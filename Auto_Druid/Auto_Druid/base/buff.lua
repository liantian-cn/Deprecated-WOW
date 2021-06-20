local db_talent = Auto_Druid_DB_Talent
local db_spell = Auto_Druid_DB_Spell
local db_buff = Auto_Druid_DB_Buff
local db_item = Auto_Druid_DB_Item
local cast =    Auto_Druid_BASE_CAST

Auto_Druid_BASE_BUFF = {}
local buff =    Auto_Druid_BASE_BUFF



function buff.count(buff_name)
    -- buff层数
    local _, _, _, count, _, duration, expires, _, _, _, spellID, _, _, _, _, _, _, _, _ =  UnitBuff("player", GetSpellInfo(db_buff[buff_name]))
    -- local _, _, _, count, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ =  UnitBuff("player", GetSpellInfo(db_buff[buff_name]))

    -- 如果层数是nil，那就是无buff，返回0。
    if count == nil then
        return 0
    end

    -- 如果这是个读秒的buff，持续不到下次施法，则返回0
    if (expires > 0) and ((expires - cast.time_remaining()) <= 0) then
        return 0
    end

    -- 如果层数是0，则表明这是不叠层的buff，返回1，1层
    if count == 0 then
        count = 1
    end

    -- 愤怒buff考虑当前施法
    if (buff_name =="solar_wrath") and (current_casting == db_spell["solar_wrath"]) then
        count = count - 1
    end

    -- 愤怒buff考虑当前施法
    if (buff_name =="lunar_strike") and (current_casting == db_spell["lunar_strike"]) then
        count = count - 1
    end

    return count

end


function buff.on(buff_name)
    -- 返回是否存在buff
    return buff.count(buff_name) > 0
end

function buff.down(buff_name)
    -- 返回是否存在buff
    return buff.count(buff_name) <= 0
end


function buff.remains(buff_name)
    -- 目标debuff剩余时间，基于下次施法时间。
    -- 相对时间
    local _, _, _, _, _, _, expires , _, _, _, _, _, _, _, _, _, _, _, _ = UnitBuff("player", GetSpellInfo(db_buff[buff_name]))
    if expires == nil then
        return 0
    else
        return expires - cast.time_remaining()
    end
end
