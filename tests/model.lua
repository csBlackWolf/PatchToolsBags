Bags={}
assert(loadfile('Model.lua'))('PatchToolsBags',Bags)
local db={autoSell=true,sellWhitelist=true,sellAllowlist={[2]=true},sellBlocklist={[3]=true}}
assert(Bags:Classify({itemID=1,quality=0},nil,1,db)=='sell')
assert(Bags:Classify({itemID=2,quality=2},true,10,db)=='quest')
assert(Bags:Classify({itemID=3,quality=0},nil,1,db)=='protected')
assert(Bags:Classify({itemID=2,quality=2},nil,0,db)==nil)
assert(Bags:Classify({itemID=1,quality=0},nil,nil,db)=='junk')
assert(Bags:Classify({itemID=1,quality=0},nil,1,{autoSell=false})=='junk')
local function item(id,n,family,suffix)
 return {family=family or 0,name=tostring(id),class=id%4,subclass=0,maxStack=20,ready=true,
  info={itemID=id,hyperlink='item:'..id..':'..(suffix or 0),stackCount=n}}
end
local function totals(slots)
 local t={}
 for _,s in ipairs(slots) do if s.info then local k=s.family..'/'..s.info.hyperlink; t[k]=(t[k] or 0)+s.info.stackCount end end
 return t
end
math.randomseed(51)
for trial=1,150 do
 local slots={}
 for i=1,80 do slots[i]=math.random()<0.3 and {family=i%2} or item(math.random(1,9),math.random(1,20),i%2,math.random(0,1)) end
 local before=totals(slots)
 for step=1,1000 do
  local m,reason=Bags:NextMove(slots)
  assert(not reason)
  if not m then break end
  assert(m.from.family==m.to.family)
  if m.kind=='merge' then
   local n=math.min(m.from.info.stackCount,m.to.maxStack-m.to.info.stackCount)
   m.to.info.stackCount=m.to.info.stackCount+n; m.from.info.stackCount=m.from.info.stackCount-n
   if m.from.info.stackCount==0 then m.from.info=nil end
  else
   assert(not m.to.info or m.from.info.hyperlink~=m.to.info.hyperlink)
   for _,key in ipairs({'info','name','class','subclass','maxStack','ready'}) do m.from[key],m.to[key]=m.to[key],m.from[key] end
  end
  assert(step<1000,'Sort failed to converge')
 end
 local after=totals(slots)
 for k,n in pairs(before) do assert(after[k]==n,'Item count changed') end
 assert(Bags:NextMove(slots)==nil)
end
local locked=item(1,2); locked.info.isLocked=true
local _,reason=Bags:NextMove({locked}); assert(reason=='wait')
locked.info.isLocked=nil; locked.ready=false
_,reason=Bags:NextMove({locked}); assert(reason=='wait')
assert(Bags:Matches({info={quality=0},mark='sell'},'schrott'))
assert(not Bags:Matches({info={quality=2},mark='protected'},'sell'))
print('PASS: 150 randomized inventories, stack/suffix/family conservation, marker protection.')
