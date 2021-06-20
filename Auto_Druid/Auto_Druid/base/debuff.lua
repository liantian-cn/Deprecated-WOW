local db_talent = Auto_Druid_DB_Talent
local db_spell = Auto_Druid_DB_Spell
local db_buff = Auto_Druid_DB_Buff
local db_item = Auto_Druid_DB_Item
local cast =    Auto_Druid_BASE_CAST

Auto_Druid_BASE_DBBUFF = {}
local debuff =  Auto_Druid_BASE_DBBUFF



function debuff.on(buff_name)
    -- 返回是否存在buff
    return not (UnitDebuff("player", GetSpellInfo(db_buff[buff_name])) == nil)
end

function debuff.down(buff_name)
    -- 返回是否存在buff
    return UnitDebuff("player", GetSpellInfo(db_buff[buff_name])) == nil
end

function debuff.remains(buff_name)
    -- 目标debuff剩余时间，基于下次施法时间。
    -- 相对时间
    local _, _, _, _, _, _, expires , _, _, _, _, _, _, _, _, _, _, _, _ = UnitDebuff("player", GetSpellInfo(db_buff[buff_name]),nil,"PLAYER")
    if expires == nil then
        return 0
    else
        return expires - cast.time_remaining()
    end
end
