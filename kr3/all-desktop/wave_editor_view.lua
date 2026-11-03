-- In-map wave editor. It edits copies stored in the Love save directory and
-- never writes to kr3/data/waves.

local class = require("middleclass")
local E = require("entity_db")
local GS = require("game_settings")
local GU = require("gui_utils_5")
local I = require("klove.image_db")
local S = require("sound_db")
local V = require("klua.vector")
local Store = require("wave_editor_store")
local Resources = require("data.encyclopedia_enemy_resources")

require("klove.kui")
require("gg_views_custom")
require("constants")

local v = V.v

local C = {
	overlay = {0, 0, 0, 175},
	background = {48, 42, 31, 255},
	panel = {232, 219, 177, 255},
	panel_alt = {213, 195, 147, 255},
	row = {245, 235, 202, 255},
	row_alt = {231, 218, 178, 255},
	button = {105, 79, 42, 255},
	button_selected = {74, 132, 61, 255},
	button_disabled = {100, 100, 100, 255},
	text = {52, 37, 21, 255},
	light_text = {255, 246, 218, 255},
	warning = {155, 48, 36, 255}
}

local SPAWN_FIELD_LIMITS = {
	max = 99999,
	interval = 999,
	interval_next = 9999
}

local function make_label(text, size, pos, font_size, color, align)
	local label = GGLabel:new(size)

	label.text = tostring(text or "")
	label.pos = pos or v(0, 0)
	label.font_name = "body"
	label.font_size = font_size or 18
	label.text_align = align or "left"
	label.vertical_align = "middle"
	label.colors.text = color or C.text
	label.fit_lines = 1

	return label
end

local function make_button(text, size, pos, callback, selected)
	local button = KButton:new(size)

	button.text = tostring(text or "")
	button.pos = pos or v(0, 0)
	button.font_name = "body"
	button.font_size = 18
	button.text_offset.y = math.max(0, math.floor((size.y - button.font_size) / 2) - 2)
	button.text_align = "center"
	button.vertical_align = "middle"
	button.colors.text = C.light_text
	button._wave_editor_background = selected and C.button_selected or C.button
	button.colors.background = button._wave_editor_background
	button.propagate_on_click = false

	function button.on_click(this)
		S:queue("GUIButtonCommon")
		if callback then
			callback(this)
		end
	end

	return button
end

local function set_button_enabled(button, enabled)
	if enabled then
		button:enable(false)
		button.colors.background = button._wave_editor_background or C.button
	else
		button:disable(false)
		button.colors.background = C.button_disabled
	end
end

local WaveScrollList = class("WaveScrollList", KScrollList)

function WaveScrollList:initialize(size)
	WaveScrollList.super.initialize(self, size)
	self.can_drag = IS_ANDROID
end

function WaveScrollList:_consume_body_drag()
	self._wave_editor_fixed_pos = self._wave_editor_fixed_pos or V.vclone(self.pos)

	local fixed = self._wave_editor_fixed_pos
	local dy = self.pos.y - fixed.y

	if dy ~= 0 and not self._down_y and self._bottom_y > self.size.y then
		self.scroll_origin_y = math.max(-(self._bottom_y - self.size.y), math.min(0, self.scroll_origin_y + dy))
	end

	self.pos.x = fixed.x
	self.pos.y = fixed.y
end

function WaveScrollList:update(dt)
	WaveScrollList.super.update(self, dt)

	if IS_ANDROID then
		self:_consume_body_drag()
	end
end

function WaveScrollList:on_dropped()
	self:_consume_body_drag()
	self._down_y = nil
end

local NumericInputView = class("WaveNumericInputView", KView)

function NumericInputView:initialize(sw, sh, title, initial_value, maximum, on_confirm, on_close)
	KView.initialize(self, v(sw, sh))
	self.colors.background = C.overlay
	self.maximum = maximum
	self.max_digits = #tostring(maximum)
	self.buffer = tostring(math.max(0, math.min(maximum, math.floor(tonumber(initial_value) or 0))))
	self.on_confirm_value = on_confirm
	self.on_close_view = on_close

	local pw, ph = 520, 550
	local back = KView:new(v(pw, ph))

	back.anchor = v(pw / 2, ph / 2)
	back.pos = v(sw / 2, sh / 2)
	back.colors.background = C.panel
	self.back = back
	self:add_child(back)

	local heading = make_label(title, v(pw, 52), v(0, 0), 27, C.light_text, "center")
	heading.colors.background = C.background
	back:add_child(heading)

	self.value_label = make_label(self.buffer, v(pw - 80, 64), v(40, 68), 34, C.text, "center")
	self.value_label.colors.background = C.row_alt
	back:add_child(self.value_label)

	local digits = {
		{"1", "2", "3"},
		{"4", "5", "6"},
		{"7", "8", "9"}
	}

	for row, values in ipairs(digits) do
		for col, digit in ipairs(values) do
			back:add_child(make_button(digit, v(120, 60), v(60 + (col - 1) * 140, 150 + (row - 1) * 72), function()
				self:_append_digit(digit)
			end))
		end
	end

	back:add_child(make_button("Xóa hết", v(120, 60), v(60, 366), function()
		self.buffer = ""
		self:_refresh_value()
	end))
	back:add_child(make_button("0", v(120, 60), v(200, 366), function()
		self:_append_digit("0")
	end))
	back:add_child(make_button("Hủy", v(160, 54), v(80, 470), function()
		self:_dismiss()
	end))
	back:add_child(make_button("Đồng ý", v(160, 54), v(280, 470), function()
		local callback = self.on_confirm_value
		local value = math.max(0, math.min(self.maximum, tonumber(self.buffer) or 0))

		self:_dismiss()
		if callback then
			callback(value)
		end
	end, true))
end

function NumericInputView:_refresh_value()
	self.value_label.text = self.buffer ~= "" and self.buffer or "0"
end

function NumericInputView:_append_digit(digit)
	local buffer = self.buffer == "0" and "" or self.buffer

	if #buffer >= self.max_digits then
		self.buffer = tostring(self.maximum)
	else
		local candidate = buffer .. digit
		self.buffer = tonumber(candidate) > self.maximum and tostring(self.maximum) or candidate
	end

	self:_refresh_value()
end

function NumericInputView:_dismiss()
	local parent = self.parent
	local on_close = self.on_close_view

	if parent then
		parent:remove_child(self)
	end
	if on_close then
		on_close(self)
	end
	self:destroy()
end

local function list_contains(list, value)
	for _, item in ipairs(list or {}) do
		if item == value then
			return true
		end
	end

	return false
end

local function enemy_region_key(enemy_name, entry)
	if entry and entry.region and Resources.regions[entry.region] then
		return entry.region
	end

	if entry and entry.first_level then
		for key, region in pairs(Resources.regions) do
			if region.generation == entry.generation and list_contains(region.levels, entry.first_level) then
				return key
			end
		end
	end

	return string.format("g%d_other", entry and entry.generation or 0)
end

local function translated_enemy_name(template_name)
	local tpl = E:get_template(template_name)
	local key = tpl and tpl.info and (tpl.info.i18n_key or string.upper(template_name)) or string.upper(template_name)
	local name = _(key .. "_NAME")

	if name == key .. "_NAME" then
		name = template_name
	end

	return name, tpl, key
end

local function enemy_icon_index(entry, tpl)
	if not tpl or not tpl.info or not tpl.info.enc_icon then
		return nil
	end

	local offset = tpl.info.enc_icon_offset

	if offset == nil then
		local index = entry and entry.encyclopedia_index or 0
		if index >= 172 and index <= 321 then
			offset = 500
		elseif index >= 322 then
			offset = 300
		else
			offset = 0
		end
	end

	return tpl.info.enc_icon + offset
end

local function enemy_icon_template(template_name, fallback)
	return E:get_template(template_name .. "_10086") or fallback
end

local function safe_image(name)
	return name and I:s(name) and KImageView:new(name) or nil
end

local EnemyPickerView = class("WaveEnemyPickerView", PopUpView)

function EnemyPickerView:initialize(sw, sh, initial_enemy, on_confirm)
	PopUpView.initialize(self, v(sw, sh))
	self.colors.background = C.overlay
	self.on_confirm_enemy = on_confirm
	self.selected_enemy = initial_enemy
	local initial_entry = Resources.enemies[initial_enemy]

	self.generation = initial_entry and initial_entry.generation or 3
	self.region = initial_entry and enemy_region_key(initial_enemy, initial_entry) or nil

	local pw, ph = math.min(1660, sw - 80), math.min(900, sh - 80)
	local back = KView:new(v(pw, ph))

	back.anchor = v(pw / 2, ph / 2)
	back.pos = v(sw / 2, sh / 2)
	back.colors.background = C.panel
	self.back = back
	self:add_child(back)

	back:add_child(make_label("Chọn quái", v(pw, 48), v(0, 0), 30, C.light_text, "center"))
	back.children[#back.children].colors.background = C.background

	local close = make_button("×", v(48, 40), v(pw - 54, 4), function()
		self:hide()
	end)
	close.font_size = 28
	back:add_child(close)

	self.gen_bar = KView:new(v(650, 44))
	self.gen_bar.pos = v(24, 58)
	back:add_child(self.gen_bar)

	self.region_bar = KView:new(v(pw - 720, 44))
	self.region_bar.pos = v(700, 58)
	back:add_child(self.region_bar)

	self.enemy_list = WaveScrollList:new(v(690, ph - 180))
	self.enemy_list.pos = v(24, 112)
	self.enemy_list.scroll_amount = 52
	self.enemy_list.colors.background = C.row
	back:add_child(self.enemy_list)

	self.details = KView:new(v(pw - 750, ph - 180))
	self.details.pos = v(730, 112)
	self.details.colors.background = C.row
	back:add_child(self.details)

	self.confirm = make_button("Xác nhận", v(180, 42), v(24, ph - 56), function()
		if self.selected_enemy and self.on_confirm_enemy then
			self.on_confirm_enemy(self.selected_enemy)
			self:hide()
		end
	end)
	back:add_child(self.confirm)

	self:_rebuild_generation_bar()
	self:_ensure_region()
	self:_rebuild_region_bar()
	self:_rebuild_enemy_list()
	self:_show_details(self.selected_enemy)
end

function EnemyPickerView:_regions_for_generation()
	local out = {}
	local has_other = false

	for key, region in pairs(Resources.regions) do
		if region.generation == self.generation then
			out[#out + 1] = {key = key, data = region}
		end
	end

	for name, entry in pairs(Resources.enemies) do
		if entry.generation == self.generation and enemy_region_key(name, entry) == string.format("g%d_other", self.generation) then
			has_other = true
			break
		end
	end

	if has_other then
		out[#out + 1] = {
			key = string.format("g%d_other", self.generation),
			data = {
				generation = self.generation,
				kind = "other"
			}
		}
	end

	table.sort(out, function(a, b)
		if a.data.kind ~= b.data.kind then
			local order = {main = 1, branch = 2, other = 3}
			return (order[a.data.kind] or 9) < (order[b.data.kind] or 9)
		end
		return a.key < b.key
	end)

	local main_index, branch_index = 0, 0

	for _, row in ipairs(out) do
		if row.data.kind == "main" then
			main_index = main_index + 1
			row.ordinal = main_index
		elseif row.data.kind == "branch" then
			branch_index = branch_index + 1
			row.ordinal = branch_index
		end
	end

	return out
end

function EnemyPickerView:_region_title(row)
	local region = row.data

	if region.kind == "main" then
		return string.format("Tuyến chính %d", row.ordinal or 1)
	elseif region.kind == "other" then
		return "Khác"
	end

	return string.format("Tuyến phụ %d", row.ordinal or 1)
end

function EnemyPickerView:_ensure_region()
	local regions = self:_regions_for_generation()
	local found = false

	for _, row in ipairs(regions) do
		if row.key == self.region then
			found = true
			break
		end
	end

	self.region = found and self.region or regions[1] and regions[1].key or nil
end

function EnemyPickerView:_rebuild_generation_bar()
	self.gen_bar:remove_children()

	for generation = 1, 5 do
		local gen = generation
		self.gen_bar:add_child(make_button("Phần " .. gen, v(112, 38), v((gen - 1) * 124, 0), function()
			self.generation = gen
			self.region = nil
			self:_ensure_region()
			self:_rebuild_generation_bar()
			self:_rebuild_region_bar()
			self:_rebuild_enemy_list()
		end, self.generation == gen))
	end
end

function EnemyPickerView:_rebuild_region_bar()
	self.region_bar:remove_children()
	local regions = self:_regions_for_generation()
	local visible = math.max(1, math.floor(self.region_bar.size.x / 154))
	self.region_offset = math.max(1, math.min(self.region_offset or 1, math.max(1, #regions - visible + 1)))

	self.region_bar:add_child(make_button("‹", v(36, 38), v(0, 0), function()
		self.region_offset = math.max(1, self.region_offset - 1)
		self:_rebuild_region_bar()
	end))

	for slot = 1, visible do
		local row = regions[self.region_offset + slot - 1]
		if row then
			local selected_region = row.key
			local button = make_button(self:_region_title(row), v(146, 38), v(42 + (slot - 1) * 154, 0), function()
				self.region = selected_region
				self:_rebuild_region_bar()
				self:_rebuild_enemy_list()
			end, self.region == selected_region)
			button.font_size = 15
			self.region_bar:add_child(button)
		end
	end

	self.region_bar:add_child(make_button("›", v(36, 38), v(self.region_bar.size.x - 36, 0), function()
		self.region_offset = math.min(math.max(1, #regions - visible + 1), self.region_offset + 1)
		self:_rebuild_region_bar()
	end))
end

function EnemyPickerView:_rebuild_enemy_list()
	self.enemy_list:clear_rows()
	local enemies = {}

	for name, entry in pairs(Resources.enemies) do
		if entry.generation == self.generation and enemy_region_key(name, entry) == self.region then
			enemies[#enemies + 1] = {name = name, entry = entry}
		end
	end

	table.sort(enemies, function(a, b)
		return a.entry.encyclopedia_index < b.entry.encyclopedia_index
	end)

	for index, row_data in ipairs(enemies) do
		local name = row_data.name
		local display_name, tpl = translated_enemy_name(name)
		local row = KView:new(v(self.enemy_list.size.x - 20, 58))

		row.colors.background = index % 2 == 0 and C.row_alt or C.row

		local icon_index = enemy_icon_index(row_data.entry, enemy_icon_template(name, tpl))
		local icon = icon_index and safe_image(string.format(GS.encyclopedia_enemy_thumb_fmt, icon_index))
		if icon then
			icon.pos = v(8, 4)
			icon.scale = v(0.72, 0.72)
			row:add_child(icon)
		end

		local button = make_button(display_name, v(row.size.x - 74, 50), v(66, 4), function()
			self.selected_enemy = name
			self:_show_details(name)
			self:_rebuild_enemy_list()
		end, self.selected_enemy == name)
		button.font_size = 16
		button.fit_lines = 2
		row:add_child(button)
		self.enemy_list:add_row(row)
	end

	if #enemies == 0 then
		local row = KView:new(v(self.enemy_list.size.x - 20, 60))
		row:add_child(make_label("Danh mục này không có quái trong bách khoa.", row.size, v(0, 0), 18, C.warning, "center"))
		self.enemy_list:add_row(row)
	end
end

function EnemyPickerView:_show_details(enemy_name)
	self.details:remove_children()

	if not enemy_name then
		self.details:add_child(make_label("Hãy chọn quái", self.details.size, v(0, 0), 24, C.text, "center"))
		return
	end

	local entry = Resources.enemies[enemy_name]
	local display_name, tpl, key = translated_enemy_name(enemy_name)
	local title = make_label(display_name, v(self.details.size.x - 30, 46), v(15, 10), 28, C.text, "center")
	self.details:add_child(title)

	local icon_index = enemy_icon_index(entry, enemy_icon_template(enemy_name, tpl))
	local portrait = icon_index and safe_image(string.format(GS.encyclopedia_enemy_fmt, icon_index))
	if portrait then
		portrait.anchor = v(portrait.size.x / 2, portrait.size.y / 2)
		portrait.pos = v(self.details.size.x / 2, 188)
		portrait.scale = v(0.68, 0.68)
		self.details:add_child(portrait)
	end

	local desc_key = key .. "_DESCRIPTION"
	local desc = _(desc_key)
	if desc == desc_key then
		desc = _(key .. "_NOTIFICATION_DESCRIPTION")
	end
	if desc == key .. "_NOTIFICATION_DESCRIPTION" then
		desc = ""
	end

	local desc_label = make_label(desc, v(self.details.size.x - 80, 100), v(40, 285), 17, C.text, "center")
	desc_label.fit_lines = 5
	desc_label.line_height = 1.05
	self.details:add_child(desc_label)

	local entity = E:create_entity(enemy_name)
	local info
	if entity and entity.info and entity.info.fn then
		local ok, result = pcall(entity.info.fn, entity)
		info = ok and result or nil
	end

	local stats = {}
	if info then
		stats = {
			{"Máu", info.hp_max},
			{"Tấn công", GU.damage_value_desc(info.damage_min, info.damage_max)},
			{"Giáp", GU.armor_value_desc(info.armor)},
			{"Kháng phép", GU.armor_value_desc(info.magic_armor)},
			{"Tốc độ", GU.speed_value_desc(entity.motion and entity.motion.max_speed or 0)},
			{"Chi phí", GU.lives_desc(info.lives)}
		}
	end

	for i, stat in ipairs(stats) do
		local col = (i - 1) % 2
		local row = math.floor((i - 1) / 2)
		self.details:add_child(make_label(stat[1] .. "：" .. tostring(stat[2] or "-"), v(250, 34), v(70 + col * 285, 410 + row * 42), 18, C.text, "left"))
	end

	local special_key = key .. "_SPECIAL"
	local special = _(special_key)
	if special == special_key then
		special = ""
	end
	local special_label = make_label(special, v(self.details.size.x - 80, 120), v(40, 550), 17, {116, 70, 38, 255}, "center")
	special_label.fit_lines = 6
	self.details:add_child(special_label)
end

local WaveEditorView = class("WaveEditorView", PopUpView)

function WaveEditorView:initialize(sw, sh, screen_map)
	PopUpView.initialize(self, v(sw, sh))
	self.colors.background = C.overlay
	self.screen_map = screen_map
	self.generation = screen_map.kr1_map and 1 or screen_map.kr2_map and 2 or screen_map.kr4_map and 4 or screen_map.kr5_map and 5 or 3
	self.mode = GAME_MODE_CAMPAIGN
	self.group_idx = 1
	self.path_idx = 1
	self._bar_offsets = {}

	local pw, ph = math.min(1780, sw - 50), math.min(980, sh - 50)
	local back = KView:new(v(pw, ph))

	back.anchor = v(pw / 2, ph / 2)
	back.pos = v(sw / 2, sh / 2)
	back.colors.background = C.panel
	self.back = back
	self:add_child(back)

	local title = make_label("Sửa đợt quái", v(pw, 52), v(0, 0), 32, C.light_text, "center")
	title.colors.background = C.background
	back:add_child(title)

	local close = make_button("×", v(48, 42), v(pw - 54, 5), function()
		self:hide()
	end)
	close.font_size = 28
	back:add_child(close)

	self.left = KView:new(v(420, ph - 72))
	self.left.pos = v(14, 60)
	self.left.colors.background = C.panel_alt
	back:add_child(self.left)

	self.right = KView:new(v(pw - 462, ph - 72))
	self.right.pos = v(448, 60)
	self.right.colors.background = C.row
	back:add_child(self.right)

	self:_build_left()
	self:_build_right()
	self:_select_generation(self.generation)
end

function WaveEditorView:_build_left()
	self.left:add_child(make_label("Chọn phần", v(self.left.size.x, 36), v(0, 0), 22, C.text, "center"))
	self.gen_bar = KView:new(v(self.left.size.x - 20, 44))
	self.gen_bar.pos = v(10, 38)
	self.left:add_child(self.gen_bar)

	self.left:add_child(make_label("Chọn màn", v(self.left.size.x, 34), v(0, 88), 22, C.text, "center"))
	self.level_list = WaveScrollList:new(v(self.left.size.x - 24, self.left.size.y - 244))
	self.level_list.pos = v(12, 124)
	self.level_list.scroll_amount = 46
	self.left:add_child(self.level_list)

	self.mode_bar = KView:new(v(self.left.size.x - 20, 50))
	self.mode_bar.pos = v(10, self.left.size.y - 108)
	self.left:add_child(self.mode_bar)

	self.left_status = make_label("", v(self.left.size.x - 24, 48), v(12, self.left.size.y - 54), 15, C.warning, "center")
	self.left_status.fit_lines = 2
	self.left:add_child(self.left_status)
end

function WaveEditorView:_build_right()
	local rw = self.right.size.x

	self.source_new = make_button("Tạo từ mẫu gốc", v(180, 40), v(14, 10), function()
		self:_create_from_source()
	end)
	self.right:add_child(self.source_new)
	self.reload_button = make_button("Nạp", v(100, 40), v(204, 10), function()
		self:_load_context(true)
	end)
	self.right:add_child(self.reload_button)
	self.save_button = make_button("Lưu", v(100, 40), v(314, 10), function()
		self:_save_current()
	end)
	self.right:add_child(self.save_button)
	self.delete_list_button = make_button("Xóa mẫu", v(110, 40), v(424, 10), function()
		self:_delete_current_list()
	end)
	self.right:add_child(self.delete_list_button)

	self.assignment_label = make_label("", v(rw - 552, 40), v(544, 10), 17, C.text, "left")
	self.right:add_child(self.assignment_label)

	self.list_bar = KView:new(v(rw - 28, 42))
	self.list_bar.pos = v(14, 56)
	self.right:add_child(self.list_bar)

	self.path_bar = KView:new(v(rw - 28, 42))
	self.path_bar.pos = v(14, 106)
	self.right:add_child(self.path_bar)

	self.wave_bar = KView:new(v(rw - 28, 42))
	self.wave_bar.pos = v(14, 156)
	self.right:add_child(self.wave_bar)

	self.spawn_list = WaveScrollList:new(v(rw - 28, self.right.size.y - 280))
	self.spawn_list.pos = v(14, 210)
	self.spawn_list.scroll_amount = 76
	self.spawn_list.colors.background = C.row
	self.right:add_child(self.spawn_list)

	self.add_spawn_button = make_button("+ Thêm lượt quái", v(180, 42), v(14, self.right.size.y - 58), function()
		self:_add_spawn()
	end)
	self.right:add_child(self.add_spawn_button)
	self.remove_spawn_button = make_button("− Xóa lượt cuối", v(180, 42), v(204, self.right.size.y - 58), function()
		self:_remove_last_spawn()
	end)
	self.right:add_child(self.remove_spawn_button)

	self.status = make_label("", v(rw - 420, 42), v(410, self.right.size.y - 58), 16, C.warning, "left")
	self.status.fit_lines = 2
	self.right:add_child(self.status)
end

function WaveEditorView:_set_status(text, ok)
	self.status.text = tostring(text or "")
	self.status.colors.text = ok and C.button_selected or C.warning
end

function WaveEditorView:_rebuild_generation_bar()
	self.gen_bar:remove_children()
	for generation = 1, 5 do
		local gen = generation
		self.gen_bar:add_child(make_button("Phần " .. gen, v(70, 38), v((gen - 1) * 78, 0), function()
			self:_select_generation(gen)
		end, self.generation == gen))
	end
end

function WaveEditorView:_select_generation(generation)
	self.generation = generation
	self.levels = Store.levels_for_generation(generation)
	self.level_idx = self.levels[1]
	self.mode = GAME_MODE_CAMPAIGN
	self:_rebuild_generation_bar()
	self:_rebuild_level_list()
	self:_rebuild_mode_bar()
	self:_load_context(true)
end

function WaveEditorView:_rebuild_level_list()
	self.level_list:clear_rows()
	for level_order, idx in ipairs(self.levels or {}) do
		local level_idx = idx
		local key = string.format("LEVEL_%d_TITLE", level_idx)
		local level_title = _(key)
		if level_title == key then
			level_title = ""
		end
		local row = KView:new(v(self.level_list.size.x - 20, 48))
		local text = level_title ~= "" and string.format("Màn %d  %s", level_idx, level_title) or string.format("Màn %d", level_idx)
		local button = make_button(text, v(row.size.x - 8, 42), v(4, 3), function()
			self.level_idx = level_idx
			self:_rebuild_level_list()
			self:_rebuild_mode_bar()
			self:_load_context(true)
		end, self.level_idx == level_idx)
		button.font_size = 16
		row:add_child(button)
		self.level_list:add_row(row)
	end
end

function WaveEditorView:_rebuild_mode_bar()
	self.mode_bar:remove_children()
	local modes = {
		{GAME_MODE_CAMPAIGN, "Chiến dịch"},
		{GAME_MODE_HEROIC, "Anh hùng"},
		{GAME_MODE_IRON, "Sắt"}
	}

	for i, row in ipairs(modes) do
		local mode, text = row[1], row[2]
		local exists = self.level_idx and Store.source_exists(self.level_idx, mode)
		local button = make_button(text, v(120, 40), v((i - 1) * 130, 0), function()
			if exists then
				self.mode = mode
				self:_rebuild_mode_bar()
				self:_load_context(true)
			end
		end, self.mode == mode)
		set_button_enabled(button, exists)
		self.mode_bar:add_child(button)
	end
end

function WaveEditorView:_load_context(force)
	if not self.level_idx or not Store.source_exists(self.level_idx, self.mode) then
		self.wave = nil
		self.current_list_id = nil
		self.group_idx = 1
		self.path_idx = 1
		self.path_count = 1
		self.left_status.text = "Màn này không có dữ liệu đợt quái gốc cho chế độ đã chọn."
		self:_refresh_right()
		return
	end

	self.left_status.text = ""
	self.source_format = Store.source_format(self.level_idx, self.mode)
	self.current_list_id = Store.get_assignment(self.level_idx, self.mode)
	local document = self.current_list_id and Store.load_list(self.current_list_id, force)
	if document and type(document.wave) == "table" then
		self.wave = document.wave
	else
		self.current_list_id = nil
		self.wave = Store.load_source(self.level_idx, self.mode)
	end

	self.group_idx = math.max(1, math.min(self.group_idx or 1, #(self.wave and self.wave.groups or {})))
	self.path_count = Store.path_count(self.level_idx, self.wave)
	self.path_idx = math.max(1, math.min(self.path_idx or 1, self.path_count))
	self:_refresh_right()
	local format_name = self.source_format == "tsv" and "TSV" or "Lua"
	self:_set_status(self.current_list_id and "Đã nạp danh sách quái tùy chỉnh: " .. format_name .. "" or "Đang dùng danh sách quái gốc: " .. format_name .. " (chỉ đọc)", true)
end

function WaveEditorView:_refresh_right()
	self:_rebuild_list_bar()
	self:_rebuild_index_bar(self.path_bar, "Đường", self.path_count or 1, self.path_idx or 1, "path", function(index)
		self.path_idx = index
		self:_refresh_right()
	end)
	self:_rebuild_index_bar(self.wave_bar, "Đợt", #(self.wave and self.wave.groups or {}), self.group_idx or 1, "wave", function(index)
		self.group_idx = index
		self:_refresh_right()
	end)
	self:_rebuild_spawn_list()

	local selected = self.current_list_id and string.format("Tùy chỉnh %d", self.current_list_id) or "Quái gốc"
	self.assignment_label.text = string.format("Màn %d / %s / %s / Đang dùng: %s", self.level_idx or 0, Store.mode_suffix(self.mode) or "-", string.upper(self.source_format or "-"), selected)
	set_button_enabled(self.save_button, self.current_list_id ~= nil)
	set_button_enabled(self.delete_list_button, self.current_list_id ~= nil)
end

function WaveEditorView:_rebuild_list_bar()
	self.list_bar:remove_children()
	self.list_bar:add_child(make_label("Danh sách quái", v(92, 38), v(0, 0), 18, C.text, "center"))

	local choices = {{id = nil, name = "Gốc"}}
	for _, row in ipairs(Store.get_lists(self.level_idx, self.mode)) do
		choices[#choices + 1] = row
	end

	local visible = math.max(1, math.floor((self.list_bar.size.x - 180) / 124))
	local offset = math.max(1, math.min(self._bar_offsets.lists or 1, math.max(1, #choices - visible + 1)))
	self._bar_offsets.lists = offset
	self.list_bar:add_child(make_button("‹", v(36, 36), v(94, 1), function()
		self._bar_offsets.lists = math.max(1, offset - 1)
		self:_rebuild_list_bar()
	end))

	for slot = 1, visible do
		local choice = choices[offset + slot - 1]
		if choice then
			local id = choice.id
			self.list_bar:add_child(make_button(choice.name, v(116, 36), v(136 + (slot - 1) * 124, 1), function()
				Store.set_assignment(self.level_idx, self.mode, id)
				self.group_idx = 1
				self.path_idx = 1
				self:_load_context(true)
			end, self.current_list_id == id))
		end
	end

	self.list_bar:add_child(make_button("›", v(36, 36), v(self.list_bar.size.x - 36, 1), function()
		self._bar_offsets.lists = math.min(math.max(1, #choices - visible + 1), offset + 1)
		self:_rebuild_list_bar()
	end))
end

function WaveEditorView:_rebuild_index_bar(container, title, count, selected, key, callback)
	container:remove_children()
	container:add_child(make_label(title, v(92, 38), v(0, 0), 18, C.text, "center"))
	count = math.max(0, count or 0)

	local visible = math.max(1, math.floor((container.size.x - 180) / 74))
	local offset = math.max(1, math.min(self._bar_offsets[key] or 1, math.max(1, count - visible + 1)))
	self._bar_offsets[key] = offset
	container:add_child(make_button("‹", v(36, 36), v(94, 1), function()
		self._bar_offsets[key] = math.max(1, offset - 1)
		self:_refresh_right()
	end))

	for slot = 1, visible do
		local index = offset + slot - 1
		if index <= count then
			local selected_index = index
			container:add_child(make_button(tostring(index), v(66, 36), v(136 + (slot - 1) * 74, 1), function()
				callback(selected_index)
			end, selected == index))
		end
	end

	container:add_child(make_button("›", v(36, 36), v(container.size.x - 36, 1), function()
		self._bar_offsets[key] = math.min(math.max(1, count - visible + 1), offset + 1)
		self:_refresh_right()
	end))
end

function WaveEditorView:_selected_path_wave(create)
	local group = self.wave and self.wave.groups and self.wave.groups[self.group_idx]
	if not group then
		return nil
	end

	group.waves = group.waves or {}
	for _, path_wave in ipairs(group.waves) do
		if tonumber(path_wave.path_index) == self.path_idx then
			path_wave.spawns = path_wave.spawns or {}
			return path_wave
		end
	end

	if create then
		local path_wave = {delay = 0, path_index = self.path_idx, spawns = {}}
		group.waves[#group.waves + 1] = path_wave
		table.sort(group.waves, function(a, b)
			return (a.path_index or 0) < (b.path_index or 0)
		end)
		return path_wave
	end

	return nil
end

function WaveEditorView:_can_edit()
	if not self.current_list_id then
		self:_set_status("Không thể sửa trực tiếp đợt quái gốc. Hãy chọn Tạo từ mẫu gốc trước.")
		return false
	end
	return true
end

function WaveEditorView:_set_spawn_value(index, field, value, minimum, maximum)
	if not self:_can_edit() then
		return
	end
	local path_wave = self:_selected_path_wave(false)
	local spawn = path_wave and path_wave.spawns[index]
	if not spawn then
		return
	end
	spawn[field] = math.max(minimum or 0, math.min(maximum or math.huge, tonumber(value) or 0))
	self:_rebuild_spawn_list()
end

function WaveEditorView:_adjust_spawn(index, field, delta, minimum, maximum)
	local path_wave = self:_selected_path_wave(false)
	local spawn = path_wave and path_wave.spawns[index]

	if not spawn then
		return
	end

	self:_set_spawn_value(index, field, (tonumber(spawn[field]) or 0) + delta, minimum, maximum)
end

function WaveEditorView:_open_numeric_input(index, field, title, maximum)
	if not self:_can_edit() then
		return
	end

	local path_wave = self:_selected_path_wave(false)
	local spawn = path_wave and path_wave.spawns[index]

	if not spawn then
		return
	end

	if self.numeric_input then
		self.numeric_input:_dismiss()
	end

	local popup
	popup = NumericInputView:new(self.sw, self.sh, title .. " (tối đa " .. maximum .. "）", spawn[field], maximum, function(value)
		self:_set_spawn_value(index, field, value, 0, maximum)
	end, function(view)
		if self.numeric_input == view then
			self.numeric_input = nil
		end
	end)
	self.numeric_input = popup
	self:add_child(popup)
end

function WaveEditorView:_rebuild_spawn_list()
	self.spawn_list:clear_rows()
	local path_wave = self:_selected_path_wave(false)
	local spawns = path_wave and path_wave.spawns or {}

	if #spawns == 0 then
		local row = KView:new(v(self.spawn_list.size.x - 20, 80))
		row.colors.background = C.row
		row:add_child(make_label("Đường này trong đợt hiện tại chưa có lượt quái. Nhấn Thêm lượt quái bên dưới.", row.size, v(0, 0), 19, C.warning, "center"))
		self.spawn_list:add_row(row)
		return
	end

	for i, spawn in ipairs(spawns) do
		local index = i
		local row = KView:new(v(self.spawn_list.size.x - 20, 84))
		row.colors.background = i % 2 == 0 and C.row_alt or C.row
		row:add_child(make_label(string.format("%02d", i), v(42, 76), v(4, 4), 18, C.text, "center"))

		local enemy_name = spawn.creep or "enemy_gnoll_reaver"
		local display_name = translated_enemy_name(enemy_name)
		local delete_x = row.size.x - 94
		local controls_right = delete_x - 8
		local step_width = math.max(112, math.min(160, math.floor((controls_right - 48 - 180 - 12) / 3)))
		local enemy_width = math.max(180, math.min(330, controls_right - 48 - 12 - step_width * 3))
		local stepper_x = 48 + enemy_width + 12
		local enemy_button = make_button(display_name, v(enemy_width, 68), v(48, 8), function()
			self:_open_enemy_picker(index)
		end)
		enemy_button.font_size = 15
		enemy_button.fit_lines = 2
		row:add_child(enemy_button)

		local function add_stepper(x, title, field, step)
			local maximum = SPAWN_FIELD_LIMITS[field]
			local small_w = math.max(30, math.floor(step_width * 0.23))
			local custom_w = step_width - small_w * 2 - 10

			row:add_child(make_label(title .. " " .. tostring(spawn[field] or 0), v(step_width, 28), v(x, 4), 15, C.text, "center"))
			row:add_child(make_button("-", v(small_w, 36), v(x, 38), function()
				self:_adjust_spawn(index, field, -step, 0, maximum)
			end))
			row:add_child(make_button("+", v(small_w, 36), v(x + small_w + 5, 38), function()
				self:_adjust_spawn(index, field, step, 0, maximum)
			end))
			local custom = make_button("Tùy chỉnh", v(custom_w, 36), v(x + small_w * 2 + 10, 38), function()
				self:_open_numeric_input(index, field, title, maximum)
			end)
			custom.font_size = 14
			row:add_child(custom)
		end

		add_stepper(stepper_x, "Số lượng", "max", 1)
		add_stepper(stepper_x + step_width, "interval", "interval", 1)
		add_stepper(stepper_x + step_width * 2, "interval_next", "interval_next", 1)

		row:add_child(make_button("Xóa", v(84, 48), v(delete_x, 18), function()
			if self:_can_edit() then
				table.remove(spawns, index)
				self:_rebuild_spawn_list()
			end
		end))
		self.spawn_list:add_row(row)
	end
end

function WaveEditorView:_add_spawn()
	if not self:_can_edit() then
		return
	end

	local path_wave = self:_selected_path_wave(true)
	path_wave.spawns[#path_wave.spawns + 1] = {
		interval = 0,
		max_same = 0,
		fixed_sub_path = 1,
		creep = "enemy_gnoll_reaver",
		path = 1,
		interval_next = 0,
		max = 1
	}
	self:_rebuild_spawn_list()
	if self.spawn_list._bottom_y > self.spawn_list.size.y then
		self.spawn_list:scroll_to_bottom()
	end
end

function WaveEditorView:_remove_last_spawn()
	if not self:_can_edit() then
		return
	end

	local path_wave = self:_selected_path_wave(false)
	if path_wave and #path_wave.spawns > 0 then
		table.remove(path_wave.spawns)
		self:_rebuild_spawn_list()
	end
end

function WaveEditorView:_open_enemy_picker(spawn_index)
	if not self:_can_edit() then
		return
	end
	local path_wave = self:_selected_path_wave(false)
	local spawn = path_wave and path_wave.spawns[spawn_index]
	if not spawn then
		return
	end

	if self.enemy_picker then
		self:remove_child(self.enemy_picker)
		self.enemy_picker:destroy()
	end

	self.enemy_picker = EnemyPickerView:new(self.sw, self.sh, spawn.creep, function(enemy_name)
		spawn.creep = enemy_name
		self:_rebuild_spawn_list()
	end)
	self:add_child(self.enemy_picker)
	self.enemy_picker:show()
end

function WaveEditorView:_create_from_source()
	if not self.level_idx or not Store.source_exists(self.level_idx, self.mode) then
		self:_set_status("Màn hoặc chế độ hiện tại không có mẫu gốc.")
		return
	end

	local id, document = Store.create_from_source(self.level_idx, self.mode)
	if not id then
		self:_set_status("Tạo từ mẫu gốc thất bại: " .. tostring(document))
		return
	end

	self.current_list_id = id
	self.wave = document.wave
	self.group_idx = 1
	self.path_idx = 1
	self.path_count = Store.path_count(self.level_idx, self.wave)
	self:_refresh_right()
	self:_set_status(string.format("Đã tạo và bật danh sách đợt quái tùy chỉnh %d.", id), true)
end

function WaveEditorView:_save_current()
	if not self:_can_edit() then
		return
	end

	local ok, refreshed_wave = Store.update_list(self.current_list_id, self.wave)

	if ok then
		self.wave = refreshed_wave or self.wave
		self:_refresh_right()
		self:_set_status(string.format("Đã lưu danh sách quái tùy chỉnh %d", self.current_list_id), true)
	else
		self:_set_status("Không thể lưu.")
	end
end

function WaveEditorView:_delete_current_list()
	local id = self.current_list_id

	if not id then
		self:_set_status("Không có mẫu đợt quái tùy chỉnh nào để xóa.")
		return
	end

	local ok, err = Store.delete_list(id)

	if not ok then
		self:_set_status("Xóa thất bại: " .. tostring(err or "unknown"))
		return
	end

	self.current_list_id = nil
	self.group_idx = 1
	self.path_idx = 1
	self:_load_context(true)
	self:_set_status(string.format("Đã xóa danh sách đợt quái tùy chỉnh %d.", id), true)
end

function WaveEditorView:show()
	WaveEditorView.super.show(self)
	self:_load_context(true)
end

function WaveEditorView:hide()
	if self.numeric_input then
		self.numeric_input:_dismiss()
		return
	end
	if self.enemy_picker and not self.enemy_picker.hidden then
		self.enemy_picker:hide()
		return
	end
	local return_view = self.return_view

	self.return_view = nil
	WaveEditorView.super.hide(self)

	if return_view then
		return_view:show()
	end
end

return WaveEditorView
