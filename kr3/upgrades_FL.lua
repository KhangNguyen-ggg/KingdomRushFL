-- chunkname: @./kr3/upgrades.lua

local log = require("klua.log"):new("upgrades")
local km = require("klua.macros")
local E = require("entity_db")
local bit = require("bit")
local balance = require("balance/balance")
local storage = require("storage")
local enemy_enhance = require("enemy_enhance")
local bor = bit.bor
local scripts = require("upgrade_scripts3")
local scripts_rebbborn = require("game_scripts-1-rebbborn")

require("constants")

local function T(name)
	return E:get_template(name)
end

local function ensure_template(name, base)
	return E.entities[name] or E:register_t(name, base)
end

local function fts(v)
	return v / FPS
end

local function v(v1, v2)
	return {
		x = v1,
		y = v2
	}
end

local function r(x, y, w, h)
	return {
		pos = v(x, y),
		size = v(w, h)
	}
end

local epsilon = 1e-09
local upgrades_FL = {}


function upgrades_FL:range_g4()
-- 本函数只切换到4代原版的无科技射程；GXR-1统一由upgrades.lua结算。
--401 萨满
	T("tower_orc_shaman_lvl1").attacks.range = 185
	T("tower_orc_shaman_lvl2").attacks.range = 185
	T("tower_orc_shaman_lvl3").attacks.range = 185
	T("tower_orc_shaman_lvl4").attacks.range = 185
	T("tower_orc_shaman_lvl4").attacks.list[2].range = 185
--402 兽人
	T("tower_orc_warriors_den_lvl1").barrack.rally_range = 145
	T("tower_orc_warriors_den_lvl2").barrack.rally_range = 145
	T("tower_orc_warriors_den_lvl3").barrack.rally_range = 145
	T("tower_orc_warriors_den_lvl4").barrack.rally_range = 145
--403 回旋镖
	T("tower_goblirang_lvl1").attacks.range = 175
	T("tower_goblirang_lvl2").attacks.range = 175
	T("tower_goblirang_lvl3").attacks.range = 175
	T("tower_goblirang_lvl4").attacks.range = 175
--404 火骑
	T("tower_rocket_riders_lvl1").attacks.range = 165
	T("tower_rocket_riders_lvl2").attacks.range = 180
	T("tower_rocket_riders_lvl3").attacks.range = 190
	T("tower_rocket_riders_lvl4").attacks.range = 200
	T("tower_rocket_riders_lvl1").attacks.list[1].range = 165
	T("tower_rocket_riders_lvl2").attacks.list[1].range = 180
	T("tower_rocket_riders_lvl3").attacks.list[1].range = 190
	T("tower_rocket_riders_lvl4").attacks.list[1].range = 200
--405 飞艇
	T("soldier_balloon_lvl1").attacks.list[1].max_range = 105
	T("soldier_balloon_lvl2").attacks.list[1].max_range = 105
	T("soldier_balloon_lvl3").attacks.list[1].max_range = 105
	T("soldier_balloon_lvl4").attacks.list[1].max_range = 105
	T("tower_balloon_lvl4").barrack.rally_range = 190
--406 火法
	T("tower_infernal_mage_lvl1").attacks.range = 175
	T("tower_infernal_mage_lvl2").attacks.range = 175
	T("tower_infernal_mage_lvl3").attacks.range = 175
	T("tower_infernal_mage_lvl4").attacks.range = 175
	T("tower_infernal_mage_lvl4").attacks.list[2].range = 150
	T("tower_infernal_mage_lvl4").attacks.list[3].range = 150
	T("tower_infernal_mage_lvl4").attacks.list[4].range = 150
--407 黑弓
	T("tower_shadow_archer_lvl1").attacks.range = 150
	T("tower_shadow_archer_lvl2").attacks.range = 165
	T("tower_shadow_archer_lvl3").attacks.range = 180
	T("tower_shadow_archer_lvl4").attacks.range = 200
--408 死灵墓
	T("tower_spirit_mausoleum_lvl1").attacks.range = 175
	T("tower_spirit_mausoleum_lvl2").attacks.range = 175
	T("tower_spirit_mausoleum_lvl3").attacks.range = 175
	T("tower_spirit_mausoleum_lvl4").attacks.range = 175
--409 熔炉
	T("tower_melting_furnace_lvl1").attacks.range = 160
	T("tower_melting_furnace_lvl2").attacks.range = 160
	T("tower_melting_furnace_lvl3").attacks.range = 160
	T("tower_melting_furnace_lvl4").attacks.range = 160
--410 黑骑
	T("tower_dark_knights_lvl1").barrack.rally_range = 145
	T("tower_dark_knights_lvl2").barrack.rally_range = 145
	T("tower_dark_knights_lvl3").barrack.rally_range = 145
	T("tower_dark_knights_lvl4").barrack.rally_range = 145
--411 僵尸
	T("tower_grim_cemetery_lvl1").attacks.range = 165
	T("tower_grim_cemetery_lvl2").attacks.range = 165
	T("tower_grim_cemetery_lvl3").attacks.range = 165
	T("tower_grim_cemetery_lvl4").attacks.range = 165
--412 骨塔
	T("tower_bone_flingers_lvl1").attacks.range = 150
	T("tower_bone_flingers_lvl2").attacks.range = 150
	T("tower_bone_flingers_lvl3").attacks.range = 150
	T("tower_bone_flingers_lvl4").attacks.range = 150
--413 红钻
	T("tower_blazing_watcher_lvl1").attacks.range = 160
	T("tower_blazing_watcher_lvl2").attacks.range = 160
	T("tower_blazing_watcher_lvl3").attacks.range = 160
	T("tower_blazing_watcher_lvl4").attacks.range = 160
--414 腐森
	T("tower_rotten_forest_lvl4").attacks.list[2].range = 160
	T("tower_rotten_forest_lvl1").attacks.range = 160
	T("tower_rotten_forest_lvl2").attacks.range = 160
	T("tower_rotten_forest_lvl3").attacks.range = 160
	T("tower_rotten_forest_lvl4").attacks.range = 160
--415 女巫
	T("tower_wicked_sisters_lvl1").barrack.rally_range = 125
	T("tower_wicked_sisters_lvl2").barrack.rally_range = 125
	T("tower_wicked_sisters_lvl3").barrack.rally_range = 125
	T("tower_wicked_sisters_lvl4").barrack.rally_range = 125
	T("tower_wicked_sisters_lvl4").attacks.list[1].max_range = {[0]=140,[1]=140,[2]=140}
	T("tower_wicked_sisters_lvl4").powers.range.range = {175,225}
--416 骚扰
	T("tower_twilight_elves_barrack_lvl1").barrack.rally_range = 180
	T("tower_twilight_elves_barrack_lvl2").barrack.rally_range = 180
	T("tower_twilight_elves_barrack_lvl3").barrack.rally_range = 180
	T("tower_twilight_elves_barrack_lvl4").barrack.rally_range = 180
--417 环礁
	T("tower_deep_devils_lvl1").attacks.range = 150
	T("tower_deep_devils_lvl1").attacks.list[1].range = 150
	T("tower_deep_devils_lvl1").barrack.rally_range = 145
	T("tower_deep_devils_lvl2").attacks.range = 150
	T("tower_deep_devils_lvl2").attacks.list[1].range = 150
	T("tower_deep_devils_lvl2").barrack.rally_range = 145
	T("tower_deep_devils_lvl3").attacks.range = 150
	T("tower_deep_devils_lvl3").attacks.list[1].range = 150
	T("tower_deep_devils_lvl3").barrack.rally_range = 145
	T("tower_deep_devils_lvl4").attacks.range = 150
	T("tower_deep_devils_lvl4").attacks.list[1].range = 150
	T("tower_deep_devils_lvl4").barrack.rally_range = 145
--418 少林
	T("tower_shaolin_lvl1").attacks.range = 160
	T("tower_shaolin_lvl2").attacks.range = 160
	T("tower_shaolin_lvl3").attacks.range = 160
	T("tower_shaolin_lvl4").attacks.range = 160
--419 沼巨
	--无
--420 火山
	T("tower_ignis_altar_lvl1").attacks.range = 150
	T("tower_ignis_altar_lvl1").attacks.list[1].range = 150
	T("tower_ignis_altar_lvl2").attacks.range = 165
	T("tower_ignis_altar_lvl2").attacks.list[1].range = 165
	T("tower_ignis_altar_lvl3").attacks.range = 180
	T("tower_ignis_altar_lvl3").attacks.list[1].range = 180
	T("tower_ignis_altar_lvl4").attacks.range = 195
	T("tower_ignis_altar_lvl4").attacks.list[1].range = 195
--421 沙虫
	T("tower_sandworm_lvl1").attacks.range = 150
	T("tower_sandworm_lvl1").attacks.list[1].range = 150
	T("tower_sandworm_lvl2").attacks.range = 150
	T("tower_sandworm_lvl2").attacks.list[1].range = 150
	T("tower_sandworm_lvl3").attacks.range = 150
	T("tower_sandworm_lvl3").attacks.list[1].range = 150
	T("tower_sandworm_lvl4").attacks.range = 150
	T("tower_sandworm_lvl4").attacks.list[1].range = 150
--422 沉船
	T("tower_ogre_shipwreck_lvl3").attacks.range = 150
	T("tower_ogre_shipwreck_lvl3").attacks.list[1].range = 150
	T("tower_ogre_shipwreck_lvl4").attacks.range = 200
	T("tower_ogre_shipwreck_lvl4").attacks.list[1].range = 200
end

function upgrades_FL:enhance1()
--101 游侠
	T("tower_ranger").powers.poison.price_base = 250
	T("arrow_ranger").bullet.hit_distance = 32
	T("tower_ranger").powers.poison.price_inc = 125
	T("mod_ranger_poison").dps.damage_inc = 12
	T("mod_ranger_poison").dps.damage_max = 4
	T("mod_ranger_poison").dps.damage_min = 4
	T("aura_ranger_thorn").aura.max_times = 99
	T("aura_ranger_thorn").aura.max_count = 1
	T("aura_ranger_thorn").aura.max_count_inc = 3
	T("aura_ranger_thorn").aura.min_count = 1
	T("mod_thorn").max_times_applied = 99
	T("mod_thorn").damage_min = 60
	T("mod_thorn").damage_max = 60
--102 火枪
	T("shotgun_musketeer_sniper").bullet.damage_type = bor(DAMAGE_TRUE, DAMAGE_FX_EXPLODE)
	T("tower_musketeer").attacks.list[4].cooldown = 6
	T("tower_musketeer").attacks.list[4].range = T("tower_musketeer").attacks.range * 0.625
	T("tower_musketeer").powers.sniper.price_base = 250
	T("tower_musketeer").powers.sniper.price_inc = 175
	T("tower_musketeer").powers.shrapnel.price_base = 315
	T("tower_musketeer").powers.shrapnel.price_inc = 315
	T("shotgun_musketeer").bullet.damage_max = 115
	T("shotgun_musketeer").bullet.damage_min = 25
	T("bomb_musketeer").bullet.damage_max_inc = 32
	T("bomb_musketeer").bullet.damage_min_inc = 12
	T("bomb_musketeer").bullet.damage_max = 0
	T("bomb_musketeer").bullet.damage_min = 0
--103 圣骑
	--T("soldier_paladin").health.dead_lifetime = 12
	T("tower_paladin").powers.healing.price_base = 80
	T("tower_paladin").powers.healing.price_inc = 80
	T("tower_paladin").powers.shield.price_base = 110
	T("tower_paladin").powers.holystrike.price_base = 145
	T("tower_paladin").powers.holystrike.price_inc = 100
	T("soldier_paladin").melee.attacks[3].damage_type = DAMAGE_TRUE
	T("soldier_paladin").melee.attacks[3].damage_radius = 75
	T("soldier_paladin").melee.attacks[3].chance = 0.3
	
--104 蛮子
	T("tower_barbarian").powers.dual.price_base = 100
	T("tower_barbarian").powers.nets.price_base = 200
	T("tower_barbarian").powers.throwing.price_inc = 75

	T("soldier_barbarian").health.hp_max = 375
	--T("soldier_barbarian").health.dead_lifetime = 9
	T("soldier_barbarian").ranged.attacks[1].cooldown = 2
	T("soldier_barbarian").melee.attacks[1].damage_inc = 16
	T("soldier_barbarian").melee.attacks[2].chance = 0.1
	T("soldier_barbarian").melee.attacks[2].chance_inc = 0.1
	T("soldier_barbarian").melee.attacks[2].damage_radius = 65
--105 奥术
	T("mod_ray_arcane").dps.damage_min = 83
	T("mod_ray_arcane").dps.damage_max = 163
	T("mod_teleport_arcane").nodes_offset_max = -24
	T("mod_teleport_arcane").nodes_offset_min = -33
	T("mod_teleport_arcane").max_times_applied = 5
	T("tower_arcane_wizard").powers.disintegrate.cooldown_base = 28
	T("tower_arcane_wizard").powers.disintegrate.cooldown_inc = -4
	T("tower_arcane_wizard").powers.disintegrate.price_base = 375
	T("tower_arcane_wizard").powers.disintegrate.price_inc = 100
	T("tower_arcane_wizard").main_script.update = scripts.tower_arcane_wizard99.update
--106 黄法
	T("tower_sorcerer").powers.polymorph.price_base = 350
	T("tower_sorcerer").powers.polymorph.price_inc = 235
	T("mod_sorcerer_curse_dps").dps.damage_min = 11
	T("mod_sorcerer_curse_dps").dps.damage_max = 11
	T("mod_sorcerer_curse_dps").modifier.duration = 7
	T("mod_sorcerer_curse_armor").modifier.duration = 7
	T("mod_sorcerer_curse_marmor").modifier.duration = 7
	T("bolt_sorcerer").bullet.mods = {
	"mod_sorcerer_curse_dps",
	"mod_sorcerer_curse_armor",
	"mod_sorcerer_curse_marmor"
	}
	local sheep_big_ground = ensure_template("enemy_sheep_sorcerer_big_ground", "enemy_sheep_ground")

	sheep_big_ground.main_script.update = scripts.enemy_sheep_sorcerer_enhanced.update
	sheep_big_ground.motion.max_speed = 3
	sheep_big_ground.render.sprites[1].scale = v(2, 2)
	sheep_big_ground.clicks_to_destroy = 3

	local sheep_big_fly = ensure_template("enemy_sheep_sorcerer_big_fly", "enemy_sheep_fly")

	sheep_big_fly.main_script.update = scripts.enemy_sheep_sorcerer_enhanced.update
	sheep_big_fly.motion.max_speed = 3
	sheep_big_fly.render.sprites[1].scale = v(2, 2)
	sheep_big_fly.clicks_to_destroy = 3

	local sheep_chain_ground = ensure_template("enemy_sheep_sorcerer_chain_ground", "enemy_sheep_ground")

	sheep_chain_ground.main_script.update = scripts.enemy_sheep_sorcerer_enhanced.update
	sheep_chain_ground.render.sprites[1].scale = nil
	sheep_chain_ground.sorcerer_polymorph_splash = nil
	sheep_chain_ground.clicks_to_destroy = 3

	local sheep_chain_fly = ensure_template("enemy_sheep_sorcerer_chain_fly", "enemy_sheep_fly")

	sheep_chain_fly.main_script.update = scripts.enemy_sheep_sorcerer_enhanced.update
	sheep_chain_fly.render.sprites[1].scale = nil
	sheep_chain_fly.sorcerer_polymorph_splash = nil
	sheep_chain_fly.clicks_to_destroy = 3

	local polymorph_chain = ensure_template("mod_polymorph_sorcerer_chain", "mod_polymorph_sorcerer")

	polymorph_chain.main_script.insert = scripts.mod_polymorph_sorcerer_enhanced.insert
	polymorph_chain.polymorph.custom_entity_names.default = "enemy_sheep_sorcerer_chain_ground"
	polymorph_chain.polymorph.custom_entity_names.enemy_demon_imp = "enemy_sheep_sorcerer_chain_fly"
	polymorph_chain.polymorph.custom_entity_names.enemy_gargoyle = "enemy_sheep_sorcerer_chain_fly"
	polymorph_chain.polymorph.custom_entity_names.enemy_rocketeer = "enemy_sheep_sorcerer_chain_fly"
	polymorph_chain.polymorph.custom_entity_names.enemy_witch = "enemy_sheep_sorcerer_chain_fly"
	polymorph_chain.polymorph.transfer_speed_factor = 1
	polymorph_chain.polymorph.transfer_lives_cost_factor = 0
	polymorph_chain.polymorph.transfer_gold_factor = 1
	polymorph_chain.polymorph.transfer_health_factor = 0.5
	polymorph_chain.polymorph.fixed_speed = nil
	polymorph_chain.polymorph.splash_counts = nil
	polymorph_chain.polymorph.splash_mod = nil
	polymorph_chain.polymorph.splash_radius = nil

	local polymorph_main = T("mod_polymorph_sorcerer")

	polymorph_main.main_script.insert = scripts.mod_polymorph_sorcerer_enhanced.insert
	polymorph_main.polymorph.custom_entity_names.default = "enemy_sheep_sorcerer_big_ground"
	polymorph_main.polymorph.custom_entity_names.enemy_demon_imp = "enemy_sheep_sorcerer_big_fly"
	polymorph_main.polymorph.custom_entity_names.enemy_gargoyle = "enemy_sheep_sorcerer_big_fly"
	polymorph_main.polymorph.custom_entity_names.enemy_rocketeer = "enemy_sheep_sorcerer_big_fly"
	polymorph_main.polymorph.custom_entity_names.enemy_witch = "enemy_sheep_sorcerer_big_fly"
	polymorph_main.polymorph.transfer_speed_factor = 1
	polymorph_main.polymorph.transfer_lives_cost_factor = 0
	polymorph_main.polymorph.transfer_gold_factor = 1
	polymorph_main.polymorph.transfer_health_factor = 0.5
	polymorph_main.polymorph.fixed_speed = 10
	polymorph_main.polymorph.splash_counts = {
		1,
		3,
		6
	}
	polymorph_main.polymorph.splash_mod = "mod_polymorph_sorcerer_chain"
	polymorph_main.polymorph.splash_radius = 100
	T("enemy_sheep_ground").clicks_to_destroy = 3
	T("enemy_sheep_fly").clicks_to_destroy = 3
--107 巨炮
	T("tower_bfg").attacks.list[1].cooldown = 3.5
	T("tower_bfg").attacks.list[2].cooldown = 7
	T("tower_bfg").attacks.list[2].cooldown_mixed = 7
	T("tower_bfg").powers.missile.price_inc = 150
	T("bomb_bfg").bullet.damage_max = 120
	T("bomb_bfg").bullet.damage_min = 60
	T("bomb_bfg").bullet.damage_radius = 75
	T("missile_bfg").bullet.damage_radius = 75
	T("missile_bfg").bullet.damage_min = 100
	T("missile_bfg").bullet.damage_max = 140
	T("bomb_bfg_fragment").bullet.damage_max = 146
	T("bomb_bfg_fragment").bullet.damage_min = 126
	T("bomb_bfg_fragment").bullet.damage_radius = 75
--108 电塔
	T("ray_tesla").bounce_range = 125
	T("mod_ray_tesla").dps.cocos_cycles = 15
	T("mod_ray_tesla").modifier.allows_duplicates = true
	T("aura_tesla_overcharge").aura.radius = 181.5
end

function upgrades_FL:enhance2()
--201 图腾
	T("totem_silence").aura.radius = 115.5
	T("totem_silence").aura.duration = 1
	T("totem_silence").aura.duration_inc = 4
	T("tower_totem").powers.weakness.price_base = 225
	T("tower_totem").powers.weakness.price_inc = 100
	T("tower_totem").powers.silence.price_base = 120
	T("tower_totem").powers.silence.price_inc = 70
	T("totem_weakness").aura.radius = 115.5
	T("mod_weakness_totem").inflicted_damage_factor = 0.4
	T("mod_weakness_totem").received_damage_factor = 1.75
--202 弩堡
	T("tower_crossbow").attacks.range = 210
	T("tower_crossbow").attacks.list[2].shots = 2
	T("tower_crossbow").attacks.list[2].shots_inc = 4
	T("tower_crossbow").attacks.list[2].near_range = 128
	T("tower_crossbow").attacks.list[2].same_target_damage_factor_inc = 0.08
	T("tower_crossbow").attacks.list[2].use_eagle_critical = true
	T("tower_crossbow").attacks.list[2].critical_damage_factor = 2
	T("tower_crossbow").attacks.list[1].critical_chance = 0.1
	T("tower_crossbow").attacks.list[1].critical_chance_inc = 0.2
	T("tower_crossbow").powers.eagle.price_base = 250
	T("tower_crossbow").powers.eagle.price_inc = 200
	T("tower_crossbow").attacks.list[3].enemy_vulnerability_aura = "aura_crossbow_eagle_vulnerability_FL"
	T("arrow_crossbow").bullet.damage_min = 15
	T("arrow_crossbow").bullet.damage_max = 23
	T("tower_crossbow").attacks.list[3].range = 175
	T("tower_crossbow").attacks.list[3].range_inc = 35

	local crossbow_eagle_vulnerability = ensure_template("mod_crossbow_eagle_vulnerability_FL", "modifier")

	crossbow_eagle_vulnerability.received_damage_factors = {
		1.2,
		1.5,
		1.8
	}
	crossbow_eagle_vulnerability.modifier.duration = 0.75
	crossbow_eagle_vulnerability.modifier.replaces_lower = true
	crossbow_eagle_vulnerability.modifier.resets_same = true
	crossbow_eagle_vulnerability.modifier.vis_flags = F_MOD
	crossbow_eagle_vulnerability.modifier.vis_bans = 0
	crossbow_eagle_vulnerability.main_script.insert = scripts.mod_crossbow_eagle_vulnerability_FL.insert
	crossbow_eagle_vulnerability.main_script.remove = scripts.mod_crossbow_eagle_vulnerability_FL.remove
	crossbow_eagle_vulnerability.main_script.update = scripts.mod_track_target.update

	local crossbow_eagle_vulnerability_aura = ensure_template("aura_crossbow_eagle_vulnerability_FL", "aura")

	crossbow_eagle_vulnerability_aura.aura.mod = "mod_crossbow_eagle_vulnerability_FL"
	crossbow_eagle_vulnerability_aura.aura.cycle_time = 0.25
	crossbow_eagle_vulnerability_aura.aura.radius = 120
	crossbow_eagle_vulnerability_aura.aura.track_source = true
	crossbow_eagle_vulnerability_aura.aura.vis_flags = F_MOD
	crossbow_eagle_vulnerability_aura.aura.vis_bans = 0
	crossbow_eagle_vulnerability_aura.main_script.update = scripts.aura_crossbow_eagle_vulnerability_FL.update
--203 刺客
	--T("soldier_assassin").melee.attacks[2].damage_inc = 20
	--T("soldier_assassin").melee.attacks[2].damage_max = 30
	--T("soldier_assassin").melee.attacks[2].damage_min = 10
	T("soldier_assassin").melee.attacks[3].chance = 0.01
	T("soldier_assassin").melee.attacks[3].chance_inc = 0.02
	T("soldier_assassin").pickpocket.chance = 0
	T("soldier_assassin").pickpocket.chance_inc = 0.3
	T("soldier_assassin").pickpocket.steal_max = 6
	T("soldier_assassin").pickpocket.steal_min = 1
	T("soldier_assassin").health.hp_max = 290
--204 圣殿
	T("tower_templar").powers.extralife.price_base = 75
	T("tower_templar").powers.extralife.price_inc = 75
	T("soldier_templar").melee.attacks[2].chance = 0.5
	T("soldier_templar").revive.chance = 0
	T("soldier_templar").revive.chance_inc = 0.2
	T("soldier_templar").revive.health_recover = 0.05
	T("soldier_templar").revive.health_recover_inc = 0.25
	T("soldier_templar").health.hp_inc = 110
	T("soldier_templar").health.hp_max = 500
	T("soldier_templar").health.armor = 0
	T("soldier_templar").regen.health = 80
	T("soldier_templar").melee.attacks[2].mods = {"mod_tower_rotten_forest_fog_miss_2", "mod_bolverk_scream_2"}
--205 死灵
	T("g2_tower_mage_1").tower.price = 100
	T("g2_tower_mage_2").tower.price = 160
	T("g2_tower_mage_3").tower.price = 240
	T("tower_necromancer").tower.price = 250
	T("tower_necromancer").powers.rider.price_inc = 100
	T("tower_necromancer").powers.pestilence.price_base = 250
	T("tower_necromancer").powers.pestilence.price_inc = 130
	T("pestilence").aura.duration_inc = 2
	T("pestilence").aura.duration = 2
	T("mod_pestilence").dps.damage_min = 5
	T("mod_pestilence").dps.damage_max = 5
	T("bolt_necromancer").bullet.damage_min = 22
	T("bolt_necromancer").bullet.damage_max = 77
	T("tower_necromancer").attacks.list[2].cooldown = 9
--206 大法师
	T("tower_archmage").attacks.list[1].payload_chance = 1
	T("tower_archmage").powers.blast.price_base = 285
	T("tower_archmage").powers.blast.price_inc = 285
	T("bolt_blast").bullet.damage_radius = 50
	T("bolt_blast").bullet.damage_radius_inc = 7.5
	T("bolt_blast").bullet.magic_armor_ignore_factor = 0.4
	T("twister").damage_min = 130
	T("twister").damage_max = 130
	T("twister").damage_inc = 90
--207 地震
	T("tower_dwaarp").attacks.list[1].damage_min = 33
	T("tower_dwaarp").attacks.list[1].damage_max = 58
	T("tower_dwaarp").attacks.list[2].cooldown = 12
	T("tower_dwaarp").powers.drill.price_inc = 80
	T("tower_dwaarp").powers.lava.price_base = 380
	T("tower_dwaarp").powers.lava.price_inc = 320
	T("tower_dwaarp").main_script.update = scripts.tower_dwaarp99.update
	T("lava").aura.radius = 105
	T("mod_lava").dps.damage_min = 2
	T("mod_lava").dps.damage_max = 2
	T("mod_lava").dps.damage_inc = 3
	local lava_slow = ensure_template("mod_slow_dwaarp_lava_FL", "mod_slow")

	lava_slow.modifier.duration = 2
	lava_slow.modifier.resets_same = true
	lava_slow.slow.level_factors = { 0.8, 0.7, 0.6 }
	lava_slow.main_script.insert = scripts.mod_slow_dwaarp_lava_FL.insert
	lava_slow.main_script.update = scripts.mod_track_target.update
	lava_slow.main_script.remove = scripts.mod_slow.remove
	T("lava").aura.mods = { "mod_lava", "mod_slow_dwaarp_lava_FL" }
	T("mod_slow_dwaarp").modifier.duration = fts(50)
--208 高达
	--EMPTY BLOCK
	T("tower_mech").powers.missile.price_base = 230
	T("tower_mech").powers.missile.price_inc = 230
	T("tower_mech").powers.missile.max_level = 3
	T("soldier_mecha").idle_flip.cooldown = 20
	T("soldier_mecha").attacks.list[1].max_range = 138
	T("bomb_mecha").bullet.damage_min = 31
	T("bomb_mecha").bullet.damage_max = 51
	T("bomb_mecha").bullet.damage_radius = 64
	T("oil_mecha").aura.radius = 76.8
	
end

function upgrades_FL:enhance3()
	local scripts_rebbborn = require("game_scripts-1-rebbborn")
--301 蓝箭
	T("tower_arcane").powers.slumber.price_base = 180
	T("tower_arcane").powers.slumber.price_inc = 135
	T("mod_arrow_arcane").damage_min = 0.1
	T("mod_arrow_arcane").damage_max = 0.1
	T("aura_arcane_burst").aura.damage_inc = 125
	T("tower_arcane").main_script.update = scripts_rebbborn.tower_green_archer.update
	T("arrow_arcane_slumber").main_script.insert = scripts_rebbborn.arrow_green.insert
	T("arrow_arcane_slumber").extra_arrow = 2
	T("arrow_arcane_slumber").extra_arrows_range = 150
--302 金弓
	T("arrow_silver_long").bullet.damage_max = 87
	T("arrow_silver_long").bullet.damage_min = 33
	T("arrow_silver").bullet.damage_max = 39
	T("arrow_silver").bullet.damage_min = 15
	T("tower_silver").attacks.short_range = 200
	T("tower_silver").powers.sentence.chances = {{0.0105,0.021,0.0315},{0.0363,0.0726,0.1089}}
	T("tower_silver").attacks.list[3].vis_bans = 0
	T("tower_silver").powers.mark.price_inc = 150
	T("mod_arrow_silver_mark").received_damage_factor = 2.5

--303 红兵
	T("tower_blade").tower.price = 230
	T("tower_blade").powers.swirling.price_base = 300
	T("tower_blade").powers.perfect_parry.price_base = 50
	T("tower_blade").powers.perfect_parry.price_inc = 200
	T("soldier_blade").health.dead_lifetime = 13
	T("soldier_blade").health.hp_max = 225
	T("soldier_blade").dodge.chance_inc = 0.125

	--T("soldier_blade").health.dead_lifetime = 13
	T("soldier_blade").dodge.counter_attack.damage_max = 4
	T("soldier_blade").dodge.counter_attack.damage_min = 4
	T("soldier_blade").dodge.counter_attack.damage_inc = 6
	T("soldier_blade").powers.blade_dance.damage_inc = 50
	T("soldier_blade").powers.blade_dance.damage_max = {50,75,100}
	T("soldier_blade").powers.blade_dance.damage_min = {20,35,50}
	T("soldier_blade").timed_attacks.list[1].vis_bans = bor(F_BOSS, F_WATER)
--304 绿兵
	T("soldier_forest").health.hp_max = 350
	T("tower_forest").barrack.max_soldiers = 3
	T("tower_forest").tower.price = 243
	T("tower_forest").powers.circle.price_base = 185
	T("tower_forest").powers.circle.price_inc = 120
	T("tower_forest").powers.eerie.price_base = 135
	T("tower_forest").powers.eerie.price_inc = 105
	T("spear_forest").bullet.damage_max = 46
	T("spear_forest").bullet.damage_min = 30
	T("spear_forest_oak").bullet.damage_max = 25
	T("spear_forest_oak").bullet.damage_min = 25
	T("spear_forest_oak").bullet.damage_inc = 45
	T("mod_forest_circle").modifier.duration = 6
--305 狂法
	T("bolt_wild_magus").bullet.damage_same_target_inc = 1
	T("bolt_wild_magus").bullet.damage_same_target_max = 36
	T("bolt_wild_magus").bullet.stack_loss_on_new_target = 6
	T("bolt_wild_magus").bullet.stack_decay_time = 6
	T("bolt_wild_magus").bullet.stack_decay_loss = 6
	T("bolt_wild_magus").bullet.permanent_damage_on_stack_max = 1
	T("bolt_wild_magus").bullet.permanent_damage_bonus_max = 10
	T("bolt_wild_magus").bullet.damage_max = 20
	T("bolt_wild_magus").bullet.damage_min = 9
	T("tower_wild_magus").powers.ward.price_base = 275
	T("tower_wild_magus").powers.ward.price_inc = 200
	T("tower_wild_magus").powers.eldritch.cooldowns = {28,22.5,17}
	T("mod_eldritch").damage_levels = {144,324,468}
	T("bolt_elves_3").bullet.damage_min = 22
	T("bolt_elves_3").bullet.damage_max = 45
	T("bolt_elves_2").bullet.damage_min = 13
	T("bolt_elves_2").bullet.damage_max = 26
	T("bolt_elves_1").bullet.damage_min = 6
	T("bolt_elves_1").bullet.damage_max = 12
	T("mod_ward").modifier.duration = 999
--306 高冷
	T("bolt_high_elven_weak").bullet.damage_max = 42
	T("tower_high_elven").main_script.update = scripts.tower_high_elven99.update
	T("tower_high_elven").main_script.remove = scripts.tower_high_elven99.remove
	T("tower_high_elven").powers.timelapse.price_base = 400
	T("tower_high_elven").powers.timelapse.price_inc = 240
	T("bolt_high_elven_weak").bullet.damage_min = 21
	T("high_elven_sentinel").ranged.attacks[1].max_shots = 20
	T("ray_high_elven_sentinel").bullet.damage_max = 44
	T("ray_high_elven_sentinel").bullet.damage_min = 22
	T("mod_timelapse").damage_levels = {240,324,360}
	T("mod_timelapse").damage_type = bor(DAMAGE_TRUE, DAMAGE_NO_KILL)
--307 熊德	
	T("rock_1").bullet.damage_max = 15
	T("rock_1").bullet.damage_min = 8
	T("rock_2").bullet.damage_max = 40
	T("rock_2").bullet.damage_min = 20
	T("rock_3").bullet.damage_max = 60
	T("rock_3").bullet.damage_min = 30
	T("rock_druid").bullet.damage_max = 61
	T("rock_druid").bullet.damage_min = 46
	T("rock_druid").bullet.damage_radius = 56.82
	T("tower_druid").powers.sylvan.price_base = 250
	T("tower_druid").powers.sylvan.price_inc = 250
	--T("druid_shooter_sylvan").attacks.list[1].cooldown = 8
	T("druid_shooter_sylvan").main_script.update = scripts.druid_shooter_sylvan99.update
	T("mod_druid_sylvan").modifier.duration = 15
	T("soldier_druid_bear").health.armor = 0.2
	T("soldier_druid_bear").health.hp_max = 700
	T("soldier_druid_bear").health.dead_lifetime = 10
	T("soldier_druid_bear").regen.health = 35
--308 大树
	T("rock_entwood").bullet.damage_max = 143
	T("rock_entwood").bullet.damage_min = 85
	T("rock_entwood").bullet.damage_radius = 64
	T("rock_firey_nut").bullet.damage_radius = 80
	T("rock_firey_nut").bullet.damage_max_inc = 111
	T("rock_firey_nut").bullet.damage_min_inc = 111
	T("tower_entwood").attacks.list[2].cooldown = 16
	T("tower_entwood").powers.clobber.damage_values = {75,135,195}
	T("tower_entwood").powers.clobber.price_base = 225
	T("tower_entwood").powers.clobber.price_inc = 225
	T("tower_entwood").powers.fiery_nuts.price_base = 330
	T("tower_entwood").powers.fiery_nuts.price_inc = 330
	T("rock_firey_nut").bullet.damage_type = DAMAGE_TRUE
	T("rock_firey_nut").bullet.child_bullet = "rock_firey_nut_small_FL"
	T("rock_firey_nut").bullet.child_count = 3
	T("rock_firey_nut").bullet.child_node_prediction = true
	T("rock_firey_nut").bullet.child_random_x_to_dest = 30
	T("rock_firey_nut").bullet.child_random_y_to_dest = 20
	T("rock_firey_nut").bullet.child_vis_bans = F_FLYING
	T("rock_firey_nut").bullet.child_vis_flags = F_RANGED
	T("rock_firey_nut").main_script.update = scripts.rock_firey_nut_FL.update
	T("rock_firey_nut_small_FL").bullet.damage_radius = 66
	T("rock_firey_nut_small_FL").bullet.damage_max_inc = 22
	T("rock_firey_nut_small_FL").bullet.damage_min_inc = 22
	T("rock_firey_nut_small_FL").bullet.damage_type = DAMAGE_TRUE
	T("rock_firey_nut_small_FL").bullet.hit_payload = "aura_fiery_nut"
end

function upgrades_FL:enhance4()
--401 萨满
	T("bolt_orc_shaman_lvl1").bullet.damage_min = 6--110
	T("bolt_orc_shaman_lvl1").bullet.damage_max = 40--160
	T("bolt_orc_shaman_lvl2").bullet.damage_min = 20--110
	T("bolt_orc_shaman_lvl2").bullet.damage_max = 100--160
	T("bolt_orc_shaman_lvl3").bullet.damage_min = 30--110
	T("bolt_orc_shaman_lvl3").bullet.damage_max = 170--160
	T("bolt_orc_shaman_lvl4").bullet.damage_min = 80--110
	T("bolt_orc_shaman_lvl4").bullet.damage_max = 290--160
	T("orc_shaman_meteor").bullet.damage_max = 54
	T("orc_shaman_meteor").bullet.damage_min = 7
	T("orc_shaman_meteor").bullet.damage_min_inc = 14
	T("orc_shaman_meteor").bullet.damage_max_inc = 36
	T("orc_shaman_meteor").bullet.damage_radius = 55
	T("tower_orc_shaman_lvl4").powers.shock.price_base = 180--180
	T("tower_orc_shaman_lvl4").powers.shock.price_inc = 180--180
	T("bolt_shock").bullet.damage_inc_min = {4,9,14}
	T("bolt_shock").bullet.damage_inc_max = {38,76,114}
	T("bolt_shock").bullet.damage_type = DAMAGE_ELECTRICAL
	T("aura_orc_shaman_vines").aura.radius = 105
	T("tower_orc_shaman_lvl4").attacks.list[2].target_range = 105
	T("mod_orc_shaman_heal").hps.heal_min = 0
	T("mod_orc_shaman_heal").hps.heal_max = 0
	T("mod_orc_shaman_heal").hps.heal_inc = 2
--402 兽人
	T("soldier_orc_warrior_lvl1").melee.attacks[1].damage_max = 11
	T("soldier_orc_warrior_lvl1").melee.attacks[1].damage_min = 7
	T("soldier_orc_warrior_lvl2").melee.attacks[1].damage_max = 23
	T("soldier_orc_warrior_lvl2").melee.attacks[1].damage_min = 13
	T("soldier_orc_warrior_lvl3").melee.attacks[1].damage_max = 30
	T("soldier_orc_warrior_lvl3").melee.attacks[1].damage_min = 19
	T("soldier_orc_warrior_lvl4").melee.attacks[1].damage_max = 40
	T("soldier_orc_warrior_lvl4").melee.attacks[1].damage_min = 25
	T("soldier_orc_warrior_lvl4").melee.attacks[1].damage_maxbase = 40
	T("soldier_orc_warrior_lvl4").melee.attacks[1].damage_minbase = 25
	T("soldier_orc_warrior_lvl1").health.armor = 0.15
	T("soldier_orc_warrior_lvl2").health.armor = 0.24
	T("soldier_orc_warrior_lvl3").health.armor = 0.28
	T("soldier_orc_warrior_lvl4").health.armor = 0.32
	T("soldier_orc_warrior_lvl1").health.dead_lifetime = 8
	T("soldier_orc_warrior_lvl2").health.dead_lifetime = 8
	T("soldier_orc_warrior_lvl3").health.dead_lifetime = 8
	T("soldier_orc_warrior_lvl4").health.dead_lifetime = 8
	T("tower_orc_warriors_den_lvl4").powers.promotion.damage_min = 40
	T("tower_orc_warriors_den_lvl4").powers.promotion.damage_max = 60
	T("aura_orc_warrior_regen").hps.heal_inc = {12,25}
--403 回旋镖
	T("goblirang_big").radius = 42
	T("goblirang_lvl1").radius = 20
	T("goblirang_lvl2").radius = 22
	T("goblirang_lvl3").radius = 24
	T("goblirang_lvl4").radius = 26
	T("tower_goblirang_lvl4").attacks.list[2].cooldown = 8.4
	T("tower_goblirang_lvl4").attacks.list[3].cooldown = 14
	T("tower_goblirang_lvl4").powers.stun.mod_chance = {0.07,0.14,0.20}
--404 火骑
	T("bomb_rr_lvl1").bullet.damage_radius = 56.25
	T("bomb_rr_lvl2").bullet.damage_radius = 56.25
	T("bomb_rr_lvl3").bullet.damage_radius = 56.25
	T("bomb_rr_lvl4").bullet.damage_radius = 56.25
	T("bomb_rr_lvl1").bullet.hit_payload = "bomb_rr_lvl1_payload"
	T("bomb_rr_lvl2").bullet.hit_payload = "bomb_rr_lvl2_payload"
	T("bomb_rr_lvl3").bullet.hit_payload = "bomb_rr_lvl3_payload"
	T("bomb_rr_lvl4").bullet.hit_payload = "bomb_rr_lvl4_payload"
	T("bomb_rr_lvl1").bullet.hit_fx = "fx_explosion_big"
	T("bomb_rr_lvl2").bullet.hit_fx = "fx_explosion_big"
	T("bomb_rr_lvl3").bullet.hit_fx = "fx_explosion_big"
	T("bomb_rr_lvl4").bullet.hit_fx = "fx_explosion_big"
	--T("bomb_rr_lvl1").bullet.damage_max = 11
	--T("bomb_rr_lvl1").bullet.damage_min = 7
	--T("bomb_rr_lvl2").bullet.damage_max = 31
	--T("bomb_rr_lvl2").bullet.damage_min = 22
	--T("bomb_rr_lvl3").bullet.damage_max = 63
	--T("bomb_rr_lvl3").bullet.damage_min = 44
	--T("bomb_rr_lvl4").bullet.damage_max = 101
	--T("bomb_rr_lvl4").bullet.damage_min = 70
	T("tower_rocket_riders_lvl4").powers.mine.price_base = 161
	T("tower_rocket_riders_lvl4").powers.mine.price_inc = 161
	T("tower_rocket_riders_lvl4").powers.nitro.damage_inc = {228,342}
	T("bomb_rr_nitro").bullet.damage_radius = 120
	T("bomb_rr_mine").bullet.damage_inc = {90,187,285}
	T("bomb_rr_cluster").bullet.damage_inc = {44,64}
--405 飞艇
	T("tower_balloon_lvl4").powers.oil.price_base = 160
	T("tower_balloon_lvl4").powers.oil.price_inc = 160
	T("soldier_balloon_lvl1").attacks.list[1].max_range = 128
	T("soldier_balloon_lvl2").attacks.list[1].max_range = 128
	T("soldier_balloon_lvl3").attacks.list[1].max_range = 128
	T("soldier_balloon_lvl4").attacks.list[1].max_range = 128
	T("oil_balloon_lvl1").aura.duration = 12
	T("oil_balloon_lvl2").aura.duration = 12
	T("oil_balloon_lvl3").aura.duration = 12
	T("bomb_balloon_lvl1").bullet.damage_radius = 42.5
	T("bomb_balloon_lvl2").bullet.damage_radius = 42.5
	T("bomb_balloon_lvl3").bullet.damage_radius = 42.5
	T("bomb_balloon_lvl4").bullet.damage_radius = 42.5
--406 火法
	local scripts4 = require("game_scripts-40")
	local infernal_burn_mods = {
		"mod_lava_infernal_mage_lvl1",
		"mod_lava_infernal_mage_lvl2",
		"mod_lava_infernal_mage_lvl3",
		"mod_lava_infernal_mage_lvl4"
	}
	local infernal_burn_damage = {
		4,
		8,
		13,
		18
	}
	local infernal_burn_explosion_damage = {
		12,
		24,
		39,
		54
	}
	local infernal_burn_aura = ensure_template("aura_infernal_mage_burn_FL", "aura")

	infernal_burn_aura.aura.mod = infernal_burn_mods[4]
	infernal_burn_aura.aura.duration = fts(23)
	infernal_burn_aura.aura.apply_delay = fts(5)
	infernal_burn_aura.aura.apply_duration = fts(10)
	infernal_burn_aura.aura.cycle_time = fts(2)
	infernal_burn_aura.aura.max_count = 100
	infernal_burn_aura.aura.radius = 80
	infernal_burn_aura.aura.vis_flags = bor(F_RANGED, F_MOD)
	infernal_burn_aura.aura.vis_bans = bor(F_FRIEND, F_HERO)
	infernal_burn_aura.main_script.insert = scripts4.aura_infernal_mage_burn_FL.insert
	infernal_burn_aura.main_script.update = scripts4.aura_infernal_mage_burn_FL.update

	for i, mod_name in ipairs(infernal_burn_mods) do
		local burn = T(mod_name)

		burn.modifier.duration = 1.5
		burn.dps.damage_every = 0.4
		burn.dps.damage_min = infernal_burn_damage[i]
		burn.dps.damage_max = infernal_burn_damage[i]
		burn.dps.damage_inc = 0
		burn.dps.damage_type = DAMAGE_TRUE
		burn.dps.kill = true
		burn.death_explosion_radius = 42
		burn.death_explosion_damage = infernal_burn_explosion_damage
		burn.death_explosion_damage_type = DAMAGE_MAGICAL
		burn.death_explosion_fx = "fx_teleport_infernal"
		burn.death_spread_mods = infernal_burn_mods
		burn.main_script.remove = scripts4.mod_lava_infernal_mage_FL.remove
	end

	T("tower_infernal_mage_lvl1").attacks.min_cooldown = 1.75
	T("tower_infernal_mage_lvl2").attacks.min_cooldown = 1.75
	T("tower_infernal_mage_lvl3").attacks.min_cooldown = 1.75
	T("tower_infernal_mage_lvl4").attacks.min_cooldown = 1.75
	T("tower_infernal_mage_lvl1").attacks.list[1].cooldown = 1.75
	T("tower_infernal_mage_lvl2").attacks.list[1].cooldown = 1.75
	T("tower_infernal_mage_lvl3").attacks.list[1].cooldown = 1.75
	T("tower_infernal_mage_lvl4").attacks.list[1].cooldown = 1.75
	T("tower_infernal_mage_lvl4").attacks.list[2].cooldown = 17.5
	T("tower_infernal_mage_lvl4").attacks.list[2].vis_bans = 0--bor(F_FLYING)
	T("tower_infernal_mage_lvl4").attacks.list[3].cooldown = 17.5--bor(F_FLYING)
	T("bolt_infernal_mage_lvl1").bullet.mod = "mod_lava_infernal_mage_lvl1"
	T("bolt_infernal_mage_lvl1").bullet.damage_max = 3
	T("bolt_infernal_mage_lvl1").bullet.damage_min = 2
	T("bolt_infernal_mage_lvl2").bullet.mod = "mod_lava_infernal_mage_lvl2"
	T("bolt_infernal_mage_lvl2").bullet.damage_max = 13
	T("bolt_infernal_mage_lvl2").bullet.damage_min = 8
	T("bolt_infernal_mage_lvl3").bullet.mod = "mod_lava_infernal_mage_lvl3"
	T("bolt_infernal_mage_lvl3").bullet.damage_max = 46
	T("bolt_infernal_mage_lvl3").bullet.damage_min = 25
	T("bolt_infernal_mage_lvl4").bullet.mod = "mod_lava_infernal_mage_lvl4"
	T("bolt_infernal_mage_lvl4").bullet.damage_max = 56
	T("bolt_infernal_mage_lvl4").bullet.damage_min = 34
	T("fissure_infernal_mage").bullet.hit_distance = 75
	T("aura_lava_fissure").aura.radius = 45
	T("tower_infernal_mage_lvl4").attacks.list[2].burn_level = 4
	T("tower_infernal_mage_lvl4").attacks.list[2].burn_mods = infernal_burn_mods
	T("tower_infernal_mage_lvl4").attacks.list[3].burn_level = 4
	T("tower_infernal_mage_lvl4").attacks.list[3].burn_aura = "aura_infernal_mage_burn_FL"
	T("tower_infernal_mage_lvl4").attacks.list[3].burn_mods = infernal_burn_mods
	T("tower_infernal_mage_lvl4").attacks.list[4].burn_level = 4
	T("tower_infernal_mage_lvl4").attacks.list[4].burn_aura = "aura_infernal_mage_burn_FL"
	T("tower_infernal_mage_lvl4").attacks.list[4].burn_mods = infernal_burn_mods
	T("mod_teleport_infernal").nodes_offset_min = -30
	T("mod_teleport_infernal").nodes_offset_max = -30
	T("aura_curse_infernal").aura.radius = 80
	T("mod_infernal_curse_armor").modifier.duration = 15
	T("mod_infernal_curse_magic_armor").modifier.duration = 15
--407 黑弓
	T("arrow_shadow_tower_lvl1").bullet.reduce_armor = 0.75
	T("arrow_shadow_tower_lvl2").bullet.reduce_armor = 0.75
	T("arrow_shadow_tower_lvl3").bullet.reduce_armor = 0.75
	T("arrow_shadow_tower_lvl4").bullet.reduce_armor = 0.75
	T("tower_shadow_archer_lvl4").attacks.list[2].cooldowns = {36,29,22}
	T("tower_shadow_archer_lvl4").powers.mark.price_base = 155
	T("tower_shadow_archer_lvl4").powers.mark.price_inc = 155
	T("mod_arrow_shadow_mark").modifier.durations = {6,7.5,9}
	T("tower_shadow_archer_lvl4").attacks.list[3].cooldown = 14
	T("tower_shadow_archer_lvl4").powers.crow.damage_min = 18
	T("tower_shadow_archer_lvl4").powers.crow.damage_max = 18
	T("tower_shadow_archer_lvl4").powers.blade.price_base = 200
	T("tower_shadow_archer_lvl4").powers.blade.price_inc = 100
--408 死灵墓
	T("fallen_ones_gargoyle").health.hp_max = 390
	--T("tower_spirit_mausoleum_lvl4").powers.spectral_communion.cooldown_inc = -0.25
	T("tower_spirit_mausoleum_lvl4").powers.spectral_communion.bullet_list = {"tower_spirit_mausoleum_lvl4_bolt", "tower_spirit_mausoleum_lvl4_bolt"}
	T("tower_spirit_mausoleum_lvl4").powers.spectral_communion.death_controller = "controller_spirit_mausoleum_spectral_death_FL"
	T("tower_spirit_mausoleum_lvl4").powers.spectral_communion.death_radius = 200
	T("tower_spirit_mausoleum_lvl4").powers.spectral_communion.price_inc = 340
	T("tower_spirit_mausoleum_lvl4").powers.spectral_communion.price_base = 340
	T("tower_spirit_mausoleum_lvl4").powers.possession.cooldown = {25,24,23}
	T("tower_spirit_mausoleum_lvl4").powers.possession.max_targets = {1,2,3}
	T("tower_spirit_mausoleum_lvl4").powers.possession.price_base = 230
	T("tower_spirit_mausoleum_lvl4").powers.possession.price_inc = 230
	T("mod_possession").possession_duration = {12,13,14}
	T("mod_possession_skill").possession_duration = {12,13,14}

	local scripts45 = require("game_scripts-45")
	local spectral_death_bolt = ensure_template("bolt_spirit_mausoleum_spectral_death_FL", "bolt_possession")
	spectral_death_bolt.bullet.damage_type = DAMAGE_MAGICAL
	spectral_death_bolt.bullet.damage_factor = 1
	spectral_death_bolt.bullet.damage_min = 29
	spectral_death_bolt.bullet.damage_max = 43
	spectral_death_bolt.bullet.mod = nil
	spectral_death_bolt.bullet.mods = nil
	spectral_death_bolt.sound_events.insert = nil
	spectral_death_bolt.sound_events.hit = nil

	local spectral_death_controller = ensure_template("controller_spirit_mausoleum_spectral_death_FL", "aura")
	spectral_death_controller.aura.bullet = "bolt_spirit_mausoleum_spectral_death_FL"
	spectral_death_controller.aura.radius = 200
	spectral_death_controller.aura.target_range = 10000
	spectral_death_controller.aura.damage_min = {29,58}
	spectral_death_controller.aura.damage_max = {43,86}
	spectral_death_controller.aura.hp_damage_factors = {0.03,0.08}
	spectral_death_controller.aura.damage_type = DAMAGE_MAGICAL
	spectral_death_controller.aura.vis_flags = F_RANGED
	spectral_death_controller.aura.vis_bans = 0
	spectral_death_controller.main_script.update = scripts45.controller_spirit_mausoleum_spectral_death_FL.update
--409 熔炉
	T("lava_furnace").aura.damage_type = DAMAGE_EXPLOSION
	T("mod_furnace_stun").modifier.duration = 0.8
	--T("mod_furnace_fuel").effect.damage_min = 96
	--T("mod_furnace_fuel").effect.damage_max = 114
	T("tower_melting_furnace_lvl1").attacks.list[1].cooldown = 3.5
	T("tower_melting_furnace_lvl2").attacks.list[1].cooldown = 3.5
	T("tower_melting_furnace_lvl3").attacks.list[1].cooldown = 3.5
	T("tower_melting_furnace_lvl4").attacks.list[1].cooldown = 3.5
--410 黑骑
	T("soldier_dark_knight_lvl4").health.armor = 0.8
	T("soldier_dark_knight_lvl4").melee.attacks[1].cooldown = 1.2
	T("soldier_dark_knight_lvl4").melee.attacks[3].chance_inc = 0.026
	T("soldier_dark_knight_lvl4").health.hp_max = 230
	T("tower_dark_knights_lvl4").barrack.max_soldiers = 3
	T("tower_dark_knights_lvl4").powers.shield.price_base = 85
	T("dark_army_soldier_knight_lvl3").health.hp_max = 170
	T("dark_army_soldier_knight_lvl2").health.hp_max = 160
	T("tower_dark_knights_lvl2").barrack.max_soldiers = 2
	T("tower_dark_knights_lvl3").barrack.max_soldiers = 3
	T("soldier_dark_knight_lvl4").health.dark_damage_type = DAMAGE_TRUE
	--T("soldier_dark_knight_lvl4").melee.attacks[1].cooldown = 1
--411 僵尸
	T("tower_grim_cemetery_lvl1").tower.price = 70
	T("tower_grim_cemetery_lvl2").tower.price = 90
	T("tower_grim_cemetery_lvl3").tower.price = 90
	T("tower_grim_cemetery_lvl4").tower.price = 110
	T("grim_cemetery_aura_lvl1").max_skeletons_tower = 5
	T("grim_cemetery_aura_lvl2").max_skeletons_tower = 6
	T("grim_cemetery_aura_lvl3").max_skeletons_tower = 7
	T("grim_cemetery_aura_lvl4").max_skeletons_tower = 8
--412 骨塔
	T("bone_flingers_bone_lvl3").bullet.damage_min = 11
	T("bone_flingers_bone_lvl3").bullet.damage_max = 26
	T("bone_flingers_bone").bullet.damage_min = 17
	T("bone_flingers_bone").bullet.damage_max = 41
	T("tower_bone_flingers_lvl4").powers.skeleton.cooldown = {12, 8}
	T("tower_bone_flingers_lvl4").powers.milk.damage_inc = {8,18,28}
	T("bone_golem_bone_2").bullet.damage_min = 25
	T("bone_golem_bone_2").bullet.damage_max = 39
	T("bone_golem_bone_3").bullet.damage_min = 33
	T("bone_golem_bone_3").bullet.damage_max = 47
	T("bone_golem_bone_4").bullet.damage_min = 42
	T("bone_golem_bone_4").bullet.damage_max = 56
	T("soldier_bone_golem").ranged.attacks[1].max_range = 186.375
--413 红钻
	T("tower_blazing_watcher_lvl4").powers.disintegrate.price_base = 250
	T("tower_blazing_watcher_lvl4").powers.disintegrate.price_inc = 125
	T("tower_blazing_watcher_lvl4").powers.disintegrate.cooldown = {25,20,15}
	T("tower_blazing_watcher_lvl4").powers.disintegrate.cooldown = {25,20,15}
	T("tower_blazing_watcher_lvl4").attack_stage_max = 10
	T("tower_blazing_watcher_lvl1").attacks.extra_range = 30
	T("tower_blazing_watcher_lvl2").attacks.extra_range = 35
	T("tower_blazing_watcher_lvl3").attacks.extra_range = 40
	T("tower_blazing_watcher_lvl4").attacks.extra_range = 45
--414 腐森
	--T("mod_tower_rotten_forest_burst_damage").dps.damage_type = DAMAGE_EXPLOSION
	T("mod_rf_thorn").damage_min = 25
	T("mod_rf_thorn").damage_max = 25
--415 女巫
	T("proy_pink_lvl1").bullet.damage_min = 24
	T("proy_pink_lvl2").bullet.damage_min = 61
	T("proy_pink_lvl3").bullet.damage_min = 108
	T("proy_pink_lvl4").bullet.damage_min = 176
--416 骚扰
	T("tower_twilight_elves_barrack_lvl4").barrack.max_soldiers = 3
	T("elves_soldier_harasser_lvl4").melee.attacks[1].damage_max = 31
	T("elves_soldier_harasser_lvl4").melee.attacks[1].damage_min = 18
	T("elves_soldier_harasser_lvl4").melee.attacks[2].damage_max = 31
	T("elves_soldier_harasser_lvl4").melee.attacks[2].damage_min = 18
	T("elves_soldier_harasser_arrow_lvl4").bullet.damage_max = 31
	T("elves_soldier_harasser_arrow_lvl4").bullet.damage_min = 18
--417 环礁
	T("tower_deep_devils_lvl4").powers.storm.damage_count = 20
	T("tower_deep_devils_lvl4").powers.storm.damage = {30, 61, 92}
	T("tower_deep_devils_lvl4").powers.storm.price_base = 290
	T("tower_deep_devils_lvl4").powers.storm.price_inc = 290
	T("high_elven_sentinel_dd").ranged.attacks[1].max_shots = 20
	T("high_elven_sentinel_dd").charge_time = 8
	T("ray_high_elven_sentinel_dd3").bullet.damage_min = 92
	T("ray_high_elven_sentinel_dd3").bullet.damage_max = 92
	T("ray_high_elven_sentinel_dd2").bullet.damage_min = 61
	T("ray_high_elven_sentinel_dd2").bullet.damage_max = 61
	T("mod_ray_high_elven_sentinel_hit_dd").modifier.duration = fts(20)
--418 少林
	T("bullet_shaolin_lvl1").bullet.damage_max = 4
	T("bullet_shaolin_lvl1").bullet.damage_min = 3
	T("bullet_shaolin_lvl2").bullet.damage_max = 14
	T("bullet_shaolin_lvl2").bullet.damage_min = 9
	T("bullet_shaolin_lvl3").bullet.damage_max = 23
	T("bullet_shaolin_lvl3").bullet.damage_min = 14
	T("bullet_shaolin_lvl4").bullet.damage_max = 36
	T("bullet_shaolin_lvl4").bullet.damage_min = 22
	T("tower_shaolin_lvl1").main_script.update = scripts.tower_shaolin99.update
	T("tower_shaolin_lvl2").main_script.update = scripts.tower_shaolin99.update
	T("tower_shaolin_lvl3").main_script.update = scripts.tower_shaolin99.update
	T("tower_shaolin_lvl4").main_script.update = scripts.tower_shaolin99.update
--419 沼巨
	T("swamp_monster_soldier_lvl1").vis.bans = bor(F_LYCAN,F_INSTAKILL,F_POLYMORPH,F_DISINTEGRATED,F_POISON, F_EAT)
	T("swamp_monster_soldier_lvl2").vis.bans = bor(F_LYCAN,F_INSTAKILL,F_POLYMORPH,F_DISINTEGRATED,F_POISON, F_EAT)
	T("swamp_monster_soldier_lvl3").vis.bans = bor(F_LYCAN,F_INSTAKILL,F_POLYMORPH,F_DISINTEGRATED,F_POISON, F_EAT)
	T("swamp_monster_soldier_lvl4").vis.bans = bor(F_LYCAN,F_INSTAKILL,F_POLYMORPH,F_DISINTEGRATED,F_POISON, F_EAT)
	T("swamp_monster_soldier_lvl1").vis.flags = bor(T("swamp_monster_soldier_lvl1").vis.flags,F_HERO)
	T("swamp_monster_soldier_lvl2").vis.flags = bor(T("swamp_monster_soldier_lvl2").vis.flags,F_HERO)
	T("swamp_monster_soldier_lvl3").vis.flags = bor(T("swamp_monster_soldier_lvl3").vis.flags,F_HERO)
	T("swamp_monster_soldier_lvl4").vis.flags = bor(T("swamp_monster_soldier_lvl4").vis.flags,F_HERO)
	T("tower_swamp_monster_lvl4").powers.eat.price_base = 80
	T("swamp_monster_soldier_lvl1").melee.attacks[1].count = 15
	T("swamp_monster_soldier_lvl2").melee.attacks[1].count = 15
	T("swamp_monster_soldier_lvl3").melee.attacks[1].count = 15
	T("swamp_monster_soldier_lvl4").melee.attacks[1].count = 15
--420 火山
	T("soldier_lavagolem").health.armor = 0.7
	T("soldier_lavagolem").health.hp_max = 292
--421 沙虫
	T("bullet_tower_sandworm_lvl1").bullet.damage_radius = 55
	T("bullet_tower_sandworm_lvl2").bullet.damage_radius = 55
	T("bullet_tower_sandworm_lvl3").bullet.damage_radius = 55
	T("bullet_tower_sandworm_lvl4").bullet.damage_radius = 55
	T("tower_sandworm_lvl4").powers.eat.price_base = 340
	T("tower_sandworm_lvl4").attacks.list[2].cooldown = 42
	T("tower_sandworm_eat").bullet.damage_radius = 87.5
	T("tower_sandworm_spit").bullet.damage_max = 0
	T("tower_sandworm_spit").bullet.damage_min = 0
	T("tower_sandworm_spit").bullet.damage_min_inc = 76
	T("tower_sandworm_spit").bullet.damage_max_inc = 76
--422 沉船
	T("bullet_tower_ogre_shipwreck_skill2").bullet.damage_max = 36
	T("bullet_tower_ogre_shipwreck_skill2").bullet.damage_min = 36
	T("tower_ogre_shipwreck_lvl4").powers.multishoot.price_base = 160
	T("tower_ogre_shipwreck_lvl4").powers.multishoot.price_inc = 160
end

function upgrades_FL:enhance5()
--501 圣巢
	T("tower_paladin_covenant_lvl1").tower.price = 60
	T("tower_paladin_covenant_lvl2").tower.price = 80
	T("tower_paladin_covenant_lvl3").tower.price = 110
	T("tower_paladin_covenant_lvl4").tower.price = 140
	T("tower_paladin_covenant_lvl4").powers.lead.price_base = 175
	T("tower_paladin_covenant_lvl4").powers.healing_prayer.price_base = 120
	T("tower_paladin_covenant_lvl4").powers.healing_prayer.price_inc = 105
	T("tower_paladin_covenant_soldier_lvl4").powers.healing_prayer.cooldown = {23,17,11}
--502 皇弓
	T("tower_royal_archers_lvl1").tower.price = 60
	T("tower_royal_archers_lvl2").tower.price = 100
	T("tower_royal_archers_lvl3").tower.price = 150
	T("tower_royal_archers_lvl4").tower.price = 180
	T("tower_royal_archers_lvl4").powers.rapacious_hunter.price_base = 150
	T("tower_royal_archers_lvl4").powers.rapacious_hunter.price_inc = 120
	T("tower_royal_archers_lvl4").powers.armor_piercer.price_inc = 120
	T("tower_royal_archers_lvl4").powers.armor_piercer.cooldown = {8, 8, 8}
	T("tower_royal_archers_pow_rapacious_hunter_eagle").attacks.list[1].damage_min = {34,66,98}
	T("tower_royal_archers_pow_rapacious_hunter_eagle").attacks.list[1].damage_max = {67,133,199}
	--T("tower_royal_archers_lvl4").powers.rapacious_hunter.price_base = 120
	--T("tower_royal_archers_lvl4").powers.rapacious_hunter.price_inc = 120
--503 奥术
	T("tower_arcane_wizard_ray_disintegrate_mod").boss_damage_config = {800,1440,2080}
	T("tower_arcane_wizard_lvl1").attacks.list[1].cooldown = 1.9
	T("tower_arcane_wizard_lvl2").attacks.list[1].cooldown = 1.9
	T("tower_arcane_wizard_lvl3").attacks.list[1].cooldown = 1.9
	local arcane_wizard = T("tower_arcane_wizard_lvl4")
	arcane_wizard.attacks.list[1].cooldown = 1.9
	arcane_wizard.attacks.list[3].max_range = arcane_wizard.attacks.range * 1.15
	arcane_wizard.attacks.list[3].min_range = 80
	arcane_wizard.attacks.list[3].include_self = true
	arcane_wizard.main_script.update = scripts.tower_arcane_wizard599.update
--504 三管
	T("tower_tricannon_overheat_scorch_aura_mod").dps.damage_config = {3,6,9}
	T("tower_tricannon_lvl1").main_script.update = scripts.tower_tricannon99.update
	T("tower_tricannon_lvl2").main_script.update = scripts.tower_tricannon99.update
	T("tower_tricannon_lvl3").main_script.update = scripts.tower_tricannon99.update
	T("tower_tricannon_lvl4").main_script.update = scripts.tower_tricannon99.update
--505 树灵
	T("mod_tower_arborean_emissary_basic_attack").modifier_duration = {4,6,8,10}
	T("tower_arborean_emissary_bolt_lvl1").bullet.damage_max = 15
	T("tower_arborean_emissary_bolt_lvl1").bullet.damage_min = 8
	T("tower_arborean_emissary_bolt_lvl2").bullet.damage_max = 33
	T("tower_arborean_emissary_bolt_lvl2").bullet.damage_min = 18
	T("tower_arborean_emissary_bolt_lvl3").bullet.damage_max = 51
	T("tower_arborean_emissary_bolt_lvl3").bullet.damage_min = 28
	T("tower_arborean_emissary_bolt_lvl4").bullet.damage_max = 81
	T("tower_arborean_emissary_bolt_lvl4").bullet.damage_min = 43
	T("tower_arborean_emissary_lvl4").powers.wave_of_roots.damage_min = {40,65,90}
	T("tower_arborean_emissary_lvl4").powers.wave_of_roots.damage_max = {40,65,90}
--506 澡堂
	T("soldier_tower_demon_pit_basic_attack").explosion_damage_min = {8,18,30,45}
	T("soldier_tower_demon_pit_basic_attack").explosion_damage_max = {15,30,45,68}
	T("soldier_tower_demon_pit_basic_attack_lvl1").explosion_damage_min = {8,18,30,45}
	T("soldier_tower_demon_pit_basic_attack_lvl1").explosion_damage_max = {15,30,45,68}
	T("soldier_tower_demon_pit_basic_attack_lvl2").explosion_damage_min = {8,18,30,45}
	T("soldier_tower_demon_pit_basic_attack_lvl2").explosion_damage_max = {15,30,45,68}
	T("soldier_tower_demon_pit_basic_attack_lvl3").explosion_damage_min = {8,18,30,45}
	T("soldier_tower_demon_pit_basic_attack_lvl3").explosion_damage_max = {15,30,45,68}
	T("soldier_tower_demon_pit_basic_attack_lvl4").explosion_damage_min = {8,18,30,45}
	T("soldier_tower_demon_pit_basic_attack_lvl4").explosion_damage_max = {15,30,45,68}
	T("tower_demon_pit_lvl1").attacks.list[1].cooldown = 2.8
	T("tower_demon_pit_lvl2").attacks.list[1].cooldown = 2.8
	T("tower_demon_pit_lvl3").attacks.list[1].cooldown = 2.8
	T("tower_demon_pit_lvl4").attacks.list[1].cooldown = 2.8
	T("tower_demon_pit_lvl4").powers.master_exploders.explosion_damage_factor = {1.3,1.6,2}
	T("tower_demon_pit_lvl4").powers.master_exploders.s_damage_increase = {0.3,0.6,1}
	T("tower_demon_pit_lvl4").powers.big_guy.cooldown = { 28, 28, 28 }
	T("tower_demon_pit_lvl4").attacks.list[2].cooldown = 28
--507 观星
	T("tower_elven_stargazers_ray").bullet.damage_min_config = {4,11,22,34}
	T("tower_elven_stargazers_ray").bullet.damage_max_config = {6,18,32,52}
	T("tower_elven_stargazers_lvl4").powers.stars_death.extra_shots = {0,1,2}
	T("tower_elven_stargazers_lvl4").powers.stars_death.price_inc = 340
	T("tower_elven_stargazers_lvl4").powers.stars_death.price_base = 150
	T("mod_tower_elven_stargazers_star_death").modifier.duration = fts(45)
--508 枪手
	T("tower_rocket_gunners_lvl1").barrack.max_soldiers = 3
	T("tower_rocket_gunners_lvl2").barrack.max_soldiers = 3
	T("tower_rocket_gunners_lvl3").barrack.max_soldiers = 3
	T("tower_rocket_gunners_lvl4").barrack.max_soldiers = 3
	T("soldier_tower_rocket_gunners_lvl4").powers.sting_missiles.hp_max_target = {500, 1000, 1500}
	T("soldier_tower_rocket_gunners_lvl4").melee.attacks[2].damage_area_min = {13,19,25}
	T("soldier_tower_rocket_gunners_lvl4").melee.attacks[2].damage_area_max = {16,24,32}
	--T("soldier_tower_rocket_gunners_lvl1").main_script.update = scripts.soldier_tower_rocket_gunners99.update
	--T("soldier_tower_rocket_gunners_lvl2").main_script.update = scripts.soldier_tower_rocket_gunners99.update
	--T("soldier_tower_rocket_gunners_lvl3").main_script.update = scripts.soldier_tower_rocket_gunners99.update
	--T("soldier_tower_rocket_gunners_lvl4").main_script.update = scripts.soldier_tower_rocket_gunners99.update
	T("soldier_tower_rocket_gunners_lvl1").vis_bans_after_take_off = F_RANGED
	T("soldier_tower_rocket_gunners_lvl2").vis_bans_after_take_off = F_RANGED
	T("soldier_tower_rocket_gunners_lvl3").vis_bans_after_take_off = F_RANGED
	T("soldier_tower_rocket_gunners_lvl4").vis_bans_after_take_off = F_RANGED
--509 巨弩
	T("bullet_tower_ballista_lvl1").bullet.damage_max = 6
	T("bullet_tower_ballista_lvl1").bullet.damage_min = 4
	T("bullet_tower_ballista_lvl2").bullet.damage_max = 16
	T("bullet_tower_ballista_lvl2").bullet.damage_min = 10
	T("bullet_tower_ballista_lvl3").bullet.damage_max = 32
	T("bullet_tower_ballista_lvl3").bullet.damage_min = 21
	T("bullet_tower_ballista_lvl4").bullet.damage_max = 55
	T("bullet_tower_ballista_lvl4").bullet.damage_min = 37
	T("tower_ballista_lvl4").attacks.list[2].damage_min = {200,325,450}
	T("tower_ballista_lvl4").attacks.list[2].damage_max = {200,325,450}
	T("tower_ballista_lvl4").powers.skill_final_shot.damage_factor_config = {1.2,1.6,2.0}
	T("bullet_tower_ballista_skill_bomb").bullet.damage_min_config = {200,325,450}
	T("bullet_tower_ballista_skill_bomb").bullet.damage_max_config = {200,325,450}
	T("mod_bullet_tower_ballista_skill_final_shot_stun").modifier.duration = fts(33)
	T("tower_ballista_lvl4").powers.skill_final_shot.bullet = "bullet_tower_ballista_skill_final_shot_area"
--510 死灵
	T("bullet_tower_necromancer_lvl1").bullet.damage_max = 10
	T("bullet_tower_necromancer_lvl1").bullet.damage_min = 4
	T("bullet_tower_necromancer_lvl2").bullet.damage_max = 25
	T("bullet_tower_necromancer_lvl2").bullet.damage_min = 12
	T("bullet_tower_necromancer_lvl3").bullet.damage_max = 45
	T("bullet_tower_necromancer_lvl3").bullet.damage_min = 20
	T("bullet_tower_necromancer_lvl4").bullet.damage_max = 80
	T("bullet_tower_necromancer_lvl4").bullet.damage_min = 36
	for i = 1, 4 do
		local necromancer = T("tower_necromancer_lvl" .. i)

		necromancer.extra_skull_on_enemy_death = true
		necromancer.extra_skull_on_enemy_death_max = 4
	end
	T("tower_necromancer_lvl4").powers.skill_debuff.price_base = 120
	T("tower_necromancer_lvl4").powers.skill_debuff.price_inc = 60
	T("aura_tower_necromancer_skill_rider").damage_min_config = {80,145,200}
	T("aura_tower_necromancer_skill_rider").damage_max_config = {80,145,200}
--511 喷火
	T("tower_flamespitter_lvl1").tower.price = 120
	T("tower_flamespitter_lvl2").tower.price = 170
	T("tower_flamespitter_lvl3").tower.price = 240
	T("tower_flamespitter_lvl4").tower.price = 310
	T("aura_tower_flamespitter").aura.radius = 70
--512 沙镖
	T("bullet_tower_sand_lvl1").bounce_damage_mult = 0.6
	T("bullet_tower_sand_lvl2").bounce_damage_mult = 0.7
	T("bullet_tower_sand_lvl3").bounce_damage_mult = 0.8
	T("bullet_tower_sand_lvl4").bounce_damage_mult = 0.9
	T("bullet_tower_sand_skill_gold").bounce_damage_mult = 1
	T("aura_tower_sand_skill_big_blade").aura.radius = 60
	T("mod_tower_sand_skill_big_blade_slow").slow.factor = 0.4
--513 战魂
	T("soldier_tower_ghost_lvl1").health.hp_max = 1
	T("soldier_tower_ghost_lvl2").health.hp_max = 100
	T("soldier_tower_ghost_lvl3").health.hp_max = 160
	T("soldier_tower_ghost_lvl4").health.hp_max = 220
	T("soldier_tower_ghost_lvl1").health.armor = 0.35
	T("soldier_tower_ghost_lvl2").health.armor = 0.45
	T("soldier_tower_ghost_lvl3").health.armor = 0.6
	T("soldier_tower_ghost_lvl4").health.armor = 0.75
	T("soldier_tower_ghost_lvl3").melee.attacks[1].damage_min = 16
	T("soldier_tower_ghost_lvl3").melee.attacks[1].damage_max = 24
	T("soldier_tower_ghost_lvl4").melee.attacks[1].damage_min = 24
	T("soldier_tower_ghost_lvl4").melee.attacks[1].damage_max = 36
	T("soul_soldier_tower_ghost_lvl4").damage_max = {70,240,410}
	T("soul_soldier_tower_ghost_lvl4").damage_min = {70,240,410}
	T("soldier_tower_ghost_lvl4").extra_damage_cooldown = 1
	
	T("tower_ghost_lvl4").powers.extra_damage.price_base = 150
	T("tower_ghost_lvl4").powers.extra_damage.price_inc = 80
--514 酒桶
	T("tower_barrel_lvl4").powers.skill_barrel.cooldown = {24,22,20}
	T("mod_tower_barrel_skill_barrel_slow").slow.factor = 0.3
	T("aura_bullet_tower_barrel_skill_barrel").explosion_damage_type = DAMAGE_EXPLOSION
	
--515 诡术
	T("bullet_tower_ray_lvl1").bullet.damage_min = 44
	T("bullet_tower_ray_lvl1").bullet.damage_max = 44
	T("bullet_tower_ray_lvl2").bullet.damage_min = 109
	T("bullet_tower_ray_lvl2").bullet.damage_max = 109
	T("bullet_tower_ray_lvl3").bullet.damage_min = 203
	T("bullet_tower_ray_lvl3").bullet.damage_max = 203
	T("bullet_tower_ray_lvl4").bullet.damage_min = 336
	T("bullet_tower_ray_lvl4").bullet.damage_max = 336
	T("mod_tower_ray_damage").damage_tiers = {0.4,0.4,0.1,0.1}
--516 暮弓
	T("tower_dark_elf_lvl4").powers.skill_buff.damage_min = {2}
	T("tower_dark_elf_lvl4").powers.skill_buff.damage_max = {4}
	T("tower_dark_elf_lvl4").powers.skill_buff.price_base = 350
	T("soldier_tower_dark_elf").dodge.chance = 0.68
	T("soldier_tower_dark_elf").health.armor = 0.4
	T("bullet_tower_dark_elf_lvl1").bullet.reduce_armor = 0.05
	T("bullet_tower_dark_elf_lvl2").bullet.reduce_armor = 0.1
	T("bullet_tower_dark_elf_lvl3").bullet.reduce_armor = 0.15
	T("bullet_tower_dark_elf_lvl4").bullet.reduce_armor = 0.2
	T("bullet_tower_dark_elf_lvl4").bullet.extra_reduce_armor = 0.3
	T("bullet_tower_dark_elf_lvl4").bullet.extra_damage_factor = 1.5
	T("tower_dark_elf_lvl4").main_script.update = scripts.tower_dark_elf99.update
--517 蛤蟆
	--EMPTY BLOCK
	T("tower_hermit_toad_lvl4").powers.jump.price_base = 120
	T("tower_hermit_toad_lvl4").powers.jump.price_inc = 100
	T("tower_hermit_toad_lvl4").powers.jump.damage_min = {120,210,270}
	T("tower_hermit_toad_lvl4").powers.jump.damage_max = {120,210,270}
--518 炮兵
	--EMPTY BLOCK
	T("tower_dwarf_lvl3").tower.price = 170
	T("tower_dwarf_lvl4").tower.price = 220
	T("tower_dwarf_lvl4").powers.formation.price_base = 150
--519 黄电
	T("tower_sparking_geode_lvl4").powers.crystalize.cooldown = {30,26,22}
	T("tower_sparking_geode_lvl4").powers.spike_burst.cooldown = {38, 32, 26}
	--T("tower_sparking_geode_lvl4").powers.crystalize.price_inc = 100
--520 熊猫
	T("bullet_tower_pandas_air_soldier_special_lvl1").bullet.damage_min = 28
	T("bullet_tower_pandas_air_soldier_special_lvl1").bullet.damage_max = 35
	T("bullet_tower_pandas_air_soldier_special_lvl2").bullet.damage_min = 56
	T("bullet_tower_pandas_air_soldier_special_lvl2").bullet.damage_max = 70
	--T("soldier_tower_pandas_red_lvl4").powers.teleport.damage_min = {3,24}
	--T("soldier_tower_pandas_red_lvl4").powers.teleport.damage_max = {6,36}
	--T("soldier_tower_pandas_red_lvl4").powers.teleport.nodes_offset_min = {-20,-28}
	--T("soldier_tower_pandas_red_lvl4").powers.teleport.nodes_offset_max = {-24,-32}
	--T("soldier_tower_pandas_blue_lvl4").powers.thunder.cooldown = {15,9}
	--521 龙巢
	T("tower_dragons_lvl1").attacks.max_dragons = 2
	T("tower_dragons_lvl2").attacks.max_dragons = 3
	T("tower_dragons_lvl3").attacks.max_dragons = 4
	T("tower_dragons_lvl4").attacks.max_dragons = 4
	T("bolt_faerie_dragon_lvl1").bullet.damage_min = 6
	T("bolt_faerie_dragon_lvl1").bullet.damage_max = 9
	T("bolt_faerie_dragon_lvl2").bullet.damage_min = 9
	T("bolt_faerie_dragon_lvl2").bullet.damage_max = 16
	T("bolt_faerie_dragon_lvl3").bullet.damage_min = 10
	T("bolt_faerie_dragon_lvl3").bullet.damage_max = 17
	T("bolt_faerie_dragon_lvl4").bullet.damage_min = 16
	T("bolt_faerie_dragon_lvl4").bullet.damage_max = 30
	T("mod_faerie_dragon_lvl1").slow.factor = 0.6
	T("mod_faerie_dragon_lvl2").slow.factor = 0.5
	T("mod_faerie_dragon_lvl3").slow.factor = 0.4
	T("mod_faerie_dragon_lvl4").slow.factor = 0.3
	T("tower_dragons_lvl4").attacks.list[2].damage_config = 45
end

function upgrades_FL:enhance6()
	local archers = T("tower_archers_lvl4")
	archers.powers.skill_a.price = {225, 225, 225}
	archers.powers.skill_a.price_base = 225
	archers.powers.skill_a.price_inc = 225
	archers.powers.skill_a.damage_min = {18, 36, 54}
	archers.powers.skill_a.damage_max = {29, 58, 87}
	archers.attacks.list[2].targets = 4
	T("bullet_archers_lvl4").main_script.update = scripts.arrow_archers_FL.update
	for level = 1, 3 do
		T("bullet_archers_skill_a_lvl" .. level).main_script.update = scripts.ray_archers_skill_a_FL.update
	end

	local wizard = T("tower_wizard_lvl4")
	wizard.powers.skill_c.price = {245, 245, 245}
	wizard.powers.skill_c.price_base = 245
	wizard.powers.skill_c.price_inc = 245
	local copies = T("aura_wizard_skill_c")
	copies.min_damage = {35, 56, 77}
	copies.max_damage = {65, 104, 143}
	copies.bullet_count = {5, 7, 10}

	T("tower_sniper_lvl4").main_script.update = scripts.tower_sniper_FL.update

	local knight_aura = T("aura_knights_skill_c_check")
	knight_aura.fl_heal_factors = {0.20, 0.35, 0.50}
	knight_aura.main_script.update = scripts.aura_knights_skill_c_FL.update
	T("soldier_knights_lvl3").health.hp_max = 160
	T("soldier_knights_lvl3").health.armor = 0.36
	T("soldier_knights_lvl4").health.hp_max = 240
	T("soldier_knights_lvl4").health.armor = 0.48

	local miners = T("tower_miners_lvl4")
	T("controller_miners_global_gold_cap").gold_cap_per_wave = 750
	miners.powers.skill_a.price = {350, 350, 350}
	miners.powers.skill_a.price_base = 350
	miners.powers.skill_a.price_inc = 350
	miners.powers.skill_b.price = {450, 450, 450}
	miners.powers.skill_b.price_base = 450
	miners.powers.skill_b.price_inc = 450
	for level = 1, 4 do
		local soldier = T("soldier_miners_lvl" .. level)
		soldier.health.hp_max = ({60, 120, 200, 300})[level]
		soldier.health.armor = ({0, 0.05, 0.15, 0.25})[level]
	end
	T("decal_miners_cart_skill_a").main_script.update = scripts.decal_miners_cart_skill_a_FL.update
	T("mod_miners_skill_b_stun").main_script.insert = scripts.mod_miners_skill_b_stun_FL.insert
	for level, reward in ipairs({1, 2, 3}) do
		local aura = T("aura_miners_skill_b_lvl" .. level)
		aura.aura.level = level
		aura.fl_gold_per_stun = reward
		aura.main_script.update = scripts.aura_miners_skill_b_FL.update
	end

	-- Royal catapult: ordinary stones keep rolling after impact.
	local roll = ensure_template("aura_catapult_basic_roll_FL", "aura_catapult_ultimate")
	roll.main_script.update = scripts.aura_catapult_basic_roll_FL.update
	roll.main_script.insert = nil
	roll.aura.mod = nil
	roll.max_nodes = 400
	for level = 1, 4 do
		T("bullet_catapult_lvl" .. level).main_script.update = scripts.bomb_catapult_roll_FL.update
	end
	T("bullet_catapult_skill_b").main_script.update = scripts.bomb_catapult_roll_FL.update

	-- Sentry watchtower: each basic/ultimate shot gains an armor-tested physical hit.
	local sniper_divisors = {12, 8, 5, 3}
	local sniper_boss_caps = {80, 120, 200, 300}
	for level = 1, 4 do
		local bullet = T("bullet_sniper_basic_lvl" .. level)
		bullet.fl_sniper_divisor = sniper_divisors[level]
		bullet.fl_sniper_boss_cap = sniper_boss_caps[level]
		bullet.main_script.update = scripts.ray_sniper_FL.update
	end
	for level = 1, 3 do
		local bullet = T("bullet_sniper_skill_a_lvl" .. level)
		bullet.fl_sniper_divisor = 3
		bullet.fl_sniper_boss_cap = 300
		bullet.main_script.update = scripts.ray_sniper_FL.update
	end
	T("bullet_sniper_ult").fl_sniper_divisor = 3
	T("bullet_sniper_ult").fl_sniper_boss_cap = 300
	T("bullet_sniper_ult").main_script.update = scripts.ray_sniper_FL.update

	-- Ironbark treant: both tower and uprooted unit have a bonus single-target hit.
	for level = 1, 4 do
		T("aura_tree_attack_lvl" .. level).main_script.update = scripts.aura_tree_attack_FL.update
		T("soldier_tree_lvl" .. level).main_script.update = scripts.soldier_tree_FL.update
	end
	local armor_mod_name = "mod_tree_skill_a_armor_FL"
	local armor_mod = ensure_template(armor_mod_name, "modifier_KR6")
	armor_mod.fl_armor_reductions = {0.20, 0.35, 0.50}
	armor_mod.fl_durations = {}
	armor_mod.modifier.replaces_lower = true
	armor_mod.modifier.resets_same = true
	armor_mod.main_script.insert = scripts.mod_tree_skill_a_armor_FL.insert
	armor_mod.main_script.update = scripts.kr6_fl_mod_track_target_update
	armor_mod.main_script.remove = scripts.mod_tree_skill_a_armor_FL.remove
	for level = 1, 3 do
		armor_mod.fl_durations[level] = T("mod_tree_skill_a_blind_lvl" .. level).modifier.duration
		for _, prefix in ipairs({"aura_tree_tower_skill_a_blind_lvl", "aura_tree_unit_skill_a_blind_lvl"}) do
			local aura = T(prefix .. level).aura
			aura.level = level
			if not table.contains(aura.mods, armor_mod_name) then
				aura.mods[#aura.mods + 1] = armor_mod_name
			end
		end
	end

	local ranger = T("tower_ranger_lvl4")
	ranger.powers.skill_a.cooldown = {15, 15, 15}
	ranger.powers.skill_c.price = {225, 180, 180}
	ranger.powers.skill_c.price_base = 225
	ranger.powers.skill_c.price_inc = 180
	for level = 1, 3 do
		T("bullet_ranger_skill_a_lvl" .. level).main_script.update = scripts.arrow_ranger_poison_FL.update
		local bounce = ensure_template("bullet_ranger_poison_bounce_FL_lvl" .. level, "bullet_ranger_skill_c_bounce_clone_lvl" .. level)
		bounce.main_script.update = scripts.bullet_ranger_poison_bounce_FL.update
		bounce.bullet.particles_name = "ps_bullet_ranger_skill_a"
		bounce.bullet.hit_fx = "fx_bullet_ranger_skill_a_hit"
		bounce.render.sprites[1].prefix = "elven_elite_ranger_arrow_poison_tip"
	end

	T("tower_crossbows_lvl4").powers.skill_a.cooldown = {18, 18, 18}

	-- The existing fear mark already triggers on death from any source.
	for level = 1, 3 do
		T("mod_crossbows_skill_b_lvl" .. level).modifier.duration = 1.5 + level * 0.5
		local dot_name = "mod_crossbows_skill_b_dot_FL_lvl" .. level
		local dot = ensure_template(dot_name, "modifier_KR6")
		E:add_comps(dot, "dps")
		dot.modifier.duration = T("mod_crossbows_skill_b_slow_lvl" .. level).modifier.duration
		dot.modifier.resets_same = true
		dot.dps.damage_type = DAMAGE_MAGICAL
		dot.dps.damage_min = level + 3
		dot.dps.damage_max = level + 3
		dot.dps.damage_every = 1
		dot.main_script.insert = scripts.kr6_fl_mod_dps_insert
		dot.main_script.update = scripts.kr6_fl_mod_dps_update
		local fear_aura_name = "aura_crossbows_skill_b_lvl" .. level
		local fear_mods = T(fear_aura_name).aura.mods
		if not table.contains(fear_mods, dot_name) then
			fear_mods[#fear_mods + 1] = dot_name
		end
		local bolt_template = T("bullet_crossbows_skill_c_lvl" .. level)
		local bolt = bolt_template.bullet
		bolt.fl_original_damage_min = bolt.fl_original_damage_min or bolt.damage_min
		bolt.fl_original_damage_max = bolt.fl_original_damage_max or bolt.damage_max
		bolt.damage_min = bolt.fl_original_damage_min
		bolt.damage_max = bolt.fl_original_damage_max
		bolt_template.fl_fear_aura = fear_aura_name
		bolt_template.main_script.update = scripts.ray_crossbows_skill_c_FL.update
	end
	local crossbows_knight = T("soldier_crossbows_ult")
	crossbows_knight.reinforcement.duration = 24
	crossbows_knight.health.hp_max = 444
	crossbows_knight.health.armor = 0.94
	crossbows_knight.melee.attacks[1].damage_min = 44
	crossbows_knight.melee.attacks[1].damage_max = 94
	T("controller_crossbows_ult").cooldown = 44

	local alchemist = T("tower_alchemist_lvl4")
	alchemist.powers.skill_a.price = {250, 200, 200}
	alchemist.powers.skill_a.price_base = 250
	alchemist.powers.skill_a.price_inc = 175
	for level, damage in ipairs({25, 40, 55}) do
		local bomb = T("bullet_alchemist_skill_a_lvl" .. level).bullet
		bomb.damage_min = damage
		bomb.damage_max = damage
		bomb.damage_type = DAMAGE_TRUE
		bomb.damage_radius = T("aura_alchemist_skill_a_lvl" .. level).aura.radius
	end

	for level, dodge_chance in ipairs({0.10, 0.20, 0.30, 0.40}) do
		local wildcat = T("soldier_wildcat_lvl" .. level)
		E:add_comps(wildcat, "dodge")
		wildcat.dodge.chance = dodge_chance
		wildcat.dodge.ranged = true
		wildcat.dodge.silent = true
		wildcat.health.armor = ({0, 0.05, 0.15, 0.3})[level]
	end
	local wildcat_tower = T("tower_wildcat_lvl4")
	wildcat_tower.powers.skill_c.price = {240, 240, 240}
	wildcat_tower.powers.skill_c.price_base = 240
	wildcat_tower.powers.skill_c.price_inc = 240
	T("soldier_wildcat_lvl4").main_script.update = scripts.soldier_wildcat_FL.update

	local culverine = T("tower_culverine_lvl4")
	culverine.timed_attacks.list[1].min_targets = 1
	for level = 1, 3 do
		T("bullet_culverine_skill_a_lvl" .. level).main_script.update = scripts.bomb_culverine_skill_a_FL.update
		local aura = T("aura_bullet_culverine_skill_b_lvl" .. level)
		aura.aura.mods = nil
		aura.fl_armor_multiplier = ({0.3, 0.7, 1.2})[level]
		aura.main_script.update = scripts.aura_culverine_skill_b_FL.update
	end

	local forger = T("tower_forger_lvl4")
	forger.timed_attacks.list[2].max_crystals = 3
	forger.powers.skill_b.price = {190, 190, 190}
	forger.powers.skill_b.price_base = 190
	forger.powers.skill_b.price_inc = 190
	forger.main_script.update = scripts.tower_forger_FL.update
	for level = 1, 3 do
		local stun = T("mod_forger_skill_c_stun_lvl" .. level)
		stun.fl_received_damage_factor = ({1.2, 1.25, 1.3})[level]
		stun.main_script.insert = scripts.mod_forger_skill_c_stun_FL.insert
		stun.main_script.remove = scripts.mod_forger_skill_c_stun_FL.remove
	end

	local sunray = T("tower_sunray_master_lvl4")
	sunray.powers.skill_a.price = {350, 165, 165}
	sunray.powers.skill_b.price = {120, 300, 300}
	sunray.powers.skill_c.price = {130, 130, 130}
	sunray.powers.skill_a.price_base = 280
	sunray.powers.skill_a.price_inc = 180
	sunray.powers.skill_b.price_base = 120
	sunray.powers.skill_b.price_inc = 275
	sunray.powers.skill_c.price_base = 155
	sunray.powers.skill_c.price_inc = 155
	sunray.attacks.list[2].skill_c_rate = 2
	for level = 1, 3 do
		local element = T("soldier_sunray_master_lvl" .. level)
		element.health.hp_max = ({180, 265, 350})[level]
		element.health.armor = ({0.4, 0.5, 0.6})[level]
		local attack = E:clone_c("area_attack")
		for key, value in pairs(element.melee.attacks[1]) do
			attack[key] = value
		end
		attack.type = "area"
		attack.damage_min = ({10, 20, 30})[level]
		attack.damage_max = ({30, 40, 50})[level]
		attack.damage_radius = 32.5
		element.melee.attacks[1] = attack
		local wave = T("aura_sunray_master_skill_b_lvl" .. level).aura
		wave.damage_min = ({64, 88, 112})[level]
		wave.damage_max = ({96, 132, 168})[level]
	end

	for level, range in ipairs({150, 175, 200, 225}) do
		local priest = T("tower_light_priestess_lvl" .. level)
		priest.attacks.range = range
		priest.tower.price = ({90, 130, 200, 260})[level]
	end
	T("tower_light_priestess_lvl4").timed_attacks.list[2].range = 225
	for level = 1, 3 do
		T("aura_light_priestess_skill_b_lvl" .. level).aura.radius = 245
	end
	local priestess = T("tower_light_priestess_lvl4")
	priestess.powers.skill_a.price = {225, 225, 225}
	priestess.powers.skill_a.price_base = 225
	priestess.powers.skill_a.price_inc = 225
	priestess.powers.skill_c.price = {325, 280, 280}
	priestess.powers.skill_c.price_base = 325
	priestess.powers.skill_c.price_inc = 280
	priestess.main_script.update = scripts.tower_light_priestess_FL.update
	priestess.main_script.remove = scripts.tower_light_priestess_FL.remove
	local aura = ensure_template("aura_light_priestess_FL", "aura")
	aura.aura.cycle_time = 0.1
	aura.main_script.update = scripts.aura_light_priestess_FL.update
	aura.main_script.remove = scripts.aura_light_priestess_FL.remove
end

--双英雄模式前3代英雄需要削弱
G1_HP_RATE = 1
G1_ATK_RATE = 1
G1_CD_RATE = 1
function upgrades_FL:enhance_hero1()
	local hero_list ={
				"hero_gerald",
				"hero_alleria",
				"hero_bolin",
				"hero_magnus",
				"hero_ignus",
				"hero_malik",
				"hero_denas",
				"hero_ingvar",
				"hero_elora",
				"hero_oni",
				"hero_hacksaw",
				"hero_thor",
				"hero_10yr",
				"hero_voltaire",
				"hero_viper"
	}
	for k, hero in ipairs(hero_list) do
		for i= 1,10 do
			T(hero).hero.level_stats.hp_max[i] = math.ceil(T(hero).hero.level_stats.hp_max[i] * G1_HP_RATE)
			T(hero).hero.level_stats.regen_health[i] = math.ceil(T(hero).hero.level_stats.regen_health[i] * G1_HP_RATE)
			if T(hero).hero.level_stats.melee_damage_max then
				T(hero).hero.level_stats.melee_damage_min[i] = math.ceil(T(hero).hero.level_stats.melee_damage_min[i] * G1_ATK_RATE)
				T(hero).hero.level_stats.melee_damage_max[i] = math.ceil(T(hero).hero.level_stats.melee_damage_max[i] * G1_ATK_RATE)
			end
			if T(hero).hero.level_stats.ranged_damage_max then
				T(hero).hero.level_stats.ranged_damage_max[i] = math.ceil(T(hero).hero.level_stats.ranged_damage_max[i] * G1_ATK_RATE)
				T(hero).hero.level_stats.ranged_damage_min[i] = math.ceil(T(hero).hero.level_stats.ranged_damage_min[i] * G1_ATK_RATE)
			end
			if T(hero).hero.level_stats.damage_min then
				T(hero).hero.level_stats.damage_min[i] = math.ceil(T(hero).hero.level_stats.damage_min[i] * G1_ATK_RATE)
				T(hero).hero.level_stats.damage_max[i] = math.ceil(T(hero).hero.level_stats.damage_max[i] * G1_ATK_RATE)
			end
		end
	end
end

function upgrades_FL:enhance_hero2()
	local hero_list ={
				"hero_alric",
				"hero_mirage",
				"hero_pirate",
				"hero_beastmaster",
				"hero_voodoo_witch",
				"hero_wizard",
				"hero_priest",
				"hero_giant",
				"hero_alien",
				"hero_dragon",
				"hero_monk",
				"hero_crab",
				"hero_van_helsing",
				"hero_dracolich",
				"hero_minotaur",
				"hero_monkey_god"
	}
	for k, hero in ipairs(hero_list) do
		for i= 1,10 do
			T(hero).hero.level_stats.hp_max[i] = math.ceil(T(hero).hero.level_stats.hp_max[i] * G1_HP_RATE)
			T(hero).hero.level_stats.regen_health[i] = math.ceil(T(hero).hero.level_stats.regen_health[i] * G1_HP_RATE)
			if T(hero).hero.level_stats.melee_damage_max then
				T(hero).hero.level_stats.melee_damage_min[i] = math.ceil(T(hero).hero.level_stats.melee_damage_min[i] * G1_ATK_RATE)
				T(hero).hero.level_stats.melee_damage_max[i] = math.ceil(T(hero).hero.level_stats.melee_damage_max[i] * G1_ATK_RATE)
			end
			if T(hero).hero.level_stats.ranged_damage_max then
				T(hero).hero.level_stats.ranged_damage_max[i] = math.ceil(T(hero).hero.level_stats.ranged_damage_max[i] * G1_ATK_RATE)
				T(hero).hero.level_stats.ranged_damage_min[i] = math.ceil(T(hero).hero.level_stats.ranged_damage_min[i] * G1_ATK_RATE)
			end
			if T(hero).hero.level_stats.damage_min then
				T(hero).hero.level_stats.damage_min[i] = math.ceil(T(hero).hero.level_stats.damage_min[i] * G1_ATK_RATE)
				T(hero).hero.level_stats.damage_max[i] = math.ceil(T(hero).hero.level_stats.damage_max[i] * G1_ATK_RATE)
			end
		end
	end
end

function upgrades_FL:enhance_hero3()
	local hero_list ={
				"hero_elves_archer",
		"hero_elves_denas",
		"hero_arivan",
		"hero_regson",
		"hero_bravebark",
		"hero_xin",
		"hero_catha",
		"hero_rag",
		"hero_veznan",
		"hero_durax",
		"hero_lilith",
		"hero_lynn",
		"hero_wilbur",
		"hero_phoenix",
		"hero_faustus",
		"hero_bruce",
	}

	for k, hero in ipairs(hero_list) do
		for i= 1,10 do
			T(hero).hero.level_stats.hp_max[i] = math.ceil(T(hero).hero.level_stats.hp_max[i] * G1_HP_RATE)
			T(hero).hero.level_stats.regen_health[i] = math.ceil(T(hero).hero.level_stats.regen_health[i] * G1_HP_RATE)
			if T(hero).hero.level_stats.melee_damage_max then
				T(hero).hero.level_stats.melee_damage_min[i] = math.ceil(T(hero).hero.level_stats.melee_damage_min[i] * G1_ATK_RATE)
				T(hero).hero.level_stats.melee_damage_max[i] = math.ceil(T(hero).hero.level_stats.melee_damage_max[i] * G1_ATK_RATE)
			end
			if T(hero).hero.level_stats.ranged_damage_max then
				T(hero).hero.level_stats.ranged_damage_max[i] = math.ceil(T(hero).hero.level_stats.ranged_damage_max[i] * G1_ATK_RATE)
				T(hero).hero.level_stats.ranged_damage_min[i] = math.ceil(T(hero).hero.level_stats.ranged_damage_min[i] * G1_ATK_RATE)
			end
			if T(hero).hero.level_stats.damage_min then
				T(hero).hero.level_stats.damage_min[i] = math.ceil(T(hero).hero.level_stats.damage_min[i] * G1_ATK_RATE)
				T(hero).hero.level_stats.damage_max[i] = math.ceil(T(hero).hero.level_stats.damage_max[i] * G1_ATK_RATE)
			end
		end
		if T(T(hero).hero.skills.ultimate.controller_name).cooldown then
			T(T(hero).hero.skills.ultimate.controller_name).cooldown = T(T(hero).hero.skills.ultimate.controller_name).cooldown * G1_CD_RATE
		else
			for i = 0, 3 do
				T(hero).hero.skills.ultimate.cooldown[i] = T(hero).hero.skills.ultimate.cooldown[i] * G5_CD_RATE
			end
		end
	end
end

G5_HP_RATE = 1.5
G5_ATK_RATE = 1.38
G5_CD_RATE = 0.72
function upgrades_FL:enhance_hero5()
	local hero_list = {
		"hero_bird",
		"hero_builder",
		"hero_dragon_bone",
		"hero_dragon_gem",
		"hero_hunter",
		"hero_lumenir",
		"hero_mecha",
		"hero_muyrn",
		"hero_raelyn",
		"hero_robot",
		"hero_space_elf",
		"hero_venom",
		"hero_vesper",
		"hero_witch",
		"hero_dragon_arb",
		"hero_lava",
		"hero_spider",
		"hero_wukong",
		"hero_douzhanshengfo",
		"hero_dragon_sun"
	}
	for k, hero in ipairs(hero_list) do
		for i= 1,10 do
			T(hero).hero.level_stats.hp_max[i] = math.ceil(T(hero).hero.level_stats.hp_max[i] * G5_HP_RATE)
			T(hero).hero.level_stats.regen_health[i] = math.ceil(T(hero).hero.level_stats.regen_health[i] * G5_HP_RATE)
			if T(hero).hero.level_stats.melee_damage_max then
				if type(T(hero).hero.level_stats.melee_damage_min[1]) == "table" then
					for j = 1,#T(hero).hero.level_stats.melee_damage_min[1] do
						T(hero).hero.level_stats.melee_damage_min[j][i] = math.ceil(T(hero).hero.level_stats.melee_damage_min[j][i] * G5_ATK_RATE)
						T(hero).hero.level_stats.melee_damage_max[j][i] = math.ceil(T(hero).hero.level_stats.melee_damage_max[j][i] * G5_ATK_RATE)
					end
				else
					T(hero).hero.level_stats.melee_damage_min[i] = math.ceil(T(hero).hero.level_stats.melee_damage_min[i] * G5_ATK_RATE)
					T(hero).hero.level_stats.melee_damage_max[i] = math.ceil(T(hero).hero.level_stats.melee_damage_max[i] * G5_ATK_RATE)
				end
			end
			if T(hero).hero.level_stats.ranged_damage_max then
				T(hero).hero.level_stats.ranged_damage_max[i] = math.ceil(T(hero).hero.level_stats.ranged_damage_max[i] * G5_ATK_RATE)
				T(hero).hero.level_stats.ranged_damage_min[i] = math.ceil(T(hero).hero.level_stats.ranged_damage_min[i] * G5_ATK_RATE)
			end
			if T(hero).hero.level_stats.damage_min then
				T(hero).hero.level_stats.damage_min[i] = math.ceil(T(hero).hero.level_stats.damage_min[i] * G5_ATK_RATE)
				T(hero).hero.level_stats.damage_max[i] = math.ceil(T(hero).hero.level_stats.damage_max[i] * G5_ATK_RATE)
			end
		end
		for i = 0, 3 do
			T(hero).hero.skills.ultimate.cooldown[i] = T(hero).hero.skills.ultimate.cooldown[i] * G5_CD_RATE
		end
	end
end

function upgrades_FL:deenhance_barrack5()
	T("soldier_tower_ghost_lvl1").health.hp_max = 30
	T("soldier_tower_ghost_lvl2").health.hp_max = 50
	T("soldier_tower_ghost_lvl3").health.hp_max = 75
	T("soldier_tower_ghost_lvl4").health.hp_max = 100
	T("soldier_tower_ghost_lvl1").health.armor = 0.2
	T("soldier_tower_ghost_lvl2").health.armor = 0.3
	T("soldier_tower_ghost_lvl3").health.armor = 0.45
	T("soldier_tower_ghost_lvl4").health.armor = 0.6

	T("tower_paladin_covenant_soldier_lvl1").health.hp_max = 40
	T("tower_paladin_covenant_soldier_lvl2").health.hp_max = 80
	T("tower_paladin_covenant_soldier_lvl3").health.hp_max = 120
	T("tower_paladin_covenant_soldier_lvl4").health.hp_max = 180
	T("tower_paladin_covenant_soldier_lvl1").health.armor = 0
	T("tower_paladin_covenant_soldier_lvl2").health.armor = 0.15
	T("tower_paladin_covenant_soldier_lvl3").health.armor = 0.25
	T("tower_paladin_covenant_soldier_lvl4").health.armor = 0.4

	T("soldier_tower_rocket_gunners_lvl1").health.hp_max = 30
	T("soldier_tower_rocket_gunners_lvl2").health.hp_max = 50
	T("soldier_tower_rocket_gunners_lvl3").health.hp_max = 70
	T("soldier_tower_rocket_gunners_lvl4").health.hp_max = 100
	T("soldier_tower_rocket_gunners_lvl1").health.armor = 0.1
	T("soldier_tower_rocket_gunners_lvl2").health.armor = 0.15
	T("soldier_tower_rocket_gunners_lvl3").health.armor = 0.2
	T("soldier_tower_rocket_gunners_lvl4").health.armor = 0.25

	T("soldier_tower_dwarf_lvl1").health.hp_max = 35
	T("soldier_tower_dwarf_lvl2").health.hp_max = 70
	T("soldier_tower_dwarf_lvl3").health.hp_max = 100
	T("soldier_tower_dwarf_lvl4").health.hp_max = 140
	T("soldier_tower_dwarf_lvl1").health.armor = 0
	T("soldier_tower_dwarf_lvl2").health.armor = 0.1
	T("soldier_tower_dwarf_lvl3").health.armor = 0.2
	T("soldier_tower_dwarf_lvl4").health.armor = 0.3
	T("tower_paladin_covenant_soldier_lvl4").powers.lead.b = {
				s_aura_damage_buff_factor = 0.2,
				aura_duration = 8,
				aura_range = 70,
				armor = 0.6,
				hp = 200,
				aura_damage_buff_factor = 1.2,
				regen_hp = 30,
				basic_attack = {
					damage_max = 22,
					damage_min = 14
				},
				aura_cooldown = {
					20
				}
			}
end
---怪物增强
function upgrades_FL:enhance11()
---敌人法球
	T("bolt_enemy").bullet.damage_type = DAMAGE_MAGICAL
---毁灭者
	T("eb_juggernaut").health.armor = 0.8
	T("eb_juggernaut").auras.list[1] = E.clone_c(E, "aura_attack")
	T("eb_juggernaut").auras.list[1].name = "juggernaut_spawner_aura"
	T("eb_juggernaut").auras.list[1].cooldown = 0	
---大雪怪
	T("eb_jt").auras.list[2] = E:clone_c("aura_attack")
	T("eb_jt").auras.list[2].name = "aura_troll_chieftain_regen"
	T("eb_jt").auras.list[2].cooldown = 0
	T("eb_jt").melee.attacks[1].mod = "mod_jt_lifesteal"
---维兹南
	T("eb_veznan").ranged.attacks[1].cooldown = {5,5,5,5}
	T("eb_veznan").health.magic_armor = 0.8
---萨雷格兹
	T("eb_sarelgaz").auras.list[1] = E:clone_c("aura_attack")
	T("eb_sarelgaz").auras.list[1].name = "sarelgaz_spawner_aura"
	T("eb_sarelgaz").auras.list[1].cooldown = 0
	T("eb_sarelgaz").melee.attacks[1].mod = "mod_jt_lifesteal"
	T("eb_sarelgaz").health.armor = 0.6
	T("eb_sarelgaz").health.magic_armor = 0.3
end
---
function upgrades_FL:enhance()
    user_data = storage:load_slot()
	if user_data.liuhui.balance and user_data.liuhui.balance == true then
		upgrades_FL:enhance1()
		upgrades_FL:enhance2()
		upgrades_FL:enhance3()
		upgrades_FL:enhance4()
		upgrades_FL:enhance5()
	end
	if enemy_enhance.enabled(user_data.xingyu and user_data.xingyu.balance) then
		upgrades_FL:enhance11()
--		upgrades_FL:enhance12()
--		upgrades_FL:enhance13()
--		upgrades_FL:enhance4()
--		upgrades_FL:enhance5()
	end		
end


return upgrades_FL
