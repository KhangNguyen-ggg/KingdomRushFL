return {
	required_sounds = {"kr4_easter_eggs_182", "branch_campaigns", "powers_kr4"},
	required_textures = {},
	scale_required_textures = {"kr4_easter_malagar", "go_stage182", "kr4_sandstorm", "kr4_sandstorm_aux", "kr4_power_reinforcements"},
	level_terrain_type = 410,
	locked_hero = false,
	max_upgrade_level = 5,
	custom_start_pos = {
		zoom = 1.3,
		pos = {x = 512, y = 384}
	},
	custom_spawn_pos = {
		{
			pos = {
				x = 75,
				y = 330
			}
		},
	},
	entities_list = {
		{template = "kr4_easter_controller", pos = {x = 0, y = 0}},
		{
			template = "kr4_branch_stage_controller",
			level = 182,
			pos = {x = 0, y = 0},
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_432",
			pos = {
				x = 512,
				y = 384
			},
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {
				x = 420,
				y = 322
			},
			["tower.default_rally_pos"] = {
				x = 415,
				y = 261
			},
			["ui.nav_mesh_id"] = "1",
			["tower.holder_id"] = "1",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {
				x = 250,
				y = 350
			},
			["tower.default_rally_pos"] = {
				x = 271,
				y = 282
			},
			["ui.nav_mesh_id"] = "2",
			["tower.holder_id"] = "2",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {
				x = 530,
				y = 211
			},
			["tower.default_rally_pos"] = {
				x = 549,
				y = 276
			},
			["ui.nav_mesh_id"] = "3",
			["tower.holder_id"] = "3",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {
				x = 322,
				y = 222
			},
			["tower.default_rally_pos"] = {
				x = 322,
				y = 287
			},
			["ui.nav_mesh_id"] = "4",
			["tower.holder_id"] = "4",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {
				x = 689,
				y = 426
			},
			["tower.default_rally_pos"] = {
				x = 656,
				y = 486
			},
			["ui.nav_mesh_id"] = "5",
			["tower.holder_id"] = "5",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {
				x = 519,
				y = 403
			},
			["tower.default_rally_pos"] = {
				x = 499,
				y = 470
			},
			["ui.nav_mesh_id"] = "6",
			["tower.holder_id"] = "6",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {
				x = 645,
				y = 305
			},
			["tower.default_rally_pos"] = {
				x = 661,
				y = 250
			},
			["ui.nav_mesh_id"] = "7",
			["tower.holder_id"] = "7",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {
				x = 769,
				y = 218
			},
			["tower.default_rally_pos"] = {
				x = 848,
				y = 245
			},
			["ui.nav_mesh_id"] = "8",
			["tower.holder_id"] = "8",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {
				x = 818,
				y = 336
			},
			["tower.default_rally_pos"] = {
				x = 756,
				y = 281
			},
			["ui.nav_mesh_id"] = "9",
			["tower.holder_id"] = "9",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {
				x = 843,
				y = 501
			},
			["tower.default_rally_pos"] = {
				x = 850,
				y = 567
			},
			["ui.nav_mesh_id"] = "10",
			["tower.holder_id"] = "10",
		},
		{
			["editor.r"] = 0.6385342622197835,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 1148,
				y = 493
			},
		},
		{
			["editor.r"] = 0.0582673029695334,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 1138,
				y = 216
			},
		},
		{
			["editor.r"] = 1.6041173226731438,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 496,
				y = 713
			},
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 75,
				y = 378
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 75,
				y = 258
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defend_point5",
			["editor.flip"] = 0,
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			["editor.orientation"] = 1,
			pos = {
				x = 75,
				y = 330
			},
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 58,
				y = 171
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 283,
				y = 67
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 200,
				y = 34
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 285,
				y = 15
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 137,
				y = 1
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 116,
				y = 46
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 98,
				y = 93
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 31,
				y = 62
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 46,
				y = 7
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 159,
				y = 103
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 86,
				y = 440
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 156,
				y = 609
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 60,
				y = 717
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 47,
				y = 121
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = -36,
				y = 720
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = -126,
				y = 714
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = -119,
				y = 553
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = -156,
				y = 645
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = -30,
				y = 136
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = -114,
				y = 88
			},
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "water_sparks_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 79,
				y = 637
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["render.sprites[1].name"] = "boat_sail_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 131,
				y = 256
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["render.sprites[1].name"] = "stage32_camp_flag_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 629,
				y = 94
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["render.sprites[1].name"] = "stage32_camp_flag_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 125,
				y = 184
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["render.sprites[1].name"] = "stage32_ships_flag_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 211,
				y = 142
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["render.sprites[1].name"] = "stage32_ships_flag_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 477,
				y = 117
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["render.sprites[1].name"] = "stage32_firepit_run",
			["render.sprites[1].animated"] = true,
			random_shift = true,
		},
		{
			template = "touch",
			pos = {
				x = 551,
				y = 90
			},
			["render.sprites[1].z"] = Z_DECALS,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 594,
				y = 42
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["render.sprites[1].name"] = "blacksmith_achievement_worker_run",
			["render.sprites[1].animated"] = true,
		},
		{
			template = "touch",
			pos = {
				x = 732,
				y = 685
			},
			["render.sprites[1].z"] = Z_DECALS,
		},
	},
	level_mode_overrides = {
        [3] = {
            locked_hero = false,
            locked_towers = {
            },
            max_upgrade_level = 5
        }
    },
}
