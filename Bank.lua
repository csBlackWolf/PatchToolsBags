local _,Bags=...

-- Era's bank bag enums can describe retail indices. Derive its equipped bank
-- bags from the carried-bag count instead. Forever's bank uses purchased tabs;
-- never guess tab indices from the profession bag's ID.
function Bags:BankBagIDs()
    if self.owner.isForever then
        local bankType=Enum and Enum.BankType and Enum.BankType.Character
        if not bankType or not C_Bank or not C_Bank.FetchPurchasedBankTabIDs then return nil end
        if C_Bank.CanViewBank and not C_Bank.CanViewBank(bankType) then return nil end
        local tabs=C_Bank.FetchPurchasedBankTabIDs(bankType)
        if type(tabs)~="table" then return nil end
        local carried={}
        for _,id in ipairs(self:BagIDs()) do carried[id]=true end
        local ids,seen={},{}
        for _,id in ipairs(tabs) do
            if type(id)~="number" or carried[id] then return nil end
            if not seen[id] then ids[#ids+1]=id; seen[id]=true end
        end
        return ids
    end
    local ids={BANK_CONTAINER or -1}
    local count=NUM_BANKBAGSLOTS or NUM_BANKBAG_SLOTS or 6
    local carried=NUM_BAG_SLOTS or 4
    for index=1,count do ids[#ids+1]=carried+index end
    return ids
end

function Bags:CanReplaceBank()
    return self.db.replaceBank~=false and self:CanReplace() and self:BankBagIDs()~=nil
end

function Bags:CreateBankView()
    if self.bankView then return self.bankView end
    if type(self.windowDB.bank)~="table" then
        self.windowDB.bank={scale=self.windowDB.scale,columns=self.windowDB.columns}
    end
    local view={isBank=true,owner=self.owner,db=self.db,windowDB=self.windowDB.bank}
    -- Share behavior, never window/button/layout state between the two views.
    setmetatable(view,{__index=function(_,key)
        if type(Bags[key])=="function" then return Bags[key] end
    end})
    view.windowDB.scale=math.max(.65,math.min(1.3,tonumber(view.windowDB.scale) or 1))
    view.windowDB.columns=math.max(6,math.min(16,tonumber(view.windowDB.columns) or 10))
    view.IsAvailable=function() return Bags.bankOpen and not Bags.bankManagement end
    view.BagIDs=function() return view:IsAvailable() and Bags:BankBagIDs() or {} end
    view.ConnectPawn=function() return Bags:ConnectPawn() end
    view.PawnUpgrade=function(_,link) return Bags:PawnUpgrade(link) end
    self.bankView=view
    view:CreateWindow()
    view.window:HookScript("OnHide",function()
        if Bags.bankOpen and not Bags.bankClosing and not Bags.bankManagement and CloseBankFrame then CloseBankFrame() end
    end)
    return view
end

function Bags:CreateBankControls()
    local button=self:Button(self.window.header,self:T("Bank bags","Banktaschen"),100,function()
        if InCombatLockdown() then return end
        self.bankSlotsExpanded=not self.bankSlotsExpanded
        self:RefreshWindow()
    end)
    self.window.bankBags=button
    button:SetHeight(20); button:SetPoint("RIGHT",self.window.settings,"LEFT",-4,0)
    button:SetScript("OnEnter",function()
        GameTooltip:SetOwner(button,"ANCHOR_TOP")
        GameTooltip:SetText(self:T("Show or hide bank bag slots. Click a locked slot to purchase it with confirmation.",
            "Banktaschenplätze ein- oder ausblenden. Gesperrten Platz anklicken, um ihn mit Bestätigung zu kaufen."),1,.82,0,1,true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave",function() GameTooltip:Hide() end)
end

function Bags:OpenNativeBank()
    if not self.bankOpen then
        self:Print("Visit a banker first.","Bitte zuerst einen Bankier besuchen."); return
    end
    if InCombatLockdown() then return end
    if self.bankView and self.bankView.sorting then self.bankView:StopSort() end
    self.bankManagement=true
    self:SetNativeBankVisible(true)
    if self.bankView then self.bankView.window:Hide() end
end

function Bags:ConfirmBankSlotPurchase(index)
    if not Bags.bankOpen or Bags.bankManagement or self.owner.isForever or InCombatLockdown() then return end
    local count,full=GetNumBankSlots()
    if full or index<=count then return end
    -- Use Blizzard's confirmation and purchase logic. A dragged bag stays on
    -- the cursor; buying a slot never also equips or discards that bag.
    BankFrame.nextSlotCost=GetBankSlotCost(count)
    StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
end

function Bags:SetNativeBankVisible(visible)
    local frame=BankFrame
    if not frame then return end
    if visible then
        self:RestoreBankSlotControls()
        local saved=self.nativeBankAppearance
        if not saved then return end
        frame:SetAlpha(saved.alpha)
        for widget,enabled in pairs(saved.mouse) do widget:EnableMouse(enabled) end
        self.nativeBankAppearance=nil
    else
        if not self.nativeBankAppearance then
            self.nativeBankAppearance={alpha=frame:GetAlpha(),mouse={}}
        end
        local saved=self.nativeBankAppearance
        local function Disable(widget)
            if widget.EnableMouse and widget.IsMouseEnabled then
                if saved.mouse[widget]==nil then saved.mouse[widget]=widget:IsMouseEnabled() end
                widget:EnableMouse(false)
            end
            if widget.GetChildren then for _,child in ipairs({widget:GetChildren()}) do Disable(child) end end
        end
        Disable(frame)
        -- Keep BankFrame logically open: the native item handlers depend on it
        -- for right-click deposits and withdrawals. Only hide its presentation.
        frame:SetAlpha(0)
    end
end

function Bags:BankSlotRowHeight()
    -- Forever purchases tabs rather than equipping Era bank bags. Its native
    -- management view remains available; never reinterpret profession-bag IDs.
    return self.bankSlotsExpanded and not self.owner.isForever and BankSlotsFrame and BankSlotsFrame.Bag1 and 42 or 0
end

function Bags:RestoreBankSlotControls()
    if self.bankView then
        for _,overlay in pairs(self.bankView.bankSlotPurchaseOverlays or {}) do overlay:Hide() end
        if self.bankView.window.bankSlotCost then self.bankView.window.bankSlotCost:Hide() end
    end
    for _,entry in ipairs(self.nativeBankSlotControls or {}) do
        local button=entry.button
        button:SetParent(entry.parent); button:SetScale(entry.scale)
        button:ClearAllPoints()
        for _,point in ipairs(entry.points) do button:SetPoint(unpack(point)) end
        button:SetShown(entry.shown)
    end
    self.nativeBankSlotControls=nil
end

function Bags:LayoutBankSlotControls()
    if not self.isBank or not Bags.bankOpen or Bags.bankManagement then return end
    if InCombatLockdown and InCombatLockdown() then return end
    self.window.bankBags:SetShown(not self.owner.isForever)
    if self:BankSlotRowHeight()==0 then
        for _,entry in ipairs(Bags.nativeBankSlotControls or {}) do entry.button:Hide() end
        for _,overlay in pairs(self.bankSlotPurchaseOverlays or {}) do overlay:Hide() end
        if self.window.bankSlotCost then self.window.bankSlotCost:Hide() end
        return
    end
    Bags.nativeBankSlotControls=Bags.nativeBankSlotControls or {}
    local function Adopt(button)
        if not button then return end
        local known=false
        for _,entry in ipairs(Bags.nativeBankSlotControls) do if entry.button==button then known=true; break end end
        if not known then
            local points={}
            for i=1,button:GetNumPoints() do points[i]={button:GetPoint(i)} end
            Bags.nativeBankSlotControls[#Bags.nativeBankSlotControls+1]={button=button,parent=button:GetParent(),
                scale=button:GetScale(),points=points,shown=button:IsShown()}
        end
        -- These are the real Blizzard controls, including their original item
        -- pickup/drop handlers and purchase confirmation. Only presentation moves.
        button:SetParent(self.window); button:SetScale(.85); button:EnableMouse(true)
        button:ClearAllPoints(); button:Show()
    end
    for index=1,(NUM_BANKBAGSLOTS or NUM_BANKBAG_SLOTS or 6) do
        local button=BankSlotsFrame["Bag"..index]
        if button then
            Adopt(button); button:SetPoint("BOTTOMLEFT",self.window,"BOTTOMLEFT",(8+(index-1)*34)/.85,30/.85)
            self.bankSlotPurchaseOverlays=self.bankSlotPurchaseOverlays or {}
            local overlay=self.bankSlotPurchaseOverlays[index]
            if not overlay then
                overlay=CreateFrame("Button",nil,button)
                overlay:SetAllPoints(); overlay:RegisterForClicks("LeftButtonUp","RightButtonUp")
                local slotIndex=index
                overlay:SetScript("OnClick",function() self:ConfirmBankSlotPurchase(slotIndex) end)
                overlay:SetScript("OnReceiveDrag",function() self:ConfirmBankSlotPurchase(slotIndex) end)
                overlay:SetScript("OnEnter",function()
                    GameTooltip:SetOwner(overlay,"ANCHOR_TOP")
                    GameTooltip:SetText(self:T("Unlock bank bag slot","Banktaschenplatz freischalten"),1,.82,0)
                    local count=GetNumBankSlots()
                    GameTooltip:AddLine(GetCoinTextureString(GetBankSlotCost(count)),1,1,1)
                    GameTooltip:Show()
                end)
                overlay:SetScript("OnLeave",function() GameTooltip:Hide() end)
                self.bankSlotPurchaseOverlays[index]=overlay
            end
            local count,full=GetNumBankSlots()
            overlay:SetShown(not full and index>count)
        end
    end
    local purchase=BankFramePurchaseButton
    if purchase then
        Adopt(purchase); purchase:SetPoint("BOTTOMRIGHT",self.window,"BOTTOMRIGHT",-8/.85,30/.85)
        local count,full=GetNumBankSlots()
        purchase:SetShown(not full)
        if not self.window.bankSlotCost then self.window.bankSlotCost=self:Text(self.window,"",11) end
        local cost=self.window.bankSlotCost
        cost:ClearAllPoints(); cost:SetPoint("RIGHT",purchase,"LEFT",-6,0)
        cost:SetText(full and "" or GetCoinTextureString(GetBankSlotCost(count)))
        cost:SetShown(not full)
    end
end

function Bags:ShowBank()
    if not self.bankOpen or not self:CanReplaceBank() then return end
    self.bankManagement=nil
    local view=self:CreateBankView()
    self:SetNativeBankVisible(false)
    if CloseBag and not self.owner.isForever then
        for _,id in ipairs(self:BankBagIDs()) do if id>=0 then CloseBag(id) end end
    end
    view.window:Show()
    self:CreateWindow(); self.window:Show()
end

function Bags:ResetBankWindow()
    local settings=self.windowDB.bank
    if not settings then return end
    settings.x,settings.y,settings.scale,settings.columns=nil,nil,1,10
    if self.bankView then self.bankView:PlaceWindow(); self.bankView:QueueRefresh() end
end

function Bags:UpdateBankReplacement()
    if not self.bankOpen then return end
    if self:CanReplaceBank() then self:ShowBank()
    else
        self.bankManagement=true
        if self.bankView then self.bankView:StopSort(); self.bankView.window:Hide() end
        self:SetNativeBankVisible(true)
    end
end

function Bags:HandleBankEvent(event)
    if event=="BANKFRAME_OPENED" then
        self.bankOpen=true; self.bankManagement=nil
        -- UIParent opens native bank bags during this event too. Replace the
        -- presentation after those handlers finish, without closing the bank.
        C_Timer.After(0,function() if self.bankOpen then self:ShowBank() end end)
        return true
    elseif event=="BANKFRAME_CLOSED" then
        self.bankOpen=nil; self.bankClosing=true; self.bankManagement=nil
        if self.bankView then
            self.bankView:StopSort(); self.bankView.window:Hide()
        end
        self:SetNativeBankVisible(true)
        self.bankClosing=nil
        return true
    end
end

function Bags:InstallBankAccess(events)
    for _,event in ipairs({"BANKFRAME_OPENED","BANKFRAME_CLOSED","PLAYERBANKSLOTS_CHANGED"}) do events:RegisterEvent(event) end
    events:RegisterEvent(self.owner.isForever and "BANK_TABS_CHANGED" or "PLAYERBANKBAGSLOTS_CHANGED")
end
