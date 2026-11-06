-- chunkname: @./kr3/data/game_animations_merge_g4.lua
-- AUTO-GENERATED: merged from kr3/data/animations by file LastWriteTime.
-- Group: LastWriteTime >= 2026-06-01 00:00:00
-- File count: 37

local out = { animations = {} }

local function __merge_animations(d)
	if d == nil then
		return
	end

	if d.animations ~= nil then
		out = table.deepmerge(out, d)
	else
		out = table.deepmerge(out, { animations = d })
	end
end

-- BEGIN kr3/data/animations/alpha_acid.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/alpha_acid.lua

local a = {
	alpha_acid_sheep_fly_out = {
		prefix = "alpha_acid_sheep",
		to = 28,
		from = 1
	},
	alpha_acid_sheep_walk = {
		prefix = "alpha_acid_sheep",
		to = 35,
		from = 29
	},
	alpha_acid_sheep_death = {
		prefix = "alpha_acid_sheep",
		to = 45,
		from = 36
	},
	alpha_acid_sheep_projectile = {
		prefix = "alpha_acid_sheep",
		to = 49,
		from = 46
	},
	alpha_acid_sheep_idle = {
		prefix = "alpha_acid_sheep",
		to = 65,
		from = 50
	},
	alpha_acid_modifier_run = {
		prefix = "alpha_acid_modifier",
		to = 27,
		from = 1
	},
	alpha_acid_shadow = {
		prefix = "alpha_acid_shadow",
		to = 1,
		from = 1
	},
	alpha_acid_hit_run = {
		prefix = "alpha_acid_hit",
		to = 15,
		from = 1
	},
	alpha_acid_trail2_run = {
		prefix = "alpha_acid_trail2",
		to = 10,
		from = 1
	},
	alpha_acid_projectile2_flying = {
		prefix = "alpha_acid_projectile2",
		to = 8,
		from = 1
	},
	alpha_acid_creep_idle = {
		prefix = "alpha_acid_creep",
		to = 27,
		from = 1
	},
	alpha_acid_creep_run = {
		prefix = "alpha_acid_creep",
		to = 54,
		from = 28
	},
	alpha_acid_creep_run_front = {
		prefix = "alpha_acid_creep",
		to = 81,
		from = 55
	},
	alpha_acid_creep_run_back = {
		prefix = "alpha_acid_creep",
		to = 106,
		from = 82
	},
	alpha_acid_creep_attack = {
		prefix = "alpha_acid_creep",
		to = 134,
		from = 107
	},
	alpha_acid_creep_evolve = {
		prefix = "alpha_acid_creep",
		to = 180,
		from = 135
	},
	alpha_acid_creep_death = {
		prefix = "alpha_acid_creep",
		to = 228,
		from = 181
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/alpha_acid.lua

-- BEGIN kr3/data/animations/basic_acid.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/basic_acid.lua

local a = {
	acid_basic_trail_run = {
		prefix = "acid_basic_trail",
		to = 10,
		from = 1
	},
	acid_basic_proyectil_idle = {
		prefix = "acid_basic_proyectil",
		to = 8,
		from = 1
	},
	acid_basic_hit_run = {
		prefix = "acid_basic_hit",
		to = 15,
		from = 1
	},
	acid_basic_creep_idle = {
		prefix = "acid_basic_creep",
		to = 1,
		from = 1
	},
	acid_basic_creep_walk = {
		prefix = "acid_basic_creep",
		to = 21,
		from = 2
	},
	acid_basic_creep_walk_down = {
		prefix = "acid_basic_creep",
		to = 41,
		from = 22
	},
	acid_basic_creep_walk_up = {
		prefix = "acid_basic_creep",
		to = 61,
		from = 42
	},
	acid_basic_creep_melee_attk = {
		prefix = "acid_basic_creep",
		to = 88,
		from = 62
	},
	acid_basic_creep_ranged_attk = {
		prefix = "acid_basic_creep",
		to = 126,
		from = 89
	},
	acid_basic_creep_death = {
		prefix = "acid_basic_creep",
		to = 155,
		from = 127
	},
	acid_basic_creep_raise = {
		prefix = "acid_basic_creep",
		to = 213,
		from = 156
	},
	acid_basic_creep_evolve_in = {
		prefix = "acid_basic_creep",
		to = 249,
		from = 214
	},
	acid_basic_creep_evolve_loop = {
		prefix = "acid_basic_creep",
		to = 303,
		from = 250
	},
	acid_basic_creep_evolve_out = {
		prefix = "acid_basic_creep",
		to = 351,
		from = 304
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/basic_acid.lua

-- BEGIN kr3/data/animations/enemy_alfa_lava.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/enemy_alfa_lava.lua

local a = {
	lava_alpha_decal_in = {
		prefix = "lava_alpha_decal",
		to = 28,
		from = 1
	},
	lava_alpha_decal_loop = {
		prefix = "lava_alpha_decal",
		to = 40,
		from = 29
	},
	lava_alpha_decal_death = {
		prefix = "lava_alpha_decal",
		to = 75,
		from = 41
	},
	lava_alpha_decal_out = {
		prefix = "lava_alpha_decal",
		to = 110,
		from = 76
	},
	lava_alpha_trail_run = {
		prefix = "lava_alpha_trail",
		to = 16,
		from = 1
	},
	lava_alpha_proyectil_run = {
		prefix = "lava_alpha_proyectil",
		to = 12,
		from = 1
	},
	lava_alpha_creep_idle = {
		prefix = "lava_alpha_creep",
		to = 1,
		from = 1
	},
	lava_alpha_creep_walk = {
		prefix = "lava_alpha_creep",
		to = 39,
		from = 2
	},
	lava_alpha_creep_walk_down = {
		prefix = "lava_alpha_creep",
		to = 77,
		from = 40
	},
	lava_alpha_creep_walk_up = {
		prefix = "lava_alpha_creep",
		to = 115,
		from = 78
	},
	lava_alpha_creep_mele = {
		prefix = "lava_alpha_creep",
		to = 153,
		from = 116
	},
	lava_alpha_creep_puke = {
		prefix = "lava_alpha_creep",
		to = 241,
		from = 154
	},
	lava_alpha_creep_death = {
		prefix = "lava_alpha_creep",
		to = 289,
		from = 242
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/enemy_alfa_lava.lua

-- BEGIN kr3/data/animations/enemy_alfa_shadow.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/enemy_alfa_shadow.lua

local a = {
	shadow_alpha_proyectile_idle = {
		prefix = "mydrias_proyectile",
		to = 16,
		from = 7
	},
	shadow_alpha_teleport_trail_run = {
		prefix = "shadow_alpha_teleport_trail",
		to = 8,
		from = 1
	},
	shadow_alpha_teleport_projectile = {
		prefix = "shadow_alpha_teleport_projectile",
		to = 2,
		from = 1
	},
	shadow_alpha_creep_teleport_loop = {
		prefix = "shadow_alpha_teleport_projectile",
		to = 2,
		from = 1
	},
	shadow_alpha_teleport_floor_run = {
		prefix = "shadow_alpha_teleport_floor",
		to = 18,
		from = 1
	},
	shadow_alpha_hit_mele_bolt_run = {
		prefix = "shadow_alpha_hit_mele_bolt",
		to = 12,
		from = 1
	},
	shadow_alpha_hit_mele_run = {
		prefix = "shadow_alpha_hit_mele",
		to = 12,
		from = 1
	},
	shadow_alpha_creep_idle = {
		prefix = "shadow_alpha_creep",
		to = 18,
		from = 1
	},
	shadow_alpha_creep_walk = {
		prefix = "shadow_alpha_creep",
		to = 36,
		from = 19
	},
	shadow_alpha_creep_walk_down = {
		prefix = "shadow_alpha_creep",
		to = 54,
		from = 37
	},
	shadow_alpha_creep_fly_down = {
		prefix = "shadow_alpha_creep",
		to = 72,
		from = 55
	},
	shadow_alpha_creep_mele = {
		prefix = "shadow_alpha_creep",
		to = 101,
		from = 73
	},
	shadow_alpha_creep_ranged = {
		prefix = "shadow_alpha_creep",
		to = 141,
		from = 102
	},
	shadow_alpha_creep_teleport_in = {
		prefix = "shadow_alpha_creep",
		to = 189,
		from = 142
	},
	shadow_alpha_creep_teleport_out = {
		prefix = "shadow_alpha_creep",
		to = 266,
		from = 190
	},
	shadow_alpha_creep_death = {
		prefix = "shadow_alpha_creep",
		to = 379,
		from = 267
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/enemy_alfa_shadow.lua

-- BEGIN kr3/data/animations/enemy_alfa_storm.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/enemy_alfa_storm.lua

local a = {
	alpha_storm_hit_run = {
		prefix = "alpha_storm_hit",
		to = 20,
		from = 1
	},
	alpha_storm_ray_stun_run = {
		prefix = "alpha_storm_ray_stun",
		to = 25,
		from = 1
	},
	alpha_storm_stun_tower_fx_run = {
		prefix = "alpha_storm_stun_tower_fx",
		to = 15,
		from = 1
	},
	alpha_storm_modifier_creep_run = {
		prefix = "alpha_storm_modifier_creep",
		to = 23,
		from = 1
	},
	alpha_storm_projectil = {
		prefix = "alpha_storm_projectil",
		to = 8,
		from = 1
	},
	alpha_storm_fx_skill_in = {
		prefix = "alpha_storm_fx_skill",
		to = 42,
		from = 1
	},
	alpha_storm_fx_skill_loop = {
		prefix = "alpha_storm_fx_skill",
		to = 82,
		from = 43
	},
	alpha_storm_fx_skill_out = {
		prefix = "alpha_storm_fx_skill",
		to = 124,
		from = 83
	},
	alpha_storm_creep_idle = {
		prefix = "alpha_storm_creep",
		to = 1,
		from = 1
	},
	alpha_storm_creep_basic_attack = {
		prefix = "alpha_storm_creep",
		to = 41,
		from = 2
	},
	alpha_storm_creep_run = {
		prefix = "alpha_storm_creep",
		to = 83,
		from = 42
	},
	alpha_storm_creep_run_front = {
		prefix = "alpha_storm_creep",
		to = 125,
		from = 84
	},
	alpha_storm_creep_run_back = {
		prefix = "alpha_storm_creep",
		to = 167,
		from = 126
	},
	alpha_storm_creep_stun_tower = {
		prefix = "alpha_storm_creep",
		to = 269,
		from = 168
	},
	alpha_storm_creep_evolve_in = {
		prefix = "alpha_storm_creep",
		to = 291,
		from = 270
	},
	alpha_storm_creep_evolve_loop = {
		prefix = "alpha_storm_creep",
		to = 333,
		from = 292
	},
	alpha_storm_creep_evolve_out = {
		prefix = "alpha_storm_creep",
		to = 361,
		from = 334
	},
	alpha_storm_creep_evolve_bloq = {
		prefix = "alpha_storm_creep",
		to = 383,
		from = 362
	},
	alpha_storm_creep_spell = {
		prefix = "alpha_storm_creep",
		to = 431,
		from = 384
	},
	alpha_storm_creep_death = {
		prefix = "alpha_storm_creep",
		to = 531,
		from = 432
	},
	alpha_storm_decal_in = {
		prefix = "alpha_storm_decal",
		to = 22,
		from = 1
	},
	alpha_storm_decal_loop = {
		prefix = "alpha_storm_decal",
		to = 64,
		from = 23
	},
	alpha_storm_decal_out = {
		prefix = "alpha_storm_decal",
		to = 73,
		from = 65
	},
	alpha_storm_select_evolve_run = {
		prefix = "alpha_storm_select_evolve",
		to = 10,
		from = 1
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/enemy_alfa_storm.lua

-- BEGIN kr3/data/animations/enemy_basic_lava.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/enemy_basic_lava.lua

local a = {
	lava_basic_creep_idle = {
		prefix = "lava_basic_creep",
		to = 1,
		from = 1
	},
	lava_basic_creep_walk = {
		prefix = "lava_basic_creep",
		to = 21,
		from = 2
	},
	lava_basic_creep_walk_front = {
		prefix = "lava_basic_creep",
		to = 41,
		from = 22
	},
	lava_basic_creep_walk_back = {
		prefix = "lava_basic_creep",
		to = 61,
		from = 42
	},
	lava_basic_creep_firebreath = {
		prefix = "lava_basic_creep",
		to = 103,
		from = 62
	},
	lava_basic_creep_mele = {
		prefix = "lava_basic_creep",
		to = 135,
		from = 104
	},
	lava_basic_creep_death = {
		prefix = "lava_basic_creep",
		to = 155,
		from = 136
	},
	lava_basic_creep_evolve_in = {
		prefix = "lava_basic_creep",
		to = 191,
		from = 156
	},
	lava_basic_creep_evolve_loop = {
		prefix = "lava_basic_creep",
		to = 245,
		from = 192
	},
	lava_basic_creep_evolve_out = {
		prefix = "lava_basic_creep",
		to = 292,
		from = 246
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/enemy_basic_lava.lua

-- BEGIN kr3/data/animations/enemy_basic_shadow.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/enemy_basic_shadow.lua

local a = {
	shadow_basic_shadow_trail_dark = {
		prefix = "shadow_basic_shadow_trail_dark",
		to = 14,
		from = 1
	},
	shadow_basic_shadow_trail_run = {
		prefix = "shadow_basic_shadow_trail",
		to = 14,
		from = 1
	},
	shadow_basic_creep_idle = {
		prefix = "shadow_basic_creep",
		to = 1,
		from = 1
	},
	shadow_basic_creep_walk = {
		prefix = "shadow_basic_creep",
		to = 21,
		from = 2
	},
	shadow_basic_creep_walk_front = {
		prefix = "shadow_basic_creep",
		to = 41,
		from = 22
	},
	shadow_basic_creep_walk_back = {
		prefix = "shadow_basic_creep",
		to = 61,
		from = 42
	},
	shadow_basic_creep_death = {
		prefix = "shadow_basic_creep",
		to = 83,
		from = 62
	},
	shadow_basic_creep_walk_shadow = {
		prefix = "shadow_basic_creep",
		to = 103,
		from = 84
	},
	shadow_basic_creep_walk_shadow_front = {
		prefix = "shadow_basic_creep",
		to = 123,
		from = 104
	},
	shadow_basic_creep_walk_shadow_back = {
		prefix = "shadow_basic_creep",
		to = 143,
		from = 124
	},
	shadow_basic_creep_transform_in = {
		prefix = "shadow_basic_creep",
		to = 179,
		from = 144
	},
	shadow_basic_creep_transform_loop = {
		prefix = "shadow_basic_creep",
		to = 197,
		from = 180
	},
	shadow_basic_creep_transform_out = {
		prefix = "shadow_basic_creep",
		to = 245,
		from = 198
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/enemy_basic_shadow.lua

-- BEGIN kr3/data/animations/enemy_basic_storm.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/enemy_basic_storm.lua

local a = {
	basic_storm_shadow = {
		prefix = "basic_storm_shadow",
		to = 1,
		from = 1
	},
	basic_storm_creep_idle = {
		prefix = "basic_storm_creep",
		to = 18,
		from = 1
	},
	basic_storm_creep_walk = {
		prefix = "basic_storm_creep",
		to = 18,
		from = 1
	},
	basic_storm_creep_walkDown = {
		prefix = "basic_storm_creep",
		to = 36,
		from = 19
	},
	basic_storm_creep_walkUp = {
		prefix = "basic_storm_creep",
		to = 54,
		from = 37
	},
	basic_storm_creep_death = {
		prefix = "basic_storm_creep",
		to = 91,
		from = 55
	},
	basic_storm_creep_evolve_in = {
		prefix = "basic_storm_creep",
		to = 166,
		from = 92
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/enemy_basic_storm.lua

-- BEGIN kr3/data/animations/enemy_boss_stage_37.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/enemy_boss_stage_37.lua

local a = {
	boss_murglun_death_in = {
		prefix = "boss_murglun_death",
		to = 30,
		from = 1
	},
	boss_murglun_death_idle = {
		prefix = "boss_murglun_death",
		to = 31,
		from = 31
	},
	boss_murglun_death_run = {
		prefix = "boss_murglun_death",
		to = 31,
		from = 1
	},
	boss_murglun_boss_idle = {
		prefix = "boss_murglun_boss",
		to = 19,
		from = 1
	},
	boss_murglun_boss_walk = {
		prefix = "boss_murglun_boss",
		to = 19,
		from = 1
	},
	boss_murglun_boss_attack_basic_full = {
		prefix = "boss_murglun_boss",
		to = 46,
		from = 20
	},
	boss_murglun_boss_attack_basic_in = {
		prefix = "boss_murglun_boss",
		to = 38,
		from = 20
	},
	boss_murglun_boss_attack_basic_loop = {
		prefix = "boss_murglun_boss",
		to = 44,
		from = 39
	},
	boss_murglun_boss_attack_basic_out = {
		prefix = "boss_murglun_boss",
		to = 46,
		from = 45
	},
	boss_murglun_boss_tower_stun = {
		prefix = "boss_murglun_boss",
		to = 96,
		from = 47
	},
	boss_murglun_boss_death = {
		prefix = "boss_murglun_boss",
		to = 194,
		from = 97
	},
	boss_murglun_boss_in_destruccion_torre = {
		prefix = "boss_murglun_boss",
		to = 218,
		from = 195
	},
	boss_murglun_boss_destruccion_torre = {
		prefix = "boss_murglun_boss",
		to = 244,
		from = 219
	},
	boss_murglun_boss_roar_in = {
		prefix = "boss_murglun_boss",
		to = 254,
		from = 245
	},
	boss_murglun_boss_roar_loop = {
		prefix = "boss_murglun_boss",
		to = 258,
		from = 255
	},
	boss_murglun_boss_roar_out = {
		prefix = "boss_murglun_boss",
		to = 266,
		from = 259
	},
	boss_murglun_boss_torre_idle = {
		prefix = "boss_murglun_boss",
		to = 340,
		from = 267
	},
	boss_murglun_boss_torre_out = {
		prefix = "boss_murglun_boss",
		to = 363,
		from = 341
	},
	boss_murglun_boss_torre_stun = {
		prefix = "boss_murglun_boss",
		to = 412,
		from = 364
	},
	boss_murglun_boss_torre_ataque_basic_in = {
		prefix = "boss_murglun_boss",
		to = 427,
		from = 413
	},
	boss_murglun_boss_torre_ataque_basic_loop = {
		prefix = "boss_murglun_boss",
		to = 435,
		from = 428
	},
	boss_murglun_boss_torre_ataque_basic_out = {
		prefix = "boss_murglun_boss",
		to = 452,
		from = 436
	},
	boss_murglun_boss_ataque_bite = {
		prefix = "boss_murglun_boss",
		to = 498,
		from = 453
	},
	boss_murglun_boss_giro_torre = {
		prefix = "boss_murglun_boss",
		to = 536,
		from = 499
	},
	boss_murglun_efecto_tower_out_run = {
		prefix = "boss_murglun_efecto_tower_out",
		to = 52,
		from = 1
	},
	boss_murglun_proyectil_basic_flying = {
		prefix = "boss_murglun_proyectil_basic",
		to = 6,
		from = 1
	},
	boss_murglun_proyectil_basic_idle = {
		prefix = "boss_murglun_proyectil_basic",
		to = 6,
		from = 1
	},
	boss_murglun_trail_basic_attack_run = {
		prefix = "boss_murglun_trail_basic_attack",
		to = 10,
		from = 1
	},
	boss_murglun_proyectil_tower_stun_run = {
		prefix = "boss_murglun_proyectil_tower_stun",
		to = 6,
		from = 1
	},
	boss_murglun_trail_tower_stun_run = {
		prefix = "boss_murglun_trail_tower_stun",
		to = 10,
		from = 1
	},
	boss_murglun_explosion_stun_in = {
		prefix = "boss_murglun_explosion_stun",
		to = 24,
		from = 1
	},
	boss_murglun_tower_stun_run = {
		prefix = "boss_murglun_tower_stun",
		to = 20,
		from = 1
	},
	boss_murglun_tower_stun_out = {
		prefix = "boss_murglun_tower_stun",
		to = 38,
		from = 21
	},
	boss_murglun_geiser_lava = {
		prefix = "boss_murglun_geiser_lava",
		to = 30,
		from = 1
	},
	boss_murglun_fuego_piso_loop = {
		prefix = "boss_murglun_fuego_piso",
		to = 14,
		from = 1
	},
	boss_murglun_area_attack_run = {
		prefix = "boss_murglun_area_attack",
		to = 28,
		from = 1
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/enemy_boss_stage_37.lua

-- BEGIN kr3/data/animations/enemy_evolved_lava.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/enemy_evolved_lava.lua

local a = {
	lava_evolve_hit_run = {
		prefix = "lava_evolve_hit",
		to = 6,
		from = 1
	},
	lava_evolve_engage_hit_run = {
		prefix = "lava_evolve_engage_hit",
		to = 14,
		from = 1
	},
	lava_evolve_shadow_run = {
		prefix = "lava_evolve_shadow",
		to = 1,
		from = 1
	},
	lava_evolve_fuego_firebreath_run = {
		prefix = "lava_evolve_fuego_firebreath",
		to = 18,
		from = 1
	},
	lava_evolve_creep_idle = {
		prefix = "lava_evolve_creep",
		to = 1,
		from = 1
	},
	lava_evolve_creep_fly = {
		prefix = "lava_evolve_creep",
		to = 19,
		from = 2
	},
	lava_evolve_creep_fly_down = {
		prefix = "lava_evolve_creep",
		to = 37,
		from = 20
	},
	lava_evolve_creep_fly_up = {
		prefix = "lava_evolve_creep",
		to = 55,
		from = 38
	},
	lava_evolve_creep_engage = {
		prefix = "lava_evolve_creep",
		to = 89,
		from = 56
	},
	lava_evolve_creep_walk = {
		prefix = "lava_evolve_creep",
		to = 125,
		from = 90
	},
	lava_evolve_creep_walk_front = {
		prefix = "lava_evolve_creep",
		to = 161,
		from = 126
	},
	lava_evolve_creep_walk_back = {
		prefix = "lava_evolve_creep",
		to = 197,
		from = 162
	},
	lava_evolve_creep_mele = {
		prefix = "lava_evolve_creep",
		to = 239,
		from = 198
	},
	lava_evolve_creep_firebreath = {
		prefix = "lava_evolve_creep",
		to = 277,
		from = 240
	},
	lava_evolve_creep_death = {
		prefix = "lava_evolve_creep",
		to = 301,
		from = 278
	},
	lava_evolve_creep_death_fly = {
		prefix = "lava_evolve_creep",
		to = 359,
		from = 302
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/enemy_evolved_lava.lua

-- BEGIN kr3/data/animations/enemy_evolved_shadow.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/enemy_evolved_shadow.lua

local a = {
	shadow_evo_shadowmode_burst_run = {
		prefix = "shadow_evo_shadowmode_burst",
		to = 14,
		from = 1
	},
	shadow_evo_shadow_trail_2_run = {
		prefix = "shadow_evo_shadow_trail_2",
		to = 18,
		from = 1
	},
	shadow_evo_shadow_trail_run = {
		prefix = "shadow_evo_shadow_trail",
		to = 14,
		from = 1
	},
	shadow_evo_projectile_run = {
		prefix = "shadow_evo_projectile",
		to = 10,
		from = 1
	},
	shadow_evo_projectile_trail_run = {
		prefix = "shadow_evo_projectile_trail",
		to = 9,
		from = 1
	},
	shadow_evo_hit = {
		prefix = "shadow_evo_hit",
		to = 6,
		from = 1
	},
	shadow_evo_creep_idle = {
		prefix = "shadow_evo_creep",
		to = 21,
		from = 2
	},
	shadow_evo_creep_fly = {
		prefix = "shadow_evo_creep",
		to = 21,
		from = 2
	},
	shadow_evo_creep_fly_down = {
		prefix = "shadow_evo_creep",
		to = 41,
		from = 22
	},
	shadow_evo_creep_fly_up = {
		prefix = "shadow_evo_creep",
		to = 61,
		from = 42
	},
	shadow_evo_creep_ranged = {
		prefix = "shadow_evo_creep",
		to = 89,
		from = 62
	},
	shadow_evo_creep_death = {
		prefix = "shadow_evo_creep",
		to = 175,
		from = 90
	},
	shadow_evo_creep_fly_shadow = {
		prefix = "shadow_evo_creep",
		to = 195,
		from = 176
	},
	shadow_evo_creep_fly_down_shadow = {
		prefix = "shadow_evo_creep",
		to = 215,
		from = 196
	},
	shadow_evo_creep_fly_up_shadow = {
		prefix = "shadow_evo_creep",
		to = 235,
		from = 216
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/enemy_evolved_shadow.lua

-- BEGIN kr3/data/animations/enemy_evolved_storm.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/enemy_evolved_storm.lua

local a = {
	storm_evolve_decal_area_run = {
		prefix = "storm_evolve_decal_area",
		to = 1,
		from = 1
	},
	storm_evolve_electric_fx_area_run = {
		prefix = "storm_evolve_electric_fx_area",
		to = 24,
		from = 1
	},
	storm_evolve_creep_idle = {
		prefix = "storm_evolve_creep",
		to = 1,
		from = 1
	},
	storm_evolve_creep_walk = {
		prefix = "storm_evolve_creep",
		to = 18,
		from = 1
	},
	storm_evolve_creep_walk_down = {
		prefix = "storm_evolve_creep",
		to = 35,
		from = 19
	},
	storm_evolve_creep_walk_up = {
		prefix = "storm_evolve_creep",
		to = 54,
		from = 36
	},
	storm_evolve_creep_death = {
		prefix = "storm_evolve_creep",
		to = 88,
		from = 55
	},
	storm_evolve_creep_attack = {
		prefix = "storm_evolve_creep",
		to = 125,
		from = 89
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/enemy_evolved_storm.lua

-- BEGIN kr3/data/animations/enemy_executioner_storm.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/enemy_executioner_storm.lua

local a = {
	storm_executor_creep_idle = {
		prefix = "storm_executor_creep",
		to = 1,
		from = 1
	},
	storm_executor_creep_walk = {
		prefix = "storm_executor_creep",
		to = 33,
		from = 2
	},
	storm_executor_creep_walk_down = {
		prefix = "storm_executor_creep",
		to = 65,
		from = 34
	},
	storm_executor_creep_walk_up = {
		prefix = "storm_executor_creep",
		to = 96,
		from = 66
	},
	storm_executor_creep_death = {
		prefix = "storm_executor_creep",
		to = 169,
		from = 97
	},
	storm_executor_creep_attk_charged_in = {
		prefix = "storm_executor_creep",
		to = 201,
		from = 170
	},
	storm_executor_creep_attk_charged_out = {
		prefix = "storm_executor_creep",
		to = 225,
		from = 202
	},
	storm_executor_creep_attk_melee = {
		prefix = "storm_executor_creep",
		to = 254,
		from = 226
	},
	storm_executor_modifier_charged_run = {
		prefix = "storm_executor_modifier_charged",
		to = 15,
		from = 1
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/enemy_executioner_storm.lua

-- BEGIN kr3/data/animations/enemy_tanky_draconian.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/enemy_tanky_draconian.lua

local a = {
	lava_tanky_hit_run = {
		prefix = "lava_tanky_hit",
		to = 6,
		from = 1
	},
	lava_tanky_creep_idle = {
		prefix = "lava_tanky_creep",
		to = 1,
		from = 1
	},
	lava_tanky_creep_walk = {
		prefix = "lava_tanky_creep",
		to = 21,
		from = 2
	},
	lava_tanky_creep_walk_down = {
		prefix = "lava_tanky_creep",
		to = 41,
		from = 22
	},
	lava_tanky_creep_walk_up = {
		prefix = "lava_tanky_creep",
		to = 61,
		from = 42
	},
	lava_tanky_creep_mele = {
		prefix = "lava_tanky_creep",
		to = 97,
		from = 62
	},
	lava_tanky_creep_death = {
		prefix = "lava_tanky_creep",
		to = 119,
		from = 98
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/enemy_tanky_draconian.lua

-- BEGIN kr3/data/animations/evolved_acid.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/evolved_acid.lua

local a = {
	evolved_acid_modifier_run = {
		prefix = "evolved_acid_modifier",
		to = 27,
		from = 1
	},
	evolved_acid_decal_area_splash = {
		prefix = "evolved_acid_decal_area_splash",
		to = 49,
		from = 1
	},
	evolved_acid_area_splash = {
		prefix = "evolved_acid_area_splash",
		to = 22,
		from = 1
	},
	evolved_acid_hit_run = {
		prefix = "evolved_acid_hit",
		to = 15,
		from = 1
	},
	evolved_acid_trail2_run = {
		prefix = "evolved_acid_trail2",
		to = 10,
		from = 1
	},
	evolved_acid_projectil = {
		prefix = "evolved_acid_projectil",
		to = 1,
		from = 1
	},
	evolved_acid_projectile2_flying = {
		prefix = "evolved_acid_projectile2",
		to = 8,
		from = 1
	},
	evolved_acid_shadow = {
		prefix = "evolved_acid_shadow",
		to = 1,
		from = 1
	},
	evolved_acid_creep_idle = {
		prefix = "evolved_acid_creep",
		to = 18,
		from = 1
	},
	evolved_acid_creep_run = {
		prefix = "evolved_acid_creep",
		to = 36,
		from = 19
	},
	evolved_acid_creep_run_front = {
		prefix = "evolved_acid_creep",
		to = 54,
		from = 37
	},
	evolved_acid_creep_run_back = {
		prefix = "evolved_acid_creep",
		to = 72,
		from = 55
	},
	evolved_acid_creep_spawn = {
		prefix = "evolved_acid_creep",
		to = 120,
		from = 73
	},
	evolved_acid_creep_attack = {
		prefix = "evolved_acid_creep",
		to = 148,
		from = 121
	},
	evolved_acid_creep_death = {
		prefix = "evolved_acid_creep",
		to = 188,
		from = 149
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/evolved_acid.lua

-- BEGIN kr3/data/animations/game_animations_new.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/game_animations_new.lua

local a = {
	desintegrate_enemy_small = {
		prefix = "disintegration_dirt_small",
		to = 13,
		from = 1
	},
	desintegrate_enemy_big = {
		prefix = "disintegration_dirt_big",
		to = 13,
		from = 1
	},
	desintegrate_enemy_air_small = {
		prefix = "states_small",
		to = 72,
		from = 59
	},
	fx_teleport_arcane_small = {
		prefix = "states_small",
		to = 10,
		from = 1
	},
	fx_teleport_arcane_big = {
		prefix = "states_big",
		to = 10,
		from = 1
	},
	explosion_big = {
		prefix = "explosion_big",
		to = 20,
		from = 3
	},
	explosion_fragment = {
		prefix = "explosion_fragment",
		to = 18,
		from = 1
	},
	explosion_air = {
		prefix = "explosion_air",
		to = 18,
		from = 1
	},
	explosion_shrapnel = {
		prefix = "explosion_shrapnel",
		to = 20,
		from = 1
	},
	enemy_water_splash_small = {
		prefix = "Update01_WaterSplashSmall",
		to = 17,
		from = 2
	},
	enemy_water_splash_big = {
		prefix = "Update01_WaterSplashBig",
		to = 17,
		from = 2
	},
	explosion_KR5_big = {
		prefix = "explosion_KR5_big",
		to = 21,
		from = 1
	},
	instant_heal_mod_fx = {
		prefix = "instant_heal_mod_fx",
		to = 25,
		from = 1
	},
	blood_splat_red = {
		prefix = "decal_blood",
		to = 5,
		from = 1
	},
	blood_splat_green = {
		prefix = "blood_green",
		to = 11,
		from = 1
	},
	blood_splat_violet = {
		prefix = "blood_violet",
		to = 11,
		from = 1
	},
	blood_splat_orange = {
		prefix = "fx_blood_splat_orange",
		to = 10,
		from = 1
	},
	blood_splat_gray = {
		prefix = "fx_blood_splat_gray",
		to = 10,
		from = 1
	},
	hero_king_denas_idle = {
		prefix = "hero_king_denas",
		to = 1,
		from = 1
	},
	hero_king_denas_walk = {
		prefix = "hero_king_denas",
		to = 17,
		from = 2
	},
	hero_king_denas_attack = {
		prefix = "hero_king_denas",
		to = 53,
		from = 18
	},
	hero_king_denas_attack2 = {
		prefix = "hero_king_denas",
		to = 79,
		from = 54
	},
	hero_king_denas_eat = {
		prefix = "hero_king_denas",
		to = 139,
		from = 80
	},
	hero_king_denas_showOff = {
		prefix = "hero_king_denas",
		to = 217,
		from = 140
	},
	hero_king_denas_specialAttack = {
		prefix = "hero_king_denas",
		to = 271,
		from = 218
	},
	hero_king_denas_coinThrow = {
		prefix = "hero_king_denas",
		to = 391,
		from = 355
	},
	hero_king_denas_death = {
		prefix = "hero_king_denas",
		to = 332,
		from = 307
	},
	hero_king_denas_respawn = {
		prefix = "hero_king_denas",
		to = 354,
		from = 333
	},
	hero_king_denas_levelup = {
		prefix = "hero_king_denas",
		to = 354,
		from = 333
	},
	hero_king_denas_shieldThrow = {
		prefix = "hero_king_denas",
		to = 306,
		from = 272
	},
	hero_king_denas_kings_speech = {
		prefix = "hero_king_denas",
		to = 391,
		from = 355
	},
	hero_king_denas_pounding_smash = {
		prefix = "hero_king_denas",
		to = 306,
		from = 272
	},
	fx_elves_hero_king_denas_heal = {
		prefix = "hero_king_denas_healFx",
		to = 25,
		from = 1
	},
	fx_elves_hero_king_denas_flash = {
		prefix = "hero_king_denas_flash",
		to = 3,
		from = 1
	},
	hero_king_denas_twister_travel = {
		prefix = "hero_king_denas_twister",
		to = 20,
		from = 13
	},
	hero_alleria5_idle = {
		prefix = "hero_alleria5",
		to = 18,
		from = 1
	},
	hero_alleria5_walk = {
		prefix = "hero_alleria5",
		to = 23,
		from = 19
	},
	hero_alleria5_bow2sword = {
		prefix = "hero_alleria5",
		to = 29,
		from = 24
	},
	hero_alleria5_idle_sword = {
		prefix = "hero_alleria5",
		to = 47,
		from = 30
	},
	hero_alleria5_sword2bow = {
		prefix = "hero_alleria5",
		to = 53,
		from = 48
	},
	hero_alleria5_shoot_start = {
		prefix = "hero_alleria5",
		to = 57,
		from = 54
	},
	hero_alleria5_shoot_loop = {
		prefix = "hero_alleria5",
		to = 69,
		from = 64
	},
	hero_alleria5_shoot_final = {
		prefix = "hero_alleria5",
		to = 73,
		from = 70
	},
	hero_alleria5_shoot_end = {
		prefix = "hero_alleria5",
		to = 79,
		from = 74
	},
	hero_alleria5_attack = {
		prefix = "hero_alleria5",
		to = 96,
		from = 80
	},
	hero_alleria5_double_strike = {
		prefix = "hero_alleria5",
		to = 122,
		from = 97
	},
	hero_alleria5_nimble_fencer = {
		prefix = "hero_alleria5",
		to = 138,
		from = 123
	},
	hero_alleria5_death = {
		prefix = "hero_alleria5",
		to = 150,
		from = 139
	},
	hero_alleria5_levelup = {
		prefix = "hero_alleria5",
		to = 167,
		from = 151
	},
	hero_alleria5_respawn = {
		prefix = "hero_alleria5",
		to = 167,
		from = 151
	},
	hero_alleria5_shoot = {
		prefix = "hero_alleria5",
		ranges = {
			{
				54,
				63
			},
			{
				74,
				79
			}
		}
	},
	hero_alleria5_whistling_arrow_shoot = {
		prefix = "hero_alleria5",
		ranges = {
			{
				54,
				63
			},
			{
				63,
				63
			},
			{
				63,
				63
			},
			{
				63,
				63
			},
			{
				63,
				63
			},
			{
				63,
				63
			},
			{
				63,
				63
			},
			{
				63,
				63
			},
			{
				63,
				63
			},
			{
				63,
				63
			},
			{
				63,
				63
			},
			{
				63,
				63
			},
			{
				63,
				63
			},
			{
				74,
				79
			}
		}
	},
	hero_alleria5_whistling_arrow_bullet = {
		prefix = "hero_alleria5_whistling_arrow_proy",
		to = 8,
		from = 1
	},
	hero_alleria5_whistling_arrow_bullet_hit = {
		prefix = "hero_alleria5_whistling_arrow_proyHit",
		to = 7,
		from = 1
	},
	hero_alleria5_whistling_arrow_bullet_trail = {
		prefix = "hero_alleria5_whistling_arrow_proyParticle",
		to = 12,
		from = 1
	},
	hero_alleria5_chilling_roar_debuff = {
		prefix = "hero_alleria5_chilling_roar_debuff",
		to = 27,
		from = 1
	},
	hero_velann_idle = {
		prefix = "hero_velann",
		to = 1,
		from = 1
	},
	hero_velann_stand = {
		prefix = "hero_velann",
		to = 35,
		from = 2
	},
	hero_velann_running = {
		prefix = "hero_velann",
		to = 51,
		from = 36
	},
	hero_velann_walk = {
		prefix = "hero_velann",
		to = 51,
		from = 36
	},
	hero_velann_shoot = {
		prefix = "hero_velann",
		to = 78,
		from = 52
	},
	hero_velann_death = {
		prefix = "hero_velann",
		to = 102,
		from = 79
	},
	hero_velann_respawn = {
		prefix = "hero_velann",
		to = 121,
		from = 103
	},
	hero_velann_levelup = {
		prefix = "hero_velann",
		to = 121,
		from = 103
	},
	hero_velann_void_prison = {
		prefix = "hero_velann",
		to = 183,
		from = 160
	},
	hero_velann_teleport_out = {
		prefix = "hero_velann",
		to = 237,
		from = 220
	},
	hero_velann_friends_on_the_other_side = {
		prefix = "hero_velann",
		to = 219,
		from = 184
	},
	hero_velann_teleport_in = {
		prefix = "hero_velann",
		to = 255,
		from = 238
	},
	hero_velann_attack = {
		prefix = "hero_velann",
		to = 274,
		from = 256
	},
	hero_velann_voices_from_beyond = {
		prefix = "hero_velann",
		to = 132,
		from = 122
	},
	hero_velann_void_rift = {
		prefix = "hero_velann",
		to = 159,
		from = 139
	},
	hero_velann_bolt_flying = {
		prefix = "hero_velann_proy",
		to = 2,
		from = 1
	},
	hero_velann_bolt_hit = {
		prefix = "hero_velann_proy",
		to = 10,
		from = 3
	},
	hero_velann_void_prison_mod_start = {
		prefix = "hero_velann_void_prison_mod",
		to = 28,
		from = 1
	},
	hero_velann_void_prison_mod_loop = {
		prefix = "hero_velann_void_prison_mod",
		to = 44,
		from = 29
	},
	hero_velann_void_prison_mod_end = {
		prefix = "hero_velann_void_prison_mod",
		to = 52,
		from = 45
	},
	hero_velann_void_prison_imp_attack = {
		prefix = "hero_velann_void_prison_imp",
		frames = {
			67,
			68,
			69,
			70,
			71,
			72,
			73,
			74,
			75,
			76,
			75,
			74,
			73,
			72,
			71,
			70,
			69,
			68,
			67
		}
	},
	hero_velann_void_prison_imp_death = {
		prefix = "hero_velann_void_prison_imp",
		to = 112,
		from = 101
	},
	hero_velann_void_prison_imp_idle = {
		prefix = "hero_velann_void_prison_imp",
		to = 67,
		from = 67
	},
	hero_velann_void_prison_imp_spawn = {
		prefix = "hero_velann_void_prison_imp",
		to = 99,
		from = 96
	},
	hero_velann_void_prison_imp_walkingDown = {
		prefix = "hero_velann_void_prison_imp",
		to = 66,
		from = 45
	},
	hero_velann_void_prison_imp_walkingRightLeft = {
		prefix = "hero_velann_void_prison_imp",
		to = 22,
		from = 1
	},
	hero_velann_void_prison_imp_walkingUp = {
		prefix = "hero_velann_void_prison_imp",
		to = 44,
		from = 23
	},
	hero_velann_void_prison_imp_running = {
		prefix = "hero_velann_void_prison_imp",
		to = 22,
		from = 1
	},
	hero_velann_friends_on_the_other_side_imp_attack = {
		prefix = "hero_velann_friends_on_the_other_side_imp",
		frames = {
			67,
			68,
			69,
			70,
			71,
			72,
			73,
			74,
			75,
			76,
			75,
			74,
			73,
			72,
			71,
			70,
			69,
			68,
			67
		}
	},
	hero_velann_friends_on_the_other_side_imp_death = {
		prefix = "hero_velann_friends_on_the_other_side_imp",
		to = 112,
		from = 101
	},
	hero_velann_friends_on_the_other_side_imp_idle = {
		prefix = "hero_velann_friends_on_the_other_side_imp",
		to = 67,
		from = 67
	},
	hero_velann_friends_on_the_other_side_imp_walkingDown = {
		prefix = "hero_velann_friends_on_the_other_side_imp",
		to = 66,
		from = 45
	},
	hero_velann_friends_on_the_other_side_imp_walkingRightLeft = {
		prefix = "hero_velann_friends_on_the_other_side_imp",
		to = 22,
		from = 1
	},
	hero_velann_friends_on_the_other_side_imp_walkingUp = {
		prefix = "hero_velann_friends_on_the_other_side_imp",
		to = 44,
		from = 23
	},
	hero_velann_friends_on_the_other_side_imp_running = {
		prefix = "hero_velann_friends_on_the_other_side_imp",
		to = 22,
		from = 1
	},
	hero_velann_friends_on_the_other_side_imp_spawn = {
		prefix = "hero_velann_friends_on_the_other_side_imp",
		to = 100,
		from = 96
	},
	hero_velann_friends_on_the_other_side_imp_teleport_in = {
		prefix = "hero_velann_friends_on_the_other_side_imp",
		to = 100,
		from = 96
	},
	hero_velann_friends_on_the_other_side_imp_teleport_out = {
		prefix = "hero_velann_friends_on_the_other_side_imp",
		frames = {
			100,
			99,
			98,
			97,
			96
		}
	},
	hero_velann_voices_from_beyond_mod = {
		prefix = "hero_velann_voices_from_beyond_fx_above",
		to = 26,
		from = 1
	},
	hero_velann_voices_from_beyond_mod_decal = {
		prefix = "hero_velann_voices_from_beyond_fx_decal",
		to = 34,
		from = 9
	},
	hero_velann_void_rift_heal_mod_fx = {
		prefix = "hero_velann_void_rift_heal_mod_fx",
		to = 25,
		from = 1
	},
	hero_velann_void_rift_damage_mod_fx = {
		prefix = "hero_velann_void_rift_damage_mod_fx",
		to = 10,
		from = 1
	},
	hero_velann_void_rift_decal_start = {
		prefix = "hero_velann_void_rift_aura",
		to = 8,
		from = 1
	},
	hero_velann_void_rift_decal_loop = {
		prefix = "hero_velann_void_rift_aura",
		to = 24,
		from = 9
	},
	hero_velann_void_rift_decal_end = {
		prefix = "hero_velann_void_rift_aura",
		to = 33,
		from = 25
	},
	hero_velann_ultimate_entity_attack = {
		prefix = "hero_velann_ultimate_entity",
		to = 45,
		from = 31
	},
	hero_velann_ultimate_entity_death = {
		prefix = "hero_velann_ultimate_entity",
		to = 80,
		from = 69
	},
	hero_velann_ultimate_entity_idle = {
		prefix = "hero_velann_ultimate_entity",
		to = 44,
		from = 44
	},
	hero_velann_ultimate_entity_walkingDown = {
		prefix = "hero_velann_ultimate_entity",
		to = 30,
		from = 21
	},
	hero_velann_ultimate_entity_walkingRightLeft = {
		prefix = "hero_velann_ultimate_entity",
		to = 10,
		from = 1
	},
	hero_velann_ultimate_entity_walkingUp = {
		prefix = "hero_velann_ultimate_entity",
		to = 20,
		from = 11
	},
	hero_velann_ultimate_entity_running = {
		prefix = "hero_velann_ultimate_entity",
		to = 10,
		from = 1
	},
	hero_vesper_vesper_idle = {
		prefix = "hero_vesper_vesper",
		to = 18,
		from = 1
	},
	hero_vesper_vesper_walk = {
		prefix = "hero_vesper_vesper",
		to = 36,
		from = 19
	},
	hero_vesper_vesper_melee_attack_1 = {
		prefix = "hero_vesper_vesper",
		to = 64,
		from = 37
	},
	hero_vesper_vesper_melee_attack_2 = {
		prefix = "hero_vesper_vesper",
		to = 90,
		from = 65
	},
	hero_vesper_vesper_ranged_attack = {
		prefix = "hero_vesper_vesper",
		to = 110,
		from = 91
	},
	hero_vesper_vesper_ranged_attack_2 = {
		prefix = "hero_vesper_vesper",
		to = 110,
		from = 91
	},
	hero_vesper_vesper_ranged_attack_1 = {
		prefix = "hero_vesper_vesper",
		to = 110,
		from = 91
	},
	hero_vesper_vesper_arrow_to_the_knee = {
		prefix = "hero_vesper_vesper",
		to = 140,
		from = 111
	},
	hero_vesper_vesper_ricochet = {
		prefix = "hero_vesper_vesper",
		to = 169,
		from = 141
	},
	hero_vesper_vesper_martial_flourish = {
		prefix = "hero_vesper_vesper",
		to = 209,
		from = 170
	},
	hero_vesper_vesper_disengage = {
		prefix = "hero_vesper_vesper",
		to = 257,
		from = 210
	},
	hero_vesper_vesper_respawn = {
		prefix = "hero_vesper_vesper",
		to = 279,
		from = 258
	},
	hero_vesper_vesper_levelup = {
		prefix = "hero_vesper_vesper",
		to = 279,
		from = 258
	},
	hero_vesper_vesper_death = {
		prefix = "hero_vesper_vesper",
		to = 307,
		from = 280
	},
	hero_vesper_attack_particle = {
		prefix = "hero_vesper_attack_particle",
		to = 11,
		from = 1
	},
	hero_vesper_attack_hit = {
		prefix = "hero_vesper_attack_hit",
		to = 6,
		from = 1
	},
	hero_vesper_arrow_to_the_knee_hit = {
		prefix = "hero_vesper_arrow_to_the_knee_hit",
		to = 11,
		from = 1
	},
	hero_vesper_arrow_to_the_knee_particles = {
		prefix = "hero_vesper_arrow_to_the_knee_particles",
		to = 13,
		from = 1
	},
	hero_vesper_martial_flourish_hit = {
		prefix = "hero_vesper_martial_flourish_hit",
		to = 23,
		from = 1
	},
	hero_vesper_ricochet_hit = {
		prefix = "hero_vesper_ricochet_hit",
		to = 11,
		from = 1
	},
	hero_vesper_ricochet_particle = {
		prefix = "hero_vesper_ricochet_particle",
		to = 13,
		from = 1
	},
	hero_vesper_disengage_hit = {
		prefix = "hero_vesper_disengage_hit",
		to = 6,
		from = 1
	},
	hero_vesper_ultimate_arrow_decal = {
		prefix = "hero_vesper_ultimate_arrow_decal",
		to = 11,
		from = 1
	},
	hero_vesper_vesper_disengage_disappear = {
		prefix = "hero_vesper_vesper",
		to = 221,
		from = 210
	},
	hero_vesper_vesper_disengage_appear = {
		prefix = "hero_vesper_vesper",
		to = 232,
		from = 221
	},
	hero_vesper_vesper_disengage_attack_start = {
		prefix = "hero_vesper_vesper",
		to = 238,
		from = 232
	},
	hero_vesper_vesper_disengage_attack_end = {
		prefix = "hero_vesper_vesper",
		to = 239,
		from = 238
	},
	hero_vesper_vesper_disengage_end = {
		prefix = "hero_vesper_vesper",
		to = 257,
		from = 252
	},
	hero_raelyn_hero_idle = {
		prefix = "hero_raelyn_hero",
		to = 23,
		from = 1
	},
	hero_raelyn_hero_idle2 = {
		prefix = "hero_raelyn_hero",
		to = 24,
		from = 24
	},
	hero_raelyn_hero_walk = {
		prefix = "hero_raelyn_hero",
		to = 48,
		from = 25
	},
	hero_raelyn_hero_melee_attack = {
		prefix = "hero_raelyn_hero",
		to = 86,
		from = 49
	},
	hero_raelyn_hero_brutal_slash = {
		prefix = "hero_raelyn_hero",
		to = 135,
		from = 87
	},
	hero_raelyn_hero_inspire_fear = {
		prefix = "hero_raelyn_hero",
		to = 175,
		from = 136
	},
	hero_raelyn_hero_unbreakable = {
		prefix = "hero_raelyn_hero",
		to = 212,
		from = 176
	},
	hero_raelyn_hero_respawn = {
		prefix = "hero_raelyn_hero",
		to = 236,
		from = 213
	},
	hero_raelyn_hero_levelup = {
		prefix = "hero_raelyn_hero",
		to = 236,
		from = 213
	},
	hero_raelyn_hero_death = {
		prefix = "hero_raelyn_hero",
		to = 280,
		from = 237
	},
	hero_raelyn_hero_grave = {
		prefix = "hero_raelyn_hero",
		to = 281,
		from = 281
	},
	hero_raelyn_hero_onslaught = {
		prefix = "hero_raelyn_hero",
		to = 301,
		from = 282
	},
	hero_raelyn_onslaught_fx_idle = {
		prefix = "hero_raelyn_onslaught_fx",
		to = 13,
		from = 1
	},
	hero_raelyn_brutal_slash_decal_idle = {
		prefix = "hero_raelyn_brutal_slash_decal",
		to = 1,
		from = 1
	},
	hero_raelyn_inspire_fear_fx_area_idle = {
		prefix = "hero_raelyn_inspire_fear_fx_area",
		to = 31,
		from = 1
	},
	hero_raelyn_inspire_fear_decal = {
		prefix = "hero_raelyn_inspire_fear_decal",
		to = 32,
		from = 1
	},
	hero_raelyn_unbreakable_fx_idle = {
		prefix = "hero_raelyn_unbreakable_fx",
		to = 16,
		from = 1
	},
	hero_raelyn_unbreakable_shield_floor_glow_idle = {
		prefix = "hero_raelyn_unbreakable_shield_floor_glow",
		to = 1,
		from = 1
	},
	hero_raelyn_unbreakable_shield_lvl1_start = {
		prefix = "hero_raelyn_unbreakable_shield_lvl1",
		to = 12,
		from = 1
	},
	hero_raelyn_unbreakable_shield_lvl1_idle = {
		prefix = "hero_raelyn_unbreakable_shield_lvl1",
		to = 36,
		from = 13
	},
	hero_raelyn_unbreakable_shield_lvl1_end = {
		prefix = "hero_raelyn_unbreakable_shield_lvl1",
		to = 42,
		from = 37
	},
	hero_raelyn_melee_attack_hit = {
		prefix = "hero_raelyn_melee_attack_hit",
		to = 6,
		from = 1
	},
	relic_banner_of_command_soldier_idle = {
		prefix = "relic_banner_of_command_soldier",
		to = 1,
		from = 1
	},
	relic_banner_of_command_soldier_running = {
		prefix = "relic_banner_of_command_soldier",
		to = 6,
		from = 2
	},
	relic_banner_of_command_soldier_attack = {
		prefix = "relic_banner_of_command_soldier",
		to = 17,
		from = 7
	},
	relic_locket_of_the_unforgiven_idle = {
		prefix = "relic_locket_of_the_unforgiven",
		to = 24,
		from = 1
	},
	relic_locket_of_the_unforgiven_running = {
		prefix = "relic_locket_of_the_unforgiven",
		to = 48,
		from = 25
	},
	relic_locket_of_the_unforgiven_attack = {
		prefix = "relic_locket_of_the_unforgiven",
		to = 66,
		from = 49
	},
	relic_locket_of_the_unforgiven_raise = {
		prefix = "relic_locket_of_the_unforgiven",
		to = 89,
		from = 67
	},
	relic_locket_of_the_unforgiven_death = {
		prefix = "relic_locket_of_the_unforgiven",
		to = 119,
		from = 90
	},
	relic_locket_of_the_unforgiven_attack_hit_fx = {
		prefix = "relic_locket_of_the_unforgiven",
		to = 125,
		from = 120
	},
	relic_guardian_orb_small = {
		prefix = "mage_highElven_balls",
		to = 1,
		from = 1
	},
	relic_guardian_orb_big = {
		prefix = "mage_highElven_balls",
		to = 19,
		from = 2
	},
	relic_guardian_orb_shoot = {
		prefix = "mage_highElven_balls",
		to = 34,
		from = 21
	},
	relic_guardian_orb_particle = {
		prefix = "mage_highElven_balls",
		to = 20,
		from = 20
	},
	ray_relic_guardian_orb = {
		prefix = "mage_highElven_balls_ray",
		to = 4,
		from = 1
	},
	fx_ray_relic_guardian_orb_hit = {
		prefix = "mage_highElven_balls_hitFx_big",
		to = 10,
		from = 1
	},
	tricannon_tower_lvl1_tower_layerX_idle = {
		layer_to = 7,
		from = 1,
		layer_prefix = "tricannon_tower_lvl1_tower_layer%i",
		to = 1,
		layer_from = 1
	},
	tricannon_tower_lvl1_tower_layerX_attack = {
		layer_to = 7,
		from = 2,
		layer_prefix = "tricannon_tower_lvl1_tower_layer%i",
		to = 58,
		layer_from = 1
	},
	tricannon_tower_lvl2_tower_layerX_idle = {
		layer_to = 7,
		from = 1,
		layer_prefix = "tricannon_tower_lvl2_tower_layer%i",
		to = 1,
		layer_from = 1
	},
	tricannon_tower_lvl2_tower_layerX_attack = {
		layer_to = 7,
		from = 2,
		layer_prefix = "tricannon_tower_lvl2_tower_layer%i",
		to = 58,
		layer_from = 1
	},
	tricannon_tower_lvl3_tower_layerX_idle = {
		layer_to = 7,
		from = 1,
		layer_prefix = "tricannon_tower_lvl3_tower_layer%i",
		to = 1,
		layer_from = 1
	},
	tricannon_tower_lvl3_tower_layerX_attack = {
		layer_to = 7,
		from = 2,
		layer_prefix = "tricannon_tower_lvl3_tower_layer%i",
		to = 58,
		layer_from = 1
	},
	tricannon_tower_lvl4_tower_layerX_idle = {
		layer_to = 10,
		from = 1,
		layer_prefix = "tricannon_tower_lvl4_tower_layer%i",
		to = 1,
		layer_from = 1
	},
	tricannon_tower_lvl4_tower_layerX_shoot = {
		layer_to = 10,
		from = 2,
		layer_prefix = "tricannon_tower_lvl4_tower_layer%i",
		to = 72,
		layer_from = 1
	},
	tricannon_tower_lvl4_tower_layerX_skill1 = {
		layer_to = 10,
		from = 73,
		layer_prefix = "tricannon_tower_lvl4_tower_layer%i",
		to = 118,
		layer_from = 1
	},
	tricannon_tower_lvl4_tower_layerX_loop = {
		layer_to = 10,
		from = 119,
		layer_prefix = "tricannon_tower_lvl4_tower_layer%i",
		to = 126,
		layer_from = 1
	},
	tricannon_tower_lvl4_tower_layerX_loop_end = {
		layer_to = 10,
		from = 127,
		layer_prefix = "tricannon_tower_lvl4_tower_layer%i",
		to = 142,
		layer_from = 1
	},
	tricannon_tower_lvl4_tower_layerX_skill_2_charge = {
		layer_to = 10,
		from = 143,
		layer_prefix = "tricannon_tower_lvl4_tower_layer%i",
		to = 201,
		layer_from = 1
	},
	tricannon_tower_lvl4_tower_layerX_skill_2_idle = {
		layer_to = 10,
		from = 202,
		layer_prefix = "tricannon_tower_lvl4_tower_layer%i",
		to = 212,
		layer_from = 1
	},
	tricannon_tower_lvl4_tower_layerX_skill_2_attack = {
		layer_to = 10,
		from = 213,
		layer_prefix = "tricannon_tower_lvl4_tower_layer%i",
		to = 280,
		layer_from = 1
	},
	tricannon_tower_lvl4_tower_layerX_skill_2_fade_out = {
		layer_to = 10,
		from = 281,
		layer_prefix = "tricannon_tower_lvl4_tower_layer%i",
		to = 290,
		layer_from = 1
	},
	tricannon_tower_lvl4_particle = {
		prefix = "tricannon_tower_lvl4_particle",
		to = 6,
		from = 1
	},
	tricannon_tower_lvl4_particle_overheat = {
		prefix = "tricannon_tower_lvl4_particle_overheat",
		to = 15,
		from = 1
	},
	tricannon_tower_overheat_fire_fx = {
		prefix = "tricannon_tower_fissure_hit",
		to = 10,
		from = 1
	},
	paladin_covenant_lvl4_flag = {
		prefix = "paladin_covenant_lvl4_flag",
		to = 22,
		from = 1
	},
	paladin_covenant_lvl4_door_open = {
		prefix = "paladin_covenant_lvl4_door",
		to = 10,
		from = 1
	},
	paladin_covenant_lvl4_door_close = {
		prefix = "paladin_covenant_lvl4_door",
		to = 18,
		from = 11
	},
	paladin_covenant_lvl123_door_open = {
		prefix = "paladin_covenant_lvl123_door",
		to = 10,
		from = 1
	},
	paladin_covenant_lvl123_door_close = {
		prefix = "paladin_covenant_lvl123_door",
		to = 18,
		from = 11
	},
	paladin_covenant_lvl4 = {
		prefix = "paladin_covenant_lvl4",
		to = 1,
		from = 1
	},
	paladin_covenant_lvl3 = {
		prefix = "paladin_covenant_lvl3",
		to = 1,
		from = 1
	},
	paladin_covenant_lvl2 = {
		prefix = "paladin_covenant_lvl2",
		to = 1,
		from = 1
	},
	paladin_covenant_lvl1 = {
		prefix = "paladin_covenant_lvl1",
		to = 1,
		from = 1
	},
	paladin_covenant_preview = {
		prefix = "paladin_covenant_preview",
		to = 1,
		from = 1
	},
	paladin_covenant_build = {
		prefix = "paladin_covenant_build",
		to = 1,
		from = 1
	},
	paladin_soldiers_lvl1_idle = {
		prefix = "paladin_soldiers_lvl1",
		to = 1,
		from = 1
	},
	paladin_soldiers_lvl1_idle2 = {
		prefix = "paladin_soldiers_lvl1",
		to = 2,
		from = 2
	},
	paladin_soldiers_lvl1_running = {
		prefix = "paladin_soldiers_lvl1",
		to = 18,
		from = 3
	},
	paladin_soldiers_lvl1_attack = {
		prefix = "paladin_soldiers_lvl1",
		to = 35,
		from = 19
	},
	paladin_soldiers_lvl1_death = {
		prefix = "paladin_soldiers_lvl1",
		to = 54,
		from = 36
	},
	paladin_soldiers_lvl2_idle = {
		prefix = "paladin_soldiers_lvl2",
		to = 1,
		from = 1
	},
	paladin_soldiers_lvl2_idle2 = {
		prefix = "paladin_soldiers_lvl2",
		to = 2,
		from = 2
	},
	paladin_soldiers_lvl2_running = {
		prefix = "paladin_soldiers_lvl2",
		to = 18,
		from = 3
	},
	paladin_soldiers_lvl2_attack = {
		prefix = "paladin_soldiers_lvl2",
		to = 35,
		from = 19
	},
	paladin_soldiers_lvl2_death = {
		prefix = "paladin_soldiers_lvl2",
		to = 54,
		from = 36
	},
	paladin_soldiers_lvl3_idle = {
		prefix = "paladin_soldiers_lvl3",
		to = 1,
		from = 1
	},
	paladin_soldiers_lvl3_idle2 = {
		prefix = "paladin_soldiers_lvl3",
		to = 2,
		from = 2
	},
	paladin_soldiers_lvl3_running = {
		prefix = "paladin_soldiers_lvl3",
		to = 18,
		from = 3
	},
	paladin_soldiers_lvl3_attack = {
		prefix = "paladin_soldiers_lvl3",
		to = 35,
		from = 19
	},
	paladin_soldiers_lvl3_death = {
		prefix = "paladin_soldiers_lvl3",
		to = 54,
		from = 36
	},
	paladin_soldiers_lvl4_captain_armor_mod_decal_start = {
		prefix = "paladin_soldiers_lvl4_captain_armor_mod_decal",
		to = 10,
		from = 1
	},
	paladin_soldiers_lvl4_captain_armor_mod_decal_loop = {
		prefix = "paladin_soldiers_lvl4_captain_armor_mod_decal",
		to = 11,
		from = 11
	},
	paladin_soldiers_lvl4_captain_armor_mod_decal_end = {
		prefix = "paladin_soldiers_lvl4_captain_armor_mod_decal",
		to = 21,
		from = 12
	},
	paladin_soldiers_lvl4_captain_armor_decal_start = {
		prefix = "paladin_soldiers_lvl4_captain_armor_decal",
		to = 39,
		from = 1
	},
	paladin_soldiers_lvl4_captain_armor_decal_loop = {
		prefix = "paladin_soldiers_lvl4_captain_armor_decal",
		to = 82,
		from = 40
	},
	paladin_soldiers_lvl4_captain_armor_decal_end = {
		prefix = "paladin_soldiers_lvl4_captain_armor_decal",
		to = 90,
		from = 83
	},
	paladin_soldiers_lvl4_captain_soldier_idle = {
		prefix = "paladin_soldiers_lvl4_captain_soldier",
		to = 1,
		from = 1
	},
	paladin_soldiers_lvl4_captain_soldier_idle2 = {
		prefix = "paladin_soldiers_lvl4_captain_soldier",
		to = 2,
		from = 2
	},
	paladin_soldiers_lvl4_captain_soldier_walk = {
		prefix = "paladin_soldiers_lvl4_captain_soldier",
		to = 12,
		from = 3
	},
	paladin_soldiers_lvl4_captain_soldier_attack01 = {
		prefix = "paladin_soldiers_lvl4_captain_soldier",
		to = 46,
		from = 13
	},
	paladin_soldiers_lvl4_captain_soldier_attack02 = {
		prefix = "paladin_soldiers_lvl4_captain_soldier",
		to = 80,
		from = 47
	},
	paladin_soldiers_lvl4_captain_soldier_healing_start = {
		prefix = "paladin_soldiers_lvl4_captain_soldier",
		to = 109,
		from = 81
	},
	paladin_soldiers_lvl4_captain_soldier_healing_loop = {
		prefix = "paladin_soldiers_lvl4_captain_soldier",
		to = 117,
		from = 110
	},
	paladin_soldiers_lvl4_captain_soldier_healing_end = {
		prefix = "paladin_soldiers_lvl4_captain_soldier",
		to = 131,
		from = 118
	},
	paladin_soldiers_lvl4_captain_soldier_armor = {
		prefix = "paladin_soldiers_lvl4_captain_soldier",
		to = 175,
		from = 132
	},
	paladin_soldiers_lvl4_captain_soldier_death = {
		prefix = "paladin_soldiers_lvl4_captain_soldier",
		to = 207,
		from = 176
	},
	paladin_soldiers_lvl4_captain_soldier_raise = {
		prefix = "paladin_soldiers_lvl4_captain_soldier",
		to = 175,
		from = 132
	},
	paladin_soldiers_lvl4_captain_armor_buff = {
		prefix = "paladin_soldiers_lvl4_captain_armor_buff",
		to = 19,
		from = 1
	},
	tower_viper_goblins_shot = {
		prefix = "viper_goblins_shot",
		to = 1,
		from = 1
	},
	tower_viper_goblins_pow_curse_of_the_snake_mod = {
		prefix = "viper_goblins_pow_curse_of_the_snake_fx_above",
		to = 26,
		from = 1
	},
	tower_viper_goblins_pow_snake_bomb_mod = {
		prefix = "viper_goblins_pow_snake_bomb_fx_decal",
		to = 34,
		from = 9
	},
	tower_viper_goblins_shooter_idle = {
		prefix = "viper_goblins_shooter",
		to = 1,
		from = 1
	},
	tower_viper_goblins_shooter_shoot = {
		prefix = "viper_goblins_shooter",
		to = 22,
		from = 2
	},
	tower_viper_goblins_shooter_curse_of_the_snake = {
		prefix = "viper_goblins_shooter",
		to = 15,
		from = 2
	},
	tower_viper_goblins_shooter_snake_bomb = {
		prefix = "viper_goblins_shooter",
		to = 15,
		from = 2
	},
	elderportal_tower_tower_preview = {
		prefix = "elderportal_tower_tower_preview",
		to = 1,
		from = 1
	},
	elderportal_tower_tower_build = {
		prefix = "elderportal_tower_tower_build",
		to = 1,
		from = 1
	},
	elderportal_tower_tower_idle = {
		prefix = "elderportal_tower_tower",
		to = 1,
		from = 1
	},
	elderportal_tower_tower_shoot = {
		prefix = "elderportal_tower_tower",
		to = 64,
		from = 2
	},
	elderportal_tower_tower_orbital_cannon = {
		prefix = "elderportal_tower_tower",
		to = 127,
		from = 65
	},
	elderportal_tower_tower_teleport = {
		prefix = "elderportal_tower_tower",
		to = 190,
		from = 128
	},
	elderportal_tower_teleport_mod = {
		prefix = "elderportal_teleport_big",
		to = 10,
		from = 1
	},
	elderportal_mine = {
		prefix = "elderportal_mine",
		to = 30,
		from = 1
	},
	tusked_brawler_idle = {
		prefix = "tusked_brawler",
		to = 1,
		from = 1
	},
	tusked_brawler_walkingRightLeft = {
		prefix = "tusked_brawler",
		to = 23,
		from = 2
	},
	tusked_brawler_walkingDown = {
		prefix = "tusked_brawler",
		to = 45,
		from = 24
	},
	tusked_brawler_walkingUp = {
		prefix = "tusked_brawler",
		to = 67,
		from = 46
	},
	tusked_brawler_attack = {
		prefix = "tusked_brawler",
		to = 91,
		from = 68
	},
	tusked_brawler_attack_2 = {
		prefix = "tusked_brawler",
		to = 116,
		from = 92
	},
	tusked_brawler_death = {
		prefix = "tusked_brawler",
		to = 141,
		from = 117
	},
	tusked_brawler_raise = {
		prefix = "tusked_brawler",
		to = 24,
		from = 24
	},
	turtle_shaman_idle = {
		prefix = "turtle_shaman",
		to = 1,
		from = 1
	},
	turtle_shaman_walkingRightLeft = {
		prefix = "turtle_shaman",
		to = 25,
		from = 2
	},
	turtle_shaman_walkingDown = {
		prefix = "turtle_shaman",
		to = 49,
		from = 26
	},
	turtle_shaman_walkingUp = {
		prefix = "turtle_shaman",
		to = 73,
		from = 50
	},
	turtle_shaman_attack_1 = {
		prefix = "turtle_shaman",
		to = 105,
		from = 74
	},
	turtle_shaman_attack_2 = {
		prefix = "turtle_shaman",
		to = 131,
		from = 106
	},
	turtle_shaman_ability_1 = {
		prefix = "turtle_shaman",
		to = 173,
		from = 132
	},
	turtle_shaman_death = {
		prefix = "turtle_shaman",
		to = 234,
		from = 174
	},
	turtle_shaman_attack_1_projectile_flying = {
		prefix = "turtle_shaman",
		to = 254,
		from = 235
	},
	turtle_shaman_attack_1_projectile_trail = {
		prefix = "turtle_shaman",
		to = 260,
		from = 255
	},
	turtle_shaman_attack_1_hit = {
		prefix = "turtle_shaman",
		to = 277,
		from = 261
	},
	turtle_shaman_attack_2_hit = {
		prefix = "turtle_shaman",
		to = 283,
		from = 278
	},
	turtle_shaman_ability_1_FX = {
		prefix = "turtle_shaman",
		to = 310,
		from = 284
	},
	turtle_shaman_HealFX_b_Spawn_1 = {
		prefix = "turtle_shaman",
		to = 315,
		from = 311
	},
	turtle_shaman_HealFX_b_Idle_1 = {
		prefix = "turtle_shaman",
		to = 343,
		from = 316
	},
	turtle_shaman_HealFX_b_Dismiss_1 = {
		prefix = "turtle_shaman",
		to = 351,
		from = 344
	},
	turtle_shaman_HealFX_a_Idle_1 = {
		prefix = "turtle_shaman",
		to = 381,
		from = 352
	},
	turtle_shaman_HealFX_decal = {
		prefix = "turtle_shaman",
		ranges = {
			{
				311,
				315
			},
			{
				316,
				343
			},
			{
				344,
				351
			}
		}
	},
	bear_vanguard_idle = {
		prefix = "bear_vanguard",
		to = 1,
		from = 1
	},
	bear_vanguard_walkingRightLeft = {
		prefix = "bear_vanguard",
		to = 25,
		from = 2
	},
	bear_vanguard_walkingDown = {
		prefix = "bear_vanguard",
		to = 49,
		from = 26
	},
	bear_vanguard_walkingUp = {
		prefix = "bear_vanguard",
		to = 73,
		from = 50
	},
	bear_vanguard_attack = {
		prefix = "bear_vanguard",
		to = 101,
		from = 74
	},
	bear_vanguard_wrath = {
		prefix = "bear_vanguard",
		to = 130,
		from = 102
	},
	bear_vanguard_death = {
		prefix = "bear_vanguard",
		to = 158,
		from = 131
	},
	bear_vanguard_mod_fx_wrath_of_the_fallen_decal_base = {
		prefix = "bear_vanguard_buffFX",
		to = 1,
		from = 1
	},
	bear_vanguard_mod_fx_wrath_of_the_fallen_decal_top = {
		prefix = "bear_vanguard_buffFX",
		to = 13,
		from = 2
	},
	bear_vanguard_decal_animation = {
		prefix = "bear_vanguard_decal_anim_decal_animation",
		to = 16,
		from = 1
	},
	bear_woodcutter_idle = {
		prefix = "bear_woodcutter",
		to = 1,
		from = 1
	},
	bear_woodcutter_walkingRightLeft = {
		prefix = "bear_woodcutter",
		to = 25,
		from = 2
	},
	bear_woodcutter_walkingDown = {
		prefix = "bear_woodcutter",
		to = 49,
		from = 26
	},
	bear_woodcutter_walkingUp = {
		prefix = "bear_woodcutter",
		to = 73,
		from = 50
	},
	bear_woodcutter_attack = {
		prefix = "bear_woodcutter",
		to = 101,
		from = 74
	},
	bear_woodcutter_wrath = {
		prefix = "bear_woodcutter",
		to = 130,
		from = 102
	},
	bear_woodcutter_death = {
		prefix = "bear_woodcutter",
		to = 158,
		from = 131
	},
	cutthroat_rat_idle = {
		prefix = "cutthroat_rat",
		to = 1,
		from = 1
	},
	cutthroat_rat_walkingRightLeft = {
		prefix = "cutthroat_rat",
		to = 9,
		from = 2
	},
	cutthroat_rat_walkingDown = {
		prefix = "cutthroat_rat",
		to = 25,
		from = 10
	},
	cutthroat_rat_walkingUp = {
		prefix = "cutthroat_rat",
		to = 41,
		from = 26
	},
	cutthroat_rat_attack_1 = {
		prefix = "cutthroat_rat",
		to = 63,
		from = 42
	},
	cutthroat_rat_attack_2 = {
		prefix = "cutthroat_rat",
		to = 95,
		from = 64
	},
	cutthroat_rat_death = {
		prefix = "cutthroat_rat",
		to = 117,
		from = 96
	},
	cutthroat_rat_attack_1_hit = {
		prefix = "cutthroat_rat",
		to = 127,
		from = 118
	},
	cutthroat_rat_attack_2_hit = {
		prefix = "cutthroat_rat",
		to = 137,
		from = 128
	},
	cutthroat_rat_attack_2_smokeFX = {
		prefix = "cutthroat_rat",
		to = 151,
		from = 138
	},
	dreadeye_viper_ranged_attack_hit = {
		prefix = "dreadeye_viper_ranged_attack_hit",
		to = 11,
		from = 1
	},
	dreadeye_viper_ranged_attack_particle = {
		prefix = "dreadeye_viper_ranged_attack_particle",
		to = 10,
		from = 1
	},
	dreadeye_viper_creep_raise = {
		prefix = "dreadeye_viper_creep",
		to = 21,
		from = 21
	},
	dreadeye_viper_creep_idle = {
		prefix = "dreadeye_viper_creep",
		to = 1,
		from = 1
	},
	dreadeye_viper_creep_walkingRightLeft = {
		prefix = "dreadeye_viper_creep",
		to = 20,
		from = 2
	},
	dreadeye_viper_creep_walkingDown = {
		prefix = "dreadeye_viper_creep",
		to = 40,
		from = 21
	},
	dreadeye_viper_creep_walkingUp = {
		prefix = "dreadeye_viper_creep",
		to = 60,
		from = 41
	},
	dreadeye_viper_creep_attack_01 = {
		prefix = "dreadeye_viper_creep",
		to = 82,
		from = 61
	},
	dreadeye_viper_creep_attack_02 = {
		prefix = "dreadeye_viper_creep",
		to = 107,
		from = 83
	},
	dreadeye_viper_creep_death = {
		prefix = "dreadeye_viper_creep",
		to = 135,
		from = 108
	},
	rottenfang_hyena_idle = {
		prefix = "rottenfang_hyena",
		to = 1,
		from = 1
	},
	rottenfang_hyena_walkingRightLeft = {
		prefix = "rottenfang_hyena",
		to = 21,
		from = 2
	},
	rottenfang_hyena_walkingDown = {
		prefix = "rottenfang_hyena",
		to = 41,
		from = 22
	},
	rottenfang_hyena_walkingUp = {
		prefix = "rottenfang_hyena",
		to = 61,
		from = 42
	},
	rottenfang_hyena_attack = {
		prefix = "rottenfang_hyena",
		to = 89,
		from = 62
	},
	rottenfang_hyena_eat_start = {
		prefix = "rottenfang_hyena",
		to = 97,
		from = 90
	},
	rottenfang_hyena_eat_loop = {
		prefix = "rottenfang_hyena",
		to = 121,
		from = 98
	},
	rottenfang_hyena_eat_end = {
		prefix = "rottenfang_hyena",
		to = 129,
		from = 122
	},
	rottenfang_hyena_death = {
		prefix = "rottenfang_hyena",
		to = 151,
		from = 130
	},
	rottenfang_hyena_attack_hit_fx = {
		prefix = "rottenfang_hyena",
		to = 159,
		from = 152
	},
	patrolling_vulture_idle = {
		prefix = "patrolling_vulture",
		to = 16,
		from = 1
	},
	patrolling_vulture_walkingRightLeft = {
		prefix = "patrolling_vulture",
		to = 32,
		from = 17
	},
	patrolling_vulture_walkingDown = {
		prefix = "patrolling_vulture",
		to = 48,
		from = 33
	},
	patrolling_vulture_walkingUp = {
		prefix = "patrolling_vulture",
		to = 64,
		from = 49
	},
	patrolling_vulture_death = {
		prefix = "patrolling_vulture",
		to = 87,
		from = 65
	},
	skunk_bombardier_idle = {
		prefix = "skunk_bombardier",
		to = 1,
		from = 1
	},
	skunk_bombardier_walkingRightLeft = {
		prefix = "skunk_bombardier",
		to = 23,
		from = 2
	},
	skunk_bombardier_walkingDown = {
		prefix = "skunk_bombardier",
		to = 45,
		from = 24
	},
	skunk_bombardier_walkingUp = {
		prefix = "skunk_bombardier",
		to = 67,
		from = 46
	},
	skunk_bombardier_shoot = {
		prefix = "skunk_bombardier",
		to = 97,
		from = 68
	},
	skunk_bombardier_attack = {
		prefix = "skunk_bombardier",
		to = 127,
		from = 98
	},
	skunk_bombardier_death = {
		prefix = "skunk_bombardier",
		to = 171,
		from = 128
	},
	skunk_bombardier_bomb_hit_fx = {
		prefix = "skunk_bombardier_explosion",
		to = 25,
		from = 1
	},
	skunk_bombardier_bomb_trail = {
		prefix = "skunk_bombardier_particle",
		to = 9,
		from = 1
	},
	skunk_bombardier_modifier_modifier = {
		prefix = "skunk_bombardier_modifier_modifier",
		to = 22,
		from = 1
	},
	acolyte_idle = {
		prefix = "acolyte_enemy",
		to = 1,
		from = 1
	},
	acolyte_walkingRightLeft = {
		prefix = "acolyte_enemy",
		to = 21,
		from = 2
	},
	acolyte_walkingDown = {
		prefix = "acolyte_enemy",
		to = 41,
		from = 22
	},
	acolyte_walkingUp = {
		prefix = "acolyte_enemy",
		to = 61,
		from = 42
	},
	acolyte_attack = {
		prefix = "acolyte_enemy",
		to = 81,
		from = 62
	},
	acolyte_death = {
		prefix = "acolyte_enemy",
		to = 119,
		from = 82
	},
	acolyte_sacrifice = {
		prefix = "acolyte_enemy",
		to = 171,
		from = 120
	},
	acolyte_attack_hit_fx = {
		prefix = "acolyte_fx",
		to = 6,
		from = 1
	},
	acolyte_tentacle_raise = {
		prefix = "acolyte_tentacle",
		to = 21,
		from = 1
	},
	acolyte_tentacle_idle = {
		prefix = "acolyte_tentacle",
		to = 22,
		from = 22
	},
	acolyte_tentacle_attack = {
		prefix = "acolyte_tentacle",
		to = 45,
		from = 23
	},
	acolyte_tentacle_attack2 = {
		prefix = "acolyte_tentacle",
		to = 67,
		from = 46
	},
	acolyte_tentacle_death = {
		prefix = "acolyte_tentacle",
		to = 94,
		from = 68
	},
	lesser_sister_idle = {
		prefix = "lesser_sister_enemy",
		to = 1,
		from = 1
	},
	lesser_sister_walkingRightLeft = {
		prefix = "lesser_sister_enemy",
		to = 25,
		from = 2
	},
	lesser_sister_walkingDown = {
		prefix = "lesser_sister_enemy",
		to = 49,
		from = 26
	},
	lesser_sister_walkingUp = {
		prefix = "lesser_sister_enemy",
		to = 73,
		from = 50
	},
	lesser_sister_attack = {
		prefix = "lesser_sister_enemy",
		to = 109,
		from = 74
	},
	lesser_sister_shoot = {
		prefix = "lesser_sister_enemy",
		to = 109,
		from = 74
	},
	lesser_sister_crooked_souls = {
		prefix = "lesser_sister_enemy",
		to = 149,
		from = 110
	},
	lesser_sister_death = {
		prefix = "lesser_sister_enemy",
		to = 209,
		from = 150
	},
	lesser_sister_bolt_flying = {
		prefix = "lesser_sister_fx",
		to = 12,
		from = 1
	},
	lesser_sister_bolt_trail = {
		prefix = "lesser_sister_fx",
		to = 18,
		from = 13
	},
	lesser_sister_bolt_hit_fx = {
		prefix = "lesser_sister_fx",
		to = 25,
		from = 19
	},
	lesser_sister_nightmare_idle = {
		prefix = "lesser_nightmare_enemy",
		to = 24,
		from = 1
	},
	lesser_sister_nightmare_walkingRightLeft = {
		prefix = "lesser_nightmare_enemy",
		to = 48,
		from = 25
	},
	lesser_sister_nightmare_walkingDown = {
		prefix = "lesser_nightmare_enemy",
		to = 72,
		from = 49
	},
	lesser_sister_nightmare_walkingUp = {
		prefix = "lesser_nightmare_enemy",
		to = 96,
		from = 73
	},
	lesser_sister_nightmare_attack = {
		prefix = "lesser_nightmare_enemy",
		to = 118,
		from = 97
	},
	lesser_sister_nightmare_raise = {
		prefix = "lesser_nightmare_enemy",
		to = 134,
		from = 119
	},
	lesser_sister_nightmare_death = {
		prefix = "lesser_nightmare_enemy",
		to = 153,
		from = 135
	},
	lesser_sister_nightmare_hit_fx = {
		prefix = "lesser_nightmare_fx",
		to = 6,
		from = 1
	},
	reinforcements_lvl1_01_idle = {
		prefix = "reinforcements_lvl1_01",
		to = 1,
		from = 1
	},
	reinforcements_lvl1_01_walk = {
		prefix = "reinforcements_lvl1_01",
		to = 17,
		from = 2
	},
	reinforcements_lvl1_01_attack = {
		prefix = "reinforcements_lvl1_01",
		to = 39,
		from = 18
	},
	reinforcements_lvl1_01_death = {
		prefix = "reinforcements_lvl1_01",
		to = 58,
		from = 40
	},
	reinforcements_lvl1_02_idle = {
		prefix = "reinforcements_lvl1_02",
		to = 1,
		from = 1
	},
	reinforcements_lvl1_02_walk = {
		prefix = "reinforcements_lvl1_02",
		to = 17,
		from = 2
	},
	reinforcements_lvl1_02_attack = {
		prefix = "reinforcements_lvl1_02",
		to = 39,
		from = 18
	},
	reinforcements_lvl1_02_death = {
		prefix = "reinforcements_lvl1_02",
		to = 58,
		from = 40
	},
	reinforcements_lvl1_03_idle = {
		prefix = "reinforcements_lvl1_03",
		to = 1,
		from = 1
	},
	reinforcements_lvl1_03_walk = {
		prefix = "reinforcements_lvl1_03",
		to = 17,
		from = 2
	},
	reinforcements_lvl1_03_attack = {
		prefix = "reinforcements_lvl1_03",
		to = 39,
		from = 18
	},
	reinforcements_lvl1_03_death = {
		prefix = "reinforcements_lvl1_03",
		to = 58,
		from = 40
	},
	reinforcements_lvl2_01_idle = {
		prefix = "reinforcements_lvl2_01",
		to = 1,
		from = 1
	},
	reinforcements_lvl2_01_walk = {
		prefix = "reinforcements_lvl2_01",
		to = 17,
		from = 2
	},
	reinforcements_lvl2_01_attack = {
		prefix = "reinforcements_lvl2_01",
		to = 39,
		from = 18
	},
	reinforcements_lvl2_01_death = {
		prefix = "reinforcements_lvl2_01",
		to = 58,
		from = 40
	},
	reinforcements_lvl2_02_idle = {
		prefix = "reinforcements_lvl2_02",
		to = 1,
		from = 1
	},
	reinforcements_lvl2_02_walk = {
		prefix = "reinforcements_lvl2_02",
		to = 17,
		from = 2
	},
	reinforcements_lvl2_02_attack = {
		prefix = "reinforcements_lvl2_02",
		to = 39,
		from = 18
	},
	reinforcements_lvl2_02_death = {
		prefix = "reinforcements_lvl2_02",
		to = 58,
		from = 40
	},
	reinforcements_lvl2_03_idle = {
		prefix = "reinforcements_lvl2_03",
		to = 1,
		from = 1
	},
	reinforcements_lvl2_03_walk = {
		prefix = "reinforcements_lvl2_03",
		to = 17,
		from = 2
	},
	reinforcements_lvl2_03_attack = {
		prefix = "reinforcements_lvl2_03",
		to = 39,
		from = 18
	},
	reinforcements_lvl2_03_death = {
		prefix = "reinforcements_lvl2_03",
		to = 58,
		from = 40
	},
	reinforcements_lvl3_01_idle = {
		prefix = "reinforcements_lvl3_01",
		to = 1,
		from = 1
	},
	reinforcements_lvl3_01_walk = {
		prefix = "reinforcements_lvl3_01",
		to = 17,
		from = 2
	},
	reinforcements_lvl3_01_attack = {
		prefix = "reinforcements_lvl3_01",
		to = 39,
		from = 18
	},
	reinforcements_lvl3_01_death = {
		prefix = "reinforcements_lvl3_01",
		to = 58,
		from = 40
	},
	reinforcements_lvl3_02_idle = {
		prefix = "reinforcements_lvl3_02",
		to = 1,
		from = 1
	},
	reinforcements_lvl3_02_walk = {
		prefix = "reinforcements_lvl3_02",
		to = 17,
		from = 2
	},
	reinforcements_lvl3_02_attack = {
		prefix = "reinforcements_lvl3_02",
		to = 39,
		from = 18
	},
	reinforcements_lvl3_02_death = {
		prefix = "reinforcements_lvl3_02",
		to = 58,
		from = 40
	},
	reinforcements_lvl3_03_idle = {
		prefix = "reinforcements_lvl3_03",
		to = 1,
		from = 1
	},
	reinforcements_lvl3_03_walk = {
		prefix = "reinforcements_lvl3_03",
		to = 17,
		from = 2
	},
	reinforcements_lvl3_03_attack = {
		prefix = "reinforcements_lvl3_03",
		to = 39,
		from = 18
	},
	reinforcements_lvl3_03_melee = {
		prefix = "reinforcements_lvl3_03",
		to = 61,
		from = 40
	},
	reinforcements_lvl3_03_death = {
		prefix = "reinforcements_lvl3_03",
		to = 80,
		from = 62
	},
	reinforcements_lvl3_03_dodge = {
		prefix = "reinforcements_lvl3_03",
		to = 91,
		from = 81
	},
	reinforcements_lvl3_03_arrow = {
		prefix = "reinforcements_lvl3_03_arrow",
		to = 1,
		from = 1
	},
	reinforcements_lvl4_01_idle = {
		prefix = "reinforcements_lvl4_01",
		to = 1,
		from = 1
	},
	reinforcements_lvl4_01_walk = {
		prefix = "reinforcements_lvl4_01",
		to = 17,
		from = 2
	},
	reinforcements_lvl4_01_attack = {
		prefix = "reinforcements_lvl4_01",
		to = 39,
		from = 18
	},
	reinforcements_lvl4_01_death = {
		prefix = "reinforcements_lvl4_01",
		to = 58,
		from = 40
	},
	reinforcements_lvl4_02_idle = {
		prefix = "reinforcements_lvl4_02",
		to = 1,
		from = 1
	},
	reinforcements_lvl4_02_walk = {
		prefix = "reinforcements_lvl4_02",
		to = 17,
		from = 2
	},
	reinforcements_lvl4_02_attack = {
		prefix = "reinforcements_lvl4_02",
		to = 39,
		from = 18
	},
	reinforcements_lvl4_02_death = {
		prefix = "reinforcements_lvl4_02",
		to = 58,
		from = 40
	},
	reinforcements_lvl4_03_idle = {
		prefix = "reinforcements_lvl4_03",
		to = 1,
		from = 1
	},
	reinforcements_lvl4_03_walk = {
		prefix = "reinforcements_lvl4_03",
		to = 17,
		from = 2
	},
	reinforcements_lvl4_03_attack = {
		prefix = "reinforcements_lvl4_03",
		to = 39,
		from = 18
	},
	reinforcements_lvl4_03_melee = {
		prefix = "reinforcements_lvl4_03",
		to = 61,
		from = 40
	},
	reinforcements_lvl4_03_death = {
		prefix = "reinforcements_lvl4_03",
		to = 80,
		from = 62
	},
	reinforcements_lvl4_03_dodge = {
		prefix = "reinforcements_lvl4_03",
		to = 91,
		from = 81
	},
	reinforcements_lvl4_03_arrow = {
		prefix = "reinforcements_lvl4_03_arrow",
		to = 1,
		from = 1
	},
	reinforcement_darkarmy_lvl_5_unit_idle = {
		prefix = "reinforcement_darkarmy_lvl_5_unit",
		to = 1,
		from = 1
	},
	reinforcement_darkarmy_lvl_5_unit_run = {
		prefix = "reinforcement_darkarmy_lvl_5_unit",
		to = 41,
		from = 2
	},
	reinforcement_darkarmy_lvl_5_unit_attack = {
		prefix = "reinforcement_darkarmy_lvl_5_unit",
		to = 75,
		from = 42
	},
	reinforcement_darkarmy_lvl_5_unit_melee = {
		prefix = "reinforcement_darkarmy_lvl_5_unit",
		to = 97,
		from = 76
	},
	reinforcement_darkarmy_lvl_5_unit_death = {
		prefix = "reinforcement_darkarmy_lvl_5_unit",
		to = 117,
		from = 98
	},
	reinforcement_darkarmy_lvl_5_unit_hit_vfx = {
		prefix = "reinforcement_darkarmy_lvl_5_unit_hit_vfx",
		to = 6,
		from = 1
	},
	reinforcement_darkarmy_lvl_5_crow_idle = {
		prefix = "reinforcement_darkarmy_lvl_5_crow",
		to = 14,
		from = 1
	},
	reinforcement_darkarmy_lvl_5_crow_attack = {
		prefix = "reinforcement_darkarmy_lvl_5_crow",
		to = 34,
		from = 15
	},
	reinforcement_darkarmy_lvl_5_crow_death = {
		prefix = "reinforcement_darkarmy_lvl_5_crow",
		to = 46,
		from = 35
	},
	reinforcement_darkarmy_lvl_5_crow_hit_idle = {
		prefix = "reinforcement_darkarmy_lvl_5_crow_hit",
		to = 16,
		from = 1
	},
	reinforcement_linirea_lvl_5_hit_vfx_idle = {
		prefix = "reinforcement_linirea_lvl_5_hit_vfx",
		to = 8,
		from = 1
	},
	reinforcement_linirea_lvl_5_unit_idle = {
		prefix = "reinforcement_linirea_lvl_5_unit",
		to = 1,
		from = 1
	},
	reinforcement_linirea_lvl_5_unit_walk = {
		prefix = "reinforcement_linirea_lvl_5_unit",
		to = 25,
		from = 2
	},
	reinforcement_linirea_lvl_5_unit_attack = {
		prefix = "reinforcement_linirea_lvl_5_unit",
		to = 60,
		from = 26
	},
	reinforcement_linirea_lvl_5_unit_death = {
		prefix = "reinforcement_linirea_lvl_5_unit",
		to = 104,
		from = 61
	},
	soldier_re_rebel_militia_lvl1_01_idle = {
		prefix = "reinforcements_rebel_militia_lvl1_01",
		to = 1,
		from = 1
	},
	soldier_re_rebel_militia_lvl1_01_running = {
		prefix = "reinforcements_rebel_militia_lvl1_01",
		to = 17,
		from = 2
	},
	soldier_re_rebel_militia_lvl1_01_attack = {
		prefix = "reinforcements_rebel_militia_lvl1_01",
		to = 39,
		from = 18
	},
	soldier_re_rebel_militia_lvl1_01_death = {
		prefix = "reinforcements_rebel_militia_lvl1_01",
		to = 58,
		from = 40
	},
	soldier_re_rebel_militia_lvl1_02_idle = {
		prefix = "reinforcements_rebel_militia_lvl1_02",
		to = 1,
		from = 1
	},
	soldier_re_rebel_militia_lvl1_02_running = {
		prefix = "reinforcements_rebel_militia_lvl1_02",
		to = 17,
		from = 2
	},
	soldier_re_rebel_militia_lvl1_02_attack = {
		prefix = "reinforcements_rebel_militia_lvl1_02",
		to = 39,
		from = 18
	},
	soldier_re_rebel_militia_lvl1_02_death = {
		prefix = "reinforcements_rebel_militia_lvl1_02",
		to = 58,
		from = 40
	},
	soldier_re_shadow_archer_lvl1_01_idle = {
		prefix = "reinforcements_shadow_archer_lvl1_01",
		to = 1,
		from = 1
	},
	soldier_re_shadow_archer_lvl1_01_running = {
		prefix = "reinforcements_shadow_archer_lvl1_01",
		to = 17,
		from = 2
	},
	soldier_re_shadow_archer_lvl1_01_attack = {
		prefix = "reinforcements_shadow_archer_lvl1_01",
		to = 39,
		from = 18
	},
	soldier_re_shadow_archer_lvl1_01_death = {
		prefix = "reinforcements_shadow_archer_lvl1_01",
		to = 58,
		from = 40
	},
	soldier_re_shadow_archer_lvl1_02_idle = {
		prefix = "reinforcements_shadow_archer_lvl1_02",
		to = 1,
		from = 1
	},
	soldier_re_shadow_archer_lvl1_02_running = {
		prefix = "reinforcements_shadow_archer_lvl1_02",
		to = 17,
		from = 2
	},
	soldier_re_shadow_archer_lvl1_02_attack = {
		prefix = "reinforcements_shadow_archer_lvl1_02",
		to = 39,
		from = 18
	},
	soldier_re_shadow_archer_lvl1_02_death = {
		prefix = "reinforcements_shadow_archer_lvl1_02",
		to = 58,
		from = 40
	},
	trees_fruity_tree_loading = {
		prefix = "trees_fruity_tree",
		to = 21,
		from = 1
	},
	trees_fruity_tree_ready = {
		prefix = "trees_fruity_tree",
		to = 32,
		from = 22
	},
	trees_fruity_tree_idle = {
		prefix = "trees_fruity_tree",
		to = 45,
		from = 33
	},
	trees_fruity_tree_shoot = {
		prefix = "trees_fruity_tree",
		to = 65,
		from = 46
	},
	trees_fruity_tree_fruit = {
		prefix = "trees_fruity_tree_fruit",
		to = 30,
		from = 1
	},
	trees_fruity_tree_fruit_apply_fx = {
		prefix = "trees_fruity_tree_fruit_apply_fx",
		to = 33,
		from = 2
	},
	trees_arborean_sages_holder = {
		prefix = "arborean_sages",
		to = 1,
		from = 1
	},
	trees_arborean_sages_spawn = {
		prefix = "arborean_sages",
		to = 11,
		from = 2
	},
	trees_arborean_sages_idle = {
		prefix = "arborean_sages",
		to = 12,
		from = 12
	},
	trees_arborean_sages_attack = {
		prefix = "arborean_sages",
		to = 42,
		from = 13
	},
	trees_arborean_sages_disappear = {
		prefix = "arborean_sages",
		to = 53,
		from = 43
	},
	props_waterfall_waves = {
		prefix = "props_waterfall_waves",
		to = 33,
		from = 1
	},
	props_water_shine = {
		prefix = "stage_2_props_water_shine",
		to = 86,
		from = 1
	},
	stage_2_special_treeFX_holdFX_small_start = {
		prefix = "stage_2_special_treeFX_holdFX_small",
		to = 10,
		from = 1
	},
	stage_2_special_treeFX_holdFX_small_idle = {
		prefix = "stage_2_special_treeFX_holdFX_small",
		to = 11,
		from = 11
	},
	stage_2_special_treeFX_holdFX_small_end = {
		prefix = "stage_2_special_treeFX_holdFX_small",
		to = 21,
		from = 12
	},
	stage_2_special_treeFX_holdFX_big_start = {
		prefix = "stage_2_special_treeFX_holdFX_big",
		to = 10,
		from = 1
	},
	stage_2_special_treeFX_holdFX_big_idle = {
		prefix = "stage_2_special_treeFX_holdFX_big",
		to = 11,
		from = 11
	},
	stage_2_special_treeFX_holdFX_big_end = {
		prefix = "stage_2_special_treeFX_holdFX_big",
		to = 21,
		from = 12
	},
	stage_2_special_treeFX_groundFX01_start = {
		prefix = "stage_2_special_treeFX_groundFX01",
		to = 7,
		from = 1
	},
	stage_2_special_treeFX_groundFX01_idle = {
		prefix = "stage_2_special_treeFX_groundFX01",
		to = 8,
		from = 8
	},
	stage_2_special_treeFX_groundFX01_end = {
		prefix = "stage_2_special_treeFX_groundFX01",
		to = 18,
		from = 9
	},
	stage_2_special_treeFX_groundFX02_start = {
		prefix = "stage_2_special_treeFX_groundFX02",
		to = 7,
		from = 1
	},
	stage_2_special_treeFX_groundFX02_idle = {
		prefix = "stage_2_special_treeFX_groundFX02",
		to = 8,
		from = 8
	},
	stage_2_special_treeFX_groundFX02_end = {
		prefix = "stage_2_special_treeFX_groundFX02",
		to = 18,
		from = 9
	},
	stage_2_special_treeFX_groundFX03_start = {
		prefix = "stage_2_special_treeFX_groundFX03",
		to = 7,
		from = 1
	},
	stage_2_special_treeFX_groundFX03_idle = {
		prefix = "stage_2_special_treeFX_groundFX03",
		to = 8,
		from = 8
	},
	stage_2_special_treeFX_groundFX03_end = {
		prefix = "stage_2_special_treeFX_groundFX03",
		to = 18,
		from = 9
	},
	stage_2_special_treeFX_groundFX04_start = {
		prefix = "stage_2_special_treeFX_groundFX04",
		to = 7,
		from = 1
	},
	stage_2_special_treeFX_groundFX04_idle = {
		prefix = "stage_2_special_treeFX_groundFX04",
		to = 8,
		from = 8
	},
	stage_2_special_treeFX_groundFX04_end = {
		prefix = "stage_2_special_treeFX_groundFX04",
		to = 18,
		from = 9
	},
	stage_2_special_treeFX_groundFX05_start = {
		prefix = "stage_2_special_treeFX_groundFX05",
		to = 7,
		from = 1
	},
	stage_2_special_treeFX_groundFX05_idle = {
		prefix = "stage_2_special_treeFX_groundFX05",
		to = 8,
		from = 8
	},
	stage_2_special_treeFX_groundFX05_end = {
		prefix = "stage_2_special_treeFX_groundFX05",
		to = 18,
		from = 9
	},
	trees_heart_of_the_arborean_decal_idle = {
		prefix = "trees_heart_of_the_arborean_decal",
		to = 1,
		from = 1
	},
	trees_heart_of_the_arborean_decal_shoot = {
		prefix = "trees_heart_of_the_arborean_decal",
		to = 183,
		from = 160
	},
	trees_heart_of_the_arborean_decal_ready = {
		prefix = "trees_heart_of_the_arborean_decal",
		to = 70,
		from = 52
	},
	trees_heart_of_the_arborean_decal_wait = {
		prefix = "trees_heart_of_the_arborean_decal",
		to = 70,
		from = 65
	},
	trees_heart_of_the_arborean_decal_power = {
		prefix = "trees_heart_of_the_arborean_decal_power",
		to = 16,
		from = 1
	},
	trees_heart_of_the_arborean_decal_terrain_fx = {
		prefix = "trees_heart_of_the_arborean_decal_terrain_fx",
		to = 14,
		from = 1
	},
	trees_heart_of_the_arborean_decal_new_idle = {
		prefix = "heart_export_heart",
		to = 1,
		from = 1
	},
	trees_heart_of_the_arborean_decal_new_shoot = {
		prefix = "heart_export_heart",
		to = 2,
		from = 2
	},
	trees_heart_of_the_arborean_decal_new_ready = {
		prefix = "heart_export_heart",
		to = 2,
		from = 2
	},
	trees_heart_of_the_arborean_decal_new_wait = {
		prefix = "heart_export_heart",
		to = 2,
		from = 2
	},
	trees_heart_of_the_arborean_decal_power_new = {
		prefix = "heart_export_explotion",
		to = 39,
		from = 1
	},
	trees_heart_of_the_arborean_decal_terrain_fx_new = {
		prefix = "heart_export_explotion_decal",
		to = 10,
		from = 1
	},
	trees_heart_of_the_arborean_tap_sign_play = {
		prefix = "trees_heart_of_the_arborean_tap_sign",
		to = 7,
		from = 1
	},
	stage_3_shaman_arborean_enemy_idle = {
		prefix = "stage_3_shaman_arborean_enemy",
		to = 1,
		from = 1
	},
	stage_3_shaman_arborean_enemy_charge = {
		prefix = "stage_3_shaman_arborean_enemy",
		to = 17,
		from = 2
	},
	stage_3_shaman_arborean_enemy_charged = {
		prefix = "stage_3_shaman_arborean_enemy",
		to = 45,
		from = 18
	},
	stage_3_shaman_arborean_enemy_shoot = {
		prefix = "stage_3_shaman_arborean_enemy",
		to = 67,
		from = 46
	},
	stage_4_special_arborean_sentinels_spearer_soldier_idle = {
		prefix = "stage_4_special_arborean_sentinels_spearer_soldier",
		to = 1,
		from = 1
	},
	stage_4_special_arborean_sentinels_spearer_soldier_running = {
		prefix = "stage_4_special_arborean_sentinels_spearer_soldier",
		to = 17,
		from = 2
	},
	stage_4_special_arborean_sentinels_spearer_soldier_attack = {
		prefix = "stage_4_special_arborean_sentinels_spearer_soldier",
		to = 39,
		from = 18
	},
	stage_4_special_arborean_sentinels_spearer_soldier_ranged_attack = {
		prefix = "stage_4_special_arborean_sentinels_spearer_soldier",
		to = 65,
		from = 40
	},
	stage_4_special_arborean_sentinels_spearer_soldier_death = {
		prefix = "stage_4_special_arborean_sentinels_spearer_soldier",
		to = 85,
		from = 66
	},
	tower_arborean_sentinels_spearmen_hitFx = {
		prefix = "arborean_spearmen_hitFx",
		to = 9,
		from = 1
	},
	arborean_barrack_lvl1_door_open = {
		prefix = "arborean_barrack_lvl1_door",
		to = 13,
		from = 1
	},
	arborean_barrack_lvl1_door_close = {
		prefix = "arborean_barrack_lvl1_door",
		to = 28,
		from = 14
	},
	stage_4_special_arborean_sentinels_barkshield_soldier_idle = {
		prefix = "stage_4_special_arborean_sentinels_barkshield_soldier",
		to = 1,
		from = 1
	},
	stage_4_special_arborean_sentinels_barkshield_soldier_running = {
		prefix = "stage_4_special_arborean_sentinels_barkshield_soldier",
		to = 20,
		from = 2
	},
	stage_4_special_arborean_sentinels_barkshield_soldier_attack = {
		prefix = "stage_4_special_arborean_sentinels_barkshield_soldier",
		to = 39,
		from = 21
	},
	stage_4_special_arborean_sentinels_barkshield_soldier_death = {
		prefix = "stage_4_special_arborean_sentinels_barkshield_soldier",
		to = 61,
		from = 40
	},
	bush_spawner_idle = {
		prefix = "bush_spawner",
		to = 1,
		from = 1
	},
	bush_spawner_spawner_enable = {
		prefix = "bush_spawner",
		to = 9,
		from = 2
	},
	stage_4_elevator_elevator_top_start = {
		prefix = "stage_4_elevator_elevator_top",
		to = 75,
		from = 1
	},
	stage_4_elevator_elevator_top_idle = {
		prefix = "stage_4_elevator_elevator_top",
		to = 76,
		from = 76
	},
	stage_4_elevator_elevator_top_end = {
		prefix = "stage_4_elevator_elevator_top",
		to = 97,
		from = 77
	},
	stage_4_leaf_anim_idle = {
		prefix = "stage_4_leaf_anim",
		to = 35,
		from = 1
	},
	props_wisp = {
		prefix = "stage_2_props_wisp",
		to = 84,
		from = 1
	},
	test_exo = {
		prefix = "test_exo",
		to = 1,
		from = 1
	},
	stage_1_tower_build_indicator = {
		prefix = "stage_1_tower_build_indicator",
		to = 4,
		from = 1
	},
	stage_1_dead_enemy_indicator = {
		prefix = "stage_1_dead_enemy_indicator",
		to = 3,
		from = 1
	},
	arborean_baby_sit_down = {
		prefix = "arborean_baby",
		to = 20,
		from = 1
	},
	arborean_baby_idle_sit = {
		prefix = "arborean_baby",
		to = 21,
		from = 21
	},
	arborean_baby_sit_up = {
		prefix = "arborean_baby",
		to = 63,
		from = 22
	},
	arborean_baby_idle1 = {
		prefix = "arborean_baby",
		to = 113,
		from = 64
	},
	arborean_baby_easter_egg_in = {
		prefix = "arborean_baby",
		to = 137,
		from = 114
	},
	arborean_baby_easter_egg_sitting_in = {
		prefix = "arborean_baby",
		to = 161,
		from = 138
	},
	arborean_baby_easter_egg_idle = {
		prefix = "arborean_baby",
		to = 162,
		from = 162
	},
	arborean_baby_easter_egg_out = {
		prefix = "arborean_baby",
		to = 281,
		from = 163
	},
	stage_5_elder_rune_5_idle = {
		prefix = "stage_5_elder_rune_5",
		to = 66,
		from = 1
	},
	stage_5_elder_rune_5_activation = {
		prefix = "stage_5_elder_rune_5",
		to = 98,
		from = 67
	},
	stage_5_elder_rune_5_idle_2 = {
		prefix = "stage_5_elder_rune_5",
		to = 125,
		from = 99
	},
	stage_5_elder_rune_5_base = {
		prefix = "stage_5_elder_rune_5_base",
		to = 1,
		from = 1
	},
	elven_warrior_idle1 = {
		prefix = "elven_warrior",
		to = 18,
		from = 1
	},
	elven_warrior_walk_loop = {
		prefix = "elven_warrior",
		to = 40,
		from = 19
	},
	elven_warrior_walk1 = {
		prefix = "elven_warrior",
		to = 110,
		from = 41
	},
	elven_warrior_walk2 = {
		prefix = "elven_warrior",
		to = 180,
		from = 111
	},
	elven_warrior_idle1_to_idle2 = {
		prefix = "elven_warrior",
		to = 194,
		from = 181
	},
	elven_warrior_idle2 = {
		prefix = "elven_warrior",
		to = 212,
		from = 195
	},
	elven_warrior_shoot = {
		prefix = "elven_warrior",
		to = 224,
		from = 213
	},
	elven_warrior_back_to_idle2 = {
		prefix = "elven_warrior",
		to = 230,
		from = 225
	},
	elven_warrior_back_to_idle1 = {
		prefix = "elven_warrior",
		to = 238,
		from = 231
	},
	elven_warrior_death = {
		prefix = "elven_warrior",
		to = 257,
		from = 239
	},
	spawn_nightmares_portal_in = {
		prefix = "spawn_nightmares_portal",
		to = 9,
		from = 9
	},
	spawn_nightmares_portal_loop = {
		prefix = "spawn_nightmares_portal",
		to = 33,
		from = 10
	},
	spawn_nightmares_portal_out = {
		prefix = "spawn_nightmares_portal",
		to = 34,
		from = 34
	},
	spawner_t3_spawnereffect = {
		prefix = "spawner_t3_spawnereffect",
		to = 41,
		from = 1
	},
	spawner_t3_spawner_idle = {
		prefix = "spawner_t3_spawner",
		to = 32,
		from = 1
	},
	spawner_t3_spawner_activate = {
		prefix = "spawner_t3_spawner",
		to = 46,
		from = 33
	},
	spawner_t3_spawner_activeloop = {
		prefix = "spawner_t3_spawner",
		to = 64,
		from = 47
	},
	spawner_t3_spawner_spawn = {
		prefix = "spawner_t3_spawner",
		to = 76,
		from = 65
	},
	spawner_t3_spawner_deactivate = {
		prefix = "spawner_t3_spawner",
		to = 92,
		from = 77
	},
	seal_of_punishment_damage_fx_idle = {
		prefix = "seal_of_punishment_damage_fx",
		to = 26,
		from = 1
	},
	seal_of_punishment_damage_fx_big_idle = {
		prefix = "seal_of_punishment_damage_fx_big",
		to = 26,
		from = 1
	},
	seal_of_punishment_particles_idle = {
		prefix = "seal_of_punishment_particles",
		to = 24,
		from = 1
	},
	seal_of_punishment_seal_idle = {
		prefix = "seal_of_punishment_seal",
		to = 1,
		from = 1
	},
	seal_of_punishment_seal_active_start = {
		prefix = "seal_of_punishment_seal",
		to = 6,
		from = 2
	},
	seal_of_punishment_seal_active_loop = {
		prefix = "seal_of_punishment_seal",
		to = 20,
		from = 7
	},
	seal_of_punishment_seal_active_end = {
		prefix = "seal_of_punishment_seal",
		to = 31,
		from = 21
	},
	upgrade_flags_teleport_fx_idle = {
		prefix = "upgrade_flags_teleport_fx",
		to = 10,
		from = 1
	},
	upgrade_flags_teleport_fx_big_idle = {
		prefix = "upgrade_flags_teleport_fx_big",
		to = 10,
		from = 1
	},
	upgrade_flags_cristal_idle = {
		prefix = "upgrade_flags_cristal",
		to = 1,
		from = 1
	},
	upgrade_flags_cristal_activation_start = {
		prefix = "upgrade_flags_cristal",
		to = 19,
		from = 2
	},
	upgrade_flags_cristal_activated_loop = {
		prefix = "upgrade_flags_cristal",
		to = 39,
		from = 20
	},
	upgrade_flags_cristal_teleport = {
		prefix = "upgrade_flags_cristal",
		to = 64,
		from = 40
	},
	upgrade_flags_particle_fx_idle = {
		prefix = "upgrade_flags_particle_fx",
		to = 16,
		from = 1
	},
	upgrade_flags_base_idle = {
		prefix = "upgrade_flags_base",
		to = 1,
		from = 1
	},
	upgrade_flags_base_activation_start = {
		prefix = "upgrade_flags_base",
		to = 7,
		from = 2
	},
	upgrade_flags_base_activated_loop = {
		prefix = "upgrade_flags_base",
		to = 8,
		from = 8
	},
	upgrade_flags_base_teleport = {
		prefix = "upgrade_flags_base",
		to = 19,
		from = 9
	},
	upgrade_flags_circle_fx_activation_start = {
		prefix = "upgrade_flags_circle_fx",
		to = 18,
		from = 1
	},
	upgrade_flags_circle_fx_activated_loop = {
		prefix = "upgrade_flags_circle_fx",
		to = 60,
		from = 19
	},
	upgrade_flags_circle_fx_teleport = {
		prefix = "upgrade_flags_circle_fx",
		to = 75,
		from = 61
	},
	display_of_true_might_heal_front_idle = {
		prefix = "display_of_true_might_heal_front",
		to = 44,
		from = 1
	},
	display_of_true_might_heal_back_idle = {
		prefix = "display_of_true_might_heal_back",
		to = 44,
		from = 1
	},
	display_of_true_might_heal_big_front_idle = {
		prefix = "display_of_true_might_heal_big_front",
		to = 44,
		from = 1
	},
	display_of_true_might_heal_big_back = {
		prefix = "display_of_true_might_heal_big_back",
		to = 44,
		from = 1
	},
	display_of_true_might_slow = {
		prefix = "display_of_true_might_slow",
		to = 34,
		from = 1
	},
	display_of_true_might_slow_deco = {
		prefix = "display_of_true_might_slow_deco",
		to = 1,
		from = 1
	},
	display_of_true_might_slow_big = {
		prefix = "display_of_true_might_slow_big",
		to = 34,
		from = 1
	},
	display_of_true_might_slow_big_deco = {
		prefix = "display_of_true_might_slow_big_deco",
		to = 1,
		from = 1
	},
	deaths_touch_fx_idle = {
		prefix = "deaths_touch_fx",
		to = 38,
		from = 1
	},
	cluster_bomb_fragment_explosion_idle = {
		prefix = "cluster_bomb_fragment_explosion",
		to = 19,
		from = 1
	},
	cluster_bomb_main_explosion_idle = {
		prefix = "cluster_bomb_main_explosion",
		to = 28,
		from = 1
	},
	cluster_bomb_explosion_decal = {
		prefix = "cluster_bomb_explosion_decal",
		to = 1,
		from = 1
	},
	cluster_bomb_fragment = {
		prefix = "cluster_bomb_fragment",
		to = 1,
		from = 1
	},
	cluster_bomb_bomb_idle = {
		prefix = "cluster_bomb_bomb",
		to = 10,
		from = 1
	},
	winter_age_ice_border_a = {
		prefix = "winter_age_ice_border_a",
		to = 1,
		from = 1
	},
	winter_age_ice_border_b = {
		prefix = "winter_age_ice_border_b",
		to = 1,
		from = 1
	},
	winter_age_ice_border_c = {
		prefix = "winter_age_ice_border_c",
		to = 1,
		from = 1
	},
	winter_age_gust = {
		prefix = "winter_age_gust",
		to = 1,
		from = 1
	},
	winter_age_snowflake_small = {
		prefix = "winter_age_snowflake_small",
		to = 1,
		from = 1
	},
	winter_age_snowflake = {
		prefix = "winter_age_snowflake",
		to = 1,
		from = 1
	},
	winter_age_stun_fx_start = {
		prefix = "winter_age_stun_fx",
		to = 20,
		from = 1
	},
	winter_age_stun_fx_idle = {
		prefix = "winter_age_stun_fx",
		to = 21,
		from = 21
	},
	winter_age_stun_fx_end = {
		prefix = "winter_age_stun_fx",
		to = 39,
		from = 22
	},
	winter_age_stun_fx_big_start = {
		prefix = "winter_age_stun_fx_big",
		to = 20,
		from = 1
	},
	winter_age_stun_fx_big_idle = {
		prefix = "winter_age_stun_fx_big",
		to = 21,
		from = 21
	},
	winter_age_stun_fx_big_end = {
		prefix = "winter_age_stun_fx_big",
		to = 39,
		from = 22
	},
	winter_age_stun_fx_air_idle = {
		prefix = "winter_age_stun_fx_air",
		to = 40,
		from = 1
	},
	winter_age_stun_fx_air_big_idle = {
		prefix = "winter_age_stun_fx_air_big",
		to = 40,
		from = 1
	},
	veznan_wrath_explosion_fx_idle = {
		prefix = "veznan_wrath_explosion_fx",
		to = 21,
		from = 1
	},
	veznan_wrath_instakill_effect_fx_idle = {
		prefix = "veznan_wrath_instakill_effect_fx",
		to = 18,
		from = 1
	},
	veznan_wrath_instakill_voladores_fx_idle = {
		prefix = "veznan_wrath_instakill_voladores_fx",
		to = 52,
		from = 1
	},
	veznan_wrath_instakill_fx = {
		prefix = "veznan_wrath_instakill_fx",
		to = 52,
		from = 1
	},
	item_summon_blackburn_attack_2_fx_idle = {
		prefix = "item_summon_blackburn_attack_2_fx",
		to = 16,
		from = 1
	},
	item_summon_blackburn_attack_2_decal_idle = {
		prefix = "item_summon_blackburn_attack_2_decal",
		to = 41,
		from = 1
	},
	item_summon_blackburn_attack_2_hit_idle = {
		prefix = "item_summon_blackburn_attack_2_hit",
		to = 10,
		from = 1
	},
	item_summon_blackburn_in_idle = {
		prefix = "item_summon_blackburn_in",
		to = 1,
		from = 1
	},
	item_summon_blackburn_blackburn_idle = {
		prefix = "item_summon_blackburn_blackburn",
		to = 1,
		from = 1
	},
	item_summon_blackburn_blackburn_in = {
		prefix = "item_summon_blackburn_blackburn",
		to = 22,
		from = 2
	},
	item_summon_blackburn_blackburn_walk = {
		prefix = "item_summon_blackburn_blackburn",
		to = 48,
		from = 23
	},
	item_summon_blackburn_blackburn_attack1 = {
		prefix = "item_summon_blackburn_blackburn",
		to = 82,
		from = 49
	},
	item_summon_blackburn_blackburn_attack2 = {
		prefix = "item_summon_blackburn_blackburn",
		to = 136,
		from = 83
	},
	item_summon_blackburn_blackburn_out = {
		prefix = "item_summon_blackburn_blackburn",
		to = 165,
		from = 137
	},
	portable_coil_lightning_fx_attack = {
		prefix = "portable_coil_lightning_fx",
		to = 11,
		from = 1
	},
	item_scroll_of_spaceshift_teleport_fx_in = {
		prefix = "item_scroll_of_spaceshift_teleport_fx",
		to = 10,
		from = 1
	},
	item_scroll_of_spaceshift_decal_in = {
		prefix = "item_scroll_of_spaceshift_decal",
		to = 43,
		from = 1
	},
	item_loot_box_chest_projectile = {
		prefix = "item_loot_box_chest_projectile",
		to = 1,
		from = 1
	},
	item_loot_box_pig_projectile = {
		prefix = "item_loot_box_pig_projectile",
		to = 1,
		from = 1
	},
	item_loot_box_statue_projectile = {
		prefix = "item_loot_box_statue_projectile",
		to = 1,
		from = 1
	},
	item_loot_box_dust_in = {
		prefix = "item_loot_box_dust",
		to = 23,
		from = 1
	},
	item_loot_box_chest_in = {
		prefix = "item_loot_box_chest",
		to = 33,
		from = 1
	},
	item_loot_box_chest_idle = {
		prefix = "item_loot_box_chest",
		to = 34,
		from = 34
	},
	item_loot_box_pig_in = {
		prefix = "item_loot_box_pig",
		to = 33,
		from = 1
	},
	item_loot_box_pig_idle = {
		prefix = "item_loot_box_pig",
		to = 34,
		from = 34
	},
	item_loot_box_statue_in = {
		prefix = "item_loot_box_statue",
		to = 33,
		from = 1
	},
	item_loot_box_statue_idle = {
		prefix = "item_loot_box_statue",
		to = 34,
		from = 34
	},
	item_loot_box_decal = {
		prefix = "item_loot_box_decal",
		to = 1,
		from = 1
	},
	item_second_breath_tap_fx = {
		prefix = "item_second_breath_tap_fx",
		to = 16,
		from = 1
	},
	item_second_breath_respawn_fx_idle = {
		prefix = "item_second_breath_respawn_fx",
		to = 17,
		from = 1
	},
	item_second_breath_decal_idle = {
		prefix = "item_second_breath_decal",
		to = 33,
		from = 1
	},
	item_second_breath_healing_fx_loop = {
		prefix = "item_second_breath_healing_fx",
		to = 19,
		from = 1
	},
	item_medical_kit_heart_idle = {
		prefix = "item_medical_kit_heart",
		to = 1,
		from = 1
	},
	item_medical_kit_heart_HUD_in = {
		prefix = "item_medical_kit_heart_HUD",
		to = 7,
		from = 1
	},
	item_medical_kit_bag_in = {
		prefix = "item_medical_kit_bag",
		to = 49,
		from = 1
	},
	item_medical_kit_bag_idle = {
		prefix = "item_medical_kit_bag",
		to = 50,
		from = 50
	},
	veznan_wrath_instakill_fx_idle = {
		prefix = "veznan_wrath_instakill_fx",
		to = 52,
		from = 1
	},
	item_summon_blackburn_attack_1_hit_idle = {
		prefix = "item_summon_blackburn_attack_1_hit",
		to = 6,
		from = 1
	},
	SunrayTower_BigRay_loop = {
		prefix = "SunrayTower_BigRay",
		to = 23,
		from = 1
	},
	SunrayTower_BigRay_fade = {
		prefix = "SunrayTower_BigRay",
		to = 34,
		from = 24
	},
	SunrayTower_SmallRay_loop = {
		prefix = "SunrayTower_SmallRay",
		to = 11,
		from = 1
	},
	SunrayTower_SmallRay_fade = {
		prefix = "SunrayTower_SmallRay",
		to = 19,
		from = 12
	}
}
local o = {}

o.animations = a

return o
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/game_animations_new.lua

-- BEGIN kr3/data/animations/hero_dragon_sun.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/hero_dragon_sun.lua

local a = {
	hero_aurion_sun_skill_overcharge_idle = {
		prefix = "hero_aurion_sun_skill_overcharge",
		to = 20,
		from = 1
	},
	hero_aurion_sun_skill_overcharge_walk = {
		prefix = "hero_aurion_sun_skill_overcharge",
		to = 20,
		from = 1
	},
	hero_aurion_sun_skill_overcharge_radiant_wave = {
		prefix = "hero_aurion_sun_skill_overcharge",
		to = 64,
		from = 21
	},
	hero_aurion_sun_skill_overcharge_worthy_foe_in = {
		prefix = "hero_aurion_sun_skill_overcharge",
		to = 86,
		from = 65
	},
	hero_aurion_sun_skill_overcharge_worthy_foe_out = {
		prefix = "hero_aurion_sun_skill_overcharge",
		to = 107,
		from = 87
	},
	hero_aurion_sun_skill_overcharge_worthy_foe_out_2 = {
		prefix = "hero_aurion_sun_skill_overcharge",
		to = 125,
		from = 108
	},
	hero_aurion_sun_skill_overcharge_solar_cleansing = {
		prefix = "hero_aurion_sun_skill_overcharge",
		to = 194,
		from = 126
	},
	hero_aurion_sun_skill_overcharge_death = {
		prefix = "hero_aurion_sun_skill_overcharge",
		to = 247,
		from = 195
	},
	hero_aurion_sun_skill_overcharge_lvlup = {
		prefix = "hero_aurion_sun_skill_overcharge",
		to = 265,
		from = 248
	},
	hero_aurion_sun_skill_overcharge_respawn = {
		prefix = "hero_aurion_sun_skill_overcharge",
		to = 265,
		from = 248
	},
	hero_aurion_sun_skill_overcharge_skill_solar_stone = {
		prefix = "hero_aurion_sun_skill_overcharge",
		to = 307,
		from = 266
	},
	hero_aurion_object_skil_solar_stone_activate_loop = {
		prefix = "hero_aurion_object_skil_solar_stone_activate",
		to = 50,
		from = 1
	},
	hero_aurion_ray_2_run = {
		prefix = "hero_aurion_ray_2",
		to = 24,
		from = 3
	},
	hero_aurion_ray_run = {
		prefix = "hero_aurion_ray",
		to = 24,
		from = 3
	},
	hero_aurion_fire_breath_decal_run = {
		prefix = "hero_aurion_fire_breath_decal",
		to = 42,
		from = 1
	},
	hero_aurion_fire_breath_hit_run = {
		prefix = "hero_aurion_fire_breath_hit",
		to = 18,
		from = 1
	},
	hero_aurion_dragon_idle = {
		prefix = "hero_aurion_dragon",
		to = 20,
		from = 1
	},
	hero_aurion_dragon_walk = {
		prefix = "hero_aurion_dragon",
		to = 20,
		from = 1
	},
	hero_aurion_dragon_radiant_wave = {
		prefix = "hero_aurion_dragon",
		to = 64,
		from = 21
	},
	hero_aurion_dragon_worthy_foe_in = {
		prefix = "hero_aurion_dragon",
		to = 86,
		from = 65
	},
	hero_aurion_dragon_worthy_foe_out = {
		prefix = "hero_aurion_dragon",
		to = 107,
		from = 87
	},
	hero_aurion_dragon_worthy_foe_out_2 = {
		prefix = "hero_aurion_dragon",
		to = 125,
		from = 108
	},
	hero_aurion_dragon_solar_cleansing = {
		prefix = "hero_aurion_dragon",
		to = 195,
		from = 126
	},
	hero_aurion_dragon_death = {
		prefix = "hero_aurion_dragon",
		to = 247,
		from = 196
	},
	hero_aurion_dragon_respawn = {
		prefix = "hero_aurion_dragon",
		to = 301,
		from = 248
	},
	hero_aurion_dragon_lvlup = {
		prefix = "hero_aurion_dragon",
		to = 337,
		from = 302
	},
	hero_aurion_dragon_skill_solar_stone = {
		prefix = "hero_aurion_dragon",
		to = 379,
		from = 338
	},
	hero_aurion_explosion_skil_solar_stone__in = {
		prefix = "hero_aurion_explosion_skil_solar_stone_",
		to = 20,
		from = 1
	},
	hero_aurion_mask_overcharge_in = {
		prefix = "hero_aurion_mask_overcharge",
		to = 28,
		from = 1
	},
	hero_aurion_decal_ulti_2_in = {
		prefix = "hero_aurion_decal_ulti_2",
		to = 1,
		from = 1
	},
	hero_aurion_decal_ulti_1_in = {
		prefix = "hero_aurion_decal_ulti_1",
		to = 1,
		from = 1
	},
	hero_aurion_decal_2_skil_solar_stone_loop = {
		prefix = "hero_aurion_decal_2_skil_solar_stone",
		to = 1,
		from = 1
	},
	hero_aurion_projectile_trail_run = {
		prefix = "hero_aurion_projectile_trail",
		to = 10,
		from = 1
	},
	hero_aurion_projectile_smoke_run = {
		prefix = "hero_aurion_projectile_smoke",
		to = 10,
		from = 1
	},
	hero_aurion_decal_skil_solar_stone_in = {
		prefix = "hero_aurion_decal_skil_solar_stone",
		to = 6,
		from = 1
	},
	hero_aurion_decal_skil_solar_stone_loop = {
		prefix = "hero_aurion_decal_skil_solar_stone",
		to = 20,
		from = 7
	},
	hero_aurion_decal_skil_solar_stone_out = {
		prefix = "hero_aurion_decal_skil_solar_stone",
		to = 41,
		from = 21
	},
	hero_aurion_projectil_skil_solar_stone_in = {
		prefix = "hero_aurion_projectil_skil_solar_stone",
		to = 25,
		from = 1
	},
	hero_aurion_fire_base_ulti_run = {
		prefix = "hero_aurion_fire_base_ulti",
		to = 10,
		from = 1
	},
	hero_aurion_fire_modifier_2_in = {
		prefix = "hero_aurion_fire_modifier_2",
		to = 14,
		from = 1
	},
	hero_aurion_fire_modifier_2_run = {
		prefix = "hero_aurion_fire_modifier_2",
		to = 24,
		from = 15
	},
	hero_aurion_fire_modifier_2_large = {
		prefix = "hero_aurion_fire_modifier_2",
		to = 24,
		from = 15
	},
	hero_aurion_fire_modifier_2_out = {
		prefix = "hero_aurion_fire_modifier_2",
		to = 33,
		from = 25
	},
	hero_aurion_fire_modifier_in = {
		prefix = "hero_aurion_fire_modifier",
		to = 14,
		from = 1
	},
	hero_aurion_fire_modifier_run = {
		prefix = "hero_aurion_fire_modifier",
		to = 24,
		from = 15
	},
	hero_aurion_fire_modifier_out = {
		prefix = "hero_aurion_fire_modifier",
		to = 33,
		from = 25
	},
	hero_aurion_decal_teleport_in = {
		prefix = "hero_aurion_decal_teleport",
		to = 13,
		from = 1
	},
	hero_aurion_explosion_run = {
		prefix = "hero_aurion_explosion",
		to = 19,
		from = 1
	},
	hero_aurion_helth_run = {
		prefix = "hero_aurion_helth",
		to = 42,
		from = 1
	},
	hero_aurion_healing_run = {
		prefix = "hero_aurion_healing",
		to = 28,
		from = 1
	},
	hero_aurion_decal_target_teleport_in = {
		prefix = "hero_aurion_decal_target_teleport",
		to = 16,
		from = 1
	},
	hero_aurion_decal_target_teleport_loop = {
		prefix = "hero_aurion_decal_target_teleport",
		to = 46,
		from = 17
	},
	hero_aurion_decal_target_teleport_out = {
		prefix = "hero_aurion_decal_target_teleport",
		to = 62,
		from = 47
	},
	hero_aurion_decal_target_teleport_full = {
		prefix = "hero_aurion_decal_target_teleport",
		to = 62,
		from = 1
	},
	hero_aurion_decal_ulti_base_in = {
		prefix = "hero_aurion_decal_ulti_base",
		to = 37,
		from = 1
	},
	hero_aurion_ulti_in = {
		prefix = "hero_aurion_ulti",
		to = 40,
		from = 1
	},
	hero_aurion_ulti_loop = {
		prefix = "hero_aurion_ulti",
		to = 61,
		from = 41
	},
	hero_aurion_ulti_out = {
		prefix = "hero_aurion_ulti",
		to = 77,
		from = 62
	},
	hero_aurion_ulti_in_run = {
		prefix = "hero_aurion_ulti_in",
		to = 23,
		from = 1
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/hero_dragon_sun.lua

-- BEGIN kr3/data/animations/kr4_branch_campaigns.lua
do
	local __chunk = (function()
local a = {
	["blue_wyvern_idle"] = {
		prefix = "blue_wyvern",
		from = 1,
		to = 1
	},
	["hunting_eagle_idle"] = {
		prefix = "hunting_eagle",
		from = 1,
		to = 1
	},
	["BlackCorsair_run"] = {
		prefix = "blackcorsair",
		from = 1,
		to = 14
	},
	["BlackCorsair_signal"] = {
		prefix = "blackcorsair",
		from = 147,
		to = 170
	},
	["Stage11_spawn_Effect_run"] = {
		prefix = "Stage11_spawn_Effect",
		from = 1,
		to = 22
	},
	["Stage12_barn_chicken_idle"] = {
		prefix = "Stage12_barn_chicken",
		from = 1,
		to = 1
	},
	["Stage12_barn_chicken_run"] = {
		prefix = "Stage12_barn_chicken",
		from = 2,
		to = 111
	},
	["Stage12_bigwaves_run"] = {
		prefix = "Stage12_bigwaves",
		from = 1,
		to = 56
	},
	["Stage12_bridge_waves_run"] = {
		prefix = "Stage12_bridge_waves",
		from = 1,
		to = 22
	},
	["Stage12_lito_idle"] = {
		prefix = "Stage12_lito",
		from = 1,
		to = 1
	},
	["Stage12_lito_run"] = {
		prefix = "Stage12_lito",
		from = 2,
		to = 110
	},
	["Stage12_sheep_big_death"] = {
		prefix = "Stage12_sheep_big",
		from = 265,
		to = 274
	},
	["Stage12_sheep_big_eatFlower"] = {
		prefix = "Stage12_sheep_big",
		from = 48,
		to = 137
	},
	["Stage12_sheep_big_eatGrass"] = {
		prefix = "Stage12_sheep_big",
		from = 9,
		to = 47
	},
	["Stage12_sheep_big_eatShroom"] = {
		prefix = "Stage12_sheep_big",
		from = 138,
		to = 264
	},
	["Stage12_sheep_big_idle"] = {
		prefix = "Stage12_sheep_big",
		from = 1,
		to = 1
	},
	["Stage12_sheep_big_walk"] = {
		prefix = "Stage12_sheep_big",
		from = 2,
		to = 8
	},
	["Stage12_sheep_small_death"] = {
		prefix = "Stage12_sheep_small",
		from = 47,
		to = 58
	},
	["Stage12_sheep_small_eat"] = {
		prefix = "Stage12_sheep_small",
		from = 9,
		to = 46
	},
	["Stage12_sheep_small_idle"] = {
		prefix = "Stage12_sheep_small",
		from = 1,
		to = 1
	},
	["Stage12_sheep_small_walk"] = {
		prefix = "Stage12_sheep_small",
		from = 2,
		to = 8
	},
	["Stage12_water_shine_run"] = {
		prefix = "Stage12_water_shine",
		from = 1,
		to = 86
	},
	["Stage12_windmill_run"] = {
		prefix = "Stage12_windmill_layer",
		from = 1,
		to = 20
	},
	["Stage14_light_action"] = {
		prefix = "Stage14_light_layer",
		from = 29,
		to = 69
	},
	["Stage14_light_run"] = {
		prefix = "Stage14_light_layer",
		from = 1,
		to = 28
	},
	["Stage16_water_run"] = {
		prefix = "Stage16_water",
		from = 1,
		to = 14
	},
	["Stage3_mole_layer_hit"] = {
		prefix = "Stage3_mole_layer",
		from = 34,
		to = 125
	},
	["Stage3_mole_layer_jump"] = {
		prefix = "Stage3_mole_layer",
		from = 1,
		to = 33
	},
	["Stage4_smoke_run"] = {
		prefix = "Stage4_smoke",
		from = 1,
		to = 64
	},
	["Stage5_assemply_line_close"] = {
		prefix = "Stage5_assembly_line_layer",
		from = 124,
		to = 132
	},
	["Stage5_assembly_line_layerX_close"] = {
		layer_from = 1,
		layer_to = 6,
		layer_prefix = "Stage5_assembly_line_layer%i",
		from = 124,
		to = 132
	},
	["Stage5_assemply_line_hammer"] = {
		prefix = "Stage5_assembly_line_layer",
		from = 20,
		to = 50
	},
	["Stage5_assembly_line_layerX_hammer"] = {
		layer_from = 1,
		layer_to = 6,
		layer_prefix = "Stage5_assembly_line_layer%i",
		from = 20,
		to = 50
	},
	["Stage5_assemply_line_light"] = {
		prefix = "Stage5_assembly_line_layer",
		from = 51,
		to = 114
	},
	["Stage5_assembly_line_layerX_light"] = {
		layer_from = 1,
		layer_to = 6,
		layer_prefix = "Stage5_assembly_line_layer%i",
		from = 51,
		to = 114
	},
	["Stage5_assemply_line_move"] = {
		prefix = "Stage5_assembly_line_layer",
		from = 1,
		to = 19
	},
	["Stage5_assembly_line_layerX_move"] = {
		layer_from = 1,
		layer_to = 6,
		layer_prefix = "Stage5_assembly_line_layer%i",
		from = 1,
		to = 19
	},
	["Stage5_assemply_line_open"] = {
		prefix = "Stage5_assembly_line_layer",
		from = 115,
		to = 123
	},
	["Stage5_assembly_line_layerX_open"] = {
		layer_from = 1,
		layer_to = 6,
		layer_prefix = "Stage5_assembly_line_layer%i",
		from = 115,
		to = 123
	},
	["Stage_11_boss_deco_ice_run"] = {
		prefix = "Stage11_boss_deco_ice",
		from = 1,
		to = 16
	},
	["Stage_11_boss_deco_idle1"] = {
		prefix = "Stage11_boss_deco_layer",
		from = 1,
		to = 1
	},
	["Stage_11_boss_deco_idle2"] = {
		prefix = "Stage11_boss_deco_layer",
		from = 2,
		to = 2
	},
	["Stage_11_boss_deco_idle3"] = {
		prefix = "Stage11_boss_deco_layer",
		from = 3,
		to = 3
	},
	["Stage_11_boss_deco_run"] = {
		prefix = "Stage11_boss_deco_layer",
		from = 4,
		to = 32
	},
	["Stage_11_cannon_dead"] = {
		prefix = "Stage_11_cannon_layer",
		from = 161,
		to = 173
	},
	["Stage_11_cannon_endcharge"] = {
		prefix = "Stage_11_cannon_layer",
		from = 95,
		to = 122
	},
	["Stage_11_cannon_loopcharge"] = {
		prefix = "Stage_11_cannon_layer",
		from = 85,
		to = 94
	},
	["Stage_11_cannon_loopdead"] = {
		prefix = "Stage_11_cannon_layer",
		from = 174,
		to = 196
	},
	["Stage_11_cannon_loopready"] = {
		prefix = "Stage_11_cannon_layer",
		from = 123,
		to = 138
	},
	["Stage_11_cannon_shock"] = {
		prefix = "Stage_11_cannon_layer",
		from = 245,
		to = 268
	},
	["Stage_11_cannon_shockSmoke"] = {
		prefix = "Stage_11_cannon_layer",
		from = 1,
		to = 24
	},
	["Stage_11_cannon_shoot"] = {
		prefix = "Stage_11_cannon_layer",
		from = 139,
		to = 160
	},
	["Stage_11_cannon_smokeIn"] = {
		prefix = "Stage_11_cannon_layer",
		from = 197,
		to = 220
	},
	["Stage_11_cannon_smokeOut"] = {
		prefix = "Stage_11_cannon_layer",
		from = 221,
		to = 244
	},
	["Stage_11_cannon_startcharge"] = {
		prefix = "Stage_11_cannon_layer",
		from = 25,
		to = 84
	},
	["Stage_11_cannon_traffic_guy_idle"] = {
		prefix = "Stage_11_cannon_traffic_guy",
		from = 1,
		to = 1
	},
	["Stage_11_cannon_traffic_guy_signs1"] = {
		prefix = "Stage_11_cannon_traffic_guy",
		from = 14,
		to = 27
	},
	["Stage_11_cannon_traffic_guy_signs2"] = {
		prefix = "Stage_11_cannon_traffic_guy",
		from = 28,
		to = 40
	},
	["Stage_11_cannon_traffic_guy_signs3"] = {
		prefix = "Stage_11_cannon_traffic_guy",
		from = 41,
		to = 54
	},
	["Stage_11_cannon_traffic_guy_walk"] = {
		prefix = "Stage_11_cannon_traffic_guy",
		from = 2,
		to = 13
	},
	["Stage_19_frogger_run"] = {
		prefix = "Stage_19_frogger",
		from = 1,
		to = 101
	},
	["Stage_1_bilbo_bilbo"] = {
		prefix = "Stage_1_bilbo_layer",
		from = 96,
		to = 326
	},
	["Stage_1_bilbo_idle"] = {
		prefix = "Stage_1_bilbo_layer",
		from = 1,
		to = 1
	},
	["Stage_1_bilbo_in"] = {
		prefix = "Stage_1_bilbo_layer",
		from = 2,
		to = 56
	},
	["Stage_1_bilbo_loop"] = {
		prefix = "Stage_1_bilbo_layer",
		from = 57,
		to = 80
	},
	["Stage_1_bilbo_out"] = {
		prefix = "Stage_1_bilbo_layer",
		from = 81,
		to = 95
	},
	["Stage_7_cuerno_curseLoop"] = {
		prefix = "Stage_7_cuerno_layer",
		from = 159,
		to = 166
	},
	["Stage_7_cuerno_in"] = {
		prefix = "Stage_7_cuerno_layer",
		from = 2,
		to = 11
	},
	["Stage_7_cuerno_lookLoop"] = {
		prefix = "Stage_7_cuerno_layer",
		from = 12,
		to = 42
	},
	["Stage_7_cuerno_outCurse"] = {
		prefix = "Stage_7_cuerno_layer",
		from = 167,
		to = 172
	},
	["Stage_7_cuerno_outPlay"] = {
		prefix = "Stage_7_cuerno_layer",
		from = 121,
		to = 145
	},
	["Stage_7_cuerno_playLoop"] = {
		prefix = "Stage_7_cuerno_layer",
		from = 99,
		to = 120
	},
	["Stage_7_cuerno_run"] = {
		prefix = "Stage_7_cuerno_layer",
		from = 1,
		to = 1
	},
	["Stage_7_cuerno_toCurse"] = {
		prefix = "Stage_7_cuerno_layer",
		from = 146,
		to = 158
	},
	["Stage_7_cuerno_toPlay"] = {
		prefix = "Stage_7_cuerno_layer",
		from = 67,
		to = 98
	},
	["Stage_7_cuerno_warn"] = {
		prefix = "Stage_7_cuerno_layer",
		from = 43,
		to = 66
	},
	["achievement_cofre_idle"] = {
		prefix = "achievement_cofre",
		from = 1,
		to = 1
	},
	["achievement_cofre_tap"] = {
		prefix = "achievement_cofre",
		from = 2,
		to = 29
	},
	["achievement_find_the_capt_run"] = {
		prefix = "achievement_find_the_capt_layer",
		from = 1,
		to = 14
	},
	["achievement_fireworks_box_idle"] = {
		prefix = "achievement_fireworks_box",
		from = 1,
		to = 1
	},
	["achievement_fireworks_box_run"] = {
		prefix = "achievement_fireworks_box",
		from = 2,
		to = 77
	},
	["achievement_fireworks_particle_run"] = {
		prefix = "achievement_fireworks_particle",
		from = 1,
		to = 13
	},
	["achievement_mono_death"] = {
		prefix = "achievement_mono",
		from = 22,
		to = 29
	},
	["achievement_mono_idle"] = {
		prefix = "achievement_mono",
		from = 1,
		to = 1
	},
	["achievement_mono_tap"] = {
		prefix = "achievement_mono",
		from = 2,
		to = 21
	},
	["achievement_shaolin_master_action"] = {
		prefix = "achievement_shaolin_master",
		from = 9,
		to = 60
	},
	["achievement_shaolin_master_idle"] = {
		prefix = "achievement_shaolin_master",
		from = 7,
		to = 8
	},
	["achievement_shaolin_master_in"] = {
		prefix = "achievement_shaolin_master",
		from = 1,
		to = 6
	},
	["achievement_shaolin_master_out"] = {
		prefix = "achievement_shaolin_master",
		from = 61,
		to = 84
	},
	["achievement_ski_yeti_ski_idle"] = {
		prefix = "achievement_ski_yeti_ski",
		from = 3,
		to = 3
	},
	["achievement_ski_yeti_ski_idleDown"] = {
		prefix = "achievement_ski_yeti_ski",
		from = 1,
		to = 1
	},
	["achievement_ski_yeti_ski_idleQuarter"] = {
		prefix = "achievement_ski_yeti_ski",
		from = 2,
		to = 2
	},
	["achievement_ski_yeti_ski_walk"] = {
		prefix = "achievement_ski_yeti_ski",
		from = 76,
		to = 100
	},
	["achievement_ski_yeti_ski_walkDown"] = {
		prefix = "achievement_ski_yeti_ski",
		from = 4,
		to = 27
	},
	["achievement_ski_yeti_ski_walkQuarter"] = {
		prefix = "achievement_ski_yeti_ski",
		from = 28,
		to = 75
	},
	["achievement_ski_yeti_yeti_death"] = {
		prefix = "achievement_ski_yeti_yeti_layer",
		from = 65,
		to = 111
	},
	["achievement_ski_yeti_yeti_eat"] = {
		prefix = "achievement_ski_yeti_yeti_layer",
		from = 11,
		to = 64
	},
	["achievement_ski_yeti_yeti_walk"] = {
		prefix = "achievement_ski_yeti_yeti_layer",
		from = 1,
		to = 10
	},
	["achievement_the_thing_bark"] = {
		prefix = "achievement_the_thing_layer",
		from = 108,
		to = 145
	},
	["achievement_the_thing_death"] = {
		prefix = "achievement_the_thing_layer",
		from = 146,
		to = 180
	},
	["achievement_the_thing_dig"] = {
		prefix = "achievement_the_thing_layer",
		from = 37,
		to = 107
	},
	["achievement_the_thing_idle"] = {
		prefix = "achievement_the_thing_layer",
		from = 1,
		to = 1
	},
	["achievement_the_thing_sniff"] = {
		prefix = "achievement_the_thing_layer",
		from = 2,
		to = 36
	},
	["achievement_the_thing_thingDeath"] = {
		prefix = "achievement_the_thing_layer",
		from = 208,
		to = 224
	},
	["achievement_the_thing_thingLoop"] = {
		prefix = "achievement_the_thing_layer",
		from = 181,
		to = 207
	},
	["achievement_tiburon_idle"] = {
		prefix = "achievement_tiburon",
		from = 1,
		to = 26
	},
	["achievement_tiburon_splash_run"] = {
		prefix = "achievement_tiburon_splash",
		from = 1,
		to = 61
	},
	["achievement_tiburon_tap_one"] = {
		prefix = "achievement_tiburon",
		from = 27,
		to = 67
	},
	["achievement_tiburon_tap_two"] = {
		prefix = "achievement_tiburon",
		from = 68,
		to = 136
	},
	["aladdin_achievement_idle"] = {
		prefix = "aladdin_achievement",
		from = 1,
		to = 1
	},
	["aladdin_achievement_moving"] = {
		prefix = "aladdin_achievement",
		from = 1,
		to = 19
	},
	["aladdin_achievement_special"] = {
		prefix = "aladdin_achievement",
		from = 55,
		to = 205
	},
	["aladdin_achievement_touch"] = {
		prefix = "aladdin_achievement",
		from = 20,
		to = 54
	},
	["alleria_arrow_decal_idle"] = {
		prefix = "alleria_arrow_decal",
		from = 9,
		to = 9
	},
	["alleria_arrow_decal_run"] = {
		prefix = "alleria_arrow_decal",
		from = 1,
		to = 8
	},
	["alleria_arrow_multishoot_decal_idle"] = {
		prefix = "alleria_arrow_multishoot_decal",
		from = 9,
		to = 9
	},
	["alleria_arrow_multishoot_decal_run"] = {
		prefix = "alleria_arrow_multishoot_decal",
		from = 1,
		to = 8
	},
	["alleria_call"] = {
		prefix = "alleria",
		from = 183,
		to = 220
	},
	["alleria_cutscene"] = {
		prefix = "alleria",
		from = 221,
		to = 244
	},
	["alleria_death"] = {
		prefix = "alleria",
		from = 146,
		to = 182
	},
	["alleria_idle"] = {
		prefix = "alleria",
		from = 1,
		to = 1
	},
	["alleria_in"] = {
		prefix = "alleria",
		from = 117,
		to = 145
	},
	["alleria_leaves_run"] = {
		prefix = "alleria_leaves",
		from = 1,
		to = 12
	},
	["alleria_melee1"] = {
		prefix = "alleria",
		from = 59,
		to = 86
	},
	["alleria_melee2"] = {
		prefix = "alleria",
		from = 87,
		to = 116
	},
	["alleria_multishoot"] = {
		prefix = "alleria",
		from = 37,
		to = 52
	},
	["alleria_shootEnd"] = {
		prefix = "alleria",
		from = 53,
		to = 58
	},
	["alleria_shootPrep"] = {
		prefix = "alleria",
		from = 17,
		to = 26
	},
	["alleria_shootStart"] = {
		prefix = "alleria",
		from = 27,
		to = 36
	},
	["alleria_walk"] = {
		prefix = "alleria",
		from = 2,
		to = 16
	},
	["alric_attack"] = {
		prefix = "alric",
		from = 99,
		to = 130
	},
	["alric_deathIn"] = {
		prefix = "alric",
		from = 325,
		to = 364
	},
	["alric_deathLoop"] = {
		prefix = "alric",
		from = 365,
		to = 394
	},
	["alric_idle"] = {
		prefix = "alric",
		from = 1,
		to = 14
	},
	["alric_sandwarrior_attack"] = {
		prefix = "sand_warrior",
		from = 113,
		to = 143
	},
	["alric_sandwarrior_death"] = {
		prefix = "sand_warrior",
		from = 144,
		to = 203
	},
	["alric_sandwarrior_idle"] = {
		prefix = "sand_warrior",
		from = 32,
		to = 32
	},
	["alric_sandwarrior_spawn"] = {
		prefix = "sand_warrior",
		from = 1,
		to = 31
	},
	["alric_sandwarrior_twisterInit"] = {
		prefix = "sand_warrior",
		from = 33,
		to = 61
	},
	["alric_sandwarrior_twisterOut"] = {
		prefix = "sand_warrior",
		from = 91,
		to = 112
	},
	["alric_sandwarrior_walk"] = {
		prefix = "sand_warrior",
		from = 62,
		to = 90
	},
	["alric_special"] = {
		prefix = "alric",
		from = 131,
		to = 180
	},
	["alric_summon"] = {
		prefix = "alric",
		from = 181,
		to = 218
	},
	["alric_tauntIn"] = {
		prefix = "alric",
		from = 298,
		to = 305
	},
	["alric_tauntLoop"] = {
		prefix = "alric",
		from = 306,
		to = 313
	},
	["alric_tauntOut"] = {
		prefix = "alric",
		from = 314,
		to = 324
	},
	["alric_twisterInit"] = {
		prefix = "alric",
		from = 219,
		to = 246
	},
	["alric_twisterOut"] = {
		prefix = "alric",
		from = 276,
		to = 297
	},
	["alric_twisterWalk"] = {
		prefix = "alric",
		from = 247,
		to = 275
	},
	["alric_twisterWalkDown"] = {
		prefix = "alric",
		from = 247,
		to = 275
	},
	["alric_twisterWalkUp"] = {
		prefix = "alric",
		from = 247,
		to = 275
	},
	["alric_walk"] = {
		prefix = "alric",
		from = 15,
		to = 42
	},
	["alric_walkDown"] = {
		prefix = "alric",
		from = 43,
		to = 70
	},
	["alric_walkUp"] = {
		prefix = "alric",
		from = 71,
		to = 98
	},
	["apex_shard_attack"] = {
		prefix = "apex_shard",
		from = 32,
		to = 56
	},
	["apex_shard_death"] = {
		prefix = "apex_shard",
		from = 128,
		to = 176
	},
	["apex_shard_idle"] = {
		prefix = "apex_shard",
		from = 1,
		to = 1
	},
	["apex_shard_spawn"] = {
		prefix = "apex_shard",
		from = 57,
		to = 127
	},
	["apex_shard_spawnBullet"] = {
		prefix = "apex_shard",
		from = 82,
		to = 127
	},
	["apex_shard_walk"] = {
		prefix = "apex_shard",
		from = 2,
		to = 11
	},
	["apex_shard_walkDown"] = {
		prefix = "apex_shard",
		from = 22,
		to = 31
	},
	["apex_shard_walkUp"] = {
		prefix = "apex_shard",
		from = 12,
		to = 21
	},
	["apex_stalker_attack"] = {
		prefix = "apex_stalker",
		from = 48,
		to = 71
	},
	["apex_stalker_death"] = {
		prefix = "apex_stalker",
		from = 72,
		to = 114
	},
	["apex_stalker_idle"] = {
		prefix = "apex_stalker",
		from = 1,
		to = 1
	},
	["apex_stalker_walk"] = {
		prefix = "apex_stalker",
		from = 2,
		to = 17
	},
	["apex_stalker_walkDown"] = {
		prefix = "apex_stalker",
		from = 18,
		to = 32
	},
	["apex_stalker_walkUp"] = {
		prefix = "apex_stalker",
		from = 33,
		to = 47
	},
	["arcane_magus_attack"] = {
		prefix = "arcane_magus",
		from = 96,
		to = 119
	},
	["arcane_magus_death"] = {
		prefix = "arcane_magus",
		from = 150,
		to = 195
	},
	["arcane_magus_decal_run"] = {
		prefix = "arcane_magus_teleport_decal",
		from = 1,
		to = 23
	},
	["arcane_magus_idle"] = {
		prefix = "arcane_magus",
		from = 1,
		to = 1
	},
	["arcane_magus_projectile_hit_run"] = {
		prefix = "arcane_magus_projectile_hit",
		from = 1,
		to = 9
	},
	["arcane_magus_shoot"] = {
		prefix = "arcane_magus",
		from = 50,
		to = 95
	},
	["arcane_magus_shoot_decal_run"] = {
		prefix = "arcane_magus_teleport_shoot_decal",
		from = 1,
		to = 18
	},
	["arcane_magus_teleport"] = {
		prefix = "arcane_magus",
		from = 120,
		to = 149
	},
	["arcane_magus_walk"] = {
		prefix = "arcane_magus",
		from = 2,
		to = 17
	},
	["arcane_magus_walkDown"] = {
		prefix = "arcane_magus",
		from = 34,
		to = 49
	},
	["arcane_magus_walkUp"] = {
		prefix = "arcane_magus",
		from = 18,
		to = 33
	},
	["arrow_decal_run"] = {
		prefix = "archer_hero_arrows_decal",
		from = 1,
		to = 11
	},
	["assasin_attack"] = {
		prefix = "assasin",
		from = 2,
		to = 29
	},
	["assasin_death"] = {
		prefix = "assasin",
		from = 77,
		to = 91
	},
	["assasin_dodge"] = {
		prefix = "assasin",
		from = 62,
		to = 76
	},
	["assasin_idle"] = {
		prefix = "assasin",
		from = 1,
		to = 1
	},
	["assasin_instakill"] = {
		prefix = "assasin",
		from = 30,
		to = 61
	},
	["assasin_walk"] = {
		prefix = "assasin",
		from = 92,
		to = 107
	},
	["assasin_walkDown"] = {
		prefix = "assasin",
		from = 108,
		to = 123
	},
	["assasin_walkUp"] = {
		prefix = "assasin",
		from = 124,
		to = 139
	},
	["bandit_attack"] = {
		prefix = "linirea_caravan_bandit",
		from = 34,
		to = 53
	},
	["bandit_death"] = {
		prefix = "linirea_caravan_bandit",
		from = 54,
		to = 69
	},
	["bandit_idle"] = {
		prefix = "linirea_caravan_bandit",
		from = 1,
		to = 1
	},
	["bandit_walk"] = {
		prefix = "linirea_caravan_bandit",
		from = 2,
		to = 17
	},
	["bandit_walkDown"] = {
		prefix = "linirea_caravan_bandit",
		from = 18,
		to = 33
	},
	["big_berta_brea_explotion_run"] = {
		prefix = "big_berta_brea_explotion_layer",
		from = 1,
		to = 61
	},
	["big_berta_brea_particle_run"] = {
		prefix = "big_berta_brea_particle",
		from = 1,
		to = 46
	},
	["big_berta_chickens_eat1"] = {
		prefix = "big_berta_chickens_layer",
		from = 18,
		to = 34
	},
	["big_berta_chickens_eat2"] = {
		prefix = "big_berta_chickens_layer",
		from = 35,
		to = 51
	},
	["big_berta_chickens_eat3"] = {
		prefix = "big_berta_chickens_layer",
		from = 52,
		to = 68
	},
	["big_berta_chickens_idle"] = {
		prefix = "big_berta_chickens_layer",
		from = 1,
		to = 1
	},
	["big_berta_chickens_jump"] = {
		prefix = "big_berta_chickens_layer",
		from = 2,
		to = 17
	},
	["big_berta_chickens_walk1"] = {
		prefix = "big_berta_chickens_layer",
		from = 69,
		to = 127
	},
	["big_berta_chickens_walk2"] = {
		prefix = "big_berta_chickens_layer",
		from = 128,
		to = 186
	},
	["big_berta_chickens_walk3"] = {
		prefix = "big_berta_chickens_layer",
		from = 187,
		to = 245
	},
	["big_berta_fire"] = {
		prefix = "big_berta_layer",
		from = 2,
		to = 78
	},
	["big_berta_idle"] = {
		prefix = "big_berta_layer",
		from = 1,
		to = 1
	},
	["blackcorsair_attack"] = {
		prefix = "blackcorsair",
		from = 111,
		to = 146
	},
	["blackcorsair_death"] = {
		prefix = "blackcorsair",
		from = 233,
		to = 283
	},
	["blackcorsair_idle"] = {
		prefix = "blackcorsair",
		from = 1,
		to = 14
	},
	["blackcorsair_taunt"] = {
		prefix = "blackcorsair",
		from = 297,
		to = 308
	},
	["blackcorsair_walk"] = {
		prefix = "blackcorsair",
		from = 15,
		to = 46
	},
	["blackcorsair_walkDown"] = {
		prefix = "blackcorsair",
		from = 47,
		to = 78
	},
	["blackcorsair_walkUp"] = {
		prefix = "blackcorsair",
		from = 79,
		to = 110
	},
	["blacksmith_achievement_worker_run"] = {
		prefix = "blacksmith_achievement_worker",
		from = 1,
		to = 1
	},
	["blacksmith_achievement_worker_special"] = {
		prefix = "blacksmith_achievement_worker",
		from = 2,
		to = 62
	},
	["blacksmith_fire_in"] = {
		prefix = "blacksmith_fire",
		from = 35,
		to = 42
	},
	["blacksmith_fire_out"] = {
		prefix = "blacksmith_fire",
		from = 24,
		to = 34
	},
	["blacksmith_fire_run"] = {
		prefix = "blacksmith_fire",
		from = 1,
		to = 12
	},
	["blacksmith_fire_tap"] = {
		prefix = "blacksmith_fire",
		from = 13,
		to = 23
	},
	["blacksmith_fire_tap_tap"] = {
		prefix = "blacksmith_fire_tap",
		from = 1,
		to = 9
	},
	["blacksmith_idle"] = {
		prefix = "blacksmith_layer",
		from = 1,
		to = 1
	},
	["blacksmith_idle_over"] = {
		prefix = "blacksmith_layer",
		from = 1,
		to = 1
	},
	["blacksmith_run"] = {
		prefix = "blacksmith_layer",
		from = 2,
		to = 9
	},
	["blue_wyvern_death"] = {
		prefix = "blue_wyvern",
		from = 55,
		to = 69
	},
	["blue_wyvern_spawn"] = {
		prefix = "blue_wyvern",
		from = 70,
		to = 87
	},
	["blue_wyvern_walk"] = {
		prefix = "blue_wyvern",
		from = 1,
		to = 18
	},
	["blue_wyvern_walkDown"] = {
		prefix = "blue_wyvern",
		from = 19,
		to = 36
	},
	["blue_wyvern_walkUp"] = {
		prefix = "blue_wyvern",
		from = 37,
		to = 54
	},
	["boat_sail_run"] = {
		prefix = "boat_sail",
		from = 1,
		to = 24
	},
	["bone_carrier_attack"] = {
		prefix = "bone_carrier",
		from = 129,
		to = 160
	},
	["bone_carrier_death"] = {
		prefix = "bone_carrier",
		from = 161,
		to = 230
	},
	["bone_carrier_idle"] = {
		prefix = "bone_carrier",
		from = 1,
		to = 30
	},
	["bone_carrier_modifier_init"] = {
		prefix = "bone_carrier_modifier",
		from = 1,
		to = 9
	},
	["bone_carrier_modifier_loop"] = {
		prefix = "bone_carrier_modifier",
		from = 10,
		to = 10
	},
	["bone_carrier_walk"] = {
		prefix = "bone_carrier",
		from = 31,
		to = 60
	},
	["bone_carrier_walkDown"] = {
		prefix = "bone_carrier",
		from = 61,
		to = 94
	},
	["bone_carrier_walkUp"] = {
		prefix = "bone_carrier",
		from = 95,
		to = 128
	},
	["boss_deep_king_unit_layer_abiltyIn"] = {
		prefix = "boss_deep_king_unit_layer",
		from = 114,
		to = 150
	},
	["boss_deep_king_unit_layer_abiltyLoop"] = {
		prefix = "boss_deep_king_unit_layer",
		from = 151,
		to = 152
	},
	["boss_deep_king_unit_layer_abiltyOut"] = {
		prefix = "boss_deep_king_unit_layer",
		from = 153,
		to = 179
	},
	["boss_deep_king_unit_layer_attack"] = {
		prefix = "boss_deep_king_unit_layer",
		from = 87,
		to = 113
	},
	["boss_deep_king_unit_layer_death"] = {
		prefix = "boss_deep_king_unit_layer",
		from = 305,
		to = 326
	},
	["boss_deep_king_unit_layer_idle"] = {
		prefix = "boss_deep_king_unit_layer",
		from = 1,
		to = 2
	},
	["boss_deep_king_unit_layer_summon"] = {
		prefix = "boss_deep_king_unit_layer",
		from = 180,
		to = 215
	},
	["boss_deep_king_unit_layer_taunt"] = {
		prefix = "boss_deep_king_unit_layer",
		from = 216,
		to = 235
	},
	["boss_deep_king_unit_layer_walk"] = {
		prefix = "boss_deep_king_unit_layer",
		from = 3,
		to = 30
	},
	["boss_deep_king_unit_layer_walkDown"] = {
		prefix = "boss_deep_king_unit_layer",
		from = 59,
		to = 86
	},
	["boss_deep_king_unit_layer_walkUp"] = {
		prefix = "boss_deep_king_unit_layer",
		from = 31,
		to = 58
	},
	["boss_dwarf_angry"] = {
		prefix = "boss_dwarf",
		from = 2,
		to = 41
	},
	["boss_dwarf_back"] = {
		prefix = "boss_dwarf",
		from = 200,
		to = 227
	},
	["boss_dwarf_coins_run"] = {
		prefix = "boss_dwarf_coins",
		from = 1,
		to = 10
	},
	["boss_dwarf_correct"] = {
		prefix = "boss_dwarf",
		from = 174,
		to = 199
	},
	["boss_dwarf_down"] = {
		prefix = "boss_dwarf",
		from = 247,
		to = 249
	},
	["boss_dwarf_down2"] = {
		prefix = "boss_dwarf",
		from = 260,
		to = 262
	},
	["boss_dwarf_downOut"] = {
		prefix = "boss_dwarf",
		from = 250,
		to = 259
	},
	["boss_dwarf_downOut2"] = {
		prefix = "boss_dwarf",
		from = 263,
		to = 271
	},
	["boss_dwarf_fail"] = {
		prefix = "boss_dwarf",
		from = 64,
		to = 173
	},
	["boss_dwarf_fall"] = {
		prefix = "boss_dwarf",
		from = 83,
		to = 173
	},
	["boss_dwarf_idle"] = {
		prefix = "boss_dwarf",
		from = 1,
		to = 1
	},
	["boss_dwarf_jump"] = {
		prefix = "boss_dwarf",
		from = 228,
		to = 234
	},
	["boss_dwarf_jumpOn"] = {
		prefix = "boss_dwarf",
		from = 235,
		to = 238
	},
	["boss_dwarf_mecha_attack"] = {
		prefix = "boss_dwarf_mecha",
		from = 72,
		to = 125
	},
	["boss_dwarf_mecha_death"] = {
		prefix = "boss_dwarf_mecha",
		from = 200,
		to = 256
	},
	["boss_dwarf_mecha_idle"] = {
		prefix = "boss_dwarf_mecha",
		from = 45,
		to = 45
	},
	["boss_dwarf_mecha_missil"] = {
		prefix = "boss_dwarf_mecha",
		from = 126,
		to = 199
	},
	["boss_dwarf_mecha_travel"] = {
		prefix = "boss_dwarf_mecha_proyectile",
		from = 1,
		to = 3
	},
	["boss_dwarf_mecha_up"] = {
		prefix = "boss_dwarf_mecha",
		from = 1,
		to = 44
	},
	["boss_dwarf_mecha_walk"] = {
		prefix = "boss_dwarf_mecha",
		from = 46,
		to = 71
	},
	["boss_dwarf_mecha_walkDown"] = {
		prefix = "boss_dwarf_mecha",
		from = 46,
		to = 71
	},
	["boss_dwarf_mecha_walkUp"] = {
		prefix = "boss_dwarf_mecha",
		from = 46,
		to = 71
	},
	["boss_dwarf_smoke_particle_run"] = {
		prefix = "boss_dwarf_mecha_proyectile_smoke",
		from = 1,
		to = 8
	},
	["boss_dwarf_splash"] = {
		prefix = "boss_dwarf_splash",
		from = 1,
		to = 29
	},
	["boss_dwarf_steal"] = {
		prefix = "boss_dwarf",
		from = 239,
		to = 246
	},
	["boss_dwarf_throne_run"] = {
		prefix = "boss_dwarf_throne",
		from = 1,
		to = 1
	},
	["boss_dwarf_up"] = {
		prefix = "boss_dwarf",
		from = 42,
		to = 63
	},
	["boss_ghost_unit_idle"] = {
		prefix = "boss_ghost_unit",
		from = 1,
		to = 28
	},
	["boss_ghost_unit_taunt"] = {
		prefix = "boss_ghost_unit",
		from = 29,
		to = 56
	},
	["boss_macaque_ability"] = {
		prefix = "boss_macaque",
		from = 112,
		to = 168
	},
	["boss_macaque_attack"] = {
		prefix = "boss_macaque",
		from = 63,
		to = 111
	},
	["boss_macaque_block_tower_layer_idle"] = {
		prefix = "boss_macaque_block_tower_layer",
		from = 22,
		to = 22
	},
	["boss_macaque_block_tower_layer_in"] = {
		prefix = "boss_macaque_block_tower_layer",
		from = 1,
		to = 21
	},
	["boss_macaque_block_tower_layer_out"] = {
		prefix = "boss_macaque_block_tower_layer",
		from = 23,
		to = 43
	},
	["boss_macaque_idleIn"] = {
		prefix = "boss_macaque",
		from = 1,
		to = 42
	},
	["boss_macaque_idleLoop"] = {
		prefix = "boss_macaque",
		from = 43,
		to = 46
	},
	["boss_macaque_idleOut"] = {
		prefix = "boss_macaque",
		from = 169,
		to = 184
	},
	["boss_macaque_ship_layer_death"] = {
		prefix = "boss_macaque_ship_layer",
		from = 33,
		to = 72
	},
	["boss_macaque_ship_layer_taunt"] = {
		prefix = "boss_macaque_ship_layer",
		from = 73,
		to = 80
	},
	["boss_macaque_ship_layer_walk"] = {
		prefix = "boss_macaque_ship_layer",
		from = 1,
		to = 32
	},
	["boss_macaque_taunt"] = {
		prefix = "boss_macaque",
		from = 47,
		to = 62
	},
	["boss_macaque_unit_layer_attack"] = {
		prefix = "boss_macaque_unit_layer",
		from = 78,
		to = 136
	},
	["boss_macaque_unit_layer_cannon"] = {
		prefix = "boss_macaque_unit_layer",
		from = 137,
		to = 194
	},
	["boss_macaque_unit_layer_idle"] = {
		prefix = "boss_macaque_unit_layer",
		from = 1,
		to = 28
	},
	["boss_macaque_unit_layer_summon"] = {
		prefix = "boss_macaque_unit_layer",
		from = 29,
		to = 77
	},
	["bruiser_attack"] = {
		prefix = "bruiser",
		from = 62,
		to = 79
	},
	["bruiser_death"] = {
		prefix = "bruiser",
		from = 80,
		to = 93
	},
	["bruiser_idle"] = {
		prefix = "bruiser",
		from = 1,
		to = 1
	},
	["bruiser_walk"] = {
		prefix = "bruiser",
		from = 2,
		to = 21
	},
	["bruiser_walkDown"] = {
		prefix = "bruiser",
		from = 22,
		to = 41
	},
	["bruiser_walkUp"] = {
		prefix = "bruiser",
		from = 42,
		to = 61
	},
	["bubble_run"] = {
		prefix = "Stage5_bubbles",
		from = 1,
		to = 35
	},
	["bullywag_bubble_crystals_blast_run"] = {
		prefix = "bullywag_bubble_crystals_blast",
		from = 1,
		to = 49
	},
	["bullywag_bubble_crystals_cooldown"] = {
		prefix = "bullywag_bubble_crystals_layer",
		from = 1,
		to = 40
	},
	["bullywag_bubble_crystals_ready"] = {
		prefix = "bullywag_bubble_crystals_layer",
		from = 41,
		to = 58
	},
	["bullywag_bubble_crystals_shield_modifier_run"] = {
		prefix = "bullywag_bubble_crystals_shield_modifier",
		from = 1,
		to = 18
	},
	["bullywag_bubble_crystals_shoot"] = {
		prefix = "bullywag_bubble_crystals_layer",
		from = 59,
		to = 99
	},
	["bullywag_spawner_active"] = {
		prefix = "bullywag_spawner_layer",
		from = 21,
		to = 50
	},
	["bullywag_spawner_idle"] = {
		prefix = "bullywag_spawner_layer",
		from = 1,
		to = 20
	},
	["bullywag_spawner_splash_run"] = {
		prefix = "bullywag_spawner_splash",
		from = 1,
		to = 20
	},
	["camel_rider_attack"] = {
		prefix = "camel_rider",
		from = 44,
		to = 72
	},
	["camel_rider_death"] = {
		prefix = "camel_rider",
		from = 73,
		to = 96
	},
	["camel_rider_idle"] = {
		prefix = "camel_rider",
		from = 1,
		to = 1
	},
	["camel_rider_walk"] = {
		prefix = "camel_rider",
		from = 2,
		to = 15
	},
	["camel_rider_walkDown"] = {
		prefix = "camel_rider",
		from = 16,
		to = 29
	},
	["camel_rider_walkUp"] = {
		prefix = "camel_rider",
		from = 30,
		to = 43
	},
	["cannon_sign_run"] = {
		prefix = "cannonsign",
		from = 1,
		to = 27
	},
	["caravan_thief_call"] = {
		prefix = "caravan_thief",
		from = 2,
		to = 35
	},
	["caravan_thief_idle"] = {
		prefix = "caravan_thief",
		from = 1,
		to = 1
	},
	["caravan_thief_throwCoin"] = {
		prefix = "caravan_thief",
		from = 36,
		to = 76
	},
	["carnival_dragon_body_death"] = {
		prefix = "carnival_dragon_body",
		from = 97,
		to = 120
	},
	["carnival_dragon_body_idle"] = {
		prefix = "carnival_dragon_body",
		from = 1,
		to = 1
	},
	["carnival_dragon_body_walk"] = {
		prefix = "carnival_dragon_body",
		from = 1,
		to = 32
	},
	["carnival_dragon_body_walkDown"] = {
		prefix = "carnival_dragon_body",
		from = 33,
		to = 64
	},
	["carnival_dragon_body_walkUp"] = {
		prefix = "carnival_dragon_body",
		from = 65,
		to = 96
	},
	["carnival_dragon_head_death"] = {
		prefix = "carnival_dragon_head",
		from = 97,
		to = 141
	},
	["carnival_dragon_head_idle"] = {
		prefix = "carnival_dragon_head",
		from = 1,
		to = 1
	},
	["carnival_dragon_head_walk"] = {
		prefix = "carnival_dragon_head",
		from = 1,
		to = 32
	},
	["carnival_dragon_head_walkDown"] = {
		prefix = "carnival_dragon_head",
		from = 33,
		to = 64
	},
	["carnival_dragon_head_walkUp"] = {
		prefix = "carnival_dragon_head",
		from = 65,
		to = 96
	},
	["cart_explotion"] = {
		prefix = "cart_explotion_touch",
		from = 5,
		to = 17
	},
	["cart_explotionDecal"] = {
		prefix = "cart_explotion_decal",
		from = 1,
		to = 34
	},
	["cart_layer_downBruiser2"] = {
		prefix = "cart_layer1",
		from = 58,
		to = 76
	},
	["cart_layer_downBruiser2Warhammer1"] = {
		prefix = "cart_layer1",
		from = 115,
		to = 133
	},
	["cart_layer_downDK"] = {
		prefix = "cart_layer1",
		from = 229,
		to = 247
	},
	["cart_layer_downIJ"] = {
		prefix = "cart_layer1",
		from = 286,
		to = 304
	},
	["cart_layer_downKremling"] = {
		prefix = "cart_layer1",
		from = 343,
		to = 361
	},
	["cart_layer_downWarhammer2"] = {
		prefix = "cart_layer1",
		from = 172,
		to = 190
	},
	["cart_layer_downWarhammer3"] = {
		prefix = "cart_layer1",
		from = 1,
		to = 19
	},
	["cart_layer_fallBruiser2"] = {
		prefix = "cart_explotion_layer1",
		from = 35,
		to = 68
	},
	["cart_layer_fallBruiser2Warhammer1"] = {
		prefix = "cart_explotion_layer1",
		from = 69,
		to = 102
	},
	["cart_layer_fallWarhammer2"] = {
		prefix = "cart_explotion_layer1",
		from = 103,
		to = 136
	},
	["cart_layer_fallWarhammer3"] = {
		prefix = "cart_explotion_layer1",
		from = 1,
		to = 34
	},
	["cart_layer_sideBruiser2"] = {
		prefix = "cart_layer1",
		from = 77,
		to = 95
	},
	["cart_layer_sideBruiser2Warhammer1"] = {
		prefix = "cart_layer1",
		from = 134,
		to = 152
	},
	["cart_layer_sideDK"] = {
		prefix = "cart_layer1",
		from = 248,
		to = 266
	},
	["cart_layer_sideIJ"] = {
		prefix = "cart_layer1",
		from = 305,
		to = 323
	},
	["cart_layer_sideKremling"] = {
		prefix = "cart_layer1",
		from = 362,
		to = 380
	},
	["cart_layer_sideWarhammer2"] = {
		prefix = "cart_layer1",
		from = 191,
		to = 209
	},
	["cart_layer_sideWarhammer3"] = {
		prefix = "cart_layer1",
		from = 20,
		to = 38
	},
	["cart_layer_upBruiser2"] = {
		prefix = "cart_layer1",
		from = 96,
		to = 114
	},
	["cart_layer_upBruiser2Warhammer1"] = {
		prefix = "cart_layer1",
		from = 153,
		to = 171
	},
	["cart_layer_upDK"] = {
		prefix = "cart_layer1",
		from = 267,
		to = 285
	},
	["cart_layer_upIJ"] = {
		prefix = "cart_layer1",
		from = 324,
		to = 342
	},
	["cart_layer_upKremling"] = {
		prefix = "cart_layer1",
		from = 381,
		to = 399
	},
	["cart_layer_upWarhammer2"] = {
		prefix = "cart_layer1",
		from = 210,
		to = 228
	},
	["cart_layer_upWarhammer3"] = {
		prefix = "cart_layer1",
		from = 39,
		to = 57
	},
	["cart_layerX_downWarhammer3"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 1,
		to = 19
	},
	["cart_layerX_sideWarhammer3"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 20,
		to = 38
	},
	["cart_layerX_upWarhammer3"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 39,
		to = 57
	},
	["cart_layerX_downBruiser2"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 58,
		to = 76
	},
	["cart_layerX_sideBruiser2"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 77,
		to = 95
	},
	["cart_layerX_upBruiser2"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 96,
		to = 114
	},
	["cart_layerX_downBruiser2Warhammer1"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 115,
		to = 133
	},
	["cart_layerX_sideBruiser2Warhammer1"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 134,
		to = 152
	},
	["cart_layerX_upBruiser2Warhammer1"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 153,
		to = 171
	},
	["cart_layerX_downWarhammer2"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 172,
		to = 190
	},
	["cart_layerX_sideWarhammer2"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 191,
		to = 209
	},
	["cart_layerX_upWarhammer2"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 210,
		to = 228
	},
	["cart_layerX_downDK"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 229,
		to = 247
	},
	["cart_layerX_sideDK"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 248,
		to = 266
	},
	["cart_layerX_upDK"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 267,
		to = 285
	},
	["cart_layerX_downIJ"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 286,
		to = 304
	},
	["cart_layerX_sideIJ"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 305,
		to = 323
	},
	["cart_layerX_upIJ"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 324,
		to = 342
	},
	["cart_layerX_downKremling"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 343,
		to = 361
	},
	["cart_layerX_sideKremling"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 362,
		to = 380
	},
	["cart_layerX_upKremling"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_layer%i",
		from = 381,
		to = 399
	},
	["cart_layerX_fallWarhammer3"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_explotion_layer%i",
		from = 1,
		to = 34
	},
	["cart_layerX_fallBruiser2"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_explotion_layer%i",
		from = 35,
		to = 68
	},
	["cart_layerX_fallBruiser2Warhammer1"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_explotion_layer%i",
		from = 69,
		to = 102
	},
	["cart_layerX_fallWarhammer2"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "cart_explotion_layer%i",
		from = 103,
		to = 136
	},
	["cascade_run"] = {
		prefix = "cascade",
		from = 1,
		to = 15
	},
	["cascade_water_flow_run"] = {
		prefix = "cascade_water_flow",
		from = 1,
		to = 21
	},
	["chompbot_attack"] = {
		prefix = "chompbot",
		from = 66,
		to = 85
	},
	["chompbot_death"] = {
		prefix = "chompbot",
		from = 120,
		to = 142
	},
	["chompbot_idle"] = {
		prefix = "chompbot",
		from = 1,
		to = 1
	},
	["chompbot_overheatLoop"] = {
		prefix = "chompbot",
		from = 96,
		to = 119
	},
	["chompbot_overheatStart"] = {
		prefix = "chompbot",
		from = 86,
		to = 95
	},
	["chompbot_walk"] = {
		prefix = "chompbot",
		from = 2,
		to = 21
	},
	["chompbot_walkDown"] = {
		prefix = "chompbot",
		from = 44,
		to = 65
	},
	["chompbot_walkUp"] = {
		prefix = "chompbot",
		from = 22,
		to = 43
	},
	["citizen_merchant_death"] = {
		prefix = "citizen_merchant",
		from = 113,
		to = 136
	},
	["citizen_merchant_idle"] = {
		prefix = "citizen_merchant",
		from = 1,
		to = 1
	},
	["citizen_merchant_melee"] = {
		prefix = "citizen_merchant",
		from = 85,
		to = 112
	},
	["citizen_merchant_proyectile_smoke_run"] = {
		prefix = "citizen_merchant_proyectile_smoke",
		from = 1,
		to = 15
	},
	["citizen_merchant_range"] = {
		prefix = "citizen_merchant",
		from = 62,
		to = 84
	},
	["citizen_merchant_walk"] = {
		prefix = "citizen_merchant",
		from = 2,
		to = 21
	},
	["citizen_merchant_walkDown"] = {
		prefix = "citizen_merchant",
		from = 22,
		to = 41
	},
	["citizen_merchant_walkUp"] = {
		prefix = "citizen_merchant",
		from = 42,
		to = 61
	},
	["citizen_rugmerchant_attack"] = {
		prefix = "citizen_rugmerchant",
		from = 62,
		to = 84
	},
	["citizen_rugmerchant_death"] = {
		prefix = "citizen_rugmerchant",
		from = 85,
		to = 102
	},
	["citizen_rugmerchant_idle"] = {
		prefix = "citizen_rugmerchant",
		from = 1,
		to = 1
	},
	["citizen_rugmerchant_walk"] = {
		prefix = "citizen_rugmerchant",
		from = 2,
		to = 21
	},
	["citizen_rugmerchant_walkDown"] = {
		prefix = "citizen_rugmerchant",
		from = 22,
		to = 41
	},
	["citizen_rugmerchant_walkUp"] = {
		prefix = "citizen_rugmerchant",
		from = 42,
		to = 61
	},
	["citizen_snakecharmer_attack"] = {
		prefix = "citizen_snakecharmer",
		from = 62,
		to = 112
	},
	["citizen_snakecharmer_death"] = {
		prefix = "citizen_snakecharmer",
		from = 113,
		to = 130
	},
	["citizen_snakecharmer_idle"] = {
		prefix = "citizen_snakecharmer",
		from = 1,
		to = 1
	},
	["citizen_snakecharmer_walk"] = {
		prefix = "citizen_snakecharmer",
		from = 2,
		to = 21
	},
	["citizen_snakecharmer_walkDown"] = {
		prefix = "citizen_snakecharmer",
		from = 22,
		to = 41
	},
	["citizen_snakecharmer_walkUp"] = {
		prefix = "citizen_snakecharmer",
		from = 42,
		to = 61
	},
	["clockwork_spider_attack"] = {
		prefix = "clockwork_spider",
		from = 29,
		to = 47
	},
	["clockwork_spider_death"] = {
		prefix = "clockwork_spider",
		from = 48,
		to = 65
	},
	["clockwork_spider_idle"] = {
		prefix = "clockwork_spider",
		from = 1,
		to = 1
	},
	["clockwork_spider_walk"] = {
		prefix = "clockwork_spider",
		from = 2,
		to = 10
	},
	["clockwork_spider_walkDown"] = {
		prefix = "clockwork_spider",
		from = 11,
		to = 19
	},
	["clockwork_spider_walkUp"] = {
		prefix = "clockwork_spider",
		from = 20,
		to = 28
	},
	["corrosive_soul_attack"] = {
		prefix = "corrosive_soul",
		from = 56,
		to = 84
	},
	["corrosive_soul_death"] = {
		prefix = "corrosive_soul",
		from = 85,
		to = 119
	},
	["corrosive_soul_fx_run"] = {
		prefix = "corrosive_soul_fx",
		from = 1,
		to = 14
	},
	["corrosive_soul_idle"] = {
		prefix = "corrosive_soul",
		from = 1,
		to = 1
	},
	["corrosive_soul_walk"] = {
		prefix = "corrosive_soul",
		from = 2,
		to = 19
	},
	["corrosive_soul_walkDown"] = {
		prefix = "corrosive_soul",
		from = 20,
		to = 37
	},
	["corrosive_soul_walkUp"] = {
		prefix = "corrosive_soul",
		from = 38,
		to = 55
	},
	["coyote_achievement_coyote_layer_idle"] = {
		prefix = "coyote_achievement_coyote_layer",
		from = 1,
		to = 94
	},
	["coyote_achievement_coyote_layer_special"] = {
		prefix = "coyote_achievement_coyote_layer",
		from = 95,
		to = 242
	},
	["croud_HM_down_run"] = {
		prefix = "croud_HM_down",
		from = 1,
		to = 11
	},
	["croud_HM_left_run"] = {
		prefix = "croud_HM_left",
		from = 1,
		to = 11
	},
	["croud_HM_right_run"] = {
		prefix = "croud_HM_right",
		from = 1,
		to = 11
	},
	["croud_confetti_hm_run"] = {
		prefix = "croud_confetti_hm",
		from = 1,
		to = 35
	},
	["croud_confetti_vez_run"] = {
		prefix = "croud_confetti_vez",
		from = 1,
		to = 35
	},
	["croud_vez_down_run"] = {
		prefix = "croud_vez_down",
		from = 1,
		to = 11
	},
	["croud_vez_left_run"] = {
		prefix = "croud_vez_left",
		from = 1,
		to = 12
	},
	["croud_vez_right_run"] = {
		prefix = "croud_vez_right",
		from = 1,
		to = 12
	},
	["dafpunk_goblins_run"] = {
		prefix = "dafpunk_goblins_layer",
		from = 1,
		to = 15
	},
	["decal_run"] = {
		prefix = "sulfur_alchemist_poison_explotion_decal",
		from = 1,
		to = 1
	},
	["demon_dust_run"] = {
		prefix = "demon_dust",
		from = 1,
		to = 11
	},
	["demon_hit_door_run"] = {
		prefix = "demon_hit_door",
		from = 1,
		to = 15
	},
	["demon_hit_explotion_run"] = {
		prefix = "demon_hit_explotion",
		from = 1,
		to = 22
	},
	["demon_hit_light_run"] = {
		prefix = "demon_hit_light",
		from = 1,
		to = 17
	},
	["demon_hit_run"] = {
		prefix = "demon_hit",
		from = 1,
		to = 8
	},
	["demon_progress_bar_icon_demon_face1"] = {
		prefix = "demon_progress_bar_icon_demon",
		from = 2,
		to = 9
	},
	["demon_progress_bar_icon_demon_face2"] = {
		prefix = "demon_progress_bar_icon_demon",
		from = 10,
		to = 17
	},
	["demon_progress_bar_icon_demon_face3"] = {
		prefix = "demon_progress_bar_icon_demon",
		from = 18,
		to = 25
	},
	["demon_progress_bar_icon_demon_idle"] = {
		prefix = "demon_progress_bar_icon_demon",
		from = 1,
		to = 1
	},
	["denas_drink"] = {
		prefix = "denas",
		from = 23,
		to = 69
	},
	["denas_idle"] = {
		prefix = "denas",
		from = 1,
		to = 1
	},
	["denas_taunt"] = {
		prefix = "denas",
		from = 9,
		to = 22
	},
	["denas_walk"] = {
		prefix = "denas",
		from = 2,
		to = 8
	},
	["desert_eagle_attack"] = {
		prefix = "desert_eagle",
		from = 43,
		to = 52
	},
	["desert_eagle_death"] = {
		prefix = "desert_eagle",
		from = 53,
		to = 64
	},
	["desert_eagle_idle"] = {
		prefix = "desert_eagle",
		from = 1,
		to = 14
	},
	["desert_eagle_walk"] = {
		prefix = "desert_eagle",
		from = 1,
		to = 14
	},
	["desert_eagle_walkDown"] = {
		prefix = "desert_eagle",
		from = 29,
		to = 42
	},
	["desert_eagle_walkUp"] = {
		prefix = "desert_eagle",
		from = 15,
		to = 28
	},
	["desert_sheep_eat"] = {
		prefix = "desert_sheep",
		from = 14,
		to = 60
	},
	["desert_sheep_idle"] = {
		prefix = "desert_sheep",
		from = 1,
		to = 1
	},
	["desert_sheep_walk"] = {
		prefix = "desert_sheep",
		from = 2,
		to = 13
	},
	["devoted_priest_attack"] = {
		prefix = "devoted_priest",
		from = 62,
		to = 83
	},
	["devoted_priest_cast"] = {
		prefix = "devoted_priest",
		from = 84,
		to = 142
	},
	["devoted_priest_death"] = {
		prefix = "devoted_priest",
		from = 143,
		to = 188
	},
	["devoted_priest_healing_run"] = {
		prefix = "devoted_priest_healing",
		from = 1,
		to = 25
	},
	["devoted_priest_idle"] = {
		prefix = "devoted_priest",
		from = 1,
		to = 1
	},
	["devoted_priest_modifier_armor_run"] = {
		prefix = "devoted_priest_modifier_armor",
		from = 1,
		to = 23
	},
	["devoted_priest_modifier_decal_run"] = {
		prefix = "devoted_priest_modifier_decal",
		from = 1,
		to = 24
	},
	["devoted_priest_walk"] = {
		prefix = "devoted_priest",
		from = 2,
		to = 21
	},
	["devoted_priest_walkDown"] = {
		prefix = "devoted_priest",
		from = 22,
		to = 41
	},
	["devoted_priest_walkUp"] = {
		prefix = "devoted_priest",
		from = 42,
		to = 61
	},
	["djini_death"] = {
		prefix = "djini",
		from = 162,
		to = 192
	},
	["djini_idle"] = {
		prefix = "djini",
		from = 2,
		to = 26
	},
	["djini_lamp_smoke_run"] = {
		prefix = "genie_smoke",
		from = 1,
		to = 29
	},
	["djini_lamp_spawn_run"] = {
		prefix = "djini_lamp_spawn",
		from = 1,
		to = 84
	},
	["djini_polimorph"] = {
		prefix = "djini",
		from = 78,
		to = 118
	},
	["djini_politower"] = {
		prefix = "djini",
		from = 119,
		to = 161
	},
	["djini_polymorph_unit_effect_run"] = {
		prefix = "djini_polymorph_unit_effect",
		from = 1,
		to = 21
	},
	["djini_sand_tower_end"] = {
		prefix = "djini_sand_tower",
		from = 22,
		to = 43
	},
	["djini_sand_tower_loop"] = {
		prefix = "djini_sand_tower",
		from = 22,
		to = 22
	},
	["djini_sand_tower_start"] = {
		prefix = "djini_sand_tower",
		from = 1,
		to = 21
	},
	["djini_spawn"] = {
		prefix = "djini",
		from = 193,
		to = 214
	},
	["djini_walk"] = {
		prefix = "djini",
		from = 2,
		to = 26
	},
	["djini_walkDown"] = {
		prefix = "djini",
		from = 27,
		to = 52
	},
	["djini_walkUp"] = {
		prefix = "djini",
		from = 53,
		to = 77
	},
	["dragon_camouflage_grietas_run"] = {
		prefix = "dragon_camouflage_grietas",
		from = 1,
		to = 13
	},
	["dragon_camouflage_iceshards_run"] = {
		prefix = "dragon_camouflage_iceshards",
		from = 1,
		to = 19
	},
	["dragon_king_boss_attack"] = {
		prefix = "dragon_king_boss_layer",
		from = 54,
		to = 83
	},
	["dragon_king_boss_body_death"] = {
		prefix = "dragon_king_boss_body_layer",
		from = 95,
		to = 120
	},
	["dragon_king_boss_body_idle"] = {
		prefix = "dragon_king_boss_body_layer",
		from = 1,
		to = 6
	},
	["dragon_king_boss_body_inHead"] = {
		prefix = "dragon_king_boss_body_layer",
		from = 66,
		to = 94
	},
	["dragon_king_boss_body_inSlide"] = {
		prefix = "dragon_king_boss_body_layer",
		from = 52,
		to = 65
	},
	["dragon_king_boss_body_outTail"] = {
		prefix = "dragon_king_boss_body_layer",
		from = 7,
		to = 51
	},
	["dragon_king_boss_death"] = {
		prefix = "dragon_king_boss_layer",
		from = 118,
		to = 190
	},
	["dragon_king_boss_death_water_fx_run"] = {
		prefix = "dragon_king_boss_death_water_fx",
		from = 1,
		to = 18
	},
	["dragon_king_boss_idle"] = {
		prefix = "dragon_king_boss_layer",
		from = 1,
		to = 44
	},
	["dragon_king_boss_in"] = {
		prefix = "dragon_king_boss_layer",
		from = 84,
		to = 100
	},
	["dragon_king_boss_out"] = {
		prefix = "dragon_king_boss_layer",
		from = 101,
		to = 117
	},
	["dragon_king_boss_particle_run"] = {
		prefix = "dragon_king_boss_particle",
		from = 1,
		to = 12
	},
	["dragon_king_boss_talkLoop"] = {
		prefix = "dragon_king_boss_layer",
		from = 45,
		to = 53
	},
	["draugr_attack"] = {
		prefix = "draugr",
		from = 52,
		to = 73
	},
	["draugr_death"] = {
		prefix = "draugr",
		from = 104,
		to = 135
	},
	["draugr_idle"] = {
		prefix = "draugr",
		from = 1,
		to = 1
	},
	["draugr_respawn"] = {
		prefix = "draugr",
		from = 74,
		to = 103
	},
	["draugr_walk"] = {
		prefix = "draugr",
		from = 2,
		to = 11
	},
	["draugr_walkDown"] = {
		prefix = "draugr",
		from = 32,
		to = 51
	},
	["draugr_walkUp"] = {
		prefix = "draugr",
		from = 12,
		to = 31
	},
	["dwarf_boss_goblin_deco_anim1"] = {
		prefix = "dwarf_boss_goblin_deco_layer",
		from = 2,
		to = 32
	},
	["dwarf_boss_goblin_deco_anim2"] = {
		prefix = "dwarf_boss_goblin_deco_layer",
		from = 33,
		to = 71
	},
	["dwarf_boss_goblin_deco_idle"] = {
		prefix = "dwarf_boss_goblin_deco_layer",
		from = 1,
		to = 1
	},
	["dwarf_boss_goblin_deco_run"] = {
		prefix = "dwarf_boss_goblin_deco_layer",
		from = 72,
		to = 223
	},
	["dwarf_flyer_death"] = {
		prefix = "dwarf_flyer",
		from = 75,
		to = 95
	},
	["dwarf_flyer_idle"] = {
		prefix = "dwarf_flyer",
		from = 2,
		to = 25
	},
	["dwarf_flyer_walk"] = {
		prefix = "dwarf_flyer",
		from = 2,
		to = 25
	},
	["dwarf_flyer_walkDown"] = {
		prefix = "dwarf_flyer",
		from = 26,
		to = 50
	},
	["dwarf_flyer_walkUp"] = {
		prefix = "dwarf_flyer",
		from = 51,
		to = 74
	},
	["elven_warrior_arrow_decal_idle"] = {
		prefix = "elven_warrior_arrow_decal",
		from = 9,
		to = 9
	},
	["elven_warrior_arrow_decal_run"] = {
		prefix = "elven_warrior_arrow_decal",
		from = 1,
		to = 8
	},
	["elven_warrior_death"] = {
		prefix = "elven_warrior",
		from = 150,
		to = 168
	},
	["elven_warrior_hit1"] = {
		prefix = "elven_warrior",
		from = 86,
		to = 117
	},
	["elven_warrior_hit2"] = {
		prefix = "elven_warrior",
		from = 118,
		to = 149
	},
	["elven_warrior_idle"] = {
		prefix = "elven_warrior",
		from = 1,
		to = 18
	},
	["elven_warrior_multiShoot"] = {
		prefix = "elven_warrior",
		from = 56,
		to = 69
	},
	["elven_warrior_shootEnd"] = {
		prefix = "elven_warrior",
		from = 70,
		to = 85
	},
	["elven_warrior_shootIn"] = {
		prefix = "elven_warrior",
		from = 37,
		to = 50
	},
	["elven_warrior_shootPrep"] = {
		prefix = "elven_warrior",
		from = 51,
		to = 55
	},
	["elven_warrior_spawn"] = {
		prefix = "elven_warrior",
		from = 169,
		to = 201
	},
	["elven_warrior_walk"] = {
		prefix = "elven_warrior",
		from = 19,
		to = 36
	},
	["elven_warrior_walkDown"] = {
		prefix = "elven_warrior",
		from = 202,
		to = 223
	},
	["elven_warrior_walkUp"] = {
		prefix = "elven_warrior",
		from = 224,
		to = 245
	},
	["falconeer_aloneAttack"] = {
		prefix = "falconeer",
		from = 138,
		to = 156
	},
	["falconeer_aloneDeath"] = {
		prefix = "falconeer",
		from = 157,
		to = 191
	},
	["falconeer_aloneIdle"] = {
		prefix = "falconeer",
		from = 87,
		to = 87
	},
	["falconeer_aloneWalk"] = {
		prefix = "falconeer",
		from = 88,
		to = 103
	},
	["falconeer_aloneWalkDown"] = {
		prefix = "falconeer",
		from = 104,
		to = 120
	},
	["falconeer_aloneWalkUp"] = {
		prefix = "falconeer",
		from = 121,
		to = 137
	},
	["falconeer_death"] = {
		prefix = "falconeer",
		from = 192,
		to = 224
	},
	["falconeer_idle"] = {
		prefix = "falconeer",
		from = 1,
		to = 1
	},
	["falconeer_spawnEagle"] = {
		prefix = "falconeer",
		from = 52,
		to = 86
	},
	["falconeer_walk"] = {
		prefix = "falconeer",
		from = 2,
		to = 17
	},
	["falconeer_walkDown"] = {
		prefix = "falconeer",
		from = 18,
		to = 34
	},
	["falconeer_walkUp"] = {
		prefix = "falconeer",
		from = 35,
		to = 51
	},
	["farmer_attack"] = {
		prefix = "linirea_farmer",
		from = 62,
		to = 80
	},
	["farmer_bucket_attack"] = {
		prefix = "farmer_bucket",
		from = 62,
		to = 77
	},
	["farmer_bucket_death"] = {
		prefix = "farmer_bucket",
		from = 78,
		to = 95
	},
	["farmer_bucket_idle"] = {
		prefix = "farmer_bucket",
		from = 1,
		to = 1
	},
	["farmer_bucket_walk"] = {
		prefix = "farmer_bucket",
		from = 2,
		to = 21
	},
	["farmer_bucket_walkDown"] = {
		prefix = "farmer_bucket",
		from = 22,
		to = 41
	},
	["farmer_bucket_walkUp"] = {
		prefix = "farmer_bucket",
		from = 42,
		to = 61
	},
	["farmer_death"] = {
		prefix = "linirea_farmer",
		from = 81,
		to = 98
	},
	["farmer_idle"] = {
		prefix = "linirea_farmer",
		from = 1,
		to = 1
	},
	["farmer_mile_attack"] = {
		prefix = "farmer_mile",
		from = 74,
		to = 109
	},
	["farmer_mile_attack2"] = {
		prefix = "farmer_mile",
		from = 110,
		to = 144
	},
	["farmer_mile_death"] = {
		prefix = "farmer_mile",
		from = 145,
		to = 172
	},
	["farmer_mile_idle"] = {
		prefix = "farmer_mile",
		from = 1,
		to = 1
	},
	["farmer_mile_walk"] = {
		prefix = "farmer_mile",
		from = 2,
		to = 25
	},
	["farmer_mile_walkDown"] = {
		prefix = "farmer_mile",
		from = 26,
		to = 49
	},
	["farmer_mile_walkUp"] = {
		prefix = "farmer_mile",
		from = 50,
		to = 73
	},
	["farmer_rake_attack"] = {
		prefix = "farmer_rake",
		from = 62,
		to = 82
	},
	["farmer_rake_death"] = {
		prefix = "farmer_rake",
		from = 83,
		to = 100
	},
	["farmer_rake_idle"] = {
		prefix = "farmer_rake",
		from = 1,
		to = 1
	},
	["farmer_rake_walk"] = {
		prefix = "farmer_rake",
		from = 2,
		to = 21
	},
	["farmer_rake_walkDown"] = {
		prefix = "farmer_rake",
		from = 22,
		to = 41
	},
	["farmer_rake_walkUp"] = {
		prefix = "farmer_rake",
		from = 42,
		to = 61
	},
	["farmer_rooster_death"] = {
		prefix = "farmer_rooster",
		from = 129,
		to = 150
	},
	["farmer_rooster_explosion_run"] = {
		prefix = "farmer_rooster_explosion",
		from = 1,
		to = 20
	},
	["farmer_rooster_idle"] = {
		prefix = "farmer_rooster",
		from = 1,
		to = 1
	},
	["farmer_rooster_idleBlock"] = {
		prefix = "farmer_rooster",
		from = 119,
		to = 119
	},
	["farmer_rooster_melee"] = {
		prefix = "farmer_rooster",
		from = 98,
		to = 118
	},
	["farmer_rooster_meleeIn"] = {
		prefix = "farmer_rooster",
		from = 84,
		to = 97
	},
	["farmer_rooster_meleeOut"] = {
		prefix = "farmer_rooster",
		from = 120,
		to = 128
	},
	["farmer_rooster_particle_run"] = {
		prefix = "farmer_rooster_particle",
		from = 1,
		to = 19
	},
	["farmer_rooster_proyectile_travel"] = {
		prefix = "farmer_rooster_proyectile",
		from = 1,
		to = 4
	},
	["farmer_rooster_range"] = {
		prefix = "farmer_rooster",
		from = 62,
		to = 83
	},
	["farmer_rooster_walk"] = {
		prefix = "farmer_rooster",
		from = 2,
		to = 21
	},
	["farmer_rooster_walkDown"] = {
		prefix = "farmer_rooster",
		from = 22,
		to = 41
	},
	["farmer_rooster_walkUp"] = {
		prefix = "farmer_rooster",
		from = 42,
		to = 61
	},
	["farmer_scythe_attack"] = {
		prefix = "farmer_scythe",
		from = 62,
		to = 79
	},
	["farmer_scythe_death"] = {
		prefix = "farmer_scythe",
		from = 80,
		to = 97
	},
	["farmer_scythe_idle"] = {
		prefix = "farmer_scythe",
		from = 1,
		to = 1
	},
	["farmer_scythe_walk"] = {
		prefix = "farmer_scythe",
		from = 2,
		to = 21
	},
	["farmer_scythe_walkDown"] = {
		prefix = "farmer_scythe",
		from = 22,
		to = 41
	},
	["farmer_scythe_walkUp"] = {
		prefix = "farmer_scythe",
		from = 42,
		to = 61
	},
	["farmer_walk"] = {
		prefix = "linirea_farmer",
		from = 2,
		to = 21
	},
	["farmer_walkDown"] = {
		prefix = "linirea_farmer",
		from = 22,
		to = 41
	},
	["farmer_walkUp"] = {
		prefix = "linirea_farmer",
		from = 42,
		to = 61
	},
	["fire_off"] = {
		prefix = "FireOff",
		from = 1,
		to = 32
	},
	["fire_run"] = {
		prefix = "Stage_1_fire",
		from = 1,
		to = 12
	},
	["frost_giant_attack"] = {
		prefix = "frost_giant",
		from = 80,
		to = 111
	},
	["frost_giant_death"] = {
		prefix = "frost_giant",
		from = 112,
		to = 183
	},
	["frost_giant_hit_run"] = {
		prefix = "frost_giant_hit",
		from = 1,
		to = 26
	},
	["frost_giant_idle"] = {
		prefix = "frost_giant",
		from = 1,
		to = 1
	},
	["frost_giant_walk"] = {
		prefix = "frost_giant",
		from = 2,
		to = 27
	},
	["frost_giant_walkDown"] = {
		prefix = "frost_giant",
		from = 28,
		to = 53
	},
	["frost_giant_walkUp"] = {
		prefix = "frost_giant",
		from = 54,
		to = 79
	},
	["frozen_heart_attack"] = {
		prefix = "frozen_heart",
		from = 104,
		to = 135
	},
	["frozen_heart_death"] = {
		prefix = "frozen_heart",
		from = 136,
		to = 211
	},
	["frozen_heart_fx_run"] = {
		prefix = "frozen_heart_fx",
		from = 1,
		to = 23
	},
	["frozen_heart_idle"] = {
		prefix = "frozen_heart",
		from = 1,
		to = 1
	},
	["frozen_heart_spawn"] = {
		prefix = "frozen_heart",
		from = 212,
		to = 223
	},
	["frozen_heart_walk"] = {
		prefix = "frozen_heart",
		from = 2,
		to = 35
	},
	["frozen_heart_walkDown"] = {
		prefix = "frozen_heart",
		from = 36,
		to = 69
	},
	["frozen_heart_walkUp"] = {
		prefix = "frozen_heart",
		from = 70,
		to = 103
	},
	["frozen_soul_death"] = {
		prefix = "frozen_soul",
		from = 16,
		to = 52
	},
	["frozen_soul_idle"] = {
		prefix = "frozen_soul",
		from = 1,
		to = 1
	},
	["frozen_soul_respawn"] = {
		prefix = "frozen_soul",
		from = 53,
		to = 129
	},
	["frozen_soul_walk"] = {
		prefix = "frozen_soul",
		from = 2,
		to = 15
	},
	["garfio_layer_idle"] = {
		prefix = "garfio_layer",
		from = 1,
		to = 40
	},
	["garfio_layer_tap_One"] = {
		prefix = "garfio_layer",
		from = 41,
		to = 80
	},
	["garfio_layer_tap_Two"] = {
		prefix = "garfio_layer",
		from = 81,
		to = 122
	},
	["garfio_layer_tap_three"] = {
		prefix = "garfio_layer",
		from = 123,
		to = 192
	},
	["ghost_death"] = {
		prefix = "ghost",
		from = 91,
		to = 118
	},
	["ghost_idle"] = {
		prefix = "ghost",
		from = 1,
		to = 1
	},
	["ghost_walk"] = {
		prefix = "ghost",
		from = 1,
		to = 30
	},
	["ghost_walkDown"] = {
		prefix = "ghost",
		from = 61,
		to = 90
	},
	["ghost_walkUp"] = {
		prefix = "ghost",
		from = 31,
		to = 60
	},
	["glacial_wolf_attack"] = {
		prefix = "glacial_wolf",
		from = 56,
		to = 76
	},
	["glacial_wolf_death"] = {
		prefix = "glacial_wolf",
		from = 77,
		to = 102
	},
	["glacial_wolf_ice_run"] = {
		prefix = "glacial_wolf_ice",
		from = 1,
		to = 23
	},
	["glacial_wolf_idle"] = {
		prefix = "glacial_wolf",
		from = 1,
		to = 1
	},
	["glacial_wolf_walk"] = {
		prefix = "glacial_wolf",
		from = 2,
		to = 19
	},
	["glacial_wolf_walkDown"] = {
		prefix = "glacial_wolf",
		from = 20,
		to = 37
	},
	["glacial_wolf_walkUp"] = {
		prefix = "glacial_wolf",
		from = 38,
		to = 55
	},
	["golem_house_attack"] = {
		prefix = "golem_house",
		from = 92,
		to = 137
	},
	["golem_house_death"] = {
		prefix = "golem_house",
		from = 138,
		to = 167
	},
	["golem_house_fx_run"] = {
		prefix = "golem_house_fx",
		from = 1,
		to = 18
	},
	["golem_house_idle"] = {
		prefix = "golem_house",
		from = 55,
		to = 55
	},
	["golem_house_spawn"] = {
		prefix = "golem_house",
		from = 1,
		to = 54
	},
	["golem_house_walk"] = {
		prefix = "golem_house",
		from = 56,
		to = 91
	},
	["gollum_death"] = {
		prefix = "gollum",
		from = 179,
		to = 222
	},
	["gollum_in"] = {
		prefix = "gollum",
		from = 45,
		to = 48
	},
	["gollum_laugh"] = {
		prefix = "gollum",
		from = 128,
		to = 178
	},
	["gollum_mine"] = {
		prefix = "gollum",
		from = 105,
		to = 127
	},
	["gollum_out"] = {
		prefix = "gollum",
		from = 17,
		to = 44
	},
	["gollum_ring"] = {
		prefix = "gollum",
		from = 1,
		to = 16
	},
	["gollum_take"] = {
		prefix = "gollum",
		from = 49,
		to = 104
	},
	["greensmoke_run"] = {
		prefix = "greensmoke",
		from = 1,
		to = 21
	},
	["greensmoke_trail_run"] = {
		prefix = "smokegreen_trail",
		from = 1,
		to = 8
	},
	["gryphon_death"] = {
		prefix = "gryphon_layer",
		from = 49,
		to = 69
	},
	["gryphon_front_death"] = {
		prefix = "gryphon_front",
		from = 49,
		to = 69
	},
	["gryphon_front_idle"] = {
		prefix = "gryphon_front",
		from = 1,
		to = 16
	},
	["gryphon_front_walk"] = {
		prefix = "gryphon_front",
		from = 1,
		to = 16
	},
	["gryphon_front_walkDown"] = {
		prefix = "gryphon_front",
		from = 17,
		to = 32
	},
	["gryphon_front_walkUp"] = {
		prefix = "gryphon_front",
		from = 33,
		to = 48
	},
	["gryphon_guy_death"] = {
		prefix = "gryphon_guy",
		from = 79,
		to = 79
	},
	["gryphon_guy_idle"] = {
		prefix = "gryphon_guy",
		from = 1,
		to = 1
	},
	["gryphon_guy_shoot"] = {
		prefix = "gryphon_guy",
		from = 2,
		to = 26
	},
	["gryphon_guy_shootDown"] = {
		prefix = "gryphon_guy",
		from = 28,
		to = 52
	},
	["gryphon_guy_shootUp"] = {
		prefix = "gryphon_guy",
		from = 54,
		to = 78
	},
	["gryphon_guy_walk"] = {
		prefix = "gryphon_guy",
		from = 1,
		to = 1
	},
	["gryphon_guy_walkDown"] = {
		prefix = "gryphon_guy",
		from = 27,
		to = 27
	},
	["gryphon_guy_walkUp"] = {
		prefix = "gryphon_guy",
		from = 53,
		to = 53
	},
	["gryphon_idle"] = {
		prefix = "gryphon_layer",
		from = 1,
		to = 16
	},
	["gryphon_walk"] = {
		prefix = "gryphon_layer",
		from = 1,
		to = 16
	},
	["gryphon_walkDown"] = {
		prefix = "gryphon_layer",
		from = 17,
		to = 32
	},
	["gryphon_walkUp"] = {
		prefix = "gryphon_layer",
		from = 33,
		to = 48
	},
	["hammerhold_archer_arrow_travel"] = {
		prefix = "hammerhold_archer_arrow",
		from = 1,
		to = 4
	},
	["hammerhold_archer_tower_idle"] = {
		prefix = "hammerhold_archer_tower",
		from = 1,
		to = 1
	},
	["hammerhold_archer_tower_shooter_idle"] = {
		prefix = "hammerhold_archer_tower_shooter",
		from = 1,
		to = 1
	},
	["hammerhold_archer_tower_shooter_idleUp"] = {
		prefix = "hammerhold_archer_tower_shooter",
		from = 23,
		to = 23
	},
	["hammerhold_archer_tower_shooter_shootDown"] = {
		prefix = "hammerhold_archer_tower_shooter",
		from = 2,
		to = 22
	},
	["hammerhold_archer_tower_shooter_shootUp"] = {
		prefix = "hammerhold_archer_tower_shooter",
		from = 24,
		to = 43
	},
	["hammerhold_roofarcher_idleLeft"] = {
		prefix = "archer_roof_layer",
		from = 81,
		to = 81
	},
	["hammerhold_roofarcher_idleRight"] = {
		prefix = "archer_roof_layer",
		from = 37,
		to = 37
	},
	["hammerhold_roofarcher_idleUp"] = {
		prefix = "archer_roof_layer",
		from = 60,
		to = 60
	},
	["hammerhold_roofarcher_idleUpLeft"] = {
		prefix = "archer_roof_layer",
		from = 103,
		to = 103
	},
	["hammerhold_roofarcher_out"] = {
		prefix = "archer_roof_layer",
		from = 124,
		to = 148
	},
	["hammerhold_roofarcher_shootDownLeft"] = {
		prefix = "archer_roof_layer",
		from = 82,
		to = 102
	},
	["hammerhold_roofarcher_shootDownRight"] = {
		prefix = "archer_roof_layer",
		from = 38,
		to = 59
	},
	["hammerhold_roofarcher_shootUpLeft"] = {
		prefix = "archer_roof_layer",
		from = 104,
		to = 123
	},
	["hammerhold_roofarcher_shootUpRight"] = {
		prefix = "archer_roof_layer",
		from = 61,
		to = 80
	},
	["hammerhold_roofarcher_spawn"] = {
		prefix = "archer_roof_layer",
		from = 1,
		to = 36
	},
	["haunted_skeleton_attack"] = {
		prefix = "haunted_skeleton",
		from = 87,
		to = 108
	},
	["haunted_skeleton_death"] = {
		prefix = "haunted_skeleton",
		from = 109,
		to = 131
	},
	["haunted_skeleton_idle"] = {
		prefix = "haunted_skeleton",
		from = 1,
		to = 14
	},
	["haunted_skeleton_modifier_damage_fx_run"] = {
		prefix = "haunted_skeleton_modifier_damage_fx",
		from = 1,
		to = 24
	},
	["haunted_skeleton_spawn"] = {
		prefix = "haunted_skeleton",
		from = 132,
		to = 157
	},
	["haunted_skeleton_walk"] = {
		prefix = "haunted_skeleton",
		from = 15,
		to = 38
	},
	["haunted_skeleton_walkDown"] = {
		prefix = "haunted_skeleton",
		from = 39,
		to = 62
	},
	["haunted_skeleton_walkUp"] = {
		prefix = "haunted_skeleton",
		from = 63,
		to = 86
	},
	["hero_storm_ray_modifier_run"] = {
		prefix = "hero_storm_ray_modifier",
		from = 1,
		to = 6
	},
	["high_sorcerer_attack"] = {
		prefix = "high_sorcerer",
		from = 98,
		to = 133
	},
	["high_sorcerer_death"] = {
		prefix = "high_sorcerer",
		from = 178,
		to = 237
	},
	["high_sorcerer_fx_run"] = {
		prefix = "high_sorcerer_fx",
		from = 1,
		to = 12
	},
	["high_sorcerer_idle"] = {
		prefix = "high_sorcerer",
		from = 1,
		to = 1
	},
	["high_sorcerer_ostrich_eat"] = {
		prefix = "desert_ostrich",
		from = 17,
		to = 68
	},
	["high_sorcerer_ostrich_idle"] = {
		prefix = "desert_ostrich",
		from = 1,
		to = 1
	},
	["high_sorcerer_ostrich_walk"] = {
		prefix = "desert_ostrich",
		from = 2,
		to = 16
	},
	["high_sorcerer_ray_travel"] = {
		prefix = "high_sorcerer_ray",
		from = 1,
		to = 18
	},
	["high_sorcerer_sheep_death"] = {
		prefix = "high_sorcerer_sheep",
		from = 38,
		to = 49
	},
	["high_sorcerer_sheep_idle"] = {
		prefix = "high_sorcerer_sheep",
		from = 1,
		to = 1
	},
	["high_sorcerer_sheep_walk"] = {
		prefix = "high_sorcerer_sheep",
		from = 2,
		to = 13
	},
	["high_sorcerer_sheep_walkDown"] = {
		prefix = "high_sorcerer_sheep",
		from = 14,
		to = 25
	},
	["high_sorcerer_sheep_walkUp"] = {
		prefix = "high_sorcerer_sheep",
		from = 26,
		to = 37
	},
	["high_sorcerer_smoke_run"] = {
		prefix = "smoke_small",
		from = 1,
		to = 11
	},
	["high_sorcerer_special"] = {
		prefix = "high_sorcerer",
		from = 134,
		to = 177
	},
	["high_sorcerer_walk"] = {
		prefix = "high_sorcerer",
		from = 2,
		to = 33
	},
	["high_sorcerer_walkDown"] = {
		prefix = "high_sorcerer",
		from = 34,
		to = 65
	},
	["high_sorcerer_walkUp"] = {
		prefix = "high_sorcerer",
		from = 66,
		to = 97
	},
	["house_parrot_idle"] = {
		prefix = "house_parrot",
		from = 1,
		to = 2
	},
	["house_parrot_run"] = {
		prefix = "house_parrot",
		from = 3,
		to = 25
	},
	["house_toad_eat"] = {
		prefix = "house_toad_layer",
		from = 231,
		to = 266
	},
	["house_toad_idle"] = {
		prefix = "house_toad_layer",
		from = 99,
		to = 230
	},
	["house_toad_inactive"] = {
		prefix = "house_toad_layer",
		from = 1,
		to = 68
	},
	["house_toad_wakeUp"] = {
		prefix = "house_toad_layer",
		from = 69,
		to = 98
	},
	["hunting_eagle_death"] = {
		prefix = "hunting_eagle",
		from = 43,
		to = 53
	},
	["hunting_eagle_walk"] = {
		prefix = "hunting_eagle",
		from = 1,
		to = 14
	},
	["hunting_eagle_walkDown"] = {
		prefix = "hunting_eagle",
		from = 29,
		to = 42
	},
	["hunting_eagle_walkUp"] = {
		prefix = "hunting_eagle",
		from = 15,
		to = 28
	},
	["ice_reaper_attack"] = {
		prefix = "ice_reaper",
		from = 74,
		to = 112
	},
	["ice_reaper_death"] = {
		prefix = "ice_reaper",
		from = 113,
		to = 166
	},
	["ice_reaper_idle"] = {
		prefix = "ice_reaper",
		from = 1,
		to = 1
	},
	["ice_reaper_spawn"] = {
		prefix = "ice_reaper",
		from = 167,
		to = 203
	},
	["ice_reaper_walk"] = {
		prefix = "ice_reaper",
		from = 2,
		to = 25
	},
	["ice_reaper_walkDown"] = {
		prefix = "ice_reaper",
		from = 26,
		to = 49
	},
	["ice_reaper_walkUp"] = {
		prefix = "ice_reaper",
		from = 50,
		to = 73
	},
	["ice_witch_attack"] = {
		prefix = "ice_witch",
		from = 56,
		to = 76
	},
	["ice_witch_bolt_hit"] = {
		prefix = "ice_witch_bolt",
		from = 5,
		to = 12
	},
	["ice_witch_bolt_travel"] = {
		prefix = "ice_witch_bolt",
		from = 1,
		to = 4
	},
	["ice_witch_death"] = {
		prefix = "ice_witch",
		from = 140,
		to = 150
	},
	["ice_witch_idle"] = {
		prefix = "ice_witch",
		from = 1,
		to = 1
	},
	["ice_witch_shoot"] = {
		prefix = "ice_witch",
		from = 77,
		to = 101
	},
	["ice_witch_summon"] = {
		prefix = "ice_witch",
		from = 102,
		to = 139
	},
	["ice_witch_walk"] = {
		prefix = "ice_witch",
		from = 2,
		to = 19
	},
	["ice_witch_walkDown"] = {
		prefix = "ice_witch",
		from = 20,
		to = 37
	},
	["ice_witch_walkUp"] = {
		prefix = "ice_witch",
		from = 38,
		to = 55
	},
	["iceberg_splash"] = {
		prefix = "Stage8_iceberg_splash",
		from = 1,
		to = 18
	},
	["iceberg_terrainCrack"] = {
		prefix = "Stage8_iceberg_terrain_cracks",
		from = 1,
		to = 6
	},
	["imperial_guard_hit_run"] = {
		prefix = "imperial_guard_hit",
		from = 1,
		to = 8
	},
	["knight_rider_attack"] = {
		prefix = "knight_rider",
		from = 44,
		to = 71
	},
	["knight_rider_chargeWalk"] = {
		prefix = "knight_rider",
		from = 72,
		to = 81
	},
	["knight_rider_chargeWalkDown"] = {
		prefix = "knight_rider",
		from = 82,
		to = 91
	},
	["knight_rider_chargeWalkUp"] = {
		prefix = "knight_rider",
		from = 92,
		to = 101
	},
	["knight_rider_death"] = {
		prefix = "knight_rider",
		from = 102,
		to = 125
	},
	["knight_rider_idle"] = {
		prefix = "knight_rider",
		from = 1,
		to = 1
	},
	["knight_rider_walk"] = {
		prefix = "knight_rider",
		from = 2,
		to = 15
	},
	["knight_rider_walkDown"] = {
		prefix = "knight_rider",
		from = 16,
		to = 29
	},
	["knight_rider_walkUp"] = {
		prefix = "knight_rider",
		from = 30,
		to = 43
	},
	["ladle_action"] = {
		prefix = "ladle_layer",
		from = 37,
		to = 58
	},
	["ladle_cauldron_idle"] = {
		prefix = "ladle_cauldron_layer",
		from = 1,
		to = 36
	},
	["ladle_cauldron_idleEmpty"] = {
		prefix = "ladle_cauldron_layer",
		from = 47,
		to = 82
	},
	["ladle_cauldron_in"] = {
		prefix = "ladle_cauldron_layer",
		from = 83,
		to = 92
	},
	["ladle_cauldron_out"] = {
		prefix = "ladle_cauldron_layer",
		from = 37,
		to = 46
	},
	["ladle_emptyWalk"] = {
		prefix = "ladle_layer",
		from = 59,
		to = 59
	},
	["ladle_poison_bubble_run"] = {
		prefix = "ladle_poison_bubble",
		from = 1,
		to = 18
	},
	["ladle_poison_intro"] = {
		prefix = "ladle_poison",
		from = 1,
		to = 6
	},
	["ladle_poison_run"] = {
		prefix = "ladle_poison",
		from = 7,
		to = 7
	},
	["ladle_poison_steam_intro"] = {
		prefix = "ladle_poison_steam",
		from = 1,
		to = 6
	},
	["ladle_poison_steam_run"] = {
		prefix = "ladle_poison_steam",
		from = 7,
		to = 36
	},
	["ladle_walk"] = {
		prefix = "ladle_layer",
		from = 1,
		to = 36
	},
	["leap_dragon_attack"] = {
		prefix = "leap_dragon",
		from = 183,
		to = 199
	},
	["leap_dragon_death"] = {
		prefix = "leap_dragon",
		from = 200,
		to = 225
	},
	["leap_dragon_flyDeath"] = {
		prefix = "leap_dragon",
		from = 226,
		to = 241
	},
	["leap_dragon_flyEnd"] = {
		prefix = "leap_dragon",
		from = 42,
		to = 62
	},
	["leap_dragon_flyEndDown"] = {
		prefix = "leap_dragon",
		from = 102,
		to = 122
	},
	["leap_dragon_flyEndUp"] = {
		prefix = "leap_dragon",
		from = 162,
		to = 182
	},
	["leap_dragon_flyInit"] = {
		prefix = "leap_dragon",
		from = 18,
		to = 31
	},
	["leap_dragon_flyInitDown"] = {
		prefix = "leap_dragon",
		from = 79,
		to = 91
	},
	["leap_dragon_flyInitUp"] = {
		prefix = "leap_dragon",
		from = 139,
		to = 151
	},
	["leap_dragon_flyWalk"] = {
		prefix = "leap_dragon",
		from = 32,
		to = 41
	},
	["leap_dragon_flyWalkDown"] = {
		prefix = "leap_dragon",
		from = 92,
		to = 101
	},
	["leap_dragon_flyWalkUp"] = {
		prefix = "leap_dragon",
		from = 152,
		to = 161
	},
	["leap_dragon_idle"] = {
		prefix = "leap_dragon",
		from = 1,
		to = 1
	},
	["leap_dragon_walk"] = {
		prefix = "leap_dragon",
		from = 2,
		to = 17
	},
	["leap_dragon_walkDown"] = {
		prefix = "leap_dragon",
		from = 63,
		to = 78
	},
	["leap_dragon_walkUp"] = {
		prefix = "leap_dragon",
		from = 123,
		to = 138
	},
	["legion_archer_arrow_travel"] = {
		prefix = "legion_archer_arrow",
		from = 1,
		to = 4
	},
	["legion_archer_attack"] = {
		prefix = "legion_archer",
		from = 62,
		to = 80
	},
	["legion_archer_death"] = {
		prefix = "legion_archer",
		from = 104,
		to = 121
	},
	["legion_archer_idle"] = {
		prefix = "legion_archer",
		from = 1,
		to = 1
	},
	["legion_archer_range"] = {
		prefix = "legion_archer",
		from = 81,
		to = 103
	},
	["legion_archer_walk"] = {
		prefix = "legion_archer",
		from = 2,
		to = 21
	},
	["legion_archer_walkDown"] = {
		prefix = "legion_archer",
		from = 22,
		to = 41
	},
	["legion_archer_walkUp"] = {
		prefix = "legion_archer",
		from = 42,
		to = 61
	},
	["legionnaire_attack"] = {
		prefix = "hammerhold_soldier",
		from = 62,
		to = 80
	},
	["legionnaire_death"] = {
		prefix = "hammerhold_soldier",
		from = 81,
		to = 98
	},
	["legionnaire_idle"] = {
		prefix = "hammerhold_soldier",
		from = 1,
		to = 1
	},
	["legionnaire_walk"] = {
		prefix = "hammerhold_soldier",
		from = 2,
		to = 21
	},
	["legionnaire_walkDown"] = {
		prefix = "hammerhold_soldier",
		from = 22,
		to = 41
	},
	["legionnaire_walkUp"] = {
		prefix = "hammerhold_soldier",
		from = 42,
		to = 61
	},
	["lich_attack"] = {
		prefix = "lich",
		from = 76,
		to = 103
	},
	["lich_death"] = {
		prefix = "lich",
		from = 178,
		to = 214
	},
	["lich_ray_hit_fx_run"] = {
		prefix = "lich_ray_hit_fx",
		from = 1,
		to = 6
	},
	["lich_ray_travel"] = {
		prefix = "lich_ray",
		from = 1,
		to = 14
	},
	["lich_shoot"] = {
		prefix = "lich",
		from = 104,
		to = 139
	},
	["lich_special"] = {
		prefix = "lich",
		from = 140,
		to = 177
	},
	["lich_walk"] = {
		prefix = "lich",
		from = 1,
		to = 24
	},
	["lich_walkDown"] = {
		prefix = "lich",
		from = 25,
		to = 50
	},
	["lich_walkUp"] = {
		prefix = "lich",
		from = 51,
		to = 75
	},
	["lightseeker_attack1"] = {
		prefix = "lightseeker",
		from = 39,
		to = 61
	},
	["lightseeker_attack2"] = {
		prefix = "lightseeker",
		from = 62,
		to = 85
	},
	["lightseeker_buff"] = {
		prefix = "lightseeker",
		from = 86,
		to = 167
	},
	["lightseeker_chair_drink"] = {
		prefix = "lightseeker_chair",
		from = 33,
		to = 111
	},
	["lightseeker_chair_idle"] = {
		prefix = "lightseeker_chair",
		from = 1,
		to = 1
	},
	["lightseeker_chair_idleEmpty"] = {
		prefix = "lightseeker_chair",
		from = 3,
		to = 3
	},
	["lightseeker_chair_idleEmptyGlass"] = {
		prefix = "lightseeker_chair",
		from = 2,
		to = 2
	},
	["lightseeker_chair_idleOut"] = {
		prefix = "lightseeker_chair",
		from = 4,
		to = 4
	},
	["lightseeker_chair_standUp"] = {
		prefix = "lightseeker_chair",
		from = 5,
		to = 32
	},
	["lightseeker_death"] = {
		prefix = "lightseeker",
		from = 425,
		to = 474
	},
	["lightseeker_dummy_climbDown"] = {
		prefix = "lightseeker_dummy",
		from = 33,
		to = 116
	},
	["lightseeker_dummy_walk"] = {
		prefix = "lightseeker_dummy",
		from = 1,
		to = 16
	},
	["lightseeker_dummy_walkDown"] = {
		prefix = "lightseeker_dummy",
		from = 17,
		to = 32
	},
	["lightseeker_heal"] = {
		prefix = "lightseeker",
		from = 168,
		to = 266
	},
	["lightseeker_idle"] = {
		prefix = "lightseeker",
		from = 1,
		to = 14
	},
	["lightseeker_idleDefeat"] = {
		prefix = "lightseeker",
		from = 475,
		to = 475
	},
	["lightseeker_spawnEnd"] = {
		prefix = "lightseeker",
		from = 279,
		to = 424
	},
	["lightseeker_spawnWalk"] = {
		prefix = "lightseeker",
		from = 267,
		to = 278
	},
	["lightseeker_waiter_in"] = {
		prefix = "lightseeker_waiter",
		from = 1,
		to = 113
	},
	["lightseeker_waiter_out"] = {
		prefix = "lightseeker_waiter",
		from = 149,
		to = 257
	},
	["lightseeker_waiter_serve"] = {
		prefix = "lightseeker_waiter",
		from = 114,
		to = 149
	},
	["lightseeker_walk"] = {
		prefix = "lightseeker",
		from = 15,
		to = 38
	},
	["linirea_banner_soldier_attackSpear"] = {
		prefix = "linirea_banner_soldier",
		from = 91,
		to = 133
	},
	["linirea_banner_soldier_attackSword"] = {
		prefix = "linirea_banner_soldier",
		from = 53,
		to = 90
	},
	["linirea_banner_soldier_death"] = {
		prefix = "linirea_banner_soldier",
		from = 134,
		to = 161
	},
	["linirea_banner_soldier_idle"] = {
		prefix = "linirea_banner_soldier",
		from = 1,
		to = 1
	},
	["linirea_banner_soldier_special"] = {
		prefix = "linirea_banner_soldier",
		from = 162,
		to = 207
	},
	["linirea_banner_soldier_walk"] = {
		prefix = "linirea_banner_soldier",
		from = 2,
		to = 18
	},
	["linirea_banner_soldier_walkDown"] = {
		prefix = "linirea_banner_soldier",
		from = 19,
		to = 35
	},
	["linirea_banner_soldier_walkUp"] = {
		prefix = "linirea_banner_soldier",
		from = 36,
		to = 52
	},
	["linirea_joe_attack"] = {
		prefix = "linirea_joe",
		from = 286,
		to = 307
	},
	["linirea_joe_callSheep"] = {
		prefix = "linirea_joe",
		from = 337,
		to = 373
	},
	["linirea_joe_curse"] = {
		prefix = "linirea_joe",
		from = 159,
		to = 196
	},
	["linirea_joe_death"] = {
		prefix = "linirea_joe",
		from = 374,
		to = 395
	},
	["linirea_joe_idle"] = {
		prefix = "linirea_joe",
		from = 265,
		to = 265
	},
	["linirea_joe_idleStanding"] = {
		prefix = "linirea_joe",
		from = 1,
		to = 1
	},
	["linirea_joe_specialAttack"] = {
		prefix = "linirea_joe",
		from = 308,
		to = 336
	},
	["linirea_joe_straw"] = {
		prefix = "linirea_joe",
		from = 2,
		to = 73
	},
	["linirea_joe_toSayayin"] = {
		prefix = "linirea_joe",
		from = 197,
		to = 264
	},
	["linirea_joe_walk"] = {
		prefix = "linirea_joe",
		from = 266,
		to = 285
	},
	["linirea_joe_watch"] = {
		prefix = "linirea_joe",
		from = 74,
		to = 158
	},
	["linirea_soldier_attack"] = {
		prefix = "linirea_soldier",
		from = 62,
		to = 80
	},
	["linirea_soldier_death"] = {
		prefix = "linirea_soldier",
		from = 81,
		to = 98
	},
	["linirea_soldier_idle"] = {
		prefix = "linirea_soldier",
		from = 1,
		to = 1
	},
	["linirea_soldier_toSoldier"] = {
		prefix = "linirea_soldier",
		from = 99,
		to = 132
	},
	["linirea_soldier_walk"] = {
		prefix = "linirea_soldier",
		from = 2,
		to = 21
	},
	["linirea_soldier_walkDown"] = {
		prefix = "linirea_soldier",
		from = 22,
		to = 41
	},
	["linirea_soldier_walkUp"] = {
		prefix = "linirea_soldier",
		from = 42,
		to = 61
	},
	["lord_head_1_flash"] = {
		prefix = "lord_head_1",
		from = 25,
		to = 48
	},
	["lord_head_1_fx_run"] = {
		prefix = "lord_head_1_fx",
		from = 1,
		to = 48
	},
	["lord_head_1_run"] = {
		prefix = "lord_head_1",
		from = 1,
		to = 24
	},
	["lord_head_2_flash"] = {
		prefix = "lord_head_2",
		from = 25,
		to = 48
	},
	["lord_head_2_fx_run"] = {
		prefix = "lord_head_2_fx",
		from = 1,
		to = 48
	},
	["lord_head_2_run"] = {
		prefix = "lord_head_2",
		from = 1,
		to = 24
	},
	["lord_of_afterlife_1_death"] = {
		prefix = "lord_of_afterlife_1",
		from = 112,
		to = 163
	},
	["lord_of_afterlife_1_spawn"] = {
		prefix = "lord_of_afterlife_1",
		from = 1,
		to = 93
	},
	["lord_of_afterlife_1_walk"] = {
		prefix = "lord_of_afterlife_1",
		from = 94,
		to = 111
	},
	["lord_of_afterlife_2_death"] = {
		prefix = "lord_of_afterlife_2",
		from = 112,
		to = 163
	},
	["lord_of_afterlife_2_spawn"] = {
		prefix = "lord_of_afterlife_2",
		from = 1,
		to = 93
	},
	["lord_of_afterlife_2_walk"] = {
		prefix = "lord_of_afterlife_2",
		from = 94,
		to = 111
	},
	["lord_of_afterlife_effect_2_run"] = {
		prefix = "lord_of_afterlife_effect_2",
		from = 1,
		to = 23
	},
	["lord_of_afterlife_effect_run"] = {
		prefix = "lord_of_afterlife_effect",
		from = 1,
		to = 23
	},
	["machine_spawner_idle"] = {
		prefix = "machine_spawner_layer",
		from = 1,
		to = 1
	},
	["machine_spawner_layerX_idle"] = {
		layer_from = 1,
		layer_to = 14,
		layer_prefix = "machine_spawner_layer%i",
		from = 1,
		to = 1
	},
	["machine_spawner_run"] = {
		prefix = "machine_spawner_layer",
		from = 2,
		to = 145
	},
	["machine_spawner_layerX_run"] = {
		layer_from = 1,
		layer_to = 14,
		layer_prefix = "machine_spawner_layer%i",
		from = 2,
		to = 145
	},
["magic_carpet_attack"] = {
prefix = "magic_carpet_layer1",
		from = 40,
		to = 101
	},
["magic_carpet_death"] = {
prefix = "magic_carpet_layer1",
		from = 102,
		to = 120
	},
	["magic_carpet_explosion_run"] = {
		prefix = "magic_carpet_explosion",
		from = 1,
		to = 24
	},
["magic_carpet_idle"] = {
prefix = "magic_carpet_layer1",
		from = 1,
		to = 13
	},
	["magic_carpet_trail_run"] = {
		prefix = "magic_carpet_trail",
		from = 1,
		to = 12
	},
["magic_carpet_walk"] = {
prefix = "magic_carpet_layer1",
		from = 1,
		to = 13
	},
["magic_carpet_walkDown"] = {
prefix = "magic_carpet_layer1",
		from = 14,
		to = 26
	},
["magic_carpet_walkUp"] = {
prefix = "magic_carpet_layer1",
		from = 27,
		to = 39
	},
	["magnus_tower_block"] = {
		prefix = "magnus_tower_layer",
		from = 138,
		to = 159
	},
	["magnus_tower_blockEnd"] = {
		prefix = "magnus_tower_layer",
		from = 190,
		to = 193
	},
	["magnus_tower_blockLoop"] = {
		prefix = "magnus_tower_layer",
		from = 160,
		to = 189
	},
	["magnus_tower_blueIdle"] = {
		prefix = "magnus_tower_layer",
		from = 33,
		to = 33
	},
	["magnus_tower_blueIn"] = {
		prefix = "magnus_tower_layer",
		from = 21,
		to = 32
	},
	["magnus_tower_blueOut"] = {
		prefix = "magnus_tower_layer",
		from = 34,
		to = 51
	},
	["magnus_tower_destroyed_explosion_run"] = {
		prefix = "magnus_tower_destroyed_explosion",
		from = 1,
		to = 19
	},
	["magnus_tower_destroyed_smog_run"] = {
		prefix = "magnus_tower_destroyed_smog",
		from = 1,
		to = 39
	},
	["magnus_tower_idle"] = {
		prefix = "magnus_tower_layer",
		from = 1,
		to = 1
	},
	["magnus_tower_idleClosed"] = {
		prefix = "magnus_tower_layer",
		from = 127,
		to = 127
	},
	["magnus_tower_idleIn"] = {
		prefix = "magnus_tower_layer",
		from = 117,
		to = 126
	},
	["magnus_tower_idleOut"] = {
		prefix = "magnus_tower_layer",
		from = 2,
		to = 20
	},
	["magnus_tower_modifier_block_in"] = {
		prefix = "magnus_tower_modifier_block",
		from = 1,
		to = 7
	},
	["magnus_tower_modifier_block_loop"] = {
		prefix = "magnus_tower_modifier_block",
		from = 8,
		to = 21
	},
	["magnus_tower_modifier_block_out"] = {
		prefix = "magnus_tower_modifier_block",
		from = 22,
		to = 33
	},
	["magnus_tower_modifier_shield_in"] = {
		prefix = "magnus_tower_modifier_shield",
		from = 1,
		to = 8
	},
	["magnus_tower_modifier_shield_loop"] = {
		prefix = "magnus_tower_modifier_shield",
		from = 9,
		to = 25
	},
	["magnus_tower_modifier_shield_out"] = {
		prefix = "magnus_tower_modifier_shield",
		from = 26,
		to = 26
	},
	["magnus_tower_open"] = {
		prefix = "magnus_tower_layer",
		from = 128,
		to = 137
	},
	["magnus_tower_orangeIdle"] = {
		prefix = "magnus_tower_layer",
		from = 65,
		to = 65
	},
	["magnus_tower_orangeIn"] = {
		prefix = "magnus_tower_layer",
		from = 52,
		to = 64
	},
	["magnus_tower_orangeOut"] = {
		prefix = "magnus_tower_layer",
		from = 66,
		to = 83
	},
	["magnus_tower_shield"] = {
		prefix = "magnus_tower_layer",
		from = 194,
		to = 215
	},
	["magnus_tower_shieldEnd"] = {
		prefix = "magnus_tower_layer",
		from = 246,
		to = 249
	},
	["magnus_tower_shieldLoop"] = {
		prefix = "magnus_tower_layer",
		from = 216,
		to = 245
	},
	["magnus_tower_spoon"] = {
		prefix = "magnus_tower_layer",
		from = 250,
		to = 270
	},
	["magnus_tower_spoonEnd"] = {
		prefix = "magnus_tower_layer",
		from = 301,
		to = 305
	},
	["magnus_tower_spoonLoop"] = {
		prefix = "magnus_tower_layer",
		from = 271,
		to = 300
	},
	["magnus_tower_violetIdle"] = {
		prefix = "magnus_tower_layer",
		from = 97,
		to = 97
	},
	["magnus_tower_violetIn"] = {
		prefix = "magnus_tower_layer",
		from = 84,
		to = 96
	},
	["magnus_tower_violetOut"] = {
		prefix = "magnus_tower_layer",
		from = 98,
		to = 116
	},
	["malik_attack_decal_run"] = {
		prefix = "malik_attack_floor_decal",
		from = 1,
		to = 27
	},
	["malik_attack_ray_modifier_run"] = {
		prefix = "malik_attack_ray_modifier",
		from = 1,
		to = 6
	},
	["malik_attack_ray_travel"] = {
		prefix = "malik_attack_ray",
		from = 1,
		to = 20
	},
	["malik_death"] = {
		prefix = "malik_layer",
		from = 570,
		to = 602
	},
	["malik_deathEnd"] = {
		prefix = "malik_layer",
		from = 637,
		to = 669
	},
	["malik_deathLoop"] = {
		prefix = "malik_layer",
		from = 603,
		to = 636
	},
	["malik_idle"] = {
		prefix = "malik_layer",
		from = 1,
		to = 1
	},
	["malik_idleWalk"] = {
		prefix = "malik_layer",
		from = 237,
		to = 237
	},
	["malik_jumpLand"] = {
		prefix = "malik_layer",
		from = 432,
		to = 460
	},
	["malik_jumpLaunch"] = {
		prefix = "malik_layer",
		from = 389,
		to = 424
	},
	["malik_jumpTravel"] = {
		prefix = "malik_layer",
		from = 425,
		to = 431
	},
	["malik_jump_decal_run"] = {
		prefix = "malik_jump_decal",
		from = 1,
		to = 18
	},
	["malik_melee"] = {
		prefix = "malik_layer",
		from = 290,
		to = 343
	},
	["malik_range"] = {
		prefix = "malik_layer",
		from = 344,
		to = 388
	},
	["malik_sitAngry"] = {
		prefix = "malik_layer",
		from = 2,
		to = 57
	},
	["malik_layerX_sitAngry"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "malik_layer%i",
		from = 2,
		to = 57
	},
	["malik_sitJump"] = {
		prefix = "malik_layer",
		from = 180,
		to = 236
	},
	["malik_layerX_sitJump"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "malik_layer%i",
		from = 180,
		to = 236
	},
	["malik_sitLaugh"] = {
		prefix = "malik_layer",
		from = 111,
		to = 179
	},
	["malik_layerX_sitLaugh"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "malik_layer%i",
		from = 111,
		to = 179
	},
	["malik_sitTauntEnd"] = {
		prefix = "malik_layer",
		from = 98,
		to = 110
	},
	["malik_sitTauntIn"] = {
		prefix = "malik_layer",
		from = 58,
		to = 63
	},
	["malik_sitTauntLoop"] = {
		prefix = "malik_layer",
		from = 64,
		to = 97
	},
	["malik_layerX_sitTauntLoop"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "malik_layer%i",
		from = 64,
		to = 97
	},
	["malik_special"] = {
		prefix = "malik_layer",
		from = 461,
		to = 525
	},
	["malik_taunt"] = {
		prefix = "malik_layer",
		from = 526,
		to = 569
	},
	["malik_tower_explotion_loop"] = {
		prefix = "malik_towerdestroction_explotion",
		from = 50,
		to = 50
	},
	["malik_tower_explotion_start"] = {
		prefix = "malik_towerdestroction_explotion",
		from = 1,
		to = 50
	},
	["malik_towerdestroction_ray_run"] = {
		prefix = "malik_towerdestroction_ray",
		from = 1,
		to = 16
	},
	["malik_walk"] = {
		prefix = "malik_layer",
		from = 238,
		to = 289
	},
	["marauder_attack"] = {
		prefix = "linirea_caravan_marauder",
		from = 42,
		to = 60
	},
	["marauder_death"] = {
		prefix = "linirea_caravan_marauder",
		from = 61,
		to = 81
	},
	["marauder_idle"] = {
		prefix = "linirea_caravan_marauder",
		from = 1,
		to = 1
	},
	["marauder_walk"] = {
		prefix = "linirea_caravan_marauder",
		from = 2,
		to = 21
	},
	["marauder_walkDown"] = {
		prefix = "linirea_caravan_marauder",
		from = 22,
		to = 41
	},
	["mcpato_in"] = {
		prefix = "mc_pato",
		from = 1,
		to = 97
	},
	["mcpato_jump"] = {
		prefix = "mc_pato",
		from = 98,
		to = 151
	},
	["mcpato_out"] = {
		prefix = "mc_pato",
		from = 152,
		to = 174
	},
	["mechadwarf_attack"] = {
		prefix = "mechadwarf",
		from = 97,
		to = 129
	},
	["mechadwarf_broken"] = {
		prefix = "mechadwarf",
		from = 130,
		to = 153
	},
	["mechadwarf_death"] = {
		prefix = "mechadwarf",
		from = 200,
		to = 235
	},
	["mechadwarf_decal_run"] = {
		prefix = "mechadwarf_decal",
		from = 1,
		to = 11
	},
	["mechadwarf_explosion_run"] = {
		prefix = "mechadwarf_explosion",
		from = 1,
		to = 11
	},
	["mechadwarf_idle"] = {
		prefix = "mechadwarf",
		from = 1,
		to = 1
	},
	["mechadwarf_specialAttack"] = {
		prefix = "mechadwarf",
		from = 154,
		to = 199
	},
	["mechadwarf_walk"] = {
		prefix = "mechadwarf",
		from = 2,
		to = 32
	},
	["mechadwarf_walkDown"] = {
		prefix = "mechadwarf",
		from = 67,
		to = 96
	},
	["mechadwarf_walkUp"] = {
		prefix = "mechadwarf",
		from = 33,
		to = 66
	},
	["mega_boss_dragon_breath_1_run"] = {
		prefix = "mega_boss_dragon_breath_1",
		from = 1,
		to = 60
	},
	["mega_boss_dragon_breath_2_run"] = {
		prefix = "mega_boss_dragon_breath_2",
		from = 1,
		to = 60
	},
	["mega_boss_dragon_breath_3_run"] = {
		prefix = "mega_boss_dragon_breath_3",
		from = 1,
		to = 60
	},
	["mega_boss_dragon_breath_freeze_run"] = {
		prefix = "mega_boss_dragon_breath_freeze",
		from = 1,
		to = 19
	},
	["mega_boss_dragon_explotion_run"] = {
		prefix = "mega_boss_dragon_explotion",
		from = 1,
		to = 20
	},
	["mega_boss_dragon_proyectile_smoke_run"] = {
		prefix = "mega_boss_dragon_proyectile_smoke",
		from = 1,
		to = 18
	},
	["mega_boss_dragon_tower_freeze_end"] = {
		prefix = "mega_boss_dragon_tower_freeze_layer",
		from = 23,
		to = 49
	},
	["mega_boss_dragon_tower_freeze_idle"] = {
		prefix = "mega_boss_dragon_tower_freeze_layer",
		from = 22,
		to = 22
	},
	["mega_boss_dragon_tower_freeze_start"] = {
		prefix = "mega_boss_dragon_tower_freeze_layer",
		from = 1,
		to = 21
	},
	["mercenary_troll_hunter_attack"] = {
		prefix = "mercenary_troll_hunter",
		from = 18,
		to = 36
	},
	["mercenary_troll_hunter_attackRange"] = {
		prefix = "mercenary_troll_hunter",
		from = 37,
		to = 55
	},
	["mercenary_troll_hunter_death"] = {
		prefix = "mercenary_troll_hunter",
		from = 56,
		to = 74
	},
	["mercenary_troll_hunter_idle"] = {
		prefix = "mercenary_troll_hunter",
		from = 1,
		to = 1
	},
	["mercenary_troll_hunter_walk"] = {
		prefix = "mercenary_troll_hunter",
		from = 2,
		to = 17
	},
	["mercenary_troll_hunter_running"] = {
		prefix = "mercenary_troll_hunter",
		from = 2,
		to = 17
	},
	["mercenary_troll_hut_layer_close"] = {
		prefix = "mercenary_troll_hut_layer",
		from = 6,
		to = 8
	},
	["mercenary_troll_hut_layer1_close"] = {
		prefix = "mercenary_troll_hut_layer1",
		from = 6,
		to = 8
	},
	["mercenary_troll_hut_layer1_close_over"] = {
		prefix = "mercenary_troll_hut_layer1",
		from = 6,
		to = 8
	},
	["mercenary_troll_hut_layer2_close"] = {
		prefix = "mercenary_troll_hut_layer2",
		from = 6,
		to = 8
	},
	["mercenary_troll_hut_layer_idle"] = {
		prefix = "mercenary_troll_hut_layer",
		from = 1,
		to = 1
	},
	["mercenary_troll_hut_layer1_idle"] = {
		prefix = "mercenary_troll_hut_layer1",
		from = 1,
		to = 1
	},
	["mercenary_troll_hut_layer1_idle_over"] = {
		prefix = "mercenary_troll_hut_layer1",
		from = 1,
		to = 1
	},
	["mercenary_troll_hut_layer2_idle"] = {
		prefix = "mercenary_troll_hut_layer2",
		from = 1,
		to = 1
	},
	["mercenary_troll_hut_layer_open"] = {
		prefix = "mercenary_troll_hut_layer",
		from = 2,
		to = 5
	},
	["mercenary_troll_hut_layer1_open"] = {
		prefix = "mercenary_troll_hut_layer1",
		from = 2,
		to = 5
	},
	["mercenary_troll_hut_layer2_open"] = {
		prefix = "mercenary_troll_hut_layer2",
		from = 2,
		to = 5
	},
	["mercenary_troll_spear_attack"] = {
		prefix = "mercenary_troll_spear",
		from = 16,
		to = 40
	},
	["mercenary_troll_spear_death"] = {
		prefix = "mercenary_troll_spear",
		from = 41,
		to = 51
	},
	["mercenary_troll_spear_idle"] = {
		prefix = "mercenary_troll_spear",
		from = 1,
		to = 1
	},
	["mercenary_troll_spear_walk"] = {
		prefix = "mercenary_troll_spear",
		from = 2,
		to = 15
	},
	["mercenary_troll_spear_running"] = {
		prefix = "mercenary_troll_spear",
		from = 2,
		to = 15
	},
	["mirage_attack"] = {
		prefix = "mirage",
		from = 72,
		to = 96
	},
	["mirage_back_light_run"] = {
		prefix = "mirage_back_light",
		from = 1,
		to = 15
	},
	["mirage_clon_attack"] = {
		prefix = "mirage_clon",
		from = 2,
		to = 25
	},
	["mirage_clon_death"] = {
		prefix = "mirage_clon",
		from = 1,
		to = 1
	},
	["mirage_clon_idle"] = {
		prefix = "mirage_clon",
		from = 1,
		to = 1
	},
	["mirage_copies"] = {
		prefix = "mirage",
		from = 141,
		to = 183
	},
	["mirage_death"] = {
		prefix = "mirage",
		from = 304,
		to = 349
	},
	["mirage_deathLoop"] = {
		prefix = "mirage",
		from = 350,
		to = 376
	},
	["mirage_decal_run"] = {
		prefix = "mirage_decal",
		from = 1,
		to = 15
	},
	["mirage_dodgeIn"] = {
		prefix = "mirage",
		from = 56,
		to = 71
	},
	["mirage_dodgeOut"] = {
		prefix = "mirage",
		from = 51,
		to = 55
	},
	["mirage_goIn"] = {
		prefix = "mirage",
		from = 26,
		to = 50
	},
	["mirage_goOut"] = {
		prefix = "mirage",
		from = 2,
		to = 25
	},
	["mirage_hit_run"] = {
		prefix = "mirage_hit",
		from = 1,
		to = 6
	},
	["mirage_horn"] = {
		prefix = "mirage",
		from = 97,
		to = 140
	},
	["mirage_idle"] = {
		prefix = "mirage",
		from = 1,
		to = 1
	},
	["mirage_rangeAttack"] = {
		prefix = "mirage",
		from = 244,
		to = 273
	},
	["mirage_rangeAttackUp"] = {
		prefix = "mirage",
		from = 274,
		to = 303
	},
	["mirage_skill_decal_sand_run"] = {
		prefix = "mirage_skill_decal_sand",
		from = 1,
		to = 18
	},
	["mirage_skill_decal_smoke_run"] = {
		prefix = "mirage_skill_decal_smoke",
		from = 1,
		to = 22
	},
	["mirage_smoke_in_run"] = {
		prefix = "mirage_smoke",
		from = 33,
		to = 52
	},
	["mirage_smoke_out_run"] = {
		prefix = "mirage_smoke",
		from = 1,
		to = 32
	},
	["mirage_walk"] = {
		prefix = "mirage",
		from = 184,
		to = 203
	},
	["mirage_walkDown"] = {
		prefix = "mirage",
		from = 224,
		to = 243
	},
	["mirage_walkUp"] = {
		prefix = "mirage",
		from = 204,
		to = 223
	},
	["mode_stage5_veznans_prisoner_1_idle"] = {
		prefix = "modes_stage5_veznans_prisioner_1",
		from = 45,
		to = 45
	},
	["mode_stage5_veznans_prisoner_1_run"] = {
		prefix = "modes_stage5_veznans_prisioner_1",
		from = 1,
		to = 45
	},
	["mode_stage5_veznans_prisoner_2_idle"] = {
		prefix = "modes_stage5_veznans_prisioner_2",
		from = 45,
		to = 45
	},
	["mode_stage5_veznans_prisoner_2_run"] = {
		prefix = "modes_stage5_veznans_prisioner_2",
		from = 1,
		to = 45
	},
	["mode_stage5_veznans_prisoner_3_idle"] = {
		prefix = "modes_stage5_veznans_prisioner_3",
		from = 1,
		to = 1
	},
	["mode_stage5_veznans_prisoner_3_run"] = {
		prefix = "modes_stage5_veznans_prisioner_3",
		from = 1,
		to = 45
	},
	["mode_stage5_veznans_prisoner_4_run"] = {
		prefix = "modes_stage5_veznans_prisioner_4",
		from = 1,
		to = 24
	},
	["moe_faint"] = {
		prefix = "moe",
		from = 127,
		to = 230
	},
	["moe_moes"] = {
		prefix = "moe",
		from = 1,
		to = 126
	},
	["mogwai_attack"] = {
		prefix = "mogwai",
		from = 50,
		to = 81
	},
	["mogwai_death"] = {
		prefix = "mogwai",
		from = 82,
		to = 95
	},
	["mogwai_idle"] = {
		prefix = "mogwai",
		from = 1,
		to = 1
	},
	["mogwai_multiply"] = {
		prefix = "mogwai",
		from = 96,
		to = 125
	},
	["mogwai_spawn"] = {
		prefix = "mogwai",
		from = 126,
		to = 137
	},
	["mogwai_walk"] = {
		prefix = "mogwai",
		from = 2,
		to = 17
	},
	["mogwai_walkDown"] = {
		prefix = "mogwai",
		from = 18,
		to = 33
	},
	["mogwai_walkUp"] = {
		prefix = "mogwai",
		from = 34,
		to = 49
	},
	["musketeer_attack"] = {
		prefix = "musketeer",
		from = 62,
		to = 81
	},
	["musketeer_death"] = {
		prefix = "musketeer",
		from = 364,
		to = 394
	},
	["musketeer_idle"] = {
		prefix = "musketeer",
		from = 1,
		to = 1
	},
	["musketeer_shootDown"] = {
		prefix = "musketeer",
		from = 111,
		to = 139
	},
	["musketeer_shootLateral"] = {
		prefix = "musketeer",
		from = 82,
		to = 110
	},
	["musketeer_shootUp"] = {
		prefix = "musketeer",
		from = 140,
		to = 169
	},
	["musketeer_smoke_run"] = {
		prefix = "fx_bullet_smoke",
		from = 1,
		to = 12
	},
	["musketeer_specialDown"] = {
		prefix = "musketeer",
		from = 233,
		to = 257
	},
	["musketeer_specialDownEnd"] = {
		prefix = "musketeer",
		from = 271,
		to = 297
	},
	["musketeer_specialDownLoop"] = {
		prefix = "musketeer",
		from = 258,
		to = 258
	},
	["musketeer_specialLateral"] = {
		prefix = "musketeer",
		from = 170,
		to = 194
	},
	["musketeer_specialLateralEnd"] = {
		prefix = "musketeer",
		from = 206,
		to = 232
	},
	["musketeer_specialLateralLoop"] = {
		prefix = "musketeer",
		from = 195,
		to = 195
	},
	["musketeer_specialUp"] = {
		prefix = "musketeer",
		from = 298,
		to = 322
	},
	["musketeer_specialUpEnd"] = {
		prefix = "musketeer",
		from = 336,
		to = 363
	},
	["musketeer_specialUpLoop"] = {
		prefix = "musketeer",
		from = 323,
		to = 323
	},
	["musketeer_walk"] = {
		prefix = "musketeer",
		from = 2,
		to = 21
	},
	["musketeer_walkDown"] = {
		prefix = "musketeer",
		from = 22,
		to = 41
	},
	["musketeer_walkUp"] = {
		prefix = "musketeer",
		from = 42,
		to = 61
	},
	["nanoq_warbear_attack"] = {
		prefix = "nanoq_warbear",
		from = 98,
		to = 124
	},
	["nanoq_warbear_chargeWalk"] = {
		prefix = "nanoq_warbear",
		from = 62,
		to = 73
	},
	["nanoq_warbear_chargeWalkDown"] = {
		prefix = "nanoq_warbear",
		from = 74,
		to = 85
	},
	["nanoq_warbear_chargeWalkUp"] = {
		prefix = "nanoq_warbear",
		from = 86,
		to = 97
	},
	["nanoq_warbear_death"] = {
		prefix = "nanoq_warbear",
		from = 126,
		to = 137
	},
	["nanoq_warbear_idle"] = {
		prefix = "nanoq_warbear",
		from = 1,
		to = 1
	},
	["nanoq_warbear_walk"] = {
		prefix = "nanoq_warbear",
		from = 2,
		to = 21
	},
	["nanoq_warbear_walkDown"] = {
		prefix = "nanoq_warbear",
		from = 22,
		to = 41
	},
	["nanoq_warbear_walkUp"] = {
		prefix = "nanoq_warbear",
		from = 42,
		to = 61
	},
	["nian_attack"] = {
		prefix = "nian",
		from = 50,
		to = 70
	},
	["nian_death"] = {
		prefix = "nian",
		from = 71,
		to = 89
	},
	["nian_idle"] = {
		prefix = "nian",
		from = 1,
		to = 1
	},
	["nian_regen_effect_healing_run"] = {
		prefix = "nian_regen_effect_healing",
		from = 1,
		to = 40
	},
	["nian_regen_effect_ripple_run"] = {
		prefix = "nian_regen_effect_ripple",
		from = 1,
		to = 40
	},
	["nian_walk"] = {
		prefix = "nian",
		from = 2,
		to = 17
	},
	["nian_walkDown"] = {
		prefix = "nian",
		from = 18,
		to = 33
	},
	["nian_walkUp"] = {
		prefix = "nian",
		from = 34,
		to = 49
	},
	["ninja_sheep_danielSanKick"] = {
		prefix = "ninja_sheep",
		from = 119,
		to = 172
	},
	["ninja_sheep_death"] = {
		prefix = "ninja_sheep",
		from = 207,
		to = 218
	},
	["ninja_sheep_fists"] = {
		prefix = "ninja_sheep",
		from = 53,
		to = 78
	},
	["ninja_sheep_idle"] = {
		prefix = "ninja_sheep",
		from = 46,
		to = 46
	},
	["ninja_sheep_kick"] = {
		prefix = "ninja_sheep",
		from = 79,
		to = 98
	},
	["ninja_sheep_spawn"] = {
		prefix = "ninja_sheep",
		from = 1,
		to = 45
	},
	["ninja_sheep_spinKick"] = {
		prefix = "ninja_sheep",
		from = 99,
		to = 118
	},
	["ninja_sheep_walk"] = {
		prefix = "ninja_sheep",
		from = 47,
		to = 52
	},
	["ninja_sheep_watch"] = {
		prefix = "ninja_sheep",
		from = 173,
		to = 206
	},
	["nomad_attack"] = {
		prefix = "nomad",
		from = 139,
		to = 173
	},
	["nomad_death"] = {
		prefix = "nomad",
		from = 174,
		to = 198
	},
	["nomad_idle"] = {
		prefix = "nomad",
		from = 1,
		to = 1
	},
	["nomad_shadowIn"] = {
		prefix = "nomad",
		from = 55,
		to = 72
	},
	["nomad_shadowOut"] = {
		prefix = "nomad",
		from = 50,
		to = 54
	},
	["nomad_spawn"] = {
		prefix = "nomad",
		from = 200,
		to = 243
	},
	["nomad_throwDown"] = {
		prefix = "nomad",
		from = 95,
		to = 116
	},
	["nomad_throwRight"] = {
		prefix = "nomad",
		from = 73,
		to = 94
	},
	["nomad_throwUp"] = {
		prefix = "nomad",
		from = 117,
		to = 138
	},
	["nomad_walk"] = {
		prefix = "nomad",
		from = 2,
		to = 17
	},
	["nomad_walkDown"] = {
		prefix = "nomad",
		from = 18,
		to = 33
	},
	["nomad_walkUp"] = {
		prefix = "nomad",
		from = 34,
		to = 49
	},
	["northern_berserker_attackArea"] = {
		prefix = "northern_berserker",
		from = 68,
		to = 97
	},
	["northern_berserker_death"] = {
		prefix = "northern_berserker",
		from = 98,
		to = 117
	},
	["northern_berserker_idle"] = {
		prefix = "northern_berserker",
		from = 1,
		to = 1
	},
	["northern_berserker_walk"] = {
		prefix = "northern_berserker",
		from = 2,
		to = 23
	},
	["northern_berserker_walkDown"] = {
		prefix = "northern_berserker",
		from = 46,
		to = 67
	},
	["northern_berserker_walkUp"] = {
		prefix = "northern_berserker",
		from = 24,
		to = 45
	},
	["northern_huntress_attack"] = {
		prefix = "northern_huntress",
		from = 62,
		to = 80
	},
	["northern_huntress_death"] = {
		prefix = "northern_huntress",
		from = 106,
		to = 119
	},
	["northern_huntress_idle"] = {
		prefix = "northern_huntress",
		from = 1,
		to = 1
	},
	["northern_huntress_special"] = {
		prefix = "northern_huntress",
		from = 81,
		to = 105
	},
	["northern_huntress_walk"] = {
		prefix = "northern_huntress",
		from = 2,
		to = 21
	},
	["northern_huntress_walkDown"] = {
		prefix = "northern_huntress",
		from = 22,
		to = 41
	},
	["northern_huntress_walkUp"] = {
		prefix = "northern_huntress",
		from = 42,
		to = 61
	},
	["northern_wildling_attack"] = {
		prefix = "northern_wildling",
		from = 68,
		to = 88
	},
	["northern_wildling_death"] = {
		prefix = "northern_wildling",
		from = 89,
		to = 102
	},
	["northern_wildling_idle"] = {
		prefix = "northern_wildling",
		from = 1,
		to = 1
	},
	["northern_wildling_walk"] = {
		prefix = "northern_wildling",
		from = 2,
		to = 23
	},
	["northern_wildling_walkDown"] = {
		prefix = "northern_wildling",
		from = 46,
		to = 67
	},
	["northern_wildling_walkUp"] = {
		prefix = "northern_wildling",
		from = 24,
		to = 45
	},
	["olaf_dance"] = {
		prefix = "Stage7_olaf",
		from = 58,
		to = 114
	},
	["olaf_death"] = {
		prefix = "Stage7_olaf",
		from = 115,
		to = 135
	},
	["olaf_idle"] = {
		prefix = "Stage7_olaf",
		from = 1,
		to = 1
	},
	["olaf_toOlaf"] = {
		prefix = "Stage7_olaf",
		from = 2,
		to = 57
	},
	["overcharge_crystals_base_charged"] = {
		prefix = "overcharge_crystals_base_layer",
		from = 33,
		to = 48
	},
	["overcharge_crystals_base_charging"] = {
		prefix = "overcharge_crystals_base_layer",
		from = 2,
		to = 32
	},
	["overcharge_crystals_base_idle"] = {
		prefix = "overcharge_crystals_base_layer",
		from = 1,
		to = 1
	},
	["overcharge_crystals_base_shoot"] = {
		prefix = "overcharge_crystals_base_layer",
		from = 49,
		to = 67
	},
	["overcharge_crystals_explotion_run"] = {
		prefix = "overcharge_crystals_explotion",
		from = 1,
		to = 16
	},
	["overcharge_crystals_modifier_run"] = {
		prefix = "overcharge_crystals_modifier",
		from = 1,
		to = 16
	},
	["overcharge_crystals_ray_loop_loop"] = {
		prefix = "overcharge_crystals_ray_loop",
		from = 1,
		to = 10
	},
	["paladin_death"] = {
		prefix = "paladin",
		from = 198,
		to = 217
	},
	["paladin_groundAttack"] = {
		prefix = "paladin",
		from = 162,
		to = 197
	},
	["paladin_ground_attack_decal_run"] = {
		prefix = "paladin_ground_attack_decal",
		from = 1,
		to = 18
	},
	["paladin_idle"] = {
		prefix = "paladin",
		from = 1,
		to = 1
	},
	["paladin_modifier_decal_run"] = {
		prefix = "paladin_modifier_decal",
		from = 1,
		to = 20
	},
	["paladin_modifier_effect_run"] = {
		prefix = "paladin_modifier_effect",
		from = 1,
		to = 20
	},
	["paladin_shieldAttack"] = {
		prefix = "paladin",
		from = 120,
		to = 161
	},
	["paladin_specialAttack1"] = {
		prefix = "paladin",
		from = 73,
		to = 95
	},
	["paladin_specialAttack2"] = {
		prefix = "paladin",
		from = 96,
		to = 119
	},
	["paladin_walk"] = {
		prefix = "paladin",
		from = 2,
		to = 24
	},
	["paladin_walkDown"] = {
		prefix = "paladin",
		from = 25,
		to = 48
	},
	["paladin_walkUp"] = {
		prefix = "paladin",
		from = 49,
		to = 72
	},
	["perython_death"] = {
		prefix = "perython",
		from = 43,
		to = 60
	},
	["perython_idle"] = {
		prefix = "perython",
		from = 1,
		to = 1
	},
	["perython_shadow"] = {
		prefix = "perython",
		from = 61,
		to = 61
	},
	["perython_walk"] = {
		prefix = "perython",
		from = 1,
		to = 14
	},
	["perython_walkDown"] = {
		prefix = "perython",
		from = 15,
		to = 28
	},
	["perython_walkUp"] = {
		prefix = "perython",
		from = 29,
		to = 42
	},
	["quarry_worker_attack"] = {
		prefix = "quarry_worker",
		from = 68,
		to = 88
	},
	["quarry_worker_buriedIn"] = {
		prefix = "quarry_worker",
		from = 89,
		to = 132
	},
	["quarry_worker_buriedOut"] = {
		prefix = "quarry_worker",
		from = 133,
		to = 147
	},
	["quarry_worker_buriedWalk"] = {
		prefix = "quarry_worker",
		from = 148,
		to = 161
	},
	["quarry_worker_buriedWalkDown"] = {
		prefix = "quarry_worker",
		from = 176,
		to = 189
	},
	["quarry_worker_buriedWalkUp"] = {
		prefix = "quarry_worker",
		from = 162,
		to = 175
	},
	["quarry_worker_death"] = {
		prefix = "quarry_worker",
		from = 190,
		to = 210
	},
	["quarry_worker_idle"] = {
		prefix = "quarry_worker",
		from = 1,
		to = 1
	},
	["quarry_worker_walk"] = {
		prefix = "quarry_worker",
		from = 2,
		to = 23
	},
	["quarry_worker_walkDown"] = {
		prefix = "quarry_worker",
		from = 46,
		to = 67
	},
	["quarry_worker_walkUp"] = {
		prefix = "quarry_worker",
		from = 24,
		to = 45
	},
	["raider_attack"] = {
		prefix = "linirea_caravan_raider",
		from = 42,
		to = 66
	},
	["raider_death"] = {
		prefix = "linirea_caravan_raider",
		from = 101,
		to = 124
	},
	["raider_idle"] = {
		prefix = "linirea_caravan_raider",
		from = 1,
		to = 1
	},
	["raider_projectile_decal_run"] = {
		prefix = "linirea_caravan_raider_projectile_decal",
		from = 1,
		to = 10
	},
	["raider_range"] = {
		prefix = "linirea_caravan_raider",
		from = 67,
		to = 100
	},
	["raider_walk"] = {
		prefix = "linirea_caravan_raider",
		from = 2,
		to = 21
	},
	["raider_walkDown"] = {
		prefix = "linirea_caravan_raider",
		from = 22,
		to = 41
	},
	["ramp_idle"] = {
		prefix = "Stage5_ramp_pc",
		from = 1,
		to = 1
	},
	["ramp_run"] = {
		prefix = "Stage5_ramp_pc",
		from = 2,
		to = 25
	},
	["roots_cloud_tower_run"] = {
		prefix = "roots_cloud_tower",
		from = 1,
		to = 42
	},
	["roots_fog_tower_run"] = {
		prefix = "roots_fog_tower",
		from = 1,
		to = 32
	},
	["roots_holder_back_idle"] = {
		prefix = "roots_holder_back",
		from = 1,
		to = 1
	},
	["roots_holder_back_in"] = {
		prefix = "roots_holder_back",
		from = 2,
		to = 26
	},
	["roots_holder_back_out"] = {
		prefix = "roots_holder_back",
		from = 27,
		to = 49
	},
	["roots_holder_front_idle"] = {
		prefix = "roots_holder_front",
		from = 1,
		to = 24
	},
	["roots_holder_front_in"] = {
		prefix = "roots_holder_front",
		from = 25,
		to = 49
	},
	["roots_holder_front_out"] = {
		prefix = "roots_holder_front",
		from = 50,
		to = 72
	},
	["roots_tower_back_idle"] = {
		prefix = "roots_tower_back",
		from = 1,
		to = 1
	},
	["roots_tower_back_in"] = {
		prefix = "roots_tower_back",
		from = 2,
		to = 26
	},
	["roots_tower_back_out"] = {
		prefix = "roots_tower_back",
		from = 27,
		to = 49
	},
	["roots_tower_front_idle"] = {
		prefix = "roots_tower_front",
		from = 1,
		to = 1
	},
	["roots_tower_front_in"] = {
		prefix = "roots_tower_front",
		from = 2,
		to = 26
	},
	["roots_tower_front_out"] = {
		prefix = "roots_tower_front",
		from = 27,
		to = 48
	},
	["sand_mysthic_attack"] = {
		prefix = "sand_mysthic",
		from = 62,
		to = 82
	},
	["sand_mysthic_death"] = {
		prefix = "sand_mysthic",
		from = 178,
		to = 226
	},
	["sand_mysthic_heal"] = {
		prefix = "sand_mysthic",
		from = 118,
		to = 177
	},
	["sand_mysthic_healing_modifier_run"] = {
		prefix = "sand_mysthic_healing_modifier",
		from = 1,
		to = 24
	},
	["sand_mysthic_healing_run"] = {
		prefix = "sand_mysthic_healing",
		from = 1,
		to = 25
	},
	["sand_mysthic_idle"] = {
		prefix = "sand_mysthic",
		from = 1,
		to = 1
	},
	["sand_mysthic_range"] = {
		prefix = "sand_mysthic",
		from = 83,
		to = 117
	},
	["sand_mysthic_ray_explosion_run"] = {
		prefix = "sand_mysthic_ray_explosion",
		from = 1,
		to = 20
	},
	["sand_mysthic_ray_hit_run"] = {
		prefix = "sand_mysthic_ray_hit",
		from = 1,
		to = 20
	},
	["sand_mysthic_ray_travel"] = {
		prefix = "sand_mysthic_ray_projectile",
		from = 1,
		to = 13
	},
	["sand_mysthic_walk"] = {
		prefix = "sand_mysthic",
		from = 2,
		to = 21
	},
	["sand_mysthic_walkDown"] = {
		prefix = "sand_mysthic",
		from = 22,
		to = 41
	},
	["sand_mysthic_walkUp"] = {
		prefix = "sand_mysthic",
		from = 42,
		to = 61
	},
	["screecher_bat_attack"] = {
		prefix = "screecher_bat",
		from = 43,
		to = 71
	},
	["screecher_bat_death"] = {
		prefix = "screecher_bat",
		from = 72,
		to = 96
	},
	["screecher_bat_stun_modifier_run"] = {
		prefix = "screecher_bat_stun_modifier",
		from = 1,
		to = 15
	},
	["screecher_bat_walk"] = {
		prefix = "screecher_bat",
		from = 1,
		to = 14
	},
	["screecher_bat_walkDown"] = {
		prefix = "screecher_bat",
		from = 15,
		to = 28
	},
	["screecher_bat_walkUp"] = {
		prefix = "screecher_bat",
		from = 29,
		to = 42
	},
	["shatra_action"] = {
		prefix = "shatra_layer",
		from = 118,
		to = 141
	},
	["shatra_actionDeath"] = {
		prefix = "shatra_layer",
		from = 258,
		to = 281
	},
	["shatra_death"] = {
		prefix = "shatra_layer",
		from = 160,
		to = 231
	},
	["shatra_idle"] = {
		prefix = "shatra_layer",
		from = 2,
		to = 2
	},
	["shatra_idleDeath"] = {
		prefix = "shatra_layer",
		from = 232,
		to = 244
	},
	["shatra_idleFight"] = {
		prefix = "shatra_layer",
		from = 89,
		to = 117
	},
	["shatra_ship_ab_run"] = {
		prefix = "shatra_ship_layer",
		from = 150,
		to = 300
	},
	["shatra_ship_dr_run"] = {
		prefix = "shatra_ship_layer",
		from = 1,
		to = 149
	},
	["shatra_spawn"] = {
		prefix = "shatra_layer",
		from = 1,
		to = 88
	},
	["shatra_taunt"] = {
		prefix = "shatra_layer",
		from = 142,
		to = 159
	},
	["shatra_tauntDeath"] = {
		prefix = "shatra_layer",
		from = 245,
		to = 257
	},
	["ship_blackcorsair_layer_idle"] = {
		prefix = "ship_blackcorsair_layer",
		from = 1,
		to = 14
	},
	["ship_blackcorsair_layer_idleShip"] = {
		prefix = "ship_blackcorsair_layer",
		from = 63,
		to = 76
	},
	["ship_blackcorsair_layer_signal"] = {
		prefix = "ship_blackcorsair_layer",
		from = 15,
		to = 62
	},
	["ship_blackcorsair_layer_signalShip"] = {
		prefix = "ship_blackcorsair_layer",
		from = 77,
		to = 124
	},
	["ship_blackcorsair_layer_taunt"] = {
		prefix = "ship_blackcorsair_layer",
		from = 125,
		to = 136
	},
	["ship_cannons_blackcorsair_attack"] = {
		prefix = "ship_cannons_blackcorsair",
		from = 2,
		to = 36
	},
	["ship_cannons_blackcorsair_idle"] = {
		prefix = "ship_cannons_blackcorsair",
		from = 1,
		to = 1
	},
	["ship_cannonsback_blackcorsair_attack"] = {
		prefix = "ship_cannonsback_blackcorsair",
		from = 2,
		to = 38
	},
	["ship_cannonsback_blackcorsair_idle"] = {
		prefix = "ship_cannonsback_blackcorsair",
		from = 1,
		to = 1
	},
	["ship_closeDoor"] = {
		prefix = "Stage8_ship_puerta",
		from = 16,
		to = 25
	},
	["ship_escapes_blackcorsair_run"] = {
		prefix = "ship_escapes_blackcorsair",
		from = 113,
		to = 126
	},
	["ship_escapes_blackcorsair_start"] = {
		prefix = "ship_escapes_blackcorsair",
		from = 1,
		to = 112
	},
	["ship_loop"] = {
		prefix = "Stage8_ship",
		from = 1,
		to = 25
	},
	["ship_motor_blackcorsair_run"] = {
		prefix = "ship_motor_blackcorsair",
		from = 111,
		to = 119
	},
	["ship_motor_blackcorsair_start"] = {
		prefix = "ship_motor_blackcorsair",
		from = 1,
		to = 110
	},
	["ship_openDoor"] = {
		prefix = "Stage8_ship_puerta",
		from = 1,
		to = 15
	},
	["ship_rowings"] = {
		prefix = "Stage8_ship_remos",
		from = 1,
		to = 25
	},
	["ship_vela_blackcorsair_run"] = {
		prefix = "ship_vela_blackcorsair",
		from = 1,
		to = 16
	},
	["ship_water"] = {
		prefix = "Stage8_ship_water",
		from = 1,
		to = 16
	},
	["ship_water_blackcorsair_run"] = {
		prefix = "ship_water_blackcorsair",
		from = 1,
		to = 16
	},
	["smokebeard_engineer_attack"] = {
		prefix = "smokebeard_engineer",
		from = 68,
		to = 92
	},
	["smokebeard_engineer_death"] = {
		prefix = "smokebeard_engineer",
		from = 120,
		to = 133
	},
	["smokebeard_engineer_idle"] = {
		prefix = "smokebeard_engineer",
		from = 67,
		to = 67
	},
	["smokebeard_engineer_ray_hit_run"] = {
		prefix = "smokebeard_engineer_ray_hit",
		from = 1,
		to = 14
	},
	["smokebeard_engineer_ray_travel"] = {
		prefix = "smokebeard_engineer_ray",
		from = 1,
		to = 10
	},
	["smokebeard_engineer_repair"] = {
		prefix = "smokebeard_engineer",
		from = 93,
		to = 99
	},
	["smokebeard_engineer_repairEnd"] = {
		prefix = "smokebeard_engineer",
		from = 114,
		to = 119
	},
	["smokebeard_engineer_repairLoop"] = {
		prefix = "smokebeard_engineer",
		from = 100,
		to = 113
	},
	["smokebeard_engineer_walk"] = {
		prefix = "smokebeard_engineer",
		from = 1,
		to = 22
	},
	["smokebeard_engineer_walkDown"] = {
		prefix = "smokebeard_engineer",
		from = 45,
		to = 66
	},
	["smokebeard_engineer_walkUp"] = {
		prefix = "smokebeard_engineer",
		from = 23,
		to = 44
	},
	["snow_golem_attack"] = {
		prefix = "snow_golem",
		from = 122,
		to = 164
	},
	["snow_golem_bomb_explotion_run"] = {
		prefix = "snow_golem_bomb_explotion",
		from = 1,
		to = 36
	},
	["snow_golem_death"] = {
		prefix = "snow_golem",
		from = 165,
		to = 218
	},
	["snow_golem_idle"] = {
		prefix = "snow_golem",
		from = 219,
		to = 219
	},
	["snow_golem_idleGolem"] = {
		prefix = "snow_golem",
		from = 1,
		to = 1
	},
	["snow_golem_idleGolem_over"] = {
		prefix = "snow_golem",
		from = 1,
		to = 1
	},
	["snow_golem_preSpawn"] = {
		prefix = "snow_golem",
		from = 265,
		to = 300
	},
	["snow_golem_spawn"] = {
		prefix = "snow_golem",
		from = 220,
		to = 264
	},
	["snow_golem_walk"] = {
		prefix = "snow_golem",
		from = 2,
		to = 41
	},
	["snow_golem_walkDown"] = {
		prefix = "snow_golem",
		from = 42,
		to = 81
	},
	["snow_golem_walkUp"] = {
		prefix = "snow_golem",
		from = 82,
		to = 121
	},
	["sparks_works_doors_run"] = {
		prefix = "sparks_works_doors",
		from = 1,
		to = 18
	},
	["special_malagar_idle"] = {
		prefix = "special_malagar",
		from = 1,
		to = 24
	},
	["special_malagar_run"] = {
		prefix = "special_malagar",
		from = 25,
		to = 105
	},
	["special_spider_tower_babyspider_attack"] = {
		prefix = "special_spider_tower_babyspider",
		from = 10,
		to = 38
	},
	["special_spider_tower_babyspider_death"] = {
		prefix = "special_spider_tower_babyspider",
		from = 39,
		to = 59
	},
	["special_spider_tower_babyspider_idle"] = {
		prefix = "special_spider_tower_babyspider",
		from = 1,
		to = 1
	},
	["special_spider_tower_babyspider_walk"] = {
		prefix = "special_spider_tower_babyspider",
		from = 2,
		to = 9
	},
	["special_spider_tower_babyspider_running"] = {
		prefix = "special_spider_tower_babyspider",
		from = 2,
		to = 9
	},
	["special_spider_tower_egg_1_eggIn"] = {
		prefix = "special_spider_tower_egg_1",
		from = 1,
		to = 8
	},
	["special_spider_tower_egg_1_idleClosed"] = {
		prefix = "special_spider_tower_egg_1",
		from = 9,
		to = 9
	},
	["special_spider_tower_egg_1_idleOpened"] = {
		prefix = "special_spider_tower_egg_1",
		from = 36,
		to = 36
	},
	["special_spider_tower_egg_1_refill"] = {
		prefix = "special_spider_tower_egg_1",
		from = 37,
		to = 45
	},
	["special_spider_tower_egg_1_spawn"] = {
		prefix = "special_spider_tower_egg_1",
		from = 10,
		to = 35
	},
	["special_spider_tower_egg_2_eggIn"] = {
		prefix = "special_spider_tower_egg_2",
		from = 1,
		to = 6
	},
	["special_spider_tower_egg_2_idleClosed"] = {
		prefix = "special_spider_tower_egg_2",
		from = 7,
		to = 7
	},
	["special_spider_tower_egg_2_idleOpened"] = {
		prefix = "special_spider_tower_egg_2",
		from = 36,
		to = 36
	},
	["special_spider_tower_egg_2_refill"] = {
		prefix = "special_spider_tower_egg_2",
		from = 37,
		to = 45
	},
	["special_spider_tower_egg_2_spawn"] = {
		prefix = "special_spider_tower_egg_2",
		from = 8,
		to = 35
	},
	["special_spider_tower_egg_3_eggIn"] = {
		prefix = "special_spider_tower_egg_3",
		from = 1,
		to = 7
	},
	["special_spider_tower_egg_3_idleClosed"] = {
		prefix = "special_spider_tower_egg_3",
		from = 8,
		to = 8
	},
	["special_spider_tower_egg_3_idleOpened"] = {
		prefix = "special_spider_tower_egg_3",
		from = 35,
		to = 35
	},
	["special_spider_tower_egg_3_refill"] = {
		prefix = "special_spider_tower_egg_3",
		from = 36,
		to = 44
	},
	["special_spider_tower_egg_3_spawn"] = {
		prefix = "special_spider_tower_egg_3",
		from = 9,
		to = 34
	},
	["special_spider_tower_egg_4_eggIn"] = {
		prefix = "special_spider_tower_egg_4",
		from = 1,
		to = 5
	},
	["special_spider_tower_egg_4_idleClosed"] = {
		prefix = "special_spider_tower_egg_4",
		from = 6,
		to = 6
	},
	["special_spider_tower_egg_4_idleOpened"] = {
		prefix = "special_spider_tower_egg_4",
		from = 33,
		to = 33
	},
	["special_spider_tower_egg_4_refill"] = {
		prefix = "special_spider_tower_egg_4",
		from = 34,
		to = 42
	},
	["special_spider_tower_egg_4_spawn"] = {
		prefix = "special_spider_tower_egg_4",
		from = 7,
		to = 32
	},
	["special_spider_tower_egg_5_eggIn"] = {
		prefix = "special_spider_tower_egg_5",
		from = 1,
		to = 5
	},
	["special_spider_tower_egg_5_idleClosed"] = {
		prefix = "special_spider_tower_egg_5",
		from = 6,
		to = 6
	},
	["special_spider_tower_egg_5_idleOpened"] = {
		prefix = "special_spider_tower_egg_5",
		from = 33,
		to = 33
	},
	["special_spider_tower_egg_5_refill"] = {
		prefix = "special_spider_tower_egg_5",
		from = 34,
		to = 42
	},
	["special_spider_tower_egg_5_spawn"] = {
		prefix = "special_spider_tower_egg_5",
		from = 7,
		to = 32
	},
	["special_spider_tower_idle"] = {
		prefix = "special_spider_tower",
		from = 1,
		to = 1
	},
	["special_spider_tower_motherspider_layBackLeft"] = {
		prefix = "special_spider_tower_motherspider",
		from = 103,
		to = 128
	},
	["special_spider_tower_motherspider_layBackRight"] = {
		prefix = "special_spider_tower_motherspider",
		from = 129,
		to = 154
	},
	["special_spider_tower_motherspider_layFront"] = {
		prefix = "special_spider_tower_motherspider",
		from = 79,
		to = 102
	},
	["special_spider_tower_motherspider_layFrontLeft"] = {
		prefix = "special_spider_tower_motherspider",
		from = 27,
		to = 52
	},
	["special_spider_tower_motherspider_layFrontRight"] = {
		prefix = "special_spider_tower_motherspider",
		from = 53,
		to = 78
	},
	["special_spider_tower_motherspider_out"] = {
		prefix = "special_spider_tower_motherspider",
		from = 155,
		to = 175
	},
	["special_spider_tower_motherspider_spawn"] = {
		prefix = "special_spider_tower_motherspider",
		from = 1,
		to = 26
	},
	["special_spider_tower_web_special_in"] = {
		prefix = "special_spider_tower_web_special",
		from = 1,
		to = 11
	},
	["special_spider_tower_web_special_run"] = {
		prefix = "special_spider_tower_web_special",
		from = 12,
		to = 12
	},
	["stable_horse_1_idle"] = {
		prefix = "stable_horse_1",
		from = 1,
		to = 1
	},
	["stable_horse_1_run"] = {
		prefix = "stable_horse_1",
		from = 2,
		to = 43
	},
	["stable_horse_2_idle"] = {
		prefix = "stable_horse_2",
		from = 1,
		to = 1
	},
	["stable_horse_2_run"] = {
		prefix = "stable_horse_2",
		from = 2,
		to = 43
	},
	["stable_horse_3_idle"] = {
		prefix = "stable_horse_3",
		from = 1,
		to = 1
	},
	["stable_horse_3_run"] = {
		prefix = "stable_horse_3",
		from = 2,
		to = 43
	},
	["stable_idle"] = {
		prefix = "stable_layer",
		from = 1,
		to = 1
	},
	["stable_idle_over"] = {
		prefix = "stable_layer",
		from = 1,
		to = 1
	},
	["stable_run"] = {
		prefix = "stable_layer",
		from = 2,
		to = 9
	},
	["stage10_boneheart_bone_1_idle"] = {
		prefix = "Stage_10_boneheart_bone_1",
		from = 1,
		to = 1
	},
	["stage10_boneheart_bone_1_run"] = {
		prefix = "Stage_10_boneheart_bone_1",
		from = 2,
		to = 33
	},
	["stage10_boneheart_bone_2_glow"] = {
		prefix = "Stage_10_boneheart_bone_2",
		from = 2,
		to = 35
	},
	["stage10_boneheart_bone_2_idle"] = {
		prefix = "Stage_10_boneheart_bone_2",
		from = 1,
		to = 1
	},
	["stage10_boneheart_bone_2_run"] = {
		prefix = "Stage_10_boneheart_bone_2",
		from = 36,
		to = 95
	},
	["stage12_pumpkin_explode"] = {
		prefix = "Stage_12_pumpkin",
		from = 13,
		to = 34
	},
	["stage12_pumpkin_idle"] = {
		prefix = "Stage_12_pumpkin",
		from = 1,
		to = 1
	},
	["stage12_pumpkin_tap"] = {
		prefix = "Stage_12_pumpkin",
		from = 2,
		to = 12
	},
	["stage13_elf_arrow_decal_idle"] = {
		prefix = "stage13_elf_arrow_decal",
		from = 8,
		to = 8
	},
	["stage13_elf_arrow_decal_run"] = {
		prefix = "stage13_elf_arrow_decal",
		from = 1,
		to = 7
	},
	["stage13_elf_end"] = {
		prefix = "stage13_elf",
		from = 74,
		to = 86
	},
	["stage13_elf_idle"] = {
		prefix = "stage13_elf",
		from = 50,
		to = 50
	},
	["stage13_elf_look"] = {
		prefix = "stage13_elf",
		from = 13,
		to = 49
	},
	["stage13_elf_out"] = {
		prefix = "stage13_elf",
		from = 1,
		to = 12
	},
	["stage13_elf_shoot"] = {
		prefix = "stage13_elf",
		from = 51,
		to = 73
	},
	["stage13_elf_top_close"] = {
		prefix = "stage13_elf_top",
		from = 27,
		to = 45
	},
	["stage13_elf_top_idle"] = {
		prefix = "stage13_elf_top",
		from = 26,
		to = 26
	},
	["stage13_elf_top_open"] = {
		prefix = "stage13_elf_top",
		from = 1,
		to = 25
	},
	["stage13_floating_light_run"] = {
		prefix = "stage13_floating_light",
		from = 1,
		to = 186
	},
	["stage13_gummi_bears_gummi1"] = {
		prefix = "stage13_gummi_bears_layer",
		from = 42,
		to = 111
	},
	["stage13_gummi_bears_gummi1Eyes"] = {
		prefix = "stage13_gummi_bears_layer",
		from = 2,
		to = 41
	},
	["stage13_gummi_bears_gummi2"] = {
		prefix = "stage13_gummi_bears_layer",
		from = 145,
		to = 192
	},
	["stage13_gummi_bears_gummi2Eyes"] = {
		prefix = "stage13_gummi_bears_layer",
		from = 112,
		to = 144
	},
	["stage13_gummi_bears_gummi3"] = {
		prefix = "stage13_gummi_bears_layer",
		from = 231,
		to = 304
	},
	["stage13_gummi_bears_gummi3Eyes"] = {
		prefix = "stage13_gummi_bears_layer",
		from = 193,
		to = 230
	},
	["stage13_gummi_bears_idle"] = {
		prefix = "stage13_gummi_bears_layer",
		from = 1,
		to = 1
	},
	["stage13_lamp_idle"] = {
		prefix = "stage13_lamp",
		from = 1,
		to = 1
	},
	["stage13_lamp_on"] = {
		prefix = "stage13_lamp",
		from = 2,
		to = 33
	},
	["stage15_groot_call1"] = {
		prefix = "stage15_groot",
		from = 2,
		to = 40
	},
	["stage15_groot_call2"] = {
		prefix = "stage15_groot",
		from = 55,
		to = 101
	},
	["stage15_groot_dance"] = {
		prefix = "stage15_groot",
		from = 111,
		to = 136
	},
	["stage15_groot_idle1"] = {
		prefix = "stage15_groot",
		from = 1,
		to = 1
	},
	["stage15_groot_idle2"] = {
		prefix = "stage15_groot",
		from = 54,
		to = 54
	},
	["stage15_groot_to2"] = {
		prefix = "stage15_groot",
		from = 41,
		to = 53
	},
	["stage15_groot_toGroot"] = {
		prefix = "stage15_groot",
		from = 102,
		to = 110
	},
	["stage15_modos_flag_run"] = {
		prefix = "stage15_modos_flag",
		from = 1,
		to = 18
	},
	["stage15_modos_music_run"] = {
		prefix = "stage15_modos_music",
		from = 1,
		to = 23
	},
	["stage15_modos_tower_party_chair"] = {
		prefix = "stage15_modos_tower_party",
		from = 1,
		to = 1
	},
	["stage15_modos_tower_party_chori"] = {
		prefix = "stage15_modos_tower_party",
		from = 2,
		to = 2
	},
	["stage15_modos_tower_party_choriSmoke"] = {
		prefix = "stage15_modos_tower_party",
		from = 3,
		to = 29
	},
	["stage15_modos_tower_party_dance1"] = {
		prefix = "stage15_modos_tower_party",
		from = 71,
		to = 82
	},
	["stage15_modos_tower_party_dance2"] = {
		prefix = "stage15_modos_tower_party",
		from = 83,
		to = 106
	},
	["stage15_modos_tower_party_dance3"] = {
		prefix = "stage15_modos_tower_party",
		from = 107,
		to = 127
	},
	["stage15_modos_tower_party_idle"] = {
		prefix = "stage15_modos_tower_party",
		from = 30,
		to = 30
	},
	["stage15_modos_tower_party_mozo"] = {
		prefix = "stage15_modos_tower_party",
		from = 31,
		to = 70
	},
	["stage15_tent_flag_run"] = {
		prefix = "stage15_tent_flag",
		from = 1,
		to = 22
	},
	["stage15_tower_flag_run"] = {
		prefix = "stage15_tower_flag",
		from = 1,
		to = 22
	},
	["stage16_archer_arrow_decal_run"] = {
		prefix = "stage16_archer_arrow_decal",
		from = 1,
		to = 3
	},
	["stage16_archer_idle"] = {
		prefix = "stage16_archer",
		from = 1,
		to = 1
	},
	["stage16_archer_shoot"] = {
		prefix = "stage16_archer",
		from = 2,
		to = 22
	},
	["stage1_bridge_dirt_run"] = {
		prefix = "Stage1_bridge_dirt",
		from = 1,
		to = 6
	},
	["stage1_bridge_smoke_run"] = {
		prefix = "Stage1_bridge_smoke",
		from = 1,
		to = 15
	},
	["stage1_chain_left"] = {
		prefix = "Stage1_chainEngineLeft",
		from = 1,
		to = 15
	},
	["stage1_chain_leftIdle"] = {
		prefix = "Stage1_chainEngineLeft",
		from = 15,
		to = 15
	},
	["stage1_chain_loop"] = {
		prefix = "Stage1_chainLoop",
		from = 1,
		to = 6
	},
	["stage1_chain_right"] = {
		prefix = "Stage1_chainEngineRight",
		from = 1,
		to = 15
	},
	["stage1_chain_rightIdle"] = {
		prefix = "Stage1_chainEngineRight",
		from = 15,
		to = 15
	},
	["stage2_firepit_run"] = {
		prefix = "Stage2_firepit",
		from = 1,
		to = 12
	},
	["stage32_blacksmith_cast"] = {
		prefix = "blacksmith_achievement_layer",
		from = 19,
		to = 107
	},
	["stage32_blacksmith_idle"] = {
		prefix = "blacksmith_achievement_layer",
		from = 1,
		to = 18
	},
	["stage32_blacksmith_special"] = {
		prefix = "blacksmith_achievement_layer",
		from = 108,
		to = 219
	},
	["stage32_camp_flag_run"] = {
		prefix = "camp_flag",
		from = 1,
		to = 27
	},
	["stage32_canon_explotion_run"] = {
		prefix = "stage32_canon_explotion",
		from = 1,
		to = 23
	},
	["stage32_canon_idle"] = {
		prefix = "stage32_canon",
		from = 1,
		to = 1
	},
	["stage32_canon_run"] = {
		prefix = "stage32_canon",
		from = 2,
		to = 30
	},
	["stage32_canon_sign_run"] = {
		prefix = "stage32_canon_sign",
		from = 1,
		to = 64
	},
	["stage32_canon_target_run"] = {
		prefix = "stage32_canon_target",
		from = 1,
		to = 10
	},
	["stage32_firepit_run"] = {
		prefix = "firepit",
		from = 1,
		to = 18
	},
	["stage32_ships_flag_run"] = {
		prefix = "ships_flag",
		from = 1,
		to = 15
	},
	["stage34_sarcophagus_close"] = {
		prefix = "sarcophagus_tower_layer2",
		from = 19,
		to = 28
	},
	["stage34_sarcophagus_idle"] = {
		prefix = "sarcophagus_tower_layer2",
		from = 1,
		to = 1
	},
	["stage34_sarcophagus_loop"] = {
		prefix = "sarcophagus_tower_layer2",
		from = 18,
		to = 18
	},
	["stage34_sarcophagus_open"] = {
		prefix = "sarcophagus_tower_layer2",
		from = 1,
		to = 18
	},
	["stage34_sarcophagus_back_close"] = {
		prefix = "sarcophagus_tower_layer1",
		from = 19,
		to = 28
	},
	["stage34_sarcophagus_back_idle"] = {
		prefix = "sarcophagus_tower_layer1",
		from = 1,
		to = 1
	},
	["stage34_sarcophagus_back_loop"] = {
		prefix = "sarcophagus_tower_layer1",
		from = 18,
		to = 18
	},
	["stage34_sarcophagus_back_open"] = {
		prefix = "sarcophagus_tower_layer1",
		from = 1,
		to = 18
	},
	["stage35_fountain_run"] = {
		prefix = "deco_fountain",
		from = 1,
		to = 16
	},
	["Stage35_fountain_run"] = {
		prefix = "deco_fountain",
		from = 1,
		to = 16
	},
	["stage37_prop_animado_barril01_run"] = {
		prefix = "stage37_prop_animado_barril01",
		from = 1,
		to = 40
	},
	["stage37_prop_animado_barril02_run"] = {
		prefix = "stage37_prop_animado_barril02",
		from = 1,
		to = 40
	},
	["stage37_prop_animado_flag_run"] = {
		prefix = "stage37_prop_animado_flag",
		from = 1,
		to = 40
	},
	["stage37_prop_animado_pollo01_explode"] = {
		prefix = "stage37_prop_animado_pollo_death",
		from = 1,
		to = 30
	},
	["stage37_prop_animado_pollo01_run"] = {
		prefix = "stage37_prop_animado_pollo01",
		from = 1,
		to = 40
	},
	["stage37_prop_animado_pollo02_explode"] = {
		prefix = "stage37_prop_animado_pollo_death",
		from = 1,
		to = 30
	},
	["stage37_prop_animado_pollo02_run"] = {
		prefix = "stage37_prop_animado_pollo02",
		from = 1,
		to = 40
	},
	["stage37_prop_animado_tabla01_run"] = {
		prefix = "stage37_prop_animado_tabla01",
		from = 1,
		to = 40
	},
	["stage37_prop_animado_tabla02_run"] = {
		prefix = "stage37_prop_animado_tabla02",
		from = 1,
		to = 40
	},
	["stage37_prop_animado_water_flag_run"] = {
		prefix = "stage37_prop_animado_water_flag",
		from = 1,
		to = 40
	},
	["stage37_prop_animado_watership_run"] = {
		prefix = "stage37_prop_animado_watership",
		from = 1,
		to = 40
	},
	["stage38_cannon_attack"] = {
		prefix = "Stage38_canon_attack",
		from = 1,
		to = 17
	},
	["stage38_cannon_explotion_run"] = {
		prefix = "Stage38_canon_explotion",
		from = 1,
		to = 20
	},
	["stage38_cannon_in"] = {
		prefix = "Stage38_canon_in",
		from = 1,
		to = 30
	},
	["stage38_cannon_palmer_explotion_run"] = {
		prefix = "palmer_explotion",
		from = 1,
		to = 30
	},
	["stage38_cannon_patch_open"] = {
		prefix = "Stage38_canon",
		from = 1,
		to = 24
	},
	["stage38_cannon_patch_run"] = {
		prefix = "Stage38_canon",
		from = 1,
		to = 1
	},
	["stage38_cannon_run"] = {
		prefix = "Stage38_canon_in",
		from = 1,
		to = 1
	},
	["stage38_cannon_smoke_run"] = {
		prefix = "Stage38_canon_puff",
		from = 1,
		to = 15
	},
	["stage38_water_details_run"] = {
		prefix = "stage38_water_details",
		from = 1,
		to = 40
	},
	["stage38_waterfall_run"] = {
		prefix = "Stage38_waterfall",
		from = 1,
		to = 16
	},
	["stage3_firepit_run"] = {
		prefix = "Stage3_firepit",
		from = 1,
		to = 12
	},
	["stage41_burst_burst"] = {
		prefix = "stage_41_burst",
		from = 1,
		to = 22
	},
	["stage41_gold_idle"] = {
		prefix = "stage_41_gold",
		from = 17,
		to = 17
	},
	["stage41_gold_run"] = {
		prefix = "stage_41_gold",
		from = 1,
		to = 16
	},
	["stage7_fire_run"] = {
		prefix = "Stage7_fire",
		from = 1,
		to = 12
	},
	["stage7_water_run"] = {
		prefix = "Stage7_water",
		from = 1,
		to = 36
	},
	["stage8_fish_run"] = {
		prefix = "stage8_fish",
		from = 1,
		to = 35
	},
	["stage8_madagascar_penguins_fly"] = {
		prefix = "Stage8_penguins",
		from = 188,
		to = 233
	},
	["stage8_madagascar_penguins_idle"] = {
		prefix = "Stage8_penguins",
		from = 1,
		to = 1
	},
	["stage8_madagascar_penguins_look"] = {
		prefix = "Stage8_penguins",
		from = 58,
		to = 82
	},
	["stage8_madagascar_penguins_madagascar"] = {
		prefix = "Stage8_penguins",
		from = 83,
		to = 187
	},
	["stage8_madagascar_penguins_walk"] = {
		prefix = "Stage8_penguins",
		from = 2,
		to = 57
	},
	["stage8_penguins_dance"] = {
		prefix = "Stage8_big_penguin",
		from = 26,
		to = 63
	},
	["stage8_penguins_flutter"] = {
		prefix = "Stage8_big_penguin",
		from = 2,
		to = 25
	},
	["stage8_penguins_idle"] = {
		prefix = "Stage8_big_penguin",
		from = 1,
		to = 1
	},
	["stage8_penguins_look"] = {
		prefix = "Stage8_big_penguin",
		from = 64,
		to = 91
	},
	["stage8_penguins_walk"] = {
		prefix = "Stage8_big_penguin",
		from = 92,
		to = 120
	},
	["stage8_seal_clap"] = {
		prefix = "Stage8_seal",
		from = 2,
		to = 45
	},
	["stage8_seal_idle"] = {
		prefix = "Stage8_seal",
		from = 1,
		to = 1
	},
	["stage8_seal_in"] = {
		prefix = "Stage8_seal",
		from = 46,
		to = 99
	},
	["stage8_seal_out"] = {
		prefix = "Stage8_seal",
		from = 100,
		to = 118
	},
	["stage8_tiny_penguins_dance"] = {
		prefix = "Stage8_tiny_penguin",
		from = 26,
		to = 90
	},
	["stage8_tiny_penguins_flutter"] = {
		prefix = "Stage8_tiny_penguin",
		from = 2,
		to = 25
	},
	["stage8_tiny_penguins_idle"] = {
		prefix = "Stage8_tiny_penguin",
		from = 1,
		to = 1
	},
	["stage8_tiny_penguins_walk"] = {
		prefix = "Stage8_tiny_penguin",
		from = 91,
		to = 108
	},
	["stage_17_kermit_drink"] = {
		prefix = "stage_17_kermit",
		from = 2,
		to = 41
	},
	["stage_17_kermit_foot"] = {
		prefix = "stage_17_kermit",
		from = 42,
		to = 73
	},
	["stage_17_kermit_idle"] = {
		prefix = "stage_17_kermit",
		from = 1,
		to = 1
	},
	["stage_18_hypnotoad_death"] = {
		prefix = "stage_18_hypnotoad",
		from = 34,
		to = 64
	},
	["stage_18_hypnotoad_idle"] = {
		prefix = "stage_18_hypnotoad",
		from = 1,
		to = 1
	},
	["stage_18_hypnotoad_loop"] = {
		prefix = "stage_18_hypnotoad",
		from = 11,
		to = 33
	},
	["stage_18_hypnotoad_toLoop"] = {
		prefix = "stage_18_hypnotoad",
		from = 2,
		to = 10
	},
	["stage_19_pool_party_ball_run"] = {
		prefix = "Stage_19_pool_party_ball",
		from = 1,
		to = 35
	},
	["stage_19_pool_party_goblin_1_run"] = {
		prefix = "Stage_19_pool_party_goblin_1",
		from = 1,
		to = 35
	},
	["stage_19_pool_party_goblin_2_run"] = {
		prefix = "Stage_19_pool_party_goblin_2",
		from = 1,
		to = 30
	},
	["stage_19_pool_party_goblin_3_idle"] = {
		prefix = "Stage_19_pool_party_goblin_3",
		from = 1,
		to = 12
	},
	["stage_19_pool_party_goblin_3_run"] = {
		prefix = "Stage_19_pool_party_goblin_3",
		from = 13,
		to = 36
	},
	["stage_22_ice_explotion_run"] = {
		prefix = "stage_22_ice_explotion",
		from = 1,
		to = 16
	},
	["stage_22_ice_vertical_run"] = {
		prefix = "stage_22_ice_vertical",
		from = 1,
		to = 13
	},
	["stage_22_modes_goblin1_idle"] = {
		prefix = "stage_22_modes_goblin1",
		from = 1,
		to = 1
	},
	["stage_22_modes_goblin1_run"] = {
		prefix = "stage_22_modes_goblin1",
		from = 2,
		to = 24
	},
	["stage_22_modes_goblin2_idle"] = {
		prefix = "stage_22_modes_goblin2_layer",
		from = 1,
		to = 1
	},
	["stage_22_modes_goblin2_run"] = {
		prefix = "stage_22_modes_goblin2_layer",
		from = 2,
		to = 52
	},
	["stage_26_paper_run"] = {
		prefix = "stage_26_paper",
		from = 1,
		to = 36
	},
	["stage_26_slender_man_appear"] = {
		prefix = "stage_26_slender_man",
		from = 1,
		to = 16
	},
	["stage_26_slender_man_dissapear"] = {
		prefix = "stage_26_slender_man",
		from = 106,
		to = 121
	},
	["stage_26_slender_man_goOut"] = {
		prefix = "stage_26_slender_man",
		from = 61,
		to = 91
	},
	["stage_26_slender_man_hide"] = {
		prefix = "stage_26_slender_man",
		from = 42,
		to = 60
	},
	["stage_26_slender_man_loop"] = {
		prefix = "stage_26_slender_man",
		from = 17,
		to = 42
	},
	["stage_26_slender_man_loopOut"] = {
		prefix = "stage_26_slender_man",
		from = 92,
		to = 106
	},
	["stage_27_gill_man_all_attack"] = {
		prefix = "stage_27_gill_man_all_layer",
		from = 159,
		to = 203
	},
	["stage_27_gill_man_all_back"] = {
		prefix = "stage_27_gill_man_all_layer",
		from = 50,
		to = 67
	},
	["stage_27_gill_man_all_drink"] = {
		prefix = "stage_27_gill_man_all_layer",
		from = 19,
		to = 49
	},
	["stage_27_gill_man_all_hide"] = {
		prefix = "stage_27_gill_man_all_layer",
		from = 152,
		to = 157
	},
	["stage_27_gill_man_all_hold"] = {
		prefix = "stage_27_gill_man_all_layer",
		from = 158,
		to = 158
	},
	["stage_27_gill_man_all_idle"] = {
		prefix = "stage_27_gill_man_all_layer",
		from = 1,
		to = 2
	},
	["stage_27_gill_man_all_loop"] = {
		prefix = "stage_27_gill_man_all_layer",
		from = 134,
		to = 151
	},
	["stage_27_gill_man_all_prep"] = {
		prefix = "stage_27_gill_man_all_layer",
		from = 3,
		to = 18
	},
	["stage_27_gill_man_all_sale"] = {
		prefix = "stage_27_gill_man_all_layer",
		from = 68,
		to = 133
	},
	["stage_27_ripple_run"] = {
		prefix = "stage_27_ripple",
		from = 1,
		to = 30
	},
	["stage_28_eyes_init"] = {
		prefix = "stage_28_eyes",
		from = 1,
		to = 24
	},
	["stage_28_eyes_loop"] = {
		prefix = "stage_28_eyes",
		from = 25,
		to = 50
	},
	["stage_28_modifier_tower_loop"] = {
		prefix = "stage_28_modifier_tower",
		from = 1,
		to = 52
	},
	["stage_2_armadillo_idle"] = {
		prefix = "stage_2_armadillo",
		from = 1,
		to = 1
	},
	["stage_2_armadillo_idleBall"] = {
		prefix = "stage_2_armadillo",
		from = 83,
		to = 83
	},
	["stage_2_armadillo_toBall"] = {
		prefix = "stage_2_armadillo",
		from = 14,
		to = 82
	},
	["stage_2_armadillo_toIdle"] = {
		prefix = "stage_2_armadillo",
		from = 84,
		to = 101
	},
	["stage_2_armadillo_walk"] = {
		prefix = "stage_2_armadillo",
		from = 2,
		to = 13
	},
	["stage_3_cart_poke_effect_run"] = {
		prefix = "stage_3_cart_poke_effect",
		from = 1,
		to = 13
	},
	["stage_40_fire_torch_idle"] = {
		prefix = "stage_40_fire_torch",
		from = 1,
		to = 12
	},
	["stage_40_lightning_flash"] = {
		prefix = "stage_40_lightning",
		from = 19,
		to = 73
	},
	["stage_40_lightning_idle"] = {
		prefix = "stage_40_lightning",
		from = 1,
		to = 18
	},
	["stage_40_lightning_lightning"] = {
		prefix = "stage_40_lightning",
		from = 74,
		to = 102
	},
	["stage_7_mast_hit"] = {
		prefix = "stage_7_mast_layer",
		from = 2,
		to = 50
	},
	["stage_7_mast_idle"] = {
		prefix = "stage_7_mast_layer",
		from = 1,
		to = 1
	},
	["stage_7_skater_skaterHit"] = {
		prefix = "stage_7_skater",
		from = 1,
		to = 33
	},
	["stage_7_skater_skaterRun"] = {
		prefix = "stage_7_skater",
		from = 34,
		to = 83
	},
	["stage_9_fire_run"] = {
		prefix = "stage_9_fire",
		from = 1,
		to = 12
	},
	["stage_9_hodor_end"] = {
		prefix = "stage_9_hodor",
		from = 44,
		to = 69
	},
	["stage_9_hodor_idle"] = {
		prefix = "stage_9_hodor",
		from = 1,
		to = 1
	},
	["stage_9_hodor_idle2"] = {
		prefix = "stage_9_hodor",
		from = 22,
		to = 33
	},
	["stage_9_hodor_tap1"] = {
		prefix = "stage_9_hodor",
		from = 2,
		to = 11
	},
	["stage_9_hodor_tap2"] = {
		prefix = "stage_9_hodor",
		from = 12,
		to = 21
	},
	["stage_9_hodor_tap3"] = {
		prefix = "stage_9_hodor",
		from = 34,
		to = 43
	},
	["stonebeard_geomancer_attack"] = {
		prefix = "stonebeard_geomancer",
		from = 98,
		to = 122
	},
	["stonebeard_geomancer_death"] = {
		prefix = "stonebeard_geomancer",
		from = 139,
		to = 166
	},
	["stonebeard_geomancer_idle"] = {
		prefix = "stonebeard_geomancer",
		from = 1,
		to = 1
	},
	["stonebeard_geomancer_idleBlock"] = {
		prefix = "stonebeard_geomancer",
		from = 97,
		to = 97
	},
	["stonebeard_geomancer_toDwarf"] = {
		prefix = "stonebeard_geomancer",
		from = 123,
		to = 138
	},
	["stonebeard_geomancer_toStone"] = {
		prefix = "stonebeard_geomancer",
		from = 73,
		to = 96
	},
	["stonebeard_geomancer_walk"] = {
		prefix = "stonebeard_geomancer",
		from = 2,
		to = 25
	},
	["stonebeard_geomancer_walkDown"] = {
		prefix = "stonebeard_geomancer",
		from = 26,
		to = 49
	},
	["stonebeard_geomancer_walkUp"] = {
		prefix = "stonebeard_geomancer",
		from = 50,
		to = 72
	},
	["sulfur_alchemist_attack"] = {
		prefix = "sulfur_alchemist",
		from = 68,
		to = 96
	},
	["sulfur_alchemist_death"] = {
		prefix = "sulfur_alchemist",
		from = 157,
		to = 198
	},
	["sulfur_alchemist_heal_fx_run"] = {
		prefix = "sulfur_alchemist_heal_fx",
		from = 1,
		to = 25
	},
	["sulfur_alchemist_idle"] = {
		prefix = "sulfur_alchemist",
		from = 1,
		to = 1
	},
	["sulfur_alchemist_projectile_heal_hit_run"] = {
		prefix = "sulfur_alchemist_projectile_heal_hit",
		from = 1,
		to = 24
	},
	["sulfur_alchemist_projectile_hit_run"] = {
		prefix = "sulfur_alchemist_projectile_hit",
		from = 1,
		to = 10
	},
	["sulfur_alchemist_shoot"] = {
		prefix = "sulfur_alchemist",
		from = 97,
		to = 126
	},
	["sulfur_alchemist_shootPoison"] = {
		prefix = "sulfur_alchemist",
		from = 127,
		to = 156
	},
	["sulfur_alchemist_walk"] = {
		prefix = "sulfur_alchemist",
		from = 2,
		to = 23
	},
	["sulfur_alchemist_walkDown"] = {
		prefix = "sulfur_alchemist",
		from = 46,
		to = 67
	},
	["sulfur_alchemist_walkUp"] = {
		prefix = "sulfur_alchemist",
		from = 24,
		to = 45
	},
	["summonwater_run"] = {
		prefix = "summonwater",
		from = 1,
		to = 15
	},
	["svell_druid_attack"] = {
		prefix = "svell_druid",
		from = 74,
		to = 120
	},
	["svell_druid_attackRanged"] = {
		prefix = "svell_druid",
		from = 121,
		to = 172
	},
	["svell_druid_death"] = {
		prefix = "svell_druid",
		from = 217,
		to = 272
	},
	["svell_druid_idle"] = {
		prefix = "svell_druid",
		from = 1,
		to = 1
	},
	["svell_druid_proyectile_hit"] = {
		prefix = "svell_druid_proyectile",
		from = 2,
		to = 10
	},
	["svell_druid_proyectile_travel"] = {
		prefix = "svell_druid_proyectile",
		from = 1,
		to = 1
	},
	["svell_druid_special"] = {
		prefix = "svell_druid",
		from = 173,
		to = 216
	},
	["svell_druid_special_effect_run"] = {
		prefix = "svell_druid_special_effect",
		from = 1,
		to = 12
	},
	["svell_druid_tower_frost_end"] = {
		prefix = "svell_druid_tower_frost_layer",
		from = 19,
		to = 45
	},
	["svell_druid_tower_frost_layerX_end"] = {
		layer_to = 2,
		from = 19,
		layer_prefix = "svell_druid_tower_frost_layer%i",
		to = 45,
		layer_from = 1
	},
	["svell_druid_tower_frost_idle"] = {
		prefix = "svell_druid_tower_frost_layer",
		from = 16,
		to = 18
	},
	["svell_druid_tower_frost_layerX_idle"] = {
		layer_to = 2,
		from = 16,
		layer_prefix = "svell_druid_tower_frost_layer%i",
		to = 18,
		layer_from = 1
	},
	["svell_druid_tower_frost_start"] = {
		prefix = "svell_druid_tower_frost_layer",
		from = 1,
		to = 15
	},
	["svell_druid_tower_frost_layerX_start"] = {
		layer_to = 2,
		from = 1,
		layer_prefix = "svell_druid_tower_frost_layer%i",
		to = 15,
		layer_from = 1
	},
	["svell_druid_tower_frost_tap_effect_run"] = {
		prefix = "svell_druid_tower_frost_tap_effect",
		from = 1,
		to = 16
	},
	["svell_druid_walk"] = {
		prefix = "svell_druid",
		from = 2,
		to = 25
	},
	["svell_druid_walkDown"] = {
		prefix = "svell_druid",
		from = 26,
		to = 49
	},
	["svell_druid_walkUp"] = {
		prefix = "svell_druid",
		from = 50,
		to = 73
	},
	["taoist_stove_coin_run"] = {
		prefix = "taoist_stove_coin",
		from = 1,
		to = 36
	},
	["taoist_stove_layerX_cooldown"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "taoist_stove_layer%i",
		from = 1,
		to = 30
	},
	["taoist_stove_fx_run"] = {
		prefix = "taoist_stove_fx",
		from = 1,
		to = 49
	},
	["taoist_stove_particle_run"] = {
		prefix = "taoist_stove_particle",
		from = 1,
		to = 8
	},
	["taoist_stove_layerX_ready"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "taoist_stove_layer%i",
		from = 31,
		to = 54
	},
	["taoist_stove_layerX_shoot"] = {
		layer_from = 1,
		layer_to = 2,
		layer_prefix = "taoist_stove_layer%i",
		from = 55,
		to = 78
	},
	["taoist_stove_soul_run"] = {
		prefix = "taoist_stove_soul",
		from = 1,
		to = 8
	},
	["teleporter_decal_run"] = {
		prefix = "teleporter_decal",
		from = 1,
		to = 69
	},
	["teleporter_fx_run"] = {
		prefix = "teleporter_fx",
		from = 1,
		to = 37
	},
	["terminator_beBack"] = {
		prefix = "terminator_hand",
		from = 1,
		to = 17
	},
	["tinbeard_gunman_attack"] = {
		prefix = "tinbeard_gunman",
		from = 68,
		to = 82
	},
	["tinbeard_gunman_death"] = {
		prefix = "tinbeard_gunman",
		from = 201,
		to = 220
	},
	["tinbeard_gunman_idle"] = {
		prefix = "tinbeard_gunman",
		from = 1,
		to = 1
	},
	["tinbeard_gunman_proyectile_hit"] = {
		prefix = "tinbeard_gunman_proyectile",
		from = 2,
		to = 18
	},
	["tinbeard_gunman_proyectile_particle1_run"] = {
		prefix = "tinbeard_gunman_proyectile_particle1",
		from = 1,
		to = 12
	},
	["tinbeard_gunman_proyectile_particle2_run"] = {
		prefix = "tinbeard_gunman_proyectile_particle2",
		from = 1,
		to = 12
	},
	["tinbeard_gunman_proyectile_travel"] = {
		prefix = "tinbeard_gunman_proyectile",
		from = 1,
		to = 1
	},
	["tinbeard_gunman_shoot"] = {
		prefix = "tinbeard_gunman",
		from = 83,
		to = 122
	},
	["tinbeard_gunman_shootDown"] = {
		prefix = "tinbeard_gunman",
		from = 162,
		to = 200
	},
	["tinbeard_gunman_shootUp"] = {
		prefix = "tinbeard_gunman",
		from = 123,
		to = 161
	},
	["tinbeard_gunman_walk"] = {
		prefix = "tinbeard_gunman",
		from = 2,
		to = 23
	},
	["tinbeard_gunman_walkDown"] = {
		prefix = "tinbeard_gunman",
		from = 46,
		to = 67
	},
	["tinbeard_gunman_walkUp"] = {
		prefix = "tinbeard_gunman",
		from = 24,
		to = 45
	},
	["tower_hammerhold_barrack_close"] = {
		prefix = "hammerhold_barrack_layer1",
		from = 19,
		to = 31
	},
	["tower_hammerhold_barrack_idle"] = {
		prefix = "hammerhold_barrack_layer1",
		from = 2,
		to = 2
	},
	["tower_hammerhold_barrack_open"] = {
		prefix = "hammerhold_barrack_layer1",
		from = 3,
		to = 18
	},
	["tower_hammerhold_barrack_openIdle"] = {
		prefix = "hammerhold_barrack_layer1",
		from = 18,
		to = 18
	},
	["tower_hammerhold_barrack_openclose"] = {
		prefix = "hammerhold_barrack_layer1",
		from = 3,
		to = 32
	},
	["tower_hammerhold_barrack_back_close"] = {
		prefix = "hammerhold_barrack_layer2",
		from = 19,
		to = 31
	},
	["tower_hammerhold_barrack_back_idle"] = {
		prefix = "hammerhold_barrack_layer2",
		from = 2,
		to = 2
	},
	["tower_hammerhold_barrack_back_open"] = {
		prefix = "hammerhold_barrack_layer2",
		from = 3,
		to = 18
	},
	["tower_hammerhold_barrack_back_openIdle"] = {
		prefix = "hammerhold_barrack_layer2",
		from = 18,
		to = 18
	},
	["tower_hammerhold_barrack_back_openclose"] = {
		prefix = "hammerhold_barrack_layer2",
		from = 3,
		to = 32
	},
	["tower_shield_knight_attack"] = {
		prefix = "tower_shield_knight",
		from = 68,
		to = 91
	},
	["tower_shield_knight_death"] = {
		prefix = "tower_shield_knight",
		from = 93,
		to = 116
	},
	["tower_shield_knight_idle"] = {
		prefix = "tower_shield_knight",
		from = 1,
		to = 1
	},
	["tower_shield_knight_idleBlock"] = {
		prefix = "tower_shield_knight",
		from = 92,
		to = 92
	},
	["tower_shield_knight_walk"] = {
		prefix = "tower_shield_knight",
		from = 2,
		to = 23
	},
	["tower_shield_knight_walkDown"] = {
		prefix = "tower_shield_knight",
		from = 24,
		to = 45
	},
	["tower_shield_knight_walkUp"] = {
		prefix = "tower_shield_knight",
		from = 46,
		to = 67
	},
	["valkyrie_attack"] = {
		prefix = "valkyrie",
		from = 62,
		to = 85
	},
	["valkyrie_death"] = {
		prefix = "valkyrie",
		from = 86,
		to = 98
	},
	["valkyrie_idle"] = {
		prefix = "valkyrie",
		from = 1,
		to = 1
	},
	["valkyrie_summon"] = {
		prefix = "valkyrie",
		from = 99,
		to = 125
	},
	["valkyrie_walk"] = {
		prefix = "valkyrie",
		from = 2,
		to = 21
	},
	["valkyrie_walkDown"] = {
		prefix = "valkyrie",
		from = 22,
		to = 41
	},
	["valkyrie_walkUp"] = {
		prefix = "valkyrie",
		from = 42,
		to = 61
	},
	["veznan_cage_in"] = {
		prefix = "veznan_cage",
		from = 1,
		to = 19
	},
	["veznan_cage_loop"] = {
		prefix = "veznan_cage",
		from = 20,
		to = 60
	},
	["veznan_crystal_cooldown"] = {
		prefix = "veznan_crystal_layer",
		from = 2,
		to = 61
	},
	["veznan_crystal_hit_end_run"] = {
		prefix = "veznan_crystal_hit_end",
		from = 1,
		to = 8
	},
	["veznan_crystal_hit_start_run"] = {
		prefix = "veznan_crystal_hit_start",
		from = 1,
		to = 8
	},
	["veznan_crystal_ray_in"] = {
		prefix = "veznan_crystal_ray",
		from = 1,
		to = 3
	},
	["veznan_crystal_ray_out"] = {
		prefix = "veznan_crystal_ray",
		from = 11,
		to = 19
	},
	["veznan_crystal_ray_travel"] = {
		prefix = "veznan_crystal_ray",
		from = 4,
		to = 10
	},
	["veznan_crystal_ready"] = {
		prefix = "veznan_crystal_layer",
		from = 1,
		to = 1
	},
	["veznan_crystal_shoot"] = {
		prefix = "veznan_crystal_layer",
		from = 62,
		to = 65
	},
	["veznan_layer_charge1InGreen"] = {
		prefix = "veznan_layer",
		from = 52,
		to = 58
	},
	["veznan_layer_charge1InGreenWall"] = {
		prefix = "veznan_layer",
		from = 136,
		to = 141
	},
	["veznan_layer_charge1InRed"] = {
		prefix = "veznan_layer",
		from = 103,
		to = 109
	},
	["veznan_layer_charingGreenIdle"] = {
		prefix = "veznan_layer",
		from = 2,
		to = 15
	},
	["veznan_layer_charingRedIdle"] = {
		prefix = "veznan_layer",
		from = 156,
		to = 169
	},
	["veznan_layer_idle"] = {
		prefix = "veznan_layer",
		from = 1,
		to = 1
	},
	["veznan_layer_loop"] = {
		prefix = "veznan_layer",
		from = 28,
		to = 41
	},
	["veznan_layer_loopEnd"] = {
		prefix = "veznan_layer",
		from = 42,
		to = 51
	},
	["veznan_layer_loopIn"] = {
		prefix = "veznan_layer",
		from = 16,
		to = 27
	},
	["veznan_layer_outRed"] = {
		prefix = "veznan_layer",
		from = 124,
		to = 135
	},
	["veznan_layer_outShot"] = {
		prefix = "veznan_layer",
		from = 91,
		to = 102
	},
	["veznan_layer_readyLoop"] = {
		prefix = "veznan_layer",
		from = 59,
		to = 72
	},
	["veznan_layer_readyLoopGreen"] = {
		prefix = "veznan_layer",
		from = 142,
		to = 155
	},
	["veznan_layer_readyLoopRed"] = {
		prefix = "veznan_layer",
		from = 110,
		to = 123
	},
	["veznan_layer_shot"] = {
		prefix = "veznan_layer",
		from = 73,
		to = 90
	},
	["veznan_projectile_hit_decal_run"] = {
		prefix = "veznan_projectile_hit_decal",
		from = 1,
		to = 21
	},
	["veznan_projectile_hit_run"] = {
		prefix = "veznan_projectile_hit",
		from = 1,
		to = 21
	},
	["veznan_projectile_run"] = {
		prefix = "veznan_projectile",
		from = 1,
		to = 18
	},
	["veznan_teleporter_loop"] = {
		prefix = "veznan_teleporter",
		from = 1,
		to = 24
	},
	["veznan_teleporter_loopOut"] = {
		prefix = "veznan_teleporter",
		from = 59,
		to = 82
	},
	["veznan_teleporter_spawn"] = {
		prefix = "veznan_teleporter",
		from = 25,
		to = 58
	},
	["veznan_wall_smoke_run"] = {
		prefix = "veznan_wall_smoke",
		from = 1,
		to = 39
	},
	["viking_boss_arrow_decal_run"] = {
		prefix = "viking_boss_arrow_decal",
		from = 1,
		to = 11
	},
	["viking_boss_attack"] = {
		prefix = "viking_boss",
		from = 46,
		to = 93
	},
	["viking_boss_axe_decal_run"] = {
		prefix = "viking_boss_axe_decal",
		from = 1,
		to = 11
	},
	["viking_boss_climb"] = {
		prefix = "viking_boss",
		from = 162,
		to = 177
	},
	["viking_boss_dragon_breathIn"] = {
		prefix = "viking_boss_dragon_layer",
		from = 77,
		to = 90
	},
	["viking_boss_dragon_breathLoop"] = {
		prefix = "viking_boss_dragon_layer",
		from = 91,
		to = 100
	},
	["viking_boss_dragon_breathOut"] = {
		prefix = "viking_boss_dragon_layer",
		from = 102,
		to = 110
	},
	["viking_boss_dragon_breath_floor_run"] = {
		prefix = "viking_boss_dragon_breath_floor",
		from = 1,
		to = 10
	},
	["viking_boss_dragon_breath_hits_run"] = {
		prefix = "viking_boss_dragon_breath_hits",
		from = 1,
		to = 14
	},
	["viking_boss_dragon_breath_particle_travel"] = {
		prefix = "viking_boss_dragon_breath_particle",
		from = 1,
		to = 5
	},
	["viking_boss_dragon_front_breathIn"] = {
		prefix = "viking_boss_dragon_front",
		from = 77,
		to = 90
	},
	["viking_boss_dragon_front_breathLoop"] = {
		prefix = "viking_boss_dragon_front",
		from = 91,
		to = 100
	},
	["viking_boss_dragon_front_breathOut"] = {
		prefix = "viking_boss_dragon_front",
		from = 102,
		to = 110
	},
	["viking_boss_dragon_front_idle"] = {
		prefix = "viking_boss_dragon_front",
		from = 1,
		to = 1
	},
	["viking_boss_dragon_front_outFly"] = {
		prefix = "viking_boss_dragon_front",
		from = 32,
		to = 76
	},
	["viking_boss_dragon_front_toFly"] = {
		prefix = "viking_boss_dragon_front",
		from = 2,
		to = 13
	},
	["viking_boss_dragon_front_walk"] = {
		prefix = "viking_boss_dragon_front",
		from = 14,
		to = 31
	},
	["viking_boss_dragon_idle"] = {
		prefix = "viking_boss_dragon_layer",
		from = 1,
		to = 1
	},
	["viking_boss_dragon_outFly"] = {
		prefix = "viking_boss_dragon_layer",
		from = 32,
		to = 76
	},
	["viking_boss_dragon_rider_angry"] = {
		prefix = "viking_boss_dragon_rider",
		from = 152,
		to = 199
	},
	["viking_boss_dragon_rider_axeLoop"] = {
		prefix = "viking_boss_dragon_rider",
		from = 206,
		to = 215
	},
	["viking_boss_dragon_rider_breathIn"] = {
		prefix = "viking_boss_dragon_rider",
		from = 593,
		to = 606
	},
	["viking_boss_dragon_rider_breathLoop"] = {
		prefix = "viking_boss_dragon_rider",
		from = 607,
		to = 616
	},
	["viking_boss_dragon_rider_breathOut"] = {
		prefix = "viking_boss_dragon_rider",
		from = 618,
		to = 626
	},
	["viking_boss_dragon_rider_callBoss"] = {
		prefix = "viking_boss_dragon_rider",
		from = 285,
		to = 376
	},
	["viking_boss_dragon_rider_callWyverns"] = {
		prefix = "viking_boss_dragon_rider",
		from = 501,
		to = 577
	},
	["viking_boss_dragon_rider_curse_loop"] = {
		prefix = "viking_boss_dragon_rider",
		from = 122,
		to = 128
	},
	["viking_boss_dragon_rider_curse_out"] = {
		prefix = "viking_boss_dragon_rider",
		from = 146,
		to = 151
	},
	["viking_boss_dragon_rider_death"] = {
		prefix = "viking_boss_dragon_rider",
		from = 578,
		to = 592
	},
	["viking_boss_dragon_rider_horn"] = {
		prefix = "viking_boss_dragon_rider",
		from = 221,
		to = 263
	},
	["viking_boss_dragon_rider_idle"] = {
		prefix = "viking_boss_dragon_rider",
		from = 2,
		to = 2
	},
	["viking_boss_dragon_rider_outAxe"] = {
		prefix = "viking_boss_dragon_rider",
		from = 216,
		to = 220
	},
	["viking_boss_dragon_rider_outFly"] = {
		prefix = "viking_boss_dragon_rider",
		from = 15,
		to = 59
	},
	["viking_boss_dragon_rider_point"] = {
		prefix = "viking_boss_dragon_rider",
		from = 138,
		to = 145
	},
	["viking_boss_dragon_rider_stand"] = {
		prefix = "viking_boss_dragon_rider",
		from = 284,
		to = 284
	},
	["viking_boss_dragon_rider_talks"] = {
		prefix = "viking_boss_dragon_rider",
		from = 377,
		to = 500
	},
	["viking_boss_dragon_rider_throwAxe"] = {
		prefix = "viking_boss_dragon_rider",
		from = 60,
		to = 87
	},
	["viking_boss_dragon_rider_throwSpear"] = {
		prefix = "viking_boss_dragon_rider",
		from = 88,
		to = 115
	},
	["viking_boss_dragon_rider_to curse"] = {
		prefix = "viking_boss_dragon_rider",
		from = 116,
		to = 121
	},
	["viking_boss_dragon_rider_toAxe"] = {
		prefix = "viking_boss_dragon_rider",
		from = 200,
		to = 205
	},
	["viking_boss_dragon_rider_toFly"] = {
		prefix = "viking_boss_dragon_rider",
		from = 3,
		to = 14
	},
	["viking_boss_dragon_rider_toIdle"] = {
		prefix = "viking_boss_dragon_rider",
		from = 264,
		to = 284
	},
	["viking_boss_dragon_rider_to_point"] = {
		prefix = "viking_boss_dragon_rider",
		from = 129,
		to = 137
	},
	["viking_boss_dragon_rider_walk"] = {
		prefix = "viking_boss_dragon_rider",
		from = 1,
		to = 1
	},
	["viking_boss_dragon_toFly"] = {
		prefix = "viking_boss_dragon_layer",
		from = 2,
		to = 13
	},
	["viking_boss_dragon_walk"] = {
		prefix = "viking_boss_dragon_layer",
		from = 14,
		to = 31
	},
	["viking_boss_idle"] = {
		prefix = "viking_boss",
		from = 1,
		to = 1
	},
	["viking_boss_insult"] = {
		prefix = "viking_boss",
		from = 10,
		to = 45
	},
	["viking_boss_insult2"] = {
		prefix = "viking_boss",
		from = 94,
		to = 161
	},
	["viking_boss_spear_decal_run"] = {
		prefix = "viking_boss_spear_decal",
		from = 1,
		to = 11
	},
	["viking_boss_stairs_idle"] = {
		prefix = "viking_boss_stairs",
		from = 12,
		to = 12
	},
	["viking_boss_stairs_run"] = {
		prefix = "viking_boss_stairs",
		from = 1,
		to = 11
	},
	["viking_boss_walk"] = {
		prefix = "viking_boss",
		from = 2,
		to = 9
	},
	["war_elephant_archer_mount_idle"] = {
		prefix = "war_elephant_archer_mount_layer",
		from = 1,
		to = 1
	},
	["war_elephant_archer_unit_idle"] = {
		prefix = "war_elephant_archer_unit_layer",
		from = 1,
		to = 1
	},
	["war_elephant_archer_unit_range"] = {
		prefix = "war_elephant_archer_unit_layer",
		from = 2,
		to = 24
	},
	["war_elephant_archers_death"] = {
		prefix = "war_elephant_archers",
		from = 35,
		to = 71
	},
	["war_elephant_archers_idle"] = {
		prefix = "war_elephant_archers",
		from = 1,
		to = 1
	},
	["war_elephant_archers_walk"] = {
		prefix = "war_elephant_archers",
		from = 1,
		to = 34
	},
	["war_elephant_archers_walkDown"] = {
		prefix = "war_elephant_archers",
		from = 1,
		to = 34
	},
	["war_elephant_archers_walkUp"] = {
		prefix = "war_elephant_archers",
		from = 1,
		to = 34
	},
	["war_elephant_drummer_buff_unit_run"] = {
		prefix = "war_elephant_drummer_buff_unit",
		from = 1,
		to = 20
	},
	["war_elephant_drummer_death"] = {
		prefix = "war_elephant_drummer",
		from = 35,
		to = 71
	},
	["war_elephant_drummer_decal_run"] = {
		prefix = "war_elephant_drummer_decal",
		from = 1,
		to = 20
	},
	["war_elephant_drummer_idle"] = {
		prefix = "war_elephant_drummer",
		from = 1,
		to = 1
	},
	["war_elephant_drummer_only_idle"] = {
		prefix = "war_elephant_drummer_only_layer",
		from = 1,
		to = 25
	},
	["war_elephant_drummer_only_playIn"] = {
		prefix = "war_elephant_drummer_only_layer",
		from = 26,
		to = 33
	},
	["war_elephant_drummer_only_playLoop"] = {
		prefix = "war_elephant_drummer_only_layer",
		from = 34,
		to = 61
	},
	["war_elephant_drummer_only_playOut"] = {
		prefix = "war_elephant_drummer_only_layer",
		from = 62,
		to = 71
	},
	["war_elephant_drummer_walk"] = {
		prefix = "war_elephant_drummer",
		from = 1,
		to = 34
	},
	["war_elephant_drummer_walkDown"] = {
		prefix = "war_elephant_drummer",
		from = 1,
		to = 34
	},
	["war_elephant_drummer_walkUp"] = {
		prefix = "war_elephant_drummer",
		from = 1,
		to = 34
	},
	["war_wagon_dust_run"] = {
		prefix = "war_wagon_dust",
		from = 1,
		to = 10
	},
	["war_wagon_layerX_death"] = {
		layer_from = 1,
		layer_to = 11,
		layer_prefix = "war_wagon_layer%i",
		from = 57,
		to = 69
	},
	["war_wagon_layerX_downWalk"] = {
		layer_from = 1,
		layer_to = 11,
		layer_prefix = "war_wagon_layer%i",
		from = 43,
		to = 50
	},
	["war_wagon_layerX_downWalkIdle"] = {
		layer_from = 1,
		layer_to = 11,
		layer_prefix = "war_wagon_layer%i",
		from = 51,
		to = 56
	},
	["war_wagon_layerX_idle"] = {
		layer_from = 1,
		layer_to = 11,
		layer_prefix = "war_wagon_layer%i",
		from = 9,
		to = 14
	},
	["war_wagon_layerX_upWalk"] = {
		layer_from = 1,
		layer_to = 11,
		layer_prefix = "war_wagon_layer%i",
		from = 29,
		to = 36
	},
	["war_wagon_layerX_upWalkIdle"] = {
		layer_from = 1,
		layer_to = 11,
		layer_prefix = "war_wagon_layer%i",
		from = 37,
		to = 42
	},
	["war_wagon_layerX_walk"] = {
		layer_from = 1,
		layer_to = 11,
		layer_prefix = "war_wagon_layer%i",
		from = 1,
		to = 8
	},
	["war_wagon_layerX_walkDown"] = {
		layer_from = 1,
		layer_to = 11,
		layer_prefix = "war_wagon_layer%i",
		from = 43,
		to = 50
	},
	["war_wagon_layerX_walkDownIdle"] = {
		layer_from = 1,
		layer_to = 11,
		layer_prefix = "war_wagon_layer%i",
		from = 51,
		to = 56
	},
	["war_wagon_layerX_walkUp"] = {
		layer_from = 1,
		layer_to = 11,
		layer_prefix = "war_wagon_layer%i",
		from = 29,
		to = 36
	},
	["war_wagon_layerX_walkUpIdle"] = {
		layer_from = 1,
		layer_to = 11,
		layer_prefix = "war_wagon_layer%i",
		from = 37,
		to = 42
	},
	["war_wagon_spawn_dust_run"] = {
		prefix = "war_wagon_spawn_dust",
		from = 1,
		to = 14
	},
	["warhammer_guard_attack"] = {
		prefix = "warhammer_guard",
		from = 68,
		to = 90
	},
	["warhammer_guard_death"] = {
		prefix = "warhammer_guard",
		from = 91,
		to = 104
	},
	["warhammer_guard_idle"] = {
		prefix = "warhammer_guard",
		from = 1,
		to = 1
	},
	["warhammer_guard_walk"] = {
		prefix = "warhammer_guard",
		from = 2,
		to = 23
	},
	["warhammer_guard_walkDown"] = {
		prefix = "warhammer_guard",
		from = 46,
		to = 67
	},
	["warhammer_guard_walkUp"] = {
		prefix = "warhammer_guard",
		from = 24,
		to = 45
	},
	["watchdog_attack"] = {
		prefix = "watchdog",
		from = 32,
		to = 48
	},
	["watchdog_death"] = {
		prefix = "watchdog",
		from = 49,
		to = 70
	},
	["watchdog_idle"] = {
		prefix = "watchdog",
		from = 1,
		to = 1
	},
	["watchdog_walk"] = {
		prefix = "watchdog",
		from = 2,
		to = 11
	},
	["watchdog_walkDown"] = {
		prefix = "watchdog",
		from = 12,
		to = 21
	},
	["watchdog_walkUp"] = {
		prefix = "watchdog",
		from = 22,
		to = 31
	},
	["water_shine_run"] = {
		prefix = "water_shine",
		from = 1,
		to = 86
	},
	["water_sparks_loop"] = {
		prefix = "water_sparks",
		from = 1,
		to = 40
	},
	["water_sparks_run"] = {
		prefix = "water_sparks",
		from = 1,
		to = 85
	},
	["werewolf_attack"] = {
		prefix = "werewolf",
		from = 49,
		to = 72
	},
	["werewolf_death"] = {
		prefix = "werewolf",
		from = 73,
		to = 94
	},
	["werewolf_idle"] = {
		prefix = "werewolf",
		from = 1,
		to = 1
	},
	["werewolf_walk"] = {
		prefix = "werewolf",
		from = 2,
		to = 16
	},
	["werewolf_walkingRightLeft"] = {
		prefix = "werewolf",
		from = 2,
		to = 16
	},
	["werewolf_walkDown"] = {
		prefix = "werewolf",
		from = 33,
		to = 48
	},
	["werewolf_walkingDown"] = {
		prefix = "werewolf",
		from = 33,
		to = 48
	},
	["werewolf_walkUp"] = {
		prefix = "werewolf",
		from = 17,
		to = 32
	},
	["werewolf_walkingUp"] = {
		prefix = "werewolf",
		from = 17,
		to = 32
	},
	["winter_lord_attack"] = {
		prefix = "winter_lord",
		from = 146,
		to = 175
	},
	["winter_lord_death"] = {
		prefix = "winter_lord",
		from = 176,
		to = 225
	},
	["winter_lord_fisical_shield_in"] = {
		prefix = "winter_lord_fisical_shield_layer",
		from = 1,
		to = 32
	},
	["winter_lord_fisical_shield_loop"] = {
		prefix = "winter_lord_fisical_shield_layer",
		from = 33,
		to = 89
	},
	["winter_lord_fisical_shield_out"] = {
		prefix = "winter_lord_fisical_shield_layer",
		from = 90,
		to = 103
	},
	["winter_lord_hit_run"] = {
		prefix = "winter_lord_hit",
		from = 1,
		to = 10
	},
	["winter_lord_idle"] = {
		prefix = "winter_lord",
		from = 1,
		to = 1
	},
	["winter_lord_magic_shield_in"] = {
		prefix = "winter_lord_magic_shield_layer",
		from = 1,
		to = 24
	},
	["winter_lord_magic_shield_loop"] = {
		prefix = "winter_lord_magic_shield_layer",
		from = 25,
		to = 83
	},
	["winter_lord_magic_shield_out"] = {
		prefix = "winter_lord_magic_shield_layer",
		from = 84,
		to = 101
	},
	["winter_lord_modifier_run"] = {
		prefix = "winter_lord_modifier",
		from = 1,
		to = 20
	},
	["winter_lord_walk"] = {
		prefix = "winter_lord",
		from = 2,
		to = 49
	},
	["winter_lord_walkDown"] = {
		prefix = "winter_lord",
		from = 50,
		to = 97
	},
	["winter_lord_walkUp"] = {
		prefix = "winter_lord",
		from = 98,
		to = 145
	},
	["winter_queen_layerX_attack"] = {
		layer_to = 6,
		from = 27,
		layer_prefix = "winter_queen_layer%i",
		to = 65,
		layer_from = 1
	},
	["winter_queen_layerX_death"] = {
		layer_to = 6,
		from = 92,
		layer_prefix = "winter_queen_layer%i",
		to = 173,
		layer_from = 1
	},
	["winter_queen_layerX_freeze"] = {
		layer_to = 6,
		from = 66,
		layer_prefix = "winter_queen_layer%i",
		to = 91,
		layer_from = 1
	},
	["winter_queen_freeze_run"] = {
		prefix = "winter_queen_freeze",
		from = 1,
		to = 9
	},
	["winter_queen_icecube_run"] = {
		prefix = "winter_queen_icecube",
		from = 1,
		to = 28
	},
	["winter_queen_layerX_idle"] = {
		layer_to = 6,
		from = 174,
		layer_prefix = "winter_queen_layer%i",
		to = 174,
		layer_from = 1
	},
	["winter_queen_layerX_idleBreak"] = {
		layer_to = 6,
		from = 1,
		layer_prefix = "winter_queen_layer%i",
		to = 1,
		layer_from = 1
	},
	["winter_queen_layerX_taunt"] = {
		layer_to = 6,
		from = 179,
		layer_prefix = "winter_queen_layer%i",
		to = 188,
		layer_from = 1
	},
	["winter_queen_layerX_tauntIn"] = {
		layer_to = 6,
		from = 175,
		layer_prefix = "winter_queen_layer%i",
		to = 178,
		layer_from = 1
	},
	["winter_queen_layerX_tauntOut"] = {
		layer_to = 6,
		from = 189,
		layer_prefix = "winter_queen_layer%i",
		to = 190,
		layer_from = 1
	},
	["winter_queen_layerX_walk"] = {
		layer_to = 6,
		from = 1,
		layer_prefix = "winter_queen_layer%i",
		to = 26,
		layer_from = 1
	},
	["croud_HM_down_run"] = {prefix = "croud_HM_down", from = 1, to = 11},
	["croud_HM_left_run"] = {prefix = "croud_HM_left", from = 1, to = 11},
	["croud_HM_right_run"] = {prefix = "croud_HM_right", from = 1, to = 11},
	["croud_vez_down_run"] = {prefix = "croud_vez_down", from = 1, to = 11},
	["croud_vez_left_run"] = {prefix = "croud_vez_left", from = 1, to = 12},
	["croud_vez_right_run"] = {prefix = "croud_vez_right", from = 1, to = 12},
	["screecher_bat_idle"] = {prefix = "screecher_bat", from = 1, to = 14},
	["lord_of_afterlife_1_idle"] = {prefix = "lord_of_afterlife_1", from = 94, to = 111},
	["lord_of_afterlife_2_idle"] = {prefix = "lord_of_afterlife_2", from = 94, to = 111},
	["mirage_clon_walk"] = {prefix = "mirage_clon", from = 1, to = 1},
	["mirage_clon_walkUp"] = {prefix = "mirage_clon", from = 1, to = 1},
	["mirage_clon_walkDown"] = {prefix = "mirage_clon", from = 1, to = 1},
}

local function add_layered_animation(prefix, name, layer_from, layer_to, from, to)
	for layer = layer_from, layer_to do
		a[prefix .. layer .. "_" .. name] = {
			prefix = prefix .. layer,
			from = from,
			to = to
		}
	end
end

for _, cfg in ipairs({
	{"idle", 1, 44},
	{"talkLoop", 45, 53},
	{"attack", 54, 83},
	{"in", 84, 100},
	{"out", 101, 117},
	{"death", 118, 190}
}) do
	add_layered_animation("dragon_king_boss_layer", cfg[1], 1, 30, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"idle", 1, 6},
	{"outTail", 7, 51},
	{"inSlide", 52, 65},
	{"inHead", 66, 94},
	{"death", 95, 120}
}) do
	add_layered_animation("dragon_king_boss_body_layer", cfg[1], 1, 4, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"cooldown", 1, 30},
	{"ready", 31, 54},
	{"shoot", 55, 78}
}) do
	add_layered_animation("taoist_stove_layer", cfg[1], 1, 2, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"run", 1, 20}
}) do
	add_layered_animation("Stage12_windmill_layer", cfg[1], 1, 2, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"run", 1, 28},
	{"action", 29, 69}
}) do
	add_layered_animation("Stage14_light_layer", cfg[1], 1, 3, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"idle", 1, 16},
	{"walk", 1, 16},
	{"walkDown", 17, 32},
	{"walkUp", 33, 48},
	{"death", 49, 69}
}) do
	add_layered_animation("gryphon_layer", cfg[1], 1, 1, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"idle", 99, 230},
	{"eat", 231, 266},
	{"inactive", 1, 68},
	{"wakeUp", 69, 98}
}) do
	add_layered_animation("house_toad_layer", cfg[1], 1, 4, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"walk", 1, 36},
	{"action", 37, 58},
	{"emptyWalk", 59, 59}
}) do
	add_layered_animation("ladle_layer", cfg[1], 1, 2, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"idle", 1, 36},
	{"out", 37, 46},
	{"idleEmpty", 47, 82},
	{"in", 83, 92}
}) do
	add_layered_animation("ladle_cauldron_layer", cfg[1], 1, 3, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"idle", 1, 1},
	{"idleOut", 2, 20},
	{"blueIn", 21, 32},
	{"blueIdle", 33, 33},
	{"blueOut", 34, 51},
	{"orangeIn", 52, 64},
	{"orangeIdle", 65, 65},
	{"orangeOut", 66, 83},
	{"violetIn", 84, 96},
	{"violetIdle", 97, 97},
	{"violetOut", 98, 116},
	{"idleIn", 117, 126},
	{"idleClosed", 127, 127},
	{"open", 128, 137},
	{"block", 138, 159},
	{"blockLoop", 160, 189},
	{"blockEnd", 190, 193},
	{"shield", 194, 215},
	{"shieldLoop", 216, 245},
	{"shieldEnd", 246, 249},
	{"spoon", 250, 270},
	{"spoonLoop", 271, 300},
	{"spoonEnd", 301, 305}
}) do
	add_layered_animation("magnus_tower_layer", cfg[1], 1, 30, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"viking_boss_dragon_idle", 1, 1},
	{"viking_boss_dragon_toFly", 2, 13},
	{"viking_boss_dragon_walk", 14, 31},
	{"viking_boss_dragon_outFly", 32, 76},
	{"viking_boss_dragon_breathIn", 77, 90},
	{"viking_boss_dragon_breathLoop", 91, 100},
	{"viking_boss_dragon_breathOut", 102, 110}
}) do
	add_layered_animation("viking_boss_dragon_layer", cfg[1], 1, 1, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"Stage_11_boss_deco_idle1", 1, 1},
	{"Stage_11_boss_deco_idle2", 2, 2},
	{"Stage_11_boss_deco_idle3", 3, 3},
	{"Stage_11_boss_deco_run", 4, 32}
}) do
	add_layered_animation("Stage11_boss_deco_layer", cfg[1], 1, 2, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"Stage_11_cannon_shockSmoke", 1, 24},
	{"Stage_11_cannon_startcharge", 25, 84},
	{"Stage_11_cannon_loopcharge", 85, 94},
	{"Stage_11_cannon_endcharge", 95, 122},
	{"Stage_11_cannon_loopready", 123, 138},
	{"Stage_11_cannon_shoot", 139, 160},
	{"Stage_11_cannon_dead", 161, 173},
	{"Stage_11_cannon_loopdead", 174, 196},
	{"Stage_11_cannon_smokeIn", 197, 220},
	{"Stage_11_cannon_smokeOut", 221, 244},
	{"Stage_11_cannon_shock", 245, 268}
}) do
	add_layered_animation("Stage_11_cannon_layer", cfg[1], 1, 9, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"idle", 1, 1},
	{"run", 2, 9}
}) do
	add_layered_animation("blacksmith_layer", cfg[1], 1, 2, cfg[2], cfg[3])
	add_layered_animation("stable_layer", cfg[1], 1, 2, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"spawn", 1, 88},
	{"idle", 2, 2},
	{"idleFight", 89, 117},
	{"action", 118, 141},
	{"taunt", 142, 159},
	{"death", 160, 231},
	{"idleDeath", 232, 244},
	{"tauntDeath", 245, 257},
	{"actionDeath", 258, 281}
}) do
	add_layered_animation("shatra_layer", cfg[1], 1, 7, cfg[2], cfg[3])
end

for _, cfg in ipairs({
	{"dr_run", 1, 149},
	{"ab_run", 150, 300}
}) do
	add_layered_animation("shatra_ship_layer", cfg[1], 1, 4, cfg[2], cfg[3])
end

a["gold_coin_pile_idle"] = {
	prefix = "gold_coin",
	from = 1,
	to = 1
}
a["gold_coin_pile_death"] = {
	prefix = "gold_coin",
	from = 2,
	to = 2
}
a["gold_coin_pile_travel"] = {
	prefix = "nextwave_coin",
	from = 4,
	to = 4
}
a["gold_coin_pile_hit"] = {
	prefix = "nextwave_coin",
	from = 4,
	to = 4
}

-- KR4 scene animations retain every source layer; flat aliases stay available.
local scene_layers = {
	Stage_1_bilbo_layer = 2,
	cart_layer1 = 2,
	machine_spawner_layer = 14,
	Stage_7_cuerno_layer = 5,
	stage13_gummi_bears_layer = 4
}
local scene_aliases = {}
for name, animation in pairs(a) do
	for i = 1, scene_layers[animation.prefix] or 0 do
		local layered = table.deepclone(animation)
		layered.prefix = (animation.prefix == "cart_layer1" and "cart_layer" or animation.prefix) .. i
		scene_aliases["kr4_scene_layer" .. i .. "_" .. name] = layered
	end
end
for name, animation in pairs(scene_aliases) do a[name] = animation end

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/kr4_branch_campaigns.lua

-- BEGIN kr3/data/animations/kr4_enemy_sapos.lua
do
	local __chunk = (function()
return {
--水晶异蛇龙
	amphiptere_walk = {
		prefix = "amphiptere",
		to = 14,
		from = 1
	},
	amphiptere_raise = {
		prefix = "amphiptere",
		to = 14,
		from = 1
	},
	amphiptere_walkDown = {
		prefix = "amphiptere",
		to = 27,
		from = 15
	},
	amphiptere_walkUp = {
		prefix = "amphiptere",
		to = 41,
		from = 28
	},
	amphiptere_speedWalk = {
		prefix = "amphiptere",
		to = 65,
		from = 42
	},
	amphiptere_speedWalkDown = {
		prefix = "amphiptere",
		to = 89,
		from = 66
	},
	amphiptere_speedWalkUp = {
		prefix = "amphiptere",
		to = 113,
		from = 90
	},
	amphiptere_death = {
		prefix = "amphiptere",
		to = 129,
		from = 114
	},
--阿努瑞boss
	anurian_boss_crystals_run = {
		prefix = "anurian_boss_crystals",
		to = 40,
		from = 1
	},
	anurian_boss_drops_run = {
		prefix = "anurian_boss_drops",
		to = 16,
		from = 1
	},
	anurian_boss_teleport_run = {
		prefix = "anurian_boss_teleport",
		to = 33,
		from = 1
	},
	anurian_boss_teleport_back_run = {
		prefix = "anurian_boss_teleport_back",
		to = 33,
		from = 1
	},
	anurian_boss_water_run = {
		prefix = "anurian_boss_water",
		to = 14,
		from = 1
	},
--阿努瑞通灵师
	bullywags_channeler_idle = {
		prefix = "bullywags_channeler",
		to = 1,
		from = 1
	},
	bullywags_channeler_walk = {
		prefix = "bullywags_channeler",
		to = 21,
		from = 2
	},
	bullywags_channeler_walkDown = {
		prefix = "bullywags_channeler",
		to = 41,
		from = 22
	},
	bullywags_channeler_walkUp = {
		prefix = "bullywags_channeler",
		to = 61,
		from = 42
	},
	bullywags_channeler_attack = {
		prefix = "bullywags_channeler",
		to = 90,
		from = 62
	},
	bullywags_channeler_ranged = {
		prefix = "bullywags_channeler",
		to = 117,
		from = 91
	},
	bullywags_channeler_death = {
		prefix = "bullywags_channeler",
		to = 177,
		from = 118
	},
	bullywags_channeler_bolt_travel = {
		prefix = "bullywags_channeler_bolt",
		to = 1,
		from = 1
	},
	bullywags_channeler_bolt_flying = {
		prefix = "bullywags_channeler_bolt",
		to = 1,
		from = 1
	},
	bullywags_channeler_bolt_hit = {
		prefix = "bullywags_channeler_bolt",
		to = 8,
		from = 2
	},
	bullywags_channeler_upgrade_effect_particles_run = {
		prefix = "bullywags_channeler_upgrade_effect_particles",
		to = 40,
		from = 1
	},
--阿努瑞博学者
	bullywags_erudite_idle = {
		prefix = "bullywags_erudite",
		to = 24,
		from = 1
	},
	bullywags_erudite_walk = {
		prefix = "bullywags_erudite",
		to = 24,
		from = 1
	},
	bullywags_erudite_walkUp = {
		prefix = "bullywags_erudite",
		to = 48,
		from = 25
	},
	bullywags_erudite_walkDown = {
		prefix = "bullywags_erudite",
		to = 72,
		from = 49
	},
	bullywags_erudite_attack = {
		prefix = "bullywags_erudite",
		to = 99,
		from = 73
	},
	bullywags_erudite_ranged = {
		prefix = "bullywags_erudite",
		to = 123,
		from = 100
	},
	bullywags_erudite_death = {
		prefix = "bullywags_erudite",
		to = 179,
		from = 124
	},
	bullywags_erudite_bolt_in = {
		prefix = "bullywags_erudite_bolt",
		to = 41,
		from = 1
	},
	bullywags_erudite_bolt_idle = {
		prefix = "bullywags_erudite_bolt",
		to = 42,
		from = 42
	},
	bullywags_erudite_bolt_travel = {
		prefix = "bullywags_erudite_bolt",
		to = 43,
		from = 43
	},
	bullywags_erudite_bolt_flying = {
		prefix = "bullywags_erudite_bolt",
		to = 43,
		from = 43
	},
	bullywags_erudite_bolt_hit = {
		prefix = "bullywags_erudite_bolt",
		to = 52,
		from = 44
	},
	bullywags_erudite_bolt_upgraded_in = {
		prefix = "bullywags_erudite_bolt_upgraded",
		to = 41,
		from = 1
	},
	bullywags_erudite_bolt_upgraded_idle = {
		prefix = "bullywags_erudite_bolt_upgraded",
		to = 51,
		from = 42
	},
	bullywags_erudite_bolt_upgraded_travel = {
		prefix = "bullywags_erudite_bolt_upgraded",
		to = 61,
		from = 52
	},
	bullywags_erudite_bolt_upgraded_flying = {
		prefix = "bullywags_erudite_bolt_upgraded",
		to = 61,
		from = 52
	},
	bullywags_erudite_bolt_upgraded_hit = {
		prefix = "bullywags_erudite_bolt_upgraded",
		to = 70,
		from = 62
	},
	bullywags_erudite_hit_run = {
		prefix = "bullywags_erudite_hit",
		to = 11,
		from = 1
	},
--阿努瑞水晶人
	bullywags_golem_idle = {
		prefix = "bullywags_golem",
		to = 1,
		from = 1
	},
	bullywags_golem_walk = {
		prefix = "bullywags_golem",
		to = 59,
		from = 2
	},
	bullywags_golem_walkDown = {
		prefix = "bullywags_golem",
		to = 117,
		from = 60
	},
	bullywags_golem_walkUp = {
		prefix = "bullywags_golem",
		to = 175,
		from = 118
	},
	bullywags_golem_attack = {
		prefix = "bullywags_golem",
		to = 227,
		from = 176
	},
	bullywags_golem_death = {
		prefix = "bullywags_golem",
		to = 291,
		from = 228
	},
	bullywags_golem_hit_run = {
		prefix = "bullywags_golem_hit",
		to = 10,
		from = 1
	},
--阿努瑞追猎者
	chaser_idle = {
		prefix = "chaser",
		to = 1,
		from = 1
	},
	chaser_raise = {
		prefix = "chaser",
		to = 1,
		from = 1
	},
	chaser_walk = {
		prefix = "chaser",
		to = 11,
		from = 2
	},
	chaser_walkDown = {
		prefix = "chaser",
		to = 21,
		from = 12
	},
	chaser_walkUp = {
		prefix = "chaser",
		to = 31,
		from = 22
	},
	chaser_melee = {
		prefix = "chaser",
		to = 59,
		from = 32
	},
	chaser_jumpIn = {
		prefix = "chaser",
		to = 69,
		from = 60
	},
	chaser_loop = {
		prefix = "chaser",
		to = 70,
		from = 70
	},
	chaser_jumpOut = {
		prefix = "chaser",
		to = 93,
		from = 71
	},
	chaser_death = {
		prefix = "chaser",
		to = 111,
		from = 94
	},
	chaser_jump_hit_fx_run = {
		prefix = "chaser_jump_hit_fx",
		to = 9,
		from = 1
	},
--阿努瑞注魔师
	infuser_idle = {
		prefix = "infuser",
		to = 1,
		from = 1
	},
	infuser_raise = {
		prefix = "infuser",
		to = 1,
		from = 1
	},
	infuser_walk = {
		prefix = "infuser",
		to = 21,
		from = 2
	},
	infuser_walkDown = {
		prefix = "infuser",
		to = 41,
		from = 22
	},
	infuser_walkUp = {
		prefix = "infuser",
		to = 61,
		from = 42
	},
	infuser_melee = {
		prefix = "infuser",
		to = 86,
		from = 62
	},
	infuser_ranged = {
		prefix = "infuser",
		to = 112,
		from = 87
	},
	infuser_cast = {
		prefix = "infuser",
		to = 125,
		from = 113
	},
	infuser_cast_loop = {
		prefix = "infuser",
		to = 125,
		from = 125
	},
	infuser_cast_end = {
		prefix = "infuser",
		to = 138,
		from = 125
	},
	infuser_gemChargeStart = {
		prefix = "infuser",
		to = 152,
		from = 139
	},
	infuser_gemChargeLoop = {
		prefix = "infuser",
		to = 153,
		from = 153
	},
	infuser_gemChargeEnd = {
		prefix = "infuser",
		to = 166,
		from = 154
	},
	infuser_death = {
		prefix = "infuser",
		to = 188,
		from = 167
	},
	infuser_bolt_travel = {
		prefix = "infuser_bolt",
		to = 1,
		from = 1
	},
	infuser_bolt_flying = {
		prefix = "infuser_bolt",
		to = 1,
		from = 1
	},
	infuser_bolt_hit = {
		prefix = "infuser_bolt",
		to = 8,
		from = 2
	},
	infuser_cast_ray_travel = {
		prefix = "infuser_cast_ray",
		to = 14,
		from = 1
	},
	infuser_cast_ray_flying = {
		prefix = "infuser_cast_ray",
		to = 14,
		from = 1
	},
	infuser_cast_ray_flying_crystal = {
		prefix = "infuser_cast_ray",
		to = 14,
		from = 1
	},
	infuser_gem_ray_travel = {
		prefix = "infuser_gem_ray",
		to = 8,
		from = 1
	},
	infuser_gem_ray_flying = {
		prefix = "infuser_gem_ray",
		to = 8,
		from = 1
	},
	infuser_gem_ray_hit_run = {
		prefix = "infuser_gem_ray_hit",
		to = 24,
		from = 1
	},
--阿努瑞看守者
	warden_idle = {
		prefix = "warden",
		to = 1,
		from = 1
	},
	warden_walk = {
		prefix = "warden",
		to = 25,
		from = 2
	},
	warden_walkDown = {
		prefix = "warden",
		to = 49,
		from = 26
	},
	warden_walkUp = {
		prefix = "warden",
		to = 73,
		from = 50
	},
	warden_hit = {
		prefix = "warden",
		to = 105,
		from = 74
	},
	warden_death = {
		prefix = "warden",
		to = 129,
		from = 106
	},
	warden_shield_in = {
		prefix = "warden_shield",
		to = 8,
		from = 1
	},
	warden_shield_loop = {
		prefix = "warden_shield",
		to = 24,
		from = 9
	},
	warden_shield_out = {
		prefix = "warden_shield",
		to = 32,
		from = 25
	},
}
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/kr4_enemy_sapos.lua

-- BEGIN kr3/data/animations/kr4_hero_isfet.lua
do
	local __chunk = (function()
return {
	hero_isfet_idle = {
		prefix = "hero_isfet_layer1",
		to = 20,
		from = 1
	},
	hero_isfet_walk = {
		prefix = "hero_isfet_layer1",
		to = 46,
		from = 21
	},
	hero_isfet_attack = {
		prefix = "hero_isfet_layer1",
		to = 73,
		from = 47
	},
	hero_isfet_rangedAttack = {
		prefix = "hero_isfet_layer1",
		to = 117,
		from = 74
	},
	hero_isfet_specialFrog = {
		prefix = "hero_isfet_layer1",
		to = 164,
		from = 118
	},
	hero_isfet_specialBlood = {
		prefix = "hero_isfet_layer1",
		to = 198,
		from = 165
	},
	hero_isfet_specialCloud = {
		prefix = "hero_isfet_layer1",
		to = 270,
		from = 199
	},
	hero_isfet_specialFirestormIn = {
		prefix = "hero_isfet_layer1",
		to = 282,
		from = 271
	},
	hero_isfet_specialFirestormLoop = {
		prefix = "hero_isfet_layer1",
		to = 317,
		from = 283
	},
	hero_isfet_specialFirestormOut = {
		prefix = "hero_isfet_layer1",
		to = 338,
		from = 318
	},
	hero_isfet_levelup = {
		prefix = "hero_isfet_layer1",
		to = 364,
		from = 339
	},
	hero_isfet_death = {
		prefix = "hero_isfet_layer1",
		to = 465,
		from = 365
	},
	hero_isfet_deathIdle = {
		prefix = "hero_isfet_layer1",
		to = 466,
		from = 466
	},
	hero_isfet_respawn = {
		prefix = "hero_isfet_layer1",
		to = 531,
		from = 467
	},
	hero_isfet_smoke_run = {
		prefix = "hero_isfet_smoke",
		to = 21,
		from = 1
	},
	hero_isfet_cloud_spawn = {
		prefix = "hero_isfet_cloud",
		to = 6,
		from = 1
	},
	hero_isfet_cloud_idle = {
		prefix = "hero_isfet_cloud",
		to = 24,
		from = 7
	},
	hero_isfet_cloud_walk = {
		prefix = "hero_isfet_cloud",
		to = 24,
		from = 7
	},
	hero_isfet_cloud_death = {
		prefix = "hero_isfet_cloud",
		to = 35,
		from = 25
	},
	hero_isfet_cloud_modifier_init = {
		prefix = "hero_isfet_cloud_modifier",
		to = 5,
		from = 1
	},
	hero_isfet_cloud_modifier_loop = {
		prefix = "hero_isfet_cloud_modifier",
		to = 21,
		from = 6
	},
	hero_isfet_cloud_modifier_end = {
		prefix = "hero_isfet_cloud_modifier",
		to = 35,
		from = 22
	},
	hero_isfet_blood_modifier_init = {
		prefix = "hero_isfet_blood_modifier",
		to = 3,
		from = 1
	},
	hero_isfet_blood_modifier_loop = {
		prefix = "hero_isfet_blood_modifier",
		to = 27,
		from = 4
	},
	hero_isfet_blood_modifier_end = {
		prefix = "hero_isfet_blood_modifier",
		to = 40,
		from = 28
	},
	hero_isfet_bolt_travel = {
		prefix = "hero_isfet_bolt",
		to = 3,
		from = 1
	},
	hero_isfet_bolt_flying = {
		prefix = "hero_isfet_bolt",
		to = 3,
		from = 1
	},
	hero_isfet_bolt_hit = {
		prefix = "hero_isfet_bolt",
		to = 10,
		from = 4
	},
	hero_isfet_frog_idle = {
		prefix = "hero_isfet_frog",
		to = 1,
		from = 1
	},
	hero_isfet_frog_talk = {
		prefix = "hero_isfet_frog",
		to = 19,
		from = 2
	},
	hero_isfet_frog_walk = {
		prefix = "hero_isfet_frog",
		to = 33,
		from = 20
	},
	hero_isfet_frog_death = {
		prefix = "hero_isfet_frog",
		to = 45,
		from = 34
	},
	hero_isfet_frog_smoke_run = {
		prefix = "hero_isfet_frog_smoke",
		to = 21,
		from = 1
	},
	hero_isfet_blood_bubble_run = {
		prefix = "hero_isfet_blood_bubble",
		to = 35,
		from = 1
	},
	hero_isfet_mummy_spawn = {
		prefix = "hero_isfet_mummy",
		to = 177,
		from = 149
	},
	hero_isfet_mummy_idle = {
		prefix = "hero_isfet_mummy",
		to = 1,
		from = 1
	},
	hero_isfet_mummy_walk = {
		prefix = "hero_isfet_mummy",
		to = 29,
		from = 2
	},
	hero_isfet_mummy_walkUp = {
		prefix = "hero_isfet_mummy",
		to = 77,
		from = 54
	},
	hero_isfet_mummy_walkDown = {
		prefix = "hero_isfet_mummy",
		to = 53,
		from = 30
	},
	hero_isfet_mummy_melee = {
		prefix = "hero_isfet_mummy",
		to = 107,
		from = 78
	},
	hero_isfet_mummy_death = {
		prefix = "hero_isfet_mummy",
		to = 148,
		from = 108
	},
	hero_isfet_fireice_fire_explotion_run = {
		prefix = "hero_isfet_fireice_fire_explotion",
		to = 24,
		from = 1
	},
	hero_isfet_fireice_ice_decal_run = {
		prefix = "hero_isfet_fireice_ice_decal",
		to = 13,
		from = 1
	},
	hero_isfet_fireice_ice_explotion_run = {
		prefix = "hero_isfet_fireice_ice_explotion",
		to = 24,
		from = 1
	},
	hero_isfet_fireice_ice_particle2_run = {
		prefix = "hero_isfet_fireice_ice_particle2",
		to = 23,
		from = 1
	},
	hero_isfet_fireice_ice_particle_run = {
		prefix = "hero_isfet_fireice_ice_particle",
		to = 23,
		from = 1
	},
	hero_isfet_fireice_ice_rocks_run = {
		prefix = "hero_isfet_fireice_ice_rocks",
		to = 33,
		from = 1
	},
	hero_isfet_fireice_fire_particle2_run = {
		prefix = "hero_isfet_fireice_fire_particle2",
		to = 23,
		from = 1
	},
	hero_isfet_fireice_fire_particle_run = {
		prefix = "hero_isfet_fireice_fire_particle",
		to = 23,
		from = 1
	},
	hero_isfet_fireice_fire_rocks_run = {
		prefix = "hero_isfet_fireice_fire_rocks",
		to = 33,
		from = 1
	},
	hero_isfet_frog_ray_travel = {
		prefix = "hero_isfet_frog_ray",
		to = 18,
		from = 1
	},
	hero_isfet_storm_clouds_in = {
		prefix = "hero_isfet_storm_clouds",
		to = 14,
		from = 1
	},
	hero_isfet_storm_clouds_run = {
		prefix = "hero_isfet_storm_clouds",
		to = 74,
		from = 15
	},
	hero_isfet_storm_clouds_out = {
		prefix = "hero_isfet_storm_clouds",
		to = 95,
		from = 75
	},
	hero_isfet_storm_lightning_travel = {
		prefix = "hero_isfet_storm_lightning",
		to = 18,
		from = 1
	},
	hero_isfet_storm_lightning_hit_run = {
		prefix = "hero_isfet_storm_lightning_hit",
		to = 10,
		from = 1
	},
	hero_isfet_storm_lightning_modifier_run = {
		prefix = "hero_isfet_storm_lightning_modifier",
		to = 6,
		from = 1
	},
}
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/kr4_hero_isfet.lua

-- BEGIN kr3/data/animations/kr4_hero_jigou.lua
do
	local __chunk = (function()
return {
	hero_jigou_idle = {
		prefix = "hero_jigou",
		to = 1,
		from = 1
	},
	hero_jigou_walk = {
		prefix = "hero_jigou",
		to = 25,
		from = 2
	},
	hero_jigou_running = {
		prefix = "hero_jigou",
		to = 25,
		from = 2
	},
	hero_jigou_attack = {
		prefix = "hero_jigou",
		to = 55,
		from = 26
	},
	hero_jigou_iceShard = {
		prefix = "hero_jigou",
		to = 105,
		from = 56
	},
	hero_jigou_shoot = { --1技能
		prefix = "hero_jigou",
		to = 105,
		from = 56
	},
	hero_jigou_frozenBreath = { --2技能
		prefix = "hero_jigou",
		to = 138,
		from = 106
	},
	hero_jigou_iceland = { --3技能
		prefix = "hero_jigou",
		to = 162,
		from = 139
	},
	hero_jigou_igloo_start = { --4技能蹲下
		prefix = "hero_jigou",
		to = 200,
		from = 163
	},
	hero_jigou_igloo_loop = { --4技能静态
		prefix = "hero_jigou",
		to = 201,
		from = 201
	},
	hero_jigou_igloo_end = {
		prefix = "hero_jigou",
		to = 1,
		from = 1
	},
	hero_jigou_death = {
		prefix = "hero_jigou",
		to = 236,
		from = 202
	},
	hero_jigou_levelup = {
		prefix = "hero_jigou",
		to = 276,
		from = 237
	},
	hero_jigou_respawn = {
		prefix = "hero_jigou",
		to = 276,
		from = 237
	},
	hero_jigou_specialIn = { --3技能开始
		prefix = "hero_jigou",
		to = 286,
		from = 277
	},
	hero_jigou_specialLoop = { --3技能循环
		prefix = "hero_jigou",
		to = 299,
		from = 287
	},
	hero_jigou_specialOut = { --3技能出
		prefix = "hero_jigou",
		to = 303,
		from = 300
	},
	hero_jigou_attack_fx_run = {
		prefix = "hero_jigou_attack_fx",
		to = 10,
		from = 1
	},
	hero_jigou_frozen_breath_fx1_run = {
		prefix = "hero_jigou_frozen_breath_fx",
		to = 27,
		from = 1
	},
	hero_jigou_frozen_breath_fx2_run = {
		prefix = "hero_jigou_frozen_breath_fx",
		to = 27,
		from = 1
	},
	hero_jigou_frozen_breath_fx3_run = {
		prefix = "hero_jigou_frozen_breath_fx",
		to = 27,
		from = 1
	},
	hero_jigou_frozen_breath_fx_start = {
		prefix = "hero_jigou_frozen_breath_fx",
		to = 27,
		from = 1
	},
	hero_jigou_iceshard_hit_run = {
		prefix = "hero_jigou_iceshard_hit",
		to = 39,
		from = 1
	},
	hero_jigou_igloo_end_run = {
		prefix = "hero_jigou_igloo_end",
		to = 24,
		from = 1
	},
	hero_jigou_special_dust_run = {
		prefix = "hero_jigou_special_dust",
		to = 11,
		from = 1
	},
	hero_jigou_special_effect_run = {
		prefix = "hero_jigou_special_effect",
		to = 11,
		from = 1
	},
	--极狗大招冰晶
	hero_jigou_ultimate_ice_shards_1 = {
		prefix = "hero_jigou_ultimate_ice_shards_1",
		to = 32,
		from = 1
	},
	hero_jigou_ultimate_ice_shards_2 = {
		prefix = "hero_jigou_ultimate_ice_shards_2",
		to = 20,
		from = 1
	},
	hero_jigou_ultimate_ice_shards_3 = {
		prefix = "hero_jigou_ultimate_ice_shards_3",
		to = 32,
		from = 1
	},
	hero_jigou_ultimate_ice_shards_4 = {
		prefix = "hero_jigou_ultimate_ice_shards_4",
		to = 27,
		from = 1
	},
	hero_jigou_ultimate_ice_shards_1_in = {
		prefix = "hero_jigou_ultimate_ice_shards_1",
		to = 18,
		from = 1
	},
	hero_jigou_ultimate_ice_shards_1_run = {
		prefix = "hero_jigou_ultimate_ice_shards_1",
		to = 19,
		from = 19
	},
	hero_jigou_ultimate_ice_shards_1_out = {
		prefix = "hero_jigou_ultimate_ice_shards_1",
		to = 32,
		from = 20
	},
	hero_jigou_ultimate_ice_shards_2_in = {
		prefix = "hero_jigou_ultimate_ice_shards_2",
		to = 8,
		from = 1
	},
	hero_jigou_ultimate_ice_shards_2_run = {
		prefix = "hero_jigou_ultimate_ice_shards_2",
		to = 9,
		from = 9
	},
	hero_jigou_ultimate_ice_shards_2_out = {
		prefix = "hero_jigou_ultimate_ice_shards_2",
		to = 20,
		from = 10
	},
	hero_jigou_ultimate_ice_shards_3_in = {
		prefix = "hero_jigou_ultimate_ice_shards_3",
		to = 20,
		from = 1
	},
	hero_jigou_ultimate_ice_shards_3_run = {
		prefix = "hero_jigou_ultimate_ice_shards_3",
		to = 21,
		from = 21
	},
	hero_jigou_ultimate_ice_shards_3_out = {
		prefix = "hero_jigou_ultimate_ice_shards_3",
		to = 32,
		from = 22
	},
	hero_jigou_ultimate_ice_shards_4_in = {
		prefix = "hero_jigou_ultimate_ice_shards_4",
		to = 13,
		from = 1
	},
	hero_jigou_ultimate_ice_shards_4_run = {
		prefix = "hero_jigou_ultimate_ice_shards_4",
		to = 14,
		from = 14
	},
	hero_jigou_ultimate_ice_shards_4_out = {
		prefix = "hero_jigou_ultimate_ice_shards_4",
		to = 27,
		from = 15
	},
}
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/kr4_hero_jigou.lua

-- BEGIN kr3/data/animations/kr4_hero_margosa.lua
do
	local __chunk = (function()
return {
	hero_lady_margosa_idle = {
		prefix = "hero_lady_margosa",
		to = 22,
		from = 1
	},
	hero_lady_margosa_walk = {
		prefix = "hero_lady_margosa",
		to = 38,
		from = 23
	},
	hero_lady_margosa_attack = {
		prefix = "hero_lady_margosa",
		to = 67,
		from = 39
	},
	hero_lady_margosa_darkCall = {
		prefix = "hero_lady_margosa",
		to = 105,
		from = 68
	},
	hero_lady_margosa_mystForm = {
		prefix = "hero_lady_margosa",
		to = 143,
		from = 106
	},
	hero_lady_margosa_toBat = {
		prefix = "hero_lady_margosa",
		to = 165,
		from = 144
	},
	hero_lady_margosa_fly = {
		prefix = "hero_lady_margosa",
		to = 173,
		from = 166
	},
	hero_lady_margosa_toHuman = {
		prefix = "hero_lady_margosa",
		to = 186,
		from = 174
	},
	hero_lady_margosa_death = {
		prefix = "hero_lady_margosa",
		to = 238,
		from = 187
	},
	hero_lady_margosa_levelup = {
		prefix = "hero_lady_margosa",
		to = 272,
		from = 239
	},
	hero_lady_margosa_respawn = {
		prefix = "hero_lady_margosa",
		to = 272,
		from = 239
	},
	hero_lady_margosa_summonBat = {
		prefix = "hero_lady_margosa",
		to = 292,
		from = 273
	},
	hero_lady_margosa_toBeast = {
		prefix = "hero_lady_margosa",
		to = 313,
		from = 293
	},
	hero_lady_margosa_beast_walk = {
		prefix = "hero_lady_margosa",
		to = 325,
		from = 314
	},
	hero_lady_margosa_beast_idle = {
		prefix = "hero_lady_margosa",
		to = 325,
		from = 314
	},
	hero_lady_margosa_beast_attack = {
		prefix = "hero_lady_margosa",
		to = 352,
		from = 326
	},
	hero_lady_margosa_beast_death = {
		prefix = "hero_lady_margosa",
		to = 386,
		from = 353
	},
	hero_lady_margosa_beast_toMargosa = {
		prefix = "hero_lady_margosa",
		to = 407,
		from = 387
	},
	hero_lady_margosa_bat_summon = {
		prefix = "hero_lady_margosa_bat",
		to = 13,
		from = 1
	},
	hero_lady_margosa_bat_idle = {
		prefix = "hero_lady_margosa_bat",
		to = 21,
		from = 14
	},
	hero_lady_margosa_bat_attack = {
		prefix = "hero_lady_margosa_bat",
		to = 41,
		from = 22
	},
	hero_lady_margosa_bat_death = {
		prefix = "hero_lady_margosa_bat",
		to = 57,
		from = 42
	},
	hero_lady_margosa_bat_hit_blood_red = {
		prefix = "hero_lady_margosa_bat_blood",
		to = 8,
		from = 1
	},
	hero_lady_margosa_bat_hit_blood_green = {
		prefix = "hero_lady_margosa_bat_blood",
		to = 8,
		from = 1
	},
	hero_lady_margosa_bat_hit_blood_sparks = {
		prefix = "hero_lady_margosa_bat_sparks",
		to = 8,
		from = 1
	},
	hero_lady_margosa_bat_hit_blood_violet = {
		prefix = "hero_lady_margosa_bat_blood",
		to = 8,
		from = 1
	},
	hero_lady_margosa_beast_attack_effect_run = {
		prefix = "hero_lady_margosa_beast_attack_effect",
		to = 32,
		from = 1
	},
	hero_lady_margosa_myst_form_effect_in = {
		prefix = "hero_lady_margosa_myst_form_effect",
		to = 9,
		from = 1
	},
	hero_lady_margosa_myst_form_effect_run = {
		prefix = "hero_lady_margosa_myst_form_effect",
		to = 26,
		from = 10
	},
	hero_lady_margosa_myst_form_effect_out = {
		prefix = "hero_lady_margosa_myst_form_effect",
		to = 34,
		from = 27
	},
	hero_lady_margosa_teleport_effect_in = {
		prefix = "hero_lady_margosa_teleport_effect",
		to = 28,
		from = 1
	},
	hero_lady_margosa_teleport_effect_out = {
		prefix = "hero_lady_margosa_teleport_effect",
		to = 28,
		from = 1
	},
	hero_lady_margosa_vampiric_touch_effect_run = {
		prefix = "hero_lady_margosa_vampiric_touch_effect",
		to = 31,
		from = 1
	},
}
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/kr4_hero_margosa.lua

-- BEGIN kr3/data/animations/kr4_hero_mortemis.lua
do
	local __chunk = (function()
return {
	hero_mortemis_idle = {
		prefix = "hero_mortemis",
		to = 15,
		from = 1
	},
	hero_mortemis_walk = {
		prefix = "hero_mortemis",
		to = 38,
		from = 16
	},
	hero_mortemis_melee = {
		prefix = "hero_mortemis",
		to = 69,
		from = 39
	},
	hero_mortemis_attack = {
		prefix = "hero_mortemis",
		to = 69,
		from = 39
	},
	hero_mortemis_attackIn = {
		prefix = "hero_mortemis",
		to = 95,
		from = 70
	},
	hero_mortemis_attackLoop = {
		prefix = "hero_mortemis",
		to = 113,
		from = 96
	},
	hero_mortemis_attackOut = {
		prefix = "hero_mortemis",
		to = 119,
		from = 114
	},
	hero_mortemis_shoot = {
		prefix = "hero_mortemis",
		to = 119,
		from = 70
	},
	hero_mortemis_deadlyFumes = {
		prefix = "hero_mortemis",
		to = 157,
		from = 120
	},
	hero_mortemis_callHunted = {
		prefix = "hero_mortemis",
		to = 191,
		from = 158
	},
	hero_mortemis_death = {
		prefix = "hero_mortemis",
		to = 242,
		from = 192
	},
	hero_mortemis_levelup = {
		prefix = "hero_mortemis",
		to = 257,
		from = 243
	},
	hero_mortemis_respawn = {
		prefix = "hero_mortemis",
		to = 257,
		from = 243
	},
	hero_mortemis_call_of_the_haunted_run = {
		prefix = "hero_mortemis_call_of_the_haunted",
		to = 18,
		from = 1
	},
	hero_mortemis_fumes_floor_decal_start = {
		prefix = "hero_mortemis_fumes_floor_decal",
		to = 4,
		from = 1
	},
	hero_mortemis_fumes_floor_decal_run = {
		prefix = "hero_mortemis_fumes_floor_decal",
		to = 5,
		from = 5
	},
	hero_mortemis_fumes_fx_run = {
		prefix = "hero_mortemis_fumes_fx",
		to = 35,
		from = 1
	},
	hero_mortemis_soul_particle_run = {
		prefix = "hero_mortemis_soul_particle",
		to = 5,
		from = 1
	},
	hero_mortemis_soul_proyectile_run = {
		prefix = "hero_mortemis_soul_proyectile",
		to = 6,
		from = 1
	},
	hero_mortemis_soul_proyectile_travel = {
		prefix = "hero_mortemis_soul_proyectile",
		to = 14,
		from = 7
	},
	hero_mortemis_soul_proyectile_hit = {
		prefix = "hero_mortemis_soul_proyectile",
		to = 19,
		from = 15
	},
	hero_mortemis_zombie_idle = {
		prefix = "hero_mortemis_zombie",
		to = 35,
		from = 1
	},
	hero_mortemis_zombie_walk = {
		prefix = "hero_mortemis_zombie",
		to = 59,
		from = 36
	},
	hero_mortemis_zombie_attack = {
		prefix = "hero_mortemis_zombie",
		to = 94,
		from = 60
	},
	hero_mortemis_zombie_raise = {
		prefix = "hero_mortemis_zombie",
		to = 147,
		from = 95
	},
	hero_mortemis_zombie_death = {
		prefix = "hero_mortemis_zombie",
		to = 187,
		from = 148
	},
	hero_mortemis_zombie_golem_raise = {
		prefix = "hero_mortemis_zombie_golem",
		to = 44,
		from = 1
	},
	hero_mortemis_zombie_golem_idle = {
		prefix = "hero_mortemis_zombie_golem",
		to = 45,
		from = 45
	},
	hero_mortemis_zombie_golem_walk = {
		prefix = "hero_mortemis_zombie_golem",
		to = 69,
		from = 46
	},
	hero_mortemis_zombie_golem_attack = {
		prefix = "hero_mortemis_zombie_golem",
		to = 101,
		from = 70
	},
	hero_mortemis_zombie_golem_death = {
		prefix = "hero_mortemis_zombie_golem",
		to = 126,
		from = 102
	},
	hero_mortemis_zombie_golem_attack_effect_run = {
		prefix = "hero_mortemis_zombie_golem_attack_effect",
		to = 8,
		from = 1
	},
	hero_mortemis_zombie_golem_attack_rocks_front_run = {
		prefix = "hero_mortemis_zombie_golem_attack_rocks_front",
		to = 19,
		from = 1
	},
}
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/kr4_hero_mortemis.lua

-- BEGIN kr3/data/animations/kr4_hero_naga.lua
do
	local __chunk = (function()
return {
	hero_naga_idle = {
		prefix = "hero_naga",
		to = 1,
		from = 1
	},
	hero_naga_walk = {
		prefix = "hero_naga",
		to = 25,
		from = 2
	},
	hero_naga_attack = {
		prefix = "hero_naga",
		to = 54,
		from = 26
	},
	hero_naga_attackSpecial = {
		prefix = "hero_naga",
		to = 82,
		from = 55
	},
	hero_naga_shoot = {
		prefix = "hero_naga",
		to = 105,
		from = 83
	},
	hero_naga_banner = {
		prefix = "hero_naga",
		to = 139,
		from = 106
	},
	hero_naga_levelup = {
		prefix = "hero_naga",
		to = 169,
		from = 140
	},
	hero_naga_respawn = {
		prefix = "hero_naga",
		to = 169,
		from = 140
	},
	hero_naga_death = {
		prefix = "hero_naga",
		to = 192,
		from = 170
	},
	hero_naga_silence = {
		prefix = "hero_naga",
		to = 232,
		from = 193
	},
	hero_naga_area_decal_run = {
		prefix = "hero_naga_area_decal",
		to = 2,
		from = 1
	},
	hero_naga_area_fx_run = {
		prefix = "hero_naga_area_fx",
		to = 13,
		from = 1
	},
	hero_naga_banner_courage_start = {
		prefix = "hero_naga_banner_courage",
		to = 14,
		from = 1
	},
	hero_naga_banner_courage_run = {
		prefix = "hero_naga_banner_courage",
		to = 15,
		from = 15
	},
	hero_naga_banner_courage_end = {
		prefix = "hero_naga_banner_courage",
		to = 25,
		from = 16
	},
	hero_naga_banner_courage_modifier_loop = {
		prefix = "hero_naga_banner_courage_modifier",
		to = 23,
		from = 1
	},
	hero_naga_banner_hit_conquest_run = {
		prefix = "hero_naga_banner_hit_conquest",
		to = 9,
		from = 1
	},
	hero_naga_banner_hit_courage_run = {
		prefix = "hero_naga_banner_hit_courage",
		to = 9,
		from = 1
	},
	hero_naga_kraken_tentacle_in = {
		prefix = "hero_naga_kraken_tentacle",
		to = 12,
		from = 1
	},
	hero_naga_kraken_tentacle_run = {
		prefix = "hero_naga_kraken_tentacle",
		to = 42,
		from = 13
	},
	hero_naga_kraken_tentacle_out = {
		prefix = "hero_naga_kraken_tentacle",
		to = 75,
		from = 43
	},
	hero_naga_kraken_water_in = {
		prefix = "hero_naga_kraken_water",
		to = 12,
		from = 1
	},
	hero_naga_kraken_water_run = {
		prefix = "hero_naga_kraken_water",
		to = 60,
		from = 13
	},
	hero_naga_kraken_water_out = {
		prefix = "hero_naga_kraken_water",
		to = 77,
		from = 61
	},
	hero_naga_proyectile_miss_run = {
		prefix = "hero_naga_proyectile_miss",
		to = 6,
		from = 1
	},
	hero_naga_silence_modifier_run = {
		prefix = "hero_naga_silence_modifier",
		to = 8,
		from = 1
	},
	hero_naga_tidal_wave_run = {
		prefix = "hero_naga_tidal_wave",
		to = 23,
		from = 1
	},
}
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/kr4_hero_naga.lua

-- BEGIN kr3/data/animations/kr4_hero_tramin.lua
do
	local __chunk = (function()
return {
	hero_tramin_idle = {
		prefix = "hero_tramin",
		to = 1,
		from = 1
	},
	hero_tramin_walk = {
		prefix = "hero_tramin",
		to = 21,
		from = 2
	},
	hero_tramin_melee = {
		prefix = "hero_tramin",
		to = 41,
		from = 22
	},
	hero_tramin_attack = {
		prefix = "hero_tramin",
		to = 41,
		from = 22
	},
	hero_tramin_melee2 = {
		prefix = "hero_tramin",
		to = 59,
		from = 42
	},
	hero_tramin_death = {
		prefix = "hero_tramin",
		to = 125,
		from = 60
	},
	hero_tramin_throwBomb = {
		prefix = "hero_tramin",
		to = 147,
		from = 126
	},
	hero_tramin_shoot = {
		prefix = "hero_tramin",
		to = 147,
		from = 126
	},
	hero_tramin_shoot2 = {
		prefix = "hero_tramin",
		to = 283,
		from = 276
	},
	hero_tramin_throwFlashbang = {
		prefix = "hero_tramin",
		to = 169,
		from = 148
	},
	hero_tramin_throwTNT = {
		prefix = "hero_tramin",
		to = 191,
		from = 170
	},
	hero_tramin_throwBombot = {
		prefix = "hero_tramin",
		to = 213,
		from = 192
	},
	hero_tramin_drink = {
		prefix = "hero_tramin",
		to = 263,
		from = 214
	},
	hero_tramin_toRocketRain = {
		prefix = "hero_tramin",
		to = 275,
		from = 264
	},
	hero_tramin_RocketRain = {
		prefix = "hero_tramin",
		to = 283,
		from = 276
	},
	hero_tramin_outRocketRain = {
		prefix = "hero_tramin",
		to = 292,
		from = 284
	},
	hero_tramin_toJetpack = {
		prefix = "hero_tramin",
		to = 313,
		from = 293
	},
	hero_tramin_toJetpack2 = {
		prefix = "hero_tramin",
		to = 301,
		from = 293
	},
	hero_tramin_jetpack = {
		prefix = "hero_tramin",
		to = 321,
		from = 314
	},
	
	hero_tramin_jetpack_fx = {
		prefix = "hero_tramin",
		to = 321,
		from = 314
	},
	hero_tramin_outJetpack = {
		prefix = "hero_tramin",
		to = 328,
		from = 322
	},
	hero_tramin_levelup = {
		prefix = "hero_tramin",
		to = 359,
		from = 329
	},
	hero_tramin_respawn = {
		prefix = "hero_tramin",
		to = 359,
		from = 329
	},
	--普攻
	hero_tramin_basic_melee_explotion_run = {
		prefix = "hero_tramin_basic_melee_explotion",
		to = 13,
		from = 1
	},
	hero_tramin_bombot_landing = {
		prefix = "hero_tramin_bombot",
		to = 8,
		from = 1
	},
	hero_tramin_bombot_landing_run = {
		prefix = "hero_tramin_bombot",
		to = 8,
		from = 1
	},
	hero_tramin_bombot_idle = {
		prefix = "hero_tramin_bombot",
		to = 9,
		from = 9
	},
	hero_tramin_bombot_walk = {
		prefix = "hero_tramin_bombot",
		to = 17,
		from = 10
	},
	hero_tramin_bombot_walkingUp = {
		prefix = "hero_tramin_bombot",
		to = 17,
		from = 10
	},
	hero_tramin_bombot_walkingDown = {
		prefix = "hero_tramin_bombot",
		to = 17,
		from = 10
	},
	hero_tramin_bombot_walkingRightLeft = {
		prefix = "hero_tramin_bombot",
		to = 17,
		from = 10
	},
	hero_tramin_bombot_explotion_run = {
		prefix = "hero_tramin_bombot_explotion",
		to = 18,
		from = 1
	},
	hero_tramin_bombot_death = {
		prefix = "hero_tramin_bombot_explotion",
		to = 18,
		from = 1
	},
	hero_tramin_drink_decal_run = {
		prefix = "hero_tramin_drink_decal",
		to = 16,
		from = 1
	},
	hero_tramin_flashbang_explotion_run = {
		prefix = "hero_tramin_flashbang_explotion",
		to = 25,
		from = 1
	},
	hero_tramin_jetpack_floor_run = {
		prefix = "hero_tramin_jetpack_floor",
		to = 19,
		from = 1
	},
	hero_tramin_jetpack_particle_run = {
		prefix = "hero_tramin_jetpack_particle",
		to = 14,
		from = 1
	},
	hero_tramin_misil_proyectile_hit_run = {
		prefix = "hero_tramin_misil_proyectile_hit",
		to = 15,
		from = 1
	},
	hero_tramin_misil_proyectile_particle_run = {
		prefix = "hero_tramin_misil_proyectile_particle",
		to = 8,
		from = 1
	},
	hero_tramin_tnt_proyectile_hit_run = {
		prefix = "hero_tramin_tnt_proyectile_hit",
		to = 18,
		from = 1
	},
	hero_tramin_ultimate_bomb_walk = {
		prefix = "hero_tramin_ultimate_bomb",
		to = 1,
		from = 1
	},
	hero_tramin_ultimate_bomb_1_walk = {
		prefix = "hero_tramin_ultimate_bomb",
		to = 9,
		from = 2
	},
	hero_tramin_ultimate_bomb_2_walk = {
		prefix = "hero_tramin_ultimate_bomb",
		to = 17,
		from = 10
	},
	hero_tramin_ultimate_bomb_3_walk = {
		prefix = "hero_tramin_ultimate_bomb",
		to = 25,
		from = 18
	},
	hero_tramin_ultimate_bomb_4_walk = {
		prefix = "hero_tramin_ultimate_bomb",
		to = 33,
		from = 26
	},
	hero_tramin_ultimate_bomb_5_walk = {
		prefix = "hero_tramin_ultimate_bomb",
		to = 41,
		from = 34
	},
	hero_tramin_ultimate_bomb_6_walk = {
		prefix = "hero_tramin_ultimate_bomb",
		to = 49,
		from = 42
	},
	hero_tramin_ultimate_box_idle = {
		prefix = "hero_tramin_ultimate_box",
		to = 1,
		from = 1
	},
	hero_tramin_ultimate_box_open = {
		prefix = "hero_tramin_ultimate_box",
		to = 15,
		from = 2
	},
	hero_tramin_ultimate_box_openIdle = {
		prefix = "hero_tramin_ultimate_box",
		to = 16,
		from = 16
	},
	hero_tramin_ultimate_explosion_run = {
		prefix = "hero_tramin_ultimate_explosion",
		to = 19,
		from = 1
	},
	hero_tramin_ultimate_fire_in = {
		prefix = "hero_tramin_ultimate_fire",
		to = 24,
		from = 1
	},
	hero_tramin_ultimate_fire_run = {
		prefix = "hero_tramin_ultimate_fire",
		to = 49,
		from = 25
	},
	hero_tramin_ultimate_fire_out = {
		prefix = "hero_tramin_ultimate_fire",
		to = 67,
		from = 50
	},
	hero_tramin_ultimate_fire_modifier_in = {
		prefix = "hero_tramin_ultimate_fire_modifier",
		to = 8,
		from = 1
	},
	hero_tramin_ultimate_fire_modifier_loop = {
		prefix = "hero_tramin_ultimate_fire_modifier",
		to = 21,
		from = 9
	},
	hero_tramin_ultimate_fire_modifier_out = {
		prefix = "hero_tramin_ultimate_fire_modifier",
		to = 36,
		from = 22
	},
	hero_tramin_ultimate_plane_fly = {
		prefix = "hero_tramin_ultimate_plane",
		to = 4,
		from = 1
	},
	hero_tramin_ultimate_proyectile_explosion_run = {
		prefix = "hero_tramin_ultimate_proyectile_explosion",
		to = 13,
		from = 1
	},
}
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/kr4_hero_tramin.lua

-- BEGIN kr3/data/animations/kr4_heroes.lua
do
	local __chunk = (function()
return {
	-- hero_dianyun
	kr4_heal_loop = {
		prefix = "healing_big",
		to = 24,
		from = 1
	},
	kr4_stun_loop = {
		prefix = "stun_effect",
		to = 10,
		from = 1
	},
	hero_storm_dragon_cloud_l1_idle = {
		to = 59,
		from = 1,
		prefix = "hero_storm_dragon_cloud_layer1"
	},
	hero_storm_dragon_cloud_l2_idle = {
		to = 59,
		from = 1,
		prefix = "hero_storm_dragon_cloud_layer2"
	},
	hero_storm_dragon_cloud_l3_idle = {
		to = 59,
		from = 1,
		prefix = "hero_storm_dragon_cloud_layer3"
	},
	hero_storm_dragon_supreme_wave = {
		prefix = "hero_storm_dragon_supreme_wave",
		to = 71,
		from = 1
	},
	hero_storm_dragon_lightning_ricochet_fx_l1 = {
		to = 100,
		from = 1,
		prefix = "hero_storm_dragon_lightning_ricochet_fx_layer1"
	},
	hero_storm_dragon_lightning_ricochet_fx_l2 = {
		to = 100,
		from = 1,
		prefix = "hero_storm_dragon_lightning_ricochet_fx_layer2"
	},
	hero_storm_dragon_lightning_ricochet_fx_l3 = {
		to = 100,
		from = 1,
		prefix = "hero_storm_dragon_lightning_ricochet_fx_layer3"
	},
	hero_storm_dragon_lightning_ricochet_cloud = {
		prefix = "hero_storm_dragon_lightning_ricochet_cloud",
		to = 18,
		from = 1
	},
	hero_storm_ray_modifier_loop = {
		prefix = "hero_storm_ray_modifier",
		to = 6,
		from = 1
	},
	hero_storm_dragon_lightning_ricochet_hit = {
		prefix = "hero_storm_dragon_lightning_ricochet_hit",
		to = 10,
		from = 1
	},
	hero_storm_dragon_lightning_ricochet = {
		prefix = "hero_storm_dragon_lightning_ricochet",
		to = 15,
		from = 1
	},
	hero_storm_dragon_lightning = {
		prefix = "hero_storm_dragon_lightning",
		to = 18,
		from = 1
	},
	hero_storm_dragon_lightning_modifier_loop = {
		prefix = "hero_storm_dragon_lightning_modifier",
		to = 6,
		from = 1
	},
	hero_storm_dragon_lightning_hit = {
		prefix = "hero_storm_dragon_lightning_hit",
		to = 10,
		from = 1
	},
	hero_storm_dragon_lantern = {
		prefix = "hero_storm_dragon_lantern",
		to = 50,
		from = 1
	},
	hero_storm_dragon_electric_son_spawn = {
		prefix = "hero_storm_dragon_electric_son",
		to = 25,
		from = 1
	},
	hero_storm_dragon_electric_son_idle = {
		prefix = "hero_storm_dragon_electric_son",
		to = 53,
		from = 26
	},
	hero_storm_dragon_electric_son_attack = {
		prefix = "hero_storm_dragon_electric_son",
		to = 81,
		from = 54
	},
	hero_storm_dragon_electric_son_death = {
		prefix = "hero_storm_dragon_electric_son",
		to = 100,
		from = 82
	},
	malik_layerX_sitIdle = {layer_from = 1, layer_to = 2, layer_prefix = "malik_layer%i", from = 1, to = 1},
	malik_layerX_sitTauntIn = {layer_from = 1, layer_to = 2, layer_prefix = "malik_layer%i", from = 58, to = 63},
	malik_layerX_sitTauntEnd = {layer_from = 1, layer_to = 2, layer_prefix = "malik_layer%i", from = 98, to = 110},
	malik_layerX_allyDeath = {layer_from = 1, layer_to = 2, layer_prefix = "malik_layer%i", from = 570, to = 669},
	-- hero_malik
	malik_layerX_idle = {
		layer_to = 2,
		from = 237,
		layer_prefix = "malik_layer%i",
		to = 237,
		layer_from = 1,
	},
	malik_layerX_walk = {
		layer_to = 2,
		from = 238,
		layer_prefix = "malik_layer%i",
		to = 289,
		layer_from = 1,
	},
	malik_layerX_walkDown = {
		layer_to = 2,
		from = 238,
		layer_prefix = "malik_layer%i",
		to = 289,
		layer_from = 1,
	},
	malik_layerX_walkUp = {
		layer_to = 2,
		from = 238,
		layer_prefix = "malik_layer%i",
		to = 289,
		layer_from = 1,
	},
	malik_layerX_melee = {
		layer_to = 2,
		from = 290,
		layer_prefix = "malik_layer%i",
		to = 343,
		layer_from = 1,
	},
	malik_layerX_range = {
		layer_to = 2,
		from = 344,
		layer_prefix = "malik_layer%i",
		to = 388,
		layer_from = 1,
	},
	malik_layerX_jumpLaunch = {
		layer_to = 2,
		from = 389,
		layer_prefix = "malik_layer%i",
		to = 424,
		layer_from = 1,
	},
	malik_layerX_jumpTravel = {
		layer_to = 2,
		from = 425,
		layer_prefix = "malik_layer%i",
		to = 431,
		layer_from = 1,
	},
	malik_layerX_jumpLand = {
		layer_to = 2,
		from = 432,
		layer_prefix = "malik_layer%i",
		to = 460,
		layer_from = 1,
	},
	malik_layerX_special = {
		layer_to = 2,
		from = 461,
		layer_prefix = "malik_layer%i",
		to = 525,
		layer_from = 1,
	},
	malik_layerX_taunt = {
		layer_to = 2,
		from = 526,
		layer_prefix = "malik_layer%i",
		to = 569,
		layer_from = 1,
	},
	malik_layerX_death = {
		layer_to = 2,
		from = 570,
		layer_prefix = "malik_layer%i",
		to = 602,
		layer_from = 1,
	},
	malik_layerX_deathLoop = {
		layer_to = 2,
		from = 603,
		layer_prefix = "malik_layer%i",
		to = 636,
		layer_from = 1,
	},
	malik_layerX_deathEnd = {
		layer_to = 2,
		from = 637,
		layer_prefix = "malik_layer%i",
		to = 669,
		layer_from = 1,
	},
	malik_attack_decal_run = {
		prefix = "malik_attack_floor_decal",
		to = 27,
		from = 1
	},
	malik_attack_ray_travel = {
		prefix = "malik_attack_ray",
		to = 20,
		from = 1
	},
	malik_attack_ray_modifier_run = {
		prefix = "malik_attack_ray_modifier",
		to = 6,
		from = 1
	},
	malik_jump_decal_run = {
		prefix = "malik_jump_decal",
		to = 18,
		from = 1
	},
	malik_towerdestroction_ray_run = {
		prefix = "malik_towerdestroction_ray",
		to = 16,
		from = 1
	},
	-- hero_eiskalt
	hero_eiskalt_idle = {
		prefix = "hero_eiskalt",
		to = 20,
		from = 1
	},
	hero_eiskalt_attack = {
		prefix = "hero_eiskalt",
		to = 44,
		from = 21
	},
	hero_eiskalt_icePeaks = {
		prefix = "hero_eiskalt",
		to = 84,
		from = 45
	},
	hero_eiskalt_coldFury = {
		prefix = "hero_eiskalt",
		to = 127,
		from = 85
	},
	hero_eiskalt_frosty = {
		prefix = "hero_eiskalt",
		to = 164,
		from = 128
	},
	hero_eiskalt_death = {
		prefix = "hero_eiskalt",
		to = 194,
		from = 165
	},
	hero_eiskalt_respawn = {
		prefix = "hero_eiskalt",
		to = 235,
		from = 195
	},
	hero_eiskalt_levelUp = {
		prefix = "hero_eiskalt",
		to = 263,
		from = 236
	},
	hero_eiskalt_cold_fury_particle_travel = {
		prefix = "hero_eiskalt_cold_fury_particle",
		to = 6,
		from = 1
	},
	hero_eiskalt_cold_fury_smoke_run = {
		prefix = "hero_eiskalt_cold_fury_smoke",
		to = 40,
		from = 1
	},
	hero_eiskalt_explosion_air_run = {
		prefix = "hero_eiskalt_explosion_air",
		to = 21,
		from = 1
	},
	hero_eiskalt_explosion_run = {
		prefix = "hero_eiskalt_explosion",
		to = 21,
		from = 1
	},
	hero_eiskalt_frosty_spawn = {
		prefix = "hero_eiskalt_frosty",
		to = 1,
		from = 1
	},
	hero_eiskalt_frosty_walkDown = {
		prefix = "hero_eiskalt_frosty",
		to = 21,
		from = 1
	},
	hero_eiskalt_frosty_walkUp = {
		prefix = "hero_eiskalt_frosty",
		to = 42,
		from = 22
	},
	hero_eiskalt_frosty_walk = {
		prefix = "hero_eiskalt_frosty",
		to = 63,
		from = 43
	},
	hero_eiskalt_frosty_death = {
		prefix = "hero_eiskalt_frosty",
		to = 97,
		from = 64
	},
	hero_eiskalt_frosty_explotion_run = {
		prefix = "hero_eiskalt_frosty_explosion",
		to = 22,
		from = 1
	},
	hero_eiskalt_ice_peaks_in = {
		prefix = "hero_eiskalt_ice_peaks",
		to = 7,
		from = 1
	},
	hero_eiskalt_ice_peaks_run = {
		prefix = "hero_eiskalt_ice_peaks",
		to = 13,
		from = 8
	},
	hero_eiskalt_ice_peaks_out = {
		prefix = "hero_eiskalt_ice_peaks",
		to = 21,
		from = 14
	},
	hero_eiskalt_particle_run = {
		prefix = "hero_eiskalt_particle",
		to = 11,
		from = 1
	},
	hero_eiskalt_proyectile_travel = {
		prefix = "hero_eiskalt_proyectile",
		to = 10,
		from = 1
	},
	-- hero_jack_o_lantern
	hero_jack_o_lantern_idle = {
		prefix = "hero_jack_o_lantern",
		to = 12,
		from = 1
	},
	hero_jack_o_lantern_walk = {
		prefix = "hero_jack_o_lantern",
		to = 22,
		from = 13
	},
	hero_jack_o_lantern_attack = {
		prefix = "hero_jack_o_lantern",
		to = 43,
		from = 23
	},
	hero_jack_o_lantern_hauntedBlade = {
		prefix = "hero_jack_o_lantern",
		to = 74,
		from = 44
	},
	hero_jack_o_lantern_spawnGhouls = {
		prefix = "hero_jack_o_lantern",
		to = 104,
		from = 75
	},
	hero_jack_o_lantern_explosiveHead = {
		prefix = "hero_jack_o_lantern",
		to = 140,
		from = 105
	},
	hero_jack_o_lantern_teleportIn = {
		prefix = "hero_jack_o_lantern",
		to = 163,
		from = 141
	},
	hero_jack_o_lantern_teleportOut = {
		prefix = "hero_jack_o_lantern",
		to = 177,
		from = 164
	},
	hero_jack_o_lantern_levelUp = {
		prefix = "hero_jack_o_lantern",
		to = 214,
		from = 178
	},
	hero_jack_o_lantern_respawn = {
		prefix = "hero_jack_o_lantern",
		to = 249,
		from = 215
	},
	hero_jack_o_lantern_death = {
		prefix = "hero_jack_o_lantern",
		to = 328,
		from = 250
	},
	hero_jack_o_lantern_idleDeath = {
		prefix = "hero_jack_o_lantern",
		to = 359,
		from = 329
	},
	hero_jack_o_lantern_idleBlock = {
		prefix = "hero_jack_o_lantern",
		to = 360,
		from = 360
	},
	hero_jack_o_lantern_explotion_run = {
		prefix = "hero_jack_o_lantern_explotion",
		to = 18,
		from = 1
	},
	hero_jack_o_lantern_spawner_hit_run = {
		prefix = "hero_jack_o_lantern_spawner_hit",
		to = 56,
		from = 1
	},
	hero_jack_o_lantern_spawner_seed_travel = {
		prefix = "hero_jack_o_lantern_spawner_seed",
		to = 12,
		from = 1
	},
	hero_jack_o_lantern_spawner_seed_decal_run = {
		prefix = "hero_jack_o_lantern_spawner_seed_decal",
		to = 10,
		from = 1
	},
	hero_jack_o_lantern_teleportfx_run = {
		prefix = "hero_jack_o_lantern_teleportfx",
		to = 31,
		from = 1
	},
	hero_jack_o_lantern_ultimate_fear_modifier_run = {
		prefix = "hero_jack_o_lantern_ultimate_fear_modifier",
		to = 4,
		from = 1
	},
	hero_jack_o_lantern_ultimate_particle_run = {
		prefix = "hero_jack_o_lantern_ultimate_particle",
		to = 10,
		from = 1
	},
	hero_jack_o_lantern_ultimate_smoke_run = {
		prefix = "hero_jack_o_lantern_ultimate_smoke",
		to = 23,
		from = 1
	},
	hero_jack_o_lantern_ghoul_idle = {
		prefix = "hero_jack_o_lantern_ghoul",
		to = 1,
		from = 1
	},
	hero_jack_o_lantern_ghoul_walk = {
		prefix = "hero_jack_o_lantern_ghoul",
		to = 11,
		from = 2
	},
	hero_jack_o_lantern_ghoul_attack = {
		prefix = "hero_jack_o_lantern_ghoul",
		to = 30,
		from = 12
	},
	hero_jack_o_lantern_ghoul_death = {
		prefix = "hero_jack_o_lantern_ghoul",
		to = 78,
		from = 31
	},
	hero_jack_o_lantern_ultimate_horse_idle = {
		prefix = "hero_jack_o_lantern_ultimate_horse",
		to = 1,
		from = 1
	},
	hero_jack_o_lantern_ultimate_horse_walk = {
		prefix = "hero_jack_o_lantern_ultimate_horse",
		to = 12,
		from = 2
	},
	hero_jack_o_lantern_ultimate_horse_walkUp = {
		prefix = "hero_jack_o_lantern_ultimate_horse",
		to = 24,
		from = 13
	},
	hero_jack_o_lantern_ultimate_horse_walkDown = {
		prefix = "hero_jack_o_lantern_ultimate_horse",
		to = 36,
		from = 25
	},
}
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/kr4_heroes.lua

-- BEGIN kr3/data/animations/kr4_map_sapos.lua
do
	local __chunk = (function()
return {
--地图内容
	Stage_17_foam_down_run = {
		prefix = "Stage_17_foam_down",
		to = 9,
		from = 1
	},
	Stage_17_foam_mid_run = {
		prefix = "Stage_17_foam_mid",
		to = 9,
		from = 1
	},
	Stage_17_foam_small_run = {
		prefix = "Stage_17_foam_small",
		to = 30,
		from = 1
	},
	Stage_17_waterfall_lake_drops_run = {
		prefix = "Stage_17_waterfall_lake_drops",
		to = 15,
		from = 1
	},
	Stage_17_waterfall_lake_waves_run = {
		prefix = "Stage_17_waterfall_lake_waves",
		to = 42,
		from = 1
	},
	Stage_17_waterfall_lines_left_run = {
		prefix = "Stage_17_waterfall_lines_left",
		to = 15,
		from = 1
	},
	Stage_17_waterfall_lines_right_run = {
		prefix = "Stage_17_waterfall_lines_right",
		to = 15,
		from = 1
	},
	Stage_17_waterfall_shine_mid_run = {
		prefix = "Stage_17_waterfall_shine_mid",
		to = 9,
		from = 1
	},
	Stage_17_waterfall_shine_top_left_run = {
		prefix = "Stage_17_waterfall_shine_top_left",
		to = 9,
		from = 1
	},
	Stage_17_waterfall_shine_top_right_run = {
		prefix = "Stage_17_waterfall_shine_top_right",
		to = 9,
		from = 1
	},
	Stage_18_water_sparks_run = {
		prefix = "Stage_18_water_sparks",
		to = 85,
		from = 1
	},
	Stage_18_wf_foam_run = {
		prefix = "Stage_18_wf_foam",
		to = 15,
		from = 1
	},
	Stage_18_wf_lines_run = {
		prefix = "Stage_18_wf_lines",
		to = 15,
		from = 1
	},
	Stage_18_wf_top_run = {
		prefix = "Stage_18_wf_top",
		to = 15,
		from = 1
	},
--spawner
	bullywag_spawner_layerX_idle = {
        layer_to = 2,
        from = 1,
        layer_prefix = "bullywag_spawner_layer%i",
        to = 20,
        layer_from = 1,
    },
    bullywag_spawner_layerX_active = {
        layer_to = 2,
        from = 21,
        layer_prefix = "bullywag_spawner_layer%i",
        to = 50,
        layer_from = 1,
    },
	bullywag_spawner_layerX_end = {
        layer_to = 2,
        from = 21,
        layer_prefix = "bullywag_spawner_layer%i",
        to = 50,
        layer_from = 1,
    },
	bullywag_spawner_splash_idle = {
		prefix = "bullywag_spawner_splash",
		to = 1,
		from = 1
	},
	bullywag_spawner_splash_active = {
		prefix = "bullywag_spawner_splash",
		to = 20,
		from = 1
	},
	bullywag_spawner_splash_end = {
		prefix = "bullywag_spawner_splash",
		to = 20,
		from = 1
	},
--神龛
	bullywag_bubble_crystals_layerX_cooldown = {
        layer_to = 10,
        from = 1,
        layer_prefix = "bullywag_bubble_crystals_layer%i",
        to = 40,
        layer_from = 1,
    },
    bullywag_bubble_crystals_layerX_ready = {
        layer_to = 10,
        from = 41,
        layer_prefix = "bullywag_bubble_crystals_layer%i",
        to = 58,
        layer_from = 1,
    },
    bullywag_bubble_crystals_layerX_shoot = {
        layer_to = 10,
        from = 59,
        layer_prefix = "bullywag_bubble_crystals_layer%i",
        to = 99,
        layer_from = 1,
    },
	bullywag_bubble_crystals_blast_run = {
		prefix = "bullywag_bubble_crystals_blast",
		to = 49,
		from = 1
	},
	bullywag_bubble_crystals_shield_modifier_run = {
		prefix = "bullywag_bubble_crystals_shield_modifier",
		to = 18,
		from = 1
	},
--水晶
	overcharge_crystals_explotion_run = {
		prefix = "overcharge_crystals_explotion",
		to = 16,
		from = 1
	},
	overcharge_crystals_modifier_start = {
		prefix = "overcharge_crystals_modifier",
		to = 16,
		from = 1
	},
	overcharge_crystals_modifier_loop = {
		prefix = "overcharge_crystals_modifier",
		to = 16,
		from = 1
	},
	overcharge_crystals_modifier_end = {
		prefix = "overcharge_crystals_modifier",
		to = 16,
		from = 1
	},
	overcharge_crystals_ray_loop_loop = {
		prefix = "overcharge_crystals_ray_loop",
		to = 10,
		from = 1
	},
	overcharge_crystals_base_layerX_idle = {
        layer_to = 2,
        from = 1,
        layer_prefix = "overcharge_crystals_base_layer%i",
        to = 1,
        layer_from = 1,
    },
    overcharge_crystals_base_layerX_charging = {
        layer_to = 2,
        from = 2,
        layer_prefix = "overcharge_crystals_base_layer%i",
        to = 32,
        layer_from = 1,
    },
    overcharge_crystals_base_layerX_charged = {
        layer_to = 2,
        from = 33,
        layer_prefix = "overcharge_crystals_base_layer%i",
        to = 48,
        layer_from = 1,
    },
    overcharge_crystals_base_layerX_shoot = {
        layer_to = 2,
        from = 49,
        layer_prefix = "overcharge_crystals_base_layer%i",
        to = 67,
        layer_from = 1,
    },
}
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/kr4_map_sapos.lua

-- BEGIN kr3/data/animations/kr4_pirates_campaign.lua
do
	local __chunk = (function()
return {
	["BlackCorsair_run"] = { prefix = "blackcorsair", from = 1, to = 14 },
	["BlackCorsair_signal"] = { prefix = "blackcorsair", from = 147, to = 170 },
	["achievement_cofre_idle"] = { prefix = "achievement_cofre", from = 1, to = 1 },
	["achievement_cofre_tap"] = { prefix = "achievement_cofre", from = 2, to = 29 },
	["achievement_mono_death"] = { prefix = "achievement_mono", from = 22, to = 29 },
	["achievement_mono_idle"] = { prefix = "achievement_mono", from = 1, to = 1 },
	["achievement_mono_tap"] = { prefix = "achievement_mono", from = 2, to = 21 },
	["achievement_tiburon_idle"] = { prefix = "achievement_tiburon", from = 1, to = 26 },
	["achievement_tiburon_splash_run"] = { prefix = "achievement_tiburon_splash", from = 1, to = 61 },
	["achievement_tiburon_tap_one"] = { prefix = "achievement_tiburon", from = 27, to = 67 },
	["achievement_tiburon_tap_two"] = { prefix = "achievement_tiburon", from = 68, to = 136 },
	["apemate_attack"] = { prefix = "apemate", from = 139, to = 172 },
	["apemate_buff"] = { prefix = "apemate", from = 173, to = 212 },
	["apemate_death"] = { prefix = "apemate", from = 104, to = 138 },
	["apemate_hit_run"] = { prefix = "apemate_hit", from = 1, to = 19 },
	["apemate_idle"] = { prefix = "apemate", from = 1, to = 1 },
	["apemate_modifierDecal_run"] = { prefix = "apemate_modifierDecal", from = 1, to = 18 },
	["apemate_modifier_run"] = { prefix = "apemate_modifier", from = 1, to = 16 },
	["apemate_projectile"] = { prefix = "apemate", from = 213, to = 217 },
	["apemate_spawn"] = { prefix = "apemate", from = 218, to = 236 },
	["apemate_walk"] = { prefix = "apemate", from = 2, to = 35 },
	["apemate_walkDown"] = { prefix = "apemate", from = 36, to = 69 },
	["apemate_walkUp"] = { prefix = "apemate", from = 70, to = 103 },
	["blackcorsair_attack"] = { prefix = "blackcorsair", from = 111, to = 146 },
	["blackcorsair_death"] = { prefix = "blackcorsair", from = 233, to = 283 },
	["blackcorsair_deathLoop"] = { prefix = "blackcorsair", from = 284, to = 296 },
	["blackcorsair_effect_run"] = { prefix = "blackcorsair_effect", from = 1, to = 22 },
	["blackcorsair_idle"] = { prefix = "blackcorsair", from = 1, to = 14 },
	["blackcorsair_jumpDown"] = { prefix = "blackcorsair", from = 223, to = 232 },
	["blackcorsair_jumpIn"] = { prefix = "blackcorsair", from = 171, to = 198 },
	["blackcorsair_jumpLoopDown"] = { prefix = "blackcorsair", from = 211, to = 222 },
	["blackcorsair_jumpLoopUp"] = { prefix = "blackcorsair", from = 199, to = 210 },
	["blackcorsair_signal"] = { prefix = "blackcorsair", from = 309, to = 356 },
	["blackcorsair_summon"] = { prefix = "blackcorsair", from = 147, to = 170 },
	["blackcorsair_taunt"] = { prefix = "blackcorsair", from = 297, to = 308 },
	["blackcorsair_walk"] = { prefix = "blackcorsair", from = 15, to = 46 },
	["blackcorsair_walkDown"] = { prefix = "blackcorsair", from = 47, to = 78 },
	["blackcorsair_walkUp"] = { prefix = "blackcorsair", from = 79, to = 110 },
	["blackthorne_skill_kill_tower_run"] = { prefix = "blackthorne_skill_kill_tower", from = 1, to = 53 },
	["blackthorne_skill_stun_tower_bubbles_close"] = { prefix = "blackthorne_skill_stun_tower_bubbles", from = 57, to = 57 },
	["blackthorne_skill_stun_tower_bubbles_loop"] = { prefix = "blackthorne_skill_stun_tower_bubbles", from = 56, to = 56 },
	["blackthorne_skill_stun_tower_bubbles_open"] = { prefix = "blackthorne_skill_stun_tower_bubbles", from = 1, to = 55 },
	["blackthorne_skill_stun_tower_close"] = { prefix = "blackthorne_skill_stun_tower", from = 64, to = 86 },
	["blackthorne_skill_stun_tower_decal_close"] = { prefix = "blackthorne_skill_stun_tower_decal", from = 72, to = 98 },
	["blackthorne_skill_stun_tower_decal_loop"] = { prefix = "blackthorne_skill_stun_tower_decal", from = 56, to = 71 },
	["blackthorne_skill_stun_tower_decal_open"] = { prefix = "blackthorne_skill_stun_tower_decal", from = 1, to = 55 },
	["blackthorne_skill_stun_tower_loop"] = { prefix = "blackthorne_skill_stun_tower", from = 56, to = 63 },
	["blackthorne_skill_stun_tower_open"] = { prefix = "blackthorne_skill_stun_tower", from = 1, to = 55 },
	["boat_sail_run"] = { prefix = "boat_sail", from = 1, to = 24 },
	["boatswain_attack"] = { prefix = "boatswain", from = 84, to = 110 },
	["boatswain_death"] = { prefix = "boatswain", from = 111, to = 133 },
	["boatswain_idle"] = { prefix = "boatswain", from = 1, to = 1 },
	["boatswain_walk"] = { prefix = "boatswain", from = 2, to = 29 },
	["boatswain_walkDown"] = { prefix = "boatswain", from = 30, to = 57 },
	["boatswain_walkUp"] = { prefix = "boatswain", from = 58, to = 83 },
	["boom_baboon_death"] = { prefix = "boom_baboon", from = 43, to = 64 },
	["boom_baboon_idle"] = { prefix = "boom_baboon", from = 1, to = 1 },
	["boom_baboon_walk"] = { prefix = "boom_baboon", from = 1, to = 14 },
	["boom_baboon_walkDown"] = { prefix = "boom_baboon", from = 15, to = 27 },
	["boom_baboon_walkUp"] = { prefix = "boom_baboon", from = 28, to = 42 },
	["boss_blackthorne_parrot_coin_in"] = { prefix = "boss_blackthorne_parrot_coin", from = 1, to = 14 },
	["boss_blackthorne_parrot_coin_loop"] = { prefix = "boss_blackthorne_parrot_coin", from = 15, to = 24 },
	["boss_blackthorne_parrot_coin_out"] = { prefix = "boss_blackthorne_parrot_coin", from = 25, to = 36 },
	["boss_blackthorne_projectile_ability_travel"] = { prefix = "boss_blackthorne_projectile_ability", from = 1, to = 12 },
	["boss_blackthorne_projectile_basic_run"] = { prefix = "boss_blackthorne_projectile_basic", from = 13, to = 23 },
	["boss_blackthorne_projectile_basic_travel"] = { prefix = "boss_blackthorne_projectile_basic", from = 1, to = 12 },
	["boss_blackthorne_projectile_small_travel"] = { prefix = "boss_blackthorne_projectile_small", from = 1, to = 4 },
	["boss_blackthorne_spawn_charge_in"] = { prefix = "boss_blackthorne_spawn_charge", from = 1, to = 8 },
	["boss_blackthorne_spawn_charge_loop"] = { prefix = "boss_blackthorne_spawn_charge", from = 9, to = 38 },
	["boss_blackthorne_spawn_charge_out"] = { prefix = "boss_blackthorne_spawn_charge", from = 39, to = 51 },
	["boss_blackthorne_spawn_explosion_run"] = { prefix = "boss_blackthorne_spawn_explosion", from = 1, to = 18 },
	["boss_blackthorne_spawn_portal_in"] = { prefix = "boss_blackthorne_spawn_portal", from = 1, to = 8 },
	["boss_blackthorne_spawn_portal_loop"] = { prefix = "boss_blackthorne_spawn_portal", from = 9, to = 24 },
	["boss_blackthorne_spawn_portal_out"] = { prefix = "boss_blackthorne_spawn_portal", from = 25, to = 35 },
	["boss_blackthorne_unit_ability"] = { prefix = "boss_blackthorne_unit", from = 33, to = 70 },
	["boss_blackthorne_unit_attackA"] = { prefix = "boss_blackthorne_unit", from = 155, to = 181 },
	["boss_blackthorne_unit_attackB"] = { prefix = "boss_blackthorne_unit", from = 182, to = 208 },
	["boss_blackthorne_unit_attackC"] = { prefix = "boss_blackthorne_unit", from = 209, to = 235 },
	["boss_blackthorne_unit_death"] = { prefix = "boss_blackthorne_unit", from = 365, to = 400 },
	["boss_blackthorne_unit_deathFly"] = { prefix = "boss_blackthorne_unit", from = 567, to = 604 },
	["boss_blackthorne_unit_deathLoop"] = { prefix = "boss_blackthorne_unit", from = 401, to = 430 },
	["boss_blackthorne_unit_flyEnd"] = { prefix = "boss_blackthorne_unit", from = 289, to = 300 },
	["boss_blackthorne_unit_flyEndDown"] = { prefix = "boss_blackthorne_unit", from = 321, to = 332 },
	["boss_blackthorne_unit_flyEndUp"] = { prefix = "boss_blackthorne_unit", from = 353, to = 364 },
	["boss_blackthorne_unit_flyInit"] = { prefix = "boss_blackthorne_unit", from = 269, to = 278 },
	["boss_blackthorne_unit_flyInitDown"] = { prefix = "boss_blackthorne_unit", from = 301, to = 310 },
	["boss_blackthorne_unit_flyInitUp"] = { prefix = "boss_blackthorne_unit", from = 333, to = 342 },
	["boss_blackthorne_unit_flyWalk"] = { prefix = "boss_blackthorne_unit", from = 279, to = 288 },
	["boss_blackthorne_unit_flyWalkDown"] = { prefix = "boss_blackthorne_unit", from = 311, to = 320 },
	["boss_blackthorne_unit_flyWalkUp"] = { prefix = "boss_blackthorne_unit", from = 343, to = 352 },
	["boss_blackthorne_unit_idle"] = { prefix = "boss_blackthorne_unit", from = 1, to = 4 },
	["boss_blackthorne_unit_shoot"] = { prefix = "boss_blackthorne_unit", from = 236, to = 268 },
	["boss_blackthorne_unit_summonInEnd"] = { prefix = "boss_blackthorne_unit", from = 485, to = 493 },
	["boss_blackthorne_unit_summonInInit"] = { prefix = "boss_blackthorne_unit", from = 431, to = 436 },
	["boss_blackthorne_unit_summonInLoop"] = { prefix = "boss_blackthorne_unit", from = 437, to = 484 },
	["boss_blackthorne_unit_summonOut"] = { prefix = "boss_blackthorne_unit", from = 494, to = 538 },
	["boss_blackthorne_unit_taunt"] = { prefix = "boss_blackthorne_unit", from = 5, to = 32 },
	["boss_blackthorne_unit_tiefIn"] = { prefix = "boss_blackthorne_unit", from = 539, to = 548 },
	["boss_blackthorne_unit_tiefLoop"] = { prefix = "boss_blackthorne_unit", from = 549, to = 560 },
	["boss_blackthorne_unit_tiefOut"] = { prefix = "boss_blackthorne_unit", from = 561, to = 566 },
	["boss_blackthorne_unit_walk"] = { prefix = "boss_blackthorne_unit", from = 71, to = 98 },
	["boss_blackthorne_unit_walkDown"] = { prefix = "boss_blackthorne_unit", from = 127, to = 154 },
	["boss_blackthorne_unit_walkUp"] = { prefix = "boss_blackthorne_unit", from = 99, to = 126 },
	["boss_deep_king_block_tower_layerX_run"] = { prefix = "boss_deep_king_block_tower_layer", from = 1, to = 45, layer_from = 1, layer_to = 6, layer_prefix = "boss_deep_king_block_tower_layer%d" },
	["boss_deep_king_throne_layerX_idle"] = { prefix = "boss_deep_king_throne_layer", from = 51, to = 68, layer_from = 1, layer_to = 5, layer_prefix = "boss_deep_king_throne_layer%d" },
	["boss_deep_king_throne_layerX_out"] = { prefix = "boss_deep_king_throne_layer", from = 87, to = 146, layer_from = 1, layer_to = 5, layer_prefix = "boss_deep_king_throne_layer%d" },
	["boss_deep_king_throne_layerX_spawn"] = { prefix = "boss_deep_king_throne_layer", from = 1, to = 50, layer_from = 1, layer_to = 5, layer_prefix = "boss_deep_king_throne_layer%d" },
	["boss_deep_king_throne_layerX_taunt"] = { prefix = "boss_deep_king_throne_layer", from = 69, to = 86, layer_from = 1, layer_to = 5, layer_prefix = "boss_deep_king_throne_layer%d" },
	["boss_deep_king_unit_layerX_SpawnOut"] = { prefix = "boss_deep_king_unit_layer", from = 261, to = 304, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["boss_deep_king_unit_layerX_abiltyIn"] = { prefix = "boss_deep_king_unit_layer", from = 159, to = 197, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["boss_deep_king_unit_layerX_abiltyLoop"] = { prefix = "boss_deep_king_unit_layer", from = 196, to = 197, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["boss_deep_king_unit_layerX_abiltyOut"] = { prefix = "boss_deep_king_unit_layer", from = 198, to = 224, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["boss_deep_king_unit_layerX_attack"] = { prefix = "boss_deep_king_unit_layer", from = 132, to = 158, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["boss_deep_king_unit_layerX_death"] = { prefix = "boss_deep_king_unit_layer", from = 305, to = 326, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["boss_deep_king_unit_layerX_idle"] = { prefix = "boss_deep_king_unit_layer", from = 46, to = 47, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["boss_deep_king_unit_layerX_spawn"] = { prefix = "boss_deep_king_unit_layer", from = 1, to = 45, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["boss_deep_king_unit_layerX_summon"] = { prefix = "boss_deep_king_unit_layer", from = 225, to = 260, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["boss_deep_king_unit_layerX_taunt"] = { prefix = "boss_deep_king_unit_layer", from = 327, to = 334, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["boss_deep_king_unit_layerX_walk"] = { prefix = "boss_deep_king_unit_layer", from = 48, to = 75, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["boss_deep_king_unit_layerX_walkDown"] = { prefix = "boss_deep_king_unit_layer", from = 104, to = 131, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["boss_deep_king_unit_layerX_walkUp"] = { prefix = "boss_deep_king_unit_layer", from = 76, to = 103, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["stage41_boss_deep_king_unit_layerX_abiltyIn"] = { prefix = "boss_deep_king_unit_layer", from = 114, to = 150, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["stage41_boss_deep_king_unit_layerX_abiltyLoop"] = { prefix = "boss_deep_king_unit_layer", from = 151, to = 152, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["stage41_boss_deep_king_unit_layerX_abiltyOut"] = { prefix = "boss_deep_king_unit_layer", from = 153, to = 179, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["stage41_boss_deep_king_unit_layerX_attack"] = { prefix = "boss_deep_king_unit_layer", from = 87, to = 113, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["stage41_boss_deep_king_unit_layerX_death"] = { prefix = "boss_deep_king_unit_layer", from = 305, to = 326, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["stage41_boss_deep_king_unit_layerX_idle"] = { prefix = "boss_deep_king_unit_layer", from = 1, to = 2, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["stage41_boss_deep_king_unit_layerX_summon"] = { prefix = "boss_deep_king_unit_layer", from = 180, to = 215, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["stage41_boss_deep_king_unit_layerX_taunt"] = { prefix = "boss_deep_king_unit_layer", from = 216, to = 235, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["stage41_boss_deep_king_unit_layerX_walk"] = { prefix = "boss_deep_king_unit_layer", from = 3, to = 30, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["stage41_boss_deep_king_unit_layerX_walkDown"] = { prefix = "boss_deep_king_unit_layer", from = 59, to = 86, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["stage41_boss_deep_king_unit_layerX_walkUp"] = { prefix = "boss_deep_king_unit_layer", from = 31, to = 58, layer_from = 1, layer_to = 3, layer_prefix = "boss_deep_king_unit_layer%d" },
	["boss_ghost_cannon_explosion_run"] = { prefix = "boss_ghost_cannon_explosion", from = 1, to = 28 },
	["boss_ghost_remos_back_run"] = { prefix = "boss_ghost_remos_back", from = 1, to = 50 },
	["boss_ghost_remos_front_run"] = { prefix = "boss_ghost_remos_front", from = 1, to = 50 },
	["boss_ghost_ship_explosion_run"] = { prefix = "boss_ghost_ship_explosion", from = 1, to = 23 },
	["boss_ghost_ship_layerX_ability"] = { prefix = "boss_ghost_ship_layer", from = 57, to = 84, layer_from = 1, layer_to = 8, layer_prefix = "boss_ghost_ship_layer%d" },
	["boss_ghost_ship_layerX_attack"] = { prefix = "boss_ghost_ship_layer", from = 29, to = 56, layer_from = 1, layer_to = 8, layer_prefix = "boss_ghost_ship_layer%d" },
	["boss_ghost_ship_layerX_death"] = { prefix = "boss_ghost_ship_layer", from = 121, to = 212, layer_from = 1, layer_to = 8, layer_prefix = "boss_ghost_ship_layer%d" },
	["boss_ghost_ship_layerX_deathLoop"] = { prefix = "boss_ghost_ship_layer", from = 213, to = 213, layer_from = 1, layer_to = 8, layer_prefix = "boss_ghost_ship_layer%d" },
	["boss_ghost_ship_layerX_deathTaunt"] = { prefix = "boss_ghost_ship_layer", from = 214, to = 233, layer_from = 1, layer_to = 8, layer_prefix = "boss_ghost_ship_layer%d" },
	["boss_ghost_ship_layerX_spawn"] = { prefix = "boss_ghost_ship_layer", from = 85, to = 120, layer_from = 1, layer_to = 8, layer_prefix = "boss_ghost_ship_layer%d" },
	["boss_ghost_ship_layerX_taunt"] = { prefix = "boss_ghost_ship_layer", from = 234, to = 261, layer_from = 1, layer_to = 8, layer_prefix = "boss_ghost_ship_layer%d" },
	["boss_ghost_ship_layerX_walk"] = { prefix = "boss_ghost_ship_layer", from = 1, to = 28, layer_from = 1, layer_to = 8, layer_prefix = "boss_ghost_ship_layer%d" },
	["boss_ghost_ship_shield_layerX_run"] = { prefix = "boss_ghost_ship_shield_layer", from = 1, to = 12, layer_from = 1, layer_to = 1, layer_prefix = "boss_ghost_ship_shield_layer%d" },
	["boss_ghost_ship_vfx_death"] = { prefix = "boss_ghost_ship_vfx", from = 37, to = 128 },
	["boss_ghost_ship_vfx_spawn"] = { prefix = "boss_ghost_ship_vfx", from = 1, to = 36 },
	["boss_ghost_tail_flag_run"] = { prefix = "boss_ghost_tail_flag", from = 1, to = 39 },
	["boss_ghost_ui_block_in"] = { prefix = "boss_ghost_ui_block", from = 1, to = 18 },
	["boss_ghost_ui_block_out"] = { prefix = "boss_ghost_ui_block", from = 21, to = 40 },
	["boss_ghost_ui_block_run"] = { prefix = "boss_ghost_ui_block", from = 19, to = 20 },
	["boss_macaque_ability"] = { prefix = "boss_macaque", from = 112, to = 168 },
	["boss_macaque_attack"] = { prefix = "boss_macaque", from = 63, to = 111 },
	["boss_macaque_block_tower_layerX_idle"] = { prefix = "boss_macaque_block_tower_layer", from = 22, to = 22, layer_from = 1, layer_to = 2, layer_prefix = "boss_macaque_block_tower_layer%d" },
	["boss_macaque_block_tower_layerX_in"] = { prefix = "boss_macaque_block_tower_layer", from = 1, to = 21, layer_from = 1, layer_to = 2, layer_prefix = "boss_macaque_block_tower_layer%d" },
	["boss_macaque_block_tower_layerX_out"] = { prefix = "boss_macaque_block_tower_layer", from = 23, to = 43, layer_from = 1, layer_to = 2, layer_prefix = "boss_macaque_block_tower_layer%d" },
	["boss_macaque_idleIn"] = { prefix = "boss_macaque", from = 1, to = 42 },
	["boss_macaque_idleLoop"] = { prefix = "boss_macaque", from = 43, to = 46 },
	["boss_macaque_idleOut"] = { prefix = "boss_macaque", from = 169, to = 184 },
	["boss_macaque_ship_layerX_death"] = { prefix = "boss_macaque_ship_layer", from = 33, to = 72, layer_from = 1, layer_to = 9, layer_prefix = "boss_macaque_ship_layer%d" },
	["boss_macaque_ship_layerX_taunt"] = { prefix = "boss_macaque_ship_layer", from = 73, to = 80, layer_from = 1, layer_to = 9, layer_prefix = "boss_macaque_ship_layer%d" },
	["boss_macaque_ship_layerX_walk"] = { prefix = "boss_macaque_ship_layer", from = 1, to = 32, layer_from = 1, layer_to = 9, layer_prefix = "boss_macaque_ship_layer%d" },
	["boss_macaque_taunt"] = { prefix = "boss_macaque", from = 47, to = 62 },
	["boss_macaque_unit_layerX_attack"] = { prefix = "boss_macaque_unit_layer", from = 78, to = 136, layer_from = 1, layer_to = 3, layer_prefix = "boss_macaque_unit_layer%d" },
	["boss_macaque_unit_layerX_cannon"] = { prefix = "boss_macaque_unit_layer", from = 137, to = 194, layer_from = 1, layer_to = 3, layer_prefix = "boss_macaque_unit_layer%d" },
	["boss_macaque_unit_layerX_idle"] = { prefix = "boss_macaque_unit_layer", from = 1, to = 28, layer_from = 1, layer_to = 3, layer_prefix = "boss_macaque_unit_layer%d" },
	["boss_macaque_unit_layerX_summon"] = { prefix = "boss_macaque_unit_layer", from = 29, to = 77, layer_from = 1, layer_to = 3, layer_prefix = "boss_macaque_unit_layer%d" },
	["bucaneer_attack"] = { prefix = "bucaneer", from = 62, to = 88 },
	["bucaneer_attackArea"] = { prefix = "bucaneer", from = 89, to = 112 },
	["bucaneer_death"] = { prefix = "bucaneer", from = 113, to = 134 },
	["bucaneer_hit_run"] = { prefix = "bucaneer_hit", from = 1, to = 23 },
	["bucaneer_idle"] = { prefix = "bucaneer", from = 1, to = 1 },
	["bucaneer_modifier_run"] = { prefix = "bucaneer_modifier", from = 1, to = 20 },
	["bucaneer_proy_travel"] = { prefix = "bucaneer_proy", from = 1, to = 5 },
	["bucaneer_walk"] = { prefix = "bucaneer", from = 2, to = 21 },
	["bucaneer_walkDown"] = { prefix = "bucaneer", from = 22, to = 41 },
	["bucaneer_walkUp"] = { prefix = "bucaneer", from = 42, to = 61 },
	["bullshark_attack"] = { prefix = "bullshark", from = 74, to = 94 },
	["bullshark_buriedIn"] = { prefix = "bullshark", from = 95, to = 114 },
	["bullshark_buriedOut"] = { prefix = "bullshark", from = 151, to = 182 },
	["bullshark_buriedWalk"] = { prefix = "bullshark", from = 115, to = 126 },
	["bullshark_buriedWalkDown"] = { prefix = "bullshark", from = 139, to = 150 },
	["bullshark_buriedWalkUp"] = { prefix = "bullshark", from = 127, to = 138 },
	["bullshark_death"] = { prefix = "bullshark", from = 183, to = 207 },
	["bullshark_idle"] = { prefix = "bullshark", from = 1, to = 1 },
	["bullshark_spawn"] = { prefix = "bullshark", from = 208, to = 233 },
	["bullshark_walk"] = { prefix = "bullshark", from = 2, to = 25 },
	["bullshark_walkDown"] = { prefix = "bullshark", from = 26, to = 49 },
	["bullshark_walkUp"] = { prefix = "bullshark", from = 50, to = 73 },
	["bullsharksplash_run"] = { prefix = "bullshark_splash", from = 1, to = 23 },
	["cannon_sign_run"] = { prefix = "cannonsign", from = 1, to = 27 },
	["captain_fog_run"] = { prefix = "captain_fog", from = 1, to = 64 },
	["corpse_recruiter_attack"] = { prefix = "corpse_recruiter", from = 109, to = 144 },
	["corpse_recruiter_death"] = { prefix = "corpse_recruiter", from = 183, to = 205 },
	["corpse_recruiter_decal_run"] = { prefix = "corpse_recruiter_decal", from = 1, to = 14 },
	["corpse_recruiter_idle"] = { prefix = "corpse_recruiter", from = 1, to = 18 },
	["corpse_recruiter_projectil_hit"] = { prefix = "corpse_recruiter_porjectile", from = 13, to = 22 },
	["corpse_recruiter_projectil_travel"] = { prefix = "corpse_recruiter_porjectile", from = 1, to = 12 },
	["corpse_recruiter_shoot"] = { prefix = "corpse_recruiter", from = 73, to = 108 },
	["corpse_recruiter_summon"] = { prefix = "corpse_recruiter", from = 145, to = 182 },
	["corpse_recruiter_walk"] = { prefix = "corpse_recruiter", from = 19, to = 36 },
	["corpse_recruiter_walkDown"] = { prefix = "corpse_recruiter", from = 37, to = 54 },
	["corpse_recruiter_walkUp"] = { prefix = "corpse_recruiter", from = 55, to = 72 },
	["corsair_attack"] = { prefix = "corsair", from = 73, to = 95 },
	["corsair_death"] = { prefix = "corsair", from = 128, to = 145 },
	["corsair_heal"] = { prefix = "corsair", from = 96, to = 127 },
	["corsair_idle"] = { prefix = "corsair", from = 1, to = 1 },
	["corsair_walk"] = { prefix = "corsair", from = 2, to = 25 },
	["corsair_walkDown"] = { prefix = "corsair", from = 26, to = 49 },
	["corsair_walkUp"] = { prefix = "corsair", from = 50, to = 72 },
	["cuzor_death"] = { prefix = "cuzor", from = 65, to = 88 },
	["cuzor_idle"] = { prefix = "cuzor", from = 1, to = 16 },
	["cuzor_walk"] = { prefix = "cuzor", from = 17, to = 32 },
	["cuzor_walkDown"] = { prefix = "cuzor", from = 33, to = 48 },
	["cuzor_walkUp"] = { prefix = "cuzor", from = 49, to = 64 },
	["decal_one_boatswain_run"] = { prefix = "decal_one_boatswain", from = 1, to = 12 },
	["decal_two_boatswain_run"] = { prefix = "decal_two_boatswain", from = 1, to = 32 },
	["filibusters_one_attack"] = { prefix = "filibusters_one", from = 68, to = 89 },
	["filibusters_one_death"] = { prefix = "filibusters_one", from = 90, to = 102 },
	["filibusters_one_idle"] = { prefix = "filibusters_one", from = 1, to = 1 },
	["filibusters_one_walk"] = { prefix = "filibusters_one", from = 2, to = 23 },
	["filibusters_one_walkDown"] = { prefix = "filibusters_one", from = 46, to = 67 },
	["filibusters_one_walkUp"] = { prefix = "filibusters_one", from = 24, to = 45 },
	["filibusters_two_attack"] = { prefix = "filibusters_two", from = 68, to = 89 },
	["filibusters_two_death"] = { prefix = "filibusters_two", from = 90, to = 111 },
	["filibusters_two_idle"] = { prefix = "filibusters_two", from = 1, to = 1 },
	["filibusters_two_walk"] = { prefix = "filibusters_two", from = 2, to = 23 },
	["filibusters_two_walkDown"] = { prefix = "filibusters_two", from = 24, to = 45 },
	["filibusters_two_walkUp"] = { prefix = "filibusters_two", from = 46, to = 67 },
	["freebooter_attack"] = { prefix = "freebooter", from = 62, to = 80 },
	["freebooter_death"] = { prefix = "freebooter", from = 81, to = 98 },
	["freebooter_idle"] = { prefix = "freebooter", from = 1, to = 1 },
	["freebooter_walk"] = { prefix = "freebooter", from = 2, to = 21 },
	["freebooter_walkDown"] = { prefix = "freebooter", from = 22, to = 41 },
	["freebooter_walkUp"] = { prefix = "freebooter", from = 42, to = 61 },
	["garfio_layerX_idle"] = { prefix = "garfio_layer", from = 1, to = 40, layer_from = 1, layer_to = 2, layer_prefix = "garfio_layer%d" },
	["garfio_layerX_tap_One"] = { prefix = "garfio_layer", from = 41, to = 80, layer_from = 1, layer_to = 2, layer_prefix = "garfio_layer%d" },
	["garfio_layerX_tap_Two"] = { prefix = "garfio_layer", from = 81, to = 122, layer_from = 1, layer_to = 2, layer_prefix = "garfio_layer%d" },
	["garfio_layerX_tap_three"] = { prefix = "garfio_layer", from = 123, to = 192, layer_from = 1, layer_to = 2, layer_prefix = "garfio_layer%d" },
	["ghostly_barge_layerX_death"] = { prefix = "ghostly_barge_layer", from = 33, to = 48, layer_from = 1, layer_to = 1, layer_prefix = "ghostly_barge_layer%d" },
	["ghostly_barge_layerX_idle"] = { prefix = "ghostly_barge_layer", from = 1, to = 16, layer_from = 1, layer_to = 1, layer_prefix = "ghostly_barge_layer%d" },
	["ghostly_barge_modifier_run"] = { prefix = "ghostly_barge_modifier", from = 1, to = 16 },
	["ghostly_barge_layerX_walk"] = { prefix = "ghostly_barge_layer", from = 17, to = 32, layer_from = 1, layer_to = 1, layer_prefix = "ghostly_barge_layer%d" },
	["ghostly_barge_layerX_walkDown"] = { prefix = "ghostly_barge_layer", from = 17, to = 32, layer_from = 1, layer_to = 1, layer_prefix = "ghostly_barge_layer%d" },
	["ghostly_barge_layerX_walkUp"] = { prefix = "ghostly_barge_layer", from = 17, to = 32, layer_from = 1, layer_to = 1, layer_prefix = "ghostly_barge_layer%d" },
	["great_macaw_death"] = { prefix = "great_macaw", from = 49, to = 69 },
	["great_macaw_idle"] = { prefix = "great_macaw", from = 1, to = 16 },
	["great_macaw_walk"] = { prefix = "great_macaw", from = 1, to = 16 },
	["great_macaw_walkDown"] = { prefix = "great_macaw", from = 17, to = 32 },
	["great_macaw_walkUp"] = { prefix = "great_macaw", from = 33, to = 48 },
	["greensmoke_run"] = { prefix = "greensmoke", from = 1, to = 21 },
	["greensmoke_trail_run"] = { prefix = "smokegreen_trail", from = 1, to = 8 },
	["hammermage_attackMelee"] = { prefix = "hammermage", from = 74, to = 94 },
	["hammermage_attackRange"] = { prefix = "hammermage", from = 95, to = 118 },
	["hammermage_attackStun"] = { prefix = "hammermage", from = 119, to = 149 },
	["hammermage_block"] = { prefix = "hammermage", from = 150, to = 178 },
	["hammermage_death"] = { prefix = "hammermage", from = 179, to = 218 },
	["hammermage_idle"] = { prefix = "hammermage", from = 1, to = 1 },
	["hammermage_proyectile_hit"] = { prefix = "hammermage_proyectile", from = 9, to = 14 },
	["hammermage_proyectile_travel"] = { prefix = "hammermage_proyectile", from = 1, to = 8 },
	["hammermage_spawn"] = { prefix = "hammermage", from = 219, to = 237 },
	["hammermage_tower_block_in"] = { prefix = "hammermage_tower_block", from = 1, to = 22 },
	["hammermage_tower_block_loop"] = { prefix = "hammermage_tower_block", from = 23, to = 60 },
	["hammermage_tower_block_out"] = { prefix = "hammermage_tower_block", from = 61, to = 75 },
	["hammermage_walk"] = { prefix = "hammermage", from = 2, to = 25 },
	["hammermage_walkDown"] = { prefix = "hammermage", from = 26, to = 49 },
	["hammermage_walkUp"] = { prefix = "hammermage", from = 50, to = 73 },
	["hammermageattack_run"] = { prefix = "hammermage_attack", from = 1, to = 19 },
	["hanged_captain_attackArea"] = { prefix = "hanged_captain", from = 100, to = 141 },
	["hanged_captain_attackMelee"] = { prefix = "hanged_captain", from = 142, to = 187 },
	["hanged_captain_death"] = { prefix = "hanged_captain", from = 212, to = 238 },
	["hanged_captain_decal_run"] = { prefix = "hanged_captain_decal", from = 1, to = 22 },
	["hanged_captain_idle"] = { prefix = "hanged_captain", from = 1, to = 24 },
	["hanged_captain_spawn"] = { prefix = "hanged_captain", from = 188, to = 211 },
	["hanged_captain_walk"] = { prefix = "hanged_captain", from = 25, to = 49 },
	["hanged_captain_walkDown"] = { prefix = "hanged_captain", from = 75, to = 99 },
	["hanged_captain_walkUp"] = { prefix = "hanged_captain", from = 50, to = 74 },
	["house_parrot_idle"] = { prefix = "house_parrot", from = 1, to = 2 },
	["house_parrot_run"] = { prefix = "house_parrot", from = 3, to = 25 },
	["lemonshark_attack"] = { prefix = "lemonshark", from = 62, to = 80 },
	["lemonshark_death"] = { prefix = "lemonshark", from = 81, to = 98 },
	["lemonshark_idle"] = { prefix = "lemonshark", from = 1, to = 1 },
	["lemonshark_spawn"] = { prefix = "lemonshark", from = 99, to = 114 },
	["lemonshark_walk"] = { prefix = "lemonshark", from = 2, to = 21 },
	["lemonshark_walkDown"] = { prefix = "lemonshark", from = 22, to = 41 },
	["lemonshark_walkUp"] = { prefix = "lemonshark", from = 42, to = 61 },
	["megalodon_attack"] = { prefix = "megalodon", from = 87, to = 126 },
	["megalodon_blood_run"] = { prefix = "megalodon_blood", from = 1, to = 45 },
	["megalodon_death"] = { prefix = "megalodon", from = 127, to = 171 },
	["megalodon_idle"] = { prefix = "megalodon", from = 1, to = 2 },
	["megalodon_spawn"] = { prefix = "megalodon", from = 172, to = 193 },
	["megalodon_walk"] = { prefix = "megalodon", from = 3, to = 30 },
	["megalodon_walkDown"] = { prefix = "megalodon", from = 31, to = 58 },
	["megalodon_walkUp"] = { prefix = "megalodon", from = 59, to = 86 },
	["parrot_attack"] = { prefix = "parrot", from = 59, to = 72 },
	["parrot_attackDown"] = { prefix = "parrot", from = 31, to = 44 },
	["parrot_attackUp"] = { prefix = "parrot", from = 45, to = 58 },
	["parrot_death"] = { prefix = "parrot", from = 73, to = 102 },
	["parrot_idle"] = { prefix = "parrot", from = 1, to = 10 },
	["parrot_twoDeath"] = { prefix = "parrot", from = 145, to = 175 },
	["parrot_twoWalk"] = { prefix = "parrot", from = 103, to = 116 },
	["parrot_twoWalkDown"] = { prefix = "parrot", from = 131, to = 144 },
	["parrot_twoWalkUp"] = { prefix = "parrot", from = 117, to = 130 },
	["parrot_walk"] = { prefix = "parrot", from = 1, to = 10 },
	["parrot_walkDown"] = { prefix = "parrot", from = 21, to = 30 },
	["parrot_walkUp"] = { prefix = "parrot", from = 11, to = 20 },
	["parrotproy_travel"] = { prefix = "parrot_proy", from = 1, to = 4 },
	["regenshark_run"] = { prefix = "regen_sharks", from = 1, to = 26 },
	["risen_cutthroat_attack"] = { prefix = "risen_cutthroat", from = 99, to = 124 },
	["risen_cutthroat_death"] = { prefix = "risen_cutthroat", from = 125, to = 152 },
	["risen_cutthroat_idle"] = { prefix = "risen_cutthroat", from = 1, to = 14 },
	["risen_cutthroat_spawn"] = { prefix = "risen_cutthroat", from = 153, to = 170 },
	["risen_cutthroat_walk"] = { prefix = "risen_cutthroat", from = 15, to = 41 },
	["risen_cutthroat_walkDown"] = { prefix = "risen_cutthroat", from = 42, to = 70 },
	["risen_cutthroat_walkUp"] = { prefix = "risen_cutthroat", from = 71, to = 98 },
	["rushing_monkey_death"] = { prefix = "rushing_monkey", from = 39, to = 56 },
	["rushing_monkey_idle"] = { prefix = "rushing_monkey", from = 1, to = 1 },
	["rushing_monkey_rollWalk"] = { prefix = "rushing_monkey", from = 78, to = 89 },
	["rushing_monkey_rollWalkDown"] = { prefix = "rushing_monkey", from = 90, to = 100 },
	["rushing_monkey_rollWalkUp"] = { prefix = "rushing_monkey", from = 101, to = 111 },
	["rushing_monkey_spawn"] = { prefix = "rushing_monkey", from = 57, to = 77 },
	["rushing_monkey_walk"] = { prefix = "rushing_monkey", from = 2, to = 14 },
	["rushing_monkey_walkDown"] = { prefix = "rushing_monkey", from = 15, to = 26 },
	["rushing_monkey_walkUp"] = { prefix = "rushing_monkey", from = 27, to = 38 },
	["shadow_veznans_prisoner_box_big_run"] = { prefix = "shadow_veznans_prisoner_box_big", from = 1, to = 94 },
	["shadow_veznans_prisoner_box_small_run"] = { prefix = "shadow_veznans_prisoner_box_small", from = 1, to = 100 },
	["ship_blackcorsair_layerX_idle"] = { prefix = "ship_blackcorsair_layer", from = 1, to = 14, layer_from = 1, layer_to = 2, layer_prefix = "ship_blackcorsair_layer%d" },
	["ship_blackcorsair_layerX_idleShip"] = { prefix = "ship_blackcorsair_layer", from = 63, to = 76, layer_from = 1, layer_to = 2, layer_prefix = "ship_blackcorsair_layer%d" },
	["ship_blackcorsair_layerX_signal"] = { prefix = "ship_blackcorsair_layer", from = 15, to = 62, layer_from = 1, layer_to = 2, layer_prefix = "ship_blackcorsair_layer%d" },
	["ship_blackcorsair_layerX_signalShip"] = { prefix = "ship_blackcorsair_layer", from = 77, to = 124, layer_from = 1, layer_to = 2, layer_prefix = "ship_blackcorsair_layer%d" },
	["ship_blackcorsair_layerX_taunt"] = { prefix = "ship_blackcorsair_layer", from = 125, to = 136, layer_from = 1, layer_to = 2, layer_prefix = "ship_blackcorsair_layer%d" },
	["ship_cannons_blackcorsair_attack"] = { prefix = "ship_cannons_blackcorsair", from = 2, to = 36 },
	["ship_cannons_blackcorsair_idle"] = { prefix = "ship_cannons_blackcorsair", from = 1, to = 1 },
	["ship_cannonsback_blackcorsair_attack"] = { prefix = "ship_cannonsback_blackcorsair", from = 2, to = 38 },
	["ship_cannonsback_blackcorsair_idle"] = { prefix = "ship_cannonsback_blackcorsair", from = 1, to = 1 },
	["ship_escapes_blackcorsair_run"] = { prefix = "ship_escapes_blackcorsair", from = 113, to = 126 },
	["ship_escapes_blackcorsair_start"] = { prefix = "ship_escapes_blackcorsair", from = 1, to = 112 },
	["ship_motor_blackcorsair_run"] = { prefix = "ship_motor_blackcorsair", from = 111, to = 119 },
	["ship_motor_blackcorsair_start"] = { prefix = "ship_motor_blackcorsair", from = 1, to = 110 },
	["ship_vela_blackcorsair_run"] = { prefix = "ship_vela_blackcorsair", from = 1, to = 16 },
	["ship_water_blackcorsair_run"] = { prefix = "ship_water_blackcorsair", from = 1, to = 16 },
	["stage37_prop_animado_barril01_run"] = { prefix = "stage37_prop_animado_barril01", from = 1, to = 40 },
	["stage37_prop_animado_barril02_run"] = { prefix = "stage37_prop_animado_barril02", from = 1, to = 40 },
	["stage37_prop_animado_flag_run"] = { prefix = "stage37_prop_animado_flag", from = 1, to = 40 },
	["stage37_prop_animado_pollo01_explode"] = { prefix = "stage37_prop_animado_pollo_death", from = 1, to = 30 },
	["stage37_prop_animado_pollo01_run"] = { prefix = "stage37_prop_animado_pollo01", from = 1, to = 40 },
	["stage37_prop_animado_pollo02_explode"] = { prefix = "stage37_prop_animado_pollo_death", from = 1, to = 30 },
	["stage37_prop_animado_pollo02_run"] = { prefix = "stage37_prop_animado_pollo02", from = 1, to = 40 },
	["stage37_prop_animado_tabla01_run"] = { prefix = "stage37_prop_animado_tabla01", from = 1, to = 40 },
	["stage37_prop_animado_tabla02_run"] = { prefix = "stage37_prop_animado_tabla02", from = 1, to = 40 },
	["stage37_prop_animado_water_flag_run"] = { prefix = "stage37_prop_animado_water_flag", from = 1, to = 40 },
	["stage37_prop_animado_watership_run"] = { prefix = "stage37_prop_animado_watership", from = 1, to = 40 },
	["stage38_cannon_attack"] = { prefix = "Stage38_canon_attack", from = 1, to = 17 },
	["stage38_cannon_explotion_run"] = { prefix = "Stage38_canon_explotion", from = 1, to = 20 },
	["stage38_cannon_in"] = { prefix = "Stage38_canon_in", from = 1, to = 30 },
	["stage38_cannon_palmer_explotion_run"] = { prefix = "palmer_explotion", from = 1, to = 30 },
	["stage38_cannon_patch_open"] = { prefix = "Stage38_canon", from = 1, to = 24 },
	["stage38_cannon_patch_run"] = { prefix = "Stage38_canon", from = 1, to = 1 },
	["stage38_cannon_run"] = { prefix = "Stage38_canon_in", from = 1, to = 1 },
	["stage38_cannon_smoke_run"] = { prefix = "Stage38_canon_puff", from = 1, to = 15 },
	["stage38_water_details_run"] = { prefix = "stage38_water_details", from = 1, to = 40 },
	["stage38_waterfall_run"] = { prefix = "Stage38_waterfall", from = 1, to = 16 },
	["stage41_burst_burst"] = { prefix = "stage_41_burst", from = 1, to = 22 },
	["stage41_gold_idle"] = { prefix = "stage_41_gold", from = 17, to = 17 },
	["stage41_gold_run"] = { prefix = "stage_41_gold", from = 1, to = 16 },
	["stage_40_fire_torch_idle"] = { prefix = "stage_40_fire_torch", from = 1, to = 12 },
	["stage_40_lightning_flash"] = { prefix = "stage_40_lightning", from = 19, to = 73 },
	["stage_40_lightning_idle"] = { prefix = "stage_40_lightning", from = 1, to = 18 },
	["stage_40_lightning_lightning"] = { prefix = "stage_40_lightning", from = 74, to = 102 },
	["stone_ball_death"] = { prefix = "stone_ball", from = 25, to = 51 },
	["stone_ball_idle"] = { prefix = "stone_ball", from = 1, to = 24 },
	["stone_ball_walk"] = { prefix = "stone_ball", from = 1, to = 24 },
	["stone_ball_walkDown"] = { prefix = "stone_ball", from = 1, to = 24 },
	["stone_ball_walkUp"] = { prefix = "stone_ball", from = 1, to = 24 },
	["summonwater_run"] = { prefix = "summonwater", from = 1, to = 15 },
	["tailblade_death"] = { prefix = "tailblade", from = 126, to = 143 },
	["tailblade_dodge"] = { prefix = "tailblade", from = 110, to = 125 },
	["tailblade_hit_run"] = { prefix = "tailblade_hit", from = 1, to = 8 },
	["tailblade_idle"] = { prefix = "tailblade", from = 1, to = 1 },
	["tailblade_melee"] = { prefix = "tailblade", from = 68, to = 91 },
	["tailblade_range"] = { prefix = "tailblade", from = 92, to = 109 },
	["tailblade_walk"] = { prefix = "tailblade", from = 2, to = 23 },
	["tailblade_walkDown"] = { prefix = "tailblade", from = 24, to = 45 },
	["tailblade_walkUp"] = { prefix = "tailblade", from = 46, to = 67 },
	["tigershark_attack"] = { prefix = "tigershark", from = 50, to = 85 },
	["tigershark_buff"] = { prefix = "tigershark", from = 86, to = 108 },
	["tigershark_death"] = { prefix = "tigershark", from = 109, to = 133 },
	["tigershark_idle"] = { prefix = "tigershark", from = 1, to = 1 },
	["tigershark_spawn"] = { prefix = "tigershark", from = 134, to = 148 },
	["tigershark_walk"] = { prefix = "tigershark", from = 2, to = 17 },
	["tigershark_walkDown"] = { prefix = "tigershark", from = 18, to = 33 },
	["tigershark_walkUp"] = { prefix = "tigershark", from = 34, to = 49 },
	["tigersharkbuff_run"] = { prefix = "tigershark_buff", from = 1, to = 16 },
	["veznans_prisoner_box_big_layerX_run"] = { prefix = "veznans_prisoner_box_big_layer", from = 1, to = 94, layer_from = 1, layer_to = 5, layer_prefix = "veznans_prisoner_box_big_layer%d" },
	["veznans_prisoner_box_small_layerX_run"] = { prefix = "veznans_prisoner_box_small_layer", from = 1, to = 100, layer_from = 1, layer_to = 5, layer_prefix = "veznans_prisoner_box_small_layer%d" },
	["water_sparks_run"] = { prefix = "water_sparks", from = 1, to = 85 }
}
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/kr4_pirates_campaign.lua

-- BEGIN kr3/data/animations/kr4_power_reinforcements.lua
do
	local __chunk = (function()
return {
	["reinforcement_demon_summon_run"] = { prefix = "reinforcement_demon_summon", from = 1, to = 22 },

	["reinforcement_demon_goonie_idle"] = { prefix = "reinforcement_demon_goonie", from = 1, to = 1 },
	["reinforcement_demon_goonie_walk"] = { prefix = "reinforcement_demon_goonie", from = 2, to = 13 },
	["reinforcement_demon_goonie_attack"] = { prefix = "reinforcement_demon_goonie", from = 14, to = 33 },
	["reinforcement_demon_goonie_death"] = { prefix = "reinforcement_demon_goonie", from = 34, to = 47 },
	["reinforcement_demon_goonie_infernalCombustionDeath"] = { prefix = "reinforcement_demon_goonie", from = 48, to = 80 },

	["reinforcement_improved_goonie_idle"] = { prefix = "reinforcement_improved_goonie", from = 1, to = 1 },
	["reinforcement_improved_goonie_walk"] = { prefix = "reinforcement_improved_goonie", from = 2, to = 13 },
	["reinforcement_improved_goonie_attack"] = { prefix = "reinforcement_improved_goonie", from = 14, to = 35 },
	["reinforcement_improved_goonie_death"] = { prefix = "reinforcement_improved_goonie", from = 36, to = 72 },
	["reinforcement_improved_goonie_infernalCombustionDeath"] = { prefix = "reinforcement_improved_goonie", from = 36, to = 72 },

	["reinforcement_demon_guard_idle"] = { prefix = "reinforcement_demon_guard", from = 1, to = 1 },
	["reinforcement_demon_guard_walk"] = { prefix = "reinforcement_demon_guard", from = 2, to = 17 },
	["reinforcement_demon_guard_attack"] = { prefix = "reinforcement_demon_guard", from = 18, to = 37 },
	["reinforcement_demon_guard_death"] = { prefix = "reinforcement_demon_guard", from = 38, to = 69 },
	["reinforcement_demon_guard_infernalNovaDeath"] = { prefix = "reinforcement_demon_guard", from = 70, to = 106 },

	["reinforcement_hellion_trident_idle"] = { prefix = "reinforcement_hellion_trident", from = 1, to = 1 },
	["reinforcement_hellion_trident_walk"] = { prefix = "reinforcement_hellion_trident", from = 2, to = 15 },
	["reinforcement_hellion_trident_attack"] = { prefix = "reinforcement_hellion_trident", from = 16, to = 35 },
	["reinforcement_hellion_trident_ranged"] = { prefix = "reinforcement_hellion_trident", from = 36, to = 57 },
	["reinforcement_hellion_trident_death"] = { prefix = "reinforcement_hellion_trident", from = 58, to = 87 },
	["reinforcement_hellion_trident_infernalCombustionDeath"] = { prefix = "reinforcement_hellion_trident", from = 58, to = 87 },
	["reinforcement_hellion_trident_proyectile_floor_run"] = { prefix = "reinforcement_hellion_trident_proyectile_floor", from = 1, to = 6 },

	["reinforcement_flaming_trident_idle"] = { prefix = "reinforcement_flaming_trident", from = 1, to = 10 },
	["reinforcement_flaming_trident_walk"] = { prefix = "reinforcement_flaming_trident", from = 11, to = 24 },
	["reinforcement_flaming_trident_attack"] = { prefix = "reinforcement_flaming_trident", from = 25, to = 44 },
	["reinforcement_flaming_trident_ranged"] = { prefix = "reinforcement_flaming_trident", from = 45, to = 66 },
	["reinforcement_flaming_trident_death"] = { prefix = "reinforcement_flaming_trident", from = 67, to = 96 },
	["reinforcement_flaming_trident_infernalCombustionDeath"] = { prefix = "reinforcement_flaming_trident", from = 67, to = 96 },
	["reinforcement_flaming_trident_fire_run"] = { prefix = "reinforcement_flaming_trident_fire", from = 1, to = 20 },
	["reinforcement_flaming_trident_proyectile_travel"] = { prefix = "reinforcement_flaming_trident_proyectile", from = 1, to = 8 },
	["reinforcement_flaming_trident_proyectile_floor_run"] = { prefix = "reinforcement_flaming_trident_proyectile_floor", from = 1, to = 14 },

	["reinforcement_pit_lord_idle"] = { prefix = "reinforcement_pit_lord", from = 1, to = 1 },
	["reinforcement_pit_lord_summon"] = { prefix = "reinforcement_pit_lord", from = 2, to = 36 },
	["reinforcement_pit_lord_walk"] = { prefix = "reinforcement_pit_lord", from = 37, to = 56 },
	["reinforcement_pit_lord_inMelee"] = { prefix = "reinforcement_pit_lord", from = 57, to = 79 },
	["reinforcement_pit_lord_idleBlock"] = { prefix = "reinforcement_pit_lord", from = 80, to = 87 },
	["reinforcement_pit_lord_melee"] = { prefix = "reinforcement_pit_lord", from = 88, to = 107 },
	["reinforcement_pit_lord_outMelee"] = { prefix = "reinforcement_pit_lord", from = 108, to = 115 },
	["reinforcement_pit_lord_ranged"] = { prefix = "reinforcement_pit_lord", from = 116, to = 150 },
	["reinforcement_pit_lord_death"] = { prefix = "reinforcement_pit_lord", from = 151, to = 187 },
	["reinforcement_pit_lord_proyectile_travel"] = { prefix = "reinforcement_pit_lord_proyectile", from = 1, to = 10 },
	["reinforcement_pit_lord_explosion_run"] = { prefix = "reinforcement_pit_lord_explosion", from = 1, to = 14 },
	["reinforcement_pit_lord_explosion_floor_run"] = { prefix = "reinforcement_pit_lord_explosion_floor", from = 1, to = 14 },

	["power_soul_impact_run"] = { prefix = "power_soul_impact", from = 1, to = 16 },
	["power_soul_impact_explosion_run"] = { prefix = "power_soul_impact_explosion", from = 1, to = 39 },
	["power_soul_impact_bolt_flying"] = { prefix = "power_soul_impact_bolt", from = 1, to = 1 },
	["power_soul_impact_bolt_travel"] = { prefix = "power_soul_impact_bolt", from = 1, to = 1 },
	["power_soul_impact_bolt_hit"] = { prefix = "power_soul_impact_bolt", from = 1, to = 12 },
	["power_soul_impact_bolt_particle_1_run"] = { prefix = "power_soul_impact_bolt_particle_1", from = 1, to = 10 },
	["power_soul_impact_bolt_particle_2_run"] = { prefix = "power_soul_impact_bolt_particle_2", from = 1, to = 10 },

	["death_ray_layer1_run"] = { prefix = "death_ray_layer1", from = 1, to = 1 },
	["death_ray_layer1_charge"] = { prefix = "death_ray_layer1", from = 2, to = 20 },
	["death_ray_layer1_shoot"] = { prefix = "death_ray_layer1", from = 21, to = 33 },
	["death_ray_layer2_run"] = { prefix = "death_ray_layer2", from = 1, to = 1 },
	["death_ray_layer2_charge"] = { prefix = "death_ray_layer2", from = 2, to = 20 },
	["death_ray_layer2_shoot"] = { prefix = "death_ray_layer2", from = 21, to = 33 },
	["death_ray_projectile_travel"] = { prefix = "death_ray_projectile", from = 1, to = 13 },
	["death_ray_projectile_hit_run"] = { prefix = "death_ray_projectile_hit", from = 1, to = 12 },
}
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/kr4_power_reinforcements.lua

-- BEGIN kr3/data/animations/stage25_decos.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/stage25_decos.lua

local a = {
	Stage_25_reflejos_agua_run = {
		prefix = "Stage_25_reflejos_agua",
		to = 30,
		from = 1
	},
	Stage_25_waves_h_run = {
		prefix = "Stage_25_waves_h",
		to = 27,
		from = 1
	},
	Stage_25_waves_v_run = {
		prefix = "Stage_25_waves_v",
		to = 27,
		from = 1
	},
	DLC_stage_03_missile_decal_tower_loop = {
		prefix = "DLC_stage_03_missile_decal_tower",
		to = 16,
		from = 1
	},
	DLC_stage_03_missile_particle = {
		prefix = "DLC_stage_03_missile_particle",
		to = 15,
		from = 1
	},
	DLC_stage_03_missile_projectile = {
		prefix = "DLC_stage_03_missile_projectile",
		to = 1,
		from = 1
	},
	DLC_stage_03_missile_hit_run = {
		prefix = "DLC_stage_03_missile_hit",
		to = 33,
		from = 1
	},
	DLC_stage_03_missile_water_splash = {
		prefix = "DLC_stage_03_missile_water_splash",
		to = 14,
		from = 1
	},
	DLC_stage_03_missile_tower_fx_loop = {
		prefix = "DLC_stage_03_missile_tower_fx",
		to = 40,
		from = 1
	},
	DLC_stage_03_missile_tower_block_tap_tap = {
		prefix = "DLC_stage_03_missile_tower_block_tap",
		to = 10,
		from = 1
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/stage25_decos.lua

-- BEGIN kr3/data/animations/stage36_decos.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/stage36_decos.lua

local a = {
	stage36_efecto_polvo_run = {
		prefix = "stage36_efecto_polvo",
		to = 22,
		from = 1
	},
	portal_efecto_salida_run = {
		prefix = "portal_efecto_salida",
		to = 40,
		from = 1
	},
	spyro_me_fx_humo_run = {
		prefix = "spyro_me_fx_humo",
		to = 14,
		from = 1
	},
	spyro_me_creep_idle = {
		prefix = "spyro_me_creep",
		to = 20,
		from = 1
	},
	spyro_me_creep_fly_in = {
		prefix = "spyro_me_creep",
		to = 36,
		from = 21
	},
	spyro_me_creep_fly_loop = {
		prefix = "spyro_me_creep",
		to = 61,
		from = 37
	},
	spyro_me_creep_fly_out = {
		prefix = "spyro_me_creep",
		to = 73,
		from = 62
	},
	spyro_me_creep_idle2 = {
		prefix = "spyro_me_creep",
		to = 93,
		from = 74
	},
	spyro_me_creep_death = {
		prefix = "spyro_me_creep",
		to = 175,
		from = 94
	},
	ranger_verde_character_idle1 = {
		prefix = "ranger_verde_character",
		to = 30,
		from = 1
	},
	ranger_verde_character_transform = {
		prefix = "ranger_verde_character",
		to = 125,
		from = 31
	},
	ranger_verde_character_ranger_idle = {
		prefix = "ranger_verde_character",
		to = 149,
		from = 126
	},
	ranger_verde_character_ranger_idle_rayo = {
		prefix = "ranger_verde_character",
		to = 174,
		from = 150
	},
	ranger_verde_character_tap_2 = {
		prefix = "ranger_verde_character",
		to = 423,
		from = 175
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/stage36_decos.lua

-- BEGIN kr3/data/animations/stage37_decos.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/stage37_decos.lua

local a = {
	train_dragon_characters_idle1 = {
		prefix = "train_dragon_characters",
		to = 124,
		from = 1
	},
	train_dragon_characters_tap1 = {
		prefix = "train_dragon_characters",
		to = 208,
		from = 125
	},
	train_dragon_characters_idle2 = {
		prefix = "train_dragon_characters",
		to = 209,
		from = 209
	},
	train_dragon_characters_tap2 = {
		prefix = "train_dragon_characters",
		to = 289,
		from = 210
	},
	stage_37_anim_props_puente_idle = {
		prefix = "stage_37_anim_props_puente",
		to = 1,
		from = 1
	},
	stage_37_anim_props_puente_out = {
		prefix = "stage_37_anim_props_puente",
		to = 2,
		from = 2
	},
	stage_37_anim_props_spawner_idle = {
		prefix = "stage_37_anim_props_spawner",
		to = 1,
		from = 1
	},
	stage_37_anim_props_spawner_idle_over = {
		prefix = "stage_37_anim_props_spawner",
		to = 1,
		from = 1
	},
	stage_37_anim_props_spawner_spawn = {
		prefix = "stage_37_anim_props_spawner",
		to = 79,
		from = 2
	},
	stage_37_anim_props_spawner_spawn_over = {
		prefix = "stage_37_anim_props_spawner",
		to = 79,
		from = 2
	},	
	stage_37_anim_props_spawner_out = {
		prefix = "stage_37_anim_props_spawner",
		to = 80,
		from = 80
	},
	stage_37_anim_props_spawner_out_over = {
		prefix = "stage_37_anim_props_spawner",
		to = 80,
		from = 80
	},	
	stage_37_anim_props_dragon_eyes_spawn_in = {
		prefix = "stage_37_anim_props_dragon_eyes_spawn",
		to = 75,
		from = 1
	},
	warden_warlock_hit_run = {
		prefix = "warden_warlock_hit",
		to = 15,
		from = 1
	},
	warden_warlock_trail_run = {
		prefix = "warden_warlock_trail",
		to = 9,
		from = 1
	},
	warden_warlock_projectil_run = {
		prefix = "warden_warlock_projectil",
		to = 9,
		from = 1
	},
	warden_warlock_warden_warrior_idle = {
		prefix = "warden_warlock_warden_warrior",
		to = 10,
		from = 1
	},
	warden_warlock_warden_warrior_attack_front = {
		prefix = "warden_warlock_warden_warrior",
		to = 61,
		from = 11
	},
	warden_warlock_warden_warrior_attack_back = {
		prefix = "warden_warlock_warden_warrior",
		to = 112,
		from = 62
	},
	warden_warlock_warden_warrior_idle_back = {
		prefix = "warden_warlock_warden_warrior",
		to = 122,
		from = 113
	},
	destruccion_torres_stage_37_torre_3_front_idle_sana = {
		prefix = "destruccion_torres_stage_37_torre_3_front",
		to = 1,
		from = 1
	},
	destruccion_torres_stage_37_torre_3_front_destruccion_torre = {
		prefix = "destruccion_torres_stage_37_torre_3_front",
		to = 45,
		from = 2
	},
	destruccion_torres_stage_37_torre_3_front_idle_rota = {
		prefix = "destruccion_torres_stage_37_torre_3_front",
		to = 46,
		from = 46
	},
	destruccion_torres_stage_37_torre_3_back_idle_sana = {
		prefix = "destruccion_torres_stage_37_torre_3_back",
		to = 1,
		from = 1
	},
	destruccion_torres_stage_37_torre_3_back_destruccion_torre = {
		prefix = "destruccion_torres_stage_37_torre_3_back",
		to = 45,
		from = 2
	},
	destruccion_torres_stage_37_torre_3_back_idle_rota = {
		prefix = "destruccion_torres_stage_37_torre_1_back",
		to = 1,
		from = 1
	},
	destruccion_torres_stage_37_torre_2_front_idle_sana = {
		prefix = "destruccion_torres_stage_37_torre_2_front",
		to = 1,
		from = 1
	},
	destruccion_torres_stage_37_torre_2_front_destruccion_torre = {
		prefix = "destruccion_torres_stage_37_torre_2_front",
		to = 45,
		from = 2
	},
	destruccion_torres_stage_37_torre_2_front_idle_rota = {
		prefix = "destruccion_torres_stage_37_torre_2_front",
		to = 46,
		from = 46
	},
	destruccion_torres_stage_37_torre_2_back_idle_sana = {
		prefix = "destruccion_torres_stage_37_torre_2_back",
		to = 1,
		from = 1
	},
	destruccion_torres_stage_37_torre_2_back_destruccion_torre = {
		prefix = "destruccion_torres_stage_37_torre_2_back",
		to = 45,
		from = 2
	},
	destruccion_torres_stage_37_torre_2_back_idle_rota = {
		prefix = "destruccion_torres_stage_37_torre_1_back",
		to = 1,
		from = 1
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/stage37_decos.lua

-- BEGIN kr3/data/animations/stage38_decos.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/stage38_decos.lua

local a = {
	warden_warlock_stage3_warden_warrior_idle = {
		prefix = "warden_warlock_stage3_warden_warrior",
		to = 1,
		from = 1
	},
	warden_warlock_stage3_warden_warrior_attack_front = {
		prefix = "warden_warlock_stage3_warden_warrior",
		to = 34,
		from = 2
	},
	warden_warlock_stage3_warden_warrior_walk = {
		prefix = "warden_warlock_stage3_warden_warrior",
		to = 55,
		from = 36
	},
	warden_warlock_stage3_warden_warrior_death = {
		prefix = "warden_warlock_stage3_warden_warrior",
		to = 79,
		from = 56
	},
	warden_warlock_stage3_warden_warrior_spawn = {
		prefix = "warden_warlock_stage3_warden_warrior",
		to = 105,
		from = 80
	},
	warden_warlock_stage3_globo_rider_in = {
		prefix = "warden_warlock_stage3_globo_rider",
		to = 8,
		from = 1
	},
	warden_warlock_stage3_globo_rider_loop = {
		prefix = "warden_warlock_stage3_globo_rider",
		to = 34,
		from = 9
	},
	warden_warlock_stage3_globo_rider_out = {
		prefix = "warden_warlock_stage3_globo_rider",
		to = 45,
		from = 35
	},
	warden_warlock_stage3_dragon_rider_idle = {
		prefix = "warden_warlock_stage3_dragon_rider",
		to = 16,
		from = 1
	},
	warden_warlock_stage3_dragon_rider_walk = {
		prefix = "warden_warlock_stage3_dragon_rider",
		to = 16,
		from = 1
	},
	warden_warlock_stage3_dragon_rider_fly = {
		prefix = "warden_warlock_stage3_dragon_rider",
		to = 16,
		from = 1
	},
	warden_warlock_stage3_dragon_rider_attack = {
		prefix = "warden_warlock_stage3_dragon_rider",
		to = 48,
		from = 17
	},
	warden_warlock_stage3_dragon_rider_death_rider = {
		prefix = "warden_warlock_stage3_dragon_rider",
		to = 72,
		from = 49
	},
	warden_warlock_stage3_dragon_rider_death_dragon = {
		prefix = "warden_warlock_stage3_dragon_rider",
		to = 100,
		from = 75
	},
	warden_warlock_stage3_hit_run = {
		prefix = "warden_warlock_stage3_hit",
		to = 15,
		from = 1
	},
	warden_warlock_stage3_trail_run = {
		prefix = "warden_warlock_stage3_trail",
		to = 9,
		from = 1
	},
	warden_warlock_stage3_projectil_flying = {
		prefix = "warden_warlock_stage3_projectil",
		to = 9,
		from = 1
	},
	warden_warlock_stage3_shadow_run = {
		prefix = "warden_warlock_stage3_shadow",
		to = 1,
		from = 1
	},
	wardens_dragon_house_spawner_idle = {
		prefix = "wardens_dragon_house_spawner",
		to = 1,
		from = 1
	},
	wardens_dragon_house_spawner_idle_over = {
		prefix = "wardens_dragon_house_spawner",
		to = 1,
		from = 1
	},
	wardens_dragon_house_spawner_spawn = {
		prefix = "wardens_dragon_house_spawner",
		to = 78,
		from = 2
	},
	ender_egg_mask_run = {
		prefix = "ender_egg_mask",
		to = 1,
		from = 1
	},
	ender_egg_particle_explosion_run = {
		prefix = "ender_egg_particle_explosion",
		to = 34,
		from = 1
	},
	ender_egg_particle_drop_run = {
		prefix = "ender_egg_particle_drop",
		to = 38,
		from = 1
	},
	ender_egg_egg_idle = {
		prefix = "ender_egg_egg",
		to = 1,
		from = 1
	},
	ender_egg_egg_tp_out = {
		prefix = "ender_egg_egg",
		to = 9,
		from = 2
	},
	ender_egg_egg_tp_in = {
		prefix = "ender_egg_egg",
		to = 27,
		from = 10
	},
	yamcha_warlok_run = {
		prefix = "yamcha_warlok",
		to = 1,
		from = 1
	},
	yamcha_warlok_tap = {
		prefix = "yamcha_warlok",
		to = 21,
		from = 2
	},
	to_the_stars_star_run = {
		prefix = "to_the_stars_star",
		to = 232,
		from = 1
	},
	to_the_stars_drakefx_run = {
		prefix = "to_the_stars_drakefx",
		to = 70,
		from = 1
	},
	to_the_stars_guy_appear = {
		prefix = "to_the_stars_guy",
		to = 46,
		from = 1
	},
	to_the_stars_guy_idle1 = {
		prefix = "to_the_stars_guy",
		to = 48,
		from = 47
	},
	to_the_stars_guy_tap1 = {
		prefix = "to_the_stars_guy",
		to = 70,
		from = 49
	},
	to_the_stars_guy_idle2 = {
		prefix = "to_the_stars_guy",
		to = 71,
		from = 71
	},
	to_the_stars_guy_tap2 = {
		prefix = "to_the_stars_guy",
		to = 85,
		from = 71
	},
	to_the_stars_guy_idle3 = {
		prefix = "to_the_stars_guy",
		to = 86,
		from = 86
	},
	to_the_stars_guy_banish = {
		prefix = "to_the_stars_guy",
		to = 106,
		from = 87
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/stage38_decos.lua

-- BEGIN kr3/data/animations/stage39_decos.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/stage39_decos.lua

local a = {
	stage39_splash_inicial_in = {
		prefix = "stage39_splash_inicial",
		to = 37,
		from = 1
	},
	stage39_splash_path_in = {
		prefix = "stage39_splash_path",
		to = 30,
		from = 1
	},
	stage39_cocoon_in = {
		prefix = "stage39_cocoon",
		to = 107,
		from = 1
	},
	stage39_cocoon_loop = {
		prefix = "stage39_cocoon",
		to = 227,
		from = 108
	},
	stage39_cocoon_out = {
		prefix = "stage39_cocoon",
		to = 272,
		from = 228
	},
	mini_boss_hit_run = {
		prefix = "mini_boss_hit",
		to = 6,
		from = 1
	},
	mini_boss_creep_idle = {
		prefix = "mini_boss_creep",
		to = 1,
		from = 1
	},
	mini_boss_creep_walk = {
		prefix = "mini_boss_creep",
		to = 41,
		from = 2
	},
	mini_boss_creep_walk_down = {
		prefix = "mini_boss_creep",
		to = 81,
		from = 42
	},
	mini_boss_creep_instakill = {
		prefix = "mini_boss_creep",
		to = 121,
		from = 82
	},
	mini_boss_creep_mele_1 = {
		prefix = "mini_boss_creep",
		to = 151,
		from = 122
	},
	mini_boss_creep_mele_2 = {
		prefix = "mini_boss_creep",
		to = 187,
		from = 152
	},
	mini_boss_creep_death_in = {
		prefix = "mini_boss_creep",
		to = 193,
		from = 188
	},
	mini_boss_creep_death_loop = {
		prefix = "mini_boss_creep",
		to = 221,
		from = 194
	},
	mini_boss_creep_death_out = {
		prefix = "mini_boss_creep",
		to = 271,
		from = 222
	},
	mini_boss_creep_death = {
		prefix = "mini_boss_creep",
		to = 271,
		from = 188
	},
	dragon_sheepy_idle_1 = {
		prefix = "dragon_sheepy_sheepy",
		to = 1,
		from = 1
	},
	dragon_sheepy_idle_1_anim = {
		prefix = "dragon_sheepy_sheepy",
		to = 7,
		from = 2
	},
	dragon_sheepy_click_1 = {
		prefix = "dragon_sheepy_sheepy",
		to = 44,
		from = 8
	},
	dragon_sheepy_idle_2 = {
		prefix = "dragon_sheepy_sheepy",
		to = 45,
		from = 45
	},
	dragon_sheepy_idle_2_anim = {
		prefix = "dragon_sheepy_sheepy",
		to = 55,
		from = 46
	},
	dragon_sheepy_click_2 = {
		prefix = "dragon_sheepy_sheepy",
		to = 111,
		from = 56
	},
	dragon_sheepy_idle_3 = {
		prefix = "dragon_sheepy_sheepy",
		to = 113,
		from = 112
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/stage39_decos.lua

-- BEGIN kr3/data/animations/stage40_decos.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/stage40_decos.lua

local a = {
	export_rayo_rayo_run = {
		prefix = "export_rayo_rayo",
		to = 20,
		from = 1
	},
	export_rayo_rayo_out = {
		prefix = "export_rayo_rayo",
		to = 36,
		from = 21
	},
	vfx_dragon_hit_damage_dragon_run = {
		prefix = "vfx_dragon_hit_damage_dragon",
		to = 23,
		from = 1
	},
	vfx_dragon_fire_particles_run = {
		prefix = "vfx_dragon_fire_particles",
		to = 18,
		from = 1
	},
	vfx_dragon_crack_loop = {
		prefix = "vfx_dragon_crack",
		to = 14,
		from = 1
	},
	vfx_dragon_crack_fire_loop = {
		prefix = "vfx_dragon_crack_fire",
		to = 12,
		from = 1
	},
	vfx_dragon_ray_1_run = {
		prefix = "vfx_dragon_ray_1",
		to = 2,
		from = 1
	},
	vfx_dragon_ray_2_run = {
		prefix = "vfx_dragon_ray_2",
		to = 2,
		from = 1
	},
	vfx_dragon_explosion_ray_run = {
		prefix = "vfx_dragon_explosion_ray",
		to = 16,
		from = 1
	},
	vfx_dragon_ray_breath_run = {
		prefix = "vfx_dragon_ray_breath",
		to = 38,
		from = 1
	},
	vfx_dragon_ray_decal_Idle = {
		prefix = "vfx_dragon_ray_decal",
		to = 42,
		from = 1
	},
	vfx_dragon_ray_deco_idle = {
		prefix = "vfx_dragon_ray_deco",
		to = 41,
		from = 1
	},
	vfx_dragon_smoke_pie_run = {
		prefix = "vfx_dragon_smoke_pie",
		to = 18,
		from = 1
	},
	vfx_dragon_stun_tower_run = {
		prefix = "vfx_dragon_stun_tower",
		to = 28,
		from = 1
	},
	vfx_dragon_stun_tower_loop = {
		prefix = "vfx_dragon_stun_tower",
		to = 28,
		from = 1
	},
	vfx_dragon_crack_run = {
		prefix = "vfx_dragon_crack",
		to = 50,
		from = 1
	},
	vfx_dragon_explosion_smoke_run = {
		prefix = "vfx_dragon_explosion_smoke",
		to = 56,
		from = 1
	},
	vfx_dragon_projectile_stun_trail_run = {
		prefix = "vfx_dragon_projectile_stun_trail",
		to = 14,
		from = 1
	},
	vfx_dragon_projectile_stun_aereo_idle = {
		prefix = "vfx_dragon_projectile_stun_aereo",
		to = 6,
		from = 1
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/stage40_decos.lua

-- BEGIN kr3/data/animations/tower_dragons.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/tower_dragons.lua

local a = {
	dlc_dragons_tower_projectil_skill_shoot_run = {
		prefix = "dlc_dragons_tower_projectil_skill_shoot",
		to = 12,
		from = 1
	},
	dlc_dragons_tower_hit_skill_shoot_voladores_run = {
		prefix = "dlc_dragons_tower_hit_skill_shoot_voladores",
		to = 18,
		from = 1
	},
	dlc_dragons_tower_trail_skill_shoot_run = {
		prefix = "dlc_dragons_tower_trail_skill_shoot",
		to = 12,
		from = 1
	},
	lvl4_angry_head_run = {
		prefix = "lvl4_angry_head",
		to = 58,
		from = 1
	},
	dlc_dragons_tower_respiracion_lvl4_fuego_run = {
		prefix = "dlc_dragons_tower_respiracion_lvl4_fuego",
		to = 22,
		from = 1
	},
	dlc_dragons_tower_respiracion_lvl1_run = {
		prefix = "dlc_dragons_tower_respiracion_lvl1",
		to = 14,
		from = 1
	},
	dlc_dragons_tower_respiracion_lvl2_run = {
		prefix = "dlc_dragons_tower_respiracion_lvl2",
		to = 14,
		from = 1
	},
	dlc_dragons_tower_respiracion_lvl3_run = {
		prefix = "dlc_dragons_tower_respiracion_lvl3",
		to = 14,
		from = 1
	},
	dlc_dragons_tower_respiracion_lvl4_run = {
		prefix = "dlc_dragons_tower_respiracion_lvl4",
		to = 14,
		from = 1
	},
	dlc_dragons_tower_modifier_stun_run = {
		prefix = "dlc_dragons_tower_modifier_stun",
		to = 10,
		from = 1
	},
	dlc_dragons_tower_modifier_stun_run_loop = {
		prefix = "dlc_dragons_tower_modifier_stun",
		to = 10,
		from = 1
	},
	dlc_dragons_tower_tower_lvl4_idle = {
		prefix = "dlc_dragons_tower_tower_lvl4",
		to = 58,
		from = 1
	},
	dlc_dragons_tower_tower_lvl4_scream = {
		prefix = "dlc_dragons_tower_tower_lvl4",
		to = 114,
		from = 59
	},
	dlc_dragons_tower_tower_lvl4_shoot_right = {
		prefix = "dlc_dragons_tower_tower_lvl4",
		to = 160,
		from = 115
	},
	dlc_dragons_tower_tower_lvl4_shoot_left = {
		prefix = "dlc_dragons_tower_tower_lvl4",
		to = 204,
		from = 161
	},
	dlc_dragons_tower_tower_lvl4_tap_in = {
		prefix = "dlc_dragons_tower_tower_lvl4",
		to = 260,
		from = 205
	},
	dlc_dragons_tower_tower_lvl3_idle = {
		prefix = "dlc_dragons_tower_tower_lvl3",
		to = 82,
		from = 1
	},
	dlc_dragons_tower_tower_lvl3_tap_in = {
		prefix = "dlc_dragons_tower_tower_lvl3",
		to = 104,
		from = 83
	},
	dlc_dragons_tower_tower_lvl3_tap_loop = {
		prefix = "dlc_dragons_tower_tower_lvl3",
		to = 105,
		from = 105
	},
	dlc_dragons_tower_tower_lvl3_tap_out = {
		prefix = "dlc_dragons_tower_tower_lvl3",
		to = 127,
		from = 106
	},
	dlc_dragons_tower_tower_lvl2_idle = {
		prefix = "dlc_dragons_tower_tower_lvl2",
		to = 82,
		from = 1
	},
	dlc_dragons_tower_tower_lvl2_tap_in = {
		prefix = "dlc_dragons_tower_tower_lvl2",
		to = 104,
		from = 83
	},
	dlc_dragons_tower_tower_lvl2_tap_loop = {
		prefix = "dlc_dragons_tower_tower_lvl2",
		to = 105,
		from = 105
	},
	dlc_dragons_tower_tower_lvl2_tap_out = {
		prefix = "dlc_dragons_tower_tower_lvl2",
		to = 127,
		from = 106
	},
	dlc_dragons_tower_tower_lvl1_idle = {
		prefix = "dlc_dragons_tower_tower_lvl1",
		to = 82,
		from = 1
	},
	dlc_dragons_tower_tower_lvl1_tap_in = {
		prefix = "dlc_dragons_tower_tower_lvl1",
		to = 104,
		from = 83
	},
	dlc_dragons_tower_tower_lvl1_tap_loop = {
		prefix = "dlc_dragons_tower_tower_lvl1",
		to = 105,
		from = 105
	},
	dlc_dragons_tower_tower_lvl1_tap_out = {
		prefix = "dlc_dragons_tower_tower_lvl1",
		to = 127,
		from = 106
	},
	dlc_dragons_tower_construction_run = {
		prefix = "dlc_dragons_tower_construction",
		to = 1,
		from = 1
	},
	dlc_dragons_tower_evolve_run = {
		prefix = "dlc_dragons_tower_evolve",
		to = 14,
		from = 1
	},
	dlc_dragons_tower_preview_run = {
		prefix = "dlc_dragons_tower_preview",
		to = 1,
		from = 1
	},
	dlc_dragons_tower_drake_lvl4_proyectile_run = {
		prefix = "dlc_dragons_tower_drake_lvl4_proyectile",
		to = 19,
		from = 1
	},
	dlc_dragons_tower_drake_lvl4_proyectile_flying = {
		prefix = "dlc_dragons_tower_drake_lvl4_proyectile",
		to = 19,
		from = 1
	},
	dlc_dragons_tower_drake_lvl4_proyectile_idle = {
		prefix = "dlc_dragons_tower_drake_lvl4_proyectile",
		to = 19,
		from = 1
	},
	dlc_dragons_tower_hit_lvl4_run = {
		prefix = "dlc_dragons_tower_hit_lvl4",
		to = 10,
		from = 1
	},
	dlc_dragons_tower_hit_run = {
		prefix = "dlc_dragons_tower_hit",
		to = 10,
		from = 1
	},
	dlc_dragons_tower_modifire_drake_attack_run = {
		prefix = "dlc_dragons_tower_modifire_drake_attack",
		to = 20,
		from = 1
	},
	dlc_dragons_tower_drake_proyectile_run = {
		prefix = "dlc_dragons_tower_drake_proyectile",
		to = 19,
		from = 1
	},
	dlc_dragons_tower_drake_proyectile_flying = {
		prefix = "dlc_dragons_tower_drake_proyectile",
		to = 19,
		from = 1
	},
	dlc_dragons_tower_drake_proyectile_idle = {
		prefix = "dlc_dragons_tower_drake_proyectile",
		to = 19,
		from = 1
	},
	dlc_dragons_tower_drake_lvl4_proyectile_trail_run = {
		prefix = "dlc_dragons_tower_drake_lvl4_proyectile_trail",
		to = 15,
		from = 1
	},
	dlc_dragons_tower_drake_proyectile_trail_run = {
		prefix = "dlc_dragons_tower_drake_proyectile_trail",
		to = 15,
		from = 1
	},
	dlc_dragons_tower_drake_lvl4_spawn = {
		prefix = "dlc_dragons_tower_drake_lvl4",
		to = 20,
		from = 1
	},
	dlc_dragons_tower_drake_lvl4_idle = {
		prefix = "dlc_dragons_tower_drake_lvl4",
		to = 38,
		from = 21
	},
	dlc_dragons_tower_drake_lvl4_fly = {
		prefix = "dlc_dragons_tower_drake_lvl4",
		to = 38,
		from = 21
	},
	dlc_dragons_tower_drake_lvl4_attack = {
		prefix = "dlc_dragons_tower_drake_lvl4",
		to = 59,
		from = 39
	},
	dlc_dragons_tower_drake_lvl3_spawn = {
		prefix = "dlc_dragons_tower_drake_lvl3",
		to = 20,
		from = 1
	},
	dlc_dragons_tower_drake_lvl3_idle = {
		prefix = "dlc_dragons_tower_drake_lvl3",
		to = 38,
		from = 21
	},
	dlc_dragons_tower_drake_lvl3_fly = {
		prefix = "dlc_dragons_tower_drake_lvl3",
		to = 38,
		from = 21
	},
	dlc_dragons_tower_drake_lvl3_attack = {
		prefix = "dlc_dragons_tower_drake_lvl3",
		to = 59,
		from = 39
	},
	dlc_dragons_tower_drake_lvl2_spawn = {
		prefix = "dlc_dragons_tower_drake_lvl2",
		to = 20,
		from = 1
	},
	dlc_dragons_tower_drake_lvl2_idle = {
		prefix = "dlc_dragons_tower_drake_lvl2",
		to = 38,
		from = 21
	},
	dlc_dragons_tower_drake_lvl2_fly = {
		prefix = "dlc_dragons_tower_drake_lvl2",
		to = 38,
		from = 21
	},
	dlc_dragons_tower_drake_lvl2_attack = {
		prefix = "dlc_dragons_tower_drake_lvl2",
		to = 59,
		from = 39
	},
	dlc_dragons_tower_drake_lvl1_spawn = {
		prefix = "dlc_dragons_tower_drake_lvl1",
		to = 20,
		from = 1
	},
	dlc_dragons_tower_drake_lvl1_idle = {
		prefix = "dlc_dragons_tower_drake_lvl1",
		to = 38,
		from = 21
	},
	dlc_dragons_tower_drake_lvl1_fly = {
		prefix = "dlc_dragons_tower_drake_lvl1",
		to = 38,
		from = 21
	},
	dlc_dragons_tower_drake_lvl1_attack = {
		prefix = "dlc_dragons_tower_drake_lvl1",
		to = 59,
		from = 39
	},
	dlc_dragons_tower_decal_stun_idle = {
		prefix = "dlc_dragons_tower_decal_stun",
		to = 42,
		from = 1
	},
	dlc_dragons_tower_trail_skill_decal_in = {
		prefix = "dlc_dragons_tower_trail_skill_decal",
		to = 26,
		from = 1
	},
	dlc_dragons_tower_trail_skill_decal_idle = {
		prefix = "dlc_dragons_tower_trail_skill_decal",
		to = 27,
		from = 27
	},
	dlc_dragons_tower_decal_projectile_run = {
		prefix = "dlc_dragons_tower_decal_projectile",
		to = 42,
		from = 1
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/tower_dragons.lua

-- BEGIN kr3/data/animations/warden_warrior.lua
do
	local __chunk = (function()
-- chunkname: @./kr5/data/animations/all/warden_warrior.lua

local a = {
	warden_warrior_warden_warrior_idle = {
		prefix = "warden_warrior_warden_warrior",
		to = 1,
		from = 1
	},
	warden_warrior_warden_warrior_walk = {
		prefix = "warden_warrior_warden_warrior",
		to = 21,
		from = 2
	},
	warden_warrior_warden_warrior_attack = {
		prefix = "warden_warrior_warden_warrior",
		to = 64,
		from = 22
	},
	warden_warrior_warden_warrior_spawn = {
		prefix = "warden_warrior_warden_warrior",
		to = 104,
		from = 65
	},
	warden_warrior_warden_warrior_death = {
		prefix = "warden_warrior_warden_warrior",
		to = 150,
		from = 105
	},
	warden_warrior_warden_warrior_raise = {
		prefix = "warden_warrior_warden_warrior",
		to = 104,
		from = 65
	},
	warden_warrior_hit_run = {
		prefix = "warden_warrior_hit",
		to = 9,
		from = 1
	}
}

return a
	end)()
	__merge_animations(__chunk)
end
-- END kr3/data/animations/warden_warrior.lua

return out
