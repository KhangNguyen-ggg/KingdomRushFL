return {
	required_sounds = {"kr4_easter_eggs_180", "branch_campaigns", "powers_kr4"},
	required_textures = {},
	scale_required_textures = {"go_stage180", "kr4_dwarven_empire", "kr4_dinos", "kr4_power_reinforcements"},
	required_exoskeletons = {"caveman", "prehistoric_dwarf", "velociraptor", "pterodactyl", "pterodactyl_with_dwarf", "carnivorous_plant_def", "carnivorous_plant_venom_proyectile", "carnivorous_plant_venom_fx", "carnivorous_plant_venom_decal", "carnivorous_plant_spit_proyectile", "carnivorous_plant_spit_fx", "stage30_miner_1", "stage30_miner_2", "stage30_special_shine", "kr4_egg_ambar_dino", "kr4_egg_demogorgon"},
	level_terrain_type = 409,
	locked_hero = false,
	max_upgrade_level = 5,
	custom_start_pos = {
		zoom = 1.3,
		pos = {x = 512, y = 384}
	},
	custom_spawn_pos = {
		{
			pos = {
				x = 73,
				y = 297
			}
		},
	},
	entities_list = {
		{template = "kr4_easter_controller", pos = {x = 0, y = 0}},
		{
			template = "kr4_branch_stage_controller",
			level = 180,
			pos = {x = 0, y = 0},
		},
		{
			template = "controller_teleport_enemies",
			path = 1,
			start_ni = 95,
			end_ni = 110,
			target_path = 4,
			target_ni = 8,
			duration = 0.5,
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_430",
			pos = {
				x = 512,
				y = 384
			},
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 38,
			pos = {
				x = 265,
				y = 287
			},
			["tower.default_rally_pos"] = {
				x = 249,
				y = 217
			},
			["ui.nav_mesh_id"] = "1",
			["tower.holder_id"] = "1",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 38,
			pos = {
				x = 387,
				y = 503
			},
			["tower.default_rally_pos"] = {
				x = 308,
				y = 440
			},
			["ui.nav_mesh_id"] = "2",
			["tower.holder_id"] = "2",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 43,
			pos = {
				x = 372,
				y = 315
			},
			["tower.default_rally_pos"] = {
				x = 379,
				y = 414
			},
			["ui.nav_mesh_id"] = "3",
			["tower.holder_id"] = "3",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 43,
			pos = {
				x = 411,
				y = 141
			},
			["tower.default_rally_pos"] = {
				x = 380,
				y = 214
			},
			["ui.nav_mesh_id"] = "4",
			["tower.holder_id"] = "4",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 43,
			pos = {
				x = 451,
				y = 563
			},
			["tower.default_rally_pos"] = {
				x = 348,
				y = 595
			},
			["ui.nav_mesh_id"] = "5",
			["tower.holder_id"] = "5",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 43,
			pos = {
				x = 521,
				y = 185
			},
			["tower.default_rally_pos"] = {
				x = 476,
				y = 247
			},
			["ui.nav_mesh_id"] = "6",
			["tower.holder_id"] = "6",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 38,
			pos = {
				x = 216,
				y = 401
			},
			["tower.default_rally_pos"] = {
				x = 218,
				y = 479
			},
			["ui.nav_mesh_id"] = "7",
			["tower.holder_id"] = "7",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 38,
			pos = {
				x = 160,
				y = 338
			},
			["tower.default_rally_pos"] = {
				x = 135,
				y = 266
			},
			["ui.nav_mesh_id"] = "8",
			["tower.holder_id"] = "8",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 43,
			pos = {
				x = 661,
				y = 388
			},
			["tower.default_rally_pos"] = {
				x = 700,
				y = 469
			},
			["ui.nav_mesh_id"] = "9",
			["tower.holder_id"] = "9",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 43,
			pos = {
				x = 565,
				y = 431
			},
			["tower.default_rally_pos"] = {
				x = 476,
				y = 457
			},
			["ui.nav_mesh_id"] = "10",
			["tower.holder_id"] = "10",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 43,
			pos = {
				x = 629,
				y = 230
			},
			["tower.default_rally_pos"] = {
				x = 612,
				y = 300
			},
			["ui.nav_mesh_id"] = "11",
			["tower.holder_id"] = "11",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 43,
			pos = {
				x = 778,
				y = 216
			},
			["tower.default_rally_pos"] = {
				x = 856,
				y = 170
			},
			["ui.nav_mesh_id"] = "12",
			["tower.holder_id"] = "12",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 43,
			pos = {
				x = 863,
				y = 376
			},
			["tower.default_rally_pos"] = {
				x = 865,
				y = 288
			},
			["ui.nav_mesh_id"] = "13",
			["tower.holder_id"] = "13",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 38,
			pos = {
				x = 197,
				y = 547
			},
			["tower.default_rally_pos"] = {
				x = 296,
				y = 528
			},
			["ui.nav_mesh_id"] = "14",
			["tower.holder_id"] = "14",
		},
		{
			["editor.r"] = 0.0,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 1129,
				y = 279
			},
		},
		{
			["editor.r"] = -0.016665123713940747,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 1129,
				y = 332
			},
		},
		{
			["editor.r"] = -0.008333140440135918,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 902,
				y = 462
			},
		},
		{
			["editor.r"] = 1.5625320521352455,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 346,
				y = 666
			},
		},
		{
			template = "touch",
			pos = {
				x = -15,
				y = 140
			},
			["render.sprites[1].z"] = Z_DECALS,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 685.75,
				y = -57
			},
			["render.sprites[1].anchor.x"] = 0.5,
			["render.sprites[1].anchor.y"] = 0,
			["render.sprites[1].z"] = Z_OBJECTS,
			["render.sprites[1].name"] = "stage30_cave2",
			["render.sprites[1].animated"] = false,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 367,
				y = 649
			},
			["render.sprites[1].anchor.x"] = 0.5,
			["render.sprites[1].anchor.y"] = 0.15,
			["render.sprites[1].z"] = Z_OBJECTS,
			["render.sprites[1].name"] = "stage30_cave1_pc",
			["render.sprites[1].animated"] = false,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = -47,
				y = 427
			},
			["render.sprites[1].anchor.x"] = 0.5,
			["render.sprites[1].anchor.y"] = 0.2,
			["render.sprites[1].z"] = Z_OBJECTS,
			["render.sprites[1].name"] = "Stage30_tunel1_pc",
			["render.sprites[1].animated"] = false,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 1052,
				y = 405
			},
			["render.sprites[1].anchor.x"] = 0.5,
			["render.sprites[1].anchor.y"] = 0.2,
			["render.sprites[1].z"] = Z_OBJECTS,
			["render.sprites[1].name"] = "Stage30_tunel2_pc",
			["render.sprites[1].animated"] = false,
		},
		{
			template = "touch",
			pos = {
				x = 59,
				y = 629
			},
			["render.sprites[1].z"] = Z_OBJECTS,
		},
		{
			template = "touch",
			pos = {
				x = 466,
				y = 714
			},
			["render.sprites[1].z"] = Z_OBJECTS,
		},
		{
			template = "touch",
			pos = {
				x = 779,
				y = 724
			},
			["render.sprites[1].z"] = Z_OBJECTS,
		},
		{
			template = "touch",
			pos = {
				x = 926,
				y = 606
			},
			["render.sprites[1].z"] = Z_OBJECTS,
		},
		{
			template = "touch",
			pos = {
				x = 687,
				y = 135
			},
			["render.sprites[1].z"] = Z_OBJECTS,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 94,
				y = 395
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 120,
				y = 522
			},
			["render.sprites[1].z"] = Z_DECALS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 58,
				y = 232
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 84,
				y = 354
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
				x = 73,
				y = 297
			},
		},
		{
			template = "decal_defend_point5",
			["editor.flip"] = 0,
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			["editor.orientation"] = 1,
			pos = {
				x = 110,
				y = 467
			},
		},
		{
			template = "touch",
			exo_prefix = "stage30_miner_1",
			idle_animation = "idle",
			loop_variants = {
				{min_cooldown = 10, max_cooldown = 15, animation_idle = "idle", animation_end = "descanso"},
				{min_cooldown = 5, max_cooldown = 10, animation_idle = "idle2", animation_end = "susto"}
			},
			pos = {
				x = 768,
				y = 628
			},
			["render.sprites[1].z"] = Z_OBJECTS,
		},
		{
			template = "touch",
			exo_prefix = "stage30_miner_2",
			idle_animation = "idle",
			loop_variants = {
				{min_cooldown = 4, max_cooldown = 10, animation_idle = "idle", animation_end = "no"},
				{min_cooldown = 4, max_cooldown = 10, animation_idle = "idle2", animation_end = "talking"}
			},
			pos = {
				x = 668,
				y = 589
			},
			["render.sprites[1].z"] = Z_OBJECTS,
		},
		{
			template = "touch",
			exo_prefix = "stage30_special_shine",
			y_position_adjust = 25,
			scale = 0.4,
			pos = {
				x = 182,
				y = 660
			},
			["render.sprites[1].z"] = Z_OBJECTS,
		},
		{
			template = "touch",
			exo_prefix = "stage30_special_shine",
			y_position_adjust = 10,
			flipped_x = true,
			scale = 0.35,
			pos = {
				x = 143,
				y = 742
			},
			["render.sprites[1].z"] = Z_OBJECTS,
		},
		{
			template = "touch",
			exo_prefix = "stage30_special_shine",
			y_position_adjust = 100,
			flipped_x = true,
			scale = 0.3,
			pos = {
				x = 429,
				y = 717
			},
			["render.sprites[1].z"] = Z_OBJECTS,
		},
		{
			template = "touch",
			exo_prefix = "stage30_special_shine",
			y_position_adjust = 10,
			flipped_x = true,
			scale = 0.3,
			pos = {
				x = 582,
				y = 718
			},
			["render.sprites[1].z"] = Z_OBJECTS,
		},
		{
			template = "touch",
			exo_prefix = "stage30_special_shine",
			y_position_adjust = 10,
			scale = 0.45,
			pos = {
				x = 749,
				y = 674
			},
			["render.sprites[1].z"] = Z_OBJECTS,
		},
		{
			template = "touch",
			exo_prefix = "stage30_special_shine",
			y_position_adjust = 10,
			flipped_x = true,
			scale = 0.45,
			pos = {
				x = 885,
				y = 707
			},
			["render.sprites[1].z"] = Z_OBJECTS,
		},
		{
			template = "touch",
			exo_prefix = "stage30_special_shine",
			y_position_adjust = 10,
			scale = 0.45,
			pos = {
				x = 27,
				y = 98
			},
			["render.sprites[1].z"] = Z_OBJECTS,
		},
	},
	invalid_path_ranges = {
		{
			from = 101,
			to = 216,
			path_id = 1,
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
