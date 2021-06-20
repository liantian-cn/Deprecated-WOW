local db_talent = Auto_Druid_DB_Talent
local db_spell = Auto_Druid_DB_Spell
local db_buff = Auto_Druid_DB_Buff
local db_item = Auto_Druid_DB_Item

local cast =    Auto_Druid_BASE_CAST
local buff =    Auto_Druid_BASE_BUFF
local debuff =  Auto_Druid_BASE_DBBUFF
local dot =  Auto_Druid_BASE_DOT
local talent =  Auto_Druid_BASE_TALENT
local slot =    Auto_Druid_BASE_SLOT
local player =  Auto_Druid_BASE_PLAYER
local setting = Auto_Druid_BASE_SETTING

-- 存储上海数据
local damageTable = {}
-- 过去5秒伤害
local damageTP5S = 0
local playerGUID = nil
local eventIndex = 0

local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

frame:SetScript("OnEvent",function(self,event, ...)
    playerGUID = UnitGUID("player")
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, eventType, _, sourceGUID, _, _, _, destGUID = ...
        if destGUID == playerGUID then
            eventIndex = eventIndex + 1  
            if eventType == "SWING_DAMAGE" then
                local _, _, _, _, _, _, _, _, _, _, _, amount, _, _, _, _, absorbed = ...
                if absorbed == nil then
                    absorbed = 0;
                end
                damageTable[eventIndex] = {time(), amount+absorbed}      
            elseif eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" or eventType == "RANGE_DAMAGE" then
                local _, _, _, _, _, _, _, _, _, _, _, _, _, _, amount, _, _, _, _, absorbed = ...
                if absorbed == nil then
                    absorbed = 0;
                end
                damageTable[eventIndex] = {time(), amount+absorbed}
            end
        end
    end

end) 


local function get_damageTP5S()
    damageTP5S = 0
	local t = time() - 5
	for k, v in pairs(damageTable) do
        if v[1] <= t then
            damageTable[k] = nil
        else
            damageTP5S = damageTP5S + v[2]
        end
	end
    return damageTP5S	
end

function Simc_Bear()
    -- print(cast.cd_ready("thrash_bear"))
    -- 怒气
    local rage = UnitPower("player" , 1)
    local max_health = UnitHealthMax("player")
    local cur_health = UnitHealth("player")
    local incoming_damage_5s = get_damageTP5S()
    -- cast.byid("thrash_bear")
    -- print(rage)
    -- print(max_health)
    -- print(incoming_damage_5s)

    -- 如果不在战斗，放弃
    if player.in_combat() == false then return false end
    -- actions=auto_attack
    -- actions+=/blood_fury
    -- actions+=/berserking
    -- actions+=/arcane_torrent
    -- 种族天赋，放弃
    -- actions+=/use_item,slot=trinket2
    -- actions+=/incarnation
    -- 化身、饰品，手动
    -- actions+=/rage_of_the_sleeper
    -- 神器技能，作为免伤，手动
    -- actions+=/lunar_beam
    -- 明月 手动

    -- actions+=/frenzied_regeneration,if=incoming_damage_5s%health.max>=0.5|health<=health.max*0.4
    -- 狂暴恢复
    if ((incoming_damage_5s/max_health) >= 0.5) and cast.cd_ready("frenzied_regeneration") and buff.down("frenzied_regeneration") then return cast.byid("frenzied_regeneration") end
    if ((cur_health/max_health) <= 0.4) and cast.cd_ready("frenzied_regeneration") and (rage >= 20) and buff.down("frenzied_regeneration") then return cast.byid("frenzied_regeneration") end
    
    -- actions+=/bristling_fur,if=buff.ironfur.stack=1|buff.ironfur.down
    -- actions+=/ironfur,if=(buff.ironfur.up=0)|(buff.gory_fur.up=1)|(rage>=80)
    if (rage >= 70) then return cast.byid("ironfur") end
    -- actions+=/moonfire,if=buff.incarnation.up=1&dot.moonfire.remains<=4.8
    -- actions+=/thrash_bear,if=buff.incarnation.up=1&dot.thrash.remains<=4.5
    
    
    -- actions+=/pulverize,if=buff.pulverize.up=0|buff.pulverize.remains<=6
    -- actions+=/moonfire,if=buff.galactic_guardian.up=1&(!ticking|dot.moonfire.remains<=4.8)
    -- actions+=/moonfire,if=buff.galactic_guardian.up=1
    if buff.on("galactic_guardian") then return cast.byid("moonfire") end
    -- actions+=/moonfire,if=dot.moonfire.remains<=4.8
    if (dot.remains("moonfire") < 4.8 ) then return cast.byid("moonfire") end
    -- actions+=/thrash_bear
    if cast.cd_ready("thrash_bear") then return cast.byname("thrash_bear") end
    -- actions+=/mangle
    local mangle_name, _, _, _, _, _ = GetSpellInfo(33917)

    if IsSpellInRange(mangle_name, "target") and cast.cd_ready("mangle") then return cast.byid("mangle") end 

    -- actions+=/swipe_bear

    return cast.byname("swipe_bear")


end