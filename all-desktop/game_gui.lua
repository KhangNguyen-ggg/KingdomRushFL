-- chunkname: @./all-desktop/game_gui.lua

if DEBUG then
	package.loaded["data.game_gui_data"] = nil
	package.loaded.gg_views_custom = nil
end

local log = require("klua.log"):new("game_gui")
local km = require("klua.macros")

require("klua.table")
require("klove.kui")

local timer = require("hump.timer"):new()
local signal = require("hump.signal")
local class = require("middleclass")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local AC = require("achievements")
local F = require("klove.font_db")
local I = require("klove.image_db")
local kui_db = require("klove.kui_db")
local S = require("sound_db")
local SU = require("screen_utils")
local E = require("entity_db")
local U = require("utils")
local V = require("klua.vector")
local v = V.v
local r = V.r
local P = require("path_db")
local GR = require("grid_db")
local GS = require("game_settings")
local GU = require("gui_utils_5") --这个不能乱用 流辉349
local LU = require("level_utils")
local storage = require("storage")
local UP = require("upgrades")
local G = love.graphics
local i18n = require("i18n")
local balance = require("balance/balance")
local tower_balance_highlight = require("tower_balance_highlight")
local tower_power_display = require("data.tower_power_display")
local UPGR = require("upgrades")
local shortcut_settings = require("shortcut_settings")
local generation_upgrades = require("generation_upgrades")
local power_selection = require("power_selection")
local earnings_stats = require("earnings_stats")
local tower_loadout = require("tower_loadout")
local map_data = require("data.map_data")
local hero_game_ver = map_data.hero_game_ver
local hero_group_ver = map_data.hero_group_ver


local function T(name)
	return E:get_template(name)
end

local function fts(v)
	return v / FPS
end

local function ISW(...)
	return i18n.sw(i18n, ...)
end

local function CJK(default, zh, ja, kr)
	return i18n.cjk(i18n, default, zh, ja, kr)
end

local infinite_heroes = require("infinite_heroes")
local IS_KR3 = KR_GAME == "kr3"
local IS_KR2 = KR_GAME == "kr2"
local IS_KR1 = KR_GAME == "kr1"

require("constants")

local kr6_enemy_notification_ids = {}

for _, enemy in ipairs(GS.encyclopedia_enemies) do
	if enemy.generation == 6 then
		kr6_enemy_notification_ids[enemy.name] = true
	end
end

local features = require("features")

require("gg_views_custom")

local data = require("data.game_gui_data")
local tower_menus = require("data.tower_menus_data")

local IS_PHONE = KR_TARGET == "phone"
local IS_TABLET = KR_TARGET == "tablet"
local DRAG_ENTITY_LOOKUP_MARGIN = 15
local DRAG_ENTITY_THRESHOLD = IS_MOBILE and 10 or 25
local DRAG_TOWER_THRESHOLD = IS_MOBILE and 10 or 25
local POWER_BUTTON_DRAG_SCALE = 1.6
local QUICK_CLICK_TIME = 0.2
local PAN_TO_ENTITY_TIME = 0.6
local TOWERMENU_SHOW_TOOLTIP_ON_MAXED_POWER = not IS_MOBILE
local SHOW_INGAME_SHOP = IS_MOBILE and PS.services and PS.services.iap and RC.v.ingame_shop or false

local game_gui = {}
local GUI_MODE_FREE_HOLDER = "free_holder"

local free_holder_click_rect

local function get_free_holder_click_rect()
	if not free_holder_click_rect then
		local template = T("tower_holder")
		local rect = template.ui.click_rect

		free_holder_click_rect = {
			x = rect.pos.x,
			y = rect.pos.y,
			w = rect.size.x,
			h = rect.size.y
		}
	end

	return free_holder_click_rect
end

local function free_holder_rects_overlap(a, b)
	return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y
end

local function free_holder_point_is_clear(x, y)
	local terrain_mask = bor(TERRAIN_LAND, TERRAIN_ICE)

	return GR:cell_is(x, y, terrain_mask) and GR:cell_is_only(x, y, terrain_mask) and not P:valid_node_nearby(x, y, nil, NF_RALLY)
end

local function can_place_free_holder(store, x, y)
	local rect = get_free_holder_click_rect()
	local sample_points = {
		v(x + rect.x + rect.w * 0.5, y + rect.y + rect.h * 0.5),
		v(x + rect.x + rect.w * 0.5, y + rect.y + 0.5 * (1 - ASPECT) * rect.h),
		v(x + rect.x + rect.w * 0.5, y + rect.y + 0.5 * (1 + ASPECT) * rect.h),
		v(x + rect.x, y + rect.y + rect.h * 0.5),
		v(x + rect.x + rect.w, y + rect.y + rect.h * 0.5)
	}

	for _, point in ipairs(sample_points) do
		if not free_holder_point_is_clear(point.x, point.y) then
			return false
		end
	end

	local candidate = {
		x = x + rect.x,
		y = y + rect.y,
		w = rect.w,
		h = rect.h
	}

	local function overlaps_entity(entity)
		if not entity or entity.enemy or entity.soldier or not entity.pos or not entity.ui or not entity.ui.click_rect then
			return false
		end

		local other = entity.ui.click_rect

		return free_holder_rects_overlap(candidate, {
			x = entity.pos.x + other.pos.x,
			y = entity.pos.y + other.pos.y,
			w = other.size.x,
			h = other.size.y
		})
	end

	for _, entity in pairs(store.entities) do
		if overlaps_entity(entity) then
			return false
		end
	end

	for _, entity in ipairs(store.pending_inserts or {}) do
		if overlaps_entity(entity) then
			return false
		end
	end

	return true
end

local function insert_free_holder(store, x, y)
	local terrain_style = store.terrain_style or 1
	local max_holder_id = 0

	local function inspect(entity)
		if entity and entity.tower then
			terrain_style = entity.tower.terrain_style or terrain_style
			max_holder_id = math.max(max_holder_id, tonumber(entity.tower.holder_id) or 0)
		end
	end

	for _, entity in pairs(store.entities) do
		inspect(entity)
	end

	for _, entity in ipairs(store.pending_inserts or {}) do
		inspect(entity)
	end

	local kr6_holder = terrain_style >= 46 and terrain_style <= 64 and terrain_style ~= 50
	local holder = E:create_entity(kr6_holder and "tower_holder_kr6" or "tower_holder")

	holder.pos = v(x, y)
	holder.tower.holder_id = tostring(max_holder_id + 1)
	holder.tower.terrain_style = terrain_style
	holder.tower.default_rally_pos = v(x, y + 50)

	local base_sprite = holder.render and holder.render.sprites and holder.render.sprites[1]

	if base_sprite and type(base_sprite.name) == "string" and string.find(base_sprite.name, "%%") then
		base_sprite.name = string.format(base_sprite.name, terrain_style)
	end

	game_gui.game.simulation:queue_insert_entity(holder)

	return holder
end

local tower_doc_name_aliases = {
	ranger = "tower_ranger",
	musketeer = "tower_musketeer",
	paladin = "tower_paladin",
	barbarian = "tower_barbarian",
	arcane_wizard = "tower_arcane_wizard",
	sorcerer = "tower_sorcerer",
	bfg = "tower_bfg",
	tesla = "tower_tesla",
	totem = "tower_totem",
	crossbow = "tower_crossbow",
	assassin = "tower_assassin",
	templar = "tower_templar",
	necromancer = "tower_necromancer",
	archmage = "tower_archmage",
	dwaarp = "tower_dwaarp",
	mecha = "tower_mech",
	mech = "tower_mech",
	arcane = "tower_arcane",
	silver = "tower_silver",
	blade = "tower_blade",
	forest = "tower_forest",
	wild_magus = "tower_wild_magus",
	high_elven = "tower_high_elven",
	druid = "tower_druid",
	entwood = "tower_entwood",
	arcane_wizard5 = "tower_arcane_wizard_lvl4",
	necromancer5 = "tower_necromancer_lvl4"
}

local function tower_doc_enhanced_enabled()
	local docs = tower_menus and tower_menus.tower_balance_docs

	if not docs then
		return false
	end

	if docs.mode == "enhanced" then
		return true
	end

	if docs.mode == "standard" or docs.mode == "game" then
		return false
	end

	local store = game_gui and game_gui.game and game_gui.game.store
	local user_data = store and store.user_data or screen_map and screen_map.user_data

	return user_data and user_data.liuhui and user_data.liuhui.balance == true
end

local function tower_doc_candidate_names(entity)
	local names = {}

	local function add(name)
		if type(name) ~= "string" or name == "" then
			return
		end

		for _, existing in ipairs(names) do
			if existing == name then
				return
			end
		end

		table.insert(names, name)

		local level_4_name = string.gsub(name, "_lvl[123]$", "_lvl4")

		if level_4_name ~= name then
			add(level_4_name)
		end

		local alias = tower_doc_name_aliases[name]

		if alias then
			add(alias)
		end

		if not string.match(name, "^tower_") then
			add("tower_" .. name)
			add("tower_" .. name .. "_lvl4")
		end
	end

	add(entity and entity.template_name)
	add(entity and entity.tower and entity.tower.type)

	return names
end

local function tower_doc_power_skill(entity, power_name)
	if not power_name then
		return nil
	end

	local docs = tower_menus and tower_menus.tower_balance_docs

	if not docs or docs.mode == "game" then
		return nil
	end

	local ranks = docs and docs.skill_ranks
	local entries = docs and docs.entries

	if not ranks or not entries then
		return nil
	end

	for _, tower_name in ipairs(tower_doc_candidate_names(entity)) do
		local rank = ranks[tower_name] and ranks[tower_name][power_name]
		local entry = rank and entries[tower_name]
		local skill = entry and entry.skills and entry.skills[rank]

		if skill then
			return skill
		end
	end

	return nil
end

local function tower_doc_power_text(entity, power_name, level)
	local skill = tower_doc_power_skill(entity, power_name)

	if not skill then
		return nil, nil
	end

	local enhanced = tower_doc_enhanced_enabled()
	local levels = enhanced and skill.levels_enhanced or skill.levels_standard
	local desc = levels and levels[level] or enhanced and skill.enhanced or skill.standard
	local previous_desc = level and level > 1 and levels and (levels[level - 1] or levels[1]) or ""
	local next_desc = levels and level and levels[level + 1] or nil

	if type(desc) ~= "string" or desc == "" then
		return nil, nil
	end

	return skill.name, desc, previous_desc, next_desc
end

game_gui.required_textures = {
	"gui_common",
	"spell_selection_icons",
	"dolia_spell_assets",
	"cheat_item_spell_icons",
	"gui_portraits",
	"kr6_hero_portraits",
	-- "kr6_hero_silent_portraits",
	-- "kr6_hero_silent_icons",
	"kr6_stage_hero_portraits",
	"achievements",
	"encyclopedia",
	"rebborn_enemy_icons",
	"gui_notifications_common",
	"gui_notifications_bg",
	"view_options",
	"white_block",
	"hero_goldfinger",
	--"ultimate45",
	--"kr4_herogui",
	"kr4_hero_power",
	--"kr4_hero_room",
	"kr5_hero_power",
	"gui_slices",
}
game_gui.ref_h = GUI_REF_H
game_gui.ref_w = GUI_REF_W
game_gui.ref_res = TEXTURE_SIZE_ALIAS.ipad

local function power_cooldown_now()
	local store = game_gui.game and game_gui.game.store

	if not store then
		return 0
	end

	-- Power execution follows simulation ticks. store.ts can run ahead when a
	-- low-FPS frame is advanced repeatedly by the fast-forward controls.
	return store.tick_ts or store.ts or 0
end

local function current_campaign_variant()
	local store = game_gui.game and game_gui.game.store

	if not store or store.level_mode ~= GAME_MODE_CAMPAIGN then
		return CAMPAIGN_VARIANT_REGULAR
	end

	return store.campaign_variant or CAMPAIGN_VARIANT_REGULAR
end

local function using_hero_rally()
	return current_campaign_variant() == CAMPAIGN_VARIANT_HERO_RALLY
end

local function using_spell_raid()
	return current_campaign_variant() == CAMPAIGN_VARIANT_SPELL_RAID
end

local function using_nostalgic_classic()
	return current_campaign_variant() == CAMPAIGN_VARIANT_NOSTALGIC_CLASSIC
end

local function spell_mode_cooldown(cooldown)
	local store = game_gui.game and game_gui.game.store

	if store and store.level_mode_6 then
		return cooldown * (GS.mode_power_cooldown_factor[store.level_mode_6] or 1)
	end

	return cooldown
end

local function power_hero_entity(rank)
	rank = rank or 1

	local store = game_gui.game and game_gui.game.store
	local user_data = storage:load_slot()
	local is_double = not using_nostalgic_classic() and user_data and user_data.liuhui_hero and user_data.liuhui_hero.usedoublehero

	if store then
		if using_hero_rally() then
			local hero = store.main_heroes and store.main_heroes[rank]

			if hero then
				return hero
			end
		elseif is_double then
			if rank == 1 then
				if store.main1_hero then
					return store.main1_hero
				end
			elseif rank == 2 then
				if store.main_hero then
					return store.main_hero
				end
			end
		elseif rank == 1 and store.main_hero then
			return store.main_hero
		end
	end

	-- Scripted stage heroes can also have HUD portraits (6-15's Blackburn is
	-- inserted before the player's hero). Only use portrait order as a fallback
	-- while the actual player-hero references have not been initialized.
	local hero_view = game_gui.heroes and game_gui.heroes[rank]

	if hero_view and hero_view.hero_id then
		return game_gui:entity_by_id(hero_view.hero_id)
	end
end

local function power_hero_template(rank)
	rank = rank or 1

	local hero = power_hero_entity(rank)

	if hero and hero.template_name then
		return E:get_template(hero.template_name), hero
	end

	local store = game_gui.game and game_gui.game.store
	local user_data = storage:load_slot()
	local hero_data = map_data.hero_data
	local is_double = not using_nostalgic_classic() and user_data and user_data.liuhui_hero and user_data.liuhui_hero.usedoublehero

	if using_hero_rally() then
		local idx = user_data and user_data.liuhui_hero and user_data.liuhui_hero.rallylist and user_data.liuhui_hero.rallylist[rank]

		if idx and hero_data[idx] then
			return E:get_template(hero_data[idx].name), nil
		end
	elseif is_double then
		local idx = user_data.liuhui_hero.herolist and user_data.liuhui_hero.herolist[rank]

		if idx and hero_data[idx] then
			return E:get_template(hero_data[idx].name), nil
		end
	elseif store and store.selected_hero then
		return E:get_template(store.selected_hero), nil
	elseif user_data and user_data.heroes and user_data.heroes.selected then
		return E:get_template(user_data.heroes.selected), nil
	end

	return nil, nil
end

local function power_hero_button_icon(ht)
	if not ht or not ht.info or not ht.info.ultimate_icon then
		return nil
	end

	if hero_game_ver(ht.template_name) == 3 then
		return "power_button_icons_" .. ht.info.ultimate_icon
	else
		return "portraits_power_hero_" .. ht.info.ultimate_icon
	end
end

local function power_hero_pointer_icon(ht)
	if not ht or not ht.info or not ht.info.ultimate_icon then
		return nil
	end

	if hero_game_ver(ht.template_name) == 3 then
		return "pointer_hero_power_" .. ht.info.ultimate_icon
	else
		return "pointer_power_" .. ht.info.ultimate_icon
	end
end

local function power_hero_ultimate_cooldown(ht, he, controller)
	if controller and controller.cooldown then
		return controller.cooldown
	end

	local u = he and he.hero and he.hero.skills and he.hero.skills.ultimate

	if u and u.cooldown then
		if type(u.cooldown) == "table" then
			return u.cooldown[u.level] or u.cooldown[3] or u.cooldown[1]
		end

		return u.cooldown
	end

	u = ht and ht.hero and ht.hero.skills and ht.hero.skills.ultimate

	if u and u.cooldown then
		if type(u.cooldown) == "table" then
			return u.cooldown[3] or u.cooldown[1]
		end

		return u.cooldown
	end
end

local reinforcement_templates = {
	[1] = {
		"re1_farmer",
		"re1_farmer_well_fed",
		"re1_conscript",
		"re1_warrior",
		"re1_legionnaire",
		"re1_legionnaire_ranged"
	},
	[2] = {
		"re2_farmer",
		"re2_farmer_well_fed",
		"re2_conscript",
		"re2_warrior",
		"re2_legionnaire",
		"re2_legionnaire_ranged"
	}
}

local function selected_power_option(slot)
	if using_nostalgic_classic() then
		local option_ids = {"default_cataclysm", "default_reinforcement", "empty_spell"}

		return power_selection.options[option_ids[slot]], option_ids[slot]
	end

	local user_data = storage:load_slot()

	return power_selection.get(user_data, slot)
end

local function default_reinforcement_generation()
	local level_idx = game_gui.game.store.level_idx

	if level_idx >= 150 and level_idx <= 201 then
		return 4
	elseif level_idx > GS.jnum5 and level_idx <= GS.last_level5 then
		return 5
	elseif level_idx <= GS.last_level3 or level_idx == 81 or level_idx == 82 or level_idx == 86 then
		return 3
	elseif level_idx <= GS.last_level2 or level_idx >= 77 and level_idx <= 80 or level_idx == 83 or level_idx == 84 or level_idx >= 87 and level_idx <= 91 then
		return 2
	end

	return 1
end

local function default_cataclysm_generation()
	local generation = default_reinforcement_generation()

	if generation == 4 then
		return 1
	elseif generation == 5 then
		return 3
	end

	return generation
end

local function default_cataclysm_uses_thunder()
	return default_cataclysm_generation() == 3
end


local function using_double_heroes()
	if using_nostalgic_classic() then
		return false
	end

	local user_data = storage:load_slot()

	return user_data and user_data.liuhui_hero and user_data.liuhui_hero.usedoublehero
end

local function hero_control_limit()
	if infinite_heroes.active(game_gui.game and game_gui.game.store) then return #(game_gui.heroes or {}) end
	if using_hero_rally() then
		return 4
	elseif KR_GAME == "kr5" or using_double_heroes() then
		return 2
	end

	return 1
end

local function selected_hero_ultimate_by_rank(rank)
	if not rank then
		return nil, nil, nil
	end

	local hero, hero_entity = power_hero_template(rank)
	local skills = hero_entity and hero_entity.hero and hero_entity.hero.skills or
		hero and hero.hero and hero.hero.skills
	local ultimate = skills and skills.ultimate

	if not hero or not ultimate or not ultimate.controller_name then
		return nil, nil, nil
	end

	return hero, hero_entity, ultimate
end

local function hero_ultimate_assignments()
	if infinite_heroes.active(game_gui.game and game_gui.game.store) then return {}, {} end
	if using_spell_raid() or using_hero_rally() then
		return {}, {}
	end

	local is_double = using_double_heroes()
	local ranks = is_double and {1, 2} or {1}
	local available_ranks = {}
	local base_slots = {}
	local assigned = {}

	for _, rank in ipairs(ranks) do
		if selected_hero_ultimate_by_rank(rank) then
			table.insert(available_ranks, rank)
		end
	end

	local next_rank = 1

	for slot = 1, 3 do
		local option = selected_power_option(slot)
		local rank = available_ranks[next_rank]

		if option.kind == "empty" and rank then
			base_slots[slot] = rank
			assigned[rank] = true
			next_rank = next_rank + 1
		end
	end

	local extra_slots = {}
	local extra_slot_names = {"a", "s"}
	local extra_slot_index = 1

	for _, rank in ipairs(available_ranks) do
		if not assigned[rank] then
			local slot = extra_slot_names[extra_slot_index]

			extra_slots[slot] = rank
			extra_slot_index = extra_slot_index + 1
		end
	end

	return base_slots, extra_slots
end

local function hero_ultimate_rank(slot)
	local base_slots, extra_slots = hero_ultimate_assignments()

	return type(slot) == "number" and base_slots[slot] or extra_slots[slot]
end

local function selected_hero_ultimate(slot)
	return selected_hero_ultimate_by_rank(hero_ultimate_rank(slot))
end

local function hero_ultimate_slot_available(slot)
	local hero, _, ultimate = selected_hero_ultimate(slot)

	return hero ~= nil and ultimate ~= nil
end

local function hero_ultimate_slot_cooldown(slot)
	local hero, hero_entity, ultimate = selected_hero_ultimate(slot)
	local controller = ultimate and E:get_template(ultimate.controller_name)

	return power_hero_ultimate_cooldown(hero, hero_entity, controller) or 60
end

local function hero_ultimate_slot_button_icon(slot)
	local hero = selected_hero_ultimate(slot)

	return hero and power_hero_button_icon(hero) or "power_button_icons_0017"
end

local function hero_ultimate_slot_pointer(slot)
	local hero = selected_hero_ultimate(slot)

	if hero then
		return power_hero_pointer_icon(hero) or "pointer_user_power_0003",
			hero.info and hero.info.ultimate_pointer_style or "point"
	end

	return "pointer_user_power_0003", "point"
end

local hero_ultimate_slots = {1, 2, 3, "a", "s"}

local function hero_ultimate_button(slot)
	return game_gui["power_" .. tostring(slot)]
end

local function refreshable_hero_ultimates()
	local best_by_hero = {}
	local hero_order = {}
	local now = power_cooldown_now()

	for _, slot in ipairs(hero_ultimate_slots) do
		local hero, hero_entity, ultimate = selected_hero_ultimate(slot)
		local button = hero_entity and hero_ultimate_button(slot)

		if hero and button and button.mode == "cooldown" and button.cooldown_view and
			button.cooldown_view.start_ts then
			local elapsed = math.max(0, now - button.cooldown_view.start_ts)
			local remaining = math.max(0, (button.cooldown_time or 0) - elapsed)

			if remaining > 0 then
				local hero_key = hero.template_name or ultimate and ultimate.controller_name or tostring(slot)
				local current = best_by_hero[hero_key]

				if not current then
					table.insert(hero_order, hero_key)
				end

				if not current or remaining > current.remaining then
					best_by_hero[hero_key] = {
						button = button,
						remaining = remaining
					}
				end
			end
		end
	end

	local result = {}
	local total_remaining = 0

	for _, hero_key in ipairs(hero_order) do
		local candidate = best_by_hero[hero_key]

		table.insert(result, candidate.button)
		total_remaining = total_remaining + candidate.remaining
	end

	return result, total_remaining
end

local function ignores_linirea_revive(entity)
	return entity.ignore_linirea_true_might_revive or
		(entity.info and entity.info.is_here_pandas == 1)
end

local function hero_ultimate_slot_can_fire(slot, wx, wy, store)
	local _, hero_entity = selected_hero_ultimate(slot)
	local skills = hero_entity and hero_entity.hero and hero_entity.hero.skills
	local ultimate = skills and skills.ultimate

	if not ultimate or not ultimate.controller_name then
		return false
	end

	local controller = E:get_template(ultimate.controller_name)

	return controller and (not controller.can_fire_fn or controller.can_fire_fn(controller, wx, wy, store))
end

local function selected_power_slot_available(slot)
	if using_hero_rally() then
		return false
	end

	local option = selected_power_option(slot)

	return option.kind ~= "empty" or selected_hero_ultimate(slot) ~= nil
end

local function reinforcement_template_name(generation, level, variant)
	if generation == 3 then
		return string.format("soldier_re_%i_%i", level, variant)
	elseif generation == 1 or generation == 2 then
		return string.format("%s_%i", reinforcement_templates[generation][level + 1], variant)
	end
end

local function legacy_upgrade_level(generation, class)
	local store = game_gui.game.store
	local user_data = store.user_data or storage:load_slot()
	local levels = UPGR:get_user_levels(user_data, generation)

	return math.min(levels[class] or 0, UPGR.max_level or 5)
end

local function fireball_control_name(generation)
	local name = "power_fireball_control_g" .. tostring(generation)

	return E.entities and E.entities[name] and name or "power_fireball_control"
end

local function power_option_control_name(option)
	if option.controller_name then
		return option.controller_name
	elseif option.kind == "default_cataclysm" then
		return default_cataclysm_uses_thunder() and "user_power_1" or fireball_control_name(default_cataclysm_generation())
	elseif option.kind == "fireball" then
		return fireball_control_name(option.generation)
	elseif option.kind == "thunder" then
		return "power_thunder_control"
	elseif option.kind == "lightning" then
		return "power_lightning"
	elseif option.kind == "reinforcement" then
		local generation = option.default_generation and default_reinforcement_generation() or option.generation

		if generation == 4 then
			return "power_kr4_reinforcements_control"
		elseif generation == 5 then
			return "power_reinforcements_control_g5"
		elseif generation == 6 then
			return "power_reinforcements_control_g6"
		end

		return "power_reinforcements_control"
	end
end

local function cheat_item_use_count(option)
	local store = game_gui.game.store

	store.cheat_item_spell_uses = store.cheat_item_spell_uses or {}

	return store.cheat_item_spell_uses[option.item_name] or 0
end

local function cheat_item_has_uses(option)
	return not option.max_uses or cheat_item_use_count(option) < option.max_uses
end

local function record_cheat_item_use(option)
	if option.kind ~= "cheat_item" then
		return
	end

	local store = game_gui.game.store

	store.cheat_item_spell_uses = store.cheat_item_spell_uses or {}
	store.cheat_item_spell_uses[option.item_name] = cheat_item_use_count(option) + 1

	if not option.max_uses or store.cheat_item_spell_uses[option.item_name] < option.max_uses then
		return
	end

	for slot = 1, 3 do
		local selected = selected_power_option(slot)
		local button = slot == 1 and game_gui.power_1 or slot == 2 and game_gui.power_2 or game_gui.power_3

		if selected.kind == "cheat_item" and selected.item_name == option.item_name and button then
			button.exhausted = true
			button:set_mode("locked")
		end
	end
end

local function template_power_cooldown(template_name)
	local template = template_name and E:get_template(template_name)

	if not template then
		return nil
	end

	if template.power_cooldown_fn then
		return template.power_cooldown_fn()
	end

	return template.cooldown
end

local function selected_power_cooldown(slot)
	local hero, hero_entity, ultimate = selected_hero_ultimate(slot)

	if hero then
		local controller = E:get_template(ultimate.controller_name)

		return power_hero_ultimate_cooldown(hero, hero_entity, controller) or 60
	end

	local option = selected_power_option(slot)

	if option.kind == "reinforcement" then
		local generation = option.default_generation and default_reinforcement_generation() or option.generation

		if generation <= 3 then
			local level = legacy_upgrade_level(generation, "reinforcements")
			local template_name = reinforcement_template_name(generation, level, 1)
			local template = template_name and E:get_template(template_name)

			return spell_mode_cooldown(template and template.cooldown or template_power_cooldown("power_reinforcements_control") or 60)
		end
	end

	if type(option.cooldown) == "number" then
		return spell_mode_cooldown(option.cooldown)
	end

	return spell_mode_cooldown(template_power_cooldown(power_option_control_name(option)) or 60)
end

local function selected_power_button_icon(slot)
	local hero = selected_hero_ultimate(slot)

	if hero then
		return power_hero_button_icon(hero) or "power_button_icons_0017"
	end

	local option = selected_power_option(slot)

	if option.kind == "default_cataclysm" then
		return default_cataclysm_uses_thunder() and "power_button_icons_0017" or "fire_0001"
	elseif option.kind == "reinforcement" and option.default_generation and default_reinforcement_generation() == 3 then
		return "power_button_icons_0018"
	end

	return option.button_icon or option.icon
end

local function selected_power_button_scale(slot)
	if selected_hero_ultimate(slot) then
		return nil
	end

	local option = selected_power_option(slot)

	return option.button_scale
end

local function selected_power_pointer(slot)
	local hero = selected_hero_ultimate(slot)

	if hero then
		return power_hero_pointer_icon(hero) or "pointer_user_power_0003",
			hero.info and hero.info.ultimate_pointer_style or "point"
	end

	local option = selected_power_option(slot)

	if option.kind == "default_cataclysm" then
		if default_cataclysm_uses_thunder() then
			return "pointer_hero_power_0017", "area"
		end

		return "pointer_user_power_0001", "area"
	elseif option.kind == "reinforcement" and option.default_generation and default_reinforcement_generation() == 3 then
		return "pointer_hero_power_0018", "point"
	end

	return option.pointer_icon, option.pointer_style, option.pointer_scale
end

local function selected_power_can_fire(slot, wx, wy, store)
	if selected_hero_ultimate(slot) then
		return hero_ultimate_slot_can_fire(slot, wx, wy, store)
	end

	local option = selected_power_option(slot)

	if option.kind == "empty" then
		return false
	elseif option.kind == "mermaid_gift" then
		local buttons = refreshable_hero_ultimates()

		return #buttons > 0
	elseif option.kind == "lightning" then
		return U.find_entity_at_pos(store.entities, wx, wy, function(entity)
			return entity.enemy
		end) ~= nil
	elseif option.kind == "cheat_item" then
		if not cheat_item_has_uses(option) then
			return false
		end

		local controller = E:create_entity(power_option_control_name(option))

		if not controller then
			return false
		end

		controller.pos.x, controller.pos.y = wx, wy

		if controller.can_fire_fn then
			return controller.can_fire_fn(controller, wx, wy, store)
		end

		local selection = controller.user_selection

		return not selection or not selection.can_select_point_fn or
			selection.can_select_point_fn(controller, wx, wy, store)
	end

	local controller = E:get_template(power_option_control_name(option))

	if not controller then
		return false
	end

	local selection = controller and controller.user_selection

	return not selection or not selection.can_select_point_fn or selection.can_select_point_fn(controller, wx, wy, store)
end

local function unlock_user_power_handler(power_idx)
	if power_idx == 1 then
		if game_gui.game.store.level.locked_hero and selected_hero_ultimate(1) then
			game_gui.power_1:set_mode("locked")
		else
			game_gui.power_1:set_mode("unlocked")
		end

		if game_gui.power_a and game_gui.power_a.available and not game_gui.game.store.level.locked_hero then
			game_gui.power_a:set_mode("unlocked")
		end
	elseif power_idx == 2 then
		if game_gui.game.store.level.locked_hero and selected_hero_ultimate(2) then
			game_gui.power_2:set_mode("locked")
		else
			game_gui.power_2:set_mode("unlocked")
		end
	elseif power_idx == 3 and game_gui.power_3 then
		if game_gui.game.store.level.locked_hero and selected_hero_ultimate(3) then
			game_gui.power_3:set_mode("locked")
		else
			game_gui.power_3:set_mode("unlocked")
		end

		if game_gui.power_s and game_gui.power_s.available and not game_gui.game.store.level.locked_hero then
			game_gui.power_s:set_mode("unlocked")
		end
	end
end


--[[
local function unlock_user_power_handler(power_idx)
	if power_idx == 1 then
		game_gui.power_1:set_mode("unlocked")
	elseif power_idx == 2 then
		game_gui.power_2:set_mode("unlocked")
	elseif power_idx == 3 and game_gui.power_3 then
		game_gui.power_3:set_mode("unlocked")
	end
end
]]--

local function enemy_reached_goal_handler(enemy)
	if enemy and enemy.enemy and enemy.enemy.lives_cost > 0 then
		S:queue("GUILooseLife")
	end

	if enemy == game_gui.selected_entity then
		game_gui:deselect_entity()
	end
end

local function next_wave_ready_handler(group)
	log.debug("next_wave_ready_handler. group_idx:%s", group.group_idx)
	S:queue("GUINextWaveReady")
	game_gui:show_wave_flags(group)
	game_gui.next_wave_button.android_confirm_armed = false
	game_gui.next_wave_button:enable()

	if game_gui.game.store.level.show_next_wave_balloon then
		game_gui.game.store.level.show_next_wave_balloon = nil

		game_gui:show_balloon("TB_WAVE")
	end
end

local function next_wave_sent_handler(group)
	log.debug("next_wave_sent_handler")
	game_gui:hide_wave_flags()
	game_gui.next_wave_button.android_confirm_armed = false
	game_gui.next_wave_button:disable()
	game_gui:show_early_wave_reward()

	if group.group_idx == 1 then
		local locks = game_gui.game.store.level.locked_powers

		if not locks or #locks == 0 or locks[1] == false then
			unlock_user_power_handler(1)
		end

		if not locks or #locks == 0 or locks[2] == false then
			unlock_user_power_handler(2)
		end

		if not locks or #locks == 0 or locks[3] == false then
			unlock_user_power_handler(3)
		end

		S:stop_group("MUSIC")
		S:queue(string.format("MusicBattle_%02d", game_gui.game.store.level_idx))
	end

	S:queue("GUINextWaveIncoming")
end

local function early_wave_called_handler(group, reward, remaining_time)
	game_gui.power_1:early_wave_bonus(remaining_time)
	game_gui.power_2:early_wave_bonus(remaining_time)

	if game_gui.power_3 then
		game_gui.power_3:early_wave_bonus(remaining_time)
	end

	if game_gui.power_a and game_gui.power_a.available then
		game_gui.power_a:early_wave_bonus(remaining_time)
	end

	if game_gui.power_s and game_gui.power_s.available then
		game_gui.power_s:early_wave_bonus(remaining_time)
	end
end

local function hide_gui_handler()
	log.debug("hide_gui_handler")
	game_gui:hide()
end

local function show_gui_handler()
	log.debug("show_gui_handler")
	game_gui:show()
end

local function hero_added_handler(hero)
	log.debug("hero added: %s", hero.template_name)
	game_gui:add_hero(hero)
end

local function game_defeat_handler(store)
	game_gui:defeat()
end

local function game_victory_handler(store)
	game_gui:deselect_all()
	game_gui:disable_keys()
	timer:after(2, function()
		game_gui:victory()
	end)
end

local function boss_fight_start_handler(boss)
	game_gui:show_boss_health_bar(boss)
end

local function boss_fight_start_tweened_handler(boss, duration)
	local bar = game_gui:show_boss_health_bar(boss)

	if bar then
		bar.alpha = 0
		timer:tween(duration or 0.3, bar, {alpha = 1}, "in-cubic")
	end
end

local function boss_fight_end_handler()
	game_gui:hide_boss_health_bars()
end

local function boss_killed_handler(boss)
	game_gui:hide_boss_health_bars(boss)
end

local function wave_notification_handler(type, id, force)
	log.debug("wave_notification - type:%s, id:%s", type, id)

	if type == "icon" and game and game.store and game.store.level_mode_6 and kr6_enemy_notification_ids[id] then
		log.debug("suppressing KR6 enemy notification: %s", id)

		return
	end

	if type == "view" then
		game_gui:show_notification(id, force)
	elseif type == "icon" then
		game_gui:queue_notification_icon(id, force)
	end
end

local function show_balloon_handler(id, at_level_idx)
	log.debug("balloon:%s at_level_idx:%s", id, at_level_idx)

	if not at_level_idx or at_level_idx == game.store.level_idx then
		game_gui:show_balloon(id)
	end
end

local function show_balloon_tutorial_handler(id, hide)
	game_gui:show_balloon_tutorial(id, hide)
end

local function show_balloon_tutorial_pos_handler(id, hide, pos, text_override)
	game_gui:show_balloon_tutorial(id, hide, pos, text_override)
end

local function hide_balloon_tutorial_handler(id)
	game_gui:hide_balloon_tutorial(id)
end

local function show_achievement_handler(id)
	log.debug("achievement %s", id)
	game_gui:show_achievement(id)
end

local function block_random_power_handler(duration, style)
	game_gui:block_random_power(duration, style)
end

local function debug_ready_user_powers_handler()
	game_gui.power_1:set_mode("ready")
	game_gui.power_2:set_mode("ready")

	if game_gui.power_3 then
		game_gui.power_3:set_mode("ready")
	end

	if game_gui.power_a and game_gui.power_a.available then
		game_gui.power_a:set_mode("ready")
	end

	if game_gui.power_s and game_gui.power_s.available then
		game_gui.power_s:set_mode("ready")
	end
end

local function reduce_user_power_cooldown_handler(power_idx, amount)
	local power = game_gui["power_" .. tostring(power_idx)]

	if power and power.mode == "cooldown" and power.cooldown_view and amount and amount > 0 then
		power.cooldown_view.start_ts = power.cooldown_view.start_ts - amount
	end
end

local function debug_ready_plants_crystals_handler()
	for _, e in pairs(game_gui.game.simulation.store.entities) do
		if table.contains({
			"plant_magic_blossom",
			"plant_poison_pumpkin",
			"crystal_arcane",
			"crystal_unstable",
			"paralyzing_tree"
		}, e.template_name) then
			e.force_ready = true
		end
	end
end

local function sand_got_gold(pos, amount, source)
	local store = game_gui.game.store
	store.player_gold = store.player_gold + amount
	earnings_stats.record(store, source, amount)

	S:queue("GUICoins")
	local reward_fx = WaveRewardFx:new(amount)
	local px, py = game_gui:g2u(pos)
	reward_fx.pos.x, reward_fx.pos.y = px, py
	reward_fx.anchor.y = reward_fx.size.y + 2
	reward_fx.scale = v(0.7, 0.7)
	game_gui.layer_gui_hud:add_child(reward_fx)
end

local function hand_midas_got_enemy_gold(entity, amount)
	local store = game_gui.game.store
	local factor = tonumber(store.hand_of_midas_factor)

	if not factor or not amount or amount <= 0 then
		return
	end

	local bonus = km.round(amount * factor)

	if bonus <= 0 then
		return
	end

	store.player_gold = store.player_gold + bonus
	earnings_stats.record(store, "spell_hand_midas", bonus)
	S:queue("GUICoins")

	if entity and entity.pos then
		local hit_offset = entity.unit and entity.unit.hit_offset or v(0, 0)
		local reward_pos = v(entity.pos.x + hit_offset.x, entity.pos.y + hit_offset.y)
		local px, py = game_gui:g2u(reward_pos)
		local reward_fx = WaveRewardFx:new(bonus)

		reward_fx.pos.x, reward_fx.pos.y = px, py
		reward_fx.anchor.y = reward_fx.size.y + 2
		reward_fx.scale = v(0.7, 0.7)
		game_gui.layer_gui_hud:add_child(reward_fx)
	end
end

local function earnings_got_enemy_gold(entity, amount)
	earnings_stats.record_enemy_payout(game_gui.game.store, entity, amount)
end

local function earnings_pickpocket(source, amount)
	if not source then
		return
	end

	local store = game_gui.game.store

	if source.template_name == "hero_pirate" or source.template_name == "hero_pirate_2" then
		earnings_stats.record(store, "hero_pirate", amount)
	elseif source.template_name == "soldier_assassin" then
		earnings_stats.record(store, "tower_assassin", amount)
	elseif source.soldier and source.soldier.tower_id then
		local tower_id = source.soldier.tower_id
		local tower = type(tower_id) == "table" and tower_id or store.entities[tower_id]

		if tower and tower.template_name == "tower_assassin" then
			earnings_stats.record(store, "tower_assassin", amount)
		end
	end
end

local function remove_item_fx_view(field)
	local view = game_gui[field]

	if not view then
		return
	end

	if view.timer_h then
		timer:cancel(view.timer_h)
		view.timer_h = nil
	end

	if view.parent then
		view:remove_from_parent()
	end

	game_gui[field] = nil
end

local function new_item_overlay(field, color)
	remove_item_fx_view(field)

	local view = KView:new(V.v(game_gui.sw, game_gui.sh))

	view.colors.background = color
	view.alpha = 0
	view.propagate_on_click = true
	view.propagate_on_down = true
	view.propagate_on_up = true
	game_gui.item_fx_container:add_child(view)
	game_gui[field] = view

	return view
end

local function clear_item_fx()
	local container = game_gui.item_fx_container

	if not container then
		return
	end

	for _, field in ipairs({
		"item_winter_age_view",
		"item_veznan_wrath_view"
	}) do
		remove_item_fx_view(field)
	end
end

local function gem_timewarp_starts_handler()
	local view = new_item_overlay("item_gem_timewarp_view", {86, 116, 255, 145})
	local pulse_time = 1 / 3

	view.timer_h = timer:script(function(wait)
		timer:tween(pulse_time, view, {alpha = 1}, "out-sine")
		wait(pulse_time)
		timer:tween(pulse_time, view, {alpha = 0.6}, "in-sine")
		wait(pulse_time)
		timer:tween(pulse_time, view, {alpha = 1}, "out-sine")
		wait(pulse_time)
		timer:tween(pulse_time, view, {alpha = 0}, "in-sine")
		wait(pulse_time)

		if view.parent then
			view:remove_from_parent()
		end

		if game_gui.item_gem_timewarp_view == view then
			game_gui.item_gem_timewarp_view = nil
		end
	end)
end

local function wrath_of_elynia_starts_handler()
	local view = new_item_overlay("item_wrath_of_elynia_view", {190, 255, 230, 255})

	timer:tween(0.5, view, {alpha = 0.35294117647058826}, "linear")
end

local function wrath_of_elynia_ends_handler()
	local view = game_gui.item_wrath_of_elynia_view

	if not view then
		return
	end

	timer:tween(0.25, view, {alpha = 0}, "linear", function()
		if view.parent then
			view:remove_from_parent()
		end

		if game_gui.item_wrath_of_elynia_view == view then
			game_gui.item_wrath_of_elynia_view = nil
		end
	end)
end

local function hand_midas_starts_handler()
	local view = new_item_overlay("item_hand_midas_view", {255, 190, 45, 180})

	timer:tween(0.2, view, {alpha = 0.55}, "out-sine", function()
		timer:tween(0.45, view, {alpha = 0.28}, "in-out-sine")
	end)
end

local function hand_midas_ends_handler()
	local view = game_gui.item_hand_midas_view

	if not view then
		return
	end

	timer:tween(0.35, view, {alpha = 0}, "linear", function()
		if view.parent then
			view:remove_from_parent()
		end

		if game_gui.item_hand_midas_view == view then
			game_gui.item_hand_midas_view = nil
		end
	end)
end

local function winter_age_starts_handler()
	clear_item_fx()

	local tt = kui_db:get_table("item_winter_age", {sw = game_gui.sw, sh = game_gui.sh})
	local view = KView:new_from_table(tt)

	game_gui.item_fx_container:add_child(view)
	game_gui.item_winter_age_view = view
	view.alpha = 0
	view.hidden = false
	timer:tween(0.2, view, {alpha = 1}, "linear")
end

local function winter_age_ends_handler()
	local view = game_gui.item_winter_age_view

	if not view then
		return
	end

	timer:tween(0.2, view, {alpha = 0}, "linear", function()
		if view.parent then
			view:remove_from_parent()
		end

		if game_gui.item_winter_age_view == view then
			game_gui.item_winter_age_view = nil
		end
	end)
end

local function medical_kit_handler(pos, hearts)
	local store = game_gui.game.store
	local layer = game_gui.layer_gui_hud
	local ui_x, ui_y = game_gui:w2u(pos)
	local bag = KImageView:new("item_medical_kit_bag_0001")
	local lives_label = game_gui.hud_counters.lbl_lives
	local dest_x, dest_y = game_gui.hud_counters:view_to_view(lives_label.pos.x + 12, lives_label.pos.y + 12, layer)
	local delay_between = 12 / FPS
	local fly_time = 1

	hearts = hearts or 3
	bag.animation = {
		hide_at_end = false,
		prefix = "item_medical_kit_bag",
		from = 1,
		to = 50
	}
	bag:animation_frame(bag.animation, 0, false)
	bag.pos.x, bag.pos.y = ui_x, ui_y
	bag.anchor.x, bag.anchor.y = bag.size.x / 2, bag.size.y / 2
	layer:add_child(bag)

	for heart_index = 1, hearts do
		local heart = KImageView:new("item_medical_kit_heart")

		heart.pos.x, heart.pos.y = ui_x + 3, ui_y - 40
		heart.anchor.x, heart.anchor.y = heart.size.x / 2, heart.size.y / 2
		heart.hidden = true
		layer:add_child(heart)

		timer:after(heart_index * delay_between, function()
			heart.hidden = false
			timer:tween(fly_time, heart.pos, {x = dest_x}, "in-expo")
			timer:tween(fly_time, heart.pos, {y = dest_y}, "linear")
		end)
		timer:after(heart_index * delay_between + fly_time, function()
			if heart.parent then
				heart:remove_from_parent()
			end

			local hud_heart = KImageView:new("item_medical_kit_heart_HUD_0001")

			hud_heart.animation = {
				hide_at_end = false,
				prefix = "item_medical_kit_heart_HUD",
				from = 1,
				to = 7
			}
			hud_heart:animation_frame(hud_heart.animation, 0, false)
			hud_heart.pos.x, hud_heart.pos.y = dest_x, dest_y
			hud_heart.anchor.x, hud_heart.anchor.y = hud_heart.size.x / 2, hud_heart.size.y / 2
			layer:add_child(hud_heart)
			store.lives = store.lives + 1
			S:queue("ItemsMedicalKitHeartAdd")
			timer:after(7 / FPS, function()
				if hud_heart.parent then
					hud_heart:remove_from_parent()
				end
			end)
		end)
	end

	timer:after(4 / FPS + hearts * delay_between + 0.5, function()
		timer:tween(0.75, bag, {
			alpha = 0,
			pos = V.v(ui_x, ui_y + 40),
			r = -math.pi / 12
		}, "linear", function()
			if bag.parent then
				bag:remove_from_parent()
			end
		end)
	end)
end

local function veznan_wrath_starts_handler()
	clear_item_fx()

	local tt = kui_db:get_table("item_veznan_wrath", {sw = game_gui.sw, sh = game_gui.sh})
	local view = KView:new_from_table(tt)
	local overlay_dark = view:ci("layer_user_item_veznan_wrath_overlay_dark")

	game_gui.item_fx_container:add_child(view)
	game_gui.item_veznan_wrath_view = view

	if overlay_dark then
		overlay_dark.hidden = false
		overlay_dark.alpha = 0
		timer:tween(0.3, overlay_dark, {alpha = 0.39215686274509803}, "linear")
	else
		log.error("item_veznan_wrath dark overlay not found")
	end
end

local function veznan_wrath_enter_handler()
	local view = game_gui.item_veznan_wrath_view
	local veznan = view and view:ci("item_veznan_wrath_exo")

	if veznan then
		veznan.hidden = false
		veznan.ts = 0
	end
end

local function veznan_wrath_blink_handler()
	local view = game_gui.item_veznan_wrath_view
	local overlay_dark = view and view:ci("layer_user_item_veznan_wrath_overlay_dark")
	local overlay_green = view and view:ci("layer_user_item_veznan_wrath_overlay_green")

	if overlay_dark and overlay_green then
		if overlay_dark.hidden and overlay_green.hidden then
			overlay_dark.hidden = false
		else
			overlay_dark.hidden = not overlay_dark.hidden
			overlay_green.hidden = not overlay_green.hidden
		end
	end
end

local function veznan_wrath_stop_blink_handler()
	local view = game_gui.item_veznan_wrath_view
	local overlay_dark = view and view:ci("layer_user_item_veznan_wrath_overlay_dark")
	local overlay_green = view and view:ci("layer_user_item_veznan_wrath_overlay_green")

	if overlay_dark then
		overlay_dark.hidden = true
	end

	if overlay_green then
		overlay_green.hidden = true
	end
end

local function veznan_wrath_ends_handler()
	local view = game_gui.item_veznan_wrath_view

	if view and view.parent then
		view:remove_from_parent()
	end

	game_gui.item_veznan_wrath_view = nil
end

--[[
	["start-cinematic"] = function()
		game_gui:set_mode(GUI_MODE_CINEMATIC_LOCK)
	end,
	["end-cinematic"] = function()
		game_gui:set_mode(GUI_MODE_IDLE)
	end,
	]]

function start_cinematic_handler()
	game_gui:set_mode(GUI_MODE_CINEMATIC_LOCK)
end

function end_cinematic_handler()
	game_gui:set_mode(GUI_MODE_IDLE)
end

function game_gui:init(w, h, game)
	self.game = game
	self.w = w
	self.h = h

	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)
	local android_ui_scale = IS_ANDROID and (ANDROID_UI_SCALE or 1) or 1
	local android_widescreen = IS_ANDROID and ANDROID_WIDESCREEN_ENABLED ~= false and w / h > MAX_SCREEN_ASPECT

	if IS_ANDROID then
		local base_scale = scale

		scale = base_scale * android_ui_scale

		if android_widescreen then
			-- Widescreen is opt-in and only meaningful on an actually extra-wide
			-- device.  UI scale changes the coordinate system, not child offsets.
			sw = w / scale
			sh = h / scale
			origin = V.v(0, 0)
		else
			-- Preserve the legacy aspect-clamped viewport, including 4:3 tablets.
			sw = sw / android_ui_scale
			sh = sh / android_ui_scale
		end
	end

	self.sw = sw
	self.sh = sh
	self.gui_scale = scale
	self.android_ui_scale = android_ui_scale
	self.mode = GUI_MODE_IDLE
	self.manual_gui_hide = nil
	self.keys_disabled = nil

	local settings = storage:load_settings()

	self.pause_on_switch = settings.pause_on_switch
	self.key_shortcuts = shortcut_settings.load_context("game")

	local window = KWindow:new(V.v(sw, sh))

	self.window = window
	window.scale.x, window.scale.y = scale, scale
	window.colors.background = {
		0,
		0,
		0,
		0
	}
	window.font_scale = scale
	window.origin = origin
	GGLabel.static.font_scale = scale
	GGLabel.static.ref_h = self.ref_h

	local pickview = PickView:new(sw, sh)

	pickview.pos = v(0, 0)

	local towermenu = TowerMenu:new()

	towermenu.hidden = true

	local towertooltip = TowerMenuTooltip:new()

	towertooltip.hidden = true

	local rallyrange = RangeCircle:new("rally_circle")

	rallyrange.hidden = true

	local tower_range = RangeCircle:new("range_circle")

	tower_range.hidden = true

	local tower_range_upgrade = RangeCircle:new("range_circle")

	tower_range_upgrade.hidden = true

	--英雄距离显示

	if screen_map.user_data.true_melee_range == nil then
		screen_map.user_data.true_melee_range = false
	end

	local meleerange = RangeCircle:new("rally_circle")

    meleerange.hidden = true

    local rangedrange = RangeCircle:new("range_circle")

    rangedrange.hidden = true

	--
	local point_confirm = KImageView:new("confirm_feedback_0001")

	point_confirm.animation = {
		to = 11,
		prefix = "confirm_feedback",
		from = 1
	}
	point_confirm.hidden = true
	point_confirm.anchor = v(point_confirm.size.x / 2, point_confirm.size.y / 2)

	local rallyflag = KImageView:new("rally_feedback_0005")

	rallyflag.animation = {
		to = 30,
		prefix = "rally_feedback",
		from = 1
	}
	rallyflag.hidden = true
	rallyflag.anchor = v(rallyflag.size.x / 2, rallyflag.size.y / 2)

	local hud_bottom = HudBottomView:new(sw, sh)
	local hud_counters = HudCountersView:new()
	local boss_bar_container = KView:new(v(sw, sh))
	boss_bar_container.hidden = true

	boss_bar_container.propagate_on_click = true
	boss_bar_container.propagate_on_down = true
	boss_bar_container.propagate_on_up = true

	hud_counters.anchor = v(0, 0)
	hud_counters.pos = v(0, -22)
	hud_counters.scale = v(0.9, 0.9)

	local incoming_tooltip = IncomingTooltip:new()

	incoming_tooltip.hidden = true

	local mouse_pointer = MousePointer:new()

	mouse_pointer.hidden = true

	local hud_pause = HudPauseButton:new()

	hud_pause.anchor = v(hud_pause.size.x, 0)
	hud_pause.pos = v(sw + (IS_KR3 and 0 or -37), -21)
	hud_pause.scale = v(0.9, 0.9)

	local pauseview = PauseView:new()

	pauseview.anchor = v(pauseview.size.x / 2, pauseview.size.y / 2)
	pauseview.pos.x = self.sw / 2
	pauseview.hidden = true

	local hud_noti_queue = NotificationQueue:new()

	hud_noti_queue.anchor = v(0, 0)
	hud_noti_queue.pos = v(80, 100)
	hud_noti_queue.propagate_on_click = true

	local notiview = NotificationView:new()

	notiview.pos = v(self.sw / 2, self.sh / 2)
	notiview.hidden = true

	local victoryview = VictoryView:new(self.game.simulation.store.level_mode)

	victoryview.pos.x, victoryview.pos.y = self.sw / 2, self.sh / 3
	victoryview.anchor.x, victoryview.anchor.y = victoryview.size.x / 2, victoryview.size.y / 2
	victoryview.hidden = true

	local defeatview = DefeatView:new()

	defeatview.pos.x, defeatview.pos.y = self.sw / 2, 3 * self.sh / 7
	defeatview.anchor.x, defeatview.anchor.y = defeatview.size.x / 2, defeatview.size.y / 2
	defeatview.hidden = true

	local combat_stats_view = CombatStatsView:new(sw, sh)

	combat_stats_view.pos.x, combat_stats_view.pos.y = self.sw / 2, self.sh / 2
	combat_stats_view.anchor.x, combat_stats_view.anchor.y = combat_stats_view.size.x / 2, combat_stats_view.size.y / 2
	combat_stats_view.hidden = true

	local overlay = OverlayView:new(sw, sh)

	overlay.hidden = true

	local comic_transition = KView:new(V.v(sw, sh))

	comic_transition.colors.background = {
		0,
		0,
		0,
		255
	}

	if self.game.store.level.show_comic_idx then
		comic_transition.hidden = false
		comic_transition.alpha = 1

		timer:tween(0.5, comic_transition, {
			alpha = 0
		}, "out-linear", function()
			comic_transition.hidden = true
		end)
	else
		comic_transition.hidden = true
	end

	--流辉349 新增对防御塔的动态加载
	tower_menus = require("data.tower_menus_data")
	--user_data.liuhui.cheathero

	local user_data = storage:load_slot()

	local selected_holders = user_data.towers

	-- Load the configured tower pages.
	local tower_menu_json = map_data.tower_menu_json
	local tower_random_json = map_data.tower_random_json
	local nostalgic_classic = current_campaign_variant() == CAMPAIGN_VARIANT_NOSTALGIC_CLASSIC
	local generation_selection = tower_loadout.normalize(user_data)
	local holder_root = tower_menus.holder[1]
	local pages = {}
	local place_list = {1, 2, 3, 4, 11, 12, 5, 9, 13, 19, 15, 21, 16, 22, 18, 24, 25, 26, 27, 28}
	local legacy_place_list = {1, 2, 3, 4, 11, 5, 9, 12, 13, 19, 15, 21, 16, 22, 18, 24, 25, 26, 27, 28}
	-- Each row is archer, barrack, mage, artillery; holder_2's source menu
	-- happens to list mage and artillery before archer and barrack.
	local generation_holders = {
		{"holder_2", {6, 7, 4, 5}},
		{"holder_3", {4, 5, 6, 7}},
		{"holder_1", {4, 5, 6, 7}},
		{"holder_4", {4, 5, 6, 7}},
		{"kr6_legacy", {1, 2, 3, 4}}
	}

	local function add_page(page)
		if #page > 0 then
			table.insert(pages, page)
		end
	end

	local function legacy_page(enabled_generations)
		local page = {}

		for generation, holder in ipairs(generation_holders) do
			if enabled_generations[generation] then
				local source_menu = tower_menus[holder[1]][1]

				for _, source_index in ipairs(holder[2]) do
					local entry = table.deepclone(source_menu[source_index])

					entry.place = legacy_place_list[#page + 1]
					table.insert(page, entry)
				end
			end
		end

		return page
	end

	local function high_generation_page()
		local page = {}
		local tower_pick = km.clamp(1, 20, user_data.tower_pick or 20)

		for i = 1, math.min(tower_pick, #(selected_holders or {})) do
			local source_entry = tower_menu_json[selected_holders[i]]

			if source_entry then
				local entry = table.deepclone(source_entry)

				entry.place = tower_pick < 6 and i or place_list[i]
				table.insert(page, entry)
			end
		end

		return page
	end

	holder_root.page = 0
	holder_root.pages = pages

	local random_towers_enabled = user_data.liuhui.rand_tower ~= nil and user_data.liuhui.rand_tower > 0

	if nostalgic_classic then
		add_page(legacy_page({true, true, true, false}))
	elseif random_towers_enabled and user_data.liuhui.rand_tower_mode <= 3 then
		local random_indices = user_data.liuhui.rand_tower_mode == 0 and {2, 3, 4, 5}
			or user_data.liuhui.rand_tower_mode == 1 and {7, 8, 9, 10}
			or user_data.liuhui.rand_tower_mode == 2 and {1}
			or {6}
		local page = {}

		for _, random_index in ipairs(random_indices) do
			table.insert(page, table.deepclone(tower_random_json[random_index]))
		end

		add_page(page)
	elseif random_towers_enabled and user_data.liuhui.rand_tower_mode >= 4 then
		local page = {}

		for i, source_entry in ipairs(game.store.tmp_random_menu or {}) do
			local entry = table.deepclone(source_entry)

			entry.place = place_list[i]
			table.insert(page, entry)
		end

		add_page(page)
	else
		local tower_mode = km.clamp(0, 2, user_data.liuhui.use3tower_count or 0)

		if tower_mode ~= 2 then
			add_page(legacy_page(generation_selection))
		end

		if tower_mode ~= 1 then
			add_page(high_generation_page())
		end
	end

	if #pages == 0 then
		pages[1] = {}
	end

	local rank = #pages

	--确定作弊按钮
	local function add_holder_menu_entry(item, preferred_places)
		table.insert(pages[rank], table.deepclone(item))

		local entry_index = #pages[rank]
		local used_places = {}

		for i, entry in ipairs(pages[rank]) do
			if i ~= entry_index and entry.place then
				used_places[entry.place] = true
			end
		end

		for _, place in ipairs(preferred_places) do
			if not used_places[place] then
				pages[rank][entry_index].place = place
				return
			end
		end
	end

	if not nostalgic_classic and (user_data.liuhui.cheat or user_data.liuhui.cheathero) then
		add_holder_menu_entry(map_data.gold_json, {15, 14, 18, 20, 21, 22, 23, 24})
	end
	local cheat5_any = user_data.liuhui.cheat5 or user_data.liuhui.cheat5_special or user_data.liuhui.cheat5_dragon
	if not nostalgic_classic and cheat5_any then
		add_holder_menu_entry(map_data.cheat_g5_json, {21, 20, 22, 23, 24, 14, 18, 15})
	end
	if not nostalgic_classic and user_data.liuhui.cheat6 then
		add_holder_menu_entry(map_data.cheat_g6_json, {22, 23, 24, 21, 20, 18, 15, 14})
	end

	--[[
	if user_data.liuhui.cheat5 and user_data.tower_pick == 12 and (screen_map.user_data.liuhui.rand_tower == nil or screen_map.user_data.liuhui.rand_tower == 0) then
		table.remove(tower_menus["holder"][1]["pages"][rank],12)
	end
	if (user_data.liuhui.cheat or user_data.liuhui.cheathero) and user_data.tower_pick >= 11 and (screen_map.user_data.liuhui.rand_tower == nil or screen_map.user_data.liuhui.rand_tower == 0) then
		table.remove(tower_menus["holder"][1]["pages"][rank],11)
	end
	]]--

	if user_data.liuhui.cheathero then
		T("tower_hero_buy").tower.price = 0
	else
		T("tower_hero_buy").tower.price = 99999999
	end

	if user_data.liuhui.cheat5_dragon then
		T("g5_special_elemental").tower.price = 0
	else
		T("g5_special_elemental").tower.price = 99999999
	end

	if cheat5_any then
		T("g5_special_buy").tower.price = 0
	else
		T("g5_special_buy").tower.price = 99999999
	end

	if user_data.liuhui.cheat5 then
		T("tower_hero_buy_c").tower.price = 0
		T("tower_hero_buy_d").tower.price = 0
	else
		T("tower_hero_buy_c").tower.price = 99999999
		T("tower_hero_buy_d").tower.price = 99999999
	end

	T("tower_hero_buy_e").tower.price = user_data.liuhui.cheat6 and 0 or 99999999

	if user_data.liuhui.cheat5_special then
		T("g5_special_tower_buy").tower.price = 0
		T("g5_special_tower").tower.price = 0
	else
		T("g5_special_tower_buy").tower.price = 99999999
		T("g5_special_tower").tower.price = 99999999
	end
	--table.insert(tower_menus["holder"][1]["pages"], tower_menus["holder"][1]["pages"][2])

	local layer_gui = KView:new()

	layer_gui.id = "layer_gui"
	layer_gui.pos = v(0, 0)
	layer_gui.size = v(sw, sh)
	layer_gui.propagate_on_click = true
	layer_gui.propagate_on_down = true
	layer_gui.propagate_on_up = true

	local layer_gui_game = KView:new()

	layer_gui_game.id = "layer_gui_game"
	layer_gui_game.pos = v(0, 0)
	layer_gui_game.size = v(sw, sh)
	layer_gui_game.propagate_on_click = true
	layer_gui_game.propagate_on_down = true
	layer_gui_game.propagate_on_up = true

	local layer_gui_hud = KView:new()

	layer_gui_hud.id = "layer_gui_hud"
	layer_gui_hud.pos = v(0, 0)
	layer_gui_hud.size = v(sw, sh)
	layer_gui_hud.propagate_on_click = true
	layer_gui_hud.propagate_on_down = true
	layer_gui_hud.propagate_on_up = true

	local layer_gui_top = KView:new()

	layer_gui_top.id = "layer_gui_top"
	layer_gui_top.pos = v(0, 0)
	layer_gui_top.size = v(sw, sh)
	layer_gui_top.propagate_on_click = true
	layer_gui_top.propagate_on_down = true
	layer_gui_top.propagate_on_up = true

	local item_fx_container = KView:new(V.v(sw, sh))

	item_fx_container.id = "item_fx_container"
	item_fx_container.propagate_on_click = true
	item_fx_container.propagate_on_down = true
	item_fx_container.propagate_on_up = true

	layer_gui_game:add_child(rallyrange)
	layer_gui_game:add_child(tower_range)
	layer_gui_game:add_child(tower_range_upgrade)
	--英雄距离显示	
	layer_gui_game:add_child(meleerange)
    layer_gui_game:add_child(rangedrange)
	--	
	layer_gui_game:add_child(boss_bar_container)
	layer_gui_game:add_child(towertooltip)
	layer_gui_game:add_child(towermenu)
	layer_gui_game:add_child(incoming_tooltip)
	layer_gui_hud:add_child(item_fx_container)
	layer_gui_hud:add_child(hud_counters)
	layer_gui_hud:add_child(hud_pause)
	layer_gui_hud:add_child(hud_noti_queue)
	layer_gui_hud:add_child(hud_bottom)
	layer_gui_hud:add_child(mouse_pointer)
	layer_gui_top:add_child(overlay)
	layer_gui_top:add_child(notiview)
	layer_gui_top:add_child(pauseview)
	layer_gui_top:add_child(victoryview)
	layer_gui_top:add_child(defeatview)
	layer_gui_top:add_child(comic_transition)
	layer_gui_top:add_child(combat_stats_view)
	layer_gui:add_child(rallyflag)
	layer_gui:add_child(point_confirm)
	layer_gui:add_child(layer_gui_game)
	layer_gui:add_child(layer_gui_hud)
	layer_gui:add_child(layer_gui_top)

	local drag_view = DragEntityView:new(v(sw, sh))
	window:add_child(drag_view)
	window:add_child(pickview)
	window:add_child(layer_gui)

	self.drag_view = drag_view
	self.pickview = pickview
	self.towermenu = towermenu
	self.towertooltip = towertooltip
	self.rallyrange = rallyrange
	self.tower_range = tower_range
	self.tower_range_upgrade = tower_range_upgrade
	--英雄距离显示
	self.melee_range = meleerange
    self.ranged_range = rangedrange
	--	
	self.point_confirm = point_confirm
	self.rallyflag = rallyflag
	self.hud_bottom = hud_bottom
	self.hud_counters = hud_counters
	self.boss_bar_container = boss_bar_container
	self.boss_bars_disabled = true
	self.boss_health_bars = {}
	self.boss_bar_order = {}
	self.boss_bar_suppressed = {}
	self.boss_bar_scan_elapsed = 0
	self.hud_pause = hud_pause
	self.hud_noti_queue = hud_noti_queue
	self.mouse_pointer = mouse_pointer
	self.overlay = overlay
	self.pauseview = pauseview
	self.notiview = notiview
	self.victoryview = victoryview
	self.defeatview = defeatview
	self.combat_stats_view = combat_stats_view
	self.incoming_tooltip = incoming_tooltip
	self.comic_transition = comic_transition
	self.layer_gui = layer_gui
	self.layer_gui_game = layer_gui_game
	self.layer_gui_hud = layer_gui_hud
	self.layer_gui_top = layer_gui_top
	self.item_fx_container = item_fx_container
	self.heroes = {}
	self.infinite_ultimate_button = nil
	self.text_balloon_views = {}
	self.heroes_space_state_machine = 0

	signal.register("got-gold", sand_got_gold)
	signal.register("got-enemy-gold", hand_midas_got_enemy_gold)
	signal.register("got-enemy-gold", earnings_got_enemy_gold)
	signal.register("soldier-pickpocket", earnings_pickpocket)
	signal.register("enemy-reached-goal", enemy_reached_goal_handler)
	signal.register("next-wave-ready", next_wave_ready_handler)
	signal.register("next-wave-sent", next_wave_sent_handler)
	signal.register("early-wave-called", early_wave_called_handler)
	signal.register("hide-gui", hide_gui_handler)
	signal.register("show-gui", show_gui_handler)
	signal.register("start-cinematic", start_cinematic_handler)
	signal.register("end-cinematic", end_cinematic_handler)
	
	signal.register("hero-added", hero_added_handler)
	signal.register("game-defeat", game_defeat_handler)
	signal.register("game-victory", game_victory_handler)
	signal.register("boss_fight_start", boss_fight_start_handler)
	signal.register("boss_fight_start_tweened", boss_fight_start_tweened_handler)
	signal.register("boss_fight_end", boss_fight_end_handler)
	signal.register("boss-killed", boss_killed_handler)
	signal.register("unlock-user-power", unlock_user_power_handler)
	signal.register("wave-notification", wave_notification_handler)
	signal.register("show-balloon", show_balloon_handler)
	signal.register("show-balloon_tutorial", show_balloon_tutorial_handler)
	signal.register("show-balloon_tutorial-pos", show_balloon_tutorial_pos_handler)
	signal.register("hide-balloon-tutorial", hide_balloon_tutorial_handler)
	signal.register("got-achievement", show_achievement_handler)
	signal.register("block-random-power", block_random_power_handler)
	signal.register("debug-ready-user-powers", debug_ready_user_powers_handler)
	signal.register("reduce-user-power-cooldown", reduce_user_power_cooldown_handler)
	signal.register("debug-ready-plants-crystals", debug_ready_plants_crystals_handler)
	signal.register("gem-timewarp-starts", gem_timewarp_starts_handler)
	signal.register("wrath-of-elynia-starts", wrath_of_elynia_starts_handler)
	signal.register("wrath-of-elynia-ends", wrath_of_elynia_ends_handler)
	signal.register("hand-midas-starts", hand_midas_starts_handler)
	signal.register("hand-midas-ends", hand_midas_ends_handler)
	signal.register("winter-age-starts", winter_age_starts_handler)
	signal.register("winter-age-ends", winter_age_ends_handler)
	signal.register("medical-kit", medical_kit_handler)
	signal.register("veznan-wrath-starts", veznan_wrath_starts_handler)
	signal.register("veznan-wrath-enter-veznan", veznan_wrath_enter_handler)
	signal.register("veznan-wrath-blink", veznan_wrath_blink_handler)
	signal.register("veznan-wrath-stop-blink", veznan_wrath_stop_blink_handler)
	signal.register("veznan-wrath-ends", veznan_wrath_ends_handler)
end

local boss_bar_excluded_templates = {
	enemy_cannibal_volcano = true,
	enemy_cannibal_volcano_normal = true,
	enemy_demon_cerberus = true
}

local function boss_has_health(entity)
	local health = entity and entity.health

	return entity and entity.id and health and type(health.hp) == "number" and type(health.hp_max) == "number" and health.hp_max > 0 and health.hp > 0 and not health.dead and not entity.pending_removal
end

local function boss_has_lives_cost(entity)
	local enemy = entity and entity.enemy

	return enemy and type(enemy.lives_cost) == "number" and enemy.lives_cost >= 20
end

local function boss_is_attackable_on_path(entity)
	if not boss_has_health(entity) or boss_bar_excluded_templates[entity.template_name] then
		return false
	end

	local path = entity.nav_path
	local pos = entity.pos
	local health = entity.health
	local sprite = entity.render and entity.render.sprites and entity.render.sprites[1]
	local bans = entity.vis and entity.vis.bans or 0

	if entity.template_name == "eb_drow_queen" and entity.phase ~= "fighting" then
		return false
	end

	local first_boss = entity.template_name == "eb_juggernaut" or entity.template_name == "eb_efreeti" or entity.template_name == "eb_gnoll"
	local on_path = path and pos and P.paths and P.paths[path.pi] and type(path.ni) == "number"

	return on_path and (first_boss or P:is_node_valid(path.pi, path.ni) and P:valid_node_nearby(pos.x, pos.y))
		and not health.ignore_damage and band(health.immune_to or 0, DAMAGE_ALL_TYPES) ~= DAMAGE_ALL_TYPES
		and band(bans, bor(F_BLOCK, F_RANGED)) ~= bor(F_BLOCK, F_RANGED)
		and (not entity.ui or entity.ui.can_select ~= false)
		and (not entity.health_bar or not entity.health_bar.hidden)
		and (not sprite or not sprite.hidden)
end

function game_gui:show_boss_health_bar(entity)
	if not self.boss_bar_container or not entity or not entity.id or self.boss_bars_disabled then
		return nil
	end

	local id = entity.id

	self.boss_bar_suppressed[id] = nil

	if not boss_is_attackable_on_path(entity) then
		return nil
	end

	local bar = self.boss_health_bars[id]

	if not bar then
		bar = UnifiedBossHealthBar:new(entity)
		self.boss_health_bars[id] = bar
		table.insert(self.boss_bar_order, id)
		self.boss_bar_container:add_child(bar)
	else
		bar.entity = entity
		bar.alpha = 1
	end

	bar.pos = v(self.sw / 2, 68 + (#self.boss_bar_order - 1) * 52)

	return bar
end

function game_gui:hide_boss_health_bars(entity)
	if not self.boss_health_bars then
		return
	end

	local function remove(id)
		local bar = self.boss_health_bars[id]

		self.boss_bar_suppressed[id] = true

		if bar then
			bar:remove_from_parent()
			self.boss_health_bars[id] = nil
		end

		for i = #self.boss_bar_order, 1, -1 do
			if self.boss_bar_order[i] == id then
				table.remove(self.boss_bar_order, i)
			end
		end
	end

	if entity and entity.id then
		remove(entity.id)
	else
		for i = #self.boss_bar_order, 1, -1 do
			remove(self.boss_bar_order[i])
		end

		local store = self.game and self.game.store

		if store then
			for id, boss in pairs(store.entities) do
				if boss_has_lives_cost(boss) then
					self.boss_bar_suppressed[id] = true
				end
			end
		end
	end
end

function game_gui:sync_boss_health_bars(dt)
	local store = self.game and self.game.store

	if self.boss_bars_disabled or not store or not self.boss_health_bars then
		return
	end

	self.boss_bar_scan_elapsed = self.boss_bar_scan_elapsed + dt
	local should_scan = self.boss_bar_scan_elapsed >= 0.15

	for i = #self.boss_bar_order, 1, -1 do
		local id = self.boss_bar_order[i]
		local bar = self.boss_health_bars[id]

		if not bar or store.entities[id] ~= bar.entity or not boss_has_health(bar.entity) then
			if bar then
				bar:remove_from_parent()
				self.boss_health_bars[id] = nil
			end

			table.remove(self.boss_bar_order, i)
		end
	end

	if should_scan and not self.boss_bars_disabled then
		self.boss_bar_scan_elapsed = 0

		for id, entity in pairs(store.entities) do
			if boss_has_lives_cost(entity) and not self.boss_bar_suppressed[id] and not self.boss_health_bars[id] and boss_is_attackable_on_path(entity) then
				self:show_boss_health_bar(entity)
			end
		end

		for id in pairs(self.boss_bar_suppressed) do
			if not store.entities[id] then
				self.boss_bar_suppressed[id] = nil
			end
		end
	end

	for i, id in ipairs(self.boss_bar_order) do
		self.boss_health_bars[id].pos = v(self.sw / 2, 68 + (i - 1) * 52)
	end
end

function game_gui:destroy()
	self:set_android_virtual_r_down(false)
	timer:clear()

	self.heroes = nil
	self.text_balloon_views = nil
	self.boss_health_bars = nil
	self.boss_bar_order = nil
	self.boss_bar_suppressed = nil
	self.wave_flags = nil
	self.selected_entity = nil
	self.last_tower_hover = nil
	self.path_direction = nil
	self.marching_ants = nil

	self.window:destroy()

	self.window = nil
	self.game = nil
	self.swap_entity = nil

	SU.remove_references(self, KView)
	signal.remove("got-gold", sand_got_gold)
	signal.remove("got-enemy-gold", hand_midas_got_enemy_gold)
	signal.remove("got-enemy-gold", earnings_got_enemy_gold)
	signal.remove("soldier-pickpocket", earnings_pickpocket)
	signal.remove("enemy-reached-goal", enemy_reached_goal_handler)
	signal.remove("next-wave-ready", next_wave_ready_handler)
	signal.remove("next-wave-sent", next_wave_sent_handler)
	signal.remove("early-wave-called", early_wave_called_handler)
	signal.remove("hide-gui", hide_gui_handler)
	signal.remove("show-gui", show_gui_handler)
	signal.remove("hero-added", hero_added_handler)
	signal.remove("game-defeat", game_defeat_handler)
	signal.remove("game-victory", game_victory_handler)
	signal.remove("boss_fight_start", boss_fight_start_handler)
	signal.remove("boss_fight_start_tweened", boss_fight_start_tweened_handler)
	signal.remove("boss_fight_end", boss_fight_end_handler)
	signal.remove("boss-killed", boss_killed_handler)
	signal.remove("unlock-user-power", unlock_user_power_handler)
	signal.remove("wave-notification", wave_notification_handler)
	signal.remove("show-balloon", show_balloon_handler)
	signal.remove("show-balloon_tutorial", show_balloon_tutorial_handler)
	signal.remove("show-balloon_tutorial-pos", show_balloon_tutorial_pos_handler)
	signal.remove("hide-balloon-tutorial", hide_balloon_tutorial_handler)
	signal.remove("got-achievement", show_achievement_handler)
	signal.remove("block-random-power", block_random_power_handler)
	signal.remove("debug-ready-user-powers", debug_ready_user_powers_handler)
	signal.remove("reduce-user-power-cooldown", reduce_user_power_cooldown_handler)
	signal.remove("debug-ready-plants-crystals", debug_ready_plants_crystals_handler)
	signal.remove("gem-timewarp-starts", gem_timewarp_starts_handler)
	signal.remove("wrath-of-elynia-starts", wrath_of_elynia_starts_handler)
	signal.remove("wrath-of-elynia-ends", wrath_of_elynia_ends_handler)
	signal.remove("hand-midas-starts", hand_midas_starts_handler)
	signal.remove("hand-midas-ends", hand_midas_ends_handler)
	signal.remove("winter-age-starts", winter_age_starts_handler)
	signal.remove("winter-age-ends", winter_age_ends_handler)
	signal.remove("medical-kit", medical_kit_handler)
	signal.remove("veznan-wrath-starts", veznan_wrath_starts_handler)
	signal.remove("veznan-wrath-enter-veznan", veznan_wrath_enter_handler)
	signal.remove("veznan-wrath-blink", veznan_wrath_blink_handler)
	signal.remove("veznan-wrath-stop-blink", veznan_wrath_stop_blink_handler)
	signal.remove("veznan-wrath-ends", veznan_wrath_ends_handler)

	signal.remove("start-cinematic", start_cinematic_handler)
	signal.remove("end-cinematic", end_cinematic_handler)
end

function game_gui:update(dt)
	timer:update(dt)
	self:sync_boss_health_bars(dt)
	--英雄距离显示	
	local e = game_gui.selected_entity
	local a = screen_map.user_data.true_melee_range
	if e and a and not e.tower then
        if e.melee and e.melee.range then
            local ux, uy = game_gui:g2u(e.pos)
            game_gui:show_melee_range(ux, uy, e.melee.range)
        end
        if e.ranged and e.ranged.attacks[1] and e.ranged.attacks[1].max_range and not e.ranged.attacks[1].disabled then
            local ux, uy = game_gui:g2u(e.pos)
            game_gui:show_ranged_range(ux, uy, e.ranged.attacks[1].max_range)
        elseif e.timed_attacks and e.timed_attacks.list[1] and e.timed_attacks.list[1].max_range and not e.timed_attacks.list[1].disabled then
            local ux, uy = game_gui:g2u(e.pos)
            game_gui:show_ranged_range(ux, uy, e.timed_attacks.list[1].max_range)
        end
	else
		self:hide_melee_range()
		self:hide_ranged_range()
	end
	--	
	self.window:update(dt)

	local st = game_gui.swap_entity
	if game_gui.mode == GUI_MODE_SWAP_TOWER and st and st.tower and st.tower.blocked then
		game_gui:deselect_entity()

		game_gui.swap_entity = nil
	end
	--if game_gui.mode == GUI_MODE_IDLE or game_gui.mode == GUI_MODE_SWAP_TOWER then
	--[[
	if game_gui.mode == GUI_MODE_SWAP_TOWER then
		local x, y = game_gui.window:get_mouse_position()
		local lx, ly = game_gui._last_mouse_pos_x, game_gui._last_mouse_pos_y

		if x ~= lx or y ~= ly then
			game_gui._last_mouse_pos_x, game_gui._last_mouse_pos_y = x, y

			local wx, wy = game_gui:u2g(V.v(x, y))
			local ee = game_gui:entity_at_pos(wx, wy)
			local lastt = game_gui.last_tower_hover

			if ee and ee.tower and ee.tower.can_hover and ee ~= lastt then
				--game_gui:show_clickable_hover(ee)
			elseif lastt and (not ee or ee ~= lastt) then
				--game_gui:hide_clickable_hover()

				self.last_tower_hover = nil
			end
		end
	end
	]]--

end

function game_gui:show_clickable_hover(entity)
	if game_gui.game.store.paused then
		return
	end

	if self.last_tower_hover then
		if self.last_tower_hover ~= entity then
			self:hide_clickable_hover()
		elseif self.clickable_hover_controller and not self.clickable_hover_controller.done then
			return
		end
	end

	if not entity or not game_gui.game.store.entities[entity.id] then
		log.debug("clickable not in store. skipping hover")

		return
	end

	self.last_tower_hover = entity

	--if ISM.last_input ~= I_TOUCH then
	local h = E:create_entity("clickable_hover_circle_controller")

	if h ~= nil then
		h.target = entity

		self.game.simulation:insert_entity(h)

		self.clickable_hover_controller = h

		S:queue("GUIQuickMenuOver")
	end
	--end
end

function game_gui:hide_clickable_hover()
	if self.clickable_hover_controller then
		self.clickable_hover_controller.done = true
		self.clickable_hover_controller = nil
	end
end

local function view_is_inside(view, ancestor)
	while view do
		if view == ancestor then
			return true
		end

		view = view.parent
	end

	return false
end

function game_gui:android_wave_confirmation_target()
	if not IS_ANDROID then
		return nil
	end

	if self.next_wave_button and self.next_wave_button.android_confirm_armed then
		return self.next_wave_button
	end

	for _, flag in ipairs(self.wave_flags or {}) do
		if flag.android_confirm_armed then
			return flag
		end
	end

	return nil
end

function game_gui:cancel_android_wave_confirmation()
	if not IS_ANDROID then
		return
	end

	if self.next_wave_button then
		self.next_wave_button.android_confirm_armed = false
	end

	for _, flag in ipairs(self.wave_flags or {}) do
		local needs_cleanup = flag.android_confirm_armed or flag.marching_ants or self.incoming_tooltip and self.incoming_tooltip.owner_flag == flag

		flag.android_confirm_armed = false

		if needs_cleanup then
			flag:on_exit()
		end
	end
end

function game_gui:cancel_android_wave_confirmation_unless_hit(x, y)
	local target = self:android_wave_confirmation_target()

	if not target or not self.window then
		return
	end

	local window = self.window
	local sx = x - window.origin.x
	local sy = y - window.origin.y
	local wx, wy = window:screen_to_view(sx, sy)

	for _, hit in ipairs(window:hit_all(wx, wy)) do
		if view_is_inside(hit, target) then
			return
		end
	end

	self:cancel_android_wave_confirmation()
end

function game_gui:mousepressed(x, y, button, istouch)
	if IS_ANDROID and button == 1 then
		self:cancel_android_wave_confirmation_unless_hit(x, y)
	end

	if button == 2 and not DEBUG_RIGHT_CLICK then
		self:deselect_all()
	else
		self.window:mousepressed(x, y, button, istouch)
	end
end

function game_gui:mousereleased(x, y, button, istouch)
	self.window:mousereleased(x, y, button, istouch)

	-- Releasing outside the button must not leave Android in permanent
	-- fast-forward. KWindow only sends on_up to views under the release point.
	if IS_ANDROID and button == 1 then
		self:set_android_virtual_r_down(false)
	end
end

function game_gui:cancel_android_world_gesture()
	local window = self.window

	if window then
		local pressed_view = window._click_start_view

		if pressed_view and pressed_view.on_exit then
			pressed_view:on_exit(window._drag_view)
		end

		window._mouse_down_pos = nil
		window._click_start_view = nil
		window._drag_view = nil
		window._last_mouse_pos = nil
	end

	if self.drag_view and self.drag_view.is_pressing then
		self.drag_view:on_exit()
	end

	self:cancel_android_wave_confirmation()
	self:set_android_virtual_r_down(false)
end

function game_gui:wheelmoved(dx, dy)
	self.window:wheelmoved(dx, dy)
end

function game_gui:show_combat_stats()
	if self.combat_stats_view then
		self.combat_stats_view:show(self.game and self.game.store)
	end
end

function game_gui:set_android_virtual_r_down(down)
	if not IS_ANDROID then
		return
	end

	self.android_virtual_r_down = down == true

	if self.android_r_button then
		self.android_r_button.colors.tint = self.android_virtual_r_down and {
			180,
			180,
			180,
			255
		} or {
			255,
			255,
			255,
			255
		}
	end
end

function game_gui:keypressed(key, isrepeat)
	if isrepeat or self:is_dragging() then
		return
	end

	if DBG_SLIDE_EDITOR and game_gui.SEL_VIEW then
		local inc = 1
		local shift = love.keyboard.isDown("lshift")
		local ctrl = love.keyboard.isDown("lctrl")

		if shift then
			inc = 20
		end

		local av = game_gui.SEL_VIEW

		if ctrl then
			if key == "up" then
				av.size.y = av.size.y - inc
			elseif key == "down" then
				av.size.y = av.size.y + inc
			elseif key == "right" then
				av.size.x = av.size.x + inc
			elseif key == "left" then
				av.size.x = av.size.x - inc
			end
		elseif key == "up" then
			av.pos.y = av.pos.y - inc
		elseif key == "down" then
			av.pos.y = av.pos.y + inc
		elseif key == "right" then
			av.pos.x = av.pos.x + inc
		elseif key == "left" then
			av.pos.x = av.pos.x - inc
		end

		if key == "7" then
			av.r = av.r - 5 * math.pi / 180
		elseif key == "8" then
			av.r = av.r + 5 * math.pi / 180
		end

		if key == "-" then
			av.font_size = km.clamp(1, 200, av.font_size - 1)
			av.font = nil
		elseif key == "=" then
			av.font_size = km.clamp(1, 200, av.font_size + 1)
			av.font = nil
		end

		if key == "0" then
			if av.text_align == "left" then
				av.text_align = "center"
			elseif av.text_align == "center" then
				av.text_align = "right"
			elseif av.text_align == "right" then
				av.text_align = "left"
			end
		end

		if key == "h" then
			av.hidden = not av.hidden
		end

		if key == "9" then
			if not av.colors.background then
				av.colors.background = {
					0,
					200,
					200,
					150
				}
			else
				av.colors.background = nil
			end
		end

		if key == "space" or key == "return" then
			local out = string.format("pos=v(%s,%s), size=v(%s,%s), font_size=%s, text_align='%s'\n", av.pos.x, av.pos.y, av.size.x, av.size.y, av.font_size, av.text_align)

			log.debug("\n%s\n", out)

			if av and av.parent then
				local out = "---------------------------\n"

				for _, vv in ipairs(av.parent.children) do
					out = out .. string.format("pos=v(%s,%s), size=v(%s,%s), r=%s, font_size=%s, text_align='%s'\n", vv.pos.x, vv.pos.y, vv.size.x, vv.size.y, vv.r, vv.font_size, vv.text_align)
				end

				out = out .. "---------------------------\n"

				log.debug("\n%s\n", out)
			end
		end
	end

	if key == KEYPRESS_ESCAPE then
		if self.combat_stats_view and not self.combat_stats_view.hidden then
			self.combat_stats_view:hide()
		elseif not self.notiview.hidden then
			self.notiview:hide()
		elseif not self.victoryview.hidden then
			game_gui:go_to_map()
		elseif not self.defeatview.hidden then
			game_gui:go_to_map()
		elseif not self.pauseview.hidden then
			self.pauseview:hide()
		elseif self.selected_entity or self.mode ~= GUI_MODE_IDLE then
			self:deselect_all()
		elseif not self.keys_disabled then
			self.pauseview:show()
		end
	end

	if self.keys_disabled then
		return
	end

	local ks = self.key_shortcuts
	local hero_cycle_key = shortcut_settings.key(ks, "hero_cycle", 1, KEYPRESS_HERO_MAIN)

	if key ~= hero_cycle_key then
		self.heroes_space_state_machine = 0
	end
	if shortcut_settings.matches(ks, "pow_1", key) and not self.power_1.hidden and not self.power_1:is_disabled() then
		self.power_1:toggle_selection()
	elseif shortcut_settings.matches(ks, "pow_2", key) and not self.power_2.hidden and not self.power_2:is_disabled() then
		self.power_2:toggle_selection()
	elseif IS_KR3 and shortcut_settings.matches(ks, "pow_3", key) and not self.power_3.hidden and not self.power_3:is_disabled() then
		self.power_3:toggle_selection()
	elseif shortcut_settings.matches(ks, "pow_a", key) and self.power_a and not self.power_a.hidden and not self.power_a:is_disabled() then
		self.power_a:toggle_selection()
	elseif shortcut_settings.matches(ks, "pow_s", key) and self.power_s and not self.power_s.hidden and not self.power_s:is_disabled() then
		self.power_s:toggle_selection()
	elseif key == hero_cycle_key then
		local available_heroes = {}
		local heroes = self.heroes or {}

		for i = 1, math.min(hero_control_limit(), #heroes) do
			local hero = heroes[i]

			if hero and not hero:is_disabled() then
				table.insert(available_heroes, hero)
			end
		end

		if #available_heroes == 0 then
			self.heroes_space_state_machine = 0
		else
			local selected_index

			for i, hero in ipairs(available_heroes) do
				if self.selected_entity and hero.hero_id == self.selected_entity.id then
					selected_index = i

					break
				end
			end

			if selected_index == #available_heroes then
				self:deselect_entity()
				self.heroes_space_state_machine = 0
			else
				local next_index = (selected_index or 0) + 1

				available_heroes[next_index]:on_click(1, 0, 0)
				self.heroes_space_state_machine = next_index
			end
		end
	elseif shortcut_settings.matches(ks, "hero_1", key) then
		if self.heroes and self.heroes[1] then
			self.heroes[1]:on_click(1, 0, 0)
		end
	elseif shortcut_settings.matches(ks, "hero_2", key) then
		if self.heroes and self.heroes[2] then
			self.heroes[2]:on_click(1, 0, 0)
		end
	elseif shortcut_settings.matches(ks, "hero_3", key) then
		if self.heroes and self.heroes[3] then
			self.heroes[3]:on_click(1, 0, 0)
		end
	elseif shortcut_settings.matches(ks, "hero_4", key) then
		if self.heroes and self.heroes[4] then
			self.heroes[4]:on_click(1, 0, 0)
		end
	elseif shortcut_settings.matches(ks, "hero_5", key) then
		if self.heroes and self.heroes[5] then
			self.heroes[5]:on_click(1, 0, 0)
		end
	elseif shortcut_settings.matches(ks, "durax_clone", key) then
		local list = LU.list_entities(self.game.store.entities, "hero_durax_clone")

		table.sort(list, function(e1, e2)
			return e1.id < e2.id
		end)

		local sel_idx

		for i, e in ipairs(list) do
			if e == self.selected_entity then
				sel_idx = i

				break
			end
		end

		self:deselect_entity()

		local next_idx = sel_idx or ks._last_durax_clone_idx or 0

		for i = 1, #list do
			next_idx = km.zmod(next_idx + 1, #list)

			local e = list[next_idx]

			if e and e.ui and e.ui.can_click then
				ks._last_durax_clone_idx = next_idx
				e.ui.clicked = true

				self:select_entity(e)

				break
			end
		end
	elseif shortcut_settings.matches(ks, "wave", key) and not self.next_wave_button:is_disabled() then
		game_gui.game.store.send_next_wave = true
	end
end

function game_gui:keyreleased(key, isrepeat)
	return
end

function game_gui:focus(focus)
	if IS_ANDROID and not focus then
		self:set_android_virtual_r_down(false)
	end

	if focus or self.game.store.paused or self.gui_hud_hidden or DEBUG_IGNORE_FOCUS then
		return
	end

	if self.pause_on_switch and self.pauseview then
		self.pauseview:show()
	end
end

function game_gui:g2u(p, snap)
	if self.game.camera then
		local game = self.game
		local sx = (p.x * game.game_scale - game.camera.x) * game.camera.zoom / self.gui_scale + self.sw / 2
		local sy = ((game.ref_h - p.y) * game.game_scale - game.camera.y) * game.camera.zoom / self.gui_scale + self.sh / 2

		if snap then
			sx, sy = math.floor(sx + 0.5), math.floor(sy + 0.5)
		end

		return sx, sy
	end

	local sx = (p.x * self.game.game_scale + self.game.game_ref_origin.x - self.window.origin.x) / self.gui_scale
	local sy = (-1 * (p.y * self.game.game_scale + self.game.game_ref_origin.y - self.sh * self.gui_scale) - self.window.origin.y) / self.gui_scale

	if snap then
		sx, sy = math.floor(sx + 0.5), math.floor(sy + 0.5)
	end

	return sx, sy
end

function game_gui:u2g(s)
	if self.game.camera then
		local game = self.game
		local px = ((s.x - self.sw / 2) * self.gui_scale / game.camera.zoom + game.camera.x) / game.game_scale
		local py = game.ref_h - ((s.y - self.sh / 2) * self.gui_scale / game.camera.zoom + game.camera.y) / game.game_scale

		return px, py
	end

	local px = (s.x * self.gui_scale + self.window.origin.x - self.game.game_ref_origin.x) / self.game.game_scale
	local py = (self.sh * self.gui_scale - (s.y * self.gui_scale + self.window.origin.y) - self.game.game_ref_origin.y) / self.game.game_scale

	return px, py
end

function game_gui:entity_at_pos(x, y)
	return U.find_entity_at_pos(self.game.simulation.store.entities, x, y)
end

function game_gui:entity_by_id(id)
	return self.game.simulation.store.entities[id]
end

function game_gui:list_heroes()
	local result = table.filter(self.game.simulation.store.pending_inserts, function(_, e)
		return e.hero
	end)

	table.sort(result, function(e1, e2)
		return e1.id < e2.id
	end)

	return result
end

function game_gui:set_mode(mode)
	local new_mode = mode or GUI_MODE_IDLE

	log.debug("  CHANGING MODE: %s -> %s", self.mode, new_mode)

	self.mode = new_mode

	self.mouse_pointer:update_pointer(mode)
end

function game_gui:show_point_confirm(x, y)
	if self.timer then
		timer:cancel(self.timer)
	end

	self.point_confirm.pos.x, self.point_confirm.pos.y = x, y
	self.point_confirm.hidden = false
	self.point_confirm.alpha = 1
	self.point_confirm.ts = 0
	self.timer = timer:after(0.36666666666666664, function()
		self.point_confirm.hidden = true
		self.timer = nil
	end)
end

function game_gui:show_rally_flag(x, y)
	if self.timer then
		timer:cancel(self.timer)
	end

	self.rallyflag.pos.x, self.rallyflag.pos.y = x, y
	self.rallyflag.hidden = false
	self.rallyflag.alpha = 1
	self.rallyflag.ts = 0
	self.timer = timer:tween(1.5, self.rallyflag, {
		alpha = 0
	}, "out-quad", function()
		self.rallyflag.hidden = true
		self.timer = nil
	end)
end

function game_gui:show_rally_range(x, y, range)
	local rr = self.rallyrange
	local camera_zoom = self.game.camera and self.game.camera.zoom or 1

	rr.range_shown = range
	rr.pos.x, rr.pos.y = x, y
	rr.scale = v(range * self.game.game_scale * camera_zoom / (rr.actual_radius.x * self.gui_scale), range * self.game.game_scale * camera_zoom * ASPECT / (rr.actual_radius.y * self.gui_scale))
	rr.hidden = false
end

function game_gui:hide_rally_range()
	local rr = self.rallyrange

	rr.range_shown = nil
	rr.hidden = true
end

function game_gui:show_tower_range(x, y, range)
	local r = self.tower_range
	local camera_zoom = self.game.camera and self.game.camera.zoom or 1

	r.range_shown = range
	r.pos.x, r.pos.y = x, y
	r.scale = v(range * self.game.game_scale * camera_zoom / (r.actual_radius.x * self.gui_scale), range * self.game.game_scale * camera_zoom * ASPECT / (r.actual_radius.y * self.gui_scale))
	r.hidden = false
end

function game_gui:show_tower_range_upgrade(x, y, range)
	local r = self.tower_range_upgrade
	local camera_zoom = self.game.camera and self.game.camera.zoom or 1

	r.range_shown = range
	r.pos.x, r.pos.y = x, y
	r.scale = v(range * self.game.game_scale * camera_zoom / (r.actual_radius.x * self.gui_scale), range * self.game.game_scale * camera_zoom * ASPECT / (r.actual_radius.y * self.gui_scale))
	r.hidden = false
end

function game_gui:hide_tower_range_upgrade()
	self.tower_range_upgrade.hidden = true
	self.tower_range_upgrade.range_shown = nil
end

function game_gui:hide_tower_ranges()
	self.tower_range.hidden = true
	self.tower_range.range_shown = nil
	self.tower_range_upgrade.hidden = true
	self.tower_range_upgrade.range_shown = nil
end

--英雄距离显示
function game_gui:show_melee_range(x, y, range)
    local r = self.melee_range
	local camera_zoom = self.game.camera and self.game.camera.zoom or 1

    r.range_shown = range
    r.pos.x, r.pos.y = x, y
    r.scale.x = range * self.game.game_scale * camera_zoom / (r.actual_radius.x * self.gui_scale)
    r.scale.y = range * self.game.game_scale * camera_zoom * ASPECT / (r.actual_radius.y * self.gui_scale)
    r.hidden = false
end

function game_gui:show_ranged_range(x, y, range)
    local r = self.ranged_range
	local camera_zoom = self.game.camera and self.game.camera.zoom or 1

    r.range_shown = range
    r.pos.x, r.pos.y = x, y
    r.scale.x = range * self.game.game_scale * camera_zoom / (r.actual_radius.x * self.gui_scale)
    r.scale.y = range * self.game.game_scale * camera_zoom * ASPECT / (r.actual_radius.y * self.gui_scale)
    r.hidden = false
end
function game_gui:hide_melee_range()
    self.melee_range.hidden = true
    self.melee_range.range_shown = nil
end

function game_gui:hide_ranged_range()
    self.ranged_range.hidden = true
    self.ranged_range.range_shown = nil
end
--

function game_gui:show_invalid_point_cross(x, y)
	self.mouse_pointer:show_cross()
end

function game_gui:show_wave_flags(group)
	self.wave_flags = {}

	local store = self.game.store
	local flags_positions = store.level.locations.entrances

	for _, w in pairs(group.waves) do
		local item = flags_positions[w.path_index]

		if item and P:is_path_active(w.path_index) then
			local duration = group.group_idx > 1 and group.interval / FPS or nil
			local incoming_report = GU.incoming_wave_report(group, w.path_index, self.game.store.level_mode)

			if incoming_report and #incoming_report > 0 then
				local wf = WaveFlag:new(w.some_flying, duration, incoming_report)
				local wfx, wfy = self:g2u(item.pos)

				wf.pointer.r = item.r - math.pi / 2
				wf.hidden = false
				---来自重生的路径显示
				wf.path_index = w.path_index
				wf.world_pos = V.v(item.pos.x, item.pos.y)
				wf.world_r = item.r
				wf.world_len = item.len

				local vf = V.v(V.rotate(-item.r, 1, 0))
				local pf = V.v(wfx, wfy)

				wf.pos = self:find_flag_position(pf, vf, 50, item.len)

				self.layer_gui_game:add_child(wf)
				wf:order_below(self.towertooltip)
				table.insert(self.wave_flags, wf)
			end
		end
	end
end

function game_gui:hide_wave_flags()
	if self.wave_flags then
		for _, wf in pairs(self.wave_flags) do
			wf:hide()
		end

		self.wave_flags = nil
	end
end

function game_gui.c_change_mode(ctx, new_state)
	game_gui:set_mode(new_state)
end

function game_gui:c_swap_tower(ctx)
	--local e = ctx.entity or game_gui.last_tower_hover
	local e = ctx-- or game_gui.last_tower_hover
	--[[
	if not e or not e.ui then
		return
	end

	if not game_gui.game.store.entities[e.id] then
		log.debug("tower %s is not in entities", e.id)

		return
	end

	if e.ui and e.ui.click_proxies then
		for _, cp in pairs(e.ui.click_proxies) do
			if cp and cp.ui and cp.ui.can_click then
				log.debug("click proxied from (%s)%s to (%s)%s", e.id, e.template_name, cp.id, cp.template_name)

				cp.ui.clicked = true
			end
		end
	end

	if not e.ui.can_click then
		log.debug("cannot click tower %s: has ui.can_click == false", e.id)

		return
	end

	if not e.ui.can_select then
		log.debug("cannot select tower %s: has ui.can_select == false", e.id)

		return
	end

	if e == game_gui.selected_entity then
		log.debug("cannot select tower %s: is already selected", e.id)

		return
	end
	]]--

	e.ui.clicked = true
	local tower_selected = game_gui.swap_entity
	if e == game_gui.swap_entity then
		return
	end

	--game_gui:deselect_entity(ctx)
	game_gui:deselect_entity()

	local controller = E:create_entity("controller_tower_swap")

	controller.tower_1 = game_gui.swap_entity
	controller.tower_2 = e

	game_gui.game.simulation:insert_entity(controller)

	game_gui.swap_entity = nil

	game_gui:set_mode(GUI_MODE_IDLE)
	game_gui:hide_ghost_hover()
end

function game_gui:show_ghost_hover()
	local h = E:create_entity("tower_ghost_hover_controller")

	self.game.simulation:insert_entity(h)

	self.tower_ghost_hover_controller = h
end

function game_gui:hide_ghost_hover()
	if self.tower_ghost_hover_controller then
		self.game.simulation:remove_entity(self.tower_ghost_hover_controller)

		self.tower_ghost_hover_controller = nil
	end
end

function game_gui:find_flag_position(pf, vf, margin, len)
	local function intersection(p1, v1, p2, v2)
		local v1xv2 = V.cross(v1.x, v1.y, v2.x, v2.y)

		if math.abs(v1xv2) < 1e-05 then
			return nil
		else
			local sx, sy = V.sub(p2.x, p2.y, p1.x, p1.y)
			local m = V.cross(sx, sy, v2.x, v2.y) / v1xv2
			local pi = V.v(V.add(p1.x, p1.y, V.mul(m, v1.x, v1.y)))
			local a = V.angleTo(v1.x, v1.y, pi.x - p1.x, pi.y - p1.y)

			return pi, math.abs(a) < math.pi / 4
		end
	end

	local pt, vt = v(0, 15), v(1, 0)
	local pb, vb = v(0, self.sh - 15), v(1, 0)
	local pr, vr = v(self.sw, 0), v(0, 1)
	local pl, vl = v(0, 0), v(0, 1)
	local borders = {
		{
			pb,
			vb
		},
		{
			pt,
			vt
		},
		{
			pr,
			vr
		},
		{
			pl,
			vl
		}
	}
	local isects = {}

	for _, b in pairs(borders) do
		local pi, towards = intersection(pf, vf, b[1], b[2])

		if pi then
			table.insert(isects, pi)
		end
	end

	table.sort(isects, function(p1, p2)
		return V.dist2(pf.x, pf.y, p1.x, p1.y) < V.dist2(pf.x, pf.y, p2.x, p2.y)
	end)

	local pi = isects[1]

	if pi.y == pt.y or pi.y == pb.y then
		return pf
	else
		if len and len < V.dist(pf.x, pf.y, pi.x, pi.y) then
			local ox, oy = V.mul(len, vf.x, vf.y)

			return V.v(V.add(pf.x, pf.y, ox, oy))
		else
			local ox, oy = V.mul(-margin, vf.x, vf.y)

			pi.x, pi.y = V.add(pi.x, pi.y, ox, oy)
		end

		return pi
	end
end

function game_gui:select_entity(e)
	if e and e.ui and not e.ui.can_select then
		log.debug("cannot select: entity %s has ui.can_select = false", e.id)

		return
	end

	if self.selected_entity and e ~= self.selected_entity then
		self:deselect_entity()
	end

	-- A deselect request raised while this entity was not selected is stale.
	-- Keep requests raised for the currently selected entity, so transitions
	-- into and out of a broken-tower state still close the previous menu.
	if e and e ~= self.selected_entity then
		e.trigger_deselect = nil
	end

	--流辉349 新增换塔
	self.selected_entity = e

	if e.tower then
		if self.mode == GUI_MODE_SWAP_TOWER then
			--log.debug("start_swap_tower_1")
			self:c_swap_tower(e)
		else
			game_gui.towermenu:show()
		end
	elseif e.hero then
		if self.mode == GUI_MODE_SWAP_TOWER then
			game_gui:hide_ghost_hover()
		end
		self:set_mode(GUI_MODE_RALLY_HERO)
		self:select_hero(e.id)
	end

	game_gui.hud_bottom.infobar:show()

	if e.enemy or e.soldier or e.barrack then
		local m = E:create_entity("entity_marker_controller")

		m.target = e

		self.game.simulation:insert_entity(m)

		self.selected_entity_marker = m
	end
end

function game_gui:deselect_entity()
	if self.selected_entity and self.selected_entity.hero then
		self:deselect_heroes()
	end

	self.towermenu:hide()
	self.hud_bottom.infobar:hide()

	if self.selected_entity_marker then
		self.selected_entity_marker.done = true
	end
	--英雄距离显示
	self:hide_melee_range()
    self:hide_ranged_range()
	--
	if self.mode == GUI_MODE_SWAP_TOWER then
		game_gui:hide_ghost_hover()
	end
	self.selected_entity = nil

	self:set_mode()
end

function game_gui:deselect_powers()
	for _, p in pairs({
		self.power_1,
		self.power_2,
		self.power_3,
		self.power_a,
		self.power_s
	}) do
		if p and p.mode == "selected" then
			self:set_mode()
			p:set_mode("default")
		end
	end
end

function game_gui:w2u(p, snap)
	return self:g2u(p, snap)
end

function game_gui:deselect_all()
	local e = self.selected_entity

	if e and e.user_selection then
		e.user_selection.in_progress = false
		e.user_selection.new_pos = nil
	end

	self:deselect_powers()
	self:deselect_entity()
	self:hide_rally_range()
end

function game_gui:deselect_heroes()
	for _, h in pairs(self.heroes) do
		h:deselect()
	end
end

function game_gui:select_hero(id)
	if infinite_heroes.active(self.game and self.game.store) then
		for n, portrait in ipairs(self.heroes or {}) do
			if portrait.hero_id == id then self.hud_bottom:update_infinite_hero_page(math.ceil(n / 2)); break end
		end
	end
	for _, h in pairs(self.heroes) do
		if h.hero_id == id then
			h:select()
		end
	end
end

function game_gui:add_hero(hero_entity)
	local hero = self.hud_bottom:add_hero(hero_entity)

	table.insert(self.heroes, hero)
end

function game_gui:disable_keys()
	self.keys_disabled = true
end

function game_gui:enable_keys()
	if not self.manual_gui_hide then
		self.keys_disabled = nil
	end
end

function game_gui:hide()
	if self.manual_gui_hide then
		return
	end

	self.manual_gui_hide = true

	self:disable_keys()
	self:deselect_all()
	self.pickview:disable()
	self.hud_bottom:hide()
	self.hud_pause:hide()
	self.hud_counters:hide()
	self.boss_bar_container.hidden = true

	if self.wave_flags then
		for _, f in pairs(self.wave_flags) do
			f.hidden = true
		end
	end

	if self.hud_noti_queue then
		self.hud_noti_queue:hide()
	end
end

function game_gui:show()
	if not self.manual_gui_hide then
		return
	end

	self.manual_gui_hide = nil

	self:enable_keys()
	self.pickview:enable()
	self.hud_bottom:show()
	self.hud_pause:show()
	self.hud_counters:show()
	self.boss_bar_container.hidden = self.boss_bars_disabled or false

	if self.wave_flags then
		for _, f in pairs(self.wave_flags) do
			f.hidden = false
		end
	end

	if self.hud_noti_queue then
		self.hud_noti_queue:show()
	end
end

function game_gui:defeat()
	self.game.store.paused = true
	self.boss_bars_disabled = true
	self.boss_bar_container.hidden = true

	self:hide_wave_flags()
	self:deselect_all()
	self:disable_keys()
	self.defeatview:show()
end

function game_gui:victory()
	self.boss_bars_disabled = true
	self.boss_bar_container.hidden = true
	if self.pauseview and not self.pauseview.hidden then
		self.pauseview:hide()
	end

	self.game.store.paused = true

	self:deselect_all()

	if self.game.store.custom_game_outcome then
		self.game.done_callback(self.game.store.custom_game_outcome)
	else
		self.victoryview:show()
	end
end

local function save_active_hero_xp(store)
	if GS.hero_xp_ephemeral then
		return
	end

	local heroes = store.main_heroes or {}

	if #heroes == 0 then
		if store.main_hero then
			table.insert(heroes, store.main_hero)
		end
		if store.main1_hero then
			table.insert(heroes, store.main1_hero)
		end
	end

	if #heroes == 0 then
		return
	end

	local slot = storage:load_slot()

	for _, hero in ipairs(heroes) do
		local status = hero and hero.hero and slot.heroes and slot.heroes.status and slot.heroes.status[hero.template_name]

		if status then
			status.xp = math.max(status.xp or 0, hero.hero.xp or 0)
		end
	end

	storage:save_slot(slot)
end

function game_gui:go_to_map()
	save_active_hero_xp(self.game.store)

	S:stop_all()
	S:resume()
	signal.emit("game-quit", self.game.store)
	-- collectgarbage()
	local screen_map = require("screen_map")
	game_gui.game.done_callback({
		next_item_name = screen_map.map_view
	})
	-- collectgarbage()
end

function game_gui:restart_game()
	save_active_hero_xp(self.game.store)

	S:stop_all()
	S:resume()
	signal.emit("game-restart", self.game.store)
	game_gui.game:restart()
end

function game_gui:show_early_wave_reward()
	if game_gui.game.store.early_wave_reward > 0 then
		S:queue("GUICoins")

		local reward_fx = WaveRewardFx:new(game_gui.game.store.early_wave_reward)
		local x, y = self.window:get_mouse_position()
		local wx, wy = self.window:screen_to_view(x, y)

		wy = wy - reward_fx.size.y
		reward_fx.pos = V.v(wx, wy)

		self.layer_gui_hud:add_child(reward_fx)
		log.debug("show early wave reward at %s,%s", wx, wy)
	end
end

function game_gui:show_notification(id, force_show)
	self.notiview:show(id, nil, force_show)
end

function game_gui:queue_notification_icon(id, force)
	self.hud_noti_queue:add(id, force)
end

function game_gui:show_balloon(id)
	local b = TutorialBalloon:new(id)

	self.layer_gui_game:add_child(b)
end

function game_gui:show_balloon_tutorial(id, hide, world_pos_override, text_override)
	local bd = data.text_balloons and data.text_balloons[id]

	if not bd then
		log.error("Text balloon with id:%s not found", id)

		return
	end

	local b = self.text_balloon_views and self.text_balloon_views[id]

	if not b or b.remove_requested then
		b = TextBalloon:new(id, nil, text_override)

		if not b.valid then
			return
		end

		if world_pos_override and b.world_pos then
			b.world_pos = V.v(world_pos_override.x, world_pos_override.y)
		end

		self.text_balloon_views[id] = b

		if b.world_pos then
			self.layer_gui_game:add_child(b)
		elseif not b.add_as_child then
			self.layer_gui_hud:add_child(b)
		end
	end

	self.tutorial_balloon = b

	if hide then
		b:hide(true)
	else
		b:show()
	end
end

function game_gui:hide_balloon_tutorial(id)
	local b = id and self.text_balloon_views and self.text_balloon_views[id] or self.tutorial_balloon

	if b then
		b:remove(true)
	end

	if self.tutorial_balloon == b then
		self.tutorial_balloon = nil
	end
end

function game_gui:show_achievement(id)
	if self.manual_gui_hide then
		return
	end

	if features.hide_achievements_popup then
		log.debug("features.hide_achievements_popup enabled: not showing achievement popup")

		return
	end

	if not self.achievement_banner then
		self.achievement_banner = AchievementBanner:new()

		self.layer_gui_game:add_child(self.achievement_banner)
	end

	self.achievement_banner:queue(id)
end

function game_gui:block_random_power(duration, style)
	local powers = {}

	for i = 1, 3 do
		local p = game_gui["power_" .. i]

		if p and not p:is_disabled() and table.contains({
			"default",
			"unlocked",
			"ready"
		}, p.mode) then
			table.insert(powers, p)
		end
	end

	local p = table.random(powers)

	if p then
		log.debug("blocking power: %s", p)

		local pbb = PowerButtonBlock:new(p, duration, style)

		p:add_child(pbb)
		pbb:block()
	end
end

function game_gui:drag_entity_around_pos(x, y, margin)
	local found = {}
	for _, e in pairs(self.game.simulation.store.entities) do
		if e.pos and e.ui and e.ui.can_click and e.nav_grid and e.health and not e.health.dead then
			local r = e.ui.click_rect
			if x > e.pos.x + r.pos.x and x < e.pos.x + r.pos.x + r.size.x and y > e.pos.y + r.pos.y and y < e.pos.y + r.pos.y + r.size.y or x > e.pos.x + r.pos.x and x < e.pos.x + r.pos.x + r.size.x and y - margin > e.pos.y + r.pos.y and y - margin < e.pos.y + r.pos.y + r.size.y or x > e.pos.x + r.pos.x and x < e.pos.x + r.pos.x + r.size.x and y + margin > e.pos.y + r.pos.y and y + margin < e.pos.y + r.pos.y + r.size.y or x - margin > e.pos.x + r.pos.x and x - margin < e.pos.x + r.pos.x + r.size.x and y > e.pos.y + r.pos.y and y < e.pos.y + r.pos.y + r.size.y or x + margin > e.pos.x + r.pos.x and x + margin < e.pos.x + r.pos.x + r.size.x and y > e.pos.y + r.pos.y and y < e.pos.y + r.pos.y + r.size.y or x - margin > e.pos.x + r.pos.x and x - margin < e.pos.x + r.pos.x + r.size.x and y + margin > e.pos.y + r.pos.y and y + margin < e.pos.y + r.pos.y + r.size.y or x - margin > e.pos.x + r.pos.x and x - margin < e.pos.x + r.pos.x + r.size.x and y - margin > e.pos.y + r.pos.y and y - margin < e.pos.y + r.pos.y + r.size.y or x + margin > e.pos.x + r.pos.x and x + margin < e.pos.x + r.pos.x + r.size.x and y - margin > e.pos.y + r.pos.y and y - margin < e.pos.y + r.pos.y + r.size.y or x + margin > e.pos.x + r.pos.x and x + margin < e.pos.x + r.pos.x + r.size.x and y + margin > e.pos.y + r.pos.y and y + margin < e.pos.y + r.pos.y + r.size.y then
				if game_gui.selected_entity == e then
					return e
				end
				table.insert(found, e)
			end
		end
	end
	if #found == 0 then return nil end

	table.sort(found, function(e1, e2)
		if e1.ui.z == e2.ui.z then
			return e1.pos.y < e2.pos.y
		else
			return e1.ui.z > e2.ui.z
		end
	end)
	return found[1]
end

function game_gui:is_dragging()
	return self.mode == GUI_MODE_DRAG_ENTITY or self.mode == GUI_MODE_DRAG_RALLY_TOWER
end

DragEntityView = class("DragEntityView", KView)

function DragEntityView:initialize(size)
	DragEntityView.super.initialize(self, size)
	self.is_pressing = false
	self.path_direction = E:create_entity("controller_path_direction")

	game_gui.game.simulation:insert_entity(self.path_direction)
end

function DragEntityView:move_draggable(x, y)
	local e = self.selected_entity
	game_gui.selected_entity = e
	local prev_mode = game_gui.mode
	local success = false
	if not e then
		log.error("selected entity is nil")
	else
		if e.hero then
			game_gui.mode = GUI_MODE_RALLY_HERO
			success = game_gui.pickview:rally_hero(x, y)
		elseif e.soldier and e.reinforcement then
			game_gui.mode = GUI_MODE_RALLY_HERO
			success = game_gui.pickview:rally_reinforcement(x, y)
		else
			game_gui.mode = GUI_MODE_RALLY_TOWER
			success = game_gui.pickview:rally_tower(x, y)
		end
	end
	if not success then
		if prev_mode == GUI_MODE_DRAG_RALLY_TOWER then
			game_gui:hide_rally_range()
		end
		game_gui:deselect_entity()
		game_gui.mouse_pointer.last_cursor = nil
	end
	self:disable_drag_line()
end

function DragEntityView:on_down(button, x, y)
	if button == 1 then
		self.selected_tower = nil
		local wx, wy = game_gui:u2g(v(x, y))
		local e = game_gui:drag_entity_around_pos(wx, wy, DRAG_ENTITY_LOOKUP_MARGIN)
		if not e then return end
		self.is_pressing = true
		self.pressed_entity = e
		self.pressed_ipos = v(wx, wy)
	end
end

function DragEntityView:on_up(button, x, y)
	if not self.is_pressing or button ~= 1 then
		return
	end
	self.is_pressing = false
	if game_gui:is_dragging() then
		self:move_draggable(x, y)
		self.path_direction.first_move = nil
	end
	self.selected_entity = nil
	self.pressed_entity = nil
	--self:enable(false)
end

function DragEntityView:update(dt)
	if not self.is_pressing then return end

	local x, y = game_gui.window:get_mouse_position()
	x, y = game_gui.window:screen_to_view(x, y)
	local wx, wy = game_gui:u2g(v(x, y))
	local e = self.pressed_entity
	local pressed_start = self.pressed_ipos

	if game_gui:is_dragging() then
		self:enable_drag_line(e.pos, v(wx, wy), e)
	else
		local dist = V.dist(pressed_start.x, pressed_start.y, wx, wy)
		if dist < DRAG_ENTITY_THRESHOLD then return end
		game_gui:deselect_entity()
		self:disable_drag_line()
		if e.soldier and e.soldier.tower_id then
			local t_id = e.soldier.tower_id
			local t = game_gui.game.store.entities[t_id]
			if t and t.barrack then
				self.selected_entity = t
				local ux, uy = game_gui:g2u(v(t.pos.x + t.tower.range_offset.x, t.pos.y + t.tower.range_offset.y))
				game_gui:show_rally_range(ux, uy, t.barrack.rally_range)
				game_gui:set_mode(GUI_MODE_DRAG_RALLY_TOWER)
			else
				self:on_up(1, x, y)
			end
		elseif e.hero then
			self.selected_entity = e
			game_gui:set_mode(GUI_MODE_DRAG_ENTITY)
		elseif e.soldier and e.reinforcement then
			self.selected_entity = e
			game_gui:set_mode(GUI_MODE_DRAG_ENTITY)
			--self:on_up(1, x, y)
		else
			self:on_up(1, x, y)
		end
	end

	--if #self.touch_fingers == 1 and self.path_direction.selected_entity ~= nil then
	--	local start_pos = self.path_direction.start_pos
	--	local end_pos = self.path_direction.end_pos
	--
	--	if V.dist(start_pos.x, start_pos.y, end_pos.x, end_pos.y) > 100 then
	--		wid("infobar_view"):hide()
	--	end
	--end
end

function DragEntityView:on_exit()
	self:disable_drag_line()
	self.is_pressing = false
end

function DragEntityView:enable_drag_line(start_pos, end_pos, entity)
	self.path_direction.start_pos = start_pos
	self.path_direction.end_pos = end_pos
	self.path_direction.selected_entity = entity
--[[
	for _, v in pairs(wid("hero_portraits_view").children) do
		if not v:is_disabled() then
			v:disable(false)

			v._disabled_from_drag = true
		end
	end

	for _, v in pairs(wid("powers_view").children) do
		if not v._disabled then
			v:disable(false)

			v._disabled_from_drag = true
		end
	end

	for _, v in pairs(wid("bag_view").children) do
		if not v._disabled then
			v:disable(false)

			v._disabled_from_drag = true
		end
	end

	wid("pause_button")._disabled = true

	if game_gui.wave_flags then
		for _, wf in ipairs(game_gui.wave_flags) do
			wf.propagate_on_down = true
			wf.propagate_on_up = true
			wf.propagate_on_touch_down = true
			wf.propagate_on_touch_up = true
			wf.propagate_on_touch_move = true
			wf.propagate_on_enter = true
		end
	end

	for _, v in pairs(wid("alerts_view").children) do
		v.propagate_on_down = true
		v.propagate_on_up = true
		v.propagate_on_touch_down = true
		v.propagate_on_touch_up = true
		v.propagate_on_touch_move = true
		v.propagate_on_enter = true
	end

	for i = 1, 3 do
		local b = wid("power_button_" .. i)

		if b then
			b.propagate_on_down = true
			b.propagate_on_up = true
			b.propagate_on_touch_down = true
			b.propagate_on_touch_up = true
			b.propagate_on_touch_move = true
			b.propagate_on_enter = true
		end
	end]]
end

function DragEntityView:disable_drag_line()
	self.path_direction.selected_entity = nil
	self.path_direction.start_pos = nil
	self.path_direction.end_pos = nil
	self.path_direction.started_from_entity = nil
--[[
	for _, v in pairs(wid("hero_portraits_view").children) do
		if v._disabled_from_drag then
			v:enable(false)

			v._disabled_from_drag = nil
		end
	end

	for _, v in pairs(wid("powers_view").children) do
		if v._disabled_from_drag then
			v:enable(false)

			v._disabled_from_drag = nil
		end
	end

	for _, v in pairs(wid("bag_view").children) do
		if v._disabled_from_drag then
			v:enable(false)

			v._disabled_from_drag = nil
		end
	end

	wid("pause_button")._disabled = false

	if game_gui.wave_flags then
		for _, wf in ipairs(game_gui.wave_flags) do
			wf.propagate_on_enter = false
		end
	end

	for _, v in pairs(wid("alerts_view").children) do
		v.propagate_on_down = false
		v.propagate_on_up = false
		v.propagate_on_touch_down = false
		v.propagate_on_touch_up = false
		v.propagate_on_touch_move = false
		v.propagate_on_enter = false
	end

	for i = 1, 3 do
		local b = wid("power_button_" .. i)

		if b then
			b.propagate_on_down = false
			b.propagate_on_up = false
			b.propagate_on_touch_down = false
			b.propagate_on_touch_up = false
			b.propagate_on_touch_move = false
			b.propagate_on_enter = false
		end
	end]]
end

TimeRewardFx = class("TimeRewardFx", KView)

function TimeRewardFx:initialize(amount)
	TimeRewardFx.super.initialize(self)

	self.ts = 0

	local vd = KView:new()

	self:add_child(vd)

	local text_width = 0
	local letter_spacing = 0.7
	local offset = v(0, 0)
	local reward_string = string.format("-%is", amount)
	local img_fmt = "waveRewardTimer_00%02i"

	for i = 1, #reward_string do
		local c = string.sub(reward_string, i, i)
		local index

		index = c == "-" and 11 or c == "s" and 12 or tonumber(c)

		local v = KImageView:new(string.format(img_fmt, index))

		v.pos.x, v.pos.y = offset.x, offset.y

		local char_size = km.round(letter_spacing * v.size.x)

		offset.x = offset.x + char_size
		text_width = text_width + char_size

		vd:add_child(v)

		self.size.y = v.size.y
	end

	self.size.x = text_width + text_width * (1 - letter_spacing) / #reward_string
	self.anchor.x = self.size.x / 2
	self.alpha = 1

	timer:tween(1, self, {
		alpha = 0
	}, "out-quad", function()
		self:remove_from_parent()
	end)

	local dy = self.size.y / 3

	timer:tween(1, vd.pos, {
		y = -dy
	}, "out-quad")
end

WaveRewardFx = class("WaveRewardFx", KImageView)

function WaveRewardFx:initialize(reward)
	WaveRewardFx.super.initialize(self, "nextwave_coin_0001")

	self.animation = {
		to = 14,
		prefix = "nextwave_coin",
		from = 1
	}
	self.ts = 0

	local vd = KView:new()

	self:add_child(vd)

	local text_width = 0
	local offset = v(0, 0)
	local reward_string = string.format("+%i", reward)
	local img_fmt = "waveReward_00%02i"

	for i = 1, #reward_string do
		local c = string.sub(reward_string, i, i)
		local index

		index = c == "+" and 11 or tonumber(c)

		local v = KImageView:new(string.format(img_fmt, index))

		v.pos.x, v.pos.y = offset.x, offset.y

		local char_size = km.round(0.7 * v.size.x)

		offset.x = offset.x + char_size
		text_width = text_width + char_size

		vd:add_child(v)
	end

	vd.pos.x = self.size.x
	self.anchor.x = (self.size.x + text_width) / 2
	self.alpha = 1

	timer:tween(1.5, self, {
		alpha = 0
	}, "out-quad", function()
		self:remove_from_parent()
	end)
end

HeroPortrait = class("HeroPortrait", KButton)

function HeroPortrait:initialize(hero_entity)
	HeroPortrait.super.initialize(self, V.v(102, 101))

	self.colors.background = {
		0,
		0,
		0,
		0
	}
	self.disabled_tint_color = {
		200,
		200,
		200,
		255
	}
	self.hero_id = hero_entity.id
	self.portrait_image_name = hero_entity.info.hero_portrait
	self.portrait = KImageView:new(hero_entity.info.hero_portrait)
	local boss = infinite_heroes.get_boss(hero_entity.template_name)
	self.portrait._draw_self = boss and boss.portrait_draw or nil
	if boss then
		local scale = math.min(63 / self.portrait.size.x, 63 / self.portrait.size.y)
		self.portrait.scale = V.v(scale, scale)
		self.portrait.pos = V.v(19 + (63 - self.portrait.size.x * scale) / 2, 15 + (63 - self.portrait.size.y * scale) / 2)
	end
	self.portrait.propagate_on_click = true

	self:add_child(self.portrait)

	self.ov_cooldown = KView:new(V.v(63, 63))
	self.ov_cooldown.pos = v(19, 78)
	self.ov_cooldown.anchor = v(0, 0)
	self.ov_cooldown.colors.background = {
		0,
		0,
		0,
		150
	}
	self.ov_cooldown.propagate_on_click = true
	self.ov_cooldown.hidden = true

	self:add_child(self.ov_cooldown)

	self.frame = KImageView:new("heroPortrait_0001")
	self.frame.disabled_tint_color = {
		200,
		200,
		200,
		255
	}
	self.frame.propagate_on_click = true

	self:add_child(self.frame)

	self.level = GGLabel:new(V.v(16, 16))
	self.level.pos = v(66, IS_KR3 and 60 or 65)
	self.level.font_name = "TOONISH"
	self.level.font_size = 14
	self.level.colors.text = {
		255,
		255,
		255
	}
	self.level.text_align = "center"
	self.level.text = "1"
	self.level.propagate_on_click = true

	self:add_child(self.level)

	self.bar_health = KImageView:new("hero_portrait_bars_0001")
	self.bar_health.pos = IS_KR3 and v(22, 78) or v(23, 83)
	self.bar_health.anchor = v(0, 0)
	self.bar_health.propagate_on_click = true

	self:add_child(self.bar_health)

	self.bar_level = KImageView:new("hero_portrait_bars_0002")
	self.bar_level.pos = IS_KR3 and v(22, 84) or v(23, 89)
	self.bar_level.anchor = v(0, 0)
	self.bar_level.propagate_on_click = true

	self:add_child(self.bar_level)

	self.ov_selected = KImageView:new("heroPortrait_selected")
	self.ov_selected.hidden = true
	self.ov_selected.propagate_on_click = true

	self:add_child(self.ov_selected)

	self.ov_hover = KImageView:new("heroPortrait_0003")
	self.ov_hover.hidden = true
	self.ov_hover.propagate_on_click = true

	self:add_child(self.ov_hover)

	self.ov_levelup = KImageView:new("heroPortrait_0001")
	self.ov_levelup.propagate_on_click = true
	self.ov_levelup.animation = {
		to = 29,
		prefix = "heroPortrait",
		from = 2
	}
	self.ov_levelup.ts = 100

	self:add_child(self.ov_levelup)
	self:update_xp(hero_entity)
end

function HeroPortrait:set_style(style)
	local prefix

	prefix = style == "left" and "heroPortrait_L" or style == "right" and "heroPortrait_R" or "heroPortrait"

	self.frame:set_image(prefix .. "_0001")
	self.ov_hover:set_image(prefix .. "_0003")

	self.ov_levelup.animation.prefix = prefix
end

function HeroPortrait:select()
	self.ov_selected.hidden = false
end

function HeroPortrait:deselect()
	self.ov_selected.hidden = true
end

function HeroPortrait:hide()
	self._original_pos_y = self.pos.y

	timer:tween(1, self.pos, {
		y = self._original_pos_y + self.size.y
	}, "out-quad")
end

function HeroPortrait:show()
	timer:tween(1, self.pos, {
		y = self._original_pos_y
	}, "out-quad")
end

function HeroPortrait:on_enter()
	self.ov_hover.hidden = false
end

function HeroPortrait:on_exit()
	self.ov_hover.hidden = true
end

function HeroPortrait:on_click(button, x, y)
	if button == 2 and DEBUG_RIGHT_CLICK then
		local wx, wy = game_gui:u2g(V.v(x, y))

		DEBUG_RIGHT_CLICK(wx, wy)
	end

	local e = game_gui:entity_by_id(self.hero_id)
	-- 修复但丁鬼魂无法使用快捷键
	-- if e.health and e.health.dead then
	-- return
	-- end
	if self.mode == GUI_MODE_SWAP_TOWER then
		game_gui:hide_ghost_hover()
	end
	if e == game_gui.selected_entity then
		game_gui:deselect_entity()
	elseif e then
		game_gui:deselect_all()
		game_gui:select_entity(e)
	end
end

function HeroPortrait:update_xp(hero)
	local e = hero
	local levelup = self.hero_level ~= e.hero.level

	if e.hero.level == 10 then
		if self.hero_level ~= e.hero.level then
			self.bar_level.scale.x = 1
			self.hero_level = e.hero.level
			self.level.text = e.hero.level
		end
	else
		if self.hero_level ~= e.hero.level then
			log.debug("level up! %s - %s", e.id, e.template_name)

			self.hero_level = e.hero.level
			self.hero_xp_base = 0

			if e.hero.level > 1 then
				self.hero_xp_base = GS.hero_xp_thresholds[e.hero.level - 1]
			end

			self.hero_xp_next = GS.hero_xp_thresholds[e.hero.level]
			self.level.text = e.hero.level
			levelup = true
		end

		self.bar_level.scale.x = (e.hero.xp - self.hero_xp_base) / (self.hero_xp_next - self.hero_xp_base)
	end

	return levelup
end

function HeroPortrait:update(dt)
	local e = force_hero or game_gui:entity_by_id(self.hero_id)

	if not e or not e.hero then
		return
	end

	local new_level = self:update_xp(e)

	if new_level then
		self.ov_levelup.ts = 0
	end

	self.bar_health.scale.x = e.health.hp / e.health.hp_max

	if e.health.dead then
		if self.ov_cooldown.hidden then
			if game_gui.selected_entity == e then
				game_gui:deselect_entity()
			end

			if not e.info.hero_portrait_always_on then
				self:disable()
			end

			self.ov_cooldown.hidden = false
			self.ov_cooldown.scale.y = -1
			self.death_start_ts = game_gui.game.store.ts
		else
			local phase = km.clamp(0, 1, (game_gui.game.store.ts - self.death_start_ts) / e.health.dead_lifetime)

			self.ov_cooldown.scale.y = phase - 1
		end
	elseif not e.health.dead and (self:is_disabled() or not self.ov_cooldown.hidden) then
		self:enable()

		self.ov_cooldown.hidden = true
		self.ov_levelup.ts = 0
	end

	if self.portrait_image_name ~= e.info.hero_portrait then
		self.portrait:set_image(e.info.hero_portrait)

		self.portrait_image_name = e.info.hero_portrait
	end

	HeroPortrait.super.update(self, dt)
end

PowerButton = class("PowerButton", KButton)

function PowerButton:initialize(default_image, mask_image, image_scale)
	PowerButton.super.initialize(self, nil, default_image)

	if image_scale and image_scale ~= 1 then
		local image_width, image_height = self.size.x, self.size.y
		local mask_ss = mask_image and I:s(mask_image)
		local mask_scale = mask_ss and (mask_ss.ref_scale or 1) or 1
		local target_width = mask_ss and mask_ss.size[1] * mask_scale or image_width * image_scale
		local target_height = mask_ss and mask_ss.size[2] * mask_scale or image_height * image_scale

		self.image_scale = image_scale
		self:set_image(default_image, V.v(target_width, target_height))
		self.image_offset = V.v((target_width - image_width * image_scale) / 2,
			(target_height - image_height * image_scale) / 2)
	end

	self.anchor = v(0, self.size.y)
	self.animations = {}
	self.mode = "default"
	self.cooldown_time = 60
	self.selected_gui_mode = nil

	local cv = KView:new(V.v(self.size.x, self.size.y))

	cv.size = v(self.size.x - 18, self.size.y - 19)
	cv.pos = v(9, 10 + cv.size.y)
	cv.colors.background = {
		0,
		0,
		0,
		150
	}
	cv.hidden = true

	self:add_child(cv)

	self.cooldown_view = cv

	if mask_image then
		self.mask = KImageView:new(mask_image)

		self:add_child(self.mask)
	end
end

function PowerButton:set_mode(mode)
	if self.exhausted and mode ~= "locked" then
		mode = "locked"
	end

	self.mode = mode

	if self.animations[mode] then
		local tv = self.mask or self

		tv.animation = self.animations[mode]
		tv.ts = 0
	end

	self.cooldown_view.hidden = true

	self:enable()

	if mode == "locked" then
		self:disable()
	elseif mode == "cooldown" then
		self:disable()

		self.cooldown_view.hidden = false
		self.cooldown_view.start_ts = power_cooldown_now()
		self.cooldown_view.scale.x, self.cooldown_view.scale.y = 1, -1
	elseif mode == "ready" then
		S:queue("GUISpellRefresh")
	end
end

function PowerButton:update(dt)
	if self.mode == "cooldown" then
		local phase = km.clamp(0, 1, (power_cooldown_now() - self.cooldown_view.start_ts) / self.cooldown_time)

		self.cooldown_view.scale.y = phase - 1

		if phase == 1 then
			self:set_mode("ready")
		end
	end

	PowerButton.super.update(self, dt)
end

function PowerButton:on_click(button, x, y)
	self:toggle_selection(true)
end

function PowerButton:toggle_selection(keep_hover)
	if not self.infinite_hero_id then game_gui.infinite_ultimate_button = nil end
	if game_gui.mode == self.selected_gui_mode then
		game_gui:set_mode()

		if keep_hover then
			self:set_mode("highlighted")
		else
			self:set_mode("default")
		end

		signal.emit("power-deselected")
	else
		game_gui:deselect_all()
		game_gui:set_mode(self.selected_gui_mode)
		self:set_mode("selected")
		S:queue("GUISpellSelect")
		signal.emit("power-selected", self.selected_gui_mode)
	end
end

function PowerButton:fire(wx, wy)
	game_gui:set_mode()
	self:set_mode("cooldown")
end

function PowerButton:is_disabled()
	log.debug(" ---- mode: %s", self.mode)

	return self._disabled or self.mode == "locked" or self.mode == "cooldown"
end

function PowerButton:on_enter()
	if table.contains({
		"default",
		"unlocked",
		"ready"
	}, self.mode) then
		self:set_mode("highlighted")
	end
end

function PowerButton:on_exit()
	if self.mode == "highlighted" then
		self:set_mode("default")
	end
end

function PowerButton:early_wave_bonus(remaining_time)
	if self.mode == "cooldown" and remaining_time > 1 then
		self.cooldown_view.start_ts = self.cooldown_view.start_ts - remaining_time

		local reward_fx = TimeRewardFx:new(remaining_time)

		reward_fx.pos = V.v(self.size.x / 2, -2 * reward_fx.size.y / 3)

		self:add_child(reward_fx)
		log.debug("show early wave time reward at %s,%s", wx, wy)
	end
end

Power1Button = class("Power1Button", PowerButton)

function Power1Button:initialize()
	--if IS_KR3 then
	--判断是不是双英雄
	local ht = power_hero_template(1)
	local level_idx = game_gui.game.store.level_idx
	local user_data = storage:load_slot()
	local is_double = user_data and user_data.liuhui_hero and user_data.liuhui_hero.usedoublehero
	if is_double and ht and hero_game_ver(ht.template_name) >= 3 then
		local icon_name = power_hero_button_icon(ht) or "power_button_icons_0017"
		Power1Button.super.initialize(self, icon_name, "power_button_mask_0001")

		self.animations = {
			default = {
				to = 1,
				prefix = "power_button_mask",
				from = 1
			},
			highlighted = {
				to = 45,
				prefix = "power_button_mask",
				from = 45
			},
			cooldown = {
				to = 1,
				prefix = "power_button_mask",
				from = 1
			},
			locked = {
				to = 30,
				prefix = "power_button_mask",
				from = 30
			},
			unlocked = {
				to = 44,
				prefix = "power_button_mask",
				from = 30
			},
			selected = {
				to = 29,
				prefix = "power_button_mask",
				from = 29
			},
			ready = {
				to = 28,
				prefix = "power_button_mask",
				from = 1,
				post = {
					1
				}
			}
		}
	--3/5代都给闪电
	elseif level_idx <= GS.last_level3 or level_idx == 81 or level_idx == 82 or (level_idx > GS.jnum5 and level_idx <= GS.last_level5) then
		--if ht and hero_game_ver(ht.template_name) < 3 then
		Power1Button.super.initialize(self, "power_button_icons_0017", "power_button_mask_0001")

		local mask_prefix = "power_button_mask"

		self.animations = {
			default = {
				to = 1,
				from = 1,
				prefix = mask_prefix
			},
			highlighted = {
				to = 45,
				from = 45,
				prefix = mask_prefix
			},
			cooldown = {
				to = 1,
				from = 1,
				prefix = mask_prefix
			},
			locked = {
				to = 30,
				from = 30,
				prefix = mask_prefix
			},
			unlocked = {
				to = 44,
				from = 30,
				prefix = mask_prefix
			},
			selected = {
				to = 29,
				from = 29,
				prefix = mask_prefix
			},
			ready = {
				to = 28,
				from = 1,
				prefix = mask_prefix,
				post = {
					1
				}
			}
		}
	else
		Power1Button.super.initialize(self, "fire_0001", "power_button_mask_0001")
		local mask_prefix = "power_button_mask"
		self.animations = {
			default = {
				to = 1,
				from = 1,
				prefix = mask_prefix
			},
			highlighted = {
				to = 45,
				from = 45,
				prefix = mask_prefix
			},
			cooldown = {
				to = 1,
				from = 1,
				prefix = mask_prefix
			},
			locked = {
				to = 30,
				from = 30,
				prefix = mask_prefix
			},
			unlocked = {
				to = 44,
				from = 30,
				prefix = mask_prefix
			},
			selected = {
				to = 29,
				from = 29,
				prefix = mask_prefix
			},
			ready = {
				to = 28,
				from = 1,
				prefix = mask_prefix,
				post = {
					1
				}
			}
		}
	end

	self.selected_gui_mode = GUI_MODE_POWER_1

	self:set_mode("locked")
end

--fire函数和图标是分开的，需要分开改
function Power1Button:fire(wx, wy)
	local hero = nil
	local he = nil
	local user_data = storage:load_slot()
	local is_double = user_data and user_data.liuhui_hero and user_data.liuhui_hero.usedoublehero
	local level_idx = game_gui.game.store.level_idx

	--[[
	if level_idx >= 150 and level_idx <= 201 then
		local e = E:create_entity("power_soul_impact_control")

		e.pos.x, e.pos.y = wx, wy
		self.cooldown_time = e.cooldown or self.cooldown_time
		Power1Button.super.fire(self, wx, wy)
		game_gui.game.simulation:insert_entity(e)
		signal.emit("power-used", 1)

		return
	end
	]]

	if is_double then
		hero, he = power_hero_template(1)
	end
	if is_double and hero and hero_game_ver(hero.template_name) >= 3 then
		
		if he then
			local u = he.hero.skills.ultimate
			local e = E:create_entity(u.controller_name)

			self.cooldown_time = power_hero_ultimate_cooldown(hero, he, e) or self.cooldown_time
			--print("cooldown_time is"..self.cooldown_time)

			e.pos.x, e.pos.y = wx, wy
			e.owner = he
			e.source_id = he.id
			e.level = u.level

			Power1Button.super.cooldown_time = self.cooldown_time
			Power1Button.super.fire(self, wx, wy)
			game_gui.game.simulation:insert_entity(e)
			--大招效果
			if hero_group_ver(hero.template_name) == 2 then
				local upg = true
				if upg then
					for _, e in pairs(game_gui.game.store.entities) do
						if e.enemy and band(e.vis.bans, F_MOD) == 0 then
							local mod = E:create_entity("mod_upgrade_alliance_display_of_true_might_dark_army")

							mod.modifier.target_id = e.id

							game_gui.game.simulation:insert_entity(mod)
						end
					end

					local overlay = E:create_entity("decal_upgrade_alliance_display_of_true_might_dark_army_overlay")

					overlay.tween.ts = game_gui.game.store.tick_ts
					overlay.pos = v(512, 384)

					game_gui.game.simulation:insert_entity(overlay)
					S:queue("UpgradeDisplayOfTrueMightDarkArmy")
				end
			elseif hero_group_ver(hero.template_name) == 1 then
				local upg = true
				if upg then
					for _, e in pairs(game_gui.game.store.entities) do
						if e.hero then
							if e.health.hp > 0 then
								e.health.hp = e.health.hp_max

								local mod = E:create_entity("mod_upgrade_alliance_display_of_true_might_linirea")

								mod.modifier.target_id = e.id

								game_gui.game.simulation:insert_entity(mod)
								
							end
						elseif e.soldier and e.vis and band(e.vis.bans, F_MOD) == 0 then
							if e.health.hp <= 0 then
								if e.info.is_here_pandas and e.info.is_here_pandas == 1 then
									--empty
								else
									e.health.dead = true
									--queue_remove(game_gui.game.store, e)
									game_gui.game.simulation:queue_remove_entity(e)
								end
							else
								e.health.hp = e.health.hp_max

								local mod = E:create_entity("mod_upgrade_alliance_display_of_true_might_linirea")

								mod.modifier.target_id = e.id

								game_gui.game.simulation:insert_entity(mod)
							end
						end
					end

					local overlay = E:create_entity("decal_upgrade_alliance_display_of_true_might_linirea_overlay")

					overlay.tween.ts = game_gui.game.store.tick_ts
					overlay.pos = v(512, 384)

					game_gui.game.simulation:insert_entity(overlay)
					S:queue("UpgradeDisplayOfTrueMightLinirea")
				end
			end

			signal.emit("power-used", 1)
			self.cooldown_time = e.cooldown or self.cooldown_time
		else 
		end
	else
		if level_idx <= GS.last_level3 or level_idx == 81 or level_idx == 82 or (level_idx > GS.jnum5 and level_idx <= GS.last_level5) then
			local e = E:create_entity("user_power_1")
			e.pos.x, e.pos.y = wx, wy
			Power1Button.super.fire(self, wx, wy)
			game_gui.game.simulation:insert_entity(e)
			signal.emit("power-used", 1)
		else
			local e = E:create_entity("power_fireball_control")
			--local e = E:create_entity("user_power_4")
			e.pos.x, e.pos.y = wx, wy
			Power1Button.super.fire(self, wx, wy)
			game_gui.game.simulation:insert_entity(e)
			signal.emit("power-used", 1)
		end
	end

end

Power2Button = class("Power2Button", PowerButton)

function Power2Button:initialize()

local level_idx = game_gui.game.store.level_idx	
if level_idx <= GS.last_level3 or level_idx == 81 or level_idx == 82 then	
	-- if IS_KR3 then
	Power2Button.super.initialize(self, "power_button_icons_0018", "power_button_mask_0001")

	local mask_prefix = "power_button_mask"

	local level_idx = game_gui.game.store.level_idx

	self.animations = {
		default = {
			to = 1,
			from = 1,
			prefix = mask_prefix
		},
		highlighted = {
			to = 45,
			from = 45,
			prefix = mask_prefix
		},
		cooldown = {
			to = 1,
			from = 1,
			prefix = mask_prefix
		},
		locked = {
			to = 30,
			from = 30,
			prefix = mask_prefix
		},
		unlocked = {
			to = 44,
			from = 30,
			prefix = mask_prefix
		},
		selected = {
			to = 29,
			from = 29,
			prefix = mask_prefix
		},
		ready = {
			to = 28,
			from = 1,
			prefix = mask_prefix,
			post = {
				1
			}
		}
	}
else
	Power2Button.super.initialize(self, "reinforcements_0001", "power_button_mask_0001")

	local mask_prefix = "power_button_mask"
	
	self.animations = {
		default = {
			to = 1,
			from = 1,
			prefix = mask_prefix
		},
		highlighted = {
			to = 45,
			from = 45,
			prefix = mask_prefix
		},
		cooldown = {
			to = 1,
			from = 1,
			prefix = mask_prefix
		},
		locked = {
			to = 30,
			from = 30,
			prefix = mask_prefix
		},
		unlocked = {
			to = 44,
			from = 30,
			prefix = mask_prefix
		},
		selected = {
			to = 29,
			from = 29,
			prefix = mask_prefix
		},
		ready = {
			to = 28,
			from = 1,
			prefix = mask_prefix,
			post = {
				1
			}
		}
	}
	--[[
	self.animations = {
		default = {
			to = 1,
			prefix = "reinforcements",
			from = 1
		},
		highlighted = {
			to = 2,
			prefix = "reinforcements",
			from = 2
		},
		cooldown = {
			to = 1,
			prefix = "reinforcements",
			from = 1
		},
		locked = {
			to = 30,
			prefix = "reinforcement_ready",
			from = 30
		},
		unlocked = {
			to = 44,
			prefix = "reinforcement_ready",
			from = 30
		},
		selected = {
			to = 29,
			prefix = "reinforcement_ready",
			from = 29
		},
		ready = {
			to = 28,
			prefix = "reinforcement_ready",
			from = 1,
			post = {
				1
			}
		}
	}
	]]--
end

	self.selected_gui_mode = GUI_MODE_POWER_2

	self:set_mode("locked")
end

function Power2Button:fire(wx, wy)
	local level_idx = game_gui.game.store.level_idx
	local user_data = game_gui.game.store.user_data or screen_map.user_data or storage:load_slot()
	local re_level = math.min(UPGR.levels.reinforcements or 0, UPGR.max_level or 5)

	if level_idx >= 150 and level_idx <= 201 then
		local e = E:create_entity("power_kr4_reinforcements_control")
		local g4_level = generation_upgrades.level(user_data, "g4_reinforcements")

		e.pos.x, e.pos.y = wx, wy
		e.reinforcement_level = g4_level
		e.branch = generation_upgrades.g4_reinforcement_branch(user_data)
		e.extra_count = user_data.reinforcement_count and user_data.reinforcement_count ~= 0
		e.pit_lord_chance = g4_level >= 5 and 0.3 or 0
		self.cooldown_time = e.cooldown or self.cooldown_time
		Power2Button.super.fire(self, wx, wy)
		game_gui.game.simulation:insert_entity(e)
		signal.emit("power-used", 2)

		return
	end

	Power2Button.super.fire(self, wx, wy)

	local i = math.random(1, 3)
	local re_str = ""
	local re1 = { "re1_farmer",
				  "re1_farmer_well_fed",
				  "re1_conscript",
				  "re1_warrior",
				  "re1_legionnaire",
				  "re1_legionnaire_ranged" }
	local re2 = { "re2_farmer",
				  "re2_farmer_well_fed",
				  "re2_conscript",
				  "re2_warrior",
				  "re2_legionnaire",
				  "re2_legionnaire_ranged" }				  

	if level_idx <= GS.last_level3 or level_idx == 81 or level_idx == 82 then
		re_str = "soldier_re_" .. re_level .. "_"
	elseif level_idx <= 44 or level_idx == 83 or level_idx == 84 or level_idx >= 88 and level_idx <= 90 then
		re_str = re2[re_level + 1] .. "_"
	elseif level_idx > GS.jnum5 and level_idx <= GS.last_level5 then
		re_str = "power_reinforcements_control_g5"
	else
		re_str = re1[re_level + 1] .. "_"
	end

	if screen_map.user_data.liuhui.reinforcement_skins and screen_map.user_data.liuhui.reinforcement_skins ~= 0 then
		local port = {
			{1000, 1001, 1002, 1003},
			{1004, 1005, 1006, 1007},
			{1008, 1009, 1010, 1011}
		}
		for i = 1, 4 do
			local t = E.entities[re1[re_level + 1] .. "_" .. i] or E:register_t(re1[re_level + 1] .. "_" .. i, "re_current_1")
			t.render.sprites[1].prefix = "re_skin_" .. screen_map.user_data.liuhui.reinforcement_skins .. "_" .. i
			t.info.portrait = string.format("info_portraits_sc_%04d", port[screen_map.user_data.liuhui.reinforcement_skins][i])
			t.info.random_name_format = string.upper(t.render.sprites[1].prefix) .. "_%i_NAME"
			t.info.random_name_count = 3
		end
		self.re_n = 4
	else
		self.re_n = 3
	end
	--local e = E:create_entity("re"..gen.."_current_" .. i)
	if level_idx == 115 and (game_gui.game.store.level_mode == GAME_MODE_IRON or game_gui.game.store.level_mode == GAME_MODE_HEROIC or (game_gui.game.store.level_mode == GAME_MODE_CAMPAIGN and game_gui.game.store.wave_group_number >= 15)) then
		local e = E:create_entity("power_denas_control")
		e.pos.x, e.pos.y = wx, wy
		Power1Button.super.fire(self, wx, wy)
		game_gui.game.simulation:insert_entity(e)
	elseif level_idx <= 100 or level_idx >= 149 then
		if screen_map.user_data.reinforcement_count and screen_map.user_data.reinforcement_count ~= 0 then
			local e = E:create_entity(re_str .. i)
	
			e.pos.x = wx
			e.pos.y = wy - 20
			e.nav_rally.center = V.v(wx, wy)
			e.nav_rally.pos = V.vclone(e.pos)
	
			game_gui.game.simulation:insert_entity(e)
	
			i = math.random(1, 3)
			--e = E:create_entity("re"..gen.."_current_" .. i)
			e = E:create_entity(re_str .. i)
			e.pos.x = wx - 20
			e.pos.y = wy + 10
			e.nav_rally.center = V.v(wx, wy)
			e.nav_rally.pos = V.vclone(e.pos)
	
			game_gui.game.simulation:insert_entity(e)
	
			i = math.random(1, 3)
			--e = E:create_entity("re"..gen.."_current_" .. i)
			e = E:create_entity(re_str .. i)
			e.pos.x = wx + 20
			e.pos.y = wy + 10
			e.nav_rally.center = V.v(wx, wy)
			e.nav_rally.pos = V.vclone(e.pos)
	
			game_gui.game.simulation:insert_entity(e)
		else			
			local e = E:create_entity(re_str .. i)
	
			e.pos.x = wx + 10
			e.pos.y = wy - 10
			e.nav_rally.center = V.v(wx, wy)
			e.nav_rally.pos = V.vclone(e.pos)
	
			game_gui.game.simulation:insert_entity(e)
	
			i = math.random(1, 3)
			--e = E:create_entity("re"..gen.."_current_" .. i)
			e = E:create_entity(re_str .. i)
			e.pos.x = wx - 10
			e.pos.y = wy + 10
			e.nav_rally.center = V.v(wx, wy)
			e.nav_rally.pos = V.vclone(e.pos)
	
			game_gui.game.simulation:insert_entity(e)
		end
	else
		local e = E:create_entity(re_str)

		e.pos.x = wx
		e.pos.y = wy

		game_gui.game.simulation:insert_entity(e)

		if level_idx == 140 and (game_gui.game.store.level_mode == GAME_MODE_CAMPAIGN and game_gui.game.store.wave_group_number >= 15) then

			local entity_string = "soldier_dragon_warden_warrior_reinforcement"

			if generation_upgrades.g5_reinforcement_branch(user_data) ~= "dark" then
				entity_string = "soldier_warden_stage_40_reinforcement"
			end
			
			local e = E:create_entity(entity_string)
			e.pos.x, e.pos.y = wx - 30, wy - 20
			e.nav_rally.center = V.v(wx, wy)
			e.nav_rally.pos = V.vclone(e.pos)
			game_gui.game.simulation:insert_entity(e)
			

			local e = E:create_entity(entity_string)
			e.pos.x, e.pos.y = wx - 30, wy + 20
			e.nav_rally.center = V.v(wx, wy)
			e.nav_rally.pos = V.vclone(e.pos)
			game_gui.game.simulation:insert_entity(e)
		end
	end

	--[[
	if level_idx == 115 and (game_gui.game.store.level_mode == GAME_MODE_IRON or game_gui.game.store.level_mode == GAME_MODE_HEROIC or (game_gui.game.store.level_mode == GAME_MODE_CAMPAIGN and game_gui.game.store.wave_group_number >= 15)) then
		local e = E:create_entity("power_denas_control")
		e.pos.x, e.pos.y = wx, wy
		Power1Button.super.fire(self, wx, wy)
		game_gui.game.simulation:insert_entity(e)
	elseif level_idx <= GS.last_level3 or level_idx == 81 or level_idx == 82 then
		local e = E:create_entity("soldier_re_" .. re_level .. "_" .. i)

		e.pos.x = wx
		e.pos.y = wy - 20
		e.nav_rally.center = V.v(wx, wy)
		e.nav_rally.pos = V.vclone(e.pos)

		game_gui.game.simulation:insert_entity(e)

		i = math.random(1, 3)
		--e = E:create_entity("re"..gen.."_current_" .. i)
		e = E:create_entity("soldier_re_" .. re_level .. "_" .. i)
		e.pos.x = wx - 20
		e.pos.y = wy + 10
		e.nav_rally.center = V.v(wx, wy)
		e.nav_rally.pos = V.vclone(e.pos)

		game_gui.game.simulation:insert_entity(e)

		i = math.random(1, 3)
		--e = E:create_entity("re"..gen.."_current_" .. i)
		e = E:create_entity("soldier_re_" .. re_level .. "_" .. i)
		e.pos.x = wx + 20
		e.pos.y = wy + 10
		e.nav_rally.center = V.v(wx, wy)
		e.nav_rally.pos = V.vclone(e.pos)

		game_gui.game.simulation:insert_entity(e)
	elseif level_idx <= 44 or level_idx == 83 or level_idx == 84 then
		local e = E:create_entity(re2[re_level + 1] .. "_" .. i)

		e.pos.x = wx
		e.pos.y = wy - 20
		e.nav_rally.center = V.v(wx, wy)
		e.nav_rally.pos = V.vclone(e.pos)

		game_gui.game.simulation:insert_entity(e)

		i = math.random(1, 3)
		--e = E:create_entity("re"..gen.."_current_" .. i)
		e = E:create_entity(re2[re_level + 1] .. "_" .. i)
		e.pos.x = wx - 20
		e.pos.y = wy + 10
		e.nav_rally.center = V.v(wx, wy)
		e.nav_rally.pos = V.vclone(e.pos)

		game_gui.game.simulation:insert_entity(e)

		i = math.random(1, 3)
		--e = E:create_entity("re"..gen.."_current_" .. i)
		e = E:create_entity(re2[re_level + 1] .. "_" .. i)
		e.pos.x = wx + 20
		e.pos.y = wy + 10
		e.nav_rally.center = V.v(wx, wy)
		e.nav_rally.pos = V.vclone(e.pos)

		game_gui.game.simulation:insert_entity(e)
	elseif level_idx > GS.jnum5 and level_idx <= GS.last_level5 then
		local e = E:create_entity("power_reinforcements_control_g5")

		e.pos.x = wx
		e.pos.y = wy

		game_gui.game.simulation:insert_entity(e)
	else
		if screen_map.reinforcement_skins and screen_map.reinforcement_skins ~= 0 then
    		local port = {
    				{1000, 1001, 1002, 1003},
    				{1004, 1005, 1006, 1007},
    				{1008, 1009, 1010, 1011}
    			}
    		for i = 1, 4 do
    				local t = E.entities[re1[re_level + 1] .. "_" .. i] or E:register_t(re1[re_level + 1] .. "_" .. i, "re_current_1")
    				t.render.sprites[1].prefix = "re_skin_" .. screen_map.reinforcement_skins .. "_" .. i
    				t.info.portrait = string.format("info_portraits_sc_%04d", port[screen_map.reinforcement_skins][i])
    				t.info.random_name_format = string.upper(t.render.sprites[1].prefix) .. "_%i_NAME"
    				t.info.random_name_count = 3
    		end
			local e = E:create_entity(re1[re_level + 1] .. "_" .. i)
			
			e.pos.x = wx
			e.pos.y = wy - 20
			e.nav_rally.center = V.v(wx, wy)
			e.nav_rally.pos = V.vclone(e.pos)
			
			game_gui.game.simulation:insert_entity(e)
			
			i = math.random(1, 3)
			e = E:create_entity(re1[re_level + 1] .. "_" .. i)
			e.pos.x = wx - 20
			e.pos.y = wy + 10
			e.nav_rally.center = V.v(wx, wy)
			e.nav_rally.pos = V.vclone(e.pos)
			
			game_gui.game.simulation:insert_entity(e)
			
			i = math.random(1, 3)
			e = E:create_entity(re1[re_level + 1] .. "_" .. i)
			e.pos.x = wx + 20
			e.pos.y = wy + 10
			e.nav_rally.center = V.v(wx, wy)
			e.nav_rally.pos = V.vclone(e.pos)
			
			game_gui.game.simulation:insert_entity(e)

    		self.re_n = 4
    	else
			local e = E:create_entity(re1[re_level + 1] .. "_" .. i)
	
			e.pos.x = wx
			e.pos.y = wy - 20
			e.nav_rally.center = V.v(wx, wy)
			e.nav_rally.pos = V.vclone(e.pos)
	
			game_gui.game.simulation:insert_entity(e)
	
			i = math.random(1, 3)
			e = E:create_entity(re1[re_level + 1] .. "_" .. i)
			e.pos.x = wx - 20
			e.pos.y = wy + 10
			e.nav_rally.center = V.v(wx, wy)
			e.nav_rally.pos = V.vclone(e.pos)
	
			game_gui.game.simulation:insert_entity(e)
	
			i = math.random(1, 3)
			e = E:create_entity(re1[re_level + 1] .. "_" .. i)
			e.pos.x = wx + 20
			e.pos.y = wy + 10
			e.nav_rally.center = V.v(wx, wy)
			e.nav_rally.pos = V.vclone(e.pos)
	
			game_gui.game.simulation:insert_entity(e)

  			self.re_n = 3
    	end				
	end]]--
	signal.emit("power-used", 2)
end

Power3Button = class("Power3Button", PowerButton)

function Power3Button:initialize()
	--判断选的是单英雄还是双英雄的第2位英雄
	local ht = nil
	local user_data = storage:load_slot()
	local is_double = user_data and user_data.liuhui_hero and user_data.liuhui_hero.usedoublehero
	ht = power_hero_template(is_double and 2 or 1)

	if ht and hero_game_ver(ht.template_name) < 3 then
		--原先power3button设置为flash闪电
		Power3Button.super.initialize(self, "lightning_0001", "power_button_mask_0001")

		self.animations = {
			default = {
				to = 1,
				prefix = "power_button_mask",
				from = 1
			},
			highlighted = {
				to = 45,
				prefix = "power_button_mask",
				from = 45
			},
			cooldown = {
				to = 1,
				prefix = "power_button_mask",
				from = 1
			},
			locked = {
				to = 30,
				prefix = "power_button_mask",
				from = 30
			},
			unlocked = {
				to = 44,
				prefix = "power_button_mask",
				from = 30
			},
			selected = {
				to = 29,
				prefix = "power_button_mask",
				from = 29
			},
			ready = {
				to = 28,
				prefix = "power_button_mask",
				from = 1,
				post = {
					1
				}
			}
		}

	else

		hero_table3 = {
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
		local icon_name = nil
		icon_name = power_hero_button_icon(ht) or "power_button_icons_0017"
		Power3Button.super.initialize(self, icon_name, "power_button_mask_0001")

		self.animations = {
			default = {
				to = 1,
				prefix = "power_button_mask",
				from = 1
			},
			highlighted = {
				to = 45,
				prefix = "power_button_mask",
				from = 45
			},
			cooldown = {
				to = 1,
				prefix = "power_button_mask",
				from = 1
			},
			locked = {
				to = 30,
				prefix = "power_button_mask",
				from = 30
			},
			unlocked = {
				to = 44,
				prefix = "power_button_mask",
				from = 30
			},
			selected = {
				to = 29,
				prefix = "power_button_mask",
				from = 29
			},
			ready = {
				to = 28,
				prefix = "power_button_mask",
				from = 1,
				post = {
					1
				}
			}
		}
	end

	self.selected_gui_mode = GUI_MODE_POWER_3

	self:set_mode("locked")
end

function Power3Button:fire(wx, wy)
	local rank = 1
	local user_data = storage:load_slot()
	local is_double = user_data and user_data.liuhui_hero and user_data.liuhui_hero.usedoublehero

	if is_double then
		rank = 2
	end

	local hero, he = power_hero_template(rank)

	if hero and hero_game_ver(hero.template_name) < 3 then
		local e = E:create_entity("power_lightning")
		local enemy = U.find_entity_at_pos(game_gui.game.simulation.store.entities, wx, wy, function(entity)
			return entity.enemy
		end)
		e.target_id = enemy.id
		e.pos.x, e.pos.y = wx, wy
		Power3Button.super.fire(self, wx, wy)
		game_gui.game.simulation:insert_entity(e)
		signal.emit("power-used", 3)
	elseif hero then
		if he then
			local u = he.hero.skills.ultimate
			local e = E:create_entity(u.controller_name)
			self.cooldown_time = power_hero_ultimate_cooldown(hero, he, e) or self.cooldown_time
			Power3Button.super.cooldown_time = self.cooldown_time
			--print("cooldown_time is"..self.cooldown_time)
			e.pos.x, e.pos.y = wx, wy
			e.owner = he
			e.source_id = he.id
			e.level = u.level

			Power3Button.super.fire(self, wx, wy)
			game_gui.game.simulation:insert_entity(e)
			--大招效果
			if hero_group_ver(hero.template_name) == 2 then
				local upg = true
				if upg then
					for _, e in pairs(game_gui.game.store.entities) do
						if e.enemy and band(e.vis.bans, F_MOD) == 0 then
							local mod = E:create_entity("mod_upgrade_alliance_display_of_true_might_dark_army")

							mod.modifier.target_id = e.id

							game_gui.game.simulation:insert_entity(mod)
						end
					end

					local overlay = E:create_entity("decal_upgrade_alliance_display_of_true_might_dark_army_overlay")

					overlay.tween.ts = game_gui.game.store.tick_ts
					overlay.pos = v(512, 384)

					game_gui.game.simulation:insert_entity(overlay)
					S:queue("UpgradeDisplayOfTrueMightDarkArmy")
				end
			elseif hero_group_ver(hero.template_name) == 1 then
				local upg = true
				if upg then
					for _, e in pairs(game_gui.game.store.entities) do
						if e.hero then
							if e.health.hp > 0 then
								e.health.hp = e.health.hp_max

								local mod = E:create_entity("mod_upgrade_alliance_display_of_true_might_linirea")

								mod.modifier.target_id = e.id

								game_gui.game.simulation:insert_entity(mod)
								
							end
						elseif e.soldier and e.vis and band(e.vis.bans, F_MOD) == 0 then
							if e.health.hp <= 0 then
								if e.info.is_here_pandas and e.info.is_here_pandas == 1 then
									--empty
								else
									e.health.dead = true
									--queue_remove(game_gui.game.store, e)
									game_gui.game.simulation:queue_remove_entity(e)
								end
							else
								e.health.hp = e.health.hp_max

								local mod = E:create_entity("mod_upgrade_alliance_display_of_true_might_linirea")

								mod.modifier.target_id = e.id

								game_gui.game.simulation:insert_entity(mod)
							end
						end
					end

					local overlay = E:create_entity("decal_upgrade_alliance_display_of_true_might_linirea_overlay")

					overlay.tween.ts = game_gui.game.store.tick_ts
					overlay.pos = v(512, 384)

					game_gui.game.simulation:insert_entity(overlay)
					S:queue("UpgradeDisplayOfTrueMightLinirea")
				end
			end
			signal.emit("power-used", 3)
			self.cooldown_time = e.cooldown or self.cooldown_time
		else 
		end
	
	end
end

local function standard_power_button_animations()
	return {
		default = {from = 1, to = 1, prefix = "power_button_mask"},
		highlighted = {from = 45, to = 45, prefix = "power_button_mask"},
		cooldown = {from = 1, to = 1, prefix = "power_button_mask"},
		locked = {from = 30, to = 30, prefix = "power_button_mask"},
		unlocked = {from = 30, to = 44, prefix = "power_button_mask"},
		selected = {from = 29, to = 29, prefix = "power_button_mask"},
		ready = {
			from = 1,
			to = 28,
			prefix = "power_button_mask",
			post = {1}
		}
	}
end

local function configure_selected_power_button(button, slot)
	PowerButton.initialize(button, selected_power_button_icon(slot), "power_button_mask_0001",
		selected_power_button_scale(slot))

	button.animations = standard_power_button_animations()
	button.slot_index = slot
	button.selected_gui_mode = slot == 1 and GUI_MODE_POWER_1 or slot == 2 and GUI_MODE_POWER_2 or GUI_MODE_POWER_3
	button.cooldown_time = selected_power_cooldown(slot)
	button.available = selected_power_slot_available(slot)
	button.hidden = not button.available

	button:set_mode("locked")
end

local function apply_linirea_full_screen_revive()
	for _, entity in pairs(game_gui.game.store.entities) do
		if entity.hero and entity.health then
			if entity.health.hp > 0 then
				entity.health.hp = entity.health.hp_max

				local mod = E:create_entity("mod_upgrade_alliance_display_of_true_might_linirea")

				mod.modifier.target_id = entity.id

				game_gui.game.simulation:insert_entity(mod)
			end
		elseif entity.soldier and entity.health and entity.vis and entity.vis.bans and
			band(entity.vis.bans, F_MOD) == 0 then
			if entity.health.hp <= 0 then
				if not ignores_linirea_revive(entity) then
					entity.health.dead = true
					game_gui.game.simulation:queue_remove_entity(entity)
				end
			else
				entity.health.hp = entity.health.hp_max

				local mod = E:create_entity("mod_upgrade_alliance_display_of_true_might_linirea")

				mod.modifier.target_id = entity.id

				game_gui.game.simulation:insert_entity(mod)
			end
		elseif entity.tower and entity.tower.type == "pandas" then
			entity.deploy_all = true
		end
	end

	local overlay = E:create_entity("decal_upgrade_alliance_display_of_true_might_linirea_overlay")

	overlay.tween.ts = game_gui.game.store.tick_ts
	overlay.pos = v(512, 384)

	game_gui.game.simulation:insert_entity(overlay)
	S:queue("UpgradeDisplayOfTrueMightLinirea")
end

local function apply_ultimate_faction_bonus(hero)
	if hero_group_ver(hero.template_name) == 2 then
		for _, entity in pairs(game_gui.game.store.entities) do
			if entity.enemy and band(entity.vis.bans, F_MOD) == 0 then
				local mod = E:create_entity("mod_upgrade_alliance_display_of_true_might_dark_army")

				mod.modifier.target_id = entity.id

				game_gui.game.simulation:insert_entity(mod)
			end
		end

		local overlay = E:create_entity("decal_upgrade_alliance_display_of_true_might_dark_army_overlay")

		overlay.tween.ts = game_gui.game.store.tick_ts
		overlay.pos = v(512, 384)

		game_gui.game.simulation:insert_entity(overlay)
		S:queue("UpgradeDisplayOfTrueMightDarkArmy")
	elseif hero_group_ver(hero.template_name) == 1 then
		apply_linirea_full_screen_revive()
	end
end

local function fire_selected_hero_ultimate(button, slot, hero, hero_entity, wx, wy)
	local ultimate = hero_entity.hero.skills.ultimate
	local entity = E:create_entity(ultimate.controller_name)

	button.cooldown_time = power_hero_ultimate_cooldown(hero, hero_entity, entity) or button.cooldown_time
	entity.pos.x, entity.pos.y = wx, wy
	entity.owner = hero_entity
	entity.source_id = hero_entity.id
	entity.level = ultimate.level

	PowerButton.fire(button, wx, wy)
	game_gui.game.simulation:insert_entity(entity)
	apply_ultimate_faction_bonus(hero)
	signal.emit("power-used", slot)

	return true
end

local function prepare_g1_reinforcement_skin(user_data, level)
	local skin = user_data.liuhui and user_data.liuhui.reinforcement_skins or 0

	if skin == 0 then
		return
	end

	local portraits = {
		{1000, 1001, 1002, 1003},
		{1004, 1005, 1006, 1007},
		{1008, 1009, 1010, 1011}
	}
	local portrait_row = portraits[skin]

	if not portrait_row then
		return
	end

	local base_name = reinforcement_templates[1][level + 1]

	for variant = 1, 4 do
		local template_name = base_name .. "_" .. variant
		local template = E.entities[template_name] or E:register_t(template_name, base_name .. "_1")

		template.render.sprites[1].prefix = string.format("re_skin_%i_%i", skin, variant)
		template.info.portrait = string.format("info_portraits_sc_%04d", portrait_row[variant])
		template.info.random_name_format = string.upper(template.render.sprites[1].prefix) .. "_%i_NAME"
		template.info.random_name_count = 3
	end
end

local function insert_manual_reinforcement(template_name, wx, wy, offset_x, offset_y)
	local entity = E:create_entity(template_name)

	entity.pos.x = wx + offset_x
	entity.pos.y = wy + offset_y
	entity.nav_rally.center = V.v(wx, wy)
	entity.nav_rally.pos = V.vclone(entity.pos)

	game_gui.game.simulation:insert_entity(entity)
end

local function fire_selected_reinforcements(button, slot, option, wx, wy)
	local store = game_gui.game.store
	local user_data = store.user_data or storage:load_slot()
	local level_idx = store.level_idx
	local generation = option.default_generation and default_reinforcement_generation() or option.generation
	local level = generation <= 3 and legacy_upgrade_level(generation, "reinforcements") or 0

	if option.default_generation and level_idx == 115 and (store.level_mode == GAME_MODE_IRON or store.level_mode == GAME_MODE_HEROIC or store.level_mode == GAME_MODE_CAMPAIGN and store.wave_group_number >= 15) then
		local entity = E:create_entity("power_denas_control")

		entity.pos.x, entity.pos.y = wx, wy
		button.cooldown_time = spell_mode_cooldown(template_power_cooldown("power_denas_control") or button.cooldown_time)
		PowerButton.fire(button, wx, wy)
		game_gui.game.simulation:insert_entity(entity)
		signal.emit("power-used", slot)

		return true
	end

	if generation == 4 then
		local entity = E:create_entity("power_kr4_reinforcements_control")
		local g4_level = generation_upgrades.level(user_data, "g4_reinforcements")

		entity.pos.x, entity.pos.y = wx, wy
		entity.reinforcement_level = g4_level
		entity.branch = generation_upgrades.g4_reinforcement_branch(user_data)
		entity.extra_count = user_data.reinforcement_count and user_data.reinforcement_count ~= 0
		entity.pit_lord_chance = g4_level >= 5 and 0.3 or 0
		button.cooldown_time = spell_mode_cooldown(entity.cooldown or button.cooldown_time)
		PowerButton.fire(button, wx, wy)
		game_gui.game.simulation:insert_entity(entity)
	elseif generation == 5 then
		local entity = E:create_entity("power_reinforcements_control_g5")

		entity.pos.x, entity.pos.y = wx, wy
		button.cooldown_time = spell_mode_cooldown(template_power_cooldown("power_reinforcements_control_g5") or button.cooldown_time)
		PowerButton.fire(button, wx, wy)
		game_gui.game.simulation:insert_entity(entity)

		if option.default_generation and level_idx == 140 and store.level_mode == GAME_MODE_CAMPAIGN and store.wave_group_number >= 15 then
			local template_name = generation_upgrades.g5_reinforcement_branch(user_data) == "dark" and "soldier_dragon_warden_warrior_reinforcement" or "soldier_warden_stage_40_reinforcement"

			insert_manual_reinforcement(template_name, wx, wy, -30, -20)
			insert_manual_reinforcement(template_name, wx, wy, -30, 20)
		end
	elseif generation == 6 then
		local entity = E:create_entity("power_reinforcements_control_g6")

		entity.pos.x, entity.pos.y = wx, wy
		button.cooldown_time = spell_mode_cooldown(template_power_cooldown("power_reinforcements_control_g6") or button.cooldown_time)
		PowerButton.fire(button, wx, wy)
		game_gui.game.simulation:insert_entity(entity)
	else
		if generation == 1 then
			prepare_g1_reinforcement_skin(user_data, level)
		end

		local extra_count = user_data.reinforcement_count and user_data.reinforcement_count ~= 0
		local offsets = extra_count and {{0, -20}, {-20, 10}, {20, 10}} or {{10, -10}, {-10, 10}}

		for _, offset in ipairs(offsets) do
			local variant = math.random(1, 3)
			local template_name = reinforcement_template_name(generation, level, variant)

			insert_manual_reinforcement(template_name, wx, wy, offset[1], offset[2])
		end

		button.cooldown_time = selected_power_cooldown(slot)
		PowerButton.fire(button, wx, wy)
	end

	signal.emit("power-used", slot)

	return true
end

local function fire_selected_spell(button, slot, wx, wy)
	local option = selected_power_option(slot)

	if option.kind == "mermaid_gift" then
		local ultimate_buttons, total_remaining = refreshable_hero_ultimates()

		if #ultimate_buttons == 0 then
			return false
		end

		button.cooldown_time = math.min(200, 40 + total_remaining * 1.6)

		for _, ultimate_button in ipairs(ultimate_buttons) do
			ultimate_button:set_mode("ready")
		end

		apply_linirea_full_screen_revive()
		PowerButton.fire(button, wx, wy)
		S:queue("DoliaMermaidGift")
		signal.emit("power-used", slot)

		return true
	elseif option.kind == "reinforcement" then
		return fire_selected_reinforcements(button, slot, option, wx, wy)
	elseif option.kind == "empty" then
		button.cooldown_time = selected_power_cooldown(slot)
		PowerButton.fire(button, wx, wy)

		return true
	end

	local entity = E:create_entity(power_option_control_name(option))

	if option.controller_values then
		for key, value in pairs(option.controller_values) do
			entity[key] = value
		end
	end

	if option.kind == "lightning" then
		local target = U.find_entity_at_pos(game_gui.game.store.entities, wx, wy, function(candidate)
			return candidate.enemy
		end)

		if not target then
			return false
		end

		entity.target_id = target.id
	end

	entity.pos.x, entity.pos.y = wx, wy
	button.cooldown_time = selected_power_cooldown(slot)

	if option.revive_allies then
		apply_linirea_full_screen_revive()
	end

	PowerButton.fire(button, wx, wy)
	game_gui.game.simulation:insert_entity(entity)

	if option.cast_sound then
		S:queue(option.cast_sound)
	end

	record_cheat_item_use(option)
	signal.emit("power-used", slot)

	return true
end

local function fire_selected_power(button, slot, wx, wy)
	local hero, hero_entity = selected_hero_ultimate(slot)

	if hero then
		if hero_entity and hero_entity.hero and hero_entity.hero.skills and hero_entity.hero.skills.ultimate then
			return fire_selected_hero_ultimate(button, slot, hero, hero_entity, wx, wy)
		end

		return false
	end

	return fire_selected_spell(button, slot, wx, wy)
end

HeroUltimateButton = class("HeroUltimateButton", PowerButton)

function HeroUltimateButton:initialize(slot)
	PowerButton.initialize(self, hero_ultimate_slot_button_icon(slot), "power_button_mask_0001")

	self.animations = standard_power_button_animations()
	self.hero_slot = slot
	self.selected_gui_mode = slot == "a" and GUI_MODE_POWER_A or GUI_MODE_POWER_S
	self.cooldown_time = hero_ultimate_slot_cooldown(slot)
	self.available = hero_ultimate_slot_available(slot)
	self.hidden = not self.available

	self:set_mode("locked")
end

function HeroUltimateButton:fire(wx, wy)
	local hero, hero_entity = selected_hero_ultimate(self.hero_slot)

	if not hero or not hero_entity or not hero_entity.hero or not hero_entity.hero.skills or
		not hero_entity.hero.skills.ultimate then
		return false
	end

	return fire_selected_hero_ultimate(self, self.hero_slot, hero, hero_entity, wx, wy)
end

-- Each copy owns its own skill button and cooldown; no fixed spell-slot ceiling.
InfiniteHeroUltimateButton = class("InfiniteHeroUltimateButton", PowerButton)

function InfiniteHeroUltimateButton:initialize(hero_entity)
	local ht = E:get_template(hero_entity.template_name)
	PowerButton.initialize(self, power_hero_button_icon(ht) or "power_button_icons_0017", "power_button_mask_0001")
	self.animations = standard_power_button_animations()
	self.infinite_hero_id = hero_entity.id
	local boss_skill = require("allied_boss_skills").skills[require("allied_boss_skills").kind(hero_entity.template_name)]
	if boss_skill then
		local label = GGLabel:new(v(self.size.x - 18, 17))
		label.pos = v(9, self.size.y - 23)
		label.font_name, label.font_size = "hud", 11
		label.text, label.text_align, label.vertical_align = boss_skill.label, "center", "middle"
		label.colors.text, label.colors.background = {255, 247, 218, 255}, {30, 23, 18, 225}
		label.fit_size, label.propagate_on_click = true, true
		self:add_child(label)
	end
	self.selected_gui_mode = GUI_MODE_POWER_S
	local ultimate = hero_entity.hero.skills.ultimate
	self.cooldown_time = power_hero_ultimate_cooldown(ht, hero_entity, E:get_template(ultimate.controller_name)) or 60
	self:set_mode("ready")
end

function InfiniteHeroUltimateButton:toggle_selection(keep_hover)
	local previous = game_gui.infinite_ultimate_button
	if previous and previous ~= self and game_gui.mode == GUI_MODE_POWER_S then
		previous:set_mode("default"); game_gui:set_mode()
	end
	game_gui.infinite_ultimate_button = self
	PowerButton.toggle_selection(self, keep_hover)
end

function InfiniteHeroUltimateButton:can_fire(wx, wy)
	local hero = game_gui:entity_by_id(self.infinite_hero_id)
	local ultimate = hero and hero.hero.skills.ultimate
	if not ultimate or (ultimate.level or 0) < 1 or self.mode == "cooldown" or (hero.health and hero.health.dead) then return false end
	if infinite_heroes.get_boss(hero.template_name) and not require("allied_boss_skills").can_fire(hero, wx, wy, game_gui.game.store) then return false end
	local controller = E:get_template(ultimate.controller_name)
	return controller and (not controller.can_fire_fn or controller.can_fire_fn(controller, wx, wy, game_gui.game.store))
end

function InfiniteHeroUltimateButton:fire(wx, wy)
	local hero = game_gui:entity_by_id(self.infinite_hero_id)
	if hero then return fire_selected_hero_ultimate(self, "s", E:get_template(hero.template_name), hero, wx, wy) end
	return false
end

function InfiniteHeroUltimateButton:update(dt)
	if self.mode == "selected" and (game_gui.infinite_ultimate_button ~= self or game_gui.mode ~= GUI_MODE_POWER_S) then self:set_mode("default") end
	PowerButton.update(self, dt)
end

function Power1Button:initialize()
	configure_selected_power_button(self, 1)
end

function Power1Button:fire(wx, wy)
	return fire_selected_power(self, 1, wx, wy)
end

function Power2Button:initialize()
	configure_selected_power_button(self, 2)
end

function Power2Button:fire(wx, wy)
	return fire_selected_power(self, 2, wx, wy)
end

function Power3Button:initialize()
	configure_selected_power_button(self, 3)
end

function Power3Button:fire(wx, wy)
	return fire_selected_power(self, 3, wx, wy)
end


PowerButtonBlock = class("PowerButtonBlock", KImageView)

function PowerButtonBlock:initialize(power_button, duration, style_name)
	self.power_button = power_button
	self.duration = duration

	local styles = data.power_button_block_styles
	local style = styles[style_name] or styles.drow_queen

	KImageView.initialize(self, style.image)

	self.anchor = v(self.size.x / 2, self.size.y / 2)
	self.pos.x, self.pos.y = power_button.size.x / 2, power_button.size.y / 2
	self.animations = style.animations
end

function PowerButtonBlock:block()
	self.power_button:disable(false)

	self.start_ts = power_cooldown_now()
	self.animation = self.animations.block
	self.ts = 0
end

function PowerButtonBlock:unblock()
	self.power_button:enable(false)

	self.start_ts = nil
	self.animation = self.animations.unblock
	self.ts = 0

	timer:after((self.animation.to - self.animation.from + 1) / 30, function()
		self:remove_from_parent()
	end)
end

function PowerButtonBlock:update(dt)
	if self.start_ts and power_cooldown_now() - self.start_ts > self.duration then
		self:unblock()
	end

	PowerButtonBlock.super.update(self, dt)
end

NextWaveButton = class("NextWaveButton", KImageButton)

function NextWaveButton:initialize()
	NextWaveButton.super.initialize(self, "nextwave_0001", "nextwave_0002", "nextwave_0002")

	self.anchor = v(math.floor(self.size.x / 2), self.size.y)
end

function NextWaveButton:on_click(button, x, y)
	log.debug("")

	if IS_ANDROID and not self.android_confirm_armed then
		self.android_confirm_armed = true

		local flag = game_gui.wave_flags and game_gui.wave_flags[1]

		if flag and flag.on_enter then
			flag:on_enter()
		end

		return false
	end

	self.android_confirm_armed = false

	game_gui.game.store.send_next_wave = true
end

InfoBar = class("InfoBar", KImageView)

function InfoBar:initialize()
	InfoBar.super.initialize(self, "base")

	local v_portrait = KView:new(V.v(68, 68))

	v_portrait.anchor = v(34, 34)
	v_portrait.pos = IS_KR3 and v(65, 39) or IS_KR1 and v(61, 32) or v(68, 38)
	v_portrait.propagate_on_down = true
	v_portrait.propagate_on_click = true
	self.v_portrait = v_portrait

	self:add_child(v_portrait)

	local l_name = GGLabel:new(V.v(130, 15))

	l_name.pos = v(97, 11)
	l_name.font_name = "infobar_name"
	l_name.font_size = 12
	l_name.colors.text = {
		255,
		255,
		255,
		255
	}
	l_name.colors.background = DEBUG_BACKGROUND_COLOR
	l_name.text_align = "left"
	l_name.vertical_align = "bottom"
	l_name.propagate_on_down = true
	l_name.propagate_on_click = true
	l_name.fit_lines = 1
	self.l_name = l_name

	self:add_child(l_name)

	local l_combat_damage = GGLabel:new(V.v(130, 15))

	l_combat_damage.pos = v(245, 11)
	l_combat_damage.font_name = "infobar_stats"
	l_combat_damage.font_size = 12
	l_combat_damage.colors.text = {
		255,
		230,
		145,
		255
	}
	l_combat_damage.colors.background = DEBUG_BACKGROUND_COLOR
	l_combat_damage.text_align = "left"
	l_combat_damage.vertical_align = "bottom"
	l_combat_damage.propagate_on_down = true
	l_combat_damage.propagate_on_click = true
	l_combat_damage.fit_lines = 1
	l_combat_damage.hidden = true
	self.l_combat_damage = l_combat_damage

	self:add_child(l_combat_damage)

	local l_combat_kills = GGLabel:new(V.v(120, 15))

	l_combat_kills.pos = v(385, 11)
	l_combat_kills.font_name = "infobar_stats"
	l_combat_kills.font_size = 12
	l_combat_kills.colors.text = {
		255,
		230,
		145,
		255
	}
	l_combat_kills.colors.background = DEBUG_BACKGROUND_COLOR
	l_combat_kills.text_align = "left"
	l_combat_kills.vertical_align = "bottom"
	l_combat_kills.propagate_on_down = true
	l_combat_kills.propagate_on_click = true
	l_combat_kills.fit_lines = 1
	l_combat_kills.hidden = true
	self.l_combat_kills = l_combat_kills

	self:add_child(l_combat_kills)

	local s_1 = 396
	local s_3 = 133.33333333333334
	local s_2 = 200
	local s_4 = 100
	local s_9 = 44.44444444444444
	local s_12 = 33.333333333333336
	local margin = v(10, 14)
	local padding = v(20, CJK(1, -2, 3, -1.5))
	local label_height = 14
	local stat_labels = {}
	--[[
		stat_labels[STATS_TYPE_TOWER_BARRACK] = {
			{
				"label",
				"l_hp",
				"base_info_icons_0009",
				s_4
			},
			{
				"label",
				"l_damage",
				"base_info_icons_0001",
				s_4
			},
			{
				"label",
				"l_armor",
				"base_info_icons_0003",
				s_4
			},
			{
				"label",
				"l_respawn",
				"base_info_icons_0007",
				s_4
			}
		}									   
		stat_labels[STATS_TYPE_SOLDIER] = {
			{
				"bar",
				"b_hp",
				"base_info_bar_bg",
				"base_info_bar",
				3.3 * s_12
			},
			{
				"label",
				"l_hp",
				nil,
				3.3 * s_12,
				"center",
				true,
				v(0, CJK(1, -2, 3, -1))
			},
			{
				"space",
				0.7 * s_12
			},
			{
				"label",
				"l_damage",
				"base_info_icons_0001",
				3 * s_12
			},
			{
				"label",
				"l_armor",
				"base_info_icons_0003",
				3 * s_12
			},
			{
				"label",
				"l_respawn",
				"base_info_icons_0007",
				2 * s_12
			}
		}	
		stat_labels[STATS_TYPE_ENEMY] = table.deepclone(stat_labels[STATS_TYPE_SOLDIER])
		stat_labels[STATS_TYPE_ENEMY][6] = {
			"label",
			"l_lives",
			"base_info_icons_0008",
			2 * s_9
		}
	]]--
	----本段代码来自DOVE版
    stat_labels[STATS_TYPE_TOWER_BARRACK] = {{"label", "l_hp", "base_info_icons_0009", 2 * s_12},
                                       {"label", "l_damage", "base_info_icons_0001", 2.5 * s_12},
                                       {"label", "l_ranged_damage", "base_info_icons_0001", 2.5 * s_12},
                                       {"label", "l_armor", "base_info_icons_0003", 3 * s_12},
                                       {"label", "l_magic_armor", "base_info_icons_0004", 3 * s_12},
									   {"label","l_dodge","base_info_icons_0021",1.8 * s_12},								   
                                       {"label", "l_respawn", "base_info_icons_0007", 2 * s_12}}	
    stat_labels[STATS_TYPE_SOLDIER] = {{"bar", "b_hp", "base_info_bar_bg", "base_info_bar", 3.3 * s_12},
                                       {"label", "l_hp", nil, 3.3 * s_12, "center", true, v(0, CJK(1, -2, 3, -1))},
                                       {"label", "l_damage", "base_info_icons_0001", 2.5 * s_12},
                                       {"label", "l_ranged_damage", "base_info_icons_0001", 2.5 * s_12},
                                       {"label", "l_armor", "base_info_icons_0003", 3 * s_12},
                                       {"label", "l_magic_armor", "base_info_icons_0004", 3 * s_12},
									   {"label","l_dodge","base_info_icons_0021",1.8 * s_12},
                                       {"label", "l_respawn", "base_info_icons_0007", 2 * s_12}}

	stat_labels[STATS_TYPE_ENEMY] = table.deepclone(stat_labels[STATS_TYPE_SOLDIER])
    stat_labels[STATS_TYPE_ENEMY][8] = {"label", "l_lives", "base_info_icons_0008", 1.5 * s_9}	
	--[[									   	
		stat_labels[STATS_TYPE_TOWER] = {
			{
				"label",
				"l_damage",
				"base_info_icons_0001",
				s_3
			},
			{
				"label",
				"l_range",
				"base_info_icons_0005",
				s_3
			},
			{
				"label",
				"l_cooldown",
				"base_info_icons_0006",
				s_3
			}
		}
		stat_labels[STATS_TYPE_TOWER_NO_RANGE] = {
			{
				"label",
				"l_damage",
				"base_info_icons_0001",
				s_2
			},
			{
				"label",
				"l_cooldown",
				"base_info_icons_0006",
				s_2
			}
		}
	]]--
	stat_labels[STATS_TYPE_TOWER] = {
		{"label","l_damage","base_info_icons_0001",s_3},
		{"label","l_range","base_info_icons_0005",s_3},
		{"label","l_cooldown","base_info_icons_0006",s_3}
	}
	stat_labels[STATS_TYPE_TOWER_NO_RANGE] = {
		{"label","l_damage","base_info_icons_0001",s_2},
		{"label","l_cooldown","base_info_icons_0006",s_2}
}
	stat_labels[STATS_TYPE_TOWER_MAGE] = table.deepclone(stat_labels[STATS_TYPE_TOWER])
	stat_labels[STATS_TYPE_TOWER_MAGE][1][3] = "base_info_icons_0002"
	stat_labels[STATS_TYPE_TEXT] = {
		{
			"label",
			"l_desc",
			nil,
			s_1,
			"left",
			false,
			v(4, CJK(1, -1, 3, -2))
		}
	}
	stat_labels[STATS_TYPE_TEXT_PORTRAIT] = table.deepclone(stat_labels[STATS_TYPE_TEXT])

	local function make_label(icon, w, align, shadow)
		local l

		if icon then
			l = GGLabel:new(V.v(w, label_height), icon)
			l.text_offset = padding
		else
			l = GGLabel:new(V.v(w, label_height))
		end

		l.font_name = "infobar_stats"
		l.font_size = 12
		l.fit_lines = 1
		l.colors.text = {
			255,
			255,
			255,
			255
		}
		l.colors.background = DEBUG_BACKGROUND_COLOR
		l.text_align = align or "left"
		l.text_shadow = shadow
		l.propagate_on_down = true
		l.propagate_on_click = true

		return l
	end

	self.stats_view = nil
	self.stats_views = {}

	for vn, vp in pairs(stat_labels) do
		local sv = KView:new()

		sv.pos = v(100, 33)
		sv.propagate_on_down = true
		sv.propagate_on_click = true
		self.stats_views[vn] = sv

		local off_x = 0

		for i, p in ipairs(vp) do
			if p[1] == "space" then
				off_x = off_x + p[2]
			elseif p[1] == "bar" then
				local _, name, bg_image, fg_image, w = unpack(p)
				local b = KImageView:new(bg_image)
				local bfg = KImageView:new(fg_image)

				b:add_child(bfg)

				bfg.pos.x = (b.size.x - bfg.size.x) / 2
				bfg.pos.y = (b.size.y - bfg.size.y) / 2
				b.pos.x = off_x
				b.bar = bfg
				b.pos.x = (w - b.size.x) / 2
				sv[name] = b

				sv:add_child(b)
			elseif p[1] == "label" then
				local _, l_name, l_icon, l_w, l_align, shadow, custom_padding = unpack(p)
				local l = make_label(l_icon, l_w, l_align, shadow)

				l.pos.x = off_x

				if custom_padding then
					l.pos.x, l.pos.y = l.pos.x + custom_padding.x, l.pos.y + custom_padding.y
				end

				off_x = off_x + l_w
				sv[l_name] = l

				sv:add_child(l)
			end
		end
	end
end

function InfoBar:show()
	log.debug("pos:%s,%s  size:%s,%s", self.pos.x, self.pos.y, self.size.x, self.size.y)
	if self.mode == GUI_MODE_SWAP_TOWER then
		game_gui:hide_ghost_hover()
	end

	local e = game_gui.selected_entity

	if not e or not e.info then
		self:hide()
		return
	end

	if e.info and e.info.i18n_key then
		self.l_name.text = string.upper(_(e.info.i18n_key .. "_NAME"))
	else
		self.l_name.text = string.upper(_(string.upper(e.template_name) .. "_NAME"))
	end

	self:update_portrait()
	self:update_stats()

	if self.tweening then
		timer:cancel(self.tweening)
	end

	self.hidden = false

	local pos_vis_y = self.pos_hidden.y - self.size.y

	if self.pos.y == pos_vis_y then
		return
	end

	local to_y = pos_vis_y

	self.tweening = timer:tween(0.25, self.pos, {
		y = to_y
	}, "out-quad", function()
		self.tweening = nil
	end)
end

function InfoBar:hide()
	if self.hidden then
		return
	end

	if self.tweening then
		timer:cancel(self.tweening)
	end

	local to_y = self.pos_hidden.y

	self.tweening = timer:tween(0.25, self.pos, {
		y = to_y
	}, "in-quad", function()
		self.hidden = true
		self.tweening = nil
	end)
end

function InfoBar:update(dt)
	InfoBar.super.update(self, dt)

	local e = game_gui.selected_entity

	if e and e.ui and not e.ui.can_select then
		game_gui:deselect_all()

		return
	end

	self:update_portrait()
	self:update_stats(dt)
end

function InfoBar:update_portrait()
	local e = game_gui.selected_entity

	if not e or not e.info then
		return
	end

	local boss = infinite_heroes.get_boss(e.template_name)
	self.v_portrait._draw_self = boss and boss.portrait_draw or nil

	if self.v_portrait_image_name ~= e.info.portrait then
		if e.info.portrait then
			self.v_portrait:set_image(e.info.portrait)
			if e.sett_variant or e.boss_owner and e.boss_owner.sett_variant then
				local portrait=self.v_portrait
				local scale=52/math.max(portrait.size.x,portrait.size.y)
				portrait.scale=V.v(scale,scale)
				portrait.anchor=V.v(portrait.size.x/2,portrait.size.y/2)
			else
				self.v_portrait.scale=V.v(1,1)
				self.v_portrait.anchor=V.v(34,34)
			end

			self.v_portrait.hidden = false
			self.v_portrait_image_name = e.info.portrait
		else
			self.v_portrait.hidden = true
			self.v_portrait_image_name = nil
		end
	end
end

local function infobar_combat_stats_number(value)
	value = value or 0

	local rounded = math.floor(value + 0.5)

	if math.abs(value - rounded) < 0.01 then
		return tostring(rounded)
	end

	return string.format("%.1f", value)
end

local function infobar_combat_stats_key(entity)
	if not entity then
		return nil
	end

	if entity.hero then
		return string.format("hero:%s", entity.id)
	end

	if entity.tower then
		local source_id = entity.combat_stats_id

		if entity.tower_upgrade_persistent_data then
			source_id = entity.tower_upgrade_persistent_data.combat_stats_id or source_id
		end

		source_id = source_id or entity.id

		return string.format("tower:%s", source_id)
	end

	return nil
end

function InfoBar:update_combat_stats()
	local damage_label = self.l_combat_damage
	local kills_label = self.l_combat_kills

	if not damage_label or not kills_label then
		return
	end

	local e = game_gui.selected_entity
	local key = infobar_combat_stats_key(e)

	if not key then
		damage_label.hidden = true
		kills_label.hidden = true

		return
	end

	local stats = game_gui.game and game_gui.game.store and game_gui.game.store.combat_stats
	local row = stats and stats.by_source and stats.by_source[key]

	damage_label.text = string.format("Tổng sát thương: %s", infobar_combat_stats_number(row and row.damage or 0))
	kills_label.text = string.format("Tổng hạ gục: %s", row and row.kills or 0)
	damage_label.hidden = false
	kills_label.hidden = false
end

function InfoBar:update_stats()
	local e = game_gui.selected_entity

	if not e or not e.info or not e.info.fn then
		return
	end

	local stats = e.info.fn(e)
	local sv = stats and self.stats_views[stats.type]
	if sv and sv._sett_layout then
		for key,saved in pairs(sv._sett_layout) do
			local label=sv[key]
			label.pos.x,label.size.x,label.hidden=saved.x,saved.width,saved.hidden
		end
	end

	if not sv then
		local missing_key = string.format("%s:%s", tostring(e.id), tostring(stats and stats.type))

		if self.missing_infobar_key ~= missing_key then
			log.error("Entity %s (id %s) has no infobar for stats type %s", tostring(e.template_name), tostring(e.id), tostring(stats and stats.type))
			self.missing_infobar_key = missing_key
		end

		self:hide()

		return
	elseif sv ~= self.stats_view then
		if self.stats_view then
			self:remove_child(self.stats_view)

			self.stats_view = nil
		end

		self.stats_view = sv

		self:add_child(self.stats_view)
	end

	self.missing_infobar_key = nil

	local ddi = data.damage_icons

    if stats.damage_type and stats.yes_melee and band(stats.damage_type, DAMAGE_TRUE) ~= 0 then
        stats.damage_icon = "meleetrue"
    end			
    if stats.damage_type and stats.yes_melee and band(stats.damage_type, DAMAGE_EXPLOSION) ~= 0 then
        stats.damage_icon = "meleeexplosion"
    end			
    if stats.damage_type and stats.yes_melee and band(stats.damage_type, DAMAGE_MAGICAL) ~= 0 then
        stats.damage_icon = "meleemagic"
    end	
    if stats.damage_type and stats.yes_melee and band(stats.damage_type, DAMAGE_ELECTRICAL) ~= 0 then
        stats.damage_icon = "meleeelectrical"
    end	
    if stats.type == STATS_TYPE_TOWER or stats.type == STATS_TYPE_TOWER_MAGE or stats.type == STATS_TYPE_TOWER_NO_RANGE then		
    	if stats.damage_type and band(stats.damage_type, DAMAGE_PHYSICAL) ~= 0 then
    	    stats.damage_icon = "arrow"
    	end		
	end	
	local damage_icon = ddi[stats.damage_icon] or ddi[band(DAMAGE_BASE_TYPES, stats.damage_type or 0)] or ddi.default
----本段代码来自DOVE版
    if stats.ranged_damage_type and not stats.no_ranged and band(stats.ranged_damage_type, DAMAGE_PHYSICAL) ~= 0 then
        stats.ranged_damage_icon = "arrow"
    end	
    if stats.ranged_damage_type and stats.no_ranged and band(stats.ranged_damage_type, DAMAGE_TRUE) ~= 0 then
        stats.ranged_damage_icon = "meleetrue"
    end			
    if stats.ranged_damage_type and stats.no_ranged and band(stats.ranged_damage_type, DAMAGE_EXPLOSION) ~= 0 then
        stats.ranged_damage_icon = "meleeexplosion"
    end			
    if stats.ranged_damage_type and stats.no_ranged and band(stats.ranged_damage_type, DAMAGE_MAGICAL) ~= 0 then
        stats.ranged_damage_icon = "meleemagic"
    end	
    if stats.ranged_damage_type and stats.no_ranged and band(stats.ranged_damage_type, DAMAGE_ELECTRICAL) ~= 0 then
        stats.ranged_damage_icon = "meleeelectrical"
    end	
				
    local ranged_damage_icon = ddi[stats.ranged_damage_icon] or
                                   ddi[band(DAMAGE_BASE_TYPES, stats.ranged_damage_type or 0)] or ddi.default
--[[								   
	if stats.type == STATS_TYPE_TOWER_BARRACK then
		sv.l_hp.text = string.format("%i", stats.hp_max)
		sv.l_damage.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

		sv.l_damage:set_image(damage_icon, V.v(sv.l_damage.size.x, sv.l_damage.size.y))

		sv.l_armor.text = GU.armor_value_desc(stats.armor)
		sv.l_respawn.text = stats.respawn and string.format(_("%i sec."), stats.respawn) or "-"
]]--
----本段代码来自DOVE版
	if stats.type == STATS_TYPE_TOWER_BARRACK then
		sv.l_hp.text = string.format("%i", stats.hp_max)

		sv.l_damage.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)
		sv.l_damage:set_image(damage_icon, V.v(sv.l_damage.size.x, sv.l_damage.size.y))

		sv.l_ranged_damage.text = GU.damage_value_desc(stats.ranged_damage_min, stats.ranged_damage_max)
        sv.l_ranged_damage:set_image(ranged_damage_icon, V.v(sv.l_ranged_damage.size.x, sv.l_ranged_damage.size.y))

--		sv.l_armor.text = GU.armor_value_desc(stats.armor)
		sv.l_armor.text = stats.armor and string.format(_("%i%%"), stats.armor * 100) .. "" .. GU.armor_value_desc(stats.armor) or GU.armor_value_desc(stats.armor)
		sv.l_magic_armor.text =  stats.magic_armor and string.format(_("%i%%"), stats.magic_armor * 100) .. "" .. GU.armor_value_desc(stats.magic_armor) or GU.armor_value_desc(stats.magic_armor)
--		sv.l_magic_armor.text = GU.armor_value_desc(stats.magic_armor)
		sv.l_dodge.text = stats.dodge and string.format(_("%i%%"), stats.dodge_chance * 100) or "-"
		sv.l_respawn.text = stats.respawn and string.format(_("%i sec."), stats.respawn) or "-"	

	elseif stats.type == STATS_TYPE_TOWER or stats.type == STATS_TYPE_TOWER_MAGE then
		sv.l_damage.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

		sv.l_damage:set_image(damage_icon, V.v(sv.l_damage.size.x, sv.l_damage.size.y))

		sv.l_range.text = stats.range and string.format(_("%i"), stats.range * 2) .. " / " .. GU.range_value_desc(stats.range) or GU.range_value_desc(stats.range)
		sv.l_cooldown.text = stats.cooldown and string.format(_("%s sec"), stats.cooldown * 1) .. " / " .. GU.cooldown_value_desc(stats.cooldown) or GU.cooldown_value_desc(stats.cooldown)
	elseif stats.type == STATS_TYPE_TOWER_NO_RANGE then
		sv.l_damage.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

		sv.l_damage:set_image(damage_icon, V.v(sv.l_damage.size.x, sv.l_damage.size.y))

		sv.l_cooldown.text = stats.cooldown and string.format(_("%s sec"), stats.cooldown * 1) .. " / " .. GU.cooldown_value_desc(stats.cooldown) or GU.cooldown_value_desc(stats.cooldown)
--[[		
	elseif stats.type == STATS_TYPE_ENEMY then
		sv.b_hp.bar.scale.x = stats.hp / stats.hp_max

		if stats.immune then
			sv.l_hp.text = _("CArmor9")
		else
			sv.l_hp.text = string.format("%i/%i", stats.hp, stats.hp_max)
		end

		sv.l_damage.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

		sv.l_damage:set_image(damage_icon, V.v(sv.l_damage.size.x, sv.l_damage.size.y))

		if stats.armor ~= 0 or stats.magic_armor == 0 then
			local original_w = sv.l_armor.size.x

			sv.l_armor.text = GU.armor_value_desc(stats.armor)

			sv.l_armor:set_image("base_info_icons_0003", V.v(sv.l_armor.w, sv.l_armor.h))

			sv.l_armor.size.x = original_w
		else
			local original_w = sv.l_armor.size.x

			sv.l_armor.text = GU.armor_value_desc(stats.magic_armor)

			sv.l_armor:set_image("base_info_icons_0004", V.v(sv.l_armor.w, sv.l_armor.h))

			sv.l_armor.size.x = original_w
		end

		sv.l_lives.text = type(stats.lives) == "number" and stats.lives > 0 and stats.lives or "-"		
	elseif stats.type == STATS_TYPE_SOLDIER then
		sv.b_hp.bar.scale.x = stats.hp / stats.hp_max
		sv.l_hp.text = string.format("%i/%i", stats.hp, stats.hp_max)
		sv.l_damage.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

		sv.l_damage:set_image(damage_icon, V.v(sv.l_damage.size.x, sv.l_damage.size.y))

		--sv.l_armor.text = GU.armor_value_desc(stats.armor)
		if stats.armor ~= 0 or stats.magic_armor == 0 or (stats.armor == 0 and stats.magic_armor == 0) then
			local original_w = sv.l_armor.size.x

			sv.l_armor.text = GU.armor_value_desc(stats.armor)

			sv.l_armor:set_image("base_info_icons_0003", V.v(sv.l_armor.w, sv.l_armor.h))

			sv.l_armor.size.x = original_w
		else
			local original_w = sv.l_armor.size.x

			sv.l_armor.text = GU.armor_value_desc(stats.magic_armor)

			sv.l_armor:set_image("base_info_icons_0004", V.v(sv.l_armor.w, sv.l_armor.h))

			sv.l_armor.size.x = original_w
		end
		sv.l_respawn.text = stats.respawn and string.format(_("%i sec."), stats.respawn) or "-"
]]--
----本段代码来自DOVE版
    elseif stats.type == STATS_TYPE_ENEMY then
        sv.b_hp.bar.scale.x = stats.hp / stats.hp_max

        if stats.immune then
            sv.l_hp.text = _("CArmor9")
        else
            sv.l_hp.text = string.format("%i/%i", stats.hp, stats.hp_max)
        end

        sv.l_damage.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)
        sv.l_damage:set_image(damage_icon, V.v(sv.l_damage.size.x, sv.l_damage.size.y))

        sv.l_ranged_damage.text = GU.damage_value_desc(stats.ranged_damage_min, stats.ranged_damage_max)
        sv.l_ranged_damage:set_image(ranged_damage_icon, V.v(sv.l_ranged_damage.size.x, sv.l_ranged_damage.size.y))

		sv.l_armor.text = stats.armor and string.format(_("%i%%"), stats.armor * 100) .. "" .. GU.armor_value_desc(stats.armor) or GU.armor_value_desc(stats.armor)
		sv.l_magic_armor.text =  stats.magic_armor and string.format(_("%i%%"), stats.magic_armor * 100) .. "" .. GU.armor_value_desc(stats.magic_armor) or GU.armor_value_desc(stats.magic_armor)
		sv.l_dodge.text = stats.dodge and string.format(_("%i%%"), stats.dodge_chance * 100) or "-"
        sv.l_lives.text = type(stats.lives) == "number" and stats.lives > 0 and stats.lives or "-"		
	elseif stats.type == STATS_TYPE_SOLDIER then
		sv.b_hp.bar.scale.x = stats.hp / stats.hp_max
		sv.l_hp.text = string.format("%i/%i", stats.hp, stats.hp_max)
		sv.l_damage.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)
		sv.l_damage:set_image(damage_icon, V.v(sv.l_damage.size.x, sv.l_damage.size.y))
        sv.l_ranged_damage.text = GU.damage_value_desc(stats.ranged_damage_min, stats.ranged_damage_max)
        sv.l_ranged_damage:set_image(ranged_damage_icon, V.v(sv.l_ranged_damage.size.x, sv.l_ranged_damage.size.y))
		sv.l_armor.text = stats.armor and string.format(_("%i%%"), stats.armor * 100) .. "" .. GU.armor_value_desc(stats.armor) or GU.armor_value_desc(stats.armor)
		sv.l_magic_armor.text =  stats.magic_armor and string.format(_("%i%%"), stats.magic_armor * 100) .. "" .. GU.armor_value_desc(stats.magic_armor) or GU.armor_value_desc(stats.magic_armor)
		sv.l_dodge.text = stats.dodge and string.format(_("%i%%"), stats.dodge_chance * 100) or "-"
		sv.l_respawn.text = stats.respawn and string.format(_("%i sec."), stats.respawn) or "-"		
	elseif stats.type == STATS_TYPE_TEXT or stats.type == STATS_TYPE_TEXT_PORTRAIT then
		sv.l_desc.text = _(stats.desc)
	end

	if e.sett_variant and stats.type==STATS_TYPE_SOLDIER then
		if not sv._sett_layout then
			sv._sett_layout={}
			for _,key in ipairs({"l_damage","l_ranged_damage","l_armor","l_magic_armor","l_dodge","l_respawn"}) do
				local label=sv[key]
				sv._sett_layout[key]={x=label.pos.x,width=label.size.x,hidden=label.hidden}
			end
		end
		local factor=e.unit.damage_factor*(e.sett_damage_factor and e.sett_damage_factor(e) or 1)
		sv.l_damage.text=string.format("%i / %i",e.melee.attacks[1].damage_min*factor,e.melee.attacks[2].damage_min*factor)
		sv.l_armor.text=string.format("%i%%",stats.armor*100)
		sv.l_magic_armor.text=string.format("%i%%",stats.magic_armor*100)
		sv.l_ranged_damage.hidden=true;sv.l_dodge.hidden=true
		for _,item in ipairs({{"l_damage",120,95},{"l_armor",225,75},{"l_magic_armor",310,75},{"l_respawn",395,85}}) do
			local label=sv[item[1]];label.pos.x,label.size.x=item[2],item[3]
		end
	end
	self:update_combat_stats()
end

HudBottomView = class("HudBottomView", KView)

function HudBottomView:initialize(sw, sh)
	sh = sh + 1

	HudBottomView.super.initialize(self)

	self.propagate_on_click = true

	if IS_KR3 then
		local x = 0
		local vh
		local bg_bar = KView:new()

		while x < sw do
			local v = KImageView:new("base_gui_kr3_tile")

			v.pos.x, v.pos.y = x, 0

			bg_bar:add_child(v)

			x = x + v.size.x
			vh = v.size.y
		end

		bg_bar.propagate_on_click = true
		bg_bar.propagate_on_down = true
		bg_bar.propagate_on_up = true
		bg_bar.anchor = v(0, vh)
		bg_bar.size = v(sw, vh)
		bg_bar.pos = v(0, sh)

		self:add_child(bg_bar)
	else
		local bg_bar = KImageView:new("bg_bottom_bar")

		bg_bar.anchor = v(0, bg_bar.size.y)
		bg_bar.pos = v(0, sh)

		self:add_child(bg_bar)
	end

	local next_wave = IS_KR3 and KView:new(v(120, 36)) or KImageView:new("bg_bottom_right")

	next_wave.anchor = v(next_wave.size.x, next_wave.size.y)
	next_wave.pos = v(sw + 6, sh)
	self.next_wave = next_wave

	self:add_child(next_wave)

	local bg_nextwave = KImageView:new("bg_bottom_nextwave")

	bg_nextwave.anchor = v(math.floor(bg_nextwave.size.x / 2), bg_nextwave.size.y)
	bg_nextwave.pos = v(next_wave.size.x / 2, next_wave.size.y)

	next_wave:add_child(bg_nextwave)

	local next_wave_button = NextWaveButton:new()

	next_wave_button.pos = v(next_wave.size.x / 2, 31)

	next_wave:add_child(next_wave_button)

	if IS_ANDROID then
		-- A hold button, not a click shortcut: game:update reads the state for
		-- as long as the finger remains down, exactly like keyboard isDown("r").
		local r_button = KButton:new(nil, "pause_base")

		r_button.anchor = v(r_button.size.x / 2, r_button.size.y / 2)
		r_button.pos = v(sw - 58, sh - 116)
		r_button.hit_rect = r(35, 6, 90, 80)
		r_button.text = "R"
		r_button.text_size = V.vclone(r_button.size)
		r_button.font_name = "body"
		r_button.font_size = 38
		r_button.text_align = "center"
		r_button.vertical_align = "middle"
		r_button.colors.text = {
			255,
			255,
			255,
			255
		}

		function r_button.on_down(this, button, x, y)
			if button == 1 then
				game_gui:set_android_virtual_r_down(true)
			end
		end

		function r_button.on_up(this, button, x, y)
			if button == 1 then
				game_gui:set_android_virtual_r_down(false)
			end
		end

		function r_button.on_exit(this)
			game_gui:set_android_virtual_r_down(false)
		end

		game_gui.android_r_button = r_button

		self:add_child(r_button)
	end

	local extra_power_count = 0

	if IS_KR3 and hero_ultimate_slot_available("a") then
		extra_power_count = extra_power_count + 1
	end

	if IS_KR3 and hero_ultimate_slot_available("s") then
		extra_power_count = extra_power_count + 1
	end

	local powers = IS_KR3 and KView:new(v(247 + extra_power_count * 63, 36)) or KImageView:new("bg_bottom_left")

	powers.anchor = v(0, powers.size.y)
	powers.pos = v(105, sh)
	powers.hidden = using_hero_rally()
	self.powers = powers

	self:add_child(powers)

	local base_powers = KImageView:new("base_powers_bg")

	base_powers.anchor = v(base_powers.size.x / 2, base_powers.size.y)
	base_powers.pos = v(247 / 2, powers.size.y)

	powers:add_child(base_powers)

	local power_1 = Power1Button:new()

	power_1.cooldown_time = selected_power_cooldown(1)

	
	power_1.pos = IS_KR3 and v(29, 30) or v(59, 30)

	powers:add_child(power_1)

	local power_2 = Power2Button:new()

	power_2.cooldown_time = selected_power_cooldown(2)
	power_2.pos = IS_KR3 and v(92, 30) or v(125, 30)

	powers:add_child(power_2)

	local power_3

	power_3 = Power3Button:new()

	power_3.cooldown_time = selected_power_cooldown(3)
	power_3.pos = v(155, 30)
	powers:add_child(power_3)

	local power_a = HeroUltimateButton:new("a")
	local power_s = HeroUltimateButton:new("s")
	local next_extra_x = 218

	local function add_extra_power(power_button)
		power_button.pos = v(next_extra_x, 30)

		if power_button.available then
			local slot_background = KImageView:new("base_power_slot_bg")

			slot_background.anchor = v(slot_background.size.x / 2, slot_background.size.y)
			slot_background.pos = v(power_button.pos.x + power_button.size.x / 2, powers.size.y)
			powers:add_child(slot_background)
			next_extra_x = next_extra_x + 63
		end

		powers:add_child(power_button)
	end

	add_extra_power(power_a)
	add_extra_power(power_s)

	for i = 1, IS_KR3 and 3 or 2 do
		local pb = ({power_1, power_2, power_3})[i]
		local pn = KImageView:new("power_nbrs_000" .. i)

		pn.anchor = v(pn.size.x / 2, pn.size.y)
		pn.pos = v(pb.pos.x + pb.size.x / 2, powers.size.y)
		pn.hidden = pb.hidden

		powers:add_child(pn)
	end

	local function add_power_key_label(power_button, image_name)
		local label = KImageView:new(image_name)

		label.anchor = v(label.size.x / 2, label.size.y)
		label.pos = v(power_button.pos.x + power_button.size.x / 2, powers.size.y)
		label.hidden = power_button.hidden
		label.propagate_on_click = true
		powers:add_child(label)
	end

	add_power_key_label(power_a, "power_nbrs_a")
	add_power_key_label(power_s, "power_nbrs_s")

	local x_center = math.floor((sw - next_wave.size.x - powers.size.x - powers.pos.x) / 2) + powers.pos.x + powers.size.x

	if not IS_KR3 then
		local bg_center = KImageView:new("bg_bottom_center")

		bg_center.anchor = v(bg_center.size.x / 2, bg_center.size.y)
		bg_center.pos = v(x_center, sh)

		self:add_child(bg_center)
	end

	local infobar = InfoBar:new()

	infobar.anchor = v(math.floor(infobar.size.x / 2), infobar.size.y)
	infobar.pos = v(x_center, sh + infobar.size.y)
	infobar.pos_hidden = V.vclone(infobar.pos)
	infobar.hidden = true
	self.infobar = infobar

	self:add_child(infobar)

	local herobar = KView:new()

	herobar.propagate_on_click = true
	herobar.propagate_on_down = true
	herobar.propagate_on_up = true
	herobar.pos = v(0, sh)
	self.herobar = herobar

	self:add_child(herobar)

	game_gui.power_1 = power_1
	game_gui.power_2 = power_2
	game_gui.power_3 = power_3
	game_gui.power_a = power_a
	game_gui.power_s = power_s
	game_gui.next_wave_button = next_wave_button
end

local function tween_hud_position(view, hidden_offset)
	view._original_pos_y = view._original_pos_y or view.pos.y

	if view._position_tween then
		timer:cancel(view._position_tween)
		view._position_tween = nil
	end

	local target_y = view._original_pos_y + hidden_offset

	if view.pos.y == target_y then
		return
	end

	view._position_tween = timer:tween(1, view.pos, {
		y = target_y
	}, "out-quad", function()
		view.pos.y = target_y
		view._position_tween = nil
	end)
end

function HudBottomView:hide()
	tween_hud_position(self, 110)
end

function HudBottomView:show()
	tween_hud_position(self, 0)
end

function HudBottomView:update_infinite_hero_page(page)
	local portraits = self.hero_portraits or {}
	local pages = math.max(1, math.ceil(#portraits / 2))
	self.infinite_hero_page = math.max(1, math.min(page or 1, pages))
	for n, portrait in ipairs(portraits) do
		portrait.hidden = math.ceil(n / 2) ~= self.infinite_hero_page
		portrait.pos = v(8 + ((n - 1) % 2) * (portrait.size.x - 18), 0)
		portrait:set_style(nil)
		if portrait.infinite_skill then
			local skill = portrait.infinite_skill
			skill.hidden = portrait.hidden
			skill.pos = v(29 + ((n - 1) % 2) * 63, 30 - game_gui.power_1.size.y - 8)
			local background = portrait.infinite_skill_background
			background.hidden = portrait.hidden
			background.pos = v(skill.pos.x + game_gui.power_1.size.x / 2, self.powers.size.y - game_gui.power_1.size.y - 8)
		end
	end
	self.powers.pos.x = 175
	if not self.infinite_pager then
		local pager = KView:new(v(130, 24))
		pager.colors.background = {37, 31, 22, 245}
		self.herobar:add_child(pager)
		self.infinite_pager = pager
		local label = GGLabel:new(v(66, 24))
		label.pos = v(32, 0); label.font_name = "hud"; label.font_size = 12
		label.text_align = "center"; label.vertical_align = "middle"; label.fit_size = true
		label.colors.text = {255, 239, 202, 255}
		pager:add_child(label); self.infinite_page_label = label
		for _, direction in ipairs({-1, 1}) do
			local step = direction
			local button = KView:new(v(30, 24))
			button.pos = v(step < 0 and 0 or 100, 0)
			button.colors.background = {70, 80, 40, 255}
			local arrow = GGLabel:new(v(30, 24))
			arrow.text = step < 0 and "<" or ">"; arrow.font_name = "hud"; arrow.font_size = 15
			arrow.text_align = "center"; arrow.vertical_align = "middle"
			arrow.colors.text = {255, 239, 202, 255}; arrow.propagate_on_click = true
			button:add_child(arrow)
			function button.on_click(_, mouse_button)
				if mouse_button ~= nil and mouse_button ~= 1 then return end
				game_gui:deselect_all()
				local count = math.max(1, math.ceil(#self.hero_portraits / 2))
				self:update_infinite_hero_page((self.infinite_hero_page - 1 + step) % count + 1)
			end
			pager:add_child(button)
		end
	end
	if portraits[1] then
		self.infinite_pager.pos = v(8 + math.floor((2 * portraits[1].size.x - 18 - 130) / 2), -portraits[1].size.y - 28)
	end
	self.infinite_pager.hidden = pages <= 1
	self.infinite_page_label.text = tostring(self.infinite_hero_page) .. "/" .. pages
	self.herobar:order_to_front()
end

function HudBottomView:add_hero(hero_entity)
	local hero = HeroPortrait:new(hero_entity)
	local rally = using_hero_rally()

	hero.anchor = v(0, hero.size.y)

	self.herobar:add_child(hero)

	if rally then
		self.herobar:order_to_front()
	end

	self.hero_portraits = self.hero_portraits or {}
	table.insert(self.hero_portraits, hero)

	local hero_count = #self.hero_portraits
	if infinite_heroes.active(game_gui.game and game_gui.game.store) then
		local ultimate = hero_entity.hero and hero_entity.hero.skills and hero_entity.hero.skills.ultimate
		if ultimate and ultimate.controller_name then
			local skill = InfiniteHeroUltimateButton:new(hero_entity)
			skill.scale = v(game_gui.power_1.size.x / skill.size.x, game_gui.power_1.size.y / skill.size.y)
			local background = KImageView:new("base_power_slot_bg")
			background.anchor = v(background.size.x / 2, background.size.y)
			self.powers:add_child(background)
			self.powers:add_child(skill)
			hero.infinite_skill = skill
			hero.infinite_skill_background = background
		end
		self:update_infinite_hero_page(self.infinite_hero_page or 1)
		return hero
	end
	local visible_limit = rally and 4 or 2

	if hero_count > visible_limit then
		hero.hidden = true

		return hero
	end

	if rally then
		for i = 1, hero_count do
			local portrait = self.hero_portraits[i]

			portrait.hidden = false
			portrait.pos = v(15 + (i - 1) * portrait.size.x, 0)
			portrait:set_style(nil)
		end

		return hero
	end

	local overlap = 18
	local start_x = hero_count == 1 and 15 or 8
	local step_x = hero.size.x - overlap

	for i = 1, hero_count do
		local portrait = self.hero_portraits[i]
		local style

		if hero_count > 1 then
			style = i == 1 and "left" or i == hero_count and "right" or nil
		end

		portrait.hidden = false
		portrait.pos = v(start_x + (i - 1) * step_x, 0)
		portrait:set_style(style)
	end

	if hero_count > 1 then
		local separator = KImageView:new("heroPortrait_separator")

		separator.anchor = v(separator.size.x / 2, hero.size.y)
		separator.pos = v(start_x + (hero_count - 1) * step_x + overlap / 2, 3)
		separator.propagate_on_click = true
		separator.propagate_on_down = true
		separator.propagate_on_up = true

		self.herobar:add_child(separator)
		self.powers.pos.x = 175
	else
		self.powers.pos.x = 105
	end

	return hero
end

UnifiedBossHealthBar = class("UnifiedBossHealthBar", KView)

local function add_boss_bar_part(parent, child)
	child.propagate_on_click = true
	child.propagate_on_down = true
	child.propagate_on_up = true
	parent:add_child(child)

	return child
end

function UnifiedBossHealthBar:initialize(entity)
	UnifiedBossHealthBar.super.initialize(self, v(370, 46))

	self.entity = entity
	self.anchor = v(185, 0)
	self.propagate_on_click = true
	self.propagate_on_down = true
	self.propagate_on_up = true
	self.colors.background = {122, 89, 46, 245}
	self.shape = {name = "rectangle", args = {"fill", 0, 0, 370, 46, 5, 5}}

	local inset = add_boss_bar_part(self, KView:new(v(366, 42)))

	inset.pos = v(2, 2)
	inset.colors.background = {26, 25, 23, 245}
	inset.shape = {name = "rectangle", args = {"fill", 0, 0, 366, 42, 4, 4}}

	local title = add_boss_bar_part(self, GGLabel:new(v(240, 19)))

	title.pos = v(12, 5)
	title.font_name = "hud"
	title.font_size = 12
	title.text_align = "left"
	title.vertical_align = "middle"
	title.fit_size = true
	title.fit_lines = 1
	title.colors.text = {255, 239, 202, 255}
	self.title = title

	local hp_label = add_boss_bar_part(self, GGLabel:new(v(103, 19)))

	hp_label.pos = v(255, 5)
	hp_label.font_name = "hud"
	hp_label.font_size = 10
	hp_label.text_align = "right"
	hp_label.vertical_align = "middle"
	hp_label.fit_size = true
	hp_label.fit_lines = 1
	hp_label.colors.text = {234, 211, 172, 255}
	self.hp_label = hp_label

	local track = add_boss_bar_part(self, KView:new(v(348, 12)))

	track.pos = v(11, 29)
	track.colors.background = {9, 10, 11, 255}
	track.shape = {name = "rectangle", args = {"fill", 0, 0, 348, 12, 3, 3}}

	local fill = add_boss_bar_part(self, KView:new(v(344, 8)))

	fill.pos = v(13, 31)
	fill.colors.background = {195, 57, 45, 255}
	fill.shape = {name = "rectangle", args = {"fill", 0, 0, 344, 8, 2, 2}}
	self.fill = fill

	local key = entity.info and entity.info.i18n_key or string.upper(entity.template_name or "BOSS")
	local name_key = key .. "_NAME"
	local name = _(name_key)

	self.title.text = name and name ~= name_key and name or (entity.template_name or "BOSS"):gsub("_", " ")
end

function UnifiedBossHealthBar:update(dt)
	UnifiedBossHealthBar.super.update(self, dt)

	local health = self.entity and self.entity.health

	if health and type(health.hp) == "number" and type(health.hp_max) == "number" and health.hp_max > 0 then
		local hp = math.max(0, health.hp)

		self.fill.scale.x = math.max(0, math.min(1, hp / health.hp_max))
		self.hp_label.text = string.format("%d / %d", math.ceil(hp), math.ceil(health.hp_max))
	end
end

HudCountersView = class("HudCountersView", KImageView)

function HudCountersView:initialize()
	HudCountersView.super.initialize(self, "top_left")

	local lbl_lives = GGLabel:new(V.v(71, 35))

	lbl_lives.pos = v(80, CJK(44, 42, 46, 39))
	lbl_lives.text = "0"
	lbl_lives.text_align = "left"
	lbl_lives.vertical_align = nil
	lbl_lives.font_name = "hud"
	lbl_lives.font_size = 12
	lbl_lives.mobile_font_factor = 1
	lbl_lives.colors.text = {
		255,
		255,
		255
	}

	local lbl_gold = GGLabel:new(V.v(71, 35))

	lbl_gold.pos = v(136, CJK(44, 42, 46, 39))
	lbl_gold.text = "1000"
	lbl_gold.text_align = "left"
	lbl_gold.vertical_align = nil
	lbl_gold.font_name = "hud"
	lbl_gold.font_size = 12
	lbl_gold.mobile_font_factor = 1
	lbl_gold.colors.text = {
		255,
		255,
		255
	}

	local lbl_wave = GGLabel:new(V.v(74, 18))

	lbl_wave.pos = v(243, CJK(42, 42, 43, 40))
	lbl_wave.text_align = "left"
	lbl_wave.vertical_align = "middle-caps"
	lbl_wave.font_name = "hud"
	lbl_wave.font_size = 11
	lbl_wave.mobile_font_factor = 1
	lbl_wave.fit_step = 0.25
	lbl_wave.fit_lines = 1
	lbl_wave.colors.text = {
		255,
		255,
		255
	}
	lbl_wave.colors.background = DEBUG_BACKGROUND_COLOR

	self:add_child(lbl_lives)
	self:add_child(lbl_gold)
	self:add_child(lbl_wave)

	self.lbl_lives = lbl_lives
	self.lbl_gold = lbl_gold
	self.lbl_wave = lbl_wave
end

function HudCountersView:update(dt)
	local store = game_gui.game.store

	self.lbl_lives.text = string.format("%d", store.lives)
	self.lbl_gold.text = string.format("%d", store.player_gold)
	self.lbl_wave.text = string.format(_("MENU_HUD_WAVES"), store.wave_group_number, store.wave_group_total)
end

function HudCountersView:hide()
	tween_hud_position(self, -self.size.y)
end

function HudCountersView:show()
	tween_hud_position(self, 0)
end

OverlayView = class("OverlayView", KView)

function OverlayView:initialize(sw, sh)
	OverlayView.super.initialize(self, V.v(sw, sh))

	self.colors.background = {
		0,
		0,
		0,
		120
	}
	self.sw = sw
	self.sh = sh
	self.propagate_on_click = false
	self.propagate_on_down = false
	self.propagate_on_up = false
	self.propagate_on_enter = false
end

function OverlayView:show()
	if self.tweener then
		timer:cancel(self.tweener)
	end

	self.tweener = timer:tween(0.25, self.colors.background, {
		0,
		0,
		0,
		120
	}, "in-quad", function()
		self.tweener = nil
	end)
	self.propagating = false
	self.hidden = false
end

function OverlayView:hide()
	if self.tweener then
		timer:cancel(self.tweener)
	end

	self.tweener = timer:tween(0.25, self.colors.background, {
		0,
		0,
		0,
		1
	}, "in-quad", function()
		self.hidden = true
		self.tweener = nil
	end)
end

HudPauseButton = class("HudPauseButton", KImageView)

function HudPauseButton:initialize()
	HudPauseButton.super.initialize(self, "pause_base")

	local button = KImageButton:new("pause_btn_0001", "pause_btn_0002", "pause_btn_0002")

	button.anchor = v(button.size.x / 2, 0)
	button.pos = v(self.size.x / 2, 25)

	function button.on_click()
		S:queue("GUIButtonCommon")
		game_gui.pauseview:show()
	end

	self:add_child(button)
	self.speed_buttons = {}
	for index = 1, 2 do
		local speed_button = GGButton:new("pause_base", "pause_base", "pause_base")
		speed_button.id = index == 1 and "speed_slow" or "speed_fast"
		speed_button.pos = v(self.size.x / 2 - (3 - index) * self.size.x * 76 / 160, self.size.y / 2)
		speed_button.hit_rect = r(self.size.x * 43 / 160, self.size.y * 9 / 92, self.size.x * 74 / 160, self.size.y * 78 / 92)
		speed_button.label.pos = v(0, 25 + button.size.y / 2 - self.size.y / 2)
		speed_button.label.font_size = 26
		speed_button.label.vertical_align = "middle"
		function speed_button:on_click(mouse_button)
			if mouse_button ~= 1 or game_gui.keys_disabled or game_gui.game.store.paused then return end
			S:queue("GUIButtonCommon")
			local current = game_gui.game.playback_speed
			local next_speed
			if self.id == "speed_slow" then
				next_speed = current == "slow" and 1 or "slow"
			else
				next_speed = current == 4 and 12 or current == 12 and 1 or 4
			end
			self.parent:set_speed(next_speed)
		end
		self.speed_buttons[index] = speed_button
		self:add_child(speed_button)
	end
	self:set_speed(1)
end

function HudPauseButton:set_speed(speed)
	game_gui.game.playback_speed = speed
	game_gui.game.upd = 0
	for index, button in pairs(self.speed_buttons) do
		local selected = index == 1 and speed == "slow" or index == 2 and (speed == 4 or speed == 12)
		button.label.text = index == 1 and "Q" or speed == 12 and "R" or "E"
		button.label_colors.default = selected and {255, 218, 80, 255} or {233, 233, 178, 255}
		button.label.colors.text = button.label_colors.default
		button.label.canvases_drawn = nil
	end
end

function HudPauseButton:hide()
	tween_hud_position(self, -self.size.y)
end

function HudPauseButton:show()
	tween_hud_position(self, 0)
end

local function combat_stats_number(value)
	value = value or 0

	local rounded = math.floor(value + 0.5)

	if math.abs(value - rounded) < 0.01 then
		return tostring(rounded)
	end

	return string.format("%.1f", value)
end

local function combat_stats_label(size, text, font_size, align, color)
	local label = GGLabel:new(size)

	label.text = text or ""
	label.font_name = "body"
	label.font_size = font_size or 15
	label.text_align = align or "left"
	label.vertical_align = "middle"
	label.fit_lines = 1
	label.propagate_on_down = true
	label.propagate_on_up = true
	label.propagate_on_click = true
	label.colors.text = color or {
		62,
		43,
		23,
		255
	}

	return label
end

CombatStatsView = class("CombatStatsView", KView)

function CombatStatsView:initialize(sw, sh)
	CombatStatsView.super.initialize(self, V.v(620, 430))

	self.sw = sw
	self.sh = sh
	self.hit_rect = V.r(-sw, -sh, sw * 2, sh * 2)
	self.colors.background = {
		239,
		215,
		146,
		245
	}
	self.propagate_on_click = false
	self.propagate_on_down = false
	self.propagate_on_up = false

	local title = combat_stats_label(V.v(self.size.x, 34), "Thống kê", 25, "center", {
		92,
		53,
		30,
		255
	})

	title.pos = V.v(0, 14)
	self:add_child(title)

	local close = GGOptionsButton:new("Đóng")

	close.pos = V.v(self.size.x - close.size.x / 2 - 14, 18 + close.size.y / 2)

	function close.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end

	self:add_child(close)
	self.tab_buttons = {}

	for i, tab in ipairs({{id = "damage", label = "Sát thương"}, {id = "earnings", label = "Thu nhập"}}) do
		local tab_id = tab.id
		local button = KView:new(V.v(112, 28))
		local label = combat_stats_label(V.v(112, 28), tab.label, 16, "center")

		button.pos = V.v(190 + (i - 1) * 122, 52)
		button.propagate_on_click = false
		button.propagate_on_down = false
		button.propagate_on_up = false
		button:add_child(label)
		self:add_child(button)
		self.tab_buttons[tab_id] = {view = button, label = label}

		function button.on_click()
			S:queue("GUIButtonCommon")
			self:set_tab(tab_id)
		end
	end

	local summary = combat_stats_label(V.v(self.size.x - 40, 26), "", 16, "center")

	summary.pos = V.v(20, 83)
	self:add_child(summary)
	self.summary_label = summary

	local header = KView:new(V.v(self.size.x - 40, 28))

	header.pos = V.v(20, 112)
	header.colors.background = {
		126,
		82,
		35,
		210
	}
	self:add_child(header)

	local header_color = {
		255,
		238,
		184,
		255
	}

	local h_id = combat_stats_label(V.v(72, 28), "ID", 15, "center", header_color)
	local h_template = combat_stats_label(V.v(300, 28), "Nguồn", 15, "left", header_color)
	local h_damage = combat_stats_label(V.v(104, 28), "Sát thương", 15, "right", header_color)
	local h_kills = combat_stats_label(V.v(70, 28), "Hạ gục", 15, "right", header_color)

	h_id.pos = V.v(0, 0)
	h_template.pos = V.v(78, 0)
	h_damage.pos = V.v(382, 0)
	h_kills.pos = V.v(492, 0)
	header:add_child(h_id)
	header:add_child(h_template)
	header:add_child(h_damage)
	header:add_child(h_kills)
	self.header_id = h_id
	self.header_template = h_template
	self.header_damage = h_damage
	self.header_kills = h_kills

	local list = KScrollList:new(V.v(self.size.x - 40, 252))

	list.pos = V.v(20, 144)
	list.scroll_amount = 28
	list.scroll_acceleration = 1.8
	list.colors.background = {
		255,
		239,
		178,
		90
	}
	list.colors.scroller_background = {
		126,
		82,
		35,
		90
	}
	list.colors.scroller_foreground = {
		126,
		82,
		35,
		230
	}
	list:set_scroller_size(10, 2)
	self:add_child(list)
	self.list = list
	self.active_tab = "damage"
	self:set_tab("damage")
end

function CombatStatsView:_draw_self()
	CombatStatsView.super._draw_self(self)

	G.setColor({
		96,
		61,
		28,
		255
	})
	G.setLineWidth(4)
	G.rectangle("line", 0, 0, self.size.x, self.size.y)
	G.setLineWidth(1)
end

function CombatStatsView:add_stats_row(index, row)
	local view = KView:new(V.v(self.list.size.x, 28))

	view.propagate_on_down = true
	view.propagate_on_up = true
	view.propagate_on_click = true

	view.colors.background = index % 2 == 0 and {
		255,
		245,
		198,
		110
	} or {
		255,
		235,
		169,
		70
	}

	local source_id = row.source_id and tostring(row.source_id) or ""
	local template_name = row.template_name or "unknown"
	local color = {
		48,
		35,
		20,
		255
	}
	local id_label = combat_stats_label(V.v(72, 28), source_id, 13, "center", color)
	local template_label = combat_stats_label(V.v(300, 28), template_name, 13, "left", color)
	local damage_label = combat_stats_label(V.v(104, 28), combat_stats_number(row.damage), 13, "right", color)
	local kills_label = combat_stats_label(V.v(70, 28), tostring(row.kills or 0), 13, "right", color)

	id_label.pos = V.v(0, 0)
	template_label.pos = V.v(78, 0)
	damage_label.pos = V.v(382, 0)
	kills_label.pos = V.v(492, 0)
	view:add_child(id_label)
	view:add_child(template_label)
	view:add_child(damage_label)
	view:add_child(kills_label)

	self.list:add_row(view)
end

function CombatStatsView:add_earnings_row(index, source, amount)
	local view = KView:new(V.v(self.list.size.x, 28))

	view.propagate_on_down = true
	view.propagate_on_up = true
	view.propagate_on_click = true
	view.colors.background = index % 2 == 0 and {255, 245, 198, 110} or {255, 235, 169, 70}

	local color = {48, 35, 20, 255}
	local source_label = combat_stats_label(V.v(420, 28), source.label, 14, "left", color)
	local amount_label = combat_stats_label(V.v(120, 28), combat_stats_number(amount), 14, "right", color)

	source_label.pos = V.v(12, 0)
	amount_label.pos = V.v(432, 0)
	view:add_child(source_label)
	view:add_child(amount_label)
	self.list:add_row(view)
end

function CombatStatsView:set_tab(tab)
	self.active_tab = tab

	for id, button in pairs(self.tab_buttons) do
		local selected = id == tab

		button.view.colors.background = selected and {126, 82, 35, 230} or {204, 169, 105, 200}
		button.label.colors.text = selected and {255, 238, 184, 255} or {62, 43, 23, 255}
	end

	local earnings = tab == "earnings"

	self.header_id.hidden = earnings
	self.header_kills.hidden = earnings
	self.header_template.pos.x = earnings and 12 or 78
	self.header_template.size.x = earnings and 420 or 300
	self.header_damage.pos.x = earnings and 432 or 382
	self.header_damage.size.x = earnings and 120 or 104
	self.header_damage.text = earnings and "Thu nhập" or "Sát thương"

	if self.store then
		self:refresh(self.store)
	end
end

function CombatStatsView:refresh_earnings(store)
	local stats = store and store.earnings_stats
	local by_source = stats and stats.by_source or {}
	local active_count = 0

	for _, source in ipairs(earnings_stats.sources) do
		if (by_source[source.id] or 0) > 0 then
			active_count = active_count + 1
		end
	end

	self.summary_label.text = string.format("Thu nhập ghi nhận: %s    Số nguồn thu: %d", combat_stats_number(stats and stats.total or 0), active_count)
	self.list:clear_rows()

	local row_index = 0

	for _, source in ipairs(earnings_stats.sources) do
		local amount = by_source[source.id] or 0

		if amount > 0 then
			row_index = row_index + 1
			self:add_earnings_row(row_index, source, amount)
		end
	end
end

function CombatStatsView:refresh(store)
	if self.active_tab == "earnings" then
		self:refresh_earnings(store)
		return
	end

	local stats = store and store.combat_stats
	local rows = {}

	if stats and stats.by_source then
		for _, row in pairs(stats.by_source) do
			if (row.damage and row.damage > 0) or (row.kills and row.kills > 0) then
				table.insert(rows, row)
			end
		end
	end

	table.sort(rows, function(a, b)
		local ad = a.damage or 0
		local bd = b.damage or 0
		local ak = a.kills or 0
		local bk = b.kills or 0

		if ad ~= bd then
			return ad > bd
		end

		if ak ~= bk then
			return ak > bk
		end

		return tostring(a.template_name or "") < tostring(b.template_name or "")
	end)

	self.summary_label.text = string.format("Tổng sát thương: %s    Hạ gục: %s    Nguồn: %s", combat_stats_number(stats and stats.total_damage or 0), stats and stats.total_kills or 0, #rows)
	self.list:clear_rows()

	if #rows == 0 then
		local empty = KView:new(V.v(self.list.size.x, 42))
		local label = combat_stats_label(V.v(self.list.size.x, 42), "Chưa ghi nhận sát thương lên kẻ địch", 16, "center")

		empty.propagate_on_down = true
		empty.propagate_on_up = true
		empty.propagate_on_click = true
		empty:add_child(label)
		self.list:add_row(empty)
	else
		for i, row in ipairs(rows) do
			self:add_stats_row(i, row)
		end
	end
end

function CombatStatsView:show(store)
	self.store = store
	self:set_tab("damage")
	self.hidden = false
	self:order_to_front()
end

function CombatStatsView:hide()
	self.hidden = true
end

PauseView = class("PauseView", KImageView)

function PauseView:initialize()
	PauseView.super.initialize(self, "options_bg_notxt")

	local header = GGPanelHeader:new(_("OPTIONS"), 170)

	header.pos = V.v(172, CJK(30, 28, nil, 28) + (IS_KR3 and -16 or 0))

	self:add_child(header)

	local mx = 100
	local y = 100
	local title = GGOptionsLabel:new(V.v(self.size.x, 28))

	title.text = _("SFX")
	title.pos = V.v(self.size.x / 2, y)
	title.anchor.x = title.size.x / 2
	title.vertical_align = "middle"

	self:add_child(title)

	y = y + title.size.y + 6

	local s_sfx = VolumeSlider:new("options_sounds_0004", "options_sounds_0005", "options_sounds_0006")

	s_sfx.pos = V.v(mx, y)

	function s_sfx:on_change(value)
		S:set_main_gain_fx(value, game_gui.game.store.active_sound_sources)
	end

	s_sfx.id = "s_sfx"

	self:add_child(s_sfx)

	y = y + 50
	title = GGOptionsLabel:new(V.v(self.size.x, 28))
	title.text = _("Music")
	title.pos = V.v(self.size.x / 2, y)
	title.anchor.x = title.size.x / 2
	title.vertical_align = "middle"

	self:add_child(title)

	y = y + title.size.y + 6

	local s_music = VolumeSlider:new("options_sounds_0001", "options_sounds_0002", "options_sounds_0003")

	function s_music:on_change(value)
		S:set_main_gain_music(value, game_gui.game.store.active_sound_sources)
	end

	s_music.pos = V.v(mx, y)
	s_music.id = "s_music"

	self:add_child(s_music)

	mx = 45
	y = y + 90 + 30

	local b

	b = GGOptionsButton:new("Thống kê")
	b.pos = V.v(math.ceil(self.size.x / 2), y - 55)

	self:add_child(b)

	function b.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")
		game_gui:show_combat_stats()
	end

	b = GGOptionsButton:new(_("BUTTON_QUIT"))
	b.pos = V.v(mx + b.size.x / 2, y)

	self:add_child(b)

	function b.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")
		game_gui:go_to_map()
	end

	b = GGOptionsButton:new(_("BUTTON_RESTART"))
	b.pos = V.v(math.ceil(self.size.x / 2), y)

	self:add_child(b)

	function b.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")
		game_gui:restart_game()
	end

	b = GGOptionsButton:new(_("BUTTON_RESUME"))
	b.pos = V.v(self.size.x - mx - b.size.x / 2, y)

	self:add_child(b)

	function b.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")
		self:hide()
	end
	--英雄距离显示
	b = GGOptionsButton:new(_("BUTTON_MELEE_RANGE"))
	b.pos = V.v( 2 * mx + b.size.x - self.size.x / 2, y)

	self:add_child(b)

	function b.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")
		screen_map.user_data.true_melee_range =  not screen_map.user_data.true_melee_range
		storage:save_slot(screen_map.user_data)
	end

	local settings = storage:load_settings()

	if settings then
		if settings.volume_fx and type(settings.volume_fx) == "number" then
			s_sfx:set_value(km.clamp(0, 1, settings.volume_fx))
		end

		if settings.volume_music and type(settings.volume_music) == "number" then
			s_music:set_value(km.clamp(0, 1, settings.volume_music))
		end
	end
end

function PauseView:show()
	if self.tweener then
		timer:cancel(self.tweener)
	end

	game_gui:disable_keys()
	game_gui:deselect_all()
	S:pause()
	self:disable(false)

	game_gui.game.store.paused = true

	game_gui.overlay:show()

	self.pos.y = game_gui.sh / 2 - 50
	self.hidden = false
	self.alpha = 0
	self.tweener = timer:tween(0.25, self, {
		alpha = 1,
		pos = {
			y = self.pos.y + 50
		}
	}, "out-quad", function()
		self:enable()

		self.tweener = nil
	end)
	self._last_volume_fx = km.clamp(0, 1, self:get_child_by_id("s_sfx").value)
	self._last_volume_music = km.clamp(0, 1, self:get_child_by_id("s_music").value)
end

function PauseView:hide()
	if self.tweener then
		timer:cancel(self.tweener)
	end

	game_gui:enable_keys()
	self:disable(false)
	S:resume()

	game_gui.game.store.paused = false

	game_gui.overlay:hide()

	self.tweener = timer:tween(0.25, self, {
		alpha = 0,
		pos = {
			y = self.pos.y - 50
		}
	}, "out-quad", function()
		self.hidden = true
		self.tweener = nil
	end)

	local s_sfx = self:get_child_by_id("s_sfx")
	local s_music = self:get_child_by_id("s_music")

	if self._last_volume_fx ~= s_sfx.value or self._last_volume_music ~= s_music.value then
		local settings = storage:load_settings()

		settings.volume_fx = km.clamp(0, 1, s_sfx.value)
		settings.volume_music = km.clamp(0, 1, s_music.value)

		storage:save_settings(settings)
	end
end

DefeatView = class("DefeatView", KImageView)

function DefeatView:initialize()
	DefeatView.super.initialize(self, "defeat_bg_notxt")

	local header = GGPanelHeader:new(_("DEFEAT"), 140)

	header.pos = V.v(160, CJK(81, 81, 83) + (IS_KR3 and -16 or 0))

	self:add_child(header)

	local l_tip = GGLabel:new(V.v(246, 90))

	l_tip.anchor.x = l_tip.size.x / 2
	l_tip.text = _(string.format("TIP_%i", math.random(1, GS.gameplay_tips_count)))
	l_tip.text_align = "center"
	l_tip.font_name = "body"
	l_tip.vertical_align = "middle"
	l_tip.font_size = 15
	l_tip.fit_size = true
	l_tip.colors.text = {
		255,
		255,
		255,
		255
	}
	l_tip.pos.x, l_tip.pos.y = self.size.x / 2, 155

	self:add_child(l_tip)

	self.l_tip = l_tip

	local mx = 84
	local y = 278
	local b

	b = GGOptionsButton(_("BUTTON_STATISTICS"))
	b.pos.x, b.pos.y = V.csnap(self.size.x / 2, y + b.size.y * 4)

	function b.on_click()
		S:queue("GUIButtonCommon")
		game_gui:show_combat_stats()
	end

	self:add_child(b)

	b = GGOptionsButton(_("BUTTON_RESTART"))
	b.pos.x, b.pos.y = V.csnap(mx + b.size.x / 2, y + b.size.y / 2)

	function b.on_click()
		log.debug("RETRY")
		game_gui:restart_game()
	end

	self:add_child(b)

	b = GGOptionsButton(_("Quit"))
	b.pos.x, b.pos.y = V.csnap(self.size.x - mx - b.size.x / 2, y + b.size.y / 2)

	function b.on_click()
		log.debug("QUIT")
		game_gui:go_to_map()
	end

	self:add_child(b)
end

function DefeatView:show()
	game_gui.overlay:show()

	self.hidden = false
	self.l_tip.text = _(string.format("TIP_%i", math.random(1, GS.gameplay_tips_count)))

	S:stop_all()
	S:queue("GUIQuestFailed")

	self.pos.y = -game_gui.sw / 2

	timer:tween(0.5, self.pos, {
		y = game_gui.sh / 2
	}, "out-back", nil, 1)
end

VictoryParticles = class("VictoryParticles", KView)

function VictoryParticles:initialize(w, h)
	VictoryParticles.super.initialize(self)

	local ss = I:s("victory_star")
	local p_scale = ss.ref_scale or 1
	local c = G.newCanvas(ss.size[1], ss.size[2])

	G.setCanvas(c)
	G.draw(I:i(ss.atlas), ss.quad)
	G.setCanvas()

	local ps = G.newParticleSystem(c, 500)

	ps:setDirection(-math.pi / 2)
	ps:setSpread(2 * math.pi / 3)
	ps:setSizes(1 * p_scale, 1.4 * p_scale)
	ps:setLinearAcceleration(0, 2000)
	ps:setParticleLifetime(0, 1.5)
	ps:setSpeed(400, 1000)
	ps:setRadialAcceleration(-200)
	ps:setColors(255, 255, 255, 255, 255, 255, 255, 0)
	ps:emit(150)

	self.ps = ps
	self.ss = ss
end

function VictoryParticles:update(dt)
	VictoryParticles.super.update(self, dt)
	self.ps:update(dt)
end

function VictoryParticles:draw()
	G.setBlendMode("add")
	G.draw(self.ps, 0, 0)
	G.setBlendMode("alpha")
	VictoryParticles.super.draw(self)
end

VictoryView = class("VictoryView", KView)

function VictoryView:initialize(level_mode)
	VictoryView.super.initialize(self)

	self.level_mode = level_mode

	local img_names = {
		[GAME_MODE_CAMPAIGN] = "victoryBadges_notxt_0002",
		[GAME_MODE_HEROIC] = "victoryBadges_notxt_0003",
		[GAME_MODE_IRON] = "victoryBadges_notxt_0001"
	}
	local v_badge = KImageView:new(img_names[level_mode])
	local vw, vh = v_badge.size.x, v_badge.size.y

	v_badge.anchor.x = vw / 2
	v_badge.anchor.y = 0
	v_badge.pos.x, v_badge.pos.y = vw / 2, 0
	v_badge.propagate_on_click = true

	local ct = GGEllipseText:new(V.v(320, -30))

	ct.pos.x, ct.pos.y = v_badge.size.x / 2, 235
	ct.anchor.x = ct.size.x / 2
	ct.text = _("VICTORY")
	ct.font_name = "h_noti"
	ct.font_size = 78
	ct.mobile_font_factor = 1
	ct.colors.text = {
		76,
		56,
		23
	}
	-- Rotating every glyph works for the Latin title, but makes the two large
	-- Chinese glyphs lean in opposite directions on the mobile result screen.
	ct.max_angle = IS_ANDROID and 0 or math.pi / 6

	v_badge:add_child(ct)

	local v_stars = KImageView:new("victoryStars_0001")

	v_stars.anchor.x = v_stars.size.x / 2
	v_stars.pos.x, v_stars.pos.y = vw / 2, 230
	v_stars.hidden = true
	v_stars.animations = {
		{
			to = 19,
			prefix = "victoryStars",
			from = 1
		},
		{
			to = 38,
			prefix = "victoryStars",
			from = 1
		},
		{
			to = 54,
			prefix = "victoryStars",
			from = 1
		}
	}

	if level_mode == GAME_MODE_IRON then
		v_stars.pos.y = v_stars.pos.y + 40
	end

	local v_c = KView:new()
	local c = KImageView:new("button_continue_chains")
	local b = GGBorderButton(_("BUTTON_CONTINUE"), true)
	b.label.mobile_font_factor = 1

	c.anchor.x = c.size.x / 2
	c.anchor.y = c.size.y + 0.9 * b.size.y
	c.pos.x = vw / 2
	c.pos.y = 0
	b.pos.x = c.size.x / 2
	b.pos.y = c.size.y + 0.125 * b.size.y

	function b.on_click()
		log.debug("CONTINUE")
		game_gui:go_to_map()
	end

	c:disable(false)
	c:add_child(b)
	v_c:add_child(c)

	v_c.propagate_on_click = true
	v_c.propagate_on_down = true
	v_c.clip = true
	v_c.size.x = vw
	v_c.size.y = vh
	v_c.anchor.x = vw / 2
	v_c.anchor.y = 0
	v_c.pos.x = vw / 2
	v_c.pos.y = 300

	local v_r = KView:new()
	local c = KImageView:new("button_restart_chains")
	local b = GGBorderButton(_("BUTTON_RESTART"))
	b.label.mobile_font_factor = 1

	c.anchor.x = c.size.x / 2
	c.anchor.y = c.size.y + 0.9 * b.size.y
	c.pos.x = vw / 2
	c.pos.y = 0
	b.pos.x = c.size.x / 2
	b.pos.y = c.size.y + 0.125 * b.size.y

	function b.on_click()
		log.debug("RESTART")
		game_gui:restart_game()
	end

	c:disable(false)
	c:add_child(b)
	v_r:add_child(c)

	v_r.clip = true
	v_r.size.x = vw
	v_r.size.y = vh
	v_r.anchor.x = vw / 2
	v_r.anchor.y = 0
	v_r.pos.x = vw / 2
	v_r.pos.y = v_c.pos.y + 115

	local v_stats = KView:new()
	local stats_chain = KImageView:new("button_restart_chains")
	local b_stats = GGBorderButton(_("BUTTON_STATISTICS"))
	b_stats.label.mobile_font_factor = 1

	stats_chain.anchor.x = stats_chain.size.x / 2
	stats_chain.anchor.y = stats_chain.size.y + 0.9 * b_stats.size.y
	stats_chain.pos.x = vw / 2
	stats_chain.pos.y = 0
	b_stats.pos.x = stats_chain.size.x / 2
	b_stats.pos.y = stats_chain.size.y + 0.125 * b_stats.size.y

	function b_stats.on_click()
		S:queue("GUIButtonCommon")
		game_gui:show_combat_stats()
	end

	stats_chain:disable(false)
	stats_chain:add_child(b_stats)
	v_stats:add_child(stats_chain)

	v_stats.clip = true
	v_stats.size.x = vw
	v_stats.size.y = vh
	v_stats.anchor.x = vw / 2
	v_stats.anchor.y = 0
	v_stats.pos.x = vw / 2
	v_stats.pos.y = v_r.pos.y + 74
	v_stats.hidden = true

	self.size.x = vw
	self.size.y = vh

	self:add_child(v_r)
	self:add_child(v_c)
	self:add_child(v_stats)
	self:add_child(v_badge)
	self:add_child(v_stars)

	self.v_badge = v_badge
	self.v_stars = v_stars
	self.v_restart = v_r
	self.v_continue = v_c
	self.v_stats = v_stats
	self.stats_chain = stats_chain
	self.b_stats = b_stats
end

function VictoryView:show()
	game_gui.overlay:show()

	self.hidden = false

	S:stop_all()
	S:queue("GUIQuestCompleted")

	local v_badge, v_stars, v_restart, v_continue, v_stats = self.v_badge, self.v_stars, self.v_restart, self.v_continue, self.v_stats
	local c_chain = v_continue.children[1]
	local r_chain = v_restart.children[1]
	local s_chain = self.stats_chain
	local stars_rating = game_gui.game.store.game_outcome.stars
	local level_idx = game_gui.game.store.level_idx

	v_stats.hidden = true
	c_chain:disable(false)
	r_chain:disable(false)
	s_chain:disable(false)

	timer:script(function(wait)
		self.scale.x, self.scale.y = 0.6, 0.6

		timer:tween(0.6, self.scale, {
			x = 1,
			y = 1
		}, "out-back", nil, 1.5)
		wait(0.15)

		local p = VictoryParticles:new()

		p.pos.x, p.pos.y = self.size.x / 2, self.size.y / 3
		self.particles = p

		self:add_child(p)
		wait(0.5)

		local animation = v_stars.animations[stars_rating]

		v_stars.animation = animation
		v_stars.ts = 0
		v_stars.hidden = false

		for i = 1, stars_rating do
			S:queue("GUIWinStars", {
				delay = (i - 1) * 0.7
			})
		end

		wait(animation.to / FPS)

		c_chain.pos.y = 0

		timer:tween(0.5, c_chain.pos, {
			y = c_chain.anchor.y
		}, "out-back")
		wait(0.5)

		r_chain.pos.y = 0

		timer:tween(0.5, r_chain.pos, {
			y = r_chain.anchor.y
		}, "out-back")
		wait(0.5)

		v_stats.hidden = false
		s_chain.pos.y = 0

		timer:tween(0.5, s_chain.pos, {
			y = s_chain.anchor.y
		}, "out-back")
		wait(0.5)
		c_chain:enable()
		r_chain:enable()
		s_chain:enable()
		S:queue(string.format("MusicBattlePrep_%02d", level_idx))
	end)
end

function VictoryView:hide()
	return
end

local function create_power_pointer(icon_name, style, icon_scale)
	local prefix = style == "area" and "pointer_area_orange" or "pointer_point_orange"
	local pointer = KImageView:new(prefix .. "_0001")

	pointer.anchor = V.v(pointer.size.x / 2, pointer.size.y / 2)
	pointer.animation = {
		from = 1,
		to = 10,
		prefix = prefix
	}
	pointer.loop = true

	local icon = KImageView:new(icon_name)

	if icon_scale and icon_scale ~= 1 then
		icon.image_scale = icon_scale
		icon:set_image(icon_name)
	end

	icon.anchor = V.v(icon.size.x / 2, icon.size.y)
	icon.pos.x, icon.pos.y = pointer.size.x / 2, pointer.size.y / 2

	pointer:add_child(icon)

	return pointer
end

local function create_selected_power_pointer(slot)
	return create_power_pointer(selected_power_pointer(slot))
end

local function create_hero_ultimate_pointer(slot)
	return create_power_pointer(hero_ultimate_slot_pointer(slot))
end

MousePointer = class("MousePointer", KView)

function MousePointer:initialize()
	MousePointer.super.initialize(self)

	self.propagate_on_click = true
	self.propagate_on_down = true
	self.propagate_on_up = true

	local rally_tower = KImageView:new("pointer_set_rally_0001")

	rally_tower.anchor = V.v(rally_tower.size.x / 2, rally_tower.size.y / 2)
	rally_tower.animation = {
		to = 10,
		prefix = "pointer_set_rally",
		from = 1
	}
	rally_tower.loop = true

	local ipc = KImageView:new("error_feedback_0001")

	ipc.anchor = v(ipc.size.x / 2, ipc.size.y / 2)
	ipc.animation = {
		to = 14,
		prefix = "error_feedback",
		from = 1
	}

	local pirate_camp = KImageView:new("pointer_pirate_cannons")

	pirate_camp.anchor = v(pirate_camp.size.x / 2, pirate_camp.size.y / 2)
	pirate_camp.alpha = 0.75

	local p1b, p2b, p3b, pab, psb, sunray_tower

	-- if IS_KR2 then
	-- 	p1b = KImageView:new("pointer_fireball_0001")
	-- 	p1b.anchor = V.v(p1b.size.x / 2, p1b.size.y / 2)
	-- 	p1b.animation = {
	-- 		to = 32,
	-- 		prefix = "pointer_fireball",
	-- 		from = 1
	-- 	}
	-- 	p1b.loop = true

	-- 	local re_t = E:get_template("re_current_1")
	-- 	local level = km.clamp(1, 4, re_t.unit.level)

	-- 	p2b = KImageView:new(string.format("pointer_reinforce_000%i", level))
	-- 	p2b.anchor = V.v(p2b.size.x / 2, p2b.size.y / 2)
	-- else
	p1b = KImageView:new("pointer_area_orange_0001")
	p1b.anchor = V.v(p1b.size.x / 2, p1b.size.y / 2)
	p1b.animation = {
		to = 10,
		prefix = "pointer_area_orange",
		from = 1
	}
	p1b.loop = true

	--流辉349 修改技能图标
	local user_data = storage:load_slot()
	local is_double = user_data and user_data.liuhui_hero and user_data.liuhui_hero.usedoublehero
	local ht = power_hero_template(1)

	local level_idx = game_gui.game.store.level_idx
	local p1i = KImageView:new((level_idx <= GS.last_level3 or level_idx == 81 or level_idx == 82 or (level_idx > GS.jnum5 and level_idx <= GS.last_level5) ) and "pointer_hero_power_0017" or "pointer_user_power_0001")
	if is_double and ht and hero_game_ver(ht.template_name) >= 3 then
		local p1_icon = power_hero_pointer_icon(ht)

		if p1_icon then
			p1i = KImageView:new(p1_icon)
		end
	end

	p1i.anchor = V.v(p1i.size.x / 2, p1i.size.y * 100 / 100)
	p1i.pos.x, p1i.pos.y = p1b.size.x / 2, p1b.size.y / 2

	p1b:add_child(p1i)

	p2b = KImageView:new("pointer_point_orange_0001")
	p2b.anchor = V.v(p2b.size.x / 2, p2b.size.y / 2)
	p2b.animation = {
		to = 10,
		prefix = "pointer_point_orange",
		from = 1
	}
	p2b.loop = true

	local p2i = KImageView:new((level_idx <= GS.last_level3 or level_idx == 81 or level_idx == 82 or (level_idx > GS.jnum5 and level_idx <= GS.last_level5) ) and "pointer_hero_power_0018" or "pointer_user_power_0002")--KImageView:new(level_idx > 22 and "pointer_user_power_0002" or "pointer_hero_power_0018")

	p2i.anchor = V.v(p2i.size.x / 2, p2i.size.y * 100 / 100)
	p2i.pos.x, p2i.pos.y = p2b.size.x / 2, p2b.size.y / 2

	p2b:add_child(p2i)

	-- if IS_KR3 then
	
	local rank = 1
	if is_double then
		rank = 2
	end

	ht = power_hero_template(rank)

	if not ht or hero_game_ver(ht.template_name) < 3 then
		p3b = KImageView:new("pointer_point_orange_0001")
		p3b.anchor = V.v(p3b.size.x / 2, p3b.size.y / 2)
		p3b.animation = {
			to = 10,
			prefix = "pointer_point_orange",
			from = 1
		}
		--p3b.animation = {
		--	to = 32,
		--	prefix = "pointer_fireball",
		--	from = 1
		--}
		p3b.loop = true

		local p3i = KImageView:new("pointer_user_power_0003")

		p3i.anchor = V.v(p3i.size.x / 2, p3i.size.y * 100 / 100)
		p3i.pos.x, p3i.pos.y = p3b.size.x / 2, p3b.size.y / 2

		p3b:add_child(p3i)
	else
		local p3_icon = power_hero_pointer_icon(ht) or "pointer_user_power_0003"
		
		local p3_style = ht.info and ht.info.ultimate_pointer_style or "point"
		local p3b_prefix = p3_style == "area" and "pointer_area_orange" or "pointer_point_orange"

		p3b = KImageView:new(p3b_prefix .. "_0001")
		p3b.anchor = V.v(p3b.size.x / 2, p3b.size.y / 2)
		p3b.animation = {
			to = 10,
			from = 1,
			prefix = p3b_prefix
		}
		p3b.loop = true

		local p3i = KImageView:new(p3_icon)

		p3i.anchor = V.v(p3i.size.x / 2, p3i.size.y * 100 / 100)
		p3i.pos.x, p3i.pos.y = p3b.size.x / 2, p3b.size.y / 2

		p3b:add_child(p3i)
	end
	-- end

	-- Replace the legacy hard-coded pointers after their setup so every slot
	-- follows its selected spell.
	p1b = create_selected_power_pointer(1)
	p2b = create_selected_power_pointer(2)
	p3b = create_selected_power_pointer(3)
	pab = create_hero_ultimate_pointer("a")
	psb = create_hero_ultimate_pointer("s")

	-- if IS_KR1 then
	sunray_tower = KImageView:new("pointer_point_orange_0001")
	sunray_tower.anchor = V.v(sunray_tower.size.x / 2, sunray_tower.size.y / 2)
	sunray_tower.animation = {
		to = 10,
		prefix = "pointer_point_orange",
		from = 1
	}
	sunray_tower.loop = true

	local drop = KImageView:new("pointer_sunray_tower")

	drop.anchor = V.v(drop.size.x / 2, drop.size.y * 100 / 100)
	drop.pos.x, drop.pos.y = sunray_tower.size.x / 2, sunray_tower.size.y / 2

	sunray_tower:add_child(drop)
	-- end
	-- end

	self.cross = ipc
	self.pointers = {
		[GUI_MODE_RALLY_TOWER] = rally_tower,
		[GUI_MODE_RALLY_HERO] = rally_tower,
		[GUI_MODE_SELECT_POINT] = pirate_camp,
		[GUI_MODE_FREE_HOLDER] = pirate_camp,
		[GUI_MODE_POWER_1] = p1b,
		[GUI_MODE_POWER_2] = p2b,
		[GUI_MODE_POWER_3] = p3b,
		[GUI_MODE_POWER_A] = pab,
		[GUI_MODE_POWER_S] = psb
	}
	self.pointers_by_name = {
		p1b = p1b,
		p2b = p2b,
		p3b = p3b,
		pab = pab,
		psb = psb,
		rally_tower = rally_tower,
		pirate_camp = pirate_camp,
		sunray_tower = sunray_tower
	}
end

function MousePointer:update_pointer(mode)
	if self.ignore_update then return end
	if self.timer then
		timer:cancel(self.timer)

		self.timer = nil
	end

	local pointer = self.pointers[mode]
	local e = game_gui.selected_entity

	if e and e.user_selection and e.user_selection.custom_pointer_name then
		local pn = e.user_selection.custom_pointer_name

		pointer = self.pointers_by_name[pn] or pointer
	end

	log.paranoid("pointer: %s", pointer)

	if not pointer then
		self.hidden = true

		love.mouse.setVisible(true)
	else
		love.mouse.setVisible(false)
		self:remove_children()
		self:add_child(pointer)

		self.hidden = false
	end
end

function MousePointer:show_cross()
	if self.ignore_update then return end
	if self.timer then
		timer:cancel(self.timer)

		self.timer = nil
	else
		if self.hidden then
			-- block empty
		end

		self.last_cursor = self.children[1]
	end

	self:remove_children()
	self:add_child(self.cross)

	self.cross.ts = 0
	self.hidden = false
	self.timer = timer:after(0.4666666666666667, function()
		self:remove_children()

		if self.last_cursor then
			self:add_child(self.last_cursor)

			self.last_cursor = nil
			self.timer = nil
		else
			self.hidden = true
		end
	end)

	self.ignore_update = true
	timer:after(0.1, function()
		self.ignore_update = false
	end)
end

function MousePointer:update(dt)
	if not self.hidden then
		if not self.window then
			self.window = self:get_window()
		end

		local x, y = self.window:get_mouse_position()

		self.pos.x, self.pos.y = self.window:screen_to_view(x, y)
	end

	MousePointer.super.update(self, dt)
end

NotificationView = class("NotificationView", KView)

function NotificationView:initialize(w, h)
	NotificationView.super.initialize(self)
end

function NotificationView:show(id, no_transition, force_show)
	local img_prefix = {
		[N_ENEMY] = "encyclopedia_creeps_",
		[N_TOWER] = "encyclopedia_towers_",
		[N_POWER] = "tutorial_powers_polaroids_"
	}
	local titles = {
		218,
		215,
		157,
		[N_ENEMY] = {
			"notifications_tit_newenemy_bg",
			_("NEW ENEMY!"),
			{
				247,
				244,
				185
			}
		},
		[N_TOWER] = {
			"notifications_tit_towers_bg",
			_("NEW TOWER UNLOCKED"),
			{
				247,
				244,
				185
			}
		},
		[N_TOWER_4] = {
			"notifications_tit_towers_bg",
			_("NEW TOWER UPGRADES"),
			{
				247,
				244,
				185
			}
		},
		[N_TOWER_2] = {
			"notifications_tit_towers_bg",
			_("NEW TOWERS UNLOCKED"),
			{
				247,
				244,
				185
			}
		},
		[N_POWER] = {
			"notifications_tit_newpower_bg",
			_("NEW SPECIAL POWER!"),
			{
				247,
				244,
				185
			}
		},
		[N_TIP] = {
			"notifications_tit_generics_bg_0001",
			_("HINT"),
			{
				247,
				244,
				185
			}
		},
		[N_TUTORIAL] = {
			"tutorial_tit_instructions_bg",
			_("INSTRUCTIONS")
		}
	}

	local function create_noti_title(style)
		local title_bg, title_text, title_color = unpack(titles[style])
		local is_long = #title_text > 20
		local v_title = KImageView:new(title_bg)

		v_title.anchor = V.v(0, v_title.size.y)
		v_title.pos = V.v(80, 40)
		v_title.scale.x = is_long and 1.3 or 1

		local v_title_label = GGShaderLabel:new(V.v(math.floor(208 * v_title.scale.x), 38))

		v_title_label.font_name = "h_noti"
		v_title_label.font_size = 24
		v_title_label.scale.x = 1 / v_title.scale.x
		v_title_label.pos.y = 16
		v_title_label.pos.x = v_title.size.x / 2
		v_title_label.anchor.x = v_title_label.size.x / 2
		v_title_label.text = title_text
		v_title_label.text_align = "center"
		v_title_label.vertical_align = ISW("middle-caps", "zh-Hans", "middle", "zh-Hant", "middle", "ko", "middle", "ja", "middle")
		v_title_label.colors.text = title_color
		v_title_label.colors.background = DEBUG_BACKGROUND_COLOR
		v_title_label.shaders = {
			"p_glow"
		}
		v_title_label.shader_args = {
			{
				thickness = 0.6,
				glow_color = {
					0,
					0,
					0,
					1
				}
			}
		}
		v_title_label.fit_lines = 1

		v_title:add_child(v_title_label)

		return v_title
	end

	local function create_noti_button(style)
		local b

		if style == "light" then
			b = GGButton("notifications_but_lightblue_bg_0001", "notifications_but_lightblue_bg_0002", "notifications_but_lightblue_bg_0002")
			b.label.text = _("OK!")
		elseif style == "dark" then
			b = GGButton("notifications_but_dark_bg_0001", "notifications_but_dark_bg_0002", "notifications_but_dark_bg_0002")
			b.label.text = _("OK!")
		elseif style == "skip" then
			b = GGButton("notifications_but_lightblue_bg_0001", "notifications_but_lightblue_bg_0002", "notifications_but_lightblue_bg_0002")
			b.label.text = _("Skip this!")
		elseif style == "next" then
			b = GGButton("notifications_but_lightblue_bg_0001", "notifications_but_lightblue_bg_0002", "notifications_but_lightblue_bg_0002")
			b.label.text = _("Next!")
		elseif style == "gotcha" then
			local prefix = "tutorial_but_gotcha_bg_long"

			b = GGButton(prefix .. "_0001", prefix .. "_0002", prefix .. "_0002")
			b.label.text = _("Got it!")
		end

		b.anchor.y = 0
		b.label.size.x = b.label.size.x - 40
		b.label.size.y = 34
		b.label.pos.x = 20
		b.label.pos.y = 14
		b.label.vertical_align = CJK("middle-caps", "middle")
		b.label.text_align = "center"
		b.label.font_name = "body"
		b.label.font_size = 20
		b.label_colors = {
			default = {
				255,
				254,
				200
			},
			hover = {
				255,
				255,
				255
			}
		}
		b.label.colors.text = b.label_colors.default
		b.label.colors.background = DEBUG_BACKGROUND_COLOR
		b.label.shader_args = {
			{
				thickness = 0.5,
				glow_color = {
					0,
					0,
					0,
					1
				}
			}
		}

		b.label:do_fit_lines(1)

		if style == "gotcha" then
			b.label.vertical_align = nil
			b.label.size.y = 26
			b.label.anchor.y = 26
			b.label.pos.y = CJK(30, 24, nil, 26)
			b.label.font_size = 20
			b.label.fit_lines = 1

			local margin = 15
			local l2 = GGShaderLabel:new(V.v(b.size.x - 2 * margin, 20))

			l2.font_name = "body"
			l2.font_size = 12
			l2.text = _("I'm ready. Now bring it on!")
			l2.anchor.y = 0
			l2.pos = v(margin, CJK(28, 26, nil, 28))
			l2.propagate_on_down = true
			l2.propagate_on_up = true
			l2.propagate_on_click = true
			l2.shaders = {
				"p_glow"
			}
			l2.shader_args = {
				{
					thickness = 0.1,
					glow_color = {
						0,
						0,
						0,
						1
					}
				}
			}
			l2.colors.text = {
				255,
				254,
				200
			}
			l2.fit_lines = 1

			b:add_child(l2)
		end

		return b
	end

	local function create_photo(image, rotation, small_shadow)
		local v_image = KImageView:new(image)

		v_image.anchor = V.v(v_image.size.x / 2, v_image.size.y / 2)
		v_image.r = rotation
		v_image.propagate_on_click = true

		local border_name = small_shadow and "notifications_polaroid_overlay_small_shadow" or "notifications_polaroid_overlay"
		local v_border = KImageView:new(border_name)
		local dx, dy = (v_border.size.x - v_image.size.x) / 2, (v_border.size.y - v_image.size.y) / 2

		v_border.pos = V.v(-dx, -dy)
		v_border.propagate_on_click = true

		v_image:add_child(v_border)

		return v_image
	end

	local function create_slide(layout_name, paper, layout_data)
		local colors = {
			black = {
				0,
				0,
				0
			},
			white = {
				255,
				255,
				255
			},
			gray = {
				48,
				41,
				35
			},
			red = {
				216,
				55,
				18
			},
			dark_red = {
				183,
				63,
				13
			},
			blue = {
				0,
				124,
				178
			}
		}
		local views = {}
		local v_paper = KImageView:new(paper)

		v_paper.propagate_on_click = true
		v_paper.propagate_on_down = true

		table.insert(views, v_paper)

		for i, d in pairs(layout_data) do
			local lv = GGLabel:new(V.v(d.size.x, d.size.y))

			lv.font_name = "body_slides"
			lv.font_size = 18
			lv.text_align = "left"
			lv.fit_size = true
			lv.colors.text = {
				17,
				20,
				12,
				255
			}

			table.deepmerge(lv, d)

			lv.text = _(lv.text)

			if lv.color and colors[lv.color] then
				lv.colors.text = colors[lv.color]
			end

			table.insert(views, lv)

			if DBG_SLIDE_EDITOR then
				function lv.on_click(this)
					if game_gui.SEL_VIEW and game_gui.SEL_VIEW._debug_old_bg_color then
						if game_gui.SEL_VIEW._debug_old_bg_color == "none" then
							game_gui.SEL_VIEW.colors.background = nil
						else
							game_gui.SEL_VIEW.colors.background = game_gui.SEL_VIEW._debug_old_bg_color
						end

						game_gui.SEL_VIEW._debug_old_bg_color = nil
					end

					game_gui.SEL_VIEW = this
					this._debug_old_bg_color = this.colors and this.colors.background or "none"
					this.colors.background = {
						255,
						0,
						0,
						100
					}

					log.debug("NotificationView - SEL_VIEW: %s", this.text)
				end
			else
				lv.propagate_on_click = true
				lv.propagate_on_down = true
				lv.propagate_on_up = true
			end
		end

		return views, v_paper.size.x, v_paper.size.y
	end

	local function create_layout(layout, image, prefix, subtitle, offset_y)
		offset_y = offset_y or 0

		local views = {}
		local ox, oy = 255, 50 + offset_y
		local my = 0
		local label_w = 320

		prefix = string.upper(prefix)

		local v_paper = KImageView:new("notifications_newenemy")

		v_paper.pos.y = offset_y
		v_paper.propagate_on_click = true
		v_paper.propagate_on_down = true

		table.insert(views, v_paper)

		if layout == N_ENEMY then
			local l_name = GGLabel:new(V.v(label_w, 36))

			l_name.pos = V.v(ox, CJK(oy, nil, nil, oy - 5))
			l_name.text = _(prefix .. "_NAME")
			l_name.font_name = "body_slides"
			l_name.font_size = 28
			l_name.colors.text = {
				24,
				26,
				15,
				255
			}
			l_name.text_align = "left"
			l_name.fit_lines = 1

			table.insert(views, l_name)

			oy = oy + my + l_name.size.y

			local l_desc = GGLabel:new(V.v(label_w, 100))

			l_desc.pos = V.v(ox, oy)
			l_desc.text = _(prefix .. "_DESCRIPTION")
			l_desc.font_name = "body_slides"
			l_desc.font_size = 19
			l_desc.line_height = CJK(0.8, nil, 1.1, 0.9)
			l_desc.colors.text = {
				24,
				26,
				15,
				255
			}
			l_desc.text_align = "left"
			l_desc.fit_size = true

			table.insert(views, l_desc)

			oy = oy + my + l_desc.size.y

			local l_extra = GGLabel:new(V.v(label_w, 90))

			l_extra.pos = V.v(ox, oy + 1)
			l_extra.text = string.gsub(_(prefix .. "_EXTRA"), "- ", "* ")
			l_extra.font_name = "body_slides"
			l_extra.font_size = 13
			l_extra.line_height = CJK(0.85, nil, 1.1, 0.9)
			l_extra.text_align = "left"
			l_extra.colors.text = {
				146,
				25,
				0,
				255
			}

			table.insert(views, l_extra)

			oy = oy + my + l_extra.size.y
		elseif layout == N_POWER then
			local l_name = GGLabel:new(V.v(label_w, 35))

			l_name.pos = V.v(ox, oy)
			l_name.text = _(prefix .. "_NAME")
			l_name.font_name = "body_slides"
			l_name.font_size = 28
			l_name.colors.text = {
				24,
				26,
				15,
				255
			}
			l_name.text_align = "left"
			l_name.vertical_align = "middle"
			l_name.fit_lines = 1

			table.insert(views, l_name)

			oy = oy + my + l_name.size.y

			local l_desc = GGLabel:new(V.v(label_w, 85))

			l_desc.pos = V.v(ox, CJK(oy, nil, nil, oy + 8))
			l_desc.text = _(prefix .. "_LARGE_DESCRIPTION")
			l_desc.font_name = "body_slides"
			l_desc.font_size = 17
			l_desc.line_height = CJK(0.8, nil, 1.1, 0.9)
			l_desc.colors.text = {
				24,
				26,
				15,
				255
			}
			l_desc.text_align = "left"

			table.insert(views, l_desc)

			oy = oy + my + l_desc.size.y
		elseif layout == N_TOWER then
			oy = oy + 20

			local l_sub = GGLabel:new(V.v(label_w, 20))

			l_sub.pos = V.v(ox + 2, oy + CJK(4, nil, nil, -4))
			l_sub.text = _(subtitle)
			l_sub.font_name = "body_slides"
			l_sub.font_size = 15
			l_sub.colors.text = {
				24,
				26,
				15,
				255
			}
			l_sub.text_align = "left"

			table.insert(views, l_sub)

			oy = oy + my + l_sub.size.y

			local l_name = GGLabel:new(V.v(label_w, 40))

			l_name.pos = V.v(ox, CJK(oy, nil, nil, oy - 2))
			l_name.text = _(prefix .. "_NAME")
			l_name.font_name = "body_slides"
			l_name.font_size = 28
			l_name.colors.text = {
				24,
				26,
				15,
				255
			}
			l_name.text_align = "left"
			l_name.fit_lines = 1

			table.insert(views, l_name)

			oy = oy + my + l_name.size.y

			local l_extra = GGLabel:new(V.v(label_w, 100))

			l_extra.pos = V.v(ox, oy)
			l_extra.text = _(prefix .. "_EXTRA")
			l_extra.font_name = "body_slides"
			l_extra.font_size = 17
			l_extra.line_height = CJK(0.8, nil, 1.1, 0.9)
			l_extra.colors.text = {
				24,
				26,
				15,
				255
			}
			l_extra.text_align = "left"

			table.insert(views, l_extra)

			oy = oy + my + l_extra.size.y
		end

		local v_photo = create_photo(image, math.pi / 24)

		v_photo.pos = V.v(134, 160 + offset_y)

		table.insert(views, v_photo)

		if DBG_SLIDE_EDITOR then
			for _, v in pairs(views) do
				if v:isInstanceOf(GGLabel) then
					function v.on_click(this)
						if game_gui.SEL_VIEW and game_gui.SEL_VIEW._debug_old_bg_color then
							if game_gui.SEL_VIEW._debug_old_bg_color == "none" then
								game_gui.SEL_VIEW.colors.background = nil
							else
								game_gui.SEL_VIEW.colors.background = game_gui.SEL_VIEW._debug_old_bg_color
							end

							game_gui.SEL_VIEW._debug_old_bg_color = nil
						end

						game_gui.SEL_VIEW = this
						this._debug_old_bg_color = this.colors and this.colors.background or "none"
						this.colors.background = {
							255,
							0,
							0,
							100
						}

						log.debug("create_layout - SEL_VIEW: %s", this.text)
					end
				end
			end
		end

		return views, v_paper.size.x, v_paper.size.y
	end

	local n = data.notifications[id]

	if not n then
		log.debug("Notification with id:%s not found", id)

		return
	end

	if not force_show and U.is_seen(game_gui.game.store, id) and not n.always then
		return
	end

	U.mark_seen(game_gui.game.store, id)

	if n and n.seen then
		for _, name in pairs(n.seen) do
			U.mark_seen(game_gui.game.store, name)
		end
	end

	if self.timers then
		for _, t in pairs(self.timers) do
			timer:cancel(t)
		end

		self:remove_children()

		self.timers = nil
	end

	if table.contains({
		N_ENEMY,
		N_POWER,
		N_TOWER
	}, n.layout) then
		local n_prefix = n.prefix or id

		if n.layout == N_ENEMY then
			local t = E:get_template(id)

			n_prefix = t and t.info and t.info.i18n_key or n_prefix
		end

		local views, pw, ph = create_layout(n.layout, n.image, n_prefix, n.sub)
		local v_title = create_noti_title(n.layout)

		v_title.anchor = V.v(0, v_title.size.y)

		local b_ok = create_noti_button("dark")

		b_ok.pos = V.v(475, 254)

		function b_ok.on_click(this)
			this:disable()
			self:hide()
		end

		self:add_child(v_title)
		self:add_child(b_ok)

		for _, v in pairs(views) do
			self:add_child(v)
		end

		self.size = V.v(pw, ph)
		self.anchor = V.v(self.size.x / 2, self.size.y / 2)
	elseif n.layout == N_TIP then
		local views, pw, ph = create_slide(n.layout, n.paper, data.notification_slides[id])
		local v_title = create_noti_title(n.layout)

		v_title.anchor = V.v(v_title.size.x / 2, v_title.size.y)
		v_title.pos = V.v(pw / 2, 32)

		local b_ok = create_noti_button("light")

		b_ok.pos = V.v(300, 360)
		b_ok.anchor.x = 0

		function b_ok.on_click(this)
			this:disable()
			self:hide()
		end

		self:add_child(v_title)
		self:add_child(b_ok)

		for _, v in pairs(views) do
			self:add_child(v)
		end

		self.size = V.v(pw, ph)
		self.anchor = V.v(self.size.x / 2, self.size.y / 2)
	elseif n.layout == N_TOWER_2 then
		local views_1, pw1, ph1 = create_layout(N_TOWER, n.images[1], n.prefixes[1], n.subs[1])
		local views_2, pw2, ph2 = create_layout(N_TOWER, n.images[2], n.prefixes[2], n.subs[2], ph1 - 30)
		local v_title = create_noti_title(n.layout)

		v_title.anchor = V.v(0, v_title.size.y)

		local b_ok = create_noti_button("dark")

		b_ok.pos = V.v(450, ph1 + ph2 - 30 - 40)

		function b_ok.on_click(this)
			this:disable()
			self:hide()
		end

		self:add_child(v_title)
		self:add_child(b_ok)

		for _, v in pairs(views_1) do
			self:add_child(v)
		end

		for _, v in pairs(views_2) do
			self:add_child(v)
		end

		self.size = V.v(pw1, ph1 + ph2 - 30)
		self.anchor = V.v(self.size.x / 2, self.size.y / 2)
	elseif n.layout == N_TOWER_4 then
		local ox, oy = 76, 55
		local my = 5
		local v_paper = KImageView:new("notifications_newenemy")

		v_paper.propagate_on_click = true
		v_paper.propagate_on_down = true

		local l_1 = GGLabel:new(V.v(490, 32))

		l_1.pos = V.v(ox, oy)
		l_1.text = string.format(_("NOTIFICATION_NEW_TOWERS_SUB_TITLE"), n.level)
		l_1.font_name = "body_slides"
		l_1.font_size = 24
		l_1.colors.text = {
			24,
			26,
			15,
			255
		}
		l_1.text_align = "center"
		oy = oy + my + l_1.size.y

		local l_2 = GGLabel:new(V.v(490, 85))

		l_2.pos = V.v(ox, oy)
		l_2.text = string.format(_("NOTIFICATION_NEW_TOWERS_SUB_DESCRIPTION"), n.level)
		l_2.font_name = "body_slides"
		l_2.font_size = 16
		l_2.colors.text = {
			24,
			26,
			15,
			255
		}
		l_2.text_align = "center"
		oy = oy + my + l_2.size.y

		local offx = 140
		local pox, poy = (v_paper.size.x - 3 * offx) / 2, 220
		local rotations = {
			math.pi / 22,
			-math.pi / 20,
			math.pi / 30,
			-math.pi / 25
		}
		local photos = {}

		for i, image in ipairs(n.images) do
			local photo = create_photo(image, rotations[i], true)

			photo.pos.x, photo.pos.y = pox + (i - 1) * offx, poy
			photo.scale = V.v(0.85, 0.85)

			table.insert(photos, photo)
		end

		local v_title = create_noti_title(n.layout)

		v_title.anchor = V.v(0, v_title.size.y)

		local b_ok = create_noti_button("dark")

		b_ok.pos = V.v(450, v_paper.size.y - 15)

		function b_ok.on_click(this)
			this:disable()
			self:hide()
		end

		self:add_child(v_title)
		self:add_child(b_ok)
		self:add_child(v_paper)
		self:add_child(l_1)
		self:add_child(l_2)

		for _, p in ipairs(photos) do
			self:add_child(p)
		end

		self.size = V.vclone(v_paper.size)
		self.anchor = V.v(self.size.x / 2, self.size.y / 2)
	elseif n.layout == N_TUTORIAL then
		local views, pw, ph = create_slide(n.layout, n.paper, data.notification_slides[id])
		local v_paper = views[1]

		v_paper.propagate_on_click = true
		v_paper.propagate_on_down = true

		local v_title = create_noti_title(n.layout)

		v_title.anchor = V.v(v_title.size.x / 2, v_title.size.y)
		v_title.pos = V.v(pw / 2, 32)

		self:add_child(v_title)

		if n.next then
			local b_skip = create_noti_button("skip")

			b_skip.anchor = V.v(b_skip.size.x, 0)
			b_skip.pos = V.v(v_paper.size.x / 2 - 20, v_paper.size.y - 30)

			function b_skip.on_click(this)
				this:disable()
				self:hide()
			end

			self:add_child(b_skip)

			local b_next = create_noti_button("next")

			b_next.anchor = V.v(0, 0)
			b_next.pos = V.v(v_paper.size.x / 2 + 20, v_paper.size.y - 30)

			function b_next.on_click(this)
				self.show_next = n.next

				this:disable()
				self:hide(true)
			end

			self:add_child(b_next)
		else
			local b_ok = create_noti_button("gotcha")

			b_ok.anchor = V.v(b_ok.size.x / 2, 0)
			b_ok.pos = V.v(v_paper.size.x / 2, v_paper.size.y - 24)

			function b_ok.on_click(this)
				this:disable()
				self:hide()
			end

			self:add_child(b_ok)
		end

		for _, v in pairs(views) do
			self:add_child(v)
		end

		self.size.x, self.size.y = pw, ph
		self.anchor = V.v(self.size.x / 2, self.size.y / 2)
	else
		log.error("Notification type %s unknown", n.layout)

		return
	end

	game_gui:deselect_all()
	game_gui:disable_keys()

	game_gui.game.store.paused = true

	game_gui.overlay:show()

	self.hidden = false
	local notification_scale = IS_ANDROID and 1 / (game_gui.android_ui_scale or 1) or 1

	if no_transition then
		self.alpha = 1
		self.scale = V.v(notification_scale, notification_scale)
	else
		self.alpha = 0
		self.scale = V.v(0.5 * notification_scale, 0.5 * notification_scale)
		self.timers = {
			timer:tween(0.4, self, {
				alpha = 1
			}),
			timer:tween(0.4, self.scale, {
				x = notification_scale,
				y = notification_scale
			}, "out-back")
		}
	end

	S:queue("GUINotificationOpen")
	signal.emit("notification-shown", n)

	if n.signals then
		for _, s in pairs(n.signals) do
			signal.emit(unpack(s))
		end
	end
end

function NotificationView:hide(no_transition)
	if not self.show_next then
		game_gui:enable_keys()

		game_gui.game.store.paused = false

		game_gui.overlay:hide()
	end

	if no_transition then
		self:remove_children()
		self:show(self.show_next, true)

		self.show_next = nil

		return
	end

	self.alpha = 1
	local notification_scale = IS_ANDROID and 1 / (game_gui.android_ui_scale or 1) or 1

	if self.timers then
		for _, t in pairs(self.timers) do
			timer:cancel(t)
		end

		self.timers = nil
	end

	self.timers = {
		timer:tween(0.4, self, {
			alpha = 0
		}),
		timer:tween(0.4, self.scale, {
			x = 0.5 * notification_scale,
			y = 0.5 * notification_scale
		}, "in-back", function()
			self.timers = nil
			self.hidden = true

			self:remove_children()

			if self.show_next then
				self:show(self.show_next)

				self.show_next = nil
			end
		end)
	}

	S:queue("GUINotificationClose")
end

NotificationQueue = class("NotificationQueue", KView)

function NotificationQueue:initialize(w, h)
	NotificationQueue.super.initialize(self, V.v(w, h))

	self.clip = false
	self.colors.background = {
		0,
		0,
		0,
		0
	}
	self.space_y = 10
end

function NotificationQueue:add(id, force)
	local n = data.notifications[id]

	if not n then
		log.warning("Notification with id:%s not found", id)

		return
	end

	if U.is_seen(game_gui.game.store, id) and not n.always and not force then
		return
	end

	U.mark_seen(game_gui.game.store, id)

	if not n.icon or not I:s(n.icon, true) then
		log.error("Notification %s skipped: icon %s is not loaded", id, tostring(n.icon))

		return
	end

	local v_icon = NotificationIcon:new(n.icon, id, n.layout)

	v_icon.pos.y = #self.children * (v_icon.size.y + self.space_y)

	self:add_child(v_icon)
	S:queue("GUINotificationSecondLevel")

	if n.icon_signals then
		for _, s in pairs(n.icon_signals) do
			signal.emit(unpack(s))
		end
	end
end

function NotificationQueue:remove_icon(child)
	local move = false

	for i, c in ipairs(self.children) do
		if c == child then
			move = true
		elseif move then
			timer:tween(0.3, c.pos, {
				y = c.pos.y - (c.size.y + self.space_y)
			}, "out-quad")
		end
	end

	self:remove_child(child)
end

function NotificationQueue:hide()
	timer:tween(0.3, self, {
		alpha = 0
	}, "in-quad")
end

function NotificationQueue:show()
	timer:tween(0.3, self, {
		alpha = 1
	}, "in-quad")
end

NotificationIcon = class("NotificationIcon", KImageView)

function NotificationIcon:initialize(image, notification_id, layout)
	NotificationIcon.super.initialize(self, image)

	self.anchor = V.v(self.size.x / 2, self.size.y / 2)
	self.notification_id = notification_id

	local title = GGShaderLabel:new(V.v(math.floor(self.size.x * 1.5), 30))

	title.anchor = V.v(title.size.x / 2, 0)
	title.pos.x = self.size.x / 2 - 4
	title.font_name = "h_noti"
	title.text_align = "center"
	title.vertical_align = "bottom"
	title.colors.text = {
		253,
		248,
		73
	}
	title.shaders = {
		"p_bands",
		"p_outline",
		"p_edge_blur"
	}

	if layout == N_TIP or layout == N_POWER then
		title.pos.y = CJK(-6, -10, -12, -14)
		title.font_size = 22
		title.text = _("TIP_ALERT_ICON")
		title.shader_args = {
			{
				margin = 0,
				p1 = 0.3,
				p2 = 0.55,
				c1 = {
					0.5019607843137255,
					0.9490196078431372,
					1,
					1
				},
				c2 = {
					0.5019607843137255,
					0.9490196078431372,
					1,
					1
				},
				c3 = {
					0.14901960784313725,
					0.7137254901960784,
					0.8509803921568627,
					1
				}
			},
			{
				thickness = 1,
				outline_color = {
					0.09019607843137255,
					0.1411764705882353,
					0.14901960784313725,
					1
				}
			},
			{
				thickness = 1
			}
		}
	else
		title.pos.y = CJK(-14, -13, -16, -20)
		title.font_size = 17
		title.text = _("NEW_ENEMY_ALERT_ICON")
		title.shader_args = {
			{
				margin = 1,
				p1 = 0.3,
				p2 = 0.45,
				c1 = {
					0.9921568627450981,
					0.9725490196078431,
					0.28627450980392155,
					1
				},
				c2 = {
					0.9921568627450981,
					0.9725490196078431,
					0.28627450980392155,
					1
				},
				c3 = {
					0.9921568627450981,
					0.7725490196078432,
					0.21568627450980393,
					1
				}
			},
			{
				thickness = 2,
				outline_color = {
					0.18823529411764706,
					0.1803921568627451,
					0.043137254901960784,
					1
				}
			},
			{
				thickness = 1
			}
		}
	end

	title.fit_lines = 1
	title.propagate_on_click = true

	self:add_child(title)
	self:show()
end

function NotificationIcon:loop_tween()
	local s = self.scale.x > 1 and 0.985 or 1.015

	timer:tween(0.3, self.scale, {
		x = s,
		y = s
	}, "in-out-sine", function()
		self:loop_tween()
	end)
end

function NotificationIcon:on_click()
	game_gui:show_notification(self.notification_id, true)
	self:hide()
end

function NotificationIcon:show()
	S:queue("GUINotificationSecondLevel")
	timer:tween(0.3, self, {
		alpha = 1
	}, "in-quad")

	self.scale.x, self.scale.y = 0.8, 0.8

	self:loop_tween()
end

function NotificationIcon:hide()
	self:disable(false)

	local s = 0.4

	timer:tween(0.4, self.scale, {
		x = s,
		y = s
	}, "in-back", function()
		self.parent:remove_icon(self)
	end)
	timer:tween(0.4, self, {
		alpha = 0
	})
end

TextBalloon = class("TextBalloon", GG5BalloonView)

function TextBalloon:initialize(id, position_offset, text_override)
	local bd = data.text_balloons and data.text_balloons[id]

	if not bd then
		log.error("Text balloon with id:%s not found", id)
		self.valid = false

		return
	end

	local flags = bd.flags or ""
	local origin = bd.origin or "world"

	TextBalloon.super.initialize(self, bd.size, bd.prefix or "balloon_map_slices", flags, _(text_override or bd.text), bd.title and _(bd.title) or nil, bd.padding, nil, bd.bg_color, bd.text_color, bd.line_color)

	self.valid = true
	self.id = id
	self.propagate_on_click = true
	self.propagate_on_down = true
	self.propagate_on_up = true
	self.balloon_on_hide = bd.balloon
	self.show_time = bd.time
	self.scale_world = bd.scale_world
	self.original_scale = V.v(self.scale.x, self.scale.y)
	position_offset = position_offset or V.v(0, 0)

	local function has_flag(value)
		return string.find(flags, value, 1, true) ~= nil
	end

	local x, y, right, bottom = 0, 0, game_gui.sw, game_gui.sh
	local widget_id = string.match(origin, "id:([%w_]+):")
	local origin_widget = widget_id and wid(widget_id) or nil

	if origin_widget and has_flag("add_as_child") then
		self.add_as_child = true
		origin_widget:add_child(self)
		right, bottom = origin_widget.size.x, origin_widget.size.y
	elseif origin_widget then
		local hud = wid("layer_gui_hud") or game_gui.layer_gui_hud
		local px, py = origin_widget:view_to_view(0, 0, hud)

		x, y = px, py
		right, bottom = px + origin_widget.size.x, py + origin_widget.size.y
	elseif widget_id then
		log.error("Text balloon %s origin widget %s was not found", id, widget_id)
		self.valid = false

		return
	elseif string.find(origin, "world", 1, true) then
		local store = game_gui.game and game_gui.game.store
		local vc = store and store.visible_coords

		if vc then
			x, y, right, bottom = vc.left, vc.top, vc.right, vc.bottom
		else
			right = game_gui.game and game_gui.game.ref_w or REF_W
			bottom = game_gui.game and game_gui.game.ref_h or REF_H
		end
	end

	local ox, oy = 0, 0

	if string.find(origin, "top", 1, true) then
		oy = y
	elseif string.find(origin, "bottom", 1, true) then
		oy = bottom
	elseif string.find(origin, "middle", 1, true) then
		oy = (y + bottom) * 0.5
	end

	if string.find(origin, "left", 1, true) then
		ox = x
	elseif string.find(origin, "right", 1, true) then
		ox = right
	elseif string.find(origin, "center", 1, true) then
		ox = (x + right) * 0.5
	end

	if string.find(origin, "world", 1, true) then
		self.world_pos = V.v(position_offset.x + ox + bd.offset.x, position_offset.y + oy + bd.offset.y)
	else
		self.pos = V.v(position_offset.x + ox + bd.offset.x, position_offset.y + oy + bd.offset.y)
	end

	self.sig_handles = {}

	local function register_signal(name, fn)
		local handle = signal.register(name, fn)

		table.insert(self.sig_handles, {
			name,
			handle
		})
	end

	self.hide_cond = bd.hide_cond

	if self.hide_cond == "tower_built" then
		register_signal("tower-built", function()
			self:remove(false)
		end)
		register_signal("tower-menu-showing", function()
			self:hide()
		end)
		register_signal("tower-menu-hiding", function()
			self:show()
		end)
	elseif self.hide_cond == "tap_twice" then
		register_signal("tower-built", function()
			self:remove(false)
		end)
		register_signal("tower-menu-showing", function()
			self:show()
		end)
		register_signal("tower-menu-hiding", function()
			self:hide()
		end)
	elseif self.hide_cond == "power_selected_1" then
		register_signal("power-selected", function(mode)
			if mode == GUI_MODE_POWER_1 then
				self:remove(true)
			end
		end)
	elseif self.hide_cond == "power_selected_2" then
		register_signal("power-selected", function(mode)
			if mode == GUI_MODE_POWER_2 then
				self:remove(true)
			end
		end)
	elseif self.hide_cond == "power_selected_3" then
		register_signal("power-selected", function(mode)
			if mode == GUI_MODE_POWER_3 then
				self:remove(true)
			end
		end)
	elseif self.hide_cond == "power_used" then
		register_signal("power-used", function()
			self:remove(true)
		end)
		register_signal("power-deselected", function()
			self:remove(true)
		end)
	elseif self.hide_cond == "noti_shown" then
		register_signal("notification-shown", function()
			self:remove(true)
		end)
	elseif self.hide_cond == "wave_selected" then
		register_signal("wave-flag-selected", function()
			self:hide()
		end)
		register_signal("wave-flag-deselected", function()
			self:show()
		end)
		register_signal("next-wave-sent", function()
			self:remove(true)
		end)
	elseif self.hide_cond == "wave_sent" then
		register_signal("next-wave-sent", function()
			self:remove(true)
		end)
	elseif self.hide_cond == "custom_event_wait" then
		register_signal("turn-off-balloon", function()
			self:remove(true)
		end)
	end

	register_signal("game-defeat", function()
		self:remove(false)
	end)
	register_signal("game-victory", function()
		self:remove(false)
	end)
	register_signal("hide-gui", function()
		self:remove(false)
	end)

	self.make_animation = not has_flag("dialog")
	self.hidden = true

	self:show()
end

function TextBalloon:show(keep_timestamp)
	if self.remove_requested or not self.hidden then
		return
	end

	self.hidden = false

	if not keep_timestamp then
		self.show_ts = game_gui.game.store.tick_ts
	end

	if self.make_animation then
		if self.tween_handle then
			timer:cancel(self.tween_handle)
		end

		self.scale = V.v(self.original_scale.x * 0.7, self.original_scale.y * 0.7)
		self.alpha = 0
		self.tween_handle = timer:tween(0.2, self, {
			alpha = 1,
			scale = {
				x = self.original_scale.x,
				y = self.original_scale.y
			}
		}, "in-quad", function()
			self.tween_handle = nil
		end)
	end
end

function TextBalloon:_detach()
	if game_gui.text_balloon_views and game_gui.text_balloon_views[self.id] == self then
		game_gui.text_balloon_views[self.id] = nil
	end

	if game_gui.tutorial_balloon == self then
		game_gui.tutorial_balloon = nil
	end

	if self.parent then
		self:remove_from_parent()
	end
end

function TextBalloon:remove(animated)
	if self.remove_requested then
		return
	end

	self.remove_requested = true

	for _, handle in pairs(self.sig_handles or {}) do
		signal.remove(handle[1], handle[2])
	end

	self.sig_handles = {}

	if self.tween_handle then
		timer:cancel(self.tween_handle)
		self.tween_handle = nil
	end

	if animated then
		if self.balloon_on_hide then
			game_gui:show_balloon(self.balloon_on_hide)
		end

		local bd = data.text_balloons[self.id]
		local duration = bd and bd.hide_tween_time or 0.4

		self.tween_handle = timer:tween(duration, self, {
			alpha = 0,
			scale = {
				x = 0.4,
				y = 0.4
			}
		}, "in-back", function()
			self.tween_handle = nil
			self:_detach()
		end)
	else
		self:_detach()
	end
end

function TextBalloon:hide(not_animated)
	if self.remove_requested or self.hidden or not self.parent then
		return
	end

	if self.tween_handle then
		timer:cancel(self.tween_handle)
		self.tween_handle = nil
	end

	if not_animated then
		self.hidden = true

		return
	end

	local bd = data.text_balloons[self.id]
	local duration = bd and bd.hide_tween_time or 0.4

	self.tween_handle = timer:tween(duration, self, {
		alpha = 0,
		scale = {
			x = 0.4,
			y = 0.4
		}
	}, "in-back", function()
		self.tween_handle = nil
		self.hidden = true
	end)
end

function TextBalloon:update(dt)
	TextBalloon.super.update(self, dt)

	if self.world_pos then
		self.pos.x, self.pos.y = game_gui:w2u(self.world_pos)

		if not self.make_animation or not self.tween_handle then
			local zoom = game_gui.game and game_gui.game.camera and game_gui.game.camera.zoom or 1
			local world_scale = self.scale_world and 0.5 or 1

			self.scale.x = zoom * world_scale
			self.scale.y = zoom * world_scale
		end
	end

	if self.show_time and self.show_ts and not self.remove_requested and game_gui.game.store.tick_ts - self.show_ts > self.show_time then
		self:remove(true)
	end
end

TutorialBalloon = class("TutorialBalloon", KImageView)

function TutorialBalloon:initialize(id)
	local bd = data.tutorial_balloons[id]

	if not bd then
		log.error("Balloon with id:%s not found", id)

		return
	end

	TutorialBalloon.super.initialize(self, bd.image)

	if data.notification_slides[id] then
		local views = {}

		for i, d in pairs(data.notification_slides[id]) do
			local lv = GGLabel:new(V.v(d.size.x, d.size.y))

			lv.font_name = "body"
			lv.font_size = 18
			lv.text_align = "left"
			lv.colors.text = {
				17,
				20,
				12,
				255
			}

			table.deepmerge(lv, d)

			lv.text = _(lv.text)

			if lv.color and colors[lv.color] then
				lv.colors.text = colors[lv.color]
			end

			table.insert(views, lv)

			if DBG_SLIDE_EDITOR then
				function lv.on_click(this)
					game_gui.SEL_VIEW = this

					log.debug("SEL_VIEW: %s", this.text)
				end
			else
				lv.propagate_on_click = true
				lv.propagate_on_down = true
				lv.propagate_on_up = true
			end
		end

		for _, v in pairs(views) do
			self:add_child(v)
		end
	end

	self.id = id
	self.propagate_on_click = true
	self.propagate_on_down = true
	self.propagate_on_up = true
	self.balloon_on_hide = bd.balloon
	self.anchor = V.v(self.size.x / 2, self.size.y / 2)

	if bd.origin == "world" then
		self.pos.x, self.pos.y = game_gui:g2u(bd.offset)
	else
		local ox, oy

		if string.match(bd.origin, "top") then
			oy = 0
		end

		if string.match(bd.origin, "bottom") then
			oy = game_gui.sh
		end

		if string.match(bd.origin, "left") then
			ox = 0
		end

		if string.match(bd.origin, "right") then
			ox = game_gui.sw
		end

		if string.match(bd.origin, "center") then
			ox = game_gui.sw / 2
			oy = game_gui.sh / 2
		end

		self.pos.x, self.pos.y = ox + bd.offset.x, oy + bd.offset.y
	end

	self.sig_handles = {}

	local function sig_reg(name, fn)
		local h = signal.register(name, fn)

		table.insert(self.sig_handles, {
			name,
			h
		})
	end

	self.hide_cond = bd.hide_cond

	if self.hide_cond == "tower_built" then
		sig_reg("tower-built", function()
			self:remove(false)
		end)
		sig_reg("tower-menu-showing", function()
			self:hide()
		end)
		sig_reg("tower-menu-hiding", function()
			self:show()
		end)
	elseif self.hide_cond == "power_selected_1" then
		sig_reg("power-selected", function(mode)
			if mode == GUI_MODE_POWER_1 then
				self:remove(true)
			end
		end)
	elseif self.hide_cond == "power_selected_2" then
		sig_reg("power-selected", function(mode)
			if mode == GUI_MODE_POWER_2 then
				self:remove(true)
			end
		end)
	elseif self.hide_cond == "power_selected_3" then
		sig_reg("power-selected", function(mode)
			if mode == GUI_MODE_POWER_3 then
				self:remove(true)
			end
		end)
	elseif self.hide_cond == "power_used" then
		sig_reg("power-used", function()
			self:remove(true)
		end)
		sig_reg("power-deselected", function()
			self:remove(true)
		end)
	elseif self.hide_cond == "noti_shown" then
		sig_reg("notification-shown", function()
			self:remove(true)
		end)
	elseif self.hide_cond == "wave_sent" then
		sig_reg("next-wave-sent", function()
			self:remove(true)
		end)
	end

	sig_reg("game-defeat", function()
		self:remove(false)
	end)
	sig_reg("game-victory", function()
		self:remove(false)
	end)
	sig_reg("hide-gui", function()
		self:remove(false)
	end)

	self.hidden = true

	self:show()
end

function TutorialBalloon:loop_tween()
	if self.tween_handle then
		timer:cancel(self.tween_handle)
	end

	if self.hidden then
		return
	end

	local s = self.scale.x > 1 and 0.985 or 1.015

	self.tween_handle = timer:tween(0.3, self.scale, {
		x = s,
		y = s
	}, "in-out-sine", function()
		self:loop_tween()
	end)
end

function TutorialBalloon:hide()
	log.debug("TutorialBalloon:hide %s", self.id)

	if self.hidden or not self.parent then
		return
	end

	if self.tween_handle then
		timer:cancel(self.tween_handle)
	end

	local s = 0.4

	self.tween_handle = timer:tween(0.4, self, {
		alpha = 0,
		scale = {
			x = s,
			y = s
		}
	}, "in-back", function()
		self.hidden = true
	end)
end

function TutorialBalloon:remove(animated)
	log.debug("TutorialBalloon:remove animated:%s, id:%s, parent:%s", animated, self.id, self.parent)

	for _, h in pairs(self.sig_handles) do
		local name, fn = unpack(h)

		signal.remove(name, fn)
	end

	if self.tween_handle then
		timer:cancel(self.tween_handle)
	end

	if animated then
		if self.balloon_on_hide then
			game_gui:show_balloon(self.balloon_on_hide)
		end

		local s = 0.4

		self.tween_handle = timer:tween(0.4, self, {
			alpha = 0,
			scale = {
				x = s,
				y = s
			}
		}, "in-back", function()
			self:remove_from_parent()
		end)
	else
		self:remove_from_parent()
	end
end

function TutorialBalloon:show()
	log.debug("TutorialBalloon:show id:%s", self.id)

	if not self.hidden then
		return
	end

	if self.tween_handle then
		timer:cancel(self.tween_handle)
	end

	self.hidden = false

	timer:tween(0.3, self, {
		alpha = 1
	}, "in-quad")

	self.scale.x, self.scale.y = 0.8, 0.8

	self:loop_tween()
end

AchievementBanner = class("AchievementBanner", KImageView)

function AchievementBanner:initialize(id)
	AchievementBanner.super.initialize(self, "achievements_box_large")

	local header = GGLabel:new(V.v(78, 13))

	header.pos.x, header.pos.y = 95, 8.5 + CJK(0, -1, 0, 0)
	header.text = _("ACHIEVEMENT")
	header.vertical_align = "middle"
	header.text_align = "center"
	header.colors.text = {
		72,
		51,
		25,
		255
	}
	header.font_name = "h_noti"
	header.font_size = 16
	header.fit_lines = 1

	self:add_child(header)

	local icon = KImageView:new("achievement_icons_0001")

	icon.anchor = V.v(icon.size.x / 2, icon.size.y / 2)
	icon.pos = V.v(40, 54)
	icon.scale = V.v(0.8, 0.8)
	icon.propagate_on_click = true

	self:add_child(icon)

	local l_title = GGLabel:new(V.v(180, 14))

	l_title.pos = V.v(68, CJK(35, 33, nil, 33))
	l_title.font_name = "h"
	l_title.font_size = 12
	l_title.colors.text = {
		234,
		205,
		132
	}
	l_title.text = "TITLE"
	l_title.text_align = "left"
	l_title.propagate_on_click = true
	l_title.fit_lines = 1

	self:add_child(l_title)

	local l_desc = GGLabel:new(V.v(180, 32))

	l_desc.font_name = "body"
	l_desc.font_size = 10
	l_desc.colors.text = {
		246,
		227,
		176
	}
	l_desc.text = "DESC"
	l_desc.text_align = "left"
	l_desc.propagate_on_click = true
	l_desc.line_height = CJK(0.8, nil, 1.1, 0.9)

	l_desc:do_fit_lines(3)

	l_desc.clip = true
	l_desc.pos.x, l_desc.pos.y = 68, 45 + CJK(0, 3, 3, 1)

	self:add_child(l_desc)

	self.icon = icon
	self.l_title = l_title
	self.l_desc = l_desc

	function self.on_click(this)
		if self.active then
			this:hide()
		end
	end

	self.anchor = V.v(self.size.x / 2, self.size.y)
	self.pos = V.v(game_gui.sw / 2, -1)
	self.hidden = true
	self.queued_ids = {}
end

function AchievementBanner:queue(id)
	table.insert(self.queued_ids, id)
	self:show()
end

function AchievementBanner:show()
	if #self.queued_ids < 1 or not self.hidden then
		return
	end

	local id = table.remove(self.queued_ids, 1)
	local ach = AC:get_data(id)
	local prefix = KR_GAME == "kr3" and "ELVES_" or ""

	self.icon:set_image("achievement_icons_" .. string.format("%04i", ach.icon))

	self.l_title.text = _(prefix .. "ACHIEVEMENT_" .. ach.name .. "_NAME")
	self.l_desc.text = _(prefix .. "ACHIEVEMENT_" .. ach.name .. "_DESCRIPTION")
	self.hidden = false
	self.active = true

	S:queue("GUIAchievementWin", {
		ignore = 1
	})

	if self.timers then
		for _, t in pairs(self.timers) do
			timer:cancel(t)
		end
	end

	self.timers = {
		timer:tween(0.5, self.pos, {
			y = self.size.y * self.scale.y + 10
		}, "out-back"),
		timer:after(4, function()
			self:hide()
		end)
	}
end

function AchievementBanner:hide()
	if self.timers then
		for _, t in pairs(self.timers) do
			timer:cancel(t)
		end
	end

	self.timers = {}
	self.active = false
	self.timers = {
		timer:tween(0.5, self.pos, {
			y = -1
		}, "in-back", function()
			self.timers = nil
			self.hidden = true

			if #self.queued_ids > 0 then
				self:show()
			end
		end)
	}
end


PickView = class("PickView", KView)

function PickView:initialize(w, h)
	PickView.super.initialize(self)

    self.propagate_on_up = true
    self.propagate_on_down = true
    self.propagate_on_click = true
	self.size = v(w, h)
	self.clip = false
	self.colors.background = {
		0,
		0,
		0,
		0
	}
end

function PickView:update(dt)
	local function show_tower_hover(entity)
		if game_gui.game.store.paused then
			return
		end

		local s = entity.render and entity.render.sprites and entity.render.sprites[1]

		if not s then
			return
		end

		s._orig_name = s.name
		if not s.exo then
			s.name = s.name .. "_over"
		end

		if s.hover_off_hidden then
			s.hidden = nil
		end

		self.last_tower_hover = entity

		S:queue("GUIQuickMenuOver")
	end

	local function hide_tower_hover()
		local oe = self.last_tower_hover

		if oe then
			local s = oe.render and oe.render.sprites and oe.render.sprites[1]

			if s then
				s.name = s._orig_name

				if s.hover_off_hidden then
					s.hidden = true
				end
			end

			self.last_tower_hover = nil
		end
	end

	PickView.super.update(self, dt)

	local e = game_gui.selected_entity

	-- Repairable broken towers must stay selectable while blocked. The
	-- one-shot flag closes a menu when a tower breaks or finishes repair.
	local blocked_without_repair_menu = e and e.tower and e.tower.blocked
		and e.tower.type ~= "tower_timed_destroy"
		and not string.find(e.tower.type or "", "tower_broken", 1, true)
	local dead = e and e.health and e.health.dead and not e.health.ignore_damage

	if e and (e.trigger_deselect or blocked_without_repair_menu or dead) then
		e.trigger_deselect = nil
		game_gui:deselect_all()
	end

	if self:is_disabled() or game_gui.mode ~= GUI_MODE_IDLE then
		hide_tower_hover()

		return
	elseif not game_gui.towermenu.hidden then
		local e = game_gui.selected_entity

		if e and game_gui.selected_entity and self.last_tower_hover ~= e then
			hide_tower_hover()

			if e.tower and e.tower.can_hover and e.ui and e.ui.can_click and not self.last_tower_hover then
				show_tower_hover(e)
			end
		end

		return
	end

	local x, y = game_gui.window:get_mouse_position()

	x, y = game_gui.window:screen_to_view(x, y)

	local wx, wy = game_gui:u2g(V.v(x, y))
	local e = game_gui:entity_at_pos(wx, wy)

	if e and e.tower and e.tower.can_hover and e.ui and e.ui.can_click and not self.last_tower_hover then
		show_tower_hover(e)
	elseif self.last_tower_hover and (not e or e ~= self.last_tower_hover) then
		hide_tower_hover()
	end
end

function PickView:on_down(button, x, y)
	local wx, wy = game_gui:u2g(V.v(x, y))

	log.debug("button:%d, screen:%s,%s  world:%s,%s", button, x, y, wx, wy)

	if button == 2 then
		if game_gui.mode == GUI_MODE_FREE_HOLDER then
			game_gui:set_mode()

			return true
		end

		if DEBUG_RIGHT_CLICK then
			DEBUG_RIGHT_CLICK(wx, wy)
		end
	elseif button == 1 then
		if game_gui.mode == GUI_MODE_FREE_HOLDER then
			local store = game_gui.game.store

			if can_place_free_holder(store, wx, wy) then
				insert_free_holder(store, wx, wy)
				game_gui:show_point_confirm(x, y)
				game_gui:set_mode()
				S:queue("GUIPlaceRallyPoint")
			else
				game_gui:show_invalid_point_cross(x, y)
			end

			return true
		elseif game_gui.mode == GUI_MODE_RALLY_TOWER then
			self:rally_tower(x, y)
			return true
		elseif game_gui.mode == GUI_MODE_RALLY_HERO then
			self:rally_hero(x, y)
			return true
		elseif game_gui.mode == GUI_MODE_SELECT_POINT then
			local e = game_gui.selected_entity

			if e.user_selection.can_select_point_fn and not e.user_selection.can_select_point_fn(e, wx, wy, game_gui.game.store) then
				game_gui:show_invalid_point_cross(x, y)

				return true
			end

			e.user_selection.in_progress = false
			e.user_selection.new_pos = v(wx, wy)

			game_gui:deselect_entity()
			log.debug("fire to %s", v(wx, wy))

			return true
		elseif game_gui.mode == GUI_MODE_POWER_1 or game_gui.mode == GUI_MODE_POWER_2 or game_gui.mode == GUI_MODE_POWER_3 then
			local slot = game_gui.mode == GUI_MODE_POWER_1 and 1 or game_gui.mode == GUI_MODE_POWER_2 and 2 or 3
			local button_view = slot == 1 and game_gui.power_1 or slot == 2 and game_gui.power_2 or game_gui.power_3

			if selected_power_can_fire(slot, wx, wy, game_gui.game.store) then
				button_view:fire(wx, wy)
			else
				game_gui:show_invalid_point_cross(x, y)
			end

			return false
		elseif game_gui.mode == GUI_MODE_POWER_A or game_gui.mode == GUI_MODE_POWER_S then
			local slot = game_gui.mode == GUI_MODE_POWER_A and "a" or "s"
			local button_view = slot == "a" and game_gui.power_a or game_gui.power_s
			if slot == "s" and game_gui.infinite_ultimate_button then
				local custom = game_gui.infinite_ultimate_button
				if custom:can_fire(wx, wy) then custom:fire(wx, wy) else game_gui:show_invalid_point_cross(x, y) end
				return false
			end

			if button_view and hero_ultimate_slot_can_fire(slot, wx, wy, game_gui.game.store) then
				button_view:fire(wx, wy)
			else
				game_gui:show_invalid_point_cross(x, y)
			end

			return false
		elseif game_gui.mode == GUI_MODE_POWER_1 then
			local store = game_gui.game.store
			local level = store.level
			local hero = nil
			local he = nil
			local user_data = storage:load_slot()
			local is_double = user_data and user_data.liuhui_hero and user_data.liuhui_hero.usedoublehero
			if is_double then
				hero, he = power_hero_template(1)
			end

			if hero and hero_game_ver(hero.template_name) >= 3 then
				if he then
					local un = he.hero.skills.ultimate
					local ut = E:get_template(un.controller_name)
					--print(un.controller_name)
					if not ut.can_fire_fn or ut.can_fire_fn(ut, wx, wy, game_gui.game.store) then
						game_gui.power_1:fire(wx, wy)
					else
						game_gui:show_invalid_point_cross(x, y)
					end
				else
					game_gui:show_invalid_point_cross(x, y)
				end
			elseif not GR:cell_is(wx, wy, TERRAIN_CLIFF) and not GR:cell_is(wx, wy, TERRAIN_FAERIE) and (P:valid_node_nearby(wx, wy, 1.4285714285714286, NF_POWER_1) or level.fn_can_power and level:fn_can_power(store, GUI_MODE_POWER_1, V.v(wx, wy)) or GR:cell_is(wx, wy, TERRAIN_WATER)) then
				game_gui.power_1:fire(wx, wy)
			else
				game_gui:show_invalid_point_cross(x, y)
			end

			return false
		elseif game_gui.mode == GUI_MODE_POWER_2 then
			if P:valid_node_nearby(wx, wy, nil, NF_RALLY) and GR:cell_is_only(wx, wy, bor(TERRAIN_LAND, TERRAIN_ICE)) then
				game_gui.power_2:fire(wx, wy)
			else
				game_gui:show_invalid_point_cross(x, y)
			end

			return false
		elseif game_gui.mode == GUI_MODE_POWER_3 then
			
			local user_data = storage:load_slot()
			local rank = 1
			local is_double = user_data and user_data.liuhui_hero and user_data.liuhui_hero.usedoublehero
			if is_double then
				rank = 2
			end
			local hero, he = power_hero_template(rank)

			if hero and hero_game_ver(hero.template_name) < 3 then
				local e = U.find_entity_at_pos(game_gui.game.simulation.store.entities, wx, wy, function(entity)
					return entity.enemy
				end)
				if e then
					game_gui.power_3:fire(wx, wy)
				else
					game_gui:show_invalid_point_cross(x, y)
				end

				return false
			elseif hero and he then
				local un = he.hero.skills.ultimate
				local ut = E:get_template(un.controller_name)
				

				if not ut.can_fire_fn or ut.can_fire_fn(ut, wx, wy, game_gui.game.store) then
					game_gui.power_3:fire(wx, wy)
				else
					game_gui:show_invalid_point_cross(x, y)
				end

				return true
			else
				game_gui:show_invalid_point_cross(x, y)

				return false
			end
		end

		local e = game_gui:entity_at_pos(wx, wy)

		if e then
			log.info("SELECTED ENTITY (%s) %s pos:(%s,%s)", e.id, e.template_name, e.pos.x, e.pos.y)
		end

		if e and e.ui and e.ui.can_click then
			e.ui.clicked = true

			if e ~= game_gui.selected_entity then
				game_gui:select_entity(e)
			elseif not e.enemy then
				game_gui:deselect_entity()
			end
		else
			game_gui:deselect_entity()
		end
	end
	return true
end

function PickView:rally_tower(x, y)
	local wx, wy = game_gui:u2g(v(x, y))
	local e = game_gui.selected_entity
	local b = e.barrack
	local rc = V.v(V.add(e.pos.x, e.pos.y, e.tower.range_offset.x, e.tower.range_offset.y))

	if U.is_inside_ellipse(v(wx, wy), rc, b.rally_range) and (b.rally_anywhere or P:valid_node_nearby(wx, wy, nil, NF_RALLY) and GR:cell_is_only(wx, wy, b.rally_terrains)) then
		S:queue("GUIPlaceRallyPoint")

		e.barrack.rally_pos = v(wx, wy)
		e.barrack.rally_new = true

		game_gui:show_rally_flag(x, y)
		game_gui:hide_rally_range()
		game_gui:deselect_entity()
		return true
	end

	local cx, cy = e.pos.x, e.pos.y
	for it = 1, 199 do
		local lx, ly = (cx * it + wx * (200-it))/ 200, (cy * it + wy * (200-it))/ 200
		if U.is_inside_ellipse(v(lx, ly), rc, b.rally_range) and (b.rally_anywhere or P:valid_node_nearby(lx, ly, nil, NF_RALLY) and GR:cell_is_only(lx, ly, b.rally_terrains)) then
			S:queue("GUIPlaceRallyPoint")

			e.barrack.rally_pos = v(lx, ly)
			e.barrack.rally_new = true

			game_gui:show_rally_flag(game_gui:g2u(e.barrack.rally_pos))
			game_gui:hide_rally_range()
			game_gui:deselect_entity()
			return true
		else 
			if U.is_inside_ellipse(v(lx, ly), rc, b.rally_range) then
				--print(string.format("%.4f, %.4f", lx, ly))
			end
		end
	end
	game_gui:show_invalid_point_cross(x, y)
	return false
end

function PickView:rally_hero(x, y)
	local wx, wy = game_gui:u2g(v(x, y))
	local e = game_gui.selected_entity

	--print("rally hero 7044")

	if (not e.nav_rally.requires_node_nearby or P:valid_node_nearby(wx, wy, nil, NF_RALLY)) and GR:cell_is_only(wx, wy, e.nav_grid.valid_terrains_dest) and (e.teleport and V.dist(wx, wy, e.pos.x, e.pos.y) > e.teleport.min_distance or e.nav_grid.ignore_waypoints or GR:find_waypoints(e.pos, e.nav_rally.pos, V.v(wx, wy), e.nav_grid.valid_terrains)) then
		if not e.nav_grid.ignore_waypoints then
			e.nav_grid.waypoints = GR:find_waypoints(e.pos, e.nav_rally.pos, V.v(wx, wy), e.nav_grid.valid_terrains)
		end

		e.nav_rally.new = true
		e.nav_rally.pos = v(wx, wy)
		e.nav_rally.center = v(wx, wy)

		game_gui:show_point_confirm(x, y)
		game_gui:deselect_entity()
		return true
	end

	local search_point = 200

	local cx, cy = e.pos.x, e.pos.y
	if game_gui.game.store.level_idx == 71 or game_gui.game.store.level_idx == 72 or (game_gui.game.store.level_idx > GS.jnum4 and game_gui.game.store.level_idx <= GS.last_level4) then
		search_point = 10
	end
	for it = 1, search_point - 1 do
		local lx, ly = (cx * it + wx * (search_point-it))/ search_point, (cy * it + wy * (search_point-it))/ search_point
		if (not e.nav_rally.requires_node_nearby or P:valid_node_nearby(lx, ly, nil, NF_RALLY)) and GR:cell_is_only(lx, ly, e.nav_grid.valid_terrains_dest) and (e.teleport and V.dist(lx, ly, e.pos.x, e.pos.y) > e.teleport.min_distance or e.nav_grid.ignore_waypoints or GR:find_waypoints(e.pos, e.nav_rally.pos, V.v(lx, ly), e.nav_grid.valid_terrains)) then
			if not e.nav_grid.ignore_waypoints then
				e.nav_grid.waypoints = GR:find_waypoints(e.pos, e.nav_rally.pos, V.v(lx, ly), e.nav_grid.valid_terrains)
			end

			e.nav_rally.new = true
			e.nav_rally.pos = v(lx, ly)
			e.nav_rally.center = v(lx, ly)

			game_gui:show_point_confirm(x, y)
			game_gui:deselect_entity()
			return true
		end
	end
	::label_7079_0::
	game_gui:show_invalid_point_cross(x, y)
	return false
end

function PickView:rally_reinforcement(x, y)
	local wx, wy = game_gui:u2g(v(x, y))
	local e = game_gui.selected_entity

	if e.reinforcement.squad_id then
		mark_entities = table.filter(game.store.entities, function(_, ee)
			return ee.reinforcement and ee.reinforcement.squad_id == e.reinforcement.squad_id
		end)
	else
		mark_entities = {e}
	end

	if (not e.nav_rally.requires_node_nearby or P:valid_node_nearby(wx, wy, nil, NF_RALLY)) and GR:cell_is_only(wx, wy, e.nav_grid.valid_terrains_dest) and (e.teleport and V.dist(wx, wy, e.pos.x, e.pos.y) > e.teleport.min_distance or e.nav_grid.ignore_waypoints or GR:find_waypoints(e.pos, e.nav_rally.pos, V.v(wx, wy), e.nav_grid.valid_terrains)) then
		for  _, ee in pairs(mark_entities) do
			if not ee.nav_grid.ignore_waypoints then
				ee.nav_grid.waypoints = GR:find_waypoints(ee.pos, ee.nav_rally.pos, V.v(wx, wy), ee.nav_grid.valid_terrains)
			end

			local origin_pose = table.deepclone(ee.nav_rally.pos)
			local origin_center = table.deepclone(ee.nav_rally.center)
			ee.nav_rally.new = true
			ee.nav_rally.center = v(wx, wy)
			ee.nav_rally.pos = v(wx + (origin_pose.x - origin_center.x), wy + (origin_pose.y - origin_center.y))
			
		end

		game_gui:show_point_confirm(x, y)
		game_gui:deselect_entity()
		return true
	end

	local cx, cy = e.pos.x, e.pos.y
	for it = 1, 199 do
		local lx, ly = (cx * it + wx * (200-it))/ 200, (cy * it + wy * (200-it))/ 200
		if (not e.nav_rally.requires_node_nearby or P:valid_node_nearby(lx, ly, nil, NF_RALLY)) and GR:cell_is_only(lx, ly, e.nav_grid.valid_terrains_dest) and (e.teleport and V.dist(lx, ly, e.pos.x, e.pos.y) > e.teleport.min_distance or e.nav_grid.ignore_waypoints or GR:find_waypoints(e.pos, e.nav_rally.pos, V.v(lx, ly), e.nav_grid.valid_terrains)) then
			for  _, ee in pairs(mark_entities) do
				if not ee.nav_grid.ignore_waypoints then
					ee.nav_grid.waypoints = GR:find_waypoints(ee.pos, ee.nav_rally.pos, V.v(lx, ly), ee.nav_grid.valid_terrains)
				end

				local origin_pose = table.deepclone(ee.nav_rally.pos)
				local origin_center = table.deepclone(ee.nav_rally.center)
				ee.nav_rally.new = true
				ee.nav_rally.center = v(lx, ly)
				ee.nav_rally.pos = v(lx + (origin_pose.x - origin_center.x), ly + (origin_pose.y - origin_center.y))
				
			end

			game_gui:show_point_confirm(lx, ly)
			game_gui:deselect_entity()
			return true
		end
	end

	game_gui:show_invalid_point_cross(x, y)
	return false
end

RangeCircle = class("RangeCircle", KView)

function RangeCircle:initialize(sprite_name)
	RangeCircle.super.initialize(self)

	self.range_shown = nil

	local tl = KImageView:new(sprite_name)
	local tr = KImageView:new(sprite_name)
	local bl = KImageView:new(sprite_name)
	local br = KImageView:new(sprite_name)

	tl.anchor = v(tl.size.x - 0.15, tl.size.y - 0.15)
	tl.scale = v(1, 1)
	tr.anchor = v(tl.size.x - 0.15, tl.size.y - 0.15)
	tr.scale = v(-1, 1)
	bl.anchor = v(tl.size.x - 0.15, tl.size.y - 0.15)
	bl.scale = v(1, -1)
	br.anchor = v(tl.size.x - 0.15, tl.size.y - 0.15)
	br.scale = v(-1, -1)
	tl.propagate_on_down = true
	tr.propagate_on_down = true
	bl.propagate_on_down = true
	br.propagate_on_down = true

	self:add_child(tl)
	self:add_child(tr)
	self:add_child(bl)
	self:add_child(br)

	self.can_drag = false
	self.propagate_on_click = true
	self.scale = v(1, 0.7)
	self.actual_radius = v(tl.size.x, tl.size.y)
end

TowerMenu = class("TowerMenu", KImageView)

function TowerMenu:initialize()
	TowerMenu.super.initialize(self, "gui_ring")

	self.can_drag = false
	self.propagate_on_click = true
	self.propagate_on_down = true
	self.propagate_on_up = true
	self.propagate_on_enter = true
	self.anchor = v(self.size.x / 2, self.size.y / 2)
	self.clip = false
end

function TowerMenu:android_world_scale()
	if game_gui.game and game_gui.game.camera then
		return game_gui.game.camera.zoom or 1
	end

	return 1
end

function TowerMenu:clear_android_confirmation()
	if not IS_ANDROID then
		return
	end

	for _, child in ipairs(self.children or {}) do
		if child.android_confirm_armed then
			child.android_confirm_armed = false
			child:on_exit()
		end
	end
end

function TowerMenu:fit_inside_screen(x, y, scale)
	local margin = 8
	local min_x = -self.anchor.x
	local max_x = self.size.x - self.anchor.x
	local min_y = -self.anchor.y
	local max_y = self.size.y - self.anchor.y

	for _, child in ipairs(self.children or {}) do
		if not child.hidden and child.pos and child.size then
			min_x = math.min(min_x, child.pos.x - self.anchor.x)
			max_x = math.max(max_x, child.pos.x + child.size.x - self.anchor.x)
			min_y = math.min(min_y, child.pos.y - self.anchor.y)
			max_y = math.max(max_y, child.pos.y + child.size.y - self.anchor.y)
		end
	end

	local left = margin - min_x * scale
	local right = game_gui.sw - margin - max_x * scale
	local top = margin - min_y * scale
	local bottom = game_gui.sh - margin - max_y * scale

	x = left <= right and math.max(left, math.min(right, x)) or game_gui.sw * 0.5
	y = top <= bottom and math.max(top, math.min(bottom, y)) or game_gui.sh * 0.5

	return x, y
end

function TowerMenu:show()
	local entity = game_gui.selected_entity

	if not entity or not entity.tower then
		return
	end

	if entity.user_selection then
		entity.user_selection.menu_shown = true
	end

	game_gui:hide_tower_ranges()

	if entity.attacks and entity.attacks.range and not entity.attacks.hide_range then
		local range = entity.attacks.range
		local ux, uy = game_gui:g2u(V.v(V.add(entity.pos.x, entity.pos.y, entity.tower.range_offset.x, entity.tower.range_offset.y)))

		game_gui:show_tower_range(ux, uy, range)
	end

	-- Stage 6-8 changes a built tower's type while leaving its upgrade level
	-- untouched; the repair menu has a single entry shared by every level.
	local menu_level = entity.tower.type == "tower_broken_stage_08" and 1 or entity.tower.level

	if not tower_menus[entity.tower.type] or not tower_menus[entity.tower.type][menu_level] then
		log.debug("tower_menus[%s][%s] not found", entity.tower.type, menu_level)

		self.hidden = true

		return
	end

	local tm = tower_menus[entity.tower.type][menu_level]
---重生
	if entity.tower.page then
		local page_key = entity.tower.type .. "_" .. entity.tower.page
		local page_menu = tower_menus[page_key]

		if page_menu and page_menu[1] then
			tm = page_menu[1]
		else
			log.debug("tower_menus[%s][1] not found, fallback to tower_menus[%s][%s]", page_key, entity.tower.type, menu_level)
			entity.tower.page = nil
			tm = tower_menus[entity.tower.type][menu_level]
		end
	else
		tm = tower_menus[entity.tower.type][menu_level]
	end
	--改动
	if tm and tm.page and tm.pages and #tm.pages > 0 then
		tm.page = (tm.page % #tm.pages) + 1
		tm = tm.pages[tm.page]
	end

	if not tm then
		self.hidden = true

		return
	end

	-- A previous first tap may still be holding a tower preview open. Clear it
	-- before rebuilding the radial menu, otherwise its translucent sprite is
	-- left attached to the old tower holder.
	self:clear_android_confirmation()
	self:remove_children()

	for _, item in pairs(tm) do
		if item.action == "tw_upgrade" and game_gui.game.store.level.locked_towers and table.contains(game_gui.game.store.level.locked_towers, item.action_arg) and not DEBUG_UNLOCK_ALL_TOWERS then
			local b = KImageView:new("main_icons_0014")

			b.pos = V.vclone(data.tower_menu_button_places[item.place])
			b.pos.x, b.pos.y = b.pos.x - b.size.x / 2, b.pos.y - b.size.y / 2

			self:add_child(b)

			if IS_KR3 then
				local bo = KImageView:new("main_icons_over")

				bo.pos = v(math.floor(-0.5 * (bo.size.x - b.size.x)), math.floor(-0.5 * (bo.size.y - b.size.y)))
				bo.propagate_on_click = true
				bo.disabled_tint_color = nil

				b:add_child(bo)
			end
		elseif item.action == "tw_sell" and entity.tower and not entity.tower.can_be_sold then
			-- block empty
		else
			local b = TowerMenuButton:new(item, entity)

			b.pos = V.vclone(data.tower_menu_button_places[item.place])
			b.pos.x, b.pos.y = b.pos.x - b.size.x / 2, b.pos.y - b.size.y / 2

			if item.action == "tw_none" then
				b:disable()
			end
			self:add_child(b)
		end
	end

	if self.tweeners then
		for _, t in pairs(self.tweeners) do
			timer:cancel(t)
		end
	end

	local ro = entity.tower.range_offset
	local mo = entity.tower.menu_offset
	local ewx, ewy = game_gui:g2u(V.v(entity.pos.x + ro.x + mo.x, entity.pos.y + ro.y + mo.y), true)
	local menu_scale = self:android_world_scale()

	ewx, ewy = self:fit_inside_screen(ewx, ewy, menu_scale)
	self.pos = v(ewx, ewy)

	self.scale = v(0.6 * menu_scale, 0.6 * menu_scale)
	self.alpha = 0
	self.hidden = false
	self.tweening = true
	self.tweeners = {
		timer:tween(0.12, self.scale, {
			x = menu_scale,
			y = menu_scale
		}, "out-quad"),
		timer:tween(0.12, self, {
			alpha = 1
		}, "out-quad", function()
			self.tweening = nil
			self.tweeners = {}
		end)
	}

	signal.emit("tower-menu-showing")
	S:queue("GUIQuickMenuOpen")
end

function TowerMenu:hide()
	-- Closing the menu by tapping the world must cancel a pending Android
	-- confirmation just like moving to another menu button does.
	self:clear_android_confirmation()

	local entity = game_gui.selected_entity

	if entity and entity.user_selection then
		entity.user_selection.menu_shown = nil
	end

	if self.tweeners then
		for _, t in pairs(self.tweeners) do
			timer:cancel(t)
		end
	end

	local menu_scale = self:android_world_scale()

	self.tweening = true
	self.tweeners = {
		timer:tween(0.12, self, {
			alpha = 0
		}, "out-quad"),
		timer:tween(0.12, self.scale, {
			x = 0.6 * menu_scale,
			y = 0.6 * menu_scale
		}, "out-quad", function()
			self.hidden = true
			self.tweening = false
			self.tweeners = {}
		end)
	}

	game_gui:hide_tower_ranges()
	game_gui.towertooltip:hide()
	signal.emit("tower-menu-hiding")
end

function TowerMenu:update(dt)
	TowerMenu.super.update(self, dt)

	if self.hidden then
		return
	end

	local e = game_gui.selected_entity

	if not e or not e.tower then
		return
	end

	if e and e.attacks and e.attacks.range and not game_gui.tower_range.hidden and game_gui.tower_range.range_shown ~= e.attacks.range then
		local ux, uy = game_gui:g2u(V.v(V.add(e.pos.x, e.pos.y, e.tower.range_offset.x, e.tower.range_offset.y)), true)

		game_gui:show_tower_range(ux, uy, e.attacks.range)

		if not game_gui.tower_range_upgrade.hidden and e.template_name == "tower_crossbow" then
			if e.powers.eagle.level < 3 then
				local m = E:get_template("mod_crossbow_eagle")
				local factor = e.powers.eagle.level < 1 and m.range_factor + m.range_factor_inc or 1 + m.range_factor_inc
				local range = e.attacks.range * factor

				game_gui:show_tower_range_upgrade(ux, uy, range)
			else
				game_gui:hide_tower_range_upgrade()
			end
		end
	end
end

TowerMenuTooltip = class("TowerMenuTooltip", KImageView)

function TowerMenuTooltip:initialize()
	TowerMenuTooltip.super.initialize(self, "tooltip_bg_standard")

	local margin = v(10, 14)
	local title = GGLabel:new(V.v(self.size.x - 2 * margin.x, 16))

	title.pos = v(margin.x, margin.y + CJK(0, -2, nil, nil))
	title.font_name = "h"
	title.font_size = 12.8
	title.colors.text = {
		205,
		245,
		55
	}
	title.text_align = "left"
	title.text = "ARCHER TOWER"
	title.fit_lines = 1
	self.title = title

	self:add_child(title)

	local desc = GGLabel:new(V.v(self.size.x - 2 * margin.x, 74))

	desc.pos = v(margin.x, margin.y + 14)
	desc.font_name = "body"
	desc.font_size = 12.5
	desc.line_height = CJK(0.9, nil, 1.1, 0.9)
	desc.colors.text = {
		240,
		230,
		185
	}
	desc.text_align = "left"
	desc.text = "Archers ready to strike at your enemies from a distance."
	desc.fit_size = true
	self.desc = desc

	self:add_child(desc)

	local bottom_margin = 26
	local font_size = 10
	local text_offset = v(18, CJK(3, 1, 1, 1))
	local w2 = (self.size.x - margin.x) / 2
	local w3 = (self.size.x - margin.x) / 3
	local p12, p22 = margin.x / 2, margin.x / 2 + w2
	local p13, p23, p33 = margin.x / 2, margin.x / 2 + w3, margin.x / 2 + 2 * w3
	local damage_label = GGLabel:new(V.v(self.size.x / 3, 16), "tooltip_icons_0007")

	damage_label.pos = v(p13, self.size.y - bottom_margin)
	damage_label.font_name = "sans"
	damage_label.font_size = font_size
	damage_label.colors.text = {
		205,
		245,
		55
	}
	damage_label.text_offset = text_offset
	damage_label.text_align = "left"
	damage_label.text = "6-8"
	self.damage_label = damage_label

	self:add_child(damage_label)

	local cooldown_label = GGLabel:new(V.v(self.size.x / 2, 16), "tooltip_icons_0009")

	cooldown_label.pos = v(p23, self.size.y - bottom_margin)
	cooldown_label.font_name = "sans"
	cooldown_label.font_size = font_size
	cooldown_label.colors.text = {
		205,
		245,
		55
	}
	cooldown_label.text_offset = text_offset
	cooldown_label.text_align = "left"
	cooldown_label.text = "Average"
	self.cooldown_label = cooldown_label

	self:add_child(cooldown_label)

	local health_label = GGLabel:new(V.v(self.size.x / 3, 16), "tooltip_icons_0006")

	health_label.pos = v(p23, self.size.y - bottom_margin)
	health_label.font_name = "sans"
	health_label.font_size = font_size
	health_label.colors.text = {
		205,
		245,
		55
	}
	health_label.text_offset = text_offset
	health_label.text_align = "left"
	health_label.text = "100"
	self.health_label = health_label

	self:add_child(health_label)

	local armor_label = GGLabel:new(V.v(self.size.x / 3, 16), "tooltip_icons_0004")

	armor_label.pos = v(p33, self.size.y - bottom_margin)
	armor_label.font_name = "sans"
	armor_label.font_size = font_size
	armor_label.colors.text = {
		205,
		245,
		55
	}
	armor_label.text_offset = text_offset
	armor_label.text_align = "left"
	armor_label.text = "Medium"
	self.armor_label = armor_label

	self:add_child(armor_label)

	local phrase_label = GGLabel:new(V.v(self.size.x - 2 * margin.x, 16))

	phrase_label.pos = v(margin.x, self.size.y - 22)
	phrase_label.font_name = "sans"
	phrase_label.font_size = font_size
	phrase_label.colors.text = {
		170,
		160,
		125
	}
	phrase_label.text_align = "left"
	self.phrase_label = phrase_label

	self:add_child(phrase_label)
end

function TowerMenuTooltip:set_template(template)
	return
end

function TowerMenuTooltip:show(entity, item)
	self.entity = entity
	self.hidden = false
	self.title.text_runs = nil
	self.desc.text_runs = nil
	self.damage_label.hidden = true
	self.health_label.hidden = true
	self.armor_label.hidden = true
	self.cooldown_label.hidden = true
	self.phrase_label.hidden = true

	if item.action == "tw_upgrade" then
		self.title.text = item.tt_title or _(item.action_arg)
		self.desc.text = GU.balance_format(item.tt_desc, balance) or "" -- item.tt_desc or ""

		local te

		if entity.tower_holder then
			te = E:get_template(item.action_arg)

			if te and te.build_name then
				te = E:get_template(te.build_name)
			end
		else
			te = E:get_template(item.action_arg)
		end

		local stats = te.info.fn(te)

		if stats.type == STATS_TYPE_TOWER_BARRACK then
			self.damage_label.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

			self.damage_label:set_image("tooltip_icons_0007", V.v(self.damage_label.size.x, self.damage_label.size.y))

			self.health_label.text = stats.hp_max
			self.armor_label.text = stats.armor and string.format(_("%i%%"), stats.armor * 100) .. "" .. GU.armor_value_desc(stats.armor) or GU.armor_value_desc(stats.armor)
			self.damage_label.hidden = false
			self.health_label.hidden = false
			self.armor_label.hidden = false
		elseif stats.type == STATS_TYPE_TOWER or stats.type == STATS_TYPE_TOWER_MAGE then
			self.damage_label.text = GU.damage_value_desc(stats.damage_min, stats.damage_max)

			self.damage_label:set_image(stats.type == STATS_TYPE_TOWER_MAGE and "tooltip_icons_0010" or "tooltip_icons_0007", V.v(self.damage_label.size.x, self.damage_label.size.y))

			self.cooldown_label.text =  stats.cooldown and string.format(_("%s sec"), stats.cooldown * 1) .. " / " .. GU.cooldown_value_desc(stats.cooldown) or GU.cooldown_value_desc(stats.cooldown)
			self.damage_label.hidden = false
			self.cooldown_label.hidden = false
		end
	elseif item.action == "upgrade_power" then

		if item.tt_phrase then
			self.phrase_label.text = item.tt_phrase
			self.phrase_label.hidden = false

			self.phrase_label:do_fit_lines(1, 10, 0.15)
		end

		local power = entity.powers[item.action_arg]
		local show_level = km.clamp(1, power.max_level, power.level + 1)
		local texts = item.tt_list[show_level] or item.tt_list[#item.tt_list]
		local doc_title, doc_desc, previous_doc_desc, next_doc_desc = tower_doc_power_text(entity, item.action_arg, show_level)
		local desc = GU.balance_format(doc_desc or texts.tt_desc, balance) or ""
		local previous_desc
		local next_desc

		if previous_doc_desc ~= nil then
			previous_desc = GU.balance_format(previous_doc_desc, balance) or previous_doc_desc
		elseif show_level > 1 then
			local previous_texts = item.tt_list[show_level - 1]

			previous_desc = previous_texts and (GU.balance_format(previous_texts.tt_desc, balance) or previous_texts.tt_desc) or ""
		else
			previous_desc = ""
		end

		if show_level == 1 then
			if doc_desc then
				next_desc = next_doc_desc
			else
				local next_texts = item.tt_list[2]

				next_desc = next_texts and next_texts.tt_desc or nil
			end

			if next_desc then
				next_desc = GU.balance_format(next_desc, balance) or next_desc
			end
		end

		local tower_name = entity.template_name or entity.tower and entity.tower.type

		desc = tower_power_display.append_cooldown(desc, tower_name, item.action_arg, power, show_level)
		previous_desc = tower_power_display.append_cooldown(previous_desc, tower_name, item.action_arg, power, show_level - 1)
		next_desc = tower_power_display.append_cooldown(next_desc, tower_name, item.action_arg, power, show_level + 1)

		local text_runs = show_level == 1 and tower_balance_highlight.next_upgrade_runs(desc, next_desc) or tower_balance_highlight.upgrade_runs(previous_desc, desc)

		self.title.text = doc_title or texts.tt_title
		self.desc.text = tower_balance_highlight.runs_text(text_runs, desc)
		self.desc.text_runs = text_runs

		if power.level == power.max_level then
			self.hidden = false
		end
	elseif item.action == "tw_add_holder" then
		self.title.text = item.tt_title or "Thêm vị trí tháp"
		self.desc.text = item.tt_desc or "Chọn khoảng đất trống trên bản đồ để tạo vị trí xây tháp mới."
		--[[
		local power = entity.powers[item.action_arg]

		if power.level == power.max_level and not TOWERMENU_SHOW_TOOLTIP_ON_MAXED_POWER then
			self.hidden = true
		else
			local show_level = km.clamp(1, #item.tt_list, power.level + 1)
			local texts = item.tt_list[show_level]

			self:ci("title").text = texts.tt_title
			self:ci("desc").text = GU.balance_format(texts.tt_desc, balance)

			if item.tt_phrase then
				local b = self:ci("bottom_type_phrase")

				b.hidden = false
				has_bottom_view = true
				b:ci("phrase").text = item.tt_phrase
			end
		end
		]]--
	elseif item.action == "tw_buy_soldier" then
		if item.tt_list then
			local texts = item.tt_list[km.clamp(1, #item.tt_list, entity.barrack.max_soldiers + 1)]

			self.title.text = texts.tt_title
			self.desc.text = GU.balance_format(texts.tt_desc, balance) or ""
		else
			if item.tt_title then
				a = item.tt_title
				self.title.text = a --item.tt_title
			end
			if item.tt_desc then
				self.desc.text = GU.balance_format(item.tt_desc, balance) or ""
			end
		end
---重生		
	elseif item.action == "tw_buy_attack" or item.action == "tw_unblock" or item.action == "tw_free_action" or item.action == "tw_overseer_recover" or item.action == "tw_repair" or item.action == "tw_page" or item.action == "tw_custom_no_close" or item.action == "tw_custom_close" then
		if item.tt_title then
			self.title.text = item.tt_title
		end

		if item.tt_desc then
			self.desc.text = item.tt_desc
		end
	elseif item.action == "tw_sell" then
		self.title.text = _("Sell Tower")

		local refund = game_gui.game.store.wave_group_number == 0 and entity.tower.spent or km.round(entity.tower.refund_factor * entity.tower.spent)

		self.desc.text = string.format(_("Sell this tower and get a %s GP refund."), refund)
	else
		self.hidden = true
	end

	if not self.hidden then
		local no_bottom_label = self.damage_label.hidden and self.health_label.hidden and self.armor_label.hidden and self.cooldown_label.hidden and self.phrase_label.hidden

		self.title:do_fit_lines()
		self.desc:do_fit_lines()
		self.damage_label:do_fit_lines()

		local width, lines = self.desc:get_wrap_lines()

		if self.title:get_font_height() + self.desc:get_font_height() * lines + (no_bottom_label and 0 or self.damage_label:get_font_height()) < 73 then
			self:set_image("tooltip_bg_small")
		else
			self:set_image("tooltip_bg_standard")
		end

		for _, v in pairs({
			self.damage_label,
			self.cooldown_label,
			self.health_label,
			self.armor_label
		}) do
			v.pos.y = self.size.y - 26
		end

		self.phrase_label.pos.y = self.size.y - 22
	end

	self:reposition(entity)
end

function TowerMenuTooltip:reposition(entity)
	if not entity or not entity.pos then
		return
	end

	local zoom = game_gui.game.camera and game_gui.game.camera.zoom or 1
	local display_w, display_h = self.size.x * zoom, self.size.y * zoom
	local oy = 126 * zoom
	local ex, ey = game_gui:g2u(V.v(entity.pos.x, entity.pos.y), true)

	self.scale.x, self.scale.y = zoom, zoom
	self.pos.x = ex - math.floor(display_w / 2)
	self.pos.y = ey - display_h - oy

	if self.pos.y < display_h / 3 then
		self.pos.y = ey + 76 * zoom
	end
end

function TowerMenuTooltip:hide()
	self.hidden = true
	self.entity = nil
end

function TowerMenuTooltip:update(dt)
	TowerMenuTooltip.super.update(self, dt)

	if not self.hidden and self.entity then
		self:reposition(self.entity)
	end
end

TowerMenuButton = class("TowerMenuButton", KView)

function TowerMenuButton:enable()
	self.click_disabled = false

	self.button:set_image(self.item.image)
	if self.item.disabled_tint then
		self.button.colors.tint = nil
	end

	if self.price_tag then
		self.price_tag:set_image("price_tag")

		self.price_tag.colors.text = {
			255,
			224,
			0
		}
	end
end

function TowerMenuButton:disable()
	self.click_disabled = true

	if self.item.action ~= "tw_change_mode" and self.item.action ~= "tw_swap_mode" then
		self.button:set_image(self.item.image .. "_disabled")
		if self.item.disabled_tint then
			self.button.colors.tint = {125, 125, 125, 255}
		end

		if self.price_tag then
			self.price_tag:set_image("price_tag_disabled")

			self.price_tag.colors.text = {
				156,
				146,
				132
			}
		end
	end
end

function TowerMenuButton:initialize(item, entity)
	TowerMenuButton.super.initialize(self)
	self.item = item
	self.item_image = item.image
	self.entity = entity

	local button = KImageView:new(item.image)
	if item.icon_scale then
		button.image_scale = item.icon_scale
		button:set_image(item.image)
	end
	button.pos = v(0, 0)
	button.propagate_on_click = true
	button.disabled_tint_color = nil
	self.button = button
	self:add_child(button)

	local halo_text = item.halo
	local image_frame
	if item.action == "tw_change_mode" or item.action == "tw_swap_mode" then
		image_frame = KImageView:new("ingame_ui_action_icon_frame")
		image_frame.pos = V.v(math.floor(-0.5 * (image_frame.size.x - button.size.x)), math.floor(-0.5 * (image_frame.size.y - button.size.y)))
		image_frame.propagate_on_click = true
		image_frame.disabled_tint_color = nil
		halo_text = "ingame_ui_action_icon_frame_hover"
	end
	local halo = KImageView:new(halo_text)
	if item.icon_scale then
		halo.scale = v(item.icon_scale, item.icon_scale)
	end
	halo.pos = v(math.floor(-0.5 * (halo.size.x * (item.icon_scale or 1) - button.size.x)), math.floor(-0.5 * (halo.size.y * (item.icon_scale or 1) - button.size.y)))
	halo.propagate_on_click = true
	halo.hidden = true
	self.halo = halo
	self:add_child(halo, 1)

	if image_frame then
		image_frame.hidden = true
		self.image_frame = image_frame
		self:add_child(self.image_frame)
	end
	

	if table.contains({
		"tw_upgrade",
		"tw_buy_soldier",
		"tw_buy_attack",
		"tw_repair",
		"tw_custom_no_close",
		"tw_custom_close",
		"tw_page",
	}, item.action) then
		local bo = KImageView:new("main_icons_over")
		if item.icon_scale then
			bo.scale = v(item.icon_scale, item.icon_scale)
		end
		bo.pos = v(math.floor(-0.5 * (bo.size.x * (item.icon_scale or 1) - button.size.x)), math.floor(-0.5 * (bo.size.y * (item.icon_scale or 1) - button.size.y)))
		bo.propagate_on_click = true
		bo.disabled_tint_color = nil
		self:add_child(bo)
	end

	if item.action == "upgrade_power" then
		local bg = KImageView:new("special_icons_bg")
		bg.pos = v(math.floor(-0.5 * (bg.size.x - button.size.x)), math.floor(-0.5 * (bg.size.y - button.size.y)))
		bg.propagate_on_click = true
		self:add_child(bg, 1)

		local power = entity.powers[item.action_arg]
		if not item.no_upgrade_lights then
			self.power_buttons = {}
			for i = 1, power.max_level do
				local pv
				if i > power.level then
					pv = KImageView:new("power_rank_0002")
				else
					pv = KImageView:new("power_rank_0001")
				end
				pv.pos = V.vclone(data.tower_menu_power_places[i])
				pv.pos.x, pv.pos.y = pv.pos.x - pv.size.x / 2, pv.pos.y - pv.size.y / 2
				pv.disabled_tint_color = nil
				pv.propagate_on_click = true
				button:add_child(pv)
				table.insert(self.power_buttons, pv)
			end
		end

		if power.level >= power.max_level then
			self:remove_child(self.halo)
			self.halo = nil
		end
	end

	local price_tag

	if item.action == "tw_upgrade" then
		local nt = E:get_template(item.action_arg)

		if nt.build_name then
			nt = E:get_template(nt.build_name)
		end

		local price = nt.tower.price

		if entity.tower.upgrade_price_multiplier then
			price = math.ceil(price * entity.tower.upgrade_price_multiplier)
			price = math.floor(price / 10) * 10
		end

		price_tag = tostring(price)
	elseif item.action == "tw_unblock" then
		price_tag = tostring(entity.tower_holder.unblock_price)
	elseif item.action == "upgrade_power" then
		local power = entity.powers[item.action_arg]
		local price = power.level == 0 and power.price_base or power.price_inc
		if power.level == power.max_level then
			-- block empty
		end
		price_tag = tostring(price)
	elseif item.action == "tw_buy_soldier" then
		local nt = E:get_template(item.action_arg)

		price_tag = tostring(nt.unit.price)
	elseif item.action == "tw_buy_attack" then
		price_tag = ""
	elseif item.action == "tw_repair" then
		price_tag = not entity.repair.active and entity.repair.cost or nil
	elseif item.action == "tw_custom_no_close" or item.action == "tw_custom_close" then
		price_tag = not entity.tower_action.active and tostring(entity.tower_action.cost) or nil
	end

	if price_tag then
		local pt = GGLabel:new(nil, "price_tag")
		if item.icon_scale then
			pt.image_scale = item.icon_scale
			pt:set_image("price_tag")
			pt.text_size = V.vclone(pt.size)
		end

		pt.id = "price_tag"
		pt.pos = V.v(button.size.x / 2 - pt.size.x / 2, button.size.y - (item.icon_scale and 16 or 11))
		pt.text_align = "center"
		pt.text_offset.y = item.icon_scale and 1 or CJK(5, 2, 7, 3)
		pt.font_name = "body"
		pt.font_size = item.icon_scale and 9 or 11
		pt.colors.text = {
			255,
			224,
			0
		}
		pt.disabled_tint_color = nil
		pt.propagate_on_click = true
		pt.text = price_tag
		self.price_tag = pt

		self:add_child(pt)
	end

	local ufx = KImageView:new("effect_powerbuy_0001")
	if item.icon_scale then
		ufx.scale = v(item.icon_scale, item.icon_scale)
	end

	ufx.animation = {
		to = 23,
		prefix = "effect_powerbuy",
		from = 1
	}
	ufx.pos = v(4, -4)
	ufx.hidden = true
	ufx.propagate_on_click = true
	self.ufx = ufx

	self:add_child(ufx)

	self.size = V.vclone(button.size)

end

function TowerMenuButton:update(dt)
	TowerMenuButton.super.update(self, dt)

	local store = game_gui.game.store
	local item, entity = self.item, self.entity

	if item.dynamic_rally then
		if entity.tower and entity.tower.show_rally then
			self.hidden = false
		else
			self.hidden = true
			return
		end
	end

	if item.action == "tw_point" and entity and entity.user_selection then
		if not entity.user_selection.allowed then
			self:disable()
		else
			self:enable()
		end
	elseif entity and item.action == "tw_upgrade" then

		local nt = E:get_template(item.action_arg)

		if nt.build_name then
			nt = E:get_template(nt.build_name)
		end

		local price = nt.tower.price
		if entity.tower.upgrade_price_multiplier then
			price = math.ceil(price * entity.tower.upgrade_price_multiplier)
			price = math.floor(price / 10) * 10
		end

		if price > store.player_gold then
			self:disable()
		else
			self:enable()
		end
	elseif entity and item.action == "tw_unblock" then

		if entity.tower_holder.unblock_price > store.player_gold then
			self:disable()
		else
			self:enable()
		end
	elseif entity and item.action == "upgrade_power" then
		local power = entity.powers[item.action_arg]
		local price = power.level == 0 and power.price_base or power.price_inc
		local is_max_level = power.level >= power.max_level

		if not is_max_level and price > store.player_gold then
			self:disable()
		else
			self:enable()
			self.click_disabled = is_max_level
		end

		local pt = self:get_child_by_id("price_tag")

		if pt then
			pt.text = tostring(price)
			pt.hidden = is_max_level
		end
	elseif entity and item.action == "tw_buy_soldier" then
		local nt = E:get_template(item.action_arg)
		local price = nt.unit.price

		if entity.template_name == "tower_stage_18_elven_barrack" then
			if price > store.player_gold or entity.barrack.current_soldiers == 3 then 
				self:disable()
			else
				self:enable()
			end
		else
			if price > store.player_gold or #entity.barrack.soldiers >= entity.barrack.max_soldiers then
				self:disable()
			else
				self:enable()
			end
		end

		local pt = self:get_child_by_id("price_tag")

		if pt then
			pt.text = tostring(price)
			pt.hidden = false
		end
	elseif entity and item.action == "tw_buy_attack" then
		local price = entity.attacks.list[item.action_arg].price

		if price > store.player_gold then
			self:disable()
		else
			self:enable()
		end

		local pt = self:get_child_by_id("price_tag")

		if pt then
			pt.text = tostring(price)
			pt.hidden = false
		end
	--elseif entity and item.action == "tw_free_action" then
	--	if not entity.user_selection.allowed then
	--		self:disable()
	--	else
	--		self:enable()
	--	end
	elseif entity and item.action == "tw_free_action" then
		local usa = entity.user_selection and entity.user_selection.actions

		if usa and usa.tw_free_action then
			if not usa.tw_free_action.allowed then
				self:disable()
			else
				self:enable()
			end
		elseif not entity.user_selection.allowed then
			self:disable()
		else
			self:enable()
		end
	elseif entity and (item.action == "tw_custom_no_close" or item.action == "tw_custom_close") then
		local action = entity.tower_action

		if action.active or action.cost > store.player_gold then
			self:disable()
		else
			self:enable()
		end

		local pt = self:get_child_by_id("price_tag")

		if pt then
			pt.text = tostring(action.cost)
			pt.hidden = action.active
		end
	elseif entity and item.action == "tw_change_mode" then
		local current_mode = entity.tower_upgrade_persistent_data.current_mode

		if item.image_modes and item.image_modes[current_mode + 1] then
			self:change_image(item.image_modes[current_mode + 1])
		elseif current_mode == 0 then
			if self.item_image == "quickmenu_action_icons_0001" then
				self:change_image("quickmenu_action_icons_0002")
			elseif self.item_image == "quickmenu_action_icons_0006" then
				self:change_image("quickmenu_action_icons_0005")
			elseif self.item_image == "quickmenu_action_icons_0007" then
				self:change_image("quickmenu_action_icons_0008")
			end
		elseif self.item_image == "quickmenu_action_icons_0002" then
			self:change_image("quickmenu_action_icons_0001")
		elseif self.item_image == "quickmenu_action_icons_0005" then
			self:change_image("quickmenu_action_icons_0006")
		elseif self.item_image == "quickmenu_action_icons_0008" then
			self:change_image("quickmenu_action_icons_0007")
		elseif self.item_image == "quick_icons_select_power_0402" and entity.tower_upgrade_persistent_data.current_mode == 1 then 
			self:change_image("quick_icons_select_power_0401")
			self.image_frame.hidden = true
		elseif self.item_image == "quick_icons_select_power_0401" and entity.tower_upgrade_persistent_data.current_mode == 2 then
			self:change_image("quick_icons_select_power_0402")
			self.image_frame.hidden = true
		elseif self.item_image == "quick_icons_select_power_swamp_monster_0001" and entity.tower_upgrade_persistent_data.current_mode == 0 then 
			self:change_image("quick_icons_select_power_swamp_monster_0002")
			self.image_frame.hidden = true
		elseif self.item_image == "quick_icons_select_power_swamp_monster_0002" and entity.tower_upgrade_persistent_data.current_mode == 1 then
			self:change_image("quick_icons_select_power_swamp_monster_0001")
			self.image_frame.hidden = true
		end

	elseif entity and item.action == "tw_repair" then
		local repair = entity.repair

		if not repair then
			self:disable()
			self.click_disabled = true

			local pt = self:get_child_by_id("price_tag")

			if pt then
				pt.hidden = true
			end

			return
		end

		local price = repair.cost

		if price > store.player_gold then
			self:disable()
		else
			self:enable()

			self.click_disabled = repair.active
		end

		local pt = self:get_child_by_id("price_tag")

		if pt then
			pt.text = tostring(price)
			pt.hidden = false
		end
	end
end

function TowerMenuButton:change_image(img)
	self.item_image = img
	self.button:set_image(img)
	
end

--[[function TowerMenuButton:on_down(button, x, y)
	GGButton.static.down_bounce_ani(self)
end

function TowerMenuButton:on_up(button, x, y)
	GGButton.static.up_bounce_ani(self)
end]]

function TowerMenuButton:on_enter()
	if not self.parent or self.parent.tweening then
		return
	end

	if self.halo then
		self.halo.hidden = false
	end

	local item, entity = self.item, self.entity

	if item.action == "tw_upgrade" then
		local nt
		if item.preview then
			local tb = E:get_template(item.action_arg)
			nt = E:get_template(tb.build_name)
		else
			nt = E:get_template(item.action_arg)
		end

		local ux, uy = game_gui:g2u(V.v(V.add(entity.pos.x, entity.pos.y, entity.tower.range_offset.x, entity.tower.range_offset.y)), snap)

		if nt and nt.attacks and nt.attacks.range then
			local new_range = nt.attacks.range

			if entity.template_name ~= "tower_crossbow" then
				local mods = table.filter(game_gui.game.store.entities, function(k, m)
					return m.template_name == "mod_crossbow_eagle" and m.modifier.target_id == entity.id
				end)

				if #mods == 1 and mods[1].modifier then
					local m = mods[1]

					new_range = new_range * (m.range_factor + m.modifier.level * m.range_factor_inc)
				end
				log.debug("range:%s new_range:%s eagle mods: %s", nt.attacks.range, new_range, #mods)
			end
			game_gui:show_tower_range_upgrade(ux, uy, new_range)
		elseif nt.barrack and nt.barrack.rally_range then
			game_gui:show_rally_range(ux, uy, nt.barrack.rally_range)
		end
	elseif item.action == "upgrade_power" and entity.template_name == "tower_crossbow" and item.action_arg == "eagle" and entity.powers.eagle.level < 3 then
		local new_range = entity.attacks.range
		local mods = table.filter(game_gui.game.store.entities, function(k, m)
			return m.template_name == "mod_crossbow_eagle" and m.modifier.target_id == entity.id
		end)

		if #mods == 1 and mods[1].modifier and mods[1].modifier.level > entity.powers.eagle.level then
			-- block empty
		else
			local m = E:get_template("mod_crossbow_eagle")
			local factor = entity.powers.eagle.level < 1 and m.range_factor + m.range_factor_inc or 1 + m.range_factor_inc
			new_range = new_range * factor
		end
		local ux, uy = game_gui:g2u(V.v(V.add(entity.pos.x, entity.pos.y, entity.tower.range_offset.x, entity.tower.range_offset.y)))
		game_gui:show_tower_range_upgrade(ux, uy, new_range)
	end

	if item.preview then
		local preview_item = entity.tower_holder.preview_items[item.preview]
		if preview_item then
			entity.render.sprites[2].name = preview_item.name
			entity.render.sprites[2].offset = V.vclone(preview_item.offset)
			entity.render.sprites[2].alpha = preview_item.alpha or entity.tower_holder.default_alpha
			entity.render.sprites[2].hidden = false
		end
	end

	game_gui.towertooltip:show(entity, item)

	if entity.ui then
		entity.ui.hover_active = true
		entity.ui.args = item.action_arg
	end
end

function TowerMenuButton:on_exit()
	-- A first Android tap intentionally keeps the desktop-style information card
	-- open.  It is cleared when another menu item is armed or the menu closes.
	if IS_ANDROID and self.android_confirm_armed then
		return
	end

	if self.halo then
		self.halo.hidden = true
	end

	game_gui:hide_tower_range_upgrade()
	game_gui.towertooltip:hide()
	if game_gui.mode ~= GUI_MODE_RALLY_TOWER then
		game_gui:hide_rally_range()
	end

	local item, entity = self.item, self.entity
	if item.preview then
		entity.render.sprites[2].hidden = true
	end

	if entity.ui then
		entity.ui.hover_active = nil
		entity.ui.args = nil
	end
end

function TowerMenuButton:on_click()
	if not self.parent or self.parent.tweening then
		return
	end
	if self.click_disabled then return end

	local item, entity = self.item, self.entity
	if item.action == "tw_upgrade" and (item.action_arg == "Goldfinger" or item.action_arg == "g5_special_buy" or item.action_arg == "tower_hero_buy_e") then
		require("director"):load_deferred_cheat_textures(game_gui.game)
	end

	-- Touch screens have no hover state.  For actions that spend gold on a tower,
	-- use the first tap as the information/preview tap and the second tap as the
	-- actual purchase.  Desktop input retains the original single-click behavior.
	local tower_type = entity.tower and entity.tower.type or ""
	local is_hero_purchase = item.action == "tw_buy_attack" and string.match(tower_type, "^hero_buy") ~= nil

	if IS_ANDROID and (item.action == "tw_upgrade" or item.action == "upgrade_power" or is_hero_purchase) then
		if not self.android_confirm_armed then
			for _, child in ipairs(self.parent.children or {}) do
				if child ~= self and child.android_confirm_armed then
					child.android_confirm_armed = false
					child:on_exit()
				end
			end

			self.android_confirm_armed = true
			self:on_enter()

			return false
		end

		self.android_confirm_armed = false
	end

	self:disable()

	local inhibit_sounds = false
	local new_mode
	if item.action == "tw_rally" then
		local e = game_gui.selected_entity
		game_gui:set_mode(GUI_MODE_RALLY_TOWER)
		local ux, uy = game_gui:g2u(V.v(V.add(e.pos.x, e.pos.y, e.tower.range_offset.x, e.tower.range_offset.y)))
		game_gui:show_rally_range(ux, uy, e.barrack.rally_range)
		self.parent:hide()
	elseif item.action == "tw_change_mode" then
		local e = game_gui.selected_entity
		if e.tower then
			e.change_mode = true
			game_gui:deselect_entity()
			new_mode = e.tower_upgrade_persistent_data.current_mode == 0 and 1 or 0
		end
		self.parent:hide()
	elseif item.action == "tw_free_action" then
		local e = game_gui.selected_entity
		if e.user_selection then
			e.user_selection.in_progress = true
			e.user_selection.arg = item.action_arg
			e.user_selection.new_pos = nil
		end

		self.parent:hide()
	elseif item.action == "tw_swap_mode" then
		local e = game_gui.selected_entity
		if e.tower then
			e.change_mode = true
			game_gui:deselect_entity()
		end

		game_gui.swap_entity = e
		game_gui:set_mode(GUI_MODE_SWAP_TOWER)
		game_gui:show_ghost_hover()

		self.parent:hide()
	elseif item.action == "tw_repair" then
		local e = game_gui.selected_entity
		if e.user_selection then
			e.user_selection.in_progress = true
		end

		--game_gui.c_deselect()
		self.parent:hide()
	elseif item.action == "tw_custom_no_close" or item.action == "tw_custom_close" then
		local e = game_gui.selected_entity

		if e.user_selection then
			e.user_selection.in_progress = true
			e.user_selection.arg = item.action_arg ~= "" and item.action_arg or nil
		end

		if item.action == "tw_custom_close" then
			game_gui:deselect_entity()
		else
			game_gui.towertooltip:show(e, item)
		end
	elseif item.action == "tw_point" then
		local e = game_gui.selected_entity
		if e.user_selection then
			e.user_selection.in_progress = true
			e.user_selection.new_pos = nil
		end
		game_gui:set_mode(GUI_MODE_SELECT_POINT)
		self.parent:hide()
	elseif item.action == "tw_add_holder" then
		self.parent:hide()
		game_gui:deselect_entity()
		game_gui:set_mode(GUI_MODE_FREE_HOLDER)
	elseif item.action == "tw_upgrade" or item.action == "tw_unblock" then

		entity.tower.upgrade_to = item.action_arg
		signal.emit("tower-built")
		game_gui:deselect_entity()
	elseif item.action == "upgrade_power" then
		local power = entity.powers[item.action_arg]

		if power.level < power.max_level then
			power.level = power.level + 1
			power.changed = true

			if not item.no_upgrade_lights then
				for i, pv in ipairs(self.power_buttons) do
					if i == power.level then
						pv:set_image("power_rank_0001")
					end
				end

				self.ufx.hidden = false
				self.ufx.ts = 0
			end

			local store = game_gui.game.store
			local spent
			if power.level == 1 then
				spent = power.price_base
			else
				spent = power.price_inc
			end
			store.player_gold = store.player_gold - spent
			entity.tower.spent = entity.tower.spent + spent
			game_gui.towertooltip:show(entity, item)
			if power.level >= power.max_level and self.halo then
				self:remove_child(self.halo)
				self.halo = nil
			end
			if power.show_rally then
				entity.tower.show_rally = true
			end
			signal.emit("tower-power-upgraded", entity, power)
		else
			inhibit_sounds = true
		end
	elseif item.action == "tw_sell" then
		entity.tower.sell = true
		game_gui:deselect_entity()
	elseif item.action == "tw_buy_soldier" then
		entity.barrack.unit_bought = item.action_arg
		game_gui:deselect_entity()
	elseif item.action == "tw_buy_attack" then
		local e = game_gui.selected_entity

		if e.user_selection then
			if e.user_selection.ignore_point then
				e.user_selection.arg = item.action_arg
				game_gui:deselect_entity()
			else
				e.user_selection.in_progress = true
				e.user_selection.arg = item.action_arg
				e.user_selection.new_pos = nil
				game_gui:set_mode(GUI_MODE_SELECT_POINT)
				self.parent:hide()
			end
		else
			game_gui:deselect_entity()
		end
---重生		
	elseif item.action == "tw_page" then
		entity.tower.page = item.action_arg

		self.parent:show()		
	end

	if item.sounds and not inhibit_sounds then
		if item.action == "tw_change_mode" and #item.sounds > 1 and new_mode then
			S:queue(item.sounds[new_mode + 1])
		else
			for _, sid in pairs(item.sounds) do
				S:queue(sid)
			end
		end
	end

end

IncomingTooltip = class("IncomingTooltip", KView)

function IncomingTooltip:initialize()
	IncomingTooltip.super.initialize(self, V.v(200, 90))

	self.colors.background = {
		21,
		17,
		13,
		220
	}

	local aw, ah = 18, 24
	local arrow = KView:new(V.v(aw, ah))

	arrow.shape = {
		name = "polygon",
		args = {
			"fill",
			{
				0,
				ah,
				aw,
				ah / 2,
				aw / 2,
				ah / 2,
				aw / 2,
				0
			}
		}
	}
	arrow.colors.background = self.colors.background
	arrow.anchor = V.v(aw / 2, ah / 2)

	self:add_child(arrow)

	local title = GGLabel:new(V.v(180, 30))

	title.text = _("INCOMING WAVE")
	title.font_name = "h"
	title.font_size = 14
	title.text_align = "center"
	title.colors.text = {
		255,
		115,
		55,
		255
	}

	local report = GGLabel:new(V.v(180, 90))

	report.font_name = "body"
	report.font_size = 12
	report.text_align = "center"
	report.colors.text = {
		255,
		245,
		210,
		255
	}
	title.pos.x, title.pos.y = 0, 10
	report.pos.x, report.pos.y = 0, 30

	self:add_child(title)
	self:add_child(report)

	self.arrow = arrow
	self.title = title
	self.report = report
end

function IncomingTooltip:set_report(text)
	self.report.text = text

	local title_w = self.title:get_text_width(self.title.text)
	local report_w = self.report:get_text_width(text)
	local w = math.max(title_w, report_w) + 40

	self.report.size.x = w
	self.title.size.x = w
	self.size.x = w

	local width, lines = self.report:get_wrap_lines()
	local height = lines * self.report:get_font_height()

	self.size.y = 40 + height + 10
end

function IncomingTooltip:show(x, y, r, report)
	self:set_report(report)
	self:reposition(x, y, r)

	if self.timer then
		timer:cancel(self.timer)
	end

	self.hidden = false
	self.alpha = 0
	self.timer = timer:tween(0.25, self, {
		alpha = 1
	}, "out-quad")
end

function IncomingTooltip:reposition(x, y, r)
	local arrow = self.arrow
	local zoom = game_gui.game.camera and game_gui.game.camera.zoom or 1
	local display_w, display_h = self.size.x * zoom, self.size.y * zoom
	local a_w = arrow.anchor.x * zoom
	local a_h = (arrow.size.y - arrow.anchor.y) * zoom
	local a = km.unroll(r)
	local offset = 15 * zoom

	self.scale.x, self.scale.y = zoom, zoom

	if x > 1.5 * display_w then
		arrow.pos.x = self.size.x
		arrow.scale.x = -1
		self.pos.x = x - display_w - a_w - offset
	else
		arrow.pos.x = 0
		arrow.scale.x = 1
		self.pos.x = x + a_w + offset
	end

	if y < 3 * display_h then
		arrow.pos.y = 0
		arrow.scale.y = -1
		self.pos.y = y + a_h + offset
	else
		arrow.pos.y = self.size.y
		arrow.scale.y = 1
		self.pos.y = y - display_h - a_h - offset
	end

	self.pos.x, self.pos.y = V.csnap(self.pos.x, self.pos.y)
end

function IncomingTooltip:hide()
	if self.timer then
		timer:cancel(self.timer)
	end

	self.timer = timer:tween(0.25, self, {
		alpha = 0
	}, "out-quad", function()
		self.hidden = true
	end)
end

function IncomingTooltip:update(dt)
	if not self.hidden and game_gui.mode ~= GUI_MODE_IDLE and game_gui.mode ~= GUI_MODE_WAVE_FLAG then
		self.hidden = true
	end
end

WaveFlag = class("WaveFlag", KView)

function WaveFlag:initialize(flying, duration, report)
	WaveFlag.super.initialize(self)

	self.duration = duration
	self.report = report
	self.start_game_ts = game_gui.game.store.ts
	self.ts = 0
	self.pulse_animation = true

	local halo = KImageView:new("nextwaveTimer_glow_0001")
	local bg_circle = KImageView:new("nextwaveTimer_Full")
	local circle = KImageView:new("nextwaveTimer_0001")
	local icon = KImageView:new(flying and "nextwaveTimer_0003" or "nextwaveTimer_0002")
	local pointer = KImageView:new("nextwaveTimer_0020")

	self.size.x, self.size.y = halo.size.x, halo.size.y
	self.anchor.x, self.anchor.y = self.size.x / 2, self.size.y / 2

	local hrs = 0.25

	self.hit_rect = V.r(hrs * self.size.x, hrs * self.size.y, (1 - 2 * hrs) * self.size.x, (1 - 2 * hrs) * self.size.y)

	for _, v in pairs({
		halo,
		bg_circle,
		circle,
		icon
	}) do
		v.anchor.x, v.anchor.y = v.size.x / 2, v.size.y / 2
	end

	pointer.anchor.x, pointer.anchor.y = pointer.size.x / 2, pointer.size.y

	for _, v in pairs({
		halo,
		bg_circle,
		circle,
		icon,
		pointer
	}) do
		v.pos.x, v.pos.y = self.size.x / 2, self.size.y / 2
		v.propagate_on_click = true

		self:add_child(v)
	end

	halo.hidden = true
	pointer.r = -math.pi / 2
	bg_circle.phase = 0
	bg_circle.clip = true

	function bg_circle.clip_fn()
		local start_angle = 3 * math.pi / 2
		local stop_angle = 7 * math.pi / 2 - bg_circle.phase * 2 * math.pi

		G.arc("fill", bg_circle.size.x / 2, bg_circle.size.y / 2, bg_circle.size.x / 2, start_angle, stop_angle, 12)
	end

	self.halo = halo
	self.bg_circle = bg_circle
	self.pointer = pointer
end

function WaveFlag:on_click()
	log.debug(">>> sending next wave...")

	if IS_ANDROID and not self.android_confirm_armed then
		for _, flag in ipairs(game_gui.wave_flags or {}) do
			if flag ~= self and flag.android_confirm_armed then
				flag.android_confirm_armed = false
				flag:on_exit()
			end
		end

		self.android_confirm_armed = true
		self:on_enter()

		return false
	end

	self.android_confirm_armed = false
	self:disable()

	self.clicked = true
	game_gui.game.store.send_next_wave = true
end

function WaveFlag:on_enter()
	self.halo.hidden = false

	game_gui.incoming_tooltip.owner_flag = self
	game_gui.incoming_tooltip:show(self.pos.x, self.pos.y, self.pointer.r + math.pi / 2, self.report)
--来自重生版路径显示
	if self.marching_ants then
		self.marching_ants.done = true
		self.marching_ants = nil
	end

	self.marching_ants = E:create_entity("path_marching_ants_controller")
	self.marching_ants.pi = self.path_index

	game_gui.game.simulation:insert_entity(self.marching_ants)	
end

function WaveFlag:on_exit()
	if IS_ANDROID and self.android_confirm_armed then
		return
	end

	self.halo.hidden = true

	if game_gui.incoming_tooltip.owner_flag == self then
		game_gui.incoming_tooltip.owner_flag = nil
	end

	game_gui.incoming_tooltip:hide()
--来自重生版路径显示
	if self.marching_ants then
		self.marching_ants.done = true
		self.marching_ants = nil
	end	
end

function WaveFlag:hide()
	self.pulse_animation = false
	self.android_confirm_armed = false

	if self.marching_ants then
		self.marching_ants.done = true
		self.marching_ants = nil
	end

	if game_gui.incoming_tooltip.owner_flag == self then
		game_gui.incoming_tooltip.owner_flag = nil
		game_gui.incoming_tooltip:hide()
	end

	self:disable()

	if not self.hide_timer then
		self.hide_timer = timer:tween(0.5, self, {
			alpha = 0,
			scale = {
				x = 1.5,
				y = 1.5
			}
		}, "out-quad", function()
			self.hidden = true

			self:remove_from_parent()
		end)
	end
end

function WaveFlag:update(dt)
	WaveFlag.super.update(self, dt)

	local camera_zoom = game_gui.game.camera and game_gui.game.camera.zoom or 1

	if self.world_pos then
		local wfx, wfy = game_gui:g2u(self.world_pos)
		local vf = V.v(V.rotate(-self.world_r, 1, 0))

		self.pos = game_gui:find_flag_position(V.v(wfx, wfy), vf, 50 * camera_zoom, self.world_len and self.world_len * camera_zoom or nil)

		if game_gui.incoming_tooltip.owner_flag == self and not game_gui.incoming_tooltip.hidden then
			game_gui.incoming_tooltip:reposition(self.pos.x, self.pos.y, self.pointer.r + math.pi / 2)
		end
	end

	if self.pulse_animation then
		local scale = camera_zoom * (0.85 + 0.15 * (0.5 * math.sin(2 * math.pi * self.ts * 1.25) + 1))

		self.scale.x, self.scale.y = scale, scale
	end

	if self.duration and self.duration > 0 then
		self.bg_circle.phase = km.clamp(0, 1, (self.duration - (game_gui.game.store.ts - self.start_game_ts)) / self.duration)
	end

	if not self.clicked and not self.hide_timer then
		if game_gui.mode == GUI_MODE_IDLE or game_gui.mode == GUI_MODE_WAVE_FLAG then
			self:enable()

			self.alpha = 1
		else
			self:disable(false)

			self.alpha = 0.2
		end
	end
end

local function getPrivateVar()
	return game_gui.heroes
end

game_gui.getPrivateVar = getPrivateVar

require("criket_patch")(game_gui)


return game_gui

