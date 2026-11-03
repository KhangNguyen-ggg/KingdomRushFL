-- chunkname: @./all/systems.lua

local log = require("klua.log"):new("systems")
local log_xp = log.xp or log:new("xp")
local log_hp = log.hp or log:new("hp")
local km = require("klua.macros")
local signal = require("hump.signal")

require("klua.table")
require("klua.dump")

local A = require("animation_db")
local AC = require("achievements")
local DI = require("difficulty")
local I = require("klove.image_db")
local SH = require("klove.shader_db")
local E = require("entity_db")
local P = require("path_db")
local F = require("klove.font_db")
local GR = require("grid_db")
local GS = require("game_settings")
local S = require("sound_db")
local SSO = require("klove.sso")
local UP = require("upgrades")
local W = require("wave_db")
local U = require("utils")
local ULH = require("utils_lh")
local SU = require("script_utils")
local LU = require("level_utils")
local LU6 = require("level_utils_6")
local V = require("klua.vector")
local storage = require("storage")
local enemy_enhance = require("enemy_enhance")
local generation_upgrades = require("generation_upgrades")
local power_selection = require("power_selection")
local earnings_stats = require("earnings_stats")
local EXO = require("exoskeleton")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local random = math.random
local ceil = math.ceil
local floor = math.floor

require("constants")

local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

local function fts(v)
	return v / FPS
end

local EARLY_WAVE_REWARD_MAX_SECONDS = 100

local function combat_stats_ensure(store)
	if not store.combat_stats then
		store.combat_stats = {
			by_source = {},
			source_meta = {},
			fallback_rows = {},
			retired_source_ids = {{}, {}, {}, {}},
			total_damage = 0,
			total_kills = 0
		}
	end

	local stats = store.combat_stats

	stats.source_meta = stats.source_meta or {}
	stats.fallback_rows = stats.fallback_rows or {}
	stats.retired_source_ids = stats.retired_source_ids or {{}, {}, {}, {}}

	return stats
end

local COMBAT_STATS_IGNORED = {}

local function combat_stats_parent_id(value)
	if type(value) == "table" then
		return value.id
	end

	return value
end

local function combat_stats_source_parent_id(entity)
	if not entity then
		return nil
	end

	if entity.combat_stats_source_id then
		return combat_stats_parent_id(entity.combat_stats_source_id)
	end

	if entity.soldier and entity.soldier.tower_id then
		return combat_stats_parent_id(entity.soldier.tower_id)
	end

	if entity.reinforcement and not entity.source_id and not entity.owner_id and not entity.owner and not entity.source then
		return nil
	end

	if entity.tower_ref then
		return combat_stats_parent_id(entity.tower_ref)
	end

	if entity.bullet and entity.bullet.source_id then
		return combat_stats_parent_id(entity.bullet.source_id)
	end

	if entity.modifier and entity.modifier.source_id then
		return combat_stats_parent_id(entity.modifier.source_id)
	end

	if entity.aura and entity.aura.source_id then
		return combat_stats_parent_id(entity.aura.source_id)
	end

	if entity.spell and entity.spell.source_id then
		return combat_stats_parent_id(entity.spell.source_id)
	end

	if entity.relic and entity.relic.owner_id then
		return combat_stats_parent_id(entity.relic.owner_id)
	end

	if entity.spawner and entity.spawner.owner_id then
		return combat_stats_parent_id(entity.spawner.owner_id)
	end

	if entity.tower_id then
		return combat_stats_parent_id(entity.tower_id)
	end

	if entity.tower_ref then
		return combat_stats_parent_id(entity.tower_ref)
	end

	if entity.source then
		return combat_stats_parent_id(entity.source)
	end

	if entity.owner then
		return combat_stats_parent_id(entity.owner)
	end

	if entity.husk and type(entity.husk) == "table" and entity.husk.id then
		return entity.husk.id
	end

	if entity.xp_dest_id then
		return combat_stats_parent_id(entity.xp_dest_id)
	end

	if entity.source_id then
		return combat_stats_parent_id(entity.source_id)
	end

	if entity.owner_id then
		return combat_stats_parent_id(entity.owner_id)
	end

	return nil
end

local function combat_stats_tower_id(entity)
	if not entity or not entity.tower then
		return nil
	end

	if entity.tower_upgrade_persistent_data then
		entity.tower_upgrade_persistent_data.combat_stats_id = entity.tower_upgrade_persistent_data.combat_stats_id or entity.combat_stats_id or entity.id
		entity.combat_stats_id = entity.tower_upgrade_persistent_data.combat_stats_id

		return entity.tower_upgrade_persistent_data.combat_stats_id
	end

	entity.combat_stats_id = entity.combat_stats_id or entity.id

	return entity.combat_stats_id
end

local function combat_stats_register_entity(store, entity)
	if not entity or not entity.id then
		return
	end

	local stats = combat_stats_ensure(store)
	local key
	local source_id
	local source_kind
	local template_name = entity.template_name

	if entity.hero then
		key = "hero:" .. entity.id
		source_id = entity.id
		source_kind = "hero"
		template_name = template_name or "hero"
	elseif entity.tower then
		local tower_id = combat_stats_tower_id(entity)

		key = "tower:" .. tower_id
		source_id = tower_id
		source_kind = "tower"
		template_name = template_name or "tower"
	else
		return nil
	end

	local row = stats.by_source[key]

	if not row then
		row = {
			source_id = source_id,
			template_name = template_name,
			source_kind = source_kind,
			damage = 0,
			kills = 0
		}
		stats.by_source[key] = row
	elseif template_name ~= "unknown" then
		row.source_id = source_id
		row.template_name = template_name
		row.source_kind = source_kind
	end

	stats.source_meta[entity.id] = row
	entity.combat_stats_source_id = source_id
	entity.combat_stats_source_template = template_name

	return row
end

local function combat_stats_bind_entity(store, entity)
	if not entity or not entity.id then
		return nil
	end

	local stats = combat_stats_ensure(store)
	local known = stats.source_meta[entity.id]

	if known ~= nil then
		return known
	end

	if entity.enemy then
		stats.source_meta[entity.id] = COMBAT_STATS_IGNORED

		return COMBAT_STATS_IGNORED
	end

	if entity.hero or entity.tower then
		return combat_stats_register_entity(store, entity)
	end

	local source_meta
	local parent_id = combat_stats_source_parent_id(entity)

	if parent_id and parent_id ~= entity.id then
		source_meta = stats.source_meta[parent_id]

		if source_meta == nil then
			local parent = store.entities[parent_id]

			if parent then
				source_meta = parent.enemy and COMBAT_STATS_IGNORED or combat_stats_register_entity(store, parent) or parent.template_name
			end
		end
	end

	if source_meta == nil then
		local dominant = store._dominant_entity

		if dominant and dominant ~= entity then
			source_meta = stats.source_meta[dominant.id]

			if source_meta == nil then
				source_meta = dominant.enemy and COMBAT_STATS_IGNORED or combat_stats_register_entity(store, dominant) or dominant.template_name
			end
		end
	end

	if source_meta == nil then
		source_meta = entity.combat_stats_source_template or entity.template_name or "unknown"
	end

	stats.source_meta[entity.id] = source_meta

	if source_meta ~= COMBAT_STATS_IGNORED then
		if type(source_meta) == "table" then
			entity.combat_stats_source_id = source_meta.source_id or entity.combat_stats_source_id
			entity.combat_stats_source_template = source_meta.template_name or entity.combat_stats_source_template
		else
			entity.combat_stats_source_template = source_meta
		end
	end

	return source_meta
end

local function combat_stats_fallback_row(stats, template_name)
	template_name = template_name or "unknown"

	local row = stats.fallback_rows[template_name]

	if row ~= nil then
		return row
	end

	if string.sub(template_name, 1, 6) == "enemy_" then
		stats.fallback_rows[template_name] = COMBAT_STATS_IGNORED

		return COMBAT_STATS_IGNORED
	end

	local key = "template:" .. template_name

	row = stats.by_source[key]

	if not row then
		row = {
			source_id = nil,
			template_name = template_name,
			source_kind = "template",
			damage = 0,
			kills = 0
		}
		stats.by_source[key] = row
	end

	stats.fallback_rows[template_name] = row

	return row
end

local function combat_stats_retire_entity(store, entity)
	local stats = store.combat_stats

	if not stats or not entity or not entity.id or stats.source_meta[entity.id] == nil then
		return
	end

	local buckets = stats.retired_source_ids
	local bucket = buckets[(store.tick or 0) % #buckets + 1]

	bucket[#bucket + 1] = entity.id
end

local function combat_stats_clear_retired(store)
	local stats = store.combat_stats

	if not stats or not stats.retired_source_ids then
		return
	end

	local buckets = stats.retired_source_ids
	local bucket = buckets[((store.tick or 0) + 1) % #buckets + 1]

	for i = 1, #bucket do
		local source_id = bucket[i]
		local source_meta = stats.source_meta[source_id]

		if not store.entities[source_id] and (type(source_meta) ~= "table" or source_meta == COMBAT_STATS_IGNORED or source_meta.source_id ~= source_id) then
			stats.source_meta[source_id] = nil
		end

		bucket[i] = nil
	end
end

local function combat_stats_record(store, damage, target, amount, killed)
	if not target or not target.enemy then
		return
	end

	amount = amount or 0

	if amount <= 0 and not killed then
		return
	end

	local stats = combat_stats_ensure(store)
	local source_id = damage and combat_stats_parent_id(damage.combat_stats_source_id or damage.source_id)
	local row = source_id and stats.source_meta[source_id] or nil

	if row == nil and damage and damage.source_id and damage.source_id ~= source_id then
		row = stats.source_meta[damage.source_id]
	end

	if row == nil and damage and damage.source_id then
		local source = store.entities[damage.source_id]

		if source then
			row = combat_stats_bind_entity(store, source)
		end
	end

	if row == nil and damage and damage.owner then
		local owner_id = combat_stats_parent_id(damage.owner)
		local owner = owner_id and store.entities[owner_id] or type(damage.owner) == "table" and damage.owner or nil

		row = owner_id and stats.source_meta[owner_id] or owner and combat_stats_bind_entity(store, owner) or nil
	end

	if row == nil then
		row = damage and damage.combat_stats_source_template or "unknown"
	end

	if type(row) == "string" then
		row = combat_stats_fallback_row(stats, row)
	end

	if row == COMBAT_STATS_IGNORED then
		return
	end

	row.damage = row.damage + amount
	stats.total_damage = stats.total_damage + amount

	if killed then
		row.kills = row.kills + 1
		stats.total_kills = stats.total_kills + 1
	end
end


-- Low-overhead performance monitor. Samples are accumulated instead of kept in
-- shifting arrays so the monitor does not become a source of frame spikes.
local perf = {
	timers = {},
	system_times = {},
	report_interval = 5,
	frame_total = 0,
	frame_count = 0,
	frame_max = 0
}

function perf.record(name, elapsed)
	local row = perf.system_times[name]

	if not row then
		row = {
			total = 0,
			calls = 0,
			max = 0
		}
		perf.system_times[name] = row
	end

	row.total = row.total + elapsed
	row.calls = row.calls + 1
	row.max = math.max(row.max, elapsed)
end

function perf.start_timer(name)
	perf.timers[name] = love.timer.getTime()
end

function perf.end_timer(name)
	local started = perf.timers[name]

	if not started then
		return 0
	end

	local elapsed = love.timer.getTime() - started
	perf.timers[name] = nil
	perf.record(name, elapsed)

	return elapsed
end

function perf.record_frame(elapsed)
	perf.frame_total = perf.frame_total + elapsed
	perf.frame_count = perf.frame_count + 1
	perf.frame_max = math.max(perf.frame_max, elapsed)
end

function perf.generate_report(store)
	local report = {
		"=== PERFORMANCE REPORT (5s interval) ===",
		os.date("%Y-%m-%d %H:%M:%S")
	}

	if perf.frame_count > 0 and perf.frame_total > 0 then
		table.insert(report, string.format("simulation ticks: %d | avg tick interval: %.3f ms | max: %.3f ms | effective TPS: %.1f", perf.frame_count, perf.frame_total * 1000 / perf.frame_count, perf.frame_max * 1000, perf.frame_count / perf.frame_total))
	end

	local sorted_costs = {}

	for name, data in pairs(perf.system_times) do
		if data.calls > 0 then
			sorted_costs[#sorted_costs + 1] = {
				name = name,
				total = data.total * 1000,
				average = data.total * 1000 / data.calls,
				max = data.max * 1000,
				calls = data.calls
			}
		end
	end

	table.sort(sorted_costs, function(a, b)
		return a.total > b.total
	end)

	table.insert(report, "\nrank | section | total ms | avg ms | max ms | calls")

	for i, item in ipairs(sorted_costs) do
		table.insert(report, string.format("%4d | %s | %.3f | %.4f | %.3f | %d", i, item.name, item.total, item.average, item.max, item.calls))

		if i >= 20 then
			break
		end
	end

	if store then
		table.insert(report, string.format("\nentities: %d | render frames: %d | damage queue: %d | lua memory: %.1f MB", store.entity_count or 0, store.render_frames and #store.render_frames or 0, store.damage_queue and #store.damage_queue or 0, collectgarbage("count") / 1024))
	end

	return table.concat(report, "\n")
end

function perf.save_store_entities(store)
	local entities = {}

	for _, e in pairs(store.entities) do
		local name = e.template_name or "unknown"
		entities[name] = (entities[name] or 0) + 1
	end

	local rows = {}

	for name, count in pairs(entities) do
		rows[#rows + 1] = {
			name = name,
			count = count
		}
	end

	table.sort(rows, function(a, b)
		return a.count > b.count
	end)

	local output = {
		"=== ENTITY COUNTS ===",
		string.format("total: %d", store.entity_count or 0)
	}

	for _, row in ipairs(rows) do
		output[#output + 1] = string.format("%s: %d", row.name, row.count)
	end

	love.filesystem.write("perf_entities_latest.txt", table.concat(output, "\n"))
end

function perf.save_report(store)
	local report = perf.generate_report(store)
	print(report)
	love.filesystem.write("performance_report_latest.txt", report .. "\n")
end

function perf.reset()
	perf.timers = {}
	perf.system_times = {}
	perf.frame_total = 0
	perf.frame_count = 0
	perf.frame_max = 0
end

local sys = {}

sys.level = {}
sys.level.name = "level"

function sys.level:init(store)
	local slot = storage:load_slot(nil, true)

	-- Towers keep the technology tree from their own generation regardless of
	-- the current level's generation, so mixed-generation loadouts need every
	-- legacy tree active at the same time.
	UP:set_all_generation_levels(slot)
	DI:set_level(store.level_difficulty)
	GR:load(store.level_name)
	P:load(store.level_name, store.visible_coords)
	W:load(store.level_name, store.level_mode_6 or store.level_mode, store.current_wave_ss_data)
	A:load()
	E:load()

	local power_dependencies = power_selection.get_selected_dependencies(slot)

	if #power_dependencies.required_exoskeletons > 0 then
		EXO:load(power_dependencies.required_exoskeletons)
	end

	if #power_dependencies.required_exoskeleton_groups > 0 then
		EXO:load_groups(power_dependencies.required_exoskeleton_groups)
	end

	for _, hero_name in ipairs(store.active_hero_names or {slot.heroes.selected}) do
		local groups = GS.heroes_required_exoskeleton_groups and GS.heroes_required_exoskeleton_groups[hero_name]

		if groups then
			EXO:load_groups(groups)
		end
	end
	if slot.liuhui and slot.liuhui.cheat6 and not (store.level_mode == GAME_MODE_CAMPAIGN and store.campaign_variant == CAMPAIGN_VARIANT_NOSTALGIC_CLASSIC) then
		for _, hero in ipairs(require("hero_summon_6")) do
			EXO:load_groups(GS.heroes_required_exoskeleton_groups[hero.name])
		end
	end

	-- Match the selected KR4 branches, including random loadouts.
	EXO:load(store.dove43_required_exoskeletons)

	store.selected_hero = slot.heroes.selected
	store.selected_hero_status = slot.heroes.status[slot.heroes.selected]

	if slot.liuhui and slot.liuhui.rand_tower and slot.liuhui.rand_tower > 0 then
		for _, exoskeletons in pairs(GS.towers_required_exoskeletons) do
			EXO:load(exoskeletons)
		end
		for _, groups in pairs(GS.towers_required_exoskeleton_groups or {}) do
			EXO:load_groups(groups)
		end
	else
		local selected_tower_count = math.min(slot.tower_pick or #slot.towers, #slot.towers)

		for i = 1, selected_tower_count do
			local v = slot.towers[i]

			if GS.towers_required_exoskeletons[v] then
				EXO:load(GS.towers_required_exoskeletons[v])
			end
			if GS.towers_required_exoskeleton_groups and GS.towers_required_exoskeleton_groups[v] then
				EXO:load_groups(GS.towers_required_exoskeleton_groups[v])
			end
		end
	end
	local hero_dianyun = {
		"hero_dianyun",
		"hero_dianyun_health_rain",
		"BKtentacle13Def",
		"ignis_altar_lava_golem",
		"ignis_altar_lvl1",
		"ignis_altar_lvl2",
		"ignis_altar_lvl3",
		"ignis_altar_lvl4",
		"ignis_altar_decal",
		"ignis_altar_decal_lava",
		"hero_beresad_ultimate_particles_animations",
	}
	EXO:load(hero_dianyun)

	local hero_mammoth_exoskeletons = {
		"hero_mammoth",
		"hero_mammoth_ancestral_back",
		"hero_mammoth_ancestral_decal",
		"hero_mammoth_ancestral_force_fear",
		"hero_mammoth_ancestral_front",
		"hero_mammoth_ancestral_hit",
		"hero_mammoth_frency_fire",
		"hero_mammoth_legacy_back_1",
		"hero_mammoth_legacy_back_2",
		"hero_mammoth_legacy_floor",
		"hero_mammoth_legacy_front",
		"hero_mammoth_legacy_middle",
		"hero_mammoth_lone_wolf_decal",
		"hero_mammoth_ultimate_back",
		"hero_mammoth_ultimate_front",
		"hero_mammoth_whirlwind_hit"
	}
	EXO:load(hero_mammoth_exoskeletons)

	local enemy_table_stage3 = {
		"BKtentacle_S15Def",
		"sam_and_frodoDef",
		"StunCircleDef",
		"StunFxDef",
		"StunWhiteDef",
		"skeleton_koopaDef",
		"ChainDef",
		"ElfSlaveDef",
		"Abomination2Def",
		"fireDef",
		"fire_maskDef",
		"templeDef",
		"temple_maskDef",
		"the_witcherDef",
		"bear_woodcutterDef",
	}
	local enemy_table_stage4 = {
		"spawner_mausoleumDef",
		"spawner_mausoleum_lightDef",
	}
	local enemy_table_stage5 = {
		"hydra_unitDef",
		"hydra_unit_transformedDef",
		"hydra_deathDef",
		"hydra_trailDef",
		"hydra_poisonDef",
		"hydra_hit_Skill1Def",
		"hydra_projectileDef",
		"hydra_decal_skill2Def",
		"hydra_death1_headsDef",
		"hydra_death_threeheadsDef",
		"Rocks_Paths1Def",
		"Rocks_Paths2Def",
		"Rocks_Paths3Def",
		"Rocks_Paths4Def",
		"rune_rockDef",
		"Tank_crocs_animationsDef",
		"Fx_Shaman_BlocktowerDef",
		"animations_tower_killDef",
	}
	EXO:load(enemy_table_stage3)
	EXO:load(enemy_table_stage4)
	EXO:load(enemy_table_stage5)
	--需要检查特殊塔

	local dragon_table = {
		"stage31_wood_holder_cuernosDef",
		"stage31_wood_holder_dragon_rootDef",
		"stage31_wood_holder_dragonDef",
		"stage31_wood_holder_gradienteDef",
		"stage31_wood_holder_habilidad_1Def",
		"stage31_wood_holder_jarraDef",
		"stage31_wood_holder_jarrahojasDef",
		"stage31_wood_holder_rayo_explosionDef",
		"stage31_wood_holder_rayoDef",
		"stage31_wood_holder_root1Def",
		"stage31_wood_holder_root2Def",
		"stage31_wood_holder_root3Def",
		"stage31_wood_holder_root4Def",
		"stage31_wood_holder_animations_parcheDef",
		"fireholder_cuernosDef",
		"fireholder_dragonDef",
		"fireholder_dragon_executionDef",
		"fireholder_dragon_rootDef",
		"fireholder_gradienteDef",
		"fireholder_habilidad_1Def",
		"fireholder_jarraDef",
		"fireholder_jarrahojasDef",
		"fireholder_rayoDef",
		"fireholder_rayo_explosionDef",
		"fireholder_dragon_executionDef",
		"dirtholder_cuernosDef",
		"dirtholder_dragonDef",
		"dirtholder_gradienteDef",
		"dirtholder_habilidad_1Def",
		"dirtholder_jarraDef",
		"dirtholder_jarrahojasDef",
		"dirtholder_parcheDef",
		"dirtholder_rayo_explosionDef",
		"dirtholder_rayoDef",
		"stage33_water_mistDef",
		"stage33_water_holder_animations_parcheDef",
		"stage33_water_holder_cuernosDef",
		"stage33_water_holder_dragonDef",
		"stage33_water_holder_gradienteDef",
		"stage33_water_holder_habilidad_1Def",
		"stage33_water_holder_healDef",
		"stage33_water_holder_jarraDef",
		"stage33_water_holder_jarrahojasDef",
		"stage33_water_holder_rayo_explosionDef",
		"stage33_water_holder_rayoDef",
		"stage33_water_dragonflyDef",
		"stage33_water_dragonrootDef",
		"stage33_water_debuff_midDef",
		"goldholder_coin_splashDef",
		"goldholder_cuernosDef",
		"goldholder_dragon_rootDef",
		"goldholder_dragonDef",
		"goldholder_gradienteDef",
		"goldholder_habilidad_1Def",
		"goldholder_jarraDef",
		"goldholder_jarrahojasDef",
		"goldholder_rayo_explosionDef",
		"goldholder_rayoDef",
	}
	local tower_special_gen5_table = {
		"sunraytowerDef",
		"sunraytower_decal1Def",
		"sunraytower_decal2Def",
		"sunraytower_hitDef",
		"stage_13_glareDef",
		"arborean_hitDef",
		"arborean_oldDef",
		"arborean_projectileDef",
		"arborean_smoke_trailDef",
		"arborean_treeDef",
		"arborean_woodDef",
		"arborean_oldDef",
		"Shaman_baseDef",
		"tower_treeDef",
		"tower_tree_explosion_decalDef",
		"tower_tree_leaflessFXDef",
		"tower_tree_projectileDef",
		"tower_tree_projectile_explosionDef",
		"tower_tree_transformationFXDef",
	}
	if slot.liuhui.cheat5 or slot.liuhui.cheat5_special then
		EXO:load(tower_special_gen5_table)
	end
	if slot.liuhui.cheat5_dragon then
		EXO:load(dragon_table)
	end
	--[[
	local FS = love.filesystem
	local path = string.format("%s/data/exoskeletons", KR_PATH_GAME)
	local files = FS.getDirectoryItems(path)
	local exo_table = {}
	for i = 1, #files do
		local name = files[i]
		if string.sub(name, -4, -1) ==".lua" then
			table.insert(exo_table, string.sub(name, 1, -5))
		end
	end
	]]

	if store.level_idx >= 87 then
		local level_data = require("data.levels."..store.level_name.."_data")
		
		if level_data.required_exoskeletons then
			EXO:load(level_data.required_exoskeletons)
		end

		if level_data.required_exoskeleton_groups then
			EXO:load_groups(level_data.required_exoskeleton_groups)
		end
	end

	if store.level.init then
		store.level:init(store)
	end

	UP:patch_templates(store.level.max_upgrade_level)
	DI:patch_templates()

	if store.level.data then
		store.level.locations = {}

		local level_utils = store.level_mode_6 and LU6 or LU

		level_utils.insert_entities(store, store.level.data.entities_list)
		level_utils.insert_invalid_path_ranges(store, store.level.data.invalid_path_ranges)
	end

	if store.level.load then
		store.level:load(store)
	end

	store.level.co = nil
	store.level.run_complete = nil
	store.player_gold = W:initial_gold()

	if store.level_mode_6 then
		store.lives = GS.mode_starting_lives[store.level_mode_6]
	elseif store.level_mode == GAME_MODE_CAMPAIGN then
		store.lives = 20
	elseif store.level_mode == GAME_MODE_HEROIC and store.level_idx == 87 then
		store.lives = 20
	elseif store.level_mode == GAME_MODE_HEROIC then
		store.lives = 1
	elseif store.level_mode == GAME_MODE_IRON then
		store.lives = 1
	elseif store.level_mode == GAME_MODE_ENDLESS then
		store.lives = W:initial_lives() or 10
	end

	store.gems_collected = 0
	store.player_score = 0
	store.game_outcome = nil
	store.main_hero = nil
	store.main1_hero = nil
	store.main_heroes = nil
	store._campaign_heroes_initialized = nil
	store._infinite_heroes_initialized = nil
	store._inserting_infinite_heroes = nil

	log.info("level_idx:%02d, level_mode:%d, level_difficulty:%d", store.level_idx, store.level_mode, store.level_difficulty)
end

function sys.level:on_update(dt, ts, store)
	local function store_hero_xp(slot)
		if GS.hero_xp_ephemeral then
			return
		end

		local heroes = store.main_heroes or {store.main_hero, store.main1_hero}

		for _, hero in ipairs(heroes) do
			if hero and hero.hero then
				local hn = hero.template_name

				if not slot.heroes or not slot.heroes.status or not slot.heroes.status[hn] then
					log.error("Active slot has no heroes status information. Skipping save")
				elseif hero.hero.xp > slot.heroes.status[hn].xp then
					slot.heroes.status[hn].xp = hero.hero.xp
				end
			end
		end
	end

	local campaign_variant = store.level_mode == GAME_MODE_CAMPAIGN and store.campaign_variant or CAMPAIGN_VARIANT_REGULAR

	if campaign_variant == CAMPAIGN_VARIANT_HERO_RALLY and not store.level.locked_hero and
		(not store.main_heroes or #store.main_heroes < 4) then
		LU.ensure_hero_rally(store)
	end

	if not store.level.update then
		store.level.run_complete = true
	else
		if not store.level.co and not store.level.run_complete then
			store.level.co = coroutine.create(store.level.update)
		end

		if store.level.co then
			local success, error = coroutine.resume(store.level.co, store.level, store)

			if coroutine.status(store.level.co) == "dead" or error ~= nil then
				if error ~= nil then
					log.error("Error running level coro: %s", debug.traceback(store.level.co, error))
				end

				store.level.co = nil
				store.level.run_complete = true
			end
		end
	end

	if not store._common_notifications then
		local slot = storage:load_slot()

		store._common_notifications = true

		if store.level_mode == GAME_MODE_IRON or store.level_mode == GAME_MODE_HEROIC then
			signal.emit("wave-notification", "view", "TIP_UPGRADES")
		elseif store.level_mode == GAME_MODE_ENDLESS then
			signal.emit("wave-notification", "view", "TIP_SURVIVAL")
		elseif KR_GAME == "kr1" and store.selected_hero and not U.is_seen(store, "TIP_HEROES") then
			signal.emit("wave-notification", "icon", "TIP_HEROES")
		elseif KR_GAME == "kr1" and store.level_mode == GAME_MODE_CAMPAIGN and store.level_idx >= 13 and U.count_stars(slot) < 50 and not U.is_seen(store, "TIP_ELITE") then
			signal.emit("wave-notification", "view", "TIP_ELITE")
		end
	end

	--print("load level 260")
	if campaign_variant == CAMPAIGN_VARIANT_HERO_RALLY and not store.level.locked_hero and
		(not store.main_heroes or #store.main_heroes < 4) then
		LU.ensure_hero_rally(store)
	elseif not store._campaign_heroes_initialized and not store.level.locked_hero and not store.level.manual_hero_insertion then
		store._campaign_heroes_initialized = true
		local user_data = storage:load_slot()
		local map_data = require("data.map_data")
		local hero_data = map_data.hero_data

		if campaign_variant == CAMPAIGN_VARIANT_SPELL_RAID then
			-- Spell raid intentionally has no heroes.
		elseif campaign_variant == CAMPAIGN_VARIANT_NOSTALGIC_CLASSIC then
			LU.insert_hero(store)
		elseif require("infinite_heroes").active(store) then
			require("infinite_heroes").spawn(store, LU.insert_hero)
		elseif (not user_data.liuhui_hero) or (not user_data.liuhui_hero.usedoublehero) then
			LU.insert_hero(store)
		else
			local name1 = hero_data[user_data.liuhui_hero.herolist[1]].name
			local name2 = hero_data[user_data.liuhui_hero.herolist[2]].name
			LU.insert_double_hero(store, name1, name2)
		end
	end

	if store.ephemeral._had_enemies then
		if not LU.has_alive_enemies(store) then
			signal.emit("all_enemies_died")

			store.ephemeral._had_enemies = false
		end
	elseif LU.has_alive_enemies(store) then
		store.ephemeral._had_enemies = true
	end

	if not store.game_outcome then
		if store.lives < 1 then
			log.info("++++ DEFEAT ++++")

			store.game_outcome = {
				victory = false,
				level_idx = store.level_idx,
				level_mode = store.level_mode,
				level_difficulty = store.level_difficulty
			}
			store.paused = true

			local slot = storage:load_slot()

			slot.last_victory = nil

			store_hero_xp(slot)

			slot.gems = (slot.gems or 0) + store.gems_collected

			if store.level_mode == GAME_MODE_ENDLESS then
				local slot_level = slot.levels[store.level_idx]

				slot_level = slot_level or {}

				if not slot_level[store.level_difficulty] then
					slot_level[store.level_difficulty] = {
						waves_survived = 0,
						high_score = 0
					}
					slot.levels[store.level_idx] = slot_level
				end

				if slot_level[store.level_difficulty].high_score < store.player_score then
					slot_level[store.level_difficulty].high_score = store.player_score
					slot_level[store.level_difficulty].waves_survived = store.wave_group_number
				end
			end

			signal.emit("game-defeat", store)
			signal.emit("game-defeat-after", store)
			storage:save_slot(slot, nil, true)
		elseif store.level.run_complete and store.waves_finished and not LU.has_alive_enemies(store) then
			log.info("++++ VICTORY ++++")

			local stars = 1
			local victory_mode = store.level_mode_6 or store.level_mode

			if victory_mode == GAME_MODE_CAMPAIGN then
				if store.lives >= 18 then
					stars = 3
				elseif store.lives >= 6 then
					stars = 2
				end
			end

			store.game_outcome = {
				victory = true,
				lives_left = store.lives,
				stars = stars,
				level_idx = store.level_idx,
				level_mode = store.level_mode,
				level_mode_6 = store.level_mode_6,
				level_difficulty = store.level_difficulty
			}

			local slot = storage:load_slot()

			slot.last_victory = {
				level_idx = store.level_idx,
				level_difficulty = store.level_difficulty,
				level_mode = victory_mode,
				stars = stars
			}

			store_hero_xp(slot)

			slot.gems = (slot.gems or 0) + store.gems_collected

			signal.emit("game-victory", store)
			signal.emit("game-victory-after", store)
			storage:save_slot(slot, nil, true)
		end
	end
end

sys.sso = {}
sys.sso.name = "sso"

function sys.sso:on_update(dt, ts, store)
	SSO:reset(store.entities)

	local vc = store.visible_coords
	local rx = vc.left
	local ry = vc.bottom
	local rw = vc.right - vc.left
	local rh = vc.top - vc.bottom
	local st = SSO:create("targets", rx, ry, rw, rh)

	for _, e in pairs(store.entities) do
		if not e.pending_removal and e.health and e.vis and e.pos then
			SSO:insert(st, e.pos.x, e.pos.y, e)
		end
	end

end

sys.sso_post = {}
sys.sso_post.name = "sso_post"

function sys.sso_post:init(store)
	SSO:reset_p_lists()
end

function sys.sso_post:destroy(store)
	SSO:reset_p_lists()
end

function sys.sso_post:on_insert(entity, store)
	local e = entity

	if e.main_script and (e.enemy and e.health or e.enemy and e.death_spawns or e.spawner and not e.spawner.eternal or e.picked_enemies or e.tunnel or IS_KR3 and e.template_name == "nav_faerie") then
		SSO:get_p_list("alive_enemies")[e.id] = e
	end

	if e.graveyard then
		SSO:get_p_list("graveyards")[e.id] = e
	end

	if e.modifier then
		SSO:get_p_list("modifiers")[e.id] = e
	end

	return true
end

function sys.sso_post:on_remove(entity, store)
	if entity.main_script then
		SSO:get_p_list("alive_enemies")[entity.id] = nil
	end

	if entity.graveyard then
		SSO:get_p_list("graveyards")[entity.id] = nil
	end

	if entity.modifier then
		SSO:get_p_list("modifiers")[entity.id] = nil
	end

	return true
end


sys.events = {}
sys.events.name = "events"

function sys.events:init(store)
	store.event_handlers = {}
end

function sys.events:on_insert(entity, store)
	if entity.events then
		for _, ev in pairs(entity.events.list) do
			if not store.event_handlers[ev.name] then
				store.event_handlers[ev.name] = {}
			end

			ev.entity_id = entity.id

			table.insert(store.event_handlers[ev.name], ev)
			log.debug("sys.events: ++ registered handler for %s entity:(%s)%s", ev.name, entity.id, entity.template_name)
		end
	end

	return true
end

function sys.events:on_remove(entity, store)
	if entity.events then
		for _, ev in pairs(entity.events.list) do
			if store.event_handlers[ev.name] then
				table.removeobject(store.event_handlers[ev.name], ev)
				log.debug("sys.events: -- removed handler for %s entity:(%s)%s", ev.name, entity.id, entity.template_name)
			end
		end
	end

	return true
end

sys.wave_spawn_tsv = {}
sys.wave_spawn_tsv.name = "wave_spawn_tsv"
sys.wave_spawn_tsv.cmd_fns = {}

function sys.wave_spawn_tsv.cmd_fns.column_names(store, cmd)
	if cmd.time_columns then
		W.db.time_columns = table.deepclone(cmd.time_columns)
	end

	if cmd.path_columns then
		W.db.path_columns = table.deepclone(cmd.path_columns)
	end
end

function sys.wave_spawn_tsv.cmd_fns.flags(store, cmd)
	if not cmd.flags_visibility then
		return
	end

	W.db.flags_visibility = cmd.flags_visibility
end

function sys.wave_spawn_tsv.cmd_fns.manual_wave(store, cmd)
	log.debug("manual_wave started: %s", cmd.wave_name)
end

function sys.wave_spawn_tsv.cmd_fns.manual_wave_repeat(store, cmd)
	local mws = W:get_wave_status(cmd.wave_name)

	if not mws then
		log.error("manual_wave_repeat: manual_wave_index[%s] not found", cmd.wave_name)

		return
	end

	if mws.repeat_remaining == -1 then
		mws.current_idx = mws.first_idx
	elseif mws.repeat_remaining and mws.repeat_remaining > 0 then
		mws.current_idx = mws.first_idx
		mws.repeat_remaining = mws.repeat_remaining - 1
	else
		mws.status = W.WS_DONE
	end
end

function sys.wave_spawn_tsv.cmd_fns.call_manual_wave(store, cmd)
	log.debug("call_manual_wave: %s", cmd.value)
	W:start_manual_wave(cmd.value)
end

function sys.wave_spawn_tsv.cmd_fns.wave(store, cmd)
	local group = W:create_wave_group_from_tsv(cmd)

	group.group_idx = store.wave_group_number + 1
	store.next_wave_group_ready = group

	signal.emit("next-wave-ready", group)

	local wave_number = store.wave_group_number
	local wait_time = cmd.wait_time
	local start_ts = store.tick_ts

	if wait_time < 0 then
		while not store.send_next_wave and not store.force_next_wave do
			coroutine.yield()
		end
	else
		U.y_wait(store, wait_time, function(store, wait_time)
			return store.send_next_wave or store.force_next_wave
		end)
	end

	local actual_wait_time = store.tick_ts - start_ts

	store.next_wave_group_ready = nil
	store.wave_group_number = store.wave_group_number + 1

	if store.force_next_wave then
		store.force_next_wave = false
	end

	if store.send_next_wave == true and store.wave_group_number > 1 then
		local score_reward
		local remaining_secs = math.max(0, km.round(wait_time - actual_wait_time))
		local reward_secs = math.min(remaining_secs, EARLY_WAVE_REWARD_MAX_SECONDS)

		if store.level_mode == GAME_MODE_ENDLESS then
			store.early_wave_reward = math.ceil(reward_secs * GS.early_wave_reward_per_second * W:get_endless_early_wave_reward_factor())

			local conf = W:get_endless_score_config()
			local time_factor = km.clamp(0, 1, remaining_secs / fts(group.interval))

			score_reward = km.round((wave_number - 1) * conf.scorePerWave * conf.scoreNextWaveMultiplier * time_factor * #group.waves)
			store.player_score = store.player_score + score_reward

			log.debug("ENDLESS: early wave %s reward %s (time_factor:%s scorePerWave:%s scoreNextWaveMultiplier:%s flags:%s", wave_number, score_reward, time_factor, conf.scorePerWave, conf.scoreNextWaveMultiplier, #group.waves)
		else
			local user_data = storage:load_slot()
			local reward_factor = generation_upgrades.early_wave_reward_factor(user_data, store.level_idx)

			store.early_wave_reward = math.ceil(reward_secs * GS.early_wave_reward_per_second * reward_factor)
		end

		store.player_gold = store.player_gold + store.early_wave_reward
		earnings_stats.record(store, "early_wave", store.early_wave_reward)

		signal.emit("early-wave-called", group, store.early_wave_reward, remaining_secs, score_reward)
	else
		store.early_wave_reward = 0
	end

	if store.level_mode == GAME_MODE_ENDLESS and wave_number > 1 then
		local conf = W:get_endless_score_config()
		local reward = (wave_number - 1) * conf.scorePerWave

		store.player_score = store.player_score + reward

		local gems = GS.endless_gems_for_wave * (wave_number - 1)

		store.gems_collected = store.gems_collected + gems

		log.debug("ENDLESS: wave %s reward:%s gems:%s", wave_number, reward, gems)
	end

	if store.level_mode ~= GAME_MODE_ENDLESS then
		local gems_keeper_random = store.level_mode == GAME_MODE_CAMPAIGN
		local spawns = W:get_spawns_for_wave(store.wave_group_number) or {}
		local gem_keepers = W:get_gem_keepers()
		local spawn_count = 0

		for _, spawn in ipairs(spawns) do
			spawn_count = spawn_count + math.max(0, math.min(99999, math.floor(tonumber(spawn.max) or 1)))
		end

		gem_keepers = math.min(gem_keepers, spawn_count)

		if gems_keeper_random and gem_keepers > 0 then
			store.gems_spawn_idx = km.rand_uniq(gem_keepers, 1, spawn_count)
		else
			store.gems_spawn_idx = {}

			for i = spawn_count, spawn_count - gem_keepers + 1, -1 do
				table.insert(store.gems_spawn_idx, i)
			end
		end

		log.debug("GEMS: assigned gems to spawn indexes %s for wave %s", getdump(store.gems_spawn_idx), store.wave_group_number)
	end

	store.current_spawn_idx = 0
	store.send_next_wave = false
	store.current_wave_group = group

	signal.emit("next-wave-sent", group)
end

function sys.wave_spawn_tsv.cmd_fns.spawn(store, cmd, wave_name)
	local wait_time = cmd.wait_time

	if wait_time and wait_time > 0 then
		U.y_wait(store, wait_time, function(store, wait_time)
			return store.force_next_wave
		end)
	end

	if store.force_next_wave then
		log.debug("skipping spawn command due to force_next_wave")

		return
	end

	local function spawn_one(o)
		if not U.is_seen(store, o.enemy) then
			signal.emit("wave-notification", "icon", o.enemy)
			U.mark_seen(store, o.enemy)
		end

		local e = E:create_entity(o.enemy)

		if e then
			store.current_spawn_idx = store.current_spawn_idx + 1

			local path = P.paths[o.pi]

			e.nav_path.pi = o.pi
			e.nav_path.spi = o.spi == "*" and math.random(#path) or o.spi
			e.nav_path.ni = P:get_start_node(o.pi)

			if e.enemy and table.contains(store.gems_spawn_idx, store.current_spawn_idx) then
				e.enemy.gems = math.floor(store.gems_per_wave / #store.gems_spawn_idx * (1 + km.rand_sign() * 0.2))

				log.debug("GEMS: %s gems to enemy: (%s)%s spawn_idx:%s", e.enemy.gems, e.id, e.template_name, store.current_spawn_idx)
			end

			queue_insert(store, e)
		else
			log.error("Entity template %s not found", o.enemy)
		end
	end

	local streams = {}

	for _, o in pairs(cmd.spawns) do
		local count = math.max(0, math.min(99999, math.floor(tonumber(o.max) or 1)))

		if count > 0 then
			streams[#streams + 1] = {
				o = o,
				remaining = count,
				next_at = 0,
				interval = math.max(0, math.min(999, tonumber(o.interval) or 0)),
				interval_next = math.max(0, math.min(9999, tonumber(o.interval_next) or 0))
			}
		end
	end

	local elapsed = 0

	while #streams > 0 do
		local next_at = math.huge
		local i = 1

		while i <= #streams do
			local stream = streams[i]

			if stream.next_at <= elapsed then
				if stream.remaining > 0 then
					spawn_one(stream.o)
					stream.remaining = stream.remaining - 1

					if stream.remaining > 0 then
						stream.next_at = elapsed + stream.interval
					elseif stream.interval_next > 0 then
						stream.next_at = elapsed + stream.interval_next
						stream.remaining = -1
					else
						table.remove(streams, i)
						stream = nil
					end
				else
					table.remove(streams, i)
					stream = nil
				end
			end

			if stream then
				next_at = math.min(next_at, stream.next_at)
				i = i + 1
			end
		end

		if #streams > 0 and next_at > elapsed then
			U.y_wait(store, next_at - elapsed, function(store)
				return store.force_next_wave
			end)
			elapsed = next_at

			if store.force_next_wave then
				log.debug("skipping remaining custom TSV spawn repetitions due to force_next_wave")

				return
			end
		end
	end
end

function sys.wave_spawn_tsv.cmd_fns.event(store, cmd)
	local wait_time = cmd.wait_time

	if wait_time and wait_time > 0 then
		U.y_wait(store, wait_time, function(store, wait_time)
			return store.force_next_wave
		end)
	end

	local handlers = store.event_handlers

	if cmd.event_name and handlers and handlers[cmd.event_name] then
		for _, ev in pairs(handlers[cmd.event_name]) do
			local entity = store.entities[ev.entity_id]

			ev.on_event(entity, store, ev.name, unpack(cmd.event_params or {}))
		end
	end
end

function sys.wave_spawn_tsv.cmd_fns.signal(store, cmd)
	local wait_time = cmd.wait_time

	if wait_time and wait_time > 0 then
		U.y_wait(store, wait_time, function(store, wait_time)
			return store.force_next_wave
		end)
	end

	if cmd.signal_name then
		signal.emit(cmd.signal_name, unpack(cmd.signal_params or {}))
	end
end

function sys.wave_spawn_tsv.cmd_fns.wait_signal(store, cmd)
	local signal_name = cmd.signal_name

	store.wait_signal_done = nil

	local function fn(...)
		log.debug("wait_signal : signal received")

		store.wait_signal_done = "arrived"
	end

	if signal_name then
		log.debug("wait_signal: registering signal %s", signal_name)
		signal.register(signal_name, fn)
	end

	log.debug("wait_signal: waiting for signal:%s  time:%s", signal_name, cmd.wait_time)

	--if cmd.wait_time < 0 then
	if cmd.wait_time < 0 then-- or signal_name == "all_enemies_died" or signal_name == "ciclone_end" or signal_name == "barrage_end" then
		while not store.wait_signal_done and not store.force_next_wave do
			coroutine.yield()
		end
	else
		--新clamp 20251003
		cmd.wait_time = km.clamp(30, 60, cmd.wait_time)
		U.y_wait(store, cmd.wait_time, function(store, wait_time)
			if store.wait_signal_done or store.force_next_wave then
				store.wait_signal_done = "interrupted"

				return true
			end
		end)
	end

	log.debug("wait_signal: deregistering signal %s", signal_name)
	if signal_name then signal.remove(signal_name, fn) end
end

function sys.wave_spawn_tsv.cmd_fns.wait(store, cmd)
	local wait_time = cmd.wait_time

	if wait_time and wait_time > 0 then
		U.y_wait(store, wait_time, function(store, wait_time)
			return store.force_next_wave
		end)
	end
end

function sys.wave_spawn_tsv.y_run_wave(store, wave_name)
	local cmd_fns = sys.wave_spawn_tsv.cmd_fns
	local cmd = W:get_next_cmd(wave_name)

	while cmd do
		if cmd_fns[cmd.name] then
			cmd_fns[cmd.name](store, cmd, wave_name)
		elseif cmd.wait_time then
			if cmd.wait_time < 0 then
				while not store.send_next_wave and not store.force_next_wave do
					coroutine.yield()
				end
			else
				U.y_wait(store, cmd.wait_time, function(store, wait_time)
					return store.force_next_wave
				end)
			end
		end

		cmd = W:get_next_cmd(wave_name)
	end

	return true
end

function sys.wave_spawn_tsv:init(store)
	if W.format ~= "tsv" then
		log.warning("Wave format is not tsv, skipping wave_spawn_tsv system")

		return "skip"
	end

	if store.level_mode == GAME_MODE_ENDLESS then
		log.error("ENDLESS mode not supported yet in wave_spawn_tsv")

		return "skip"
	end

	store.wave_group_number = 0
	store.waves_finished = false
	store.last_wave_ts = 0
	store.send_next_wave = false
	store.manual_wave_cos = {}

	do
		local cmd_fns = sys.wave_spawn_tsv.cmd_fns
		local cmd = W:peek_next_cmd()

		while cmd and cmd.name ~= "wave" and cmd.name ~= "manual_wave" and not cmd.wait_time do
			if cmd_fns[cmd.name] then
				cmd_fns[cmd.name](store, cmd)
			end

			cmd = W:get_next_cmd()
			cmd = W:peek_next_cmd()
		end
	end

	if store.level_mode == GAME_MODE_ENDLESS then
		store.gems_per_wave = 0
		store.wave_group_total = 0
	else
		store.gems_per_wave = math.floor((GS.gems_per_level[store.level_idx] or 100) * GS.gems_factor_per_mode[store.level_mode] / W:all_waves_count())
		store.wave_group_total = W:groups_count()
	end

	store.wave_spawn_co = coroutine.create(sys.wave_spawn_tsv.y_run_wave)
end

function sys.wave_spawn_tsv:on_update(dt, ts, store)
	if store.force_next_wave then
		LU.kill_all_enemies(store, nil, true)
	end

	if store.wave_spawn_co then
		local ok, done = coroutine.resume(store.wave_spawn_co, store)

		if ok and done then
			store.wave_spawn_co = nil
			store.waves_finished = true

			log.debug("wave_spawn_tsv: waves finished")
		end

		if not ok then
			log.error("wave_spawn_tsv: Error resuming wave_spawn_co co:%s", debug.traceback(store.wave_spawn_co, done))

			store.wave_spawn_co = nil
		end
	elseif store.waves_finished == false then
		--流辉 20251003 否则，当没有线程的时候，强制结束
		level_table = {116}
		if store.wave_group_total <= (store.wave_group_number + 0.5) and not table.contains(level_table, store.level_idx) then
			store.waves_finished = true
			print("LIUHUI349 FORCE END LEVEL")
		end
	end

	if W:has_pending_manual_waves() then
		for _, name in pairs(W:list_pending_manual_waves()) do
			local ws = W:get_wave_status(name)

			ws.state = W.WS_RUNNING
			store.manual_wave_cos = store.manual_wave_cos or {}
			store.manual_wave_cos[name] = coroutine.create(sys.wave_spawn_tsv.y_run_wave)
		end
	end

	if store.manual_wave_cos then
		local to_remove

		for name, co in pairs(store.manual_wave_cos) do
			local ws = W:get_wave_status(name)

			if ws and ws.state == W.WS_DONE then
				to_remove = to_remove or {}

				table.insert(to_remove, name)
			else
				local ok, done = coroutine.resume(co, store, name)

				if ok and done then
					to_remove = to_remove or {}

					table.insert(to_remove, name)
				end

				if not ok then
					log.error("wave_spawn_tsv: Error resuming manual_wave_cos[%s]:%s", name, debug.traceback(co, done))

					store.wave_spawn_co = nil
				end
			end
		end

		if to_remove then
			for _, name in pairs(to_remove) do
				store.manual_wave_cos[name] = nil

				local ws = W:get_wave_status(name)

				if ws then
					ws.state = W.WS_REMOVED
				end
			end

			to_remove = nil
		end
	end

	store.force_next_wave = false
end

sys.wave_spawn = {}
sys.wave_spawn.name = "wave_spawn"

local function notify_new_enemy(store, template_name)
	if U.is_seen(store, template_name) then
		return
	end

	-- A failed notification must not terminate the enemy spawner.
	local ok, err = xpcall(function()
		signal.emit("wave-notification", "icon", template_name)
	end, debug.traceback)

	U.mark_seen(store, template_name)

	if not ok then
		log.error("Enemy notification failed for %s; spawning continues: %s", template_name, err)
	end
end

local function spawner(store, wave)
	log.debug("spawner thread(%s) for wave(%s) starting", coroutine.running(), tostring(wave))

	local spawns = wave.spawns
	local pi = wave.path_index
	local last_spawn_ts = 0
	local gems_creep_idx
	local gems_keeper_random = store.level_mode == GAME_MODE_CAMPAIGN
	local gems_spawn_idx = gems_keeper_random and math.random(1, #spawns) or #spawns
	local max_creeps = spawns[gems_spawn_idx] and spawns[gems_spawn_idx].max or 3

	if max_creeps > 0 then
		gems_creep_idx = gems_keeper_random and math.random(1, max_creeps) or max_creeps

		log.debug("GEMS: gems_spawn_idx:%s gems_creep_idx:%s", gems_spawn_idx, gems_creep_idx)
	else
		log.debug("GEMS: assigned to spawner with max_creeps = 0, so not in play.")
	end

	for i = 1, #spawns do
		local current_count = 0
		local current_creep
		local s = spawns[i]
		local path = P.paths[pi]

		notify_new_enemy(store, s.creep)

		if s.creep_aux then
			notify_new_enemy(store, s.creep_aux)
		end

		for j = 1, s.max do
			U.y_wait(store, fts(s.interval or 0))

			if not current_creep then
				current_creep = s.creep
			elseif s.creep_aux and s.max_same and s.max_same > 0 and current_count >= s.max_same then
				current_creep = s.creep == current_creep and s.creep_aux or s.creep
				current_count = 0
			end

			local e = E:create_entity(current_creep)

			if e then
				e.nav_path.pi = pi
				e.nav_path.spi = s.fixed_sub_path == 1 and s.path or math.random(#path)
				e.nav_path.ni = P:get_start_node(pi)
				e.spawn_data = s.spawn_data

				if e.enemy and gems_spawn_idx == i and gems_creep_idx == j then
					e.enemy.gems = math.floor(store.gems_per_wave * (1 + km.rand_sign() * 0.2))

					log.debug("GEMS: %s gems to enemy: (%s)%s spawn:%s creep:%s", e.enemy.gems, e.id, e.template_name, i, j)
				end

				queue_insert(store, e)

				current_count = current_count + 1
			else
				log.error("Entity template not found for %s.", s.crep)
			end
		end

		if s.max == 0 then
			U.y_wait(store, fts(s.interval or 0))
		end

		local oes = s.on_end_signal

		if oes then
			log.info("Sending spawner on_end_signal: %s", oes)

			store.wave_signals[oes] = {}
		end

		if i < #spawns then
			U.y_wait(store, fts(s.interval_next or 0))
		end
	end

	log.debug("spawner thread(%s) for wave(%s) about to finish", coroutine.running(), tostring(wave))

	return true
end

function sys.wave_spawn:init(store)
	if W.format ~= "lua" then
		log.warning("Wave format is not lua, skipping wave_spawn system")

		return "skip"
	end
	store.wave_group_number = 0
	store.waves_finished = false
	store.last_wave_ts = 0
	store.waves_active = {}
	store.wave_signals = {}
	store.send_next_wave = false

	if store.level_mode == GAME_MODE_ENDLESS then
		store.gems_per_wave = 0
		store.wave_group_total = 0
	else
		store.gems_per_wave = math.floor(GS.gems_per_level[store.level_idx] * GS.gems_factor_per_mode[store.level_mode] / W:waves_count())
		store.wave_group_total = W:groups_count()
	end

	local function run(store)
		log.info("Wave group spawn thread STARTING")

		local i = 1

		while W:has_group(i) do
			local group = W:get_group(i)

			group.group_idx = i
			store.next_wave_group_ready = group

			signal.emit("next-wave-ready", group)

			if i == 1 then
				for _, wave in pairs(group.waves) do
					if wave.notification and wave.notification ~= "" then
						signal.emit("wave-notification", "view", wave.notification)
					end
				end

				while not store.send_next_wave do
					coroutine.yield()
				end

				log.debug("Sending first WAVE. (Started by player)")
			else
				while not store.send_next_wave and not (store.tick_ts - store.last_wave_ts >= fts(group.interval)) and not store.force_next_wave do
					coroutine.yield()
				end
			end

			log.info("sending WAVE group %02d (%02d waves)", i, #group.waves)

			store.next_wave_group_ready = nil
			store.wave_group_number = i

			if store.send_next_wave == true and i > 1 then
				local score_reward
				local remaining_secs = group.no_early_wave_bonus and 0 or math.max(0, km.round(fts(group.interval) - (store.tick_ts - store.last_wave_ts)))
				local reward_secs = math.min(remaining_secs, EARLY_WAVE_REWARD_MAX_SECONDS)

				if store.level_mode == GAME_MODE_ENDLESS then
					store.early_wave_reward = math.ceil(reward_secs * GS.early_wave_reward_per_second * W:get_endless_early_wave_reward_factor())

					local conf = W:get_endless_score_config()
					local time_factor = km.clamp(0, 1, remaining_secs / fts(group.interval))

					score_reward = km.round((i - 1) * conf.scorePerWave * conf.scoreNextWaveMultiplier * time_factor * #group.waves)
					store.player_score = store.player_score + score_reward

					log.debug("ENDLESS: early wave %s reward %s (time_factor:%s scorePerWave:%s scoreNextWaveMultiplier:%s flags:%s", i, score_reward, time_factor, conf.scorePerWave, conf.scoreNextWaveMultiplier, #group.waves)
				else
					local user_data = storage:load_slot()
					local reward_factor = generation_upgrades.early_wave_reward_factor(user_data, store.level_idx)

					store.early_wave_reward = math.ceil(reward_secs * GS.early_wave_reward_per_second * reward_factor)
				end

				store.player_gold = store.player_gold + store.early_wave_reward
				earnings_stats.record(store, "early_wave", store.early_wave_reward)

				signal.emit("early-wave-called", group, store.early_wave_reward, remaining_secs, score_reward)
			else
				store.early_wave_reward = 0
			end

			if store.level_mode == GAME_MODE_ENDLESS and i > 1 then
				local conf = W:get_endless_score_config()
				local reward = (i - 1) * conf.scorePerWave

				store.player_score = store.player_score + reward

				local gems = GS.endless_gems_for_wave * (i - 1)

				store.gems_collected = store.gems_collected + gems

				log.debug("ENDLESS: wave %s reward:%s gems:%s", i, reward, gems)
			end

			store.send_next_wave = false
			store.current_wave_group = group

			signal.emit("next-wave-sent", group)
			log.debug("GEMS:_wave_idx:%s", gems_wave_idx)

			for j, wave in pairs(group.waves) do
				wave.group_idx = i

				if i ~= 1 and wave.notification and wave.notification ~= "" then
					signal.emit("wave-notification", "view", wave.notification)
				end

				if wave.notification_second_level and wave.notification_second_level ~= "" then
					signal.emit("wave-notification", "icon", wave.notification_second_level)
				end

				local sco = coroutine.create(function()
					local wave_start_ts = store.tick_ts

					while store.tick_ts < wave_start_ts + fts(wave.delay) do
						coroutine.yield()
					end

					return spawner(store, wave)
				end)

				store.waves_active[sco] = sco
			end

			log.info("WAVE group %d about to wait for all its spawner threads to finish", i)

			while next(store.waves_active) do
				coroutine.yield()
			end

			store.current_wave_group = nil
			store.last_wave_ts = store.tick_ts
			i = i + 1
		end

		log.info("WAVE spawn thread FINISHED")

		return true
	end

	store.wave_spawn_thread = coroutine.create(run)
end

function sys.wave_spawn:force_next_wave(store)
	if store.force_next_wave then
		store.waves_active = {}

		LU.kill_all_enemies(store, nil, true)
	end
end

function sys.wave_spawn:on_insert(entity, store)
	if store.level_mode == GAME_MODE_ENDLESS and (entity.enemy or entity.endless) and not entity._entity_progression_done then
		W:set_entity_progression(entity, store.wave_group_number)

		entity._entity_progression_done = true
	end

	return true
end

function sys.wave_spawn:on_update(dt, ts, store)
	sys.wave_spawn:force_next_wave(store)

	if store.wave_spawn_thread then
		local ok, done = coroutine.resume(store.wave_spawn_thread, store)

		if ok and done then
			store.wave_spawn_thread = nil
			store.waves_finished = true

			log.debug("++++ WAVES FINISHED")
		end

		if not ok then
			log.error("Error resuming wave_spawn_thread co: %s", debug.traceback(store.wave_spawn_thread, done))

			--流辉 20251003 否则，强制结束。目前暂时查不出bug
			store.waves_finished = true
			
			store.wave_spawn_thread = nil
		end
	elseif store.waves_finished == false then
	--流辉 20251003 否则，当没有线程的时候，强制结束
		level_table = {116}
		if store.wave_group_total <= (store.wave_group_number + 0.5) and not table.contains(level_table, store.level_idx) then
			store.waves_finished = true
			print("LIUHUI349 FORCE END LEVEL")
		end
	end

	local to_cleanup

	for _, co in pairs(store.waves_active) do
		local ok, done = coroutine.resume(co, store)

		if ok and (done or coroutine.status(co) == "dead") then
			log.debug("thread (%s) finished after resume()", tostring(co))

			to_cleanup = to_cleanup or {}
			to_cleanup[#to_cleanup + 1] = co
		end

		if not ok then
			local err = done

			log.error("Error resuming spawner thread (%s): %s", tostring(co), debug.traceback(co, err))

			to_cleanup = to_cleanup or {}
			to_cleanup[#to_cleanup + 1] = co
		end
	end

	if to_cleanup then
		for _, co in pairs(to_cleanup) do
			log.debug("removing spawner thread (%s)", co)

			store.waves_active[co] = nil
		end

		to_cleanup = nil
	end

	store.force_next_wave = false
end

sys.mod_lifecycle = {}
sys.mod_lifecycle.name = "mod_lifecycle"

function sys.mod_lifecycle:on_insert(entity, store)
	if not entity.modifier then
		return true
	end

	local this = entity
	local target_id = this.modifier.target_id
	local target = store.entities[target_id]
	if target and target.unit and target.unit.modifier_filter and not target.unit.modifier_filter(this, store) then return false end
	local modifiers = table.filter(store.entities, function(k, v)
		return v.modifier and v.modifier.target_id == target_id
	end)

	for _, m in pairs(modifiers) do
		if m.modifier.bans and table.contains(m.modifier.bans, this.template_name) then
			log.debug("modifier %s not allowed by %s for target entity %s", this.template_name, m.template_name, this.modifier.target_id)

			return false
		end
	end

	if this.modifier.remove_banned then
		for _, m in pairs(modifiers) do
			if this.modifier.bans and table.contains(this.modifier.bans, m.template_name) then
				m.modifier.removed_by_ban = true

				queue_remove(store, m)
				log.debug("banned modifier (%s) %s removed by (%s) %s for target entity %s", m.id, m.template_name, this.id, this.template_name, this.modifier.target_id)
			end

			if this.modifier.ban_types and table.contains(this.modifier.ban_types, m.modifier.type) then
				m.modifier.removed_by_ban = true

				queue_remove(store, m)
				log.debug("banned modifier (%s) %s of type %s removed by (%s) %s for target entity %s", m.id, m.template_name, this.id, m.modifier.type, this.template_name, this.modifier.target_id)
			end
		end
	end

	this.modifier.ts = store.tick_ts

	if this.render then
		for i = 1, #this.render.sprites do
			this.render.sprites[i].ts = store.tick_ts
		end
	end

	for _, m in pairs(modifiers) do
		if m.template_name == this.template_name then
			if this.modifier.level == m.modifier.level and this.modifier.allows_duplicates then
				log.paranoid("adding a duplicate modifier (%s)-%s", this.id, this.template_name)

				return true
			elseif this.modifier.level > m.modifier.level and this.modifier.replaces_lower then
				log.paranoid("replacing existing modifier (%s)-%s with (%s)-%s", m.id, m.template_name, this.id, this.template_name)
				queue_remove(store, m)

				if m.render then
					for i = 1, #this.render.sprites do
						this.render.sprites[i].ts = m.render.sprites[i].ts
					end
				end
			elseif this.modifier.level == m.modifier.level and this.modifier.resets_same then
				log.paranoid("resetting ts for modifier (%s)-%s instead of inserting (%s)-%s", m.id, m.template_name, this.id, this.template_name)

				m.modifier.ts = store.tick_ts

				if this.modifier.resets_same_tween and m.tween then
					m.tween.ts = store.tick_ts - (this.modifier.resets_same_tween_offset or 0)
				end

				return false
			else
				return false
			end
		end
	end

	return true
end

sys.tower_upgrade = {}
sys.tower_upgrade.name = "tower_upgrade"

function sys.tower_upgrade:on_update(dt, ts, store)
	for _, e in E:filter_iter(store.entities, "tower") do
		if e.tower.sell or e.tower.destroy then
			log.debug("selling %s", e.id)

			if e.tower.sell then
				local refund = store.wave_group_number == 0 and e.tower.spent or km.round(e.tower.refund_factor * e.tower.spent)

				store.player_gold = store.player_gold + refund
			end

			if e.tower.sell then
				local mods = table.filter(store.entities, function(_, ee)
					return ee.modifier and ee.modifier.target_id == e.id
				end)

				for _, mod in pairs(mods) do
					queue_remove(store, mod)
				end
			end

			local kr6_holder = e.tower.terrain_style and e.tower.terrain_style >= 46 and e.tower.terrain_style <= 64 and e.tower.terrain_style ~= 50
			local th = E:create_entity(kr6_holder and "tower_holder_kr6" or "tower_holder")

			th.pos = V.vclone(e.pos)
			th.tower.holder_id = e.tower.holder_id
			th.tower.flip_x = e.tower.flip_x

			if e.tower.default_rally_pos then
				th.tower.default_rally_pos = e.tower.default_rally_pos
			end

			if e.tower.terrain_style then
				th.tower.terrain_style = e.tower.terrain_style
				th.render.sprites[1].name = string.format(th.render.sprites[1].name, e.tower.terrain_style)
			end

			queue_insert(store, th)
			combat_stats_register_entity(store, e)
			queue_remove(store, e)
			signal.emit("tower-removed", e, th)

			if e.tower.sell then
				local dust = E:create_entity("fx_tower_sell_dust")

				dust.pos.x, dust.pos.y = th.pos.x, th.pos.y + 35
				dust.render.sprites[1].ts = store.tick_ts

				queue_insert(store, dust)

				if e.sound_events and e.sound_events.sell then
					S:queue(e.sound_events.sell, e.sound_events.sell_args)
				end
			end
		elseif e.tower.upgrade_to then

			log.debug("upgrading %s to %s", e.id, e.tower.upgrade_to)
			combat_stats_register_entity(store, e)

			local mods = table.filter(store.entities, function(_, ee)
				return ee.modifier and ee.modifier.target_id == e.id
			end)

			for _, mod in pairs(mods) do
				queue_remove(store, mod)
			end

			local ne = E:create_entity(e.tower.upgrade_to)

			ne.pos = V.vclone(e.pos)
			ne.tower.holder_id = e.tower.holder_id
			ne.tower.flip_x = e.tower.flip_x

			if e.tower.default_rally_pos then
				ne.tower.default_rally_pos = V.vclone(e.tower.default_rally_pos)
			end

			if e.tower.terrain_style then
				ne.tower.terrain_style = e.tower.terrain_style
				ne.render.sprites[1].name = string.format(ne.render.sprites[1].name, e.tower.terrain_style)
			end

			ne.combat_stats_id = e.combat_stats_id or combat_stats_tower_id(e)
			combat_stats_register_entity(store, ne)

			queue_insert(store, ne)
			queue_remove(store, e)
			signal.emit("tower-upgraded", ne, e)

			local price = ne.tower.price

			if ne.tower.type == "build_animation" then
				local bt = E:get_template(ne.build_name)

				price = bt.tower.price
			elseif e.tower.type == "build_animation" then
				price = 0
			elseif e.tower_holder and e.tower_holder.unblock_price > 0 then
				price = e.tower_holder.unblock_price
			end

			if e.tower.upgrade_price_multiplier then
				price = math.ceil(price * e.tower.upgrade_price_multiplier)
				price = math.floor(price / 10) * 10
			end

			store.player_gold = store.player_gold - price

			if not e.tower_holder or not e.tower_holder.blocked then
				ne.tower.spent = e.tower.spent + price
			end

			if e.tower and e.tower.type == "engineer" and ne.tower.type == "engineer" then
				if ne.ranged_attack then
					ne.ranged_attack.ts = e.ranged_attack.ts
				elseif ne.area_attack then
					ne.area_attack.ts = e.ranged_attack.ts
				end
			elseif e.barrack and ne.barrack then
				if e.barrack.rally_pos then
					ne.barrack.rally_pos = V.vclone(e.barrack.rally_pos)
				end

				for i, s in ipairs(e.barrack.soldiers) do
					if not s.health then
						-- block empty
					elseif s.health.dead then
						-- block empty
					else
						if i > ne.barrack.max_soldiers then
							U.unblock_target(store, s)
						else
							--3人熊猫专用
							local nst = ne.barrack.solder_upgrade_map and ne.barrack.solder_upgrade_map[s.template_name] or ne.barrack.soldier_type
							local ns = E:create_entity(nst)

							ns.info.i18n_key = s.info.i18n_key
							ns.soldier.tower_id = ne.id
							--流辉 需要新增战士编号
							ns.soldier.tower_soldier_idx = i
							ns.pos = V.vclone(s.pos)
							ns.motion.dest = V.vclone(s.motion.dest)
							ns.motion.arrived = s.motion.arrived
							ns.render.sprites[1].flip_x = s.render.sprites[1].flip_x
							ns.render.sprites[1].flip_y = s.render.sprites[1].flip_y
							ns.render.sprites[1].name = s.render.sprites[1].name
							ns.render.sprites[1].loop = s.render.sprites[1].loop
							ns.render.sprites[1].ts = s.render.sprites[1].ts
							ns.render.sprites[1].runs = s.render.sprites[1].runs
							ns.nav_rally.pos = V.vclone(s.nav_rally.pos)
							ns.nav_rally.center = V.vclone(s.nav_rally.center)
							ns.nav_rally.new = s.nav_rally.new

							for i, a in ipairs(ns.melee.attacks) do
								if s.melee.attacks[i] then
									a.ts = s.melee.attacks[i].ts
								end
							end

							U.replace_blocker(store, s, ns)

							ne.barrack.soldiers[i] = ns

							queue_insert(store, ns)
						end

						s.health.dead = true

						queue_remove(store, s)
					end
				end
			elseif ne.barrack then
				ne.barrack.rally_pos = V.vclone(ne.tower.default_rally_pos)
			end

			if e.tower_upgrade_persistent_data and ne.tower_upgrade_persistent_data then
				ne.tower_upgrade_persistent_data = e.tower_upgrade_persistent_data
			end

			if ne.tower_upgrade_persistent_data then
				ne.tower_upgrade_persistent_data.combat_stats_id = ne.combat_stats_id
			end

			if ne.tower.type ~= "build_animation" and not ne.tower.hide_dust then
				local dust = E:create_entity("fx_tower_buy_dust")

				dust.pos.x, dust.pos.y = ne.pos.x, ne.pos.y + 10
				dust.render.sprites[1].ts = store.tick_ts

				queue_insert(store, dust)
			end
		end

	end
end

sys.game_upgrades = {}
sys.game_upgrades.name = "game_upgrades"

function sys.game_upgrades:init(store)
	store.game_upgrades_data = {}
	store.game_upgrades_data.mage_towers_count = 0
end

function sys.game_upgrades:on_insert(entity, store)
	local mage_tower_types = {
		"mage",
		"g2_mage",
		"archmage",
		"necromancer",
		"g1_mage",

		"wicked_sisters",
		"deep_devils",
		"blazing_watcher",
		"orc_shaman",
		"spirit_mausoleum",
		"infernal_mage",
		"sc_winter",
		"sc_frost_gem",

		"arcane_wizard5",
		"arborean_emissary",
		"necromancer5",
		"elven_stargazers",
		"ray",
		"dragons",
		"hermit_toad",

		"arcane",
		"wild_magus",
		"high_elven",
		"arcane_wizard",
		"sorcerer",

		"kr6_mage_kr1", 
		"kr6_arcane_wizard_kr1", 
		"kr6_sorcerer_kr1",
		"kr6_wizard", 
		"kr6_sunray_master", 
		"kr6_light_priestess", 
		"kr6_forger"
	}
	local mage_bullet_names = {
		"bolt_1",
		"bolt_2",
		"bolt_3",
		"bolt_archmage",
		"bolt_necromancer"
	}
	local u = UP:get_upgrade("mage_brilliance")

	if u and entity.tower and table.contains(mage_tower_types, entity.tower.type) then
		local existing_towers = table.filter(store.entities, function(_, e)
			return e.tower and table.contains(mage_tower_types, e.tower.type)
		end)

		if #existing_towers == 0 then
			for _, bn in pairs(mage_bullet_names) do
				local b = E:get_template(bn).bullet

				b._orig_damage_min = b.damage_min
				b._orig_damage_max = b.damage_max
			end
		else
			local f = u.damage_factors[km.clamp(1, #u.damage_factors, #existing_towers + 1)]

			for _, bn in pairs(mage_bullet_names) do
				local b = E:get_template(bn).bullet

				if b._orig_damage_min then
					b.damage_min = math.ceil(b._orig_damage_min * f)
					b.damage_max = math.ceil(b._orig_damage_max * f)
				else
					b._orig_damage_min = b.damage_min
					b._orig_damage_max = b.damage_max
					b.damage_min = math.ceil(b._orig_damage_min * f)
					b.damage_max = math.ceil(b._orig_damage_max * f)
				end
			end
		end
	end

	return true
end

function sys.game_upgrades:on_remove(entity, store)
	local mage_tower_types = {
		"mage",
		"g1_mage",
		"g2_mage",
		"archmage",
		"necromancer",

		"wicked_sisters",
		"deep_devils",
		"blazing_watcher",
		"orc_shaman",
		"spirit_mausoleum",
		"infernal_mage",
		"sc_winter",
		"sc_frost_gem",

		"arcane_wizard5",
		"arborean_emissary",
		"necromancer5",
		"elven_stargazers",
		"ray",
		"dragons",
		"hermit_toad",

		"arcane",
		"wild_magus",
		"high_elven",
		"arcane_wizard",
		"sorcerer",
		
		"kr6_mage_kr1", 
		"kr6_arcane_wizard_kr1", 
		"kr6_sorcerer_kr1",
		"kr6_wizard", 
		"kr6_sunray_master", 
		"kr6_light_priestess", 
		"kr6_forger"
	}
	local mage_bullet_names = {
		"bolt_1",
		"bolt_2",
		"bolt_3",
		"bolt_archmage",
		"bolt_necromancer"
	}
	local u = UP:get_upgrade("mage_brilliance")

	if u and entity.tower and table.contains(mage_tower_types, entity.tower.type) then
		local existing_towers = table.filter(store.entities, function(_, e)
			return e.tower and table.contains(mage_tower_types, e.tower.type)
		end)
		local f = u.damage_factors[km.clamp(1, #u.damage_factors, #existing_towers - 1)]

		for _, bn in pairs(mage_bullet_names) do
			local b = E:get_template(bn).bullet

			b.damage_min = math.ceil(b._orig_damage_min * f)
			b.damage_max = math.ceil(b._orig_damage_max * f)
		end
	end

	return true
end

sys.game_upgrades_6 = {}
sys.game_upgrades_6.name = "game_upgrades_6"

local game_upgrades_6_ultimate_by_template = {
	tower_archers_lvl4 = "archers_ulti",
	tower_ranger_lvl4 = "archers_ulti",
	tower_crossbows_lvl4 = "archers_ulti",
	tower_sniper_lvl4 = "archers_ulti",
	soldier_knights_lvl4 = "barracks_ulti",
	tower_wildcat_lvl4 = "barracks_ulti",
	tower_miners_lvl4 = "barracks_ulti",
	tower_wizard_lvl4 = "mages_ulti",
	tower_sunray_master_lvl4 = "mages_ulti",
	tower_light_priestess_lvl4 = "mages_ulti",
	tower_forger_lvl4 = "mages_ulti",
	tower_catapult_lvl4 = "artillery_ulti",
	tower_culverine_lvl4 = "artillery_ulti",
	tower_tree_lvl4 = "artillery_ulti",
	tower_alchemist_lvl4 = "artillery_ulti"
}

local function game_upgrades_6_set_ultimate_active(entity, store)
	local upgrade_key = game_upgrades_6_ultimate_by_template[entity.template_name]
	local ultimate = entity.powers and entity.powers.ultimate

	if upgrade_key and ultimate then
		ultimate.active = store.game_upgrades_6_data.ultimates[upgrade_key] == true
	end
end

local function game_upgrades_6_set_mage_damage(upgrade, factor)
	for _, template_name in ipairs(upgrade.bullet_names or {}) do
		local template = E.entities[template_name]
		local damage = template and (template.bullet or template.aura)

		if damage then
			damage._mages_l4b_damage_min = damage._mages_l4b_damage_min or damage.damage_min
			damage._mages_l4b_damage_max = damage._mages_l4b_damage_max or damage.damage_max
			damage.damage_min = math.ceil(damage._mages_l4b_damage_min * factor)
			damage.damage_max = math.ceil(damage._mages_l4b_damage_max * factor)
		end
	end
end

local function game_upgrades_6_count_mages(store, tower_types)
	local count = 0

	for _, entity in pairs(store.entities) do
		if entity.tower and table.contains(tower_types, entity.tower.type) then
			count = count + 1
		end
	end

	return count
end

function sys.game_upgrades_6:init(store)
	local upgrade = UP:get_upgrade("mages_l4b")

	store.game_upgrades_6_data = {
		ultimates = {}
	}

	for _, upgrade_key in pairs(game_upgrades_6_ultimate_by_template) do
		if store.game_upgrades_6_data.ultimates[upgrade_key] == nil then
			store.game_upgrades_6_data.ultimates[upgrade_key] = UP:get_upgrade(upgrade_key) ~= nil
		end
	end

	if upgrade then
		for _, template_name in ipairs(upgrade.bullet_names or {}) do
			local template = E.entities[template_name]
			local damage = template and (template.bullet or template.aura)

			if damage then
				damage._mages_l4b_damage_min = damage.damage_min
				damage._mages_l4b_damage_max = damage.damage_max
			end
		end
	end
end

function sys.game_upgrades_6:on_insert(entity, store)
	local upgrade = UP:get_upgrade("mages_l4b")
	local tower_types = upgrade and (upgrade.count_tower_types or upgrade.tower_types)

	game_upgrades_6_set_ultimate_active(entity, store)

	if upgrade and entity.tower and table.contains(tower_types, entity.tower.type) then
		local count = game_upgrades_6_count_mages(store, tower_types) + 1
		local factor = upgrade.damage_factors[km.clamp(1, #upgrade.damage_factors, count)]

		game_upgrades_6_set_mage_damage(upgrade, factor)
	end

	return true
end

function sys.game_upgrades_6:on_remove(entity, store)
	local upgrade = UP:get_upgrade("mages_l4b")
	local tower_types = upgrade and (upgrade.count_tower_types or upgrade.tower_types)

	if upgrade and entity.tower and table.contains(tower_types, entity.tower.type) then
		local count = math.max(0, game_upgrades_6_count_mages(store, tower_types) - 1)
		local factor = upgrade.damage_factors[km.clamp(1, #upgrade.damage_factors, count)]

		game_upgrades_6_set_mage_damage(upgrade, factor)
	end

	return true
end

sys.main_script = {}
sys.main_script.name = "main_script"

local function main_script_init_lists(store)
	store.entities_with_main_script_on_update_count = 0
	store.entities_with_main_script_on_update = {}
	store.entities_with_main_script_on_update_index = {}
	store.entities_with_main_script_on_update_count1 = 0
	store.entities_with_main_script_on_update1 = {}
	store.entities_with_main_script_on_update_index1 = {}
end

local function main_script_register_update(store, entity)
	local s = entity.main_script

	if not s or not s.update then
		return
	end

	if s.type == 1 then
		if store.entities_with_main_script_on_update_index1[entity.id] then
			return
		end

		store.entities_with_main_script_on_update_count1 = store.entities_with_main_script_on_update_count1 + 1
		store.entities_with_main_script_on_update1[store.entities_with_main_script_on_update_count1] = entity
		store.entities_with_main_script_on_update_index1[entity.id] = store.entities_with_main_script_on_update_count1
	else
		if store.entities_with_main_script_on_update_index[entity.id] then
			return
		end

		store.entities_with_main_script_on_update_count = store.entities_with_main_script_on_update_count + 1
		store.entities_with_main_script_on_update[store.entities_with_main_script_on_update_count] = entity
		store.entities_with_main_script_on_update_index[entity.id] = store.entities_with_main_script_on_update_count
	end
end

local function main_script_unregister_update(store, entity)
	local s = entity.main_script

	if not s or not s.update then
		return
	end

	if s.type == 1 then
		local index = store.entities_with_main_script_on_update_index1[entity.id]

		if not index then
			return
		end

		local count = store.entities_with_main_script_on_update_count1
		local last_entity = store.entities_with_main_script_on_update1[count]

		store.entities_with_main_script_on_update1[index] = last_entity

		if last_entity then
			store.entities_with_main_script_on_update_index1[last_entity.id] = index
		end

		store.entities_with_main_script_on_update1[count] = nil
		store.entities_with_main_script_on_update_index1[entity.id] = nil
		store.entities_with_main_script_on_update_count1 = count - 1
	else
		local index = store.entities_with_main_script_on_update_index[entity.id]

		if not index then
			return
		end

		local count = store.entities_with_main_script_on_update_count
		local last_entity = store.entities_with_main_script_on_update[count]

		store.entities_with_main_script_on_update[index] = last_entity

		if last_entity then
			store.entities_with_main_script_on_update_index[last_entity.id] = index
		end

		store.entities_with_main_script_on_update[count] = nil
		store.entities_with_main_script_on_update_index[entity.id] = nil
		store.entities_with_main_script_on_update_count = count - 1
	end
end

function sys.main_script:init(store)
	main_script_init_lists(store)
	store._dominant_entity = nil
end

function sys.main_script:on_queue(entity, store, insertion)
	if insertion then
		combat_stats_bind_entity(store, entity)
	end

	if entity.main_script and entity.main_script.queue then
		local previous = store._dominant_entity

		store._dominant_entity = entity
		entity.main_script.queue(entity, store, insertion)
		store._dominant_entity = previous
	end
end

function sys.main_script:on_dequeue(entity, store, insertion)
	if entity.main_script and entity.main_script.dequeue then
		local previous = store._dominant_entity

		store._dominant_entity = entity
		entity.main_script.dequeue(entity, store, insertion)
		store._dominant_entity = previous
	end
end

function sys.main_script:on_insert(entity, store)
	if entity.main_script and entity.main_script.insert then
		local previous = store._dominant_entity

		store._dominant_entity = entity

		local result = entity.main_script.insert(entity, store, entity.main_script)

		store._dominant_entity = previous

		return result
	else
		return true
	end
end

function sys.main_script:on_insert_unconditional(entity, store)
	main_script_register_update(store, entity)
end

function sys.main_script:on_update(dt, ts, store)
	for i = 1, store.entities_with_main_script_on_update_count do
		local e = store.entities_with_main_script_on_update[i]
		local s = e.main_script

		if not s.update then
			-- block empty
		else
			if not s.co and s.runs ~= 0 then
				s.runs = s.runs - 1
				s.co = coroutine.create(s.update)
			end

			if s.co then
				local previous = store._dominant_entity

				store._dominant_entity = e

				local success, error = coroutine.resume(s.co, e, store, s)

				store._dominant_entity = previous

				if coroutine.status(s.co) == "dead" and not success and error ~= nil or (not success and error ~= nil) then
					if debug.traceback(s.co, error) ~= "cannot resume dead coroutine\nstack traceback:" then
						
						log.error("Error running coro: %s", debug.traceback(s.co, error))
					end
					s.co = nil
				end
			end
		end
	end

	for i = 1, store.entities_with_main_script_on_update_count1 do
		local e = store.entities_with_main_script_on_update1[i]
		local s = e.main_script

		if s and s.update then
			local previous = store._dominant_entity

			store._dominant_entity = e
			s.update(e, store, s)
			store._dominant_entity = previous
		end
	end
end

function sys.main_script:on_remove(entity, store)
	if entity.main_script and entity.main_script.remove then
		local previous = store._dominant_entity

		store._dominant_entity = entity

		local result = entity.main_script.remove(entity, store, entity.main_script)

		store._dominant_entity = previous

		return result
	else
		return true
	end
end

function sys.main_script:on_remove_unconditional(entity, store)
	main_script_unregister_update(store, entity)
end

sys.health = {}
sys.health.name = "health"

function sys.health:init(store)
	store.damage_queue = {}
	store.damage_queue_swapper = {}
	store.combat_stats = {
		by_source = {},
		source_meta = {},
		fallback_rows = {},
		retired_source_ids = {{}, {}, {}, {}},
		total_damage = 0,
		total_kills = 0
	}
	store.earnings_stats = {by_source = {}, total = 0}

	local slot = storage:load_slot()

	store.enemy_wave_health_growth_level = enemy_enhance.level(slot.xingyu and slot.xingyu.balance)
end

function sys.health:on_remove_unconditional(entity, store)
	combat_stats_retire_entity(store, entity)
end

function sys.health:on_insert(entity, store)
	if entity.enemy and entity.health and not entity.health._wave_health_growth_done then
		entity.health._wave_health_growth_done = true

		if store.enemy_wave_health_growth_level > 0 and (store.wave_group_number or 0) >= 6 then
			local factor = enemy_enhance.wave_health_factor(store.enemy_wave_health_growth_level, store.wave_group_number)

			entity.health.hp_max = math.floor(entity.health.hp_max * factor + 0.5)

			if entity.health.hp then
				entity.health.hp = math.floor(entity.health.hp * factor + 0.5)
			end
		end
	end

	if entity.health and not entity.health.hp then
		entity.health.hp = entity.health.hp_max
	end

	return true
end

function sys.health:on_update(dt, ts, store)
	local damage_queue = store.damage_queue
	local next_damage_queue = store.damage_queue_swapper

	for i = #next_damage_queue, 1, -1 do
		next_damage_queue[i] = nil
	end

	local damage_queue_len = #damage_queue

	for i = damage_queue_len, 1, -1 do
		local d = damage_queue[i]

		if d.damage_applied == nil then
			d.damage_applied = 0

			local e = store.entities[d.target_id]

			if not e then
				-- block empty
			else
				local h = e.health

				if not h.dead and band(d.damage_type, DAMAGE_SPIKED_ARMOR) == 0 then
					local source = store.entities[d.source_id]
					if source then
						if e and h.dark_spiked_armor and e.soldier and e.soldier.target_id and not source.bullet and not source.dps then
							local t = store.entities[e.soldier.target_id]
							if t and t.health and not t.health.dead then
								local sad = E:create_damage()

								sad.damage_type = bor(h.dark_damage_type, DAMAGE_NO_DODGE, DAMAGE_SPIKED_ARMOR)
								sad.value = h.dark_spiked_armor
								sad.source_id = e.id
								sad.target_id = t.id

								next_damage_queue[#next_damage_queue + 1] = sad
							end
						end
					elseif e and h.dark_spiked_armor and e.soldier and e.soldier.target_id then
						local t = store.entities[e.soldier.target_id]
						if t and t.health and not t.health.dead then
							local sad = E:create_damage()

							sad.damage_type = bor(h.dark_damage_type, DAMAGE_NO_DODGE, DAMAGE_SPIKED_ARMOR)
							sad.value = h.dark_spiked_armor
							sad.source_id = e.id
							sad.target_id = t.id

							next_damage_queue[#next_damage_queue + 1] = sad
						end
					end
				end 

				-- Innate allied-boss immunity survives buffs that reset health.immune_to.
				local execution_immune = e.boss_kind and band(d.damage_type, bor(DAMAGE_INSTAKILL, DAMAGE_EAT)) ~= 0
				if h.dead or execution_immune or (h.immune_to and band(h.immune_to, d.damage_type) ~= 0) or h.ignore_damage or h.on_damage and not h.on_damage(e, store, d) then
					log_hp.paranoid("entity: (%s) %s dead:%s - ignoring damage: \n%s", e.id, e.template_name, e.health.dead, getfulldump(d))
				else
					local starting_hp = h.hp

					h.last_damage_types = bor(h.last_damage_types, d.damage_type)

					log_hp.paranoid("(%s) %s - last_damage_types: %x", e.id, e.template_name, d.damage_type)

					if band(d.damage_type, bor(DAMAGE_INSTAKILL, DAMAGE_EAT)) ~= 0 then
						d.damage_applied = h.hp
						d.damage_result = bor(d.damage_result, DR_KILL)
						h.hp = 0
					elseif band(d.damage_type, DAMAGE_ARMOR) ~= 0 then
						SU.armor_dec(e, d.value)

						d.damage_result = bor(d.damage_result, DR_ARMOR)
					elseif band(d.damage_type, DAMAGE_MAGICAL_ARMOR) ~= 0 then
						SU.magic_armor_dec(e, d.value)

						d.damage_result = bor(d.damage_result, DR_MAGICAL_ARMOR)
					else
						local source=store.entities[d.source_id]
						local dealer=source and source.modifier and store.entities[source.modifier.source_id] or source
						if dealer and dealer.unit and dealer.unit.prepare_damage then dealer.unit.prepare_damage(dealer,e,store,d) end
						local actual_damage = U.predict_damage(e, d)

						h.hp = h.hp - actual_damage

						if band(d.damage_type, DAMAGE_NO_KILL) ~= 0 and starting_hp > 0 and h.hp < 1 then
							actual_damage = math.max(0, starting_hp - 1)
							h.hp = 1
						elseif e.enemy and actual_damage > 0 and h.hp > 0 and h.hp < 1 then
							actual_damage = starting_hp
							h.hp = 0
						end

						d.damage_applied = actual_damage

						log_hp.paranoid("(%s) %s - damage_applied: %s", e.id, e.template_name, actual_damage)

						if starting_hp > 0 and h.hp <= 0 then
							d.damage_result = bor(d.damage_result, DR_KILL)
						end

						if actual_damage > 0 then
							d.damage_result = bor(d.damage_result, DR_DAMAGE)
							h.last_damage_source_id = d.source_id
							local source=store.entities[d.source_id]
							local dealer=source and source.modifier and store.entities[source.modifier.source_id] or source
							if starting_hp>0 and dealer and dealer.unit and dealer.unit.on_damage_dealt then
								dealer.unit.on_damage_dealt(dealer,e,store,d,math.min(actual_damage,starting_hp),dealer==source)
							end

							if e.regen then
								e.regen.last_hit_ts = store.tick_ts
							end

							if d.track_damage then
								signal.emit("entity-damaged", e, d)

								local source = store.entities[d.source_id]

								if source and source.track_damage then
									table.insert(source.track_damage.damaged, {
										e.id,
										actual_damage
									})
								end
							end
						end

						if e and h.spiked_armor and h.spiked_armor > 0 and band(d.damage_type, DAMAGE_SPIKED_ARMOR) == 0 then
							local reflected_target

							if e.soldier and e.soldier.target_id then
								reflected_target = store.entities[e.soldier.target_id]
							elseif e.enemy and e.enemy.blockers and d.source_id and table.contains(e.enemy.blockers, d.source_id) then
								local source = store.entities[d.source_id]

								if source and source.soldier then
									reflected_target = source
								end
							end

							if reflected_target and reflected_target.health and not reflected_target.health.dead then
								local sad = E:create_damage()

								sad.damage_type = bor(DAMAGE_TRUE, DAMAGE_SPIKED_ARMOR)
								sad.value = math.ceil(h.spiked_armor * d.value)
								sad.source_id = e.id
								sad.target_id = reflected_target.id

								next_damage_queue[#next_damage_queue + 1] = sad
							end
						end
						
						if e and h.accumulated_damage_factor > 0 then
							h.accumulated_damage = h.accumulated_damage + km.round(actual_damage * h.accumulated_damage_factor)
						end
					end

					local killed = starting_hp > 0 and h.hp <= 0

					combat_stats_record(store, d, e, d.damage_applied, killed)

					if killed then
						signal.emit("entity-killed", e, d)

						if d.track_kills then
							local source = store.entities[d.source_id]

							if source and source.track_kills then
								table.insert(source.track_kills.killed, e.id)
							end
						end
					end
				end
			end

			next_damage_queue[#next_damage_queue + 1] = d
		end
	end

	for i = damage_queue_len + 1, #damage_queue do
		next_damage_queue[#next_damage_queue + 1] = damage_queue[i]
	end

	store.damage_queue_swapper = damage_queue
	store.damage_queue = next_damage_queue

	combat_stats_clear_retired(store)

	for _, e in E:filter_iter(store.entities, "health") do
		local h = e.health

		if e.enemy and not h.ignore_damage and h.hp > 0 and h.hp < 1 then
			h.hp = 0
		end

		if h.hp <= 0 and not h.dead and not h.ignore_damage then
			h.hp = 0
			h.dead = true
			h.death_ts = store.tick_ts
			h.delete_after = store.tick_ts + h.dead_lifetime

			if e.health_bar then
				e.health_bar.hidden = true
			end

			if e.enemy then
				local gold_factor = store.level_mode_6 and GS.gold_enemy_factor_per_mode_6[store.level_mode_6] or 1
				local obtained_gold = e.enemy.gold * gold_factor

				store.player_gold = store.player_gold + obtained_gold
				earnings_stats.record_enemy_payout(store, e, obtained_gold)

				signal.emit("got-enemy-gold", e, obtained_gold)
			end

			if e.enemy and e.enemy.gems > 0 then
				store.gems_collected = store.gems_collected + e.enemy.gems

				signal.emit("show-gems-reward", e, e.enemy.gems)
			end

			if e.enemy and store.level_mode == GAME_MODE_ENDLESS then
				local conf = W:get_endless_score_config()
				local score = (1 + math.max(h.armor, h.magic_armor)) * h.hp_max * conf.scoreEnemyMultiplier

				if e.motion then
					score = score * e.motion.max_speed / FPS
				end

				score = km.round(score)
				store.player_score = store.player_score + score

				log.debug("ENDLESS: kill score %s (%s)%s - armor:%s magic_armor:%s hp_max:%s speed:%s", score, e.id, e.template_name, h.armor, h.magic_armor, h.hp_max, e.motion and e.motion.max_speed or 0)
			end
		end

		if not h.dead then
			h.last_damage_types = 0
			e._allied_corpse_claimed = nil
		end

		if h.dead and not e.hero and not h.ignore_delete_after and (h.delete_after and store.tick_ts > h.delete_after or h.delete_now) then
			queue_remove(store, e)
		end
	end
end

sys.count_groups = {}
sys.count_groups.name = "count_groups"

function sys.count_groups:init(store)
	store.count_groups = {}
	store.count_groups[COUNT_GROUP_CONCURRENT] = {}
	store.count_groups[COUNT_GROUP_CUMULATIVE] = {}
end

function sys.count_groups:on_queue(entity, store, insertion)
	if insertion and entity.count_group then
		local c = entity.count_group

		if c.in_limbo then
			c.in_limbo = nil

			return true
		end

		local g = store.count_groups

		if not g[c.type][c.name] then
			g[c.type][c.name] = 0
		end

		g[c.type][c.name] = g[c.type][c.name] + 1

		signal.emit("count-group-changed", entity, g[c.type][c.name], 1)
	end
end

function sys.count_groups:on_dequeue(entity, store, insertion)
	if insertion then
		self:on_remove(entity, store)
	end
end

function sys.count_groups:on_remove(entity, store)
	if entity.count_group and not entity.count_group.in_limbo and entity.count_group.type == COUNT_GROUP_CONCURRENT then
		local c = entity.count_group
		local g = store.count_groups

		g[c.type][c.name] = km.clamp(0, 1000000000, g[c.type][c.name] - 1)

		signal.emit("count-group-changed", entity, g[c.type][c.name], -1)
	end

	return true
end

sys.hero_xp_tracking = {}
sys.hero_xp_tracking.name = "hero_xp_tracking"

function sys.hero_xp_tracking:on_update(dt, ts, store)
	for _, d in pairs(store.damage_queue) do
		if d.xp_gain_factor and d.xp_gain_factor > 0 and d.damage_applied and d.damage_applied > 0 then
			local id = d.xp_dest_id or d.source_id
			local e = store.entities[id]

			if not e or not e.hero then
				-- block empty
			else
				local amount = d.damage_applied * d.xp_gain_factor

				e.hero.xp_queued = e.hero.xp_queued + amount

				if log_xp.level >= log_xp.DEBUG_LEVEL then
					local t = store.entities[d.target_id]

					log_xp.debug("XP QUEUE DAMAGE: (%s)%s xp:%.2f damage:%.2f factor:%.2f to:(%s)%s via:%s", e.id, e.template_name, amount, d.damage_applied, d.xp_gain_factor, d.target_id, t and t.template_name or "?", d.source_id)
				end
			end
		end
	end
end

sys.pops = {}
sys.pops.name = "pops"

function sys.pops:on_update(dt, ts, store)
	for _, d in pairs(store.damage_queue) do
		if not d.pop or not d.target_id then
			-- block empty
		else
			local source = store.entities[d.source_id]
			local target = store.entities[d.target_id]
			local pop_entity

			if source and (source.enemy or source.soldier) then
				pop_entity = source
			elseif target then
				pop_entity = target
			else
				goto label_37_0
			end

			if (not d.pop_chance or math.random() < d.pop_chance) and (not d.pop_conds or band(d.damage_result, d.pop_conds) ~= 0) then
				local name = d.pop[math.random(1, #d.pop)]
				local e = E:create_entity(name)

				if e.pop_over_target and target then
					pop_entity = target
				end

				e.pos = V.v(pop_entity.pos.x, pop_entity.pos.y)

				if pop_entity.unit and pop_entity.unit.pop_offset then
					e.pos.y = e.pos.y + pop_entity.unit.pop_offset.y
				elseif pop_entity == target and pop_entity.unit and pop_entity.unit.hit_offset then
					e.pos.y = e.pos.y + pop_entity.unit.hit_offset.y
				end

				e.pos.y = e.pos.y + e.pop_y_offset
				e.render.sprites[1].r = math.random(-21, 21) * math.pi / 180
				e.render.sprites[1].ts = store.tick_ts

				queue_insert(store, e)
			end
		end

		::label_37_0::
	end
end

sys.timed = {}
sys.timed.name = "timed"

function sys.timed:on_render_update(dt, ts, store)
	for _, e in E:filter_iter(store.entities, "timed") do
		local s = e.render.sprites[e.timed.sprite_id]

		if e.timed.disabled then
			-- block empty
		elseif not s or s._animation_missing then
			queue_remove(store, e)
		elseif s.ts == store.tick_ts then
			-- block empty
		elseif e.timed.runs and (s.runs or 0) >= e.timed.runs or e.timed.duration and store.tick_ts - s.ts > e.timed.duration then
			queue_remove(store, e)
		end
	end
end

sys.tween = {}
sys.tween.name = "tween"

function sys.tween:on_insert(entity, store)
	if entity.tween then
		for _, p in pairs(entity.tween.props) do
			for _, n in pairs(p.keys) do
				for i = 1, 2 do
					if type(n[i]) == "string" then
						local nf = loadstring("return " .. n[i])
						local env = {}

						env.this = entity
						env.store = store
						env.math = math
						env.U = U
						env.V = V

						setfenv(nf, env)

						n[i] = nf()
					end
				end
			end
		end

		if entity.tween.random_ts then
			entity.tween.ts = U.frandom(-1 * entity.tween.random_ts, 0)
		end
	end

	return true
end

function sys.tween:on_render_update(dt, ts, store)
	local fns = {}

	function fns.step(s)
		return 0
	end

	function fns.linear(s)
		return s
	end

	function fns.quad(s)
		return s * s
	end

	function fns.sine(s)
		return 0.5 * (1 - math.cos(s * math.pi))
	end

	local function lerp(a, b, t, fn)
		fn = fn or "linear"

		local ta = type(a)

		if ta == "table" then
			return V.v(lerp(a.x, b.x, t, fn), lerp(a.y, b.y, t, fn))
		elseif ta == "boolean" then
			return a
		else
			return a + (b - a) * fns[fn](t)
		end
	end

	for _, e in E:filter_iter(store.entities, "tween") do
		if e.tween.disabled then
			-- block empty
		else
			local finished = true

			for _, t in pairs(e.tween.props) do
				if t.disabled then
					-- block empty
				else
					local sids = type(t.sprite_id) == "table" and t.sprite_id or {
						t.sprite_id
					}

					for _, sid in pairs(sids) do
						local value
						local s = e.render.sprites[sid]
						local keys = t.keys
						local ka = keys[1]
						local kb = keys[#keys]
						local start_time = keys[1][1]
						local end_time = keys[#keys][1]
						local duration = end_time - start_time
						local time_ref = t.ts or e.tween.ts or s.ts
						local time = store.tick_ts - time_ref

						if t.time_offset then
							time = time + t.time_offset
						end

						if t.loop then
							time = time % duration
						end

						if e.tween.reverse and not t.ignore_reverse then
							time = duration - time
						end

						time = km.clamp(start_time, end_time, time)

						for i = 1, #keys do
							local ki = keys[i]

							if time >= ki[1] then
								ka = ki
							end

							if time <= ki[1] then
								kb = ki

								break
							end
						end

						if ka == kb then
							value = ka[2]
						else
							value = lerp(ka[2], kb[2], (time - ka[1]) / (kb[1] - ka[1]), ka[3] or t.interp)
						end

						if t.multiply then
							if type(value) == "boolean" then
								s[t.name] = value and s[t.name]
							elseif type(value) == "table" then
								s[t.name].x = value.x * s[t.name].x
								s[t.name].y = value.y * s[t.name].y
							else
								s[t.name] = value * s[t.name]
							end
						else
							s[t.name] = value
						end

						if t.loop then
							finished = finished and t.loop
						elseif e.tween.reverse then
							finished = finished and kb == keys[1]
						else
							finished = finished and ka == keys[#keys]
						end
					end
				end
			end

			if finished then
				if e.tween.remove then
					queue_remove(store, e)
				end

				if e.tween.run_once then
					e.tween.disabled = true
				end
			end
		end
	end
end

sys.goal_line = {}
sys.goal_line.name = "goal_line"

function sys.goal_line:on_update(dt, ts, store)
	for _, e in E:filter_iter(store.entities, "nav_path") do
		local node_index = e.nav_path.ni
		local end_node = P:get_end_node(e.nav_path.pi)

		if end_node <= node_index and not P.path_connections[e.nav_path.pi] and e.enemy and e.enemy.remove_at_goal_line then
			log.debug("enemy %s reached goal", e.id)
			signal.emit("enemy-reached-goal", e)

			store.lives = km.clamp(0, 10000, store.lives - e.enemy.lives_cost)
			local gold_factor = store.level_mode_6 and GS.gold_enemy_factor_per_mode_6[store.level_mode_6] or 1
			local obtained_gold = e.enemy.gold * gold_factor
			store.player_gold = store.player_gold + obtained_gold
			earnings_stats.record_enemy_payout(store, e, obtained_gold)
			local handlers = store.event_handlers and store.event_handlers["enemy-reached-goal"]

			if handlers then
				for _, ev in ipairs(handlers) do
					local owner = store.entities[ev.entity_id]

					if owner then
						ev.on_event(owner, store, ev.name, e)
					end
				end
			end

			queue_remove(store, e)
		end
	end
end

sys.texts = {}
sys.texts.name = "texts"

local text_cache = {}
local text_cache_count, text_cache_bytes, text_serial = 0, 0, 0
local TEXT_CACHE_LIMIT, TEXT_CACHE_BYTES = 128, 8 * 1024 * 1024

local function text_cache_key(t, scale)
	local c = t.color
	return table.concat({string.format("%q", t.text), t.size.x, t.size.y,
		string.format("%q", t.alignment), string.format("%q", t.font_name), t.font_size,
		c[1], c[2], c[3], c[4] or 255, t.line_height or 1, scale or 1,
		tostring(t.fit_height), tostring(t.debug_bg)}, "|")
end

function sys.texts:clear_cache()
	for _, entry in pairs(text_cache) do I:remove_image(entry.name) end
	text_cache = {}
	text_cache_count, text_cache_bytes = 0, 0
end

function sys.texts:on_insert(entity, store)
	if entity.texts then
		for _, t in pairs(entity.texts.list) do
			local key = text_cache_key(t, store.screen_scale)
			local entry = text_cache[key]
			if not entry then
				-- Font rendering scales its size argument in place; keep entity data intact.
				local size = {x = t.size.x, y = t.size.y}
				local image = F:create_text_image(t.text, size, t.alignment, t.font_name, t.font_size, t.color, t.line_height, store.screen_scale, t.fit_height, t.debug_bg)
				local w, h = image:getDimensions()
				local bytes = w * h * 4
				if bytes <= TEXT_CACHE_BYTES then
					for old_key, old in pairs(text_cache) do
						if text_cache_count < TEXT_CACHE_LIMIT and text_cache_bytes + bytes <= TEXT_CACHE_BYTES then break end
						if old.refs == 0 then
							I:remove_image(old.name)
							text_cache[old_key] = nil
							text_cache_count = text_cache_count - 1
							text_cache_bytes = text_cache_bytes - old.bytes
						end
					end
				end
				text_serial = text_serial + 1
				entry = {name = "textcache_" .. text_serial, refs = 0, bytes = bytes}
				I:add_image(entry.name, image, "temp_game_texts", store.screen_scale)
				if text_cache_count < TEXT_CACHE_LIMIT and text_cache_bytes + bytes <= TEXT_CACHE_BYTES then
					text_cache[key] = entry
					text_cache_count = text_cache_count + 1
					text_cache_bytes = text_cache_bytes + bytes
				end
			end
			entry.refs = entry.refs + 1
			t.image_name = entry.name
			t.image_cache_key = text_cache[key] == entry and key or nil
			t.image_group = "texts"
			entity.render.sprites[t.sprite_id].name = entry.name
			entity.render.sprites[t.sprite_id].animated = false
		end
	end
	return true
end

function sys.texts:on_remove(entity, store)
	if entity.texts then
		for _, t in pairs(entity.texts.list) do
			local entry = t.image_cache_key and text_cache[t.image_cache_key]
			if entry and entry.name == t.image_name then
				entry.refs = math.max(0, entry.refs - 1)
			elseif t.image_name then
				I:remove_image(t.image_name)
			end
			t.image_name, t.image_cache_key = nil, nil
		end
	end
	return true
end


sys.particle_system = {}
sys.particle_system.name = "particle_system"

function sys.particle_system:on_insert(entity, store)
	if entity.particle_system then
		local s = entity.particle_system

		s.emit_ts = (s.emit_ts and s.emit_ts or store.tick_ts) + s.ts_offset
		s.ts = store.tick_ts
		s.last_pos = {
			x = 0,
			y = 0
		}
	end

	return true
end

function sys.particle_system:on_remove(entity, store)
	if entity.particle_system then
		local s = entity.particle_system

		for i = #s.particles, 1, -1 do
			local p = entity.particle_system.particles[i]
			p.f.marked_to_remove = true
            s.particles[i] = nil
			--table.removeobject(s.particles, p)
			--table.removeobject(store.render_frames, p.f)
		end
	end

	return true
end

local function particle_new_frame(draw_order, z, sort_y_offset, sort_y)
	local f = {
		ss = nil,
		flip_x = false,
		flip_y = false,
		pos = {
			x = 0,
			y = 0
		},
		r = 0,
		scale = {
			x = 1,
			y = 1
		},
		anchor = {
			x = 0.5,
			y = 0.5
		},
		offset = {
			x = 0,
			y = 0
		},
		_draw_order = draw_order,
		z = z,
		sort_y = sort_y,
		sort_y_offset = sort_y_offset,
		alpha = 255,
		hidden = nil,
	}
	return f
end

local function particle_new_particle(ts)
	local p = {
		pos = {
			x = 0,
			y = 0
		},
		r = 0,
		speed = {
			x = 0,
			y = 0
		},
		spin = 0,
		scale_factor = {
			x = 1,
			y = 1
		},
		ts = ts,
		last_ts = ts,
	}
	return p
end

local function particle_phase_interp(values, phase, default)
	if not values or #values == 0 then
		return default
	end

	if #values == 1 then
		return values[1]
	end

	local intervals = #values - 1
	local interval = math.floor(phase * intervals)
	local interval_phase = phase * intervals - interval
	local a = values[interval + 1]
	local b = values[interval + 2]
	local ta = type(a)

	if ta == "table" then
		local out = {}

		for i = 1, #a do
			out[i] = a[i] + (b[i] - a[i]) * interval_phase
		end

		return out
	elseif ta == "boolean" then
		return a
	elseif a ~= nil and b ~= nil then
		return a + (b - a) * interval_phase
	else
		log.error("sys.particle_system:update phase_interp has nil values in %s", getdump(values))

		return default
	end
end

function sys.particle_system:on_render_update(dt, ts, store)

	for _, e in E:filter_iter(store.entities, "particle_system") do
		local s = e.particle_system
		local target, target_rot

		if s.track_id then
			target = store.entities[s.track_id]

			if target then
				s.last_pos.x, s.last_pos.y = e.pos.x, e.pos.y
				e.pos.x, e.pos.y = target.pos.x, target.pos.y

				if s.track_offset then
					e.pos.x, e.pos.y = e.pos.x + s.track_offset.x, e.pos.y + s.track_offset.y
				end

				if target.render and target.render.sprites[1] then
					target_rot = target.render.sprites[1].r
				end
			else
				s.emit = false
				s.source_lifetime = 0
			end
		end

		if s.emit_duration and s.emit then
			if not s.emit_duration_ts then
				s.emit_duration_ts = store.tick_ts
			end

			if store.tick_ts - s.emit_duration_ts > s.emit_duration then
				s.emit = false
			end
		end

		if not s.emit then
			s.emit_ts = store.tick_ts + s.ts_offset
		end

		if s.emit and ts - s.emit_ts > 1 / s.emission_rate then
			local count = math.floor((ts - s.emit_ts) * s.emission_rate)

			for i = 1, count do
				local pts = s.emit_ts + i * 1 / s.emission_rate
				local draw_order = s.draw_order and 100000 * s.draw_order + e.id or math.floor(pts * 100)
				local f = particle_new_frame(draw_order, s.z, s.sort_y_offset, s.sort_y)

				table.insert(store.render_frames, f)

				local p = particle_new_particle(pts)

				f.anchor.x, f.anchor.y = s.anchor.x, s.anchor.y

				table.insert(s.particles, p)

				p.f = f
				p.lifetime = U.frandom(s.particle_lifetime[1], s.particle_lifetime[2])

				if s.track_id then
					local stepx = (e.pos.x - s.last_pos.x) / count
					local stepy = (e.pos.y - s.last_pos.y) / count

					p.pos.x, p.pos.y = s.last_pos.x + stepx * (i - 1), s.last_pos.y + stepy * (i - 1)
				else
					p.pos.x, p.pos.y = e.pos.x, e.pos.y
				end

				if s.emit_area_spread then
					local sp = s.emit_area_spread

					p.pos.x = p.pos.x + U.frandom(-sp.x / 2, sp.x / 2)
					p.pos.y = p.pos.y + U.frandom(-sp.y / 2, sp.y / 2)
				end

				if s.emit_offset then
					p.pos.x = p.pos.x + s.emit_offset.x
					p.pos.y = p.pos.y + s.emit_offset.y
				end

				if s.emit_speed then
					p.speed.x, p.speed.y = V.rotate(s.emit_direction + U.frandom(-s.emit_spread, s.emit_spread), U.frandom(s.emit_speed[1], s.emit_speed[2]), 0)
				end

				if s.emit_rotation then
					p.r = s.emit_rotation
				elseif s.track_rotation and target_rot then
					p.r = target_rot
				else
					p.r = s.emit_direction + U.frandom(-s.emit_rotation_spread, s.emit_rotation_spread)
				end

				if s.spin then
					p.spin = U.frandom(s.spin[1], s.spin[2])
				end

				if s.scale_var then
					local factor = U.frandom(s.scale_var[1], s.scale_var[2])

					p.scale_factor = V.v(factor, factor)

					if not s.scale_same_aspect then
						p.scale_factor.y = U.frandom(s.scale_var[1], s.scale_var[2])
					end
				end

				if s.names then
					if s.cycle_names then
						if not s._last_name_idx then
							s._last_name_idx = 0
						end

						s._last_name_idx = km.zmod(s._last_name_idx + 1, #s.names)
						p.name_idx = s._last_name_idx
					else
						p.name_idx = math.random(1, #s.names)
					end
				end
			end

			s.emit_ts = s.emit_ts + count * 1 / s.emission_rate
		end

		local particles = s.particles

		for i = #particles, 1, -1 do
			local p = particles[i]
			local tp = ts - p.last_ts
			local phase = (ts - p.ts) / p.lifetime

			if phase >= 1 then
				p.f.marked_to_remove = true

				local last = #particles

				particles[i] = particles[last]
				particles[last] = nil
			else
				if phase < 0 then
					phase = 0
				end

				local f = p.f

				p.last_ts = ts
				p.pos.x, p.pos.y = p.pos.x + p.speed.x * tp, p.pos.y + p.speed.y * tp
				f.pos.x, f.pos.y = p.pos.x, p.pos.y
				p.r = p.r + p.spin * tp
				f.r = p.r

				local scale_x = particle_phase_interp(s.scales_x, phase, 1)
				local scale_y = particle_phase_interp(s.scales_y, phase, 1)

				f.scale.x, f.scale.y = scale_x * p.scale_factor.x, scale_y * p.scale_factor.y
				f.alpha = particle_phase_interp(s.alphas, phase, 255)

				if s.sort_y_offsets then
					f.sort_y_offset = particle_phase_interp(s.sort_y_offsets, phase, 1)
				end

				local fn

				if s.animated then
					local to = ts - p.ts

					if s.animation_fps then
						to = to * s.animation_fps / FPS
					end

					if p.name_idx then
						fn = A:fn(s.names[p.name_idx], to, s.loop)
					else
						fn = A:fn(s.name, to, s.loop)
					end
				elseif p.name_idx then
					fn = s.names[p.name_idx]
				else
					fn = s.name
				end

				f.ss = I:s(fn)
			end
		end

		if s.source_lifetime and ts - s.ts > s.source_lifetime then
			s.emit = false

			if #s.particles == 0 then
				queue_remove(store, e)
			end
		end
	end
end

sys.render = {}
sys.render.name = "render"

local ffi = require("ffi")
ffi.cdef [[
typedef struct
{
    double sort_y;
    double pos_x;
    int    z;
    int    draw_order;
    int    lua_index;
} RenderFrameFFI;
typedef struct
{
    float sort_y;
    int   z;
    int   draw_order;
    int   lua_index;
} RenderFrameAndroidFFI;
void ffi_sort(void* arr, void* tmp, int n);
]]

--local lib_render_sort = ffi.load("render_timsort.dll")

local lib_render_sort

local osname = love.system and love.system.getOS and love.system.getOS() or ""
local render_sort_lib_name

if IS_ANDROID then
	render_sort_lib_name = "librender_sort_android.so"
else
	render_sort_lib_name = osname == "Windows" and "render_timsort.dll" or "render_timsort"
end
local ok, load_err = pcall(function()
	lib_render_sort = ffi.load(render_sort_lib_name)
end)

if not ok then
	lib_render_sort = nil
	log.warning("render sort library %s could not be loaded: %s; falling back to Lua ffi_merge_sort", render_sort_lib_name, tostring(load_err))
end

local RENDER_FFI_CAPACITY = 16384

local function render_frame_less(a, b)
	local az = a.z or Z_OBJECTS
	local bz = b.z or Z_OBJECTS

	if az ~= bz then
		return az < bz
	end

	local ay = a.sort_y or (a.sort_y_offset or 0) + (a.pos and a.pos.y or 0)
	local by = b.sort_y or (b.sort_y_offset or 0) + (b.pos and b.pos.y or 0)

	if ay ~= by then
		return ay > by
	end

	local ad = a._draw_order or a.draw_order or 0
	local bd = b._draw_order or b.draw_order or 0

	if ad ~= bd then
		return ad < bd
	end

	return (a.pos and a.pos.x or 0) < (b.pos and b.pos.x or 0)
end

local function render_clear_array(a)
	for i = #a, 1, -1 do
		a[i] = nil
	end
end

local function render_sort_lua_fallback(store)
	local source = store.render_frames
	local sorted = store.render_frames_sorted

	render_clear_array(sorted)

	for i = 1, #source do
		local f = source[i]

		if f and not f.marked_to_remove and f.pos then
			sorted[#sorted + 1] = f
		end
	end

	table.sort(sorted, render_frame_less)
	store.render_frames_sorted = source
	store.render_frames = sorted
end

local function render_android_native_order_valid(a, b)
	if a.z ~= b.z then
		return a.z < b.z
	end

	if a.sort_y ~= b.sort_y then
		return a.sort_y > b.sort_y
	end

	return a.draw_order <= b.draw_order
end

local render_android_sort_warning = {}

local function render_android_sort_warn_once(reason)
	if render_android_sort_warning[reason] then
		return
	end

	render_android_sort_warning[reason] = true
	log.warning("Android native render sort validation failed (%s); using Lua sort for this frame", tostring(reason))
end

local render_desktop_sort_warning = {}

local function render_desktop_sort_warn_once(reason)
	if render_desktop_sort_warning[reason] then
		return
	end

	render_desktop_sort_warning[reason] = true
	log.warning("Desktop native render sort validation failed (%s); using Lua sort for this frame", tostring(reason))
end

local function render_update_sprite_state(s, ts, entity)
	if s._render_state_ts == ts then
		return s._render_frame_name
	end

	local last_runs = s.runs
	local fn, runs, idx
	local is_animated = s.animation or s.animated

	if s.animation then
		fn, runs, idx = A:fni(s.animation, ts - s.ts + s.time_offset, s.loop, s.fps)
	elseif s.animated then
		local full_name = s.prefix and s.prefix .. "_" .. s.name or s.name
		local animation_suffix = entity and entity.animation_suffix

		if animation_suffix and A:has_animation(full_name .. animation_suffix) then
			full_name = full_name .. animation_suffix
		end

		fn, runs, idx = A:fn(full_name, ts - s.ts + s.time_offset, s.loop, s.fps)
		s.frame_name = fn
	else
		fn = s.name
	end

	s.runs = runs or 0
	s.frame_idx = idx or 1
	s._animation_missing = is_animated and not fn or nil

	if s.sync_idx then
		s.sync_flag = s.frame_idx == s.sync_idx
	elseif s.sync_flag == nil then
		s.sync_flag = s.frame_idx == 1
	else
		s.sync_flag = last_runs ~= s.runs
	end

	if s.hide_after_runs and (s.runs or 0) >= s.hide_after_runs then
		s.hidden = true
	end

	s._render_state_ts = ts
	s._render_frame_name = fn

	return fn
end

function sys.render:init(store)
	store.render_frames = {}
	store.render_frames_sorted = {}
	local ffi_frame_type = IS_ANDROID and "RenderFrameAndroidFFI[?]" or "RenderFrameFFI[?]"
	store.render_frames_ffi = ffi.new(ffi_frame_type, RENDER_FFI_CAPACITY)
	store.render_frames_ffi_tmp = ffi.new(ffi_frame_type, RENDER_FFI_CAPACITY)
	store.render_frames_ffi_seen = IS_ANDROID and ffi.new("uint8_t[?]", RENDER_FFI_CAPACITY + 1) or nil
	--local hb_quad = {0,0,1,1,1024,1024}
	local hb_quad = love.graphics.newQuad(unpack(HEALTH_BAR_CORNER_DOT_QUAD))
	--love.graphics.newQuad(unpack({0,0,1,1,1024,1024}))

	self._hb_ss = {
		ref_scale = 1,
		quad = hb_quad,
		trim = {
			0,
			0,
			0,
			0
		},
		size = {
			1,
			1
		},
		atlas = "gui_portraits_20260307"
	}
	self._hb_sizes = HEALTH_BAR_SIZES[store.texture_size] or HEALTH_BAR_SIZES.default
	self._hb_colors = HEALTH_BAR_COLORS

	local function ffi_cmp(a, b)
        if a.z ~= b.z then
            return a.z < b.z
        end
        if a.sort_y ~= b.sort_y then
            return a.sort_y > b.sort_y
        end
        if a.draw_order ~= b.draw_order then
            return a.draw_order < b.draw_order
        end
        return a.pos_x < b.pos_x
    end

	local function ffi_cmp_inverse(a, b)
        if a.z ~= b.z then
            return a.z > b.z
        end
        if a.sort_y ~= b.sort_y then
            return a.sort_y < b.sort_y
        end
        if a.draw_order ~= b.draw_order then
            return a.draw_order > b.draw_order
        end
        return a.pos_x > b.pos_x
    end

    local function ffi_merge_sort(arr, tmp, left, right)
        if right - left <= 1 then
            return
        end
        local mid = floor((left + right) / 2)
        ffi_merge_sort(arr, tmp, left, mid)
        ffi_merge_sort(arr, tmp, mid, right)
        local i, j, k = left, mid, left
        local sizeof_frame = ffi.sizeof("RenderFrameFFI")
        while i < mid and j < right do
            if ffi_cmp(arr[i], arr[j]) then
                ffi.copy(tmp + k, arr + i, sizeof_frame)
                i = i + 1
            else
                ffi.copy(tmp + k, arr + j, sizeof_frame)
                j = j + 1
            end
            k = k + 1
        end
        while i < mid do
            ffi.copy(tmp + k, arr + i, sizeof_frame)
            i = i + 1
            k = k + 1
        end
        while j < right do
            ffi.copy(tmp + k, arr + j, sizeof_frame)
            j = j + 1
            k = k + 1
        end
        for l = left, right - 1 do
            ffi.copy(arr + l, tmp + l, sizeof_frame)
        end
    end

	self.ffi_cmp = ffi_cmp
	self.ffi_sort = ULH.ffi_timsort
end

function sys.render:on_insert(entity, store)
	local render_frames = store.render_frames
	if entity.render then
		for i, s in ipairs(entity.render.sprites) do
			local f = {}

			f.marked_to_remove = false
			f.ss = nil
			f.flip_x = false
			f.flip_y = false
			f.pos = {
				x = 0,
				y = 0
			}
			f.anchor = {
				x = 0,
				y = 0
			}
			f.offset = {
				x = 0,
				y = 0
			}
			f._draw_order = 100000 * (s.draw_order or i) + (entity.id or 0)
			f.z = s.z or Z_OBJECTS
			f.sort_y = s.sort_y
			f.sort_y_offset = s.sort_y_offset

			if s.random_ts then
				s.ts = U.frandom(-1 * s.random_ts, 0)
			end

			if s.color then
				f.color = s.color
			end

			if s.shader then
				f.shader = SH:get(s.shader)
				f.shader_args = s.shader_args
			end

			if entity.render.frames[i] then
				table.removeobject(render_frames, entity.render.frames[i])
			end

			entity.render.frames[i] = f

			table.insert(render_frames, f)
		end
	end

	if entity.health_bar then
		local hb = entity.health_bar
		local fk = hb.black_bar_hp and {} or nil

		if fk then
			fk.flip_x = false
			fk.pos = {
				x = 0,
				y = 0
			}
			fk.r = 0
			fk.alpha = 255
			fk.anchor = {
				x = 0,
				y = 0
			}
			fk.offset = V.vclone(hb.offset)
			fk._draw_order = (hb.draw_order and 100000 * hb.draw_order or 200001) + entity.id
			fk.z = Z_OBJECTS
			fk.sort_y_offset = hb.sort_y_offset
			fk.ss = self._hb_ss
			fk.color = hb.colors and hb.colors.black or self._hb_colors.black

			local hbsize = self._hb_sizes[hb.type]

			fk.bar_width = hbsize.x
			fk.scale = V.v(hbsize.x, hbsize.y)
			fk.offset.x = fk.offset.x - hbsize.x / 2
		end

		local fb = {}

		fb.flip_x = false
		fb.pos = {
			x = 0,
			y = 0
		}
		fb.r = 0
		fb.alpha = 255
		fb.anchor = {
			x = 0,
			y = 0
		}
		fb.offset = V.vclone(hb.offset)
		fb._draw_order = (hb.draw_order and 100000 * hb.draw_order + 1 or 200002) + entity.id
		fb.z = Z_OBJECTS
		fb.sort_y_offset = hb.sort_y_offset
		fb.ss = self._hb_ss
		fb.color = hb.colors and hb.colors.bg or self._hb_colors.bg

		local hbsize = self._hb_sizes[hb.type]

		fb.bar_width = hbsize.x
		fb.scale = V.v(hbsize.x, hbsize.y)
		fb.offset.x = fb.offset.x - hbsize.x * fb.ss.ref_scale / 2

		local ff = {}

		ff.flip_x = false
		ff.pos = {
			x = 0,
			y = 0
		}
		ff.r = 0
		ff.alpha = 255
		ff.anchor = {
			x = 0,
			y = 0
		}
		ff.offset = V.vclone(hb.offset)
		ff._draw_order = (hb.draw_order and 100000 * hb.draw_order + 2 or 200003) + entity.id
		ff.z = Z_OBJECTS
		ff.sort_y_offset = hb.sort_y_offset
		ff.ss = self._hb_ss
		ff.color = hb.colors and hb.colors.fg or self._hb_colors.fg

		local hbsize = self._hb_sizes[hb.type]

		ff.bar_width = hbsize.x
		ff.scale = V.v(hbsize.x, hbsize.y)
		ff.offset.x = ff.offset.x - hbsize.x * ff.ss.ref_scale / 2

		for i = #hb.frames, 1, -1 do
			--table.removeobject(store.render_frames, hb.frames[i])
			if hb.frames[i] then
				hb.frames[i].marked_to_remove = true
			end
		end

		hb.frames[1] = fb
		hb.frames[2] = ff

		--table.insert(store.render_frames, fb)
		--table.insert(store.render_frames, ff)
		render_frames[#render_frames + 1] = fb
        render_frames[#render_frames + 1] = ff

		if fk then
			hb.frames[3] = fk

			table.insert(store.render_frames, fk)
		end
	end

	return true
end

function sys.render:on_remove(entity, store)
	if entity.render then
		for i = #entity.render.frames, 1, -1 do
			local f = entity.render.frames[i]

			--table.removeobject(store.render_frames, f)

			entity.render.frames[i] = nil
			if f then
				f.marked_to_remove = true
			end
		end
	end

	if entity.health_bar then
		for i = #entity.health_bar.frames, 1, -1 do
			local f = entity.health_bar.frames[i]

			--table.removeobject(store.render_frames, f)
			if f then
				f.marked_to_remove = true
			end
			entity.health_bar.frames[i] = nil
		end
	end

	return true
end

function sys.render:on_update(dt, ts, store)
	for _, e in E:filter_iter(store.entities, "render") do
		local render = e.render

		if render then
			for _, s in ipairs(render.sprites) do
				render_update_sprite_state(s, ts, e)
			end
		end
	end
end

function sys.render:prepare_frame(dt, ts, store)
	local d = store

	for _, e in E:filter_iter(d.entities, "render") do
		local render = e.render

		if render then
			for i, s in ipairs(render.sprites) do
			local f = render.frames[i]
			local fn = s._render_frame_name or render_update_sprite_state(s, ts, e)

			if not f then
				f = {
					marked_to_remove = false,
					ss = nil,
					flip_x = false,
					flip_y = false,
					pos = {
						x = (s.pos and s.pos.x) or (e.pos and e.pos.x) or 0,
						y = (s.pos and s.pos.y) or (e.pos and e.pos.y) or 0
					},
					anchor = {
						x = 0,
						y = 0
					},
					offset = {
						x = 0,
						y = 0
					},
					_draw_order = 100000 * (s.draw_order or i) + (e.id or 0),
					draw_order = 100000 * (s.draw_order or i) + (e.id or 0),
					z = s.z or Z_OBJECTS,
					sort_y = s.sort_y,
					sort_y_offset = s.sort_y_offset,
					alpha = s.alpha,
					hidden = true
				}
				render.frames[i] = f
				store.render_frames[#store.render_frames + 1] = f
			end

			local frame_is_exo = not not s.exo

			if not fn then
				f.ss = nil
				f.exo_frame = nil
				f.exo = nil
				f._frame_name = nil
				f._frame_is_exo = frame_is_exo
			elseif f._frame_name ~= fn or f._frame_is_exo ~= frame_is_exo then
				local frame_loaded = false

				if frame_is_exo then
					local exo_frame = EXO:f(fn)

					if exo_frame then
						f.exo_frame = exo_frame
						f.exo = exo_frame.exo
						frame_loaded = true
					end
				else
					f.ss = I:s(fn)
					f.exo_frame = nil
					f.exo = nil
					frame_loaded = f.ss ~= nil
				end

				if frame_loaded then
					f._frame_name = fn
					f._frame_is_exo = frame_is_exo
				end
			end

			if frame_is_exo and f.exo_frame then
					--if s.exo_hide_prefix then
					--	for _, p in ipairs(f.exo_frame.parts) do
					--		p.hidden = false

					--		for _, prefix in ipairs(s.exo_hide_prefix) do
					--			if string.find(p.name, prefix, 1, true) then
					--				p.hidden = true

					--				break
					--			end
					--		end
					--	end
					--end
					--
				if s.exo_hide_prefix then
						for _, p in ipairs(f.exo_frame) do
							if p[1] == 1 then
								local pname = f.exo.parts[p[2] ][1]

								p.hidden = false

								for _, prefix in ipairs(s.exo_hide_prefix) do
									if string.find(pname, prefix, 1, true) then
										p.hidden = true

										break
									end
								end
							end
						end
					end
			end

			f.flip_x = s.flip_x
			f.flip_y = s.flip_y

			local render_pos = s.pos or e.pos
			local render_pos_ready = render_pos and render_pos.x ~= nil and render_pos.y ~= nil

			if render_pos_ready then
				if not f.pos then
					f.pos = {
						x = 0,
						y = 0
					}
				end

				f.pos.x, f.pos.y = render_pos.x, render_pos.y
			end

			f.r = s.r
			f.scale = s.scale
			f.anchor.x, f.anchor.y = s.anchor.x, s.anchor.y
			if s.offset then
				f.offset.x, f.offset.y = s.offset.x, s.offset.y
			elseif e.offset then
				f.offset.x, f.offset.y = e.offset.x, e.offset.y
			else
				f.offset.x, f.offset.y = 0,0
			end
			f.z = s.z or Z_OBJECTS
			f.sort_y = s.sort_y
			f.sort_y_offset = s.sort_y_offset
			f._draw_order = 100000 * (s.draw_order or i) + e.id
			f.alpha = s.alpha

			f.hidden = s.hidden or not fn or not render_pos_ready

			if ts < s.ts then
				f.hidden = true
			end
			end
		end

		if render and e.health_bar and e.health.hp then
			local hb = e.health_bar
			local fb = hb.frames[1]
			local ff = hb.frames[2]
			local fk = hb.black_bar_hp and hb.frames[3] or nil

			if fb and ff then
				if hb.hidden then
					fb.hidden = true
					ff.hidden = true

					if fk then
						fk.hidden = true
					end
				elseif e.pos and e.pos.x and hb.offset then
					fb.hidden = false
					ff.hidden = false

					if fk then
						fk.hidden = false
					end

					fb.pos.x, fb.pos.y = math.floor(e.pos.x), math.ceil(e.pos.y)
					ff.pos.x, ff.pos.y = math.floor(e.pos.x), math.ceil(e.pos.y)
					fb.offset.x, fb.offset.y = hb.offset.x - fb.bar_width * fb.ss.ref_scale / 2, hb.offset.y
					ff.offset.x, ff.offset.y = hb.offset.x - ff.bar_width * ff.ss.ref_scale / 2, hb.offset.y
					fb.z = hb.z or Z_OBJECTS
					ff.z = hb.z or Z_OBJECTS
					fb._draw_order = (hb.draw_order and 100000 * hb.draw_order + 1 or 200002) + e.id
					ff._draw_order = (hb.draw_order and 100000 * hb.draw_order + 2 or 200003) + e.id
					fb.sort_y_offset = hb.sort_y_offset
					ff.sort_y_offset = hb.sort_y_offset

					if fk then
						fk.pos.x, fk.pos.y = math.floor(e.pos.x), math.floor(e.pos.y)
						fk.offset.x, fk.offset.y = hb.offset.x - fk.bar_width * fk.ss.ref_scale / 2, hb.offset.y
						fk.z = hb.z or Z_OBJECTS
						fk.sort_y_offset = hb.sort_y_offset
						fk._draw_order = (hb.draw_order and 100000 * hb.draw_order or 200001) + e.id
						ff.scale.x = e.health.hp / hb.black_bar_hp * ff.bar_width
						fb.scale.x = e.health.hp_max / hb.black_bar_hp * fb.bar_width
					else
						ff.scale.x = e.health.hp / e.health.hp_max * ff.bar_width
					end
				end
			end
		end

	end

	-- Android uses Dove's compact 16-byte ABI, not the desktop render_timsort
	-- structure. Validate every returned index before swapping the frame arrays;
	-- a missing library, capacity overflow, bad index, duplicate or bad order
	-- falls back to Lua sorting for this frame without losing any frame objects.
	if IS_ANDROID then
		if not lib_render_sort then
			render_sort_lua_fallback(store)

			return
		end

		local render_frames = store.render_frames
		local render_frames_ffi = store.render_frames_ffi
		local n = 0

		for i = 1, #render_frames do
			local f = render_frames[i]

			if f and not f.marked_to_remove and f.pos then
				if n >= RENDER_FFI_CAPACITY then
					render_android_sort_warn_once("capacity")
					render_sort_lua_fallback(store)

					return
				end

				local ffi_f = render_frames_ffi[n]
				ffi_f.z = f.z or Z_OBJECTS
				ffi_f.sort_y = f.sort_y or (f.sort_y_offset or 0) + (f.pos.y or 0)
				ffi_f.draw_order = f._draw_order or f.draw_order or 0
				ffi_f.lua_index = i
				n = n + 1
			end
		end

		local ok_sort, sort_err = pcall(lib_render_sort.ffi_sort, render_frames_ffi, store.render_frames_ffi_tmp, n)

		if not ok_sort then
			render_android_sort_warn_once("call: " .. tostring(sort_err))
			render_sort_lua_fallback(store)

			return
		end

		local seen = store.render_frames_ffi_seen
		ffi.fill(seen, RENDER_FFI_CAPACITY + 1)
		local new_frames = store.render_frames_sorted
		local previous_ffi

		render_clear_array(new_frames)

		for i = 0, n - 1 do
			local lua_index = tonumber(render_frames_ffi[i].lua_index)
			local f = lua_index and render_frames[lua_index]

			if not lua_index or lua_index < 1 or lua_index > #render_frames or seen[lua_index] ~= 0 or not f or f.marked_to_remove or not f.pos then
				render_android_sort_warn_once("index")
				render_sort_lua_fallback(store)

				return
			end

			local ffi_f = render_frames_ffi[i]

			if previous_ffi and not render_android_native_order_valid(previous_ffi, ffi_f) then
				render_android_sort_warn_once("order")
				render_sort_lua_fallback(store)

				return
			end

			seen[lua_index] = 1
			new_frames[i + 1] = f
			previous_ffi = ffi_f
		end

		store.render_frames_sorted = render_frames
		store.render_frames = new_frames

		return
	end

	--insertsort(store.render_frames)
	local render_frames = store.render_frames

	local render_frames_ffi = store.render_frames_ffi
    local n = 0
    for i = 1, #render_frames do
        local f = render_frames[i]
        if f and not f.marked_to_remove and f.pos then
			if n >= RENDER_FFI_CAPACITY then
				render_desktop_sort_warn_once("capacity")
				render_sort_lua_fallback(store)

				return
			end

            local ffi_f = render_frames_ffi[n]
            ffi_f.z = f.z or Z_OBJECTS
            ffi_f.sort_y = f.sort_y or (f.sort_y_offset or 0) + (f.pos.y or 0)
            ffi_f.draw_order = f._draw_order or f.draw_order or 0
            ffi_f.pos_x = f.pos.x or 0
            ffi_f.lua_index = i
            n = n + 1
        end
    end
	--此前用的是第1条
    --self.ffi_sort(store.render_frames_ffi, store.render_frames_ffi_tmp, 0, n)
	--self.ffi_sort(store.render_frames_ffi, n, self.ffi_cmp)
	if lib_render_sort then
		lib_render_sort.ffi_sort(render_frames_ffi, store.render_frames_ffi_tmp, n)
	else
		self.ffi_sort(render_frames_ffi, store.render_frames_ffi_tmp, 0, n)
	end
	local new_frames = store.render_frames_sorted

	for i = #new_frames, 1, -1 do
		new_frames[i] = nil
	end

	for i = 0, n - 1 do
        local ffi_f = render_frames_ffi[i]
        local f = render_frames[ffi_f.lua_index]
		new_frames[i + 1] = f
	end
	store.render_frames_sorted = render_frames
	store.render_frames = new_frames
end
--[[
function sys.render:init(store)
	store.render_frames = {}

	local hb_quad = love.graphics.newQuad(unpack(HEALTH_BAR_CORNER_DOT_QUAD))

	self._hb_ss = {
		ref_scale = 1,
		quad = hb_quad,
		trim = {
			0,
			0,
			0,
			0
		},
		size = {
			1,
			1
		}
	}
	self._hb_sizes = HEALTH_BAR_SIZES[store.texture_size] or HEALTH_BAR_SIZES.default
	self._hb_colors = HEALTH_BAR_COLORS
end]]

--[[
function sys.render:init(store)
	store.render_frames = {}

	--local hb_quad = {0,0,1,1,1024,1024}
	local hb_quad = love.graphics.newQuad(unpack(HEALTH_BAR_CORNER_DOT_QUAD))
	--love.graphics.newQuad(unpack({0,0,1,1,1024,1024}))

	self._hb_ss = {
		ref_scale = 1,
		quad = hb_quad,
		trim = {
			0,
			0,
			0,
			0
		},
		size = {
			1,
			1
		},
		atlas = "gui_portraits_20260307"
	}
	self._hb_sizes = HEALTH_BAR_SIZES[store.texture_size] or HEALTH_BAR_SIZES.default
	self._hb_colors = HEALTH_BAR_COLORS
end

function sys.render:on_insert(entity, store)
	if entity.render then
		for i, s in ipairs(entity.render.sprites) do
			local f = {}

			f.ss = nil
			f.flip_x = false
			f.flip_y = false
			f.pos = {
				x = 0,
				y = 0
			}
			f.anchor = {
				x = 0,
				y = 0
			}
			f.offset = {
				x = 0,
				y = 0
			}
			f.draw_order = 100000 * (s.draw_order or i) + entity.id
			f.z = s.z or Z_OBJECTS
			f.sort_y = s.sort_y
			f.sort_y_offset = s.sort_y_offset

			if s.random_ts then
				s.ts = U.frandom(-1 * s.random_ts, 0)
			end

			if s.color then
				f.color = s.color
			end

			if s.shader then
				f.shader = SH:get(s.shader)
				f.shader_args = s.shader_args
			end

			if entity.render.frames[i] then
				table.removeobject(store.render_frames, entity.render.frames[i])
			end

			entity.render.frames[i] = f

			table.insert(store.render_frames, f)
		end
	end

	if entity.health_bar then
		local hb = entity.health_bar
		local fk = hb.black_bar_hp and {} or nil

		if fk then
			fk.flip_x = false
			fk.pos = {
				x = 0,
				y = 0
			}
			fk.r = 0
			fk.alpha = 255
			fk.anchor = {
				x = 0,
				y = 0
			}
			fk.offset = V.vclone(hb.offset)
			fk.draw_order = (hb.draw_order and 100000 * hb.draw_order or 200001) + entity.id
			fk.z = Z_OBJECTS
			fk.sort_y_offset = hb.sort_y_offset
			fk.ss = self._hb_ss
			fk.color = hb.colors and hb.colors.black or self._hb_colors.black

			local hbsize = self._hb_sizes[hb.type]

			fk.bar_width = hbsize.x
			fk.scale = V.v(hbsize.x, hbsize.y)
			fk.offset.x = fk.offset.x - hbsize.x / 2
		end

		local fb = {}

		fb.flip_x = false
		fb.pos = {
			x = 0,
			y = 0
		}
		fb.r = 0
		fb.alpha = 255
		fb.anchor = {
			x = 0,
			y = 0
		}
		fb.offset = V.vclone(hb.offset)
		fb.draw_order = (hb.draw_order and 100000 * hb.draw_order + 1 or 200002) + entity.id
		fb.z = Z_OBJECTS
		fb.sort_y_offset = hb.sort_y_offset
		fb.ss = self._hb_ss
		fb.color = hb.colors and hb.colors.bg or self._hb_colors.bg

		local hbsize = self._hb_sizes[hb.type]

		fb.bar_width = hbsize.x
		fb.scale = V.v(hbsize.x, hbsize.y)
		fb.offset.x = fb.offset.x - hbsize.x * fb.ss.ref_scale / 2

		local ff = {}

		ff.flip_x = false
		ff.pos = {
			x = 0,
			y = 0
		}
		ff.r = 0
		ff.alpha = 255
		ff.anchor = {
			x = 0,
			y = 0
		}
		ff.offset = V.vclone(hb.offset)
		ff.draw_order = (hb.draw_order and 100000 * hb.draw_order + 2 or 200003) + entity.id
		ff.z = Z_OBJECTS
		ff.sort_y_offset = hb.sort_y_offset
		ff.ss = self._hb_ss
		ff.color = hb.colors and hb.colors.fg or self._hb_colors.fg

		local hbsize = self._hb_sizes[hb.type]

		ff.bar_width = hbsize.x
		ff.scale = V.v(hbsize.x, hbsize.y)
		ff.offset.x = ff.offset.x - hbsize.x * ff.ss.ref_scale / 2

		for i = #hb.frames, 1, -1 do
			table.removeobject(store.render_frames, hb.frames[i])
		end

		hb.frames[1] = fb
		hb.frames[2] = ff

		table.insert(store.render_frames, fb)
		table.insert(store.render_frames, ff)

		if fk then
			hb.frames[3] = fk

			table.insert(store.render_frames, fk)
		end
	end

	return true
end

function sys.render:on_remove(entity, store)
	if entity.render then
		for i = #entity.render.frames, 1, -1 do
			local f = entity.render.frames[i]

			table.removeobject(store.render_frames, f)

			entity.render.frames[i] = nil
		end
	end

	if entity.health_bar then
		for i = #entity.health_bar.frames, 1, -1 do
			local f = entity.health_bar.frames[i]

			table.removeobject(store.render_frames, f)

			entity.health_bar.frames[i] = nil
		end
	end

	return true
end

function sys.render:on_update(dt, ts, store)
	local d = store
	local entities = d.entities

	for _, e in E:filter_iter(entities, "render") do
		for i, s in ipairs(e.render.sprites) do
			local f = e.render.frames[i]
			local fn = render_update_sprite_state(s, ts, e)

			if s.exo then
				local exo_frame = fn and EXO:f(fn)
				if exo_frame then
					f.exo_frame = exo_frame
					f.exo = exo_frame.exo

					
					--if s.exo_hide_prefix then
					--	for _, p in ipairs(f.exo_frame.parts) do
					--		p.hidden = false

					--		for _, prefix in ipairs(s.exo_hide_prefix) do
					--			if string.find(p.name, prefix, 1, true) then
					--				p.hidden = true

					--				break
					--			end
					--		end
					--	end
					--end
					--
					if s.exo_hide_prefix then
						for _, p in ipairs(f.exo_frame) do
							if p[1] == 1 then
								local pname = f.exo.parts[p[2] ][1]

								p.hidden = false

								for _, prefix in ipairs(s.exo_hide_prefix) do
									if string.find(pname, prefix, 1, true) then
										p.hidden = true

										break
									end
								end
							end
						end
					end
				end
			else
				local ss = fn and I:s(fn)
				f.ss = ss
			end

			f.flip_x = s.flip_x
			f.flip_y = s.flip_y

			if s.pos then
				f.pos.x, f.pos.y = s.pos.x, s.pos.y
			else
				f.pos.x, f.pos.y = e.pos.x, e.pos.y
			end

			f.r = s.r
			f.scale = s.scale
			f.anchor.x, f.anchor.y = s.anchor.x, s.anchor.y
			if s.offset then
				f.offset.x, f.offset.y = s.offset.x, s.offset.y
			elseif e.offset then
				f.offset.x, f.offset.y = e.offset.x, e.offset.y
			else
				f.offset.x, f.offset.y = 0,0
			end
			f.z = s.z or Z_OBJECTS
			f.sort_y = s.sort_y
			f.sort_y_offset = s.sort_y_offset
			f.draw_order = 100000 * (s.draw_order or i) + e.id
			f.alpha = s.alpha

			if s.hide_after_runs and (s.runs or 0) >= s.hide_after_runs then
				s.hidden = true
			end

			f.hidden = s.hidden or not fn

			if ts < s.ts then
				f.hidden = true
			end
		end

		if e.health_bar then
			local hb = e.health_bar
			local fb = hb.frames[1]
			local ff = hb.frames[2]
			local fk = hb.black_bar_hp and hb.frames[3] or nil

			if hb.hidden then
				fb.hidden = true
				ff.hidden = true

				if fk then
					fk.hidden = true
				end
			elseif e.pos.x then
				fb.hidden = false
				ff.hidden = false

				if fk then
					fk.hidden = false
				end

				fb.pos.x, fb.pos.y = math.floor(e.pos.x), math.ceil(e.pos.y)
				ff.pos.x, ff.pos.y = math.floor(e.pos.x), math.ceil(e.pos.y)
				fb.offset.x, fb.offset.y = hb.offset.x - fb.bar_width * fb.ss.ref_scale / 2, hb.offset.y
				ff.offset.x, ff.offset.y = hb.offset.x - ff.bar_width * ff.ss.ref_scale / 2, hb.offset.y
				fb.z = hb.z or Z_OBJECTS
				ff.z = hb.z or Z_OBJECTS
				fb.draw_order = (hb.draw_order and 100000 * hb.draw_order + 1 or 200002) + e.id
				ff.draw_order = (hb.draw_order and 100000 * hb.draw_order + 2 or 200003) + e.id
				fb.sort_y_offset = hb.sort_y_offset
				ff.sort_y_offset = hb.sort_y_offset

				if fk then
					fk.pos.x, fk.pos.y = math.floor(e.pos.x), math.floor(e.pos.y)
					fk.offset.x, fk.offset.y = hb.offset.x - fk.bar_width * fk.ss.ref_scale / 2, hb.offset.y
					fk.z = hb.z or Z_OBJECTS
					fk.sort_y_offset = hb.sort_y_offset
					fk.draw_order = (hb.draw_order and 100000 * hb.draw_order or 200001) + e.id
					ff.scale.x = e.health.hp / hb.black_bar_hp * ff.bar_width
					fb.scale.x = e.health.hp_max / hb.black_bar_hp * fb.bar_width
				else
					ff.scale.x = e.health.hp / e.health.hp_max * ff.bar_width
				end
			end
		end
	end

	local function insertsort(a)
		local len = #a

		for i = 2, len do
			local f1_lte_f2
			local f1 = a[i]
			local y1 = f1.sort_y or (f1.sort_y_offset and f1.sort_y_offset or 0) + (f1.pos.y or 0)

			for j = i - 1, 0, -1 do
				if j == 0 then
					a[j + 1] = f1

					break
				end

				local f2 = a[j]
				local y2 = f2.sort_y or (f2.sort_y_offset and f2.sort_y_offset or 0) + (f2.pos.y or 0)

				if f1.z == f2.z then
					if y1 == y2 then
						if f1.draw_order == f2.draw_order then
							f1_lte_f2 = f1.pos.x < f2.pos.x
						else
							f1_lte_f2 = f1.draw_order < f2.draw_order
						end
					else
						f1_lte_f2 = y2 < y1
					end
				else
					f1_lte_f2 = f1.z < f2.z
				end

				if f1_lte_f2 then
					a[j + 1] = a[j]
				else
					a[j + 1] = f1

					break
				end
			end
		end
	end

	insertsort(store.render_frames)
end
]]

sys.sound_events = {}
sys.sound_events.name = "sound_events"

function sys.sound_events:on_insert(entity, store)
	local se = entity.sound_events

	if se and se.insert then
		local sounds = se.insert

		if type(sounds) ~= "table" then
			sounds = {
				sounds
			}
		end

		for _, s in pairs(sounds) do
			S:queue(s, se.insert_args)
		end
	end

	return true
end

function sys.sound_events:on_remove(entity, store)
	local se = entity.sound_events

	if se then
		if se.remove then
			local sounds = se.remove

			if type(sounds) ~= "table" then
				sounds = {
					sounds
				}
			end

			for _, s in pairs(sounds) do
				S:queue(s, se.remove_args)
			end
		end

		if se.remove_stop then
			local sounds = se.remove_stop

			if type(sounds) ~= "table" then
				sounds = {
					sounds
				}
			end

			for _, s in pairs(sounds) do
				S:stop(s, se.remove_stop_args)
			end
		end
	end

	return true
end

sys.seen_tracker = {}
sys.seen_tracker.name = "seen_tracker"

function sys.seen_tracker:init(store)
	local slot = storage:load_slot()

	store.seen = slot.seen and slot.seen or {}
	store.seen_dirty = nil
end

function sys.seen_tracker:on_insert(entity, store)
	if (entity.tower or entity.enemy) and not entity.ignore_seen_tracker then
		if entity.enemy and not entity.soldier and not entity.hero then
			local ok, err = xpcall(function()
				signal.emit("wave-notification", "enemy", entity)
			end, debug.traceback)
			if not ok then log.error("Enemy card failed for %s: %s", entity.template_name, err) end
		end
		U.mark_seen(store, entity.template_name)
	end

	return true
end

function sys.seen_tracker:on_update(dt, ts, store)
	if store.seen_dirty then
		local slot = storage:load_slot()

		slot.seen = store.seen

		storage:save_slot(slot)

		store.seen_dirty = false
	end
end

sys.dbg_enemy_tracker = {}
sys.dbg_enemy_tracker.name = "dbg_enemy_tracker"

local function format_stats(det)
	local diff = det.c_removed - (det.c_killed + det.c_end_node_reached)

	return string.format("enemy tracker - ins:%s | rem:%s (kill:%s + reach:%s = %s) %s", det.c_inserted, det.c_removed, det.c_killed, det.c_end_node_reached, diff, diff ~= 0 and "ERROR" or "")
end

function sys.dbg_enemy_tracker:init(store)
	store.det = {}
	store.det.c_inserted = 0
	store.det.c_removed = 0
	store.det.c_killed = 0
	store.det.c_end_node_reached = 0
end

function sys.dbg_enemy_tracker:on_insert(entity, store)
	if entity.enemy then
		store.det.c_inserted = store.det.c_inserted + 1

		log.debug(format_stats(store.det))
	end

	return true
end

function sys.dbg_enemy_tracker:on_remove(entity, store)
	if entity.enemy then
		store.det.c_removed = store.det.c_removed + 1

		if entity.enemy and entity.health.dead then
			store.det.c_killed = store.det.c_killed + 1
		end

		if entity.nav_path then
			local pi = entity.nav_path.pi
			local ni = entity.nav_path.ni
			local end_ni = P:get_end_node(pi)

			if end_ni <= ni then
				store.det.c_end_node_reached = store.det.c_end_node_reached + 1
			end
		end

		log.debug(format_stats(store.det))

		if store.det.c_removed ~= store.det.c_killed + store.det.c_end_node_reached then
			log.debug("DBG_ENEMY_TRACKER: ENEMY REMOVAL UNKNOWN: (%s) %s", entity.id, entity.template_name)
		end
	end

	return true
end

sys.editor_overrides = {}
sys.editor_overrides.name = "editor_overrides"

function sys.editor_overrides:on_insert(entity, store)
	if entity.editor and entity.editor.components then
		for _, c in pairs(entity.editor.components) do
			E:add_comps(entity, c)
		end
	end

	if entity.editor and entity.editor.overrides then
		for k, v in pairs(entity.editor.overrides) do
			LU.eval_set_prop(entity, k, v)
		end
	end

	return true
end

sys.editor_script = {}
sys.editor_script.name = "editor_script"

function sys.editor_script:on_insert(entity, store)
	if entity.editor_script and entity.editor_script.insert then
		return entity.editor_script.insert(entity, store, entity.editor_script.insert)
	else
		return true
	end
end

function sys.editor_script:on_remove(entity, store)
	if entity.editor_script and entity.editor_script.remove then
		return entity.editor_script.remove(entity, store, entity.editor_script.remove)
	else
		return true
	end
end

function sys.editor_script:on_update(dt, ts, store)
	for _, e in E:filter_iter(store.entities, "editor_script") do
		local s = e.editor_script

		if not s.update then
			-- block empty
		else
			if not s.co and s.runs ~= 0 then
				s.runs = s.runs - 1
				s.co = coroutine.create(s.update)
			end

			if s.co then
				local success, error = coroutine.resume(s.co, e, store, s)

				if coroutine.status(s.co) == "dead" or error ~= nil then
					if error ~= nil then
						log.error("Error running editor_script coro: %s", debug.traceback(s.co, error))
					end

					s.co = nil
				end
			end
		end
	end
end

PERFORMANCE_MONITOR_ENABLED = false

-- Keep the registered system available when profiling is disabled so the
-- release build can retain the same simulation system list without warnings.
sys.performance_monitor = {}
sys.performance_monitor.name = "performance_monitor"

_G.KR_PERFORMANCE_MONITOR = nil

if PERFORMANCE_MONITOR_ENABLED then
	_G.KR_PERFORMANCE_MONITOR = perf
    -- 需要监控的系统方法列表
    local MONITORED_METHODS = {"on_render_update", "prepare_frame", "on_insert", "on_remove", "on_queue", "on_dequeue"}

    -- 包装系统方法以添加性能监控
    local function create_monitored_system(original_sys)
        local monitored = {}
        for k, v in pairs(original_sys) do
            monitored[k] = v
        end

        -- 为每个需要监控的方法添加包装
        for _, method_name in ipairs(MONITORED_METHODS) do
            if original_sys[method_name] then
                local original_method = original_sys[method_name]
                local timer_name = (original_sys.name or "unknown") .. "." .. method_name

                monitored[method_name] = function(self, ...)
                    perf.start_timer(timer_name)
                    local result = original_method(self, ...)
                    perf.end_timer(timer_name)
                    return result
                end
            end
        end

        return monitored
    end

    -- 添加帧时间监控系统
    function sys.performance_monitor:init(store)
        self.last_frame_time = love.timer.getTime()
        self.last_report_time = love.timer.getTime()
		self.last_entity_report_time = self.last_report_time - 25
		print("Performance reports: " .. love.filesystem.getSaveDirectory())
    end

    function sys.performance_monitor:on_update(dt, ts, store)
        local current_time = love.timer.getTime()
        local frame_time = current_time - self.last_frame_time

		perf.record_frame(frame_time)

        -- 定期输出报告
		if current_time - self.last_report_time > perf.report_interval then
			perf.save_report(store)

			if current_time - self.last_entity_report_time >= 30 then
				perf.save_store_entities(store)
				self.last_entity_report_time = current_time
			end

			perf.reset()
			self.last_report_time = current_time
		end

        self.last_frame_time = current_time
    end

    -- 包装所有现有系统以添加性能监控
    local original_systems = {}
    for name, system in pairs(sys) do
        if type(system) == "table" and system.name then
            original_systems[name] = system
            sys[name] = create_monitored_system(system)
        end
    end

    -- 添加手动触发性能报告的函数（可以在游戏中调用）
    function sys.trigger_performance_report(store)
        perf.save_report(store)
    end
end



return sys

