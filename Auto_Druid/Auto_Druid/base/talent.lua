local db_talent = Auto_Druid_DB_Talent

Auto_Druid_BASE_TALENT = {}
local talent =  Auto_Druid_BASE_TALENT

function talent.enabled(talent_name)
    -- 返回是否启用天赋
    return IsPlayerSpell(db_talent[talent_name])
end

function talent.disabled(talent_name)
    -- 返回是否启用天赋
    return not IsPlayerSpell(db_talent[talent_name])
end