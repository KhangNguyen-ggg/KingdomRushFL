local E = require("entity_db")
local A = require("achievements")
local U = require("utils_pld")
local S = require("sound_db")
local V = require("klua.vector")
local bit = require("bit")
local definitions = require("data.kr4_easter_eggs")
local M = {}

local function remove(store, e)
	simulation:queue_remove_entity(e)
end

local function start(e, store, state, loop)
	if not state or not e.egg.states[state] then return false end
	for i, sp in ipairs(e.render.sprites) do
		sp.ts, sp.runs = store.tick_ts, 0
		U.animation_start(e, state, nil, store.tick_ts, loop, i, true)
	end
	return true
end

local function play(e, store, state, sounds)
	if not start(e, store, state, false) then return end
	e.ui.clicked = nil
	local ts, played = store.tick_ts, {}
	repeat
		for i, sound in ipairs(sounds or {}) do
			if not played[i] and store.tick_ts - ts >= (sound.delay or 0) then
				played[i] = true
				S:queue(sound.id)
			end
		end
		coroutine.yield()
	until U.animation_finished(e, 1)
	e.ui.clicked = nil
end

local function visible(e, show)
	for _, sp in ipairs(e.render.sprites) do sp.hidden = not show end
	e.ui.can_click = show
end

local function unique(id, key)
	local counters = A.counters[P_LIFETIME]
	key = "easter_unique:" .. id .. ":" .. key
	if counters[key] then return false end
	counters[key], A.dirty = 1, true
	return true
end

local function award(e, store)
	if e.egg_awarded then return end
	e.egg_awarded = true
	local d = e.egg
	if d.kind == "fireworks" then
		local fx = E:create_entity("kr4_easter_fireworks")
		fx.pos = V.v(e.pos.x, e.pos.y + 100);simulation:queue_insert_entity(fx)
	end
	for _, id in ipairs(d.achievement) do
		if id == "KR4_ACHIEVEMENT_HAPPY_NEW_YEAR" then
			store.easter_fireworks = (store.easter_fireworks or 0) + 1
			if store.easter_fireworks == d.fireworks_total and unique(id, tostring(d.level)) then A:inc_check(id) end
		elseif unique(id, d.level .. ":" .. d.index) then
			A:inc_check(id)
			if id == "KR4_ACHIEVEMENT_BONEHART" and A:have(id) then
				local fx = E:create_entity("kr4_easter_bonehart")
				fx.pos = V.v(512, 384);fx.render.sprites[1].ts = store.tick_ts
				simulation:queue_insert_entity(fx)
			end
		end
	end
end

local function tap(e)
	while not e.ui.clicked do coroutine.yield() end
	e.ui.clicked = nil
end

local function finish(e, store, state, sounds)
	e.ui.can_click = false
	play(e, store, state, sounds)
	award(e, store)
	remove(store, e)
end

local function hypnotize(e, store)
	for _, target in pairs(store.entities) do
		local flags = target.vis and target.vis.flags or 0
		if (target.enemy or target.soldier) and target.health and not target.health.dead and bit.band(flags, bit.bor(F_BOSS, F_MINIBOSS)) == 0 then
			local mod = E:create_entity("mod_stun")
			mod.modifier.source_id, mod.modifier.target_id = e.id, target.id
			mod.modifier.duration = e.egg.source.modifier.duration
			simulation:queue_insert_entity(mod)
		end
	end
end

function M.update(e, store)
	local d, o = e.egg, e.egg.source
	local kind = d.kind
	if not d.exo then
		local frame = require("animation_db"):fn(e.render.sprites[1].prefix .. "_" .. d.idle, 0, true)
		local image = frame and require("klove.image_db"):s(frame, true)
		if image then
			local anchor, scale = e.render.sprites[1].anchor, o.scale or 1
			local w, h = image.size[1] * scale * (image.ref_scale or 1), image.size[2] * scale * (image.ref_scale or 1)
			e.ui.click_rect = V.r(-w * anchor.x, -h * anchor.y, w, h)
		end
	end
	start(e, store, d.idle, true)
	if kind == "touch_on_event" then
		while true do
			visible(e, false)
			U.y_wait(store, math.random(o.min_cooldown, o.max_cooldown))
			visible(e, true)
			start(e, store, o.animation_on_event, false)
			while not e.ui.clicked and not U.animation_finished(e, 1) do coroutine.yield() end
			if e.ui.clicked then finish(e, store, o.animation_end, o.end_sound);return end
			play(e, store, o.animation_not_touch)
		end
	elseif kind == "shaolin_master" then
		visible(e, false)
		for i, pos in ipairs(o.array_positions) do
			U.y_wait(store, o.delay_to_appear)
			e.pos = V.vclone(pos)
			visible(e, true)
			play(e, store, "in")
			start(e, store, "idle", true)
			tap(e)
			play(e, store, "action")
			play(e, store, "out")
			visible(e, false)
		end
		award(e, store);remove(store, e);return
	elseif kind == "yeti" then
		-- shortcut: KR4's C++ skier route is unavailable; use the current stage's path for the chase.
		visible(e, false)
		U.y_wait(store, o.cooldown)
		local P = require("path_db")
		local path = P.paths[1] and P.paths[1][1]
		if not path then remove(store, e);return end
		local skier = E:create_entity("kr4_easter_skier")
		skier.render.sprites[1].prefix = d.skier_prefix .. "_layer1"
		local node = math.min(#path, 2)
		skier.pos = V.vclone(path[node])
		simulation:queue_insert_entity(skier)
		e.pos = V.vclone(path[node]);e.pos.x = e.pos.x - 55
		visible(e, true)
		start(e, store, "walk", true)
		local last = store.tick_ts
		while node < #path do
			if e.ui.clicked then
				remove(store, skier);finish(e, store, "eat");return
			end
			local now = store.tick_ts
			local target = path[node + 1]
			local dx, dy = target.x - skier.pos.x, target.y - skier.pos.y
			local distance = math.sqrt(dx * dx + dy * dy)
			local step = d.speed * (now - last);last = now
			if distance <= step then skier.pos = V.vclone(target);node = node + 1
			elseif distance > 0 then skier.pos.x = skier.pos.x + dx * step / distance;skier.pos.y = skier.pos.y + dy * step / distance end
			e.pos.x, e.pos.y = skier.pos.x - 55, skier.pos.y
			coroutine.yield()
		end
		remove(store, skier);remove(store, e);return
	elseif kind == "seal" then
		while true do
			visible(e, false);U.y_wait(store, math.random(o.min_cooldown_appear, o.max_cooldown_appear))
			visible(e, true);play(e, store, "in");start(e, store, d.idle, true)
			local until_ts = store.tick_ts + math.random(o.min_cooldown_clap, o.max_cooldown_clap)
			while not e.ui.clicked and store.tick_ts < until_ts do coroutine.yield() end
			play(e, store, "clap");play(e, store, "out")
		end
	elseif kind == "gill_man" then
		while true do
			start(e, store, "idle", true)
			U.y_wait(store, math.random(o.min_cooldown, o.max_cooldown))
			play(e, store, "prep")
			S:queue(o.sound_drink.id);start(e, store, "drink", true)
			local until_ts = store.tick_ts + o.delay_drink
			while not e.ui.clicked and store.tick_ts < until_ts do coroutine.yield() end
			if e.ui.clicked then
				e.ui.can_click = false
				S:queue(o.sound_appear.id);play(e, store, "sale")
				start(e, store, "hold", true);U.y_wait(store, o.delay_monster)
				S:queue(o.sound_attack.id);finish(e, store, "attack");return
			end
			play(e, store, "back")
		end
	end
	local clicks, next_flavour = 0, store.tick_ts + math.random(15, 30)
	while true do
		if e.ui.clicked then
			e.ui.clicked = nil;clicks = clicks + 1
			if kind == "hypnotoad" then
				play(e, store, "toLoop");hypnotize(e, store)
				start(e, store, "loop", true);U.y_wait(store, o.modifier.duration)
				finish(e, store, "death");return
			elseif kind == "groot" then
				if clicks == 1 then play(e, store, "call1");play(e, store, "to2");d.idle = "idle2"
				elseif clicks == 2 then play(e, store, "call2")
				else play(e, store, "toGroot");finish(e, store, "dance");return end
			elseif kind == "gollum" then
				if clicks >= (o.touches or 3) then finish(e, store, "take");return end
				play(e, store, clicks == 1 and "mine" or "laugh")
			elseif kind == "olaf" then
				play(e, store, "toOlaf");finish(e, store, "dance");return
			elseif kind == "the_thing" then
				if clicks >= o.touches_to_thing then play(e, store, "thingLoop");finish(e, store, "thingDeath");return end
				play(e, store, clicks == 1 and "sniff" or "bark")
			elseif kind == "touch_kermit" then
				play(e, store, "drink");award(e, store)
			elseif kind == "gummi_bears" then
				play(e, store, "gummi" .. math.min(clicks, 3))
				if clicks >= 3 then award(e, store);e.ui.can_click = false end
			elseif kind == "armadillo" then
				finish(e, store, "toBall");return
			elseif kind == "boneheart_bone" then
				finish(e, store, "run");return
			elseif kind == "hodor" then
				if clicks < 3 then play(e, store, "tap" .. clicks)
				else
					play(e, store, "tap3");start(e, store, "idle2", true);e.ui.can_click = false
					local P = require("path_db")
					local undead = {}
					for i = 1, o.zombies do
						local enemy = E:create_entity("enemy_draugr_gold")
						enemy.nav_path.pi, enemy.nav_path.spi, enemy.nav_path.ni = o.datapath.path, (i - 1) % 3 + 1, math.random(unpack(o.datapath.node_range))
						enemy.pos = P:node_pos(enemy.nav_path)
						undead[#undead + 1] = enemy;simulation:queue_insert_entity(enemy)
					end
					coroutine.yield()
					while true do
						local alive, escaped = 0, false
						for _, enemy in ipairs(undead) do
							if not enemy.health.dead then if store.entities[enemy.id] then alive = alive + 1 else escaped = true end end
						end
						if escaped then e.ui.can_click = false;return end
						if alive == 0 then finish(e, store, "end");return end
						coroutine.yield()
					end
				end
			elseif kind == "touch_garfio" then
				local states = {"tap_One", "tap_Two", "tap_three"}
				if clicks >= 3 then finish(e, store, states[3]);return end
				play(e, store, states[clicks])
			elseif kind == "monkey_three_heads" then
				if clicks >= 3 then finish(e, store, "death");return end
				play(e, store, "tap")
			elseif kind == "touch_shark_achievement" then
				if clicks >= 2 then finish(e, store, "tap_two");return end
				play(e, store, "tap_one")
			elseif o.random_for_event then
				if math.random() <= o.random_check then
					play(e, store, o.animation_on_end, o.end_sound);award(e, store)
				else play(e, store, o.animation_on_touch, o.touch_sound) end
			else
				local required = o.touches_for_event or 1
				local state = o.animation_on_touch
				if type(state) == "table" then state = state[math.min(clicks, #state)] end
				if clicks >= required then finish(e, store, o.animation_on_end or "run", o.end_sound);return end
				play(e, store, state, o.touch_sound_per_tap and o.touch_sound_per_tap[clicks] or o.touch_sound)
			end
			start(e, store, d.idle, true)
		elseif store.tick_ts >= next_flavour then
			if kind == "touch_kermit" then play(e, store, "foot")
			elseif kind == "touch_with_random" then play(e, store, o.animation_random) end
			start(e, store, d.idle, true)
			next_flavour = store.tick_ts + math.random(o.min_cooldown or 15, o.max_cooldown or 30)
		end
		coroutine.yield()
	end
end

function M.register_templates()
	local totals = {}
	for _, d in ipairs(definitions) do if d.kind == "fireworks" then totals[d.level] = (totals[d.level] or 0) + 1 end end
	for _, definition in ipairs(definitions) do
		local d = table.deepclone(definition)
		local states = {};for _, state in ipairs(d.states) do states[state] = true end;d.states = states
		d.fireworks_total = totals[d.level]
		local t = E:register_t(d.template, "decal_scripted")
		E:add_comps(t, "ui")
		t.main_script.update, t.egg = M.update, d
		t.ui.can_click, t.ui.can_select = true, false
		local offset = type(d.source.touch_offset) == "number" and d.source.touch_offset or 10
		t.ui.click_rect = V.r(-25 - offset, -15 - offset, 50 + 2 * offset, 65 + 2 * offset)
		t.render.sprites = {}
		for i = 1, d.layers do
			local sp = E:clone_c("sprite");t.render.sprites[i] = sp
			sp.name, sp.prefix = d.idle, d.exo or d.prefix .. "_layer" .. i
			sp.animated, sp.exo = true, d.exo and true or nil
			sp.anchor = table.deepclone(d.source.anchor or V.v(0.5, 0.5))
			sp.flip_x = d.source.flipped_x or d.source.flipped or false
			sp.scale = V.vv(d.source.scale or 1)
			sp.r = (d.source.rotation_value or 0) * math.pi / 180
			sp.z, sp.draw_order = Z_OBJECTS, i
		end
	end
	local controller = E:register_t("kr4_easter_controller", "decal_scripted")
	controller.render = nil
	controller.main_script.update = function(this, store)
		for _, d in ipairs(definitions) do if d.level == store.level_idx then
			for _, e in pairs(store.entities) do
				if e.template_name == d.replace and e.pos and math.abs(e.pos.x - d.pos.x) < 1 and math.abs(e.pos.y - d.pos.y) < 1 then
					if e.render then for _, sp in ipairs(e.render.sprites) do sp.hidden = true end end
					remove(store, e)
				end
			end
			local e = E:create_entity(d.template);e.pos = V.vclone(d.pos);simulation:queue_insert_entity(e)
		end end
		remove(store, this)
	end
	local skier = E:register_t("kr4_easter_skier", "decal")
	skier.render.sprites[1].name, skier.render.sprites[1].animated = "walk", true
	skier.render.sprites[1].anchor = V.v(0.5, 0.139)
	local bonehart = E:register_t("kr4_easter_bonehart", "decal_scripted")
	bonehart.render.sprites[1].prefix, bonehart.render.sprites[1].name = "kr4_egg_Stage_10_boneheart_achievement", "run"
	bonehart.render.sprites[1].exo, bonehart.render.sprites[1].animated = true, true
	bonehart.render.sprites[1].z = Z_OBJECTS_COVERS
	bonehart.main_script.update = function(this, store)
		U.y_animation_play(this, this.render.sprites[1].name, nil, store.tick_ts, 1)
		remove(store, this)
	end
	local fireworks = E:register_t("kr4_easter_fireworks", "kr4_easter_bonehart")
	fireworks.render.sprites[1].prefix = "kr4_egg_china_achievement_fireworks"
	fireworks.render.sprites[1].name = "anim"
end

return M
