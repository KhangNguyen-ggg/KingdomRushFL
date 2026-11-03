local bit = require("bit")
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local E = require("entity_db")
local i18n = require("i18n")
local log = require("klua.log"):new("test_case")

require("constants")

local anchor_y = 0
local image_y = 0
local tt, b
local scripts = require("game_scripts")
local kr1_scripts = require("game_scripts-1")
local kr4_scripts = require("game_scripts-43")
local kr45_scripts = require("game_scripts-45")

require("templates")

local H = require("helpers")
local balance = require("balance/balance")
local IS_PHONE = KR_TARGET == "phone"
local IS_PHONE_OR_TABLET = KR_TARGET == "phone" or KR_TARGET == "tablet"
local IS_CONSOLE = KR_TARGET == "console"

local function v(v1, v2)
    return {
        x = v1,
        y = v2
    }
end

local function vv(v1)
    return {
        x = v1,
        y = v1
    }
end

local function r(x, y, w, h)
    return {
        pos = v(x, y),
        size = v(w, h)
    }
end

local function fts(v)
    return v / FPS
end

local function ady(v)
    return v - anchor_y * image_y
end

local function adx(v)
    return v - anchor_x * image_x
end

local function np(pi, spi, ni)
    return {
        dir = 1,
        pi = pi,
        spi = spi,
        ni = ni
    }
end

local function d2r(d)
    return d * math.pi / 180
end

local function RT(name, ref)
    return E:register_t(name, ref)
end

local function AC(tpl, ...)
    return E:add_comps(tpl, ...)
end

local function CC(comp_name)
    return E:clone_c(comp_name)
end

DO_ENEMY_BIG = 2
DO_SOLDIER_BIG = 3
DO_HEROES = 3
DO_MOD_FX = 4
DO_TOWER_MODS = 10

if H.command_line_has_arg("balance_override") then
    local balance_override_path = H.command_line_argv("balance_override")

    require(balance_override_path)
end

if game and game.store and game.store.level and game.store.level.test_case and game.store.level.test_case.patch_balance then
    local new_balance = game.store.level.test_case:patch_balance()

    if new_balance then
        balance = new_balance
    end
end


local mod_gold = E:register_t("mod_gold", "modifier")

E:add_comps(mod_gold, "slow")

mod_gold.modifier.duration = 0.3
mod_gold.modifier.allows_duplicates = true
mod_gold.modifier.type = MOD_TYPE_GOLD
mod_gold.slow.factor = 1.1
mod_gold.main_script.insert = kr4_scripts.mod_gold.insert
mod_gold.main_script.remove = kr4_scripts.mod_gold.remove
mod_gold.main_script.update = scripts.mod_track_target.update

--本文件：使用前3代底层代码实现4代防御塔
----------------------------------------------
--------------------少林寺---------------------
----------------------------------------------
--建造
tt = E:register_t("tower_build_shaolin", "tower_build")
tt.build_name = "tower_shaolin_lvl1"
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2].name = "shaolin_temple_lvl1_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(0, 35)--v(0, 30)
tt.render.sprites[3].offset.y = 62
tt.render.sprites[4].offset.y = 62


tt = E:register_t("tower_shaolin_lvl1", "tower_kr4")

E:add_comps(tt, "attacks")
tt.info.i18n_key = "TOWER_SHAOLIN_TEMPLE_LEVEL1"
tt.info.fn = kr4_scripts.tower_shaolin.get_info
tt.info.portrait = "gui4_bottom_info_image_towers_0022"
tt.main_script.insert = kr4_scripts.tower_shaolin.insert
tt.main_script.update = kr4_scripts.tower_shaolin.update
tt.main_script.remove = kr4_scripts.tower_shaolin.remove
tt.attacks.list[1] = E:clone_c("bullet_attack")
--tt.attacks.list[1].animation = "harvester"
tt.attacks.list[1].bullet = "bullet_shaolin_lvl1"
tt.attacks.list[1].bullet_start_offset = v(10, 11)
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[1].vis_flags = bor(F_RANGED)
tt.attacks.list[1].chance = 1

tt.attacks.range = 160
tt.attacks.cooldown = fts(0)
tt.attacks.enemy_cooldown = 1.37
tt.attacks.pixie_cooldown = 1.37
tt.attacks.excluded_templates = {
	"enemy_rabbit"
}
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_0002"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "shaolin_temple_lvl1_0002"
tt.render.sprites[2].offset = v(0, 30)
tt.render.sprites[2].sort_y_offset = 30
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "shaolin_monk_lvl1_deco"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].offset = v(16, 18)
--tt.render.sprites[3].sort_y_offset = 30
tt.render.sprites[3].flip_x = true
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "shaolin_monk_lvl1_deco"
tt.render.sprites[4].name = "idle"
tt.render.sprites[4].offset = v(-16, 18)
--tt.render.sprites[4].sort_y_offset = 30
tt.sound_events.insert = "ShaolinTaunt"
tt.tower.level = 1
tt.tower.menu_offset = v(0, 6)
tt.tower.price = 110
tt.tower.type = "shaolin"
tt.tower.kind = TOWER_KIND_ARCHER

tt = E:register_t("tower_shaolin_lvl2", "tower_shaolin_lvl1")
tt.info.i18n_key = "TOWER_SHAOLIN_TEMPLE_LEVEL2"
tt.tower.level = 2
tt.tower.price = 150
tt.attacks.range = 170
tt.attacks.list[1].bullet = "bullet_shaolin_lvl2"
tt.render.sprites[2].name = "shaolin_temple_lvl2_0001"
tt.render.sprites[3].prefix = "shaolin_monk_lvl2_deco"
tt.render.sprites[4].prefix = "shaolin_monk_lvl2_deco"

tt = E:register_t("tower_shaolin_lvl3", "tower_shaolin_lvl1")
tt.info.i18n_key = "TOWER_SHAOLIN_TEMPLE_LEVEL3"
tt.tower.level = 3
tt.tower.price = 190
tt.attacks.range = 180
tt.attacks.list[1].bullet = "bullet_shaolin_lvl3"
tt.render.sprites[2].name = "shaolin_temple_lvl3_0001"
tt.render.sprites[3].prefix = "shaolin_monk_lvl3_deco"
tt.render.sprites[4].prefix = "shaolin_monk_lvl3_deco"

tt = E:register_t("tower_shaolin_lvl4", "tower_shaolin_lvl1")

E:add_comps(tt, "powers", "barrack","auras")
tt.info.i18n_key = "TOWER_SHAOLIN_TEMPLE_LEVEL4"
tt.tower.level = 4
tt.tower.price = 230
tt.attacks.range = 187.5
tt.attacks.list[1].bullet = "bullet_shaolin_lvl4"
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "aura_tower_shaolin_gold"
tt.auras.list[1].cooldown = 0
tt.render.sprites[2].name = "shaolin_temple_lvl4_0001"
tt.render.sprites[3].prefix = "shaolin_monk_lvl4_deco"
tt.render.sprites[4].prefix = "shaolin_monk_lvl4_deco"
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].animated = true
tt.render.sprites[5].hidden = true
tt.render.sprites[5].name = "shaolin_temple_lvl4_lion_run"
tt.render.sprites[5].offset = v(0, 30)
--tt.render.sprites[5].sort_y_offset = 30
tt.powers.total = E:clone_c("power")
tt.powers.total.price_base = 175
tt.powers.total.price_inc = 175
tt.powers.total.max_level = 3
tt.powers.total.enc_icon = 363
tt.powers.dragon = E:clone_c("power")
tt.powers.dragon.price_base = 250
tt.powers.dragon.max_level = 1
tt.powers.dragon.enc_icon = 362
tt.powers.lion = E:clone_c("power")
tt.powers.lion.price_base = 100
tt.powers.lion.max_level = 1
tt.powers.lion.enc_icon = 361
tt.barrack.soldier_type = "soldier_dragon"
tt.barrack.rally_range = 185

tt = E:register_t("aura_tower_shaolin_gold", "aura")
--b = balance.towers.sparking_geode.spike_burst
tt.aura.mods = {
	"mod_tower_shaolin_gold",
}
tt.aura.radius = 184.8 --可能需要科技
tt.aura.vis_flags = bor(F_MOD)
tt.aura.vis_bans = bor(F_FRIEND)
tt.aura.duration = 1e+99
tt.aura.cycle_time = 0.4
tt.distance_between_crystals = {
	115,
	110,
	70
}
tt.main_script.insert = kr4_scripts.aura_tower_shaolin_gold.insert
tt.main_script.update = kr4_scripts.aura_tower_shaolin_gold.update
tt.ps_names = {
	--"ps_tower_rotten_forest_sparks_1",
	--"ps_tower_rotten_forest_sparks_1"
}

tt = E:register_t("mod_tower_shaolin_gold", "mod_gold")
--b = balance.towers.sparking_geode.spike_burst
tt.modifier.duration = 0.4
tt.slow.factor = 1.1

function tt.main_script.insert(this, store, script)
	this.slow.factor = this.slow.factor

	return kr4_scripts.mod_gold.insert(this, store, script)
end

tt = RT("soldier_dragon", "soldier_militia")
AC(tt, "melee", "nav_grid")

image_y = 64
anchor_y = 0.15
tt.health.armor = 0
tt.health.armor_inc = 0
tt.health.dead_lifetime = 13
tt.health.hp_max = 400
tt.health.hp_inc = 0
tt.health_bar.offset = v(0, 45)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "SHAOLIN_DRAGON_WARRIOR"
tt.info.portrait = "gui4_bottom_info_image_soldiers_0051"
tt.info.random_name_count = nil
tt.info.random_name_format = nil
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].count = 1
tt.melee.attacks[1].damage_inc = 0
tt.melee.attacks[1].damage_max = 60
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].damage_radius = 37.5
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(35, 0)
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].pop = {
	"pop_whaam",
	"pop_kapow"
}
tt.melee.attacks[1].pop_chance = 0.3
tt.melee.attacks[1].sound_hit = "AreaAttack"
tt.melee.range = 60
tt.motion.max_speed = 30
tt.regen.health = 40
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"running"
}
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].prefix = "shaolin_dragon_warrior"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "shaolin_dragon_warrior_shadow"
tt.render.sprites[2].anchor.y = 0.15
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1

tt.soldier.melee_slot_offset = v(15, 0)
tt.sound_events.insert = "RockElementalDeath"
tt.sound_events.death = "RockElementalDeath"
tt.ui.click_rect = r(-25, -2, 50, 52)
tt.unit.blood_color = BLOOD_RED
tt.unit.hit_offset = v(0, 15)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.vis.bans = bor(F_LYCAN)

tt = E:register_t("shaolin_monk_lvl1_hit_fx", "fx")
E:add_comps(tt, "sound_events")
--tt.render.sprites[1].anchor.y = 0
tt.render.sprites[1].name = "shaolin_monk_lvl1_hit_effect_run"
tt.render.sprites[1].animated = true
tt.sound_events.insert = "ShaolinAttack"

tt = E:register_t("shaolin_monk_lvl4_hit_fx", "shaolin_monk_lvl1_hit_fx")
E:add_comps(tt, "sound_events")
tt.render.sprites[1].name = "shaolin_monk_lvl4_hit_effect_run"

tt = E:register_t("bullet_shaolin_lvl1", "arrow")
tt.bullet.damage_min = 2
tt.bullet.damage_max = 4
tt.bullet.hit_fx = "shaolin_monk_lvl1_hit_fx"
tt.render.sprites[1].name = nil
tt.render.sprites[1].hidden = true
tt.sound_events.insert = nil
tt.bullet.damage_type = DAMAGE_PHYSICAL

tt = E:register_t("bullet_shaolin_lvl2", "bullet_shaolin_lvl1")
tt.bullet.damage_min = 6
tt.bullet.damage_max = 10
tt.bullet.hit_fx = "shaolin_monk_lvl1_hit_fx"

tt = E:register_t("bullet_shaolin_lvl3", "bullet_shaolin_lvl1")
tt.bullet.damage_min = 11
tt.bullet.damage_max = 17
tt.bullet.hit_fx = "shaolin_monk_lvl1_hit_fx"

tt = E:register_t("bullet_shaolin_lvl4", "bullet_shaolin_lvl1")
tt.bullet.damage_min = 14
tt.bullet.damage_max = 26
--tt.bullet.hit_fx = "shaolin_monk_lvl4_hit_fx"

tt = E:register_t("decal_shaolin_lvl1", "decal_scripted")
E:add_comps(tt, "idle_flip", "soldier", "unit", "tween")
tt.idle_flip.animations = {
	"idle"
}
tt.idle_flip.cooldown = fts(90)
tt.idle_flip.loop = false
tt.main_script.update = kr4_scripts.decal_shaolin.update
tt.render.sprites[1].prefix = "shaolin_monk_lvl1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor.y = 1 / 9
tt.render.sprites[1].z = Z_BULLETS
tt.soldier.melee_slot_offset = v(0, 0)
tt.attack_ts = 0
tt.target_id = nil
tt.attack = nil
tt.attack_level = nil
tt.tween.disabled = true
tt.tween.remove = false
tt.tween.props[1].name = "offset"
tt.tween.props[1].interp = "sine"
tt.tween.props[1].keys = {
	{
		0,
		v(0, 0)
	},
	{
		fts(6),
		v(0, 1)
	},
	{
		fts(11),
		v(0, 0)
	}
}
tt.tween.props[1].loop = false
tt.tween.props[1].disabled = true
tt.tween.props[1].sprite_id = 1

tt = E:register_t("decal_shaolin_lvl2", "decal_shaolin_lvl1")
tt.render.sprites[1].prefix = "shaolin_monk_lvl2"

tt = E:register_t("decal_shaolin_lvl3", "decal_shaolin_lvl1")
tt.render.sprites[1].prefix = "shaolin_monk_lvl3"

tt = E:register_t("decal_shaolin_lvl4", "decal_shaolin_lvl1")
tt.soldier.melee_slot_offset = v(5, 0)
tt.render.sprites[1].prefix = "shaolin_monk_lvl4"
tt.render.sprites[1].anchor.y = 2 / 9

tt = E:register_t("decal_shaolin_gold", "aura")
E:add_comps(tt, "pos", "render","sound_events")
tt.aura.duration = fts(36)
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "shaolin_abundance_coin"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS
tt.sound_events.insert = nil


----------------------------------------------
---------------------冰龙----------------------
----------------------------------------------
tt = E:register_t("hero_eiskalt", "hero")

E:add_comps(tt, "ranged", "timed_attacks")

image_y = 308
anchor_y = 0.12962962962962962
tt.hero.level_stats.hp_max = {
	360,
	390,
	420,
	450,
	480,
	510,
	540,
	570,
	600,
	630
}
tt.hero.level_stats.regen_health = {
	22,
	25,
	28,
	31,
	34,
	37,
	40,
	43,
	46,
	49
}
tt.hero.level_stats.armor = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
}
tt.hero.level_stats.ranged_damage_min = {
	17,
	23,
	29,
	34,
	39,
	43,
	49,
	55,
	60,
	66
}
tt.hero.level_stats.ranged_damage_max = {
	24,
	32,
	41,
	49,
	57,
	66,
	74,
	82,
	90,
	98
}

--1技能 爆炸
tt.hero.skills.explosion = E:clone_c("hero_skill")

tt.hero.skills.explosion.damage_radius = {
	[0] = 20,
	40,
	60,
	80
}

--2技能 减速
tt.hero.skills.coldfury = E:clone_c("hero_skill")
tt.hero.skills.coldfury.cooldown = {
	20,
	16,
	12
}
tt.hero.skills.coldfury.xp_gain_factor = 160

--3技能 冰球，原技能瘟疫球
tt.hero.skills.frosty = E:clone_c("hero_skill")
tt.hero.skills.frosty.xp_gain_factor = 180
tt.hero.skills.frosty.damage_min = {
	80,
	160,
	240
}
tt.hero.skills.frosty.damage_max = {
	80,
	160,
	240
}

--4技能 冰刺，原技能脊骨雨
tt.hero.skills.icepeak = E:clone_c("hero_skill")
tt.hero.skills.icepeak.xp_gain_factor = 274
tt.hero.skills.icepeak.count = {
	8,
	8,
	8
}
tt.hero.skills.icepeak.damage_min = {
	500,
	1000,
	1500
}
tt.hero.skills.icepeak.damage_max = {
	500,
	1000,
	1500
}

tt.hero.use_custom_spawn_point = true

tt.hero.skills.explosion.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.explosion.hr_icon = 401
tt.hero.skills.explosion.hr_order = 1
tt.hero.skills.coldfury.hr_cost = {
	3,
	2,
	1
}
tt.hero.skills.coldfury.cooldown_time = {
	20,
	16,
	12
}
tt.hero.skills.coldfury.hr_icon = 402
tt.hero.skills.coldfury.hr_order = 2
tt.hero.skills.frosty.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.frosty.hr_icon = 403
tt.hero.skills.frosty.hr_order = 3
tt.hero.skills.icepeak.hr_cost = {
	2,
	2,
	2
}
tt.hero.skills.icepeak.hr_icon = 404
tt.hero.skills.icepeak.hr_order = 4

tt.hero.skills.ultimate = E:clone_c("hero_skill")
tt.hero.skills.ultimate.controller_name = "hero_eiskalt_ultimate"
tt.hero.skills.ultimate.duration = {
	[0] = 4,
	6,
	8,
	12
}
tt.hero.skills.ultimate.hr_cost = {
	4,
	4,
	4
}
tt.hero.skills.ultimate.hr_icon = 405
tt.hero.skills.ultimate.hr_order = 5
tt.hero.skills.ultimate.key = "DRONES"


tt.health.armor = nil
tt.health.dead_lifetime = 22.5
tt.health.hp_max = nil
tt.health_bar.offset = v(0, 157)
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.draw_order = -1
tt.health_bar.sort_y_offset = -200
tt.hero.fn_level_up = kr4_scripts.hero_eiskalt.level_up
tt.hero.tombstone_show_time = nil
tt.idle_flip.cooldown = 10
tt.drag_line_origin_offset = v(0, 80)
tt.info.fn = kr4_scripts.hero_eiskalt.get_info
tt.info.hero_portrait = "kra_hero_portraits_0412"
tt.info.ultimate_icon = "0412"
tt.info.portrait = "gui4_bottom_info_image_heroes_0015"
tt.info.damage_icon = "magic"
tt.main_script.insert = kr4_scripts.hero_eiskalt.insert
tt.main_script.update = kr4_scripts.hero_eiskalt.update
tt.motion.max_speed = 90
tt.nav_rally.requires_node_nearby = false
tt.nav_grid.ignore_waypoints = true
tt.nav_grid.valid_terrains = TERRAIN_ALL_MASK
tt.nav_grid.valid_terrains_dest = TERRAIN_ALL_MASK
tt.regen.cooldown = 1
tt.regen.health = nil
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "hero_eiskalt"
tt.render.sprites[1].angles.walk = {
	"idle"
}
tt.render.sprites[1].sort_y_offset = -200
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "hero_eiskalt_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.sound_events.change_rally_point = "HeroEiskaltTaunt"
tt.sound_events.death = "HeroEiskaltTauntDeath"
tt.sound_events.respawn = "HeroDracolichRespawn"
tt.sound_events.insert = "HeroEiskaltTaunt"
tt.sound_events.hero_room_select = "HeroEiskaltTauntSelect"
tt.ui.click_rect = r(-25, 70, 50, 45)
tt.unit.blood_color = BLOOD_GRAY
tt.unit.hit_offset = v(0, 98)
tt.unit.hide_after_death = true
tt.unit.marker_offset = v(0, -0.15)
tt.unit.mod_offset = v(0, 101)
tt.vis.bans = bor(tt.vis.bans, F_EAT, F_NET, F_POISON)
tt.vis.flags = bor(tt.vis.flags, F_FLYING)
tt.ranged.attacks[1] = E:clone_c("bullet_attack")
tt.ranged.attacks[1].bullet = "fireball_eiskalt"
tt.ranged.attacks[1].bullet_start_offset = {
	v(46, 52)
}
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].max_range = 220
tt.ranged.attacks[1].shoot_time = fts(13)
tt.ranged.attacks[1].sync_animation = true
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].animation = "range_attack"
tt.ranged.attacks[1].estimated_flight_time = fts(24)
tt.ranged.attacks[1].sound = "HeroDracolichAttack"

--瘟疫载体->大雪球
tt.timed_attacks.list[1] = E:clone_c("spawn_attack")
tt.timed_attacks.list[1].animation = "frosty"
tt.timed_attacks.list[1].cooldown = 18
tt.timed_attacks.list[1].disabled = true
tt.timed_attacks.list[1].entity = "bullet_eiskalt_frosty"--"hero_eiskalt_frosty"
tt.timed_attacks.list[1].spawn_offset = v(12, 60)
tt.timed_attacks.list[1].spawn_time = fts(20)
tt.timed_attacks.list[1].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[1].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[1].range_nodes_max = 50
tt.timed_attacks.list[1].range_nodes_min = 10
tt.timed_attacks.list[1].sound = "HeroDracolichSoulsPlague"
--脊柱雨->冰刺
tt.timed_attacks.list[2] = E:clone_c("spawn_attack")
tt.timed_attacks.list[2].animation = "icePeaks"
tt.timed_attacks.list[2].cooldown = 15
tt.timed_attacks.list[2].disabled = true
tt.timed_attacks.list[2].entity = "eiskalt_icepeaks"
tt.timed_attacks.list[2].spawn_time = fts(8)
tt.timed_attacks.list[2].vis_flags = bor(F_RANGED)
tt.timed_attacks.list[2].vis_bans = bor(F_FLYING)
tt.timed_attacks.list[2].min_range = 0
tt.timed_attacks.list[2].max_range = 200
tt.timed_attacks.list[2].damage_max = 200
tt.timed_attacks.list[2].damage_min = 200
--撞击地面->冻土
tt.timed_attacks.list[3] = CC("aura_attack")
tt.timed_attacks.list[3].animation = "coldFury"
tt.timed_attacks.list[3].bullet = "aura_chill_eiskalt"
tt.timed_attacks.list[3].cast_time = fts(25)
tt.timed_attacks.list[3].cooldown = 20
tt.timed_attacks.list[3].disabled = true
tt.timed_attacks.list[3].max_range = 125
tt.timed_attacks.list[3].min_range = 20
tt.timed_attacks.list[3].sound = "HeroFrostGroundFreeze"
tt.timed_attacks.list[3].step = 3
tt.timed_attacks.list[3].nodes_offset = 6
tt.timed_attacks.list[3].vis_bans = bor(F_FLYING, F_FRIEND)
tt.timed_attacks.list[3].vis_flags = F_RANGED
tt.timed_attacks.list[3].xp_from_skill = "coldfury"


tt = RT("mod_eiskalt_chill_lvl1", "mod_slow")
tt.modifier.duration = 3
tt.slow.factor = 0.5

tt = RT("mod_eiskalt_chill_lvl2", "mod_slow")
tt.modifier.duration = fts(11)
tt.slow.factor = 0.5

tt = RT("mod_eiskalt_chill_lvl3", "mod_slow")
tt.modifier.duration = fts(15)
tt.slow.factor = 0.5


tt = RT("fx_aura_chill_eiskalt_smoke", "decal_scripted")
AC(tt, "tween")
tt.main_script.update = kr4_scripts.eiskalt_cold_fury_smoke.update
tt.render.sprites[1].name = "hero_eiskalt_cold_fury_smoke_run"
tt.render.sprites[1].animated = true
tt.tween.disabled = true
tt.tween.props[1].keys = {
    { fts(20), 255 },
    { fts(40), 0 }
}

tt = RT("aura_chill_eiskalt", "aura")

AC(tt, "render", "tween")

tt.aura.cycle_time = fts(10)
tt.aura.duration = 5
tt.aura.mod = "mod_eiskalt_chill_lvl2"
tt.aura.radius = 44.800000000000004
tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
tt.aura.vis_flags = bor(F_ENEMY)
tt.aura.hit_decal = "fx_aura_chill_eiskalt_smoke"
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = kr1_scripts.aura_chill_elora.update
tt.render.sprites[1].name = "hero_eiskalt_cold_fury_ice"
tt.render.sprites[1].loop = false
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = true
tt.tween.disabled = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		0.2,
		0
	}
}

tt = E:register_t("fx_fireball_eiskalt_decal", "decal_tween")
tt.render.sprites[1].name = "hero_eiskalt_proyectile_travel"
tt.render.sprites[1].animated = false
tt.tween.props[1].keys = {
	{
		fts(17),
		255
	},
	{
		fts(27),
		0
	}
}
tt = E:register_t("fx_fireball_eiskalt_ground", "fx")
tt.render.sprites[1].name = "hero_eiskalt_explosion_run"
tt.render.sprites[1].anchor.y = 0.20512820512820512
tt.render.sprites[1].sort_y_offset = -5
tt = E:register_t("fx_fireball_eiskalt_air", "fx")
tt.render.sprites[1].name = "hero_eiskalt_explosion_air_run"
tt.render.sprites[1].anchor.y = 0.24
tt.render.sprites[1].scale = v(0.7, 0.7)
tt = E:register_t("ps_fireball_eiskalt")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_eiskalt_particle_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.particle_lifetime = {
	fts(11),
	fts(16)
}
tt.particle_system.scale_var = {
	0.78,
	1.43
}
tt.particle_system.scales_x = {
	1,
	1.25
}
tt.particle_system.scales_y = {
	1,
	1.25
}
tt.particle_system.emission_rate = 20
tt.particle_system.emit_rotation_spread = math.pi
tt.particle_system.alphas = {
	255,
	0
}
tt = E:register_t("fireball_eiskalt", "bullet")
tt.render.sprites[1].name = "hero_eiskalt_proyectile_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].anchor.x = 0.69
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.min_speed = 390
tt.bullet.max_speed = 390
tt.bullet.hit_fx = "fx_fireball_eiskalt_ground"
tt.bullet.hit_fx_air = "fx_fireball_eiskalt_air"
tt.bullet.hit_decal = "fx_fireball_eiskalt_decal"
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 20
tt.bullet.xp_gain_factor = 0.8
tt.bullet.particles_name = "ps_fireball_eiskalt"
tt.bullet.vis_flags = F_RANGED
tt.bullet.mod = "mod_eiskalt_chill_lvl1"
tt.main_script.update = kr4_scripts.fireball_eiskalt.update
tt.sound_events.hit = "HeroDragonAttackHit"

tt = E:register_t("eiskalt_icepeaks", "bullet")

E:add_comps(tt, "tween")

tt.main_script.update = kr4_scripts.eiskalt_icepeaks.update
tt.bullet.damage_max = nil
tt.bullet.damage_min = nil
tt.bullet.damage_radius = 27.5
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.damage_flags = F_AREA
tt.bullet.damage_bans = F_FRIEND
tt.bullet.mod = nil
tt.bullet.hit_time = fts(4)
tt.bullet.duration = 2
tt.render.sprites[1].prefix = "hero_eiskalt_ice_peaks"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].anchor.y = 0.09027777777777778
tt.render.sprites[1].z = Z_OBJECTS
tt.tween.remove = false
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		fts(3),
		0
	},
	{
		fts(6),
		255
	},
	{
		tt.bullet.duration,
		255
	},
	{
		tt.bullet.duration + fts(10),
		0
	}
}
--tt.tween.props[1].sprite_id = 2
tt.sound_events.delayed_insert = "HeroEiskaltPeak"


tt = E:register_t("fx_eiskalt_rider_hit", "fx")
tt.render.sprites[1].name = "hero_eiskalt_proyectile_travel"

tt = E:register_t("ps_eiskalt_rider_trail_A")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_eiskalt_particle_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 6
tt.particle_system.emit_area_spread = v(15, 15)
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.z = Z_OBJECTS
tt.particle_system.particle_lifetime = {
	fts(13),
	fts(13)
}
tt.particle_system.emit_offset = v(0, 0)
tt.emit_offset_relative = v(-10, 0)
tt = E:register_t("ps_eiskalt_rider_trail_B")

E:add_comps(tt, "pos", "particle_system")

tt.particle_system.name = "hero_eiskalt_particle_run"
tt.particle_system.animated = true
tt.particle_system.loop = false
tt.particle_system.emission_rate = 8
tt.particle_system.emit_area_spread = v(15, 15)
tt.particle_system.anchor = v(0.5, 0.5)
tt.particle_system.z = Z_OBJECTS + 1
tt.particle_system.particle_lifetime = {
	fts(9),
	fts(9)
}
tt.particle_system.emit_offset = v(0, 0)
tt.emit_offset_relative = v(-10, 0)

tt = E:register_t("fx_eiskalt_frosty_spawn", "fx")
tt.render.sprites[1].name = "hero_eiskalt_frosty_explotion_run"
tt.render.sprites[1].anchor.y = 0.4

tt = E:register_t("bullet_eiskalt_frosty", "bombKR5")
tt.sound_events.insert = nil
tt.sound_events.hit = nil
tt.bullet.flight_time = fts(30)
tt.bullet.hit_fx = "fx_eiskalt_frosty_spawn"
tt.bullet.pop = nil
tt.bullet.pop_chance = 0
tt.bullet.rotation_speed = 4 * math.pi
tt.bullet.hit_payload = "aura_eiskalt_rider"
tt.bullet.damage_max = 0
tt.bullet.damage_min = 0
tt.bullet.damage_radius = 0
tt.render.sprites[1].name = "hero_eiskalt_frosty_projectile"
tt.render.sprites[1].animated = false

tt = E:register_t("aura_eiskalt_rider", "aura")
b = balance.towers.necromancer5.skill_rider

E:add_comps(tt, "render","nav_path", "tween", "motion")

tt.aura.mod = "mod_eiskalt_chill_lvl3"
tt.aura.radius = 75
tt.aura.vis_flags = bor(F_AREA)
tt.aura.vis_bans = bor(F_FLYING)
tt.aura.duration = 6
tt.aura.cycle_time = fts(5)
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "hero_eiskalt_frosty"
tt.render.sprites[1].sort_y_offset = -60
tt.render.sprites[1].animated = true
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = kr4_scripts.aura_eiskalt_skill_rider.update
tt.tween.props[1].name = "alpha"
tt.tween.props[1].keys = {
	{
		0,
		0
	},
	{
		0.5,
		255
	}
}
tt.tween.props[1].sprite_id = 1
tt.tween.remove = false
tt.motion.max_speed = 90
tt.damage_min = nil
tt.damage_max = nil
tt.damage_min_config = {32,64,96}
tt.damage_max_config = {32,64,96}
tt.damage_type = DAMAGE_PHYSICAL
tt.hit_fx = "fx_eiskalt_rider_hit"
--tt.spawn_side_fx = "hero_eiskalt_frosty_walk"
--tt.spawn_front_fx = "hero_eiskalt_frosty_walkDown"
--tt.spawn_back_fx = "hero_eiskalt_frosty_walkUp"
tt.particles_name_A = "ps_eiskalt_rider_trail_A"--"hero_eiskalt_particle_run"
tt.particles_name_B = "ps_eiskalt_rider_trail_B"--"hero_eiskalt_particle_run"
tt.sound_events.insert = "HeroEiskaltFrosty"

--代码没问题了，但是动画可能有问题，需要参见5代亡灵骑士的动画
--[[
tt = E:register_t("hero_eiskalt_frostyx", "aura")

E:add_comps(tt, "render", "nav_path", "motion", "tween")

tt.aura.duration = 3
tt.aura.duration_var = 1.0
tt.aura.damage_min = 32
tt.aura.damage_max = 32
tt.aura.damage_radius = 50
tt.aura.damage_type = DAMAGE_TRUE
tt.aura.damage_cycle = fts(3)
tt.aura.damage_flags = F_AREA
tt.aura.damage_bans = 0
tt.motion.max_speed = 3.5 * FPS
tt.motion.max_speed_var = 0.25 * FPS
tt.main_script.insert = kr4_scripts.hero_eiskalt_frosty.insert
tt.main_script.update = kr4_scripts.hero_eiskalt_frosty.update
tt.render.sprites[1].prefix = "hero_eiskalt_frosty"
tt.render.sprites[1].sort_y_offset = -21
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].animated = true
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.tween.disabled = true
tt.tween.remove = true
tt.tween.props[1].keys = {
	{
		0,
		255
	},
	{
		tt.aura.duration_var,
		0
	}
}
]]--
tt = E:register_t("fx_power_eiskalt_drop", "fx")

E:add_comps(tt, "tween")

tt.render.sprites[1].name = "hero_eiskalt_copo"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor.x = 1
tt.render.sprites[1].scale = v(0.5,0.5)
tt.render.sprites[1].z = Z_OBJECTS_SKY

tt = RT("hero_eiskalt_ultimate")

E:add_comps(tt, "user_item", "pos", "main_script", "user_selection","sound_events")

tt.can_fire_fn = kr4_scripts.hero_eiskalt_ultimate.can_fire_fn
tt.cooldown = 40
tt.duration = 12
tt.sound_events.insert = "HeroEiskaltBreath"

tt.main_script.insert = kr4_scripts.hero_eiskalt_ultimate.insert
tt.main_script.update = kr4_scripts.hero_eiskalt_ultimate.update
tt.excluded_templates = {
		"eb_umbra",
		"enemy_umbra_piece",
		"enemy_umbra_piece_flying",
		"enemy_tremor",
		"enemy_headless_horseman"
}
tt.vis_flags = bor(F_RANGED, F_FREEZE)
tt.vis_bans = 0

tt.rain = {}
tt.rain.alpha_max = 255
tt.rain.alpha_min = 150
tt.rain.angle_between = 2 * math.pi / 180
tt.rain.angle_max = -60 * math.pi / 180
tt.rain.angle_min = -80 * math.pi / 180
tt.rain.cooldown = 0.25
tt.rain.count = 6
tt.rain.delay_max = 0.25
tt.rain.disabled = false
tt.rain.distance_max = 550
tt.rain.distance_min = 450
tt.rain.duration = 0.25
tt.rain.ts = 0

tt.freeze_alpha_min = 80
tt.freeze_alpha_max = 112

tt.mod = "mod_eiskalt_freeze"

tt = E:register_t("mod_eiskalt_freeze", "mod_freeze")
E:add_comps(tt, "render")
tt.modifier.duration = 1
tt.render.sprites[1].prefix = "freeze_creep"
tt.render.sprites[1].sort_y_offset = -2
tt.custom_offsets = {}
tt.custom_offsets.flying = v(-5, 32)
tt.custom_offsets.enemy_wasp_queen = v(-5, 38)
tt.custom_offsets.eb_efreeti = v(100, 15)
tt.custom_suffixes = {}
tt.custom_suffixes.flying = "_air"
tt.custom_animations = {
		"start",
		"end"
}

tt = RT("overlay_eiskalt_freeze", "overlay_power_thunder_flash")
tt.render.sprites[1].color = { 223, 223, 255, 255 }
tt.render.sprites[2] = nil
tt.tween.props[2] = nil


----------------------------------------------
-------------------沼泽巨人--------------------
----------------------------------------------
--建造
tt = E:register_t("tower_build_swamp_monster", "tower_build")
tt.build_name = "tower_swamp_monster_lvl1"
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[1].animated = false
tt.render.sprites[1].hidden = true
tt.render.sprites[2].name = "swamp_monster_towers_lvl1_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(0, 20)--v(0, 30)
tt.render.sprites[3].offset.y = 62
tt.render.sprites[4].offset.y = 62

tt = E:register_t("tower_swamp_monster_lvl1", "tower_barrack_1")
AC(tt, "tower_upgrade_persistent_data", "attacks")
tt.info.fn = kr4_scripts.tower_swamp_monster.get_info
--tt.info.portrait = "info_portraits_towers_0002"
tt.info.portrait = "gui4_bottom_info_image_towers_0023"
tt.info.i18n_key = "TOWER_SWAMP_MONSTER_LEVEL1"
tt.main_script.insert = kr4_scripts.tower_swamp_monster.insert
tt.main_script.remove = kr4_scripts.tower_swamp_monster.remove
tt.main_script.update = kr4_scripts.tower_swamp_monster.update
tt.tower.type = "swamp_monster"
tt.tower.price = 120
tt.tower.level = 1
tt.barrack.max_soldiers = 1
tt.barrack.soldier_type = "swamp_monster_soldier_lvl1"
tt.barrack.rally_range = 137.5
tt.barrack.rally_angle_offset = -0.4
tt.render.sprites[1].name = "swamp_monster_towers_lvl1_0002"
tt.render.sprites[1].offset = v(0, 20)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "swamp_monster_tower_shooter_lvl1"
tt.render.sprites[2].angles = {
	idle = {
		"idleUp",
		"idle"
	},
	shoot = {
		"shootUp",
		"shootDown"
	},
}
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].offset = v(0, 20)
tt.attacks.range = 185
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].shoot_time = fts(8)
tt.attacks.list[1].shooters_delay = 0.1
tt.attacks.list[1].bullet = "bullet_swamp_monster_lvl1"
tt.attacks.list[1].bullet_start_offset = v(0, 55)
tt.attacks.list[1].cooldown = 2.1
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].sound = "SwampMonsterAttack"
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
table.remove(tt.render.sprites, 3)
tt.sound_events.insert = "SwampMonsterTaunt"
tt.sound_events.change_rally_point = "SwampMonsterTauntChange"
tt.tower.kind = TOWER_KIND_BARRACK

tt = E.register_t(E, "tower_swamp_monster_lvl2", "tower_swamp_monster_lvl1")
tt.info.i18n_key = "TOWER_SWAMP_MONSTER_LEVEL2"
tt.tower.price = 150
tt.tower.level = 2
tt.barrack.soldier_type = "swamp_monster_soldier_lvl2"
tt.render.sprites[1].name = "swamp_monster_towers_lvl2_0001"
tt.render.sprites[2].prefix = "swamp_monster_tower_shooter_lvl2"
tt.attacks.list[1].bullet = "bullet_swamp_monster_lvl2"
tt.attacks.range = 215

tt = E.register_t(E, "tower_swamp_monster_lvl3", "tower_swamp_monster_lvl1")
tt.info.i18n_key = "TOWER_SWAMP_MONSTER_LEVEL3"
tt.tower.price = 210
tt.tower.level = 3
tt.barrack.soldier_type = "swamp_monster_soldier_lvl3"
tt.render.sprites[1].name = "swamp_monster_towers_lvl3_0001"
tt.render.sprites[2].prefix = "swamp_monster_tower_shooter_lvl3"
tt.attacks.list[1].bullet = "bullet_swamp_monster_lvl3"
tt.attacks.range = 250

tt = E.register_t(E, "tower_swamp_monster_lvl4", "tower_swamp_monster_lvl1")
AC(tt, "powers")

tt.info.i18n_key = "TOWER_SWAMP_MONSTER_LEVEL4"
tt.tower.price = 290
tt.tower.level = 4
tt.attacks.range = 300
tt.attacks.list[1].bullet = "bullet_swamp_monster_lvl4"
tt.barrack.soldier_type = "swamp_monster_soldier_lvl4"
tt.render.sprites[1].name = "swamp_monster_towers_lvl4_0001"
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "swamp_monster_tower_smoke"
tt.render.sprites[2].name = "run"
tt.render.sprites[2].offset = v(-5, 15)
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "swamp_monster_tower_smoke"
tt.render.sprites[3].name = "run"
tt.render.sprites[3].offset = v(5, 15)

for i = 4, 6 do
	tt.render.sprites[i] = E:clone_c("sprite")
	tt.render.sprites[i].prefix = "swamp_monster_tower_shooter_lvl4_layer" .. i - 3
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].offset = v(0, -5)
	tt.render.sprites[i].anchor.y = 0.228
	tt.render.sprites[i].group = "layers"
	tt.render.sprites[i].angles = {
		idle = {
			"idleUp",
			"idle"
		},
		shoot = {
			"shootUp",
			"shootDown"
		},
	}
end
tt.attacks.list[1].bullet = "bullet_swamp_monster_lvl4"
tt.powers.stun = CC("power")
tt.powers.stun.price_base = 120
tt.powers.stun.price_inc = 120
tt.powers.stun.mod = "mod_goblirang_stun"
tt.powers.stun.enc_icon = 365
tt.powers.stun.mod_chance = {0.2,0.4,0.6}
tt.powers.instakill = CC("power")
tt.powers.instakill.price_base = 140
tt.powers.instakill.price_inc = 140
tt.powers.instakill.enc_icon = 366
tt.powers.instakill.mod_chance = {0.02,0.04,0.06}
tt.powers.eat = CC("power")
tt.powers.eat.price_base = 140
tt.powers.eat.enc_icon = 367
tt.powers.eat.max_level = 1
tt.powers.eat.hp = 1050

tt = E:register_t("fx_sm_splat", "fx")
tt.render.sprites[1].name = "swamp_monster_tower_explosion_run"

local arrow = E:register_t("bullet_swamp_monster_lvl4", "arrow")
arrow.bullet.hit_distance = 50
arrow.bullet.hit_fx = "fx_sm_splat"
arrow.bullet.miss_fx = "fx_sm_splat"
arrow.bullet.miss_decal = nil
--arrow.bullet.hit_blood_fx = "fx_blood_splat_wicked_sisters"
arrow.bullet.flight_time = fts(18)
arrow.bullet.damage_type = DAMAGE_PHYSICAL
arrow.render.sprites[1].name = "swamp_monster_tower_proyectile_lvl4"
arrow.render.sprites[1].animated = false
arrow.sound_events.insert = "SwampMonsterAttack"
arrow.sound_events.hit = "SwampMonsterExplosion"
arrow.bullet.prediction_error = false
arrow.bullet.predict_target_pos = true
arrow.bullet.damage_min = 90
arrow.bullet.damage_max = 100
arrow.bullet.mod = nil--"mod_wicked_sister_poison_lvl1"
arrow.bullet.particles_name = nil --"ps_bullet_tower_wicked_sisters_basic_trail"

local arrow = E:register_t("bullet_swamp_monster_lvl1", "bullet_swamp_monster_lvl4")
arrow.render.sprites[1].name = "swamp_monster_tower_proyectile_lvl1"
arrow.bullet.damage_min = 19
arrow.bullet.damage_max = 21

local arrow = E:register_t("bullet_swamp_monster_lvl2", "bullet_swamp_monster_lvl4")
arrow.render.sprites[1].name = "swamp_monster_tower_proyectile_lvl2"
arrow.bullet.damage_min = 38
arrow.bullet.damage_max = 42

local arrow = E:register_t("bullet_swamp_monster_lvl3", "bullet_swamp_monster_lvl4")
arrow.render.sprites[1].name = "swamp_monster_tower_proyectile_lvl3"
arrow.bullet.damage_min = 65
arrow.bullet.damage_max = 71

tt = RT("swamp_monster_soldier_lvl1", "soldier_elemental")
tt.info.portrait = "gui4_bottom_info_image_soldiers_0052"
tt.main_script.insert = kr4_scripts.soldier_swamp_monster.insert
tt.main_script.update = kr4_scripts.soldier_swamp_monster.update
tt.info.i18n_key = "TOWER_SWAMP_MONSTER_MENU"
tt.health.armor = 0
tt.health.armor_inc = 0
tt.health.dead_lifetime = 20
tt.health.hp_max = 800
tt.health.hp_inc = 0
tt.health_bar.offset = v(0, 48)

tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].count = 5
tt.melee.attacks[1].damage_inc = 0
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 10
tt.melee.attacks[1].damage_radius = 75
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_decal = "decal_ground_hit"
--tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(35, 0)
tt.melee.attacks[1].hit_time = fts(14)
tt.melee.attacks[1].pop = {
	"pop_whaam",
	"pop_kapow"
}
tt.melee.attacks[1].pop_chance = 0.3
tt.melee.attacks[1].sound_hit = "SwampMonsterAttack"
tt.melee.attacks[1].chance = 1
tt.melee.range = 75
tt.motion.max_speed = 35
tt.regen.health = 8
tt.render.sprites[1].anchor.y = 1 / 6
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {
	"running"
}
tt.render.sprites[1].name = "raise"
tt.render.sprites[1].prefix = "swamp_monster_unit_lvl1"
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "swamp_monster_unit_lvl1_shadow"
tt.render.sprites[2].anchor.y = 0.175
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.soldier.melee_slot_offset = v(15, 0)
tt.sound_events.insert = "SwampMonsterOut"
tt.sound_events.death = "SwampMonsterIn"
tt.ui.click_rect = r(-25, -2, 50, 52)
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = v(0, 15)
tt.unit.marker_offset = v(0, -2)
tt.unit.mod_offset = v(0, 16)
tt.vis.bans = bor(F_LYCAN, F_POISON)--bor(F_LYCAN,F_INSTAKILL,F_POLYMORPH,F_DISINTEGRATED,F_POISON)

tt = RT("swamp_monster_soldier_lvl2", "swamp_monster_soldier_lvl1")
tt.info.portrait = "gui4_bottom_info_image_soldiers_0053"
tt.health.hp_max = 1500
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_min = 20
tt.regen.health = 16
tt.render.sprites[1].prefix = "swamp_monster_unit_lvl2"
tt.render.sprites[1].anchor.x = 0.49
tt.render.sprites[2].name = "swamp_monster_unit_lvl2_shadow"
tt.health_bar.offset = v(0, 52)

tt = RT("swamp_monster_soldier_lvl3", "swamp_monster_soldier_lvl1")
tt.info.portrait = "gui4_bottom_info_image_soldiers_0054"
tt.health.hp_max = 2200
tt.melee.attacks[1].damage_max = 70
tt.melee.attacks[1].damage_min = 40
tt.regen.health = 24
tt.render.sprites[1].prefix = "swamp_monster_unit_lvl3"
tt.render.sprites[1].anchor.x = 0.505
tt.render.sprites[2].name = "swamp_monster_unit_lvl3_shadow"
tt.health_bar.offset = v(0, 58)

tt = RT("swamp_monster_soldier_lvl4", "swamp_monster_soldier_lvl1")
AC( tt, "powers")
tt.info.portrait = "gui4_bottom_info_image_soldiers_0055"
tt.powers.stun = CC("power")
tt.powers.stun.mod = "mod_goblirang_stun"
tt.powers.stun.enc_icon = 365
tt.powers.stun.mod_chance = {0.2,0.4,0.6}
tt.powers.instakill = CC("power")
tt.powers.instakill.enc_icon = 366
tt.powers.instakill.mod_chance = {0.02,0.04,0.06}
tt.powers.eat = CC("power")
tt.powers.eat.enc_icon = 367
tt.powers.eat.max_level = 1
tt.health.hp_max = 3000
tt.regen.health = 30
tt.render.sprites[1].prefix = "swamp_monster_unit_lvl4"
tt.render.sprites[1].anchor.y = 0.22
tt.render.sprites[2].name = "swamp_monster_unit_lvl4_shadow"
tt.render.sprites[2].anchor.y = 0.22
tt.health_bar.offset = v(0, 64)
tt.melee.cooldown = 2.5
tt.melee.attacks[1] = CC("area_attack")
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].shared_cooldown = 2.5
tt.melee.attacks[1].count = 5
tt.melee.attacks[1].damage_inc = 0
tt.melee.attacks[1].damage_max = 90
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_radius = 75
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
--tt.melee.attacks[1].hit_decal = "decal_ground_hit"
--tt.melee.attacks[1].hit_fx = "fx_ground_hit"
tt.melee.attacks[1].hit_offset = v(35, 0)
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].pop = {
	"pop_whaam",
	"pop_kapow"
}
tt.melee.attacks[1].pop_chance = 0.3
tt.melee.attacks[1].sound_hit = "SwampMonsterAttack"
tt.melee.attacks[1].chance = 1
tt.melee.attacks[2] = CC("area_attack")
tt.melee.attacks[2].cooldown = 2.5
tt.melee.attacks[2].shared_cooldown = 2.5
tt.melee.attacks[2].count = 5
tt.melee.attacks[2].damage_inc = 0
--tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].damage_max = 90
tt.melee.attacks[2].damage_min = 50
tt.melee.attacks[2].damage_radius = 75
tt.melee.attacks[2].damage_type = DAMAGE_PHYSICAL
--tt.melee.attacks[2].hit_decal = "decal_ground_hit"
--tt.melee.attacks[2].hit_fx = "fx_ground_hit"
tt.melee.attacks[2].hit_offset = v(35, 0)
tt.melee.attacks[2].hit_time = fts(13)
tt.melee.attacks[2].mod ="mod_swamp_stun"
tt.melee.attacks[2].animation = "stun"
tt.melee.attacks[2].pop = {
	"pop_whaam",
	"pop_kapow"
}
tt.melee.attacks[2].pop_chance = 0.3
tt.melee.attacks[2].sound_hit = "SwampMonsterExplosion"
tt.melee.attacks[2].chance = 0
tt.melee.attacks[2].chance_inc = 0.2
tt.melee.attacks[3] = E.clone_c(E, "melee_attack")
tt.melee.attacks[3].animation = "instakill"
tt.melee.attacks[3].chance = 0
tt.melee.attacks[3].chance_inc = 0.02
tt.melee.attacks[3].cooldown = 2.5
tt.melee.attacks[3].shared_cooldown = 2.5
--tt.melee.attacks[3].disabled = true
tt.melee.attacks[3].hit_time = fts(18)
tt.melee.attacks[3].instakill = true
tt.melee.attacks[3].sound_hit = "SwampMonsterExplosion"
tt.melee.attacks[3].damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_FX_EXPLODE, DAMAGE_NO_DODGE)
tt.melee.attacks[3].pop = {
  "pop_instakill"
}
tt.melee.attacks[3].pop_chance = 1
tt.melee.attacks[3].power_name = "instakill"
tt.melee.attacks[3].forced_cooldown = true
tt.melee.attacks[3].vis_bans = bor(F_FLYING, F_CLIFF, F_BOSS)
tt.melee.attacks[3].vis_flags = F_BLOCK

tt = RT("mod_swamp_stun", "mod_stun")

E.add_comps(E, tt, "render")

tt.modifier.duration = 3
tt.modifier.vis_bans = F_BOSS
tt.render.sprites[1] = E:clone_c("sprite")
tt.render.sprites[1].prefix = "stun"
tt.render.sprites[1].name = "small"
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[1].size_names = {
	"small",
	"big",
	"big"
}

--------------------------------------------------------------------------------
-- SC Reset 3.6: alternate level-4 branches for official KR4 towers
--------------------------------------------------------------------------------

local function sc_exo_sprite(prefix, name, offset, anchor)
	local sprite = CC("sprite")

	sprite.prefix = prefix
	sprite.name = name or "idle"
	sprite.animated = true
	sprite.exo = true
	sprite.offset = offset or v(0, 0)
	if anchor then
		sprite.anchor = anchor
	end
	return sprite
end

local function sc_sprite(prefix, name, offset, anchor)
	local sprite = CC("sprite")

	sprite.prefix = prefix
	sprite.name = name or "idle"
	sprite.animated = true
	sprite.offset = offset or v(0, 0)
	if anchor then
		sprite.anchor = anchor
	end

	return sprite
end

local function sc_terrain_sprite()
	local sprite = CC("sprite")

	sprite.animated = false
	sprite.name = "terrains_%04i"
	sprite.offset = v(0, 10)
	sprite.z = Z_TOWER_BASES
	return sprite
end

local function sc_radius(source_diameter)
	return source_diameter / 2
end

local function sc_controller(name, update)
	local controller = RT(name)

	AC(controller, "pos", "main_script")
	controller.main_script.update = update
	return controller
end

local function sc_power(tower, name, price, max_level, enc_icon)
	local power = CC("power")

	power.price_base = price
	power.price_inc = price
	power.max_level = max_level or 3
	power.enc_icon = enc_icon
	tower.powers[name] = power
	return power
end

-- Bone Flingers branch 2: Underground Warriors --------------------------------

tt = RT("tower_sc_rat_tower", "tower_barrack_1")
AC(tt, "powers")
tt.info.i18n_key = "TOWER_SC_RAT_TOWER"
tt.info.portrait = "top_info_tower_icons_0007"
tt.main_script.insert = kr4_scripts.sc_branch_barrack.insert
tt.main_script.update = kr4_scripts.sc_branch_barrack.update
tt.main_script.remove = kr4_scripts.sc_branch_barrack.remove
tt.sc_controller = "controller_sc_rat_tower"
tt.tower.type = "sc_rat_tower"
tt.tower.kind = TOWER_KIND_BARRACK
tt.tower.level = 4
tt.tower.price = 400
tt.tower.menu_offset = v(0, 18)
tt.barrack.soldier_type = "soldier_sc_harpooner"
tt.barrack.max_soldiers = 2
tt.barrack.rally_range = sc_radius(300)
tt.barrack.respawn_offset = v(0, 4)
tt.sound_events.insert = "UndergroundWarriorsTaunt"
tt.sound_events.change_rally_point = "HarpoonersTaunt"
tt.render.sprites = {
	sc_terrain_sprite(),
	sc_exo_sprite("subway_back", "IdleBase", v(-7, 12)),
	sc_exo_sprite("subway_front", "idle", v(0, 0)),
	sc_exo_sprite("rat_tower_small_rat", "idle", v(-14, 45)),
	sc_exo_sprite("rat_tower_small_rat", "idle", v(4, 34))
}
sc_power(tt, "training", 153, 3, 669)
sc_power(tt, "big_rat", 161, 3, 670)
sc_power(tt, "shield", 178, 3, 671).price_inc = 153
sc_power(tt, "rat_swarm", 255, 3, 672).price_inc = 170

sc_controller("controller_sc_rat_tower", kr4_scripts.sc_rat_controller.update)

tt = RT("soldier_sc_harpooner", "soldier_militia")
AC(tt, "ranged", "powers", "timed_actions", "nav_grid")
tt.info.i18n_key = "SOLDIER_SC_HARPOONER"
tt.info.portrait = "top_info_units_portraits_0014"
tt.main_script.insert = kr4_scripts.sc_harpooner.insert
tt.main_script.update = kr45_scripts.kr4_soldier_barrack.update
tt.sound_events.insert = "HarpoonersTaunt"
tt.health.hp_max = 120
tt.health.dead_lifetime = 5
tt.regen.cooldown = 1
tt.regen.health = 12
tt.motion.max_speed = 75
tt.melee.range = sc_radius(80)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].damage_max = 10
tt.melee.attacks[1].hit_time = 0.233
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bullet_sc_harpooner"
tt.ranged.attacks[1].cooldown = 2.3
tt.ranged.attacks[1].shoot_time = 0.267
tt.ranged.attacks[1].min_range = 35
tt.ranged.attacks[1].max_range = sc_radius(400)
tt.ranged.attacks[1].animation = "shoot"
tt.ranged.attacks[1].bullet_start_offset = {v(4, 7), v(4, 7), v(4, 7)}
tt.ranged.attacks[1].vis_flags = F_RANGED
tt.ranged.attacks[1].vis_bans = F_NIGHTMARE
tt.ranged.range_while_blocking = false
tt.powers.shield = CC("power")
tt.timed_actions.list[1] = CC("mod_attack")
tt.timed_actions.list[1].animation = "skill02Gril"
tt.timed_actions.list[1].cast_time = 0.6
tt.timed_actions.list[1].cooldown = 15
tt.timed_actions.list[1].disabled = true
tt.timed_actions.list[1].level = 0
tt.timed_actions.list[1].mod = "mod_sc_rat_shield"
tt.timed_actions.list[1].power_name = "shield"
tt.timed_actions.list[1].fn_can = function(soldier, store, action)
	local target = soldier.soldier.target_id and store.entities[soldier.soldier.target_id]

	return target and target.health and not target.health.dead and band(target.vis.flags, F_BOSS) == 0
end
tt.render.sprites = {sc_exo_sprite("harpooner_boy", "idle", v(0, 0), v(0.5, 0.16))}
tt.render.sprites[1].angles = {
	walk = {"walk", "walk", "walk"},
	shoot = {"shootUp", "shoot", "shootDown"}
}
tt.health_bar.offset = v(0, 31)
tt.unit.hit_offset = v(0, 9)
tt.unit.mod_offset = v(0, 9)
tt.soldier.melee_slot_offset = v(12, 0)

tt = RT("bullet_sc_harpooner", "arrow")
tt.bullet.damage_min = 46
tt.bullet.damage_max = 56
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = 0.3
tt.bullet.reduce_armor = 0.2
tt.bullet.mod = "mod_sc_harpooner_stun_roll"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "shooter_harpooner_proyectile"

tt = RT("bullet_sc_harpooner_girl", "bullet_sc_harpooner")
tt.bullet.damage_min = 28
tt.bullet.damage_max = 42

tt = RT("mod_sc_harpooner_stun_roll", "modifier")
tt.main_script.insert = kr4_scripts.sc_harpooner_stun_roll.insert
tt = RT("mod_sc_harpooner_stun", "mod_stun")
tt.modifier.duration = 2
tt.modifier.vis_bans = F_BOSS

tt = RT("mod_sc_rat_shield", "modifier")
AC(tt, "render")
tt.main_script.insert = kr4_scripts.sc_rat_shield.insert
tt.main_script.remove = kr4_scripts.sc_rat_shield.remove
tt.main_script.update = scripts.mod_track_target.update
tt.modifier.duration = 3
tt.modifier.vis_bans = F_BOSS
tt.render.sprites[1] = sc_exo_sprite("harpooner_shield", "shield", v(0, 0))

tt = RT("sc_rat_small_bolt", "arrow")
tt.bullet.damage_min = 8
tt.bullet.damage_max = 12
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = 0.25
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "shooter_harpooner_proyectile"

tt = RT("soldier_sc_underground", "soldier_militia")
AC(tt, "nav_path")
tt.info.i18n_key = "SOLDIER_SC_UNDERGROUND"
tt.info.fn = kr4_scripts.sc_path_soldier.get_info
tt.main_script.insert = kr4_scripts.sc_path_soldier.insert
tt.main_script.update = kr4_scripts.sc_path_soldier.update
tt.health.hp_max = 100
tt.health.dead_lifetime = 7
tt.motion.max_speed = 50
tt.regen.health = 0
tt.melee.range = sc_radius(140)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 17
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].hit_time = 0.3
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.attacks[1].vis_bans = bor(F_FLYING, F_CLIFF)
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].chance = 0
tt.melee.attacks[2].cooldown = 1
tt.melee.attacks[2].damage_min = 17
tt.melee.attacks[2].damage_max = 25
tt.melee.attacks[2].hit_time = 0.3
tt.melee.attacks[2].animation = "attack"
tt.melee.attacks[2].vis_flags = F_BLOCK
tt.melee.attacks[2].vis_bans = bor(F_FLYING, F_CLIFF)
tt.render.sprites = {sc_exo_sprite("rat_tower_small_soldier_basic_skill", "idle", v(0, 0), v(0.5, 0.15))}
tt.render.sprites[1].angles = {walk = {"walk", "walk", "walk"}}
tt.health_bar.offset = v(0, 31)
tt.unit.hit_offset = v(0, 15)
tt.unit.mod_offset = v(0, 16)
tt.soldier.melee_slot_offset = v(21, 0)
tt.nav_path.dir = -1

for i, duration in ipairs({1.5, 1.75, 2}) do
	tt = RT("mod_sc_underground_stun_" .. i, "mod_stun")
	tt.modifier.duration = duration
	tt.modifier.vis_bans = F_BOSS
end

tt = RT("soldier_sc_big_rat", "soldier_sc_underground")
tt.health.hp_max = 480
tt.motion.max_speed = 40
tt.melee.attacks[1].damage_min = 51
tt.melee.attacks[1].damage_max = 76
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].hit_time = 0.366
tt.melee.range = sc_radius(120)
tt.melee.attacks[2] = nil
tt.melee.order = {1}
tt.render.sprites[1].prefix = "rat_tower_big_rat"
tt.health_bar.offset = v(0, 44)
tt.unit.hit_offset = v(0, 17)
tt.unit.mod_offset = v(0, 15)
tt.soldier.melee_slot_offset = v(29, 0)

tt = RT("unit_sc_poisonous_rat")
AC(tt, "pos", "motion", "nav_path", "render", "main_script")
tt.main_script.update = kr4_scripts.sc_poisonous_rat.update
tt.motion.max_speed = 90
tt.nav_path.dir = -1
tt.source_id = nil
tt.level = 1
tt.spawn_delay = 0
tt.aura = {
	range = sc_radius(70),
	cooldown = 0.1
}
tt.render.sprites[1] = sc_exo_sprite("rat_tower_warriors", "walk", v(0, 0))
tt.render.sprites[1].angles = {walk = {"walkUp", "walk", "walkDown"}}

tt = RT("mod_sc_rat_swarm_dot", "modifier")
AC(tt, "dps", "render")
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.modifier.duration = 5
tt.dps.damage_every = 1
tt.dps.damage_min = 5
tt.dps.damage_max = 5
tt.dps.damage_inc = 2
tt.dps.damage_type = DAMAGE_TRUE
tt.render.sprites[1] = sc_exo_sprite("rat_tower_modifier", "idle", v(0, 3))

tt = RT("mod_sc_rat_swarm_slow", "mod_slow")
tt.modifier.duration = 5
tt.slow.factor = 0.9
tt.main_script.insert = function(this, store, script)
	this.slow.factor = ({0.9, 0.85, 0.8})[this.modifier.level]
	return scripts.mod_slow.insert(this, store, script)
end

-- Elite Harassers branch 2: Twilight Avengers -------------------------------

tt = RT("tower_sc_twilight_avenger", "tower_barrack_1")
AC(tt, "powers")
tt.info.i18n_key = "TOWER_SC_TWILIGHT_AVENGER"
tt.info.portrait = "sc_tower_icon_twilight_avenger"
tt.main_script.insert = kr4_scripts.sc_branch_barrack.insert
tt.main_script.update = kr4_scripts.sc_branch_barrack.update
tt.main_script.remove = kr4_scripts.sc_branch_barrack.remove
tt.sc_controller = "controller_sc_twilight_avenger"
tt.tower.type = "sc_twilight_avenger"
tt.tower.kind = TOWER_KIND_BARRACK
tt.tower.level = 4
tt.tower.price = 260
tt.barrack.soldier_type = "soldier_sc_twilight_avenger"
tt.barrack.max_soldiers = 2
tt.barrack.rally_range = sc_radius(350)
tt.sound_events.insert = "kr4_elves_barrack_taunt"
tt.sound_events.change_rally_point = "kr4_elves_barrack_taunt"
tt.render.sprites = {sc_terrain_sprite(), CC("sprite")}
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "tower_avenger_0001"
tt.render.sprites[2].offset = v(0, 26)
sc_power(tt, "death_curse", 212, 3, 673)
sc_power(tt, "twilight_blade", 187, 2, 674)
sc_power(tt, "magic_armor", 272, 2, 675)

sc_controller("controller_sc_twilight_avenger", kr4_scripts.sc_avenger_controller.update)

tt = RT("soldier_sc_twilight_avenger", "soldier_militia")
AC(tt, "powers", "nav_grid")
tt.info.i18n_key = "SOLDIER_SC_TWILIGHT_AVENGER"
tt.main_script.update = kr45_scripts.kr4_soldier_barrack.update
tt.health.hp_max = 900
tt.health.armor = 0.9
tt.health.magic_armor = 0
tt.health.dead_lifetime = 18
tt.regen.cooldown = 2
tt.regen.health = 68
tt.motion.max_speed = 66
tt.melee.range = sc_radius(140)
tt.melee.attacks[1].cooldown = 1.5
tt.melee.attacks[1].damage_min = 50
tt.melee.attacks[1].damage_max = 75
tt.melee.attacks[1].hit_time = 0.433
tt.melee.attacks[1].mod = "mod_sc_avenger_bonus"
tt.melee.attacks[2] = CC("melee_attack")
tt.melee.attacks[2].animation = "attack"
tt.melee.attacks[2].cooldown = 10
tt.melee.attacks[2].damage_min = 0
tt.melee.attacks[2].damage_max = 0
tt.melee.attacks[2].damage_inc = 70
tt.melee.attacks[2].damage_type = DAMAGE_TRUE
tt.melee.attacks[2].disabled = true
tt.melee.attacks[2].power_name = "twilight_blade"
tt.melee.attacks[2].hit_time = 0.433
tt.powers.death_curse = CC("power")
tt.powers.twilight_blade = CC("power")
tt.powers.magic_armor = CC("power")
tt.render.sprites = {sc_exo_sprite("avenger2", "idle", v(0, 0), v(0.5, 0.264))}
tt.render.sprites[1].angles = {walk = {"walkUp", "walk", "walkDown"}}
tt.render.sprites[1].scale = v(768 / 1080, 768 / 1080)
tt.health_bar.offset = v(0, 50)
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(0, 20)
tt.soldier.melee_slot_offset = v(23, 0)

tt = RT("mod_sc_avenger_bonus", "modifier")
tt.main_script.insert = kr4_scripts.sc_avenger_bonus.insert

tt = RT("mod_sc_avenger_curse", "modifier")
AC(tt, "render")
tt.main_script.insert = scripts.mod_track_target.insert
tt.main_script.update = kr4_scripts.sc_avenger_curse.update
tt.modifier.duration = 9999
tt.modifier.vis_bans = F_NIGHTMARE
tt.render.sprites[1].prefix = "poisonViolet"
tt.render.sprites[1].name = "run"

tt = RT("aura_sc_avenger_curse_burst", "aura")
AC(tt, "render")
tt.main_script.update = kr4_scripts.sc_avenger_curse_burst.update
tt.render.sprites[1].prefix = "derst"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].loop = false

-- Rotten Forest branch 2: Nuclear Waste Disposal ----------------------------

tt = RT("tower_sc_nuclear_tower", "tower")
AC(tt, "attacks", "powers")
tt.info.i18n_key = "TOWER_SC_NUCLEAR_TOWER"
tt.info.portrait = "top_info_tower_icons_0010"
tt.info.fn = kr4_scripts.sc_nuclear_tower.get_info
tt.main_script.update = kr4_scripts.sc_nuclear_tower.update
tt.tower.type = "sc_nuclear_tower"
tt.tower.kind = TOWER_KIND_MAGE
tt.tower.level = 4
tt.tower.price = 345
tt.tower.menu_offset = v(0, 18)
tt.sound_events.insert = "WasteDisposerTaunt"
tt.attacks.range = sc_radius(390)
tt.attacks.cooldown = 4.3
tt.render.sprites = {
	sc_terrain_sprite(),
	sc_exo_sprite("nuclear_tower", "idle", v(0, -15))
}
sc_power(tt, "efficiency", 204, 3, 676)
sc_power(tt, "super_blob", 204, 3, 677)
sc_power(tt, "toxic_zone", 306, 1, 678)

tt = RT("bullet_sc_nuclear", "bullet")
tt.main_script.update = kr4_scripts.sc_nuclear_bomb.update
tt.bullet.damage_radius = sc_radius(90)
tt.bullet.flight_time = 0.5
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.render.sprites[1] = sc_exo_sprite("nuclear_ball", "idle", v(0, 0))
tt.render.sprites[2] = sc_exo_sprite("nuclear_tower_blob_spawn_trail", "run", v(0, 0))

tt = RT("fx_sc_nuclear_impact")
AC(tt, "pos", "render", "main_script")
tt.main_script.update = kr4_scripts.sc_one_shot_fx.update
tt.duration = 0.8
tt.render.sprites[1] = sc_exo_sprite("nuclear_tower_blob_spawn_explosion", "run", v(0, 0))
tt.render.sprites[1].loop = false

tt = RT("soldier_sc_nuclear_blob", "soldier_militia")
tt.info.i18n_key = "SOLDIER_SC_NUCLEAR_BLOB"
tt.main_script.update = kr4_scripts.sc_nuclear_blob.update
tt.health.hp_max = 90
tt.health.dead_lifetime = 2
tt.regen.health = 0
tt.motion.max_speed = 30
tt.melee.range = sc_radius(200)
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].damage_max = 6
tt.melee.attacks[1].hit_time = 0.63
tt.melee.attacks[1].animation = "melee"
tt.render.sprites = {sc_exo_sprite("nuclear_blob", "idle", v(0, 0), v(0.5, 0.2))}
tt.render.sprites[1].angles = {walk = {"walk", "walk", "walk"}}
tt.health_bar.offset = v(0, 32)
tt.unit.hit_offset = v(0, 15)
tt.unit.mod_offset = v(0, 16)
tt.soldier.melee_slot_offset = v(24, 0)
tt.vis.bans = bor(tt.vis.bans, F_MOD)

tt = RT("soldier_sc_nuclear_blob_big", "soldier_sc_nuclear_blob")
tt.health.hp_max = 120
tt.melee.attacks[1].damage_min = 8
tt.melee.attacks[1].damage_max = 15
tt.render.sprites[1].prefix = "nuclear_blob_skill"
tt.health_bar.offset = v(0, 44)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM

sc_controller("controller_sc_nuclear_decay", kr4_scripts.sc_nuclear_decay.update)

tt = RT("aura_sc_nuclear_death", "aura")
AC(tt, "render")
tt.main_script.update = kr4_scripts.sc_nuclear_burst.update
tt.render.sprites[1] = sc_exo_sprite("nuclear_spawn", "spawn", v(0, 0))
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS

tt = RT("aura_sc_nuclear_residue", "aura")
AC(tt, "render")
tt.main_script.update = kr4_scripts.sc_nuclear_residue.update
tt.render.sprites[1] = sc_exo_sprite("nuclear_decal_skill", "run", v(0, 0))
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_DECALS

tt = RT("mod_sc_nuclear_residue", "modifier")
AC(tt, "render")
tt.main_script.insert = kr4_scripts.sc_nuclear_residue_mod.insert
tt.main_script.update = kr4_scripts.sc_nuclear_residue_mod.update
tt.modifier.duration = 4
tt.render.sprites[1] = sc_exo_sprite("nucleartower_modify", "idle", v(0, 0))

tt = RT("aura_sc_nuclear_zone", "aura")
AC(tt, "render")
tt.main_script.update = kr4_scripts.sc_nuclear_zone.update
tt.render.sprites = {}
for _, offset in ipairs({
	v(0, 86), v(43, 68), v(86, 50), v(86, 0), v(86, -50), v(43, -68),
	v(0, -86), v(-43, -68), v(-86, -50), v(-86, 0), v(-86, 50), v(-43, 68)
}) do
	local sprite = sc_exo_sprite("nuclear_tower_decal", "run", offset)
	sprite.loop = true
	sprite.z = Z_DECALS
	table.insert(tt.render.sprites, sprite)
end

-- Goblin War Zeppelin branch 2: Drone Hive ---------------------------------

tt = RT("tower_sc_drone_hive", "tower_barrack_1")
AC(tt, "powers")
tt.info.i18n_key = "TOWER_SC_DRONE_HIVE"
tt.info.portrait = "top_info_tower_icons_0012"
tt.main_script.insert = kr4_scripts.sc_branch_barrack.insert
tt.main_script.update = kr4_scripts.sc_branch_barrack.update
tt.main_script.remove = kr4_scripts.sc_drone_tower.remove
tt.sc_controller = "controller_sc_drone_hive"
tt.tower.type = "sc_drone_hive"
tt.tower.kind = TOWER_KIND_ARCHER
tt.tower.level = 4
tt.tower.price = 360
tt.barrack.soldier_type = "soldier_sc_drone"
tt.barrack.max_soldiers = 3
tt.barrack.rally_range = sc_radius(660)
tt.sound_events.insert = "DroneHiveTaunt"
tt.render.sprites = {
	sc_terrain_sprite(),
	sc_exo_sprite("dronehivetower", "idle", v(0, 0))
}
sc_power(tt, "drone_upgrade", 187, 3, 679)
sc_power(tt, "support", 374, 3, 680).price_inc = 374
sc_power(tt, "big_drone", 153, 2, 681).price_inc = 153

sc_controller("controller_sc_drone_hive", kr4_scripts.sc_drone_controller.update)

tt = RT("soldier_sc_drone", "soldier_militia")
AC(tt, "ranged", "powers", "force_motion")
tt.info.i18n_key = "SOLDIER_SC_DRONE"
tt.main_script.update = kr4_scripts.sc_drone.update
tt.health.hp_max = 1
tt.health.ignore_damage = true
tt.regen.health = 0
tt.motion.max_speed = 75
tt.melee.range = 1
tt.melee.attacks[1].damage_min = 0
tt.melee.attacks[1].damage_max = 0
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bullet_sc_drone"
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].shoot_time = 0.033
tt.ranged.attacks[1].shoot_times = {0.033, 0.166, 0.299}
tt.ranged.attacks[1].loops = 1
tt.ranged.attacks[1].animations = {nil, "attack", nil}
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].max_range = sc_radius(265)
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].sound = "DroneHiveShot"
tt.ranged.attacks[1].bullet_start_offset = {v(0, 10), v(0, 10), v(0, 10)}
tt.ranged.attacks[1].vis_flags = F_RANGED
tt.ranged.attacks[1].vis_bans = F_NIGHTMARE
tt.ranged.range_while_blocking = false
tt.powers.drone_upgrade = CC("power")
tt.motion.max_speed = 90
tt.force_motion.max_a = 600
tt.force_motion.max_v = 90
tt.force_motion.ramp_radius = 25
tt.force_motion.ramp_min_factor = 0.2
tt.force_motion.fr = 0.08
tt.force_motion.a_step = 16
tt.render.sprites = {sc_exo_sprite("dronehivedrone", "idle", v(0, 0), v(0.5, 0.2)), CC("sprite")}
tt.render.sprites[1].angles = {
	walk = {"walk", "walk", "walk"},
	attack = {"attackup", "attack", "attack"}
}
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "asst_dronehive_drone_shadow"
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].z = Z_DECALS
tt.health_bar.hidden = true
tt.ui.can_click = false
tt.unit.hit_offset = v(0, 28)
tt.unit.mod_offset = v(0, 28)
tt.vis.flags = bor(band(tt.vis.flags, bnot(F_BLOCK)), F_FLYING)
tt.vis.bans = bor(tt.vis.bans, F_BLOCK)

tt = RT("bullet_sc_drone", "arrow")
tt.bullet.damage_min = 7
tt.bullet.damage_max = 10
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.flight_time = 0.25
tt.bullet.mod = "mod_sc_drone_slow"
tt.bullet.hit_fx = "fx_sc_drone_hit"
tt.render.sprites[1] = sc_exo_sprite("droneshootbody", "run", v(0, 0))
tt.render.sprites[1].hidden = true

tt = RT("fx_sc_drone_hit")
AC(tt, "pos", "render", "main_script")
tt.main_script.update = kr4_scripts.sc_one_shot_fx.update
tt.duration = 0.5
tt.render.sprites = {
	sc_exo_sprite("droneshootbody", "run", v(0, 0)),
	sc_exo_sprite("droneshootfloor", "run", v(0, 0))
}
tt.render.sprites[1].loop = false
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2].loop = false
tt.render.sprites[2].z = Z_DECALS

tt = RT("bullet_sc_drone_upgraded", "bullet_sc_drone")
tt.bullet.damage_min = 8
tt.bullet.damage_max = 11

tt = RT("mod_sc_drone_slow", "mod_slow")
tt.modifier.duration = 0.5
tt.slow.factor = 0.8

tt = RT("soldier_sc_big_drone", "soldier_militia")
AC(tt, "ranged", "nav_grid")
tt.info.i18n_key = "SOLDIER_SC_BIG_DRONE"
tt.main_script.update = kr4_scripts.sc_big_drone.update
tt.health.hp_max = 245
tt.health.armor = 0.2
tt.health.dead_lifetime = 12
tt.regen.health = 0
tt.motion.max_speed = 50
tt.melee.range = sc_radius(120)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 47
tt.melee.attacks[1].damage_max = 67
tt.melee.attacks[1].hit_time = 0.3
tt.melee.attacks[1].damage_type = DAMAGE_EXPLOSION
tt.melee.attacks[1].hit_times = {0.3, 0.5, 0.7, 0.9}
tt.melee.attacks[1].loops = 1
tt.melee.attacks[1].animations = {nil, "attack", nil}
tt.ranged.attacks[1] = CC("bullet_attack")
tt.ranged.attacks[1].bullet = "bullet_sc_big_drone"
tt.ranged.attacks[1].cooldown = 1
tt.ranged.attacks[1].shoot_times = {0.3, 0.433, 0.566}
tt.ranged.attacks[1].loops = 1
tt.ranged.attacks[1].animations = {nil, "attack", nil}
tt.ranged.attacks[1].min_range = 0
tt.ranged.attacks[1].max_range = sc_radius(265)
tt.ranged.attacks[1].animation = "attack"
tt.ranged.attacks[1].sound = "DroneHiveShot"
tt.ranged.attacks[1].bullet_start_offset = {v(0, 10), v(0, 10), v(0, 10)}
tt.ranged.attacks[1].vis_flags = F_RANGED
tt.ranged.attacks[1].vis_bans = F_NIGHTMARE
tt.ranged.range_while_blocking = false
tt.render.sprites = {sc_exo_sprite("dronehivedrone_skillb", "walk", v(0, 0), v(0.5, 0.18))}
tt.render.sprites[1].angles = {walk = {"walkUp", "walk", "walkDown"}}
tt.idle_flip.last_animation = "walk"
tt.health_bar.offset = v(0, 33)
tt.unit.hit_offset = v(0, 15)
tt.unit.mod_offset = v(0, 16)
tt.soldier.melee_slot_offset = v(21, 0)

tt = RT("bullet_sc_big_drone", "bullet_sc_drone")
tt.bullet.damage_min = 16
tt.bullet.damage_max = 22
tt.bullet.mod = nil

tt = RT("bullet_sc_big_drone_spawn", "bullet")
tt.main_script.update = kr4_scripts.sc_big_drone_spawn.update
tt.render.sprites = {CC("sprite"), sc_exo_sprite("dronetrailrabbit", "run", v(0, 0))}
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "Dronehive_projectile"
tt.render.sprites[1].anchor = v(0.5, 0)
tt.render.sprites[2].loop = true

tt = RT("mod_sc_drone_support", "modifier")
AC(tt, "render")
tt.main_script.insert = scripts.mod_tower_factors.insert
tt.main_script.update = scripts.mod_tower_factors.update
tt.main_script.remove = scripts.mod_tower_factors.remove
tt.modifier.duration = 9999
tt.render.sprites = {
	sc_exo_sprite("commandcenter_activate", "buff", v(0, 10)),
	sc_exo_sprite("commandcenter_parabolic", "Idle", v(0, 10)),
	sc_exo_sprite("commandcenter_power_tower_decal", "Idle", v(0, 10))
}
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[3].z = Z_DECALS

tt = RT("mod_sc_drone_soldier_damage", "modifier")
tt.main_script.insert = scripts.mod_damage_factors.insert
tt.main_script.update = scripts.mod_track_target.update
tt.main_script.remove = scripts.mod_damage_factors.remove
tt.modifier.duration = 9999

tt = RT("bullet_sc_drone_orbital", "bullet")
tt.main_script.update = kr4_scripts.sc_drone_orbital_projectile.update
tt.render.sprites[1] = sc_exo_sprite("dronespecialbomb", "travel", v(0, 0))

tt = RT("aura_sc_drone_orbital", "aura")
AC(tt, "render")
tt.main_script.update = kr4_scripts.sc_drone_orbital.update
tt.render.sprites[1] = sc_exo_sprite("dronespecialexplosion", "run", v(0, 0))
tt.render.sprites[1].loop = false

-- Ignis Altar branch 2: Thermalblast Spa ------------------------------------

tt = RT("tower_sc_thermalblast_spa", "tower")
AC(tt, "attacks", "powers")
tt.info.i18n_key = "TOWER_SC_THERMALBLAST_SPA"
tt.info.portrait = "top_info_tower_icons_0018"
tt.info.fn = kr4_scripts.sc_thermal_tower.get_info
tt.main_script.update = kr4_scripts.sc_thermal_tower.update
tt.tower.type = "sc_thermalblast_spa"
tt.tower.kind = TOWER_KIND_ARTILLERY
tt.tower.level = 4
tt.tower.price = 325
tt.sound_events.insert = "ThermalblastSpaTaunt"
tt.attacks.range = sc_radius(360)
tt.attacks.cooldown = 4
tt.render.sprites = {
	sc_terrain_sprite(),
	sc_exo_sprite("sumo_tower", "idle", v(0, 0))
}
sc_power(tt, "geysers", 185, 3, 682)
sc_power(tt, "sumo", 150, 3, 683)
sc_power(tt, "mist", 150, 3, 684)

tt = RT("aura_sc_thermal_geyser", "aura")
AC(tt, "render")
tt.main_script.update = kr4_scripts.sc_thermal_geyser.update
tt.render.sprites[1] = sc_exo_sprite("sumo_towerGeyser", "run", v(0, 0))
tt.render.sprites[1].loop = false
tt.render.sprites[2] = sc_exo_sprite("sumo_towerDecalBasicAttack", "run", v(0, 0))
tt.render.sprites[2].loop = false

tt = RT("mod_sc_geyser_dot", "modifier")
AC(tt, "render")
tt.main_script.insert = kr4_scripts.sc_geyser_dot.insert
tt.main_script.update = kr4_scripts.sc_geyser_dot.update
tt.modifier.duration = 1.5
tt.render.sprites[1] = sc_exo_sprite("sumo_towerSkillAModifier", "run", v(0, 0))

tt = RT("soldier_sc_sumo", "soldier_militia")
AC(tt, "reinforcement")
tt.info.i18n_key = "SOLDIER_SC_SUMO"
tt.info.fn = scripts.soldier_reinforcement.get_info
tt.main_script.insert = scripts.soldier_reinforcement.insert
tt.main_script.update = kr4_scripts.sc_sumo.update
tt.health.hp_max = 160
tt.health.dead_lifetime = 2
tt.regen.health = 0
tt.motion.max_speed = 65
tt.melee.range = sc_radius(200)
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 69
tt.melee.attacks[1].damage_max = 102
tt.melee.attacks[1].hit_time = 0.233
tt.reinforcement.duration = 9
tt.reinforcement.fade = false
tt.reinforcement.fade_in = false
tt.reinforcement.fade_out = false
tt.render.sprites = {sc_exo_sprite("sumo_towerSkillBUnit", "idle", v(0, 0), v(0.5, 0.18))}
tt.render.sprites[1].angles = {walk = {"walk", "walk", "walk"}}
tt.health_bar.offset = v(0, 38)
tt.unit.hit_offset = v(0, 15)
tt.unit.mod_offset = v(0, 16)
tt.soldier.melee_slot_offset = v(22, 0)

tt = RT("aura_sc_sumo_landing", "aura")
AC(tt, "render")
tt.main_script.update = kr4_scripts.sc_sumo_landing.update
tt.render.sprites[1] = sc_exo_sprite("sumo_towerSkillBDecal", "out", v(0, 0))
tt.render.sprites[1].loop = false

tt = RT("mod_sc_sumo_stun", "mod_stun")
tt.modifier.duration = 1
tt.modifier.vis_bans = F_BOSS

tt = RT("aura_sc_thermal_mist", "aura")
AC(tt, "render")
tt.main_script.update = kr4_scripts.sc_thermal_mist.update
tt.render.sprites[1] = sc_exo_sprite("sumo_towerSmoke", "run", v(0, 0))
tt.render.sprites[1].loop = true

tt = RT("mod_sc_thermal_slow", "mod_slow")
tt.modifier.duration = 5
tt.slow.factor = 0.7

tt = RT("mod_sc_thermal_silence", "modifier")
AC(tt, "render")
tt.main_script.insert = kr4_scripts.sc_silence.insert
tt.main_script.update = scripts.mod_track_target.update
tt.main_script.remove = kr4_scripts.sc_silence.remove
tt.modifier.duration = 5
tt.modifier.vis_bans = F_BOSS
tt.render.sprites[1] = sc_exo_sprite("sumo_towerSmokeModifier", "run", v(0, 0))

-- Shaolin level 3 branch: Fuhai Temple -------------------------------------

tt = RT("tower_sc_fuhai_temple", "tower_barrack_1")
AC(tt, "attacks", "powers")
tt.info.i18n_key = "TOWER_SC_FUHAI_TEMPLE"
tt.info.portrait = "gui_bottom_info_image_towers_8888"
tt.info.fn = kr4_scripts.sc_fuhai_temple.get_info
tt.main_script.insert = kr4_scripts.sc_fuhai_temple.insert
tt.main_script.update = kr4_scripts.sc_fuhai_temple.update
tt.main_script.remove = kr4_scripts.sc_fuhai_temple.remove
tt.tower.type = "sc_fuhai_temple"
tt.tower.kind = TOWER_KIND_BARRACK
tt.tower.level = 4
tt.tower.price = 290
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = v(0, 16)
tt.attacks.range = sc_radius(367.5)
tt.attacks.cooldown = 1.37
tt.attacks.enemy_cooldown = 1.37
tt.attacks.damage_min = 13
tt.attacks.damage_max = 21
tt.attacks.max_targets = 2
tt.barrack.soldier_type = "soldier_sc_fuhai_arhat"
tt.barrack.max_soldiers = 0
tt.barrack.rally_range = sc_radius(300)
tt.barrack.respawn_offset = v(0, -10)
tt.sound_events.insert = "FuhaiTempleTaunt"
tt.sound_events.change_rally_point = "ShaolinTaunt"
tt.render.sprites = {
	sc_terrain_sprite(),
	sc_sprite("fuhai_temple_lvl4", "idle", v(0, -6), v(0.5, 0.148)),
	sc_sprite("fuhai_monk_lvl4_deco", "idle", v(-25, 32)),
	sc_sprite("fuhai_monk_lvl4_deco", "idle", v(25, 32)),
	sc_sprite("fuhai_monk_lvl4_deco", "idle", v(-36, 20)),
	sc_sprite("fuhai_monk_lvl4_deco", "idle", v(36, 20)),
	sc_sprite("fuhai_monk_lvl4_deco", "idle", v(0, 45))
}
tt.render.sprites[5].hidden = true
tt.render.sprites[6].hidden = true
tt.render.sprites[7].hidden = true
sc_power(tt, "monks", 300, 3, 685)
sc_power(tt, "aura", 350, 2, 686).price_inc = 200
sc_power(tt, "arhat", 220, 3, 687).price_inc = 240

tt = RT("decal_sc_fuhai_monk", "decal_shaolin_lvl4")
tt.main_script.update = kr4_scripts.sc_fuhai_monk.update
tt.render.sprites[1] = sc_sprite("fuhai_monk_lvl4", "idle", v(0, 0), v(0.5, 0.22))
tt.render.sprites[1].z = Z_BULLETS
tt.soldier.melee_slot_offset = v(10, 0)
tt.attack_time = 0.166

tt = RT("soldier_sc_fuhai_arhat", "soldier_militia")
tt.info.i18n_key = "SOLDIER_SC_FUHAI_ARHAT"
tt.info.fn = scripts.soldier_barrack.get_info
tt.main_script.update = kr4_scripts.sc_fuhai_arhat.update
tt.health.hp_max = 400
tt.health.armor = 0.6
tt.health.dead_lifetime = 18
tt.regen.health = 40
tt.regen.cooldown = 2
tt.motion.max_speed = 50
tt.melee.range = sc_radius(120)
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_time = 0.533
tt.melee.attacks[1].animation = "attack"
tt.render.sprites = {sc_sprite("fuhai_dragon_warrior", "idle", v(0, 0), v(0.5, 0.147))}
tt.render.sprites[1].angles = {walk = {"walk", "walk", "walk"}}
tt.health_bar.offset = v(0, 46)
tt.unit.hit_offset = v(0, 15)
tt.unit.mod_offset = v(0, 16)
tt.soldier.melee_slot_offset = v(25, 0)

tt = RT("fx_sc_fuhai_hit", "fx")
tt.render.sprites[1] = sc_sprite("fuhai_monk_lvl4_hit_effect", "run", v(0, 0))
tt.render.sprites[1].loop = false

for i, factor in ipairs({0.9, 0.8}) do
	t = RT("mod_sc_fuhai_aura_slow_" .. i, "mod_slow")
	t.modifier.duration = 0.3
	t.slow.factor = factor

	t = RT("mod_sc_fuhai_aura_damage_" .. i, "modifier")
	t.main_script.insert = scripts.mod_damage_factors.insert
	t.main_script.update = scripts.mod_track_target.update
	t.main_script.remove = scripts.mod_damage_factors.remove
	t.modifier.duration = 0.3
	t.inflicted_damage_factor = ({0.85, 0.7})[i]
end

tt = RT("mod_sc_fuhai_stun", "mod_stun")
tt.modifier.duration = fts(8)
tt.modifier.vis_bans = bor(F_BOSS, F_MINIBOSS)

tt = RT("mod_sc_fuhai_silence", "modifier")
tt.main_script.insert = kr4_scripts.sc_fuhai_silence.insert
tt.main_script.update = scripts.mod_track_target.update
tt.main_script.remove = kr4_scripts.sc_silence.remove
tt.modifier.duration = 2
tt.modifier.vis_bans = bor(F_BOSS, F_MINIBOSS)

-- Infernal Mage level 1 branch: Winter Witch -------------------------------

local function sc_winter_tower(name, level, price, range, damage_min, damage_max)
	local tower = RT(name, "tower")

	AC(tower, "attacks")
	tower.info.i18n_key = "TOWER_SC_WINTER_LEVEL" .. level
	tower.info.portrait = "gui_bottom_info_image_enemies_0020"
	tower.info.fn = kr4_scripts.sc_winter_tower.get_info
	tower.main_script.update = kr4_scripts.sc_winter_tower.update
	tower.tower.type = "sc_winter"
	tower.tower.kind = TOWER_KIND_MAGE
	tower.tower.team = TEAM_DARK_ARMY
	tower.tower.level = level
	tower.tower.price = price
	tower.tower.size = TOWER_SIZE_LARGE
	tower.tower.menu_offset = v(0, 12)
	tower.winter_index = level - 1
	tower.attacks.range = range
	tower.attacks.cooldown = 1.8
	tower.attacks.list[1] = CC("bullet_attack")
	tower.attacks.list[1].cooldown = 1.8
	tower.attacks.list[1].shoot_time = 0.4
	tower.attacks.list[1].damage_min = damage_min
	tower.attacks.list[1].damage_max = damage_max
	tower.attacks.list[1].vis_flags = bor(F_RANGED, F_AREA)
	tower.attacks.list[1].vis_bans = F_NIGHTMARE
	tower.attacks.list[1].bullet = "bullet_sc_winter"
	tower.attacks.list[1].area_bullet = "bullet_sc_winter_area"
	tower.attacks.list[1].shoot_offset = v(8, 34)
	tower.sound_events.insert = "WinterMageTaunt"
	return tower
end

local function sc_winter_terrain()
	local sprite = CC("sprite")

	sprite.animated = false
	sprite.name = "terrain_winter"
	sprite.offset = v(0, 10)
	sprite.anchor = v(0.5, 0.205)
	sprite.z = Z_TOWER_BASES
	return sprite
end

tt = sc_winter_tower("winter_level2", 2, 180, sc_radius(315), 12, 20)
tt.shooter_offset = v(0, 25)
tt.render.sprites = {
	sc_winter_terrain(),
	sc_sprite("winter_tower", "lvl2_idle", v(0, 4), v(0.5, 0.157)),
	sc_sprite("ice_witch", "idle", tt.shooter_offset, v(0.5, 0.18))
}
tt.render.sprites[3].group = "winter_shooter"

tt = sc_winter_tower("winter_level3", 3, 250, sc_radius(350), 22, 38)
tt.shooter_offset = v(0, 35)
tt.render.sprites = {
	sc_winter_terrain(),
	sc_sprite("winter_tower", "lvl3_idle", v(0, 4), v(0.5, 0.157)),
	sc_sprite("ice_witch", "idle", tt.shooter_offset, v(0.5, 0.18))
}
tt.render.sprites[3].group = "winter_shooter"

tt = sc_winter_tower("winter_level4", 4, 300, sc_radius(385), 41, 68)
AC(tt, "powers")
tt.shooter_offset = v(0, 45)
tt.render.sprites = {
	sc_winter_terrain(),
	sc_sprite("winter_tower_lvl4_layer1", "idle", v(0, 4), v(0.5, 0.157)),
	sc_sprite("winter_tower_lvl4_layer2", "idle", v(0, 4), v(0.5, 0.157)),
	sc_sprite("winter_tower_lvl4_layer3", "idle", v(0, 4), v(0.5, 0.157)),
	sc_sprite("ice_witch", "idle", tt.shooter_offset, v(0.5, 0.18))
}
for i = 2, 4 do
	tt.render.sprites[i].group = "winter_tower"
end
tt.render.sprites[5].group = "winter_shooter"
sc_power(tt, "ground", 300, 3, 688).price_inc = 210
sc_power(tt, "shield", 250, 1, 689)
sc_power(tt, "tornado", 350, 3, 690).price_inc = 250

tt = RT("bullet_sc_winter", "bullet")
tt.main_script.update = kr4_scripts.sc_winter_bullet.update
tt.render.sprites[1] = sc_sprite("ice_witch_bolt", "travel", v(0, 0), v(0.5, 0.5))
tt.render.sprites[1].z = Z_BULLETS
tt.speed = 420
tt.retarget_range = sc_radius(63)

tt = RT("bullet_sc_winter_area", "bullet_sc_winter")
tt.render.sprites[1] = sc_sprite("svell_druid_proyectile", "travel", v(0, 0), v(0.5, 0.5))
tt.render.sprites[1].z = Z_BULLETS
tt.retarget_range = 0

tt = RT("fx_sc_winter_area_hit", "fx_eiskalt_frosty_spawn")
tt.render.sprites[1].anchor = v(0.5, 0.136)
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[1].sort_y_offset = -3

tt = RT("aura_sc_winter_ground", "aura")
AC(tt, "render")
tt.main_script.update = kr4_scripts.sc_winter_ground.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "winter_decal"
tt.render.sprites[1].z = Z_DECALS

for i, factor in ipairs({0.76, 0.68, 0.6}) do
	t = RT("mod_sc_winter_slow_" .. i, "mod_slow")
	t.modifier.duration = 3
	t.slow.factor = factor

	t = RT("mod_sc_winter_slow_boss_" .. i, "mod_slow")
	t.modifier.duration = 3
	t.slow.factor = 1 - (1 - factor) * 0.5
end

tt = RT("mod_sc_winter_ground_slow", "mod_slow")
tt.modifier.duration = 0.35
tt.slow.factor = 0.4

tt = RT("mod_sc_winter_freeze", "mod_eiskalt_freeze")
tt.modifier.duration = 2

tt = RT("mod_sc_winter_shield", "modifier")
AC(tt, "render")
tt.main_script.insert = kr4_scripts.sc_winter_shield.insert
tt.main_script.update = kr4_scripts.sc_winter_shield.update
tt.main_script.remove = kr4_scripts.sc_winter_shield.remove
tt.modifier.duration = 7
for i = 1, 6 do
	tt.render.sprites[i] = sc_sprite("winter_lord_magic_shield_layer" .. i, "in", v(0, 0), v(0.5, 0.5))
	tt.render.sprites[i].group = "winter_shield"
end

tt = RT("aura_sc_winter_tornado", "aura")
AC(tt, "render", "nav_path", "motion")
tt.main_script.update = kr4_scripts.sc_winter_tornado.update
tt.motion.max_speed = 46.08
tt.render.sprites[1] = sc_sprite("winter_tornado", "start", v(0, 0), v(0.5, 0.14))
tt.render.sprites[1].loop = false
tt.pickup_range = sc_radius(70)
tt.nodes_limit = 15
tt.max_times_applied = 3
tt.enemies_max = 4
tt.enemies_inc = 1
tt.picked_enemies = {}
tt.aura.vis_flags = bor(F_RANGED, F_TWISTER)
tt.aura.vis_bans = bor(F_CLIFF, F_BOSS, F_NIGHTMARE)

tt = RT("mod_sc_winter_tornado_hold", "mod_stun")
tt.modifier.duration = 0.3
tt.modifier.vis_bans = bor(F_BOSS, F_MINIBOSS)

-- BEGIN DOVE43 BUILTIN TOWERS
do -- sniper_tower
local scripts = kr4_scripts
local cfg = scripts.dove43_config["sniper_tower"]
local BODY_SCALE = 1.265625

	local reg = E.register_t
	local scale_k = 1.265625 / 1.2
	local tt
	tt = reg(E, "tower_sniper", "tower_archer_1")
	E:add_comps(tt, "powers")
	tt.tower.menu_offset = v(2, 20)
	tt.tower.price = 290
	tt.tower.type = "sniper_tower"
	tt.info.portrait = "d43_sniper_tower_sniper_portrait"
	tt.tower_cfg = cfg
	tt.powers.practice = CC("power")
	tt.powers.practice.price_base = 210
	tt.powers.practice.price_inc = 185
	tt.powers.practice.max_level = 3
	tt.powers.kill = CC("power")
	tt.powers.kill.price_base = 320
	tt.powers.kill.price_inc = 300
	tt.powers.kill.max_level = 1
	tt.powers.weak = CC("power")
	tt.powers.weak.price_base = 225
	tt.powers.weak.price_inc = 180
	tt.powers.weak.max_level = 3
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].prefix = "d43_sniper_base"
	tt.render.sprites[2].name = "idle"
	tt.render.sprites[2].exo = true
	tt.render.sprites[2].offset = v(2, 1)
	tt.render.sprites[2].scale = v(1.265625, 1.265625)
	tt.render.sprites[4] = CC("sprite")
	tt.render.sprites[4].prefix = "d43_sniper_base_skill_b"
	tt.render.sprites[4].name = "idle"
	tt.render.sprites[4].exo = true
	tt.render.sprites[4].offset = v(2, 1)
	tt.render.sprites[4].scale = v(1.265625, 1.265625)
	tt.render.sprites[4].hidden = true
	tt.render.sprites[5] = CC("sprite")
	tt.render.sprites[5].prefix = "d43_sniper_base_skill_a"
	tt.render.sprites[5].name = "idle"
	tt.render.sprites[5].exo = true
	tt.render.sprites[5].offset = v(2, 1)
	tt.render.sprites[5].scale = v(1.265625, 1.265625)
	tt.render.sprites[5].hidden = true
	tt.render.sprites[3] = CC("sprite")
	tt.render.sprites[3].prefix = "d43_sniper"
	tt.render.sprites[3].name = "idle"
	tt.render.sprites[3].exo = true
	tt.render.sprites[3].z = Z_OBJECTS_COVERS
	tt.render.sprites[3].offset = v(0, 45 * scale_k)
	tt.render.sprites[3].scale = v(1.1 * scale_k, 1.1 * scale_k)
	local aa = tt.attacks.list[1]
	aa.bullet = "arrow_sniper_shot"
	aa.animation = "shoot"
	aa.cooldown = cfg.attack_cooldown
	aa.shoot_time = 0.166
	tt.attacks.range = cfg.attack_range
	tt.attacks.blind_range = 135
	aa.vis_flags = bor(F_RANGED)
	aa.vis_bans = 0
	aa.bullet_start_offset = {v(4 * scale_k, 12 * scale_k), v(4 * scale_k, 5 * scale_k), v(4 * scale_k, 5 * scale_k)}
	tt.sound_events.insert = "d43_sniper_taunt_1"
	tt.info.fn = scripts.tower_sniper.get_info
	tt.main_script.update = scripts.tower_sniper.update
	tt = reg(E, "fx_sniper_hit", "fx")
	tt.render.sprites[1].prefix = "d43_sniper_tower_sniper_special_hit"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].draw_order = 2
	tt = reg(E, "fx_sniper_hit_skull", "fx")
	tt.render.sprites[1].prefix = "d43_sniper_tower_sniper_special_hit_skull"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].draw_order = 2
	tt = reg(E, "fx_sniper_mira_special", "fx")
	E:add_comps(tt, "main_script")
	tt.timed = nil
	tt.render.sprites[1].prefix = "d43_sniper_tower_sniper_mira_special"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].loop = false
	tt.render.sprites[1].z = Z_EFFECTS
	tt.main_script.update = scripts.fx_sniper_mira_special.update
	tt = reg(E, "fx_sniper_mira", "fx")
	E:add_comps(tt, "main_script")
	tt.timed = nil
	tt.render.sprites[1].prefix = "d43_sniper_mira"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_EFFECTS
	tt.main_script.update = scripts.fx_sniper_mira.update
	tt = reg(E, "fx_sniper_mira_decal", "fx")
	E:add_comps(tt, "main_script")
	tt.timed = nil
	tt.render.sprites[1].prefix = "d43_sniper_mira_decal"
	tt.render.sprites[1].name = "decal"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS
	tt.main_script.update = scripts.fx_sniper_mira.update
	tt = reg(E, "fx_sniper_skill_mira", "fx")
	E:add_comps(tt, "main_script")
	tt.timed = nil
	tt.render.sprites[1].prefix = "d43_sniper_skill_mira"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_EFFECTS
	tt.main_script.update = scripts.fx_sniper_mira.update
	tt = reg(E, "sniper_spotter", "fx")
	E:add_comps(tt, "main_script")
	tt.timed = nil
	tt.render.sprites[1].prefix = "d43_sniper_skill_spotter"
	tt.render.sprites[1].name = "idle"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_OBJECTS
	tt.main_script.update = scripts.sniper_spotter.update
	tt = reg(E, "fx_sniper_muzzle", "fx")
	tt.render.sprites[1].prefix = "d43_sniper_skill_smoketrail"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_EFFECTS
	tt = reg(E, "arrow_sniper_shot", "shotgun_musketeer")
	tt.main_script.insert = scripts.shotgun_dove43.insert
	tt.main_script.update = scripts.shotgun_dove43.update
	tt.bullet.damage_min = cfg.attack_damage_min
	tt.bullet.damage_max = cfg.attack_damage_max
	tt.bullet.damage_type = bor(DAMAGE_PHYSICAL, DAMAGE_NO_DODGE)
	tt.bullet.reduce_armor = 0.25
	tt.bullet.hit_blood_fx = "fx_blood_splat"
	tt.bullet.start_fx = "fx_sniper_muzzle"
	tt.bullet.min_speed = 40 * FPS
	tt.bullet.max_speed = 40 * FPS
	tt.sound_events.insert = "d43_sniper_shot"
	tt = reg(E, "arrow_sniper_shot_weak", "arrow_sniper_shot")
	tt = reg(E, "arrow_sniper_kill", "arrow_sniper_shot")
	tt.bullet.hit_fx = "fx_sniper_hit"
	tt.bullet.hit_blood_fx = "fx_sniper_hit_skull"
	tt.bullet.start_fx = nil
	tt.render.sprites[1].hidden = true
	tt = reg(E, "fx_sniper_ray", "fx")
	tt.render.sprites[1].prefix = "d43_sniper_tower_sniper_special_proyectile"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].anchor = v(0, 0.5)
	tt.render.sprites[1].z = Z_EFFECTS
	tt = reg(E, "arrow_sniper_ray", "shotgun_musketeer_sniper")
	tt.main_script.insert = scripts.shotgun_dove43.insert
	tt.main_script.update = scripts.shotgun_dove43.update
	tt.bullet.damage_type = bor(DAMAGE_PHYSICAL, DAMAGE_NO_DODGE)
	tt.bullet.reduce_armor = 0.25
	tt.bullet.particles_name = nil
	tt.bullet.start_fx = nil
	tt.bullet.hide_radius = nil
	tt.render.sprites[1].hidden = true
	tt.sound_events.insert = "d43_sniper_shot"

	tt = reg(E, "fx_sniper_ray_skill", "fx")
	E:add_comps(tt, "main_script")
	tt.timed = nil
	tt.render.sprites[1].prefix = "d43_sniper_skill_bullet"
	tt.render.sprites[1].name = "idle"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].loop = true
	tt.render.sprites[1].z = Z_EFFECTS
	tt.main_script.update = scripts.fx_sniper_ray_skill.update
	tt = reg(E, "mod_sniper_poison_dot", "mod_poison")
	tt.modifier.allows_duplicates = true
	tt.main_script.insert = scripts.mod_dps_dove43.insert
	tt.modifier.duration = cfg.weak_duration[1]
	tt.modifier.max_duplicates = cfg.weak_max_stacks
	tt.dps.damage_min = cfg.weak_poison_damage[1] / cfg.weak_duration[1]
	tt.dps.damage_max = tt.dps.damage_min
	tt.dps.damage_inc = (cfg.weak_poison_damage[3] - cfg.weak_poison_damage[1]) / (cfg.weak_duration[1] * 2)
	tt.dps.damage_every = 1
	tt.dps.kill = true
	tt.dps.damage_type = bor(DAMAGE_POISON, DAMAGE_NO_SHIELD_HIT)
	tt = reg(E, "mod_sniper_poison_slow", "mod_slow")
	tt.main_script.insert = scripts.mod_slow_dove43.insert
	tt.modifier.duration = cfg.weak_duration[1]
	tt.modifier.resets_same = true
	tt.modifier.replaces_lower = true
	tt.slow.factor = cfg.weak_slow[1]
	tt.slow.factor_inc = (cfg.weak_slow[3] - cfg.weak_slow[1]) / 2
end

do
local tower = E:get_template("tower_sniper")
tower.tower.level = 4
tower.tower.kind = TOWER_KIND_ARCHER
tower.tower.cooldown_factor = 1
tower.info.i18n_key = "TOWER_SNIPER"
tower.info.enc_icon = 672
tower.render.sprites[1] = sc_terrain_sprite()
tower.dove43_dependencies = {"tower_sniper","fx_sniper_hit","fx_sniper_hit_skull","fx_sniper_mira_special","fx_sniper_mira","fx_sniper_mira_decal","fx_sniper_skill_mira","sniper_spotter","fx_sniper_muzzle","arrow_sniper_shot","arrow_sniper_shot_weak","arrow_sniper_kill","fx_sniper_ray","arrow_sniper_ray","fx_sniper_ray_skill","mod_sniper_poison_dot","mod_sniper_poison_slow"}
end

do -- plague_hospital
local scripts = kr4_scripts
local cfg = scripts.dove43_config["plague_hospital"]
local BODY_SCALE = 1.265625

	local reg = E.register_t
	local tt
	tt = reg(E, "tower_plague_hospital", "tower")
	E:add_comps(tt, "attacks", "powers", "auras", "barrack")
	tt.tower.type = "plague_hospital"
	tt.tower.price = 315
	tt.tower.menu_offset = v(0, 24)
	tt.tower.default_rally_pos = v(52, -15)
	tt.tower_cfg = cfg
	tt.info.fn = scripts.tower_plague_hospital.get_info
	tt.info.portrait = "d43_plague_hospital_plague_portrait"
	tt.main_script.insert = scripts.tower_plague_hospital.insert
	tt.main_script.update = scripts.tower_plague_hospital.update
	tt.main_script.remove = scripts.tower_plague_hospital.remove
	tt.attacks.range = cfg.attack_range
	tt.sound_events.insert = "d43_plague_taunt_1"
	tt.sound_events.change_rally_point = "d43_plague_taunt_2"
	tt.ui.click_rect = r(-47, -8, 94, 78)
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].name = "terrain_4_artillery_%04i"
	tt.render.sprites[1].offset = v(0, 15)
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].prefix = "d43_plaguetower"
	tt.render.sprites[2].name = "idle"
	tt.render.sprites[2].exo = true
	tt.render.sprites[2].offset = v(0, -8)
	tt.render.sprites[2].scale = v(1.265625, 1.265625)
	tt.render.sprites[3] = CC("sprite")
	tt.render.sprites[3].prefix = "d43_plaguetower_doctor"
	tt.render.sprites[3].name = "idle"
	tt.render.sprites[3].exo = true
	tt.render.sprites[3].offset = v(1, 47)
	tt.render.sprites[3].scale = v(1.265625, 1.265625)
	tt.render.sprites[3].z = Z_OBJECTS_COVERS
	tt.render.sprites[4] = CC("sprite")
	tt.render.sprites[4].prefix = "d43_plaguetower_towersmoke"
	tt.render.sprites[4].name = "idle"
	tt.render.sprites[4].exo = true
	tt.render.sprites[4].offset = v(0, -5)
	tt.render.sprites[4].draw_order = -1
	tt.render.sprites[4].scale = v(1.265625, 1.265625)
	tt.render.sprites[5] = CC("sprite")
	tt.render.sprites[5].prefix = "d43_plaguetower_decal"
	tt.render.sprites[5].name = "run"
	tt.render.sprites[5].exo = true
	tt.render.sprites[5].offset = v(0, -8)
	tt.render.sprites[5].z = Z_DECALS
	tt.render.sprites[5].scale = v(1.0125, 1.0125)
	tt.render.sprites[6] = CC("sprite")
	tt.render.sprites[6].prefix = "d43_plaguetower_smoke"
	tt.render.sprites[6].name = "run"
	tt.render.sprites[6].exo = true
	tt.render.sprites[6].offset = v(0, -8)
	tt.render.sprites[6].draw_order = -1
	tt.render.sprites[6].scale = v(1.265625, 1.265625)
	tt.render.sprites[7] = CC("sprite")
	tt.render.sprites[7].prefix = "d43_plaguetower_electricity"
	tt.render.sprites[7].name = "run"
	tt.render.sprites[7].exo = true
	tt.render.sprites[7].offset = v(0, -8)
	tt.render.sprites[7].draw_order = -1
	tt.render.sprites[7].scale = v(1.265625, 1.265625)
	tt.attacks.list[1] = CC("custom_attack")
	tt.attacks.list[1].entity = "soldier_plague_mutant"
	tt.attacks.list[1].cooldown = cfg.mike_cooldown[1]
	tt.attacks.list[1].disabled = true
	tt.attacks.list[1].vis_flags = F_BLOCK
	tt.attacks.list[1].vis_bans = bor(F_FLYING)
	tt.auras.list[1] = CC("aura_attack")
	tt.auras.list[1].name = "aura_plague_hospital_miasma"
	tt.auras.list[1].cooldown = 0
	tt.auras.list[2] = CC("aura_attack")
	tt.auras.list[2].name = "aura_plague_hospital_corpse"
	tt.auras.list[2].cooldown = 0
	tt.powers.mike = CC("power")
	tt.powers.mike.price_base = 210
	tt.powers.mike.price_inc = 140
	tt.powers.mike.max_level = 2
	tt.powers.mike.cooldown = {}
	for i = 1, #cfg.mike_cooldown do
		tt.powers.mike.cooldown[i] = cfg.mike_cooldown[i]
	end
	tt.powers.house = CC("power")
	tt.powers.house.price_base = 180
	tt.powers.house.price_inc = 180
	tt.powers.house.max_level = 2
	tt.powers.biohazard = CC("power")
	tt.powers.biohazard.price_base = 120
	tt.powers.biohazard.price_inc = 160
	tt.powers.biohazard.max_level = 2
	tt.barrack.soldier_type = "soldier_plague_mutant"
	tt.barrack.rally_range = 160
	tt.barrack.rally_radius = 30
	tt.barrack.max_soldiers = 0
	tt.barrack.rally_fn = scripts.tower_plague_hospital.rally_fn

	tt = reg(E, "mod_plague_hospital_miasma", "modifier")
	E:add_comps(tt, "dps", "render")
	tt.modifier.duration = cfg.miasma_duration
	tt.modifier.allows_duplicates = true
	tt.modifier.vis_flags = F_POISON
	tt.modifier.vis_bans = bor(F_FLYING)
	tt.dps.damage_every = cfg.miasma_duration
	tt.dps.damage_min = cfg.miasma_damage
	tt.dps.damage_max = cfg.miasma_damage
	tt.dps.damage_type = bor(DAMAGE_POISON, DAMAGE_NO_SHIELD_HIT)
	tt.dps.kill = true
	tt.main_script.insert = scripts.mod_dps_dove43.insert
	tt.main_script.update = scripts.mod_dps.update
	tt.render.sprites[1].prefix = "d43_plaguetower_status"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_EFFECTS

	tt = reg(E, "mod_plague_hospital_miasma_stun", "mod_stun")
	tt.modifier.resets_same = false
	tt.modifier.allows_duplicates = true
	tt.main_script.insert = scripts.mod_plague_hospital_miasma_stun.insert

	tt = reg(E, "mod_plague_hospital_buff", "modifier")
	E:add_comps(tt, "render")
	tt.modifier.duration = cfg.bio_duration[1]
	tt.main_script.insert = scripts.mod_plague_hospital_buff.insert
	tt.main_script.update = scripts.mod_plague_hospital_buff.update
	tt.main_script.remove = scripts.mod_plague_hospital_buff.remove
	tt.render.sprites[1].prefix = "d43_plaguetower_buff2"
	tt.render.sprites[1].name = "Idle"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_EFFECTS

	tt = reg(E, "aura_plague_hospital_miasma", "aura")
	E:add_comps(tt, "main_script")
	tt.aura.mods = {"mod_plague_hospital_miasma"}
	tt.aura.duration = 1e+99
	tt.aura.cycle_time = cfg.miasma_tick
	tt.aura.vis_flags = bor(F_MOD)
	tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
	tt.main_script.update = scripts.aura_plague_hospital_miasma.update

	tt = reg(E, "aura_plague_hospital_corpse", "aura")
	E:add_comps(tt, "main_script")
	tt.aura.duration = -1
	tt.aura.cycle_time = 0.2
	tt.ph_zombies = {}
	tt.ph_revive_queue = {}
	tt.ph_house_level = 0
	tt.main_script.update = scripts.aura_plague_hospital_corpse.update

	tt = reg(E, "decal_plague_hospital_decal", "decal_scripted")
	tt.render.sprites[1] = CC("sprite")
	tt.render.sprites[1].prefix = "d43_plaguetower_decal"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS
	tt.render.sprites[1].scale = v(1.125, 1.125)
	tt.ph_fx_fadeout = true
	tt.main_script.update = scripts.decal_plague_hospital.update

	tt = reg(E, "decal_plague_hospital_smoke", "decal_scripted")
	tt.render.sprites[1] = CC("sprite")
	tt.render.sprites[1].prefix = "d43_plaguetower_smoke"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS
	tt.render.sprites[1].scale = v(0.42, 0.42)
	tt.ph_fx_fadeout = true
	tt.main_script.update = scripts.decal_plague_hospital.update

	tt = reg(E, "decal_plague_hospital_spark", "decal_scripted")
	tt.render.sprites[1] = CC("sprite")
	tt.render.sprites[1].prefix = "d43_plaguetower_electricity"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS
	tt.render.sprites[1].scale = v(1.40625, 1.40625)
	tt.ph_fx_fadeout = false
	tt.main_script.update = scripts.decal_plague_hospital.update

	tt = reg(E, "soldier_plague_zombie", "soldier_militia")
	tt.info.i18n_key = "SOLDIER_PLAGUE_ZOMBIE"
	tt.info.portrait = "d43_plague_hospital_plague_zombie_portrait"
	tt.info.fn = scripts.soldier_plague_zombie.get_info
	tt.main_script.update = scripts.soldier_plague_zombie.update
	tt.health.hp_max = cfg.zombie_hp[1]
	tt.health.dead_lifetime = 6
	tt.regen.health = 0
	tt.motion.max_speed = cfg.zombie_speed
	tt.melee.range = cfg.zombie_melee_range
	tt.melee.attacks[1].damage_min = cfg.zombie_damage_min[1]
	tt.melee.attacks[1].damage_max = cfg.zombie_damage_max[1]
	tt.melee.attacks[1].hit_time = cfg.zombie_hit_time
	tt.soldier.melee_slot_offset = v(12, 0)
	tt.render.sprites[1].prefix = "d43_plaguetower_zombie"
	tt.render.sprites[1].name = "idle"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].angles = nil
	tt.render.sprites[1].scale = v(0.95, 0.95)
	tt.health_bar.offset = v(0, 21)
	tt.unit.hit_offset = v(0, 11)
	tt.vis.bans = bor(F_CANNIBALIZE, F_POISON, F_LYCAN, F_SKELETON)

	tt = reg(E, "soldier_plague_mutant", "soldier_militia")
	tt.info.i18n_key = "SOLDIER_PLAGUE_MUTANT"
	tt.info.portrait = "d43_plague_hospital_plague_mike_portrait"
	tt.info.fn = scripts.soldier_plague_mutant.get_info
	tt.main_script.insert = scripts.soldier_plague_mutant.insert
	tt.main_script.update = scripts.soldier_plague_mutant.update
	tt.health.hp_max = cfg.mike_hp[1]
	tt.health.armor = cfg.mike_armor
	tt.health.dead_lifetime = 6
	tt.regen.health = 64
	tt.motion.max_speed = cfg.mike_speed
	tt.melee.range = cfg.mike_melee_range
	tt.melee.attacks[1].damage_min = cfg.mike_damage_min[1]
	tt.melee.attacks[1].damage_max = cfg.mike_damage_max[1]
	tt.melee.attacks[1].damage_type = DAMAGE_TRUE
	tt.melee.attacks[1].hit_time = cfg.mike_hit_time
	tt.soldier.melee_slot_offset = v(20, 0)
	tt.render.sprites[1].prefix = "d43_plaguetower_giant"
	tt.render.sprites[1].name = "idle"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].angles = nil
	tt.render.sprites[1].scale = v(1.40625, 1.40625)
	tt.health_bar.offset = v(0, 48)
	tt.unit.hit_offset = v(0, 28)
	tt.vis.bans = bor(F_CANNIBALIZE, F_POISON, F_LYCAN, F_SKELETON)

end

do
local tower = E:get_template("tower_plague_hospital")
tower.tower.level = 4
tower.tower.kind = TOWER_KIND_ENGINEER
tower.tower.cooldown_factor = 1
tower.info.i18n_key = "TOWER_PLAGUE_HOSPITAL"
tower.info.enc_icon = 673
tower.render.sprites[1] = sc_terrain_sprite()
tower.dove43_dependencies = {"tower_plague_hospital","mod_plague_hospital_miasma","mod_plague_hospital_miasma_stun","mod_plague_hospital_buff","aura_plague_hospital_miasma","aura_plague_hospital_corpse","decal_plague_hospital_decal","decal_plague_hospital_smoke","decal_plague_hospital_spark","soldier_plague_zombie","soldier_plague_mutant"}
end

do -- command_center
local scripts = kr4_scripts
local cfg = scripts.dove43_config["command_center"]
local BODY_SCALE = 1.265625

	local reg = E.register_t
	local tt
	tt = reg(E, "tower_command_center", "tower")
	E:add_comps(tt, "attacks", "powers")
	tt.tower.type = "command_center"
	tt.tower.kind = TOWER_KIND_ENGINEER
	tt.tower.price = 350
	tt.tower.menu_offset = v(0, 24)
	tt.tower_cfg = cfg
	tt.info.fn = scripts.tower_command_center.get_info
	tt.info.portrait = "d43_command_center_cc_portrait"
	tt.main_script.insert = scripts.tower_command_center.insert
	tt.main_script.update = scripts.tower_command_center.update
	tt.main_script.remove = scripts.tower_command_center.remove
	tt.attacks.range = cfg.attack_range
	tt.sound_events.insert = "d43_cc_taunt_1"
	tt.ui.click_rect = r(-45, -5, 90, 80)
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].name = "terrain_4_artillery_%04i"
	tt.render.sprites[1].offset = v(0, 15)
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].prefix = "d43_commandcenter_tower"
	tt.render.sprites[2].name = "idle"
	tt.render.sprites[2].exo = true
	tt.render.sprites[2].offset = v(0, 0)
	tt.render.sprites[2].scale = v(1.265625, 1.265625)
	tt.attacks.list[1] = CC("bullet_attack")
	tt.attacks.list[1].bullet = "cc_flashbang_bullet"
	tt.attacks.list[1].cooldown = cfg.flashbang_cooldown
	tt.attacks.list[1].shoot_time = 1.33
	tt.attacks.list[1].vis_flags = bor(F_RANGED)
	tt.attacks.list[1].vis_bans = bor(F_FLYING)
	tt.attacks.list[1].bullet_start_offset = v(-17, 55)
	tt.attacks.list[1].node_prediction = true
	tt.attacks.list[2] = CC("custom_attack")
	tt.attacks.list[2].cooldown = 1
	tt.attacks.list[2].mod = "mod_cc_command_aura"
	tt.attacks.list[2].mod_fx = "mod_cc_command_aura_fx"
	tt.attacks.list[2].max_range = cfg.attack_range
	tt.attacks.list[2].min_range = 0
	tt.attacks.list[2].vis_flags = bor(F_MOD)
	tt.powers.radar = CC("power")
	tt.powers.radar.price_base = 280
	tt.powers.radar.price_inc = 280
	tt.powers.radar.max_level = 3
	tt.powers.radar.armor_threshold = 0.9
	tt.powers.radar.damage = {50, 100, 150}
	tt.powers.intranet = CC("power")
	tt.powers.intranet.price_base = 350
	tt.powers.intranet.price_inc = 100
	tt.powers.intranet.max_level = 2
	tt.powers.intranet.range_bonus = {0.24, 0.36}
	tt.powers.reaper = CC("power")
	tt.powers.reaper.price_base = 315
	tt.powers.reaper.price_inc = 315
	tt.powers.reaper.max_level = 3
	tt.powers.reaper.execute_ratio = {0.04, 0.12, 0.20}
	tt.powers.airstrike = CC("power")
	tt.powers.airstrike.price_base = 225
	tt.powers.airstrike.price_inc = 225
	tt.powers.airstrike.max_level = 3
	tt.powers.airstrike.cooldown_base = 16
	tt.powers.airstrike.missiles = {1, 2, 3}

	tt = reg(E, "cc_flashbang_bullet", "bomb")
	tt.bullet.damage_min = cfg.flashbang_damage_min
	tt.bullet.damage_max = cfg.flashbang_damage_max
	tt.bullet.damage_radius = cfg.flashbang_damage_radius
	tt.bullet.hit_fx = "fx_cc_flashbang_fx"
	tt.bullet.mod = "mod_stun"
	tt.render.sprites[1] = CC("sprite")
	tt.render.sprites[1].prefix = "d43_commandcenter_flashbang"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.sound_events.insert = nil
	tt.sound_events.hit = "d43_cc_missile"

	tt = reg(E, "mod_cc_command_aura", "modifier")
	tt.main_script.insert = scripts.mod_tower_factors.insert
	tt.main_script.update = scripts.mod_cc_command_aura.update
	tt.main_script.remove = scripts.mod_cc_command_aura.remove
	tt.modifier.duration = 1e+99
	tt.modifier.use_mod_offset = false

	tt = reg(E, "mod_cc_command_aura_fx", "modifier")
	E:add_comps(tt, "render")
	tt.main_script.insert = scripts.mod_cc_command_aura_fx.insert
	tt.main_script.update = scripts.mod_cc_command_aura_fx.update
	tt.modifier.duration = 1e+99
	tt.modifier.use_mod_offset = false
	tt.modifier.keep_on_tower_upgrade = true
	tt.render.sprites[1].prefix = "d43_commandcenter_power_tower_decal"
	tt.render.sprites[1].name = "Idle"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_TOWER_BASES + 1

	tt = reg(E, "mod_cc_intranet_range", "modifier")
	E:add_comps(tt, "render")
	tt.main_script.insert = scripts.mod_cc_intranet_range.insert
	tt.main_script.update = scripts.mod_cc_intranet_range.update
	tt.main_script.remove = scripts.mod_cc_intranet_range.remove
	tt.modifier.allows_duplicates = true
	tt.modifier.duration = 1e+99
	tt.modifier.use_mod_offset = false
	tt.render.sprites[1].prefix = "d43_commandcenter_activate"
	tt.render.sprites[1].name = "buff"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].loop = true
	tt.render.sprites[1].z = Z_EFFECTS
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].prefix = "d43_commandcenter_parabolic"
	tt.render.sprites[2].name = "Idle"
	tt.render.sprites[2].exo = true
	tt.render.sprites[2].hidden = true
	tt.render.sprites[2].z = Z_TOWER_BASES + 1

	tt = reg(E, "cc_intranet_wave", "fx")
	E:add_comps(tt, "main_script")
	tt.timed = nil
	tt.render.sprites[1].prefix = "d43_commandcenter_skillbwaves"
	tt.render.sprites[1].name = "start"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_EFFECTS
	tt.main_script.update = scripts.cc_intranet_wave.update

	tt = reg(E, "fx_cc_intranet_hit", "fx")
	tt.render.sprites[1].prefix = "d43_commandcenter_skilladvanced"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_EFFECTS

	tt = reg(E, "cc_power_plane", "fx")
	E:add_comps(tt, "main_script")
	tt.timed = nil
	tt.render.sprites[1].prefix = "d43_commandcenter_power_plane"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_EFFECTS
	tt.main_script.update = scripts.cc_power_plane.update

	tt = reg(E, "fx_cc_power_target", "fx")
	E:add_comps(tt, "main_script")
	tt.timed = nil
	tt.render.sprites[1].prefix = "d43_commandcenter_power_target"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_EFFECTS
	tt.main_script.update = scripts.fx_cc_power_target.update

	tt = reg(E, "cc_power_missile", "bomb")
	tt.bullet.damage_type = DAMAGE_EXPLOSION
	tt.bullet.damage_min = cfg.airstrike_damage_min[1]
	tt.bullet.damage_max = cfg.airstrike_damage_max[1]
	tt.bullet.damage_radius = cfg.airstrike_damage_radius
	tt.bullet.execute_ratio = 0.04
	tt.bullet.damage_flags = F_AREA
	tt.bullet.vis_flags = bor(F_RANGED)
	tt.bullet.min_speed = 300
	tt.bullet.max_speed = 450
	tt.bullet.turn_speed = 10 * math.pi / 180 * 30
	tt.bullet.acceleration_factor = 0.1
	tt.bullet.retarget_range = math.huge
	tt.bullet.particles_name = "ps_missile"
	tt.bullet.hit_fx = "fx_cc_power_explosion"
	tt.bullet.hit_fx_water = nil
	tt.main_script.insert = scripts.missile.insert
	tt.main_script.update = scripts.missile_cc_reaper.update
	tt.render.sprites[1] = CC("sprite")
	tt.render.sprites[1].prefix = "d43_commandcenter_power_missile"
	tt.render.sprites[1].name = "flying"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].flip_x = true
	tt.sound_events.insert = nil
	tt.sound_events.hit = "d43_cc_missile"

	tt = reg(E, "cc_reaper_missile", "bullet")
	tt.bullet.damage_type = DAMAGE_EXPLOSION
	tt.bullet.damage_min = 40
	tt.bullet.damage_max = 200
	tt.bullet.damage_radius = 47.5
	tt.bullet.damage_flags = F_AREA
	tt.bullet.vis_flags = F_RANGED
	tt.bullet.vis_bans = 0
	tt.bullet.damage_bans = 0
	tt.bullet.min_speed = 300
	tt.bullet.max_speed = 450
	tt.bullet.turn_speed = 10 * math.pi / 180 * 30
	tt.bullet.acceleration_factor = 0.1
	tt.bullet.retarget_range = 99999
	tt.bullet.particles_name = "ps_cc_reaper_missile"
	tt.bullet.hit_fx = "fx_cc_power_explosion"
	tt.bullet.hit_fx_air = "fx_cc_power_explosion"
	tt.render.sprites[1].prefix = "d43_cc_reaper_missile"
	tt.render.sprites[1].name = "flying"
	tt.render.sprites[1].loop = true
	tt.main_script.insert = scripts.missile.insert
	tt.main_script.update = scripts.missile_cc_reaper.update
	tt.sound_events.insert = "d43_cc_missile"
	tt.sound_events.hit = "d43_cc_missile"

	tt = reg(E, "ps_cc_reaper_missile", "ps_missile")
	tt.particle_system.name = "d43_command_center_reaper_trail"

	tt = reg(E, "fx_cc_power_explosion", "fx")
	tt.render.sprites[1].prefix = "d43_commandcenter_power_explosion"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -2

	tt = reg(E, "fx_cc_flashbang_fx", "fx")
	tt.render.sprites[1].prefix = "d43_commandcenter_flashbangFX"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -2

end

do
local tower = E:get_template("tower_command_center")
tower.tower.level = 4
tower.tower.kind = TOWER_KIND_ENGINEER
tower.tower.cooldown_factor = 1
tower.info.i18n_key = "TOWER_COMMAND_CENTER"
tower.info.enc_icon = 674
tower.render.sprites[1] = sc_terrain_sprite()
tower.dove43_dependencies = {"tower_command_center","cc_flashbang_bullet","mod_cc_command_aura","mod_cc_command_aura_fx","mod_cc_intranet_range","cc_intranet_wave","fx_cc_intranet_hit","cc_power_plane","fx_cc_power_target","cc_power_missile","cc_reaper_missile","ps_cc_reaper_missile","fx_cc_power_explosion","fx_cc_flashbang_fx"}
end

do -- ice_cooler
local scripts = kr4_scripts
local cfg = scripts.dove43_config["ice_cooler"]
local BODY_SCALE = 1.265625
	local tt

	tt = RT("fx_ice_cooler_explosion_cian", "fx")
	tt.render.sprites[1].prefix = "d43_icecooler_explosion_cian"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].sort_y_offset = 2

	tt = RT("fx_ice_cooler_explosion_pink", "fx")
	tt.render.sprites[1].prefix = "d43_icecooler_explosion_pink"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].sort_y_offset = 2

	tt = RT("fx_ice_cooler_explosion_green", "fx")
	tt.render.sprites[1].prefix = "d43_icecooler_explosion_green"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].sort_y_offset = 2

	tt = RT("fx_ice_cooler_icecloud", "fx")
	tt.render.sprites[1].prefix = "d43_icecooler_icecloud"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].scale = v(1.265625, 1.265625)

	tt = RT("fx_ice_cooler_breath", "fx")
	tt.render.sprites[1].prefix = "d43_icecooler_breath"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_BULLETS
	tt.render.sprites[1].scale = v(1.265625, 1.265625)
	tt.timed.runs = INT_32_MAX

	tt = RT("fx_ice_cooler_freeze_mark", "decal_tween")
	tt.render.sprites[1] = E:clone_c("sprite")
	tt.render.sprites[1].prefix = "d43_icecooler_freeze_mark"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS
	tt.tween.props[1].name = "alpha"
	tt.tween.props[1].keys = {{0, 255}, {1.6, 255}, {2.2, 0}}

	tt = RT("mod_ice_cooler_freeze", "mod_freeze")
	E:add_comps(tt, "render")
	tt.modifier.duration = cfg.freeze_duration
	tt.modifier.vis_bans = bor(F_BOSS, F_POLYMORPH)
	tt.render.sprites[1].prefix = "d43_icecooler_freeze_mod"
	tt.render.sprites[1].name = "idle"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].loop = true
	tt.render.sprites[1].offset = v(0, -5)
	tt.render.sprites[1].sort_y_offset = -2

	tt = RT("enemy_ice_cooler_snowman", "enemy")
	tt.main_script.update = scripts.enemy_ice_cooler_snowman.update
	tt.health.armor = 0
	tt.health.magic_armor = 0
	tt.health_bar.offset = v(0, 46)
	tt.unit.hit_offset = v(0, 10)
	tt.unit.mod_offset = v(0, 12)
	tt.motion.max_speed = 0
	tt.render.sprites[1].prefix = "d43_icecooler_snowman"
	tt.render.sprites[1].name = "in"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].angles = {walk = {"idle"}}
	tt.render.sprites[1].scale = v(1.265625, 1.265625)
	tt.info.portrait = "d43_ice_cooler_ice_cooler_snowman_portrait"
	tt.sound_events.death = "d43_ice_cooler_snowman_death"
	tt.vis.flags = bor(F_ENEMY, F_POLYMORPH)
	tt.vis.bans = bor(F_BLOCK, F_SKELETON)

	tt = RT("mod_ice_cooler_polymorph", "modifier")
	tt.modifier.duration = cfg.flavors_duration
	tt.modifier.vis_bans = bor(F_POLYMORPH, F_BOSS)
	tt.entity_hp = cfg.flavors_hp
	tt.transform_fx = "fx_ice_cooler_icecloud"
	tt.sound_transform = "d43_ice_cooler_freeze"
	tt.main_script.insert = scripts.mod_ice_cooler_polymorph.insert
	tt.main_script.update = scripts.mod_ice_cooler_polymorph.update
	tt.main_script.remove = scripts.mod_ice_cooler_polymorph.remove

	for i = 1, 3 do
		tt = RT("mod_ice_cooler_party_polymorph_" .. i, "mod_ice_cooler_polymorph")
		tt.entity_hp = cfg.flavors_hp[i]
		tt.party_chance = cfg.flavors_chance[i]
		tt.main_script.insert = scripts.mod_ice_cooler_polymorph.insert
		tt.main_script.update = scripts.mod_ice_cooler_polymorph.update
		tt.main_script.remove = scripts.mod_ice_cooler_polymorph.remove
	end

	tt = RT("ice_cooler_icecream", "bomb")
	tt.main_script.insert = scripts.bomb_dove43.insert
	tt.main_script.update = scripts.bomb_dove43.update
	tt.bullet.flight_time = fts(18)
	tt.bullet.rotation_speed = 20 * 30 * math.pi / 180
	tt.bullet.damage_type = DAMAGE_MAGICAL
	tt.bullet.damage_min = cfg.party_damage_min
	tt.bullet.damage_max = cfg.party_damage_max
	tt.bullet.damage_radius = cfg.party_radius
	tt.bullet.damage_flags = F_AREA
	tt.bullet.mods = {"mod_ice_cooler_freeze"}
	tt.bullet.hit_fx = "fx_ice_cooler_explosion_cian"
	tt.bullet.hit_decal = nil
	tt.bullet.hide_radius = nil
	tt.bullet.pop = nil
	tt.render.sprites[1].name = "d43_ice_cooler_asst_icecream_cian"
	tt.render.sprites[1].animated = false
	tt.sound_events.insert = nil
	tt.sound_events.hit = "d43_ice_cooler_party_explosion"

	tt = RT("ice_cooler_breath_bullet", "bullet")
	tt.bullet.damage_type = DAMAGE_MAGICAL
	tt.bullet.damage_min = cfg.damage_min
	tt.bullet.damage_max = cfg.damage_max

	for _, fan in ipairs({{"soldier_ice_cooler_fan_cyan", "d43_icecooler_fan_cyan", "d43_ice_cooler_ice_cooler_fan_cyan_portrait"}, {"soldier_ice_cooler_fan_pink", "d43_icecooler_fan_pink", "d43_ice_cooler_ice_cooler_fan_pink_portrait"}, {"soldier_ice_cooler_fan_green", "d43_icecooler_fan_green", "d43_ice_cooler_ice_cooler_fan_green_portrait"}}) do
		local tt = RT(fan[1], "soldier_militia")

		E:add_comps(tt, "reinforcement", "tween")
		tt.main_script.update = scripts.soldier_ice_cooler_fan.update
		tt.health.hp_max = type(cfg.fans_hp) == "table" and cfg.fans_hp[1] or cfg.fans_hp
		tt.regen.health = 0
		tt.regen.cooldown = 2
		tt.melee.attacks[1].cooldown = 1
		tt.melee.attacks[1].damage_min = cfg.fans_damage_min
		tt.melee.attacks[1].damage_max = cfg.fans_damage_max
		tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
		tt.melee.attacks[1].hit_time = fts(13)
		tt.melee.attacks[1].sound = nil
		tt.melee.range = 60
		tt.motion.max_speed = 50
		tt.reinforcement.duration = type(cfg.fans_duration) == "table" and cfg.fans_duration[1] or cfg.fans_duration
		tt.reinforcement.fade = false
		tt.reinforcement.fade_out = true
		tt.tween.props[1].name = "alpha"
		tt.tween.props[1].keys = {{0, 0}, {fts(10), 255}}
		tt.tween.remove = false
		tt.tween.disabled = true
		tt.patrol_pos_offset = v(15, 10)
		tt.patrol_min_cd = 3
		tt.patrol_max_cd = 6
		tt.render.sprites[1].prefix = fan[2]
		tt.render.sprites[1].name = "indash"
		tt.render.sprites[1].exo = true
		tt.render.sprites[1].scale = v(1.125, 1.125)
		tt.render.sprites[1].angles = {
			walk = {"walk"}
		}
		tt.info.portrait = fan[3]
		tt.health_bar.offset = v(0, 37)
		tt.unit.hit_offset = v(0, 16)
		tt.unit.mod_offset = v(0, 18)
		tt.soldier.melee_slot_offset = v(15, 0)
		tt.vis.bans = bor(F_POISON, F_CANNIBALIZE, F_LYCAN, F_SKELETON)
	end

	tt = RT("tower_ice_cooler", "tower")
	E:add_comps(tt, "attacks", "powers")
	tt.attacks.list[1] = CC("bullet_attack")
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[3] = CC("sprite")
	tt.info.portrait = "d43_ice_cooler_ice_cooler_portrait"
	tt.info.fn = scripts.tower_ice_cooler.get_info
	tt.tower.type = "ice_cooler"
	tt.tower.price = 315
	tt.powers.party = E:clone_c("power")
	tt.powers.party.max_level = 1
	tt.powers.party.price_base = 320
	tt.powers.flavors = E:clone_c("power")
	tt.powers.flavors.max_level = 3
	tt.powers.flavors.price_base = 300
	tt.powers.flavors.price_inc = 150
	tt.powers.fans = E:clone_c("power")
	tt.powers.fans.max_level = 2
	tt.powers.fans.price_base = 200
	tt.powers.fans.price_inc = 100
	tt.powers.party.count = cfg.party_count
	tt.powers.party.radius = cfg.party_radius
	tt.powers.party.damage_min = cfg.party_damage_min
	tt.powers.party.damage_max = cfg.party_damage_max
	tt.powers.party.cooldown = cfg.party_cooldown
	tt.powers.flavors.chance = cfg.flavors_chance
	tt.powers.flavors.hp = cfg.flavors_hp
	tt.powers.flavors.duration = cfg.flavors_duration
	tt.powers.fans.cooldown = cfg.fans_cooldown
	tt.powers.fans.hp = cfg.fans_hp
	tt.powers.fans.count = cfg.fans_count
	tt.powers.fans.damage_min = cfg.fans_damage_min
	tt.powers.fans.damage_max = cfg.fans_damage_max
	tt.powers.fans.duration = cfg.fans_duration
	tt.attacks.range = cfg.range
	tt.attacks.list[1].bullet = nil
	tt.attacks.list[1].cooldown = cfg.cooldown
	tt.attacks.list[1].damage_min = cfg.damage_min
	tt.attacks.list[1].damage_max = cfg.damage_max
	tt.attacks.list[2] = E:clone_c("bullet_attack")
	tt.attacks.list[2].cooldown = cfg.party_cooldown
	tt.attacks.list[2].requires_magic = false
	tt.attacks.list[2].vis_bans = bor(F_FLYING, F_CLIFF)
	tt.attacks.list[3] = E:clone_c("bullet_attack")
	tt.attacks.list[3].cooldown = cfg.fans_cooldown[1] or cfg.fans_cooldown
	tt.attacks.list[3].requires_magic = false
	tt.attacks.list[3].vis_flags = F_BLOCK
	tt.attacks.list[3].vis_bans = bor(F_FLYING)
	tt.render.sprites[2].prefix = "d43_icecooler_tower"
	tt.render.sprites[2].name = "idle"
	tt.render.sprites[2].exo = true
	tt.render.sprites[2].offset = v(0, -7)
	tt.render.sprites[2].scale = v(1.265625, 1.265625)
	tt.render.sprites[3].prefix = "d43_icecooler_shooter"
	tt.render.sprites[3].name = "idle"
	tt.render.sprites[3].exo = true
	tt.render.sprites[3].angles = nil
	tt.render.sprites[3].offset = v(2, 50)
	tt.render.sprites[3].scale = v(1.265625, 1.265625)
	tt.render.sid_tower = 2
	tt.render.sid_shooter = 3
	tt.sound_events.insert = "d43_ice_cooler_taunt_3"
	tt.main_script.update = scripts.tower_ice_cooler.update
	tt.main_script.remove = scripts.tower_ice_cooler.remove

end

do
local tower = E:get_template("tower_ice_cooler")
tower.tower.level = 4
tower.tower.kind = TOWER_KIND_MAGE
tower.tower.cooldown_factor = 1
tower.info.i18n_key = "TOWER_ICE_COOLER"
tower.info.enc_icon = 675
tower.render.sprites[1] = sc_terrain_sprite()
tower.dove43_dependencies = {"fx_ice_cooler_explosion_cian","fx_ice_cooler_explosion_pink","fx_ice_cooler_explosion_green","fx_ice_cooler_icecloud","fx_ice_cooler_breath","fx_ice_cooler_freeze_mark","mod_ice_cooler_freeze","enemy_ice_cooler_snowman","mod_ice_cooler_polymorph","mod_ice_cooler_party_polymorph_","ice_cooler_icecream","ice_cooler_breath_bullet","tower_ice_cooler","soldier_ice_cooler_fan_cyan","soldier_ice_cooler_fan_green","soldier_ice_cooler_fan_pink"}
end

do -- machine_gunner
local scripts = kr4_scripts
local cfg = scripts.dove43_config["machine_gunner"]
local BODY_SCALE = 1.265625

	local reg = E.register_t
	local tt

	tt = reg(E, "tower_machine_gunner", "tower_archer_1")
	E:add_comps(tt, "powers")
	tt.tower.type = "machine_gunner"
	tt.tower.price = 375
	tt.tower.size = TOWER_SIZE_LARGE
	tt.tower.menu_offset = v(2, 20)
	tt.info.portrait = "d43_machine_gunner_machine_gunner_portrait"
	tt.info.i18n_key = "TOWER_MACHINE_GUNNER"
	tt.info.fn = scripts.tower_machine_gunner.get_info
	tt.tower.tower_cfg = cfg

	tt.powers.storm = CC("power")
	tt.powers.storm.price_base = 300
	tt.powers.storm.max_level = 1
	tt.powers.storm.cooldown = cfg.storm_cooldown
	tt.powers.medal = CC("power")
	tt.powers.medal.price_base = 250
	tt.powers.medal.max_level = 1
	tt.powers.arrow = CC("power")
	tt.powers.arrow.price_base = 150
	tt.powers.arrow.price_inc = 125
	tt.powers.arrow.max_level = 3

	local body_offset = v(0, 4)
	local shooter_offset = v(4, 29)
	local shooter_scale = BODY_SCALE * 0.9

	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].prefix = "d43_machinegunner_base"
	tt.render.sprites[2].name = "idle"
	tt.render.sprites[2].exo = true
	tt.render.sprites[2].offset = body_offset
	tt.render.sprites[2].scale = v(BODY_SCALE, BODY_SCALE)

	tt.render.sprites[3] = CC("sprite")
	tt.render.sprites[3].prefix = "d43_shooter_machinegunner"
	tt.render.sprites[3].name = "idle"
	tt.render.sprites[3].exo = true
	tt.render.sprites[3].offset = shooter_offset
	tt.render.sprites[3].scale = v(shooter_scale, shooter_scale)
	tt.render.sprites[3].angles = {
		idle = { "idleUp", "idleDown" },
		shoot = { "shootUp", "shootDown" },
	}

	tt.render.sprites[4] = CC("sprite")
	tt.render.sprites[4].prefix = "d43_machinegunner_base_skill_a"
	tt.render.sprites[4].name = "idle"
	tt.render.sprites[4].exo = true
	tt.render.sprites[4].offset = body_offset
	tt.render.sprites[4].scale = v(BODY_SCALE, BODY_SCALE)
	tt.render.sprites[4].hidden = true

	tt.render.sprites[5] = CC("sprite")
	tt.render.sprites[5].prefix = "d43_machinegunner_base_skill_b"
	tt.render.sprites[5].name = "idle"
	tt.render.sprites[5].exo = true
	tt.render.sprites[5].offset = body_offset
	tt.render.sprites[5].scale = v(BODY_SCALE, BODY_SCALE)
	tt.render.sprites[5].hidden = true

	tt.render.sid_body = 2
	tt.render.sid_shooter = 3
	tt.render.sid_deco_medal = 4
	tt.render.sid_deco_arrow = 5

	tt.attacks.range = cfg.attack_range
	tt.attacks.list[1] = CC("bullet_attack")
	tt.attacks.list[1].animation = "shoot"
	tt.attacks.list[1].bullet = "bullet_machine_gunner_shot"
	tt.attacks.list[1].cooldown = cfg.attack_cooldown
	tt.attacks.list[1].shoot_time = 0.1
	tt.attacks.list[1].vis_flags = bor(F_RANGED)

	tt.attacks.list[2] = CC("bullet_attack")
	tt.attacks.list[2].animation = "bulletstormUp"
	tt.attacks.list[2].bullet = "bullet_machine_gunner_storm"
	tt.attacks.list[2].cooldown = cfg.storm_cooldown
	tt.attacks.list[2].shoot_time = 0.05
	tt.attacks.list[2].vis_flags = bor(F_RANGED)
	tt.attacks.list[2].disabled = true

	tt.attacks.list[3] = CC("bullet_attack")
	tt.attacks.list[3].animation = "skilladvanced"
	tt.attacks.list[3].bullet = "arrow_machine_gunner_arrow"
	tt.attacks.list[3].cooldown = cfg.arrow_cooldown[1]
	tt.attacks.list[3].range = cfg.arrow_range
	tt.attacks.list[3].shoot_time = 0.5
	tt.attacks.list[3].vis_flags = bor(F_RANGED)
	tt.attacks.list[3].disabled = true
	tt.attacks.list[3].per_level_damage_min = { cfg.arrow_damage_min[1], cfg.arrow_damage_min[2], cfg.arrow_damage_min[3] }
	tt.attacks.list[3].per_level_damage_max = { cfg.arrow_damage_max[1], cfg.arrow_damage_max[2], cfg.arrow_damage_max[3] }
	tt.attacks.list[3].per_level_cooldown = { cfg.arrow_cooldown[1], cfg.arrow_cooldown[2], cfg.arrow_cooldown[3] }
	tt.attacks.list[3].per_level_count = { cfg.arrow_count[1], cfg.arrow_count[2], cfg.arrow_count[3] }

	tt.main_script.update = scripts.tower_machine_gunner.update
	tt.sound_events.insert = "d43_machine_gunner_taunt_1"

	tt = reg(E, "bullet_machine_gunner_shot", "shotgun")
	tt.main_script.insert = scripts.shotgun_dove43.insert
	tt.main_script.update = scripts.shotgun_dove43.update
	tt.bullet.damage_min = cfg.attack_damage_min
	tt.bullet.damage_max = cfg.attack_damage_max
	tt.bullet._cfg_damage_min = cfg.attack_damage_min
	tt.bullet._cfg_damage_max = cfg.attack_damage_max
	-- Preserve native per-round maximum scaling: KR4 Master Architect yields 24-54.
	tt.bullet.volley_damage = {damage_min = 22, base_max = cfg.attack_damage_max * 3}
	tt.bullet.damage_type = bor(DAMAGE_PHYSICAL, DAMAGE_NO_DODGE)
	tt.bullet.damage_radius = 25
	tt.bullet.hit_fx = "fx_machine_gunner_hit"
	tt.bullet.miss_fx = "fx_smoke_bullet"
	tt.bullet.min_speed = 30 * FPS
	tt.bullet.max_speed = 30 * FPS
	tt.bullet.hide_radius = 35
	tt.bullet.pop = { "pop_thunk" }
	tt.bullet.vis_flags = bor(F_RANGED)
	tt.sound_events.insert = "d43_machine_gunner_shot"

	tt = reg(E, "bullet_machine_gunner_storm", "bullet_machine_gunner_shot")
	tt.bullet.damage_radius = 0
	tt.bullet.damage_min = cfg.attack_damage_min * cfg.storm_damage_factor
	tt.bullet.damage_max = cfg.attack_damage_max * cfg.storm_damage_factor
	tt.bullet._cfg_damage_min = cfg.attack_damage_min * cfg.storm_damage_factor
	tt.bullet._cfg_damage_max = cfg.attack_damage_max * cfg.storm_damage_factor
	tt.bullet.damage_type = bor(DAMAGE_TRUE, DAMAGE_NO_DODGE)
	tt.bullet.hide_radius = 20

	tt = reg(E, "arrow_machine_gunner_arrow", "arrow")
	tt.bullet.damage_min = cfg.arrow_direct_damage_min
	tt.bullet.damage_max = cfg.arrow_direct_damage_max
	tt.bullet.damage_type = DAMAGE_PHYSICAL
	tt.bullet.payload = "aura_machine_gunner_burst"
	tt.bullet.prediction_error = false
	tt.bullet.asymmetrical = true
	tt.bullet.flight_time_min = fts(10)
	tt.bullet.flight_time_factor = fts(5) * 1.8
	tt.bullet.vis_flags = bor(F_RANGED)
	tt.bullet.particles_name = "ps_machine_gunner_arrow_trail"
	tt.render.sprites[1].name = "d43_machine_gunner_asst_machinegunner_arrow2"
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].flip_x = true
	tt.sound_events.insert = "d43_machine_gunner_arrow_shot"

	tt = reg(E, "ps_machine_gunner_arrow_trail", "particle_system")
	tt.particle_system.names = {
		"d43_machine_gunner_asst_machinegunner_trail1",
		"d43_machine_gunner_asst_machinegunner_trail2",
		"d43_machine_gunner_asst_machinegunner_trail3",
		"d43_machine_gunner_asst_machinegunner_trail4",
		"d43_machine_gunner_asst_machinegunner_trail5",
		"d43_machine_gunner_asst_machinegunner_trail6",
		"d43_machine_gunner_asst_machinegunner_trail7",
		"d43_machine_gunner_asst_machinegunner_trail8",
	}
	tt.particle_system.emission_rate = 20
	tt.particle_system.loop = false
	tt.particle_system.particle_lifetime = { fts(5), fts(6) }
	tt.particle_system.track_rotation = true
	tt.particle_system.scales_x = { 0.5, 1 }
	tt.particle_system.scales_y = { 0.5, 1 }
	tt.particle_system.alphas = { 220, 0 }

	tt = reg(E, "aura_machine_gunner_burst", "aura")
	E:add_comps(tt, "render")
	tt.aura.damage_type = DAMAGE_EXPLOSION
	tt.aura.radius = cfg.arrow_radius
	tt.aura.vis_flags = bor(F_RANGED)
	tt.aura.per_level_damage_min = { cfg.arrow_damage_min[1], cfg.arrow_damage_min[2], cfg.arrow_damage_min[3] }
	tt.aura.per_level_damage_max = { cfg.arrow_damage_max[1], cfg.arrow_damage_max[2], cfg.arrow_damage_max[3] }
	tt.main_script.update = scripts.aura_machine_gunner_burst.update
	tt.render.sprites[1].prefix = "d43_shooter_machinegunner_skill_explosion"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_EFFECTS
	tt.sound_events.insert = "d43_machine_gunner_arrow_explosion"

	tt = reg(E, "fx_machine_gunner_hit", "fx")
	tt.render.sprites[1].prefix = "d43_shooter_machinegunner_hit"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_EFFECTS

	tt = reg(E, "fx_machine_gunner_ripple", "fx")
	tt.render.sprites[1].prefix = "d43_machinegunner_ripple_fx"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_EFFECTS

end

do
local tower = E:get_template("tower_machine_gunner")
tower.tower.level = 4
tower.tower.kind = TOWER_KIND_ARCHER
tower.tower.cooldown_factor = 1
tower.info.i18n_key = "TOWER_MACHINE_GUNNER"
tower.info.enc_icon = 676
tower.render.sprites[1] = sc_terrain_sprite()
tower.dove43_dependencies = {"tower_machine_gunner","bullet_machine_gunner_shot","bullet_machine_gunner_storm","arrow_machine_gunner_arrow","ps_machine_gunner_arrow_trail","aura_machine_gunner_burst","fx_machine_gunner_hit","fx_machine_gunner_ripple"}
end
-- END DOVE43 BUILTIN TOWERS

-- BEGIN DOVE43 EXTRA TOWERS
do
local E = require("entity_db")
local scripts = kr4_scripts
local kr5_scripts = require("game_scripts-5")
local v = require("klua.vector").v
local bit = require("bit")
local bor = bit.bor
local function vv(x, y) return v(x, y) end
local function fts(t) return t / 30 end
local function CC(name) return E:clone_c(name) end
local function r(x, y, w, h) return {pos = v(x, y), size = v(w, h)} end
local tt

do
local cfg = {["attack_radius"]=75,["attack_cooldown"]=3.3,["attack_damage_min"]=68,["attack_damage_max"]=112,["precision_cooldown"]={20,18,15},["precision_damage_min"]={110,160,210},["precision_damage_max"]={183,258,333},["precision_radius"]=50,["drone_range"]=130,["drone_cooldown"]=1.5,["drone_damage_min"]=38,["drone_damage_max"]=72,["drone_detect_range"]=200,["drone_leash_range"]=80,["drone_move_speed"]=150,["slow_radius"]=75,["slow_factor"]={0.85,0.7}}
	tt = E:register_t("tower_blastin_bullriders", "tower")
	E:add_comps(tt, "attacks", "powers", "auras", "barrack")
	tt.tower.type = "blastin_bullriders"
	tt.tower.price = 330
	tt.tower.menu_offset = v(0, 22)
	tt.tower_cfg = cfg
	tt.info.portrait = "d43_blastin_bullriders_blastin_bullriders_portrait"
	tt.info.fn = scripts.tower_common.get_info
	tt.main_script.insert = scripts.tower_blastin_bullriders.insert
	tt.main_script.update = scripts.tower_blastin_bullriders.update
	tt.main_script.remove = scripts.tower_blastin_bullriders.remove
	tt.attacks.range = cfg.attack_radius
	tt.sound_events.insert = "d43_blastin_taunt_1"
	tt.sound_events.change_rally_point = "d43_blastin_taunt_2"
	tt.ui.click_rect = r(-48, -8, 96, 80)
	tt.barrack.soldier_type = ""
	tt.barrack.max_soldiers = 0
	tt.barrack.rally_range = math.huge
	tt.barrack.rally_radius = 20
	tt.barrack.rally_anywhere = true
	tt.barrack.rally_fn = nil
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].name = "terrain_4_artillery_%04i"
	tt.render.sprites[1].offset = v(0, 15)
	local body = {prefix = "d43_aerial_strike", offset = v(0, 4), scale = v(1.265625, 1.265625)}
	local body_a = {prefix = "d43_aerial_strike_skill_a", offset = v(0, 4), scale = v(1.265625, 1.265625)}
	local body_b = {prefix = "d43_aerial_strike_skill_b", offset = v(0, 4), scale = v(1.265625, 1.265625)}
	local body_ab = {prefix = "d43_aerial_strike_skill_ab", offset = v(0, 4), scale = v(1.265625, 1.265625)}
	local weapon = {prefix = "d43_aerial_strike_cactus", offset = v(0, 4), scale = v(1.265625, 1.265625)}
	local weapon_a = {prefix = "d43_aerial_strike_cactus_skill_a", offset = v(0, 4), scale = v(1.265625, 1.265625)}
	local weapon_b = {prefix = "d43_aerial_strike_cactus_skill_b", offset = v(0, 4), scale = v(1.265625, 1.265625)}
	local weapon_ab = {prefix = "d43_aerial_strike_cactus_skill_ab", offset = v(0, 4), scale = v(1.265625, 1.265625)}
	local function add_exo_sprite(def, hidden)
		local i = #tt.render.sprites + 1
		tt.render.sprites[i] = CC("sprite")
		tt.render.sprites[i].prefix = def.prefix
		tt.render.sprites[i].name = def.anim or "idle"
		tt.render.sprites[i].exo = true
		tt.render.sprites[i].animated = true
		tt.render.sprites[i].offset = def.offset
		tt.render.sprites[i].scale = def.scale
		tt.render.sprites[i].hidden = hidden or false
		return i
	end
	local body_ids = {
		add_exo_sprite(body, false),
		add_exo_sprite(body_a, true),
		add_exo_sprite(body_b, true),
		add_exo_sprite(body_ab, true),
	}
	local weapon_ids = {
		add_exo_sprite(weapon, false),
		add_exo_sprite(weapon_a, true),
		add_exo_sprite(weapon_b, true),
		add_exo_sprite(weapon_ab, true),
	}
	local flag_decal_id = add_exo_sprite({prefix = "d43_aerial_rally_decal", anim = "Idle",
		offset = v(0, 0), scale = v(1.265625, 1.265625)}, false)
	local flag_id = add_exo_sprite({prefix = "d43_aerial_rally", anim = "Idle",
		offset = v(0, 0), scale = v(1.265625, 1.265625)}, false)
	local flag_decal_b_id = add_exo_sprite({prefix = "d43_aerial_rally_decal_skillB", anim = "idle",
		offset = v(0, 0), scale = v(1.265625, 1.265625)}, true)
	local flag_b_id = add_exo_sprite({prefix = "d43_aerial_rally_skillB", anim = "idle",
		offset = v(0, 0), scale = v(1.265625, 1.265625)}, true)
	local slow_fx_id = add_exo_sprite({prefix = "d43_aerial_modify_skillB", anim = "run",
		offset = v(0, 0), scale = v(1.265625, 1.265625)}, true)
	local slow_ring_id = add_exo_sprite({prefix = "d43_aerial_rally_decal_skillB", anim = "idle",
		offset = v(0, 0), scale = v(1.265625, 1.265625)}, true)
	tt.render.sprites[flag_decal_id].z = Z_DECALS
	tt.render.sprites[flag_decal_b_id].z = Z_DECALS
	tt.render.sprites[slow_ring_id].z = Z_DECALS
	tt.render.sprites[flag_id].z = Z_OBJECTS
	tt.render.sprites[flag_b_id].z = Z_OBJECTS
	tt.render.sprites[slow_fx_id].z = Z_EFFECTS
	tt.render.sprites[flag_decal_b_id].exo_hide_prefix = {"d43_blastin_bullriders_asst_aerial_area_circles_skillB", "d43_blastin_bullriders_asst_aerial_area_glow_skillB"}
	tt.render.sprites[slow_ring_id].exo_hide_prefix = {"d43_blastin_bullriders_asst_aerial03_ground_skillB"}
	tt.render.sprites[slow_fx_id].alpha = 140
	tt.render.sprites[flag_b_id].alpha = 195
	tt.render.sprites[flag_decal_b_id].alpha = 225
	tt.render.sprites[slow_ring_id].alpha = 225
	tt.bullriders_body_ids = body_ids
	tt.bullriders_weapon_ids = weapon_ids
	tt.bullriders_flag_id = flag_id
	tt.bullriders_flag_decal_id = flag_decal_id
	tt.bullriders_flag_b_id = flag_b_id
	tt.bullriders_flag_decal_b_id = flag_decal_b_id
	tt.bullriders_slow_fx_id = slow_fx_id
	tt.bullriders_slow_ring_id = slow_ring_id
	tt.attacks.list[1] = CC("custom_attack")
	tt.attacks.list[1].bullet = "bomb_bullriders_basic"
	tt.attacks.list[1].cooldown = cfg.attack_cooldown
	tt.attacks.list[1].vis_flags = bor(F_RANGED)
	tt.attacks.list[1].vis_bans = 0
	tt.powers.precision = CC("power")
	tt.powers.precision.price_base = 160
	tt.powers.precision.price_inc = 120
	tt.powers.precision.max_level = 3
	tt.powers.precision.cooldown_lv = cfg.precision_cooldown
	tt.powers.precision.cooldown_tech_factor = 1
	tt.powers.precision.damage_min_lv = cfg.precision_damage_min
	tt.powers.precision.damage_max_lv = cfg.precision_damage_max
	tt.powers.precision.damage_tech_factor = 1
	tt.powers.precision.radius = cfg.precision_radius
	tt.powers.double_trouble = CC("power")
	tt.powers.double_trouble.price_base = 120
	tt.powers.double_trouble.price_inc = 0
	tt.powers.double_trouble.max_level = 1
	tt.powers.double_trouble.range = cfg.drone_range
	tt.powers.double_trouble.cooldown = cfg.drone_cooldown
	tt.powers.double_trouble.damage_min = cfg.drone_damage_min
	tt.powers.double_trouble.damage_max = cfg.drone_damage_max
	tt.powers.buying_time = CC("power")
	tt.powers.buying_time.price_base = 160
	tt.powers.buying_time.price_inc = 120
	tt.powers.buying_time.max_level = 2
	tt.powers.buying_time.radius = cfg.slow_radius
	tt.powers.buying_time.slow_factor = cfg.slow_factor

	tt = E:register_t("bomb_bullriders_basic", "bomb")
	tt.main_script.update = scripts.bomb_bullriders_basic.update
	tt.bullet.flight_time = fts(18)
	tt.bullet.align_with_trajectory = true
	tt.bullet.damage_min = cfg.attack_damage_min
	tt.bullet.damage_max = cfg.attack_damage_max
	tt.bullet.damage_radius = cfg.attack_radius
	tt.bullet.damage_type = DAMAGE_EXPLOSION
	tt.bullet.damage_flags = F_AREA
	tt.bullet.hit_fx = "fx_bullriders_explosion"
	tt.bullet.hit_decal = "decal_bullriders_crater"
	tt.bullet.pop = {"pop_kboom"}
	tt.bullet.rotation_speed = nil
	tt.render.sprites[1].prefix = "d43_aerial_bull_rocket"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].flip_x = true
	tt.render.sprites[1].scale = v(1, 1)
	tt.sound_events.hit = "d43_blastin_mortar_impact"
	tt.sound_events.hit_water = nil

	tt = E:register_t("bolt_bullriders_precision", "bullet")
	tt.main_script.update = scripts.bolt_bullriders_precision.update
	tt.bullet.damage_min = cfg.precision_damage_min[1]
	tt.bullet.damage_max = cfg.precision_damage_max[1]
	tt.bullet.min_speed = 400
	tt.bullet.max_speed = 400
	tt.bullet.acceleration_factor = 0.05
	tt.bullet.turn_speed = 5
	tt.bullet.retarget_range = 900
	tt.bullet.damage_type = DAMAGE_TRUE
	tt.bullet.damage_radius = cfg.precision_radius
	tt.bullet.damage_flags = F_AREA
	tt.bullet.vis_flags = bor(F_RANGED)
	tt.bullet.vis_bans = 0
	tt.bullet.hit_fx = "fx_bullriders_precision_explosion"
	tt.render.sprites[1].prefix = "d43_aerial_cactus_missil"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].flip_x = true
	tt.render.sprites[1].scale = v(1, 1)
	tt.sound_events.insert = "d43_blastin_missile_launch"
	tt.sound_events.hit = "d43_blastin_deep_explosion"
	tt.sound_events.hit_water = nil

	tt = E:register_t("fx_bullriders_explosion", "fx")
	tt.render.sprites[1].prefix = "d43_aerial_bull_explosion"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -2

	tt = E:register_t("decal_bullriders_crater", "decal_timed")
	tt.timed.duration = 2
	tt.render.sprites[1].prefix = "d43_aerial_bull_decal"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_DECALS

	tt = E:register_t("fx_bullriders_precision_explosion", "fx")
	tt.render.sprites[1].prefix = "d43_aerial_cactus_explosion"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -2

	tt = E:register_t("fx_bullriders_drone_explosion", "fx")
	tt.render.sprites[1].prefix = "d43_aerial_drone_explosion_skillA"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -2

	tt = E:register_t("drone_bullriders", "fx")
	E:add_comps(tt, "main_script")
	tt.timed = nil
	tt.render.sprites[1] = CC("sprite")
	tt.render.sprites[1].prefix = "d43_aerial_drone_skillA"
	tt.render.sprites[1].name = "idle"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].loop = true
	tt.render.sprites[1].scale = v(1.265625, 1.265625)
	tt.render.sprites[1].z = Z_OBJECTS
	tt.render.sprites[1].sort_y_offset = -100
	tt.render.sprites[2] = CC("sprite")
	tt.render.sprites[2].prefix = "d43_aerial_drone_shadow_skillA"
	tt.render.sprites[2].name = "run"
	tt.render.sprites[2].exo = true
	tt.render.sprites[2].animated = true
	tt.render.sprites[2].scale = v(1.265625, 1.265625)
	tt.render.sprites[2].z = Z_DECALS
	tt.main_script.insert = scripts.drone_bullriders.insert
	tt.main_script.update = scripts.drone_bullriders.update

	tt = E:register_t("bullet_bullriders_drone", "shotgun_musketeer")
	tt.bullet.damage_min = cfg.drone_damage_min
	tt.bullet.damage_max = cfg.drone_damage_max
	tt.bullet.damage_type = DAMAGE_PHYSICAL
	tt.bullet.reduce_armor = 0.3
	tt.bullet.min_speed = 20 * FPS
	tt.bullet.max_speed = 20 * FPS
	tt.bullet.vis_flags = bor(F_RANGED)
	tt.bullet.vis_bans = 0
	tt.bullet.hit_fx = "fx_bullriders_drone_explosion"
	tt.bullet.hit_blood_fx = nil
	tt.bullet.start_fx = nil
	tt.bullet.miss_fx = nil
	tt.render.sprites[1].hidden = true
	tt.sound_events.insert = nil
	tt.sound_events.hit = nil

	tt = E:register_t("flag_bullriders_marker", "soldier")
	tt.info.fn = scripts.flag_bullriders_marker.get_info
	tt.info.portrait = "d43_blastin_bullriders_blastin_bullriders_portrait"
	tt.info.i18n_key = "TOWER_BLASTIN_BULLRIDERS"
	tt.health.hp_max = 1
	tt.health.ignore_damage = true
	tt.health_bar.hidden = true
	tt.vis.bans = F_ALL
	tt.ui.click_rect = r(-18, -18, 36, 36)
	tt.ui.can_click = true
	tt.ui.can_select = true
	tt.motion.max_speed = 0
	tt.render.sprites[1].name = "square_ffffff"
	tt.render.sprites[1].animated = false
	tt.render.sprites[1].hidden = true
	tt.main_script.insert = scripts.flag_bullriders_marker.insert
	tt.main_script.update = scripts.flag_bullriders_marker.update

	tt = E:register_t("fx_bullriders_launch_rocket", "fx")
	E:add_comps(tt, "main_script")
	tt.timed = nil
	tt.render.sprites[1].prefix = "d43_aerial_bull_rocket"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].animated = true
	tt.render.sprites[1].flip_x = true
	tt.render.sprites[1].loop = true
	tt.render.sprites[1].scale = v(1.265625, 1.265625)
	tt.render.sprites[1].z = Z_BULLETS
	tt.main_script.insert = scripts.fx_bullriders_launch_rocket.insert
	tt.main_script.update = scripts.fx_bullriders_launch_rocket.update

	tt = E:register_t("mod_bullriders_slow_1", "mod_slow")
	tt.slow.factor = cfg.slow_factor[1]
	tt.modifier.duration = 0.4
	tt.modifier.resets_same = true

	tt = E:register_t("mod_bullriders_slow_2", "mod_slow")
	tt.slow.factor = cfg.slow_factor[2]
	tt.modifier.duration = 0.4
	tt.modifier.resets_same = true

	tt = E:register_t("aura_bullriders_slow", "aura")
	E:add_comps(tt, "main_script")
	tt.aura.mod = "mod_bullriders_slow_1"
	tt.aura.duration = 1e+99
	tt.aura.cycle_time = 0.06
	tt.aura.radius = cfg.slow_radius
	tt.aura.vis_flags = bor(F_MOD)
	tt.aura.vis_bans = bor(F_FRIEND, F_FLYING)
	tt.main_script.insert = scripts.aura_apply_mod.insert
	tt.main_script.update = scripts.aura_apply_mod.update
tt = E:get_template("tower_blastin_bullriders")
tt.tower.level = 4
tt.tower.kind = TOWER_KIND_ENGINEER
tt.tower.cooldown_factor = 1
tt.info.i18n_key = "TOWER_BLASTIN_BULLRIDERS"
tt.info.enc_icon = 677
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[1].z = Z_TOWER_BASES
end

do
local cfg = {["attack_range"]=150,["mind_control_cooldown"]=5,["mind_control_duration"]=10,["mind_control_max_units"]=2,["mind_control_drain_pct"]=0.02,["tantrum_cooldown"]={20,18,16},["tantrum_stun"]={4,5,6},["tantrum_max_targets"]=5,["tantrum_min_count"]=2,["bigbrain_range"]=155,["bigbrain_cooldown"]={4,3,2.5},["bigbrain_damage_min"]=54,["bigbrain_damage_min_inc"]=23,["bigbrain_damage_max"]=66,["bigbrain_damage_max_inc"]=28,["projection_cooldown"]={12,10,8},["projection_radius"]=55,["projection_damage_min"]=40,["projection_damage_min_inc"]=20,["projection_damage_max"]=60,["projection_damage_max_inc"]=30}
	tt = E:register_t("tower_wifi_babies", "tower_mage_1")
	E:add_comps(tt, "powers")
	tt.info.portrait = "d43_wifi_babies_wifi_babies_portrait"
	tt.info.enc_icon = 3
	tt.info.fn = scripts.tower_wifi_babies.get_info
	tt.tower.type = "wifi_babies"
	tt.tower.price = 260
	tt.tower.size = TOWER_SIZE_LARGE
	tt.attacks.range = cfg.attack_range
	tt.attacks.list[1] = E:clone_c("bullet_attack")
	tt.attacks.list[1].animation = "skillbasic"
	tt.attacks.list[1].cooldown = 6
	tt.attacks.list[1].shoot_time = fts(8)
	tt.attacks.list[1].bullet = "bullet_wifi_babies_ray"
	tt.attacks.list[1].bullet_start_offset = v(1, 88)
	tt.attacks.list[1].vis_flags = bor(F_RANGED, F_DISINTEGRATED)
	tt.attacks.list[1].vis_bans = 0
	tt.mind_control = {}
	tt.mind_control.cooldown = cfg.mind_control_cooldown
	tt.mind_control.vis_flags = bor(F_RANGED)
	tt.mind_control.vis_bans = 0
	tt.mind_control.bullet = "bolt_wifi_babies_mind"
	tt.mind_control.bullet_start_offset = v(0, 60)
	tt.powers.tantrum = E:clone_c("power")
	tt.powers.tantrum.max_level = 2
	tt.powers.tantrum.price_base = 160
	tt.powers.tantrum.price_inc = 160
	tt.powers.tantrum.cooldown = cfg.tantrum_cooldown[1]
	tt.powers.tantrum.vis_flags = bor(F_RANGED)
	tt.powers.tantrum.vis_bans = 0
	tt.powers.big_brain = E:clone_c("power")
	tt.powers.big_brain.max_level = 3
	tt.powers.big_brain.price_base = 100
	tt.powers.big_brain.price_inc = 60
	tt.powers.projection = E:clone_c("power")
	tt.powers.projection.max_level = 3
	tt.powers.projection.price_base = 170
	tt.powers.projection.price_inc = 140
	tt.powers.projection.cooldown = cfg.projection_cooldown[1]
	tt.powers.projection.vis_flags = bor(F_RANGED)
	tt.powers.projection.vis_bans = 0
	tt.powers.tantrum.range = cfg.attack_range
	tt.powers.tantrum.max_targets = cfg.tantrum_max_targets
	tt.powers.tantrum.min_count = cfg.tantrum_min_count
	tt.powers.tantrum.cooldown_lv = {cfg.tantrum_cooldown[2], cfg.tantrum_cooldown[3]}
	tt.powers.tantrum.stun_lv = {cfg.tantrum_stun[2], cfg.tantrum_stun[3]}
	tt.powers.big_brain.cooldown_lv = cfg.bigbrain_cooldown
	tt.powers.big_brain.damage_min_lv = {54, 77, 100}
	tt.powers.big_brain.damage_max_lv = {66, 94, 122}
	tt.powers.projection.radius = cfg.projection_radius
	tt.powers.projection.cooldown_lv = cfg.projection_cooldown
	tt.powers.projection.damage_min_lv = {40, 60, 80}
	tt.powers.projection.damage_max_lv = {60, 90, 120}
	tt.render.sprites[2].prefix = "d43_wifi_babies"
	tt.render.sprites[2].name = "idle"
	tt.render.sprites[2].animated = true
	tt.render.sprites[2].exo = true
	tt.render.sprites[2].offset = v(0, 3)
	tt.render.sprites[2].scale = v(1.265625, 1.265625)
	tt.render.sprites[3].hidden = true
	tt.render.sprites[4].hidden = true
	tt.render.sid_tower = 2
	tt.sound_events.insert = "d43_wifi_babies_taunt_1"
	tt.main_script.update = scripts.tower_wifi_babies.update

	tt = E:register_t("bolt_wifi_babies_mind", "bolt")
	E:add_comps(tt, "tween")
	tt.main_script.insert = nil
	tt.main_script.update = kr45_scripts.initial_bolt.update
	tt.render.sprites[1].prefix = "d43_wifi_babies_part"
	tt.render.sprites[1].name = "flying"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].anchor = v(0.5, 0.5)
	tt.render.sprites[1].z = Z_OBJECTS + 1
	tt.render.sprites[1].scale = v(1.265625, 1.265625)
	tt.tween.remove = false
	tt.tween.props[1].keys = {{0, 0}, {0.2, 255}}
	tt.bullet.damage_type = 0
	tt.bullet.acceleration_factor = 0.01
	tt.bullet.min_speed = 100
	tt.bullet.max_speed = 200
	tt.bullet.max_track_distance = REF_H / 2
	tt.bullet.flip_x = true
	tt.bullet.pop = nil
	tt.bullet.pop_conds = nil
	tt.bullet.mod = "mod_wifi_babies_mind"
	tt.bullet.hit_fx = nil
	tt.sound_events.insert = nil

	tt = E:register_t("mod_wifi_babies_mind", "modifier")
	E:add_comps(tt, "render")
	tt.possession_duration = {10}
	tt.possession_animations = {"mind control", "mind control", "mind control"}
	tt.modifier.duration = 10
	tt.modifier.use_mod_offset = nil
	tt.main_script.insert = kr45_scripts.mod_possession_skill.insert
	tt.main_script.update = kr45_scripts.mod_possession_skill.update
	tt.main_script.remove = kr45_scripts.mod_possession_skill.remove
	tt.render.sprites[1].prefix = "d43_wifi_babies_mind_control"
	tt.render.sprites[1].name = "mind control"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].anchor = v(0.5, 0.14)
	tt.render.sprites[1].draw_order = DO_MOD_FX
	tt.render.sprites[1].size_scales = {vv(1, 1), vv(1.3, 1.3), vv(1.8, 1.8)}

	tt = E:register_t("bullet_wifi_babies_ray", "bullet")
	tt.main_script.update = kr5_scripts.ray5_simple.update
	tt.bullet.damage_type = bor(DAMAGE_MAGICAL, DAMAGE_DISINTEGRATE, DAMAGE_IGNORE_SHIELD)
	tt.bullet.damage_min = cfg.bigbrain_damage_min
	tt.bullet.damage_max = cfg.bigbrain_damage_max
	tt.bullet.damage_min_inc = cfg.bigbrain_damage_min_inc
	tt.bullet.damage_max_inc = cfg.bigbrain_damage_max_inc
	tt.bullet.hit_time = fts(4)
	tt.bullet.max_track_distance = REF_H / 6
	tt.bullet.hit_fx = nil
	tt.bullet.out_fx = nil
	tt.bullet.pop = nil
	tt.bullet.pop_conds = nil
	tt.hit_fx_only_no_target = false
	tt.track_target = true
	tt.image_width = 133.5
	tt.ray_duration = fts(18)
	tt.render.sprites[1].prefix = "d43_wifi_ray"
	tt.render.sprites[1].name = "flying"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].anchor = v(0.5, 0.5)
	tt.render.sprites[1].scale = v(1.265625, 1.265625)
	tt.render.sprites[1].z = Z_EFFECTS
	tt.render.sprites[1].loop = true
	tt.sound_events.insert = "d43_wifi_babies_laser"

	tt = E:register_t("mod_wifi_babies_stun", "mod_stun")
	tt.modifier.vis_flags = bor(F_MOD, F_STUN)
	tt.render.sprites[1].prefix = "d43_wifi_babies_nuclear_stun"
	tt.render.sprites[1].name = "loop"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].size_names = nil
	tt.render.sprites[1].loop = true

	tt = E:register_t("fx_wifi_babies_stun_hit", "fx")
	tt.render.sprites[1].prefix = "d43_wifi_babies_explosion"
	tt.render.sprites[1].name = "explosion"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_EFFECTS

	tt = E:register_t("fx_wifi_babies_pulse", "fx")
	tt.render.sprites[1].prefix = "d43_wifi_babies_pulse"
	tt.render.sprites[1].name = "ripple"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS

	tt = E:register_t("fx_wifi_babies_projection_decal", "fx")
	tt.render.sprites[1].prefix = "d43_wifi_babies_floatingbabies_decal"
	tt.render.sprites[1].name = "run"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].z = Z_DECALS

	tt = E:register_t("bolt_wifi_babies_projection", "bullet")
	tt.main_script.update = scripts.bolt_wifi_babies_projection.update
	tt.render.sprites[1].prefix = "d43_wifi_babies_floatingbabies"
	tt.render.sprites[1].name = "hit"
	tt.render.sprites[1].exo = true
	tt.render.sprites[1].anchor = v(0.5, 0.5)
	tt.render.sprites[1].z = Z_EFFECTS
	tt.bullet.damage_min = cfg.projection_damage_min
	tt.bullet.damage_max = cfg.projection_damage_max
	tt.bullet.damage_min_inc = cfg.projection_damage_min_inc
	tt.bullet.damage_max_inc = cfg.projection_damage_max_inc
	tt.bullet.damage_type = DAMAGE_MAGICAL
	tt.bullet.damage_inc = 0
	tt.bullet.damage_radius = cfg.projection_radius
	tt.bullet.damage_radius_inc = 0
	tt.bullet.damage_flags = F_AREA
	tt.render.sprites[1].loop = false
tt = E:get_template("tower_wifi_babies")
tt.tower.level = 4
tt.tower.kind = TOWER_KIND_MAGE
tt.tower.cooldown_factor = 1
tt.info.i18n_key = "TOWER_WIFI_BABIES"
tt.info.enc_icon = 678
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[1].z = Z_TOWER_BASES
end
end
-- END DOVE43 EXTRA TOWERS
