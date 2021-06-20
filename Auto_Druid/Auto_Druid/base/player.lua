local db_talent = Auto_Druid_DB_Talent
local db_spell = Auto_Druid_DB_Spell
local db_buff = Auto_Druid_DB_Buff
local db_item = Auto_Druid_DB_Item
local buff =    Auto_Druid_BASE_BUFF

Auto_Druid_BASE_PLAYER = {}
local player =  Auto_Druid_BASE_PLAYER




function player.in_bloodlust()
    -- 是否在爆发
    if buff.on("time_warp") then
        return true
    elseif buff.on("bloodlust") then
        return true
    elseif buff.on("heroism") then
        return true
    elseif buff.on("netherwinds") then
        return true
    elseif buff.on("ancient_hysteria") then
        return true
    elseif buff.on("drums_of_the_mountain") then
        return true
    elseif buff.on("drums_of_fury") then
        return true
    else
        return false
    end
end


function player.in_combat()
    -- 是否在战斗
    return UnitAffectingCombat("player")
end

function player.equip(itemname)
    return IsEquippedItem(db_item[itemname])
end


function player.target_npcid()
    local guid = UnitGUID("target")
    if guid ~= nil then
        local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
        if type == "Creature" then
            return npc_id
        else 
            return 0
        end
    else
        return 0
    end
end


function player.TargetNearestEnemy()
    return TargetNearestEnemy()
end


function player.casting(spell_name)
    local _, _, _, _, _, _, _, _, _, current_casting = UnitCastingInfo("player")
    if current_casting == db_spell[spell_name] then
        return true
    else 
        return false
    end
end

function player.not_casting(spell_name)
    local _, _, _, _, _, _, _, _, _, current_casting = UnitCastingInfo("player")
    if current_casting ~= db_spell[spell_name] then
        return true
    else 
        return false
    end
end


function player.target_health_pct()
    local maxValue = UnitHealthMax("target")
    local health = UnitHealth("target")
    if maxValue ~= nil then
        return health/maxValue
    else
        return 0
    end
end