-- chunkname: @./kr3/game_settings.lua

local GS = {}

GS.url_strategy_guide = "http://www.kingdomrushorigins.com/strategy.html"
GS.url_twitter = "https://twitter.com/ironhidegames"
GS.url_facebook = "http://www.facebook.com/ironhidegames"
GS.url_policy = "https://www.ironhidegames.com/PrivacyPolicy"
GS.gameplay_tips_count = 84
GS.early_wave_reward_per_second = 1--需要判断是不是5代关卡，是的话需要乘以1.8
GS.early_wave_reward_per_second5 = 1.8
GS.max_stars = 1002
GS.max_difficulty = DIFFICULTY_IMPOSSIBLE
GS.difficulty_soldier_hp_max_factor = {
	1.2,
	1,
	1,
	1
}
GS.difficulty_enemy_hp_max_factor = {
	0.8,
	1,
	1.2,
	1.5
}
GS.difficulty_enemy_speed_factor = {
	1,
	1,
	1,
	1.1
}
GS.mode_enemy_speed_factor = {
	1,
	1,
	1,
	1,
	1,
	1,
	1.2,
	1
}
GS.mode_power_cooldown_factor = {
	1,
	1,
	1,
	1,
	0.5,
	1,
	0.5,
	1
}
GS.mode_starting_lives = {
	20,
	1,
	1,
	10,
	3,
	3,
	3,
	3
}
GS.gold_enemy_factor_per_mode_6 = {
	1,
	0,
	1,
	0,
	1,
	1.5,
	2.5,
	1
}
GS.hero_xp_multipliers_per_mode = {
	1,
	0,
	1,
	0,
	0,
	1.25,
	1.25,
	1.5
}
GS.difficulty_enemy_gold_factor = {
	1,
	0.675,
	0.533333,
}
GS.difficulty_init_gold_factor = {
	1,
	1.35,
	1.6,
}
GS.main_campaign_levels = 15
GS.main_campaign_levels3 = 15
GS.main_campaign_levels2 = 37
GS.main_campaign_levels1 = 56
GS.main_campaign_levels5 = 116
GS.main_campaign_levels4 = 166
GS.main_campaign_levels6 = 268
GS.last_level = 22
GS.last_level3 = 22
GS.last_level2 = 44
GS.last_level1 = 76---重生--72
GS.last_level5 = 141
GS.last_level6 = 269
--[=[ 193-201 暂不开放；保留原上限，便于之后重新启用。
GS.last_level4 = 201
]=]
GS.last_level4 = 192
GS.jnum1 = 44
GS.max_level1 = 32
GS.jnum2 = 22
GS.max_level2 = 31
GS.jnum3 = 0
GS.max_level3 = 23
GS.jnum5 = 100
GS.max_level5 = 41
GS.jnum6 = 250
GS.max_level6 = 19
GS.jnum4 = 149
--[=[ 193-201 暂不开放；保留原旗帜数量，便于之后重新启用。
GS.max_level4 = 52
]=]
GS.max_level4 = 43
GS.endless_levels_count = 2
GS.level_ranges = {
	{
		1,
		15
	},
	{
		16,
		18
	},
	{
		19,
		20
	},
	{
		21,
		22
	}
}
GS.level_ranges3 = {
	{
		1,
		15
	},
	{
		16,
		18
	},
	{
		19,
		20
	},
	{
		21,
		22
	},
	{
		86
	}
}
GS.level_ranges2 = {
	{
		23,
		37
	},
	{
		38,
		40
	},
	{
		41,
		43
	},
	{
		44
	},
	{
		77
	},
	{
		78
	},
	{
		79
	},
	{
		80
	},
	{
		87,
		91,
		list = true
	},
	{
		88,
		90
	},
}
GS.level_ranges1 = {
	{
		45,
		56
	},
	{
		57
	},
	{
		58
	},
	{
		59,
		66,
		list = true
	},
	{
		60,
		61
	},
	{
		62,
		63
	},
	{
		64,
		65
	},
	{
		67,
		70
	},
	{
		71,
		72
	},
	{
		73,
		74,
		75,
		list = true
	},	
	{
		76
	},
	
}
GS.level_ranges5 = {
	{
		101,
		116
	},
	{
		117,
		119
	},
	{
		120,
		122
	},
	{
		123,
		127
	},
	{
		128,
		130
	},
	{
		131,
		135
	},
	{
		136,
		141
	},
}
GS.level_ranges4 = {
	{
		150,
		166
	},
	{
		167,
		169
	},
	{
		170,
		172
	},
	{
		173,
		175
	},
	{
		176,
		178
	},
	{
		179,
		180
	},
	{
		181
	},
	{
		182,
		186
	},
	{
		187,
		191
	},
	{
		192
	},
	--[=[ 193-201 暂不开放。
	{
		193,
		195
	},
	{
		196,
		197,
		201,
		list = true,
	},
	{
		198,
		200
	},
	]=]
}
GS.level_ranges6 = {
	{
		251,
		268
	},
	{
		269
	}
}

GS.default_hero = "hero_elves_archer"
GS.hero_xp_thresholds = {
	300,
	900,
	2000,
	4800,
	8000,
	12000,
	16000,
	20000,
	26000
}

GS.hero_level_expected = {
	1,
	1,
	2,
	2,
	3,
	4,
	5,
	5,
	6,
	7,
	8,
	9,
	9,
	10,
	10,
	8,
	9,
	10,
	8,
	9,
	10,
	10
}
GS.hero_level_expected[48] = 1
GS.hero_level_expected[49] = 1
GS.hero_level_expected[50] = 1
GS.hero_level_expected[51] = 1
GS.hero_level_expected[52] = 1
GS.hero_level_expected[251] = 1
GS.hero_level_expected[252] = 1
GS.hero_level_expected[253] = 2
GS.hero_level_expected[254] = 2
GS.hero_level_expected[255] = 3
GS.hero_level_expected[256] = 3
GS.hero_level_expected[257] = 3
GS.hero_level_expected[258] = 4
GS.hero_level_expected[259] = 4
GS.hero_level_expected[260] = 5
GS.hero_level_expected[261] = 5
GS.hero_level_expected[262] = 6
GS.hero_level_expected[263] = 6
GS.hero_level_expected[264] = 7
GS.hero_level_expected[265] = 8
GS.hero_level_expected[266] = 8
GS.hero_level_expected[267] = 9
GS.hero_level_expected[268] = 9
GS.hero_level_expected[269] = 9
GS.hero_level_expected_multipliers_below = {
	1,
	2
}
GS.hero_level_expected_multipliers_above = {
	0.5,
	0.25
}
GS.hero_xp_gain_per_difficulty_mode = {
	[DIFFICULTY_EASY] = 2,
	[DIFFICULTY_NORMAL] = 1.1,
	[DIFFICULTY_HARD] = 1,
	[DIFFICULTY_IMPOSSIBLE] = 1
}
GS.skill_points_for_hero_level = {
	0,
	4,
	8,
	12,
	16,
	20,
	24,
	28,
	32,
	36
}
GS.endless_gems_for_wave = 1
GS.gems_factor_per_mode = {
	0.8,
	0.48,
	0.48
}
GS.gems_per_level = {
	100,
	150,
	200,
	250,
	250,
	275,
	275,
	300,
	300,
	325,
	325,
	350,
	350,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	100,
	150,
	200,
	250,
	250,
	275,
	275,
	300,
	300,
	325,
	325,
	350,
	350,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	100,
	150,
	200,
	250,
	250,
	275,
	275,
	300,
	300,
	325,
	325,
	350,
	350,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
	400,
}
GS.tower_room_tower_thumb_fmt = "kra_main_icons_%04d"--"quickmenu_main_icons_main_icons_0%03i_0001" -- 5和14缺失
GS.encyclopedia_tower_fmt = "encyclopedia_towers_0%03i"
GS.encyclopedia_tower_thumb_fmt = "encyclopedia_tower_thumbs_0%03i"
GS.encyclopedia_enemy_fmt = "encyclopedia_creeps_0%03i"
GS.encyclopedia_enemy_thumb_fmt = "encyclopedia_creep_thumbs_0%03i"
GS.encyclopedia_enemies = {
	{
		always_shown = true,
		name = "enemy_gnoll_reaver"
	},
	{
		name = "enemy_gnoll_burner"
	},
	{
		name = "enemy_gnoll_gnawer"
	},
	{
		name = "enemy_hyena"
	},
	{
		name = "enemy_perython"
	},
	{
		name = "enemy_gnoll_blighter"
	},
	{
		name = "enemy_ettin"
	},
	{
		name = "enemy_twilight_elf_harasser"
	},
	{
		name = "eb_gnoll"
	},
	{
		name = "enemy_gnoll_warleader"
	},
	{
		name = "enemy_sword_spider"
	},
	{
		name = "enemy_satyr_cutthroat"
	},
	{
		name = "enemy_satyr_hoplite"
	},
	{
		name = "enemy_webspitting_spider"
	},
	{
		name = "enemy_gloomy"
	},
	{
		name = "enemy_twilight_scourger"
	},
	{
		name = "enemy_bandersnatch"
	},
	{
		name = "enemy_redcap"
	},
	{
		name = "enemy_twilight_avenger"
	},
	{
		name = "enemy_boomshrooms"
	},
	{
		name = "enemy_munchshrooms"
	},
	{
		name = "enemy_shroom_breeder"
	},
	{
		name = "eb_drow_queen"
	},
	{
		name = "enemy_razorboar"
	},
	{
		name = "enemy_twilight_evoker"
	},
	{
		name = "enemy_twilight_golem"
	},
	{
		name = "enemy_mantaray"
	},
	{
		name = "enemy_spider_arachnomancer"
	},
	{
		name = "enemy_twilight_heretic"
	},
	{
		name = "enemy_spider_son_of_mactans"
	},
	{
		name = "enemy_arachnomancer"
	},
	{
		name = "enemy_drider"
	},
	{
		name = "eb_spider"
	},
	{
		name = "enemy_gnoll_bloodsydian"
	},
	{
		name = "enemy_bloodsydian_warlock"
	},
	{
		name = "enemy_ogre_magi"
	},
	{
		name = "eb_bram"
	},
	{
		name = "enemy_blood_servant"
	},
	{
		name = "enemy_screecher_bat"
	},
	{
		name = "enemy_mounted_avenger"
	},
	{
		name = "eb_bajnimen"
	},
	{
		name = "enemy_twilight_brute"
	},
	{
		name = "enemy_shadows_spawns"
	},
	{
		name = "enemy_grim_devourers"
	},
	{
		name = "enemy_dark_spitters"
	},
	{
		name = "enemy_shadow_champion"
	},
	{
		name = "eb_balrog"
	},
	--2代
	{
		always_shown = true,
		name = "enemy_bouncer"
	},
	{
		name = "enemy_desert_raider"
	},
	{
		name = "enemy_desert_archer"
	},
	{
		name = "enemy_desert_wolf_small"
	},
	{
		name = "enemy_desert_wolf"
	},
	{
		name = "enemy_immortal"
	},
	{
		name = "enemy_fallen"
	},
	{
		name = "enemy_executioner"
	},
	{
		name = "enemy_scorpion"
	},
	{
		name = "enemy_wasp"
	},
	{
		name = "enemy_wasp_queen"
	},
	{
		name = "enemy_tremor"
	},
	{
		name = "enemy_munra"
	},
	{
		name = "enemy_jungle_spider_small"
	},
	{
		name = "enemy_jungle_spider_big"
	},
	{
		name = "enemy_cannibal"
	},
	{
		name = "enemy_hunter"
	},
	{
		name = "enemy_shaman_priest"
	},
	{
		name = "enemy_shaman_shield"
	},
	{
		name = "enemy_shaman_magic"
	},
	{
		name = "enemy_shaman_necro"
	},
	{
		name = "enemy_cannibal_zombie"
	},
	{
		name = "enemy_gorilla"
	},
	{
		name = "enemy_savage_bird_rider"
	},
	{
		name = "enemy_alien_breeder"
	},
	{
		name = "enemy_alien_reaper"
	},
	{
		name = "enemy_razorwing"
	},
	{
		name = "enemy_quetzal"
	},
	{
		name = "enemy_broodguard"
	},
	{
		name = "enemy_myrmidon"
	},
	{
		name = "enemy_blazefang"
	},
	{
		name = "enemy_nightscale"
	},
	{
		name = "enemy_darter"
	},
	{
		name = "enemy_brute"
	},
	{
		name = "enemy_savant"
	},
	{
		name = "enemy_efreeti_small"
	},
	{
		name = "eb_efreeti"
	},
	{
		name = "enemy_gorilla_small"
	},
	{
		name = "eb_gorilla"
	},
	{
		name = "enemy_umbra_minion"
	},
	{
		name = "eb_umbra"
	},
	{
		name = "enemy_greenfin"
	},
	{
		name = "enemy_deviltide"
	},
	{
		name = "enemy_redspine"
	},
	{
		name = "enemy_blacksurge"
	},
	{
		name = "enemy_bluegale"
	},
	{
		name = "enemy_bloodshell"
	},
	{
		name = "eb_leviathan"
	},
	{
		name = "enemy_halloween_zombie"
	},
	{
		name = "enemy_ghoul"
	},
	{
		name = "enemy_bat"
	},
	{
		name = "enemy_werewolf"
	},
	{
		name = "enemy_abomination"
	},
	{
		name = "enemy_lycan"
	},
	{
		name = "enemy_ghost"
	},
	{
		name = "enemy_phantom_warrior"
	},
	{
		name = "enemy_elvira"
	},
	{
		name = "eb_dracula"
	},
	{
		name = "enemy_sniper"
	},
	{
		name = "eb_saurian_king"
	},
	--1代
	{
		always_shown = true,
		name = "enemy_goblin"
	},
	{
		name = "enemy_fat_orc"
	},
	{
		name = "enemy_shaman"
	},
	{
		name = "enemy_ogre"
	},
	{
		name = "enemy_bandit"
	},
	{
		name = "enemy_brigand"
	},
	{
		name = "enemy_marauder"
	},
	{
		name = "enemy_spider_small"
	},
	{
		name = "enemy_spider_big"
	},
	{
		name = "enemy_gargoyle"
	},
	{
		name = "enemy_shadow_archer"
	},
	{
		name = "enemy_dark_knight"
	},
	{
		name = "enemy_wolf_small"
	},
	{
		name = "enemy_wolf"
	},
	{
		name = "enemy_golem_head"
	},
	{
		name = "enemy_whitewolf"
	},
	{
		name = "enemy_troll"
	},
	{
		name = "enemy_troll_axe_thrower"
	},
	{
		name = "enemy_troll_chieftain"
	},
	{
		name = "enemy_yeti"
	},
	{
		name = "enemy_rocketeer"
	},
	{
		name = "enemy_slayer"
	},
	{
		name = "enemy_demon"
	},
	{
		name = "enemy_demon_mage"
	},
	{
		name = "enemy_demon_wolf"
	},
	{
		name = "enemy_demon_imp"
	},
	{
		name = "enemy_skeleton"
	},
	{
		name = "enemy_skeleton_big"
	},
	{
		name = "enemy_necromancer"
	},
	{
		name = "enemy_lava_elemental"
	},
	{
		name = "enemy_sarelgaz_small"
	},
	{
		name = "eb_juggernaut"
	},
	{
		name = "eb_jt"
	},
	{
		name = "eb_veznan"
	},
	{
		name = "eb_sarelgaz"
	},
	{
		name = "enemy_goblin_zapper"
	},
	{
		name = "enemy_orc_armored"
	},
	{
		name = "enemy_orc_rider"
	},
	{
		name = "enemy_forest_troll"
	},
	{
		name = "eb_gulthak"
	},
	{
		name = "enemy_zombie"
	},
	{
		name = "enemy_spider_rotten"
	},
	{
		name = "enemy_rotten_tree"
	},
	{
		name = "enemy_swamp_thing"
	},
	{
		name = "eb_greenmuck"
	},
	{
		name = "enemy_raider"
	},
	{
		name = "enemy_pillager"
	},
	{
		name = "eb_kingpin"
	},
	{
		name = "enemy_troll_skater"
	},
	{
		name = "enemy_troll_brute"
	},
	{
		name = "eb_ulgukhai"
	},
	{
		name = "enemy_demon_legion"
	},
	{
		name = "enemy_demon_flareon"
	},
	{
		name = "enemy_demon_gulaemon"
	},
	{
		name = "enemy_demon_cerberus"
	},
	{
		name = "eb_moloch"
	},
	{
		name = "enemy_rotten_lesser"
	},
	{
		name = "eb_myconid"
	},
	-- {
	-- 	name = "enemy_halloween_zombie"
	-- },
	{
		name = "enemy_giant_rat"
	},
	{
		name = "enemy_wererat"
	},
	{
		name = "enemy_fallen_knight"
	},
	{
		name = "enemy_spectral_knight"
	},
	-- {
	-- 	name = "enemy_abomination"
	-- },
	{
		name = "enemy_witch"
	},
	-- {
	-- 	name = "enemy_werewolf"
	-- },
	-- {
	-- 	name = "enemy_lycan"
	-- },
	{
		name = "eb_blackburn"
	},
	--重生2：战锤要塞
	{
		always_shown = false,
		name = "enemy_fremen"
	},
	{
		always_shown = false,
		name = "enemy_sand_monk"
	},
	{
		always_shown = false,
		name = "enemy_umbral_acolyte"
	},
	{
		always_shown = false,
		name = "enemy_primordial"
	},
	{
		always_shown = false,
		name = "enemy_set"
	},
	{
		always_shown = false,
		name = "eb_malagar"
	},
	--重生：王国保卫战1代29-31关
	{
		name = "enemy_hobgoblin_small"
	},
	{
		name = "enemy_cursed_shaman"
	},
	{
		name = "enemy_hobgoblin_shield"
	},
	{
		name = "enemy_hobgoblin_rider"
	},
	{
		name = "enemy_goblin_spear"
	},
	{
		name = "enemy_goblin_balloon"
	},
	{
		name = "enemy_cursed_golem"
	},
	{
		name = "enemy_cursed_shard"
	},
	{
		name = "enemy_hobgoblin_miniboss"
	},
	{
		name = "eb_hobgoblin"
	},
	{
		name = "enemy_goblin_platform"
	},
	--5代
	{
		always_shown = false,
		name = "enemy_hog_invader"
	},
	{
		always_shown = false,
		name = "enemy_tusked_brawler"
	},
	{
		always_shown = false,
		name = "enemy_cutthroat_rat"
	},
	{
		always_shown = false,
		name = "enemy_bear_vanguard"
	},
	{
		always_shown = false,
		name = "enemy_turtle_shaman"
	},
	{
		always_shown = false,
		name = "enemy_surveyor_harpy"
	},
	{
		always_shown = false,
		name = "enemy_dreadeye_viper"
	},
	{
		always_shown = false,
		name = "enemy_hyena5"
	},
	{
		always_shown = false,
		name = "enemy_skunk_bombardier"
	},
	{
		always_shown = false,
		name = "enemy_bear_woodcutter"
	},
	{
		always_shown = false,
		name = "enemy_rhino"
	},
	{
		always_shown = false,
		name = "boss_pig"
	},
	{
		always_shown = false,
		name = "enemy_acolyte"
	},
	{
		always_shown = false,
		name = "enemy_acolyte_tentacle"
	},
	{
		always_shown = false,
		name = "enemy_small_stalker"
	},
	{
		always_shown = false,
		name = "enemy_lesser_sister"
	},
	{
		always_shown = false,
		name = "enemy_lesser_sister_nightmare"
	},
	{
		always_shown = false,
		name = "enemy_spiderling"
	},
	{
		always_shown = false,
		name = "enemy_unblinded_priest"
	},
	{
		always_shown = false,
		name = "enemy_unblinded_abomination"
	},
	{
		always_shown = false,
		name = "enemy_unblinded_abomination_stage_8"
	},
	{
		always_shown = false,
		name = "enemy_armored_nightmare"
	},
	{
		always_shown = false,
		name = "enemy_unblinded_shackler"
	},
	{
		always_shown = false,
		name = "enemy_corrupted_stalker"
	},
	{
		always_shown = false,
		name = "enemy_stage_11_cult_leader_illusion"
	},
	{
		always_shown = false,
		name = "enemy_blinker"
	},
	{
		always_shown = false,
		name = "enemy_crystal_golem"
	},
	{
		always_shown = false,
		name = "enemy_glareling"
	},
	{
		always_shown = false,
		name = "boss_corrupted_denas"
	},
	{
		always_shown = false,
		name = "enemy_mindless_husk"
	},
	{
		always_shown = false,
		name = "enemy_vile_spawner"
	},
	{
		always_shown = false,
		name = "enemy_lesser_eye"
	},
	{
		always_shown = false,
		name = "enemy_noxious_horror"
	},
	{
		always_shown = false,
		name = "enemy_hardened_horror"
	},
	{
		always_shown = false,
		name = "enemy_amalgam"
	},
	{
		always_shown = false,
		name = "enemy_evolving_scourge"
	},
	{
		always_shown = false,
		name = "boss_cult_leader"
	},
	{
		always_shown = false,
		name = "controller_stage_16_overseer"
	},
	{
		always_shown = false,
		name = "enemy_corrupted_elf"
	},
	{
		always_shown = false,
		name = "enemy_specter"
	},
	{
		always_shown = false,
		name = "enemy_bane_wolf"
	},
	{
		always_shown = false,
		name = "enemy_dust_cryptid"
	},
	{
		always_shown = false,
		name = "enemy_deathwood"
	},
	{
		always_shown = false,
		name = "enemy_revenant_soulcaller"
	},
	{
		always_shown = false,
		name = "enemy_animated_armor"
	},
	{
		always_shown = false,
		name = "enemy_revenant_harvester"
	},
	{
		always_shown = false,
		name = "boss_navira"
	},
	{
		always_shown = false,
		name = "enemy_crocs_basic"
	},
	{
		always_shown = false,
		name = "enemy_crocs_basic_egg"
	},
	{
		always_shown = false,
		name = "enemy_crocs_ranged"
	},
	{
		always_shown = false,
		name = "enemy_crocs_flier"
	},
	{
		always_shown = false,
		name = "enemy_killertile"
	},
	{
		always_shown = false,
		name = "enemy_quickfeet_gator"
	},
	{
		always_shown = false,
		name = "enemy_crocs_egg_spawner"
	},
	{
		always_shown = false,
		name = "enemy_crocs_shaman"
	},
	{
		always_shown = false,
		name = "enemy_crocs_hydra"
	},
	{
		always_shown = false,
		name = "enemy_crocs_tank"
	},
	{
		always_shown = false,
		name = "boss_crocs_lvl1"
	},
	{
		always_shown = false,
		name = "enemy_darksteel_hammerer"
	},
	{
		always_shown = false,
		name = "enemy_scrap_speedster"
	},
	{
		always_shown = false,
		name = "enemy_darksteel_shielder"
	},
	{
		always_shown = false,
		name = "enemy_darksteel_guardian"
	},
	{
		always_shown = false,
		name = "enemy_surveillance_sentry"
	},
	{
		always_shown = false,
		name = "enemy_rolling_sentry"
	},
	{
		always_shown = false,
		name = "enemy_brute_welder"
	},
	{
		always_shown = false,
		name = "enemy_darksteel_fist"
	},
	{
		always_shown = false,
		name = "enemy_machinist"
	},
	{
		always_shown = false,
		name = "enemy_mad_tinkerer"
	},
	{
		always_shown = false,
		name = "enemy_scrap_drone"
	},
	{
		always_shown = false,
		name = "boss_machinist"
	},
	{
		always_shown = false,
		name = "enemy_darksteel_anvil"
	},
	{
		always_shown = false,
		name = "enemy_common_clone"
	},
	{
		always_shown = false,
		name = "enemy_darksteel_hulk"
	},
	{
		always_shown = false,
		name = "enemy_deformed_grymbeard_clone"
	},
	{
		always_shown = false,
		name = "boss_grymbeard"
	},
	{
		always_shown = false,
		name = "enemy_ballooning_spider"
	},
	{
		always_shown = false,
		name = "enemy_glarenwarden"
	},
	{
		always_shown = false,
		name = "enemy_spider_sister"
	},
	{
		always_shown = false,
		name = "enemy_spider_priest"
	},
	{
		always_shown = false,
		name = "enemy_drainbrood"
	},
	{
		always_shown = false,
		name = "enemy_cultbrood"
	},
	{
		always_shown = false,
		name = "enemy_spidead"
	},
	{
		always_shown = false,
		name = "boss_spider_queen"
	},
	{
		always_shown = false,
		name = "enemy_flame_guard"
	},
	{
		always_shown = false,
		name = "enemy_blaze_raider"
	},
	{
		always_shown = false,
		name = "enemy_fire_fox"
	},
	{
		always_shown = false,
		name = "enemy_fire_phoenix"
	},
	{
		always_shown = false,
		name = "enemy_nine_tailed_fox"
	},
	{
		always_shown = false,
		name = "enemy_wuxian"
	},
	{
		always_shown = false,
		name = "enemy_burning_treant"
	},
	{
		always_shown = false,
		name = "enemy_ash_spirit"
	},
	{
		always_shown = false,
		name = "boss_redboy_teen"
	},
	{
		always_shown = false,
		name = "enemy_citizen_1"
	},
	{
		always_shown = false,
		name = "enemy_citizen_2"
	},
	{
		always_shown = false,
		name = "enemy_citizen_3"
	},
	{
		always_shown = false,
		name = "enemy_citizen_4"
	},
	{
		always_shown = false,
		name = "enemy_gale_warrior"
	},
	{
		always_shown = false,
		name = "enemy_water_spirit"
	},
	{
		always_shown = false,
		name = "enemy_storm_spirit"
	},
	{
		always_shown = false,
		name = "enemy_storm_elemental"
	},
	{
		always_shown = false,
		name = "enemy_qiongqi"
	},
	{
		always_shown = false,
		name = "enemy_water_sorceress"
	},
	{
		always_shown = false,
		name = "enemy_palace_guard"
	},
	{
		always_shown = false,
		name = "enemy_fan_guard"
	},
	{
		always_shown = false,
		name = "boss_princess_iron_fan"
	},
	{
		always_shown = false,
		name = "enemy_doom_bringer"
	},
	{
		always_shown = false,
		name = "enemy_demon_minotaur"
	},
	{
		always_shown = false,
		name = "enemy_golden_eyed"
	},
	{
		always_shown = false,
		name = "enemy_hellfire_warlock"
	},
	{
		always_shown = false,
		name = "boss_bull_king"
	},
	{
		always_shown = false,
		name = "enemy_tower_ray_sheep"
	},
	{
		always_shown = false,
		name = "enemy_pumpkin_witch"
	},
	{
		always_shown = false,
		name = "enemy_basic_lava"
	},
	{
		always_shown = false,
		name = "enemy_evolved_lava"
	},
	{
		always_shown = false,
		name = "enemy_alfa_lava"
	},
	{
		always_shown = false,
		name = "enemy_basic_acid"
	},
	{
		always_shown = false,
		name = "enemy_evolved_acid"
	},
	{
		always_shown = false,
		name = "enemy_alfa_acid"
	},
	{
		always_shown = false,
		name = "enemy_basic_shadow"
	},
	{
		always_shown = false,
		name = "enemy_evolved_shadow"
	},
	{
		always_shown = false,
		name = "enemy_alfa_shadow"
	},
	{
		always_shown = false,
		name = "enemy_basic_storm"
	},
	{
		always_shown = false,
		name = "enemy_evolved_storm"
	},
	{
		always_shown = false,
		name = "enemy_alfa_storm"
	},
	{
		always_shown = false,
		name = "enemy_executioner_storm"
	},
	{
		always_shown = false,
		name = "boss_murglum"
	},
	{
		always_shown = false,
		name = "enemy_miniboss_stage_39"
	},
	{
		always_shown = false,
		name = "controller_stage_39_boss"
	},
	{
		always_shown = false,
		name = "controller_stage_40_boss"
	},
	--4代
	--主线1
	{
		always_shown = false,
		name = "enemy_human_woodcutter"
	},
	{
		always_shown = false,
		name = "enemy_human_worker"
	},
	{
		always_shown = false,
		name = "enemy_bruiser"
	},
	{
		always_shown = false,
		name = "enemy_warhammer_guard"
	},
	{
		always_shown = false,
		name = "enemy_clockwork_spider"
	},
	{
		always_shown = false,
		name = "enemy_chomp_bot"
	},
	{
		always_shown = false,
		name = "enemy_cyclopter_pilot"
	},
	{
		always_shown = false,
		name = "enemy_smokebeard_engineer"
	},
	{
		always_shown = false,
		name = "enemy_tinbeard_gunman"
	},
	{
		always_shown = false,
		name = "enemy_quarry_worker"
	},
	{
		always_shown = false,
		name = "enemy_stonebeard_geomancer"
	},
	{
		always_shown = false,
		name = "enemy_sulfur_alchemist"
	},
	{
		always_shown = false,
		name = "enemy_mechadwarf"
	},
	{
		always_shown = false,
		name = "enemy_boss_dwarf_mecha"
	},
	{
		always_shown = false,
		name = "enemy_blue_wyvern"
	},
	{
		always_shown = false,
		name = "enemy_glacial_wolf"
	},
	{
		always_shown = false,
		name = "enemy_northern_huntress"
	},
	{
		always_shown = false,
		name = "enemy_northern_wildling"
	},
	{
		always_shown = false,
		name = "enemy_apex_stalker"
	},
	{
		always_shown = false,
		name = "enemy_apex_shard"
	},
	{
		always_shown = false,
		name = "enemy_ice_witch"
	},
	{
		always_shown = false,
		name = "enemy_nanoq_warbear"
	},
	{
		always_shown = false,
		name = "enemy_northern_berserker"
	},
	{
		always_shown = false,
		name = "enemy_leap_dragon"
	},
	{
		always_shown = false,
		name = "enemy_valkyrie"
	},
	{
		always_shown = false,
		name = "enemy_draugr_gold"
	},
	{
		always_shown = false,
		name = "enemy_frost_giant"
	},
	{
		always_shown = false,
		name = "enemy_svell_druid"
	},
	{
		always_shown = false,
		name = "enemy_mega_boss_dragon"
	},
	{
		always_shown = false,
		name = "enemy_footman"
	},
	{
		always_shown = false,
		name = "enemy_elite_footman"
	},
	{
		always_shown = false,
		name = "enemy_banner_bearer"
	},
	{
		always_shown = false,
		name = "enemy_guardian_eagle"
	},
	{
		always_shown = false,
		name = "enemy_hunting_dog"
	},
	{
		always_shown = false,
		name = "enemy_devoted_priest"
	},
	{
		always_shown = false,
		name = "enemy_elven_warrior"
	},
	{
		always_shown = false,
		name = "enemy_griffin_bombardier"
	},
	{
		always_shown = false,
		name = "enemy_arcane_magus"
	},
	{
		always_shown = false,
		name = "enemy_high_sorcerer"
	},
	{
		always_shown = false,
		name = "enemy_musketeer"
	},
	{
		always_shown = false,
		name = "enemy_paladin"
	},
	{
		always_shown = false,
		name = "enemy_farmer_bucket"
	},
	{
		always_shown = false,
		name = "enemy_tower_shield_knight"
	},
	{
		always_shown = false,
		name = "enemy_knight_rider"
	},
	{
		always_shown = false,
		name = "enemy_war_wagon"
	},
	{
		always_shown = false,
		name = "enemy_golem_house"
	},
	{
		always_shown = false,
		name = "enemy_lightseeker"
	},
	{
		always_shown = false,
		name = "enemy_mega_knight"
	},
	--青蛙
	{
		always_shown = false,
		name = "enemy_chaser"
	},
	{
		always_shown = false,
		name = "enemy_warden"
	},
	{
		always_shown = false,
		name = "enemy_amphiptere"
	},
	{
		always_shown = false,
		name = "enemy_bullywags_golem"
	},
	{
		always_shown = false,
		name = "enemy_infuser"
	},
	{
		always_shown = false,
		name = "enemy_bullywags_channeler"
	},
	{
		always_shown = false,
		name = "enemy_bullywags_erudite"
	},
	{
		always_shown = false,
		name = "enemy_boss_anurian"
	},
	{
		always_shown = false,
		name = "enemy_frozen_heart"
	},
	{
		always_shown = false,
		name = "enemy_frozen_soul"
	},
	{
		always_shown = false,
		name = "enemy_ice_golem"
	},
	{
		always_shown = false,
		name = "enemy_ice_reaper"
	},
	{
		always_shown = false,
		name = "enemy_winter_lord"
	},
	{
		always_shown = false,
		name = "enemy_winter_queen"
	},
	{
		always_shown = false,
		name = "enemy_mogwai"
	},
	{
		always_shown = false,
		name = "enemy_nian"
	},
	{
		always_shown = false,
		name = "enemy_carnival_dragon_head"
	},
	{
		always_shown = false,
		name = "enemy_dragon_king_boss"
	},
	--鬼王
	{
		always_shown = false,
		name = "enemy_kr4_ghost"
	},
	{
		always_shown = false,
		name = "enemy_haunted_skeleton"
	},
	{
		always_shown = false,
		name = "enemy_werewolf_db"
	},
	{
		always_shown = false,
		name = "enemy_corrosive_soul"
	},
	{
		always_shown = false,
		name = "enemy_lich"
	},
	{
		always_shown = false,
		name = "enemy_kr4_screecher_bat"
	},
	{
		always_shown = false,
		name = "enemy_bone_carrier"
	},
	{
		always_shown = false,
		name = "enemy_lord_of_afterlife"
	},
	{
		always_shown = false,
		name = "enemy_lord_of_afterlife_2"
	},
	{
		always_shown = false,
		name = "enemy_prehistoric_dwarf"
	},
	{
		always_shown = false,
		name = "enemy_velociraptor"
	},
	{
		always_shown = false,
		name = "enemy_pterodactyl"
	},
	{
		always_shown = false,
		name = "enemy_charly"
	},
	{
		always_shown = false,
		name = "enemy_boss_great_t"
	},
	{
		always_shown = false,
		name = "enemy_legionnaire"
	},
	{
		always_shown = false,
		name = "enemy_legion_archer"
	},
	{
		always_shown = false,
		name = "enemy_camel_rider"
	},
	{
		always_shown = false,
		name = "enemy_legion_nomad"
	},
	{
		always_shown = false,
		name = "enemy_djini"
	},
	{
		always_shown = false,
		name = "enemy_magic_carpet"
	},
	{
		always_shown = false,
		name = "enemy_falconeer"
	},
	{
		always_shown = false,
		name = "enemy_desert_eagle"
	},
	{
		always_shown = false,
		name = "enemy_sand_mysthic"
	},
	{
		always_shown = false,
		name = "enemy_assassin"
	},
	{
		always_shown = false,
		name = "enemy_war_elephant"
	},
	{
		always_shown = false,
		name = "enemy_elephant_lancer"
	},
	{
		always_shown = false,
		name = "enemy_mirage_path"
	},
	{
		always_shown = false,
		name = "enemy_alric"
	},
	{
		always_shown = false,
		name = "enemy_malik"
	},
	-- freebooter 的原版 0140 头像在当前目标拆图目录缺失，先不加入，避免错头像。
	{
		always_shown = false,
		name = "enemy_bucaneer"
	},
	{
		always_shown = false,
		name = "enemy_corsair"
	},
	{
		always_shown = false,
		name = "enemy_boatswain"
	},
	{
		always_shown = false,
		name = "enemy_bomber_parrot"
	},
	{
		always_shown = false,
		name = "enemy_rushing_monkey"
	},
	{
		always_shown = false,
		name = "enemy_filibusters"
	},
	{
		always_shown = false,
		name = "enemy_boom_baboon"
	},
	{
		always_shown = false,
		name = "enemy_great_macaw"
	},
	{
		always_shown = false,
		name = "enemy_apemate"
	},
	{
		always_shown = false,
		name = "enemy_tailblade"
	},
	{
		always_shown = false,
		name = "enemy_lemonshark"
	},
	{
		always_shown = false,
		name = "enemy_bullshark_dasher"
	},
	{
		always_shown = false,
		name = "enemy_tigershark_rager"
	},
	{
		always_shown = false,
		name = "enemy_hammermage"
	},
	{
		always_shown = false,
		name = "enemy_megalodon"
	},
	{
		always_shown = false,
		name = "enemy_risen_cutthroat"
	},
	{
		always_shown = false,
		name = "enemy_corpse_recruiter"
	},
	{
		always_shown = false,
		name = "enemy_ghostly_barge"
	},
	{
		always_shown = false,
		name = "enemy_cursed_sailor"
	},
	{
		always_shown = false,
		name = "enemy_hanged_captain"
	},
	{
		always_shown = false,
		name = "enemy_black_corsair"
	},
	{
		always_shown = false,
		name = "enemy_macaque"
	},
	{
		always_shown = false,
		name = "enemy_deep_king_throne"
	},
	{
		always_shown = false,
		name = "enemy_flying_ghost_ship"
	},
	{
		always_shown = false,
		name = "enemy_blackthorne"
	},
	-- KR4 Zeta campaign enemies. Variant-only units reuse their base entry;
	-- these are the new silhouettes and named encounters introduced by 193-201.
	{always_shown = false, name = "enemy_boron_alchemist"},
	{always_shown = false, name = "enemy_winter_lord_soldier"},
	{always_shown = false, name = "enemy_winter_lord_mage"},
	{always_shown = false, name = "enemy_frozen_soul_mage"},
	{always_shown = false, name = "enemy_toxic_blob"},
	{always_shown = false, name = "enemy_wilbur"},
	{always_shown = false, name = "enemy_juggernaut_eva"},
	{always_shown = false, name = "enemy_ruin_spider"},
	{always_shown = false, name = "enemy_demon_spawn"},
	{always_shown = false, name = "enemy_demon_guards"},
	{always_shown = false, name = "enemy_demon_tridents"},
	{always_shown = false, name = "enemy_demon_flaming_tridents"},
	{always_shown = false, name = "enemy_oloch_duplicate"},
	{always_shown = false, name = "enemy_hounds_of_tindalos"},
	{always_shown = false, name = "enemy_demon_lord"},
	{always_shown = false, name = "enemy_demon_fat"},
	{always_shown = false, name = "enemy_cerberus"},
	{always_shown = false, name = "enemy_kr4_enemy_demon_veznan"},
	{always_shown = false, name = "enemy_kr1_enemy_demon_moloch"},
	{always_shown = false, name = "enemy_kr4_enemy_demon_oloch"},
	{always_shown = false, name = "enemy_kr4_boss_red_triplet"},
	-- 6代
	{always_shown = true, generation = 6, name = "enemy_bandit_g6"},
	{always_shown = false, generation = 6, name = "enemy_blackguard"},
	{always_shown = false, generation = 6, name = "enemy_shadow_archer_g6"},
	{always_shown = false, generation = 6, name = "enemy_shadow_blades"},
	{always_shown = false, generation = 6, name = "enemy_crow"},
	{always_shown = false, generation = 6, name = "enemy_crowcaller"},
	{always_shown = false, generation = 6, name = "enemy_goblin_g6"},
	{always_shown = false, generation = 6, name = "enemy_orc_warrior"},
	{always_shown = false, generation = 6, name = "enemy_orc_shaman"},
	{always_shown = false, generation = 6, name = "enemy_wulf"},
	{always_shown = false, generation = 6, name = "enemy_worg"},
	{always_shown = false, generation = 6, name = "enemy_orc_wildling"},
	{always_shown = false, generation = 6, name = "enemy_headhunter"},
	{always_shown = false, generation = 6, name = "enemy_nivus_broom"},
	{always_shown = false, generation = 6, name = "enemy_rider_goblin"},
	{always_shown = false, generation = 6, name = "enemy_ogre_g6"},
	{always_shown = false, generation = 6, name = "enemy_boss_stage_08"},
	{always_shown = false, generation = 6, name = "enemy_troll_warrior"},
	{always_shown = false, generation = 6, name = "enemy_troll_champion_g6"},
	{always_shown = false, generation = 6, name = "enemy_troll_glider"},
	{always_shown = false, generation = 6, name = "enemy_frost_icecaller"},
	{always_shown = false, generation = 6, name = "enemy_troll_crusher"},
	{always_shown = false, generation = 6, name = "enemy_troll_pathfinder"},
	{always_shown = false, generation = 6, name = "enemy_frost_baiter"},
	{always_shown = false, generation = 6, name = "enemy_frost_brute"},
	{always_shown = false, generation = 6, name = "enemy_boss_stage_10"},
	{always_shown = false, generation = 6, name = "enemy_spiderling_g6"},
	{always_shown = false, generation = 6, name = "enemy_giant_spider"},
	{always_shown = false, generation = 6, name = "enemy_spider_matriarch"},
	{always_shown = false, generation = 6, name = "enemy_leaper_spider"},
	{always_shown = false, generation = 6, name = "enemy_son_of_sarelgaz"},
	{always_shown = false, generation = 6, name = "enemy_boss_stage_11"},
	{always_shown = false, generation = 6, name = "enemy_troll_chieftain_g6"},
	{always_shown = false, generation = 6, name = "enemy_boss_stage_13"},
	{always_shown = false, generation = 6, name = "enemy_brigand_g6"},
	{always_shown = false, generation = 6, name = "enemy_gargoyle_g6"},
	{always_shown = false, generation = 6, name = "enemy_dark_sapper"},
	{always_shown = false, generation = 6, name = "enemy_tainted_wolf"},
	{always_shown = false, generation = 6, name = "enemy_skeleton_g6"},
	{always_shown = false, generation = 6, name = "enemy_skeleton_big_g6"},
	{always_shown = false, generation = 6, name = "enemy_dark_disciple"},
	{always_shown = false, generation = 6, name = "enemy_swamp_thing_g6"},
	{always_shown = false, generation = 6, name = "enemy_swamp_husk"},
	{always_shown = false, generation = 6, name = "enemy_necromancer_g6"},
	{always_shown = false, generation = 6, name = "enemy_boss_stage_15"},
	{always_shown = false, generation = 6, name = "enemy_death_rider"},
	{always_shown = false, generation = 6, name = "enemy_rotten_tree_g6"},
	{always_shown = false, generation = 6, name = "enemy_dark_knight_g6"},
	{always_shown = false, generation = 6, name = "enemy_dark_slayer"},
	{always_shown = false, generation = 6, name = "enemy_demon_spawn_g6"},
	{always_shown = false, generation = 6, name = "enemy_demon_hound"},
	{always_shown = false, generation = 6, name = "enemy_demon_lord_g6"},
	{always_shown = false, generation = 6, name = "enemy_demon_flareon_g6"},
	{always_shown = false, generation = 6, name = "enemy_demon_imp_g6"},
	{always_shown = false, generation = 6, name = "enemy_magma_elemental"},
	{always_shown = false, generation = 6, name = "enemy_stage_18_veznan"},
}

GS.towers_required_exoskeletons = {
	[22] = {
		"avenger2",
	},
	[24] = {
		"ignis_altar_lava_golem",
		"ignis_altar_lvl1",
		"ignis_altar_lvl2",
		"ignis_altar_lvl3",
		"ignis_altar_lvl4",
		"ignis_altar_decal",
		"ignis_altar_decal_lava",
		"sumo_tower",
		"sumo_towerDecalBasicAttack",
		"sumo_towerGeyser",
		"sumo_towerSkillAModifier",
		"sumo_towerSkillBDecal",
		"sumo_towerSkillBUnit",
		"sumo_towerSmoke",
		"sumo_towerSmokeModifier",
	},
	[32] = {
		"tower_plant_base",
		"nuclear_tower",
		"nuclear_ball",
		"nuclear_blob",
		"nuclear_blob_skill",
		"nuclear_spawn",
		"nuclear_decal_skill",
		"nuclear_tower_blob_spawn_trail",
		"nuclear_tower_blob_spawn_explosion",
		"nuclear_tower_decal",
		"nucleartower_modify",
	},
	[36] = {
		"dronehivetower",
		"dronehivedrone",
		"dronehivedrone_skilla",
		"dronehivedrone_skillb",
		"droneshootbody",
		"droneshootfloor",
		"dronespecialbomb",
		"dronespecialexplosion",
		"dronetrailrabbit",
		"commandcenter_activate",
		"commandcenter_parabolic",
		"commandcenter_power_tower_decal",
	},
	[37] = {
		"subway_back",
		"subway_front",
		"rat_tower_small_rat",
		"harpooner_boy",
		"harpooner_girl",
		"harpooner_shield",
		"rat_tower_small_soldier_basic_skill",
		"rat_tower_big_rat",
		"rat_tower_warriors",
		"rat_tower_modifier",
	}
}

GS.towers_required_exoskeleton_groups = {
	[44] = {"go_towers_archers"},
	[46] = {"go_towers_wizard"},
	[47] = {"go_towers_catapult"},
	[49] = {"go_towers_culverine"},
	[51] = {"go_towers_light_priestess"},
	[52] = {"go_towers_tree"},
	[54] = {"go_towers_alchemist"},
	[57] = {"go_towers_miners"},
	[58] = {"go_towers_sniper"}
}

GS.heroes_required_exoskeleton_groups = {
	hero_gerald_g6 = {"go_hero_gerald"},
	hero_zefira = {"go_hero_zefira"},
	hero_bolin_g6 = {"go_hero_bolin"},
	hero_malik_g6 = {"go_hero_malik"},
	hero_ashbite = {"go_hero_ashbite"},
	hero_rhodes = {"go_hero_rhodes"},
	hero_drakkan = {"go_hero_drakkan"},
	hero_myriath = {"go_hero_myriath"},
	hero_connor = {"go_hero_connor"},
	hero_ignus_g6 = {"go_hero_ignus"},
	hero_oni_g6 = {"go_hero_oni"},
	hero_illiana = {"go_hero_illiana"},
	hero_silent = {}
}

GS.heroes_required_sound_groups = {
	hero_gerald_g6 = "kr6_hero_gerald",
	hero_zefira = "kr6_hero_zefira",
	hero_bolin_g6 = "kr6_hero_bolin",
	hero_malik_g6 = "kr6_hero_malik",
	hero_ashbite = "kr6_hero_ashbite",
	hero_rhodes = "kr6_hero_rhodes",
	hero_drakkan = "kr6_hero_drakkan",
	hero_myriath = "kr6_hero_myriath",
	hero_connor = "kr6_hero_connor",
	hero_ignus_g6 = "kr6_hero_ignus",
	hero_oni_g6 = "kr6_hero_oni",
	hero_illiana = "kr6_hero_illiana",
	hero_silent = "kr6_common_gameplay"
}

for i = #GS.encyclopedia_enemies, 1, -1 do
	if GS.encyclopedia_enemies[i].target and GS.encyclopedia_enemies[i].target ~= KR_TARGET then
		table.remove(GS.encyclopedia_enemies, i)
	end
end

-- BEGIN DOVE43 BUILTIN TOWERS
GS.towers_dove43_exoskeletons = {["shadow_archer"]={"d43_sniper","d43_sniper_base","d43_sniper_base_skill_a","d43_sniper_base_skill_b","d43_sniper_mira","d43_sniper_mira_decal","d43_sniper_skill_attack","d43_sniper_skill_blood","d43_sniper_skill_bullet","d43_sniper_skill_mira","d43_sniper_skill_smoketrail","d43_sniper_skill_spotter"},["rocket_riders"]={"d43_plaguetower","d43_plaguetower_buff2","d43_plaguetower_decal","d43_plaguetower_doctor","d43_plaguetower_doctor_skilla","d43_plaguetower_electricity","d43_plaguetower_giant","d43_plaguetower_skilla","d43_plaguetower_skillab","d43_plaguetower_skillb","d43_plaguetower_smoke","d43_plaguetower_status","d43_plaguetower_towersmoke","d43_plaguetower_zombie"},["melting_furnace"]={"d43_commandcenter_activate","d43_commandcenter_flashbang","d43_commandcenter_flashbangFX","d43_commandcenter_parabolic","d43_commandcenter_power_explosion","d43_commandcenter_power_missile","d43_commandcenter_power_plane","d43_commandcenter_power_smoke","d43_commandcenter_power_target","d43_commandcenter_power_tower_decal","d43_commandcenter_skilladvanced","d43_commandcenter_skillbwaves","d43_commandcenter_tower","d43_commandcenter_tower_a","d43_commandcenter_tower_ab","d43_commandcenter_tower_b"},["orc_shaman"]={"d43_icecooler_breath","d43_icecooler_explosion_cian","d43_icecooler_explosion_green","d43_icecooler_explosion_pink","d43_icecooler_fan_cyan","d43_icecooler_fan_green","d43_icecooler_fan_pink","d43_icecooler_freeze_mark","d43_icecooler_freeze_mod","d43_icecooler_icecloud","d43_icecooler_shooter","d43_icecooler_snowman","d43_icecooler_tower","d43_icecooler_tower_skilla","d43_icecooler_tower_skillab","d43_icecooler_tower_skillb"},["goblirang"]={"d43_machinegunner_base","d43_machinegunner_base_skill_a","d43_machinegunner_base_skill_b","d43_machinegunner_ripple_fx","d43_shooter_machinegunner","d43_shooter_machinegunner_basic","d43_shooter_machinegunner_hit","d43_shooter_machinegunner_skill_explosion"}}
GS.towers_dove43_exoskeletons.rocket_riders = nil
GS.towers_dove43_exoskeletons.grim_cemetery = {
	"d43_plaguetower", "d43_plaguetower_buff2", "d43_plaguetower_decal",
	"d43_plaguetower_doctor", "d43_plaguetower_doctor_skilla", "d43_plaguetower_electricity",
	"d43_plaguetower_giant", "d43_plaguetower_skilla", "d43_plaguetower_skillab",
	"d43_plaguetower_skillb", "d43_plaguetower_smoke", "d43_plaguetower_status",
	"d43_plaguetower_towersmoke", "d43_plaguetower_zombie",
}
GS.towers_dove43_exoskeletons.ogre_shipwreck = {
	"d43_aerial_bull_decal", "d43_aerial_bull_explosion", "d43_aerial_bull_rocket_skillB",
	"d43_aerial_bull_rocket", "d43_aerial_bull_trail", "d43_aerial_cactus_explosion",
	"d43_aerial_cactus_missil_skillA", "d43_aerial_cactus_missil", "d43_aerial_cactus_trail",
	"d43_aerial_drone_explosion_skillA", "d43_aerial_drone_shadow_skillA", "d43_aerial_drone_skillA",
	"d43_aerial_modify_skillB", "d43_aerial_rally_decal_skillB", "d43_aerial_rally_decal",
	"d43_aerial_rally_skillB", "d43_aerial_rally", "d43_aerial_skillA_mira",
	"d43_aerial_strike_cactus_skill_a", "d43_aerial_strike_cactus_skill_ab",
	"d43_aerial_strike_cactus_skill_b", "d43_aerial_strike_cactus",
	"d43_aerial_strike_skill_a", "d43_aerial_strike_skill_ab",
	"d43_aerial_strike_skill_b", "d43_aerial_strike",
}
GS.towers_dove43_exoskeletons.spirit_mausoleum = {
	"d43_wifi_babies_explosion", "d43_wifi_babies_floatingbabies_decal",
	"d43_wifi_babies_floatingbabies", "d43_wifi_babies_mind_control",
	"d43_wifi_babies_nuclear_stun", "d43_wifi_babies_part", "d43_wifi_babies_pulse",
	"d43_wifi_babies_skilla", "d43_wifi_babies_skillab", "d43_wifi_babies_skillb",
	"d43_wifi_babies", "d43_wifi_ray",
}
-- END DOVE43 BUILTIN TOWERS
return GS
