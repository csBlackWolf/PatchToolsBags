local _, Bags = ...
function Bags:Classify(info, quest, price, db)
    if not info then return nil end
    local id=info.itemID
    if quest then return "quest" end
    if db.sellBlocklist and db.sellBlocklist[id] then return "protected" end
    local eligible=(db.autoSell and info.quality==0)
        or (db.sellWhitelist and db.sellAllowlist and db.sellAllowlist[id])
    if eligible and price and price>0 then return "sell" end
    if info.quality==0 then return "junk" end
end
function Bags:Matches(item, query)
    if query=="" then return true end
    if not item.info then return false end
    local words={quest="quest",schrott="junk",junk="junk",verkauf="sell",sell="sell",protected="protected",["geschützt"]="protected"}
    if words[query] then
        return item.mark==words[query] or (words[query]=="junk" and item.info.quality==0)
    end
    return (item.search or ""):find(query,1,true)~=nil
end
-- Display ordering never changes the slot records or their bag/slot identities.
-- Full links distinguish random suffixes; coordinates break ties consistently.
function Bags:Before(a,b)
    if not a.info then return false end
    if not b.info then return true end
    if a.class~=b.class then return a.class<b.class end
    if a.subclass~=b.subclass then return a.subclass<b.subclass end
    if a.name~=b.name then return a.name<b.name end
    local al,bl=a.info.hyperlink or tostring(a.info.itemID),b.info.hyperlink or tostring(b.info.itemID)
    if al~=bl then return al<bl end
    return false
end
function Bags:DisplayOrder(slots)
    local display={}
    for i,slot in ipairs(slots) do display[i]=slot end
    table.sort(display,function(a,b)
        if self:Before(a,b) then return true end
        if self:Before(b,a) then return false end
        if a.bag~=b.bag then return a.bag<b.bag end
        return a.slot<b.slot
    end)
    return display
end
function Bags:Signature(info)
    return info and ((info.hyperlink or tostring(info.itemID)).."#"..info.stackCount) or "empty"
end
-- Only identical partial stacks may move. Display sorting must never create
-- physical swaps; different bag families remain separate for consolidation.
function Bags:NextMove(slots)
    local groups={}
    for _,s in ipairs(slots) do
        if s.info and (s.info.isLocked or not s.ready) then return nil,"wait" end
        local family=s.family or 0
        groups[family]=groups[family] or {}
        table.insert(groups[family],s)
    end
    for _,group in pairs(groups) do
        local partial={}
        for _,s in ipairs(group) do
            if s.info and s.maxStack>1 and s.info.stackCount<s.maxStack then
                local link=s.info.hyperlink
                if partial[link] then return {kind="merge",from=s,to=partial[link]} end
                partial[link]=s
            end
        end
    end
end
