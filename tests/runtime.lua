Bags={}
assert(loadfile('Model.lua'))('PatchToolsBags',Bags)
unpack=table.unpack
local frames,queue={},{}
local methods={}
local function noop() end
function methods:SetNormalTexture(asset)
 assert(asset~=nil,'Classic requires a texture asset')
end
function methods:GetNormalTexture()
 if not self.normal then self.normal=CreateFrame('Texture') end
 return self.normal
end
function methods:GetPushedTexture()
 if not self.pushed then self.pushed=CreateFrame('Texture') end
 return self.pushed
end
for name in ('SetAtlas AddLine SetHighlightTexture SetPushedTexture SetJustifyH SetBackdrop SetBackdropColor SetBackdropBorderColor SetSize SetHeight SetWidth SetPoint ClearAllPoints SetFrameStrata SetMovable SetClampedToScreen EnableMouse RegisterForClicks RegisterForDrag SetAutoFocus SetMaxLetters ClearFocus SetTextColor SetAlpha SetAllPoints SetFont SetValueStep SetObeyStepOnDrag StartMoving StopMovingOrSizing SetOwner SetBagItem SetMinMaxValues'):gmatch('%S+') do methods[name]=noop end
function methods:SetPoint(...) self.point={...} end
function methods:SetScript(key,fn)
 if self.nativeScripts and (key=='OnClick' or key=='OnDragStart' or key=='OnReceiveDrag') then
  error('Native container click/drag scripts must not be replaced by addon code')
 end
 self.scripts[key]=fn
end
function methods:HookScript(key,callback)
 local original=self.scripts[key]
 self.scripts[key]=function(...) if original then original(...) end; callback(...) end
end
function methods:GetHighlightTexture()
 if not self.highlight then self.highlight=CreateFrame('Texture') end
 return self.highlight
end
function methods:UnlockHighlight() self.highlightLocked=false end
function methods:RegisterEvent(event) self.events[event]=true end
function methods:CreateFontString() return CreateFrame('FontString') end
function methods:CreateTexture() return CreateFrame('Texture') end
function methods:SetText(t) self.text=t end
function methods:GetText() return self.text or '' end
function methods:GetFont() return 'font',12,'' end
function methods:GetName() return self.name end
function methods:GetParent() return self.parent end
function methods:SetParent(parent) self.parent=parent end
function methods:GetScale() return self.scale or 1 end
function methods:GetNumPoints() return self.point and 1 or 0 end
function methods:GetPoint() return table.unpack(self.point) end
function methods:SetDesaturated(value) self.desaturated=value end
function methods:SetAlpha(value) self.alpha=value end
function methods:SetVertexColor(...) self.vertex={...} end
function methods:SetTexture(value) self.texture=value end
function methods:SetBackdropBorderColor(...) self.border={...} end
function methods:GetOwner() return self.owner end
function methods:GetAlpha() return self.alpha or 1 end
function methods:IsMouseEnabled() return self.mouseEnabled~=false end
function methods:IsMouseOver() return self.mouseOver==true end
function methods:EnableMouse(enabled) self.mouseEnabled=enabled end
function methods:GetChildren()
 local children={}
 for _,frame in ipairs(frames) do if frame.parent==self then children[#children+1]=frame end end
 return table.unpack(children)
end
function methods:SetAttribute(key,value)
 assert(not self.nativeScripts,'native button attributes must stay unchanged')
 self.attributes=self.attributes or {}; self.attributes[key]=value
end
function methods:GetTexture() return self.texture end
function methods:GetAttribute(key) return self.attributes and self.attributes[key] end
function methods:Click()
 if self.template and self.template:find('SecureActionButtonTemplate',1,true) then
  assert(not self.scripts.OnClick,'secure proxy must keep its XML click handler')
  assert(self:GetAttribute('type')=='click' and self:GetAttribute('useOnKeyDown')==false)
  return self:GetAttribute('clickbutton'):Click()
 end
 if self.scripts.OnClick then self.scripts.OnClick(self) end
end
function methods:SetID(id) self.id=id end
function methods:GetID() return self.id end
function methods:SetScale(scale) self.scale=scale end
function methods:GetEffectiveScale() return self.scale or 1 end
function methods:GetWidth() return 1920 end
function methods:GetHeight() return 1080 end
function methods:GetLeft() return 200 end
function methods:GetTop() return 700 end
function methods:SetChecked(value) self.checked=value end
function methods:GetChecked() return self.checked end
function methods:SetValue(value) self.value=value; if self.scripts.OnValueChanged then self.scripts.OnValueChanged(self,value) end end
function methods:Hide() self.hideCount=(self.hideCount or 0)+1; self.shown=false; if self.scripts.OnHide then self.scripts.OnHide(self) end end
function methods:Show() local wasShown=self.shown; self.shown=true; if not wasShown and self.scripts.OnShow then self.scripts.OnShow(self) end end
function methods:SetShown(value) if value then self:Show() else self:Hide() end end
function methods:IsShown() return self.shown end
function methods:Enable() self.enabled=true end
function methods:Disable() self.enabled=false end
function CreateFrame(kind,name,parent,template)
 if template=='ContainerFrameItemButtonTemplate' or template=='BankItemButtonGenericTemplate' then
  assert(kind==(Bags.owner.isForever and 'ItemButton' or 'Button'),'use the correct client widget type')
 end
 local f=setmetatable({scripts={},events={},name=name,parent=parent,shown=true,template=template}, {__index=methods})
 frames[#frames+1]=f
 if name then _G[name]=f end
 if template=='OptionsSliderTemplate' then _G[name..'Low']=CreateFrame('FontString'); _G[name..'High']=CreateFrame('FontString') end
 if template=='ContainerFrameItemButtonTemplate' or template=='BankItemButtonGenericTemplate' then
  f.kind=kind
  f.icon=CreateFrame('Texture',name..'IconTexture',f)
  f.Count=CreateFrame('FontString',name..'Count',f)
  _G[name..'Cooldown']=CreateFrame('Cooldown')
  f.nativeScripts=true
  f.scripts.OnClick=function(button,key)
   if template=='BankItemButtonGenericTemplate' then
    C_Container.PickupContainerItem(button:GetParent():GetID(),button:GetID()); return
   end
   if IsModifiedClick() then ContainerFrameItemButton_OnModifiedClick(button,key)
   else ContainerFrameItemButton_OnClick(button,key) end
  end
  f.scripts.OnDragStart=function(button) ContainerFrameItemButton_OnDrag(button) end
  f.scripts.OnReceiveDrag=function(button) ContainerFrameItemButton_OnDrag(button) end
 end
 return f
end
UIParent=CreateFrame('Frame'); UISpecialFrames={}; SlashCmdList={}; ITEM_QUALITY_COLORS={}
GameTooltip=CreateFrame('Frame'); ShoppingTooltip1=CreateFrame('Frame'); ShoppingTooltip2=CreateFrame('Frame')
GetLocale=function() return 'deDE' end
C_Timer={After=function(_,fn) queue[#queue+1]=fn end}
local function drain() local n=0; while #queue>0 do local fn=table.remove(queue,1); fn(); n=n+1; assert(n<10000) end end
local combat,cursor=false,nil
InCombatLockdown=function() return combat end
GetCursorInfo=function() return cursor and 'item',cursor and cursor.itemID end
IsModifiedClick=function() return false end
GetMoney=function() return 100 end
GetCoinTextureString=tostring
ResetCursor=noop
ShowInspectCursor=noop
-- Reproduce the Forever report: the old global hover helper is absent.
MouseIsOver=nil
SetItemButtonTexture=function(b,texture) assert(b.icon); b.icon:SetTexture(texture) end
SetItemButtonCount=function(b,count) assert(b.Count); b.Count:SetText(count>1 and tostring(count) or ''); b.Count:SetShown(count>1) end
SetItemButtonDesaturated=function(b,value) assert(b.icon); b.icon:SetDesaturated(value) end
CooldownFrame_Set=noop
hooksecurefunc=noop
local loaded={Baganator=true}
C_AddOns={IsAddOnLoaded=function(name) return loaded[name] end}
local originalToggles=0
ToggleBackpack=function() originalToggles=originalToggles+1 end
ToggleBag=ToggleBackpack
PatchTools={isClassicEra=true,hasProfessionBag=false,db={autoSell=true,sellWhitelist=true,sellBlocklist={},sellAllowlist={}}}
function PatchTools:RegisterOptionsPage(id,title,fn) assert(id=='bags'); self.builder=fn end
local inventory={
 [0]={{itemID=3,hyperlink='item:3',stackCount=3,quality=0},nil,{itemID=1,hyperlink='item:1',stackCount=12,quality=2}},
 [1]={{itemID=1,hyperlink='item:1',stackCount=13,quality=2}},
 [2]={{itemID=9,hyperlink='item:9',stackCount=4,quality=2}}, [3]={}, [4]={}}
local capacities={[0]=4,[1]=2,[2]=2,[3]=0,[4]=0}
local mutations=0
C_Container={
 GetContainerNumSlots=function(b) assert(b<=4); return capacities[b] end,
 GetContainerNumFreeSlots=function(b) return 0,b==2 and 2 or 0 end,
 GetContainerItemInfo=function(b,s) return inventory[b][s] end,
 GetContainerItemQuestInfo=function() return {} end,
 GetContainerItemCooldown=function() return 0,0,0 end,
 PickupContainerItem=function(b,s)
  mutations=mutations+1
  local item=inventory[b][s]
  if cursor and item and cursor.hyperlink==item.hyperlink then
   local amount=math.min(cursor.stackCount,20-item.stackCount)
   item.stackCount=item.stackCount+amount; cursor.stackCount=cursor.stackCount-amount
   if cursor.stackCount==0 then cursor=nil end
  else inventory[b][s],cursor=cursor,item end
 end}
C_Item={GetItemInfo=function(link) local id=tonumber(link:match('%d+')); return 'Item '..id,link,2,1,1,'Type','Subtype',20,'',1,1,id%4,0 end}
assert(loadfile('Core.lua'))('PatchToolsBags',Bags)
assert(loadfile('Pawn.lua'))('PatchToolsBags',Bags)
assert(loadfile('Window.lua'))('PatchToolsBags',Bags)
assert(loadfile('Bank.lua'))('PatchToolsBags',Bags)
assert(loadfile('Options.lua'))('PatchToolsBags',Bags)
local eventFrame=frames[#frames]
-- Locate the event frame, since files loaded after it need not create frames.
for _,f in ipairs(frames) do if f.events.PLAYER_LOGIN then eventFrame=f end end
PatchToolsBagsDB={scale=.85,columns=12,x=100,y=700,backgroundTransparency=.3}
eventFrame.scripts.OnEvent(eventFrame,'PLAYER_LOGIN')
assert(Bags.windowDB==PatchToolsBagsCharacterDB and Bags.windowDB.scale==.85
    and Bags.windowDB.columns==12 and Bags.windowDB.x==100 and Bags.windowDB.y==700)
assert(PatchTools.builder)
local debugCalls=0
PatchTools.OpenDebugReport=function() debugCalls=debugCalls+1 end
SlashCmdList.PATCHTOOLSBAGS(' debug '); assert(debugCalls==1)
PatchTools.OpenDebugReport=nil; SlashCmdList.PATCHTOOLSBAGS('debug')

PatchTools.builder(CreateFrame('Frame'))
ToggleBackpack(); assert(originalToggles==1,'Other bag addon must retain access')
SlashCmdList.PATCHTOOLSBAGS(''); assert(Bags.window:IsShown())
drain()
assert(mutations==0,'Opening the sorted display must not move any items')
assert(Bags.buttons['0:1'].mark.texture=='Interface\\MoneyFrame\\UI-GoldIcon')
assert(Bags.buttons['0:1'].mark.desaturated==true,'Junk coin must be grey')
assert(Bags.buttons['0:1'].edge.texture=='Interface\\Common\\WhiteIconFrame','Item outline must use native rounded artwork')
assert(#Bags.buttons['0:1'].markShadows==8)
for _,shadow in ipairs(Bags.buttons['0:1'].markShadows) do
 assert(shadow.texture==Bags.buttons['0:1'].mark.texture and shadow.vertex[1]==0 and shadow:IsShown(),'Outline must follow the marker silhouette')
end
assert(not Bags.buttons['0:2'].markShadows[1]:IsShown(),'Empty slots must not retain marker outlines')

assert(Bags.buttons['0:1'].mark.point[3]==-6 and Bags.buttons['0:1'].mark.point[2]==4,'Marker must be inset from the border')
local savedQuest=C_Container.GetContainerItemQuestInfo
C_Container.GetContainerItemQuestInfo=function(bag,slot) return {isQuestItem=bag==0 and slot==3} end
Bags:RefreshWindow()
local questBorder=Bags.buttons['0:3'].edge.vertex
assert(questBorder[1]==1 and questBorder[2]==0.78 and questBorder[3]==0.08,'Quest border must be gold')
assert(Bags.buttons['0:3'].mark.desaturated==false,'Grey state must not leak to quest icons')
C_Container.GetContainerItemQuestInfo=savedQuest
Bags:RefreshWindow()

local first=Bags.buttons['0:1']
assert(first.point[4]==26 and first.point[5]==-58,'Opening must retain real slot order before an explicit sort')
assert(Bags.sectionBadges[2].title:find('Specialty') or Bags.sectionBadges[2].title:find('Spezial'),'Specialty bags need a separate visible section')
assert(Bags.sectionBadges[1].count.text==3,'Combined badge must count free slots')
assert(#Bags.sectionBadges[1].bagLines==2,'Combined tooltip must list every included bag')
assert(#Bags.sectionBadges[2].bagLines==1,'Specialty tooltip must remain separate')
local clicked
ContainerFrameItemButton_OnClick=function(button,key) clicked={button:GetParent():GetID(),button:GetID(),key} end
first.scripts.OnClick(first,'RightButton')
assert(clicked[1]==0 and clicked[2]==1 and clicked[3]=='RightButton','Visual buttons must act on real slot')
loaded.Baganator=false
ToggleBackpack(); assert(not Bags.window:IsShown())
ToggleBackpack(); assert(Bags.window:IsShown())
ToggleBag(5); assert(originalToggles==2,'Bank access must retain native behavior')
combat=true; Bags:Sort(); assert(mutations==0,'Combat sorting must never touch inventory')
assert(not Bags.sorting,'Combat sorting must not start a merging job')
assert(Bags.buttons['0:3'].point[4]==26 and Bags.buttons['0:3'].point[5]==-58,'Combat sorting must reorder the display')
assert(inventory[0][3].stackCount==12 and inventory[1][1].stackCount==13,'Combat sorting must leave partial stacks untouched')
combat=false; cursor={itemID=99}; Bags:Sort(); assert(mutations==0); cursor=nil
Bags:Sort(); drain()
assert(not Bags.sorting and not cursor)
assert(inventory[0][1].itemID==3 and inventory[0][1].stackCount==3,'Non-stack items must retain real coordinates')
assert(inventory[0][3].itemID==1 and inventory[0][3].stackCount==20)
assert(inventory[1][1].itemID==1 and inventory[1][1].stackCount==5)
assert(inventory[2][1].itemID==9,'Specialty bag must retain its family')
assert(Bags.buttons['0:3'].point[4]==26 and Bags.buttons['0:3'].point[5]==-58,'Sort click must order the normal-bag section')
assert(Bags.buttons['2:1'].point[5]<Bags.buttons['0:3'].point[5],'Specialty slots must be below normal bags')

local previous=mutations; Bags:Sort(); drain(); assert(mutations==previous,'Already sorted inventory should do no work')
C_Item.GetItemFamily=function(link) return link=='item:3' and 2 or 0 end
combat=true; Bags:Sort(); drain()
assert(mutations==previous,'Combat must also skip specialty transfers')
combat=false; Bags.db.sortSpecialtyBags=false; Bags:Sort(); drain()
assert(mutations==previous,'Disabling specialty routing must preserve real placement')
Bags.db.sortSpecialtyBags=true; Bags:Sort(); drain()
assert(not inventory[0][1] and inventory[2][2].itemID==3,'Matching goods must move into an empty specialty slot')
assert(not cursor and not Bags.sorting,'An empty-slot transfer must finish and confirm cleanly')
C_Container.PickupContainerItem(2,2); C_Container.PickupContainerItem(0,1)
C_Item.GetItemFamily=nil; Bags:RefreshWindow()
local source,target=Bags.buttons['0:3'],Bags.buttons['0:2']
local sourceX,sourceY=source.point[4],source.point[5]
local targetX,targetY=target.point[4],target.point[5]
ContainerFrameItemButton_OnDrag=function(button) C_Container.PickupContainerItem(button:GetParent():GetID(),button:GetID()) end
ContainerFrameItemButton_OnClick=function(button) C_Container.PickupContainerItem(button:GetParent():GetID(),button:GetID()) end
source:GetHighlightTexture():Show(); source.highlightLocked=true; source.hover:Show()
local sourceHides=source.hideCount or 0
source.scripts.OnDragStart(source)
assert(not source:GetHighlightTexture():IsShown() and not source.hover:IsShown() and not source.highlightLocked,'Drag start must clear the source highlight without hiding the button')
eventFrame.scripts.OnEvent(eventFrame,'ITEM_LOCK_CHANGED')
drain()
assert(source:IsShown() and (source.hideCount or 0)==sourceHides,'Inventory refresh must not hide the active drag source')
assert(source:GetNormalTexture().alpha==0 and source:GetPushedTexture().alpha==0 and source:GetHighlightTexture().alpha==0,'Native decorations must remain invisible after drag refresh')
assert(not source.hover:IsShown(),'Custom hover must not remain on the old slot')
target.scripts.OnReceiveDrag(target)
assert(not cursor and not inventory[0][3] and inventory[0][2].itemID==1,'Drag/drop must move the selected item')
Bags:RefreshWindow()
assert(source.point[4]==sourceX and source.point[5]==sourceY,'Vacated slot must not be reordered automatically')
assert(target.point[4]==targetX and target.point[5]==targetY,'Drop destination must retain its visual position')
Bags.layout=nil; Bags:RefreshWindow()
assert(target.point[4]==targetX and target.point[5]==targetY,'Layout must survive reconstruction from saved settings')

SlashCmdList.PATCHTOOLSBAGS('reset'); drain()
assert(Bags.windowDB.scale==1 and Bags.windowDB.columns==10)
-- Comparison groups fit as a whole, even when neither side has enough space.
function methods:SetPoint(...) self.point={...} end
function methods:SetOwner(owner,anchor) self.owner=owner; self.anchor=anchor end
function GameTooltip:GetWidth() return 500 end
function GameTooltip:GetHeight() return 350 end
function ShoppingTooltip1:GetWidth() return 320 end
function ShoppingTooltip2:GetWidth() return 420 end
GameTooltip_ShowCompareItem=function(tip)
 assert(tip.anchor=='ANCHOR_PRESERVE')
 ShoppingTooltip1:Show(); ShoppingTooltip2:Show()
end
IsModifiedClick=function() return true end
for _,x in ipairs({10,700,1700}) do
 local button=Bags.buttons['0:1']
 button.GetLeft=function() return x end
 Bags:Tooltip(button)
 assert(GameTooltip.point[4]>=8)
 assert(ShoppingTooltip2.point[4]+420<=1920-8)
end
print('PASS: module registration, settings/window creation, bag takeover, safe live sorting, no-op sort, reset.')


local savedInfo=C_Item.GetItemInfo
ContainerIDToInventoryID=nil
C_Container.ContainerIDToInventoryID=function(bag) return bag+19 end
GetInventoryItemLink=function(_,slot) return tostring(slot) end
C_Item.GetItemInfo=function(link)
 local subclass=link=='20' and 2 or 3
 return 'Bag',link,1,1,1,'Quiver','',1,'',1,1,11,subclass
end
assert(Bags:SectionIcon({key='general'}):find('INV_Misc_Bag_08',1,true))
assert(Bags:SectionIcon({key='bag1',bag=1}):find('INV_Misc_Quiver_10',1,true))
assert(Bags:SectionIcon({key='bag2',bag=2}):find('INV_Misc_Ammo_Bullet_01',1,true))
C_Item.GetItemInfo=savedInfo

local cursorMode,soldBag,soldSlot
ResetCursor=function() cursorMode='default' end
ShowInspectCursor=function() cursorMode='inspect' end
C_Container.ShowContainerSellCursor=function(bag,slot) cursorMode='sell'; soldBag=bag; soldSlot=slot end
MerchantFrame=CreateFrame('Frame'); MerchantFrame.selectedTab=1; MerchantFrame:Show()
IsModifiedClick=function() return false end
local itemButton=Bags.buttons['0:1']
Bags:UpdateItemCursor(itemButton)
assert(cursorMode=='sell' and soldBag==0 and soldSlot==1,'Merchant cursor must use the actual bag/slot')
MerchantFrame.selectedTab=2
Bags:UpdateItemCursor(itemButton); assert(cursorMode=='default','Buyback tab must not show a sale cursor')
MerchantFrame.selectedTab=1
SpellIsTargeting=function() return true end
cursorMode='spell'; Bags:UpdateItemCursor(itemButton); assert(cursorMode=='spell','Pet feeding and item-target spells must retain their cursor')
SpellIsTargeting=function() return false end
InRepairMode=function() return true end
cursorMode='repair'; Bags:UpdateItemCursor(itemButton); assert(cursorMode=='repair')
InRepairMode=function() return false end
MerchantFrame:Hide()
Bags:UpdateItemCursor(itemButton); assert(cursorMode=='default','Closing the merchant must clear the sale cursor')
IsModifiedClick=function(kind) return kind=='DRESSUP' end
Bags:UpdateItemCursor(itemButton); assert(cursorMode=='inspect')
IsModifiedClick=function() return false end
print('PASS: sale, buyback, merchant close, repair, inspect and pet-feed cursor modes.')

PawnPlayerFullName='Test'; PawnCommon={ShowBagUpgradeAdvisor=true}
PawnShouldItemLinkHaveUpgradeArrow=function() return true end
itemButton.Count=CreateFrame('FontString')
Bags:RefreshWindow()
assert(itemButton.pawnUpgrade:IsShown(),'Pawn upgrades need a visible arrow')
assert(itemButton.pawnUpgrade.point[1]=='BOTTOMRIGHT')
assert(itemButton.Count.point[1]=='BOTTOMLEFT','stack count must not overlap upgrade arrow')
PawnCommon.ShowBagUpgradeAdvisor=false
Bags:RefreshWindow(); assert(itemButton.pawnUpgrade:IsShown(),'native Pawn arrows can be disabled independently')
Bags.db.pawnUpgrades=false
Bags:RefreshWindow(); assert(not itemButton.pawnUpgrade:IsShown())
assert(itemButton.Count.point[1]=='BOTTOMRIGHT')
local opened,page
Bags.owner.OpenOptions=function() opened=true end
Bags.owner.SelectOptionsPage=function(_,id) page=id end
Bags.window.settings.scripts.OnClick(); assert(opened and page=='bags')
function methods:SetBackdropColor(...) self.background={...} end
Bags.db.backgroundTransparency=.6; Bags:ApplyBackgroundTransparency()
assert(math.abs(Bags.window.background[4]-.388)<.000001)
assert(Bags.window.alpha==nil,'transparency must affect background only')
Bags:RefreshWindow()
local emptyButton
for _,button in pairs(Bags.buttons) do
    local icon=button.icon or _G[button:GetName()..'IconTexture']
    if button.hasItem then
        if icon then assert(icon.vertex[4]==1,'occupied item icons stay opaque') end
        assert(button.edge.vertex[4]==1,'occupied item borders stay opaque')
    else
        emptyButton=button
        if icon then assert(math.abs(icon.vertex[4]-.4)<.000001,'empty fill follows background transparency') end
        assert(math.abs(button.edge.vertex[4]-.4)<.000001,'empty border follows background transparency')
    end
end
assert(emptyButton,'fixture includes empty slots')
Bags.db.backgroundTransparency=0; Bags:RefreshWindow()
assert(emptyButton.edge.vertex[4]==1,'restoring opacity restores empty slots too')
print('PASS: bottom-right Pawn arrow, nonoverlapping count, direct settings and background-only transparency.')

local account=PatchToolsBagsDB
local first=Bags.windowDB
first.scale=.7; first.columns=8; first.x=77
account.backgroundTransparency=.4
PatchToolsBagsCharacterDB=nil; eventFrame.scripts.OnEvent(eventFrame,'PLAYER_LOGIN')
assert(Bags.windowDB~=first and Bags.windowDB.scale==.85 and Bags.windowDB.columns==12)
Bags.windowDB.scale=1.2; Bags.windowDB.columns=16
PatchToolsBagsCharacterDB=first; eventFrame.scripts.OnEvent(eventFrame,'PLAYER_LOGIN')
assert(Bags.windowDB.scale==.7 and Bags.windowDB.columns==8 and Bags.windowDB.x==77)
SlashCmdList.PATCHTOOLSBAGS('reset'); eventFrame.scripts.OnEvent(eventFrame,'PLAYER_LOGIN')
assert(Bags.windowDB.scale==1 and Bags.windowDB.columns==10 and Bags.windowDB.x==nil)
assert(Bags.db==account and account.scale==.85 and account.columns==12 and account.backgroundTransparency==.4)
print('PASS: bag character migration, separate position/scale/columns, reset and global transparency.')

-- Classic bank bags start at NUM_BAG_SLOTS + 1, even when the shared retail
-- enums claim 6. Forever must use purchased bank tabs and keep reagent bag 5.
local carriedIDs=Bags:BagIDs()
Enum={BagIndex={ReagentBag=5,BankBag_1=6},BankType={Character=0}}
NUM_BAG_SLOTS=4; NUM_BANKBAGSLOTS=6; BANK_CONTAINER=-1
local ids=Bags:BankBagIDs()
assert(#ids==7 and ids[1]==-1 and ids[2]==5 and ids[7]==10)
inventory[-1]={{itemID=1,hyperlink='item:1',stackCount=12,quality=2}}
inventory[5]={{itemID=1,hyperlink='item:1',stackCount=13,quality=2}}
capacities[-1]=4; capacities[5]=2
C_Container.GetContainerNumSlots=function(id) return capacities[id] or 0 end
C_Container.GetContainerItemInfo=function(id,slot) return inventory[id] and inventory[id][slot] end
BankFrame=CreateFrame('Frame'); BankFrame:SetAlpha(.7)
BankSlotsFrame=CreateFrame('Frame',nil,BankFrame)
local bankBagClicks,bankBagDrops,purchases=0,0,0
local bankSlotsFull=false
GetNumBankSlots=function() return 2,bankSlotsFull end
GetBankSlotCost=function(count) assert(count==2); return 10000 end
for index=1,6 do
 local button=CreateFrame('Button',nil,BankSlotsFrame); BankSlotsFrame['Bag'..index]=button
 button:SetID(index); button:SetPoint('TOPLEFT',BankSlotsFrame,'TOPLEFT',index*40,0)
 button:SetScript('OnClick',function() bankBagClicks=bankBagClicks+1 end)
 button:SetScript('OnReceiveDrag',function() bankBagDrops=bankBagDrops+1 end)
 button.nativeScripts=true
end
BankFramePurchaseButton=CreateFrame('Button',nil,BankSlotsFrame)
BankFramePurchaseButton:SetScript('OnClick',function() purchases=purchases+1 end)
BankFramePurchaseButton.nativeScripts=true
local nativeChild=CreateFrame('Button',nil,BankFrame); nativeChild:EnableMouse(false)
local nativeActive=CreateFrame('Button',nil,BankFrame); nativeActive:EnableMouse(true)
local closedNative={}
CloseBag=function(id) closedNative[#closedNative+1]=id end
local closes=0
CloseBankFrame=function() closes=closes+1; Bags:HandleBankEvent('BANKFRAME_CLOSED') end
local originalBagWindow=Bags.window
Bags:HandleBankEvent('BANKFRAME_OPENED'); drain()
local bank=Bags.bankView
assert(bank and bank~=Bags and bank.window~=originalBagWindow and bank.window:IsShown())
assert(bank.buttons['-1:1'] and bank.buttons['5:1'] and not bank.buttons['0:1'])
local tooltipLocation
BankButtonIDToInvSlotID=function(slot,isBag) assert(not isBag); return 39+slot end
function GameTooltip:SetInventoryItem(unit,slot) tooltipLocation={'inventory',unit,slot} end
function GameTooltip:SetBagItem(bag,slot) assert(bag~=-1,'base bank requires the inventory tooltip API'); tooltipLocation={'bag',bag,slot} end
bank:Tooltip(bank.buttons['-1:1'])
assert(tooltipLocation[1]=='inventory' and tooltipLocation[2]=='player' and tooltipLocation[3]==40)
bank:Tooltip(bank.buttons['5:1'])
assert(tooltipLocation[1]=='bag' and tooltipLocation[2]==5 and tooltipLocation[3]==1)
assert(bank.windowDB~=Bags.windowDB and bank.layout~=Bags.layout)
assert(bank:BankSlotRowHeight()==0,'bank bag controls start collapsed')
assert(bank.window.bankBags:GetParent()==bank.window.header,'header button is above the draggable header')
bank.window.bankBags.scripts.OnClick()
assert(bank:BankSlotRowHeight()==42 and BankSlotsFrame.Bag1:GetParent()==bank.window)
assert(BankSlotsFrame.Bag6:GetID()==6 and BankSlotsFrame.Bag6:IsMouseEnabled(),'locked bank slots remain reachable')
BankSlotsFrame.Bag1.scripts.OnClick(); BankSlotsFrame.Bag2.scripts.OnReceiveDrag()
BankFramePurchaseButton.scripts.OnClick()
assert(bankBagClicks==1 and bankBagDrops==1 and purchases==1,'keep native bag and purchase handlers')
local confirmations=0
StaticPopup_Show=function(key) assert(key=='CONFIRM_BUY_BANK_SLOT'); confirmations=confirmations+1 end
assert(not bank.bankSlotPurchaseOverlays[1]:IsShown() and bank.bankSlotPurchaseOverlays[3]:IsShown())
bank.bankSlotPurchaseOverlays[3].scripts.OnClick()
assert(confirmations==1 and BankFrame.nextSlotCost==10000 and purchases==1,'locked slot opens confirmation without buying')
cursor={itemID=999}; local beforeDrop=mutations
bank.bankSlotPurchaseOverlays[4].scripts.OnReceiveDrag()
assert(confirmations==2 and cursor.itemID==999 and mutations==beforeDrop,'locked slot drop preserves cursor and inventory')
cursor=nil
combat=true; bank.bankSlotPurchaseOverlays[3].scripts.OnClick(); combat=false
assert(confirmations==2,'no purchase prompt during combat')
bank.window.bankBags.scripts.OnClick()
assert(bank:BankSlotRowHeight()==0 and not BankSlotsFrame.Bag1:IsShown() and not bank.bankSlotPurchaseOverlays[3]:IsShown())
bank.window.bankBags.scripts.OnClick()
assert(BankFramePurchaseButton:GetParent()==bank.window and BankFramePurchaseButton:IsShown())
bankSlotsFull=true; bank:RefreshWindow(); assert(not BankFramePurchaseButton:IsShown())
bankSlotsFull=false; bank:RefreshWindow(); assert(BankFramePurchaseButton:IsShown())
assert(BankFrame:GetAlpha()==0 and not BankFrame:IsMouseEnabled() and not nativeActive:IsMouseEnabled())
assert(#closedNative==6 and closedNative[1]==5,'native bank bags suppressed without closing carried bags')
local carriedSignature=Bags:Signature(inventory[0][1])
bank:Sort(); drain()
assert(inventory[-1][1].stackCount==20 and inventory[5][1].stackCount==5)
assert(Bags:Signature(inventory[0][1])==carriedSignature,'bank consolidation never touches carried items')
bank.buttons['-1:1'].scripts.OnClick(bank.buttons['-1:1'],'LeftButton')
assert(cursor and cursor.itemID==1,'bank main slot keeps native click handling')
C_Container.PickupContainerItem(-1,1); assert(not cursor)
Bags.windowDB.x=88; bank.windowDB.x=22; bank.windowDB.scale=.75
Bags:HandleBankEvent('BANKFRAME_CLOSED'); drain()
assert(not bank.window:IsShown() and BankFrame:GetAlpha()==.7)
assert(BankSlotsFrame.Bag1:GetParent()==BankSlotsFrame and BankSlotsFrame.Bag1:GetScale()==1)
assert(BankFramePurchaseButton:GetParent()==BankSlotsFrame,'restore native controls when the visit ends')
assert(BankFrame:IsMouseEnabled() and not nativeChild:IsMouseEnabled() and nativeActive:IsMouseEnabled())
local beforeClosed=mutations; bank:Sort(); drain(); assert(mutations==beforeClosed)
Bags:HandleBankEvent('BANKFRAME_OPENED'); drain()
assert(bank.windowDB.x==22 and Bags.windowDB.x==88,'separate bank layout survives reopening')
Bags:OpenNativeBank()
assert(Bags.bankManagement and not bank.window:IsShown() and BankFrame:GetAlpha()==.7)
assert(BankSlotsFrame.Bag1:GetParent()==BankSlotsFrame,'native setup gets its bag buttons back')
SlashCmdList.PATCHTOOLSBAGS('bank')
assert(not Bags.bankManagement and bank.window:IsShown() and BankFrame:GetAlpha()==0,'return from native bank setup')
inventory[-1][1].stackCount=11; inventory[5][1].stackCount=12
bank:Sort(); local afterStart=mutations
Bags:HandleBankEvent('BANKFRAME_CLOSED'); drain()
assert(mutations==afterStart and not bank.sorting,'bank closure cancels delayed consolidation')

Bags.owner.isForever=true; Bags.owner.hasProfessionBag=true
local tabs={6,8,10}
C_Bank={CanViewBank=function(kind) assert(kind==0); return true end,
 FetchPurchasedBankTabIDs=function(kind) assert(kind==0); return tabs end}
assert(Bags:BagIDs()[6]==5,'profession bag remains carried')
ids=Bags:BankBagIDs(); assert(#ids==3 and ids[1]==6 and ids[2]==8 and ids[3]==10)
tabs={5,6}; assert(Bags:BankBagIDs()==nil,'reject a bank response that aliases the carried profession bag')
tabs={6,8,10}; inventory[6]={{itemID=9,hyperlink='item:9',stackCount=1,quality=2}}; capacities[6]=2
Bags:HandleBankEvent('BANKFRAME_OPENED'); drain()
assert(bank.buttons['6:1']:IsShown() and not bank.buttons['5:1']:IsShown() and not bank.buttons['-1:1']:IsShown())
assert(#Bags:Scan()==10,'carried inventory scan includes the profession bag and excludes bank tabs')
Bags.db.replaceBank=false; Bags:UpdateBankReplacement()
assert(not bank.window:IsShown() and BankFrame:GetAlpha()==.7,'bank replacement can be disabled live')
Bags.db.replaceBank=true; Bags:UpdateBankReplacement(); assert(bank.window:IsShown())
Bags:HandleBankEvent('BANKFRAME_CLOSED'); drain()
C_Bank=nil; Bags:HandleBankEvent('BANKFRAME_OPENED'); drain()
assert(not bank.window:IsShown() and BankFrame:GetAlpha()==.7,'unavailable Forever API keeps the native bank')
Bags:HandleBankEvent('BANKFRAME_CLOSED')
print('PASS: Era bank index mismatch, native handlers, separate bank sorting/layout, lifecycle cancellation, restoration and Forever tab/profession isolation.')

-- Opening uses the same sort operation, once per opening, and never merges in combat.
Bags.owner.isForever=false; Bags.owner.hasProfessionBag=false
drain(); Bags.window:Hide()
assert(Bags.db.autoSortOnOpen==false,'automatic sorting defaults off')
local originalSort=Bags.Sort
local sortCalls=0
Bags.Sort=function(self) sortCalls=sortCalls+1; return originalSort(self) end
Bags.window:Show(); drain(); assert(sortCalls==0)
Bags.window:Hide(); Bags.db.autoSortOnOpen=true
Bags.window:Show(); Bags.window:Hide(); drain()
assert(sortCalls==0,'closing before the opening callback cancels automatic sorting')
inventory[0]={{itemID=1,hyperlink='item:1',stackCount=7,quality=2}}
inventory[1]={{itemID=1,hyperlink='item:1',stackCount=8,quality=2}}
local beforeAuto=mutations
combat=true; Bags.window:Show(); drain()
assert(sortCalls==1 and mutations==beforeAuto,'automatic combat sorting only changes the display')
Bags.window:Show(); Bags:RefreshWindow(); drain()
assert(sortCalls==1,'refreshing or showing an already open window does not sort again')
combat=false; Bags.window:Hide(); Bags.window:Show(); drain()
assert(sortCalls==2 and mutations>beforeAuto,'outside combat opening also merges partial stacks')
assert((inventory[0][1] and inventory[0][1].stackCount or 0)+(inventory[1][1] and inventory[1][1].stackCount or 0)==15)
Bags.window:Hide(); cursor={itemID=123}; Bags.window:Show(); drain()
assert(sortCalls==2 and cursor.itemID==123,'opening with an item on the cursor skips sorting')
cursor=nil; Bags.db.autoSortOnOpen=false; Bags.Sort=originalSort
print('PASS: optional opening sort, default off, once per opening, cancellation, combat display only and safe stack merging.')

-- Reopen a carried inventory with Forever's intrinsic ItemButton contract and
-- no legacy hover global. Both filled and empty profession-bag slots render.
Bags.window:Hide(); Bags.window=nil
Bags.owner.isForever=true; Bags.owner.hasProfessionBag=true
inventory[5]={{itemID=9,hyperlink='item:9',stackCount=4,quality=2,iconFileID=12345,isLocked=true}}
capacities[5]=2
C_CurrencyInfo={GetCoinTextureString=function(amount) return 'coins:'..tostring(amount) end}
GetCoinTextureString=nil; GetMoney=function() return 42 end
SlashCmdList.PATCHTOOLSBAGS(''); drain()
assert(Bags.window:IsShown() and Bags.buttons['0:1'].kind=='ItemButton')
assert(Bags.window.money:GetText()=='coins:42','Forever currency namespace works without the old global')
assert(Bags:FormatMoney(10000)=='coins:10000','bank prices use the same currency adapter')
local profession=Bags.buttons['5:1']
assert(profession.icon.texture==12345 and profession.Count:GetText()=='4' and profession.Count:IsShown())
assert(profession.icon.desaturated==true and not Bags.buttons['5:2'].Count:IsShown())
assert(Bags.buttons['5:2'].icon.texture=='Interface\\Buttons\\WHITE8X8')
profession.mouseOver=true; profession.scripts.OnEnter(profession)
assert(profession.hover:IsShown()); Bags:RefreshWindow(); assert(profession.hover:IsShown(),'keep hover while the mouse remains over the item')
profession.mouseOver=false; Bags:RefreshWindow(); assert(not profession.hover:IsShown(),'clear hover when it leaves the item')
local mouseMethod=methods.IsMouseOver
methods.IsMouseOver=nil; MouseIsOver=function(button) return button.mouseOver end
profession.mouseOver=true; profession.scripts.OnEnter(profession); Bags:RefreshWindow()
assert(profession.hover:IsShown(),'legacy hover API fallback')
profession.mouseOver=false; Bags:RefreshWindow(); assert(not profession.hover:IsShown())
methods.IsMouseOver=mouseMethod; MouseIsOver=nil
profession.scripts.OnDragStart(profession)
assert(cursor and cursor.itemID==9,'Forever native drag still picks up the real profession-bag item')
C_Container.PickupContainerItem(5,1); assert(not cursor)
print('PASS: Forever intrinsic item buttons, missing MouseIsOver global, icon/count/lock rendering, profession bags, hover cleanup and native dragging.')
C_CurrencyInfo=nil; GetCoinTextureString=function(amount) return 'legacy:'..tostring(amount) end
assert(Bags:FormatMoney(42)=='legacy:42','Era legacy currency formatter remains supported')
GetCoinTextureString=nil
assert(Bags:FormatMoney(42)=='42 Kupfer','plain currency fallback if neither API is available')
print('PASS: money display with modern currency namespace, legacy API and missing-API fallback.')

-- Forever's bank grants the first tab after OpenAllBags returns. Global bag
-- functions must remain native, including their nested OpenBackpack calls.
local secureHooks={}
hooksecurefunc=function(name,callback)
 assert(type(name)=='string' and type(_G[name])=='function')
 secureHooks[name]=callback
end
local inAddonHook=false
local function NativeCall(name,...)
 local result=_G[name](...)
 if secureHooks[name] then
  inAddonHook=true; secureHooks[name](...); inAddonHook=false
 end
 return result
end
local heldFrame=CreateFrame('Frame'); heldFrame:SetID(0); heldFrame:Hide()
local professionFrame=CreateFrame('Frame'); professionFrame:SetID(5)
local bankContainer=CreateFrame('Frame'); bankContainer:SetID(6); bankContainer:Show()
ContainerFrameUtil_EnumerateContainerFrames=function() return ipairs({heldFrame,professionFrame,bankContainer}) end
ToggleBackpack=function() heldFrame:SetShown(not heldFrame:IsShown()) end
OpenBackpack=function() if not heldFrame:IsShown() then NativeCall('ToggleBackpack') end end
OpenAllBags=function() NativeCall('OpenBackpack'); professionFrame:Show() end
CloseBackpack=function() heldFrame:Hide() end
CloseAllBags=function() NativeCall('CloseBackpack'); professionFrame:Hide() end
ToggleAllBags=function() NativeCall('OpenAllBags') end
ToggleBag=function(id) if id==0 then NativeCall('ToggleBackpack') end end
local nativeOpen,nativeBackpack=OpenAllBags,OpenBackpack
Bags:InstallBagAccess()
assert(OpenAllBags==nativeOpen and OpenBackpack==nativeBackpack,'do not replace secure native bag functions')
local grantedTabs={}
local grants=0
C_Bank={CanViewBank=function() return true end,FetchPurchasedBankTabIDs=function() return grantedTabs end,
 PurchaseBankTab=function()
  assert(not inAddonHook,'first tab purchase must remain in native bank execution')
  grants=grants+1; grantedTabs={6}
 end}
Bags.bankOpen=true; Bags.bankManagement=nil
Bags:UpdateBankReplacement()
assert(Bags.bankManagement and not bank.window:IsShown() and BankFrame:GetAlpha()==.7,
 'bank with no tabs keeps native setup visible instead of a 0/0 replacement')
-- The bank's native OnShow sequence continues before our deferred presentation.
NativeCall('OpenAllBags',BankFrame)
assert(Bags.bagAccessPending and grants==0)
assert(heldFrame:IsShown() and heldFrame:GetAlpha()==0 and professionFrame:GetAlpha()==0,
 'native bags are visually masked before the deferred takeover, without changing secure opening visibility')
assert(bankContainer:GetAlpha()==1,'carried-bag masking excludes the bank')
C_Bank.PurchaseBankTab(0)
Bags:HandleBankEvent('BANK_TABS_CHANGED'); drain()
assert(grants==1 and bank.window:IsShown() and Bags.window:IsShown())
assert(heldFrame:GetAlpha()==1 and professionFrame:GetAlpha()==1,'hidden native containers regain their original alpha')
assert(not heldFrame:IsShown() and not professionFrame:IsShown() and bankContainer:IsShown(),
 'hide carried presentation only after native initialization, preserve bank containers')
NativeCall('ToggleAllBags'); drain(); assert(not Bags.window:IsShown(),'nested native calls toggle custom window only once')
NativeCall('ToggleAllBags'); drain(); assert(Bags.window:IsShown())
NativeCall('OpenAllBags'); assert(heldFrame:GetAlpha()==0)
Bags.db.replaceBags=false; Bags:MaskNativeCarriedBags(false)
assert(heldFrame:GetAlpha()==1,'disabling replacement restores native appearance immediately')
drain(); Bags.db.replaceBags=true
Bags:HandleBankEvent('BANKFRAME_CLOSED'); drain()
print('PASS: secure Forever bag hooks, nested opening, free first-bank-tab setup and deferred presentation.')

-- Expansion slots mirror native bank controls through secure hardware clicks.
Bags.bankOpen=true; Bags.bankManagement=nil; bank.bankSlotsExpanded=true
BankFrame.BankPanel=CreateFrame('Frame',nil,BankFrame)
function BankFrame.BankPanel:GetActiveBankType() return 0 end
local buy=CreateFrame('Button',nil,BankFrame.BankPanel)
BankFrame.BankPanel.PurchaseButton=buy
local buyConfirmations=0
buy:SetScript('OnClick',function(button)
 assert(button:GetParent():GetActiveBankType()==0)
 buyConfirmations=buyConfirmations+1
end)
local equipped=CreateFrame('Button',nil,BankFrame)
equipped.bankType=0; equipped.bagSlotID=2; equipped.icon=CreateFrame('Texture'); equipped.icon:SetTexture('native-bag')
local equippedClicks=0
equipped:SetScript('OnClick',function(button) assert(button:GetParent()==BankFrame); equippedClicks=equippedClicks+1 end)
BankFrame.itemButtonBagPool={EnumerateActive=function() return pairs({[equipped]=true}) end}
C_Bank.FetchMaxNumBankTabs=function() return 9 end
C_Bank.FetchNextPurchasableBankTabData=function() return {tabCost=1000} end
grantedTabs={6}
bank.bankSlotsExpanded=false
Bags:ShowBank(); drain()
assert(bank:BankSlotRowHeight()==0,'Forever expansion row starts collapsed')
bank.window.bankBags:Click()
assert(bank:BankSlotRowHeight()==60 and #bank.foreverBankSlots==8)
local locked=bank.foreverBankSlots[1]
assert(locked.point[4]==26,'Expansion slots align with the item grid')
assert(bank.window.bankSlotCost.point[1]=='BOTTOMLEFT'
 and bank.window.bankSlotCost.text:find('Nächster Bankplatz:',1,true),'Price must be labeled beside the slots')
assert(locked:IsShown() and locked.locked and locked:GetAttribute('clickbutton')==buy)
locked:Click(); assert(buyConfirmations==1 and grants==1,'locked slot requests native confirmation without purchase')
assert(buy:GetParent()==BankFrame.BankPanel,'purchase control retains native ownership')
capacities[7]=0; inventory[7]={}
grantedTabs={6,7}; Bags:HandleBankEvent('BANK_TABS_CHANGED'); drain()
assert(not locked.locked and locked:GetAttribute('clickbutton')==equipped)
locked:Click(); assert(equippedClicks==1,'purchased slot keeps native bag-slot operation')
bank.window.bankBags:Click(); assert(not locked:IsShown() and not bank.window.bankSlotCost:IsShown())
Bags:HandleBankEvent('BANKFRAME_CLOSED'); drain()
assert(not locked:IsShown())
print('PASS: Forever expansion row, native confirmation forwarding, equipped slots and visit cleanup.')

-- Forever's extra bag can report family zero; reagent eligibility is supplied
-- separately by the item API. Exercise scanning and the confirmed transfer.
inventory={[0]={{itemID=12,hyperlink='item:12',stackCount=6,quality=1},
 {itemID=13,hyperlink='item:13',stackCount=1,quality=1}},[1]={},[2]={},[3]={},[4]={},[5]={}}
capacities={[0]=2,[1]=0,[2]=0,[3]=0,[4]=0,[5]=2}
C_Container.GetContainerNumFreeSlots=function() return 0,0 end
C_Item.GetItemInfo=function(link)
 local id=tonumber(link:match('%d+'))
 return 'Item '..id,link,1,1,1,'Type','Subtype',20,'',1,1,7,0,0,0,nil,id==12
end
Bags.itemCache={}; Bags.layout=nil; Bags.db.autoSortOnOpen=false
Bags.window:Show(); Bags:Sort(); drain()
assert(not cursor and not Bags.sorting and not inventory[0][1])
assert(inventory[5][1].itemID==12 and inventory[5][1].stackCount==6)
assert(inventory[0][2].itemID==13,'Non-reagents must stay out of the profession bag')
assert(#Bags:Sections(Bags:Scan())==2,'Reagent bag retains its own section')
print('PASS: Forever reagent metadata, physical transfer confirmation and separate bag display.')
