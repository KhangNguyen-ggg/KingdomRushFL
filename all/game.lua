-- chunkname: @./all/game.lua

local log = require("klua.log"):new("game")
local km = require("klua.macros")
local signal = require("hump.signal")
local V = require("hump.vector-light")
local U = require("utils")
local RU = require("render_utils")
local I = require("klove.image_db")
local E = require("entity_db")
local F = require("klove.font_db")
local P = require("path_db")
local S = require("sound_db")
local SU = require("screen_utils")
local GR = require("grid_db")
local GS = require("game_settings")
local UP = require("upgrades")
local storage = require("storage")
local shortcut_settings = require("shortcut_settings")
local SSO = require("klove.sso")
local AC = require("achievements")
local PS = require("platform_services")
local simulation = require("simulation")
local game_gui = require("game_gui")
local adaptive_fps = require("dove_modules.perf.adaptive_fps")
local G = love.graphics
local bit = require("bit")

require("constants")
game = {}
game.upd = 0

local function krflapk_android_image_stats()
	if not I or not I.db_images then
		return "images=unavailable"
	end

	local loaded, deferred, empty = 0, 0, 0

	for _, v in pairs(I.db_images) do
		if v and v[1] then
			loaded = loaded + 1
		elseif v and v[4] and v[5] then
			deferred = deferred + 1
		else
			empty = empty + 1
		end
	end

	return string.format("images loaded=%s deferred=%s empty=%s atlas_frames=%s missing_images=%s missing_sprites=%s", loaded, deferred, empty, I.db_atlas and #table.keys(I.db_atlas) or 0, I.missing_images and #table.keys(I.missing_images) or 0, I.missing_sprites and #table.keys(I.missing_sprites) or 0)
end

local function krflapk_android_join_limited(list, limit)
	local out = {}

	for i = 1, math.min(#list, limit) do
		table.insert(out, list[i])
	end

	if #list > limit then
		table.insert(out, "..." .. tostring(#list - limit) .. " more")
	end

	return table.concat(out, ",")
end

local function krflapk_android_join_range(list, start_index, count)
	if not list or #list == 0 then
		return "[0/0](none)"
	end

	local first = math.max(1, start_index or 1)

	if first > #list then
		first = 1
	end

	local last = math.min(#list, first + (count or #list) - 1)
	local out = {}

	for i = first, last do
		table.insert(out, list[i])
	end

	return string.format("[%s-%s/%s]%s", first, last, #list, table.concat(out, ","))
end

local function krflapk_android_chunk_start(list, step, batch_index)
	if not list or #list == 0 then
		return 1
	end

	local chunks = math.max(1, math.ceil(#list / step))

	return ((math.max(1, batch_index or 1) - 1) % chunks) * step + 1
end

local function krflapk_android_image_list_lines(batch_index)
	if not I or not I.db_images then
		return {
			"KRFLAPK images unavailable"
		}
	end

	local loaded, deferred, empty, focus_loaded, focus_deferred = {}, {}, {}, {}, {}

	local function is_focus(name)
		return string.match(name, "^go_stage") or string.match(name, "^go_towers") or string.match(name, "^go_enemies") or string.match(name, "^go_hero") or string.match(name, "^gui_") or string.match(name, "^terrain") or string.match(name, "^stage")
	end

	for name, v in pairs(I.db_images) do
		if v and v[1] then
			table.insert(loaded, name)

			if is_focus(name) then
				table.insert(focus_loaded, name)
			end
		elseif v and v[4] and v[5] then
			table.insert(deferred, name .. "->" .. tostring(v[4]))

			if is_focus(name) then
				table.insert(focus_deferred, name .. "->" .. tostring(v[4]))
			end
		else
			table.insert(empty, name)
		end
	end

	table.sort(loaded)
	table.sort(deferred)
	table.sort(empty)
	table.sort(focus_loaded)
	table.sort(focus_deferred)

	local lines = {
		"KRFLAPK images focus_loaded=" .. krflapk_android_join_range(focus_loaded, krflapk_android_chunk_start(focus_loaded, 10, batch_index), 10),
		"KRFLAPK images focus_deferred=" .. krflapk_android_join_range(focus_deferred, krflapk_android_chunk_start(focus_deferred, 8, batch_index), 8),
		"KRFLAPK images loaded=" .. krflapk_android_join_range(loaded, krflapk_android_chunk_start(loaded, 14, batch_index), 14),
		"KRFLAPK images deferred=" .. krflapk_android_join_range(deferred, krflapk_android_chunk_start(deferred, 10, batch_index), 10)
	}

	if #empty > 0 then
		table.insert(lines, "KRFLAPK images empty=" .. krflapk_android_join_range(empty, krflapk_android_chunk_start(empty, 8, batch_index), 8))
	end

	return lines
end

local function krflapk_android_sprite_load_state(sprite_name)
	if not I then
		return "I=nil"
	end

	local ss = I:s(sprite_name, true)

	if not ss then
		return "ss=nil"
	end

	local im = I.db_images and I.db_images[ss.atlas]
	local load_state = im and im[1] and "yes" or im and "empty" or "missing"

	return string.format("ss=yes atlas=%s load=%s size=%s,%s trim=%s,%s,%s,%s", tostring(ss.atlas), load_state, tostring(ss.size and ss.size[1]), tostring(ss.size and ss.size[2]), tostring(ss.trim and ss.trim[1]), tostring(ss.trim and ss.trim[2]), tostring(ss.trim and ss.trim[3]), tostring(ss.trim and ss.trim[4]))
end

local function krflapk_android_background_diag_lines(store)
	if not store or not store.entities then
		return {
			"KRFLAPK bg store/entities unavailable"
		}
	end

	local lines = {}
	local count = 0

	for _, e in pairs(store.entities) do
		if e and e.render and (e.name == "background" or e.template_name == "decal_background" or e.template_name == "decal" or e.template_name and string.find(e.template_name, "background", 1, true)) then
			for i, s in ipairs(e.render.sprites) do
				local f = e.render.frames and e.render.frames[i]
				local sprite_name = s.name or s.frame_name or s.animation or "nil"
				local f_atlas = f and f.ss and f.ss.atlas or f and f.exo and "exo" or f and "no_ss" or "no_frame"
				local f_loaded = "n/a"

				if f and f.ss and f.ss.atlas and I and I.db_images then
					local im = I.db_images[f.ss.atlas]

					f_loaded = im and im[1] and "yes" or im and "empty" or "missing"
				end

				count = count + 1
				table.insert(lines, string.format("KRFLAPK bg#%s ent=%s/%s spr=%s s.z=%s s.hidden=%s frame=%s f.z=%s f.hidden=%s f.atlas=%s f.load=%s pos=%s,%s", count, tostring(e.id), tostring(e.template_name or e.name), tostring(sprite_name), tostring(s.z), tostring(s.hidden), f and "yes" or "nil", tostring(f and f.z), tostring(f and f.hidden), tostring(f_atlas), tostring(f_loaded), tostring(e.pos and math.floor(e.pos.x)), tostring(e.pos and math.floor(e.pos.y))))
				table.insert(lines, "KRFLAPK bg sprite " .. tostring(sprite_name) .. " " .. krflapk_android_sprite_load_state(sprite_name))
			end
		end
	end

	if count == 0 then
		table.insert(lines, "KRFLAPK bg entity count=0")
	end

	return lines
end

local function krflapk_android_entity_diag_lines(store)
	if not store then
		return {
			"KRFLAPK entity store=nil"
		}
	end

	local counts = {
		total = 0,
		render = 0,
		hero = 0,
		tower = 0,
		enemy = 0,
		soldier = 0,
		health = 0,
		main_script = 0
	}
	local samples = {}

	if store.entities then
		for _, e in pairs(store.entities) do
			if e then
				counts.total = counts.total + 1

				if e.render then
					counts.render = counts.render + 1
				end

				if e.hero then
					counts.hero = counts.hero + 1
				end

				if e.tower then
					counts.tower = counts.tower + 1
				end

				if e.enemy then
					counts.enemy = counts.enemy + 1
				end

				if e.soldier then
					counts.soldier = counts.soldier + 1
				end

				if e.health then
					counts.health = counts.health + 1
				end

				if e.main_script then
					counts.main_script = counts.main_script + 1
				end

				if #samples < 14 then
					table.insert(samples, tostring(e.template_name or e.name or e.id))
				end
			end
		end
	end

	local lines = {
		string.format("KRFLAPK entities total=%s entity_count=%s pending_i=%s pending_r=%s render_frames=%s", counts.total, tostring(store.entity_count), store.pending_inserts and #store.pending_inserts or "nil", store.pending_removals and #store.pending_removals or "nil", store.render_frames and #store.render_frames or "nil"),
		string.format("KRFLAPK entities render=%s hero=%s tower=%s enemy=%s soldier=%s health=%s main=%s paused=%s tick=%s", counts.render, counts.hero, counts.tower, counts.enemy, counts.soldier, counts.health, counts.main_script, tostring(store.paused), tostring(store.tick)),
		"KRFLAPK entity samples=" .. table.concat(samples, ",")
	}

	return lines
end

local function krflapk_android_body_sprite_diag_lines(store)
	if not store or not store.entities then
		return {
			"KRFLAPK body store/entities unavailable"
		}
	end

	local lines = {}
	local count = 0

	for _, e in pairs(store.entities) do
		if e and e.render and (e.hero or e.enemy or e.tower or e.soldier or e.barrack) then
			for i, s in ipairs(e.render.sprites) do
				if count >= 12 then
					break
				end

				local f = e.render.frames and e.render.frames[i]
				local fn = s.frame_name or s.name or s.animation or "nil"
				local atlas = f and f.ss and f.ss.atlas or f and f.exo and "exo" or f and "no_ss" or "no_frame"
				local load_state = "n/a"

				if f and f.ss and f.ss.atlas and I and I.db_images then
					local im = I.db_images[f.ss.atlas]

					load_state = im and im[1] and "yes" or im and "empty" or "missing"
				end

				count = count + 1
				table.insert(lines, string.format("KRFLAPK body#%s ent=%s/%s spr=%s anim=%s prefix=%s name=%s fn=%s ss=%s atlas=%s load=%s hidden=%s z=%s a=%s pos=%s,%s off=%s,%s scale=%s,%s", count, tostring(e.id), tostring(e.template_name), tostring(i), tostring(s.animated), tostring(s.prefix), tostring(s.name), tostring(fn), f and f.ss and "yes" or "nil", tostring(atlas), tostring(load_state), tostring(f and f.hidden), tostring(f and f.z), tostring(f and f.alpha), tostring(f and f.pos and math.floor(f.pos.x)), tostring(f and f.pos and math.floor(f.pos.y)), tostring(f and f.offset and math.floor(f.offset.x)), tostring(f and f.offset and math.floor(f.offset.y)), tostring(f and f.scale and f.scale.x), tostring(f and f.scale and f.scale.y)))
			end
		end

		if count >= 12 then
			break
		end
	end

	if count == 0 then
		table.insert(lines, "KRFLAPK body entity/render count=0")
	end

	return lines
end

local function krflapk_android_frame_summary(frames, max_count)
	if not frames then
		return "render_frames=nil"
	end

	local out = {
		string.format("render_frames=%s", #frames)
	}
	local count = 0

	for i, f in ipairs(frames) do
		if f and not f.hidden then
			count = count + 1

			local atlas = f.ss and f.ss.atlas or f.exo and "exo" or "no_ss"
			local loaded = "n/a"

			if f.ss and f.ss.atlas and I and I.db_images then
				local im = I.db_images[f.ss.atlas]

				loaded = im and im[1] and "yes" or im and "empty" or "missing"
			end

			table.insert(out, string.format("#%s z=%s atlas=%s loaded=%s pos=%s,%s", i, tostring(f.z), tostring(atlas), loaded, f.pos and math.floor(f.pos.x) or "nil", f.pos and math.floor(f.pos.y) or "nil"))

			if count >= max_count then
				break
			end
		end
	end

	return table.concat(out, " | ")
end

local function krflapk_android_frame_diag_lines(frames, max_count)
	if not frames then
		return {
			"KRFLAPK frames: nil"
		}
	end

	local z_gui_decals = Z_GUI_DECALS or 0
	local z_screen_fixed = Z_SCREEN_FIXED or 0
	local z_gui = Z_GUI or 0
	local counts = {
		world = 0,
		fixed = 0,
		gui = 0,
		after_gui = 0,
		hidden = 0,
		total = #frames
	}
	local samples = {}

	for i, f in ipairs(frames) do
		if not f or f.hidden then
			counts.hidden = counts.hidden + 1
		else
			local z = f.z or 0

			if z < z_gui_decals then
				counts.world = counts.world + 1
			elseif z < z_screen_fixed then
				counts.fixed = counts.fixed + 1
			elseif z < z_gui then
				counts.gui = counts.gui + 1
			else
				counts.after_gui = counts.after_gui + 1
			end

			if #samples < max_count then
				local atlas = f.ss and f.ss.atlas or f.exo and "exo" or "no_ss"
				local loaded = "n/a"

				if f.ss and f.ss.atlas and I and I.db_images then
					local im = I.db_images[f.ss.atlas]

					loaded = im and im[1] and "yes" or im and "empty" or "missing"
				end

				local color = "nil"

				if f.color then
					color = string.format("%s,%s,%s", tostring(f.color[1]), tostring(f.color[2]), tostring(f.color[3]))
				end

				table.insert(samples, string.format("#%s z=%s a=%s c=%s atlas=%s load=%s p=%s,%s", i, tostring(z), tostring(f.alpha), color, tostring(atlas), loaded, f.pos and math.floor(f.pos.x) or "nil", f.pos and math.floor(f.pos.y) or "nil"))
			end
		end
	end

	local lines = {
		string.format("KRFLAPK frames total=%s hidden=%s world=%s fixed=%s gui=%s after=%s", counts.total, counts.hidden, counts.world, counts.fixed, counts.gui, counts.after_gui)
	}

	for _, s in ipairs(samples) do
		table.insert(lines, "KRFLAPK frame " .. s)
	end

	return lines
end

--流辉349
--需要根据已选定的防御塔和已选定的英雄加载相应的图像，后面有注释的都是需要动态加载的
game.required_textures = {
	"go_towers",
	--"go_towers_hermit_toad", --5
	--"go_towers_ballista", --5
	--"go_towers_tricannon", --5
	--"go_towers_ray", --5
	--"go_towers_demon_pit", --5
	"go_towers_1",
	"go_towers_2",
	"go_towers_special",
	"go_barrack_pirates",
	"go_enemies_common",
	"go_decals"
	--"go_hero_all_1", --1
	--"go_hero_all_2", --2
	--"go_hero_all_3-1", --3
	--"go_hero_all_3-2", --3
}

game.ref_h = REF_H
game.ref_w = REF_W
game.ref_res = TEXTURE_SIZE_ALIAS.ipad
game.required_sounds = {
	"common",
	"common5",
	"ElvesTowerTaunts",
	"ElvesCommonSounds"
}
game.simulation_systems = {
	"level",
	"wave_spawn",
	"wave_spawn_tsv",
	"mod_lifecycle",
	"main_script",
	"events",
	"tween",
	"health",
	"count_groups",
	"hero_xp_tracking",
	"pops",
	"goal_line",
	"tower_upgrade",
	"game_upgrades",
	"game_upgrades_6",
	"texts",
	"particle_system",
	"render",
	"timed",
	"sound_events",
	"seen_tracker",
	"performance_monitor",
	SSO and "sso" or "",
	SSO and "sso_post" or ""
}

function game:init(screen_w, screen_h, done_callback)
	signal.begin_stage()
	self.screen_w = screen_w
	self.screen_h = screen_h
	self.done_callback = done_callback

	local aspect = screen_w / screen_h

	if aspect < MIN_SCREEN_ASPECT then
		self.game_scale = screen_w / MIN_SCREEN_ASPECT / self.ref_h
	else
		self.game_scale = screen_h / self.ref_h
	end

	self.game_ref_origin = V.v((screen_w - self.ref_w * self.game_scale) / 2, (screen_h - self.ref_h * self.game_scale) / 2)

	local panext = self.store.level.pan_extension
	local visible_h = REF_H
	local visible_w = math.ceil(self.screen_w * self.ref_h / self.screen_h)

	visible_w = km.clamp(REF_H * 4 / 3, REF_H * 16 / 9, visible_w)

	local v_left = (self.ref_w - visible_w) / 2
	local v_right = self.ref_w + (visible_w - self.ref_w) / 2
	local v_top = (panext and panext.top or 0) + visible_h
	local v_bottom = panext and panext.bottom or 0

	self.store.visible_coords = {
		top = v_top,
		left = v_left,
		bottom = v_bottom,
		right = v_right
	}

	-- The world camera is shared by touch and desktop controls. At zoom 1 its
	-- transform matches the original centred battlefield exactly, while the HUD
	-- remains in screen space.
	do
		local camera_world_w = self.ref_w * self.game_scale
		local camera_world_h = self.ref_h * self.game_scale
		local camera_view_left, camera_view_top = 0, 0
		local camera_view_w, camera_view_h = screen_w, screen_h
		local camera_left, camera_right = 0, camera_world_w
		local camera_top, camera_bottom = 0, camera_world_h
		local cover_zoom = 1

		if IS_ANDROID then
			local android_widescreen = ANDROID_WIDESCREEN_ENABLED ~= false and screen_w / screen_h > MAX_SCREEN_ASPECT
			local standard_sw, standard_sh, standard_scale, standard_origin = SU.clamp_window_aspect(screen_w, screen_h, self.ref_w, self.ref_h)
			-- Level art and gameplay visibility support at most a 16:9 world.  On a
			-- wider phone, zoom that world just enough to cover the physical screen
			-- instead of inventing drawable letterbox margins.  The resulting excess
			-- height remains available through vertical camera dragging.
			local camera_content_w = self.ref_h * MAX_SCREEN_ASPECT * self.game_scale
			local camera_margin_x = android_widescreen and math.max(0, (camera_content_w - camera_world_w) * 0.5) or 0
			-- With widescreen disabled, use the exact legacy aspect-clamped viewport.
			-- This deliberately remains generic: 4:3 tablets keep a 4:3 viewport,
			-- while only the opt-in branch below exposes an extra-wide phone surface.
			camera_view_w = android_widescreen and screen_w or standard_sw * standard_scale
			camera_view_h = android_widescreen and screen_h or standard_sh * standard_scale
			camera_view_left = android_widescreen and 0 or standard_origin.x
			camera_view_top = android_widescreen and 0 or standard_origin.y
			cover_zoom = math.max(1, camera_view_w / camera_content_w, camera_view_h / camera_world_h)
			camera_left = -camera_margin_x
			camera_right = camera_world_w + camera_margin_x
		else
			camera_left = v_left * self.game_scale
			camera_right = v_right * self.game_scale
			camera_top = (visible_h - v_top) * self.game_scale
			camera_bottom = (visible_h - v_bottom) * self.game_scale
		end

		self.camera = {
			x = camera_world_w * 0.5,
			y = camera_world_h * 0.5,
			zoom = cover_zoom,
			min_zoom = cover_zoom,
			min_zoom_clamp = cover_zoom,
			max_zoom = IS_ANDROID and 3 or 1.2,
			view_left = camera_view_left,
			view_top = camera_view_top,
			view_w = camera_view_w,
			view_h = camera_view_h,
			ww = camera_right - camera_left,
			wh = camera_bottom - camera_top,
			-- Extended mobile bounds affect visibility only, not drawable map art.
			wl = camera_left,
			wr = camera_right,
			wt = camera_top,
			wb = camera_bottom
		}

		function self.camera:clamp()
			self.zoom = km.clamp(self.min_zoom, self.max_zoom, self.zoom)

			local half_w = self.view_w / (2 * self.zoom)
			local half_h = self.view_h / (2 * self.zoom)
			local min_x, max_x = self.wl + half_w, self.wr - half_w
			local min_y, max_y = self.wt + half_h, self.wb - half_h

			if min_x > max_x then
				min_x, max_x = (self.wl + self.wr) * 0.5, (self.wl + self.wr) * 0.5
			end

			if min_y > max_y then
				min_y, max_y = (self.wt + self.wb) * 0.5, (self.wt + self.wb) * 0.5
			end

			self.x = km.clamp(min_x, max_x, self.x)
			self.y = km.clamp(min_y, max_y, self.y)
		end

		function self.camera:can_pan()
			return (self.wr - self.wl) * self.zoom > self.view_w + 0.5 or (self.wb - self.wt) * self.zoom > self.view_h + 0.5
		end

		self.camera:clamp()
		self._touch_points = {}
		self._pinch_start = nil
		self._camera_pan = nil
		self._mouse_camera_pan = nil
	end

	RU.init()

	self.store.ephemeral = {}

	simulation:init(self.store, self.simulation_systems)

	self.simulation = simulation

	if IS_ANDROID then
		self.store.realtime_accumulator = true
		adaptive_fps:set_scene(self)
	end

	game_gui:init(screen_w, screen_h, self)

	self.game_gui = game_gui

	if not self.store.level.show_comic_idx or self.store.level_mode ~= GAME_MODE_CAMPAIGN then
		S:queue(string.format("MusicBattlePrep_%02d", self.store.level_idx))
	end

	self:init_debug()
	signal.emit("game-start", self.store)
end

if DEBUG then
	function game:reload_gui()
		self.game_gui:destroy()

		local i18n = require("i18n")

		main:set_locale(i18n.current_locale)

		package.loaded.game_gui = nil
		self.game_gui = require("game_gui")

		self.game_gui:init(self.screen_w, self.screen_h, self)

		if self.store.main_hero then
			self.game_gui:add_hero(self.store.main_hero)
		end
	end
end

function game:restart()
	-- Entity removal callbacks are skipped when the simulation is reset.
	signal.emit("game-cleanup", self.store)
	require("systems").texts:clear_cache()
	self.game_gui:destroy()
	signal.end_stage()
	require("exoskeleton"):unload_all()
	SSO:reset()
	SSO:reset_p_lists()
	signal.begin_stage()
	self.store.restarted = true
	self.store.ephemeral = {}
	self.store.cheat_item_spell_uses = {}

	self.simulation:init(self.store, self.simulation_systems)

	if IS_ANDROID then
		self.store.realtime_accumulator = true
		adaptive_fps:set_scene(self)
	end

	self.game_gui:init(self.screen_w, self.screen_h, self)
	S:stop_all()
	S:queue(string.format("MusicBattlePrep_%02d", self.store.level_idx))

	if PS then
		PS.paused = true
	end

	self:init_debug()
	signal.emit("game-start", self.store)
end

function game:destroy()
	signal.emit("game-cleanup", self.store)

	if IS_ANDROID then
		adaptive_fps:destroy()
	end

	self.game_gui:destroy()

	self.game_gui = nil

	RU.destroy()
	require("systems").texts:clear_cache()
	signal.end_stage()
	require("exoskeleton"):unload_all()
	SSO:reset()
	SSO:reset_p_lists()

	if simulation.store == self.store then simulation.store = nil end
	require("hero_auto_rally"):clear_state(self.store)
	self.simulation = nil
	self.gui_required_textures = nil
	self.store = nil
end

function game:update_debug(dt)
	if self.DBG_AUTO_SEND then
		for k, ts in pairs(self.auto_send_list) do
			if game.store.tick_ts - ts > self.auto_send_interval then
				self.auto_send_list[k] = game.store.tick_ts

				local e = E:create_entity(k)

				e.nav_path.pi = self.dbg_active_pi
				e.nav_path.spi = self.dbg_use_random_subpath and math.random(1, 3) or 1
				e.nav_path.ni = P:get_start_node(self.dbg_active_pi)

				self.simulation:queue_insert_entity(e)
			end
		end
	end
end

function game:init_debug()
	if not DEBUG then
		return
	end

	DEBUG_KEYS_ON = true
	self.I = I
	self.DBG_DRAW_CLICKABLE = false
	self.DBG_DRAW_PATHS = nil
	self.DBG_DRAW_GRID = false
	self.DBG_DRAW_CENTERS = false
	self.DBG_ENEMY_PAGES = false
	self.DBG_DRAW_RALLY_RANGES = false
	self.DBG_DRAW_UNIT_RANGE = false
	self.DBG_DRAW_BULLET_TRAILS = false
	self.DBG_FPS_COUNTER = false
	self.PERF_TIME_GRAPH = false
	self.DBG_TIME_MULT = 1
	self.DBG_AUTO_SEND = false
	self.auto_send_list = {}
	self.auto_send_interval = 5
	self.dbg_use_random_subpath = true
	package.loaded["data.game_debug_data"] = nil

	local data = require("data.game_debug_data")

	self.current_enemy_page = data.default_page_for_level and data.default_page_for_level[self.store.level_idx] or data.default_page_for_terrain[self.store.level_terrain_type] or 1
	self.enemy_pages = data.enemy_pages
	self.enemy_keys = {
		"q",
		"w",
		"e",
		"r",
		"t",
		"y",
		"u",
		"i",
		"o",
		"p"
	}
	self.dbg_active_pi = 1

	if localuser_game_init then
		localuser_game_init()
	end

	if custom_script and custom_script.game_init then
		custom_script:game_init()
	end
end

function game:update(dt)
	local perf = _G.KR_PERFORMANCE_MONITOR
	local perf_started = perf and love.timer.getTime()
	local simulation_dt = IS_ANDROID and adaptive_fps:update(dt) or dt

	if DEBUG then
		self:update_debug(dt)
	end

	local key_shortcuts = self.game_gui and self.game_gui.key_shortcuts
	local speed_slow_key = shortcut_settings.key(key_shortcuts, "speed_slow", 1, SELF_DEFINED_KEY_1_12X)
	local speed_3x_key = shortcut_settings.key(key_shortcuts, "speed_3x", 1, SELF_DEFINED_KEY_3X)
	local speed_12x_key = shortcut_settings.key(key_shortcuts, "speed_12x", 1, SELF_DEFINED_KEY_12X)

	local playback_speed = self.playback_speed or 1
	if love.keyboard.isDown(speed_slow_key) then
		playback_speed = "slow"
	elseif love.keyboard.isDown(speed_3x_key) then
		playback_speed = 4
	elseif love.keyboard.isDown(speed_12x_key) or IS_ANDROID and self.game_gui and self.game_gui.android_virtual_r_down then
		playback_speed = 12
	end

	if playback_speed == "slow" then
		if self.upd == 12 then
			self.simulation:update(simulation_dt)
			self.upd = 0
		else
			self.upd = self.upd + 1
		end
	elseif playback_speed > 1 then
		for i = 1, playback_speed do
			self.simulation:update(simulation_dt)
		end
	elseif self.DBG_TIME_MULT then
		for i = 1, self.DBG_TIME_MULT do
			self.simulation:update(simulation_dt)
		end
	else
		self.simulation:update(simulation_dt)
	end

	if perf_started then
		perf.record("game.simulation_total", love.timer.getTime() - perf_started)
	end

	self.simulation:prepare_render(dt)
	local gui_started = perf_started and love.timer.getTime()
	self.game_gui:update(dt)

	if perf_started then
		perf.record("game.gui_update", love.timer.getTime() - gui_started)
		perf.record("game.update_total", love.timer.getTime() - perf_started)
	end
end

function game:keypressed(key, isrepeat)
	if DEBUG then
		if key == "/" then
			DEBUG_KEYS_ON = not DEBUG_KEYS_ON
		end

		if DEBUG_KEYS_ON and self:debug_keypressed(key, isrepeat) then
			return true
		end
	end

	return self.game_gui:keypressed(key, isrepeat)
end

function game:keyreleased(key, isrepeat)
	self.game_gui:keyreleased(key, isrepeat)
end

function game:mousepressed(x, y, button, istouch)
	self.game_gui:mousepressed(x, y, button, istouch)

	if not IS_ANDROID and not istouch and button == 1 and self.camera and self.camera:can_pan() and not self.store.paused then
		local gui = self.game_gui
		local drag_view = gui and gui.drag_view
		local pressed_view = gui and gui.window and gui.window._click_start_view

		if gui and not pressed_view and gui.mode == GUI_MODE_IDLE and not gui.selected_entity and not (drag_view and drag_view.is_pressing) then
			self._mouse_camera_pan = {
				start_x = x,
				start_y = y,
				last_x = x,
				last_y = y,
				active = false
			}
		end
	end
end

function game:mousereleased(x, y, button, istouch)
	if not IS_ANDROID and button == 1 and self._mouse_camera_pan then
		if self._mouse_camera_pan.active and self.game_gui.cancel_android_world_gesture then
			self.game_gui:cancel_android_world_gesture()
		end

		self._mouse_camera_pan = nil
	end

	self.game_gui:mousereleased(x, y, button, istouch)
end

function game:mousemoved(x, y, dx, dy, istouch)
	local pan = not IS_ANDROID and not istouch and self._mouse_camera_pan

	if not pan then
		return
	end

	local gui = self.game_gui
	local drag_view = gui and gui.drag_view
	local can_pan = love.mouse.isDown(1) and self.camera and self.camera:can_pan() and not self.store.paused and gui and gui.mode == GUI_MODE_IDLE and not gui.selected_entity and not (drag_view and drag_view.is_pressing)

	if not can_pan then
		self._mouse_camera_pan = nil

		return
	end

	local move_x, move_y = x - pan.last_x, y - pan.last_y

	if not pan.active then
		local total_x, total_y = x - pan.start_x, y - pan.start_y

		if total_x * total_x + total_y * total_y >= 100 then
			pan.active = true
			move_x, move_y = total_x, total_y
			gui:cancel_android_world_gesture()
		end
	end

	pan.last_x, pan.last_y = x, y

	if pan.active then
		self.camera.x = self.camera.x - move_x / self.camera.zoom
		self.camera.y = self.camera.y - move_y / self.camera.zoom
		self.camera:clamp()
	end
end

function game:wheelmoved(dx, dy)
	if not IS_ANDROID and self.camera and dy ~= 0 and not self.store.paused then
		local mx, my = love.mouse.getPosition()
		local camera = self.camera
		local view_right = camera.view_left + camera.view_w
		local view_bottom = camera.view_top + camera.view_h

		if mx >= camera.view_left and mx <= view_right and my >= camera.view_top and my <= view_bottom then
			local old_zoom = camera.zoom
			local new_zoom = km.clamp(camera.min_zoom, camera.max_zoom, old_zoom * 1.05 ^ dy)

			if new_zoom ~= old_zoom then
				local center_x = camera.view_left + camera.view_w * 0.5
				local center_y = camera.view_top + camera.view_h * 0.5
				local anchor_x = camera.x + (mx - center_x) / old_zoom
				local anchor_y = camera.y + (my - center_y) / old_zoom

				camera.zoom = new_zoom
				camera.x = anchor_x - (mx - center_x) / new_zoom
				camera.y = anchor_y - (my - center_y) / new_zoom
				camera:clamp()
			end

			return
		end
	end

	if self.game_gui.wheelmoved then
		self.game_gui:wheelmoved(dx, dy)
	end
end

function game:touchpressed(id, x, y, dx, dy, pressure)
	if IS_ANDROID and self.camera then
		self._touch_points = self._touch_points or {}
		self._touch_points[id] = V.v(x, y)

		local points = {}

		for _, point in pairs(self._touch_points) do
			table.insert(points, point)
		end

		if #points == 1 and self.camera:can_pan() then
			self._camera_pan = {
				id = id,
				start_x = x,
				start_y = y,
				last_x = x,
				last_y = y,
				active = false
			}
		elseif #points == 2 then
			local p1, p2 = points[1], points[2]
			local cx, cy = (p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5
			local dist = math.sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2)

			self._camera_pan = nil

			if dist > 0 then
				self._pinch_start = {
					dist = dist,
					center_x = cx,
					center_y = cy,
					zoom = self.camera.zoom,
					camera_x = self.camera.x,
					camera_y = self.camera.y
				}

				-- A pinch is a camera gesture, not a tower/skill confirmation.
				-- Close any open world menu so the release cannot buy something
				-- that happened to be below the first finger.
				if self.game_gui and self.game_gui.deselect_all then
					self.game_gui:deselect_all()
				end

				if self.game_gui and self.game_gui.cancel_android_world_gesture then
					self.game_gui:cancel_android_world_gesture()
				end
			end
		end
	end

	if self.game_gui and self.game_gui.touchpressed then
		self.game_gui:touchpressed(id, x, y, dx, dy, pressure)
	end
end

function game:touchreleased(id, x, y, dx, dy, pressure)
	if IS_ANDROID and self._touch_points then
		if self._camera_pan and self._camera_pan.id == id then
			if self._camera_pan.active and self.game_gui and self.game_gui.cancel_android_world_gesture then
				self.game_gui:cancel_android_world_gesture()
			end

			self._camera_pan = nil
		end

		self._touch_points[id] = nil
		self._pinch_start = nil
	end

	if self.game_gui and self.game_gui.touchreleased then
		self.game_gui:touchreleased(id, x, y, dx, dy, pressure)
	end
end

function game:touchmoved(id, x, y, dx, dy, pressure)
	local handled_pinch = false
	local handled_pan = false

	if IS_ANDROID and self.camera and self._touch_points then
		self._touch_points[id] = V.v(x, y)

		local points = {}

		for _, point in pairs(self._touch_points) do
			table.insert(points, point)
		end

		if #points == 2 then
			local p1, p2 = points[1], points[2]
			local cx, cy = (p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5
			local dist = math.sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2)
			local start = self._pinch_start

			if not start and dist > 0 then
				start = {
					dist = dist,
					center_x = cx,
					center_y = cy,
					zoom = self.camera.zoom,
					camera_x = self.camera.x,
					camera_y = self.camera.y
				}
				self._pinch_start = start
			elseif start and start.dist > 0 then
				local new_zoom = km.clamp(self.camera.min_zoom, self.camera.max_zoom, start.zoom * dist / start.dist)
				local anchor_x = start.camera_x + (start.center_x - self.screen_w * 0.5) / start.zoom
				local anchor_y = start.camera_y + (start.center_y - self.screen_h * 0.5) / start.zoom

				self.camera.zoom = new_zoom
				self.camera.x = anchor_x - (cx - self.screen_w * 0.5) / new_zoom
				self.camera.y = anchor_y - (cy - self.screen_h * 0.5) / new_zoom
				self.camera:clamp()
			end

			handled_pinch = true
		elseif #points == 1 and self._camera_pan and self._camera_pan.id == id then
			local pan = self._camera_pan
			local gui = self.game_gui
			local drag_view = gui and gui.drag_view
			local can_pan = self.camera:can_pan() and gui and gui.mode == GUI_MODE_IDLE and not gui.selected_entity and not (drag_view and drag_view.is_pressing)

			if not can_pan then
				self._camera_pan = nil
			else
				local move_x, move_y = x - pan.last_x, y - pan.last_y

				if not pan.active then
					local total_x, total_y = x - pan.start_x, y - pan.start_y

					if total_x * total_x + total_y * total_y >= 100 then
						pan.active = true
						move_x, move_y = total_x, total_y

						if gui.cancel_android_world_gesture then
							gui:cancel_android_world_gesture()
						end
					end
				end

				pan.last_x, pan.last_y = x, y

				if pan.active then
					self.camera.x = self.camera.x - move_x / self.camera.zoom
					self.camera.y = self.camera.y - move_y / self.camera.zoom
					self.camera:clamp()
					handled_pan = true
				end
			end
		end
	end

	if not handled_pinch and not handled_pan and self.game_gui and self.game_gui.touchmoved then
		self.game_gui:touchmoved(id, x, y, dx, dy, pressure)
	end
end

function game:gamepadaxis(joystick, axis, value)
	if self.game_gui.gamepadaxis then
		self.game_gui:gamepadaxis(joystick, axis, value)
	end
end

function game:gamepadpressed(joystick, button)
	if self.game_gui.gamepadpressed then
		self.game_gui:gamepadpressed(joystick, button)
	end
end

function game:gamepadreleased(joystick, button)
	if self.game_gui.gamepadreleased then
		self.game_gui:gamepadreleased(joystick, button)
	end
end

function game:joystickpressed(joystick, button)
	if self.game_gui.joystickpressed then
		self.game_gui:joystickpressed(joystick, button)
	end
end

function game:joystickreleased(joystick, button)
	if self.game_gui.joystickreleased then
		self.game_gui:joystickreleased(joystick, button)
	end
end

function game:joystickadded(joystick)
	if self.game_gui.joystickadded then
		self.game_gui:joystickadded(joystick)
	end
end

function game:joystickremoved(joystick)
	if self.game_gui.joystickremoved then
		self.game_gui:joystickremoved(joystick)
	end
end

function game:focus(focus)
	if self.game_gui.focus then
		self.game_gui:focus(focus)
	end
end

function game:get_ism_state()
	if self.game_gui and self.game_gui.get_ism_state then
		return self.game_gui:get_ism_state()
	end
end

function game:draw()
	local perf = _G.KR_PERFORMANCE_MONITOR
	local perf_started = perf and love.timer.getTime()

	self:draw_game()

	if perf_started then
		perf.record("game.draw_total", love.timer.getTime() - perf_started)
	end
end

function game:draw_enemy_pages()
	local function print_sh(str, x, y, color)
		color = color and color or {
			255,
			255,
			255
		}

		G.setColor(0, 0, 0)
		G.print(str, x + 1, y + 1)
		G.setColor(unpack(color))
		G.print(str, x, y)
		G.setColor(255, 255, 255)
	end

	local sw, sh, scale, origin = SU.clamp_window_aspect(self.screen_w, self.screen_h, self.screen_w, self.screen_h)

	G.setColor(0, 0, 0, 100)
	G.rectangle("fill", origin.x + 5, self.screen_h / 2 - 5, 270, self.screen_h / 3)

	local names = self.enemy_pages[self.current_enemy_page]
	local x, y = math.floor(origin.x + 10), self.screen_h / 2

	G.setFont(F:f("DroidSansMono", 13))

	for i, n in ipairs(names) do
		local key = self.enemy_keys[i]

		print_sh(string.format("%s: %s", key, n), x, y, self.auto_send_list[n] and {
			255,
			100,
			100
		} or {
			255,
			255,
			255
		})

		y = y + 12
	end

	G.setColor(255, 255, 255)

	y = y + 12

	print_sh("[: prev page", x, y)

	y = y + 12

	print_sh("]: next page", x, y)

	y = y + 12

	if self.DBG_AUTO_SEND then
		print_sh("=: auto send (ON)", x, y)
	else
		print_sh("=: auto send (OFF)", x, y)
	end

	y = y + 12

	print_sh(string.format(";: use random subpath: %s", self.dbg_use_random_subpath), x, y)

	y = y + 12

	print_sh(string.format(":: remove existing mods: %s", self.DBG_REMOVE_EXISTING_MODS), x, y)

	y = y + 12

	print_sh(string.format("+/-: auto send time (%s sec)", self.auto_send_interval), x, y)

	if self.store.game_outcome then
		y = y + 12

		print_sh("Lives checking OFF (store.game_outcome set)", x, y)
	end

	y = y + 12

	print_sh(string.format("z/Z: time warp (%sx)", self.DBG_TIME_MULT), x, y)

	y = y + 12

	print_sh(string.format("f9/f10: enemy speed factor (%sx)", GS.difficulty_enemy_speed_factor[self.store.level_difficulty]), x, y)

	y = y + 12

	print_sh(string.format("DEBUG KEYS ARE %s", DEBUG_KEYS_ON and "ON" or "OFF"), x, y)

	y = y + 12

	print_sh(string.format("Frame: %if", self.store.tick_ts * FPS), x, y)

	if self.store._lap_start then
		y = y + 12

		local sta = self.store._lap_start
		local sto = self.store._lap_stop or 0

		print_sh(string.format(",/.: Chrono: %i->%i=%if (%.2fs)", sta * FPS, sto * FPS, (sto - sta) * FPS, sto - sta), x, y)
	end
end

if DEBUG then
	function game:debug_keypressed(key, isrepeat)
		local shift = love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift")
		local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("lctrl")

		local function remove_all_modifiers()
			log.error("remove_all_modifiers")

			for _, e in pairs(self.store.entities) do
				if e.modifier then
					self.simulation:queue_remove_entity(e)
				end
			end
		end

		local function apply_modifier(name, e)
			if e then
				local m = E:create_entity(name)

				m.modifier.target_id = e.id
				m.pos = V.vclone(e.pos)

				self.simulation:queue_insert_entity(m)
			else
				for _, e in pairs(self.store.entities) do
					if e.enemy then
						local m = E:create_entity(name)

						m.modifier.target_id = e.id
						m.pos = V.vclone(e.pos)

						self.simulation:queue_insert_entity(m)
					end
				end
			end
		end

		if self.DBG_ENEMY_PAGES and table.contains(self.enemy_keys, key) and #self.enemy_pages[self.current_enemy_page] >= table.keyforobject(self.enemy_keys, key) then
			local idx = table.keyforobject(self.enemy_keys, key)
			local template_name = self.enemy_pages[self.current_enemy_page][idx]
			local e = E:create_entity(template_name)

			if e and e.enemy then
				e.enemy.wave_group_idx = km.clamp(1, 99999, game.store.wave_group_number)
				e.nav_path.pi = self.dbg_active_pi
				e.nav_path.spi = self.dbg_use_random_subpath and math.random(1, 3) or 1
				e.nav_path.ni = P:get_start_node(self.dbg_active_pi)

				if self.DBG_AUTO_SEND then
					if self.auto_send_list[e.template_name] then
						self.auto_send_list[e.template_name] = nil
					else
						self.auto_send_list[e.template_name] = 0
					end
				end

				if not self.DBG_AUTO_SEND then
					self.simulation:queue_insert_entity(e)
				end
			elseif e and e.modifier and not isrepeat then
				if self.DBG_REMOVE_EXISTING_MODS then
					remove_all_modifiers()
				end

				apply_modifier(self.enemy_pages[self.current_enemy_page][idx], self.game_gui.selected_entity)
			end
		elseif key == "-" then
			self.auto_send_interval = km.clamp(1, 1000, self.auto_send_interval - 1)
		elseif key == "=" then
			if shift then
				self.auto_send_interval = km.clamp(1, 1000, self.auto_send_interval + 1)
			else
				self.DBG_AUTO_SEND = not self.DBG_AUTO_SEND
				self.auto_send_list = {}
			end
		elseif key == "`" then
			self.DBG_ENEMY_PAGES = not self.DBG_ENEMY_PAGES
		elseif key == "[" then
			self.current_enemy_page = km.clamp(1, #self.enemy_pages, self.current_enemy_page - 1)
		elseif key == "]" then
			self.current_enemy_page = km.clamp(1, #self.enemy_pages, self.current_enemy_page + 1)
		elseif key == "a" then
			self.store.paused = not self.store.paused
		elseif key == "s" then
			self.store.step = true
		elseif key == "d" then
			if self.game_gui and self.game_gui.selected_entity then
				local e = self.game_gui.selected_entity

				if ctrl and shift and e.health then
					local damage = E:create_damage()

					damage.value = e.health.hp
					damage.target_id = e.id
					damage.damage_type = bit.bor(DAMAGE_EAT)

					table.insert(self.store.damage_queue, damage)
				elseif shift and e.health then
					local damage = E:create_damage()

					damage.value = math.floor(0.9 * e.health.hp - 1)
					damage.target_id = e.id

					table.insert(self.store.damage_queue, damage)
				elseif ctrl and e.health then
					e.health.hp = e.health.hp_max
				elseif e.health then
					local damage = E:create_damage()

					damage.value = e.health.hp
					damage.target_id = e.id
					damage.damage_type = DAMAGE_TRUE

					table.insert(self.store.damage_queue, damage)
				end
			end
		elseif key == "f" then
			-- block empty
		elseif key == "g" then
			self.DBG_DRAW_GRID = not self.DBG_DRAW_GRID
			self.grid_canvas = nil
		elseif key == "h" then
			self.path_canvas = nil

			if not self.DBG_DRAW_PATHS then
				self.DBG_DRAW_PATHS = 1
			elseif self.DBG_DRAW_PATHS == 1 then
				self.DBG_DRAW_PATHS = 2
			else
				self.DBG_DRAW_PATHS = nil
			end
		elseif key == "j" then
			self.dbg_active_pi = km.zmod(self.dbg_active_pi + 1, #P.paths)
			self.path_canvas = nil
		elseif key == "l" then
			if shift then
				if self.store.lives > 1 then
					self.store.lives = km.clamp(1, 20, self.store.lives - 100)
				else
					self.store.lives = 0
				end
			else
				self.store.lives = self.store.lives + 100
			end

			if self.store.lives > 200 then
				self.store.lives = 1000
				self.store.game_outcome = {}
			elseif self.store.lives <= 20 then
				self.store.game_outcome = nil
			end
		elseif key == ";" then
			if shift then
				self.DBG_REMOVE_EXISTING_MODS = not self.DBG_REMOVE_EXISTING_MODS
			else
				self.dbg_use_random_subpath = not self.dbg_use_random_subpath
			end
		elseif key == "z" then
			if shift then
				self.DBG_TIME_MULT = km.clamp(1, 64, self.DBG_TIME_MULT / 2)
			else
				self.DBG_TIME_MULT = km.clamp(1, 64, self.DBG_TIME_MULT * 2)
			end
		elseif key == "x" then
			local heroes = table.filter(self.store.entities, function(_, e)
				return e.hero and not e.hero.stage_hero
			end)

			if heroes and #heroes > 0 then
				heroes[1].hero.xp_queued = 500
			end
		elseif key == "c" then
			if shift then
				self.DBG_DRAW_BULLET_TRAILS = not self.DBG_DRAW_BULLET_TRAILS
			else
				self.DBG_DRAW_CENTERS = not self.DBG_DRAW_CENTERS
				self.DBG_DRAW_CLICKABLE = not self.DBG_DRAW_CLICKABLE
			end
		elseif key == "v" then
			if shift then
				local storage = require("storage")
				local slot = storage:load_slot()

				if self.game_gui.window:get_child_by_id("bag_contents_view") then
					for _, v in pairs(self.game_gui.window:get_child_by_id("bag_contents_view").children) do
						v:enable()

						v:ci("bag_item_qty").text = 10
						slot.bag[v.item] = 10
					end
				end

				storage:save_slot(slot)
			else
				signal.emit("debug-ready-user-powers")
				signal.emit("debug-ready-plants-crystals")
			end
		elseif key == "b" then
			self.DBG_DRAW_TOWER_RANGE = not self.DBG_DRAW_TOWER_RANGE
			self.DBG_DRAW_UNIT_RANGE = not self.DBG_DRAW_UNIT_RANGE
			self.DBG_DRAW_RALLY_RANGES = not self.DBG_DRAW_RALLY_RANGES
			self.DBG_DRAW_SPECIAL_RANGES = not self.DBG_DRAW_SPECIAL_RANGES
		elseif key == "m" then
			if love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") then
				self.store.player_gold = self.store.player_gold - 1000
			else
				self.store.player_gold = self.store.player_gold + 1000
			end
		elseif key == "n" then
			if love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") then
				self.DBG_DRAW_NAV_MESH = not self.DBG_DRAW_NAV_MESH
			else
				self.store.force_next_wave = true
			end
		elseif key == "," then
			self.store._lap_start = self.store.tick_ts
			self.store._lap_stop = nil
		elseif key == "." then
			self.store._lap_stop = self.store.tick_ts
		elseif key == "f9" then
			GS.difficulty_enemy_speed_factor[self.store.level_difficulty] = GS.difficulty_enemy_speed_factor[self.store.level_difficulty] - 0.01

			log.debug(" decrement speed factor")
		elseif key == "f10" then
			GS.difficulty_enemy_speed_factor[self.store.level_difficulty] = GS.difficulty_enemy_speed_factor[self.store.level_difficulty] + 0.01

			log.debug(" increment speed factor")
		else
			return false
		end

		return true
	end
end

do
	function game:draw_game()
		local frame_draw_params = RU.frame_draw_params
		local draw_frames_range = RU.draw_frames_range
		local gs = self.game_scale
		local rox, roy

		if self.camera then
			local c = self.camera

			c:clamp()

			local viewport_center_x = (c.view_left or 0) + c.view_w * 0.5
			local viewport_center_y = (c.view_top or 0) + c.view_h * 0.5
			local dox = c.x * c.zoom - viewport_center_x
			local doy = c.y * c.zoom - viewport_center_y

			rox, roy = -dox, -doy
			gs = gs * c.zoom
		else
			rox, roy = self.game_ref_origin.x, self.game_ref_origin.y
		end

		if self.store.world_offset then
			rox, roy = rox + self.store.world_offset.x, roy + self.store.world_offset.y
		end

		local world_cull_bounds

		if IS_ANDROID then
			-- Match Dove's mobile renderer: world sprites outside the camera do
			-- not reach the draw path.  Bounds are expressed in the same
			-- reference/screen-y coordinate system used by frame_draw_params.
			-- The margin keeps large effects entering from an edge from popping.
			local margin = 100

			world_cull_bounds = self._android_world_cull_bounds or {}
			self._android_world_cull_bounds = world_cull_bounds
			local view_left = self.camera and self.camera.view_left or 0
			local view_top = self.camera and self.camera.view_top or 0
			local view_right = self.camera and view_left + self.camera.view_w or self.screen_w
			local view_bottom = self.camera and view_top + self.camera.view_h or self.screen_h

			world_cull_bounds.left = (view_left - rox) / gs - margin
			world_cull_bounds.right = (view_right - rox) / gs + margin
			world_cull_bounds.top = (view_top - roy) / gs - margin
			world_cull_bounds.bottom = (view_bottom - roy) / gs + margin
		end

		if self.DBG_DRAW_PATHS and not self.path_canvas then
			local node_size = 2
			local point_size = 3

			G.push()
			G.translate(rox, roy)
			G.scale(gs, gs)

			self.path_canvas = G.newCanvas()

			G.setCanvas(self.path_canvas)

			if self.DBG_DRAW_PATHS == 2 then
				for pi, p in ipairs(P.paths) do
					if pi == self.dbg_active_pi then
						local pw = P:path_width(pi)

						for ni, o in pairs(p[1]) do
							if P:is_node_valid(pi, ni) then
								G.setColor(0, 0, 255, 150)
								G.circle("fill", o.x, REF_H - o.y, pw, 16)
							end
						end
					end
				end
			end

			for pi, p in ipairs(P.paths) do
				for _, sp in pairs(p) do
					for ni, o in ipairs(sp) do
						if not P:is_node_valid(pi, ni) then
							G.setColor(255, 255, 0, 255)
							G.rectangle("fill", o.x - node_size, REF_H - o.y - node_size, 2 * node_size, 2 * node_size)
						else
							G.setColor(255, 255, 255, 255)
							G.circle("fill", o.x, REF_H - o.y, node_size, 6)
						end
					end
				end
			end

			for pi, p in ipairs(P.paths) do
				if pi == self.dbg_active_pi then
					local start_node = P:get_start_node(pi)
					local end_node = P:get_end_node(pi)
					local v_start_node = P:get_visible_start_node(pi)
					local v_end_node = P:get_visible_end_node(pi)
					local dp_node = P:get_defend_point_node(pi)

					log.debug("-- path color lines ------------------------------------------")

					for sp_i, sp in pairs(p) do
						for ni, o in ipairs(sp) do
							if sp_i == 3 and ni == dp_node then
								local p1 = p[1][ni]

								G.setColor(0, 0, 0, 255)
								G.setLineWidth(5)
								G.circle("fill", p1.x, REF_H - p1.y, 20, 5)
								log.debug("pi:%s ni:%s : %s (black)", pi, ni, "defend point")
							end

							if sp_i == 3 and (ni == start_node or ni == end_node) then
								local p2, p3 = p[2][ni], p[3][ni]

								G.setColor(255, 255, 255, 255)
								G.setLineWidth(5)
								G.line(p2.x, REF_H - p2.y, p3.x, REF_H - p3.y)
								log.debug("pi:%s ni:%s : %s (white)", pi, ni, ni == start_node and "start" or "end")
							end

							if sp_i == 3 and (ni == v_start_node + 0 or ni == v_end_node - 0) then
								local p2, p3 = p[2][ni], p[3][ni]

								G.setColor(255, 0, 0, 255)
								G.setLineWidth(3)
								G.line(p2.x, REF_H - p2.y, p3.x, REF_H - p3.y)
								log.debug("pi:%s ni:%s : %s (red)", pi, ni, ni == v_start_node and "visible start" or "visible end")
							end

							if sp_i == 3 and (ni == v_start_node + 10 or ni == v_end_node - 10) then
								local p2, p3 = p[2][ni], p[3][ni]

								G.setColor(0, 0, 255, 255)
								G.setLineWidth(3)
								G.line(p2.x, REF_H - p2.y, p3.x, REF_H - p3.y)
								log.debug("pi:%s ni:%s : vis - 10 (blue)", pi, ni)
							end

							if sp_i == 3 and (ni == v_start_node + 20 or ni == v_end_node - 20) then
								local p2, p3 = p[2][ni], p[3][ni]

								G.setColor(0, 0, 0)
								G.setColor(0, 255, 0, 255)
								G.setLineWidth(3)
								G.line(p2.x, REF_H - p2.y, p3.x, REF_H - p3.y)
								log.debug("pi:%s ni:%s : vis - 20 (green)", pi, ni)
							end

							G.setLineWidth(1)
							G.setColor(255, 0, 255, 255)
							G.rectangle("line", o.x - point_size, REF_H - o.y - point_size, 2 * point_size, 2 * point_size)
						end
					end
				end
			end

			if self.store.level and self.store.level.points_spawner and self.store.level.points_spawner.spawner_points then
				G.setColor(0, 0, 255, 255)
				G.setLineWidth(3)

				for _, p in pairs(self.store.level.points_spawner.spawner_points) do
					G.circle("fill", p.from.x, REF_H - p.from.y, 10, 8)
					G.line(p.from.x, REF_H - p.from.y, p.to.x, REF_H - p.to.y)
				end
			end

			if self.store.level then
				G.setColor(0, 0, 255, 255)

				for _, e in pairs(self.store.entities) do
					if e.graveyard and e.graveyard.spawn_pos then
						for _, p in pairs(e.graveyard.spawn_pos) do
							G.circle("fill", p.x, REF_H - p.y, 5, 4)
						end
					end
				end
			end

			G.setLineWidth(1)
			G.setColor(255, 255, 255, 255)
			G.setCanvas()
			G.pop()
		end

		if self.DBG_DRAW_GRID and not self.grid_canvas then
			G.push()
			G.translate(rox, REF_H * gs + roy)
			G.scale(gs, -gs)
			G.translate(GR.ox, GR.oy)

			self.grid_canvas = G.newCanvas()

			G.setCanvas(self.grid_canvas)

			for i = 1, #GR.grid do
				for j = 1, #GR.grid[i] do
					local t = GR.grid[i][j]

					G.setColor(GR.grid_colors[t] or {
						100,
						100,
						100
					})
					G.rectangle("fill", (i - 1) * GR.cell_size, (j - 1) * GR.cell_size, GR.cell_size, GR.cell_size)
				end
			end

			if GR.waypoints_cache and GR.waypoints_cache.path_c then
				G.setColor(GR.grid_colors.path)

				for _, n in pairs(GR.waypoints_cache.path_c) do
					G.rectangle("fill", (n.x - 0.5) * GR.cell_size, (n.y - 0.5) * GR.cell_size, GR.cell_size / 2, GR.cell_size / 2)
				end
			end

			if DEBUG_POINTS then
				G.setColor(GR.grid_colors.path)

				for _, n in pairs(DEBUG_POINTS) do
					G.rectangle("fill", (n.x - 0.5) * GR.cell_size, (n.y - 0.5) * GR.cell_size, GR.cell_size / 2, GR.cell_size / 2)
				end
			end

			G.setCanvas()
			G.setColor(255, 255, 255, 255)
			G.pop()
		end

		local last_idx

		if IS_ANDROID then
			local diag_time = love.timer.getTime()

			self.krflapk_android_draw_diag_count = self.krflapk_android_draw_diag_count or 0
			self.krflapk_android_draw_diag_last_time = self.krflapk_android_draw_diag_last_time or -999

			local should_log_diag = self.krflapk_android_draw_diag_count < 6 and diag_time - self.krflapk_android_draw_diag_last_time >= 2

			if should_log_diag then
				self.krflapk_android_draw_diag_count = self.krflapk_android_draw_diag_count + 1
				self.krflapk_android_draw_diag_last_time = diag_time

				if log.android_log_write then
					log.android_log_write(string.format("KRFLAPK draw #%s t=%.1f screen=%sx%s scale=%s origin=%s,%s ro=%s,%s camera=%s,%s,%s night=%s offset=%s\n", tostring(self.krflapk_android_draw_diag_count), diag_time, tostring(self.screen_w), tostring(self.screen_h), tostring(gs), tostring(self.game_ref_origin and self.game_ref_origin.x), tostring(self.game_ref_origin and self.game_ref_origin.y), tostring(rox), tostring(roy), tostring(self.camera and self.camera.x), tostring(self.camera and self.camera.y), tostring(self.camera and self.camera.zoom), tostring(self.store and self.store.night_mode), tostring(self.store and self.store.world_offset)))
					log.android_log_write("KRFLAPK " .. krflapk_android_image_stats() .. "\n")

					for _, line in ipairs(krflapk_android_entity_diag_lines(self.store)) do
						log.android_log_write(line .. "\n")
					end

					for _, line in ipairs(krflapk_android_body_sprite_diag_lines(self.store)) do
						log.android_log_write(line .. "\n")
					end

					for _, line in ipairs(krflapk_android_background_diag_lines(self.store)) do
						log.android_log_write(line .. "\n")
					end

					for _, line in ipairs(krflapk_android_image_list_lines(self.krflapk_android_draw_diag_count)) do
						log.android_log_write(line .. "\n")
					end

					for _, line in ipairs(krflapk_android_frame_diag_lines(self.store and self.store.render_frames, 8)) do
						log.android_log_write(line .. "\n")
					end
				else
					log.error("KRFLAPK draw diag unavailable")
				end
			end
		end

		G.push()
		G.translate(rox, roy)
		G.scale(gs, gs)

		last_idx = draw_frames_range(self.store.render_frames, 1, Z_GUI_DECALS - 1, world_cull_bounds)

		G.pop()

		if self.DBG_DRAW_GRID then
			G.setColor(255, 255, 255, 100)
			G.draw(self.grid_canvas)
			G.setColor(255, 255, 255, 255)
		end

		if self.DBG_DRAW_RALLY_RANGES then
			G.push()
			G.translate(rox, roy)
			G.scale(gs, gs)

			for _, e in pairs(self.store.entities) do
				if e.barrack then
					local b = e.barrack
					local s = E:get_template(b.soldier_type)

					G.setColor(100, 100, 255, 100)

					if s.melee then
						local range = s.melee.range

						G.ellipse("fill", b.rally_pos.x, REF_H - b.rally_pos.y, range, range * ASPECT)
					end
				end
			end

			G.setColor(255, 255, 255, 255)
			G.pop()
		end

		if self.DBG_DRAW_SPECIAL_RANGES then
			G.push()
			G.translate(rox, roy)
			G.scale(gs, gs)

			for _, e in pairs(self.store.entities) do
				if e.custom_attack and e.custom_attack.range then
					G.setColor(100, 100, 255, 100)
					G.ellipse("fill", e.pos.x, REF_H - e.pos.y, e.custom_attack.range, e.custom_attack.range * ASPECT)
				end
			end

			for _, e in pairs(self.store.entities) do
				if e.aura and e.aura.damage_radius then
					G.setColor(100, 100, 255, 100)
					G.ellipse("fill", e.pos.x, REF_H - e.pos.y, e.aura.damage_radius, e.aura.damage_radius * ASPECT)
				end
			end

			G.setColor(255, 255, 255, 255)
			G.pop()
		end

		if self.DBG_DRAW_TOWER_RANGE then
			G.push()
			G.translate(rox, roy)
			G.scale(gs, gs)

			local e = game.game_gui.selected_entity or self.dbg_last_selected_entity

			if e then
				self.dbg_last_selected_entity = e

				local range = e.attacks and e.attacks.range

				if range then
					range = range * (e.attacks.prediction_range_factor or 1)

					local pos = e.pos

					if e.tower and e.tower.range_offset then
						pos = V.v(pos.x + e.tower.range_offset.x, pos.y + e.tower.range_offset.y)
					end

					G.setColor(100, 100, 255, 100)
					G.setLineWidth(3)
					G.ellipse("line", pos.x, REF_H - pos.y, range, range * ASPECT)

					if e.attacks and e.attacks.range_check_factor then
						local f = e.attacks.range_check_factor

						G.setColor(100, 100, 255, 60)
						G.setLineWidth(3)
						G.ellipse("line", pos.x, REF_H - pos.y, f * range, f * range * ASPECT)
					end
				end
			end

			G.setColor(255, 255, 255, 255)
			G.pop()
		end

		if self.DBG_DRAW_UNIT_RANGE then
			G.push()
			G.translate(rox, roy)
			G.scale(gs, gs)

			local e = game.game_gui.selected_entity or self.dbg_last_selected_entity

			if e then
				self.dbg_last_selected_entity = e

				local range, min_range

				if e.ranged then
					range = e.ranged.attacks[1].max_range
					min_range = e.ranged.attacks[1].min_range
				elseif e.melee and e.melee.range then
					range = e.melee.range
				elseif e.attacks and e.attacks.list[1] and e.attacks.list[1].max_range then
					range = e.attacks.list[1].max_range
					min_range = e.attacks.list[1].min_range
				end

				if range then
					G.setColor(100, 100, 255, 100)
					G.setLineWidth(3)
					G.ellipse("line", e.pos.x, REF_H - e.pos.y, range, range * ASPECT)
				end

				if min_range then
					G.setColor(50, 50, 255, 100)
					G.setLineWidth(2)
					G.ellipse("line", e.pos.x, REF_H - e.pos.y, min_range, min_range * ASPECT)
				end
			end

			G.setColor(255, 255, 255, 255)
			G.pop()
		end

		if self.DBG_DRAW_AURA_RANGE then
			G.push()
			G.translate(rox, roy)
			G.scale(gs, gs)

			for _, e in pairs(self.store.entities) do
				if e.aura and e.aura.radius then
					G.setColor(100, 100, 255, 100)
					G.setLineWidth(3)
					G.ellipse("line", e.pos.x, REF_H - e.pos.y, e.aura.radius, e.aura.radius * ASPECT)
				end
			end

			G.setColor(255, 255, 255, 255)
			G.pop()
		end

		G.push()
		G.translate(rox, roy)
		G.scale(gs, gs)

		last_idx = draw_frames_range(self.store.render_frames, last_idx + 1, Z_SCREEN_FIXED - 1, world_cull_bounds)

		G.pop()

		if self.DBG_DRAW_PATHS then
			G.setColor(255, 255, 255, 100)
			G.draw(self.path_canvas)
			G.setColor(255, 255, 255, 255)
		end

		G.push()
		G.translate(self.game_ref_origin.x, self.game_ref_origin.y)
		G.scale(self.game_scale, self.game_scale)

		last_idx = draw_frames_range(self.store.render_frames, last_idx + 1, Z_GUI - 1)

		G.pop()
		self.game_gui.window:draw_child(self.game_gui.layer_gui)

		if self.DBG_DRAW_CENTERS then
			G.push()
			G.translate(rox, roy)
			G.scale(gs, gs)

			for _, e in pairs(self.store.entities) do
				if e.pos and e.bullet then
					G.setLineWidth(1)
					G.setColor(200, 200, 0, 200)
					G.line(e.pos.x - 1, REF_H - e.pos.y - 1, e.pos.x + 1, REF_H - e.pos.y + 1)
					G.line(e.pos.x - 1, REF_H - e.pos.y + 1, e.pos.x + 1, REF_H - e.pos.y - 1)
				elseif e.pos and not e.bullet and not e.decal then
					G.setColor(0, 0, 200, 200)
					G.rectangle("fill", e.pos.x - 1, REF_H - e.pos.y - 4, 2, 8)
					G.rectangle("fill", e.pos.x - 4, REF_H - e.pos.y - 1, 8, 2)
				end
			end

			G.pop()
			G.setColor(255, 255, 255, 255)
		end

		if self.DBG_DRAW_CLICKABLE then
			G.push()
			G.translate(rox, roy)
			G.scale(gs, gs)

			for _, e in pairs(self.store.entities) do
				if e.ui then
					G.setColor(255, 255, 0, 70)

					local rect = e.ui.click_rect

					G.rectangle("fill", e.pos.x + rect.pos.x, REF_H - (e.pos.y + rect.pos.y), rect.size.x, -rect.size.y)
				end
			end

			G.pop()
			G.setColor(255, 255, 255, 255)
		end

		if self.DBG_DRAW_NAV_MESH then
			G.push()
			G.translate(rox, roy)
			G.scale(gs, gs)
			G.setFont(F:f("DroidSansMono", 18))

			local towers = {}

			for _, e in pairs(self.store.entities) do
				if e.tower and e.tower.holder_id then
					towers[tonumber(e.tower.holder_id)] = e

					G.setColor(0, 0, 0, 255)
					G.print(e.tower.holder_id, e.pos.x + 5, REF_H - e.pos.y - 8)
					G.setColor(202, 202, 0, 255)
					G.print(e.tower.holder_id, e.pos.x + 5 - 2, REF_H - e.pos.y - 8 - 2)
				end
			end

			G.setColor(0, 100, 255, 255)
			G.setLineWidth(2)
			G.translate(0, -10)

			local ox, oy = 40, 15
			local ax, ay = 40, 15

			for h_id, row in pairs(self.store.level.nav_mesh) do
				local e = towers[h_id]

				if not e then
					-- block empty
				else
					local oe = towers[row[1]]

					if oe then
						G.line(e.pos.x + ox, REF_H - e.pos.y, oe.pos.x - ax, REF_H - oe.pos.y)
					end

					oe = towers[row[2]]

					if oe then
						G.line(e.pos.x, REF_H - e.pos.y - oy, oe.pos.x, REF_H - oe.pos.y + ay)
					end

					oe = towers[row[3]]

					if oe then
						G.line(e.pos.x - ox, REF_H - e.pos.y, oe.pos.x + ax, REF_H - oe.pos.y)
					end

					oe = towers[row[4]]

					if oe then
						G.line(e.pos.x, REF_H - e.pos.y + oy, oe.pos.x, REF_H - oe.pos.y - ay)
					end
				end
			end

			local s2 = 10
			local s3 = 15

			G.setColor(0, 0, 200, 255)

			for h_id, row in pairs(self.store.level.nav_mesh) do
				local e = towers[h_id]

				if not e then
					-- block empty
				else
					for i = 1, 4 do
						local oe = towers[row[i]]

						if oe then
							local tx, ty, ta, a, r

							if i == 1 then
								tx, ty = e.pos.x + ox, REF_H - e.pos.y
								a, r = V.toPolar(oe.pos.x - ax - (e.pos.x + ox), REF_H - oe.pos.y - (REF_H - e.pos.y))
							elseif i == 2 then
								tx, ty = e.pos.x, REF_H - e.pos.y - oy
								a, r = V.toPolar(oe.pos.x - e.pos.x, REF_H - oe.pos.y + ay - (REF_H - e.pos.y - oy))
							elseif i == 3 then
								a, r = V.toPolar(oe.pos.x + ax - (e.pos.x - ox), REF_H - oe.pos.y - (REF_H - e.pos.y))
								tx, ty = e.pos.x - ox, REF_H - e.pos.y
							else
								a, r = V.toPolar(oe.pos.x - e.pos.x, REF_H - oe.pos.y - ay - (REF_H - e.pos.y + oy))
								tx, ty = e.pos.x, REF_H - e.pos.y + oy
							end

							if a then
								G.push()
								G.translate(tx, ty)
								G.rotate(a)
								G.translate(s3, 0)
								G.polygon("fill", s2, 0, 0, s2, 0, -s2)
								G.pop()
							end
						end
					end
				end
			end

			G.pop()
			G.setColor(255, 255, 255, 255)
		end

		if self.DBG_DRAW_BULLET_TRAILS then
			G.push()
			G.scale(gs, gs)
			G.translate(rox, roy)

			if not self.dbg_bullet_canvas then
				self.dbg_bullet_canvas = G.newCanvas()
			end

			G.setCanvas(self.dbg_bullet_canvas)

			for _, e in pairs(self.store.entities) do
				if e.bullet and e.bullet.from and e.bullet.to and (not self.DBG_DRAW_BULLET_TRAILS_SOURCE or e.bullet.source_id == self.DBG_DRAW_BULLET_TRAILS_SOURCE) then
					G.setColor(0, 0, 255, 255)
					G.circle("fill", e.bullet.from.x, REF_H - e.bullet.from.y, 4, 3)
					G.circle("fill", e.bullet.to.x, REF_H - e.bullet.to.y, 4, 5)
					G.setColor(0, 255, 100, 255)
					G.circle("fill", e.pos.x, REF_H - e.pos.y, 1, 6)
				end
			end

			G.setCanvas()
			G.scale(gs, gs)
			G.pop()
			G.setColor(255, 255, 255, 200)
			G.draw(self.dbg_bullet_canvas)
			G.setColor(255, 255, 255, 255)
		elseif self.dbg_bullet_canvas then
			self.dbg_bullet_canvas = nil
		end

		if self.DBG_ENEMY_PAGES then
			game:draw_enemy_pages()
		end
	end
end

require("hero_enhance_mod"):init(game, game_gui)
require("hero_auto_rally"):init(game)

return game

