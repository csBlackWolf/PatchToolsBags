local bags={db={}}
assert(loadfile('Pawn.lua'))('PatchToolsBags',bags)
local queue,refreshes,replace={},0,true
function bags:QueueRefresh() refreshes=refreshes+1 end
function bags:CanReplace() return replace end
bags.window={IsShown=function() return true end}
C_Timer={After=function(_,fn) queue[#queue+1]=fn end}
assert(not bags:ConnectPawn(),'Pawn remains optional')
PawnPlayerFullName='Test'; PawnCommon={ShowBagUpgradeAdvisor=true}
local callback,registered,unregistered,calls=nil,0,0,0
function PawnRegisterThirdPartyBag(name,api) assert(name=='PatchToolsBags'); registered=registered+1; callback=api.RefreshAll end
function PawnUnregisterThirdPartyBag(name) assert(name=='PatchToolsBags'); unregistered=unregistered+1 end
local pending=true
function PawnShouldItemLinkHaveUpgradeArrow(link,checkLevel)
    assert(checkLevel==false); calls=calls+1
    if link=='pending' and pending then return nil end
    return link=='upgrade' or link=='requires-level-20'
end
assert(bags:ConnectPawn()); bags:ConnectPawn(); assert(registered==1)
assert(bags:PawnUpgrade('upgrade')); assert(bags:PawnUpgrade('upgrade')); assert(calls==1)
assert(not bags:PawnUpgrade('ordinary')); assert(not bags:PawnUpgrade('ordinary')); assert(calls==2,'negative answers are cached')
assert(not bags:PawnUpgrade('pending')); assert(#queue==1)
pending=false; queue[1](); assert(refreshes==1)
assert(not bags:PawnUpgrade('pending'))
callback(); assert(bags.pawnUpgradeCache.upgrade==nil)
assert(bags:PawnUpgrade('upgrade'))
replace=false; bags:ConnectPawn(); assert(unregistered==1,'preview must leave native bag integration enabled')
PawnCommon.ShowBagUpgradeAdvisor=false; assert(bags:ConnectPawn(),'Pawn native-bag preference must not hide our arrows')
bags.db.pawnUpgrades=false; assert(not bags:ConnectPawn(),'our own arrow preference is respected')
bags.db.pawnUpgrades=true; assert(bags:ConnectPawn())
assert(bags:PawnUpgrade('requires-level-20'),'an upgrade above the current level must keep its arrow')
print('PASS: optional Pawn, budget retry, cache invalidation, native bag fallback and arrow preference.')
