local db_talent = Auto_Druid_DB_Talent
local db_spell = Auto_Druid_DB_Spell
local db_buff = Auto_Druid_DB_Buff
local db_item = Auto_Druid_DB_Item

Auto_Druid_BASE_CAST = {}
local cast =    Auto_Druid_BASE_CAST



function cast.time_remaining()
    -- 计算下次可以施法的时间，返回值代表多少秒后可以施法。
    -- 返回值为绝对时间，可以和 GetTime()计算得到相对时间。

    -- 计算下次gcd结束的时间
    local gcd_start, gcd_duration, _ =  GetSpellCooldown(db_spell.gcd)
    local gcd_end = gcd_start + gcd_duration

    -- 当前施法结束时间
    _, _, _, _, _, endTime, _, _, _ = UnitCastingInfo("player")

    -- 如果当前不在施法，返回gcd结束时间 or 当前时间
    -- 如果当前在施法，返回施法结束时间 or gcd结束时间
    -- 均取最大值

    local rho = nil

    if endTime == nil then
        rho = math.max(GetTime(),gcd_end)
    else
        rho = math.max(endTime/1000,gcd_end)
    end

    return rho
end


function cast.byname(spell_name)
    -- 施法
    local name, _, _, _, _, _, _ = GetSpellInfo(db_spell[spell_name])
    return CastSpellByName(name)
end


function cast.to_self(spell_name)
    -- 施法
    local name, _, _, _, _, _, _ = GetSpellInfo(db_spell[spell_name])
    return CastSpellByName(name,"player")
end

function cast.byid(spell_name)
    -- 施法
    -- print(db_spell[spell_name])
    return CastSpellByID(db_spell[spell_name])
end


function cast.byid_focus(spell_name)
    -- 施法
    -- print(db_spell[spell_name])
    return CastSpellByID(db_spell[spell_name],"focus")
end

function cast.be_ready(spell_name)
    -- 判断技能是否准备就绪，是否可以本次施法结束后施法
    if not IsPlayerSpell(db_spell[spell_name]) then return false end
    
    -- 依据是，如果技能CD小于等于公共CD，则可以下次施法
    local cd_start, cd_duration, _ = GetSpellCooldown(db_spell[spell_name])
    local cd_end = cd_start + cd_duration
    -- print(cd_start)
    -- print(cd_duration)
    -- print(cd_end)
    if cd_end == 0 then
        return true
    elseif cd_end <= cast.time_remaining() then
        return true
    else 
        return false
    end
end


function cast.cd_ready(spell_name)
    -- 不判断天赋，应为有些技能bug了
   
    -- 依据是，如果技能CD小于等于公共CD，则可以下次施法
    local cd_start, cd_duration, _ = GetSpellCooldown(db_spell[spell_name])
    local cd_end = cd_start + cd_duration
    -- print(cd_start)
    -- print(cd_duration)
    -- print(cd_end)
    if cd_end == 0 then
        return true
    elseif cd_end <= cast.time_remaining() then
        return true
    else 
        return false
    end
end

function cast.gcd_max()
    -- GCD时间，gcd本身没施法时间，用1.5秒且无法加速的星辰耀斑代替。
    local _, _, _, castingTime, _, _, _ =  GetSpellInfo(db_spell["stellar_flare"])
    return math.max(castingTime/1000,0.75)
end


function cast.execute_time(spell_name)
    -- 返回施法时间，这里不考虑buff的情况
    -- 读条技能返回读条时间，瞬发技能返回GCD
    -- 0.75是GCD下限
    local _, _, _, castingTime, _, _, _ = GetSpellInfo(db_spell[spell_name])
    if castingTime == 0 then
        return cast.gcd_max()
    else
        return math.max(castingTime/1000,0.75)
    end
end


function cast.bymacro(spell_name)
    local name, _, _, _, _, _, _ = GetSpellInfo(db_spell[spell_name])
    return RunMacroText(string.format("/cast %s", name))
end


function cast.aoe_player(spell_name)
    local name, _, _, _, _, _, _ = GetSpellInfo(db_spell[spell_name])
    return RunMacroText(string.format("/cast [@player] %s", name))
end

function cast.aoe_cursor(spell_name)
    local name, _, _, _, _, _, _ = GetSpellInfo(db_spell[spell_name])
    return RunMacroText(string.format("/cast [@cursor] %s", name))
end


function cast.aoe(spell_name)
    local name, _, _, _, _, _, _ = GetSpellInfo(db_spell[spell_name])
    return RunMacroText(string.format("/cast [@%s] %s", Auto_Druid_AOE, name))
end


function cast.cooldown(spell_name)
    -- 计算技能CD
    local start, duration, enable = GetSpellCooldown(db_spell[spell_name])
    if duration == 0 then
        return 0
    else
        return start+duration-GetTime()
    end
end