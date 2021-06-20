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

-- 能量
local astral_power = {}


local function next_moon(spell_name)
    if spell_name == "full_moon" then
        return "new_moon"
    elseif spell_name == "half_moon" then
        return "full_moon"
    elseif spell_name == "new_moon" then
        return "half_moon"
    else
        return false
    end
end

local previous_moon = "full_moon"

local frame = CreateFrame("Frame")

frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frame:SetScript("OnEvent",function(s,e,p,n)
    if(p=="player"and n==GetSpellInfo(db_spell["full_moon"]))then
        previous_moon = "full_moon"
    elseif (p=="player"and n==GetSpellInfo(db_spell["half_moon"]))then
        previous_moon = "half_moon"
    elseif (p=="player"and n==GetSpellInfo(db_spell["new_moon"]))then
        previous_moon = "new_moon"
    end;
end) 


local function moon_ready(spell_name)
    local charges, maxCharges, start, duration = GetSpellCharges(db_spell["full_moon"])
    local moon_q = next_moon(previous_moon)
    local _, _, _, _, _, _, _, _, _, current_casting = UnitCastingInfo("player")
    if current_casting == db_spell[moon_q] then
        moon_q = next_moon(moon_q)
        return (charges>=2) and (spell_name == moon_q)
    else
        return (charges>=1) and (spell_name == moon_q)
    end
end

local function moon_charges()
    local charges, maxCharges, start, duration = GetSpellCharges(db_spell["full_moon"])
    local moon_q = next_moon(previous_moon)
    local _, _, _, _, _, _, _, _, _, current_casting = UnitCastingInfo("player")
    if current_casting == db_spell[moon_q] then
        charges = charges - 1
    end
    return math.max(0,charges)
end



local function refresh_astral_power()
    -- 能量获取速度
    local psi = 1
    -- 如果开启了[化身：艾露恩之眷] or [超凡之盟]，能量获取速度增加50%
    if buff.on("celestial_alignment") or buff.on("incarnation") then psi = 1.5  end

    local chi = 1
    -- 如果使用了[艾露恩的祝福]，能量获取速度增加25%
    if buff.on("blessing_of_elune") then chi = 1.25  end

    -- 根据当前施法不同，修正下一击时的能量
    local _, _, _, _, _, _, _, _, _, current_casting = UnitCastingInfo("player")

    astral_power["max"] = UnitPowerMax("player" , 8)
    astral_power["value"] = UnitPower("player" , 8)
    
    if current_casting == db_spell["full_moon"] then
        astral_power["value"] = astral_power["value"] + 40
    elseif current_casting == db_spell["half_moon"] then
        astral_power["value"] = astral_power["value"] + 20
    elseif current_casting == db_spell["new_moon"] then
        astral_power["value"] = astral_power["value"] + 10
    elseif current_casting == db_spell["solar_wrath"] then
        astral_power["value"] = astral_power["value"] + 8 * psi * chi
    elseif current_casting == db_spell["lunar_strike"] then
        astral_power["value"] = astral_power["value"] + 12 * psi * chi
    end
    astral_power["deficit"] = astral_power["max"] - astral_power["value"]

end


local function refresh()
    refresh_astral_power()
end

local function lunar_strike_execute_time()
    -- 需要考虑buff的影响，当前有1层buff，且正在施法就是明月打击的情况。下一个明月打击速度提高25%
    local _, _, _, count, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ =  UnitBuff("player", GetSpellInfo(db_buff["lunar_strike"]))
    local execute_time = cast.execute_time("lunar_strike")
    local _, _, _, _, _, _, _, _, _, current_casting = UnitCastingInfo("player")


    if count == 1 and (current_casting == db_spell["lunar_strike"]) and talent.enabled("starlord") then
        return execute_time*1.25
    else
        return execute_time
    end
end

local function solar_wrath_execute_time()
    -- 需要考虑buff的影响，当前有1层buff，且正在施法就是明月打击的情况。下一个愤怒速度提高25%
    local _, _, _, count, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ =  UnitBuff("player", GetSpellInfo(db_buff["solar_wrath"]))
    local execute_time = cast.execute_time("solar_wrath")
    local _, _, _, _, _, _, _, _, _, current_casting = UnitCastingInfo("player")


    if count == 1 and (current_casting == db_spell["solar_wrath"]) and talent.enabled("starlord") then
        return execute_time*1.25
    else
        return execute_time
    end
end




local function in_burst()
    -- 如果开启了[化身：艾露恩之眷] or [超凡之盟] 则认为在爆发
    return buff.on("celestial_alignment") or buff.on("incarnation")
end

local function movable()
    -- 返回ture的时候，只打瞬发技能...
    local speed, groundSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")

    if (speed > 0) and buff.down("stellar_drift") then 
        return true
    else
        return false
    end
end



local function action_the_emerald_dreamcatcher()


    -- 开始
    -- if movable() then return cast.byid("moonfire") end

    -- actions.ed=astral_communion,if=astral_power.deficit>=75&buff.the_emerald_dreamcatcher.up
    -- 如果可以释放[沟通星界]，缺少能量超过75，则释放
    if cast.be_ready("astral_communion") and (astral_power.deficit>=75) then return cast.byid("astral_communion") end

    -- actions.ed+=/incarnation,if=astral_power>=60|buff.bloodlust.up
    -- actions.ed+=/celestial_alignment,if=astral_power>=60&!buff.the_emerald_dreamcatcher.up
    -- 嗜血条件下，能量>=60，开大爆发
    -- 嗜血条件下，能量>=60，没有橙头buff，开小爆发
    if talent.enabled("incarnation") and cast.be_ready("incarnation") and player.in_bloodlust() and (astral_power.value>= 60) then return cast.byname("incarnation") end
    if talent.disabled("incarnation") and cast.be_ready("celestial_alignment") and player.in_bloodlust() and (astral_power.value>= 60) and buff.down("the_emerald_dreamcatcher") then return cast.byid("celestial_alignment") end

    -- actions.ed+=/starsurge,if=(gcd.max*astral_power%26)>target.time_to_die
    -- 目标将死，无法判断，pass
    -- actions.ed+=/stellar_flare,cycle_targets=1,max_cycle_targets=4,if=active_enemies<4&remains<7.2
    -- 星辰耀斑，基本不用，pass

    -- actions.ed+=/moonfire,if=((talent.natures_balance.enabled&remains<3)|(remains<6.6&!talent.natures_balance.enabled))&(buff.the_emerald_dreamcatcher.remains>gcd.max|!buff.the_emerald_dreamcatcher.up)
    -- 月火
    if ((talent.enabled("natures_balance") and (dot.remains("moonfire") <3 )) or (talent.disabled("natures_balance") and (dot.remains("moonfire") < 6.6 ))) 
     and  ((buff.remains("the_emerald_dreamcatcher")>cast.gcd_max()) or (buff.remains("the_emerald_dreamcatcher")) ) then return cast.byid("moonfire") end

    -- actions.ed+=/sunfire,if=((talent.natures_balance.enabled&remains<3)|(remains<5.4&!talent.natures_balance.enabled))&(buff.the_emerald_dreamcatcher.remains>gcd.max|!buff.the_emerald_dreamcatcher.up)
    -- 阳炎
    if ((talent.enabled("natures_balance") and (dot.remains("sunfire") <3 )) or (talent.disabled("natures_balance") and (dot.remains("sunfire") < 5.4 ))) 
     and  ((buff.remains("the_emerald_dreamcatcher")>cast.gcd_max()) or (buff.remains("the_emerald_dreamcatcher")) ) then return cast.byid("sunfire") end

    -- actions.ed+=/starfall,if=buff.oneths_overconfidence.up&buff.the_emerald_dreamcatcher.remains>execute_time
    -- 可以插入星落则插入星落
    if buff.on("oneths_overconfidence") and (buff.remains("the_emerald_dreamcatcher") > cast.execute_time("starfall")) then return cast.aoe("starfall") end
    -- print(buff.on("oneths_overconfidence"))
    -- print(buff.remains("the_emerald_dreamcatcher") >= cast.execute_time("starfall"))

    -- 如果有枭兽狂怒buff，则插入星火。
    if buff.on("owlkin_frenzy") and (buff.remains("the_emerald_dreamcatcher") > cast.gcd_max()) then return cast.byid("lunar_strike") end
    -- actions.ed+=/new_moon,if=astral_power.deficit>=10&buff.the_emerald_dreamcatcher.remains>execute_time&astral_power>=16
    -- actions.ed+=/half_moon,if=astral_power.deficit>=20&buff.the_emerald_dreamcatcher.remains>execute_time&astral_power>=6
    -- actions.ed+=/full_moon,if=astral_power.deficit>=40&buff.the_emerald_dreamcatcher.remains>execute_time
    -- 神器技能，比较简单，不解释
    if moon_ready("new_moon") and (astral_power.deficit>=10) and (buff.remains("the_emerald_dreamcatcher") > cast.execute_time("new_moon"))  then return cast.byid("new_moon") end
    if moon_ready("half_moon") and (astral_power.deficit>=20) and (buff.remains("the_emerald_dreamcatcher") > cast.execute_time("half_moon"))  then return cast.byid("new_moon") end
    if moon_ready("full_moon") and (astral_power.deficit>=40) and (buff.remains("the_emerald_dreamcatcher") > cast.execute_time("full_moon"))  then return cast.byid("new_moon") end

    -- 7.2.5做一些优化
    -- actions.ed+=/lunar_strike,if=( buff.lunar_empowerment.up&buff.the_emerald_dreamcatcher.remains>execute_time&(!(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=15|(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=22.5))&spell_haste<0.4
    -- 有buff的情况下，打明月
    if buff.on("lunar_strike") and (buff.remains("the_emerald_dreamcatcher") > lunar_strike_execute_time()) and (((in_burst() == flase) and (astral_power.deficit>=15)) or((in_burst() and (astral_power.deficit>=22.5) )) ) then return cast.byid("lunar_strike") end
    -- if buff.on("lunar_strike") and (buff.remains("the_emerald_dreamcatcher") > lunar_strike_execute_time())  then return cast.byid("lunar_strike") end

    -- actions.ed+=/solar_wrath,if=buff.solar_empowerment.stack>1&buff.the_emerald_dreamcatcher.remains>2*execute_time&astral_power>=6&(dot.moonfire.remains>5|(dot.sunfire.remains<5.4&dot.moonfire.remains>6.6))&(!(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=10|(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=15)
    -- 有buff的情况，打愤怒
    if buff.on("solar_wrath") and (buff.remains("the_emerald_dreamcatcher") > solar_wrath_execute_time()) and (((in_burst() == flase) and (astral_power.deficit>=10)) or((in_burst() and (astral_power.deficit>=15) )) ) then return cast.byid("solar_wrath") end
    -- if buff.on("solar_wrath") and (buff.remains("the_emerald_dreamcatcher") > solar_wrath_execute_time())  then return cast.byid("solar_wrath") end

    -- actions.ed+=/lunar_strike,if=buff.lunar_empowerment.up&buff.the_emerald_dreamcatcher.remains>execute_time&astral_power>=11&(!(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=15|(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=22.5)
    -- actions.ed+=/solar_wrath,if=buff.solar_empowerment.up&buff.the_emerald_dreamcatcher.remains>execute_time&astral_power>=16&(!(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=10|(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=15)
    -- 无buff，尽量插入一个无buff愤怒/
    if buff.down("solar_wrath") and (buff.remains("the_emerald_dreamcatcher") > solar_wrath_execute_time()) and (((in_burst() == flase) and (astral_power.deficit>=10)) or((in_burst() and (astral_power.deficit>=15) )) ) then return cast.byid("solar_wrath") end

    -- actions.ed+=/starsurge,if=(buff.the_emerald_dreamcatcher.up&buff.the_emerald_dreamcatcher.remains<gcd.max)|astral_power>85|((buff.celestial_alignment.up|buff.incarnation.up)&astral_power>30)
    -- 如果剩余时间小于一个gcd 或能量缺少少于15 或爆发期间能量>30
    if (buff.on("the_emerald_dreamcatcher") and buff.remains("the_emerald_dreamcatcher") < cast.gcd_max()) or (astral_power.deficit < 15) or (in_burst() and (astral_power.value > 30)) then return cast.byid("starsurge") end

    -- 以下为断了buff，相对简单
    -- actions.ed+=/starfall,if=buff.oneths_overconfidence.up
    if buff.on("oneths_overconfidence") then return cast.aoe("starfall") end

    -- actions.ed+=/new_moon,if=astral_power.deficit>=10
    -- actions.ed+=/half_moon,if=astral_power.deficit>=20
    -- actions.ed+=/full_moon,if=astral_power.deficit>=40
    if moon_ready("new_moon") and (astral_power.deficit>=10) then return cast.byid("new_moon") end
    if moon_ready("half_moon") and (astral_power.deficit>=20) then return cast.byid("new_moon") end
    if moon_ready("full_moon") and (astral_power.deficit>=40) then return cast.byid("new_moon") end

    -- actions.ed+=/solar_wrath,if=buff.solar_empowerment.up
    -- actions.ed+=/lunar_strike,if=buff.lunar_empowerment.up
    if buff.on("solar_wrath") then return cast.byid("solar_wrath") end
    if buff.on("lunar_strike") then return cast.byid("lunar_strike") end

    return cast.byid("solar_wrath")
    -- actions.ed+=/solar_wrath
end


local function action_aoe()
    -- 如果有枭兽狂怒buff，则插入星火。
    if buff.on("owlkin_frenzy") then return cast.byid("lunar_strike") end
    -- actions.AoE=starfall,if=debuff.stellar_empowerment.remains<gcd.max*2|astral_power.deficit<22.5|(buff.celestial_alignment.remains>8|buff.incarnation.remains>8)|target.time_to_die<8
    if astral_power.value >= 60 then return cast.aoe("starfall") end
    -- actions.AoE+=/new_moon,if=astral_power.deficit>14
    -- actions.AoE+=/half_moon,if=astral_power.deficit>24
    -- actions.AoE+=/full_moon,if=astral_power.deficit>44
    if moon_ready("new_moon") and (astral_power.deficit>=14) then return cast.byid("new_moon") end
    if moon_ready("half_moon") and (astral_power.deficit>=24) then return cast.byid("new_moon") end
    if moon_ready("full_moon") and (astral_power.deficit>=44) then return cast.byid("new_moon") end
    -- actions.AoE+=/warrior_of_elune
    if cast.be_ready("warrior_of_elune") then return cast.byid("warrior_of_elune") end
    -- actions.AoE+=/lunar_strike,if=buff.warrior_of_elune.up


    -- if (UnitIsEnemy("player","focus") == true) and (IsSpellInRange(GetSpellInfo(190984),"focus") == 1) and (UnitIsDeadOrGhost("focus") ~= 1) then 
    --     if buff.on("warrior_of_elune") then return cast.byid_focus("lunar_strike") end 
    --     -- actions.AoE+=/solar_wrath,if=buff.solar_empowerment.up
    --     -- actions.AoE+=/lunar_strike,if=buff.lunar_empowerment.up
    --     if buff.on("solar_wrath") then return cast.byid_focus("solar_wrath") end
    --     if buff.on("lunar_strike") then return cast.byid_focus("lunar_strike") end
    --     -- actions.AoE+=/lunar_strike,if=active_enemies>=4|spell_haste<0.45
    --     if (setting.active_enemies() >= 4 ) then return cast.byid_focus("lunar_strike") end
    --     -- actions.AoE+=/solar_wrath
    --     return cast.byid_focus("solar_wrath")
        
    -- end

    if buff.on("warrior_of_elune") then return cast.byid("lunar_strike") end 
    -- actions.AoE+=/solar_wrath,if=buff.solar_empowerment.up
    -- actions.AoE+=/lunar_strike,if=buff.lunar_empowerment.up
    if buff.on("solar_wrath") then return cast.byid("solar_wrath") end
    if buff.on("lunar_strike") then return cast.byid("lunar_strike") end
    -- actions.AoE+=/lunar_strike,if=active_enemies>=4|spell_haste<0.45
    if (setting.active_enemies() >= 4 ) then return cast.byid("lunar_strike") end
    -- actions.AoE+=/solar_wrath
    return cast.byid("solar_wrath")


end



local function action_single_target()

    -- 如果有枭兽狂怒buff，则插入星火。
    if buff.on("owlkin_frenzy") then return cast.byid("lunar_strike") end

    -- actions.single_target=starsurge,if=astral_power.deficit<44|(buff.celestial_alignment.up|buff.incarnation.up|buff.astral_acceleration.up)|(gcd.max*(astral_power%40))>target.time_to_die
    if ( astral_power.deficit < 44 ) then return cast.byid("starsurge") end
    -- actions.single_target+=/new_moon,if=astral_power.deficit>14&!(buff.celestial_alignment.up|buff.incarnation.up)
    -- actions.single_target+=/half_moon,if=astral_power.deficit>24&!(buff.celestial_alignment.up|buff.incarnation.up)
    -- actions.single_target+=/full_moon,if=astral_power.deficit>44
    if moon_ready("new_moon") and (astral_power.deficit>=14) then return cast.byid("new_moon") end
    if moon_ready("half_moon") and (astral_power.deficit>=24) then return cast.byid("new_moon") end
    if moon_ready("full_moon") and (astral_power.deficit>=44) then return cast.byid("new_moon") end
    -- actions.single_target+=/warrior_of_elune
    if cast.be_ready("warrior_of_elune") then return cast.byid("warrior_of_elune") end
    -- actions.single_target+=/lunar_strike,if=buff.warrior_of_elune.up
    if buff.on("warrior_of_elune") then return cast.byid("lunar_strike") end 
    -- actions.single_target+=/solar_wrath,if=buff.solar_empowerment.up
    -- actions.single_target+=/lunar_strike,if=buff.lunar_empowerment.up
    if buff.on("solar_wrath") then return cast.byid("solar_wrath") end
    if buff.on("lunar_strike") then return cast.byid("lunar_strike") end
    -- actions.single_target+=/solar_wrath
    return cast.byid("solar_wrath")
end


function Simc_Moonkin()
    refresh()
    -- 开始
    -- 如果不是[枭兽形态]，切换到[枭兽形态]
    if buff.down("moonkin_form") then return cast.bymacro("moonkin_form") end

    if UnitDebuff("player", GetSpellInfo(240447)) then  return SpellStopCasting() end

    -- actions=potion,name=deadly_grace,if=buff.celestial_alignment.up|buff.incarnation.up
    -- 喝药,太贵,PASS

    -- actions+=/blessing_of_elune,if=active_enemies<=2&talent.blessing_of_the_ancients.enabled&buff.blessing_of_elune.down
    -- actions+=/blessing_of_elune,if=active_enemies>=3&talent.blessing_of_the_ancients.enabled&buff.blessing_of_anshe.down
    -- 如果天赋使用了远古祝福，根据敌人数量，分别使用2中形态。
    if (setting.active_enemies() <=2) and talent.enabled("blessing_of_the_ancients") and buff.down("blessing_of_elune") then return cast.byid("blessing_of_elune") end
    if (setting.active_enemies() >=3) and talent.enabled("blessing_of_the_ancients") and buff.down("blessing_of_elune") then return cast.byid("blessing_of_elune") end

    -- actions+=/blood_fury,if=buff.celestial_alignment.up|buff.incarnation.up
    -- actions+=/berserking,if=buff.celestial_alignment.up|buff.incarnation.up
    -- actions+=/arcane_torrent,if=buff.celestial_alignment.up|buff.incarnation.up
    -- 部落种族天赋，pass

    -- 特殊目标
    if (player.target_npcid() == 120651) then return cast.byid("moonfire") end

    -- actions+=/use_item,slot=trinket1
    -- 使用饰品
    if slot.ready(13) and setting.burst() then return slot.use(13) end
    if slot.ready(14) and setting.burst() then return slot.use(14) end
    -- actions+=/incarnation,if=astral_power>=40
    -- actions+=/celestial_alignment,if=astral_power>=40

    if talent.enabled("incarnation") and cast.be_ready("incarnation") and setting.burst() and (astral_power.value>= 60) then return cast.byname("incarnation") end
    if talent.disabled("incarnation") and cast.be_ready("celestial_alignment") and setting.burst() and (astral_power.value>= 60) then return cast.byname("celestial_alignment") end

    -- actions+=/call_action_list,name=fury_of_elune,if=talent.fury_of_elune.enabled&cooldown.fury_of_elue.remains<target.time_to_die
    -- [艾露恩之怒] 暂时用不上 PASS

    -- actions+=/call_action_list,name=ed,if=equipped.the_emerald_dreamcatcher&active_enemies<=1
    -- 如果装备橙头，则使用橙头战斗规则
    if player.equip("the_emerald_dreamcatcher") and (setting.active_enemies() <=1) then return action_the_emerald_dreamcatcher() end
    

    -- actions+=/stellar_flare,cycle_targets=1,max_cycle_targets=4,if=active_enemies<4&remains<7.23
    -- 星辰耀斑，基本不用，pass

    -- actions+=/new_moon,if=((charges=2&recharge_time<5)|charges=3)&astral_power.deficit>14
    -- actions+=/half_moon,if=((charges=2&recharge_time<5)|charges=3|(target.time_to_die<15&charges=2))&astral_power.deficit>24
    -- actions+=/full_moon,if=((charges=2&recharge_time<5)|charges=3|target.time_to_die<15)&astral_power.deficit>44

    if (movable() == false ) and moon_ready("new_moon") and (astral_power.deficit>=10) and (moon_charges() == 3) then return cast.byid("new_moon") end
    if (movable() == false ) and moon_ready("half_moon") and (astral_power.deficit>=20) and (moon_charges() == 3) then return cast.byid("new_moon") end
    if (movable() == false ) and moon_ready("full_moon") and (astral_power.deficit>=40) and (moon_charges() == 3) then return cast.byid("new_moon") end

    -- actions+=/moonfire,cycle_targets=1,if=((talent.natures_balance.enabled&remains<3)|(remains<6.6&!talent.natures_balance.enabled))&astral_power.deficit>7
    -- actions+=/sunfire,if=((talent.natures_balance.enabled&remains<3)|(remains<5.4&!talent.natures_balance.enabled))&astral_power.deficit>7



    -- actions.ed+=/moonfire,if=((talent.natures_balance.enabled&remains<3)|(remains<6.6&!talent.natures_balance.enabled))&(buff.the_emerald_dreamcatcher.remains>gcd.max|!buff.the_emerald_dreamcatcher.up)
    -- 月火
    if (talent.enabled("natures_balance") and (dot.remains("moonfire") <3 )) or (talent.disabled("natures_balance") and (dot.remains("moonfire") < 6.6 )) then return cast.byid("moonfire") end
    if (talent.enabled("natures_balance") and (dot.remains("sunfire") <3 )) or (talent.disabled("natures_balance") and (dot.remains("sunfire") < 5.4 )) then return cast.byid("sunfire") end

    -- actions+=/astral_communion,if=astral_power.deficit>=71
    if cast.be_ready("astral_communion") and (astral_power.deficit>=71) then return cast.byid("astral_communion") end
    -- if movable() then return cast.byid("moonfire") end

    if buff.on("oneths_intuition") then return cast.byid("starsurge") end
    -- actions+=/call_action_list,name=AoE,if=(active_enemies>=2&talent.stellar_drift.enabled)|active_enemies>=3
    if ((setting.active_enemies() >= 2) and talent.enabled("stellar_drift")) or (setting.active_enemies() >= 3) then return action_aoe() end

    -- actions+=/starfall,if=buff.oneths_overconfidence.up
    if buff.on("oneths_overconfidence") then return cast.aoe("starfall") end

    -- actions+=/solar_wrath,if=buff.solar_empowerment.stack=3
    -- actions+=/lunar_strike,if=buff.lunar_empowerment.stack=3
    if buff.count("solar_wrath") > 2 then return cast.byid("solar_wrath") end
    if buff.count("lunar_strike") > 2 then return cast.byid("lunar_strike") end

    -- actions+=/starsurge,if=buff.oneths_intuition.up
    if buff.on("oneths_intuition") then return cast.byid("starsurge") end

    
    
    -- actions+=/call_action_list,name=single_target

    return action_single_target()

end

function SimcTest(args)

    print(moon_ready("new_moon"))
    print(moon_ready("half_moon"))
    print(moon_ready("full_moon"))

end
