
local db_talent = Auto_Druid_DB_Talent
local db_spell = Auto_Druid_DB_Spell
local db_buff = Auto_Druid_DB_Buff
local db_item = Auto_Druid_DB_Item

-- Auto_Druid_Frame = CreateFrame("Frame","Auto_Druid_Frame",UIParent)

Auto_Druid_ENEMY_NUM = 1 
Auto_Druid_BURST = false
Auto_Druid_SCRIPT = false
Auto_Druid_AOE = "player"


function Auto_Druid_REFRESH_ENEMY_NUM()
    Auto_Druid_FrameButtonValue:SetText(Auto_Druid_ENEMY_NUM)
end

function Auto_Druid_ADD_ENEMY_NUM()
    Auto_Druid_ENEMY_NUM = Auto_Druid_ENEMY_NUM + 1
    if Auto_Druid_ENEMY_NUM >=5 then
        Auto_Druid_ENEMY_NUM = 5
    end
    Auto_Druid_REFRESH_ENEMY_NUM()
end


function Auto_Druid_CUT_ENEMY_NUM()
    Auto_Druid_ENEMY_NUM = Auto_Druid_ENEMY_NUM - 1
    if Auto_Druid_ENEMY_NUM <= 1 then
        Auto_Druid_ENEMY_NUM = 1
    end
    Auto_Druid_REFRESH_ENEMY_NUM()
end

Auto_Druid_FrameButtonValue:SetScript("OnClick", function()Auto_Druid_REFRESH_ENEMY_NUM()end)
Auto_Druid_FrameButtonAdd:SetScript("OnClick", function()Auto_Druid_ADD_ENEMY_NUM()end)
Auto_Druid_FrameButtonCut:SetScript("OnClick", function()Auto_Druid_CUT_ENEMY_NUM()end)


function Auto_Druid_SWITCH_BURST()
    local fs = nil
    if Auto_Druid_BURST == false then
        Auto_Druid_BURST = true
        fs = Auto_Druid_FrameButtonBurstValue:GetFontString()
        fs:SetTextColor(1,0,0,1)
        Auto_Druid_FrameButtonBurstValue:SetText("on")
        Auto_Druid_FrameButtonBurstValue:SetFontString(fs)
    else
        Auto_Druid_BURST = false
        fs = Auto_Druid_FrameButtonBurstValue:GetFontString()
        fs:SetTextColor(0,1,1,0.5)
        Auto_Druid_FrameButtonBurstValue:SetText("off")
        Auto_Druid_FrameButtonBurstValue:SetFontString(fs)
    end
end

Auto_Druid_FrameButtonBurst:SetScript("OnClick", function()Auto_Druid_SWITCH_BURST()end)


-- function Auto_Druid_SWITCH_SCRIPT()
--     local fs = nil
--     if Auto_Druid_SCRIPT == false then
--         Auto_Druid_SCRIPT = true
--         fs = Auto_Druid_FrameButtonScriptValue:GetFontString()
--         fs:SetTextColor(1,0,0,1)
--         Auto_Druid_FrameButtonScriptValue:SetText("on")
--         Auto_Druid_FrameButtonScriptValue:SetFontString(fs)
--     else
--         Auto_Druid_SCRIPT = false
--         fs = Auto_Druid_FrameButtonScriptValue:GetFontString()
--         fs:SetTextColor(0,1,1,0.5)
--         Auto_Druid_FrameButtonScriptValue:SetText("off")
--         Auto_Druid_FrameButtonScriptValue:SetFontString(fs)
--     end
-- end

-- Auto_Druid_FrameButtonScript:SetScript("OnClick", function()Auto_Druid_SWITCH_SCRIPT()end)


function Auto_Druid_SWITCH_AOE()
    local fs = nil
    if Auto_Druid_AOE == "player" then
        Auto_Druid_AOE = "cursor"
        fs = Auto_Druid_FrameButtonAOEValue:GetFontString()
        fs:SetTextColor(1,0,0,1)
        Auto_Druid_FrameButtonAOEValue:SetText("cursor")
        Auto_Druid_FrameButtonAOEValue:SetFontString(fs)
    else
        Auto_Druid_AOE = "player"
        fs = Auto_Druid_FrameButtonAOEValue:GetFontString()
        fs:SetTextColor(0,1,1,0.5)
        Auto_Druid_FrameButtonAOEValue:SetText("player")
        Auto_Druid_FrameButtonAOEValue:SetFontString(fs)
    end
end

Auto_Druid_FrameButtonAOE:SetScript("OnClick", function()Auto_Druid_SWITCH_AOE()end)