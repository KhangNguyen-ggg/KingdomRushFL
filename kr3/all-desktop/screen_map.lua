-- chunkname: @./all-desktop/screen_map.lua

local log = require("klua.log"):new("screen_map")
local class = require("middleclass")
local DI = require("difficulty")
local E = require("entity_db")
local E6
local F = require("klove.font_db")
local G = love.graphics
local GS = require("game_settings")
local GU = require("gui_utils_5")
local I = require("klove.image_db")
local S = require("sound_db")
local SH = require("klove.shader_db")
local SU = require("screen_utils")
local U = require("utils")
local UPGR = require("upgrades")
local V = require("klua.vector")
local v = V.v
local km = require("klua.macros")
local i18n = require("i18n")
local storage = require("storage")
local infinite_heroes = require("infinite_heroes")
local enemy_enhance = require("enemy_enhance")
local power_selection = require("power_selection")
local power_upgrades_6 = require("power_upgrades_6")
local hero_upgrades_6 = require("hero_upgrades_6")
local generation_upgrades = require("generation_upgrades")
local shortcut_settings = require("shortcut_settings")
local tower_loadout = require("tower_loadout")
local signal = require("hump.signal")
local timer = require("hump.timer")
local utf8 = require("utf8")
local balance = require("balance/balance")
local balance_6
local tower_balance_highlight = require("tower_balance_highlight")
--local screen_map_classes = require("screen_map_classes")
local achievements_data
local map_data = require("data.map_data")
local tower_menus = require("data.tower_menus_data")
local special_tower_power_icons = require("data.special_tower_power_icons")
local special_tower_encyclopedia = require("data.special_tower_encyclopedia")
local kr6_tower_integration = require("data.kr6_tower_integration")
local tower_power_display = require("data.tower_power_display")

local krflapk_love_major = love.getVersion and select(1, love.getVersion()) or love._version_major
local krflapk_needs_batch_color_compat = (love.system and love.system.getOS and love.system.getOS() == "Android") or (krflapk_love_major and krflapk_love_major >= 11)

local function krflapk_color_channel(v, default)
	if v == nil then
		return default
	end

	if krflapk_needs_batch_color_compat and v > 1 then
		return v / 255
	end

	return v
end

local function krflapk_batch_set_color(batch, r, g, b, a)
	batch:setColor(krflapk_color_channel(r, 1), krflapk_color_channel(g, 1), krflapk_color_channel(b, 1), krflapk_color_channel(a, 1))
end


local function T(name)
	return E:get_template(name)
end

require("klove.kui")

local kui_db = require("klove.kui_db")

require("gg_views_custom")

local WaveEditorView = require("wave_editor_view")
local encyclopedia_enemy_resources = require("data.encyclopedia_enemy_resources")

local IS_KR1 = KR_GAME == "kr1"
local IS_KR3 = KR_GAME == "kr3"
local CREEP_1235_NUM = 317
local CREEP_PRE_KR6_NUM = 458
-- Final encyclopedia icon ranges in the five-in-one build:
-- KR3 001-099, KR1 101-199 and KR2 201-299 are stored directly in templates.
-- KR4 stores 001-199 and adds 300; KR5 stores 001-199 and adds 500.
-- Keep the same rule with +700 for a future KR6 import (final 701-899).
local ENCYCLOPEDIA_ENEMY_GENERATION_OFFSETS = {
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 300,
	[5] = 500,
	[6] = 700
}

local function layout_encyclopedia_page_button(button, page, total_pages, view_width, single_row_y, double_row_y)
	local row = math.floor((page - 1) / 12)
	local column = (page - 1) % 12
	local row_count = math.min(12, total_pages - row * 12)

	button.anchor = v(button.size.x / 2, button.size.y / 2)
	button.pos = v(view_width / 2 + (column - (row_count - 1) / 2) * 30,
		total_pages > 12 and double_row_y + row * 37 or single_row_y)
	button.scale = v(0.68, 0.68)
	button.label.font_size = 18
	button.page_idx = page
end

local function encyclopedia_enemy_db(creep_data)
	if creep_data and creep_data.generation == 6 then
		E6 = E6 or require("entity_db_6_proxy")

		return E6
	end

	return E
end

local function encyclopedia_enemy_template(creep_data)
	if not creep_data then
		return nil
	end

	local db = encyclopedia_enemy_db(creep_data)
	local t = db:get_template(creep_data.name .. "_10086")

	if t == nil then
		t = db:get_template(creep_data.name)
	end

	return t
end

local function encyclopedia_enemy_entity(creep_data)
	local t = encyclopedia_enemy_template(creep_data)

	if not t then
		return nil, nil
	end

	local ce = table.deepclone(t)

	ce.id = -1

	return ce, t
end

local function encyclopedia_tower_db(tower_entry)
	if tower_entry and tower_entry.generation == 6 then
		E6 = E6 or require("entity_db_6_proxy")

		return E6
	end

	return E
end

local function encyclopedia_tower_template(tower_entry, tower_name)
	local db = encyclopedia_tower_db(tower_entry)

	return db:get_template(tower_name)
end

local function encyclopedia_tower_entity(tower_entry, tower_name)
	local t = encyclopedia_tower_template(tower_entry, tower_name)

	if not t then
		return nil
	end

	local entity = table.deepclone(t)

	entity.id = -1

	return entity
end

local function encyclopedia_enemy_icon_idx(t, enemy_name, encyclopedia_index, generation)
	local icon_override = enemy_name
		and encyclopedia_enemy_resources.encyclopedia_icon_overrides
		and encyclopedia_enemy_resources.encyclopedia_icon_overrides[enemy_name]

	if icon_override then
		return icon_override
	end

	if generation == 6 and encyclopedia_index then
		return 700 + encyclopedia_index - CREEP_PRE_KR6_NUM
	end

	local icon = t and t.info and t.info.enc_icon

	if not icon then
		return encyclopedia_index or 1
	end

	local offset = t.info.enc_icon_offset

	if offset == nil and generation then
		offset = ENCYCLOPEDIA_ENEMY_GENERATION_OFFSETS[generation]
	end

	local resource_generation

	if offset == nil and enemy_name then
		local resource = encyclopedia_enemy_resources.enemies[enemy_name]

		resource_generation = resource and resource.generation

		if resource_generation and resource_generation >= 4 then
			offset = ENCYCLOPEDIA_ENEMY_GENERATION_OFFSETS[resource_generation]
		end
	end

	-- The encyclopedia order is the authoritative KR4 fallback for older
	-- entries without resource metadata. Explicit generation/template offsets
	-- must win so imported KR6 entries stay in the 701+ range.
	if offset == nil and encyclopedia_index and encyclopedia_index > CREEP_1235_NUM then
		offset = ENCYCLOPEDIA_ENEMY_GENERATION_OFFSETS[4]
	end

	if offset == nil and resource_generation then
		offset = ENCYCLOPEDIA_ENEMY_GENERATION_OFFSETS[resource_generation]
	end

	if offset == nil then
		offset = 0
	end

	return icon + offset
end
local global_icon_idx = {   1,   2,   3,   4,--圣巢/皇弓/奥术/三管
						    6,   7,   8,   9,  --树灵/澡堂/观星/火箭
						   10,  11,  12,  13,  --巨弩/死灵/喷火/沙镖
						   16,  17,  18,  32,--幽魂/酒桶/诡术/暮弓/
						   34,  39,  42,  49,--蛤蟆/炮兵/巨像/熊猫
						   51, --龙巢
						  417, 414, 421, 408, 411,--骚扰/红钻/火山/黑弓/黑骑
						  407, 409, 404, 423, 410,--火法/熔炉/回旋/沉船/死墓
						  415, 419, 420, 416, 406, -- 腐森/少林/沼巨/女巫/飞艇
						  413, 403, 402, 405, 412,--骨塔/兽人/萨满/火骑/僵尸
						  418, 422,--鱼人/沙虫
					}

screen_map = {}

local function configure_android_map_popup(view)
	if not IS_ANDROID or not view then
		return view
	end

	local ui_scale = screen_map.android_ui_scale or 1
	local inverse_ui_scale = 1 / ui_scale

	-- Full-page popups already occupy most of the authored 1920x1080 canvas.
	-- Keep their original coordinate system and size on Android: scaling their
	-- full-screen `back` root also scales the large empty margins around the
	-- book, which pushes the dynamically-created encyclopedia/tower controls
	-- away from the pages and makes the layout appear scrambled.
	view.scale = V.v(inverse_ui_scale, inverse_ui_scale)

	return view
end

local function screen_map_current_generation(map)
	if map.kr1_map then
		return 1
	elseif map.kr2_map then
		return 2
	elseif map.kr4_map then
		return 4
	elseif map.kr5_map then
		return 5
	elseif map.kr6_map then
		return 6
	end

	return 3
end

local function screen_map_seen_table()
	if screen_map.user_data and not screen_map.user_data.seen then
		screen_map.user_data.seen = {}
	end

	return screen_map.user_data and screen_map.user_data.seen
end

local function screen_map_mark_seen(seen_key)
	local seen = screen_map_seen_table()

	if seen and seen_key then
		seen[seen_key] = true
		storage:save_slot(screen_map.user_data)
	end
end

local function screen_map_text_balloon(image_name, text, label_size, label_pos, font_size, color)
	local tip = KImageView:new(image_name)
	local label = GGLabel:new(label_size)

	tip.propagate_on_click = true
	tip.propagate_on_down = true
	tip.propagate_on_up = true
	label.pos = label_pos or v(12, 12)
	label.font_name = "body"
	label.font_size = font_size or 22
	label.text = text
	label.text_align = "center"
	label.vertical_align = "middle"
	label.line_height = 0.9
	label.propagate_on_click = true
	label.propagate_on_down = true
	label.propagate_on_up = true
	label.colors.text = color or {
		46,
		41,
		39,
		255
	}
	label.fit_lines = 2
	tip:add_child(label)

	return tip, label
end

local function screen_map_first_level_unfinished(gen)
	local level_idx = map_data.level_rank(1, gen)
	local level = level_idx and screen_map.user_data and screen_map.user_data.levels and screen_map.user_data.levels[level_idx]

	return level and not level[GAME_MODE_CAMPAIGN]
end

function screen_map:remove_map_entry_hint(field_name)
	local tip = self[field_name]

	if tip and tip.parent then
		tip.parent:remove_child(tip)
	end

	self[field_name] = nil
end

function screen_map:dismiss_map_entry_hint(field_name, seen_key, mark_seen)
	self:remove_map_entry_hint(field_name)

	if mark_seen then
		screen_map_mark_seen(seen_key)
	end
end

function screen_map:clear_map_entry_hints()
	self:remove_map_entry_hint("mapTowerRoomTip")
	self:remove_map_entry_hint("mapHeroRoomTip")
	self:remove_map_entry_hint("mapHideUITip")
	self:remove_map_entry_hint("mapDisplaySettingsTip")
end

function screen_map:show_map_entry_hints()
	local seen = screen_map_seen_table()

	if not seen or not self.window then
		return
	end

	local hint_color = {
		0,
		102,
		158,
		255
	}

	if IS_ANDROID and self.o_button and (DBG_SHOW_BALLOONS or not seen.map_display_settings_tip) then
		local tip = screen_map_text_balloon("mapBaloon_heroLvlUp_notxt", "Chỉnh font, giao diện và màn hình rộng\ntrong cài đặt di động; có mục cần khởi động lại.", V.v(260, 52), v(15, 19), 18, hint_color)

		tip.anchor = v(0, 0)
		tip.pos = v(self.o_button.pos.x + 42, self.o_button.pos.y + 18)

		function tip.on_click()
			screen_map:dismiss_map_entry_hint("mapDisplaySettingsTip", "map_display_settings_tip", true)
		end

		self.mapDisplaySettingsTip = tip
		self.window:add_child(tip)
	end

	if self.tower5_room and (DBG_SHOW_BALLOONS or not seen.map_tower_room_tip) then
		local tip = screen_map_text_balloon("mapBaloon_heroLvlUp_notxt", "Chọn tháp tại đây", V.v(228, 44), v(15, 24), 26, hint_color)

		tip.anchor = v(tip.size.x / 2, tip.size.y)
		tip.pos = v(self.tower5_room.pos.x + 80, self.sh - 160)

		function tip.on_click()
			screen_map:dismiss_map_entry_hint("mapTowerRoomTip", "map_tower_room_tip", true)
		end

		self.mapTowerRoomTip = tip
		self.window:add_child(tip)
	end

	if self.hero_but and not self.heroTip and (DBG_SHOW_BALLOONS or not seen.map_hero_room_tip) then
		local tip = screen_map_text_balloon("mapBaloon_heroLvlUp_notxt", "Chọn anh hùng tại đây", V.v(228, 44), v(15, 24), 26, hint_color)

		tip.anchor = v(tip.size.x / 2, tip.size.y)
		tip.pos = v(self.hero_but.pos.x, self.sh - 160)

		function tip.on_click()
			screen_map:dismiss_map_entry_hint("mapHeroRoomTip", "map_hero_room_tip", true)
		end

		self.mapHeroRoomTip = tip
		self.window:add_child(tip)
	end

	local generation = screen_map_current_generation(self)
	local hide_ui_seen_key = "map_hide_ui_tip_" .. generation

	if DBG_SHOW_BALLOONS or not seen[hide_ui_seen_key] then
		local tip = screen_map_text_balloon("mapBaloon_heroLvlUp_notxt", "Nhấn Tab để ẩn giao diện\n(và ẩn hướng dẫn này)", V.v(228, 44), v(15, 24), 26, hint_color)

		tip.anchor = v(tip.size.x / 2, tip.size.y)
		tip.pos = v(self.sw / 2, self.sh - 160)

		function tip.on_click()
			screen_map:dismiss_map_entry_hint("mapHideUITip", hide_ui_seen_key, true)
		end

		self.mapHideUITip = tip
		self.window:add_child(tip)
	end
end
screen_map.required_sounds = {
	"common",
	"common5",
	"common4",
	"kr6_map_tower_taunts",
	"kr6_common",
	"kr6_music_screen_map",
	"music_screen_map",
	"hero_oberon",
	"hero_ember",
	"hero_penumbra",
	"hero_zezitra",
	"hero_deadeye",
	"kr6_hero_gerald",
	"kr6_hero_zefira",
	"kr6_hero_bolin",
	"kr6_hero_malik",
	"kr6_hero_ashbite",
	"kr6_hero_rhodes",
	"kr6_hero_drakkan",
	"kr6_hero_myriath",
	"kr6_hero_connor",
	"kr6_hero_ignus",
	"kr6_hero_oni",
	"kr6_hero_illiana"
}
screen_map.required_textures = {
	"ui_volibear_lol20",
	"ui_lich_king",
	"ui_sett_spirit",
	"screen_map",
	"generation_upgrades",
	"legacy_generation_upgrades",
	"spell_select_button",
	"tower_select_button",
	"spell_selection_icons",
	"kr6_ui_icons",
	"kr6_level_select_badges",
	"kr6_power_upgrade_icons",
	"kr6_screen_map_bg",
	"kr6_screen_map",
	"kr6_screen_map_decos",
	"kr6_level_thumbs",
	"kr6_hero_room_icons",
	"kr6_hero_room_big",
	"kr6_map_hero_portraits",
	-- "kr6_hero_silent_icons",
	-- "kr6_hero_silent_portraits",
	"dolia_spell_assets",
	"yao_spell_icon",
	"shaosiyuan_spell_icon",
	"cheat_item_spell_icons",
	"screen_map_animations",
	"screen_map_animations-1",
	"screen_map_animations-2",
	"kr4_map_decos",
	"kr4_map_decos_2",
	"kr4_map_decos_pc",
	"kr4_map_towerroom",
	"room_hero",
	"view_options",
	"achievements",
	"encyclopedia",
	"encyclopedia_thumbs",
	"encyclopedia_towers",
	"kr6_encyclopedia_towers",
	"kr6_encyclopedia_tower_skills",
	"encyclopedia_special_towers",
	"encyclopedia_special_tower_power_icons",
	"encyclopedia_dove43_towers",
	"encyclopedia_dove43_extra",
	"encyclopedia_creeps",
	"kr6_encyclopedia_creeps",
	"kr4_level_thumbs",
	--[=[ 193-201 暂不开放，暂时不加载其关卡缩略图。
	"zeta_level_thumbs",
	]=]
	"kr5_level_thumbs",
	"rebborn_level_thumbs",
	"stage91_level_thumb",
	"rebborn_heroes_room",
	"rebborn_heroes_gui",
	"rebborn_enemy_icons",
	--"ultimate45",
	--"kr4_herogui",
	--"kr4_hero_power",
	"rebbborn_fig",
	"kr4_hero_room",
	"kr4_map_hero_portraits",
	"kr5_hero_power",
}

-- if IS_KR1 then
-- 	table.insert(screen_map.required_textures, "screen_map_hero_room")
-- end

screen_map.ref_w = 1920
screen_map.ref_h = 1080
screen_map.ref_res = TEXTURE_SIZE_ALIAS.fullhd

local function ISW(...)
	return i18n.sw(i18n, ...)
end

local function CJK(default, zh, ja, kr)
	return i18n.cjk(i18n, default, zh, ja, kr)
end


-- Vietnamese captions on the dark map-button backgrounds.
local function vietnamese_map_caption(label)
	if i18n.current_locale ~= "zh-Hans" then return end
	label.font_name = "button"
	label.font_size = 18
	label.text_align = "center"
	label.vertical_align = "middle"
	label.colors.text = {255, 245, 210, 255}
	label.shaders = {"p_outline", "p_glow"}
	label.shader_args = {
		{thickness = 1.2, outline_color = {0.04, 0.06, 0.02, 1}},
		{thickness = 1.4, glow_color = {0, 0, 0, 0.85}}
	}
	label.fit_lines = 1
	label.canvases_drawn = nil
	label:do_fit_lines(1)
end

local function enemy_enhance_label(value)
	local level = enemy_enhance.level(value)

	if level == 1 then
		return CJK("Low", "Thấp", "小", "소")
	elseif level == 2 then
		return CJK("Medium", "Vừa", "中", "중")
	elseif level == 3 then
		return CJK("High", "Cao", "大", "대")
	end

	return CJK("Off", "Tắt", "オフ", "끔")
end

local function kr4_map_hero_portrait_name(hd)
	if not hd or type(hd.icon) ~= "number" or hd.icon < 401 or hd.icon > 417 then
		return nil
	end

	local hero_name = hd.name == "hero_tramin_seventh" and "hero_tramin" or hd.name

	return "mapButtons_portrait_hero_kr4_" .. hero_name
end

local function kr6_map_hero_portrait_name(hd)
	if not hd or hd.generation ~= 6 then
		return nil
	end

	return "mapButtons_portrait_hero_kr6_" .. hd.name
end

local function refresh_mobile_font_tree(view)
	if not view then
		return
	end

	if view._load_font and view.font_size then
		view.font = nil
		view._loaded_font_size = nil
		view._fitted_font = nil
		view.canvases_drawn = nil
	end

	if view.children then
		for _, child in ipairs(view.children) do
			refresh_mobile_font_tree(child)
		end
	end
end

local function get_hero_index(hero_name)
	for i, h in ipairs(screen_map.hero_data) do
		if hero_name == h.name then
			return i
		end
	end

	log.error("Hero named %s not found in hero_data", hero_name)

	return nil
end

local function fill_missing_hero_statuses(user_data)
	if not user_data or not user_data.heroes then
		return false
	end

	user_data.heroes.status = user_data.heroes.status or {}

	local template = require("data.slot_template")
	local defaults = template.heroes and template.heroes.status or {}
	local changed = false

	for hero_name, status in pairs(defaults) do
		if not user_data.heroes.status[hero_name] then
			user_data.heroes.status[hero_name] = table.deepclone(status)
			changed = true
		end
	end

	if hero_upgrades_6.normalize(user_data) then
		changed = true
	end

	return changed
end

local function default_double_hero_list()
	return {
		[1] = get_hero_index("hero_vesper") or 53,
		[2] = get_hero_index("hero_raelyn") or 54
	}
end

local function default_rally_hero_list()
	return {
		[1] = get_hero_index("hero_gerald") or 1,
		[2] = get_hero_index("hero_alric") or 14,
		[3] = get_hero_index("hero_elves_archer") or 25,
		[4] = get_hero_index("hero_orc") or 48
	}
end

local function get_hero_stats(p)
	local out = {}
	local index, hero_name

	if type(p) == "number" then
		index = p
	else
		index = get_hero_index(p)
	end

	local data = screen_map.hero_data[index]

	hero_name = data.name

	local user_data = screen_map.user_data or storage:load_slot()

	local status = user_data.heroes.status[hero_name]

	if not status then
		log.debug("hero status for %s not found in slot. overwritting from template", hero_name)

		local template = require("data.slot_template")

		local default_status = template.heroes.status[hero_name] or {
			xp = 0,
			skills = {}
		}

		status = table.deepclone(default_status)
		user_data.heroes.status[hero_name] = status
		storage:save_slot(user_data)
		--status.xp = 0
	end

	local h = E:create_entity(hero_name)

	h.hero.xp = status.xp or 0

	local level, level_progress = U.get_hero_level(h.hero.xp, GS.hero_xp_thresholds)

	h.hero.level = level
	if h.hero.level < data.starting_level then
		h.hero.level = data.starting_level
		h.hero.xp = GS.hero_xp_thresholds[h.hero.level]
	end

	out.skill_names = {}
	out.skill_names_i18n = {}

	local used_points = 0

	for k, v in pairs(status.skills) do
		h.hero.skills[k].level = v

		local i = h.hero.skills[k].hr_order

		out.skill_names[i] = k
		out.skill_names_i18n[i] = h.hero.skills[k].key

		for j = 1, v do
			used_points = used_points + h.hero.skills[k].hr_cost[j]
		end
	end

	h.hero.fn_level_up(h, {}, true)

	local info = h.info.fn(h)

	out.index = index
	out.name = hero_name
	out.name_i18n = h.info.i18n_key or hero_name
	out.icon = data.icon
	out.thumb = data.thumb
	out.portrait = data.portrait
	out.level = h.hero.level
	out.xp = h.hero.xp
	out.level_progress = level_progress
	out.taunt = h.sound_events.change_rally_point .. "Select"
	out.hero_class = _(string.upper(out.name_i18n) .. "_CLASS")
	out.health = info.hp_max
	if info.no_ranged then
		out.damage = info.damage_min .. " - " .. info.damage_max	
	elseif info.ranged_damage_min and info.map_melee then
		out.damage = info.damage_min .. " - " .. info.damage_max
	elseif info.ranged_damage_min then
		out.damage = info.ranged_damage_min .. " - " .. info.ranged_damage_max
	else
		out.damage = info.damage_min .. " - " .. info.damage_max	
	end
--[[
	if info.ranged_damage_min then
		out.damage = info.ranged_damage_min .. " - " .. info.ranged_damage_max
	else
		out.damage = info.damage_min .. " - " .. info.damage_max
	end
]]--	
	out.armor = info.armor and string.format(_("%i%%"), info.armor * 100) .. "" .. GU.armor_value_desc(info.armor)
	out.magic_armor = info.magic_armor and string.format(_("%i%%"), info.magic_armor * 100) .. "" .. GU.armor_value_desc(info.magic_armor)
	if info.armor == 0 and info.magic_armor and info.magic_armor >= 0.01 then
		out.armor = out.magic_armor.._("MAGIC_ARMOR_DESC")
	end
	out.attack_rate = _(string.upper(out.name_i18n) .. "_ATTACKRATE")
--	out.damage_icon = h.info.damage_icon or 1
	if info.no_ranged then
		out.damage_icon = h.info.damage_icon or 1	
	elseif info.ranged_damage_min and info.map_melee then
		out.damage_icon = h.info.damage_icon or 1
	elseif info.ranged_damage_min then
		out.damage_icon = h.info.ranged_damage_icon or 1
	else
		out.damage_icon = h.info.damage_icon or 1
	end	
	out.skills = h.hero.skills
	out.remaining_points = GS.skill_points_for_hero_level[h.hero.level] - used_points

	if data.generation == 6 then
		out.remaining_points = hero_upgrades_6.remaining_points(user_data, hero_name, h.hero.level, GS.skill_points_for_hero_level)
	end

	if out.attack_rate == string.upper(out.name_i18n) .. "_ATTACKRATE" then
		out.attack_rate = ISW("AVERAGE", "zh-Hans", "Trung bình", "zh-Hant", "平均")
	end

	return out, h
end

function screen_map:init(w, h, done_callback, map_change)
	self.done_callback = done_callback
	self.map_shortcuts = shortcut_settings.load_context("map")

	local sw, sh, scale, origin = SU.clamp_window_aspect(w, h, self.ref_w, self.ref_h)
	local authored_sw = sw
	local authored_sh = sh
	local base_scale = scale
	local unscaled_sw, unscaled_sh = sw, sh
	local android_ui_scale = IS_ANDROID and (ANDROID_UI_SCALE or 1) or 1
	local android_widescreen = IS_ANDROID and ANDROID_WIDESCREEN_ENABLED ~= false and w / h > MAX_SCREEN_ASPECT

	if IS_ANDROID then
		if android_widescreen then
			unscaled_sw = w / base_scale
			unscaled_sh = h / base_scale
		end

		scale = base_scale * android_ui_scale

		if android_widescreen then
			-- Expose the extra-wide viewport only when both the device and setting
			-- request it. MapView counter-scales the map content below.
			sw = w / scale
			sh = h / scale
			origin = V.v(0, 0)
		else
			-- UI may grow, but the map viewport keeps the original generic aspect.
			sw = sw / android_ui_scale
			sh = sh / android_ui_scale
		end
	end

	self.sw, self.sh = sw, sh
	self.android_ui_scale = android_ui_scale
	self.android_widescreen = android_widescreen
	self.android_device_is_widescreen = IS_ANDROID and w / h > MAX_SCREEN_ASPECT
	self.android_unscaled_sw = unscaled_sw
	self.android_unscaled_sh = unscaled_sh

	local ui_hidden = self.button_hidden
	local window = map_change and self.window or KWindow:new(V.v(sw, sh))

	window.scale = v(scale, scale)
	window.origin = origin
	self.window = window
	GGLabel.static.font_scale = scale
	GGLabel.static.ref_h = self.ref_h

	if DEBUG then
		package.loaded["data.achievements_data"] = nil
		package.loaded["data.map_data"] = nil
		package.loaded.map_decos_functions = nil
	end

	achievements_data = require("data.achievements_data")
	map_data = require("data.map_data")
	screen_map.hero_data = map_data.hero_data
	screen_map.tower_data = map_data.tower_data
	screen_map.tower_5_data = map_data.tower_5_data
	screen_map.level_data = map_data.level_data

	if not map_change then
		E:load()
	end

	--坐标切换.注意kr5的大小是2432*1368，放到前3代缩小到了1920*1080
	local points_data
	-- GS.level_ranges = GS.level_ranges3
	-- GS.last_level = GS.last_level3
	local generation = 3

	if not self.kr1_map and not self.kr2_map and not self.kr3_map and not self.kr4_map and not self.kr5_map and not self.kr6_map then
		self.kr1_map = false
		self.kr2_map = false
		self.kr3_map = true
		self.kr4_map = false
		self.kr5_map = false
		self.kr6_map = false
	end

	if self.kr1_map == true then
		points_data = require("data.map_points1")
		generation = 1

	elseif self.kr2_map == true then
		points_data = require("data.map_points2")
		generation = 2
	elseif self.kr5_map == true then
		points_data = require("data.map_points5")
		generation = 5
	elseif self.kr4_map == true then
		points_data = require("data.map_points4")
		generation = 4
	elseif self.kr6_map == true then
		points_data = require("data.map_points6")
		generation = 6
	else
		points_data = require("data.map_points")--3代
		local generation = 3
	end

	local ppl = {}

	local ppl_points = {}
	if self.kr5_map == true then
		if points_data.points and points_data.points[1] and points_data.points[1].children then
			for i = 1, #points_data.points - 6 do
				for j = 1, #points_data.points[i].children do

					new_pos = v(
						points_data.points[i].pos.x * points_data.RATE_X + points_data.OFFSET_X + points_data.points[i].children[j].pos.x * points_data.RATE_X + points_data.OFFSET_X1,
					    points_data.points[i].pos.y * points_data.RATE_Y + points_data.OFFSET_Y + points_data.points[i].children[j].pos.y * points_data.RATE_Y + points_data.OFFSET_Y1)
					local p = {
						id = #points_data.points[i].children[j].id,
						level = #points_data.points[i].id,
						pos = new_pos,
					}
					table.insert(ppl_points,p)
				end
			end
		

			points_data.points = ppl_points
		end
	end
	if points_data.points then
		table.sort(points_data.points, function(e1, e2)
			local e1l, e2l = tonumber(e1.level), tonumber(e2.level)
			local e1p, e2p = tonumber(e1.id), tonumber(e2.id)

			if e1l == e2l then
				return e1p < e2p
			else
				return e1l < e2l
			end
		end)

		for _, p in ipairs(points_data.points) do
			local l = tonumber(p.level)

			if not ppl[l] then
				ppl[l] = {}
			end

			table.insert(ppl[l], {
				pos = p.pos,
				water = p.water
			})
		end
	end

	self.map_points = {}
	self.map_points.points = ppl
	self.map_points.flags = points_data.flags
	self.map_points.endless_flags = points_data.endless_flags
	self.user_data = storage:load_slot()
	local hidden_hero_selection_changed = false
	if self.user_data.heroes.selected == "hero_silent" then
		self.user_data.heroes.selected = GS.default_hero
		hidden_hero_selection_changed = true
	end
	local hero_list = self.user_data.liuhui_hero and self.user_data.liuhui_hero.herolist
	if hero_list then
		local defaults = default_double_hero_list()
		for i = 1, 2 do
			if hero_list[i] and not screen_map.hero_data[hero_list[i]] then
				hero_list[i] = defaults[i]
				hidden_hero_selection_changed = true
			end
		end
	end
	if hidden_hero_selection_changed then
		storage:save_slot(self.user_data)
	end
	if fill_missing_hero_statuses(self.user_data) then
		storage:save_slot(self.user_data)
	end

	self.unlock_data = {}
	self.unlock_data.unlocked_levels = {}

	local levels = self.user_data.levels
	-- for i = 1,70 do
	-- 	levels[i] = table.deepclone(levels[1])
	-- end
	local victory = self.user_data.last_victory

	if victory then
		local level = levels[victory.level_idx]

		if not level then
			log.error("victory level %s was not shown in map before. ignoring victory", victory.level_idx)
		else
			if victory.level_mode == GAME_MODE_CAMPAIGN then
				if not level[GAME_MODE_CAMPAIGN] then
					level.stars = victory.stars
					self.unlock_data.show_stars_level = victory.level_idx
					self.unlock_data.star_count_before = 0

					if victory.level_idx < GS["last_level" .. generation] and not levels[victory.level_idx + 1] then
						levels[victory.level_idx + 1] = {}
						self.unlock_data.new_level = victory.level_idx + 1

						table.insert(self.unlock_data.unlocked_levels, self.unlock_data.new_level)
					end
				elseif victory.stars > level.stars then
					self.unlock_data.show_stars_level = victory.level_idx
					self.unlock_data.star_count_before = level.stars
					level.stars = victory.stars
				end
			elseif victory.level_mode == GAME_MODE_HEROIC or (victory.level_mode == GAME_MODE_BLITZ and victory.level_idx >= 251 and victory.level_idx <= 269) then
				self.unlock_data.heroic_level = not level[victory.level_mode] and victory.level_idx or nil
			elseif victory.level_mode == GAME_MODE_IRON then
				self.unlock_data.iron_level = not level[GAME_MODE_IRON] and victory.level_idx or nil
			end

			level[victory.level_mode] = math.max(victory.level_difficulty, level[victory.level_mode] or 0)
		end

		self.user_data.last_victory = nil

		storage:save_slot(self.user_data)
	elseif #self.user_data.levels == 0 then
		self.unlock_data.unlocked_levels = {
			1
		}
		levels[1] = {}

		storage:save_slot(self.user_data)
	elseif self.user_data.levels[GS["level_ranges"..generation][1][1]] == nil then
		self.unlock_data.unlocked_levels = {
			GS["level_ranges"..generation][1][1]
		}
		levels[GS["level_ranges"..generation][1][1]] = {}
		storage:save_slot(self.user_data)
	end

	if U.unlock_next_levels_in_ranges(self.unlock_data, levels, GS, generation) then
		storage:save_slot(self.user_data)
	end

	self.total_stars = U.count_stars(self.user_data)

	local map_viewport_left, map_viewport_top = 0, 0
	local map_viewport_w, map_viewport_h = sw, sh

	-- Only the opt-in widescreen mode may expose the physical extra-wide
	-- viewport.  With it disabled, keep the original aspect-clamped viewport
	-- returned by SU.clamp_window_aspect (including its native 4:3 tablet path).
	if android_widescreen then
		map_viewport_left = -origin.x / scale
		map_viewport_top = -origin.y / scale
		map_viewport_w = w / scale
		map_viewport_h = h / scale
	end

	if map_change then
		self.window:remove_child(self.map_view)
		self.map_view:destroy()
		self.window._drag_view = nil
		self.window._click_start_view = nil
		self.window._last_enter_view = nil
		self.window._last_mouse_pos = nil
		self.window.focused = nil
		self.window.responder = nil
		self.endlessTip = nil
	end

	local map = MapView:new(authored_sw, authored_sh, map_viewport_left, map_viewport_top, map_viewport_w, map_viewport_h, android_ui_scale)

	map.can_drag = false
	self.window:add_child(map, map_change and 1 or nil)

	self.map_view = map
	self._android_map_touches = {}
	self._android_map_pinch = nil
	self._android_map_pan = nil
	self._android_modal_touches = {}
	self._android_modal_pinch = nil
	self._android_modal_pan = nil
	self._android_modal_transform = nil

	-- Campaign changes only rebuild the map; rooms and their assets stay in place.
	if map_change then
		self._set_map_switcher_open(false)
		self:clear_map_entry_hints()
		if not self.button_hidden then
			self:show_map_entry_hints()
		end
		self:queue_map_music()
		return
	end

	local vign = KImageView:new("map_vignette_small")

	local vign_w = IS_ANDROID and map_viewport_w or sw
	local vign_h = IS_ANDROID and map_viewport_h or sh
	local vign_left = IS_ANDROID and map_viewport_left or 0
	local vign_top = IS_ANDROID and map_viewport_top or 0

	vign.scale = V.v(1.02 * vign_w / vign.size.x, 1.02 * vign_h / vign.size.y)
	vign.pos.x = vign_left - vign_w * 0.01
	vign.pos.y = vign_top - vign_h * 0.01
	vign.propagate_on_click = true
	vign.propagate_on_down = true
	vign.propagate_on_up = true

	self.window:add_child(vign)

	self.button_hidden = false
	local o_button = KImageButton:new("map_configBtn_0001", "map_configBtn_0002", "map_configBtn_0003")

	o_button.anchor = v(o_button.size.x / 2, o_button.size.y / 2)
	o_button.pos = v(80, 70)

	function o_button.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")
		self:dismiss_map_entry_hint("mapDisplaySettingsTip", "map_display_settings_tip", true)
		self.option_panel:show()
	end
	self.o_button = o_button

	self.window:add_child(o_button)

	local a_button = GGButton:new("mapButtons-notxt_0004", "mapButtons-notxt_0005")

	a_button.anchor = v(a_button.size.x / 2, a_button.size.y / 2)
	a_button.pos = v(sw - 100, sh - 90)

	function a_button.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")
		self.achievements:show()
	end

	a_button.label.pos = v(50, 121)
	a_button.label.size = v(126, 30)
	a_button.label.text_size = a_button.label.size
	a_button.label.font_size = 18
	a_button.label.vertical_align = CJK("middle", "top", nil, "top")
	a_button.label.text = _("Achievements")
	a_button.label.fit_lines = 1

	self.a_button = a_button

	self.window:add_child(a_button)

	self.TTT = a_button

	local e_button = GGButton:new("mapButtons-notxt_0007", "mapButtons-notxt_0008")

	e_button.anchor = v(e_button.size.x / 2, e_button.size.y / 2)
	e_button.pos = v(a_button.pos.x - 170, sh - 90)

	function e_button.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")
		self.encyclopedia:show()
	end

	e_button.label.pos = v(50, 121)
	e_button.label.size = v(126, 30)
	e_button.label.text_size = e_button.label.size
	e_button.label.font_size = 18
	e_button.label.vertical_align = CJK("middle", "top", nil, "top")
	e_button.label.text = _("Encyclopedia")
	e_button.label.fit_lines = 1

	self.e_button = e_button
	self.window:add_child(e_button)

	--地图切换按钮
	local map_switcher_open = false
	local set_map_switcher_open
	local spell_select_button
	local change_button1 = GGButton:new("mapButtons-notxt_0013", "mapButtons-notxt_0014")

	change_button1.anchor = v(change_button1.size.x / 2, change_button1.size.y / 2)
	change_button1.pos = v(a_button.pos.x - 1360, sh - 90)

	function change_button1.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")

		if self.kr1_map then
			set_map_switcher_open(not map_switcher_open)
		else
			self.kr3_map = false
			self.kr2_map = false
			self.kr4_map = false
			self.kr5_map = false
			self.kr6_map = false
			self.kr1_map = true
			timer.clear()
			screen_map:init(w, h, done_callback, not self:android_map_modal_open())
		end
	end

	change_button1.label.pos = v(50, 121)
	change_button1.label.size = v(126, 30)
	change_button1.label.text_size = change_button1.label.size
	change_button1.label.font_size = 18
	change_button1.label.vertical_align = CJK("middle", "top", nil, "top")
	change_button1.label.text = _("Rush")
	change_button1.label.fit_lines = 1

	self.window:add_child(change_button1)

	local change_button2 = GGButton:new("mapButtons-notxt_0015", "mapButtons-notxt_0016")

	change_button2.anchor = v(change_button2.size.x / 2, change_button2.size.y / 2)
	change_button2.pos = v(a_button.pos.x - 1190, sh - 90)

	function change_button2.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")

		if self.kr2_map then
			set_map_switcher_open(not map_switcher_open)
		else
			self.kr3_map = false
			self.kr2_map = true
			self.kr5_map = false
			self.kr6_map = false
			self.kr4_map = false
			self.kr1_map = false
			timer.clear()
			screen_map:init(w, h, done_callback, not self:android_map_modal_open())
		end
	end

	change_button2.label.pos = v(50, 121)
	change_button2.label.size = v(126, 30)
	change_button2.label.text_size = change_button2.label.size
	change_button2.label.font_size = 18
	change_button2.label.vertical_align = CJK("middle", "top", nil, "top")
	change_button2.label.text = _("Frontier")
	change_button2.label.fit_lines = 1

	self.window:add_child(change_button2)
	

	local change_button4 = GGButton:new("mapButtons-notxt_0400", "mapButtons-notxt_0401")

	change_button4.anchor = v(change_button4.size.x / 2, change_button4.size.y / 2)
	change_button4.pos = v(a_button.pos.x - 850, sh - 90)
	--change_button5.scale = v(2,2)

	function change_button4.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")

		if self.kr4_map then
			set_map_switcher_open(not map_switcher_open)
		else
			self.kr3_map = false
			self.kr2_map = false
			self.kr5_map = false
			self.kr6_map = false
			self.kr4_map = true
			self.kr1_map = false
			timer.clear()
			screen_map:init(w, h, done_callback, not self:android_map_modal_open())
		end
	end
	
	change_button4.label.pos = v(50, 121)
	change_button4.label.size = v(126, 30)
	change_button4.label.text_size = change_button4.label.size
	change_button4.label.font_size = 18
	change_button4.label.vertical_align = CJK("middle", "top", nil, "top")
	change_button4.label.text = _("Vegnance")
	change_button4.label.fit_lines = 1
	self.window:add_child(change_button4)


	local change_button5 = GGButton:new("mapButtons-notxt_0500", "mapButtons-notxt_0501")

	change_button5.anchor = v(change_button5.size.x / 2, change_button5.size.y / 2)
	change_button5.pos = v(a_button.pos.x - 680, sh - 90)
	--change_button5.scale = v(2,2)

	function change_button5.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")

		if self.kr5_map then
			set_map_switcher_open(not map_switcher_open)
		else
			self.kr3_map = false
			self.kr2_map = false
			self.kr4_map = false
			self.kr5_map = true
			self.kr6_map = false
			self.kr1_map = false
			timer.clear()
			screen_map:init(w, h, done_callback, not self:android_map_modal_open())
		end
	end
	
	change_button5.label.pos = v(50, 121)
	change_button5.label.size = v(126, 30)
	change_button5.label.text_size = change_button5.label.size
	change_button5.label.font_size = 18
	change_button5.label.vertical_align = CJK("middle", "top", nil, "top")
	change_button5.label.text = _("Alliance")
	change_button5.label.fit_lines = 1
	self.window:add_child(change_button5)

	local change_button6 = GGButton:new("mapButtons-notxt_0600", "mapButtons-notxt_0601")

	change_button6.anchor = v(change_button6.size.x / 2, change_button6.size.y / 2)
	change_button6.pos = v(a_button.pos.x - 510, sh - 90)

	function change_button6.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")

		if self.kr6_map then
			set_map_switcher_open(not map_switcher_open)
		else
			self.kr1_map = false
			self.kr2_map = false
			self.kr3_map = false
			self.kr4_map = false
			self.kr5_map = false
			self.kr6_map = true
			timer.clear()
			screen_map:init(w, h, done_callback, not self:android_map_modal_open())
		end
	end

	change_button6.label.pos = v(50, 121)
	change_button6.label.size = v(126, 30)
	change_button6.label.text_size = change_button6.label.size
	change_button6.label.font_size = 18
	change_button6.label.vertical_align = CJK("middle", "top", nil, "top")
	change_button6.label.text = "Genesis"
	change_button6.label.fit_lines = 1
	self.window:add_child(change_button6)

	local change_button3 = GGButton:new("mapButtons-notxt_0017", "mapButtons-notxt_0018")

	change_button3.anchor = v(change_button3.size.x / 2, change_button3.size.y / 2)
	change_button3.pos = v(a_button.pos.x - 1020, sh - 90)

	function change_button3.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")

		if self.kr3_map then
			set_map_switcher_open(not map_switcher_open)
		else
			self.kr3_map = true
			self.kr2_map = false
			self.kr5_map = false
			self.kr6_map = false
			self.kr4_map = false
			self.kr1_map = false
			timer.clear()
			screen_map:init(w, h, done_callback, not self:android_map_modal_open())
		end
	end

	change_button3.label.pos = v(50, 121)
	change_button3.label.size = v(126, 30)
	change_button3.label.text_size = change_button3.label.size
	change_button3.label.font_size = 18
	change_button3.label.vertical_align = CJK("middle", "top", nil, "top")
	change_button3.label.text = _("Origin")
	change_button3.label.fit_lines = 1
	self.window:add_child(change_button3)

	self.change_button1 = change_button1
	self.change_button2 = change_button2
	self.change_button3 = change_button3
	self.change_button4 = change_button4
	self.change_button5 = change_button5
	self.change_button6 = change_button6

	local map_change_buttons = {
		change_button1,
		change_button2,
		change_button3,
		change_button4,
		change_button5,
		change_button6
	}
	local map_change_labels = {
		_("Rush"),
		_("Frontier"),
		_("Origin"),
		_("Vegnance"),
		_("Alliance"),
		"Genesis"
	}
	local map_switch_aux_visibility

	local function current_map_generation()
		if self.kr1_map then
			return 1
		elseif self.kr2_map then
			return 2
		elseif self.kr4_map then
			return 4
		elseif self.kr5_map then
			return 5
		elseif self.kr6_map then
			return 6
		end

		return 3
	end

	set_map_switcher_open = function(open)
		map_switcher_open = open and true or false
		self.map_switcher_open = map_switcher_open

		if spell_select_button then
			spell_select_button.hidden = map_switcher_open
		end

		for _, item in pairs({
			self.a_button,
			self.e_button,
			self.u_button,
			self.hero_but
		}) do
			item.hidden = map_switcher_open
		end

		local aux_fields = {
			"upgrade_star",
			"skill_star",
			"upgradeTip",
			"heroTip"
		}

		if map_switcher_open then
			map_switch_aux_visibility = {}

			for _, field in ipairs(aux_fields) do
				local item = self[field]

				if item then
					map_switch_aux_visibility[field] = item.hidden
					item.hidden = true
				end
			end
		elseif map_switch_aux_visibility then
			for _, field in ipairs(aux_fields) do
				local item = self[field]

				if item and map_switch_aux_visibility[field] ~= nil then
					item.hidden = map_switch_aux_visibility[field]
				end
			end

			map_switch_aux_visibility = nil
		end

		local current_generation = current_map_generation()

		for generation, map_button in ipairs(map_change_buttons) do
			if map_switcher_open then
				map_button.hidden = false
				map_button.pos = v(a_button.pos.x - (6 - generation) * 170, sh - 90)
				map_button.label.text = map_change_labels[generation]
			else
				map_button.hidden = generation ~= current_generation
				map_button.pos = v(a_button.pos.x - 850, sh - 90)
				map_button.label.text = generation == current_generation and "Đổi bản đồ" or map_change_labels[generation]
			end
		end
	end

	spell_select_button = GGButton:new("spell_select_button_0001", "spell_select_button_0002", "spell_select_button_0002")
	spell_select_button.anchor = v(spell_select_button.size.x / 2, spell_select_button.size.y / 2)
	spell_select_button.pos = v(a_button.pos.x - 680, sh - 80)
	spell_select_button.label.pos = v(50, 111)
	spell_select_button.label.size = v(126, 30)
	spell_select_button.label.text_size = spell_select_button.label.size
	spell_select_button.label.font_size = 18
	spell_select_button.label.vertical_align = CJK("middle", "top", nil, "top")
	spell_select_button.label.text = "Chọn phép"
	spell_select_button.label.fit_lines = 1

	function spell_select_button.on_click()
		S:queue("GUIButtonCommon")
		self.spell_select:show()
	end

	self.spell_select_button = spell_select_button
	self.window:add_child(spell_select_button)

	self._set_map_switcher_open = set_map_switcher_open
	set_map_switcher_open(false)
	

	local tower5_room = GGButton:new("tower_select_button_0001", "tower_select_button_0002", "tower_select_button_0002")
	tower5_room.anchor = v(tower5_room.size.x / 2, tower5_room.size.y / 2)
	tower5_room.pos = v(125, sh - 90)
	tower5_room.label.pos = v(50, 121)
	tower5_room.label.size = v(126, 30)
	tower5_room.label.text_size = tower5_room.label.size
	tower5_room.label.font_size = 18
	tower5_room.label.vertical_align = CJK("middle", "top", nil, "top")
	tower5_room.label.text = "Chọn tháp"
	tower5_room.label.fit_lines = 1

	function tower5_room.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")
		self:dismiss_map_entry_hint("mapTowerRoomTip", "map_tower_room_tip", true)
		self:remove_map_entry_hint("mapHeroRoomTip")
		self.tower_room:show()
	end
	self.tower5_room = tower5_room
	self.window:add_child(tower5_room)

	--[[
	local double_hero_room = GGButton:new("screen_map_button_map_heroes_0001", "screen_map_button_map_heroes_0001")
	double_hero_room.anchor = v(double_hero_room.size.x / 2, double_hero_room.size.y / 2)
	double_hero_room.pos = v(100, sh - 250)
	double_hero_room.scale = v(1,1)
	function double_hero_room.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")
		self.hero5_room:show()
	end
	self.double_hero_room = double_hero_room
	self.window:add_child(double_hero_room)
	]]
	------多种选项
	local more_button = KImageButton:new("map_configBtn_0001", "map_configBtn_0002", "map_configBtn_0003")

	more_button.anchor = v(more_button.size.x / 2, more_button.size.y / 2)
	more_button.pos = v(80, 160)

	function more_button.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")
		self.more_option_panel:show()
	end
	self.more_button = more_button

	self.window:add_child(more_button)	

	-- Android/Harmony does not have a physical Tab key. Keep this button
	-- outside the group hidden by Tab so the player can always restore it.
	if IS_ANDROID then
		local tab_button = KImageButton:new("map_configBtn_0001", "map_configBtn_0002", "map_configBtn_0003")

		tab_button.anchor = v(tab_button.size.x / 2, tab_button.size.y / 2)
		tab_button.pos = v(80, 250)
		tab_button.text = "TAB"
		tab_button.text_size = V.vclone(tab_button.size)
		tab_button.font_name = "body"
		tab_button.font_size = 24
		tab_button.text_align = "center"
		tab_button.vertical_align = "middle"
		tab_button.colors.text = {
			255,
			255,
			255,
			255
		}

		function tab_button.on_click(this, button, x, y)
			S:queue("GUIButtonCommon")
			self:keypressed("tab", false)
		end

		self.android_tab_button = tab_button

		self.window:add_child(tab_button)
	end
	------
	local u_button = GGButton:new("mapButtons-notxt_0010", "mapButtons-notxt_0011")

	u_button.anchor = v(u_button.size.x / 2, u_button.size.y / 2)
	u_button.pos = v(e_button.pos.x - 170, sh - 90)

	function u_button.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")
		self.upgrades:show()

		if self.upgradeTip then
			self.upgradeTip.hidden = true
		end
	end

	u_button.label.pos = v(50, 121)
	u_button.label.size = v(126, 30)
	u_button.label.text_size = u_button.label.size
	u_button.label.font_size = 18
	u_button.label.vertical_align = CJK("middle", "top", nil, "top")
	u_button.label.text = _("UPGRADES")
	u_button.label.fit_lines = 1
	self.u_button = u_button

	self.window:add_child(u_button)

	if DBG_SHOW_BALLOONS or self.unlock_data.new_level == 2 then
		self.upgradeTip = KImageView:new("mapBaloon_buyUpgrade_notxt")
		self.upgradeTip.anchor = v(self.upgradeTip.size.x / 2, self.upgradeTip.size.y)
		self.upgradeTip.pos = v(e_button.pos.x - 120, sh - 160)

		self.window:add_child(self.upgradeTip)

		local l = GGLabel:new(V.v(228, 34))

		l.pos = v(15, CJK(19, nil, 24, 26))
		l.font_name = "body"
		l.font_size = 28
		l.text = _("BUY UPGRADES!")
		l.text_align = "center"
		l.vertical_align = "middle"
		l.colors.text = {
			0,
			102,
			158,
			255
		}
		l.line_height = CJK(0.7, nil, 1.1, nil)
		l.fit_lines = 2

		self.upgradeTip:add_child(l)

		local l = GGLabel:new(V.v(228, 72))

		l.pos = v(15, CJK(62, nil, 80, 74))
		l.font_name = "body"
		l.font_size = 18
		l.text = _("Use the earned stars to improve your towers and powers!")
		l.colors.text = {
			46,
			41,
			39,
			255
		}
		l.line_height = CJK(0.9, nil, 1.25, nil)
		l.fit_lines = 3

		self.upgradeTip:add_child(l)
	end

	self.upgrade_star = KImageView:new("mapUpgradePointsAvailable")
	self.upgrade_star.anchor = v(self.upgrade_star.size.x / 2, self.upgrade_star.size.y / 2)
	self.upgrade_star.pos = v(u_button.pos.x + 20, u_button.pos.y - 50)
	self.upgrade_star.scale = v(0.85, 0.85)
	self.upgrade_star.propagate_on_click = true

	self.window:add_child(self.upgrade_star)

	local points_label = KLabel:new(V.v(self.upgrade_star.size.x, 24))

	points_label.pos = v(0, 19)
	points_label.font = F:f("Comic Book Italic", "22")
	points_label.colors.text = {
		78,
		43,
		7
	}
	points_label.text = "1"
	points_label.text_align = "center"
	points_label.propagate_on_click = true

	self.upgrade_star:add_child(points_label)

	self.upgrade_points = points_label

	local h_button = GGButton:new("mapButtons-notxt_0001", "mapButtons-notxt_0002")

	h_button.anchor = v(h_button.size.x / 2, u_button.size.y / 2)
	h_button.pos = v(u_button.pos.x - 170, sh - 90)

	function h_button.on_click(this, button, x, y)
		S:queue("GUIButtonCommon")
		self:dismiss_map_entry_hint("mapHeroRoomTip", "map_hero_room_tip", true)
		self:remove_map_entry_hint("mapTowerRoomTip")
		self.hero_room:show()

		if self.heroTip then
			self.heroTip.hidden = true
		end
	end

	h_button.label.pos = v(50, 121)
	h_button.label.size = v(126, 30)
	h_button.label.text_size = h_button.label.size
	h_button.label.font_size = 18
	h_button.label.vertical_align = CJK("middle", "top", nil, "top")
	h_button.label.text = _("HERO ROOM")
	h_button.label.fit_lines = 1

	self.window:add_child(h_button)

	self.hero_but = h_button

	local hero_unlock_levels = table.map(screen_map.hero_data, function(k, v)
		return v.available_level
	end)

	if DBG_SHOW_BALLOONS or table.contains(hero_unlock_levels, self.unlock_data.new_level) then
		self.heroTip = KImageView:new("mapBalloon_heroUnlocked_notxt")
		self.heroTip.anchor = v(self.heroTip.size.x / 2, self.heroTip.size.y)
		self.heroTip.pos = v(h_button.pos.x, sh - 165)

		self.window:add_child(self.heroTip)

		local l = GGLabel:new(V.v(160, 46))

		l.pos = v(10, 10)
		l.font_name = "body"
		l.font_size = 22
		l.line_height = 0.8
		l.text = _("HERO UNLOCKED!")
		l.text_align = "center"
		l.vertical_align = "middle"
		l.colors.text = {
			0,
			102,
			158,
			255
		}
		l.fit_lines = 2

		self.heroTip:add_child(l)
	end

	self.hero_icon_portrait = KImageView:new("mapButtons_portrait_hero_0001")
	self.hero_icon_portrait.propagate_on_click = true
	self.hero_icon_portrait.propagate_on_down = true
	self.hero_icon_portrait.propagate_on_up = true
	self.hero_icon_portrait.hidden = true

	if self.user_data.heroes.selected then
		self.hero_icon_portrait.hidden = false
	end

	h_button:add_child(self.hero_icon_portrait)

	self.skill_star = KImageView:new("mapButtons_portrait_hero_points")
	self.skill_star.anchor = v(self.skill_star.size.x / 2, self.skill_star.size.y / 2)
	self.skill_star.pos = v(h_button.pos.x + 40, h_button.pos.y - 45)
	self.skill_star.propagate_on_click = true
	self.skill_star.hidden = true

	self.window:add_child(self.skill_star)

	local points_label = KLabel:new(V.v(self.skill_star.size.x, 24))

	points_label.pos = v(-1, 11)
	points_label.font = F:f("Comic Book Italic", "22")
	points_label.colors.text = {
		78,
		43,
		7
	}
	points_label.text_align = "center"
	points_label.propagate_on_click = true

	self.skill_star:add_child(points_label)

	self.skill_label = points_label


	local hs = get_hero_stats(screen_map.user_data.heroes.selected)

	if hs.remaining_points > 0 then
		self.skill_star.hidden = false
		points_label.text = tostring(hs.remaining_points)
	end

	if DBG_SHOW_BALLOONS or not screen_map.user_data.seen.map_skill_tip and not self.heroTip and screen_map.user_data.heroes.selected == GS.default_hero and screen_map.user_data.heroes.status[GS.default_hero].xp >= GS.hero_xp_thresholds[1] then
		self.heroTip = KImageView:new("mapBaloon_heroLvlUp_notxt")
		self.heroTip.anchor = v(self.heroTip.size.x / 2, self.heroTip.size.y)
		self.heroTip.pos = v(h_button.pos.x - 120, sh - 160)

		self.window:add_child(self.heroTip)

		screen_map.user_data.seen.map_skill_tip = true

		local l = GGLabel:new(V.v(228, 34))

		l.pos = v(15, 19)
		l.font_name = "body"
		l.font_size = 26
		l.text = _("HERO LEVEL UP!")
		l.text_align = "center"
		l.vertical_align = "middle"
		l.colors.text = {
			0,
			102,
			158,
			255
		}
		l.line_height = 0.7
		l.fit_lines = 2

		self.heroTip:add_child(l)

		local l = GGLabel:new(V.v(228, 52))

		l.pos = v(15, 62)
		l.font_name = "body"
		l.font_size = 18
		l.text = _("Use the earned hero points to train your hero!")
		l.colors.text = {
			46,
			41,
			39,
			255
		}
		l.line_height = CJK(0.9, nil, 1.25, nil)
		l.fit_lines = 3

		self.heroTip:add_child(l)
	end

	local stars_banner = StarsBanner:new()

	
	stars_banner.pos = v(sw - 190, 30)

	self.stars_banner = stars_banner
	self.window:add_child(stars_banner)

	local popup_sw = IS_ANDROID and unscaled_sw or sw
	local popup_sh = IS_ANDROID and unscaled_sh or sh
	local upgrades = configure_android_map_popup(UpgradesView:new(popup_sw, popup_sh))

	upgrades.pos = v(0, 0)

	self.window:add_child(upgrades)

	self.upgrades = upgrades

	self.upgrades:set_init_values(screen_map.total_stars)

	local encyclopedia = configure_android_map_popup(EncyclopediaView:new(popup_sw, popup_sh))

	encyclopedia.pos = v(0, 0)
	self.encyclopedia = encyclopedia

	self.window:add_child(encyclopedia)

	self:show_map_entry_hints()

	local hero_room

	if IS_KR1 then
		local ctx = {}

		ctx.ref_h = self.ref_h

		function ctx.cjk(default, zh, ja, kr)
			return i18n.cjk(i18n, default, zh, ja, kr)
		end

		local tt = kui_db:get_table("hero_room_view", ctx)

		hero_room = HeroRoomViewKR1:new_from_table(tt)
		hero_room.pos = v((popup_sw - hero_room.size.x) / 2, 0)
	else
		hero_room = HeroRoomView:new(popup_sw, popup_sh)
		hero_room.pos = v(0, 0)
	end

	hero_room = configure_android_map_popup(hero_room)

	self.hero_room = hero_room

	self.window:add_child(hero_room)

	self.spell_select = configure_android_map_popup(SpellSelectView:new(popup_sw, popup_sh))
	self.spell_select.pos = v(0, 0)
	self.window:add_child(self.spell_select)

	--新增防御塔选择界面tower_room
	self.tower_room = configure_android_map_popup(TowerSelectView:new(popup_sw, popup_sh))
	self.tower_room.pos = v(0, 0)
	self.window:add_child(self.tower_room)

	--新增5代英雄选择界面hero5_room
	self.hero5_room = configure_android_map_popup(Hero5SelectView:new(popup_sw, popup_sh))
	self.hero5_room.pos = v(0, 0)
	self.window:add_child(self.hero5_room)
	-------多种选项
	self.more_option_panel = configure_android_map_popup(MoreOptionsView:new(popup_sw, popup_sh))
	self.more_option_panel.pos = v(0, 0)
	self.window:add_child(self.more_option_panel)
	-------
	self.difficulty_view = configure_android_map_popup(DifficultyView:new(popup_sw, popup_sh))
	self.difficulty_view.pos = v(0, 0)
	self.window:add_child(self.difficulty_view)

	self.new_player_setup_stage = screen_map.user_data.difficulty == nil and "difficulty" or nil

	if screen_map.user_data.difficulty == nil or DEBUG_SHOW_DIFFICULTY then
		self.difficulty_view:show()
	end

	self.option_panel = configure_android_map_popup(OptionsView:new(popup_sw, popup_sh))
	self.option_panel.pos = v(0, 0)

	self.window:add_child(self.option_panel)

	self.developer_mode_panel = configure_android_map_popup(DeveloperModeView:new(popup_sw, popup_sh))
	self.developer_mode_panel.pos = v(0, 0)

	self.window:add_child(self.developer_mode_panel)

	if IS_ANDROID then
		self.mobile_settings_panel = configure_android_map_popup(MobileSettingsView:new(popup_sw, popup_sh))
		self.mobile_settings_panel.pos = v(0, 0)
		self.window:add_child(self.mobile_settings_panel)
	else
		self.shortcut_settings_panel = ShortcutSettingsView:new(popup_sw, popup_sh)
		self.shortcut_settings_panel.pos = v(0, 0)
		self.window:add_child(self.shortcut_settings_panel)
	end

	self.stime = 0
	self.achievements = configure_android_map_popup(AchievementsView:new(popup_sw, popup_sh))
	self.achievements.pos = v(0, 0)

	self.window:add_child(self.achievements)

	local wave_editor_sw = IS_ANDROID and unscaled_sw or sw
	local wave_editor_sh = IS_ANDROID and unscaled_sh or sh

	self.wave_editor = WaveEditorView:new(wave_editor_sw, wave_editor_sh, self)
	self.wave_editor.pos = v(0, 0)

	if IS_ANDROID then
		local inverse_ui_scale = 1 / android_ui_scale

		self.wave_editor.scale = v(inverse_ui_scale, inverse_ui_scale)
	end

	self.window:add_child(self.wave_editor)

	self:set_map_ui_hidden(ui_hidden)
	self:queue_map_music()
end

function screen_map:queue_map_music()
	if self.kr1_map then
		S:queue("MusicMap1")
	elseif self.kr2_map then
		S:queue("MusicMap2")
	elseif self.kr5_map then
		S:queue("MusicMap5")
	elseif self.kr4_map then
		S:queue("MusicMap4")
	elseif self.kr6_map then
		S:queue("MusicMap6")
	else
		S:queue("MusicMap")
	end
end

function screen_map:destroy()
	timer.clear()
	self.window:destroy()

	self.window = nil
	self._set_map_switcher_open = nil

	SU.remove_references(self, KView)
end

function screen_map:update(dt)
	self.window:update(dt)
	timer.update(dt)

	self.stime = self.stime + dt * 10

	if not self.upgrade_star.hidden then
		self.upgrade_star.scale = v(math.sin(self.stime) * 0.05 + 0.8, math.sin(self.stime) * 0.05 + 0.8)
	end

	if self.upgradeTip then
		self.upgradeTip.scale = v(math.sin(self.stime * 0.5) * 0.02 + 0.98, math.sin(self.stime * 0.5) * 0.02 + 0.98)
	end

	if self.heroTip then
		self.heroTip.scale = v(math.sin(self.stime * 0.5) * 0.02 + 0.98, math.sin(self.stime * 0.5) * 0.02 + 0.98)
	end

	if self.mapTowerRoomTip then
		self.mapTowerRoomTip.scale = v(math.sin(self.stime * 0.5) * 0.02 + 0.98, math.sin(self.stime * 0.5) * 0.02 + 0.98)
	end

	if self.mapHeroRoomTip then
		self.mapHeroRoomTip.scale = v(math.sin(self.stime * 0.5) * 0.02 + 0.98, math.sin(self.stime * 0.5) * 0.02 + 0.98)
	end

	if self.mapHideUITip then
		self.mapHideUITip.scale = v(math.sin(self.stime * 0.5) * 0.02 + 0.98, math.sin(self.stime * 0.5) * 0.02 + 0.98)
	end

	if not self.skill_star.hidden then
		self.skill_star.scale = v(math.sin(self.stime) * 0.05 + 0.95, math.sin(self.stime) * 0.05 + 0.95)
	end

	if self.endlessTip then
		self.endlessTip.scale = v(math.sin(self.stime * 0.5) * 0.02 + 0.98, math.sin(self.stime * 0.5) * 0.02 + 0.98)
	end
end

function screen_map:draw()
	self.window:draw()
end

function screen_map:set_map_ui_hidden(hidden)
	hidden = hidden and true or false
	if hidden == self.button_hidden then return end

	-- Tab only detaches map controls, never modal rooms opened by shortcuts.
	for _, item in pairs({
		self.tower5_room, self.spell_select_button, self.a_button,
		self.u_button, self.o_button, self.e_button,
		self.change_button1, self.change_button2, self.change_button3,
		self.change_button4, self.change_button5, self.change_button6,
		self.hero_but, self.skill_star, self.upgrade_star,
		self.stars_banner, self.more_button
	}) do
		if hidden and item.parent == self.window then
			self.window:remove_child(item)
		elseif not hidden and not item.parent then
			self.window:add_child(item)
		end
	end

	if not hidden then
		for _, popup in pairs({
			self.upgrades, self.encyclopedia, self.hero_room, self.spell_select,
			self.tower_room, self.hero5_room, self.more_option_panel,
			self.difficulty_view, self.option_panel, self.developer_mode_panel,
			self.mobile_settings_panel, self.shortcut_settings_panel,
			self.achievements, self.wave_editor, self.level_select
		}) do
			if popup.parent == self.window then popup:order_to_front() end
		end
	end
	self.button_hidden = hidden
end

function screen_map:keypressed(key, isrepeat)
	if self.shortcut_settings_panel and not self.shortcut_settings_panel.hidden then
		if self.window:keypressed(key, isrepeat) then
			return true
		elseif key ~= "escape" then
			return true
		end
	end

	if key == "escape" then
		if self.encyclopedia and not self.encyclopedia.hidden and self.encyclopedia.hide_tower_power_popup and self.encyclopedia:hide_tower_power_popup() then
			return
		elseif self.tower_room and not self.tower_room.hidden and self.tower_room.hide_tower_power_popup and self.tower_room:hide_tower_power_popup() then
			return
		end

		if self.level_select and not self.level_select.hidden then
			self.level_select:hide()
		elseif self.wave_editor and not self.wave_editor.hidden then
			self.wave_editor:hide()
		elseif self.mobile_settings_panel and not self.mobile_settings_panel.hidden then
			self.mobile_settings_panel:hide()
			self.option_panel:show()
		elseif self.shortcut_settings_panel and not self.shortcut_settings_panel.hidden then
			self.shortcut_settings_panel:hide()
			self.option_panel:show()
		elseif self.developer_mode_panel and not self.developer_mode_panel.hidden then
			self.developer_mode_panel:hide()
			self.option_panel:show()
		elseif not self.hero_room.hidden then
			self.hero_room:hide()
		elseif not self.upgrades.hidden then
			self.upgrades:hide()
		elseif not self.encyclopedia.hidden then
			self.encyclopedia:hide()
		elseif not self.achievements.hidden then
			self.achievements:hide()
		elseif not self.spell_select.hidden then
			self.spell_select:hide()
		elseif not self.tower_room.hidden then
			self.tower_room:hide();
		--elseif not self.hero5_room.hidden then
		--	self.hero5_room:hide();
		elseif not self.difficulty_view.hidden then
			-- block empty
		elseif not self.more_option_panel.hidden then
			-- block empty
			self.more_option_panel:hide()
		elseif not self.option_panel.hidden then
			self.option_panel:hide()
		else
			self.option_panel:show()
		end
	end

	local map_shortcuts = self.map_shortcuts or shortcut_settings.load_context("map")

	if shortcut_settings.matches(map_shortcuts, "more_options", key) then
		if not self.more_option_panel.hidden then
			self.more_option_panel:hide()
		else
			self.more_option_panel:show()
		end
	end

	if shortcut_settings.matches(map_shortcuts, "heroes", key) then
		if not self.hero_room.hidden then
			self.hero_room:hide()
		else
			self.hero_room:show()
		end
	end

	if shortcut_settings.matches(map_shortcuts, "towers", key) then
		if not self.tower_room.hidden then
			self.tower_room:hide()
		else
			self.tower_room:show()
		end
	end
	
	if shortcut_settings.matches(map_shortcuts, "upgrades", key) then
		if not self.upgrades.hidden then
			self.upgrades:hide()
		else
			self.upgrades:show()
		end
	end

	if shortcut_settings.matches(map_shortcuts, "spells", key) then
		if not self.spell_select.hidden then
			self.spell_select:hide()
		else
			self.spell_select:show()
		end
	end

	if shortcut_settings.matches(map_shortcuts, "difficulty", key) then
		if not self.difficulty_view.hidden then
			self.difficulty_view:hide()
		else
			self.difficulty_view:show()
		end
	end

	if shortcut_settings.matches(map_shortcuts, "encyclopedia", key) then
		if not self.encyclopedia.hidden then
			self.encyclopedia:hide()
		else
			self.encyclopedia:show()
		end
	end

	if shortcut_settings.matches(map_shortcuts, "achievements", key) then
		if not self.achievements.hidden then
			self.achievements:hide()
		else
			self.achievements:show()
		end
	end

	if shortcut_settings.matches(map_shortcuts, "map_1", key) then
		self.change_button1:on_click()
	end

	if shortcut_settings.matches(map_shortcuts, "map_2", key) then
		self.change_button2:on_click()
	end

	if shortcut_settings.matches(map_shortcuts, "map_3", key) then
		self.change_button3:on_click()
	end

	if shortcut_settings.matches(map_shortcuts, "map_4", key) then
		self.change_button4:on_click()
	end

	if shortcut_settings.matches(map_shortcuts, "map_5", key) then
		self.change_button5:on_click()
	end

	if shortcut_settings.matches(map_shortcuts, "toggle_ui", key) then
		self:dismiss_map_entry_hint("mapHideUITip", "map_hide_ui_tip_" .. screen_map_current_generation(self), true)

		self:set_map_ui_hidden(not self.button_hidden)
	end

	if DEBUG_MAP_ANI_EDITOR and self.SEL_ANI then
		local inc = 1

		if love.keyboard.isDown("lshift") then
			inc = 20
		end

		local ctrl = love.keyboard.isDown("lctrl")
		local av = self.SEL_ANI

		if ctrl then
			if key == "up" then
				if not av.scale then
					av.scale = {
						x = 1,
						y = 1
					}
				end

				av.scale.x = av.scale.x + 0.1
				av.scale.y = av.scale.y + 0.1
			elseif key == "down" then
				if not av.scale then
					av.scale = {
						x = 1,
						y = 1
					}
				end

				av.scale.x = av.scale.x - 0.1
				av.scale.y = av.scale.y - 0.1
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

		if key == "h" then
			av.hidden = not av.hidden
		end

		if key == "c" then
			if not av.colors.background then
				av.colors.background = {
					200,
					200,
					200,
					100
				}
			else
				av.colors.background = nil
			end
		end

		if key == "space" or key == "return" then
			if not self.SEL_LIST then
				self.SEL_LIST = {}
			end

			self.SEL_LIST[av.id] = {
				pos = av.pos,
				scale = av.scale
			}

			local out = "---------------------------\n"

			for iid, iv in pairs(self.SEL_LIST) do
				out = out .. string.format("%s = { pos=v(%s,%s), scale=v(%s,%s)\n", iid, iv.pos.x, iv.pos.y, iv.scale.x, iv.scale.y)
			end

			out = out .. "---------------------------\n"

			log.debug("\n%s\n", out)
		end
	end

end

function screen_map:keyreleased(key)
	return
end

function screen_map:mousepressed(x, y, button, istouch)
	if not IS_ANDROID and button == 1 and self.map_view then
		self.map_view.can_drag = not self:android_map_modal_open() and self.map_view:can_pan()

		if self.map_view.can_drag then
			self.map_view.scrolling_dir = 0
			self.map_view:on_down(button, x, y, istouch)
		end
	end

	self.window:mousepressed(x, y, button, istouch)
end

function screen_map:mousereleased(x, y, button, istouch)
	self.window:mousereleased(x, y, button, istouch)
end

function screen_map:wheelmoved(dx, dy)
	if not IS_ANDROID and self.map_view and dy ~= 0 and not self:android_map_modal_open() then
		local x, y = love.mouse.getPosition()
		local px, py = self:android_map_point(x, y)
		local map = self.map_view
		local view_right = map.viewport_left + map.viewport_w
		local view_bottom = map.viewport_top + map.viewport_h

		if px >= map.viewport_left and px <= view_right and py >= map.viewport_top and py <= view_bottom then
			local old_zoom = map.zoom
			local new_zoom = km.clamp(map.min_zoom, map.max_zoom, old_zoom * 1.05 ^ dy)

			if new_zoom ~= old_zoom then
				local map_x = (px - map.pos.x) / old_zoom
				local map_y = (py - map.pos.y) / old_zoom

				map.zoom = new_zoom
				map.scale.x, map.scale.y = new_zoom, new_zoom
				map.pos.x = px - map_x * new_zoom
				map.pos.y = py - map_y * new_zoom
				map.scrolling_dir = 0
				map:clamp_zoom_position()
			end

			return
		end
	end

	self.window:wheelmoved(dx, dy)
end

local function screen_map_view_is_inside(view, ancestor)
	while view do
		if view == ancestor then
			return true
		end

		view = view.parent
	end

	return false
end

function screen_map:android_map_point(x, y)
	local window = self.window

	return (x - window.origin.x) / window.scale.x, (y - window.origin.y) / window.scale.y
end

function screen_map:android_map_active_modal()
	-- This list is intentionally sparse (for example level_select is nil until
	-- a flag is opened), so pairs must be used instead of ipairs.
	for _, view in pairs({
		self.level_select,
		self.option_panel,
		self.mobile_settings_panel,
		self.shortcut_settings_panel,
		self.developer_mode_panel,
		self.more_option_panel,
		self.difficulty_view,
		self.upgrades,
		self.encyclopedia,
		self.hero_room,
		self.spell_select,
		self.tower_room,
		self.hero5_room,
		self.achievements,
		self.wave_editor
	}) do
		if view and not view.hidden then
			return view
		end
	end

	return nil

end


function screen_map:android_map_modal_open()
	return self:android_map_active_modal() ~= nil
end

function screen_map:android_modal_target(modal)
	return modal and (modal.android_zoom_target or modal.back or modal) or nil
end

function screen_map:android_modal_transform(modal)
	local target = self:android_modal_target(modal)

	if not target then
		return nil
	end

	local state = self._android_modal_transform

	if state and state.target == target and state.session == target._android_ui_session then
		return state
	end

	-- A newly opened panel always starts at its authored scale and centred
	-- position.  The state is kept on the target so reopening another panel
	-- cannot inherit the previous panel's zoom or pan offset.
	target._android_ui_base_scale_x = target._android_ui_base_scale_x or target.scale.x
	target._android_ui_base_scale_y = target._android_ui_base_scale_y or target.scale.y
	target._android_ui_base_pos_x = target.pos.x
	target._android_ui_base_pos_y = target.pos.y
	target._android_ui_zoom = target._android_ui_zoom or 1

	state = {
		modal = modal,
		target = target,
		base_scale_x = target._android_ui_base_scale_x,
		base_scale_y = target._android_ui_base_scale_y,
		base_pos_x = target._android_ui_base_pos_x,
		base_pos_y = target._android_ui_base_pos_y,
		zoom = target._android_ui_zoom,
		min_zoom = 1,
		max_zoom = 3,
		session = target._android_ui_session
	}

	self._android_modal_transform = state

	return state
end

function screen_map:clamp_android_modal_transform(state)
	if not state or not state.target then
		return
	end

	local target = state.target

	state.zoom = km.clamp(state.min_zoom, state.max_zoom, state.zoom)

	local viewport_w = self.window and self.window.size.x or self.sw or target.size.x
	local viewport_h = self.window and self.window.size.y or self.sh or target.size.y
	local scaled_w = target.size.x * state.base_scale_x * state.zoom
	local scaled_h = target.size.y * state.base_scale_y * state.zoom
	local max_pan_x = math.max(0, (scaled_w - viewport_w) * 0.5)
	local max_pan_y = math.max(0, (scaled_h - viewport_h) * 0.5)

	target._android_ui_zoom = state.zoom
	target.scale.x = state.base_scale_x * state.zoom
	target.scale.y = state.base_scale_y * state.zoom
	target.pos.x = km.clamp(state.base_pos_x - max_pan_x, state.base_pos_x + max_pan_x, target.pos.x)
	target.pos.y = km.clamp(state.base_pos_y - max_pan_y, state.base_pos_y + max_pan_y, target.pos.y)
end

function screen_map:reset_android_modal_transform(state)
	state = state or self._android_modal_transform

	if not state or not state.target then
		return
	end

	state.zoom = 1
	state.target._android_ui_zoom = 1
	state.target.scale.x = state.base_scale_x
	state.target.scale.y = state.base_scale_y
	state.target.pos.x = state.base_pos_x
	state.target.pos.y = state.base_pos_y
end

function screen_map:android_map_pan_allowed()
	if not self.map_view or self:android_map_modal_open() then
		return false
	end

	local pressed_view = self.window and self.window._click_start_view

	return not pressed_view or screen_map_view_is_inside(pressed_view, self.map_view)
end

function screen_map:cancel_android_map_pointer()
	local window = self.window

	if not window then
		return
	end

	local pressed_view = window._click_start_view

	if pressed_view and pressed_view.on_exit then
		pressed_view:on_exit(window._drag_view)
	end

	window._mouse_down_pos = nil
	window._click_start_view = nil
	window._drag_view = nil
	window._last_mouse_pos = nil
end

function screen_map:touchpressed(id, x, y, dx, dy, pressure)
	if not IS_ANDROID or not self.map_view then
		return
	end

	local px, py = self:android_map_point(x, y)
	local modal = self:android_map_active_modal()

	if modal then
		local state = self:android_modal_transform(modal)

		if not state then
			return
		end

		self._android_modal_touches = self._android_modal_touches or {}
		self._android_modal_touches[id] = V.v(px, py)

		local points = {}

		for _, point in pairs(self._android_modal_touches) do
			table.insert(points, point)
		end

		if #points == 1 then
			self._android_modal_pan = {
				id = id,
				start_x = px,
				start_y = py,
				last_x = px,
				last_y = py,
				active = false,
				state = state
			}
		elseif #points == 2 then
			local p1, p2 = points[1], points[2]
			local cx, cy = (p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5
			local dist = math.sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2)

			self._android_modal_pan = nil

			if dist > 0 then
				self._android_modal_pinch = {
					dist = dist,
					zoom = state.zoom,
					anchor_x = (cx - state.target.pos.x) / (state.base_scale_x * state.zoom),
					anchor_y = (cy - state.target.pos.y) / (state.base_scale_y * state.zoom),
					state = state
				}
				self:cancel_android_map_pointer()
			end
		end

		return
	end

	self._android_map_touches = self._android_map_touches or {}
	self._android_map_touches[id] = V.v(px, py)

	local points = {}

	for _, point in pairs(self._android_map_touches) do
		table.insert(points, point)
	end

	if #points == 1 then
		self._android_map_pan = {
			id = id,
			start_x = px,
			start_y = py,
			last_x = px,
			last_y = py,
			active = false
		}
	elseif #points == 2 then
		local p1, p2 = points[1], points[2]
		local cx, cy = (p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5
		local dist = math.sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2)

		self._android_map_pan = nil

		if dist > 0 then
			self._android_map_pinch = {
				dist = dist,
				zoom = self.map_view.zoom,
				map_x = (cx - self.map_view.pos.x) / self.map_view.zoom,
				map_y = (cy - self.map_view.pos.y) / self.map_view.zoom
			}
			self.map_view.scrolling_dir = 0
			self:cancel_android_map_pointer()
		end
	end
end

function screen_map:touchreleased(id, x, y, dx, dy, pressure)
	if not IS_ANDROID then
		return
	end

	if self._android_modal_touches and self._android_modal_touches[id] then
		if self._android_modal_pan and self._android_modal_pan.id == id then
			if self._android_modal_pan.active then
				self:cancel_android_map_pointer()
			end

			self._android_modal_pan = nil
		end

		self._android_modal_touches[id] = nil
		self._android_modal_pinch = nil

		return
	end

	if not self._android_map_touches then
		return
	end

	if self._android_map_pan and self._android_map_pan.id == id then
		if self._android_map_pan.active then
			self:cancel_android_map_pointer()
		end

		self._android_map_pan = nil
	end

	self._android_map_touches[id] = nil
	self._android_map_pinch = nil
end

function screen_map:touchmoved(id, x, y, dx, dy, pressure)
	if not IS_ANDROID or not self.map_view then
		return
	end

	local px, py = self:android_map_point(x, y)

	if self._android_modal_touches and self._android_modal_touches[id] then
		self._android_modal_touches[id] = V.v(px, py)

		local points = {}

		for _, point in pairs(self._android_modal_touches) do
			table.insert(points, point)
		end

		if #points == 2 and self._android_modal_pinch then
			local p1, p2 = points[1], points[2]
			local cx, cy = (p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5
			local dist = math.sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2)
			local pinch = self._android_modal_pinch
			local state = pinch.state

			state.zoom = km.clamp(state.min_zoom, state.max_zoom, pinch.zoom * dist / pinch.dist)
			state.target.pos.x = cx - pinch.anchor_x * state.base_scale_x * state.zoom
			state.target.pos.y = cy - pinch.anchor_y * state.base_scale_y * state.zoom
			self:clamp_android_modal_transform(state)
		elseif #points == 1 and self._android_modal_pan and self._android_modal_pan.id == id then
			local pan = self._android_modal_pan
			local state = pan.state
			local move_x = px - pan.last_x
			local move_y = py - pan.last_y

			if not pan.active then
				local total_x, total_y = px - pan.start_x, py - pan.start_y

				if total_x * total_x + total_y * total_y >= 100 and state.zoom > state.min_zoom then
					pan.active = true
					move_x = total_x
					move_y = total_y
					self:cancel_android_map_pointer()
				end
			end

			pan.last_x, pan.last_y = px, py

			if pan.active then
				state.target.pos.x = state.target.pos.x + move_x
				state.target.pos.y = state.target.pos.y + move_y
				self:clamp_android_modal_transform(state)
			end
		end

		return
	end

	if not self._android_map_touches then
		return
	end

	self._android_map_touches[id] = V.v(px, py)

	local points = {}

	for _, point in pairs(self._android_map_touches) do
		table.insert(points, point)
	end

	if #points == 2 and self._android_map_pinch then
		local p1, p2 = points[1], points[2]
		local cx, cy = (p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5
		local dist = math.sqrt((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2)
		local pinch = self._android_map_pinch
		local zoom = km.clamp(self.map_view.min_zoom, self.map_view.max_zoom, pinch.zoom * dist / pinch.dist)

		self.map_view.zoom = zoom
		self.map_view.scale.x, self.map_view.scale.y = zoom, zoom
		self.map_view.pos.x = cx - pinch.map_x * zoom
		self.map_view.pos.y = cy - pinch.map_y * zoom
		self.map_view:clamp_zoom_position()
	elseif #points == 1 and self._android_map_pan and self._android_map_pan.id == id then
		local pan = self._android_map_pan

		if not self:android_map_pan_allowed() then
			self._android_map_pan = nil

			return
		end

		local move_x, move_y = px - pan.last_x, py - pan.last_y

		if not pan.active then
			local total_x, total_y = px - pan.start_x, py - pan.start_y

			if total_x * total_x + total_y * total_y >= 100 then
				pan.active = true
				move_x, move_y = total_x, total_y
				self.map_view.scrolling_dir = 0
				self:cancel_android_map_pointer()
			end
		end

		pan.last_x, pan.last_y = px, py

		if pan.active then
			self.map_view.pos.x = self.map_view.pos.x + move_x
			self.map_view.pos.y = self.map_view.pos.y + move_y
			self.map_view:clamp_zoom_position()
		end
	end
end

function screen_map:start_level(level_idx, level_mode)
	local variant = self.user_data.campaign_variant or CAMPAIGN_VARIANT_REGULAR
	local is_extra_campaign_mode = variant == CAMPAIGN_VARIANT_SPELL_RAID or variant == CAMPAIGN_VARIANT_HERO_RALLY or variant == CAMPAIGN_VARIANT_NOSTALGIC_CLASSIC
	local level_progress = self.user_data.levels and self.user_data.levels[level_idx]

	if level_mode == GAME_MODE_CAMPAIGN and is_extra_campaign_mode and (not level_progress or (level_progress.stars or 0) < 3) then
		if self.level_select and self.level_select.show_three_star_required then
			self.level_select:show_three_star_required()
		end

		return false
	end

	self.user_data.liuhui_hero = self.user_data.liuhui_hero or {}
	self.user_data.liuhui_hero.rallylist = self.user_data.liuhui_hero.rallylist or default_rally_hero_list()
	if infinite_heroes.allowed({campaign_variant = variant}, self.user_data, level_mode) and not self.hero_room:validate_infinite_team() then
		if self.level_select then self.level_select:hide() end
		return false
	end
	storage:save_slot(self.user_data)

	self.done_callback({
		next_item_name = "game",
		level_idx = level_idx,
		level_mode = level_mode,
		level_difficulty = self.user_data.difficulty,
		campaign_variant = variant
	})

end

MapView = class("MapView", KImageView)

function MapView:initialize(screen_w, screen_h, viewport_left, viewport_top, viewport_w, viewport_h, ui_scale)
	self.viewport_left = viewport_left or 0
	self.viewport_top = viewport_top or 0
	self.viewport_w = viewport_w or screen_w
	self.viewport_h = viewport_h or screen_h
	self.ui_scale = ui_scale or 1

	if screen_map.kr6_map then
		KImageView.initialize(self, "KRGMapBackground")

		self.size = V.v(2486, 1339.5)
		self.screen_w = screen_w
		self.screen_h = screen_h
		self.stime = 0
		self.max_scroll_speed = 280
		self.scrolling_dir = 0

		self.ma_under_layer = KView:new(V.v(2486, 1339.5))
		self.ma_under_layer.propagate_on_click = true
		self.ma_under_layer.propagate_on_down = true
		self.ma_under_layer.propagate_on_up = true
		self:add_child(self.ma_under_layer)

		self.points_layer = KView:new(V.v(2486, 1339.5))
		self.points_layer.propagate_on_click = true
		self.points_layer.propagate_on_down = true
		self.points_layer.propagate_on_up = true
		self:add_child(self.points_layer)

		self.ma_mid_layer = KView:new(V.v(2486, 1339.5))
		self.ma_mid_layer.propagate_on_click = true
		self.ma_mid_layer.propagate_on_down = true
		self.ma_mid_layer.propagate_on_up = true
		self:add_child(self.ma_mid_layer)

		self.points_front_layer = KView:new(V.v(2486, 1339.5))
		self.points_front_layer.propagate_on_click = true
		self.points_front_layer.propagate_on_down = true
		self.points_front_layer.propagate_on_up = true
		self:add_child(self.points_front_layer)

		self.flags_layer = KView:new(V.v(2486, 1339.5))
		self.flags_layer.propagate_on_click = true
		self.flags_layer.propagate_on_down = true
		self.flags_layer.propagate_on_up = true
		self:add_child(self.flags_layer)

		self.ma_over_layer = KView:new(V.v(2486, 1339.5))
		self.ma_over_layer.propagate_on_click = true
		self.ma_over_layer.propagate_on_down = true
		self.ma_over_layer.propagate_on_up = true
		self:add_child(self.ma_over_layer)

		local last_flag_idx = 1

		for i = 1, GS.max_level6 do
			if screen_map.user_data.levels[GS.jnum6 + i] then
				last_flag_idx = i
			end
		end

		if screen_map.unlock_data.new_level and screen_map.unlock_data.new_level >= 251 and screen_map.unlock_data.new_level <= 269 then
			last_flag_idx = screen_map.unlock_data.new_level - GS.jnum6
		end

		local last_flag = screen_map.map_points.flags[last_flag_idx]

		if last_flag and last_flag.pos then
			local vl, vr = -1 * self.pos.x, -1 * self.pos.x + self.screen_w

			if vl > last_flag.pos.x or vr < last_flag.pos.x then
				self.pos.x = -(last_flag.pos.x - self.screen_w / 2)
				self.pos.x = km.clamp(self.screen_w - self.size.x, 0, self.pos.x)
			end
		end

		self:load_map_animations(6)

		local clouds = KImageView:new("MASK_clouds")

		clouds.pos = v(0, 0)
		clouds.propagate_on_click = true
		clouds.propagate_on_down = true
		clouds.propagate_on_up = true
		self.ma_mid_layer:add_child(clouds)
		self:show_kr6_map_decos()
		self:show_flags(6)
	elseif screen_map.kr1_map then
		KImageView.initialize(self, "map_background1")

		self.screen_w = screen_w
		self.screen_h = screen_h
		self.stime = 0
		self.max_scroll_speed = 280
		self.scrolling_dir = 0
		self.ma_under_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_under_layer.propagate_on_click = true
		self.ma_under_layer.propagate_on_down = true
		self.ma_under_layer.propagate_on_up = true

		self:add_child(self.ma_under_layer)

		self.points_layer = KView:new(V.v(screen_w, screen_h))
		self.points_layer.propagate_on_click = true
		self.points_layer.propagate_on_down = true
		self.points_layer.propagate_on_up = true

		self:add_child(self.points_layer)

		self.ma_mid_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_mid_layer.propagate_on_click = true
		self.ma_mid_layer.propagate_on_down = true
		self.ma_mid_layer.propagate_on_up = true

		self:add_child(self.ma_mid_layer)

		self.flags_layer = KView:new(V.v(screen_w, screen_h))
		self.flags_layer.propagate_on_click = true
		self.flags_layer.propagate_on_down = true
		self.flags_layer.propagate_on_up = true

		self:add_child(self.flags_layer)

		self.ma_over_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_over_layer.propagate_on_click = true
		self.ma_over_layer.propagate_on_down = true
		self.ma_over_layer.propagate_on_up = true

		self:add_child(self.ma_over_layer)

		local last_flag_idx = screen_map.unlock_data.new_level or #screen_map.user_data.levels
		local last_flag = screen_map.map_points.flags[last_flag_idx]

		if last_flag and last_flag.pos then
			log.debug("scroll to show level idx:%s", last_flag_idx)

			local vl, vr = -1 * self.pos.x, -1 * self.pos.x + self.screen_w

			if vl > last_flag.pos.x or vr < last_flag.pos.x then
				self.pos.x = -(last_flag.pos.x - self.screen_w / 2)
				self.pos.x = km.clamp(self.screen_w - self.size.x, 0, self.pos.x)
			end
		end

		self:load_map_animations(1)
		self:show_flags(1)
	elseif screen_map.kr2_map then
		KImageView.initialize(self, "map_background2")

		self.screen_w = screen_w
		self.screen_h = screen_h
		self.stime = 0
		self.max_scroll_speed = 280
		self.scrolling_dir = 0
		self.ma_under_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_under_layer.propagate_on_click = true
		self.ma_under_layer.propagate_on_down = true
		self.ma_under_layer.propagate_on_up = true

		self:add_child(self.ma_under_layer)

		self.points_layer = KView:new(V.v(screen_w, screen_h))
		self.points_layer.propagate_on_click = true
		self.points_layer.propagate_on_down = true
		self.points_layer.propagate_on_up = true

		self:add_child(self.points_layer)

		self.ma_mid_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_mid_layer.propagate_on_click = true
		self.ma_mid_layer.propagate_on_down = true
		self.ma_mid_layer.propagate_on_up = true

		self:add_child(self.ma_mid_layer)

		self.flags_layer = KView:new(V.v(screen_w, screen_h))
		self.flags_layer.propagate_on_click = true
		self.flags_layer.propagate_on_down = true
		self.flags_layer.propagate_on_up = true

		self:add_child(self.flags_layer)

		self.ma_over_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_over_layer.propagate_on_click = true
		self.ma_over_layer.propagate_on_down = true
		self.ma_over_layer.propagate_on_up = true

		self:add_child(self.ma_over_layer)

		local last_flag_idx = screen_map.unlock_data.new_level or #screen_map.user_data.levels
		local last_flag = screen_map.map_points.flags[last_flag_idx]

		if last_flag and last_flag.pos then
			log.debug("scroll to show level idx:%s", last_flag_idx)

			local vl, vr = -1 * self.pos.x, -1 * self.pos.x + self.screen_w

			if vl > last_flag.pos.x or vr < last_flag.pos.x then
				self.pos.x = -(last_flag.pos.x - self.screen_w / 2)
				self.pos.x = km.clamp(self.screen_w - self.size.x, 0, self.pos.x)
			end
		end

		self:load_map_animations(2)
		self:show_flags(2)
	elseif screen_map.kr5_map then
		KImageView.initialize(self, "MapBackground_kr5")

		self.screen_w = screen_w
		self.screen_h = screen_h
		self.stime = 0
		self.max_scroll_speed = 280
		self.scrolling_dir = 0
		self.ma_under_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_under_layer.propagate_on_click = true
		self.ma_under_layer.propagate_on_down = true
		self.ma_under_layer.propagate_on_up = true

		self:add_child(self.ma_under_layer)

		self.points_layer = KView:new(V.v(screen_w, screen_h))
		self.points_layer.propagate_on_click = true
		self.points_layer.propagate_on_down = true
		self.points_layer.propagate_on_up = true

		self:add_child(self.points_layer)

		self.ma_mid_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_mid_layer.propagate_on_click = true
		self.ma_mid_layer.propagate_on_down = true
		self.ma_mid_layer.propagate_on_up = true

		self:add_child(self.ma_mid_layer)

		self.flags_layer = KView:new(V.v(screen_w, screen_h))
		self.flags_layer.propagate_on_click = true
		self.flags_layer.propagate_on_down = true
		self.flags_layer.propagate_on_up = true

		self:add_child(self.flags_layer)

		self.ma_over_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_over_layer.propagate_on_click = true
		self.ma_over_layer.propagate_on_down = true
		self.ma_over_layer.propagate_on_up = true

		self:add_child(self.ma_over_layer)

		local last_flag_idx = screen_map.unlock_data.new_level or #screen_map.user_data.levels
		local last_flag = screen_map.map_points.flags[last_flag_idx]

		if last_flag and last_flag.pos then
			log.debug("scroll to show level idx:%s", last_flag_idx)

			local vl, vr = -1 * self.pos.x, -1 * self.pos.x + self.screen_w

			if vl > last_flag.pos.x or vr < last_flag.pos.x then
				self.pos.x = -(last_flag.pos.x - self.screen_w / 2)
				self.pos.x = km.clamp(self.screen_w - self.size.x, 0, self.pos.x)
			end
		end

		self:load_map_animations(5)
		self:show_flags(5)
	elseif screen_map.kr4_map then
		KImageView.initialize(self, "MapBackground_kr4")

		self.screen_w = screen_w
		self.screen_h = screen_h
		self.stime = 0
		self.max_scroll_speed = 280
		self.scrolling_dir = 0
		self.ma_under_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_under_layer.propagate_on_click = true
		self.ma_under_layer.propagate_on_down = true
		self.ma_under_layer.propagate_on_up = true

		self:add_child(self.ma_under_layer)

		self.points_layer = KView:new(V.v(screen_w, screen_h))
		self.points_layer.propagate_on_click = true
		self.points_layer.propagate_on_down = true
		self.points_layer.propagate_on_up = true

		self:add_child(self.points_layer)

		self.ma_mid_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_mid_layer.propagate_on_click = true
		self.ma_mid_layer.propagate_on_down = true
		self.ma_mid_layer.propagate_on_up = true

		self:add_child(self.ma_mid_layer)

		self.flags_layer = KView:new(V.v(screen_w, screen_h))
		self.flags_layer.propagate_on_click = true
		self.flags_layer.propagate_on_down = true
		self.flags_layer.propagate_on_up = true

		self:add_child(self.flags_layer)

		self.ma_over_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_over_layer.propagate_on_click = true
		self.ma_over_layer.propagate_on_down = true
		self.ma_over_layer.propagate_on_up = true

		self:add_child(self.ma_over_layer)

		local last_flag_idx = screen_map.unlock_data.new_level or #screen_map.user_data.levels
		local last_flag = screen_map.map_points.flags[last_flag_idx]

		if last_flag and last_flag.pos then
			log.debug("scroll to show level idx:%s", last_flag_idx)

			local vl, vr = -1 * self.pos.x, -1 * self.pos.x + self.screen_w

			if vl > last_flag.pos.x or vr < last_flag.pos.x then
				self.pos.x = -(last_flag.pos.x - self.screen_w / 2)
				self.pos.x = km.clamp(self.screen_w - self.size.x, 0, self.pos.x)
			end
		end

		self:load_map_animations(4)
		self:show_flags(4)
	else
		KImageView.initialize(self, "map_background_0001")

		self.screen_w = screen_w
		self.screen_h = screen_h
		self.stime = 0
		self.max_scroll_speed = 280
		self.scrolling_dir = 0
		self.ma_under_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_under_layer.propagate_on_click = true
		self.ma_under_layer.propagate_on_down = true
		self.ma_under_layer.propagate_on_up = true

		self:add_child(self.ma_under_layer)

		self.mask_under_layer = KImageView:new("map_background_0003")

		self:add_child(self.mask_under_layer)

		self.points_layer = KView:new(V.v(screen_w, screen_h))
		self.points_layer.propagate_on_click = true
		self.points_layer.propagate_on_down = true
		self.points_layer.propagate_on_up = true

		self:add_child(self.points_layer)

		self.ma_mid_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_mid_layer.propagate_on_click = true
		self.ma_mid_layer.propagate_on_down = true
		self.ma_mid_layer.propagate_on_up = true

		self:add_child(self.ma_mid_layer)

		self.flags_layer = KView:new(V.v(screen_w, screen_h))
		self.flags_layer.propagate_on_click = true
		self.flags_layer.propagate_on_down = true
		self.flags_layer.propagate_on_up = true

		self:add_child(self.flags_layer)

		self.ma_over_layer = KView:new(V.v(screen_w, screen_h))
		self.ma_over_layer.propagate_on_click = true
		self.ma_over_layer.propagate_on_down = true
		self.ma_over_layer.propagate_on_up = true

		self:add_child(self.ma_over_layer)

		local last_flag_idx = screen_map.unlock_data.new_level or #screen_map.user_data.levels
		local last_flag = screen_map.map_points.flags[last_flag_idx]

		if last_flag and last_flag.pos then
			log.debug("scroll to show level idx:%s", last_flag_idx)

			local vl, vr = -1 * self.pos.x, -1 * self.pos.x + self.screen_w

			if vl > last_flag.pos.x or vr < last_flag.pos.x then
				self.pos.x = -(last_flag.pos.x - self.screen_w / 2)
				self.pos.x = km.clamp(self.screen_w - self.size.x, 0, self.pos.x)
			end
		end

		self:load_map_animations(3)
		self:show_flags(3)
	end

	local base_pos_x, base_pos_y = self.pos.x, self.pos.y
	local cover_zoom = 1

	if IS_ANDROID then
		-- viewport_* uses the enlarged UI coordinate system. Convert it back to
		-- the unscaled map coordinate space, calculate the normal cover zoom, then
		-- counter the parent UI scale so map content itself is not enlarged.
		local ui_scale = self.ui_scale or 1
		local base_viewport_w = self.viewport_w * ui_scale
		local base_viewport_h = self.viewport_h * ui_scale

		cover_zoom = math.max(1, base_viewport_w / self.screen_w, base_viewport_h / self.screen_h) / ui_scale
	end

	self.zoom = cover_zoom
	self.min_zoom = cover_zoom
	self.max_zoom = IS_ANDROID and 3 / (self.ui_scale or 1) or cover_zoom + 0.2
	self.scale.x, self.scale.y = cover_zoom, cover_zoom

	local viewport_center_x = self.viewport_left + self.viewport_w * 0.5
	local viewport_center_y = self.viewport_top + self.viewport_h * 0.5

	-- Preserve whichever horizontal location the normal map initialization
	-- selected (for example the newest unlocked flag), then zoom around the
	-- centre of the authored viewport.
	self.pos.x = viewport_center_x + (base_pos_x - self.screen_w * 0.5) * cover_zoom
	self.pos.y = viewport_center_y + (base_pos_y - self.screen_h * 0.5) * cover_zoom
	self:clamp_zoom_position()
end

function MapView:clamp_zoom_position()
	self.zoom = km.clamp(self.min_zoom, self.max_zoom, self.zoom or 1)
	self.scale.x, self.scale.y = self.zoom, self.zoom

	local scaled_w = self.size.x * self.zoom
	local scaled_h = self.size.y * self.zoom
	local view_left = self.viewport_left or 0
	local view_top = self.viewport_top or 0
	local view_w = self.viewport_w or self.screen_w
	local view_h = self.viewport_h or self.screen_h
	local min_x = view_left + view_w - scaled_w
	local min_y = view_top + view_h - scaled_h
	local max_x = view_left
	local max_y = view_top

	local drag_max_x = min_x > max_x and view_left + (view_w - scaled_w) * 0.5 or max_x
	local drag_max_y = min_y > max_y and view_top + (view_h - scaled_h) * 0.5 or max_y
	local drag_limits = self.drag_limits or V.r(0, 0, 0, 0)

	self.drag_limits = drag_limits
	drag_limits.pos.x, drag_limits.pos.y = drag_max_x, drag_max_y
	drag_limits.size.x = min_x > max_x and 0 or min_x - max_x
	drag_limits.size.y = min_y > max_y and 0 or min_y - max_y
	self.pos.x = km.clamp(drag_limits.pos.x, drag_limits.pos.x + drag_limits.size.x, self.pos.x)
	self.pos.y = km.clamp(drag_limits.pos.y, drag_limits.pos.y + drag_limits.size.y, self.pos.y)

end

function MapView:can_pan()
	return self.size.x * self.zoom > self.viewport_w + 0.5 or self.size.y * self.zoom > self.viewport_h + 0.5
end

local KR5_MAP_EXO = require("exoskeleton")

KR5MapExo = class("KR5MapExo", KView)

function KR5MapExo:initialize(size, exo_name, exo_animation, exo_scale_factor)
	KView.initialize(self, size)

	self.exo_name = exo_name
	self.exo_animation = exo_animation
	self.exo_scale_factor = exo_scale_factor
	self.runs = 0
	self.ts = self.ts or 0

	self:load_exo()
end

function KR5MapExo:destroy()
	KR5_MAP_EXO:unload(self.exo_name)
	self.batch = nil
	self._exo_frame = nil
	self.animations = nil
	KR5MapExo.super.destroy(self)
end

function KR5MapExo:load_exo()
	local anis, max_parts = KR5_MAP_EXO:load_kui(self.exo_name, true)

	self.animations = anis

	local temp_canvas = G.newCanvas(2, 2)

	self.batch = G.newSpriteBatch(temp_canvas, max_parts, "stream")
end

function KR5MapExo:update(dt)
	if self.ts <= 0 then
		self.runs = 0
	end

	self.ts = self.ts + dt

	local aa_name = self.exo_name .. "_" .. self.exo_animation
	local aa = self.animations and self.animations[aa_name]

	if not aa then
		log.error("Exo animation named %s could not be found in KR5MapExo animations list", aa_name)

		return
	end

	local fn, runs = self:animation_frame(aa, self.ts, self.loop, self.fps)

	self._exo_frame = KR5_MAP_EXO:f(fn)

	if not self.loop and self.runs ~= runs and runs > 0 and self.on_exo_finished then
		self:on_exo_finished(runs)
	end

	self.runs = runs
end

function KR5MapExo:_draw_self()
	local exo_frame = self._exo_frame

	if not exo_frame or not self.batch then
		return
	end

	local current_atlas
	local batch = self.batch
	local batch_count = 0
	local cr, cg, cb, ca = 255, 255, 255, 255
	local lr, lg, lb, la
	local texture_swap_count = 0

	batch:clear()

	for _, part in ipairs(exo_frame) do
		local part_type, part_name_idx, alpha, x, y, sx, sy, r, kx, ky = unpack(part)

		if part_type == 1 or part_type == 2 then
			local source_part = exo_frame.exo.parts[part_name_idx]

			if source_part then
				local part_name, pox, poy = unpack(source_part)
				local ss = I:s(part_name)

				if ss.atlas and ss.atlas ~= current_atlas then
					if batch_count > 0 then
						G.draw(batch)

						batch_count = 0
						texture_swap_count = texture_swap_count + 1
					end

					batch:clear()

					lr, lg, lb, la = nil

					if ss.atlas then
						current_atlas = ss.atlas

						batch:setTexture(I:i(ss.atlas))
					end
				end

				if self.colors.exo then
					cr, cg, cb = self.colors.exo[1], self.colors.exo[2], self.colors.exo[3]
				else
					cr, cg, cb = 255, 255, 255
				end

				ca = self.alpha * (alpha or 1)

				if ca ~= la or cr ~= lr or cg ~= lg or cb ~= lb then
					krflapk_batch_set_color(batch, cr, cg, cb, ca * 255)

					lr, lg, lb, la = cr, cg, cb, ca
				end

				local quad = ss.quad
				local ref_scale = ss.ref_scale or 1
				local raw_sx, raw_sy = sx, sy

				r = -self.r + r
				sx = sx * ref_scale
				sy = sy * ref_scale

				if self.exo_scale_factor then
					local f = self.exo_scale_factor

					x = x * f
					y = y * f
					pox = pox * f
					poy = poy * f
				end

				local ox = 0.5 * ss.size[1] - ss.trim[1] - pox / ref_scale
				local oy = 0.5 * ss.size[2] - ss.trim[2] - poy / ref_scale

				if ss.textureRotated then
					r = r - math.pi / 2
					ox = 0.5 * ss.size[2] - ss.trim[4] + poy / ref_scale
					oy = 0.5 * ss.size[1] - ss.trim[1] - pox / ref_scale
					sy = raw_sx * ref_scale
					sx = raw_sy * ref_scale
				end

				batch:add(quad, x, y, r, sx, sy, ox, oy, kx, ky)

				batch_count = batch_count + 1
			end
		end
	end

	if batch_count > 0 then
		G.draw(batch)
	end

	if texture_swap_count > 5 and not self._warning_shown then
		log.warning("KR5MapExo: texture swapping count was %s for exo:%s", texture_swap_count, self.exo_name .. "_" .. self.exo_animation)

		self._warning_shown = true
	end
end

KR5MapExoOverseer = class("KR5MapExoOverseer", KR5MapExo)

function KR5MapExoOverseer:initialize(size, exo_name, exo_animation, exo_scale_factor)
	KR5MapExo.initialize(self, size, exo_name, exo_animation, exo_scale_factor)

	self.action_cooldown = 8
	self.tick_ts = 0
	self.action_ts = 0
end

function KR5MapExoOverseer:update(dt)
	KR5MapExo.update(self, dt)

	self.tick_ts = self.tick_ts + dt

	if not self.hidden and self.exo_animation ~= "loop_inactive" and self.tick_ts - self.action_ts >= self.action_cooldown then
		self.exo_animation = "action"
		self.ts = 0
		self.action_ts = self.tick_ts
		self.loop = false
	end
end

function KR5MapExoOverseer:on_exo_finished(runs)
	if self.exo_animation == "action" and runs == 1 then
		self.exo_animation = "loop_active"
		self.loop = true
		self.ts = 0
	end
end

if GGExo and not GGExoOverseer then
	GGExoOverseer = class("GGExoOverseer", GGExo)

	function GGExoOverseer:initialize(size, exo_name, exo_animation, exo_scale_factor)
		GGExo.initialize(self, size, exo_name, exo_animation, exo_scale_factor)

		self.hidden = false
		self.ts = 0
		self.runs = 0
		self.action_cooldown = 8
		self.tick_ts = 0
		self.action_ts = 0
	end

	function GGExoOverseer:update(dt)
		GGExo.update(self, dt)

		self.tick_ts = self.tick_ts + dt

		if not self.hidden and self.exo_animation ~= "loop_inactive" and self.tick_ts - self.action_ts >= self.action_cooldown then
			self.exo_animation = "action"
			self.ts = 0
			self.action_ts = self.tick_ts
			self.loop = false
		end
	end

	function GGExoOverseer:on_exo_finished(runs)
		if self.exo_animation == "action" and runs == 1 then
			self.exo_animation = "loop_active"
			self.loop = true
			self.ts = 0
		end
	end
end

function MapView:load_map_animations(num)
	local anis = map_data["map_animations" .. num]
	local offset = map_data["map_animation_offset" .. num]
	local transform = map_data["map_animation_transform" .. num]
	local function random_wait(min, max)
		if min == max then
			return min
		end

		return min + math.random() * (max - min)
	end
	local function transform_pos(pos)
		if not pos or not offset and not transform then
			return pos
		end

		local x, y = pos.x, pos.y

		if transform then
			if transform.flip_y then
				y = transform.flip_y - y
			end

			if transform.offset then
				x = x + transform.offset.x
				y = y + transform.offset.y
			end
		end

		if offset then
			x = x + offset.x
			y = y + offset.y
		end

		return V.v(x, y)
	end

	for _, o in pairs(anis) do
		anis[o.id] = o
	end

	for i = 1, #anis do
		local val = anis[i]
		local ani

		if val.template then
			ani = table.deepmerge(anis[val.template], val, true)
		else
			ani = table.deepclone(val)
		end

		if ani.pos_list then
			ani.pos = ani.pos_list[1]
		end

		if ani.scale_list then
			ani.scale = ani.scale_list[1]
		end

		if offset or transform then
			if ani.pos_list then
				for j = 1, #ani.pos_list do
					ani.pos_list[j] = transform_pos(ani.pos_list[j])
				end

				ani.pos = ani.pos_list[1]
			elseif ani.pos then
				ani.pos = transform_pos(ani.pos)
			end

			if ani.path then
				for j = 1, #ani.path do
					ani.path[j] = transform_pos(ani.path[j])
				end
			end

			if ani.move then
				ani.move.from = transform_pos(ani.move.from)
				ani.move.to = transform_pos(ani.move.to)
			end
		end

		ani.animation = ani.animation or ani.idle_animation

		local av

		if ani.fns then
			local v
			local animation = ani.animations and ani.animations.default or ani.animation

			if animation and animation.prefix and animation.from then
				local f1 = string.format("%s_%04d", animation.prefix, animation.from)

				v = KImageView:new(f1)
			end

			v = v or KView:new()
			v.pos = V.vclone(ani.pos)
			v.anchor = ani.anchor and V.vclone(ani.anchor) or V.v(v.size.x / 2, v.size.y / 2)
			v.r = ani.r or v.r
			v.loop = ani.loop

			if ani.scale then
				v.scale = V.vclone(ani.scale)
			end

			if ani.fns then
				for fk, fn in pairs(ani.fns) do
					v[fk] = fn
				end
			end

			v.ctx = {
				screen_map = screen_map,
				timer = timer,
				data = ani,
				map_view = self
			}
			av = v
		elseif ani.exo_name then
			local exo_class

			if num == 5 then
				exo_class = ani.exo_class == "GGExoOverseer" and KR5MapExoOverseer or KR5MapExo
			else
				exo_class = ani.exo_class == "GGExoOverseer" and GGExoOverseer or GGExo
			end

			av = exo_class:new(nil, ani.exo_name, ani.exo_animation or "loop", ani.exo_scale_factor)
			av.pos = ani.pos and V.vclone(ani.pos) or V.v(0, 0)
			av.anchor = ani.anchor and V.vclone(ani.anchor) or V.v(0, 0)
			av.r = ani.r or av.r
			av.loop = ani.loop

			if ani.scale then
				av.scale = V.vclone(ani.scale)
			end
		elseif ani.pos or ani.path or ani.move then
			local f1 = string.format("%s_%04d", ani.animation.prefix, ani.animation.from)

			av = KImageView:new(f1)
			av.anchor = ani.anchor and V.vclone(ani.anchor) or v(av.size.x / 2, av.size.y / 2)
			av.r = ani.r or av.r

			if ani.scale then
				av.scale = ani.scale
			end

			if ani.pos then
				av.pos = ani.pos
			elseif ani.path then
				av.path = ani.path
				av.pos = ani.path[1]
			end
		else
			av = KView:new(V.v(self.screen_w, self.screen_h))
		end

		av.id = ani.id
		av.alpha = ani.alpha or 1

		if not ani.exo_name then
			av.animation = ani.animation
		end

		if ani.hidden ~= nil then
			av.hidden = ani.hidden
		end

		if ani.ts ~= nil then
			av.ts = ani.ts
		end

		if ani.fns then
			if av.prepare then
				av:prepare()
			end
		elseif ani.exo_name then
			-- GGExo advances its own exoskeleton animation.
		elseif ani.path then
			av.loop = ani.loop
			av.path_idx = 1
			av.hidden = true

			if ani.wait then
				av.every_min = ani.wait[1]
				av.every_max = ani.wait[2]
			end

			timer.after(av.every_min and random_wait(av.every_min, av.every_max) or 0.03333333333333333, function(func)
				if av.path_idx == 1 then
					av.hidden = false
					av.ts = 0
				end

				if av.path_idx > #av.path then
					av.hidden = true
					av.path_idx = 1
					av.ts = 0

					timer.after(av.every_min and random_wait(av.every_min, av.every_max) or 0.03333333333333333, func)
				else
					av.pos = av.path[av.path_idx]
					av.path_idx = av.path_idx + 1

					timer.after(0.03333333333333333, func)
				end
			end)
		elseif ani.move then
			av.move = ani.move
			av.loop = ani.loop
			av.pingpong = ani.pingpong
			av.random_start = ani.random_start

			if ani.wait then
				av.every_min = ani.wait[1]
				av.every_max = ani.wait[2]
			end

			if not av.move.permanent then
				av.hidden = true
			end

			local function move_func()
				timer.after(av.every_min and random_wait(av.every_min, av.every_max) or 0.03333333333333333, function(func)
					av.ts = 0

					if not av.move.permanent then
						av.hidden = false
					end

					local m = av.move
					local move_time = m.time

					av.pos.x, av.pos.y = m.from.x, m.from.y

					local params = {
						pos = {
							x = m.to.x,
							y = m.to.y
						}
					}

					log.paranoid(" MOVING (%s): %s,%s to %s,%s in %s", av.id, av.pos.x, av.pos.y, m.to.x, m.to.y, move_time)
					timer.tween(move_time, av, params, m.interp, function(func2)
						if not av.move.permanent then
							av.hidden = true
						end

						if av.move.pingpong then
							local v = av.move.to

							av.move.to = av.move.from
							av.move.from = v
						end

						timer.after(av.every_min and random_wait(av.every_min, av.every_max) or 0.03333333333333333, func)
					end)
				end)
			end

			if av.random_start then
				av.ts = 0

				local m = av.move

				av.pos.x, av.pos.y = math.random(m.from.x, m.to.x), math.random(m.from.y, m.to.y)

				local move_time = m.time * math.abs(m.to.x - av.pos.x) / math.abs(m.to.x - m.from.x)

				if not av.move.permanent then
					av.hidden = false
				end

				log.paranoid(" RANDOM_START (%s): %s,%s to %s,%s in %s", av.id, av.pos.x, av.pos.y, m.to.x, m.to.y, move_time)
				timer.tween(move_time, av, {
					pos = {
						x = m.to.x,
						y = m.to.y
					}
				}, m.interp, move_func)
			else
				move_func()
			end
		elseif ani.toggle then
			av.every_min = ani.every_min or ani.wait[1]
			av.every_max = ani.every_max or ani.wait[2]
			av.hidden = math.random() > 0.5

			timer.after(random_wait(av.every_min, av.every_max), function(func)
				av.hidden = not av.hidden

				timer.after(random_wait(av.every_min, av.every_max), func)
			end)
		elseif ani.loop then
			av.loop = ani.loop
			av.ts = math.random(av.animation.from, av.animation.to) / 30
		else
			av.ts = ani.animation.to / 30
			av.every_min = ani.every_min or ani.wait[1]
			av.every_max = ani.every_max or ani.wait[2]

			if ani.idle_animation then
				av.loop = true
			end

			local w = random_wait(av.every_min, av.every_max)

			if ani.idle_animation then
				local a = ani.idle_animation
				local a_len = (a.to - a.from + 1) / 30

				w = math.ceil(w / a_len) * a_len
			end

			timer.after(w, function(func)
				if ani.pos_list then
					local idx = math.random(1, #ani.pos_list)

					av.pos = ani.pos_list[idx]

					if ani.scale_list then
						av.scale = ani.scale_list[idx]
					end
				end

				if ani.action_animation then
					av.animation = ani.action_animation
				end

				av.ts = 0
				av.loop = false

				local dur = (av.animation.to - av.animation.from + 1) / 30
				local w2 = random_wait(av.every_min, av.every_max)

				if ani.idle_animation then
					timer.after(dur, function()
						av.animation = ani.idle_animation
						av.ts = 0
						av.loop = true
					end)

					local a = ani.idle_animation
					local a_len = (a.to - a.from + 1) / 30

					w2 = math.ceil(w2 / a_len) * a_len
				end

				timer.after(dur + w2, func)
			end)
		end

		if ani.layer == 1 then
			self.ma_under_layer:add_child(av)
		elseif ani.layer == 2 then
			self.ma_mid_layer:add_child(av)
		elseif ani.layer == 3 then
			self.ma_over_layer:add_child(av)
		else
			log.error("animation layer %s does not exist", ani.layer)
		end

		if DEBUG_MAP_ANI_EDITOR then
			function av.on_click(this)
				screen_map.SEL_ANI = this

				log.debug("sel ani: %s", this.id)
			end
		else
			av.propagate_on_click = true
			av.propagate_on_down = true
			av.propagate_on_up = true
		end
	end
end

function MapView:show_kr6_map_decos()
	local levels = screen_map.user_data.levels
	local new_level = screen_map.unlock_data.new_level
	local function completed(source_level)
		local level = levels[GS.jnum6 + source_level]

		return level and level[GAME_MODE_CAMPAIGN] ~= nil
	end
	local function exo(id)
		return self:ci(id)
	end

	if completed(4) then
		local crane = exo("kr6_map_stage254_crane")
		local wall = exo("kr6_map_stage254_wall")

		if crane then
			crane.hidden = true
		end

		if wall then
			if new_level == 255 then
				wall.exo_animation = "run"
				wall.ts = 0
				wall.loop = false
				function wall.on_exo_finished(this)
					this.exo_animation = "idle_2"
					this.loop = true
					this.ts = 0
					this.on_exo_finished = nil
				end
				S:queue("GUIMapStage4WallBreak")
			else
				wall.exo_animation = "idle_2"
				wall.ts = 0
			end
		end
	end

	local stage5_tree = exo("kr6_map_stage255_tree")
	local stage5_light = exo("kr6_map_stage255_light")

	if stage5_tree then
		stage5_tree.hidden = not completed(5)
	end

	if completed(5) and stage5_tree and stage5_light then
		if new_level == 256 then
			stage5_tree.exo_animation = "run"
			stage5_tree.ts = 0
			stage5_tree.loop = false
			function stage5_tree.on_exo_finished(this)
				this.exo_animation = "idle"
				this.loop = true
				this.ts = 0
				this.on_exo_finished = nil
			end

			stage5_light.exo_animation = "off"
			stage5_light.ts = 0
			stage5_light.loop = false
			function stage5_light.on_exo_finished(this)
				this.exo_animation = "idle_off"
				this.loop = true
				this.ts = 0
				this.on_exo_finished = nil
			end
			S:queue("GUIMapStage5ForestBurn")
		else
			stage5_tree.exo_animation = "idle"
			stage5_tree.ts = 0
			stage5_light.exo_animation = "idle_off"
			stage5_light.ts = 0
		end
	end

	if completed(8) then
		local templars = exo("kr6_map_stage258_templars")
		local wall = exo("kr6_map_stage258_wall")

		if templars then
			templars.hidden = true
		end

		if wall then
			if new_level == 259 then
				wall.exo_animation = "run"
				wall.ts = 0
				wall.loop = false
				function wall.on_exo_finished(this)
					this.exo_animation = "idle_2"
					this.loop = true
					this.ts = 0
					this.on_exo_finished = nil
				end
				S:queue("GUIMapStage8FortressBreak")
			else
				wall.exo_animation = "idle_2"
				wall.ts = 0
			end
		end
	end

	local stage10_jt = exo("kr6_map_stage260_jt")

	if stage10_jt then
		stage10_jt.hidden = true
	end

	if completed(9) then
		local wall = exo("kr6_map_stage260_mountain_wall")

		if wall and stage10_jt then
			if new_level == 260 then
				wall.exo_animation = "run"
				wall.ts = 0
				wall.loop = false
				function wall.on_exo_finished(this)
					this.hidden = true
					stage10_jt.hidden = false
					this.on_exo_finished = nil
				end
			else
				wall.hidden = true
				stage10_jt.hidden = false
			end
		end
	end

	local stage11_spider = exo("kr6_map_stage261_spider")
	local stage11_eyes = exo("kr6_map_stage261_spider_eyes")

	if stage11_spider then
		stage11_spider.hidden = true
	end
	if stage11_eyes then
		stage11_eyes.hidden = true
	end

	if completed(10) then
		local wall = exo("kr6_map_stage261_mountain_wall")

		if wall and stage11_spider then
			if new_level == 261 then
				wall.exo_animation = "run"
				wall.ts = 0
				wall.loop = false
				function wall.on_exo_finished(this)
					this.hidden = true
					stage11_spider.hidden = false
					if stage11_eyes then
						stage11_eyes.hidden = false
					end
					this.on_exo_finished = nil
				end
			else
				wall.hidden = true
				stage11_spider.hidden = false
				if stage11_eyes then
					stage11_eyes.hidden = false
				end
			end
		end
	end

	local stage12_torches = exo("kr6_map_stage262_torches")

	if stage12_torches then
		stage12_torches.hidden = true
	end

	if completed(11) and levels[262] then
		local wall = exo("kr6_map_stage262_mountain_wall")

		if wall and stage12_torches then
			if new_level == 262 then
				wall.exo_animation = "run"
				wall.ts = 0
				wall.loop = false
				stage12_torches.hidden = false
				function wall.on_exo_finished(this)
					this.hidden = true
					this.on_exo_finished = nil
				end
				S:queue("GUIMapStage11RockBreak")
			else
				wall.hidden = true
				stage12_torches.hidden = false
				stage12_torches.exo_animation = "run"
				stage12_torches.ts = 0
			end
		end
	end

	local stage13_tower = exo("kr6_map_stage263_sunray_tower")

	if stage13_tower then
		stage13_tower.hidden = not completed(13)
	end

	if completed(15) then
		local swamp = exo("kr6_map_stage265_swamp")

		if swamp then
			if new_level == 266 then
				swamp.exo_animation = "start"
				swamp.ts = 0
				swamp.loop = false
				function swamp.on_exo_finished(this)
					this.exo_animation = "loop"
					this.loop = true
					this.ts = 0
					this.on_exo_finished = nil
				end
			else
				swamp.exo_animation = "loop"
				swamp.loop = true
			end
		end
	end

	local stage16_forest = exo("kr6_map_stage266_rotten_forest")

	if stage16_forest then
		stage16_forest.hidden = not completed(16)
		if completed(16) then
			if new_level == 267 then
				stage16_forest.exo_animation = "start"
				stage16_forest.ts = 0
				stage16_forest.loop = false
				function stage16_forest.on_exo_finished(this)
					this.exo_animation = "idle"
					this.loop = true
					this.ts = 0
					this.on_exo_finished = nil
				end
			else
				stage16_forest.exo_animation = "idle"
				stage16_forest.loop = true
				stage16_forest.ts = 0
			end
		end
	end

	if completed(18) then
		local stage18_tower = exo("kr6_map_stage268_tower")

		if stage18_tower then
			stage18_tower.exo_animation = "idle_2"
			stage18_tower.loop = true
			stage18_tower.ts = 0
		end
	end
end

function MapView:clear_flags()
	for _, f in pairs(self.flags) do
		self.flags_layer:remove_child(f)
	end

	for _, w in pairs(self.wings) do
		self.flags_layer:remove_child(w)
	end

	for _, pg in pairs(self.point_groups) do
		for _, p in pairs(pg) do
			p.parent:remove_child(p)
		end
	end

	for _, ld in pairs(self.level_decos) do
		ld.view.parent:remove_child(ld.view)
	end

	self.flags = {}
	self.wings = {}
	self.point_groups = {}
	self.level_decos = {}
end

function MapView:load_level_decos(num)
	local layers = {
		self.ma_under_layer,
		self.ma_mid_layer,
		self.ma_over_layer
	}
	local out = {}
	local decos = map_data["map_decos" .. num]

	for _, d in pairs(decos) do
		local v = KImageView:new(d.image)

		v.id = d.id
		v.pos = V.vclone(d.pos)
		v.anchor = d.anchor and V.vclone(d.anchor) or V.v(v.size.x / 2, v.size.y / 2)
		v.animations = d.animations
		v.loop = d.loop
		v.hidden = d.hidden
		v.hit_rect = d.hit_rect

		if d.fns then
			for fk, fn in pairs(d.fns) do
				v[fk] = fn
			end
		end

		layers[d.layer]:add_child(v)

		v.ctx = {
			screen_map = screen_map,
			timer = timer
		}

		if v.prepare then
			v.prepare(v)
		end

		if d.trigger_level then
			out[d.trigger_level] = {
				view = v
			}
		end

		if DEBUG_MAP_ANI_EDITOR then
			function v.on_click(this)
				screen_map.SEL_ANI = this

				log.debug("sel deco: %s", this.id)
			end
		end
	end

	return out
end

function MapView:show_flags(num)
	self.flags = {}
	self.wings = {}
	self.point_groups = {}
	self.level_decos = self:load_level_decos(num)

	local levels = screen_map.user_data.levels

	local max_level = GS.max_level3
	local jnum = GS.jnum3
	if num == 1 then
		max_level = GS.max_level1
		jnum = GS.jnum1
	elseif num == 2 then
		max_level = GS.max_level2
		jnum = GS.jnum2
	elseif num == 5 then
		max_level = GS.max_level5
		jnum = GS.jnum5
	elseif num == 4 then
		max_level = GS.max_level4
		jnum = GS.jnum4
	elseif num == 6 then
		max_level = GS.max_level6
		jnum = GS.jnum6
	end

	timer.script(function(wait)
		self.show_flags_in_progress = true

		local ud = screen_map.unlock_data
		local level_extra_list = {}
		for i = 1, max_level do
			local level = levels[map_data.level_rank(i,num)]
			local flag_skip = table.contains(level_extra_list, map_data.level_rank(i,num))
			if not level then
				-- block empty
			else
				local points_data = screen_map.map_points.points[i]
				local flag_pos = V.vclone(screen_map.map_points.flags[i].pos)
				local flag_y_offset = num == 6 and 40 or 0

				flag_pos.y = flag_pos.y - flag_y_offset

				if self.level_decos[i] and not table.contains(ud.unlocked_levels, map_data.level_rank(i,num)) then
					local v = self.level_decos[i].view

					v:unlock()
				end

				self.point_groups[i] = {}

				if i > 1 and points_data then
					for _, point_data in ipairs(points_data) do
						local texture_name = num == 6 and "kr6_map_flags_animation_path_dot_0010" or point_data.water and "flag_bullet_water_0010" or "flag_bullet_0010"
						local pointt = KImageView:new(texture_name)

						pointt.is_in_water = point_data.water
						pointt.is_kr6 = num == 6
						pointt.pos = point_data.pos

						local points_layer = num == 6 and i >= 16 and self.points_front_layer or self.points_layer
						points_layer:add_child(pointt)
						table.insert(self.point_groups[i], pointt)

						pointt.anchor = v(pointt.size.x / 2, pointt.size.y - 4)
						pointt.propagate_on_click = true

						if table.contains(ud.unlocked_levels, map_data.level_rank(i,num)) then
							pointt.hidden = true
						end
					end
				end

				local flag = LevelFlagView:new(i)

				
				flag:set_data(level, num)
				self.flags_layer:add_child(flag)

				self.flags[i] = flag
				flag.pos = flag_pos

				flag:set_mode("nostar")

				if table.contains(ud.unlocked_levels, map_data.level_rank(i,num)) then
					flag.hidden = true
				end
				

				if level[GAME_MODE_CAMPAIGN] and level.stars then
					if ud.show_stars_level ~= map_data.level_rank(i,num) or ud.star_count_before > 0 then
						flag:set_mode("campaign")
					end

					for j = 1, level.stars do
						local star = KImageView:new("mapFlag_star_0017")

						star.propagate_on_click = true

						flag:add_child(star)
						table.insert(flag.star_views, star)

						star.pos = flag.star_pos[j]

						if ud.show_stars_level == map_data.level_rank(i,num) and j > ud.star_count_before then
							star.hidden = true
						end
					end
				end

				if level[GAME_MODE_IRON] and ud.iron_level ~= map_data.level_rank(i,num) then
					flag:set_mode("iron")
				end

				local heroic_mode = num == 6 and GAME_MODE_BLITZ or GAME_MODE_HEROIC

				if level[heroic_mode] then
					local wing = KImageView:new("map_flag_heroic_0015")

					self.flags_layer:add_child(wing)

					self.wings[i] = wing

					wing:order_below(flag)

					wing.pos = v(flag_pos.x - 3, flag_pos.y)
					wing.anchor = v(wing.size.x / 2, wing.size.y / 2)
					wing.hidden = ud.heroic_level == map_data.level_rank(i,num)
				end

				for lid, f in pairs(screen_map.map_points.endless_flags) do
					if f.unlocks_at_level == i then
						local flag = EndlessLevelFlagView:new(lid)

						flag.pos = V.vclone(f.pos)
						self.flags[lid] = flag

						self.flags_layer:add_child(flag)

						if f.show_balloon and (DBG_SHOW_BALLOONS or not screen_map.user_data.seen[f.show_balloon]) then
							local t = KImageView:new_from_table(kui_db:get_table("screen_map_balloon_endless", {
								CJK = CJK
							}))

							t.pos = V.v(flag.pos.x, flag.pos.y - 40)

							self:add_child(t)

							screen_map.endlessTip = t
						end
					end
				end

			end
		end
		

		wait(1)

		while not screen_map.difficulty_view.hidden do
			wait(0.5)
		end

		for i = 1, max_level do
			local level = levels[map_data.level_rank(i,num)]
			local flag_skip = table.contains(level_extra_list, map_data.level_rank(i,num))

			if not level then
				-- block empty
			else
				local points_data = screen_map.map_points.points[i]
				--local flag_pos = screen_map.map_points.flags[i].pos
				local flag_pos = V.vclone(screen_map.map_points.flags[i].pos)
				local flag = self.flags[i]
				local wing = self.wings[i]

				if flag and ud.show_stars_level == map_data.level_rank(i,num) then
					flag:disable(false)

					local first_star = ud.star_count_before + 1

					for j = first_star, level.stars do
						flag.star_views[j].hidden = true
					end

					wait(0.5)

					if not level[GAME_MODE_IRON] then
						flag:set_mode("gotstar", true)
						wait(1)
						flag:set_mode("campaign")
					end

					for j = first_star, level.stars do
						local star = flag.star_views[j]

						star.hidden = false
						star.animation = {
							to = 17,
							prefix = "mapFlag_star",
							from = 1
						}
						star.ts = 0

						S:queue("GUIWinStars")
						wait(0.5)
					end

					flag:enable()
				end

				if flag and ud.iron_level == map_data.level_rank(i,num) then
					flag:disable(false)
					wait(0.5)
					S:queue("GUIWinStars")
					flag:set_mode("turnIron", true)
					wait(4)
					flag:set_mode("iron")
					flag:enable()
				end

				if wing and ud.heroic_level == map_data.level_rank(i,num) then
					flag:disable(false)

					wing.hidden = true

					wait(0.5)
					S:queue("GUIWinStars")

					wing.animation = {
						to = 15,
						prefix = "map_flag_heroic",
						from = 1
					}
					wing.ts = 0
					wing.hidden = false

					wait(2)
					flag:enable()
				end

				if self.level_decos[i] and table.contains(ud.unlocked_levels, map_data.level_rank(i,num)) then
					local v = self.level_decos[i].view

					v:unlock(wait)
				end

				local level_rank = map_data.level_rank(i, num)

				if i > 1 and (ud.new_level == level_rank or table.contains(ud.unlocked_levels, level_rank)) then
					S:queue("GuimapNewRoad")

					for _, pointt in ipairs(self.point_groups[i]) do
						pointt.hidden = false
						pointt.animation = {
							to = 10,
							from = 1,
							prefix = pointt.is_kr6 and "kr6_map_flags_animation_path_dot" or pointt.is_in_water and "flag_bullet_water" or "flag_bullet"
						}
						pointt.ts = 0

						wait(0.4)
					end
				end

				if table.contains(ud.unlocked_levels, map_data.level_rank(i,num)) then
					flag.hidden = false

					flag:disable(false)
					flag:set_mode("newFlag", true)
					S:queue("GUIMapNewFlah")
					wait(1)
					flag:set_mode("nostar")
					flag:enable()
				end
			end

		end
		

		self.show_flags_in_progress = nil

		local show_start_here = DBG_SHOW_BALLOONS or #screen_map.user_data.levels == 1

		if screen_map.kr4_map then
			show_start_here = show_start_here or screen_map_first_level_unfinished(4)
		elseif screen_map.kr5_map then
			show_start_here = show_start_here or screen_map_first_level_unfinished(5)
		elseif screen_map.kr6_map then
			show_start_here = show_start_here or screen_map_first_level_unfinished(6)
		end

		if show_start_here then
			local start_here = KImageView:new("mapBalloon_starthere_notxt")

			start_here.anchor = v(start_here.size.x / 2, start_here.size.y)

			local first_flag = screen_map.map_points.flags and screen_map.map_points.flags[1]

			if first_flag and first_flag.pos then
				start_here.pos = v(first_flag.pos.x, first_flag.pos.y - 30)
			elseif screen_map.kr1_map then
				start_here.pos = v(292, 775)
			elseif screen_map.kr2_map then
				start_here.pos = v(307, 280)
			else
				start_here.pos = v(194, 170)
			end

			screen_map.map_view:add_child(start_here)

			screen_map.map_view.start_here = start_here

			local l = GGLabel:new(V.v(164, 32))

			l.pos = v(8, 8)
			l.font_name = "body"
			l.font_size = 18
			l.text = _("START HERE!")
			l.text_align = "center"
			l.vertical_align = "middle"
			l.colors.text = {
				46,
				41,
				39,
				255
			}
			l.fit_lines = 1

			start_here:add_child(l)

			start_here.alpha = 0

			timer.tween(0.5, start_here, {
				alpha = 1
			}, "in-quad")
		end
	end)
end

function MapView:update(dt)
	MapView.super.update(self, dt)

	self.stime = self.stime + dt * 10

	if self.start_here then
		local pulse = math.sin(self.stime * 0.5) * 0.02 + 0.98

		self.start_here.scale = v(pulse, pulse)
	end

	if self.scrolling_dir == 0 then
		return
	end

	if self.scrolling_dir == 1 or  self.scrolling_dir == -1 then
		self.pos = v(self.pos.x + self.scrolling_dir * self.max_scroll_speed * dt, self.pos.y)
		self:clamp_zoom_position()
	end

	-- 处理 Y 轴滚动 (上下) - 新增逻辑
	if self.scrolling_dir == 2 or self.scrolling_dir == -2 then
		-- scrolling_dir = 2 (鼠标在顶部) -> 地图向下移动 (Y增加) 以显示顶部内容
		-- scrolling_dir = -2 (鼠标在底部) -> 地图向上移动 (Y减少) 以显示底部内容
		local dir_y = (self.scrolling_dir == 2) and 1 or -1
		self.pos = v(self.pos.x, self.pos.y + dir_y * self.max_scroll_speed * dt)
		self:clamp_zoom_position()
	end
end

MapView:include(KMDragInertia)

LevelFlagView = class("LevelFlagView", KImageView)

function LevelFlagView:initialize(level_num)
	KImageView.initialize(self, "map_flag_0181")

	self.star_pos = {
		v(12, 12),
		v(28, 12),
		v(43, 12)
	}
	self.star_views = {}
	self.anchor = v(self.size.x / 2, self.size.y / 2)
	self.mode = "default"
	self.animations = {}
	self.level_num = level_num
	self.button = KButton:new(V.v(self.size.x, self.size.y))

	self:add_child(self.button)

	self.button.hit_rect = V.r(20, 34, 44, 74)

	function self.button.on_click()
		S:queue("GUIButtonCommon")

		local popup_sw = IS_ANDROID and screen_map.android_unscaled_sw or screen_map.sw
		local popup_sh = IS_ANDROID and screen_map.android_unscaled_sh or screen_map.sh

		screen_map.level_select = configure_android_map_popup(LevelSelectView:new(popup_sw, popup_sh, self.level_num, self.stars, self.heroic, self.iron, self.slot_data))

		screen_map.window:add_child(screen_map.level_select)
		screen_map.level_select:show()
		self:disable(false)
		timer.after(0.5, function()
			self:enable()
		end)
	end

	function self.button.on_enter()
		S:queue("GUIQuickMenuOver")

		self.animation = nil

		if self.mode == "campaign" then
			self:set_image("map_flag_0181")
		elseif self.mode == "iron" then
			self:set_image("map_flag_0182")
		else
			self:set_image("map_flag_0180")
		end

		self.randomWait = -1
	end

	function self.button.on_exit()
		self:set_mode(self.mode, true)
	end

	self.animations = {
		gotstar = {
			to = 89,
			prefix = "map_flag",
			from = 65
		},
		campaign = {
			to = 134,
			prefix = "map_flag",
			from = 90
		},
		newFlag = {
			to = 24,
			prefix = "map_flag",
			from = 1
		},
		nostar = {
			to = 64,
			prefix = "map_flag",
			from = 24
		},
		iron = {
			to = 179,
			prefix = "map_flag",
			from = 160
		},
		turnIron = {
			to = 150,
			prefix = "map_flag",
			from = 135
		}
	}

	self:set_mode("campaign", false)
end

function LevelFlagView:set_data(data, generation)
	self.stars = data.stars or 0
	self.iron = data[GAME_MODE_IRON] and 1 or 0
	self.heroic = data[generation == 6 and GAME_MODE_BLITZ or GAME_MODE_HEROIC] and 1 or 0
	self.slot_data = data
end

function LevelFlagView:set_mode(mode, restart)
	self.mode = mode

	if self.animations[mode] then
		self.animation = self.animations[mode]

		if restart then
			self.ts = 0
		else
			self.ts = 1000000000
		end

		self.randomWait = love.math.random(3, 10)
	end
end

function LevelFlagView:update(dt)
	LevelFlagView.super.update(self, dt)

	if self.randomWait < 0 then
		return
	end

	self.randomWait = self.randomWait - dt

	if self.randomWait < 0 then
		self.randomWait = love.math.random(3, 10.1)
		self.ts = 0
	end
end

KRGLevelFlagView = class("KRGLevelFlagView", KImageView)

function KRGLevelFlagView:initialize(level_num)
	self.flag_prefix = level_num <= 8 and "kr6_map_flags_animation_stage_flag" or "kr6_map_flags_animation_stage_shadow_flag"
	KImageView.initialize(self, self.flag_prefix .. "_0001")

	self.star_pos = {
		v(27.5, 43.1),
		v(47.15, 42.65),
		v(65.3, 42)
	}
	self.star_views = {}
	self.anchor = v(43.95, 106.55)
	self.mode = "default"
	self.level_num = level_num
	self.button = KButton:new(V.v(88, 110))
	self.button.hit_rect = V.r(18, 38, 61, 66)
	self:add_child(self.button)

	function self.button.on_click()
		S:queue("GUIButtonCommon")

		local popup_sw = IS_ANDROID and screen_map.android_unscaled_sw or screen_map.sw
		local popup_sh = IS_ANDROID and screen_map.android_unscaled_sh or screen_map.sh

		screen_map.level_select = configure_android_map_popup(LevelSelectView:new(popup_sw, popup_sh, self.level_num, self.stars, self.heroic, self.iron, self.slot_data))
		screen_map.window:add_child(screen_map.level_select)
		screen_map.level_select:show()
		self:disable(false)
		timer.after(0.5, function()
			self:enable()
		end)
	end

	function self.button.on_enter()
		S:queue("GUIQuickMenuOver")
	end

	function self.button.on_exit()
		self:set_mode(self.mode, true)
	end

	self.animations = {
		newFlag = { from = 2, to = 25 },
		nostar = { from = 26, to = 73 },
		gotstar = { from = 74, to = 100 },
		campaign = { from = 101, to = 148 },
		turnIron = { from = 150, to = 195 },
		iron = { from = 221, to = 221 }
	}
	self:set_mode("campaign", false)
end

function KRGLevelFlagView:set_data(data)
	self.stars = data.stars or 0
	self.iron = data[GAME_MODE_IRON] and 1 or 0
	self.heroic = data[GAME_MODE_BLITZ] and 1 or 0
	self.slot_data = data
end

function KRGLevelFlagView:set_mode(mode, restart)
	self.mode = mode

	local frames = self.animations[mode]

	if frames then
		self.animation = {
			prefix = self.flag_prefix,
			from = frames.from,
			to = frames.to
		}
		self.ts = restart and 0 or 1000000000
		self.randomWait = (mode == "nostar" or mode == "campaign") and love.math.random(5, 20) or -1
	end
end

function KRGLevelFlagView:update(dt)
	KRGLevelFlagView.super.update(self, dt)

	if not self.randomWait or self.randomWait < 0 then
		return
	end

	self.randomWait = self.randomWait - dt

	if self.randomWait < 0 then
		self.randomWait = love.math.random(5, 20)
		self.ts = 0
	end
end

EndlessLevelFlagView = class("EndlessLevelFlagView", KImageButton)

function EndlessLevelFlagView:initialize(level_num)
	KImageButton.initialize(self, "mapFlag_endless_desktop_0001", "mapFlag_endless_desktop_0002", "mapFlag_endless_desktop_0002")

	self.anchor = v(self.size.x / 2, self.size.y / 2)
	self.level_num = level_num
end

function EndlessLevelFlagView:on_click()
	S:queue("GUIButtonCommon")

	if screen_map.endlessTip then
		screen_map.endlessTip.hidden = true
		screen_map.user_data.seen.map_balloon_endless_view = true

		storage:save_slot(screen_map.user_data)
	end

	local popup_sw = IS_ANDROID and screen_map.android_unscaled_sw or screen_map.sw
	local popup_sh = IS_ANDROID and screen_map.android_unscaled_sh or screen_map.sh

	screen_map.level_select = configure_android_map_popup(EndlessLevelSelectView:new(popup_sw, popup_sh, self.level_num, self.slot_data))

	screen_map.window:add_child(screen_map.level_select)
	screen_map.level_select:show()
	self:on_exit()
	self:disable(false)
	timer.after(0.5, function()
		self:enable()
	end)
end

StarsBanner = class("StarsBanner", KImageView)

function StarsBanner:initialize()
	KImageView.initialize(self, "mapStarsContainer")

	self.anchor = v(self.size.x / 2, 0)

	self:set_value(screen_map.total_stars, GS.max_stars)
end

function StarsBanner:set_value(got_value, of_value)
	local aux = tostring(got_value):reverse()
	local half_moved = self.size.x / 2 - 25
	local posx = half_moved - 5

	for digit in aux.gmatch(aux, "%d") do
		local digit_image

		if digit == "0" then
			digit_image = KImageView:new("mapStarsContainer_numbers_0010")
		else
			digit_image = KImageView:new("mapStarsContainer_numbers_000" .. digit)
		end

		digit_image.pos = v(posx - 20, self.size.y / 2)
		digit_image.anchor = v(digit_image.size.x / 2, digit_image.size.y / 2)

		self:add_child(digit_image)

		posx = posx - 20
	end

	local slash_image = KImageView:new("mapStarsContainer_numbers_0011")

	slash_image.anchor = v(slash_image.size.x / 2, slash_image.size.y / 2)
	slash_image.pos = v(half_moved, self.size.y / 2)

	self:add_child(slash_image)

	aux = tostring(of_value)

	local posx = half_moved + 5

	for digit in aux.gmatch(aux, "%d") do
		local digit_image

		if digit == "0" then
			digit_image = KImageView:new("mapStarsContainer_numbers_0010")
		else
			digit_image = KImageView:new("mapStarsContainer_numbers_000" .. digit)
		end

		digit_image.pos = v(posx + 20, self.size.y / 2)
		digit_image.anchor = v(digit_image.size.x / 2, digit_image.size.y / 2)

		self:add_child(digit_image)

		posx = posx + 20
	end
end

local ls_page_l_x = 214
local ls_page_r_x = 690
local ls_page_w = 360
local ls_page_y = 104
local ls_page_l_m = ls_page_l_x + ls_page_w / 2
local ls_page_r_m = ls_page_r_x + ls_page_w / 2

local function add_level_title(parent, text, style, y)
	local px, pm, py, fs, lines

	py = y or ls_page_y

	if style == "left" then
		px = ls_page_l_x
		pm = ls_page_l_m
		fs = CJK(36, nil, 34)
		lines = 2

		local words = string.split(text, " ")

		if #words == 1 then
			lines = 1
		end

		text = string.gsub(text, "-", " ")
	elseif style == "right" then
		px = ls_page_r_x
		pm = ls_page_r_m
		fs = 32
		lines = 1
	elseif style == "sub" then
		px = ls_page_r_x
		pm = ls_page_r_m
		fs = 26
		lines = 1
	end

	local title = GGLabel:new(V.v(ls_page_w - 120, lines * 40))

	title.pos = v(px + 60, py)
	title.anchor.y = title.size.y / 2
	title.font_name = "h_book"
	title.font_size = fs
	title.font_align = "center"
	title.vertical_align = "middle"
	title.colors.text = style == "sub" and {
		142,
		131,
		91,
		255
	} or {
		100,
		89,
		52,
		255
	}
	title.text = text
	title.line_height = CJK(0.9, 0.9, 1, 0.9)
	title.fit_lines = lines

	title:do_fit_lines()
	parent:add_child(title)

	local tw, wrn, wr = title:get_wrap_lines()
	local title_w = 0

	for i = 1, wrn do
		title_w = math.max(title_w, title:get_text_width(wr[i]))
	end

	local deco_y = py + 3
	local d
	local dn = "levelSelect_volutas_0001"

	d = KImageView:new(dn)
	d.pos = v(pm - title_w / 2 - 8, deco_y)
	d.anchor = v(0, d.size.y / 2)
	d.scale.x = -1
	d.alpha = style == "sub" and 0.5 or 1

	parent:add_child(d)

	d = KImageView:new(dn)
	d.pos = v(pm + title_w / 2 + 10, deco_y)
	d.anchor = v(0, d.size.y / 2)
	d.alpha = style == "sub" and 0.5 or 1

	parent:add_child(d)
end

local function add_levelid_title(parent, text, style, y)
	local px, pm, py, fs, lines

	py = y or ls_page_y

	if style == "left" then
		px = ls_page_l_x
		pm = ls_page_l_m
		fs = 32
		lines = 2

		local words = string.split(text, " ")

		if #words == 1 then
			lines = 1
		end

		--text = string.gsub(text, "-", " ")
	elseif style == "right" then
		px = ls_page_r_x
		pm = ls_page_r_m
		fs = 32
		lines = 1
	elseif style == "sub" then
		px = ls_page_r_x
		pm = ls_page_r_m
		fs = 26
		lines = 1
	end

	local title = GGLabel:new(V.v(ls_page_w - 120, lines * 40))

	title.pos = v(px + 60, py)
	title.anchor.y = title.size.y / 2
	title.font_name = "body_bold"
	title.font_size = fs
	title.font_align = "center"
	title.vertical_align = "middle"
	title.colors.text = style == "sub" and {
		142,
		131,
		91,
		255
	} or {
		100,
		89,
		52,
		255
	}
	title.text = text
	title.line_height = CJK(0.9, 0.9, 1, 0.9)
	title.fit_lines = lines

	title:do_fit_lines()
	parent:add_child(title)

	local tw, wrn, wr = title:get_wrap_lines()
	local title_w = 0

	for i = 1, wrn do
		title_w = math.max(title_w, title:get_text_width(wr[i]))
	end

	local deco_y = py + 3
	local d
	local dn = "levelSelect_volutas_0001"

	d = KImageView:new(dn)
	d.pos = v(pm - title_w / 2 - 8, deco_y)
	d.anchor = v(0, d.size.y / 2)
	d.scale.x = -1
	d.alpha = style == "sub" and 0.5 or 1

	parent:add_child(d)

	d = KImageView:new(dn)
	d.pos = v(pm + title_w / 2 + 10, deco_y)
	d.anchor = v(0, d.size.y / 2)
	d.alpha = style == "sub" and 0.5 or 1

	parent:add_child(d)
end

local function add_level_description(parent, text, max_y)
	local LEFT_MARGIN = ls_page_r_x + 10
	local FULL_PARAGRAPH_WIDTH = ls_page_w - 10
	local TEXT_TOP_POS = ls_page_y + 50 + CJK(0, 0, 0, -4)
	local RIGHT_PAGE_MAX_Y = max_y or 468
	local font_name = "body"
	local font_size = 17.5
	local line_height = CJK(0.85, 0.85, 1.1, 0.9)
	local bg = KImageView:new("levelSelect_capitular_bg")

	bg.pos = v(LEFT_MARGIN - 10, TEXT_TOP_POS - 30)

	parent:add_child(bg)

	local FIRST_PARAGRAPH_WIDTH = ls_page_w - bg.size.x
	local english = i18n.english_for and i18n.english_for(text)
	if english then
		local font = F:f(font_name, font_size)
		local function description_fits(value)
			local body = string.sub(value, utf8.offset(value, 2))
			local width, lines = font:getWrap(body, FIRST_PARAGRAPH_WIDTH)
			local first_lines = math.min(#lines, math.ceil((bg.pos.y + bg.size.y - TEXT_TOP_POS - 3) / (font:getHeight() * line_height)))
			local rest = {}
			for n = first_lines + 1, #lines do rest[#rest + 1] = string.trim(lines[n]) end
			local rest_width, rest_lines = font:getWrap(table.concat(rest, " "), FULL_PARAGRAPH_WIDTH)
			local rest_height = #rest > 0 and (1 + (#rest_lines - 1) * line_height) * font:getHeight() or 0
			return width <= FIRST_PARAGRAPH_WIDTH and rest_width <= FULL_PARAGRAPH_WIDTH and TEXT_TOP_POS + first_lines * font:getHeight() * line_height + rest_height <= RIGHT_PAGE_MAX_Y
		end
		if not description_fits(text) or (font.hasGlyphs and not font:hasGlyphs(text)) then text = english end
	end
	local p = string.sub(text, utf8.offset(text, 2))
	local first_letter_label = GGLabel:new(V.v(bg.size.x, bg.size.y))

	first_letter_label.pos = v(bg.pos.x + CJK(-4, 0, 0, 0), bg.pos.y + CJK(0, -4, -6, -6))
	first_letter_label.font_name = "capitals"
	first_letter_label.font_size = CJK(64, 56, 56, 56)
	first_letter_label.colors.text = {
		247,
		234,
		186
	}
	first_letter_label.text_align = "center"
	first_letter_label.vertical_align = "bottom"
	first_letter_label.text = string.sub(text, 1, utf8.offset(text, 2) - 1)

	parent:add_child(first_letter_label)

	local first_paragraph_1_label = GGLabel:new(V.v(FIRST_PARAGRAPH_WIDTH, 100))

	first_paragraph_1_label.pos = v(bg.pos.x + bg.size.x - 2, TEXT_TOP_POS)
	first_paragraph_1_label.font_name = font_name
	first_paragraph_1_label.font_size = font_size
	first_paragraph_1_label.line_height = line_height
	first_paragraph_1_label.colors.text = {
		64,
		57,
		36
	}
	first_paragraph_1_label.text_align = "left"
	first_paragraph_1_label.text = p

	parent:add_child(first_paragraph_1_label)

	local w, p_nlines, p_lines = first_paragraph_1_label:get_wrap_lines()
	local p_max_lines = math.ceil((bg.pos.y + bg.size.y - TEXT_TOP_POS - 3) / (first_paragraph_1_label:get_font_height() * line_height))
	local p_1_nlines = math.min(p_max_lines, #p_lines)

	for i = 1, #p_lines do
		p_lines[i] = string.trim(p_lines[i])
	end

	local p_1 = table.concat(p_lines, "\n", 1, p_1_nlines)
	local p_2 = table.concat(p_lines, CJK(" ", "", "", nil), p_1_nlines + 1)

	first_paragraph_1_label.text = p_1

	log.debug("Lines:\n%s", getdump(p_lines))
	log.debug("p_1_nlines:%i", p_1_nlines)

	local p2_pos = v(LEFT_MARGIN, first_paragraph_1_label.pos.y + first_paragraph_1_label:get_font_height() * p_1_nlines * line_height)
	local first_paragraph_2_label = GGLabel:new(V.v(FULL_PARAGRAPH_WIDTH, RIGHT_PAGE_MAX_Y - p2_pos.y))

	first_paragraph_2_label.pos = p2_pos
	first_paragraph_2_label.fit_size = true
	first_paragraph_2_label.font_name = font_name
	first_paragraph_2_label.font_size = font_size
	first_paragraph_2_label.line_height = line_height
	first_paragraph_2_label.colors.text = {
		64,
		57,
		36
	}
	first_paragraph_2_label.text_align = "left"

	parent:add_child(first_paragraph_2_label)

	first_paragraph_2_label.text = p_2
end

local function add_difficulty_stamp(parent, mode, diff, x, y)
	if diff then
		local im = KImageView:new("levelSelect_difficultyCompleted_000" .. diff)

		im.pos = v(x, y)

		parent:add_child(im)
	end
end

local function add_level_battle_button(parent, mode, level_num)
	local c1 = {
		0.9529411764705882,
		0.7764705882352941,
		0.596078431372549,
		1
	}
	local c3 = {
		0.6862745098039216,
		0.5372549019607843,
		0.38823529411764707,
		1
	}
	local co = {
		0.37254901960784315,
		0.023529411764705882,
		0.050980392156862744,
		1
	}
	local sh = {
		"p_bands",
		"p_outline",
		"p_glow"
	}
	local sha = {
		{
			margin = 0,
			p1 = 0,
			p2 = 0.4,
			c1 = c1,
			c2 = c1,
			c3 = c3
		},
		{
			thickness = 2.5,
			outline_color = co
		},
		{
			thickness = 1.6,
			glow_color = {
				0,
				0,
				0,
				0.6
			}
		}
	}
	local c1_hover = {
		1,
		1,
		1,
		1
	}
	local c3_hover = {
		1,
		1,
		0.6941176470588235,
		1
	}
	local co_hover = {
		0.807843137254902,
		0.13725490196078433,
		0.08627450980392157,
		1
	}
	local sha_hover = {
		{
			margin = 0,
			p1 = 0,
			p2 = 0.4,
			c1 = c1_hover,
			c2 = c1_hover,
			c3 = c3_hover
		},
		{
			thickness = 2.5,
			outline_color = co_hover
		},
		{
			thickness = 1.6,
			glow_color = {
				c3[1],
				c3[2],
				c3[3],
				0.6
			}
		}
	}
	local prefix = "levelSelect_startMode_notxt_000%i"
	local nu = string.format(prefix, 2 * mode - 1)
	local nh = string.format(prefix, 2 * mode)
	local b = KImageButton:new(nu, nh, nh)

	b.pos = v(805, 470)

	parent:add_child(b)

	function b.on_click()
		S:queue("GUIButtonCommon")
		screen_map:start_level(level_num, mode)
	end

	function b.on_enter(this)
		this.class.on_enter(this)

		this.t1.shader_args = sha_hover
		this.t2.shader_args = sha_hover

		this.t1:redraw()
		this.t2:redraw()
	end

	function b.on_exit(this)
		this.class.on_exit(this)

		this.t1.shader_args = sha
		this.t2.shader_args = sha

		this.t1:redraw()
		this.t2:redraw()
	end

	local t = GGShaderLabel:new(V.v(b.size.x, 20))

	t.pos.y = 70
	t.font_size = 15
	t.font_name = "h_noti"
	t.text_align = "center"
	t.text = _("BUTTON_TO_BATTLE_1")
	t.colors.text = {
		255,
		255,
		255,
		255
	}
	t.shaders = sh
	t.shader_args = sha
	t.propagate_on_click = true

	b:add_child(t)

	b.t1 = t
	t = GGShaderLabel:new(V.v(b.size.x, 30))
	t.pos.y = 86
	t.font_size = 22
	t.font_name = "h_noti"
	t.text_align = "center"
	t.text = _("BUTTON_TO_BATTLE_2")
	t.colors.text = {
		255,
		255,
		255,
		255
	}
	t.shaders = sh
	t.shader_args = sha
	t.propagate_on_click = true

	b:add_child(t)

	b.t2 = t
end

local function add_level_rules(parent, level_num, y)
	local level_data = screen_map.level_data[level_num]
	local has_hero = level_data.upgrades.heroe
	local upg_desc = _("UPGRADE_LEVEL") .. "\n" .. tostring(level_data.upgrades.level)
	local upg_icon = KImageView:new("levelSelect_modeRules_0010")

	upg_icon.pos = v(ls_page_r_x + 20, y)

	parent:add_child(upg_icon)

	local upg_label = GGLabel:new(V.v(90, upg_icon.size.y))

	upg_label.pos = v(upg_icon.pos.x + upg_icon.size.x, upg_icon.pos.y + upg_icon.size.y / 2)
	upg_label.anchor.y = upg_label.size.y / 2
	upg_label.font_name = "body"
	upg_label.font_size = 11
	upg_label.text_align = "center"
	upg_label.vertical_align = "middle"
	upg_label.text = upg_desc
	upg_label.colors.text = {
		64,
		57,
		36
	}

	parent:add_child(upg_label)

	local hero_icon = KImageView:new(has_hero and "levelSelect_modeRules_0011" or "levelSelect_modeRules_00009")

	hero_icon.pos = v(ls_page_r_x + ls_page_w / 2 + 20, y)

	parent:add_child(hero_icon)

	local hero_label = GGLabel:new(V.v(90, hero_icon.size.y))

	hero_label.pos = v(hero_icon.pos.x + hero_icon.size.x, hero_icon.pos.y + hero_icon.size.y / 2)
	hero_label.anchor.y = hero_label.size.y / 2
	hero_label.font_name = "body"
	hero_label.font_size = 11
	hero_label.text_align = "center"
	hero_label.vertical_align = "middle"
	hero_label.text = has_hero and _("HEROES") or _("NO HEROES")
	hero_label.colors.text = {
		64,
		57,
		36
	}

	parent:add_child(hero_label)
end

local function add_level_tab(parent, mode, y, stars)
	local x = 1105
	local fmt = "levelSelect_Mode_notxt_00%02i"
	local indexes = {
		[GAME_MODE_CAMPAIGN] = {
			nil,
			1,
			2,
			3
		},
		[GAME_MODE_HEROIC] = {
			4,
			5,
			6,
			7
		},
		[GAME_MODE_IRON] = {
			8,
			9,
			10,
			11
		}
	}
	local i_l, i_n, i_h, i_s = unpack(indexes[mode])
	local texts = {
		_("Campaign"),
		_("Heroic"),
		_("Iron")
	}

	if not parent.tabs_locked then
		parent.tabs_locked = {}
	end

	if not parent.tabs then
		parent.tabs = {}
	end

	if not parent.tabs_selected then
		parent.tabs_selected = {}
	end

	local oy = (mode ~= GAME_MODE_CAMPAIGN and -2 or 0) + CJK(0, -4, 3, 0)
	local ox = mode ~= GAME_MODE_CAMPAIGN and 0 or 0
	local lx = 40
	local ly = 56
	local lx_sel = 53

	if i_l and stars < 3 then
		local t = KImageView:new(string.format(fmt, i_l))

		t.pos = v(x, y)

		function t.on_enter()
			local msg = mode == GAME_MODE_HEROIC and _("Heroic challenge") or _("Iron challenge")

			parent:show_tooltip(msg)
		end

		function t.on_exit()
			parent:hide_tooltip()
		end

		parent.back:add_child(t)

		parent.tabs_locked[mode] = t

		local l = GGLabel:new(V.v(68, 10))

		l.anchor = v(l.size.x / 2, l.size.y / 2)
		l.font_name = CJK("body", nil, nil, "h_noti")
		l.font_size = 13
		l.font_align = "center"
		l.pos = v(lx + ox, ly + oy)
		l.colors.text = {
			198,
			134,
			95,
			255
		}
		l.text = texts[mode]
		l.propagate_on_click = true
		l.fit_lines = 1

		t:add_child(l)
	else
		if i_n then
			local l = GGLabel:new(V.v(68, 10))

			l.anchor = v(l.size.x / 2, l.size.y / 2)
			l.font_name = CJK("body", nil, nil, "h_noti")
			l.font_size = 13
			l.font_align = "center"
			l.pos = v(lx + ox, ly + oy)
			l.colors.text = {
				198,
				134,
				95,
				255
			}
			l.text = texts[mode]
			l.propagate_on_click = true
			l.fit_lines = 1

			local t = KImageButton:new(string.format(fmt, i_n), string.format(fmt, i_h))

			t.pos = v(x, y)

			function t.on_click(this)
				S:queue("GUIButtonCommon")
				parent:show_page(mode, stars)
			end

			function t.on_enter(this)
				S:queue("GUIQuickMenuOver")

				l.colors.text = {
					95,
					59,
					38,
					255
				}

				this.class.on_enter(this)
			end

			function t.on_exit(this)
				l.colors.text = {
					198,
					134,
					95,
					255
				}

				this.class.on_exit(this)
			end

			t:add_child(l)
			parent.back:add_child(t)

			parent.tabs[mode] = t
		end

		if i_s then
			local l = GGLabel:new(V.v(68, 10))

			l.anchor = v(l.size.x / 2, l.size.y / 2)
			l.font_name = CJK("body", nil, nil, "h_noti")
			l.font_size = 13
			l.font_align = "center"
			l.pos = v(lx_sel + ox, ly + oy)
			l.colors.text = {
				142,
				213,
				246,
				255
			}
			l.text = texts[mode]
			l.propagate_on_click = true
			l.fit_lines = 1

			local t = KImageView:new(string.format(fmt, i_s))

			t.pos = v(x, y)

			t:add_child(l)
			parent.back:add_child(t)

			parent.tabs_selected[mode] = t
		end
	end
end

LevelSelectDifficultyButton = class("LevelSelectDifficultyButton", KImageButton)

function LevelSelectDifficultyButton:initialize()
	KImageButton.initialize(self, "levelSelect_difficulty_0001")

	local diff = screen_map.user_data.difficulty or DIFFICULTY_NORMAL

	self:set_difficulty(diff)
end

function LevelSelectDifficultyButton:on_click()
	S:queue("GUIButtonCommon")

	-- local campaign_done = #screen_map.user_data.levels > GS.main_campaign_levels
	local campaign_done = #screen_map.user_data.levels >= 1
	local diff = screen_map.user_data.difficulty

	diff = km.zmod(diff + 1, campaign_done and GS.max_difficulty or 3)
	screen_map.user_data.difficulty = diff

	storage:save_slot(screen_map.user_data)
	self:set_difficulty(diff)
	self:set_image(self.hover_image_name)
end

function LevelSelectDifficultyButton:set_difficulty(diff)
	local fmt = "levelSelect_difficulty_000%i"
	local img_n = string.format(fmt, 2 * diff - 1)
	local img_h = string.format(fmt, 2 * diff)

	self.default_image_name = img_n
	self.hover_image_name = img_h
	self.click_image_name = img_h

	self:set_image(self.default_image_name)

	self.difficulty = diff
end

function LevelSelectDifficultyButton:update(dt)
	local diff = screen_map.user_data.difficulty

	if diff ~= self.difficulty then
		self:set_difficulty(diff)
	end

	LevelSelectDifficultyButton.super.update(self, dt)
end

local level_select_campaign_variants = {
	CAMPAIGN_VARIANT_REGULAR,
	CAMPAIGN_VARIANT_SPELL_RAID,
	CAMPAIGN_VARIANT_HERO_RALLY,
	CAMPAIGN_VARIANT_NOSTALGIC_CLASSIC
}

local level_select_campaign_variant_labels = {
	[CAMPAIGN_VARIANT_REGULAR] = CJK("Campaign", "Campaign", "キャンペーン", "캠페인"),
	[CAMPAIGN_VARIANT_SPELL_RAID] = CJK("Spell Raid", "Đột kích phép", "スペル強襲", "주문 습격"),
	[CAMPAIGN_VARIANT_HERO_RALLY] = CJK("Hero Rally", "Hội quân anh hùng", "英雄集結", "영웅 집결"),
	[CAMPAIGN_VARIANT_NOSTALGIC_CLASSIC] = CJK("Nostalgic", "Cổ điển", "懐旧クラシック", "향수 클래식")
}

local function level_select_kr6_campaign_mode(variant)
	if variant == CAMPAIGN_VARIANT_SPELL_RAID then
		return GAME_MODE_NO_HEROES
	elseif variant == CAMPAIGN_VARIANT_HERO_RALLY then
		return GAME_MODE_EXTRA_HEROES
	elseif variant == CAMPAIGN_VARIANT_NOSTALGIC_CLASSIC then
		return GAME_MODE_KR1
	end

	return GAME_MODE_CAMPAIGN
end

LevelSelectView = class("LevelSelectView", PopUpView)

function LevelSelectView:update_campaign_variant_button()
	local variant = screen_map.user_data.campaign_variant

	if not level_select_campaign_variant_labels[variant] then
		variant = CAMPAIGN_VARIANT_REGULAR
		screen_map.user_data.campaign_variant = variant
	end

	self.campaign_variant_button.label.text = level_select_campaign_variant_labels[variant]
	self.campaign_variant_button.label.fit_lines = 1

	if self.campaign_completion_stamp then
		local mode = self.local_generation == 6 and level_select_kr6_campaign_mode(variant) or GAME_MODE_CAMPAIGN
		local difficulty = self.slot_data[mode]

		self.campaign_completion_stamp.hidden = not difficulty

		if difficulty then
			self.campaign_completion_stamp:set_image("levelSelect_difficultyCompleted_000" .. difficulty)
		end
	end
end

function LevelSelectView:initialize(sw, sh, level_num, stars, heroic, iron, slot_data)
	PopUpView.initialize(self, V.v(sw, sh))
	local local_generation = 3

	local local_level_num = level_num
	if screen_map.kr1_map then
		level_num = level_num + 44
		local_generation = 1
	elseif screen_map.kr2_map then
		if level_num <= 22 then
			level_num = level_num + 22
		elseif level_num <= 26 then
			level_num = level_num + 54
		else
			level_num = level_num + 60
		end
		local_generation = 2
	elseif screen_map.kr5_map then
		level_num = level_num + 100
		local_generation = 5
	elseif screen_map.kr4_map then
		local_level_num = level_num - 1
		level_num = local_level_num + 150
		local_generation = 4
		if local_level_num >= 43 then
			local_level_num = local_level_num - 1
		end
	elseif screen_map.kr6_map then
		level_num = level_num + 250
		local_generation = 6
	else--if screen_map.kr3_map then
		if level_num >= 23 then
			level_num = 86
		end
		local_generation = 3
	end
	local level_string = string.format("%02i", level_num)
	local level_data = screen_map.level_data[level_num]

	self.local_generation = local_generation
	self.slot_data = slot_data

	self.back = KImageView:new("levelSelect_background")
	self.back.anchor = v(self.back.size.x / 2, self.back.size.y / 2)
	self.back.pos = v(sw / 2 - 15, sh / 2 - 50)

	self:add_child(self.back)

	self.back.alpha = 0

	local close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")

	close_button.pos = v(self.back.size.x - 50, 20)
	self.close_button = close_button

	self.back:add_child(close_button)

	function close_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end

	if local_generation == 4 and local_level_num == 16 then
		add_levelid_title(self.back, string.format("%d-%s", local_generation,"16A" or 0), "left", ls_page_y)
	elseif local_generation == 4 and level_num == 192 then
		add_levelid_title(self.back, string.format("%d-%s", local_generation,"16B" or 0), "left", ls_page_y)
	else
		add_levelid_title(self.back, string.format("%d-%d", local_generation,local_level_num or 0), "left", ls_page_y)
	end

	add_level_title(self.back, _(string.format("LEVEL_%d_TITLE", level_num or 0)), "left", ls_page_y+46)
	--add_level_title(self.back, _(string.format("LEVEL_%d_TITLE", level_num)), "left", ls_page_y+22)

	--[[
	local levelidtitle = GGLabel:new(V.v(ls_page_w - 120, 6))

	levelidtitle.pos = v(ls_page_l_x + 60, ls_page_y + 10)
	levelidtitle.anchor.y = levelidtitle.size.y / 2
	levelidtitle.font_name = "body_bold"
	levelidtitle.font_size = 30
	levelidtitle.font_align = "center"
	levelidtitle.vertical_align = "middle"
	levelidtitle.colors.text = style == "sub" and {
		142,
		131,
		91,
		255
	} or {
		100,
		89,
		52,
		255
	}
	levelidtitle.text = string.format("%d-%d", local_generation,local_level_num)
	levelidtitle.line_height = CJK(0.9, 0.9, 1, 0.9)
	levelidtitle.fit_lines = 40

	levelidtitle:do_fit_lines()
	self.back:add_child(levelidtitle)
	]]

	local stage_thumb = KImageView:new(string.len(level_string) == 2 and "stage_thumbs_00" .. level_string or "stage_thumbs_0"..level_string)

	stage_thumb.pos = v(215, 190)

	self.back:add_child(stage_thumb)

	local thumb_frame = KImageView:new("levelSelect_thumbFrame")

	thumb_frame.pos = v(202, 175)

	self.back:add_child(thumb_frame)

	local badge_x = local_generation == 6 and 258 or 310
	local badge_x_off = 35
	local badge_y = 490
	local badge_fmt = "levelSelect_badges_000%i"

	if local_generation == 6 then
		local badges = {
			{"star", stars >= 1},
			{"star", stars >= 2},
			{"star", stars >= 3},
			{"iron", slot_data[GAME_MODE_IRON] ~= nil},
			{"blitz", slot_data[GAME_MODE_BLITZ] ~= nil},
			{"spells", slot_data[GAME_MODE_NO_HEROES] ~= nil},
			{"heroes", slot_data[GAME_MODE_EXTRA_HEROES] ~= nil},
			{"classic", slot_data[GAME_MODE_KR1] ~= nil}
		}

		for _, badge in ipairs(badges) do
			local state = badge[2] and "on" or "off"
			local b = KImageView:new(string.format("kr6_level_select_badge_%s_%s", badge[1], state))

			b.scale = v(0.8, 0.8)
			b.pos = v(badge_x, badge_y)
			badge_x = badge_x + badge_x_off

			self.back:add_child(b)
		end
	else
		for i = 1, 5 do
			local n

			if i == 5 then
				n = iron > 0 and 5 or 6
			elseif i == 4 then
				n = heroic > 0 and 3 or 4
			else
				n = i <= stars and 1 or 2
			end

			local bn = string.format(badge_fmt, n)
			local b = KImageView:new(bn)

			b.scale = v(0.8, 0.8)
			b.pos = v(badge_x, badge_y)
			badge_x = badge_x + badge_x_off

			self.back:add_child(b)
		end
	end

	self.campaign = KView:new()

	self.back:add_child(self.campaign)
	add_level_title(self.campaign, _("Campaign"), "right")

	local desc_h = add_level_description(self.campaign, _("LEVEL_" .. tostring(level_num) .. "_HISTORY"), 390)

	local variant_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	variant_button.anchor = v(math.floor(variant_button.size.x / 2), variant_button.size.y / 2)
	variant_button.pos = v(ls_page_r_m, 426)
	variant_button.scale = v(0.9, 0.9)
	variant_button.label.size = v(110, 34)
	variant_button.label.text_size = variant_button.label.size
	variant_button.label.pos = v(16, 19)
	variant_button.label.font_name = "body_bold"
	variant_button.label.font_size = 22
	variant_button.label.vertical_align = "middle"
	variant_button.label.fit_lines = 1

	function variant_button.on_click()
		local current = screen_map.user_data.campaign_variant or CAMPAIGN_VARIANT_REGULAR
		local next_index = 1

		for i, variant in ipairs(level_select_campaign_variants) do
			if variant == current then
				next_index = i % #level_select_campaign_variants + 1
				break
			end
		end

		screen_map.user_data.campaign_variant = level_select_campaign_variants[next_index]
		storage:save_slot(screen_map.user_data)
		self:update_campaign_variant_button()
		S:queue("GUIButtonCommon")
	end

	self.campaign:add_child(variant_button)
	self.campaign_variant_button = variant_button
	self.campaign_completion_stamp = KImageView:new("levelSelect_difficultyCompleted_0001")
	self.campaign_completion_stamp.pos = v(690, 520)
	self.campaign:add_child(self.campaign_completion_stamp)
	self:update_campaign_variant_button()

	local b = LevelSelectDifficultyButton:new()

	b.pos = v(982, 522)

	self.campaign:add_child(b)
	add_level_battle_button(self.campaign, GAME_MODE_CAMPAIGN, level_num)
	add_level_tab(self, GAME_MODE_CAMPAIGN, 175, stars)

	if level_num ~= 116 and level_num ~= 80 and level_num ~= 166 then
		local rules_y = 290

		self.heroic = KView:new()

		self.back:add_child(self.heroic)

		self.heroic.hidden = true

		local rbg = KImageView:new("levelSelect_modebg_notxt_0001")

		rbg.pos = v(ls_page_r_x + (ls_page_w - rbg.size.x) / 2, rules_y + 20)

		self.heroic:add_child(rbg)
		add_level_title(self.heroic, _("Heroic"), "right")

		local desc_h = add_level_description(self.heroic, _("LEVEL_MODE_HEROIC_DESCRIPTION"))

		add_level_title(self.heroic, _("Challenge Rules"), "sub", rules_y)
		add_level_rules(self.heroic, level_num, rules_y + 38)
		local heroic_completion_mode = local_generation == 6 and GAME_MODE_BLITZ or GAME_MODE_HEROIC

		add_difficulty_stamp(self.heroic, heroic_completion_mode, slot_data[heroic_completion_mode], 690, 520)

		local b = LevelSelectDifficultyButton:new()

		b.pos = v(982, 522)

		self.heroic:add_child(b)
		add_level_battle_button(self.heroic, GAME_MODE_HEROIC, level_num)
		add_level_tab(self, GAME_MODE_HEROIC, 260, stars)

		local rules_y = 290

		self.iron = KView:new()

		self.back:add_child(self.iron)

		self.iron.hidden = true

		local rbg = KImageView:new("levelSelect_modebg_notxt_0001")

		rbg.pos = v(ls_page_r_x + (ls_page_w - rbg.size.x) / 2, rules_y + 20)

		self.iron:add_child(rbg)

		local rbbg = KImageView:new("levelSelect_modebg_notxt_0002")

		rbbg.pos = v(ls_page_r_x + (ls_page_w - rbbg.size.x) / 2, rules_y + 90)

		self.iron:add_child(rbbg)
		add_level_title(self.iron, _("Iron"), "right")

		local desc_h = add_level_description(self.iron, _("LEVEL_MODE_IRON_DESCRIPTION"))

		add_level_title(self.iron, _("Challenge Rules"), "sub", rules_y)
		add_level_rules(self.iron, level_num, rules_y + 38)

		local b_x = 770
		local b_y = rbbg.pos.y + 10
		local b_o = 50
		local allowed_towers = screen_map.level_data[level_num].iron
		local opts = {
			"archers",
			"barracks",
			"mages",
			"druids",
			"artillery"
		}

		for i, v in ipairs(opts) do
			local n = table.contains(allowed_towers, v) and 2 * i or 2 * i - 1
			local b = KImageView:new(string.format("levelSelect_modeRules_000%i", n))

			b.pos = V.v(b_x, b_y)
			b_x = b_x + b_o

			self.iron:add_child(b)
		end

		add_difficulty_stamp(self.iron, GAME_MODE_IRON, slot_data[GAME_MODE_IRON], 690, 520)

		local b = LevelSelectDifficultyButton:new()

		b.pos = v(982, 522)

		self.iron:add_child(b)
		add_level_battle_button(self.iron, GAME_MODE_IRON, level_num)
		add_level_tab(self, GAME_MODE_IRON, 345, stars)
	end


	self:show_page(GAME_MODE_CAMPAIGN, stars)

	local name_label = GGLabel:new(V.v(280, 18))

	name_label.pos = v(10, 10)
	name_label.font_name = "body"
	name_label.font_size = 18
	name_label.colors.text = {
		255,
		255,
		255
	}
	name_label.text = _("Heroic")
	name_label.text_align = "left"

	local desc_label = GGLabel:new(V.v(280, 18))

	desc_label.pos = v(10, name_label.pos.y + name_label.size.y + 5)
	desc_label.font_name = "body"
	desc_label.font_size = 18
	desc_label.colors.text = {
		245,
		203,
		6
	}
	desc_label.text_align = "left"
	desc_label.text = _("LEVEL_MODE_LOCKED_DESCRIPTION")
	desc_label.line_height = 0.9

	local w, lines = desc_label:get_wrap_lines()
	local panel_h = desc_label.pos.y + lines * desc_label:get_font_height() * desc_label.line_height + 10

	self.tip_panel = KView:new(V.v(300, panel_h))
	self.tip_panel.colors.background = {
		21,
		17,
		13,
		255
	}
	self.tip_panel.alpha = 0.9

	self:add_child(self.tip_panel)

	self.tip_panel.title = name_label

	self.tip_panel:add_child(name_label)

	self.tip_panel.desc = desc_label

	self.tip_panel:add_child(desc_label)

	local tip_panel_tip = KImageView:new("Upgrades_Tips_tip")

	tip_panel_tip.pos = v(self.tip_panel.size.x + 10, self.tip_panel.size.y - 20)
	tip_panel_tip.scale = v(-1, 1)
	tip_panel_tip.propagate_on_click = true

	self.tip_panel:add_child(tip_panel_tip)

	self.tip_panel.tip = tip_panel_tip
	self.tip_panel.anchor = v(self.tip_panel.size.x + 15, self.tip_panel.size.y + 20)
	self.tip_panel.hidden = true
end

function LevelSelectView:show_three_star_required()
	if self.three_star_dialog then
		return
	end

	local overlay = KView:new(V.v(self.back.size.x, self.back.size.y))

	overlay.colors.background = {0, 0, 0, 110}
	self.back:add_child(overlay)
	self.three_star_dialog = overlay

	local function dismiss()
		self.back:remove_child(overlay)
		self.three_star_dialog = nil
	end

	function overlay.on_click()
		dismiss()
	end

	local frame = KView:new(V.v(760, 220))

	frame.pos = v((self.back.size.x - frame.size.x) / 2, (self.back.size.y - frame.size.y) / 2)
	frame.colors.background = {89, 61, 34, 255}
	frame.on_click = function() end
	overlay:add_child(frame)

	local card = KView:new(V.v(frame.size.x - 10, frame.size.y - 10))

	card.pos = v(5, 5)
	card.colors.background = {250, 232, 166, 255}
	card.on_click = function() end
	frame:add_child(card)

	local message = GGLabel:new(V.v(card.size.x - 60, 80))

	message.pos = v(30, 38)
	message.font_name = "body"
	message.font_size = 28
	message.colors.text = {64, 57, 36, 255}
	message.text = "Đạt 3 sao ở màn này để mở các chế độ khác."
	message.text_align = "center"
	message.vertical_align = "middle"
	message.fit_lines = 2
	card:add_child(message)

	local confirm = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	confirm.pos = v(card.size.x / 2, 165)
	confirm.label.text = CJK("OK", "Đồng ý", "確認", "확인")
	confirm.label.font_name = "body_bold"
	confirm.label.font_size = 22
	confirm.label.fit_lines = 1
	confirm.label.vertical_align = "middle"
	confirm.label.pos = v(0, 0)

	function confirm.on_click()
		S:queue("GUIButtonCommon")
		dismiss()
	end

	card:add_child(confirm)
end

function LevelSelectView:show_tooltip(title)
	self.tip_panel.hidden = false
	self.tip_panel.title.text = title

	self:update_tooltip_position()
end

function LevelSelectView:hide_tooltip()
	self.tip_panel.hidden = true
end

function LevelSelectView:update_tooltip_position()
	if not self.tip_panel.hidden then
		local mx, my = screen_map.window:get_mouse_position()

		self.tip_panel.pos = v(mx / screen_map.window.scale.x, my / screen_map.window.scale.y)
	end
end

function LevelSelectView:update(dt)
	LevelSelectView.super.update(self, dt)
	self:update_tooltip_position()
end

function LevelSelectView:show_page(page, stars)
	self.campaign.hidden = page ~= GAME_MODE_CAMPAIGN
	if self.heroic then
		self.heroic.hidden = page ~= GAME_MODE_HEROIC
	end
	if self.iron then
		self.iron.hidden = page ~= GAME_MODE_IRON
	end
	for _, m in pairs({
		GAME_MODE_CAMPAIGN,
		GAME_MODE_HEROIC,
		GAME_MODE_IRON
	}) do
		if self.tabs[m] then
			self.tabs[m].hidden = page == m
		end

		if self.tabs_selected[m] then
			self.tabs_selected[m].hidden = page ~= m
		end
	end
end

EndlessLevelSelectView = class("EndlessLevelSelectView", PopUpView)

function EndlessLevelSelectView:initialize(sw, sh, level_num, slot_data)
	PopUpView.initialize(self, V.v(sw, sh))

	self.level_idx = level_num

	local level_string = string.format("%02i", level_num)
	local level_data = screen_map.level_data[level_num]

	self.back = KImageView:new("levelSelect_background")
	self.back.anchor = v(self.back.size.x / 2, self.back.size.y / 2)
	self.back.pos = v(sw / 2 - 15, sh / 2 - 50)

	self:add_child(self.back)

	self.back.alpha = 0

	local close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")

	close_button.pos = v(self.back.size.x - 50, 20)
	self.close_button = close_button

	self.back:add_child(close_button)

	function close_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end

	add_level_title(self.back, _(string.format("ENDLESS_LEVEL_%d_TITLE", level_num - 80)), "left", ls_page_y + 22)

	local stage_thumb = KImageView:new("stage_thumbs_endless_00" .. level_string)

	stage_thumb.pos = v(215, 190)

	self.back:add_child(stage_thumb)

	local thumb_frame = KImageView:new("levelSelect_thumbFrame")

	thumb_frame.pos = v(202, 175)

	self.back:add_child(thumb_frame)

	local bp = KImageView:new("levelSelect_bg_patch")

	bp.scale = v(21, 6)
	bp.pos = v(290, 475)

	self.back:add_child(bp)

	local w = KImageView:new("levelSelect_waves")

	w.anchor = v(w.size.x / 2, w.size.y / 2)
	w.pos = v(290, 485)

	self.back:add_child(w)

	local wl = GGLabel:new(v(30, 24))

	wl.pos = v(29, 29)
	wl.vertical_align = "middle"
	wl.font_name = "body"
	wl.font_size = 20
	wl.fit_size = true
	wl.colors.text = {
		64,
		57,
		36
	}
	wl.colors.background = {
		0,
		0,
		0,
		0
	}
	wl.text = "99"

	w:add_child(wl)

	self.waves_label = wl

	local wd = GGLabel:new(V.v(100, 40))

	wd.text = _("ENDLESS_LEVEL_SELECT_SURVIVED")
	wd.pos = v(w.pos.x, w.pos.y + 55)
	wd.anchor = v(wd.size.x / 2, wd.size.y / 2)
	wd.font_name = "body"
	wd.font_size = 16
	wd.text_align = "center"
	wd.vertical_align = "top"
	wd.colors.text = {
		64,
		57,
		36
	}

	self.back:add_child(wd)

	local s = KImageView:new("levelSelect_maxScore")

	s.anchor = v(s.size.x / 2, s.size.y / 2)
	s.pos = v(480, 487)

	self.back:add_child(s)

	local sl = GGLabel:new(v(84, 24))

	sl.pos = v(32, 25)
	sl.vertical_align = "middle"
	sl.font_name = "body"
	sl.font_size = 20
	sl.fit_size = true
	sl.fit_lines = 1
	sl.colors.text = {
		64,
		57,
		36
	}
	sl.colors.background = {
		0,
		0,
		0,
		0
	}
	sl.text = "999999"

	s:add_child(sl)

	self.score_label = sl

	local sd = GGLabel:new(V.v(100, 40))

	sd.text = _("ENDLESS_LEVEL_SELECT_MAX_SCORE")
	sd.pos = v(s.pos.x, s.pos.y + 55)
	sd.anchor = v(sd.size.x / 2, sd.size.y / 2)
	sd.font_name = "body"
	sd.font_size = 16
	sd.text_align = "center"
	sd.vertical_align = "top"
	sd.colors.text = {
		64,
		57,
		36
	}

	self.back:add_child(sd)
	self:load_score()

	local right_page = KView:new()

	self.back:add_child(right_page)
	add_level_title(right_page, _("ENDLESS_LEVEL_SELECT_HEADER"), "right")

	local desc_h = add_level_description(right_page, _("ENDLESS_LEVEL_" .. tostring(level_num - 80) .. "_HISTORY"))
	local rules_y = 320
	local rbg = KImageView:new("levelSelect_modebg_notxt_0001")

	rbg.pos = v(ls_page_r_x + (ls_page_w - rbg.size.x) / 2, rules_y + 20)

	right_page:add_child(rbg)
	add_level_title(right_page, _("Challenge Rules"), "sub", rules_y)

	rules_y = rules_y + 38

	local heart_icon = KImageView:new("levelSelect_modeRules_endless_0001")

	heart_icon.pos = v(ls_page_r_x + 20, rules_y)

	right_page:add_child(heart_icon)

	local skull_icon = KImageView:new("levelSelect_modeRules_endless_0002")

	skull_icon.pos = v(ls_page_r_x + ls_page_w / 2 + 20, rules_y)

	right_page:add_child(skull_icon)

	local heart_label = GGLabel:new(V.v(90, heart_icon.size.y))

	heart_label.text = _("ENDLESS_LEVEL_SELECT_LIVES_INFO")
	heart_label.pos = v(heart_icon.pos.x + heart_icon.size.x, heart_icon.pos.y + heart_icon.size.y / 2)
	heart_label.anchor.y = heart_label.size.y / 2
	heart_label.font_name = "body"
	heart_label.font_size = 13
	heart_label.text_align = "center"
	heart_label.vertical_align = "middle"
	heart_label.colors.text = {
		64,
		57,
		36
	}

	right_page:add_child(heart_label)

	local skull_label = GGLabel:new(V.v(90, skull_icon.size.y))

	skull_label.text = _("ENDLESS_LEVEL_SELECT_WAVES_INFO")
	skull_label.pos = v(skull_icon.pos.x + skull_icon.size.x, skull_icon.pos.y + skull_icon.size.y / 2)
	skull_label.anchor.y = skull_label.size.y / 2
	skull_label.font_name = "body"
	skull_label.font_size = 13
	skull_label.text_align = "center"
	skull_label.vertical_align = "middle"
	skull_label.colors.text = {
		64,
		57,
		36
	}

	right_page:add_child(skull_label)

	local b = LevelSelectDifficultyButton:new()

	b.pos = v(982, 522)
	b.parent_on_click = b.on_click

	function b.on_click(this)
		this:parent_on_click()
		self:load_score()
	end

	right_page:add_child(b)

	local ps_ld = PS and PS.services.leaderboards or nil
	local r = KImageButton("levelSelect_rankings_0001", "levelSelect_rankings_0002", "levelSelect_rankings_0002")

	r.pos = v(720, 550)
	r.anchor = v(r.size.x / 2, r.size.y / 2)
	r.alpha = ps_ld and ps_ld:get_status() and 1 or 0.5

	function r.on_click()
		S:queue("GUIButtonCommon")

		if not ps_ld then
			return
		end

		if ps_ld:get_status() then
			local user_data = storage:load_slot()

			ps_ld:show_leaderboard(level_num, user_data.difficulty)
		else
			ps_ld:do_signin()
		end
	end

	right_page:add_child(r)
	add_level_battle_button(right_page, GAME_MODE_ENDLESS, level_num)
end

function EndlessLevelSelectView:load_score()
	local waves_survived = 0
	local high_score = 0
	local user_data = storage:load_slot()
	local slot_level = user_data.levels[self.level_idx]

	if slot_level and slot_level[user_data.difficulty] then
		waves_survived = slot_level[user_data.difficulty].waves_survived
		high_score = slot_level[user_data.difficulty].high_score
	end

	self.waves_label.text = tostring(waves_survived)
	self.score_label.text = tostring(high_score)
end

UpgradesView = class("UpgradesView", PopUpView)

local SHARED_TECH_TREE_HELP_KEY = "shared_tech_tree_help"
local SHARED_TECH_TREE_HELP_TEXT = "1. Tháp chỉ nhận nâng cấp từ cây công nghệ của phần game gốc, bất kể đang chơi màn thuộc phần nào. Ví dụ: dùng T200 Battle-Mecha trong màn phần 3 vẫn nhận công nghệ gây choáng của phần 2, nhưng không nhận công nghệ chấn động đá của phần 3 hay ngắm thông minh của phần 1.\n\n2. Viện binh và phép thiên tai của mỗi phần có cây công nghệ riêng, cần nâng cấp riêng. Viện binh phần 4/5 có nhánh chọn một trong hai; quân được gọi trong màn chơi phụ thuộc vào nhánh đã chọn."
local GENERATION_UPGRADE_ICON_SCALE = 0.5
local GENERATION_UPGRADE_ICON_SCALE_45 = 0.87

local function new_generation_upgrade_frame(button, color)
	local ss = button.image_ss
	local ref_scale = ss and (ss.ref_scale or 1) * button.image_scale or 1
	local trim = ss and ss.trim or {0, 0}
	local quad = ss and ss.f_quad or {0, 0, button.size.x, button.size.y}
	local frame = KView:new(V.v(quad[3] * ref_scale, quad[4] * ref_scale))
	local thickness = 3

	frame.pos = v(trim[1] * ref_scale, trim[2] * ref_scale)
	frame.propagate_on_click = true
	frame.propagate_on_down = true
	frame.propagate_on_up = true

	local function add_edge(x, y, width, height)
		local edge = KView:new(V.v(width, height))

		edge.pos = v(x, y)
		edge.colors.background = color
		edge.propagate_on_click = true
		edge.propagate_on_down = true
		edge.propagate_on_up = true
		frame:add_child(edge)
	end

	add_edge(0, 0, frame.size.x, thickness)
	add_edge(0, frame.size.y - thickness, frame.size.x, thickness)
	add_edge(0, thickness, thickness, frame.size.y - thickness * 2)
	add_edge(frame.size.x - thickness, thickness, thickness, frame.size.y - thickness * 2)

	return frame
end

function UpgradesView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))

	self.back = KImageView:new("Upgrades_BG_notxt")
	self.back.anchor = v(self.back.size.x / 2, self.back.size.y / 2)
	self.back.pos = v(sw / 2 - 15, sh / 2 - 50)

	self:add_child(self.back)

	self.back.alpha = 1

	if IS_KR3 then
		local header_bg = KImageView("kr3_title_bg")

		header_bg.anchor.x = km.round(header_bg.size.x / 2)
		header_bg.pos = v(km.round(self.back.size.x / 2) - 10, -34)

		self.back:add_child(header_bg)
	end

	local header = GGPanelHeader:new(_("UPGRADES"), 274)

	header.pos = V.v(308, CJK(27, 25, nil, 25) + (IS_KR3 and -36 or 0))

	self.back:add_child(header)

	local close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")

	close_button.pos = v(self.back.size.x - 55, 20)
	self.close_button = close_button

	self.back:add_child(close_button)

	self.reset_button = GGUpgradesButton:new(_("BUTTON_RESET"))
	self.reset_button.pos = v(240, 630)

	self.back:add_child(self.reset_button)

	self.done_button = GGUpgradesButton:new(_("BUTTON_DONE"))
	self.done_button.pos = v(680, 630)

	self.back:add_child(self.done_button)

	self.star_container = KImageView:new("Upgrades_StarContainer")
	self.star_container.pos = v(100, 637)

	self.back:add_child(self.star_container)

	self.stars_label = KLabel:new(V.v(self.star_container.size.x / 2, self.star_container.size.y))
	self.stars_label.pos = v(85 + self.star_container.size.x / 2, 648)
	self.stars_label.font = F:f("Comic Book Italic", "30")
	self.stars_label.colors.text = {
		231,
		222,
		175
	}
	self.stars_label.text = "0"

	self.back:add_child(self.stars_label)

	self.disabled_icon = {}
	self.current_page = 1
	self.legacy_pages = {}

	for generation = 1, 3 do
		local page = KView:new(V.v(self.back.size.x, self.back.size.y))
		local title = GGLabel:new(V.v(300, 30))

		page.hidden = generation ~= 1
		page.propagate_on_click = true
		page.propagate_on_down = true
		page.propagate_on_up = true
		title.pos = v((self.back.size.x - title.size.x) / 2, 62)
		title.font_name = "body_bold"
		title.font_size = 22
		title.colors.text = {231, 222, 175, 255}
		title.text = string.format("Công nghệ phần %i", generation)
		title.text_align = "center"
		title.vertical_align = "middle"
		title.fit_lines = 1
		page:add_child(title)
		self.legacy_pages[generation] = page
		self.back:add_child(page)
	end

	self.generation_pages = {}

	for page_number = 4, 5 do
		local page = KView:new(V.v(self.back.size.x, self.back.size.y))

		page.hidden = true
		page.propagate_on_click = true
		page.propagate_on_down = true
		page.propagate_on_up = true
		self.generation_pages[page_number] = page
		self.back:add_child(page)
	end

	local legacy_root_names = {
		{"Tháp cung", "Doanh trại", "Pháp sư", "Tháp pháo", "Thiên tai", "Viện binh"},
		{"Tháp cung", "Doanh trại", "Pháp sư", "Tháp pháo", "Thiên tai", "Viện binh"},
		{"Tháp cung", "Doanh trại", "Pháp sư", "Tháp pháo", "Thiên tai", "Viện binh"}
	}

	local function add_root_tip(parent, center_x, center_y, title, description, sprite, icon_scale)
		local button = KButton:new()

		if sprite then
			button:set_image(sprite)
			button.anchor = v(button.size.x / 2, button.size.y / 2)
			button.pos = v(center_x, center_y)
			button.scale = v(icon_scale, icon_scale)

			local frame = new_generation_upgrade_frame(button, {255, 201, 38, 255})

			button:add_child(frame)
		else
			button.size = V.v(90, 76)
			button.hit_rect = V.r(0, 0, button.size.x, button.size.y)
			button.pos = v(center_x - button.size.x / 2, center_y - button.size.y / 2)
		end

		function button.on_enter()
			self:set_tip_panel(title, description, "")
		end

		function button.on_exit()
			self:hide_tip_panel()
		end

		parent:add_child(button)

		return button
	end

	local bar_positions = {
		v(152, 538),
		v(274, 538),
		v(394, 538),
		v(514, 538),
		v(636, 538),
		v(755, 538)
	}

	self.upgrade_bars = {}
	self.upgrade_buttons = {}

	UPGR:normalize_user_data(screen_map.user_data)
	generation_upgrades.normalize(screen_map.user_data)

	for generation = 1, 3 do
		local page = self.legacy_pages[generation]

		self.upgrade_bars[generation] = {}
		self.upgrade_buttons[generation] = {}

		for i, class in ipairs(UPGR.display_order) do
			local bar = KImageView:new("YellowBar")
			local root_name = legacy_root_names[generation][i]
			local root_subject = root_name == "Thiên tai" and "Phép thiên tai" or root_name

			bar.anchor = IS_KR3 and v(6, 376) or v(6, 372)
			bar.pos = bar_positions[i]
			page:add_child(bar)
			self.upgrade_bars[generation][class] = bar
			add_root_tip(page, bar_positions[i].x, 570, string.format("Phần %d: công nghệ %s", generation, root_name), string.format("Phần %d: %s được hưởng các nâng cấp này.", generation, root_subject))
		end
	end

	self.spent_stars = 0

	local start_y = 520
	local separation_y = 80
	local x_offsets = {
		115,
		237,
		355,
		477,
		598,
		718
	}

	for generation = 1, 3 do
		for _, key in ipairs(UPGR.generation_item_keys[generation]) do
			local value = UPGR.list[key]
			local class_ind = table.keyforobject(UPGR.display_order, value.class)
			local icon = UPGR:get_generation_icon(generation, value)
			local icon_name = generation == 3 and string.format("Upgrades_Icons_%04i", icon) or string.format("G%d_Upgrades_Icons_%04i", generation, icon)
			local button = UpgradeButtons:new(icon_name, value, key, generation)

			button.pos = v(x_offsets[class_ind], start_y - value.level * separation_y)
			self.legacy_pages[generation]:add_child(button)
			self.upgrade_buttons[generation][key] = button
		end
	end

	self.generation_buttons = {}
	local generation_x = {150, 350, 550, 750}
	local generation_start_y = 520
	local generation_separation_y = 80

	local function build_generation_page(page_number)
		local page = self.generation_pages[page_number]
		local generation_back = KView:new(V.v(800, 565))

		generation_back.pos = v(55, 50)
		generation_back.colors.background = {31, 27, 19, 255}
		page:add_child(generation_back)

		for column, x in ipairs(generation_x) do
			local lane = KView:new(V.v(176, 505))

			lane.pos = v(x - 88, 96)
			lane.colors.background = column % 2 == 1 and {40, 35, 24, 255} or {47, 39, 25, 255}
			page:add_child(lane)
		end

		for column, tree_id in ipairs(generation_upgrades.page_tree_order[page_number]) do
			local tree = generation_upgrades.trees[tree_id]
			local title = GGLabel:new(V.v(180, 30))

			title.pos = v(generation_x[column] - 90, 62)
			title.font_name = "body_bold"
			title.font_size = 20
			title.colors.text = {231, 222, 175, 255}
			title.text = tree.name
			title.text_align = "center"
			title.vertical_align = "middle"
			title.fit_lines = 1
			page:add_child(title)

			local bar = KImageView:new("YellowBar")

			bar.anchor = IS_KR3 and v(6, 376) or v(6, 372)
			bar.pos = v(generation_x[column], 538)
			page:add_child(bar)
			local icon_scale = page_number == 4 and GENERATION_UPGRADE_ICON_SCALE_45 or GENERATION_UPGRADE_ICON_SCALE

			add_root_tip(page, generation_x[column], 570, tree.root_name, tree.root_description, tree.root_sprite, icon_scale)

			local items_by_level = {}

			for _, item in ipairs(tree.items) do
				items_by_level[item.level] = items_by_level[item.level] or {}
				table.insert(items_by_level[item.level], item)
			end

			for level, items in pairs(items_by_level) do
				for index, item in ipairs(items) do
					local icon_name = item.sprite or string.format("Upgrades_Icons_%04i", item.icon)
					local button = GenerationUpgradeButton:new(icon_name, item, icon_scale)
					local offset = #items > 1 and (index == 1 and -38 or 38) or 0

					button.anchor = v(button.size.x / 2, button.size.y / 2)
					button.pos = v(generation_x[column] + offset, generation_start_y - level * generation_separation_y + button.size.y / 2)
					page:add_child(button)
					self.generation_buttons[item.key] = button
				end
			end
		end
	end

	build_generation_page(4)
	build_generation_page(5)

	self.page_buttons = {}
	local page_button_x = 389

	for page_index = 1, 5 do
		local selected = page_index == self.current_page
		local button = EncyclopediaPageButton:new(page_index, selected)
		local target_page = page_index

		button.anchor = v(button.size.x / 2, button.size.y / 2)
		button.pos = v(page_button_x + (page_index - 1) * 36, 655)
		button.deselected_image_name = "encyclopedia_pageNbr_0001"
		button.selected_image_name = "encyclopedia_pageNbrSelected_0001"

		function button.on_click()
			S:queue("GUIButtonCommon")
			self:set_page(target_page)
		end

		self.back:add_child(button)
		self.page_buttons[page_index] = button
	end

	self.help_button = GGUpgradesButton:new("Trợ giúp")
	self.help_button.pos = v(570, 630)
	self.back:add_child(self.help_button)

	self:set_bought_levels()
	self:set_stars_and_check()

	self.tip_panel = KView:new(V.v(320, 100))
	self.tip_panel.colors.background = {
		21,
		17,
		13,
		255
	}
	self.tip_panel.anchor = v(0, 105)
	self.tip_panel.alpha = 0.9

	self:add_child(self.tip_panel)

	local tip_panel_tip = KImageView:new("Upgrades_Tips_tip")

	tip_panel_tip.pos = v(6, 72)
	tip_panel_tip.propagate_on_click = true

	self.tip_panel:add_child(tip_panel_tip)

	self.tip_panel.tip = tip_panel_tip

	local name_label = GGLabel:new(V.v(240, 18))

	name_label.pos = v(20, 8)
	name_label.font_name = "body"
	name_label.font_size = 18
	name_label.colors.text = {
		255,
		255,
		255
	}
	name_label.text = "title_name"
	name_label.text_align = "left"
	name_label.fit_lines = 1
	self.tip_panel.title = name_label

	self.tip_panel:add_child(name_label)

	local desc_label = GGLabel:new(V.v(280, 18))

	desc_label.pos = v(20, 33)
	desc_label.font_name = "body"
	desc_label.font_size = 18
	desc_label.colors.text = {
		245,
		203,
		6
	}
	desc_label.text_align = "left"
	desc_label.text = "desc_name"
	desc_label.line_height = CJK(0.85, nil, 1, 0.9)
	self.tip_panel.desc = desc_label

	self.tip_panel:add_child(desc_label)

	local price_label = GGLabel:new(V.v(50, 18))

	price_label.pos = v(295, 8)
	price_label.font_name = "numbers"
	price_label.font_size = 18
	price_label.colors.text = {
		255,
		255,
		255
	}
	price_label.text = "2"
	price_label.text_align = "left"
	self.tip_panel.price = price_label

	self.tip_panel:add_child(price_label)

	self.tip_panel.propagate_on_click = true
	self.tip_panel.hidden = true

	local tip_star = KImageView:new("Upgrades_Tips_Star")

	tip_star.pos = v(270, 10)
	self.tip_panel.star = tip_star

	self.tip_panel:add_child(tip_star)

	local max_upgrade_stars = UPGR:get_total_stars() + generation_upgrades.total_price()
	local l_stars_num = math.ceil(math.min(screen_map.total_stars, max_upgrade_stars) - self.spent_stars - generation_upgrades.spent(screen_map.user_data))

	screen_map.upgrade_star.hidden = l_stars_num <= 0
	screen_map.upgrade_points.text = l_stars_num
	screen_map.upgrade_points.hidden = l_stars_num <= 0
end

function UpgradesView:hide_shared_tech_tree_help()
	if self.shared_tech_tree_help and self.shared_tech_tree_help.parent then
		self.shared_tech_tree_help.parent:remove_child(self.shared_tech_tree_help)
	end

	self.shared_tech_tree_help = nil
end

function UpgradesView:show_shared_tech_tree_help(force)
	local seen = screen_map_seen_table()

	if not force then
		if not seen or seen[SHARED_TECH_TREE_HELP_KEY] and not DBG_SHOW_BALLOONS then
			return
		end

		screen_map_mark_seen(SHARED_TECH_TREE_HELP_KEY)
	end

	self:hide_shared_tech_tree_help()

	local overlay = KView:new(V.v(self.back.size.x, self.back.size.y))

	overlay.colors.background = {
		0,
		0,
		0,
		85
	}

	function overlay.on_click()
		S:queue("GUIButtonCommon")
		self:hide_shared_tech_tree_help()
	end

	local frame = KView:new(V.v(math.min(820, self.back.size.x - 80), 380))

	frame.pos = v((self.back.size.x - frame.size.x) / 2, (self.back.size.y - frame.size.y) / 2 - 15)
	frame.colors.background = {
		89,
		61,
		34,
		250
	}
	frame.propagate_on_click = true
	frame.propagate_on_down = true
	frame.propagate_on_up = true
	overlay:add_child(frame)

	local card = KView:new(V.v(frame.size.x - 10, frame.size.y - 10))

	card.pos = v(5, 5)
	card.colors.background = {
		250,
		232,
		166,
		255
	}
	card.propagate_on_click = true
	card.propagate_on_down = true
	card.propagate_on_up = true
	frame:add_child(card)

	local label = GGLabel:new(V.v(card.size.x - 60, card.size.y - 80))

	label.pos = v(30, 24)
	label.font_name = "body"
	label.font_size = 22
	label.colors.text = {
		86,
		55,
		35,
		255
	}
	label.text = SHARED_TECH_TREE_HELP_TEXT
	label.text_align = "left"
	label.vertical_align = "top"
	label.line_height = 1.08
	label.fit_lines = 11
	label.propagate_on_click = true
	label.propagate_on_down = true
	label.propagate_on_up = true
	card:add_child(label)

	local continue_label = GGLabel:new(V.v(card.size.x - 60, 24))

	continue_label.pos = v(30, card.size.y - 38)
	continue_label.font_name = "body"
	continue_label.font_size = 18
	continue_label.colors.text = {
		116,
		72,
		43,
		255
	}
	continue_label.text = "Nhấn để tiếp tục"
	continue_label.text_align = "center"
	continue_label.fit_lines = 1
	continue_label.propagate_on_click = true
	continue_label.propagate_on_down = true
	continue_label.propagate_on_up = true
	card:add_child(continue_label)

	self.shared_tech_tree_help = overlay
	self.back:add_child(overlay)
end

function UpgradesView:set_tip_panel(title, desc, price)
	if self.im_disabled then
		return
	end

	self.tip_panel.title.text = title
	self.tip_panel.price.text = price

	local d = self.tip_panel.desc

	d.text = desc

	local _w, lines = d:get_wrap_lines()

	self.tip_panel.size.y = d.pos.y + (lines + 1) * d.line_height * d:get_font_height()
	self.tip_panel.tip.pos = v(-14, self.tip_panel.size.y - 20)
	self.tip_panel.anchor = v(-15, self.tip_panel.size.y + 10)
	self.tip_panel.hidden = false

	self:update_tooltip_position()
end

function UpgradesView:hide_tip_panel()
	self.tip_panel.hidden = true
end

function UpgradesView:set_init_values(stars)
	self.max_stars = screen_map.total_stars
end

function UpgradesView:set_page(page)
	self.current_page = km.clamp(1, 5, page)

	for generation = 1, 3 do
		self.legacy_pages[generation].hidden = self.current_page ~= generation
	end

	for page_number, generation_page in pairs(self.generation_pages) do
		generation_page.hidden = self.current_page ~= page_number
	end

	for page_index, button in ipairs(self.page_buttons) do
		if page_index == self.current_page then
			button:select()
		else
			button:deselect()
		end
	end

	self:hide_tip_panel()
	self:set_stars_and_check()
end

function UpgradesView:update_tooltip_position()
	if not self.tip_panel.hidden then
		local mx, my = screen_map.window:get_mouse_position()

		self.tip_panel.pos = v(mx / screen_map.window.scale.x, my / screen_map.window.scale.y)
	end
end

function UpgradesView:update(dt)
	UpgradesView.super.update(self, dt)
	self:update_tooltip_position()
end

function UpgradesView:set_stars_and_check()
	local generation_spent = generation_upgrades.spent(screen_map.user_data)
	local l_stars_num = math.ceil(screen_map.total_stars - self.spent_stars - generation_spent)

	for generation = 1, 3 do
		local bought_list = self.bought_lists[generation]

		for _, value in pairs(self.upgrade_buttons[generation]) do
			local do_grey = true

			if bought_list[value.data_values.class] + 1 == value.data_values.level and not value.bought and l_stars_num >= value.data_values.price then
				do_grey = false
			end

			if not value.bought then
				if do_grey then
					value:grey_me()
				else
					value:ungrey_me()
				end
			end
		end
	end

	for key, value in pairs(self.generation_buttons) do
		if generation_upgrades.has_key(screen_map.user_data, key) then
			value:set_bought()
		elseif generation_upgrades.can_buy(screen_map.user_data, value.data_values.tree, key) and l_stars_num >= value.data_values.price then
			value:ungrey_me()
		else
			value:grey_me()
		end
	end

	local page_spent = self.current_page <= 3 and self.spent_stars_by_generation[self.current_page] or generation_upgrades.spent_page(screen_map.user_data, self.current_page)

	if page_spent > 0 then
		self.reset_button:enable()
	else
		self.reset_button:disable()
	end
	if l_stars_num <= 0 then
		l_stars_num = 0
	end
	self.stars_label.text = l_stars_num
end

function UpgradesView:set_bought_levels(generation, new_bought_list)
	if generation and new_bought_list then
		UPGR:set_user_levels(screen_map.user_data, generation, new_bought_list)
	end

	self.bought_lists = {}
	self.spent_stars_by_generation = {}
	self.spent_stars = 0

	for current_generation = 1, 3 do
		local levels = UPGR:get_user_levels(screen_map.user_data, current_generation)

		self.bought_lists[current_generation] = {}

		for class, value in pairs(levels) do
			self.bought_lists[current_generation][class] = value
			self.upgrade_bars[current_generation][class].scale = v(1, 0.2 * value)
		end

		self.spent_stars_by_generation[current_generation] = UPGR:get_spent_stars(levels, current_generation)
		self.spent_stars = self.spent_stars + self.spent_stars_by_generation[current_generation]

		for _, button in pairs(self.upgrade_buttons[current_generation]) do
			if levels[button.data_values.class] >= button.data_values.level then
				button:set_bought()
			else
				button:grey_me()
			end
		end
	end

	self:set_stars_and_check()
	storage:save_slot(screen_map.user_data)
end

function UpgradesView:rest_stars(stars_num)
	if stars_num > tonumber(self.stars_label.text) then
		return false
	else
		return true
	end
end

function UpgradesView:upgrade_bought(generation, class, level, stars_num)
	self.bought_lists[generation][class] = level

	self:set_bought_levels(generation, self.bought_lists[generation])
	self:set_stars_and_check()
end

function UpgradesView:show()
	UPGR:normalize_user_data(screen_map.user_data)
	generation_upgrades.normalize(screen_map.user_data)
	self:set_bought_levels()
	self:set_init_values(screen_map.total_stars)
	self:set_page(self.current_page or 1)
	UpgradesView.super.show(self)
	self:show_shared_tech_tree_help()
end

function UpgradesView:hide()
	self:hide_shared_tech_tree_help()
	UpgradesView.super.hide(self)

	self.tip_panel.hidden = true
end

function UpgradesView:enable()
	UpgradesView.super.enable(self)

	self.im_disabled = false

	function self.close_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end

	function self.done_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end

	function self.help_button.on_click()
		S:queue("GUIButtonCommon")
		self:show_shared_tech_tree_help(true)
	end

	function self.reset_button.on_click(button, x, y)
		S:queue("GUIButtonCommon")

		if self.current_page >= 4 then
			generation_upgrades.reset_page(screen_map.user_data, self.current_page)
			self:set_bought_levels()
		else
			local none_bought = {}

			for _, k in pairs(UPGR.display_order) do
				none_bought[k] = 0
			end

			self:set_bought_levels(self.current_page, none_bought)
		end

	end

	local page_spent = self.current_page <= 3 and self.spent_stars_by_generation[self.current_page] or generation_upgrades.spent_page(screen_map.user_data, self.current_page)

	if page_spent > 0 then
		self.reset_button:enable()
	else
		self.reset_button:disable()
	end

end

function UpgradesView:disable()
	UpgradesView.super.disable(self, false)

	self.im_disabled = true
	self.close_button.on_click = nil
	self.done_button.on_click = nil
	self.reset_button.on_click = nil
	self.help_button.on_click = nil

	local max_upgrade_stars = UPGR:get_total_stars() + generation_upgrades.total_price()
	local l_stars_num = math.ceil(math.min(screen_map.total_stars, max_upgrade_stars) - self.spent_stars - generation_upgrades.spent(screen_map.user_data))

	screen_map.upgrade_star.hidden = l_stars_num == 0
	screen_map.upgrade_points.text = l_stars_num
	screen_map.upgrade_points.hidden = l_stars_num == 0
end

UpgradeButtons = class("UpgradeButtons", KImageView)

function UpgradeButtons:initialize(sprite, data_values, my_id, generation)
	KImageView.initialize(self, sprite)

	self.my_id = my_id
	self.generation = generation
	self.disabled_image = KImageView:new("Disabled_" .. sprite)

	self:add_child(self.disabled_image)

	self.data_values = data_values
	self.over_circle = KImageView:new("Upgrades_Icons_over")
	self.over_circle.anchor = v(self.over_circle.size.x / 2, self.over_circle.size.y / 2)
	self.over_circle.pos = v(self.size.x / 2, self.size.y / 2)
	self.over_circle.propagate_on_click = true

	self:add_child(self.over_circle)

	self.bought_circle = KImageView:new("Upgrades_Icons_Bought")
	self.bought_circle.anchor = v(self.bought_circle.size.x / 2, self.bought_circle.size.y / 2)
	self.bought_circle.pos = v(self.size.x / 2, self.size.y / 2)

	self:add_child(self.bought_circle)

	self.sell_icon = KImageView:new("Generation_Upgrade_Sell")
	self.sell_icon.anchor = v(self.sell_icon.size.x / 2, self.sell_icon.size.y / 2)
	self.sell_icon.pos = v(self.size.x / 2, self.size.y / 2)
	self.sell_icon.hidden = true
	self.sell_icon.propagate_on_click = true
	self:add_child(self.sell_icon)

	self.cost_panel = KImageView:new("Upgrades_Icons_PriceTag")
	self.cost_panel.pos = v(35, 55)

	self:add_child(self.cost_panel)

	local price_value

	if data_values.price <= 4 then
		price_value = KImageView:new("Upgrades_Icons_PriceTag_Nm_000" .. data_values.price)
		price_value.anchor = v(price_value.size.x / 2, price_value.size.y / 2)
		price_value.pos = v(self.cost_panel.size.x / 2 + 4, self.cost_panel.size.y / 2)
	else
		price_value = GGLabel:new(V.v(self.cost_panel.size.x, self.cost_panel.size.y))
		price_value.font_name = "body_bold"
		price_value.font_size = 13
		price_value.text = tostring(data_values.price)
		price_value.text_align = "center"
		price_value.vertical_align = "middle"
		price_value.text_offset.x = 4
		price_value.colors.text = {255, 224, 0, 255}
		price_value.propagate_on_click = true
	end

	self.cost_panel:add_child(price_value)

	self.disabled_cost_panel = KImageView:new("Disabled_Upgrades_Icons_PriceTag")
	self.disabled_cost_panel.pos = v(35, 55)

	self:add_child(self.disabled_cost_panel)

	local disabled_price_value

	if data_values.price <= 4 then
		disabled_price_value = KImageView:new("Disabled_Upgrades_Icons_PriceTag_Nm_000" .. data_values.price)
		disabled_price_value.anchor = v(disabled_price_value.size.x / 2, disabled_price_value.size.y / 2)
		disabled_price_value.pos = v(self.cost_panel.size.x / 2 + 4, self.cost_panel.size.y / 2)
	else
		disabled_price_value = GGLabel:new(V.v(self.disabled_cost_panel.size.x, self.disabled_cost_panel.size.y))
		disabled_price_value.font_name = "body_bold"
		disabled_price_value.font_size = 13
		disabled_price_value.text = tostring(data_values.price)
		disabled_price_value.text_align = "center"
		disabled_price_value.vertical_align = "middle"
		disabled_price_value.text_offset.x = 4
		disabled_price_value.colors.text = {156, 146, 132, 255}
		disabled_price_value.propagate_on_click = true
	end

	self.disabled_cost_panel:add_child(disabled_price_value)

	self.cost_panel.propagate_on_click = true
	self.disabled_cost_panel.propagate_on_click = true
	self.over_circle.hidden = true
	self.bought_circle.hidden = true
	self.bought = false
	self.grey_out = true
	self.cost_panel.hidden = true
end

function UpgradeButtons:on_enter()
	if self.bought then
		self.sell_icon.hidden = false
	elseif not self.grey_out then
		self.over_circle.hidden = false
	end

	screen_map.upgrades:set_tip_panel(_(UPGR:get_localization_key(self.generation, self.my_id, "NAME")), _(UPGR:get_localization_key(self.generation, self.my_id, "DESCRIPTION")), self.data_values.price)
end

function UpgradeButtons:on_exit()
	self.over_circle.hidden = true
	self.sell_icon.hidden = true

	screen_map.upgrades:hide_tip_panel()
end

function UpgradeButtons:grey_me()
	self.grey_out = true
	self.disabled_image.hidden = false
	self.cost_panel.hidden = true
	self.disabled_cost_panel.hidden = false
	self.bought = false
	self.bought_circle.hidden = true
	self.over_circle.hidden = true
	self.sell_icon.hidden = true
end

function UpgradeButtons:ungrey_me()
	self.grey_out = false
	self.disabled_image.hidden = true
	self.cost_panel.hidden = false
	self.disabled_cost_panel.hidden = true
	self.bought = false
	self.bought_circle.hidden = true
	self.over_circle.hidden = true
	self.sell_icon.hidden = true
end

function UpgradeButtons:on_click(button, x, y)
	if self.bought then
		S:queue("GUIButtonCommon")
		screen_map.upgrades:hide_tip_panel()
		screen_map.upgrades.bought_lists[self.generation][self.data_values.class] = self.data_values.level - 1
		screen_map.upgrades:set_bought_levels(self.generation, screen_map.upgrades.bought_lists[self.generation])

		return
	end

	if not self.grey_out and not self.bought and screen_map.upgrades:rest_stars(self.data_values.price) then
		S:queue("GUIBuyUpgrade")
		screen_map.upgrades:hide_tip_panel()
		self:set_bought()
		screen_map.upgrades:upgrade_bought(self.generation, self.data_values.class, self.data_values.level, self.data_values.price)

		self.explotion = KImageView:new()
		self.explotion.pos = v(-17.5, -17.5)
		self.explotion.animation = {
			to = 18,
			prefix = "Upgrades_Icons_buyFx",
			from = 1
		}
		self.explotion.ts = 0

		self:add_child(self.explotion)
		timer.tween(0.6, nil, {}, "linear", function()
			self:remove_child(self.explotion)

			self.explotion = nil
		end)
	end
end

function UpgradeButtons:set_bought()
	self.cost_panel.hidden = true
	self.disabled_cost_panel.hidden = true
	self.bought = true
	self.bought_circle.hidden = false
	self.over_circle.hidden = true
	self.sell_icon.hidden = true
	self.disabled_image.hidden = true

	if self.data_values.class == "thunder" then
		return self.data_values.price / 2
	elseif self.data_values.class == "reinforcements" then
		return self.data_values.price
	else
		return self.data_values.price / 3
	end
	-- return self.data_values.price
end

GenerationUpgradeButton = class("GenerationUpgradeButton", UpgradeButtons)

function GenerationUpgradeButton:initialize(sprite, data_values, icon_scale)
	UpgradeButtons.initialize(self, sprite, data_values, data_values.key)

	self:remove_child(self.over_circle)
	self:remove_child(self.bought_circle)

	self.over_circle = new_generation_upgrade_frame(self, {255, 244, 158, 255})
	self.bought_circle = new_generation_upgrade_frame(self, {255, 201, 38, 255})
	self.over_circle.hidden = true
	self.bought_circle.hidden = true

	self:add_child(self.over_circle)
	self:add_child(self.bought_circle)

	self.scale = v(icon_scale, icon_scale)
end

function GenerationUpgradeButton:on_enter()
	if self.bought then
		self.sell_icon.hidden = false
	elseif not self.grey_out then
		self.over_circle.hidden = false
	end

	local title = self.data_values.name or _(self.data_values.name_key)
	local description = self.data_values.description or _(self.data_values.description_key)

	description = GU.balance_format(description, balance) or description

	screen_map.upgrades:set_tip_panel(title, description, self.data_values.price)
end

function GenerationUpgradeButton:on_click(button, x, y)
	local was_bought = self.bought

	if (was_bought or not self.grey_out) and screen_map.upgrades:generation_upgrade_clicked(self.data_values) then
		S:queue(was_bought and "GUIButtonCommon" or "GUIBuyUpgrade")
		screen_map.upgrades:hide_tip_panel()

		if not was_bought then
			self.explotion = KImageView:new()
			self.explotion.pos = v(-17.5, -17.5)
			self.explotion.animation = {to = 18, prefix = "Upgrades_Icons_buyFx", from = 1}
			self.explotion.ts = 0
			self:add_child(self.explotion)
			timer.tween(0.6, nil, {}, "linear", function()
				self:remove_child(self.explotion)
				self.explotion = nil
			end)
		end
	end
end

EncyclopediaTabLabel = class("EncyclopediaTabLabel", GGShaderLabel)

function EncyclopediaTabLabel:initialize(text, selected, rotation)
	GGShaderLabel.initialize(self, V.v(62, 18))

	self.font_name = CJK("body", nil, nil, "h_noti")
	self.font_size = 16
	self.font_align = "center"
	self.anchor.x, self.anchor.y = self.size.x / 2, self.size.y / 2
	self.r = rotation or 4 * math.pi / 180
	self.text = text
	self.fit_lines = 1
	self.shaders = {
		"p_glow"
	}

	if selected then
		self.colors.text = {
			224,
			242,
			253,
			255
		}
		self.shader_args = {
			{
				thickness = 2,
				glow_color = {
					0.03137254901960784,
					0.12549019607843137,
					0.1803921568627451,
					1
				}
			}
		}
	else
		self.shader_args = {
			{
				thickness = 2,
				glow_color = {
					0.29411764705882354,
					0.13725490196078433,
					0.06666666666666667,
					1
				}
			}
		}
		self.colors.text = {
			198,
			134,
			95,
			255
		}
	end
end

local encyclopedia_text_has_copy

local function encyclopedia_find_power_menu_item(menu, power_name)
	if type(menu) ~= "table" then
		return nil
	end

	if (menu.action == "upgrade_power" or menu.action == "tw_ultimate_info") and menu.action_arg == power_name then
		return menu
	end

	for _, item in pairs(menu) do
		local found = encyclopedia_find_power_menu_item(item, power_name)

		if found then
			return found
		end
	end

	return nil
end

local kr6_tower_select_ultimate_data = kr6_tower_integration.ultimate_data
local kr6_tower_detail_names = {}

for _, template_name in ipairs(kr6_tower_integration.detail_templates or {}) do
	kr6_tower_detail_names[template_name] = true
end

local function encyclopedia_tower_power_menu_item(dt, power_name, tower_name)
	local tower = dt.tower
	local advanced_skills = kr6_tower_integration.legacy_advanced_skills[tower_name]
	local tower_type = advanced_skills and advanced_skills.menu or tower and tower.type

	if not tower_type then
		return nil
	end

	if power_name == "ultimate" and string.sub(tower_type, 1, 4) == "kr6_" then
		local menu_name = string.sub(tower_type, 5)
		local ultimate = kr6_tower_select_ultimate_data[menu_name]

		if ultimate then
			return {
				action = "tw_ultimate_info",
				action_arg = "ultimate",
				image = "quickmenu_special_icons_" .. ultimate.icon .. "_0004",
				tt_title = _("TOWER_" .. ultimate.text .. "_4_ULT_NAME"),
				tt_desc = _("TOWER_" .. ultimate.text .. "_4_ULT_DESCRIPTION")
			}
		end
	end

	local menus_by_level

	if tower.page and tower_menus[tower_type .. "_" .. tower.page] then
		menus_by_level = tower_menus[tower_type .. "_" .. tower.page]
	else
		menus_by_level = tower_menus[tower_type]
	end

	if not menus_by_level then
		return nil
	end

	local level_menu = menus_by_level[tower.level or 1]
	local item = encyclopedia_find_power_menu_item(level_menu, power_name)

	if item then
		return item
	end

	return encyclopedia_find_power_menu_item(menus_by_level, power_name)
end

local special_tower_build_suffixes = {
	"_d",
	"_land",
	"_holder",
	"_goal_d",
	"_re",
	"_1",
	"_2"
}

local function encyclopedia_find_tower_build_menu_item(menu, tower_name, allow_variant, visited)
	if type(menu) ~= "table" then
		return nil
	end

	visited = visited or {}

	if visited[menu] then
		return nil
	end

	visited[menu] = true

	if menu.action == "tw_upgrade" and type(menu.action_arg) == "string" then
		if menu.action_arg == tower_name then
			return menu
		end

		if allow_variant then
			for _, suffix in ipairs(special_tower_build_suffixes) do
				if menu.action_arg == tower_name .. suffix then
					return menu
				end
			end
		end
	end

	for _, item in pairs(menu) do
		local found = encyclopedia_find_tower_build_menu_item(item, tower_name, allow_variant, visited)

		if found then
			return found
		end
	end

	return nil
end

local function encyclopedia_special_tower_build_menu_item(tower_name)
	return encyclopedia_find_tower_build_menu_item(tower_menus, tower_name, false)
		or encyclopedia_find_tower_build_menu_item(tower_menus, tower_name, true)
end

local function encyclopedia_menu_has_action(menu, action, visited)
	if type(menu) ~= "table" then
		return false
	end

	visited = visited or {}

	if visited[menu] then
		return false
	end

	visited[menu] = true

	if menu.action == action then
		return true
	end

	for _, item in pairs(menu) do
		if encyclopedia_menu_has_action(item, action, visited) then
			return true
		end
	end

	return false
end

local function encyclopedia_special_tower_fallback_description(tower_name, dt)
	local override = special_tower_encyclopedia.description_overrides[tower_name]

	if encyclopedia_text_has_copy(override) then
		return override
	end

	local build_item = encyclopedia_special_tower_build_menu_item(tower_name)
	local menu_desc = build_item and build_item.tt_desc

	if encyclopedia_text_has_copy(menu_desc) then
		return GU.balance_format(menu_desc, balance) or menu_desc
	end

	local tower = dt and dt.tower
	local tower_type = tower and tower.type
	local menu

	if tower_type then
		if tower.page and tower_menus[tower_type .. "_" .. tower.page] then
			menu = tower_menus[tower_type .. "_" .. tower.page]
		else
			menu = tower_menus[tower_type]
		end
	end

	local has_buy_soldier = encyclopedia_menu_has_action(menu, "tw_buy_soldier")
	local has_buy_attack = encyclopedia_menu_has_action(menu, "tw_buy_attack") or encyclopedia_menu_has_action(menu, "tw_free_action")
	local has_barrack = dt and dt.barrack or has_buy_soldier
	local has_attack = dt and dt.attacks and type(dt.attacks.list) == "table" and next(dt.attacks.list) ~= nil
	local has_powers = dt and type(dt.powers) == "table" and next(dt.powers) ~= nil

	if has_barrack and has_attack then
		return "Triển khai lính chặn địch, đồng thời dùng hỏa lực tầm xa hoặc đòn đánh đặc biệt để hỗ trợ."
	elseif has_barrack then
		return "Triển khai hoặc thuê lính để chặn và tấn công địch quanh điểm tập kết."
	elseif has_attack and has_powers then
		return "Tấn công địch trong tầm. Nâng cấp kỹ năng để tăng sức chiến đấu của tháp."
	elseif has_attack then
		return "Tự động tấn công địch trong tầm, hỗ trợ hỏa lực cho màn chơi."
	elseif has_buy_attack then
		return "Dùng vàng để kích hoạt đòn tấn công hoặc hiệu ứng hỗ trợ của công trình trong màn."
	elseif has_powers then
		return "Dùng kỹ năng riêng để hỗ trợ chiến đấu."
	end

	return "Cung cấp hỗ trợ đặc biệt trong màn tương ứng hoặc qua menu xây dựng."
end

local function encyclopedia_power_fallback_title(dt, tower_name, power_name, power)
	local info_key = dt and dt.info and dt.info.i18n_key

	return _(string.upper(string.format("%s_%s_NAME", info_key or tower_name, power.name or power_name)))
end

encyclopedia_text_has_copy = function(text)
	if type(text) ~= "string" then
		return false
	end

	local stripped = string.gsub(text, "%s+", "")

	if stripped == "" then
		return false
	end

	return not (string.find(stripped, "_") and string.match(stripped, "^[%u%d_%.%-]+$"))
end

local function encyclopedia_tower_entry_display_name(tower_entry, fallback_name)
	local display_name = tower_entry and tower_entry.display_name

	if not encyclopedia_text_has_copy(display_name) and tower_entry and tower_entry.display_name_key then
		display_name = _(tower_entry.display_name_key)
	end

	return encyclopedia_text_has_copy(display_name) and display_name or fallback_name
end

local function encyclopedia_tower_power_price(power, level)
	return tower_power_display.price(power, level)
end

local function encyclopedia_tower_power_match_desc(desc)
	if desc ~= "" then
		return GU.balance_format(desc, balance) or desc
	end

	return desc
end

local function encyclopedia_tower_docs()
	return tower_menus and tower_menus.tower_balance_docs
end

local function encyclopedia_tower_doc_mode()
	local docs = encyclopedia_tower_docs()
	local mode = docs and docs.mode or "auto"

	if mode == "standard" or mode == "enhanced" or mode == "game" then
		return mode
	end

	return screen_map.user_data and screen_map.user_data.liuhui and screen_map.user_data.liuhui.balance and "enhanced" or "standard"
end

local function encyclopedia_tower_doc_status()
	local docs = encyclopedia_tower_docs()
	local mode = encyclopedia_tower_doc_mode()
	local status = docs and docs.status_text and docs.status_text[mode]

	if status then
		return status
	end

	return mode == "enhanced" and "Tăng cường: bật" or "Tăng cường: tắt"
end

local function encyclopedia_tower_doc_entry(tower_name)
	local docs = encyclopedia_tower_docs()

	return docs and docs.entries and docs.entries[tower_name]
end

local function encyclopedia_tower_doc_text(values, fallback)
	local mode = encyclopedia_tower_doc_mode()

	if mode == "game" or type(values) ~= "table" then
		return fallback
	end

	return values[mode] or values.standard or fallback
end

local function encyclopedia_tower_doc_skill_levels(skill)
	local mode = encyclopedia_tower_doc_mode()

	if mode == "game" or type(skill) ~= "table" then
		return nil
	end

	local levels = mode == "enhanced" and skill.levels_enhanced or skill.levels_standard

	if type(levels) == "table" and #levels > 0 then
		return levels
	end

	return nil
end

local function encyclopedia_tower_doc_skill_level_count(skill)
	local levels = encyclopedia_tower_doc_skill_levels(skill)

	return levels and #levels or 0
end

local function encyclopedia_tower_doc_skill_desc(skill, fallback, level)
	local levels = encyclopedia_tower_doc_skill_levels(skill)

	if levels then
		local desc = levels[level or 1] or levels[#levels]

		if encyclopedia_text_has_copy(desc) then
			return desc
		end
	end

	return encyclopedia_tower_doc_text(skill, fallback)
end

function UpgradesView:generation_upgrade_clicked(item)
	if generation_upgrades.has_key(screen_map.user_data, item.key) then
		generation_upgrades.refund_from(screen_map.user_data, item.tree, item.key)
	elseif self:rest_stars(item.price) then
		generation_upgrades.buy(screen_map.user_data, item.tree, item.key)
	else
		return false
	end

	storage:save_slot(screen_map.user_data)
	self:set_stars_and_check()

	return true
end

local function encyclopedia_tower_doc_skill_previous_desc(skill, level)
	local levels = encyclopedia_tower_doc_skill_levels(skill)

	if not levels or not level or level <= 1 then
		return ""
	end

	return levels[level - 1] or levels[1] or ""
end

local function encyclopedia_tower_doc_skill_next_desc(skill, level)
	local levels = encyclopedia_tower_doc_skill_levels(skill)

	if not levels or not level then
		return nil
	end

	return levels[level + 1]
end

local function encyclopedia_tower_doc_normalize(text)
	text = tostring(text or "")
	text = string.gsub(text, "%s+", "")
	text = string.gsub(text, "Ⅰ$", "")
	text = string.gsub(text, "Ⅱ$", "")
	text = string.gsub(text, "Ⅲ$", "")
	text = string.gsub(text, "Ⅳ$", "")
	text = string.gsub(text, "Ⅴ$", "")
	text = string.gsub(text, "I+$", "")

	return text
end

local function encyclopedia_tower_doc_chars(text)
	local chars = {}
	text = tostring(text or "")

	local i = 1

	while i <= #text do
		local b1 = string.byte(text, i)
		local len, code = 1, b1

		if b1 and b1 >= 240 then
			local b2, b3, b4 = string.byte(text, i + 1, i + 3)

			if b2 and b3 and b4 then
				len = 4
				code = (b1 % 8) * 262144 + (b2 % 64) * 4096 + (b3 % 64) * 64 + (b4 % 64)
			end
		elseif b1 and b1 >= 224 then
			local b2, b3 = string.byte(text, i + 1, i + 2)

			if b2 and b3 then
				len = 3
				code = (b1 % 16) * 4096 + (b2 % 64) * 64 + (b3 % 64)
			end
		elseif b1 and b1 >= 192 then
			local b2 = string.byte(text, i + 1)

			if b2 then
				len = 2
				code = (b1 % 32) * 64 + (b2 % 64)
			end
		end

		if code and ((code >= 48 and code <= 57) or (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or (code >= 19968 and code <= 40959)) then
			table.insert(chars, string.sub(text, i, i + len - 1))
		end

		i = i + len
	end

	return chars
end

local function encyclopedia_tower_doc_number_counts(text)
	local counts = {}
	local total = 0

	for number in string.gmatch(tostring(text or ""), "%d+%.?%d*") do
		counts[number] = (counts[number] or 0) + 1
		total = total + 1
	end

	return counts, total
end

local function encyclopedia_tower_doc_number_similarity(a, b)
	local ac, at = encyclopedia_tower_doc_number_counts(a)
	local bc, bt = encyclopedia_tower_doc_number_counts(b)

	if at == 0 or bt == 0 then
		return 0
	end

	local common = 0

	for number, count in pairs(ac) do
		common = common + math.min(count, bc[number] or 0)
	end

	return common / math.max(1, math.min(at, bt))
end

local function encyclopedia_tower_doc_similarity(a, b)
	local ac = encyclopedia_tower_doc_chars(a)
	local bc = encyclopedia_tower_doc_chars(b)

	if #ac == 0 or #bc == 0 then
		return 0
	end

	local counts = {}

	for _, ch in ipairs(ac) do
		counts[ch] = (counts[ch] or 0) + 1
	end

	local common = 0

	for _, ch in ipairs(bc) do
		local count = counts[ch]

		if count and count > 0 then
			common = common + 1
			counts[ch] = count - 1
		end
	end

	local char_score = common / math.max(1, math.min(#ac, #bc))
	local number_score = encyclopedia_tower_doc_number_similarity(a, b)

	if number_score > 0 then
		return char_score * 0.75 + number_score * 0.25
	end

	return char_score
end

local function encyclopedia_tower_doc_skill_texts(skill)
	local texts = {}

	if not skill then
		return texts
	end

	for _, key in ipairs({
		"standard",
		"enhanced"
	}) do
		if encyclopedia_text_has_copy(skill[key]) then
			table.insert(texts, skill[key])
		end
	end

	for _, key in ipairs({
		"levels_standard",
		"levels_enhanced"
	}) do
		if type(skill[key]) == "table" then
			for _, value in ipairs(skill[key]) do
				if encyclopedia_text_has_copy(value) then
					table.insert(texts, value)
				end
			end
		end
	end

	return texts
end

local function encyclopedia_tower_doc_skill_by_rank(entry, tower_name, power_name)
	local docs = encyclopedia_tower_docs()
	local ranks = docs and docs.skill_ranks
	local tower_ranks = tower_name and ranks and ranks[tower_name]
	local rank = tower_ranks and power_name and tower_ranks[power_name]

	return type(rank) == "number" and entry and entry.skills and entry.skills[rank] or nil
end

local function encyclopedia_tower_doc_skill(entry, title, desc, tower_name, power_name)
	if not entry or not entry.skills then
		return nil
	end

	if encyclopedia_tower_doc_mode() == "game" then
		return nil
	end

	local ranked_skill = encyclopedia_tower_doc_skill_by_rank(entry, tower_name, power_name)

	if ranked_skill then
		return ranked_skill
	end

	local normalized_title = encyclopedia_tower_doc_normalize(title)
	local best_skill, best_score, second_score

	if encyclopedia_text_has_copy(desc) or normalized_title ~= "" then
		best_score = 0
		second_score = 0

		for _, skill in ipairs(entry.skills) do
			local normalized_skill = encyclopedia_tower_doc_normalize(skill.name)
			local title_score = 0
			local desc_score = 0

			if normalized_title ~= "" and normalized_skill ~= "" then
				if normalized_title == normalized_skill then
					title_score = 1
				elseif string.find(normalized_title, normalized_skill, 1, true) or string.find(normalized_skill, normalized_title, 1, true) then
					title_score = 0.75
				else
					title_score = encyclopedia_tower_doc_similarity(normalized_title, normalized_skill)
				end
			end

			for _, doc_text in ipairs(encyclopedia_tower_doc_skill_texts(skill)) do
				desc_score = math.max(desc_score, encyclopedia_tower_doc_similarity(desc, doc_text))
			end

			local score = desc_score * 0.8 + title_score * 0.2

			if not encyclopedia_text_has_copy(desc) then
				score = title_score
			end

			if score > best_score then
				second_score = best_score
				best_score = score
				best_skill = skill
			elseif score > second_score then
				second_score = score
			end
		end

		if best_skill and best_score >= 0.35 then
			return best_skill
		end

		if best_skill and best_score >= 0.22 and best_score >= second_score + 0.05 then
			return best_skill
		end

		if best_skill and #entry.skills <= 3 and best_score >= 0.19 and best_score >= second_score + 0.04 then
			return best_skill
		end
	end

	return nil
end

local function encyclopedia_tower_power_level_count(item, power)
	local menu_count = item and item.tt_list and #item.tt_list or nil
	local power_count = power and power.max_level or nil
	local count = 1

	if item and not item.tt_list then
		return count
	end

	count = menu_count or (type(power_count) == "number" and power_count > 0 and power_count) or 1

	if menu_count and type(power_count) == "number" and power_count > 0 then
		count = math.min(menu_count, power_count)
	end

	return math.max(1, count)
end

local function tower_select_reload_balance_templates()
	E:load()
	UPGR:set_all_generation_levels(screen_map.user_data)
	DI:set_level(screen_map.user_data.difficulty)
	UPGR:patch_templates(5)
	DI:patch_templates()
end

local function encyclopedia_ensure_balance_flags()
	screen_map.user_data.liuhui = screen_map.user_data.liuhui or {}

	if screen_map.user_data.liuhui.balance == nil then
		screen_map.user_data.liuhui.balance = false
	end

	if screen_map.user_data.liuhui.g4range_balance == nil then
		screen_map.user_data.liuhui.g4range_balance = 1
	end
end

local function encyclopedia_tower_power_rows(dt, tower_name, power_name, power, prefer_menu_copy)
	local item = encyclopedia_tower_power_menu_item(dt, power_name, tower_name)
	local doc_entry = encyclopedia_tower_doc_entry(tower_name)
	local fallback_title = encyclopedia_power_fallback_title(dt, tower_name, power_name, power)
	local rows = {}

	local function add_row(texts, level)
		local title = texts and texts.tt_title or fallback_title
		local desc = texts and texts.tt_desc or ""
		local desc_has_cooldown = tower_power_display.desc_has_cooldown(desc)
		local match_desc = encyclopedia_tower_power_match_desc(desc)
		local previous_desc
		local next_desc
		local previous_desc_has_cooldown = false
		local next_desc_has_cooldown = false

		if not encyclopedia_text_has_copy(title) then
			title = encyclopedia_text_has_copy(fallback_title) and fallback_title or power_name
		end

		local doc_skill = not prefer_menu_copy and encyclopedia_tower_doc_skill(doc_entry, title, match_desc, tower_name, power_name) or nil

		if doc_skill then
			title = encyclopedia_text_has_copy(doc_skill.name) and doc_skill.name or title
			desc = encyclopedia_tower_doc_skill_desc(doc_skill, match_desc, level)
			previous_desc = encyclopedia_tower_doc_skill_previous_desc(doc_skill, level)
			next_desc = encyclopedia_tower_doc_skill_next_desc(doc_skill, level)
			desc_has_cooldown = tower_power_display.desc_has_cooldown(desc)
			previous_desc_has_cooldown = tower_power_display.desc_has_cooldown(previous_desc)
			next_desc_has_cooldown = tower_power_display.desc_has_cooldown(next_desc)
		elseif not prefer_menu_copy and doc_entry and encyclopedia_tower_doc_mode() ~= "game" then
			return
		else
			desc = match_desc
			desc_has_cooldown = desc_has_cooldown or tower_power_display.desc_has_cooldown(desc)

			if item and item.tt_list then
				local previous_texts = level > 1 and item.tt_list[level - 1] or nil
				local next_texts = level == 1 and item.tt_list[level + 1] or nil
				local previous_desc_source = previous_texts and previous_texts.tt_desc or ""
				local next_desc_source = next_texts and next_texts.tt_desc or ""

				previous_desc = previous_texts and encyclopedia_tower_power_match_desc(previous_desc_source) or ""
				next_desc = next_texts and encyclopedia_tower_power_match_desc(next_desc_source) or nil
				previous_desc_has_cooldown = tower_power_display.desc_has_cooldown(previous_desc_source) or tower_power_display.desc_has_cooldown(previous_desc)
				next_desc_has_cooldown = tower_power_display.desc_has_cooldown(next_desc_source) or tower_power_display.desc_has_cooldown(next_desc)
			end
		end

		if desc ~= "" then
			desc = GU.balance_format(desc, balance) or desc
		end

		if previous_desc and previous_desc ~= "" then
			previous_desc = GU.balance_format(previous_desc, balance) or previous_desc
		end

		if next_desc and next_desc ~= "" then
			next_desc = GU.balance_format(next_desc, balance) or next_desc
		end

		desc = tower_power_display.append_cooldown(desc, tower_name, power_name, power, level, desc_has_cooldown)
		previous_desc = tower_power_display.append_cooldown(previous_desc, tower_name, power_name, power, level - 1, previous_desc_has_cooldown)
		next_desc = tower_power_display.append_cooldown(next_desc, tower_name, power_name, power, level + 1, next_desc_has_cooldown)

		if kr6_tower_detail_names[tower_name] and power_name == "ultimate" and item and item.action == "tw_ultimate_info" and encyclopedia_text_has_copy(desc) then
			local unlock_note = "Đây là tuyệt kỹ, tự mở khi tháp đạt cấp 4."

			if not string.find(desc, unlock_note, 1, true) then
				desc = desc .. "\n" .. unlock_note
			end
		end

		if not encyclopedia_text_has_copy(desc) then
			return
		end

		local text_runs = level == 1 and tower_balance_highlight.next_upgrade_runs(desc, next_desc) or previous_desc ~= nil and tower_balance_highlight.upgrade_runs(previous_desc, desc) or nil

		table.insert(rows, {
			title = title,
			desc = tower_balance_highlight.runs_text(text_runs, desc),
			text_runs = text_runs,
			price = encyclopedia_tower_power_price(power, level),
			level = level
		})
	end

	if item and item.tt_list then
		local level_count = encyclopedia_tower_power_level_count(item, power)

		for level = 1, level_count do
			local texts = item.tt_list[level] or item.tt_list[#item.tt_list]

			add_row(texts, level)
		end
	elseif item then
		local level_count = encyclopedia_tower_power_level_count(item, power)

		for level = 1, level_count do
			add_row(item, level)
		end
	elseif power and (power.tt_title or power.tt_desc) then
		add_row({
			tt_title = power.tt_title and _(power.tt_title) or fallback_title,
			tt_desc = power.tt_desc and _(power.tt_desc) or ""
		}, 1)
	end

	return rows[1] and rows[1].title or nil, rows
end

local function screen_map_tower_data_index_by_name(tower_name)
	for i, data in ipairs(screen_map.tower_data or {}) do
		if data.name == tower_name then
			return i
		end
	end

	return nil
end

local function encyclopedia_tower_lvl4_source_name(tower_name)
	local level_4_name = string.gsub(tower_name or "", "_lvl[123]$", "_lvl4")

	return level_4_name
end

local function tower_select_lvl4_tower_name(selection_index)
	local item = map_data.tower_menu_json and map_data.tower_menu_json[selection_index]

	if not item then
		return nil
	end

	local build_template = item.action_arg and E.entities and E.entities[item.action_arg]
	local build_name = build_template and build_template.build_name

	if build_name then
		local level_4_name = string.gsub(build_name, "_lvl%d+$", "_lvl4")

		if level_4_name ~= build_name and E.entities and E.entities[level_4_name] then
			return level_4_name
		end

		if E.entities and E.entities[build_name] then
			return build_name
		end
	end

	if item.type then
		local level_4_name = "tower_" .. item.type .. "_lvl4"

		if E.entities and E.entities[level_4_name] then
			return level_4_name
		end
	end

	return nil
end

local function tower_select_detail_index(selection_index)
	local tower_name = tower_select_lvl4_tower_name(selection_index)

	if not tower_name then
		return nil
	end

	return screen_map_tower_data_index_by_name(tower_name)
end

local tower_select_legacy_regular_detail_indices = {
	53,
	57,
	33,
	37,
	13,
	17,
	54,
	58,
	34,
	38,
	14,
	18,
	55,
	59,
	35,
	39,
	15,
	19,
	56,
	60,
	36,
	40,
	16,
	20
}

local tower_select_kr6_advanced_names = {
	"tower_ranger_kr1",
	"tower_paladin_kr1",
	"tower_arcane_wizard_kr1",
	"tower_bfg_kr1",
	"tower_musketeer_kr1",
	"tower_barbarian_kr1",
	"tower_sorcerer_kr1",
	"tower_tesla_kr1"
}

local function tower_select_legacy_detail_indices()
	local indices = {}

	for _, detail_index in ipairs(tower_select_legacy_regular_detail_indices) do
		table.insert(indices, detail_index)
	end

	for _, tower_name in ipairs(tower_select_kr6_advanced_names) do
		local detail_index = screen_map_tower_data_index_by_name(tower_name)

		if detail_index then
			table.insert(indices, detail_index)
		end
	end

	return indices
end

local function screen_map_is_special_tower_entry(tower_entry)
	return tower_entry and tower_entry.generation ~= 6 and (tower_entry.icon or 0) >= 601
end

local function tower_select_special_detail_indices()
	local indices = {}

	for detail_index, tower_data in ipairs(screen_map.tower_data or {}) do
		if screen_map_is_special_tower_entry(tower_data) then
			table.insert(indices, detail_index)
		end
	end

	return indices
end

local function encyclopedia_hide_tower_power_popup(panel)
	if panel.power_popup then
		panel:remove_child(panel.power_popup)

		panel.power_popup = nil
	end
end

local function encyclopedia_show_tower_power_popup(panel, title, rows, show_balance_status)
	encyclopedia_hide_tower_power_popup(panel)

	if panel.order_to_front then
		panel:order_to_front()
	end

	local viewport = panel.parent and panel.parent.size or panel.size
	local popup_w = math.min(1800, viewport.x - 64)
	local popup_h = math.min(850, viewport.y - 64)
	local overlay = KView:new(V.v(viewport.x, viewport.y))

	-- Keep the popup owned by the detail panel, but lay it out against the full
	-- screen so the wide card also fits a 4:3 tablet viewport.
	overlay.pos = v(-panel.pos.x, -panel.pos.y)
	overlay.colors.background = {
		0,
		0,
		0,
		75
	}

	function overlay.on_click()
		S:queue("GUIButtonCommon")
		encyclopedia_hide_tower_power_popup(panel)
	end

	panel:add_child(overlay)
	panel.power_popup = overlay

	local frame = KView:new(V.v(popup_w, popup_h))

	frame.pos = v((viewport.x - popup_w) / 2, (viewport.y - popup_h) / 2)
	frame.colors.background = {
		89,
		61,
		34,
		245
	}
	frame.propagate_on_click = true
	overlay:add_child(frame)

	local card = KView:new(V.v(popup_w - 10, popup_h - 10))

	card.pos = v(5, 5)
	card.colors.background = {
		250,
		232,
		166,
		250
	}
	card.on_click = function()
	end
	frame:add_child(card)

	local close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")

	close_button.anchor = v(close_button.size.x / 2, close_button.size.y / 2)
	close_button.pos = v(card.size.x - 22, 22)

	function close_button.on_click()
		S:queue("GUIButtonCommon")
		encyclopedia_hide_tower_power_popup(panel)
	end

	card:add_child(close_button)

	local title_label = GGLabel:new(V.v(card.size.x - 90, 34))

	title_label.pos = v(card.size.x / 2, 18)
	title_label.anchor.x = title_label.size.x / 2
	title_label.font_name = "body"
	title_label.font_size = 30
	title_label.colors.text = {
		116,
		72,
		43,
		255
	}
	title_label.text = show_balance_status == false and title or string.format("%s (%s)", title or "", encyclopedia_tower_doc_status())
	title_label.text_align = "center"
	title_label.fit_lines = 1
	card:add_child(title_label)

	local content_y = 68
	local content_h = card.size.y - content_y - 20
	local list = KScrollList:new(V.v(card.size.x - 40, content_h))

	list.pos = v(20, content_y)
	list.scroll_amount = 48
	list.scroll_acceleration = 1.5
	list:set_scroller_size(20, 5)
	list.colors.scroller_background = {174, 139, 85, 100}
	list.colors.scroller_foreground = {116, 72, 43, 230}

	function list:on_touch_down(id, x, y)
		self.touch_scroll_id = id
		self.touch_scroll_y = y
	end

	function list:on_touch_move(id, x, y)
		if self.touch_scroll_id == id and self._bottom_y > self.size.y then
			self.scroll_origin_y = km.clamp(-(self._bottom_y - self.size.y), 0,
				self.scroll_origin_y + y - self.touch_scroll_y)
			self.touch_scroll_y = y
		end
	end

	function list:on_touch_up(id)
		if self.touch_scroll_id == id then
			self.touch_scroll_id = nil
		end
	end

	card:add_child(list)

	local row_w = list.size.x - 30
	local heading_w = math.min(270, math.max(185, math.floor(row_w * 0.22)))
	local desc_w = row_w - heading_w - 30

	for i, row in ipairs(rows) do
		local row_desc = GGLabel:new(V.v(desc_w, 1))

		row_desc.pos = v(heading_w + 16, 14)
		row_desc.font_name = "body"
		row_desc.font_size = popup_w < 1200 and 22 or 24
		row_desc.line_height = CJK(1, nil, 1.08, 1)
		row_desc.colors.text = {0, 0, 0, 255}
		row_desc.text = row.desc or ""
		row_desc.text_runs = row.text_runs
		row_desc.text_align = "left"

		local _, line_count = row_desc:get_wrap_lines()
		local row_h = math.max(120, math.ceil(math.max(1, line_count) * row_desc:get_font_height() * row_desc.line_height) + 34)
		local row_container = KView:new(V.v(row_w, row_h + 12))
		local row_panel = KView:new(V.v(row_w, row_h))

		row_panel.colors.background = i % 2 == 0 and {255, 245, 206, 235} or {255, 241, 188, 235}
		row_container:add_child(row_panel)
		list:add_row(row_container)

		local row_title = GGLabel:new(V.v(heading_w - 24, row.price and 58 or row_h - 24))

		row_title.pos = v(12, row.price and math.max(10, row_h / 2 - 52) or 12)
		row_title.font_name = "body"
		row_title.font_size = popup_w < 1200 and 23 or 26
		row_title.colors.text = {116, 72, 43, 255}
		row_title.text = not panel.hide_power_levels and row.level and string.format("%s (cấp %d)", row.title or "", row.level) or row.title or ""
		row_title.text_align = "center"
		row_title.vertical_align = "middle"
		row_title.fit_lines = 2
		row_panel:add_child(row_title)

		if row.price then
			local row_price = GGLabel:new(V.v(heading_w - 24, 32))

			row_price.pos = v(12, row_h / 2 + 10)
			row_price.font_name = "body"
			row_price.font_size = 24
			row_price.colors.text = {116, 72, 43, 255}
			row_price.text = tostring(row.price)
			row_price.text_align = "center"
			row_price.vertical_align = "middle"
			row_price.fit_lines = 1
			row_panel:add_child(row_price)
		end

		row_desc.size.y = row_h - 28
		row_desc.text_size.y = row_h - 28
		row_panel:add_child(row_desc)
	end
end

local tower_select_legacy_slot_hint_title = "Tháp phần 1–3 và tháp cổ điển được mang theo bộ"
local tower_select_legacy_slot_hint_text = "Tháp cao cấp phần 1/2/3, KR Conquest và Genesis phải nâng từ tháp cơ bản tương ứng, nên không đặt vào ô tháp độc lập phần 4/5/6 bên phải. Chọn các bộ muốn mang theo bằng năm biểu tượng phía dưới bên trái. Mỗi bộ được đánh dấu sẽ thêm bốn tháp cơ bản vào trang xây tháp đầu tiên trong trận."
local tower_select_special_slot_hint_text = "Tháp đặc biệt được xây trong màn tương ứng, qua menu mở rộng của tháp cơ bản hoặc tùy chọn tháp đặc biệt; không thêm vào bộ tháp thường phần 4/5. Trang này chỉ để xem thông tin, chỉ số và kỹ năng."
local tower_select_tutorial_required_title = "Hãy thiết lập bộ tháp trước"
local tower_select_tutorial_required_text = "Hãy thêm một tháp bất kỳ của phần 4/6 vào bộ tháp để tiếp tục. Nếu không thích dùng tháp phần 4/6, bạn có thể thay lại sau."

local function tower_select_hide_legacy_slot_hint(view)
	if view.legacy_slot_hint_popup and view.legacy_slot_hint_popup.parent then
		view.legacy_slot_hint_popup.parent:remove_child(view.legacy_slot_hint_popup)
	end

	view.legacy_slot_hint_popup = nil
end

local function tower_select_show_legacy_slot_hint(view, title_override, message_override, compact)
	tower_select_hide_legacy_slot_hint(view)

	local view_w = view.sw or view.size.x
	local view_h = view.sh or view.size.y
	local overlay = KView:new(V.v(view_w, view_h))

	overlay.pos = v(0, 0)
	overlay.colors.background = {
		0,
		0,
		0,
		75
	}

	function overlay.on_click()
		S:queue("GUIButtonCommon")
		tower_select_hide_legacy_slot_hint(view)
	end

	view.back:add_child(overlay)
	view.legacy_slot_hint_popup = overlay

	local popup_w = math.min(compact and 620 or 1360, view_w - 100)
	local popup_h = math.min(compact and 190 or 420, view_h - 100)
	local frame = KView:new(V.v(popup_w, popup_h))

	frame.pos = v((view_w - popup_w) / 2, (view_h - popup_h) / 2 - (compact and 0 or 10))
	frame.colors.background = {
		89,
		61,
		34,
		245
	}
	frame.propagate_on_click = true
	overlay:add_child(frame)

	local card = KView:new(V.v(popup_w - 10, popup_h - 10))

	card.pos = v(5, 5)
	card.colors.background = {
		250,
		232,
		166,
		250
	}
	card.on_click = function()
	end
	frame:add_child(card)

	local close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")

	close_button.anchor = v(close_button.size.x / 2, close_button.size.y / 2)
	close_button.pos = v(card.size.x - 22, 22)

	function close_button.on_click()
		S:queue("GUIButtonCommon")
		tower_select_hide_legacy_slot_hint(view)
	end

	card:add_child(close_button)

	local title_label = GGLabel:new(V.v(card.size.x - 110, compact and 38 or 42))

	title_label.pos = v(card.size.x / 2, compact and 20 or 24)
	title_label.anchor.x = title_label.size.x / 2
	title_label.font_name = "body"
	title_label.font_size = compact and 28 or 32
	title_label.colors.text = {
		116,
		72,
		43,
		255
	}
	title_label.text = title_override or tower_select_legacy_slot_hint_title
	title_label.text_align = "center"
	title_label.fit_lines = 1
	card:add_child(title_label)

	local message = GGLabel:new(V.v(card.size.x - (compact and 72 or 104), card.size.y - (compact and 82 or 112)))

	message.pos = v(compact and 36 or 52, compact and 66 or 84)
	message.font_name = "body"
	message.font_size = compact and 24 or 28
	message.line_height = CJK(0.95, nil, 1.1, 0.95)
	message.colors.text = {
		0,
		0,
		0,
		255
	}
	message.text = message_override or (view.tower_generation_tab == "special" and tower_select_special_slot_hint_text or tower_select_legacy_slot_hint_text)
	message.text_align = "left"
	message.vertical_align = "middle"
	message.fit_lines = compact and 2 or 7
	card:add_child(message)
end

local function encyclopedia_show_tower_mechanic_popup(panel, tower_name)
	local entry = encyclopedia_tower_doc_entry(tower_name)

	if not entry then
		return
	end

	local rows = {}
	local attack = encyclopedia_tower_doc_text(entry.attack, entry.attack and entry.attack.standard or "")

	if encyclopedia_text_has_copy(attack) then
		table.insert(rows, {
			title = "Cách tấn công",
			desc = attack
		})
	end

	if encyclopedia_tower_doc_mode() == "enhanced" and encyclopedia_text_has_copy(entry.change_note) then
		table.insert(rows, {
			title = "Thay đổi cân bằng",
			desc = entry.change_note
		})
	end

	if encyclopedia_text_has_copy(entry.port_note) then
		table.insert(rows, {
			title = "Ghi chú chuyển thể",
			desc = entry.port_note
		})
	end

	if #rows == 0 then
		return
	end

	encyclopedia_show_tower_power_popup(panel, string.format("%s: cơ chế và hướng dẫn", entry.title or ""), rows)
end

local function encyclopedia_add_tower_mechanic_button(panel, tower_name)
	if not encyclopedia_tower_doc_entry(tower_name) then
		return
	end

	local button = KView:new(V.v(150, 30))

	button.anchor = v(button.size.x / 2, button.size.y / 2)
	button.pos = v(300, 576)
	button.colors.background = {
		90,
		58,
		30,
		230
	}
	button.propagate_on_click = true

	local inner = KView:new(V.v(button.size.x - 4, button.size.y - 4))

	inner.pos = v(2, 2)
	inner.colors.background = {
		233,
		205,
		123,
		245
	}
	inner.propagate_on_click = true
	button:add_child(inner)

	local label = GGLabel:new(V.v(inner.size.x, inner.size.y))

	label.font_name = "body"
	label.font_size = 16
	label.colors.text = {
		68,
		46,
		24,
		255
	}
	label.text = "Cơ chế tháp"
	label.text_align = "center"
	label.vertical_align = "middle"
	label.text_offset.y = CJK(0, -2, 0, 0)
	label.fit_lines = 1
	inner:add_child(label)

	function button.on_click()
		S:queue("GUIButtonCommon")
		encyclopedia_show_tower_mechanic_popup(panel, tower_name)
	end

	inner.on_click = button.on_click
	label.on_click = button.on_click

	panel:add_child(button)
end

local function encyclopedia_add_special_tower_build_button(panel, tower_entry)
	local tower_name = tower_entry and tower_entry.name
	local build_note = tower_name and special_tower_encyclopedia.build_notes[tower_name]

	if not encyclopedia_text_has_copy(build_note) then
		return
	end

	local button = KView:new(V.v(150, 30))

	button.anchor = v(button.size.x / 2, button.size.y / 2)
	button.pos = v(300, 576)
	button.colors.background = {
		90,
		58,
		30,
		230
	}
	button.propagate_on_click = true

	local inner = KView:new(V.v(button.size.x - 4, button.size.y - 4))

	inner.pos = v(2, 2)
	inner.colors.background = {
		233,
		205,
		123,
		245
	}
	inner.propagate_on_click = true
	button:add_child(inner)

	local label = GGLabel:new(V.v(inner.size.x, inner.size.y))

	label.font_name = "body"
	label.font_size = 16
	label.colors.text = {
		68,
		46,
		24,
		255
	}
	label.text = "Cách xây tháp"
	label.text_align = "center"
	label.vertical_align = "middle"
	label.text_offset.y = CJK(0, -2, 0, 0)
	label.fit_lines = 1
	inner:add_child(label)

	local function show_build_note()
		S:queue("GUIButtonCommon")
		local display_name = encyclopedia_tower_entry_display_name(tower_entry, tower_name)

		encyclopedia_show_tower_power_popup(panel, string.format("%s: cách xây dựng", display_name), {
			{
				title = "Cách xây",
				desc = build_note
			}
		}, false)
	end

	button.on_click = show_build_note
	inner.on_click = show_build_note
	label.on_click = show_build_note

	panel:add_child(button)
end

local function tower_select_add_quick_balance_buttons(view, detail_index)
	local panel = view.right_panel

	if not panel then
		return
	end

	encyclopedia_ensure_balance_flags()

	local function make_button(x, label_text, on_click)
		local button = KView:new(V.v(140, 30))

		button.anchor = v(button.size.x / 2, button.size.y / 2)
		button.pos = v(x, 576)
		button.colors.background = {
			90,
			58,
			30,
			230
		}
		button.propagate_on_click = true

		local inner = KView:new(V.v(button.size.x - 4, button.size.y - 4))

		inner.pos = v(2, 2)
		inner.colors.background = {
			233,
			205,
			123,
			245
		}
		inner.propagate_on_click = true
		button:add_child(inner)

		local label = GGLabel:new(V.v(inner.size.x, inner.size.y))

		label.font_name = "body"
		label.font_size = 16
		label.colors.text = {
			68,
			46,
			24,
			255
		}
		label.text = label_text
		label.text_align = "center"
		label.vertical_align = "middle"
		label.text_offset.y = CJK(0, -2, 0, 0)
		label.fit_lines = 1
		inner:add_child(label)
		button.on_click = on_click
		inner.on_click = on_click
		label.on_click = on_click
		panel:add_child(button)
	end

	make_button(155, screen_map.user_data.liuhui.balance and "Tăng cường: bật" or "Tăng cường: tắt", function()
		screen_map.user_data.liuhui.balance = not screen_map.user_data.liuhui.balance
		storage:save_slot(screen_map.user_data)
		tower_select_reload_balance_templates()
		view:detail_tower(detail_index)
		S:queue("GUIButtonCommon")
	end)

	make_button(445, screen_map.user_data.liuhui.g4range_balance and "Tầm phần 4: bật" or "Tầm phần 4: tắt", function()
		screen_map.user_data.liuhui.g4range_balance = not screen_map.user_data.liuhui.g4range_balance
		storage:save_slot(screen_map.user_data)
		tower_select_reload_balance_templates()
		view:detail_tower(detail_index)
		S:queue("GUIButtonCommon")
	end)
end

local function encyclopedia_add_tower_power_icons(panel, dt, tower_name, power_names, total_width, prefer_menu_data, icon_scale_factor)
	if #power_names == 0 then
		return 0
	end

	local tw = total_width or 360
	local scale_factor = icon_scale_factor or 1
	local entries = {}

	for i, power_name in ipairs(power_names) do
		local power = dt.powers and dt.powers[power_name] or {}
		local title, rows = encyclopedia_tower_power_rows(dt, tower_name, power_name, power, prefer_menu_data)
		local menu_item = encyclopedia_tower_power_menu_item(dt, power_name, tower_name)
		local encyclopedia_icon = power and power.enc_icon and string.format("encyclopedia_tower_specials_%04i", power.enc_icon)
		local power_icon = power and power.icon_name
		local mapped_menu_icon = menu_item and special_tower_power_icons[menu_item.image]
		local menu_icon = prefer_menu_data and mapped_menu_icon
		local icon_name = menu_icon or mapped_menu_icon or power_icon or encyclopedia_icon or menu_item and menu_item.image

		if kr6_tower_detail_names[tower_name] and icon_name and string.match(icon_name, "^quickmenu_special_icons_.+_000[1-4]$") then
			icon_name = "kr6_encyclopedia_" .. icon_name
		end

		if title and #rows > 0 and icon_name then
			table.insert(entries, {
				power_name = power_name,
				power = power,
				icon_name = icon_name,
				uses_mapped_menu_icon = icon_name == mapped_menu_icon,
				title = title,
				rows = rows
			})
		end
	end

	if #entries == 0 then
		return 0
	end

	local iw = math.ceil(tw / #entries)

	for i, entry in ipairs(entries) do
		local power = entry.power
		local px = 120 + (2 * i - 1) * iw / 2
		local icon = KButton:new()

		icon:set_image(entry.icon_name)
		icon.pos = v(px, 515)
		icon.anchor = v(icon.size.x / 2, icon.size.y / 2)

		local icon_scale = scale_factor

		if prefer_menu_data or entry.uses_mapped_menu_icon then
			icon_scale = math.min(42 / icon.size.x, 42 / icon.size.y, 1) * scale_factor
		end

		icon.scale = v(icon_scale, icon_scale)

		function icon.on_click()
			S:queue("GUIButtonCommon")

			encyclopedia_show_tower_power_popup(panel, entry.title, entry.rows)
		end

		panel:add_child(icon)

		local label = GGLabel:new(V.v(tw / #entries, 50))

		label.pos = v(px, 535)
		label.anchor = v(label.size.x / 2, 0)
		label.font_name = "body"
		label.font_size = 14
		label.line_height = 0.85
		label.colors.text = {
			0,
			0,
			0
		}
		label.text = entry.title
		label.text_align = "center"
		label.fit_lines = 2

		panel:add_child(label)
	end

	return #entries
end

local function tower_stat_level_path(base_name)
	return {
		base_name .. "_1",
		base_name .. "_2",
		base_name .. "_3"
	}
end

local tower_stat_legacy_price_paths = {
	tower_arcane = tower_stat_level_path("tower_archer"),
	tower_silver = tower_stat_level_path("tower_archer"),
	tower_blade = tower_stat_level_path("tower_barrack"),
	tower_forest = tower_stat_level_path("tower_barrack"),
	tower_wild_magus = tower_stat_level_path("tower_mage"),
	tower_high_elven = tower_stat_level_path("tower_mage"),
	tower_druid = tower_stat_level_path("tower_rock_thrower"),
	tower_entwood = tower_stat_level_path("tower_rock_thrower"),
	tower_crossbow = tower_stat_level_path("g2_tower_archer"),
	tower_totem = tower_stat_level_path("g2_tower_archer"),
	tower_assassin = tower_stat_level_path("g2_tower_barrack"),
	tower_templar = tower_stat_level_path("g2_tower_barrack"),
	tower_archmage = tower_stat_level_path("g2_tower_mage"),
	tower_necromancer = tower_stat_level_path("g2_tower_mage"),
	tower_dwaarp = tower_stat_level_path("g2_tower_engineer"),
	tower_mech = tower_stat_level_path("g2_tower_engineer"),
	tower_ranger = tower_stat_level_path("g1_tower_archer"),
	tower_musketeer = tower_stat_level_path("g1_tower_archer"),
	tower_paladin = tower_stat_level_path("g1_tower_barrack"),
	tower_barbarian = tower_stat_level_path("g1_tower_barrack"),
	tower_arcane_wizard = tower_stat_level_path("g1_tower_mage"),
	tower_sorcerer = tower_stat_level_path("g1_tower_mage"),
	tower_bfg = tower_stat_level_path("g1_tower_engineer"),
	tower_tesla = tower_stat_level_path("g1_tower_engineer")
}

local function tower_stat_template_price(template_name)
	local template = E:get_template(template_name)

	return template and template.tower and template.tower.price
end

local function tower_stat_full_power_price(power)
	if type(power) ~= "table" then
		return 0
	end

	local max_level = math.max(0, math.floor(tonumber(power.max_level) or 0))
	local price_base = tonumber(power.price_base)

	if max_level == 0 or not price_base then
		return 0
	end

	local price_inc = tonumber(power.price_inc) or price_base

	return price_base + math.max(0, max_level - 1) * price_inc
end

local function tower_stat_full_power_total(dt)
	local total = 0

	if dt and type(dt.powers) == "table" then
		for _, power in pairs(dt.powers) do
			total = total + tower_stat_full_power_price(power)
		end
	end

	return total
end

local function tower_stat_price(tower_name, dt, mode)
	if mode == "total" then
		local base_name = string.match(tower_name or "", "^(.*)_lvl%d+$")

		if base_name then
			local total = 0
			local found_level = false

			for level = 1, 4 do
				local level_template = E:get_template(string.format("%s_lvl%i", base_name, level))

				if level_template and level_template.tower and level_template.tower.price then
					total = total + level_template.tower.price
					found_level = true
				end
			end

			if found_level then
				return math.floor(total + tower_stat_full_power_total(dt) + 0.5)
			end
		end

		local legacy_path = tower_stat_legacy_price_paths[tower_name]

		if legacy_path then
			local total = dt and dt.tower and dt.tower.price or tower_stat_template_price(tower_name) or 0
			local found_price = total > 0

			for _, level_template_name in ipairs(legacy_path) do
				local price = tower_stat_template_price(level_template_name)

				if price then
					total = total + price
					found_price = true
				end
			end

			if found_price then
				return math.floor(total + tower_stat_full_power_total(dt) + 0.5)
			end
		end

		if dt and dt.tower and dt.tower.price then
			return math.floor(dt.tower.price + tower_stat_full_power_total(dt) + 0.5)
		end
	end

	if dt and dt.tower and dt.tower.price then
		return math.floor(dt.tower.price + 0.5)
	end

	return nil
end

local function tower_stat_round(value)
	return value and math.floor(value + 0.5) or nil
end

local function encyclopedia_tower_stat_text(stat_name, tower_name, dt, di, price_mode)
	if stat_name == "health" then
		return di.hp_max and tostring(di.hp_max) or ""
	elseif stat_name == "armor" then
		return di.armor and string.format(_("%i%%"), di.armor * 100) .. "" .. GU.armor_value_desc(di.armor) or ""
	elseif stat_name == "dmg" or stat_name == "mdmg" then
		return di.damage_min and di.damage_max and di.damage_min .. "-" .. di.damage_max or ""
	elseif stat_name == "respawn" then
		return di.respawn and string.format(_("%i sec."), di.respawn) or ""
	elseif stat_name == "reload" then
		return di.cooldown and string.format(_("%s sec"), di.cooldown * 1) .. " / " .. GU.cooldown_value_desc(di.cooldown) or ""
	elseif stat_name == "range" then
		return di.range and string.format(_("%i"), tower_stat_round(di.range * 2)) .. " / " .. GU.range_value_desc(di.range) or ""
	elseif stat_name == "rally" then
		local rally_range = dt and dt.barrack and dt.barrack.rally_range

		return rally_range and string.format(_("%i"), tower_stat_round(rally_range * 2)) .. " / " .. GU.range_value_desc(rally_range) or ""
	elseif stat_name == "price" then
		local price = tower_stat_price(tower_name, dt, price_mode)

		return price and tostring(price) or ""
	end

	return ""
end

local function encyclopedia_add_tower_stat_icons(panel, tower_name, dt, di, price_mode)
	local icons_list = {
		reload = 5,
		armor = 2,
		range = 6,
		health = 1,
		respawn = 4,
		dmg = 3,
		mdmg = 7,
		rally = 6
	}
	local stats_list

	if di.type == STATS_TYPE_TOWER_BARRACK then
		stats_list = {
			"health",
			"dmg",
			"armor",
			"respawn",
			"rally",
			"price"
		}
	elseif di.type == STATS_TYPE_TOWER_MAGE then
		stats_list = {
			"mdmg",
			"reload",
			"range",
			"price"
		}
	else
		stats_list = {
			"dmg",
			"reload",
			"range",
			"price"
		}
	end

	local visible_stats = {}

	for _, stat_name in ipairs(stats_list) do
		local text = encyclopedia_tower_stat_text(stat_name, tower_name, dt, di, price_mode)

		if text ~= "" then
			table.insert(visible_stats, {
				name = stat_name,
				text = text
			})
		end
	end

	local mx = 200
	local my = #stats_list > 4 and 360 or 380

	for i, stat in ipairs(visible_stats) do
		local stat_name = stat.name
		local icon

		if stat_name == "price" then
			icon = KImageView:new("heroroom_tooltip_coin")
			icon.scale = V.v(1.35, 1.35)
		else
			icon = KImageView:new("encyclopedia_icons_" .. string.format("%04i", icons_list[stat_name]))
		end

		icon.pos = V.v(mx, my)
		icon.anchor = V.v(icon.size.x / 2, icon.size.y / 2)

		panel:add_child(icon)

		local lwidth = #visible_stats == 3 and i == 3 and 180 or 85
		local label = GGLabel:new(V.v(lwidth, 25))

		label.pos = V.v(mx + 20, my - 10)
		label.font_name = "body"
		label.font_size = 15
		label.text_align = "left"
		label.vertical_align = "middle"
		label.line_height = 0.75
		label.text = stat.text
		label.fit_lines = 2

		panel:add_child(label)

		mx = mx + 125

		if mx > 400 then
			mx = 200
			my = my + 40
		end
	end
end

EncyclopediaView = class("EncyclopediaView", PopUpView)

function EncyclopediaView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))

	self.back = KView:new(V.v(sw, sh))
	self.back.pos = v(0, 0)
	self.back.anchor = v(sw / 2, sh / 2)

	self:add_child(self.back)

	self.back.alpha = 0

	local hf = sw / 2 - 700

	self.hf = hf
	self.tower_button = KImageButton:new("encyclopedia_buttons_notxt_0002", "encyclopedia_buttons_notxt_0003", "encyclopedia_buttons_notxt_0003")
	self.tower_button.pos = v(hf + 300, 100)

	self.back:add_child(self.tower_button)

	self.tower_button.hidden = true

	function self.tower_button.on_click()
		S:queue("GUIButtonCommon")

		self.enemies_button.hidden = false
		self.enemies_selected.hidden = true
		self.tower_selected.hidden = false
		self.tower_button.hidden = true

		self:load_towers(1)
	end

	local tl = EncyclopediaTabLabel:new(_("Towers"), false)

	tl.pos.x, tl.pos.y = 56, 86

	self.tower_button:add_child(tl)

	self.tower_selected = KImageView:new("encyclopedia_buttons_notxt_0001")
	self.tower_selected.pos = v(hf + 300, 100)

	self.back:add_child(self.tower_selected)

	local tl = EncyclopediaTabLabel:new(_("Towers"), true)

	tl.pos.x, tl.pos.y = 56, ISW(81, "zh-Hans", 81)

	self.tower_selected:add_child(tl)

	self.enemies_button = KImageButton:new("encyclopedia_buttons_notxt_0005", "encyclopedia_buttons_notxt_0006", "encyclopedia_buttons_notxt_0006")
	self.enemies_button.pos = v(hf + 400, 90)

	self.back:add_child(self.enemies_button)

	function self.enemies_button.on_click()
		S:queue("GUIButtonCommon")

		self.enemies_button.hidden = true
		self.enemies_selected.hidden = false
		self.tower_selected.hidden = true
		self.tower_button.hidden = false

		self:load_creeps(1)

		if self.right_panel then
			self.back:remove_child(self.right_panel)

			self.right_panel = nil
		end

		self:detail_creep(1)
	end

	local tl = EncyclopediaTabLabel:new(_("Enemies"), false, 2 * math.pi / 180)

	tl.pos.x, tl.pos.y = 56, ISW(88, "zh-Hans", 90)

	self.enemies_button:add_child(tl)

	self.enemies_selected = KImageView:new("encyclopedia_buttons_notxt_0004")
	self.enemies_selected.pos = v(hf + 400, 90)

	self.back:add_child(self.enemies_selected)

	self.enemies_selected.hidden = true

	local tl = EncyclopediaTabLabel:new(_("Enemies"), true, 2 * math.pi / 180)

	tl.pos.x, tl.pos.y = 56, 81

	self.enemies_selected:add_child(tl)

	self.backback = KImageView:new("encyclopedia_bg")
	self.backback.anchor = v(self.backback.size.x / 2, self.backback.size.y / 2)
	self.backback.pos = v(sw / 2, sh / 2)

	self.back:add_child(self.backback)

	local close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")

	close_button.pos = v(self.backback.size.x - 52, 16)
	self.close_button = close_button

	self.backback:add_child(close_button)

	function self.close_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end
end

function EncyclopediaView:show()
	EncyclopediaView.super.show(self)

	local user_data = storage:load_slot()

	E:load()
	UPGR:set_all_generation_levels(user_data)
	DI:set_level(screen_map.user_data.difficulty)
	UPGR:patch_templates(5)
	DI:patch_templates()
	self:load_towers(1)

	self.enemies_button.hidden = false
	self.enemies_selected.hidden = true
	self.tower_selected.hidden = false
	self.tower_button.hidden = true
end

function EncyclopediaView:hide_tower_power_popup()
	if self.right_panel and self.right_panel.power_popup then
		encyclopedia_hide_tower_power_popup(self.right_panel)

		return true
	end

	return false
end

function EncyclopediaView:load_towers(index)
	if self.towers then
		self.back:remove_child(self.towers)
	end
	if self.creep then
		self.creep.hidden = true
	end

	self.towers = KView:new(V.v(366, 444))
	self.towers.pos = v(self.hf + 310, 200)

	self.back:add_child(self.towers)

	local title = GGLabel:new(V.v(self.towers.size.x, 70))

	title.pos.y = 32
	title.font_name = "h_book"
	title.font_size = 40
	title.font_align = "center"
	title.colors.text = {
		100,
		89,
		51,
		255
	}
	title.text = _("Towers")

	self.towers:add_child(title)

	local title_w = title:get_text_width(title.text)
	local deco_y = 60
	local left_deco = KImageView:new("encyclopedia_rightArt")

	left_deco.pos = v(self.towers.size.x / 2 - title_w / 2 - 10, deco_y)
	left_deco.anchor = v(left_deco.size.x, left_deco.size.y / 2)

	self.towers:add_child(left_deco)

	local right_deco = KImageView:new("encyclopedia_rightArt")

	right_deco.pos = v(self.towers.size.x / 2 + title_w / 2 + 13, deco_y)
	right_deco.anchor = v(right_deco.size.x, right_deco.size.y / 2)
	right_deco.scale.x = -1

	self.towers:add_child(right_deco)

	local st1 = GGLabel:new(V.v(self.towers.size.x, 24))

	st1.pos.y = 88
	st1.font_name = "body"
	st1.font_size = 15
	st1.font_align = "center"
	st1.colors.text = {
		100,
		89,
		51,
		255
	}
	st1.text = _("Basic")

	if index <= 4 then
		self.towers:add_child(st1)
	end

	local st2 = GGLabel:new(V.v(self.towers.size.x, 24))

	st2.pos.y = 363
	st2.font_name = "body"
	st2.font_size = 15
	st2.font_align = "center"
	st2.colors.text = {
		100,
		89,
		51,
		255
	}
	st2.text = _("Advanced")

	if index <= 4 then
		self.towers:add_child(st2)
	end
	local legacy_count = #kr6_tower_integration.legacy_encyclopedia_towers
	local legacy_start = #screen_map.tower_data - legacy_count + 1
	local page_start = index == 4 and legacy_start or index > 4 and (index - 2) * 20 + 1 or (index - 1) * 20 + 1
	local page_end = index == 4 and #screen_map.tower_data or index > 4 and legacy_start - 1 or #screen_map.tower_data
	local page_count = math.max(0, math.min(20, page_end - page_start + 1))
	for i = 1, page_count do
		local num = page_start + i - 1
		local tower_entry = screen_map.tower_data[num]
		local icon_idx = tower_entry.icon or num
		local icon = tower_entry.generation == 6 and string.format(GS.encyclopedia_tower_fmt, icon_idx) or string.format(GS.encyclopedia_tower_thumb_fmt, icon_idx)
		local off_y = (i <= 12 or index >= 5) and 150 or 170
		self:create_tower(icon, v(math.fmod(i - 1, 4) * 88 + 50, math.floor((i - 1) / 4) * 85 + off_y), num, true)
	end

	self.over_sprite = KImageView:new("encyclopedia_tower_thumbs_0022")
	self.over_sprite.hidden = true
	self.over_sprite.anchor = v(self.over_sprite.size.x / 2, self.over_sprite.size.y / 2)
	self.over_sprite.propagate_on_click = true
	self.towers:add_child(self.over_sprite)

	self.select_sprite = KImageView:new("encyclopedia_tower_thumbs_0023")
	self.select_sprite.anchor = v(self.select_sprite.size.x / 2, self.select_sprite.size.y / 2)
	self.select_sprite.pos = v(50, 150)
	self.select_sprite.hidden = false
	self.towers:add_child(self.select_sprite)

	self.page_buttons = {}
	local total_pages = math.ceil(#screen_map.tower_data / 20)

	for i = 1, total_pages do
		local btn = EncyclopediaPageButton:new(i, i == index)

		layout_encyclopedia_page_button(btn, i, total_pages, self.towers.size.x, 572, 570)

		if i ~= index then
			function btn.on_click(this)
				S:queue("GUIButtonCommon")
				self:load_towers(this.page_idx)
			end
		end

		self.towers:add_child(btn)
		table.insert(self.page_buttons, btn)
	end

	if page_count > 0 then
		self:detail_tower(page_start)
	end
end

local function tower_encyclopedia_icon_scale(tower)
	return math.min(64 / tower.size.x, 64 / tower.size.y, 1)
end

--information就是num
function EncyclopediaView:create_tower(icon, pos, information, enabled)
	--if information <= 4 or screen_map.user_data.seen[screen_map.tower_data[information].name] then
		local tower = KButton:new()

		tower:set_image(icon)

		tower.anchor = v(tower.size.x / 2, tower.size.y / 2)
		tower.pos = pos

		local tower_entry = screen_map.tower_data[information]

		if tower_entry.generation == 6 then
			local icon_scale = tower_encyclopedia_icon_scale(tower)

			tower.scale = v(icon_scale, icon_scale)
		elseif screen_map_is_special_tower_entry(tower_entry) then
			tower.scale = v(0.8, 0.8)
		end

		self.towers:add_child(tower)
		function tower.on_enter()
			self:update_over_sprite(tower.pos)
		end

		function tower.on_exit()
			self:remove_over_sprite()
		end

		function tower.on_click()
			S:queue("GUINotificationPaperOver")
			self:tower_clicked(information, pos)
		end
	--else
	--	local tower = KImageView:new("encyclopedia_tower_thumbs_0021")

	--	tower.anchor = v(tower.size.x / 2, tower.size.y / 2)
	--	tower.pos = pos

	--	self.towers:add_child(tower)
	--end
end

function EncyclopediaView:update_over_sprite(pos)
	self.over_sprite.hidden = false
	self.over_sprite.pos = pos
end

function EncyclopediaView:remove_over_sprite()
	self.over_sprite.hidden = true
end

function EncyclopediaView:tower_clicked(information, pos)
	self.select_sprite.hidden = false
	self.select_sprite.pos = pos
	self.information = information

	self:detail_tower(information)
end

function EncyclopediaView:detail_tower(index)
	if self.right_panel then
		self.back:remove_child(self.right_panel)

		self.right_panel = nil
	end

	self.right_panel = KView:new(V.v(600, 700))
	self.right_panel.pos = v(self.sw / 2 - 30, 200)
	self.right_panel.propagate_on_click = true

	self.back:add_child(self.right_panel)

	local tower_entry = screen_map.tower_data[index]
	local tower_name = tower_entry.name
	local advanced_skills = kr6_tower_integration.legacy_advanced_skills[tower_name]
	local is_special_encyclopedia_tower = screen_map_is_special_tower_entry(tower_entry)
	local dt = encyclopedia_tower_entity(tower_entry, tower_name)

	if not dt then
		return
	end

	local power_tower_name = encyclopedia_tower_lvl4_source_name(tower_name)
	local power_dt = power_tower_name ~= tower_name and encyclopedia_tower_entity(tower_entry, power_tower_name) or dt

	if not power_dt then
		power_tower_name = tower_name
		power_dt = dt
	end

	local di = dt.info and dt.info.fn and dt.info.fn(dt) or {
		type = STATS_TYPE_TOWER
	}
	local title_label = GGLabel:new(V.v(280, 50))

	title_label.pos = v(300, 44)
	title_label.anchor.x = title_label.size.x / 2
	title_label.font_name = "h_book"
	title_label.font_size = 22
	title_label.colors.text = {
		148,
		94,
		58
	}
	local info_key = dt.info and dt.info.i18n_key or tower_name
	local localized_name = encyclopedia_tower_entry_display_name(tower_entry)

	if not encyclopedia_text_has_copy(localized_name) then
		localized_name = _(string.upper(info_key) .. "_NAME")
	end

	if not encyclopedia_text_has_copy(localized_name) then
		localized_name = tower_name
	end

	title_label.text = localized_name
	title_label.text_align = "center"
	title_label.fit_lines = 1

	local title_width, _w = title_label:get_wrap_lines()

	self.right_panel:add_child(title_label)

	local left_decoration = KImageView:new("encyclopedia_rightArt")

	left_decoration.pos = v(300 - title_width / 2 - 10, 60)
	left_decoration.anchor = v(left_decoration.size.x, left_decoration.size.y / 2)
	left_decoration.scale.x = 0.7

	self.right_panel:add_child(left_decoration)

	local right_decoration = KImageView:new("encyclopedia_rightArt")

	right_decoration.pos = v(300 + title_width / 2 + 10, 60)
	right_decoration.anchor = v(left_decoration.size.x, right_decoration.size.y / 2)
	right_decoration.scale.x = -0.7

	self.right_panel:add_child(right_decoration)

	local portrait = KImageView:new(string.format(GS.encyclopedia_tower_fmt, screen_map.tower_data[index].icon or index))

	portrait.anchor = v(portrait.size.x / 2, portrait.size.y / 2)
	portrait.pos = v(300, 175)
	portrait.scale = v(0.7, 0.708)

	self.right_panel:add_child(portrait)

	local over_portrait = KImageView:new("encyclopedia_frame")

	over_portrait.anchor = v(over_portrait.size.x / 2, over_portrait.size.y / 2)
	over_portrait.pos = v(300, 175)

	self.right_panel:add_child(over_portrait)

	local desc_label = GGLabel:new(V.v(330, 50))

	desc_label.pos = v(300, 280)
	desc_label.anchor = v(165, 0)
	desc_label.font_name = "body"
	desc_label.font_size = 16
	desc_label.line_height = CJK(0.85, nil, 1.1, 0.9)
	desc_label.colors.text = {
		0,
		0,
		0
	}
	local description_override = is_special_encyclopedia_tower and special_tower_encyclopedia.description_overrides[tower_name]
	local localized_desc = encyclopedia_text_has_copy(description_override) and description_override or _(string.upper(info_key) .. "_DESCRIPTION")

	if not encyclopedia_text_has_copy(localized_desc) then
		localized_desc = tower_entry.description or ""
	end

	if not encyclopedia_text_has_copy(localized_desc) and is_special_encyclopedia_tower then
		localized_desc = encyclopedia_special_tower_fallback_description(tower_name, dt)
	end

	desc_label.text = localized_desc
	desc_label.text_align = "center"
	desc_label.fit_lines = 4

	self.right_panel:add_child(desc_label)

	local frame = KImageView:new("encyclopedia_rightPages_0001")

	frame.anchor = v(frame.size.x / 2, 0)
	frame.pos = v(305, 352)

	self.right_panel:add_child(frame)

	encyclopedia_add_tower_stat_icons(self.right_panel, tower_name, dt, di, "level")

	local show_tower_powers

	if tower_entry.generation == 6 then
		show_tower_powers = string.match(tower_name, "_lvl4$") ~= nil or advanced_skills ~= nil
	else
		show_tower_powers = is_special_encyclopedia_tower or index <= 60 or power_tower_name ~= tower_name or index % 4 == 0
	end

	if show_tower_powers and (power_dt.powers or advanced_skills) then
		local specials = GGLabel:new(V.v(190, 26))

		specials.pos = v(300, 462)
		specials.anchor.x = specials.size.x / 2
		specials.text = _("Specials")
		specials.font_name = "h_book"
		specials.font_size = 20
		specials.text_align = "center"
		specials.colors.text = {
			116,
			105,
			66,
			255
		}
		specials.fit_lines = 1

		self.right_panel:add_child(specials)

		local title_w = specials:get_text_width(specials.text)
		local left_deco = KImageView:new("encyclopedia_rightArt")

		left_deco.pos = v(self.right_panel.size.x / 2 - title_w / 2 - 10, specials.pos.y + 16)
		left_deco.anchor = v(left_deco.size.x, left_deco.size.y / 2)
		left_deco.alpha = 0.6
		left_deco.scale.x = 0.7

		self.right_panel:add_child(left_deco)

		local right_deco = KImageView:new("encyclopedia_rightArt")

		right_deco.pos = v(self.right_panel.size.x / 2 + title_w / 2 + 13, specials.pos.y + 16)
		right_deco.anchor = v(right_deco.size.x, right_deco.size.y / 2)
		right_deco.alpha = 0.6
		right_deco.scale.x = -0.7

		self.right_panel:add_child(right_deco)

		local power_names = {}

		if advanced_skills then
			for _, power_name in ipairs(advanced_skills.powers) do
				table.insert(power_names, power_name)
			end
		else
			for power_name in pairs(power_dt.powers) do
				table.insert(power_names, power_name)
			end

			table.sort(power_names)
		end

		local tw = 360
		local power_count = encyclopedia_add_tower_power_icons(self.right_panel, power_dt, power_tower_name, power_names, tw, is_special_encyclopedia_tower, advanced_skills and 0.6 or nil)

		if power_count == 0 then
			specials.hidden = true
			left_deco.hidden = true
			right_deco.hidden = true
		end
	end

	if is_special_encyclopedia_tower then
		encyclopedia_add_special_tower_build_button(self.right_panel, tower_entry)
	else
		encyclopedia_add_tower_mechanic_button(self.right_panel, power_tower_name)
	end

	tower_select_add_quick_balance_buttons(self, index)
end

function EncyclopediaView:load_creeps(index)
	if self.creep then
		self.back:remove_child(self.creep)
	end

	if self.towers then
		self.towers.hidden = true
		self.select_sprite.hidden = true
	end

	self.creep = KView:new(V.v(372, 444))
	self.creep.pos = v(self.hf + 310, 200)

	self.back:add_child(self.creep)

	self.over_sprite = KImageView:new("encyclopedia_creep_thumbs_over")
	self.select_sprite2 = KImageView:new("encyclopedia_creep_thumbs_selected")

	local title = GGLabel:new(V.v(self.creep.size.x, 70))

	title.pos.y = 32
	title.font_name = "h_book"
	title.font_size = 40
	title.font_align = "center"
	title.colors.text = {
		100,
		89,
		51,
		255
	}
	title.text = _("Enemies")

	self.creep:add_child(title)

	local title_w = title:get_text_width(title.text)
	local deco_y = 60
	local left_deco = KImageView:new("encyclopedia_rightArt")

	left_deco.pos = v(self.creep.size.x / 2 - title_w / 2 - 10, deco_y)
	left_deco.anchor = v(left_deco.size.x, left_deco.size.y / 2)

	self.creep:add_child(left_deco)

	local right_deco = KImageView:new("encyclopedia_rightArt")

	right_deco.pos = v(self.creep.size.x / 2 + title_w / 2 + 13, deco_y)
	right_deco.anchor = v(right_deco.size.x, right_deco.size.y / 2)
	right_deco.scale.x = -1

	self.creep:add_child(right_deco)

	local creeps_per_page = 36
	local creeps_data = GS.encyclopedia_enemies
	local max_creeps = #creeps_data

	for d = 1, creeps_per_page do
		local i = d + creeps_per_page * (index - 1)

		if i <= max_creeps then
			local t = encyclopedia_enemy_template(creeps_data[i])
			local icon_idx = encyclopedia_enemy_icon_idx(t, creeps_data[i].name, i, creeps_data[i].generation)
			local icon = string.format(GS.encyclopedia_enemy_thumb_fmt, icon_idx)

			self:create_creep(icon, v(math.fmod(d - 1, 6) * 63 + 35, math.floor((d - 1) / 6) * 63 + 140), i, true)
		end
	end

	self.creep:add_child(self.over_sprite)

	self.over_sprite.hidden = true
	self.over_sprite.anchor = v(self.over_sprite.size.x / 2, self.over_sprite.size.y / 2)
	self.over_sprite.propagate_on_click = true

	self.creep:add_child(self.select_sprite2)

	self.select_sprite2.anchor = v(self.select_sprite2.size.x / 2, self.select_sprite2.size.y / 2)
	self.select_sprite2.hidden = false
	self.select_sprite2.pos = v(35, 140)
	self.page_buttons = {}

	local total_pages = math.ceil(max_creeps / creeps_per_page)

	for i = 1, total_pages do
		local btn = EncyclopediaPageButton:new(i, i == index)

		layout_encyclopedia_page_button(btn, i, total_pages, self.creep.size.x, 530, 530)

		if i ~= index then
			function btn.on_click(this)
				S:queue("GUIButtonCommon")
				self:load_creeps(this.page_idx)
			end
		end

		self.creep:add_child(btn)
		table.insert(self.page_buttons, btn)
	end

	local first_creep = creeps_data[(index - 1) * creeps_per_page + 1]

	if first_creep and screen_map.user_data.seen[first_creep.name] then
		self:detail_creep((index - 1) * creeps_per_page + 1)
	else
		self.select_sprite2.hidden = true
	end
end

function EncyclopediaView:create_creep(icon, pos, information, enabled)
	if not screen_map.user_data.seen then
		screen_map.user_data.seen = {}
	end

	local creep_data = GS.encyclopedia_enemies[information]

	if true then --creep_data.always_shown or screen_map.user_data.seen[creep_data.name] then
		local b = KButton:new()

		b:set_image(icon)

		b.anchor = v(b.size.x / 2, b.size.y / 2)
		b.pos = pos
		b.scale = v(0.8, 0.8)

		self.creep:add_child(b)

		function b.on_enter()
			self:update_over_sprite(b.pos)
		end

		function b.on_exit()
			self:remove_over_sprite()
		end

		function b.on_click()
			S:queue("GUINotificationPaperOver")
			self:creep_clicked(information, pos)
		end
	--else
	--	local b = KImageView:new("encyclopedia_creep_thumbs_0049")

	--	b.anchor = v(b.size.x / 2, b.size.y / 2)
	--	b.pos = pos

	--	self.creep:add_child(b)
	end
end

function EncyclopediaView:creep_clicked(information, pos)
	self.select_sprite2.hidden = false
	self.select_sprite2.pos = pos

	self:detail_creep(information)
end

function EncyclopediaView:detail_creep(index)
	if self.right_panel then
		self.back:remove_child(self.right_panel)

		self.right_panel = nil
	end

	self.right_panel = KView:new(V.v(600, 700))
	self.right_panel.propagate_on_click = true
	self.right_panel.pos = v(self.sw / 2 - 30, 200)

	self.back:add_child(self.right_panel)

	local creep_data = GS.encyclopedia_enemies[index]
	local ce, t = encyclopedia_enemy_entity(creep_data)

	if not ce then
		return
	end

	local name_prefix = ce.info.i18n_key or string.upper(creep_data.name)
	local title_label = GGLabel:new(V.v(280, 50))

	title_label.pos = v(300, 44)
	title_label.anchor.x = title_label.size.x / 2
	title_label.font_name = "h_book"
	title_label.font_size = 22
	title_label.colors.text = {
		148,
		94,
		58
	}
	title_label.text = _(name_prefix .. "_NAME")
	title_label.text_align = "center"
	title_label.fit_lines = 1

	local title_width, _w = title_label:get_wrap_lines()

	self.right_panel:add_child(title_label)

	local left_decoration = KImageView:new("encyclopedia_rightArt")

	left_decoration.pos = v(300 - title_width / 2 - 10, 60)
	left_decoration.anchor = v(left_decoration.size.x, left_decoration.size.y / 2)
	left_decoration.scale.x = 0.7

	self.right_panel:add_child(left_decoration)

	local right_decoration = KImageView:new("encyclopedia_rightArt")

	right_decoration.pos = v(300 + title_width / 2 + 10, 60)
	right_decoration.anchor = v(left_decoration.size.x, right_decoration.size.y / 2)
	right_decoration.scale.x = -0.7

	self.right_panel:add_child(right_decoration)

	local portrait = KImageView:new(string.format(GS.encyclopedia_enemy_fmt, encyclopedia_enemy_icon_idx(t, creep_data.name, index, creep_data.generation)))

	portrait.anchor = v(portrait.size.x / 2, portrait.size.y / 2)
	portrait.pos = v(300, 175)
	portrait.scale = v(0.7, 0.708)

	self.right_panel:add_child(portrait)

	local over_portrait = KImageView:new("encyclopedia_frame")

	over_portrait.anchor = v(over_portrait.size.x / 2, over_portrait.size.y / 2)
	over_portrait.pos = v(300, 175)

	self.right_panel:add_child(over_portrait)

	local desc_label = GGLabel:new(V.v(330, 50))

	desc_label.pos = v(300, 280)
	desc_label.anchor = v(165, 0)
	desc_label.font_name = "body"
	desc_label.font_size = 16
	desc_label.line_height = CJK(1, nil, 1.1, 0.9)
	desc_label.colors.text = {
		0,
		0,
		0
	}
	local desc_key = index <= CREEP_1235_NUM and name_prefix .. "_DESCRIPTION" or name_prefix .. "_NOTIFICATION_DESCRIPTION"
	local desc_text = _(desc_key)
	if desc_text == desc_key then
		local alt_desc_key = index <= CREEP_1235_NUM and name_prefix .. "_NOTIFICATION_DESCRIPTION" or name_prefix .. "_DESCRIPTION"
		desc_text = _(alt_desc_key)
		if desc_text == alt_desc_key then
			desc_text = ""
		end
	end
	desc_label.text = desc_text
	desc_label.text_align = "center"
	desc_label.fit_lines = 4

	self.right_panel:add_child(desc_label)

	local frame = KImageView:new("encyclopedia_rightPages_0002")

	frame.anchor = v(frame.size.x / 2, 0)
	frame.pos = v(305, 360)

	self.right_panel:add_child(frame)

	local mx = 205
	local my = 380
	local ci = ce.info.fn(ce)
	local skill_table = {
		ci.hp_max,
		GU.damage_value_desc(ci.damage_min, ci.damage_max),
		ci.armor and string.format(_("%i%%"), ci.armor * 100) .. "" .. GU.armor_value_desc(ci.armor),
		ci.magic_armor and string.format(_("%i%%"), ci.magic_armor * 100) .. "" .. GU.armor_value_desc(ci.magic_armor),
		GU.speed_value_desc(ce.motion and (ce.motion.max_speed or 0) or 0),
		(GU.lives_desc(ci.lives))
	}
	if ci.no_ranged then
		skill_table = {
		ci.hp_max,
		GU.damage_value_desc(ci.damage_min, ci.damage_max),
		ci.armor and string.format(_("%i%%"), ci.armor * 100) .. "" .. GU.armor_value_desc(ci.armor),
		ci.magic_armor and string.format(_("%i%%"), ci.magic_armor * 100) .. "" .. GU.armor_value_desc(ci.magic_armor),
		GU.speed_value_desc(ce.motion and (ce.motion.max_speed or 0) or 0),
		(GU.lives_desc(ci.lives))
	}
	elseif ci.ranged_damage_min and ci.damage_max then
		if ci.ranged_damage_max < ci.damage_max then
			skill_table = {
				ci.hp_max,
				GU.damage_value_desc(ci.damage_min, ci.damage_max),
				ci.armor and string.format(_("%i%%"), ci.armor * 100) .. "" .. GU.armor_value_desc(ci.armor),
				ci.magic_armor and string.format(_("%i%%"), ci.magic_armor * 100) .. "" .. GU.armor_value_desc(ci.magic_armor),
				GU.speed_value_desc(ce.motion and (ce.motion.max_speed or 0) or 0),
				(GU.lives_desc(ci.lives))
			}
		else
			skill_table = {
				ci.hp_max,
				GU.damage_value_desc(ci.ranged_damage_min, ci.ranged_damage_max),
				ci.armor and string.format(_("%i%%"), ci.armor * 100) .. "" .. GU.armor_value_desc(ci.armor),
				ci.magic_armor and string.format(_("%i%%"), ci.magic_armor * 100) .. "" .. GU.armor_value_desc(ci.magic_armor),
				GU.speed_value_desc(ce.motion and (ce.motion.max_speed or 0) or 0),
				(GU.lives_desc(ci.lives))
			}			
		end	
	elseif ci.ranged_damage_min then
		skill_table = {
		ci.hp_max,
		GU.damage_value_desc(ci.ranged_damage_min, ci.ranged_damage_max),
		ci.armor and string.format(_("%i%%"), ci.armor * 100) .. "" .. GU.armor_value_desc(ci.armor),
		ci.magic_armor and string.format(_("%i%%"), ci.magic_armor * 100) .. "" .. GU.armor_value_desc(ci.magic_armor),
		GU.speed_value_desc(ce.motion and (ce.motion.max_speed or 0) or 0),
		(GU.lives_desc(ci.lives))
	}
	else
		skill_table = {
		ci.hp_max,
		GU.damage_value_desc(ci.damage_min, ci.damage_max),
		ci.armor and string.format(_("%i%%"), ci.armor * 100) .. "" .. GU.armor_value_desc(ci.armor),
		ci.magic_armor and string.format(_("%i%%"), ci.magic_armor * 100) .. "" .. GU.armor_value_desc(ci.magic_armor),
		GU.speed_value_desc(ce.motion and (ce.motion.max_speed or 0) or 0),
		(GU.lives_desc(ci.lives))
	}
	end
	--ce.moton and
	for i = 1, 6 do
		local desc_label = GGLabel:new(V.v(90, 50))

		desc_label.pos = v(mx + 20, my - 5)
		desc_label.anchor = v(0, 2)
		desc_label.font_name = "body"
		desc_label.font_size = 15
		desc_label.line_height = 2
		desc_label.text = skill_table[i]
		desc_label.text_align = "left"
		desc_label.fit_lines = 1

		self.right_panel:add_child(desc_label)

		mx = mx + 130

		if mx > 400 then
			mx = 200
			my = my + 30
		end
	end

	local special_key = string.upper(creep_data.name) .. "_SPECIAL"
	local special = _(special_key)

	local special_extra = string.upper(creep_data.name) .. "_EXTRA"
	local special_extra_key = _(special_extra)

	if special == special_key then
		special = ""
	end

	if special_extra_key == special_extra then
		--empty
		if t.info and t.info.i18n_key then
			special_extra = t.info.i18n_key .. "_EXTRA"
			special_extra_key = _(special_extra)
			if special_extra_key == special_extra then
				local special_i18n = t.info.i18n_key .. "_SPECIAL"
				local special_i18n_key = _(special_i18n)
				if special_i18n_key ~= special_i18n then
					special = special .. special_i18n_key
					special = string.gsub(special, "\n", "；")
				end
			else
				special = special..special_extra_key
			special = string.gsub(special, "\n", "；")
			end
		end
	else
		special = special..special_extra_key
		special = string.gsub(special, "\n", "；")
	end

	local special_frame = KImageView:new("encyclopedia_rightPages_0004")

	special_frame.anchor.x = special_frame.size.x / 2
	special_frame.pos = v(300, 390)
	special_frame.scale = v(0.75, 0.75)

	self.right_panel:add_child(special_frame)

	if string.len(special) == 0 then
		special_frame.hidden = true
	end

	local desc_label = GGLabel:new(V.v(400, 22))

	desc_label.pos = v(300, 506)
	desc_label.anchor = v(desc_label.size.x / 2, 0)
	desc_label.font_name = "body"
	desc_label.font_size = 15
	desc_label.text = special
	desc_label.text_align = "center"
	desc_label.colors.text = {
		148,
		94,
		58
	}
	desc_label.vertical_align = "middle"
	desc_label.fit_lines = 1

	self.right_panel:add_child(desc_label)
end

EncyclopediaPageButton = class("EncyclopediaPageButton", GGButton)
EncyclopediaPageButton.static.init_arg_names = {
	"label_text"
}

function EncyclopediaPageButton:initialize(label_text, select)
	local rs = GGLabel.static.ref_h / REF_H

	if select then
		GGButton.initialize(self, "encyclopedia_pageNbrSelected_0001", "encyclopedia_pageNbrSelected_0001", "encyclopedia_pageNbrSelected_0001")
		self.deselected_image_name = "encyclopedia_pageNbrSelected_0001"
		self.selected_image_name = "encyclopedia_pageNbrSelected_0001"
	else
		GGButton.initialize(self, "encyclopedia_pageNbr_0001", "encyclopedia_pageNbrOver_0001", "encyclopedia_pageNbrSelected_0001")
	end
	--self.deselected_image_name = "encyclopedia_pageNbrOver_0001"
	--self.selected_image_name = "encyclopedia_pageNbrSelected_0001"
	self.label.pos.x, self.label.pos.y = rs * 1, 0
	self.label.vertical_align = "middle-caps"
	self.label.font_name = "numbers_bold"
	-- Keep page-number buttons at a stable desktop size. Android applies its
	-- global 1.2 font factor when the font is loaded.
	self.label.font_size = 16
	self.label.fit_lines = 1

	if not self.label_text_key and label_text then
		self.label.text = label_text
	end

	self.on_down_scale = 0.95
end

function EncyclopediaPageButton:select()
	self.default_image_name = self.selected_image_name

	self:disable()
	self:set_image(self.selected_image_name)
end

function EncyclopediaPageButton:deselect()
	self.default_image_name = self.deselected_image_name

	self:enable()

	if not self:is_disabled() then
		self:set_image(self.default_image_name)
	end
end

--新增5代英雄系统
--该界面只用于选择与反选，不用于提升英雄能力
Hero5SelectView = class("Hero5SelectView", PopUpView)

local hrvt_scale = v(0.625, 0.625)
local hrvt_size = v(160 * hrvt_scale.x, 168 * hrvt_scale.y)
local hrvt_margin = v(14, 10)
local hrvt_sep = v(6, 4)
local hrvt_per_row = 8

function Hero5SelectView:hero_thumb_pos(i, ox, oy)
	i = i % 16
	if i == 0 then
		i = 16
	end
	local frame = self.hero_select
	local sx = frame.pos.x - frame.size.x / 2 * frame.scale.x + hrvt_margin.x
	local dx = hrvt_size.x + hrvt_sep.x
	local sy = frame.pos.y - frame.size.y / 2 * frame.scale.y + hrvt_margin.y
	local dy = hrvt_size.y + hrvt_sep.y
	local per_row = hrvt_per_row
	local pos = v(math.fmod(i - 1, per_row) * dx + sx, math.floor((i - 1) / per_row) * dy + sy)

	pos.x = pos.x + (ox and ox or 0)
	pos.y = pos.y + (oy and oy or 0) + (i <= 47 and 0 or 10)

	return pos
end

function Hero5SelectView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))

	local user_data = storage:load_slot()

	self.back = KImageView:new("heroroom_001_notxt")
	self.back.pos = v(0, 0)
	self.back.anchor = v(self.back.size.x / 2, self.back.size.y / 2)

	self:add_child(self.back)

	self.back.alpha = 0
	self.hero_select = KImageView:new("heroroom_002")
	self.hero_select.anchor = v(self.hero_select.size.x / 2, self.hero_select.size.y / 2)
	self.hero_select.pos = v(self.back.size.x / 2, 203)
	self.hero_select.scale.y = (2 * hrvt_margin.y + 2 * hrvt_size.y + hrvt_sep.y) / self.hero_select.size.y

	self.back:add_child(self.hero_select)

	self.hero_select.selected = KImageView:new("heroroom_portraitsDecos_0002")
	self.hero_select.selected.pos = v(30, 30)
	self.hero_select.selected.scale = hrvt_scale
	self.hero_select.selected.hidden = true
	self.hero_select.over = KImageView:new("heroroom_portraitsDecos_0003")
	self.hero_select.over.pos = v(30, 30)
	self.hero_select.over.propagate_on_click = true
	self.hero_select.over.scale = hrvt_scale
	self.hero_select.over.hidden = false
	self.selected_index = -1
	self.hero_select.mouse_over = KImageView:new("heroroom_thumbs_0008")
	self.hero_select.mouse_over.propagate_on_click = true
	self.hero_select.mouse_over.hidden = true
	self.hero_select.mouse_over.scale = v(hrvt_size.x / self.hero_select.mouse_over.size.x, hrvt_size.y / self.hero_select.mouse_over.size.y)

	if screen_map.user_data.liuhui_hero == nil then
		screen_map.user_data.liuhui_hero = {}
	end
	if screen_map.user_data.liuhui_hero.usedoublehero == nil then
		screen_map.user_data.liuhui_hero.usedoublehero = false
	end
	if screen_map.user_data.liuhui_hero.herolist == nil then
		screen_map.user_data.liuhui_hero.herolist = {[1] = 48; [2] = 49}
	end
	--需要确定并加载防御塔数据，当前联盟共移植(19)塔，复仇共移植(12)塔，局内最多携带(10)塔。


	if screen_map.user_data.heroes.selected then
		for i, hd in ipairs(screen_map.hero_data) do
			if hd.name == screen_map.user_data.heroes.selected then
				self.selected_index = i
				self.real_selected = i
				self.hero_select.selected.pos = self:hero_thumb_pos(i)
				self.hero_select.over.pos = self:hero_thumb_pos(i)
				self.hero_select.selected.hidden = false

				break
			end
		end
	end

	if self.selected_index < 0 then
		self.hero_select.selected.hidden = true
		self.selected_index = 1
		self.hero_select.over.pos = v(sx, sy)
	end

	self.over_index = self.selected_index

	-- local max_level = #screen_map.user_data.levels
	local max_level = 72
	-- changed
	self.hero_views = {}
	self.hero_viewing = 1
	function switch_hero_room_page()
		for i, v in ipairs(self.hero_views) do
			if (i >= self.hero_viewing and i - self.hero_viewing < 16) then
				v.hidden = false
			else
				v.hidden = true
			end
		end
		self.hero_viewing = self.hero_viewing + 16
		if self.hero_viewing > #self.hero_views then
			self.hero_viewing = 1
		end
	end

	for i = 1, #screen_map.hero_data do
		local hd = screen_map.hero_data[i]
		get_hero_stats(i)

		if not hd or hd.coming_soon then
			local portrait = KImageView:new("heroroom_portraitsDecos_0001")

			table.insert(self.hero_views, portrait)
			portrait.hidden = true

			portrait.pos = self:hero_thumb_pos(i)
			portrait.scale = hrvt_scale

			self.back:add_child(portrait)
		else
			--在此加入英雄
			--注意5代英雄的portrait和技能的加载
			local portrait = nil
			if i <= 47 then--加载前3代英雄
				portrait = KImageView:new(string.format("heroroom_portraits_%04i", hd.thumb))
			else--加载5代英雄
				portrait = KImageView:new(string.format("hero_room_portraits_small_thumb_%s_0001", hd.name))
			end
			table.insert(self.hero_views, portrait)
			portrait.hidden = true

			portrait.pos = self:hero_thumb_pos(i)
			portrait.scale = i <= 47 and hrvt_scale or v(1, 1)
			--portrait.scale = hrvt_scale if i <= 47 else v(1,1)

			self.back:add_child(portrait)

			function portrait.on_enter()
				self.hero_select.mouse_over.hidden = false
				self.hero_select.mouse_over.pos = self:hero_thumb_pos(i, 0, -1)
			end

			function portrait.on_exit()
				self.hero_select.mouse_over.hidden = true
			end

			function portrait.on_click()
				S:queue("GUIQuickMenuOpen")

				self.selected_index = i
				self.over_index = i

				--self:construct_hero(i)

				self.hero_select.over.pos = portrait.pos
				self.hero_select.over.hidden = false
			end

			if max_level < hd.available_level then
				local portraitLock = KImageView:new("heroroom_portraitsLock")

				table.insert(self.hero_views, portrait)
				portrait.hidden = true

				portraitLock.pos = self:hero_thumb_pos(i)
				portraitLock.scale = v(hrvt_size.x / portraitLock.size.x, hrvt_size.y / portraitLock.size.y)

				self.back:add_child(portraitLock)

				portraitLock.propagate_on_click = true
			end
		end
	end

	self.hero_select.selected.propagate_on_click = true

	self.back:add_child(self.hero_select.mouse_over)
	self.back:add_child(self.hero_select.over)
	self.back:add_child(self.hero_select.selected)

	--[[
	self.tip_panel = HeroToolTip:new()

	self:add_child(self.tip_panel)

	self.skills = HeroSkills:new(1, {})
	self.skills.anchor = v(0, 0)
	self.skills.pos = v(self.back.size.x / 2 - 15, 375 + (IS_KR3 and -6 or 0))

	self.back:add_child(self.skills)

	self.skills.tip_panel = self.tip_panel
	]]--

	local close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")

	close_button.pos = v(self.back.size.x - 53, 19)

	function close_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end

	self.close_button = close_button

	self.back:add_child(close_button)

--[[
	self.portrait = KImageView:new("portrait_notxt_0001")
	self.portrait.scale = v(0.9, 0.9)
	self.portrait.anchor = v(self.portrait.size.x / 2, self.portrait.size.y / 2)
	self.portrait.pos = v(400, 510)

	self.back:add_child(self.portrait)

	self.portrait_name = HeroNameLabel:new(V.v(200, 100))
	self.portrait_name.pos = v(300, 552)

	self.back:add_child(self.portrait_name)

	self.portrait_over = KView:new(V.v(self.portrait.size.x, self.portrait.size.y))
	self.portrait_over.scale = v(0.9, 0.9)
	self.portrait_over.colors.background = {
		255,
		255,
		255,
		0
	}
	self.portrait_over.propagate_on_click = true
	self.portrait_over.anchor = v(self.portrait.size.x / 2, self.portrait.size.y / 2)
	self.portrait_over.pos = v(400, 510)

	self.back:add_child(self.portrait_over)

	local over_portrait = KImageView:new("heroroom_020")

	over_portrait.anchor = v(over_portrait.size.x / 2, over_portrait.size.y / 2)
	over_portrait.pos = v(400, 510)

	self.back:add_child(over_portrait)
	]]--
	--self.skills:load_hero(1)

	--[[
	self.selected_spr = KImageView:new("heroroom_btnSelect_0003")
	self.selected_spr.pos = v(320, 655)

	self.back:add_child(self.selected_spr)

	self.selected_spr.hidden = true

	local selected_text = GGShaderLabel:new(V.v(114, 38))

	selected_text.pos = v(25, 16)
	selected_text.font_size = 24
	selected_text.font_name = "button"
	selected_text.text_align = "center"
	selected_text.vertical_align = ISW("middle-caps", "zh-Hans", "middle", "ko", "middle", "ja", "middle", "zh-Hant", "middle")
	selected_text.text = _("MAP_HERO_ROOM_SELECTED")
	selected_text.colors.text = {
		233,
		222,
		178,
		255
	}
	selected_text.fit_lines = 1
	selected_text.shaders = {
		"p_glow"
	}
	selected_text.shader_args = {
		{
			thickness = 3,
			glow_color = {
				0.23921568627450981,
				0.19607843137254902,
				0.1568627450980392,
				1
			}
		}
	}

	self.selected_spr:add_child(selected_text)

	self.locked_spr = KImageView:new("heroroom_btnSelect_0004")
	self.locked_spr.pos = v(320, 655)

	self.back:add_child(self.locked_spr)

	self.locked_spr.hidden = true

	local locked_text = GGLabel:new(V.v(114, 38))

	locked_text.pos = v(25, 16)
	locked_text.font_size = 16
	locked_text.font_name = "button"
	locked_text.text_align = "center"
	locked_text.vertical_align = ISW("middle-caps", "zh-Hans", "middle", "ko", "middle", "ja", "middle", "zh-Hant", "middle")
	locked_text.colors.text = {
		255,
		255,
		255
	}

	self.locked_spr:add_child(locked_text)

	self.locked_spr.l_text = locked_text
	self.select_but = GGButton:new("heroroom_btnSelect_0001", "heroroom_btnSelect_0002", "heroroom_btnSelect_0002")
	self.select_but.pos = v(320, 655)
	self.select_but.anchor = v(0, 0)
	self.select_but.on_down_scale = nil
	self.select_but.label.size = v(114, 38)
	self.select_but.label.text_size = self.select_but.label.size
	self.select_but.label.pos = v(25, 16)
	self.select_but.label.font_size = 24
	self.select_but.label.vertical_align = ISW("middle-caps", "zh-Hans", "middle", "ko", "middle", "ja", "middle", "zh-Hant", "middle")
	self.select_but.label.text = _("MAP_HERO_ROOM_SELECT")
	self.select_but.label.fit_lines = 1

	function self.select_but.on_click()
		S:queue("GUIBuyUpgrade")

		if not screen_map.user_data.seen.heroroom_help_select then
			screen_map.user_data.seen.heroroom_help_select = true
			self.help_select.hidden = true
		end

		local i = self.selected_index
		local hd = screen_map.hero_data[i]

		local selected_stats = get_hero_stats(i)

		screen_map.skill_label.text = tostring(selected_stats.remaining_points)

		if selected_stats.remaining_points == 0 then
			screen_map.skill_star.hidden = true
		else
			screen_map.skill_star.hidden = false
		end

		self.hero_select.selected.pos = self:hero_thumb_pos(i)
		screen_map.user_data.heroes.selected = hd.name

		local ht = E:get_template(hd.name)

		S:queue(ht.sound_events.hero_room_select)

		local h_status = screen_map.user_data.heroes.status[screen_map.user_data.heroes.selected]
		local starting_xp = hd.starting_level < 2 and 0 or GS.hero_xp_thresholds[hd.starting_level - 1]

		h_status.xp = math.max(h_status.xp, starting_xp)

		storage:save_slot(screen_map.user_data)

		self.select_but.hidden = true
		self.selected_spr.hidden = false
		self.real_selected = i

		local kr4_portrait_name = kr4_map_hero_portrait_name(hd)

		if hd.icon <= 47 then
			screen_map.hero_icon_portrait:set_image(string.format("mapButtons_portrait_hero_%04i", hd.icon))
			screen_map.hero_icon_portrait.pos = V.v(0,0)
		elseif kr4_portrait_name then
			screen_map.hero_icon_portrait:set_image(kr4_portrait_name)
			screen_map.hero_icon_portrait.pos = V.v(0, 0)
			screen_map.hero_icon_portrait.scale = V.v(1, 1)
		else
			screen_map.hero_icon_portrait:set_image(string.format("hero_room_portraits_small_button_%s_0001", hd.name))
			screen_map.hero_icon_portrait.pos = V.v(200,400)
			screen_map.hero_icon_portrait.scale = V.v(0.7,0.7)
		end

		screen_map.hero_icon_portrait.hidden = false
		self.portrait_over.colors.background = {
			255,
			255,
			255,
			255
		}

		timer.tween(0.8, self.portrait_over.colors, {
			background = {
				255,
				255,
				255,
				0
			}
		}, "out-quad")

	end

	self.back:add_child(self.select_but)
]]--
	--self:construct_hero(self.selected_index)

	self.selected_hero1 = KImageView:new("heroroom_014_large")
	self.selected_hero2 = KImageView:new("heroroom_014_large")
	self.back:add_child(self.selected_hero1)
	self.back:add_child(self.selected_hero2)
	self:update_selected_hero()

	if not IS_KR3 then
		local header = GGPanelHeader:new(_("DOUBLE HERO ROOM"), 274)

		header.pos = V.v(397, CJK(26, 24, nil, 24))

		self.back:add_child(header)
	end

	if not screen_map.user_data.seen.heroroom_help or DEBUG_HEROROOM_HELP then
		self.hero_help = KImageView:new("heroroom_001_notxt")

		self.back:add_child(self.hero_help)

		self.hero_help.colors.tint = {
			0,
			0,
			0,
			150
		}

		function self.hero_help.on_click()
			timer.tween(0.5, self.hero_help, {
				alpha = 0
			}, "out-quad", function()
				self.back:remove_child(self.hero_help)
			end)

			screen_map.user_data.seen.heroroom_help = true
			screen_map.user_data.seen.heroroom_double_help = true

			storage:save_slot(screen_map.user_data)
		end

		function self.hero_help.disable()
			self.hero_help.colors.tint = {
				0,
				0,
				0,
				120
			}
		end

		function self.hero_help.remove_disabled_tint()
			self.hero_help.colors.tint = {
				0,
				0,
				0,
				120
			}
		end

		local help_ability = KImageView:new("heroroom_help_abilities_notxt")

		help_ability.pos = v(572, 466)

		self.hero_help:add_child(help_ability)

		local help_ability_text = GGLabel:new(V.v(326, 28))

		help_ability_text.font_name = "body"
		help_ability_text.font_size = 24
		help_ability_text.colors.text = {
			0,
			0,
			0,
			255
		}
		help_ability_text.text_align = "center"
		help_ability_text.vertical_align = "middle"
		help_ability_text.text = _("Select and train abilities")
		help_ability_text.pos = v(12, 15)
		help_ability_text.fit_lines = 1

		help_ability:add_child(help_ability_text)

		local help_select = KImageView:new("heroroom_help_select_notxt")

		help_select.pos = v(85, 645)

		self.hero_help:add_child(help_select)

		local help_select_text = GGLabel:new(V.v(200, 30))

		help_select_text.font_name = "body"
		help_select_text.font_size = 24
		help_select_text.colors.text = {
			0,
			0,
			0,
			255
		}
		help_select_text.text_align = "center"
		help_select_text.vertical_align = "middle"
		help_select_text.text = _("Click to select")
		help_select_text.pos = v(13, 15)
		help_select_text.fit_lines = 1

		help_select:add_child(help_select_text)
	end

	if IS_KR3 then
		local header_bg = KImageView("kr3_title_bg")

		header_bg.anchor.x = km.round(header_bg.size.x / 2)
		header_bg.pos = v(km.round(self.back.size.x / 2), -36)

		self.back:add_child(header_bg)

		local header = GGPanelHeader:new(_("DOUBLE HERO ROOM"), 274)

		header.pos = V.v(397, CJK(26, 24, nil, 24) - 36)

		self.back:add_child(header)
	end

	local done_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	done_button.anchor = v(math.floor(done_button.size.x / 2), done_button.size.y / 2)
	done_button.pos = v(self.back.size.x - 166, self.back.size.y - 32)
	done_button.label.size = v(100, 34)
	done_button.label.text_size = done_button.label.size
	done_button.label.pos = v(20, 19)
	done_button.label.font_size = 24
	done_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	done_button.label.text = _("BUTTON_DONE")
	done_button.label.fit_lines = 1

	function done_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end

	self.back:add_child(done_button)

	self.done_button = done_button

	local switch_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	switch_button.size.x = 200
	switch_button.anchor = v(math.floor(done_button.size.x / 2), done_button.size.y / 2)
	switch_button.pos = v(self.selected_hero2.pos.x + 200, self.selected_hero2.pos.y + 60)
	switch_button.label.size = v(160, 34)
	switch_button.label.text_size = done_button.label.size
	switch_button.label.pos = v(20, 19)
	switch_button.label.font_size = 24
	switch_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	switch_button.label.text = screen_map.user_data.liuhui_hero.usedoublehero and _("HERO5_MODE_ON") or _("HERO5_MODE_OFF")
	switch_button.label.fit_lines = 1

	function switch_button.on_click()
		S:queue("GUIButtonCommon")
		screen_map.user_data.liuhui_hero.usedoublehero = not screen_map.user_data.liuhui_hero.usedoublehero
		screen_map.user_data.liuhui_hero.useinfinitehero = false
		switch_button.label.text = screen_map.user_data.liuhui_hero.usedoublehero and _("HERO5_MODE_ON") or _("HERO5_MODE_OFF")
		storage:save_slot(screen_map.user_data)
	end

	self.back:add_child(switch_button)

	self.switch_button = switch_button

	local select_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	select_button.anchor = v(math.floor(done_button.size.x / 2), done_button.size.y / 2)
	select_button.pos = v(self.back.size.x - 166 - done_button.size.x * 2 - 20 * 2, self.back.size.y - 32)
	select_button.label.size = v(100, 34)
	select_button.label.text_size = done_button.label.size
	select_button.label.pos = v(20, 19)
	select_button.label.font_size = 24
	select_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	select_button.label.text = _("MAP_HERO_ROOM_SELECT")
	select_button.label.fit_lines = 1

	--选择英雄
	function select_button.on_click()
		S:queue("GUIButtonCommon")
		local i = self.selected_index --注意不能和icon值弄混了
		local hd = screen_map.hero_data[i]
		if hd.transplanting == true then
			return
		end
		screen_map.user_data.liuhui_hero.herolist[2] = screen_map.user_data.liuhui_hero.herolist[1]
		screen_map.user_data.liuhui_hero.herolist[1] = self.selected_index
		local ht = E:get_template(hd.name)
		S:queue(ht.sound_events.hero_room_select)

		local h_status = screen_map.user_data.heroes.status[hd.name]
		local starting_xp = hd.starting_level < 2 and 0 or GS.hero_xp_thresholds[hd.starting_level - 1]

		h_status.xp = math.min(math.max(h_status.xp, starting_xp), 1153000)

		--storage:save_slot(screen_map.user_data)
		storage:save_slot(screen_map.user_data)
		self:update_selected_hero()
	end

	self.back:add_child(select_button)

	self.select_button = select_button

	--英雄界面切换按钮
	switch_hero_room_page()
	if self.real_selected > 16 and self.real_selected <= 32 then
		switch_hero_room_page()
	elseif self.real_selected > 32 and self.real_selected <= 48 then
		switch_hero_room_page()
		switch_hero_room_page()
	elseif self.real_selected >= 48 and self.real_selected <= 64 then
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
	elseif self.real_selected >= 65 and self.real_selected <= 80 then
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
	elseif self.real_selected >= 81 and self.real_selected <= 96 then
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
	else
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
	end

	local next_page_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	next_page_button.anchor = v(math.floor(done_button.size.x / 2), done_button.size.y / 2)
	next_page_button.pos = v(self.back.size.x - 166 - done_button.size.x - 20, self.back.size.y - 32)
	next_page_button.label.size = v(100, 34)
	next_page_button.label.text_size = done_button.label.size
	next_page_button.label.pos = v(20, 19)
	next_page_button.label.font_size = 24
	next_page_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	next_page_button.label.text = _("BUTTON_NEXT_PAGE")
	next_page_button.label.fit_lines = 1

	function next_page_button.on_click()
		switch_hero_room_page()
		S:queue("GUIButtonCommon")
	end

	self.back:add_child(next_page_button)

	self.next_page_button = next_page_button

	local prev_page_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	prev_page_button.anchor = v(math.floor(done_button.size.x / 2), done_button.size.y / 2)
	prev_page_button.pos = v(self.back.size.x - 498 - done_button.size.x - 20, self.back.size.y - 32)
	prev_page_button.label.size = v(100, 34)
	prev_page_button.label.text_size = done_button.label.size
	prev_page_button.label.pos = v(20, 19)
	prev_page_button.label.font_size = 24
	prev_page_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	prev_page_button.label.text = _("BUTTON_PREV_PAGE")
	prev_page_button.label.fit_lines = 1

	function prev_page_button.on_click()
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
		S:queue("GUIButtonCommon")
	end

	self.back:add_child(prev_page_button)

	self.prev_page_button = prev_page_button

	local over_done_button = KImageView:new("heroroom_014_large")

	over_done_button.anchor = v(math.floor(over_done_button.size.x / 2), over_done_button.size.y / 2)
	over_done_button.pos = v(self.back.size.x - 498, self.back.size.y - 34)

	self.back:add_child(over_done_button)

	over_done_button.propagate_on_click = true
end

function Hero5SelectView:show()
	Hero5SelectView.super.show(self)
end

function Hero5SelectView:update_selected_hero()

	local i = screen_map.user_data.liuhui_hero.herolist[1]
	local hd = screen_map.hero_data[i]
	if i <= 47 then--加载前3代英雄
		self.selected_hero1:set_image(string.format("heroroom_portraits_%04i", hd.thumb))
	else--加载5代英雄
		self.selected_hero1:set_image(string.format("hero_room_portraits_small_thumb_%s_0001", hd.name))
	end
	self.selected_hero1.pos =  i <= 47 and self:hero_thumb_pos(1, 0, 300) or self:hero_thumb_pos(49, 0, 300)
	self.selected_hero1.scale = i <= 47 and hrvt_scale or v(1, 1)

	local i = screen_map.user_data.liuhui_hero.herolist[2]
	local hd = screen_map.hero_data[i]
	if i <= 47 then--加载前3代英雄
		self.selected_hero2:set_image(string.format("heroroom_portraits_%04i", hd.thumb))
	else--加载5代英雄
		self.selected_hero2:set_image(string.format("hero_room_portraits_small_thumb_%s_0001", hd.name))
	end
	self.selected_hero2.pos = i <= 47 and self:hero_thumb_pos(2, 0, 300) or self:hero_thumb_pos(50, 0, 300)
	self.selected_hero2.scale = i <= 47 and hrvt_scale or v(1, 1)
end

SpellSelectView = class("SpellSelectView", PopUpView)

local function spell_select_set_icon(view, image_name, scale)
	view:set_image(image_name)
	view.anchor = v(view.size.x / 2, view.size.y / 2)
	view.scale = v(scale or 0.72, scale or 0.72)
end

local function spell_select_icon_scale(option, scale)
	return option and option.generation == 6 and scale * 0.5 or scale
end

function SpellSelectView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))

	self.selected_option_id = nil
	self.detail_option_id = nil
	self.option_page = 1
	self.option_page_count = math.max(1, math.ceil(#power_selection.order / 12))
	self.slot_rows = {}
	self.option_cards = {}
	self.back = KView:new(V.v(sw, sh))
	self.back.pos = v(0, 0)
	self.back.anchor = v(sw / 2, sh / 2)
	self.back.alpha = 0

	self:add_child(self.back)

	self.backback = KImageView:new("encyclopedia_bg")
	self.backback.anchor = v(self.backback.size.x / 2, self.backback.size.y / 2)
	self.backback.pos = v(sw / 2, sh / 2)
	self.back:add_child(self.backback)

	local book = self.backback
	local left_title = GGLabel:new(V.v(460, 48))

	left_title.pos = v(156, 52)
	left_title.font_name = "h_book"
	left_title.font_size = 34
	left_title.colors.text = {100, 89, 51, 255}
	left_title.text = "Chọn phép"
	left_title.text_align = "center"
	left_title.vertical_align = "middle"
	left_title.fit_lines = 1
	book:add_child(left_title)

	local upgrade_info_label = GGLabel:new(V.v(440, 470))

	upgrade_info_label.pos = v(630, 72)
	upgrade_info_label.font_name = "body"
	upgrade_info_label.font_size = 22
	upgrade_info_label.line_height = 1.1
	upgrade_info_label.colors.text = {78, 63, 38, 255}
	upgrade_info_label.text_align = "left"
	upgrade_info_label.vertical_align = "top"
	upgrade_info_label.fit_lines = 12
	book:add_child(upgrade_info_label)
	self.upgrade_info_label = upgrade_info_label

	local power_upgrade_title = GGLabel:new(V.v(440, 32))

	power_upgrade_title.pos = v(630, 185)
	power_upgrade_title.font_name = "body_bold"
	power_upgrade_title.font_size = 21
	power_upgrade_title.colors.text = {100, 89, 51, 255}
	power_upgrade_title.text = "Nâng phép phần 6 (5/5)"
	power_upgrade_title.text_align = "center"
	power_upgrade_title.vertical_align = "middle"
	power_upgrade_title.fit_lines = 1
	power_upgrade_title.hidden = true
	book:add_child(power_upgrade_title)
	self.power_upgrade_title = power_upgrade_title

	local power_upgrade_detail = GGLabel:new(V.v(440, 132))

	power_upgrade_detail.pos = v(630, 405)
	power_upgrade_detail.font_name = "body"
	power_upgrade_detail.font_size = 19
	power_upgrade_detail.line_height = 1.05
	power_upgrade_detail.colors.text = {78, 63, 38, 255}
	power_upgrade_detail.text_align = "center"
	power_upgrade_detail.vertical_align = "top"
	power_upgrade_detail.fit_lines = 5
	power_upgrade_detail.hidden = true
	book:add_child(power_upgrade_detail)
	self.power_upgrade_detail = power_upgrade_detail
	self.power_upgrade_buttons = {}

	local power_upgrade_positions = {
		v(670, 260),
		v(670, 350),
		v(760, 305),
		v(850, 260),
		v(850, 350),
		v(940, 260),
		v(940, 350),
		v(1030, 305)
	}

	for index, position in ipairs(power_upgrade_positions) do
		local highlight = KView:new(V.v(72, 72))

		highlight.pos = v(position.x - 36, position.y - 36)
		highlight.hidden = true
		highlight.propagate_on_click = true
		highlight.propagate_on_down = true
		highlight.propagate_on_up = true

		function highlight:_draw_self()
			local pr, pg, pb, pa = G.getColor()
			local old_width = G.getLineWidth and G.getLineWidth() or 1
			local points = {
				18, 3,
				54, 3,
				69, 36,
				54, 69,
				18, 69,
				3, 36
			}

			G.setColor(255, 210, 55, 64)
			G.polygon("fill", points)
			G.setColor(255, 205, 45, 255)
			G.setLineWidth(4)
			G.polygon("line", points)
			G.setLineWidth(old_width)
			G.setColor(pr, pg, pb, pa)
		end

		book:add_child(highlight)

		local button = KButton:new()

		button:set_image("power_upgrade_icons_reinforcements_" .. index)
		button.anchor = v(button.size.x / 2, button.size.y / 2)
		button.pos = position
		button.scale = v(0.5, 0.5)
		button.hidden = true

		function button.on_click()
			local node = button.node

			if not node then
				return
			end

			self.selected_power_upgrade_node = node
			self:update_power_upgrade_detail(node)

			if not node.branch then
				return
			end

			if power_upgrades_6.set_branch(screen_map.user_data, node.power_name, node.tier, node.branch) then
				storage:save_slot(screen_map.user_data)
				S:queue("GUIButtonCommon")
				self:refresh()
			end
		end

		function button.on_enter()
			self.hovered_power_upgrade_node = button.node
			self:update_power_upgrade_detail(button.node)
		end

		function button.on_exit()
			if self.hovered_power_upgrade_node == button.node then
				self.hovered_power_upgrade_node = nil
			end

			self:update_power_upgrade_detail(self.selected_power_upgrade_node)
		end

		book:add_child(button)
		button.branch_highlight = highlight
		table.insert(self.power_upgrade_buttons, button)
	end

	local selected_title = GGLabel:new(V.v(460, 30))

	selected_title.pos = v(156, 430)
	selected_title.font_name = "body_bold"
	selected_title.font_size = 22
	selected_title.colors.text = {100, 89, 51, 255}
	selected_title.text = "Đã chọn"
	selected_title.text_align = "center"
	selected_title.vertical_align = "middle"
	selected_title.fit_lines = 1
	book:add_child(selected_title)

	for slot = 1, 3 do
		local slot_index = slot
		local row = KButton:new()

		row.size = v(136, 110)
		row.pos = v(160 + (slot - 1) * 154, 460)
		row.propagate_on_click = false

		function row.on_click()
			self:assign_selected_option(slot_index)
		end

		book:add_child(row)

		local frame = KImageView:new("encyclopedia_tower_thumbs_0021")

		frame.anchor = v(frame.size.x / 2, frame.size.y / 2)
		frame.pos = v(68, 44)
		frame.scale = v(0.72, 0.72)
		frame.propagate_on_click = true
		row:add_child(frame)

		local icon = KImageView:new("spell_selection_icon_fire")

		spell_select_set_icon(icon, "spell_selection_icon_fire", 0.58)
		icon.pos = v(68, 44)
		icon.propagate_on_click = true
		row:add_child(icon)

		local slot_label = GGLabel:new(V.v(136, 24))

		slot_label.pos = v(0, 0)
		slot_label.font_name = "h_book"
		slot_label.font_size = 18
		slot_label.colors.text = {100, 89, 51, 255}
		slot_label.text = string.format("Ô %i", slot)
		slot_label.text_align = "center"
		slot_label.vertical_align = "middle"
		slot_label.fit_lines = 1
		slot_label.propagate_on_click = true
		row:add_child(slot_label)

		local name_label = GGLabel:new(V.v(128, 24))

		name_label.pos = v(4, 72)
		name_label.font_name = "body"
		name_label.font_size = 15
		name_label.colors.text = {78, 63, 38, 255}
		name_label.text_align = "center"
		name_label.vertical_align = "middle"
		name_label.fit_lines = 1
		name_label.propagate_on_click = true
		row:add_child(name_label)

		self.slot_rows[slot] = {
			root = row,
			frame = frame,
			icon = icon,
			name_label = name_label,
			slot_label = slot_label
		}
	end

	for index, option_id in ipairs(power_selection.order) do
		local selected_option_id = option_id
		local option = power_selection.options[option_id]
		local page_index = (index - 1) % 12
		local option_page = math.floor((index - 1) / 12) + 1
		local column = page_index % 4
		local row_index = math.floor(page_index / 4)
		local card = KButton:new()

		card.size = v(112, 88)
		card.pos = v(152 + column * 116, 104 + row_index * 91)
		card.hidden = option_page ~= self.option_page

		function card.on_click()
			self:select_option(selected_option_id)
		end

		book:add_child(card)

		local frame = KImageView:new("encyclopedia_tower_thumbs_0021")

		frame.anchor = v(frame.size.x / 2, frame.size.y / 2)
		frame.pos = v(56, 31)
		frame.scale = v(0.62, 0.62)
		frame.propagate_on_click = true
		card:add_child(frame)

		local map_icon = option.map_icon or option.icon
		local icon = KImageView:new(map_icon)

		spell_select_set_icon(icon, map_icon, spell_select_icon_scale(option, 0.52))
		icon.pos = v(56, 31)
		icon.propagate_on_click = true
		card:add_child(icon)

		local label = GGLabel:new(V.v(112, 28))

		label.pos = v(0, 60)
		label.font_name = "body"
		label.font_size = 14
		label.line_height = 0.85
		label.colors.text = {78, 63, 38, 255}
		label.text = option.label
		label.text_align = "center"
		label.vertical_align = "middle"
		label.fit_lines = 2
		label.propagate_on_click = true
		card:add_child(label)

		function card.on_enter()
			if self.selected_option_id ~= selected_option_id then
				frame:set_image("encyclopedia_tower_thumbs_0022")
			end
		end

		function card.on_exit()
			if self.selected_option_id ~= selected_option_id then
				frame:set_image("encyclopedia_tower_thumbs_0021")
			end
		end

		self.option_cards[option_id] = {
			root = card,
			frame = frame,
			label = label,
			page = option_page
		}
	end

	self.option_page_buttons = {}

	local page_button_spacing = 36
	local page_button_x = 386 - page_button_spacing * (self.option_page_count - 1) / 2

	for page = 1, self.option_page_count do
		local page_index = page
		local page_button = EncyclopediaPageButton:new(page, false)

		page_button.anchor = v(page_button.size.x / 2, page_button.size.y / 2)
		page_button.pos = v(page_button_x + page_button_spacing * (page - 1), 412)
		page_button.page_idx = page
		page_button.deselected_image_name = "encyclopedia_pageNbr_0001"
		page_button.selected_image_name = "encyclopedia_pageNbrSelected_0001"

		function page_button.on_click()
			if self.option_page ~= page_index then
				self.option_page = page_index
				S:queue("GUIButtonCommon")
				self:refresh()
			end
		end

		book:add_child(page_button)
		table.insert(self.option_page_buttons, page_button)
	end

	local default_button = GGOptionsButton:new("Mặc định")

	default_button.anchor = v(default_button.size.x / 2, default_button.size.y / 2)
	default_button.pos = v(386, 600)
	default_button.scale = v(0.62, 0.62)
	default_button.label.font_name = "body_bold"
	default_button.label.font_size = 20
	default_button.label.fit_lines = 1

	function default_button.on_click()
		power_selection.apply_default(screen_map.user_data)
		self.selected_option_id = nil
		local _, first_slot_id = power_selection.get(screen_map.user_data, 1)

		self.detail_option_id = first_slot_id
		storage:save_slot(screen_map.user_data)
		S:queue("GUIButtonCommon")
		self:refresh()
	end

	book:add_child(default_button)

	local close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")

	close_button.pos = v(book.size.x - 52, 16)
	book:add_child(close_button)

	function close_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end

	self.close_button = close_button
end

function SpellSelectView:update_power_upgrade_detail(node)
	if node then
		local active = power_upgrades_6.is_node_active(screen_map.user_data, node)
		local state_text = node.branch and (active and "Nhánh này đang bật" or "Nhấn để chọn nhánh này") or "Nâng cấp cố định đang bật"
		local inner_balance_6 = balance_6 or require("data.balance.balance_6")
		local description = GU.balance_format(_(node.description_key), inner_balance_6) or _(node.description_key)

		balance_6 = inner_balance_6
		self.power_upgrade_detail.text = string.format("%s\n%s\n%s", _(node.name_key), description, state_text)
	else
		self.power_upgrade_detail.text = "Nhấn hoặc trỏ vào biểu tượng công nghệ để xem hiệu ứng. Tầng 1, 3 và 4 có hai nhánh, chỉ được chọn một."
	end
end

function SpellSelectView:select_option(option_id)
	if not power_selection.options[option_id] then
		return
	end

	self.detail_option_id = option_id
	self.selected_option_id = self.selected_option_id == option_id and nil or option_id
	S:queue("GUINotificationPaperOver")
	self:refresh()
end

function SpellSelectView:assign_selected_option(slot)
	local option_id = self.selected_option_id
	local assigned, reason

	if not option_id then
		return
	end

	assigned, reason = power_selection.set(screen_map.user_data, slot, option_id)

	if not assigned then
		if reason == "cataclysm_limit" then
			tower_select_show_legacy_slot_hint(self, "Chọn phép", "Chỉ được chọn tối đa một phép thuộc nhóm Thiên tai.", true)
			S:queue("GUIButtonCommon")
		end

		return
	end

	self.selected_option_id = nil
	self.detail_option_id = option_id
	storage:save_slot(screen_map.user_data)
	S:queue("GUIButtonCommon")
	self:refresh()
end

function SpellSelectView:refresh()
	for slot, row in ipairs(self.slot_rows) do
		local option = power_selection.get(screen_map.user_data, slot)

		row.frame:set_image("encyclopedia_tower_thumbs_0021")
		spell_select_set_icon(row.icon, option.map_icon or option.icon, spell_select_icon_scale(option, 0.58))
		row.name_label.text = option.label
		row.slot_label.colors.text = {100, 89, 51, 255}
	end

	local selected_id = self.selected_option_id

	for option_id, card in pairs(self.option_cards) do
		local selected = option_id == selected_id

		card.root.hidden = card.page ~= self.option_page
		card.frame:set_image(selected and "encyclopedia_tower_thumbs_0023" or "encyclopedia_tower_thumbs_0021")
		card.label.colors.text = selected and {148, 94, 58, 255} or {78, 63, 38, 255}
	end

	for page, page_button in ipairs(self.option_page_buttons) do
		if page == self.option_page then
			page_button:select()
		else
			page_button:deselect()
		end
	end

	local detail_id = self.detail_option_id

	if not power_selection.options[detail_id] then
		local _, first_slot_id = power_selection.get(screen_map.user_data, 1)

		detail_id = first_slot_id
		self.detail_option_id = detail_id
	end

	local detail_option = power_selection.options[detail_id]
	local show_power_upgrades = detail_option and detail_option.generation == 6 and detail_option.power_name and
		power_upgrades_6.powers[detail_option.power_name]

	if not show_power_upgrades or not self.hovered_power_upgrade_node or
		self.hovered_power_upgrade_node.power_name ~= detail_option.power_name then
		self.hovered_power_upgrade_node = nil
	end

	if not show_power_upgrades or not self.selected_power_upgrade_node or
		self.selected_power_upgrade_node.power_name ~= detail_option.power_name then
		self.selected_power_upgrade_node = nil
	end

	self.upgrade_info_label.text = power_selection.get_description(screen_map.user_data, detail_id)
	self.upgrade_info_label.size.y = show_power_upgrades and 105 or 470
	self.upgrade_info_label.fit_lines = show_power_upgrades and 5 or 12
	self.power_upgrade_title.hidden = not show_power_upgrades
	self.power_upgrade_detail.hidden = not show_power_upgrades

	local nodes = show_power_upgrades and power_upgrades_6.get_nodes(detail_option.power_name) or {}

	for index, button in ipairs(self.power_upgrade_buttons) do
		local node = nodes[index]

		button.node = node
		button.hidden = not node

		if node then
			local active = power_upgrades_6.is_node_active(screen_map.user_data, node)

			button:set_image(node.icon)
			button.anchor = v(button.size.x / 2, button.size.y / 2)
			button.scale = v(0.5, 0.5)
			button.alpha = active and 255 or 80
			button.branch_highlight.hidden = not (node.branch and active)
		else
			button.branch_highlight.hidden = true
		end
	end

	if show_power_upgrades then
		self:update_power_upgrade_detail(self.hovered_power_upgrade_node or self.selected_power_upgrade_node)
	end
end

function SpellSelectView:show()
	local _, changed = power_selection.normalize(screen_map.user_data)

	if changed then
		storage:save_slot(screen_map.user_data)
	end

	self.selected_option_id = nil
	self.selected_power_upgrade_node = nil
	local _, first_slot_id = power_selection.get(screen_map.user_data, 1)

	self.detail_option_id = first_slot_id
	self:refresh()
	SpellSelectView.super.show(self)
end


--新增4/5代防御塔选带系统
TowerSelectView = class("TowerSelectView", PopUpView)

function TowerSelectView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))
	-- Leave enough room for the enlarged deck controls below the book while
	-- keeping the book, page contents and tabs aligned as one unit.
	self.popup_y_offset = -48

	self.back = KView:new(V.v(sw, sh))
	self.back.pos = v(0, 0)
	self.back.anchor = v(sw / 2, sh / 2)

	self:add_child(self.back)

	self.back.alpha = 0

	local hf = sw / 2 - 700

	self.hf = hf
	--新增一个liuhui的数据table
	if screen_map.user_data.liuhui == nil then
		screen_map.user_data.liuhui = {}
	end
	if screen_map.user_data.xingyu == nil then
		screen_map.user_data.xingyu = {}
	end	
	screen_map.user_data.xingyu.balance = enemy_enhance.level(screen_map.user_data.xingyu.balance)
	if screen_map.user_data.liuhui.use3tower == nil then
		screen_map.user_data.liuhui.use3tower = true
	end
	if screen_map.user_data.liuhui.use3tower_count == nil then
		screen_map.user_data.liuhui.use3tower_count = 0
	end	
	if screen_map.user_data.liuhui.impossiblerate == nil then
		screen_map.user_data.liuhui.impossiblerate = 1.5
	end
	GS.difficulty_enemy_hp_max_factor[4] = screen_map.user_data.liuhui.impossiblerate
	if screen_map.user_data.liuhui.cheat == nil then
		screen_map.user_data.liuhui.cheat = false
	end
	if screen_map.user_data.liuhui.cheat5 == nil then
		screen_map.user_data.liuhui.cheat5 = false
	end
	if screen_map.user_data.liuhui.cheat6 == nil then
		screen_map.user_data.liuhui.cheat6 = false
	end
	if screen_map.user_data.liuhui.cheat5_special == nil then
		screen_map.user_data.liuhui.cheat5_special = false
	end
	if screen_map.user_data.liuhui.cheat5_dragon == nil then
		screen_map.user_data.liuhui.cheat5_dragon = false
	end
	if screen_map.user_data.liuhui.cheathero == nil then
		screen_map.user_data.liuhui.cheathero = false
	end
	if screen_map.user_data.liuhui.hero_enhance == nil then
		screen_map.user_data.liuhui.hero_enhance = false
	end
	if screen_map.user_data.liuhui.hero_auto_rally == nil then
		screen_map.user_data.liuhui.hero_auto_rally = false
	end
	if screen_map.user_data.liuhui.g3_hprate == nil then
		screen_map.user_data.liuhui.g3_hprate = false
	end
	if screen_map.user_data.liuhui.balance == nil then
		screen_map.user_data.liuhui.balance = false
	end	
	if screen_map.user_data.liuhui.enemy_count == nil then
		screen_map.user_data.liuhui.enemy_count = 1
	end	
	if screen_map.user_data.liuhui.reinforcement_skins == nil then
		screen_map.user_data.liuhui.reinforcement_skins = 0		
	end
	if screen_map.user_data.reinforcement_count == nil then
		screen_map.user_data.reinforcement_count = 0		
	end
	if screen_map.user_data.liuhui.g5_hero_dark_count == nil then
		screen_map.user_data.liuhui.g5_hero_dark_count = 2
	end
	if screen_map.user_data.liuhui.reinforcement_5 == nil then
		screen_map.user_data.liuhui.reinforcement_5 = "royal" 
	end
	--废案
	if screen_map.user_data.liuhui.cp_mode == nil or screen_map.user_data.liuhui.cp_mode == true then
		screen_map.user_data.liuhui.cp_mode = false
	end
	if screen_map.user_data.liuhui.rand_creep == nil then
		screen_map.user_data.liuhui.rand_creep = 0
	end
	if screen_map.user_data.liuhui.rand_tower == nil then
		screen_map.user_data.liuhui.rand_tower = 0
	end
	if screen_map.user_data.liuhui.rand_tower_mode == nil then
		screen_map.user_data.liuhui.rand_tower_mode = 0
	end
	if screen_map.user_data.liuhui.rand_hero == nil then
		screen_map.user_data.liuhui.rand_hero = 0
	end
	if screen_map.user_data.liuhui.g4range_balance == nil then
		screen_map.user_data.liuhui.g4range_balance = 1
	end
--需要确定并加载防御塔数据，首次进入默认携带5代前20塔，局内最多携带20塔。
	local MAX_TOWER = 20
	self.alliance_num = 21
	self.vegnance_num = 22
	self.genesis_num = map_data.tower_6_count or 15
	self.max_tower = MAX_TOWER
	local _, tower_generation_migrated = tower_loadout.normalize(screen_map.user_data)
	local tower_status = screen_map.user_data.towers
	local previous_tower_count = tower_status and #tower_status or 0
	local tower_selection_migrated = tower_generation_migrated
	local tmp_list = {
		[1] = 1;
		[2] = 2;
		[3] = 3;
		[4] = 4;
		[5] = 5;
		[6] = 6;
		[7] = 7;
		[8] = 8;
		[9] = 9;
		[10] = 10;
		[11] = 11;
		[12] = 12;
		[13] = 13;
		[14] = 14;
		[15] = 15;
		[16] = 16;
		[17] = 17;
		[18] = 18;
		[19] = 19;
		[20] = 20;
	}
	if tower_status == nil then
		screen_map.user_data.towers = tmp_list
		tower_selection_migrated = true
	else
		local normalized_towers = {}
		local used_towers = {}
		local total_towers = self.alliance_num + self.vegnance_num + self.genesis_num

		for _, tower_num in ipairs(tower_status) do
			if type(tower_num) == "number" and tower_num >= 1 and tower_num <= total_towers and not used_towers[tower_num] and #normalized_towers < MAX_TOWER then
				table.insert(normalized_towers, tower_num)
				used_towers[tower_num] = true
			end
		end

		for tower_num = 1, total_towers do
			if #normalized_towers >= MAX_TOWER then
				break
			end

			if not used_towers[tower_num] then
				table.insert(normalized_towers, tower_num)
				used_towers[tower_num] = true
			end
		end

		local selection_changed = #normalized_towers ~= #tower_status

		if not selection_changed then
			for i, tower_num in ipairs(normalized_towers) do
				if tower_status[i] ~= tower_num then
					selection_changed = true

					break
				end
			end
		end

		if selection_changed then
			screen_map.user_data.towers = normalized_towers
			tower_selection_migrated = true
		end
	end

	local tower_pick = screen_map.user_data.tower_pick
	if tower_pick == nil or previous_tower_count == 0 then
		screen_map.user_data.tower_pick = MAX_TOWER
		tower_selection_migrated = true
	elseif previous_tower_count == 12 and tower_pick == 12 then
		-- Migrate an old "maximum selected" save to the new maximum.
		screen_map.user_data.tower_pick = MAX_TOWER
		tower_selection_migrated = true
	else
		screen_map.user_data.tower_pick = km.clamp(1, MAX_TOWER, tower_pick)
		tower_selection_migrated = tower_selection_migrated or screen_map.user_data.tower_pick ~= tower_pick
	end

	if tower_selection_migrated then
		storage:save_slot(screen_map.user_data)
	end

	self.selected_tower = 0
	self.selected_legacy_tower = nil

	self.backback = KImageView:new("encyclopedia_bg")
	self.backback.anchor = v(self.backback.size.x / 2, self.backback.size.y / 2)
	self.backback.pos = v(sw / 2, sh / 2)
	--self.backback.scale = v(1, 1)
	self.tower_generation_tab = "g45"

	self.g45_tab_button = KImageButton:new("encyclopedia_buttons_notxt_0002", "encyclopedia_buttons_notxt_0003", "encyclopedia_buttons_notxt_0003")
	self.g45_tab_button.pos = v(hf + 300, 100)
	self.g45_tab_button.hidden = true
	self.back:add_child(self.g45_tab_button)

	function self.g45_tab_button.on_click()
		S:queue("GUIButtonCommon")
		self:set_tower_generation_tab("g45")
	end

	local g45_tab_label = EncyclopediaTabLabel:new("Phần 4–6", false)

	g45_tab_label.pos.x, g45_tab_label.pos.y = 56, 86
	self.g45_tab_button:add_child(g45_tab_label)

	self.g45_tab_selected = KImageView:new("encyclopedia_buttons_notxt_0001")
	self.g45_tab_selected.pos = v(hf + 300, 100)
	self.back:add_child(self.g45_tab_selected)

	local g45_selected_label = EncyclopediaTabLabel:new("Phần 4–6", true)

	g45_selected_label.pos.x, g45_selected_label.pos.y = 56, ISW(81, "zh-Hans", 81)
	self.g45_tab_selected:add_child(g45_selected_label)

	self.legacy_tab_button = KImageButton:new("encyclopedia_buttons_notxt_0002", "encyclopedia_buttons_notxt_0003", "encyclopedia_buttons_notxt_0003")
	self.legacy_tab_button.pos = v(hf + 400, 90)
	self.back:add_child(self.legacy_tab_button)

	function self.legacy_tab_button.on_click()
		S:queue("GUIButtonCommon")
		self:set_tower_generation_tab("legacy")
	end

	local legacy_tab_label = EncyclopediaTabLabel:new("Phần 1–3", false, 2 * math.pi / 180)

	legacy_tab_label.pos.x, legacy_tab_label.pos.y = 56, ISW(88, "zh-Hans", 90)
	self.legacy_tab_button:add_child(legacy_tab_label)

	self.legacy_tab_selected = KImageView:new("encyclopedia_buttons_notxt_0001")
	self.legacy_tab_selected.pos = v(hf + 400, 90)
	self.legacy_tab_selected.hidden = true
	self.back:add_child(self.legacy_tab_selected)

	local legacy_selected_label = EncyclopediaTabLabel:new("Phần 1–3", true, 2 * math.pi / 180)

	legacy_selected_label.pos.x, legacy_selected_label.pos.y = 56, 81
	self.legacy_tab_selected:add_child(legacy_selected_label)

	self.special_tab_button = KImageButton:new("encyclopedia_buttons_notxt_0002", "encyclopedia_buttons_notxt_0003", "encyclopedia_buttons_notxt_0003")
	self.special_tab_button.pos = v(hf + 500, 100)
	self.back:add_child(self.special_tab_button)

	function self.special_tab_button.on_click()
		S:queue("GUIButtonCommon")
		self:set_tower_generation_tab("special")
	end

	local special_tab_label = EncyclopediaTabLabel:new("Tháp đặc biệt", false)

	special_tab_label.pos.x, special_tab_label.pos.y = 56, 86
	self.special_tab_button:add_child(special_tab_label)

	self.special_tab_selected = KImageView:new("encyclopedia_buttons_notxt_0001")
	self.special_tab_selected.pos = v(hf + 500, 100)
	self.special_tab_selected.hidden = true
	self.back:add_child(self.special_tab_selected)

	local special_selected_label = EncyclopediaTabLabel:new("Tháp đặc biệt", true)

	special_selected_label.pos.x, special_selected_label.pos.y = 56, ISW(81, "zh-Hans", 81)
	self.special_tab_selected:add_child(special_selected_label)

	-- Keep the tab roots behind the book, matching the encyclopedia layering.
	self.back:add_child(self.backback)

	self:create_tower_deck_panel()

	-- Keep the book close button as the last child so it is drawn and receives
	-- input above the tower-selection controls.
	local close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")

	close_button.pos = v(self.backback.size.x - 52, 16)
	self.close_button = close_button
	self.backback:add_child(close_button)

	function self.close_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end

end

local function tower_deck_label(text, size, font_size)
	local label = GGLabel:new(size)

	label.font_name = "body_bold"
	label.font_size = font_size or 18
	label.colors.text = {245, 230, 180, 255}
	label.text = text
	label.text_align = "center"
	label.vertical_align = "middle"
	label.fit_lines = 2

	return label
end

local function tower_deck_set_scaled_image(image_view, image_name, max_width, max_height)
	image_view:set_image(image_name)
	image_view.anchor = v(image_view.size.x / 2, image_view.size.y / 2)

	local scale = math.min(max_width / image_view.size.x, max_height / image_view.size.y)

	image_view.scale = v(scale, scale)
end

local function tower_deck_high_icon(tower_index)
	local tower_entry = map_data.tower_5_data and map_data.tower_5_data[tower_index]

	if tower_entry and tower_entry.selector_icon then
		return tower_entry.selector_icon
	end

	local icon_index = global_icon_idx[tower_index]

	if not icon_index then
		return "encyclopedia_tower_thumbs_lock"
	elseif icon_index > 400 then
		return string.format("towerselect_quickmenu_icons_%04i", icon_index - 400)
	end

	return string.format(GS.tower_room_tower_thumb_fmt, icon_index)
end

local function tower_deck_high_icon_size(tower_index, alliance_num, vengeance_num)
	if tower_index and tower_index <= (alliance_num or 0) + (vengeance_num or 0) then
		return 50
	end

	-- Sixth-generation selector icons fill their 113px canvas.
	return 42
end

local function tower_deck_outline(width, height)
	local outline = KView:new(V.v(width, height))
	local color = {255, 205, 60, 255}
	local edges = {
		{0, 0, width, 3},
		{0, height - 3, width, 3},
		{0, 0, 3, height},
		{width - 3, 0, 3, height}
	}

	outline.propagate_on_click = true

	for _, edge in ipairs(edges) do
		local line = KView:new(V.v(edge[3], edge[4]))

		line.pos = v(edge[1], edge[2])
		line.colors.background = color
		line.propagate_on_click = true
		outline:add_child(line)
	end

	return outline
end

function TowerSelectView:create_tower_deck_panel()
	local panel = KView:new(V.v(1280, 192))

	panel.pos = v((self.sw - panel.size.x) / 2, self.sh / 2 + self.backback.size.y / 2 - 8)
	panel.colors.background = {37, 31, 22, 248}
	self.back:add_child(panel)
	self.deck_panel = panel

	local divider = KView:new(V.v(2, panel.size.y - 16))

	divider.pos = v(490, 8)
	divider.colors.background = {105, 87, 55, 220}
	panel:add_child(divider)

	self.legacy_mode_outline = tower_deck_outline(484, panel.size.y - 4)
	self.legacy_mode_outline.pos = v(3, 2)
	panel:add_child(self.legacy_mode_outline)

	self.high_mode_outline = tower_deck_outline(panel.size.x - 498, panel.size.y - 4)
	self.high_mode_outline.pos = v(495, 2)
	panel:add_child(self.high_mode_outline)

	local legacy_title = tower_deck_label("Phần 1–3", V.v(474, 29), 22)

	legacy_title.pos = v(8, 2)
	panel:add_child(legacy_title)

	local legacy_help = tower_deck_label("Nhấn biểu tượng để chọn bộ tháp mang theo; giữ ít nhất một bộ.", V.v(474, 31), 17)

	legacy_help.pos = v(8, 29)
	legacy_help.colors.text = {224, 211, 170, 255}
	panel:add_child(legacy_help)

	local high_title = tower_deck_label("Phần 4–6", V.v(770, 29), 22)

	high_title.pos = v(502, 2)
	panel:add_child(high_title)

	local high_help = tower_deck_label("Chọn tháp phía trên, rồi nhấn ô để thay. Số tháp mang theo quyết định số ô được dùng.", V.v(770, 31), 17)

	high_help.pos = v(502, 29)
	high_help.colors.text = {224, 211, 170, 255}
	panel:add_child(high_help)

	self.generation_slots = {}
	local generation_icons = {
		string.format(GS.encyclopedia_tower_thumb_fmt, 101),
		string.format(GS.encyclopedia_tower_thumb_fmt, 201),
		string.format(GS.encyclopedia_tower_thumb_fmt, 1),
		string.format(GS.encyclopedia_tower_thumb_fmt, 660),
		"kr6_icon_room_tower_archer_kr1"
	}
	local generation_names = {"Phần 1", "Phần 2", "Phần 3", "KRC", "Phần 6"}
	local generation_x = {10, 105, 200, 295, 390}

	for i = 1, tower_loadout.GENERATION_COUNT do
		local generation = i
		local slot = KView:new(V.v(90, 124))

		slot.pos = v(generation_x[i], 60)
		slot.colors.background = {34, 28, 20, 255}
		panel:add_child(slot)

		local frame = KImageView:new("encyclopedia_tower_thumbs_0021")

		frame.anchor = v(frame.size.x / 2, frame.size.y / 2)
		frame.pos = v(45, 41)
		frame.scale = v(0.9, 0.9)
		frame.propagate_on_click = true
		slot:add_child(frame)

		local icon = KImageView:new(generation_icons[i])

		icon.pos = v(45, 41)
		icon.propagate_on_click = true
		tower_deck_set_scaled_image(icon, generation_icons[i], 62, 58)
		slot:add_child(icon)

		local label = tower_deck_label(generation_names[i], V.v(90, 28), i == 4 and 14 or 18)

		label.pos = v(0, 91)
		label.propagate_on_click = true
		slot:add_child(label)

		function slot.on_click()
			local generations = tower_loadout.normalize(screen_map.user_data)

			if generations[generation] then
				local enabled_count = 0

				for j = 1, tower_loadout.GENERATION_COUNT do
					if generations[j] then
						enabled_count = enabled_count + 1
					end
				end

				if enabled_count <= 1 then
					tower_select_show_legacy_slot_hint(self, "Chọn đội tháp", "Phải giữ ít nhất một tháp trong nhóm này. Để chỉ dùng tháp KR4-6, chuyển tùy chọn sang Ba phần sau.", true)
					S:queue("GUIButtonCommon")

					return
				end
			end

			generations[generation] = not generations[generation]
			storage:save_slot(screen_map.user_data)
			S:queue("GUIButtonCommon")
			self:update_selected_tower()
		end

		slot.frame = frame
		slot.label = label
		self.generation_slots[i] = slot
	end

	self.high_tower_slots = {}

	for i = 1, self.max_tower do
		local slot_index = i
		local slot = KView:new(V.v(52, 56))
		local column = math.fmod(i - 1, 10)
		local row = math.floor((i - 1) / 10)

		slot.pos = v(506 + column * 55, 62 + row * 59)
		slot.colors.background = {34, 28, 20, 255}
		panel:add_child(slot)

		local frame = KImageView:new("encyclopedia_tower_thumbs_0021")

		frame.anchor = v(frame.size.x / 2, frame.size.y / 2)
		frame.pos = v(26, 28)
		frame.scale = v(0.62, 0.62)
		frame.propagate_on_click = true
		slot:add_child(frame)

		local tower_index = screen_map.user_data.towers[i]
		local portrait = KImageView:new(tower_deck_high_icon(tower_index))
		local portrait_size = tower_deck_high_icon_size(tower_index, self.alliance_num, self.vegnance_num)

		portrait.pos = v(26, 28)
		portrait.propagate_on_click = true
		tower_deck_set_scaled_image(portrait, tower_deck_high_icon(tower_index), portrait_size, portrait_size)
		slot:add_child(portrait)

		function slot.on_click()
			self:try_select(slot_index)
		end

		slot.frame = frame
		slot.portrait = portrait
		self.high_tower_slots[i] = slot
	end

	local mode_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	mode_button.anchor = v(mode_button.size.x / 2, mode_button.size.y / 2)
	mode_button.pos = v(1166.5, 79)
	mode_button.scale = v(0.8, 0.8)
	mode_button.label.size = v(mode_button.size.x, mode_button.size.y)
	mode_button.label.text_size = mode_button.label.size
	mode_button.label.pos = v(0, 0)
	mode_button.label.font_size = 20
	mode_button.label.font_name = "sans_bold"
	mode_button.label.text_align = "center"
	mode_button.label.vertical_align = "middle"
	mode_button.label.fit_lines = 1

	function mode_button.on_click()
		screen_map.user_data.liuhui.use3tower_count = math.fmod((screen_map.user_data.liuhui.use3tower_count or 0) + 1, 3)
		storage:save_slot(screen_map.user_data)
		S:queue("GUIButtonCommon")
		self:update_selected_tower()
	end

	self.mode_button = mode_button
	panel:add_child(mode_button)

	local count_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	count_button.anchor = v(count_button.size.x / 2, count_button.size.y / 2)
	count_button.pos = v(1166.5, 145)
	count_button.scale = v(0.8, 0.8)
	count_button.label.size = v(count_button.size.x, count_button.size.y)
	count_button.label.text_size = count_button.label.size
	count_button.label.pos = v(0, 0)
	count_button.label.font_size = 20
	count_button.label.font_name = "sans_bold"
	count_button.label.text_align = "center"
	count_button.label.vertical_align = "middle"
	count_button.label.fit_lines = 1

	function count_button.on_click()
		local tower_pick = screen_map.user_data.tower_pick

		if tower_pick <= 4 then
			tower_pick = self.max_tower
		else
			tower_pick = tower_pick - 4
		end

		screen_map.user_data.tower_pick = tower_pick
		storage:save_slot(screen_map.user_data)
		S:queue("GUIButtonCommon")
		self:update_selected_tower()
	end

	self.count_button = count_button
	panel:add_child(count_button)
	self:update_selected_tower()
end

function TowerSelectView:set_tower_generation_tab(tab)
	local legacy_tab = tab == "legacy"
	local special_tab = tab == "special"
	local g45_tab = not legacy_tab and not special_tab

	self.tower_generation_tab = special_tab and "special" or legacy_tab and "legacy" or "g45"
	self.g45_tab_button.hidden = g45_tab
	self.g45_tab_selected.hidden = not g45_tab
	self.legacy_tab_button.hidden = legacy_tab
	self.legacy_tab_selected.hidden = not legacy_tab
	self.special_tab_button.hidden = special_tab
	self.special_tab_selected.hidden = not special_tab
	self.selected_tower = 0
	self.selected_legacy_tower = nil

	self:load_towers(1)
end

--起始和每次刷新都需要调用一次本函数
function TowerSelectView:update_selected_tower()
	local generations = tower_loadout.normalize(screen_map.user_data)
	local tower_mode = km.clamp(0, 2, screen_map.user_data.liuhui.use3tower_count or 0)

	if self.legacy_mode_outline then
		self.legacy_mode_outline.hidden = tower_mode == 2
	end

	if self.high_mode_outline then
		self.high_mode_outline.hidden = tower_mode == 1
	end

	for i, slot in ipairs(self.generation_slots or {}) do
		local enabled = generations[i]

		slot.frame:set_image(enabled and "encyclopedia_tower_thumbs_0023" or "encyclopedia_tower_thumbs_0021")
		slot.label.colors.text = enabled and {255, 226, 92, 255} or {190, 184, 164, 255}
	end

	for i, slot in ipairs(self.high_tower_slots or {}) do
		local tower_index = screen_map.user_data.towers[i]
		local enabled = i <= screen_map.user_data.tower_pick
		local portrait_size = tower_deck_high_icon_size(tower_index, self.alliance_num, self.vegnance_num)

		tower_deck_set_scaled_image(slot.portrait, tower_deck_high_icon(tower_index), portrait_size, portrait_size)
		slot.frame:set_image(enabled and "encyclopedia_tower_thumbs_0023" or "encyclopedia_tower_thumbs_0021")
		slot.colors.background = enabled and {72, 57, 22, 255} or {34, 28, 20, 255}
		slot.portrait.alpha = enabled and 1 or 0.42
		slot.frame.alpha = enabled and 1 or 0.62
	end

	if self.count_button then
		self.count_button.label.text = string.format(_("TOWER_G45_PICK"), screen_map.user_data.tower_pick)
	end

	if self.mode_button then
		self.mode_button.label.text = _("USE3TOOWER_COUNT_" .. tower_mode)
	end

	if self.right_panel and self.right_panel.order_to_front then
		self.right_panel:order_to_front()
	end

	if self.g5_button then
		self.g5_button.label.text = screen_map.user_data.liuhui.cheat5 and _("G5_SELECT") or _("G5_DESELECT")
	end
	if self.g5_special_button then
		self.g5_special_button.label.text = screen_map.user_data.liuhui.cheat5_special and _("G5_SPECIAL_SELECT") or _("G5_SPECIAL_DESELECT")
	end
	if self.g5_dragon_button then
		self.g5_dragon_button.label.text = screen_map.user_data.liuhui.cheat5_dragon and _("G5_DRAGON_SPECIAL") or _("G5_DRAGON_DESELECT")
	end
	--[[
	self.cheat_hero_button.label.text = screen_map.user_data.liuhui.cheathero and _("CHEAT_HERO") or _("NO_CHEAT_HERO")
	self.cheat_button.label.text = screen_map.user_data.liuhui.cheat and _("CHEAT_GOLD") or _("NO_CHEAT_GOLD")
	self.g3_hprate_button.label.text = screen_map.user_data.liuhui.g3_hprate and _("G3_CALRATE") or _("G3_STANDARD")
	self.g5_button.label.text = screen_map.user_data.liuhui.cheat5 and _("G5_SELECT") or _("G5_DESELECT")
	self.g5_dragon_button.label.text = screen_map.user_data.liuhui.cheat5_dragon and _("G5_DRAGON_SPECIAL") or _("G5_DRAGON_DESELECT")
	self.ecound_button.label.text = _("LH349_ENEMY_COUNT_"..(screen_map.user_data.liuhui.enemy_count or 1))
	self.g5_hero_button.label.text = _("G5_HERO_DARK_COUNT_"..screen_map.user_data.liuhui.g5_hero_dark_count or 2)
	self.g5_reinforcement_button.label.text = _("G5_REINFORCEMENT_"..((screen_map.user_data.liuhui.reinforcement_5=="dark")and 2 or 1))
	self.reinforcement_skin_button.label.text =  _("LH349_REINFORCEMENT_SKIN_"..screen_map.user_data.liuhui.reinforcement_skins or 0)
	self.reinforcement_count_button.label.text = _("REINFORCEMENT_"..screen_map.user_data.reinforcement_count or 0)
	self.balance_button.label.text = screen_map.user_data.liuhui.balance and _("FLBALANCE") or _("FLSTANDARD")
	--self.xingyu_button.label.text = enemy_enhance_label(screen_map.user_data.xingyu.balance)
	self.g4range_balance_button.label.text = screen_map.user_data.liuhui.g4range_balance and _("FL_RANGE_BALANCE") or _("FL_RANGE_STD")
	self.stim.text = _("ImpossibleHPRate")..string.format("%.2f", screen_map.user_data.liuhui.impossiblerate)
	self.rand_button_1.label.text = _("RAND_CREEP_"..(screen_map.user_data.liuhui.rand_creep or 0))
	self.rand_button_2.label.text = _("RAND_TOWER_"..(screen_map.user_data.liuhui.rand_tower or 0))
	self.rand_button_22.label.text = _("RAND_TOWER_MODE_"..(screen_map.user_data.liuhui.rand_tower_mode or 0))
	self.rand_button_3.label.text = _("RAND_HERO_"..(screen_map.user_data.liuhui.rand_hero or 0))
	]]

end

function TowerSelectView:try_select(index)
	if self.selected_legacy_tower then
		S:queue("GUIButtonCommon")
		tower_select_show_legacy_slot_hint(self)

		return
	end

	if self.selected_tower == 0 then return end
	local judge = 0
	for i, value in ipairs(screen_map.user_data.towers) do
		if self.selected_tower == value then
			if index == i then return end
			judge = i
			break
		end
	end
	if judge ~= 0 then
		screen_map.user_data.towers[judge] = screen_map.user_data.towers[index]
	end
	screen_map.user_data.towers[index] = self.selected_tower
	self.select_sprite.hidden = true
	
	storage:save_slot(screen_map.user_data)
	--S:queue("GUIButtonCommon")
	map_data = require("data.map_data")
	e = E:get_template(map_data.tower_menu_json[self.selected_tower].action_arg)
	t = E:get_template(e.build_name)
	local select_sound = t.sound_events.tower_room_select or t.sound_events.room_select or t.sound_events.insert

	S:queue(select_sound)
	self.selected_tower = 0
	self.selected_legacy_tower = nil
	self:update_selected_tower()
end

function TowerSelectView:show()
	TowerSelectView.super.show(self)

	local user_data = storage:load_slot()

	E:load()
	UPGR:set_all_generation_levels(user_data)
	DI:set_level(screen_map.user_data.difficulty)
	UPGR:patch_templates(5)
	DI:patch_templates()
	self:set_tower_generation_tab("g45")
	self:show_first_open_help()
end

function TowerSelectView:hide()
	if screen_map.new_player_setup_stage == "tower" then
		local has_generation_four_tower = false

		for _, tower_index in ipairs(screen_map.user_data.towers or {}) do
			if tower_index > self.alliance_num then
				has_generation_four_tower = true

				break
			end
		end

		if not has_generation_four_tower then
			tower_select_show_legacy_slot_hint(self, tower_select_tutorial_required_title, tower_select_tutorial_required_text)

			return
		end
	end

	TowerSelectView.super.hide(self)

	if screen_map.new_player_setup_stage == "tower" then
		screen_map.new_player_setup_stage = nil

		if screen_map.hero_room then
			screen_map.hero_room:show()
		end
	end
end

function TowerSelectView:show_first_open_help()
	local seen = screen_map_seen_table()

	if not seen or (seen.tower_room_help and not DBG_SHOW_BALLOONS) then
		return
	end

	if self.tower_room_help and self.tower_room_help.parent then
		self.tower_room_help:order_to_front()

		return
	end

	local view_w = self.sw or self.size.x
	local view_h = self.sh or self.size.y
	local help = KView:new(V.v(view_w, view_h))

	help.pos = v(0, 0)

	function help.on_click()
		if self.tower_room_help and self.tower_room_help.parent then
			self.tower_room_help.parent:remove_child(self.tower_room_help)
		end

		self.tower_room_help = nil
		screen_map_mark_seen("tower_room_help")
	end

	local help_g45 = screen_map_text_balloon("heroroom_help_abilities_notxt", "Các thẻ phía trên mở trang chọn tháp phần 4–6,\ntrang thông tin phần 1–3 và tháp đặc biệt.", V.v(326, 44), v(12, 12), 19)

	help_g45.pos = v(self.hf + 315, 120)
	help:add_child(help_g45)

	local help_legacy = screen_map_text_balloon("heroroom_help_abilities_notxt", "Chọn bộ tháp cơ bản phần 1/2/3, KR Conquest\nvà Genesis bằng các biểu tượng dưới bên trái.", V.v(326, 44), v(12, 12), 18)

	help_legacy.pos = v(self.hf + 170, 855)
	help:add_child(help_legacy)

	local help_default, help_default_label = screen_map_text_balloon("heroroom_help_abilities_notxt", "Muốn dùng tháp phần 4/6, hãy sang trang 2/3 để thiết lập.", V.v(326, 58), v(12, 8), 18)

	help_default_label.fit_lines = 3
	help_default.pos = v(self.hf + 875, 855)
	help:add_child(help_default)

	local help_continue = screen_map_text_balloon("mapBalloon_starthere_notxt", "Nhấn để tiếp tục", V.v(154, 28), v(13, 8), 18)

	help_continue.anchor = v(help_continue.size.x / 2, help_continue.size.y)
	help_continue.pos = v(view_w / 2, view_h - 125)
	help:add_child(help_continue)

	self.tower_room_help = help
	self.back:add_child(help)
end

function TowerSelectView:hide_tower_power_popup()
	if self.legacy_slot_hint_popup then
		tower_select_hide_legacy_slot_hint(self)

		return true
	end

	if self.right_panel and self.right_panel.power_popup then
		encyclopedia_hide_tower_power_popup(self.right_panel)

		return true
	end

	return false
end

function TowerSelectView:load_towers(index)
	tower_select_hide_legacy_slot_hint(self)

	local legacy_tab = self.tower_generation_tab == "legacy"
	local special_tab = self.tower_generation_tab == "special"
	local read_only_tab = legacy_tab or special_tab
	local detail_indices = legacy_tab and tower_select_legacy_detail_indices() or special_tab and tower_select_special_detail_indices() or nil
	local legacy_page_size = 24
	local total_pages = read_only_tab and math.max(1, math.ceil(#detail_indices / legacy_page_size)) or 3

	index = km.clamp(1, total_pages, index or 1)
	self.current_tower_page = index
	self.selected_legacy_tower = nil

	if self.towers then
		self.back:remove_child(self.towers)
	end
	self.towers = KView:new(V.v(366, 444))
	self.towers.pos = v(self.hf + 310, 200)
	self.back:add_child(self.towers)

	local title = GGLabel:new(V.v(self.towers.size.x, 70))
	title.pos.y = 32
	title.font_name = "h_book"
	title.font_size = 40
	title.font_align = "center"
	title.colors.text = {
		100,
		89,
		51,
		255
	}
	title.text = _("Towers")
	title.fit_lines = 1
	self.towers:add_child(title)

	local title_w = math.min(title:get_text_width(title.text), self.towers.size.x - 90)
	local deco_y = 60
	local left_deco = KImageView:new("encyclopedia_rightArt")
	left_deco.pos = v(self.towers.size.x / 2 - title_w / 2 - 10, deco_y)
	left_deco.anchor = v(left_deco.size.x, left_deco.size.y / 2)
	self.towers:add_child(left_deco)

	local right_deco = KImageView:new("encyclopedia_rightArt")
	right_deco.pos = v(self.towers.size.x / 2 + title_w / 2 + 13, deco_y)
	right_deco.anchor = v(right_deco.size.x, right_deco.size.y / 2)
	right_deco.scale.x = -1
	self.towers:add_child(right_deco)

	local st1 = GGLabel:new(V.v(self.towers.size.x, 24))
	st1.pos.y = 76
	st1.font_name = "body"
	st1.font_size = 15
	st1.font_align = "center"
	st1.colors.text = {
		100,
		89,
		51,
		255
	}
	st1.text = legacy_tab and "Tháp cao cấp phần 1/2/3 và 6 (chỉ xem)" or special_tab and "Tháp đặc biệt (chỉ xem)" or _("TowerList_G5")
	st1.fit_lines = 1
	self.st1 = st1

	self.towers:add_child(self.st1)

	local st2 = GGLabel:new(V.v(self.towers.size.x, 112))
	st2.pos.y = 435
	st2.font_name = "body"
	st2.font_size = 17
	st2.font_align = "center"
	st2.colors.text = {
		100,
		89,
		51,
		255
	}
	st2.text = legacy_tab and "Trang này giới thiệu tháp phần 1/2/3. Nâng tháp cơ bản lên cấp 3 để mở dạng cao cấp. Chọn bộ tháp phần 1–3 bằng các biểu tượng dưới bên trái." or special_tab and "Trang này giới thiệu tháp NPC và tháp đặc biệt. Nhấn Cách xây tháp để xem hướng dẫn." or "Trang này giới thiệu tháp phần 4/5/6. Chọn tháp, rồi nhấn ô thuộc phần 4–6 phía dưới bên phải để thêm vào bộ."
	st2.fit_lines = 5
	self.towers:add_child(st2)

	if read_only_tab then
		self.selected_tower = 0

		local first_item = (index - 1) * legacy_page_size + 1
		local last_item = math.min(first_item + legacy_page_size - 1, #detail_indices)

		for item_index = first_item, last_item do
			local i = item_index - first_item + 1
			local detail_index = detail_indices[item_index]
			local tower_data = screen_map.tower_data[detail_index]
			local icon_idx = tower_data.icon or detail_index
			local icon = tower_data.generation == 6 and string.format(GS.encyclopedia_tower_fmt, icon_idx) or string.format(GS.encyclopedia_tower_thumb_fmt, icon_idx)
			local pos = v(math.fmod(i - 1, 6) * 70 + 5, math.floor((i - 1) / 6) * 74 + 138)

			self:create_legacy_tower(icon, pos, detail_index)
		end
	elseif index == 1 then
		for i = 1, self.alliance_num do
			local num = i
			--local icon_idx = screen_map.tower_5_data[num].icon or num -- 5和14缺失
			local icon_idx_1 = global_icon_idx[num]
			local icon = string.format(GS.tower_room_tower_thumb_fmt, icon_idx_1)
			local off_y = i <= 18 and 138 or 138
			self:create_tower(icon, v(math.fmod(i - 1, 6) * 70 + 5, math.floor((i - 1) / 6) * 74 + off_y), num, true)
			self.st1.text = _("TowerList_G5")
		end
	elseif index == 2 then
		for i = self.alliance_num+1, self.alliance_num + self.vegnance_num do
			local num = i
			--local icon_idx = screen_map.tower_5_data[num].icon or num -- 5和14缺失
			local icon_idx_1 = global_icon_idx[num]
			local icon = string.format("towerselect_quickmenu_icons_%04i", icon_idx_1 - 400)
			local off_y = i <= 18 and 138 or 138
			--self:create_tower(icon, v(math.fmod(i - 1, 4) * 88 + 50, math.floor((i - 1) / 4) * 85 + off_y), num, true)
			self:create_tower(icon, v(math.fmod(i - 1 - self.alliance_num, 6) * 70 + 5, math.floor((i - 1 - self.alliance_num) / 6) * 74 + off_y), num, true)
			self.st1.text = _("TowerList_G4")
		end
	elseif index == 3 then
		local first_genesis = self.alliance_num + self.vegnance_num + 1
		local last_genesis = first_genesis + self.genesis_num - 1

		for i = first_genesis, last_genesis do
			local tower_entry = map_data.tower_5_data[i]
			local icon = tower_entry and tower_entry.selector_icon or "encyclopedia_tower_thumbs_lock"
			local local_index = i - first_genesis

			self:create_tower(icon, v(math.fmod(local_index, 6) * 70 + 5, math.floor(local_index / 6) * 74 + 138), i, true)
		end

		self.st1.text = "Tháp phần 6"
	end

	self.over_sprite = KImageView:new("encyclopedia_tower_thumbs_0022")
	self.over_sprite.anchor = v(self.over_sprite.size.x / 2, self.over_sprite.size.y / 2)
	self.over_sprite.hidden = true
	self.over_sprite.propagate_on_click = true
	self.towers:add_child(self.over_sprite)

	self.select_sprite = KImageView:new("encyclopedia_tower_thumbs_0023")
	self.select_sprite.anchor = v(self.select_sprite.size.x / 2, self.select_sprite.size.y / 2)
	self.select_sprite.hidden = true
	self.towers:add_child(self.select_sprite)

	self.page_buttons_tower = {}
	local boffset = 40
	local bx, by = self.towers.size.x / 2 - boffset * (total_pages - 1) / 2, 572

	-- page bar
	for i = 1, total_pages do
		if i == index then
			local btn = EncyclopediaPageButton:new(i, true)

			btn.anchor = v(btn.size.x / 2, btn.size.y / 2)
			btn.pos = v(bx + boffset * (i - 1), by)
			btn.page_idx = i
			self.towers:add_child(btn)
			
			table.insert(self.page_buttons_tower, btn)
		else
			local btn = EncyclopediaPageButton:new(i, false)

			btn.anchor = v(btn.size.x / 2, btn.size.y / 2)
			btn.pos = v(bx + boffset * (i - 1), by)
			btn.page_idx = i
			function btn.on_click(this, button, x, y)
				S:queue("GUIButtonCommon")
				self:load_towers(this.page_idx)
			end
			self.towers:add_child(btn)
			table.insert(self.page_buttons_tower, btn)
		end
	end

	self:update_selected_tower()

	local detail_index

	if read_only_tab then
		detail_index = detail_indices[(index - 1) * legacy_page_size + 1]
	else
		local first_tower = index == 1 and 1 or index == 2 and self.alliance_num + 1 or self.alliance_num + self.vegnance_num + 1

		detail_index = tower_select_detail_index(first_tower)
	end

	if detail_index then
		self:detail_tower(detail_index)
	elseif self.right_panel then
		self.back:remove_child(self.right_panel)

		self.right_panel = nil
	end
end

function TowerSelectView:create_legacy_tower(icon, pos, detail_index)
	local tower = KButton:new()

	tower:set_image(icon)

	tower.anchor = v(tower.size.x / 2, tower.size.y / 2)
	tower.pos = pos

	local tower_entry = screen_map.tower_data[detail_index]
	local is_special_tower = screen_map_is_special_tower_entry(tower_entry)

	if tower_entry.generation == 6 then
		local icon_scale = tower_encyclopedia_icon_scale(tower)

		tower.scale = v(icon_scale, icon_scale)
	else
		local original_scale = is_special_tower and 0.8 or 0.88
		local icon_scale = math.max(original_scale, math.min(64 / tower.size.x, 64 / tower.size.y))

		tower.scale = v(icon_scale, icon_scale)
	end

	self.towers:add_child(tower)

	function tower.on_enter()
		self:update_over_sprite(tower.pos)
	end

	function tower.on_exit()
		self:remove_over_sprite()
	end

	function tower.on_click()
		S:queue("GUINotificationPaperOver")

		self.selected_tower = 0
		self.selected_legacy_tower = detail_index
		self.select_sprite.hidden = false
		self.select_sprite.pos = pos

		self:detail_tower(detail_index)
	end
end

function TowerSelectView:create_tower(icon, pos, information, enabled)
	--if information <= 4 or screen_map.user_data.seen[screen_map.tower_data[information].name] then
		local tower = KButton:new()

		tower:set_image(icon)

		tower.anchor = v(tower.size.x / 2, tower.size.y / 2)
		tower.pos = pos
		if information > self.alliance_num + self.vegnance_num then
			tower.scale = v(0.48, 0.48)
		else
			local original_scale = information > self.alliance_num and 0.42 or 1.2
			local icon_scale = math.max(original_scale, math.min(60 / tower.size.x, 60 / tower.size.y))

			tower.scale = v(icon_scale, icon_scale)
		end

		self.towers:add_child(tower)
		function tower.on_enter()
			self:update_over_sprite(tower.pos)
		end

		function tower.on_exit()
			self:remove_over_sprite()
		end

		function tower.on_click()
			S:queue("GUINotificationPaperOver")
			self:tower_clicked(information, pos)

			local detail_index = tower_select_detail_index(information)

			if detail_index then
				self:detail_tower(detail_index)
			end
		end
	--else
	--	local tower = KImageView:new("encyclopedia_tower_thumbs_0021")

	--	tower.anchor = v(tower.size.x / 2, tower.size.y / 2)
	--	tower.pos = pos

	--	self.towers:add_child(tower)
	--end
end

function TowerSelectView:update_over_sprite(pos)
	self.over_sprite.hidden = false
	self.over_sprite.pos = pos
end

function TowerSelectView:remove_over_sprite()
	self.over_sprite.hidden = true
end

--在防御塔被选中的时候，需要确定被选定的塔序号
function TowerSelectView:tower_clicked(information, pos)
	self.selected_legacy_tower = nil

	if self.selected_tower == information then
		self.select_sprite.hidden = true
		self.selected_tower = 0
	else
		self.select_sprite.hidden = false
		self.select_sprite.pos = pos
		self.selected_tower = information
	end
end

--暂时不管这些。后续在选择防御塔的时候再处理。
function TowerSelectView:detail_tower(index)
	if self.right_panel then
		self.back:remove_child(self.right_panel)

		self.right_panel = nil
	end

	self.right_panel = KView:new(V.v(600, 700))
	self.right_panel.pos = v(self.sw / 2 - 30, 200)
	self.right_panel.propagate_on_click = true
	self.right_panel.hide_power_levels = true

	self.back:add_child(self.right_panel)

	local tower_entry = screen_map.tower_data[index]
	local tower_name = tower_entry.name
	local advanced_skills = kr6_tower_integration.legacy_advanced_skills[tower_name]
	local is_special_encyclopedia_tower = screen_map_is_special_tower_entry(tower_entry)
	local dt = encyclopedia_tower_entity(tower_entry, tower_name)

	if not dt then
		log.error("tower %s not found in templates", tower_name)

		return
	end

	local di = dt.info and dt.info.fn and dt.info.fn(dt) or {
		type = STATS_TYPE_TOWER
	}
	local title_label = GGLabel:new(V.v(280, 50))

	title_label.pos = v(300, 44)
	title_label.anchor.x = title_label.size.x / 2
	title_label.font_name = "h_book"
	title_label.font_size = 22
	title_label.colors.text = {
		148,
		94,
		58
	}
	local info_key = dt.info and dt.info.i18n_key or tower_name
	local localized_name = encyclopedia_tower_entry_display_name(tower_entry)

	if not encyclopedia_text_has_copy(localized_name) then
		localized_name = _(string.upper(info_key) .. "_NAME")
	end

	if not encyclopedia_text_has_copy(localized_name) then
		localized_name = tower_name
	end

	title_label.text = localized_name
	title_label.text_align = "center"
	title_label.fit_lines = 1

	local title_width, _w = title_label:get_wrap_lines()

	self.right_panel:add_child(title_label)

	local left_decoration = KImageView:new("encyclopedia_rightArt")

	left_decoration.pos = v(300 - title_width / 2 - 10, 60)
	left_decoration.anchor = v(left_decoration.size.x, left_decoration.size.y / 2)
	left_decoration.scale.x = 0.7

	self.right_panel:add_child(left_decoration)

	local right_decoration = KImageView:new("encyclopedia_rightArt")

	right_decoration.pos = v(300 + title_width / 2 + 10, 60)
	right_decoration.anchor = v(left_decoration.size.x, right_decoration.size.y / 2)
	right_decoration.scale.x = -0.7

	self.right_panel:add_child(right_decoration)

	local portrait = KImageView:new(string.format(GS.encyclopedia_tower_fmt, tower_entry.icon or index))

	portrait.anchor = v(portrait.size.x / 2, portrait.size.y / 2)
	portrait.pos = v(300, 175)
	portrait.scale = v(0.7, 0.708)

	self.right_panel:add_child(portrait)

	local over_portrait = KImageView:new("encyclopedia_frame")

	over_portrait.anchor = v(over_portrait.size.x / 2, over_portrait.size.y / 2)
	over_portrait.pos = v(300, 175)

	self.right_panel:add_child(over_portrait)

	local desc_label = GGLabel:new(V.v(330, 50))

	desc_label.pos = v(300, 280)
	desc_label.anchor = v(165, 0)
	desc_label.font_name = "body"
	desc_label.font_size = 16
	desc_label.line_height = CJK(0.85, nil, 1.1, 0.9)
	desc_label.colors.text = {
		0,
		0,
		0
	}
	local description_override = is_special_encyclopedia_tower and special_tower_encyclopedia.description_overrides[tower_name]
	local localized_desc = encyclopedia_text_has_copy(description_override) and description_override or _(string.upper(info_key) .. "_DESCRIPTION")

	if not encyclopedia_text_has_copy(localized_desc) then
		localized_desc = tower_entry.description or ""
	end

	if not encyclopedia_text_has_copy(localized_desc) and is_special_encyclopedia_tower then
		localized_desc = encyclopedia_special_tower_fallback_description(tower_name, dt)
	end

	desc_label.text = localized_desc
	desc_label.text_align = "center"
	desc_label.fit_lines = 4

	self.right_panel:add_child(desc_label)

	local frame = KImageView:new("encyclopedia_rightPages_0001")

	frame.anchor = v(frame.size.x / 2, 0)
	frame.pos = v(305, 352)

	self.right_panel:add_child(frame)

	encyclopedia_add_tower_stat_icons(self.right_panel, tower_name, dt, di, "total")

	if dt.powers or advanced_skills then
		local specials = GGLabel:new(V.v(190, 26))

		specials.pos = v(300, 462)
		specials.anchor.x = specials.size.x / 2
		specials.text = _("Specials")
		specials.font_name = "h_book"
		specials.font_size = 20
		specials.text_align = "center"
		specials.colors.text = {
			116,
			105,
			66,
			255
		}
		specials.fit_lines = 1

		self.right_panel:add_child(specials)

		local title_w = specials:get_text_width(specials.text)
		local left_deco = KImageView:new("encyclopedia_rightArt")

		left_deco.pos = v(self.right_panel.size.x / 2 - title_w / 2 - 10, specials.pos.y + 16)
		left_deco.anchor = v(left_deco.size.x, left_deco.size.y / 2)
		left_deco.alpha = 0.6
		left_deco.scale.x = 0.7

		self.right_panel:add_child(left_deco)

		local right_deco = KImageView:new("encyclopedia_rightArt")

		right_deco.pos = v(self.right_panel.size.x / 2 + title_w / 2 + 13, specials.pos.y + 16)
		right_deco.anchor = v(right_deco.size.x, right_deco.size.y / 2)
		right_deco.alpha = 0.6
		right_deco.scale.x = -0.7

		self.right_panel:add_child(right_deco)

		local power_names = {}

		if advanced_skills then
			for _, power_name in ipairs(advanced_skills.powers) do
				table.insert(power_names, power_name)
			end
		else
			for power_name in pairs(dt.powers) do
				table.insert(power_names, power_name)
			end

			table.sort(power_names)
		end

		local tw = 360
		-- Keep tower-selection skill icons at the same size as their encyclopedia
		-- counterparts. KR6 legacy advanced skills intentionally use their shared
		-- 0.6 atlas scale in both views; every other generation uses the default 1.0.
		local icon_scale = advanced_skills and 0.6 or nil
		local power_count = encyclopedia_add_tower_power_icons(self.right_panel, dt, tower_name, power_names, tw, nil, icon_scale)

		if power_count == 0 then
			specials.hidden = true
			left_deco.hidden = true
			right_deco.hidden = true
		end
	end

	if is_special_encyclopedia_tower then
		encyclopedia_add_special_tower_build_button(self.right_panel, tower_entry)
	else
		encyclopedia_add_tower_mechanic_button(self.right_panel, tower_name)
	end

	tower_select_add_quick_balance_buttons(self, index)
end
-------多种选项
MoreOptionsView = class("OptionsView", PopUpView)

function MoreOptionsView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))
	--
	self.back = KImageView:new("heroroom_001_notxt")
	self.pos = v(0, 0)
	self.back.pos = v(sw / 2, sh / 2 - 50)
	self.back.pos = v(0, 0)
	self.back.anchor = v(self.back.size.x / 2, self.back.size.y / 2)

	self:add_child(self.back)
	self.back.alpha = 1
	--
	local mx = 100
	local y = 130
	---
	--新增一个liuhui的数据table
	if screen_map.user_data.liuhui == nil then
		screen_map.user_data.liuhui = {}
	end
	if screen_map.user_data.xingyu == nil then
		screen_map.user_data.xingyu = {}
	end	
	screen_map.user_data.xingyu.balance = enemy_enhance.level(screen_map.user_data.xingyu.balance)
	if screen_map.user_data.liuhui.use3tower == nil then
		screen_map.user_data.liuhui.use3tower = true
	end
	if screen_map.user_data.liuhui.use3tower_count == nil then
		screen_map.user_data.liuhui.use3tower_count = 0
	end	
	if screen_map.user_data.liuhui.impossiblerate == nil then
		screen_map.user_data.liuhui.impossiblerate = 1.5
	end
	GS.difficulty_enemy_hp_max_factor[4] = screen_map.user_data.liuhui.impossiblerate
	if screen_map.user_data.liuhui.cheat == nil then
		screen_map.user_data.liuhui.cheat = false
	end
	if screen_map.user_data.liuhui.cheat5 == nil then
		screen_map.user_data.liuhui.cheat5 = false
	end
	if screen_map.user_data.liuhui.cheat6 == nil then
		screen_map.user_data.liuhui.cheat6 = false
	end
	if screen_map.user_data.liuhui.cheat5_special == nil then
		screen_map.user_data.liuhui.cheat5_special = false
	end
	if screen_map.user_data.liuhui.cheat5_dragon == nil then
		screen_map.user_data.liuhui.cheat5_dragon = false
	end
	if screen_map.user_data.liuhui.cheathero == nil then
		screen_map.user_data.liuhui.cheathero = false
	end
	if screen_map.user_data.liuhui.hero_enhance == nil then
		screen_map.user_data.liuhui.hero_enhance = false
	end
	if screen_map.user_data.liuhui.g3_hprate == nil then
		screen_map.user_data.liuhui.g3_hprate = false
	end
	if screen_map.user_data.liuhui.balance == nil then
		screen_map.user_data.liuhui.balance = false
	end	
	if screen_map.user_data.liuhui.enemy_count == nil then
		screen_map.user_data.liuhui.enemy_count = 1
	end	
	if screen_map.user_data.liuhui.reinforcement_skins == nil then
		screen_map.user_data.liuhui.reinforcement_skins = 0		
	end
	if screen_map.user_data.reinforcement_count == nil then
		screen_map.user_data.reinforcement_count = 0		
	end
	if screen_map.user_data.liuhui.g5_hero_dark_count == nil then
		screen_map.user_data.liuhui.g5_hero_dark_count = 2
	end
	if screen_map.user_data.liuhui.reinforcement_5 == nil then
		screen_map.user_data.liuhui.reinforcement_5 = "royal" 
	end
	--废案
	if screen_map.user_data.liuhui.cp_mode == nil or screen_map.user_data.liuhui.cp_mode == true then
		screen_map.user_data.liuhui.cp_mode = false
	end
	if screen_map.user_data.liuhui.rand_creep == nil then
		screen_map.user_data.liuhui.rand_creep = 0
	end
	if screen_map.user_data.liuhui.rand_tower == nil then
		screen_map.user_data.liuhui.rand_tower = 0
	end
	if screen_map.user_data.liuhui.rand_tower_mode == nil then
		screen_map.user_data.liuhui.rand_tower_mode = 0
	end
	if screen_map.user_data.liuhui.rand_hero == nil then
		screen_map.user_data.liuhui.rand_hero = 0
	end
	if screen_map.user_data.liuhui.g4range_balance == nil then
		screen_map.user_data.liuhui.g4range_balance = 1
	end	
	-----
	local header_bg = KImageView("kr3_title_bg")

	header_bg.anchor.x = km.round(header_bg.size.x / 2)
	header_bg.pos = v(km.round(self.back.size.x / 2), -36)

	self.back:add_child(header_bg)	

	local header = GGPanelHeader:new(_("OPTIONS"), 274)

	header.pos = V.v(397, CJK(26, 24, nil, 24) - 36)

	self.back:add_child(header)	
	local bg_middle = self.back.size.x / 2

--设置出怪数量
	local ecound_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	ecound_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	ecound_button.pos = v(bg_middle - 120, 208)
	ecound_button.scale = v(0.8, 0.8)
	ecound_button.label.size = v(100, 34)
	ecound_button.label.text_size = ecound_button.label.size
	ecound_button.label.pos = v(20, 19)
	ecound_button.label.font_size = 24
	ecound_button.label.font_name = "sans_bold"
	ecound_button.label.vertical_align = "middle"
	ecound_button.label.text = _("LH349_ENEMY_COUNT_"..screen_map.user_data.liuhui.enemy_count)
	ecound_button.label.fit_lines = 1
	function ecound_button.on_click()
		screen_map.user_data.liuhui.enemy_count = screen_map.user_data.liuhui.enemy_count + 1
		if screen_map.user_data.liuhui.enemy_count >= 4 then
			screen_map.user_data.liuhui.enemy_count = 1
		end
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.ecound_button = ecound_button
	self.back:add_child(self.ecound_button)

	local ecount = GGLabel:new(V.v(bg_middle - 80, 24))
	ecount.pos.x = bg_middle - 570
	ecount.pos.y = 188--288
	ecount.font_name = "sans_bold"
	ecount.font_size = 20
	ecount.font_align = "center"
	ecount.colors.text = {
		200,
		89,
		51,
		255
	}
	ecount.text = _("LH349_ENEMY_COUNT")
	self.back:add_child(ecount)

---怪物增强

	local xingyu_ecount = GGLabel:new(V.v(bg_middle - 80, 24))
	xingyu_ecount.pos.x = bg_middle - 100
	xingyu_ecount.pos.y = 188--288
	xingyu_ecount.font_name = "sans_bold"
	xingyu_ecount.font_size = 20
	xingyu_ecount.font_align = "center"
	xingyu_ecount.colors.text = {
		200,
		89,
		51,
		255
	}
	xingyu_ecount.text = _("FLBALANCE_ENEMY")
	self.back:add_child(xingyu_ecount)

	local xingyu_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	xingyu_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	xingyu_button.pos = v(bg_middle + 350, 208)
	xingyu_button.scale = v(0.8, 0.8)
	xingyu_button.label.size = v(100, 34)
	xingyu_button.label.text_size = ecound_button.label.size
	xingyu_button.label.pos = v(20, 19)
	xingyu_button.label.font_size = 24
	xingyu_button.label.font_name = "sans_bold"
	xingyu_button.label.vertical_align = "middle"
	xingyu_button.label.text = enemy_enhance_label(screen_map.user_data.xingyu.balance)
	xingyu_button.label.fit_lines = 1
	function xingyu_button.on_click()
		screen_map.user_data.xingyu.balance = (enemy_enhance.level(screen_map.user_data.xingyu.balance) + 1) % 4
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.xingyu_button = xingyu_button
	self.back:add_child(self.xingyu_button)
---	
--设置5代科技
	local g5_hero_txt = GGLabel:new(V.v(bg_middle - 80, 24))
	g5_hero_txt.pos.x = bg_middle - 570
	g5_hero_txt.pos.y = 238
	g5_hero_txt.font_name = "sans_bold"
	g5_hero_txt.font_size = 20
	g5_hero_txt.font_align = "center"
	g5_hero_txt.colors.text = {
		100,
		200,
		51,
		255
	}
	g5_hero_txt.text = _("G5_KINGDOM_DARK")
	self.back:add_child(g5_hero_txt)

	local g5_hero_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	g5_hero_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	g5_hero_button.pos = v(bg_middle -120, 258)
	g5_hero_button.scale = v(0.8, 0.8)
	g5_hero_button.label.size = v(100, 34)
	g5_hero_button.label.text_size = ecound_button.label.size
	g5_hero_button.label.pos = v(20, 19)
	g5_hero_button.label.font_size = 24
	g5_hero_button.label.font_name = "sans_bold"
	g5_hero_button.label.vertical_align = "middle"
	g5_hero_button.label.text = _("G5_HERO_DARK_COUNT_"..screen_map.user_data.liuhui.g5_hero_dark_count)
	g5_hero_button.label.fit_lines = 1
	function g5_hero_button.on_click()
		screen_map.user_data.liuhui.g5_hero_dark_count = screen_map.user_data.liuhui.g5_hero_dark_count + 1
		if screen_map.user_data.liuhui.g5_hero_dark_count >= 3 then
			screen_map.user_data.liuhui.g5_hero_dark_count = 0
		end
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.g5_hero_button = g5_hero_button
	self.back:add_child(self.g5_hero_button)

--援兵皮肤
	local reinforcement_skin = GGLabel:new(V.v(bg_middle - 80, 24))
	reinforcement_skin.pos.x = bg_middle - 100
	reinforcement_skin.pos.y = 238
	reinforcement_skin.font_name = "sans_bold"
	reinforcement_skin.font_size = 20
	reinforcement_skin.font_align = "center"
	reinforcement_skin.colors.text = {
		100,
		200,
		51,
		255
	}
	reinforcement_skin.text = _("LH349_REINFORCEMENT_SKIN")
	self.back:add_child(reinforcement_skin)

	local reinforce_count = GGLabel:new(V.v(bg_middle - 80, 24))
	reinforce_count.pos.x = bg_middle - 570
	reinforce_count.pos.y = 288
	reinforce_count.font_name = "sans_bold"
	reinforce_count.font_size = 20
	reinforce_count.font_align = "center"
	reinforce_count.colors.text = {
		100,
		200,
		51,
		255
	}
	reinforce_count.text = _("LH349_REINFORCEMENT_COUNT")
	self.back:add_child(reinforce_count)

	local reinforcement_skin_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	reinforcement_skin_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	reinforcement_skin_button.pos = v(bg_middle + 350, 258)
	reinforcement_skin_button.scale = v(0.8, 0.8)
	reinforcement_skin_button.label.size = v(100, 34)
	reinforcement_skin_button.label.text_size = ecound_button.label.size
	reinforcement_skin_button.label.pos = v(20, 19)
	reinforcement_skin_button.label.font_size = 24
	reinforcement_skin_button.label.font_name = "sans_bold"
	reinforcement_skin_button.label.vertical_align = "middle"
	reinforcement_skin_button.label.text =  _("LH349_REINFORCEMENT_SKIN_"..screen_map.user_data.liuhui.reinforcement_skins)
	reinforcement_skin_button.label.fit_lines = 1
	function reinforcement_skin_button.on_click()
		screen_map.user_data.liuhui.reinforcement_skins = screen_map.user_data.liuhui.reinforcement_skins + 1
		if screen_map.user_data.liuhui.reinforcement_skins >= 4 then
			screen_map.user_data.liuhui.reinforcement_skins = 0
		end
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.reinforcement_skin_button = reinforcement_skin_button
	self.back:add_child(self.reinforcement_skin_button)
--援兵数量

	local reinforcement_count_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	reinforcement_count_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	reinforcement_count_button.pos = v(bg_middle - 120, 308)
	reinforcement_count_button.scale = v(0.8, 0.8)
	reinforcement_count_button.label.size = v(100, 34)
	reinforcement_count_button.label.text_size = ecound_button.label.size
	reinforcement_count_button.label.pos = v(20, 19)
	reinforcement_count_button.label.font_size = 24
	reinforcement_count_button.label.font_name = "sans_bold"
	reinforcement_count_button.label.vertical_align = "middle"
	reinforcement_count_button.label.text = _("LH349_REINFORCEMENT_COUNT_"..screen_map.user_data.reinforcement_count)
	reinforcement_count_button.label.fit_lines = 1
	function reinforcement_count_button.on_click()
		screen_map.user_data.reinforcement_count = screen_map.user_data.reinforcement_count + 1
		if screen_map.user_data.reinforcement_count >= 2 then
			screen_map.user_data.reinforcement_count = 0
		end
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.reinforcement_count_button = reinforcement_count_button
	self.back:add_child(self.reinforcement_count_button)

--设置携带防御塔

	local c_button_text = GGLabel:new(V.v(bg_middle - 80, 24))
	c_button_text.pos.x = bg_middle - 100
	c_button_text.pos.y = 288
	c_button_text.font_name = "sans_bold"
	c_button_text.font_size = 20
	c_button_text.font_align = "center"
	c_button_text.colors.text = {
		100,
		200,
		51,
		255
	}
	c_button_text.text = _("G123PICK")
	self.back:add_child(c_button_text)

	local count_button_text = GGLabel:new(V.v(bg_middle - 80, 24))
	count_button_text.pos.x = bg_middle - 570
	count_button_text.pos.y = 338
	count_button_text.font_name = "sans_bold"
	count_button_text.font_size = 20
	count_button_text.font_align = "center"
	count_button_text.colors.text = {
		100,
		200,
		51,
		255
	}
	count_button_text.text = _("TOWER_G45_PICK_COUNT")
	self.back:add_child(count_button_text)

	local c_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	c_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	c_button.pos = v(bg_middle + 350, 308) --(非点选的位置)v(self.sw / 2 - 2, 268)
	c_button.scale = v(0.8, 0.8)
	c_button.label.size = v(100, 34)
	c_button.label.text_size = ecound_button.label.size
	c_button.label.pos = v(20, 19)
	c_button.label.font_size = 24
	c_button.label.font_name = "sans_bold"
	c_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	c_button.label.text = _("USE3TOOWER_COUNT_"..screen_map.user_data.liuhui.use3tower_count)--screen_map.user_data.liuhui.use3tower and _("THIS_YES") or _("THIS_NO")
	c_button.label.fit_lines = 1
	function c_button.on_click()
--		screen_map.user_data.liuhui.use3tower = not screen_map.user_data.liuhui.use3tower
		screen_map.user_data.liuhui.use3tower_count = screen_map.user_data.liuhui.use3tower_count + 1
		if screen_map.user_data.liuhui.use3tower_count >= 3 then
			screen_map.user_data.liuhui.use3tower_count = 0
		end				
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.c_button = c_button
	self.back:add_child(self.c_button)
--选择防御塔的携带数量
	local MAX_TOWER = 20
	self.alliance_num = 21
	self.vegnance_num = 22
	self.max_tower = MAX_TOWER
	local count_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	count_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	count_button.pos = v(bg_middle - 120, 358)--v(self.back.size.x - 166 - select_button.size.x - 20, self.back.size.y - 32)
	count_button.scale = v(0.8, 0.8)
	count_button.label.size = v(100, 34)
	count_button.label.text_size = ecound_button.label.size
	count_button.label.pos = v(20, 19)
	count_button.label.font_size = 24
	count_button.label.font_name = "sans_bold"
	count_button.label.vertical_align = "middle"
	count_button.label.text = string.format(_("TOWER_45_PICK_COUNT"), screen_map.user_data.tower_pick)
	count_button.label.fit_lines = 1
	function count_button.on_click()
		local tower_pick = screen_map.user_data.tower_pick
		if tower_pick <= 4 then
			tower_pick = MAX_TOWER
			self.count_button.label.text = string.format(_("TOWER_45_PICK_COUNT"), tower_pick)
		else
			tower_pick = tower_pick - 4
			self.count_button.label.text = string.format(_("TOWER_45_PICK_COUNT"), tower_pick)
		end
		screen_map.user_data.tower_pick = tower_pick
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.count_button = count_button
	self.back:add_child(self.count_button)

--设置最大血量
	local stim = GGLabel:new(V.v(bg_middle - 80, 24))
	stim.pos.x = bg_middle - 570
	stim.pos.y = 138
	stim.font_name = "sans_bold"
	stim.font_size = 20
	stim.font_align = "center"
	stim.colors.text = {
		200,
		89,
		51,
		255
	}
	stim.text = _("ImpossibleHPRate")--..string.format("%.2f", screen_map.user_data.liuhui.impossiblerate)
	self.stim = stim
	self.back:add_child(stim)

	local stim_count = GGLabel:new(V.v(bg_middle - 80, 24))
	stim_count.pos.x = bg_middle - 350
	stim_count.pos.y = 98
	stim_count.font_name = "sans_bold"
	stim_count.font_size = 20
	stim_count.font_align = "center"
	stim_count.colors.text = {
		200,
		89,
		51,
		255
	}
	stim_count.text = string.format("%.2f", screen_map.user_data.liuhui.impossiblerate)
	self.stim_count = stim_count
	self.back:add_child(stim_count)

	local minus_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	minus_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	minus_button.pos = v(bg_middle  -170, 158)--v(self.back.size.x - 166 - select_button.size.x - 20, self.back.size.y - 32)
	minus_button.scale = v(0.8, 0.8)
	minus_button.label.size = v(100, 34)
	minus_button.label.text_size = ecound_button.label.size
	minus_button.label.pos = v(20, 19)
	minus_button.label.font_size = 24
	minus_button.label.font_name = "sans_bold"
	minus_button.label.vertical_align = "middle"
	minus_button.label.text = "-"
	minus_button.label.fit_lines = 1
	function minus_button.on_click()
		local impossiblerate = screen_map.user_data.liuhui.impossiblerate
		if impossiblerate and impossiblerate >= 2.51 then
			impossiblerate = impossiblerate - 0.25
		elseif impossiblerate and impossiblerate >= 1.14 then
			impossiblerate = impossiblerate - 0.05
		else
			impossiblerate = 1.10
		end
		screen_map.user_data.liuhui.impossiblerate = impossiblerate
		GS.difficulty_enemy_hp_max_factor[4] = screen_map.user_data.liuhui.impossiblerate
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.minus_button = minus_button
	self.back:add_child(self.minus_button)

	local plus_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	plus_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	plus_button.pos = v(bg_middle - 70, 158)--v(self.back.size.x - 166 - select_button.size.x - 20, self.back.size.y - 32)
	plus_button.scale = v(0.8, 0.8)
	plus_button.label.size = v(100, 34)
	plus_button.label.text_size = ecound_button.label.size
	plus_button.label.pos = v(20, 19)
	plus_button.label.font_size = 24
	plus_button.label.font_name = "sans_bold"
	plus_button.label.vertical_align = "middle"
	plus_button.label.text = "+"
	plus_button.label.fit_lines = 1
	function plus_button.on_click()
		local impossiblerate = screen_map.user_data.liuhui.impossiblerate
		if impossiblerate and impossiblerate <= 2.49 then
			impossiblerate = impossiblerate + 0.05
		elseif impossiblerate and impossiblerate <= 19.99 then
			impossiblerate = impossiblerate + 0.25
		else
			impossiblerate = 20
		end
		screen_map.user_data.liuhui.impossiblerate = impossiblerate
		GS.difficulty_enemy_hp_max_factor[4] = screen_map.user_data.liuhui.impossiblerate
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.plus_button = plus_button
	self.back:add_child(self.plus_button)

--设置3代血量模式
	local stg3 = GGLabel:new(V.v(bg_middle - 80, 24))
	stg3.pos.x = bg_middle - 100
	stg3.pos.y = 138
	stg3.font_name = "sans_bold"
	stg3.font_size = 20
	stg3.font_align = "center"
	stg3.colors.text = {
		200,
		89,
		51,
		255
	}
	stg3.text = _("G3_IMPOSSIBLE")
	self.back:add_child(stg3)


	local g3_hprate_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	g3_hprate_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	g3_hprate_button.pos = v(bg_middle + 350, 158)
	g3_hprate_button.scale = v(0.8, 0.8)
	g3_hprate_button.label.size = v(100, 34)
	g3_hprate_button.label.text_size = ecound_button.label.size
	g3_hprate_button.label.pos = v(20, 19)
	g3_hprate_button.label.font_size = 20
	g3_hprate_button.label.font_name = "sans_bold"
	g3_hprate_button.label.vertical_align = "middle"
	g3_hprate_button.label.text = screen_map.user_data.liuhui.g3_hprate and _("G3_CALRATE") or _("G3_STANDARD")
	g3_hprate_button.label.fit_lines = 1
	function g3_hprate_button.on_click()
		screen_map.user_data.liuhui.g3_hprate = not screen_map.user_data.liuhui.g3_hprate
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.g3_hprate_button = g3_hprate_button
	self.back:add_child(self.g3_hprate_button)
--设置平衡性开关
	local stbalance = GGLabel:new(V.v(bg_middle - 80, 24))
	stbalance.pos.x = bg_middle - 100
	stbalance.pos.y = 338
	stbalance.font_name = "sans_bold"
	stbalance.font_size = 20
	stbalance.font_align = "center"
	stbalance.colors.text = {
		100,
		200,
		51,
		255
	}
	stbalance.text = _("BALANCE_MODE_BETTER")
	self.back:add_child(stbalance)

	local stbalance_4 = GGLabel:new(V.v(bg_middle - 80, 24))
	stbalance_4.pos.x = bg_middle - 570
	stbalance_4.pos.y = 388
	stbalance_4.font_name = "sans_bold"
	stbalance_4.font_size = 20
	stbalance_4.font_align = "center"
	stbalance_4.colors.text = {
		100,
		200,
		51,
		255
	}
	stbalance_4.text = _("BALANCE_MODE_BETTER_4")
	self.back:add_child(stbalance_4)

	local balance_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	balance_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	balance_button.pos = v(bg_middle + 350, 358)
	balance_button.scale = v(0.8, 0.8)
	balance_button.label.size = v(100, 34)
	balance_button.label.text_size = ecound_button.label.size
	balance_button.label.pos = v(20, 19)
	balance_button.label.font_size = 24
	balance_button.label.font_name = "sans_bold"
	balance_button.label.vertical_align = "middle"
	balance_button.label.text = screen_map.user_data.liuhui.balance and _("THIS_YES") or _("THIS_NO")
	balance_button.label.fit_lines = 1
	function balance_button.on_click()
		screen_map.user_data.liuhui.balance = not screen_map.user_data.liuhui.balance
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.balance_button = balance_button
	self.back:add_child(self.balance_button)

	local g4range_balance_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	g4range_balance_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	g4range_balance_button.pos = v(bg_middle - 120, 408)
	g4range_balance_button.scale = v(0.8, 0.8)
	g4range_balance_button.label.size = v(100, 34)
	g4range_balance_button.label.text_size = ecound_button.label.size
	g4range_balance_button.label.pos = v(20, 19)
	g4range_balance_button.label.font_size = 24
	g4range_balance_button.label.font_name = "sans_bold"
	g4range_balance_button.label.vertical_align = "middle"
	g4range_balance_button.label.text = screen_map.user_data.liuhui.g4range_balance and _("FL_RANGE_BALANCE_RANGE") or _("FL_RANGE_STD_RANGE")
	g4range_balance_button.label.fit_lines = 1
	function g4range_balance_button.on_click()
		screen_map.user_data.liuhui.g4range_balance = not screen_map.user_data.liuhui.g4range_balance
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.g4range_balance_button = g4range_balance_button
	self.back:add_child(self.g4range_balance_button)

--设置英雄补强
	local st_hero_enhance = GGLabel:new(V.v(bg_middle - 80, 24))
	st_hero_enhance.pos.x = bg_middle - 100
	st_hero_enhance.pos.y = 388
	st_hero_enhance.font_name = "sans_bold"
	st_hero_enhance.font_size = 20
	st_hero_enhance.font_align = "center"
	st_hero_enhance.colors.text = {
		100,
		200,
		51,
		255
	}
	st_hero_enhance.text = _("HERO_ENHANCE_MODE")
	self.back:add_child(st_hero_enhance)

	local hero_enhance_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	hero_enhance_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	hero_enhance_button.pos = v(bg_middle + 350, 408)
	hero_enhance_button.scale = v(0.8, 0.8)
	hero_enhance_button.label.size = v(100, 34)
	hero_enhance_button.label.text_size = ecound_button.label.size
	hero_enhance_button.label.pos = v(20, 19)
	hero_enhance_button.label.font_size = 24
	hero_enhance_button.label.font_name = "sans_bold"
	hero_enhance_button.label.vertical_align = "middle"
	hero_enhance_button.label.text = screen_map.user_data.liuhui.hero_enhance and _("THIS_YES") or _("THIS_NO")
	hero_enhance_button.label.fit_lines = 1
	function hero_enhance_button.on_click()
		screen_map.user_data.liuhui.hero_enhance = not screen_map.user_data.liuhui.hero_enhance
		storage:save_slot(screen_map.user_data)

		local ok, hero_enhance_mod = pcall(require, "hero_enhance_mod")

		if ok and hero_enhance_mod.set_enabled then
			hero_enhance_mod:set_enabled(screen_map.user_data.liuhui.hero_enhance)
		end

		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.hero_enhance_button = hero_enhance_button
	self.back:add_child(self.hero_enhance_button)

--设置金手指
	local st_cheat = GGLabel:new(V.v(bg_middle - 80, 24))
	st_cheat.pos.x = bg_middle - 570
	st_cheat.pos.y = 438
	st_cheat.font_name = "sans_bold"--"body"
	st_cheat.font_size = 20
	st_cheat.font_align = "center"
	st_cheat.colors.text = {
		255,
		240,
		80,
		255
	}
	st_cheat.text = _("IS_CHEAT_GOLD")
	self.back:add_child(st_cheat)

	local st_cheat = GGLabel:new(V.v(bg_middle - 80, 24))
	st_cheat.pos.x = bg_middle - 100
	st_cheat.pos.y = 438
	st_cheat.font_name = "sans_bold"--"body"
	st_cheat.font_size = 20
	st_cheat.font_align = "center"
	st_cheat.colors.text = {
		255,
		240,
		80,
		255
	}
	st_cheat.text = _("IS_CHEAT_LOONG")
	self.back:add_child(st_cheat)

	local st_cheat_hero = GGLabel:new(V.v(bg_middle - 80, 24))
	st_cheat_hero.pos.x = bg_middle - 570
	st_cheat_hero.pos.y = 488
	st_cheat_hero.font_name = "sans_bold"--"body"
	st_cheat_hero.font_size = 20
	st_cheat_hero.font_align = "center"
	st_cheat_hero.colors.text = {
		255,
		240,
		80,
		255
	}
	st_cheat_hero.text = _("IS_CHEAT_HERO")
	self.back:add_child(st_cheat_hero)

	local st_cheat = GGLabel:new(V.v(bg_middle - 80, 24))
	st_cheat.pos.x = bg_middle - 100
	st_cheat.pos.y = 488
	st_cheat.font_name = "sans_bold"--"body"
	st_cheat.font_size = 20
	st_cheat.font_align = "center"
	st_cheat.colors.text = {
		255,
		240,
		80,
		255
	}
	st_cheat.text = _("IS_CHEAT_HERO_5")
	self.back:add_child(st_cheat)

	local st_cheat_hint = GGLabel:new(V.v(bg_middle + 30, 24))
	st_cheat_hint.pos.x = bg_middle - 285
	st_cheat_hint.pos.y = 738
	st_cheat_hint.font_name = "sans_bold"--"body"
	st_cheat_hint.font_size = 20
	st_cheat_hint.font_align = "center"
	st_cheat_hint.colors.text = {
		255,
		240,
		80,
		255
	}
	st_cheat_hint.text = _("IS_CHEAT_HERO_5_HINT")
	self.back:add_child(st_cheat_hint)

	local st_cheat = GGLabel:new(V.v(bg_middle - 80, 24))
	st_cheat.pos.x = bg_middle - 570
	st_cheat.pos.y = 538
	st_cheat.font_name = "sans_bold"--"body"
	st_cheat.font_size = 20
	st_cheat.font_align = "center"
	st_cheat.colors.text = {
		255,
		240,
		80,
		255
	}
	st_cheat.text = _("IS_CHEAT_G5_SPECIAL")
	self.back:add_child(st_cheat)

	local cheat_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	cheat_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	cheat_button.pos = v(bg_middle - 120, 458)
	cheat_button.scale = v(0.8, 0.8)
	cheat_button.label.size = v(100, 34)
	cheat_button.label.text_size = ecound_button.label.size
	cheat_button.label.pos = v(20, 19)
	cheat_button.label.font_size = 24
	cheat_button.label.font_name = "sans_bold"
	cheat_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	cheat_button.label.text = screen_map.user_data.liuhui.cheat and _("THIS_YES") or _("THIS_NO")
	cheat_button.label.fit_lines = 1
	function cheat_button.on_click()
		screen_map.user_data.liuhui.cheat = not screen_map.user_data.liuhui.cheat
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.cheat_button = cheat_button
	self.back:add_child(self.cheat_button)

	local cheat_hero_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	cheat_hero_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	cheat_hero_button.pos = v(bg_middle - 120, 508)--v(self.back.size.x - 166 - select_button.size.x - 20, self.back.size.y - 32)
	cheat_hero_button.scale = v(0.8, 0.8)
	cheat_hero_button.label.size = v(100, 34)
	cheat_hero_button.label.text_size = ecound_button.label.size
	cheat_hero_button.label.pos = v(20, 19)
	cheat_hero_button.label.font_size = 24
	cheat_hero_button.label.font_name = "sans_bold"
	cheat_hero_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	cheat_hero_button.label.text = screen_map.user_data.liuhui.cheathero and _("THIS_YES") or _("THIS_NO")
	cheat_hero_button.label.fit_lines = 1
	function cheat_hero_button.on_click()
		screen_map.user_data.liuhui.cheathero = not screen_map.user_data.liuhui.cheathero
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.cheat_hero_button = cheat_hero_button
	self.back:add_child(self.cheat_hero_button)

	local g5_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	g5_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	g5_button.pos = v(bg_middle + 350, 508)
	g5_button.scale = v(0.8, 0.8)
	g5_button.label.size = v(100, 34)
	g5_button.label.text_size = ecound_button.label.size
	g5_button.label.pos = v(20, 19)
	g5_button.label.font_size = 24
	g5_button.label.font_name = "sans_bold"
	g5_button.label.vertical_align = "middle"
	g5_button.label.text = screen_map.user_data.liuhui.cheat5 and _("THIS_YES") or _("THIS_NO")
	g5_button.label.fit_lines = 1
	function g5_button.on_click()
		screen_map.user_data.liuhui.cheat5 = not screen_map.user_data.liuhui.cheat5
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.g5_button = g5_button
	self.back:add_child(self.g5_button)

	local g6_label = GGLabel:new(V.v(bg_middle - 80, 24))
	g6_label.pos = v(bg_middle - 100, 538)
	g6_label.font_name = "sans_bold"
	g6_label.font_size = 20
	g6_label.font_align = "center"
	g6_label.colors.text = {255, 240, 80, 255}
	g6_label.text = _("IS_CHEAT_HERO_6")
	self.back:add_child(g6_label)

	local g6_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	g6_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	g6_button.pos = v(bg_middle + 350, 558)
	g6_button.scale = v(0.8, 0.8)
	g6_button.label.size = v(100, 34)
	g6_button.label.text_size = ecound_button.label.size
	g6_button.label.pos = v(20, 19)
	g6_button.label.font_size = 24
	g6_button.label.font_name = "sans_bold"
	g6_button.label.vertical_align = "middle"
	g6_button.label.text = screen_map.user_data.liuhui.cheat6 and _("THIS_YES") or _("THIS_NO")
	g6_button.label.fit_lines = 1
	function g6_button.on_click()
		screen_map.user_data.liuhui.cheat6 = not screen_map.user_data.liuhui.cheat6
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.g6_button = g6_button
	self.back:add_child(g6_button)

	local g5_special_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	g5_special_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	g5_special_button.pos = v(bg_middle - 120, 558)
	g5_special_button.scale = v(0.8, 0.8)
	g5_special_button.label.size = v(100, 34)
	g5_special_button.label.text_size = ecound_button.label.size
	g5_special_button.label.pos = v(20, 19)
	g5_special_button.label.font_size = 24
	g5_special_button.label.font_name = "sans_bold"
	g5_special_button.label.vertical_align = "middle"
	g5_special_button.label.text = screen_map.user_data.liuhui.cheat5_special and _("THIS_YES") or _("THIS_NO")
	g5_special_button.label.fit_lines = 1
	function g5_special_button.on_click()
		screen_map.user_data.liuhui.cheat5_special = not screen_map.user_data.liuhui.cheat5_special
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.g5_special_button = g5_special_button
	self.back:add_child(self.g5_special_button)

	local g5_dragon_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	g5_dragon_button.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	g5_dragon_button.pos = v(bg_middle + 350, 458)
	g5_dragon_button.scale = v(0.8, 0.8)
	g5_dragon_button.label.size = v(100, 34)
	g5_dragon_button.label.text_size = ecound_button.label.size
	g5_dragon_button.label.pos = v(20, 19)
	g5_dragon_button.label.font_size = 24
	g5_dragon_button.label.font_name = "sans_bold"
	g5_dragon_button.label.vertical_align = "middle"
	g5_dragon_button.label.text = screen_map.user_data.liuhui.cheat5_dragon and _("THIS_YES") or _("THIS_NO")
	g5_dragon_button.label.fit_lines = 1
	function g5_dragon_button.on_click()
		screen_map.user_data.liuhui.cheat5_dragon = not screen_map.user_data.liuhui.cheat5_dragon
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.g5_dragon_button = g5_dragon_button
	self.back:add_child(self.g5_dragon_button)
---随机模式
	local st_rand = GGLabel:new(V.v(bg_middle - 80, 24))
	st_rand.pos.x = bg_middle - 570
	st_rand.pos.y = 588
	st_rand.font_name = "sans_bold"
	st_rand.font_size = 20
	st_rand.font_align = "center"
	st_rand.colors.text = {
		93,
		156,
		252,
		255
	}
	st_rand.text = _("IS_RAND_ENEMY")
	self.back:add_child(st_rand)

	local st_rand = GGLabel:new(V.v(bg_middle - 80, 24))
	st_rand.pos.x = bg_middle - 100
	st_rand.pos.y = 588
	st_rand.font_name = "sans_bold"
	st_rand.font_size = 20
	st_rand.font_align = "center"
	st_rand.colors.text = {
		93,
		156,
		252,
		255
	}
	st_rand.text = _("IS_RAND_TOWER")
	self.back:add_child(st_rand)

	local st_rand = GGLabel:new(V.v(bg_middle - 80, 24))
	st_rand.pos.x = bg_middle - 570
	st_rand.pos.y = 638
	st_rand.font_name = "sans_bold"
	st_rand.font_size = 20
	st_rand.font_align = "center"
	st_rand.colors.text = {
		93,
		156,
		252,
		255
	}
	st_rand.text = _("IS_RAND_MODE")
	self.back:add_child(st_rand)

	local st_rand = GGLabel:new(V.v(bg_middle - 80, 24))
	st_rand.pos.x = bg_middle - 100
	st_rand.pos.y = 638
	st_rand.font_name = "sans_bold"
	st_rand.font_size = 20
	st_rand.font_align = "center"
	st_rand.colors.text = {
		93,
		156,
		252,
		255
	}
	st_rand.text = _("IS_RAND_HERO")
	self.back:add_child(st_rand)

	local rand_button_1 = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	rand_button_1.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	rand_button_1.pos = v(bg_middle - 120, 608)
	rand_button_1.scale = v(0.8, 0.8)
	rand_button_1.label.size = v(100, 34)
	rand_button_1.label.text_size = ecound_button.label.size
	rand_button_1.label.pos = v(20, 19)
	rand_button_1.label.font_size = 24
	rand_button_1.label.font_name = "sans_bold"
	rand_button_1.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	rand_button_1.label.text = _("RAND_CREEP_ENEMY_"..(screen_map.user_data.liuhui.rand_creep or 0))
	rand_button_1.label.fit_lines = 1
	function rand_button_1.on_click()
		screen_map.user_data.liuhui.rand_creep = screen_map.user_data.liuhui.rand_creep + 1
		if screen_map.user_data.liuhui.rand_creep >= 4 then
			screen_map.user_data.liuhui.rand_creep = 0
		end
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.rand_button_1 = rand_button_1
	self.back:add_child(self.rand_button_1)

	local rand_button_2 = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	rand_button_2.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	rand_button_2.pos = v(bg_middle + 350, 608)--v(self.back.size.x - 166 - select_button.size.x - 20, self.back.size.y - 32)
	rand_button_2.scale = v(0.8, 0.8)
	rand_button_2.label.size = v(100, 34)
	rand_button_2.label.text_size = ecound_button.label.size
	rand_button_2.label.pos = v(20, 19)
	rand_button_2.label.font_size = 24
	rand_button_2.label.font_name = "sans_bold"
	rand_button_2.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	rand_button_2.label.text = _("RAND_TOWER_COUNT_"..(screen_map.user_data.liuhui.rand_tower or 0))
	rand_button_2.label.fit_lines = 1
	function rand_button_2.on_click()
		screen_map.user_data.liuhui.rand_tower = screen_map.user_data.liuhui.rand_tower + 1

		if screen_map.user_data.liuhui.rand_tower >= 6 then
			screen_map.user_data.liuhui.rand_tower = 0
		end
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.rand_button_2 = rand_button_2
	self.back:add_child(self.rand_button_2)

	local rand_button_22 = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	rand_button_22.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	rand_button_22.pos = v(bg_middle - 120, 658)--v(self.back.size.x - 166 - select_button.size.x - 20, self.back.size.y - 32)
	rand_button_22.scale = v(0.8, 0.8)
	rand_button_22.label.size = v(100, 34)
	rand_button_22.label.text_size = ecound_button.label.size
	rand_button_22.label.pos = v(20, 19)
	rand_button_22.label.font_size = 24
	rand_button_22.label.font_name = "sans_bold"
	rand_button_22.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	rand_button_22.label.text = _("RAND_TOWER_MODE_"..(screen_map.user_data.liuhui.rand_tower_mode or 0))
	rand_button_22.label.fit_lines = 1
	function rand_button_22.on_click()
		screen_map.user_data.liuhui.rand_tower_mode = screen_map.user_data.liuhui.rand_tower_mode + 1
		if screen_map.user_data.liuhui.rand_tower_mode >= 5 then
			screen_map.user_data.liuhui.rand_tower_mode = 0
		end
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.rand_button_22 = rand_button_22
	self.back:add_child(self.rand_button_22)

	local rand_button_3 = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	rand_button_3.anchor = v(math.floor(ecound_button.size.x / 2), ecound_button.size.y / 2)
	rand_button_3.pos = v(bg_middle + 350, 658)--v(self.back.size.x - 166 - select_button.size.x - 20, self.back.size.y - 32)
	rand_button_3.scale = v(0.8, 0.8)
	rand_button_3.label.size = v(100, 34)
	rand_button_3.label.text_size = ecound_button.label.size
	rand_button_3.label.pos = v(20, 19)
	rand_button_3.label.font_size = 24
	rand_button_3.label.font_name = "sans_bold"
	rand_button_3.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	rand_button_3.label.text = _("THIS_YES_"..(screen_map.user_data.liuhui.rand_hero or 0))
	rand_button_3.label.fit_lines = 1
	function rand_button_3.on_click()
		screen_map.user_data.liuhui.rand_hero = screen_map.user_data.liuhui.rand_hero + 1
		if screen_map.user_data.liuhui.rand_hero >= 2 then
			screen_map.user_data.liuhui.rand_hero = 0
		end
		storage:save_slot(screen_map.user_data)
		self:update_selected()
		S:queue("GUIButtonCommon")
	end
	self.rand_button_3 = rand_button_3
	self.back:add_child(self.rand_button_3)

	--关闭按钮
	local close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")

	close_button.pos = v(self.back.size.x - 53, 19)
	self.close_button = close_button

	self.back:add_child(close_button)

	function self.close_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end
	self:update_selected()

end

function MoreOptionsView:update_selected()
	if self.selected_panel then
		self.back:remove_child(self.selected_panel)

		self.selected_panel = nil
	end

	self.selected_panel = KView:new(V.v(600, 700))
	self.selected_panel.pos = v(self.sw / 2 - 400, 270) --v(self.sw / 2 - 30, 200)
	self.selected_panel.propagate_on_click = true
	self.back:add_child(self.selected_panel)

	for i = 1, self.max_tower do
		local num = screen_map.user_data.towers[i]
		local icon = tower_deck_high_icon(num)
		log.debug(icon)
	end
	self.cheat_hero_button.label.text = screen_map.user_data.liuhui.cheathero and _("THIS_YES") or _("THIS_NO")
	self.cheat_button.label.text = screen_map.user_data.liuhui.cheat and _("THIS_YES") or _("THIS_NO")
	self.c_button.label.text = _("USE3TOOWER_COUNT_"..screen_map.user_data.liuhui.use3tower_count)--screen_map.user_data.liuhui.use3tower and _("THIS_YES") or _("THIS_NO")
	self.g3_hprate_button.label.text = screen_map.user_data.liuhui.g3_hprate and _("G3_CALRATE") or _("G3_STANDARD")
	self.g5_button.label.text = screen_map.user_data.liuhui.cheat5 and _("THIS_YES") or _("THIS_NO")
	self.g6_button.label.text = screen_map.user_data.liuhui.cheat6 and _("THIS_YES") or _("THIS_NO")
	self.g5_special_button.label.text = screen_map.user_data.liuhui.cheat5_special and _("THIS_YES") or _("THIS_NO")
	self.g5_dragon_button.label.text = screen_map.user_data.liuhui.cheat5_dragon and _("THIS_YES") or _("THIS_NO")
	self.ecound_button.label.text = _("LH349_ENEMY_COUNT_"..(screen_map.user_data.liuhui.enemy_count or 1))
	self.g5_hero_button.label.text = _("G5_HERO_DARK_COUNT_"..screen_map.user_data.liuhui.g5_hero_dark_count or 2)
	self.reinforcement_skin_button.label.text =  _("LH349_REINFORCEMENT_SKIN_"..screen_map.user_data.liuhui.reinforcement_skins or 0)
	self.reinforcement_count_button.label.text = _("LH349_REINFORCEMENT_COUNT_"..screen_map.user_data.reinforcement_count or 0)
	self.balance_button.label.text = screen_map.user_data.liuhui.balance and _("THIS_YES") or _("THIS_NO")
	self.hero_enhance_button.label.text = screen_map.user_data.liuhui.hero_enhance and _("THIS_YES") or _("THIS_NO")
	self.xingyu_button.label.text = enemy_enhance_label(screen_map.user_data.xingyu.balance)
	self.g4range_balance_button.label.text = screen_map.user_data.liuhui.g4range_balance and _("FL_RANGE_BALANCE_RANGE") or _("FL_RANGE_STD_RANGE")
	self.stim.text = _("ImpossibleHPRate")--..string.format("%.2f", screen_map.user_data.liuhui.impossiblerate)
	self.stim_count.text = string.format("%.2f", screen_map.user_data.liuhui.impossiblerate)
	self.rand_button_1.label.text = _("RAND_CREEP_ENEMY_"..(screen_map.user_data.liuhui.rand_creep or 0))
	self.rand_button_2.label.text = _("RAND_TOWER_COUNT_"..(screen_map.user_data.liuhui.rand_tower or 0))
	self.rand_button_22.label.text = _("RAND_TOWER_MODE_"..(screen_map.user_data.liuhui.rand_tower_mode or 0))
	self.rand_button_3.label.text = _("THIS_YES_"..(screen_map.user_data.liuhui.rand_hero or 0))
end

function MoreOptionsView:show()
	MoreOptionsView.super.show(self)

	self.difficulty_idx = screen_map.user_data.difficulty

	if not self.difficulty_idx then
		self.difficulty_idx = 1
	end
end

function MoreOptionsView:hide()
	MoreOptionsView.super.hide(self)
end
------
HeroNameLabel = class("HeroNameLabel", KView)

function HeroNameLabel:initialize(size)
	HeroNameLabel.super.initialize(self, size or self.size)

	self.labels = {}
	self.hero_name_config = map_data.hero_names_config
end

function HeroNameLabel:set_hero(hero_name, hero_i18n_key, display_name)
	--label如果没有可以default
	local conf = self.hero_name_config[hero_name] or self.hero_name_config.default
	local text = display_name or _(string.upper(hero_i18n_key or hero_name) .. "_NAME")

	for _, s in pairs({
		"・",
		"·"
	}) do
		text = string.gsub(text, s, " ")
	end

	local parts = conf.single_line and {
		text
	} or string.split(text, " ")
	local labels = self.labels
	local fs = display_name and 34 or conf.font_size or #parts > 2 and 28 or #parts > 1 and 44 or 70
	-- if screen_map.kr1_hero then
	-- 	fs = conf.font_size or #parts > 2 and 28 or #parts > 1 and 38 or 64
	-- end

	if #labels < #parts then
		for i = #labels + 1, #parts do
			local l = GGShaderLabel:new(self.size)

			self:add_child(l)

			labels[i] = l
			l.font_name = "hero_name_label"
			-- if screen_map.kr1_hero then
			-- 	l.font_name = "hero_name_label_kr1"
			-- end
			l.shaders = {
				"p_bands",
				"p_outline",
				"p_glow",
				"p_drop_shadow"
			}
			l.fit_lines = 1

			if IS_KR1 then
				l.shader_margin = math.ceil(0.35 * self.size.x)
			end
		end
	end

	for i = 1, #labels do
		local l = labels[i]

		l.hidden = true
	end

	local longest_idx = 1

	for i = 1, #parts do
		if utf8.len(parts[i]) > utf8.len(parts[longest_idx]) then
			longest_idx = i
		end
	end

	local longest_l = labels[longest_idx]

	longest_l.text = parts[longest_idx]

	longest_l:do_fit_lines(1, fs)

	longest_l.size.y = longest_l:get_font_height()

	local bl = longest_l:get_font_baseline()

	for i = 1, #parts do
		local l = labels[i]

		if i ~= longest_idx then
			l.text = parts[i]
			l.font_size = longest_l:get_fitted_font_size()
		end

		l.size.y = longest_l.size.y
		l.text_size.y = longest_l.size.y
		l.hidden = nil
		l.pos.y = self.size.y - bl - (#parts - i) * longest_l.size.y
		l.shader_args = conf.shader_args

		l:redraw()
	end
end

local kr6_general_upgrade_titles = {
	upg_a = ISW("Experience Gain", "zh-Hans", "Tăng kinh nghiệm", "zh-Hant", "經驗獲取"),
	upg_b = ISW("Attack Damage", "zh-Hans", "Tăng sát thương", "zh-Hant", "攻擊強化"),
	upg_c = ISW("Health", "zh-Hans", "Tăng máu", "zh-Hant", "生命強化"),
	upg_d = ISW("Respawn Time", "zh-Hans", "Hồi sinh nhanh", "zh-Hant", "重生加速"),
	upg_e = ISW("Armor", "zh-Hans", "Tăng giáp", "zh-Hant", "護甲強化")
}

Kr6HeroUpgradeTreeView = class("Kr6HeroUpgradeTreeView", KView)

function Kr6HeroUpgradeTreeView:initialize(owner)
	KView.initialize(self, V.v(940, 480))

	self.owner = owner
	self.hero_index = nil
	self.hero_name = nil
	self.hidden = true
	self.colors.background = {25, 30, 20, 248}
	self.nodes = {}

	local border = KView:new(V.v(self.size.x - 8, self.size.y - 8))

	border.pos = v(4, 4)
	border.colors.background = {61, 70, 38, 255}
	self:add_child(border)

	local inner = KView:new(V.v(self.size.x - 16, self.size.y - 16))

	inner.pos = v(8, 8)
	inner.colors.background = {31, 35, 22, 255}
	self:add_child(inner)

	self.title = GGLabel:new(V.v(480, 34))
	self.title.pos = v(230, 17)
	self.title.font_name = "body_bold"
	self.title.font_size = 27
	self.title.text_align = "center"
	self.title.vertical_align = "middle"
	self.title.colors.text = {245, 230, 180, 255}
	self.title.fit_lines = 1
	self:add_child(self.title)

	local points_back = KImageView:new("heroroom_013")

	points_back.pos = v(22, 14)
	self:add_child(points_back)

	local points_icon = KImageView:new("heroroom_012")

	points_icon.anchor = v(points_icon.size.x / 2, points_icon.size.y / 2)
	points_icon.pos = v(47, 31)
	self:add_child(points_icon)

	self.points = KLabel:new(V.v(52, 36))
	self.points.pos = v(53, 13)
	self.points.font = F:f("Comic Book Italic", "24")
	self.points.text_align = "center"
	self.points.colors.text = {231, 222, 175, 255}
	self:add_child(self.points)

	self.reset_button = GGButton:new("heroroom_btnReset_large_0001", "heroroom_btnReset_large_0002")
	self.reset_button.pos = v(self.size.x - 190, 10)
	self.reset_button.on_down_scale = nil
	self.reset_button.label.size = v(80, 26)
	self.reset_button.label.text_size = self.reset_button.label.size
	self.reset_button.label.pos = v(19, 16)
	self.reset_button.label.font_size = 18
	self.reset_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	self.reset_button.label.text = _("BUTTON_RESET")
	self.reset_button.label.fit_lines = 1
	self:add_child(self.reset_button)

	function self.reset_button.on_click()
		self:reset_tree()
	end

	local close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")

	close_button.pos = v(self.size.x - 48, 9)
	self:add_child(close_button)

	function close_button.on_click()
		S:queue("GUIButtonCommon")
		self:close()
	end

	local connection_layer = KView:new(V.v(self.size.x, self.size.y))
	local exemplar = hero_upgrades_6.data[hero_upgrades_6.hero_names[1]]

	connection_layer.propagate_on_click = true
	connection_layer.propagate_on_down = true
	connection_layer.propagate_on_up = true

	function connection_layer:_draw_self()
		local pr, pg, pb, pa = G.getColor()
		local old_width = G.getLineWidth and G.getLineWidth() or 1

		G.setColor(111, 92, 49, 255)
		G.setLineWidth(5)

		for _, chain in ipairs({
			{"skill_a", "upg_sa1", "upg_sa2"},
			{"skill_b", "upg_sb1", "upg_sb2"},
			{"skill_c", "upg_sc1", "upg_sc2"}
		}) do
			for i = 1, #chain - 1 do
				local a = exemplar.nodes[chain[i]]
				local b = exemplar.nodes[chain[i + 1]]

				G.line(a.x + 35, a.y + 55, b.x + 35, b.y + 55)
			end
		end

		G.setLineWidth(old_width)
		G.setColor(pr, pg, pb, pa)
	end

	self:add_child(connection_layer)

	for _, node_id in ipairs(hero_upgrades_6.node_order) do
		local node = exemplar.nodes[node_id]
		local button = KImageButton:new(node.icon, node.icon, node.icon, node.icon .. "_disabled")

		button.anchor = v(button.size.x / 2, button.size.y / 2)
		button.pos = v(node.x + 35, node.y + 55)
		button.scale = v(0.38, 0.38)
		button.node_id = node_id
		self:add_child(button)

		button.bought = KImageView:new("Upgrades_Icons_Bought")
		button.bought.anchor = v(button.bought.size.x / 2, button.bought.size.y / 2)
		button.bought.pos = v(button.size.x / 2, button.size.y / 2)
		button.bought.scale = v(2.22, 2.22)
		button.bought.propagate_on_click = true
		button.bought.hidden = true
		button:add_child(button.bought)

		button.over = KImageView:new("Upgrades_Icons_over")
		button.over.anchor = v(button.over.size.x / 2, button.over.size.y / 2)
		button.over.pos = v(button.size.x / 2, button.size.y / 2)
		button.over.scale = v(2.06, 2.06)
		button.over.propagate_on_click = true
		button.over.hidden = true
		button:add_child(button.over)

		local cost_view = KView:new(V.v(50, 24))

		cost_view.pos = v(node.x + 10, node.y + 88)
		self:add_child(cost_view)

		local cost_icon = KImageView:new("heroroom_012")

		cost_icon.scale = v(0.55, 0.55)
		cost_view:add_child(cost_icon)

		local cost_label = KLabel:new(V.v(28, 22))

		cost_label.pos = v(19, 0)
		cost_label.font = F:f("Comic Book Italic", "16")
		cost_label.colors.text = {231, 222, 175, 255}
		cost_label.text_align = "center"
		cost_view:add_child(cost_label)

		button.cost_view = cost_view
		button.cost_label = cost_label
		self.nodes[node_id] = button

		function button.on_enter()
			button.over.hidden = false
			self:show_tooltip(button.node_id)
		end

		function button.on_exit()
			button.over.hidden = true
			self:hide_tooltip()
		end

		function button.on_click()
			self:buy_node(button.node_id)
		end
	end
end

function Kr6HeroUpgradeTreeView:_draw_self()
	Kr6HeroUpgradeTreeView.super._draw_self(self)

	local pr, pg, pb, pa = G.getColor()

	G.setColor(151, 128, 70, 255)
	G.setLineWidth(2)
	G.rectangle("line", 7, 7, self.size.x - 14, self.size.y - 14)
	G.setLineWidth(1)
	G.setColor(pr, pg, pb, pa)
end

function Kr6HeroUpgradeTreeView:open(hero_index)
	local hero_name = screen_map.hero_data[hero_index].name

	if not hero_upgrades_6.is_hero(hero_name) then
		return
	end

	self.hero_index = hero_index
	self.hero_name = hero_name
	self.hidden = false
	self:refresh()
end

function Kr6HeroUpgradeTreeView:close()
	self.hidden = true
	self:hide_tooltip()
end

function Kr6HeroUpgradeTreeView:show_tooltip(node_id)
	local tree = hero_upgrades_6.data[self.hero_name]
	local node = tree and tree.nodes[node_id]

	if not node then
		return
	end

	local bought = hero_upgrades_6.is_bought(screen_map.user_data, self.hero_name, node_id)
	local tip = self.owner.tip_panel

	tip.price.hidden = bought
	tip.bullet.hidden = bought
	if tip.star then
		tip.star.hidden = bought
	end
	local inner_balance_6 = balance_6 or require("data.balance.balance_6")
	local balance_hero_name = hero_upgrades_6.balance_names[self.hero_name] or self.hero_name
	local replacements = {
		hero_name = balance_hero_name,
		upgrade_name = node_id
	}
	local title = GU.balance_format(_(node.title_key), inner_balance_6, replacements) or _(node.title_key)
	if self.hero_name ~= "hero_silent" then
		title = kr6_general_upgrade_titles[node_id] or title
	end
	local description = GU.balance_format(_(node.description_key), inner_balance_6, replacements) or _(node.description_key)

	balance_6 = inner_balance_6
	self.owner.skills:set_panel_height(title, description, node.cost)
	self.owner.skills:update_tooltip_position()
end

function Kr6HeroUpgradeTreeView:hide_tooltip()
	self.owner.tip_panel.hidden = true
end

function Kr6HeroUpgradeTreeView:reload_templates()
	E:load()
	UPGR:set_all_generation_levels(screen_map.user_data)
	DI:set_level(screen_map.user_data.difficulty)
	UPGR:patch_templates(5)
	DI:patch_templates()
end

function Kr6HeroUpgradeTreeView:buy_node(node_id)
	if self.owner.skills.no_buy then
		return
	end

	local hero_data = get_hero_stats(self.hero_index)

	if not hero_upgrades_6.buy(screen_map.user_data, self.hero_name, node_id, hero_data.level, GS.skill_points_for_hero_level) then
		return
	end

	S:queue("GUIBuyUpgrade")
	storage:save_slot(screen_map.user_data)
	self:reload_templates()
	self.owner:construct_hero(self.hero_index)
	self:refresh()
	self:show_tooltip(node_id)
end

function Kr6HeroUpgradeTreeView:reset_tree()
	if self.owner.skills.no_buy or not self.hero_name or hero_upgrades_6.spent_points(screen_map.user_data, self.hero_name) == 0 then
		return
	end

	S:queue("GUIButtonCommon")
	hero_upgrades_6.reset(screen_map.user_data, self.hero_name)
	storage:save_slot(screen_map.user_data)
	self:reload_templates()
	self.owner:construct_hero(self.hero_index)
	self:refresh()
end

function Kr6HeroUpgradeTreeView:refresh()
	local tree = hero_upgrades_6.data[self.hero_name]

	if not tree then
		return
	end

	local hero_data = get_hero_stats(self.hero_index)
	local remaining = hero_upgrades_6.remaining_points(screen_map.user_data, self.hero_name, hero_data.level, GS.skill_points_for_hero_level)

	self.title.text = string.format("%s - %s", _(tree.display_key .. "_NAME"), ISW("HERO UPGRADES", "zh-Hans", "Nâng cấp anh hùng", "zh-Hant", "英雄科技樹"))
	self.points.text = tostring(remaining)

	for _, node_id in ipairs(hero_upgrades_6.node_order) do
		local node = tree.nodes[node_id]
		local button = self.nodes[node_id]
		local bought = hero_upgrades_6.is_bought(screen_map.user_data, self.hero_name, node_id)
		local available = hero_upgrades_6.can_buy(screen_map.user_data, self.hero_name, node_id, hero_data.level, GS.skill_points_for_hero_level)
		local image_name = (bought or available) and node.icon or node.icon .. "_disabled"

		button.default_image_name = image_name
		button.hover_image_name = image_name
		button.click_image_name = image_name
		button.disable_image_name = node.icon .. "_disabled"
		button:set_image(image_name)
		button.anchor = v(button.size.x / 2, button.size.y / 2)
		button.bought.hidden = not bought
		button.cost_view.hidden = bought
		button.cost_label.text = tostring(node.cost)
	end

	if hero_upgrades_6.spent_points(screen_map.user_data, self.hero_name) > 0 and not self.owner.skills.no_buy then
		self.reset_button:enable()
	else
		self.reset_button:disable()
	end

	if screen_map.user_data.heroes.selected == self.hero_name then
		screen_map.skill_label.text = tostring(remaining)
		screen_map.skill_star.hidden = remaining == 0
	end
end

HeroRoomView = class("HeroRoomView", PopUpView)

local hrvt_scale = v(0.625, 0.625)
local hrvt_size = v(160 * hrvt_scale.x, 168 * hrvt_scale.y)
local hrvt_margin = v(14, 10)
local hrvt_sep = v(6, 4)
local hrvt_per_row = 8
local hrvt_rebborn2_scale = v(0.95, 0.95)

local function is_rebborn2_hero_thumb(hd)
	return hd and hd.portrait and hd.portrait >= 950 and hd.portrait <= 954
end

local function hero_room_thumb_scale(i, hd, portrait)
	if i <= 47 then
		return hrvt_scale
	end

	if hero_upgrades_6.is_hero(hd and hd.name) and portrait and portrait.size.x > 0 and portrait.size.y > 0 then
		local scale = math.min(hrvt_size.x / portrait.size.x, hrvt_size.y / portrait.size.y)

		return v(scale, scale)
	end

	if is_rebborn2_hero_thumb(hd) then
		return hrvt_rebborn2_scale
	end

	return v(1, 1)
end

function HeroRoomView:hero_thumb_pos(i, ox, oy)
	i = i % 16
	if i == 0 then
		i = 16
	end
	local frame = self.hero_select
	local sx = frame.pos.x - frame.size.x / 2 * frame.scale.x + hrvt_margin.x
	local dx = hrvt_size.x + hrvt_sep.x
	local sy = frame.pos.y - frame.size.y / 2 * frame.scale.y + hrvt_margin.y
	local dy = hrvt_size.y + hrvt_sep.y
	local per_row = hrvt_per_row
	local pos = v(math.fmod(i - 1, per_row) * dx + sx, math.floor((i - 1) / per_row) * dy + sy)

	pos.x = pos.x + (ox and ox or 0)
	pos.y = pos.y + (oy and oy or 0) + (i <= 47 and 0 or 10)

	return pos
end

function HeroRoomView:hero_thumb_cell_pos(i, hd, ox, oy)
	return self:hero_thumb_pos(i, ox, oy)
end

function HeroRoomView:hero_thumb_image_pos(i, hd, ox, oy)
	local pos = self:hero_thumb_cell_pos(i, hd, ox, oy)

	if is_rebborn2_hero_thumb(hd) then
		pos.x = pos.x + hrvt_size.x * (1 - hrvt_rebborn2_scale.x) / 2
		pos.y = pos.y + hrvt_size.y * (1 - hrvt_rebborn2_scale.y) / 2
	end

	return pos
end

function HeroRoomView:allied_room_name(boss)
	if boss.kind=="volibear_prestige" then return "Volibear" end
	if boss.kind=="navira_blue" then return "Navira" end
	if boss.kind:match("^sett") then return "Sett" end
	return boss.title
end

function HeroRoomView:sync_allied_boss_images()
	for _,boss in ipairs(infinite_heroes.bosses.list) do
		local t=E:get_template(boss.source)
		local resource=encyclopedia_enemy_resources.enemies[boss.source]
		if t and not boss.custom_portrait then
			local index=encyclopedia_enemy_icon_idx(t,boss.source,resource and resource.encyclopedia_index,resource and resource.generation)
			boss.icon=string.format(GS.encyclopedia_enemy_thumb_fmt,index)
			boss.portrait=string.format(GS.encyclopedia_enemy_fmt,index)
		end
	end
end

function HeroRoomView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))
	self.popup_y_offset = -55

	self.back = KImageView:new("heroroom_001_notxt")
	self.back.pos = v(0, 0)
	
	self.back.anchor = v(self.back.size.x / 2, self.back.size.y / 2)

	self:add_child(self.back)

	self.back.alpha = 0
	self.hero_select = KImageView:new("heroroom_002")
	self.hero_select.anchor = v(self.hero_select.size.x / 2, self.hero_select.size.y / 2)
	self.hero_select.pos = v(self.back.size.x / 2, 203)
	self.hero_select.scale.y = (2 * hrvt_margin.y + 2 * hrvt_size.y + hrvt_sep.y) / self.hero_select.size.y

	self.back:add_child(self.hero_select)

	self.hero_select.selected = KImageView:new("heroroom_portraitsDecos_0002")
	self.hero_select.selected.pos = v(30, 30)
	self.hero_select.selected.scale = hrvt_scale
	self.hero_select.selected.hidden = true
	self.hero_select.over = KImageView:new("heroroom_portraitsDecos_0003")
	self.hero_select.over.pos = v(30, 30)
	self.hero_select.over.propagate_on_click = true
	self.hero_select.over.scale = hrvt_scale
	self.hero_select.over.hidden = false
	self.selected_index = -1
	self.hero_select.mouse_over = KImageView:new("heroroom_thumbs_0008")
	self.hero_select.mouse_over.propagate_on_click = true
	self.hero_select.mouse_over.hidden = true
	self.hero_select.mouse_over.scale = v(hrvt_size.x / self.hero_select.mouse_over.size.x, hrvt_size.y / self.hero_select.mouse_over.size.y)

	if screen_map.user_data.liuhui_hero == nil then
		screen_map.user_data.liuhui_hero = {}
	end
	if screen_map.user_data.liuhui_hero.usedoublehero == nil then
		screen_map.user_data.liuhui_hero.usedoublehero = false
	end
	if screen_map.user_data.liuhui_hero.herolist == nil then
		screen_map.user_data.liuhui_hero.herolist = default_double_hero_list()
	end
	if screen_map.user_data.liuhui_hero.rallylist == nil then
		screen_map.user_data.liuhui_hero.rallylist = default_rally_hero_list()
	end

	if screen_map.user_data.heroes.selected then
		for i, hd in ipairs(screen_map.hero_data) do
			if hd.name == screen_map.user_data.heroes.selected then
				self.selected_index = i
				self.real_selected = i
				self.hero_select.selected.pos = self:hero_thumb_cell_pos(i, hd)
				self.hero_select.over.pos = self:hero_thumb_cell_pos(i, hd)
				local kr4_portrait_name = kr4_map_hero_portrait_name(hd)
				local kr6_portrait_name = kr6_map_hero_portrait_name(hd)

				if hd.icon <= 47 then
					screen_map.hero_icon_portrait:set_image(string.format("mapButtons_portrait_hero_%04i", hd.icon))
					screen_map.hero_icon_portrait.pos = v(0, 0)
					screen_map.hero_icon_portrait.scale = v(1, 1)
				elseif kr4_portrait_name then
					screen_map.hero_icon_portrait:set_image(kr4_portrait_name)
					screen_map.hero_icon_portrait.pos = v(0, 0)
					screen_map.hero_icon_portrait.scale = v(1, 1)
				elseif kr6_portrait_name then
					screen_map.hero_icon_portrait:set_image(kr6_portrait_name)
					screen_map.hero_icon_portrait.pos = v(0, 0)
					screen_map.hero_icon_portrait.scale = v(1, 1)
				else
					screen_map.hero_icon_portrait:set_image(string.format("hero_room_portraits_small_button_%s_0001", hd.name))
					if is_rebborn2_hero_thumb(hd) then
						screen_map.hero_icon_portrait.pos = v(0, 0)
						screen_map.hero_icon_portrait.scale = v(1, 1)
					else
						screen_map.hero_icon_portrait.pos = v(78, 42)
						screen_map.hero_icon_portrait.scale = v(0.8, 0.8)
					end
				end
				screen_map.hero_icon_portrait.hidden = false
				self.hero_select.selected.hidden = false

				break
			end
		end
	end

	if self.selected_index < 0 then
		self.hero_select.selected.hidden = true
		self.selected_index = 1
		self.hero_select.over.pos = v(sx, sy)
	end

	self.over_index = self.selected_index

	-- local max_level = #screen_map.user_data.levels
	local max_level = 72
	-- changed
	self.hero_views = {}
	self.hero_viewing = 1
	function switch_hero_room_page()
		for i, v in ipairs(self.hero_views) do
			if (i >= self.hero_viewing and i - self.hero_viewing < 16) then
				v.hidden = false
			else
				v.hidden = true
			end
		end
		self.hero_viewing = self.hero_viewing + 16
		if self.hero_viewing > #self.hero_views then
			self.hero_viewing = 1
		end
	end

	for i = 1, #screen_map.hero_data do
		local hd = screen_map.hero_data[i]

		if not hd or hd.coming_soon then
			local portrait = KImageView:new("heroroom_portraitsDecos_0001")

			table.insert(self.hero_views, portrait)
			portrait.hidden = true

			portrait.pos = self:hero_thumb_image_pos(i, hd)
			portrait.scale = hrvt_scale

			self.back:add_child(portrait)
		else
			--在此加入英雄
			--注意5代英雄的portrait和技能的加载
			local portrait = nil
			if i <= 47 then--加载前3代英雄
				portrait = KImageView:new(string.format("heroroom_portraits_%04i", hd.thumb))
			else--加载5代英雄
				portrait = KImageView:new(string.format("hero_room_portraits_small_thumb_%s_0001", hd.name))
			end
			table.insert(self.hero_views, portrait)
			portrait.hidden = true

			portrait.pos = self:hero_thumb_image_pos(i, hd)
			portrait.scale = hero_room_thumb_scale(i, hd, portrait)
			--portrait.scale = hrvt_scale if i <= 47 else v(1,1)

			self.back:add_child(portrait)

			function portrait.on_enter()
				self.hero_select.mouse_over.hidden = false
				self.hero_select.mouse_over.pos = self:hero_thumb_cell_pos(i, hd, 0, -1)
			end

			function portrait.on_exit()
				self.hero_select.mouse_over.hidden = true
			end

			function portrait.on_click()
				S:queue("GUIQuickMenuOpen")

				self.selected_boss = nil
				self.selected_index = i
				self.over_index = i

				self:construct_hero(i)

				self.hero_select.over.pos = self:hero_thumb_cell_pos(i, hd)
				self.hero_select.over.hidden = false
			end

			if max_level < hd.available_level then
				local portraitLock = KImageView:new("heroroom_portraitsLock")

				table.insert(self.hero_views, portrait)
				portrait.hidden = true

				portraitLock.pos = self:hero_thumb_cell_pos(i, hd)
				portraitLock.scale = v(hrvt_size.x / portraitLock.size.x, hrvt_size.y / portraitLock.size.y)

				self.back:add_child(portraitLock)

				portraitLock.propagate_on_click = true
			end
		end
	end

	self:sync_allied_boss_images()
	-- Boss entries share the hero grid; saved normal hero indices stay unchanged.
	for _, boss in ipairs(infinite_heroes.bosses.list) do
		local index = #self.hero_views + 1
		local card = KView:new(V.v(hrvt_size.x, hrvt_size.y))
		card.pos = self:hero_thumb_cell_pos(index)
		card.colors.background = {65, 44, 73, 220}
		card.hidden = true
		local portrait = KImageView:new(boss.icon)
		portrait._draw_self = boss.portrait_draw
		local scale = math.min(82 / portrait.size.x, 78 / portrait.size.y)
		portrait.scale = v(scale, scale)
		portrait.anchor = v(portrait.size.x / 2, portrait.size.y / 2)
		portrait.pos = v(50, 43)
		portrait.propagate_on_click = true
		card:add_child(portrait)
		local label = GGLabel:new(v(100, 20))
		label.text, label.font_name, label.font_size = self:allied_room_name(boss), "body_bold", 14
		label.text_align, label.vertical_align = "center", "middle"
		label.colors.text = {255, 242, 211, 255}
		label.pos = v(0, 80)
		label.propagate_on_click = true
		card:add_child(label)
		function card.on_click(_, button)
			if button and button ~= 1 then return end
			self.selected_boss = boss.name
			self:construct_hero(self.selected_index)
			self.hero_select.over.pos = self:hero_thumb_cell_pos(index)
			self.hero_select.over.hidden = false
			S:queue("GUIQuickMenuOpen")
		end
		self.hero_views[index] = card
		self.back:add_child(card)
	end

	self.hero_select.selected.propagate_on_click = true

	self.back:add_child(self.hero_select.mouse_over)
	self.back:add_child(self.hero_select.over)
	self.back:add_child(self.hero_select.selected)

	self.tip_panel = HeroToolTip:new()

	self:add_child(self.tip_panel)

	self.skills = HeroSkills:new(1, {})
	self.skills.anchor = v(0, 0)
	self.skills.pos = v(self.back.size.x / 2 - 15, 375 + (IS_KR3 and -6 or 0))

	self.back:add_child(self.skills)

	self.skills.tip_panel = self.tip_panel

	-- 创建英雄自传视图 (用于1代英雄) - 替换整个技能区域
	self.bio_view = KView:new(V.v(self.skills.size.x, self.skills.size.y))
	self.bio_view.pos = self.skills.pos
	self.bio_view.hidden = true
	self.back:add_child(self.bio_view)

	-- 使用与技能视图相同的背景
	local bio_bg = KImageView:new("heroroom_003")
	self.bio_view:add_child(bio_bg)

	-- 自传标题背景（替换技能标题）
	local bio_title_bg = KImageView:new("heroroom_006_notxt")
	bio_title_bg.pos = v(V.csnap(self.bio_view.size.x / 2 - 4, IS_KR3 and 6 or 2))
	bio_title_bg.anchor = v(bio_title_bg.size.x / 2, bio_title_bg.size.y / 2)
	self.bio_view:add_child(bio_title_bg)

	local bio_header = GGShaderLabel:new(V.v(130, 26))
	bio_header.font_name = "h"
	bio_header.font_size = 22
	bio_header.text_align = "center"
	bio_header.vertical_align = CJK("middle-caps", "middle", nil, "middle")
	bio_header.colors.text = {250, 250, 250, 255}
	bio_header.shaders = {"p_bands", "p_glow"}
	bio_header.shader_args = {
		{
			margin = 1,
			p1 = 0.42,
			p2 = 0.56,
			c1 = {0.9803921568627451, 0.9803921568627451, 0.9803921568627451, 1},
			c2 = {0.9098039215686274, 0.8745098039215686, 0.6901960784313725, 1},
			c3 = {0.6588235294117647, 0.6274509803921569, 0.4588235294117647, 1}
		},
		{
			thickness = 1.6,
			glow_color = {0, 0, 0, 0.85}
		}
	}
	self.bio_header = bio_header
	bio_header.text = _("Introduction")  -- "介绍"
	bio_header.fit_lines = 1
	bio_header.pos = v(23, ISW(9, "zh-Hans", 8))
	bio_title_bg:add_child(bio_header)

	-- 属性面板背景（与技能视图相同）
	local bio_stat_panel = KImageView:new("heroroom_004")
	bio_stat_panel.pos = v(V.csnap(8 - 245, self.bio_view.size.y / 2 + 30))
	bio_stat_panel.anchor = v(bio_stat_panel.size.x, bio_stat_panel.size.y / 2)
	self.bio_view:add_child(bio_stat_panel)

	-- 属性图标背景
	local bio_stat_bullets = KImageView:new("heroroom_007")
	bio_stat_bullets.pos = v(V.csnap(bio_stat_panel.size.x / 2, bio_stat_panel.size.y / 2 - 2))
	bio_stat_bullets.anchor = v(bio_stat_bullets.size.x / 2, bio_stat_bullets.size.y / 2)
	bio_stat_panel:add_child(bio_stat_bullets)

	-- 自传内容区域（放在右侧）
	local bio_content_area = KView:new(V.v(350, 250))
	bio_content_area.pos = v(50, 50)
	self.bio_view:add_child(bio_content_area)

	-- 自传文本
	self.bio_text = GGLabel:new(V.v(350, 145))
	self.bio_text.pos = v(0, 0)
	self.bio_text.font_name = "body"
	self.bio_text.font_size = 15
	self.bio_text.line_height = 1.0
	self.bio_text.colors.text = {255, 255, 255}
	self.bio_text.text_align = "left"
	self.bio_text.vertical_align = "top"
	self.bio_text.fit_lines = 6
	bio_content_area:add_child(self.bio_text)

	-- 1代说明文本
	self.g1_text = GGLabel:new(V.v(350, 85))
	self.g1_text.pos = v(0, 130)
	self.g1_text.font_name = "body"
	self.g1_text.font_size = 15
	self.g1_text.line_height = 1.0
	self.g1_text.colors.text = {255, 255, 255}
	self.g1_text.text_align = "left"
	self.g1_text.vertical_align = "top"
	self.g1_text.fit_lines = 6
	bio_content_area:add_child(self.g1_text)

	-- 技能介绍文本
	self.skills_intro_text = GGLabel:new(V.v(350, 85))
	self.skills_intro_text.pos = v(0, 160)
	self.skills_intro_text.font_name = "body"
	self.skills_intro_text.font_size = 18
	self.skills_intro_text.line_height = 1.0
	self.skills_intro_text.colors.text = {245, 203, 6}
	self.skills_intro_text.text_align = "left"
	self.skills_intro_text.vertical_align = "top"
	self.skills_intro_text.fit_lines = 3
	bio_content_area:add_child(self.skills_intro_text)

	self.kr6_tree_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	self.kr6_tree_button.anchor = v(self.kr6_tree_button.size.x / 2, self.kr6_tree_button.size.y / 2)
	self.kr6_tree_button.pos = v(175, 190)
	self.kr6_tree_button.label.size = v(100, 34)
	self.kr6_tree_button.label.text_size = self.kr6_tree_button.label.size
	self.kr6_tree_button.label.pos = v(20, 19)
	self.kr6_tree_button.label.font_size = 19
	self.kr6_tree_button.label.font_name = "body_bold"
	self.kr6_tree_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	self.kr6_tree_button.label.text = ISW("HERO UPGRADES", "zh-Hans", "Nâng cấp anh hùng", "zh-Hant", "英雄科技樹")
	self.kr6_tree_button.label.fit_lines = 1
	self.kr6_tree_button.hidden = true
	bio_content_area:add_child(self.kr6_tree_button)

	function self.kr6_tree_button.on_click()
		if self.kr6_tree then
			S:queue("GUIButtonCommon")
			self.kr6_tree:open(self.selected_index)
		end
	end

	-- 在自传视图中复制属性显示
	local y_o, y_d = 6, 34
	local x, y = 31, y_o

	-- 血量
	self.bio_health = GGLabel:new(V.v(80, 17))
	self.bio_health.pos = v(x, y)
	self.bio_health.colors.text = {255, 255, 255}
	self.bio_health.text = "200"
	self.bio_health.text_align = "left"
	self.bio_health.font_name = "Comic Book Italic"
	self.bio_health.font_size = 16
	self.bio_health.vertical_align = "middle"
	self.bio_health.fit_lines = 1
	bio_stat_bullets:add_child(self.bio_health)

	y = y + y_d

	-- 护甲
	self.bio_armor = GGLabel:new(V.v(80, 17))
	self.bio_armor.pos = v(x, y)
	self.bio_armor.colors.text = {255, 255, 255}
	self.bio_armor.text = "200"
	self.bio_armor.text_align = "left"
	self.bio_armor.font_name = CJK("body", nil, nil, "h_noti")
	self.bio_armor.font_size = 16
	self.bio_armor.text_offset.y = -2
	self.bio_armor.vertical_align = "middle"
	self.bio_armor.fit_lines = 1
	bio_stat_bullets:add_child(self.bio_armor)

	y = y + y_d

	-- 攻击
	self.bio_attack = GGLabel:new(V.v(80, 17))
	self.bio_attack.pos = v(x, y)
	self.bio_attack.colors.text = {255, 255, 255}
	self.bio_attack.text = "100"
	self.bio_attack.text_align = "left"
	self.bio_attack.font_name = "Comic Book Italic"
	self.bio_attack.font_size = 16
	self.bio_attack.vertical_align = "middle"
	self.bio_attack.fit_lines = 1
	bio_stat_bullets:add_child(self.bio_attack)

	-- 攻击图标
	self.bio_attack_icon = KImageView:new("heroroom_attackIcons_0001")
	self.bio_attack_icon.pos = v(x - 29, y - 8)
	bio_stat_bullets:add_child(self.bio_attack_icon)

	y = y + y_d

	-- 攻击速度
	self.bio_time = GGLabel:new(V.v(80, 17))
	self.bio_time.pos = v(x, y)
	self.bio_time.colors.text = {255, 255, 255}
	self.bio_time.text = "200"
	self.bio_time.text_align = "left"
	self.bio_time.font_name = CJK("body", nil, nil, "h_noti")
	self.bio_time.font_size = 16
	self.bio_time.text_offset.y = -1
	self.bio_time.vertical_align = "middle"
	self.bio_time.fit_lines = 1
	bio_stat_bullets:add_child(self.bio_time)

	-- 英雄徽章和等级显示
	local bio_hero_badge = KImageView:new("heroroom_heroBadge_notxt_0002")
	bio_hero_badge.anchor = v(bio_hero_badge.size.x, bio_hero_badge.size.y / 2)
	bio_hero_badge.pos = v(-5 - 245, 40)
	self.bio_view:add_child(bio_hero_badge)

	self.bio_level_num = KImageView:new("heroroom_heroBadge_numbers_0001")
	self.bio_level_num.pos = v(-75 - 245, 40)
	self.bio_level_num.scale = v(0.5, 0.5)
	self.bio_level_num.anchor = v(self.bio_level_num.size.x / 2, self.bio_level_num.size.y / 2)
	self.bio_view:add_child(self.bio_level_num)

	self.bio_hero_bar = KImageView:new("hero_bar_middle")
	self.bio_hero_bar.pos = v(-105 - 245, 60)
	self.bio_hero_bar.anchor = v(0, self.bio_hero_bar.size.y / 2)
	self.bio_hero_bar.scale = v(0.5, 1)
	self.bio_view:add_child(self.bio_hero_bar)

	self.bio_hero_bar_init = KImageView:new("hero_bar_init")
	self.bio_hero_bar_init.anchor = v(self.bio_hero_bar_init.size.x, self.bio_hero_bar_init.size.y / 2)
	self.bio_hero_bar_init.pos = v(-104 - 245, 60)
	self.bio_view:add_child(self.bio_hero_bar_init)

	self.bio_hero_bar_end = KImageView:new("hero_bar_end")
	self.bio_hero_bar_end.anchor = v(self.bio_hero_bar_end.size.x, self.bio_hero_bar_end.size.y / 2)
	self.bio_hero_bar_end.pos = v(-105 - 245 + 58, 60)
	self.bio_view:add_child(self.bio_hero_bar_end)

	-- 职业标签
	self.bio_class_label = GGLabel:new(V.v(104, 14))
	self.bio_class_label.pos = v(-155 - 245 + 24, ISW(71, "zh-Hans", 66, "zh-Hant", 69, "ko", 69))
	self.bio_class_label.font_name = CJK("body", nil, nil, "sans_bold")
	self.bio_class_label.font_size = 14
	self.bio_class_label.colors.text = {0, 0, 0}
	self.bio_class_label.text = "class"
	self.bio_class_label.text_align = "center"
	self.bio_class_label.vertical_align = ISW("middle-caps", "zh-Hans", "top", "zh-Hant", "top")
	self.bio_class_label.fit_lines = 1
	self.bio_view:add_child(self.bio_class_label)

	local close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")

	close_button.pos = v(self.back.size.x - 53, 19)

	function close_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end

	self.close_button = close_button

	self.back:add_child(close_button)

	self.portrait = KImageView:new("portrait_notxt_0001")
	self.portrait.scale = v(0.9, 0.9)
	self.portrait.anchor = v(self.portrait.size.x / 2, self.portrait.size.y / 2)
	self.portrait.pos = v(400, 510)

	self.back:add_child(self.portrait)

	self.portrait_name = HeroNameLabel:new(V.v(200, 100))
	self.portrait_name.pos = v(300, 552)

	self.back:add_child(self.portrait_name)

	self.portrait_over = KView:new(V.v(self.portrait.size.x, self.portrait.size.y))
	self.portrait_over.scale = v(0.9, 0.9)
	self.portrait_over.colors.background = {
		255,
		255,
		255,
		0
	}
	self.portrait_over.propagate_on_click = true
	self.portrait_over.anchor = v(self.portrait.size.x / 2, self.portrait.size.y / 2)
	self.portrait_over.pos = v(400, 510)

	self.back:add_child(self.portrait_over)

	local over_portrait = KImageView:new("heroroom_020")

	over_portrait.anchor = v(over_portrait.size.x / 2, over_portrait.size.y / 2)
	over_portrait.pos = v(400, 510)

	self.back:add_child(over_portrait)
	self.skills:load_hero(1)

	self.selected_spr = KImageView:new("heroroom_btnSelect_0003")
	self.selected_spr.pos = v(320, 655)

	self.back:add_child(self.selected_spr)

	self.selected_spr.hidden = true

	local selected_text = GGShaderLabel:new(V.v(114, 38))

	selected_text.pos = v(25, 16)
	selected_text.font_size = 24
	selected_text.font_name = "button"
	selected_text.text_align = "center"
	selected_text.vertical_align = ISW("middle-caps", "zh-Hans", "middle", "ko", "middle", "ja", "middle", "zh-Hant", "middle")
	selected_text.text = _("MAP_HERO_ROOM_SELECTED")
	selected_text.colors.text = {
		233,
		222,
		178,
		255
	}
	selected_text.fit_lines = 1
	selected_text.shaders = {
		"p_glow"
	}
	selected_text.shader_args = {
		{
			thickness = 3,
			glow_color = {
				0.23921568627450981,
				0.19607843137254902,
				0.1568627450980392,
				1
			}
		}
	}

	self.selected_spr:add_child(selected_text)

	self.locked_spr = KImageView:new("heroroom_btnSelect_0004")
	self.locked_spr.pos = v(320, 655)

	self.back:add_child(self.locked_spr)

	self.locked_spr.hidden = true

	local locked_text = GGLabel:new(V.v(114, 38))

	locked_text.pos = v(25, 16)
	locked_text.font_size = 16
	locked_text.font_name = "button"
	locked_text.text_align = "center"
	locked_text.vertical_align = ISW("middle-caps", "zh-Hans", "middle", "ko", "middle", "ja", "middle", "zh-Hant", "middle")
	locked_text.colors.text = {
		255,
		255,
		255
	}

	self.locked_spr:add_child(locked_text)

	self.locked_spr.l_text = locked_text

	self.select_but = GGButton:new("heroroom_btnSelect_0001", "heroroom_btnSelect_0002", "heroroom_btnSelect_0002")
	self.select_but.pos = v(320, 655)
	self.select_but.anchor = v(0, 0)
	self.select_but.on_down_scale = nil
	self.select_but.label.size = v(114, 38)
	self.select_but.label.text_size = self.select_but.label.size
	self.select_but.label.pos = v(25, 16)
	self.select_but.label.font_size = 24
	self.select_but.label.vertical_align = ISW("middle-caps", "zh-Hans", "middle", "ko", "middle", "ja", "middle", "zh-Hant", "middle")
	self.select_but.label.text = _("MAP_HERO_ROOM_SELECT")
	self.select_but.label.fit_lines = 1

	function self.select_but.on_click()
		if infinite_heroes.enabled(screen_map.user_data) then
			S:queue("GUIButtonCommon")
			self:change_infinite_hero(1)
			return
		end
		local i = self.selected_index
		local hd = screen_map.hero_data[i]

		if hd.transplanting == true then
			return
		end
		S:queue("GUIBuyUpgrade")

		if not screen_map.user_data.seen.heroroom_help_select then
			screen_map.user_data.seen.heroroom_help_select = true
			self.help_select.hidden = true
		end

		screen_map.skill_label.text = self.skills.points.text

		if tonumber(self.skills.points.text) == 0 then
			screen_map.skill_star.hidden = true
		else
			screen_map.skill_star.hidden = false
		end

		self.hero_select.selected.pos = self:hero_thumb_cell_pos(i, hd)
		screen_map.user_data.heroes.selected = hd.name

		local ht = E:get_template(hd.name)

		S:queue(ht.sound_events.hero_room_select)

		local h_status = screen_map.user_data.heroes.status[screen_map.user_data.heroes.selected]
		local starting_xp = hd.starting_level < 2 and 0 or GS.hero_xp_thresholds[hd.starting_level - 1]

		h_status.xp = math.min(math.max(h_status.xp, starting_xp), 1153000)

		storage:save_slot(screen_map.user_data)

		self.select_but.hidden = true
		self.selected_spr.hidden = false
		self.real_selected = i
		local kr4_portrait_name = kr4_map_hero_portrait_name(hd)
		local kr6_portrait_name = kr6_map_hero_portrait_name(hd)

		if hd.icon <= 47 then
			screen_map.hero_icon_portrait:set_image(string.format("mapButtons_portrait_hero_%04i", hd.icon))
			screen_map.hero_icon_portrait.pos = v(0, 0)
			screen_map.hero_icon_portrait.scale = v(1, 1)
		elseif kr4_portrait_name then
			screen_map.hero_icon_portrait:set_image(kr4_portrait_name)
			screen_map.hero_icon_portrait.pos = v(0, 0)
			screen_map.hero_icon_portrait.scale = v(1, 1)
		elseif kr6_portrait_name then
			screen_map.hero_icon_portrait:set_image(kr6_portrait_name)
			screen_map.hero_icon_portrait.pos = v(0, 0)
			screen_map.hero_icon_portrait.scale = v(1, 1)
		else
			screen_map.hero_icon_portrait:set_image(string.format("hero_room_portraits_small_button_%s_0001", hd.name))
			if is_rebborn2_hero_thumb(hd) then
				screen_map.hero_icon_portrait.pos = v(0, 0)
				screen_map.hero_icon_portrait.scale = v(1, 1)
			else
				screen_map.hero_icon_portrait.pos = v(78, 44)
				screen_map.hero_icon_portrait.scale = v(0.8, 0.8)
			end
		end

		screen_map.hero_icon_portrait.hidden = false
		self.portrait_over.colors.background = {
			255,
			255,
			255,
			255
		}

		timer.tween(0.8, self.portrait_over.colors, {
			background = {
				255,
				255,
				255,
				0
			}
		}, "out-quad")

		self:update_selected_hero()
	end

	self.back:add_child(self.select_but)
	self:construct_hero(self.selected_index)


	if screen_map.user_data.liuhui == nil then
		screen_map.user_data.liuhui = {}
	end
	if screen_map.user_data.liuhui.g1_level10 == nil then
		screen_map.user_data.liuhui.g1_level10 = false
	end
	if screen_map.user_data.liuhui.hero_enhance == nil then
		screen_map.user_data.liuhui.hero_enhance = false
	end

	self.g1_level_but = GGButton:new("heroroom_btnSelect_0001", "heroroom_btnSelect_0002", "heroroom_btnSelect_0002")
	--self.g1_level_but.anchor = v(0, 0)
	self.g1_level_but.on_down_scale = nil
	self.g1_level_but.label.size = v(114, 38)
	self.g1_level_but.pos = v(self.back.size.x - 700 - self.g1_level_but.size.x - 20, self.back.size.y - 112)--v(self.back.size.x - 498 - self.g1_level_but.size.x - 20, self.back.size.y - 32)--v(self.back.size.x - 498 - self.g1_level_but.size.x - 20, self.back.size.y - 32)
	self.g1_level_but.label.text_size = self.g1_level_but.label.size
	self.g1_level_but.label.pos = v(25, 16)
	self.g1_level_but.label.font_size = 24
	self.g1_level_but.label.font_name = "body_bold"
	self.g1_level_but.label.vertical_align = ISW("middle-caps", "zh-Hans", "middle", "ko", "middle", "ja", "middle", "zh-Hant", "middle")
	self.g1_level_but.label.text = screen_map.user_data.liuhui.g1_level10 and _("HERO_G1_LEVEL10_ON") or _("HERO_G1_LEVEL10_OFF")
	self.g1_level_but.label.fit_lines = 1

	function self.g1_level_but.on_click()
		screen_map.user_data.liuhui.g1_level10 = not screen_map.user_data.liuhui.g1_level10
		storage:save_slot(screen_map.user_data)
		self.g1_level_but.label.text = screen_map.user_data.liuhui.g1_level10 and _("HERO_G1_LEVEL10_ON") or _("HERO_G1_LEVEL10_OFF")
		S:queue("GUIButtonCommon")
	end

	self.back:add_child(self.g1_level_but)

	self:create_hero_deck_panel()
	self:create_infinite_hero_panel()

	if not IS_KR3 then
		local header = GGPanelHeader:new(_("HERO ROOM"), 274)

		header.pos = V.v(397, CJK(26, 24, nil, 24))

		self.back:add_child(header)
	end

	if not screen_map.user_data.seen.heroroom_help or DEBUG_HEROROOM_HELP then
		self.hero_help = KImageView:new("heroroom_001_notxt")

		self.back:add_child(self.hero_help)

		self.hero_help.colors.tint = {
			0,
			0,
			0,
			150
		}

		function self.hero_help.on_click()
			timer.tween(0.5, self.hero_help, {
				alpha = 0
			}, "out-quad", function()
				self.back:remove_child(self.hero_help)
			end)

			screen_map.user_data.seen.heroroom_help = true
			screen_map.user_data.seen.heroroom_double_help = true

			storage:save_slot(screen_map.user_data)
		end

		function self.hero_help.disable()
			self.hero_help.colors.tint = {
				0,
				0,
				0,
				120
			}
		end

		function self.hero_help.remove_disabled_tint()
			self.hero_help.colors.tint = {
				0,
				0,
				0,
				120
			}
		end

		local help_ability = KImageView:new("heroroom_help_abilities_notxt")

		help_ability.pos = v(572, 466)

		self.hero_help:add_child(help_ability)

		local help_ability_text = GGLabel:new(V.v(326, 28))

		help_ability_text.font_name = "body"
		help_ability_text.font_size = 24
		help_ability_text.colors.text = {
			0,
			0,
			0,
			255
		}
		help_ability_text.text_align = "center"
		help_ability_text.vertical_align = "middle"
		help_ability_text.text = _("Select and train abilities")
		help_ability_text.pos = v(12, 15)
		help_ability_text.fit_lines = 1

		help_ability:add_child(help_ability_text)

		local help_select = KImageView:new("heroroom_help_select_notxt")

		help_select.pos = v(85, 645)

		self.hero_help:add_child(help_select)

		local help_select_text = GGLabel:new(V.v(200, 30))

		help_select_text.font_name = "body"
		help_select_text.font_size = 24
		help_select_text.colors.text = {
			0,
			0,
			0,
			255
		}
		help_select_text.text_align = "center"
		help_select_text.vertical_align = "middle"
		help_select_text.text = _("Click to select")
		help_select_text.pos = v(13, 15)
		help_select_text.fit_lines = 1

		help_select:add_child(help_select_text)
	end

	if IS_KR3 then
		local header_bg = KImageView("kr3_title_bg")

		header_bg.anchor.x = km.round(header_bg.size.x / 2)
		header_bg.pos = v(km.round(self.back.size.x / 2), -36)

		self.back:add_child(header_bg)

		local header = GGPanelHeader:new(_("HERO ROOM"), 274)

		header.pos = V.v(397, CJK(26, 24, nil, 24) - 36)

		self.back:add_child(header)
	end

	local done_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	done_button.anchor = v(math.floor(done_button.size.x / 2), done_button.size.y / 2)
	done_button.pos = v(self.back.size.x - 166, self.back.size.y - 32)
	done_button.label.size = v(100, 34)
	done_button.label.text_size = done_button.label.size
	done_button.label.pos = v(20, 19)
	done_button.label.font_size = 24
	done_button.label.font_name = "body_bold"
	done_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	done_button.label.text = _("BUTTON_DONE")
	done_button.label.fit_lines = 1

	function done_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end

	self.back:add_child(done_button)

	self.done_button = done_button

	local switch_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	switch_button.anchor = v(math.floor(done_button.size.x / 2), done_button.size.y / 2)
	switch_button.pos = v(self.back.size.x - 694 - done_button.size.x - 20, self.back.size.y - 32)
	switch_button.label.size = v(100, 34)
	switch_button.label.text_size = done_button.label.size
	switch_button.label.pos = v(20, 19)
	switch_button.label.font_size = 18
	switch_button.label.font_name = "body_bold"
	switch_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	switch_button.label.text = infinite_heroes.enabled(screen_map.user_data) and "Vô hạn tướng" or (screen_map.user_data.liuhui_hero.usedoublehero and "Hai tướng" or "Một tướng")
	switch_button.label.fit_lines = 1

	function switch_button.on_click()
		S:queue("GUIButtonCommon")
		local settings = screen_map.user_data.liuhui_hero
		if settings.useinfinitehero then
			settings.useinfinitehero, settings.usedoublehero = false, false
		elseif settings.usedoublehero then
			settings.useinfinitehero, settings.usedoublehero = true, false
			settings = infinite_heroes.settings(screen_map.user_data)
			if #settings.infiniteheroes == 0 then settings.infiniteheroes[1] = screen_map.user_data.heroes.selected end
		else
			settings.usedoublehero = true
		end
		switch_button.label.text = infinite_heroes.enabled(screen_map.user_data) and "Vô hạn tướng" or (screen_map.user_data.liuhui_hero.usedoublehero and "Hai tướng" or "Một tướng")
		storage:save_slot(screen_map.user_data)
		self:update_selected_hero()
	end

	self.back:add_child(switch_button)

	self.switch_button = switch_button

	self:update_selected_hero()

	--英雄界面切换按钮
	switch_hero_room_page()
	if self.real_selected > 16 and self.real_selected <= 32 then
		switch_hero_room_page()
	elseif self.real_selected > 32 and self.real_selected <= 48 then
		switch_hero_room_page()
		switch_hero_room_page()
	elseif self.real_selected >= 49 and self.real_selected <= 64 then
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
	elseif self.real_selected >= 65 and self.real_selected <= 80 then
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
	elseif self.real_selected >= 81 then
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
		switch_hero_room_page()
	end

	local next_page_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	next_page_button.anchor = v(math.floor(done_button.size.x / 2), done_button.size.y / 2)
	next_page_button.pos = v(self.back.size.x - 166 - done_button.size.x - 20, self.back.size.y - 32)
	next_page_button.label.size = v(100, 34)
	next_page_button.label.text_size = done_button.label.size
	next_page_button.label.pos = v(20, 19)
	next_page_button.label.font_size = 24
	next_page_button.label.font_name = "body_bold"
	next_page_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	next_page_button.label.text = _("BUTTON_NEXT_PAGE")
	next_page_button.label.fit_lines = 1

	function next_page_button.on_click()
		for i, v in ipairs(self.hero_views) do
			if (i >= self.hero_viewing and i - self.hero_viewing < 16) then
				v.hidden = false
			else
				v.hidden = true
			end
		end
		self.hero_viewing = self.hero_viewing + 16
		if self.hero_viewing > #self.hero_views then
			self.hero_viewing = 1
		end
		S:queue("GUIButtonCommon")
	end

	self.back:add_child(next_page_button)

	self.next_page_button = next_page_button

	local hero_enhance_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	hero_enhance_button.anchor = v(math.floor(done_button.size.x / 2), done_button.size.y / 2)
	hero_enhance_button.pos = v(next_page_button.pos.x, self.g1_level_but.pos.y)
	hero_enhance_button.label.size = v(100, 34)
	hero_enhance_button.label.text_size = done_button.label.size
	hero_enhance_button.label.pos = v(20, 19)
	hero_enhance_button.label.font_size = 18
	hero_enhance_button.label.font_name = "body_bold"
	hero_enhance_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	hero_enhance_button.label.text = screen_map.user_data.liuhui.hero_enhance and _("HERO_ENHANCE_ON") or _("HERO_ENHANCE_OFF")
	hero_enhance_button.label.fit_lines = 1

	function hero_enhance_button.on_click()
		screen_map.user_data.liuhui.hero_enhance = not screen_map.user_data.liuhui.hero_enhance
		storage:save_slot(screen_map.user_data)

		local ok, hero_enhance_mod = pcall(require, "hero_enhance_mod")

		if ok and hero_enhance_mod.set_enabled then
			hero_enhance_mod:set_enabled(screen_map.user_data.liuhui.hero_enhance)
		end

		E:load()
		UPGR:set_all_generation_levels(screen_map.user_data)
		DI:set_level(screen_map.user_data.difficulty)
		UPGR:patch_templates(5)
		DI:patch_templates()
		self:update_hero_enhance_button()
		self:construct_hero(self.selected_index)
		S:queue("GUIButtonCommon")
	end

	self.back:add_child(hero_enhance_button)

	self.hero_enhance_button = hero_enhance_button

	local hero_auto_rally_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	hero_auto_rally_button.anchor = v(math.floor(done_button.size.x / 2), done_button.size.y / 2)
	hero_auto_rally_button.pos = v(hero_enhance_button.pos.x - done_button.size.x - 20, self.g1_level_but.pos.y)
	hero_auto_rally_button.label.size = v(100, 34)
	hero_auto_rally_button.label.text_size = done_button.label.size
	hero_auto_rally_button.label.pos = v(20, 19)
	hero_auto_rally_button.label.font_size = 18
	hero_auto_rally_button.label.font_name = "body_bold"
	hero_auto_rally_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	hero_auto_rally_button.label.text = screen_map.user_data.liuhui.hero_auto_rally and CJK("Auto Rally: On", "Tự tập kết: bật", "自動集結：オン", "자동 집결: 켬") or CJK("Auto Rally: Off", "Tự tập kết: tắt", "自動集結：オフ", "자동 집결: 끔")
	hero_auto_rally_button.label.fit_lines = 1

	function hero_auto_rally_button.on_click()
		screen_map.user_data.liuhui.hero_auto_rally = not screen_map.user_data.liuhui.hero_auto_rally
		storage:save_slot(screen_map.user_data)
		self:update_hero_auto_rally_button()
		S:queue("GUIButtonCommon")
	end

	self.back:add_child(hero_auto_rally_button)
	self.hero_auto_rally_button = hero_auto_rally_button

	local prev_page_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")

	prev_page_button.anchor = v(math.floor(done_button.size.x / 2), done_button.size.y / 2)
	prev_page_button.pos = v(self.back.size.x - 332 - done_button.size.x - 20, self.back.size.y - 32)
	prev_page_button.label.size = v(100, 34)
	prev_page_button.label.text_size = done_button.label.size
	prev_page_button.label.pos = v(20, 19)
	prev_page_button.label.font_size = 24
	prev_page_button.label.font_name = "body_bold"
	prev_page_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	prev_page_button.label.text = _("BUTTON_PREV_PAGE")
	prev_page_button.label.fit_lines = 1

	function prev_page_button.on_click()
		for jt = 1, math.ceil(#self.hero_views / 16) - 1 do
			for i, v in ipairs(self.hero_views) do
				if (i >= self.hero_viewing and i - self.hero_viewing < 16) then
					v.hidden = false
				else
					v.hidden = true
				end
			end
			self.hero_viewing = self.hero_viewing + 16
			if self.hero_viewing > #self.hero_views then
				self.hero_viewing = 1
			end
		end
		S:queue("GUIButtonCommon")
	end

	self.back:add_child(prev_page_button)

	self.prev_page_button = prev_page_button

	local over_done_button = KImageView:new("heroroom_014_large")

	over_done_button.anchor = v(math.floor(over_done_button.size.x / 2), over_done_button.size.y / 2)
	over_done_button.pos = v(self.back.size.x - 168, self.back.size.y - 34)

	self.back:add_child(over_done_button)

	over_done_button.propagate_on_click = true

	self.kr6_tree = Kr6HeroUpgradeTreeView:new(self)
	self.kr6_tree.pos = v((self.back.size.x - self.kr6_tree.size.x) / 2, 220)
	self.back:add_child(self.kr6_tree)

end

function HeroRoomView:update_hero_enhance_button()
	if self.hero_enhance_button then
		self.hero_enhance_button.label.text = screen_map.user_data.liuhui.hero_enhance and _("HERO_ENHANCE_ON") or _("HERO_ENHANCE_OFF")
	end
end

function HeroRoomView:update_hero_auto_rally_button()
	if self.hero_auto_rally_button then
		self.hero_auto_rally_button.label.text = screen_map.user_data.liuhui.hero_auto_rally and CJK("Auto Rally: On", "Tự tập kết: bật", "自動集結：オン", "자동 집결: 켬") or CJK("Auto Rally: Off", "Tự tập kết: tắt", "自動集結：オフ", "자동 집결: 끔")
	end
end

local function hero_deck_label(text, size, font_size)
	local label = GGLabel:new(size)

	label.font_name = "body_bold"
	label.font_size = font_size or 18
	label.colors.text = {245, 230, 180, 255}
	label.text = text
	label.text_align = "center"
	label.vertical_align = "middle"
	label.fit_lines = 1

	return label
end

function HeroRoomView:create_hero_deck_slot(deck_name, slot_index, x)
	local slot = KView:new(V.v(76, 76))

	slot.pos = v(x, 61)
	slot.colors.background = {34, 28, 20, 255}

	local portrait = KImageView:new("heroroom_014_large")

	portrait.propagate_on_click = true
	portrait.pos = v(38, 38)
	slot.portrait = portrait
	slot:add_child(portrait)

	local number = hero_deck_label(tostring(slot_index), V.v(20, 20), 15)

	number.pos = v(2, 2)
	number.colors.background = {12, 10, 8, 210}
	number.propagate_on_click = true
	slot:add_child(number)

	function slot.on_click()
		self:assign_selected_hero_to_deck(deck_name, slot_index)
	end

	self.deck_panel:add_child(slot)
	table.insert(self.deck_slots, slot)
end

function HeroRoomView:create_hero_deck_panel()
	local panel = KView:new(V.v(self.back.size.x - 40, 142))

	panel.pos = v(20, self.back.size.y + 3)
	panel.colors.background = {37, 31, 22, 248}
	self.back:add_child(panel)
	self.deck_panel = panel
	self.deck_slots = {}

	local instruction_text = "Chọn anh hùng phía trên, rồi nhấn nút phía dưới để thêm vào đội."
	local instruction = hero_deck_label(instruction_text, V.v(panel.size.x - 24, 28), 18)

	instruction.pos = v(12, 3)
	panel:add_child(instruction)
	self.hero_deck_instruction = instruction
	self.hero_deck_instruction_text = instruction_text

	self.single_hero_deck_outline = tower_deck_outline(164, 108)
	self.single_hero_deck_outline.pos = v(62, 32)
	panel:add_child(self.single_hero_deck_outline)

	self.double_hero_deck_outline = tower_deck_outline(194, 108)
	self.double_hero_deck_outline.pos = v(250, 32)
	panel:add_child(self.double_hero_deck_outline)

	local single_label = hero_deck_label("Đội một anh hùng", V.v(130, 26), 18)
	local double_label = hero_deck_label("Đội hai anh hùng", V.v(160, 26), 18)
	local rally_label = hero_deck_label("Đội hội quân", V.v(300, 26), 18)

	single_label.pos = v(72, 33)
	double_label.pos = v(263, 33)
	rally_label.pos = v(579, 33)
	panel:add_child(single_label)
	panel:add_child(double_label)
	panel:add_child(rally_label)

	self:create_hero_deck_slot("single", 1, 99)
	self:create_hero_deck_slot("double", 1, 267)
	self:create_hero_deck_slot("double", 2, 351)
	self:create_hero_deck_slot("rally", 1, 563)
	self:create_hero_deck_slot("rally", 2, 647)
	self:create_hero_deck_slot("rally", 3, 731)
	self:create_hero_deck_slot("rally", 4, 815)

	self:update_selected_hero()
end

function HeroRoomView:infinite_deck_button(parent, text, x, y, width, action)
	local button = KView:new(v(width, 28))
	button.pos = v(x, y)
	button.colors.background = {66, 75, 39, 255}
	local label = hero_deck_label(text, v(width, 28), 15)
	label.propagate_on_click = true
	button:add_child(label)
	function button.on_click(_, mouse_button)
		if mouse_button == 1 or mouse_button == nil then S:queue("GUIButtonCommon"); action() end
	end
	parent:add_child(button)
	return button
end

function HeroRoomView:create_infinite_hero_panel()
	local panel = KView:new(v(self.deck_panel.size.x, 142))
	panel.pos = V.vclone(self.deck_panel.pos)
	panel.colors.background = {37, 31, 22, 248}
	self.back:add_child(panel)
	self.infinite_panel = panel
	self.infinite_page = 1
	self.infinite_slots = {}
	self.infinite_team_info = hero_deck_label("", v(270, 28), 15)
	self.infinite_team_info.pos = v(10, 32)
	panel:add_child(self.infinite_team_info)
	self:infinite_deck_button(panel, "< Đội", 605, 32, 120, function() self:change_infinite_team(-1) end)
	self:infinite_deck_button(panel, "Đội >", 735, 32, 115, function() self:change_infinite_team(1) end)
	self:infinite_deck_button(panel, "Đội mới", 495, 32, 100, function() self:change_infinite_team(0, false) end)
	self:infinite_deck_button(panel, "Nhân bản", 285, 32, 100, function() self:change_infinite_team(0, true) end)
	self.infinite_delete_team_button = self:infinite_deck_button(panel, "Xóa đội", 395, 32, 90, function()
		if not infinite_heroes.delete_team(screen_map.user_data) then
			self.infinite_team_info.text = "Cần giữ ít nhất 1 đội"
			return
		end
		self.infinite_page = 1
		storage:save_slot(screen_map.user_data)
		self:update_infinite_hero_panel()
	end)
	self.infinite_delete_team_button.colors.background = {168, 45, 38, 255}
	self.infinite_delete_team_button.children[1].colors.text = {255, 245, 232, 255}
	self.infinite_info = hero_deck_label("", v(140, 28), 14)
	self.infinite_info.pos = v(10, 3)
	panel:add_child(self.infinite_info)
	self.infinite_selection = hero_deck_label("", v(125, 28), 14)
	self.infinite_selection.pos = v(150, 3)
	panel:add_child(self.infinite_selection)
	self:infinite_deck_button(panel, "+ Thêm", 285, 3, 100, function() self:change_infinite_hero(1) end)
	self:infinite_deck_button(panel, "- Bỏ", 395, 3, 90, function() self:change_infinite_hero(-1) end)
	self:infinite_deck_button(panel, "Bỏ hết", 495, 3, 100, function()
		local list = infinite_heroes.settings(screen_map.user_data).infiniteheroes
		for n = #list, 1, -1 do table.remove(list, n) end
		self.infinite_page = 1
		storage:save_slot(screen_map.user_data); self:update_infinite_hero_panel()
	end)
	self:infinite_deck_button(panel, "Trang trước", 605, 3, 120, function()
		self.infinite_page = math.max(1, self.infinite_page - 1); self:update_infinite_hero_panel()
	end)
	self:infinite_deck_button(panel, "Trang sau", 735, 3, 115, function()
		local list = infinite_heroes.settings(screen_map.user_data).infiniteheroes
		self.infinite_page = math.min(math.max(1, math.ceil(#list / 8)), self.infinite_page + 1); self:update_infinite_hero_panel()
	end)
	for n = 1, 8 do
		local slot = KView:new(v(76, 76))
		slot.pos = v(24 + (n - 1) * ((panel.size.x - 110) / 7), 64)
		slot.colors.background = {34, 28, 20, 255}
		slot.portrait = KImageView:new("heroroom_014_large")
		slot.portrait.propagate_on_click = true
		slot:add_child(slot.portrait)
		slot.number = hero_deck_label("", v(36, 20), 12)
		slot.number.colors.background = {12, 10, 8, 210}
		slot.number.propagate_on_click = true
		slot:add_child(slot.number)
		function slot.on_click(_, mouse_button)
			if mouse_button ~= nil and mouse_button ~= 1 then return end
			local list = infinite_heroes.settings(screen_map.user_data).infiniteheroes
			if slot.team_index and list[slot.team_index] then
				table.remove(list, slot.team_index)
				storage:save_slot(screen_map.user_data); self:update_infinite_hero_panel()
			end
		end
		panel:add_child(slot); self.infinite_slots[n] = slot
	end
	self:update_selected_hero()
end

function HeroRoomView:change_infinite_team(delta, copy_current)
	local settings = infinite_heroes.settings(screen_map.user_data)
	if delta == 0 then
		infinite_heroes.new_team(screen_map.user_data, copy_current)
	else
		infinite_heroes.select_team(screen_map.user_data, settings.infinite_team_index + delta)
	end
	self.infinite_page = 1
	storage:save_slot(screen_map.user_data)
	self:update_infinite_hero_panel()
end

function HeroRoomView:change_infinite_hero(delta)
	local list = infinite_heroes.settings(screen_map.user_data).infiniteheroes
	if delta > 0 then
		local boss = infinite_heroes.get_boss(self.selected_boss)
		local hd = boss or screen_map.hero_data[self.selected_index]
		if not hd or hd.transplanting or hd.coming_soon or (hd.available_level or 0) > #screen_map.user_data.levels then return end
		list[#list + 1] = hd.name
		if boss and not screen_map.user_data.heroes.status[hd.name] then
			screen_map.user_data.heroes.status[hd.name] = {xp = GS.hero_xp_thresholds[9], skills = {}}
		end
		local status = screen_map.user_data.heroes.status[hd.name]
		local xp = boss and GS.hero_xp_thresholds[9] or (hd.starting_level < 2 and 0 or GS.hero_xp_thresholds[hd.starting_level - 1])
		if status then status.xp = math.max(status.xp or 0, xp or 0) end
		self.infinite_page = math.ceil(#list / 8)
	else
		if #list > 0 then table.remove(list) end
	end
	storage:save_slot(screen_map.user_data)
	self:update_infinite_hero_panel()
end

function HeroRoomView:update_infinite_hero_panel()
	local settings = infinite_heroes.settings(screen_map.user_data)
	local list = settings.infiniteheroes
	local pages = math.max(1, math.ceil(#list / 8))
	self.infinite_page = math.min(self.infinite_page, pages)
	self.infinite_info.text = #list .. " tướng | " .. self.infinite_page .. "/" .. pages
	local boss = infinite_heroes.get_boss(self.selected_boss)
	local hd = boss or screen_map.hero_data[self.selected_index]
	local ht = not boss and hd and E:get_template(hd.name)
	self.infinite_selection.text = boss and self:allied_room_name(boss) or hd and _(string.upper(ht and ht.info and ht.info.i18n_key or hd.name) .. "_NAME", hd.name) or "Chọn hero/boss"
	local available = hd and not hd.transplanting and not hd.coming_soon and (hd.available_level or 0) <= #screen_map.user_data.levels
	local unlimited = infinite_heroes.enabled(screen_map.user_data)
	self.select_but.hidden = not available or not unlimited and (boss ~= nil or self.selected_index == self.real_selected)
	self.selected_spr.hidden = unlimited or boss ~= nil or self.selected_index ~= self.real_selected
	if unlimited and available then self.locked_spr.hidden = true end
	if unlimited and self.help_select then self.help_select.hidden = true end
	self.infinite_team_info.text = settings.infinite_teams[settings.infinite_team_index].name .. " (" .. settings.infinite_team_index .. "/" .. #settings.infinite_teams .. ")"
	self.infinite_delete_team_button.alpha = #settings.infinite_teams > 1 and 1 or 0.5
	for n, slot in ipairs(self.infinite_slots) do
		local index = (self.infinite_page - 1) * 8 + n
		local hero_index = infinite_heroes.get_boss(list[index]) and list[index] or list[index] and get_hero_index(list[index])
		slot.team_index = hero_index and index or nil
		if hero_index then
			self:set_hero_deck_slot(slot, hero_index)
			slot.number.text = tostring(index)
		else slot.hidden = true end
	end
end

function HeroRoomView:set_hero_deck_slot(slot, hero_index)
	local hd = screen_map.hero_data[hero_index]
	local is_boss = infinite_heroes.get_boss(hero_index)

	if not hd and not is_boss then
		slot.hidden = true
		return
	end

	slot.hidden = false
	local image_name = is_boss and is_boss.icon or (hero_index <= 47 and string.format("heroroom_portraits_%04i", hd.thumb) or string.format("hero_room_portraits_small_thumb_%s_0001", hd.name))

	slot.portrait:set_image(image_name)
	slot.portrait._draw_self = is_boss and is_boss.portrait_draw or nil
	local scale = math.min(70 / slot.portrait.size.x, 70 / slot.portrait.size.y)

	slot.portrait.anchor = v(slot.portrait.size.x / 2, slot.portrait.size.y / 2)
	slot.portrait.pos = v(38, 38)
	slot.portrait.scale = v(scale, scale)
end

function HeroRoomView:assign_selected_hero_to_deck(deck_name, slot_index)
	local index = self.selected_index
	local hd = screen_map.hero_data[index]

	if not hd or hd.transplanting == true or hd.available_level > #screen_map.user_data.levels then
		S:queue("GUIButtonCommon")
		return
	end

	if self.selected_boss then return end
	if deck_name == "single" then
		self.select_but.on_click()
		return
	elseif deck_name == "double" then
		screen_map.user_data.liuhui_hero.herolist[slot_index] = index
	else
		local duplicate_count = 0

		for current_slot, current_index in ipairs(screen_map.user_data.liuhui_hero.rallylist or {}) do
			local current_hd = screen_map.hero_data[current_index]

			if current_slot ~= slot_index and current_hd and current_hd.name == hd.name then
				duplicate_count = duplicate_count + 1
			end
		end

		if duplicate_count >= 2 then
			tower_select_show_legacy_slot_hint(self, "Chọn đội anh hùng", "Ở chế độ này, chỉ được chọn tối đa hai bản sao của cùng một anh hùng.", true)
			S:queue("GUIButtonCommon")

			return
		end

		screen_map.user_data.liuhui_hero.rallylist[slot_index] = index
	end

	local ht = E:get_template(hd.name)
	local status = screen_map.user_data.heroes.status[hd.name]
	local starting_xp = hd.starting_level < 2 and 0 or GS.hero_xp_thresholds[hd.starting_level - 1]

	if ht and ht.sound_events and ht.sound_events.hero_room_select then
		S:queue(ht.sound_events.hero_room_select)
	end
	if status then
		status.xp = math.min(math.max(status.xp, starting_xp), 1153000)
	end
	storage:save_slot(screen_map.user_data)

	self:update_selected_hero()
end

function HeroRoomView:update_selected_hero()
	if self.infinite_panel then
		self.infinite_panel.hidden = not infinite_heroes.enabled(screen_map.user_data)
		self.deck_panel.hidden = not self.infinite_panel.hidden
		self:update_infinite_hero_panel()
	end
	if not self.deck_slots then
		return
	end

	local use_double_hero = screen_map.user_data.liuhui_hero.usedoublehero == true

	if self.single_hero_deck_outline then
		self.single_hero_deck_outline.hidden = use_double_hero
	end
	if self.double_hero_deck_outline then
		self.double_hero_deck_outline.hidden = not use_double_hero
	end

	local single_index = get_hero_index(screen_map.user_data.heroes.selected) or self.selected_index
	local indices = {
		single_index,
		screen_map.user_data.liuhui_hero.herolist[1],
		screen_map.user_data.liuhui_hero.herolist[2],
		screen_map.user_data.liuhui_hero.rallylist[1],
		screen_map.user_data.liuhui_hero.rallylist[2],
		screen_map.user_data.liuhui_hero.rallylist[3],
		screen_map.user_data.liuhui_hero.rallylist[4]
	}

	for i, slot in ipairs(self.deck_slots) do
		self:set_hero_deck_slot(slot, indices[i])
	end

	self.hero_deck_instruction.text = self.hero_deck_instruction_text
	self.hero_deck_instruction.colors.text = {245, 230, 180, 255}
end

function HeroRoomView:validate_infinite_team()
	if infinite_heroes.enabled(screen_map.user_data) and #infinite_heroes.names(screen_map.user_data, screen_map.hero_data) == 0 then
		if self.hidden then self:show() end
		tower_select_show_legacy_slot_hint(self, "Đội Vô hạn đang trống", "Hãy thêm ít nhất 1 tướng vào đội hoặc chuyển sang chế độ Một tướng/Hai tướng trước khi thoát.", true)
		return false
	end
	return true
end

function HeroRoomView:hide()
	if not self:validate_infinite_team() then return false end
	tower_select_hide_legacy_slot_hint(self)
	return HeroRoomView.super.hide(self)
end

function HeroRoomView:show()
	HeroRoomView.super.show(self)

	local user_data = storage:load_slot()

	E:load()
	UPGR:set_all_generation_levels(user_data)
	DI:set_level(screen_map.user_data.difficulty)
	UPGR:patch_templates(5)
	DI:patch_templates()
	self:update_hero_enhance_button()
	self:update_hero_auto_rally_button()
	self:update_selected_hero()
	self:construct_hero(self.selected_index)
end

function HeroRoomView:update_sett_skill_panel(boss)
 local entries=boss and boss.skill_cards
 local popup=boss and boss.kind=="volibear_prestige"
 self.tip_panel.hidden=true;self.tip_panel.volibear_popup=nil
 self.bio_text.hidden=popup or false
 if entries and self.sett_skill_panel and self.sett_skill_panel.boss_name~=boss.name then
  self.sett_skill_panel.parent:remove_child(self.sett_skill_panel);self.sett_skill_panel=nil
 end
 if self.sett_skill_panel then self.sett_skill_panel.hidden=not entries end
 self.bio_text.pos.y=entries and 68 or 0
 if self.bio_header then self.bio_header.text=entries and "Kỹ năng" or _("Introduction") end
 if not entries then return end
 if not self.sett_skill_panel then
  local panel=KView:new(v(350,64));self.sett_skill_panel=panel;panel.buttons={};panel.boss_name=boss.name
  self.bio_text.parent:add_child(panel)
  for index,entry in ipairs(entries) do
   local button=KButton:new(v(64,64));button.pos=v((index-1)*70,0)
   button.colors.background={42,31,57,210};panel:add_child(button);panel.buttons[index]=button
   local icon=KImageView:new(entry.icon);icon.pos=v(4,4);icon.colors.tint={205,205,215,230}
   icon.scale=v(56/icon.size.x,56/icon.size.y);icon.propagate_on_click=true;button:add_child(icon)
   local function show_popup()
    local selected=self.sett_skill_cards[index]
    local tip=self.tip_panel;tip.volibear_popup=true;tip.price.hidden=true;tip.bullet.hidden=true
    if tip.star then tip.star.hidden=true end
    self.skills:set_panel_height(selected.title,selected.description,"")
    self.skills:update_tooltip_position()
   end
   if popup then
    button.on_enter=show_popup
    button.on_exit=function()self.skills:hide_tooltip()end
   end
   function button.on_click(_,mouse_button)
    if mouse_button and mouse_button~=1 then return end
    if popup then show_popup();S:queue("GUIButtonCommon");return end
    local selected=self.sett_skill_cards[index]
    self.bio_text.text=selected.title.."\n"..selected.description
    for i,b in ipairs(panel.buttons) do b.colors.background=i==index and {112,72,145,235} or {42,31,57,210} end
    S:queue("GUIButtonCommon")
   end
  end
 end
 self.sett_skill_cards=entries
 if popup then self.bio_text.text="";return end
 self.bio_text.font_size=20;self.bio_text.size,self.bio_text.text_size=v(350,182),v(350,182)
 self.bio_text.fit_lines,self.bio_text.fit_size=nil,true
 self.sett_skill_panel.buttons[1]:on_click(1)
end

function HeroRoomView:construct_allied_boss(name)
	local boss = infinite_heroes.get_boss(name)
	if not boss then return end
	if self.help_select then self.back:remove_child(self.help_select); self.help_select = nil end
	if self.kr6_tree then self.kr6_tree:close() end
	self.old_index = nil
	self.select_but.hidden, self.selected_spr.hidden, self.locked_spr.hidden = true, true, true
	self.skills.hidden, self.bio_view.hidden = true, false
	self.g1_text.hidden, self.skills_intro_text.hidden, self.kr6_tree_button.hidden = true, true, true
	if not self.boss_portrait_frame then
		self.boss_portrait_frame=KImageView:new("encyclopedia_frame")
		self.boss_portrait_frame.anchor=v(self.boss_portrait_frame.size.x/2,self.boss_portrait_frame.size.y/2)
		self.boss_portrait_frame.pos=v(400,510)
		self.boss_portrait_frame.propagate_on_click=true
		self.back:add_child(self.boss_portrait_frame)
	end
	self.boss_portrait_frame.hidden=false
	self.portrait_over.hidden=true
	self.portrait:set_image(boss.portrait)
	self.portrait._draw_self = boss.portrait_draw
	self.portrait.anchor = v(self.portrait.size.x / 2, self.portrait.size.y / 2)
	local frame=self.boss_portrait_frame
	local scale=math.min(220/frame.size.x,290/frame.size.y)
	frame.scale=v(scale,scale)
	self.portrait.scale=v(0.7*scale,0.708*scale)
	self.portrait_name:set_hero(boss.name, nil, self:allied_room_name(boss))
	local skill_module = require("allied_boss_skills")
	local skill = skill_module.skills[skill_module.kind(name)]
	self.bio_text.text = skill.description .. (boss.basic_only and " Thêm vào đội Vô hạn hero để kiểm tra." or " Tất cả kỹ năng tự dùng khi đủ điều kiện. Thêm vào đội Vô hạn hero để chơi.")
    local is_blackburn=boss.kind=="blackburn"
    local blackburn=require("blackburn_enhance")
    local version=is_blackburn and blackburn or boss.kind=="godieth" and require("godieth_enhance")
    if not self.boss_version_button then
        local button=GGButton:new("heroroom_btnDone_large_0001","heroroom_btnDone_large_0002")
        button.anchor=v(button.size.x/2,button.size.y/2)
        button.pos=v(225,255)
        button.scale=v(0.9,0.75)
        button.label.size,button.label.text_size=v(132,34),v(132,34)
        button.label.pos=v(8,19)
        button.label.font_name,button.label.font_size="body_bold",18
        button.label.fit_lines=1
        self.bio_view:add_child(button)
        self.boss_version_button=button
    end
    self.boss_version_button.hidden=not version
    if version then
        self.boss_version_button.label.text=version.label(screen_map.user_data)
        self.boss_version_button.on_click=function()
            local slot=screen_map.user_data
            slot.liuhui=slot.liuhui or {}
            slot.liuhui[boss.kind.."_level"]=(version.level(slot)+1)%(is_blackburn and 4 or 2)
            storage:save_slot(slot)
            S:queue("GUIButtonCommon")
            self:show()
        end
        self.bio_text.text=version.description(version.level(screen_map.user_data))
    end
	local large_bio = boss.preview_stats ~= nil or boss.kind == "navira" or boss.kind == "navira_blue" or boss.kind == "godieth" or boss.kind == "set"
	local text_height = large_bio and 220 or 145
	self.bio_text.font_size = large_bio and 20 or 15
	self.bio_text.size, self.bio_text.text_size = v(350, text_height), v(350, text_height)
	self.bio_text.fit_lines = not large_bio and 6 or nil
	self.bio_text.fit_size = large_bio
    if version then
        self.bio_text.font_size=18
        self.bio_text.size,self.bio_text.text_size=v(350,170),v(350,170)
        self.bio_text.fit_lines,self.bio_text.fit_size=nil,true
    end
	local native = boss.preview_stats or E:get_template(boss.source)
    -- Stage animations are not loaded in the hero room; read stats without registering a combat template.
    local blackburn_profile=is_blackburn and blackburn.profile(blackburn.level(screen_map.user_data))
	local hp = native and native.health and native.health.hp_max
    if blackburn_profile then hp=math.floor(hp*blackburn_profile.hp+0.5) end
	self.bio_class_label.text = boss.hero_class or (boss.bombardment and "Boss - bắn diện rộng" or "Boss - cận chiến")
	self.bio_time.text = "20s"
	self.bio_armor.text = native and tostring(math.floor((blackburn_profile and blackburn_profile.armor or native.health.armor or 0) * 100)) .. "%" or "-"
	self.bio_health.text = tostring(type(hp) == "table" and hp[1] or hp or "-")
	local attack = native and native.melee and native.melee.attacks[1]
	self.bio_attack.text = boss.melee_damage and tostring(boss.melee_damage) or attack and tostring(attack.damage_min) .. "-" .. tostring(attack.damage_max) or "11-22 x 7"
    if blackburn_profile then self.bio_attack.text=blackburn_profile.damage[1].."-"..blackburn_profile.damage[2] end
	self.bio_attack_icon:set_image("heroroom_attackIcons_0001")
	self.bio_level_num:set_image("heroroom_heroBadge_numbers_0010")
	self.bio_hero_bar.hidden, self.bio_hero_bar_end.hidden, self.bio_hero_bar_init.hidden = true, true, true
	self:update_sett_skill_panel(boss)
	if self.infinite_panel then self:update_infinite_hero_panel() end
end

function HeroRoomView:construct_hero(index)
	if self.selected_boss then return self:construct_allied_boss(self.selected_boss) end
	self:update_sett_skill_panel(nil)
    if self.boss_version_button then self.boss_version_button.hidden=true end
	self.portrait._draw_self = nil
	self.bio_text.font_size, self.bio_text.size, self.bio_text.text_size = 15, v(350, 145), v(350, 145)
	self.bio_text.fit_lines, self.bio_text.fit_size = 6, nil
	if self.boss_portrait_frame then self.boss_portrait_frame.hidden=true end
	self.portrait_over.hidden=false
	if self.help_select then
		self.back:remove_child(self.help_select)

		self.help_select = nil
	end

	if index == self.real_selected then
		self.select_but.hidden = true
		self.selected_spr.hidden = false
		self.skills.no_buy = false
		self.locked_spr.hidden = true
	elseif screen_map.hero_data[index].available_level > #screen_map.user_data.levels then
		self.locked_spr.hidden = false
		self.select_but.hidden = true
		self.locked_spr.l_text.text = string.format(_("MAP_HERO_ROOM_UNLOCK"), screen_map.hero_data[index].available_level)
		self.locked_spr.l_text.fit_lines = 2
		self.skills.no_buy = true
	elseif screen_map.hero_data[index].transplanting == true then
		self.locked_spr.hidden = false
		self.select_but.hidden = true
		self.locked_spr.l_text.text = _("TRANSPLANTING")
		self.locked_spr.l_text.fit_lines = 2
		self.skills.no_buy = true
	else
		self.select_but.hidden = false
		self.selected_spr.hidden = true
		self.skills.no_buy = false
		self.locked_spr.hidden = true

		if not screen_map.user_data.seen.heroroom_help_select then
			self.help_select = KImageView:new("heroroom_help_select_notxt")
			self.help_select.pos = v(85, 645)

			self.back:add_child(self.help_select)

			local help_select_text = GGLabel:new(V.v(200, 30))

			help_select_text.font_name = "body"
			help_select_text.font_size = 24
			help_select_text.colors.text = {
				0,
				0,
				0,
				255
			}
			help_select_text.text_align = "center"
			help_select_text.vertical_align = "middle"
			help_select_text.text = _("Click to select")
			help_select_text.pos = v(13, 15)
			help_select_text.fit_lines = 1

			self.help_select:add_child(help_select_text)
		end
	end

	local hero_data = get_hero_stats(index)

	if index ~= self.old_index then
		self.old_index = index

		if hero_data.portrait <= 47 then
			self.portrait:set_image(string.format("portrait_notxt_%04i", hero_data.portrait))
			self.portrait.anchor = v(137, 193)
			self.portrait.scale = v(0.9, 0.9)
		elseif hero_data.portrait >= 950 and hero_data.portrait <= 954 or screen_map.hero_data[index].generation == 6 then
			self.portrait:set_image(string.format("hero_room_portraits_big_%s_0001", hero_data.name))
			local portrait_scale = math.min(274 / self.portrait.size.x, 386 / self.portrait.size.y)

			self.portrait.anchor = v(self.portrait.size.x / 2, self.portrait.size.y / 2)
			self.portrait.scale = v(portrait_scale, portrait_scale)
		else
			self.portrait:set_image(string.format("hero_room_portraits_big_%s_0001", hero_data.name))
			self.portrait.anchor = v(137, 193)
			self.portrait.scale = v(0.9, 0.8344)
		end
		self.portrait_name:set_hero(hero_data.name, hero_data.name_i18n)

		self.portrait_over.colors.background = {
			255,
			255,
			255,
			255
		}

		timer.tween(0.2, self.portrait_over.colors, {
			background = {
				255,
				255,
				255,
				0
			}
		}, "out-quad")
	end

	local generation = screen_map.hero_data[index].generation
	local is_kr1_hero = generation == 1
	local is_kr6_hero = generation == 6
	local uses_intro_view = is_kr1_hero or is_kr6_hero

	if self.kr6_tree and self.kr6_tree.hero_index ~= index then
		self.kr6_tree:close()
	end

	if uses_intro_view then
		self.skills.hidden = true
		self.bio_view.hidden = false
		self.g1_text.hidden = is_kr6_hero
		self.skills_intro_text.hidden = is_kr6_hero
		self.kr6_tree_button.hidden = not is_kr6_hero

		if is_kr6_hero then
			local tree = hero_upgrades_6.data[hero_data.name]

			self.bio_text.text = tree and GU.balance_format(_(tree.description_key), balance) or ""
			self.skills.points.text = tostring(hero_data.remaining_points)
		else
			self.bio_text.text = _(string.upper(hero_data.name) .. "_BIO")
			self.g1_text.text = _("G1_HERO_NOUPGRADE_TEXT")
			self.skills_intro_text.text = _(string.upper(hero_data.name) .. "_SKILLS_INTRO")
		end

		local damage_icons = {
			default = "heroroom_attackIcons_0001",
			magic = "heroroom_attackIcons_0002",
			sword = "heroroom_attackIcons_0001",
			fireball = "heroroom_attackIcons_0004",
			arrow = "heroroom_attackIcons_0003",
			shot = "heroroom_attackIcons_0001",
			meleemagic = "heroroom_attackIcons_0002",
			electrical = "heroroom_attackIcons_0002",
			meleeelectrical = "heroroom_attackIcons_0002",
			explosion = "heroroom_attackIcons_0004",
			meleeexplosion = "heroroom_attackIcons_0004",
			meleetrue = "heroroom_attackIcons_0002",
			rangedtrue = "heroroom_attackIcons_0002"
		}

		self.bio_class_label.text = hero_data.hero_class
		self.bio_time.text = hero_data.attack_rate
		self.bio_armor.text = hero_data.armor
		self.bio_attack.text = hero_data.damage
		self.bio_health.text = hero_data.health
		self.bio_attack_icon:set_image(damage_icons[hero_data.damage_icon] or damage_icons.default)
		self.bio_level_num:set_image(string.format("heroroom_heroBadge_numbers_%04i", hero_data.level))
		self.bio_hero_bar.scale = v(hero_data.level_progress, 1)
		self.bio_hero_bar.hidden = false
		self.bio_hero_bar_end.hidden = hero_data.level_progress < 1
		self.bio_hero_bar_init.hidden = hero_data.level_progress == 0
	else
		self.skills.hidden = false
		self.bio_view.hidden = true
		self.kr6_tree_button.hidden = true
		self.skills:load_hero(index)
	end
	if self.infinite_panel then self:update_infinite_hero_panel() end
end

HeroToolTip = class("HeroToolTip", KLabel)

function HeroToolTip:initialize()
	self.rect_w = 300
	self.rect_h = 78
	self.tip_w = 15
	self.tip_h = 23

	local coin_pos_from_right = 51

	KLabel.initialize(self, V.v(self.rect_w, self.rect_h))

	self.anchor = v(self.rect_w / 2, 0)
	self.alpha = 0.9

	local name_label = GGLabel:new(V.v(self.rect_w - coin_pos_from_right - 10, 18))

	name_label.pos = v(15, 30)
	name_label.font_name = "body"
	name_label.font_size = 18
	name_label.colors.text = {
		255,
		255,
		255
	}
	name_label.text_align = "left"
	self.title = name_label

	self:add_child(name_label)

	local desc_label = GGLabel:new(V.v(self.rect_w - 30, 18))

	desc_label.pos = v(15, 55)
	desc_label.font_name = "body"
	desc_label.font_size = 18
	desc_label.colors.text = {
		245,
		203,
		6
	}
	desc_label.text_align = "left"
	desc_label.line_height = CJK(0.85, nil, 1, 0.9)
	self.desc = desc_label

	self:add_child(desc_label)

	self.bullet = KImageView:new("heroroom_tooltip_coin")
	self.bullet.pos = v(self.rect_w - coin_pos_from_right, 30)

	self:add_child(self.bullet)

	local price_label = GGLabel:new(V.v(50, 18))

	price_label.pos = v(self.rect_w - coin_pos_from_right + 20, 28)
	price_label.font_name = "Comic Book Italic"
	price_label.font_size = 18
	price_label.colors.text = {
		255,
		255,
		255
	}
	price_label.text = "2"
	price_label.text_align = "left"
	self.price = price_label

	self:add_child(price_label)

	self.hidden = true
end

function HeroToolTip:_draw_self()
	HeroToolTip.super._draw_self(self)

	local pr, pg, pb, pa = G.getColor()
	local current_alpha = pa / 255
	local new_c = {
		20,
		16,
		13,
		224 * current_alpha
	}

	G.setColor(new_c)
	G.rectangle("fill", 0, self.tip_h, self.size.x, self.size.y)
	G.polygon("fill", (self.rect_w - self.tip_w) / 2, self.tip_h, self.rect_w / 2, 0, (self.rect_w + self.tip_w) / 2, self.tip_h)
	G.setColor(pr, pg, pb, pa)
end

HeroSkills = class("HeroSkills", KImageView)

function HeroSkills:initialize()
	KImageView.initialize(self, "heroroom_003")

	local movel = 245
	local kr3_y_offset = IS_KR3 and 4 or 0
	local title_bg = KImageView:new("heroroom_006_notxt")

	title_bg.pos = v(V.csnap(self.size.x / 2 - 4, IS_KR3 and 6 or 2))
	title_bg.anchor = v(title_bg.size.x / 2, title_bg.size.y / 2)

	self:add_child(title_bg)

	local header = GGShaderLabel:new(V.v(130, 26))

	header.font_name = "h"
	header.font_size = 22
	header.text_align = "center"
	header.vertical_align = CJK("middle-caps", "middle", nil, "middle")
	header.colors.text = {
		250,
		250,
		250,
		255
	}
	header.shaders = {
		"p_bands",
		"p_glow"
	}
	header.shader_args = {
		{
			margin = 1,
			p1 = 0.42,
			p2 = 0.56,
			c1 = {
				0.9803921568627451,
				0.9803921568627451,
				0.9803921568627451,
				1
			},
			c2 = {
				0.9098039215686274,
				0.8745098039215686,
				0.6901960784313725,
				1
			},
			c3 = {
				0.6588235294117647,
				0.6274509803921569,
				0.4588235294117647,
				1
			}
		},
		{
			thickness = 1.6,
			glow_color = {
				0,
				0,
				0,
				0.85
			}
		}
	}

	header.text = _("Skills")

	header.fit_lines = 1
	header.pos = v(23, ISW(9, "zh-Hans", 8))

	title_bg:add_child(header)

	local stat_panel = KImageView:new("heroroom_004")

	stat_panel.pos = v(V.csnap(8 - movel, self.size.y / 2 + 30))
	stat_panel.anchor = v(stat_panel.size.x, stat_panel.size.y / 2)

	self:add_child(stat_panel)

	local stat_bullets = KImageView:new("heroroom_007")

	stat_bullets.pos = v(V.csnap(stat_panel.size.x / 2, stat_panel.size.y / 2 - 2))
	stat_bullets.anchor = v(stat_bullets.size.x / 2, stat_bullets.size.y / 2)

	stat_panel:add_child(stat_bullets)

	self.reset_button = GGButton:new("heroroom_btnReset_large_0001", "heroroom_btnReset_large_0002")
	self.reset_button.anchor = v(0, 0)
	self.reset_button.pos = v(310, 9 + kr3_y_offset)
	self.reset_button.on_down_scale = nil
	self.reset_button.label.size = v(80, 26)
	self.reset_button.label.text_size = self.reset_button.label.size
	self.reset_button.label.pos = v(19, 16)
	self.reset_button.label.font_size = 18
	self.reset_button.label.vertical_align = ISW("middle-caps", "zh-Hans", "top", "zh-Hant", "top", "ko", "middle")
	self.reset_button.label.text = _("BUTTON_RESET")
	self.reset_button.label.fit_lines = 1

	self:add_child(self.reset_button)
	self.reset_button:disable()

	function self.reset_button.on_click()
		S:queue("GUIButtonCommon")

		local selected_hero = screen_map.hero_data[screen_map.hero_room.over_index].name

		for v, i in pairs(screen_map.user_data.heroes.status[selected_hero].skills) do
			screen_map.user_data.heroes.status[selected_hero].skills[v] = 0
		end

		storage:save_slot(screen_map.user_data)
		screen_map.hero_room:construct_hero(screen_map.hero_room.selected_index)
		self.reset_button:disable()
	end

	local points_back = KImageView:new("heroroom_013")

	points_back.pos = v(25, 19 + kr3_y_offset)

	self:add_child(points_back)

	local points_icon = KImageView:new("heroroom_012")

	points_icon.pos = v(50, 36 + kr3_y_offset)
	points_icon.anchor = v(points_icon.size.x / 2, points_icon.size.y / 2)

	self:add_child(points_icon)

	local point_label = KLabel:new(V.v(50, 50))

	point_label.pos = v(55, 20 + kr3_y_offset)
	point_label.font = F:f("Comic Book Italic", "24")
	point_label.text_align = "center"
	point_label.colors.text = {
		231,
		222,
		175
	}
	point_label.text = "1"
	self.points = point_label

	self:add_child(point_label)

	local ay = -5
	local dx = 82

	self.bars = {}

	for i = 0, 4 do
		local is_ulti = i == 4 and IS_KR3
		local bg = KImageView:new("heroroom_009")

		bg.pos = v(82 * i + 25, 73 + ay)
		bg.level = 0

		self:add_child(bg)

		self.bars[i] = bg

		if is_ulti then
			local ulti_frame = KImageView("heroroom_009_ulti")

			ulti_frame.pos = V.v(-5, 0)

			bg:add_child(ulti_frame)
		end

		bg.plus_pos = {
			[0] = v(bg.size.x / 2, 74 + ay - 0),
			v(bg.size.x / 2, 74 + ay - 28),
			(v(bg.size.x / 2, 74 + ay - 56))
		}
		bg.plus = KImageButton:new("heroroom_018")

		bg:add_child(bg.plus)

		bg.plus.anchor = v(bg.plus.size.x / 2 - 1, 1)
		bg.plus.pos = bg.plus_pos[0]
		bg.plus.hidden = true

		function bg.plus.on_click()
			if self.no_buy then
				return
			end

			S:queue("GUIBuyUpgrade")

			local new_level = bg.level + 1
			local user_data = screen_map.user_data
			local hero_data = get_hero_stats(self.index)
			local sk_name = hero_data.skill_names[i + 1]

			-- changed
			if not sk_name then
				return
			end

			user_data.heroes.status[hero_data.name].skills[sk_name] = bg.level + 1

			storage:save_slot(user_data)
			screen_map.hero_room:construct_hero(self.index)
			self:show_tooltip(i)
		end

		bg.over = KView:new(V.v(46, 30))

		bg:add_child(bg.over)

		bg.over.anchor = v(bg.over.size.x / 2, 0)
		bg.over.pos = bg.plus_pos[0]
		bg.over.propagate_on_click = true
		bg.over.propagate_on_down = true
		bg.over.propagate_on_up = true

		function bg.over.on_enter()
			bg.plus.hidden = false
		end

		function bg.over.on_exit()
			bg.plus.hidden = true
		end

		bg.bullets = {}

		for o = 0, 2 do
			local b = KImageView:new("heroroom_010")

			b.anchor = v(b.size.x / 2, 0)
			b.pos = bg.plus_pos[o]

			bg:add_child(b)

			b.hidden = true
			bg.bullets[o] = b
		end

		bg.icon = KImageView:new("heroroom_upgradeIcons0001")
		bg.icon.anchor = v(bg.icon.size.x / 2, bg.icon.size.y / 2)
		bg.icon.pos = v(bg.size.x / 2, 137)

		bg:add_child(bg.icon)

		function bg.icon.on_enter()
			self:show_tooltip(i)

			bg.icon_over.hidden = false
		end

		function bg.icon.on_exit()
			self:hide_tooltip()

			bg.icon_over.hidden = true
		end

		function bg.icon.on_click()
			if bg.level < 3 and not bg.over.hidden then
				bg.plus:on_click()
			end
		end

		bg.icon_over = KImageView:new(IS_KR3 and "heroroom_upgradeIcons0081" or "heroroom_015")
		bg.icon_over.anchor = v(bg.icon_over.size.x / 2, bg.icon_over.size.y / 2)
		bg.icon_over.pos = V.vclone(bg.icon.pos)
		bg.icon_over.hidden = true

		bg:add_child(bg.icon_over)

		bg.cost_panel = KImageView:new("heroroom_011")
		bg.cost_panel.anchor = v(bg.cost_panel.size.x / 2, bg.cost_panel.size.y / 2)
		bg.cost_panel.pos = v(bg.size.x / 2, bg.icon.pos.y + bg.icon.size.y / 2)

		bg:add_child(bg.cost_panel)

		local cost_label = KLabel:new(V.v(20, 20))

		cost_label.pos = v(33, 6)
		cost_label.font = F:f("Comic Book Italic", "14")
		cost_label.colors.text = {
			231,
			222,
			175
		}
		cost_label.text = "2"
		cost_label.text_align = "center"
		bg.cost = cost_label

		bg.cost_panel:add_child(cost_label)
	end

	local hero_badge_contain = KImageView:new("heroroom_017")

	hero_badge_contain.anchor = v(hero_badge_contain.size.x, hero_badge_contain.size.y / 2)
	hero_badge_contain.pos = v(-5 - movel, 60)

	self:add_child(hero_badge_contain)

	do
		local y_o, y_d = 6, 34
		local x, y = 31, y_o
		local health_label = GGLabel:new(V.v(80, 17))

		health_label.pos = v(x, y)
		health_label.colors.text = {
			255,
			255,
			255
		}
		health_label.text = "200"
		health_label.text_align = "left"
		health_label.font_name = "Comic Book Italic"
		health_label.font_size = 16
		health_label.vertical_align = "middle"
		health_label.fit_lines = 1
		self.health = health_label

		stat_bullets:add_child(health_label)

		y = y + y_d

		local armor_label = GGLabel:new(V.v(80, 17))

		armor_label.pos = v(x, y)
		armor_label.colors.text = {
			255,
			255,
			255
		}
		armor_label.text = "200"
		armor_label.text_align = "left"
		armor_label.font_name = CJK("body", nil, nil, "h_noti")
		armor_label.font_size = 16
		armor_label.text_offset.y = -2
		armor_label.vertical_align = "middle"
		armor_label.fit_lines = 1
		self.armor = armor_label

		stat_bullets:add_child(armor_label)

		y = y + y_d

		local damage_label = GGLabel:new(V.v(80, 17))

		damage_label.pos = v(x, y)
		damage_label.colors.text = {
			255,
			255,
			255
		}
		damage_label.text = "100"
		damage_label.text_align = "left"
		damage_label.font_name = "Comic Book Italic"
		damage_label.font_size = 16
		damage_label.vertical_align = "middle"
		damage_label.fit_lines = 1
		self.attack = damage_label

		stat_bullets:add_child(damage_label)

		self.attack_icon = KImageView:new("heroroom_attackIcons_0001")
		self.attack_icon.pos = v(x - 29, y - 8)

		stat_bullets:add_child(self.attack_icon)

		y = y + y_d

		local time_label = GGLabel:new(V.v(80, 17))

		time_label.pos = v(x, y)
		time_label.colors.text = {
			255,
			255,
			255
		}
		time_label.text = "200"
		time_label.text_align = "left"
		time_label.font_name = CJK("body", nil, nil, "h_noti")
		time_label.font_size = 16
		time_label.text_offset.y = -1
		time_label.vertical_align = "middle"
		time_label.fit_lines = 1
		self.time = time_label

		stat_bullets:add_child(time_label)
	end

	local hero_badge = KImageView:new("heroroom_heroBadge_notxt_0002")

	hero_badge.anchor = v(hero_badge.size.x, hero_badge.size.y / 2)
	hero_badge.pos = v(-5 - movel, 40)
	self.hero_badge = hero_badge

	self:add_child(hero_badge)

	self.level_num = KImageView:new("heroroom_heroBadge_numbers_0001")
	self.level_num.pos = v(-75 - movel, 40)
	self.level_num.scale = v(0.5, 0.5)
	self.level_num.anchor = v(self.level_num.size.x / 2, self.level_num.size.y / 2)

	self:add_child(self.level_num)

	self.hero_bar = KImageView:new("hero_bar_middle")
	self.hero_bar.pos = v(-105 - movel, 60)
	self.hero_bar.anchor = v(0, self.hero_bar.size.y / 2)
	self.hero_bar.scale = v(0.5, 1)

	self:add_child(self.hero_bar)

	self.hero_bar_init = KImageView:new("hero_bar_init")
	self.hero_bar_init.anchor = v(self.hero_bar_init.size.x, self.hero_bar_init.size.y / 2)
	self.hero_bar_init.pos = v(-104 - movel, 60)

	self:add_child(self.hero_bar_init)

	self.hero_bar_end = KImageView:new("hero_bar_end")
	self.hero_bar_end.anchor = v(self.hero_bar_end.size.x, self.hero_bar_end.size.y / 2)
	self.hero_bar_end.pos = v(-105 - movel + 58, 60)

	self:add_child(self.hero_bar_end)

	local class_label = GGLabel:new(V.v(104, 14))

	class_label.pos = v(-155 - movel + 24, ISW(71, "zh-Hans", 66, "zh-Hant", 69, "ko", 69))
	class_label.font_name = CJK("body", nil, nil, "sans_bold")
	class_label.font_size = 14
	class_label.colors.text = {
		0,
		0,
		0
	}
	class_label.text = "class"
	class_label.text_align = "center"
	class_label.vertical_align = ISW("middle-caps", "zh-Hans", "top", "zh-Hant", "top")
	class_label.fit_lines = 1
	self.class_label = class_label

	self:add_child(class_label)
end

function HeroSkills:enable()
	UpgradesView.super.enable(self)

	if self.disable_reset then
		self.reset_button:disable()
	end
end

function HeroSkills:set_panel_height(title, desc, price, format_balance)
	self.tip_panel.price.text = price
	self.tip_panel.desc.text = GU.balance_format(desc, format_balance or balance)
	self.tip_panel.title.text = title

	local title_label = self.tip_panel.title
	local desc_label = self.tip_panel.desc
	local _, title_lines = title_label:get_wrap_lines()
	local title_height = math.ceil(title_label:get_font_height() * (1 + (math.max(1, title_lines) - 1) * title_label.line_height))

	title_label.size.y = title_height
	title_label.text_size.y = title_height
	desc_label.pos.y = title_label.pos.y + title_height + 5

	local _, desc_lines = desc_label:get_wrap_lines()
	local desc_height = math.ceil(desc_label:get_font_height() * (1 + (math.max(1, desc_lines) - 1) * desc_label.line_height))

	desc_label.size.y = desc_height
	desc_label.text_size.y = desc_height
	self.tip_panel.size.y = desc_label.pos.y + desc_height + 12
	self.tip_panel.hidden = false
end

function HeroSkills:show_tooltip(i)
	local hero_data = get_hero_stats(self.index)
	local sk_key = hero_data.skill_names_i18n[i + 1] or hero_data.skill_names[i + 1]
	local sk_name = hero_data.skill_names[i + 1]
	local sk = hero_data.skills[sk_name]

	-- changed
	if not sk then
		return
	end

	if sk.level == 3 then
		self.tip_panel.price.hidden = true
		self.tip_panel.bullet.hidden = true

		if self.tip_panel.star then
			self.tip_panel.star.hidden = true
		end
	else
		self.tip_panel.price.hidden = false
		self.tip_panel.bullet.hidden = false

		if self.tip_panel.star then
			self.tip_panel.star.hidden = false
		end
	end

	self:set_panel_height(_(string.format("%s_%s_TITLE", string.upper(hero_data.name_i18n), string.upper(sk_key))), _(string.format("%s_%s_DESCRIPTION_%s", string.upper(hero_data.name_i18n), string.upper(sk_key), tostring(km.clamp(1, 3, sk.level)))), sk.hr_cost[sk.level + 1])

	self.tip_panel.hidden = false

	self:update_tooltip_position()
end

function HeroSkills:hide_tooltip()
	self.tip_panel.hidden = true
end

function HeroSkills:update_tooltip_position()
	if not self.tip_panel.hidden then
		local mx, my = screen_map.window:get_mouse_position()

		my = my + 30
		self.tip_panel.pos = v(mx / screen_map.window.scale.x, my / screen_map.window.scale.y)
		if self.tip_panel.volibear_popup then
			local tip=self.tip_panel;local bounds=tip.parent.size
			tip.pos.x=km.clamp(tip.rect_w/2+8,bounds.x-tip.rect_w/2-8,tip.pos.x)
			tip.pos.y=km.clamp(8,math.max(8,bounds.y-tip.size.y-tip.tip_h-8),tip.pos.y)
		end
	end
end

function HeroSkills:update(dt)
	HeroSkills.super.update(self, dt)
	self:update_tooltip_position()
end

function HeroSkills:load_hero(index)
	local damage_icons = {
		default = "heroroom_attackIcons_0001",
		magic = "heroroom_attackIcons_0002",
		sword = "heroroom_attackIcons_0001",
		fireball = "heroroom_attackIcons_0004",
		arrow = "heroroom_attackIcons_0003",
		shot = "heroroom_attackIcons_0001",
		meleemagic = "heroroom_attackIcons_0002",
		electrical = "heroroom_attackIcons_0002",
		meleeelectrical = "heroroom_attackIcons_0002",
		explosion = "heroroom_attackIcons_0004",
		meleeexplosion = "heroroom_attackIcons_0004",
		meleetrue = "heroroom_attackIcons_0002",
		rangedtrue = "heroroom_attackIcons_0002",			
	}
	local hero_data = get_hero_stats(index)

	self.hero_data = hero_data
	self.class_label.text = hero_data.hero_class
	self.time.text = hero_data.attack_rate
	self.armor.text = hero_data.armor
	self.attack.text = hero_data.damage
	self.health.text = hero_data.health

	self.attack_icon:set_image(damage_icons[hero_data.damage_icon] or damage_icons.default)
	self.level_num:set_image(string.format("heroroom_heroBadge_numbers_%04i", hero_data.level))

	self.index = hero_data.index

	local hero_level = hero_data.level

	log.paranoid("hero:%s  xp:%s  level:%s  perc:%s", hero_data.name, hero_data.xp, hero_level, percentaje_lvl)

	self.hero_bar.scale = v(hero_data.level_progress, 1)
	self.hero_bar.hidden = false
	self.hero_bar_end.hidden = hero_data.level_progress < 1
	self.hero_bar_init.hidden = hero_data.level_progress == 0

	local disable_reset = true

	for i = 0, 4 do
		self.bars[i].cost_panel.hidden = false

		local sk_name = hero_data.skill_names[i + 1]
		local sk = hero_data.skills[sk_name]

		-- changed
		if not sk then
			break
		end
		if index <= 47 then
            self.bars[i].icon.scale = v(1, 1)
			if self.no_buy or sk.level < 3 and sk.hr_cost[sk.level + 1] > hero_data.remaining_points then
				self.bars[i].icon:set_image("heroroom_upgradeIcons0" .. string.format("%03i", sk.hr_icon) .. "_disabled")
				self.bars[i].cost_panel:set_image("heroroom_011_disabled")
			else
				self.bars[i].icon:set_image("heroroom_upgradeIcons0" .. string.format("%03i", sk.hr_icon))
				self.bars[i].cost_panel:set_image("heroroom_011")
			end
		else--5代英雄没有disabled
			self.bars[i].icon.scale = v(0.8, 0.8)
			if self.no_buy or sk.level < 3 and sk.hr_cost[sk.level + 1] > hero_data.remaining_points then
				self.bars[i].icon:set_image("hero_room_skill_icons_"..hero_data.name..string.format("_%04i", i+1))
				self.bars[i].cost_panel:set_image("heroroom_011_disabled")
				--hero_room_skill_icons_hero_vesper_0001
			else
				self.bars[i].icon:set_image("hero_room_skill_icons_"..hero_data.name..string.format("_%04i", i+1))
				self.bars[i].cost_panel:set_image("heroroom_011")
			end
		end

		self.bars[i].cost.text = tostring(sk.hr_cost[sk.level + 1])
		self.bars[i].skill_name = sk_name
		self.bars[i].level = sk.level

		for d = 0, 2 do
			if d < sk.level then
				self.bars[i].bullets[d].hidden = false

				self.reset_button:enable()

				disable_reset = false
			else
				self.bars[i].bullets[d].hidden = true
			end
		end

		if sk.level < 3 and hero_data.remaining_points >= sk.hr_cost[sk.level + 1] then
			local bar = self.bars[i]

			bar.over.pos = bar.plus_pos[sk.level]
			bar.plus.pos = bar.plus_pos[sk.level]
			bar.over.hidden = false
		else
			self.bars[i].over.hidden = true

			if self.bars[i].level == 3 then
				self.bars[i].cost_panel.hidden = true
			end
		end
	end

	self.disable_reset = disable_reset
	self.points.text = hero_data.remaining_points

	local selected_hero = screen_map.user_data.heroes.selected

	if screen_map.hero_room and screen_map.hero_room.real_selected == screen_map.hero_room.over_index and selected_hero == hero_data.name then
		screen_map.skill_label.text = self.points.text

		if hero_data.remaining_points == 0 then
			screen_map.skill_star.hidden = true
		else
			screen_map.skill_star.hidden = false
		end
	end
end

local function use_bold_settings_button_font(button)
	button.label.font_name = "sans_bold"
	button.label.canvases_drawn = nil

	return button
end

local function prepare_max_level_heroes(user_data)
	local updated = table.deepclone(user_data)
	local default_statuses = require("data.slot_template").heroes.status
	local max_xp = GS.hero_xp_thresholds[#GS.hero_xp_thresholds]
	local hero_level = #GS.skill_points_for_hero_level

	fill_missing_hero_statuses(updated)

	for hero_name, status in pairs(updated.heroes.status) do
		status.xp = math.max(tonumber(status.xp) or 0, max_xp)
		status.skills = status.skills or {}

		local defaults = default_statuses[hero_name]

		if defaults then
			for skill_name in pairs(defaults.skills) do
				status.skills[skill_name] = 3
			end
		end

		for skill_name in pairs(status.skills) do
			status.skills[skill_name] = 3
		end
	end

	for _, hero_name in ipairs(hero_upgrades_6.hero_names) do
		hero_upgrades_6.reset(updated, hero_name)

		for _, node_id in ipairs(hero_upgrades_6.node_order) do
			if node_id ~= "talent_2" and not hero_upgrades_6.buy(updated, hero_name, node_id, hero_level, GS.skill_points_for_hero_level) then
				log.error("could not max sixth-generation hero skill %s.%s", hero_name, node_id)
				return nil
			end
		end
	end

	return updated
end

DeveloperModeView = class("DeveloperModeView", PopUpView)

function DeveloperModeView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))

	self.back = KImageView:new("options_bg_notxt")
	self.pos = v(0, 0)
	self.back.anchor = v(self.back.size.x / 2, self.back.size.y / 2)
	self.back.pos = v(sw / 2, sh / 2 - 50)
	self.back.alpha = 1
	self:add_child(self.back)

	local header = GGPanelHeader:new("Công cụ phát triển", 242)

	header.pos = V.v(240, CJK(41, 39, nil, 39) - (IS_KR3 and 19 or 0))
	self.back:add_child(header)

	local wave_editor_button = GGOptionsButton:new("Sửa đợt quái")

	use_bold_settings_button_font(wave_editor_button)
	wave_editor_button.anchor.x = wave_editor_button.size.x / 2
	wave_editor_button.pos = V.v(self.back.size.x / 2 - 125, 175)

	function wave_editor_button.on_click()
		S:queue("GUIButtonCommon")
		screen_map.wave_editor.return_view = self
		self:hide()
		screen_map.wave_editor:show()
	end

	self.wave_editor_button = wave_editor_button
	self.back:add_child(wave_editor_button)

	local map_editor_button = GGOptionsButton:new("Sửa bản đồ")

	use_bold_settings_button_font(map_editor_button)
	map_editor_button.anchor.x = map_editor_button.size.x / 2
	map_editor_button.pos = V.v(self.back.size.x / 2 + 125, 175)

	function map_editor_button.on_click()
		S:queue("GUIButtonCommon")
		if IS_ANDROID then
			self.mobile_map_editor_notice.hidden = false
			self.mobile_map_editor_notice:order_to_front()
			return
		end

		local generation = screen_map.kr1_map and 1 or screen_map.kr2_map and 2 or screen_map.kr4_map and 4 or screen_map.kr5_map and 5 or screen_map.kr6_map and 6 or 3
		local level_idx = map_data.level_rank(1, generation) or 1

		screen_map.done_callback({
			next_item_name = "game_editor",
			custom = level_idx
		})
	end

	self.map_editor_button = map_editor_button
	self.back:add_child(map_editor_button)

	local fullscreen_tower_build = GGOptionsButton:new("Xây mọi nơi: tắt")

	use_bold_settings_button_font(fullscreen_tower_build)
	fullscreen_tower_build.anchor.x = fullscreen_tower_build.size.x / 2
	fullscreen_tower_build.pos = V.v(self.back.size.x / 2 - 125, 290)

	function fullscreen_tower_build.on_click(this)
		S:queue("GUIButtonCommon")
		screen_map.user_data.liuhui = screen_map.user_data.liuhui or {}
		screen_map.user_data.liuhui.fullscreen_tower_build = not screen_map.user_data.liuhui.fullscreen_tower_build

		if screen_map.user_data.liuhui.fullscreen_tower_build then
			screen_map.user_data.liuhui.rand_tower = 0
		end

		this.label.text = screen_map.user_data.liuhui.fullscreen_tower_build and "Xây mọi nơi: bật" or "Xây mọi nơi: tắt"
		storage:save_slot(screen_map.user_data)

		if screen_map.more_option_panel and screen_map.more_option_panel.update_selected then
			screen_map.more_option_panel:update_selected()
		end
	end

	self.fullscreen_tower_build = fullscreen_tower_build
	self.back:add_child(fullscreen_tower_build)

	local max_heroes_button = GGOptionsButton:new("Tối đa cấp anh hùng")

	use_bold_settings_button_font(max_heroes_button)
	max_heroes_button.anchor.x = max_heroes_button.size.x / 2
	max_heroes_button.pos = V.v(self.back.size.x / 2 + 125, 290)

	function max_heroes_button.on_click()
		S:queue("GUIButtonCommon")
		self.max_heroes_notice_text.text = "Nâng anh hùng lên cấp tối đa? Thao tác này không thể hoàn tác."
		self.max_heroes_notice.hidden = false
		self.max_heroes_notice:order_to_front()
	end

	self.max_heroes_button = max_heroes_button
	self.back:add_child(max_heroes_button)

	local back_button = GGOptionsButton:new("Quay lại")

	use_bold_settings_button_font(back_button)
	back_button.anchor.x = back_button.size.x / 2
	back_button.pos = V.v(self.back.size.x / 2, 430)

	function back_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
		screen_map.option_panel:show()
	end

	self.back_button = back_button
	self.back:add_child(back_button)

	local tutorial_hint = GGLabel:new(V.v(self.back.size.x - 60, 34))

	tutorial_hint.pos = V.v(30, 490)
	tutorial_hint.text = "Nếu chưa rõ cách dùng, hãy đọc hướng dẫn cho người mới."
	tutorial_hint.font_name = "body"
	tutorial_hint.font_size = 20
	tutorial_hint.text_align = "center"
	tutorial_hint.vertical_align = "middle"
	tutorial_hint.fit_lines = 1
	tutorial_hint.colors.text = {255, 232, 189, 255}
	tutorial_hint.propagate_on_up = true
	tutorial_hint.propagate_on_down = true
	tutorial_hint.propagate_on_click = true
	self.back:add_child(tutorial_hint)

	local mobile_notice = KView:new(V.v(sw, sh))

	mobile_notice.colors.background = {0, 0, 0, 185}
	mobile_notice.hidden = true

	local notice_back = KView:new(V.v(720, 280))

	notice_back.anchor = V.v(360, 140)
	notice_back.pos = V.v(sw / 2, sh / 2)
	notice_back.colors.background = {232, 219, 177, 255}
	mobile_notice:add_child(notice_back)

	local notice_title = GGLabel:new(V.v(720, 58))

	notice_title.text = "Thông báo"
	notice_title.font_name = "body"
	notice_title.font_size = 30
	notice_title.text_align = "center"
	notice_title.vertical_align = "middle"
	notice_title.colors.text = {255, 246, 218, 255}
	notice_title.colors.background = {48, 42, 31, 255}
	notice_back:add_child(notice_title)

	local notice_text = GGLabel:new(V.v(640, 90))

	notice_text.pos = V.v(40, 78)
	notice_text.text = "Màn hình điện thoại quá nhỏ. Hãy dùng máy tính để sửa bản đồ."
	notice_text.font_name = "body"
	notice_text.font_size = 24
	notice_text.text_align = "center"
	notice_text.vertical_align = "middle"
	notice_text.fit_lines = 2
	notice_text.colors.text = {52, 37, 21, 255}
	notice_back:add_child(notice_text)

	local notice_ok = GGOptionsButton:new("Đã hiểu")

	use_bold_settings_button_font(notice_ok)
	notice_ok.anchor.x = notice_ok.size.x / 2
	notice_ok.pos = V.v(360, 215)
	function notice_ok.on_click()
		S:queue("GUIButtonCommon")
		mobile_notice.hidden = true
	end
	notice_back:add_child(notice_ok)

	self.mobile_map_editor_notice = mobile_notice
	self:add_child(mobile_notice)

	local max_heroes_notice = KView:new(V.v(sw, sh))

	max_heroes_notice.colors.background = {0, 0, 0, 185}
	max_heroes_notice.hidden = true

	local confirm_back = KView:new(V.v(720, 280))

	confirm_back.anchor = V.v(360, 140)
	confirm_back.pos = V.v(sw / 2, sh / 2)
	confirm_back.colors.background = {232, 219, 177, 255}
	max_heroes_notice:add_child(confirm_back)

	local confirm_title = GGLabel:new(V.v(720, 58))

	confirm_title.text = "Thông báo"
	confirm_title.font_name = "body"
	confirm_title.font_size = 30
	confirm_title.text_align = "center"
	confirm_title.vertical_align = "middle"
	confirm_title.colors.text = {255, 246, 218, 255}
	confirm_title.colors.background = {48, 42, 31, 255}
	confirm_back:add_child(confirm_title)

	local confirm_text = GGLabel:new(V.v(640, 90))

	confirm_text.pos = V.v(40, 78)
	confirm_text.text = "Đưa anh hùng lên cấp tối đa? Thao tác này không thể hoàn tác."
	confirm_text.font_name = "body"
	confirm_text.font_size = 24
	confirm_text.text_align = "center"
	confirm_text.vertical_align = "middle"
	confirm_text.fit_lines = 2
	confirm_text.colors.text = {52, 37, 21, 255}
	confirm_back:add_child(confirm_text)

	local confirm_yes = GGOptionsButton:new("Có")

	use_bold_settings_button_font(confirm_yes)
	confirm_yes.anchor.x = confirm_yes.size.x / 2
	confirm_yes.pos = V.v(260, 215)

	function confirm_yes.on_click()
		S:queue("GUIButtonCommon")

		local user_data = screen_map.user_data
		local updated = prepare_max_level_heroes(user_data)

		if not updated then
			confirm_text.text = "Không thể nâng cấp anh hùng. Save chưa bị thay đổi."
			return
		end

		local previous_status = user_data.heroes.status
		local previous_upgrades = user_data.hero_upgrades_6

		user_data.heroes.status = updated.heroes.status
		user_data.hero_upgrades_6 = updated.hero_upgrades_6

		if not storage:save_slot(user_data) then
			user_data.heroes.status = previous_status
			user_data.hero_upgrades_6 = previous_upgrades
			confirm_text.text = "Không thể ghi save. Anh hùng chưa bị thay đổi."
			return
		end

		max_heroes_notice.hidden = true
	end

	confirm_back:add_child(confirm_yes)

	local confirm_no = GGOptionsButton:new("Không")

	use_bold_settings_button_font(confirm_no)
	confirm_no.anchor.x = confirm_no.size.x / 2
	confirm_no.pos = V.v(460, 215)

	function confirm_no.on_click()
		S:queue("GUIButtonCommon")
		max_heroes_notice.hidden = true
	end

	confirm_back:add_child(confirm_no)

	self.max_heroes_notice = max_heroes_notice
	self.max_heroes_notice_text = confirm_text
	self:add_child(max_heroes_notice)
end

function DeveloperModeView:show()
	DeveloperModeView.super.show(self)
	screen_map.user_data.liuhui = screen_map.user_data.liuhui or {}
	self.fullscreen_tower_build.label.text = screen_map.user_data.liuhui.fullscreen_tower_build and "Xây mọi nơi: bật" or "Xây mọi nơi: tắt"
	self.mobile_map_editor_notice.hidden = true
	self.max_heroes_notice.hidden = true
end

local MOBILE_UI_SCALES = {1, 1.1, 1.2, 1.3, 1.4}

local function valid_mobile_ui_scale(value)
	value = tonumber(value) or 1

	for _, scale in ipairs(MOBILE_UI_SCALES) do
		if math.abs(value - scale) < 0.001 then
			return scale
		end
	end

	return 1
end

local function next_mobile_ui_scale(value)
	value = valid_mobile_ui_scale(value)

	for i, scale in ipairs(MOBILE_UI_SCALES) do
		if scale == value then
			return MOBILE_UI_SCALES[i % #MOBILE_UI_SCALES + 1]
		end
	end

	return 1
end

MobileSettingsView = class("MobileSettingsView", PopUpView)

function MobileSettingsView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))

	self.back = KImageView:new("options_bg_notxt")
	self.pos = v(0, 0)
	self.back.anchor = v(self.back.size.x / 2, self.back.size.y / 2)
	self.back.pos = v(sw / 2, sh / 2 - 50)
	self.back.alpha = 1
	self:add_child(self.back)

	local header = GGPanelHeader:new("Cài đặt di động", 242)

	header.pos = V.v(240, CJK(41, 39, nil, 39) - (IS_KR3 and 19 or 0))
	self.back:add_child(header)

	local font_scale_button = GGOptionsButton:new("Cỡ chữ: 1.0×")

	use_bold_settings_button_font(font_scale_button)
	font_scale_button.anchor.x = font_scale_button.size.x / 2
	font_scale_button.pos = V.v(self.back.size.x / 2, 145)

	function font_scale_button.on_click(this)
		local new_scale = this.pending_scale == 1.2 and 1 or 1.2
		local settings = storage:load_settings()

		this.pending_scale = new_scale
		settings.mobile_font_scale = new_scale
		storage:save_settings(settings, true)
		this.label.text = string.format("Cỡ chữ: %.1f lần", new_scale)
		S:queue("GUIButtonCommon")
	end

	self.font_scale_button = font_scale_button
	self.back:add_child(font_scale_button)

	local ui_scale_button = GGOptionsButton:new("Cỡ UI: 1.0×")

	use_bold_settings_button_font(ui_scale_button)
	ui_scale_button.anchor.x = ui_scale_button.size.x / 2
	ui_scale_button.pos = V.v(self.back.size.x / 2, 230)

	function ui_scale_button.on_click(this)
		local new_scale = next_mobile_ui_scale(this.pending_scale)
		local settings = storage:load_settings()

		this.pending_scale = new_scale
		settings.mobile_ui_scale = new_scale
		storage:save_settings(settings, true)
		this.label.text = string.format("Cỡ giao diện: %.1f lần", new_scale)
		S:queue("GUIButtonCommon")
	end

	self.ui_scale_button = ui_scale_button
	self.back:add_child(ui_scale_button)

	local widescreen_button = GGOptionsButton:new("Màn hình rộng: bật")

	use_bold_settings_button_font(widescreen_button)
	widescreen_button.anchor.x = widescreen_button.size.x / 2
	widescreen_button.pos = V.v(self.back.size.x / 2, 315)

	function widescreen_button.on_click(this)
		this.pending_enabled = not this.pending_enabled

		local settings = storage:load_settings()

		settings.mobile_widescreen = this.pending_enabled
		storage:save_settings(settings, true)
		this.label.text = this.pending_enabled and "Màn hình rộng: bật" or "Màn hình rộng: tắt"
		S:queue("GUIButtonCommon")
	end

	self.widescreen_button = widescreen_button
	self.back:add_child(widescreen_button)

	local restart_note = GGLabel:new(V.v(self.back.size.x - 60, 34))

	restart_note.pos = V.v(30, 385)
	restart_note.text = "Một số cài đặt cần khởi động lại để có hiệu lực."
	restart_note.font_name = "body"
	restart_note.font_size = 20
	restart_note.text_align = "center"
	restart_note.vertical_align = "middle"
	restart_note.fit_lines = 1
	restart_note.colors.text = {255, 232, 189, 255}
	restart_note.propagate_on_up = true
	restart_note.propagate_on_down = true
	restart_note.propagate_on_click = true
	self.restart_note = restart_note
	self.back:add_child(restart_note)

	local back_button = GGOptionsButton:new("Quay lại")

	use_bold_settings_button_font(back_button)
	back_button.anchor.x = back_button.size.x / 2
	back_button.pos = V.v(self.back.size.x / 2, 450)

	function back_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
		screen_map.option_panel:show()
	end

	self.back_button = back_button
	self.back:add_child(back_button)
end

function MobileSettingsView:show()
	MobileSettingsView.super.show(self)

	local settings = storage:load_settings()
	local font_scale = tonumber(settings.mobile_font_scale) == 1.2 and 1.2 or 1
	local ui_scale = valid_mobile_ui_scale(settings.mobile_ui_scale)
	local widescreen_enabled = settings.mobile_widescreen ~= false

	self.font_scale_button.pending_scale = font_scale
	self.font_scale_button.label.text = string.format("Cỡ chữ: %.1f×", font_scale)
	self.ui_scale_button.pending_scale = ui_scale
	self.ui_scale_button.label.text = string.format("Cỡ UI: %.1f×", ui_scale)
	self.widescreen_button.pending_enabled = widescreen_enabled
	self.widescreen_button.label.text = widescreen_enabled and "Màn hình rộng: bật" or "Màn hình rộng: tắt"
	self.widescreen_button.hidden = not screen_map.android_device_is_widescreen
end

ShortcutSettingsView = class("ShortcutSettingsView", PopUpView)

function ShortcutSettingsView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))

	self.back = KImageView:new("options_bg_notxt")
	self.back.anchor = V.v(self.back.size.x / 2, self.back.size.y / 2)
	self.back.pos = V.v(sw / 2, sh / 2 - 50)
	self.back.alpha = 1
	self:add_child(self.back)

	local header = GGPanelHeader:new("Cài đặt phím tắt", 242)

	header.pos = V.v(240, CJK(41, 39, nil, 39) - (IS_KR3 and 19 or 0))
	self.back:add_child(header)

	self.bindings = {
		map = shortcut_settings.load_context("map"),
		game = shortcut_settings.load_context("game")
	}
	self.binding_buttons = {map = {}, game = {}}
	self.context = "map"

	local map_tab = GGOptionsButton:new("Bản đồ")

	use_bold_settings_button_font(map_tab)
	map_tab.anchor = V.v(map_tab.size.x / 2, map_tab.size.y / 2)
	map_tab.pos = V.v(150, 94)
	map_tab.scale = V.v(0.62, 0.62)
	map_tab.label.fit_lines = 1
	self.back:add_child(map_tab)

	local game_tab = GGOptionsButton:new("Trong trận")

	use_bold_settings_button_font(game_tab)
	game_tab.anchor = V.v(game_tab.size.x / 2, game_tab.size.y / 2)
	game_tab.pos = V.v(self.back.size.x - 150, 94)
	game_tab.scale = V.v(0.62, 0.62)
	game_tab.label.fit_lines = 1
	self.back:add_child(game_tab)

	self.map_tab = map_tab
	self.game_tab = game_tab

	local input_note = GGLabel:new(V.v(self.back.size.x - 44, 20))

	input_note.pos = V.v(22, 394)
	input_note.font_name = "body"
	input_note.font_size = 15
	input_note.text = "Một số phím chỉ hoạt động khi tắt bộ gõ tiếng Trung."
	input_note.text_align = "center"
	input_note.vertical_align = "middle"
	input_note.fit_lines = 1
	input_note.colors.text = {219, 183, 103, 255}
	input_note.propagate_on_click = true
	input_note.propagate_on_down = true
	input_note.propagate_on_up = true
	self.back:add_child(input_note)

	local status_label = GGLabel:new(V.v(self.back.size.x - 44, 21))

	status_label.pos = V.v(22, 414)
	status_label.font_name = "body"
	status_label.font_size = 16
	status_label.text_align = "center"
	status_label.vertical_align = "middle"
	status_label.fit_lines = 1
	status_label.colors.text = {255, 222, 147, 255}
	status_label.propagate_on_click = true
	status_label.propagate_on_down = true
	status_label.propagate_on_up = true
	self.status_label = status_label
	self.back:add_child(status_label)

	local function add_binding_button(list, row, context, definition, slot_index, x)
		local button = GGOptionsButton:new(shortcut_settings.display_key(self.bindings[context][definition.id][slot_index]))

		use_bold_settings_button_font(button)
		button.anchor = V.v(button.size.x / 2, button.size.y / 2)
		button.pos = V.v(x, row.size.y / 2)
		button.scale = V.v(0.53, 0.53)
		button.label.fit_lines = 1
		button.shortcut_binding_button = true
		button.shortcut_context = context
		button.shortcut_action = definition.id
		button.shortcut_slot = slot_index
		button.value = self.bindings[context][definition.id][slot_index]

		function button.on_click(this)
			S:queue("GUIButtonCommon")
			self:cancel_capture()
			self.capture_button = this
			this.label.text = "Nhấn một phím"
			self.status_label.text = ""
			screen_map.window:set_responder(this)
		end

		function button.on_keypressed(this, key)
			local ok, result, conflict_label = shortcut_settings.set_binding(
				self.bindings[this.shortcut_context],
				this.shortcut_context,
				this.shortcut_action,
				this.shortcut_slot,
				key)

			if ok then
				self.bindings[this.shortcut_context] = shortcut_settings.save_context(
					this.shortcut_context,
					self.bindings[this.shortcut_context])
				this.value = self.bindings[this.shortcut_context][this.shortcut_action][this.shortcut_slot]
				self.status_label.text = "Đã lưu: " .. shortcut_settings.display_key(this.value)

				if this.shortcut_context == "map" then
					screen_map.map_shortcuts = self.bindings.map
				end
			elseif result == "reserved" then
				self.status_label.text = "Esc và F1-F8 là phím cố định, không thể đổi."
			elseif result == "conflict" then
				self.status_label.text = "Phím này đã dùng cho: " .. tostring(conflict_label)
			else
				self.status_label.text = "Không thể dùng phím này."
			end

			this.label.text = shortcut_settings.display_key(this.value)
			screen_map.window:set_responder()
			self.capture_button = nil

			return true
		end

		row:add_child(button)
		table.insert(self.binding_buttons[context], button)
	end

	local function build_list(context)
		local list = KScrollList:new(V.v(self.back.size.x - 40, 273))

		list.pos = V.v(20, 120)
		list.scroll_amount = 34
		list.scroll_acceleration = 1.5
		list:set_scroller_size(10, 3)
		list.colors.background = {37, 31, 24, 145}
		list.colors.scroller_background = {73, 61, 43, 210}
		list.colors.scroller_foreground = {207, 174, 99, 255}

		for row_index, definition in ipairs(shortcut_settings.get_definitions(context)) do
			local row = KView:new(V.v(list.size.x - 16, 50))

			if row_index % 2 == 0 then
				row.colors.background = {255, 242, 196, 18}
			end

			local action_label = GGLabel:new(V.v(178, row.size.y))

			action_label.pos = V.v(8, 0)
			action_label.text = definition.label
			action_label.font_name = "body"
			action_label.font_size = 18
			action_label.text_align = "left"
			action_label.vertical_align = "middle"
			action_label.fit_lines = 1
			action_label.colors.text = {255, 235, 193, 255}
			action_label.propagate_on_click = true
			action_label.propagate_on_down = true
			action_label.propagate_on_up = true
			row:add_child(action_label)

			local editable_slots = {}
			local fixed_labels = {}

			for slot_index, slot in ipairs(definition.slots) do
				if slot.fixed then
					table.insert(fixed_labels, "Mặc định" .. shortcut_settings.display_key(slot.key))
				else
					table.insert(editable_slots, slot_index)
				end
			end

			if #editable_slots == 2 then
				add_binding_button(list, row, context, definition, editable_slots[1], 250)
				add_binding_button(list, row, context, definition, editable_slots[2], 350)
			elseif #editable_slots == 1 then
				add_binding_button(list, row, context, definition, editable_slots[1], #fixed_labels > 0 and 260 or 325)
			end

			if #fixed_labels > 0 then
				local fixed_label = GGLabel:new(V.v(#editable_slots > 0 and 94 or 210, row.size.y))

				fixed_label.pos = V.v(#editable_slots > 0 and 335 or 205, 0)
				fixed_label.text = table.concat(fixed_labels, " / ")
				fixed_label.font_name = "body"
				fixed_label.font_size = 17
				fixed_label.text_align = "center"
				fixed_label.vertical_align = "middle"
				fixed_label.fit_lines = 1
				fixed_label.colors.text = {219, 183, 103, 255}
				fixed_label.propagate_on_click = true
				fixed_label.propagate_on_down = true
				fixed_label.propagate_on_up = true
				row:add_child(fixed_label)
			end

			list:add_row(row)

			if context == "game" and definition.id == "speed_12x" then
				local credit_row = KView:new(V.v(list.size.x - 16, 32))
				local credit = GGLabel:new(V.v(credit_row.size.x - 16, credit_row.size.y))

				credit.pos = V.v(8, 0)
				credit.text = "Tính năng do nhóm bản địa hóa rebbborn đóng góp. Xin cảm ơn!"
				credit.font_name = "body"
				credit.font_size = 15
				credit.text_align = "left"
				credit.vertical_align = "middle"
				credit.fit_lines = 1
				credit.colors.text = {219, 183, 103, 255}
				credit.propagate_on_click = true
				credit.propagate_on_down = true
				credit.propagate_on_up = true
				credit_row:add_child(credit)
				list:add_row(credit_row)
			end
		end

		self.back:add_child(list)

		return list
	end

	self.map_list = build_list("map")
	self.game_list = build_list("game")

	function map_tab.on_click()
		S:queue("GUIButtonCommon")
		self:set_context("map")
	end

	function game_tab.on_click()
		S:queue("GUIButtonCommon")
		self:set_context("game")
	end

	local reset_button = GGOptionsButton:new("Đặt lại trang này")

	use_bold_settings_button_font(reset_button)
	reset_button.anchor = V.v(reset_button.size.x / 2, reset_button.size.y / 2)
	reset_button.pos = V.v(135, 460)
	reset_button.scale = V.v(0.7, 0.7)
	reset_button.label.fit_lines = 1

	function reset_button.on_click()
		S:queue("GUIButtonCommon")
		self:cancel_capture()
		self.bindings[self.context] = shortcut_settings.reset_context(self.context)
		self:refresh_buttons(self.context)
		self.status_label.text = "Đã khôi phục mặc định cho trang này."

		if self.context == "map" then
			screen_map.map_shortcuts = self.bindings.map
		end
	end

	self.back:add_child(reset_button)

	local back_button = GGOptionsButton:new("Quay lại")

	use_bold_settings_button_font(back_button)
	back_button.anchor = V.v(back_button.size.x / 2, back_button.size.y / 2)
	back_button.pos = V.v(self.back.size.x - 135, 460)
	back_button.scale = V.v(0.7, 0.7)

	function back_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
		screen_map.option_panel:show()
	end

	self.back:add_child(back_button)
	self:set_context("map")
end

function ShortcutSettingsView:cancel_capture()
	if self.capture_button then
		self.capture_button.label.text = shortcut_settings.display_key(self.capture_button.value)

		if screen_map.window.responder == self.capture_button then
			screen_map.window:set_responder()
		end

		self.capture_button = nil
	end
end

function ShortcutSettingsView:refresh_buttons(context)
	for _, button in ipairs(self.binding_buttons[context] or {}) do
		button.value = self.bindings[context][button.shortcut_action][button.shortcut_slot]
		button.label.text = shortcut_settings.display_key(button.value)
	end
end

function ShortcutSettingsView:set_context(context)
	self:cancel_capture()
	self.context = context
	self.map_list.hidden = context ~= "map"
	self.game_list.hidden = context ~= "game"
	self.map_tab.label.text = context == "map" and "[Bản đồ]" or "Bản đồ"
	self.game_tab.label.text = context == "game" and "[Trong trận]" or "Trong trận"
	self.status_label.text = ""
end

function ShortcutSettingsView:show()
	self.bindings.map = shortcut_settings.load_context("map")
	self.bindings.game = shortcut_settings.load_context("game")
	screen_map.map_shortcuts = self.bindings.map
	self:refresh_buttons("map")
	self:refresh_buttons("game")
	self:set_context(self.context or "map")
	ShortcutSettingsView.super.show(self)
end

function ShortcutSettingsView:hide()
	self:cancel_capture()
	ShortcutSettingsView.super.hide(self)
end

OptionsView = class("OptionsView", PopUpView)

function OptionsView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))

	self.back = KImageView:new("options_bg_notxt")
	self.pos = v(0, 0)
	self.back.anchor = v(self.back.size.x / 2, self.back.size.y / 2)
	self.back.pos = v(sw / 2, sh / 2 - 50)

	self:add_child(self.back)

	self.back.alpha = 1

	local mx = 100
	local y = 130
	local header = GGPanelHeader:new(_("OPTIONS"), 242)

	header.pos = V.v(240, CJK(41, 39, nil, 39) - (IS_KR3 and 19 or 0))

	self.back:add_child(header)

	local title = GGOptionsLabel:new(V.v(240, 30))

	title.text = _("SFX")
	title.text_align = "center"
	title.fit_lines = 1
	title.anchor.x = title.size.x / 2
	title.pos = V.v(self.back.size.x / 2, y)
	title.vertical_align = "middle"

	self.back:add_child(title)

	y = y + title.size.y + 7

	local s_sfx = VolumeSlider:new("options_sounds_0004", "options_sounds_0005", "options_sounds_0006")

	s_sfx.pos = V.v(self.back.size.x / 2, y)
	s_sfx.anchor.x = s_sfx.size.x / 2

	function s_sfx:on_change(value)
		S:set_main_gain_fx(value)
	end

	s_sfx.id = "s_sfx"

	self.back:add_child(s_sfx)

	y = y + 50
	title = GGOptionsLabel:new(V.v(200, 30))
	title.text = _("Music")
	title.text_align = "center"
	title.fit_lines = 1
	title.pos = V.v(self.back.size.x / 2, y)
	title.anchor.x = title.size.x / 2
	title.vertical_align = "middle"

	self.back:add_child(title)

	y = y + title.size.y + 7

	local s_music = VolumeSlider:new("options_sounds_0001", "options_sounds_0002", "options_sounds_0003")

	function s_music:on_change(value)
		S:set_main_gain_music(value)
	end

	s_music.pos = V.v(self.back.size.x / 2, y)
	s_music.anchor.x = s_music.size.x / 2
	s_music.id = "s_music"

	self.back:add_child(s_music)

	y = y + 85 - 30
	title = GGOptionsLabel:new(V.v(200, 38))
	title.text = _("Difficulty")
	title.text_align = "center"
	title.vertical_align = CJK("middle-caps", "middle", nil, nil)
	title.pos = V.v(self.back.size.x / 2, y)
	title.anchor.x = title.size.x / 2
	title.propagate_on_click = true
	title.fit_size = true

	self.back:add_child(title)

	self.difficulty_idx = screen_map.user_data.difficulty

	if not self.difficulty_idx then
		self.difficulty_idx = 1
	end

	self.difficulty_labels = {
		"LEVEL_SELECT_DIFFICULTY_CASUAL",
		"LEVEL_SELECT_DIFFICULTY_NORMAL",
		"LEVEL_SELECT_DIFFICULTY_VETERAN",
		"LEVEL_SELECT_DIFFICULTY_IMPOSSIBLE"
	}
	y = y + 38

	local diff_bg = KImageView:new("difficulty_select_bg")

	diff_bg.anchor.x = diff_bg.size.x / 2
	diff_bg.pos = v(self.back.size.x / 2, y)

	self.back:add_child(diff_bg)

	self.difficulty = GGLabel:new(V.v(220, 46))
	self.difficulty.pos = v(self.back.size.x / 2, y)
	self.difficulty.anchor.x = self.difficulty.size.x / 2
	self.difficulty.vertical_align = CJK("middle-caps", "middle", nil, nil)
	self.difficulty.text_align = "center"
	self.difficulty.font_name = CJK("body", nil, nil, "h")
	self.difficulty.font_size = 24
	self.difficulty.text = _(self.difficulty_labels[self.difficulty_idx])
	self.difficulty.colors.text = {
		214,
		189,
		131
	}
	self.difficulty.colors.text_default = {
		214,
		189,
		131
	}
	self.difficulty.colors.text_hover = {
		255,
		223,
		0
	}
	self.difficulty.fit_size = true

	self.back:add_child(self.difficulty)

	function self.difficulty.on_enter(this)
		this.colors.text = this.colors.text_hover
	end

	function self.difficulty.on_exit(this)
		this.colors.text = this.colors.text_default
	end

	function self.difficulty.on_click(this)
		screen_map.option_panel:hide()
		screen_map.difficulty_view:show()
	end

	mx = 150
	y = y + 120 - 10

	-- Keep a single centred entry in the main panel. The actual mobile display
	-- choices live in a dedicated sub-panel so this screen is not overcrowded.
	if IS_ANDROID then
		local mobile_settings_button = GGOptionsButton:new("Cài đặt di động")

		use_bold_settings_button_font(mobile_settings_button)
		mobile_settings_button.anchor.x = mobile_settings_button.size.x / 2
		mobile_settings_button.pos = V.v(self.back.size.x / 2, y + 73)
		mobile_settings_button.scale = V.v(0.8, 0.8)
		mobile_settings_button.label.fit_lines = 1

		function mobile_settings_button.on_click()
			S:queue("GUIButtonCommon")
			self:hide()
			screen_map.mobile_settings_panel:show()
		end

		self.mobile_settings_button = mobile_settings_button
		self.back:add_child(mobile_settings_button)
	else
		local shortcut_settings_button = GGOptionsButton:new("Cài đặt phím tắt")

		use_bold_settings_button_font(shortcut_settings_button)
		shortcut_settings_button.anchor.x = shortcut_settings_button.size.x / 2
		shortcut_settings_button.pos = V.v(self.back.size.x / 2, y + 73)
		shortcut_settings_button.scale = V.v(0.8, 0.8)
		shortcut_settings_button.label.fit_lines = 1

		function shortcut_settings_button.on_click()
			S:queue("GUIButtonCommon")
			self:hide()
			screen_map.shortcut_settings_panel:show()
		end

		self.shortcut_settings_button = shortcut_settings_button
		self.back:add_child(shortcut_settings_button)
	end

	local b

	b = GGOptionsButton:new(_("BUTTON_QUIT"))
	b.anchor.x = 0
	b.pos = V.v(mx, y)

	function b.on_click()
		screen_map.done_callback({
			next_item_name = "slots"
		})
		S:queue("GUIButtonCommon")
	end

	self.quit = b

	self.back:add_child(b)

	b = GGOptionsButton:new(_("BUTTON_RESUME"))
	b.anchor.x = b.size.x
	b.pos = V.v(self.back.size.x - mx, y)

	function b.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
	end

	self.resume = b

	self.back:add_child(b)
	--英雄距离显示
	local btrue_melee_range
	btrue_melee_range = GGOptionsButton:new(_("BUTTON_MELEE_RANGE"))
	btrue_melee_range.anchor.x = btrue_melee_range.size.x
	btrue_melee_range.pos = V.v(self.back.size.x / 2 - 2*mx, y)

	function btrue_melee_range.on_click()
		S:queue("GUIButtonCommon")
		screen_map.user_data.true_melee_range =  not screen_map.user_data.true_melee_range
		storage:save_slot(screen_map.user_data)
	end

	self.melee_range = btrue_melee_range

	self.back:add_child(btrue_melee_range)

	local developer_mode_button = GGOptionsButton:new("Công cụ phát triển")

	use_bold_settings_button_font(developer_mode_button)
	developer_mode_button.anchor.x = 0
	developer_mode_button.pos = V.v(self.back.size.x / 2 + 2 * mx, y)

	function developer_mode_button.on_click()
		S:queue("GUIButtonCommon")
		self:hide()
		screen_map.developer_mode_panel:show()
	end

	self.developer_mode_button = developer_mode_button
	self.back:add_child(developer_mode_button)
	--

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

function OptionsView:show()
	OptionsView.super.show(self)

	self.difficulty_idx = screen_map.user_data.difficulty

	if not self.difficulty_idx then
		self.difficulty_idx = 1
	end

	self.difficulty.text = _(self.difficulty_labels[self.difficulty_idx])
	self._last_volume_fx = km.clamp(0, 1, self:get_child_by_id("s_sfx").value)
	self._last_volume_music = km.clamp(0, 1, self:get_child_by_id("s_music").value)
end

function OptionsView:hide()
	OptionsView.super.hide(self)

	local s_sfx = self:get_child_by_id("s_sfx")
	local s_music = self:get_child_by_id("s_music")

	if self._last_volume_fx ~= s_sfx.value or self._last_volume_music ~= s_music.value then
		local settings = storage:load_settings()

		settings.volume_fx = km.clamp(0, 1, s_sfx.value)
		settings.volume_music = km.clamp(0, 1, s_music.value)

		storage:save_settings(settings)
	end
end

DifficultyButton = class("DifficultyButton", KImageButton)

function DifficultyButton:initialize(label_text, desc_text, difficulty)
	KImageButton.initialize(self, "difficulty_btns_notxt_marco_0001", "difficulty_btns_notxt_marco_0002", "difficulty_btns_notxt_marco_0001")

	self.scale = V.v(1, 1)
	self.on_down_scale = 0.98
	self.anchor.x, self.anchor.y = self.size.x / 2, self.size.y / 2

	local illus = KImageView:new("difficulty_btns_ilustraciones_000" .. difficulty)

	illus.anchor.x, illus.anchor.y = illus.size.x / 2, illus.size.y / 2
	illus.pos.x, illus.pos.y = self.size.x / 2, self.size.y / 2

	self:add_child(illus)

	local glow = KImageView:new("difficulty_btns_notxt_marco_0003")

	glow.hidden = true

	self:add_child(glow)

	self.glow = glow

	local label = GGShaderLabel:new(V.v(268, 50))

	label.font_name = "h"
	label.font_size = 46
	label.text_align = "center"
	label.vertical_align = "middle-caps"
	label.colors.text = {
		255,
		226,
		99,
		255
	}
	label.propagate_on_up = true
	label.propagate_on_down = true
	label.propagate_on_click = true
	label.text = label_text
	label.fit_lines = 1
	label.shaders = {
		"p_bands",
		"p_outline",
		"p_glow"
	}
	label.shader_args = {
		{
			margin = 2,
			p1 = 0,
			p2 = 0.47,
			c1 = {
				1,
				0.8862745098039215,
				0.38823529411764707,
				1
			},
			c2 = {
				1,
				0.8862745098039215,
				0.38823529411764707,
				1
			},
			c3 = {
				0.8509803921568627,
				0.5137254901960784,
				0.10588235294117647,
				1
			}
		},
		{
			thickness = 2.5,
			outline_color = {
				0.2901960784313726,
				0.1607843137254902,
				0,
				1
			}
		},
		{
			thickness = 1.6,
			glow_color = {
				0,
				0,
				0,
				0.6
			}
		}
	}
	label.anchor = v(label.size.x / 2, label.size.y)
	label.pos = v(self.size.x / 2, 272)

	self:add_child(label)

	self.label = label

	local desc = GGLabel:new(V.v(260, 92))

	desc.font_name = "body"
	desc.font_size = 20
	desc.line_height = CJK(1, nil, nil, 0.8)
	desc.text_align = "center"
	desc.vertical_align = "top"
	desc.colors.text = {
		255,
		232,
		189
	}
	desc.propagate_on_up = true
	desc.propagate_on_down = true
	desc.propagate_on_click = true
	desc.text = desc_text
	desc.fit_lines = 3
	desc.anchor = v(desc.size.x / 2, 0)
	desc.pos = v(self.size.x / 2, 280)

	self:add_child(desc)

	self.desc = desc
end

function DifficultyButton:on_down(button, x, y)
	if self.on_down_scale then
		self.original_scale = V.vclone(self.scale)
		self.scale.x, self.scale.y = self.scale.x * self.on_down_scale, self.scale.y * self.on_down_scale
	end
end

function DifficultyButton:on_up(button, x, y)
	if self.on_down_scale and self.original_scale then
		self.scale = self.original_scale
	end
end

function DifficultyButton:on_exit(drag_view)
	if DifficultyButton.super.on_exit then
		DifficultyButton.super.on_exit(self, drag_view)
	end

	if self.on_down_scale and self.original_scale then
		self.scale = self.original_scale
	end

	self.glow.hidden = true
end

function DifficultyButton:on_enter(drag_view)
	if DifficultyButton.super.on_enter then
		DifficultyButton.super.on_enter(self, drag_view)
	end

	self.glow.hidden = false
end

function DifficultyButton:disable(tint, color)
	DifficultyButton.super.disable(self, tint, color)

	local args = self.label.shader_args[1]

	args.c1 = {
		0.6078431372549019,
		0.49411764705882355,
		0,
		1
	}
	args.c2 = {
		0.6078431372549019,
		0.49411764705882355,
		0,
		1
	}
	args.c3 = {
		0.4588235294117647,
		0.12156862745098039,
		0,
		1
	}
end

function DifficultyButton:enable(untint)
	DifficultyButton.super.disable(self, untint)

	local args = self.label.shader_args[1]

	args.c1 = {
		1,
		0.8862745098039215,
		0.38823529411764707,
		1
	}
	args.c2 = {
		1,
		0.8862745098039215,
		0.38823529411764707,
		1
	}
	args.c3 = {
		0.8509803921568627,
		0.5137254901960784,
		0.10588235294117647,
		1
	}
end

DifficultyView = class("DifficultyView", PopUpView)

function DifficultyView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))

	local impo = GS.max_difficulty > DIFFICULTY_HARD

	self.back = KImageView:new(impo and "difficulty_bg_wide_notxt" or "difficulty_bg_notxt")
	self.back.anchor = v(self.back.size.x / 2, self.back.size.y / 2)
	self.back.pos = v(sw / 2, sh / 2)

	self:add_child(self.back)

	sw = self.back.size.x
	sh = self.back.size.y

	if IS_KR3 then
		local header_bg = KImageView("kr3_title_bg")

		header_bg.anchor.x = km.round(header_bg.size.x / 2)
		header_bg.pos = v(km.round(self.back.size.x / 2), -30)

		self.back:add_child(header_bg)
	end

	local header = GGPanelHeader:new(_("DIFFICULTY LEVEL"), 260)

	header.pos = V.v(sw / 2, 29 + (IS_KR3 and -34 or 0))
	header.anchor.x = 130

	self.back:add_child(header)

	-- local campaign_done = #screen_map.user_data.levels > GS.main_campaign_levels
	local campaign_done = #screen_map.user_data.levels >= 1
	local b_y = sh / 2 + (impo and -20 or 0)
	local offset = 90
	local aw = self.back.size.x - 2 * offset
	local sep = impo and -15 or 0
	local b_xs = impo and {
		sw / 2 - 400,
		sw / 2 - 133.33333333333334,
		sw / 2 + 133.33333333333334,
		sw / 2 + 400
	} or {
		sw / 2 - 330,
		sw / 2,
		sw / 2 + 330
	}
	local b_texts = {
		{
			_("LEVEL_SELECT_DIFFICULTY_CASUAL"),
			_("For beginners to strategy games!")
		},
		{
			_("LEVEL_SELECT_DIFFICULTY_NORMAL"),
			_("A good challenge!")
		},
		{
			_("LEVEL_SELECT_DIFFICULTY_VETERAN"),
			_("Hardcore! play at your own risk!")
		}
	}

	if impo then
		table.insert(b_texts, {
			_("LEVEL_SELECT_DIFFICULTY_IMPOSSIBLE"),
			campaign_done and _("DIFFICULTY_SELECTION_IMPOSSIBLE_DESCRIPTION") or _("DIFFICULTY_SELECTION_IMPOSSIBLE_LOCKED_DESCRIPTION")
		})
	end

	for i, set in pairs(b_texts) do
		local title, desc = unpack(set)
		local b = DifficultyButton:new(title, desc, i)
		local bw = b.size.x
		local x

		if impo then
			x = sw / 2 + (2 * i - 5) * (bw / 2 + sep / 2)
		else
			x = sw / 2 + (i - 2) * (bw + sep)
		end

		b.pos = V.v(x, b_y)

		if i == 4 and not campaign_done then
			b:disable()
		end

		function b.on_click(this, b, x, y)
			S:queue("GUIButtonCommon")

			local continue_new_player_setup = screen_map.new_player_setup_stage == "difficulty"

			screen_map.user_data.difficulty = i

			storage:save_slot(screen_map.user_data)
			self:hide()

			if continue_new_player_setup then
				screen_map.new_player_setup_stage = "tower"
				screen_map.tower_room:show()
			end
		end

		self.back:add_child(b)
	end

	local tip = GGLabel:new(V.v(550, 40))

	tip.font_name = "body"
	tip.font_size = 20
	tip.text_align = "left"
	tip.vertical_align = "middle"
	tip.colors.text = {
		255,
		232,
		189
	}
	tip.propagate_on_up = true
	tip.propagate_on_down = true
	tip.propagate_on_click = true
	tip.text = _("You can always change the difficulty in the options menu.")
	tip.fit_lines = 1
	tip.anchor = v(0, 0)
	tip.pos = v(354 + (impo and 82 or 0), 584)

	self.back:add_child(tip)
end

AchievementsView = class("AchievementsView", PopUpView)

function AchievementsView:initialize(sw, sh)
	PopUpView.initialize(self, V.v(sw, sh))

	self.back = KImageView:new("Achievements_BG_notxt")
	self.back.anchor = v(self.back.size.x / 2, self.back.size.y / 2)
	self.back.pos = v(sw / 2 - 15, sh / 2)

	self:add_child(self.back)

	sw = self.back.size.x
	sh = self.back.size.y

	if IS_KR3 then
		local header_bg = KImageView("kr3_title_bg")

		header_bg.anchor.x = km.round(header_bg.size.x / 2)
		header_bg.pos = v(km.round(self.back.size.x / 2) - 10, -24)

		self.back:add_child(header_bg)
	end

	local header = GGPanelHeader:new(_("ACHIEVEMENTS"), 274)

	header.pos = V.v(364, CJK(39, 35, nil, 36) + (IS_KR3 and -36 or 0))

	self.back:add_child(header)

	local close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002", "levelSelect_closeBtn_0003")

	close_button.pos = v(self.back.size.x - 55, 31)
	self.close_button = close_button

	self.back:add_child(close_button)

	function close_button.on_click(this, x, y)
		S:queue("GUIButtonCommon")
		self:hide()
	end

	self.items_per_page = 10
	self.max_pages = math.ceil(#achievements_data / self.items_per_page)
	self.boxes = {}

	for i = 1, self.items_per_page do
		local ach = KImageView:new("Achievements_Box_Large")

		ach.anchor = v(math.floor(ach.size.x / 2), math.floor(ach.size.y / 2))
		ach.pos = v(self.back.size.x / 2, 173 + math.floor((i - 1) / 2) * 108)

		if i % 2 == 0 then
			ach.pos.x = ach.pos.x + 230
		else
			ach.pos.x = ach.pos.x - 230
		end

		ach.img = KImageView:new("achievement_icons_0001")
		ach.img.anchor = v(math.floor(ach.img.size.x / 2), math.floor(ach.img.size.y / 2))
		ach.img.pos = IS_KR3 and v(59, 53) or v(57, 49)

		ach:add_child(ach.img)

		ach.title = GGLabel:new(V.v(260, 32))
		ach.title.pos = v(118, 2 + (IS_KR3 and 4 or 0))
		ach.title.font_name = "h"
		ach.title.font_size = 18
		ach.title.colors.text = {
			233,
			224,
			117
		}
		ach.title.text_align = "left"
		ach.title.vertical_align = "bottom"
		ach.title.fit_lines = 1

		ach:add_child(ach.title)

		ach.desc = GGLabel:new(V.v(260, 40))
		ach.desc.pos = v(118, CJK(33, nil, 36, 36) + (IS_KR3 and 6 or 0))
		ach.desc.font_name = "body"
		ach.desc.font_size = 15
		ach.desc.colors.text = {
			156,
			152,
			126
		}
		ach.desc.line_height = CJK(0.75, nil, 1.1, 0.9)
		ach.desc.text_align = "left"
		ach.desc.fit_lines = CJK(4, nil, nil, 2)

		ach:add_child(ach.desc)
		self.back:add_child(ach)

		self.boxes[i] = ach
	end

	local button_w = 45
	local start_x = math.floor(self.back.size.x / 2 - (button_w - 3) * self.max_pages / 2 + 5)
	local ox = start_x

	for i = 1, self.max_pages do
		local o_button = AchievementsPageButton:new(i)

		o_button.pos = v(ox, 696)
		o_button.page_idx = i

		self.back:add_child(o_button)

		ox = ox + (button_w - 3)
	end

	self:createPage(1)
end

function AchievementsView:show()
	self:createPage(1)
	AchievementsView.super.show(self)
end

function AchievementsView:createPage(pagenum)
	local init = (pagenum - 1) * self.items_per_page

	for i = 1, self.items_per_page do
		if init + i <= #achievements_data then
			local ach = achievements_data[init + i]
			local box = self.boxes[i]

			box.hidden = false

			if not screen_map.user_data.achievements then
				screen_map.user_data.achievements = {}
			end

			local isActive = screen_map.user_data.achievements[ach.name]

			if isActive then
				box.img:set_image("achievement_icons_" .. string.format("%04i", ach.icon))
			else
				box.img:set_image("achievement_icons_disabled_" .. string.format("%04i", ach.icon))
			end

			local prefix = IS_KR3 and "ELVES_"
			local title = _(prefix .. "ACHIEVEMENT_" .. ach.name .. "_NAME")
			local desc = _(prefix .. "ACHIEVEMENT_" .. ach.name .. "_DESCRIPTION")

			box.title.text = title
			box.desc.text = desc

			if isActive then
				box.desc.colors.text = {
					156,
					152,
					126
				}
				box.title.colors.text = {
					233,
					224,
					177
				}
			else
				box.desc.colors.text = {
					107,
					98,
					87
				}
				box.title.colors.text = {
					107,
					98,
					87
				}
			end

			function box.img.on_click(this, button, x, y)
				if isActive then
					log.info("Manually retriggering achievement signal for ach %s", ach.name)
					signal.emit("got-achievement", ach.name)
				end
			end
		else
			local box = self.boxes[i]

			box.hidden = true
		end
	end

	self.current_page_idx = pagenum

	for _, c in pairs(self.back.children) do
		if c:isInstanceOf(AchievementsPageButton) then
			if c.page_idx == pagenum then
				c:select()
			else
				c:deselect()
			end
		end
	end
end

AchievementsPageButton = class("AchievementsPageButton", GGButton)
AchievementsPageButton.static.init_arg_names = {
	"label_text"
}

function AchievementsPageButton:initialize(label_text)
	local rs = GGLabel.static.ref_h / REF_H

	GGButton.initialize(self, "Achievements_page_0001", "Achievements_page_0002", "Achievements_page_0002")

	self.deselected_image_name = "Achievements_page_0001"
	self.selected_image_name = "Achievements_page_0003"
	self.label.pos.x, self.label.pos.y = rs * 1, 0
	self.label.vertical_align = "middle-caps"
	self.label.font_name = "numbers_bold"
	self.label.font_size = rs * 14
	self.label.fit_lines = 1

	if not self.label_text_key and label_text then
		self.label.text = label_text
	end

	self.on_down_scale = 0.95
end

function AchievementsPageButton:on_click()
	S:queue("GUIButtonCommon")
	self.parent.parent:createPage(self.page_idx)
end

function AchievementsPageButton:select()
	self.default_image_name = self.selected_image_name

	self:disable()
	self:set_image(self.selected_image_name)
end

function AchievementsPageButton:deselect()
	self.default_image_name = self.deselected_image_name

	self:enable()

	if not self:is_disabled() then
		self:set_image(self.default_image_name)
	end
end

require("hero_enhance_mod"):hook_hero_room(HeroRoomView)

return screen_map

