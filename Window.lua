local _,Bags=...
local bronze={0.38,0.29,0.14,1}
function Bags:Backdrop(frame)
    frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    frame:SetBackdropColor(0.045,0.035,0.025,0.97)
    frame:SetBackdropBorderColor(unpack(bronze))
end
function Bags:Text(parent,text,size)
    local f=parent:CreateFontString(nil,"OVERLAY","GameFontNormal")
    f:SetText(text); if size then f:SetFont(f:GetFont(),size) end
    return f
end
function Bags:Button(parent,text,width,callback)
    local b=CreateFrame("Button",nil,parent,"BackdropTemplate")
    self:Backdrop(b); b:SetSize(width,24)
    b.label=self:Text(b,text); b.label:SetPoint("CENTER")
    b:SetScript("OnClick",callback)
    b:SetScript("OnEnter",function() b:SetBackdropBorderColor(0.9,0.7,0.25,1) end)
    b:SetScript("OnLeave",function() b:SetBackdropBorderColor(unpack(bronze)) end)
    return b
end
function Bags:PlaceWindow()
    local f=self.window
    f:SetScale(self.db.scale); f:ClearAllPoints()
    if self.db.x and self.db.y then f:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",self.db.x,self.db.y)
    else f:SetPoint("CENTER",UIParent,"CENTER",130,0) end
end
-- Preserve the explicit anchor while Blizzard builds comparisons. Position the
-- whole visible group afterwards, rather than triggering Classic's NONE branch.
function Bags:Tooltip(button)
    if not button.hasItem or self.sorting then return end
    local tip=GameTooltip
    tip:SetOwner(button,"ANCHOR_PRESERVE")
    tip:ClearAllPoints(); tip:SetPoint("BOTTOMLEFT",button,"TOPLEFT",0,8)
    tip:SetBagItem(button:GetParent():GetID(),button:GetID())
    tip:Show()
    local compare=IsModifiedClick("COMPAREITEMS") or (GetCVarBool and GetCVarBool("alwaysCompareItems"))
    if compare then GameTooltip_ShowCompareItem(tip)
    else
        if ShoppingTooltip1 then ShoppingTooltip1:Hide() end
        if ShoppingTooltip2 then ShoppingTooltip2:Hide() end
    end
    local group={tip}
    for _,t in ipairs({ShoppingTooltip1,ShoppingTooltip2}) do if t:IsShown() then group[#group+1]=t end end
    -- Coordinates are converted through each tooltip's effective scale.
    local scale=tip:GetEffectiveScale()
    local screenW=UIParent:GetWidth()*UIParent:GetEffectiveScale()/scale
    local screenH=UIParent:GetHeight()*UIParent:GetEffectiveScale()/scale
    local widths,total,height={},0,0
    for i,t in ipairs(group) do
        widths[i]=t:GetWidth()*t:GetEffectiveScale()/scale
        total=total+widths[i]+(i>1 and 4 or 0)
        height=math.max(height,t:GetHeight()*t:GetEffectiveScale()/scale)
    end
    local left=math.max(8,math.min(button:GetLeft()*button:GetEffectiveScale()/scale,screenW-total-8))
    local top=math.min(screenH-8,button:GetTop()*button:GetEffectiveScale()/scale+height+8)
    for i,t in ipairs(group) do
        local ratio=scale/t:GetEffectiveScale()
        t:ClearAllPoints(); t:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",left*ratio,top*ratio)
        left=left+widths[i]+4
    end
end
function Bags:CreateItemButton(parent,bag,slot)
    -- The standard template supplies stack splitting, drag and item behavior.
    local b=CreateFrame("Button", "PatchToolsBagsItem"..bag.."_"..slot,parent,"ContainerFrameItemButtonTemplate")
    b.Cooldown=_G[b:GetName().."Cooldown"]
    local normal=b:GetNormalTexture()
    if normal then normal:Hide() end
    -- The native container template leaves its store-purchase highlight visible.
    -- Blizzard's normal refresh hides it; our own renderer must do that too.
    for _,key in ipairs({"BattlepayItemTexture","NewItemTexture","flash"}) do
        if b[key] then b[key]:Hide() end
    end
    b:SetID(slot); b:SetSize(36,36)
    b:RegisterForClicks("LeftButtonUp","RightButtonUp"); b:RegisterForDrag("LeftButton")
    -- Keep the secure XML click/drag scripts inherited from Blizzard intact.
    -- Replacing them with addon closures taints spell-targeted item use (pet
    -- feeding, enchanting, etc.). Sorting disables the buttons instead.
    b.UpdateTooltip=function(button) self:Tooltip(button) end
    b:SetScript("OnEnter",b.UpdateTooltip)
    b:SetScript("OnLeave",function(button)
        if GameTooltip:GetOwner()==button then
            GameTooltip:Hide(); ShoppingTooltip1:Hide(); ShoppingTooltip2:Hide()
        end
        ResetCursor()
    end)
    b:SetScript("OnUpdate",nil)
    -- Blizzard's native rounded icon outline follows the item button shape.
    b.edge=b:CreateTexture(nil,"OVERLAY",nil,4); b.edge:SetAllPoints()
    b.edge:SetTexture("Interface\\Common\\WhiteIconFrame")
    local icon=b.icon or _G[b:GetName().."IconTexture"]
    if icon then
        icon:ClearAllPoints(); icon:SetPoint("TOPLEFT",2,-2); icon:SetPoint("BOTTOMRIGHT",-2,2)
    end
    b.mark=b:CreateTexture(nil,"OVERLAY",nil,7); b.mark:SetSize(13,13); b.mark:SetPoint("TOPLEFT",4,-6)
    b.markShadows={}
    for _,offset in ipairs({{-1,0},{1,0},{0,-1},{0,1},{-1,-1},{1,-1},{-1,1},{1,1}}) do
        local shadow=b:CreateTexture(nil,"OVERLAY",nil,6)
        shadow:SetSize(13,13); shadow:SetPoint("CENTER",b.mark,"CENTER",offset[1],offset[2])
        shadow:SetVertexColor(0,0,0,(offset[1]==0 or offset[2]==0) and 0.5 or 0.25)
        b.markShadows[#b.markShadows+1]=shadow
    end
    return b
end
function Bags:CreateWindow()
    if self.window then return end
    local f=CreateFrame("Frame","PatchToolsBagsWindow",UIParent,"BackdropTemplate")
    self.window=f; f:Hide(); self:Backdrop(f)
    f:SetFrameStrata("HIGH"); f:SetMovable(true); f:SetClampedToScreen(true); f:EnableMouse(true)
    f:SetSize(424,400)
    local header=CreateFrame("Frame",nil,f); header:SetPoint("TOPLEFT",1,-1); header:SetPoint("TOPRIGHT",-1,-1); header:SetHeight(27)
    header:EnableMouse(true); header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart",function() f:StartMoving() end)
    header:SetScript("OnDragStop",function()
        f:StopMovingOrSizing(); self.db.x=f:GetLeft(); self.db.y=f:GetTop()
    end)
    local title=self:Text(header,"PatchToolsBags",14); title:SetPoint("LEFT",6,0)
    local close=self:Button(header,"×",20,function() f:Hide() end); close:SetHeight(20); close:SetPoint("RIGHT",-5,0)
    f.sort=self:Button(f,self:T("Sort","Sortieren"),86,function() self:Sort(); self:QueueRefresh() end)
    f.sort:SetHeight(20); f.sort:SetPoint("TOPRIGHT",-6,-32)
    local search=CreateFrame("EditBox",nil,f,"InputBoxTemplate")
    search:SetPoint("TOPLEFT",12,-32); search:SetPoint("RIGHT",f.sort,"LEFT",-12,0); search:SetHeight(20)
    search:SetAutoFocus(false); search:SetMaxLetters(80)
    search:SetScript("OnTextChanged",function() self.query=string.lower(search:GetText() or ""); self:QueueRefresh() end)
    search:SetScript("OnEscapePressed",function() search:ClearFocus() end)
    search:SetScript("OnEnterPressed",function() search:ClearFocus() end)
    search:SetScript("OnEnter",function()
        GameTooltip:SetOwner(search,"ANCHOR_TOP"); GameTooltip:SetText(self:T("Search: name, item ID, quest, junk, sell, protected","Suche: Name, Item-ID, quest, schrott, verkauf, geschützt"),1,0.82,0,1,true); GameTooltip:Show()
    end)
    search:SetScript("OnLeave",function() if GameTooltip:GetOwner()==search then GameTooltip:Hide() end end)
    f.summary=self:Text(f,"",11); f.summary:SetPoint("BOTTOMLEFT",6,7)
    f.money=self:Text(f,"",11); f.money:SetPoint("BOTTOMRIGHT",-22,7)
    local help=self:Button(header,"?",18,function() end)
    help:SetHeight(20); help:SetPoint("RIGHT",close,"LEFT",-4,0)
    help:SetScript("OnEnter",function()
        GameTooltip:SetOwner(help,"ANCHOR_TOP")
        GameTooltip:SetText(self:T("Gold coin: sell · Grey coin: junk · ! Quest · Key: protected\nSort: order display and merge stacks.\nDrag the lower right corner to scale.","Goldmünze: Verkauf · Graue Münze: Schrott · ! Quest · Schlüssel: geschützt\nSortieren: Anzeige ordnen und Stapel zusammenführen.\nEcke unten rechts ziehen: skalieren."),1,0.82,0,1,true)
        GameTooltip:Show()
    end)
    help:SetScript("OnLeave",function() if GameTooltip:GetOwner()==help then GameTooltip:Hide() end end)
    local grip=CreateFrame("Button",nil,f)
    grip:SetSize(16,16); grip:SetPoint("BOTTOMRIGHT",-1,1)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    local function StopScaling()
        grip:SetScript("OnUpdate",nil)
        self.db.x=f:GetLeft(); self.db.y=f:GetTop()
    end
    grip:SetScript("OnMouseDown",function(_,button)
        if button~="LeftButton" then return end
        local cursorX,cursorY=GetCursorPosition()
        local uiScale=UIParent:GetEffectiveScale()
        local initial=self.db.scale
        local left,top=f:GetLeft()*initial,f:GetTop()*initial
        local span=f:GetWidth()+f:GetHeight()
        grip:SetScript("OnUpdate",function()
            if not IsMouseButtonDown("LeftButton") then StopScaling(); return end
            local x,y=GetCursorPosition()
            local value=math.max(0.65,math.min(1.3,initial+((x-cursorX)-(y-cursorY))/uiScale/span))
            self.db.scale=value
            f:SetScale(value)
            f:ClearAllPoints(); f:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",left/value,top/value)
        end)
    end)
    grip:SetScript("OnMouseUp",StopScaling)
    grip:SetScript("OnHide",function() grip:SetScript("OnUpdate",nil) end)
    self.bagParents={}; self.buttons={}; self.query=""
    f:SetScript("OnShow",function() self:RefreshWindow() end)
    f:SetScript("OnHide",function()
        if self.sorting then self:StopSort() end
        search:ClearFocus()
        local owner=GameTooltip:GetOwner()
        if owner and owner.ptBags then GameTooltip:Hide(); ShoppingTooltip1:Hide(); ShoppingTooltip2:Hide() end
    end)
    UISpecialFrames[#UISpecialFrames+1]="PatchToolsBagsWindow"
    self:PlaceWindow()
end
function Bags:SectionIcon(section)
    local fallback="Interface\\Icons\\INV_Misc_Bag_08"
    local inventoryID=C_Container.ContainerIDToInventoryID or ContainerIDToInventoryID
    if section.key=="general" or not inventoryID then return fallback end
    local inventory=inventoryID(section.bag)
    local link=GetInventoryItemLink and GetInventoryItemLink("player",inventory)
    local getInfo=C_Item and C_Item.GetItemInfo or GetItemInfo
    if link and getInfo then
        local class,subclass=select(12,getInfo(link))
        if class==11 and subclass==2 then return "Interface\\Icons\\INV_Misc_Quiver_10" end
        if class==11 and subclass==3 then return "Interface\\Icons\\INV_Misc_Ammo_Bullet_01" end
    end
    return (GetInventoryItemTexture and GetInventoryItemTexture("player",inventory)) or fallback
end
function Bags:RefreshWindow()
    local slots=self:Scan(); local f=self.window
    local sections=self:Sections(slots)
    local available=UIParent:GetHeight()/self.db.scale-160
    local columns=math.max(self.db.columns,math.ceil(#slots/math.max(1,math.floor(available/38))))
    columns=math.min(20,columns)
    local function ContentHeight()
        local height=0
        for _,section in ipairs(sections) do height=height+math.max(40,math.ceil(#section.slots/columns)*38)+4 end
        return height
    end
    while ContentHeight()>available and columns<20 do columns=columns+1 end
    f:SetSize(math.max(300,columns*38+30),ContentHeight()+80)
    f:SetScale(self.db.scale)
    self.sectionBadges=self.sectionBadges or {}
    for _,badge in ipairs(self.sectionBadges) do badge:Hide() end
    local y=58
    for index,section in ipairs(sections) do
        local badge=self.sectionBadges[index]
        if not badge then
            badge=CreateFrame("Frame",nil,f); badge:SetSize(20,40); badge:EnableMouse(true)
            badge.icon=badge:CreateTexture(nil,"ARTWORK"); badge.icon:SetSize(18,18); badge.icon:SetPoint("TOP",0,-2)
            badge.count=self:Text(badge,"",10); badge.count:SetPoint("TOP",0,-23)
            badge:SetScript("OnEnter",function()
                GameTooltip:SetOwner(badge,"ANCHOR_LEFT")
                GameTooltip:SetText(badge.title,1,0.82,0)
                GameTooltip:AddLine(badge.detail,1,1,1,true)
                for _,line in ipairs(badge.bagLines) do GameTooltip:AddLine(line,0.8,0.8,0.8,true) end
                GameTooltip:Show()
            end)
            badge:SetScript("OnLeave",function() if GameTooltip:GetOwner()==badge then GameTooltip:Hide() end end)
            self.sectionBadges[index]=badge
        end
        local getName=C_Container.GetBagName or GetBagName
        badge.title=section.key=="general" and self:T("Combined bags","Zusammengefasste Taschen")
            or (getName and getName(section.bag)) or self:T("Specialty bag","Spezialtasche")
        local free,bagOrder,counts=0,{},{}
        for _,slot in ipairs(section.slots) do
            if not counts[slot.bag] then counts[slot.bag]={total=0,free=0}; bagOrder[#bagOrder+1]=slot.bag end
            counts[slot.bag].total=counts[slot.bag].total+1
            if not slot.info then free=free+1; counts[slot.bag].free=counts[slot.bag].free+1 end
        end
        table.sort(bagOrder)
        badge.bagLines={}
        for _,bag in ipairs(bagOrder) do
            local count=counts[bag]
            local name=(getName and getName(bag)) or (bag==0 and self:T("Backpack","Rucksack") or self:T("Bag ","Tasche ")..bag)
            badge.bagLines[#badge.bagLines+1]=name..": "..count.free.." / "..count.total..self:T(" free"," frei")
        end
        badge.detail=string.format(self:T("%d free / %d slots","%d frei / %d Plätze"),free,#section.slots)
        badge.icon:SetTexture(self:SectionIcon(section)); badge.count:SetText(free)
        badge:ClearAllPoints(); badge:SetPoint("TOPLEFT",f,"TOPLEFT",3,-y); badge:Show()
        for i,slot in ipairs(section.slots) do
            slot.viewX=26+((i-1)%columns)*38
            slot.viewY=-y-math.floor((i-1)/columns)*38
        end
        y=y+math.max(40,math.ceil(#section.slots/columns)*38)+4
    end
    local used=0
    for _,b in pairs(self.buttons) do b:Hide() end
    local marks={
        quest="Interface\\GossipFrame\\AvailableQuestIcon",
        protected="Interface\\Icons\\INV_Misc_Key_03",
        sell="Interface\\MoneyFrame\\UI-GoldIcon",
    }
    for i,s in ipairs(slots) do
        if not self.bagParents[s.bag] then
            local p=CreateFrame("Frame",nil,f); p:SetAllPoints(); p:SetID(s.bag); self.bagParents[s.bag]=p
        end
        local key=s.bag..":"..s.slot
        local b=self.buttons[key]
        if not b then b=self:CreateItemButton(self.bagParents[s.bag],s.bag,s.slot); b.ptBags=true; self.buttons[key]=b end
        b:ClearAllPoints(); b:SetPoint("TOPLEFT",f,"TOPLEFT",s.viewX,s.viewY)
        b:Show(); b.hasItem=s.info~=nil; b.readable=s.info and s.info.isReadable
        SetItemButtonTexture(b,s.info and s.info.iconFileID or "Interface\\Buttons\\WHITE8X8")
        local icon=b.icon or _G[b:GetName().."IconTexture"]
        if icon then
            if s.info then icon:SetVertexColor(1,1,1)
            else icon:SetVertexColor(0.065,0.055,0.04) end
        end
        SetItemButtonCount(b,s.info and s.info.stackCount or 0)
        SetItemButtonDesaturated(b,s.info and s.info.isLocked or false)
        if s.info then used=used+1 end
        local q=s.info and s.info.quality
        local color=q and q>=2 and ITEM_QUALITY_COLORS[q]
        if s.mark=="quest" then b.edge:SetVertexColor(1,0.78,0.08,1)
        else b.edge:SetVertexColor(color and color.r*0.9 or 0.25,color and color.g*0.9 or 0.22,color and color.b*0.9 or 0.15,1) end
        local mark=self.db.markers and s.mark
        -- Use the same coin for both sale lists and junk, with grey denoting junk.
        -- Quest and blocklist protection still win.
        if self.db.markers and s.info and s.info.quality==0 and mark~="quest" and mark~="protected" then mark="junk" end
        local markerTexture=mark=="junk" and marks.sell or (mark and marks[mark])
        b.mark:SetShown(markerTexture~=nil and markerTexture~=false)
        b.mark:SetDesaturated(mark=="junk"); b.mark:SetVertexColor(1,1,1)
        if markerTexture then b.mark:SetTexture(markerTexture) end
        for _,shadow in ipairs(b.markShadows) do
            shadow:SetShown(markerTexture~=nil and markerTexture~=false)
            if markerTexture then shadow:SetTexture(markerTexture) end
        end
        b:SetAlpha(self:Matches(s,self.query) and 1 or 0.22)
        local start,duration,enable=C_Container.GetContainerItemCooldown(s.bag,s.slot)
        if b.Cooldown then CooldownFrame_Set(b.Cooldown,start,duration,enable) end
        if self.sorting then b:Disable() else b:Enable() end
    end
    f.summary:SetText(string.format(self:T("%d / %d slots · %d free","%d / %d Plätze · %d frei"),used,#slots,#slots-used))
    f.money:SetText(GetCoinTextureString(GetMoney()))
    f.sort.label:SetText(self.sorting and self:T("Sorting…","Sortiert…") or self:T("Sort","Sortieren"))
end
