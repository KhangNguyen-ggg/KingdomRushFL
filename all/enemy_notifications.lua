local M = {}

local function translated(key)
	local value = _(key)
	return value ~= key and value ~= "" and value or nil
end

local function loaded(images, name)
	local sprite = name and images.db_atlas[name]
	local atlas = sprite and images.db_images[sprite.atlas]
	return atlas and atlas[1] and name or nil
end

function M.prepare(entity, images, notifications)
	if not entity.enemy or entity.soldier or entity.hero or not entity.health or entity.health.dead then return end
	local id = entity.template_name
	local old = notifications[id]
	if old and not old.enemy_card and loaded(images, old.icon) and loaded(images, old.image) then return old end
	local info = entity.info or {}
	local prefix = info.i18n_key or string.upper(id)
	local title = translated(prefix .. "_NAME") or translated(prefix)
	if not title then
		title = id:gsub("^enemy_", ""):gsub("_", " ")
		title = title:gsub("^%l", string.upper)
	end
	local image = loaded(images, info.portrait) or loaded(images, info.portrait_boss)
	if not image then
		local animations = require("animation_db")
		for _, sprite in ipairs(entity.render and entity.render.sprites or {}) do
			if not sprite.hidden and not (sprite.name or ""):find("shadow") then
				local key = sprite.name and (sprite.prefix and sprite.prefix .. "_" .. sprite.name or sprite.name)
				image = loaded(images, key)
				if not image and key and animations:has_animation(key) then
					image = loaded(images, animations:fn(key, 0, true))
				end
				if image then break end
			end
		end
	end
	-- shortcut: skeletal enemies without a loaded portrait use the generic emblem until portrait assets are provided.
	image = image or loaded(images, "alert_tip_notxt_0005")
	local icon = loaded(images, "notifications_polaroid_overlay")
	if not icon then return end
	local hp = type(entity.health.hp_max) == "number" and entity.health.hp_max or 0
	local description = translated(prefix .. "_DESCRIPTION") or translated(prefix .. "_EXTRA") or "Kẻ địch vừa xuất hiện trên chiến trường."
	local extra = string.format("Máu: %s\nGiáp: %d%%   Kháng phép: %d%%", tostring(math.floor(hp)), math.floor((entity.health.armor or 0) * 100 + 0.5), math.floor((entity.health.magic_armor or 0) * 100 + 0.5))
	local n = {layout = N_ENEMY, image = image, icon = icon, enemy_card = {title = title, description = description, extra = extra}}
	notifications[id] = n
	return n
end

return M
