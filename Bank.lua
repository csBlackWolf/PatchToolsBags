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
    local button=self:Button(self.window,self:T("Bank setup","Bankverwaltung"),112,function()
        if self.sorting then self:StopSort() end
        Bags.bankManagement=true
        Bags:SetNativeBankVisible(true)
        self.window:Hide()
    end)
    self.window.bankSetup=button
    button:SetHeight(20); button:SetPoint("RIGHT",self.window.settings,"LEFT",-4,0)
    button:SetScript("OnEnter",function()
        GameTooltip:SetOwner(button,"ANCHOR_TOP")
        GameTooltip:SetText(self:T("Open Blizzard's bank setup to buy slots or change bank bags. /ptbags bank returns to this view.",
            "Blizzards Bankverwaltung öffnen, um Plätze zu kaufen oder Banktaschen zu wechseln. /ptbags bank kehrt zu dieser Ansicht zurück."),1,.82,0,1,true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave",function() GameTooltip:Hide() end)
end

function Bags:SetNativeBankVisible(visible)
    local frame=BankFrame
    if not frame then return end
    if visible then
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
