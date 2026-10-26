local addon,Bags=...
_G.PatchToolsBags=Bags
local de=GetLocale()=="deDE"
function Bags:T(en,ger) return de and ger or en end
function Bags:Print(en,ger) print("|cff80d6ffPatchToolsBags:|r "..self:T(en,ger)) end
function Bags:BagIDs()
    local ids={0,1,2,3,4}
    if self.owner.hasProfessionBag then ids[#ids+1]=Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag or 5 end
    return ids
end
function Bags:Scan()
    local slots={}
    self.itemCache=self.itemCache or {}
    local getInfo=C_Item and C_Item.GetItemInfo or GetItemInfo
    for _,bag in ipairs(self:BagIDs()) do
        local _,family=C_Container.GetContainerNumFreeSlots(bag)
        for slot=1,C_Container.GetContainerNumSlots(bag) do
            local info=C_Container.GetContainerItemInfo(bag,slot)
            local s={bag=bag,slot=slot,family=family or 0,info=info}
            if info then
                local key=info.hyperlink or info.itemID
                local cached=self.itemCache[key]
                if not cached then
                    local name,_,_,_,_,kind,subkind,maxStack,_,_,price,class,subclass=getInfo(key)
                    cached={name=name,kind=kind,subkind=subkind,maxStack=maxStack,price=price,class=class,subclass=subclass}
                    if name then self.itemCache[key]=cached end
                end
                local name,kind,subkind,maxStack,price,class,subclass=cached.name,cached.kind,cached.subkind,cached.maxStack,cached.price,cached.class,cached.subclass
                s.name=name or "..."; s.maxStack=maxStack or 1
                s.class=class or 99; s.subclass=subclass or 99
                s.ready=name~=nil and info.hyperlink~=nil
                s.search=string.lower(table.concat({s.name,tostring(info.itemID),kind or "",subkind or ""}," "))
                local quest=C_Container.GetContainerItemQuestInfo(bag,slot)
                s.mark=self:Classify(info,quest and (quest.isQuestItem or quest.questID),price,self.owner.db or {})
            end
            slots[#slots+1]=s
        end
    end
    return slots
end
function Bags:QueueRefresh()
    if self.refreshPending then return end
    self.refreshPending=true
    C_Timer.After(0.04,function()
        self.refreshPending=nil
        if self.window and self.window:IsShown() then self:RefreshWindow() end
        local bank=rawget(self,"bankView")
        if bank and self.bankOpen and self.nativeBankAppearance then self:SetNativeBankVisible(false) end
        if bank and bank.window and bank.window:IsShown() then bank:RefreshWindow() end
    end)
end
function Bags:StopSort(message)
    if self.sorting then self:Sections(self:Scan(),true) end
    self.sorting=nil
    if message then self:Print(message[1],message[2]) end
    self:QueueRefresh()
end
function Bags:Sort()
    if self.IsAvailable and not self:IsAvailable() then return end
    if self.sorting then return end
    if GetCursorInfo() then
        self:Print("Sort with an empty cursor.","Bitte mit leerem Mauszeiger sortieren."); return
    end
    self:Sections(self:Scan(),true)
    self:RefreshWindow()
    if InCombatLockdown() then
        self:Print("Display sorted. Stack merging is skipped during combat.","Anzeige sortiert. Stapel werden im Kampf nicht zusammengeführt.")
        return
    end
    self.sorting=true
    local steps=0
    local function Step()
        if not self.sorting then return end
        if self.IsAvailable and not self:IsAvailable() then self:StopSort(); return end
        if InCombatLockdown() then
            self:StopSort({"Stack merging stopped because combat started.","Stapelzusammenführung wegen Kampfbeginn angehalten."}); return
        end
        if GetCursorInfo() or not self.window:IsShown() then self:StopSort(); return end
        local move,reason=self:NextMove(self:Scan())
        if reason then self:StopSort({"Items are still locked or loading. Please try again.","Gegenstände sind noch gesperrt oder werden geladen. Bitte erneut versuchen."}); return end
        if not move then self:StopSort(); return end
        steps=steps+1
        if steps>1000 then self:StopSort({"Sorting stopped; please try again.","Sortierung angehalten; bitte erneut versuchen."}); return end
        local a,b=move.from,move.to
        local ai,bi=a.info,b.info
        local amount=math.min(ai.stackCount,b.maxStack-bi.stackCount)
        local expectedA=ai.stackCount-amount>0 and {hyperlink=ai.hyperlink,stackCount=ai.stackCount-amount} or nil
        local expectedB={hyperlink=bi.hyperlink,stackCount=bi.stackCount+amount}
        -- Only slots in this view are touched; never clear or delete a cursor.
        C_Container.PickupContainerItem(a.bag,a.slot)
        local cursor,id=GetCursorInfo()
        if cursor~="item" or id~=ai.itemID then self:StopSort(); return end
        C_Container.PickupContainerItem(b.bag,b.slot)
        if GetCursorInfo() then C_Container.PickupContainerItem(a.bag,a.slot) end
        if GetCursorInfo() then self:StopSort({"Sorting stopped. Please place the item on your cursor.","Sortierung angehalten. Bitte den Gegenstand am Mauszeiger ablegen."}); return end
        local attempts=0
        local function Confirm()
            if not self.sorting then return end
            if self.IsAvailable and not self:IsAvailable() then self:StopSort(); return end
            attempts=attempts+1
            local x=C_Container.GetContainerItemInfo(a.bag,a.slot)
            local y=C_Container.GetContainerItemInfo(b.bag,b.slot)
            if self:Signature(x)==self:Signature(expectedA) and self:Signature(y)==self:Signature(expectedB)
                and not (x and x.isLocked or y and y.isLocked) then
                self:QueueRefresh(); C_Timer.After(0.02,Step)
            elseif attempts<30 then C_Timer.After(0.07,Confirm)
            else self:StopSort({"Inventory changed or the server did not confirm the move; sorting stopped.","Inventar geändert oder Verschiebung nicht bestätigt; Sortierung angehalten."}) end
        end
        C_Timer.After(0.02,Confirm)
    end
    Step()
end
function Bags:CanReplace()
    if not self.db.replaceBags then return false end
    local loaded=C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
    for _,name in ipairs({"Baganator","Bagnon","AdiBags","ArkInventory","BetterBags"}) do
        if loaded(name) then return false end
    end
    return true
end
function Bags:Toggle() self:CreateWindow(); self.window:SetShown(not self.window:IsShown()) end
function Bags:InstallBagAccess()
    local operations={ToggleBackpack="toggle",ToggleAllBags="toggle",ToggleBag="bag",OpenBackpack="open",OpenAllBags="open",CloseBackpack="close",CloseAllBags="close"}
    for name,op in pairs(operations) do
        local original=_G[name]
        if type(original)=="function" then
            _G[name]=function(...)
                local id=...
                local carried=false
                for _,bag in ipairs(Bags:BagIDs()) do if bag==id then carried=true; break end end
                if op=="bag" and Bags.bankOpen and not Bags.bankManagement and Bags:CanReplaceBank() then
                    for _,bag in ipairs(Bags:BankBagIDs() or {}) do
                        if bag==id then Bags:ShowBank(); return end
                    end
                end
                if not Bags:CanReplace() or (op=="bag" and not carried) then return original(...) end
                Bags:CreateWindow()
                if op=="close" then Bags.window:Hide()
                elseif op=="open" then Bags.window:Show()
                else Bags:Toggle() end
            end
        end
    end
end
local events=CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent",function(_,event)
    if event=="PLAYER_LOGIN" then
        Bags.owner=_G.PatchTools
        if not Bags.owner or not Bags.owner.RegisterOptionsPage or not C_Container then return end
        if not (Bags.owner.isClassicEra or Bags.owner.isForever) then
            Bags:Print("This prototype supports Classic Era and Forever.","Dieser Prototyp unterstützt Classic Era und Forever."); return
        end
        PatchToolsBagsDB=PatchToolsBagsDB or {}
        Bags.db=PatchToolsBagsDB
        if type(PatchToolsBagsCharacterDB)~="table" then
            PatchToolsBagsCharacterDB={scale=Bags.db.scale,columns=Bags.db.columns,x=Bags.db.x,y=Bags.db.y}
        end
        Bags.windowDB=PatchToolsBagsCharacterDB
        for k,v in pairs({replaceBags=true,replaceBank=true,markers=true,pawnUpgrades=true,backgroundTransparency=0}) do if Bags.db[k]==nil then Bags.db[k]=v end end
        Bags.windowDB.columns=math.max(6,math.min(16,tonumber(Bags.windowDB.columns) or 10))
        Bags.windowDB.scale=math.max(0.65,math.min(1.3,tonumber(Bags.windowDB.scale) or 1))
        Bags.db.backgroundTransparency=math.max(0,math.min(0.8,tonumber(Bags.db.backgroundTransparency) or 0))
        Bags.owner:RegisterOptionsPage("bags",Bags:T("Bags","Taschen"),function(parent) Bags:BuildOptions(parent) end)
        Bags:InstallBagAccess()
        if Bags.InstallBankAccess then Bags:InstallBankAccess(events) end
        SLASH_PATCHTOOLSBAGS1="/ptbags"; SLASH_PATCHTOOLSBAGS2="/patchtoolsbags"
        SlashCmdList.PATCHTOOLSBAGS=function(msg)
            if msg:lower():match("^%s*bank%s*$") then
                Bags:ShowBank()
            elseif msg:lower():match("^%s*reset%s*$") then
                Bags.windowDB.x=nil; Bags.windowDB.y=nil; Bags.windowDB.scale=1; Bags.windowDB.columns=10
                if Bags.ResetBankWindow then Bags:ResetBankWindow() end
                Bags:CreateWindow(); Bags:PlaceWindow(); Bags.window:Show(); Bags:QueueRefresh()
            else Bags:Toggle() end
        end
        for _,e in ipairs({"BAG_UPDATE_DELAYED","ITEM_LOCK_CHANGED","GET_ITEM_INFO_RECEIVED","PLAYER_MONEY","BAG_UPDATE_COOLDOWN","QUEST_LOG_UPDATE","PLAYER_EQUIPMENT_CHANGED","PLAYER_LEVEL_UP","ADDON_LOADED"}) do events:RegisterEvent(e) end
        for _,method in ipairs({"SetItemRule","SetOption"}) do
            if type(Bags.owner[method])=="function" then hooksecurefunc(Bags.owner,method,function() Bags:QueueRefresh() end) end
        end
    elseif Bags.db then
        if Bags.HandleBankEvent and Bags:HandleBankEvent(event) then return end
        if event=="PLAYER_EQUIPMENT_CHANGED" or event=="PLAYER_LEVEL_UP" or event=="GET_ITEM_INFO_RECEIVED" or event=="ADDON_LOADED" then
            Bags:InvalidatePawnUpgrades()
        else Bags:QueueRefresh() end
    end
end)
