Auto_Druid_BASE_SLOT = {}
local slot =    Auto_Druid_BASE_SLOT

function slot.ready(slot)
    -- 装备是否可以使用
    local start, duration, enable = GetInventoryItemCooldown("player", slot)
    if (enable == 1) and (start == 0) then 
        return true
    else
        return false
    end
    
end

function slot.use(slot)
-- 使用装备
    return UseInventoryItem(slot)
end