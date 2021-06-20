local db_talent = Auto_Druid_DB_Talent
local db_spell = Auto_Druid_DB_Spell
local db_buff = Auto_Druid_DB_Buff
local db_item = Auto_Druid_DB_Item

local cast =    Auto_Druid_BASE_CAST
local buff =    Auto_Druid_BASE_BUFF
local debuff =  Auto_Druid_BASE_DBBUFF
local talent =  Auto_Druid_BASE_TALENT
local dot =  Auto_Druid_BASE_DOT
local slot =    Auto_Druid_BASE_SLOT
local player =  Auto_Druid_BASE_PLAYER
local setting = Auto_Druid_BASE_SETTING


local energy = {}


local stronger_rip = false
local stronger_rake = false




local debug = false
local function debug_print(str)
    if debug then
        print(str)
    end
    return nil
end

local function refresh_energy()

    energy["max"] = UnitPowerMax("player" , 3)
    energy["value"] = UnitPower("player" , 3)
    energy["deficit"] = energy["max"] - energy["value"]

end




function Simc_Cat()
    refresh_energy()
    -- if energy.deficit == 0 then
    --     debug = true
    -- else
    --     debug = false
    -- end
    debug_print(energy.deficit)
    local combo_points = GetComboPoints( "player","target")


    if talent.disabled("bloodtalons") then
        return debug_print("100级天赋必须点血爪")
    end


    if talent.disabled("savage_roar") then
        return debug_print("75级天赋必须点野蛮咆哮")
    end

-- 合剂
-- actions.precombat=flask
-- 食物
-- actions.precombat+=/food
-- 符文
-- actions.precombat+=/augmentation
-- 开战前愈合
-- actions.precombat+=/愈合,if=talent.血腥爪击.enabled
-- # 斜掠_refresh controls how aggresively to refresh 斜掠. Lower means less aggresively.
-- actions.precombat+=/variable,name=斜掠_refresh,op=set,value=7
-- actions.precombat+=/variable,name=斜掠_refresh,op=set,value=3,if=equipped.橙鞋
-- # Pooling controlls how aggresively to pool. Lower means more aggresively
-- actions.precombat+=/variable,name=pooling,op=set,value=3
-- actions.precombat+=/variable,name=pooling,op=set,value=10,if=equipped.chatoyant_signet
-- actions.precombat+=/variable,name=pooling,op=set,value=3,if=equipped.the_wildshapers_clutch&!equipped.chatoyant_signet
-- actions.precombat+=/cat_form
-- actions.precombat+=/潜行
-- # Snapshot raid buffed stats before combat begins and pre-potting is done.
-- actions.precombat+=/snapshot_stats
-- actions.precombat+=/potion

-- 如果不在猫形态，点了血腥爪击天赋，没有血腥爪击debuff,则释放愈合,否侧变猫
-- talent.bloodtalons.enabled
if buff.down("cat_form") then
    debug_print("不在猫形态")
    if buff.down("bloodtalons") and player.not_casting("regrowth")  then 
        debug_print("有血爪天赋，且无血爪buff")
        return cast.to_self("regrowth")
    else
        return cast.byname("cat_form") 
    end
end


-- ##################################
-- ##                              ##
-- ##       spec  特殊技能          ##
-- ##                              ##
-- ##################################

--------------- 简易版 ----------------------------------

-- # Executed every time the actor is available.
-- actions=dash,if=!buff.cat_form.up
-- actions+=/cat_form
-- actions+=/call_action_list,name=opener,if=!dot.割裂.ticking&time<15&talent.野蛮咆哮.enabled&talent.锯齿创伤.enabled&talent.血腥爪击.enabled&desired_targets<=1
-- actions+=/call_action_list,name=opener,if=!dot.rip.ticking&time<15&talent.savage_roar.enabled&talent.jagged_wounds.enabled&talent.bloodtalons.enabled&desired_targets<=1


-- if dot.down("rip") then
--     -- 无割裂，大概是起手状态
--     -- actions.opener=斜掠,if=buff.潜行.up
--     -- actions.opener+=/野蛮咆哮,if=buff.野蛮咆哮.down
--     -- actions.opener+=/狂暴,if=buff.野蛮咆哮.up&!equipped.灵魂之引
--     -- actions.opener+=/猛虎之怒,if=buff.狂暴.up&!equipped.灵魂之引
--     -- actions.opener+=/frenzy,if=buff.血腥爪击.up&!equipped.灵魂之引
--     -- actions.opener+=/愈合,if=连击点=5&buff.血腥爪击.down&buff.掠食者的迅捷.up&!equipped.灵魂之引
--     -- actions.opener+=/割裂,if=连击点=5&buff.血腥爪击.up
--     -- actions.opener+=/撕碎,if=连击点<5&buff.野蛮咆哮.up
--     -- actions.opener=rake,if=buff.prowl.up
--     -- actions.opener+=/savage_roar,if=buff.savage_roar.down
--     -- actions.opener+=/berserk,if=buff.savage_roar.up
--     -- actions.opener+=/tigers_fury,if=buff.berserk.up
--     -- actions.opener+=/frenzy,if=buff.bloodtalons.up
--     -- actions.opener+=/regrowth,if=combo_points=5&buff.bloodtalons.down&buff.predatory_swiftness.up
--     -- actions.opener+=/rip,if=combo_points=5&buff.bloodtalons.up
--     -- actions.opener+=/shred,if=combo_points<5&buff.savage_roar.up
--     if (combo_points > 0) and buff.down("savage_roar") then
--         debug_print("没有野蛮咆哮，野蛮咆哮")
--         return cast.byname("savage_roar")
--     end
-- end




-- actions+=/狂暴,if=buff.猛虎之怒.up
if cast.cd_ready("berserk") and setting.burst() and buff.on("savage_roar") and (energy.deficit >= 80) then
    debug_print("开爆发")
    return cast.byname("berserk")
end

if slot.ready(13) and buff.on("savage_roar") then return slot.use(13) end
if slot.ready(14) and buff.on("savage_roar") then return slot.use(14) end




-- # Use Healing Touch at 5 Combo Points, if Predatory Swiftness is about to fall off, at 2 Combo Points before Ashamane's Frenzy, before Elune's Guidance is cast or before the Elune's Guidance buff gives you a 5th Combo Point.
-- actions+=/愈合,if=talent.血腥爪击.enabled&buff.掠食者的迅捷.up&buff.血腥爪击.down&(连击点>=5|buff.掠食者的迅捷.remains<1.5|(talent.血腥爪击.enabled&连击点=2&cooldown.阿莎曼的狂乱.remains<gcd)|(talent.elunes_guidance.enabled&((cooldown.elunes_guidance.remains<gcd&连击点=0)|(buff.elunes_guidance.up&连击点>=4))))
-- actions+=/愈合,if=talent.血腥爪击.enabled&buff.掠食者的迅捷.up&buff.血腥爪击.down&连击点=4&dot.斜掠.remains<4
-- actions+=/regrowth,if=talent.bloodtalons.enabled&buff.predatory_swiftness.up&buff.bloodtalons.down&(combo_points>=5|buff.predatory_swiftness.remains<1.5|(talent.bloodtalons.enabled&combo_points=2&cooldown.ashamanes_frenzy.remains<gcd)|(talent.elunes_guidance.enabled&((cooldown.elunes_guidance.remains<gcd&combo_points=0)|(buff.elunes_guidance.up&combo_points>=4))))
-- actions+=/regrowth,if=talent.bloodtalons.enabled&buff.predatory_swiftness.up&buff.bloodtalons.down&combo_points=4&dot.rake.remains<4
if buff.on("predatory_swiftness") and buff.down("bloodtalons") then
    debug_print("有掠食者的迅捷，无血腥爪击")
    if (combo_points == 4) and (dot.remains("rake") < 4) then
        debug_print("四星，斜掠剩余小于4秒，愈合")
        return cast.to_self("regrowth")
    end
    if combo_points == 5 then
        debug_print("五星，有掠食者的迅捷不用浪费，愈合")
        return cast.to_self("regrowth")
    end
    if buff.remains("predatory_swiftness") < 1.5 then
        debug_print("掠食者的迅捷持续时间<1.5秒，不用浪费，愈合")
        return cast.to_self("regrowth")
    end
    if (combo_points == 2) and cast.cd_ready("ashamanes_frenzy") and (buff.remains("savage_roar") > 3) then
        debug_print("2星，阿莎曼的狂乱可用，有咆哮，使用愈合")
        return cast.to_self("regrowth")
    end
end


-- actions+=/猛虎之怒,if=(!buff.clearcasting.react&energy.deficit>=60)|energy.deficit>=80
-- actions+=/tigers_fury,if=(!buff.clearcasting.react&energy.deficit>=60)|energy.deficit>=80
if cast.cd_ready("tigers_fury") then
    if buff.on("clearcasting") and  (energy.deficit >=90 ) then
        debug_print("energy.deficit>=80")
        return cast.to_self("tigers_fury")
    end
    if buff.down("clearcasting") and  (energy.deficit >=75) then
        debug_print("!buff.clearcasting.react&energy.deficit>=60")
        return cast.to_self("tigers_fury")
    end
end 


-- # Keep 割裂 from falling off during execute range.
-- actions+=/凶猛撕咬,cycle_targets=1,if=dot.割裂.ticking&dot.割裂.remains<3&target.time_to_die>3&(target.health.pct<25|talent.剑齿利刃.enabled)
-- actions+=/ferocious_bite,cycle_targets=1,if=dot.rip.ticking&dot.rip.remains<3&target.time_to_die>3&(target.health.pct<25|talent.sabertooth.enabled)
if (combo_points >= 1 ) and dot.on("rip") and (dot.remains("rip") < 3) and (player.target_health_pct() <= 0.25) and buff.on("bloodtalons") then
    debug_print("血量小于25%时，凶猛撕咬刷新割裂")
    return cast.to_self("ferocious_bite")
end

-- debug_print(cast.cooldown("tigers_fury"))

-- ##################################
-- ##                              ##
-- ##       finisher  终结技       ##
-- ##                              ##
-- ##################################
-- actions+=/call_action_list,name=finisher

-- # The Following line massively increases performance of the simulation but can be safely removed.
-- actions+=/wait,sec=1,if=energy.time_to_max>3
if (combo_points == 5) then
debug_print("五星")
-- # Use Savage Roar if it's expired and you're at 5 combo points or are about to use Brutal Slash
-- actions.finisher=pool_resource,for_next=1
-- actions.finisher+=/野蛮咆哮,if=!buff.野蛮咆哮.up&(连击点=5|(talent.野蛮挥砍.enabled&spell_targets.野蛮挥砍>desired_targets&action.野蛮挥砍.charges>0))
-- actions.finisher+=/savage_roar,if=!buff.savage_roar.up&(combo_points=5|(talent.brutal_slash.enabled&spell_targets.brutal_slash>desired_targets&action.brutal_slash.charges>0))

    -- 没有咆哮，就补咆哮，第一优先级。
    if buff.down("savage_roar") then
        debug_print("没有野蛮咆哮，野蛮咆哮")
        return cast.byname("savage_roar")
    end


    -- 有咆哮的情况下，以下四种情况才使用终结技。
    -- 高能量，能量空缺<30，因为魂戒指，使用后能量空缺<15。
    -- 狂暴，能量消耗-50%。
    -- 三秒内有猛虎。
    -- 斜掠 < 1.5秒，需要终结技后补斜掠
    
    if ((energy.deficit < 40) and buff.down("clearcasting")) or ((energy.deficit < 50) and buff.on("clearcasting")) or buff.on("berserk") or (cast.cooldown("tigers_fury") < 3) or (dot.remains("rake") <= 1.5) then
        debug_print("满足终结技释放条件")

        -- # Refresh 割裂 at 8 seconds or for a stronger 割裂
        -- actions.finisher+=/割裂,cycle_targets=1,if=(!ticking|(remains<8&target.health.pct>25&!talent.剑齿利刃.enabled)|persistent_multiplier>dot.割裂.pmultiplier)&target.time_to_die-remains>tick_time*4&连击点=5&(energy.time_to_max<3|buff.狂暴.up|buff.化身.up|buff.elunes_guidance.up|cooldown.猛虎之怒.remains<3|set_bonus.tier18_4pc|(buff.clearcasting.react&energy>65)|talent.soul_of_the_forest.enabled|!dot.割裂.ticking|(dot.斜掠.remains<1.5&spell_targets.横扫<6))
        -- actions.finisher+=/rip,cycle_targets=1,if=(!ticking|(remains<8&target.health.pct>25&!talent.sabertooth.enabled)|persistent_multiplier>dot.rip.pmultiplier)&target.time_to_die-remains>tick_time*4&combo_points=5&(energy.time_to_max<variable.pooling|buff.berserk.up|buff.incarnation.up|buff.elunes_guidance.up|cooldown.tigers_fury.remains<3|set_bonus.tier18_4pc|(buff.clearcasting.react&energy>65)|talent.soul_of_the_forest.enabled|!dot.rip.ticking|(dot.rake.remains<1.5&spell_targets.swipe_cat<6))


        if ((dot.remains("rip") < 8) and (player.target_health_pct() > 0.25)) and buff.on("bloodtalons") then
            stronger_rip = true
            debug_print("割裂小于8秒,释放割裂")
            return cast.byname("rip")
        end

        if dot.down("rip") then
            stronger_rip = false
            debug_print("没有割裂,释放割裂")
            print("垃圾割裂")
            return cast.byname("rip")
        end


        -- # Refresh Savage Roar early with Jagged Wounds
        -- actions.finisher+=/野蛮咆哮,if=((buff.野蛮咆哮.remains<=10.5&talent.锯齿创伤.enabled)|(buff.野蛮咆哮.remains<=7.2))&连击点=5&(energy.time_to_max<3|buff.狂暴.up|buff.化身.up|buff.elunes_guidance.up|cooldown.猛虎之怒.remains<3|set_bonus.tier18_4pc|(buff.clearcasting.react&energy>65)|talent.soul_of_the_forest.enabled|!dot.割裂.ticking|(dot.斜掠.remains<1.5&spell_targets.横扫<6))
        -- actions.finisher+=/savage_roar,if=((buff.savage_roar.remains<=10.5&talent.jagged_wounds.enabled)|(buff.savage_roar.remains<=7.2))&combo_points=5&(energy.time_to_max<variable.pooling|buff.berserk.up|buff.incarnation.up|buff.elunes_guidance.up|cooldown.tigers_fury.remains<3|set_bonus.tier18_4pc|(buff.clearcasting.react&energy>65)|talent.soul_of_the_forest.enabled|!dot.rip.ticking|(dot.rake.remains<1.5&spell_targets.swipe_cat<6))
        if (buff.remains("savage_roar") <= 10.5) then
            debug_print("野蛮咆哮持续时间小于10.5,使用野蛮咆哮")
            return cast.byname("savage_roar")
        end

        -- actions.finisher+=/凶猛撕咬,max_energy=1,cycle_targets=1,if=连击点=5&(energy.time_to_max<3|buff.狂暴.up|buff.化身.up|buff.elunes_guidance.up|cooldown.猛虎之怒.remains<3)
        -- actions.finisher+=/ferocious_bite,max_energy=1,cycle_targets=1,if=combo_points=5&(energy.time_to_max<variable.pooling|buff.berserk.up|buff.incarnation.up|buff.elunes_guidance.up|cooldown.tigers_fury.remains<3)
        debug_print("割裂和咆哮都不需要，释放凶猛撕咬")
        return cast.byname("ferocious_bite")

    end
end


-- ##################################
-- ##                              ##
-- ##       generator  攒星        ##
-- ##                              ##
-- ##################################

if (combo_points < 5) then
    -- actions+=/call_action_list,name=generator
    -- 
    -- # 当连击点<2,且有血爪buff,有野蛮咆哮buff时候，使用阿莎曼的狂乱
    -- actions.generator+=/阿莎曼的狂乱,if=连击点<=2&(buff.血腥爪击.up|!talent.血腥爪击.enabled)&(buff.野蛮咆哮.up|!talent.野蛮咆哮.enabled)
    -- actions.generator+=/ashamanes_frenzy,if=combo_points<=2&buff.elunes_guidance.down&(buff.bloodtalons.up|!talent.bloodtalons.enabled)&(buff.savage_roar.up|!talent.savage_roar.enabled)
    if (combo_points <= 2) and cast.cd_ready("ashamanes_frenzy") and buff.on("bloodtalons") and buff.on("savage_roar") then
        debug_print("连击点<2,且有血爪buff,有野蛮咆哮buff时候，使用阿莎曼的狂乱")
        return cast.byname("ashamanes_frenzy")
    end

    -- # Refresh 斜掠 early with 血腥爪击
    -- actions.generator+=/pool_resource,for_next=1
    -- actions.generator+=/斜掠,cycle_targets=1,if=连击点<5&(!ticking|(!talent.血腥爪击.enabled&remains<duration*0.3)|(talent.血腥爪击.enabled&buff.血腥爪击.up&(remains<=variable.斜掠_refresh)&persistent_multiplier>dot.斜掠.pmultiplier*0.80))&target.time_to_die-remains>tick_time
    -- actions.generator+=/rake,cycle_targets=1,if=combo_points<5&(!ticking|(!talent.bloodtalons.enabled&remains<duration*0.3)|(talent.bloodtalons.enabled&buff.bloodtalons.up&(remains<=7)&persistent_multiplier>dot.rake.pmultiplier*0.80))&target.time_to_die-remains>tick_time
    -- 没有斜，或者有血爪且小于7秒，上斜掠 


    if buff.on("bloodtalons") and dot.remains("rake") <= 7 then
        debug_print("有血爪且小于7秒，上斜掠 ")
        stronger_rake = true
        return cast.byname("rake")
    end

    if dot.down("rake") then
        debug_print("没有斜掠，上斜掠 ")
        stronger_rake = false
        print("垃圾斜掠")
        return cast.byname("rake")
    end

    -- actions.generator+=/pool_resource,for_next=1

    -- # Brutal Slash if you would cap out charges before the next adds spawn
    -- actions.generator+=/撕碎,if=连击点<5&(spell_targets.横扫<3|talent.野蛮挥砍.enabled)
    -- actions.generator+=/shred,if=combo_points<5&(spell_targets.swipe_cat<3|talent.brutal_slash.enabled)
    -- 连击点<5 撕碎
    debug_print("连击点<5 撕碎")
    return cast.byname("shred")
end










end