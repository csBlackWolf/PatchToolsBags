Bags={}
assert(loadfile('Model.lua'))('PatchToolsBags',Bags)
unpack=table.unpack
local frames,queue={},{}
local methods={}
local function noop() end
function methods:SetNormalTexture(asset)
 assert(asset~=nil,'Classic requires a texture asset')
end
function methods:GetNormalTexture() return nil end
for name in ('SetTexture SetAtlas AddLine SetHighlightTexture SetPushedTexture SetJustifyH SetBackdrop SetBackdropColor SetBackdropBorderColor SetSize SetHeight SetWidth SetPoint ClearAllPoints SetFrameStrata SetMovable SetClampedToScreen EnableMouse RegisterForClicks RegisterForDrag SetAutoFocus SetMaxLetters ClearFocus SetTextColor SetAlpha SetAllPoints SetFont SetValueStep SetObeyStepOnDrag StartMoving StopMovingOrSizing SetOwner SetBagItem SetMinMaxValues'):gmatch('%S+') do methods[name]=noop end
function methods:SetPoint(...) self.point={...} end
function methods:SetScript(key,fn)
 if self.nativeScripts and (key=='OnClick' or key=='OnDragStart' or key=='OnReceiveDrag') then
  error('Native container click/drag scripts must not be replaced by addon code')
 end
 self.scripts[key]=fn
end
function methods:RegisterEvent(event) self.events[event]=true end
function methods:CreateFontString() return CreateFrame('FontString') end
function methods:CreateTexture() return CreateFrame('Texture') end
function methods:SetText(t) self.text=t end
function methods:GetText() return self.text or '' end
function methods:GetFont() return 'font',12,'' end
function methods:GetName() return self.name end
function methods:GetParent() return self.parent end
function methods:GetOwner() return self.owner end
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
function methods:Hide() self.shown=false; if self.scripts.OnHide then self.scripts.OnHide(self) end end
function methods:Show() self.shown=true; if self.scripts.OnShow then self.scripts.OnShow(self) end end
function methods:SetShown(value) if value then self:Show() else self:Hide() end end
function methods:IsShown() return self.shown end
function methods:Enable() self.enabled=true end
function methods:Disable() self.enabled=false end
function CreateFrame(kind,name,parent,template)
 assert(kind~='ItemButton','Classic template uses Button')
 local f=setmetatable({scripts={},events={},name=name,parent=parent,shown=true}, {__index=methods})
 frames[#frames+1]=f
 if name then _G[name]=f end
 if template=='OptionsSliderTemplate' then _G[name..'Low']=CreateFrame('FontString'); _G[name..'High']=CreateFrame('FontString') end
 if template=='ContainerFrameItemButtonTemplate' then
  _G[name..'Cooldown']=CreateFrame('Cooldown')
  f.nativeScripts=true
  f.scripts.OnClick=function(button,key)
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
SetItemButtonTexture=noop; SetItemButtonCount=noop; SetItemButtonDesaturated=noop; CooldownFrame_Set=noop
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
assert(loadfile('Window.lua'))('PatchToolsBags',Bags)
assert(loadfile('Options.lua'))('PatchToolsBags',Bags)
local eventFrame=frames[#frames]
-- Locate the event frame, since files loaded after it need not create frames.
for _,f in ipairs(frames) do if f.events.PLAYER_LOGIN then eventFrame=f end end
eventFrame.scripts.OnEvent(eventFrame,'PLAYER_LOGIN')
assert(PatchTools.builder)
PatchTools.builder(CreateFrame('Frame'))
ToggleBackpack(); assert(originalToggles==1,'Other bag addon must retain access')
SlashCmdList.PATCHTOOLSBAGS(''); assert(Bags.window:IsShown())
drain()
assert(mutations==0,'Opening the sorted display must not move any items')
local first=Bags.buttons['0:1']
assert(first.point[4]==38 and first.point[5]==-58,'Opening must retain real slot order before an explicit sort')
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
combat=true; Bags:Sort(); assert(mutations==0)
combat=false; cursor={itemID=99}; Bags:Sort(); assert(mutations==0); cursor=nil
Bags:Sort(); drain()
assert(not Bags.sorting and not cursor)
assert(inventory[0][1].itemID==3 and inventory[0][1].stackCount==3,'Non-stack items must retain real coordinates')
assert(inventory[0][3].itemID==1 and inventory[0][3].stackCount==20)
assert(inventory[1][1].itemID==1 and inventory[1][1].stackCount==5)
assert(inventory[2][1].itemID==9,'Specialty bag must retain its family')
assert(Bags.buttons['0:3'].point[4]==38 and Bags.buttons['0:3'].point[5]==-58,'Sort click must order the normal-bag section')
assert(Bags.buttons['2:1'].point[5]<Bags.buttons['0:3'].point[5],'Specialty slots must be below normal bags')

local previous=mutations; Bags:Sort(); drain(); assert(mutations==previous,'Already sorted inventory should do no work')
local source,target=Bags.buttons['0:3'],Bags.buttons['0:2']
local sourceX,sourceY=source.point[4],source.point[5]
local targetX,targetY=target.point[4],target.point[5]
ContainerFrameItemButton_OnDrag=function(button) C_Container.PickupContainerItem(button:GetParent():GetID(),button:GetID()) end
ContainerFrameItemButton_OnClick=function(button) C_Container.PickupContainerItem(button:GetParent():GetID(),button:GetID()) end
source.scripts.OnDragStart(source)
target.scripts.OnReceiveDrag(target)
assert(not cursor and not inventory[0][3] and inventory[0][2].itemID==1,'Drag/drop must move the selected item')
Bags:RefreshWindow()
assert(source.point[4]==sourceX and source.point[5]==sourceY,'Vacated slot must not be reordered automatically')
assert(target.point[4]==targetX and target.point[5]==targetY,'Drop destination must retain its visual position')
Bags.layout=nil; Bags:RefreshWindow()
assert(target.point[4]==targetX and target.point[5]==targetY,'Layout must survive reconstruction from saved settings')

SlashCmdList.PATCHTOOLSBAGS('reset'); drain()
assert(Bags.db.scale==1 and Bags.db.columns==10)
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
ContainerIDToInventoryID=function(bag) return bag+19 end
GetInventoryItemLink=function(_,slot) return tostring(slot) end
C_Item.GetItemInfo=function(link)
 local subclass=link=='20' and 2 or 3
 return 'Bag',link,1,1,1,'Quiver','',1,'',1,1,11,subclass
end
assert(Bags:SectionIcon({key='general'}):find('INV_Misc_Bag_08',1,true))
assert(Bags:SectionIcon({key='bag1',bag=1}):find('INV_Misc_Quiver_10',1,true))
assert(Bags:SectionIcon({key='bag2',bag=2}):find('INV_Misc_Ammo_Bullet_01',1,true))
C_Item.GetItemInfo=savedInfo
