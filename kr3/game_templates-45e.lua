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
local scripts = require("game_scripts-5")
local base_scripts = require("custom_scripts_0")
local kr1_scripts = require("game_scripts-1")
local scripts_rebbborn = require("game_scripts-1-rebbborn")
local kr4_scripts = require("game_scripts-45e")
local zeta_unit_metadata = require("data.zeta_unit_metadata")

require("templates")

local H = require("helpers")
local U = require("utils_pld")
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

local function kr4_add_enemy_shadow(t, name, anchor_y_value, offset_y)
	t.render.sprites[2] = E:clone_c("sprite")
	t.render.sprites[2].is_shadow = true
	t.render.sprites[2].animated = false
	t.render.sprites[2].name = name
	t.render.sprites[2].anchor = v(0.5, anchor_y_value or 0.2)
	t.render.sprites[2].offset = v(0, offset_y or 0)
	t.render.sprites[2].z = Z_DECALS + 1
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


--本文件：使用5代底层代码实现4代关卡
--4-0
tt = E:register_t("fade_loop", "fx")
tt.render.sprites[1].name = "fade_loop"

-------------------------------------------------------
------------------------矮人主线------------------------
-------------------------------------------------------

tt = E:register_t("enemy_human_woodcutter", "enemy_KR5")
E:add_comps(tt, "melee")
tt.enemy.gold = 5
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = 30
tt.health.armor = 0
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 32)
tt.info.i18n_key = "ENEMY_HUMAN_WOODCUTTER"
tt.info.enc_icon = 1
tt.info.enc_icon_offset = 300
tt.info.portrait = "gui4_bottom_info_image_enemies_0001"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 5)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 3
tt.melee.attacks[1].damage_min = 1
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 40
tt.render.sprites[1].prefix = "human_woodcutter"
tt.render.sprites[1].offset.y = 15
kr4_add_enemy_shadow(tt, "human_woodcutter_shadow")
tt.sound_events.death = "EnemyDarksteelHammererDeath"
tt.ui.click_rect = r(-17, 0, 34, 30)

tt = E:register_t("enemy_human_worker", "enemy_KR5")
E:add_comps(tt, "melee")
tt.enemy.gold = 5
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = 50
tt.health.armor = 0
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 32)
tt.info.i18n_key = "ENEMY_HUMAN_WORKER"
tt.info.enc_icon = 2
tt.info.enc_icon_offset = 300
tt.info.portrait = "gui4_bottom_info_image_enemies_0002"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 5)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 6
tt.melee.attacks[1].damage_min = 4
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 40
tt.render.sprites[1].prefix = "human_worker"
tt.render.sprites[1].offset.y = 15
kr4_add_enemy_shadow(tt, "human_worker_shadow")
tt.sound_events.death = "EnemyDarksteelHammererDeath"
tt.ui.click_rect = r(-17, 0, 34, 30)

tt = E:register_t("enemy_bruiser", "enemy_KR5")
E:add_comps(tt, "melee")
tt.enemy.gold = 3
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = 30
tt.health.armor = 0
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 32)
tt.info.i18n_key = "ENEMY_BRUISER"
tt.info.enc_icon = 3
tt.info.enc_icon_offset = 300
tt.info.portrait = "gui4_bottom_info_image_enemies_0003"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 5)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 4
tt.melee.attacks[1].damage_min = 2
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 30
tt.render.sprites[1].prefix = "bruiser"
tt.render.sprites[1].offset.y = 15
kr4_add_enemy_shadow(tt, "bruiser_shadow")
tt.sound_events.death = "EnemyDarksteelHammererDeath"
tt.ui.click_rect = r(-17, 0, 34, 30)


tt = E:register_t("enemy_warhammer_guard", "enemy_KR5")
E:add_comps(tt, "melee")
tt.enemy.gold = 8
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = 70
tt.health.armor = 0.2
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 32)
tt.info.i18n_key = "ENEMY_WARHAMMER_GUARD"
tt.info.enc_icon = 4
tt.info.enc_icon_offset = 300
tt.info.portrait = "gui4_bottom_info_image_enemies_0004"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 5)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 7
tt.melee.attacks[1].damage_min = 5
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 40
tt.render.sprites[1].prefix = "warhammer_guard"
tt.render.sprites[1].offset.y = 10
kr4_add_enemy_shadow(tt, "warhammer_guard_shadow")
tt.sound_events.death = "EnemyDarksteelHammererDeath"
tt.ui.click_rect = r(-17, 0, 34, 30)

tt = E:register_t("enemy_clockwork_spider", "enemy_KR5")
E:add_comps(tt, "melee")
tt.enemy.gold = 3
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = 40
tt.health.dead_lifetime = 9
tt.health.armor = 0
tt.health.magic_armor = 0
tt.health.on_damage = kr4_scripts.branch_enemy.on_repairable_damage
tt.repairable_death = {
	dead_lifetime = 9,
	disabled_animation = "death",
	destroyed_animation = "death",
	destroyed_lifetime = 2,
	no_repair_damage_types = bor(DAMAGE_EXPLOSION, DAMAGE_FX_EXPLODE, DAMAGE_DISINTEGRATE, DAMAGE_DISINTEGRATE_BOSS, DAMAGE_EAT, DAMAGE_NO_SPAWNS)
}
tt.health_bar.offset = v(0, 32)
tt.info.i18n_key = "ENEMY_CLOCKWORK_SPIDER"
tt.info.enc_icon = 8
tt.info.portrait = "gui4_bottom_info_image_enemies_0008"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 5)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt.unit.blood_color = BLOOD_NONE
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 3
tt.melee.attacks[1].damage_min = 2
tt.melee.attacks[1].hit_time = fts(8)
tt.motion.max_speed = 90
tt.render.sprites[1].prefix = "clockwork_spider"
tt.render.sprites[1].offset.y = 15
kr4_add_enemy_shadow(tt, "clockwork_spider_shadow")
tt.sound_events.death = "dwarves_mechadwarf_death"
tt.ui.click_rect = r(-17, 0, 34, 30)


tt = E:register_t("enemy_chomp_bot", "enemy_KR5")
E:add_comps(tt, "melee")
tt.enemy.gold = 15
tt.enemy.melee_slot = v(28, 0)
tt.health.hp_max = 120
tt.health.dead_lifetime = 9
tt.health.armor = 0.2
tt.health.magic_armor = 0
tt.health.on_damage = kr4_scripts.branch_enemy.on_repairable_damage
tt.repairable_death = {
	dead_lifetime = 9,
	disabled_animation = "overheatStart",
	destroyed_animation = "death",
	destroyed_lifetime = 2,
	no_repair_damage_types = bor(DAMAGE_EXPLOSION, DAMAGE_FX_EXPLODE, DAMAGE_DISINTEGRATE, DAMAGE_DISINTEGRATE_BOSS, DAMAGE_EAT, DAMAGE_NO_SPAWNS)
}
tt.health_bar.offset = v(0, 32)
tt.info.i18n_key = "ENEMY_CHOMP_BOT"
tt.info.enc_icon = 5
tt.info.portrait = "gui4_bottom_info_image_enemies_0005"
tt.unit.hit_offset = v(0, 14)
tt.unit.head_offset = v(0, 5)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 10)
tt.unit.blood_color = BLOOD_NONE
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_mixed.update
tt.melee.attacks[1].cooldown = 1.2
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].hit_time = 0.13
tt.melee.attacks[1].hit_times = {0.13, 0.33, 0.53}
tt.motion.max_speed = 39
tt.render.sprites[1].prefix = "chompbot"
tt.render.sprites[1].offset.y = 15
kr4_add_enemy_shadow(tt, "chompbot_shadow")
tt.sound_events.death = "dwarves_mechadwarf_death"
tt.ui.click_rect = r(-17, 0, 34, 30)

---------------------------------------------------------
------------------------阿努瑞支线------------------------
---------------------------------------------------------
--阿努瑞追猎者
tt = RT("enemy_chaser", "enemy")
AC(tt, "melee", "timed_attacks")
tt.enemy.gold = 16
tt.enemy.lives_cost = 1
tt.enemy.melee_slot = v(20, 0)
tt.health.armor = 0.5
tt.health.hp_max = 180
tt.health_bar.offset = v(0, 25)
tt.info.i18n_key = "ENEMY_ANURIAN_CHASER"
tt.info.portrait = "gui4_bottom_info_image_enemies_0061"
tt.info.enc_icon = 58
tt.motion.max_speed = 26
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].damage_min = 16
tt.melee.attacks[1].hit_time = fts(18)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].animation = "melee"
tt.melee.attacks[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.timed_attacks.list[1] = E:clone_c("jump_attack")
tt.timed_attacks.list[1].skill = "jump_target"
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].damage_max = 60
tt.timed_attacks.list[1].damage_min = 60
tt.timed_attacks.list[1].max_range = 260
tt.timed_attacks.list[1].min_range = 30
tt.timed_attacks.list[1].is_area_damage = true
tt.timed_attacks.list[1].damage_radius = 60
tt.timed_attacks.list[1].flight_time = fts(18)
tt.timed_attacks.list[1].min_targets = 2
tt.timed_attacks.list[1].node_limit = 80
tt.timed_attacks.list[1].search_type = U.search_type.nearest
tt.timed_attacks.list[1].search_stream = U.search_stream.only_upstream
tt.timed_attacks.list[1].need_back = false
tt.timed_attacks.list[1].backed_attack = true
tt.timed_attacks.list[1].loops = 1
tt.timed_attacks.list[1].animations = {
	"jumpIn",
	"loop",
	"jumpOut"
}
tt.timed_attacks.list[1].sounds = {
	nil,
	nil,
	"frog_chaser_jump"
}
tt.timed_attacks.list[1].hit_fx = {
	"chaser_jump_hit_fx",
	"chaser_jump_effect"
}
tt.timed_attacks.list[1].hit_decal = "chaser_decal"
tt.timed_attacks.list[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.render.sprites[1].anchor = v(0.5, 0.132)
tt.render.sprites[1].offset = v(0, 0)
tt.render.sprites[1].prefix = "chaser"
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[1].animated = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "chaser_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.137)
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = v(0, 18)
tt.unit.mod_offset = v(0, 15)
tt.unit.head_offset = v(0, 40)
tt.ui.click_rect = r(-30, -8, 45, 30)
tt.vis.flags = bor(F_ENEMY)
tt.main_script.update = base_scripts.kr4_enemy_mixed.update

tt = RT("chaser_jump_hit_fx", "fx")
tt.render.sprites[1].prefix = "chaser_jump_hit_fx"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.475)

tt = RT("chaser_decal", "decal_tween")
tt.render.sprites[1].name = "chaser_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.tween.props[1].keys = {
	{
		1,
		255
	},
	{
		2.5,
		0
	}
}

tt = RT("chaser_jump_effect", "decal_tween")
tt.render.sprites[1].name = "chaser_jump_effect"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.tween.props[1].name = "scale"
tt.tween.props[1].keys = {
	{
		0,
		vv(0.35)
	},
	{
		0.23,
		vv(1)
	}
}

--阿努瑞看守者
--buff名：shield_in
tt = RT("enemy_warden", "enemy")
AC(tt, "melee", "timed_attacks")
tt.enemy.gold = 55
tt.enemy.lives_cost = 1
tt.enemy.melee_slot = v(25, 0)
tt.health.armor = 0.8
tt.health.hp_max = 600
tt.health_bar.offset = v(0, 40)
tt.info.enc_icon = 59
tt.info.i18n_key = "ENEMY_ANURIAN_WARDEN"
tt.info.portrait = "gui4_bottom_info_image_enemies_0064"
tt.motion.max_speed = 25
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].hit_time = fts(13)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].animation = "hit"
tt.melee.attacks[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.render.sprites[1].anchor = v(0.5, 0.15)
tt.render.sprites[1].prefix = "warden"
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[1].animated = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "warden_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.174)
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].z = Z_DECALS + 1
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = v(0, 20)
tt.unit.mod_offset = v(0, 20)
tt.unit.head_offset = v(0, 40)
tt.ui.click_rect = r(-23, 3, 45, 40)
tt.vis.flags = bor(F_ENEMY)
tt.main_script.update = base_scripts.kr4_enemy_mixed.update

--水晶异蛇龙
tt = RT("enemy_amphiptere", "enemy")
tt.enemy.gold = 7
tt.health.hp_max = 70
tt.health_bar.offset = v(0, 70)
tt.info.enc_icon = 60
tt.info.i18n_key = "ENEMY_CRYSTAL_AMPHIPTERE"
tt.info.portrait = "gui4_bottom_info_image_enemies_0063"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = scripts.enemy_passive.update
tt.motion.max_speed = 60
tt.render.sprites[1].prefix = "amphiptere"
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[1].offset = v(0, 38)
tt.render.sprites[1].anchor = v(0.5, 0.264)
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "amphiptere_shadow"
tt.render.sprites[2].offset = v(0, 0)
tt.render.sprites[2].anchor = v(0.5, 0.044)
tt.ui.click_rect = r(-18, 23, 28, 27)
tt.unit.can_explode = false
tt.unit.can_disintegrate = true
tt.unit.disintegrate_fx = "fx_enemy_desintegrate_air"
tt.unit.hit_offset = v(-3, 36)
tt.unit.mod_offset = v(-3, 50)
tt.unit.hide_after_death = true
tt.unit.show_blood_pool = false
tt.unit.blood_color = BLOOD_GREEN
tt.vis.bans = bor(F_BLOCK, F_THORN, F_SKELETON)
tt.vis.flags = bor(F_ENEMY, F_FLYING)

--水晶毁灭者
tt = RT("enemy_bullywags_golem", "enemy")

AC(tt, "melee", "death")

tt.enemy.gold = 80
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(30, 0)
tt.health.armor = 0
tt.health.hp_max = 1400
tt.health_bar.offset = v(0, 60)
tt.info.enc_icon = 64
tt.info.i18n_key = "ENEMY_CRYSTAL_DEMOLISHER"
tt.info.portrait = "gui4_bottom_info_image_enemies_0067"
tt.motion.max_speed = 16
tt.melee.attacks[1].cooldown = 2.5
tt.melee.attacks[1].damage_max = 240
tt.melee.attacks[1].damage_min = 130
tt.melee.attacks[1].hit_time = fts(20)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.render.sprites[1].anchor = v(0.523, 0.213)
tt.render.sprites[1].prefix = "bullywags_golem"
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[1].animated = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "bullywags_golem_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.219)
tt.render.sprites[2].z = Z_DECALS + 1
tt.unit.blood_color = BLOOD_RED
tt.unit.hit_offset = v(0, 10)
tt.unit.mod_offset = v(0, 25)
tt.unit.head_offset = v(0, 40)
tt.ui.click_rect = r(-12, 12, 53, 65)
tt.vis.flags = bor(F_ENEMY)
tt.main_script.update = base_scripts.kr4_enemy_mixed.update
tt.death.death_fn = kr4_scripts.enemy_crystal_demolisher.death_fn
tt.death.damage = 300
tt.death.damage_type = DAMAGE_PHYSICAL
tt.death.min_range = 0
tt.death.max_range = 60
tt.death.count = 5
tt.death.vis_flags = 0
tt.death.vis_bans = 0

--阿努瑞注魔师
tt = RT("enemy_infuser", "enemy")
AC(tt, "melee", "ranged", "timed_attacks")
tt.enemy.gold = 30
tt.enemy.lives_cost = 1
tt.enemy.melee_slot = v(28, 0)
tt.health.armor = 0
tt.health.magic_armor = 0.6
tt.health.hp_max = 250
tt.health_bar.offset = v(0, 30)
tt.info.enc_icon = 61
tt.info.i18n_key = "ENEMY_ANURIAN_INFUSER"
tt.info.portrait = "gui4_bottom_info_image_enemies_0062"
tt.motion.max_speed = 25
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 15
tt.melee.attacks[1].damage_min = 11
tt.melee.attacks[1].hit_time = fts(10)
tt.melee.attacks[1].basic_attack = true
tt.melee.attacks[1].animation = "melee"
tt.melee.attacks[1].vis_bans = bor(F_ENEMY, F_FLYING)
tt.ranged.attacks[1].bullet = "enemy_infuser_bolt"
tt.ranged.attacks[1].bullet_start_offset = {
	v(-5, 38.5),
	v(5, 38.5)
}
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].shoot_time = fts(9)
tt.timed_attacks.list[1] = E:clone_c("bullet_attack")
tt.timed_attacks.list[1].skill = "range_unit"
tt.timed_attacks.list[1].skill_id = 1
tt.timed_attacks.list[1].extra_cooldowns = { { 2, 5 },{ 3, 10 } }
tt.timed_attacks.list[1].cooldown = 5
tt.timed_attacks.list[1].bullet_start_offset = {
	v(-13, 42.5),
	v(13, 42.5)
}
tt.timed_attacks.list[1].max_range = 150
tt.timed_attacks.list[1].min_range = 25
tt.timed_attacks.list[1].cast_time = fts(9)
tt.timed_attacks.list[1].hold_advance = true
tt.timed_attacks.list[1].ignore_hit_offset = true
tt.timed_attacks.list[1].animation = "cast"
tt.timed_attacks.list[1].vis_bans = bor(F_FRIEND)
tt.timed_attacks.list[1].can_be_silenced = true
tt.timed_attacks.list[1].bullet = "infuser_cast_ray_shield"
tt.timed_attacks.list[1].allowed_templates = { "enemy_warden" }
tt.timed_attacks.list[1].sound = "frog_infuser_shield-complete"
tt.timed_attacks.list[1].sound_args = {
	delay = fts(8)
}
tt.timed_attacks.list[2] = table.deepclone(tt.timed_attacks.list[1])
tt.timed_attacks.list[2].skill_id = 2
tt.timed_attacks.list[2].disabled = false
tt.timed_attacks.list[2].extra_cooldowns = { { 1, 5 },{3, 10} }
tt.timed_attacks.list[2].bullet = "infuser_cast_ray_speed"
tt.timed_attacks.list[2].allowed_templates = { "enemy_amphiptere" }
tt.timed_attacks.list[2].sound = nil
tt.timed_attacks.list[3] = E:clone_c("custom_attack")
tt.timed_attacks.list[3].skill_id = 3
tt.timed_attacks.list[3].vis_bans = bor(F_ENEMY)
tt.timed_attacks.list[3].disabled = false
tt.timed_attacks.list[3].cast_time = fts(9)
tt.timed_attacks.list[3].bullet_start_offset = {
	v(-13, 42.5),
	v(13, 42.5)
}
tt.timed_attacks.list[3].loop_time = fts(150)
tt.timed_attacks.list[3].cooldown = 10
tt.timed_attacks.list[3].animation_start = "cast"
tt.timed_attacks.list[3].animation_loop = "cast_loop"
tt.timed_attacks.list[3].animation_end = "cast_end"
tt.timed_attacks.list[3].skill = "object_on_crystal"
tt.timed_attacks.list[3].target_id = nil
tt.timed_attacks.list[3].can_be_silenced = true
tt.timed_attacks.list[3].max_range = 150
tt.timed_attacks.list[3].min_range = 25
tt.timed_attacks.list[3].radius = 150
tt.timed_attacks.list[3].extra_cooldowns = { { 1, 5 }, {2,5} }
tt.timed_attacks.list[3].bullet = "infuser_cast_ray_silent"
tt.timed_attacks.list[3].allowed_templates = { "overcharge_crystal" }
tt.timed_attacks.list[3].sound = nil
tt.render.sprites[1].anchor = v(0.5, 0.106)
tt.render.sprites[1].offset = v(0, 3)
tt.render.sprites[1].prefix = "infuser"
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[1].animated = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "chaser_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.127)
tt.render.sprites[2].offset = v(0, 1)
tt.render.sprites[2].z = Z_DECALS + 1
tt.unit.blood_color = BLOOD_GREEN
tt.unit.hit_offset = v(0, 12)
tt.unit.mod_offset = v(0, 12)
tt.unit.head_offset = v(0, 40)
tt.ui.click_rect = r(-18, -3, 32, 36)
tt.vis.flags = bor(F_ENEMY)
tt.main_script.update = base_scripts.kr4_enemy_mixed.update

--阿努瑞通灵师  代码来自2代
tt = E:register_t("enemy_bullywags_channeler", "enemy")
E:add_comps(tt, "melee", "ranged", "auras")
anchor_y = 0.16
image_y = 62
tt.auras.list[1] = E:clone_c("aura_attack")
tt.auras.list[1].name = "channeler_shield_aura"
tt.auras.list[1].cooldown = 0
tt.auras.list[2] = E:clone_c("aura_attack")
tt.auras.list[2].name = "channeler_damage_aura"
tt.auras.list[2].cooldown = 0
tt.enemy.gold = 25
tt.enemy.melee_slot = v(20, 0)
tt.health.armor = 0
tt.health.hp_max = 300
tt.health.magic_armor = 0.6
tt.health_bar.offset = v(0, ady(47))
tt.info.portrait = "gui4_bottom_info_image_enemies_0065"
tt.info.enc_icon = 63
tt.info.i18n_key = "ENEMY_ANURIAN_CHANNELER"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = base_scripts.kr4_enemy_mixed.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 42
tt.melee.attacks[1].damage_min = 28
tt.melee.attacks[1].hit_time = fts(12)
tt.ranged.attacks[1].bullet = "enemy_bullywags_channeler_bolt"
tt.ranged.attacks[1].bullet_start_offset = {
	v(-5, 38.5),
	v(5, 38.5)
}
tt.ranged.attacks[1].cooldown = 1.2
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].max_range = 100
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].shoot_time = fts(9)
tt.motion.max_speed = 1.1 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "bullywags_channeler"
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "chaser_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.127)
tt.render.sprites[2].offset = v(0, -8)
tt.render.sprites[2].z = Z_DECALS + 1
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, ady(10))
tt.unit.mod_offset = v(0, ady(26))
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)

--阿努瑞博学者  代码来自2代
tt = E:register_t("enemy_bullywags_erudite", "enemy")
E:add_comps(tt, "melee", "ranged")
anchor_y = 0.16
image_y = 62
tt.enemy.gold = 60
tt.enemy.melee_slot = v(20, 0)
tt.health.armor = 0
tt.health.hp_max = 500
tt.health.magic_armor = 0.8
tt.health_bar.offset = v(0, ady(47))
tt.info.portrait = "gui4_bottom_info_image_enemies_0066"
tt.info.enc_icon = 62
tt.info.i18n_key = "ENEMY_ANURIAN_ERUDITE"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = base_scripts.kr4_enemy_mixed.update
tt.main_script.remove = kr4_scripts.enemy_bullywags_erudite.remove
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 42
tt.melee.attacks[1].damage_min = 28
tt.melee.attacks[1].hit_time = fts(12)
tt.ranged.attacks[1].bullet = "enemy_bullywags_erudite_bolt"
tt.ranged.attacks[1].bullet_start_offset = {
	v(0, 38.5),
	v(0, 38.5)
}
tt.ranged.attacks[1].cooldown = 2.0
tt.ranged.attacks[1].hold_advance = true
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].max_range = 125
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].max_stored_bullets = 3
tt.ranged.attacks[1].storage_offsets = {
	v(0, 50),
	v(-20, 47),
	v(20, 47)
}
tt.ranged.attacks[1]._stored_bullets = {}
tt.ranged.attacks[1].animation = "ranged"
tt.ranged.attacks[1].shoot_time = fts(9)
tt.motion.max_speed = 1 * FPS
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "bullywags_erudite"
tt.render.sprites[1].angles.walk = {
	"walk",
	"walkUp",
	"walkDown"
}
tt.unit.hit_offset = v(0, 14)
tt.unit.marker_offset = v(0, ady(10))
tt.unit.mod_offset = v(0, ady(26))
tt.sound_events.death = "frog_erudite_death"
tt.vis.flags = bor(tt.vis.flags, F_SPELLCASTER)

--阿努瑞
tt = E:register_t("enemy_boss_anurian", "boss")
E:add_comps(tt, "melee")
anchor_y = 0.16
image_y = 62
tt.enemy.gold = 0
tt.enemy.lives_cost = 20
tt.enemy.melee_slot = v(50, 0)
tt.health.armor = 0
tt.health.hp_max = 7000
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, ady(120))
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.portrait = "gui4_bottom_info_image_enemies_0068"
tt.info.enc_icon = 87
tt.info.i18n_key = "ENEMY_BOSS_POLYX_ENCYC"
tt.main_script.insert = scripts.enemy_basic.insert
tt.main_script.update = kr4_scripts.branch_enemy.update
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_max = 9999
tt.melee.attacks[1].damage_min = 9999
tt.melee.attacks[1].damage_type = DAMAGE_INSTAKILL
tt.melee.attacks[1].animation = "eat"
tt.melee.attacks[1].damage_radius = 50
tt.melee.attacks[1].hit_time = fts(12)
tt.melee.attacks[1].max_count = 99
tt.motion.max_speed = 8
tt.render.sprites[1].anchor.y = anchor_y
tt.render.sprites[1].prefix = "anurian_boss"
tt.render.sprites[1].exo = true
tt.render.sprites[1].angles = {}
tt.render.sprites[1].angles.walk = {"walk", "walk", "walk"}
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].anchor = v(0.5, 0.5)
tt.render.sprites[2].animated = true
tt.render.sprites[2].name = "run"
tt.render.sprites[2].offset = v(0, 17)
tt.render.sprites[2].prefix = "anurian_boss_drops"
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = true
tt.render.sprites[3].name = "run"
tt.render.sprites[3].offset = v(0, 12)
tt.render.sprites[3].prefix = "anurian_boss_crystals"
tt.render.sprites[3].z = Z_OBJECTS + 1
tt.ui.click_rect = r(-60, 0, 120, 120)
tt.unit.blood_color = BLOOD_VIOLET
tt.unit.head_offset = v(0, 110)
tt.unit.hit_offset = v(0, 55)
tt.unit.marker_offset = v(0, ady(10))
tt.unit.mod_offset = v(0, 55)
tt.vis.bans = bor(tt.vis.bans, F_MOD, F_POLYMORPH, F_STUN, F_SLOW)
tt.vis.flags = bor(tt.vis.flags, F_BOSS, F_SPELLCASTER)
tt.branch = {
	boss = true,
	swap_path_data = {
		{path = 2, trigger_node = 92, new_path = 3, new_node = 97, walk_to_path = true},
		{path = 3, trigger_node = 117, new_path = 2, new_node = 122, walk_to_path = true}
	}
}

tt = RT("fx_anurian_boss_teleport", "fx")
tt.render.sprites[1].anchor = v(0.5, 0.15)
tt.render.sprites[1].name = "run"
tt.render.sprites[1].prefix = "anurian_boss_teleport"
tt.render.sprites[1].z = Z_OBJECTS + 2

tt = RT("fx_anurian_boss_teleport_back", "fx")
tt.render.sprites[1].anchor = v(0.5, 0.15)
tt.render.sprites[1].name = "run"
tt.render.sprites[1].prefix = "anurian_boss_teleport_back"
tt.render.sprites[1].z = Z_OBJECTS + 2

tt = RT("anurian_boss_water", "decal_scripted")
tt.main_script.update = kr4_scripts.anurian_boss_water.update
tt.render.sprites[1].anchor = v(0.5, 0.16)
tt.render.sprites[1].animated = true
tt.render.sprites[1].name = "walk"
tt.render.sprites[1].prefix = "anurian_boss"
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].anchor = v(0.5, 0.5)
tt.render.sprites[2].animated = true
tt.render.sprites[2].name = "run"
tt.render.sprites[2].offset = v(0, 17)
tt.render.sprites[2].prefix = "anurian_boss_drops"
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = true
tt.render.sprites[3].name = "run"
tt.render.sprites[3].offset = v(0, 12)
tt.render.sprites[3].prefix = "anurian_boss_crystals"
tt.render.sprites[3].z = Z_OBJECTS + 1

tt = RT("stage169_anurian_water_fx", "decal_scripted")
tt.render.sprites[1].anchor = v(0.5, 0)
tt.render.sprites[1].animated = true
tt.render.sprites[1].name = "run"
tt.render.sprites[1].prefix = "anurian_boss_water"
tt.render.sprites[1].scale = v(0.8, 0.8)
tt.render.sprites[1].z = Z_OBJECTS + 1

tt = RT("stage169_mask_2", "decal_scripted")
tt.render.sprites[1].anchor = v(0.5, 0)
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage_19_mask_2"
tt.render.sprites[1].z = Z_OBJECTS + 2

tt = RT("enemy_infuser_bolt", "bolt")
tt.render.sprites[1].prefix = "infuser_bolt"
tt.bullet.damage_min = 22
tt.bullet.damage_max = 30
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.hit_fx = "enemy_infuser_bolt_hit_fx"

tt = RT("enemy_infuser_bolt_hit_fx", "fx")
tt.render.sprites[1].prefix = "infuser_bolt"
tt.render.sprites[1].name = "hit"

tt = RT("enemy_bullywags_channeler_bolt", "bolt")
tt.render.sprites[1].prefix = "bullywags_channeler_bolt"
tt.bullet.damage_min = 25
tt.bullet.damage_max = 35
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.hit_fx = "enemy_bullywags_channeler_bolt_hit_fx"

tt = RT("enemy_bullywags_channeler_bolt_hit_fx", "fx")
tt.render.sprites[1].prefix = "infuser_bolt"
tt.render.sprites[1].name = "hit"

tt = RT("enemy_bullywags_erudite_bolt", "bolt")
tt.sound_events.insert = "frog_erudite_shot"
tt.render.sprites[1].prefix = "bullywags_erudite_bolt"
tt.bullet.damage_min = 42
tt.bullet.damage_max = 64
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.hit_fx = "enemy_bullywags_erudite_bolt_hit_fx"

tt = RT("enemy_bullywags_erudite_bolt_hit_fx", "fx")
tt.render.sprites[1].prefix = "bullywags_erudite_bolt"
tt.render.sprites[1].name = "hit"

tt = RT("enemy_bullywags_erudite_upgrade_bolt", "bolt")
tt.sound_events.insert = "frog_erudite_shot"
tt.render.sprites[1].prefix = "bullywags_erudite_bolt_upgraded"
tt.bullet.damage_min = 80
tt.bullet.damage_max = 120
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.hit_fx = "enemy_bullywags_eruditer_upgrade_bolt_hit_fx"

tt = RT("enemy_bullywags_eruditer_upgrade_bolt_hit_fx", "fx")
tt.render.sprites[1].prefix = "bullywags_erudite_bolt_upgraded"
tt.render.sprites[1].name = "hit"

tt = RT("infuser_cast_ray_shield", "bullet")
tt.render.sprites[1].prefix = "infuser_cast_ray"
tt.render.sprites[1].name = "flying"
tt.render.sprites[1].loop = false
tt.render.sprites[1].anchor = v(0.008, 0.54)
tt.bullet.flight_time = fts(2)
tt.bullet.hit_time = fts(3)
tt.image_width = 110
tt.main_script.update = scripts.ray_simple.update
tt.bullet.mod = "infuser_cast_shield_mod"

tt = RT("infuser_cast_ray_speed", "infuser_cast_ray_shield")
tt.bullet.mod = "infuser_cast_speed_mod"

tt = RT("infuser_cast_ray_silent", "infuser_cast_ray_shield")
tt.render.sprites[1].prefix = "infuser_gem_ray"
tt.render.sprites[1].name = "flying"
tt.render.sprites[1].animated = true
--tt.render.sprites[1].scale = v(1.2,1.2)
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_BULLETS
tt.bullet.ignore_hit_offset = false
tt.main_script.update = kr4_scripts.ray_simple_silent.update
tt.bullet.flight_time = fts(3)
tt.bullet.hit_time = fts(150)
tt.bullet.mod = nil
tt.sound_events.insert = "frog_infuser_crystalcharge-loop"
tt.sound_events.interrupt = "frog_infuser_crystalcharge-loop-end"

tt = RT("infuser_cast_shield_mod", "modifier")
AC(tt, "render", "health")
tt.render.sprites[1].prefix = "warden_shield"
tt.render.sprites[1].loop = false
tt.animations = {
	"in",
	"loop",
	"out"
}
tt.main_script.insert = kr4_scripts.infuser_cast_shield_mod.insert
tt.main_script.update = kr4_scripts.infuser_cast_shield_mod.update
tt.main_script.remove = kr4_scripts.infuser_cast_shield_mod.remove
tt.modifier.shield_hp = 200
tt.modifier.duration = -1

tt = RT("infuser_cast_speed_mod", "mod_slow")
tt.main_script.insert = kr4_scripts.infuser_cast_speed_mod.insert
tt.main_script.remove = kr4_scripts.infuser_cast_speed_mod.remove
tt.slow.factor = 3
tt.modifier.duration = 2
tt.walk_animations = {
	"speedWalk",
	"speedWalkUp",
	"speedWalkDown"
}

tt = RT("bullywag_spawner", "decal_scripted")
AC(tt, "spawner", "editor")
tt.render.sprites[1].prefix = "bullywag_spawner_layer1"
tt.render.sprites[1].animated = true
tt.render.sprites[1].group = 1
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "bullywag_spawner_layer2"
tt.render.sprites[2].animated = true
tt.render.sprites[2].group = 1
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "bullywag_spawner_splash"
tt.render.sprites[3].anchor = v(0.5, 0.187)
tt.render.sprites[3].offset = v(0, 0)
tt.render.sprites[3].animated = true
tt.spawner.animations = {
	{
		["name"] = "idle",
		["group"] = 1
	},
	{
		["name"] = "active",
		["group"] = 1
	},
	{
		["name"] = "end",
		["times"] = 1,
		["sprite"] = 3
	},
	{
		["name"] = "idle",
		["sprite"] = 3
	}
}
tt.main_script.update = kr4_scripts.bullywag_spawner.update

--通灵师的buff
tt = E:register_t("channeler_shield_aura", "aura")
tt.aura.mod = "mod_bullywags_channeler_shield"
tt.aura.cycle_time = 1
tt.aura.duration = -1
tt.aura.radius = 115.2
tt.aura.track_source = true
tt.aura.targets_per_cycle = 10
tt.aura.vis_flags = F_MOD
tt.aura.allowed_templates = {
	"enemy_bullywags_golem",
}
--tt.aura.requires_magic = true
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("channeler_damage_aura", "aura")
tt.aura.mod = "mod_bullywags_channeler_damage"
tt.aura.cycle_time = 1
tt.aura.duration = -1
tt.aura.radius = 115.2
tt.aura.track_source = true
tt.aura.targets_per_cycle = 10
tt.aura.vis_flags = F_MOD
tt.aura.allowed_templates = {
	"enemy_bullywags_erudite",
}
tt.aura.requires_magic = true
tt.main_script.insert = scripts.aura_apply_mod.insert
tt.main_script.update = scripts.aura_apply_mod.update

tt = E:register_t("mod_bullywags_channeler_shield", "modifier")
E:add_comps(tt, "render", "armor_buff")
tt.modifier.duration = 2
tt.modifier.allows_duplicates = false
tt.modifier.use_mod_offset = false
tt.armor_buff.magic = false
tt.armor_buff.max_factor = 0.25
tt.armor_buff.step_factor = 0.03
tt.armor_buff.cycle_time = 1
tt.render.sprites[1].prefix = "bullywags_channeler_upgrade_effect_particles"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor.y = 0.15625
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "bullywags_channeler_upgrade_effect_decal"
tt.render.sprites[2].animated = false
tt.render.sprites[2].anchor.y = 0
tt.render.sprites[2].offset.y = -15
tt.render.sprites[2].z = Z_DECALS
tt.main_script.insert = scripts.mod_armor_buff.insert
tt.main_script.remove = scripts.mod_armor_buff.remove
tt.main_script.update = scripts.mod_armor_buff.update

tt = E:register_t("mod_bullywags_channeler_damage", "modifier")
E:add_comps(tt, "render", "armor_buff")
tt.modifier.duration = 2
tt.modifier.use_mod_offset = false
tt.armor_buff.magic = false
tt.armor_buff.max_factor = 0
tt.armor_buff.step_factor = 0
tt.armor_buff.cycle_time = 1
tt.render.sprites[1].prefix = "bullywags_channeler_upgrade_effect_particles"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor.y = 0.15625
tt.render.sprites[2] = table.deepclone(tt.render.sprites[1])
tt.render.sprites[2].name = "bullywags_channeler_upgrade_effect_decal"
tt.render.sprites[2].animated = false
tt.render.sprites[2].anchor.y = 0
tt.render.sprites[2].offset.y = -15
tt.render.sprites[2].z = Z_DECALS
tt.main_script.insert = kr4_scripts.mod_erudite_buff.insert
tt.main_script.remove = kr4_scripts.mod_erudite_buff.remove
tt.main_script.update = kr4_scripts.mod_erudite_buff.update

--第18关场景：阿努瑞神龛
tt = E:register_t("bullywag_bubble_crystal", "decal_scripted")
E:add_comps(tt, "ui", "attacks", "tween")
tt.ui.can_click = true
tt.ui.click_rect = r(-37, -16, 74, 65)
tt.tween.disabled = true
tt.tween.remove = nil
tt.tween.reverse = nil
tt.tween.props[1].sprite_id = {}
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
tt.tween_duration = 0.5
tt.animation_group1 = "bubble_crystal_layer"
for i = 1, 10 do
	if i > 1 then
		tt.render.sprites[i] = E:clone_c("sprite")
	end
	tt.render.sprites[i].prefix = "bullywag_bubble_crystals_layer" .. i
	tt.render.sprites[i].name = "ready"
	tt.render.sprites[i].anchor = v(0.5, 0.246)
	tt.render.sprites[i].group = tt.animation_group1
end
tt.attacks.list[1] = E:clone_c("area_attack")
tt.attacks.list[1].vis_flags = bor(F_RANGED)
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].mod = "mod_bullywag_bubble_crystal"
tt.attacks.list[1].mod2 = "mod_bullywag_bubble_crystal_2"
tt.attacks.list[1].max_targets = 8
tt.attacks.list[1].cooldown = 30
tt.attacks.list[1].range = 187.5
tt.attacks.list[1].sound = "frog_infuser_shield-complete"
tt.attacks.list[1].sound_args = {
	delay = fts(2)
}
tt.main_script.update = kr4_scripts.bullywag_bubble_crystal.update

local decal_dwaarp_pulse = E:register_t("decal_bubble_crystal_pulse", "decal_tween")

decal_dwaarp_pulse.tween.props[1].name = "scale"
decal_dwaarp_pulse.tween.props[1].keys = {
	{
		0,
		v(1, 1)
	},
	{
		0.32,
		v(4, 4)
	}
}
decal_dwaarp_pulse.tween.props[1].sprite_id = 1
decal_dwaarp_pulse.tween.props[2] = E:clone_c("tween_prop")
decal_dwaarp_pulse.tween.props[2].name = "alpha"
decal_dwaarp_pulse.tween.props[2].keys = {
	{
		0,
		255
	},
	{
		0.32,
		0
	}
}
decal_dwaarp_pulse.tween.props[2].sprite_id = 1
decal_dwaarp_pulse.render.sprites[1].animated = false
decal_dwaarp_pulse.render.sprites[1].name = "bullywag_bubble_crystals_blast_0001"
decal_dwaarp_pulse.render.sprites[1].z = Z_DECALSlocal 

tt = E:register_t("mod_bullywag_bubble_crystal", "modifier")
E:add_comps(tt, "render", "armor_buff")
tt.modifier.duration = 6
tt.modifier.use_mod_offset = false
tt.armor_buff.magic = false
tt.armor_buff.max_factor = 2
tt.armor_buff.step_factor = 2
tt.armor_buff.cycle_time = 1
tt.render.sprites[1].prefix = "bullywag_bubble_crystals_shield_modifier"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor.y = 0.15625
tt.main_script.insert = scripts.mod_armor_buff.insert
tt.main_script.remove = scripts.mod_armor_buff.remove
tt.main_script.update = scripts.mod_armor_buff.update

tt = E:register_t("mod_bullywag_bubble_crystal_2", "modifier")
E:add_comps(tt, "armor_buff")
tt.modifier.duration = 6
tt.modifier.use_mod_offset = false
tt.armor_buff.magic = true
tt.armor_buff.max_factor = 2
tt.armor_buff.step_factor = 2
tt.armor_buff.cycle_time = 1
tt.main_script.insert = scripts.mod_armor_buff.insert
tt.main_script.remove = scripts.mod_armor_buff.remove
tt.main_script.update = scripts.mod_armor_buff.update

--第18关场景:注魔水晶
tt = E:register_t("overcharge_crystal", "decal_scripted")
E:add_comps(tt, "attacks", "tween", "crystal", "vis", "health", "unit")
tt.health.hp_max = 999999
tt.charging = false
tt.charged = false
tt.decharge = false
tt.unit.hit_offset = v(0,38)
tt.tween.disabled = true
tt.tween.remove = nil
tt.tween.reverse = nil
tt.tween.props[1].sprite_id = {}
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
tt.tween_duration = 0.5
tt.animation_group1 = "overcharge_crystal_layer"
for i = 1, 2 do
	if i > 1 then
		tt.render.sprites[i] = E:clone_c("sprite")
	end
	tt.render.sprites[i].prefix = "overcharge_crystals_base_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].anchor = v(0.5, 0.246)
	tt.render.sprites[i].group = tt.animation_group1
end
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].vis_flags = bor(F_RANGED)
tt.attacks.list[1].vis_bans = bor(F_NIGHTMARE)
tt.attacks.list[1].animation = "shoot"
tt.attacks.list[1].mod = "mod_overcharge_crystal_serpent"
tt.attacks.list[1].exclude_tower_kind = {}
tt.attacks.list[1].cooldown = 5.1
tt.attacks.list[1].max_range = 9999
tt.attacks.list[1].min_range = 0
tt.attacks.list[1].vis_flags = bor(F_MOD, F_CUSTOM)
tt.attacks.list[1].vis_bans = bor(F_CUSTOM)
--tt.attacks.list[1].sound = "frog_infuser_crystal_blockedtower-loop"
--tt.attacks.list[1].sound_args = {
--	delay = fts(2)
--}
tt.main_script.update = kr4_scripts.overcharge_crystal.update

tt = E:register_t("mod_overcharge_crystal_serpent", "modifier")
E:add_comps(tt, "render")
tt.sound_events.insert = "frog_infuser_crystal_blockedtower-loop"
tt.sound_events.finish = "frog_infuser_crystal_blockedtower-loop-end"
tt.main_script.update = scripts.mod_tower_block.update
tt.modifier.duration = 14
tt.render.sprites[1].anchor.y = 0.24
tt.render.sprites[1].draw_order = 10
tt.render.sprites[1].name = "start"
tt.render.sprites[1].prefix = "overcharge_crystals_modifier"

tt = E:register_t_10086("fx_lightining_crystal", "decal_scripted")
tt.main_script.update = kr4_scripts.multi_sprite_fx.update
tt.render.sprites[1].name = "overcharge_crystals_ray_loop_loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].scale = vv(2)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "overcharge_crystals_explotion_run"
tt.render.sprites[2].animated = true
tt.render.sprites[2].hidden = true
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[2].delay_start = fts(6)

---------------------------------------------------------
------------------------海盗王支线------------------------
---------------------------------------------------------

local pirate_enemy_i18n_overrides = {
	black_corsair = "ENEMY_BLACK_CORSAIR_ENCYC",
	blackthorne = "ENEMY_BLACKTHORNE_ENCYC",
	deep_king_throne = "ENEMY_DEEP_KING_ENCYC",
	filibusters_mini = "ENEMY_FILIBUSTERS",
	flying_ghost_ship = "ENEMY_FLYING_GHOST_SHIP_ENCYC",
	macaque = "ENEMY_MACAQUE_ENCYC"
}

local pirate_enemy_enc_icons = {
	apemate = 122,
	black_corsair = 94,
	blackthorne = 98,
	boatswain = 116,
	bomber_parrot = 117,
	boom_baboon = 120,
	bucaneer = 114,
	bullshark_dasher = 125,
	corpse_recruiter = 129,
	corsair = 115,
	cursed_sailor = 131,
	deep_king_throne = 96,
	filibusters = 119,
	filibusters_mini = 119,
	flying_ghost_ship = 97,
	ghostly_barge = 130,
	great_macaw = 121,
	hammermage = 127,
	hanged_captain = 132,
	lemonshark = 124,
	macaque = 95,
	megalodon = 133,
	risen_cutthroat = 128,
	rushing_monkey = 118,
	tailblade = 123,
	tigershark_rager = 126
}

local function pirate_enemy_template(name, prefix, hp, speed, gold, anchor, bar_y, shadow, options)
	options = options or {}
	local t = RT("enemy_" .. name, "enemy")
	t.enemy.gold = gold
	t.enemy.lives_cost = 1
	t.enemy.melee_slot = v(20, 0)
	t.health.hp_max = hp
	t.health.armor = 0
	t.health.magic_armor = 0
	t.health_bar.offset = v(0, bar_y or 35)
	t.info.i18n_key = pirate_enemy_i18n_overrides[name] or "ENEMY_" .. string.upper(name)
	t.info.enc_icon = options.enc_icon or pirate_enemy_enc_icons[name]
	t.motion.max_speed = speed
	t.render.sprites[1].prefix = prefix
	t.render.sprites[1].anchor = anchor or v(0.5, 0.2)
	t.render.sprites[1].angles.walk = {"walk", "walkUp", "walkDown"}
	t.render.sprites[1].animated = true
	if shadow then
		t.render.sprites[2] = E:clone_c("sprite")
		t.render.sprites[2].animated = false
		t.render.sprites[2].is_shadow = true
		t.render.sprites[2].name = shadow
		t.render.sprites[2].offset = v(0, 20)
		if options and options.shadow_y then
			t.render.sprites[2].offset = v(0, options.shadow_y)
		end
		t.render.sprites[2].z = Z_DECALS + 1
	end
	t.unit.hit_offset = v(0, math.floor((bar_y or 35) * 0.42))
	t.unit.mod_offset = v(0, math.floor((bar_y or 35) * 0.45))
	t.unit.head_offset = v(0, bar_y or 35)
	t.ui.click_rect = r(-22, 0, 44, bar_y or 35)
	t.vis.flags = bor(F_ENEMY)
	t.main_script.insert = scripts.enemy_basic.insert
	t.main_script.update = kr4_scripts.enemy_pirate.update
	t.pirate = {kind = name}
	return t
end

local function pirate_melee(t, damage_min, damage_max, cooldown, hit_time, animation)
	AC(t, "melee")
	local a = t.melee.attacks[1]
	a.animation = animation or "attack"
	a.cooldown = cooldown
	a.damage_min = damage_min
	a.damage_max = damage_max
	a.damage_type = DAMAGE_PHYSICAL
	a.hit_time = hit_time
	a.vis_flags = F_BLOCK
	a.vis_bans = bor(F_ENEMY, F_FLYING)
	a.basic_attack = true
	return a
end

local function pirate_flying(t, height)
	t.enemy.melee_slot = nil
	t.unit.can_explode = false
	t.unit.hide_after_death = true
	t.unit.show_blood_pool = false
	t.unit.hit_offset = v(0, height)
	t.unit.mod_offset = v(0, height)
	t.vis.flags = bor(F_ENEMY, F_FLYING)
	t.vis.bans = bor(t.vis.bans, F_BLOCK, F_THORN)
	for _, sprite in ipairs(t.render.sprites) do
		if sprite.is_shadow then
			sprite.offset = v(0, 0)
		end
	end
	return t
end

-- 海盗水手的近战与远程点燃。
tt = RT("mod_bucaneer_dot_melee", "modifier")
E:add_comps(tt, "dps", "render")
tt.modifier.duration = 2.5
tt.modifier.vis_flags = F_BURN
tt.dps.damage_every = 0.2
tt.dps.damage_min = 5
tt.dps.damage_max = 5
tt.dps.damage_type = DAMAGE_TRUE
tt.main_script.insert = scripts.mod_dps.insert
tt.main_script.update = scripts.mod_dps.update
tt.render.sprites[1].prefix = "bucaneer_modifier"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].draw_order = 2

tt = RT("mod_bucaneer_dot_ranged", "mod_bucaneer_dot_melee")
tt.dps.damage_min = 7
tt.dps.damage_max = 7

tt = RT("mod_tailblade_poison", "mod_poison")
tt.modifier.duration = 3
tt.dps.damage_every = 0.33
tt.dps.damage_min = 4
tt.dps.damage_max = 4
tt.dps.damage_type = DAMAGE_TRUE

tt = RT("mod_apemate_buff", "modifier")
tt.modifier.duration = 4
tt.damage_factor = 1.5
tt.speed_factor = 1.5
tt.main_script.insert = kr4_scripts.mod_pirate_stat_buff.insert
tt.main_script.remove = kr4_scripts.mod_pirate_stat_buff.remove
tt.main_script.update = scripts.mod_track_target.update

tt = RT("mod_shark_lifesteal_3", "modifier")
tt.heal = 3
tt.main_script.insert = kr4_scripts.mod_shark_lifesteal.insert

tt = RT("mod_shark_lifesteal_5", "mod_shark_lifesteal_3")
tt.heal = 5

tt = RT("mod_shark_lifesteal_10", "mod_shark_lifesteal_3")
tt.heal = 10

tt = RT("mod_shark_lifesteal_15", "mod_shark_lifesteal_3")
tt.heal = 15

tt = RT("mod_shark_lifesteal_75", "mod_shark_lifesteal_3")
tt.heal = 75

tt = RT("mod_shark_lifesteal_100", "mod_shark_lifesteal_3")
tt.heal = 100

tt = RT("enemy_bucaneer_projectile", "arrow")
tt.bullet.damage_min = 8
tt.bullet.damage_max = 12
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = fts(22)
tt.bullet.mod = "mod_bucaneer_dot_ranged"
tt.bullet.hit_fx = "fx_enemy_bucaneer_projectile_hit"
tt.render.sprites[1].prefix = "bucaneer_proy"
tt.render.sprites[1].name = "travel"
tt.render.sprites[1].animated = true
tt.sound_events.insert = "krv_sfx_bucaneer_attack"

tt = RT("fx_enemy_bucaneer_projectile_hit", "fx")
AC(tt, "sound_events")
tt.render.sprites[1].prefix = "bucaneer_hit"
tt.render.sprites[1].name = "run"
tt.sound_events.insert = "krv_sfx_bucaneer_explotion"

tt = RT("enemy_bomber_parrot_bomb", "bomb")
tt.bullet.damage_min = 105
tt.bullet.damage_max = 150
tt.bullet.damage_radius = 55
tt.bullet.damage_type = DAMAGE_EXPLOSION
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.flight_time = fts(16)
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].name = "parrot_proy_0001"
tt.render.sprites[1].animated = false
tt.sound_events.insert = "kr4_enemies_pirates_bomber_parrot_bomb_throw"
tt.sound_events.hit = "bomb_hit_sound"

tt = RT("enemy_tailblade_projectile", "arrow")
tt.bullet.damage_min = 30
tt.bullet.damage_max = 55
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = fts(7)
tt.bullet.mod = "mod_tailblade_poison"
tt.bullet.hit_fx = "fx_enemy_tailblade_projectile_hit"
tt.render.sprites[1].name = "tailblade_proy_"
tt.render.sprites[1].animated = false

tt = RT("fx_enemy_tailblade_projectile_hit", "fx")
tt.render.sprites[1].prefix = "tailblade_hit"
tt.render.sprites[1].name = "run"

-- 海盗无赖
tt = pirate_enemy_template("freebooter", "freebooter", 300, 45, 16, v(0.5, 0.2), 30, "freebooter_shadow")
pirate_melee(tt, 10, 15, 1, 0.3, "attack")
tt.pirate.corpse = "risen"
tt.info.portrait = "gui4_bottom_info_image_enemies_0113"

-- 海盗水手
tt = pirate_enemy_template("bucaneer", "bucaneer", 360, 35, 35, v(0.5, 0.21), 33, "bucaneer_shadow")
tt.sound_events.death = "dwarves_sulfur_alchemist_death"
local pa = pirate_melee(tt, 7, 7, 1.5, 0.366, "attack")
pa.mod = "mod_bucaneer_dot_melee"
AC(tt, "ranged")
tt.ranged.attacks[1].animation = "attackArea"
tt.ranged.attacks[1].bullet = "enemy_bucaneer_projectile"
tt.ranged.attacks[1].bullet_start_offset = {v(-6, 22), v(6, 22)}
tt.ranged.attacks[1].cooldown = 5
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].shoot_time = 0.333
tt.ranged.attacks[1].vis_flags = F_RANGED
tt.ranged.attacks[1].vis_bans = bor(F_ENEMY)
tt.pirate.corpse = "risen"
tt.info.portrait = "gui4_bottom_info_image_enemies_0112"

-- 海盗头子
tt = pirate_enemy_template("corsair", "corsair", 430, 35, 45, v(0.5, 0.2), 34, "corsair_shadow")
tt.health.armor = 0.3
pirate_melee(tt, 40, 75, 1, 0.3, "attack")
tt.pirate.heal = {cooldown = 5, amount = 100, health_trigger = 0.9, animation = "heal", cast_time = 0.366}
tt.pirate.corpse = "risen"
tt.info.portrait = "gui4_bottom_info_image_enemies_0114"

-- 炸弹鹦鹉
tt = pirate_enemy_template("bomber_parrot", "parrot", 180, 60, 20, v(0.5, 0.17), 74, "parrot_shadow", {shadow_y=65})
tt.sound_events.death = "group_pirates_bomber_parrot_death"
pirate_flying(tt, 56)
tt.render.sprites[1].angles.attack = {"attack", "attackUp", "attackDown"}
tt.pirate.bomb = {
	cooldown = 1,
	min_range = 0,
	max_range = 100,
	bullet = "enemy_bomber_parrot_bomb",
	animation = "attack",
	shoot_time = 0.2,
	shoot_offsets = {attack = v(13, 48), attackUp = v(0, 66), attackDown = v(0, 36)}
}
tt.pirate.one_shot = true
tt.info.portrait = "gui4_bottom_info_image_enemies_0116"

-- 海盗水手长
tt = pirate_enemy_template("boatswain", "boatswain", 2200, 18, 70, v(0.5, 0.31), 50, "boatswain_shadow")
tt.render.sprites[1].angles.attack = {"attack", "attack", "attack"}
local pa = pirate_melee(tt, 90, 125, 2, 0.333, "attack")
pa.sound = "kr4_enemies_pirates_boatswain_melee"
pa.type = "area"
pa.damage_radius = 50
pa.count = 5
pa.hit_offset = v(35, 0)
pa.vis_flags = F_AREA
pa.vis_bans = bor(F_ENEMY)
tt.unit.death_animation = "death"
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(28, 0)
tt.pirate.corpse = "hanged"
tt.info.portrait = "gui4_bottom_info_image_enemies_0115"

-- 冲锋猴
tt = pirate_enemy_template("rushing_monkey", "rushing_monkey", 80, 60, 7, v(0.5, 0.12), 24, "rushing_monkey_shadow_0001", {shadow_y=30})
tt.vis.bans = bor(tt.vis.bans, F_BLOCK)
tt.pirate.spawn_animation = "spawn"
tt.pirate.rush = {radius = 62.5, factor = 2.5, safe_nodes_to_exit = 50}
tt.info.portrait = "gui4_bottom_info_image_enemies_0118"

-- 叠罗猴与小型叠罗猴
tt = pirate_enemy_template("filibusters", "filibusters_one", 240, 39, 33, v(0.5, 0.196), 59, "filibusters_one_shadow", {shadow_y=30})
tt.sound_events.death = "group_pirates_filibusters_fall_off"
pirate_melee(tt, 20, 30, 0.8, 0.2, "attack")
tt.pirate.death_spawns = {"enemy_filibusters_mini", "enemy_rushing_monkey"}

tt = pirate_enemy_template("filibusters_mini", "filibusters_two", 160, 39, 22, v(0.5, 0.196), 41, "filibusters_two_shadow", {shadow_y=30})
tt.sound_events.death = "group_pirates_filibusters_fall_off"
pirate_melee(tt, 10, 20, 0.8, 0.2, "attack")
tt.pirate.death_spawns = {"enemy_rushing_monkey"}
tt.info.portrait = "gui4_bottom_info_image_enemies_0119"

-- 爆桶猴
tt = pirate_enemy_template("boom_baboon", "boom_baboon", 350, 60, 30, v(0.5, 0.28), 60, "boom_baboon_shadow0001", {shadow_y=25})
tt.vis.bans = bor(tt.vis.bans, F_BLOCK)
tt.pirate.proximity = 35
tt.pirate.death_damage = {radius = 50, damage_min = 150, damage_max = 200, damage_type = DAMAGE_TRUE}
tt.pirate.death_spawns = {"enemy_rushing_monkey"}
tt.pirate.death_fx = "fx_kr4_explosion_fragment"
tt.pirate.death_fx_duration = 1
tt.pirate.remove_on_death = true
tt.info.portrait = "gui4_bottom_info_image_enemies_0120"

-- 尾刃狒狒
tt = pirate_enemy_template("tailblade", "tailblade", 400, 75, 40, v(0.5, 0.3846), 30, "tailblade_shadow_0001", {shadow_y=10})
tt.sound_events.death = "group_pirates_filibusters_fall_off"
AC(tt, "dodge")
tt.dodge.animation = "dodge"
tt.dodge.chance = 0.15
tt.dodge.cooldown = 0.5
tt.health.on_damage = kr4_scripts.enemy_tailblade.on_damage
pirate_melee(tt, 16, 24, 1, 0.2666, "melee")
AC(tt, "ranged")
tt.ranged.attacks[1].animation = "range"
tt.ranged.attacks[1].bullet = "enemy_tailblade_projectile"
tt.ranged.attacks[1].bullet_start_offset = {v(8, 16), v(-8, 16)}
tt.ranged.attacks[1].cooldown = 1.2
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].max_range = 137.5
tt.ranged.attacks[1].shoot_time = 0.2666
tt.ranged.attacks[1].vis_flags = F_RANGED
tt.ranged.attacks[1].vis_bans = bor(F_ENEMY)
tt.info.portrait = "gui4_bottom_info_image_enemies_0122"

-- 巨型金刚鹦鹉
tt = pirate_enemy_template("great_macaw", "great_macaw", 400, 45, 55, v(0.5, 0.077), 98, "great_macaw_shadow_0001", {shadow_y=30})
tt.sound_events.death = "group_pirates_bomber_parrot_death"
pirate_flying(tt, 72)
tt.pirate.death_spawns = {"enemy_rushing_monkey"}
tt.pirate.safe_nodes_to_exit = 50
tt.info.portrait = "gui4_bottom_info_image_enemies_0123"

-- 猿大副
tt = pirate_enemy_template("apemate", "apemate", 2000, 13, 125, v(0.5, 0.24), 55, "apemate_shadow", {shadow_y=30})
tt.sound_events.death = "krv_sfx_monkey_apemate_death"
tt.pirate.spawn_animation = "spawn"
tt.health.armor = 0.6
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(30, 0)
local pa = pirate_melee(tt, 130, 160, 3.5, 0.4, "attack")
pa.type = "area"
pa.damage_radius = 60
pa.count = 5
pa.hit_offset = v(36, 0)
pa.vis_flags = F_AREA
pa.vis_bans = bor(F_ENEMY)
tt.pirate.buff = {cooldown = 6, radius = 200, min_count = 2, max_count = 5, duration = 4, animation = "buff", cast_time = 0.2666, mod = "mod_apemate_buff"}
tt.info.portrait = "gui4_bottom_info_image_enemies_0121"

-- 滚石
tt = pirate_enemy_template("monkey_ball", "stone_ball", 200, 45, 0, v(0.5, 0.2), 60, nil)
tt.render.sprites[1].angles.walk = {"walk", "walk", "walk"}
tt.vis.bans = bor(tt.vis.bans, F_BLOCK, F_MOD)
tt.ui.can_select = false
tt.unit.show_blood_pool = false
tt.pirate.rolling_damage = {radius = 25, cooldown = 0.25, damage = 55}

tt = RT("enemy_hammermage_projectile", "bolt_enemy")
tt.bullet.damage_min = 80
tt.bullet.damage_max = 115
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.min_speed = 120
tt.bullet.max_speed = 300
tt.bullet.acceleration_factor = 0.1
tt.bullet.hit_fx = "fx_enemy_hammermage_projectile_hit"
tt.main_script.insert = kr4_scripts.pirate_bolt.insert
tt.render.sprites[1].prefix = "hammermage_proyectile"
tt.render.sprites[1].name = "travel"
tt.render.sprites[1].animated = true

tt = RT("fx_enemy_hammermage_projectile_hit", "fx")
tt.render.sprites[1].prefix = "hammermage_proyectile"
tt.render.sprites[1].name = "hit"

tt = RT("enemy_corpse_recruiter_projectile", "arrow")
tt.bullet.damage_min = 112
tt.bullet.damage_max = 148
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.flight_time = fts(10)
tt.bullet.hit_fx = "fx_enemy_corpse_recruiter_projectile_hit"
tt.render.sprites[1].prefix = "corpse_recruiter_projectil"
tt.render.sprites[1].name = "travel"
tt.render.sprites[1].animated = true
tt.sound_events.insert = "group_ghosts-corpse-recruiter-ranged"

tt = RT("fx_enemy_corpse_recruiter_projectile_hit", "fx")
tt.render.sprites[1].prefix = "corpse_recruiter_projectil"
tt.render.sprites[1].name = "hit"

tt = RT("fx_enemy_ghost_barrage", "fx")
tt.render.sprites[1].prefix = "boss_ghost_ship_explosion"
tt.render.sprites[1].name = "run"

tt = RT("enemy_blackthorne_cluster_bomb", "bomb")
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_radius = 1
tt.bullet.damage_bans = F_ALL
tt.bullet.damage_flags = 0
tt.bullet.flight_time = fts(25)
tt.bullet.hit_fx = "fx_enemy_blackthorne_cluster_break"
tt.bullet.hit_decal = nil
tt.bullet.pop = nil
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].prefix = "boss_blackthorne_projectile_basic"
tt.render.sprites[1].name = "travel"
tt.render.sprites[1].animated = true
tt.sound_events.insert = nil
tt.sound_events.hit = "bomb_hit_sound"

tt = RT("fx_enemy_blackthorne_cluster_break", "fx")
tt.render.sprites[1].prefix = "boss_blackthorne_projectile_basic"
tt.render.sprites[1].name = "run"

tt = RT("enemy_blackthorne_cluster_fragment", "bomb")
tt.bullet.damage_min = 150
tt.bullet.damage_max = 150
tt.bullet.damage_radius = 35
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.damage_bans = F_ENEMY
tt.bullet.damage_flags = F_AREA
tt.bullet.flight_time = fts(16)
tt.bullet.hit_fx = "fx_kr4_explosion_fragment"
tt.bullet.hit_decal = "decal_bomb_crater"
tt.bullet.pop = nil
tt.main_script.insert = scripts.enemy_bomb.insert
tt.main_script.update = scripts.enemy_bomb.update
tt.render.sprites[1].prefix = "boss_blackthorne_projectile_small"
tt.render.sprites[1].name = "travel"
tt.render.sprites[1].animated = true
tt.sound_events.insert = nil
tt.sound_events.hit = "bomb_hit_sound"

tt = RT("enemy_blackthorne_cluster_controller", "decal_scripted")
tt.main_script.update = kr4_scripts.blackthorne_cluster_controller.update
tt.render.sprites[1].hidden = true
tt.count = 7
tt.fragment = "enemy_blackthorne_cluster_fragment"

tt = RT("mod_hammermage_tower_block", "modifier")
AC(tt, "render")
tt.modifier.duration = 3
tt.main_script.update = kr4_scripts.mod_pirate_tower_block.update
tt.main_script.remove = kr4_scripts.mod_pirate_tower_block.remove
tt.render.sprites[1].prefix = "hammermage_tower_block"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("boss_macaque_block_tower", "modifier")
AC(tt, "render")
tt.modifier.duration = 5
tt.main_script.update = kr4_scripts.mod_pirate_tower_block.update
tt.main_script.remove = kr4_scripts.mod_pirate_tower_block.remove
tt.loop_animation = "idle"
for i = 1, 2 do
	if i > 1 then tt.render.sprites[i] = E:clone_c("sprite") end
	tt.render.sprites[i].prefix = "boss_macaque_block_tower_layer" .. i
	tt.render.sprites[i].name = "in"
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].anchor = v(0.5, 0.333)
	tt.render.sprites[i].offset = v(0, 20)
	tt.render.sprites[i].z = Z_EFFECTS + i
end

tt = RT("mod_ghostly_barge_armor", "modifier")
tt.modifier.duration = 0.3
tt.magic_armor = 0.85
tt.main_script.insert = kr4_scripts.mod_ghostly_barge_armor.insert
tt.main_script.remove = kr4_scripts.mod_ghostly_barge_armor.remove
tt.main_script.update = scripts.mod_track_target.update

-- 弯刀柠檬鲨
tt = pirate_enemy_template("lemonshark", "lemonshark", 240, 40, 15, v(0.5, 0.2), 35, "lemonshark_shadow0001")
tt.pirate.spawn_animation = "spawn"
tt.pirate.spawn_sound = "group_sharks_splash_spawns"
local pa = pirate_melee(tt, 15, 35, 0.8, 0.3, "attack")
pa.mod = "mod_shark_lifesteal_5"
tt.info.portrait = "gui4_bottom_info_image_enemies_0125"

-- 冲刺牛鲨
tt = pirate_enemy_template("bullshark_dasher", "bullshark", 700, 24, 25, v(0.5, 0.22), 55, "bullshark_shadow")
tt.render.sprites[1].offset = v(0, -15)
tt.health.armor = 0.5
tt.enemy.melee_slot = v(28, 0)
tt.pirate.spawn_animation = "spawn"
tt.pirate.spawn_sound = "group_sharks_splash_spawns"
local pa = pirate_melee(tt, 35, 55, 1.4, 0.233, "attack")
pa.mod = "mod_shark_lifesteal_15"
tt.pirate.buried = {cooldown = 5, duration = 0.7, factor = 7.5, animation_in = "buriedIn", animation = "buriedWalk", animation_out = "buriedOut", safe_nodes_to_exit = 65}
tt.info.portrait = "gui4_bottom_info_image_enemies_0128"

-- 暴怒虎鲨
tt = pirate_enemy_template("tigershark_rager", "tigershark", 550, 38, 50, v(0.5, 0.2), 48, "tigershark_shadow")
tt.render.sprites[1].offset = v(0, -15)
tt.enemy.lives_cost = 2
tt.pirate.spawn_animation = "spawn"
tt.pirate.spawn_sound = "group_sharks_splash_spawns"
local pa = pirate_melee(tt, 8, 13, 1.5, 0.2, "attack")
pa.damage_type = DAMAGE_TRUE
pa.hit_times = {0.2, 0.4, 0.733}
pa.mod = "mod_shark_lifesteal_3"
tt.pirate.rager = {radius = 100, factor = 2, linger = 1.5}
tt.info.portrait = "gui4_bottom_info_image_enemies_0126"

-- 锤头鲨法师
tt = pirate_enemy_template("hammermage", "hammermage", 400, 18, 40, v(0.5, 0.2), 55, "hammermage_shadow")
tt.render.sprites[1].offset = v(0, -20)
tt.health.magic_armor = 0.6
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(28, 0)
tt.pirate.spawn_animation = "spawn"
tt.pirate.spawn_sound = "group_sharks_splash_spawns"
local pa = pirate_melee(tt, 10, 25, 1, 0.266, "attackMelee")
pa.mod = "mod_shark_lifesteal_10"
pa.type = "area"
pa.damage_radius = 45
pa.count = 8
pa.hit_offset = v(42, 0)
AC(tt, "ranged")
tt.ranged.attacks[1].animation = "attackRange"
tt.ranged.attacks[1].bullet = "enemy_hammermage_projectile"
tt.ranged.attacks[1].bullet_start_offset = {v(-7, 66), v(7, 66)}
tt.ranged.attacks[1].cooldown = 1.8
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].shoot_time = 0.5
tt.ranged.attacks[1].vis_flags = F_RANGED
tt.ranged.attacks[1].vis_bans = bor(F_ENEMY)
tt.pirate.stun = {cooldown = 8, radius = 150, min_count = 2, max_count = 4, duration = 3, animation = "attackStun", cast_time = 0.433}
tt.pirate.tower_block = {cooldown = 6, radius = 150, duration = 3, max_count = 1, animation = "block", cast_time = 0.433, mod = "mod_hammermage_tower_block"}
tt.info.portrait = "gui4_bottom_info_image_enemies_0127"

-- 巨齿鲨
tt = pirate_enemy_template("megalodon", "megalodon", 3500, 10, 250, v(0.5, 0.2), 90, "megalodon_shadow",{shadow_y = 40})
tt.render.sprites[1].offset = v(0, -60)
tt.render.sprites[2].offset = v(0, -20)
tt.sound_events.death = "krv_sharks_megalodon_death"
tt.enemy.lives_cost = 3
tt.enemy.melee_slot = v(35, 0)
tt.vis.flags = bor(F_ENEMY, F_MINIBOSS)
tt.pirate.spawn_animation = "spawn"
tt.pirate.spawn_sound = "group_sharks_splash_spawns"
local pa = pirate_melee(tt, 9999, 9999, 4, 0.4, "attack")
pa.instakill = true
pa.type = "area"
pa.damage_type = DAMAGE_INSTAKILL
pa.damage_radius = 100
pa.count = 99
pa.vis_bans = bor(F_ENEMY, F_FLYING)
pa.fn_filter = kr4_scripts.enemy_pirate.blockers_only
pa.mod = "mod_shark_lifesteal_100"
tt.info.portrait = "gui4_bottom_info_image_enemies_0129"

-- 回魂割喉者
tt = pirate_enemy_template("risen_cutthroat", "risen_cutthroat", 200, 35, 13, v(0.5, 0.2), 40, "risen_cutthroat_shadow")
tt.sound_events.death = "haunted_skeleton_death"
tt.pirate.spawn_animation = "spawn"
tt.pirate.spawn_sound = "group_ghosts-ghosts-rising"
pirate_melee(tt, 45, 80, 1, 0.2666, "attack")
tt.pirate.fog_speed = 80
tt.info.portrait = "gui4_bottom_info_image_enemies_0131"

-- 还魂师
tt = pirate_enemy_template("corpse_recruiter", "corpse_recruiter", 550, 35, 50, v(0.5, 0.2), 50, "corpse_recruiter_shadow", {shadow_y = 40})
tt.sound_events.death = nil
local pa = pirate_melee(tt, 12, 18, 2, 0.6, "attack")
AC(tt, "ranged")
tt.ranged.attacks[1].animation = "shoot"
tt.ranged.attacks[1].bullet = "enemy_corpse_recruiter_projectile"
tt.ranged.attacks[1].bullet_start_offset = {v(0, 38), v(0, 38)}
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].shoot_time = 0.666
tt.ranged.attacks[1].vis_flags = F_RANGED
tt.ranged.attacks[1].vis_bans = bor(F_ENEMY)
tt.pirate.recruit = {cooldown = 1, radius = 175, max_count = 3, animation = "summon", cast_time = 0.56, safe_nodes_to_exit = 40}
tt.info.portrait = "gui4_bottom_info_image_enemies_0133"

-- 腐臭鹦鹉
tt = pirate_enemy_template("cursed_sailor", "cuzor", 100, 60, 25, v(0.5, 0.17), 70, "cuzor_shadow", {shadow_y = 60})
tt.health.armor = 0.9
pirate_flying(tt, 52)
tt.info.portrait = "gui4_bottom_info_image_enemies_0132"

-- 绞刑船长
tt = pirate_enemy_template("hanged_captain", "hanged_captain", 1250, 15, 99, v(0.5, 0.2), 65, "hanged_captain_shadow", {shadow_y = 60})
tt.sound_events.death = "krv_ghost_captain_death"
tt.enemy.lives_cost = 2
tt.enemy.melee_slot = v(32, 0)
tt.pirate.spawn_animation = "spawn"
local pa = pirate_melee(tt, 999, 999, 2.5, 0.333, "attackMelee")
pa.instakill = true
pa.vis_bans = bor(pa.vis_bans, F_BOSS)
tt.pirate.fog_spawn = {cooldown = 8, duration = 18, radius = 55, qty = 7, step_nodes = 4, animation = "attackArea", cast_time = 0.733, safe_nodes_to_exit = 55}
tt.info.portrait = "gui4_bottom_info_image_enemies_0134"

-- 幽灵摆渡人
tt = pirate_enemy_template("ghostly_barge", "ghostly_barge_layer1", 600, 15, 60, v(0.5, 0.17), 90, "ghostly_barge_shadow", {shadow_y = 75})
tt.health.magic_armor = 0.85
pirate_flying(tt, 65)
tt.pirate.armor_aura = {radius = 175, max_count = 6, cooldown = 0.2, mod = "mod_ghostly_barge_armor"}
tt.info.portrait = "gui4_bottom_info_image_enemies_0130"

-- 死亡海盗的短暂尸体标记，供还魂师复活。
tt = RT("pirate_corpse_marker", "decal_scripted")
AC(tt, "tween")
tt.main_script.update = kr4_scripts.pirate_corpse_marker.update
tt.duration = 4
tt.raise_template = "enemy_risen_cutthroat"
tt.render.sprites[1].name = "decal_blood_pool_red"
tt.render.sprites[1].animated = false
tt.render.sprites[1].alpha = 100
tt.render.sprites[1].z = Z_DECALS
tt.tween.disabled = true

-- 紫雾：30%未命中、阵亡单位转化，以及幽灵船护盾都由脚本处理。
tt = RT("pirates_fog", "decal_scripted")
AC(tt, "tween")
tt.main_script.update = kr4_scripts.pirates_fog.update
tt.duration = 18
tt.radius = 55
tt.render.sprites[1].name = "captain_fog_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].alpha = 175
tt.tween.disabled = true

tt = RT("pirates_fog_2", "pirates_fog")
tt.radius = 70

for _, fog_name in ipairs({"pirates_fog_boss1_0", "pirates_fog_boss1_1", "pirates_fog_boss1_2", "pirates_fog_boss2_0", "pirates_fog_boss2_1", "pirates_fog_boss2_2"}) do
	RT(fog_name, "pirates_fog")
end

local function pirate_boss_template(name, prefix, hp, speed, anchor, bar_y, shadow, options)
	local t = pirate_enemy_template(name, prefix, hp, speed, 0, anchor, bar_y, shadow, options)
	t.enemy.lives_cost = 20
	t.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
	t.health_bar.offset = v(0, bar_y)
	t.vis.flags = bor(F_ENEMY, F_BOSS)
	t.info.i18n_key = pirate_enemy_i18n_overrides[name] or "ENEMY_" .. string.upper(name)
	t.info.enc_icon = pirate_enemy_enc_icons[name] or t.info.enc_icon
	return t
end

local function pirate_add_layers(t, prefix, count, anchor, offset)
	t.animation_group = "layers"

	for i = 1, count do
		if i > 1 then
			t.render.sprites[i] = E:clone_c("sprite")
		end
		t.render.sprites[i].prefix = prefix .. i
		t.render.sprites[i].anchor = anchor
		t.render.sprites[i].offset = offset or v(0, 0)
		t.render.sprites[i].animated = true
		t.render.sprites[i].group = t.animation_group
		t.render.sprites[i].draw_order = i
	end
	return count
end

-- Boss 黑胡子船长
tt = pirate_boss_template("black_corsair", "blackcorsair", 13000, 9, v(0.5, 0.321), 60, "blackcorsair_shadow",{shadow_y=25})
tt.enemy.gold = 35
tt.enemy.melee_slot = v(30, 0)
local pa = pirate_melee(tt, 50, 63, 0.4, 0.166, "attack")
pa.damage_type = DAMAGE_TRUE
pa.sound = "group_pirates_black_corsair_melee"
tt.sound_events.death = "kr4_enemies_pirates_black_corsair_death"
pa.hit_times = {0.166, 0.432, 0.698}
pa.type = "area"
pa.damage_radius = 90
pa.count = 3
pa.vis_bans = bor(F_ENEMY, F_FLYING)
tt.pirate.cannons = {cooldown = 13, warning_time = 5, radius = 45, damage_min = 200, damage_max = 300, max_count = 8, animation = "signal", cast_time = 0.266}
tt.pirate.end_level_on_death = true
tt.info.portrait = "gui4_bottom_info_image_enemies_0117"

-- Boss 猢狲船长（船体九层，猴王三层以静态首帧挂在船体上）。
tt = pirate_boss_template("macaque", "boss_macaque_ship_layer1", 10000, 6, v(0.5, 0.315), 100, nil)
tt.sound_events.death = "krv_sfx_monkeys_boss_death"
tt.render.sprites[1].angles.walk = {"walk", "walk", "walk"}
tt.vis.bans = bor(tt.vis.bans, F_BLOCK)
tt.enemy.melee_slot = nil
pirate_add_layers(tt, "boss_macaque_ship_layer", 9, v(0.5, 0.315), v(0, 0))
for i = 1, 3 do
	local sid = 9 + i
	tt.render.sprites[sid] = E:clone_c("sprite")
	tt.render.sprites[sid].prefix = "boss_macaque_unit_layer" .. i
	tt.render.sprites[sid].animated = true
	tt.render.sprites[sid].name = "idle"
	tt.render.sprites[sid].ignore_start = true
	tt.render.sprites[sid].anchor = v(0.5, 0.315)
	tt.render.sprites[sid].offset = v(0, 0)
end
tt.pirate.stomp = {radius = 35, cooldown = 0.25, damage = 20}
tt.pirate.hide_sprite_ids_on_death = {10, 11, 12}
tt.pirate.spawn_apemate = {first_cooldown = 30, cooldown = 22, ahead_nodes = 25, safe_nodes_to_exit = 55, animation = "summon", cast_time = 0.466, sprite_ids = {10, 11, 12}}
tt.pirate.fruit = {cooldown = 25, duration = 3, animation = "attack", cast_time = 1.8, sprite_ids = {10, 11, 12}}
tt.pirate.tower_block = {first_cooldown = 15, cooldown = 25, radius = 10000, duration = 5, max_count = 2, mod = "boss_macaque_block_tower", animation = "cannon", cast_time = 0.8, sprite_ids = {10, 11, 12}}
tt.pirate.end_level_on_death = true
tt.info.portrait = "gui4_bottom_info_image_enemies_0124"

-- Boss 深海王
tt = pirate_boss_template("deep_king_throne", "boss_deep_king_unit_layer1", 9500, 10, v(0.5, 0.25), 85, nil)
tt.sound_events.death = "krv_sharks_megalodon_death"
tt.enemy.melee_slot = v(38, 0)
pirate_add_layers(tt, "boss_deep_king_unit_layer", 3, v(0.5, 0.25), v(0, 0))
tt.pirate.spawn_animation = "spawn"
tt.pirate.spawn_sound = "krv_sfx_sharks_boss_appear"
tt.render.sprites[1].offset = v(0, -140)
tt.render.sprites[2].offset = v(0, -140)
tt.render.sprites[3].offset = v(0, -140)
local pa = pirate_melee(tt, 1500, 1500, 2, 0.266, "attack")
pa.damage_type = DAMAGE_TRUE
pa.type = "area"
pa.damage_radius = 50
pa.count = 99
pa.fn_filter = kr4_scripts.enemy_pirate.blockers_only
pa.mod = "mod_shark_lifesteal_75"
tt.pirate.spawn_sharks = {cooldown = 15, safe_nodes_to_exit = 45, animation = "summon", cast_time = 0.4}
tt.pirate.destroy_tower = {cooldown = 20, radius = 150, hidden_time = 1.5, animation = "abiltyIn", return_animation = "abiltyOut"}
tt.pirate.phase_thresholds = {0.75, 0.45}
tt.pirate.phase_paths = {5, 3}
tt.pirate.end_level_on_death = true
tt.info.portrait = "gui4_bottom_info_image_enemies_0135"

-- Boss 斯派克
tt = pirate_boss_template("flying_ghost_ship", "boss_ghost_ship_layer1", 15500, 9, v(0.5, 0.2), 175, nil)
tt.sound_events.death = "krv_ghost_captain_death"
tt.render.sprites[1].angles.walk = {"walk", "walk", "walk"}
pirate_flying(tt, 90)
tt.vis.flags = bor(F_ENEMY, F_FLYING, F_BOSS)
pirate_add_layers(tt, "boss_ghost_ship_layer", 8, v(0.5, 0.2), v(0, 0))
tt.pirate.spawn_animation = "spawn"
tt.pirate.ghost_barrage = {cooldown = 5.5, min_range = 0, max_range = 125, radius = 40, damage_min = 11, damage_max = 22, shots = 7, max_rounds = 6, animation = "attack", cast_time = 0}
tt.pirate.disable_power = {cooldown = 14, duration_min = 4, duration_max = 8, animation = "ability", cast_time = 0.3333}
tt.pirate.fog_immortality = true
tt.pirate.boss_death = {animation = "death", loop_animation = "deathLoop", delay = 0.5, max_time = 5}
tt.pirate.end_level_on_death = true
tt.health.on_damage = kr4_scripts.enemy_ghost_ship.on_damage
tt.info.portrait = "gui4_bottom_info_image_enemies_0136"

-- 第191关四位小 Boss。
tt = RT("enemy_black_corsair_last_stage", "enemy_black_corsair")
tt.health.hp_max = 6800
tt.enemy.gold = 0
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.vis.bans = bor(tt.vis.bans, F_FREEZE, F_INSTAKILL, F_POLYMORPH, F_TELEPORT)
tt.pirate.cannons = nil
tt.pirate.end_level_on_death = nil
tt.pirate.death_cage = {template = "blackthorne_prisoner_box_small", pos = v(602, 635), flip_x = true, delay = 1}
tt.melee.attacks[1].cooldown = 0.4
tt.melee.attacks[1].damage_min = 28
tt.melee.attacks[1].damage_max = 40
tt.melee.attacks[1].damage_type = DAMAGE_TRUE
tt.info.portrait = "gui4_bottom_info_image_enemies_0117"

tt = RT("enemy_boss_macaque_last_stage", "enemy_macaque")
tt.health.hp_max = 5500
tt.motion.max_speed = 6
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.vis.bans = bor(tt.vis.bans, F_FREEZE, F_INSTAKILL, F_POLYMORPH, F_TELEPORT)
tt.pirate.death_cage = {template = "blackthorne_prisoner_box_big", pos = v(646, 626), flip_x = false, delay = 1}
tt.pirate.spawn_apemate.first_cooldown = 20
tt.pirate.spawn_apemate.cooldown = 75
tt.pirate.spawn_apemate.safe_nodes_to_exit = 35
tt.pirate.fruit.cooldown = 12
tt.pirate.fruit.duration = 1.1
tt.pirate.tower_block = nil
tt.pirate.end_level_on_death = nil
tt.info.portrait = "gui4_bottom_info_image_enemies_0124"

tt = RT("enemy_deep_king_throne_last_stage", "enemy_deep_king_throne")
tt.health.hp_max = 5225
tt.vis.flags = bor(F_ENEMY, F_BOSS)
tt.vis.bans = bor(tt.vis.bans, F_FREEZE, F_INSTAKILL, F_POLYMORPH, F_TELEPORT)
for i = 1, 3 do
	tt.render.sprites[i].prefix = "stage41_boss_deep_king_unit_layer" .. i
end
tt.pirate.death_cage = {template = "blackthorne_prisoner_box_big", pos = v(715, 599), flip_x = true, delay = 1}
tt.pirate.spawn_sharks.cooldown = 40
tt.pirate.spawn_sharks.safe_nodes_to_exit = 40
tt.pirate.destroy_tower.cooldown = 28
tt.pirate.destroy_tower.start_ready = true
tt.pirate.destroy_tower.hidden_time = 3.5
tt.pirate.phase_thresholds = nil
tt.pirate.phase_paths = nil
tt.pirate.spawn_animation = nil
tt.pirate.spawn_sound = nil
tt.pirate.end_level_on_death = nil
tt.melee.attacks[1].cooldown = 1.5
tt.info.portrait = "gui4_bottom_info_image_enemies_0135"

tt = RT("enemy_flying_ghost_ship_last_stage", "enemy_flying_ghost_ship")
tt.health.hp_max = 8525
tt.enemy.lives_cost = 999
tt.motion.max_speed = 8
tt.vis.flags = bor(F_ENEMY, F_FLYING, F_BOSS)
tt.vis.bans = bor(tt.vis.bans, F_FREEZE, F_INSTAKILL, F_POLYMORPH, F_TELEPORT)
tt.pirate.fog_immortality = false
tt.pirate.spawn_animation = nil
tt.pirate.end_level_on_death = nil
tt.pirate.death_cage = {template = "blackthorne_prisoner_box_small", pos = v(768, 575), flip_x = true, delay = 1}
tt.info.portrait = "gui4_bottom_info_image_enemies_0136"

-- Boss 黑棘船长
tt = pirate_boss_template("blackthorne", "boss_blackthorne_unit", 15000, 5, v(0.5, 0.2), 65, "boss_blackthorne_unit_shadow", {shadow_y = 40})
tt.enemy.melee_slot = v(30, 0)
pirate_melee(tt, 75, 115, 1, 0.266, "attackA")
tt.melee.attacks[1].sound = "group_pirates_blackthorne_melee"
tt.pirate.cluster_bomb = {cooldown = 5, min_range = 50, max_range = 200, search_radius = 70, min_count = 2, count = 7, bullet = "enemy_blackthorne_cluster_bomb", fragment = "enemy_blackthorne_cluster_fragment", animation = "shoot", cast_time = 0.333}
tt.pirate.fly = {cooldown = 15, duration = 3, factor = 4, invulnerable_time = 0.5, safe_nodes_to_exit = 60, animation_in = "flyInit", animation = "flyWalk", animation_out = "flyEnd", delay_other_skills = 7}
tt.pirate.steal_gold = {cooldown = 12, preboss_cooldown = 40, min_gold = 350, fixed = 150, factor = 0.3, animation = "tiefIn", loop_animation = "tiefLoop", out_animation = "tiefOut", cast_time = 0.3, loop_time = 5, delay_other_skills = 7, parrot_fx = "blackthorne_coin_parrot", parrot_offset = v(70, 55)}
tt.pirate.kraken = {cooldown = 30, delay = 3, radius = 150, max_towers = 3, animation = "summonOut", cast_time = 0.5, delay_other_skills = 7}
tt.pirate.death_cage = {template = "blackthorne_prisoner_box_small", offset = v(0, -17), delay = 0.8}
tt.pirate.end_level_on_death = true
tt.info.portrait = "gui4_bottom_info_image_enemies_0137"

-- 场景控制器负责 Boss、酒馆/猴球、炮击、雾区时序和第191关四船长。
tt = RT("pirates_stage_controller", "decal_scripted")
tt.main_script.update = kr4_scripts.pirates_stage_controller.update
tt.level = 187
tt.render = nil

tt = RT("macaque_fruit_splash", "decal_scripted")
tt.main_script.update = kr4_scripts.macaque_fruit_splash.update
tt.duration = 3
tt.render.sprites[1].name = "macaque_fruit_splash01"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS + 100
tt.render.sprites[1].scale = v(2.5, 2.5)
tt.render.sprites[1].alpha = 220

tt = RT("fx_pirate_cannon_warning", "decal_scripted")
tt.main_script.update = kr4_scripts.macaque_fruit_splash.update
tt.duration = 5
tt.render.sprites[1].prefix = "cannon_sign"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_DECALS

tt = RT("fx_kr4_explosion_fragment", "fx_explosion_fragment")
tt.timed.duration = 1
tt.timed.runs = 1
tt.render.sprites[1].loop = false

-- 黑胡子炮船的水面层。其余船层由关卡图集中的现有动画直接组合。
tt = RT("stage37_ship_water_blackcorsair", "decal_scripted")
tt.render.sprites[1].prefix = "ship_water_blackcorsair"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_DECALS

-- 第 37 关战役模式中，黑胡子在第 15 波前一直站在旗舰上指挥炮击。
-- 英雄/钢铁模式使用不含 Boss 的 idleShip/signalShip 动画。
tt = RT("stage37_pirate_ship", "decal_scripted")
tt.main_script.update = kr4_scripts.stage37_pirate_ship.update
local ship_layers = {
	{"ship_blackcorsair_layer1", "idle", Z_OBJECTS},
	{"ship_blackcorsair_layer2", "idle", Z_OBJECTS + 1},
	{"ship_water_blackcorsair", "run", Z_OBJECTS - 3},
	{"ship_motor_blackcorsair", "run", Z_OBJECTS - 2},
	{"ship_escapes_blackcorsair", "run", Z_OBJECTS - 1},
	{"ship_vela_blackcorsair", "run", Z_OBJECTS + 2},
	{"ship_cannonsback_blackcorsair", "idle", Z_OBJECTS - 1},
	{"ship_cannons_blackcorsair", "idle", Z_OBJECTS + 2}
}
for i, cfg in ipairs(ship_layers) do
	if i > 1 then tt.render.sprites[i] = E:clone_c("sprite") end
	tt.render.sprites[i].prefix = cfg[1]
	tt.render.sprites[i].name = cfg[2]
	tt.render.sprites[i].anchor = v(0.5, 0.222)
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].z = cfg[3]
end

tt = RT("stage38_boss_macaque", "decal_scripted")
for i = 1, 9 do
	if i > 1 then tt.render.sprites[i] = E:clone_c("sprite") end
	tt.render.sprites[i].prefix = "boss_macaque_ship_layer" .. i
	tt.render.sprites[i].name = "walk"
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].z = Z_OBJECTS
end

tt = RT("blackthorne_coin_parrot", "decal_scripted")
tt.main_script.update = kr4_scripts.blackthorne_coin_parrot.update
tt.loop_time = 5
tt.render.sprites[1].prefix = "boss_blackthorne_parrot_coin"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS + 20

local function blackthorne_box_template(name, size)
	local t = RT(name, "decal_scripted")
	t.main_script.update = kr4_scripts.blackthorne_prisoner_box.update
	t.sound = "krv_sfx_falling-cage-on-deathBoss"
	t.render.sprites[1].prefix = "shadow_veznans_prisoner_box_" .. size
	t.render.sprites[1].name = "run"
	t.render.sprites[1].animated = true
	t.render.sprites[1].z = Z_OBJECTS + 9
	for i = 1, 5 do
		local sid = i + 1
		t.render.sprites[sid] = E:clone_c("sprite")
		t.render.sprites[sid].prefix = "veznans_prisoner_box_" .. size .. "_layer" .. i
		t.render.sprites[sid].name = "run"
		t.render.sprites[sid].animated = true
		t.render.sprites[sid].z = Z_OBJECTS + 10
	end
	return t
end

blackthorne_box_template("blackthorne_prisoner_box_small", "small")
blackthorne_box_template("blackthorne_prisoner_box_big", "big")

tt = RT("stage39_deep_king_throne_scene", "decal_scripted")
tt.main_script.update = kr4_scripts.stage39_deep_king_scene.update
for i = 1, 5 do
	if i > 1 then tt.render.sprites[i] = E:clone_c("sprite") end
	tt.render.sprites[i].prefix = "boss_deep_king_throne_layer" .. i
	tt.render.sprites[i].name = "idle"
	tt.render.sprites[i].animated = true
	tt.render.sprites[i].anchor = v(0.5, 0.4828)
	tt.render.sprites[i].z = Z_OBJECTS + 2
end

tt = RT("stage39_deep_king_splash", "fx")
tt.render.sprites[1].name = "stage39_splash_path_in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS + 1

tt = RT("stage41_blackthorne_scene", "decal_scripted")
tt.main_script.update = kr4_scripts.stage41_blackthorne_scene.update
tt.loop_time = 5
tt.render.sprites[1].prefix = "boss_blackthorne_unit"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.2)
tt.render.sprites[1].z = Z_OBJECTS + 5
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "boss_blackthorne_unit_shadow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].offset = v(0, 40)
tt.render.sprites[2].z = Z_DECALS + 1

tt = RT("stage41_burst", "fx")
tt.render.sprites[1].name = "stage41_burst_burst"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS + 1

-- 场景交互与装饰模板。
local function pirate_decal(name, sprite_name, animated, z)
	local t = RT(name, "decal")
	t.render.sprites[1].name = sprite_name
	t.render.sprites[1].animated = animated or false
	t.render.sprites[1].z = z or Z_DECALS
	return t
end

pirate_decal("stage37_barrel1", "stage37_prop_animado_barril01_run", true)
pirate_decal("stage37_barrel1_shifted", "stage37_prop_animado_barril01_run", true)
pirate_decal("stage37_barrel2", "stage37_prop_animado_barril02_run", true)
pirate_decal("stage37_barrel2_shifted", "stage37_prop_animado_barril02_run", true)
pirate_decal("stage37_chicken1", "stage37_prop_animado_pollo01_run", true, Z_OBJECTS)
pirate_decal("stage37_chicken2", "stage37_prop_animado_pollo02_run", true, Z_OBJECTS)
pirate_decal("stage37_plank1", "stage37_prop_animado_tabla01_run", true)
pirate_decal("stage37_plank2", "stage37_prop_animado_tabla02_run", true)
pirate_decal("stage40_lightning", "stage_40_lightning_idle", true, Z_OBJECTS)
pirate_decal("stage40_sun_rays", "stage40_sunray", false, Z_DECALS)
pirate_decal("stage41_gold_shine", "stage41_gold_run", true, Z_OBJECTS)

-- KR4 stores these unopened stage 41 sites in the towers array.  They are
-- blocked holders, not decals; the stage controller replaces them with
-- regular holders when Blackthorne opens each route.
tt = RT("pirates_blocked", "tower_holder")
tt.tower_holder.blocked = true
tt.tower.can_be_mod = false
tt.ui.can_click = false
for _, sprite in ipairs(tt.render.sprites) do
	sprite.hidden = true
end

tt = RT("touch_garfio", "decal_scripted")
tt.render.sprites[1].prefix = "garfio_layer1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("monkey_three_heads", "decal_scripted")
tt.render.sprites[1].name = "achievement_mono_idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("touch_shark_achievement", "decal_scripted")
tt.render.sprites[1].name = "achievement_tiburon_idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("dlc_pirates_treasure_achievement", "decal_scripted")
tt.render.sprites[1].name = "achievement_cofre_idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS

---------------------------------------------------------
-- KR4 branches: Frozen North, China, Prehistoric and Hammerhold
---------------------------------------------------------

local branch_enemy_i18n_overrides = {
	alric = "ENEMY_ALRIC_ENCYC",
	apex_shard = "ENEMY_APEX_SHARD_ENCYC",
	apex_shard_gold = "ENEMY_APEX_SHARD_ENCYC",
	boss_dwarf_mecha = "ENEMY_BOSS_BOLGUR_ENCYC",

	draugr_gold = "ENEMY_DRAGUR",
	dragon_king_boss = "ENEMY_BOSS_DRAGON_KING_ENCYC",
	farmer_bucket = "ENEMY_FARMER_ENCYC",
	farmer_mile = "ENEMY_FARMER_ENCYC",
	farmer_rake = "ENEMY_FARMER_ENCYC",
	farmer_rooster = "ENEMY_FARMER_ENCYC",
	farmer_scythe = "ENEMY_FARMER_ENCYC",
	high_sorcerer_sheep_fast = "ENEMY_SHEEP",
	carnival_dragon_body = "ENEMY_CARNIVAL",
	carnival_dragon_head = "ENEMY_CARNIVAL",
	kr4_screecher_bat = "ENEMY_SCREECHER_BAT",
	charly = "ENEMY_CAVE_DWARF",
	ice_golem = "ENEMY_SNOW_GOLEM_ENCYC",
	lightseeker = "ENEMY_LIGHTSEEKER_ENCYC",
	pterodactyl_with_dwarf = "ENEMY_PTERODACTYL",
	legionnaire = "ENEMY_LEGGIONAIRE",
	legion_nomad = "ENEMY_NOMAD",
	djini = "ENEMY_DJINNI",
	lord_of_afterlife = "ENEMY_BOSS_ANCIENT_GHOST_ENCYC",
	lord_of_afterlife_2 = "ENEMY_BOSS_ANCIENT_GHOST_ENCYC",
	boss_great_t = "ENEMY_BOSS_GREAT_T_ENCYC",
	malik = "ENEMY_MALIK_ENCYC",
	mega_boss_dragon = "ENEMY_BOSS_JOKULL_ENCYC",
	mega_knight = "ENEMY_MEGA_KNIGHT_ENCYC",
	mirage_path = "ENEMY_MIRAGE_ENCYC",
	mirage_clon = "ENEMY_MIRAGE",
	stonebeard_geomancer = "ENEMY_STONEBEARD_GEOMANCER_ENCYC",
	winter_queen = "ENEMY_BOSS_WINTER_QUEEN_ENCYC"
}

local branch_enemy_enc_icons = {
	alric = 113,
	apex_shard = 53,
	apex_shard_gold = 53,
	apex_stalker = 36,
	arcane_magus = 31,
	assassin = 108,
	banner_bearer = 27,
	blue_wyvern = 24,
	boss_dwarf_mecha = 84,
	boss_great_t = 92,
	camel_rider = 101,
	carnival_dragon_body = 79,
	carnival_dragon_head = 79,
	charly = 83,
	cyclopter_pilot = 13,
	desert_eagle = 106,
	devoted_priest = 32,
	djini = 103,
	dragon_king_boss = 90,
	draugr_gold = 17,
	elephant_lancer = 110,
	elite_footman = 26,
	elven_warrior = 46,
	falconeer = 105,
	farmer_bucket = 39,
	farmer_mile = 40,
	farmer_rake = 41,
	farmer_rooster = 42,
	farmer_scythe = 41,
	footman = 25,
	frost_giant = 23,
	frozen_heart = 66,
	frozen_soul = 67,
	frozen_soul_only = 67,
	glacial_wolf = 22,
	golem_house = 52,
	griffin_bombardier = 35,
	guardian_eagle = 55,
	high_sorcerer = 34,
	hunting_dog = 54,
	ice_golem = 65,
	ice_reaper = 68,
	ice_witch = 20,
	knight_rider = 33,
	kr4_screecher_bat = 75,
	leap_dragon = 37,
	legion_archer = 100,
	legion_nomad = 102,
	legionnaire = 99,
	lightseeker = 48,
	lord_of_afterlife = 89,
	lord_of_afterlife_2 = 91,
	magic_carpet = 104,
	malik = 93,
	mechadwarf = 12,
	mega_boss_dragon = 85,
	mega_knight = 86,
	mirage_clon = 111,
	mirage_path = 111,
	mogwai = 77,
	musketeer = 28,
	nanoq_warbear = 19,
	nian = 78,
	northern_berserker = 18,
	northern_huntress = 14,
	northern_wildling = 15,
	paladin = 30,
	prehistoric_dwarf = 80,
	pterodactyl = 82,
	pterodactyl_with_dwarf = 82,
	quarry_worker = 6,
	sand_mysthic = 107,
	smokebeard_engineer = 7,
	stonebeard_geomancer = 11,
	sulfur_alchemist = 10,
	svell_druid = 21,
	tinbeard_gunman = 9,
	tower_shield_knight = 29,
	valkyrie = 16,
	velociraptor = 81,
	war_elephant = 109,
	war_wagon = 57,
	winter_lord = 69,
	winter_queen = 88
}

local function branch_enemy_template(name, prefix, hp, armor, magic_armor, speed, gold, lives, anchor_y_value, bar_y, shadow, options)
	local t = RT("enemy_" .. name, "enemy")
	options = options or {}
	t.enemy.gold = gold or 0
	t.enemy.lives_cost = lives or 1
	t.enemy.melee_slot = v(options.melee_slot or 20, 0)
	t.health.hp_max = hp
	t.health.armor = armor or 0
	t.health.magic_armor = magic_armor or 0
	t.health_bar.offset = v(0, bar_y or 35)
	t.health_bar.type = options.boss and HEALTH_BAR_SIZE_MEDIUM or (bar_y and bar_y >= 48 and HEALTH_BAR_SIZE_MEDIUM_LARGE or HEALTH_BAR_SIZE_SMALL)
	t.info.i18n_key = options.i18n_key or branch_enemy_i18n_overrides[name] or "ENEMY_" .. string.upper(name)
	t.info.enc_icon = options.enc_icon or branch_enemy_enc_icons[name]
	if options.enc_icon_offset ~= nil then
		t.info.enc_icon_offset = options.enc_icon_offset
	elseif options.enc_icon_absolute then
		t.info.enc_icon_offset = 0
	end
	t.info.fn = kr4_scripts.branch_enemy.get_info
	t.motion.max_speed = speed or 0
	t.render.sprites[1].prefix = prefix
	t.render.sprites[1].anchor = v(0.5, anchor_y_value or 0.2)
	t.render.sprites[1].angles.walk = options.single_walk and {"walk", "walk", "walk"} or {"walk", "walkUp", "walkDown"}
	t.render.sprites[1].animated = true
	if options.exo then
		t.render.sprites[1].exo = true
	end
	if shadow and not options.flying then
		t.render.sprites[2] = E:clone_c("sprite")
		t.render.sprites[2].animated = false
		t.render.sprites[2].is_shadow = true
		t.render.sprites[2].name = shadow
		t.render.sprites[2].anchor = v(0.5, anchor_y_value or 0.2)
		t.render.sprites[2].offset = v(0, (options.shadow_y or 0))
		t.render.sprites[2].z = Z_DECALS + 1
	end
	t.unit.hit_offset = v(0, options.hit_y or math.floor((bar_y or 35) * 0.42))
	t.unit.mod_offset = v(0, options.mod_y or math.floor((bar_y or 35) * 0.45))
	t.unit.head_offset = v(0, options.head_y or bar_y or 35)
	t.ui.click_rect = r(-math.max(20, options.click_w or 22), 0, math.max(40, (options.click_w or 22) * 2), bar_y or 35)
	t.vis.flags = bor(F_ENEMY, options.flying and F_FLYING or 0, options.boss and F_BOSS or 0)
	if options.unblockable or options.flying then
		t.vis.bans = bor(t.vis.bans, F_BLOCK)
	end
	t.main_script.insert = scripts.enemy_basic.insert
	t.main_script.update = kr4_scripts.branch_enemy.update
	t.branch = options
	return t
end

local function branch_add_layered_sprites(t, prefix, count, anchor, offset, z)
	for i = 1, count do
		if i > 1 then
			t.render.sprites[i] = E:clone_c("sprite")
		end
		t.render.sprites[i].prefix = prefix .. i
		t.render.sprites[i].name = "idle"
		t.render.sprites[i].animated = true
		t.render.sprites[i].anchor = anchor or v(0.5, 0.5)
		t.render.sprites[i].offset = offset or v(0, 0)
		t.render.sprites[i].z = z or Z_OBJECTS
		t.render.sprites[i].draw_order = i
	end
end

local function branch_melee(t, damage_min, damage_max, cooldown, hit_time, animation, damage_type)
	AC(t, "melee")
	local a = t.melee.attacks[1]
	a.animation = animation or "attack"
	a.cooldown = cooldown or 1
	a.damage_min = damage_min
	a.damage_max = damage_max
	a.damage_type = damage_type or DAMAGE_PHYSICAL
	a.hit_time = hit_time or 0.3
	a.vis_flags = F_BLOCK
	a.vis_bans = bor(F_ENEMY, F_FLYING)
	if t.branch and t.branch.area_melee then
		a.type = "area"
		a.damage_radius = t.branch.area_melee
		a.count = t.branch.area_melee_max_count or 99
		a.hit_offset = t.branch.area_melee_hit_offset
	end
	return a
end

-- Frozen branch.
tt = branch_enemy_template("apex_shard_gold", "apex_shard", 80, 0, 0.8, 80, 6, 1, 0.35, 30, "apex_shard_shadow", {spawn_animation = "spawn"})
branch_melee(tt, 12, 18, 0.5, 0.3)

tt = RT("enemy_apex_shard", "enemy_apex_shard_gold")
tt.enemy.gold = 0

tt = branch_enemy_template("apex_stalker", "apex_stalker", 300, 0, 0.8, 65, 40, 2, 0.3, 37, "apex_stalker_shadow", {death_spawn = "enemy_apex_shard", devour_heal = 225})
branch_melee(tt, 20, 25, 0.5, 0.3)

tt = branch_enemy_template("draugr_gold", "draugr", 150, 0, 0.8, 24, 10, 1, 0.24, 35, "draugr_shadow", {spawn_animation = "respawn"})
branch_melee(tt, 6, 9, 1.2, 0.37)

tt = RT("enemy_draugr_summoned", "enemy_draugr_gold")
tt.enemy.gold = 0

tt = branch_enemy_template("frost_giant", "frost_giant", 1400, 0.6, 0, 20, 90, 2, 0.21, 64, "frost_giant_shadow", {melee_slot = 33, click_w = 35})
branch_melee(tt, 125, 150, 2, 0.5)

tt = branch_enemy_template("frozen_heart", "frozen_heart", 1000, 0, 0, 13, 0, 2, 0.275, 44, "frozen_heart_shadow", {death_spawn = "enemy_frozen_soul", spawn_animation = "spawn", melee_slot = 25})
branch_melee(tt, 35, 45, 1, 0.5)

tt = branch_enemy_template("frozen_soul", "frozen_soul", 180, 0.85, 0, 18, 90, 1, 0.222, 37, "frozen_soul_shadow", {unblockable = true, single_walk = true, revive = "enemy_frozen_heart", revive_after = 8, revive_safe_nodes = 60, revive_animation = "respawn", revive_sound = "ice_frozen_soul_rebirth", revive_delay_after = 2})
tt.vis.bans = bor(tt.vis.bans, F_STUN, F_SLOW, F_POISON, F_POLYMORPH)
tt.sound_events.death = nil

tt = RT("enemy_frozen_soul_only", "enemy_frozen_soul")
tt.health.hp_max = 200
tt.health.armor = 1
tt.motion.max_speed = 24
tt.enemy.gold = 26
tt.branch.revive = nil

tt = branch_enemy_template("ice_reaper", "ice_reaper", 450, 0, 0.6, 50, 55, 1, 0.116, 38, "ice_reaper_shadow", {kill_spawn = "enemy_apex_shard", spawn_animation = "spawn"})
branch_melee(tt, 50, 70, 0.5, 0.433)

tt = branch_enemy_template("ice_witch", "ice_witch", 250, 0, 0.8, 24, 50, 1, 0.18, 34, "ice_witch_shadow", {ranged = {stand_ground = true, cooldown = 2, min_range = 25, max_range = 150, damage_min = 15, damage_max = 20, damage_type = DAMAGE_MAGICAL, animation = "shoot", hit_time = 0.36, freeze = 2, projectile = "branch_projectile_ice_witch"}, spawn = {cooldown = 8, count = 1, template = "enemy_apex_shard", animation = "summon"}})
tt.sound_events.death = nil
branch_melee(tt, 12, 18, 2, 0.266)

tt = branch_enemy_template("svell_druid", "svell_druid", 550, 0, 0.6, 20, 50, 2, 0.225, 33, "svell_druid_shadow", {ranged = {no_melee = true, cooldown = 3, min_range = 50, max_range = 175, damage_min = 20, damage_max = 30, damage_type = DAMAGE_MAGICAL, animation = "attackRanged", hit_time = 0.4, projectile = "branch_projectile_svell_druid"}, tower_block = {cooldown = 12, range = 150, duration = 6, animation = "special", mod = "mod_branch_tower_block_frost"}})
branch_melee(tt, 20, 30, 1, 0.47)

tt = branch_enemy_template("winter_lord", "winter_lord", 900, 0.85, 0, 30, 100, 1, 0.15, 43, "winter_lord_shadow", {swap_armor = {interval = 15, armor = 0.85, magic_armor = 0.85, physical_sprite = 3, magic_sprite = 4}})
branch_melee(tt, 50, 70, 3, 0.466)
tt.melee.attacks[1].mod = "mod_branch_winter_dot"
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "winter_lord_fisical_shield"
tt.render.sprites[3].name = "loop"
tt.render.sprites[3].animated = true
tt.render.sprites[3].anchor = v(0.5, 0.15)
tt.render.sprites[3].offset = v(0, 0)
tt.render.sprites[3].hidden = true
tt.render.sprites[3].z = Z_OBJECTS + 1
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "winter_lord_magic_shield"
tt.render.sprites[4].name = "loop"
tt.render.sprites[4].animated = true
tt.render.sprites[4].anchor = v(0.5, 0.15)
tt.render.sprites[4].offset = v(0, 0)
tt.render.sprites[4].hidden = true
tt.render.sprites[4].z = Z_OBJECTS + 1

-- KR4 main campaign: dwarves and northern barbarians.
tt = branch_enemy_template("cyclopter_pilot", "dwarf_flyer", 40, 0, 0, 55, 6, 1, 0.037, 92, nil, {flying = true, unblockable = true, single_walk = true, hit_y = 57, mod_y = 60, head_y = 75})
kr4_add_enemy_shadow(tt, "dwarf_flyer_shadow", 0.037)

tt = branch_enemy_template("smokebeard_engineer", "smokebeard_engineer", 240, 0.4, 0, 36, 24, 1, 0.15, 40, "smokebeard_engineer_shadow", {repair = {dead_only = true, interrupt_on_block = true, break_on_interrupt = true, cooldown = 4, range = 105, factor = 1, hp_factors = {enemy_chomp_bot = 1, enemy_clockwork_spider = 1, enemy_mechadwarf = 0.25}, max_targets = 1, animation = "repair", loop_animation = "repairLoop", end_animation = "repairEnd", cast_time = 5, delete_after_grace = 1, projectile = "branch_projectile_smokebeard_repair", ray_interval = 0.45, shoot_offset = v(4, 42), flight_time = fts(8), g = 0, sound = "dwarves_smokebeard_repair", targets = {enemy_chomp_bot = true, enemy_clockwork_spider = true, enemy_mechadwarf = true}}})
branch_melee(tt, 8, 12, 1, 0.23)

tt = branch_enemy_template("mechadwarf", "mechadwarf", 1200, 0.7, 0, 18, 80, 2, 0.13, 57, "mechadwarf_shadow", {melee_slot = 32, click_w = 38})
tt.health.dead_lifetime = 9
tt.health.on_damage = kr4_scripts.branch_enemy.on_repairable_damage
tt.repairable_death = {
	dead_lifetime = 9,
	disabled_animation = "death",
	destroyed_animation = "death",
	destroyed_lifetime = 2,
	no_repair_damage_types = bor(DAMAGE_EXPLOSION, DAMAGE_FX_EXPLODE, DAMAGE_DISINTEGRATE, DAMAGE_DISINTEGRATE_BOSS, DAMAGE_EAT, DAMAGE_NO_SPAWNS)
}
tt.unit.blood_color = BLOOD_NONE
branch_melee(tt, 40, 60, 1.2, 0.75)
tt.melee.attacks[1].area_attack = {cooldown = 12, radius = 45, max_count = 8, damage_min = 80, damage_max = 80, animation = "specialAttack", hit_time = 0.9, sound = "dwarves_mechadwarf_impact"}

tt = branch_enemy_template("blue_wyvern", "blue_wyvern", 100, 0, 0, 60, 14, 1, 0.04, 92, nil, {flying = true, unblockable = true, single_walk = true, hit_y = 58, mod_y = 53, head_y = 85})
kr4_add_enemy_shadow(tt, "blue_wyvern_shadow", 0.04)
tt.sound_events.death = "barbarians_wyvern_death"

tt = branch_enemy_template("glacial_wolf", "glacial_wolf", 110, 0, 0.6, 70, 10, 1, 0.23, 41, "glacial_wolf_shadow", {death_freeze = {chance = 0.3, range = 30, duration = 2, max_targets = 2}})
branch_melee(tt, 8, 12, 0.6, 0.4)

tt = branch_enemy_template("northern_huntress", "northern_huntress", 120, 0, 0, 36, 10, 1, 0.1, 30, "northern_huntress_shadow", {ranged = {stand_ground = true, cooldown = 0.5, min_range = 25, max_range = 125, damage_min = 8, damage_max = 10, damage_type = DAMAGE_PHYSICAL, animation = "special", hit_time = 0.3, count = 2, projectile = "branch_projectile_northern_huntress"}})
tt.sound_events.death = nil
branch_melee(tt, 4, 7, 0.5, 0.3)

tt = branch_enemy_template("northern_wildling", "northern_wildling", 125, 0.2, 0, 33, 12, 1, 0.16, 37, "northern_wildling_shadow", {})
branch_melee(tt, 12, 18, 1, 0.33)

tt = branch_enemy_template("nanoq_warbear", "nanoq_warbear", 750, 0.6, 0, 24, 65, 2, 0.16, 47, "nanoq_warbear_shadow", {charge = {cooldown = 7, duration = 4, factor = 2.1, safe_nodes_to_exit = 60, animation = "chargeWalk"}})
branch_melee(tt, 40, 60, 1.2, 0.3)

tt = branch_enemy_template("northern_berserker", "northern_berserker", 450, 0, 0, 36, 30, 1, 0.21, 40, "northern_berserker_shadow", {area_melee = 60})
branch_melee(tt, 36, 48, 1.2, 0.53, "attackArea")
tt.melee.attacks[1].area_attack = {cooldown = 1.2, radius = 60, max_count = 99, damage_min = 36, damage_max = 48, animation = "attackArea", hit_time = 0.53}

tt = branch_enemy_template("leap_dragon", "leap_dragon", 220, 0.4, 0, 39, 20, 1, 0.085, 52, "leap_dragon_shadow", {fly = {cooldown = 5, duration = 2, factor = 1.8, safe_nodes_to_exit = 60, animation_in = "flyInit", animation = "flyWalk", animation_out = "flyEnd", death_animation = "flyDeath"}})
branch_melee(tt, 18, 26, 1, 0.37)

tt = branch_enemy_template("valkyrie", "valkyrie", 400, 0.7, 0, 36, 35, 1, 0.2, 39, "valkyrie_shadow", {area_spawn_dead = {cooldown = 1, range = 100, max_targets = 3, template = "enemy_draugr_summoned", zero_gold = true, includes = {enemy_northern_wildling = true, enemy_northern_huntress = true, enemy_northern_berserker = true}, animation = "summon", cast_time = 0.4, sound = "barbarians_valkyrie_summon"}})
tt.sound_events.death = nil
branch_melee(tt, 28, 42, 1, 0.366)

-- Linirea units reused by the China branch.
tt = branch_enemy_template("footman", "farmer", 200, 0, 0, 36, 16, 1, 0.2, 30, "linirea_farmer_shadow", {})
branch_melee(tt, 13, 19, 1, 0.3)

tt = branch_enemy_template("elite_footman", "linirea_soldier", 270, 0.3, 0, 36, 24, 1, 0.2, 30, "linirea_soldier_shadow", {spawn_animation = "toSoldier"})
branch_melee(tt, 15, 25, 1, 0.3)

tt = branch_enemy_template("banner_bearer", "linirea_banner_soldier", 500, 0.6, 0, 24, 36, 1, 0.207, 37, "linirea_banner_soldier_shadow", {transform_unit = {cooldown = 6, range = 110, from = "enemy_footman", to = "enemy_elite_footman", max_targets = 1, animation = "special", cast_time = 0.3, sound = "linirea_banner_bearer_cry", result_sound = "linirea_elite_footman_improve"}})
branch_melee(tt, 30, 45, 1, 0.43, "attackSword")

tt = branch_enemy_template("guardian_eagle", "hunting_eagle", 90, 0, 0, 66, 10, 1, 0.03, 80, nil, {flying = true, unblockable = true, single_walk = true, hit_y = 57, mod_y = 53, head_y = 70})

tt = branch_enemy_template("hunting_dog", "watchdog", 80, 0, 0.3, 84, 12, 1, 0.2, 26, "watchdog_shadow", {})
branch_melee(tt, 14, 22, 1, 0.33)

tt = branch_enemy_template("devoted_priest", "devoted_priest", 250, 0, 0.5, 36, 45, 1, 0.08, 30, "devoted_priest_shadow", {heal = {cooldown = 3, range = 90, factor = 0.15, max_targets = 3, animation = "cast"}, armor_aura = {range = 75, magic = 0.5}})
tt.sound_events.death = nil
branch_melee(tt, 2, 4, 1, 0.4)

tt = branch_enemy_template("elven_warrior", "elven_warrior", 300, 0, 0.3, 42, 40, 1, 0.267, 33, "elven_warrior_shadow", {spawn_animation = "spawn", ranged = {stand_ground = true, cooldown = 1.5, min_range = 50, max_range = 175, damage_min = 5, damage_max = 10, damage_type = DAMAGE_PHYSICAL, animation = "shootPrep", followup_animation = "multiShoot", end_animation = "shootEnd", shot_interval = 0.167, hit_time = 0.3, count = 3, projectile = "branch_projectile_elven_warrior"}})
tt.unit.death_animation = "death"
branch_melee(tt, 26, 38, 1, 0.433, "hit1")

tt = branch_enemy_template("griffin_bombardier", "gryphon", 280, 0, 0, 33, 30, 1, 0.4, 112, nil, {flying = true, unblockable = true, hit_y = 67, mod_y = 64, head_y = 105})
tt.flight_height = 50
tt.animation_group = "layers"
tt.render.sprites[1].prefix = "gryphon_layer1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].group = tt.animation_group
tt.render.sprites[1].offset = v(0, tt.flight_height)
tt.render.sprites[1].draw_order = 1
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "gryphon_guy"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].animated = true
tt.render.sprites[2].anchor = v(0.5, 0.013)
tt.render.sprites[2].offset = v(-5, tt.flight_height + 20)
tt.render.sprites[2].z = tt.render.sprites[1].z
tt.render.sprites[2].angles = {}
tt.render.sprites[2].angles.walk = tt.render.sprites[1].angles.walk
tt.render.sprites[2].group = tt.animation_group
tt.render.sprites[2].draw_order = 2
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "gryphon_front"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].animated = true
tt.render.sprites[3].anchor = tt.render.sprites[1].anchor
tt.render.sprites[3].offset = tt.render.sprites[1].offset
tt.render.sprites[3].z = tt.render.sprites[1].z
tt.render.sprites[3].angles = {}
tt.render.sprites[3].angles.walk = tt.render.sprites[1].angles.walk
tt.render.sprites[3].group = tt.animation_group
tt.render.sprites[3].draw_order = 3
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].is_shadow = true
tt.render.sprites[4].animated = false
tt.render.sprites[4].name = "gryphon_shadow"
tt.render.sprites[4].anchor = v(0.5, 0.4)
tt.render.sprites[4].offset = v(0, 0)
tt.render.sprites[4].z = Z_DECALS + 1
tt.branch.ranged = {stand_ground = true, cooldown = 0.8, min_range = 0, max_range = 120, radius = 55, max_count = 8, damage_min = 15, damage_max = 30, damage_type = DAMAGE_EXPLOSION, animation = "shoot", sprite_ids = {2}, hit_time = 0.33, projectile = "branch_projectile_griffin_bombardier", shoot_offset = v(4, tt.flight_height + 40), flight_time = fts(16), g = -1, sound = "BombShootSound"}
tt.branch.layer_offsets = {
	[2] = {
		leftright = v(-5, tt.flight_height + 20),
		up = v(0, tt.flight_height + 28),
		down = v(0, tt.flight_height + 27)
	}
}

tt = branch_enemy_template("arcane_magus", "arcane_magus", 550, 0, 0.8, 33, 60, 1, 0.25, 32, "arcane_magus_shadow", {teleport_allies = {cooldown = 8, target_cooldown = 8, range = 50, nodes = 25, min_targets = 4, max_targets = 10, safe_nodes_to_exit = 90, animation = "teleport", excludes = {enemy_high_sorcerer = true, enemy_mega_knight = true, enemy_golem_house = true}}, ranged = {cooldown = 3, min_range = 25, max_range = 175, radius = 30, damage_min = 14, damage_max = 21, damage_type = DAMAGE_MAGICAL, animation = "shoot", hit_time = 0.3, projectile = "branch_projectile_arcane_magus"}})
branch_melee(tt, 12, 24, 1, 0.3)

tt = branch_enemy_template("high_sorcerer", "high_sorcerer", 1750, 0.6, 0, 18, 120, 2, 0.156, 69, "high_sorcerer_shadow", {polymorph = {cooldown = 20, range = 150, duration = 10, max_targets = 1, animation = "special", instakill = true, sheep_template = "enemy_high_sorcerer_sheep_fast", safe_nodes_to_exit = 50}, area_melee = 60, melee_slot = 32, click_w = 34})
branch_melee(tt, 60, 90, 1.4, 0.567)
tt.melee.attacks[1].area_attack = {cooldown = 1.4, radius = 60, max_count = 8, damage_min = 60, damage_max = 90, animation = "attack", hit_time = 0.567}
tt.melee.attacks[1].disabled = true

tt = branch_enemy_template("high_sorcerer_sheep_fast", "high_sorcerer_sheep", 80, 0, 0, 65, 0, 1, 0.2, 28, nil, {unblockable = true, single_walk = true})
kr4_add_enemy_shadow(tt, "high_sorcerer_sheep_shadow", 0.2)
tt.sound_events.death = "linirea_high_sorcerer_sheep_explode"
tt.vis.bans = bor(tt.vis.bans, F_BLOCK, F_STUN, F_SLOW, F_POISON, F_POLYMORPH)
tt = RT("enemy_high_sorcerer_sheep2", "enemy_high_sorcerer_sheep_fast")
tt.motion.max_speed = 36

tt = branch_enemy_template("musketeer", "musketeer", 180, 0, 0, 36, 18, 1, 0.435, 30, "musketeer_shadow", {ranged = {cooldown = 1.2, min_range = 0, max_range = 100, damage_min = 30, damage_max = 45, damage_type = DAMAGE_PHYSICAL, animation = "shootLateral", hit_time = 0.57, projectile = "branch_projectile_musketeer", flight_time = fts(8)}, snipe = {cooldown = 5, min_range = 105, max_range = 325, damage_min = 90, damage_max = 120, damage_type = DAMAGE_PHYSICAL, animation = "specialLateral", hit_time = 0.833, projectile = "branch_projectile_musketeer", flight_time = fts(6)}})
branch_melee(tt, 8, 12, 1, 0.3)

tt = branch_enemy_template("paladin", "paladin", 750, 0, 0.6, 30, 50, 1, 0.211, 39, "paladin_shadow", {area_attack = {cooldown = 5, radius = 60, max_count = 5, damage_min = 70, damage_max = 90, animation = "groundAttack", hit_time = 0.433}})
branch_melee(tt, 36, 54, 1, 0.4, "specialAttack1")
tt.melee.attacks[1].area_attack = tt.branch.area_attack

tt = branch_enemy_template("mega_knight", "imperial_guard", 4500, 0.6, 0.4, 36, 250, 20, 0.156, 80, nil, {exo = true, boss = true, single_walk = true, melee_slot = 33, click_w = 50, end_level_on_last_of_template = true})
branch_melee(tt, 160, 180, 1, 0.733, "attack", DAMAGE_EXPLOSION)
tt.melee.attacks[1].area_attack = {cooldown = 1, radius = 120, max_count = 8, damage_min = 160, damage_max = 180, damage_type = DAMAGE_EXPLOSION, animation = "attack", hit_time = 0.733, sound = "linirea_mega_knight_attack"}
tt.sound_events.death = "linirea_mega_knight_death"

tt = branch_enemy_template("tower_shield_knight", "tower_shield_knight", 1000, 0.9, 0, 25, 80, 1, 0.213, 46, "tower_shield_knight_shadow", {shield_drop_on_melee = 0.3})
branch_melee(tt, 40, 50, 1.3, 0.433)

tt = branch_enemy_template("war_wagon", "war_wagon_layer1", 800, 0, 0, 14, 100, 2, 0.2, 48, nil, {unblockable = true, hit_y = 24, mod_y = 26, head_y = 44, click_w = 45, spawn = {passive = true, cooldown = 9, count = 3, template = "enemy_footman", safe_nodes_to_exit = 60, node_gap = 2, zero_gold = true}})
tt.animation_group = "layers"
branch_add_layered_sprites(tt, "war_wagon_layer", 11, v(0.5, 0.2), v(0, 0), Z_OBJECTS)
for i = 1, 11 do
	tt.render.sprites[i].group = tt.animation_group
	tt.render.sprites[i].name = "walk"
	tt.render.sprites[i].angles = {}
	tt.render.sprites[i].angles.walk = {"walk", "walkUp", "walkDown"}
end
tt.render.sprites[12] = E:clone_c("sprite")
tt.render.sprites[12].animated = false
tt.render.sprites[12].is_shadow = true
tt.render.sprites[12].name = "war_wagon_shadow"
tt.render.sprites[12].anchor = v(0.5, 0.2)
tt.render.sprites[12].offset = v(0, 0)
tt.render.sprites[12].z = Z_DECALS + 1

-- China branch.
tt = branch_enemy_template("mogwai", "mogwai", 40, 0, 0, 65, 5, 1, 0.355, 30, "mogwai_shadow", {water_duplicate = "enemy_mogwai2", spawn_animation = "spawn"})
branch_melee(tt, 8, 12, 1, 0.466)
tt = RT("enemy_mogwai2", "enemy_mogwai")
tt.enemy.gold = 0
tt.branch.water_duplicate = "enemy_mogwai3"
tt = RT("enemy_mogwai3", "enemy_mogwai")
tt.enemy.gold = 0
tt.branch.water_duplicate = nil

tt = branch_enemy_template("nian", "nian", 800, 0, 0.3, 65, 90, 1, 0.21, 41, "nian_shadow", {water_regen = 100})
branch_melee(tt, 30, 40, 1, 0.4)
tt.sound_events.death = nil

tt = branch_enemy_template("carnival_dragon_body", "carnival_dragon_body", 400, 0, 0, 15, 15, 1, 0.164, 40, "carnival_dragon_body_shadow", {unblockable = true})
tt.vis.bans = bor(tt.vis.bans, F_STUN, F_SLOW, F_POISON, F_POLYMORPH)
tt = branch_enemy_template("carnival_dragon_head", "carnival_dragon_head", 850, 0, 0, 15, 40, 2, 0.1, 55, "carnival_dragon_head_shadow", {unblockable = true})
tt.vis.bans = bor(tt.vis.bans, F_STUN, F_SLOW, F_POISON, F_POLYMORPH)

-- KR4 Halloween units that collide with existing KR3 templates use an explicit prefix.

tt = branch_enemy_template("kr4_screecher_bat", "screecher_bat", 120, 0, 0, 60, 14, 1, 0.2, 90, nil, {flying = true, unblockable = true, single_walk = true, stun = {cooldown = 5, range = 50, duration = 6, animation = "attack"}})

-- Prehistoric branch.
tt = branch_enemy_template("quarry_worker", "quarry_worker", 80, 0, 0, 30, 8, 1, 0.243, 36, "quarry_worker_shadow", {buried = {cooldown = 8, duration = 2, factor = 3, animation = "buriedWalk", animation_in = "buriedIn", animation_out = "buriedOut"}})
branch_melee(tt, 10, 14, 1, 0.27)
tt.info.portrait = "gui4_bottom_info_image_enemies_0006"

tt = branch_enemy_template("stonebeard_geomancer", "stonebeard_geomancer", 500, 0, 0, 21, 50, 1, 0.117, 44, "stonebeard_geomancer_shadow", {
	melee_armor = 0.8,
	transform_on_melee = {factor = 3.3007407407407407, animation_in = "toStone", animation_out = "toDwarf", idle_animation = "idleBlock", sound = "dwarves_geomancer_transform"}
})
branch_melee(tt, 34, 50, 1.2, 0.33)
tt.info.portrait = "gui4_bottom_info_image_enemies_0011"

tt = branch_enemy_template("sulfur_alchemist", "sulfur_alchemist", 160, 0, 0.8, 33, 16, 1, 0.13, 38, "sulfur_alchemist_shadow", {ranged = {cooldown = 1.5, min_range = 50, max_range = 150, damage_min = 16, damage_max = 24, damage_type = DAMAGE_PHYSICAL, animation = "shootPoison", hit_time = 0.67, projectile = "branch_projectile_sulfur_alchemist"}, heal = {cooldown = 5, range = 150, hp_threshold = 0.75, max_targets = 1, animation = "shoot", cast_time = 0.63, projectile = "branch_projectile_sulfur_alchemist_heal", no_damage = true, mod = "mod_branch_heal", duration = 2, tick = 0.2, tick_heal = 2.5, excludes = {enemy_chomp_bot = true, enemy_clockwork_spider = true, enemy_mechadwarf = true}}})
branch_melee(tt, 5, 8, 1, 0.23)
tt.info.portrait = "gui4_bottom_info_image_enemies_0010"

tt = branch_enemy_template("tinbeard_gunman", "tinbeard_gunman", 120, 0, 0, 33, 12, 1, 0.21, 37, "tinbeard_gunman_shadow", {ranged = {cooldown = 1.3, min_range = 25, max_range = 150, damage_min = 20, damage_max = 30, damage_type = DAMAGE_PHYSICAL, animation = "shoot", hit_time = 0.83, projectile = "branch_projectile_tinbeard_gunman", flight_time = fts(8), g = 0, shoot_offset = v(4, 28)}})
branch_melee(tt, 9, 13, 2, 0.3)
tt.info.portrait = "gui4_bottom_info_image_enemies_0009"

tt = branch_enemy_template("charly", "caveman", 230, 0.2, 0, 33, 8, 1, 0.145, 30, "asst_caveman_shadow", {exo = true})
branch_melee(tt, 5, 7, 1, 0.33)
tt.info.portrait = "gui4_bottom_info_image_enemies_0092"

tt = branch_enemy_template("prehistoric_dwarf", "prehistoric_dwarf", 1700, 0, 0, 20, 85, 2, 0, 46, "asst_enanopreh_shadow", {exo = true, warcry = {cooldown = 10, range = 200, factor = 1.5, speed_factor = 1.3, hp_bonus = 85, duration = 5, animation = "warCry", targets = {enemy_velociraptor = true}, mod = "mod_branch_damage"}, melee_slot = 15})
tt.render.sprites[2].anchor = v(0.5, 0.5)
branch_melee(tt, 120, 150, 1.5, 0.33)
tt.info.portrait = "gui4_bottom_info_image_enemies_0089"

tt = branch_enemy_template("velociraptor", "velociraptor", 170, 0, 0, 115, 14, 1, 0.0985, 42, "asst_velocirraptor_shadow", {exo = true, instakill = {chance = 1, hp_ratio = 0.2, cooldown = 6, safe_nodes_to_exit = 30, animation = "eat", egg_template = "velociraptor_egg", egg_at_nest = true, sound = "velociraptor_nice_meal_attack", egg_sound = "velociraptor_nice_meal_egg"}, spawn_animation = "spawn", spawn_sound = "velociraptor_egg_spawn", melee_slot = 13})
tt.sound_events.death = nil
branch_melee(tt, 25, 45, 0.75, 0.3)
tt.info.portrait = "gui4_bottom_info_image_enemies_0088"

tt = branch_enemy_template("pterodactyl", "pterodactyl", 130, 0, 0, 57, 10, 1, 0.037, 98, nil, {exo = true, flying = true, unblockable = true, single_walk = true})
tt.info.portrait = "gui4_bottom_info_image_enemies_0090"

tt = branch_enemy_template("pterodactyl_with_dwarf", "pterodactyl_with_dwarf", 150, 0, 0, 44, 10, 1, 0.037, 98, nil, {exo = true, flying = true, unblockable = true, single_walk = true, death_spawn = "enemy_prehistoric_dwarf"})
tt.info.portrait = "gui4_bottom_info_image_enemies_0090"

-- Hammerhold branch.
tt = branch_enemy_template("legionnaire", "legionnaire", 280, 0, 0, 36, 7, 1, 0.2, 30, "hammerhold_soldier_shadow", {})
branch_melee(tt, 14, 22, 1, 0.3)
tt.info.portrait = "gui4_bottom_info_image_enemies_0093"

tt = branch_enemy_template("legion_archer", "legion_archer", 140, 0, 0, 39, 12, 1, 0.2, 30, "legion_archer_shadow", {ranged = {cooldown = 0.8, min_range = 25, max_range = 175, damage_min = 14, damage_max = 18, damage_type = DAMAGE_PHYSICAL, animation = "range", hit_time = 0.3, projectile = "branch_projectile_legion_archer"}})
branch_melee(tt, 8, 12, 1, 0.3)
tt.info.portrait = "gui4_bottom_info_image_enemies_0094"

tt = branch_enemy_template("hammerhold_citizen", "citizen_merchant", 30, 0, 0, 39, 12, 1, 0.125, 30, "citizen_merchant_shadow", {ranged = {stand_ground = true, cooldown = 0.7, min_range = 100, max_range = 280, damage_min = 8, damage_max = 12, damage_type = DAMAGE_PHYSICAL, animation = "range", hit_time = 0.42, projectile = "branch_projectile_legion_archer", shoot_offset = v(5, 17), flight_time = fts(15), g = -1}})
branch_melee(tt, 8, 12, 1, 0.43, "melee")
tt.info.portrait = "gui4_bottom_info_image_enemies_0106"

tt = branch_enemy_template("hammerhold_citizen_rugmerchant", "citizen_rugmerchant", 40, 0, 0, 39, 12, 1, 0.08, 32, "citizen_rugmerchant_shadow", {})
branch_melee(tt, 8, 12, 1, 0.3, "attack")
tt.info.portrait = "gui4_bottom_info_image_enemies_0104"

tt = branch_enemy_template("hammerhold_citizen_snakecharmer", "citizen_snakecharmer", 40, 0, 0, 39, 12, 1, 0.09, 32, "citizen_snakecharmer_shadow", {})
branch_melee(tt, 8, 12, 1, 1.06, "attack")
tt.info.portrait = "gui4_bottom_info_image_enemies_0105"

tt = branch_enemy_template("camel_rider", "camel_rider", 410, 0, 0, 60, 35, 2, 0.3, 60, "camel_rider_shadow", {death_spawn = "enemy_legionnaire", melee_slot = 20})
branch_melee(tt, 35, 50, 1.3, 0.5)
tt.info.portrait = "gui4_bottom_info_image_enemies_0095"

tt = branch_enemy_template("falconeer", "falconeer", 360, 0.4, 0, 36, 30, 1, 0.2, 42, "falconeer_shadow", {spawn_eagle = {cooldown = 1, range = 235, template = "enemy_desert_eagle", animation = "spawnEagle", max_alive = 1, once = true, prefix_on_spawn = "alone", idle_name = "aloneIdle", sound = "kr4_enemies_sandstorm_falconeer_bird"}})
branch_melee(tt, 30, 45, 1.5, 0.3, "aloneAttack")
tt.info.portrait = "gui4_bottom_info_image_enemies_0098"

tt = branch_enemy_template("desert_eagle", "desert_eagle", 60, 0, 0, 70, 0, 1, 0.45, 20, nil, {flying = true, unblockable = true, single_walk = true, ranged = {stand_ground = true, cooldown = 3, min_range = 0, max_range = 100, damage_min = 7, damage_max = 9, damage_type = DAMAGE_PHYSICAL, animation = "attack", hit_time = 0.16}})
tt.sound_events.death = "group_sandstorm_eagle_death"
tt.info.portrait = "gui4_bottom_info_image_enemies_0110"

tt = branch_enemy_template("legion_nomad", "nomad", 270, 0, 0, 60, 5, 1, 0.19, 30, "nomad_shadow", {ranged = {cooldown = 1.2, min_range = 25, max_range = 125, damage_min = 16, damage_max = 24, damage_type = DAMAGE_PHYSICAL, animation = "throwRight", hit_time = 0.35, projectile = "branch_projectile_legion_nomad", flight_time = fts(7)}, shadow_jump = {cooldown = 4, nodes = -15, safe_nodes_start = 20, safe_nodes_to_exit = 30, trigger_range = 125, require_target = true, walk_after = 0.35, animation_out = "shadowOut", animation_in = "shadowIn"}})
branch_melee(tt, 16, 24, 1, 0.53)
tt.info.portrait = "gui4_bottom_info_image_enemies_0102"

tt = branch_enemy_template("assassin", "assasin", 500, 0, 0, 50, 35, 1, 0.08, 34, "assasin_shadow", {dodge = 0.15, instakill = {chance = 0.15, animation = "instakill", vis_bans = F_HERO}})
branch_melee(tt, 26, 38, 0.97, 0.3)
tt.health.on_damage = kr4_scripts.branch_enemy.on_damage
tt.info.portrait = "gui4_bottom_info_image_enemies_0103"

tt = branch_enemy_template("magic_carpet", "magic_carpet", 320, 0, 0.5, 40, 25, 1, 0.23, 72, nil, {flying = true, unblockable = true, ranged = {cooldown = 4, min_range = 50, max_range = 120, radius = 60, min_targets = 2, damage_min = 48, damage_max = 72, damage_type = DAMAGE_EXPLOSION, animation = "attack", hit_time = 1.64, projectile = "branch_projectile_magic_carpet"}})
tt.info.portrait = "gui4_bottom_info_image_enemies_0104"

tt = branch_enemy_template("sand_mysthic", "sand_mysthic", 550, 0, 0.6, 27, 45, 1, 0.2, 37, "sand_mysthic_shadow", {ranged = {cooldown = 2, min_range = 45, max_range = 175, radius = 95, damage_min = 220, damage_max = 260, damage_type = DAMAGE_EXPLOSION, animation = "range", hit_time = 0.59, projectile = "branch_ray_sand_mysthic", projectile_sound = "group_sandstorm_mysthic_attack", shoot_offset = v(12, 41)}, heal = {cooldown = 7, range = 175, amount = 180, max_targets = 1, hp_threshold = 0.9, animation = "heal", cast_time = 0.7, sound = "kr4_enemies_sandstorm_sand_mysthic_heal", excludes = {enemy_war_wagon = true}}})
branch_melee(tt, 10, 16, 1, 0.4)
tt.info.portrait = "gui4_bottom_info_image_enemies_0100"

tt = branch_enemy_template("djini", "djini", 1350, 0, 0.9, 22, 60, 2, 0.315, 48, "djini_shadow", {polymorph = {cooldown = 1.3, range = 125, duration = 15, source_dead_min_duration = 5, max_targets = 5, animation = "polimorph", instakill = false}, tower_block = {cooldown = 40, range = 175, duration = 10, max_targets = 3, animation = "politower", mod = "mod_branch_tower_block_djini"}})
tt.info.portrait = "gui4_bottom_info_image_enemies_0096"

tt = branch_enemy_template("war_elephant", "war_elephant_drummer", 2800, 0.8, 0, 10, 225, 3, 0.1, 90, "war_elephant_drummer_shadow", {unblockable = true, boss = true, trample = {radius = 30, damage = 11, tick = 0.2}, drum_buff = {cooldown = 5, range = 125, min_targets = 2, max_targets = 10, animation = "playIn", loop_animation = "playLoop", end_animation = "playOut", sprite_ids = {2}, cast_time = 0.3, loop_time = 3, heal_mod = "mod_branch_war_elephant_heal", heal_duration = 2, heal_tick = 0.5, heal_amount = 15, speed_mod = "mod_branch_war_elephant_speed", speed_duration = 2, speed_factor = 1.5, sound = "kr4_enemies_sandstorm_elephant_drums", decal_fx = "fx_branch_war_elephant_drummer_decal", excludes = {enemy_war_elephant = true, enemy_elephant_lancer = true}}, click_w = 45})
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "war_elephant_drummer_only"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].animated = true
tt.render.sprites[2].anchor = v(0.5, 0.1)
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.render.sprites[2].draw_order = 2
tt.branch.layer_offsets = {
	[2] = {
		leftright = v(-16, 68),
		up = v(-16, 68),
		down = v(-16, 68)
	}
}
tt.sound_events.death = "kr4_enemies_sandstorm_elephant_death"
tt.info.portrait = "gui4_bottom_info_image_enemies_0102"

tt = branch_enemy_template("elephant_lancer", "war_elephant_archers", 2800, 0.8, 0, 10, 225, 3, 0.1, 90, "war_elephant_archers_shadow", {unblockable = true, boss = true, trample = {radius = 30, damage = 11, tick = 0.2}, ranged = {cooldown = 1.15, min_range = 25, max_range = 250, damage_min = 8, damage_max = 12, damage_type = DAMAGE_PHYSICAL, animation = "range", sprite_ids = {3, 4}, hit_time = 0.5, count = 2, projectile = "branch_projectile_legion_archer", shoot_offset = v(5, 70), flight_time = fts(15), g = -1, sound = "group_arrow_release_sound"}, click_w = 45})
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "war_elephant_archer_mount"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].animated = true
tt.render.sprites[2].anchor = v(0.5, 0.1)
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.render.sprites[2].draw_order = 2
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "war_elephant_archer_unit"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].animated = true
tt.render.sprites[3].anchor = v(0.5, 0.1)
tt.render.sprites[3].z = Z_OBJECTS + 2
tt.render.sprites[3].draw_order = 3
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].prefix = "war_elephant_archer_unit"
tt.render.sprites[4].name = "idle"
tt.render.sprites[4].animated = true
tt.render.sprites[4].anchor = v(0.5, 0.1)
tt.render.sprites[4].z = Z_OBJECTS + 2
tt.render.sprites[4].draw_order = 4
tt.branch.layer_offsets = {
	[2] = {
		leftright = v(-21, 53),
		up = v(-21, 53),
		down = v(-21, 53)
	},
	[3] = {
		leftright = v(-27, 56),
		up = v(-27, 56),
		down = v(-27, 56)
	},
	[4] = {
		leftright = v(-10, 56),
		up = v(-10, 56),
		down = v(-10, 56)
	}
}
tt.sound_events.death = "kr4_enemies_sandstorm_elephant_death"
tt.info.portrait = "gui4_bottom_info_image_enemies_0101"

-- Branch modifiers and level-scene objects.
tt = RT("mod_branch_freeze", "mod_stun")
tt.modifier.duration = 2

tt = RT("mod_branch_polymorph", "modifier")
AC(tt, "render")
tt.main_script.insert = kr4_scripts.mod_branch_polymorph.insert
tt.main_script.remove = kr4_scripts.mod_branch_polymorph.remove
tt.main_script.update = kr4_scripts.mod_branch_polymorph.update
tt.modifier.duration = 15
tt.render.sprites[1].prefix = "desert_sheep"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.33)
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].is_shadow = true
tt.render.sprites[2].name = "desert_sheep_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.33)
tt.render.sprites[2].z = Z_DECALS + 1
tt.visual_small = {
	prefix = "desert_sheep",
	shadow = "desert_sheep_shadow",
	anchor = v(0.5, 0.33)
}
tt.visual_big = {
	prefix = "high_sorcerer_ostrich",
	shadow = "desert_ostrich_shadow",
	anchor = v(0.5, 0.26)
}

tt = RT("mod_branch_heal", "modifier")
AC(tt, "render")
tt.main_script.update = kr4_scripts.mod_branch_heal.update
tt.modifier.duration = 2
tt.modifier.use_mod_offset = true
tt.tick = 0.2
tt.heal = 2.5
tt.render.sprites[1].name = "sulfur_alchemist_heal_fx_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.15)
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("mod_branch_war_elephant_heal", "mod_branch_heal")
tt.modifier.duration = 2
tt.tick = 0.5
tt.heal = 15
tt.render.sprites[1].name = "war_elephant_drummer_buff_unit_run"

tt = RT("mod_branch_winter_dot", "modifier")
AC(tt, "render")
tt.main_script.update = kr4_scripts.mod_branch_dot.update
tt.modifier.duration = 3
tt.modifier.use_mod_offset = true
tt.damage = 10
tt.tick = 0.5
tt.render.sprites[1].prefix = "winter_lord_modifier"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("mod_branch_tower_block", "modifier")
AC(tt, "render")
tt.modifier.duration = 6
tt.main_script.update = kr4_scripts.mod_pirate_tower_block.update
tt.main_script.remove = kr4_scripts.mod_pirate_tower_block.remove
tt.render.sprites[1].hidden = true
tt.render.sprites[1].animated = false

tt = RT("mod_branch_tower_block_frost", "modifier")
AC(tt, "render", "ui")
tt.modifier.duration = 6
tt.main_script.update = kr4_scripts.mod_pirate_tower_block.update
tt.main_script.remove = kr4_scripts.mod_pirate_tower_block.remove
tt.in_animation = "start"
tt.loop_animation = "idle"
tt.out_animation = "end"
tt.in_time = 0.25
tt.out_time = 0.25
tt.render.sprites[1].prefix = "svell_druid_tower_frost_layer1"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "svell_druid_tower_frost_layer2"
tt.render.sprites[2].name = "start"
tt.render.sprites[2].animated = true
tt.render.sprites[2].z = Z_EFFECTS + 1
tt.ui.can_click = true
tt.ui.can_select = nil
tt.ui.click_rect = r(-42, -24, 84, 86)
tt.tap_fx = "stage10_tower_ice_tap_fx"

tt = RT("mod_branch_tower_block_djini", "mod_branch_tower_block")
AC(tt, "ui")
tt.in_animation = "start"
tt.loop_animation = "loop"
tt.out_animation = "end"
tt.in_time = 0.25
tt.out_time = 0.25
tt.render.sprites[1].prefix = "djini_sand_tower"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].hidden = false
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_EFFECTS
tt.ui.can_click = true
tt.ui.can_select = nil
tt.ui.click_rect = r(-42, -24, 84, 86)

tt = RT("mod_magnus_arcane_shield", "modifier")
AC(tt, "render")
tt.modifier.duration = 4
tt.main_script.insert = kr4_scripts.mod_magnus_arcane_shield.insert
tt.main_script.update = kr4_scripts.mod_magnus_arcane_shield.update
tt.main_script.remove = kr4_scripts.mod_magnus_arcane_shield.remove
tt.in_animation = "in"
tt.loop_animation = "loop"
tt.out_animation = "out"
tt.render.sprites[1].prefix = "magnus_tower_modifier_shield"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("mod_magnus_tower_block", "mod_branch_tower_block")
tt.modifier.duration = 6
tt.in_animation = "in"
tt.loop_animation = "loop"
tt.out_animation = "out"
tt.in_time = 0.25
tt.out_time = 0.25
tt.render.sprites[1].hidden = false
tt.render.sprites[1].prefix = "magnus_tower_modifier_block"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("mod_magnus_poison", "mod_poison")
tt.modifier.duration = 1
tt.dps.damage_every = 0.33
tt.dps.damage_min = 4
tt.dps.damage_max = 4
tt.dps.damage_type = DAMAGE_TRUE
tt.dps.kill = true

tt = RT("aura_magnus_poison", "aura")
AC(tt, "render")
tt.aura.mod = "mod_magnus_poison"
tt.aura.duration = 15
tt.aura.radius = 90
tt.aura.cycle_time = 0.33
tt.aura.mod_duration = 1
tt.aura.vis_flags = 0
tt.aura.vis_bans = F_FLYING
tt.main_script.update = kr4_scripts.aura_magnus_poison.update
tt.intro_animation = "ladle_poison_intro"
tt.run_animation = "ladle_poison_run"
tt.steam_intro_animation = "ladle_poison_steam_intro"
tt.steam_run_animation = "ladle_poison_steam_run"
tt.intro_time = fts(6)
tt.render.sprites[1].name = "ladle_poison_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS + 1
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "ladle_poison_bubble_run"
tt.render.sprites[2].animated = true
tt.render.sprites[2].anchor = v(0.5, 0.5)
tt.render.sprites[2].z = Z_DECALS + 2
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "ladle_poison_steam_run"
tt.render.sprites[3].animated = true
tt.render.sprites[3].anchor = v(0.5, 0.5)
tt.render.sprites[3].z = Z_DECALS + 3

tt = RT("kr4_branch_stage_controller", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_stage_controller.update
tt.render = nil
tt.level = 170

tt = RT("stage165_house_swap_event", "decal_scripted")
tt.main_script.update = kr4_scripts.stage165_house_swap_event.update
tt.render.sprites[1].hidden = true

tt = RT("stage164_spawn_event", "decal_scripted")
tt.main_script.update = kr4_scripts.stage164_spawn_event.update
tt.render.sprites[1].hidden = true

tt = RT("stage165_lightseeker_wave_event", "decal_scripted")
tt.main_script.update = kr4_scripts.stage165_lightseeker_wave_event.update
tt.render.sprites[1].hidden = true

tt = RT("stage164_golem_house_decal", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.render.sprites[1].name = "golem_house_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0.28)
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("stage164_golem_house_dormant", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.render.sprites[1].name = "golem_house_idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.28)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "golem_house_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.28)
tt.render.sprites[2].z = Z_DECALS + 1
tt.render.sprites[2].is_shadow = true

local function branch_interactive(name, prefix, animation, click_rect)
	local t = RT(name, "decal_scripted")
	AC(t, "ui")
	t.ui.can_click = true
	t.ui.click_rect = click_rect or r(-35, -10, 70, 70)
	t.render.sprites[1].prefix = prefix
	t.render.sprites[1].name = animation or "idle"
	t.render.sprites[1].animated = true
	t.render.sprites[1].z = Z_OBJECTS
	return t
end

tt = RT("dummy_holder", "tower_holder")
tt.tower.type = "dummy_holder"
tt.tower.can_be_mod = false
tt.render.sprites[1].hidden = true
tt.ui.click_rect = r(0, 0, 0, 0)
tt.ui.can_click = nil
tt.ui.can_select = nil

tt = RT("touch", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.render.sprites[1].hidden = true
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS

tt = RT("touch_with_random", "decal_scripted")
AC(tt, "ui")
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.render.sprites[1].name = "asst_bush_easteregg_dino"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS
tt.ui.click_rect = r(-25, -45, 50, 90)
tt.ui.can_select = nil

tt = branch_interactive("the_thing", "achievement_the_thing", "idle", r(-34, -12, 68, 58))
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.render.sprites[1].anchor = v(0.5, 0.12)
tt.render.sprites[1].z = Z_DECALS
tt.ui.can_select = nil
tt.click_animation = {
	"sniff",
	"bark"
}

tt = RT("yeti", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.render.sprites[1].prefix = "achievement_ski_yeti_yeti"
tt.render.sprites[1].name = "walk"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.085)
tt.render.sprites[1].z = Z_OBJECTS

tt = branch_interactive("shaolin_master", "achievement_shaolin_master", "idle", r(-32, -52, 64, 96))
AC(tt, "main_script")
tt.main_script.update = kr4_scripts.shaolin_master.update
tt.render.sprites[1].anchor = v(0.5, 0.15)
tt.render.sprites[1].hidden = true
tt.render.sprites[1].z = Z_OBJECTS
tt.ui.can_click = false
tt.array_positions = {
	v(425, 32),
	v(485, 704),
	v(156, 270)
}
tt.delay_to_appear = 3
tt.touches_to_win = 3

tt = branch_interactive("magical_stove", "taoist_stove_layer1", "ready", r(-45, -10, 90, 75))
tt.main_script.update = kr4_scripts.magical_stove.update
tt.animation_group = "layers"
branch_add_layered_sprites(tt, "taoist_stove_layer", 2, v(0.5, 0.19), v(0, 0), Z_OBJECTS)
for _, s in ipairs(tt.render.sprites) do
	s.name = "ready"
	s.group = tt.animation_group
end
tt.layer_sprite_ids = {1, 2}
tt.coin_sprite_id = 3
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].prefix = "taoist_stove_coin"
tt.render.sprites[3].name = "run"
tt.render.sprites[3].animated = true
tt.render.sprites[3].anchor = v(0.5, 0.19)
tt.render.sprites[3].offset = v(0, 0)
tt.render.sprites[3].z = Z_OBJECTS + 1
tt.render.sprites[3].draw_order = 3
tt.render.sprites[3].hidden = true
tt.cooldown = 60
tt.radius = 150
tt.max_targets = 60
tt.gold_factor = 0.5

tt = RT("fireworks", "decal_scripted")
tt.render.sprites[1].prefix = "achievement_fireworks_box"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("blackburn_controller", "decal_scripted")
AC(tt, "ui")
tt.main_script.update = kr4_scripts.blackburn_controller.update
tt.ui.can_click = true
tt.ui.click_rect = r(-55, -20, 110, 100)
tt.render.sprites[1].name = "blackburn_armor_helmet"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("stage178_lord_of_afterlife_preview", "decal_scripted")
tt.main_script.update = kr4_scripts.stage178_lord_preview.update
tt.render.sprites[1].prefix = "lord_of_afterlife_1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.133)
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.circle_radius = 55
tt.circle_y_scale = 0.45
tt.circle_speed = 0.65
tt.fade_in = 0.33
tt.fade_out = 0.33

tt = RT("stage178_lord_of_afterlife_preview_2", "stage178_lord_of_afterlife_preview")
tt.render.sprites[1].prefix = "lord_of_afterlife_2"

tt = RT("fx_lord_of_afterlife_spawn", "decal_scripted")
tt.main_script.update = kr4_scripts.stage178_lord_spawn_fx.update
tt.render.sprites[1].prefix = "lord_of_afterlife_effect"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.133)
tt.render.sprites[1].loop = true
tt.render.sprites[1].z = Z_OBJECTS + 2
tt.duration = 5
tt.fade_in = 0.33
tt.fade_out = 0.33

tt = RT("fx_lord_of_afterlife_spawn_2", "fx_lord_of_afterlife_spawn")
tt.render.sprites[1].prefix = "lord_of_afterlife_effect_2"

tt = RT("velociraptor_nest", "decal_scripted")
local nest_parts = {
	{"asst_eggs_mechanic_back", 0, 0, 1.1, 1.1, Z_OBJECTS},
	{"asst_eggs_mechanic_egg9", -1, -9, 1.1, 1.1, Z_OBJECTS + 1},
	{"asst_eggs_mechanic_egg10", 4, -1, 1.1, 1.1, Z_OBJECTS + 1},
	{"asst_eggs_mechanic_egg", -8, -2, 1.56, 1.53, Z_OBJECTS + 1},
	{"asst_eggs_mechanic_top", 2, -10, 1.1, 1.1, Z_OBJECTS + 2}
}
for i, cfg in ipairs(nest_parts) do
	if i > 1 then tt.render.sprites[i] = E:clone_c("sprite") end
	tt.render.sprites[i].name = cfg[1]
	tt.render.sprites[i].animated = false
	tt.render.sprites[i].offset = v(cfg[2], cfg[3])
	tt.render.sprites[i].scale = v(cfg[4], cfg[5])
	tt.render.sprites[i].z = cfg[6]
end

tt = RT("velociraptor_egg", "decal_scripted")
tt.main_script.update = kr4_scripts.velociraptor_egg.update
tt.render.sprites[1].name = "asst_eggs_mechanic_egg"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0.36)
tt.render.sprites[1].z = Z_OBJECTS
tt.hatch_time = 4
tt.spawn_template = "enemy_velociraptor"

tt = RT("zeta_spider_egg", "decal_scripted")
tt.main_script.update = kr4_scripts.velociraptor_egg.update
tt.render.sprites[1].prefix = "special_spider_tower_egg_1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.35)
tt.render.sprites[1].z = Z_OBJECTS
tt.hatch_time = 2.8
tt.hatch_animation = "spawn"
tt.spawn_template = "enemy_zeta_spiderling"
tt.spawn_count = 2
tt.node_gap = 1

tt = RT("fx_velociraptor_nest_hatch", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_one_shot_fx.update
tt.render.sprites[1].name = "asst_eggs_mechanic_splattop_1"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS + 3
tt.frames = {
	"asst_eggs_mechanic_splattop_1",
	"asst_eggs_mechanic_splattop_2",
	"asst_eggs_mechanic_splattop_3",
	"asst_eggs_mechanic_splattop_4",
	"asst_eggs_mechanic_splattop_5"
}
tt.frame_time = 0.055

tt = RT("kr4_carnivorous_plant", "decal_scripted")
tt.main_script.update = kr4_scripts.kr4_carnivorous_plant.update
tt.render.sprites[1].prefix = "carnivorous_plant_def"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].hidden = false
tt.render.sprites[1].anchor = v(0.5, 0.35)
tt.render.sprites[1].z = Z_OBJECTS
tt.venom = {cooldown = 4, range = 165, radius = 52.5, duration = 4.5, dot_duration = 1, damage = 4, tick = 0.33, slow_factor = 0.3, projectile = "kr4_carnivorous_plant_venom_projectile", pool = "kr4_carnivorous_plant_venom_pool"}
tt.teleport = {disabled = true, cooldown = 2.5, range = 50, sickness = 1.5, centers = {{17, 19}, {19, 17}, {17, -19}, {19, -17}}}

tt = RT("kr4_carnivorous_plant_venom_projectile", "decal_scripted")
tt.main_script.update = kr4_scripts.kr4_plant_projectile.update
tt.render.sprites[1].prefix = "carnivorous_plant_venom_proyectile"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BULLETS
tt.duration = 0.45
tt.hit_fx = "fx_kr4_carnivorous_plant_venom_hit"
tt.pool = "kr4_carnivorous_plant_venom_pool"
tt.sound_hit = "carnivorous_plant_venom_impact"

tt = RT("kr4_carnivorous_plant_spit_projectile", "decal_scripted")
tt.main_script.update = kr4_scripts.kr4_plant_projectile.update
tt.render.sprites[1].prefix = "carnivorous_plant_spit_proyectile"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_BULLETS
tt.duration = 0.35
tt.hit_fx = "fx_kr4_carnivorous_plant_spit_hit"
tt.sound_hit = "carnivorous_plant_impact"

tt = RT("fx_kr4_carnivorous_plant_venom_hit", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_one_shot_fx.update
tt.render.sprites[1].prefix = "carnivorous_plant_venom_fx"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].anchor = v(0.5, 0.15)
tt.render.sprites[1].z = Z_OBJECTS
tt.duration = 0.35

tt = RT("fx_kr4_carnivorous_plant_spit_hit", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_one_shot_fx.update
tt.render.sprites[1].prefix = "carnivorous_plant_spit_fx"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].anchor = v(0.5, 0.15)
tt.render.sprites[1].z = Z_OBJECTS
tt.duration = 0.3

tt = RT("kr4_carnivorous_plant_venom_pool", "decal_scripted")
tt.main_script.update = kr4_scripts.kr4_plant_venom_pool.update
tt.render.sprites[1].prefix = "carnivorous_plant_venom_decal"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS
tt.duration = 4.5
tt.radius = 52.5
tt.mod = "mod_branch_plant_venom"
tt.slow_mod = "mod_branch_plant_venom_slow"
tt.tick = 0.1

tt = RT("stage36_crowd", "decal_scripted")
tt.main_script.update = kr4_scripts.stage36_crowd.update
tt.render.sprites[1].prefix = "croud_vez_down"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("stage36_malik_throne", "decal_scripted")
tt.main_script.update = kr4_scripts.stage36_malik_throne.update
tt.render.sprites[1].name = "malik_chair"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0.34)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].draw_order = 0
-- The arena's opaque roof masks use Z_OBJECTS_COVERS in this FL port.
-- Malik sits on that roof, so the throne scene must draw above those masks.
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1
for i = 1, 2 do
	local sid = i + 1
	tt.render.sprites[sid] = E:clone_c("sprite")
	tt.render.sprites[sid].prefix = "malik_layer" .. i
	tt.render.sprites[sid].name = "sitIdle"
	tt.render.sprites[sid].animated = true
	tt.render.sprites[sid].anchor = v(0.5, 0.34)
	tt.render.sprites[sid].z = Z_OBJECTS
	tt.render.sprites[sid].draw_order = i
	tt.render.sprites[sid].z = Z_OBJECTS_COVERS + 1
end
tt.idle_animation = "sitIdle"
tt.exit_animation = "sitJump"
tt.exit_sound = "malik_pre_fight"

tt = RT("decal_malik_dialogue", "decal_scripted")
AC(tt, "texts")
tt.main_script.update = require("malik_presentation").update_dialogue
tt.render.sprites[1].name = "krfl_malik_taunt_orange"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_BULLETS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "krfl_malik_taunt_orange_arrow"
tt.render.sprites[2].animated = false
tt.render.sprites[2].offset = v(-85, -50)
tt.render.sprites[2].z = Z_BULLETS
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].offset = v(0, 2)
tt.render.sprites[3].z = Z_BULLETS
tt.texts.list[1].size = v(216, 72)
tt.texts.list[1].font_name = "body_bold"
tt.texts.list[1].font_size = 18
tt.texts.list[1].color = {255, 244, 215}
tt.texts.list[1].line_height = 1
tt.texts.list[1].fit_height = true
tt.texts.list[1].sprite_id = 3

tt = RT("miner", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_looping_decal.update
tt.render.sprites[1].prefix = "stage30_miner_1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.idle_animation = "idle"
tt.loop_variants = {
	{min_cooldown = 10, max_cooldown = 15, animation_idle = "idle", animation_end = "descanso"},
	{min_cooldown = 5, max_cooldown = 10, animation_idle = "idle2", animation_end = "susto"}
}

tt = RT("multiple_loop", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_looping_decal.update
tt.render.sprites[1].prefix = "stage30_special_shine"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_OBJECTS
tt.idle_animation = "idle"
tt.loop_variants = {
	{min_cooldown = 1, max_cooldown = 4, animation_idle = "idle", animation_end = "run"}
}

tt = RT("stage22_back_throne", "decal")
tt.render.sprites[1].name = "stage_22_back_throne"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0.245)
tt.render.sprites[1].z = Z_DECALS

tt = RT("winter_queen_statue", "decal_scripted")
branch_add_layered_sprites(tt, "winter_queen_layer", 6, v(0.5, 0.245), v(0, 0), Z_OBJECTS)
for _, s in pairs(tt.render.sprites) do
	s.flip_x = true
end

tt = RT("shatra", "decal_scripted")
AC(tt, "sound_events")
tt.main_script.update = kr4_scripts.shatra.update
tt.animation_group = "layers"
branch_add_layered_sprites(tt, "shatra_layer", 7, v(0.5, 0.5), v(0, 0), Z_OBJECTS)
for _, s in ipairs(tt.render.sprites) do
	s.group = tt.animation_group
end
tt.wave_start = 15
tt.action_loop_duration = 5
tt.sound_events.spawn = "shatra_intro"
tt.sound_events.deathray = "shatra_deathray"
tt.sound_events.abduction = "shatra_abduction"
tt.sound_events.death = "shatra_death"
tt.omegaray = {
	cooldown = 20,
	cooldown_wait = 5,
	fx = "shatra_ship_deathray_fx",
	destroy_delay = 2.6,
	excludes = {
		sarcophagus = true,
		sarcophagus_2 = true,
		sarcophagus_build_2 = true,
		stage34_sarcophagus_build_2 = true
	},
	tower_radius = 72,
	towers = {
		{v(621, 214), v(697, 321), v(785, 290)},
		{v(291, 453), v(350, 338)},
		{v(393, 224), v(501, 238), v(275, 229)},
		{v(751, 429)},
		{v(281, 537), v(218, 410)}
	}
}
tt.abduction = {
	cooldown = 15,
	fx = "shatra_ship_abduction_fx",
	crowd_range = 140,
	min_targets = 2,
	kill_radius = 120,
	max_targets = 3
}

tt = RT("shatra_ship_deathray_fx", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_one_shot_fx.update
tt.animation_group = "layers"
for i = 1, 4 do
	local s = i == 1 and tt.render.sprites[1] or E:clone_c("sprite")

	tt.render.sprites[i] = s
	s.prefix = "shatra_ship_layer" .. i
	s.name = "dr_run"
	s.animated = true
	s.anchor = v(0.5, 0.18)
	s.z = Z_OBJECTS + 4
	s.group = tt.animation_group
	s.draw_order = i
end
tt.render.sprites[5] = E:clone_c("sprite")
tt.render.sprites[5].name = "shatra_ship_shadow"
tt.render.sprites[5].animated = false
tt.render.sprites[5].is_shadow = true
tt.render.sprites[5].anchor = v(0.5, 0.5)
tt.render.sprites[5].offset = v(0, -100)
tt.render.sprites[5].z = Z_DECALS
tt.duration = 5

tt = RT("shatra_ship_abduction_fx", "shatra_ship_deathray_fx")
for i = 1, 4 do
	tt.render.sprites[i].name = "ab_run"
	tt.render.sprites[i].anchor = v(0.5, 0.22)
end

tt = branch_interactive("sarcophagus", "stage34_sarcophagus_back", "idle", r(-45, -10, 90, 75))
tt.main_script.update = kr4_scripts.sarcophagus.update
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage34_sarcophagus"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].animated = true
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.cost = 120
tt.spawn_count = 5
tt.cooldown = 13.5
tt.spawn_interval = 2.7
tt = RT("sarcophagus_2", "sarcophagus")
tt.cost = 35

tt = RT("sarcophagus_build_2", "tower_KR5")
AC(tt, "user_selection", "attacks")
tt.tower.type = "sarcophagus_build_2"
tt.tower.level = 1
tt.tower.price = 50
tt.tower.can_be_sold = true
tt.tower.can_be_mod = false
tt.tower.can_hover = true
tt.tower.menu_offset = v(0, 18)
tt.attacks.range = 0
tt.attacks.list[1] = E:clone_c("bullet_attack")
tt.attacks.list[1].damage_min = 0
tt.attacks.list[1].damage_max = 0
tt.attacks.list[1].damage_type = DAMAGE_TRUE
tt.attacks.list[1].cooldown = 0
tt.attacks.list[1].price = 120
tt.info.i18n_key = "SPECIAL_SARCOPHAGUS"
tt.info.portrait = "sarcophagus_tower_layer1_0001"
tt.main_script.update = kr4_scripts.sarcophagus.update
tt.render.sprites[1].prefix = "stage34_sarcophagus_back"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "stage34_sarcophagus"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].animated = true
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.ui.can_click = true
tt.ui.can_select = true
tt.ui.click_rect = r(-36, -2, 72, 58)
tt.user_selection.allowed = true
tt.user_selection.ignore_point = true
tt.direct_activate = false
tt.cost = 120
tt.spawn_count = 5
tt.spawn_template = "stage34_sarcophagus_mummy"
tt.cooldown = 13.5
tt.spawn_interval = 2.7

tt = RT("stage34_sarcophagus_build_2", "sarcophagus_build_2")
tt.tower.type = "stage34_sarcophagus_build_2"
tt.tower.can_be_sold = false

tt = RT("stage34_sarcophagus_mummy", "hero_isfet_mummy")
tt.lifetime = 18
tt.ui.can_click = true
tt.ui.can_select = true

tt = RT("hammerhold_archer", "decal_scripted")
AC(tt, "ui")
tt.main_script.update = kr4_scripts.hammerhold_archer.update
tt.ui.can_click = false
tt.ui.can_select = false
tt.render.sprites[1].prefix = "hammerhold_archer_tower"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "hammerhold_archer_tower_shooter"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].animated = true
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.attack = {cooldown = 0.8, min_range = 25, max_range = 290, damage_min = 14, damage_max = 18, hit_time = 0.25}

tt = RT("hammerhold_roof_archer", "decal_scripted")
tt.main_script.update = kr4_scripts.hammerhold_archer.update
tt.render.sprites[1].prefix = "hammerhold_roofarcher"
tt.render.sprites[1].name = "spawn"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS
tt.roof_archer = true
tt.lifetime = 10
tt.attack = {cooldown = 1.1, min_range = 50, max_range = 350, damage_min = 10, damage_max = 20, hit_time = 0.43}

for _, barrack_name in ipairs({"hammerhold_barrack", "hammerhold_barrack1", "hammerhold_barrack2", "hammerhold_barrack3", "hammerhold_barrack4", "hammerhold_barrack5", "hammerhold_barrack6", "hammerhold_barrack7", "legionnaire_barrack"}) do
	local t = RT(barrack_name, "decal_scripted")
	AC(t, "ui")
	t.main_script.update = kr4_scripts.hammerhold_barrack.update
	t.ui.can_click = false
	t.ui.can_select = false
	t.render.sprites[1].prefix = "tower_hammerhold_barrack"
	t.render.sprites[1].name = "idle"
	t.render.sprites[1].animated = true
	t.render.sprites[1].z = Z_OBJECTS
	t.render.sprites[2] = E:clone_c("sprite")
	t.render.sprites[2].prefix = "tower_hammerhold_barrack_back"
	t.render.sprites[2].name = "idle"
	t.render.sprites[2].animated = true
	t.render.sprites[2].z = Z_OBJECTS + 1
	t.cooldown = 6
	t.start_wave = 1
end

tt = RT("veznan_ship_cannon", "decal_scripted")
AC(tt, "ui")
tt.main_script.update = kr4_scripts.veznan_ship_cannon.update
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-38, -20, 76, 70)
tt.render.sprites[1].prefix = "stage32_canon"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].z = Z_OBJECTS
tt.costs = {200, 250, 300}
tt = RT("veznan_ship_cannon_iron", "veznan_ship_cannon")
tt.costs = {200, 250, 300}

tt = RT("roadrunner", "decal_scripted")
tt.render.sprites[1].hidden = true

-- Branch bosses. Values below follow the KR4 unit settings used by the
-- corresponding branch skill handlers.
tt = branch_enemy_template("winter_queen", "winter_queen_layer1", 4000, 0, 0, 10, 0, 20, 0.245, 105, nil, {
	boss = true, single_walk = true, melee_slot = 20,
	tower_block = {cooldown = 12, range = 175, duration = 4, max_targets = 3, animation = "freeze", cast_time = 0.55, mod = "mod_branch_tower_block_frost"},
	necromancy = {range = 250, template = "enemy_apex_shard", safe_nodes_to_exit = 25},
	end_level_on_death = true
})
branch_add_layered_sprites(tt, "winter_queen_layer", 6, v(0.5, 0.245), v(0, 0), Z_OBJECTS)
tt.render.sprites[7] = E:clone_c("sprite")
tt.render.sprites[7].animated = false
tt.render.sprites[7].is_shadow = true
tt.render.sprites[7].name = "winter_queen_shadow"
tt.render.sprites[7].anchor = v(0.5, 0.245)
tt.render.sprites[7].offset = v(0, 0)
tt.render.sprites[7].z = Z_DECALS + 1
local winter_queen_melee = branch_melee(tt, 150, 300, 2, 0.235, "attack")
winter_queen_melee.sound = "level22_winterqueen_stingattack"
tt.branch.tower_block.sound = "level22_winterqueen_towerfreeze"
winter_queen_melee.type = "area"
winter_queen_melee.damage_radius = 90
winter_queen_melee.count = 5
tt.sound_events.death = "level22_winterqueen_death"

tt = branch_enemy_template("dragon_king_boss", "dragon_king_boss_layer1", 8000, 0, 0, 10, 0, 0, 0.113, 75, nil, {
	boss = true, unblockable = true, single_walk = true,
	water = {
		cooldown = 6,
		duration = 8,
		radius = 30,
		animation = "attack",
		cast_time = 0.4,
		projectile = "dragon_king_water_bolt",
		shoot_offset = v(-3, 120),
		sound = "level25_dragonking_waterballspit",
		target_nodes = {
			{path = 1, node = 95},
			{path = 2, node = 117},
			{path = 3, node = 35},
			{path = 3, node = 112}
		}
	},
	move = {
		cooldown = 35,
		nodes = 25,
		node_limit = 140,
		action_time = 1.5,
		delay_to_end = 1.5,
		animation_out = "out",
		animation_in = "in",
		body_out = "outTail",
		body_slide = "inSlide",
		body_in = "inHead",
		sound_out = "level25_dragonking_movement_dive",
		sound_loop = "level25_dragonking_movement_loop",
		sound_in = "level25_dragonking_movement_emerge"
	},
	death_delay = 3.7
})
branch_add_layered_sprites(tt, "dragon_king_boss_layer", 30, v(0.5, 0.113), v(0, 0), Z_OBJECTS)
tt.render.sprites[1].angles.walk = {"idle", "idle", "idle"}
tt.main_script.update = kr4_scripts.dragon_king_boss.update
tt.health_bar.hidden = true
tt.branch.main_sprite_ids = {}
for i = 1, 30 do
	tt.branch.main_sprite_ids[i] = i
end
tt.branch.body_sprite_ids = {}
for i = 1, 4 do
	local sid = 30 + i
	tt.branch.body_sprite_ids[i] = sid
	tt.render.sprites[sid] = E:clone_c("sprite")
	tt.render.sprites[sid].prefix = "dragon_king_boss_body_layer" .. i
	tt.render.sprites[sid].name = "idle"
	tt.render.sprites[sid].animated = true
	tt.render.sprites[sid].anchor = v(0.5, 0.113)
	tt.render.sprites[sid].offset = v(0, 0)
	tt.render.sprites[sid].z = Z_OBJECTS - 1
	tt.render.sprites[sid].draw_order = i
	tt.render.sprites[sid].hidden = true
	tt.render.sprites[sid].ignore_start = true
end

tt = branch_enemy_template("lord_of_afterlife", "lord_of_afterlife_1", 3000, 1, 0, 8, 0, 20, 0.133, 60, "lord_of_afterlife_1_shadow", {
	boss = true, unblockable = true, single_walk = true, spawn_animation = "spawn", paired_boss = "enemy_lord_of_afterlife_2"
})
tt.vis.bans = bor(tt.vis.bans, F_MOD, F_POLYMORPH, F_STUN, F_SLOW)

tt = branch_enemy_template("lord_of_afterlife_2", "lord_of_afterlife_2", 3000, 0, 1, 8, 0, 20, 0.133, 60, "lord_of_afterlife_2_shadow", {
	boss = true, unblockable = true, single_walk = true, spawn_animation = "spawn", paired_boss = "enemy_lord_of_afterlife"
})
tt.vis.bans = bor(tt.vis.bans, F_MOD, F_POLYMORPH, F_STUN, F_SLOW)

tt = branch_enemy_template("boss_great_t", "great_t", 8000, 0, 0.6, 10, 0, 20, 0.167, 115, nil, {
	exo = true, boss = true, single_walk = true, melee_slot = 50, click_w = 60,
	instakill = {chance = 1, animation = "instakill", cooldown = 8, sound = "kr4_enemies_boss_great_t_crunch"},
	doomsday = {cooldown = 12, radius = 75, count = 8, damage_min = 150, damage_max = 190, animation = "doomsday", cast_time = 0.75, sound = "kr4_enemies_boss_great_t_doomsday_dance"},
	boss_death = {animation = "death", delay = 6}
})
local great_t_melee = branch_melee(tt, 115, 155, 1.5, 0.5, "melee")
great_t_melee.sound = "kr4_enemies_boss_great_t_hit_melee"
tt.sound_events.death = "kr4_enemies_boss_great_t_death"

tt = branch_enemy_template("mirage_path", "mirage", 8000, 0, 0, 13, 0, 20, 0.15, 48, "mirage_shadow", {
	boss = true, unblockable = true,
	ranged = {stand_ground = true, cooldown = 0.6, min_range = 50, max_range = 125, damage_min = 150, damage_max = 190, damage_type = DAMAGE_PHYSICAL, animation = "rangeAttack", hit_time = 0.5, projectile = "branch_projectile_mirage", flight_time = fts(7)},
	shadow_jump = {cooldown = 8, shared_min_cooldown = 8, nodes = -5, safe_nodes_start = 65, safe_nodes_to_exit = 55, animation_out = "dodgeOut", animation_in = "dodgeIn", leave_copy = "enemy_mirage_clon"},
	clone = {cooldown = 14, shared_min_cooldown = 8, range = 150, min_targets = 2, max_targets = 4, template = "enemy_legion_nomad", animation = "copies", cast_time = 0.86, sound = "mirage_special_clones"}
})
tt.branch.shadow_jump.sound = "kr4_enemies_sandstorm_nomad_dodge"
branch_melee(tt, 122, 154, 0.6, 0.36, "attack")

tt = branch_enemy_template("mirage_clon", "mirage_clon", 300, 0, 0, 36, 7, 1, 0.15, 37, nil, {spawn_animation = "idle"})
branch_melee(tt, 76, 92, 1, 0.3, "attack")

tt = branch_enemy_template("alric", "alric", 8000, 0, 0, 10, 35, 20, 0.28, 46, "alric_shadow", {
	boss = true, melee_slot = 15,
	spawn = {cooldown = 16, count = 3, template = "enemy_alric_sandwarrior", animation = "summon", cast_time = 0.6},
	buried = {cooldown = 40, duration = 3, factor = 6, animation = "twisterWalk", animation_in = "twisterInit", animation_out = "twisterOut", sound = "alric_twister"},
	end_level_on_death = true
})
tt.unit.death_animation = "deathIn"
local alric_melee = branch_melee(tt, 84, 128, 0.5, 0.4, "attack")
alric_melee.area_attack = {cooldown = 3, damage_min = 184, damage_max = 272, radius = 60, max_count = 8, animation = "special", hit_time = 0.63, sound = "alric_fury_attack"}

tt = branch_enemy_template("alric_sandwarrior", "alric_sandwarrior", 350, 0, 0, 65, 35, 1, 0.28, 38, "alric_sandwarrior_shadow", {spawn_animation = "spawn"})
branch_melee(tt, 52, 76, 0.5, 0.46, "attack")
tt.sound_events.death = "group_sandstorm_alric_sandwarrior_death"

tt = branch_enemy_template("malik", "malik", 9000, 0, 0, 7, 35, 20, 0.34, 55, "malik_shadow", {
	malik_presentation = true,
	boss = true, melee_slot = 15,
	ranged = {cooldown = 4.5, min_range = 50, max_range = 490, damage_min = 390, damage_max = 480, damage_type = DAMAGE_MAGICAL, animation = "range", hit_time = 0.59, projectile = "branch_projectile_malik", flight_time = fts(6), g = 0},
	tower_destroy = {cooldown = 13, range = 125, animation = "special", cast_time = 1.21, sound = "malik_tower_destroy_oneshot"},
	rocket_jump = {cooldown = 12, nodes = 25, radius = 160, damage_min = 274, damage_max = 328, animation_out = "jumpLaunch", animation = "jumpTravel", animation_in = "jumpLand", sound = "malik_jump_charge", hit_sound = "malik_jump_hit", destinations = {{reach_node = 0, path = 3, node = 45}, {reach_node = 68, path = 0, node = 68}, {reach_node = 78, path = 3, node = 84}, {reach_node = 91, path = 6, node = 95}, {reach_node = 103, path = 3, node = 108}}},
	boss_death = {
		sequence = true,
		animation = "death",
		animation_timeout = 2,
		loop_animation = "deathLoop",
		loop_duration = 0.5,
		end_animation = "deathEnd",
		end_timeout = 2,
		sounds = {
			{name = "malik_death_hammerfall", delay = 0.3},
			{name = "malik_death_body_fall", delay = 0.5}
		}
	},
	end_level_on_death = true
})
branch_add_layered_sprites(tt, "malik_layer", 2, v(0.5, 0.34), v(0, 0), Z_OBJECTS)
tt.enemy.wait_for_death_animation = true
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "malik_shadow"
tt.render.sprites[3].animated = false
tt.render.sprites[3].is_shadow = true
tt.render.sprites[3].ignore_start = true
tt.render.sprites[3].anchor = v(0.5, 0.34)
tt.render.sprites[3].z = Z_DECALS + 1
local malik_melee = branch_melee(tt, 172, 216, 3, 0.85, "melee")
malik_melee.sound = "malik_melee_attack"
tt.branch.ranged.sound = "malik_ranged_attack"
malik_melee.damage_radius = 60
malik_melee.max_count = 8
malik_melee.type = "area"
malik_melee.count = 8
malik_melee.hit_fx = "fx_branch_malik_attack_decal"

tt = branch_enemy_template("boss_dwarf_mecha", "boss_dwarf_mecha", 7000, 0, 0, 15, 0, 20, 0.08, 100, nil, {
	boss = true, melee_slot = 30,
	ranged = {cooldown = 25, min_range = 100, max_range = 500, damage_min = 100, damage_max = 150, damage_type = DAMAGE_PHYSICAL, radius = 60, animation = "missil", hit_time = 0.66, projectile = "branch_projectile_boss_dwarf_mecha", sound = "dwarves_boss_dwarf_missile_release"},
	end_level_on_death = true,
	boss_death = {animation = "death", delay = 2}
})
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.unit.hit_offset = v(0, 45)
tt.unit.mod_offset = v(0, 45)
tt.unit.head_offset = v(0, 95)
tt.info.i18n_key = "ENEMY_BOSS_BOLGUR_ENCYC"
branch_melee(tt, 150, 200, 1, 0.83, "attack")
tt.melee.attacks[1].damage_radius = 60
tt.melee.attacks[1].max_count = 8
tt.melee.attacks[1].sound = "dwarves_boss_dwarf_attack_1"
tt.sound_events.death = "dwarves_boss_dwarf_death"

tt = branch_enemy_template("knight_rider", "knight_rider", 220, 0, 0, 35, 20, 2, 0.3, 49, "knight_rider_shadow", {
	charge = {cooldown = 4, duration = 2, factor = 2, ignore_block = true, animation = "chargeWalk", animation_up = "chargeWalkUp", animation_down = "chargeWalkDown", radius = 25, damage_min = 16, damage_max = 24, damage_type = DAMAGE_PHYSICAL, tick_time = 0.1, max_count = 6},
	death_spawn = "enemy_paladin"
})
branch_melee(tt, 16, 24, 1, 0.5, "attack")

tt = branch_enemy_template("lightseeker", "lightseeker", 7000, 0.7, 0, 16, 0, 999, 0.21, 45, nil, {
	boss = true,
	single_walk = true,
	melee_slot = 17,
	lightseeker_courage = {
		cooldown = 10,
		range = 150,
		min_targets = 2,
		max_targets = 5,
		duration = 4,
		animation = "buff",
		cast_time = 0.5,
		mod = "mod_magnus_arcane_shield",
		sound = "linirea_lightseeker_boost",
		excluded = {
			enemy_arcane_magus = true,
			enemy_golem_house = true,
			enemy_griffin_bombardier = true,
			enemy_guardian_eagle = true,
			enemy_high_sorcerer = true,
			enemy_hunting_dog = true
		}
	},
	lightseeker_heal = {
		cooldown = 5,
		animation = "heal",
		cast_time = 1.17,
		thresholds = {
			{ratio = 0.5, amount = 100},
			{ratio = 0.25, amount = 300}
		}
	},
	lightseeker_waves = {
		{node = 80, wave = "boss_riders_elites_1"},
		{node = 81, wave = "boss_sorcerer_4"},
		{node = 100, wave = "boss_elves_4"},
		{node = 110, wave = "boss_paladins_1"},
		{node = 120, wave = "boss_elves_4"},
		{node = 125, wave = "boss_tower_1"},
		{node = 140, wave = "boss_elites_1"},
		{node = 141, wave = "boss_elite_4"},
		{node = 150, wave = "boss_sorcerer_4"}
	},
	end_level_on_death = true,
	boss_death = {animation = "death", delay = 3}
})
branch_melee(tt, 120, 180, 1, 0.4, "attack1", DAMAGE_MAGICAL)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.i18n_key = "ENEMY_LIGHTSEEKER_ENCYC"

tt = branch_enemy_template("golem_house", "golem_house", 2000, 0, 0, 16, 150, 3, 0.28, 108, "golem_house_shadow", {spawn_animation = "spawn", melee_slot = 34, single_walk = true})
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.branch.spawn_sound = "level14_magichouse_transform"
branch_melee(tt, 60, 120, 2.5, 0.33, "attack")

tt = branch_enemy_template("mega_boss_dragon", "mega_dragon_boss", 5, 0, 0, 0, 0, 0, 0.5, 95, nil, {boss = true, flying = true, unblockable = true, single_walk = true, exo = true})
tt.info.i18n_key = "ENEMY_BOSS_JOKULL_ENCYC"
tt.info.portrait_boss = "boss_health_bar_icon_0001"
tt.health_bar.type = HEALTH_BAR_SIZE_LARGE
tt.health_bar.offset = v(142, 95)
tt.health.immune_to = DAMAGE_ALL_TYPES
tt.main_script.update = kr4_scripts.mega_boss_dragon.update
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_TOWER_BASES - 3
tt.vis.flags = 0
tt.vis.bans = bor(F_RANGED, F_BLOCK, F_MOD, F_AREA)
tt.ui.can_click = false
tt.ui.can_select = false
tt.unit.hit_offset = v(142, -58)
tt.unit.mod_offset = v(142, -58)
tt.unit.head_offset = v(142, 60)

tt = branch_enemy_template("alleria", "alleria", 500, 0, 0, 60, 0, 1, 0.25, 48, "alleria_shadow", {
	boss = true,
	single_walk = true,
	lifetime = 15,
	spawn_animation = "in",
	spawn = {cooldown = 20, count = 1, template = "enemy_elven_warrior", animation = "call", cast_time = 0.567},
	ranged = {cooldown = 2, min_range = 25, max_range = 400, damage_min = 40, damage_max = 80, damage_type = DAMAGE_PHYSICAL, animation = "shootPrep", hit_time = 0.3, no_facing = true, projectile = "branch_projectile_alleria"}
})
branch_melee(tt, 50, 60, 1, 0.3, "melee1")

tt = branch_enemy_template("farmer_bucket", "farmer_bucket", 80, 0, 0, 33, 0, 1, 0.13, 30, "farmer_bucket_shadow", nil)
branch_melee(tt, 6, 10, 1, 0.3, "attack")

tt = branch_enemy_template("farmer_mile", "farmer_mile", 180, 0, 0, 30, 0, 1, 0.213, 37, "farmer_mile_shadow", nil)
branch_melee(tt, 12, 17, 1.2, 0.3, "attack")

tt = branch_enemy_template("farmer_rake", "farmer_rake", 80, 0, 0, 33, 0, 1, 0.13, 30, "farmer_rake_shadow", nil)
branch_melee(tt, 6, 10, 1, 0.3, "attack")

tt = branch_enemy_template("farmer_scythe", "farmer_scythe", 80, 0, 0, 33, 0, 1, 0.13, 30, "farmer_rake_shadow", nil)
branch_melee(tt, 6, 10, 1, 0.233, "attack")

tt = branch_enemy_template("farmer_rooster", "farmer_rooster", 80, 0, 0, 30, 0, 1, 0.125, 33, "farmer_rooster_shadow", {
	ranged = {cooldown = 2, min_range = 0, max_range = 75, damage_min = 6, damage_max = 10, damage_type = DAMAGE_PHYSICAL, animation = "range", hit_time = 0.4, no_facing = true, projectile = "branch_projectile_farmer_rooster"}
})
branch_melee(tt, 6, 10, 1, 0.133, "melee")

tt = branch_enemy_template("linirea_joe", "linirea_joe", 1500, 0, 0, 36, 100, 1, 0.14, 30, "linirea_joe_shadow", {
	single_walk = true,
	spawn_animation = "toSayayin",
	spawn_sound = "linirea_joe_angry",
	spawn = {cooldown = 15, count = 2, template = "enemy_ninja_sheep", animation = "callSheep", cast_time = 0.767, sound = "linirea_joe_angry"}
})
branch_melee(tt, 32, 48, 1, 0.4, "attack")
tt.melee.attacks[1].area_attack = {cooldown = 12, radius = 40, max_count = 1, damage_min = 64, damage_max = 96, animation = "specialAttack", hit_time = 0.4}

tt = branch_enemy_template("ninja_sheep", "ninja_sheep", 110, 0, 0, 40, 0, 1, 0.25, 26, "ninja_sheep_shadow", {
	single_walk = true,
	spawn_animation = "spawn"
})
branch_melee(tt, 13, 19, 1, 0.4, "fists")
tt.melee.attacks[1].area_attack = {cooldown = 8, radius = 30, max_count = 1, damage_min = 26, damage_max = 38, animation = "danielSanKick", hit_time = 1.4}

local function branch_enemy_projectile_template(name, sprite_name, animated, hit_fx, flight_time)
	local t = RT(name, "arrow")

	t.main_script.insert = kr4_scripts.branch_enemy_projectile.insert
	t.main_script.update = kr4_scripts.branch_enemy_projectile.update
	t.bullet.flight_time = flight_time or fts(18)
	t.bullet.hit_fx = hit_fx
	t.render.sprites[1].name = sprite_name
	t.render.sprites[1].animated = animated or false
	t.render.sprites[1].flip_x = true

	return t
end

local function branch_enemy_projectile_fx(name, sprite_name, animated)
	local t = RT(name, "decal_scripted")

	t.main_script.update = kr4_scripts.branch_one_shot_fx.update
	t.render.sprites[1].name = sprite_name
	t.render.sprites[1].animated = animated ~= false
	t.render.sprites[1].z = Z_OBJECTS
	t.duration = animated ~= false and 0.6 or 0.4

	return t
end

local function branch_enemy_projectile_decal(name, sprite_name, animated, duration)
	local t = branch_enemy_projectile_fx(name, sprite_name, animated)

	t.render.sprites[1].z = Z_DECALS
	t.duration = duration or (animated ~= false and 0.8 or 3.3)

	return t
end

branch_enemy_projectile_template("branch_projectile_ice_witch", "ice_witch_bolt_travel", true, "fx_branch_projectile_ice_witch_hit")
branch_enemy_projectile_fx("fx_branch_projectile_ice_witch_hit", "ice_witch_bolt_hit", true)
branch_enemy_projectile_template("branch_projectile_svell_druid", "svell_druid_proyectile_travel", true, "fx_branch_projectile_svell_druid_hit")
branch_enemy_projectile_fx("fx_branch_projectile_svell_druid_hit", "svell_druid_proyectile_hit", true)
branch_enemy_projectile_template("branch_projectile_northern_huntress", "northern_huntress_proyectile", false, nil, fts(22)).bullet.decal_fx = "fx_branch_decal_northern_huntress_projectile"
E:get_template("branch_projectile_northern_huntress").bullet.hit_blood_fx = "fx_blood_splat"
branch_enemy_projectile_decal("fx_branch_decal_northern_huntress_projectile", "northern_huntress_proyectile_decal", false)
branch_enemy_projectile_template("branch_projectile_elven_warrior", "elven_warrior_arrow", false, nil, fts(22)).bullet.decal_fx = "fx_branch_decal_elven_warrior_arrow"
E:get_template("branch_projectile_elven_warrior").bullet.hit_blood_fx = "fx_blood_splat"
branch_enemy_projectile_decal("fx_branch_decal_elven_warrior_arrow", "elven_warrior_arrow_decal_run", true)
branch_enemy_projectile_template("branch_projectile_arcane_magus", "arcane_mage_projectile", false, "fx_branch_projectile_arcane_magus_hit", fts(12))
branch_enemy_projectile_fx("fx_branch_projectile_arcane_magus_hit", "arcane_magus_projectile_hit_run", true)
branch_enemy_projectile_template("branch_projectile_musketeer", "tinbeard_gunman_proyectile_travel", true, nil, fts(8)).bullet.decal_fx = "fx_branch_decal_musketeer_smoke"
E:get_template("branch_projectile_musketeer").bullet.hit_blood_fx = "fx_blood_splat"
branch_enemy_projectile_decal("fx_branch_decal_musketeer_smoke", "musketeer_smoke_run", true, 0.6)
branch_enemy_projectile_template("branch_projectile_sulfur_alchemist", "sulfur_alchemist_projectile", false, "fx_branch_projectile_sulfur_alchemist_hit")
branch_enemy_projectile_fx("fx_branch_projectile_sulfur_alchemist_hit", "sulfur_alchemist_projectile_hit_run", true)
branch_enemy_projectile_template("branch_projectile_sulfur_alchemist_heal", "sulfur_alchemist_projectile_heal", false, "fx_branch_projectile_sulfur_alchemist_heal_hit", fts(22))
branch_enemy_projectile_fx("fx_branch_projectile_sulfur_alchemist_heal_hit", "sulfur_alchemist_projectile_heal_hit_run", true)
branch_enemy_projectile_fx("fx_branch_war_elephant_drummer_decal", "war_elephant_drummer_decal_run", true)
branch_enemy_projectile_template("branch_projectile_tinbeard_gunman", "tinbeard_gunman_proyectile_travel", true, "fx_branch_projectile_tinbeard_gunman_hit", fts(8)).bullet.g = 0
branch_enemy_projectile_fx("fx_branch_projectile_tinbeard_gunman_hit", "tinbeard_gunman_proyectile_hit", true)
branch_enemy_projectile_template("branch_projectile_smokebeard_repair", "smokebeard_engineer_ray_travel", true, "fx_branch_projectile_smokebeard_repair_hit", fts(8)).bullet.g = 0
branch_enemy_projectile_fx("fx_branch_projectile_smokebeard_repair_hit", "smokebeard_engineer_ray_hit_run", true)
branch_enemy_projectile_template("branch_projectile_legion_archer", "legion_archer_arrow_travel", true, nil, fts(15)).bullet.decal_fx = "fx_branch_decal_legion_archer_arrow"
E:get_template("branch_projectile_legion_archer").bullet.hit_blood_fx = "fx_blood_splat"
branch_enemy_projectile_decal("fx_branch_decal_legion_archer_arrow", "legion_archer_arrow_0005", false)
branch_enemy_projectile_template("branch_projectile_legion_nomad", "nomad_proyectile", false, nil, fts(7)).bullet.decal_fx = "fx_branch_decal_legion_nomad_projectile"
E:get_template("branch_projectile_legion_nomad").bullet.hit_blood_fx = "fx_blood_splat"
branch_enemy_projectile_decal("fx_branch_decal_legion_nomad_projectile", "nomad_proyectile_decal", false)
branch_enemy_projectile_template("branch_projectile_magic_carpet", "magic_carpet_projectile", false, "fx_branch_projectile_magic_carpet_hit", fts(22))
branch_enemy_projectile_fx("fx_branch_projectile_magic_carpet_hit", "magic_carpet_explosion_run", true)
tt = branch_enemy_projectile_template("branch_projectile_griffin_bombardier", "gryphon_projectile", false, "fx_kr4_explosion_fragment", fts(16))
tt.bullet.decal_fx = "fx_branch_decal_griffin_bombardier_crater"
tt.sound_events.insert = nil
tt.sound_events.hit = "BombExplosionSound"
branch_enemy_projectile_decal("fx_branch_decal_griffin_bombardier_crater", "decal_bomb_crater", false)
tt = branch_enemy_projectile_template("branch_projectile_demon_trident", "reinforcement_hellion_trident_proyectile", false, "fx_kr4_reinforcement_hellion_trident_floor", fts(10))
tt.bullet.g = 0
tt = RT("branch_ray_sand_mysthic", "bullet")
tt.main_script.update = kr4_scripts.branch_enemy_ray.update
tt.image_width = 212
tt.track_target = false
tt.ray_duration = 0.65
tt.bullet.hit_time = 0.1
tt.bullet.damage_radius = 95
tt.bullet.mod = "mod_branch_sand_mysthic_ray_hit"
tt.bullet.mod_duration = 0.7
tt.bullet.hit_fx = "fx_branch_projectile_sand_mysthic_hit"
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].name = "sand_mysthic_ray_travel"
tt.render.sprites[1].loop = false
branch_enemy_projectile_fx("fx_branch_projectile_sand_mysthic_hit", "sand_mysthic_ray_explosion_run", true)
branch_enemy_projectile_template("branch_projectile_mirage", "mirage_kunai", false, nil, fts(7)).bullet.decal_fx = "fx_branch_decal_mirage_kunai"
E:get_template("branch_projectile_mirage").bullet.hit_blood_fx = "fx_blood_splat"
branch_enemy_projectile_decal("fx_branch_decal_mirage_kunai", "mirage_kunai_decal", false)
branch_enemy_projectile_template("branch_projectile_malik", "malik_attack_ray_travel", true, "fx_branch_projectile_malik_hit", fts(6)).bullet.g = 0
branch_enemy_projectile_fx("fx_branch_projectile_malik_hit", "malik_attack_ray_modifier_run", true).duration = fts(6)
branch_enemy_projectile_decal("fx_branch_malik_jump_decal", "malik_jump_decal_run", true, fts(18))
branch_enemy_projectile_decal("fx_branch_malik_attack_decal", "malik_attack_decal_run", true, fts(27))
tt = branch_enemy_projectile_fx("fx_branch_malik_tower_ray", "malik_towerdestroction_ray_run", true)
tt.duration = fts(16)
tt.render.sprites[1].anchor = v(0.5, 0)
tt.render.sprites[1].z = Z_BULLETS
tt = branch_enemy_projectile_fx("fx_branch_malik_tower_explosion", "malik_tower_explotion_start", true)
tt.duration = fts(50)
branch_enemy_projectile_template("branch_projectile_boss_dwarf_mecha", "boss_dwarf_mecha_travel", true, "fx_kr4_explosion_fragment", fts(30)).bullet.decal_fx = "fx_branch_decal_boss_dwarf_mecha_crater"
branch_enemy_projectile_decal("fx_branch_decal_boss_dwarf_mecha_crater", "decal_bomb_crater", false)
branch_enemy_projectile_template("branch_projectile_alleria", "alleria_arrow", false, nil, fts(22)).bullet.decal_fx = "fx_branch_decal_alleria_arrow"
E:get_template("branch_projectile_alleria").bullet.hit_blood_fx = "fx_blood_splat"
branch_enemy_projectile_decal("fx_branch_decal_alleria_arrow", "alleria_arrow_decal_run", true)
branch_enemy_projectile_template("branch_projectile_farmer_rooster", "farmer_rooster_proyectile_travel", true, "fx_branch_projectile_farmer_rooster_hit")
branch_enemy_projectile_fx("fx_branch_projectile_farmer_rooster_hit", "farmer_rooster_explosion_run", true)

tt = RT("branch_projectile_oloch_instakill", "bolt_oloch_big")
tt.bullet.damage_min = 0
tt.bullet.damage_max = 0
tt.bullet.damage_type = DAMAGE_TRUE

tt = branch_enemy_projectile_template("branch_projectile_juggernaut_eva", "deep_devils_reef_tower_redspine_spear_eva", false, nil, fts(15))
tt.bullet.g = -1
tt.bullet.hit_blood_fx = "fx_blood_splat"

-- Runtime modifiers used by the shared branch enemy controller.
tt = RT("mod_branch_magic_armor", "modifier")
tt.main_script.insert = kr4_scripts.mod_branch_stat.insert
tt.main_script.remove = kr4_scripts.mod_branch_stat.remove
tt.main_script.update = kr4_scripts.mod_branch_stat.update
tt.modifier.duration = 0.5
tt.magic_armor = 0.5

tt = RT("mod_branch_damage", "modifier")
tt.main_script.insert = kr4_scripts.mod_branch_stat.insert
tt.main_script.remove = kr4_scripts.mod_branch_stat.remove
tt.main_script.update = kr4_scripts.mod_branch_stat.update
tt.modifier.duration = 5

tt = RT("mod_zeta_demon_guard_damage", "mod_branch_damage")
tt.modifier.duration = 60
tt.modifier.allows_duplicates = true
tt.damage_factor = 1.2

tt = RT("mod_zeta_oloch_imprison", "mod_stun")
tt.main_script.update = kr4_scripts.mod_zeta_oloch_imprison.update
tt.modifier.duration = 5
tt.modifier.vis_bans = F_BOSS
tt.modifier.resets_same = false
tt.render.sprites[1].prefix = "veznan_cage"
tt.render.sprites[1].name = "in"
tt.render.sprites[1].size_names = nil
tt.render.sprites[1].anchor = v(0.5, 0.15)
tt.render.sprites[1].draw_order = 20
tt.damage = 24
tt.tick = 1
tt.fissure_template = "enemy_zeta_demon_fissure"

tt = RT("mod_branch_sand_mysthic_ray_hit", "mod_track_target_fx")
tt.modifier.duration = 0.7
tt.modifier.use_mod_offset = true
tt.render.sprites[1].name = "sand_mysthic_ray_hit_run"
tt.render.sprites[1].loop = false

tt = RT("mod_zeta_juggernaut_shield", "infuser_cast_shield_mod")
tt.modifier.shield_hp = 9000
tt.modifier.shield_decay = 45
tt.modifier.shield_decay_interval = 0.2
tt.render.sprites[1].prefix = "hero_asra_shield"

tt = RT("mod_zeta_juggernaut_half_health", "modifier")
tt.modifier.duration = 10000
tt.health_factor = 0.5
tt.main_script.insert = kr4_scripts.mod_zeta_juggernaut_half_health.insert
tt.main_script.update = scripts.mod_track_target.update
tt.damage_factor = 1.5

tt = RT("mod_branch_war_elephant_speed", "modifier")
tt.main_script.insert = kr4_scripts.mod_branch_stat.insert
tt.main_script.remove = kr4_scripts.mod_branch_stat.remove
tt.main_script.update = kr4_scripts.mod_branch_stat.update
tt.modifier.duration = 2
tt.speed_factor = 1.5

tt = RT("mod_branch_plant_venom", "modifier")
tt.main_script.update = kr4_scripts.mod_branch_dot.update
tt.modifier.duration = 1
tt.damage = 4
tt.tick = 0.33
tt.damage_type = DAMAGE_TRUE

tt = RT("mod_branch_plant_venom_slow", "modifier")
tt.main_script.insert = kr4_scripts.mod_branch_stat.insert
tt.main_script.remove = kr4_scripts.mod_branch_stat.remove
tt.main_script.update = kr4_scripts.mod_branch_stat.update
tt.modifier.duration = 2
tt.speed_factor = 0.3

tt = RT("dragon_king_water_pool", "decal_scripted")
tt.main_script.update = kr4_scripts.dragon_king_water_pool.update
tt.render.sprites[1].name = "dragon_king_boss_water_pool"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.duration = 8
tt.radius = 30

tt = RT("fx_dragon_king_water_splash", "decal_scripted")
tt.main_script.update = kr4_scripts.dragon_king_water_splash.update
tt.render.sprites[1].name = "dragon_king_boss_death_water_fx_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.18)
tt.render.sprites[1].z = Z_OBJECTS
tt.duration = 0.6

tt = RT("dragon_king_water_bolt", "decal_scripted")
tt.main_script.update = kr4_scripts.dragon_king_water_bolt.update
tt.render.sprites[1].name = "dragon_king_boss_projectile"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_OBJECTS
tt.speed = 520
tt.pool = "dragon_king_water_pool"
tt.hit_fx = "fx_dragon_king_water_splash"
tt.hit_sound = "level25_dragonking_waterballsplash"
tt.extra_pools = {
	{delay = 0.2, radius = 20, offsets = {v(34, 0), v(18, 0)}},
	{delay = 0.4, radius = 25, offsets = {v(38, 35), v(22, 35)}}
}

tt = RT("great_t_meteor_controller", "decal_scripted")
tt.main_script.update = kr4_scripts.great_t_meteor.update
tt.render.sprites[1].prefix = "great_t_meteor_shadow"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].z = Z_DECALS
tt.delay = 1.25
tt.radius = 35
tt.damage_min = 150
tt.damage_max = 190

tt = branch_enemy_template("ice_golem", "snow_golem", 2500, 0.2, 0, 13, 25, 2, 0.25, 47, "snow_golem_shadow", {spawn_animation = "spawn", melee_slot = 25})
tt.render.sprites[1].name = "idleGolem"
branch_melee(tt, 60, 120, 2, 0.533, "attack")
tt.branch.spawn_sound = "ice_snow_golem_awake"

tt = branch_interactive("ice_block", "snow_golem", "idleGolem", r(-28, -8, 56, 62))
AC(tt, "tower", "tower_holder", "sound_events")
tt.main_script.update = kr4_scripts.ice_block.update
tt.tower.type = "ice_block"
tt.tower.level = 1
tt.tower.can_be_mod = false
tt.tower.can_be_sold = false
tt.tower.menu_offset = v(0, 18)
tt.tower_holder.blocked = true
tt.tower_holder.unblock_price = 200
tt.render.sprites[1].offset = v(0, 21)
tt.ui.click_rect = r(-40, -24, 80, 82)
tt.sound_events.remove = "ice_break"
tt.wave_start = 1
tt.delay_to_spawn = 10
tt.cost = 200
tt.path = 1
tt.subpath = 1
tt.node = 1

local branch_scene_layers = {bilbo = 2, trolley = 2, spawner = 14, not_my_tempo = 5, gummi_bears = 4}

local function branch_anim_decal(name, anim, anchor, z, click_rect)
	local t = RT(name, "decal_scripted")
	t.main_script.update = kr4_scripts.branch_static_decal.update
	t.render.sprites[1].name = anim
	t.render.sprites[1].animated = true
	t.render.sprites[1].anchor = anchor or v(0.5, 0.5)
	t.render.sprites[1].z = z or Z_OBJECTS
	if branch_scene_layers[name] then
		t.animation_group = "layers"
		for i = 1, branch_scene_layers[name] do
			local s = table.deepclone(t.render.sprites[1])
			s.prefix = "kr4_scene_layer" .. i
			s.group = t.animation_group
			s.draw_order = i
			t.render.sprites[i] = s
		end
	end
	if click_rect then
		AC(t, "ui")
		t.ui.can_click = true
		t.ui.can_select = false
		t.ui.click_rect = click_rect
	end
	return t
end

local function branch_layered_anim_decal(name, prefix, anim, layers, anchor, z)
	local t = RT(name, "decal_scripted")
	t.main_script.update = kr4_scripts.branch_static_decal.update
	t.animation_group = "layers"

	for i = 1, layers do
		local s = i == 1 and t.render.sprites[1] or E:clone_c("sprite")

		t.render.sprites[i] = s
		s.prefix = prefix .. i
		s.name = anim
		s.animated = true
		s.anchor = anchor or v(0.5, 0.5)
		s.z = z or Z_OBJECTS
		s.group = t.animation_group
		s.draw_order = i
	end

	return t
end

local function branch_static_frame(name, frame, anchor, z)
	local t = RT(name, "decal")
	t.render.sprites[1].name = frame
	t.render.sprites[1].animated = false
	t.render.sprites[1].anchor = anchor or v(0.5, 0.5)
	t.render.sprites[1].z = z or Z_OBJECTS
	return t
end

local function branch_special_holder(name, anim, anchor)
	local t = RT(name, "tower_holder")
	t.tower.type = name
	t.tower.level = 1
	t.tower.can_be_mod = false
	t.tower.can_be_sold = false
	t.tower.menu_offset = v(0, 18)
	t.tower_holder.blocked = true
	t.render.sprites[1].name = anim
	t.render.sprites[1].animated = true
	t.render.sprites[1].anchor = anchor or v(0.5, 0.22)
	t.render.sprites[1].z = Z_OBJECTS
	t.ui.can_click = true
	t.ui.can_select = true
	t.ui.click_rect = r(-55, -18, 110, 80)
	return t
end

local function branch_layered_special_holder(name, prefix, anim, layers, anchor)
	local t = branch_special_holder(name, anim, anchor)
	t.animation_group = "layers"

	for i = 1, layers do
		local s = i == 1 and t.render.sprites[1] or E:clone_c("sprite")

		t.render.sprites[i] = s
		s.prefix = prefix .. i
		s.name = anim
		s.animated = true
		s.anchor = anchor or v(0.5, 0.22)
		s.z = Z_OBJECTS
		s.group = t.animation_group
		s.draw_order = i
	end

	return t
end

tt = branch_anim_decal("boss_dwarf", "boss_dwarf_idle", v(0.5, 0.5), Z_OBJECTS)
tt.main_script.update = require("bolgur_stage").scene_update
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "boss_dwarf_throne"
tt.render.sprites[2].name = "run"
tt.render.sprites[2].animated = true
tt.render.sprites[2].anchor = v(0.5, 0.5)
tt.render.sprites[2].z = Z_OBJECTS - 1
tt.loop_variants = {
	{animation_idle = "boss_dwarf_idle", animation_end = "boss_dwarf_angry", min_cooldown = 12, max_cooldown = 24},
	{animation_idle = "boss_dwarf_idle", animation_end = "boss_dwarf_steal", min_cooldown = 28, max_cooldown = 45}
}
tt.steal_gold = {
	animation = "boss_dwarf_steal",
	cooldown_min = 45,
	cooldown_max = 50,
	fx = "fx_boss_dwarf_coins",
	fx_pos = v(129, 10),
	gold_steal = 1,
	loops = 10,
	min_gold = 1000,
	sound = "dwarves_boss_dwarf_coin_steal",
	wave_start = 1
}

tt = RT("fx_boss_dwarf_coins", "fx")
tt.render.sprites[1].name = "boss_dwarf_coins_run"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_EFFECTS

tt = branch_anim_decal("viking_boss", "viking_boss_idle", v(0.5, 0.136), Z_OBJECTS)
tt.loop_variants = {
	{animation_idle = "viking_boss_idle", animation_end = "viking_boss_insult", min_cooldown = 18, max_cooldown = 35},
	{animation_idle = "viking_boss_idle", animation_end = "viking_boss_insult2", min_cooldown = 18, max_cooldown = 35}
}

tt = RT("viking_boss_dragon", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.animation_group = "dragon_body"
tt.render.sprites[1].name = "viking_boss_dragon_idle"
tt.render.sprites[1].prefix = "viking_boss_dragon_layer1"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.26)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[1].group = tt.animation_group
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "viking_boss_dragon_rider_idle"
tt.render.sprites[2].prefix = nil
tt.render.sprites[2].animated = true
tt.render.sprites[2].anchor = v(0.5, 0.26)
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.rider_sprite_idx = 2

tt = RT("viking_boss_weapon_impact", "decal_timed")
tt.render.sprites[1].name = "viking_boss_axe_decal_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS
tt.timed.duration = 0.8

tt = RT("viking_boss_weapon_warning", "decal_scripted")
tt.main_script.update = kr4_scripts.macaque_fruit_splash.update
tt.duration = 0.85
tt.render.sprites[1].name = "viking_boss_power_shadows"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[1].alpha = 180

tt = RT("viking_boss_dragon_breath_floor", "decal_timed")
tt.render.sprites[1].name = "viking_boss_dragon_breath_floor_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS
tt.timed.duration = 0.7

tt = RT("viking_boss_dragon_breath_hits", "decal_timed")
tt.render.sprites[1].name = "viking_boss_dragon_breath_hits_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS
tt.timed.duration = 0.7

tt = branch_anim_decal("alleria_end", "alleria_cutscene", v(0.5, 0.25), Z_OBJECTS)
tt.main_script.update = kr4_scripts.alleria_end.update
tt.start_animation = "alleria_cutscene"
tt.leaves_fx = "fx_alleria_leaves"

tt = RT("fx_alleria_leaves", "fx")
tt.render.sprites[1].name = "alleria_leaves_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.25)
tt.render.sprites[1].z = Z_OBJECTS + 1

tt = branch_layered_anim_decal("magnus", "magnus_tower_layer", "idle", 30, v(0.5, 0.136), Z_OBJECTS)
tt.main_script.update = kr4_scripts.magnus.update
tt.magnus = {
	animation_group = tt.animation_group,
	idle_animation = "idle",
	wave_skills = {
		[2] = {skill = "shield", cooldown = 25},
		[3] = {skill = "shield", cooldown = 25},
		[4] = {skill = "tower_block", cooldown = 20},
		[5] = {skill = "poison", cooldown = 20},
		[6] = {skill = "shield", cooldown = 25},
		[7] = {skill = "poison", cooldown = 20},
		[8] = {skill = "tower_block", cooldown = 20},
		[9] = {skill = "tower_block", cooldown = 15},
		[10] = {skill = "shield", cooldown = 22},
		[11] = {skill = "poison", cooldown = 15},
		[12] = {skill = "poison", cooldown = 15},
		[13] = {skill = "tower_block", cooldown = 15},
		[14] = {skill = "shield", cooldown = 15},
		[15] = {skill = "tower_block", cooldown = 15}
	},
	shield = {
		mod = "mod_magnus_arcane_shield",
		duration = 4,
		range = 9999,
		min_targets = 2,
		max_targets = 5,
		animation = "shield",
		loop_animation = "shieldLoop",
		end_animation = "shieldEnd",
		loop_time = 0.25,
		excluded_templates = {
			"enemy_griffin_bombardier",
			"enemy_falconeer",
			"enemy_desert_eagle",
			"enemy_hunting_dog",
			"enemy_golem_house"
		},
		excluded_prefixes = {
			"enemy_high_sorcerer"
		}
	},
	tower_block = {
		mod = "mod_magnus_tower_block",
		duration = 6,
		radius = 420,
		max_targets = 3,
		animation = "block",
		loop_animation = "blockLoop",
		end_animation = "blockEnd",
		loop_time = 0.25,
		excluded_kinds = {
			TOWER_KIND_BARRACK
		},
		excluded_types = {
			"wicked_sisters",
			"balloon"
		},
		excluded_prefixes = {
			"tower_wicked_sisters",
			"tower_balloon",
			"zeppelin"
		}
	},
	poison = {
		aura = "aura_magnus_poison",
		duration = 15,
		search_radius = 120,
		radius = 90,
		min_targets = 2,
		animation = "spoon",
		loop_animation = "spoonLoop",
		end_animation = "spoonEnd",
		loop_time = 0.25
	}
}

tt = branch_layered_anim_decal("ladle", "ladle_layer", "walk", 2, v(0.5, 0), Z_OBJECTS)
tt.ladle_group = tt.animation_group
tt.cauldron_group = "cauldron"
for i = 1, 3 do
	local sid = i + 2
	local s = E:clone_c("sprite")

	tt.render.sprites[sid] = s
	s.prefix = "ladle_cauldron_layer" .. i
	s.name = "idle"
	s.animated = true
	s.anchor = v(0.5, 0)
	s.z = Z_OBJECTS
	s.group = tt.cauldron_group
	s.draw_order = sid
end
tt = branch_layered_anim_decal("house_toad", "house_toad_layer", "idle", 4, v(0.5, 0.35), Z_OBJECTS)
tt = branch_anim_decal("lightseeker_roof", "lightseeker_chair_idle", v(0.5, 0.05), Z_OBJECTS)
tt.main_script.update = kr4_scripts.lightseeker_roof.update
tt.render.sprites[1].offset = v(0, 75)
tt.render.sprites[1].z = Z_OBJECTS_COVERS + 1

tt = branch_anim_decal("denas", "denas_idle", v(0.5, 0.138), Z_OBJECTS_COVERS + 2)
tt.main_script.update = kr4_scripts.branch_looping_decal.update
tt.loop_variants = {
	{animation_idle = "denas_idle", animation_end = "denas_taunt", min_cooldown = 30, max_cooldown = 50},
	{animation_idle = "denas_idle", animation_end = "denas_drink", min_cooldown = 40, max_cooldown = 60}
}

tt = RT("fx_jokull_breath", "fx")
tt.render.sprites[1].name = "mega_boss_dragon_breath_freeze_run"
tt.render.sprites[1].anchor = v(0.5, 0.3)

tt = RT("mod_jokull_freeze", "mod_stun")
tt.modifier.duration = 1

tt = RT("fx_magnus_end_explosion", "fx")
tt.render.sprites[1].name = "magnus_tower_destroyed_explosion_run"
tt.render.sprites[1].anchor = v(0.5, 0.5)


tt = branch_anim_decal("cannon_traffic_guy", "Stage_11_cannon_traffic_guy_idle", v(0.5, 0.2), Z_OBJECTS)
tt.main_script.update = kr4_scripts.branch_looping_decal.update
tt.loop_variants = {
	{animation_idle = "Stage_11_cannon_traffic_guy_idle", animation_end = "Stage_11_cannon_traffic_guy_signs1", min_cooldown = 5, max_cooldown = 10},
	{animation_idle = "Stage_11_cannon_traffic_guy_idle", animation_end = "Stage_11_cannon_traffic_guy_signs2", min_cooldown = 5, max_cooldown = 10},
	{animation_idle = "Stage_11_cannon_traffic_guy_idle", animation_end = "Stage_11_cannon_traffic_guy_signs3", min_cooldown = 5, max_cooldown = 10}
}

tt = branch_layered_anim_decal("stage11_goblin_cannon_left", "Stage_11_cannon_layer", "Stage_11_cannon_loopready", 9, v(0.5, 0.2), Z_OBJECTS + 2)
AC(tt, "ui")
tt.main_script.update = kr4_scripts.stage11_goblin_cannon.update
tt.ui.can_click = false
tt.ui.can_select = false
tt.ui.click_rect = r(-60, -18, 120, 135)
tt.cooldown = 30
tt.action_time = 0.4
tt.side = "left"
tt.tip_offset_x = 30
tt.tip_offset_y = 110

tt = RT("stage11_goblin_cannon_right", "stage11_goblin_cannon_left")
tt.side = "right"
tt.render.sprites[1].flip_x = true
for _, s in pairs(tt.render.sprites) do
	s.flip_x = true
end
tt.tip_offset_x = -30

tt = RT("stage11_cannon_projectile_fx", "decal_timed")
tt.render.sprites[1].name = "mega_boss_dragon_proyectile"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].z = Z_BULLETS
tt.timed.duration = 0.45

tt = RT("mega_boss_dragon_projectile_smoke", "decal_timed")
tt.render.sprites[1].name = "mega_boss_dragon_proyectile_smoke_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.timed.duration = 0.8

tt = RT("mega_boss_dragon_horn_impact", "decal_timed")
tt.render.sprites[1].name = "mega_boss_dragon_explotion_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.18)
tt.render.sprites[1].z = Z_OBJECTS + 1
tt.timed.duration = 0.8

tt = RT("stage161_ice_platform_cracks_fx", "decal_timed")
tt.render.sprites[1].name = "dragon_camouflage_grietas_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_TOWER_BASES
tt.timed.duration = 0.5

tt = RT("stage161_ice_platform_shards_fx", "decal_timed")
tt.render.sprites[1].name = "dragon_camouflage_iceshards_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS + 6
tt.timed.duration = 0.7

tt = branch_layered_anim_decal("stage161_boss_deco", "Stage11_boss_deco_layer", "Stage_11_boss_deco_idle1", 2, v(0.5, 0.5), Z_TOWER_BASES - 8)
tt.render.sprites[2].z = Z_TOWER_BASES - 7

tt = RT("stage161_boss_deco_ice_fx", "decal_timed")
tt.render.sprites[1].name = "Stage_11_boss_deco_ice_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_TOWER_BASES - 6
tt.timed.duration = 0.55

tt = RT("stage11_cannon_explosion_fx", "decal_timed")
tt.render.sprites[1].name = "mega_boss_dragon_explotion_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.18)
tt.render.sprites[1].z = Z_OBJECTS + 3
tt.timed.duration = 0.8

tt = branch_anim_decal("wyvern_spawner", "Stage11_spawn_Effect_run", v(0.5, 0.16), Z_OBJECTS)
tt = branch_anim_decal("teleporter_spawner", "teleporter_decal_run", v(0.5, 0.16), Z_DECALS)

tt = RT("stage164_teleporter_flash", "decal_timed")
tt.render.sprites[1].name = "teleporter_decal_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.16)
tt.render.sprites[1].z = Z_DECALS
tt.timed.duration = fts(69)

tt = RT("door_open", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.render.sprites[1].hidden = true

tt = branch_anim_decal("trolley", "cart_layer_sideWarhammer3", v(0.5, 0.5), Z_OBJECTS)
tt = RT("stage3_trolley", "decal_scripted")
AC(tt, "ui")
tt.main_script.update = kr4_scripts.stage3_trolley.update
tt.render.sprites[1].name = "cart_layer1_sideWarhammer3"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "cart_layer2_sideWarhammer3"
tt.render.sprites[2].animated = true
tt.render.sprites[2].anchor = v(0.5, 0.5)
tt.render.sprites[2].z = Z_OBJECTS
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-58, -26, 116, 70)
tt.duration = 3.2
tt.touches = 4
tt.touch_offset = 18

tt = RT("fx_stage3_trolley_hit", "fx")
tt.render.sprites[1].name = "stage_3_cart_poke_effect_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS + 1

tt = RT("fx_stage3_trolley_explosion", "fx")
tt.render.sprites[1].name = "cart_explotion"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS + 1

tt = RT("decal_stage3_trolley_explosion", "decal_tween")
tt.render.sprites[1].name = "cart_explotionDecal"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{1.5, 255}, {4, 0}}

tt = branch_anim_decal("spawner", "machine_spawner_idle", v(0.5, 0.1), Z_OBJECTS)

tt = branch_layered_anim_decal("stage155_machine_spawner", "machine_spawner_layer", "idle", 14, v(0.5, 0.1), Z_OBJECTS)
tt = branch_static_frame("stage155_machine_spawner_shadow", "machine_spawner_shadow", v(0.5, 0.209), Z_DECALS)
tt = branch_anim_decal("stage155_ramp_spawner", "ramp_idle", v(0.5, 1), Z_DECALS)

tt = branch_layered_anim_decal("stage155_assembly_line", "Stage5_assembly_line_layer", "move", 6, v(0.5, 1), Z_DECALS)

tt = RT("assembly_line", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.render.sprites[1].hidden = true

tt = branch_anim_decal("not_my_tempo", "Stage_7_cuerno_run", v(0.5, 0.33), Z_OBJECTS)
tt = branch_anim_decal("ship", "ship_loop", v(0.5, 0.2), Z_OBJECTS)
tt = branch_anim_decal("iceberg", "iceberg_splash", v(0.5, 0.2), Z_OBJECTS)

tt = RT("stage158_sea_fill", "decal")
tt.render.sprites[1].name = "stage158_sea_fill"
tt.render.sprites[1].animated = false
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].scale = v(2048, 1536)
tt.render.sprites[1].z = Z_BACKGROUND - 100

local stage158_ship_z = Z_OBJECTS_COVERS

tt = RT("stage158_ship", "decal_scripted")
tt.main_script.update = kr4_scripts.stage158_ship.update
tt.render.sprites[1].name = "ship_loop"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.2)
tt.render.sprites[1].z = stage158_ship_z
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "ship_rowings"
tt.render.sprites[2].animated = true
tt.render.sprites[2].anchor = v(0.5, 0.2)
tt.render.sprites[2].z = stage158_ship_z + 1
tt.render.sprites[3] = E:clone_c("sprite")
tt.render.sprites[3].name = "ship_water"
tt.render.sprites[3].animated = true
tt.render.sprites[3].anchor = v(0.5, 0.2)
tt.render.sprites[3].z = stage158_ship_z - 1
tt.render.sprites[4] = E:clone_c("sprite")
tt.render.sprites[4].name = "ship_openDoor"
tt.render.sprites[4].animated = true
tt.render.sprites[4].anchor = v(0.5, 0.2)
tt.render.sprites[4].hidden = true
tt.render.sprites[4].z = stage158_ship_z + 2

tt = branch_static_frame("stage158_iceberg", "Stage8_iceberg", v(0.5, 0.5), Z_DECALS - 10)

tt = RT("fx_stage158_iceberg_splash", "fx")
tt.render.sprites[1].name = "iceberg_splash"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS - 9

tt = RT("fx_stage158_iceberg_crack", "fx")
tt.render.sprites[1].name = "iceberg_terrainCrack"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS - 8

tt = RT("snow_storm", "decal_scripted")
AC(tt, "sound_events")
tt.main_script.update = kr4_scripts.snow_storm.update
tt.render.sprites[1].hidden = true
tt.duration = 15
tt.delay_transition = 3
tt.tower_block_template = "stage10_tower_ice_block"
tt.tower_block_duration = 4
tt.towers_amount = 3
tt.particle_name = "stage10_blizzard_snow"
tt.sound_events.insert = "level10_icestorm"

tt = RT("stage10_blizzard_snow", "ps_stage_snow")
tt.pos = v(337, 706)
tt.particle_system.emission_rate = 150
tt.particle_system.emit_area_spread = v(900, 0)
tt.particle_system.emit_direction = -3 * math.pi / 4
tt.particle_system.emit_speed = {
	900,
	1100
}
tt.particle_system.particle_lifetime = {
	4,
	6
}
tt.particle_system.scale_var = {
	0.25,
	0.45
}

tt = RT("stage10_tower_ice_tap_fx", "fx")
tt.render.sprites[1].prefix = "svell_druid_tower_frost_tap_effect"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.133)
tt.render.sprites[1].z = Z_OBJECTS + 2

tt = RT("stage10_tower_ice_block", "decal_scripted")
AC(tt, "ui", "sound_events")
tt.main_script.update = kr4_scripts.stage10_tower_ice_block.update
tt.duration = 4
tt.required_clicks = 3
tt.unblock_delay = 0.33
tt.y_offset = 20
tt.ui.can_click = true
tt.ui.can_select = nil
tt.ui.click_rect = r(-42, -24, 84, 86)
tt.tap_fx = "stage10_tower_ice_tap_fx"
tt.sound_events.remove = "ice_break"
tt.render.sprites[1].prefix = "svell_druid_tower_frost_layer1"
tt.render.sprites[1].name = "start"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.35)
tt.render.sprites[1].z = Z_EFFECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "svell_druid_tower_frost_layer2"
tt.render.sprites[2].name = "start"
tt.render.sprites[2].animated = true
tt.render.sprites[2].anchor = v(0.5, 0.35)
tt.render.sprites[2].z = Z_EFFECTS + 1

tt = RT("fx_with_animation", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.render.sprites[1].hidden = true

-- KR4 main-campaign scene/cameo objects used by levels 150-165.
tt = branch_anim_decal("bilbo", "Stage_1_bilbo_idle", v(0.5, 0.16), Z_OBJECTS, r(-35, -12, 70, 70))
tt.main_script.update = kr4_scripts.stage1_bilbo.update
tt.min_cooldown = 15
tt.max_cooldown = 30
tt.loop_times = 3

tt = branch_static_frame("condor", "stage_1_condor", v(0.5, 0.5), Z_OBJECTS)
tt = branch_static_frame("moving_cloud", "stage_1_cloud_1", v(0.5, 0.5), Z_OBJECTS)

tt = branch_anim_decal("armadillo", "stage_2_armadillo_idle", v(0.5, 0.18), Z_OBJECTS, r(-32, -12, 64, 56))
tt.click_animation = {"stage_2_armadillo_toBall", "stage_2_armadillo_toIdle"}
tt.loop_animation = "stage_2_armadillo_idle"

tt = RT("multiple_objects", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.render.sprites[1].hidden = true

tt = branch_anim_decal("gollum", "gollum_in", v(0.5, 0.18), Z_OBJECTS, r(-30, -10, 60, 60))
tt.click_animation = {"gollum_laugh", "gollum_mine", "gollum_ring", "gollum_take"}
tt.loop_animation = "gollum_ring"

tt = RT("touch_on_event", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.render.sprites[1].hidden = true

tt = branch_special_holder("holder_frozen_lands_blocked", "terrain_ice_blocked_flag", v(0.5, 0.18))
tt.tower.terrain_style = TERRAIN_STYLE_ICE
tt.render.sprites[1].animated = false
tt.tower_holder.unblock_price = 80
tt.ui.can_click = true

tt = RT("mercenary_troll_hut", "tower_KR5")
AC(tt, "barrack", "vis")
tt.tower.type = "mercenary_troll_hut"
tt.tower.kind = TOWER_KIND_BARRACK
tt.tower.level = 1
tt.tower.price = 0
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.damage_factor = 1
tt.tower.menu_offset = v(0, 18)
tt.info.fn = scripts.tower_barrack_mercenaries.get_info
tt.info.i18n_key = "MERCENARY_TROLL_HUT"
tt.info.portrait = "mercenary_troll_hut_layer1_0001"
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.update = kr4_scripts.mercenary_troll_hut.update
tt.main_script.remove = scripts.tower_barrack.remove
tt.render.sprites[1].prefix = "mercenary_troll_hut_layer1"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].anchor = v(0.5, 0.118)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].prefix = "mercenary_troll_hut_layer2"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].anchor = v(0.5, 0.118)
tt.render.sprites[2].z = Z_OBJECTS
tt.render.door_sids = {1, 2}
tt.barrack.has_door = true
tt.barrack.door_hold_time = 1
tt.barrack.max_soldiers = 3
tt.barrack.rally_range = 145
tt.barrack.respawn_offset = v(0, -14)
tt.barrack.rally_angle_offset = 0
tt.ui.can_click = true
tt.ui.can_select = true
tt.ui.click_rect = r(-58, -20, 116, 85)
tt.sound_events.change_rally_point = "TauntsReinforcementTaunt"

tt = RT("mercenary_troll_hut_2", "mercenary_troll_hut")
tt.tower.price = 50
tt.tower.can_be_sold = true

tt = RT("mercenary_troll_hunter_spear", "soldier_militia")
tt.health.armor = 0
tt.health.dead_lifetime = 3
tt.health.hp_max = 120
tt.health_bar.offset = v(0, 34)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.fn = scripts.soldier_mercenary.get_info
tt.info.portrait = "mercenary_troll_spear_0001"
tt.info.i18n_key = "MERCENARY_TROLL_HUNTER_SPEAR"
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.update = kr4_scripts.kr4_soldier_barrack.update
tt.main_script.remove = scripts.soldier_barrack.remove
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 6
tt.melee.attacks[1].damage_max = 8
tt.melee.attacks[1].hit_time = 0.47
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.range = 60
tt.motion.max_speed = 75
tt.regen.cooldown = 2
tt.regen.health = 10
tt.render.sprites[1].prefix = "mercenary_troll_spear"
tt.render.sprites[1].anchor = v(0.5, 0.23)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "mercenary_troll_spear_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.23)
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].is_shadow = true
tt.soldier.melee_slot_offset = v(18, 0)
tt.sound_events.change_rally_point = "TauntsReinforcementTaunt"
tt.unit.price = 40

tt = RT("mercenary_troll_hunter_axe", "soldier_militia")
AC(tt, "ranged")
tt.health.armor = 0
tt.health.dead_lifetime = 3
tt.health.hp_max = 180
tt.health_bar.offset = v(0, 37)
tt.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
tt.info.fn = scripts.soldier_mercenary.get_info
tt.info.portrait = "mercenary_troll_hunter_0001"
tt.info.i18n_key = "MERCENARY_TROLL_HUNTER_AXE"
tt.info.random_name_format = nil
tt.info.ranged_damage_icon = "physical"
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.update = kr4_scripts.kr4_soldier_barrack.update
tt.main_script.remove = scripts.soldier_barrack.remove
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].damage_max = 20
tt.melee.attacks[1].hit_time = 0.33
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.range = 60
tt.ranged.go_back_during_cooldown = true
tt.ranged.attacks[1].animation = "attackRange"
tt.ranged.attacks[1].bullet = "mercenary_troll_hunter_axe_projectile"
tt.ranged.attacks[1].bullet_start_offset = {v(14, 44)}
tt.ranged.attacks[1].cooldown = 1.3
tt.ranged.attacks[1].max_range = 150
tt.ranged.attacks[1].min_range = 61
tt.ranged.attacks[1].shoot_time = fts(10)
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].vis_flags = F_RANGED
tt.motion.max_speed = 60
tt.regen.cooldown = 2
tt.regen.health = 22
tt.render.sprites[1].prefix = "mercenary_troll_hunter"
tt.render.sprites[1].anchor = v(0.5, 0.29)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "mercenary_troll_hunter_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.29)
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].is_shadow = true
tt.soldier.melee_slot_offset = v(18, 0)
tt.sound_events.change_rally_point = "TauntsReinforcementTaunt"
tt.unit.price = 80

tt = RT("mercenary_troll_hunter_axe_projectile", "arrow")
tt.bullet.damage_min = 8
tt.bullet.damage_max = 12
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = fts(10)
tt.bullet.miss_decal = "mercenary_troll_hunter_axe_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "mercenary_troll_hunter_proy"

tt = RT("mercenary_troll_hunter_axe_decal", "decal_timed")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "mercenary_troll_hunter_decal"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS
tt.timed.duration = 1.5

tt = branch_anim_decal("olaf", "olaf_idle", v(0.5, 0.12), Z_OBJECTS, r(-30, -10, 60, 70))
tt.click_animation = {"olaf_dance", "olaf_toOlaf"}
tt.loop_animation = "olaf_idle"

tt = RT("troll_skater", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.render.sprites[1].hidden = true

tt = branch_anim_decal("penguin", "stage8_penguins_idle", v(0.5, 0.15), Z_OBJECTS, r(-20, -8, 40, 44))
tt.click_animation = {"stage8_penguins_dance", "stage8_penguins_flutter", "stage8_penguins_look"}
tt.loop_animation = "stage8_penguins_idle"

tt = branch_anim_decal("seal", "stage8_seal_idle", v(0.5, 0.14), Z_OBJECTS, r(-28, -8, 56, 42))
tt.click_animation = {"stage8_seal_clap", "stage8_seal_in", "stage8_seal_out"}
tt.loop_animation = "stage8_seal_idle"

tt = branch_anim_decal("hodor", "stage_9_hodor_idle", v(0.5, 0.2), Z_OBJECTS, r(-45, -12, 90, 90))
tt.click_animation = {"stage_9_hodor_tap1", "stage_9_hodor_tap2", "stage_9_hodor_tap3", "stage_9_hodor_idle2"}
tt.loop_animation = "stage_9_hodor_idle"

tt = branch_anim_decal("boneheart_bone", "stage10_boneheart_bone_1_idle", v(0.5, 0.18), Z_OBJECTS, r(-25, -8, 50, 50))
tt.click_animation = {"stage10_boneheart_bone_1_run", "stage10_boneheart_bone_2_run", "stage10_boneheart_bone_2_glow"}
tt.loop_animation = "stage10_boneheart_bone_1_idle"

tt = branch_anim_decal("linirea_joe_dummy", "linirea_joe_idleStanding", v(0.5, 0.14), Z_OBJECTS, r(-30, -10, 60, 70))
tt.main_script.insert = kr4_scripts.stage12_joe_dummy.insert
tt.main_script.update = kr4_scripts.stage12_joe_dummy.update
tt.click_animation = {"linirea_joe_watch", "linirea_joe_straw"}
tt.loop_animation = "linirea_joe_idleStanding"
tt.angry_animation = "linirea_joe_toSayayin"
tt.angry_sound = "linirea_joe_angry"
tt.idle_cooldown_min = 20
tt.idle_cooldown_max = 40
tt.required_sheep = 5
tt.joe_template = "enemy_linirea_joe"
-- KR4 path 0 becomes path 1 here; PC also adds 15 nodes to source node 60.
tt.joe_path = 1
tt.joe_subpath = 1
tt.joe_node = 75

tt = branch_anim_decal("sheep_big", "Stage12_sheep_big_idle", v(0.5, 0.32), Z_OBJECTS, r(-22, -8, 44, 42))
AC(tt, "sound_events")
tt.main_script.update = kr4_scripts.stage12_sheep.update
tt.click_animation = {"Stage12_sheep_big_eatFlower", "Stage12_sheep_big_eatGrass", "Stage12_sheep_big_eatShroom"}
tt.loop_animation = "Stage12_sheep_big_idle"
tt.death_animation = "Stage12_sheep_big_death"
tt.clicks_to_destroy = 5
tt.sound_events.remove = "linirea_high_sorcerer_sheep_explode"

tt = branch_anim_decal("sheep_small", "Stage12_sheep_small_idle", v(0.5, 0.25), Z_OBJECTS, r(-18, -8, 36, 34))
AC(tt, "sound_events")
tt.main_script.update = kr4_scripts.stage12_sheep.update
tt.click_animation = {"Stage12_sheep_small_eat"}
tt.loop_animation = "Stage12_sheep_small_idle"
tt.death_animation = "Stage12_sheep_small_death"
tt.clicks_to_destroy = 5
tt.sound_events.remove = "linirea_high_sorcerer_sheep_explode"

tt = RT("stage12_farm_spawner", "decal_scripted")
tt.main_script.update = kr4_scripts.stage12_farm_spawner.update
tt.render.sprites[1].hidden = true

branch_anim_decal("water_waves", "Stage12_water_shine_run", v(0.5, 0.5), Z_DECALS)
branch_layered_anim_decal("windmill", "Stage12_windmill_layer", "run", 2, v(0.5, 0.5), Z_OBJECTS)
branch_anim_decal("gummi_bears", "stage13_gummi_bears_idle", v(0.5, 0.5), Z_OBJECTS)
branch_anim_decal("path_segment_deco_anim", "stage13_lamp_on", v(0.5, 0.5), Z_OBJECTS)
branch_static_frame("path_segment_deco_glow", "stage13_glow1", v(0.5, 0.2), Z_OBJECTS)
branch_layered_anim_decal("dark_light", "Stage14_light_layer", "run", 3, v(0.5, 0.14), Z_OBJECTS)

tt = branch_anim_decal("groot", "stage15_groot_idle1", v(0.5, 0.14), Z_OBJECTS, r(-48, -12, 96, 96))
tt.click_animation = {"stage15_groot_dance", "stage15_groot_call1", "stage15_groot_call2", "stage15_groot_to2"}
tt.loop_animation = "stage15_groot_idle1"

tt = RT("spider_nest", "tower_KR5")
AC(tt, "barrack", "powers", "vis")
tt.tower.type = "spider_nest"
tt.tower.kind = TOWER_KIND_BARRACK
tt.tower.level = 1
tt.tower.price = 150
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.damage_factor = 1
tt.tower.menu_offset = v(0, 18)
tt.info.fn = scripts.tower_barrack.get_info
tt.info.i18n_key = "TOWER_SPIDER_NEST"
tt.info.portrait = "special_spider_tower_0001"
tt.main_script.insert = scripts.tower_barrack.insert
tt.main_script.update = kr4_scripts.spider_nest_tower.update
tt.main_script.remove = scripts.tower_barrack.remove
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "special_spider_tower_terrain"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].name = "special_spider_tower_idle"
tt.render.sprites[2].animated = true
tt.render.sprites[2].anchor = v(0.5, 0.22)
tt.render.sprites[2].offset = v(0, -12)
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].name = "special_spider_tower_egg_1_idleClosed"
tt.render.sprites[3].animated = true
tt.render.sprites[3].anchor = v(0.258, 0.45)
tt.render.sprites[3].offset = v(-30, 8)
tt.render.sprites[3].z = Z_OBJECTS + 1
tt.render.sprites[4] = CC("sprite")
tt.render.sprites[4].name = "special_spider_tower_egg_3_idleClosed"
tt.render.sprites[4].animated = true
tt.render.sprites[4].anchor = v(0.75, 0.34)
tt.render.sprites[4].offset = v(35, -2)
tt.render.sprites[4].z = Z_OBJECTS + 1
tt.render.sprites[4].hidden = true
tt.render.sprites[5] = CC("sprite")
tt.render.sprites[5].name = "special_spider_tower_egg_5_idleClosed"
tt.render.sprites[5].animated = true
tt.render.sprites[5].anchor = v(0.333, 0.18)
tt.render.sprites[5].offset = v(-14, -17)
tt.render.sprites[5].z = Z_OBJECTS + 1
tt.render.sprites[5].hidden = true
tt.barrack.has_door = false
tt.barrack.max_soldiers = 1
tt.barrack.rally_range = 160
tt.barrack.rally_angle_offset = 0
tt.barrack.respawn_offset = v(0, 0)
tt.barrack.soldier_type = "soldier_spider_nest_babyspider"
tt.powers.spiderlings = CC("power")
tt.powers.spiderlings.price_base = 90
tt.powers.spiderlings.price_inc = 90
tt.powers.spiderlings.max_level = 2
tt.powers.sticky_web = CC("power")
tt.powers.sticky_web.price_base = 220
tt.powers.sticky_web.price_inc = 0
tt.powers.sticky_web.max_level = 1
tt.spider_nest = {
	range = 160,
	max_soldiers = 3,
	egg_refresh_cooldown = 15,
	web_range = 160,
	web_tick_time = 0.2,
	web_mod = "mod_spider_nest_web_slow",
	egg_configs = {
		{sid = 3, prefix = "special_spider_tower_egg_1", spawn_x = -30, spawn_y = 21, respawn_delay = 0.6},
		{sid = 4, prefix = "special_spider_tower_egg_3", spawn_x = 35, spawn_y = 11, respawn_delay = 0.6},
		{sid = 5, prefix = "special_spider_tower_egg_5", spawn_x = -14, spawn_y = 0, respawn_delay = 0.6}
	},
	web_offsets = {
		{x = -24, y = 4, scale = 1},
		{x = 11, y = 5, scale = 1},
		{x = 14, y = 26, scale = 1},
		{x = -24, y = 27, scale = 1},
		{x = -15, y = 110, scale = 1},
		{x = -32, y = 84, scale = 0.7},
		{x = 20, y = 80, scale = 1},
		{x = 40, y = 113, scale = 0.7},
		{x = 70, y = 85, scale = 0.7},
		{x = -35, y = -80, scale = 1},
		{x = -84, y = -67, scale = 0.7},
		{x = -92, y = -36, scale = 1},
		{x = -41, y = -45, scale = 1},
		{x = 0, y = -60, scale = 0.7}
	}
}
tt.ui.can_click = true
tt.ui.can_select = true
tt.ui.click_rect = r(-58, -18, 116, 85)
tt.sound_events.change_rally_point = "TauntsReinforcementTaunt"

tt = RT("spider_nest_2", "spider_nest")
tt.tower.price = 50
tt.tower.can_be_sold = true

tt = RT("spider_nest_web_fx", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.render.sprites[1].name = "special_spider_tower_web_special_run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_DECALS

tt = RT("mod_spider_nest_web_slow", "mod_slow")
tt.modifier.duration = 0.5
tt.slow.factor = 0.8

tt = RT("soldier_spider_nest_babyspider", "soldier_militia")
AC(tt, "nav_grid")
tt.health.armor = 0
tt.health.dead_lifetime = 3
tt.health.hp_max = 90
tt.health.magic_armor = 0
tt.health_bar.offset = v(0, 30)
tt.health_bar.type = HEALTH_BAR_SIZE_SMALL
tt.info.fn = scripts.soldier_barrack.get_info
tt.info.i18n_key = "TOWER_SPIDER_NEST_UNIT"
tt.info.portrait = "special_spider_tower_babyspider_0001"
tt.info.random_name_format = nil
tt.main_script.insert = scripts.soldier_barrack.insert
tt.main_script.update = kr4_scripts.kr4_soldier_barrack.update
tt.main_script.remove = scripts.soldier_barrack.remove
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 30
tt.melee.attacks[1].damage_max = 50
tt.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
tt.melee.attacks[1].hit_time = 0.6
tt.melee.attacks[1].vis_bans = bor(F_CLIFF)
tt.melee.attacks[1].vis_flags = F_BLOCK
tt.melee.range = 60
tt.motion.max_speed = 60
tt.regen.cooldown = 2
tt.regen.health = 0
tt.render.sprites[1].prefix = "special_spider_tower_babyspider"
tt.render.sprites[1].anchor = v(0.5, 0.109)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "special_spider_tower_babyspider_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.109)
tt.render.sprites[2].z = Z_DECALS
tt.render.sprites[2].is_shadow = true
tt.self_damage = {
	cooldown = 2,
	damage = 9,
	damage_type = DAMAGE_TRUE
}
tt.soldier.melee_slot_offset = v(12, 0)
tt.sound_events.change_rally_point = "TauntsReinforcementTaunt"
tt.unit.price = 0

tt = branch_layered_special_holder("linirea_house_swap_blacksmith", "blacksmith_layer", "idle", 2, v(0.5, 0.18))
tt.tower_holder.blocked = false
tt.tower_holder.unblock_price = nil
tt.ui.can_click = false
tt.ui.can_select = false
tt.ui.click_rect = r(-75, -22, 90, 80)

tt = branch_layered_special_holder("linirea_house_swap_stable", "stable_layer", "idle", 2, v(0.5, 0.22))
tt.tower_holder.blocked = false
tt.tower_holder.unblock_price = nil
tt.ui.can_click = false
tt.ui.can_select = false
tt.ui.click_rect = r(-70, -20, 120, 90)

tt = RT("linirea_caravan", "tower_KR5")
AC(tt, "attacks", "user_selection", "vis")
tt.tower.type = "linirea_caravan"
tt.tower.level = 1
tt.tower.price = 0
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.can_hover = true
tt.tower.damage_factor = 1
tt.tower.menu_offset = v(0, 18)
tt.info.fn = kr4_scripts.linirea_caravan.get_info
tt.info.i18n_key = "TOWER_CARAVAN"
tt.info.portrait = "caravan"
tt.main_script.update = kr4_scripts.linirea_caravan.update
tt.user_selection.can_select_point_fn = kr4_scripts.linirea_caravan.can_select_point
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "caravan"
tt.render.sprites[2].anchor = v(0.5, 0.22)
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].prefix = "caravan_thief"
tt.render.sprites[3].name = "idle"
tt.render.sprites[3].anchor = v(0.5, 0.12)
tt.render.sprites[3].offset = v(0, 18)
tt.render.sprites[3].z = Z_OBJECTS
tt.render.thief_sid = 3
tt.attacks.list[1] = CC("custom_attack")
tt.attacks.list[1].price = 60
tt.attacks.list[1].packs = {
	{"soldier_linirea_caravan_bandit", "soldier_linirea_caravan_raider"},
	{"soldier_linirea_caravan_bandit", "soldier_linirea_caravan_marauder"},
	{"soldier_linirea_caravan_bandit", "soldier_linirea_caravan_bandit"}
}
tt.attacks.list[2] = CC("custom_attack")
tt.attacks.list[2].price = 120
tt.attacks.list[2].packs = {
	{"soldier_linirea_caravan_bandit", "soldier_linirea_caravan_bandit", "soldier_linirea_caravan_raider"},
	{"soldier_linirea_caravan_bandit", "soldier_linirea_caravan_bandit", "soldier_linirea_caravan_marauder"}
}
tt.caravan_offsets = {
	default = {v(0, 0)},
	[2] = {v(-12, 0), v(12, 0)},
	[3] = {v(-18, -4), v(0, 10), v(18, -4)}
}
tt.spawn_fx = "fx_linirea_caravan_call"
tt.spawn_fx_y_offset = 50
tt.ui.can_click = true
tt.ui.can_select = true
tt.ui.click_rect = r(-55, -18, 110, 80)

tt = RT("linirea_caravan_2", "linirea_caravan")
tt.tower.price = 50
tt.tower.can_be_sold = true

tt = RT("zeta_eva2_factory", "tower_KR5")
AC(tt, "attacks", "user_selection", "vis")
tt.tower.type = "zeta_eva2_factory"
tt.tower.level = 1
tt.tower.price = 0
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.can_hover = true
tt.tower.damage_factor = 1
tt.tower.menu_offset = v(0, 16)
tt.info.fn = kr4_scripts.zeta_eva2_factory.get_info
tt.info.i18n_key = "EVA_FACTORY"
tt.info.portrait = "gui4_bottom_info_image_enemies_0005"
tt.main_script.update = kr4_scripts.zeta_eva2_factory.update
tt.user_selection.can_select_point_fn = kr4_scripts.linirea_caravan.can_select_point
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "Stage_86_stone_0001"
tt.render.sprites[2].anchor = v(0.5, 0.125)
tt.render.sprites[2].offset = v(5, -8)
tt.render.sprites[2].z = Z_OBJECTS
tt.attacks.list[1] = CC("custom_attack")
tt.attacks.list[1].price = 100
tt.max_units = 5
tt.soldier_template = "soldier_zeta_chomp_bot_ally"
tt.spawn_offset = v(-8, 6)
tt.ui.can_click = true
tt.ui.can_select = true
tt.ui.click_rect = r(-40, -25, 80, 70)

tt = RT("soldier_zeta_chomp_bot_ally", "soldier_militia")
tt.health.hp_max = 180
tt.health.armor = 0.3
tt.health.magic_armor = 0
tt.health.dead_lifetime = 9
tt.health_bar.offset = v(0, 30)
tt.info.i18n_key = "ENEMY_CHOMP_BOT"
tt.info.portrait = "gui4_bottom_info_image_enemies_0005"
tt.info.random_name_count = 0
tt.info.random_name_format = nil
tt.main_script.remove = kr4_scripts.soldier_zeta_chomp_bot_ally.remove
tt.melee.attacks[1].animation = "attack"
tt.melee.attacks[1].cooldown = 0.8
tt.melee.attacks[1].damage_min = 20
tt.melee.attacks[1].damage_max = 30
tt.melee.attacks[1].hit_time = 0.13
tt.melee.attacks[1].hit_times = {0.13, 0.33, 0.53}
tt.melee.attacks[1].loops = 1
tt.melee.range = 65
tt.motion.max_speed = 58
tt.regen.health = 0
tt.render.sprites[1].anchor = v(0.5, 0.21)
tt.render.sprites[1].prefix = "chompbot"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].angles.walk = {"walk"}
tt.render.sprites[1].offset = v(0, 15)
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "chompbot_shadow"
tt.render.sprites[2].anchor = v(0.5, 0.21)
tt.render.sprites[2].offset = v(0, 15)
tt.render.sprites[2].z = Z_DECALS + 1
tt.render.sprites[2].is_shadow = true
tt.soldier.melee_slot_offset = v(7, 0)
tt.sound_events.death = "dwarves_mechadwarf_death"
tt.ui.click_rect = r(-17, 0, 34, 30)
tt.unit.blood_color = BLOOD_NONE
tt.unit.head_offset = v(0, 26)
tt.unit.hit_offset = v(0, 12)
tt.unit.marker_offset = v(0, 0)
tt.unit.mod_offset = v(0, 16)
tt.unit.price = 15
tt.death_refund = 15

tt = RT("zeta_level19_iron_tower", "tower_KR5")
AC(tt, "attacks", "vis")
tt.tower.type = "zeta_level19_iron_tower"
tt.tower.level = 1
tt.tower.price = 0
tt.tower.can_be_sold = false
tt.tower.can_be_mod = false
tt.tower.damage_factor = 1
tt.tower.menu_offset = v(0, 4)
tt.info.fn = kr4_scripts.zeta_level19_iron_tower.get_info
tt.info.i18n_key = "TOWER_LEVEL19_IRON_TOWER"
tt.info.portrait = "gui4_bottom_info_image_enemies_0066"
tt.main_script.update = kr4_scripts.zeta_level19_iron_tower.update
tt.main_script.remove = kr4_scripts.zeta_level19_iron_tower.remove
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrains_%04i"
tt.render.sprites[1].offset = v(0, 10)
tt.render.sprites[1].z = Z_DECALS
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = true
tt.render.sprites[2].prefix = "bullywags_erudite"
tt.render.sprites[2].name = "idle"
tt.render.sprites[2].anchor = v(0.5, 0.122)
tt.render.sprites[2].offset = v(54, 18)
tt.render.sprites[2].z = Z_OBJECTS
tt.attacks.range = 175
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].animation = "ranged"
tt.attacks.list[1].bullet = "enemy_bullywags_erudite_upgrade_bolt"
tt.attacks.list[1].bullet_start_offset = {v(54, 58)}
tt.attacks.list[1].cooldown = 1.4
tt.attacks.list[1].shoot_time = 0.33
tt.attacks.list[1].max_stored_bullets = 15
tt.attacks.list[1]._stored_bullets = {}
tt.attacks.list[1].storage_offsets = {
	v(54, 63), v(60, 62), v(65, 60), v(69, 57), v(70, 54),
	v(66, 51), v(62, 49), v(57, 48), v(51, 48), v(46, 49),
	v(42, 51), v(38, 54), v(39, 57), v(43, 60), v(48, 62)
}
tt.ui.can_click = true
tt.ui.can_select = true
tt.ui.click_rect = r(20, -5, 70, 75)

tt = RT("fx_linirea_caravan_call", "decal_tween")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "caravan_thief_call"
tt.render.sprites[1].anchor = v(0.5, 0.5)
tt.render.sprites[1].z = Z_OBJECTS
tt.tween.props[1].keys = {{0, 255}, {1.65, 255}, {1.9, 0}}

local function linirea_caravan_soldier_template(name, prefix, i18n_key, portrait, hp, armor, speed, lifetime, anchor_y_value, bar_y, slot_x, hit_y, mod_y)
	local t = RT(name, "soldier_militia")

	AC(t, "reinforcement")

	t.health.armor = armor
	t.health.dead_lifetime = 3
	t.health.hp_max = hp
	t.health_bar.offset = v(0, bar_y)
	t.health_bar.type = HEALTH_BAR_SIZE_MEDIUM
	t.info.fn = scripts.soldier_reinforcement.get_info
	t.info.i18n_key = i18n_key
	t.info.portrait = portrait
	t.info.random_name_count = 0
	t.info.random_name_format = nil
	t.main_script.insert = kr4_scripts.kr4_reinforcement.insert
	t.main_script.update = kr4_scripts.kr4_reinforcement.update
	t.melee.attacks[1].animation = "attack"
	t.melee.attacks[1].damage_type = DAMAGE_PHYSICAL
	t.melee.attacks[1].vis_bans = bor(F_CLIFF)
	t.melee.attacks[1].vis_flags = F_BLOCK
	t.melee.range = 60
	t.motion.max_speed = speed
	t.regen.cooldown = 2
	t.regen.health = 0
	t.reinforcement.duration = lifetime
	t.reinforcement.fade = nil
	t.reinforcement.fade_in = nil
	t.reinforcement.fade_out = nil
	t.render.sprites[1].prefix = prefix
	t.render.sprites[1].name = "idle"
	t.render.sprites[1].anchor = v(0.5, anchor_y_value)
	t.render.sprites[1].angles.walk = {"walk"}
	t.render.sprites[2] = CC("sprite")
	t.render.sprites[2].animated = false
	t.render.sprites[2].name = prefix .. "_shadow"
	t.render.sprites[2].anchor = v(0.5, anchor_y_value)
	t.render.sprites[2].z = Z_DECALS
	t.render.sprites[2].is_shadow = true
	t.soldier.melee_slot_offset = v(slot_x, 0)
	t.ui.click_rect = r(-16, 0, 32, math.max(32, bar_y))
	t.unit.hit_offset = v(0, hit_y)
	t.unit.marker_offset = v(0, 0)
	t.unit.mod_offset = v(0, mod_y)
	t.unit.price = 0

	return t
end

tt = linirea_caravan_soldier_template("soldier_linirea_caravan_bandit", "bandit", "BANDIT", "gui_bottom_info_image_enemies_0049", 180, 0, 75, 18, 0.12, 30, 12, 12, 12)
tt.melee.attacks[1].cooldown = 0.6
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].hit_time = 0.23
tt.melee.attacks[1].hit_times = {0.23, 0.43}
tt.melee.attacks[1].loops = 1
tt.melee.attacks[1].animations = {nil, "attack"}

tt = linirea_caravan_soldier_template("soldier_linirea_caravan_raider", "raider", "RAIDER", "gui_bottom_info_image_enemies_0050", 220, 0, 75, 18, 0.15, 42, 19, 20, 20)
AC(tt, "ranged")
tt.info.ranged_damage_icon = "physical"
tt.melee.attacks[1].cooldown = 1
tt.melee.attacks[1].damage_min = 15
tt.melee.attacks[1].damage_max = 25
tt.melee.attacks[1].hit_time = 0.33
tt.ranged.go_back_during_cooldown = true
tt.ranged.attacks[1].animation = "range"
tt.ranged.attacks[1].bullet = "linirea_caravan_raider_projectile"
tt.ranged.attacks[1].bullet_start_offset = {v(0, 20)}
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].max_range = 300
tt.ranged.attacks[1].min_range = 120
tt.ranged.attacks[1].shoot_time = 0.7
tt.ranged.attacks[1].vis_bans = bor(F_NIGHTMARE)
tt.ranged.attacks[1].vis_flags = F_RANGED

tt = RT("linirea_caravan_raider_projectile", "arrow")
tt.bullet.damage_min = 25
tt.bullet.damage_max = 40
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.flight_time = fts(18)
tt.bullet.miss_decal = "linirea_caravan_raider_projectile_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "linirea_caravan_raider_projectile"

tt = RT("linirea_caravan_raider_projectile_decal", "fx")
tt.render.sprites[1].name = "linirea_caravan_raider_projectile_decal_run"

tt = linirea_caravan_soldier_template("soldier_linirea_caravan_marauder", "marauder", "MARAUDER", "gui_bottom_info_image_enemies_0051", 380, 0.5, 75, 18, 0.12, 45, 22, 22, 22)
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].damage_min = 40
tt.melee.attacks[1].damage_max = 60
tt.melee.attacks[1].hit_time = 0.33

tt = RT("branch_water_zone", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_water_zone.update
tt.render.sprites[1].hidden = true
tt.radius = 45

tt = branch_interactive("blackburn_part", "", "", r(-24, -24, 48, 48))
tt.main_script.update = kr4_scripts.blackburn_part.update
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "stage_28_axe"

tt = RT("boss_shaman", "decal_scripted")
tt.main_script.update = kr4_scripts.boss_shaman.update
tt.render.sprites[1].prefix = "great_t_shaman"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].exo = true
tt.render.sprites[1].anchor = v(0.5, 0)
tt.render.sprites[1].hidden = false
tt.render.sprites[1].z = Z_OBJECTS
tt.taunt_cooldown_min = 10
tt.taunt_cooldown_max = 20
tt.taunt_loop_duration = 2.5
tt.end_sounds = {
	{time = 0.2, sound = "kr4_enemies_boss_great_t_hit_melee"},
	{time = 0.7, sound = "kr4_enemies_boss_great_t_hit_melee"},
	{time = 1.2, sound = "kr4_enemies_boss_great_t_hit_melee"},
	{time = 1.7, sound = "kr4_enemies_boss_great_t_roar"}
}

---------------------------------------------------------
-- KR4 powers and reinforcements (levels 150-199)
---------------------------------------------------------

tt = RT("fx_kr4_power_death_ray_coils_hit", "fx")
tt.render.sprites[1].name = "death_ray_projectile_hit_run"
tt.render.sprites[1].z = Z_EFFECTS

tt = RT("ray_kr4_power_death_ray_coils", "decal_scripted")
tt.main_script.update = kr4_scripts.ray_kr4_power_death_ray_coils.update
tt.render.sprites[1].prefix = "death_ray_projectile"
tt.render.sprites[1].name = "travel"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0, 0.5)
tt.render.sprites[1].z = Z_BULLETS
tt.image_width = 212
tt.duration = 0.43
tt.hit_fx = "fx_kr4_power_death_ray_coils_hit"
tt.damage_min = 150
tt.damage_max = 300
tt.damage_type = DAMAGE_TRUE

tt = RT("decal_kr4_power_death_ray_coils", "decal_scripted")
tt.main_script.update = kr4_scripts.decal_kr4_power_death_ray_coils.update
tt.render.sprites[1].prefix = "death_ray_layer1"
tt.render.sprites[1].name = "run"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.078)
tt.render.sprites[1].z = Z_OBJECTS
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].prefix = "death_ray_layer2"
tt.render.sprites[2].name = "run"
tt.render.sprites[2].animated = true
tt.render.sprites[2].anchor = v(0.5, 0.078)
tt.render.sprites[2].z = Z_OBJECTS + 1
tt.base_sid = 1
tt.top_sid = 2
tt.ray = "ray_kr4_power_death_ray_coils"
tt.trigger_dist = 80
tt.cooldown = 180
tt.tick_time = 0.05
tt.action_time = 0.1
tt.shoot_offset = v(0, 34)
tt.vis_flags = bor(F_RANGED)
tt.vis_bans = bor(F_FRIEND)

tt = RT("fx_kr4_reinforcement_demon_summon", "fx")
tt.render.sprites[1].name = "reinforcement_demon_summon_run"
tt.render.sprites[1].anchor = v(0.5, 0.22)
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("fx_kr4_reinforcement_hellion_trident_floor", "fx")
tt.render.sprites[1].name = "reinforcement_hellion_trident_proyectile_floor_run"
tt.render.sprites[1].z = Z_DECALS

tt = RT("fx_kr4_reinforcement_flaming_trident_floor", "fx")
tt.render.sprites[1].name = "reinforcement_flaming_trident_proyectile_floor_run"
tt.render.sprites[1].z = Z_DECALS

tt = RT("fx_kr4_reinforcement_flaming_trident_fire", "fx")
tt.render.sprites[1].name = "reinforcement_flaming_trident_fire_run"
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("fx_kr4_reinforcement_pit_lord_explosion", "fx")
tt.render.sprites[1].name = "reinforcement_pit_lord_explosion_run"
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("fx_kr4_reinforcement_pit_lord_explosion_floor", "fx")
tt.render.sprites[1].name = "reinforcement_pit_lord_explosion_floor_run"
tt.render.sprites[1].z = Z_DECALS

tt = RT("fx_kr4_reinforcement_death_circle_medium", "decal_tween")
tt.render.sprites[1].name = "death_floor_circle_medium"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0.2, 255}, {0.9, 0}}

tt = RT("fx_kr4_reinforcement_death_circle_big", "decal_tween")
tt.render.sprites[1].name = "death_floor_circle_big"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0.2, 255}, {0.9, 0}}

tt = RT("mod_kr4_reinforcement_burn", "mod_lava")
tt.modifier.duration = 2
tt.dps.damage_min = 1
tt.dps.damage_max = 1
tt.dps.damage_inc = 0
tt.dps.damage_type = DAMAGE_PHYSICAL
tt.dps.damage_every = 0.2
tt.dps.kill = false

tt = RT("kr4_reinforcement_hellion_trident_projectile", "arrow")
tt.render.sprites[1].name = "reinforcement_hellion_trident_proyectile"
tt.render.sprites[1].animated = false
tt.render.sprites[1].flip_x = true
tt.bullet.hit_distance = 50
tt.bullet.damage_min = 3
tt.bullet.damage_max = 6
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.hit_fx = "fx_kr4_reinforcement_hellion_trident_floor"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil

tt = RT("kr4_reinforcement_flaming_trident_projectile", "arrow")
tt.render.sprites[1].name = "reinforcement_flaming_trident_proyectile_0001"
tt.render.sprites[1].animated = false
tt.render.sprites[1].flip_x = true
tt.bullet.hit_distance = 50
tt.bullet.damage_min = 10
tt.bullet.damage_max = 14
tt.bullet.damage_type = DAMAGE_PHYSICAL
tt.bullet.hit_fx = "fx_kr4_reinforcement_flaming_trident_floor"
tt.bullet.mod = "mod_kr4_reinforcement_burn"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil

tt = RT("kr4_reinforcement_pit_lord_projectile", "bomb")
tt.render.sprites[1].name = "reinforcement_pit_lord_proyectile_travel"
tt.render.sprites[1].animated = true
tt.bullet.damage_min = 33
tt.bullet.damage_max = 66
tt.bullet.damage_type = DAMAGE_MAGICAL
tt.bullet.damage_radius = 70
tt.bullet.damage_flags = F_AREA
tt.bullet.hit_fx = "fx_kr4_reinforcement_pit_lord_explosion"
tt.bullet.hit_decal = "fx_kr4_reinforcement_pit_lord_explosion_floor"
tt.bullet.flight_time = fts(22)
tt.sound_events.insert = nil
tt.sound_events.hit = nil

local function kr4_reinforcement_template(name, prefix, hp, regen, damage_min, damage_max, armor, speed, lifetime, anchor_y_value, bar_y, hit_y, mod_y)
	local t = RT(name, "soldier_militia")

	AC(t, "reinforcement")

	t.cooldown = 14
	t.info.fn = scripts.soldier_reinforcement.get_info
	t.info.portrait = "gui_bottom_info_image_soldiers_0001"
	t.info.random_name_count = 0
	t.info.random_name_format = nil
	t.main_script.insert = kr4_scripts.kr4_reinforcement.insert
	t.main_script.update = kr4_scripts.kr4_reinforcement.update
	t.health.hp_max = hp
	t.health.armor = armor
	t.health_bar.offset = v(0, bar_y)
	t.motion.max_speed = speed
	t.regen.cooldown = 2
	t.regen.health = regen
	t.reinforcement.duration = lifetime
	t.reinforcement.fade = nil
	t.reinforcement.fade_in = nil
	t.render.sprites[1].prefix = prefix
	t.render.sprites[1].name = "idle"
	t.render.sprites[1].anchor = v(0.5, anchor_y_value)
	t.render.sprites[1].angles.walk = {"walk"}
	t.soldier.melee_slot_offset = v(8, 0)
	t.unit.hit_offset = v(0, hit_y)
	t.unit.mod_offset = v(0, mod_y)
	t.unit.marker_offset = v(0, 0)
	t.melee.attacks[1].cooldown = 1
	t.melee.attacks[1].damage_min = damage_min
	t.melee.attacks[1].damage_max = damage_max
	t.melee.attacks[1].hit_time = 0.3
	t.melee.attacks[1].animation = "attack"
	t.melee.attacks[1].sound = "MeleeSword"
	t.ui.click_rect = r(-15, 0, 30, math.max(28, bar_y))
	t.kr4_reinforcement = {
		base_death_damage = 20,
		base_death_radius = 45,
		base_death_max_count = 5,
		base_death_type = DAMAGE_PHYSICAL,
		death_animation = "infernalCombustionDeath",
		death_decal = "fx_kr4_reinforcement_death_circle_medium",
		summon_fx = "fx_kr4_reinforcement_demon_summon"
	}

	return t
end

kr4_reinforcement_template("soldier_kr4_reinforcement_goonie", "reinforcement_demon_goonie", 30, 3, 1, 2, 0, 75, 12, 0.264, 24, 9, 9)
kr4_reinforcement_template("soldier_kr4_reinforcement_trained_goonie", "reinforcement_improved_goonie", 60, 4, 2, 3, 0.1, 75, 12, 0.264, 26, 9, 9)

tt = kr4_reinforcement_template("soldier_kr4_reinforcement_demon_guard", "reinforcement_demon_guard", 150, 8, 6, 10, 0.2, 75, 18, 0.245, 38, 14, 14)
tt.melee.attacks[1].cooldown = 1.2
tt.soldier.melee_slot_offset = v(23, 0)
tt.info.portrait = "gui_bottom_info_image_soldiers_0002"

tt = RT("soldier_kr4_reinforcement_demon_guard_nova", "soldier_kr4_reinforcement_demon_guard")
tt.kr4_reinforcement.base_death_damage = 50
tt.kr4_reinforcement.base_death_radius = 60
tt.kr4_reinforcement.base_death_max_count = 8
tt.kr4_reinforcement.death_animation = "infernalNovaDeath"

tt = kr4_reinforcement_template("soldier_kr4_reinforcement_hellion_trident", "reinforcement_hellion_trident", 120, 6, 3, 6, 0.1, 75, 16, 0.245, 34, 12, 12)
AC(tt, "ranged")
tt.melee.attacks[1].cooldown = 1.2
tt.ranged.attacks[1].bullet = "kr4_reinforcement_hellion_trident_projectile"
tt.ranged.attacks[1].bullet_start_offset = {v(0, 21)}
tt.ranged.attacks[1].cooldown = 1.5
tt.ranged.attacks[1].max_range = 175
tt.ranged.attacks[1].min_range = 50
tt.ranged.attacks[1].shoot_time = 0.43
tt.ranged.attacks[1].animation = "ranged"
tt.info.portrait = "gui_bottom_info_image_soldiers_0003"

tt = RT("soldier_kr4_reinforcement_flaming_trident", "soldier_kr4_reinforcement_hellion_trident")
tt.render.sprites[1].prefix = "reinforcement_flaming_trident"
tt.ranged.attacks[1].bullet = "kr4_reinforcement_flaming_trident_projectile"
tt.info.portrait = "gui_bottom_info_image_soldiers_0004"

tt = kr4_reinforcement_template("soldier_kr4_reinforcement_pit_lord", "reinforcement_pit_lord", 220, 12, 33, 66, 0.2, 50, 16, 0.1, 57, 20, 20)
AC(tt, "ranged")
tt.render.sprites[1].sort_y_offset = 8
tt.melee.attacks[1].cooldown = 2
tt.melee.attacks[1].hit_time = 0.27
tt.melee.attacks[1].animation = "melee"
tt.ranged.attacks[1].bullet = "kr4_reinforcement_pit_lord_projectile"
tt.ranged.attacks[1].bullet_start_offset = {v(20, 42)}
tt.ranged.attacks[1].ignore_hit_offset = true
tt.ranged.attacks[1].cooldown = 2
tt.ranged.attacks[1].max_range = 100
tt.ranged.attacks[1].min_range = 25
tt.ranged.attacks[1].shoot_time = 0.55
tt.ranged.attacks[1].animation = "ranged"
tt.kr4_reinforcement.base_death_damage = 50
tt.kr4_reinforcement.base_death_radius = 45
tt.kr4_reinforcement.base_death_max_count = 5
tt.kr4_reinforcement.death_animation = "death"
tt.kr4_reinforcement.death_decal = "fx_kr4_reinforcement_death_circle_big"
tt.kr4_reinforcement.summon_fx = nil
tt.kr4_reinforcement.block_idle = "idleBlock"
tt.spawn_animation = "summon"
tt.soldier.melee_slot_offset = v(23, 0)
tt.info.portrait = "gui_bottom_info_image_soldiers_0005"
tt.ui.click_rect = r(-22, 0, 44, 58)

tt = RT("power_kr4_reinforcements_control")
AC(tt, "user_power", "pos", "main_script", "user_selection")
tt.cooldown = 14
tt.main_script.insert = kr4_scripts.power_kr4_reinforcements_control.insert
tt.user_selection.can_select_point_fn = kr4_scripts.power_kr4_reinforcements_control.can_select_point

tt = RT("fx_power_soul_impact", "fx")
tt.render.sprites[1].name = "power_soul_impact_run"
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("fx_power_soul_impact_explosion", "fx")
tt.render.sprites[1].name = "power_soul_impact_explosion_run"
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("fx_power_soul_impact_bolt_hit", "fx")
tt.render.sprites[1].name = "power_soul_impact_bolt_hit"
tt.render.sprites[1].z = Z_OBJECTS

tt = RT("decal_power_soul_impact_explosion", "decal_tween")
tt.render.sprites[1].name = "power_soul_impact_explosion_decal"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.props[1].keys = {{0.2, 255}, {2.2, 0}}

tt = RT("mod_power_soul_impact_slow", "mod_slow")
tt.modifier.duration = 2
tt.slow.factor = 0.5

tt = RT("mod_power_soul_impact_stun", "mod_stun")
tt.modifier.duration = 0.4

tt = RT("power_soul_impact_bolt", "bolt")
tt.render.sprites[1].prefix = "power_soul_impact_bolt"
tt.render.sprites[1].name = "travel"
tt.bullet.damage_min = 7
tt.bullet.damage_max = 22
tt.bullet.damage_type = DAMAGE_TRUE
tt.bullet.min_speed = 180
tt.bullet.max_speed = 540
tt.bullet.acceleration_factor = 0.08
tt.bullet.hit_fx = "fx_power_soul_impact_bolt_hit"
tt.bullet.pop = nil
tt.bullet.pop_conds = nil
tt.sound_events.insert = nil

tt = RT("power_soul_impact_control")
AC(tt, "user_power", "pos", "main_script", "user_selection", "track_kills","sound_events")
tt.cooldown = 70
tt.user_power.level = 0
tt.main_script.update = kr4_scripts.power_soul_impact_control.update
tt.user_selection.can_select_point_fn = kr4_scripts.power_soul_impact_control.can_select_point
tt.soul_impact = {
	impact_count = 3,
	storm_extra = 0,
	max_spread = 40,
	impact_delay = 0.8,
	damage_delay = 0.2,
	damage_min = 25,
	damage_max = 55,
	damage_type = DAMAGE_TRUE,
	damage_radius = 57.5,
	stun_duration = 0,
	spectre_count = 0,
	spectre_range = 175,
	spectre_damage_min = 7,
	spectre_damage_max = 22,
	slow_duration = 0,
	slow_factor = 0.5,
	echo_chance = 0,
	echo_delay = 1,
	kill_cooldown_min = 0,
	kill_cooldown_max = 0
}
tt.sound_events.release = "power_soulimpact_greenbeam"
tt.sound_events.impact = "group_power_soulimpact_impact"
tt.sound_events.spectres = "power_soulimpact_spiritrelease"

-- KR4 Zeta campaign (levels 193-201). Unit metadata below is generated
-- exclusively from the original units_settings.plist.

local zeta_health_bar_types = {
	[0] = HEALTH_BAR_SIZE_SMALL,
	[1] = HEALTH_BAR_SIZE_MEDIUM_LARGE,
	[2] = HEALTH_BAR_SIZE_LARGE
}

local function zeta_raise_enemy(t)
	if not t.render or not t.render.sprites or not t.render.sprites[1] then
		return t
	end

	local name = string.gsub(t.template_name or "", "^enemy_", "")
	-- Only metadata generated from the original Zeta plist is allowed here.
	-- No hand-written visual fallback is permitted here: using one would silently
	-- reintroduce guessed coordinates and classifications.
	local visual = zeta_unit_metadata[name]

	if not visual then
		return t
	end

	-- Keep the original row on every spawned clone.  Scripts that need source
	-- classifications (demon/mecha/zombie eligibility, etc.) can then use the
	-- plist value directly instead of inferring it from a template name.
	t.zeta_source_metadata = visual

	local anchor = visual.anchor
	local hit = visual.hit or v(0, visual.hit_y)
	local mod = visual.mod or v(0, visual.mod_y)
	local head = visual.head or v(visual.head_x, visual.head_y)
	local life_bar = visual.life_bar

	if life_bar == nil and visual.bar_y then
		life_bar = {size = visual.bar_size, y = visual.bar_y}
	end

	-- Zeta's plist is authoritative for the unit's base metadata.  These values
	-- must not depend on which existing FL template happened to be cloned.
	if visual.health_by_difficulty then
		t.health.hp_max = table.deepclone(visual.health_by_difficulty)
	elseif visual.health then
		t.health.hp_max = visual.health
	end
	if visual.armor ~= nil then
		if visual.armor_type == 1 then
			t.health.armor = 0
			t.health.magic_armor = visual.armor / 100
		else
			t.health.armor = visual.armor / 100
			t.health.magic_armor = 0
		end
	end
	if visual.speed then
		t.motion.max_speed = visual.speed
	end
	if visual.gold ~= nil then
		t.enemy.gold = visual.gold
	end
	if visual.skulls ~= nil then
		t.enemy.lives_cost = visual.skulls
	end
	if visual.block_x_position then
		t.enemy.melee_slot = v(visual.block_x_position, 0)
	end

	if visual.source_key then
		t.vis.flags = band(t.vis.flags or 0, bnot(bor(F_FLYING, F_BOSS, F_MINIBOSS)))
		if visual.flying then
			t.vis.flags = bor(t.vis.flags, F_FLYING)
		end
		if visual.is_boss then
			t.vis.flags = bor(t.vis.flags, F_BOSS)
		end
		if visual.is_small_boss then
			t.vis.flags = bor(t.vis.flags, F_MINIBOSS)
		end

		if visual.can_be_blocked == false or visual.flying then
			t.vis.bans = bor(t.vis.bans or 0, F_BLOCK)
		else
			t.vis.bans = band(t.vis.bans or 0, bnot(F_BLOCK))
		end
		if visual.is_modifier_immune then
			t.vis.bans = bor(t.vis.bans or 0, F_MOD)
		else
			t.vis.bans = band(t.vis.bans or 0, bnot(F_MOD))
		end

		-- Missing fields in the source mean the normal selectable/targetable
		-- defaults.  Reset inherited template values as well as applying false.
		t.ui.can_select = visual.can_be_selected ~= false
		t.ui.can_click = visual.can_be_targeted ~= false
		if visual.can_be_targeted == false then
			t.vis.bans = F_ALL
			t.ui.can_select = false
		end
	end

	if visual.death_sound and t.sound_events then
		t.sound_events.death = visual.death_sound
		if visual.delay_death_sound then
			t.sound_events.death_args = {delay = visual.delay_death_sound}
		end
	end
	if t.info then
		if visual.display_name then
			t.info.i18n_key = string.gsub(visual.display_name, "_NAME$", "")
		end
		if visual.display_bottom_image then
			t.info.portrait = visual.display_bottom_image
		end
		if visual.life_bar_boss and visual.life_bar_boss.icon_name then
			t.info.portrait_boss = visual.life_bar_boss.icon_name
		end
	end
	if visual.idle_animation then
		for _, sprite in ipairs(t.render.sprites) do
			if sprite.animated and not sprite.is_shadow then
				sprite.name = visual.idle_animation
			end
		end
	end

	if visual.selector == "selected_big" then
		t.unit.size = UNIT_SIZE_LARGE
	elseif visual.selector == "selected_med" then
		t.unit.size = UNIT_SIZE_MEDIUM
	elseif visual.selector == "selected_small" then
		t.unit.size = UNIT_SIZE_SMALL
	end

	if visual.blood_decal_type == "blood_green" or visual.blood_type == "green" then
		t.unit.blood_color = BLOOD_GREEN
	elseif visual.blood_decal_type == "blood_red" or visual.blood_type == "red" then
		t.unit.blood_color = BLOOD_RED
	elseif visual.is_mecha or visual.can_bleed == false or visual.blood_type == "sparks" then
		t.unit.blood_color = BLOOD_NONE
		t.unit.show_blood_pool = false
	end

	if visual.source_key and not visual.shadow then
		for i = #t.render.sprites, 1, -1 do
			if t.render.sprites[i].is_shadow then
				table.remove(t.render.sprites, i)
			end
		end
	end

	if anchor then
		for _, sprite in ipairs(t.render.sprites) do
			if not sprite.zeta_keep_anchor then
				sprite.anchor = v(anchor.x, anchor.y)
			end
		end
	end

	if life_bar then
		t.health_bar.hidden = false
		t.health_bar.offset = v(0, life_bar.y)
		t.health_bar.type = zeta_health_bar_types[life_bar.size] or t.health_bar.type
	else
		t.health_bar.hidden = true
	end

	t.unit.hit_offset = v(hit.x, hit.y)
	t.unit.mod_offset = v(mod.x, mod.y)
	t.unit.head_offset = v(head.x, head.y)

	-- Selector source sizes in the original jw_gui atlas are 120/84/52 px.
	local click_half_width = visual.selector == "selected_big" and 60 or (visual.selector == "selected_med" and 42 or 26)
	local click_height = life_bar and life_bar.y or head.y
	t.ui.click_rect = r(-click_half_width, 0, click_half_width * 2, click_height)

	if visual.shadow then
		local shadow
		local shadow_source = type(visual.shadow) == "table" and visual.shadow or {sprite = visual.shadow}

		for _, sprite in ipairs(t.render.sprites) do
			if sprite.is_shadow then
				shadow = sprite
				break
			end
		end

		if not shadow then
			shadow = E:clone_c("sprite")
			shadow.animated = false
			shadow.is_shadow = true
			shadow.z = Z_DECALS + 1
			table.insert(t.render.sprites, shadow)
		end



		shadow.name = shadow_source.sprite
		if shadow_source.anchor then
			shadow.anchor = v(shadow_source.anchor.x, shadow_source.anchor.y)
		else
			-- The source omits the shadow anchor when the engine default is intended.
			shadow.anchor = v(0.5, 0.5)
		end
		local shadow_position = shadow_source.position or shadow_source.offset
		shadow.offset = shadow_position and v(shadow_position.x, shadow_position.y) or v(0, 15)
		if shadow_source.scale then
			shadow.scale = v(shadow_source.scale, shadow_source.scale)
		end
	end

	return t
end

local function zeta_use_exoskeleton(t, prefix)
	local sprite = t.render.sprites[1]

	t.render.sprites = {sprite}
	sprite.prefix = prefix
	sprite.name = "idle"
	sprite.animated = true
	sprite.exo = true
	sprite.angles = {
		walk = {"walk", "walk", "walk"}
	}

	return zeta_raise_enemy(t)
end

local function zeta_enemy_variant(name, base, values)
	local t = RT("enemy_" .. name, "enemy_" .. base)
	values = values or {}

	if values.hp then
		t.health.hp_max = values.hp
	end
	if values.armor ~= nil then
		t.health.armor = values.armor
	end
	if values.magic_armor ~= nil then
		t.health.magic_armor = values.magic_armor
	end
	if values.speed then
		t.motion.max_speed = values.speed
	end
	if values.gold ~= nil then
		t.enemy.gold = values.gold
	end
	if values.lives then
		t.enemy.lives_cost = values.lives
	end
	if values.unblockable then
		t.vis.bans = bor(t.vis.bans or 0, F_BLOCK)
	end
	if values.i18n_key then
		t.info.i18n_key = values.i18n_key
	end
	if values.enc_icon then
		t.info.enc_icon = values.enc_icon

		if values.enc_icon_offset ~= nil then
			t.info.enc_icon_offset = values.enc_icon_offset
		elseif values.enc_icon_absolute then
			t.info.enc_icon_offset = 0
		end
	end
	if values.prefix and t.render and t.render.sprites and t.render.sprites[1] then
		t.render.sprites[1].prefix = values.prefix
	end
	if values.single_walk and t.render and t.render.sprites and t.render.sprites[1] then
		t.render.sprites[1].angles = t.render.sprites[1].angles or {}
		t.render.sprites[1].angles.walk = {"walk", "walk", "walk"}
	end
	if values.melee and t.melee and t.melee.attacks and t.melee.attacks[1] then
		local a = t.melee.attacks[1]
		a.damage_min = values.melee[1]
		a.damage_max = values.melee[2]
		a.cooldown = values.melee[3] or a.cooldown
	end

	return zeta_raise_enemy(t)
end

-- The Zeta branch's spiderling is a KR4 unit.  It cannot share the
-- enemy_spiderling name with KR5, whose template and atlas are unrelated.
tt = branch_enemy_template("zeta_spiderling", "special_spider_tower_babyspider_redsmall", 50, 0, 0.4, 65, 4, 1, 0.109, 20, "special_spider_tower_babyspider_redsmall_shadow", {
	single_walk = true,
	swarm_block = {range = 50, break_range = 65},
	i18n_key = "ENEMY_SPIDERLING",
	heal = {
		cooldown = 5,
		range = 45,
		hp_threshold = 1,
		max_targets = 99,
		amount = 25,
		include_self = true,
		include_mecha = true,
		no_animation = true
	}
})
branch_melee(tt, 15, 25, 1, 0.6)
zeta_raise_enemy(tt)

local function zeta_attach_unit_sprite(t, prefix, position, anchor)
	local sprite = E:clone_c("sprite")

	sprite.prefix = prefix
	sprite.name = "idle"
	sprite.animated = true
	sprite.anchor = anchor
	sprite.offset = v(position.x, position.y)
	sprite.z = Z_OBJECTS + 1
	sprite.ignore_start = true
	sprite.zeta_attached_unit = true
	sprite.zeta_attached_offset = v(position.x, position.y)
	sprite.zeta_keep_anchor = true
	table.insert(t.render.sprites, sprite)

	return #t.render.sprites
end

local function zeta_attach_source_unit_sprite(t, source_key, prefix)
	local units = t.zeta_source_metadata and t.zeta_source_metadata.units

	for _, source_unit in ipairs(units or {}) do
		if source_unit.key == source_key and source_unit.position then
			local anchor = source_unit.anchor

			if not anchor then
				error(string.format("missing source anchor for %s", source_key))
			end

			return zeta_attach_unit_sprite(
				t,
				prefix,
				v(source_unit.position.x, source_unit.position.y),
				v(anchor.x, anchor.y)
			)
		end
	end

	error(string.format("missing source unit %s on %s", source_key, t.template_name or "<unknown>"))
end

local function zeta_mount_ranged_attack(t, sprite_id, shoot_offset, animation)
	t.branch.ranged = {
		cooldown = 0.5,
		min_range = 50,
		max_range = 250,
		damage_min = 16,
		damage_max = 20,
		damage_type = DAMAGE_PHYSICAL,
		animation = animation or "special",
		end_animation = "idle",
		hit_time = 0.3,
		projectile = "branch_projectile_northern_huntress",
		shoot_offset = shoot_offset,
		flight_time = fts(22),
		sprite_ids = {sprite_id},
		extra_projectile_chances = {0.26},
		projectile_sound = "axe_release_sound"
	}
end

-- Frozen branch remixes.
zeta_enemy_variant("a_bruiser", "bruiser", {hp = 30, speed = 33, gold = 3, melee = {2, 4, 1}})
zeta_enemy_variant("a_warhammer_guard", "warhammer_guard", {hp = 70, armor = 0.2, speed = 33, gold = 8, melee = {5, 7, 1}})
zeta_enemy_variant("apex_stalker_xblock", "apex_stalker", {unblockable = true})
tt = zeta_enemy_variant("blue_wyvern_mounts", "blue_wyvern", {hp = 200, magic_armor = 0.5, speed = 35, gold = 25})
tt.branch.death_spawn = "enemy_blue_wyvern"
local zeta_blue_wyvern_rider_sid = zeta_attach_source_unit_sprite(tt, "blue_wyvern_rider", "northern_huntress")
zeta_mount_ranged_attack(tt, zeta_blue_wyvern_rider_sid, v(43, 80))

tt = zeta_enemy_variant("blue_wyvern_mounts_xblock", "blue_wyvern_mounts", {unblockable = true})
tt.branch.ranged = nil
zeta_enemy_variant("boron_alchemist", "sulfur_alchemist", {hp = 160, armor = 0.8, magic_armor = 0, speed = 33, gold = 16, i18n_key = "ENEMY_BORON_ALCHEMIST", enc_icon = 134})
zeta_enemy_variant("boron_alchemist_fast", "boron_alchemist", {speed = 50})
tt = zeta_enemy_variant("bruiser_legion", "bruiser", {hp = 30, speed = 33, gold = 3, melee = {2, 4, 1}})
tt.render.sprites[1].offset.y = (tt.render.sprites[1].offset.y or 0) - 13
zeta_enemy_variant("bruiser_legion_fast", "bruiser_legion", {speed = 50, melee = {2, 4, 0.6}})
zeta_enemy_variant("bruiser_pillar", "bruiser", {hp = 1600, speed = 33, gold = 3, melee = {20, 40, 1}})
zeta_enemy_variant("chomp_bot_fast", "chomp_bot", {hp = 120, armor = 0.3, speed = 60, gold = 15, melee = {20, 30, 0.72}})
zeta_enemy_variant("chomp_bot_pillar", "chomp_bot", {hp = 12000, armor = 0.3, speed = 26, gold = 18, melee = {200, 300, 1.2}})
zeta_enemy_variant("clockwork_spider_fast", "clockwork_spider", {hp = 40, magic_armor = 0.2, speed = 200, gold = 3, melee = {2, 3, 0.72}})
zeta_enemy_variant("clockwork_spider_pillar", "clockwork_spider", {hp = 3600, magic_armor = 0.2, speed = 60, gold = 4, melee = {20, 30, 1.2}})
tt = zeta_enemy_variant("cyclopter_engineer", "cyclopter_pilot", {hp = 720, armor = -0.5, speed = 33, gold = 40})
local zeta_cyclopter_rider_sid = zeta_attach_source_unit_sprite(tt, "cyclopter_rider", "smokebeard_engineer")
tt.render.sprites[zeta_cyclopter_rider_sid].offset.x = tt.render.sprites[zeta_cyclopter_rider_sid].offset.x + 10
for _, sprite in ipairs(tt.render.sprites) do
	if sprite.is_shadow then
		sprite.offset.y = sprite.offset.y + 6
	end
end
zeta_mount_ranged_attack(tt, zeta_cyclopter_rider_sid, v(61, 82), "attack")
zeta_enemy_variant("cyclopter_pilot_pillar", "cyclopter_pilot", {hp = 3600, speed = 37, gold = 4})
zeta_enemy_variant("draugr", "draugr_gold", {hp = 150, magic_armor = 0.8, speed = 24, gold = -3, melee = {6, 9, 1.2}})
zeta_enemy_variant("draugr_armor", "draugr_gold", {hp = 300, armor = 0.8, magic_armor = 0, speed = 24, gold = 10, melee = {12, 18, 1.2}})
zeta_enemy_variant("draugr_xblock", "draugr", {gold = 0, unblockable = true})
zeta_enemy_variant("draugr_armor_xblock", "draugr_armor", {unblockable = true})
zeta_enemy_variant("frozen_heart_dup", "frozen_heart", {hp = 500, speed = 13, gold = 0, melee = {35, 45, 1}})
zeta_enemy_variant("frozen_soul_mage", "frozen_soul", {
	hp = 180,
	armor = 0,
	magic_armor = 0.85,
	speed = 18,
	gold = 0,
	i18n_key = "ENEMY_FROZEN_SOUL_MAGE",
	enc_icon = 137
})
zeta_enemy_variant("glacial_wolf_xblock", "glacial_wolf", {unblockable = true})
zeta_enemy_variant("ice_witch_xblock", "ice_witch", {unblockable = true})
zeta_enemy_variant("nanoq_warbear_xblock", "nanoq_warbear", {unblockable = true})
zeta_enemy_variant("northern_berserker_xblock", "northern_berserker", {unblockable = true})
zeta_enemy_variant("northern_huntress_xblock", "northern_huntress", {unblockable = true})
zeta_enemy_variant("northern_wildling_xblock", "northern_wildling", {armor = 0.4, unblockable = true})
zeta_enemy_variant("valkyrie_xblock", "valkyrie", {unblockable = true})

tt = branch_enemy_template("winter_lord_mage", "winter_lord", 1000, 0, 0.5, 30, 150, 1, 0.15, 43, "winter_lord_shadow", {
	i18n_key = "ENEMY_WINTER_LORD_MAGE", enc_icon = 136, offset_y = 20,
	spawn = {cooldown = 14, count = 2, template = "enemy_frozen_soul_mage", animation = "attack"},
	heal = {cooldown = 14, range = 110, factor = 0.3, max_targets = 3, no_animation = true, mod = "mod_branch_freeze", duration = 3}
})
branch_melee(tt, 105, 135, 3, 0.4)
zeta_raise_enemy(tt)
zeta_enemy_variant("winter_lord_mage_xblock", "winter_lord_mage", {unblockable = true})

tt = branch_enemy_template("winter_lord_soldier", "winter_lord", 1000, 0.5, 0, 30, 75, 1, 0.15, 43, "winter_lord_shadow", {area_melee = 90, i18n_key = "ENEMY_WINTER_LORD_SOLDIER", enc_icon = 135})
branch_melee(tt, 105, 135, 3, 0.4)
zeta_raise_enemy(tt)
zeta_enemy_variant("winter_wolf", "glacial_wolf", {hp = 280, armor = 0, magic_armor = 0.5, speed = 60, gold = 35, melee = {20, 40, 1}})

-- Dwarf and Linirea remixes.
zeta_enemy_variant("mechadwarf_fast", "mechadwarf", {speed = 27, melee = {40, 60, 1.2}})
zeta_enemy_variant("mechadwarf_boss", "mechadwarf", {hp = 19200, armor = 0.7, speed = 18, gold = 280, lives = 20, melee = {400, 600, 1.2}})
zeta_enemy_variant("mechadwarf_eva", "mechadwarf", {hp = 1200, armor = 0, magic_armor = 0.7, speed = 18, gold = 50, melee = {40, 60, 1.2}})
zeta_enemy_variant("mechadwarf_eva_boss", "mechadwarf_boss", {hp = 63000, armor = -0.5, magic_armor = 0, speed = 20, gold = 200, melee = {400, 600, 1.2}})
zeta_enemy_variant("smokebeard_engineer_fast", "smokebeard_engineer", {hp = 360, armor = 0.6, speed = 54, gold = 24, melee = {8, 12, 0.6}})
zeta_enemy_variant("smokebeard_engineer_boss", "smokebeard_engineer", {hp = 32000, armor = 0.6, speed = 24, gold = 240, lives = 20, melee = {80, 120, 1}})
zeta_enemy_variant("stonebeard_geomancer_pillar", "stonebeard_geomancer", {hp = 40000, speed = 21, gold = 50, melee = {340, 500, 1.2}})
zeta_enemy_variant("test_geomancer", "stonebeard_geomancer", {hp = 3000, armor = 0, magic_armor = 0.6, speed = 21, gold = 50, melee = {102, 150, 1.2}})
zeta_enemy_variant("sulfur_alchemist_fast", "sulfur_alchemist", {speed = 50})
zeta_enemy_variant("svell_druid_architect_xblock", "svell_druid", {hp = 1100, armor = 0.6, magic_armor = 0, gold = 70, lives = 2, unblockable = true})
zeta_enemy_variant("tinbeard_gunman_fast", "tinbeard_gunman", {speed = 50, gold = 4, melee = {9, 13, 1.2}})
zeta_enemy_variant("tinbeard_gunman_pillar", "tinbeard_gunman", {hp = 5400, speed = 33, gold = 4, melee = {90, 130, 2}})
zeta_enemy_variant("tinbeard_gunman_lightning", "tinbeard_gunman", {speed = 22, gold = 20, melee = {9, 13, 2}})
zeta_enemy_variant("tinbeard_gunman_lightning_pillar", "tinbeard_gunman_lightning", {hp = 9000, melee = {90, 130, 2}})
zeta_enemy_variant("warhammer_guard_fast", "warhammer_guard", {speed = 50, melee = {5, 7, 0.6}})
zeta_enemy_variant("warhammer_guard_pillar", "warhammer_guard", {hp = 5400, speed = 33, melee = {50, 70, 1}})
zeta_enemy_variant("royal_engineer", "smokebeard_engineer", {hp = 720, armor = 0.6, speed = 30, gold = 60, lives = 2, melee = {8, 12, 1}})
zeta_enemy_variant("royal_engineer_weak", "royal_engineer", {})
tt = zeta_enemy_variant("kr2_mecha", "mechadwarf", {hp = 800, armor = 0.5, speed = 40, gold = 50})
zeta_use_exoskeleton(tt, "mecha")
tt = zeta_enemy_variant("kr2_mecha_engineer", "kr2_mecha", {})
zeta_use_exoskeleton(tt, "mecha")
zeta_attach_source_unit_sprite(tt, "mecha_engineer_rider", "smokebeard_engineer")
tt = zeta_enemy_variant("kr2_mecha_engineer_boss", "kr2_mecha", {hp = 8000, speed = 16, gold = 250, lives = 5})
zeta_use_exoskeleton(tt, "mecha")
zeta_attach_source_unit_sprite(tt, "mecha_engineer_rider", "smokebeard_engineer")
zeta_enemy_variant("music_player_eva", "tinbeard_gunman", {
	hp = 110, armor = 0, magic_armor = 0.6, speed = 1, gold = 0, unblockable = true,
	prefix = "elves_shadow", single_walk = true
})

-- Wasteland and infernal units with their Zeta-specific HD animation sets.
zeta_enemy_variant("harasser", "raider", {
	hp = 275, armor = 0.5, speed = 50, gold = 25,
	prefix = "elves_soldier_harasser_lvl4", single_walk = true
})
zeta_enemy_variant("troll_champion", "forest_troll", {
	hp = 480, speed = 28, gold = 50, lives = 2,
	prefix = "mercenary_troll_hunter", single_walk = true
})
tt = branch_enemy_template("matriarch", "special_spider_tower_babyspider_redlarge", 400, 0.6, 0, 40, 30, 3, 0.2, 35, nil, {
	single_walk = true,
	heal = {cooldown = 5, range = 67.5, hp_threshold = 1, max_targets = 99, amount = 25, include_self = true, include_mecha = true, no_animation = true},
	lay_egg = {cooldown = 6, cooldown_min = 6, cooldown_max = 9, safe_nodes_to_exit = 20, animation = "attack", cast_time = 0.6, egg_template = "zeta_spider_egg", spawn_template = "enemy_zeta_spiderling", spawn_count = 2}
})
branch_melee(tt, 18, 30, 1, 0.6)
zeta_raise_enemy(tt)

tt = branch_enemy_template("ruin_spider", "special_spider_tower_babyspider", 200, 0, 0.5, 55, 18, 1, 0.2, 35, nil, {
	single_walk = true, i18n_key = "ENEMY_RUIN_SPIDER", enc_icon = 141,
	heal = {cooldown = 5, range = 54, hp_threshold = 1, max_targets = 99, amount = 25, include_self = true, include_mecha = true, no_animation = true}
})
branch_melee(tt, 30, 50, 1, 0.35)
zeta_raise_enemy(tt)

tt = branch_enemy_template("toxic_blob", "rednuclear_blob", 300, 0, 0, 22, 20, 1, 0.2, 38, nil, {single_walk = true, area_melee = 45, i18n_key = "ENEMY_LCL", enc_icon = 138})
branch_melee(tt, 20, 40, 2, 0.4)
zeta_use_exoskeleton(tt, "rednuclear_blob")

tt = branch_enemy_template("cerberus", "Cerberus", 6000, 0.8, 0, 50, 350, 5, 0.2, 64, nil, {
	area_melee = 82.5, area_melee_max_count = 5, area_melee_hit_offset = v(22.5, 0), spawn_animation = "spawn",
	death_damage = {range = 140, damage_min = 666, damage_max = 666, damage_type = DAMAGE_PHYSICAL, max_count = 1000},
	i18n_key = "ENEMY_CERBERUS", enc_icon = 150
})
branch_melee(tt, 70, 90, 1.1, 0.33)
zeta_raise_enemy(tt)

tt = branch_enemy_template("hounds_of_tindalos", "cerberus_small", 666, 0, 0.3, 67, 50, 1, 0.2, 38, nil, {
	area_melee = 82.5, area_melee_max_count = 5, area_melee_hit_offset = v(22.5, 0), spawn_animation = "raise",
	death_damage = {range = 140, damage_min = 70, damage_max = 70, damage_type = DAMAGE_PHYSICAL, max_count = 1000},
	shadow_jump = {cooldown = 8, nodes = 25, safe_nodes_to_exit = 65, animation_out = "sleep", animation_in = "raise"},
	i18n_key = "ENEMY_HOUNDS_OF_TINDALOS", enc_icon = 147
})
branch_melee(tt, 33, 66, 2, 0.33)
zeta_raise_enemy(tt)

tt = branch_enemy_template("demon_fat", "demon_fat", 750, 0, 0.5, 40, 40, 2, 0.2, 48, nil, {i18n_key = "ENEMY_DEMON_FAT", enc_icon = 149})
branch_melee(tt, 30, 50, 1.5, 0.4)
zeta_raise_enemy(tt)
tt = branch_enemy_template("demon_spawn", "reinforcement_improved_goonie", 200, 0, 0.3, 36, 12, 1, 0.17, 27, "reinforcement_improved_goonie_shadow", {
	single_walk = true, spawn_fx = "fx_kr4_reinforcement_demon_summon", spawn_fx_y = 2, spawn_delay = 0.3,
	death_damage = {range = 45, damage_min = 35, damage_max = 35, damage_type = DAMAGE_PHYSICAL, max_count = 5},
	i18n_key = "ENEMY_DEMON_SPAWN", enc_icon = 142
})
branch_melee(tt, 10, 30, 1, 0.27)
zeta_raise_enemy(tt)
tt = branch_enemy_template("demon_guards", "reinforcement_demon_guard", 600, 0.8, 0, 30, 36, 1, 0.312, 38, "reinforcement_demon_guard_shadow", {
	single_walk = true, spawn_fx = "fx_kr4_reinforcement_demon_summon", spawn_fx_y = 2, spawn_delay = 0.3,
	damage_stack_on_attack = {mod = "mod_zeta_demon_guard_damage"},
	death_damage = {range = 45, damage_min = 70, damage_max = 70, damage_type = DAMAGE_PHYSICAL, max_count = 5},
	i18n_key = "ENEMY_DEMON_GUARDS", enc_icon = 143
})
branch_melee(tt, 10, 30, 1.2, 0.3)
zeta_raise_enemy(tt)
tt = branch_enemy_template("zeta_demon_imp", "demon_imp", 300, 0.4, 0, 48, 25, 1, 0.2, 48, nil, {
	flying = true, unblockable = true, single_walk = true,
	death_damage = {range = 45, damage_min = 35, damage_max = 35, damage_type = DAMAGE_PHYSICAL, max_count = 5},
	i18n_key = "ENEMY_DEMON_IMP", enc_icon = 126
})
tt = branch_enemy_template("demon_lord", "demon_lord", 1000, 0, 0.5, 30, 80, 2, 0.2, 50, nil, {i18n_key = "ENEMY_DEMON_LORD", enc_icon = 148})
branch_melee(tt, 35, 55, 1.5, 0.45)
zeta_raise_enemy(tt)
tt = zeta_enemy_variant("demon_flaming_tridents", "demon_flareon", {
	hp = 500, magic_armor = 0.5, speed = 48, gold = 32,
	prefix = "reinforcement_flaming_trident", single_walk = true,
	i18n_key = "ENEMY_DEMON_FLAMING_TRIDENTS", enc_icon = 145
})
tt.ranged.attacks[1].animation = "ranged"

tt = branch_enemy_template("demon_tridents", "reinforcement_hellion_trident", 250, 0, 0, 48, 16, 1, 0.2, 34, "reinforcement_hellion_trident_shadow", {
	single_walk = true,
	ranged = {
		cooldown = 1.4, min_range = 50, max_range = 150, damage_min = 10, damage_max = 20,
		damage_type = DAMAGE_PHYSICAL, animation = "ranged", hit_time = 0.43,
		projectile = "branch_projectile_demon_trident", shoot_offset = v(10, 26), flight_time = fts(10),
		walk_while_shooting = true
	},
	death_damage = {range = 45, damage_min = 35, damage_max = 35, damage_type = DAMAGE_PHYSICAL, max_count = 5},
	i18n_key = "ENEMY_DEMON_TRIDENTS", enc_icon = 144
})
branch_melee(tt, 10, 20, 1.5, 0.27)
zeta_raise_enemy(tt)

tt = branch_enemy_template("juggernaut_eva", "juggernaut_eva", 13500, 0, 0.7, 20, 0, 20, 0.125, 90, nil, {
	boss = true, single_walk = true, area_melee = 100, area_melee_max_count = 5, spawn_animation = "in",
	shield = {cooldown = 16, ready_on_start = true, mod = "mod_zeta_juggernaut_shield", shield_hp = 9000},
	ranged = {
		cooldown = 10, min_range = 40, max_range = 160, damage_min = 260, damage_max = 260,
		damage_type = DAMAGE_TRUE, animation = "bomb", hit_time = 1.1,
		projectile = "branch_projectile_juggernaut_eva", shoot_offset = v(22, 50), flight_time = fts(15),
		mod = "mod_zeta_juggernaut_half_health", extra_projectile_chances = {0.3, 0.3}
	},
	i18n_key = "ENEMY_JUGGERNAUT_EVA", enc_icon = 140
})
branch_melee(tt, 140, 180, 2, 0.5)
zeta_raise_enemy(tt)

tt = branch_enemy_template("kr1_enemy_demon_moloch", "kr1_moloch", 8888, 0, 0, 25, 300, 20, 0.2, 75, nil, {
	boss = true, single_walk = true, spawn_animation = "spawn", area_melee = 75, area_melee_max_count = 3, area_melee_hit_offset = v(10, 0),
	tower_block = {cooldown = 11, range = 220, duration = 3.3, max_targets = 3, animation = "special", cast_time = 0.5},
	i18n_key = "ENEMY_DEMON_BOSS1", enc_icon = 152
})
branch_melee(tt, 66, 132, 2, 0.5)
zeta_raise_enemy(tt)

tt = branch_enemy_template("kr4_enemy_demon_veznan", "kr1_veznan_demon", 7777, 0, 0, 9, 300, 20, 0.2, 75, nil, {boss = true, single_walk = true, spawn_animation = "spawn", i18n_key = "ENEMY_DEMON_BOSS2", enc_icon = 151})
branch_melee(tt, 222, 444, 1.5, 0.7)
zeta_use_exoskeleton(tt, "demon_veznan")

tt = branch_enemy_template("kr4_enemy_demon_oloch", "hero_oloch", 9999, 0, 0.65, 10.5, 300, 20, 0.3, 75, nil, {
	boss = true, single_walk = true,
	instakill = {cooldown = 9, animation = "melee", cast_time = 0.23, vis_bans = F_HERO},
	ranged = {
		cooldown = 12, min_range = 20, max_range = 175, damage_min = 0, damage_max = 0,
		damage_type = DAMAGE_TRUE, animation = "shoot", hit_time = 1.066,
		projectile = "branch_projectile_oloch_instakill", shoot_offset = v(12, 44), instakill = true,
		vis_bans = bor(F_FLYING, F_HERO)
	},
	spawn = {
		cooldown = 16, safe_nodes_to_exit = 50, count = 1, animation = "shoot", cast_time = 0.5,
		templates = {"enemy_demon_lord", "enemy_oloch_duplicate", "enemy_demon_lord", "enemy_demon_lord", "enemy_oloch_duplicate"},
		node_gap = 5
	},
	death_damage = {range = 60, damage_min = 140, damage_max = 140, damage_type = DAMAGE_PHYSICAL, max_count = 5},
	i18n_key = "ENEMY_DEMON_BOSS3", enc_icon = 153
})
branch_melee(tt, 66, 66, 1.2, 0.23, "melee", DAMAGE_MAGICAL)
zeta_raise_enemy(tt)

tt = branch_enemy_template("oloch_duplicate", "hero_oloch_duplication", 1200, 0, 0, 25, 85, 2, 0.3, 42, "hero_oloch_duplication_shadow", {
	single_walk = true,
	reset_ranged_on_melee = true,
	instakill = {
		cooldown = 14, animation = "melee", cast_time = 0.23, vis_bans = F_BOSS,
		hp_damage_factor = 3, damage_type = DAMAGE_MAGICAL,
		imprison = {range = 200, duration = 5, damage = 24, tick = 1, animation = "shoot", cast_time = 0.5}
	},
	ranged = {
		cooldown = 16, min_range = 20, max_range = 150, damage_min = 0, damage_max = 0,
		damage_type = DAMAGE_MAGICAL, animation = "shoot", hit_time = 1.066,
		projectile = "branch_projectile_oloch_instakill", shoot_offset = v(12, 44), hp_damage_factor = 3,
		vis_bans = bor(F_FLYING, F_BOSS),
		imprison = {range = 200, duration = 5, damage = 24, tick = 1, animation = "shoot", cast_time = 0.5}
	},
	spawn = {
		cooldown = 10, safe_nodes_to_exit = 15, count = 2, animation = "shoot", cast_time = 0.5,
		templates = {"enemy_demon_spawn", "enemy_demon_spawn", "enemy_demon_spawn", "enemy_demon_spawn", "enemy_demon_tridents"},
		node_gap = 5
	},
	death_damage = {range = 45, damage_min = 140, damage_max = 140, damage_type = DAMAGE_PHYSICAL, max_count = 5},
	i18n_key = "ENEMY_OLOCH_DUPLICATE", enc_icon = 146
})
branch_melee(tt, 10, 30, 1.2, 0.23)
zeta_raise_enemy(tt)

local function zeta_hide_enemy_controller(t, update)
	t.main_script.update = update
	t.motion.max_speed = 0
	t.enemy.gold = 0
	t.enemy.lives_cost = 0
	t.health.immune_to = DAMAGE_ALL_TYPES
	t.health_bar.hidden = true
	t.ui.can_click = false
	t.ui.can_select = false
	t.vis.bans = F_ALL

	for _, sprite in ipairs(t.render.sprites) do
		sprite.hidden = true
	end

	return t
end

tt = zeta_enemy_variant("kr4_boss_red_triplet", "kr4_enemy_demon_oloch", {hp = 9999, magic_armor = 0.67, speed = 10, gold = 0, lives = 0, i18n_key = "ENEMY_DEMON_BOSS", enc_icon = 154})
zeta_hide_enemy_controller(tt, kr4_scripts.zeta_triplet_controller.update)
tt.death_damage = 3335

tt = zeta_enemy_variant("kr4_boss_red_triplet_iron", "kr4_enemy_demon_oloch", {hp = 9999, magic_armor = 0.67, speed = 10, gold = 0, lives = 0, i18n_key = "ENEMY_DEMON_BOSS", enc_icon = 403})
zeta_hide_enemy_controller(tt, kr4_scripts.zeta_triplet_controller.update)
tt.death_damage = 770
tt.iron_triplet = true

tt = zeta_enemy_variant("demon_endgame_spawner", "kr4_enemy_demon_oloch", {hp = 9999, magic_armor = 0.67, speed = 1, gold = 0, lives = 0, i18n_key = "ENEMY_DEMON_BOSS", enc_icon = 403})
zeta_hide_enemy_controller(tt, kr4_scripts.zeta_endgame_spawner.update)

tt = zeta_enemy_variant("demon_endgame", "kr4_enemy_demon_oloch", {hp = 11999, magic_armor = 0.65, speed = 10, gold = 0, lives = 20, i18n_key = "ENEMY_DEMON_BOSS3", enc_icon = 403})
tt.health.immune_to = DAMAGE_ALL_TYPES
tt.health_bar.hidden = true
tt.vis.bans = F_ALL
tt.ui.can_click = false
tt.ui.can_select = false

tt = zeta_enemy_variant("zeta_draugr_flag1", "draugr_gold", {hp = 30000, magic_armor = 0, speed = 0, gold = 0, lives = 1, i18n_key = "ENEMY_DRAGUR", enc_icon = 317})
tt.branch.self_decay = {always = true, initial_delay = 100, cooldown = 100, damage = 40000, damage_type = DAMAGE_TRUE}

tt = zeta_enemy_variant("zeta_draugr_flag0", "draugr_gold", {hp = 30000, magic_armor = 0, speed = 0, gold = 0, lives = 1, melee = {60, 90, 1.2}, i18n_key = "ENEMY_DRAGUR", enc_icon = 317})
tt.branch.self_decay = {cooldown = 0.25, damage = 5000, damage_type = DAMAGE_TRUE}

tt = branch_enemy_template("zeta_demon_fissure", "elves_shadow", 100000, 0, 0, 0, 15, 0, 0.125, 45, nil, {
	boss = true, unblockable = true, single_walk = true, i18n_key = "ENEMY_ZETA_DEMON_FISSURE", enc_icon = 403, enc_icon_absolute = true
})
tt.main_script.update = kr4_scripts.zeta_demon_fissure.update
tt.enemy.ignore_victory = true
tt.render.sprites[1].hidden = true
tt.render.sprites[2] = E:clone_c("sprite")
tt.render.sprites[2].name = "darkarmy_melting_furnace_decal_fissure_0001"
tt.render.sprites[2].animated = false
tt.render.sprites[2].anchor = v(0.5, 0.5)
tt.render.sprites[2].z = Z_DECALS + 1
tt.ui.can_select = false
tt.zeta_fissure = {
	regen = 5000,
	regen_cooldown = 1,
	support_radius = 150,
	support_cooldown = 2,
	heal_factor = 0.05,
	flat_heal = 10,
	burn_damage = 5,
	burn_cooldown = 0.5,
	death_radius = 200,
	death_damage = 200
}

tt = branch_enemy_template("zeta_demon_spawner", "elves_shadow", 110, 0.6, 0, 0, 0, 0, 0.23, 41, nil, {
	unblockable = true, single_walk = true, i18n_key = "ENEMY_ZETA_DEMON_RAY", enc_icon = 403, enc_icon_absolute = true
})
AC(tt, "death_spawns")
tt.main_script.update = kr4_scripts.zeta_demon_spawner.update
tt.enemy.ignore_victory = true
tt.death_spawns.name = "enemy_zeta_demon_ray"
tt.death_spawns.quantity = 1
tt.death_spawns.delay = 0.37
tt.ui.can_select = false
tt.zeta_spawner = {
	lifetime = 0.2
}

tt = branch_enemy_template("zeta_demon_ray", "elves_shadow", 10000, 0, 0, 0, 0, 0, 0.125, 32, nil, {
	boss = true, unblockable = true, single_walk = true, i18n_key = "ENEMY_ZETA_DEMON_RAY", enc_icon = 403, enc_icon_absolute = true
})
tt.main_script.update = kr4_scripts.zeta_demon_ray.update
tt.enemy.ignore_victory = true
tt.ui.can_select = false
tt.zeta_ray = {
	initial_damage = 7850,
	initial_damage_delay = 0.15,
	regen = 1000,
	regen_cooldown = 0.1,
	protection_radius = 96,
	trigger_hp_factor = 0.48,
	max_targets = 3,
	fissure_damage = 160000,
	arm_delay = 0.4
}

tt = RT("zeta_pit_lord_projectile", "kr4_reinforcement_pit_lord_projectile")
tt.bullet.damage_min = 66
tt.bullet.damage_max = 110
tt.bullet.damage_radius = 49.5

tt = RT("soldier_zeta_pit_lord_ally", "soldier_kr4_reinforcement_pit_lord")
tt.health.hp_max = 1666
tt.regen.health = 0
tt.motion.max_speed = 50
tt.melee.attacks[1].damage_min = 66
tt.melee.attacks[1].damage_max = 110
tt.melee.attacks[1].cooldown = 1.8
tt.ranged.attacks[1].bullet = "zeta_pit_lord_projectile"
tt.ranged.attacks[1].damage_min = 66
tt.ranged.attacks[1].damage_max = 110
tt.ranged.attacks[1].cooldown = 3
tt.ranged.attacks[1].min_range = 65
tt.ranged.attacks[1].max_range = 125
tt.reinforcement.duration = 1000000
tt.kr4_reinforcement.base_death_damage = 80
tt.kr4_reinforcement.base_death_radius = 45
tt.kr4_reinforcement.base_death_max_count = 5

tt = RT("zeta_pit_lord_spawner", "decal_scripted")
tt.main_script.update = kr4_scripts.zeta_pit_lord_spawner.update
tt.render = nil

tt = branch_enemy_template("zeta_oloch_altar", "hero_oloch", 9999, 0, 0.67, 0, 0, 0, 0.3, 42, nil, {
	boss = true, unblockable = true, single_walk = true, i18n_key = "ENEMY_DEMON_BOSS3", enc_icon = 403, enc_icon_absolute = true
})
tt.main_script.update = kr4_scripts.zeta_oloch_altar.update
tt.render.sprites[1].angles = nil
tt.render.sprites[1].name = "idle"
tt.vis.bans = F_ALL
tt.ui.can_click = false
tt.ui.can_select = false
tt.activate_wave = 16
tt.eruption_waves = {4, 7, 10}
tt.death_radius = 60
tt.death_damage = 140

tt = RT("mod_zeta_demon_heroic_enrage", "modifier")
tt.modifier.duration = 1.1
tt.inflicted_damage_factor = 1.5
tt.received_damage_factor = 1.5
tt.speed_factor = 1.5
tt.main_script.insert = kr4_scripts.zeta_fury_modifier.insert
tt.main_script.remove = kr4_scripts.zeta_fury_modifier.remove
tt.main_script.update = scripts.mod_track_target.update

tt = RT("zeta_demon_heroic_booster", "decal_scripted")
tt.main_script.update = kr4_scripts.zeta_demon_heroic_booster.update
tt.render = nil
tt.radius = 166.5
tt.cycle_time = 0.9

tt = RT("zeta_eva_support_controller", "decal_scripted")
tt.main_script.update = kr4_scripts.zeta_eva_support_controller.update
tt.render = nil
tt.heal_per_tick = 20

tt = RT("zeta_eva1_iron_controller", "decal_scripted")
tt.main_script.update = kr4_scripts.zeta_eva1_iron_controller.update
tt.render = nil
tt.scan_interval = 0.15

tt = RT("zeta_eva1_heroic_controller", "decal_scripted")
tt.main_script.update = kr4_scripts.zeta_eva1_heroic_controller.update
tt.render = nil
tt.scan_interval = 0.15
tt.possession_chance = 0.375
tt.possession_duration = 1500
tt.special_lifetime = 5

tt = RT("zeta_eva2_heroic_controller", "decal_scripted")
tt.main_script.update = kr4_scripts.zeta_eva2_heroic_controller.update
tt.render = nil
tt.scan_interval = 0.15
tt.choice_waves = {1, 3, 5}

tt = RT("zeta_eva3_heroic_controller", "decal_scripted")
tt.main_script.update = kr4_scripts.zeta_eva3_heroic_controller.update
tt.render = nil
tt.target_holder_id = "14"
tt.cloud_template = "enemy_zeta_level19_black_cloud"

tt = RT("zeta_demon_iron_controller", "decal_scripted")
tt.main_script.update = kr4_scripts.zeta_demon_iron_controller.update
tt.render = nil
tt.scan_interval = 0.15

tt = branch_enemy_template("wilbur", "kr3_wilbur_layer", 4000, 0, 0, 35, 100, 5, 0.4, 130, nil, {
	 boss = true, flying = true, unblockable = true, single_walk = true, spawn_animation = "spawn", i18n_key = "ENEMY_WILBUR", enc_icon = 139,
	ranged = {no_melee = true, cooldown = 0.75, min_range = 0, max_range = 150, damage_min = 21, damage_max = 32, damage_type = DAMAGE_TRUE, animation = "shoot", hit_time = 0.06},
	spawn = {passive = true, cooldown = 15, count = 3, template = "enemy_wilbur_drone", node_gap = 3}
})
tt.animation_group = "layers"
branch_add_layered_sprites(tt, "kr3_wilbur_layer", 4, v(0.5, 0.4), v(0, 0), Z_OBJECTS)
for _, s in ipairs(tt.render.sprites) do
	s.group = tt.animation_group
end
tt.enemy.gold = 500
zeta_raise_enemy(tt)

tt = branch_enemy_template("wilbur_drone", "kr3_wilbur_drone", 300, 0, 0, 45, 8, 1, 0.4, 70, nil, {
	flying = true, unblockable = true, single_walk = true, spawn_animation = "spawn", i18n_key = "ENEMY_WILBUR_DRONE",
	ranged = {no_melee = true, cooldown = 0.75, min_range = 0, max_range = 100, damage_min = 16, damage_max = 24, damage_type = DAMAGE_TRUE, animation = "shoot", hit_time = 0.08}
})
zeta_raise_enemy(tt)

-- Non-combat source objects referenced directly by the converted level data.
local function zeta_static_scene(name, sprite_name, animated, z, anchor)
	local t = RT(name, "decal_scripted")
	t.main_script.update = kr4_scripts.branch_static_decal.update
	t.render.sprites[1].name = sprite_name
	t.render.sprites[1].animated = animated or false
	t.render.sprites[1].z = z or Z_DECALS
	t.render.sprites[1].anchor = anchor or v(0.5, 0.5)
	return t
end

tt = RT("zeta_demon_crystal", "decal_scripted")
tt.main_script.update = kr4_scripts.branch_static_decal.update
tt.animation_group = "layers"
branch_add_layered_sprites(tt, "veznan_crystal_layer", 11, v(0.5, 0.2), v(0, 0), Z_OBJECTS)
for _, s in ipairs(tt.render.sprites) do
	s.group = tt.animation_group
	s.name = "ready"
end

tt = RT("zeta_lava_glow", "decal_tween")
tt.render.sprites[1].name = "stage_106_lava_glow"
tt.render.sprites[1].animated = false
tt.render.sprites[1].z = Z_DECALS
tt.tween.remove = false
tt.tween.props[1].name = "alpha"
tt.tween.props[1].loop = true
tt.tween.props[1].keys = {{0, 90}, {1.25, 220}, {2.5, 90}}

tt = RT("zeta_cerberus_holder", "decal_scripted")
tt.main_script.update = kr4_scripts.zeta_cerberus_holder.update
tt.render.sprites[1].prefix = "Cerberus"
tt.render.sprites[1].name = "sleep"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.2)
tt.render.sprites[1].z = Z_OBJECTS
tt.wave_start = 15
tt.spawn_template = "enemy_cerberus"
tt.spawn_path = 4
tt.spawn_subpath = 1
tt.spawn_node = 36

local function zeta_animated_scene(name, prefix, animation, z, anchor)
	local t = RT(name, "decal_scripted")
	t.main_script.update = kr4_scripts.branch_static_decal.update
	t.render.sprites[1].prefix = prefix
	t.render.sprites[1].name = animation or "idle"
	t.render.sprites[1].animated = true
	t.render.sprites[1].z = z or Z_OBJECTS
	t.render.sprites[1].anchor = anchor or v(0.5, 0.5)
	return t
end

tt = zeta_animated_scene("zeta_eva2_magnet", "Stage_83_magnet", "idle", Z_OBJECTS, v(0.5, 0.125))
AC(tt, "ui")
tt.main_script.update = kr4_scripts.zeta_eva2_magnet.update
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-34, -12, 68, 86)
tt.triggered_template = "zeta_eva2_magnet_triggered"

tt = zeta_animated_scene("zeta_eva2_magnet_triggered", "Stage_83_magnet", "shoot", Z_OBJECTS, v(0.5, 0.125))
tt.main_script.update = kr4_scripts.zeta_eva2_magnet_triggered.update
tt.duration = 6
tt.attack_interval = 0.2
tt.attack_radius = 1500
tt.damage = 25
tt.gold_per_hit = 1
tt.death_gold = 5

local function zeta_eva2_choice_scene(name, prefix, side)
	local t = zeta_animated_scene(name, prefix, "spawn", Z_OBJECTS + 2, v(0.5, 0.2))

	AC(t, "ui")
	t.main_script.update = kr4_scripts.zeta_eva2_heroic_choice.update
	t.ui.can_click = true
	t.ui.can_select = false
	t.ui.click_rect = r(-34, -12, 68, 70)
	t.side = side
	t.choice_timeout = 30

	return t
end

zeta_eva2_choice_scene("zeta_eva2_heroic_choice_left", "zeta_buff_choice", "left")
zeta_eva2_choice_scene("zeta_eva2_heroic_choice_right", "zeta_buff_choice1", "right")

tt = branch_enemy_template("zeta_level19_black_cloud", "elves_shadow", 1200, 0, 0, 0, 250, 0, 0.125, 42, nil, {
	unblockable = true,
	single_walk = true,
	i18n_key = "ENEMY_LEVEL19_BLACK_CLOUD"
})
tt.main_script.update = kr4_scripts.zeta_level19_black_cloud.update
tt.render.sprites[1].name = "idle"
tt.health_bar.hidden = false
tt.ui.can_click = true
tt.ui.can_select = true

tt = zeta_animated_scene("zeta_level19_black_cloud_residue", "elves_shadow", "idle", Z_OBJECTS + 1, v(0.5, 0.125))
tt.main_script.update = kr4_scripts.zeta_level19_black_cloud_residue.update
tt.duration = 3

zeta_animated_scene("zeta_demon_stone_1", "Stage_86_stone", "idle", Z_OBJECTS, v(0.5, 0.125))
zeta_animated_scene("zeta_demon_stone_2", "Stage_86_stone", "idle", Z_OBJECTS, v(0.5, 0.125))
zeta_animated_scene("zeta_demon_stone_3", "Stage_86_stone", "idle", Z_OBJECTS, v(0.5, 0.125))

tt = RT("zeta_wilbur_altar", "enemy_wilbur")
tt.main_script.update = kr4_scripts.zeta_wilbur_altar.update
tt.motion.max_speed = 0
tt.enemy.gold = 0
tt.enemy.lives_cost = 0
tt.health.immune_to = DAMAGE_ALL_TYPES
tt.vis.bans = F_ALL
tt.ui.can_click = false
tt.ui.can_select = true
tt.health_bar.hidden = false
tt.branch.spawn.wave_start = 5
tt.branch.spawn.cooldown = 48
tt.altar_wave = 10
tt.death_radius = 45
tt.death_damage = 80

tt = RT("zeta_gold_reward_spawner", "decal_scripted")
tt.main_script.update = kr4_scripts.zeta_gold_reward_spawner.update
tt.render = nil
tt.wave = 1

tt = RT("zeta_gold_coin_pile", "decal_scripted")
AC(tt, "ui")
tt.main_script.update = kr4_scripts.zeta_gold_coin_pile.update
tt.render.sprites[1].prefix = "gold_coin_pile"
tt.render.sprites[1].name = "idle"
tt.render.sprites[1].animated = true
tt.render.sprites[1].anchor = v(0.5, 0.167)
tt.render.sprites[1].z = Z_OBJECTS
tt.ui.can_click = true
tt.ui.can_select = false
tt.ui.click_rect = r(-28, -12, 56, 48)
tt.reward = 150

local function zeta_statue_scene(name, prefix, next_template, reward)
	local t = zeta_animated_scene(name, prefix, "idle", Z_OBJECTS, v(0.5, 0.125))

	t.main_script.update = kr4_scripts.zeta_eva3_statue.update
	t.next_template = next_template
	t.reward = reward

	if next_template then
		AC(t, "ui")
		t.ui.can_click = true
		t.ui.can_select = false
		t.ui.click_rect = r(-32, -10, 64, 74)
	end

	return t
end

zeta_statue_scene("zeta_eva3_statue225", "Stage_87_statue225", "zeta_eva3_statue315")
zeta_statue_scene("zeta_eva3_statue315", "Stage_87_statue315", "zeta_eva3_statue45")
zeta_statue_scene("zeta_eva3_statue45", "Stage_87_statue45", "zeta_eva3_statue135", 99)
zeta_statue_scene("zeta_eva3_statue135", "Stage_87_statue135")
zeta_animated_scene("zeta_stage87_end", "Stage_87_2", "run", Z_OBJECTS + 7, v(0.5, 1))

require("kr4_easter_eggs").register_templates()
require("bolgur_stage").register_templates()

tt = RT("zeta_stage_event", "decal_scripted")
tt.main_script.update = kr4_scripts.zeta_stage_event.update
tt.render = nil

