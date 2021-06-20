local DamageTable = {}
local DamageTP5S = 0
local EventIndex = 0

local frame = CreateFrame("Frame")
local PlayerGUID = UnitGUID("player")


frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_LEAVE_COMBAT")

frame:SetScript("OnEvent",function(self,event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" and UnitAffectingCombat("player") then
        local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags , destGUID = CombatLogGetCurrentEventInfo()
        if destGUID == PlayerGUID then
            EventIndex = EventIndex + 1  
            if eventType == "SWING_DAMAGE" then
                local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, amount, overkill, school, resisted, blocked, absorbed = CombatLogGetCurrentEventInfo()
                if absorbed == nil then
                    absorbed = 0;
                end
                DamageTable[EventIndex] = {timestamp, amount+absorbed} 
            elseif eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" or eventType == "RANGE_DAMAGE" then
                local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed = CombatLogGetCurrentEventInfo()
                if absorbed == nil then
                    absorbed = 0;
                end
                DamageTable[EventIndex] = {timestamp, amount+absorbed}
            end

        end

        DamageTP5S = 0
        local t = timestamp - 5
        for k, v in pairs(DamageTable) do
            if v[1] <= t then
                DamageTable[k] = nil
            else
                DamageTP5S = DamageTP5S + v[2]
            end
        end


    end

    if event == "PLAYER_LEAVE_COMBAT" then
        for k in pairs (DamageTable) do
            DamageTable [k] = nil
        end
        DamageTP5S = 0
    end

end) 


function get_damageTP5S()

    return DamageTP5S	
end