-- chunkname: @./all/level_utils.lua

local log = require("klua.log"):new("level_utils")

require("klua.table")

local km = require("klua.macros")
local signal = require("hump.signal")
local V = require("klua.vector")
local E = require("entity_db")
local GS = require("game_settings")
local I = require("klove.image_db")
local G = require("love.graphics")
local P = require("path_db")
local serpent = require("serpent")
local storage = require("storage")
local bit = require("bit")
local bor = bit.bor
local LU = {}
local infinite_heroes = require("infinite_heroes")

local function create_playable_hero(name)
	if infinite_heroes.get_boss(name) then infinite_heroes.bosses.register(name) end
	return E:create_entity(name)
end

function LU.queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

function LU.queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

function LU.eval_get_prop(e, expr)
	local f = loadstring("return e." .. expr)
	local env = {}

	env.e = e

	setfenv(f, env)

	return f()
end

function LU.eval_set_prop(e, prop_name, value)
	log.error("prop_name:%s prop_value:%s", prop_name, value)

	local repr

	if type(value) == "string" then
		repr = "'" .. value .. "'"
	else
		repr = tostring(value)
	end

	local f = loadstring("e." .. prop_name .. "=" .. repr)
	local env = {}

	env.e = e

	setfenv(f, env)
	f()
end

function LU.load_level(store, name)
	local level
	local fn = KR_PATH_GAME .. "/data/levels/" .. name .. ".lua"

	if not love.filesystem.isFile(fn) then
		log.debug("Level file does not exist for %s", fn)

		level = {}
	else
		local f, err = love.filesystem.load(fn)

		if err then
			log.error("Error loading level %s: %s", fn, err)

			return nil
		end

		level = f()
	end

	level.data = LU.load_data(store)
	level.locations = LU.load_locations(store) or {}

	if level.data then
		store.level_terrain_type = level.data.level_terrain_type

		for _, n in pairs({
			"required_textures",
			"required_sounds",
			"locked_hero",
			"locked_powers",
			"locked_towers",
			"max_upgrade_level",
			"custom_spawn_pos",
			"pan_extension",
			"show_comic_idx",
			"nav_mesh",
			"custom_start_pos",
			"ignore_walk_backwards_paths"
		}) do
			level[n] = level.data[n]
		end
	end

	return level
end

if DEBUG then
	function LU.save_data(store, name)
		local fn = KR_FULLPATH_BASE .. "/" .. KR_PATH_GAME .. "/data/levels/" .. name .. "_data.lua"

		local function custom_sort(k, o)
			local function sort_table(a, b)
				if a == "template" then
					return true
				elseif b == "template" then
					return false
				elseif type(a) == "number" and type(b) == "number" then
					if type(o[a]) == "table" and type(o[b]) == "table" and o[a].template and o[b].template then
						if o[a].template == o[b].template and o[a].pos and o[b].pos then
							if o[a].pos.y == o[b].pos.y then
								if o[a].pos.x == o[b].pos.x and o[a]["editor.game_mode"] and o[b]["editor.game_mode"] then
									return o[a]["editor.game_mode"] < o[b]["editor.game_mode"]
								else
									return o[a].pos.x < o[b].pos.x
								end
							else
								return o[a].pos.y < o[b].pos.y
							end
						else
							return o[a].template < o[b].template
						end
					else
						return a < b
					end
				else
					return tostring(a) < tostring(b)
				end
			end

			table.sort(k, sort_table)
		end

		local str = serpent.block(store.level.data, {
			indent = "    ",
			comment = false,
			sortkeys = custom_sort,
			keyignore = {
				_idx = true,
				frames = true,
				locations = true,
				_id = true
			}
		})
		local out = "return " .. str .. "\n"
		local f = io.open(fn, "w")

		f:write(out)
		f:flush()
		f:close()
	end
end

function LU.eval_file(filename)
	local f, err = love.filesystem.load(filename)

	if err then
		log.info("Error loading file %s: %s", fullname, err)

		return nil, err
	end

	local env = {}

	env.V = V
	env.v = V.v
	env.r = V.r
	env.km = km

	function env.fts(v)
		return v / FPS
	end

	env.math = math

	local cf = KR_PATH_ALL .. "/constants.lua"
	local c = love.filesystem.load(cf)

	setfenv(c, env)
	c()
	setfenv(f, env)

	local data = f()

	return data
end

function LU.load_data(store)
	local fn = KR_PATH_GAME .. "/data/levels/" .. store.level_name .. "_data.lua"
	local data = LU.eval_file(fn)

	if not data then
		return nil
	end

	local ov = data.level_mode_overrides[store.level_mode]

	if ov then
		for k, v in pairs(ov) do
			data[k] = ov[k]
		end
	end

	return data
end

function LU.load_locations(store)
	local fn = KR_PATH_GAME .. "/data/levels/" .. store.level_name .. "_loc.lua"
	local f, err = love.filesystem.load(fn)

	if err then
		log.info("Level has no locations file %s: %s", fn, err)

		return nil
	end

	local l = f()

	if not l._patched_y then
		for _, h in pairs(l.holders) do
			h.pos.y = h.pos.y + 4
			h.rally_pos.y = h.rally_pos.y + 4
		end

		l._patched_y = true
	end

	table.sort(l.exits, function(o1, o2)
		return o1.id < o2.id
	end)

	return l
end

function LU.insert_entities(store, items, store_back_references)
	if store_back_references then
		items._idx = {}
	end

	for i, item in ipairs(items) do
		local template = item.template

		if not template then
			log.error("template name missing in idx:%s : %s", i, getdump(item))
		else
			local e = E:create_entity(template)

			if not e then
				log.error("template named %s could not be found", template)
			else
				for k, v in pairs(item) do
					if k ~= "template" then
						local vv = v

						if not store_back_references and type(v) == "table" then
							vv = table.deepclone(v)
						end

						if string.find(k, "%.") then
							if string.sub(k, 1, 7) == "editor." and not e.editor then
								e.editor = {}
							end

							local kf = loadstring("e." .. k .. " = vv")
							local env = {}

							env.e = e
							env.k = k
							env.vv = vv

							setfenv(kf, env)
							kf()
						else
							e[k] = vv
						end
					end
				end

				if e.editor and e.editor.game_mode ~= 0 and e.editor.game_mode ~= store.level_mode then
					log.debug("skipping item %s. game mode mismatch", e.template_name)
				else
					if e.tower and e.tower.terrain_style then
						e.render.sprites[1].name = string.format(e.render.sprites[1].name, e.tower.terrain_style)
					end

					if e.sound_events and e.sound_events.mute_on_level_insert then
						e.sound_events.insert = nil
					end

					LU.queue_insert(store, e)

					if store_back_references then
						item._id = e.id
						items._idx[e.id] = item
					end
				end
			end
		end
	end
end

function LU.insert_invalid_path_ranges(store, ranges)
	if ranges then
		for _, item in pairs(ranges) do
			P:add_invalid_range(item.path_id, item.from, item.to, item.flags)
		end
	end
end

function LU.insert_defend_points(store, points, style)
	if not points then
		log.info("store.level.locations.exits does not exist")

		return
	end

	for _, p in pairs(points) do
		local e = E:create_entity("decal_defend_point")

		e.pos.x, e.pos.y = p.pos.x, p.pos.y

		if style == TERRAIN_STYLE_UNDERGROUND then
			e.render.sprites[1].name = "defendFlag_underground_0069"
		end

		e.editor = nil

		LU.queue_insert(store, e)
	end
end

function LU.insert_holders(store, holders, templates)
	if not holders then
		log.info("store.level.locations.holders does not exist")

		return
	end

	for _, hp in pairs(holders) do
		local id = hp.id
		local template = templates and templates[id] or "tower_holder"

		LU.insert_tower(store, template, hp.style, hp.pos, hp.rally_pos, nil, hp.id)
	end
end

function LU.insert_tower(store, template, style, pos, rally_pos, spent, holder_id)
	local e = E:create_entity(template)

	e.pos = V.v(pos.x, pos.y)
	e.tower.spent = spent and spent or 0
	e.tower.terrain_style = TERRAIN_STYLES[style]
	e.tower.default_rally_pos = V.v(rally_pos.x, rally_pos.y)
	e.tower.holder_id = holder_id
	e.render.sprites[1].name = string.format(e.render.sprites[1].name, e.tower.terrain_style)

	if e.barrack then
		e.barrack.rally_pos = V.vclone(e.tower.default_rally_pos)
	end

	LU.queue_insert(store, e)

	return e
end

function LU.insert_background(store, name, z, sort_y, quad_trim)
	local e = E:create_entity("decal")

	e.name = "background"
	e.pos.x, e.pos.y = REF_W / 2, REF_H / 2
	e.render.sprites[1].anchor = V.v(0.5, 0.5)
	e.render.sprites[1].animated = false
	e.render.sprites[1].name = name
	e.render.sprites[1].z = z
	e.render.sprites[1].sort_y = sort_y

	if quad_trim then
		local ss = I:s(e.render.sprites[1].name)
		local t = ss.trim

		t[1] = t[1] - quad_trim
		t[2] = t[2] - quad_trim
		t[3] = t[3] + 2 * quad_trim
		t[4] = t[4] + 2 * quad_trim

		local q = ss.f_quad

		q[1] = q[1] - quad_trim
		q[2] = q[2] - quad_trim
		q[3] = q[3] + 2 * quad_trim
		q[4] = q[4] + 2 * quad_trim
		ss.quad = G.newQuad(q[1], q[2], q[3], q[4], ss.a_size[1], ss.a_size[2])
	end

	LU.queue_insert(store, e)

	return e
end

local function campaign_variant_is(store, variant)
	return store and store.level_mode == GAME_MODE_CAMPAIGN and store.campaign_variant == variant
end

function LU.ensure_hero_rally(store)
	if store._campaign_heroes_initialized and store.main_heroes and #store.main_heroes >= 4 then
		return store.main_heroes
	end

	if store.level.locked_hero then
		return
	end

	local user_data = store.user_data or storage:load_slot()
	local hero_data = require("data.map_data").hero_data
	local defaults = {"hero_gerald", "hero_alric", "hero_elves_archer", "hero_orc"}
	local rally_list = user_data and user_data.liuhui_hero and user_data.liuhui_hero.rallylist
	local names = {}

	for i = 1, 4 do
		local idx = rally_list and rally_list[i]

		names[i] = idx and hero_data[idx] and hero_data[idx].name or defaults[i]
	end

	return LU.insert_hero_rally(store, names)
end

function LU.insert_hero(store, name, pos)
	if not name and infinite_heroes.active(store) and not store._inserting_infinite_heroes then
		local heroes = infinite_heroes.spawn(store, LU.insert_hero)
		return heroes and heroes[1]
	end
	if store.level.locked_hero then
		log.debug("hero locked for level. will not insert")

		return
	end

	if not name then
		if campaign_variant_is(store, CAMPAIGN_VARIANT_HERO_RALLY) and not store._inserting_hero_rally then
			local heroes = LU.ensure_hero_rally(store)

			return heroes and heroes[1]
		elseif campaign_variant_is(store, CAMPAIGN_VARIANT_SPELL_RAID) then
			store._campaign_heroes_initialized = true

			return
		end

		store._campaign_heroes_initialized = true
	end

	local template_name

	if not name then
		--这里是主英雄的插入口
		template_name = store.selected_hero and store.selected_hero or GS.default_hero

		if not template_name then
			store.level.locked_hero = true

			return
		end
	else
		template_name = name
	end

	local hero = create_playable_hero(template_name)

	if not hero then
		log.error("Could not create hero named %s", template_name)

		return
	end

	if not pos then
		if hero.hero.use_custom_spawn_point and store.level.custom_spawn_pos then
			if store.level.custom_spawn_pos.x then
				pos = store.level.custom_spawn_pos
			else
				pos = store.level.custom_spawn_pos[1].pos
			end
		else
			pos = store.level.locations.exits[1].pos
		end
	end

	hero.pos = V.vclone(pos)
	hero.nav_rally.center = V.vclone(hero.pos)
	hero.nav_rally.pos = hero.nav_rally.center

	if not name then
		store.main_hero = hero
		
		local status = store.selected_hero_status or infinite_heroes.get_boss(template_name) and {xp = 0, skills = {}}

		if status and status.skills and status.xp then
			--changed
			local hero_list ={				
				"hero_gerald",
				"hero_alleria",
				"hero_bolin",
				"hero_magnus",
				"hero_ignus",
				"hero_malik",
				"hero_denas",
				"hero_ingvar",
				"hero_elora",
				"hero_oni",
				"hero_hacksaw",
				"hero_thor",
				"hero_10yr",
				"hero_voltaire",
				"hero_viper",
				"hero_oberon",
				"hero_ember",
				"hero_penumbra",
				"hero_zezitra",
				"hero_deadeye"
			}
			
			if table.contains(hero_list, hero.template_name) then
				--hero.hero.xp = 0
				--hero.hero.level = 1
				hero.hero.xp = (screen_map.user_data.liuhui~=nil and screen_map.user_data.liuhui.g1_level10 == true) and 28000 or 0 
				hero.hero.level = (screen_map.user_data.liuhui~=nil and screen_map.user_data.liuhui.g1_level10 == true) and 10 or 1
			else
				hero.hero.xp = status.xp
				hero.hero.level = 10
			end
			-- print("main_hero: %s, h.level:%d", hero.template_name, hero.hero.level)
			for i, th in ipairs(GS.hero_xp_thresholds) do
				if th > hero.hero.xp then
					hero.hero.level = i
					break
				end
			end

			for k, v in pairs(status.skills) do
				if not hero.hero.skills[k] then
					log.error("hero %s status missing skill %s", hero.template_name, k)
				else
					hero.hero.skills[k].level = v
				end
			end
		else
			log.error("Active slot has no hero status or xp info for %s", template_name)
		end
	end
	
	LU.queue_insert(store, hero)
	signal.emit("hero-added", hero)
	-- print("main_hero: %s, h.level:%d", hero.template_name, hero.hero.level)
	
	if store.main_hero and store.main_hero.hero then
		local he = store.main_hero

		log.info("main_hero: %s, h.level:%d", he.template_name, he.hero.level)

		for sn, hs in pairs(he.hero.skills) do
			log.info("\t hero skill %s level: %d", sn, hs.level)
		end
	end

	return hero
end

--双英雄专用加载函数，name1必须提供参数
function LU.insert_double_hero(store, name1, name2, pos, pos2)
	if store.level.locked_hero then
		log.debug("hero locked for level. will not insert")
		return
	end

	if campaign_variant_is(store, CAMPAIGN_VARIANT_HERO_RALLY) and not store._inserting_hero_rally then
		local heroes = LU.ensure_hero_rally(store)

		return heroes and heroes[1], heroes and heroes[2]
	elseif campaign_variant_is(store, CAMPAIGN_VARIANT_SPELL_RAID) then
		store._campaign_heroes_initialized = true

		return
	end

	store._campaign_heroes_initialized = true

	map_data = require("data.map_data")
	local hero_data = map_data.hero_data

	if not name1 then
		log.debug("name1 error")
		print("name1 error")
		return
	end

	if not name2 then
		log.debug("name2 error")
		print("name2 error")
		return
	end
	local template_name = name1

	local hero = create_playable_hero(template_name)

	if not hero then
		log.error("Could not create hero named %s", template_name)
		return
	end

	if not pos then
		if hero.hero.use_custom_spawn_point and store.level.custom_spawn_pos then
			if store.level.custom_spawn_pos.x then
				pos = store.level.custom_spawn_pos
			else
				pos = store.level.custom_spawn_pos[1].pos
			end
		else
			pos = store.level.locations.exits[1].pos
		end
	end

	if not store.level.locations.exits[2] or store.level_idx == 39 or store.level_idx == 40 or store.level_idx == 9 or store.level_idx == 136 or store.level_idx == 141 then
	hero.pos = V.v(pos.x - 20, pos.y)
	else
	hero.pos = V.vclone(pos)
	end
	hero.nav_rally.center = V.vclone(hero.pos)
	hero.nav_rally.pos = hero.nav_rally.center
		
	if name1 then		
		local slot = storage:load_slot(nil, true)
		
		local status = slot.heroes.status[name1] or infinite_heroes.get_boss(name1) and {xp = 0, skills = {}}

		if status and status.skills and status.xp then
			--changed
			local hero_list ={
				"hero_gerald",
				"hero_alleria",
				"hero_bolin",
				"hero_magnus",
				"hero_ignus",
				"hero_malik",
				"hero_denas",
				"hero_ingvar",
				"hero_elora",
				"hero_oni",
				"hero_hacksaw",
				"hero_thor",
				"hero_10yr",
				"hero_voltaire",
				"hero_viper",
				"hero_oberon",
				"hero_ember",
				"hero_penumbra",
				"hero_zezitra",
				"hero_deadeye"
			}
			
			if table.contains(hero_list, hero.template_name) then
				hero.hero.xp = (screen_map.user_data.liuhui~=nil and screen_map.user_data.liuhui.g1_level10 == true) and 28000 or 4800 
				hero.hero.level = (screen_map.user_data.liuhui~=nil and screen_map.user_data.liuhui.g1_level10 == true) and 10 or 5
			else
				hero.hero.xp = status.xp
				hero.hero.level = 10
			end
			-- print("main_hero: %s, h.level:%d", hero.template_name, hero.hero.level)
			for i, th in ipairs(GS.hero_xp_thresholds) do
				if th > hero.hero.xp then
					hero.hero.level = i
					break
				end
			end

			for k, v in pairs(status.skills) do
				if not hero.hero.skills[k] then
					log.error("hero %s status missing skill %s", hero.template_name, k)
				else
					hero.hero.skills[k].level = v
				end
			end
		else
			log.error("Active slot has no hero status or xp info for %s", template_name)
		end
	end

	store.main1_hero = hero

	LU.queue_insert(store, hero)
	signal.emit("hero-added", hero)
	

	local template_name = name2

	local hero = create_playable_hero(template_name)

	if not hero then
		log.error("Could not create hero named %s", template_name)
		return
	end

	if not pos2 then
		if hero.hero.use_custom_spawn_point and store.level.custom_spawn_pos then
			if store.level.custom_spawn_pos.x then
				pos2 = store.level.custom_spawn_pos
			else
				local custom_spawn = store.level.custom_spawn_pos[2] or store.level.custom_spawn_pos[1]

				pos2 = custom_spawn.pos or custom_spawn
			end
		elseif not store.level.locations.exits[2] or store.level_idx == 39 or store.level_idx == 40 or store.level_idx == 9 or store.level_idx == 136 or store.level_idx == 141 then
			pos2 = pos
		else
			if store.level.locations.exits[2].pos then
				pos2 = store.level.locations.exits[2].pos
			else
				pos2 = store.level.locations.exits[1].pos
			end
		end
	end
--[[
	if not pos or store.level_idx == 140 then
		if hero.hero.use_custom_spawn_point and store.level.custom_spawn_pos then
			if store.level.custom_spawn_pos.x then
				pos = store.level.custom_spawn_pos
			else
				if store.level_idx == 140 then
					pos = store.level.custom_spawn_pos[2].pos
				else
					pos = store.level.custom_spawn_pos[1].pos
				end
			end
		else
			if store.level_idx == 140 then
				pos = store.level.locations.exits[2].pos
			else
				pos = store.level.locations.exits[1].pos
			end
		end
	end
]]--
	store.main_hero = hero

	if not store.level.locations.exits[2] or store.level_idx == 39 or store.level_idx == 40 or store.level_idx == 9 or store.level_idx == 136 or store.level_idx == 141 then
	hero.pos = V.v(pos2.x + 20, pos2.y)
	else
	hero.pos = V.vclone(pos2)
	end
	hero.nav_rally.center = V.vclone(hero.pos)
	hero.nav_rally.pos = hero.nav_rally.center

	if name2 then		
		
		local slot = storage:load_slot(nil, true)
		local status = slot.heroes.status[name2] or infinite_heroes.get_boss(name2) and {xp = 0, skills = {}}

		if status and status.skills and status.xp then
			--changed
			local hero_list ={
				"hero_gerald",
				"hero_alleria",
				"hero_bolin",
				"hero_magnus",
				"hero_ignus",
				"hero_malik",
				"hero_denas",
				"hero_ingvar",
				"hero_elora",
				"hero_oni",
				"hero_hacksaw",
				"hero_thor",
				"hero_10yr",
				"hero_voltaire",
				"hero_viper",
				"hero_oberon",
				"hero_ember",
				"hero_penumbra",
				"hero_zezitra",
				"hero_deadeye"
			}
			
			if table.contains(hero_list, hero.template_name) then
				hero.hero.xp = (screen_map.user_data.liuhui~=nil and screen_map.user_data.liuhui.g1_level10 == true) and 28000 or 4800 
				hero.hero.level = (screen_map.user_data.liuhui~=nil and screen_map.user_data.liuhui.g1_level10 == true) and 10 or 5
			else
				hero.hero.xp = status.xp
				hero.hero.level = 10
			end
			-- print("main_hero: %s, h.level:%d", hero.template_name, hero.hero.level)
			for i, th in ipairs(GS.hero_xp_thresholds) do
				if th > hero.hero.xp then
					hero.hero.level = i
					break
				end
			end

			for k, v in pairs(status.skills) do
				if not hero.hero.skills[k] then
					log.error("hero %s status missing skill %s", hero.template_name, k)
				else
					hero.hero.skills[k].level = v
				end
			end
		else
			log.error("Active slot has no hero status or xp info for %s", template_name)
		end
	end
	
	LU.queue_insert(store, hero)
	signal.emit("hero-added", hero)
	print("add hero done")


	return hero
end

--双英雄专用加载函数，name1必须提供参数，返回2个英雄
function LU.insert_double_hero_return2(store, name1, name2, pos, pos2)
	if store.level.locked_hero then
		log.debug("hero locked for level. will not insert")
		return
	end

	if campaign_variant_is(store, CAMPAIGN_VARIANT_HERO_RALLY) and not store._inserting_hero_rally then
		local heroes = LU.ensure_hero_rally(store)

		return heroes and heroes[1], heroes and heroes[2]
	elseif campaign_variant_is(store, CAMPAIGN_VARIANT_SPELL_RAID) then
		store._campaign_heroes_initialized = true

		return
	end

	store._campaign_heroes_initialized = true

	map_data = require("data.map_data")
	local hero_data = map_data.hero_data

	if not name1 then
		log.debug("name1 error")
		print("name1 error")
		return
	end

	if not name2 then
		log.debug("name2 error")
		print("name2 error")
		return
	end
	local template_name = name1

	local hero = create_playable_hero(template_name)

	if not hero then
		log.error("Could not create hero named %s", template_name)
		return
	end

	if not pos then
		if hero.hero.use_custom_spawn_point and store.level.custom_spawn_pos then
			if store.level.custom_spawn_pos.x then
				pos = store.level.custom_spawn_pos
			else
				pos = store.level.custom_spawn_pos[1].pos
			end
		else
			pos = store.level.locations.exits[1].pos
		end
	end

	if not store.level.locations.exits[2] or store.level_idx == 39 or store.level_idx == 40 or store.level_idx == 9 or store.level_idx == 136 or store.level_idx == 141 then
	hero.pos = V.v(pos.x - 20, pos.y)
	else
	hero.pos = V.vclone(pos)
	end
	hero.nav_rally.center = V.vclone(hero.pos)
	hero.nav_rally.pos = hero.nav_rally.center
		
	if name1 then		
		local slot = storage:load_slot(nil, true)
		
		local status = slot.heroes.status[name1] or infinite_heroes.get_boss(name1) and {xp = 0, skills = {}}

		if status and status.skills and status.xp then
			--changed
			local hero_list ={
				"hero_gerald",
				"hero_alleria",
				"hero_bolin",
				"hero_magnus",
				"hero_ignus",
				"hero_malik",
				"hero_denas",
				"hero_ingvar",
				"hero_elora",
				"hero_oni",
				"hero_hacksaw",
				"hero_thor",
				"hero_10yr",
				"hero_voltaire",
				"hero_viper",
				"hero_oberon",
				"hero_ember",
				"hero_penumbra",
				"hero_zezitra",
				"hero_deadeye"
			}
			
			if table.contains(hero_list, hero.template_name) then
				hero.hero.xp = (screen_map.user_data.liuhui~=nil and screen_map.user_data.liuhui.g1_level10 == true) and 28000 or 4800 
				hero.hero.level = (screen_map.user_data.liuhui~=nil and screen_map.user_data.liuhui.g1_level10 == true) and 10 or 5
			else
				hero.hero.xp = status.xp
				hero.hero.level = 10
			end
			-- print("main_hero: %s, h.level:%d", hero.template_name, hero.hero.level)
			for i, th in ipairs(GS.hero_xp_thresholds) do
				if th > hero.hero.xp then
					hero.hero.level = i
					break
				end
			end

			for k, v in pairs(status.skills) do
				if not hero.hero.skills[k] then
					log.error("hero %s status missing skill %s", hero.template_name, k)
				else
					hero.hero.skills[k].level = v
				end
			end
		else
			log.error("Active slot has no hero status or xp info for %s", template_name)
		end
	end

	store.main1_hero = hero

	LU.queue_insert(store, hero)
	signal.emit("hero-added", hero)	

	local template_name = name2

	local hero2 = create_playable_hero(template_name)

	if not hero2 then
		log.error("Could not create hero named %s", template_name)
		return
	end
	if not pos2 then
		if hero2.hero.use_custom_spawn_point and store.level.custom_spawn_pos then
			if store.level.custom_spawn_pos.x then
				pos2 = store.level.custom_spawn_pos
			else
				local custom_spawn = store.level.custom_spawn_pos[2] or store.level.custom_spawn_pos[1]

				pos2 = custom_spawn.pos or custom_spawn
			end
		elseif not store.level.locations.exits[2] or store.level_idx == 39 or store.level_idx == 40 or store.level_idx == 9 or store.level_idx == 136 or store.level_idx == 141 then
			pos2 = pos
		else
			if store.level.locations.exits[2].pos then
				pos2 = store.level.locations.exits[2].pos
			else
				pos2 = store.level.locations.exits[1].pos
			end
		end
	end
--[[
	if not pos then
		if hero2.hero.use_custom_spawn_point and store.level.custom_spawn_pos then
			if store.level.custom_spawn_pos.x then
				pos = store.level.custom_spawn_pos
			else
				pos = store.level.custom_spawn_pos[1].pos
			end
		else
			pos = store.level.locations.exits[1].pos
		end
	end
]]--
	store.main_hero = hero2

	if not store.level.locations.exits[2] or store.level_idx == 39 or store.level_idx == 40 or store.level_idx == 9 or store.level_idx == 136 or store.level_idx == 141 then
	hero2.pos = V.v(pos2.x + 20, pos2.y)
	else
	hero2.pos = V.vclone(pos2)
	end
	hero2.nav_rally.center = V.vclone(hero2.pos)
	hero2.nav_rally.pos = hero2.nav_rally.center

	if name2 then		
		
		local slot = storage:load_slot(nil, true)
		local status = slot.heroes.status[name2] or infinite_heroes.get_boss(name2) and {xp = 0, skills = {}}

		if status and status.skills and status.xp then
			--changed
			local hero_list ={
				"hero_gerald",
				"hero_alleria",
				"hero_bolin",
				"hero_magnus",
				"hero_ignus",
				"hero_malik",
				"hero_denas",
				"hero_ingvar",
				"hero_elora",
				"hero_oni",
				"hero_hacksaw",
				"hero_thor",
				"hero_10yr",
				"hero_voltaire",
				"hero_viper",
				"hero_oberon",
				"hero_ember",
				"hero_penumbra",
				"hero_zezitra",
				"hero_deadeye"
			}
			
			if table.contains(hero_list, hero2.template_name) then
				hero2.hero.xp = (screen_map.user_data.liuhui~=nil and screen_map.user_data.liuhui.g1_level10 == true) and 28000 or 4800 
				hero2.hero.level = (screen_map.user_data.liuhui~=nil and screen_map.user_data.liuhui.g1_level10 == true) and 10 or 5
			else
				hero2.hero.xp = status.xp
				hero2.hero.level = 10
			end
			-- print("main_hero: %s, h.level:%d", hero.template_name, hero.hero.level)
			for i, th in ipairs(GS.hero_xp_thresholds) do
				if th > hero2.hero.xp then
					hero2.hero.level = i
					break
				end
			end

			for k, v in pairs(status.skills) do
				if not hero2.hero.skills[k] then
					log.error("hero %s status missing skill %s", hero2.template_name, k)
				else
					hero2.hero.skills[k].level = v
				end
			end
		else
			log.error("Active slot has no hero status or xp info for %s", template_name)
		end
	end
	
	LU.queue_insert(store, hero2)
	signal.emit("hero-added", hero2)
	print("add hero done")


	return hero, hero2
end

function LU.insert_hero_rally(store, hero_names)
	if not hero_names or #hero_names < 4 then
		log.error("Hero rally requires four hero names")
		return
	end

	if store.main_heroes and #store.main_heroes >= 4 then
		store._campaign_heroes_initialized = true

		return store.main_heroes
	end

	store._campaign_heroes_initialized = true
	store._inserting_hero_rally = true

	local exits = store.level.locations and store.level.locations.exits or {}
	local first = exits[1] and exits[1].pos or V.v(512, 384)
	local second = exits[2] and exits[2].pos or first
	local first_top = V.v(first.x, first.y - 24)
	local second_top = V.v(second.x, second.y - 24)
	local first_bottom = V.v(first.x, first.y + 24)
	local second_bottom = V.v(second.x, second.y + 24)
	local hero1, hero2 = LU.insert_double_hero_return2(store, hero_names[1], hero_names[2], first_top, second_top)
	local hero3, hero4 = LU.insert_double_hero_return2(store, hero_names[3], hero_names[4], first_bottom, second_bottom)

	store._inserting_hero_rally = nil

	store.main_heroes = {hero1, hero2, hero3, hero4}
	store.main1_hero = hero1
	store.main_hero = hero2

	return store.main_heroes
end

function LU.list_entities(t, template_name, tag)
	return table.filter(t, function(_, e)
		return (not template_name or e.template_name == template_name) and (not tag or e.editor and e.editor.tag == tag)
	end)
end

function LU.has_alive_enemies(store, excluded_templates)
	local store_enemies = table.filter(store.entities, function(_, e)
		return e.main_script and (e.main_script.co or e.main_script.runs > 0) and (e.enemy and e.health and (not e.health.dead or e.enemy.wait_for_death_animation and not e.health.death_finished_ts) or e.enemy and e.death_spawns or e.spawner and not e.spawner.eternal or e.picked_enemies and #e.picked_enemies > 0 or e.tunnel and #e.tunnel.picked_enemies > 0 or e.template_name == "nav_faerie") and not (e.enemy and e.enemy.ignore_victory) and (not excluded_templates or not table.contains(excluded_templates, e.template_name)) and e.template_name ~= "bullywag_spawner"
	end)
	local pending_enemies = table.filter(store.pending_inserts, function(_, e)
		return e.enemy and not e.enemy.ignore_victory or e.template_name == "nav_faerie"
	end)
	local wait_for_graveyard = false

	if #store_enemies == 0 and #pending_enemies == 0 then
		local graveyards = E:filter(store.entities, "graveyard")

		if #graveyards > 0 then
			if store._graveyards_check_ts then
				local wait_time = 0

				for _, g in pairs(graveyards) do
					if g.interrupt then
						wait_for_graveyard = false

						goto label_23_0
					else
						wait_time = math.max(wait_time, g.graveyard.dead_time + g.graveyard.check_interval)
					end

					wait_time = wait_time + 2 * store.tick_length
				end

				if wait_time < store.tick_ts - store._graveyards_check_ts then
					log.debug("graveyard wait done")

					wait_for_graveyard = false
				else
					wait_for_graveyard = true
				end
			else
				log.debug("starting new graveyard timeout check")

				store._graveyards_check_ts = store.tick_ts
				wait_for_graveyard = true
			end
		end
	elseif store._graveyards_check_ts then
		log.debug("enemies appear. resetting graveyard timeout check")

		store._graveyards_check_ts = nil
	end

	::label_23_0::

	return #store_enemies > 0 or #pending_enemies > 0 or wait_for_graveyard, #store_enemies, #pending_enemies
end


function LU.has_alive_enemies_2(store, excluded_templates)
	local store_enemies = table.filter(store.entities, function(_, e)
		return e.main_script and (e.main_script.co or e.main_script.runs > 0) and (e.enemy and e.health and (not e.health.dead or e.enemy.wait_for_death_animation and not e.health.death_finished_ts) or e.enemy and e.death_spawns or e.spawner and not e.spawner.eternal or e.picked_enemies and #e.picked_enemies > 0 or e.tunnel and #e.tunnel.picked_enemies > 0 or e.template_name == "nav_faerie") and not (e.enemy and e.enemy.ignore_victory) and (not excluded_templates or not table.contains(excluded_templates, e.template_name))
	end)
	local pending_enemies = table.filter(store.pending_inserts, function(_, e)
		return e.enemy and not e.enemy.ignore_victory or e.template_name == "nav_faerie"
	end)
	local wait_for_graveyard = false

	if #store_enemies == 0 and #pending_enemies == 0 then
		local graveyards = E:filter(store.entities, "graveyard")

		if #graveyards > 0 then
			if store._graveyards_check_ts then
				local wait_time = 0

				for _, g in pairs(graveyards) do
					if g.interrupt then
						wait_for_graveyard = false

						goto label_23_0
					else
						wait_time = math.max(wait_time, g.graveyard.dead_time + g.graveyard.check_interval)
					end

					wait_time = wait_time + 2 * store.tick_length
				end

				if wait_time < store.tick_ts - store._graveyards_check_ts then
					log.debug("graveyard wait done")

					wait_for_graveyard = false
				else
					wait_for_graveyard = true
				end
			else
				log.debug("starting new graveyard timeout check")

				store._graveyards_check_ts = store.tick_ts
				wait_for_graveyard = true
			end
		end
	elseif store._graveyards_check_ts then
		log.debug("enemies appear. resetting graveyard timeout check")

		store._graveyards_check_ts = nil
	end

	::label_23_0::

	return #store_enemies > 0 or #pending_enemies > 0 or wait_for_graveyard, #store_enemies, #pending_enemies, store_enemies, pending_enemies
end

local kill_all_controllers = {
	graveyard_controller = true,
	swamp_controller = true
}
local kill_all_interrupts = {
	twister = true,
	mod_timelapse = true,
	aura_bullet_balrog = true
}
local kill_all_removals = {
	nav_faerie = true,
	mod_drider_poison = true,
	decal_drider_cocoon = true,
	mod_dark_spitters = true,
	mod_balrog = true
}

local function kill_all_enemies_in_list(store, list, discard_gold, keep_spawners)
	for _, e in pairs(list) do
		local name = e.template_name

		if e.enemy and e.vis and (bit.band(e.vis.flags, F_BOSS) == 0 or bit.band(e.vis.flags, F_MINIBOSS) ~= 0) then
			if e.health.immune_to ~= DAMAGE_ALL then
				e.health.hp = 0

				if e.death_spawns then
					e.health.last_damage_types = DAMAGE_NO_SPAWNS
				end
			end

			if discard_gold then
				e.enemy.gold = 0
			end

			e.vis.bans = bor(e.vis.bans, F_MOD)

			if e.regen then
				e.regen.cooldown = 1e+99
			end
		end

		if name == "soldier_rag" then
			e.health.hp = 0
		end

		if not keep_spawners then
			if e.spawner then
				e.spawner.interrupt = true
			end

			if kill_all_controllers[name] then
				e.interrupt = true
			end
		end

		if kill_all_interrupts[name] then
			e.interrupt = true
		end
	end

	for _, e in pairs(list) do
		if kill_all_removals[e.template_name] then
			LU.queue_remove(store, e)
		end
	end
end

function LU.kill_all_enemies(store, discard_gold, keep_spawners)
	kill_all_enemies_in_list(store, store.entities, discard_gold, keep_spawners)
	kill_all_enemies_in_list(store, store.pending_inserts, discard_gold, keep_spawners)
end

return LU
