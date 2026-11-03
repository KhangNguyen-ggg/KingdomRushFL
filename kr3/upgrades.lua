-- chunkname: @./kr3/upgrades.lua

local log = require("klua.log"):new("upgrades")
local km = require("klua.macros")
local E = require("entity_db")
local bit = require("bit")
local balance = require("balance/balance")
local storage = require("storage")
local enemy_enhance = require("enemy_enhance")
local generation_upgrades = require("generation_upgrades")
local upgrades_6 = require("upgrades_6")
local hero_upgrades_6 = require("hero_upgrades_6")

require("constants")

local function T(name)
	return E:get_template(name)
end

local function ensure_template(name, base)
	return E.entities[name] or E:register_t(name, base)
end
--征服
local function DP(desktop, phone)
	return not (KR_TARGET ~= "phone" and KR_TARGET ~= "tablet") and phone or desktop
end
--
local epsilon = 1e-09
local upgrades = {}

upgrades.max_level = nil
upgrades.levels = {}
upgrades.levels.archers = 0
upgrades.levels.barracks = 0
upgrades.levels.mages = 0
upgrades.levels.reinforcements = 0
upgrades.levels.rocks = 0
upgrades.levels.thunder = 0
upgrades.display_order = {
	"archers",
	"barracks",
	"mages",
	"rocks",
	"thunder",
	"reinforcements"
}
upgrades.list = {
	archer_el_master_shooter = {
		damage_factor = 1.05,
		class = "archers",
		icon = 1,
		price = 1,
		level = 1
	},
	archer_salvage = {
		refund_factor = 0.9,
		class = "archers",
		price = 1,
		level = 1,
		icon = 1
	},
	archer_improved_aim = {
		range_factor = 1.1,
		class = "archers",
		icon = 1,
		price = 1,
		level = 1
	},
	
	archer_el_treesinged_bow = {
		range_factor = 1.1,
		class = "archers",
		icon = 2,
		price = 1,
		level = 2
	},
	archer_eagle_eye = {
		range_factor = 1.1,
		class = "archers",
		price = 1,
		level = 2,
		icon = 2
	},
	archer_lumbermill = {
		cost_reduction = 10,
		class = "archers",
		icon = 2,
		price = 1,
		level = 2
	},
	
	archer_el_obsidian_heads = {
		price = 2,
		icon = 3,
		class = "archers",
		level = 3
	},
	archer_focused_aim = {
		damage_factor = 1.05,
		class = "archers",
		icon = 3,
		price = 2,
		level = 3
	},
	archer_piercing = {
		class = "archers",
		reduce_armor_factor = 0.1,
		price = 2,
		level = 3,
		icon = 3
	},
	
	archer_el_elven_training = {
		burst_damage_factor = 1.1,
		sentence_chance_factor = 1.1,
		damage_factor = 1.1,
		class = "archers",
		mark_damage_factor = 1.1,
		slumber_duration_factor = 1.1,
		icon = 4,
		price = 2,
		level = 4
	},
	archer_far_shots = {
		range_factor = 1.1,
		class = "archers",
		price = 2,
		level = 4,
		icon = 4
	},
	archer_master_marksmanship = {
		range_factor = 1.05,
		damage_factor = 1.1,
		class = "archers",
		icon = 4,
		price = 2,
		level = 4
	},
	
	archer_el_bloodletting_shoot = {
		price = 3,
		icon = 5,
		class = "archers",
		level = 5
	},
	archer_twin_shot = {
		class = "archers",
		chance = 0.1,
		icon = 5,
		price = 3,
		level = 5
	},
	archer_precision = {
		damage_factor = 2,
		class = "archers",
		chance = 0.1,
		price = 3,
		level = 5,
		icon = 5
	},
	
	barrack_el_elven_fencing = {
		class = "barracks",
		cost_factor = 0.9,
		icon = 6,
		price = 1,
		level = 1
	},
	barrack_el_expert_tactician = {
		rally_range_factor = 1.1,
		class = "barracks",
		icon = 7,
		price = 1,
		level = 2
	},
	barrack_el_enchanted_armor = {
		class = "barracks",
		armor_increase = 0.1,
		icon = 8,
		price = 2,
		level = 3
	},
	barrack_el_moon_forged_blades = {
		price = 2,
		icon = 9,
		class = "barracks",
		level = 4
	},
	barrack_el_cheat_death = {
		class = "barracks",
		chance = 0.1,
		revivechance = 0.1,
		icon = 10,
		price = 3,
		level = 5
	},
	
	barrack_survival = {
		health_factor = 1.1,
		class = "barracks",
		price = 1,
		level = 1,
		icon = 6
	},
	barrack_better_armor = {
		class = "barracks",
		armor_increase = 0.1,
		price = 1,
		level = 2,
		icon = 7
	},
	barrack_improved_deployment = {
		cooldown_factor = 0.8,
		rally_range_factor = 1.2,
		class = "barracks",
		price = 2,
		level = 3,
		icon = 8
	},
	barrack_survival_2 = {
		health_factor = 1.0909,
		class = "barracks",
		price = 2,
		level = 4,
		icon = 9
	},
	barrack_barbed_armor = {
		spiked_armor_factor = 0.1,
		class = "barracks",
		price = 3,
		level = 5,
		icon = 10
	},
	
	barrack_defensive_techniques = {
		class = "barracks",
		armor_increase = 0.1,
		icon = 6,
		price = 1,
		level = 1
	},
	barrack_boot_camp = {
		class = "barracks",
		icon = 7,
		price = 1,
		level = 2,
		health_factor = 1.1 - epsilon
	},
	barrack_esprit_des_corps = {
		rally_range_factor = 1.2,
		regen_factor = 1.2,
		class = "barracks",
		icon = 8,
		price = 2,
		level = 3
	},
	barrack_veteran_squad = {
		respawn_reduction = 2,
		class = "barracks",
		armor_increase = 0.1,
		icon = 9,
		price = 2,
		level = 4
	},
	barrack_courage = {
		regen_cooldown = 1,
		regen_factor = 0.01,
		class = "barracks",
		icon = 10,
		price = 3,
		level = 5
	},
	
	mage_el_crystal_focus = {
		range_factor = 1.05,
		class = "mages",
		icon = 11,
		price = 1,
		level = 1
	},
	mage_el_bane_spell = {
		damage_factor = 1.15,
		class = "mages",
		icon = 12,
		price = 1,
		level = 2
	},
	mage_el_crystal_gazing = {
		range_factor = 1.05,
		class = "mages",
		icon = 13,
		price = 2,
		level = 3
	},
	mage_el_empowerment = {
		damage_factor = 3,
		class = "mages",
		chance = 0.05,
		icon = 14,
		price = 2,
		level = 4
	},
	mage_el_alter_reality = {
		price = 3,
		icon = 15,
		class = "mages",
		level = 5
	},
	
	mage_rune_of_power = {
		range_factor = 1.1,
		class = "mages",
		icon = 11,
		price = 1,
		level = 1
	},
	mage_spell_of_penetration = {
		class = "mages",
		chance = 0.1,
		icon = 12,
		price = 1,
		level = 2
	},
	mage_eldrich_power = {
		damage_factor = 1.1,
		class = "mages",
		icon = 13,
		price = 2,
		level = 3
	},
	mage_wizard_academy = {
		class = "mages",
		cost_factor = 0.9,
		icon = 14,
		price = 2,
		level = 4
	},
	mage_brilliance = {
		class = "mages",
		icon = 15,
		price = 3,
		level = 5,
		damage_factors = {
			1,
			1.05,
			1.1,
			1.14,
			1.18,
			1.21,
			1.24,
			1.27,
			1.3
		}
	},
	
	mage_spell_reach = {
		range_factor = 1.1,
		class = "mages",
		price = 1,
		level = 1,
		icon = 11
	},
	mage_arcane_shatter = {
		mod = "mod_arcane_shatter",
		class = "mages",
		chance = 0.1,
		price = 1,
		level = 2,
		icon = 12
	},
	mage_hermetic_study = {
		class = "mages",
		cost_factor = 0.9,
		price = 2,
		level = 3,
		icon = 13
	},
	mage_empowered_magic = {
		damage_factor = 1.15,
		class = "mages",
		chance = 0.1,
		price = 2,
		level = 4,
		icon = 14
	},
	mage_slow_curse = {
		mod = "mod_slow_curse",
		class = "mages",
		price = 3,
		level = 5,
		icon = 15
	},
	
	stone_el_druid_hardened_boulders = {
		damage_factor = 1.1,
		class = "rocks",
		icon = 16,
		price = 1,
		level = 1
	},
	stone_el_druid_sharp_splinters = {
		damage_area_factor = 1.1,
		armor_increase = 0.5,
		class = "rocks",
		icon = 17,
		price = 1,
		level = 2
	},
	stone_el_druid_earth_mastery = {
		range_factor = 1.1,
		class = "rocks",
		icon = 18,
		price = 2,
		level = 3
	},
	stone_el_druid_heavy_load = {
		price = 3,
		icon = 19,
		class = "rocks",
		level = 4
	},
	stone_el_druid_shocking_impact = {
		price = 3,
		icon = 20,
		class = "rocks",
		level = 5
	},
	
	engineer_concentrated_fire = {
		damage_factor = 1.1,
		class = "rocks",
		price = 1,
		level = 1,
		icon = 16
	},
	engineer_range_finder = {
		range_factor = 1.1,
		class = "rocks",
		price = 1,
		level = 2,
		icon = 17
	},
	engineer_field_logistics = {
		class = "rocks",
		cost_factor = 0.9,
		price = 2,
		level = 3,
		icon = 18
	},
	engineer_industrialization = {
		class = "rocks",
		cost_factor = 0.75,
		price = 3,
		level = 4,
		icon = 19
	},
	engineer_efficiency = {
		price = 3,
		class = "rocks",
		level = 5,
		icon = 20
	},
	
	engineer_smoothbore = {
		range_factor = 1.1,
		class = "rocks",
		icon = 16,
		price = 1,
		level = 1
	},
	engineer_alchemical_powder = {
		class = "rocks",
		chance = 0.1,
		icon = 17,
		price = 1,
		level = 2
	},
	engineer_improved_ordnance = {
		damage_factor = 1.1,
		class = "rocks",
		icon = 18,
		price = 2,
		level = 3
	},
	engineer_gnomish_tinkering = {
		cooldown_factor = 0.9,
		class = "rocks",
		icon = 19,
		price = 3,
		level = 4
	},
	engineer_shock_and_awe = {
		class = "rocks",
		chance = 0.2,
		icon = 20,
		price = 3,
		level = 5
	},
	
	thunder_level_1 = {
		hits = 6,
		class = "thunder",
		icon = 21,
		price = 2,
		level = 1
	},
	thunder_level_2 = {
		price = 2,
		icon = 22,
		class = "thunder",
		level = 2
	},
	thunder_level_3 = {
		price = 3,
		icon = 23,
		class = "thunder",
		level = 3
	},
	thunder_level_4 = {
		price = 3,
		icon = 24,
		class = "thunder",
		level = 4
	},
	thunder_level_5 = {
		price = 3,
		icon = 25,
		class = "thunder",
		level = 5
	},

	rain_blazing_skies = {
		fireball_count_increase = 2,
		class = "thunder",
		damage_increase = 20,
		price = 2,
		level = 1,
		icon = 21
	},
	rain_scorched_earth = {
		price = 2,
		class = "thunder",
		level = 2,
		icon = 22
	},
	rain_bigger_and_meaner = {
		range_factor = 1.25,
		cooldown_reduction = 10,
		class = "thunder",
		damage_increase = 40,
		price = 3,
		level = 3,
		icon = 23
	},
	rain_blazing_earth = {
		cooldown_reduction = 10,
		class = "thunder",
		price = 3,
		level = 4,
		icon = 24
	},
	rain_cataclysm = {
		class = "thunder",
		damage_increase = 60,
		price = 3,
		level = 5,
		icon = 25
	},

	reinforcement_level_1 = {
		class = "reinforcements",
		template_name = "soldier_re_1",
		icon = 26,
		price = 2,
		level = 1
	},
	reinforcement_level_2 = {
		class = "reinforcements",
		template_name = "soldier_re_2",
		icon = 27,
		price = 3,
		level = 2
	},
	reinforcement_level_3 = {
		class = "reinforcements",
		template_name = "soldier_re_3",
		icon = 28,
		price = 3,
		level = 3
	},
	reinforcement_level_4 = {
		class = "reinforcements",
		template_name = "soldier_re_4",
		icon = 29,
		price = 3,
		level = 4
	},
	reinforcement_level_5 = {
		class = "reinforcements",
		template_name = "soldier_re_5",
		icon = 30,
		price = 4,
		level = 5
	},	
}

upgrades.generation_item_keys = {
	[1] = {
		"archer_salvage", "archer_eagle_eye", "archer_piercing", "archer_far_shots", "archer_precision",
		"barrack_survival", "barrack_better_armor", "barrack_improved_deployment", "barrack_survival_2", "barrack_barbed_armor",
		"mage_spell_reach", "mage_arcane_shatter", "mage_hermetic_study", "mage_empowered_magic", "mage_slow_curse",
		"engineer_concentrated_fire", "engineer_range_finder", "engineer_field_logistics", "engineer_industrialization", "engineer_efficiency",
		"rain_blazing_skies", "rain_scorched_earth", "rain_bigger_and_meaner", "rain_blazing_earth", "rain_cataclysm",
		"reinforcement_level_1", "reinforcement_level_2", "reinforcement_level_3", "reinforcement_level_4", "reinforcement_level_5"
	},
	[2] = {
		"archer_improved_aim", "archer_lumbermill", "archer_focused_aim", "archer_master_marksmanship", "archer_twin_shot",
		"barrack_defensive_techniques", "barrack_boot_camp", "barrack_esprit_des_corps", "barrack_veteran_squad", "barrack_courage",
		"mage_rune_of_power", "mage_spell_of_penetration", "mage_eldrich_power", "mage_wizard_academy", "mage_brilliance",
		"engineer_smoothbore", "engineer_alchemical_powder", "engineer_improved_ordnance", "engineer_gnomish_tinkering", "engineer_shock_and_awe",
		"rain_blazing_skies", "rain_scorched_earth", "rain_bigger_and_meaner", "rain_blazing_earth", "rain_cataclysm",
		"reinforcement_level_1", "reinforcement_level_2", "reinforcement_level_3", "reinforcement_level_4", "reinforcement_level_5"
	},
	[3] = {
		"archer_el_master_shooter", "archer_el_treesinged_bow", "archer_el_obsidian_heads", "archer_el_elven_training", "archer_el_bloodletting_shoot",
		"barrack_el_elven_fencing", "barrack_el_expert_tactician", "barrack_el_enchanted_armor", "barrack_el_moon_forged_blades", "barrack_el_cheat_death",
		"mage_el_crystal_focus", "mage_el_bane_spell", "mage_el_crystal_gazing", "mage_el_empowerment", "mage_el_alter_reality",
		"stone_el_druid_hardened_boulders", "stone_el_druid_sharp_splinters", "stone_el_druid_earth_mastery", "stone_el_druid_heavy_load", "stone_el_druid_shocking_impact",
		"thunder_level_1", "thunder_level_2", "thunder_level_3", "thunder_level_4", "thunder_level_5",
		"reinforcement_level_1", "reinforcement_level_2", "reinforcement_level_3", "reinforcement_level_4", "reinforcement_level_5"
	}
}

upgrades.item_generations = {}

for generation, keys in pairs(upgrades.generation_item_keys) do
	for _, key in ipairs(keys) do
		upgrades.item_generations[key] = upgrades.item_generations[key] or {}
		upgrades.item_generations[key][generation] = true
	end
end

local function blank_levels()
	local levels = {}

	for _, class in ipairs(upgrades.display_order) do
		levels[class] = 0
	end

	return levels
end

local function copy_levels(source)
	local levels = blank_levels()

	if type(source) == "table" then
		for _, class in ipairs(upgrades.display_order) do
			levels[class] = tonumber(source[class]) or 0
		end
	end

	return levels
end

function upgrades:generation_for_level(level_idx)
	if not level_idx then
		return 3
	elseif level_idx < 39 then
		return 1
	elseif level_idx < 77 then
		return 2
	elseif level_idx < 101 then
		return 3
	elseif level_idx < 150 then
		return 5
	else
		return 4
	end
end

function upgrades:normalize_user_data(user_data)
	if type(user_data.upgrades_by_generation) ~= "table" then
		local legacy = copy_levels(user_data.upgrades)

		user_data.upgrades_by_generation = {
			[1] = copy_levels(legacy),
			[2] = copy_levels(legacy),
			[3] = copy_levels(legacy)
		}
	end

	for generation = 1, 3 do
		user_data.upgrades_by_generation[generation] = copy_levels(user_data.upgrades_by_generation[generation])
	end

	user_data.upgrades = copy_levels(user_data.upgrades_by_generation[3])

	return user_data.upgrades_by_generation
end

function upgrades:get_user_levels(user_data, generation)
	return self:normalize_user_data(user_data)[generation]
end

function upgrades:set_user_levels(user_data, generation, levels)
	local all_levels = self:normalize_user_data(user_data)

	all_levels[generation] = copy_levels(levels)

	if generation == 3 then
		user_data.upgrades = copy_levels(levels)
	end

	return all_levels[generation]
end

function upgrades:copy_user_levels(user_data)
	local source = self:normalize_user_data(user_data)
	local result = {}

	for generation = 1, 3 do
		result[generation] = copy_levels(source[generation])
	end

	return result
end

function upgrades:restore_user_levels(user_data, state)
	for generation = 1, 3 do
		self:set_user_levels(user_data, generation, state[generation])
	end
end

function upgrades:is_item_for_generation(name, generation)
	local generations = self.item_generations[name]

	return generations and generations[generation] or false
end

function upgrades:get_localization_key(generation, name, suffix)
	return string.format("LEGACY_G%d_%s_%s", generation, name, suffix)
end

function upgrades:get_generation_icon(generation, item)
	if generation ~= 1 then
		return item.icon
	elseif item.class == "archers" then
		return 12 + item.level
	elseif item.class == "barracks" then
		return 7 + item.level
	elseif item.class == "mages" then
		return 17 + item.level
	elseif item.class == "rocks" then
		return 22 + item.level
	elseif item.class == "thunder" then
		return 2 + item.level
	elseif item.class == "reinforcements" then
		return ({28, 29, 30, 1, 2})[item.level]
	end

	return item.icon
end
upgrades.list_v = {
	archer_salvage_v = {
		range_factor = 1.1,
		class = "archers",
		price = 1,
		level = 1,
		icon = 1,--DP(13, 6)
	},
	archer_eagle_eye_v = {
		damage_factor = 1.1,
		class = "archers",
		price = 1,
		level = 2,
		icon = 2,--DP(14, 7)
	},
	archer_piercing_v = {
		class = "archers",
		reduce_armor_factor = 0.03,
		max_reduction = 0.25,
		price = 2,
		level = 3,
		icon = 3,--DP(15, 8)
	},
	archer_far_shots_v = {
		speed_factor = 1.1,
		class = "archers",
		price = 2,
		level = 4,
		icon = 4,--DP(16, 9)
	},
	archer_precision_v = {
		damage_factor = 2,
		bounce_range = 120,
		class = "archers",
		chance = 0.15,
		bullet = "dark_shard",
		price = 3,
		level = 5,
		icon = 5,--DP(17, 10)
	},
	barrack_survival_v = {
		rally_range_factor = 1.1,
		armor_increase = 0.15,
		class = "barracks",
		price = 1,
		level = 1,
		icon = 6,--DP(8, 1)
	},
	barrack_better_armor_v = {
		class = "barracks",
		health_factor = 1.3,
		price = 2,
		level = 4,
		icon = 7,--DP(9, 2)
	},
	barrack_improved_deployment_v = {
		pickpocket_chance = 0.1,
		pickpocket_amount = 2,
		class = "barracks",
		price = 2,
		level = 3,
		icon = 8,--DP(10, 3)
	},
	barrack_survival_2_v = {
		damage_factor = 1.1,
		class = "barracks",
		price = 1,
		level = 2,
		icon = 9,--DP(11, 4)
	},
	barrack_barbed_armor_v = {
		true_armor = 10,
		class = "barracks",
		price = 3,
		level = 5,
		icon = 10,--DP(12, 5)
	},
	mage_spell_reach_v = {
		damage_factor = 1.15,
		class = "mages",
		price = 1,
		level = 1,
		icon = 11,--DP(18, 11)
	},
	mage_arcane_shatter_v = {
		mod = "mod_v_shatter",
		chance = 0.1,
		class = "mages",
		price = 1,
		level = 2,
		icon = 12,--DP(19, 12)
	},
	mage_hermetic_study_v = {
		class = "mages",
		range_factor = 1.15,
		price = 2,
		level = 3,
		icon = 13,--DP(20, 13)
	},
	mage_empowered_magic_v = {
		damage_factor = 2,
		chance = 0.1,
		class = "mages",
		price = 2,
		level = 4,
		icon = 14,--DP(21, 14)
	},
	mage_slow_curse_v = {
		mod = "mod_slow_curse_v",
		class = "mages",
		price = 3,
		level = 5,
		icon = 15,--DP(22, 15)
	},
	engineer_concentrated_fire_v = {
		area_factor = 1.2,
		class = "rocks",
		price = 1,
		level = 1,
		icon = 16,--DP(23, 16)
	},
	engineer_range_finder_v = {
		damage_factor = 1.1,
		class = "rocks",
		price = 1,
		level = 2,
		icon = 17,--DP(24, 17)
	},
	engineer_field_logistics_v = {
		count = 3,
		damage_factor = 0.2,
		class = "rocks",
		price = 2,
		level = 3,
		icon = 18,--DP(25, 18)
	},
	engineer_industrialization_v = {
		class = "rocks",
		cost_factor = 0.85,
		price = 3,
		level = 4,
		icon = 19,--DP(26, 19)
	},
	engineer_efficiency_v = {
		price = 3,
		bonus = 0.05,
		max_bonus = 1.25,
		class = "rocks",
		level = 5,
		icon = 20,--DP(27, 20)
	},
}

function upgrades:set_levels(levels, generation)
	self.active_generation = generation or self.active_generation or 3
	self.levels_by_generation = nil

	for _, class in ipairs(self.display_order) do
		self.levels[class] = tonumber(levels and levels[class]) or 0
	end
end

function upgrades:set_levels_for_user(user_data, generation)
	generation = generation or 3
	self.runtime_user_data = user_data

	if generation >= 1 and generation <= 3 then
		self:set_levels(self:get_user_levels(user_data, generation), generation)
	else
		self:set_levels(blank_levels(), generation)
	end
end

function upgrades:set_all_generation_levels(user_data)
	-- Legacy generations store class levels, while generations 4 and 5 store
	-- individual technology keys. Keep both formats bound to the same slot so
	-- every level applies all five generations' technology trees.
	self.runtime_user_data = user_data
	generation_upgrades.normalize(user_data)
	self.active_generation = 0
	self.levels_by_generation = self:copy_user_levels(user_data)
	self.levels = copy_levels(self.levels_by_generation[3])
end

function upgrades:item_level_is_active(name, item)
	local generations = self.item_generations[name]

	if not generations then
		return true
	elseif self.active_generation == 0 then
		for generation in pairs(generations) do
			local levels = self.levels_by_generation and self.levels_by_generation[generation]

			if levels and item.level <= (levels[item.class] or 0) then
				return true
			end
		end

		return false
	end

	return generations[self.active_generation] and item.level <= (self.levels[item.class] or 0) or false
end

function upgrades:has_upgrade(name)
	local u = self.list[name]

	local max_level = self.max_level

	return u and self:item_level_is_active(name, u) and (not max_level or u.level <= max_level)
end

function upgrades:get_upgrade(name)
	local generation_upgrade = generation_upgrades.get(name)

	if generation_upgrade then
		local user_data = self.runtime_user_data or storage:load_slot()

		return generation_upgrades.has_key(user_data, name) and generation_upgrade or nil
	end

	local u = self.list[name]
	local max_level = self.max_level

	if not u or not self:item_level_is_active(name, u) or not max_level or u.level > max_level then
		return nil
	else
		return u
	end
end

function upgrades:get_upgrade_info(name)
	return self.list_v[name]
end

function upgrades:get_spent_stars(levels, generation)
	local total = 0

	for _, key in ipairs(self.generation_item_keys[generation] or {}) do
		local item = self.list[key]

		if item.level <= (levels[item.class] or 0) then
			total = total + item.price
		end
	end

	return total
end

function upgrades:get_total_stars(generation)
	local total = 0
	local generations = generation and {generation} or {1, 2, 3}

	for _, current_generation in ipairs(generations) do
		for _, key in ipairs(self.generation_item_keys[current_generation]) do
			total = total + self.list[key].price
		end
	end

	return total
end

G5_HP_RATE = 1.5
G5_ATK_RATE = 1.38
G5_CD_RATE = 0.72


function upgrades:enhance_hero5()
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
		"hero_dragon_sun",
	}
	for k, hero in ipairs(hero_list) do
		for i= 1,10 do
			T(hero).hero.level_stats.hp_max[i] = math.ceil(T(hero).hero.level_stats.hp_max[i] * G5_HP_RATE)
			T(hero).hero.level_stats.regen_health[i] = math.ceil(T(hero).hero.level_stats.regen_health[i] * G5_HP_RATE)
			if T(hero).hero.level_stats.melee_damage_max then
				if hero == "hero_wukong" or hero == "hero_douzhanshengfo" then
					for j = 1,4 do
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

local G4_TOWER_PREFIXES = {
	"tower_sniper", -- Dove43 native branch
	"tower_plague_hospital", -- Dove43 native branch
	"tower_command_center", -- Dove43 native branch
	"tower_ice_cooler", -- Dove43 native branch
	"tower_machine_gunner", -- Dove43 native branch
	"tower_blastin_bullriders", -- Dove43 native branch
	"tower_wifi_babies", -- Dove43 native branch
	"tower_wicked_sisters_stregi", -- Dove43 native branch
	"tower_shadow_archer_lvl",
	"tower_dark_knights_lvl",
	"tower_infernal_mage_lvl",
	"tower_rocket_riders_lvl",
	"tower_bone_flingers_lvl",
	"tower_melting_furnace_lvl",
	"tower_spirit_mausoleum_lvl",
	"tower_goblirang_lvl",
	"tower_orc_shaman_lvl",
	"tower_orc_warriors_den_lvl",
	"tower_grim_cemetery_lvl",
	"tower_balloon_lvl",
	"tower_rotten_forest_lvl",
	"tower_blazing_watcher_lvl",
	"tower_wicked_sisters_lvl",
	"tower_twilight_elves_barrack_lvl",
	"tower_deep_devils_lvl",
	"tower_shaolin_lvl",
	"tower_swamp_monster_lvl",
	"tower_ignis_altar_lvl",
	"tower_sandworm_lvl",
	"tower_ogre_shipwreck_lvl"
}

local G4_MAGE_PREFIXES = {
	"tower_ice_cooler", -- Dove43 native branch
	"tower_wifi_babies", -- Dove43 native branch
	"tower_wicked_sisters_stregi", -- Dove43 native branch
	"tower_deep_devils_lvl",
	"tower_infernal_mage_lvl",
	"tower_blazing_watcher_lvl",
	"tower_wicked_sisters_lvl",
	"tower_orc_shaman_lvl",
	"tower_spirit_mausoleum_lvl"
}

local G4_GXR_PREFIXES = {
	"tower_sniper", -- Dove43 native branch
	"tower_machine_gunner", -- Dove43 native branch
	"tower_shadow_archer_lvl",
	"tower_bone_flingers_lvl",
	"tower_goblirang_lvl",
	"tower_swamp_monster_lvl",
	"tower_shaolin_lvl",
	"tower_ogre_shipwreck_lvl"
}

local G4_BARRACK_PREFIXES = {
	"tower_orc_warriors_den_lvl",
	"tower_dark_knights_lvl",
	"tower_bone_flingers_lvl",
	"tower_grim_cemetery_lvl",
	"tower_spirit_mausoleum_lvl",
	"tower_twilight_elves_barrack_lvl",
	"tower_deep_devils_lvl",
	"tower_swamp_monster_lvl",
	"tower_ignis_altar_lvl",
	"tower_shaolin_lvl",
	"tower_ogre_shipwreck_lvl"
}

local G4_DAMAGE_KEYS = {
	zombie_damage_min = true,
	zombie_damage_max = true,
	mike_damage_min = true,
	mike_damage_max = true,
	damage = true,
	damage_inc = true,
	damage_inc_max = true,
	damage_inc_min = true,
	damage_max = true,
	damage_max_inc = true,
	damage_maxbase = true,
	damage_min = true,
	damage_min_inc = true,
	damage_minbase = true,
	damage_values = true,
	death_explosion_damage = true,
	explosion_damage = true
}

local g4_upgrade_baseline
local g4_upgrade_baseline_entities

local function g4_template_names(prefixes)
	local names = {}

	for _, prefix in ipairs(prefixes) do
		if E.entities[prefix] then table.insert(names, prefix) end
		for level = 1, 4 do
			local name = prefix .. level

			if E.entities[name] then
				table.insert(names, name)
			end
		end
	end

	return names
end

local function g4_collect_template_graph(roots, skip_ref)
	local queue = {}
	local names = {}
	local seen = {}

	local function enqueue(name, parent_key)
		if parent_key ~= "excluded_templates" and type(name) == "string" and E.entities[name] and not seen[name] and (not skip_ref or not skip_ref(name, parent_key)) then
			seen[name] = true
			table.insert(queue, name)
			table.insert(names, name)
		end
	end

	for _, name in ipairs(roots) do
		enqueue(name)
	end

	local index = 1

	while index <= #queue do
		local template = E.entities[queue[index]]
		local seen_tables = {}

		local function scan(value, parent_key)
			if type(value) ~= "table" or seen_tables[value] then
				return
			end

			seen_tables[value] = true

			for key, child in pairs(value) do
				if type(child) == "string" then
					enqueue(child, type(key) == "number" and parent_key or key)
				elseif type(child) == "table" then
					scan(child, key)
				end
			end
		end

		scan(template)
		index = index + 1
	end

	return names
end

local function g4_copy_numeric(value)
	if type(value) ~= "table" then
		return value
	end

	local result = {}

	for key, child in pairs(value) do
		result[key] = g4_copy_numeric(child)
	end

	return result
end

local function g4_map_numeric(value, fn)
	if type(value) == "number" then
		return fn(value)
	elseif type(value) ~= "table" then
		return value
	end

	local result = {}

	for key, child in pairs(value) do
		result[key] = g4_map_numeric(child, fn)
	end

	return result
end

local function g4_record_fields(template_names, accepted_keys, excluded_names)
	local entries = {}
	local recorded = {}

	for _, name in ipairs(template_names) do
		if not excluded_names or not excluded_names[name] then
			local seen_tables = {}

			local function scan(value)
				if type(value) ~= "table" or seen_tables[value] then
					return
				end

				seen_tables[value] = true

				for key, child in pairs(value) do
					if accepted_keys[key] and (type(child) == "number" or type(child) == "table") then
						recorded[value] = recorded[value] or {}

						if not recorded[value][key] then
							recorded[value][key] = true
							table.insert(entries, {holder = value, key = key, value = g4_copy_numeric(child)})
						end
					elseif type(child) == "table" then
						scan(child)
					end
				end
			end

			scan(E.entities[name])
		end
	end

	return entries
end

local function g4_floor_factors(value, factors)
	for _, factor in ipairs(factors) do
		value = math.floor(value * factor)
	end

	return value
end

local function g4_apply_entries(entries, active_factors)
	for _, entry in ipairs(entries) do
		entry.holder[entry.key] = g4_map_numeric(entry.value, function(value)
			return g4_floor_factors(value, active_factors)
		end)
	end
end

local function g4_record_direct(holder, key, entries)
	if holder and type(holder[key]) == "number" then
		table.insert(entries, {holder = holder, key = key, value = holder[key]})
	end
end

local function g4_build_upgrade_baseline()
	local all_towers = g4_template_names(G4_TOWER_PREFIXES)
	local all_names = g4_collect_template_graph(all_towers)
	local mage_towers = g4_template_names(G4_MAGE_PREFIXES)
	local mage_names = g4_collect_template_graph(mage_towers, function(name)
		local template = E.entities[name]

		if name:find("^soldier_wicked_sisters_lvl") then
			return false
		end

		return name == "fallen_ones_gargoyle" or name:find("^soldier_") or template and template.soldier
	end)
	local mage_name_set = {}
	local poison_names = {}

	for _, name in ipairs(mage_names) do
		mage_name_set[name] = true
	end

	for level = 1, 4 do
		poison_names["mod_wicked_sister_poison_lvl" .. level] = true
	end

	local damage_other_exclusions = {}

	for name in pairs(mage_name_set) do
		damage_other_exclusions[name] = true
	end

	-- The lava golem receives War Rations health, but Ignis Altar units are
	-- excluded from Master Architect in the KR4 technology table.
	damage_other_exclusions.soldier_lavagolem = true

	local nonmage_roots = {}

	for _, name in ipairs(all_towers) do
		if not mage_name_set[name] and not name:find("^tower_ignis_altar_lvl") then
			table.insert(nonmage_roots, name)
		end
	end

	for _, name in ipairs(g4_template_names(G4_BARRACK_PREFIXES)) do
		local template = E.entities[name]
		local soldier_type = template and template.barrack and template.barrack.soldier_type

		if soldier_type and not name:find("^tower_ignis_altar") then
			table.insert(nonmage_roots, soldier_type)
		end
	end

	-- Shipwreck upgrades create these units by name instead of referencing them in the tower template.
	for _, soldier_type in ipairs({
		"cook_ogre_lvl3",
		"deckhand_goblin_blue_lvl1",
		"deckhand_goblin_blue_lvl2",
		"deckhand_goblin_red_lvl1",
		"deckhand_goblin_red_lvl2"
	}) do
		table.insert(nonmage_roots, soldier_type)
	end

	local nonmage_names = g4_collect_template_graph(nonmage_roots)

	local baseline = {
		damage_mage = g4_record_fields(mage_names, G4_DAMAGE_KEYS, poison_names),
		damage_other = g4_record_fields(nonmage_names, G4_DAMAGE_KEYS, damage_other_exclusions),
		hp = g4_record_fields(all_names, {hp_max = true, zombie_hp = true, mike_hp = true}),
		prices = g4_record_fields(all_names, {price_base = true, price_inc = true}),
		ranges = {},
		radii = {}
	}
	local rotten_tree_power = E.entities.tower_rotten_forest_lvl4
		and E.entities.tower_rotten_forest_lvl4.powers
		and E.entities.tower_rotten_forest_lvl4.powers.tree

	g4_record_direct(rotten_tree_power, "hp", baseline.hp)
	local ice_fans = E.entities.tower_ice_cooler and E.entities.tower_ice_cooler.powers.fans
	if ice_fans then
		table.insert(baseline.hp, {holder = ice_fans, key = "hp", value = g4_copy_numeric(ice_fans.hp)})
	end

	for _, name in ipairs(g4_template_names(G4_GXR_PREFIXES)) do
		local attacks = E.entities[name].attacks

		if attacks then
			g4_record_direct(attacks, "range", baseline.ranges)
			for _, attack in pairs(attacks.list or {}) do
				g4_record_direct(attack, "range", baseline.ranges)
				g4_record_direct(attack, "max_range", baseline.ranges)
			end
		end
	end

	local artillery_roots = g4_template_names({
		"tower_rocket_riders_lvl",
		"tower_balloon_lvl",
		"tower_ogre_shipwreck_lvl"
	})
	table.append(artillery_roots, {"tower_plague_hospital", "tower_command_center", "tower_blastin_bullriders"})
	local artillery_names = g4_collect_template_graph(artillery_roots)

	baseline.radii = g4_record_fields(artillery_names, {damage_radius = true})

	return baseline
end

function upgrades:apply_g4_tower_upgrades(user_data)
	if g4_upgrade_baseline_entities ~= E.entities then
		g4_upgrade_baseline = g4_build_upgrade_baseline()
		g4_upgrade_baseline_entities = E.entities
	end

	local master_architect = generation_upgrades.has_key(user_data, "g4_towers_master_architect")
	local rune_power = generation_upgrades.has_key(user_data, "g4_towers_rune_power")
	local active_damage_factors = master_architect and {1.1} or {}

	g4_apply_entries(g4_upgrade_baseline.damage_other, active_damage_factors)
	g4_apply_entries(g4_upgrade_baseline.damage_mage, active_damage_factors)
	g4_apply_entries(g4_upgrade_baseline.hp, generation_upgrades.has_key(user_data, "g4_towers_war_rations") and {1.3} or {})
	g4_apply_entries(g4_upgrade_baseline.prices, generation_upgrades.has_key(user_data, "g4_towers_merchant_guild") and {0.85} or {})

	for _, entry in ipairs(g4_upgrade_baseline.ranges) do
		entry.holder[entry.key] = generation_upgrades.has_key(user_data, "g4_towers_gxr1") and entry.value * 1.05 or entry.value
	end

	for _, entry in ipairs(g4_upgrade_baseline.radii) do
		entry.holder[entry.key] = generation_upgrades.has_key(user_data, "g4_towers_large_bombs") and entry.value * 1.2 or entry.value
	end

	local poison_bases = {10, 25, 43, 70}
	local poison_factors = {}

	if rune_power then
		table.insert(poison_factors, 1.1)
	end
	if master_architect then
		table.insert(poison_factors, 1.1)
	end

	for level, base in ipairs(poison_bases) do
		local poison = E.entities["mod_wicked_sister_poison_lvl" .. level]
		local damage = g4_floor_factors(base, poison_factors)

		if poison and poison.dps then
			poison.dps.damage_min = damage
			poison.dps.damage_max = damage
		end
	end
end

function upgrades:patch_templates(max_level)
--限制最大科技等级
	if max_level then
		self.max_level = max_level
	end
--4代原始范围
	local user_data = self.runtime_user_data or storage:load_slot()
	local upgrades_FL = require("upgrades_FL")
	if user_data.liuhui and user_data.liuhui.g4range_balance ~= nil and user_data.liuhui.g4range_balance == false then
		upgrades_FL:range_g4()
	end
--平衡性调整
	
	--local upgrades_lockson = require("upgrades_lockson")
	if user_data.liuhui and user_data.liuhui.balance and user_data.liuhui.balance == true then
		upgrades_FL:enhance1()
		upgrades_FL:enhance2()
		upgrades_FL:enhance3()
		upgrades_FL:enhance4()
		upgrades_FL:enhance5()
		if E.entities["tower_catapult_lvl1"] then
			upgrades_FL:enhance6()
		end
		--upgrades_lockson:enhancecreeps()
	end
	if enemy_enhance.enabled(user_data.xingyu and user_data.xingyu.balance) then
		upgrades_FL:enhance11()
--		upgrades_FL:enhance12()
--		upgrades_FL:enhance13()
--		upgrades_FL:enhance4()
--		upgrades_FL:enhance5()
	end			
	self:apply_g4_tower_upgrades(user_data)
	upgrades_6.apply(user_data, generation_upgrades.has_key)
	hero_upgrades_6.apply(user_data)
	--5代英雄折算科技
	upgrades:enhance_hero5()

	local u
	--征服科技
	local archer_towers = {
		"tower_archer_1_v",
		"tower_archer_2_v",
		"tower_archer_3_v",
		"tower_deathcoil"
	}
		
	u = self:get_upgrade("archer_salvage")

	if u then
		u = self:get_upgrade_info("archer_salvage_v")
		for _, n in pairs(archer_towers) do
			T(n).attacks.range = T(n).attacks.range * u.range_factor
		end
	end

	u = self:get_upgrade("archer_eagle_eye")

	if u then
		u = self:get_upgrade_info("archer_eagle_eye_v")
		for _, n in pairs({
			"arrow_1_v",
			"arrow_2_v",
			"arrow_3_v",
			"bolt_sniper_deathcoil"
		}) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end
	end

	u = self:get_upgrade("archer_piercing")

	if u then
		u = self:get_upgrade_info("archer_piercing_v")
		for _, n in pairs({
			"arrow_1_v",
			"arrow_2_v",
			"arrow_3_v",
			"bolt_sniper_deathcoil"
		}) do
			T(n).bullet.reduce_armor = u.reduce_armor_factor
			T(n).bullet.armor_damage_inc = u.reduce_armor_factor
			T(n).bullet.armor_damage_max = u.max_reduction
		end
	end

	u = self:get_upgrade("archer_far_shots")

	if u then
		u = self:get_upgrade_info("archer_far_shots_v")
		for _, n in pairs(archer_towers) do
			T(n).attacks.list[1].cooldown = (math.floor((T(n).attacks.list[1].cooldown / u.speed_factor) * 10))/10
		end
		
		T("tower_deathcoil").attacks.list[1].charge_tick = (math.floor((T("tower_deathcoil").attacks.list[1].charge_tick / u.speed_factor) * 10))/10
	end

	local barrack_soldiers = {
		"soldier_thug",
		"soldier_bandit",
		"soldier_brigand",
		"soldier_redcap"
	}
	local barrack_towers = {
		"tower_barrack_1_v",
		"tower_barrack_2_v",
		"tower_barrack_3_v",
		"tower_redcap"
	}

	u = self:get_upgrade("barrack_survival")

	if u then
		u = self:get_upgrade_info("barrack_survival_v")
		for _, n in pairs(barrack_soldiers) do
			T(n).health.armor = T(n).health.armor + u.armor_increase
		end
		for _, n in pairs(barrack_towers) do
			T(n).barrack.rally_range = T(n).barrack.rally_range * u.rally_range_factor
		end
--		T("soldier_skeleton_graveyard").health.armor = T("soldier_skeleton_graveyard").health.armor + u.armor_increase
	end

	u = self:get_upgrade("barrack_better_armor")

	if u then
		u = self:get_upgrade_info("barrack_better_armor_v")
		for _, n in pairs(barrack_soldiers) do
			T(n).health.hp_max = km.round(T(n).health.hp_max * u.health_factor)
		end
--		T("soldier_skeleton_graveyard").health.hp_max = km.round(T("soldier_skeleton_graveyard").health.hp_max * u.health_factor)
	end

	u = self:get_upgrade("barrack_improved_deployment")

	if u then
		u = self:get_upgrade_info("barrack_improved_deployment_v")
		for _, n in pairs(barrack_soldiers) do
			T(n).pickpocket.chance = u.pickpocket_chance
			T(n).pickpocket.steal_max = u.pickpocket_amount
			T(n).pickpocket.steal_min = u.pickpocket_amount
		end
	end

	u = self:get_upgrade("barrack_survival_2")

	if u then
		u = self:get_upgrade_info("barrack_survival_2_v")
		for _, n in pairs(barrack_soldiers) do
			T(n).melee.attacks[1].damage_min = math.floor(T(n).melee.attacks[1].damage_min * u.damage_factor)
			T(n).melee.attacks[1].damage_max = math.floor(T(n).melee.attacks[1].damage_max * u.damage_factor)
			T(n).melee.attacks[1].track_damage = true
		end
--		T("soldier_skeleton_graveyard").melee.attacks[1].damage_min = math.floor(T("soldier_skeleton_graveyard").melee.attacks[1].damage_min * u.damage_factor)
--		T("soldier_skeleton_graveyard").melee.attacks[1].damage_max = math.floor(T("soldier_skeleton_graveyard").melee.attacks[1].damage_max * u.damage_factor)
--		T("soldier_skeleton_graveyard").melee.attacks[1].track_damage = true
	end

	u = self:get_upgrade("barrack_barbed_armor")

	if u then
		u = self:get_upgrade_info("barrack_barbed_armor_v")
		for _, n in pairs(barrack_soldiers) do
			T(n).health.true_armor = u.true_armor
		end
--		T("soldier_skeleton_graveyard").health.true_armor = u.true_armor
--		T("hero_goblin").health.true_armor = u.true_armor
	end

	local mage_towers = {
		"tower_mage_1_v",
		"tower_mage_2_v",
		"tower_mage_3_v",
		"tower_shaman"
	}

	u = self:get_upgrade("mage_spell_reach")

	if u then
		u = self:get_upgrade_info("mage_spell_reach_v")
		for _, n in pairs({
			"bolt_1_v",
			"bolt_2_v",
			"bolt_3_v",
			"bolt_shaman_totem"
		}) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end
	end

	u = self:get_upgrade("mage_hermetic_study")

	if u then
		u = self:get_upgrade_info("mage_hermetic_study_v")
		for _, n in pairs(mage_towers) do
			T(n).attacks.range = math.ceil(T(n).attacks.range * u.range_factor)
		end
	end

	local engineer_towers = {
		"tower_artillery_1",
		"tower_artillery_2",
		"tower_artillery_3"
	}
	local engineer_bombs = {
		"bomb_v",
		"bomb_dynamite_v",
		"bomb_black_v"
	}

	u = self:get_upgrade("engineer_concentrated_fire")

	if u then
		u = self:get_upgrade_info("engineer_concentrated_fire_v")
		for _, n in pairs(engineer_bombs) do
			T(n).bullet.damage_radius = math.ceil(T(n).bullet.damage_radius * u.area_factor)
		end
		T("decal_rotshroom_mine").damage_radius =  math.ceil(T("decal_rotshroom_mine").damage_radius * u.area_factor)
		T("decal_rotshroom_mine_mini").damage_radius =  math.ceil(T("decal_rotshroom_mine_mini").damage_radius * u.area_factor)
	end

	u = self:get_upgrade("engineer_range_finder")

	if u then
		u = self:get_upgrade_info("engineer_range_finder_v")
		for _, n in pairs(engineer_bombs) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end
		T("decal_rotshroom_mine").damage_min =  math.ceil(T("decal_rotshroom_mine").damage_min * u.damage_factor)
		T("decal_rotshroom_mine").damage_max =  math.ceil(T("decal_rotshroom_mine").damage_max * u.damage_factor)
	end

	u = self:get_upgrade("engineer_industrialization")

	if u then
		u = self:get_upgrade_info("engineer_industrialization_v")
		for _, n in pairs({
			"tower_rotshroom",
--			"tower_tesla"
		}) do
			for pk, pv in pairs(T(n).powers) do
				pv.price_base = math.floor(pv.price_base * u.cost_factor)
				pv.price_inc = math.floor(pv.price_inc * u.cost_factor)
			end
		end
	end	
--3代射手科技
	u = self:get_upgrade("archer_el_master_shooter")

	if u then
		for _, n in pairs({
			"tower_archer_1",
			"tower_archer_2",
			"tower_archer_3",
			"tower_arcane",
			"tower_silver",
			"tower_ground_archer",
			"tower_green_archer",			
			"tower_ewok_archer_re","tower_ewok_archer"		
		}) do
			T(n).tower.damage_factor = T(n).tower.damage_factor * u.damage_factor
		end
	end

	u = self:get_upgrade("archer_el_treesinged_bow")

	if u then
		for _, n in pairs({
			"tower_archer_1",
			"tower_archer_2",
			"tower_archer_3",
			"tower_arcane",
			"tower_silver",
			"tower_ground_archer",
			"tower_green_archer",			
			"tower_ewok_archer_re","tower_ewok_archer"					
		}) do
			T(n).attacks.range = math.ceil(T(n).attacks.range * u.range_factor)
		end
	end

	u = self:get_upgrade("archer_el_elven_training")

	if u then
		T("aura_arcane_burst").aura.damage_inc = T("aura_arcane_burst").aura.damage_inc * u.burst_damage_factor
		T("tower_arcane").attacks.list[2].cooldown_inc = -1
		T("mod_arrow_arcane_slumber").modifier.duration = T("mod_arrow_arcane_slumber").modifier.duration * u.slumber_duration_factor

		for _, chance_group in pairs(T("tower_silver").powers.sentence.chances) do
			for _, chance in pairs(chance_group) do
				chance = chance * u.sentence_chance_factor
			end
		end

		T("mod_arrow_silver_mark").received_damage_factor = T("mod_arrow_silver_mark").received_damage_factor * u.mark_damage_factor
		for _, n in pairs({
			"arrow_1",
			"arrow_2",
			"arrow_3",
			"arrow_arcane","arrow_arcane_burst","arrow_arcane_slumber",
			--"arrow_silver","arrow_silver_long","arrow_silver_mark","arrow_silver_mark_long",
			"arrow_ground_archer",
			"arrow_green_archer","arrow_green_burst","arrow_green_sentence",
			"spear_ewok",								
		}) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end
	end

	u = self:get_upgrade("archer_el_bloodletting_shoot")

	if u then
		for _, n in pairs({
			"arrow_1",
			"arrow_2",
			"arrow_3",
			"arrow_arcane","arrow_arcane_burst","arrow_arcane_slumber",
			"arrow_silver","arrow_silver_long","arrow_silver_mark","arrow_silver_mark_long",
			"arrow_ground_archer",
			"arrow_green_archer","arrow_green_burst","arrow_green_sentence",
			"spear_ewok",				
		}) do
			local b = T(n).bullet

			if type(b.mod) == "table" then
				table.insert(b.mod, "mod_blood_elves")
			elseif b.mod ~= nil then
				b.mod = {
					b.mod,
					"mod_blood_elves"
				}
			else
				b.mod = "mod_blood_elves"
			end
		end
	end
--2代射手科技
	u = self:get_upgrade("archer_improved_aim")

	if u then
		for _, n in pairs({
			"g2_tower_archer_1",
			"g2_tower_archer_2",
			"g2_tower_archer_3",
			"tower_totem",
			"tower_crossbow",
			"tower_archer_hammerhold","tower_archer_hammerhold_1",
			"tower_hammerhold_elite",
			"tower_archer_dwarf","tower_archer_dwarf_d",
			"tower_pirate_watchtower","tower_pirate_watchtower_d",			
		}) do
			T(n).attacks.range = math.ceil(T(n).attacks.range * u.range_factor)
		end
	end

	u = self:get_upgrade("archer_lumbermill")

	if u then
		for _, n in pairs({
			"g2_tower_archer_1",
			"g2_tower_archer_2",
			"g2_tower_archer_3",
			"tower_archer_hammerhold_1",
			"tower_hammerhold_elite"
		}) do
			T(n).tower.price = T(n).tower.price - u.cost_reduction
		end
	end

	u = self:get_upgrade("archer_focused_aim")

	if u then
		for _, n in pairs({
			"g2_arrow_1",
			"g2_arrow_2",
			"g2_arrow_3",
			"arrow_crossbow",
			"axe_totem",			
			"arrow_hammerhold_elite",
			"arrow_hammerhold","arrow_hammerhold_1",
			"dwarf_shotgun",
			"pirate_watchtower_shotgun",	
		}) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end
	end

	u = self:get_upgrade("archer_master_marksmanship")

	if u then
		for _, n in pairs({
			"g2_tower_archer_1",
			"g2_tower_archer_2",
			"g2_tower_archer_3",
			"tower_totem",
			"tower_crossbow",
			"tower_archer_dwarf","tower_archer_dwarf_d",
			"tower_pirate_watchtower","tower_pirate_watchtower_d",			
			"tower_archer_hammerhold","tower_archer_hammerhold_1",
			"tower_hammerhold_elite",
		}) do
			T(n).attacks.range = math.ceil(T(n).attacks.range * u.range_factor)
		end

		for _, n in pairs({
			"g2_arrow_1",
			"g2_arrow_2",
			"g2_arrow_3",
			"arrow_crossbow",
			"axe_totem",			
			"arrow_hammerhold_elite",
			"arrow_hammerhold","arrow_hammerhold_1",
			"dwarf_shotgun",
			"pirate_watchtower_shotgun",			
		}) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end
	end
--1代射手科技
	local archer_towers = {
		"g1_tower_archer_1",
		"g1_tower_archer_2",
		"g1_tower_archer_3",
		"tower_ranger",
		"tower_musketeer",
		"tower_archer_kr1_lvl1",
		"tower_archer_kr1_lvl2",
		"tower_archer_kr1_lvl3",
		"tower_ranger_kr1",
		"tower_musketeer_kr1"
	}

	u = self:get_upgrade("archer_salvage")

	if u then
		for _, n in pairs(archer_towers) do
			T(n).tower.refund_factor = u.refund_factor
		end
	end

	u = self:get_upgrade("archer_eagle_eye")

	if u then
		for _, n in pairs(archer_towers) do
			T(n).attacks.range = T(n).attacks.range * u.range_factor
		end

		T("aura_ranger_thorn").aura.radius = T("aura_ranger_thorn").aura.radius * u.range_factor
		T("kr6_kr1_aura_ranger_thorn").aura.radius = T("kr6_kr1_aura_ranger_thorn").aura.radius * u.range_factor
		T("tower_musketeer").attacks.list[2].range = T("tower_musketeer").attacks.list[2].range * u.range_factor
		T("tower_musketeer").attacks.list[3].range = T("tower_musketeer").attacks.list[3].range * u.range_factor
		T("tower_musketeer").attacks.list[4].range = T("tower_musketeer").attacks.list[4].range * u.range_factor
		for i = 2, 4 do
			local attack = T("tower_musketeer_kr1").attacks.list[i]
			attack.range = attack.range * u.range_factor
		end
	end

	u = self:get_upgrade("archer_piercing")

	if u then
		for _, n in pairs({
			"g1_arrow_1",
			"g1_arrow_2",
			"g1_arrow_3",
			"kr6_kr1_arrow_1",
			"kr6_kr1_arrow_2",
			"kr6_kr1_arrow_3",
			"kr6_kr1_arrow_ranger",
			"arrow_ranger",
			"kr6_kr1_shotgun_musketeer",
			"kr6_kr1_shotgun_musketeer_sniper",
			"shotgun_musketeer",
			"shotgun_musketeer_sniper",
		}) do
			T(n).bullet.reduce_armor = u.reduce_armor_factor
		end
	end

	u = self:get_upgrade("archer_far_shots")

	if u then
		for _, n in pairs(archer_towers) do
			T(n).attacks.range = T(n).attacks.range * u.range_factor
		end

		T("aura_ranger_thorn").aura.radius = T("aura_ranger_thorn").aura.radius * u.range_factor
		T("kr6_kr1_aura_ranger_thorn").aura.radius = T("kr6_kr1_aura_ranger_thorn").aura.radius * u.range_factor
		T("tower_musketeer").attacks.list[2].range = T("tower_musketeer").attacks.list[2].range * u.range_factor
		T("tower_musketeer").attacks.list[3].range = T("tower_musketeer").attacks.list[3].range * u.range_factor
		T("tower_musketeer").attacks.list[4].range = T("tower_musketeer").attacks.list[4].range * u.range_factor
		for i = 2, 4 do
			local attack = T("tower_musketeer_kr1").attacks.list[i]
			attack.range = attack.range * u.range_factor
		end
	end
--3代兵营科技

	u = self:get_upgrade("barrack_el_elven_fencing")

	if u then
		for _, n in pairs({
			"tower_barrack_1",
			"tower_barrack_2",
			"tower_barrack_3"
		}) do
			T(n).tower.price = math.ceil(T(n).tower.price * u.cost_factor)
		end
	end

	u = self:get_upgrade("barrack_el_expert_tactician")

	if u then
		for _, n in pairs({
			"tower_barrack_1",
			"tower_barrack_2",
			"tower_barrack_3",
			"tower_blade",
			"tower_forest",
			"tower_drow","tower_drow_d",
			"tower_baby_ashbite","tower_baby_ashbite_d",							
			"tower_ewok","tower_ewok_d",
			"tower_ewok_rework","tower_ewok_archer_re",	
			"tower_elf_1","tower_elf_kr1",					
		}) do
			T(n).barrack.rally_range = math.ceil(T(n).barrack.rally_range * u.rally_range_factor)
		end
	end

	u = self:get_upgrade("barrack_el_enchanted_armor")

	if u then
		for _, n in pairs({
			"soldier_barrack_1",
			"soldier_barrack_2",
			"soldier_barrack_3",
			"soldier_blade",
			"soldier_forest",						
			"soldier_drow",
			"soldier_baby_ashbite",			
			"soldier_ewok",
			"soldier_ewok_re","soldier_ewok_re_1",			
		}) do
			T(n).health.armor = T(n).health.armor + u.armor_increase
		end
	end

	u = self:get_upgrade("barrack_el_moon_forged_blades")

	if u then
		T("soldier_barrack_1").melee.attacks[1].mod = "mod_moon_forged_blades_barrack_1"
		T("soldier_barrack_2").melee.attacks[1].mod = "mod_moon_forged_blades_barrack_2"
		T("soldier_barrack_3").melee.attacks[1].mod = "mod_moon_forged_blades_barrack_3"
		T("soldier_blade").melee.attacks[1].mod = "mod_moon_forged_blades_blade"
		T("soldier_blade").melee.attacks[2].mod = "mod_moon_forged_blades_blade"
		T("soldier_blade").melee.attacks[3].mod = "mod_moon_forged_blades_blade"
		T("soldier_forest").melee.attacks[1].mod = "mod_moon_forged_blades_forest"
		T("soldier_drow").melee.attacks[1].mod = "mod_moon_forged_blades_drow"
		T("soldier_ewok").melee.attacks[1].mod = "mod_moon_forged_blades_drow"
		T("soldier_ewok_re").melee.attacks[1].mod = "mod_moon_forged_blades_drow"
		T("soldier_ewok_re_1").melee.attacks[1].mod = "mod_moon_forged_blades_drow"				
		T("soldier_elf_kr1").melee.attacks[1].mod = "mod_moon_forged_blades_blade"
		T("soldier_elf_1").melee.attacks[1].mod = "mod_moon_forged_blades_blade"
	end

	u = self:get_upgrade("barrack_el_cheat_death")

	if u then
		for _, n in pairs({
			"soldier_barrack_1",
			"soldier_barrack_2",
			"soldier_barrack_3",
			"soldier_blade",
			"soldier_forest",						
			"soldier_drow",
			"soldier_baby_ashbite",			
			"soldier_ewok",
			"soldier_ewok_re","soldier_ewok_re_1",			
			"soldier_elf_1","soldier_elf_kr1",
			"soldier_druid_bear",					
		}) do
			T(n).revive.disabled = nil
		end
	end
	
--2代兵营科技
	u = self:get_upgrade("barrack_defensive_techniques")

	if u then
		for _, n in pairs({
			"soldier_militia",
			"soldier_footmen",
			"soldier_knight",
			"soldier_templar",
			"soldier_assassin",
			"soldier_pirate_captain","soldier_pirate_flamer","soldier_pirate_anchor",
			"soldier_pirate_captain_2","soldier_pirate_flamer_2","soldier_pirate_anchor_2",
			"soldier_amazona",
			"soldier_amazona_re",			
			"soldier_legionnaire","soldier_djinn",
			"soldier_legionnaire_2","soldier_djinn_2",
			"soldier_dwarf","soldier_dwarf_shooter",
			"soldier_cannibal"
		}) do
			T(n).health.armor = T(n).health.armor + u.armor_increase
		end
	end

	u = self:get_upgrade("barrack_boot_camp")

	if u then
		for _, n in pairs({
			"soldier_militia",
			"soldier_footmen",
			"soldier_knight",
			"soldier_templar",
			"soldier_assassin",
			"soldier_pirate_captain","soldier_pirate_flamer","soldier_pirate_anchor",
			"soldier_pirate_captain_2","soldier_pirate_flamer_2","soldier_pirate_anchor_2",
			"soldier_amazona",
			"soldier_amazona_re",			
			"soldier_legionnaire","soldier_djinn",
			"soldier_legionnaire_2","soldier_djinn_2",
			"soldier_dwarf","soldier_dwarf_shooter",	
			"soldier_cannibal"		
		}) do
			T(n).health.hp_max = math.ceil(T(n).health.hp_max * u.health_factor)
		end
	end

	u = self:get_upgrade("barrack_esprit_des_corps")

	if u then
		for _, n in pairs({
			"soldier_militia",
			"soldier_footmen",
			"soldier_knight",
			"soldier_templar",
			"soldier_assassin",
			"soldier_pirate_captain","soldier_pirate_flamer","soldier_pirate_anchor",
			"soldier_pirate_captain_2","soldier_pirate_flamer_2","soldier_pirate_anchor_2",
			"soldier_amazona",
			"soldier_amazona_re",			
			"soldier_legionnaire","soldier_djinn",
			"soldier_legionnaire_2","soldier_djinn_2",
			"soldier_dwarf","soldier_dwarf_shooter",
			"soldier_cannibal"	
		}) do
			T(n).regen.health = math.ceil(T(n).regen.health * u.regen_factor)
		end

		for _, n in pairs({
			"g2_tower_barrack_1",
			"g2_tower_barrack_2",
			"g2_tower_barrack_3",
			"tower_templar",
			"tower_assassin",
			"tower_barrack_dwarf","tower_barrack_dwarf_d","tower_barrack_dwarfshooter",		
			"tower_barrack_pirates","tower_barrack_pirates_d",			
			"tower_barrack_pirate_captain","tower_barrack_pirate_captain_2",  "tower_barrack_pirate_flamer_2",  "tower_barrack_pirate_anchor_2", 
			"tower_barrack_amazonas","tower_barrack_amazonas_d",
			"tower_barrack_amazonas_re",						
			"tower_barrack_mercenaries","tower_barrack_mercenaries_d",
			"tower_barrack_mercenaries_2","tower_barrack_legion_2","tower_barrack_djinn_2",
			"tower_barrack_canibal"
		}) do
			T(n).barrack.rally_range = math.ceil(T(n).barrack.rally_range * u.rally_range_factor)
		end
	end

	u = self:get_upgrade("barrack_veteran_squad")

	if u then
		for _, n in pairs({
			"soldier_militia",
			"soldier_footmen",
			"soldier_knight",
			"soldier_templar",
			"soldier_assassin",
			"soldier_pirate_captain","soldier_pirate_flamer","soldier_pirate_anchor",
			"soldier_pirate_captain_2","soldier_pirate_flamer_2","soldier_pirate_anchor_2",
			"soldier_amazona",
			"soldier_amazona_re",			
			"soldier_legionnaire","soldier_djinn",
			"soldier_legionnaire_2","soldier_djinn_2",
			"soldier_dwarf","soldier_dwarf_shooter",
			"soldier_cannibal"
		}) do
			T(n).health.armor = T(n).health.armor + u.armor_increase
			T(n).health.dead_lifetime = T(n).health.dead_lifetime - u.respawn_reduction
		end

	end
--1代兵营科技
	local barrack_soldiers = {
		"g1_soldier_militia",
		"g1_soldier_footmen",
		"g1_soldier_knight",
		"soldier_militia_kr1",
		"soldier_footmen_kr1",
		"soldier_knight_kr1",
		"soldier_paladin",
		"soldier_barbarian",
		"kr6_kr1_soldier_paladin",
		"kr6_kr1_soldier_barbarian",
		"soldier_steam_troop",		
		"soldier_elf",
		"soldier_elf_kr1","soldier_elf_1",		
		"soldier_sasquash",
		"soldier_sasquash_2",
		"soldier_s6_imperial_guard",
		"soldier_imperial_guard","soldier_s6_imperial_guard_2",		
		"soldier_paladin_rider",
		"soldier_hammerhold_guard"
	}
	local barrack_towers = {
		"g1_tower_barrack_1",
		"g1_tower_barrack_2",
		"g1_tower_barrack_3",
		"tower_barrack_kr1_lvl1",
		"tower_barrack_kr1_lvl2",
		"tower_barrack_kr1_lvl3",
		"tower_paladin_kr1",
		"tower_barbarian_kr1",
		"tower_paladin",
		"tower_barbarian",
		"tower_steam_troop",		
		"tower_elf","tower_elf_d",
		"tower_elf_kr1","tower_elf_1",		
		"tower_sasquash","tower_sasquash_d",
		"tower_sasquash_rework",		
	    "tower_imperial_patrol",
		"tower_imperial_patrol_2","tower_imperialguard",		
		"tower_paladin_rider",
		"tower_hammerhold_guard"
	}

	u = self:get_upgrade("barrack_survival")

	if u then
		for _, n in pairs(barrack_soldiers) do
			T(n).health.hp_max = km.round(T(n).health.hp_max * u.health_factor)
		end
	end

	u = self:get_upgrade("barrack_better_armor")

	if u then
		for _, n in pairs(barrack_soldiers) do
			T(n).health.armor = T(n).health.armor + u.armor_increase
		end
	end

	u = self:get_upgrade("barrack_improved_deployment")

	if u then
		for _, n in pairs(barrack_soldiers) do
			T(n).health.dead_lifetime = math.floor(T(n).health.dead_lifetime * u.cooldown_factor)
		end

		for _, n in pairs(barrack_towers) do
			T(n).barrack.rally_range = T(n).barrack.rally_range * u.rally_range_factor
		end
	end

	u = self:get_upgrade("barrack_survival_2")

	if u then
		for _, n in pairs(barrack_soldiers) do
			T(n).health.hp_max = km.round(T(n).health.hp_max * u.health_factor)
		end
	end

	u = self:get_upgrade("barrack_barbed_armor")

	if u then
		for _, n in pairs(barrack_soldiers) do
			T(n).health.spiked_armor = u.spiked_armor_factor
		end
		for _, n in pairs({
			"soldier_elemental",
			"kr6_kr1_soldier_elemental",
			"soldier_ancient_guardian",			
			"soldier_magnus_illusion",
			"soldier_ingvar_ancestor",
			"soldier_alleria_wildcat",
			"hero_alleria",
			"hero_alleria_2",
			"hero_alleria_g3",
			"hero_gerald",
			"hero_gerald_2",
			"hero_bolin",
			"hero_bolin_2",
			"hero_magnus",
			"hero_magnus_2",
			"hero_ignus",
			"hero_ignus_2",
			"hero_malik",
			"hero_malik_2",
			"hero_denas",
			"hero_denas_2",
			"hero_ingvar",
			"hero_ingvar_2",
			"hero_elora",
			"hero_elora_2",
			"hero_oni",
			"hero_oni_2",
			"hero_hacksaw",
			"hero_hacksaw_2",
			"hero_thor",
			"hero_thor_2",
			"hero_10yr",
			"hero_10yr_2",
			"hero_voltaire",
			"hero_voltaire_2",
			"hero_viper",
			"hero_viper_2",
			"g1_soldier_militia",
			"g1_soldier_footmen",
			"g1_soldier_knight",
			"soldier_paladin",
			"soldier_barbarian",
			"kr6_kr1_soldier_paladin",
			"kr6_kr1_soldier_barbarian",
			"soldier_steam_troop",		
			"soldier_elf",
			"soldier_elf_1","soldier_elf_kr1",		
			"soldier_sasquash",
			"soldier_sasquash_2",
			"soldier_s6_imperial_guard",
			"soldier_imperial_guard","soldier_s6_imperial_guard_2",		
			"soldier_paladin_rider"
		}) do
			T(n).health.spiked_armor = u.spiked_armor_factor
		end
		
	end

--3代法师科技
	u = self:get_upgrade("mage_el_crystal_focus")

	if u then
		for _, n in pairs({
			"tower_mage_1",
			"tower_mage_2",
			"tower_mage_3",
			"tower_wild_magus",
			"tower_high_elven",
			"tower_faerie_dragon","tower_faerie_dragon_d","tower_faerie_dragon_re",
			"tower_pixie","tower_pixie_d","tower_pixie_re",
		}) do
			T(n).attacks.range = math.ceil(T(n).attacks.range * u.range_factor)
		end
	end

	u = self:get_upgrade("mage_el_bane_spell")

	if u then
		for _, n in pairs({
			"bolt_elves_1",
			"bolt_elves_2",
			"bolt_elves_3",
			"bolt_wild_magus",
			"bolt_high_elven_strong",--"bolt_high_elven_weak","ray_high_elven_sentinel",
			"bolt_faerie_dragon",
			"fireball_baby_ashbite",
		}) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end
	end

	u = self:get_upgrade("mage_el_crystal_gazing")

	if u then
		for _, n in pairs({
			"tower_mage_1",
			"tower_mage_2",
			"tower_mage_3",
			"tower_wild_magus",
			"tower_high_elven",
			"tower_pixie","tower_pixie_d","tower_pixie_re",
			"tower_faerie_dragon","tower_faerie_dragon_d","tower_faerie_dragon_re",
		}) do
			T(n).attacks.range = math.ceil(T(n).attacks.range * u.range_factor)
		end
	end
--2代法师科技
	u = self:get_upgrade("mage_rune_of_power")

	if u then
		for _, n in pairs({
			"g2_tower_mage_1",
			"g2_tower_mage_2",
			"g2_tower_mage_3",
			"tower_archmage",
			"tower_necromancer"
		}) do
			T(n).attacks.range = math.ceil(T(n).attacks.range * u.range_factor)
		end
	end

	u = self:get_upgrade("mage_eldrich_power")

	if u then
		for _, n in pairs({
			"bolt_1",
			"bolt_2",
			"bolt_3",
			"bolt_archmage",
			"bolt_necromancer"
		}) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end
		T("ray_neptune").bullet.damage_min_levels[1] = math.ceil(T("ray_neptune").bullet.damage_min_levels[1]*u.damage_factor)
		T("ray_neptune").bullet.damage_min_levels[2] = math.ceil(T("ray_neptune").bullet.damage_min_levels[2]*u.damage_factor)
		T("ray_neptune").bullet.damage_min_levels[3] = math.ceil(T("ray_neptune").bullet.damage_min_levels[3]*u.damage_factor)
		T("ray_neptune").bullet.damage_max_levels[1] = math.ceil(T("ray_neptune").bullet.damage_max_levels[1]*u.damage_factor)
		T("ray_neptune").bullet.damage_max_levels[2] = math.ceil(T("ray_neptune").bullet.damage_max_levels[2]*u.damage_factor)
		T("ray_neptune").bullet.damage_max_levels[3] = math.ceil(T("ray_neptune").bullet.damage_max_levels[3]*u.damage_factor)
	end

	u = self:get_upgrade("mage_wizard_academy")

	if u then
		for _, p in pairs({
			T("tower_archmage").powers.twister,
			T("tower_archmage").powers.blast,
			T("tower_necromancer").powers.pestilence,
			T("tower_necromancer").powers.rider,
			T("tower_neptune").powers.ray,
			T("tower_neptune_d").powers.ray,
		}) do
			p.price_base = math.floor(p.price_base * u.cost_factor)
			p.price_inc = math.floor(p.price_inc * u.cost_factor)
		end
	end

--1代法师科技
	local mage_towers = {
		"g1_tower_mage_1",
		"g1_tower_mage_2",
		"g1_tower_mage_3",
		"tower_arcane_wizard",
		"tower_sorcerer",
		"tower_time_wizard",
		"tower_mage_kr1_lvl1",
		"tower_mage_kr1_lvl2",
		"tower_mage_kr1_lvl3",
		"tower_arcane_wizard_kr1",
		"tower_sorcerer_kr1"
	}

	u = self:get_upgrade("mage_spell_reach")

	if u then
		for _, n in pairs(mage_towers) do
			T(n).attacks.range = T(n).attacks.range * u.range_factor
		end
	end

	u = self:get_upgrade("mage_arcane_shatter")

	if u then
		for _, n in pairs({
			"g1_bolt_1",
			"g1_bolt_2",
			"g1_bolt_3",
			"kr6_kr1_bolt_1",
			"kr6_kr1_bolt_2",
			"kr6_kr1_bolt_3",
			"bolt_sorcerer_kr1",
			"bolt_sorcerer",
			"ray_arcane",
			"kr6_kr1_ray_arcane",
			"bolt_time_wizard",			
			"bolt_elora_freeze","bolt_elora_slow",
			"bolt_magnus","bolt_magnus_illusion",
			"ray_sunray"
		}) do
			local mods = {
				n == "kr6_kr1_ray_arcane" and "kr6_kr1_mod_arcane_shatter" or u.mod
			}
			local b = T(n).bullet

			if b.mod then
				table.insert(mods, b.mod)
			end

			if b.mods then
				table.append(mods, b.mods)
			end

			b.mod = nil
			b.mods = mods
		end
	end

	u = self:get_upgrade("mage_hermetic_study")

	if u then
		for _, n in pairs(mage_towers) do
			T(n).tower.price = math.ceil(T(n).tower.price * u.cost_factor)
		end
		T("tower_sunray").tower.price = math.ceil(T("tower_sunray").tower.price*u.cost_factor)
		T("tower_sunray_d").tower.price = math.ceil(T("tower_sunray_d").tower.price*u.cost_factor)
	end

	u = self:get_upgrade("mage_empowered_magic")

	if u then
		for _, n in pairs({
			"g1_bolt_1",
			"g1_bolt_2",
			"g1_bolt_3",
			"kr6_kr1_bolt_1",
			"kr6_kr1_bolt_2",
			"kr6_kr1_bolt_3",
			"bolt_sorcerer_kr1",
			"bolt_sorcerer",
			"bolt_time_wizard",
			"ray_sunray"
		}) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end

		T("mod_ray_arcane").dps.damage_min = math.ceil(T("mod_ray_arcane").dps.damage_min * u.damage_factor)
		T("mod_ray_arcane").dps.damage_max = math.ceil(T("mod_ray_arcane").dps.damage_max * u.damage_factor)
		T("kr6_kr1_mod_ray_arcane").dps.damage_min = math.ceil(T("kr6_kr1_mod_ray_arcane").dps.damage_min * u.damage_factor)
		T("kr6_kr1_mod_ray_arcane").dps.damage_max = math.ceil(T("kr6_kr1_mod_ray_arcane").dps.damage_max * u.damage_factor)
	end

	u = self:get_upgrade("mage_slow_curse")

	if u then
		for _, n in pairs({
			"g1_bolt_1",
			"g1_bolt_2",
			"g1_bolt_3",
			"kr6_kr1_bolt_1",
			"kr6_kr1_bolt_2",
			"kr6_kr1_bolt_3",
			"bolt_sorcerer_kr1",
			"bolt_sorcerer",
			"ray_arcane",
			"kr6_kr1_ray_arcane",
			"bolt_time_wizard",
			"bolt_elora_freeze","bolt_elora_slow",
			"bolt_magnus","bolt_magnus_illusion",			
			"ray_sunray"
		}) do
			local mods = {
				n == "kr6_kr1_ray_arcane" and "kr6_kr1_mod_slow_curse" or u.mod
			}
			local b = T(n).bullet

			if b.mod then
				table.insert(mods, b.mod)
			end

			if b.mods then
				table.append(mods, b.mods)
			end

			b.mod = nil
			b.mods = mods
		end
	end
--3代巨炮科技
	

	u = self:get_upgrade("stone_el_druid_sharp_splinters")

	if u then
		for _, n in pairs({
			"rock_1",
			"rock_2",
			"rock_3",
			"rock_druid",
			"rock_entwood","rock_firey_nut"			
		}) do
			T(n).bullet.damage_radius = math.ceil(T(n).bullet.damage_radius * u.damage_area_factor)
		end
		T("aura_razor_edge").aura.radius = math.floor(T("aura_razor_edge").aura.radius*u.damage_area_factor)
		T("aura_black_baby_dragon").aura.radius = math.floor(T("aura_black_baby_dragon").aura.radius*u.damage_area_factor)
		T("aura_black_baby_dragon_d").aura.radius = math.floor(T("aura_black_baby_dragon_d").aura.radius*u.damage_area_factor)
	end

	u = self:get_upgrade("stone_el_druid_earth_mastery")

	if u then
		for _, n in pairs({
			"tower_rock_thrower_1",
			"tower_rock_thrower_2",
			"tower_rock_thrower_3",
			"tower_druid",
			"tower_entwood",
			"tower_bastion","tower_bastion_d"
		}) do
			T(n).attacks.range = math.ceil(T(n).attacks.range * u.range_factor)
		end
	end

	u = self:get_upgrade("stone_el_druid_heavy_load")

	if u then
		for _, n in pairs({
			"rock_1",
			"rock_2",
			"rock_3",
			"rock_druid",
			"rock_entwood","rock_firey_nut"
		}) do
			T(n).bullet.damage_type = bit.bor(DAMAGE_TRUE, DAMAGE_FX_EXPLODE)
		end
	end

	u = self:get_upgrade("stone_el_druid_shocking_impact")

	if u then
		for _, n in pairs({
			"rock_1",
			"rock_2",
			"rock_3",
			"rock_druid",
			"rock_entwood","rock_firey_nut"
		}) do
			T(n).bullet.mod = "mod_shocking_impact"
		end
		T("aura_razor_edge").aura.mod = "mod_shocking_impact"
		T("aura_black_baby_dragon").aura.mods = {"mod_black_baby_dragon","mod_shocking_impact"}
		T("aura_black_baby_dragon_d").aura.mods = {"mod_black_baby_dragon","mod_shocking_impact",}		
	end

	u = self:get_upgrade("stone_el_druid_hardened_boulders")

	if u then
		for _, n in pairs({
			"rock_1",
			"rock_2",
			"rock_3",
			"rock_druid",
			"rock_entwood",
		}) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end
		T("aura_razor_edge").aura.duration = 2
		T("mod_black_baby_dragon").insert_damage = math.floor(T("mod_black_baby_dragon").insert_damage * u.damage_factor)		
	end
--2代巨炮科技
	u = self:get_upgrade("engineer_smoothbore")

	if u then
		for _, n in pairs({
			"g2_tower_engineer_1",
			"g2_tower_engineer_2",
			"g2_tower_engineer_3",
			"tower_dwaarp",
			"tower_sandworm",
			"tower_frankenstein","tower_frankenstein_d"
		}) do
			T(n).attacks.range = math.ceil(T(n).attacks.range * u.range_factor)
		end

		T("soldier_mecha").attacks.list[1].max_range = T("soldier_mecha").attacks.list[1].max_range * u.range_factor
		T("soldier_mecha").attacks.list[2].max_range = T("soldier_mecha").attacks.list[2].max_range * u.range_factor
	end

	u = self:get_upgrade("engineer_alchemical_powder")

	if u then
		for _, n in pairs({
			"g2_bomb",
			"g2_bomb_dynamite",
			"g2_bomb_black",
			"bomb_mecha",
			"bomb_pirate_camp"
		}) do
			T(n).up_alchemical_powder_chance = u.chance
		end
		T("ray_frankenstein").bounce_damage_factor = 1
		T("ray_frankenstein").bounce_damage_factor_min = 1
	end

	u = self:get_upgrade("engineer_improved_ordnance")

	if u then
		for _, n in pairs({
			"g2_bomb",
			"g2_bomb_dynamite",
			"g2_bomb_black",
			"bomb_mecha",
			"bomb_pirate_camp"
		}) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end

		T("tower_dwaarp").attacks.list[1].damage_min = T("tower_dwaarp").attacks.list[1].damage_min * u.damage_factor
		T("tower_dwaarp").attacks.list[1].damage_max = T("tower_dwaarp").attacks.list[1].damage_max * u.damage_factor
		T("mod_teeth").dps.damage_min = T("mod_teeth").dps.damage_min * u.damage_factor
		T("mod_teeth").dps.damage_max = T("mod_teeth").dps.damage_max * u.damage_factor
		T("mod_ray_frankenstein").dps.damage_min = math.ceil(T("mod_ray_frankenstein").dps.damage_min * u.damage_factor)
		T("mod_ray_frankenstein").dps.damage_max = math.ceil(T("mod_ray_frankenstein").dps.damage_max * u.damage_factor)		
	end

	u = self:get_upgrade("engineer_gnomish_tinkering")

	if u then
		for _, a in pairs({
			T("tower_dwaarp").attacks.list[2],
			T("tower_dwaarp").attacks.list[3],
			T("soldier_mecha").attacks.list[2],
			T("soldier_mecha").attacks.list[3],
			T("tower_sandworm").attacks.list[1],
			T("tower_sandworm").attacks.list[2],
			T("tower_frankenstein").attacks.list[1],
			T("tower_frankenstein_d").attacks.list[1],		
			T("soldier_frankenstein").melee.attacks[2]
		}) do
			a.cooldown = a.cooldown * u.cooldown_factor
		end
		T("soldier_tremor").health.dead_lifetime = T("soldier_tremor").health.dead_lifetime * u.cooldown_factor
		T("soldier_frankenstein").health.dead_lifetime = T("soldier_frankenstein").health.dead_lifetime * u.cooldown_factor
	end

	u = self:get_upgrade("engineer_shock_and_awe")

	if u then
		for _, n in pairs({
			"g2_bomb",
			"g2_bomb_dynamite",
			"g2_bomb_black",
			"bomb_mecha","missile_mecha",
			"bomb_teeth",		
			"pirate_watchtower_bomb",
			"dwarf_barrel", "shotgun_dwarf_barrel",
			"bomb_pirate_camp",			
		}) do
			T(n).up_shock_and_awe_chance = u.chance
		end
		T("soldier_frankenstein").melee.attacks[2].mod = "mod_frankenstein_pound"
		T("soldier_frankenstein").melee.attacks[2].damage_type = DAMAGE_ELECTRICAL
	end
--1代巨炮科技
	local engineer_towers = {
		"g1_tower_engineer_1",
		"g1_tower_engineer_2",
		"g1_tower_engineer_3",
		"tower_engineer_kr1_lvl1",
		"tower_engineer_kr1_lvl2",
		"tower_engineer_kr1_lvl3",
		"tower_bfg_kr1",
		"tower_tesla_kr1",
		"tower_bfg",
		"tower_tesla",
		"tower_sandmystic"
	}
	local engineer_bombs = {
		"g1_bomb",
		"g1_bomb_dynamite",
		"g1_bomb_black",
		"bomb_KR1",
		"bomb_dynamite_KR1",
		"bomb_black_KR1",
		"airstrike_steam_troop",
		"bomb_steam_troop"
	}

	u = self:get_upgrade("engineer_efficiency")
	if u then
		T("missile_bfg").bullet.damage_min = T("missile_bfg").bullet.damage_max
		T("kr6_kr1_missile_bfg").bullet.damage_min = T("kr6_kr1_missile_bfg").bullet.damage_max
		T("ray_tesla").bounce_damage_factor = 1
		T("ray_tesla").bounce_damage_factor_min = 1
		T("kr6_kr1_ray_tesla").bounce_damage_factor = 1
		T("kr6_kr1_ray_tesla").bounce_damage_factor_min = 1
		T("b_tesla").bounce_damage_factor = 1
		T("b_tesla").bounce_damage_factor_min = 1
		T("airstrike_steam_troop").bullet.damage_min = T("airstrike_steam_troop").bullet.damage_max		
		T("bomb_mine_bolin").bullet.damage_min = T("bomb_mine_bolin").bullet.damage_max		
	end

	u = self:get_upgrade("engineer_concentrated_fire")

	if u then
		for _, n in pairs(engineer_bombs) do
			T(n).bullet.damage_min = math.ceil(T(n).bullet.damage_min * u.damage_factor)
			T(n).bullet.damage_max = math.ceil(T(n).bullet.damage_max * u.damage_factor)
		end
		T("bomb_bfg").bullet.damage_min = math.floor(T("bomb_bfg").bullet.damage_min * u.damage_factor)
		T("bomb_bfg").bullet.damage_max = math.floor(T("bomb_bfg").bullet.damage_max * u.damage_factor)
		T("kr6_kr1_bomb_bfg").bullet.damage_min = math.floor(T("kr6_kr1_bomb_bfg").bullet.damage_min * u.damage_factor)
		T("kr6_kr1_bomb_bfg").bullet.damage_max = math.floor(T("kr6_kr1_bomb_bfg").bullet.damage_max * u.damage_factor)
		T("ray_tesla").bounce_damage_min = math.floor(T("ray_tesla").bounce_damage_min * u.damage_factor)
		T("ray_tesla").bounce_damage_max = math.floor(T("ray_tesla").bounce_damage_max * u.damage_factor)
		T("kr6_kr1_ray_tesla").bounce_damage_min = math.floor(T("kr6_kr1_ray_tesla").bounce_damage_min * u.damage_factor)
		T("kr6_kr1_ray_tesla").bounce_damage_max = math.floor(T("kr6_kr1_ray_tesla").bounce_damage_max * u.damage_factor)
	end

	u = self:get_upgrade("engineer_range_finder")

	if u then
		for _, n in pairs({
			"g1_tower_engineer_1",
			"g1_tower_engineer_2",
			"g1_tower_engineer_3",
			"tower_engineer_kr1_lvl1",
			"tower_engineer_kr1_lvl2",
			"tower_engineer_kr1_lvl3",
			"tower_bfg_kr1",
			"tower_tesla_kr1",
			"tower_bfg",
			"tower_tesla",
			"tower_sandmystic"
		}) do
			T(n).attacks.range = math.ceil(T(n).attacks.range * u.range_factor)
		end

		T("tower_bfg").attacks.list[1].range = math.ceil(T("tower_bfg").attacks.list[1].range * u.range_factor)
		T("tower_bfg").attacks.list[2].range_base = math.ceil(T("tower_bfg").attacks.list[2].range_base * u.range_factor)
		T("tower_tesla").attacks.list[1].range = math.ceil(T("tower_tesla").attacks.list[1].range * u.range_factor)
		T("tower_bfg_kr1").attacks.list[1].range = math.ceil(T("tower_bfg_kr1").attacks.list[1].range * u.range_factor)
		T("tower_bfg_kr1").attacks.list[2].range_base = math.ceil(T("tower_bfg_kr1").attacks.list[2].range_base * u.range_factor)
		T("tower_tesla_kr1").attacks.list[1].range = math.ceil(T("tower_tesla_kr1").attacks.list[1].range * u.range_factor)
		T("tower_sandmystic").attacks.list[1].range = math.ceil(T("tower_sandmystic").attacks.list[1].range * u.range_factor)
	end

	u = self:get_upgrade("engineer_field_logistics")

	if u then
		for _, n in pairs(engineer_towers) do
			T(n).tower.price = math.floor(T(n).tower.price * u.cost_factor)
		end
	end

	u = self:get_upgrade("engineer_industrialization")

	if u then
		for _, n in pairs({"tower_bfg_kr1", "tower_tesla_kr1"}) do
			for _, power in pairs(T(n).powers) do
				power.price_base = math.floor(power.price_base * u.cost_factor)
				power.price_inc = math.floor(power.price_inc * u.cost_factor)
				for i = 1, #power.price do
					power.price[i] = math.floor(power.price[i] * u.cost_factor)
				end
			end
		end
		for _, n in pairs({
			"tower_bfg",
			"tower_tesla",
			"tower_sandmystic",
		}) do
			for pk, pv in pairs(T(n).powers) do
				pv.price_base = math.floor(pv.price_base * u.cost_factor)
				pv.price_inc = math.floor(pv.price_inc * u.cost_factor)
			end
		end
	end

	-- Thunder is always a generation-3 spell, even when selected in another
	-- generation's level. Do not derive it from the current level's tech tree.
	local thunder_level = math.min(self:get_user_levels(user_data, 3).thunder or 0, self.max_level or 5)
	local thunder = T("power_thunder_control")
	local thunder_primary = thunder.thunders[1]

	thunder.user_power.level = thunder_level
	thunder.cooldown = thunder_level >= 2 and 60 or 70
	thunder_primary.count = thunder_level >= 3 and 8 or thunder_level >= 1 and 6 or 3
	thunder.rain.disabled = thunder_level < 3 and true or nil
	thunder.slow.disabled = thunder_level < 3 and true or nil
	thunder.thunders[2].count = thunder_level >= 5 and 6 or 0
	T("mod_power_thunder_slow").slow.factor = thunder_level >= 4 and 0.4 or 0.6

	if thunder_level >= 5 then
		thunder_primary.damage_min = 150
		thunder_primary.damage_max = 200
	elseif thunder_level >= 4 then
		thunder_primary.damage_min = 110
		thunder_primary.damage_max = 130
	elseif thunder_level >= 2 then
		thunder_primary.damage_min = 80
		thunder_primary.damage_max = 100
	else
		thunder_primary.damage_min = 50
		thunder_primary.damage_max = 90
	end

	T("power_fireball_control").user_power.level = self.levels.thunder
	u = self:get_upgrade("rain_blazing_skies")

	if u then
		T("power_fireball_control").fireball_count = T("power_fireball_control").fireball_count + u.fireball_count_increase
		T("power_fireball").bullet.damage_min = T("power_fireball").bullet.damage_min + u.damage_increase
		T("power_fireball").bullet.damage_max = T("power_fireball").bullet.damage_max + u.damage_increase
	end

	u = self:get_upgrade("rain_scorched_earth")

	if u then
		T("power_fireball").scorch_earth = true
	end

	u = self:get_upgrade("rain_bigger_and_meaner")

	if u then
		T("power_fireball_control").cooldown = T("power_fireball_control").cooldown - u.cooldown_reduction
		T("power_fireball").bullet.damage_radius = T("power_fireball").bullet.damage_radius * u.range_factor
		T("power_fireball").bullet.damage_min = T("power_fireball").bullet.damage_min + u.damage_increase
		T("power_fireball").bullet.damage_max = T("power_fireball").bullet.damage_max + u.damage_increase
	end

	u = self:get_upgrade("rain_blazing_earth")

	if u then
		T("power_fireball_control").cooldown = T("power_fireball_control").cooldown - u.cooldown_reduction
		T("power_scorched_earth").aura.damage_min = 20
		T("power_scorched_earth").aura.damage_max = 30
		T("power_scorched_earth").aura.duration = 10
		T("power_scorched_water").aura.damage_min = 20
		T("power_scorched_water").aura.damage_max = 30
		T("power_scorched_water").aura.duration = 10
	end

	u = self:get_upgrade("rain_cataclysm")

	if u then
		T("power_fireball_control").cataclysm_count = 5
		T("power_fireball").bullet.damage_min = T("power_fireball").bullet.damage_min + u.damage_increase
		T("power_fireball").bullet.damage_max = T("power_fireball").bullet.damage_max + u.damage_increase
	end

	local function configure_generation_fireball(generation)
		local level = math.min(self:get_user_levels(user_data, generation).thunder or 0, self.max_level or 5)
		local suffix = "_g" .. generation
		local control = ensure_template("power_fireball_control" .. suffix, "power_fireball_control")
		local projectile = ensure_template("power_fireball" .. suffix, "power_fireball")
		local scorched_water = ensure_template("power_scorched_water" .. suffix, "power_scorched_water")
		local scorched_earth = ensure_template("power_scorched_earth" .. suffix, "power_scorched_earth")
		local damage_increase = (level >= 1 and 20 or 0) + (level >= 3 and 40 or 0) + (level >= 5 and 60 or 0)

		control.user_power.level = level
		control.cooldown = 80 - (level >= 3 and 10 or 0) - (level >= 4 and 10 or 0)
		control.fireball_count = level >= 1 and 5 or 3
		control.cataclysm_count = level >= 5 and 5 or 0
		control.fireball_template = projectile.template_name

		projectile.bullet.damage_min = 30 + damage_increase
		projectile.bullet.damage_max = 60 + damage_increase
		projectile.bullet.damage_radius = level >= 3 and 75 or 60
		projectile.scorch_earth = level >= 2
		projectile.scorched_water_template = scorched_water.template_name
		projectile.scorched_earth_template = scorched_earth.template_name

		for _, aura in ipairs({scorched_water, scorched_earth}) do
			aura.aura.damage_min = level >= 4 and 20 or 10
			aura.aura.damage_max = level >= 4 and 30 or 20
			aura.aura.duration = level >= 4 and 10 or 5
		end
	end

	configure_generation_fireball(1)
	configure_generation_fireball(2)

	local soul = T("power_soul_impact_control")

	if soul then
		local sl = math.min(self.levels.thunder or 0, self.max_level or 5)
		local s = soul.soul_impact

		soul.user_power.level = sl
		soul.cooldown = sl >= 4 and 60 or 70
		s.impact_count = sl >= 5 and 6 or sl >= 1 and 4 or 3
		s.storm_extra = sl >= 5 and 2 or 0
		s.stun_duration = sl >= 2 and 0.4 or 0
		s.spectre_count = sl >= 3 and 4 or sl >= 2 and 2 or 0
		s.slow_duration = sl >= 3 and 2 or 0
		s.slow_factor = 0.5
		s.echo_chance = sl >= 4 and 0.25 or 0
		s.kill_cooldown_min = sl >= 4 and 5 or 0
		s.kill_cooldown_max = sl >= 4 and 7 or 0
	end

	local kr4_reinforcements = T("power_kr4_reinforcements_control")

	if kr4_reinforcements then
		local rl = generation_upgrades.level(user_data, "g4_reinforcements")

		kr4_reinforcements.reinforcement_level = rl
		kr4_reinforcements.branch = generation_upgrades.g4_reinforcement_branch(user_data)
		kr4_reinforcements.pit_lord_chance = rl >= 5 and 0.3 or 0
		kr4_reinforcements.cooldown = 14
	end

	if self.levels.reinforcements > 0 then
		local rl = math.min(self.levels.reinforcements, self.max_level or 5)

		u = self:get_upgrade("reinforcement_level_" .. rl)

		if u then
			for i = 1, 3 do
				E:set_template("re1_current_" .. i, T(u.template_name .. "_" .. i))
				E:set_template("re2_current_" .. i, T(u.template_name .. "_" .. i))
				E:set_template("re3_current_" .. i, T(u.template_name .. "_" .. i))
			end

			T("power_reinforcements_control").cooldown = E:get_template("re1_current_1").cooldown
		end
	end

--5代防御塔科技
	local b = balance.upgrades
	local u
	local all_towers = {
		"tower_paladin_covenant_lvl",
		"tower_demon_pit_lvl",
		"tower_tricannon_lvl",
		"tower_royal_archers_lvl",
		"tower_arborean_emissary_lvl",
		"tower_elven_stargazers_lvl",
		"tower_arcane_wizard_lvl",
		"tower_necromancer_lvl",
		"tower_ballista_lvl",
		"tower_flamespitter_lvl",
		"tower_rocket_gunners_lvl",
		"tower_barrel_lvl",
		"tower_sand_lvl",
		"tower_ghost_lvl",
		"tower_ray_lvl",
		"tower_dark_elf_lvl",
		"tower_hermit_toad_lvl",
		"tower_dwarf_lvl",
		"tower_sparking_geode_lvl",
		"tower_pandas_lvl",
		"tower_dragons_lvl",
	}

	-- towers_war_rations 我方单位加血10%->20%
	u = self:get_upgrade("towers_war_rations")
	local b_towers_war_rations_hp_factor = b.towers_war_rations.hp_factor
	--5代兵营血量调整。
	--if user_data.liuhui.balance ~= nil and user_data.liuhui.balance == false then
	--	upgrades_FL:deenhance_barrack5()
	--	b_towers_war_rations_hp_factor = 1.1
	--end
	if u then
		for _, n in pairs(all_towers) do
			for i = 1, 4 do
				if T(n .. i).barrack then
					local st = T(T(n .. i).barrack.soldier_type)
					if st then
						st.health.hp_max = km.round(st.health.hp_max * b_towers_war_rations_hp_factor)
					end
				end
			end
		end

		for i = 1, 4 do
			for _, n in pairs({
				"soldier_tower_necromancer_skeleton_lvl",
				"soldier_tower_necromancer_skeleton_golem_lvl",
				"soldier_tower_demon_pit_basic_attack_lvl"
			}) do
				T(n .. i).health.hp_max = km.round(T(n .. i).health.hp_max * b_towers_war_rations_hp_factor)
			end
		end

		T("big_guy_tower_demon_pit_lvl4").health.hp_max = km.round(T("big_guy_tower_demon_pit_lvl4").health.hp_max * b_towers_war_rations_hp_factor)
		T("soldier_tower_barrel_skill_warrior").war_rations_hp_factor = b_towers_war_rations_hp_factor
		T("tower_paladin_covenant_soldier_lvl4").powers.lead.b.hp = T("tower_paladin_covenant_soldier_lvl4").powers.lead.b.hp * b_towers_war_rations_hp_factor
		T("soldier_tower_dark_elf").war_rations_hp_factor = b_towers_war_rations_hp_factor

		for i = 1, 4 do
			T("soldier_tower_pandas_red_lvl" .. i).health.hp_max = km.round(T("soldier_tower_pandas_red_lvl" .. i).health.hp_max * b.towers_war_rations.hp_factor)
			T("soldier_tower_pandas_green_lvl" .. i).health.hp_max = km.round(T("soldier_tower_pandas_green_lvl" .. i).health.hp_max * b.towers_war_rations.hp_factor)
		end
	end

	-- towers_wise_investment 防御塔售价返还90%金币
	u = self:get_upgrade("towers_wise_investment")
	if u then
		for _, n in pairs(all_towers) do
			for i = 1, 4 do
				T(n .. i).tower.refund_factor = b.towers_wise_investment.refund_factor
			end
		end
	end

	-- towers_scoping_mechanism 防御塔范围提升10%
	u = self:get_upgrade("towers_scoping_mechanism")
	if u then
		local range_factor = b.towers_scoping_mechanism.range_factor
		local rally_range_factor = b.towers_scoping_mechanism.rally_range_factor

		for _, n in pairs(all_towers) do
			for i = 1, 4 do
				local t = T(n .. i)

				if t.barrack then
					t.barrack.rally_range = t.barrack.rally_range * rally_range_factor
				end

				if t.attacks then
					t.attacks.range = t.attacks.range * range_factor
				end
			end
		end
	end

	-- towers_golden_time 提前召唤多给80%金币，不给这个科技
	u = self:get_upgrade("towers_golden_time")

	--if u then
	--	GS.early_wave_reward_per_second = GS.early_wave_reward_per_second_default * b.towers_golden_time.early_wave_reward_per_second_factor
	--else
	--	GS.early_wave_reward_per_second = GS.early_wave_reward_per_second_default
	--end

	-- towers_improved_formulas 智能瞄准
	u = self:get_upgrade("towers_improved_formulas")
	if u then
		local r_factor = b.towers_improved_formulas.range_factor

		for _, n in pairs({
			"soldier_tower_demon_pit_basic_attack_lvl"
		}) do
			for i = 1, 4 do
				for j = 1, 4 do
					T(n .. i).explosion_range[j] = T(n .. i).explosion_range[j] * r_factor
					T(n .. i).explosion_damage_min[j] = T(n .. i).explosion_damage_max[j]
				end
			end
		end

		for i = 1, 4 do
			T("tower_tricannon_bomb_" .. i).bullet.damage_radius = T("tower_tricannon_bomb_" .. i).bullet.damage_radius * r_factor
			T("tower_tricannon_bomb_" .. i).bullet.damage_min = T("tower_tricannon_bomb_" .. i).bullet.damage_max
		end

		for i = 1, 4 do
			T("bullet_tower_hermit_toad_engineer_basic_lvl" .. i).bullet.damage_radius = T("bullet_tower_hermit_toad_engineer_basic_lvl" .. i).bullet.damage_radius * r_factor
		end

		for i = 1, 4 do
			T("bullet_tower_hermit_toad_engineer_basic_lvl" .. i).bullet.damage_min = T("bullet_tower_hermit_toad_engineer_basic_lvl" .. i).bullet.damage_max
		end

		T("tower_tricannon_bomb_bombardment_bomb").bullet.damage_radius = T("tower_tricannon_bomb_bombardment_bomb").bullet.damage_radius * r_factor
		for i = 1,3 do
			T("tower_tricannon_bomb_bombardment_bomb").bullet.damage_min_config[i] = T("tower_tricannon_bomb_bombardment_bomb").bullet.damage_max_config[i]
		end

		T("soldier_tower_rocket_gunners_lvl4").melee.attacks[2].damage_radius = T("soldier_tower_rocket_gunners_lvl4").melee.attacks[2].damage_radius * r_factor
		T("bullet_tower_ballista_skill_bomb").bullet.damage_radius = T("bullet_tower_ballista_skill_bomb").bullet.damage_radius * r_factor
		--for i = 1,3 do
		--	T("bullet_tower_ballista_skill_bomb").bullet.damage_min_config[i] = T("bullet_tower_ballista_skill_bomb").bullet.damage_max_config[i]
		--end

		T("bullet_tower_flamespitter_skill_bomb").bullet.damage_radius = T("bullet_tower_flamespitter_skill_bomb").bullet.damage_radius * r_factor
		T("controller_tower_flamespitter_column").radius_in = T("controller_tower_flamespitter_column").radius_in * r_factor
		T("controller_tower_flamespitter_column").radius_out = T("controller_tower_flamespitter_column").radius_out * r_factor

		for i = 1, 4 do
			T("bullet_tower_barrel_lvl" .. i).bullet.damage_radius = T("bullet_tower_barrel_lvl" .. i).bullet.damage_radius * r_factor
			T("bullet_tower_barrel_lvl" .. i).bullet.damage_min = T("bullet_tower_barrel_lvl" .. i).bullet.damage_max
		end

		T("aura_bullet_tower_barrel_skill_barrel").explosion_damage_radius = T("aura_bullet_tower_barrel_skill_barrel").explosion_damage_radius * r_factor
		for i = 1,3 do
			T("aura_bullet_tower_barrel_skill_barrel").explosion_damage_min[i] = T("aura_bullet_tower_barrel_skill_barrel").explosion_damage_max[i]
		end
	end

	-- towers_favorite_customer 最后一级技能价格下降
	-- 由于提前开波的技能在此无法复现，所以提升本技能的效果。
	-- 1级技能返还20%金币，3级技能返还25%金币。
	u = self:get_upgrade("towers_favorite_customer")

	if u then
		for _, n in pairs({
		"tower_paladin_covenant_lvl4",
		"tower_demon_pit_lvl4",
		"tower_tricannon_lvl4",
		"tower_royal_archers_lvl4",
		"tower_arborean_emissary_lvl4",
		"tower_elven_stargazers_lvl4",
		"tower_arcane_wizard_lvl4",
		"tower_necromancer_lvl4",
		"tower_ballista_lvl4",
		"tower_flamespitter_lvl4",
		"tower_rocket_gunners_lvl4",
		"tower_barrel_lvl4",
		"tower_sand_lvl4",
		"tower_ghost_lvl4",
		"tower_ray_lvl4",
		"tower_dark_elf_lvl4",
		"tower_hermit_toad_lvl4",
		"tower_dwarf_lvl4",
		"tower_sparking_geode_lvl4",
		"tower_pandas_lvl4",
		"tower_dragons_lvl4",
			--"tower_entwood"
		}) do
			for pk, pv in pairs(T(n).powers) do
				if pv.max_level == 1 or pv.price_inc == 0 then
					pv.price_base = math.floor(pv.price_base * b.towers_favorite_customer.refund_cost_factor_one_level)
				elseif pv.max_level == 2 then
					pv.price_inc = math.floor(pv.price_inc * 0.5)
				else
					pv.price_inc = math.floor(pv.price_inc * b.towers_favorite_customer.refund_cost_factor)
				end
			end
		end
	end

	--if u then
	--	u.refund_cost_factor = b.towers_favorite_customer.refund_cost_factor
	--	u.refund_cost_factor_one_level = b.towers_favorite_customer.refund_cost_factor_one_level
	--end

	--towers_keen_accuracy 技能CD降低20%
	u = self:get_upgrade("towers_keen_accuracy")

	if u then
		for _, n in pairs(all_towers) do
			local template = T(n .. 4)

			for _, p in pairs(T(n .. 4).powers) do
				if p.cooldown then
					for k, _ in pairs(p.cooldown) do
						p.cooldown[k] = p.cooldown[k] * b.towers_keen_accuracy.cooldown_mult
					end
				end
			end
		end
	end

	-- towers_royal_training 复活时间-2秒，只缩短复活时间，不缩短援军复活时间。
	-- 为了折合复活科技，复活时间-3秒。
	u = self:get_upgrade("towers_royal_training")

	if u then
		for _, n in pairs(all_towers) do
			if n == "tower_pandas_lvl" then
				for i = 1, 4 do
					T(n .. i).attacks.list[2].cooldown = T(n .. i).attacks.list[2].cooldown - b.towers_royal_training.reduce_cooldown
				end
			else
				for i = 1, 4 do
					if T(n .. i).barrack then
						local st = T(T(n .. i).barrack.soldier_type)
						if st then
							st.health.dead_lifetime = st.health.dead_lifetime - b.towers_royal_training.reduce_cooldown
						end
					end
				end
			end
		end

		for i = 1, 3 do
			T("tower_barrel_lvl4").attacks.list[3].cooldown[i] = T("tower_barrel_lvl4").attacks.list[3].cooldown[i] - b.towers_royal_training.reinforcements_cooldown
		end

		T("re_current_1").cooldown = T("re_current_1").cooldown - b.towers_royal_training.reinforcements_cooldown
	end

	u = true --self:get_upgrade("alliance_shady_company")

	if u and user_data.liuhui then
		local heroes = user_data.liuhui.g5_hero_dark_count
		--local heroes = 0

		--for _, h in ipairs(slot.heroes.team) do
		--	if T(h).hero.team == TEAM_DARK_ARMY then
		--		heroes = heroes + 1
		--	end
		--end

		if heroes and heroes > 0 then
			local tower_t, bullet_t, soldier_t
			local d_mult = 1 + b.alliance_shady_company.damage_extra * heroes

			for i = 1, 4 do
				tower_t = T("tower_royal_archers_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			tower_t = T("tower_arcane_wizard_lvl1")
			bullet_t = T(tower_t.attacks.list[1].bullet)

			for i = 1, 4 do
				bullet_t.bullet.damage_min_config[i] = math.ceil(bullet_t.bullet.damage_min_config[i] * d_mult)
				bullet_t.bullet.damage_max_config[i] = math.ceil(bullet_t.bullet.damage_max_config[i] * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_paladin_covenant_lvl" .. i)
				soldier_t = T(tower_t.barrack.soldier_type)
				soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
				soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_arborean_emissary_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			tower_t = T("tower_elven_stargazers_lvl1")
			bullet_t = T(tower_t.attacks.list[1].bullet)

			for i = 1, 4 do
				bullet_t.bullet.damage_min_config[i] = math.ceil(bullet_t.bullet.damage_min_config[i] * d_mult)
				bullet_t.bullet.damage_max_config[i] = math.ceil(bullet_t.bullet.damage_max_config[i] * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_tricannon_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_demon_pit_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				soldier_t = T(bullet_t.bullet.hit_payload)
				soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
				soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_ballista_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_rocket_gunners_lvl" .. i)
				soldier_t = T(tower_t.barrack.soldier_type)
				soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
				soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
				bullet_t = T(soldier_t.ranged.attacks[1].bullet)
				bullet_t.bullet.damage_min_config[i] = math.ceil(bullet_t.bullet.damage_min_config[i] * d_mult)
				bullet_t.bullet.damage_max_config[i] = math.ceil(bullet_t.bullet.damage_max_config[i] * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_necromancer_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_flamespitter_lvl" .. i)

				local aura_t = T(tower_t.attacks.list[1].aura)

				aura_t.damage_min_config[i] = math.ceil(aura_t.damage_min_config[i] * d_mult)
				aura_t.damage_max_config[i] = math.ceil(aura_t.damage_max_config[i] * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_barrel_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_sand_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_ghost_lvl" .. i)
				soldier_t = T(tower_t.barrack.soldier_type)
				soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
				soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_ray_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			tower_t = T("tower_ray_lvl4")
			bullet_t = T(tower_t.attacks.list[2].bullet)
			bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
			bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)

			for i = 1, 4 do
				tower_t = T("tower_dwarf_lvl" .. i)
				soldier_t = T(tower_t.barrack.soldier_type)
				soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
				soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
			end
			
			for i = 1, 4 do
				tower_t = T("tower_dark_elf_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_hermit_toad_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_hermit_toad_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[2].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_sparking_geode_lvl" .. i)
				bullet_t = T(tower_t.attacks.list[1].bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end

			for i = 1, 4 do
				tower_t = T("tower_pandas_lvl" .. i)

				for _, b_cfg in pairs(tower_t.attacks.list[1].bullet_list) do
					bullet_t = T(b_cfg.b)
					bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
					bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
				end

				for _, s in pairs(tower_t.attacks.list[2].soldiers) do
					soldier_t = T(s)
					soldier_t.melee.attacks[1].damage_min = math.ceil(soldier_t.melee.attacks[1].damage_min * d_mult)
					soldier_t.melee.attacks[1].damage_max = math.ceil(soldier_t.melee.attacks[1].damage_max * d_mult)
				end
			end

			for i = 1, 4 do
				tower_t = T("faerie_dragon_lvl" .. i)
				bullet_t = T(tower_t.custom_attack.bullet)
				bullet_t.bullet.damage_min = math.ceil(bullet_t.bullet.damage_min * d_mult)
				bullet_t.bullet.damage_max = math.ceil(bullet_t.bullet.damage_max * d_mult)
			end
		end
	end

	u = true --self:get_upgrade("alliance_friends_of_the_crown")

	if u and user_data.liuhui then
		--local cost_red = 0

		--for _, h in ipairs(slot.heroes.team) do
		--	if T(h).hero.team == TEAM_LINIREA then
		--		cost_red = cost_red + b.alliance_friends_of_the_crown.cost_red_per_hero
		--	end
		--end
		local cost_red = 5*(2 - user_data.liuhui.g5_hero_dark_count)

		if cost_red > 0 then
			for _, n in pairs(all_towers) do
				for i = 1, 4 do
					T(n .. i).tower.price = T(n .. i).tower.price - cost_red
				end
			end
		end
	end

	-- 5代援军科技跟随所选援军，不再受当前关卡代数限制。
	u = self:get_upgrade("reinforcements_master_blacksmiths")

	if u then
		local portrait_idxs = {
			25,
			26,
			27
		}

		for i = 1, 3 do
			local t = T("soldier_reinforcement_basic_0" .. i)

			t.unit.damage_factor = b.reinforcements_master_blacksmiths.damage_factor
			t.health.armor = b.reinforcements_master_blacksmiths.armor
			t.render.sprites[1].prefix = "reinforcements_lvl2_0" .. i
			t.info.portrait = "gui_bottom_info_image_soldiers_00" .. portrait_idxs[i]
		end
	end

	u = self:get_upgrade("reinforcements_intense_workout")

	if u then
		for i = 1, 3 do
			local t = T("soldier_reinforcement_basic_0" .. i)

			t.health.hp_max = t.health.hp_max * b.reinforcements_intense_workout.hp_factor
			t.reinforcement.duration = t.reinforcement.duration + b.reinforcements_intense_workout.duration_extra
		end
	end

	u = self:get_upgrade("reinforcements_rebel_militia")

	if u then
		for i = 1, 2 do
			local num = km.zmod(i, 2)

			E:set_template("re_current_" .. i, E:get_template("soldier_reinforcement_rebel_militia_0" .. num))
		end
	end

	u = self:get_upgrade("reinforcements_shadow_archer")

	if u then
		for i = 1, 1 do
			local num = km.zmod(i, 2)

			E:set_template("re_current_" .. i, E:get_template("soldier_reinforcement_shadow_archer_0" .. num))
		end
	end

	u = self:get_upgrade("towers_royal_training")

	if u then
		T("re_current_1").cooldown = T("re_current_1").cooldown - b.towers_royal_training.reinforcements_cooldown
	end

	u = self:get_upgrade("reinforcements_thorny_armor")

	if u then
		local portrait_idxs = {
			31,
			33
		}

		for i = 1, 2 do
			local num = km.zmod(i, 2)
			local t = T("soldier_reinforcement_rebel_militia_0" .. num)

			t.health.spiked_armor = b.reinforcements_thorny_armor.spiked_armor
			t.render.sprites[1].prefix = "reinforcements_lvl4_0" .. num
			t.info.portrait = "gui_bottom_info_image_soldiers_00" .. portrait_idxs[i]
		end
	end

	u = self:get_upgrade("reinforcements_night_veil")

	if u then
		for i = 1, 1 do
			local num = km.zmod(i, 2)
			local t = T("soldier_reinforcement_shadow_archer_0" .. num)

			t.ranged.attacks[1].max_range = t.ranged.attacks[1].max_range + b.reinforcements_night_veil.extra_range
			t.ranged.attacks[1].cooldown = t.ranged.attacks[1].cooldown - b.reinforcements_night_veil.cooldown_red
			t.render.sprites[1].prefix = "reinforcements_lvl4_0" .. num + 2
			t.info.portrait = "gui_bottom_info_image_soldiers_0032"

			local t = T("arrow_soldier_re_shadow_archer")

			t.render.sprites[1].name = "reinforcements_lvl4_03_arrow"
		end
	end

	--出口科技
	if game and game.store and game.store.level_idx and game.store.level_idx >= 101 and game.store.level_idx <= 149 then
			c_upg = E:create_entity("controller_upgrades_alliance")
			c_upg.seal = "decal_upgrade_alliance_seal_of_punishment"
			c_upg.coil = "decal_upgrade_alliance_flux_altering_coils"
			simulation:queue_insert_entity_exit(c_upg)
	end

	--4代关卡：复用5代防守旗帜接口，但把旗帜替换为4代死亡射线线圈
	if self:get_upgrade("g4_towers_death_coils") and game and game.store and game.store.level_idx and game.store.level_idx >= 150 and game.store.level_idx <= 201 then
			c_upg = E:create_entity("controller_upgrades_alliance")
			c_upg.coil = "decal_kr4_power_death_ray_coils"
			c_upg.extra_gold = 0
			simulation:queue_insert_entity_exit(c_upg)
	end
	

	--所有科技结算完之后：refund_factor在随机塔模式下降低到0.6
	if user_data.liuhui and user_data.liuhui.rand_tower and user_data.liuhui.rand_tower > 0 then
		for _, t in pairs(E:filter_templates("tower")) do
			t.tower.refund_factor = 0.6
		end
	end

end

return upgrades
