-- chunkname: @./kr6/data/balance/balance.lua

local function v(v1, v2)
	return {
		x = v1,
		y = v2
	}
end

local function fts(v)
	return v / FPS
end

local function sub_one(value)
	if type(value) == "table" then
		local result = {}

		for i, v in ipairs(value) do
			result[i] = v - 1
		end

		return result
	elseif type(value) == "number" then
		return value - 1
	else
		return -999
	end
end

local function slow_calc(value)
	if type(value) == "table" then
		local result = {}

		for i, v in ipairs(value) do
			result[i] = 1 - v
		end

		return result
	elseif type(value) == "number" then
		return 1 - value
	else
		return -999
	end
end

local b = {}

b.heroes = {}
b.heroes.common = {}
b.heroes.common.xp_level_steps = {
	1,
	nil,
	2,
	nil,
	nil,
	nil,
	3,
	[9] = 3
}
b.heroes.common.xp_level_steps_ulti = {
	1,
	[10] = 3,
	[5] = 2
}
b.heroes.common.melee_attack_range = 72
b.heroes.hero_gerald = {}
b.heroes.hero_gerald.stats = {}
b.heroes.hero_gerald.stats.hp = 6.5
b.heroes.hero_gerald.stats.armor = 5
b.heroes.hero_gerald.stats.damage = 4
b.heroes.hero_gerald.stats.cooldown = 3.5
b.heroes.hero_gerald.dead_lifetime = 30
b.heroes.hero_gerald.speed = 55
b.heroes.hero_gerald.regen_cooldown = 1
b.heroes.hero_gerald.armor = {
	0.05,
	0.1,
	0.15,
	0.2,
	0.25,
	0.3,
	0.35,
	0.4,
	0.45,
	0.5
}
b.heroes.hero_gerald.hp_max = {
	220,
	240,
	260,
	280,
	300,
	320,
	340,
	360,
	380,
	400
}
b.heroes.hero_gerald.regen_health = {
	18,
	19,
	21,
	22,
	24,
	26,
	27,
	29,
	30,
	32
}
b.heroes.hero_gerald.basic_melee = {}
b.heroes.hero_gerald.basic_melee.cooldown = 2
b.heroes.hero_gerald.basic_melee.xp_gain_factor = 1
b.heroes.hero_gerald.basic_melee.damage_min = {
	10,
	11,
	13,
	14,
	16,
	18,
	19,
	21,
	22,
	24
}
b.heroes.hero_gerald.basic_melee.damage_max = {
	14,
	17,
	19,
	22,
	24,
	26,
	29,
	31,
	34,
	36
}
b.heroes.hero_gerald.basic_melee.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_gerald.skill_a = {}
b.heroes.hero_gerald.skill_a.cooldown = 16
b.heroes.hero_gerald.skill_a.xp_gain = {
	16,
	32,
	48
}
b.heroes.hero_gerald.skill_a.duration = 4
b.heroes.hero_gerald.skill_a.radius = 60
b.heroes.hero_gerald.skill_a.armor_inc = 0.4
b.heroes.hero_gerald.skill_a.min_targets = 1
b.heroes.hero_gerald.skill_b = {}
b.heroes.hero_gerald.skill_b.cooldown = 24
b.heroes.hero_gerald.skill_b.xp_gain = {
	24,
	48,
	72
}
b.heroes.hero_gerald.skill_b.duration = 6
b.heroes.hero_gerald.skill_b.armor_inc = 0.3
b.heroes.hero_gerald.skill_b.spiked_armor = 0.3
b.heroes.hero_gerald.skill_c = {}
b.heroes.hero_gerald.skill_c.cooldown = 50
b.heroes.hero_gerald.skill_c.xp_gain = {
	50,
	100,
	150
}
b.heroes.hero_gerald.skill_c.hp_ptg = 0.4
b.heroes.hero_gerald.skill_c.nodes_teleport = 30
b.heroes.hero_gerald.ultimate = {}
b.heroes.hero_gerald.ultimate.cooldown = 25
b.heroes.hero_gerald.ultimate.xp_gain = {
	25
}
b.heroes.hero_gerald.ultimate.damage_min = 200
b.heroes.hero_gerald.ultimate.damage_max = 200
b.heroes.hero_gerald.ultimate.s_damage = 200
b.heroes.hero_gerald.ultimate.damage_radius = 50
b.heroes.hero_gerald.ultimate.damage_type = DAMAGE_TRUE
b.heroes.hero_gerald.ultimate.damage_ptg_to_others = 0.75
b.heroes.hero_gerald.ultimate.initial_stun_duration = 0.5
b.heroes.hero_gerald.ultimate.initial_stun_radius = 60
b.heroes.hero_gerald.ultimate.hit_stun_duration = 1
b.heroes.hero_gerald.talent_1 = {}
b.heroes.hero_gerald.talent_1.block_chance = 0.35
b.heroes.hero_gerald.talent_2 = {}
b.heroes.hero_gerald.talent_2.regen_ptg = 0.03
b.heroes.hero_gerald.talent_2.cooldown = fts(30)
b.heroes.hero_gerald.upgrades = {}
b.heroes.hero_gerald.upgrades.upg_sa1 = {}
b.heroes.hero_gerald.upgrades.upg_sa1.duration = 6
b.heroes.hero_gerald.upgrades.upg_sa2 = {}
b.heroes.hero_gerald.upgrades.upg_sa2.duration = 10
b.heroes.hero_gerald.upgrades.upg_sb1 = {}
b.heroes.hero_gerald.upgrades.upg_sb1.spiked_armor = 0.6
b.heroes.hero_gerald.upgrades.upg_sb2 = {}
b.heroes.hero_gerald.upgrades.upg_sb2.armor_inc = 0.4
b.heroes.hero_gerald.upgrades.upg_sb2.cooldown = 20
b.heroes.hero_gerald.upgrades.upg_sc1 = {}
b.heroes.hero_gerald.upgrades.upg_sc1.cooldown = 50
b.heroes.hero_gerald.upgrades.upg_sc1.hp_ptg = 0.7
b.heroes.hero_gerald.upgrades.upg_sc2 = {}
b.heroes.hero_gerald.upgrades.upg_sc2.cooldown = 40
b.heroes.hero_gerald.upgrades.upg_sc2.hp_ptg = 1
b.heroes.hero_gerald.upgrades.upg_a = {}
b.heroes.hero_gerald.upgrades.upg_a.xp_inc_factor = 1.3
b.heroes.hero_gerald.upgrades.upg_a.s_xp_inc_factor = sub_one(b.heroes.hero_gerald.upgrades.upg_a.xp_inc_factor)
b.heroes.hero_gerald.upgrades.upg_b = {}
b.heroes.hero_gerald.upgrades.upg_b.dmg_factor = 1.1
b.heroes.hero_gerald.upgrades.upg_b.s_dmg_factor = sub_one(b.heroes.hero_gerald.upgrades.upg_b.dmg_factor)
b.heroes.hero_gerald.upgrades.upg_c = {}
b.heroes.hero_gerald.upgrades.upg_c.hp_ptg = 0.1
b.heroes.hero_gerald.upgrades.upg_d = {}
b.heroes.hero_gerald.upgrades.upg_d.dead_lifetime = 20
b.heroes.hero_gerald.upgrades.upg_e = {}
b.heroes.hero_gerald.upgrades.upg_e.armor_inc = 0.1
b.heroes.hero_zefira = {}
b.heroes.hero_zefira.stats = {}
b.heroes.hero_zefira.stats.hp = 1.5
b.heroes.hero_zefira.stats.armor = 2
b.heroes.hero_zefira.stats.damage = 2.5
b.heroes.hero_zefira.stats.cooldown = 7.5
b.heroes.hero_zefira.dead_lifetime = 30
b.heroes.hero_zefira.speed = 70
b.heroes.hero_zefira.regen_cooldown = 1
b.heroes.hero_zefira.armor = {
	0.02,
	0.04,
	0.06,
	0.08,
	0.1,
	0.12,
	0.14,
	0.16,
	0.18,
	0.2
}
b.heroes.hero_zefira.hp_max = {
	150,
	160,
	170,
	180,
	190,
	200,
	210,
	220,
	230,
	240
}
b.heroes.hero_zefira.regen_health = {
	12,
	13,
	14,
	15,
	16,
	16,
	17,
	18,
	19,
	20
}
b.heroes.hero_zefira.basic_melee = {}
b.heroes.hero_zefira.basic_melee.cooldown = 1
b.heroes.hero_zefira.basic_melee.xp_gain_factor = 0.8
b.heroes.hero_zefira.basic_melee.damage_min = {
	4,
	5,
	6,
	6,
	7,
	8,
	9,
	9,
	10,
	11
}
b.heroes.hero_zefira.basic_melee.damage_max = {
	12,
	14,
	17,
	19,
	21,
	23,
	26,
	28,
	30,
	32
}
b.heroes.hero_zefira.basic_melee.damage_type = DAMAGE_MAGICAL
b.heroes.hero_zefira.basic_ranged = {}
b.heroes.hero_zefira.basic_ranged.cooldown = 1
b.heroes.hero_zefira.basic_ranged.xp_gain_factor = 0.8
b.heroes.hero_zefira.basic_ranged.max_range = 150
b.heroes.hero_zefira.basic_ranged.min_range = 70
b.heroes.hero_zefira.basic_ranged.damage_min = {
	4,
	5,
	6,
	6,
	7,
	8,
	9,
	9,
	10,
	11
}
b.heroes.hero_zefira.basic_ranged.damage_max = {
	12,
	14,
	17,
	19,
	21,
	23,
	26,
	28,
	30,
	32
}
b.heroes.hero_zefira.basic_ranged.damage_type = DAMAGE_MAGICAL
b.heroes.hero_zefira.skill_a = {}
b.heroes.hero_zefira.skill_a.cooldown = 12
b.heroes.hero_zefira.skill_a.xp_gain = {
	12,
	24,
	36
}
b.heroes.hero_zefira.skill_a.damage_min = 20
b.heroes.hero_zefira.skill_a.damage_max = 40
b.heroes.hero_zefira.skill_a.damage_radius = 50
b.heroes.hero_zefira.skill_a.damage_type = DAMAGE_MAGICAL
b.heroes.hero_zefira.skill_a.min_targets = 1
b.heroes.hero_zefira.skill_a.stun_duration = 1
b.heroes.hero_zefira.skill_b = {}
b.heroes.hero_zefira.skill_b.cooldown = 18
b.heroes.hero_zefira.skill_b.xp_gain = {
	18,
	36,
	54
}
b.heroes.hero_zefira.skill_b.min_targets = 1
b.heroes.hero_zefira.skill_b.detection_radius = 80
b.heroes.hero_zefira.skill_b.radius = 45
b.heroes.hero_zefira.skill_b.damage_every = 0.25
b.heroes.hero_zefira.skill_b.damage_min = 2
b.heroes.hero_zefira.skill_b.damage_max = 2
b.heroes.hero_zefira.skill_b.s_damage_total_lvl1 = 32
b.heroes.hero_zefira.skill_b.s_damage_total_lvl2 = 48
b.heroes.hero_zefira.skill_b.damage_type = DAMAGE_MAGICAL
b.heroes.hero_zefira.skill_b.duration = 4
b.heroes.hero_zefira.skill_b.armor_inc = 0.3
b.heroes.hero_zefira.skill_b.magic_armor_inc = 0.3
b.heroes.hero_zefira.skill_b.s_resistance_inc = 0.3
b.heroes.hero_zefira.skill_b.slow_factor = 0.3
b.heroes.hero_zefira.skill_c = {}
b.heroes.hero_zefira.skill_c.cooldown = 2
b.heroes.hero_zefira.skill_c.xp_gain = {
	0,
	0,
	0
}
b.heroes.hero_zefira.skill_c.min_dist = 160
b.heroes.hero_zefira.skill_c.duration = 4
b.heroes.hero_zefira.skill_c.damage_factor = 1.3
b.heroes.hero_zefira.skill_c.s_damage_factor = sub_one(b.heroes.hero_zefira.skill_c.damage_factor)
b.heroes.hero_zefira.ultimate = {}
b.heroes.hero_zefira.ultimate.cooldown = 34
b.heroes.hero_zefira.ultimate.xp_gain = {
	34
}
b.heroes.hero_zefira.ultimate.spears_count = 21
b.heroes.hero_zefira.ultimate.min_targets = 3
b.heroes.hero_zefira.ultimate.max_range = 150
b.heroes.hero_zefira.ultimate.min_range = 50
b.heroes.hero_zefira.ultimate.damage_min = 20
b.heroes.hero_zefira.ultimate.damage_max = 20
b.heroes.hero_zefira.ultimate.s_total_damage = 210
b.heroes.hero_zefira.ultimate.damage_radius = 35
b.heroes.hero_zefira.ultimate.damage_type = DAMAGE_MAGICAL
b.heroes.hero_zefira.ultimate.duration = 0.8
b.heroes.hero_zefira.talent_1 = {}
b.heroes.hero_zefira.talent_1.radius = 50
b.heroes.hero_zefira.talent_1.armor_factor = 0.3
b.heroes.hero_zefira.talent_1.magic_armor_factor = 0.3
b.heroes.hero_zefira.talent_1.s_resistance_red = 0.3
b.heroes.hero_zefira.talent_1.debuff_duration = 1
b.heroes.hero_zefira.talent_2 = {}
b.heroes.hero_zefira.talent_2.crit_chance = 0.2
b.heroes.hero_zefira.upgrades = {}
b.heroes.hero_zefira.upgrades.upg_sa1 = {}
b.heroes.hero_zefira.upgrades.upg_sa1.min_damage = 50
b.heroes.hero_zefira.upgrades.upg_sa1.max_damage = 70
b.heroes.hero_zefira.upgrades.upg_sa2 = {}
b.heroes.hero_zefira.upgrades.upg_sa2.min_damage = 80
b.heroes.hero_zefira.upgrades.upg_sa2.max_damage = 100
b.heroes.hero_zefira.upgrades.upg_sb1 = {}
b.heroes.hero_zefira.upgrades.upg_sb1.slow_factor = 0.75
b.heroes.hero_zefira.upgrades.upg_sb1.s_slow_factor = 0.25
b.heroes.hero_zefira.upgrades.upg_sb2 = {}
b.heroes.hero_zefira.upgrades.upg_sb2.duration = 6
b.heroes.hero_zefira.upgrades.upg_sc1 = {}
b.heroes.hero_zefira.upgrades.upg_sc1.dmg_factor = 1.4
b.heroes.hero_zefira.upgrades.upg_sc1.s_dmg_factor = sub_one(b.heroes.hero_zefira.upgrades.upg_sc1.dmg_factor)
b.heroes.hero_zefira.upgrades.upg_sc1.duration = 6
b.heroes.hero_zefira.upgrades.upg_sc2 = {}
b.heroes.hero_zefira.upgrades.upg_sc2.dmg_factor = 1.5
b.heroes.hero_zefira.upgrades.upg_sc2.s_dmg_factor = sub_one(b.heroes.hero_zefira.upgrades.upg_sc2.dmg_factor)
b.heroes.hero_zefira.upgrades.upg_sc2.duration = 8
b.heroes.hero_zefira.upgrades.upg_a = {}
b.heroes.hero_zefira.upgrades.upg_a.dead_lifetime = 20
b.heroes.hero_zefira.upgrades.upg_b = {}
b.heroes.hero_zefira.upgrades.upg_b.skill_red_factor = 0.1
b.heroes.hero_zefira.upgrades.upg_b.ult_red_factor = 0.05
b.heroes.hero_zefira.upgrades.upg_c = {}
b.heroes.hero_zefira.upgrades.upg_c.regen_factor = 1.2
b.heroes.hero_zefira.upgrades.upg_c.s_regen_factor = sub_one(b.heroes.hero_zefira.upgrades.upg_c.regen_factor)
b.heroes.hero_zefira.upgrades.upg_d = {}
b.heroes.hero_zefira.upgrades.upg_d.hp_ptg = 0.2
b.heroes.hero_zefira.upgrades.upg_e = {}
b.heroes.hero_zefira.upgrades.upg_e.dmg_factor = 1.05
b.heroes.hero_zefira.upgrades.upg_e.s_dmg_factor = sub_one(b.heroes.hero_zefira.upgrades.upg_e.dmg_factor)
b.heroes.hero_bolin = {}
b.heroes.hero_bolin.stats = {}
b.heroes.hero_bolin.stats.hp = 2
b.heroes.hero_bolin.stats.armor = 1.5
b.heroes.hero_bolin.stats.damage = 7.5
b.heroes.hero_bolin.stats.cooldown = 1
b.heroes.hero_bolin.dead_lifetime = 30
b.heroes.hero_bolin.speed = 60
b.heroes.hero_bolin.regen_cooldown = 1
b.heroes.hero_bolin.armor = {
	0.05,
	0.06,
	0.07,
	0.08,
	0.09,
	0.1,
	0.11,
	0.12,
	0.13,
	0.15
}
b.heroes.hero_bolin.hp_max = {
	170,
	180,
	190,
	200,
	210,
	220,
	230,
	240,
	250,
	260
}
b.heroes.hero_bolin.regen_health = {
	14,
	14,
	15,
	16,
	17,
	18,
	18,
	19,
	20,
	21
}
b.heroes.hero_bolin.melee_attack_range = 40
b.heroes.hero_bolin.basic_melee = {}
b.heroes.hero_bolin.basic_melee.cooldown = 1
b.heroes.hero_bolin.basic_melee.xp_gain_factor = 1
b.heroes.hero_bolin.basic_melee.damage_min = {
	8,
	9,
	10,
	10,
	11,
	12,
	13,
	14,
	14,
	15
}
b.heroes.hero_bolin.basic_melee.damage_max = {
	12,
	13,
	14,
	16,
	17,
	18,
	19,
	20,
	22,
	23
}
b.heroes.hero_bolin.basic_melee.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_bolin.basic_ranged = {}
b.heroes.hero_bolin.basic_ranged.cooldown = 2.75
b.heroes.hero_bolin.basic_ranged.xp_gain_factor = 0.8
b.heroes.hero_bolin.basic_ranged.max_range = 200
b.heroes.hero_bolin.basic_ranged.min_range = 70
b.heroes.hero_bolin.basic_ranged.damage_min = {
	20,
	22,
	24,
	26,
	28,
	30,
	32,
	34,
	36,
	38
}
b.heroes.hero_bolin.basic_ranged.damage_max = {
	30,
	33,
	36,
	39,
	42,
	45,
	48,
	52,
	54,
	57
}
b.heroes.hero_bolin.basic_ranged.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_bolin.death_explosion = {}
b.heroes.hero_bolin.death_explosion.damage_min = 20
b.heroes.hero_bolin.death_explosion.damage_max = 30
b.heroes.hero_bolin.death_explosion.damage_radius = 70
b.heroes.hero_bolin.death_explosion.damage_type = DAMAGE_EXPLOSION
b.heroes.hero_bolin.skill_a = {}
b.heroes.hero_bolin.skill_a.cooldown = 16
b.heroes.hero_bolin.skill_a.xp_gain = {
	16,
	32,
	48
}
b.heroes.hero_bolin.skill_a.min_range = 200
b.heroes.hero_bolin.skill_a.max_range = 300
b.heroes.hero_bolin.skill_a.min_targets = 3
b.heroes.hero_bolin.skill_a.mortar_gap = 10
b.heroes.hero_bolin.skill_a.damage_min = 10
b.heroes.hero_bolin.skill_a.damage_max = 15
b.heroes.hero_bolin.skill_a.damage_radius = 50
b.heroes.hero_bolin.skill_a.damage_type = DAMAGE_EXPLOSION
b.heroes.hero_bolin.skill_a.aura = {}
b.heroes.hero_bolin.skill_a.aura.slow_factor = 0.6
b.heroes.hero_bolin.skill_a.aura.radius = 60
b.heroes.hero_bolin.skill_a.aura.duration = 4
b.heroes.hero_bolin.skill_a.aura.slow_duration = 0.5
b.heroes.hero_bolin.skill_b = {}
b.heroes.hero_bolin.skill_b.cooldown = 6
b.heroes.hero_bolin.skill_b.xp_gain = {
	6,
	6,
	6
}
b.heroes.hero_bolin.skill_b.max_mines = 4
b.heroes.hero_bolin.skill_b.damage_min = 12
b.heroes.hero_bolin.skill_b.damage_max = 18
b.heroes.hero_bolin.skill_b.min_range = 40
b.heroes.hero_bolin.skill_b.max_range = 120
b.heroes.hero_bolin.skill_b.damage_type = DAMAGE_EXPLOSION
b.heroes.hero_bolin.skill_b.trigger_radius = 30
b.heroes.hero_bolin.skill_b.dmg_radius = 45
b.heroes.hero_bolin.skill_c = {}
b.heroes.hero_bolin.skill_c.hp_percentage = 0.01
b.heroes.hero_bolin.skill_c.boss_hp_percentage = 0.002
b.heroes.hero_bolin.skill_c.damage_cap = {
	50,
	50,
	50
}
b.heroes.hero_bolin.ultimate = {}
b.heroes.hero_bolin.ultimate.cooldown = 35
b.heroes.hero_bolin.ultimate.xp_gain = {
	35
}
b.heroes.hero_bolin.ultimate.min_targets = 3
b.heroes.hero_bolin.ultimate.min_hp = 500
b.heroes.hero_bolin.ultimate.range = 200
b.heroes.hero_bolin.ultimate.shot_count = 8
b.heroes.hero_bolin.talent_1 = {}
b.heroes.hero_bolin.talent_1.armor_penetration = 0.25
b.heroes.hero_bolin.talent_2 = {}
b.heroes.hero_bolin.talent_2.shot_count = 5
b.heroes.hero_bolin.talent_2.explosion = {}
b.heroes.hero_bolin.talent_2.explosion.damage_min = 24
b.heroes.hero_bolin.talent_2.explosion.damage_max = 36
b.heroes.hero_bolin.talent_2.explosion.damage_type = DAMAGE_EXPLOSION
b.heroes.hero_bolin.talent_2.explosion.damage_radius = 50
b.heroes.hero_bolin.upgrades = {}
b.heroes.hero_bolin.upgrades.upg_sa1 = {}
b.heroes.hero_bolin.upgrades.upg_sa1.min_damage = 15
b.heroes.hero_bolin.upgrades.upg_sa1.max_damage = 20
b.heroes.hero_bolin.upgrades.upg_sa2 = {}
b.heroes.hero_bolin.upgrades.upg_sa2.min_damage = 20
b.heroes.hero_bolin.upgrades.upg_sa2.max_damage = 25
b.heroes.hero_bolin.upgrades.upg_sb1 = {}
b.heroes.hero_bolin.upgrades.upg_sb1.min_damage = 17
b.heroes.hero_bolin.upgrades.upg_sb1.max_damage = 28
b.heroes.hero_bolin.upgrades.upg_sb1.max_mines = 6
b.heroes.hero_bolin.upgrades.upg_sb2 = {}
b.heroes.hero_bolin.upgrades.upg_sb2.min_damage = 24
b.heroes.hero_bolin.upgrades.upg_sb2.max_damage = 36
b.heroes.hero_bolin.upgrades.upg_sb2.max_mines = 8
b.heroes.hero_bolin.upgrades.upg_sc1 = {}
b.heroes.hero_bolin.upgrades.upg_sc1.hp_percentage = 0.02
b.heroes.hero_bolin.upgrades.upg_sc1.boss_hp_percentage = 0.004
b.heroes.hero_bolin.upgrades.upg_sc2 = {}
b.heroes.hero_bolin.upgrades.upg_sc2.hp_percentage = 0.03
b.heroes.hero_bolin.upgrades.upg_sc2.boss_hp_percentage = 0.006
b.heroes.hero_bolin.upgrades.upg_a = {}
b.heroes.hero_bolin.upgrades.upg_a.attack_cooldown = 2.5
b.heroes.hero_bolin.upgrades.upg_a.s_attack_cooldown = 0.1
b.heroes.hero_bolin.upgrades.upg_b = {}
b.heroes.hero_bolin.upgrades.upg_b.range_factor = 1.15
b.heroes.hero_bolin.upgrades.upg_b.s_range_factor = sub_one(b.heroes.hero_bolin.upgrades.upg_b.range_factor)
b.heroes.hero_bolin.upgrades.upg_c = {}
b.heroes.hero_bolin.upgrades.upg_c.armor_inc = 0.1
b.heroes.hero_bolin.upgrades.upg_d = {}
b.heroes.hero_bolin.upgrades.upg_d.dmg_factor = 1.05
b.heroes.hero_bolin.upgrades.upg_d.s_dmg_factor = sub_one(b.heroes.hero_bolin.upgrades.upg_d.dmg_factor)
b.heroes.hero_bolin.upgrades.upg_e = {}
b.heroes.hero_bolin.upgrades.upg_e.skill_red_factor = 0.1
b.heroes.hero_bolin.upgrades.upg_e.ult_red_factor = 0.05
b.heroes.hero_malik = {}
b.heroes.hero_malik.stats = {}
b.heroes.hero_malik.stats.hp = 9
b.heroes.hero_malik.stats.armor = 0
b.heroes.hero_malik.stats.damage = 3
b.heroes.hero_malik.stats.cooldown = 5.5
b.heroes.hero_malik.dead_lifetime = 30
b.heroes.hero_malik.speed = 60
b.heroes.hero_malik.regen_cooldown = 1
b.heroes.hero_malik.armor = {
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
b.heroes.hero_malik.hp_max = {
	200,
	230,
	260,
	290,
	320,
	350,
	380,
	410,
	440,
	470
}
b.heroes.hero_malik.regen_health = {
	16,
	18,
	21,
	23,
	26,
	28,
	30,
	33,
	35,
	38
}
b.heroes.hero_malik.basic_melee = {}
b.heroes.hero_malik.basic_melee.cooldown = 1.5
b.heroes.hero_malik.basic_melee.xp_gain_factor = 0.9
b.heroes.hero_malik.basic_melee.damage_min = {
	10,
	11,
	12,
	13,
	14,
	16,
	17,
	18,
	19,
	20
}
b.heroes.hero_malik.basic_melee.damage_max = {
	14,
	16,
	18,
	20,
	22,
	23,
	25,
	27,
	29,
	31
}
b.heroes.hero_malik.basic_melee.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_malik.skill_a = {}
b.heroes.hero_malik.skill_a.cooldown = 18
b.heroes.hero_malik.skill_a.xp_gain = {
	18,
	36,
	54
}
b.heroes.hero_malik.skill_a.duration = 6
b.heroes.hero_malik.skill_a.hp_increase_ptg = 0.3
b.heroes.hero_malik.skill_a.hp_base = 50
b.heroes.hero_malik.skill_b = {}
b.heroes.hero_malik.skill_b.cooldown = 20
b.heroes.hero_malik.skill_b.xp_gain = {
	20,
	40,
	60
}
b.heroes.hero_malik.skill_b.damage_min = 48
b.heroes.hero_malik.skill_b.damage_max = 72
b.heroes.hero_malik.skill_b.damage_radius = 50
b.heroes.hero_malik.skill_b.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_malik.skill_b.min_targets = 1
b.heroes.hero_malik.skill_b.stun_duration = 2
b.heroes.hero_malik.skill_c = {}
b.heroes.hero_malik.skill_c.cooldown = 40
b.heroes.hero_malik.skill_c.xp_gain = {
	40,
	80,
	120
}
b.heroes.hero_malik.skill_c.hp_threshold = 1500
b.heroes.hero_malik.skill_c.current_hp_threshold = 80
b.heroes.hero_malik.ultimate = {}
b.heroes.hero_malik.ultimate.cooldown = 28
b.heroes.hero_malik.ultimate.xp_gain = {
	28
}
b.heroes.hero_malik.ultimate.damage_min = 16
b.heroes.hero_malik.ultimate.damage_max = 24
b.heroes.hero_malik.ultimate.damage_radius = 80
b.heroes.hero_malik.ultimate.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_malik.ultimate.duration = 5
b.heroes.hero_malik.ultimate.min_targets = 3
b.heroes.hero_malik.ultimate.self_speed_factor = 1.17
b.heroes.hero_malik.ultimate.cycle_time = 0.5
b.heroes.hero_malik.ultimate.s_total_min_damage = 160
b.heroes.hero_malik.ultimate.s_total_max_damage = 240
b.heroes.hero_malik.ultimate.slow_factor = 0.6
b.heroes.hero_malik.ultimate.slow_duration = 0.5
b.heroes.hero_malik.talent_1 = {}
b.heroes.hero_malik.talent_1.damage_radius = 70
b.heroes.hero_malik.talent_2 = {}
b.heroes.hero_malik.talent_2.dmg_factor = 1.25
b.heroes.hero_malik.talent_2.s_dmg_factor = sub_one(b.heroes.hero_malik.talent_2.dmg_factor)
b.heroes.hero_malik.talent_2.detection_radius = 150
b.heroes.hero_malik.upgrades = {}
b.heroes.hero_malik.upgrades.upg_sa1 = {}
b.heroes.hero_malik.upgrades.upg_sa1.hp_increase_ptg = 0.4
b.heroes.hero_malik.upgrades.upg_sa2 = {}
b.heroes.hero_malik.upgrades.upg_sa2.hp_increase_ptg = 0.5
b.heroes.hero_malik.upgrades.upg_sb1 = {}
b.heroes.hero_malik.upgrades.upg_sb1.stun_duration = 4
b.heroes.hero_malik.upgrades.upg_sb2 = {}
b.heroes.hero_malik.upgrades.upg_sb2.damage_radius = 120
b.heroes.hero_malik.upgrades.upg_sb2.s_damage_radius = 50
b.heroes.hero_malik.upgrades.upg_sc1 = {}
b.heroes.hero_malik.upgrades.upg_sc1.cooldown = 34
b.heroes.hero_malik.upgrades.upg_sc2 = {}
b.heroes.hero_malik.upgrades.upg_sc2.cooldown = 28
b.heroes.hero_malik.upgrades.upg_a = {}
b.heroes.hero_malik.upgrades.upg_a.regen_factor = 1.15
b.heroes.hero_malik.upgrades.upg_a.s_regen_factor = sub_one(b.heroes.hero_malik.upgrades.upg_a.regen_factor)
b.heroes.hero_malik.upgrades.upg_b = {}
b.heroes.hero_malik.upgrades.upg_b.movement_factor = 1.2
b.heroes.hero_malik.upgrades.upg_b.s_movement_factor = sub_one(b.heroes.hero_malik.upgrades.upg_b.movement_factor)
b.heroes.hero_malik.upgrades.upg_c = {}
b.heroes.hero_malik.upgrades.upg_c.dmg_factor = 1.15
b.heroes.hero_malik.upgrades.upg_c.s_dmg_factor = sub_one(b.heroes.hero_malik.upgrades.upg_c.dmg_factor)
b.heroes.hero_malik.upgrades.upg_c.hp_ptg_threshold = 0.75
b.heroes.hero_malik.upgrades.upg_d = {}
b.heroes.hero_malik.upgrades.upg_d.hp_ptg = 0.1
b.heroes.hero_malik.upgrades.upg_e = {}
b.heroes.hero_malik.upgrades.upg_e.chance = 0.2
b.heroes.hero_malik.upgrades.upg_e.hp_ptg = 1
b.heroes.hero_ashbite = {}
b.heroes.hero_ashbite.stats = {}
b.heroes.hero_ashbite.stats.hp = 9.5
b.heroes.hero_ashbite.stats.armor = 2.5
b.heroes.hero_ashbite.stats.damage = 9.5
b.heroes.hero_ashbite.stats.cooldown = 3.5
b.heroes.hero_ashbite.dead_lifetime = 30
b.heroes.hero_ashbite.speed = 150
b.heroes.hero_ashbite.regen_cooldown = 1
b.heroes.hero_ashbite.armor = {
	0.05,
	0.07,
	0.09,
	0.11,
	0.13,
	0.15,
	0.17,
	0.19,
	0.21,
	0.23
}
b.heroes.hero_ashbite.hp_max = {
	230,
	260,
	290,
	320,
	350,
	380,
	410,
	440,
	470,
	500
}
b.heroes.hero_ashbite.regen_health = {
	18,
	21,
	23,
	26,
	28,
	30,
	33,
	35,
	38,
	40
}
b.heroes.hero_ashbite.basic_attack = {}
b.heroes.hero_ashbite.basic_attack.min_range = 50
b.heroes.hero_ashbite.basic_attack.max_range = 220
b.heroes.hero_ashbite.basic_attack.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_ashbite.basic_attack.cooldown = 2
b.heroes.hero_ashbite.basic_attack.xp_gain_factor = 0.6
b.heroes.hero_ashbite.basic_attack.damage_min = {
	19,
	22,
	26,
	29,
	32,
	35,
	38,
	42,
	45,
	48
}
b.heroes.hero_ashbite.basic_attack.damage_max = {
	29,
	34,
	38,
	43,
	48,
	53,
	58,
	62,
	67,
	72
}
b.heroes.hero_ashbite.basic_attack.damage_radius = 40
b.heroes.hero_ashbite.skill_a = {}
b.heroes.hero_ashbite.skill_a.cooldown = 16
b.heroes.hero_ashbite.skill_a.xp_gain = {
	16,
	32,
	48
}
b.heroes.hero_ashbite.skill_a.min_targets = 3
b.heroes.hero_ashbite.skill_a.min_range = 50
b.heroes.hero_ashbite.skill_a.max_range = 150
b.heroes.hero_ashbite.skill_a.aura = {}
b.heroes.hero_ashbite.skill_a.aura.duration = 2
b.heroes.hero_ashbite.skill_a.aura.damage_min = 4
b.heroes.hero_ashbite.skill_a.aura.damage_max = 6
b.heroes.hero_ashbite.skill_a.aura.s_damage_min = 32
b.heroes.hero_ashbite.skill_a.aura.s_damage_max = 48
b.heroes.hero_ashbite.skill_a.aura.damage_type = DAMAGE_TRUE
b.heroes.hero_ashbite.skill_a.aura.damage_every = 0.25
b.heroes.hero_ashbite.skill_a.aura.damage_radius = 50
b.heroes.hero_ashbite.skill_b = {}
b.heroes.hero_ashbite.skill_b.cooldown = 20
b.heroes.hero_ashbite.skill_b.xp_gain = {
	20,
	40,
	60
}
b.heroes.hero_ashbite.skill_b.min_range = 50
b.heroes.hero_ashbite.skill_b.max_range = 200
b.heroes.hero_ashbite.skill_b.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_ashbite.skill_b.damage_min = 32
b.heroes.hero_ashbite.skill_b.damage_max = 32
b.heroes.hero_ashbite.skill_b.damage_radius = 45
b.heroes.hero_ashbite.skill_b.stun_duration = 2
b.heroes.hero_ashbite.skill_b.embers_duration = 4
b.heroes.hero_ashbite.skill_b.embers_radius = 45
b.heroes.hero_ashbite.skill_b.embers_cycle_time = 0.5
b.heroes.hero_ashbite.skill_b.burn = {}
b.heroes.hero_ashbite.skill_b.burn.duration = 0.5
b.heroes.hero_ashbite.skill_b.burn.damage = 4
b.heroes.hero_ashbite.skill_b.burn.damage_every = 0.25
b.heroes.hero_ashbite.skill_b.burn.damage_type = DAMAGE_TRUE
b.heroes.hero_ashbite.skill_b.burn.s_damage = 64
b.heroes.hero_ashbite.skill_c = {}
b.heroes.hero_ashbite.skill_c.cooldown = 30
b.heroes.hero_ashbite.skill_c.attack_cooldown = 2
b.heroes.hero_ashbite.skill_c.melee_xp_gain_factor = 1
b.heroes.hero_ashbite.skill_c.range = 120
b.heroes.hero_ashbite.skill_c.xp_gain = {
	30,
	60,
	90
}
b.heroes.hero_ashbite.skill_c.target_min_hp = 100
b.heroes.hero_ashbite.skill_c.target_max_hp = 1000
b.heroes.hero_ashbite.skill_c.duration = 8
b.heroes.hero_ashbite.skill_c.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_ashbite.skill_c.damage_min = 80
b.heroes.hero_ashbite.skill_c.damage_max = 120
b.heroes.hero_ashbite.skill_c.heal_ptg = 0.2
b.heroes.hero_ashbite.ultimate = {}
b.heroes.hero_ashbite.ultimate.cooldown = 35
b.heroes.hero_ashbite.ultimate.xp_gain = {
	35
}
b.heroes.hero_ashbite.ultimate.min_targets = 3
b.heroes.hero_ashbite.ultimate.min_range = 100
b.heroes.hero_ashbite.ultimate.max_range = 300
b.heroes.hero_ashbite.ultimate.damage_min = 64
b.heroes.hero_ashbite.ultimate.damage_max = 96
b.heroes.hero_ashbite.ultimate.damage_type = DAMAGE_TRUE
b.heroes.hero_ashbite.ultimate.damage_radius = 70
b.heroes.hero_ashbite.talent_1 = {}
b.heroes.hero_ashbite.talent_1.burn = {}
b.heroes.hero_ashbite.talent_1.burn.duration = 4
b.heroes.hero_ashbite.talent_1.burn.damage = 2
b.heroes.hero_ashbite.talent_1.burn.damage_every = 0.25
b.heroes.hero_ashbite.talent_1.burn.damage_type = DAMAGE_TRUE
b.heroes.hero_ashbite.talent_1.burn.s_damage = 32
b.heroes.hero_ashbite.talent_2 = {}
b.heroes.hero_ashbite.talent_2.armor_red = 0.01
b.heroes.hero_ashbite.upgrades = {}
b.heroes.hero_ashbite.upgrades.upg_sa1 = {}
b.heroes.hero_ashbite.upgrades.upg_sa1.damage_min = 6
b.heroes.hero_ashbite.upgrades.upg_sa1.damage_max = 9
b.heroes.hero_ashbite.upgrades.upg_sa1.s_damage_min = 48
b.heroes.hero_ashbite.upgrades.upg_sa1.s_damage_max = 72
b.heroes.hero_ashbite.upgrades.upg_sa2 = {}
b.heroes.hero_ashbite.upgrades.upg_sa2.damage_min = 9
b.heroes.hero_ashbite.upgrades.upg_sa2.damage_max = 12
b.heroes.hero_ashbite.upgrades.upg_sa2.s_damage_min = 64
b.heroes.hero_ashbite.upgrades.upg_sa2.s_damage_max = 96
b.heroes.hero_ashbite.upgrades.upg_sb1 = {}
b.heroes.hero_ashbite.upgrades.upg_sb1.embers_duration = 6
b.heroes.hero_ashbite.upgrades.upg_sb1.stun_duration = 3
b.heroes.hero_ashbite.upgrades.upg_sb1.s_damage = 96
b.heroes.hero_ashbite.upgrades.upg_sb2 = {}
b.heroes.hero_ashbite.upgrades.upg_sb2.embers_duration = 8
b.heroes.hero_ashbite.upgrades.upg_sb2.stun_duration = 4
b.heroes.hero_ashbite.upgrades.upg_sb2.s_damage = 128
b.heroes.hero_ashbite.upgrades.upg_sc1 = {}
b.heroes.hero_ashbite.upgrades.upg_sc1.heal_ptg = 0.3
b.heroes.hero_ashbite.upgrades.upg_sc2 = {}
b.heroes.hero_ashbite.upgrades.upg_sc2.heal_ptg = 0.4
b.heroes.hero_ashbite.upgrades.upg_a = {}
b.heroes.hero_ashbite.upgrades.upg_a.hp_ptg = 0.1
b.heroes.hero_ashbite.upgrades.upg_b = {}
b.heroes.hero_ashbite.upgrades.upg_b.range_factor = 1.15
b.heroes.hero_ashbite.upgrades.upg_b.s_range_factor = sub_one(b.heroes.hero_ashbite.upgrades.upg_b.range_factor)
b.heroes.hero_ashbite.upgrades.upg_c = {}
b.heroes.hero_ashbite.upgrades.upg_c.skill_red_factor = 0.1
b.heroes.hero_ashbite.upgrades.upg_c.ult_red_factor = 0.05
b.heroes.hero_ashbite.upgrades.upg_d = {}
b.heroes.hero_ashbite.upgrades.upg_d.regen_factor = 1.3
b.heroes.hero_ashbite.upgrades.upg_d.s_regen_factor = sub_one(b.heroes.hero_ashbite.upgrades.upg_d.regen_factor)
b.heroes.hero_ashbite.upgrades.upg_e = {}
b.heroes.hero_ashbite.upgrades.upg_e.dmg_factor = 1.1
b.heroes.hero_ashbite.upgrades.upg_e.s_dmg_factor = sub_one(b.heroes.hero_ashbite.upgrades.upg_e.dmg_factor)
b.heroes.hero_rhodes = {}
b.heroes.hero_rhodes.stats = {}
b.heroes.hero_rhodes.stats.hp = 7
b.heroes.hero_rhodes.stats.armor = 5
b.heroes.hero_rhodes.stats.damage = 3
b.heroes.hero_rhodes.stats.cooldown = 5.5
b.heroes.hero_rhodes.dead_lifetime = 30
b.heroes.hero_rhodes.speed = 40
b.heroes.hero_rhodes.regen_cooldown = 1
b.heroes.hero_rhodes.armor = {
	0.23,
	0.26,
	0.29,
	0.32,
	0.35,
	0.38,
	0.41,
	0.44,
	0.47,
	0.5
}
b.heroes.hero_rhodes.hp_max = {
	200,
	225,
	250,
	275,
	300,
	325,
	350,
	375,
	400,
	425
}
b.heroes.hero_rhodes.regen_health = {
	14,
	16,
	18,
	20,
	22,
	24,
	26,
	28,
	30,
	32
}
b.heroes.hero_rhodes.basic_melee = {}
b.heroes.hero_rhodes.basic_melee.cooldown = 1.5
b.heroes.hero_rhodes.basic_melee.xp_gain_factor = 1
b.heroes.hero_rhodes.basic_melee.damage_min = {
	8,
	10,
	11,
	12,
	13,
	14,
	16,
	17,
	18,
	19
}
b.heroes.hero_rhodes.basic_melee.damage_max = {
	13,
	14,
	16,
	18,
	20,
	22,
	23,
	25,
	27,
	29
}
b.heroes.hero_rhodes.basic_melee.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_rhodes.skill_a = {}
b.heroes.hero_rhodes.skill_a.cooldown = 8
b.heroes.hero_rhodes.skill_a.xp_gain = {
	8,
	15,
	21
}
b.heroes.hero_rhodes.skill_a.damage_min = 16
b.heroes.hero_rhodes.skill_a.damage_max = 24
b.heroes.hero_rhodes.skill_a.damage_type = DAMAGE_TRUE
b.heroes.hero_rhodes.skill_a.min_range = 50
b.heroes.hero_rhodes.skill_a.max_range = 200
b.heroes.hero_rhodes.skill_a.stun_duration = 0.5
b.heroes.hero_rhodes.skill_b = {}
b.heroes.hero_rhodes.skill_b.cooldown = 22
b.heroes.hero_rhodes.skill_b.xp_gain = {
	22,
	44,
	66
}
b.heroes.hero_rhodes.skill_b.duration = 6
b.heroes.hero_rhodes.skill_b.hp_heal_ptg = 0.3
b.heroes.hero_rhodes.skill_b.armor_inc = 0.3
b.heroes.hero_rhodes.skill_b.trigger_hp_ptg = 0.7
b.heroes.hero_rhodes.skill_b.time_blocking_to_trigger = 5
b.heroes.hero_rhodes.skill_c = {}
b.heroes.hero_rhodes.skill_c.cooldown = 16
b.heroes.hero_rhodes.skill_c.xp_gain = {
	16,
	32,
	48
}
b.heroes.hero_rhodes.skill_c.range = 150
b.heroes.hero_rhodes.skill_c.range_pre_block = 175
b.heroes.hero_rhodes.skill_c.min_targets = 3
b.heroes.hero_rhodes.skill_c.aura = {}
b.heroes.hero_rhodes.skill_c.aura.damage_min = 12
b.heroes.hero_rhodes.skill_c.aura.damage_max = 18
b.heroes.hero_rhodes.skill_c.aura.s_damage_min = 32
b.heroes.hero_rhodes.skill_c.aura.s_damage_max = 48
b.heroes.hero_rhodes.skill_c.aura.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_rhodes.skill_c.aura.travel_distance = 18
b.heroes.hero_rhodes.skill_c.aura.range = 75
b.heroes.hero_rhodes.skill_c.aura.speed = 200
b.heroes.hero_rhodes.skill_c.aura.cycle_time = 0.25
b.heroes.hero_rhodes.skill_c.slow = {}
b.heroes.hero_rhodes.skill_c.slow.duration = 4
b.heroes.hero_rhodes.skill_c.slow.factor = 0.8
b.heroes.hero_rhodes.skill_c.slow.s_factor = 1 - b.heroes.hero_rhodes.skill_c.slow.factor
b.heroes.hero_rhodes.ultimate = {}
b.heroes.hero_rhodes.ultimate.cooldown = 35
b.heroes.hero_rhodes.ultimate.xp_gain = {
	35
}
b.heroes.hero_rhodes.ultimate.damage_min = 30
b.heroes.hero_rhodes.ultimate.damage_max = 42
b.heroes.hero_rhodes.ultimate.damage_radius = 55
b.heroes.hero_rhodes.ultimate.damage_type = DAMAGE_TRUE
b.heroes.hero_rhodes.ultimate.range = 225
b.heroes.hero_rhodes.ultimate.range_pre_block = 250
b.heroes.hero_rhodes.ultimate.ray_duration = 3
b.heroes.hero_rhodes.ultimate.min_targets = 3
b.heroes.hero_rhodes.ultimate.move_speed = 40
b.heroes.hero_rhodes.ultimate.cycle_time = 0.25
b.heroes.hero_rhodes.ultimate.s_total_min_damage = 120
b.heroes.hero_rhodes.ultimate.s_total_max_damage = 160
b.heroes.hero_rhodes.ultimate.slow = {}
b.heroes.hero_rhodes.ultimate.slow.duration = 1
b.heroes.hero_rhodes.ultimate.slow.factor = 0.5
b.heroes.hero_rhodes.ultimate.slow.s_factor = 1 - b.heroes.hero_rhodes.ultimate.slow.factor
b.heroes.hero_rhodes.talent_1 = {}
b.heroes.hero_rhodes.talent_1.hp_threshold = 0.75
b.heroes.hero_rhodes.talent_1.armor_inc = 0.2
b.heroes.hero_rhodes.upgrades = {}
b.heroes.hero_rhodes.upgrades.upg_sa1 = {}
b.heroes.hero_rhodes.upgrades.upg_sa1.cooldown = 7
b.heroes.hero_rhodes.upgrades.upg_sa1.damage_min = 32
b.heroes.hero_rhodes.upgrades.upg_sa1.damage_max = 48
b.heroes.hero_rhodes.upgrades.upg_sa2 = {}
b.heroes.hero_rhodes.upgrades.upg_sa2.cooldown = 6
b.heroes.hero_rhodes.upgrades.upg_sa2.damage_min = 56
b.heroes.hero_rhodes.upgrades.upg_sa2.damage_max = 84
b.heroes.hero_rhodes.upgrades.upg_sb1 = {}
b.heroes.hero_rhodes.upgrades.upg_sb1.hp_heal_ptg = 0.4
b.heroes.hero_rhodes.upgrades.upg_sb1.armor_inc = 0.4
b.heroes.hero_rhodes.upgrades.upg_sb1.trigger_hp_ptg = 0.7
b.heroes.hero_rhodes.upgrades.upg_sb2 = {}
b.heroes.hero_rhodes.upgrades.upg_sb2.hp_heal_ptg = 0.5
b.heroes.hero_rhodes.upgrades.upg_sb2.armor_inc = 0.5
b.heroes.hero_rhodes.upgrades.upg_sb2.trigger_hp_ptg = 0.7
b.heroes.hero_rhodes.upgrades.upg_sc1 = {}
b.heroes.hero_rhodes.upgrades.upg_sc1.slow_factor = 0.7
b.heroes.hero_rhodes.upgrades.upg_sc1.s_slow_factor = 1 - b.heroes.hero_rhodes.upgrades.upg_sc1.slow_factor
b.heroes.hero_rhodes.upgrades.upg_sc2 = {}
b.heroes.hero_rhodes.upgrades.upg_sc2.damage_min = 16
b.heroes.hero_rhodes.upgrades.upg_sc2.damage_max = 24
b.heroes.hero_rhodes.upgrades.upg_sc2.s_damage_min = 48
b.heroes.hero_rhodes.upgrades.upg_sc2.s_damage_max = 72
b.heroes.hero_rhodes.upgrades.upg_a = {}
b.heroes.hero_rhodes.upgrades.upg_a.regen_factor = 1.15
b.heroes.hero_rhodes.upgrades.upg_a.s_regen_factor = sub_one(b.heroes.hero_rhodes.upgrades.upg_a.regen_factor)
b.heroes.hero_rhodes.upgrades.upg_b = {}
b.heroes.hero_rhodes.upgrades.upg_b.hp_ptg = 0.1
b.heroes.hero_rhodes.upgrades.upg_b.s_hp_ptg = b.heroes.hero_rhodes.upgrades.upg_b.hp_ptg
b.heroes.hero_rhodes.upgrades.upg_c = {}
b.heroes.hero_rhodes.upgrades.upg_c.armor_inc = 0.15
b.heroes.hero_rhodes.upgrades.upg_d = {}
b.heroes.hero_rhodes.upgrades.upg_d.dmg_factor = 1.1
b.heroes.hero_rhodes.upgrades.upg_d.s_dmg_factor = sub_one(b.heroes.hero_rhodes.upgrades.upg_d.dmg_factor)
b.heroes.hero_rhodes.upgrades.upg_e = {}
b.heroes.hero_rhodes.upgrades.upg_e.skills_cd_red_factor = 0.1
b.heroes.hero_rhodes.upgrades.upg_e.skill_red_factor = b.heroes.hero_rhodes.upgrades.upg_e.skills_cd_red_factor
b.heroes.hero_drakkan = {}
b.heroes.hero_drakkan.stats = {}
b.heroes.hero_drakkan.stats.hp = 8.5
b.heroes.hero_drakkan.stats.armor = 2
b.heroes.hero_drakkan.stats.damage = 8
b.heroes.hero_drakkan.stats.cooldown = 3.5
b.heroes.hero_drakkan.dead_lifetime = 30
b.heroes.hero_drakkan.speed = 100
b.heroes.hero_drakkan.regen_cooldown = 1
b.heroes.hero_drakkan.armor = {
	0,
	0.02,
	0.04,
	0.06,
	0.08,
	0.1,
	0.12,
	0.14,
	0.16,
	0.18
}
b.heroes.hero_drakkan.hp_max = {
	230,
	255,
	280,
	305,
	330,
	355,
	380,
	405,
	430,
	455
}
b.heroes.hero_drakkan.regen_health = {
	18,
	20,
	22,
	24,
	26,
	28,
	30,
	32,
	34,
	36
}
b.heroes.hero_drakkan.basic_attack = {}
b.heroes.hero_drakkan.basic_attack.min_range = 50
b.heroes.hero_drakkan.basic_attack.max_range = 220
b.heroes.hero_drakkan.basic_attack.damage_type = DAMAGE_MAGICAL
b.heroes.hero_drakkan.basic_attack.cooldown = 2
b.heroes.hero_drakkan.basic_attack.xp_gain_factor = 0.6
b.heroes.hero_drakkan.basic_attack.damage_min = {
	13,
	16,
	19,
	22,
	26,
	29,
	32,
	35,
	38,
	42
}
b.heroes.hero_drakkan.basic_attack.damage_max = {
	19,
	24,
	29,
	34,
	38,
	43,
	48,
	53,
	58,
	62
}
b.heroes.hero_drakkan.basic_attack.damage_radius = 40
b.heroes.hero_drakkan.skill_a = {}
b.heroes.hero_drakkan.skill_a.cooldown = 15
b.heroes.hero_drakkan.skill_a.xp_gain = {
	15,
	30,
	45
}
b.heroes.hero_drakkan.skill_a.min_targets = 3
b.heroes.hero_drakkan.skill_a.min_range = 50
b.heroes.hero_drakkan.skill_a.max_range = 160
b.heroes.hero_drakkan.skill_a.silence = {}
b.heroes.hero_drakkan.skill_a.silence.duration = 8
b.heroes.hero_drakkan.skill_a.aura = {}
b.heroes.hero_drakkan.skill_a.aura.duration = fts(45)
b.heroes.hero_drakkan.skill_a.aura.damage_min = 6
b.heroes.hero_drakkan.skill_a.aura.damage_max = 9
b.heroes.hero_drakkan.skill_a.aura.s_damage_min = 24
b.heroes.hero_drakkan.skill_a.aura.s_damage_max = 36
b.heroes.hero_drakkan.skill_a.aura.damage_type = DAMAGE_MAGICAL
b.heroes.hero_drakkan.skill_a.aura.damage_every = 0.25
b.heroes.hero_drakkan.skill_a.aura.damage_radius = 75
b.heroes.hero_drakkan.skill_b = {}
b.heroes.hero_drakkan.skill_b.cooldown = 18
b.heroes.hero_drakkan.skill_b.xp_gain = {
	18,
	36,
	54
}
b.heroes.hero_drakkan.skill_b.min_targets = 3
b.heroes.hero_drakkan.skill_b.min_range = 50
b.heroes.hero_drakkan.skill_b.max_range = 90
b.heroes.hero_drakkan.skill_b.aura = {}
b.heroes.hero_drakkan.skill_b.aura.damage_type = DAMAGE_MAGICAL
b.heroes.hero_drakkan.skill_b.aura.damage_min = 24
b.heroes.hero_drakkan.skill_b.aura.damage_max = 36
b.heroes.hero_drakkan.skill_b.aura.damage_radius = 90
b.heroes.hero_drakkan.skill_c = {}
b.heroes.hero_drakkan.skill_c.cooldown = 28
b.heroes.hero_drakkan.skill_c.range = 220
b.heroes.hero_drakkan.skill_c.xp_gain = {
	28,
	56,
	84
}
b.heroes.hero_drakkan.skill_c.clone = {}
b.heroes.hero_drakkan.skill_c.clone.speed = 100
b.heroes.hero_drakkan.skill_c.clone.regen_cooldown = 1
b.heroes.hero_drakkan.skill_c.clone.armor = 0.06
b.heroes.hero_drakkan.skill_c.clone.hp_max = 240
b.heroes.hero_drakkan.skill_c.clone.regen_health = 19
b.heroes.hero_drakkan.skill_c.clone.spawn_offset = v(-50, 15)
b.heroes.hero_drakkan.skill_c.clone.duration = 10
b.heroes.hero_drakkan.skill_c.clone.basic_attack = {}
b.heroes.hero_drakkan.skill_c.clone.basic_attack.min_range = b.heroes.hero_drakkan.basic_attack.min_range
b.heroes.hero_drakkan.skill_c.clone.basic_attack.max_range = b.heroes.hero_drakkan.basic_attack.max_range
b.heroes.hero_drakkan.skill_c.clone.basic_attack.damage_type = DAMAGE_MAGICAL
b.heroes.hero_drakkan.skill_c.clone.basic_attack.cooldown = b.heroes.hero_drakkan.basic_attack.cooldown
b.heroes.hero_drakkan.skill_c.clone.basic_attack.damage_min = 19
b.heroes.hero_drakkan.skill_c.clone.basic_attack.damage_max = 29
b.heroes.hero_drakkan.skill_c.clone.basic_attack.damage_radius = b.heroes.hero_drakkan.basic_attack.damage_radius
b.heroes.hero_drakkan.ultimate = {}
b.heroes.hero_drakkan.ultimate.cooldown = 40
b.heroes.hero_drakkan.ultimate.xp_gain = {
	40
}
b.heroes.hero_drakkan.ultimate.min_targets = 7
b.heroes.hero_drakkan.ultimate.max_range = 2000
b.heroes.hero_drakkan.ultimate.shots = 7
b.heroes.hero_drakkan.ultimate.damage_min = 40
b.heroes.hero_drakkan.ultimate.damage_max = 60
b.heroes.hero_drakkan.ultimate.damage_type = DAMAGE_MAGICAL
b.heroes.hero_drakkan.ultimate.damage_radius = 70
b.heroes.hero_drakkan.talent_1 = {}
b.heroes.hero_drakkan.talent_1.cooldown = 2
b.heroes.hero_drakkan.talent_1.min_dist = 250
b.heroes.hero_drakkan.talent_2 = {}
b.heroes.hero_drakkan.talent_2.skills_cd_red = 0.2
b.heroes.hero_drakkan.upgrades = {}
b.heroes.hero_drakkan.upgrades.upg_sa1 = {}
b.heroes.hero_drakkan.upgrades.upg_sa1.damage_min = 8
b.heroes.hero_drakkan.upgrades.upg_sa1.damage_max = 12
b.heroes.hero_drakkan.upgrades.upg_sa1.s_damage_min = 48
b.heroes.hero_drakkan.upgrades.upg_sa1.s_damage_max = 72
b.heroes.hero_drakkan.upgrades.upg_sa1.silence_duration = 10
b.heroes.hero_drakkan.upgrades.upg_sa2 = {}
b.heroes.hero_drakkan.upgrades.upg_sa2.damage_min = 12
b.heroes.hero_drakkan.upgrades.upg_sa2.damage_max = 18
b.heroes.hero_drakkan.upgrades.upg_sa2.s_damage_min = 72
b.heroes.hero_drakkan.upgrades.upg_sa2.s_damage_max = 108
b.heroes.hero_drakkan.upgrades.upg_sa2.silence_duration = 12
b.heroes.hero_drakkan.upgrades.upg_sb1 = {}
b.heroes.hero_drakkan.upgrades.upg_sb1.damage_min = 48
b.heroes.hero_drakkan.upgrades.upg_sb1.damage_max = 72
b.heroes.hero_drakkan.upgrades.upg_sb2 = {}
b.heroes.hero_drakkan.upgrades.upg_sb2.damage_min = 82
b.heroes.hero_drakkan.upgrades.upg_sb2.damage_max = 114
b.heroes.hero_drakkan.upgrades.upg_sc1 = {}
b.heroes.hero_drakkan.upgrades.upg_sc1.duration = 13
b.heroes.hero_drakkan.upgrades.upg_sc2 = {}
b.heroes.hero_drakkan.upgrades.upg_sc2.duration = 16
b.heroes.hero_drakkan.upgrades.upg_a = {}
b.heroes.hero_drakkan.upgrades.upg_a.magic_res = 1
b.heroes.hero_drakkan.upgrades.upg_b = {}
b.heroes.hero_drakkan.upgrades.upg_b.regen_factor = 1.2
b.heroes.hero_drakkan.upgrades.upg_b.s_regen_factor = sub_one(b.heroes.hero_drakkan.upgrades.upg_b.regen_factor)
b.heroes.hero_drakkan.upgrades.upg_c = {}
b.heroes.hero_drakkan.upgrades.upg_c.skill_dmg_factor = 1.1
b.heroes.hero_drakkan.upgrades.upg_c.s_skill_dmg_factor = sub_one(b.heroes.hero_drakkan.upgrades.upg_c.skill_dmg_factor)
b.heroes.hero_drakkan.upgrades.upg_d = {}
b.heroes.hero_drakkan.upgrades.upg_d.dmg_factor = 1.1
b.heroes.hero_drakkan.upgrades.upg_d.s_dmg_factor = sub_one(b.heroes.hero_drakkan.upgrades.upg_d.dmg_factor)
b.heroes.hero_drakkan.upgrades.upg_e = {}
b.heroes.hero_drakkan.upgrades.upg_e.range_factor = 1.2
b.heroes.hero_drakkan.upgrades.upg_e.s_range_factor = sub_one(b.heroes.hero_drakkan.upgrades.upg_e.range_factor)
b.heroes.hero_myriath = {}
b.heroes.hero_myriath.stats = {}
b.heroes.hero_myriath.stats.hp = 2
b.heroes.hero_myriath.stats.armor = 0
b.heroes.hero_myriath.stats.damage = 5
b.heroes.hero_myriath.stats.cooldown = 5.5
b.heroes.hero_myriath.dead_lifetime = 30
b.heroes.hero_myriath.speed = 90
b.heroes.hero_myriath.regen_cooldown = 1
b.heroes.hero_myriath.armor = {
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
b.heroes.hero_myriath.hp_max = {
	170,
	180,
	190,
	200,
	210,
	220,
	230,
	240,
	250,
	260
}
b.heroes.hero_myriath.regen_health = {
	14,
	14,
	15,
	16,
	17,
	18,
	18,
	19,
	20,
	21
}
b.heroes.hero_myriath.basic_melee = {}
b.heroes.hero_myriath.basic_melee.cooldown = 1.5
b.heroes.hero_myriath.basic_melee.xp_gain_factor = 0.8
b.heroes.hero_myriath.basic_melee.damage_min = {
	12,
	14,
	16,
	17,
	19,
	21,
	23,
	25,
	26,
	28
}
b.heroes.hero_myriath.basic_melee.damage_max = {
	18,
	21,
	23,
	26,
	29,
	32,
	34,
	37,
	40,
	42
}
b.heroes.hero_myriath.basic_melee.damage_type = DAMAGE_MAGICAL
b.heroes.hero_myriath.basic_ranged = {}
b.heroes.hero_myriath.basic_ranged.cooldown = 1.5
b.heroes.hero_myriath.basic_ranged.xp_gain_factor = 0.8
b.heroes.hero_myriath.basic_ranged.max_range = 125
b.heroes.hero_myriath.basic_ranged.min_range = 70
b.heroes.hero_myriath.basic_ranged.damage_min = {
	12,
	14,
	16,
	17,
	19,
	21,
	23,
	25,
	26,
	28
}
b.heroes.hero_myriath.basic_ranged.damage_max = {
	18,
	21,
	23,
	26,
	29,
	32,
	34,
	37,
	40,
	42
}
b.heroes.hero_myriath.basic_ranged.damage_type = DAMAGE_MAGICAL
b.heroes.hero_myriath.skill_a = {}
b.heroes.hero_myriath.skill_a.cooldown = 6
b.heroes.hero_myriath.skill_a.min_range = 75
b.heroes.hero_myriath.skill_a.max_range = 130
b.heroes.hero_myriath.skill_a.xp_gain = {
	6,
	12,
	18
}
b.heroes.hero_myriath.skill_a.damage_min = 12
b.heroes.hero_myriath.skill_a.damage_max = 18
b.heroes.hero_myriath.skill_a.damage_type = DAMAGE_MAGICAL
b.heroes.hero_myriath.skill_b = {}
b.heroes.hero_myriath.skill_b.cooldown = 16
b.heroes.hero_myriath.skill_b.xp_gain = {
	16,
	32,
	48
}
b.heroes.hero_myriath.skill_b.min_distance_from_end = 200
b.heroes.hero_myriath.skill_b.distance = 50
b.heroes.hero_myriath.skill_c = {}
b.heroes.hero_myriath.skill_c.damage_min = 6
b.heroes.hero_myriath.skill_c.damage_max = 8
b.heroes.hero_myriath.skill_c.s_damage_min = 36
b.heroes.hero_myriath.skill_c.s_damage_max = 48
b.heroes.hero_myriath.skill_c.damage_type = DAMAGE_MAGICAL
b.heroes.hero_myriath.skill_c.cooldown = 12
b.heroes.hero_myriath.skill_c.xp_gain = {
	12,
	24,
	48
}
b.heroes.hero_myriath.ultimate = {}
b.heroes.hero_myriath.ultimate.cooldown = 40
b.heroes.hero_myriath.ultimate.xp_gain = {
	40
}
b.heroes.hero_myriath.ultimate.min_targets = 3
b.heroes.hero_myriath.ultimate.distance = 40
b.heroes.hero_myriath.ultimate.min_detection_range = 20
b.heroes.hero_myriath.ultimate.max_detection_range = 80
b.heroes.hero_myriath.ultimate.damage_min = 60
b.heroes.hero_myriath.ultimate.damage_max = 90
b.heroes.hero_myriath.ultimate.damage_type = DAMAGE_MAGICAL
b.heroes.hero_myriath.ultimate.damage_radius = 55
b.heroes.hero_myriath.ultimate.max_speed = 80
b.heroes.hero_myriath.ultimate.clone_count = 3
b.heroes.hero_myriath.talent_1 = {}
b.heroes.hero_myriath.talent_1.health_inc = 25
b.heroes.hero_myriath.talent_1.s_health_inc = 110
b.heroes.hero_myriath.talent_1.duration_inc = 2
b.heroes.hero_myriath.talent_1.s_duration_inc = 8
b.heroes.hero_myriath.talent_2 = {}
b.heroes.hero_myriath.talent_2.radius = 75
b.heroes.hero_myriath.talent_2.damage_min = 48
b.heroes.hero_myriath.talent_2.damage_max = 72
b.heroes.hero_myriath.talent_2.damage_type = DAMAGE_MAGICAL
b.heroes.hero_myriath.clone = {}
b.heroes.hero_myriath.clone.stats = {}
b.heroes.hero_myriath.clone.stats.hp = 2
b.heroes.hero_myriath.clone.stats.armor = 0
b.heroes.hero_myriath.clone.stats.damage = 7
b.heroes.hero_myriath.clone.stats.cooldown = 8
b.heroes.hero_myriath.clone.speed = 100
b.heroes.hero_myriath.clone.regen_cooldown = 1
b.heroes.hero_myriath.clone.armor = 0
b.heroes.hero_myriath.clone.hp_max = 85
b.heroes.hero_myriath.clone.regen_health = 7
b.heroes.hero_myriath.clone.duration = 6
b.heroes.hero_myriath.clone.basic_melee_attack_ptg = 0.68
b.heroes.hero_myriath.clone.basic_ranged_attack_ptg = 0.68
b.heroes.hero_myriath.clone.skill_c_attack_ptg = 1
b.heroes.hero_myriath.upgrades = {}
b.heroes.hero_myriath.upgrades.upg_sa1 = {}
b.heroes.hero_myriath.upgrades.upg_sa1.min_damage = 24
b.heroes.hero_myriath.upgrades.upg_sa1.max_damage = 36
b.heroes.hero_myriath.upgrades.upg_sa2 = {}
b.heroes.hero_myriath.upgrades.upg_sa2.min_damage = 36
b.heroes.hero_myriath.upgrades.upg_sa2.max_damage = 54
b.heroes.hero_myriath.upgrades.upg_sb1 = {}
b.heroes.hero_myriath.upgrades.upg_sb1.cooldown = 13
b.heroes.hero_myriath.upgrades.upg_sb2 = {}
b.heroes.hero_myriath.upgrades.upg_sb2.cooldown = 10
b.heroes.hero_myriath.upgrades.upg_sc1 = {}
b.heroes.hero_myriath.upgrades.upg_sc1.damage_min = 7
b.heroes.hero_myriath.upgrades.upg_sc1.damage_max = 10
b.heroes.hero_myriath.upgrades.upg_sc1.s_damage_min = 42
b.heroes.hero_myriath.upgrades.upg_sc1.s_damage_max = 60
b.heroes.hero_myriath.upgrades.upg_sc2 = {}
b.heroes.hero_myriath.upgrades.upg_sc2.damage_min = 8
b.heroes.hero_myriath.upgrades.upg_sc2.damage_max = 12
b.heroes.hero_myriath.upgrades.upg_sc2.s_damage_min = 48
b.heroes.hero_myriath.upgrades.upg_sc2.s_damage_max = 72
b.heroes.hero_myriath.upgrades.upg_a = {}
b.heroes.hero_myriath.upgrades.upg_a.movement_factor = 1.5
b.heroes.hero_myriath.upgrades.upg_a.s_movement_factor = sub_one(b.heroes.hero_myriath.upgrades.upg_a.movement_factor)
b.heroes.hero_myriath.upgrades.upg_b = {}
b.heroes.hero_myriath.upgrades.upg_b.damage_factor = 1.05
b.heroes.hero_myriath.upgrades.upg_b.s_dmg_factor = sub_one(b.heroes.hero_myriath.upgrades.upg_b.damage_factor)
b.heroes.hero_myriath.upgrades.upg_c = {}
b.heroes.hero_myriath.upgrades.upg_c.attack_cooldown = 1
b.heroes.hero_myriath.upgrades.upg_c.s_attack_cooldown = 0.35
b.heroes.hero_myriath.upgrades.upg_d = {}
b.heroes.hero_myriath.upgrades.upg_d.dodge_chance = 0.2
b.heroes.hero_myriath.upgrades.upg_e = {}
b.heroes.hero_myriath.upgrades.upg_e.skill_red_factor = 0.15
b.heroes.hero_myriath.upgrades.upg_e.ult_red_factor = 0.05
b.heroes.hero_connor = {}
b.heroes.hero_connor.stats = {}
b.heroes.hero_connor.stats.hp = 4.5
b.heroes.hero_connor.stats.armor = 2.5
b.heroes.hero_connor.stats.damage = 4.5
b.heroes.hero_connor.stats.cooldown = 4.5
b.heroes.hero_connor.dead_lifetime = 30
b.heroes.hero_connor.speed = 70
b.heroes.hero_connor.regen_cooldown = 1
b.heroes.hero_connor.armor = {
	0.07,
	0.09,
	0.11,
	0.13,
	0.15,
	0.17,
	0.19,
	0.21,
	0.23,
	0.25
}
b.heroes.hero_connor.hp_max = {
	200,
	215,
	230,
	245,
	260,
	275,
	290,
	305,
	320,
	335
}
b.heroes.hero_connor.regen_health = {
	16,
	17,
	18,
	20,
	21,
	22,
	23,
	24,
	26,
	27
}
b.heroes.hero_connor.basic_melee = {}
b.heroes.hero_connor.basic_melee.cooldown = 1.75
b.heroes.hero_connor.basic_melee.xp_gain_factor = 0.9
b.heroes.hero_connor.basic_melee.damage_min = {
	13,
	14,
	15,
	17,
	18,
	20,
	21,
	22,
	24,
	25
}
b.heroes.hero_connor.basic_melee.damage_max = {
	19,
	21,
	23,
	25,
	27,
	29,
	32,
	34,
	36,
	38
}
b.heroes.hero_connor.basic_melee.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_connor.skill_a = {}
b.heroes.hero_connor.skill_a.cooldown = 16
b.heroes.hero_connor.skill_a.xp_gain = {
	16,
	32,
	48
}
b.heroes.hero_connor.skill_a.min_targets = 3
b.heroes.hero_connor.skill_a.min_range = 0
b.heroes.hero_connor.skill_a.max_range = 100
b.heroes.hero_connor.skill_a.damage_min = 12
b.heroes.hero_connor.skill_a.damage_max = 18
b.heroes.hero_connor.skill_a.damage_radius = 170
b.heroes.hero_connor.skill_a.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_connor.skill_a.bleed = {}
b.heroes.hero_connor.skill_a.bleed.duration = 4
b.heroes.hero_connor.skill_a.bleed.cycle_time = 0.25
b.heroes.hero_connor.skill_a.bleed.damage_min = 1
b.heroes.hero_connor.skill_a.bleed.damage_max = 1
b.heroes.hero_connor.skill_a.bleed.s_damage = 16
b.heroes.hero_connor.skill_a.bleed.sa1_damage = 24
b.heroes.hero_connor.skill_a.bleed.sa2_damage = 36
b.heroes.hero_connor.skill_a.bleed.damage_type = DAMAGE_TRUE
b.heroes.hero_connor.skill_b = {}
b.heroes.hero_connor.skill_b.cooldown = 25
b.heroes.hero_connor.skill_b.xp_gain = {
	25,
	50,
	75
}
b.heroes.hero_connor.skill_b.min_range = 50
b.heroes.hero_connor.skill_b.max_range = 90
b.heroes.hero_connor.skill_b.time_to_block = 2
b.heroes.hero_connor.skill_b.damage_min = 64
b.heroes.hero_connor.skill_b.damage_max = 96
b.heroes.hero_connor.skill_b.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_connor.skill_c = {}
b.heroes.hero_connor.skill_c.cooldown = 22
b.heroes.hero_connor.skill_c.range = 220
b.heroes.hero_connor.skill_c.xp_gain = {
	22,
	44,
	66
}
b.heroes.hero_connor.skill_c.min_range = 0
b.heroes.hero_connor.skill_c.max_range = 190
b.heroes.hero_connor.skill_c.min_targets = 3
b.heroes.hero_connor.skill_c.amount_of_aoes = 4
b.heroes.hero_connor.skill_c.node_between_aoes = 5
b.heroes.hero_connor.skill_c.damage_min = 44
b.heroes.hero_connor.skill_c.damage_max = 68
b.heroes.hero_connor.skill_c.damage_radius = 40
b.heroes.hero_connor.skill_c.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_connor.ultimate = {}
b.heroes.hero_connor.ultimate.cooldown = 30
b.heroes.hero_connor.ultimate.xp_gain = {
	30
}
b.heroes.hero_connor.ultimate.min_targets = 1
b.heroes.hero_connor.ultimate.min_range = 0
b.heroes.hero_connor.ultimate.max_range = 120
b.heroes.hero_connor.ultimate.duration = 10
b.heroes.hero_connor.ultimate.basic_attack_cooldown = 1
b.heroes.hero_connor.ultimate.s_basic_attack_cooldown = 0.55
b.heroes.hero_connor.ultimate.base_damage_factor = 2
b.heroes.hero_connor.ultimate.s_base_damage_factor = sub_one(b.heroes.hero_connor.ultimate.base_damage_factor)
b.heroes.hero_connor.ultimate.movement_speed_factor = 1.3
b.heroes.hero_connor.ultimate.s_movement_speed = sub_one(b.heroes.hero_connor.ultimate.movement_speed_factor)
b.heroes.hero_connor.ultimate.basic_attack_xp_gain_factor = 0.8
b.heroes.hero_connor.ultimate.hp_ptg_to_trigger = 0.8
b.heroes.hero_connor.ultimate.stun = {}
b.heroes.hero_connor.ultimate.stun.damage_min = 20
b.heroes.hero_connor.ultimate.stun.damage_max = 20
b.heroes.hero_connor.ultimate.stun.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_connor.ultimate.stun.range = 100
b.heroes.hero_connor.ultimate.stun.duration = 1
b.heroes.hero_connor.talent_1 = {}
b.heroes.hero_connor.talent_1.hp_ptg_to_trigger = 0.4
b.heroes.hero_connor.talent_1.skill_damage_factor = 1.4
b.heroes.hero_connor.talent_1.s_skill_damage_factor = sub_one(b.heroes.hero_connor.talent_1.skill_damage_factor)
b.heroes.hero_connor.talent_2 = {}
b.heroes.hero_connor.talent_2.chance_to_revive = 1
b.heroes.hero_connor.talent_2.cooldown = 180
b.heroes.hero_connor.talent_2.hp_ptg_on_revive = 0.7
b.heroes.hero_connor.talent_2.starting_cd = 0
b.heroes.hero_connor.upgrades = {}
b.heroes.hero_connor.upgrades.upg_sa1 = {}
b.heroes.hero_connor.upgrades.upg_sa1.bleed_duration = 6
b.heroes.hero_connor.upgrades.upg_sa1.damage_min = 32
b.heroes.hero_connor.upgrades.upg_sa1.damage_max = 48
b.heroes.hero_connor.upgrades.upg_sa2 = {}
b.heroes.hero_connor.upgrades.upg_sa2.bleed_duration = 8
b.heroes.hero_connor.upgrades.upg_sa2.damage_min = 52
b.heroes.hero_connor.upgrades.upg_sa2.damage_max = 78
b.heroes.hero_connor.upgrades.upg_sb1 = {}
b.heroes.hero_connor.upgrades.upg_sb1.damage_min = 80
b.heroes.hero_connor.upgrades.upg_sb1.damage_max = 120
b.heroes.hero_connor.upgrades.upg_sb1.cooldown = 22
b.heroes.hero_connor.upgrades.upg_sb2 = {}
b.heroes.hero_connor.upgrades.upg_sb2.damage_min = 96
b.heroes.hero_connor.upgrades.upg_sb2.damage_max = 144
b.heroes.hero_connor.upgrades.upg_sb2.cooldown = 19
b.heroes.hero_connor.upgrades.upg_sc1 = {}
b.heroes.hero_connor.upgrades.upg_sc1.amount_of_aoes = 6
b.heroes.hero_connor.upgrades.upg_sc1.damage_min = 54
b.heroes.hero_connor.upgrades.upg_sc1.damage_max = 82
b.heroes.hero_connor.upgrades.upg_sc2 = {}
b.heroes.hero_connor.upgrades.upg_sc2.amount_of_aoes = 8
b.heroes.hero_connor.upgrades.upg_sc2.damage_min = 74
b.heroes.hero_connor.upgrades.upg_sc2.damage_max = 106
b.heroes.hero_connor.upgrades.upg_a = {}
b.heroes.hero_connor.upgrades.upg_a.hp_ptg = 0.1
b.heroes.hero_connor.upgrades.upg_b = {}
b.heroes.hero_connor.upgrades.upg_b.armor_inc = 0.1
b.heroes.hero_connor.upgrades.upg_c = {}
b.heroes.hero_connor.upgrades.upg_c.skills_cd_red_factor = 0.1
b.heroes.hero_connor.upgrades.upg_c.ult_cd_red_factor = 0.05
b.heroes.hero_connor.upgrades.upg_c.skill_red_factor = b.heroes.hero_connor.upgrades.upg_c.skills_cd_red_factor
b.heroes.hero_connor.upgrades.upg_d = {}
b.heroes.hero_connor.upgrades.upg_d.dmg_factor = 1.1
b.heroes.hero_connor.upgrades.upg_d.s_dmg_factor = sub_one(b.heroes.hero_connor.upgrades.upg_d.dmg_factor)
b.heroes.hero_connor.upgrades.upg_e = {}
b.heroes.hero_connor.upgrades.upg_e.attack_cooldown = 1.5
b.heroes.hero_connor.upgrades.upg_e.s_attack_cooldown = 0.15
b.heroes.hero_ignus = {}
b.heroes.hero_ignus.throttled_cooldown = 1
b.heroes.hero_ignus.stats = {}
b.heroes.hero_ignus.stats.hp = 5
b.heroes.hero_ignus.stats.armor = 0
b.heroes.hero_ignus.stats.damage = 3.5
b.heroes.hero_ignus.stats.cooldown = 7.5
b.heroes.hero_ignus.dead_lifetime = 30
b.heroes.hero_ignus.speed = 70
b.heroes.hero_ignus.regen_cooldown = 1
b.heroes.hero_ignus.armor = {
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
b.heroes.hero_ignus.hp_max = {
	210,
	225,
	240,
	255,
	270,
	285,
	300,
	315,
	330,
	345
}
b.heroes.hero_ignus.regen_health = {
	17,
	18,
	19,
	20,
	22,
	23,
	24,
	25,
	26,
	28
}
b.heroes.hero_ignus.basic_melee = {}
b.heroes.hero_ignus.basic_melee.xp_gain_factor = 0.7
b.heroes.hero_ignus.basic_melee.damage_min = {
	3,
	3,
	4,
	4,
	5,
	5,
	6,
	7,
	7,
	8
}
b.heroes.hero_ignus.basic_melee.damage_max = {
	4,
	5,
	6,
	7,
	7,
	8,
	9,
	10,
	11,
	11
}
b.heroes.hero_ignus.basic_melee.damage_type = DAMAGE_TRUE
b.heroes.hero_ignus.skill_a = {}
b.heroes.hero_ignus.skill_a.cooldown = 10
b.heroes.hero_ignus.skill_a.xp_gain = {
	10,
	20,
	30
}
b.heroes.hero_ignus.skill_a.damage_min = 40
b.heroes.hero_ignus.skill_a.damage_max = 60
b.heroes.hero_ignus.skill_a.damage_type = DAMAGE_TRUE
b.heroes.hero_ignus.skill_a.min_range = 50
b.heroes.hero_ignus.skill_a.max_range = 120
b.heroes.hero_ignus.skill_b = {}
b.heroes.hero_ignus.skill_b.cooldown = 18
b.heroes.hero_ignus.skill_b.xp_gain = {
	18,
	36,
	54
}
b.heroes.hero_ignus.skill_b.min_targets = 3
b.heroes.hero_ignus.skill_b.detection_range = 90
b.heroes.hero_ignus.skill_b.damage_radius = 100
b.heroes.hero_ignus.skill_b.damage_min = 48
b.heroes.hero_ignus.skill_b.damage_max = 90
b.heroes.hero_ignus.skill_b.damage_type = DAMAGE_TRUE
b.heroes.hero_ignus.skill_c = {}
b.heroes.hero_ignus.skill_c.cooldown = 15
b.heroes.hero_ignus.skill_c.xp_gain = {
	15,
	30,
	45
}
b.heroes.hero_ignus.skill_c.detection_range = 100
b.heroes.hero_ignus.skill_c.bounce_range = 120
b.heroes.hero_ignus.skill_c.max_hits = 3
b.heroes.hero_ignus.skill_c.damage_min = 56
b.heroes.hero_ignus.skill_c.damage_max = 84
b.heroes.hero_ignus.skill_c.damage_type = DAMAGE_TRUE
b.heroes.hero_ignus.ultimate = {}
b.heroes.hero_ignus.ultimate.cooldown = 30
b.heroes.hero_ignus.ultimate.xp_gain = {
	30
}
b.heroes.hero_ignus.ultimate.duration = 3
b.heroes.hero_ignus.ultimate.min_targets = 2
b.heroes.hero_ignus.ultimate.detection_range = 80
b.heroes.hero_ignus.ultimate.damage_radius = 80
b.heroes.hero_ignus.ultimate.min_range = 20
b.heroes.hero_ignus.ultimate.damage_min = 20
b.heroes.hero_ignus.ultimate.damage_max = 30
b.heroes.hero_ignus.ultimate.s_damage_min = 240
b.heroes.hero_ignus.ultimate.s_damage_max = 360
b.heroes.hero_ignus.ultimate.damage_type = DAMAGE_TRUE
b.heroes.hero_ignus.ultimate.cycle_time = 0.25
b.heroes.hero_ignus.ultimate.movement_speed = 0.21
b.heroes.hero_ignus.talent_1 = {}
b.heroes.hero_ignus.talent_1.damage_radius = 50
b.heroes.hero_ignus.talent_1.damage_min = 2
b.heroes.hero_ignus.talent_1.damage_max = 2
b.heroes.hero_ignus.talent_1.s_total_damage = 8
b.heroes.hero_ignus.talent_1.damage_type = DAMAGE_TRUE
b.heroes.hero_ignus.talent_1.cycle_time = 0.25
b.heroes.hero_ignus.talent_2 = {}
b.heroes.hero_ignus.talent_2.heal_ptg = 0.15
b.heroes.hero_ignus.upgrades = {}
b.heroes.hero_ignus.upgrades.upg_sa1 = {}
b.heroes.hero_ignus.upgrades.upg_sa1.damage_min = 64
b.heroes.hero_ignus.upgrades.upg_sa1.damage_max = 96
b.heroes.hero_ignus.upgrades.upg_sa2 = {}
b.heroes.hero_ignus.upgrades.upg_sa2.damage_min = 100
b.heroes.hero_ignus.upgrades.upg_sa2.damage_max = 150
b.heroes.hero_ignus.upgrades.upg_sb1 = {}
b.heroes.hero_ignus.upgrades.upg_sb1.damage_min = 64
b.heroes.hero_ignus.upgrades.upg_sb1.damage_max = 120
b.heroes.hero_ignus.upgrades.upg_sb2 = {}
b.heroes.hero_ignus.upgrades.upg_sb2.damage_min = 88
b.heroes.hero_ignus.upgrades.upg_sb2.damage_max = 165
b.heroes.hero_ignus.upgrades.upg_sc1 = {}
b.heroes.hero_ignus.upgrades.upg_sc1.damage_min = 80
b.heroes.hero_ignus.upgrades.upg_sc1.damage_max = 120
b.heroes.hero_ignus.upgrades.upg_sc2 = {}
b.heroes.hero_ignus.upgrades.upg_sc2.damage_min = 120
b.heroes.hero_ignus.upgrades.upg_sc2.damage_max = 180
b.heroes.hero_ignus.upgrades.upg_a = {}
b.heroes.hero_ignus.upgrades.upg_a.extra_speed_factor = 7.714
b.heroes.hero_ignus.upgrades.upg_a.min_distance = 160
b.heroes.hero_ignus.upgrades.upg_a.slide_distance = 12
b.heroes.hero_ignus.upgrades.upg_b = {}
b.heroes.hero_ignus.upgrades.upg_b.dmg_factor = 1.1
b.heroes.hero_ignus.upgrades.upg_b.s_dmg_factor = sub_one(b.heroes.hero_ignus.upgrades.upg_b.dmg_factor)
b.heroes.hero_ignus.upgrades.upg_c = {}
b.heroes.hero_ignus.upgrades.upg_c.skills_cd_red_factor = 0.1
b.heroes.hero_ignus.upgrades.upg_c.skill_red_factor = b.heroes.hero_ignus.upgrades.upg_c.skills_cd_red_factor
b.heroes.hero_ignus.upgrades.upg_d = {}
b.heroes.hero_ignus.upgrades.upg_d.regen_factor = 1.15
b.heroes.hero_ignus.upgrades.upg_d.s_regen_factor = sub_one(b.heroes.hero_ignus.upgrades.upg_d.regen_factor)
b.heroes.hero_ignus.upgrades.upg_e = {}
b.heroes.hero_ignus.upgrades.upg_e.hp_ptg = 0.1
b.heroes.hero_ignus.upgrades.upg_e.s_hp_ptg = b.heroes.hero_ignus.upgrades.upg_e.hp_ptg
b.heroes.hero_oni = {}
b.heroes.hero_oni.throttled_cooldown = 1
b.heroes.hero_oni.stats = {}
b.heroes.hero_oni.stats.hp = 4
b.heroes.hero_oni.stats.armor = 3.5
b.heroes.hero_oni.stats.damage = 8
b.heroes.hero_oni.stats.cooldown = 3.5
b.heroes.hero_oni.dead_lifetime = 30
b.heroes.hero_oni.speed = 70
b.heroes.hero_oni.regen_cooldown = 1
b.heroes.hero_oni.armor = {
	0.1,
	0.13,
	0.16,
	0.19,
	0.22,
	0.25,
	0.28,
	0.31,
	0.34,
	0.37
}
b.heroes.hero_oni.hp_max = {
	180,
	195,
	210,
	225,
	240,
	255,
	270,
	285,
	300,
	315
}
b.heroes.hero_oni.regen_health = {
	14,
	16,
	17,
	18,
	19,
	20,
	22,
	23,
	24,
	25
}
b.heroes.hero_oni.basic_melee = {}
b.heroes.hero_oni.basic_melee.cooldown = 2
b.heroes.hero_oni.basic_melee.xp_gain_factor = 0.7
b.heroes.hero_oni.basic_melee.damage_min = {
	5,
	7,
	9,
	10,
	12,
	13,
	15,
	17,
	18,
	20
}
b.heroes.hero_oni.basic_melee.damage_max = {
	8,
	11,
	13,
	15,
	18,
	20,
	23,
	25,
	27,
	30
}
b.heroes.hero_oni.basic_melee.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_oni.skill_a = {}
b.heroes.hero_oni.skill_a.cooldown = 24
b.heroes.hero_oni.skill_a.xp_gain = {
	24,
	48,
	72
}
b.heroes.hero_oni.skill_a.damage_min = 95
b.heroes.hero_oni.skill_a.damage_max = 105
b.heroes.hero_oni.skill_a.damage_type = DAMAGE_TRUE
b.heroes.hero_oni.skill_b = {}
b.heroes.hero_oni.skill_b.cooldown = 20
b.heroes.hero_oni.skill_b.xp_gain = {
	20,
	40,
	60
}
b.heroes.hero_oni.skill_b.duration = fts(90)
b.heroes.hero_oni.skill_b.cancel_time_refund = 0.5
b.heroes.hero_oni.skill_b.s_duration = 3
b.heroes.hero_oni.skill_b.trigger_threshold = 0.5
b.heroes.hero_oni.skill_b.heal_ptg = 0.0208
b.heroes.hero_oni.skill_b.s_heal_ptg = 0.25
b.heroes.hero_oni.skill_b.heal_every = 0.25
b.heroes.hero_oni.skill_c = {}
b.heroes.hero_oni.skill_c.cooldown = 18
b.heroes.hero_oni.skill_c.xp_gain = {
	18,
	36,
	54
}
b.heroes.hero_oni.skill_c.min_detection_range = 100
b.heroes.hero_oni.skill_c.detection_range = 250
b.heroes.hero_oni.skill_c.damage_min = {
	40,
	40,
	40
}
b.heroes.hero_oni.skill_c.damage_max = {
	60,
	60,
	60
}
b.heroes.hero_oni.skill_c.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_oni.skill_c.armor_red = 0.05
b.heroes.hero_oni.ultimate = {}
b.heroes.hero_oni.ultimate.cooldown = 38
b.heroes.hero_oni.ultimate.xp_gain = {
	38
}
b.heroes.hero_oni.ultimate.damage_min = 160
b.heroes.hero_oni.ultimate.damage_max = 180
b.heroes.hero_oni.ultimate.damage_radius = 70
b.heroes.hero_oni.ultimate.damage_type = DAMAGE_TRUE
b.heroes.hero_oni.ultimate.min_targets = 2
b.heroes.hero_oni.ultimate.prediction = fts(0)
b.heroes.hero_oni.talent_1 = {}
b.heroes.hero_oni.talent_1.damage_factor = 2
b.heroes.hero_oni.talent_1.s_damage_factor = 1
b.heroes.hero_oni.talent_1.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_oni.talent_2 = {}
b.heroes.hero_oni.talent_2.s_lifesteal = 0.5
b.heroes.hero_oni.talent_2.lifesteal = 0.5
b.heroes.hero_oni.talent_2.block_time = 4
b.heroes.hero_oni.upgrades = {}
b.heroes.hero_oni.upgrades.upg_sa1 = {}
b.heroes.hero_oni.upgrades.upg_sa1.damage_min = 165
b.heroes.hero_oni.upgrades.upg_sa1.damage_max = 175
b.heroes.hero_oni.upgrades.upg_sa2 = {}
b.heroes.hero_oni.upgrades.upg_sa2.damage_min = 235
b.heroes.hero_oni.upgrades.upg_sa2.damage_max = 245
b.heroes.hero_oni.upgrades.upg_sb1 = {}
b.heroes.hero_oni.upgrades.upg_sb1.heal_ptg = 0.0333
b.heroes.hero_oni.upgrades.upg_sb1.s_heal_ptg = 0.4
b.heroes.hero_oni.upgrades.upg_sb2 = {}
b.heroes.hero_oni.upgrades.upg_sb2.heal_ptg = 0.0458
b.heroes.hero_oni.upgrades.upg_sb2.s_heal_ptg = 0.55
b.heroes.hero_oni.upgrades.upg_sc1 = {}
b.heroes.hero_oni.upgrades.upg_sc1.damage_min = {
	52,
	52,
	52
}
b.heroes.hero_oni.upgrades.upg_sc1.damage_max = {
	78,
	78,
	78
}
b.heroes.hero_oni.upgrades.upg_sc1.armor_red = 0.07
b.heroes.hero_oni.upgrades.upg_sc2 = {}
b.heroes.hero_oni.upgrades.upg_sc2.damage_min = {
	64,
	64,
	64
}
b.heroes.hero_oni.upgrades.upg_sc2.damage_max = {
	96,
	96,
	96
}
b.heroes.hero_oni.upgrades.upg_sc2.armor_red = 0.1
b.heroes.hero_oni.upgrades.upg_a = {}
b.heroes.hero_oni.upgrades.upg_a.skills_cd_red_factor = 0.1
b.heroes.hero_oni.upgrades.upg_a.skill_red_factor = b.heroes.hero_oni.upgrades.upg_a.skills_cd_red_factor
b.heroes.hero_oni.upgrades.upg_a.s_skill_red_factor = b.heroes.hero_oni.upgrades.upg_a.skill_red_factor
b.heroes.hero_oni.upgrades.upg_b = {}
b.heroes.hero_oni.upgrades.upg_b.hp_ptg = 0.1
b.heroes.hero_oni.upgrades.upg_b.s_hp_ptg = b.heroes.hero_oni.upgrades.upg_b.hp_ptg
b.heroes.hero_oni.upgrades.upg_c = {}
b.heroes.hero_oni.upgrades.upg_c.armor_inc = 0.15
b.heroes.hero_oni.upgrades.upg_d = {}
b.heroes.hero_oni.upgrades.upg_d.attack_cooldown = 1.8
b.heroes.hero_oni.upgrades.upg_d.s_attack_cooldown = 0.1
b.heroes.hero_oni.upgrades.upg_e = {}
b.heroes.hero_oni.upgrades.upg_e.damage_factor = 1.12
b.heroes.hero_oni.upgrades.upg_e.s_dmg_factor = sub_one(b.heroes.hero_oni.upgrades.upg_e.damage_factor)
b.heroes.hero_illiana = {}
b.heroes.hero_illiana.stats = {}
b.heroes.hero_illiana.stats.hp = 1
b.heroes.hero_illiana.stats.armor = 0
b.heroes.hero_illiana.stats.damage = 6
b.heroes.hero_illiana.stats.cooldown = 7.5
b.heroes.hero_illiana.dead_lifetime = 30
b.heroes.hero_illiana.speed = 70
b.heroes.hero_illiana.regen_cooldown = 1
b.heroes.hero_illiana.armor = {
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
b.heroes.hero_illiana.hp_max = {
	140,
	150,
	160,
	170,
	180,
	190,
	200,
	210,
	220,
	230
}
b.heroes.hero_illiana.regen_health = {
	11,
	12,
	13,
	14,
	15,
	16,
	17,
	18,
	19,
	20
}
b.heroes.hero_illiana.basic_melee = {}
b.heroes.hero_illiana.basic_melee.cooldown = 1
b.heroes.hero_illiana.basic_melee.xp_gain_factor = 0.75
b.heroes.hero_illiana.basic_melee.damage_min = {
	4,
	4,
	5,
	5,
	6,
	7,
	8,
	8,
	9,
	10
}
b.heroes.hero_illiana.basic_melee.damage_max = {
	7,
	8,
	9,
	10,
	11,
	12,
	13,
	14,
	15,
	16
}
b.heroes.hero_illiana.basic_melee.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_illiana.basic_ranged = {}
b.heroes.hero_illiana.basic_ranged.cooldown = 1
b.heroes.hero_illiana.basic_ranged.xp_gain_factor = 0.75
b.heroes.hero_illiana.basic_ranged.max_range = 165
b.heroes.hero_illiana.basic_ranged.min_range = 70
b.heroes.hero_illiana.basic_ranged.damage_min = {
	4,
	7,
	8,
	9,
	10,
	12,
	13,
	14,
	15,
	16
}
b.heroes.hero_illiana.basic_ranged.damage_max = {
	10,
	13,
	15,
	17,
	20,
	22,
	24,
	26,
	29,
	31
}
b.heroes.hero_illiana.basic_ranged.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_illiana.dragon = {}
b.heroes.hero_illiana.dragon.basic_ranged = {}
b.heroes.hero_illiana.dragon.basic_ranged.damage_min = {
	4,
	5,
	5,
	6,
	7,
	8,
	9,
	10,
	11,
	12
}
b.heroes.hero_illiana.dragon.basic_ranged.damage_max = {
	7,
	8,
	9,
	11,
	12,
	14,
	15,
	17,
	18,
	20
}
b.heroes.hero_illiana.dragon.basic_ranged.damage_type = DAMAGE_MAGICAL
b.heroes.hero_illiana.dragon.basic_ranged.max_range = 165
b.heroes.hero_illiana.dragon.basic_ranged.cooldown = 1
b.heroes.hero_illiana.transfer = {}
b.heroes.hero_illiana.transfer.min_distance = 160
b.heroes.hero_illiana.transfer.extra_speed = 25
b.heroes.hero_illiana.skill_a = {}
b.heroes.hero_illiana.skill_a.cooldown = 12
b.heroes.hero_illiana.skill_a.xp_gain = {
	12,
	24,
	36
}
b.heroes.hero_illiana.skill_a.damage_min = 20
b.heroes.hero_illiana.skill_a.damage_max = 40
b.heroes.hero_illiana.skill_a.damage_type = DAMAGE_TRUE
b.heroes.hero_illiana.skill_a.max_range = 165
b.heroes.hero_illiana.skill_a.max_bounces = 2
b.heroes.hero_illiana.skill_a.bounce_range = 75
b.heroes.hero_illiana.skill_a.min_targets = 3
b.heroes.hero_illiana.skill_a.tag_duration = 4
b.heroes.hero_illiana.skill_a.basic_range = 165
b.heroes.hero_illiana.skill_a.armor_red = 0.25
b.heroes.hero_illiana.skill_a.magic_armor_red = 0
b.heroes.hero_illiana.skill_b = {}
b.heroes.hero_illiana.skill_b.cooldown = 15
b.heroes.hero_illiana.skill_b.xp_gain = {
	15,
	30,
	45
}
b.heroes.hero_illiana.skill_b.min_targets = 3
b.heroes.hero_illiana.skill_b.detection_radius = 165
b.heroes.hero_illiana.skill_b.stun_radius = 100
b.heroes.hero_illiana.skill_b.stun_duration = 2
b.heroes.hero_illiana.skill_c = {}
b.heroes.hero_illiana.skill_c.cooldown = 1
b.heroes.hero_illiana.skill_c.xp_gain = {
	8,
	16,
	24
}
b.heroes.hero_illiana.skill_c.damage_min = 42
b.heroes.hero_illiana.skill_c.damage_max = 58
b.heroes.hero_illiana.skill_c.damage_type = DAMAGE_PHYSICAL
b.heroes.hero_illiana.skill_c.detection_range = 165
b.heroes.hero_illiana.ultimate = {}
b.heroes.hero_illiana.ultimate.cooldown = 35
b.heroes.hero_illiana.ultimate.xp_gain = {
	35
}
b.heroes.hero_illiana.ultimate.detection_range = 200
b.heroes.hero_illiana.ultimate.min_targets = 3
b.heroes.hero_illiana.ultimate.distance = 50
b.heroes.hero_illiana.ultimate.distance_between_nodes = 4
b.heroes.hero_illiana.ultimate.random_for_node = 4
b.heroes.hero_illiana.ultimate.fire_stream = {}
b.heroes.hero_illiana.ultimate.fire_stream.damage_min = 55
b.heroes.hero_illiana.ultimate.fire_stream.damage_max = 85
b.heroes.hero_illiana.ultimate.fire_stream.damage_type = DAMAGE_TRUE
b.heroes.hero_illiana.ultimate.fire_stream.cycle_time = 0.25
b.heroes.hero_illiana.ultimate.fire_stream.damage_radius = 60
b.heroes.hero_illiana.ultimate.fire_decal = {}
b.heroes.hero_illiana.ultimate.fire_decal.damage_min = 3
b.heroes.hero_illiana.ultimate.fire_decal.damage_max = 5
b.heroes.hero_illiana.ultimate.fire_decal.s_damage_min = 12
b.heroes.hero_illiana.ultimate.fire_decal.s_damage_max = 20
b.heroes.hero_illiana.ultimate.fire_decal.damage_type = DAMAGE_TRUE
b.heroes.hero_illiana.ultimate.fire_decal.duration = 3
b.heroes.hero_illiana.ultimate.fire_decal.cycle_time = 0.25
b.heroes.hero_illiana.ultimate.fire_decal.damage_radius = 50
b.heroes.hero_illiana.talent_1 = {}
b.heroes.hero_illiana.talent_1.dodge_chance = 0.4
b.heroes.hero_illiana.talent_2 = {}
b.heroes.hero_illiana.talent_2.damage_factor = 2
b.heroes.hero_illiana.talent_2.s_damage_factor = sub_one(b.heroes.hero_illiana.talent_2.damage_factor)
b.heroes.hero_illiana.upgrades = {}
b.heroes.hero_illiana.upgrades.upg_sa1 = {}
b.heroes.hero_illiana.upgrades.upg_sa1.damage_min = 45
b.heroes.hero_illiana.upgrades.upg_sa1.damage_max = 70
b.heroes.hero_illiana.upgrades.upg_sa2 = {}
b.heroes.hero_illiana.upgrades.upg_sa2.damage_min = 75
b.heroes.hero_illiana.upgrades.upg_sa2.damage_max = 105
b.heroes.hero_illiana.upgrades.upg_sb1 = {}
b.heroes.hero_illiana.upgrades.upg_sb1.stun_duration = 4
b.heroes.hero_illiana.upgrades.upg_sb2 = {}
b.heroes.hero_illiana.upgrades.upg_sb2.stun_duration = 6
b.heroes.hero_illiana.upgrades.upg_sc1 = {}
b.heroes.hero_illiana.upgrades.upg_sc1.damage_min = 62
b.heroes.hero_illiana.upgrades.upg_sc1.damage_max = 88
b.heroes.hero_illiana.upgrades.upg_sc2 = {}
b.heroes.hero_illiana.upgrades.upg_sc2.damage_min = 92
b.heroes.hero_illiana.upgrades.upg_sc2.damage_max = 134
b.heroes.hero_illiana.upgrades.upg_a = {}
b.heroes.hero_illiana.upgrades.upg_a.range_inc_factor = 1.1
b.heroes.hero_illiana.upgrades.upg_a.s_range_factor = sub_one(b.heroes.hero_illiana.upgrades.upg_a.range_inc_factor)
b.heroes.hero_illiana.upgrades.upg_b = {}
b.heroes.hero_illiana.upgrades.upg_b.hp_ptg = 0.2
b.heroes.hero_illiana.upgrades.upg_b.s_hp_ptg = b.heroes.hero_illiana.upgrades.upg_b.hp_ptg
b.heroes.hero_illiana.upgrades.upg_c = {}
b.heroes.hero_illiana.upgrades.upg_c.skills_cd_red_factor = 0.1
b.heroes.hero_illiana.upgrades.upg_c.skill_red_factor = b.heroes.hero_illiana.upgrades.upg_c.skills_cd_red_factor
b.heroes.hero_illiana.upgrades.upg_d = {}
b.heroes.hero_illiana.upgrades.upg_d.dmg_factor = 1.1
b.heroes.hero_illiana.upgrades.upg_d.s_dmg_factor = sub_one(b.heroes.hero_illiana.upgrades.upg_d.dmg_factor)
b.heroes.hero_illiana.upgrades.upg_e = {}
b.heroes.hero_illiana.upgrades.upg_e.dmg_factor = 1.15
b.heroes.hero_illiana.upgrades.upg_e.s_dmg_factor = sub_one(b.heroes.hero_illiana.upgrades.upg_e.dmg_factor)
b.enemies = {}
b.enemies.shadow_order = {}
b.enemies.shadow_order.bandit = {}
b.enemies.shadow_order.bandit.gold = 5
b.enemies.shadow_order.bandit.hp = {
	40,
	40,
	50,
	100
}
b.enemies.shadow_order.bandit.armor = 0
b.enemies.shadow_order.bandit.magic_armor = 0
b.enemies.shadow_order.bandit.speed = 40
b.enemies.shadow_order.bandit.basic_attack = {}
b.enemies.shadow_order.bandit.basic_attack.cooldown = 1
b.enemies.shadow_order.bandit.basic_attack.damage_min = 1
b.enemies.shadow_order.bandit.basic_attack.damage_max = 2
b.enemies.shadow_order.bandit.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.shadow_order.demon_spawn = {}
b.enemies.shadow_order.demon_spawn.gold = 6
b.enemies.shadow_order.demon_spawn.hp = {
	210,
	240,
	300,
	330
}
b.enemies.shadow_order.demon_spawn.armor = 0
b.enemies.shadow_order.demon_spawn.magic_armor = 0.4
b.enemies.shadow_order.demon_spawn.speed = 40
b.enemies.shadow_order.demon_spawn.basic_attack = {}
b.enemies.shadow_order.demon_spawn.basic_attack.cooldown = 1.2
b.enemies.shadow_order.demon_spawn.basic_attack.damage_min = 6
b.enemies.shadow_order.demon_spawn.basic_attack.damage_max = 10
b.enemies.shadow_order.demon_spawn.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.shadow_order.demon_spawn.death_explosion = {}
b.enemies.shadow_order.demon_spawn.death_explosion.damage_min = 20
b.enemies.shadow_order.demon_spawn.death_explosion.damage_max = 25
b.enemies.shadow_order.demon_spawn.death_explosion.damage_radius = 45
b.enemies.shadow_order.demon_spawn.death_explosion.damage_type = DAMAGE_EXPLOSION
b.enemies.shadow_order.demon_flareon = {}
b.enemies.shadow_order.demon_flareon.gold = 8
b.enemies.shadow_order.demon_flareon.hp = {
	230,
	280,
	330,
	360
}
b.enemies.shadow_order.demon_flareon.armor = 0
b.enemies.shadow_order.demon_flareon.magic_armor = 0.4
b.enemies.shadow_order.demon_flareon.speed = 40
b.enemies.shadow_order.demon_flareon.basic_attack = {}
b.enemies.shadow_order.demon_flareon.basic_attack.cooldown = 1.3
b.enemies.shadow_order.demon_flareon.basic_attack.damage_min = 10
b.enemies.shadow_order.demon_flareon.basic_attack.damage_max = 15
b.enemies.shadow_order.demon_flareon.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.shadow_order.demon_flareon.ranged_attack = {}
b.enemies.shadow_order.demon_flareon.ranged_attack.cooldown = 1.5
b.enemies.shadow_order.demon_flareon.ranged_attack.max_range = 150
b.enemies.shadow_order.demon_flareon.ranged_attack.min_range = 60
b.enemies.shadow_order.demon_flareon.ranged_attack.damage_min = 10
b.enemies.shadow_order.demon_flareon.ranged_attack.damage_max = 16
b.enemies.shadow_order.demon_flareon.ranged_attack.damage_type = DAMAGE_TRUE
b.enemies.shadow_order.demon_flareon.ranged_attack.burn_duration = 3
b.enemies.shadow_order.demon_flareon.ranged_attack.burn_damage_min = 8
b.enemies.shadow_order.demon_flareon.ranged_attack.burn_damage_max = 12
b.enemies.shadow_order.demon_flareon.death_explosion = {}
b.enemies.shadow_order.demon_flareon.death_explosion.damage_min = 30
b.enemies.shadow_order.demon_flareon.death_explosion.damage_max = 40
b.enemies.shadow_order.demon_flareon.death_explosion.damage_radius = 45
b.enemies.shadow_order.demon_flareon.death_explosion.damage_type = DAMAGE_EXPLOSION
b.enemies.shadow_order.blackguard = {}
b.enemies.shadow_order.blackguard.gold = 8
b.enemies.shadow_order.blackguard.hp = {
	70,
	80,
	100,
	200
}
b.enemies.shadow_order.blackguard.armor = 0.3
b.enemies.shadow_order.blackguard.magic_armor = 0
b.enemies.shadow_order.blackguard.speed = 40
b.enemies.shadow_order.blackguard.basic_attack = {}
b.enemies.shadow_order.blackguard.basic_attack.cooldown = 1.25
b.enemies.shadow_order.blackguard.basic_attack.damage_min = 3
b.enemies.shadow_order.blackguard.basic_attack.damage_max = 5
b.enemies.shadow_order.blackguard.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.shadow_order.shadow_blades = {}
b.enemies.shadow_order.shadow_blades.gold = 10
b.enemies.shadow_order.shadow_blades.hp = {
	60,
	70,
	80,
	160
}
b.enemies.shadow_order.shadow_blades.armor = 0
b.enemies.shadow_order.shadow_blades.magic_armor = 0
b.enemies.shadow_order.shadow_blades.speed = 64
b.enemies.shadow_order.shadow_blades.basic_attack = {}
b.enemies.shadow_order.shadow_blades.basic_attack.cooldown = 0.8
b.enemies.shadow_order.shadow_blades.basic_attack.damage_min = 7
b.enemies.shadow_order.shadow_blades.basic_attack.damage_max = 11
b.enemies.shadow_order.shadow_blades.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.shadow_order.shadow_blades.smokebomb = {}
b.enemies.shadow_order.shadow_blades.smokebomb.radius = 60
b.enemies.shadow_order.shadow_blades.smokebomb.duration = {
	3,
	3,
	3,
	5
}
b.enemies.shadow_order.shadow_blades.smokebomb.min_nodes_to_exit = 35
b.enemies.shadow_order.shadow_blades.smokebomb.hp_threshold = 0.2
b.enemies.shadow_order.shadow_archer = {}
b.enemies.shadow_order.shadow_archer.gold = 15
b.enemies.shadow_order.shadow_archer.hp = {
	100,
	110,
	140,
	280
}
b.enemies.shadow_order.shadow_archer.armor = 0
b.enemies.shadow_order.shadow_archer.magic_armor = 0.3
b.enemies.shadow_order.shadow_archer.speed = 40
b.enemies.shadow_order.shadow_archer.basic_attack = {}
b.enemies.shadow_order.shadow_archer.basic_attack.cooldown = 1.5
b.enemies.shadow_order.shadow_archer.basic_attack.damage_min = 3
b.enemies.shadow_order.shadow_archer.basic_attack.damage_max = 4
b.enemies.shadow_order.shadow_archer.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.shadow_order.shadow_archer.ranged_attack = {}
b.enemies.shadow_order.shadow_archer.ranged_attack.cooldown = 1.5
b.enemies.shadow_order.shadow_archer.ranged_attack.max_range = 150
b.enemies.shadow_order.shadow_archer.ranged_attack.min_range = 60
b.enemies.shadow_order.shadow_archer.ranged_attack.damage_min = 10
b.enemies.shadow_order.shadow_archer.ranged_attack.damage_max = 16
b.enemies.shadow_order.shadow_archer.ranged_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.shadow_order.crow = {}
b.enemies.shadow_order.crow.gold = 2
b.enemies.shadow_order.crow.hp = {
	20,
	20,
	25,
	40
}
b.enemies.shadow_order.crow.armor = 0
b.enemies.shadow_order.crow.magic_armor = 0
b.enemies.shadow_order.crow.speed = 64
b.enemies.shadow_order.crowcaller = {}
b.enemies.shadow_order.crowcaller.gold = 40
b.enemies.shadow_order.crowcaller.hp = {
	250,
	300,
	350,
	750
}
b.enemies.shadow_order.crowcaller.armor = 0
b.enemies.shadow_order.crowcaller.magic_armor = 0.6
b.enemies.shadow_order.crowcaller.speed = 32
b.enemies.shadow_order.crowcaller.basic_attack = {}
b.enemies.shadow_order.crowcaller.basic_attack.cooldown = 1
b.enemies.shadow_order.crowcaller.basic_attack.damage_min = 8
b.enemies.shadow_order.crowcaller.basic_attack.damage_max = 12
b.enemies.shadow_order.crowcaller.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.shadow_order.crowcaller.crowcall = {}
b.enemies.shadow_order.crowcaller.crowcall.cooldown = 6
b.enemies.shadow_order.crowcaller.crowcall.spawn_count = {
	1,
	1,
	1,
	2
}
b.enemies.shadow_order.crowcaller.crowcall.max_crows = 10
b.enemies.shadow_order.crowcaller.crowcall.node_limit = 60
b.enemies.shadow_order.headhunter = {}
b.enemies.shadow_order.headhunter.gold = 80
b.enemies.shadow_order.headhunter.hp = {
	650,
	800,
	900,
	1800
}
b.enemies.shadow_order.headhunter.armor = 0.5
b.enemies.shadow_order.headhunter.magic_armor = 0
b.enemies.shadow_order.headhunter.speed = 24
b.enemies.shadow_order.headhunter.lives_cost = 2
b.enemies.shadow_order.headhunter.basic_attack = {}
b.enemies.shadow_order.headhunter.basic_attack.cooldown = 1.5
b.enemies.shadow_order.headhunter.basic_attack.damage_min = 24
b.enemies.shadow_order.headhunter.basic_attack.damage_max = 36
b.enemies.shadow_order.headhunter.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.shadow_order.headhunter.instakill = {}
b.enemies.shadow_order.headhunter.instakill.hp_threshold = {
	0.25,
	0.25,
	0.25,
	0.4
}
b.enemies.shadow_order.headhunter.instakill.cooldown = 6
b.enemies.shadow_order.headhunter.instakill.chance = 1
b.enemies.orcs = {}
b.enemies.orcs.goblin = {}
b.enemies.orcs.goblin.gold = 3
b.enemies.orcs.goblin.hp = {
	20,
	20,
	30,
	75
}
b.enemies.orcs.goblin.armor = 0
b.enemies.orcs.goblin.magic_armor = 0
b.enemies.orcs.goblin.speed = 50
b.enemies.orcs.goblin.basic_attack = {}
b.enemies.orcs.goblin.basic_attack.cooldown = 1
b.enemies.orcs.goblin.basic_attack.damage_min = 2
b.enemies.orcs.goblin.basic_attack.damage_max = 3
b.enemies.orcs.goblin.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.orcs.orc_warrior = {}
b.enemies.orcs.orc_warrior.gold = 15
b.enemies.orcs.orc_warrior.hp = {
	160,
	180,
	200,
	400
}
b.enemies.orcs.orc_warrior.armor = 0.3
b.enemies.orcs.orc_warrior.magic_armor = 0
b.enemies.orcs.orc_warrior.speed = 32
b.enemies.orcs.orc_warrior.basic_attack = {}
b.enemies.orcs.orc_warrior.basic_attack.cooldown = 1.5
b.enemies.orcs.orc_warrior.basic_attack.damage_min = 9
b.enemies.orcs.orc_warrior.basic_attack.damage_max = 14
b.enemies.orcs.orc_warrior.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.orcs.orc_warrior.rage = {}
b.enemies.orcs.orc_warrior.rage.radius = 60
b.enemies.orcs.orc_warrior.rage.duration = 6
b.enemies.orcs.orc_warrior.rage.damage_factor = 2
b.enemies.orcs.orc_shaman = {}
b.enemies.orcs.orc_shaman.gold = 12
b.enemies.orcs.orc_shaman.hp = {
	80,
	100,
	120,
	250
}
b.enemies.orcs.orc_shaman.armor = 0
b.enemies.orcs.orc_shaman.magic_armor = 0.8
b.enemies.orcs.orc_shaman.speed = 32
b.enemies.orcs.orc_shaman.basic_attack = {}
b.enemies.orcs.orc_shaman.basic_attack.cooldown = 1.25
b.enemies.orcs.orc_shaman.basic_attack.damage_min = 4
b.enemies.orcs.orc_shaman.basic_attack.damage_max = 6
b.enemies.orcs.orc_shaman.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.orcs.orc_shaman.ranged_attack = {}
b.enemies.orcs.orc_shaman.ranged_attack.cooldown = 1.25
b.enemies.orcs.orc_shaman.ranged_attack.min_range = 60
b.enemies.orcs.orc_shaman.ranged_attack.max_range = 120
b.enemies.orcs.orc_shaman.ranged_attack.damage_min = 4
b.enemies.orcs.orc_shaman.ranged_attack.damage_max = 6
b.enemies.orcs.orc_shaman.ranged_attack.damage_type = DAMAGE_MAGICAL
b.enemies.orcs.orc_shaman.heal = {}
b.enemies.orcs.orc_shaman.heal.cooldown = 8
b.enemies.orcs.orc_shaman.heal.range = 100
b.enemies.orcs.orc_shaman.heal.duration = 1
b.enemies.orcs.orc_shaman.heal.heal_per_second_min = {
	60,
	60,
	60,
	135
}
b.enemies.orcs.orc_shaman.heal.heal_per_second_max = {
	80,
	80,
	80,
	180
}
b.enemies.orcs.orc_shaman.heal.min_targets = 2
b.enemies.orcs.orc_shaman.heal.max_target_hp = 0.7
b.enemies.orcs.wulf = {}
b.enemies.orcs.wulf.gold = 4
b.enemies.orcs.wulf.hp = {
	35,
	40,
	40,
	80
}
b.enemies.orcs.wulf.armor = 0
b.enemies.orcs.wulf.magic_armor = 0
b.enemies.orcs.wulf.speed = 90
b.enemies.orcs.wulf.basic_attack = {}
b.enemies.orcs.wulf.basic_attack.cooldown = 0.8
b.enemies.orcs.wulf.basic_attack.damage_min = 2
b.enemies.orcs.wulf.basic_attack.damage_max = 3
b.enemies.orcs.wulf.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.orcs.wulf.dodge_chance = {
	0.3,
	0.3,
	0.3,
	0.5
}
b.enemies.orcs.orc_wildling = {}
b.enemies.orcs.orc_wildling.gold = 20
b.enemies.orcs.orc_wildling.hp = {
	240,
	280,
	320,
	640
}
b.enemies.orcs.orc_wildling.armor = 0.6
b.enemies.orcs.orc_wildling.magic_armor = 0
b.enemies.orcs.orc_wildling.speed = 32
b.enemies.orcs.orc_wildling.basic_attack = {}
b.enemies.orcs.orc_wildling.basic_attack.cooldown = 1
b.enemies.orcs.orc_wildling.basic_attack.damage_min = 6
b.enemies.orcs.orc_wildling.basic_attack.damage_max = 10
b.enemies.orcs.orc_wildling.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.orcs.orc_wildling.worg_mode = {}
b.enemies.orcs.orc_wildling.worg_mode.speed_mult = {
	2,
	2,
	2,
	2.1875
}
b.enemies.orcs.orc_wildling.worg_mode.range = 100
b.enemies.orcs.worg = {}
b.enemies.orcs.worg.gold = 10
b.enemies.orcs.worg.hp = {
	100,
	120,
	140,
	280
}
b.enemies.orcs.worg.armor = 0
b.enemies.orcs.worg.magic_armor = 0.5
b.enemies.orcs.worg.speed = 64
b.enemies.orcs.worg.basic_attack = {}
b.enemies.orcs.worg.basic_attack.cooldown = 1.25
b.enemies.orcs.worg.basic_attack.damage_min = 10
b.enemies.orcs.worg.basic_attack.damage_max = 15
b.enemies.orcs.worg.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.orcs.worg.dodge_chance = {
	0.3,
	0.3,
	0.3,
	0.5
}
b.enemies.orcs.rider_goblin = {}
b.enemies.orcs.rider_goblin.gold = 10
b.enemies.orcs.rider_goblin.hp = {
	120,
	140,
	160,
	320
}
b.enemies.orcs.rider_goblin.armor = 0
b.enemies.orcs.rider_goblin.magic_armor = 0.5
b.enemies.orcs.rider_goblin.speed = 64
b.enemies.orcs.rider_goblin.basic_attack = {}
b.enemies.orcs.rider_goblin.basic_attack.cooldown = 1.25
b.enemies.orcs.rider_goblin.basic_attack.damage_min = 10
b.enemies.orcs.rider_goblin.basic_attack.damage_max = 15
b.enemies.orcs.rider_goblin.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.orcs.rider_goblin.spawn = {}
b.enemies.orcs.rider_goblin.spawn.max_nodes_to_exit = 70
b.enemies.orcs.rider_goblin.spawn.min_nodes_ahead = 15
b.enemies.orcs.rider_goblin.spawn.max_nodes_ahead = 25
b.enemies.orcs.ogre = {}
b.enemies.orcs.ogre.gold = 120
b.enemies.orcs.ogre.hp = {
	1100,
	1300,
	1600,
	2800
}
b.enemies.orcs.ogre.armor = 0
b.enemies.orcs.ogre.magic_armor = 0
b.enemies.orcs.ogre.speed = 24
b.enemies.orcs.ogre.lives_cost = 2
b.enemies.orcs.ogre.basic_attack = {}
b.enemies.orcs.ogre.basic_attack.cooldown = 2
b.enemies.orcs.ogre.basic_attack.damage_min = {
	38,
	38,
	38,
	64
}
b.enemies.orcs.ogre.basic_attack.damage_max = {
	58,
	58,
	58,
	104
}
b.enemies.orcs.ogre.basic_attack.damage_radius = 25
b.enemies.orcs.ogre.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.orcs.boss = {}
b.enemies.orcs.boss.hp = {
	5600,
	7200,
	8000,
	13000
}
b.enemies.orcs.boss.armor = 0
b.enemies.orcs.boss.magic_armor = 0
b.enemies.orcs.boss.speed_cart = 16
b.enemies.orcs.boss.speed_cart_rage = 100
b.enemies.orcs.boss.rage_hp = 0.7
b.enemies.orcs.boss.nodes_to_enrage = 30
b.enemies.orcs.boss.nodes_knockback = 30
b.enemies.orcs.boss.speed = 16
b.enemies.orcs.boss.basic_attack = {}
b.enemies.orcs.boss.basic_attack.cooldown = 1
b.enemies.orcs.boss.basic_attack.damage_min = 120
b.enemies.orcs.boss.basic_attack.damage_max = 160
b.enemies.orcs.boss.basic_attack.damage_radius = 75
b.enemies.orcs.boss.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.orcs.boss.shout = {}
b.enemies.orcs.boss.shout.cooldown = 15
b.enemies.orcs.boss.shout.radius = 1200
b.enemies.orcs.boss.shout.min_targets = 3
b.enemies.orcs.boss.shout.damage_factor = 2
b.enemies.orcs.boss.shout.speed_mult = 1.25
b.enemies.orcs.boss.shout.buff_duration = 5
b.enemies.orcs.boss.shout.stun_duration = 2
b.enemies.deep_trolls = {}
b.enemies.deep_trolls.troll_warrior = {}
b.enemies.deep_trolls.troll_warrior.gold = 8
b.enemies.deep_trolls.troll_warrior.hp = {
	90,
	100,
	120,
	180
}
b.enemies.deep_trolls.troll_warrior.armor = 0
b.enemies.deep_trolls.troll_warrior.magic_armor = 0
b.enemies.deep_trolls.troll_warrior.speed = 40
b.enemies.deep_trolls.troll_warrior.lives_cost = 1
b.enemies.deep_trolls.troll_warrior.basic_attack = {}
b.enemies.deep_trolls.troll_warrior.basic_attack.cooldown = 1
b.enemies.deep_trolls.troll_warrior.basic_attack.damage_min = 6
b.enemies.deep_trolls.troll_warrior.basic_attack.damage_max = 9
b.enemies.deep_trolls.troll_warrior.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.deep_trolls.troll_warrior.regeneration = {}
b.enemies.deep_trolls.troll_warrior.regeneration.cooldown = fts(15)
b.enemies.deep_trolls.troll_warrior.regeneration.health = 3
b.enemies.deep_trolls.troll_champion = {}
b.enemies.deep_trolls.troll_champion.gold = 30
b.enemies.deep_trolls.troll_champion.hp = {
	340,
	380,
	450,
	675
}
b.enemies.deep_trolls.troll_champion.armor = 0.3
b.enemies.deep_trolls.troll_champion.magic_armor = 0
b.enemies.deep_trolls.troll_champion.speed = 32
b.enemies.deep_trolls.troll_champion.lives_cost = 1
b.enemies.deep_trolls.troll_champion.basic_attack = {}
b.enemies.deep_trolls.troll_champion.basic_attack.cooldown = 1.5
b.enemies.deep_trolls.troll_champion.basic_attack.damage_min = 15
b.enemies.deep_trolls.troll_champion.basic_attack.damage_max = 24
b.enemies.deep_trolls.troll_champion.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.deep_trolls.troll_champion.ranged_attack = {}
b.enemies.deep_trolls.troll_champion.ranged_attack.cooldown = 8
b.enemies.deep_trolls.troll_champion.ranged_attack.min_range = 30
b.enemies.deep_trolls.troll_champion.ranged_attack.max_range = 100
b.enemies.deep_trolls.troll_champion.ranged_attack.damage_min = 15
b.enemies.deep_trolls.troll_champion.ranged_attack.damage_max = 24
b.enemies.deep_trolls.troll_champion.ranged_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.deep_trolls.troll_champion.regeneration = {}
b.enemies.deep_trolls.troll_champion.regeneration.cooldown = fts(15)
b.enemies.deep_trolls.troll_champion.regeneration.health = 4
b.enemies.deep_trolls.troll_glider = {}
b.enemies.deep_trolls.troll_glider.gold = 4
b.enemies.deep_trolls.troll_glider.hp = {
	60,
	70,
	80,
	90
}
b.enemies.deep_trolls.troll_glider.armor = 0
b.enemies.deep_trolls.troll_glider.magic_armor = 0
b.enemies.deep_trolls.troll_glider.speed = 50
b.enemies.deep_trolls.troll_glider.lives_cost = 1
b.enemies.deep_trolls.troll_glider.regeneration = {}
b.enemies.deep_trolls.troll_glider.regeneration.cooldown = fts(15)
b.enemies.deep_trolls.troll_glider.regeneration.health = 0
b.enemies.deep_trolls.troll_glider.suicide = {}
b.enemies.deep_trolls.troll_glider.suicide.damage_min = 1000
b.enemies.deep_trolls.troll_glider.suicide.damage_max = 1000
b.enemies.deep_trolls.troll_glider.suicide.damage_type = DAMAGE_INSTAKILL
b.enemies.deep_trolls.troll_crusher = {}
b.enemies.deep_trolls.troll_crusher.gold = 130
b.enemies.deep_trolls.troll_crusher.hp = {
	1150,
	1300,
	1600,
	2400
}
b.enemies.deep_trolls.troll_crusher.armor = 0.5
b.enemies.deep_trolls.troll_crusher.magic_armor = 0
b.enemies.deep_trolls.troll_crusher.speed = 24
b.enemies.deep_trolls.troll_crusher.lives_cost = 2
b.enemies.deep_trolls.troll_crusher.basic_attack = {}
b.enemies.deep_trolls.troll_crusher.basic_attack.cooldown = 2
b.enemies.deep_trolls.troll_crusher.basic_attack.damage_min = 40
b.enemies.deep_trolls.troll_crusher.basic_attack.damage_max = 60
b.enemies.deep_trolls.troll_crusher.basic_attack.damage_radius = 50
b.enemies.deep_trolls.troll_crusher.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.deep_trolls.troll_crusher.pound_attack = {}
b.enemies.deep_trolls.troll_crusher.pound_attack.cooldown = {
	30,
	30,
	30,
	20
}
b.enemies.deep_trolls.troll_crusher.pound_attack.damage_min = 40
b.enemies.deep_trolls.troll_crusher.pound_attack.damage_max = 60
b.enemies.deep_trolls.troll_crusher.pound_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.deep_trolls.troll_crusher.pound_attack.damage_radius = 70
b.enemies.deep_trolls.troll_crusher.pound_attack.stun = {}
b.enemies.deep_trolls.troll_crusher.pound_attack.stun.duration = 6
b.enemies.deep_trolls.troll_crusher.pound_attack.stun.range = 150
b.enemies.deep_trolls.troll_crusher.regeneration = {}
b.enemies.deep_trolls.troll_crusher.regeneration.cooldown = fts(15)
b.enemies.deep_trolls.troll_crusher.regeneration.health = 10
b.enemies.deep_trolls.frost_icecaller = {}
b.enemies.deep_trolls.frost_icecaller.gold = 80
b.enemies.deep_trolls.frost_icecaller.hp = {
	700,
	800,
	900,
	1350
}
b.enemies.deep_trolls.frost_icecaller.armor = 0
b.enemies.deep_trolls.frost_icecaller.magic_armor = 0.8
b.enemies.deep_trolls.frost_icecaller.speed = 32
b.enemies.deep_trolls.frost_icecaller.lives_cost = 1
b.enemies.deep_trolls.frost_icecaller.basic_attack = {}
b.enemies.deep_trolls.frost_icecaller.basic_attack.cooldown = 1.5
b.enemies.deep_trolls.frost_icecaller.basic_attack.damage_min = 6
b.enemies.deep_trolls.frost_icecaller.basic_attack.damage_max = 14
b.enemies.deep_trolls.frost_icecaller.basic_attack.damage_radius = 50
b.enemies.deep_trolls.frost_icecaller.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.deep_trolls.frost_icecaller.ranged_attack = {}
b.enemies.deep_trolls.frost_icecaller.ranged_attack.cooldown = 1.5
b.enemies.deep_trolls.frost_icecaller.ranged_attack.min_range = 30
b.enemies.deep_trolls.frost_icecaller.ranged_attack.max_range = 150
b.enemies.deep_trolls.frost_icecaller.ranged_attack.damage_min = 28
b.enemies.deep_trolls.frost_icecaller.ranged_attack.damage_max = 43
b.enemies.deep_trolls.frost_icecaller.ranged_attack.damage_type = DAMAGE_MAGICAL
b.enemies.deep_trolls.frost_icecaller.death_explosion = {}
b.enemies.deep_trolls.frost_icecaller.death_explosion.slow_factor = 0.5
b.enemies.deep_trolls.frost_icecaller.death_explosion.slow_duration = 1
b.enemies.deep_trolls.frost_icecaller.death_explosion.aura_duration = 16
b.enemies.deep_trolls.frost_icecaller.death_explosion.aura_cycle_time = 0.1
b.enemies.deep_trolls.frost_icecaller.death_explosion.range = 55
b.enemies.deep_trolls.frost_icecaller.icicles_attack = {}
b.enemies.deep_trolls.frost_icecaller.icicles_attack.cooldown = {
	15,
	15,
	15,
	10
}
b.enemies.deep_trolls.frost_icecaller.icicles_attack.rows = 4
b.enemies.deep_trolls.frost_icecaller.icicles_attack.row_spread = 5
b.enemies.deep_trolls.frost_icecaller.icicles_attack.row_anticipation = 5
b.enemies.deep_trolls.frost_icecaller.icicles_attack.amount_per_row = 3
b.enemies.deep_trolls.frost_icecaller.icicles_attack.spread = 5
b.enemies.deep_trolls.frost_icecaller.icicles_attack.y_offset = -8
b.enemies.deep_trolls.frost_icecaller.icicles_attack.scale_min = 0.9
b.enemies.deep_trolls.frost_icecaller.icicles_attack.scale_max = 1
b.enemies.deep_trolls.frost_icecaller.icicles_attack.duration = 0.7
b.enemies.deep_trolls.frost_icecaller.icicles_attack.damage_min = 20
b.enemies.deep_trolls.frost_icecaller.icicles_attack.damage_max = 40
b.enemies.deep_trolls.frost_icecaller.icicles_attack.damage_radius = 25
b.enemies.deep_trolls.frost_icecaller.icicles_attack.damage_type = DAMAGE_MAGICAL
b.enemies.deep_trolls.frost_icecaller.icicles_attack.min_range = 50
b.enemies.deep_trolls.frost_icecaller.icicles_attack.range = 150
b.enemies.deep_trolls.troll_pathfinder = {}
b.enemies.deep_trolls.troll_pathfinder.gold = 10
b.enemies.deep_trolls.troll_pathfinder.hp = {
	90,
	100,
	120,
	180
}
b.enemies.deep_trolls.troll_pathfinder.armor = 0.3
b.enemies.deep_trolls.troll_pathfinder.magic_armor = 0
b.enemies.deep_trolls.troll_pathfinder.speed = 50
b.enemies.deep_trolls.troll_pathfinder.slide_speed_factor = 2
b.enemies.deep_trolls.troll_pathfinder.lives_cost = 1
b.enemies.deep_trolls.troll_pathfinder.basic_attack = {}
b.enemies.deep_trolls.troll_pathfinder.basic_attack.cooldown = 1
b.enemies.deep_trolls.troll_pathfinder.basic_attack.damage_min = 6
b.enemies.deep_trolls.troll_pathfinder.basic_attack.damage_max = 9
b.enemies.deep_trolls.troll_pathfinder.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.deep_trolls.troll_pathfinder.regeneration = {}
b.enemies.deep_trolls.troll_pathfinder.regeneration.cooldown = fts(15)
b.enemies.deep_trolls.troll_pathfinder.regeneration.health = 3
b.enemies.deep_trolls.frost_baiter = {}
b.enemies.deep_trolls.frost_baiter.gold = 3
b.enemies.deep_trolls.frost_baiter.hp = {
	30,
	40,
	40,
	50
}
b.enemies.deep_trolls.frost_baiter.armor = 0
b.enemies.deep_trolls.frost_baiter.magic_armor = 0
b.enemies.deep_trolls.frost_baiter.speed = 64
b.enemies.deep_trolls.frost_baiter.ice_speed_factor = 1.33
b.enemies.deep_trolls.frost_baiter.lives_cost = 1
b.enemies.deep_trolls.frost_baiter.basic_attack = {}
b.enemies.deep_trolls.frost_baiter.basic_attack.cooldown = 1
b.enemies.deep_trolls.frost_baiter.basic_attack.damage_min = 3
b.enemies.deep_trolls.frost_baiter.basic_attack.damage_max = 4
b.enemies.deep_trolls.frost_baiter.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.deep_trolls.frost_baiter.bait = {}
b.enemies.deep_trolls.frost_baiter.bait.cooldown = 30
b.enemies.deep_trolls.frost_baiter.bait.min_jump_distance = 20
b.enemies.deep_trolls.frost_baiter.bait.max_jump_distance = 25
b.enemies.deep_trolls.frost_baiter.bait.max_nodes_to_exit = 55
b.enemies.deep_trolls.frost_baiter.decoy = {}
b.enemies.deep_trolls.frost_baiter.decoy.gold = 0
b.enemies.deep_trolls.frost_baiter.decoy.hp = {
	30,
	40,
	40,
	50
}
b.enemies.deep_trolls.frost_baiter.decoy.armor = 0
b.enemies.deep_trolls.frost_baiter.decoy.magic_armor = 0
b.enemies.deep_trolls.frost_baiter.decoy.speed = 0
b.enemies.deep_trolls.frost_baiter.decoy.duration = 4
b.enemies.deep_trolls.frost_baiter.death_stun = {}
b.enemies.deep_trolls.frost_baiter.death_stun.duration = 1
b.enemies.deep_trolls.frost_baiter.death_stun.range = 50
b.enemies.deep_trolls.frost_brute = {}
b.enemies.deep_trolls.frost_brute.gold = 260
b.enemies.deep_trolls.frost_brute.hp = {
	1800,
	2200,
	2500,
	3400
}
b.enemies.deep_trolls.frost_brute.armor = 1
b.enemies.deep_trolls.frost_brute.magic_armor = 0.6
b.enemies.deep_trolls.frost_brute.speed = 24
b.enemies.deep_trolls.frost_brute.lives_cost = 2
b.enemies.deep_trolls.frost_brute.ice_speed_factor = 1.2
b.enemies.deep_trolls.frost_brute.basic_attack = {}
b.enemies.deep_trolls.frost_brute.basic_attack.cooldown = 2
b.enemies.deep_trolls.frost_brute.basic_attack.damage_min = 30
b.enemies.deep_trolls.frost_brute.basic_attack.damage_max = 46
b.enemies.deep_trolls.frost_brute.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.deep_trolls.frost_brute.death_explosion = {}
b.enemies.deep_trolls.frost_brute.death_explosion.slow_factor = 0.5
b.enemies.deep_trolls.frost_brute.death_explosion.slow_duration = 1
b.enemies.deep_trolls.frost_brute.death_explosion.aura_duration = 16
b.enemies.deep_trolls.frost_brute.death_explosion.aura_cycle_time = 0.1
b.enemies.deep_trolls.frost_brute.death_explosion.range = 70
b.enemies.deep_trolls.frost_brute.cold_breath = {}
b.enemies.deep_trolls.frost_brute.cold_breath.cooldown = {
	35,
	35,
	35,
	16
}
b.enemies.deep_trolls.frost_brute.cold_breath.damage_min = 20
b.enemies.deep_trolls.frost_brute.cold_breath.damage_max = 30
b.enemies.deep_trolls.frost_brute.cold_breath.damage_every = 0.5
b.enemies.deep_trolls.frost_brute.cold_breath.damage_type = DAMAGE_PHYSICAL
b.enemies.deep_trolls.frost_brute.cold_breath.min_targets = 1
b.enemies.deep_trolls.frost_brute.cold_breath.trigger_radius = 110
b.enemies.deep_trolls.frost_brute.cold_breath.radius = 110
b.enemies.deep_trolls.frost_brute.cold_breath.freeze_duration = 6
b.enemies.deep_trolls.troll_chieftain = {}
b.enemies.deep_trolls.troll_chieftain.gold = 60
b.enemies.deep_trolls.troll_chieftain.hp = {
	1000,
	1200,
	1500,
	2100
}
b.enemies.deep_trolls.troll_chieftain.armor = 0
b.enemies.deep_trolls.troll_chieftain.magic_armor = 0
b.enemies.deep_trolls.troll_chieftain.speed = 24
b.enemies.deep_trolls.troll_chieftain.lives_cost = 2
b.enemies.deep_trolls.troll_chieftain.basic_attack = {}
b.enemies.deep_trolls.troll_chieftain.basic_attack.cooldown = 2
b.enemies.deep_trolls.troll_chieftain.basic_attack.damage_min = 40
b.enemies.deep_trolls.troll_chieftain.basic_attack.damage_max = 60
b.enemies.deep_trolls.troll_chieftain.basic_attack.damage_radius = 50
b.enemies.deep_trolls.troll_chieftain.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.deep_trolls.troll_chieftain.drums = {}
b.enemies.deep_trolls.troll_chieftain.drums.cooldown = {
	20,
	20,
	20,
	14
}
b.enemies.deep_trolls.troll_chieftain.drums.radius = 100
b.enemies.deep_trolls.troll_chieftain.drums.min_targets = 3
b.enemies.deep_trolls.troll_chieftain.drums.speed_factor = 1.33
b.enemies.deep_trolls.troll_chieftain.drums.dmg_factor = 1.33
b.enemies.deep_trolls.troll_chieftain.drums.duration = 8
b.enemies.deep_trolls.troll_chieftain.regeneration = {}
b.enemies.deep_trolls.troll_chieftain.regeneration.cooldown = fts(15)
b.enemies.deep_trolls.troll_chieftain.regeneration.health = 8
b.enemies.deep_trolls.troll_boss = {}
b.enemies.deep_trolls.troll_boss.hp = {
	9000,
	10500,
	13000,
	17000
}
b.enemies.deep_trolls.troll_boss.armor = 0
b.enemies.deep_trolls.troll_boss.shielded_armor = 0.98
b.enemies.deep_trolls.troll_boss.magic_armor = 0
b.enemies.deep_trolls.troll_boss.shielded_magic_armor = 0.98
b.enemies.deep_trolls.troll_boss.speed = 13
b.enemies.deep_trolls.troll_boss.sunray_stun = 5
b.enemies.deep_trolls.troll_boss.offstage_wait_min = 4
b.enemies.deep_trolls.troll_boss.offstage_wait_max = 6
b.enemies.deep_trolls.troll_boss.turn_off_wave_wait = 0.5
b.enemies.deep_trolls.troll_boss.basic_attack = {}
b.enemies.deep_trolls.troll_boss.basic_attack.cooldown = 1
b.enemies.deep_trolls.troll_boss.basic_attack.damage_min = 150
b.enemies.deep_trolls.troll_boss.basic_attack.damage_max = 250
b.enemies.deep_trolls.troll_boss.basic_attack.damage_radius = 75
b.enemies.deep_trolls.troll_boss.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.deep_trolls.troll_boss.jump_progression = {
	left = {
		8,
		25,
		28,
		31,
		34,
		37
	},
	right = {
		26,
		29,
		32,
		35,
		38,
		38
	}
}
b.enemies.jt_boss = {}
b.enemies.jt_boss.hp = {
	6700,
	8400,
	9500,
	11000
}
b.enemies.jt_boss.armor = 0
b.enemies.jt_boss.magic_armor = 0
b.enemies.jt_boss.speed = 12
b.enemies.jt_boss.basic_attack = {}
b.enemies.jt_boss.basic_attack.cooldown = 1
b.enemies.jt_boss.basic_attack.damage_min = 150
b.enemies.jt_boss.basic_attack.damage_max = 200
b.enemies.jt_boss.basic_attack.damage_radius = 75
b.enemies.jt_boss.basic_attack.damage_type = DAMAGE_EAT
b.enemies.jt_boss.tower_freeze = {}
b.enemies.jt_boss.tower_freeze.cooldown = 20
b.enemies.jt_boss.tower_freeze.tired_time = 3
b.enemies.jt_boss.tower_freeze.range = 400
b.enemies.jt_boss.tower_freeze.duration = 15
b.enemies.jt_boss.tower_freeze.targets = 4
b.enemies.jt_boss.tower_freeze.taps_to_thaw = 5
b.enemies.jt_boss.tower_freeze.random_icicles = 5
b.enemies.jt_boss.tower_freeze.allies_icicles = 2
b.enemies.spiders = {}
b.enemies.spiders.spiderling = {}
b.enemies.spiders.spiderling.gold = 2
b.enemies.spiders.spiderling.hp = {
	15,
	20,
	20,
	30
}
b.enemies.spiders.spiderling.armor = 0
b.enemies.spiders.spiderling.magic_armor = 0.2
b.enemies.spiders.spiderling.speed = 80
b.enemies.spiders.spiderling.lives_cost = 1
b.enemies.spiders.spiderling.basic_attack = {}
b.enemies.spiders.spiderling.basic_attack.cooldown = 0.8
b.enemies.spiders.spiderling.basic_attack.damage_min = 2
b.enemies.spiders.spiderling.basic_attack.damage_max = 3
b.enemies.spiders.spiderling.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.spiders.giant_spider = {}
b.enemies.spiders.giant_spider.gold = 18
b.enemies.spiders.giant_spider.hp = {
	140,
	180,
	200,
	300
}
b.enemies.spiders.giant_spider.armor = 0
b.enemies.spiders.giant_spider.magic_armor = 0.2
b.enemies.spiders.giant_spider.speed = 36
b.enemies.spiders.giant_spider.lives_cost = 1
b.enemies.spiders.giant_spider.basic_attack = {}
b.enemies.spiders.giant_spider.basic_attack.cooldown = 1.5
b.enemies.spiders.giant_spider.basic_attack.damage_min = 14
b.enemies.spiders.giant_spider.basic_attack.damage_max = 21
b.enemies.spiders.giant_spider.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.spiders.spider_matriarch = {}
b.enemies.spiders.spider_matriarch.gold = 100
b.enemies.spiders.spider_matriarch.hp = {
	650,
	750,
	900,
	1350
}
b.enemies.spiders.spider_matriarch.armor = 0
b.enemies.spiders.spider_matriarch.magic_armor = 0.6
b.enemies.spiders.spider_matriarch.speed = 32
b.enemies.spiders.spider_matriarch.lives_cost = 2
b.enemies.spiders.spider_matriarch.basic_attack = {}
b.enemies.spiders.spider_matriarch.basic_attack.cooldown = 1.5
b.enemies.spiders.spider_matriarch.basic_attack.damage_min = 17
b.enemies.spiders.spider_matriarch.basic_attack.damage_max = 26
b.enemies.spiders.spider_matriarch.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.spiders.spider_matriarch.egg_spawn = {}
b.enemies.spiders.spider_matriarch.egg_spawn.max_nodes_to_exit = 30
b.enemies.spiders.spider_matriarch.egg_spawn.cooldown = 6
b.enemies.spiders.spider_matriarch.egg_spawn.max_eggs = 4
b.enemies.spiders.spider_matriarch.egg_spawn.time_to_spawn = 5
b.enemies.spiders.spider_matriarch.egg_spawn.spawn_count = {
	3,
	3,
	3,
	4
}
b.enemies.spiders.leaper_spider = {}
b.enemies.spiders.leaper_spider.gold = 12
b.enemies.spiders.leaper_spider.hp = {
	85,
	100,
	120,
	180
}
b.enemies.spiders.leaper_spider.armor = 0.25
b.enemies.spiders.leaper_spider.magic_armor = 0
b.enemies.spiders.leaper_spider.speed = 40
b.enemies.spiders.leaper_spider.lives_cost = 1
b.enemies.spiders.leaper_spider.basic_attack = {}
b.enemies.spiders.leaper_spider.basic_attack.cooldown = 1
b.enemies.spiders.leaper_spider.basic_attack.damage_min = 14
b.enemies.spiders.leaper_spider.basic_attack.damage_max = 21
b.enemies.spiders.leaper_spider.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.spiders.leaper_spider.leap_attack = {}
b.enemies.spiders.leaper_spider.leap_attack.cooldown = 3
b.enemies.spiders.leaper_spider.leap_attack.min_nodes = 10
b.enemies.spiders.leaper_spider.leap_attack.max_nodes = 20
b.enemies.spiders.leaper_spider.leap_attack.max_nodes_to_exit = 30
b.enemies.spiders.leaper_spider.poison = {}
b.enemies.spiders.leaper_spider.poison.duration = 3
b.enemies.spiders.leaper_spider.poison.cycle_time = 0.25
b.enemies.spiders.leaper_spider.poison.damage = 2
b.enemies.spiders.leaper_spider.poison.damage_type = DAMAGE_TRUE
b.enemies.spiders.son_of_sarelgaz = {}
b.enemies.spiders.son_of_sarelgaz.gold = 80
b.enemies.spiders.son_of_sarelgaz.hp = {
	850,
	1000,
	1200,
	1800
}
b.enemies.spiders.son_of_sarelgaz.armor = 0.4
b.enemies.spiders.son_of_sarelgaz.magic_armor = 0.4
b.enemies.spiders.son_of_sarelgaz.speed = 30
b.enemies.spiders.son_of_sarelgaz.lives_cost = 2
b.enemies.spiders.son_of_sarelgaz.basic_attack = {}
b.enemies.spiders.son_of_sarelgaz.basic_attack.cooldown = 1.5
b.enemies.spiders.son_of_sarelgaz.basic_attack.damage_min = 30
b.enemies.spiders.son_of_sarelgaz.basic_attack.damage_max = 45
b.enemies.spiders.son_of_sarelgaz.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.spiders.son_of_sarelgaz.stun_attack = {}
b.enemies.spiders.son_of_sarelgaz.stun_attack.duration = 3
b.enemies.spiders.son_of_sarelgaz.stun_attack.cooldown = 8
b.enemies.spiders.boss_spider = {}
b.enemies.spiders.boss_spider.hp = {
	7700,
	9000,
	11000,
	12000
}
b.enemies.spiders.boss_spider.armor = 0
b.enemies.spiders.boss_spider.magic_armor = 0.76
b.enemies.spiders.boss_spider.speed = 15
b.enemies.spiders.boss_spider.phases_health_thresholds = {
	0.75,
	0.45
}
b.enemies.spiders.boss_spider.basic_attack = {}
b.enemies.spiders.boss_spider.basic_attack.cooldown = 4
b.enemies.spiders.boss_spider.basic_attack.damage_min = 150
b.enemies.spiders.boss_spider.basic_attack.damage_max = 200
b.enemies.spiders.boss_spider.basic_attack.damage_radius = 45
b.enemies.spiders.boss_spider.basic_attack.damage_type = DAMAGE_EAT
b.enemies.dark_army = {}
b.enemies.dark_army.skeleton = {}
b.enemies.dark_army.skeleton.gold = 2
b.enemies.dark_army.skeleton.hp = {
	70,
	80,
	100,
	125
}
b.enemies.dark_army.skeleton.armor = 0
b.enemies.dark_army.skeleton.magic_armor = 0
b.enemies.dark_army.skeleton.speed = 28
b.enemies.dark_army.skeleton.basic_attack = {}
b.enemies.dark_army.skeleton.basic_attack.cooldown = 1
b.enemies.dark_army.skeleton.basic_attack.damage_min = 4
b.enemies.dark_army.skeleton.basic_attack.damage_max = 7
b.enemies.dark_army.skeleton.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.skeleton_big = {}
b.enemies.dark_army.skeleton_big.gold = 30
b.enemies.dark_army.skeleton_big.hp = {
	480,
	620,
	800,
	1000
}
b.enemies.dark_army.skeleton_big.lives_cost = 2
b.enemies.dark_army.skeleton_big.armor = 0
b.enemies.dark_army.skeleton_big.magic_armor = 0
b.enemies.dark_army.skeleton_big.speed = 24
b.enemies.dark_army.skeleton_big.basic_attack = {}
b.enemies.dark_army.skeleton_big.basic_attack.cooldown = 1.5
b.enemies.dark_army.skeleton_big.basic_attack.damage_min = 30
b.enemies.dark_army.skeleton_big.basic_attack.damage_max = 45
b.enemies.dark_army.skeleton_big.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.skeleton_goat = {}
b.enemies.dark_army.skeleton_goat.gold = 5
b.enemies.dark_army.skeleton_goat.hp = {
	60,
	100,
	100,
	120
}
b.enemies.dark_army.skeleton_goat.lives_cost = 1
b.enemies.dark_army.skeleton_goat.armor = 0
b.enemies.dark_army.skeleton_goat.magic_armor = 0
b.enemies.dark_army.skeleton_goat.speed = 64
b.enemies.dark_army.brigand = {}
b.enemies.dark_army.brigand.gold = 20
b.enemies.dark_army.brigand.hp = {
	250,
	280,
	350,
	450
}
b.enemies.dark_army.brigand.armor = 0.4
b.enemies.dark_army.brigand.magic_armor = 0
b.enemies.dark_army.brigand.speed = 40
b.enemies.dark_army.brigand.basic_attack = {}
b.enemies.dark_army.brigand.basic_attack.cooldown = 1
b.enemies.dark_army.brigand.basic_attack.damage_min = 9
b.enemies.dark_army.brigand.basic_attack.damage_max = 14
b.enemies.dark_army.brigand.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.brigand.bleed_strike = {}
b.enemies.dark_army.brigand.bleed_strike.cooldown = 10
b.enemies.dark_army.brigand.bleed_strike.damage_min = 9
b.enemies.dark_army.brigand.bleed_strike.damage_max = 14
b.enemies.dark_army.brigand.bleed_strike.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.brigand.bleed_strike.bleed = {}
b.enemies.dark_army.brigand.bleed_strike.bleed.duration = 2
b.enemies.dark_army.brigand.bleed_strike.bleed.cycle_time = 0.25
b.enemies.dark_army.brigand.bleed_strike.bleed.damage_min = 3
b.enemies.dark_army.brigand.bleed_strike.bleed.damage_max = 3
b.enemies.dark_army.brigand.bleed_strike.bleed.damage_type = DAMAGE_TRUE
b.enemies.dark_army.rotten_tree = {}
b.enemies.dark_army.rotten_tree.gold = 60
b.enemies.dark_army.rotten_tree.hp = {
	1000,
	1100,
	1200,
	1500
}
b.enemies.dark_army.rotten_tree.armor = 0.5
b.enemies.dark_army.rotten_tree.magic_armor = 0
b.enemies.dark_army.rotten_tree.speed = 18
b.enemies.dark_army.rotten_tree.basic_attack = {}
b.enemies.dark_army.rotten_tree.basic_attack.cooldown = 1.5
b.enemies.dark_army.rotten_tree.basic_attack.damage_min = 30
b.enemies.dark_army.rotten_tree.basic_attack.damage_max = 45
b.enemies.dark_army.rotten_tree.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.dark_sapper = {}
b.enemies.dark_army.dark_sapper.gold = 30
b.enemies.dark_army.dark_sapper.hp = {
	600,
	600,
	720,
	900
}
b.enemies.dark_army.dark_sapper.armor = 0
b.enemies.dark_army.dark_sapper.magic_armor = 0
b.enemies.dark_army.dark_sapper.speed = 24
b.enemies.dark_army.dark_sapper.basic_attack = {}
b.enemies.dark_army.dark_sapper.basic_attack.cooldown = 1
b.enemies.dark_army.dark_sapper.basic_attack.damage_min = 20
b.enemies.dark_army.dark_sapper.basic_attack.damage_max = 30
b.enemies.dark_army.dark_sapper.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.dark_sapper.ranged_attack = {}
b.enemies.dark_army.dark_sapper.ranged_attack.cooldown = 2
b.enemies.dark_army.dark_sapper.ranged_attack.max_range = 170
b.enemies.dark_army.dark_sapper.ranged_attack.min_range = 60
b.enemies.dark_army.dark_sapper.ranged_attack.damage_min = 56
b.enemies.dark_army.dark_sapper.ranged_attack.damage_max = 84
b.enemies.dark_army.dark_sapper.ranged_attack.damage_radius = 70
b.enemies.dark_army.dark_sapper.ranged_attack.damage_type = DAMAGE_EXPLOSION
b.enemies.dark_army.dark_sapper.death_explosion = {}
b.enemies.dark_army.dark_sapper.death_explosion.damage_min = 100
b.enemies.dark_army.dark_sapper.death_explosion.damage_max = 150
b.enemies.dark_army.dark_sapper.death_explosion.damage_radius = 60
b.enemies.dark_army.dark_sapper.death_explosion.damage_type = DAMAGE_EXPLOSION
b.enemies.dark_army.swamp_husk = {}
b.enemies.dark_army.swamp_husk.gold = 4
b.enemies.dark_army.swamp_husk.hp = {
	110,
	130,
	160,
	200
}
b.enemies.dark_army.swamp_husk.armor = 0.3
b.enemies.dark_army.swamp_husk.magic_armor = 0
b.enemies.dark_army.swamp_husk.speed = 24
b.enemies.dark_army.swamp_husk.basic_attack = {}
b.enemies.dark_army.swamp_husk.basic_attack.cooldown = 1.5
b.enemies.dark_army.swamp_husk.basic_attack.damage_min = 5
b.enemies.dark_army.swamp_husk.basic_attack.damage_max = 8
b.enemies.dark_army.swamp_husk.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.swamp_husk.poison = {}
b.enemies.dark_army.swamp_husk.poison.duration = 2
b.enemies.dark_army.swamp_husk.poison.cycle_time = 0.25
b.enemies.dark_army.swamp_husk.poison.damage = 4
b.enemies.dark_army.swamp_husk.poison.damage_type = DAMAGE_TRUE
b.enemies.dark_army.swamp_thing = {}
b.enemies.dark_army.swamp_thing.gold = 120
b.enemies.dark_army.swamp_thing.hp = {
	2000,
	2400,
	2800,
	3500
}
b.enemies.dark_army.swamp_thing.armor = 0
b.enemies.dark_army.swamp_thing.magic_armor = 0
b.enemies.dark_army.swamp_thing.speed = 24
b.enemies.dark_army.swamp_thing.lives_cost = 2
b.enemies.dark_army.swamp_thing.basic_attack = {}
b.enemies.dark_army.swamp_thing.basic_attack.cooldown = 1.8
b.enemies.dark_army.swamp_thing.basic_attack.damage_min = 72
b.enemies.dark_army.swamp_thing.basic_attack.damage_max = 108
b.enemies.dark_army.swamp_thing.basic_attack.damage_radius = 40
b.enemies.dark_army.swamp_thing.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.swamp_thing.regeneration = {}
b.enemies.dark_army.swamp_thing.regeneration.cooldown = fts(10)
b.enemies.dark_army.swamp_thing.regeneration.health = 4
b.enemies.dark_army.exalted_shadow_archer = {}
b.enemies.dark_army.exalted_shadow_archer.gold = 15
b.enemies.dark_army.exalted_shadow_archer.hp = {
	170,
	190,
	240,
	265
}
b.enemies.dark_army.exalted_shadow_archer.armor = 0
b.enemies.dark_army.exalted_shadow_archer.magic_armor = 0.3
b.enemies.dark_army.exalted_shadow_archer.speed = 40
b.enemies.dark_army.exalted_shadow_archer.basic_attack = {}
b.enemies.dark_army.exalted_shadow_archer.basic_attack.cooldown = 1
b.enemies.dark_army.exalted_shadow_archer.basic_attack.damage_min = 4
b.enemies.dark_army.exalted_shadow_archer.basic_attack.damage_max = 6
b.enemies.dark_army.exalted_shadow_archer.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.exalted_shadow_archer.ranged_attack = {}
b.enemies.dark_army.exalted_shadow_archer.ranged_attack.shots = 3
b.enemies.dark_army.exalted_shadow_archer.ranged_attack.cooldown = 2
b.enemies.dark_army.exalted_shadow_archer.ranged_attack.max_range = 150
b.enemies.dark_army.exalted_shadow_archer.ranged_attack.min_range = 60
b.enemies.dark_army.exalted_shadow_archer.ranged_attack.damage_min = 10
b.enemies.dark_army.exalted_shadow_archer.ranged_attack.damage_max = 15
b.enemies.dark_army.exalted_shadow_archer.ranged_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.exalted_shadow_archer.cloud_of_crows = {}
b.enemies.dark_army.exalted_shadow_archer.cloud_of_crows.speed = 64
b.enemies.dark_army.exalted_shadow_archer.cloud_of_crows.nodes_to_explode = 56
b.enemies.dark_army.exalted_shadow_archer.cloud_of_crows.spawn_count = 2
b.enemies.dark_army.exalted_shadow_blades = {}
b.enemies.dark_army.exalted_shadow_blades.gold = 10
b.enemies.dark_army.exalted_shadow_blades.hp = {
	110,
	120,
	150,
	170
}
b.enemies.dark_army.exalted_shadow_blades.armor = 0
b.enemies.dark_army.exalted_shadow_blades.magic_armor = 0
b.enemies.dark_army.exalted_shadow_blades.speed = 64
b.enemies.dark_army.exalted_shadow_blades.basic_attack = {}
b.enemies.dark_army.exalted_shadow_blades.basic_attack.cooldown = 0.8
b.enemies.dark_army.exalted_shadow_blades.basic_attack.damage_min = 12
b.enemies.dark_army.exalted_shadow_blades.basic_attack.damage_max = 18
b.enemies.dark_army.exalted_shadow_blades.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.exalted_shadow_blades.smokebomb = {}
b.enemies.dark_army.exalted_shadow_blades.smokebomb.radius = 120
b.enemies.dark_army.exalted_shadow_blades.smokebomb.amount_of_clouds = 20
b.enemies.dark_army.exalted_shadow_blades.smokebomb.duration = 3
b.enemies.dark_army.exalted_shadow_blades.smokebomb.min_nodes_to_exit = 35
b.enemies.dark_army.exalted_shadow_blades.smokebomb.hp_threshold = 0.3
b.enemies.dark_army.exalted_shadow_blades.cloud_of_crows = {}
b.enemies.dark_army.exalted_shadow_blades.cloud_of_crows.speed = 64
b.enemies.dark_army.exalted_shadow_blades.cloud_of_crows.nodes_to_explode = 25
b.enemies.dark_army.exalted_shadow_blades.cloud_of_crows.spawn_count = 2
b.enemies.dark_army.exalted_crowcaller = {}
b.enemies.dark_army.exalted_crowcaller.gold = 40
b.enemies.dark_army.exalted_crowcaller.hp = {
	420,
	480,
	600,
	660
}
b.enemies.dark_army.exalted_crowcaller.armor = 0
b.enemies.dark_army.exalted_crowcaller.magic_armor = 0.8
b.enemies.dark_army.exalted_crowcaller.speed = 32
b.enemies.dark_army.exalted_crowcaller.basic_attack = {}
b.enemies.dark_army.exalted_crowcaller.basic_attack.cooldown = 1
b.enemies.dark_army.exalted_crowcaller.basic_attack.damage_min = 10
b.enemies.dark_army.exalted_crowcaller.basic_attack.damage_max = 15
b.enemies.dark_army.exalted_crowcaller.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.exalted_crowcaller.crowcall = {}
b.enemies.dark_army.exalted_crowcaller.crowcall.cooldown = 6
b.enemies.dark_army.exalted_crowcaller.crowcall.spawn_count = 2
b.enemies.dark_army.exalted_crowcaller.crowcall.max_crows = 10
b.enemies.dark_army.exalted_crowcaller.crowcall.node_limit = 60
b.enemies.dark_army.exalted_crow = {}
b.enemies.dark_army.exalted_crow.gold = 2
b.enemies.dark_army.exalted_crow.hp = {
	20,
	30,
	35,
	40
}
b.enemies.dark_army.exalted_crow.armor = 0
b.enemies.dark_army.exalted_crow.magic_armor = 0
b.enemies.dark_army.exalted_crow.speed = 70
b.enemies.dark_army.gargoyle = {}
b.enemies.dark_army.gargoyle.gold = 8
b.enemies.dark_army.gargoyle.hp = {
	105,
	120,
	150,
	165
}
b.enemies.dark_army.gargoyle.armor = 0
b.enemies.dark_army.gargoyle.magic_armor = 0
b.enemies.dark_army.gargoyle.speed = 50
b.enemies.dark_army.gargoyle.stone_form = {}
b.enemies.dark_army.gargoyle.stone_form.trigger_hp = 60
b.enemies.dark_army.gargoyle.stone_form.max_uses = 1
b.enemies.dark_army.gargoyle.stone_form.heal_per_second_min = 30
b.enemies.dark_army.gargoyle.stone_form.heal_per_second_max = 30
b.enemies.dark_army.gargoyle.stone_form.heal_every = 0.25
b.enemies.dark_army.gargoyle.stone_form.duration = {
	4,
	4,
	4,
	6
}
b.enemies.dark_army.gargoyle.stone_form.armor = 0
b.enemies.dark_army.gargoyle.stone_form.magic_armor = 0
b.enemies.dark_army.tainted_wolf = {}
b.enemies.dark_army.tainted_wolf.gold = 12
b.enemies.dark_army.tainted_wolf.hp = {
	180,
	225,
	250,
	315
}
b.enemies.dark_army.tainted_wolf.armor = 0
b.enemies.dark_army.tainted_wolf.magic_armor = 0.5
b.enemies.dark_army.tainted_wolf.speed = 64
b.enemies.dark_army.tainted_wolf.basic_attack = {}
b.enemies.dark_army.tainted_wolf.basic_attack.cooldown = 1.25
b.enemies.dark_army.tainted_wolf.basic_attack.damage_min = 16
b.enemies.dark_army.tainted_wolf.basic_attack.damage_max = 24
b.enemies.dark_army.tainted_wolf.basic_attack.damage_type = DAMAGE_MAGICAL
b.enemies.dark_army.tainted_wolf.dodge_chance = {
	0.4,
	0.4,
	0.4,
	0.55
}
b.enemies.dark_army.dark_disciple = {}
b.enemies.dark_army.dark_disciple.gold = 30
b.enemies.dark_army.dark_disciple.hp = {
	350,
	400,
	500,
	625
}
b.enemies.dark_army.dark_disciple.armor = 0
b.enemies.dark_army.dark_disciple.magic_armor = 0.9
b.enemies.dark_army.dark_disciple.speed = 20
b.enemies.dark_army.dark_disciple.lives_cost = 1
b.enemies.dark_army.dark_disciple.basic_attack = {}
b.enemies.dark_army.dark_disciple.basic_attack.cooldown = 1.5
b.enemies.dark_army.dark_disciple.basic_attack.damage_min = 10
b.enemies.dark_army.dark_disciple.basic_attack.damage_max = 16
b.enemies.dark_army.dark_disciple.basic_attack.damage_radius = 50
b.enemies.dark_army.dark_disciple.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.dark_disciple.ranged_attack = {}
b.enemies.dark_army.dark_disciple.ranged_attack.cooldown = 2
b.enemies.dark_army.dark_disciple.ranged_attack.min_range = 30
b.enemies.dark_army.dark_disciple.ranged_attack.max_range = 120
b.enemies.dark_army.dark_disciple.ranged_attack.damage_min = 36
b.enemies.dark_army.dark_disciple.ranged_attack.damage_max = 68
b.enemies.dark_army.dark_disciple.ranged_attack.damage_type = DAMAGE_MAGICAL
b.enemies.dark_army.dark_disciple.block_tower_attack = {}
b.enemies.dark_army.dark_disciple.block_tower_attack.cooldown = 2
b.enemies.dark_army.dark_disciple.block_tower_attack.min_range = 0
b.enemies.dark_army.dark_disciple.block_tower_attack.max_range = {
	240,
	240,
	240,
	300
}
b.enemies.dark_army.dark_disciple.block_tower_attack.tether_range = {
	240,
	240,
	240,
	300
}
b.enemies.dark_army.dark_knight = {}
b.enemies.dark_army.dark_knight.gold = 60
b.enemies.dark_army.dark_knight.hp = {
	700,
	860,
	960,
	1200
}
b.enemies.dark_army.dark_knight.armor = 0.8
b.enemies.dark_army.dark_knight.magic_armor = 0
b.enemies.dark_army.dark_knight.speed = 28
b.enemies.dark_army.dark_knight.lives_cost = 1
b.enemies.dark_army.dark_knight.basic_attack = {}
b.enemies.dark_army.dark_knight.basic_attack.cooldown = 1.5
b.enemies.dark_army.dark_knight.basic_attack.damage_min = 30
b.enemies.dark_army.dark_knight.basic_attack.damage_max = 46
b.enemies.dark_army.dark_knight.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.dark_knight.kills_to_transform = 1000
b.enemies.dark_army.dark_slayer = {}
b.enemies.dark_army.dark_slayer.gold = 160
b.enemies.dark_army.dark_slayer.hp = {
	1200,
	1440,
	1600,
	2000
}
b.enemies.dark_army.dark_slayer.armor = 1
b.enemies.dark_army.dark_slayer.magic_armor = 0
b.enemies.dark_army.dark_slayer.speed = 24
b.enemies.dark_army.dark_slayer.lives_cost = 2
b.enemies.dark_army.dark_slayer.basic_attack = {}
b.enemies.dark_army.dark_slayer.basic_attack.cooldown = 2
b.enemies.dark_army.dark_slayer.basic_attack.damage_min = 35
b.enemies.dark_army.dark_slayer.basic_attack.damage_max = 52
b.enemies.dark_army.dark_slayer.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.dark_slayer.instakill_cooldown = 10
b.enemies.dark_army.dark_slayer.instakill_chance = {
	0.3,
	0.3,
	0.3,
	0.4
}
b.enemies.dark_army.dark_slayer.spiked_armor = 0.3
b.enemies.dark_army.death_rider = {}
b.enemies.dark_army.death_rider.gold = 70
b.enemies.dark_army.death_rider.hp = 800
b.enemies.dark_army.death_rider.armor = 0
b.enemies.dark_army.death_rider.magic_armor = 0
b.enemies.dark_army.death_rider.speed = 52
b.enemies.dark_army.death_rider.lives_cost = 1
b.enemies.dark_army.death_rider.plague_aura = {}
b.enemies.dark_army.death_rider.plague_aura.radius = 50
b.enemies.dark_army.death_rider.plague_aura.cycle_time = 0.25
b.enemies.dark_army.death_rider.plague_aura.damage_min = 8
b.enemies.dark_army.death_rider.plague_aura.damage_max = 16
b.enemies.dark_army.death_rider.plague_aura.damage_type = DAMAGE_MAGICAL
b.enemies.dark_army.death_rider.death_sliding = {}
b.enemies.dark_army.death_rider.death_sliding.speed = 46
b.enemies.dark_army.death_rider.death_sliding.slide_speed_factor = 2
b.enemies.dark_army.death_rider.gallop = {}
b.enemies.dark_army.death_rider.gallop.cooldown = 10
b.enemies.dark_army.death_rider.gallop.range = 70
b.enemies.dark_army.death_rider.gallop.speed_mult = 1.923
b.enemies.dark_army.death_rider.gallop.duration = 1.8
b.enemies.dark_army.necromancer = {}
b.enemies.dark_army.necromancer.gold = 50
b.enemies.dark_army.necromancer.hp = {
	450,
	500,
	600,
	800
}
b.enemies.dark_army.necromancer.armor = 0
b.enemies.dark_army.necromancer.magic_armor = 0.6
b.enemies.dark_army.necromancer.speed = 20
b.enemies.dark_army.necromancer.lives_cost = 1
b.enemies.dark_army.necromancer.basic_attack = {}
b.enemies.dark_army.necromancer.basic_attack.cooldown = 1.5
b.enemies.dark_army.necromancer.basic_attack.damage_min = 12
b.enemies.dark_army.necromancer.basic_attack.damage_max = 18
b.enemies.dark_army.necromancer.basic_attack.damage_radius = 50
b.enemies.dark_army.necromancer.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.dark_army.necromancer.custom_attack = {}
b.enemies.dark_army.necromancer.custom_attack.cooldown = 2.5
b.enemies.dark_army.necromancer.custom_attack.min_range = 30
b.enemies.dark_army.necromancer.custom_attack.max_range = 120
b.enemies.dark_army.necromancer.custom_attack.damage_min = 40
b.enemies.dark_army.necromancer.custom_attack.damage_max = 60
b.enemies.dark_army.necromancer.custom_attack.damage_type = DAMAGE_MAGICAL
b.enemies.dark_army.necromancer.custom_attack.duration = 0.5
b.enemies.dark_army.necromancer.custom_attack.lifesteal = 0.25
b.enemies.dark_army.necromancer.spawn_cooldown = 7
b.enemies.dark_army.necromancer.spawn_first_cooldown = 2
b.enemies.dark_army.necromancer.spawn_max_count = {
	4,
	5,
	5,
	6
}
b.enemies.dark_army.necromancer.max_skeleton_count = 20
b.enemies.dark_army.necromancer.summon_skeleton_node_limit = 60
b.enemies.dark_army.dark_construct = {}
b.enemies.dark_army.dark_construct.gold = 200
b.enemies.dark_army.dark_construct.hp = {
	1960,
	2240,
	2800,
	3080
}
b.enemies.dark_army.dark_construct.armor = 0
b.enemies.dark_army.dark_construct.magic_armor = 0
b.enemies.dark_army.dark_construct.speed = 24
b.enemies.dark_army.dark_construct.lives_cost = 2
b.enemies.dark_army.dark_construct.basic_attack = {}
b.enemies.dark_army.dark_construct.basic_attack.cooldown = 2
b.enemies.dark_army.dark_construct.basic_attack.damage_min = 48
b.enemies.dark_army.dark_construct.basic_attack.damage_max = 72
b.enemies.dark_army.dark_construct.basic_attack.damage_radius = 80
b.enemies.dark_army.dark_construct.basic_attack.damage_type = DAMAGE_MAGICAL
b.enemies.dark_army.dark_construct.spawn = {}
b.enemies.dark_army.dark_construct.spawn.spawn_count = 3
b.enemies.dark_army.dark_construct.spawn.min_nodes_ahead = 10
b.enemies.dark_army.dark_construct.spawn.max_nodes_ahead = 25
b.enemies.dark_army.dark_construct.spawn.max_nodes_to_exit = 70
b.enemies.dark_army.darkling = {}
b.enemies.dark_army.darkling.gold = 0
b.enemies.dark_army.darkling.hp = 80
b.enemies.dark_army.darkling.armor = 0
b.enemies.dark_army.darkling.magic_armor = 0
b.enemies.dark_army.darkling.speed = 64
b.enemies.dark_army.darkling.lives_cost = 1
b.enemies.dark_army.darkling.roll = {}
b.enemies.dark_army.darkling.roll.cooldown = 3
b.enemies.dark_army.darkling.roll.movement_speed = 120
b.enemies.dark_army.darkling.roll.duration = 1
b.enemies.dark_army.darkling.roll.range = 60
b.enemies.lord_blackburn_boss = {}
b.enemies.lord_blackburn_boss.hp = {
	9000,
	11000,
	12000,
	14000
}
b.enemies.lord_blackburn_boss.armor = {
	0.5,
	0.6,
	0.6,
	0.74
}
b.enemies.lord_blackburn_boss.magic_armor = 0
b.enemies.lord_blackburn_boss.speed = 12
b.enemies.lord_blackburn_boss.start_path = 1
b.enemies.lord_blackburn_boss.start_node = 50
b.enemies.lord_blackburn_boss.basic_attack = {}
b.enemies.lord_blackburn_boss.basic_attack.cooldown = 1.5
b.enemies.lord_blackburn_boss.basic_attack.damage_min = 175
b.enemies.lord_blackburn_boss.basic_attack.damage_max = 225
b.enemies.lord_blackburn_boss.basic_attack.damage_radius = 75
b.enemies.lord_blackburn_boss.basic_attack.damage_type = DAMAGE_TRUE
b.enemies.lord_blackburn_boss.tower_block = {}
b.enemies.lord_blackburn_boss.tower_block.cooldown = 18
b.enemies.lord_blackburn_boss.tower_block.range = 250
b.enemies.lord_blackburn_boss.tower_block.duration = 4
b.enemies.lord_blackburn_boss.tower_block.targets = 4
b.enemies.lord_blackburn_boss.tower_block.damage_min = 175
b.enemies.lord_blackburn_boss.tower_block.damage_max = 225
b.enemies.lord_blackburn_boss.tower_block.damage_radius = 100
b.enemies.lord_blackburn_boss.tower_block.damage_type = DAMAGE_PHYSICAL
b.enemies.demons = {}
b.enemies.demons.demon_imp = {}
b.enemies.demons.demon_imp.gold = 5
b.enemies.demons.demon_imp.hp = {
	180,
	200,
	250,
	280
}
b.enemies.demons.demon_imp.armor = 0
b.enemies.demons.demon_imp.magic_armor = 0.25
b.enemies.demons.demon_imp.speed = 60
b.enemies.demons.demon_hound = {}
b.enemies.demons.demon_hound.gold = 6
b.enemies.demons.demon_hound.hp = {
	245,
	350,
	450,
	500
}
b.enemies.demons.demon_hound.armor = 0
b.enemies.demons.demon_hound.magic_armor = 0.5
b.enemies.demons.demon_hound.speed = 60
b.enemies.demons.demon_hound.basic_attack = {}
b.enemies.demons.demon_hound.basic_attack.cooldown = 1
b.enemies.demons.demon_hound.basic_attack.damage_min = 21
b.enemies.demons.demon_hound.basic_attack.damage_max = 39
b.enemies.demons.demon_hound.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.demons.demon_hound.dodge_chance = 0.3
b.enemies.demons.demon_hound.death_explosion = {}
b.enemies.demons.demon_hound.death_explosion.damage_min = 50
b.enemies.demons.demon_hound.death_explosion.damage_max = 70
b.enemies.demons.demon_hound.death_explosion.damage_radius = 45
b.enemies.demons.demon_hound.death_explosion.damage_type = DAMAGE_EXPLOSION
b.enemies.demons.demon_lord = {}
b.enemies.demons.demon_lord.gold = 20
b.enemies.demons.demon_lord.hp = {
	910,
	1250,
	1350,
	1500
}
b.enemies.demons.demon_lord.armor = 0
b.enemies.demons.demon_lord.magic_armor = 0.8
b.enemies.demons.demon_lord.speed = 32
b.enemies.demons.demon_lord.basic_attack = {}
b.enemies.demons.demon_lord.basic_attack.cooldown = 1.5
b.enemies.demons.demon_lord.basic_attack.damage_min = 35
b.enemies.demons.demon_lord.basic_attack.damage_max = 65
b.enemies.demons.demon_lord.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.demons.demon_lord.shield = {}
b.enemies.demons.demon_lord.shield.range = 180
b.enemies.demons.demon_lord.shield.cooldown = 6
b.enemies.demons.demon_lord.shield.cast_time = fts(15)
b.enemies.demons.demon_lord.shield.max_count = 4
b.enemies.demons.demon_lord.shield.ignore_hits = 4
b.enemies.demons.demon_lord.death_explosion = {}
b.enemies.demons.demon_lord.death_explosion.damage_min = 90
b.enemies.demons.demon_lord.death_explosion.damage_max = 120
b.enemies.demons.demon_lord.death_explosion.damage_radius = 60
b.enemies.demons.demon_lord.death_explosion.damage_type = DAMAGE_PHYSICAL
b.enemies.demons.magma_elemental = {}
b.enemies.demons.magma_elemental.gold = 110
b.enemies.demons.magma_elemental.hp = {
	2000,
	2500,
	2850,
	3200
}
b.enemies.demons.magma_elemental.armor = 0.8
b.enemies.demons.magma_elemental.magic_armor = 0
b.enemies.demons.magma_elemental.speed = 20
b.enemies.demons.magma_elemental.lives_cost = 2
b.enemies.demons.magma_elemental.basic_attack = {}
b.enemies.demons.magma_elemental.basic_attack.cooldown = 2.5
b.enemies.demons.magma_elemental.basic_attack.damage_min = 70
b.enemies.demons.magma_elemental.basic_attack.damage_max = 100
b.enemies.demons.magma_elemental.basic_attack.damage_type = DAMAGE_PHYSICAL
b.enemies.demons.magma_elemental.basic_attack.damage_radius = 50
b.enemies.demons.magma_elemental.basic_attack.count = 6
b.enemies.demons.magma_elemental.basic_attack.burn_duration = 3
b.enemies.demons.magma_elemental.basic_attack.burn_damage_min = 8
b.enemies.demons.magma_elemental.basic_attack.burn_damage_max = 12
b.towers = {}
b.towers.common = {}
b.towers.archers = {}
b.towers.archers.price = {
	70,
	100,
	150,
	230
}
b.towers.archers.stats = {}
b.towers.archers.stats.damage = 2
b.towers.archers.stats.range = 5.5
b.towers.archers.stats.cooldown = 9.5
b.towers.archers.basic_attack = {}
b.towers.archers.basic_attack.damage_min = {
	4,
	9,
	13,
	16
}
b.towers.archers.basic_attack.damage_max = {
	6,
	13,
	18,
	26
}
b.towers.archers.basic_attack.cooldown = {
	1,
	0.9,
	0.7,
	0.6
}
b.towers.archers.basic_attack.range = {
	165,
	180,
	200,
	220
}
b.towers.archers.basic_attack.damage_type = DAMAGE_PHYSICAL
b.towers.archers.skill_a = {}
b.towers.archers.skill_a.price = {
	150,
	150,
	150
}
b.towers.archers.skill_a.xp_gain = 15
b.towers.archers.skill_a.cooldown = 15
b.towers.archers.skill_a.damage_min = {
	16,
	20,
	24
}
b.towers.archers.skill_a.damage_max = {
	24,
	30,
	36
}
b.towers.archers.skill_a.damage_type = DAMAGE_PHYSICAL
b.towers.archers.skill_a.stun_duration = {
	2,
	4,
	6
}
b.towers.archers.skill_a.targets = 2
b.towers.archers.skill_b = {}
b.towers.archers.skill_b.price = {
	120,
	120,
	120
}
b.towers.archers.skill_b.xp_gain = 20
b.towers.archers.skill_b.radius = 220
b.towers.archers.skill_b.range_factor = {
	1.15,
	1.25,
	1.35
}
b.towers.archers.skill_b.s_range_factor = {
	sub_one(b.towers.archers.skill_b.range_factor[1]),
	sub_one(b.towers.archers.skill_b.range_factor[2]),
	sub_one(b.towers.archers.skill_b.range_factor[3])
}
b.towers.archers.skill_c = {}
b.towers.archers.skill_c.price = {
	200,
	200,
	200
}
b.towers.archers.skill_c.xp_gain = 10
b.towers.archers.skill_c.cooldown = 12
b.towers.archers.skill_c.duration = {
	5,
	6,
	7
}
b.towers.archers.skill_c.weak_factor = {
	1.3,
	1.5,
	1.75
}
b.towers.archers.skill_c.boss_weak_factor = {
	1.15,
	1.25,
	1.35
}
b.towers.archers.skill_c.s_weak_factor = {
	sub_one(b.towers.archers.skill_c.weak_factor[1]),
	sub_one(b.towers.archers.skill_c.weak_factor[2]),
	sub_one(b.towers.archers.skill_c.weak_factor[3])
}
b.towers.archers.skill_c.range = 200
b.towers.archers.skill_c.min_hp = 50
b.towers.archers.ultimate = {}
b.towers.archers.ultimate.xp_gain = 30
b.towers.archers.ultimate.cooldown = 36
b.towers.archers.ultimate.duration = 6
b.towers.archers.ultimate.attack_cd = 0.3
b.towers.archers.ultimate.min_targets = 1
b.towers.archers.ultimate.min_hp = 800
b.towers.knights = {}
b.towers.knights.price = {
	70,
	110,
	160,
	220
}
b.towers.knights.stats = {}
b.towers.knights.stats.damage = 1
b.towers.knights.stats.hp = 6
b.towers.knights.stats.armor = 4.5
b.towers.knights.rally_range = 150
b.towers.knights.max_soldiers = 3
b.towers.knights.soldier = {}
b.towers.knights.soldier.armor = {
	0.1,
	0.2,
	0.3,
	0.4
}
b.towers.knights.soldier.dead_lifetime = 12
b.towers.knights.soldier.hp = {
	40,
	80,
	130,
	200
}
b.towers.knights.soldier.regen_hp = {
	3,
	6,
	10,
	13
}
b.towers.knights.soldier.speed = 75
b.towers.knights.soldier.basic_attack = {}
b.towers.knights.soldier.basic_attack.damage_min = {
	2,
	3,
	6,
	9
}
b.towers.knights.soldier.basic_attack.damage_max = {
	4,
	5,
	10,
	13
}
b.towers.knights.soldier.basic_attack.cooldown = 1
b.towers.knights.soldier.basic_attack.range = 70
b.towers.knights.skill_a = {}
b.towers.knights.skill_a.price = {
	120,
	120,
	120
}
b.towers.knights.skill_a.xp_gain = 20
b.towers.knights.skill_a.armor_inc_per_hero = {
	0.05,
	0.1,
	0.15
}
b.towers.knights.skill_a.radius = 110
b.towers.knights.skill_b = {}
b.towers.knights.skill_b.price = {
	180,
	180,
	180
}
b.towers.knights.skill_b.xp_gain = 20
b.towers.knights.skill_b.cooldown = 15
b.towers.knights.skill_b.hp_ptg = {
	0.25,
	0.4,
	0.6
}
b.towers.knights.skill_c = {}
b.towers.knights.skill_c.price = {
	150,
	100,
	100
}
b.towers.knights.skill_c.xp_gain = 20
b.towers.knights.skill_c.cd_mult = {
	0.8,
	0.6,
	0.4
}
b.towers.knights.skill_c.s_cd_mult = {
	0.2,
	0.4,
	0.6
}
b.towers.knights.skill_c.duration = 8
b.towers.knights.skill_c.radius = 100
b.towers.knights.ultimate = {}
b.towers.knights.ultimate.xp_gain = 35
b.towers.knights.ultimate.cooldown = 30
b.towers.knights.ultimate.hp_trigger = 0.2
b.towers.knights.ultimate.duration = 5
b.towers.wizard = {}
b.towers.wizard.shared_min_cooldown = 2
b.towers.wizard.price = {
	100,
	150,
	210,
	280
}
b.towers.wizard.stats = {}
b.towers.wizard.stats.damage = 9.5
b.towers.wizard.stats.range = 4
b.towers.wizard.stats.cooldown = 7
b.towers.wizard.basic_attack = {}
b.towers.wizard.basic_attack.damage_min = {
	6,
	14,
	24,
	36
}
b.towers.wizard.basic_attack.damage_max = {
	9,
	24,
	43,
	66
}
b.towers.wizard.basic_attack.cooldown = 2
b.towers.wizard.basic_attack.range = {
	160,
	170,
	180,
	190
}
b.towers.wizard.basic_attack.damage_type = DAMAGE_MAGICAL
b.towers.wizard.skill_a = {}
b.towers.wizard.skill_a.price = {
	120,
	120,
	120
}
b.towers.wizard.skill_a.damage_min = {
	40,
	100,
	160
}
b.towers.wizard.skill_a.damage_max = {
	40,
	100,
	160
}
b.towers.wizard.skill_a.s_damage = {
	40,
	100,
	160
}
b.towers.wizard.skill_a.cooldown = {
	20,
	20,
	20
}
b.towers.wizard.skill_a.range = {
	180,
	180,
	180
}
b.towers.wizard.skill_a.damage_radius = 60
b.towers.wizard.skill_a.burn = {}
b.towers.wizard.skill_a.burn.duration = 4
b.towers.wizard.skill_a.burn.damage = {
	2,
	3,
	4
}
b.towers.wizard.skill_a.burn.damage_every = 0.25
b.towers.wizard.skill_a.burn.s_damage = {
	32,
	48,
	64
}
b.towers.wizard.skill_b = {}
b.towers.wizard.skill_b.price = {
	200,
	160,
	160
}
b.towers.wizard.skill_b.enemy_check_range = 300
b.towers.wizard.skill_b.cooldown = {
	25,
	25,
	25
}
b.towers.wizard.skill_b.damage_factor = {
	1.5,
	1.75,
	2
}
b.towers.wizard.skill_b.s_damage_factor = {
	0.5,
	0.75,
	1
}
b.towers.wizard.skill_b.duration = {
	8,
	10,
	12
}
b.towers.wizard.skill_c = {}
b.towers.wizard.skill_c.price = {
	160,
	160,
	160
}
b.towers.wizard.skill_c.hit_min_damage = 50
b.towers.wizard.skill_c.hit_max_damage = 50
b.towers.wizard.skill_c.cooldown = {
	25,
	25,
	25
}
b.towers.wizard.skill_c.book = {}
b.towers.wizard.skill_c.book.range = 140
b.towers.wizard.skill_c.book.min_damage = {
	34,
	52,
	62
}
b.towers.wizard.skill_c.book.max_damage = {
	60,
	92,
	108
}
b.towers.wizard.skill_c.book.bullet_count = {
	3,
	5,
	8
}
b.towers.wizard.ultimate = {}
b.towers.wizard.ultimate.damage = 620
b.towers.wizard.ultimate.cooldown = 36
b.towers.wizard.ultimate.range = {
	180,
	180,
	180,
	180
}
b.towers.wizard.ultimate.stun_duration = 1
b.towers.wizard.ultimate.damage_type = DAMAGE_MAGICAL
b.towers.wizard.ultimate.stun_range = 20
b.towers.catapult = {}
b.towers.catapult.shared_min_cooldown = 3
b.towers.catapult.price = {
	110,
	160,
	220,
	290
}
b.towers.catapult.stats = {}
b.towers.catapult.stats.damage = 9
b.towers.catapult.stats.cooldown = 1.5
b.towers.catapult.stats.range = 9
b.towers.catapult.basic_attack = {}
b.towers.catapult.basic_attack.damage_min = {
	14,
	32,
	52,
	80
}
b.towers.catapult.basic_attack.damage_max = {
	20,
	45,
	78,
	120
}
b.towers.catapult.basic_attack.damage_radius = 60
b.towers.catapult.basic_attack.damage_type = DAMAGE_EXPLOSION
b.towers.catapult.basic_attack.cooldown = 3
b.towers.catapult.basic_attack.range = {
	250,
	265,
	280,
	300
}
b.towers.catapult.skill_a = {}
b.towers.catapult.skill_a.price = {
	100,
	100,
	100
}
b.towers.catapult.skill_a.xp_gain = 15
b.towers.catapult.skill_a.damage_min = {
	80,
	80,
	80
}
b.towers.catapult.skill_a.damage_max = {
	120,
	120,
	120
}
b.towers.catapult.skill_a.damage_radius = 60
b.towers.catapult.skill_a.damage_type = DAMAGE_EXPLOSION
b.towers.catapult.skill_a.cooldown = {
	15,
	15,
	15
}
b.towers.catapult.skill_a.range = 300
b.towers.catapult.skill_a.slow_factor = {
	0.6,
	0.5,
	0.4
}
b.towers.catapult.skill_a.s_slow_factor = {
	0.4,
	0.5,
	0.6
}
b.towers.catapult.skill_a.slow_duration = {
	6,
	8,
	10
}
b.towers.catapult.skill_b = {}
b.towers.catapult.skill_b.price = {
	200,
	200,
	200
}
b.towers.catapult.skill_b.xp_gain = 20
b.towers.catapult.skill_b.damage_min = {
	18,
	36,
	52
}
b.towers.catapult.skill_b.damage_max = {
	32,
	64,
	92
}
b.towers.catapult.skill_b.damage_radius = 60
b.towers.catapult.skill_b.damage_type = DAMAGE_EXPLOSION
b.towers.catapult.skill_b.explosion_delay = 0.1
b.towers.catapult.skill_c = {}
b.towers.catapult.skill_c.price = {
	120,
	100,
	100
}
b.towers.catapult.skill_c.xp_gain = 20
b.towers.catapult.skill_c.cooldown = {
	7,
	7,
	7
}
b.towers.catapult.skill_c.min_range = 20
b.towers.catapult.skill_c.max_range = 120
b.towers.catapult.skill_c.damage_min = {
	20,
	32,
	48
}
b.towers.catapult.skill_c.damage_max = {
	30,
	48,
	72
}
b.towers.catapult.skill_c.damage_radius = 40
b.towers.catapult.skill_c.damage_type = DAMAGE_PHYSICAL
b.towers.catapult.skill_c.stun_duration = {
	1,
	2,
	3
}
b.towers.catapult.skill_c.max_traps = {
	3,
	4,
	5
}
b.towers.catapult.skill_c.min_dist_between_traps = 50
b.towers.catapult.ultimate = {}
b.towers.catapult.ultimate.xp_gain = 35
b.towers.catapult.ultimate.cooldown = 35
b.towers.catapult.ultimate.min_range = 0
b.towers.catapult.ultimate.max_range = 300
b.towers.catapult.ultimate.min_targets = 3
b.towers.catapult.ultimate.speed = 100
b.towers.catapult.ultimate.hit_damage_min = 60
b.towers.catapult.ultimate.hit_damage_max = 60
b.towers.catapult.ultimate.hit_damage_radius = 55
b.towers.catapult.ultimate.hit_damage_type = DAMAGE_EXPLOSION
b.towers.catapult.ultimate.explosion_damage_min = 60
b.towers.catapult.ultimate.explosion_damage_max = 60
b.towers.catapult.ultimate.explosion_damage_radius = 55
b.towers.catapult.ultimate.explosion_damage_type = DAMAGE_EXPLOSION
b.towers.catapult.ultimate.damage_min = 75
b.towers.catapult.ultimate.damage_max = 75
b.towers.catapult.ultimate.damage_type = DAMAGE_EXPLOSION
b.towers.catapult.ultimate.s_total_damage = 195
b.towers.catapult.ultimate.radius = 60
b.towers.catapult.ultimate.nodes = 50
b.towers.catapult.ultimate.burn = {}
b.towers.catapult.ultimate.burn.duration = 4
b.towers.catapult.ultimate.burn.damage = {
	4,
	4,
	4
}
b.towers.catapult.ultimate.burn.s_damage = 64
b.towers.catapult.ultimate.burn.damage_every = 0.25
b.towers.ranger = {}
b.towers.ranger.price = {
	80,
	120,
	180,
	260
}
b.towers.ranger.stats = {}
b.towers.ranger.stats.damage = 5.5
b.towers.ranger.stats.cooldown = 9
b.towers.ranger.stats.range = 6
b.towers.ranger.basic_attack = {}
b.towers.ranger.basic_attack.range = {
	190,
	200,
	215,
	235
}
b.towers.ranger.basic_attack.cooldown = 1.5
b.towers.ranger.bullet = {}
b.towers.ranger.bullet.damage_min = {
	6,
	16,
	32,
	52
}
b.towers.ranger.bullet.damage_max = {
	10,
	24,
	42,
	66
}
b.towers.ranger.bullet.damage_type = DAMAGE_PHYSICAL
b.towers.ranger.skill_a = {}
b.towers.ranger.skill_a.price = {
	200,
	200,
	200
}
b.towers.ranger.skill_a.cooldown = {
	15,
	15,
	15
}
b.towers.ranger.skill_a.bullet = {}
b.towers.ranger.skill_a.bullet.damage_min = {
	54,
	54,
	54
}
b.towers.ranger.skill_a.bullet.damage_max = {
	66,
	66,
	66
}
b.towers.ranger.skill_a.bullet.damage_type = DAMAGE_PHYSICAL
b.towers.ranger.skill_a.poison = {}
b.towers.ranger.skill_a.poison.duration = {
	3,
	5,
	8
}
b.towers.ranger.skill_a.poison.damage_min = {
	2,
	4,
	6
}
b.towers.ranger.skill_a.poison.damage_max = {
	2,
	4,
	6
}
b.towers.ranger.skill_a.poison.s_damage_total = {
	24,
	80,
	192
}
b.towers.ranger.skill_a.poison.damage_every = {
	0.25,
	0.25,
	0.25
}
b.towers.ranger.skill_a.poison.damage_type = DAMAGE_TRUE
b.towers.ranger.skill_b = {}
b.towers.ranger.skill_b.price = {
	150,
	150,
	150
}
b.towers.ranger.skill_b.cooldown = {
	25,
	25,
	25
}
b.towers.ranger.skill_b.stun_duration = {
	2,
	2,
	2
}
b.towers.ranger.skill_b.bullet = {}
b.towers.ranger.skill_b.bullet.damage_min = {
	80,
	120,
	160
}
b.towers.ranger.skill_b.bullet.damage_max = {
	120,
	180,
	240
}
b.towers.ranger.skill_b.bullet.damage_type = DAMAGE_PHYSICAL
b.towers.ranger.skill_b.aura = {}
b.towers.ranger.skill_b.aura.slow_factor = {
	0.4,
	0.4,
	0.4
}
b.towers.ranger.skill_b.aura.s_slow_factor = {
	0.6,
	0.6,
	0.6
}
b.towers.ranger.skill_b.aura.slow_duration = {
	0.5,
	0.5,
	0.5
}
b.towers.ranger.skill_b.aura.duration = {
	6,
	7,
	9
}
b.towers.ranger.skill_b.aura.cycle_time = {
	0.25,
	0.25,
	0.25
}
b.towers.ranger.skill_b.aura.radius = {
	60,
	60,
	60
}
b.towers.ranger.skill_c = {}
b.towers.ranger.skill_c.price = {
	250,
	200,
	200
}
b.towers.ranger.skill_c.bounce_damage_mult = {
	0.25,
	0.5,
	0.75
}
b.towers.ranger.skill_c.damage_type = DAMAGE_PHYSICAL
b.towers.ranger.skill_c.bounce_range = {
	100,
	100,
	100
}
b.towers.ranger.skill_c.max_bounces = {
	3,
	3,
	3
}
b.towers.ranger.ultimate = {}
b.towers.ranger.ultimate.damage_boss = 500
b.towers.ranger.ultimate.hp_threshold = 0.4
b.towers.ranger.ultimate.cooldown = 32
b.towers.culverine = {}
b.towers.culverine.shared_min_cooldown = 3
b.towers.culverine.price = {
	130,
	180,
	240,
	310
}
b.towers.culverine.stats = {}
b.towers.culverine.stats.damage = 7
b.towers.culverine.stats.cooldown = 5
b.towers.culverine.stats.range = 3.5
b.towers.culverine.basic_attack = {}
b.towers.culverine.basic_attack.damage_min = {
	10,
	25,
	45,
	70
}
b.towers.culverine.basic_attack.damage_max = {
	14,
	33,
	59,
	90
}
b.towers.culverine.basic_attack.damage_radius = 55
b.towers.culverine.basic_attack.damage_type = DAMAGE_EXPLOSION
b.towers.culverine.basic_attack.cooldown = 3
b.towers.culverine.basic_attack.range = {
	180,
	180,
	180,
	180
}
b.towers.culverine.skill_a = {}
b.towers.culverine.skill_a.price = {
	150,
	150,
	150
}
b.towers.culverine.skill_a.xp_gain = 15
b.towers.culverine.skill_a.cooldown = {
	16,
	16,
	16
}
b.towers.culverine.skill_a.damage_min = {
	70,
	115,
	165
}
b.towers.culverine.skill_a.damage_max = {
	90,
	155,
	225
}
b.towers.culverine.skill_a.damage_radius = 90
b.towers.culverine.skill_a.damage_type = DAMAGE_EXPLOSION
b.towers.culverine.skill_a.range = 200
b.towers.culverine.skill_a.aura_range = 90
b.towers.culverine.skill_a.min_targets = 3
b.towers.culverine.skill_a.min_magic_res = 0.3
b.towers.culverine.skill_a.aura_duration = {
	6,
	8,
	10
}
b.towers.culverine.skill_a.mod_duration = {
	0.3,
	0.3,
	0.3
}
b.towers.culverine.skill_a.mr_red = {
	1,
	1,
	1
}
b.towers.culverine.skill_b = {}
b.towers.culverine.skill_b.price = {
	100,
	100,
	100
}
b.towers.culverine.skill_b.xp_gain = 10
b.towers.culverine.skill_b.armor_red = {
	0.04,
	0.06,
	0.08
}
b.towers.culverine.skill_c = {}
b.towers.culverine.skill_c.price = {
	200,
	200,
	200
}
b.towers.culverine.skill_c.xp_gain = 20
b.towers.culverine.skill_c.cooldown = {
	25,
	25,
	25
}
b.towers.culverine.skill_c.rate_of_fire = {
	0.1,
	0.1,
	0.1
}
b.towers.culverine.skill_c.shots = {
	3,
	6,
	9
}
b.towers.culverine.skill_c.min_targets = 3
b.towers.culverine.skill_c.min_health = 600
b.towers.culverine.ultimate = {}
b.towers.culverine.ultimate.xp_gain = 35
b.towers.culverine.ultimate.cooldown = 35
b.towers.culverine.ultimate.attacks_to_trigger = 7
b.towers.culverine.ultimate.speed = 100
b.towers.culverine.ultimate.damage_min = 60
b.towers.culverine.ultimate.damage_max = 110
b.towers.culverine.ultimate.damage_radius = 200
b.towers.culverine.ultimate.damage_type = DAMAGE_EXPLOSION
b.towers.culverine.ultimate.stun = {}
b.towers.culverine.ultimate.stun.duration = 2
b.towers.sunray_master = {}
b.towers.sunray_master.price = {
	110,
	150,
	220,
	280
}
b.towers.sunray_master.stats = {}
b.towers.sunray_master.stats.damage = 1
b.towers.sunray_master.stats.range = 4
b.towers.sunray_master.stats.cooldown = 10
b.towers.sunray_master.baisc_attack_range = {
	160,
	170,
	180,
	190
}
b.towers.sunray_master.beam_attack = {}
b.towers.sunray_master.beam_attack.damage_min = {
	3,
	7,
	13,
	20
}
b.towers.sunray_master.beam_attack.damage_max = {
	5,
	12,
	21,
	32
}
b.towers.sunray_master.beam_attack.cooldown = {
	0.5,
	0.5,
	0.5,
	0.5
}
b.towers.sunray_master.beam_attack.damage_type = DAMAGE_MAGICAL
b.towers.sunray_master.beam_attack.duration = fts(30)
b.towers.sunray_master.beam_attack.cycle_time = 0.25
b.towers.sunray_master.beam_attack.damage_radius = 55
b.towers.sunray_master.beam_attack.slow_factor = {
	0.8,
	0.8,
	0.8,
	0.8
}
b.towers.sunray_master.beam_attack.slow_duration = {
	1,
	1,
	1,
	1
}
b.towers.sunray_master.rapid_fire_attack = {}
b.towers.sunray_master.rapid_fire_attack.damage_min = {
	1,
	3,
	5,
	9
}
b.towers.sunray_master.rapid_fire_attack.damage_max = {
	3,
	7,
	13,
	16
}
b.towers.sunray_master.rapid_fire_attack.cooldown = {
	0.2,
	0.2,
	0.2,
	0.2
}
b.towers.sunray_master.rapid_fire_attack.damage_type = DAMAGE_MAGICAL
b.towers.sunray_master.rapid_fire_attack.number_of_attacks = 4
b.towers.sunray_master.skill_a = {}
b.towers.sunray_master.skill_a.price = {
	200,
	100,
	50
}
b.towers.sunray_master.skill_a.rally_range = 150
b.towers.sunray_master.skill_a.max_soldiers = {
	2,
	2,
	2
}
b.towers.sunray_master.skill_a.soldier = {}
b.towers.sunray_master.skill_a.soldier.hp = {
	100,
	140,
	180
}
b.towers.sunray_master.skill_a.soldier.armor = {
	0.15,
	0.2,
	0.25
}
b.towers.sunray_master.skill_a.soldier.dead_lifetime = {
	12,
	12,
	12
}
b.towers.sunray_master.skill_a.soldier.regen_hp = {
	8,
	10,
	11
}
b.towers.sunray_master.skill_a.soldier.speed = 60
b.towers.sunray_master.skill_a.soldier.basic_attack = {}
b.towers.sunray_master.skill_a.soldier.basic_attack.damage_min = {
	3,
	4,
	5
}
b.towers.sunray_master.skill_a.soldier.basic_attack.damage_max = {
	5,
	6,
	7
}
b.towers.sunray_master.skill_a.soldier.basic_attack.cooldown = 2
b.towers.sunray_master.skill_a.soldier.basic_attack.range = 70
b.towers.sunray_master.skill_b = {}
b.towers.sunray_master.skill_b.price = {
	150,
	150,
	150
}
b.towers.sunray_master.skill_b.radius = {
	200,
	200,
	200
}
b.towers.sunray_master.skill_b.damage_min = {
	16,
	32,
	48
}
b.towers.sunray_master.skill_b.damage_max = {
	24,
	48,
	72
}
b.towers.sunray_master.skill_b.slow_factor = {
	0.8,
	0.7,
	0.6
}
b.towers.sunray_master.skill_b.s_slow_factor = {
	0.2,
	0.3,
	0.4
}
b.towers.sunray_master.skill_b.slow_duration = {
	3,
	3,
	3
}
b.towers.sunray_master.skill_c = {}
b.towers.sunray_master.skill_c.price = {
	100,
	100,
	100
}
b.towers.sunray_master.skill_c.dmg_factor = {
	1.4,
	1.7,
	2
}
b.towers.sunray_master.skill_c.s_dmg_factor = sub_one(b.towers.sunray_master.skill_c.dmg_factor)
b.towers.sunray_master.skill_c.armor_red = {
	0.02,
	0.03,
	0.04
}
b.towers.sunray_master.skill_c.rate = 4
b.towers.sunray_master.ultimate = {}
b.towers.sunray_master.ultimate.damage_min = 36
b.towers.sunray_master.ultimate.damage_max = 64
b.towers.sunray_master.ultimate.damage_type = DAMAGE_MAGICAL
b.towers.sunray_master.ultimate.damage_radius = 75
b.towers.sunray_master.ultimate.range = 200
b.towers.sunray_master.ultimate.number_of_beams = 4
b.towers.sunray_master.ultimate.min_targets = 3
b.towers.sunray_master.ultimate.cooldown = 40
b.towers.sunray_master.ultimate.delay_between_shots = fts(5)
b.towers.sunray_master.ultimate.stun = {}
b.towers.sunray_master.ultimate.stun.duration = 2
b.towers.sunray_master.ultimate.min_spread = 75
b.towers.sunray_master.ultimate.max_spread = 100
b.towers.wildcat = {}
b.towers.wildcat.price = {
	80,
	130,
	190,
	260
}
b.towers.wildcat.stats = {}
b.towers.wildcat.stats.damage = 1.5
b.towers.wildcat.stats.hp = 8
b.towers.wildcat.stats.armor = 1.5
b.towers.wildcat.rally_range = 150
b.towers.wildcat.max_soldiers = 2
b.towers.wildcat.soldier = {}
b.towers.wildcat.soldier.hp = {
	80,
	120,
	160,
	220
}
b.towers.wildcat.soldier.armor = {
	0,
	0.05,
	0.1,
	0.15
}
b.towers.wildcat.soldier.dead_lifetime = 12
b.towers.wildcat.soldier.regen_hp = {
	6,
	8,
	11,
	15
}
b.towers.wildcat.soldier.speed = 75
b.towers.wildcat.soldier.extra_speed = 55
b.towers.wildcat.soldier.min_distance_extra_speed = 75
b.towers.wildcat.soldier.basic_attack = {}
b.towers.wildcat.soldier.basic_attack.damage_min = {
	3,
	7,
	10,
	16
}
b.towers.wildcat.soldier.basic_attack.damage_max = {
	5,
	10,
	14,
	20
}
b.towers.wildcat.soldier.basic_attack.damage_type = DAMAGE_PHYSICAL
b.towers.wildcat.soldier.basic_attack.cooldown = 1
b.towers.wildcat.soldier.basic_attack.range = 70
b.towers.wildcat.soldier.ranged_attack = {}
b.towers.wildcat.soldier.ranged_attack.damage_min = {
	3,
	7,
	10,
	16
}
b.towers.wildcat.soldier.ranged_attack.damage_max = {
	5,
	10,
	14,
	20
}
b.towers.wildcat.soldier.ranged_attack.damage_type = DAMAGE_PHYSICAL
b.towers.wildcat.soldier.ranged_attack.cooldown = 1
b.towers.wildcat.soldier.ranged_attack.min_range = 50
b.towers.wildcat.soldier.ranged_attack.max_range = 175
b.towers.wildcat.skill_a = {}
b.towers.wildcat.skill_a.price = {
	120,
	120,
	120
}
b.towers.wildcat.skill_a.cooldown = {
	15,
	15,
	15
}
b.towers.wildcat.skill_a.min_range = 0
b.towers.wildcat.skill_a.max_range = 150
b.towers.wildcat.skill_a.min_targets = 2
b.towers.wildcat.skill_a.damage_min = {
	18,
	32,
	38
}
b.towers.wildcat.skill_a.damage_max = {
	28,
	46,
	56
}
b.towers.wildcat.skill_a.damage_type = DAMAGE_PHYSICAL
b.towers.wildcat.skill_a.max_bounces = {
	2,
	3,
	4
}
b.towers.wildcat.skill_a.bounce_range = {
	100,
	100,
	100
}
b.towers.wildcat.skill_a.bounce_damage_mult = {
	1,
	1,
	1,
	1
}
b.towers.wildcat.skill_a.bounce_speed_mult = 1
b.towers.wildcat.skill_b = {}
b.towers.wildcat.skill_b.price = {
	160,
	160,
	160
}
b.towers.wildcat.skill_b.cooldown = {
	12,
	12,
	12
}
b.towers.wildcat.skill_b.damage_min = {
	27,
	80,
	134
}
b.towers.wildcat.skill_b.damage_max = {
	42,
	120,
	200
}
b.towers.wildcat.skill_b.damage_type = DAMAGE_PHYSICAL
b.towers.wildcat.skill_b.bleed = {}
b.towers.wildcat.skill_b.bleed.cycle_time = 0.25
b.towers.wildcat.skill_b.bleed.damage_min = {
	3,
	4,
	5
}
b.towers.wildcat.skill_b.bleed.damage_max = {
	3,
	4,
	5
}
b.towers.wildcat.skill_b.bleed.s_damage = {
	48,
	64,
	80
}
b.towers.wildcat.skill_b.bleed.duration = {
	4,
	4,
	4
}
b.towers.wildcat.skill_c = {}
b.towers.wildcat.skill_c.price = {
	180,
	180,
	180
}
b.towers.wildcat.skill_c.cooldown = {
	18,
	18,
	18
}
b.towers.wildcat.skill_c.damage_min = {
	14,
	24,
	30
}
b.towers.wildcat.skill_c.damage_max = {
	22,
	34,
	44
}
b.towers.wildcat.skill_c.damage_type = DAMAGE_PHYSICAL
b.towers.wildcat.skill_c.damage_radius = 35
b.towers.wildcat.skill_c.min_range = 75
b.towers.wildcat.skill_c.max_range = 150
b.towers.wildcat.skill_c.arrow_count = {
	8,
	10,
	12
}
b.towers.wildcat.skill_c.min_targets = 3
b.towers.wildcat.skill_c.nodes_between_arrows = 0.5
b.towers.wildcat.ultimate = {}
b.towers.wildcat.ultimate.cooldown = 35
b.towers.wildcat.ultimate.range = 150
b.towers.wildcat.ultimate.damage_min = 160
b.towers.wildcat.ultimate.damage_max = 240
b.towers.wildcat.ultimate.damage_type = DAMAGE_PHYSICAL
b.towers.wildcat.ultimate.number_of_attacks = 4
b.towers.wildcat.ultimate.time_between_attacks = fts(8)
b.towers.light_priestess = {}
b.towers.light_priestess.price = {
	90,
	130,
	200,
	260
}
b.towers.light_priestess.stats = {}
b.towers.light_priestess.stats.damage = 4.5
b.towers.light_priestess.stats.range = 4
b.towers.light_priestess.stats.cooldown = 8
b.towers.light_priestess.basic_attack = {}
b.towers.light_priestess.basic_attack.damage_min = {
	5,
	13,
	25,
	37
}
b.towers.light_priestess.basic_attack.damage_max = {
	10,
	24,
	46,
	69
}
b.towers.light_priestess.basic_attack.damage_type = DAMAGE_MAGICAL
b.towers.light_priestess.basic_attack.cooldown = 1.25
b.towers.light_priestess.basic_attack.range = {
	160,
	170,
	180,
	190
}
b.towers.light_priestess.passive = {}
b.towers.light_priestess.passive.armor_inc = {
	0.1,
	0.15,
	0.2,
	0.25
}
b.towers.light_priestess.passive.duration = 0.1
b.towers.light_priestess.passive.range = {
	160,
	170,
	180,
	190
}
b.towers.light_priestess.skill_a = {}
b.towers.light_priestess.skill_a.price = {
	200,
	200,
	200
}
b.towers.light_priestess.skill_a.cooldown = {
	16,
	16,
	16
}
b.towers.light_priestess.skill_a.range = 190
b.towers.light_priestess.skill_a.duration = {
	4,
	4,
	4
}
b.towers.light_priestess.skill_a.armor_inc = {
	0.1,
	0.2,
	0.3
}
b.towers.light_priestess.skill_a.heal_every = 0.25
b.towers.light_priestess.skill_a.heal_per_second_min = {
	24,
	32,
	48
}
b.towers.light_priestess.skill_a.heal_per_second_max = {
	24,
	32,
	48
}
b.towers.light_priestess.skill_a.s_total_heal = {
	96,
	128,
	192
}
b.towers.light_priestess.skill_a.heal_threshold = {
	0.6,
	0.6,
	0.6
}
b.towers.light_priestess.skill_b = {}
b.towers.light_priestess.skill_b.price = {
	120,
	120,
	120
}
b.towers.light_priestess.skill_b.cooldown = {
	22,
	22,
	22
}
b.towers.light_priestess.skill_b.range = 190
b.towers.light_priestess.skill_b.min_targets = 2
b.towers.light_priestess.skill_b.slow_factor = {
	0.6,
	0.6,
	0.6
}
b.towers.light_priestess.skill_b.s_slow_factor = {
	0.4,
	0.4,
	0.4
}
b.towers.light_priestess.skill_b.slow_duration = {
	6,
	8,
	10
}
b.towers.light_priestess.skill_b.silence_duration = {
	6,
	8,
	10
}
b.towers.light_priestess.skill_c = {}
b.towers.light_priestess.skill_c.price = {
	150,
	150,
	150
}
b.towers.light_priestess.skill_c.cooldown = {
	18,
	18,
	18
}
b.towers.light_priestess.skill_c.range = 300
b.towers.light_priestess.skill_c.dmg_factor = {
	1.5,
	1.75,
	2
}
b.towers.light_priestess.skill_c.s_dmg_factor = {
	sub_one(b.towers.light_priestess.skill_c.dmg_factor[1]),
	sub_one(b.towers.light_priestess.skill_c.dmg_factor[2]),
	sub_one(b.towers.light_priestess.skill_c.dmg_factor[3])
}
b.towers.light_priestess.skill_c.dmg_inc_duration = {
	5,
	7,
	9
}
b.towers.light_priestess.skill_c.detection_range = {
	375,
	375,
	375
}
b.towers.light_priestess.ultimate = {}
b.towers.light_priestess.ultimate.cooldown = 37
b.towers.light_priestess.ultimate.range = 190
b.towers.light_priestess.ultimate.duration = 5
b.towers.light_priestess.ultimate.damage_min = 20
b.towers.light_priestess.ultimate.damage_max = 30
b.towers.light_priestess.ultimate.s_damage_min = 400
b.towers.light_priestess.ultimate.s_damage_max = 600
b.towers.light_priestess.ultimate.damage_type = DAMAGE_MAGICAL
b.towers.light_priestess.ultimate.cycle_time = 0.25
b.towers.light_priestess.ultimate.armor_red = 0.015
b.towers.light_priestess.ultimate.invulnerability_duration = 0.5
b.towers.tree = {}
b.towers.tree.price = {
	140,
	180,
	230,
	300
}
b.towers.tree.stats = {}
b.towers.tree.stats.damage = 4.5
b.towers.tree.stats.range = 2.5
b.towers.tree.stats.cooldown = 5
b.towers.tree.rally_range = 160
b.towers.tree.soldier = {}
b.towers.tree.soldier.armor = {
	0.1,
	0.1,
	0.15,
	0.15
}
b.towers.tree.soldier.dead_lifetime = 20
b.towers.tree.soldier.hp = {
	500,
	700,
	900,
	1100
}
b.towers.tree.soldier.regen_hp = {
	40,
	56,
	72,
	88
}
b.towers.tree.soldier.speed = 30
b.towers.tree.soldier.basic_attack = {}
b.towers.tree.soldier.basic_attack.damage_min = {
	8,
	19,
	35,
	56
}
b.towers.tree.soldier.basic_attack.damage_max = {
	12,
	29,
	53,
	84
}
b.towers.tree.soldier.basic_attack.damage_type = DAMAGE_EXPLOSION
b.towers.tree.soldier.basic_attack.damage_radius = 50
b.towers.tree.soldier.basic_attack.cooldown = 3
b.towers.tree.soldier.basic_attack.range = 70
b.towers.tree.basic_attack = {}
b.towers.tree.basic_attack.damage_min = {
	8,
	19,
	33,
	50
}
b.towers.tree.basic_attack.damage_max = {
	12,
	29,
	50,
	75
}
b.towers.tree.basic_attack.damage_radius = {
	160,
	160,
	160,
	160
}
b.towers.tree.basic_attack.damage_type = DAMAGE_EXPLOSION
b.towers.tree.basic_attack.cooldown = 3
b.towers.tree.basic_attack.range = {
	160,
	160,
	160,
	160
}
b.towers.tree.skill_a = {}
b.towers.tree.skill_a.price = {
	150,
	100,
	100
}
b.towers.tree.skill_a.cooldown = {
	20,
	20,
	20
}
b.towers.tree.skill_a.min_targets = 3
b.towers.tree.skill_a.range = 160
b.towers.tree.skill_a.aura = {}
b.towers.tree.skill_a.aura.radius_tower = 160
b.towers.tree.skill_a.aura.radius_unit = 50
b.towers.tree.skill_a.aura.range_unit = 160
b.towers.tree.skill_a.aura.duration = 0.3
b.towers.tree.skill_a.aura.cycle_time = 0.29
b.towers.tree.skill_a.blind = {}
b.towers.tree.skill_a.blind.damage_min = {
	2,
	3,
	4
}
b.towers.tree.skill_a.blind.damage_max = {
	2,
	3,
	4
}
b.towers.tree.skill_a.blind.s_damage = {
	32,
	72,
	128
}
b.towers.tree.skill_a.blind.damage_type = DAMAGE_TRUE
b.towers.tree.skill_a.blind.damage_every = 0.25
b.towers.tree.skill_a.blind.damage_factor = 0.1
b.towers.tree.skill_a.blind.s_damage_factor = 0.9
b.towers.tree.skill_a.blind.duration = {
	4,
	6,
	8
}
b.towers.tree.skill_b = {}
b.towers.tree.skill_b.price = {
	200,
	100,
	100
}
b.towers.tree.skill_b.cooldown = {
	25,
	25,
	25
}
b.towers.tree.skill_b.damage_type = DAMAGE_INSTAKILL
b.towers.tree.skill_b.min_hp_max = {
	0,
	0,
	0
}
b.towers.tree.skill_b.max_hp_max = {
	1500,
	2000,
	2800
}
b.towers.tree.skill_c = {}
b.towers.tree.skill_c.price = {
	150,
	100,
	100
}
b.towers.tree.skill_c.cooldown = {
	14,
	14,
	14
}
b.towers.tree.skill_c.range = 160
b.towers.tree.skill_c.min_targets = 2
b.towers.tree.skill_c.aura = {}
b.towers.tree.skill_c.aura.duration = 0.1
b.towers.tree.skill_c.aura.radius = 160
b.towers.tree.skill_c.aura.cycle_time = 0.09
b.towers.tree.skill_c.aura.max_targets = {
	4,
	5,
	6
}
b.towers.tree.skill_c.root = {}
b.towers.tree.skill_c.root.duration = {
	2,
	3,
	4
}
b.towers.tree.ultimate = {}
b.towers.tree.ultimate.cooldown = 35
b.towers.tree.ultimate.range = 160
b.towers.tree.ultimate.damage_min = 80
b.towers.tree.ultimate.damage_max = 120
b.towers.tree.ultimate.damage_type = DAMAGE_EXPLOSION
b.towers.tree.ultimate.damage_radius = 80
b.towers.tree.ultimate.seedling_spawn_count = 3
b.towers.tree.ultimate.seedling = {}
b.towers.tree.ultimate.seedling.duration = 25
b.towers.tree.ultimate.seedling.armor = 0
b.towers.tree.ultimate.seedling.dead_lifetime = 2
b.towers.tree.ultimate.seedling.hp = 60
b.towers.tree.ultimate.seedling.regen_hp = 5
b.towers.tree.ultimate.seedling.speed = 50
b.towers.tree.ultimate.seedling.basic_attack = {}
b.towers.tree.ultimate.seedling.basic_attack.damage_min = 6
b.towers.tree.ultimate.seedling.basic_attack.damage_max = 10
b.towers.tree.ultimate.seedling.basic_attack.damage_type = DAMAGE_PHYSICAL
b.towers.tree.ultimate.seedling.basic_attack.cooldown = 1
b.towers.tree.ultimate.seedling.basic_attack.range = 70
b.towers.alchemist = {}
b.towers.alchemist.price = {
	100,
	150,
	220,
	300
}
b.towers.alchemist.stats = {}
b.towers.alchemist.stats.damage = 8
b.towers.alchemist.stats.range = 2.5
b.towers.alchemist.stats.cooldown = 8.5
b.towers.alchemist.basic_attack = {}
b.towers.alchemist.basic_attack.range = {
	160,
	160,
	160,
	160
}
b.towers.alchemist.basic_attack.damage_min = {
	1,
	2,
	3,
	4
}
b.towers.alchemist.basic_attack.damage_max = {
	2,
	3,
	4,
	5
}
b.towers.alchemist.basic_attack.damage_radius = 48
b.towers.alchemist.basic_attack.damage_type = DAMAGE_TRUE
b.towers.alchemist.basic_attack.cycle_time = 0.3
b.towers.alchemist.basic_attack.cooldown = 0.94
b.towers.alchemist.basic_attack.duration = {
	2,
	3,
	4,
	5
}
b.towers.alchemist.basic_attack.slow_factor = {
	0.6,
	0.6,
	0.6,
	0.6
}
b.towers.alchemist.basic_attack.slow_duration = {
	0.5,
	0.5,
	0.5,
	0.5
}
b.towers.alchemist.skill_a = {}
b.towers.alchemist.skill_a.price = {
	100,
	100,
	100
}
b.towers.alchemist.skill_a.cooldown = {
	15,
	15,
	15
}
b.towers.alchemist.skill_a.min_targets = 3
b.towers.alchemist.skill_a.min_detection_range = 50
b.towers.alchemist.skill_a.max_detection_range = 180
b.towers.alchemist.skill_a.projectile_count = {
	8,
	10,
	12
}
b.towers.alchemist.skill_a.slow_factor = {
	0.6,
	0.45,
	0.3
}
b.towers.alchemist.skill_a.s_slow_factor = {
	0.4,
	0.55,
	0.7
}
b.towers.alchemist.skill_a.slow_duration = {
	1,
	1,
	1
}
b.towers.alchemist.skill_a.slow_radius = 50
b.towers.alchemist.skill_a.cycle_time = 0.25
b.towers.alchemist.skill_a.duration = {
	5,
	6,
	7
}
b.towers.alchemist.skill_a.min_distance_between_shots = 5
b.towers.alchemist.skill_b = {}
b.towers.alchemist.skill_b.price = {
	150,
	150,
	150
}
b.towers.alchemist.skill_b.cooldown = {
	22,
	22,
	22
}
b.towers.alchemist.skill_b.max_range = 250
b.towers.alchemist.skill_b.min_targets = 1
b.towers.alchemist.skill_b.soldier = {}
b.towers.alchemist.skill_b.soldier.armor = {
	0,
	0,
	0
}
b.towers.alchemist.skill_b.soldier.magic_armor = {
	0,
	0,
	0
}
b.towers.alchemist.skill_b.soldier.hp = {
	150,
	180,
	210
}
b.towers.alchemist.skill_b.soldier.regen_hp = {
	10,
	13,
	16
}
b.towers.alchemist.skill_b.soldier.regen_cooldown = 1
b.towers.alchemist.skill_b.soldier.speed = 50
b.towers.alchemist.skill_b.soldier.duration = {
	30,
	30,
	30
}
b.towers.alchemist.skill_b.soldier.basic_attack = {}
b.towers.alchemist.skill_b.soldier.basic_attack.damage_min = {
	16,
	32,
	64
}
b.towers.alchemist.skill_b.soldier.basic_attack.damage_max = {
	24,
	48,
	96
}
b.towers.alchemist.skill_b.soldier.basic_attack.damage_type = DAMAGE_TRUE
b.towers.alchemist.skill_b.soldier.basic_attack.cooldown = 1.5
b.towers.alchemist.skill_b.soldier.basic_attack.melee_range = 70
b.towers.alchemist.skill_c = {}
b.towers.alchemist.skill_c.price = {
	200,
	200,
	200
}
b.towers.alchemist.skill_c.bullet = {}
b.towers.alchemist.skill_c.bullet.damage_min = {
	10,
	28,
	46
}
b.towers.alchemist.skill_c.bullet.damage_max = {
	16,
	46,
	68
}
b.towers.alchemist.skill_c.bullet.damage_radius = 50
b.towers.alchemist.skill_c.bullet.damage_type = DAMAGE_EXPLOSION
b.towers.alchemist.skill_c.area = {}
b.towers.alchemist.skill_c.area.damage_min = {
	5,
	6,
	7
}
b.towers.alchemist.skill_c.area.damage_max = {
	7,
	8,
	9
}
b.towers.alchemist.skill_c.area.damage_radius = 50
b.towers.alchemist.skill_c.area.damage_type = DAMAGE_TRUE
b.towers.alchemist.skill_c.area.cycle_time = 0.3
b.towers.alchemist.skill_c.area.duration = {
	5,
	5,
	5
}
b.towers.alchemist.skill_c.area.slow_factor = {
	0.6,
	0.6,
	0.6
}
b.towers.alchemist.skill_c.area.slow_duration = {
	0.5,
	0.5,
	0.5
}
b.towers.alchemist.ultimate = {}
b.towers.alchemist.ultimate.cooldown = 40
b.towers.alchemist.ultimate.detection_range = 160
b.towers.alchemist.ultimate.transform_range = 80
b.towers.alchemist.ultimate.polymorph_duration = 15
b.towers.alchemist.ultimate.min_total_hp = 300
b.towers.alchemist.ultimate.hp_cap = 600
b.towers.alchemist.ultimate.gold_pig = {}
b.towers.alchemist.ultimate.gold_pig.extra_gold = 15
b.towers.alchemist.ultimate.gold_pig.armor = 0
b.towers.alchemist.ultimate.gold_pig.magic_armor = 0
b.towers.miners = {}
b.towers.miners.global = {}
b.towers.miners.global.gold_cap_per_wave = 300
b.towers.miners.price = {
	120,
	160,
	220,
	300
}
b.towers.miners.stats = {}
b.towers.miners.stats.damage = 1
b.towers.miners.stats.hp = 2.5
b.towers.miners.stats.armor = 0
b.towers.miners.rally_range = 160
b.towers.miners.max_soldiers = 8
b.towers.miners.spawn_soldier_interval = 5
b.towers.miners.boss_spawn_soldier_interval = 6
b.towers.miners.soldier = {}
b.towers.miners.soldier.armor = {
	0,
	0,
	0,
	0
}
b.towers.miners.soldier.dead_lifetime = 3
b.towers.miners.soldier.hp = {
	40,
	60,
	90,
	120
}
b.towers.miners.soldier.regen_hp = {
	4,
	5,
	7,
	10
}
b.towers.miners.soldier.speed = 75
b.towers.miners.soldier.tunneling_time = 0.6
b.towers.miners.soldier.basic_attack = {}
b.towers.miners.soldier.basic_attack.damage_min = {
	3,
	4,
	7,
	10
}
b.towers.miners.soldier.basic_attack.damage_max = {
	5,
	7,
	11,
	15
}
b.towers.miners.soldier.basic_attack.cooldown = 1
b.towers.miners.soldier.basic_attack.range = 70
b.towers.miners.gold_generation = {}
b.towers.miners.gold_generation.min_gold = {
	1,
	1,
	2,
	2
}
b.towers.miners.gold_generation.max_gold = {
	2,
	3,
	3,
	4
}
b.towers.miners.gold_generation.tick_cooldown = {
	3,
	3,
	3,
	3
}
b.towers.miners.gold_generation.max_gold_cap = 100000
b.towers.miners.skill_a = {}
b.towers.miners.skill_a.price = {
	150,
	150,
	150
}
b.towers.miners.skill_a.cooldown = {
	20,
	20,
	20
}
b.towers.miners.skill_a.max_range = 500
b.towers.miners.skill_a.min_targets = 2
b.towers.miners.skill_a.cart = {}
b.towers.miners.skill_a.cart.speed = 120
b.towers.miners.skill_a.cart.hit_radius = 40
b.towers.miners.skill_a.cart.damage_min = {
	18,
	40,
	52
}
b.towers.miners.skill_a.cart.damage_max = {
	28,
	60,
	78
}
b.towers.miners.skill_a.cart.damage_radius = 80
b.towers.miners.skill_a.cart.max_nodes = 80
b.towers.miners.skill_a.soldier = {}
b.towers.miners.skill_a.soldier.hp = {
	50,
	65,
	90
}
b.towers.miners.skill_a.soldier.armor = {
	0,
	0,
	0
}
b.towers.miners.skill_a.soldier.regen_hp = {
	3,
	5,
	6
}
b.towers.miners.skill_a.soldier.duration = {
	15,
	15,
	15
}
b.towers.miners.skill_a.soldier.speed = 50
b.towers.miners.skill_a.soldier.basic_attack = {}
b.towers.miners.skill_a.soldier.basic_attack.damage_min = {
	3,
	4,
	7
}
b.towers.miners.skill_a.soldier.basic_attack.damage_max = {
	5,
	7,
	11
}
b.towers.miners.skill_a.soldier.basic_attack.cooldown = 1
b.towers.miners.skill_a.soldier.basic_attack.melee_range = 70
b.towers.miners.skill_b = {}
b.towers.miners.skill_b.price = {
	200,
	200,
	200
}
b.towers.miners.skill_b.aura = {}
b.towers.miners.skill_b.aura.damage_min = {
	8,
	20,
	32
}
b.towers.miners.skill_b.aura.damage_max = {
	12,
	30,
	48
}
b.towers.miners.skill_b.aura.damage_type = DAMAGE_PHYSICAL
b.towers.miners.skill_b.aura.radius = 45
b.towers.miners.skill_b.stun = {}
b.towers.miners.skill_b.stun.duration = {
	1,
	1.5,
	2
}
b.towers.miners.skill_c = {}
b.towers.miners.skill_c.price = {
	250,
	100,
	100
}
b.towers.miners.skill_c.gold_factor = {
	1,
	1.5,
	2
}
b.towers.miners.ultimate = {}
b.towers.miners.ultimate.cooldown = 50
b.towers.miners.ultimate.duration = 1.5
b.towers.miners.ultimate.tick_cooldown = 0.5
b.towers.miners.ultimate.min_gold = 18
b.towers.miners.ultimate.max_gold = 24
b.towers.miners.ultimate.s_min_gold = b.towers.miners.ultimate.min_gold * 4
b.towers.miners.ultimate.s_max_gold = b.towers.miners.ultimate.max_gold * 4
b.towers.miners.ultimate.skill_c_cooldown_factor = 1
b.towers.forger = {}
b.towers.forger.shared_min_cooldown = 2
b.towers.forger.price = {
	120,
	160,
	220,
	280
}
b.towers.forger.stats = {}
b.towers.forger.stats.damage = 6.5
b.towers.forger.stats.range = 4
b.towers.forger.stats.cooldown = 7
b.towers.forger.basic_attack = {}
b.towers.forger.basic_attack.cooldown = 0.57
b.towers.forger.basic_attack.range = {
	160,
	170,
	180,
	190
}
b.towers.forger.basic_attack.damage_min = {
	8,
	18,
	38,
	56
}
b.towers.forger.basic_attack.damage_max = {
	14,
	36,
	58,
	88
}
b.towers.forger.basic_attack.damage_type = DAMAGE_MAGICAL
b.towers.forger.basic_attack.damage_radius = 50
b.towers.forger.skill_a = {}
b.towers.forger.skill_a.price = {
	250,
	250,
	250
}
b.towers.forger.skill_a.cooldown = {
	18,
	18,
	18
}
b.towers.forger.skill_a.detection_range = 180
b.towers.forger.skill_a.damage_min = {
	30,
	60,
	90
}
b.towers.forger.skill_a.damage_max = {
	45,
	90,
	135
}
b.towers.forger.skill_a.s_damage_min = {
	60,
	120,
	180
}
b.towers.forger.skill_a.s_damage_max = {
	90,
	180,
	270
}
b.towers.forger.skill_a.damage_radius = 30
b.towers.forger.skill_a.damage_type = DAMAGE_MAGICAL
b.towers.forger.skill_a.cycle_time = 0.25
b.towers.forger.skill_a.min_targets = 2
b.towers.forger.skill_a.disc_speed = 120
b.towers.forger.skill_a.distance = 60
b.towers.forger.skill_a.max_spawn_distance = 220
b.towers.forger.skill_a.distance_from_enemy = 8
b.towers.forger.skill_b = {}
b.towers.forger.skill_b.price = {
	160,
	160,
	160
}
b.towers.forger.skill_b.cooldown = {
	20,
	20,
	20
}
b.towers.forger.skill_b.crystals = 2
b.towers.forger.skill_b.detection_range = 190
b.towers.forger.skill_b.min_targets = 1
b.towers.forger.skill_b.spawn_distance = 5
b.towers.forger.skill_b.crystal = {}
b.towers.forger.skill_b.crystal.detection_range = 120
b.towers.forger.skill_b.crystal.damage_min = {
	8,
	16,
	24
}
b.towers.forger.skill_b.crystal.damage_max = {
	12,
	24,
	36
}
b.towers.forger.skill_b.crystal.s_damage_min = {
	32,
	64,
	96
}
b.towers.forger.skill_b.crystal.s_damage_max = {
	48,
	96,
	144
}
b.towers.forger.skill_b.crystal.damage_type = DAMAGE_MAGICAL
b.towers.forger.skill_b.crystal.duration = {
	10,
	10,
	10
}
b.towers.forger.skill_b.crystal.max_damage = {
	100,
	200,
	300
}
b.towers.forger.skill_b.crystal.cycle_time = 0.25
b.towers.forger.skill_c = {}
b.towers.forger.skill_c.price = {
	200,
	200,
	200
}
b.towers.forger.skill_c.cooldown = {
	26,
	26,
	26
}
b.towers.forger.skill_c.stun_duration = {
	5,
	7,
	9
}
b.towers.forger.skill_c.detection_range = 120
b.towers.forger.skill_c.min_targets = {
	2,
	2,
	2
}
b.towers.forger.skill_c.max_targets = {
	2,
	3,
	4
}
b.towers.forger.ultimate = {}
b.towers.forger.ultimate.damage = 1000
b.towers.forger.ultimate.cooldown = 40
b.towers.forger.ultimate.detection_range = 180
b.towers.forger.ultimate.radius = 50
b.towers.forger.ultimate.stun_duration = 0.5
b.towers.forger.ultimate.min_total_hp = 300
b.towers.forger.ultimate.hp_cap = 1200
b.towers.forger.ultimate.grouping_range = 80
b.towers.crossbows = {}
b.towers.crossbows.price = {
	90,
	110,
	170,
	250
}
b.towers.crossbows.stats = {}
b.towers.crossbows.stats.damage = 6
b.towers.crossbows.stats.range = 4
b.towers.crossbows.stats.cooldown = 7.5
b.towers.crossbows.basic_attack = {}
b.towers.crossbows.basic_attack.damage_min = {
	2,
	6,
	12,
	18
}
b.towers.crossbows.basic_attack.damage_max = {
	5,
	10,
	18,
	28
}
b.towers.crossbows.basic_attack.cooldown = 0.6
b.towers.crossbows.basic_attack.range = {
	160,
	170,
	180,
	190
}
b.towers.crossbows.basic_attack.damage_type = DAMAGE_PHYSICAL
b.towers.crossbows.basic_attack.retarget_range = 70
b.towers.crossbows.skill_a = {}
b.towers.crossbows.skill_a.price = {
	200,
	200,
	200
}
b.towers.crossbows.skill_a.cooldown = {
	25,
	25,
	25
}
b.towers.crossbows.skill_a.damage_min = {
	18,
	18,
	18
}
b.towers.crossbows.skill_a.damage_max = {
	28,
	28,
	28
}
b.towers.crossbows.skill_a.damage_type = DAMAGE_PHYSICAL
b.towers.crossbows.skill_a.min_targets = 1
b.towers.crossbows.skill_a.detection_range = 200
b.towers.crossbows.skill_a.duration = {
	4,
	6,
	9
}
b.towers.crossbows.skill_a.attack_cooldown = 0
b.towers.crossbows.skill_a.time_between_shots = fts(0)
b.towers.crossbows.skill_a.shots_per_attack = 1
b.towers.crossbows.skill_a.retarget_range = 45
b.towers.crossbows.skill_b = {}
b.towers.crossbows.skill_b.price = {
	150,
	150,
	150
}
b.towers.crossbows.skill_b.radius = 60
b.towers.crossbows.skill_b.slow_factor = {
	0.8,
	0.65,
	0.5
}
b.towers.crossbows.skill_b.s_slow_factor = {
	0.2,
	0.35,
	0.5
}
b.towers.crossbows.skill_b.slow_duration = {
	4,
	6,
	8
}
b.towers.crossbows.skill_b.weak_factor = {
	0.9,
	0.75,
	0.6
}
b.towers.crossbows.skill_b.boss_weak_factor = {
	0.95,
	0.9,
	0.85
}
b.towers.crossbows.skill_b.s_weak_factor = {
	0.1,
	0.25,
	0.4
}
b.towers.crossbows.skill_b.weak_factor_duration = {
	4,
	6,
	8
}
b.towers.crossbows.skill_b.mod_duration = 0.15
b.towers.crossbows.skill_c = {}
b.towers.crossbows.skill_c.price = {
	200,
	200,
	200
}
b.towers.crossbows.skill_c.cooldown = {
	20,
	20,
	20
}
b.towers.crossbows.skill_c.damage_min = {
	120,
	240,
	360
}
b.towers.crossbows.skill_c.damage_max = {
	180,
	360,
	540
}
b.towers.crossbows.skill_c.damage_type = DAMAGE_TRUE
b.towers.crossbows.skill_c.detection_range = 190
b.towers.crossbows.skill_c.instakill_chance = {
	0.1,
	0.25,
	0.4
}
b.towers.crossbows.ultimate = {}
b.towers.crossbows.ultimate.cooldown = 36
b.towers.crossbows.ultimate.detection_range = 140
b.towers.crossbows.ultimate.min_targets = 1
b.towers.crossbows.ultimate.soldier = {}
b.towers.crossbows.ultimate.soldier.armor = 0.8
b.towers.crossbows.ultimate.soldier.magic_armor = 0
b.towers.crossbows.ultimate.soldier.hp = 250
b.towers.crossbows.ultimate.soldier.regen_hp = 20
b.towers.crossbows.ultimate.soldier.regen_cooldown = 1
b.towers.crossbows.ultimate.soldier.speed = 50
b.towers.crossbows.ultimate.soldier.duration = 30
b.towers.crossbows.ultimate.soldier.basic_attack = {}
b.towers.crossbows.ultimate.soldier.basic_attack.damage_min = 32
b.towers.crossbows.ultimate.soldier.basic_attack.damage_max = 48
b.towers.crossbows.ultimate.soldier.basic_attack.damage_type = DAMAGE_PHYSICAL
b.towers.crossbows.ultimate.soldier.basic_attack.cooldown = 1.5
b.towers.crossbows.ultimate.soldier.basic_attack.melee_range = 70
b.towers.sniper = {}
b.towers.sniper.price = {
	100,
	140,
	180,
	250
}
b.towers.sniper.stats = {}
b.towers.sniper.stats.damage = 10
b.towers.sniper.stats.range = 10
b.towers.sniper.stats.cooldown = 1
b.towers.sniper.ignore_nodes_start = 10
b.towers.sniper.ignore_nodes_end = 5
b.towers.sniper.coordinated_targeting = true
b.towers.sniper.coordinated_wasted_damage_factor = 1.5
b.towers.sniper.basic_attack = {}
b.towers.sniper.basic_attack.damage_min = {
	26,
	65,
	114,
	174
}
b.towers.sniper.basic_attack.damage_max = {
	34,
	80,
	144,
	218
}
b.towers.sniper.basic_attack.damage_type = DAMAGE_PHYSICAL
b.towers.sniper.basic_attack.cooldown = 4
b.towers.sniper.basic_attack.min_range = {
	150,
	150,
	150,
	150
}
b.towers.sniper.basic_attack.max_range = {
	3000,
	3000,
	3000,
	3000
}
b.towers.sniper.basic_attack.crosshair_time = fts(30)
b.towers.sniper.basic_attack.crosshair_duration = 2
b.towers.sniper.basic_attack.max_retarget_range = 75
b.towers.sniper.skill_a = {}
b.towers.sniper.skill_a.price = {
	150,
	150,
	150
}
b.towers.sniper.skill_a.cd_red_factor = {
	0.25,
	0.25,
	0.25
}
b.towers.sniper.skill_a.damage_factor = {
	1.1,
	1.25,
	1.4
}
b.towers.sniper.skill_a.s_damage_factor = sub_one(b.towers.sniper.skill_a.damage_factor)
b.towers.sniper.skill_b = {}
b.towers.sniper.skill_b.price = {
	200,
	200,
	200
}
b.towers.sniper.skill_b.cooldown = {
	12,
	12,
	12
}
b.towers.sniper.skill_b.min_hp = {
	50,
	50,
	50
}
b.towers.sniper.skill_b.bleed = {}
b.towers.sniper.skill_b.bleed.duration = 4
b.towers.sniper.skill_b.bleed.cycle_time = 0.25
b.towers.sniper.skill_b.bleed.damage_min = {
	8,
	16,
	24
}
b.towers.sniper.skill_b.bleed.damage_max = {
	10,
	19,
	29
}
b.towers.sniper.skill_b.bleed.s_damage_min = {
	128,
	256,
	384
}
b.towers.sniper.skill_b.bleed.s_damage_max = {
	160,
	320,
	480
}
b.towers.sniper.skill_b.bleed.damage_type = DAMAGE_TRUE
b.towers.sniper.skill_c = {}
b.towers.sniper.skill_c.price = {
	180,
	180,
	180
}
b.towers.sniper.skill_c.cooldown = {
	6,
	6,
	6
}
b.towers.sniper.skill_c.damage_min = {
	22,
	46,
	68
}
b.towers.sniper.skill_c.damage_max = {
	30,
	58,
	88
}
b.towers.sniper.skill_c.s_damage_min = {
	66,
	138,
	204
}
b.towers.sniper.skill_c.s_damage_max = {
	90,
	177,
	264
}
b.towers.sniper.skill_c.damage_type = DAMAGE_PHYSICAL
b.towers.sniper.ultimate = {}
b.towers.sniper.ultimate.cooldown = 50
b.towers.sniper.ultimate.retarget_range = 75
b.towers.sniper.ultimate.time_between_shots = fts(20)
b.towers.sniper.ultimate.damage_factor = 1.1
b.towers.sniper.ultimate.s_damage_factor = sub_one(b.towers.sniper.ultimate.damage_factor)
b.towers.upgrades = {}
b.towers.upgrades.barracks = {}
b.towers.upgrades.barracks.l1 = {}
b.towers.upgrades.barracks.l1.hp_factor = 1.1
b.towers.upgrades.barracks.l1.s_hp_factor = sub_one(b.towers.upgrades.barracks.l1.hp_factor)
b.towers.upgrades.barracks.l2 = {}
b.towers.upgrades.barracks.l2.spawn_reduction = 2
b.towers.upgrades.barracks.l2.spawn_reduction_miners = 0.5
b.towers.upgrades.barracks.l3a = {}
b.towers.upgrades.barracks.l3a.dmg_factor = 1.3
b.towers.upgrades.barracks.l1.s_dmg_factor = sub_one(b.towers.upgrades.barracks.l3a.dmg_factor)
b.towers.upgrades.barracks.l3b = {}
b.towers.upgrades.barracks.l3b.hp_factor = 1.1
b.towers.upgrades.barracks.l3b.s_hp_factor = sub_one(b.towers.upgrades.barracks.l3b.hp_factor)
b.towers.upgrades.barracks.l3b.armor_inc = 0.1
b.towers.upgrades.barracks.l4a = {}
b.towers.upgrades.barracks.l4a.dmg_factor = 2
b.towers.upgrades.barracks.l4b = {}
b.towers.upgrades.barracks.l4b.hp_ptg_threshold = 0.25
b.towers.upgrades.barracks.l4b.dmg_received_factor = 0.8
b.towers.upgrades.barracks.l4b.s_dmg_received_factor = 0.2
b.towers.upgrades.archers = {}
b.towers.upgrades.archers.l1 = {}
b.towers.upgrades.archers.l1.range_factor = 1.1
b.towers.upgrades.archers.l1.s_range_factor = sub_one(b.towers.upgrades.archers.l1.range_factor)
b.towers.upgrades.archers.l2 = {}
b.towers.upgrades.archers.l2.dmg_factor = 1.1
b.towers.upgrades.archers.l2.s_dmg_factor = sub_one(b.towers.upgrades.archers.l2.dmg_factor)
b.towers.upgrades.archers.l3a = {}
b.towers.upgrades.archers.l3a.disabled_dmg_factor = 1.15
b.towers.upgrades.archers.l3a.s_disabled_dmg_factor = sub_one(b.towers.upgrades.archers.l3a.disabled_dmg_factor)
b.towers.upgrades.archers.l3b = {}
b.towers.upgrades.archers.l3b.attack_speed_factor = 0.9
b.towers.upgrades.archers.l3b.s_attack_speed_factor = slow_calc(b.towers.upgrades.archers.l3b.attack_speed_factor)
b.towers.upgrades.archers.l4a = {}
b.towers.upgrades.archers.l4a.double_dmg_chance = 0.12
b.towers.upgrades.archers.l4b = {}
b.towers.upgrades.mages = {}
b.towers.upgrades.mages.l1 = {}
b.towers.upgrades.mages.l1.min_dmg_factor = 1.15
b.towers.upgrades.mages.l1.s_min_dmg_factor = sub_one(b.towers.upgrades.mages.l1.min_dmg_factor)
b.towers.upgrades.mages.l2 = {}
b.towers.upgrades.mages.l2.build_cost_red_factor = 0.9
b.towers.upgrades.mages.l2.s_build_cost_red_factor = slow_calc(b.towers.upgrades.mages.l2.build_cost_red_factor)
b.towers.upgrades.mages.l3a = {}
b.towers.upgrades.mages.l3a.skill_cost_red_factor = 0.85
b.towers.upgrades.mages.l3a.s_skill_cost_red_factor = slow_calc(b.towers.upgrades.mages.l3a.skill_cost_red_factor)
b.towers.upgrades.mages.l3b = {}
b.towers.upgrades.mages.l3b.range_factor = 1.1
b.towers.upgrades.mages.l3b.s_range_factor = sub_one(b.towers.upgrades.mages.l3b.range_factor)
b.towers.upgrades.mages.l3b.dmg_factor = 1.1
b.towers.upgrades.mages.l3b.s_dmg_factor = sub_one(b.towers.upgrades.mages.l3b.dmg_factor)
b.towers.upgrades.mages.l4a = {}
b.towers.upgrades.mages.l4a.skills_cd_red_factor = 0.8
b.towers.upgrades.mages.l4a.s_skills_cd_red_factor = slow_calc(b.towers.upgrades.mages.l4a.skills_cd_red_factor)
b.towers.upgrades.mages.l4b = {}
b.towers.upgrades.mages.l4b.dmg_factors = {
	1,
	1.04,
	1.08,
	1.12,
	1.16,
	1.2,
	1.24,
	1.28,
	1.32
}
b.towers.upgrades.mages.l4b.s_dmg_factors = 0.04
b.towers.upgrades.mages.l4b.s_dmg_factors_max = 0.32
b.towers.upgrades.artillery = {}
b.towers.upgrades.artillery.l1 = {}
b.towers.upgrades.artillery.l1.area_inc_factor = 1.1
b.towers.upgrades.artillery.l1.s_area_inc_factor = sub_one(b.towers.upgrades.artillery.l1.area_inc_factor)
b.towers.upgrades.artillery.l2 = {}
b.towers.upgrades.artillery.l2.dmg_factor = 1.1
b.towers.upgrades.artillery.l2.s_dmg_factor = sub_one(b.towers.upgrades.artillery.l2.dmg_factor)
b.towers.upgrades.artillery.l3a = {}
b.towers.upgrades.artillery.l3a.attack_speed_factor = 0.9
b.towers.upgrades.artillery.l3a.s_attack_speed_factor = slow_calc(b.towers.upgrades.artillery.l3a.attack_speed_factor)
b.towers.upgrades.artillery.l3b = {}
b.towers.upgrades.artillery.l3b.armor_ignore_factor = 0.75
b.towers.upgrades.artillery.l4a = {}
b.towers.upgrades.artillery.l4a.stun_duration = 0.25
b.towers.upgrades.artillery.l4b = {}
b.towers.upgrades.artillery.l4b.range_inc_factor = 1.1
b.towers.upgrades.artillery.l4b.s_range_inc_factor = sub_one(b.towers.upgrades.artillery.l4b.range_inc_factor)
b.towers.upgrades.artillery.l4b.dmg_factor = 1.15
b.towers.upgrades.artillery.l4b.s_dmg_factor = sub_one(b.towers.upgrades.artillery.l4b.dmg_factor)
b.specials = {}
b.specials.terrain_1 = {}
b.specials.terrain_1.blocked_holders = {}
b.specials.terrain_1.blocked_holders.price = 60
b.specials.stage_01 = {}
b.specials.stage_01.tutorial_bandit = {}
b.specials.stage_01.tutorial_bandit.hp = 24
b.specials.stage_01.tutorial_bandit.speed = 48
b.specials.stage_01.king = {}
b.specials.stage_01.king.bullet = {}
b.specials.stage_01.king.bullet.damage_min = 80
b.specials.stage_01.king.bullet.damage_max = 120
b.specials.stage_01.king.bullet.damage_radius = 50
b.specials.stage_01.king.bullet.cooldown = 2
b.specials.stage_01.king.bullet.variation_chances = {
	0.3,
	0.6,
	0.1
}
b.specials.stage_02 = {}
b.specials.stage_02.teleport = {}
b.specials.stage_02.teleport.cooldown = 35
b.specials.stage_02.teleport.nodes_teleport = 50
b.specials.stage_02.teleport.radius = 40
b.specials.stage_02.teleport.max_targets = 4
b.specials.stage_03 = {}
b.specials.stage_03.jenkins = {}
b.specials.stage_03.jenkins.speed = 100
b.specials.stage_03.jenkins.damage_min = 25
b.specials.stage_03.jenkins.damage_max = 35
b.specials.stage_03.jenkins.damage_type = DAMAGE_TRUE
b.specials.stage_03.jenkins.radius = 60
b.specials.stage_03.fisherman = {}
b.specials.stage_03.fisherman.reward = 20
b.specials.stage_05 = {}
b.specials.stage_05.tree = {}
b.specials.stage_05.tree.cooldown = 25
b.specials.stage_05.tree.cooldown_iron = 10
b.specials.stage_05.tree.damage_min = 20
b.specials.stage_05.tree.damage_max = 40
b.specials.stage_05.tree.damage_type = DAMAGE_TRUE
b.specials.stage_05.tree.radius = 260
b.specials.stage_05.tree.stun_duration = 4
b.specials.stage_05.tree.cat_hp_buff = 1.5
b.specials.stage_05.tree.cat_dmg_buff = 2
b.specials.stage_05.tree.alleria_speed_buff = 2
b.specials.stage_05.tree.alleria_regen_buff = 2.5
b.specials.stage_05.tree.alleria_multishots_buff = 5
b.specials.stage_06 = {}
b.specials.stage_06.nivus = {}
b.specials.stage_06.nivus.delay_between_spells = 15
b.specials.stage_06.nivus.magic_missiles = {}
b.specials.stage_06.nivus.magic_missiles.cooldown = 17
b.specials.stage_06.nivus.magic_missiles.min_range = 0
b.specials.stage_06.nivus.magic_missiles.max_range = 400
b.specials.stage_06.nivus.magic_missiles.count = 3
b.specials.stage_06.nivus.magic_missiles.damage_min = 5
b.specials.stage_06.nivus.magic_missiles.damage_max = 15
b.specials.stage_06.nivus.magic_missiles.damage_type = DAMAGE_MAGICAL
b.specials.stage_06.nivus.books = {}
b.specials.stage_06.nivus.books.min_range = 0
b.specials.stage_06.nivus.books.max_range = 1000
b.specials.stage_06.nivus.books.soldier = {}
b.specials.stage_06.nivus.books.soldier.armor = 0
b.specials.stage_06.nivus.books.soldier.dead_lifetime = 12
b.specials.stage_06.nivus.books.soldier.hp = 35
b.specials.stage_06.nivus.books.soldier.regen_hp = 4
b.specials.stage_06.nivus.books.soldier.speed = 80
b.specials.stage_06.nivus.books.soldier.duration = 16
b.specials.stage_06.nivus.books.soldier.basic_attack = {}
b.specials.stage_06.nivus.books.soldier.basic_attack.damage_min = 10
b.specials.stage_06.nivus.books.soldier.basic_attack.damage_max = 14
b.specials.stage_06.nivus.books.soldier.basic_attack.cooldown = 1
b.specials.stage_06.nivus.books.soldier.basic_attack.range = 72
b.specials.stage_06.nivus.disintegrate = {}
b.specials.stage_06.nivus.disintegrate.min_range = 0
b.specials.stage_06.nivus.disintegrate.max_range = 1000
b.specials.stage_06.nivus.disintegrate.min_hp = 220
b.specials.stage_06.nivus.disintegrate.max_hp = 1000
b.specials.stage_06.nivus.brooms = {}
b.specials.stage_06.nivus.brooms.min_nodes = 40
b.specials.stage_06.nivus.brooms.max_range = 1000
b.specials.stage_06.nivus.brooms.max_brooms = 5
b.specials.stage_06.nivus.brooms.chain_range = 120
b.specials.stage_06.nivus.brooms.duration = 10
b.specials.stage_06.nivus.brooms.enemy = {}
b.specials.stage_06.nivus.brooms.enemy.hp = 1
b.specials.stage_06.nivus.brooms.enemy.armor = 0
b.specials.stage_06.nivus.brooms.enemy.magic_armor = 0
b.specials.stage_06.nivus.brooms.enemy.speed = 20
b.specials.stage_06.nivus.brooms.enemy.hp_mult = 0.6
b.specials.stage_06.nivus.brooms.enemy.lives_cost = 1
b.specials.stage_06.nivus.brooms.enemy.grant_original_enemy_gold = true
b.specials.stage_06.nivus.brooms.enemy.default_gold = 5
b.specials.stage_07 = {}
b.specials.stage_07.knight = {}
b.specials.stage_07.knight.speed = 130
b.specials.stage_07.knight.damage_min = 50
b.specials.stage_07.knight.damage_max = 100
b.specials.stage_07.knight.damage_type = DAMAGE_PHYSICAL
b.specials.stage_07.knight.radius = 60
b.specials.stage_08 = {}
b.specials.stage_08.templar_archer = {}
b.specials.stage_08.templar_archer.cooldown = 4
b.specials.stage_08.templar_archer.damage_min = 4
b.specials.stage_08.templar_archer.damage_max = 8
b.specials.stage_08.templar_archer.damage_type = DAMAGE_PHYSICAL
b.specials.stage_08.templar_archer.min_range = 25
b.specials.stage_08.templar_archer.max_range = 320
b.specials.stage_08.templar_swordsman = {}
b.specials.stage_08.templar_swordsman.spawn_cooldown = 12
b.specials.stage_08.templar_swordsman.spawn_count = 3
b.specials.stage_08.templar_swordsman.armor = 0.25
b.specials.stage_08.templar_swordsman.hp = 200
b.specials.stage_08.templar_swordsman.regen_hp = 6
b.specials.stage_08.templar_swordsman.speed = 40
b.specials.stage_08.templar_swordsman.basic_attack = {}
b.specials.stage_08.templar_swordsman.basic_attack.cooldown = 1.5
b.specials.stage_08.templar_swordsman.basic_attack.damage_min = 8
b.specials.stage_08.templar_swordsman.basic_attack.damage_max = 16
b.specials.stage_08.templar_swordsman.basic_attack.damage_type = DAMAGE_PHYSICAL
b.specials.stage_08.templar_swordsman.basic_attack.range = 70
b.specials.stage_08.templar_swordsman.arterial_strike = {}
b.specials.stage_08.templar_swordsman.arterial_strike.cooldown = 4
b.specials.stage_08.templar_swordsman.arterial_strike.damage_min = 16
b.specials.stage_08.templar_swordsman.arterial_strike.damage_max = 32
b.specials.stage_08.templar_swordsman.arterial_strike.damage_type = DAMAGE_PHYSICAL
b.specials.stage_08.templar_swordsman.arterial_strike.bleed_duration = 3
b.specials.stage_08.templar_swordsman.arterial_strike.bleed_damage_min = 4
b.specials.stage_08.templar_swordsman.arterial_strike.bleed_damage_max = 5
b.specials.stage_08.templar_swordsman.arterial_strike.bleed_every = 0.5
b.specials.stage_08.cloud_of_crows = {}
b.specials.stage_08.cloud_of_crows.speed = 64
b.specials.stage_08.cloud_of_crows.nodes_to_explode = 56
b.specials.stage_08.cloud_of_crows.spawn_count = 4
b.specials.stage_08.goblin_catapult = {}
b.specials.stage_08.goblin_catapult.taps_to_explode = 6
b.specials.stage_08.goblin_catapult.nodes_ahead = 50
b.specials.stage_08.tower_stun = {}
b.specials.stage_08.tower_stun.wait_time = 5
b.specials.stage_08.tower_stun.cooldown_min = 90
b.specials.stage_08.tower_stun.cooldown_max = 120
b.specials.stage_08.tower_stun.repair_cost = 100
b.specials.stage_08.tower_stun.fire_duration = 45
b.specials.stage_09 = {}
b.specials.stage_09.easter_egg_mortal_kombat = {}
b.specials.stage_09.easter_egg_mortal_kombat.attack_cd = 10
b.specials.stage_09.easter_egg_mortal_kombat.stun_duration = 5
b.specials.stage_17 = {}
b.specials.stage_17.paladin = {}
b.specials.stage_17.paladin.armor = 0.8
b.specials.stage_17.paladin.dead_lifetime = 12
b.specials.stage_17.paladin.hp_max = 240
b.specials.stage_17.paladin.regen_hp = 0
b.specials.stage_17.paladin.speed = 50
b.specials.stage_17.paladin.range = 60
b.specials.stage_17.paladin.basic_attack = {}
b.specials.stage_17.paladin.basic_attack.damage_min = 14
b.specials.stage_17.paladin.basic_attack.damage_max = 20
b.specials.stage_17.paladin.basic_attack.cooldown = 1
b.specials.stage_17.paladin.basic_attack.range = 65
b.specials.stage_17.duel = {}
b.specials.stage_17.duel.fight_duration = 4.5
b.specials.stage_17.duel.clash_window = 2
b.specials.stage_17.duel.tap_time_aid = 0.08
b.specials.stage_17.duel.taps_required = 10
b.specials.stage_17.duel.slayer_victory_wait = 2
b.specials.stage_17.duel.paladin_victory_wait = 2
b.specials.stage_17.duel.enemy_buffs = {}
b.specials.stage_17.duel.enemy_buffs.aura = {}
b.specials.stage_17.duel.enemy_buffs.aura.duration = 7
b.specials.stage_17.duel.enemy_buffs.mods = {}
b.specials.stage_17.duel.enemy_buffs.mods.armor_inc = 0.2
b.specials.stage_17.duel.enemy_buffs.mods.speed_factor = 1.1
b.specials.stage_17.duel.enemy_buffs.mods.duration = 5
b.specials.stage_17.duel.soldier_buffs = {}
b.specials.stage_17.duel.soldier_buffs.aura = {}
b.specials.stage_17.duel.soldier_buffs.aura.duration = 7
b.specials.stage_17.duel.soldier_buffs.mods = {}
b.specials.stage_17.duel.soldier_buffs.mods.dmg_factor = 1.1
b.specials.stage_17.duel.soldier_buffs.mods.armor_inc = 0.2
b.specials.stage_17.duel.soldier_buffs.mods.duration = 5
b.specials.stage_17.joust = {}
b.specials.stage_17.joust.bet_amount = 25
b.specials.stage_17.joust.bet_payout_mult = 4
b.specials.stage_17.joust.cooldown = 75
b.specials.terrain_2 = {}
b.specials.terrain_2.blocked_holders = {}
b.specials.terrain_2.blocked_holders.price = 100
b.specials.terrain_2.pillar_tower_holders = {}
b.specials.terrain_2.pillar_tower_holders.taps_to_break = 3
b.specials.terrain_2.pillar_tower_holders.damage_min = 200
b.specials.terrain_2.pillar_tower_holders.damage_max = 300
b.specials.terrain_2.pillar_tower_holders.damage_radius = 65
b.specials.terrain_2.pillar_tower_holders.damage_type = DAMAGE_INSTAKILL
b.specials.terrain_2.pillar_tower_holders.friendly_damage = true
b.specials.stage_10 = {}
b.specials.stage_10.jt_mechanics = {}
b.specials.stage_10.jt_mechanics.icicles = {}
b.specials.stage_10.jt_mechanics.icicles.target_random = 3
b.specials.stage_10.jt_mechanics.icicles.target_allies = 2
b.specials.stage_10.jt_mechanics.icicles.target_enemies = 2
b.specials.stage_10.jt_mechanics.icicles.damage_min = 40
b.specials.stage_10.jt_mechanics.icicles.damage_max = 60
b.specials.stage_10.jt_mechanics.icicles.damage_radius = 50
b.specials.stage_10.jt_mechanics.icicles.damage_type = DAMAGE_PHYSICAL
b.specials.stage_10.jt_mechanics.icicles.icicles_per_cluster = 3
b.specials.stage_10.jt_mechanics.icicles.spread = 30
b.specials.stage_10.jt_mechanics.icicles.scale_min = 0.7
b.specials.stage_10.jt_mechanics.patrol = {}
b.specials.stage_10.jt_mechanics.patrol.cooldown = 40
b.specials.stage_10.jt_mechanics.patrol.duration = 4
b.specials.stage_10.jt_mechanics.patrol.attacks_until_tired = 1
b.specials.stage_10.jt_mechanics.patrol.damage_radius = 70
b.specials.stage_10.jt_mechanics.patrol.damage_type = DAMAGE_EAT
b.specials.stage_10.jt_mechanics.swipe = {}
b.specials.stage_10.jt_mechanics.swipe.cooldown = 40
b.specials.stage_10.jt_mechanics.swipe.max_wait = 3
b.specials.stage_10.jt_mechanics.swipe.damage_radius = 70
b.specials.stage_10.jt_mechanics.swipe.damage_type = DAMAGE_EAT
b.specials.stage_10.at_at = {}
b.specials.stage_10.at_at.damage_min = 40
b.specials.stage_10.at_at.damage_max = 60
b.specials.stage_10.at_at.damage_radius = 50
b.specials.stage_11 = {}
b.specials.stage_11.shadow_radius = {
	290,
	500,
	600
}
b.specials.stage_11.spider_mechanics = {}
b.specials.stage_11.spider_mechanics.tower_block = {}
b.specials.stage_11.spider_mechanics.tower_block.default_active_waves = {
	3,
	5,
	6,
	7,
	9,
	10,
	12,
	13,
	15
}
b.specials.stage_11.spider_mechanics.tower_block.interval_min = 15
b.specials.stage_11.spider_mechanics.tower_block.interval_max = 30
b.specials.stage_11.spider_mechanics.tower_block.time_to_block = 3
b.specials.stage_11.spider_mechanics.tower_block.taps_to_remove = 5
b.specials.stage_11.spider_mechanics.tower_block.block_duration = 6
b.specials.stage_11.spider_mechanics.eggs_spawn = {}
b.specials.stage_11.spider_mechanics.eggs_spawn.time_to_spawn = 5
b.specials.stage_11.spider_mechanics.rappel = {}
b.specials.stage_11.spider_mechanics.rappel.node_variation = 10
b.specials.stage_11.webs = {}
b.specials.stage_11.webs.speed_factor = 1.25
b.specials.stage_11.webs.slow_factor = 0.7
b.specials.stage_11.webs.mod_duration = 0.25
b.specials.stage_11.webs.range = 60
b.specials.stage_12 = {}
b.specials.stage_12.troll_rappel = {}
b.specials.stage_12.troll_rappel.node_variation = 8
b.specials.terrain_3 = {}
b.specials.terrain_3.blocked_holders = {}
b.specials.terrain_3.blocked_holders.price = 120
b.specials.stage_14 = {}
b.specials.stage_14.graveyard = {}
b.specials.stage_14.graveyard.dead_time = 1
b.specials.stage_14.graveyard.spawn_interval = 1
b.specials.stage_14.graveyard.small_skeleton_hp_threshold = 599
b.specials.stage_14.graveyard.big_skeleton_hp_threshold = 1e+99
b.specials.stage_15 = {}
b.specials.stage_15.lord_blackburn = {}
b.specials.stage_15.lord_blackburn.hp_max = {
	450,
	650,
	800
}
b.specials.stage_15.lord_blackburn.armor = {
	0.3,
	0.5,
	0.6
}
b.specials.stage_15.lord_blackburn.magic_armor = {
	0,
	0,
	0
}
b.specials.stage_15.lord_blackburn.regen_health = {
	36,
	44,
	64
}
b.specials.stage_15.lord_blackburn.max_speed = 45
b.specials.stage_15.lord_blackburn.dead_lifetime = 18
b.specials.stage_15.lord_blackburn.basic_attack = {}
b.specials.stage_15.lord_blackburn.basic_attack.cooldown = 2
b.specials.stage_15.lord_blackburn.basic_attack.range = 75
b.specials.stage_15.lord_blackburn.basic_attack.damage_min = {
	26,
	34,
	52
}
b.specials.stage_15.lord_blackburn.basic_attack.damage_max = {
	40,
	50,
	78
}
b.specials.stage_15.lord_blackburn.basic_attack.damage_type = DAMAGE_PHYSICAL
b.specials.stage_15.lord_blackburn.explosion_radius = 120
b.specials.stage_15.swamp = {}
b.specials.stage_15.swamp.spawn_interval = 1
b.specials.stage_15.swamp.spawn_cooldown = 3
b.specials.stage_15.easter_egg_simpsons = {}
b.specials.stage_15.easter_egg_simpsons.fish_duration = 15
b.specials.stage_15.easter_egg_simpsons.min_time = 20
b.specials.stage_15.easter_egg_simpsons.max_time = 80
b.specials.stage_18 = {}
b.specials.stage_18.veznan = {}
b.specials.stage_18.veznan.cast_time = 1
b.specials.stage_18.veznan.global_cooldown = 2
b.specials.stage_18.veznan.taunt_cooldown_min = 12
b.specials.stage_18.veznan.taunt_cooldown_max = 24
b.specials.stage_18.veznan.gem_blast = {}
b.specials.stage_18.veznan.gem_blast.start_wave = 2
b.specials.stage_18.veznan.gem_blast.cooldown = 15
b.specials.stage_18.veznan.gem_blast.count = 4
b.specials.stage_18.veznan.gem_blast.radius = 300
b.specials.stage_18.veznan.gem_blast.damage_min = 180
b.specials.stage_18.veznan.gem_blast.damage_max = 240
b.specials.stage_18.veznan.disable_towers = {}
b.specials.stage_18.veznan.disable_towers.default_count = 2
b.specials.stage_18.veznan.disable_towers.default_group = "*"
b.specials.stage_18.veznan.disable_towers.click_time = 4
b.specials.stage_18.veznan.disable_towers.lock_duration = 6
b.specials.stage_18.veznan.disable_towers.taps_to_free = 3
b.specials.stage_18.veznan.disable_towers.taps_to_free_touch = 5
b.specials.stage_18.veznan.summon = {}
b.specials.stage_18.veznan.summon.default_path = 1
b.specials.stage_18.veznan.summon.default_group = 1
b.specials.stage_18.veznan.summon.groups = {
	{
		{
			2,
			0,
			"enemy_demon_spawn_g6"
		},
		{
			1,
			0.8,
			"enemy_demon_spawn_g6"
		},
		{
			3,
			1,
			"enemy_demon_spawn_g6"
		},
		{
			2,
			0.8,
			"enemy_demon_spawn_g6"
		},
		{
			1,
			1.2,
			"enemy_demon_spawn_g6"
		}
	},
	{
		{
			2,
			0,
			"enemy_demon_hound"
		},
		{
			1,
			1.6,
			"enemy_demon_hound"
		},
		{
			3,
			1,
			"enemy_demon_hound"
		},
		{
			2,
			0.8,
			"enemy_demon_hound"
		}
	},
	{
		{
			2,
			0,
			"enemy_demon_spawn_g6"
		},
		{
			1,
			0.8,
			"enemy_demon_spawn_g6"
		},
		{
			3,
			0.8,
			"enemy_demon_lord_g6"
		},
		{
			2,
			1,
			"enemy_demon_flareon_g6"
		},
		{
			1,
			1.2,
			"enemy_demon_flareon_g6"
		}
	},
	{
		{
			2,
			0,
			"enemy_demon_imp_g6"
		},
		{
			1,
			1,
			"enemy_demon_imp_g6"
		},
		{
			3,
			1,
			"enemy_demon_imp_g6"
		}
	}
}
b.specials.stage_18.veznan.boss = {}
b.specials.stage_18.veznan.boss.hp_max = {
	5666,
	6666,
	7666,
	8666
}
b.specials.stage_18.veznan.boss.speed = 10
b.specials.stage_18.veznan.boss.spawn_delay = 4
b.specials.stage_18.veznan.boss.basic_attack = {}
b.specials.stage_18.veznan.boss.basic_attack.cooldown = 2.2
b.specials.stage_18.veznan.boss.basic_attack.damage_min = 250
b.specials.stage_18.veznan.boss.basic_attack.damage_max = 350
b.specials.stage_18.veznan.boss.basic_attack.damage_radius = 75
b.specials.stage_18.veznan.boss.gem_blast = {}
b.specials.stage_18.veznan.boss.gem_blast.cooldown = 5
b.specials.stage_18.veznan.boss.gem_blast.count = 1
b.specials.stage_18.veznan.boss.gem_blast.radius = 260
b.specials.stage_18.veznan.boss.gem_blast.min_radius = 100
b.specials.stage_18.veznan.boss.skill_master_delay = 2
b.specials.stage_18.veznan.boss.disable_towers = {}
b.specials.stage_18.veznan.boss.disable_towers.cooldown = 15
b.specials.stage_18.veznan.boss.disable_towers.count = 2
b.specials.stage_18.veznan.boss.disable_towers.radius = 300
b.specials.stage_18.veznan.boss.siphon = {}
b.specials.stage_18.veznan.boss.siphon.cooldown = 7
b.specials.stage_18.veznan.boss.siphon.count = 5
b.specials.stage_18.veznan.boss.siphon.radius = 250
b.specials.stage_18.veznan.boss.siphon.min_radius = 0
b.specials.stage_18.veznan.boss.siphon.damage_min = 550
b.specials.stage_18.veznan.boss.siphon.damage_max = 750
b.specials.stage_18.veznan.boss.siphon.heal_per_soul = 100
b.specials.stage_18.veznan.boss.siphon.soul_time = 0.5
b.specials.stage_18.veznan.boss.siphon.stagger = 0.25
b.specials.stage_18.veznan.boss.reveal_full_heal = true
b.specials.stage_18.veznan.boss.reveal = {}
b.specials.stage_18.veznan.boss.reveal.loop_time = 4
b.specials.stage_18.veznan.boss.reveal.soul_count = 12
b.specials.stage_18.veznan.boss.reveal.soul_time = 0.8
b.specials.stage_18.veznan.boss.reveal.soul_fade = 0.3
b.specials.stage_18.veznan.boss.reveal.soul_offset_x = 250
b.specials.stage_18.veznan.boss.reveal.soul_offset_y = {
	200,
	300
}
b.specials.stage_18.veznan.boss.reveal.soul_curve = {
	60,
	120
}
b.specials.stage_18.veznan.boss.reveal.taunt_pre_delay = 1
b.specials.stage_18.veznan.boss.reveal.taunt_post_delay = 1
b.specials.stage_18.veznan.boss.reveal.hero_damage_min = 0
b.specials.stage_18.veznan.boss.reveal.hero_damage_max = 0
b.specials.stage_18.veznan.boss.reveal.hero_stun_duration = 14
b.specials.stage_18.veznan.boss.illusion_blast = {}
b.specials.stage_18.veznan.boss.illusion_blast.radius = 200
b.specials.stage_18.veznan.boss.illusion_blast.soul_time = 2
b.specials.stage_18.veznan.boss.illusion_blast.soul_offset_x = 150
b.specials.stage_18.veznan.boss.illusion_blast.soul_offset_y = {
	200,
	300
}
b.specials.stage_18.veznan.boss.illusion_blast.death_soul_count = 15
b.specials.stage_18.veznan.boss.moloch_stun_duration = 4
b.specials.stage_18.veznan.boss.skill_stagger = 4
b.specials.stage_18.veznan.boss.real = {}
b.specials.stage_18.veznan.boss.real.hp_max = {
	5999,
	6999,
	7999,
	9999
}
b.specials.stage_18.veznan.boss.real.center_reveal = true
b.specials.stage_18.veznan.boss.real.disable_towers_off = true
b.specials.stage_18.veznan.boss.melee_engage = {}
b.specials.stage_18.veznan.boss.melee_engage.cooldown = 0
b.specials.stage_18.veznan.boss.melee_engage.duration = 3
b.specials.stage_18.moloch = {}
b.specials.stage_18.moloch.cast_time = 1
b.specials.stage_18.moloch.global_cooldown = 2
b.specials.stage_18.moloch.claw_slam = {}
b.specials.stage_18.moloch.claw_slam.pos = {
	x = 812,
	y = 348
}
b.specials.stage_18.moloch.claw_slam.telegraph_time = 4.3
b.specials.stage_18.moloch.claw_slam.damage_radius = 280
b.specials.stage_18.moloch.claw_slam.tower_stun_duration = 3.5
b.specials.stage_18.moloch.claw_slam.shock_radius = 450
b.specials.stage_18.moloch.claw_slam.shock_damage_max = 700
b.specials.stage_18.moloch.claw_slam.shock_damage_min = 100
b.specials.stage_18.moloch.lava_ball = {}
b.specials.stage_18.moloch.lava_ball.count = 1
b.specials.stage_18.moloch.lava_ball.damage_min = 200
b.specials.stage_18.moloch.lava_ball.damage_max = 250
b.specials.stage_18.moloch.lava_ball.damage_radius = 90
b.specials.stage_18.moloch.lava_ball.speed = 1500
b.specials.stage_18.moloch.lava_ball.target_warn_time = 4
b.specials.stage_18.moloch.lava_ball.areas = {
	{
		range = 150,
		pos = {
			x = 383,
			y = 333
		}
	},
	{
		range = 100,
		pos = {
			x = 198,
			y = 355
		}
	},
	{
		range = 150,
		pos = {
			x = 415,
			y = 441
		}
	}
}
b.specials.stage_18.moloch.lava_ball.fire_duration = 5
b.specials.stage_18.moloch.lava_ball.fire_radius = 70
b.specials.stage_18.moloch.lava_ball.fire_cycle_time = 0.4
b.specials.stage_18.moloch.lava_ball.burn_duration = 3
b.specials.stage_18.moloch.lava_ball.burn_damage_min = 8
b.specials.stage_18.moloch.lava_ball.burn_damage_max = 12
b.specials.stage_18.moloch.lava_ball.spawn_template = "enemy_magma_elemental"
b.specials.stage_18.moloch.lava_ball.exit_safezone = 300
b.specials.stage_18.moloch.lava_ball.unit_snap_radius = 80
b.specials.stage_18.moloch.lava_ball.paths = {
	9,
	13,
	15,
	17,
	22
}
b.specials.stage_18.moloch.hellspawn_boost = {}
b.specials.stage_18.moloch.hellspawn_boost.dmg_factor = 1.5
b.specials.stage_18.moloch.hellspawn_boost.duration = 8
b.specials.stage_18.moloch.hellspawn_boost.allowed_templates = {
	"enemy_demon_spawn_g6",
	"enemy_demon_hound",
	"enemy_demon_imp_g6",
	"enemy_demon_flareon_g6",
	"enemy_demon_lord_g6",
	"enemy_magma_elemental"
}
b.specials.towers = {}
b.specials.towers.stage_04_crane = {}
b.specials.towers.stage_04_crane.attack_cost = 30
b.specials.towers.stage_04_crane.attack_cost_iron = 30
b.specials.towers.stage_04_crane.attack = {}
b.specials.towers.stage_04_crane.attack.damage_min = 60
b.specials.towers.stage_04_crane.attack.damage_max = 120
b.specials.towers.stage_04_crane.attack.damage_radius = 60
b.specials.towers.stage_04_crane.attack.range = 1400
b.specials.towers.stage_04_crane.attack.damage_type = DAMAGE_EXPLOSION
b.specials.towers.stage_07_barn = {}
b.specials.towers.stage_07_barn.knight_cost = 50
b.specials.towers.stage_07_barn.max_soldiers = 3
b.specials.towers.stage_07_barn.soldier = {}
b.specials.towers.stage_07_barn.soldier.armor = 0.25
b.specials.towers.stage_07_barn.soldier.dead_lifetime = 12
b.specials.towers.stage_07_barn.soldier.hp = 100
b.specials.towers.stage_07_barn.soldier.regen_hp = 0
b.specials.towers.stage_07_barn.soldier.speed = 60
b.specials.towers.stage_07_barn.soldier.basic_attack = {}
b.specials.towers.stage_07_barn.soldier.basic_attack.damage_min = 4
b.specials.towers.stage_07_barn.soldier.basic_attack.damage_max = 6
b.specials.towers.stage_07_barn.soldier.basic_attack.cooldown = 1
b.specials.towers.stage_07_barn.soldier.basic_attack.range = 65
b.specials.towers.stage_08_catapult = {}
b.specials.towers.stage_08_catapult.attack = {}
b.specials.towers.stage_08_catapult.attack.price = 50
b.specials.towers.stage_08_catapult.attack.damage_min = 100
b.specials.towers.stage_08_catapult.attack.damage_max = 150
b.specials.towers.stage_08_catapult.attack.damage_radius = 80
b.specials.towers.stage_08_catapult.attack.damage_type = DAMAGE_EXPLOSION
b.specials.towers.stage_11_tower_camp = {}
b.specials.towers.stage_11_tower_camp.wave_level_up = {
	5,
	10
}
b.specials.towers.stage_11_tower_camp.max_soldiers = {
	1,
	2,
	2
}
b.specials.towers.stage_11_tower_camp.fire_arrow = {}
b.specials.towers.stage_11_tower_camp.fire_arrow.cooldown = 1.5
b.specials.towers.stage_11_tower_camp.fire_arrow.cost = 50
b.specials.towers.stage_11_tower_camp.attack = {}
b.specials.towers.stage_11_tower_camp.attack.range = 300
b.specials.towers.stage_11_tower_camp.attack.cooldown = 1
b.specials.towers.stage_11_tower_camp.attack.bullet = {}
b.specials.towers.stage_11_tower_camp.attack.bullet.damage_min = 10
b.specials.towers.stage_11_tower_camp.attack.bullet.damage_max = 16
b.specials.towers.stage_11_tower_camp.attack.bullet.damage_type = DAMAGE_PHYSICAL
b.specials.towers.stage_11_tower_camp.prices = {
	0,
	400,
	600
}
b.specials.towers.stage_11_tower_camp.soldier = {}
b.specials.towers.stage_11_tower_camp.soldier.hp = 100
b.specials.towers.stage_11_tower_camp.soldier.armor = 0
b.specials.towers.stage_11_tower_camp.soldier.dead_lifetime = {
	30,
	30,
	26
}
b.specials.towers.stage_11_tower_camp.soldier.regen_hp = 100
b.specials.towers.stage_11_tower_camp.soldier.speed = 40
b.specials.towers.stage_11_tower_camp.soldier.basic_attack = {}
b.specials.towers.stage_11_tower_camp.soldier.basic_attack.damage_min = 4
b.specials.towers.stage_11_tower_camp.soldier.basic_attack.damage_max = 6
b.specials.towers.stage_11_tower_camp.soldier.basic_attack.cooldown = 1
b.specials.towers.stage_11_tower_camp.soldier.basic_attack.range = 65
b.specials.towers.stage_13_sunray_tower = {}
b.specials.towers.stage_13_sunray_tower.price = 200
b.specials.towers.stage_13_sunray_tower.health_boss_hits = 3
b.specials.towers.stage_13_sunray_tower.sunray = {}
b.specials.towers.stage_13_sunray_tower.sunray.points_to_charge = 28
b.specials.towers.stage_13_sunray_tower.sunray.points_per_second = {
	0.61,
	0.74,
	0.87,
	1
}
b.specials.towers.stage_13_sunray_tower.sunray.sorcerers_to_charge = 1
b.specials.towers.stage_13_sunray_tower.sunray.sorcerer_spawn_time = 6
b.specials.towers.stage_13_sunray_tower.sunray.min_range = 0
b.specials.towers.stage_13_sunray_tower.sunray.max_range = 1500
b.specials.towers.stage_13_sunray_tower.sunray.bullet = {}
b.specials.towers.stage_13_sunray_tower.sunray.bullet.ray_duration = 2
b.specials.towers.stage_13_sunray_tower.sunray.bullet.cycle_time = 0.1
b.specials.towers.stage_13_sunray_tower.sunray.bullet.damage_min = 75
b.specials.towers.stage_13_sunray_tower.sunray.bullet.damage_max = 75
b.specials.towers.stage_13_sunray_tower.sunray.bullet.damage_radius = 50
b.specials.towers.stage_13_sunray_tower.sunray.bullet.damage_type = DAMAGE_TRUE
b.specials.towers.stage_13_sunray_tower.sunray.bullet_boss = {}
b.specials.towers.stage_13_sunray_tower.sunray.bullet_boss.cycle_time = 0.25
b.specials.towers.stage_13_sunray_tower.sunray.bullet_boss.damage_min = 40
b.specials.towers.stage_13_sunray_tower.sunray.bullet_boss.damage_max = 50
b.specials.towers.stage_13_sunray_tower.sunray.bullet_boss.damage_type = DAMAGE_TRUE
b.specials.towers.stage_13_sunray_tower.sorcerer = {}
b.specials.towers.stage_13_sunray_tower.sorcerer.time_to_reach_path = 4.3
b.specials.towers.stage_13_sunray_tower.sorcerer.armor = 0
b.specials.towers.stage_13_sunray_tower.sorcerer.dead_lifetime = 12
b.specials.towers.stage_13_sunray_tower.sorcerer.hp = 120
b.specials.towers.stage_13_sunray_tower.sorcerer.regen_hp = 0
b.specials.towers.stage_13_sunray_tower.sorcerer.speed = 50
b.specials.towers.stage_13_sunray_tower.sorcerer.basic_attack = {}
b.specials.towers.stage_13_sunray_tower.sorcerer.basic_attack.damage_min = 4
b.specials.towers.stage_13_sunray_tower.sorcerer.basic_attack.damage_max = 6
b.specials.towers.stage_13_sunray_tower.sorcerer.basic_attack.cooldown = 1
b.specials.towers.stage_13_sunray_tower.sorcerer.basic_attack.range = 35
b.specials.towers.stage_13_sunray_obelisk = {}
b.specials.towers.stage_13_sunray_obelisk.price = 150
b.specials.towers.stage_13_sunray_obelisk.sunray = {}
b.specials.towers.stage_13_sunray_obelisk.sunray.points_to_charge = 2
b.specials.towers.stage_13_sunray_obelisk.sunray.shots = 10
b.specials.towers.stage_13_sunray_obelisk.sunray.time_between_shots = fts(8)
b.specials.towers.stage_13_sunray_obelisk.sunray.min_range = 0
b.specials.towers.stage_13_sunray_obelisk.sunray.max_range = 200
b.specials.towers.stage_13_sunray_obelisk.sunray.bullet = {}
b.specials.towers.stage_13_sunray_obelisk.sunray.bullet.damage_min = 48
b.specials.towers.stage_13_sunray_obelisk.sunray.bullet.damage_max = 72
b.specials.towers.stage_13_sunray_obelisk.sunray.bullet.damage_type = DAMAGE_TRUE
b.specials.towers.stage_14_blacksmith = {}
b.specials.towers.stage_14_blacksmith.towers_to_start_effect = 3
b.specials.towers.stage_14_blacksmith.skill_a = {}
b.specials.towers.stage_14_blacksmith.skill_a.price = {
	150,
	150,
	150
}
b.specials.towers.stage_14_blacksmith.skill_a.aura = {}
b.specials.towers.stage_14_blacksmith.skill_a.aura.radius = 250
b.specials.towers.stage_14_blacksmith.skill_a.aura.dmg_factor = {
	1.1,
	1.2,
	1.35
}
b.specials.towers.stage_14_blacksmith.skill_a.aura.s_dmg_factor = {
	sub_one(b.specials.towers.stage_14_blacksmith.skill_a.aura.dmg_factor[1]),
	sub_one(b.specials.towers.stage_14_blacksmith.skill_a.aura.dmg_factor[2]),
	sub_one(b.specials.towers.stage_14_blacksmith.skill_a.aura.dmg_factor[3])
}
b.specials.towers.stage_14_blacksmith.skill_a.aura.armor_factor = {
	0.1,
	0.2,
	0.35
}
b.specials.towers.stage_14_tavern = {}
b.specials.towers.stage_14_tavern.towers_to_start_effect = 3
b.specials.towers.stage_14_tavern.beer = {}
b.specials.towers.stage_14_tavern.beer.cooldown = 15
b.specials.towers.stage_14_tavern.beer.min_injury = 0.5
b.specials.towers.stage_14_tavern.beer.radius = 60
b.specials.towers.stage_14_tavern.beer.max_targets = 5
b.specials.towers.stage_14_tavern.beer.mod = {}
b.specials.towers.stage_14_tavern.beer.mod.duration = 3
b.specials.towers.stage_14_tavern.beer.mod.heal_every = 0.25
b.specials.towers.stage_14_tavern.beer.mod.heal_per_second_min = 20
b.specials.towers.stage_14_tavern.beer.mod.heal_per_second_max = 20
b.specials.towers.stage_14_tavern.aura = {}
b.specials.towers.stage_14_tavern.aura.radius = 250
b.specials.towers.stage_14_tavern.aura.respawn_time_reduction = 2
b.specials.towers.stage_14_armory = {}
b.specials.towers.stage_14_armory.price = 200
b.specials.towers.stage_14_armory.rally_range = 200
b.specials.towers.stage_14_armory.skill_a = {}
b.specials.towers.stage_14_armory.skill_a.price = {
	150
}
b.specials.towers.stage_14_armory.skill_b = {}
b.specials.towers.stage_14_armory.skill_b.price = {
	100,
	100,
	100
}
b.specials.towers.stage_14_armory.skill_b.respawn_times = {
	14,
	12,
	10
}
b.specials.towers.stage_14_armory.soldier = {}
b.specials.towers.stage_14_armory.soldier.hp = {
	100,
	180
}
b.specials.towers.stage_14_armory.soldier.armor = {
	0.1,
	0.2
}
b.specials.towers.stage_14_armory.soldier.dead_lifetime = 16
b.specials.towers.stage_14_armory.soldier.regen_hp = {
	8,
	14
}
b.specials.towers.stage_14_armory.soldier.speed = {
	60,
	60
}
b.specials.towers.stage_14_armory.soldier.basic_attack = {}
b.specials.towers.stage_14_armory.soldier.basic_attack.damage_min = {
	4,
	6
}
b.specials.towers.stage_14_armory.soldier.basic_attack.damage_max = {
	6,
	10
}
b.specials.towers.stage_14_armory.soldier.basic_attack.damage_radius = {
	0,
	50
}
b.specials.towers.stage_14_armory.soldier.basic_attack.cooldown = 1
b.specials.towers.stage_14_armory.soldier.basic_attack.range = {
	65,
	65
}
b.specials.towers.stage_16_treant_attacker = {}
b.specials.towers.stage_16_treant_attacker.basic_attack = {}
b.specials.towers.stage_16_treant_attacker.basic_attack.range = 180
b.specials.towers.stage_16_treant_attacker.basic_attack.bullet_count = 3
b.specials.towers.stage_16_treant_attacker.basic_attack.cooldown = 4.5
b.specials.towers.stage_16_treant_attacker.basic_attack.bullet = {}
b.specials.towers.stage_16_treant_attacker.basic_attack.bullet.damage_min = 30
b.specials.towers.stage_16_treant_attacker.basic_attack.bullet.damage_max = 50
b.specials.towers.stage_16_treant_attacker.basic_attack.bullet.damage_radius = 50
b.specials.towers.stage_16_treant_attacker.basic_attack.bullet.damage_type = DAMAGE_EXPLOSION
b.specials.towers.stage_16_treant_killer = {}
b.specials.towers.stage_16_treant_killer.basic_attack = {}
b.specials.towers.stage_16_treant_killer.basic_attack.range = 180
b.specials.towers.stage_16_treant_killer.basic_attack.bullet_count = 3
b.specials.towers.stage_16_treant_killer.basic_attack.cooldown = 40
b.specials.towers.stage_16_treant_killer.instakill = {}
b.specials.towers.stage_16_treant_killer.instakill.detection_radius = 170
b.specials.towers.stage_16_treant_killer.instakill.radius = 50
b.specials.towers.stage_16_treant_healer = {}
b.specials.towers.stage_16_treant_healer.aura = {}
b.specials.towers.stage_16_treant_healer.aura.range = 180
b.specials.towers.stage_16_treant_healer.aura.cycle_time = 0.5
b.specials.towers.stage_16_treant_healer.aura.heal = {}
b.specials.towers.stage_16_treant_healer.aura.heal.duration = 0.6
b.specials.towers.stage_16_treant_healer.aura.heal.heal_every = 0.25
b.specials.towers.stage_16_treant_healer.aura.heal.heal_per_second_min = 5
b.specials.towers.stage_16_treant_healer.aura.heal.heal_per_second_max = 5
b.specials.towers.stage_16_treant_rooter = {}
b.specials.towers.stage_16_treant_rooter.aura = {}
b.specials.towers.stage_16_treant_rooter.aura.range = 175
b.specials.towers.stage_16_treant_rooter.aura.cycle_time = 0.5
b.specials.towers.stage_16_treant_rooter.aura.slow = {}
b.specials.towers.stage_16_treant_rooter.aura.slow.duration = 0.6
b.specials.towers.stage_16_treant_rooter.aura.slow.slow_factor = 0.6
b.specials.towers.stage_17_paladin_barracks = {}
b.specials.towers.stage_17_paladin_barracks.knight_cost = 50
b.specials.towers.stage_17_paladin_barracks.max_soldiers = 3
b.specials.towers.stage_17_paladin_barracks.soldier = {}
b.specials.towers.stage_17_paladin_barracks.soldier.armor = 0.25
b.specials.towers.stage_17_paladin_barracks.soldier.dead_lifetime = 5
b.specials.towers.stage_17_paladin_barracks.soldier.hp = 100
b.specials.towers.stage_17_paladin_barracks.soldier.regen_hp = 0
b.specials.towers.stage_17_paladin_barracks.soldier.speed = 60
b.specials.towers.stage_17_paladin_barracks.soldier.basic_attack = {}
b.specials.towers.stage_17_paladin_barracks.soldier.basic_attack.damage_min = 4
b.specials.towers.stage_17_paladin_barracks.soldier.basic_attack.damage_max = 6
b.specials.towers.stage_17_paladin_barracks.soldier.basic_attack.cooldown = 1
b.specials.towers.stage_17_paladin_barracks.soldier.basic_attack.range = 65
b.specials.heroes = {}
b.specials.heroes.hero_alleria = {}
b.specials.heroes.hero_alleria.dead_lifetime = 30
b.specials.heroes.hero_alleria.speed = 70
b.specials.heroes.hero_alleria.regen_cooldown = 1
b.specials.heroes.hero_alleria.armor = 0
b.specials.heroes.hero_alleria.hp_max = 160
b.specials.heroes.hero_alleria.regen_health = 13
b.specials.heroes.hero_alleria.regen_tree_mult = 1.5
b.specials.heroes.hero_alleria.basic_melee = {}
b.specials.heroes.hero_alleria.basic_melee.cooldown = 1
b.specials.heroes.hero_alleria.basic_melee.damage_min = 8
b.specials.heroes.hero_alleria.basic_melee.damage_max = 13
b.specials.heroes.hero_alleria.basic_melee.damage_type = DAMAGE_PHYSICAL
b.specials.heroes.hero_alleria.basic_ranged = {}
b.specials.heroes.hero_alleria.basic_ranged.cooldown = 1
b.specials.heroes.hero_alleria.basic_ranged.min_range = 70
b.specials.heroes.hero_alleria.basic_ranged.max_range = 150
b.specials.heroes.hero_alleria.basic_ranged.damage_min = 8
b.specials.heroes.hero_alleria.basic_ranged.damage_max = 13
b.specials.heroes.hero_alleria.basic_ranged.damage_type = DAMAGE_PHYSICAL
b.specials.heroes.hero_alleria.multishot = {}
b.specials.heroes.hero_alleria.multishot.cooldown = 20
b.specials.heroes.hero_alleria.multishot.damage_min = 8
b.specials.heroes.hero_alleria.multishot.damage_max = 14
b.specials.heroes.hero_alleria.multishot.damage_type = DAMAGE_PHYSICAL
b.specials.heroes.hero_alleria.multishot.max_range = 200
b.specials.heroes.hero_alleria.multishot.min_range = 100
b.specials.heroes.hero_alleria.multishot.min_targets = 3
b.specials.heroes.hero_alleria.multishot.shots = 3
b.specials.heroes.hero_alleria.wildcat = {}
b.specials.heroes.hero_alleria.wildcat.cooldown = 28
b.specials.heroes.hero_alleria.wildcat.min_targets = 2
b.specials.heroes.hero_alleria.wildcat.soldier = {}
b.specials.heroes.hero_alleria.wildcat.soldier.armor = 0
b.specials.heroes.hero_alleria.wildcat.soldier.dead_lifetime = 12
b.specials.heroes.hero_alleria.wildcat.soldier.hp = 80
b.specials.heroes.hero_alleria.wildcat.soldier.regen_hp = 6
b.specials.heroes.hero_alleria.wildcat.soldier.speed = 80
b.specials.heroes.hero_alleria.wildcat.soldier.duration = 15
b.specials.heroes.hero_alleria.wildcat.soldier.basic_attack = {}
b.specials.heroes.hero_alleria.wildcat.soldier.basic_attack.damage_min = 6
b.specials.heroes.hero_alleria.wildcat.soldier.basic_attack.damage_max = 9
b.specials.heroes.hero_alleria.wildcat.soldier.basic_attack.damage_type = DAMAGE_PHYSICAL
b.specials.heroes.hero_alleria.wildcat.soldier.basic_attack.cooldown = 1
b.specials.heroes.hero_alleria.wildcat.soldier.basic_attack.range = 150
b.specials.heroes.hero_denas = {}
b.specials.heroes.hero_denas.dead_lifetime = 27
b.specials.heroes.hero_denas.speed = 110
b.specials.heroes.hero_denas.armor = 0.5
b.specials.heroes.hero_denas.hp_max = 750
b.specials.heroes.hero_denas.regen_health = 60
b.specials.heroes.hero_denas.basic_melee = {}
b.specials.heroes.hero_denas.basic_melee.cooldown = 2
b.specials.heroes.hero_denas.basic_melee.damage_min = 35
b.specials.heroes.hero_denas.basic_melee.damage_max = 50
b.specials.heroes.hero_denas.basic_melee.damage_type = DAMAGE_PHYSICAL
b.specials.heroes.hero_denas.mighty_slash = {}
b.specials.heroes.hero_denas.mighty_slash.cooldown = 6
b.specials.heroes.hero_denas.mighty_slash.damage_min = 100
b.specials.heroes.hero_denas.mighty_slash.damage_max = 120
b.specials.heroes.hero_denas.bombardement = {}
b.specials.heroes.hero_denas.bombardement.cooldown = 20
b.specials.heroes.hero_denas.bombardement.max_range = 300
b.specials.heroes.hero_denas.bombardement.min_targets = 3
b.specials.heroes.hero_denas.bombardement.cluster_radius = 75
b.specials.heroes.hero_denas.bombardement.shots = 1
b.specials.heroes.hero_denas.bombardement.edge_margin = 150
b.specials.heroes.hero_denas.bombardement.hero_margin = 100
b.specials.heroes.hero_denas.bombardement.enter_scale = 1.7
b.specials.heroes.hero_denas.bombardement.arrive_scale = 0.7
b.specials.heroes.hero_denas.bombardement.damage_min = 200
b.specials.heroes.hero_denas.bombardement.damage_max = 450
b.specials.heroes.hero_denas.bombardement.radius = 60
b.specials.heroes.hero_denas.bombardement.damage_type = DAMAGE_EXPLOSION
b.specials.heroes.hero_denas.denas_guards = {}
b.specials.heroes.hero_denas.denas_guards.cooldown = 15
b.specials.heroes.hero_denas.denas_guards.range_nodes_min = 0
b.specials.heroes.hero_denas.denas_guards.range_nodes_max = 30
b.specials.heroes.hero_denas.denas_guards.max_path_dist = 60
b.specials.heroes.hero_denas.denas_guards.ahead_nodes = 5
b.specials.heroes.hero_denas.denas_guards.soldier = {}
b.specials.heroes.hero_denas.denas_guards.soldier.duration = 12
b.specials.heroes.hero_denas.denas_guards.soldier.hp_max = 150
b.specials.heroes.hero_denas.denas_guards.soldier.armor = 0.35
b.specials.heroes.hero_denas.denas_guards.soldier.regen_health = 8
b.specials.heroes.hero_denas.denas_guards.soldier.max_speed = 64
b.specials.heroes.hero_denas.denas_guards.soldier.melee_attack = {}
b.specials.heroes.hero_denas.denas_guards.soldier.melee_attack.cooldown = 1
b.specials.heroes.hero_denas.denas_guards.soldier.melee_attack.damage_min = 8
b.specials.heroes.hero_denas.denas_guards.soldier.melee_attack.damage_max = 12
b.specials.heroes.hero_denas.denas_guards.soldier.melee_attack.range = 72
b.specials.heroes.hero_denas.rally_speed_boost = {}
b.specials.heroes.hero_denas.rally_speed_boost.min_dist = 100
b.specials.heroes.hero_denas.rally_speed_boost.speed_factor = 1.5
b.powers = {}
b.powers.reinforcements = {}
b.powers.reinforcements.xp_per_use = 100
b.powers.reinforcements.stats = {}
b.powers.reinforcements.stats.type = "summon"
b.powers.reinforcements.stats.cooldown = 9.5
b.powers.reinforcements.stats.hp = 4
b.powers.reinforcements.soldier = {}
b.powers.reinforcements.soldier.cooldown = 15
b.powers.reinforcements.soldier.duration = 12
b.powers.reinforcements.soldier.hp_max = 40
b.powers.reinforcements.soldier.regen_health = 8
b.powers.reinforcements.soldier.armor = 0
b.powers.reinforcements.soldier.max_speed = 64
b.powers.reinforcements.soldier.melee_attack = {}
b.powers.reinforcements.soldier.melee_attack.cooldown = 1
b.powers.reinforcements.soldier.melee_attack.damage_min = 2
b.powers.reinforcements.soldier.melee_attack.damage_max = 4
b.powers.reinforcements.soldier.melee_attack.range = 72
b.powers.reinforcements.special_soldier = {}
b.powers.reinforcements.special_soldier.cooldown = 16
b.powers.reinforcements.special_soldier.duration = 12
b.powers.reinforcements.special_soldier.hp_max = 140
b.powers.reinforcements.special_soldier.regen_health = 11
b.powers.reinforcements.special_soldier.armor = 0.4
b.powers.reinforcements.special_soldier.spiked_armor = 0
b.powers.reinforcements.special_soldier.max_speed = 64
b.powers.reinforcements.special_soldier.melee_attack = {}
b.powers.reinforcements.special_soldier.melee_attack.cooldown = 1
b.powers.reinforcements.special_soldier.melee_attack.damage_min = 10
b.powers.reinforcements.special_soldier.melee_attack.damage_max = 14
b.powers.reinforcements.special_soldier.melee_attack.range = 72
b.powers.reinforcements.special_soldier.aura_range = 70
b.powers.reinforcements.special_soldier.aura_duration = 0.2
b.powers.reinforcements.special_soldier.aura_cycle_time = 0.2
b.powers.reinforcements.special_soldier.buff_duration = 12
b.powers.reinforcements.special_soldier.buff_dmg_factor = 1.1
b.powers.reinforcements.special_soldier.s_buff_dmg_factor = sub_one(b.powers.reinforcements.special_soldier.buff_dmg_factor)
b.powers.reinforcements.special_soldier.buff_armor_max_factor = 0.15
b.powers.rain_of_fire = {}
b.powers.rain_of_fire.cooldown = 60
b.powers.rain_of_fire.min_spread = 25
b.powers.rain_of_fire.max_spread = 40
b.powers.rain_of_fire.meteor_count = 3
b.powers.rain_of_fire.xp_per_use = 400
b.powers.rain_of_fire.stats = {}
b.powers.rain_of_fire.stats.type = "damage"
b.powers.rain_of_fire.stats.cooldown = 4.5
b.powers.rain_of_fire.stats.damage = 6.5
b.powers.rain_of_fire.bullet = {}
b.powers.rain_of_fire.bullet.radius = 70
b.powers.rain_of_fire.bullet.damage_type = DAMAGE_TRUE
b.powers.rain_of_fire.bullet.damage_min = 36
b.powers.rain_of_fire.bullet.damage_max = 54
b.powers.royal_edict = {}
b.powers.royal_edict.cooldown = 50
b.powers.royal_edict.duration = 0.5
b.powers.royal_edict.range = 200
b.powers.royal_edict.buff_dmg_factor = 1.75
b.powers.royal_edict.s_buff_dmg_factor = sub_one(b.powers.royal_edict.buff_dmg_factor)
b.powers.royal_edict.mod_duration = 6
b.powers.royal_edict.xp_per_use = 320
b.powers.royal_edict.stats = {}
b.powers.royal_edict.stats.type = "utility"
b.powers.royal_edict.stats.cooldown = 5.5
b.powers.royal_edict.stats.range = 8
b.powers.soaring_shop = {}
b.powers.soaring_shop.duration = 20
b.powers.soaring_shop.max_speed = 64
b.powers.soaring_shop.cooldown = 50
b.powers.soaring_shop.xp_per_use = 320
b.powers.soaring_shop.attack_1 = {}
b.powers.soaring_shop.attack_1.damage_type = DAMAGE_EXPLOSION
b.powers.soaring_shop.attack_1.radius = 50
b.powers.soaring_shop.attack_1.damage_min = 15
b.powers.soaring_shop.attack_1.damage_max = 25
b.powers.soaring_shop.attack_1.cooldown = 0.64
b.powers.soaring_shop.attack_1.range = 200
b.powers.soaring_shop.attack_1.special_1_rate = 3
b.powers.soaring_shop.attack_1.special_2_rate = 5
b.powers.soaring_shop.attack_1.prediction = fts(10)
b.powers.soaring_shop.attack_2 = {}
b.powers.soaring_shop.attack_2.stun_duration = 1.5
b.powers.soaring_shop.attack_2.damage_type = DAMAGE_EXPLOSION
b.powers.soaring_shop.attack_2.radius = 75
b.powers.soaring_shop.attack_2.damage_min = 10
b.powers.soaring_shop.attack_2.damage_max = 20
b.powers.soaring_shop.attack_2.cooldown = 20
b.powers.soaring_shop.attack_2.range = 200
b.powers.soaring_shop.attack_3 = {}
b.powers.soaring_shop.attack_3.damage_type = DAMAGE_EXPLOSION
b.powers.soaring_shop.attack_3.radius = 90
b.powers.soaring_shop.attack_3.damage_min = 100
b.powers.soaring_shop.attack_3.damage_max = 300
b.powers.soaring_shop.attack_3.cooldown = 10
b.powers.soaring_shop.attack_3.range = 60
b.powers.soaring_shop.attack_3.prediction = fts(6)
b.powers.soaring_shop.bottom_info_stats = {}
b.powers.soaring_shop.bottom_info_stats.hp = 10
b.powers.soaring_shop.bottom_info_stats.hp_max = 10
b.powers.soaring_shop.bottom_info_stats.damage_min = b.powers.soaring_shop.attack_1.damage_min
b.powers.soaring_shop.bottom_info_stats.damage_max = b.powers.soaring_shop.attack_1.damage_max
b.powers.soaring_shop.bottom_info_stats.armor = 1
b.powers.soaring_shop.bottom_info_stats.respawn = 10
b.powers.soaring_shop.bottom_info_stats.cooldown = b.powers.soaring_shop.cooldown
b.powers.soaring_shop.stats = {}
b.powers.soaring_shop.stats.type = "damage"
b.powers.soaring_shop.stats.cooldown = 5.5
b.powers.soaring_shop.stats.damage = 5.5
b.powers.aspect_of_sol = {}
b.powers.aspect_of_sol.cooldown = 60
b.powers.aspect_of_sol.summon_target_radius = 50
b.powers.aspect_of_sol.xp_per_use = 400
b.powers.aspect_of_sol.stats = {}
b.powers.aspect_of_sol.stats.type = "summon"
b.powers.aspect_of_sol.stats.cooldown = 4.5
b.powers.aspect_of_sol.stats.hp = 10
b.powers.aspect_of_sol.soldier = {}
b.powers.aspect_of_sol.soldier.hp_max = 750
b.powers.aspect_of_sol.soldier.armor = 0.5
b.powers.aspect_of_sol.soldier.magic_armor = 0
b.powers.aspect_of_sol.soldier.max_speed = 30
b.powers.aspect_of_sol.soldier.duration = 18
b.powers.aspect_of_sol.soldier.melee_attack = {}
b.powers.aspect_of_sol.soldier.melee_attack.cooldown = 1.5
b.powers.aspect_of_sol.soldier.melee_attack.damage_min = 42
b.powers.aspect_of_sol.soldier.melee_attack.damage_max = 64
b.powers.aspect_of_sol.soldier.melee_attack.range = 72
b.powers.aspect_of_sol.soldier.melee_attack.damage_type = DAMAGE_TRUE
b.powers.aspect_of_sol.soldier.melee_attack.boss_damage_cap = 0.5
b.powers.aspect_of_sol.soldier.melee_attack.miniboss_damage_cap = 1
b.powers.aspect_of_sol.soldier.special_attack = {}
b.powers.aspect_of_sol.soldier.special_attack.damage_min = 98
b.powers.aspect_of_sol.soldier.special_attack.damage_max = 146
b.powers.aspect_of_sol.soldier.special_attack.damage_type = DAMAGE_TRUE
b.powers.aspect_of_sol.soldier.special_attack.boss_damage_cap = 0.5
b.powers.aspect_of_sol.soldier.special_attack.miniboss_damage_cap = 1
b.powers.aspect_of_sol.warcry = {}
b.powers.aspect_of_sol.warcry.duration = 5
b.powers.aspect_of_sol.warcry.dmg_factor_inc = 1.3
b.powers.aspect_of_sol.warcry.s_dmg_factor_inc = sub_one(b.powers.aspect_of_sol.warcry.dmg_factor_inc)
b.powers.aspect_of_sol.warcry.armor_inc = 0.3
b.powers.aspect_of_sol.warcry.cooldown = 30
b.powers.aspect_of_sol.warcry.max_range = 100
b.powers.aspect_of_sol.warcry.slow_duration = 6
b.powers.aspect_of_sol.warcry.slow_factor = 0.5
b.powers.aspect_of_sol.warcry.s_slow_factor = 0.5
b.powers.aspect_of_sol.warcry.radius = 80
b.powers.aspect_of_sol.on_summon = {}
b.powers.aspect_of_sol.on_summon.stun_duration = 2
b.powers.aspect_of_sol.on_summon.radius = 100
b.powers.aspect_of_sol.on_summon.damage_type = DAMAGE_TRUE
b.powers.aspect_of_sol.on_summon.boss_damage_cap = 0.5
b.powers.aspect_of_sol.on_summon.miniboss_damage_cap = 0.5
b.powers.aspect_of_sol.on_select_enemy = {}
b.powers.aspect_of_sol.on_select_enemy.damage = 300
b.powers.aspect_of_sol.on_select_enemy.damage_type = DAMAGE_TRUE
b.powers.aspect_of_sol.on_select_enemy.max_boss_damage = 300
b.powers.aspect_of_sol.on_select_enemy.max_miniboss_damage = 300
b.powers.aspect_of_sol.spawn_with_beam = false
b.powers.teleportation_sigil = {}
b.powers.teleportation_sigil.cooldown = 45
b.powers.teleportation_sigil.xp_per_use = 280
b.powers.teleportation_sigil.sigil_duration = 40
b.powers.teleportation_sigil.nodes_to_teleport = 50
b.powers.teleportation_sigil.nodes_limit = 10
b.powers.teleportation_sigil.tp_duration = 1
b.powers.teleportation_sigil.enemy_max_tp_count = 4
b.powers.teleportation_sigil.max_tp_count = 4
b.powers.teleportation_sigil.range = 50
b.powers.teleportation_sigil.stats = {}
b.powers.teleportation_sigil.stats.type = "utility"
b.powers.teleportation_sigil.stats.cooldown = 6
b.powers.teleportation_sigil.stats.range = 4
b.powers.wintersongs_wrath = {}
b.powers.wintersongs_wrath.cooldown = 40
b.powers.wintersongs_wrath.xp_per_use = 280
b.powers.wintersongs_wrath.duration = 8
b.powers.wintersongs_wrath.slow_factor = 0.6
b.powers.wintersongs_wrath.s_slow_factor = 0.4
b.powers.wintersongs_wrath.radius = 120
b.powers.wintersongs_wrath.cycle_time = 0.1
b.powers.wintersongs_wrath.stats = {}
b.powers.wintersongs_wrath.stats.type = "utility"
b.powers.wintersongs_wrath.stats.cooldown = 6.5
b.powers.wintersongs_wrath.stats.range = 5
b.powers.thunder_zapper = {}
b.powers.thunder_zapper.cooldown = 50
b.powers.thunder_zapper.xp_per_use = 320
b.powers.thunder_zapper.duration = 10
b.powers.thunder_zapper.max_speed = 60
b.powers.thunder_zapper.spawn_detection_range = 80
b.powers.thunder_zapper.damage_aura = {}
b.powers.thunder_zapper.damage_aura.damage_min = 6
b.powers.thunder_zapper.damage_aura.damage_max = 10
b.powers.thunder_zapper.damage_aura.s_damage_min = 240
b.powers.thunder_zapper.damage_aura.s_damage_max = 400
b.powers.thunder_zapper.damage_aura.damage_type = DAMAGE_TRUE
b.powers.thunder_zapper.damage_aura.radius = 80
b.powers.thunder_zapper.damage_aura.cycle_time = 0.25
b.powers.thunder_zapper.summon_aura = {}
b.powers.thunder_zapper.summon_aura.damage_min = 30
b.powers.thunder_zapper.summon_aura.damage_max = 42
b.powers.thunder_zapper.summon_aura.damage_type = DAMAGE_TRUE
b.powers.thunder_zapper.summon_aura.damage_radius = 110
b.powers.thunder_zapper.stats = {}
b.powers.thunder_zapper.stats.type = "damage"
b.powers.thunder_zapper.stats.cooldown = 5.5
b.powers.thunder_zapper.stats.damage = 5.5
b.powers.musketeers = {}
b.powers.musketeers.xp_per_use = 133
b.powers.musketeers.cooldown = 20
b.powers.musketeers.stats = {}
b.powers.musketeers.stats.type = "summon"
b.powers.musketeers.stats.cooldown = 9
b.powers.musketeers.stats.hp = 2
b.powers.musketeers.soldier = {}
b.powers.musketeers.soldier.duration = 12
b.powers.musketeers.soldier.hp_max = 30
b.powers.musketeers.soldier.regen_health = 5
b.powers.musketeers.soldier.armor = 0
b.powers.musketeers.soldier.max_speed = 80
b.powers.musketeers.soldier.melee_attack = {}
b.powers.musketeers.soldier.melee_attack.cooldown = 1.5
b.powers.musketeers.soldier.melee_attack.damage_min = 2
b.powers.musketeers.soldier.melee_attack.damage_max = 4
b.powers.musketeers.soldier.melee_attack.range = 50
b.powers.musketeers.soldier.basic_ranged = {}
b.powers.musketeers.soldier.basic_ranged.cooldown = 1.5
b.powers.musketeers.soldier.basic_ranged.xp_gain_factor = 0.8
b.powers.musketeers.soldier.basic_ranged.min_range = 20
b.powers.musketeers.soldier.basic_ranged.max_range = 220
b.powers.musketeers.soldier.basic_ranged.damage_min = 10
b.powers.musketeers.soldier.basic_ranged.damage_max = 16
b.powers.musketeers.soldier.basic_ranged.damage_type = DAMAGE_PHYSICAL
b.upgrades = {}
b.upgrades.power_reinforcements = {}
b.upgrades.power_reinforcements.l2a = {}
b.upgrades.power_reinforcements.l2a.duration_extra = 5
b.upgrades.power_reinforcements.l2b = {}
b.upgrades.power_reinforcements.l2b.dmg_factor = 1.5
b.upgrades.power_reinforcements.l2b.s_damage_factor = sub_one(b.upgrades.power_reinforcements.l2b.dmg_factor)
b.upgrades.power_reinforcements.l3 = {}
b.upgrades.power_reinforcements.l3.armor = 0.4
b.upgrades.power_reinforcements.l3.hp_factor = 1.15
b.upgrades.power_reinforcements.l3.s_hp_factor = sub_one(b.upgrades.power_reinforcements.l3.hp_factor)
b.upgrades.power_reinforcements.l4a = {}
b.upgrades.power_reinforcements.l4a.mov_speed_factor = 1.2
b.upgrades.power_reinforcements.l4a.cooldown_decrease = 3
b.upgrades.power_reinforcements.l4b = {}
b.upgrades.power_reinforcements.l4b.armor_increase = 0.15
b.upgrades.power_reinforcements.l5a = {}
b.upgrades.power_reinforcements.l5a.dmg_factor = 1.5
b.upgrades.power_reinforcements.l5a.s_dmg_factor = sub_one(b.upgrades.power_reinforcements.l5a.dmg_factor)
b.upgrades.power_reinforcements.l5a.hp_factor = 1.15
b.upgrades.power_reinforcements.l5a.s_hp_factor = sub_one(b.upgrades.power_reinforcements.l5a.hp_factor)
b.upgrades.power_reinforcements.l5b = {}
b.upgrades.power_reinforcements.l5b.spiked_armor = 0.2
b.upgrades.power_reinforcements.l6 = {}
b.upgrades.power_rain_of_fire = {}
b.upgrades.power_rain_of_fire.l2a = {}
b.upgrades.power_rain_of_fire.l2a.cd_reduction = 5
b.upgrades.power_rain_of_fire.l2b = {}
b.upgrades.power_rain_of_fire.l2b.damage_factor = 1.1
b.upgrades.power_rain_of_fire.l2b.s_damage_factor = sub_one(b.upgrades.power_rain_of_fire.l2b.damage_factor)
b.upgrades.power_rain_of_fire.l3 = {}
b.upgrades.power_rain_of_fire.l3.duration = 3
b.upgrades.power_rain_of_fire.l3.burn_duration = 0.5
b.upgrades.power_rain_of_fire.l3.cycle_time = 0.25
b.upgrades.power_rain_of_fire.l3.damage_min = 3
b.upgrades.power_rain_of_fire.l3.damage_max = 5
b.upgrades.power_rain_of_fire.l3.s_damage_min = 36
b.upgrades.power_rain_of_fire.l3.s_damage_max = 60
b.upgrades.power_rain_of_fire.l3.radius = 50
b.upgrades.power_rain_of_fire.l3.damage_type = DAMAGE_TRUE
b.upgrades.power_rain_of_fire.l4a = {}
b.upgrades.power_rain_of_fire.l4a.duration_inc = 4
b.upgrades.power_rain_of_fire.l4a.damage_inc = 1.5
b.upgrades.power_rain_of_fire.l4a.s_damage_inc = sub_one(b.upgrades.power_rain_of_fire.l4a.damage_inc)
b.upgrades.power_rain_of_fire.l4b = {}
b.upgrades.power_rain_of_fire.l4b.meteor_inc = 2
b.upgrades.power_rain_of_fire.l5a = {}
b.upgrades.power_rain_of_fire.l5a.duration = 7
b.upgrades.power_rain_of_fire.l5a.slow_duration = 0.5
b.upgrades.power_rain_of_fire.l5a.slow_factor = 0.6
b.upgrades.power_rain_of_fire.l5a.s_slow_factor = 0.4
b.upgrades.power_rain_of_fire.l5a.radius = 50
b.upgrades.power_rain_of_fire.l5a.cycle_time = 0.3
b.upgrades.power_rain_of_fire.l5b = {}
b.upgrades.power_rain_of_fire.l5b.damage_min = 24
b.upgrades.power_rain_of_fire.l5b.damage_max = 36
b.upgrades.power_rain_of_fire.l5b.damage_radius = 60
b.upgrades.power_rain_of_fire.l5b.damage_type = DAMAGE_TRUE
b.upgrades.power_rain_of_fire.l6 = {}
b.upgrades.power_rain_of_fire.l6.cataclysm_count = 5
b.upgrades.power_rain_of_fire.l6.cd_reduction = 10
b.upgrades.power_royal_edict = {}
b.upgrades.power_royal_edict.l2a = {}
b.upgrades.power_royal_edict.l2a.range_factor = 1.2
b.upgrades.power_royal_edict.l2a.s_range_factor = sub_one(b.upgrades.power_royal_edict.l2a.range_factor)
b.upgrades.power_royal_edict.l3 = {}
b.upgrades.power_royal_edict.l3.range_factor = 1.5
b.upgrades.power_royal_edict.l3.s_range_factor = sub_one(b.upgrades.power_royal_edict.l3.range_factor)
b.upgrades.power_royal_edict.l4a = {}
b.upgrades.power_royal_edict.l4a.dmg_factor_inc = 0.2
b.upgrades.power_royal_edict.l4b = {}
b.upgrades.power_royal_edict.l4b.mod = {}
b.upgrades.power_royal_edict.l4b.mod.gold = 4
b.upgrades.power_royal_edict.l5b = {}
b.upgrades.power_royal_edict.l5b.duration_factor = 1.33
b.upgrades.power_royal_edict.l5b.s_duration_factor = sub_one(b.upgrades.power_royal_edict.l5b.duration_factor)
b.upgrades.power_soaring_shop = {}
b.upgrades.power_soaring_shop.l2a = {}
b.upgrades.power_soaring_shop.l2a.radius_factor = 1.2
b.upgrades.power_soaring_shop.l2a.s_radius_factor = sub_one(b.upgrades.power_soaring_shop.l2a.radius_factor)
b.upgrades.power_soaring_shop.l2b = {}
b.upgrades.power_soaring_shop.l2b.cd_reduction = 10
b.upgrades.power_soaring_shop.l4a = {}
b.upgrades.power_soaring_shop.l4a.damage_inc = 1.1
b.upgrades.power_soaring_shop.l4a.s_damage_inc = sub_one(b.upgrades.power_soaring_shop.l4a.damage_inc)
b.upgrades.power_soaring_shop.l4b = {}
b.upgrades.power_soaring_shop.l4b.cd_reduction = 5
b.upgrades.power_soaring_shop.l5a = {}
b.upgrades.power_soaring_shop.l5a.cd_reduction = 0.5
b.upgrades.power_soaring_shop.l5a.s_cd_reduction = 1.5
b.upgrades.power_soaring_shop.l5b = {}
b.upgrades.power_soaring_shop.l5b.duration_factor = 1.2
b.upgrades.power_soaring_shop.l5b.s_duration_factor = 24
b.upgrades.power_aspect_of_sol = {}
b.upgrades.power_aspect_of_sol.l2a = {}
b.upgrades.power_aspect_of_sol.l2a.duration_factor = 1.34
b.upgrades.power_aspect_of_sol.l2a.s_duration_factor = 24
b.upgrades.power_aspect_of_sol.l2b = {}
b.upgrades.power_aspect_of_sol.l2b.damage_inc = 1.3
b.upgrades.power_aspect_of_sol.l2b.s_damage_inc = sub_one(b.upgrades.power_aspect_of_sol.l2b.damage_inc)
b.upgrades.power_aspect_of_sol.l4a = {}
b.upgrades.power_aspect_of_sol.l4a.duration_factor = 2
b.upgrades.power_aspect_of_sol.l4a.s_duration_factor = sub_one(b.upgrades.power_aspect_of_sol.l4a.duration_factor)
b.upgrades.power_aspect_of_sol.l6 = {}
b.upgrades.power_aspect_of_sol.l6.damage_min = 120
b.upgrades.power_aspect_of_sol.l6.damage_max = 200
b.upgrades.power_teleportation_sigil = {}
b.upgrades.power_teleportation_sigil.l2a = {}
b.upgrades.power_teleportation_sigil.l2a.duration_factor = 2
b.upgrades.power_teleportation_sigil.l2a.s_duration_factor = 2
b.upgrades.power_teleportation_sigil.l2b = {}
b.upgrades.power_teleportation_sigil.l2b.slow_factor = 0.7
b.upgrades.power_teleportation_sigil.l2b.s_slow_factor = 0.3
b.upgrades.power_teleportation_sigil.l2b.slow_duration = 4
b.upgrades.power_teleportation_sigil.l3 = {}
b.upgrades.power_teleportation_sigil.l3.second_tp_chance = 0.3
b.upgrades.power_teleportation_sigil.l3.range = 50
b.upgrades.power_teleportation_sigil.l4a = {}
b.upgrades.power_teleportation_sigil.l4a.s_cd_reduction = 5
b.upgrades.power_teleportation_sigil.l4b = {}
b.upgrades.power_teleportation_sigil.l4b.max_tp_count = 6
b.upgrades.power_teleportation_sigil.l5a = {}
b.upgrades.power_teleportation_sigil.l5a.s_damage_red = 0.5
b.upgrades.power_teleportation_sigil.l5a.damage_red_duration = 5
b.upgrades.power_teleportation_sigil.l5a.silence_duration = 5
b.upgrades.power_teleportation_sigil.l5a.s_debuff_duration = 5
b.upgrades.power_teleportation_sigil.l5b = {}
b.upgrades.power_teleportation_sigil.l5b.stun_duration = 3
b.upgrades.power_teleportation_sigil.l6 = {}
b.upgrades.power_teleportation_sigil.l6.instakill_chance = 0.2
b.upgrades.power_teleportation_sigil.l6.instakill_min_hp = 50
b.upgrades.power_teleportation_sigil.l6.range = 50
b.upgrades.power_thunder_zapper = {}
b.upgrades.power_thunder_zapper.l2a = {}
b.upgrades.power_thunder_zapper.l2a.dmg_factor = 1.5
b.upgrades.power_thunder_zapper.l2a.s_dmg_factor = sub_one(b.upgrades.power_thunder_zapper.l2a.dmg_factor)
b.upgrades.power_thunder_zapper.l2b = {}
b.upgrades.power_thunder_zapper.l2b.duration_factor = 1.2
b.upgrades.power_thunder_zapper.l2b.s_duration_factor = 12
b.upgrades.power_thunder_zapper.l3 = {}
b.upgrades.power_thunder_zapper.l3.range = 100
b.upgrades.power_thunder_zapper.l3.cooldown = 2
b.upgrades.power_thunder_zapper.l3.min_targets = 1
b.upgrades.power_thunder_zapper.l3.damage_min = 25
b.upgrades.power_thunder_zapper.l3.damage_max = 35
b.upgrades.power_thunder_zapper.l3.damage_type = DAMAGE_TRUE
b.upgrades.power_thunder_zapper.l3.bounce_range = 100
b.upgrades.power_thunder_zapper.l3.bounce_damage_factor = 1
b.upgrades.power_thunder_zapper.l3.bounce_damage_factor_min = 1
b.upgrades.power_thunder_zapper.l3.bounce_damage_factor_inc = 0
b.upgrades.power_thunder_zapper.l4a = {}
b.upgrades.power_thunder_zapper.l4a.cd_reduction = 7.5
b.upgrades.power_thunder_zapper.l4b = {}
b.upgrades.power_thunder_zapper.l4b.slow_factor = 0.75
b.upgrades.power_thunder_zapper.l4b.s_slow_factor = slow_calc(b.upgrades.power_thunder_zapper.l4b.slow_factor)
b.upgrades.power_thunder_zapper.l4b.slow_duration = 1
b.upgrades.power_thunder_zapper.l5a = {}
b.upgrades.power_thunder_zapper.l5a.radius_factor = 1.25
b.upgrades.power_thunder_zapper.l5a.s_radius_factor = sub_one(b.upgrades.power_thunder_zapper.l5a.radius_factor)
b.upgrades.power_thunder_zapper.l5b = {}
b.upgrades.power_thunder_zapper.l5b.stun_duration = 3
b.upgrades.power_thunder_zapper.l6 = {}
b.upgrades.power_thunder_zapper.l6.cooldown = 3
b.upgrades.power_thunder_zapper.l6.damage_min = 80
b.upgrades.power_thunder_zapper.l6.damage_max = 125
b.upgrades.power_thunder_zapper.l6.damage_type = DAMAGE_TRUE
b.upgrades.power_thunder_zapper.l6.damage_radius = 120
b.upgrades.power_wintersongs_wrath = {}
b.upgrades.power_wintersongs_wrath.l2a = {}
b.upgrades.power_wintersongs_wrath.l2a.duration_factor = 1.5
b.upgrades.power_wintersongs_wrath.l2a.s_duration = 12
b.upgrades.power_wintersongs_wrath.l2b = {}
b.upgrades.power_wintersongs_wrath.l2b.radius_factor = 1.35
b.upgrades.power_wintersongs_wrath.l2b.s_radius_factor = sub_one(b.upgrades.power_wintersongs_wrath.l2b.radius_factor)
b.upgrades.power_wintersongs_wrath.l3 = {}
b.upgrades.power_wintersongs_wrath.l3.radius = 32
b.upgrades.power_wintersongs_wrath.l3.damage_min = 24
b.upgrades.power_wintersongs_wrath.l3.damage_max = 36
b.upgrades.power_wintersongs_wrath.l3.damage_type = DAMAGE_MAGICAL
b.upgrades.power_wintersongs_wrath.l3.spike_count = 3
b.upgrades.power_wintersongs_wrath.l3.distance_between_spikes = 5
b.upgrades.power_wintersongs_wrath.l3.delay_between_spikes = fts(3)
b.upgrades.power_wintersongs_wrath.l3.cast_delay = 0.05
b.upgrades.power_wintersongs_wrath.l4a = {}
b.upgrades.power_wintersongs_wrath.l4a.spike_count = 6
b.upgrades.power_wintersongs_wrath.l4b = {}
b.upgrades.power_wintersongs_wrath.l4b.slow_factor = 0.3
b.upgrades.power_wintersongs_wrath.l4b.s_slow_factor = 0.7
b.upgrades.power_wintersongs_wrath.l5a = {}
b.upgrades.power_wintersongs_wrath.l5a.damage_inc = 1.3
b.upgrades.power_wintersongs_wrath.l5a.s_damage_inc = sub_one(b.upgrades.power_wintersongs_wrath.l5a.damage_inc)
b.upgrades.power_wintersongs_wrath.l5b = {}
b.upgrades.power_wintersongs_wrath.l5b.stun_duration = 4
b.upgrades.power_wintersongs_wrath.l6 = {}
b.upgrades.power_wintersongs_wrath.l6.slow_factor = 0.5
b.upgrades.power_wintersongs_wrath.l6.s_slow_factor = 0.5
b.upgrades.power_wintersongs_wrath.l6.duration = 6
b.upgrades.power_musketeers = {}
b.upgrades.power_musketeers.l2a = {}
b.upgrades.power_musketeers.l2a.duration_inc = 4
b.upgrades.power_musketeers.l2b = {}
b.upgrades.power_musketeers.l2b.range_inc_factor = 1.2
b.upgrades.power_musketeers.l2b.s_range_factor = sub_one(b.upgrades.power_musketeers.l2b.range_inc_factor)
b.upgrades.power_musketeers.l2b.movement_factor = 1.2
b.upgrades.power_musketeers.l2b.s_movement_factor = sub_one(b.upgrades.power_musketeers.l2b.movement_factor)
b.upgrades.power_musketeers.l3 = {}
b.upgrades.power_musketeers.l3.attack_cooldown = 1.3
b.upgrades.power_musketeers.l3.s_attack_cooldown = 0.25
b.upgrades.power_musketeers.l3.damage_inc = 1.5
b.upgrades.power_musketeers.l3.s_damage_inc = sub_one(b.upgrades.power_musketeers.l3.damage_inc)
b.upgrades.power_musketeers.l4a = {}
b.upgrades.power_musketeers.l4a.extra_damage = 0.35
b.upgrades.power_musketeers.l4b = {}
b.upgrades.power_musketeers.l4b.reduce_armor_factor = 0.5
b.upgrades.power_musketeers.l5a = {}
b.upgrades.power_musketeers.l5a.attack_cooldown = 1
b.upgrades.power_musketeers.l5a.s_attack_cooldown = 0.25
b.upgrades.power_musketeers.l5a.cd_reduction = 2
b.upgrades.power_musketeers.l5b = {}
b.upgrades.power_musketeers.l5b.instakill_chance = 0.2
b.upgrades.power_musketeers.l5b.hp_threshold = 0.25
b.upgrades.power_musketeers.l6 = {}
b.upgrades.power_musketeers.l6.damage_radius = 50
b.upgrades.power_musketeers.l6.damage_min = 56
b.upgrades.power_musketeers.l6.damage_max = 80
b.upgrades.power_musketeers.l6.damage_type = DAMAGE_EXPLOSION
b.upgrades.power_musketeers.l6.stun_duration = 2
b.items = {}
b.items.hearts = {}
b.items.hearts.lives = 5
b.items.gold = {}
b.items.gold.gold = 500
b.items.bomb = {}
b.items.bomb.damage_min = 2000
b.items.bomb.damage_max = 2000
b.kr1_mode = {}
b.kr1_mode.towers = {}
b.kr1_mode.towers.archers = {}
b.kr1_mode.towers.archers.price = {
	70,
	110,
	160
}
b.kr1_mode.towers.archers.basic_attack = {}
b.kr1_mode.towers.archers.basic_attack.damage_min = {
	4,
	7,
	10
}
b.kr1_mode.towers.archers.basic_attack.damage_max = {
	6,
	11,
	16
}
b.kr1_mode.towers.archers.basic_attack.cooldown = {
	0.8,
	0.6,
	0.5
}
b.kr1_mode.towers.archers.basic_attack.range = {
	140,
	160,
	180
}
b.kr1_mode.towers.ranger = {}
b.kr1_mode.towers.ranger.price = 230
b.kr1_mode.towers.ranger.basic_attack = {}
b.kr1_mode.towers.ranger.basic_attack.damage_min = 13
b.kr1_mode.towers.ranger.basic_attack.damage_max = 19
b.kr1_mode.towers.ranger.basic_attack.cooldown = 0.4
b.kr1_mode.towers.ranger.basic_attack.range = 200
b.kr1_mode.towers.ranger.poison = {}
b.kr1_mode.towers.ranger.poison.price = {
	250,
	200,
	200
}
b.kr1_mode.towers.ranger.poison.mod = {}
b.kr1_mode.towers.ranger.poison.mod.duration = 3
b.kr1_mode.towers.ranger.poison.mod.damage_base = 0
b.kr1_mode.towers.ranger.poison.mod.damage_inc = 5
b.kr1_mode.towers.ranger.poison.mod.damage_every = 1
b.kr1_mode.towers.ranger.poison.mod.s0_damage_base = b.kr1_mode.towers.ranger.poison.mod.damage_base + b.kr1_mode.towers.ranger.poison.mod.damage_inc
b.kr1_mode.towers.ranger.poison.mod.s1_damage_base = b.kr1_mode.towers.ranger.poison.mod.s0_damage_base + b.kr1_mode.towers.ranger.poison.mod.damage_inc
b.kr1_mode.towers.ranger.poison.mod.s2_damage_base = b.kr1_mode.towers.ranger.poison.mod.s1_damage_base + b.kr1_mode.towers.ranger.poison.mod.damage_inc
b.kr1_mode.towers.ranger.thorn = {}
b.kr1_mode.towers.ranger.thorn.price = {
	250,
	150,
	150
}
b.kr1_mode.towers.ranger.thorn.mod = {}
b.kr1_mode.towers.ranger.thorn.mod.duration_base = 0.5
b.kr1_mode.towers.ranger.thorn.mod.duration_inc = 0.5
b.kr1_mode.towers.ranger.thorn.mod.s0_duration_base = b.kr1_mode.towers.ranger.thorn.mod.duration_base + b.kr1_mode.towers.ranger.thorn.mod.duration_inc
b.kr1_mode.towers.ranger.thorn.mod.s1_duration_base = b.kr1_mode.towers.ranger.thorn.mod.s0_duration_base + b.kr1_mode.towers.ranger.thorn.mod.duration_inc
b.kr1_mode.towers.ranger.thorn.mod.s2_duration_base = b.kr1_mode.towers.ranger.thorn.mod.s1_duration_base + b.kr1_mode.towers.ranger.thorn.mod.duration_inc
b.kr1_mode.towers.ranger.thorn.mod.damage_min = 20
b.kr1_mode.towers.ranger.thorn.mod.damage_max = 20
b.kr1_mode.towers.ranger.thorn.mod.s_damage_min_max = b.kr1_mode.towers.ranger.thorn.mod.damage_min * 2
b.kr1_mode.towers.ranger.thorn.mod.damage_every = 0.5
b.kr1_mode.towers.ranger.thorn.aura = {}
b.kr1_mode.towers.ranger.thorn.aura.cooldown = 10
b.kr1_mode.towers.ranger.thorn.aura.radius = 200
b.kr1_mode.towers.ranger.thorn.aura.max_count_base = 2
b.kr1_mode.towers.ranger.thorn.aura.max_count_inc = 2
b.kr1_mode.towers.musketeers = {}
b.kr1_mode.towers.musketeers.price = 230
b.kr1_mode.towers.musketeers.basic_attack = {}
b.kr1_mode.towers.musketeers.basic_attack.damage_min = 35
b.kr1_mode.towers.musketeers.basic_attack.damage_max = 65
b.kr1_mode.towers.musketeers.basic_attack.cooldown = 1.5
b.kr1_mode.towers.musketeers.basic_attack.range = 235
b.kr1_mode.towers.musketeers.sniper = {}
b.kr1_mode.towers.musketeers.sniper.price = {
	250,
	250,
	250
}
b.kr1_mode.towers.musketeers.sniper.cooldown = 14
b.kr1_mode.towers.musketeers.sniper.shoot_time = fts(30)
b.kr1_mode.towers.musketeers.sniper.damage_factor_inc = 0.2
b.kr1_mode.towers.musketeers.sniper.instakill_chance_inc = 0.2
b.kr1_mode.towers.musketeers.sniper.s0_instakill_chance = b.kr1_mode.towers.musketeers.sniper.instakill_chance_inc
b.kr1_mode.towers.musketeers.sniper.s1_instakill_chance = b.kr1_mode.towers.musketeers.sniper.s0_instakill_chance + b.kr1_mode.towers.musketeers.sniper.instakill_chance_inc
b.kr1_mode.towers.musketeers.sniper.s2_instakill_chance = b.kr1_mode.towers.musketeers.sniper.s1_instakill_chance + b.kr1_mode.towers.musketeers.sniper.instakill_chance_inc
b.kr1_mode.towers.musketeers.shrapnel = {}
b.kr1_mode.towers.musketeers.shrapnel.price = {
	250,
	250,
	250
}
b.kr1_mode.towers.musketeers.shrapnel.cooldown = 9
b.kr1_mode.towers.musketeers.shrapnel.range_factor = 0.5
b.kr1_mode.towers.musketeers.shrapnel.min_spread = 12.5
b.kr1_mode.towers.musketeers.shrapnel.max_spread = 32.5
b.kr1_mode.towers.musketeers.shrapnel.damage_min_base = 0
b.kr1_mode.towers.musketeers.shrapnel.damage_min_inc = 10
b.kr1_mode.towers.musketeers.shrapnel.damage_max_base = 0
b.kr1_mode.towers.musketeers.shrapnel.damage_max_inc = 40
b.kr1_mode.towers.musketeers.shrapnel.s_projectile = 6
b.kr1_mode.towers.musketeers.shrapnel.s0_damage_min_base = b.kr1_mode.towers.musketeers.shrapnel.damage_min_base + b.kr1_mode.towers.musketeers.shrapnel.damage_min_inc * b.kr1_mode.towers.musketeers.shrapnel.s_projectile
b.kr1_mode.towers.musketeers.shrapnel.s0_damage_max_base = b.kr1_mode.towers.musketeers.shrapnel.damage_max_base + b.kr1_mode.towers.musketeers.shrapnel.damage_max_inc * b.kr1_mode.towers.musketeers.shrapnel.s_projectile
b.kr1_mode.towers.musketeers.shrapnel.s1_damage_min_base = b.kr1_mode.towers.musketeers.shrapnel.s0_damage_min_base + b.kr1_mode.towers.musketeers.shrapnel.damage_min_inc * b.kr1_mode.towers.musketeers.shrapnel.s_projectile
b.kr1_mode.towers.musketeers.shrapnel.s1_damage_max_base = b.kr1_mode.towers.musketeers.shrapnel.s0_damage_max_base + b.kr1_mode.towers.musketeers.shrapnel.damage_max_inc * b.kr1_mode.towers.musketeers.shrapnel.s_projectile
b.kr1_mode.towers.musketeers.shrapnel.s2_damage_min_base = b.kr1_mode.towers.musketeers.shrapnel.s1_damage_min_base + b.kr1_mode.towers.musketeers.shrapnel.damage_min_inc * b.kr1_mode.towers.musketeers.shrapnel.s_projectile
b.kr1_mode.towers.musketeers.shrapnel.s2_damage_max_base = b.kr1_mode.towers.musketeers.shrapnel.s1_damage_max_base + b.kr1_mode.towers.musketeers.shrapnel.damage_max_inc * b.kr1_mode.towers.musketeers.shrapnel.s_projectile
b.kr1_mode.towers.musketeers.shrapnel.damage_radius = 48
b.kr1_mode.towers.barracks = {}
b.kr1_mode.towers.barracks.price = {
	70,
	110,
	160
}
b.kr1_mode.towers.barracks.rally_range = {
	145,
	145,
	145
}
b.kr1_mode.towers.barracks.soldier = {}
b.kr1_mode.towers.barracks.soldier.hp_max = {
	50,
	100,
	150
}
b.kr1_mode.towers.barracks.soldier.armor = {
	0,
	0.15,
	0.3
}
b.kr1_mode.towers.barracks.soldier.regen = {
	5,
	7,
	10
}
b.kr1_mode.towers.barracks.soldier.damage_min = {
	1,
	3,
	6
}
b.kr1_mode.towers.barracks.soldier.damage_max = {
	3,
	4,
	10
}
b.kr1_mode.towers.paladins = {}
b.kr1_mode.towers.paladins.price = 230
b.kr1_mode.towers.paladins.rally_range = 145
b.kr1_mode.towers.paladins.soldier = {}
b.kr1_mode.towers.paladins.soldier.hp_max = 200
b.kr1_mode.towers.paladins.soldier.armor = 0.5
b.kr1_mode.towers.paladins.soldier.regen = 25
b.kr1_mode.towers.paladins.soldier.damage_min = 12
b.kr1_mode.towers.paladins.soldier.damage_max = 18
b.kr1_mode.towers.paladins.soldier.movement_speed = 75
b.kr1_mode.towers.paladins.healing = {}
b.kr1_mode.towers.paladins.healing.price = {
	150,
	150,
	150
}
b.kr1_mode.towers.paladins.healing.cooldown = 10
b.kr1_mode.towers.paladins.healing.min_health_factor = 0.7
b.kr1_mode.towers.paladins.healing.mod = {}
b.kr1_mode.towers.paladins.healing.mod.heal_min_base = 0
b.kr1_mode.towers.paladins.healing.mod.heal_min_inc = 40
b.kr1_mode.towers.paladins.healing.mod.heal_max_base = 0
b.kr1_mode.towers.paladins.healing.mod.heal_max_inc = 60
b.kr1_mode.towers.paladins.healing.mod.s0_heal_min_base = b.kr1_mode.towers.paladins.healing.mod.heal_min_base + b.kr1_mode.towers.paladins.healing.mod.heal_min_inc
b.kr1_mode.towers.paladins.healing.mod.s0_heal_max_base = b.kr1_mode.towers.paladins.healing.mod.heal_max_base + b.kr1_mode.towers.paladins.healing.mod.heal_max_inc
b.kr1_mode.towers.paladins.healing.mod.s1_heal_min_base = b.kr1_mode.towers.paladins.healing.mod.s0_heal_min_base + b.kr1_mode.towers.paladins.healing.mod.heal_min_inc
b.kr1_mode.towers.paladins.healing.mod.s1_heal_max_base = b.kr1_mode.towers.paladins.healing.mod.s0_heal_max_base + b.kr1_mode.towers.paladins.healing.mod.heal_max_inc
b.kr1_mode.towers.paladins.healing.mod.s2_heal_min_base = b.kr1_mode.towers.paladins.healing.mod.s1_heal_min_base + b.kr1_mode.towers.paladins.healing.mod.heal_min_inc
b.kr1_mode.towers.paladins.healing.mod.s2_heal_max_base = b.kr1_mode.towers.paladins.healing.mod.s1_heal_max_base + b.kr1_mode.towers.paladins.healing.mod.heal_max_inc
b.kr1_mode.towers.paladins.shield = {}
b.kr1_mode.towers.paladins.shield.price = {
	200
}
b.kr1_mode.towers.paladins.shield.armor_inc = 0.15
b.kr1_mode.towers.paladins.holystrike = {}
b.kr1_mode.towers.paladins.holystrike.price = {
	200,
	125,
	125
}
b.kr1_mode.towers.paladins.holystrike.damage_radius = 50
b.kr1_mode.towers.paladins.holystrike.damage_min_base = 0
b.kr1_mode.towers.paladins.holystrike.damage_min_inc = 25
b.kr1_mode.towers.paladins.holystrike.damage_max_base = 0
b.kr1_mode.towers.paladins.holystrike.damage_max_inc = 45
b.kr1_mode.towers.paladins.holystrike.s0_damage_min_base = b.kr1_mode.towers.paladins.holystrike.damage_min_base + b.kr1_mode.towers.paladins.holystrike.damage_min_inc
b.kr1_mode.towers.paladins.holystrike.s0_damage_max_base = b.kr1_mode.towers.paladins.holystrike.damage_max_base + b.kr1_mode.towers.paladins.holystrike.damage_max_inc
b.kr1_mode.towers.paladins.holystrike.s1_damage_min_base = b.kr1_mode.towers.paladins.holystrike.s0_damage_min_base + b.kr1_mode.towers.paladins.holystrike.damage_min_inc
b.kr1_mode.towers.paladins.holystrike.s1_damage_max_base = b.kr1_mode.towers.paladins.holystrike.s0_damage_max_base + b.kr1_mode.towers.paladins.holystrike.damage_max_inc
b.kr1_mode.towers.paladins.holystrike.s2_damage_min_base = b.kr1_mode.towers.paladins.holystrike.s1_damage_min_base + b.kr1_mode.towers.paladins.holystrike.damage_min_inc
b.kr1_mode.towers.paladins.holystrike.s2_damage_max_base = b.kr1_mode.towers.paladins.holystrike.s1_damage_max_base + b.kr1_mode.towers.paladins.holystrike.damage_max_inc
b.kr1_mode.towers.barbarians = {}
b.kr1_mode.towers.barbarians.price = 230
b.kr1_mode.towers.barbarians.rally_range = 145
b.kr1_mode.towers.barbarians.soldier = {}
b.kr1_mode.towers.barbarians.soldier.hp_max = 250
b.kr1_mode.towers.barbarians.soldier.armor = 0
b.kr1_mode.towers.barbarians.soldier.regen = 30
b.kr1_mode.towers.barbarians.soldier.damage_min = 16
b.kr1_mode.towers.barbarians.soldier.damage_max = 24
b.kr1_mode.towers.barbarians.soldier.multi_hit_factor = {
	0.2,
	0.35,
	0.45
}
b.kr1_mode.towers.barbarians.soldier.movement_speed = 75
b.kr1_mode.towers.barbarians.dual = {}
b.kr1_mode.towers.barbarians.dual.price = {
	250,
	100,
	100
}
b.kr1_mode.towers.barbarians.dual.damage_inc = 5
b.kr1_mode.towers.barbarians.dual.twister_damage_inc = 20
b.kr1_mode.towers.barbarians.dual.s0_damage_inc = b.kr1_mode.towers.barbarians.dual.damage_inc * 2
b.kr1_mode.towers.barbarians.dual.s1_damage_inc = b.kr1_mode.towers.barbarians.dual.s0_damage_inc + b.kr1_mode.towers.barbarians.dual.damage_inc * 2
b.kr1_mode.towers.barbarians.dual.s2_damage_inc = b.kr1_mode.towers.barbarians.dual.s1_damage_inc + b.kr1_mode.towers.barbarians.dual.damage_inc * 2
b.kr1_mode.towers.barbarians.twister = {}
b.kr1_mode.towers.barbarians.twister.price = {
	150,
	100,
	100
}
b.kr1_mode.towers.barbarians.twister.damage_min = 5
b.kr1_mode.towers.barbarians.twister.damage_max = 25
b.kr1_mode.towers.barbarians.twister.s0_damage_min = b.kr1_mode.towers.barbarians.twister.damage_min + b.kr1_mode.towers.barbarians.dual.twister_damage_inc
b.kr1_mode.towers.barbarians.twister.s0_damage_max = b.kr1_mode.towers.barbarians.twister.damage_max + b.kr1_mode.towers.barbarians.dual.twister_damage_inc
b.kr1_mode.towers.barbarians.twister.s1_damage_min = b.kr1_mode.towers.barbarians.twister.s0_damage_min + b.kr1_mode.towers.barbarians.dual.twister_damage_inc
b.kr1_mode.towers.barbarians.twister.s1_damage_max = b.kr1_mode.towers.barbarians.twister.s0_damage_max + b.kr1_mode.towers.barbarians.dual.twister_damage_inc
b.kr1_mode.towers.barbarians.twister.s2_damage_min = b.kr1_mode.towers.barbarians.twister.s1_damage_min + b.kr1_mode.towers.barbarians.dual.twister_damage_inc
b.kr1_mode.towers.barbarians.twister.s2_damage_max = b.kr1_mode.towers.barbarians.twister.s1_damage_max + b.kr1_mode.towers.barbarians.dual.twister_damage_inc
b.kr1_mode.towers.barbarians.twister.damage_radius = 50
b.kr1_mode.towers.barbarians.twister.chance_base = 0.1
b.kr1_mode.towers.barbarians.twister.chance_inc = 0.05
b.kr1_mode.towers.barbarians.twister.s0_chance_base = b.kr1_mode.towers.barbarians.twister.chance_base + b.kr1_mode.towers.barbarians.twister.chance_inc
b.kr1_mode.towers.barbarians.twister.s1_chance_base = b.kr1_mode.towers.barbarians.twister.s0_chance_base + b.kr1_mode.towers.barbarians.twister.chance_inc
b.kr1_mode.towers.barbarians.twister.s2_chance_base = b.kr1_mode.towers.barbarians.twister.s1_chance_base + b.kr1_mode.towers.barbarians.twister.chance_inc
b.kr1_mode.towers.barbarians.throwing = {}
b.kr1_mode.towers.barbarians.throwing.price = {
	200,
	100,
	100
}
b.kr1_mode.towers.barbarians.throwing.cooldown = 2.5
b.kr1_mode.towers.barbarians.throwing.min_range = 55
b.kr1_mode.towers.barbarians.throwing.max_range = 155
b.kr1_mode.towers.barbarians.throwing.range_inc = 13
b.kr1_mode.towers.barbarians.throwing.bullet = {}
b.kr1_mode.towers.barbarians.throwing.bullet.damage_min = 24
b.kr1_mode.towers.barbarians.throwing.bullet.damage_max = 32
b.kr1_mode.towers.barbarians.throwing.bullet.damage_inc = 10
b.kr1_mode.towers.barbarians.throwing.bullet.s0_damage_min = b.kr1_mode.towers.barbarians.throwing.bullet.damage_min + b.kr1_mode.towers.barbarians.throwing.bullet.damage_inc
b.kr1_mode.towers.barbarians.throwing.bullet.s0_damage_max = b.kr1_mode.towers.barbarians.throwing.bullet.damage_max + b.kr1_mode.towers.barbarians.throwing.bullet.damage_inc
b.kr1_mode.towers.barbarians.throwing.bullet.s1_damage_min = b.kr1_mode.towers.barbarians.throwing.bullet.s0_damage_min + b.kr1_mode.towers.barbarians.throwing.bullet.damage_inc
b.kr1_mode.towers.barbarians.throwing.bullet.s1_damage_max = b.kr1_mode.towers.barbarians.throwing.bullet.s0_damage_max + b.kr1_mode.towers.barbarians.throwing.bullet.damage_inc
b.kr1_mode.towers.barbarians.throwing.bullet.s2_damage_min = b.kr1_mode.towers.barbarians.throwing.bullet.s1_damage_min + b.kr1_mode.towers.barbarians.throwing.bullet.damage_inc
b.kr1_mode.towers.barbarians.throwing.bullet.s2_damage_max = b.kr1_mode.towers.barbarians.throwing.bullet.s1_damage_max + b.kr1_mode.towers.barbarians.throwing.bullet.damage_inc
b.kr1_mode.towers.mages = {}
b.kr1_mode.towers.mages.prices = {
	100,
	160,
	240
}
b.kr1_mode.towers.mages.basic_attack = {}
b.kr1_mode.towers.mages.basic_attack.damage_min = {
	9,
	23,
	40
}
b.kr1_mode.towers.mages.basic_attack.damage_max = {
	17,
	43,
	74
}
b.kr1_mode.towers.mages.basic_attack.cooldown = {
	1.5,
	1.5,
	1.5
}
b.kr1_mode.towers.mages.basic_attack.range = {
	140,
	160,
	180
}
b.kr1_mode.towers.arcane = {}
b.kr1_mode.towers.arcane.prices = 300
b.kr1_mode.towers.arcane.basic_attack = {}
b.kr1_mode.towers.arcane.basic_attack.damage_min = 76
b.kr1_mode.towers.arcane.basic_attack.damage_max = 140
b.kr1_mode.towers.arcane.basic_attack.cooldown = 2
b.kr1_mode.towers.arcane.basic_attack.range = 200
b.kr1_mode.towers.arcane.disintegrate = {}
b.kr1_mode.towers.arcane.disintegrate.price = {
	300,
	150,
	150
}
b.kr1_mode.towers.arcane.disintegrate.cooldown_base = 22
b.kr1_mode.towers.arcane.disintegrate.cooldown_inc = -2
b.kr1_mode.towers.arcane.disintegrate.s1_cooldown_base = b.kr1_mode.towers.arcane.disintegrate.cooldown_base + b.kr1_mode.towers.arcane.disintegrate.cooldown_inc
b.kr1_mode.towers.arcane.disintegrate.s2_cooldown_base = b.kr1_mode.towers.arcane.disintegrate.s1_cooldown_base + b.kr1_mode.towers.arcane.disintegrate.cooldown_inc
b.kr1_mode.towers.arcane.teleport = {}
b.kr1_mode.towers.arcane.teleport.price = {
	300,
	100,
	100
}
b.kr1_mode.towers.arcane.teleport.cooldown = 14
b.kr1_mode.towers.arcane.teleport.max_count_base = 3
b.kr1_mode.towers.arcane.teleport.max_count_inc = 1
b.kr1_mode.towers.arcane.teleport.s1_max_count_base = b.kr1_mode.towers.arcane.teleport.max_count_base + b.kr1_mode.towers.arcane.teleport.max_count_inc
b.kr1_mode.towers.arcane.teleport.s2_max_count_base = b.kr1_mode.towers.arcane.teleport.s1_max_count_base + b.kr1_mode.towers.arcane.teleport.max_count_inc
b.kr1_mode.towers.arcane.teleport.aura = {}
b.kr1_mode.towers.arcane.teleport.aura.radius = 42.5
b.kr1_mode.towers.sorcerer = {}
b.kr1_mode.towers.sorcerer.prices = 300
b.kr1_mode.towers.sorcerer.rally_range = 180
b.kr1_mode.towers.sorcerer.basic_attack = {}
b.kr1_mode.towers.sorcerer.basic_attack.damage_min = 30
b.kr1_mode.towers.sorcerer.basic_attack.damage_max = 64
b.kr1_mode.towers.sorcerer.basic_attack.cooldown = 1.5
b.kr1_mode.towers.sorcerer.basic_attack.range = 200
b.kr1_mode.towers.sorcerer.basic_attack.mod_armor = {}
b.kr1_mode.towers.sorcerer.basic_attack.mod_armor.duration = 5
b.kr1_mode.towers.sorcerer.basic_attack.mod_armor.armor_red_factor = -0.5
b.kr1_mode.towers.sorcerer.basic_attack.mod_dps = {}
b.kr1_mode.towers.sorcerer.basic_attack.mod_dps.duration = 5
b.kr1_mode.towers.sorcerer.basic_attack.mod_dps.damage_min = 10
b.kr1_mode.towers.sorcerer.basic_attack.mod_dps.damage_max = 10
b.kr1_mode.towers.sorcerer.basic_attack.mod_dps.damage_every = 1.25
b.kr1_mode.towers.sorcerer.polymorph = {}
b.kr1_mode.towers.sorcerer.polymorph.price = {
	250,
	100,
	100
}
b.kr1_mode.towers.sorcerer.polymorph.cooldown_base = 22
b.kr1_mode.towers.sorcerer.polymorph.cooldown_inc = -2
b.kr1_mode.towers.sorcerer.polymorph.s1_cooldown_base = b.kr1_mode.towers.sorcerer.polymorph.cooldown_base + b.kr1_mode.towers.sorcerer.polymorph.cooldown_inc
b.kr1_mode.towers.sorcerer.polymorph.s2_cooldown_base = b.kr1_mode.towers.sorcerer.polymorph.s1_cooldown_base + b.kr1_mode.towers.sorcerer.polymorph.cooldown_inc
b.kr1_mode.towers.sorcerer.polymorph.mod = {}
b.kr1_mode.towers.sorcerer.polymorph.mod.transfer_health_factor = 0.5
b.kr1_mode.towers.sorcerer.polymorph.mod.transfer_speed_factor = 0.8
b.kr1_mode.towers.sorcerer.elemental = {}
b.kr1_mode.towers.sorcerer.elemental.price = {
	350,
	150,
	150
}
b.kr1_mode.towers.sorcerer.elemental.soldier = {}
b.kr1_mode.towers.sorcerer.elemental.soldier.melee_range = 75
b.kr1_mode.towers.sorcerer.elemental.soldier.regen = 20
b.kr1_mode.towers.sorcerer.elemental.soldier.armor_base = 0.3
b.kr1_mode.towers.sorcerer.elemental.soldier.armor_inc = 0.1
b.kr1_mode.towers.sorcerer.elemental.soldier.hp_max_base = 500
b.kr1_mode.towers.sorcerer.elemental.soldier.hp_max_inc = 100
b.kr1_mode.towers.sorcerer.elemental.soldier.attack_cooldown = 2
b.kr1_mode.towers.sorcerer.elemental.soldier.damage_min = 20
b.kr1_mode.towers.sorcerer.elemental.soldier.damage_max = 40
b.kr1_mode.towers.sorcerer.elemental.soldier.damage_inc = 10
b.kr1_mode.towers.sorcerer.elemental.soldier.damage_radius = 37.5
b.kr1_mode.towers.engineers = {}
b.kr1_mode.towers.engineers.prices = {
	125,
	220,
	320
}
b.kr1_mode.towers.engineers.basic_attack = {}
b.kr1_mode.towers.engineers.basic_attack.damage_min = {
	8,
	20,
	30
}
b.kr1_mode.towers.engineers.basic_attack.damage_max = {
	15,
	40,
	60
}
b.kr1_mode.towers.engineers.basic_attack.cooldown = {
	3,
	3,
	3
}
b.kr1_mode.towers.engineers.basic_attack.range = {
	160,
	160,
	160
}
b.kr1_mode.towers.engineers.basic_attack.damage_radius = {
	62.400000000000006,
	62.400000000000006,
	67.2
}
b.kr1_mode.towers.bfg = {}
b.kr1_mode.towers.bfg.prices = 400
b.kr1_mode.towers.bfg.basic_attack = {}
b.kr1_mode.towers.bfg.basic_attack.damage_min = 50
b.kr1_mode.towers.bfg.basic_attack.damage_max = 100
b.kr1_mode.towers.bfg.basic_attack.damage_radius = 67.5
b.kr1_mode.towers.bfg.basic_attack.cooldown = 3
b.kr1_mode.towers.bfg.basic_attack.range = 180
b.kr1_mode.towers.bfg.missile = {}
b.kr1_mode.towers.bfg.missile.price = {
	200,
	100,
	100
}
b.kr1_mode.towers.bfg.missile.range_base = 180
b.kr1_mode.towers.bfg.missile.range_inc_factor = 0.2
b.kr1_mode.towers.bfg.missile.damage_inc = 40
b.kr1_mode.towers.bfg.missile.cooldown_mixed = 14.1
b.kr1_mode.towers.bfg.missile.cooldown_flying = 6.5
b.kr1_mode.towers.bfg.missile.bullet = {}
b.kr1_mode.towers.bfg.missile.bullet.damage_min = 60
b.kr1_mode.towers.bfg.missile.bullet.damage_max = 100
b.kr1_mode.towers.bfg.missile.bullet.s0_damage_min = b.kr1_mode.towers.bfg.missile.bullet.damage_min + b.kr1_mode.towers.bfg.missile.damage_inc
b.kr1_mode.towers.bfg.missile.bullet.s0_damage_max = b.kr1_mode.towers.bfg.missile.bullet.damage_max + b.kr1_mode.towers.bfg.missile.damage_inc
b.kr1_mode.towers.bfg.missile.bullet.s1_damage_min = b.kr1_mode.towers.bfg.missile.bullet.s0_damage_min + b.kr1_mode.towers.bfg.missile.damage_inc
b.kr1_mode.towers.bfg.missile.bullet.s1_damage_max = b.kr1_mode.towers.bfg.missile.bullet.s0_damage_max + b.kr1_mode.towers.bfg.missile.damage_inc
b.kr1_mode.towers.bfg.missile.bullet.s2_damage_min = b.kr1_mode.towers.bfg.missile.bullet.s1_damage_min + b.kr1_mode.towers.bfg.missile.damage_inc
b.kr1_mode.towers.bfg.missile.bullet.s2_damage_max = b.kr1_mode.towers.bfg.missile.bullet.s1_damage_max + b.kr1_mode.towers.bfg.missile.damage_inc
b.kr1_mode.towers.bfg.missile.bullet.damage_radius = 41.25
b.kr1_mode.towers.bfg.cluster = {}
b.kr1_mode.towers.bfg.cluster.cooldown = 17
b.kr1_mode.towers.bfg.cluster.price = {
	200,
	150,
	150
}
b.kr1_mode.towers.bfg.cluster.fragment_count_base = 1
b.kr1_mode.towers.bfg.cluster.fragment_count_inc = 2
b.kr1_mode.towers.bfg.cluster.s0_fragment_count_base = b.kr1_mode.towers.bfg.cluster.fragment_count_base + b.kr1_mode.towers.bfg.cluster.fragment_count_inc
b.kr1_mode.towers.bfg.cluster.s1_fragment_count_base = b.kr1_mode.towers.bfg.cluster.s0_fragment_count_base + b.kr1_mode.towers.bfg.cluster.fragment_count_inc
b.kr1_mode.towers.bfg.cluster.s2_fragment_count_base = b.kr1_mode.towers.bfg.cluster.s1_fragment_count_base + b.kr1_mode.towers.bfg.cluster.fragment_count_inc
b.kr1_mode.towers.bfg.cluster.fragment = {}
b.kr1_mode.towers.bfg.cluster.fragment.damage_min = 60
b.kr1_mode.towers.bfg.cluster.fragment.damage_max = 80
b.kr1_mode.towers.bfg.cluster.fragment.damage_radius = 52.5
b.kr1_mode.towers.tesla = {}
b.kr1_mode.towers.tesla.prices = 400
b.kr1_mode.towers.tesla.basic_attack = {}
b.kr1_mode.towers.tesla.basic_attack.damage_min = 70
b.kr1_mode.towers.tesla.basic_attack.damage_max = 100
b.kr1_mode.towers.tesla.basic_attack.cooldown = 2.2
b.kr1_mode.towers.tesla.basic_attack.bounce_range = 95
b.kr1_mode.towers.tesla.basic_attack.bounce_damage_factor = 0.5
b.kr1_mode.towers.tesla.basic_attack.bounce_damage_factor_min = 0.5
b.kr1_mode.towers.tesla.basic_attack.bounce_damage_factor_inc = 0
b.kr1_mode.towers.tesla.basic_attack.range = 165
b.kr1_mode.towers.tesla.bolt = {}
b.kr1_mode.towers.tesla.bolt.price = {
	200,
	200
}
b.kr1_mode.towers.tesla.bolt.jump_base = 3
b.kr1_mode.towers.tesla.bolt.jump_inc = 1
b.kr1_mode.towers.tesla.bolt.s0_jump_base = b.kr1_mode.towers.tesla.bolt.jump_base + b.kr1_mode.towers.tesla.bolt.jump_inc
b.kr1_mode.towers.tesla.bolt.s1_jump_base = b.kr1_mode.towers.tesla.bolt.s0_jump_base + b.kr1_mode.towers.tesla.bolt.jump_inc
b.kr1_mode.towers.tesla.overcharge = {}
b.kr1_mode.towers.tesla.overcharge.price = {
	250,
	125,
	125
}
b.kr1_mode.towers.tesla.overcharge.aura = {}
b.kr1_mode.towers.tesla.overcharge.aura.radius = 165
b.kr1_mode.towers.tesla.overcharge.aura.damage_min = 0
b.kr1_mode.towers.tesla.overcharge.aura.damage_max = 8
b.kr1_mode.towers.tesla.overcharge.aura.damage_inc = 8
b.kr1_mode.towers.tesla.overcharge.aura.s0_damage_min = b.kr1_mode.towers.tesla.overcharge.aura.damage_min + b.kr1_mode.towers.tesla.overcharge.aura.damage_inc
b.kr1_mode.towers.tesla.overcharge.aura.s0_damage_max = b.kr1_mode.towers.tesla.overcharge.aura.damage_max + b.kr1_mode.towers.tesla.overcharge.aura.damage_inc
b.kr1_mode.towers.tesla.overcharge.aura.s1_damage_min = b.kr1_mode.towers.tesla.overcharge.aura.s0_damage_min + b.kr1_mode.towers.tesla.overcharge.aura.damage_inc
b.kr1_mode.towers.tesla.overcharge.aura.s1_damage_max = b.kr1_mode.towers.tesla.overcharge.aura.s0_damage_max + b.kr1_mode.towers.tesla.overcharge.aura.damage_inc
b.kr1_mode.towers.tesla.overcharge.aura.s2_damage_min = b.kr1_mode.towers.tesla.overcharge.aura.s1_damage_min + b.kr1_mode.towers.tesla.overcharge.aura.damage_inc
b.kr1_mode.towers.tesla.overcharge.aura.s2_damage_max = b.kr1_mode.towers.tesla.overcharge.aura.s1_damage_max + b.kr1_mode.towers.tesla.overcharge.aura.damage_inc
b.kr1_mode.upgrades = {}
b.kr1_mode.upgrades.archers = {}
b.kr1_mode.upgrades.archers.archer_salvage = {}
b.kr1_mode.upgrades.archers.archer_salvage.refund_factor = 0.9
b.kr1_mode.upgrades.archers.archer_eagle_eye = {}
b.kr1_mode.upgrades.archers.archer_eagle_eye.range_factor = 1.1
b.kr1_mode.upgrades.archers.archer_piercing = {}
b.kr1_mode.upgrades.archers.archer_piercing.reduce_armor_factor = 0.1
b.kr1_mode.upgrades.archers.archer_far_shots = {}
b.kr1_mode.upgrades.archers.archer_far_shots.range_factor = 1.1
b.kr1_mode.upgrades.archers.archer_precision = {}
b.kr1_mode.upgrades.archers.archer_precision.chance = 0.1
b.kr1_mode.upgrades.archers.archer_precision.damage_factor = 2
b.kr1_mode.upgrades.barracks = {}
b.kr1_mode.upgrades.barracks.barrack_survival = {}
b.kr1_mode.upgrades.barracks.barrack_survival.health_factor = 1.1
b.kr1_mode.upgrades.barracks.barrack_better_armor = {}
b.kr1_mode.upgrades.barracks.barrack_better_armor.armor_increase = 0.1
b.kr1_mode.upgrades.barracks.barrack_improved_deployment = {}
b.kr1_mode.upgrades.barracks.barrack_improved_deployment.cooldown_factor = 0.8
b.kr1_mode.upgrades.barracks.barrack_improved_deployment.rally_range_factor = 1.2
b.kr1_mode.upgrades.barracks.barrack_survival_2 = {}
b.kr1_mode.upgrades.barracks.barrack_survival_2.health_factor = 1.0909
b.kr1_mode.upgrades.barracks.barrack_barbed_armor = {}
b.kr1_mode.upgrades.barracks.barrack_barbed_armor.spiked_armor_factor = 0.1
b.kr1_mode.upgrades.mages = {}
b.kr1_mode.upgrades.mages.mage_spell_reach = {}
b.kr1_mode.upgrades.mages.mage_spell_reach.range_factor = 1.08
b.kr1_mode.upgrades.mages.mage_arcane_shatter = {}
b.kr1_mode.upgrades.mages.mage_arcane_shatter.mr_red = 0.03
b.kr1_mode.upgrades.mages.mage_hermetic_study = {}
b.kr1_mode.upgrades.mages.mage_hermetic_study.cost_factor = 0.9
b.kr1_mode.upgrades.mages.mage_empowered_magic = {}
b.kr1_mode.upgrades.mages.mage_empowered_magic.damage_factor = 1.15
b.kr1_mode.upgrades.engineers = {}
b.kr1_mode.upgrades.engineers.engineer_concentrated_fire = {}
b.kr1_mode.upgrades.engineers.engineer_concentrated_fire.damage_factor = 1.1
b.kr1_mode.upgrades.engineers.engineer_range_finder = {}
b.kr1_mode.upgrades.engineers.engineer_range_finder.range_factor = 1.1
b.kr1_mode.upgrades.engineers.engineer_field_logistics = {}
b.kr1_mode.upgrades.engineers.engineer_field_logistics.cost_factor = 0.9
b.kr1_mode.upgrades.engineers.engineer_industrialization = {}
b.kr1_mode.upgrades.engineers.engineer_industrialization.cost_factor = 0.75

return b
