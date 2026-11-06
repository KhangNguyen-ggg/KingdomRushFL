return {
	required_sounds = {"kr4_easter_eggs_184", "branch_campaigns", "powers_kr4"},
	required_textures = {},
	scale_required_textures = {"kr4_easter_malagar", "go_stage184", "kr4_sandstorm", "kr4_sandstorm_aux", "kr4_level34_shatra", "kr4_level34_shatra2", "kr4_power_reinforcements", "go_hero_isfet",},
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
				x = 940,
				y = 565
			}
		},
	},
	entities_list = {
		{template = "kr4_easter_controller", pos = {x = 0, y = 0}},
		{
			template = "kr4_branch_stage_controller",
			level = 184,
			pos = {x = 0, y = 0},
		},
		{
			template = "controller_teleport_enemies",
			path = 1,
			start_ni = 74,
			end_ni = 275,
			duration = 0.5,
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_434",
			pos = {
				x = 512,
				y = 384
			},
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {x = 350, y = 338},
			["tower.default_rally_pos"] = {x = 344, y = 284},
			["ui.nav_mesh_id"] = "1",
			["tower.holder_id"] = "1",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {x = 218, y = 410},
			["tower.default_rally_pos"] = {x = 264, y = 346},
			["ui.nav_mesh_id"] = "2",
			["tower.holder_id"] = "2",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {x = 621, y = 214},
			["tower.default_rally_pos"] = {x = 624, y = 160},
			["ui.nav_mesh_id"] = "3",
			["tower.holder_id"] = "3",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {x = 501, y = 238},
			["tower.default_rally_pos"] = {x = 503, y = 176},
			["ui.nav_mesh_id"] = "4",
			["tower.holder_id"] = "4",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {x = 751, y = 429},
			["tower.default_rally_pos"] = {x = 736, y = 373},
			["ui.nav_mesh_id"] = "5",
			["tower.holder_id"] = "5",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {x = 275, y = 229},
			["tower.default_rally_pos"] = {x = 271, y = 169},
			["ui.nav_mesh_id"] = "6",
			["tower.holder_id"] = "6",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {x = 697, y = 321},
			["tower.default_rally_pos"] = {x = 673, y = 262},
			["ui.nav_mesh_id"] = "7",
			["tower.holder_id"] = "7",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {x = 785, y = 290},
			["tower.default_rally_pos"] = {x = 786, y = 230},
			["ui.nav_mesh_id"] = "8",
			["tower.holder_id"] = "8",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {x = 393, y = 224},
			["tower.default_rally_pos"] = {x = 392, y = 162},
			["ui.nav_mesh_id"] = "9",
			["tower.holder_id"] = "9",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {x = 826, y = 551},
			["tower.default_rally_pos"] = {x = 836, y = 615},
			["ui.nav_mesh_id"] = "10",
			["tower.holder_id"] = "10",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {x = 281, y = 537},
			["tower.default_rally_pos"] = {x = 279, y = 605},
			["ui.nav_mesh_id"] = "11",
			["tower.holder_id"] = "11",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {x = 291, y = 453},
			["tower.default_rally_pos"] = {x = 346, y = 408},
			["ui.nav_mesh_id"] = "12",
			["tower.holder_id"] = "12",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 44,
			pos = {x = 723, y = 547},
			["tower.default_rally_pos"] = {x = 685, y = 599},
			["ui.nav_mesh_id"] = "13",
			["tower.holder_id"] = "13",
		},
		{
			["editor.r"] = 2.6742137186223283,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 644,
				y = 416
			},
		},
		{
			["editor.r"] = 0.43007813505586256,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 376,
				y = 422
			},
		},
		{
			["editor.r"] = -2.4149503129080676,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 146,
				y = 447
			},
		},
		{
			["editor.r"] = 0.9944211062037129,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 319,
				y = 693
			},
		},
		{
			["editor.r"] = -0.11710874456686428,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 848,
				y = 382
			},
		},
		{
			["editor.r"] = 2.3209150165987538,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 114,
				y = 220
			},
		},
		{
			["editor.r"] = 2.7004131731748124,
			["editor.path_id"] = 7,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 144,
				y = 259
			},
		},
		{
			["editor.r"] = 3.0079404062725996,
			["editor.path_id"] = 8,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 165,
				y = 304
			},
		},
		{
			["editor.r"] = 0.0838366420684145,
			["editor.path_id"] = 9,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 849,
				y = 335
			},
		},
		{
			["editor.r"] = -0.5346889039760393,
			["editor.path_id"] = 10,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 359,
				y = 596
			},
		},
		{
			["editor.r"] = 1.7044485741120903,
			["editor.path_id"] = 11,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 373,
				y = 681
			},
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 940,
				y = 173
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 940,
				y = 263
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 940,
				y = 505
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 940,
				y = 615
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
				x = 940,
				y = 570
			},
		},
		{
			template = "decal_defend_point5",
			["editor.flip"] = 0,
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			["editor.orientation"] = 1,
			pos = {
				x = 930,
				y = 225
			},
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 506,
				y = 377
			},
			["render.sprites[1].anchor.x"] = 0.5,
			["render.sprites[1].anchor.y"] = 0.07,
			["render.sprites[1].z"] = Z_OBJECTS,
			["render.sprites[1].name"] = "Stage_34_pyramid_center_mask",
			["render.sprites[1].animated"] = false,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 19,
				y = 210
			},
			["render.sprites[1].anchor.x"] = 0.5,
			["render.sprites[1].anchor.y"] = 0.07,
			["render.sprites[1].z"] = Z_OBJECTS,
			["render.sprites[1].name"] = "stage34_pyramid_left_mask",
			["render.sprites[1].animated"] = false,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 985,
				y = 280
			},
			["render.sprites[1].anchor.x"] = 0.5,
			["render.sprites[1].anchor.y"] = 0.2,
			["render.sprites[1].z"] = Z_OBJECTS,
			["render.sprites[1].name"] = "stage34_pyramid_right_mask",
			["render.sprites[1].animated"] = false,
		},
		{
			template = "touch",
			pos = {
				x = 74,
				y = 574
			},
			["render.sprites[1].z"] = Z_DECALS,
		},
	},
	invalid_path_ranges = {
		{
			from = 74,
			to = 275,
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
	nav_mesh = {
		{14, 12, 2, 9},
		{12, 11, nil, 6},
		{8, 7, 4, nil},
		{3, 14, 9, nil},
		{nil, 13, 14, 7},
		{9, 1, nil, nil},
		{8, 5, 14, 3},
		{nil, 5, 7, nil},
		{4, 1, 6, nil},
		{nil, nil, 13, 5},
		{13, nil, nil, 12},
		{14, 11, 2, 1},
		{10, nil, 11, 5},
		{7, 13, 1, 3},
	},
}
