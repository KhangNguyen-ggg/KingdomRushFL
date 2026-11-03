-- chunkname: @./all/director.lua

local log = require("klua.log"):new("director")
local km = require("klua.macros")
local signal = require("hump.signal")
local mod = require("mod")

require("klua.dump")
require("klua.table")

local features = require("features")
local i18n = require("i18n")
local V = require("klua.vector")
local I = require("klove.image_db")
local F = require("klove.font_db")
local SH = require("klove.shader_db")
local KDB = require("klove.kui_db")
local S = require("sound_db")
local G = love.graphics
local AC = require("achievements")
local LU = require("level_utils")
local infinite_heroes = require("infinite_heroes")
local LU6 = require("level_utils_6")
local RC = require("remote_config")
local ISM = require("input_state_machine")
local marketing = require("marketing")
local storage = require("storage")
local services = require("platform_services")
local director_data = require("data.director_data")
local GS = require("game_settings")
local E = require("entity_db")
local UPGR = require("upgrades")
local power_selection = require("power_selection")
local tower_loadout = require("tower_loadout")
local function T(name)
	return E:get_template(name)
end

local function resolve_kr6_level_mode(level_mode, campaign_variant)
	if level_mode == GAME_MODE_IRON then
		return GAME_MODE_IRON
	elseif level_mode == GAME_MODE_HEROIC then
		return GAME_MODE_BLITZ
	elseif campaign_variant == CAMPAIGN_VARIANT_SPELL_RAID then
		return GAME_MODE_NO_HEROES
	elseif campaign_variant == CAMPAIGN_VARIANT_HERO_RALLY then
		return GAME_MODE_EXTRA_HEROES
	elseif campaign_variant == CAMPAIGN_VARIANT_NOSTALGIC_CLASSIC then
		return GAME_MODE_KR1
	end

	return GAME_MODE_CAMPAIGN
end


local function replace_locale(list, locale)
	local out = {}

	for _, v in pairs(list) do
		local ns = string.gsub(v, "LOCALE", locale or i18n.current_locale)

		table.insert(out, ns)
	end

	return out
end

director = {}
director.item_props = director_data.item_props

function director:init(params)
	KDB:init(KR_PATH_GAME_TARGET .. "/data/kui_templates" .. ";" .. KR_PATH_ALL_TARGET .. "/data/kui_templates" .. ";" .. KR_PATH_GAME .. "/data/kui_templates", DEBUG)
	SH:init(KR_PATH_ALL_TARGET .. "/assets/shaders", true)
	S:init(KR_PATH_GAME_TARGET .. "/assets/sounds")

	I.use_canvas = params.image_db_uses_canvas

	RC:init()
	AC:init()
	services:init()
	marketing:init()

	self.params = params

	self:reset_screen_params()

	I:setMaxThreads(params.max_threads)
	if params.locale then
		main:set_locale(params.locale)
		love.window.setTitle(string.format(_("GAME_TITLE_" .. string.upper(KR_GAME)), KR_FL_VERSION))
	end

	if features.overrides and table.contains(features.overrides, "censored_cn") then
		BLOOD_RED = BLOOD_GRAY
	end

	if KR_TARGET == "phone" and KR_PLATFORM == "android" then
		local filename = "/data/data/" .. version.bundle_id .. "/files/.Defaults.plist"

		storage:import_plist(filename)
	elseif KR_TARGET == "desktop" and KR_GAME == "kr1" and services.services then
		local dir

		if services.services.steam then
			dir = services.services.steam:get_install_dir()
		elseif services.services.gamecenter then
			dir = services.services.gamecenter:get_install_dir()
		elseif services.services.kart then
			dir = services.services.kart:get_install_dir()
		end

		if not dir then
			log.error("Could not find original install dir. Skipping savegame import")
		else
			storage:import_dotnet(dir)
		end
	end

	self.next_item_name = "splash"

	if params.level or params.screen then
		if not storage:load_slot(1) then
			storage:create_slot(1)
		end

		storage:set_active_slot(1)

		if params.screen then
			self.next_item_name = params.screen
			self.next_item_args = {
				custom = params.custom,
				texture_size = params.texture_size
			}
		elseif params.level then
			self.next_item_name = "game"
			self.next_item_args = {
				level_idx = tonumber(params.level),
				level_mode = params.mode and tonumber(params.mode) or GAME_MODE_CAMPAIGN,
				level_difficulty = params.diff and tonumber(params.diff) or DIFFICULTY_NORMAL
			}
		end
	end

	if KR_TARGET == "desktop" then
		if params.screen == "game_editor" then
			local c = love.mouse.newCursor(KR_PATH_ALL_TARGET .. "/assets/cursors/crosshair.png", 16, 16)

			love.mouse.setCursor(c)
		else
			local cursor_name = "hand_32"

			if params.large_pointer then
				cursor_name = params.height < 1080 and "hand_48" or "hand_64"
			end

			self.cursor_up = love.mouse.newCursor(string.format(KR_PATH_ALL_TARGET .. "/assets/cursors/%s_0001.png", cursor_name), 3, 2)
			self.cursor_down = love.mouse.newCursor(string.format(KR_PATH_ALL_TARGET .. "/assets/cursors/%s_0002.png", cursor_name), 3, 2)

			love.mouse.setCursor(self.cursor_up)
		end
	end

	mod:init()
end

function director:quit()
	log.debug("quitting...")
	services:shutdown()
	love.event.quit()
end

function director:get_texture_scale(item_name, ref_res)
	local scale = ref_res / TEXTURE_SIZE_ALIAS[self.params.texture_size]
	local factors = TEXTURE_SIZE_FACTOR[self.params.texture_size]

	if factors and factors[item_name] then
		scale = scale / factors[item_name]
	end

	log.debug("item:%s ref_res:%s texture_size:%s -> scale:%s", item_name, ref_res, self.params.texture_size, scale)

	return scale
end

function director:reset_screen_params(force_scissor)
	local params = self.params
	local aw, ah = love.graphics.getDimensions()

	params.width, params.height = aw, ah

	local screen_aspect = params.width / params.height
	local max_aspect = MAX_SCREEN_ASPECT
	local min_aspect = MIN_SCREEN_ASPECT

	-- Android/Harmony phones wider than 16:9 use a cover-style world/map
	-- transform.  Do not clip those extra columns here: the game and map
	-- cameras fill them while keeping fixed UI on its authored 16:9 layout.
	if IS_ANDROID and ANDROID_WIDESCREEN_ENABLED ~= false and max_aspect < screen_aspect then
		self.scissor_enabled = false
	elseif screen_aspect < min_aspect then
		self.scissor_w = params.width
		self.scissor_h = params.width / min_aspect
		self.scissor_x = 0
		self.scissor_y = (params.height - self.scissor_h) / 2
		self.scissor_enabled = true
	elseif max_aspect < screen_aspect then
		self.scissor_w = params.height * max_aspect
		self.scissor_h = params.height
		self.scissor_x = (params.width - self.scissor_w) / 2
		self.scissor_y = 0
		self.scissor_enabled = true
	else
		self.scissor_enabled = false
	end

	if force_scissor ~= nil then
		log.info("forcing scissor value to %s", force_scissor)

		self.scissor_enabled = force_scissor
	end

	log.info("resetting screen params. w,h:%s,%s scissor:%s %s,%s,%s,%s", aw, ah, self.scissor_enabled, self.scissor_x, self.scissor_y, self.scissor_w, self.scissor_h)
end

function director:item_done_callback(item_name, outcome)
	if self.active_item and self.active_item.done_callback_called then
		log.error("  Done callback already called... Ignoring!")

		return
	end

	self.active_item.done_callback_called = true

	if self.active_item then
		local w = self.active_item.game_gui and self.active_item.game_gui.window or self.active_item.window

		if w then
			log.debug("disabling events for item:%s window:%s", self.active_item.item_name, w)
			w:disable(false)

			if ISM then
				ISM:destroy(w)
			end
		end
	end

	log.debug("DONE CALLBACK FROM %s with outcome %s", item_name, getdump(outcome))

	if outcome then
		if outcome.quit then
			self:quit()

			return
		elseif outcome.next_item_name then
			self.next_item_name = outcome.next_item_name
			self.next_item_args = outcome

			return
		elseif outcome.prevent_loading then
			self.next_item_prevent_loading = true
		end
	end

	if item_name == "comics" then
		self.queued_item = self.active_item.game_item

		return
	end

	local props = self.item_props[item_name]

	if props.next then
		self.next_item_name = props.next
		self.next_item_args = {}

		return
	end
end

function director:get_comic_data_file(comic_idx)
	comic_idx = tonumber(comic_idx) or comic_idx

	local suffix = string.format("/data/comics/%02i.csv", comic_idx)

	-- KR5 comics use 20-42; KR6 comics use 43-54. The desktop target
	-- contains legacy comics with overlapping ids, so use the imported
	-- game data beside their remapped atlases.
	if type(comic_idx) == "number" and comic_idx >= 20 and comic_idx <= 54 then
		local imported_file = KR_PATH_GAME .. suffix

		if love.filesystem.isFile(imported_file) then
			return imported_file
		end
	end

	local file = KR_PATH_GAME_TARGET .. suffix

	if not love.filesystem.isFile(file) then
		file = KR_PATH_GAME .. suffix
	end

	return file
end

local function finish_unload_item(item)
	if item.item_name == "game" then
		item:destroy()

		item.store = nil
	elseif item.destroy then
		item:destroy()
	end

	collectgarbage()
end

function director:unload_item(item, async)
	if not item then
		log.debug("item nil")

		return true
	end

	if async and item._async_unload_started then
		local images_done = I:queue_unload_done()
		local sounds_done = S:queue_unload_done()

		if not images_done or not sounds_done then
			return false
		end

		item._async_unload_started = nil
		finish_unload_item(item)

		return true
	end
	
	if item.item_name == "game" then
		local game = item
		local function unload_atlas(group, scale)
			if async then
				I:queue_unload_atlas(group, scale)
			else
				I:unload_atlas(group, scale, true)
			end
		end
		local function unload_sound(group)
			if async then
				S:queue_unload_group(group)
			else
				S:unload_group(group, true)
			end
		end

		for _, group in pairs(game.gui_required_textures or replace_locale(game.game_gui.required_textures)) do
			local scale = self:get_texture_scale("game_gui", game.game_gui.ref_res)

			unload_atlas(group, scale)
		end
		-- collectgarbage()

		local groups = {}

		groups = table.append(groups, replace_locale(game.required_textures))
		groups = table.append(groups, replace_locale(game.wave_editor_required_textures or {}))
		groups = table.append(groups, replace_locale(game.store.level.required_textures))
		
		-- if game.store.selected_hero then
			-- table.insert(groups, "go_" .. game.store.selected_hero)
		-- end

		for _, group in pairs(groups) do
			local scale = self:get_texture_scale("game", game.ref_res)
			unload_atlas(group, scale)
		end

		for _, group in pairs(replace_locale(game.scale_required_textures)) do
			local scale = self:get_texture_scale("game", game.ref_res * TEXTURE_SIZE_FACTOR.kr_45)
			unload_atlas(group, scale)
		end

		for _, group in pairs(replace_locale(game.sc_branch_skill_textures or {})) do
			local scale = self:get_texture_scale("game", game.ref_res * TEXTURE_SIZE_FACTOR.kr_45 * TEXTURE_SIZE_FACTOR.kr_45)
			unload_atlas(group, scale)
		end

		for _, group in pairs(replace_locale(game.wave_editor_scale_required_textures or {})) do
			local scale = self:get_texture_scale("game", game.ref_res * TEXTURE_SIZE_FACTOR.kr_45)
			unload_atlas(group, scale)
		end

		for _, group in pairs(replace_locale(game.scale_required_textures_enemy)) do
			local scale = self:get_texture_scale("game", game.ref_res * TEXTURE_SIZE_FACTOR.kr_45 * 2)
			unload_atlas(group, scale)
		end
		-- collectgarbage()

		unload_atlas("temp_game_texts", game.store.screen_scale)

		if item.required_sounds then
			for _, group in pairs(item.required_sounds) do
				unload_sound(group)
			end
		end

		if game.store.level.required_sounds then
			for _, group in pairs(game.store.level.required_sounds) do
				unload_sound(group)
			end
		end

		-- if game.store.selected_hero then
			-- S:unload_group(game.store.selected_hero)
		-- end

		if async then
			item._async_unload_started = true

			return false
		end

		I:purge_atlas()
		finish_unload_item(item)

		return true
	elseif not item.keep_loaded then
		local textures = item.required_textures
		local function unload_atlas(group, scale)
			if async then
				I:queue_unload_atlas(group, scale)
			else
				I:unload_atlas(group, scale, true)
			end
		end
		local function unload_sound(group)
			if async then
				S:queue_unload_group(group)
			else
				S:unload_group(group, true)
			end
		end

		if textures then
			local scale = self:get_texture_scale(item.item_name, item.ref_res)

			for _, group in pairs(replace_locale(textures, item.locale_at_requirement)) do
				unload_atlas(group, scale)
			end
		end

		if item.required_sounds then
			for _, group in pairs(item.required_sounds) do
				unload_sound(group)
			end
		end

		if async then
			item._async_unload_started = true

			return false
		end

		-- Release a screen's atlas/sound groups together, then collect once.
		I:purge_atlas()
		finish_unload_item(item)

		return true
	end

	return true
end

--第6关结束后props出了问题（应该是漫画）
function director:queue_load_item_named(name, force_reload)
	local function _require(name, force)
		if force_reload or force then
			package.loaded[name] = nil
		end

		local r = require(name)

		r.locale_at_requirement = i18n.current_locale

		return r
	end

	local props = self.item_props[name]

	self:reset_screen_params(props and props.scissor)

	local show_loading = props.show_loading

	if self.next_item_prevent_loading then
		show_loading = false
		self.next_item_prevent_loading = nil
	end

	if show_loading then
		local loading = _require("screen_loading")
		local level_idx

		if self.next_item_args and self.next_item_args.level_idx then
			level_idx = self.next_item_args.level_idx
		elseif game and game.store then
			level_idx = game.store.level_idx
		end

		if loading.update_required_textures then
			loading:update_required_textures(name, level_idx)
		end

		self:load_texture_groups(loading.required_textures, self.params.texture_size, loading.ref_res, false)

		if loading.required_sounds then
			self:load_sound_groups(loading.required_sounds)
		end

		loading:init(self.params.width, self.params.height)
		loading:close()

		self.queue_unload_item = self.active_item
		self.active_item = loading
		-- Present the loading screen before synchronous atlas metadata/template work.
		if G.isActive() then
			G.push("all")
			G.setCanvas()
			G.origin()
			G.setScissor()
			G.clear()
			loading:draw()
			G.present()
			G.pop()
		end
	end

	if props.type == "screen" then
		local item = _require(props.src, self.next_item_args and self.next_item_args.force_reload)

		item.item_name = name
		item.args = self.next_item_args
		if item.required_textures then
			self:load_texture_groups(replace_locale(item.required_textures), self.params.texture_size, item.ref_res, true, name)
		end

		if item.ref_res then
			item.screen_scale = self:get_texture_scale(name, item.ref_res)
		end

		self.queued_item = item

		if item.required_sounds then
			self:load_sound_groups(item.required_sounds)
		end
	elseif props.type == "comic" then
		local args = self.next_item_args
		local comic_idx = args.custom
		local item = _require("screen_comics")

		item.item_name = "comics"
		item.required_textures = {
			"loading_common",
			"comic_" .. comic_idx
		}
		item.comic_data = love.filesystem.read(self:get_comic_data_file(comic_idx))

		self:load_texture_groups(replace_locale(item.required_textures), self.params.texture_size, item.ref_res, true)

		self.queued_item = item
	elseif props.type == "game" then
		local game_gui = _require("game_gui")
		local game = _require("game")
		local args = self.next_item_args
		local user_data = storage:load_slot()
		game.item_name = "game"
		game.max_fps = DRAW_FPS

		game.store = {}
		game.store.level_idx = args.level_idx
		game.store.campaign_variant = args.campaign_variant or CAMPAIGN_VARIANT_REGULAR
		if args.level_idx >= 251 and args.level_idx <= 269 then
			game.store.level_mode_6 = resolve_kr6_level_mode(args.level_mode, game.store.campaign_variant)
		end
		local nostalgic_classic = args.level_mode == GAME_MODE_CAMPAIGN and game.store.campaign_variant == CAMPAIGN_VARIANT_NOSTALGIC_CLASSIC

		local map_data = require("data.map_data")
		local tower_generations = tower_loadout.normalize(user_data)
		local tower_mode = km.clamp(0, 2, user_data.liuhui.use3tower_count or 0)
		local regular_tower_loadout = not user_data.liuhui.rand_tower or user_data.liuhui.rand_tower == 0
		local kr6_legacy_enabled = not nostalgic_classic and regular_tower_loadout and tower_mode ~= 2 and tower_generations[5]
		local hero_game_ver = map_data.hero_game_ver
		local rebborn_hero_sounds = {
			hero_deadeye = true,
			hero_ember = true,
			hero_oberon = true,
			hero_penumbra = true,
			hero_zezitra = true
		}
		local rebborn_summon_heroes = {
			"hero_oberon",
			"hero_ember",
			"hero_penumbra",
			"hero_zezitra",
			"hero_deadeye"
		}
		local hero_summon_6 = require("hero_summon_6")
		local function append_unique(list, value)
			for _, item in ipairs(list) do
				if item == value then
					return
				end
			end

			table.insert(list, value)
		end

		local tower_5_data_tmp = map_data.tower_5_data

		local HERO_5_START = 48

		
		game.scale_required_textures_enemy = {
			--在这里添加5代敌人的图像，修改每关的出怪列表，注释掉前面的“--”即可添加敌人。
			--"go_enemies_sea_of_trees", 	--5代第1大关敌人
			--"go_enemies_terrain_2",  		--5代第2大关敌人
			--"go_enemies_terrain_3",  		--5代第3大关敌人
			--"go_enemies_terrain_4",  		--5代第4大关敌人（亡魂支线）
			--"go_enemies_terrain_5",  		--5代第5大关敌人（鳄鱼支线）
			--"go_enemies_terrain_6",  		--5代第6大关敌人（矮人支线）
			--"go_enemies_terrain_7",  		--5代第7大关敌人（蜘蛛支线）
		}

		math.randomseed(os.time())
		local function random_hero()
			local random_result = nil
			while true do
				random_result = math.random(1, #map_data.hero_data)
				if map_data.hero_data[random_result].transplanting == nil then
					break
				end
			end
			return random_result
		end
		--对英雄进行随机
		if not (args.level_mode == GAME_MODE_CAMPAIGN and game.store.campaign_variant == CAMPAIGN_VARIANT_SPELL_RAID) and not infinite_heroes.allowed(game.store, user_data, args.level_mode) and user_data.liuhui.rand_hero and user_data.liuhui.rand_hero == 1 then
			local hero_data = map_data.hero_data
			if game.store.campaign_variant == CAMPAIGN_VARIANT_HERO_RALLY and args.level_mode == GAME_MODE_CAMPAIGN then
				for i = 1, 4 do
					user_data.liuhui_hero.rallylist[i] = random_hero()
				end
			elseif not nostalgic_classic and user_data.liuhui_hero.usedoublehero then
				user_data.liuhui_hero.herolist[1] = random_hero()--math.random(1, #hero_data)
				user_data.liuhui_hero.herolist[2] = random_hero()--math.random(1, #hero_data)
				--local ht1 = hero_data[user_data.liuhui_hero.herolist[1]].name
				--local ht = hero_data[user_data.liuhui_hero.herolist[2]].name
			else
				rand_hero = random_hero()--math.random(1, #hero_data)
				user_data.heroes.selected = hero_data[rand_hero].name
			end
			storage:save_slot(user_data)
		end
		user_data = storage:load_slot()
		local ht = user_data.heroes.selected 
		local active_hero_names = {}
		game.store.infinite_hero_names = nil
		if infinite_heroes.allowed(game.store, user_data, args.level_mode) then
			local names = infinite_heroes.names(user_data, map_data.hero_data)
			if #names == 0 then names = {ht} end
			game.store.infinite_hero_names = names
		end

		if game.store.infinite_hero_names then
			for _, name in ipairs(game.store.infinite_hero_names) do table.insert(active_hero_names, name) end
		elseif args.level_mode == GAME_MODE_CAMPAIGN and game.store.campaign_variant == CAMPAIGN_VARIANT_HERO_RALLY then
			local defaults = {"hero_gerald", "hero_alric", "hero_elves_archer", "hero_orc"}

			for i = 1, 4 do
				local idx = user_data.liuhui_hero.rallylist and user_data.liuhui_hero.rallylist[i]
				local hero_name = idx and map_data.hero_data[idx] and map_data.hero_data[idx].name or defaults[i]

				table.insert(active_hero_names, hero_name)
			end
		elseif not (args.level_mode == GAME_MODE_CAMPAIGN and game.store.campaign_variant == CAMPAIGN_VARIANT_SPELL_RAID) then
			if not nostalgic_classic and user_data.liuhui_hero.usedoublehero then
				table.insert(active_hero_names, map_data.hero_data[user_data.liuhui_hero.herolist[1]].name)
				table.insert(active_hero_names, map_data.hero_data[user_data.liuhui_hero.herolist[2]].name)
			else
				table.insert(active_hero_names, ht)
			end
		end
		game.store.active_hero_names = active_hero_names

		--对塔进行随机
		--string.sub(name, 1, -5)
		local tower_list = {
			archer = {},
			barrack = {},
			mage = {},
			engineer = {},
		}
		game.store.random_tower_list = {
			random0 = {},
			random1 = {},
			random2 = {},
			random3 = {},
			random4 = {},
			random20 = {},
			random21 = {},
			random22 = {},
			random23 = {},
			random24 = {},
		}
		game.store.tmp_random_menu = {}
		game.store.liuhui_rand_tower = 0
		if user_data.liuhui.rand_tower and user_data.liuhui.rand_tower >= 1 then
			game.store.liuhui_rand_tower = 1
			--抽箭塔
			for it = 1, user_data.liuhui.rand_tower do
				local finished = false
				local tower_id = 0
				while finished == false do
					tower_id = math.random(1, #map_data.random.archer)
					if not table.contains(tower_list.archer, map_data.random.archer[tower_id]) then
						table.insert(tower_list.archer, map_data.random.archer[tower_id])
						finished = true
					end
				end

				local rank1 = table.find(map_data.tower_5_data, function(k, v)
					return v.name == map_data.random.archer[tower_id]
				end)
				local rank2 = table.find(map_data.tower_3_data, function(k, v)
					return v.name == map_data.random.archer[tower_id]
				end)
				local rank3 = table.find(map_data.tower_4_data, function(k, v)
					return v.name == map_data.random.archer[tower_id]
				end)
				--加入template
				local template_name = ""
				local template_json = {}
				if rank2 then
					template_name = T(map_data.tower3_menu_json[1][rank2].action_arg).build_name
					template_json = table.deepclone(map_data.tower3_menu_json[1][rank2])
				elseif rank3 then
					template_name = T(map_data.tower4_menu_json[1][rank3].action_arg).build_name
					template_json = table.deepclone(map_data.tower4_menu_json[1][rank3])
				else
					template_name = T(map_data.tower_menu_json[rank1].action_arg).build_name
					template_json = table.deepclone(map_data.tower_menu_json[rank1])
				end
				table.insert(game.store.random_tower_list.random1, template_name)
				table.insert(game.store.random_tower_list.random0, template_name)
				if template_name == "tower_archer_1_v" then
					table.insert(game.store.random_tower_list.random21, "tower_archer_2_v")
					table.insert(game.store.random_tower_list.random20, "tower_archer_2_v")
				else
					table.insert(game.store.random_tower_list.random21, string.sub(template_name, 1,-2).."2")
					table.insert(game.store.random_tower_list.random20, string.sub(template_name, 1,-2).."2")
				end
				table.insert(game.store.tmp_random_menu, template_json)
			end
			--抽兵营
			for it = 1, user_data.liuhui.rand_tower do
				local finished = false
				local tower_id = 0
				while finished == false do
					tower_id = math.random(1, #map_data.random.barrack)
					if not table.contains(tower_list.barrack, map_data.random.barrack[tower_id]) then
						table.insert(tower_list.barrack, map_data.random.barrack[tower_id])
						finished = true
					end
				end

				local rank1 = table.find(map_data.tower_5_data, function(k, v)
					return v.name == map_data.random.barrack[tower_id]
				end)
				local rank2 = table.find(map_data.tower_3_data, function(k, v)
					return v.name == map_data.random.barrack[tower_id]
				end)
				local rank3 = table.find(map_data.tower_4_data, function(k, v)
					return v.name == map_data.random.barrack[tower_id]
				end)
				--加入template
				local template_name = ""
				local template_json = {}
				if rank2 then
					template_name = T(map_data.tower3_menu_json[1][rank2].action_arg).build_name
					template_json = table.deepclone(map_data.tower3_menu_json[1][rank2])
				elseif rank3 then
					template_name = T(map_data.tower4_menu_json[1][rank3].action_arg).build_name
					template_json = table.deepclone(map_data.tower4_menu_json[1][rank3])
				else
					template_name = T(map_data.tower_menu_json[rank1].action_arg).build_name
					template_json = table.deepclone(map_data.tower_menu_json[rank1])
				end
				table.insert(game.store.random_tower_list.random2, template_name)
				table.insert(game.store.random_tower_list.random0, template_name)
				if template_name == "tower_barrack_1_v" then
					table.insert(game.store.random_tower_list.random22, "tower_barrack_2_v")
					table.insert(game.store.random_tower_list.random20, "tower_barrack_2_v")
				else
					table.insert(game.store.random_tower_list.random22, string.sub(template_name, 1,-2).."2")
					table.insert(game.store.random_tower_list.random20, string.sub(template_name, 1,-2).."2")
				end

				table.insert(game.store.tmp_random_menu, template_json)
			end
			--抽法师
			for it = 1, user_data.liuhui.rand_tower do
				local finished = false
				local tower_id = 0
				while finished == false do
					tower_id = math.random(1, #map_data.random.mage)
					if not table.contains(tower_list.mage, map_data.random.mage[tower_id]) then
						table.insert(tower_list.mage, map_data.random.mage[tower_id])
						finished = true
					end
				end

				local rank1 = table.find(map_data.tower_5_data, function(k, v)
					return v.name == map_data.random.mage[tower_id]
				end)
				local rank2 = table.find(map_data.tower_3_data, function(k, v)
					return v.name == map_data.random.mage[tower_id]
				end)
				local rank3 = table.find(map_data.tower_4_data, function(k, v)
					return v.name == map_data.random.mage[tower_id]
				end)
				--加入template
				local template_name = ""
				local template_json = {}
				if rank2 then
					template_name = T(map_data.tower3_menu_json[1][rank2].action_arg).build_name
					template_json = table.deepclone(map_data.tower3_menu_json[1][rank2])
				elseif rank3 then
					template_name = T(map_data.tower4_menu_json[1][rank3].action_arg).build_name
					template_json = table.deepclone(map_data.tower4_menu_json[1][rank3])
				else
					template_name = T(map_data.tower_menu_json[rank1].action_arg).build_name
					template_json = table.deepclone(map_data.tower_menu_json[rank1])
				end
				table.insert(game.store.random_tower_list.random3, template_name)
				table.insert(game.store.random_tower_list.random0, template_name)
				if template_name == "tower_mage_1_v" then
					table.insert(game.store.random_tower_list.random23, "tower_mage_2_v")
					table.insert(game.store.random_tower_list.random20, "tower_mage_2_v")
				else
					table.insert(game.store.random_tower_list.random23, string.sub(template_name, 1,-2).."2")
					table.insert(game.store.random_tower_list.random20, string.sub(template_name, 1,-2).."2")
				end

				table.insert(game.store.tmp_random_menu, template_json)
			end
			--抽炮塔
			for it = 1, user_data.liuhui.rand_tower do
				local finished = false
				local tower_id = 0
				while finished == false do
					tower_id = math.random(1, #map_data.random.engineer)
					if not table.contains(tower_list.engineer, map_data.random.engineer[tower_id]) then
						table.insert(tower_list.engineer, map_data.random.engineer[tower_id])
						finished = true
					end
				end

				local rank1 = table.find(map_data.tower_5_data, function(k, v)
					return v.name == map_data.random.engineer[tower_id]
				end)
				local rank2 = table.find(map_data.tower_3_data, function(k, v)
					return v.name == map_data.random.engineer[tower_id]
				end)
				local rank3 = table.find(map_data.tower_4_data, function(k, v)
					return v.name == map_data.random.engineer[tower_id]
				end)
				--加入template
				local template_name = ""
				local template_json = {}
				if rank2 then
					template_name = T(map_data.tower3_menu_json[1][rank2].action_arg).build_name
					template_json = table.deepclone(map_data.tower3_menu_json[1][rank2])
				elseif rank3 then
					template_name = T(map_data.tower4_menu_json[1][rank3].action_arg).build_name
					template_json = table.deepclone(map_data.tower4_menu_json[1][rank3])
				else
					template_name = T(map_data.tower_menu_json[rank1].action_arg).build_name
					template_json = table.deepclone(map_data.tower_menu_json[rank1])
				end
				table.insert(game.store.random_tower_list.random4, template_name)
				table.insert(game.store.random_tower_list.random0, template_name)
				table.insert(game.store.random_tower_list.random24, string.sub(template_name, 1,-2).."2")
				table.insert(game.store.random_tower_list.random20, string.sub(template_name, 1,-2).."2")
				table.insert(game.store.tmp_random_menu, template_json)
			end
			
		end

		

		game.deferred_cheat_textures = {}
		game.deferred_cheat_scale_textures = {}

		local sc_branch_loaded = false
		local sc_frost_gem_skill_icons_loaded = false

		--if user_data.liuhui.cp_mode == false then
		--禁用兼容模式
		if true then
			game.required_textures = {
				--必需品
				"go_decals",
				"go_enemies_common",
				"go_towers_44",
				"go_towers_1-galaxy",
				"rebbborn_fig",
				"gui_common_123mod",
				"spell_selection_icons",
				"dolia_spell_assets",
				"go_towers_special",
			 	"go_barrack_pirates",
				"go_enemies_desert_b",
				"go_enemies_desert",
				"go_hero_munra",
				"go_towers_1",--防御塔
				"go_towers_2",--援兵相关
				"go_reinforcement_skin_0",
				"go_reinforcement_skin_1",
				"go_reinforcement_skin_2",
				"go_reinforcement_skin_3",
				"kr4_sapos",
				--"ultimate45",
				--"kr4_herogui",
				"kr4_hero_power",
				--"kr4_hero_room",
				"kr5_hero_power",
				--神灯许愿台
				"go_hero_baby_malik",
				"go_hero_alleria_g3",
				"go_hero_bolverk",
				"go_hero_vampiress",
				--征服
				"gui_common_v",
				"gui_portraits_v",
				"go_towers_v",
				"go_towers_rebborn",
				"rebborn_heroes_gui",
				"terrains_6",
			}
			if game.store.level_mode_6 then
				table.insert(game.required_textures, "go_decals_g6")
			end
			game.scale_required_textures = {
				"go_towers",
				"terrains_5",
				"terrains_4",
				"go_commons",--5代相关
			}
			
			for _, hero_name in ipairs(active_hero_names) do
				local boss = infinite_heroes.get_boss(hero_name)
				if boss then
					for _, texture in ipairs(boss.unscaled_textures or {}) do
						append_unique(game.required_textures, texture)
					end
					for _, texture in ipairs(boss.textures) do
						append_unique(boss.scaled and game.scale_required_textures or game.required_textures, texture)
					end
                    if boss.kind=="blackburn" and require("blackburn_enhance").level(user_data)==3 then
                        append_unique(game.required_textures,"go_enemies_blackburn")
                    end
				elseif hero_name == "hero_alleria" or hero_game_ver(hero_name) == 6 then
					table.insert(game.required_textures, "go_" .. hero_name)
				elseif hero_game_ver(hero_name) >= 4 then
					table.insert(game.scale_required_textures, "go_" .. hero_name)
				else
					table.insert(game.required_textures, "go_" .. hero_name)
				end
			end
			if not nostalgic_classic and user_data.liuhui.cheathero then
				table.insert(game.deferred_cheat_textures, "go_hero_all_1")
				table.insert(game.deferred_cheat_textures, "go_hero_all_2")
				table.insert(game.deferred_cheat_textures, "go_hero_all_3-1")
				table.insert(game.deferred_cheat_textures, "go_hero_all_3-2")
				table.insert(game.deferred_cheat_textures, "go_hero_voltaire")
				table.insert(game.deferred_cheat_textures, "go_hero_viper")
				table.insert(game.deferred_cheat_textures, "go_hero_munra")
				table.insert(game.required_textures, "rebborn_hero_summon_icons")

				for _, hero_name in ipairs(rebborn_summon_heroes) do
					append_unique(game.deferred_cheat_textures, "go_" .. hero_name)
				end
			end

			-- SC Reset 3.6 branches share the selected official KR4 parent tower.
			local sc_branch_textures = {
				shadow_archer = {"go_towers_dove43_sniper_tower"},
				grim_cemetery = {"go_towers_dove43_plague_hospital"},
				ogre_shipwreck = {"go_towers_dove43_blastin_bullriders"},
				spirit_mausoleum = {"go_towers_dove43_wifi_babies"},
				wicked_sisters = {"go_towers_dove43_wicked_sisters_stregi", "go_hero_witch", "go_towers_shadow_archer"},
				melting_furnace = {"go_towers_dove43_command_center"},
				orc_shaman = {"go_towers_dove43_ice_cooler"},
				goblirang = {"go_towers_dove43_machine_gunner"},
				bone_flingers = {"go_towers_sc_rat_tower"},
				twilight_elves_barrack = {"go_towers_sc_twilight_avenger"},
				rotten_forest = {"go_towers_sc_nuclear_tower"},
				balloon = {"go_towers_sc_drone_hive"},
				ignis_altar = {"go_towers_sc_thermalblast_spa"},
				shaolin = {"go_towers_sc_fuhai_temple"},
				infernal_mage = {"go_towers_sc_winter", "kr4_frozen_north", "kr4_hielo", "go_hero_eiskalt"},
				blazing_watcher = {"go_towers_sc_frost_gem"}
			}
			game.sc_branch_skill_textures = {}
			game.store.dove43_required_exoskeletons = {}
			local function load_sc_branch(name)
				local textures = sc_branch_textures[name]

				if textures then
					for _, texture in ipairs(textures) do
						table.insert(game.scale_required_textures, texture)
					end
					for _, exo in ipairs(GS.towers_dove43_exoskeletons[name] or {}) do
						append_unique(game.store.dove43_required_exoskeletons, exo)
					end
					if name == "blazing_watcher" and not sc_frost_gem_skill_icons_loaded then
						table.insert(game.sc_branch_skill_textures, "go_towers_sc_frost_gem_skill_icons")
						sc_frost_gem_skill_icons_loaded = true
					end
					if not string.find(textures[1], "go_towers_dove43_", 1, true) then
						sc_branch_loaded = true
					end
				end
			end

			--防御塔加载
			local kr6_ui_loaded = false
			local tower_entry_by_name = {}

			for _, tower_entry in ipairs(tower_5_data_tmp) do
				tower_entry_by_name[tower_entry.name] = tower_entry
			end

			local function load_tower_texture(tower_name, generation)
				local texture = "go_towers_" .. tower_name

				if generation == 6 then
					append_unique(game.required_textures, texture)
					if not kr6_ui_loaded then
						append_unique(game.required_textures, "kr6_ui_icons")
						kr6_ui_loaded = true
					end
				else
					append_unique(game.scale_required_textures, texture)
				end
			end

			if game.store.level_mode_6 == GAME_MODE_KR1 or kr6_legacy_enabled then
				for _, tower_name in ipairs(map_data.tower_6_legacy_names or {}) do
					load_tower_texture(tower_name, 6)
				end
			end

			if not nostalgic_classic and regular_tower_loadout then
				for i = 1,user_data.tower_pick do
					local num = user_data.towers[i]
					local tower_entry = tower_5_data_tmp[num]

					if tower_entry then
						local tower_name = tower_entry.name

						load_tower_texture(tower_name, tower_entry.generation)
						load_sc_branch(tower_name)
					end
				end
			elseif not nostalgic_classic then
				for kk, vv in pairs(tower_list) do
					for i = 1,#vv do
						local tower_entry = tower_entry_by_name[vv[i]]

						if tower_entry then
							load_tower_texture(tower_entry.name, tower_entry.generation)
							load_sc_branch(vv[i])
						end
					end
				end
			end
			if sc_branch_loaded then
				table.insert(game.scale_required_textures, "go_towers_sc_branch_ui")
				table.insert(game.sc_branch_skill_textures, "go_towers_sc_branch_skill_icons")
			end
			
			if not nostalgic_classic and user_data.liuhui.cheat5 == true then

				for i = HERO_5_START, #map_data.hero_data do
					if map_data.hero_data[i].transplanting == nil and hero_game_ver(map_data.hero_data[i].name) ~= 6 then
						local hero_name = map_data.hero_data[i].name
						append_unique(game.deferred_cheat_scale_textures, "go_" .. hero_name)
					end
				end
			end
			if not nostalgic_classic and user_data.liuhui.cheat6 == true then
				for _, hero in ipairs(hero_summon_6) do
					append_unique(game.deferred_cheat_textures, "go_" .. hero.name)
				end
			end

			if not nostalgic_classic and user_data.liuhui.cheat5_special == true then
				table.insert(game.deferred_cheat_textures, "go_stage104")
				table.insert(game.deferred_cheat_textures, "go_stage113")
				table.insert(game.deferred_cheat_textures, "go_stage117")
				table.insert(game.deferred_cheat_textures, "go_stage118")
				table.insert(game.deferred_cheat_textures, "go_stage120")
				table.insert(game.deferred_cheat_textures, "go_stage122")
				table.insert(game.deferred_cheat_scale_textures, "go_g5_stage528")
				table.insert(game.deferred_cheat_scale_textures, "go_stage137")
				
				table.insert(game.required_textures, "gui_common_5_D")

				table.insert(game.deferred_cheat_scale_textures, "go_stage157")
				table.insert(game.deferred_cheat_scale_textures, "kr4_frozen_north")
				table.insert(game.deferred_cheat_scale_textures, "kr4_mercenary_troll_hut")
				table.insert(game.deferred_cheat_scale_textures, "kr4_hielo")
				table.insert(game.deferred_cheat_scale_textures, "go_stage163")
				table.insert(game.deferred_cheat_scale_textures, "kr4_linirea")
				table.insert(game.deferred_cheat_scale_textures, "kr4_spider_nest")
				table.insert(game.deferred_cheat_scale_textures, "kr4_spider_icons")
				table.insert(game.deferred_cheat_scale_textures, "go_stage165")
				table.insert(game.deferred_cheat_scale_textures, "kr4_chino")
				table.insert(game.deferred_cheat_scale_textures, "go_stage184")
				table.insert(game.deferred_cheat_scale_textures, "kr4_sandstorm")
				table.insert(game.deferred_cheat_scale_textures, "kr4_sandstorm_aux")
				table.insert(game.deferred_cheat_scale_textures, "kr4_power_reinforcements")
				table.insert(game.deferred_cheat_scale_textures, "go_hero_isfet")
			end

			if not nostalgic_classic and user_data.liuhui.cheat5_dragon == true then
				table.insert(game.deferred_cheat_textures, "go_stage135")
				table.insert(game.deferred_cheat_textures, "go_wukong_elemental_holders")
			end
			
			if args.level_idx == 5 then
				table.insert(game.required_textures, "go_hero_alleria_g3")
			end
		end
		
		--然后再补全sound
		game.required_sounds = {
			"common",
			"common5",
			"ElvesTowerTaunts",
			"ElvesCommonSounds",
			"stage_20",
			"stage_13",
			"terrain_wukong_common"
		}
		if not nostalgic_classic then
			local power_dependencies = power_selection.get_selected_dependencies(user_data)

			for _, texture in ipairs(power_dependencies.required_textures) do
				append_unique(game.required_textures, texture)
			end

			for _, texture in ipairs(power_dependencies.scale_required_textures) do
				append_unique(game.scale_required_textures, texture)
			end

			for _, sound in ipairs(power_dependencies.required_sounds) do
				append_unique(game.required_sounds, sound)
			end
		end
		if not nostalgic_classic then
			table.insert(game.required_sounds, "tower_hermit_toad")
		end
		local kr6_sounds_loaded = false

		if kr6_legacy_enabled then
			for _, tower_name in ipairs(map_data.tower_6_legacy_names or {}) do
				append_unique(game.required_sounds, "tower_" .. tower_name)
			end

			append_unique(game.required_sounds, "kr6_common_gameplay")
			kr6_sounds_loaded = true
		end

		if not nostalgic_classic and regular_tower_loadout then
			for i = 1,user_data.tower_pick do
				local num = user_data.towers[i]
				local tower_entry = tower_5_data_tmp[num]

				if tower_entry then
					local strs = ("tower_"..tower_entry.name)

					append_unique(game.required_sounds, strs)
					if tower_entry.generation == 6 and not kr6_sounds_loaded then
						append_unique(game.required_sounds, "kr6_common_gameplay")
						kr6_sounds_loaded = true
					end
				end
			end
		elseif not nostalgic_classic then
			for kk, vv in pairs(tower_list) do
				for i = 1,#vv do
					local rank1 = table.find(map_data.tower_5_data, function(k, v)
						return v.name == vv[i]
					end)
					if rank1 then
						local tower_entry = map_data.tower_5_data[rank1]
						local strs = ("tower_"..vv[i])
						append_unique(game.required_sounds, strs)
						if tower_entry.generation == 6 and not kr6_sounds_loaded then
							append_unique(game.required_sounds, "kr6_common_gameplay")
							kr6_sounds_loaded = true
						end
					end
				end
			end
		end
		if not nostalgic_classic and user_data.liuhui.cheat5 == true then
			for i = HERO_5_START, #map_data.hero_data do
				if map_data.hero_data[i].transplanting == nil and hero_game_ver(map_data.hero_data[i].name) ~= 6 then
					table.insert(game.required_sounds, map_data.hero_data[i].name)
				end
			end
			table.insert(game.required_sounds, "stage_137")
		end
		if not nostalgic_classic and user_data.liuhui.cheat6 == true then
			for _, hero in ipairs(hero_summon_6) do
				append_unique(game.required_sounds, GS.heroes_required_sound_groups[hero.name])
			end
		end
		if not nostalgic_classic and user_data.liuhui.cheat5_special == true then
			table.insert(game.required_sounds, "sounds_stage157")
			table.insert(game.required_sounds, "sounds_stage163")
			table.insert(game.required_sounds, "sounds_stage165")
			table.insert(game.required_sounds, "branch_campaigns")
			table.insert(game.required_sounds, "powers_kr4")
		end
		if not nostalgic_classic and user_data.liuhui.cheathero then
			for _, hero_name in ipairs(rebborn_summon_heroes) do
				append_unique(game.required_sounds, hero_name)
			end
		end
		if sc_branch_loaded then
			table.insert(game.required_sounds, "sc_branch_towers")
		end
		local dove43_sounds = {["go_towers_dove43_sniper_tower"]="d43_sniper_tower",["go_towers_dove43_plague_hospital"]="d43_plague_hospital",["go_towers_dove43_command_center"]="d43_command_center",["go_towers_dove43_ice_cooler"]="d43_ice_cooler",["go_towers_dove43_machine_gunner"]="d43_machine_gunner",["go_towers_dove43_blastin_bullriders"]="d43_blastin_bullriders",["go_towers_dove43_wifi_babies"]="d43_wifi_babies",["go_towers_dove43_wicked_sisters_stregi"]="d43_wicked_sisters_stregi"}
		for _, texture in ipairs(game.scale_required_textures) do
			if dove43_sounds[texture] then append_unique(game.required_sounds, dove43_sounds[texture]) end
		end
		if table.contains(game.scale_required_textures, "go_towers_dove43_wicked_sisters_stregi") then
			append_unique(game.required_sounds, "hero_witch")
			append_unique(game.required_sounds, "tower_shadow_archer")
		end

		for _, hero_name in ipairs(active_hero_names) do
			local boss = infinite_heroes.get_boss(hero_name)
			if boss then
				for _, group in ipairs(boss.sounds or {}) do append_unique(game.required_sounds, group) end
			elseif hero_game_ver(hero_name) >= 4 or rebborn_hero_sounds[hero_name] then
				local sound_group = GS.heroes_required_sound_groups and GS.heroes_required_sound_groups[hero_name] or hero_name

				append_unique(game.required_sounds, sound_group)
			end
		end

		game.store.level_name = "level" .. string.format("%02i", args.level_idx)
		if args.level_idx >= 101 then
			local local_level = require(string.format("data.levels.level%02i_data",args.level_idx))
			--game.scale_required_textures = game.scale_required_textures + local_level.scale_required_textures
			if local_level.scale_required_textures then
				for k, v in pairs(local_level.scale_required_textures) do
					table.insert(game.scale_required_textures, v)
				end
			end
		end
		game.store.level_mode = args.level_mode
		game.store.level_difficulty = args.level_difficulty
		game.store.screen_scale = self:get_texture_scale("game", REF_H)
		game.store.texture_size = self.params.texture_size
		game.store.level = game.store.level_mode_6 and LU6.load_level(game.store, game.store.level_name) or LU.load_level(game.store, game.store.level_name)
		game.store.user_data = user_data

		game.wave_editor_required_textures = {}
		game.wave_editor_scale_required_textures = {}
		local wave_editor_ok, wave_editor_store = pcall(require, "wave_editor_store")

		if wave_editor_ok and wave_editor_store then
			local atlases_ok, normal, scaled = pcall(wave_editor_store.active_atlases, game.store.level_name, game.store.level_mode)

			if atlases_ok then
				game.wave_editor_required_textures = normal or game.wave_editor_required_textures
				game.wave_editor_scale_required_textures = scaled or game.wave_editor_scale_required_textures
			else
				log.error("Failed to collect wave editor atlases for %s: %s", game.store.level_name, tostring(normal))
			end
		end
		
        if require("blackburn_enhance").level(user_data)==3 and
            table.contains(game.wave_editor_required_textures,"go_stage70") then
            append_unique(game.required_textures,"go_enemies_blackburn")
        end

		if require("navira_duelist").level(user_data)==1 then
			for _,groups in ipairs({game.required_textures,game.scale_required_textures,game.scale_required_textures_enemy,game.wave_editor_required_textures,game.wave_editor_scale_required_textures,game.store.level.required_textures}) do
				if table.contains(groups,"go_stage119") then
					for _,texture in ipairs(require("navira_duelist").shield_textures) do append_unique(game.required_textures,texture) end
					break
				end
			end
		end

        -- collectgarbage()
		self:load_texture_groups(replace_locale(game.scale_required_textures), self.params.texture_size, game.ref_res * TEXTURE_SIZE_FACTOR.kr_45, true, "game")
		self:load_texture_groups(replace_locale(game.sc_branch_skill_textures or {}), self.params.texture_size, game.ref_res * TEXTURE_SIZE_FACTOR.kr_45 * TEXTURE_SIZE_FACTOR.kr_45, true, "game")
		self:load_texture_groups(replace_locale(game.scale_required_textures_enemy), self.params.texture_size, game.ref_res * TEXTURE_SIZE_FACTOR.kr_45 * 2, true, "game")
		self:load_texture_groups(replace_locale(game.wave_editor_scale_required_textures), self.params.texture_size, game.ref_res * TEXTURE_SIZE_FACTOR.kr_45, true, "game")
		self:load_texture_groups(replace_locale(game.required_textures), self.params.texture_size, game.ref_res, true, "game")
		self:load_texture_groups(replace_locale(game.wave_editor_required_textures), self.params.texture_size, game.ref_res, true, "game")
		self:load_texture_groups(replace_locale(game.store.level.required_textures), self.params.texture_size, game.ref_res, true, "game")
		local gui_required_textures = table.deepclone(game_gui.required_textures)
		-- Classic boss avatars are thumbnails, not the large encyclopedia portraits.
		-- Load them at HUD scale; rebborn_enemy_icons is already a GUI dependency.
		for _,hero_name in ipairs(active_hero_names) do
			if infinite_heroes.get_boss(hero_name) then
				append_unique(gui_required_textures,"encyclopedia_thumbs")
				break
			end
		end
		if not nostalgic_classic and user_data.liuhui.cheat6 == true then
			table.insert(gui_required_textures, "kr6_hero_summon_icons")
		end
		game.gui_required_textures = replace_locale(gui_required_textures)
		self:load_texture_groups(game.gui_required_textures, self.params.texture_size, game_gui.ref_res, true, "game_gui")
		self:load_sound_groups(game.required_sounds)
		self:load_sound_groups(game.store.level.required_sounds)

		if game.store.level.show_comic_idx and game.store.level_mode == GAME_MODE_CAMPAIGN then
			local comic_idx = game.store.level.show_comic_idx
			local item = _require("screen_comics")

			item.item_name = "comics"
			item.required_textures = {
				"comic_" .. comic_idx
			}
			item.level_idx = game.store.level_idx
			local comic_idx_2 = comic_idx
			local comic_scale = 1
			if args.level_idx >= 101 then
				comic_scale = TEXTURE_SIZE_FACTOR.kr_45
			end
			item.comic_data = love.filesystem.read(self:get_comic_data_file(comic_idx_2))
			
			self:load_texture_groups(replace_locale(item.required_textures), self.params.texture_size, item.ref_res, true, "comic")

			self.queued_item = item
			item.game_item = game
		else
			self.queued_item = game
		end
	end

	log.debug("queued item: %s", self.queued_item.item_name)
end

function director:load_deferred_cheat_textures(game)
	local normal = game.deferred_cheat_textures or {}
	local scaled = game.deferred_cheat_scale_textures or {}
	if #normal == 0 and #scaled == 0 then return end

	-- shortcut: load F1 art together on first purchase; split by menu if this load stays too large.
	self:load_texture_groups(replace_locale(normal), self.params.texture_size, game.ref_res, true, "game")
	self:load_texture_groups(replace_locale(scaled), self.params.texture_size, game.ref_res * TEXTURE_SIZE_FACTOR.kr_45, true, "game")
	G.push("all")
	while not I:queue_load_done() do
		love.event.pump()
		G.setCanvas()
		G.origin()
		G.setScissor()
		G.clear()
		game:draw()
		local w, h = G.getWidth(), G.getHeight()
		G.origin()
		G.setScissor()
		G.setColor(0, 0, 0, 220)
		G.rectangle("fill", 0, h - 60, w, 60)
		G.setColor(255, 255, 255, 255)
		G.rectangle("fill", 20, h - 25, (w - 40) * I.progress, 8)
		G.present()
		love.timer.sleep(0.001)
	end
	G.pop()
	love.timer.step()
	table.append(game.required_textures, normal)
	table.append(game.scale_required_textures, scaled)
	game.deferred_cheat_textures = nil
	game.deferred_cheat_scale_textures = nil
end

function director:load_texture_groups(groups, texture_size, ref_height, queue, item_name)
	local scale = 1

	if ref_height then
		scale = self:get_texture_scale(item_name, ref_height)
	end

	for _, group in pairs(groups) do
		local texture_path = KR_PATH_GAME_TARGET .. "/assets/images/" .. texture_size

		if features.overrides then
			for _, n in pairs(features.overrides) do
				local ov_path = texture_path .. "/_ov/" .. n

				if love.filesystem.exists(ov_path .. "/" .. group .. ".lua") then
					log.debug("  +++ texture group %s overriden by %s", group, n)

					texture_path = ov_path
				end
			end
		end

		if queue then
			I:queue_load_atlas(scale, texture_path, group)
		else
			I:load_atlas(scale, texture_path, group)
		end
	end
end

function director:load_sound_groups(groups)
	S.global_source_mode = self.params.audio_mode

	if groups then
		for _, group in pairs(groups) do
			S:queue_load_group(group)
		end
	end
end

function director:queued_item_ready(dt)
	local images_done = I:queue_load_done()
	local sounds_done = S:queue_load_done()

	return images_done and sounds_done
end

function director:update(dt)
	S:update(dt)

	if self.next_item_name then
		self:queue_load_item_named(self.next_item_name, self.force_reload)

		self.queued_item_init = false
		self.queued_item_first_draw = false
		self.last_item_name = self.next_item_name
		self.next_item_name = nil
		self.force_reload = nil
	end

	if self.active_item then
		local ai = self.active_item

		if ai.limit_fps then
			ai.next_frame_ts = ai.limit_fps and ai.next_frame_ts + 1 / ai.limit_fps or nil
		end

		ai:update(dt)
	end

	local ai = self.active_item
	local aits = ai and ai.is_transition and ai.transition_state or nil

	if aits == "closing" or aits == "opening" then
		-- block empty
	else
		if self.queue_unload_item and (not aits or aits == "closed") then
			if not self:unload_item(self.queue_unload_item, true) then
				goto label_13_0
			end

			self.queue_unload_item = nil
		end
		
		if self.queued_item and self:queued_item_ready(dt) then
			local ai = self.active_item

			if ai and ai.hold_enabled then
				-- block empty
			else
				if not self.queued_item_init then
					local item = self.queued_item

					local function cb(outcome)
						self:item_done_callback(item.item_name, outcome)
					end

					self.queued_item:init(self.params.width, self.params.height, cb)

					self.queued_item.done_callback_called = nil
					self.queued_item_init = true
					self.queued_item_first_draw = false

					self.queued_item:update(2 * TICK_LENGTH)

					goto label_13_0
				end

				if ai then
					if ai.transition_state == "closing" then
						goto label_13_0
					elseif ai.transition_state == "closed" and self.queued_item_first_draw then
						ai:open()

						goto label_13_0
					elseif ai.transition_state == "opening" then
						goto label_13_0
					end
				end

				self:unload_item(self.active_item)

				self.active_item = self.queued_item
				self.queued_item = nil
				self.queued_item_init = nil

				signal.emit(SGN_DIRECTOR_ITEM_SHOWN, self.active_item.item_name, self.active_item)

				local item = self.active_item
				local fps

				if item.max_fps then
					fps = item.max_fps
				else
					fps = not self.params.vsync and 60 or nil
				end

				item.limit_fps = fps
				item.next_frame_ts = love.timer.getTime()
			end
		end
	end

	::label_13_0::

	if ISM then
		local state = self.active_item and self.active_item.get_ism_state and self.active_item:get_ism_state()

		ISM:update(dt, state)
	end

	services:update(dt)
end

function director:draw()
	if self.active_item then
		if self.scissor_w and self.scissor_enabled then
			G.setScissor(self.scissor_x, self.scissor_y, self.scissor_w, self.scissor_h)
		end

		local ai = self.active_item

		if ai.transition_state == "closing" and self.queue_unload_item then
			self.queue_unload_item:draw()
		elseif self.queued_item and self.queued_item_init then
			self.queued_item:draw()

			self.queued_item_first_draw = true
		end

		ai:draw()

		if self.scissor_w and self.scissor_enabled then
			G.setScissor()
		end
	end
end

function director:limit_fps()
	if self.active_item then
		local ai = self.active_item

		if ai.next_frame_ts then
			local current_ts = love.timer.getTime()

			if current_ts >= ai.next_frame_ts then
				ai.next_frame_ts = current_ts

				return
			end

			love.timer.sleep(ai.next_frame_ts - current_ts)
		end
	end
end

function director:keypressed(key, isrepeat)
	if key == "tab" and love.window.getFullscreen() and love.system.getOS() == "OS X" and (love.keyboard.isDown("lgui") or love.keyboard.isDown("rgui")) then
		love.window.minimize()

		return
	end

	if DEBUG and key == "r" and love.keyboard.isDown("lshift") and not isrepeat then
		RC:reload()

		if self.active_item and self.active_item.item_name == "game" then
			log.error("FORCING RELOAD OF GUI ONLY")
			game:reload_gui()
		else
			log.error("FORCING RELOAD OF %s", self.last_item_name)

			self.force_reload = true
			self.next_item_name = self.last_item_name
		end

		return
	end

	if self.active_item and self.active_item.keypressed and self.active_item:keypressed(key, isrepeat) then
		return
	end

	if ISM then
		local state = self.active_item and self.active_item.get_ism_state and self.active_item:get_ism_state()

		ISM:proc_key(state, key, isrepeat)
	end
end

function director:keyreleased(key, isrepeat)
	if self.active_item and self.active_item.keyreleased then
		self.active_item:keyreleased(key, isrepeat)
	end
end

function director:textinput(t)
	if self.active_item and self.active_item.textinput then
		self.active_item:textinput(t)
	end
end

function director:mousepressed(x, y, button, istouch)
	if self.cursor_down then
		love.mouse.setCursor(self.cursor_down)
	end

	if self.active_item and self.active_item.mousepressed then
		self.active_item:mousepressed(x, y, button, istouch)
	end
end

function director:mousereleased(x, y, button, istouch)
	if self.cursor_up then
		love.mouse.setCursor(self.cursor_up)
	end

	if self.active_item and self.active_item.mousereleased then
		self.active_item:mousereleased(x, y, button, istouch)
	end
end

function director:mousemoved(x, y, dx, dy, istouch)
	if self.active_item and self.active_item.mousemoved then
		self.active_item:mousemoved(x, y, dx, dy, istouch)
	end
end

function director:wheelmoved(dx, dy)
	if self.active_item and self.active_item.wheelmoved then
		self.active_item:wheelmoved(dx, dy)
	end
end

function director:touchpressed(id, x, y, dx, dy, pressure)
	if self.active_item and self.active_item.touchpressed then
		self.active_item:touchpressed(id, x, y, dx, dy, pressure)
	end
end

function director:touchreleased(id, x, y, dx, dy, pressure)
	if self.active_item and self.active_item.touchreleased then
		self.active_item:touchreleased(id, x, y, dx, dy, pressure)
	end
end

function director:touchmoved(id, x, y, dx, dy, pressure)
	if self.active_item and self.active_item.touchmoved then
		self.active_item:touchmoved(id, x, y, dx, dy, pressure)
	end
end

function director:gamepadaxis(joystick, axis, value)
	if self.active_item and self.active_item.gamepadaxis then
		self.active_item:gamepadaxis(joystick, axis, value)
	end
end

function director:gamepadpressed(joystick, button)
	if self.active_item then
		if self.active_item.gamepadpressed then
			self.active_item:gamepadpressed(joystick, button)
		end

		local state = self.active_item and self.active_item.get_ism_state and self.active_item:get_ism_state()

		if ISM then
			ISM:proc_button(state, joystick, button)
		end
	end
end

function director:gamepadreleased(joystick, button)
	if self.active_item and self.active_item.gamepadreleased then
		self.active_item:gamepadreleased(joystick, button)
	end
end

function director:joystickpressed(joystick, button)
	if self.active_item and self.active_item.joystickpressed then
		self.active_item:joystickpressed(joystick, button)
	end
end

function director:joystickreleased(joystick, button)
	if self.active_item and self.active_item.joystickreleased then
		self.active_item:joystickreleased(joystick, button)
	end
end

function director:joystickadded(joystick)
	if ISM then
		ISM:joystickadded(joystick)
	end

	if self.active_item and self.active_item.joystickadded then
		self.active_item:joystickadded(joystick)
	end

	signal.emit("joystick-added", joystick)
end

function director:joystickremoved(joystick)
	if ISM then
		ISM:joystickremoved(joystick)
	end

	if self.active_item and self.active_item.joystickremoved then
		self.active_item:joystickremoved(joystick)
	end

	signal.emit("joystick-removed", joystick)
end

function director:resize(w, h)
	log.debug(">>>>>>>>> screen size changed to %s,%s", w, h)
	self:reset_screen_params()
end

function director:focus(focus)
	log.paranoid("++++++++++ focus changed to :%s ++++++++++", focus)

	if self.active_item and self.active_item.focus then
		self.active_item:focus(focus)
	end
end

return director

