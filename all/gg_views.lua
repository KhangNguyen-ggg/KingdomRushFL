-- chunkname: @./all/gg_views.lua

local log = require("klua.log"):new("gg_views")

require("klove.kui")
require("klua.table")

local V = require("klua.vector")
local class = require("middleclass")
local km = require("klua.macros")
local F = require("klove.font_db")
local G = love.graphics
local I = require("klove.image_db")
local S = require("sound_db")
local GU = require("gui_utils_5")
local EXO = require("exoskeleton")

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

GGLabel = class("GGLabel", KLabel)

GGLabel:append_serialize_keys("text_key", "text_shadow", "text_shadow_offset", "fit_lines", "fit_step", "fit_size", "vertical_align")

GGLabel.static.serialize_children = false
GGLabel.static.font_scale = 1
GGLabel.static.ref_h = REF_H
GGLabel.static.mobile_font_factor = 1

-- Android can optionally render regular interface text at 1.2x.  Keep the
-- choice in settings.lua so it applies to every screen, including the slot
-- screen which is created before the map options panel is available.
if IS_ANDROID then
	local ok_storage, storage = pcall(require, "storage")

	if ok_storage and storage then
		local ok_settings, settings = pcall(storage.load_settings, storage)

		if ok_settings and settings and tonumber(settings.mobile_font_scale) == 1.2 then
			GGLabel.static.mobile_font_factor = 1.2
		end
	end
end

GGLabel:include(KMLocaleOverrides)

function GGLabel:initialize(size, image_name)
	self.font_name = nil
	self.font_size = nil
	self.text_key = nil
	self.text_shadow = nil
	self.text_shadow_offset = V.v(1, 1)
	self.text_runs = nil
	self.fit_lines = nil
	self.fit_step = 0.5
	self._font_scale = GGLabel.static.font_scale
	self._ref_h = GGLabel.static.ref_h

	KLabel.initialize(self, size, image_name)

	if not self.colors.text_shadow then
		self.colors.text_shadow = {
			0,
			0,
			0,
			255
		}
	end

	if DEBUG_GG_SHOW_BG then
		self.colors.background = {
			255,
			0,
			0,
			100
		}
	end

	if self.text_key then
		self.text = _(self.text_key)
	end

	self._fitted_font = nil
	self._fitted_lines = nil
	self._fitted_text = nil
end

function GGLabel:_load_font()
	local font_size = self._fitted_font_size or self.font_size
	local mobile_font_factor = rawget(self, "mobile_font_factor")

	if mobile_font_factor == nil then
		mobile_font_factor = GGLabel.static.mobile_font_factor or 1
	end

	local rendered_font_size = font_size and font_size * mobile_font_factor

	if not self.font or self._loaded_font_name ~= self.font_name or self._loaded_font_size ~= rendered_font_size then
		self._fitted_font = nil
		self._loaded_font_name = self.font_name
		self._loaded_font_size = rendered_font_size

		if self.font_name and self.font_size then
			self.font = F:f(self.font_name, rendered_font_size * self._font_scale)
			self.font_adj = F:f_adj(self.font_name, rendered_font_size * self._font_scale)
		else
			log.debug("Font not specified for %s", self)

			self.font = G:getFont()
			self.font_adj = {
				size = 1
			}
		end
	end
end

function GGLabel:_fit_text()
	local font_size = self.font_size
	local fit_lines = self.fit_lines
	local fit_size = self.fit_size
	local step = self.fit_step

	if not fit_lines and not fit_size then
		return
	end

	if self._fitted_font ~= self.font or self._fitted_starting_font_size ~= font_size or self._fitted_lines ~= self.fit_lines or self._fitted_fit_size ~= self.fit_size or self._fitted_step ~= self.fit_step or self._fitted_size ~= self.text_size or self._fitted_text ~= self.text then
		self.font = nil
		self._fitted_font_size = nil

		while font_size >= 1 do
			local w, lines = self:get_wrap_lines()

			if fit_lines and lines <= fit_lines then
				break
			end

			local h = lines * self:get_font_height() * self.line_height

			if fit_size and h <= self.text_size.y then
				break
			end

			font_size = font_size - step
			self._fitted_font_size = font_size
			self.font = nil
		end

		if font_size < 1 then
			log.error("Could not fit label %s for text %s, size:%s,%s, lines:%s, fit_size:%s", self.id, self.text, self.text_size.x, self.text_size.y, fit_lines, fit_size)

			self._fitted_font_size = nil
		end

		self._fitted_starting_font_size = self.font_size
		self._fitted_font = self.font
		self._fitted_lines = self.fit_lines
		self._fitted_fit_size = self.fit_size
		self._fitted_step = self.fit_step
		self._fitted_size = self.text_size
		self._fitted_text = self.text
	end
end

function GGLabel:_draw_self()
	KLabel.super._draw_self(self)
	self:_load_font()
	self:_fit_text()

	local font_scale = self._font_scale or GGLabel.static.font_scale

	if self.font then
		G.setFont(self.font)
		self.font:setLineHeight(self.line_height)
	end

	local pr, pg, pb, pa = G.getColor()
	local voff = (self.font_adj.top or 0) / font_scale

	if self.vertical_align and self.vertical_align ~= "top" then
		local tw, tl = self:get_wrap_lines()
		local th = self:get_font_height()
		local des = -1 * self.font:getDescent() / font_scale
		local base = self.font:getBaseline() / font_scale

		if tl > 1 then
			th = th + (tl - 1) * self:get_font_height() * self.font:getLineHeight()
		end

		if self.vertical_align == "middle" then
			voff = math.floor((self.text_size.y - th) / 2)
		elseif self.vertical_align == "middle-caps" then
			voff = math.floor((self.text_size.y - th + des) / 2)
		elseif self.vertical_align == "bottom" then
			voff = self.text_size.y - th
		elseif self.vertical_align == "bottom-caps" then
			voff = self.text_size.y - th + des
		elseif self.vertical_align == "base" then
			voff = -base
		end

		local vadj = (self.font_adj[self.vertical_align] or 0) / font_scale

		voff = voff + vadj
	end

	if self.text_shadow then
		local tsc = self.colors.text_shadow
		local new_c = {
			tsc[1],
			tsc[2],
			tsc[3],
			tsc[4]
		}

		if not new_c[4] then
			new_c[4] = 255
		end

		new_c[4] = self.alpha * pa / 255 * new_c[4]

		G.setColor(new_c)

		local sox, soy = self.text_shadow_offset.x, self.text_shadow_offset.y

		G.printf(self.text, self.text_offset.x + sox, self.text_offset.y + soy + voff, self.text_size.x * font_scale, self.text_align, 0, 1 / font_scale)
	end

	if self.colors.text then
		local new_c = {
			self.colors.text[1],
			self.colors.text[2],
			self.colors.text[3],
			self.colors.text[4]
		}

		if not new_c[4] then
			new_c[4] = 255
		end

		if self.colors.tint then
			local tint_c = self.colors.tint

			new_c[1] = new_c[1] * tint_c[1] / 255
			new_c[2] = new_c[2] * tint_c[2] / 255
			new_c[3] = new_c[3] * tint_c[3] / 255
			new_c[4] = new_c[4] * tint_c[4] / 255
		end

		new_c[4] = self.alpha * pa / 255 * new_c[4]

		G.setColor(new_c)
	end

	local draw_text = self.text or " "

	if self.text_runs and #self.text_runs > 0 then
		local colored_text = {}

		for _, run in ipairs(self.text_runs) do
			local source_color = run.color or self.colors.text or {
				255,
				255,
				255,
				255
			}
			local run_color = {
				source_color[1] or 255,
				source_color[2] or 255,
				source_color[3] or 255,
				source_color[4] or 255
			}

			if self.colors.tint then
				local tint_c = self.colors.tint

				run_color[1] = run_color[1] * tint_c[1] / 255
				run_color[2] = run_color[2] * tint_c[2] / 255
				run_color[3] = run_color[3] * tint_c[3] / 255
				run_color[4] = run_color[4] * tint_c[4] / 255
			end

			run_color[4] = self.alpha * pa / 255 * run_color[4]

			for channel = 1, 4 do
				run_color[channel] = krflapk_color_channel(run_color[channel], 1)
			end

			table.insert(colored_text, run_color)
			table.insert(colored_text, run.text or "")
		end

		G.setColor(255, 255, 255, 255)
		draw_text = colored_text
	end

	G.printf(draw_text, self.text_offset.x, self.text_offset.y + voff, self.text_size.x * font_scale, self.text_align, 0, 1 / font_scale)
	G.setColor(pr, pg, pb, pa)
end

function GGLabel:get_wrap_lines()
	self:_load_font()

	local width, wrapped = self.font:getWrap(self.text or " ", self.text_size.x * self._font_scale)

	width = width / self._font_scale

	return width, #wrapped, wrapped
end

function GGLabel:get_font_height()
	self:_load_font()

	if self.font then
		return self.font:getHeight() / self._font_scale
	end

	return 0
end

function GGLabel:get_font_ascent()
	self:_load_font()

	if self.font then
		return self.font:getAscent() / self._font_scale
	end

	return 0
end

function GGLabel:get_font_descent()
	self:_load_font()

	if self.font then
		return self.font:getDescent() / self._font_scale
	end

	return 0
end

function GGLabel:get_font_baseline()
	self:_load_font()

	if self.font then
		return self.font:getBaseline() / self._font_scale
	end

	return 0
end

function GGLabel:get_fitted_font_size()
	return self._fitted_font_size or self.font_size
end

function GGLabel:get_text_width(text)
	self:_load_font()

	if self.font then
		return self.font:getWidth(text) / self._font_scale
	end

	return 0
end

function GGLabel:do_fit_lines(max_lines, start_size, step)
	self.fit_lines = max_lines or self.fit_lines
	self.font_size = start_size or self.font_size
	self.fit_step = step or self.fit_step
	self.font = nil

	self:_fit_text()

	if not self._fitted_font_size then
		return 0, 0
	else
		return self:get_wrap_lines()
	end
end

GGShaderLabel = class("GGShaderLabel", GGLabel)

GGShaderLabel:include(KMShaderDraw)

GGButton = class("GGButton", KImageButton)
GGButton.static.serialize_children = false
GGButton.static.label_keys = {
	"label_font_name",
	"label_font_size",
	"label_text_align",
	"label_vertical_align",
	"label_text",
	"label_text_key",
	"label_pos",
	"label_fit_size",
	"label_fit_lines",
	"label_shaders",
	"label_shader_args",
	"label_colors"
}

GGButton:append_serialize_keys(unpack(GGButton.static.label_keys))

function GGButton:initialize(default_image_name, hover_image_name, click_image_name)
	self.on_down_scale = 0.95

	KImageButton.initialize(self, default_image_name, hover_image_name, click_image_name)

	if not self.label_colors then
		self.label_colors = {
			default = {
				233,
				233,
				178,
				255
			},
			hover = {
				246,
				228,
				132,
				255
			}
		}
	end

	if not self._deserialize_table then
		self.anchor.x, self.anchor.y = self.size.x / 2, self.size.y / 2
	end

	local rs = GGLabel.static.ref_h / REF_H
	local label = GGShaderLabel:new(self.label_size or self.size)

	label.text = self.label_text_key and _(self.label_text_key) or self.label_text or ""
	label.text_key = self.label_text_key
	label.font_name = self.label_font_name or "button"
	label.font_size = self.label_font_size or 19 * rs
	label.text_align = self.label_text_align or "center"
	label.fit_size = self.label_fit_size
	label.fit_lines = self.label_fit_lines
	label.colors.text = self.label_colors.default
	label.pos = self.label_pos or V.v(0, 18 * rs)
	label.propagate_on_down = true
	label.propagate_on_up = true
	label.propagate_on_click = true
	label.shaders = self.label_shaders or {
		"p_glow"
	}
	label.shader_args = self.label_shader_args or {
		{
			glow_color = {
				0,
				0,
				0,
				1
			},
			thickness = 1.8 * rs
		}
	}
	label.vertical_align = self.label_vertical_align or "top"

	self:add_child(label)

	self.label = label
end

function GGButton:serialize(doing_template)
	for _, n in pairs(GGButton.static.label_keys) do
		if n == "label_colors" then
			-- block empty
		else
			local label_key = string.gsub(n, "label_", "")

			if self.label[label_key] then
				self[n] = self.label[label_key]
			end
		end
	end

	return GGButton.super.serialize(self, doing_template)
end

function GGButton:on_down(button, x, y)
	GGButton.super.on_down(self, button, x, y)

	if self.on_down_scale then
		self.original_scale = V.vclone(self.scale)
		self.scale.x, self.scale.y = self.scale.x * self.on_down_scale, self.scale.y * self.on_down_scale
	end
end

function GGButton:on_up(button, x, y)
	GGButton.super.on_up(self, button, x, y)

	if self.on_down_scale and self.original_scale then
		self.scale = self.original_scale
	end
end

function GGButton:on_enter(drag_view)
	GGButton.super.on_enter(self, drag_view)

	self.label.colors.text = self.label_colors.hover
	self.label.canvases_drawn = nil
end

function GGButton:on_exit(drag_view)
	GGButton.super.on_exit(self, drag_view)

	self.label.colors.text = self.label_colors.default
	self.label.canvases_drawn = nil

	if self.on_down_scale and self.original_scale then
		self.scale = self.original_scale
	end
end

function GGButton:disable(tint, color)
	GGButton.super.disable(self, tint, color)

	self.label.canvases_drawn = nil
end

function GGButton:enable()
	GGButton.super.enable(self)

	self.label.canvases_drawn = nil
end

GGImageButton = class("GGImageButton", GGLabel)

GGImageButton:append_serialize_keys("default_image_name", "hover_image_name", "click_image_name", "down_scale")

GGImageButton.static.init_arg_names = {
	"default_image_name",
	"hover_image_name",
	"click_image_name"
}

function GGImageButton:initialize(default_image_name, hover_image_name, click_image_name)
	log.paranoid("GGImageButton:initialize %s", self.id)

	self.highlighted = false
	self.default_image_name = default_image_name
	self.hover_image_name = hover_image_name or default_image_name
	self.click_image_name = click_image_name or hover_image_name or default_image_name
	self.down_scale = nil

	GGLabel.initialize(self, nil, default_image_name)
end

function GGImageButton:on_enter(drag_view)
	log.paranoid("GGImageButton:on_enter %s", self.id)

	if self.image_name == self.click_image_name then
		return
	end

	self:set_image(self.hover_image_name)
end

function GGImageButton:on_exit(drag_view)
	log.paranoid("GGImageButton:on_exit %s", self.id)
	self:set_image(self.default_image_name)

	if self.down_scale then
		self.scale.x, self.scale.y = 1, 1
	end
end

function GGImageButton:on_down(button, x, y)
	log.paranoid("GGImageButton:on_down %s", self.id)
	self:set_image(self.click_image_name)

	if self.down_scale then
		self.scale.x, self.scale.y = self.down_scale, self.down_scale
	end
end

function GGImageButton:on_up(button, x, y)
	log.paranoid("GGImageButton:on_up %s", self.id)
	self:set_image(self.hover_image_name)

	if self.down_scale then
		self.scale.x, self.scale.y = 1, 1
	end
end

function GGImageButton:on_focus()
	log.paranoid("GGImageButton:on_focus %s", self.id)
	self:on_enter()
end

function GGImageButton:on_defocus()
	log.paranoid("GGImageButton:on_defocus %s", self.id)
	self:on_exit()
end

GGToggleButton = class("GGToggleButton", GGLabel)

GGToggleButton:append_serialize_keys("true_image_name", "false_image_name", "down_scale")

GGToggleButton.static.init_arg_names = {
	"true_image_name",
	"false_image_name"
}

function GGToggleButton:initialize(true_image_name, false_image_name)
	self.value = true
	self.true_image_name = true_image_name
	self.false_image_name = false_image_name
	self.down_scale = nil

	GGLabel.initialize(self, nil, true_image_name)

	self.propagate_on_up = false
	self.propagate_on_down = false
	self.propagate_on_click = false
	self.propagate_on_touch_down = false
	self.propagate_on_touch_up = false
	self.propagate_on_touch_move = false
end

function GGToggleButton:on_down(button, x, y)
	self:set_value(not self.value)

	if self.down_scale then
		self.scale.x, self.scale.y = self.down_scale, self.down_scale
	end
end

function GGToggleButton:on_up(button, x, y)
	if self.down_scale then
		self.scale.x, self.scale.y = 1, 1
	end
end

function GGToggleButton:on_exit(drag_view)
	if self.down_scale then
		self.scale.x, self.scale.y = 1, 1
	end
end

function GGToggleButton:set_value(value)
	self.value = value

	if value then
		self:set_image(self.true_image_name)
	else
		self:set_image(self.false_image_name)
	end

	if self.on_change then
		self:on_change(value)
	end
end


GGAni = class("GGAni", KView)

function GGAni:initialize(size, image_name)
	GGAni.super.initialize(self, size, image_name)

	self.mute_sounds = nil
	self.mute_events = nil
	self.last_frame = 0
end

function GGAni:update(dt)
	GGAni.super.update(self, dt)

	local fps = self.fps or FPS
	local frame = math.ceil(self.ts * fps)
	local last_frame = self.last_frame

	if frame ~= last_frame and self.animation and self.animation.frames then
		self.last_frame = frame

		local ani_len = #self.animation.frames
		local frame_offset

		if self.loop then
			frame_offset = km.zmod(frame, ani_len)
		else
			frame_offset = km.clamp(1, ani_len, frame) - 1
		end

		local wrapped_frame = self.animation.from + frame_offset

		if not self.hidden and self.sounds and not self.mute_sounds and self.on_sound then
			for _, row in pairs(self.sounds) do
				if row.f == wrapped_frame then
					self:on_sound(row.name, wrapped_frame)
				end
			end
		end

		if self.events and not self.mute_events and self.on_event then
			for _, row in pairs(self.events) do
				if row.f == wrapped_frame then
					self:on_event(row.name, wrapped_frame)
				end
			end
		end

		if not self.loop and self.cb_finish and self.animation and self.animation.to and self.animation.to + 1 == frame then
			log.paranoid("id:%s calling callback:%s", self.id, self.cb_finish)
			self.cb_finish(self)
		end
	end
end

function GGAni:on_sound(name, frame)
	if not self.mute_sounds then
		log.debug("id:%s sound:%s frame:%s", self.id, name, frame)
		S:queue(name)
	end
end

function GGAni:on_event(name, frame)
	if not self.mute_events then
		log.debug("id:%s event:%s frame:%s", self.id, name, frame)
	end
end

function GGAni:start_animation(name, force_ts, cb_finish)
	if not self.animations or not self.animations[name] then
		log.error("id:%s animation not found:%s", self.id, name)

		return
	end

	log.paranoid("id:%s start_animation(%s, %s, %s)", self.id, name, force_ts, cb_finish)

	self.animation.frames = nil
	self.animation.from = self.animations[name].from
	self.animation.to = self.animations[name].to
	self.ts = force_ts or 0
	self.last_frame = 0
	self.cb_finish = cb_finish
end

GGTimeline = class("GGTimeline", KView)

function GGTimeline:initialize(size)
	KView.initialize(self, size)

	self.propagate_on_click = true
	self.propagate_on_down = true
	self.propagate_on_up = true
	self.enable_canvas_caching = nil

	if not self.timeline then
		log.error("timeline property missing")

		return
	end

	table.sort(self.timeline, function(e1, e2)
		return e1.f < e2.f
	end)

	if self.sequences then
		for _, r in ipairs(self.sequences) do
			self.sequences[r.name] = r
		end
	end

	self:reset()
end

function GGTimeline:reset()
	for _, c in pairs(self.children) do
		c.hidden = true
	end

	self.ts = 0
	self.paused = true
	self.last_frame = 0

	for _, row in pairs(self.timeline) do
		if row.f <= 1 then
			self:do_row(row, 0)
		end
	end

	self.sequence = nil
	self._cached_canvas_requested = nil
	self._cached_canvas = nil
	self.image = nil
end

function GGTimeline:start(name)
	self:reset()
	self.paused = false

	if not name then
		return
	end

	local sequence = self.sequences and self.sequences[name]

	if not sequence then
		log.error("sequence named %s not found in timeline %s", name, self.id)

		return
	end

	self.sequence = sequence

	local fps = self.fps or FPS
	local dt = 1 / fps
	local stime = dt * sequence.from

	self:update(stime, true)
end

function GGTimeline:jump(time, pause)
	self:reset()
	self.paused = false
	self:update(time, true)
	self.paused = pause
end

function GGTimeline:_draw_children()
	if self._cached_canvas then
		return
	end

	GGTimeline.super._draw_children(self)
end

function GGTimeline:draw()
	if self.hidden then
		return
	end

	if self._cached_canvas_requested then
		self._cached_canvas_requested = nil
		self.image = nil

		local cr = self:get_bounds_rect()
		local cw, ch = math.ceil(cr.size.x), math.ceil(cr.size.y)

		if cw <= 0 or ch <= 0 then
			log.error("bounds for %s are 0. skipping cached canvas request ", self.id)
			log.error("  image_ss:%s", getdump(self.image_ss))
			log.error("  bounds:%s", getfulldump(cr))
		else
			log.debug("GGTimeline - caching canvas for %s", self.id)

			local cached_canvas = G.newCanvas(cw, ch)
			local pr, pg, pb, pa = G.getColor()
			local scx, scy, scw, sch = G.getScissor()

			G.setColor(255, 255, 255, 255)
			G.push()
			G.setCanvas(cached_canvas)
			G.setScissor()
			G.origin()

			local dx, dy = self.pos.x - cr.pos.x, self.pos.y - cr.pos.y

			G.translate(dx, dy)
			self:_draw_self()
			self:_draw_children()
			G.setCanvas()
			G.pop()
			G.setScissor(scx, scy, scw, sch)
			G.setColor(pr, pg, pb, pa)
			self:set_image(cached_canvas)

			self._cached_canvas = cached_canvas
			self.image_offset = V.v(-dx, -dy)

			return
		end
	end

	GGTimeline.super.draw(self)
end

function GGTimeline:update(dt, jumping)
	if self.paused then
		if not jumping and not self.hidden and self.enable_canvas_caching and not self._cached_canvas and not self.sequence then
			self._cached_canvas_requested = true
		end

		return
	end

	local fps = self.fps or FPS

	self.ts = self.ts + dt

	local frame = math.ceil(self.ts * fps)
	local ts_offset = self.ts - (frame - 1) / fps

	if self.play == "loop" then
		frame = km.zmod(frame, self.frame_duration)

		if frame < self.last_frame then
			self.last_frame = 0
		end
	else
		if jumping then
			frame = km.clamp(1, self.frame_duration, frame)
		end

		if self.sequence then
			frame = km.clamp(1, self.sequence.to, frame)
		end
	end

	local changed_ids = {}

	for i, row in ipairs(self.timeline) do
		if row.f > self.last_frame and frame >= row.f then
			local next_row

			if row.ease then
				for j = i + 1, #self.timeline do
					if self.timeline[j] and self.timeline[j].id == row.id then
						next_row = self.timeline[j]

						break
					end
				end
			end

			self:do_row(row, (frame - row.f) / fps + ts_offset, next_row)
			table.insert(changed_ids, row.id)
		end
	end

	self.last_frame = frame

	for _, c in pairs(self.children) do
		c:update(table.contains(changed_ids, c.id) and 0 or dt)

		if not c.hidden and frame <= self.frame_duration and c.frame_duration then
			local cframe = math.ceil(c.ts * fps)

			if self.play ~= "loop" and not self.sequence then
				c.hidden = cframe > c.frame_duration
			end
		end
	end

	if self.enable_canvas_caching and not jumping and not self.hidden and not self.sequence and self.play ~= "loop" and frame > 1.5 * self.frame_duration then
		self.paused = true
	end
end

function GGTimeline:do_row(row, ts, next_row)
	local view = self:ci(row.id)

	if not view then
		log.error("could not find view with id %s", row.id)

		return
	end

	local ktw

	if self:get_window() then
		ktw = self:get_window().ktw

		if ktw then
			ktw:cancel(view)
		end
	end

	view.hidden = row.hidden or false

	if row.pos then
		view.pos.x, view.pos.y = row.pos.x, row.pos.y
	end

	if row.scale then
		view.scale = view.scale or V.v(0, 0)
		view.scale.x, view.scale.y = row.scale.x, row.scale.y
	elseif view.scale then
		view.scale.x, view.scale.y = 1, 1
	else
		view.scale = V.v(1, 1)
	end

	if row.r then
		view.r = row.r
	end

	view.alpha = row.alpha or 1

	if row.frame_duration then
		view.frame_duration = row.frame_duration
	end

	ts = ts or 0

	if view.frame_duration then
		local duration = view.frame_duration / (self.fps or FPS)

		if row.play == "loop" then
			view.ts = ts % duration
		else
			view.ts = km.clamp(0, duration, ts)
		end

		if row.ease and next_row and duration > view.ts then
			local props = {}

			if row.pos and next_row.pos and (row.pos.x ~= next_row.pos.x or row.pos.y ~= next_row.pos.y) then
				props.pos = {
					x = next_row.pos.x,
					y = next_row.pos.y
				}
			end

			if row.scale ~= next_row.scale then
				local nx = next_row.scale and next_row.scale.x or 1
				local ny = next_row.scale and next_row.scale.y or 1

				props.scale = {
					x = nx,
					y = ny
				}
			end

			if row.r ~= next_row.r then
				props.r = next_row.r or 0
			end

			if row.alpha ~= next_row.alpha then
				props.alpha = next_row.alpha or 1
			end

			local etype = "linear"

			if math.abs(row.ease) > 30 then
				etype = "quad"
			elseif math.abs(row.ease) > 50 then
				etype = "cubic"
			elseif math.abs(row.ease) > 70 then
				etype = "quart"
			end

			local edir = row.ease < 0 and "in" or "out"
			local method = edir .. "-" .. etype
			local len = duration - view.ts

			if ktw then
				ktw:cancel(view)
				ktw:tween(view, len, view, props, method)
			end
		end
	else
		view.ts = ts
	end

	local function apply_ani(target, target_ts)
		if target.animation then
			if row.play then
				target.loop = row.play == "loop"
				target.animation.frames = nil
				target.animation.from = row.a_from or 1

				if row.play == "once" then
					target.animation.to = row.a_to or 1
				elseif row.play == "single" then
					target.animation.to = row.a_from or 1
				end
			end

			target.ts = target_ts
		end
	end

	if view.animation then
		apply_ani(view, view.ts)
	elseif view.children then
		for _, c in pairs(view.children) do
			apply_ani(c, view.ts)
		end
	end
end

GG9SlicesView = class("GG9SlicesView", KView)

GG9SlicesView:append_serialize_keys("slices_prefix", "direction")

GG9SlicesView.static.init_arg_names = {
	"size",
	"slices_prefix",
	"direction"
}
GG9SlicesView.static.image_suffixes = {
	"lt",
	"ct",
	"rt",
	"lc",
	"cc",
	"rc",
	"lb",
	"cb",
	"rb"
}
GG9SlicesView.static.image_suffixes_miss_map = {
	rt = {
		"lt",
		-1,
		1
	},
	rc = {
		"lc",
		-1,
		1
	},
	lb = {
		"lt",
		1,
		-1
	},
	cb = {
		"ct",
		1,
		-1
	},
	rb = {
		"lt",
		-1,
		-1
	}
}

function GG9SlicesView:initialize(size, slices_prefix, direction)
	if not slices_prefix or type(slices_prefix) ~= "string" then
		log.error("No slices_prefix or not a string. View not created")

		return nil
	end

	if not size then
		log.error("No size. View not created")

		return nil
	end

	local i1 = I:s(slices_prefix .. "_lt")
	local i2 = I:s(slices_prefix .. (direction == "v" and "_lc" or direction == "h" and "_ct" or "_cc"))
	local i3 = I:s(slices_prefix .. (direction == "v" and "_lb" or direction == "h" and "_rt" or "_rb"), true)

	i3 = i3 or i1

	if not i1 or not i2 or not i3 then
		log.error("On or more slices with prefix %s not found in database", slices_prefix)

		return nil
	end

	local ref_scale = i1.ref_scale or 1
	local mid_count_x, mid_count_y = 0, 0

	if size.x / ref_scale > i1.size[1] + i3.size[1] then
		mid_count_x = math.ceil((size.x / ref_scale - (i1.size[1] + i3.size[1])) / i2.size[1])
	end

	if size.y / ref_scale > i1.size[2] + i3.size[2] then
		mid_count_y = math.ceil((size.y / ref_scale - (i1.size[2] + i3.size[2])) / i2.size[2])
	end

	local count_x, count_y = mid_count_x + 2, mid_count_y + 2
	local cw = i1.size[1] + i3.size[1] + mid_count_x * i2.size[1]
	local ch = i1.size[2] + i3.size[2] + mid_count_y * i2.size[2]

	if direction == "v" then
		cw = i1.size[1]
		count_x = 1
	elseif direction == "h" then
		ch = i1.size[2]
		count_y = 1
	end

	local canvas = G.newCanvas(cw, ch)
	local pr, pg, pb, pa = G.getColor()

	G.setColor(255, 255, 255, 255)

	local scx, scy, scw, sch = G.getScissor()

	G.push()
	G.setCanvas(canvas)
	G.setScissor()
	G.origin()

	local suff = GG9SlicesView.static.image_suffixes
	local miss_suff = GG9SlicesView.static.image_suffixes_miss_map
	local lw, lh = 0, 0
	local ox, oy = 0, 0

	for i = 1, count_x do
		local si = i == 1 and 1 or i == count_x and 3 or 2

		oy = 0

		for j = 1, count_y do
			local sj = j == 1 and 0 or j == count_y and 6 or 3
			local sox, soy, scale_x, scale_y = 0, 0, 1, 1
			local sn = slices_prefix .. "_" .. suff[si + sj]
			local iss = I:s(sn, true)

			if not iss then
				local ms = miss_suff[suff[si + sj]]

				sn = slices_prefix .. "_" .. ms[1]
				iss = I:s(sn)

				if not iss then
					log.error("Could not find slice image %s with suffix %s", slices_prefix, ms[1])

					return nil
				end

				scale_x, scale_y = ms[2], ms[3]
				sox, soy = scale_x == -1 and iss.size[1] or 0, scale_y == -1 and iss.size[2] or 0
			end

			local ti = I:i(iss.atlas)

			lw, lh = iss.size[1], iss.size[2]

			G.push()
			G.translate(ox, oy)
			--G.draw(ti, iss.quad, iss.trim[1] * scale_x, iss.trim[2] * scale_y, 0, scale_x, scale_y, sox, soy)
			if iss.textureRotated then
				sox = iss.f_quad[4]
				soy = scale_y == -1 and iss.f_quad[3] or 0
				G.draw(ti, iss.quad, iss.trim[1] * scale_y, iss.trim[2] * scale_x, - math.pi / 2, scale_y, scale_x, sox, soy)
			else
				G.draw(ti, iss.quad, iss.trim[1] * scale_x, iss.trim[2] * scale_y, 0, scale_x, scale_y, sox, soy)
			end
			G.pop()

			oy = oy + lh
		end

		ox = ox + lw
	end

	G.pop()
	G.setScissor(scx, scy, scw, sch)
	G.setCanvas()
	G.setColor(pr, pg, pb, pa)

	local view_size = V.v(canvas:getDimensions())

	view_size.x, view_size.y = view_size.x * ref_scale, view_size.y * ref_scale

	KView.initialize(self, view_size, canvas)

	self.size = view_size
	self.image_scale = ref_scale
end

GG5BalloonView = class("GG5BalloonView", KView)

function GG5BalloonView:initialize(max_size, prefix, flags, text, title, text_padding, text_separation, background_color, text_color, line_color, title_color)
	max_size = max_size or V.v(256, 0)
	prefix = prefix or "balloon_map_slices"
	flags = flags or ""
	text = text or ""

	local function has_flag(value)
		return string.find(flags, value, 1, true) ~= nil
	end

	local padding = text_padding or V.v(10, 10)
	local separation = text_separation or 0
	local title_font_size = has_flag("small_title") and 22 or has_flag("large_font") and 34 or 30
	local text_font_size = has_flag("dialog") and 17 or has_flag("large_font") and 34 or 28
	local text_align = has_flag("centered") and "center" or "left"
	local fit_lines = has_flag("one_line") and 1 or nil

	text_color = text_color or (has_flag("yellow_text") and {
		255,
		255,
		0,
		255
	} or {
		70,
		56,
		47,
		255
	})
	title_color = title_color or {
		16,
		101,
		161,
		255
	}
	background_color = background_color or {
		254,
		243,
		213,
		255
	}
	line_color = line_color or {
		127,
		104,
		86,
		255
	}

	local title_label

	if title then
		title_label = GGLabel:new(max_size)
		title_label.text = title
		title_label.font_name = "body_bold"
		title_label.font_size = title_font_size
		title_label.text_align = text_align
		title_label.fit_lines = fit_lines
		title_label.line_height = 0.85
		title_label.colors.text = title_color
		title_label:_load_font()
		title_label:_fit_text()

		local width, count = title_label:get_wrap_lines()

		title_label.size.x = width
		title_label.size.y = math.ceil(count * title_label:get_font_height() * title_label.line_height)
	end

	local text_label = GGLabel:new(max_size)

	text_label.text = text
	text_label.font_name = "body"
	text_label.font_size = text_font_size
	text_label.text_align = text_align
	text_label.vertical_align = title and "top" or "middle"
	text_label.fit_lines = fit_lines
	text_label.line_height = 0.85
	text_label.colors.text = text_color
	text_label:_load_font()
	text_label:_fit_text()

	local text_width, text_count = text_label:get_wrap_lines()

	text_label.size.x = text_width
	text_label.size.y = math.ceil(text_count * text_label:get_font_height() * text_label.line_height)

	local block_width = math.max(title_label and title_label.size.x or 0, text_label.size.x)
	local block_height = (title_label and title_label.size.y or 0) + (title_label and separation or 0) + text_label.size.y
	local block_size = V.v(block_width, block_height)

	if title_label then
		title_label.size.x = block_width
	end

	text_label.size.x = block_width
	KView.initialize(self, V.v(block_width + 2 * padding.x, block_height + 2 * padding.y))

	if has_flag("callout-") then
		local width, height = self.size.x, self.size.y
		local background = KView:new(V.v(width, height))
		local tip_offset = V.v(30, 0)
		local tip_size = 15

		if has_flag("side") then
			if has_flag("left") then
				background.scale.x = -1
				tip_offset.x = width
				self.anchor.x = -tip_size
			elseif has_flag("right") then
				tip_offset.x = width
				self.anchor.x = width + tip_size
			end

			if has_flag("top") then
				background.scale.y = -1
				tip_offset.y = height * 0.75
				self.anchor.y = height * 0.25
			elseif has_flag("bottom") then
				tip_offset.y = height * 0.75
				self.anchor.y = height * 0.75
			else
				tip_offset.y = height * 0.5
				self.anchor.y = height * 0.5
			end
		else
			if has_flag("left") then
				background.scale.x = -1
				tip_offset.x = width * 0.75
				self.anchor.x = width * 0.25
			elseif has_flag("right") then
				tip_offset.x = width * 0.75
				self.anchor.x = width * 0.75
			else
				tip_offset.x = width * 0.5
				self.anchor.x = width * 0.5
			end

			if has_flag("top") then
				background.scale.y = -1
				self.anchor.y = -tip_size
			elseif has_flag("bottom") then
				self.anchor.y = height + tip_size
			else
				self.anchor.y = height * 0.5
			end
		end

		local vertices = GU.rounded_rectangle(0, 0, width, height, 5, tip_offset, 1.6)

		background.colors.background = background_color
		background.shape = {
			name = "polygon",
			args = vertices
		}
		background.propagate_on_click = true
		background.anchor = V.v(width * 0.5, height * 0.5)
		background.pos = V.v(width * 0.5, height * 0.5)
		self:add_child(background)

		local border_vertices = table.clone(vertices)

		border_vertices[1] = "line"

		local border = KView:new(V.v(width, height))

		border.colors.background = line_color
		border.shape = {
			name = "polygon",
			args = border_vertices
		}
		border.propagate_on_click = true
		background:add_child(border)
	else
		local direction = has_flag("direction_v") and "v" or has_flag("direction_h") and "h" or nil
		local background = GG9SlicesView:new(self.size, prefix, direction)

		if background then
			self:add_child(background)
			self.size = V.v(background.size.x, background.size.y)
		end

		self.anchor.x = has_flag("left") and 0 or has_flag("right") and self.size.x or self.size.x * 0.5
		self.anchor.y = has_flag("top") and 0 or has_flag("bottom") and self.size.y or self.size.y * 0.5
	end

	local x_margin = math.floor((self.size.x - block_size.x) * 0.5)
	local y_margin = math.floor((self.size.y - block_size.y) * 0.5)

	if title_label then
		title_label.pos = V.v(x_margin, y_margin)
		text_label.pos = V.v(x_margin, y_margin + title_label.size.y + separation)
		self:add_child(title_label)
	else
		text_label.pos = V.v(x_margin, y_margin)
	end

	self:add_child(text_label)
end

GGLayout = class("GGLayout", KView)

GGLayout:append_serialize_keys("layout", "space")

GGLayout.static.init_arg_names = {
	"size",
	"layout",
	"space"
}

function GGLayout:initialize(size, layout, space)
	GGLayout.super.initialize(self, size)

	self.layout = layout or "top"
	self.space = space or 0

	self:update_layout()

	self.propagate_on_up = true
	self.propagate_on_down = true
	self.propagate_on_click = true
end

function GGLayout:update_layout()
	local x, y = 0, 0

	if self.layout == "top" then
		x, y = 0, 0

		for _, c in pairs(self.children) do
			if c:isInstanceOf(GGLabel) then
				c.size.x = self.size.x
				c.text_size.x = self.size.x

				c:_load_font()
				c:_fit_text()

				local w, l = c:get_wrap_lines()

				c.size.y = l * c:get_font_height() * c.line_height
				c.text_size.y = c.size.y
			end

			c.pos.y = y
			y = y + c.size.y + self.space
		end
	end
end

GGExoPlaceholder = class("GGExoPlaceholder", KView)

function GGExoPlaceholder:_draw_self()
	self.parent:_draw_self_deferred()
end

GGExo = class("GGExo", KView)

GGExo:append_serialize_keys("exo_name", "exo_animation", "exo_scale_factor")

GGExo.static.init_arg_names = {
	"size",
	"exo_name",
	"exo_animation",
	"exo_scale_factor"
}

function GGExo:initialize(size, exo_name, exo_animation, exo_scale_factor)
	KView.initialize(self, size)

	self.exo_name = exo_name
	self.exo_animation = exo_animation
	self.exo_scale_factor = exo_scale_factor
	self.runs = 0

	if not self.ts then
		self.ts = 0
	end

	self:load_exo()

	for _, c in pairs(self.children) do
		if c:isInstanceOf(GGExoPlaceholder) then
			self._defer_draw_to_placeholder = true

			break
		end
	end

	if #self.children > 0 and not self._defer_draw_to_placeholder then
		local ep = GGExoPlaceholder:new()

		self:add_child(ep, 1)
	end
end

function GGExo:destroy()
	EXO:unload(self.exo_name)
	self.batch = nil
	self._exo_frame = nil
	self.animations = nil
	GGExo.super.destroy(self)
end

function GGExo:load_exo()
	local anis, max_parts = EXO:load_kui(self.exo_name, true)

	self.animations = anis

	if KR_NATIVE then
		return
	end

	local temp_canvas = G.newCanvas(2, 2)

	self.batch = G.newSpriteBatch(temp_canvas, max_parts, "stream")
end

function GGExo:update(dt)
	if self.ts <= 0 then
		self.runs = 0
	end

	self.ts = self.ts + dt

	local aa_name = self.exo_name .. "_" .. self.exo_animation
	local aa = self.animations[aa_name]

	if not aa then
		log.error("Exo animation named %s could not be found in GGExo animations list %s", aa_name, getdump(self.animations))
		self._exo_frame = nil

		return
	end

	local fn, runs = self:animation_frame(aa, self.ts, self.loop, self.fps)
	local exo_frame = EXO:f(fn)

	self._exo_frame = exo_frame

	for _, c in pairs(self.children) do
		local x, y = self:get_attach_pos(c.exo_attach_point)

		if x and y then
			c.pos.x, c.pos.y = x, y
		end
	end

	if not self.loop and self.runs ~= runs and runs > 0 and self.on_exo_finished then
		self:on_exo_finished(runs)
	end

	self.runs = runs
end

function GGExo:get_attach_pos(name)
	if not self._exo_frame then
		return
	end

	local exo_frame = self._exo_frame
	local ap = exo_frame.attachPoints and exo_frame.attachPoints[name]
	local xf

	if ap then
		xf = ap.xform
	elseif exo_frame.exo and exo_frame.exo.attach_idx then
		local attach_idx = exo_frame.exo.attach_idx[name]

		xf = attach_idx and exo_frame.last_attach_point_xform and exo_frame.last_attach_point_xform[attach_idx]
	end

	if not xf then
		return
	end

	local x, y, r, sx, sy, kx, ky = xf.x, xf.y, xf.r, xf.sx, xf.sy, xf.kx, xf.ky

	r = -self.r + r

	if self.exo_scale_factor then
		local f = self.exo_scale_factor

		x = x * f
		y = y * f
	end

	return x, y
end

function GGExo:_draw_self()
	if self._defer_draw_to_placeholder then
		return
	else
		self:_draw_self_deferred()
	end
end

function GGExo:_draw_self_deferred()
	if KR_NATIVE then
		local cr, cg, cb = 255, 255, 255

		if self.colors.exo then
			cr, cg, cb = unpack(self.colors.exo)
		end

		if _V11 then
			cr, cg, cb = cr / 255, cg / 255, cb / 255
		end

		EXO:draw_frame_kui(self._exo_frame, self.exo_scale_factor or 1, cr, cg, cb, self.alpha or 1)

		return
	end

	local exo_frame = self._exo_frame

	if not exo_frame or not exo_frame.exo or not exo_frame.exo.parts or not self.batch then
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

		if part_type == 8 then
			exo_frame.last_attach_point_xform = exo_frame.last_attach_point_xform or {}
			exo_frame.last_attach_point_xform[part_name_idx] = {
				x = x,
				y = y,
				r = r,
				sx = sx,
				sy = sy,
				kx = kx,
				ky = ky
			}
		elseif (part_type == 1 or part_type == 2) and not part.hidden then
			local exo_part = exo_frame.exo.parts[part_name_idx]

			if exo_part then
				local part_name, pox, poy = unpack(exo_part)
				local ss = I:s(part_name)

				if ss and ss.atlas then
					if ss.atlas ~= current_atlas then
						if batch_count > 0 then
							G.draw(batch)

							batch_count = 0
							texture_swap_count = texture_swap_count + 1
						end

						batch:clear()
						lr, lg, lb, la = nil
						current_atlas = ss.atlas
						batch:setTexture(I:i(ss.atlas))
					end

					if self.colors.exo then
						local c = self.colors.exo

						cr, cg, cb = c[1], c[2], c[3]
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
	end

	if batch_count > 0 then
		G.draw(batch)
	end

	if texture_swap_count > 5 and not self._warning_shown then
		log.warning("GGExo: texture swapping count was %s for exo:%s. Try making texture group atlas size larger or do not use _MERGE fpr the exo subdirectory to improve fps", texture_swap_count, self.exo_name .. "_" .. self.exo_animation)

		self._warning_shown = true
	end
end

GGEllipseText = class("GGEllipseText", KView)
GGEllipseText.static.serialize_children = false

GGEllipseText:append_serialize_keys("text")

GGEllipseText.static.init_arg_names = {
	"size",
	"text"
}

function GGEllipseText:initialize(size, text)
	GGEllipseText.super.initialize(self, size, nil)

	self.ellipse_w = size.x
	self.ellipse_h = size.y
	self.max_angle = self.max_angle or math.pi / 2
	self.text = text

	if self.text_key then
		self.text = _(self.text_key)
	end

	self.colors.text = self.colors.text or {
		200,
		200,
		200,
		255
	}
end

function GGEllipseText:redraw()
	self:remove_children()

	self._drawn = true

	if not self.text or self.text == "" then
		return
	end

	local utf8 = require("utf8")
	local cv = {}
	local count = utf8.len(self.text)
	local color = self.colors.text
	local text_w = 0

	for i = 1, count do
		local o = utf8.offset(self.text, i)
		local l = GGLabel:new()

		self:add_child(l)

		cv[i] = l
		l.text = string.sub(self.text, utf8.offset(self.text, i), utf8.offset(self.text, i + 1) - 1)
		l.font_name = self.font_name
		l.font_size = self.font_size
		l.mobile_font_factor = rawget(self, "mobile_font_factor")

		l:_load_font()

		l.size.x = l:get_text_width(l.text)
		l.size.y = l:get_font_height()
		l.colors.text = color
		l.anchor.x = l.size.x / 2
		l.anchor.y = l.size.y * 2 / 3
		text_w = text_w + l.size.x
	end

	local so_x = (self.ellipse_w - text_w) / 2
	local o_x = so_x

	for i = 1, count do
		local l = cv[i]

		l.pos.x = o_x + l.size.x / 2
		l.pos.y = math.sin(l.pos.x / self.ellipse_w * math.pi) * self.ellipse_h

		local phase = (l.pos.x - so_x) / text_w

		l.r = -1 * (phase - 0.5) * self.max_angle
		o_x = o_x + l.size.x
	end
end

function GGEllipseText:_draw_self()
	if not self._drawn then
		self:redraw()
	end

	GGEllipseText.super._draw_self(self)
end
