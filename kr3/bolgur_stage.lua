local E = require("entity_db")
local U = require("utils_pld")
local LU = require("level_utils")
local S = require("sound_db")
local P = require("path_db")
local V = require("klua.vector")
local A = require("animation_db")
local data = require("data.bolgur_stage")
local M = {}

local function start(e, store, name, loop)
	local sp = e.render.sprites[1]
	sp.ts, sp.runs = store.tick_ts, 0
	U.animation_start(e, name, nil, store.tick_ts, loop, 1, true)
end

local function play(e, store, name, can_interrupt)
	start(e, store, name, false)
	while not U.animation_finished(e, 1) do
		if can_interrupt and e.exit then return false end
		coroutine.yield()
	end
	return true
end

local function coins_view()
	local gui = package.loaded.game_gui
	if not gui or not gui.layer_gui_hud then return end
	local image = require("klove.image_db"):s("boss_dwarf_coins_0001", true)
	if not image then return end
	local view = require("klove.kui").KImageView:new("boss_dwarf_coins_0001")
	view.pos = V.vclone(data.steal.object.position_pc)
	gui.layer_gui_hud:add_child(view)
	return view
end

function M.scene_update(this, store)
	local steal = data.steal
	local next_steal = store.tick_ts + math.random(steal.cooldown_min, steal.cooldown_max)
	local next_wait = store.tick_ts + math.random(data.wait.cooldown_min, data.wait.cooldown_max)
	local next_splash = store.tick_ts + math.random(data.splash.cooldown_min, data.splash.cooldown_max)
	start(this, store, "boss_dwarf_idle", true)
	while not this.exit do
		this.ui.clicked = nil
		if store.tick_ts >= next_steal and (store.wave_group_number or 0) >= steal.wave_start and (store.player_gold or 0) >= steal.min_gold then
			next_steal = store.tick_ts + math.random(steal.cooldown_min, steal.cooldown_max)
			this.stealing, this.ui.can_click = true, true
			start(this, store, "boss_dwarf_steal", true)
			S:queue(steal.object.init_sound.id)
			local view = coins_view()
			local ts, paid = store.tick_ts, 0
			local loop_duration = A:duration("boss_dwarf_steal")
			while paid < steal.loops and not this.exit and not this.ui.clicked do
				if store.tick_ts - ts >= (paid + 1) * loop_duration then
					store.player_gold = math.max(0, (store.player_gold or 0) - steal.gold_steal)
					paid = paid + 1
				end
				if view then view:set_image(A:fn("boss_dwarf_coins_run", store.tick_ts - ts, true)) end
				coroutine.yield()
			end
			if view and view.parent then view.parent:remove_child(view) end
			this.stealing, this.ui.can_click = false, false
			if this.ui.clicked and not this.exit then
				this.ui.clicked = nil
				play(this, store, "boss_dwarf_angry", true)
			end
			start(this, store, "boss_dwarf_idle", true)
		elseif store.tick_ts >= next_splash then
			next_splash = store.tick_ts + math.random(data.splash.cooldown_min, data.splash.cooldown_max)
			if play(this, store, "boss_dwarf_up", true) and play(this, store, "boss_dwarf_correct", true) then
				for _, point in ipairs(data.splash.points) do
					if this.exit then break end
					branch_spawn_scene(store, "fx_bolgur_splash", this.pos.x + tonumber(point.x), this.pos.y + tonumber(point.y))
					U.y_wait(store, data.splash.delay_spawn, function() return this.exit end)
				end
				play(this, store, "boss_dwarf_back", true)
			end
			start(this, store, "boss_dwarf_idle", true)
		elseif store.tick_ts >= next_wait then
			next_wait = store.tick_ts + math.random(data.wait.cooldown_min, data.wait.cooldown_max)
			local sequence = data.wait.animation[math.random(1, #data.wait.animation)]
			if type(sequence) == "string" then sequence = {sequence} end
			for _, name in ipairs(sequence) do if not play(this, store, "boss_dwarf_" .. name, true) then break end end
			start(this, store, "boss_dwarf_idle", true)
		end
		coroutine.yield()
	end
	this.stealing, this.ui.can_click = false, false
	S:queue("dwarves_boss_dwarf_throne")
	for _, name in ipairs({"boss_dwarf_up", "boss_dwarf_jump", "boss_dwarf_jumpOn", "boss_dwarf_downOut2"}) do play(this, store, name) end
	this.exit_done = true
	simulation:queue_remove_entity(this)
end

function M.fire_burst(store, this, attack, target)
	for i, offset in ipairs(data.missiles.offsets) do
		if this.health.dead or this.unit.is_stunned then break end
		if not target or not store.entities[target.id] or target.health.dead then
			target = U.find_nearest_soldier(store.entities, this.pos, attack.min_range, attack.max_range, 0, F_FLYING, kr4_valid_enemy_soldier_target)
		end
		if not target then break end
		local shot = table.clone(attack)
		shot.shoot_offset = offset
		branch_enemy_fire_projectile(store, this, shot, target)
		if i < #data.missiles.offsets then
			U.y_wait(store, data.missiles.intervals[i], function() return this.health.dead or this.unit.is_stunned end)
		end
	end
end

function M.update(this, store)
	if store.level_mode ~= GAME_MODE_CAMPAIGN then return end
	local state = {phase = "throne", spawned = 0}
	store.bolgur_stage = state
	store.level.kr4_boss_done, store.level.run_complete = nil, nil
	store.level.update = function(level)
		while not level.kr4_boss_done do coroutine.yield() end
	end
	local npc = branch_spawn_scene(store, "boss_dwarf", data.npc_pos.x, data.npc_pos.y)
	state.npc = npc
	while not store.waves_finished or LU.has_alive_enemies(store) do coroutine.yield() end
	state.phase = "transition"
	npc.exit = true
	while store.entities[npc.id] and not npc.exit_done do coroutine.yield() end
	local boss = branch_spawn_from_pos_to_path(store, "enemy_boss_dwarf_mecha", data.mech_pos, data.mech_path, 1, P:get_start_node(data.mech_path))
	assert(boss, "Bolgur's mech path is missing")
	boss.branch.end_level_on_death = false
	boss.branch.spawn_animation = "up"
	boss.branch.ranged.bolgur_burst = true
	local melee = boss.melee.attacks[1]
	melee.type, melee.count = "area", data.melee.count
	melee.hit_times, melee.damage_radius, melee.hit_offset = table.deepclone(data.melee.hit_times), data.melee.radius, V.vclone(data.melee.offset)
	state.boss, state.started, state.phase = boss, store.tick_ts, "mech"
	S:queue("MusicBossFight_156")
	local next_spawn = 1
	coroutine.yield()
	while not boss.health.dead and store.entities[boss.id] do
		while next_spawn <= #data.reinforcements and store.tick_ts - state.started >= data.reinforcements[next_spawn].at do
			local row = data.reinforcements[next_spawn]
			local subpath = row.subpath == 0 and math.random(1, 3) or row.subpath
			branch_spawn_boss(store, row.template, row.path, subpath, row.node)
			state.spawned, next_spawn = state.spawned + 1, next_spawn + 1
		end
		coroutine.yield()
	end
	if not boss.health.dead then
		state.phase = "escaped"
		store.level.kr4_boss_done, store.level.run_complete = true, true
		return
	end
	state.phase = "death"
	while store.entities[boss.id] do coroutine.yield() end
	state.phase = "finished"
	require("achievements"):got("KR4_ACHIEVEMENT_DEFEAT_DWARF_KING")
	branch_kill_all_enemies_for_victory(store, true)
end

function M.register_templates()
	local npc = E.entities.boss_dwarf
	E:add_comps(npc, "ui")
	npc.ui.can_click, npc.ui.can_select = false, false
	npc.ui.click_rect = V.r(-45, -35, 90, 95)
	local throne = npc.render.sprites[2]
	throne.anchor = V.v(0.5, 0.08)
	throne.offset = V.v(data.mech_pos.x - data.npc_pos.x, data.mech_pos.y - data.npc_pos.y)
	throne.z = Z_OBJECTS - 1
	local fx = E:register_t("fx_bolgur_splash", "fx")
	fx.render.sprites[1].name = "boss_dwarf_splash"
	fx.render.sprites[1].anchor = V.v(0.5, 0.5)
end

return M
