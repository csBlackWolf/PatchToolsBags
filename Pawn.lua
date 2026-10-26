local _,Bags=...

function Bags:InvalidatePawnUpgrades()
    self.pawnUpgradeCache={}
    self:QueueRefresh()
end

function Bags:ConnectPawn()
    local available=PawnPlayerFullName and PawnCommon and type(PawnShouldItemLinkHaveUpgradeArrow)=="function"
    local register=available and self:CanReplace() and type(PawnRegisterThirdPartyBag)=="function"
    if register and not self.pawnRegistered then
        local ok=pcall(PawnRegisterThirdPartyBag,"PatchToolsBags",{
            RefreshAll=function() self:InvalidatePawnUpgrades() end,
        })
        self.pawnRegistered=ok
        self.pawnUpgradeCache={}
    elseif not register and self.pawnRegistered and type(PawnUnregisterThirdPartyBag)=="function" then
        pcall(PawnUnregisterThirdPartyBag,"PatchToolsBags")
        self.pawnRegistered=nil
        self.pawnUpgradeCache={}
    end
    -- A separate preview must not take over Pawn's native bag integration.
    if not self.pawnRegistered then self.pawnUpgradeCache={} end
    return available and PawnCommon.ShowBagUpgradeAdvisor
end

function Bags:PawnUpgrade(link)
    if not link then return false end
    self.pawnUpgradeCache=self.pawnUpgradeCache or {}
    local cached=self.pawnUpgradeCache[link]
    if cached~=nil then return cached end
    local ok,result=pcall(PawnShouldItemLinkHaveUpgradeArrow,link,true)
    if not ok then return false end
    if result~=nil then
        self.pawnUpgradeCache[link]=result==true
        return result==true
    end
    -- Pawn budgets work per frame. Cache finished answers so later slots get a
    -- turn on the retry instead of recalculating the first items every time.
    if not self.pawnRetryPending then
        self.pawnRetryPending=true
        C_Timer.After(0.3,function()
            self.pawnRetryPending=nil
            if self.window and self.window:IsShown() then self:QueueRefresh() end
        end)
    end
    return false
end
