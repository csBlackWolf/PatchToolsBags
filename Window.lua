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
    b:SetScript("OnClick",function(button,key)
        if self.sorting then return end
        local modified=IsModifiedClick()
        local info=C_Container.GetContainerItemInfo(bag,slot)
        if key~="LeftButton" and modified and IsModifiedClick("AUTOLOOTTOGGLE") and info and info.hasLoot then modified=false end
        if modified then ContainerFrameItemButton_OnModifiedClick(button,key)
        else ContainerFrameItemButton_OnClick(button,key) end
    end)
    b:SetScript("OnDragStart",function(button) if not self.sorting then ContainerFrameItemButton_OnDrag(button) end end)
    b:SetScript("OnReceiveDrag",function(button) if not self.sorting then ContainerFrameItemButton_OnClick(button,"LeftButton") end end)
    b.UpdateTooltip=function(button) self:Tooltip(button) end
    b:SetScript("OnEnter",b.UpdateTooltip)
    b:SetScript("OnLeave",function(button)
        if GameTooltip:GetOwner()==button then
            GameTooltip:Hide(); ShoppingTooltip1:Hide(); ShoppingTooltip2:Hide()
        end
        ResetCursor()
    end)
    b:SetScript("OnUpdate",nil)
    b.edge=CreateFrame("Frame",nil,b,"BackdropTemplate"); b.edge:SetAllPoints()
    b.edge:SetBackdrop({edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    b.mark=self:Text(b,"",11); b.mark:SetPoint("TOPLEFT",3,-2)
    return b
end
function Bags:CreateWindow()
    if self.window then return end
    local f=CreateFrame("Frame","PatchToolsBagsWindow",UIParent,"BackdropTemplate")
    self.window=f; f:Hide(); self:Backdrop(f)
    f:SetFrameStrata("HIGH"); f:SetMovable(true); f:SetClampedToScreen(true); f:EnableMouse(true)
    f:SetSize(424,400)
    local header=CreateFrame("Frame",nil,f); header:SetPoint("TOPLEFT",1,-1); header:SetPoint("TOPRIGHT",-1,-1); header:SetHeight(35)
    header:EnableMouse(true); header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart",function() f:StartMoving() end)
    header:SetScript("OnDragStop",function()
        f:StopMovingOrSizing(); self.db.x=f:GetLeft(); self.db.y=f:GetTop()
    end)
    local title=self:Text(header,"PatchToolsBags",15); title:SetPoint("LEFT",10,0)
    local close=self:Button(header,"×",24,function() f:Hide() end); close:SetPoint("RIGHT",-7,0)
    f.sort=self:Button(f,self:T("Sort","Sortieren"),92,function() self:Sort(); self:QueueRefresh() end)
    f.sort:SetPoint("TOPRIGHT",-10,-43)
    local search=CreateFrame("EditBox",nil,f,"InputBoxTemplate")
    search:SetPoint("TOPLEFT",16,-44); search:SetPoint("RIGHT",f.sort,"LEFT",-14,0); search:SetHeight(22)
    search:SetAutoFocus(false); search:SetMaxLetters(80)
    search:SetScript("OnTextChanged",function() self.query=string.lower(search:GetText() or ""); self:QueueRefresh() end)
    search:SetScript("OnEscapePressed",function() search:ClearFocus() end)
    search:SetScript("OnEnterPressed",function() search:ClearFocus() end)
    search:SetScript("OnEnter",function()
        GameTooltip:SetOwner(search,"ANCHOR_TOP"); GameTooltip:SetText(self:T("Search: name, item ID, quest, junk, sell, protected","Suche: Name, Item-ID, quest, schrott, verkauf, geschützt"),1,0.82,0,1,true); GameTooltip:Show()
    end)
    search:SetScript("OnLeave",function() if GameTooltip:GetOwner()==search then GameTooltip:Hide() end end)
    f.summary=self:Text(f,"",11); f.summary:SetPoint("BOTTOMLEFT",10,29)
    f.legend=self:Text(f,self:T("Q Quest   P Protected   V Sell   J Junk","Q Quest   P Geschützt   V Verkauf   J Schrott"),10)
    f.legend:SetPoint("BOTTOMLEFT",10,10); f.legend:SetTextColor(0.7,0.66,0.55)
    f.money=self:Text(f,"",11); f.money:SetPoint("BOTTOMRIGHT",-10,29)
    local grip=CreateFrame("Button",nil,f)
    grip:SetSize(20,20); grip:SetPoint("BOTTOMRIGHT",-1,1)
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
function Bags:RefreshWindow()
    local slots=self:Scan(); local f=self.window
    local sections=self:Sections(slots)
    local available=UIParent:GetHeight()/self.db.scale-160
    local columns=math.max(self.db.columns,math.ceil(#slots/math.max(1,math.floor(available/40))))
    columns=math.min(20,columns)
    local function ContentHeight()
        local height=0
        for _,section in ipairs(sections) do height=height+24+math.ceil(#section.slots/columns)*40+8 end
        return height
    end
    while ContentHeight()>available and columns<20 do columns=columns+1 end
    f:SetSize(math.max(400,columns*40+20),ContentHeight()+132)
    f:SetScale(self.db.scale)
    self.sectionLabels=self.sectionLabels or {}
    for _,label in ipairs(self.sectionLabels) do label:Hide() end
    local y=78
    for index,section in ipairs(sections) do
        local label=self.sectionLabels[index]
        if not label then label=self:Text(f,"",11); self.sectionLabels[index]=label end
        local title=self:T("Bags","Taschen")
        if section.key~="general" then
            local getName=C_Container.GetBagName or GetBagName
            title=(getName and getName(section.bag)) or self:T("Specialty bag","Spezialtasche")
        end
        local free=0
        for _,slot in ipairs(section.slots) do if not slot.info then free=free+1 end end
        label:SetText(title.." · "..free.." / "..#section.slots..self:T(" free"," frei"))
        label:ClearAllPoints(); label:SetPoint("TOPLEFT",f,"TOPLEFT",10,-y); label:Show()
        y=y+24
        for i,slot in ipairs(section.slots) do
            slot.viewX=10+((i-1)%columns)*40
            slot.viewY=-y-math.floor((i-1)/columns)*40
        end
        y=y+math.ceil(#section.slots/columns)*40+8
    end
    local used=0
    for _,b in pairs(self.buttons) do b:Hide() end
    local marks={quest={"Q",1,0.85,0.2},protected={"P",0.3,0.8,1},sell={"V",1,0.7,0.1},junk={"J",0.7,0.7,0.7}}
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
        b.edge:SetBackdropBorderColor(color and color.r*0.65 or 0.25,color and color.g*0.65 or 0.22,color and color.b*0.65 or 0.15,1)
        local mark=self.db.markers and marks[s.mark]
        b.mark:SetText(mark and mark[1] or ""); if mark then b.mark:SetTextColor(mark[2],mark[3],mark[4]) end
        b:SetAlpha(self:Matches(s,self.query) and 1 or 0.22)
        local start,duration,enable=C_Container.GetContainerItemCooldown(s.bag,s.slot)
        if b.Cooldown then CooldownFrame_Set(b.Cooldown,start,duration,enable) end
        if self.sorting then b:Disable() else b:Enable() end
    end
    f.summary:SetText(string.format(self:T("%d / %d slots · %d free","%d / %d Plätze · %d frei"),used,#slots,#slots-used))
    f.money:SetText(GetCoinTextureString(GetMoney()))
    f.sort.label:SetText(self.sorting and self:T("Sorting…","Sortiert…") or self:T("Sort","Sortieren"))
    f.legend:SetShown(self.db.markers)
end
