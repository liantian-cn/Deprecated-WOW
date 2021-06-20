

local db_talent = Auto_Druid_DB_Talent
local db_spell = Auto_Druid_DB_Spell
local db_buff = Auto_Druid_DB_Buff
local db_item = Auto_Druid_DB_Item

Auto_Druid_BASE_SETTING = {}
local setting = Auto_Druid_BASE_SETTING


function setting.active_enemies()
    return Auto_Druid_ENEMY_NUM
end

function setting.script_on()
    return Auto_Druid_SCRIPT
end

function setting.burst()
    return Auto_Druid_BURST
end

