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
-- Persist slot coordinates, not item identities: manual moves and newly looted
-- items stay at their chosen display position until the next explicit sort.
function Bags:Sections(slots,sort)
    if not self.layout then
        if self.isBank then
            self.windowDB.layout=self.windowDB.layout or {}
            self.layout=self.windowDB.layout
        else
        self.db.layouts=self.db.layouts or {}
        local character=UnitGUID and UnitGUID("player") or "current"
        self.db.layouts[character]=self.db.layouts[character] or {}
        self.layout=self.db.layouts[character]
        end
    end
    local sections,byKey={},{}
    for _,slot in ipairs(slots) do
        local key=slot.family==0 and "general" or "bag"..slot.bag
        if not byKey[key] then
            local section={key=key,bag=slot.bag,family=slot.family,slots={}}
            byKey[key]=section; sections[#sections+1]=section
        end
        table.insert(byKey[key].slots,slot)
    end
    table.sort(sections,function(a,b)
        if a.key=="general" then return b.key~="general" end
        if b.key=="general" then return false end
        return a.bag<b.bag
    end)
    for _,section in ipairs(sections) do
        local ordered={}
        if sort then ordered=self:DisplayOrder(section.slots)
        else
            local remaining={}
            for _,slot in ipairs(section.slots) do remaining[slot.bag..":"..slot.slot]=slot end
            for _,key in ipairs(self.layout[section.key] or {}) do
                if remaining[key] then ordered[#ordered+1]=remaining[key]; remaining[key]=nil end
            end
            for _,slot in ipairs(section.slots) do
                if remaining[slot.bag..":"..slot.slot] then ordered[#ordered+1]=slot end
            end
        end
        section.slots=ordered
        local keys={}
        for i,slot in ipairs(ordered) do keys[i]=slot.bag..":"..slot.slot end
        self.layout[section.key]=keys
    end
    return sections
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
