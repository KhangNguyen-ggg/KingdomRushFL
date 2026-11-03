local log = require("klua.log"):new("game_gui")
local km = require("klua.macros")

require("klua.table")
require("klove.kui")

local timer = require("hump.timer"):new()
local signal = require("hump.signal")
local class = require("middleclass")
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local AC = require("achievements")
local F = require("klove.font_db")
local I = require("klove.image_db")
local S = require("sound_db")
local SU = require("screen_utils")
local E = require("entity_db")
local U = require("utils")
local V = require("klua.vector")
local v = V.v
local r = V.r
local P = require("path_db")
local GR = require("grid_db")
local GS = require("game_settings")
local GU = require("gui_utils_5") -- 这个不能乱用 流辉349
local LU = require("level_utils")
local storage = require("storage")
local UP = require("upgrades")
local G = love.graphics
local i18n = require("i18n")
local balance = require("balance/balance")
local UPGR = require("upgrades")
local tower_menus = require("data.tower_menus_data")
local shortcut_settings = require("shortcut_settings")
local high_level_towers = {}
local skipped_auto_powers = {
    tricannon = {overheat = true},
    infernal_mage = {curse = true},
    dark_knights = {shield = true}
}

CriketMenuButton = class("CriketMenuButton", KView)
function CriketMenuButton:initialize(item)
    CriketMenuButton.super.initialize(self)

    self.item_image = item.image

    local b = KImageView:new(item.image)

    b.pos = v(0, 0)
    b.propagate_on_click = true
    b.disabled_tint_color = nil
    self.button = b

    self:add_child(b)

    local halo = KImageView:new(item.halo)

    halo.pos = v(math.floor(-0.5 * (halo.size.x - b.size.x)), math.floor(-0.5 * (halo.size.y - b.size.y)))

    halo.propagate_on_click = true
    halo.hidden = true
    self.halo = halo

    self:add_child(halo, 1)

    if table.contains({"tw_upgrade", "tw_buy_soldier", "tw_buy_attack","tw_page",}, item.action) then
        local bo = KImageView:new("main_icons_over")

        bo.pos = v(math.floor(-0.5 * (bo.size.x - b.size.x)), math.floor(-0.5 * (bo.size.y - b.size.y)))
        bo.propagate_on_click = true
        bo.disabled_tint_color = nil

        self:add_child(bo)
    end

    local ufx = KImageView:new("effect_powerbuy_0001")

    ufx.animation = {
        to = 23,
        prefix = "effect_powerbuy",
        from = 1
    }
    ufx.pos = v(4, -4)
    ufx.hidden = true
    ufx.propagate_on_click = true
    self.ufx = ufx

    self:add_child(ufx)

    self.size = V.vclone(b.size)
end

CriketMenu = class("CriketMenu", KImageView)

function CriketMenu:initialize(game_gui_instance)
    CriketMenu.super.initialize(self, "gui_ring")
    self.can_drag = false
    self.game_gui = game_gui_instance
    self.propagate_on_click = true
    self.propagate_on_down = true
    self.propagate_on_up = true
    self.propagate_on_enter = true
    self.anchor = v(self.size.x / 2, self.size.y / 2)
    self.clip = false
    self.replace = false
end

function CriketMenu:calculate_button_position(item_index)
    local circle_volume = 6
    local radius_mod = 65
    local radius = radius_mod -- 默认半径
    while item_index > circle_volume do
        item_index = item_index - circle_volume
        radius = radius + radius_mod -- 每圈增加80像素的半径
        circle_volume = circle_volume + 6 -- 每圈增加6个按钮
    end

    -- 计算每个按钮之间的角度间隔
    local angle_step = (2 * math.pi) / circle_volume

    -- 计算当前按钮的角度（从顶部开始，顺时针）
    local angle = (item_index - 1) * angle_step - math.pi / 2

    -- 计算相对于圆心的位置
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius

    -- 返回相对于菜单中心的位置
    return V.v(self.size.x / 2 + x, self.size.y / 2 + y)
end
function CriketMenu:show()
    self:remove_children()
    for index, item in pairs(high_level_towers) do
        local b = CriketMenuButton:new(item)
        b.pos = self:calculate_button_position(index)
        b.pos.x, b.pos.y = b.pos.x - b.size.x / 2, b.pos.y - b.size.y / 2
        b.item_props = item

        local stm = self

        if item.action == "tw_none" then
            b:disable()
        else
            function b.on_click(this, button, x, y)
                log.debug("CLICK")
                if not self.tweening and not this.click_disabled then
                    stm:button_callback(this, item)
                end
            end

            function b.on_enter(this, drag_view)
                if not self.tweening then
                    stm:button_enter(this)
                end
            end

            function b.on_exit(this, drag_view)
                stm:button_exit(this)
            end
        end

        self:add_child(b)
    end

    self.pos = v(self.game_gui.sw * 0.5, self.game_gui.sh * 0.5)
    self.scale = v(1, 1)
    self.alpha = 1
    self.hidden = false
    -- self.tweening = true
    -- self.tweening = false
    -- self.tweeners = {timer:tween(0.12, self.scale, {
    --     x = 1,
    --     y = 1
    -- }, "out-quad"), timer:tween(0.12, self, {
    --     alpha = 1
    -- }, "out-quad", function()
    --     self.tweening = nil
    --     self.tweeners = {}
    -- end)}

    S:queue("GUIQuickMenuOpen")
end

function CriketMenu:hide()
    -- if self.tweeners then
    --     for _, t in pairs(self.tweeners) do
    --         timer:cancel(t)
    --     end
    -- end

    -- self.tweening = true
    -- self.tweeners = {timer:tween(0.12, self, {
    --     alpha = 0
    -- }, "out-quad"), timer:tween(0.12, self.scale, {
    --     x = 0.6,
    --     y = 0.6
    -- }, "out-quad", function()
    --     self.hidden = true
    --     self.tweening = false
    --     self.tweeners = {}
    -- end)}
    self.hidden = true
end

function CriketMenu:button_enter(button)
    if button.halo then
        button.halo.hidden = false
    end
end

function CriketMenu:button_exit(button)
    if button.halo then
        button.halo.hidden = true
    end
end

function CriketMenu:button_callback(button, item, entity, mouse_button, x, y)

    if item.action == "tw_upgrade" then
        local template = E.entities[item.action_arg]

        if not template or not template.tower or template.tower.type == "build_animation" then
            log.error("One-click tower template is not a finished tower: %s", tostring(item.action_arg))
            self:hide()
            return
        end

        local menu = tower_menus[item.menu_key or template.tower.type]
        local purchasable_powers = {}

        for _, page in ipairs(menu or {}) do
            for _, menu_item in ipairs(page) do
                if menu_item.action == "upgrade_power" then
                    purchasable_powers[menu_item.action_arg] = true
                end
            end
        end

        local skipped_powers = skipped_auto_powers[item.tower_type or template.tower.type] or {}
        local towers = table.filter(self.game_gui.game.store.entities, function(k, v)
            return v.tower
        end)
        for k, v in pairs(towers) do
            if self.replace or v.tower.type == "holder" or (v.tower_holder and v.tower_holder.blocked == true) then
                local new_tower = E:create_entity(item.action_arg)

                new_tower.pos = V.vclone(v.pos)
                new_tower.tower.holder_id = v.tower.holder_id
                new_tower.tower.flip_x = v.tower.flip_x
                if v.tower.default_rally_pos then
                    new_tower.tower.default_rally_pos = V.vclone(v.tower.default_rally_pos)
                end
                if v.tower.terrain_style then
                    new_tower.tower.terrain_style = v.tower.terrain_style
                    local sprite = new_tower.render and new_tower.render.sprites[1]

                    if sprite and type(sprite.name) == "string" and sprite.name:find("%%") then
                        sprite.name = string.format(sprite.name, v.tower.terrain_style)
                    end
                end

                if new_tower.ui and v.ui then
                    new_tower.ui.nav_mesh_id = v.ui.nav_mesh_id
                end

                if new_tower.powers then
                    for name, power in pairs(new_tower.powers) do
                        if name ~= "ultimate" and not skipped_powers[name]
                            and (purchasable_powers[name] or next(purchasable_powers) == nil)
                            and power.max_level and power.max_level > 0 then
                            power.level = power.max_level
                            power.changed = true
                            if power.show_rally then
                                new_tower.tower.show_rally = true
                            end
                        end
                    end
                end

                if new_tower.barrack then
                    new_tower.barrack.rally_pos = V.vclone(new_tower.tower.default_rally_pos or new_tower.pos)
                end

                self.game_gui.game.simulation:queue_remove_entity(v)
                self.game_gui.game.simulation:queue_insert_entity(new_tower)
            end
        end
    end
    self:hide()
end

local g1_to_g3_towers = {
    {
        check = "main_icons_0019",
        action_arg = "tower_blade",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0104",
        place = 1,
        tt_title = _("TOWER_BARRACKS_BLADE_NAME"),
        tt_desc = _("TOWER_BARRACKS_BLADE_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_forest",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0105",
        place = 2,
        tt_title = _("TOWER_FOREST_KEEPERS_NAME"),
        tt_desc = _("TOWER_FOREST_KEEPERS_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_drow_d",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "special_icons_0301",
        place = 3,
        tt_title = _("ELVES_TOWER_SPECIAL_DROW_NAME"),
        tt_desc = _("ELVES_TOWER_SPECIAL_DROW_DESCRIPTION")
    }, {
        check = "main_icons_0020",
        action_arg = "tower_elf_kr1",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0906",
        place = 3,
        tt_title = _("SPECIAL_ELF_KR1_REPAIR_NAME"),
        tt_desc = _("SPECIAL_ELF_KR1_REPAIR_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_baby_ashbite_d",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0113",
        place = 2,
        tt_title = _("ELVES_BABY_ASHBITE_TOWER_NAME"),
        tt_desc = _("ELVES_BABY_ASHBITE_FIREBREATH_SMALL_DESCRIPTION_3") .. "\n" .. _("ELVES_BABY_ASHBITE_SMOKEBREATH_SMALL_DESCRIPTION_1")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_ewok_archer_re",--"tower_ewok_rework",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0112",
        place = 1,
        tt_title = _("ELVES_EWOK_NAME"),
        tt_desc = _("ELVES_EWOK_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_arcane",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0108",
        place = 1,
        tt_title = _("TOWER_ARCANE_NAME"),
        tt_desc = _("TOWER_ARCANE_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_silver",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0109",
        place = 2,
        tt_title = _("TOWER_SILVER_NAME"),
        tt_desc = _("TOWER_SILVER_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_green_archer",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "groundArchers_0002",
        place = 3, -- 3,
        tt_title = _("TOWER_GREEN_ARCHER_NAME"),
        tt_desc = _("TOWER_GREEN_ARCHER_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_druid",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0111",
        place = 1,
        tt_title = _("TOWER_DRUID_HENGE_NAME"),
        tt_desc = _("TOWER_DRUID_HENGE_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_entwood",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0110",
        place = 2,
        tt_title = _("TOWER_ENTWOOD_NAME"),
        tt_desc = _("TOWER_ENTWOOD_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_bastion_d",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_tower_icons_0003",
        place = 11,
        tt_title = _("ELVES_TOWER_BASTION_D_NAME"),
        tt_desc = _("ELVES_TOWER_BASTION_D_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_wild_magus",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0106",
        place = 1,
        tt_title = _("TOWER_MAGE_WILD_MAGUS_NAME"),
        tt_desc = _("TOWER_MAGE_WILD_MAGUS_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_high_elven",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0107",
        place = 2,
        tt_title = _("TOWER_MAGE_HIGH_ELVEN_NAME"),
        tt_desc = _("TOWER_MAGE_HIGH_ELVEN_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_pixie_re",--"tower_pixie_d",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_tower_icons_0002",
        place = 11,
        tt_title = _("ELVES_TOWER_PIXIE_NAME"),
        tt_desc = _("ELVES_TOWER_PIXIE_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_faerie_dragon_re",--"tower_faerie_dragon_d",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_tower_icons_0001",
        place = 12,
        tt_title = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_NAME"),
        tt_desc = _("ELVES_TOWER_SPECIAL_FAERIE_DRAGONS_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_bfg",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0013",
        place = 1, -- 3,
        tt_title = _("TOWER_BFG_NAME"),
        tt_desc = _("TOWER_BFG_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_tesla",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0012",
        place = 2, -- 4,
        tt_title = _("TOWER_TESLA_NAME"),
        tt_desc = _("TOWER_TESLA_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_ranger",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0011",
        place = 1, -- 3,
        tt_title = _("TOWER_RANGERS_NAME"),
        tt_desc = _("TOWER_RANGERS_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_musketeer",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0010",
        place = 2, -- 4,
        tt_title = _("TOWER_MUSKETEERS_NAME"),
        tt_desc = _("TOWER_MUSKETEERS_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_barbarian",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0009",
        place = 2, -- 3,
        tt_title = _("TOWER_BARBARIANS_NAME"),
        tt_desc = _("TOWER_BARBARIANS_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_paladin",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0008",
        place = 1, -- 11,
        tt_title = _("TOWER_PALADINS_NAME"),
        tt_desc = _("TOWER_PALADINS_DESCRIPTION")
    }, {
        action = "tw_upgrade",
        action_arg = "tower_necromancer",
        check = "main_icons_0019",
        halo = "glow_ico_main",
        image = "main_icons_0021",
        place = 1,
        tt_title = _("TOWER_NECROMANCER_NAME"),
        tt_desc = _("TOWER_NECROMANCER_DESCRIPTION")
    }, {
        action = "tw_upgrade",
        action_arg = "tower_archmage",
        check = "main_icons_0019",
        halo = "glow_ico_main",
        image = "main_icons_0022",
        place = 2,
        tt_title = _("TOWER_ARCHMAGE_NAME"),
        tt_desc = _("TOWER_ARCHMAGE_DESCRIPTION")
    }, {
        action = "tw_upgrade",
        action_arg = "tower_dwaarp",
        check = "main_icons_0019",
        halo = "glow_ico_main",
        image = "main_icons_0027",
        place = 1, -- 11,
        tt_title = _("TOWER_DWAARP_NAME"),
        tt_desc = _("TOWER_DWAARP_DESCRIPTION")
    }, {
        action = "tw_upgrade",
        action_arg = "tower_frankenstein_d",
        check = "main_icons_0019",
        halo = "glow_ico_main",
        image = "main_tower_icons_0006",
        place = 1,
        tt_title = _("TOWER_FRANKENSTEIN_NAME"),
        tt_desc = _("TOWER_FRANKENSTEIN_DESCRIPTION")
    }, {
        action = "tw_upgrade",
        action_arg = "tower_mech",
        check = "main_icons_0019",
        halo = "glow_ico_main",
        image = "main_icons_0028",
        place = 2, -- 12,
        tt_title = _("TOWER_MECH_NAME"),
        tt_desc = _("TOWER_MECH_DESCRIPTION")
    }, {
        action = "tw_upgrade",
        action_arg = "tower_totem",
        check = "main_icons_0019",
        halo = "glow_ico_main",
        image = "main_icons_0026",
        place = 1,
        tt_title = _("TOWER_TOTEM_NAME"),
        tt_desc = _("TOWER_TOTEM_DESCRIPTION")
    }, {
        action = "tw_upgrade",
        action_arg = "tower_crossbow",
        check = "main_icons_0019",
        halo = "glow_ico_main",
        image = "main_icons_0025",
        place = 2,
        tt_title = _("TOWER_CROSSBOW_NAME"),
        tt_desc = _("TOWER_CROSSBOW_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_archer_dwarf_d",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_tower_icons_0005",
        place = 3, -- 5,
        tt_title = _("TOWER_ARCHER_DWARF_NAME"),
        tt_desc = _("TOWER_ARCHER_DWARF_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_pirate_watchtower_d",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_tower_icons_0004",
        place = 4, -- 10,
        tt_title = _("TOWER_PIRATE_WATCHTOWER_NAME"),
        tt_desc = _("TOWER_PIRATE_WATCHTOWER_DESCRIPTION")
    }, {
        action = "tw_upgrade",
        action_arg = "tower_assassin",
        check = "main_icons_0019",
        halo = "glow_ico_main",
        image = "main_icons_0024",
        place = 1,
        tt_title = _("TOWER_ASSASSIN_NAME"),
        tt_desc = _("TOWER_ASSASSIN_DESCRIPTION")
    }, {
        action = "tw_upgrade",
        action_arg = "tower_templar",
        check = "main_icons_0019",
        halo = "glow_ico_main",
        image = "main_icons_0023",
        place = 2,
        tt_title = _("TOWER_TEMPLAR_NAME"),
        tt_desc = _("TOWER_TEMPLAR_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_barrack_dwarf_d",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "special_icons_0201",
        place = 3,
        tt_title = _("SPECIAL_DWARF_HALL_NAME"),
        tt_desc = _("SPECIAL_DWARF_HALL_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_barrack_amazonas_re",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0033a",
        place = 3, -- 15,
        tt_title = _("TOWER_BARRACK_AMAZONAS_NAME"),
        tt_desc = _("TOWER_BARRACK_AMAZONAS_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_barrack_mercenaries_d",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0029",
        place = 2,
        tt_title = _("TOWER_BARRACK_MERCENARIES_NAME"),
        tt_desc = _("TOWER_BARRACK_MERCENARIES_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_barrack_mercenaries_2",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_00aa",
        place = 1,
        tt_title = _("TOWER_BARRACK_MERCENARIES_NAME"),
        tt_desc = _("TOWER_BARRACK_MERCENARIES_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_barrack_pirate_captain",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0031a",
        place = 2,
        tt_title = _("TOWER_BARRACK_PIRATES_NAME"),
        tt_desc = _("TOWER_BARRACK_PIRATES_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_arcane_wizard",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0006",
        place = 1, -- 3,
        tt_title = _("TOWER_ARCANE_WIZARD_NAME"),
        tt_desc = _("TOWER_ARCANE_WIZARD_DESCRIPTION")
    }, {
        check = "main_icons_0019",
        action_arg = "tower_sorcerer",
        action = "tw_upgrade",
        halo = "glow_ico_main",
        image = "main_icons_0007",
        place = 2, -- 4,
        tt_title = _("TOWER_SORCERER_NAME"),
        tt_desc = _("TOWER_SORCERER_DESCRIPTION")
    }
}

local function rebuild_high_level_towers()
    tower_menus = require("data.tower_menus_data")
    high_level_towers = {}

    local holder = tower_menus.holder and tower_menus.holder[1]
    local pages = holder and holder.pages or {}
    local seen = {}

    for _, page in ipairs(pages) do
        for _, tower_menu in ipairs(page) do
            local tower_type = type(tower_menu.action_arg) == "string"
                and tower_menu.action_arg:match("^tower_build_(.+)$")

            if tower_menu.action == "tw_upgrade" and tower_type and not seen[tower_type] then
                local target = "tower_" .. tower_type .. "_lvl4"
                local template = E.entities[target]
                local menu_key = template and template.tower and template.tower.type or tower_type
                local regular_upgrade = false

                for _, upgrade in ipairs(tower_menus[menu_key] and tower_menus[menu_key][3] or {}) do
                    if upgrade.action == "tw_upgrade" and upgrade.action_arg == target then
                        regular_upgrade = true
                        break
                    end
                end

                if template and template.tower and template.tower.level == 4 and regular_upgrade then
                    local entry = table.deepclone(tower_menu)

                    entry.action_arg = target
                    entry.tower_type = tower_type
                    entry.menu_key = menu_key
                    table.insert(high_level_towers, entry)
                    seen[tower_type] = true
                else
                    log.debug("No level 4 one-click tower for %s", tower_menu.action_arg)
                end
            end
        end
    end

    for _, tower_menu in ipairs(g1_to_g3_towers) do
        table.insert(high_level_towers, tower_menu)
    end
end

local function patch_cricket_ui(game_gui)
    local original_init = game_gui.init

    game_gui.fullscreen_tower_build_enabled = false

    function game_gui:set_fullscreen_tower_build_enabled(enabled)
        self.fullscreen_tower_build_enabled = enabled == true

        if self.fullscreen_tower_build_enabled and not self._criket_menu_data_ready then
            rebuild_high_level_towers()
            self._criket_menu_data_ready = true
        elseif not self.fullscreen_tower_build_enabled and self.criketmenu then
            self.criketmenu:hide()
            self.criketmenu.replace = false
        end

        if self.android_criket_z_button then
            self.android_criket_z_button.hidden = not self.fullscreen_tower_build_enabled
        end
    end

    function game_gui:toggle_fullscreen_tower_menu()
        if not self.fullscreen_tower_build_enabled or not self.criketmenu then
            return
        end

        if self.criketmenu.hidden then
            self.criketmenu:show()
        else
            self.criketmenu:hide()
        end
    end

    function game_gui:init(w, h, game)
        self.fullscreen_tower_build_enabled = false
        self._criket_menu_data_ready = false

        original_init(self, w, h, game)

        local criketmenu = CriketMenu:new(self)

        criketmenu.hidden = true
        self.layer_gui_game:add_child(criketmenu)
        self.criketmenu = criketmenu

        if IS_ANDROID and self.hud_bottom then
            local z_button = KButton:new(nil, "pause_base")

            z_button.anchor = v(z_button.size.x / 2, z_button.size.y / 2)
            z_button.pos = v(self.sw - 58, self.sh - 195)
            z_button.hit_rect = r(35, 6, 90, 80)
            z_button.text = "Z"
            z_button.text_size = V.vclone(z_button.size)
            z_button.font_name = "body"
            z_button.font_size = 38
            z_button.text_align = "center"
            z_button.vertical_align = "middle"
            z_button.colors.text = {255, 255, 255, 255}
            z_button.hidden = true

            function z_button.on_click()
                self:toggle_fullscreen_tower_menu()
            end

            self.android_criket_z_button = z_button
            self.hud_bottom:add_child(z_button)
        end

        local user_data = storage:load_slot()
        local enabled = user_data and user_data.liuhui and user_data.liuhui.fullscreen_tower_build == true

        self:set_fullscreen_tower_build_enabled(enabled)
    end

    local original_key_pressed = game_gui.keypressed

    function game_gui:keypressed(key, isrepeat)
        original_key_pressed(self, key, isrepeat)

        if not self.fullscreen_tower_build_enabled or self.keys_disabled or self.game.store.paused then
            return
        end

		if shortcut_settings.matches(self.key_shortcuts, "build_menu", key) then
			self:toggle_fullscreen_tower_menu()
		elseif shortcut_settings.matches(self.key_shortcuts, "build_mode", key) then
            self.criketmenu.replace = not self.criketmenu.replace
        end
    end
end

return patch_cricket_ui

