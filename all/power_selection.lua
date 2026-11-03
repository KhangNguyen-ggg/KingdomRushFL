local UPGR = require("upgrades")
local generation_upgrades = require("generation_upgrades")
local power_upgrades_6 = require("power_upgrades_6")

local M = {}

local kr6_power_exoskeleton_groups = {
	royal_edict = {"go_power_royal_edict"},
	soaring_shop = {"go_power_soaring_shop"},
	aspect_of_sol = {"go_power_aspect_of_sol"},
	teleportation_sigil = {"go_power_teleportation_sigil"},
	thunder_zapper = {"go_power_thunder_zapper"},
	wintersongs_wrath = {"go_power_wintersongs_wrath"}
}

local function kr6_power_option(power_name, label, description, pointer_style, reinforcement)
	return {
		label = label,
		icon = "kr6_icon_room_power_" .. power_name,
		map_icon = "kr6_icon_room_power_" .. power_name,
		button_icon = "in_game_icon_power_" .. power_name,
		button_scale = 0.7,
		pointer_icon = "pointer_power_" .. power_name,
		pointer_scale = 0.8,
		pointer_style = pointer_style or "point",
		kind = reinforcement and "reinforcement" or "kr6_power",
		generation = 6,
		power_name = power_name,
		controller_name = reinforcement and "power_reinforcements_control_g6" or "power_" .. power_name .. "_control",
		description = description,
		required_textures = {"kr6_ui_icons", "go_power_" .. power_name},
		required_sounds = {"kr6_common_gameplay", "powers_" .. power_name},
		required_exoskeleton_groups = kr6_power_exoskeleton_groups[power_name]
	}
end

local item_required_exoskeletons = {
	portable_coil = {
		"item_portable_coilDef",
		"item_portable_coil_hitDef"
	},
	veznan_wrath = {
		"veznan_wrath_exoskeleton"
	}
}

M.order = {
	"empty_spell",
	"default_cataclysm",
	"default_reinforcement",
	"lightning_flash",
	"reinforcement_g1",
	"reinforcement_g2",
	"reinforcement_g3",
	"reinforcement_g4",
	"reinforcement_g5",
	"fireball_g1",
	"fireball_g2",
	"thunder_g3",
	"mermaid_gift",
	"yao_spirit_blessing",
	"shaosiyuan_fateful_bond",
	"item_cluster_bomb",
	"item_portable_coil",
	"item_scroll_of_spaceshift",
	"item_deaths_touch",
	"item_winter_age",
	"item_summon_blackburn",
	"item_loot_box",
	"item_medical_kit",
	"item_veznan_wrath",
	"kro_teleport_scroll",
	"kro_horn_heroism",
	"kro_gem_timewarp",
	"kro_rod_dragon_fire",
	"kro_hand_midas",
	"kro_wrath_of_elynia",
	"reinforcement_g6",
	"fireball_g6",
	"royal_edict_g6",
	"soaring_shop_g6",
	"aspect_of_sol_g6",
	"teleportation_sigil_g6",
	"thunder_zapper_g6",
	"wintersongs_wrath_g6",
	"musketeers_g6"
}

local function cheat_item_option(item_name, label, price, cooldown, effect, pointer_style, max_uses, controller_values)
	return {
		label = label,
		icon = "cheat_item_spell_" .. item_name,
		map_icon = "cheat_item_spell_" .. item_name,
		pointer_icon = "pointer_cheat_item_spell_" .. item_name,
		pointer_style = pointer_style,
		kind = "cheat_item",
		controller_name = "controller_item_" .. item_name,
		item_name = item_name,
		price = price,
		cooldown = cooldown,
		max_uses = max_uses,
		controller_values = controller_values,
		required_textures = {"go_items_" .. item_name},
		required_exoskeletons = item_required_exoskeletons[item_name],
		required_sounds = {"item_" .. item_name},
		description = string.format("%s Thời gian hồi: %i giây. %s", effect, cooldown,
			max_uses and string.format("Mỗi trận dùng tối đa %i lần.", max_uses) or "")
	}
end

local function kro_item_option(item_name, template_name, label, cooldown, effect, pointer_style, max_uses,
		required_textures, cast_sound, required_sounds)
	return {
		label = label,
		icon = "cheat_item_spell_kro_" .. item_name,
		map_icon = "cheat_item_spell_kro_" .. item_name,
		pointer_icon = "pointer_cheat_item_spell_kro_" .. item_name,
		pointer_style = pointer_style,
		kind = "cheat_item",
		controller_name = "user_item_" .. template_name,
		item_name = "kro_" .. item_name,
		cooldown = cooldown,
		max_uses = max_uses,
		required_textures = required_textures or {},
		cast_sound = cast_sound,
		required_sounds = required_sounds or {},
		description = string.format("%s Thời gian hồi: %i giây. %s", effect, cooldown,
			max_uses and string.format("Mỗi trận dùng tối đa %i lần.", max_uses) or "")
	}
end

M.options = {
	reinforcement_g1 = {
		label = "Viện quân phần 1",
		icon = "reinforcements_0001",
		map_icon = "spell_selection_icon_reinforcement",
		pointer_icon = "pointer_user_power_0002",
		pointer_style = "point",
		kind = "reinforcement",
		generation = 1,
		tech_upgrade = "reinforcements"
	},
	reinforcement_g2 = {
		label = "Viện quân phần 2",
		icon = "reinforcements_0001",
		map_icon = "spell_selection_icon_reinforcement",
		pointer_icon = "pointer_user_power_0002",
		pointer_style = "point",
		kind = "reinforcement",
		generation = 2,
		tech_upgrade = "reinforcements"
	},
	reinforcement_g3 = {
		label = "Viện quân phần 3",
		icon = "power_button_icons_0018",
		map_icon = "spell_selection_icon_reinforcement_g3",
		pointer_icon = "pointer_hero_power_0018",
		pointer_style = "point",
		kind = "reinforcement",
		generation = 3,
		tech_upgrade = "reinforcements"
	},
	reinforcement_g4 = {
		label = "Viện quân phần 4",
		icon = "reinforcements_0001",
		map_icon = "spell_selection_icon_reinforcement",
		pointer_icon = "pointer_user_power_0002",
		pointer_style = "point",
		kind = "reinforcement",
		generation = 4,
		tech_upgrade = "reinforcements",
		scale_required_textures = {"kr4_power_reinforcements"}
	},
	reinforcement_g5 = {
		label = "Viện quân phần 5",
		icon = "reinforcements_0001",
		map_icon = "spell_selection_icon_reinforcement",
		pointer_icon = "pointer_user_power_0002",
		pointer_style = "point",
		kind = "reinforcement",
		generation = 5,
		tech_upgrade = "reinforcements"
	},
	reinforcement_g6 = kr6_power_option("reinforcements", "Viện quân phần 6",
		"Triệu hồi hai đơn vị cận chiến hỗ trợ chiến đấu. Thời gian hồi cơ bản: 15 giây.", "point", true),
	fireball_g1 = {
		label = "Mưa lửa phần 1",
		icon = "fire_0001",
		map_icon = "spell_selection_icon_fire",
		pointer_icon = "pointer_user_power_0001",
		pointer_style = "area",
		kind = "fireball",
		generation = 1,
		tech_upgrade = "thunder"
	},
	fireball_g2 = {
		label = "Mưa lửa phần 2",
		icon = "fire_0001",
		map_icon = "spell_selection_icon_fire",
		pointer_icon = "pointer_user_power_0001",
		pointer_style = "area",
		kind = "fireball",
		generation = 2,
		tech_upgrade = "thunder"
	},
	thunder_g3 = {
		label = "Sấm sét phần 3",
		icon = "power_button_icons_0017",
		map_icon = "spell_selection_icon_thunder",
		pointer_icon = "pointer_hero_power_0017",
		pointer_style = "area",
		kind = "thunder",
		generation = 3,
		tech_upgrade = "thunder"
	},
	fireball_g6 = kr6_power_option("rain_of_fire", "Mưa lửa phần 6",
		"Gọi mưa thiên thạch phép đang bốc cháy, gây sát thương lớn lên kẻ địch trong vùng. Thời gian hồi cơ bản: 60 giây.", "area"),
	royal_edict_g6 = kr6_power_option("royal_edict", "Sắc lệnh hoàng gia",
		"Tăng sát thương cho các tháp xung quanh trong vài giây. Thời gian hồi cơ bản: 50 giây.", "area"),
	soaring_shop_g6 = kr6_power_option("soaring_shop", "Cửa hàng Gnome",
		"Triệu hồi một cửa hàng bay, ném thuốc nổ tấn công kẻ địch. Thời gian hồi cơ bản: 50 giây.", "point"),
	aspect_of_sol_g6 = kr6_power_option("aspect_of_sol", "Hiện thân Sol",
		"Triệu hồi hiện thân của Sol, vị thánh kỵ sĩ đầu tiên, để chiến đấu. Thời gian hồi cơ bản: 60 giây.", "point"),
	teleportation_sigil_g6 = kr6_power_option("teleportation_sigil", "Ấn dịch chuyển",
		"Dịch chuyển một số kẻ địch lùi về phía sau trên đường đi. Thời gian hồi cơ bản: 45 giây.", "area"),
	thunder_zapper_g6 = kr6_power_option("thunder_zapper", "Kỹ sư phóng điện",
		"Triệu hồi kỹ sư phóng điện tấn công kẻ địch đi ngang qua. Thời gian hồi cơ bản: 50 giây.", "point"),
	wintersongs_wrath_g6 = kr6_power_option("wintersongs_wrath", "Khúc ca cuồng nộ mùa đông",
		"Triệu hồi Elora dùng sức mạnh băng giá cản bước kẻ địch. Thời gian hồi cơ bản: 40 giây.", "area"),
	musketeers_g6 = kr6_power_option("musketeers", "Xạ thủ tinh nhuệ",
		"Triệu hồi một nhóm lính súng bắn kẻ địch. Thời gian hồi cơ bản: 20 giây.", "point"),
	lightning_flash = {
		label = "Sét Flash",
		icon = "lightning_0001",
		map_icon = "spell_selection_icon_flash",
		pointer_icon = "pointer_user_power_0003",
		pointer_style = "point",
		kind = "lightning",
		description = "Phép trả phí trong bản Flash của phần 1. Gây 666-999 sát thương chuẩn lên một mục tiêu. Thời gian hồi: 25 giây."
	},
	mermaid_gift = {
		label = "Phước lành tiên cá",
		icon = "dolia_mermaid_gift_0001",
		map_icon = "dolia_mermaid_gift_0001",
		pointer_icon = "pointer_dolia_mermaid_gift_0001",
		pointer_style = "point",
		kind = "mermaid_gift",
		cooldown = 30,
		description = "Lập tức hồi tất cả chiêu cuối anh hùng đang chờ hồi, đồng thời hồi máu và hồi sinh đồng đội trên toàn bản đồ; không tác động đến các phép khác. Nếu có nhiều chiêu cuối chủ động giống nhau, chỉ hồi chiêu có thời gian chờ dài nhất. Chỉ dùng được khi có chiêu cuối anh hùng đang chờ hồi. Thời gian hồi bằng 40 giây cộng 1.6 lần tổng thời gian hồi đã rút ngắn, tối đa 200 giây."
	},
	yao_spirit_blessing = {
		label = "Sừng sững trên đỉnh núi",
		icon = "yao_spell_icon_0001",
		map_icon = "yao_spell_icon_0001",
		pointer_icon = "pointer_yao_spell_0001",
		pointer_style = "point",
		kind = "global_support",
		controller_name = "controller_power_yao_spirit_blessing",
		cooldown = 70,
		revive_allies = true,
		cast_sound = "YaoSpellCast",
		required_textures = {"yao_spell_icon", "yao_spell_fx"},
		required_sounds = {"power_yao_spell"},
		description = "Hồi sinh toàn bộ đơn vị phe ta và cấp 200 khiên cho mọi đơn vị không bay. Câm lặng toàn bộ anh hùng phe địch, giảm 50% sức tấn công và xóa toàn bộ giáp vật lý lẫn kháng phép của chúng trong 14 giây. Thời gian hồi: 70 giây."
	},
	shaosiyuan_fateful_bond = {
		label = "Nhân duyên hội ngộ",
		icon = "shaosiyuan_spell_icon_0001",
		map_icon = "shaosiyuan_spell_icon_0001",
		pointer_icon = "pointer_shaosiyuan_spell_0001",
		pointer_style = "point",
		kind = "global_support",
		controller_name = "controller_power_shaosiyuan_fateful_bond",
		cooldown = 80,
		revive_allies = true,
		cast_sound = "ShaosiyuanSpellCast",
		required_textures = {"shaosiyuan_spell_icon", "shaosiyuan_spell_fx"},
		required_sounds = {"power_shaosiyuan_spell"},
		description = "Hồi sinh toàn bộ đơn vị phe ta. Trong 16 giây, đồng đội trên toàn bản đồ hồi 10% máu tối đa mỗi giây; mọi kẻ địch bị giảm 35% tốc độ di chuyển và chịu 6 sát thương chuẩn mỗi 0,5 giây. Cứ tác động đến 2 lính đồng minh hoặc 2 kẻ địch sẽ nhận 4 vàng. Thời gian hồi: 80 giây."
	},
	default_cataclysm = {
		label = "Phép tấn công mặc định",
		icon = "power_button_icons_0017",
		map_icon = "spell_selection_icon_thunder",
		pointer_icon = "pointer_hero_power_0017",
		pointer_style = "area",
		kind = "default_cataclysm",
		description = "Dùng phép tấn công mặc định của màn đang chơi. Phần 1/4 dùng Mưa lửa phần 1; phần 2 dùng Mưa lửa phần 2; phần 3/5 dùng Sấm sét phần 3; phần 6 dùng Mưa lửa phần 6."
	},
	default_reinforcement = {
		label = "Viện quân mặc định",
		icon = "reinforcements_0001",
		map_icon = "spell_selection_icon_reinforcement",
		pointer_icon = "pointer_user_power_0002",
		pointer_style = "point",
		kind = "reinforcement",
		default_generation = true,
		description = "Dùng viện quân mặc định của màn đang chơi."
	},
	empty_spell = {
		label = "Ô phép trống",
		icon = "spell_selection_icon_empty",
		map_icon = "spell_selection_icon_empty",
		pointer_icon = "spell_selection_icon_empty",
		pointer_style = "point",
		kind = "empty",
		description = "Không dùng ô phép này.",
		cooldown = 100
	},
	item_cluster_bomb = cheat_item_option("cluster_bomb", "Bom chùm", 50, 24,
		"Ném bom gây sát thương trong vùng rồi phân tách thành nhiều bom nhỏ xung quanh.", "area"),
	item_portable_coil = cheat_item_option("portable_coil", "Cuộn điện di động", 80, 24,
		"Đặt bẫy trên đường đi, gây sát thương và làm choáng kẻ địch kích hoạt bẫy. Hiệu ứng có thể lan sang kẻ địch gần đó.", "area"),
	item_scroll_of_spaceshift = cheat_item_option("scroll_of_spaceshift", "Cuộn dịch chuyển không gian", 150, 30,
		"Dịch chuyển tối đa 10 kẻ địch trong vùng lùi về phía sau trên đường đi.", "area"),
	item_deaths_touch = cheat_item_option("deaths_touch", "Cái chạm tử thần", 300, 90,
		"Nhấn vào kẻ địch để tiêu diệt ngay; gây sát thương chuẩn lớn lên trùm.", "point"),
	item_winter_age = cheat_item_option("winter_age", "Mùa đông đã đến", 350, 75,
		"Đóng băng tất cả kẻ địch có thể bị ảnh hưởng trên chiến trường.", "area"),
	item_summon_blackburn = cheat_item_option("summon_blackburn", "Mũ Blackburn", 600, 108,
		"Triệu hồi Lãnh chúa Blackburn hỗ trợ chiến đấu trên đường đi.", "point"),
	item_loot_box = cheat_item_option("loot_box", "Rương chiến lợi phẩm", 400, 150,
		"Thả rương xuống đường đi, gây sát thương cho kẻ địch và nhận 666 vàng.", "area", nil, {gold_amount = 666}),
	item_medical_kit = cheat_item_option("medical_kit", "Túi cứu thương", 300, 150,
		"Nhận 5 mạng.", "point", nil, {hearts = 5}),
	item_veznan_wrath = cheat_item_option("veznan_wrath", "Cơn thịnh nộ của Vez'nan", 990, 90,
		"Vez'nan tung phép mạnh, giáng đòn hủy diệt lên toàn bộ kẻ địch trên chiến trường.", "area", nil),
	kro_teleport_scroll = kro_item_option("teleport_scroll", "teleport_scroll", "Cuộn dịch chuyển", 30,
		"Dịch chuyển kẻ địch trong vùng lùi về phía sau trên đường đi.", "area"),
	kro_horn_heroism = kro_item_option("horn_heroism", "horn_heroism", "Tù và anh hùng", 84,
		"Cường hóa lính và tháp gần đó, bảo vệ chúng và tăng sát thương lên gấp đôi.", "area"),
	kro_gem_timewarp = kro_item_option("gem_timewarp", "gem_timewarp", "Cổng xoáy", 72,
		"Gây 128 sát thương phép lên toàn bộ kẻ địch, dịch chuyển chúng lùi về phía sau và làm chậm.", "area", nil, nil,
		"DaqiaoVortexGateCast", {"power_daqiao_vortex_gate"}),
	kro_rod_dragon_fire = kro_item_option("rod_dragon_fire", "rod_dragon_fire", "Trượng hơi thở rồng", 60,
		"Đặt trượng hơi thở rồng trên đường đi, liên tục bắn cầu lửa vào kẻ địch gần đó.", "point", nil, {"go_items_rod_dragon_fire"}),
	kro_hand_midas = kro_item_option("hand_midas", "hand_midas", "Bàn tay Midas", 60,
		"Nhân đôi vàng nhận được khi tiêu diệt kẻ địch trong 35 giây.", "point", nil),
	kro_wrath_of_elynia = kro_item_option("wrath_of_elynia", "wrath_of_elynia", "Cơn thịnh nộ của Elynie", 90,
		"Tiêu diệt kẻ địch thường trên chiến trường và gây 3000 sát thương chuẩn lên trùm.", "area", nil)
}

local default_slots = {
	"default_cataclysm",
	"default_reinforcement",
	"empty_spell"
}

function M.normalize(user_data)
	user_data.liuhui = user_data.liuhui or {}

	local changed = false
	local _, power_upgrades_changed = power_upgrades_6.normalize(user_data)
	local selection = user_data.liuhui.power_selection

	changed = changed or power_upgrades_changed

	if type(selection) ~= "table" then
		selection = {}
		user_data.liuhui.power_selection = selection
		changed = true
	end

	if type(selection.slots) ~= "table" then
		selection.slots = {}
		changed = true
	end

	for slot = 1, 3 do
		if not M.options[selection.slots[slot]] then
			selection.slots[slot] = default_slots[slot]
			changed = true
		end
	end

	if selection.hero_ultimate ~= nil then
		selection.hero_ultimate = nil
		changed = true
	end

	return selection, changed
end

function M.get(user_data, slot)
	local selection = M.normalize(user_data)

	return M.options[selection.slots[slot]], selection.slots[slot]
end

function M.set(user_data, slot, option_id)
	if slot < 1 or slot > 3 or not M.options[option_id] then
		return false, "invalid_option"
	end

	local selection = M.normalize(user_data)

	selection.slots[slot] = option_id

	return true
end

function M.apply_default(user_data)
	local selection = M.normalize(user_data)

	for slot = 1, 3 do
		selection.slots[slot] = default_slots[slot]
	end

	return true
end

function M.get_description(user_data, option_id)
	local option = M.options[option_id]

	if not option then
		return ""
	end

	if option.tech_upgrade then
		local level = 0

		if user_data and option.generation and option.generation <= 3 then
			level = UPGR:get_user_levels(user_data, option.generation)[option.tech_upgrade] or 0
		elseif user_data and option.kind == "reinforcement" and (option.generation == 4 or option.generation == 5) then
			level = generation_upgrades.level(user_data, "g" .. option.generation .. "_reinforcements")
		end

		return string.format("Phép này chịu tác động của nhánh nâng cấp tương ứng và không điều chỉnh tại đây. Cấp nâng cấp hiện tại: %i", level)
	end

	return option.description or ""
end

function M.get_selected_dependencies(user_data)
	local selection = M.normalize(user_data)
	local result = {
		required_textures = {},
		scale_required_textures = {},
		required_sounds = {},
		required_exoskeletons = {},
		required_exoskeleton_groups = {}
	}
	local seen = {}

	local function append_unique(target_name, value)
		local key = target_name .. ":" .. value

		if not seen[key] then
			seen[key] = true
			table.insert(result[target_name], value)
		end
	end

	for slot = 1, 3 do
		local option = M.options[selection.slots[slot]]

		if option then
			for _, value in ipairs(option.required_textures or {}) do
				append_unique("required_textures", value)
			end

			for _, value in ipairs(option.scale_required_textures or {}) do
				append_unique("scale_required_textures", value)
			end

			for _, value in ipairs(option.required_sounds or {}) do
				append_unique("required_sounds", value)
			end

			for _, value in ipairs(option.required_exoskeletons or {}) do
				append_unique("required_exoskeletons", value)
			end

			for _, value in ipairs(option.required_exoskeleton_groups or {}) do
				append_unique("required_exoskeleton_groups", value)
			end
		end
	end

	return result
end

function M.should_auto_cast_hero_ultimate(store, hero, allowed, excluded)
	if not store or not hero or type(hero.template_name) ~= "string" then
		return false
	end

	if store.level_mode == GAME_MODE_CAMPAIGN and store.campaign_variant == CAMPAIGN_VARIANT_HERO_RALLY then
		return true
	end

	return allowed and not excluded and string.sub(hero.template_name, -2) == "_2"
end

return M

