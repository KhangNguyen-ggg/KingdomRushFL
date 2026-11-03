local log = require("klua.log"):new("game_scripts")

require("klua.table")

local km = require("klua.macros")
local signal = require("hump.signal")
local AC = require("achievements")
local E = require("entity_db")
local GR = require("grid_db")
local GS = require("game_settings")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils")
local SU5 = require("script_utils_5")
local SU6 = require("script_utils_6")
local U = require("utils")
local U6 = require("utils_6")
local U5 = require("utils_5")
local ULH = require("utils_lh")
local LU = require("level_utils")
local game_gui = require("game_gui")
require("game_gui")
require("klove.kui")
local UP = require("upgrades")
local V = require("klua.vector")
local W = require("wave_db")
local bit = require("bit")
local storage = require("storage")
local GSC = require("game_scripts")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot

require("i18n")

local scripts = require("scripts")
local scripts6 = require("scripts_6")
scripts.kr6_fl_mod_track_target_update = scripts6.mod_track_target.update
scripts.kr6_fl_mod_dps_insert = scripts6.mod_dps.insert
scripts.kr6_fl_mod_dps_update = scripts6.mod_dps.update
local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

local function queue_damage(store, damage)
	store.damage_queue[#store.damage_queue + 1] = damage
end

local function fts(v)
	return v / FPS
end

local function v(v1, v2)
	return {
		x = v1,
		y = v2
	}
end

local function tpos(e)
	return e.tower and e.tower.range_offset and V.v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or
	e.pos
end

scripts.a_hero = {
	on_damage = function(this, store, damage)
		local h = this.health
		local da = damage
		local pd = U.predict_damage(this, damage)

		if band(da.damage_type, bor(DAMAGE_EAT)) ~= 0 then
			return true
		end
		this.brave_max_times = this.brave_max_times or 1
		if not this.brave_times then
			this.brave_times = this.brave_max_times
		end
		if this.brave_times and this.brave_times > 0 and pd >= h.hp then
			this.brave_times = this.brave_times - 1
			h.hp = 1
			if this.brave_heal then
				h.hp = this.brave_heal
				local m = E:create_entity("mod_shaman_heal")
				m.modifier.target_id = this.id
				m.modifier.source_id = this.id
				m.hps.heal_min = 0
				m.hps.heal_max = 0
				if this.unit.size and m.render.sprites[1].size_names then
					m.render.sprites[1].name = m.render.sprites[1].size_names[this.unit.size]
				end
				queue_insert(store, m)
			end
			if this.brave_mod then
				local m = E:create_entity(this.brave_mod)
				m.modifier.target_id = this.id
				m.modifier.source_id = this.id
				queue_insert(store, m)
			end
			if this.brave_heal_factor then
				h.hp = h.hp_max * this.brave_heal_factor
			end
			if this.brave_hp_inc then
				h.hp_max = h.hp_max + this.brave_hp_inc
			end
			h.hp = km.clamp(0, h.hp_max, h.hp)
			return false
		end

		if this.brave_times and this.brave_times <= 0 and pd >= h.hp then
			this.brave_times = nil
		end

		return true
	end,
	insert = function(this, store)
		if this.auras then
			local aura = {}
			for i = 1, #this.auras.list do
				::again::
				aura[i] = E:create_entity(this.auras.list[i].name)
				aura[i].aura.source_id = this.id
				aura[i].pos = this.pos
				queue_insert(store, aura[i])
				if not aura[i] then
					goto again
				end
			end
		end
		this.health_bar.hidden = false
		if this.render.sprites[1] then
			this.render.sprites[1].fps = this.render.sprites[1].fps or FPS
			this.render.sprites[1].alpha = this.render.sprites[1].alpha or 255
		end
		this.melee.order = U.attack_order(this.melee.attacks)
		this.nav_rally.pos = this.nav_rally.pos or V.vclone(this.pos)
		this.nav_rally.center = this.nav_rally.center or V.vclone(this.pos)
		this.health.dead_lifetime = this.health.dead_lifetime or 3

		return true
	end,
	update = function(this, store, script)
		local h = this.health
		local he = this.hero
		local brk, sta = nil
		local idle_cooldown = this.idle_flip.cooldown or 3
		local idle_chance = this.idle_flip.chance or 0.5
		local idle_ts = store.tick_ts

		this.health_bar.hidden = false
		this.melee.order = U.attack_order(this.melee.attacks)


		while true do
			::loop::
			if h.dead then
				SU.y_hero_death_and_respawn(store, this)
			end
			if this.unit.is_stunned then
				U.animation_start(this, "idle", nil, store.tick_ts, -1)
				SU.soldier_idle(store, this)
				coroutine.yield()
			else
				::rally::
				if this.nav_rally.new then
					SU.y_hero_new_rally(store, this)
				else
					--nothing
				end
				::net::
				if this.nav_rally.new then
					goto rally
				end
				if h.dead or this.unit.is_stunned then
					goto loop
				end
				if this.melee then
					brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

					if sta == A_IN_COOLDOWN and U.animation_finished(this) then
						U.animation_start(this, "idle", nil, store.tick_ts, true)
					end
					if sta ~= A_NO_TARGET then
						coroutine.yield()
						goto net
					else
						coroutine.yield()
						goto out
					end
				end
				::out::
				if SU.soldier_go_back_step(store, this) then
					coroutine.yield()
					SU.soldier_go_back_step(store, this)
					this.motion.change = true
					goto net
				else
					SU.soldier_idle(store, this)
					SU.soldier_regen(store, this)
					if idle_cooldown < store.tick_ts - idle_ts then
						if math.random() < idle_chance then
							this.render.sprites[1].flip_x = not this.render.sprites[1].flip_x
						end
						idle_ts = store.tick_ts
					end
					this.motion.change = nil
					coroutine.yield()
				end
			end
		end
	end
}

scripts.a_dwarf = {
	update = function(this, store)
		local function no_hero_can()
			if store.level.locked_hero then
				return false
			end
			return store.selected_hero
		end
		if this.hero_insert and no_hero_can() then
			local hero = LU.insert_hero(store, this.template_name, this.nav_rally.pos)
			hero.hero_insert = false
			U.sprites_hide(this)
			queue_remove(store, this)
			return
		elseif this.hero_insert then
			local so = E:create_entity(this.template_name)
			so.pos = this.nav_rally.pos
			so.hero_insert = false
			so.nav_rally.pos = V.vclone(this.nav_rally.pos)
			so.nav_rally.center = V.vclone(so.nav_rally.pos)
			queue_insert(store, so)
			U.sprites_hide(this)
			queue_remove(store, this)
			return
		end
		if this.cheat_game_2 then
			store.player_gold = store.player_gold + 6666
			storage:load_slot().gems = storage:load_slot().gems + 99
			signal.emit("show-gems-reward", this, 99)
			U.sprites_hide(this)
			queue_remove(store, this)
			return
		end
		if this.cheat_game_3 then
			store.lives = 99
			U.sprites_hide(this)
			queue_remove(store, this)
			return
		end
		if this.cheat_game_4 then
			for _, e in pairs(store.entities) do
				if e.enemy and e.nav_path then
					e.motion.max_speed = 0
				end
			end
			U.sprites_hide(this)
			queue_remove(store, this)
			return
		end
		if this.cheat_game_5 then
			for _, e in pairs(store.entities) do
				if e.soldier and e.nav_rally then
					e.health.armor = 0.8
					e.health.damage_factor = 0.5
				end
			end
			U.sprites_hide(this)
			queue_remove(store, this)
			return
		end
		if this.cheat_game_6 then
			for _, e in pairs(store.entities) do
				if e.enemy and e.nav_path then
					local d = E:create_damage()
					d.damage_type = DAMAGE_INSTAKILL
					d.target_id = e.id
					queue_damage(store, d)
				end
			end
			queue_remove(store, this)
			return
		end
		if this.cheat_game_7 then
			for _, e in pairs(store.entities) do
				if e.enemy and e.nav_path then
					e.health.armor = 0
					e.health.damage_factor = 2
				end
			end
			U.sprites_hide(this)
			queue_remove(store, this)
			return
		end
		if this.cheat_game then
			LU.kill_all_enemies(store, true)
			game.store.force_next_wave = true
			U.sprites_hide(this)
			queue_remove(store, this)
			return
		end
		::twice::
		if this.auras then
			local aura = {}
			for i = 1, #this.auras.list do
				::again::
				aura[i] = E:create_entity(this.auras.list[i].name)
				aura[i].aura.source_id = this.id
				aura[i].pos = this.pos
				queue_insert(store, aura[i])
				if not aura[i] then
					goto again
				end
			end
			return scripts.a_hero.update(this, store, script)
		else
			return scripts.a_hero.update(this, store, script)
		end
	end
}

scripts.tower_buy_soldiers = {
	get_info = function (this)
	return {
				type = STATS_TYPE_TEXT,
				desc = _((this.info.i18n_key or string.upper(this.template_name)) .. "_DESCRIPTION")
			}
	end,
	can_select_point = function (this, x, y, store)

		return P:valid_node_nearby(x, y) and GR:cell_is(x, y, bor(TERRAIN_ALL_MASK))

	end,
	update = function (this, store)
		local sell_id = 9
		local us = this.user_selection
		local a = this.attacks
		local tow = this.tower
		local us_args = {}
		local us_poses = {}

local function set_attacks()

		if this.ui and this.ui.args == "tower_level_up" then
			tow.level = tow.level + 1
			this.ui.args = nil
			if this == game_gui.selected_entity then
				game_gui:deselect_entity()
			end
		end
				if us and us.arg and us.new_pos then
					table.insert(us_args, us.arg)
					table.insert(us_poses, us.new_pos)
					us.new_pos = nil
					us.arg = nil
				end
			end
local function cast_attacks(arg, rpos)

	if us then
			
				if arg and rpos then
				local aa = a.list
				local group = nil
				local rx = rpos.x
				local ry = rpos.y
					if aa[arg] and aa[arg].entities then
					local fx = E:create_entity("fx_bullet_rod_dragon_fire_hit")
					fx.render.sprites[1].ts = store.tick_ts
					fx.pos = V.vclone(rpos)

					queue_insert(store, fx)
					store.player_gold = store.player_gold -  aa[arg].price
						for _, so in pairs(aa[arg].entities) do
						so.chance = so.chance or so[1] or 1
						so.soldiers = so.soldiers or so[2]
						so.fx_list = so.fx_list or so[3]
						so.auras = so.auras or so[4]
						so.offsets = so.offsets or nil
						so.func = so.func or nil
						so.func_clicks = so.func_clicks or nil

						if so.func and so.func (this, store, rx, ry) then
						--nothing
						elseif so.func then
						goto finish
						end
							if (not so.chance or so.chance == 1 or math.random() < so.chance) then
							group = so
							break
							end
							::finish::
						end

					local so = group
					if group then
								if so.func_clicks then
									if so.can_func_clicks then
										if so.func_clicks (this, store, rx, ry) then
										so.can_func_clicks = nil
										goto more
										else
										goto more
										end
									end
									so.can_func_clicks = true
								end
							if so.soldiers then
								local num = #so.soldiers
								local center = nil
								if so.soldiers[#so.soldiers] == center then
									num = num - 1
									center = true
								end
								for i = 1, num do
									local sr = so.soldiers[i]
									local s = E:create_entity(sr)
									s.nav_rally.center = V.vclone(rpos)
									s.nav_rally.pos = V.vclone(rpos)
									if so.offsets then
										s.nav_rally.pos.x = s.nav_rally.pos.x + so.offsets[km.zmod(i, #so.offsets)].x
										s.nav_rally.pos.y = s.nav_rally.pos.y + so.offsets[km.zmod(i, #so.offsets)].y
										if center then
											s.nav_rally.center.x = s.nav_rally.pos.x
											s.nav_rally.center.y = s.nav_rally.pos.y
										end
									end
									s.nav_rally.new = true
									s.pos = V.vclone(s.nav_rally.pos)
									-- if store.main_hero then
										-- s.info.ultimate_icon = store.main_hero.info.ultimate_icon
									-- elseif s.info.ultimate_icon then
										-- s.info.ultimate_icon = "0017"
									-- end
									queue_insert(store, s)

									local result = game_gui.getPrivateVar()
									if #result < 2 then
										signal.emit("hero-added", s)
									end
									-- print(string.format("(%s) %s", result, #result))
									-- game_gui:add_hero(s)
									-- signal.emit("hero-added", s)
								end
								-- for i = 1, num do
									-- local sr = so.soldiers[i]
									-- local hero = LU.insert_hero(store, sr, rpos)
								-- end
							end
							if so.fx_list then
								for i = 1, #so.fx_list do
								local sr = so.fx_list[i]
									local s = E:create_entity(sr)
									s.pos = V.vclone(rpos)
									s.render.sprites[1].ts = store.tick_ts
									if so.offsets then
									s.pos.x = s.pos.x + so.offsets[km.zmod(i, #so.offsets)].x
									s.pos.y = s.pos.y + so.offsets[km.zmod(i, #so.offsets)].y
									end
									queue_insert(store, s)
									end
								end
							if so.auras then
							local num = #so.auras
							local source = nil
							if so.auras[#so.auras] == true then
							num = num - 1
							source = true
							end
								for i = 1, num do
								local sr = so.auras[i]
									local s = E:create_entity(sr)
									s.pos = V.vclone(rpos)
									if s.render.sprites[1] then
									s.render.sprites[1].ts = store.tick_ts
									end
									if so.offsets then
									s.pos.x = s.pos.x + so.offsets[km.zmod(i, #so.offsets)].x
									s.pos.y = s.pos.y + so.offsets[km.zmod(i, #so.offsets)].y
									end
									local target = U.find_entity_at_pos(store.entities, s.pos.x, s.pos.y, function (e)
									return e.unit and e.health and (e.soldier or e.enemy) and (e.nav_rally or e.nav_path)
									end)
									if target and s.aura and source then
									s.aura.source_id = target.id
									end
									queue_insert(store, s)
									end
								end
::more::
							end
						end
					end
				end
			end

		while true do
		
		if us then
			set_attacks()
			if #us_args > 0 and #us_poses > 0 then
			for i = 1, #us_args do
				cast_attacks(us_args[i], us_poses[i])
				us_args[i] = nil
				us_poses[i] = nil
			end
			end
		end

			coroutine.yield()
		end
	end
}

scripts.tower_arcane_wizard99 = {}

function scripts.tower_arcane_wizard99.update(this, store)
	local tower_sid = 2
	local shooter_sid = 3
	local teleport_sid = 4
	local a = this.attacks
	local ar = this.attacks.list[1]
	local ad = this.attacks.list[2]
	local at = this.attacks.list[3]
	local pow_d = this.powers.disintegrate
	local pow_t = this.powers.teleport
	local last_ts = store.tick_ts

	ar.ts = store.tick_ts

	local aura = E:get_template(at.aura)
	local max_times_applied = E:get_template(aura.aura.mod).max_times_applied
	local aa, pow
	local attacks = {
		ad,
		at,
		ar
	}
	local pows = {
		pow_d,
		pow_t
	}

	local function find_target(aa)
		local target, __, pred_pos
		if aa == ad then
			target, __, pred_pos = ULH.find_strongest_enemy_in_range(store.entities, tpos(this), 0, a.range, aa.node_prediction, aa.vis_flags, aa.vis_bans)
		else
			target, __, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, aa.node_prediction, aa.vis_flags, aa.vis_bans, function(e)
				if aa == at then
					return e.nav_path.ni >= aa.min_nodes and (not e.enemy.counts.mod_teleport or e.enemy.counts.mod_teleport < max_times_applied)
				else
					return true
				end
			end)
		end

		return target, pred_pos
	end

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					if pow == pow_d then
						if pow.level == 1 then
							ad.ts = store.tick_ts
						end

						ad.cooldown = pow.cooldown_base + pow.cooldown_inc * pow.level
					end

					if pow == pow_t and pow.level == 1 then
						at.ts = store.tick_ts
					end
				end
			end

			for i, aa in pairs(attacks) do
				pow = pows[i]

				if (not pow or pow.level > 0) and store.tick_ts - aa.ts > aa.cooldown and store.tick_ts - last_ts > a.min_cooldown then
					local enemy, pred_pos = find_target(aa)

					if not enemy then
						-- block empty
					else
						last_ts = store.tick_ts

						local soffset = this.render.sprites[shooter_sid].offset
						local an, af, ai = U.animation_name_facing_point(this, aa.animation, enemy.pos, shooter_sid, soffset)

						U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)
						U.animation_start(this, aa.animation, nil, store.tick_ts, false, tower_sid)

						if aa == at then
							this.render.sprites[teleport_sid].ts = last_ts
						end

						U.y_wait(store, aa.shoot_time)

						enemy, pred_pos = find_target(aa)

						if not enemy then
							-- block empty
						else
							aa.ts = last_ts

							local b

							if aa == at then
								b = E:create_entity(aa.aura)
								b.pos.x, b.pos.y = pred_pos.x, pred_pos.y
								b.aura.target_id = enemy.id
								b.aura.source_id = this.id
								b.aura.max_count = pow_t.max_count_base + pow_t.max_count_inc * pow_t.level
								b.aura.level = pow_t.level
							else
								b = E:create_entity(aa.bullet)
								b.pos.x, b.pos.y = this.pos.x + aa.bullet_start_offset.x, this.pos.y + aa.bullet_start_offset.y
								b.bullet.from = V.vclone(b.pos)
								b.bullet.to = V.vclone(enemy.pos)
								b.bullet.target_id = enemy.id
								b.bullet.source_id = this.id
								if aa == ar then
									b.bullet.damage_rate = this.tower.damage_factor
								end
							end

							queue_insert(store, b)
							U.y_animation_wait(this, tower_sid)
						end
					end
				end
			end

			if store.tick_ts - ar.ts > this.tower.long_idle_cooldown then
				local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid)

				U.animation_start(this, an, af, store.tick_ts, true, shooter_sid)
			end

			coroutine.yield()
		end
	end
end

scripts.mod_slow_dwaarp_lava_FL = {}

function scripts.mod_slow_dwaarp_lava_FL.insert(this, store, script)
	local factors = this.slow.level_factors

	this.slow.factor = factors[this.modifier.level] or factors[#factors]

	return scripts.mod_slow.insert(this, store, script)
end

scripts.tower_dwaarp99 = {}
function scripts.tower_dwaarp99.update(this, store, script)
	local a = this.attacks
	local aa = this.attacks.list[1]
	local la = this.attacks.list[2]
	local da = this.attacks.list[3]
	local pow_d = this.powers.drill
	local pow_l = this.powers.lava
	local lava_ready = false
	local drill_ready = false
	local std_ready = false
	local anim_id = 3

	aa.ts = store.tick_ts

	::label_86_0::

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			if pow_d.changed then
				pow_d.changed = nil

				if pow_d.level == 1 then
					da.ts = store.tick_ts
				end
			end

			if pow_l.changed then
				pow_l.changed = nil

				if pow_l.level == 1 then
					la.ts = store.tick_ts
				end
			end

			if pow_d.level > 0 and store.tick_ts - da.ts > da.cooldown + pow_d.level * da.cooldown_inc then
				drill_ready = true
			end

			if store.tick_ts - aa.ts > aa.cooldown then
				if pow_l.level > 0 and store.tick_ts - la.ts > la.cooldown then
					lava_ready = true
					this.render.sprites[4].hidden = false
					this.render.sprites[5].hidden = false
				end

				std_ready = true
			end

			if not drill_ready and not lava_ready and not std_ready then
				coroutine.yield()
			else
				if drill_ready then
					local trigger_enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, true, da.vis_flags, da.vis_bans, function(e)
						return e.health.hp_max >= 800
					end)
					if not trigger_enemy then
						trigger_enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, true, da.vis_flags, da.vis_bans)
					end


					if not trigger_enemy then
						-- block empty
					else
						drill_ready = false
						da.ts = store.tick_ts

						S:queue(da.sound)
						U.animation_start(this, "drill", nil, store.tick_ts, 1, anim_id)

						while store.tick_ts - da.ts < da.hit_time do
							coroutine.yield()
						end

						local enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, true, da.vis_flags, da.vis_bans)

						if enemy then
							local drill = E:create_entity(da.bullet)

							drill.bullet.target_id = enemy.id
							drill.pos.x, drill.pos.y = enemy.pos.x, enemy.pos.y

							queue_insert(store, drill)
						end

						while not U.animation_finished(this, anim_id) do
							coroutine.yield()
						end

						goto label_86_0
					end
				end

				local trigger_range = (lava_ready and 0.9 or 1) * a.range
				local trigger_enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, trigger_range, false, aa.vis_flags, aa.vis_bans)

				if std_ready and trigger_enemy then
					aa.ts = store.tick_ts

					if lava_ready then
						la.ts = store.tick_ts
					end

					U.animation_start(this, "shoot", nil, store.tick_ts, 1, anim_id)

					while store.tick_ts - aa.ts < aa.hit_time do
						coroutine.yield()
					end

					local enemies = table.filter(store.entities, function(k, v)
						return v.enemy and v.vis and v.health and not v.health.dead and band(v.vis.flags, aa.damage_bans) == 0 and band(v.vis.bans, aa.damage_flags) == 0 and U.is_inside_ellipse(v.pos, tpos(this), a.range)
					end)
					local alchemical_powder = UP:get_upgrade("engineer_alchemical_powder")
					local alchemical_powder_on = alchemical_powder and math.random() < alchemical_powder.chance
					local shock_and_awe = UP:get_upgrade("engineer_shock_and_awe")

					for _, enemy in pairs(enemies) do
						local d = E:create_damage()

						d.source_id = this.id
						d.target_id = enemy.id
						d.damage_type = aa.damage_type

						if alchemical_powder_on then
							d.value = aa.damage_max
						else
							d.value = math.random(aa.damage_min, aa.damage_max)
						end

						d.value = math.ceil(this.tower.damage_factor * d.value)

						queue_damage(store, d)

						if aa.mod then
							local mod = E:create_entity(aa.mod)

							mod.modifier.target_id = enemy.id

							queue_insert(store, mod)
						end

						if shock_and_awe and band(enemy.vis.bans, F_STUN) == 0 and band(enemy.vis.flags, bor(F_BOSS, F_CLIFF, F_FLYING)) == 0 and math.random() < shock_and_awe.chance then
							local mod = E:create_entity("mod_shock_and_awe")

							mod.modifier.target_id = enemy.id

							queue_insert(store, mod)
						end
					end

					for i = 1, #this.fx_points do
						local p = this.fx_points[i]

						if lava_ready then
							local lava = E:create_entity(la.bullet)

							lava.pos.x, lava.pos.y = p.pos.x, p.pos.y
							lava.aura.ts = store.tick_ts
							lava.aura.source_id = this.id
							lava.aura.level = pow_l.level

							queue_insert(store, lava)
						end

						if band(p.terrain, TERRAIN_WATER) ~= 0 then
							local smoke = E:create_entity("decal_dwaarp_smoke_water")

							smoke.pos.x, smoke.pos.y = p.pos.x, p.pos.y
							smoke.render.sprites[1].ts = store.tick_ts + math.random() * 5 / FPS

							queue_insert(store, smoke)

							if lava_ready then
								local vapor = E:create_entity("decal_dwaarp_scorched_water")

								vapor.render.sprites[1].ts = store.tick_ts + U.frandom(0, 0.5)
								vapor.pos.x, vapor.pos.y = p.pos.x + U.frandom(-5, 5), p.pos.y + U.frandom(-5, 5)

								if math.random() < 0.5 then
									vapor.render.sprites[1].flip_x = true
								end

								queue_insert(store, vapor)
							end
						else
							local decal = E:create_entity("decal_tween")

							decal.pos.x, decal.pos.y = p.pos.x, p.pos.y
							decal.tween.props[1].keys = {
								{
									0,
									255
								},
								{
									1,
									255
								},
								{
									2.5,
									0
								}
							}
							decal.tween.props[1].name = "alpha"

							if math.random() < 0.5 then
								decal.render.sprites[1].name = "EarthquakeTower_HitDecal1"
							else
								decal.render.sprites[1].name = "EarthquakeTower_HitDecal2"
							end

							decal.render.sprites[1].animated = false
							decal.render.sprites[1].z = Z_DECALS
							decal.render.sprites[1].ts = store.tick_ts

							queue_insert(store, decal)

							local smoke = E:create_entity("decal_dwaarp_smoke")

							smoke.pos.x, smoke.pos.y = p.pos.x, p.pos.y
							smoke.render.sprites[1].ts = store.tick_ts + math.random() * 5 / FPS

							queue_insert(store, smoke)

							if lava_ready then
								local scorch = E:create_entity("decal_dwaarp_scorched")

								if math.random() < 0.5 then
									scorch.render.sprites[1].name = "EarthquakeTower_Lava2"
								end

								scorch.pos.x, scorch.pos.y = p.pos.x, p.pos.y
								scorch.render.sprites[1].ts = store.tick_ts

								queue_insert(store, scorch)
							end
						end
					end

					if lava_ready then
						local tower_scorch = E:create_entity("decal_dwaarp_tower_scorched")

						tower_scorch.pos.x, tower_scorch.pos.y = this.pos.x, this.pos.y + 10
						tower_scorch.render.sprites[1].ts = store.tick_ts

						queue_insert(store, tower_scorch)
					end

					local pulse = E:create_entity("decal_dwaarp_pulse")

					pulse.pos.x, pulse.pos.y = this.pos.x, this.pos.y + 16
					pulse.render.sprites[1].ts = store.tick_ts

					queue_insert(store, pulse)

					if lava_ready then
						S:queue(la.sound)
					end

					S:queue(aa.sound)

					while not U.animation_finished(this, anim_id) do
						coroutine.yield()
					end

					std_ready = false
					lava_ready = false
					this.render.sprites[4].hidden = true
					this.render.sprites[5].hidden = true
				end

				U.animation_start(this, "idle", nil, store.tick_ts, -1, anim_id)
				coroutine.yield()
			end
		end
	end
end

scripts.tower_silver99 = {}
function scripts.tower_silver.update(this, store)
	local a = this.attacks
	local aa = this.attacks.list[1]
	local as = this.attacks.list[2]
	local am = this.attacks.list[3]
	local pow_s = this.powers.sentence
	local pow_m = this.powers.mark
	local sid = 3

	local function is_long(enemy)
		return V.dist(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) > a.short_range
	end

	local function y_do_shot(attack, enemy, level)
		S:queue(attack.sound, attack.sound_args)

		local lidx = is_long(enemy) and 2 or 1
		local soffset = this.render.sprites[sid].offset
		local an, af, ai = U.animation_name_facing_point(this, attack.animations[lidx], enemy.pos, sid, soffset)

		U.animation_start(this, an, af, store.tick_ts, false, sid)

		local shoot_time = attack.shoot_times[lidx]

		U.y_wait(store, shoot_time)

		if V.dist(tpos(this).x, tpos(this).y, enemy.pos.x, enemy.pos.y) <= a.range then
			local boffset = attack.bullet_start_offsets[lidx][ai]
			local b = E:create_entity(attack.bullets[lidx])

			b.pos.x = this.pos.x + soffset.x + boffset.x * (af and -1 or 1)
			b.pos.y = this.pos.y + soffset.y + boffset.y
			b.bullet.from = V.vclone(b.pos)
			b.bullet.to = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
			b.bullet.target_id = enemy.id
			b.bullet.level = level or 0
			b.bullet.damage_factor = this.tower.damage_factor

			local dist = V.dist(b.bullet.to.x, b.bullet.to.y, b.bullet.from.x, b.bullet.from.y)

			b.bullet.flight_time = b.bullet.flight_time_min + dist * b.bullet.flight_time_factor
			if enemy.health.hp_max >= 1200 and pow_s and pow_s.level > 0 then
				b.bullet.damage_factor = (0.5+1.5*pow_s.level) * b.bullet.damage_factor
				b.bullet.reduce_armor = 0.4
			end
			
			if attack.critical_chances and math.random() < attack.critical_chances[lidx] then
				b.bullet.damage_factor = 2 * b.bullet.damage_factor
				b.bullet.pop = {
					"pop_crit"
				}
				b.bullet.pop_conds = DR_DAMAGE
				b.bullet.damage_type = DAMAGE_TRUE
			end

			if attack.use_obsidian_upgrade then
				local u = UP:get_upgrade("archer_el_obsidian_heads")

				if u and enemy.health and enemy.health.armor == 0 then
					b.bullet.damage_min = b.bullet.damage_max
				end
			end

			queue_insert(store, b)

			if attack.shot_fx then
				local fx = E:create_entity(attack.shot_fx)

				fx.pos.x, fx.pos.y = b.bullet.from.x, b.bullet.from.y

				local bb = b.bullet

				fx.render.sprites[1].r = V.angleTo(bb.to.x - bb.from.x, bb.to.y - bb.from.y)
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)
			end
		end

		U.y_animation_wait(this, sid)

		an, af = U.animation_name_facing_point(this, "idle", enemy.pos, sid, soffset)

		U.animation_start(this, an, af, store.tick_ts, true, sid)
	end

	local function reset_cooldowns(long)
		aa.ts = store.tick_ts
		as.ts = store.tick_ts
		aa.cooldown = long and aa.cooldowns[2] or aa.cooldowns[1]
		as.cooldown = long and as.cooldowns[2] or as.cooldowns[1]
	end

	aa.ts = store.tick_ts

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					if pow.level == 1 then
						local pa = this.attacks.list[pow.attack_idx]

						pa.ts = store.tick_ts
					end
				end
			end

			if pow_m.level > 0 and store.tick_ts - am.ts > am.cooldown then
				local enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, am.vis_flags, am.vis_bans, function(e)
					return not U.has_modifiers(store, e, "mod_arrow_silver_mark")
				end)

				if enemy then
					am.ts = store.tick_ts

					reset_cooldowns(is_long(enemy))
					y_do_shot(am, enemy, pow_m.level)
				end
			end

			if pow_s.level > 0 and store.tick_ts - as.ts > as.cooldown then
				local enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, as.vis_flags, as.vis_bans)

				if enemy then
					local long = is_long(enemy)
					local lidx = long and 2 or 1
					local chance = pow_s.chances[lidx][pow_s.level]

					as.ts = store.tick_ts

					if chance > math.random() then
						reset_cooldowns(long)
						y_do_shot(as, enemy, pow_s.level)
					end
				end
			end

			if store.tick_ts - aa.ts > aa.cooldown then
				local enemy = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, false, aa.vis_flags, aa.vis_bans)

				if enemy then
					reset_cooldowns(is_long(enemy))
					y_do_shot(aa, enemy)
				end
			end

			if store.tick_ts - aa.ts > this.tower.long_idle_cooldown then
				local an, af = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, sid)

				U.animation_start(this, an, af, store.tick_ts, true, sid)
			end

			coroutine.yield()
		end
	end
end

scripts.druid_shooter_sylvan99 = {}

function scripts.druid_shooter_sylvan99.update(this, store)
	local a = this.attacks.list[1]

	a.ts = store.tick_ts

	while true do
		if this.owner.tower.blocked or not this.owner.tower.can_do_magic then
			-- block empty
		elseif store.tick_ts - a.ts > a.cooldown then
			SU.delay_attack(store, a, 1)

			local target, targets, _ = ULH.find_strongest_enemy_in_range(store.entities, this.owner.pos, 0, a.range, false, a.vis_flags, a.vis_bans, function(v)
				return not table.contains(a.excluded_templates, v.template_name) and not SU.has_modifiers(store, v, "mod_druid_sylvan")
			end)

			if targets then
				S:queue(a.sound)
				U.animation_start(this, a.animation, nil, store.tick_ts)
				U.y_wait(store, a.cast_time)

				a.ts = store.tick_ts

				local mod = E:create_entity(a.spell)

				mod.modifier.target_id = targets[1].id
				mod.modifier.level = this.owner.powers.sylvan.level

				queue_insert(store, mod)
			end
		end

		coroutine.yield()
	end
end

scripts.tower_shaolin99 = {}
function scripts.tower_shaolin99.update(this, store)
	local a = this.attacks
	this.pixies = {}
	a.ts = store.tick_ts
	this.idle_offsets = {v(-18, -1),v(21, -3),v(5, -9),
		v(-18, -1),v(21, -3),v(5, -9),v(-18, -1),v(21, -3),v(5, -9)}
	local pow_d = this.powers and this.powers.dragon
	local pow_l = this.powers and this.powers.lion
	local pow_t = this.powers and this.powers.total
	local enemy_cooldowns = {}
	local ba = this.barrack

	local function spawn_pixie()
		local e = E:create_entity("decal_shaolin_lvl"..this.tower.level)
		local po = this.idle_offsets[#this.pixies + 1]

		e.idle_pos = po
		e.pos.x, e.pos.y = this.pos.x + po.x, this.pos.y + po.y

		queue_insert(store, e)
		table.insert(this.pixies, e)
		e.render.sprites[1].hidden = true

		e.owner = this
	end

	spawn_pixie()
	spawn_pixie()
	spawn_pixie()
	if this.tower.level >= 3 then
		spawn_pixie()
	end

	this.anim_play_out = false
	this.anim_play_in = false
	while true do
		if this.tower.blocked then
			-- block empty
		else
			if pow_t and pow_t.changed and #this.pixies < 8 then
				pow_t.changed = nil

				spawn_pixie()
				if pow_t.level == 3 then
					spawn_pixie()
				end
			end

			if pow_l and pow_l.changed then
				pow_l.changed = nil
				this.render.sprites[5].hidden = false
				if this.aura1 == nil then
					local e = E:create_entity("aura_tower_shaolin_gold")
					e.pos = V.vclone(this.pos)
					e.aura.level = 1
					e.aura.source_id = this.id
					e.aura.ts = store.tick_ts
								
					this.aura1 = e
								
					if this.powers and this.powers.lion.level >= 1 then
						queue_insert(store, e)				
					end
				end
			end
			

			if pow_d and pow_d.level > 0 then
					if pow_d.changed then
						pow_d.changed = nil
	
						local s = ba.soldiers[1]
	
						if s and store.entities[s.id] then
							s.unit.level = pow_d.level
							s.health.armor = s.health.armor
							s.health.hp_max = s.health.hp_max
							s.health.hp = s.health.hp_max
	
							local ma = s.melee.attacks[1]
	
							ma.damage_min = ma.damage_min
							ma.damage_max = ma.damage_max
						end
					end
	
					local s = ba.soldiers[1]
	
					if s and s.health.dead then
						last_soldier_pos = s.pos
					end
	
					if not s or s.health.dead and store.tick_ts - s.health.death_ts > s.health.dead_lifetime then
						local ns = E:create_entity(ba.soldier_type)
	
						ns.soldier.tower_id = this.id
						--print("tower_id: "..this.id)
						--ns.pos = last_soldier_pos or V.v(ba.rally_pos.x, ba.rally_pos.y)
						if not ba.rally_pos and this.tower.default_rally_pos then
							ba.rally_pos = V.vclone(this.tower.default_rally_pos)
						end
						ns.pos = V.v(ba.rally_pos.x, ba.rally_pos.y)
						ns.nav_rally.pos = V.vclone(ba.rally_pos)
						ns.nav_rally.center = V.vclone(ba.rally_pos)
						ns.nav_rally.new = true
						ns.unit.level = 1
						ns.health.armor = ns.health.armor
						ns.health.hp_max = ns.health.hp_max
	
						local ma = ns.melee.attacks[1]
	
						ma.damage_min = ma.damage_min
						ma.damage_max = ma.damage_max
	
						queue_insert(store, ns)
	
						ba.soldiers[1] = ns
						s = ns
					end
	
					if ba.rally_new then
						ba.rally_new = false
	
						signal.emit("rally-point-changed", this)
						--print("rally changed: "..this.id)
	
						if s then
							s.nav_rally.pos = V.vclone(ba.rally_pos)
							s.nav_rally.center = V.vclone(ba.rally_pos)
							s.nav_rally.new = true
	
							if not s.health.dead then
								S:queue(this.sound_events.change_rally_point)
							end
						end
					end
			end

			if store.tick_ts - a.ts > a.cooldown then
				for pixie_count, pixie in pairs(this.pixies) do
					local target, attack

					if pixie.target or store.tick_ts - pixie.attack_ts <= a.pixie_cooldown then
						-- block empty
					else
						attack = a.list[1]

						if not attack then
							-- block empty
						else
							target = U.find_foremost_enemy(store.entities, this.pos, 0, a.range,false, attack.vis_flags, attack.vis_bans, function(e)
								return not table.contains(a.excluded_templates, e.template_name) and (not enemy_cooldowns[e.id] or enemy_cooldowns[e.id] < store.tick_ts)
							end)

							if not target then
								-- block empty
							else
								if pixie_count == 1 then
									this.anim_play_out = true
								end
								enemy_cooldowns[target.id] = store.tick_ts + a.enemy_cooldown
								pixie.attack_ts = store.tick_ts
								pixie.target_id = target.id
								pixie.attack = attack
								pixie.attack_level = pixie_count
								a.ts = store.tick_ts

								break
							end
						end
					end
				end
			end
			if this.anim_play_in == true then 
				U.y_animation_play(this, "in", nil, store.tick_ts, false, 3)
				U.y_animation_play(this, "in", nil, store.tick_ts, false, 4)
				this.anim_play_in = false
			end

			if this.anim_play_out == true then 
				U.y_animation_play(this, "out", nil, store.tick_ts, false, 3)
				U.y_animation_play(this, "out", nil, store.tick_ts, false, 4)
				this.anim_play_out = false
			end
		end

		coroutine.yield()
	end
end

scripts.tower_arcane_wizard599 = {}
function scripts.tower_arcane_wizard599.update(this, store)
	local shooter_sid = this.render.sid_shooter
	local a = this.attacks
	local ar = this.attacks.list[1]
	local ad = this.attacks.list[2]
	local ae = this.attacks.list[3]
	local pow_d = this.powers and this.powers.disintegrate or nil
	local pow_e = this.powers and this.powers.empowerment or nil
	local last_ts = store.tick_ts - ar.cooldown

	a._last_target_pos = a._last_target_pos or v(REF_W, 0)
	ar.ts = store.tick_ts - ar.cooldown + a.attack_delay_on_spawn

	local attacks = {}
	local pows = {}
	local empowerments_previews
	local first_time_empower = true

	if ad then
		table.insert(attacks, ad)
		table.insert(pows, pow_d)
	end

	if ae then
		table.insert(attacks, ae)
		table.insert(pows, pow_e)
	end

	if ar then
		table.insert(attacks, ar)
		table.insert(pows, nil)
	end

	local function find_target(aa)

		local target
		local targets
		local pred_pos
		if aa == ar then
			target, targets, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, aa.node_prediction, aa.vis_flags, aa.vis_bans, function(e)
				return not aa.excluded_templates or not table.contains(aa.excluded_templates, e.template_name)
			end)
		else
			target, targets, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, aa.node_prediction, aa.vis_flags, aa.vis_bans, function(e)
				return (not aa.excluded_templates or not table.contains(aa.excluded_templates, e.template_name) ) and band(bor(F_BOSS, F_MINIBOSS),e.vis.flags) ~= 0
			end)
			if not target then
				target, targets, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, a.range, aa.node_prediction, aa.vis_flags, aa.vis_bans, function(e)
					return not aa.excluded_templates or not table.contains(aa.excluded_templates, e.template_name)
				end)
			end
		end



		return target, pred_pos
	end

	do
		local soffset = this.shooter_offset
		local an, af, ai = U.animation_name_facing_point(this, "idle", a._last_target_pos, shooter_sid, soffset)

		U.animation_start_group(this, an, false, store.tick_ts, false, "layers")
	end

	::label_666_0::

	while true do
		ae.max_range = a.range * 1.15
		if this.tower.blocked then
			coroutine.yield()
		else
			if this.powers then
				for k, pow in pairs(this.powers) do
					if pow.changed then
						pow.changed = nil

						if pow == pow_d then
							ad.cooldown = pow.cooldown[pow.level]

							if pow.level == 1 then
								ad.ts = store.tick_ts - ad.cooldown
							end
						end

						if pow == pow_e then
							ae.cooldown = pow.cooldown[pow.level]
							ae.ts = store.tick_ts - ae.cooldown
						end
					end
				end
			end

			SU5.towers_swaped(store, this, this.attacks.list)

			if this.ui.hover_active and this.ui.args == "empowerment" and not empowerments_previews and pow_e and pow_e.level == 0 then
				empowerments_previews = {}

				local targets = table.filter(store.entities, function(k, v)
					return v.tower and v.tower.type == "holder" and v.ui.can_click and U.is_inside_ellipse(v.pos, this.pos, ae.max_range) or v.tower and not v.pending_removal and not v.tower.blocked and (not ae.excluded_templates or not table.contains(ae.excluded_templates, v.template_name)) and U.is_inside_ellipse(v.pos, this.pos, ae.max_range) and (ae.min_range == 0 or not U.is_inside_ellipse(v.pos, this.pos, ae.min_range)) and v.vis and band(v.vis.flags, ae.vis_bans) == 0 and band(v.vis.bans, ae.vis_flags) == 0 and not table.contains(ae.exclude_tower_kind, v.tower.kind) and not U.has_modifiers(store, v, ae.mod) and v.tower.can_be_mod
				end)

				if ae.include_self and this.tower.can_be_mod and not table.contains(ae.exclude_tower_kind, this.tower.kind) and not U.has_modifiers(store, this, ae.mod) then
					targets = targets or {}

					if not table.contains(targets, this) then
						table.insert(targets, this)
					end
				end

				if targets then
					for _, target in pairs(targets) do
						local decal = E:create_entity("decal_tower_arcane_wizard_empowerment_preview")

						decal.pos = target.pos
						decal.render.sprites[1].ts = store.tick_ts

						queue_insert(store, decal)
						table.insert(empowerments_previews, decal)
					end
				end
			elseif empowerments_previews and (not this.ui.hover_active or this.ui.args ~= "empowerment") then
				for _, decal in pairs(empowerments_previews) do
					queue_remove(store, decal)
				end

				empowerments_previews = nil
			end

			for i, aa in pairs(attacks) do
				local pow = pows[i]

				if (not pow or pow.level > 0) and store.tick_ts - aa.ts > aa.cooldown and store.tick_ts - last_ts > a.min_cooldown then
					if aa == ae then
						--奥术增伤
						local towers = U.find_towers_in_range(store.entities, this.pos, ae, function(t)
							local has_mod, mods = U.has_modifiers(store, t, ae.mod)
							local max_factor = 1

							if has_mod and mods and #mods >= 1 then
								for k, v in pairs(mods) do
									if max_factor < v.damage_factor then
										max_factor = v.damage_factor
									end
								end
							end

							--前3代当中vis是nil，导致无法判定 mod by 流辉349
							--return t.tower.can_be_mod and max_factor < pow.damage_factor[pow.level] and band(t.vis.flags, ae.vis_bans) == 0 and band(t.vis.bans, ae.vis_flags) == 0 and not table.contains(ae.exclude_tower_kind, t.tower.kind)
							return t.tower.can_be_mod and max_factor < pow.damage_factor[pow.level] and not table.contains(ae.exclude_tower_kind, t.tower.kind)
						end)

						if ae.include_self then
							local has_mod, mods = U.has_modifiers(store, this, ae.mod)
							local max_factor = 1

							if has_mod and mods and #mods >= 1 then
								for k, v in pairs(mods) do
									if max_factor < v.damage_factor then
										max_factor = v.damage_factor
									end
								end
							end

							if this.tower.can_be_mod and max_factor < pow.damage_factor[pow.level] and not table.contains(ae.exclude_tower_kind, this.tower.kind) then
								towers = towers or {}

								if not table.contains(towers, this) then
									table.insert(towers, this)
								end
							end
						end

						if not towers or #towers <= 0 then
							SU.delay_attack(store, ae, ae.cooldown)
						else
							local start_ts = store.tick_ts

							if first_time_empower then
								U.animation_start_group(this, aa.animation, false, store.tick_ts, false, "layers")
								U.y_wait(store, aa.shoot_time)

								first_time_empower = false
								last_ts = store.tick_ts
							end

							for _, tower in ipairs(towers) do
								local mark_mod = E:create_entity(ae.mark_mod)

								mark_mod.modifier.source_id = this.id
								mark_mod.modifier.target_id = tower.id

								queue_insert(store, mark_mod)

								local has_mod, mods = U.has_modifiers(store, tower, ae.mod)
								local max_factor = 1

								if mods and #mods >= 1 then
									for k, v in pairs(mods) do
										if max_factor < v.damage_factor then
											max_factor = v.damage_factor
										end
									end
								end
							end

							S:queue(a.sound)

							for _, tower in ipairs(towers) do
								local m = E:create_entity(ae.mod)

								m.modifier.source_id = this.id
								m.modifier.target_id = tower.id
								m.modifier.level = pow.level
								m.damage_factor = pow.damage_factor[pow.level]

								queue_insert(store, m)

								m = E:create_entity(ae.mod_fx)
								m.modifier.source_id = this.id
								m.modifier.target_id = tower.id
								m.modifier.level = pow.level
								m.pos.x, m.pos.y = tower.pos.x, tower.pos.y

								queue_insert(store, m)
							end

							ae.ts = start_ts

							U.y_animation_wait_group(this, "layers")

							goto label_666_0
						end
					else
						local enemy, pred_pos = find_target(aa)

						if not enemy then
							SU.delay_attack(store, aa, fts(10))
						else
							local enemy_id = enemy.id
							local enemy_pos = enemy.pos

							last_ts = store.tick_ts

							if aa == ad then
								S:queue(ad.sound)
							end

							local soffset = this.shooter_offset
							local an, af, ai = U.animation_name_facing_point(this, aa.animation, enemy.pos, shooter_sid, soffset)

							a._last_target_pos.x, a._last_target_pos.y = enemy.pos.x, enemy.pos.y

							U.animation_start_group(this, an, false, store.tick_ts, false, "layers")

							local b = E:create_entity(aa.bullet)
							local start_offset = table.safe_index(aa.bullet_start_offset, ai)

							if aa.load_time then
								U.y_wait(store, aa.load_time)

								if b.bullet.out_fx then
									local fx = E:create_entity(b.bullet.out_fx)

									fx.pos.x, fx.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
									fx.render.sprites[1].ts = store.tick_ts

									queue_insert(store, fx)

									this.ray_fx_start = fx
								end

								U.y_wait(store, aa.shoot_time - aa.load_time)
							else
								U.y_wait(store, aa.shoot_time)

								if b.bullet.out_fx then
									local fx = E:create_entity(b.bullet.out_fx)

									fx.pos.x, fx.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
									fx.render.sprites[1].ts = store.tick_ts

									queue_insert(store, fx)

									this.ray_fx_start = fx
								end
							end

							enemy, pred_pos = find_target(aa)

							if enemy then
								enemy_id = enemy.id
								enemy_pos = enemy.pos

								if aa == ad then
									local is_boss = U.flag_has(enemy.vis.flags, bor(F_BOSS, F_MINIBOSS))

									if not is_boss then
										enemy.vis.bans = F_ALL
									end
								end
							end

							aa.ts = last_ts
							b.bullet.damage_min = b.bullet.damage_min_config[this.tower.level]
							b.bullet.damage_max = b.bullet.damage_max_config[this.tower.level]
							b.pos.x, b.pos.y = this.pos.x + start_offset.x, this.pos.y + start_offset.y
							b.bullet.from = V.vclone(b.pos)
							b.bullet.to = V.vclone(enemy_pos)
							b.bullet.target_id = enemy_id
							b.bullet.source_id = this.id
							b.bullet.damage_factor = this.tower.damage_factor
							b.tower_ref = this

							if aa == ad then
								b.bullet.level = pow_d.level
							else
								b.bullet.level = this.tower.level
							end

							queue_insert(store, b)
							U.y_animation_wait_group(this, "layers")

							goto label_666_0
						end
					end
				end
			end

			if store.tick_ts - ar.ts > this.tower.long_idle_cooldown then
				local soffset = this.shooter_offset
				local an, af, ai = U.animation_name_facing_point(this, "idle", this.tower.long_idle_pos, shooter_sid, soffset)

				U.animation_start_group(this, an, false, store.tick_ts, true, "layers")
			end

			coroutine.yield()
		end
	end
end

scripts.soldier_tower_rocket_gunners99 = {}
function scripts.soldier_tower_rocket_gunners99.update(this, store, script)
	local brk, sta
	local tower = store.entities[this.soldier.tower_id]
	--流辉349 当前没做切换按钮，默认只有空军形态
	--local is_taking_off = true
	local is_taking_off = true --tower.tower_upgrade_persistent_data.is_taking_off[this.soldier.tower_soldier_idx]
	local last_target_pos

	if is_taking_off then
		this.vis.bans = bor(this.vis.bans, F_RANGED)
	end
	this.melee.attacks[1].level = this.unit.level
	this.ranged.attacks[1].level = this.unit.level
	this.vis.flags = bor(this.vis.flags, F_FLYING)
	this._max_speed = this.motion.max_speed

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	local MODE_FLY = 0
	local MODE_GROUND = 1

	local function adjust_position_reference(mode)
		mode = mode or this.current_mode
		this.ui.click_rect.pos.y = this.render.sprites[1].offset.y + this.ui.click_rect_offset_y
		this.unit.hit_offset.y = this.render.sprites[1].offset.y + 12
		this.unit.mod_offset.y = this.render.sprites[1].offset.y + 13

		if this.ranged.attacks[3] then
			this.ranged.attacks[3].bullet_start_offset = {
				v(this.ranged.attacks[3].bullet_start_offset_relative.x, this.render.sprites[1].offset.y + this.ranged.attacks[3].bullet_start_offset_relative.y)
			}
		end

		if mode == MODE_GROUND then
			local new_height = U5.ease_value(this.health_bar.offset.y, this.health_bar.y_offset, store.tick_length * 10, "linear")

			this.health_bar.offset.y = new_height
		else
			local new_height = U5.ease_value(this.health_bar.offset.y, this.flight_height + this.health_bar.y_offset, store.tick_length * 10, "linear")

			this.health_bar.offset.y = new_height
		end
	end

	local function adjust_height(mode, strength_down)
		mode = mode or this.current_mode

		local height_dest = this.flight_height
		local easing = "quart-in"
		local strength = 1.5

		if mode == MODE_GROUND then
			height_dest = 0
			easing = "expo-in"
			strength = strength_down or 2
		end

		local new_height = U5.ease_value(this.render.sprites[1].offset.y, height_dest, store.tick_length * strength, easing)

		this.render.sprites[1].offset.y = km.clamp(0, this.flight_height, new_height)

		adjust_position_reference(mode)

		this.drag_line_origin_offset.y = height_dest
	end

	local function check_tower_damage_factor()
		if store.entities[this.soldier.tower_id] then
			for _, a in ipairs(this.melee.attacks) do
				if not a._original_damage_min then
					a._original_damage_min = a.damage_min
				end

				if not a._original_damage_max then
					a._original_damage_max = a.damage_max
				end

				a.damage_min = a._original_damage_min * store.entities[this.soldier.tower_id].tower.damage_factor
				a.damage_max = a._original_damage_max * store.entities[this.soldier.tower_id].tower.damage_factor
			end
		end
	end

	local function y_soldier_new_rally_custom(store, this)
		log.debug("enter rally")

		local r = this.nav_rally
		local out = false
		local prev_immune = this.health.immune_to

		this.health.immune_to = r.immune_to

		if r.new then
			r.new = false

			U5.unblock_target(store, this)
			U5.set_destination(this, r.pos)

			if r.delay_max then
				U5.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop)

				local index = this.soldier.tower_soldier_idx or 0
				local tower = store.entities[this.soldier.tower_id]
				local total = tower and tower.barrack.max_soldiers or 1

				log.debug(index .. " asdfa " .. total)

				if SU5.y_soldier_wait(store, this, index / total * r.delay_max) then
					goto label_818_0
				end
			end

			local an, af = U5.animation_name_facing_point(this, "walk", this.motion.dest)

			U5.animation_start(this, an, af, store.tick_ts, -1)

			local start_ts = store.tick_ts

			if is_taking_off then
				this.vis.bans = this.vis_bans_before_take_off
				this.shadow_decal = E:create_entity(this.shadow_decal_t)
				this.shadow_decal.pos = this.pos
				this.shadow_decal.soldier_height = this.flight_height
				this.shadow_decal.entity = this

				queue_insert(store, this.shadow_decal)

				local dest = V.vclone(r.pos)

				this.render.sprites[1].sort_y_offset = this.spawn_sort_y_offset
				this.tween.disabled = true
				this.tween.props[1].disabled = true
				this.render.sprites[1].scale = v(0.9, 0.9)

				U5.y_animation_play(this, "take_off", nil, store.tick_ts, 1)

				this.render.sprites[1].scale = v(1, 1)

				U5.animation_start(this, "idle_air", nil, store.tick_ts, true)

				this.idle_flip.last_animation = "idle_air"

				local fx = E:create_entity(this.spawn_fx)

				fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
				fx.render.sprites[1].ts = store.tick_ts

				queue_insert(store, fx)

				while not this.motion.arrived do
					adjust_height()

					local easing = "quart-inout"

					this.pos.x = U5.ease_value(this.pos.x, dest.x, (store.tick_ts - start_ts) / 30, easing)
					this.pos.y = U5.ease_value(this.pos.y, dest.y, (store.tick_ts - start_ts) / 30, easing)

					local vx, vy = V.sub(dest.x, dest.y, this.pos.x, this.pos.y)
					local v_len = V.len(vx, vy)

					if v_len <= this.arrive_epsilon then
						this.motion.arrived = true
					end

					if tower and tower.tower.upgrade_to then
						is_taking_off = false

						break
					end

					coroutine.yield()
				end

				is_taking_off = false
				tower.tower_upgrade_persistent_data.is_taking_off[this.soldier.tower_soldier_idx] = false
				this.tween.disabled = false
				this.tween.props[1].disabled = false
				this.tween.props[1].ts = store.tick_ts
				this.render.sprites[1].sort_y_offset = 0
				this.motion.max_speed = this.speed_flight
				this.melee.attacks[1].disabled = true
				this.current_mode = MODE_FLY
			elseif this.current_mode == MODE_FLY or V.dist2(r.pos.x, r.pos.y, this.pos.x, this.pos.y) < this.max_dist_walk * this.max_dist_walk then
				local start_ts = store.tick_ts
				local time_to_accel = 0.7
				local dist_to_break = 50
				local vx, vy = V.sub(r.pos.x, r.pos.y, this.pos.x, this.pos.y)
				local dist2 = V.len2(vx, vy)

				while not this.motion.arrived do
					if this.health.dead or this.unit.is_stunned then
						out = true

						break
					end

					if r.new and not is_taking_off then
						out = false

						break
					end

					if this.change_mode and this.current_mode == MODE_GROUND and dist2 > this.max_dist_walk * this.max_dist_walk then
						out = false

						break
					end

					if this.current_mode == MODE_FLY then
						local vx, vy = V.sub(r.pos.x, r.pos.y, this.pos.x, this.pos.y)
						local dist = V.len(vx, vy)

						if dist_to_break < dist then
							local ease_step = (store.tick_ts - start_ts) / time_to_accel

							this.motion.max_speed = U5.ease_value(0, this._max_speed, ease_step, "quad-in")
						else
							local ease_step = dist / dist_to_break

							this.motion.max_speed = U5.ease_value(20, this._max_speed, ease_step, "quad-in")
						end
					end

					U5.walk(this, store.tick_length)

					this.motion.speed.x, this.motion.speed.y = 0, 0

					coroutine.yield()
				end
			else
				local start_ts = store.tick_ts
				local time_to_accel = 0.7
				local dist_to_break = 60
				local breaking = false

				U5.animation_start(this, "take_off", nil, store.tick_ts, false)

				while not this.motion.arrived do
					if this.health.dead or this.unit.is_stunned then
						out = true

						break
					end

					if this.change_mode then
						out = false

						break
					end

					adjust_height(breaking and MODE_GROUND or MODE_FLY, 1)

					if U5.animation_finished(this) and this.render.sprites[1].name == "take_off" then
						U5.animation_start(this, "idle_air", nil, store.tick_ts, true)
					end

					local vx, vy = V.sub(r.pos.x, r.pos.y, this.pos.x, this.pos.y)
					local dist = V.len(vx, vy)

					if dist_to_break < dist then
						local ease_step = (store.tick_ts - start_ts) / time_to_accel

						this.motion.max_speed = U5.ease_value(0, this._max_speed, ease_step, "quad-in")
					else
						breaking = true

						local ease_step = dist / dist_to_break

						this.motion.max_speed = U5.ease_value(20, this._max_speed, ease_step, "quad-in")

						if this.current_mode == MODE_GROUND and this.render.sprites[1].name == "idle_air" then
							U5.animation_start(this, "take_off", nil, store.tick_ts, false)
						end
					end

					U5.walk(this, store.tick_length)

					this.motion.speed.x, this.motion.speed.y = 0, 0

					coroutine.yield()
				end
			end
		end

		::label_818_0::

		this.motion.max_speed = this.speed_ground
		this.vis.bans = this.vis_bans_after_take_off
		this.health.immune_to = prev_immune

		return out
	end

	local function change_mode_fly()
		this.motion.max_speed = this.speed_flight
		this.ranged.attacks[1].animation = "attack_air"
		this.melee.attacks[1].disabled = true

		if this.melee.attacks[2] then
			this.melee.attacks[2].disabled = true
		end

		if this.ranged.attacks[2] then
			this.ranged.attacks[2].animation = "phosphoric_coating_air"
		end

		if this.ranged.attacks[3] then
			this.ranged.attacks[3].animation = "sting_missiles_air"
		end

		this.unit.death_animation = "death_air"
		this.unit.hide_after_death = true

		local land_fx = E:create_entity(this.land_fx)

		land_fx.render.sprites[1].ts = store.tick_ts
		land_fx.pos = this.pos

		queue_insert(store, land_fx)
		S:queue(this.sound_take_off)
		U5.y_animation_play(this, "take_off", nil, store.tick_ts, 1)
		U5.animation_start(this, "idle_air", nil, store.tick_ts, true)

		this.idle_flip.last_animation = "idle_air"

		while this.render.sprites[1].offset.y < this.flight_height - this.arrive_epsilon do
			adjust_height()
			coroutine.yield()
		end

		U5.y_wait(store, 0.2 * this.soldier.tower_soldier_idx)

		this.tween.props[1].disabled = false
		this.tween.disabled = false
		this.tween.props[1].ts = store.tick_ts
		this.render.sprites[1].angles.walk = {
			"idle_air"
		}
		this.vis.flags = bor(this.vis.flags, F_FLYING)
	end

	local function change_mode_ground()
		this.motion.max_speed = this.speed_ground
		this.ranged.attacks[1].animation = "attack_floor"
		this.unit.death_animation = "death_floor"
		this.unit.hide_after_death = false

		if this.powers and this.powers.phosphoric.level > 0 then
			this.melee.attacks[1].disabled = true
			this.melee.attacks[2].disabled = false
		else
			this.melee.attacks[1].disabled = false
		end

		if this.ranged.attacks[2] then
			this.ranged.attacks[2].animation = "phosphoric_coating_floor"
		end

		if this.ranged.attacks[3] then
			this.ranged.attacks[3].animation = "sting_missiles_floor"
		end

		this.tween.props[1].disabled = true
		this.tween.disabled = true

		local land_fx_ready = false

		while this.render.sprites[1].offset.y > this.arrive_epsilon do
			adjust_height()

			if not land_fx_ready and this.render.sprites[1].offset.y < this.distance_to_land_fx then
				land_fx_ready = true

				local land_fx = E:create_entity(this.land_fx)

				land_fx.render.sprites[1].ts = store.tick_ts
				land_fx.pos = this.pos

				queue_insert(store, land_fx)
			end

			coroutine.yield()
		end

		U5.y_animation_play(this, "landing", nil, store.tick_ts, 1)
		U5.animation_start(this, "idle_floor", nil, store.tick_ts, 1)

		this.idle_flip.last_animation = "idle_floor"
		this.render.sprites[1].angles.walk = {
			"walk"
		}
		this.vis.flags = U5.flag_clear(this.vis.flags, F_FLYING)
	end

	local function soldier_idle(store, this)
		local idle_animation = "idle_floor"

		if this.current_mode == MODE_FLY then
			idle_animation = "idle_air"
		end

		local idle_pos = this.pos

		if this.soldier.target_id then
			local target = store.entities[this.soldier.target_id]

			if target then
				idle_pos = target.pos

				local an, af = U5.animation_name_facing_point(this, idle_animation, idle_pos)

				U5.animation_start(this, an, af, store.tick_ts, true)
			end
		elseif last_target_pos then
			idle_pos = last_target_pos

			local an, af = U5.animation_name_facing_point(this, idle_animation, idle_pos)

			U5.animation_start(this, an, af, store.tick_ts, true)
		else
			U5.animation_start(this, this.idle_flip.last_animation, nil, store.tick_ts, this.idle_flip.loop, nil, force_ts)
		end

		if store.tick_ts - this.idle_flip.ts > 2 * store.tick_length then
			this.idle_flip.ts_counter = 0
		end

		this.idle_flip.ts = store.tick_ts
		this.idle_flip.ts_counter = this.idle_flip.ts_counter + store.tick_length

		if this.idle_flip.ts_counter > this.idle_flip.cooldown then
			this.idle_flip.ts_counter = 0

			if math.random() < this.idle_flip.chance then
				this.render.sprites[1].flip_x = not this.render.sprites[1].flip_x
			end

			if this.idle_flip.animations then
				this.idle_flip.last_animation = table.random(this.idle_flip.animations)
			end
		end
	end

	local function y_soldier_ranged_attacks(store, this)
		local target, attack, pred_pos = SU5.soldier_pick_ranged_target_and_attack(store, this)

		if not target then
			last_target_pos = nil

			return false, A_NO_TARGET
		end

		if not attack then
			return false, A_IN_COOLDOWN
		end

		local start_ts = store.tick_ts
		local attack_done

		U5.set_destination(this, this.pos)

		if this.current_mode == MODE_FLY and attack ~= this.ranged.attacks[3] then
			pred_pos.y = pred_pos.y - this.flight_height
		end

		if attack == this.ranged.attacks[3] then
			local mark = E:create_entity(attack.mark_mod)

			mark.modifier.target_id = target.id
			mark.modifier.source_id = this.id
			mark.modifier.duration = 9e+99

			queue_insert(store, mark)
		end

		attack_done = SU5.y_soldier_do_ranged_attack(store, this, target, attack, pred_pos)

		if attack_done then
			last_target_pos = pred_pos
			attack.ts = start_ts

			if attack.shared_cooldown then
				for _, aa in pairs(this.ranged.attacks) do
					if aa ~= attack and aa.shared_cooldown then
						aa.ts = attack.ts
					end
				end
			end

			if this.ranged.forced_cooldown then
				this.ranged.forced_ts = start_ts
			end
		end

		if attack_done then
			return false, A_DONE
		else
			return true
		end
	end

	if not this.spawned_from_tower then
		this.current_mode = tower.tower_upgrade_persistent_data.current_mode
		this.change_mode = false
		this.vis.bans = this.vis_bans_after_take_off
		this.shadow_decal = E:create_entity(this.shadow_decal_t)
		this.shadow_decal.pos = this.pos
		this.shadow_decal.soldier_height = this.flight_height
		this.shadow_decal.entity = this

		queue_insert(store, this.shadow_decal)

		if this.current_mode == MODE_FLY then
			U5.animation_start(this, "idle_air", nil, store.tick_ts, true)

			this.idle_flip.last_animation = "idle_air"

			if this.ranged.attacks[2] then
				this.ranged.attacks[2].animation = "phosphoric_coating_air"
			end

			if this.ranged.attacks[3] then
				this.ranged.attacks[3].animation = "sting_missiles_air"
			end

			this.tween.disabled = false
			this.tween.props[1].disabled = false
			this.tween.props[1].ts = store.tick_ts
			this.motion.max_speed = this.speed_flight
			this.melee.attacks[1].disabled = true
			this.vis.flags = bor(this.vis.flags, F_FLYING)
		else
			this.motion.max_speed = this.speed_ground
			this.melee.attacks[1].disabled = false
			this.ranged.attacks[1].animation = "attack_floor"

			if this.ranged.attacks[2] then
				this.ranged.attacks[2].animation = "phosphoric_coating_floor"
			end

			if this.ranged.attacks[3] then
				this.ranged.attacks[3].animation = "sting_missiles_floor"
			end

			this.unit.death_animation = "death_floor"
			this.unit.hide_after_death = false
			this.tween.props[1].disabled = true
			this.tween.disabled = true

			U5.animation_start(this, "idle_floor", nil, store.tick_ts, true)

			this.idle_flip.last_animation = "idle_floor"
			this.render.sprites[1].angles.walk = {
				"walk"
			}
			this.vis.flags = U5.flag_clear(this.vis.flags, F_FLYING)
		end

		adjust_height()
	end

	while true do
		while this.nav_rally.new do
			if y_soldier_new_rally_custom(store, this) then
				goto label_814_1
			end
		end

		if this.change_mode or this.current_mode ~= tower.tower_upgrade_persistent_data.current_mode then
			this.change_mode = false

			U5.unblock_target(store, this)

			if this.current_mode == MODE_GROUND then
				this.current_mode = MODE_FLY

				change_mode_fly()
			else
				this.current_mode = MODE_GROUND

				change_mode_ground()
			end
		end

		adjust_position_reference()

		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil

					SU5.soldier_power_upgrade(this, pn)

					if p == this.powers.phosphoric then
						this.melee.attacks[1].disabled = true
						this.melee.attacks[2].disabled = false
						this.melee.attacks[2].level = p.level
						this.ranged.attacks[1].disabled = true
						this.ranged.attacks[2].disabled = false
						this.ranged.attacks[2].level = p.level
						this.unit.damage_factor = p.damage_factor[p.level]
					end

					if p == this.powers.sting_missiles then
						this.ranged.attacks[3].max_range = p.max_range[p.level]
						this.ranged.attacks[3].min_range = p.min_range[p.level]
						this.ranged.attacks[3].hp_max_target = p.hp_max_target[p.level]
						this.ranged.attacks[3].filter_fn = function(e, o)
							return e.health and e.health.hp_max <= p.hp_max_target[p.level]
						end
					end
				end
			end
		end

		check_tower_damage_factor()

		if this.health.dead then
			tower.tower_upgrade_persistent_data.is_taking_off[this.soldier.tower_soldier_idx] = true

			if this.current_mode == MODE_FLY then
				this.unit.fade_time_after_death = false

				U5.unblock_target(store, this)
				SU5.y_enemy_death(store, this)
			else
				this.tween = nil

				SU5.y_soldier_death(store, this)
			end

			return
		end

		if this.unit.is_stunned then
			this.tween.props[1].disabled = true

			SU5.soldier_idle(store, this)

			goto label_814_1
		else
			this.tween.props[1].disabled = false
		end

		if this.current_mode == MODE_GROUND then
			brk, sta = SU5.y_soldier_melee_block_and_attacks(store, this)

			if sta == A_DONE and this.powers and this.powers.phosphoric.level > 0 then
				local target = store.entities[this.soldier.target_id]

				if target then
					if target.health.armor and target.health.armor > 0 then
						SU5.armor_dec(target, this.powers.phosphoric.armor_reduction[this.powers.phosphoric.level])
					end

					tower_rocket_gunners_phosphoric_area_damage(this, store, target)
				end
			end

			if brk or sta ~= A_NO_TARGET then
				goto label_814_1
			end
		end

		if this.ranged and not this.ranged.range_while_blocking then
			if this.ranged.attacks[2] and this.ranged.attacks[2].bullet_start_offset then
				for _, start_offset in ipairs(this.ranged.attacks[2].bullet_start_offset) do
					start_offset.y = this.render.sprites[1].offset.y + this.ranged.attacks[2].bullet_start_offset_relative.y
					start_offset.x = this.ranged.attacks[2].bullet_start_offset_relative.x
				end
			end

			brk, sta = y_soldier_ranged_attacks(store, this)

			if brk or sta == A_DONE then
				goto label_814_1
			elseif sta == A_IN_COOLDOWN and not this.ranged.go_back_during_cooldown then
				goto label_814_0
			end
		end

		if SU5.soldier_go_back_step(store, this) then
			goto label_814_1
		end

		::label_814_0::

		soldier_idle(store, this)
		SU5.soldier_regen(store, this)

		::label_814_1::

		coroutine.yield()
	end
end

scripts.rock_firey_nut_FL = {}

function scripts.rock_firey_nut_FL.update(this, store, script)
	local b = this.bullet
	local origin = V.vclone(b.to)
	local child_bullet = b.child_bullet
	local child_count = b.child_count or 3
	local child_level = b.level or 0
	local child_damage_factor = b.damage_factor or 1
	local child_source_id = b.source_id
	local child_random_x = b.child_random_x_to_dest or 30
	local child_random_y = b.child_random_y_to_dest or 20

	scripts.bomb_kro.update(this, store, script)

	if not child_bullet or child_level <= 0 then
		return
	end

	child_count = child_count + child_level - 1

	local source = child_source_id and store.entities[child_source_id]
	local child_range = b.child_search_range or source and source.attacks and source.attacks.range or 210
	local child_prediction = b.child_node_prediction or true
	local child_vis_flags = b.child_vis_flags or F_RANGED
	local child_vis_bans = b.child_vis_bans or F_FLYING
	local _, enemies = U.find_foremost_enemy(store.entities, origin, 0, child_range, child_prediction, child_vis_flags, child_vis_bans)
	local target_positions = {}
	local enemies_hitted = {}

	local function nearest_path_pos(pos)
		local nearest_nodes = P:nearest_nodes(pos.x, pos.y)

		if nearest_nodes and nearest_nodes[1] then
			local pi, spi, ni = unpack(nearest_nodes[1])

			if P:is_node_valid(pi, ni) then
				return P:node_pos(pi, spi, ni)
			end
		end

		return V.vclone(pos)
	end

	if enemies and #enemies > 0 then
		for i = 1, child_count do
			local enemy = enemies[km.zmod(i + 1, #enemies)]
			local pred

			if enemy then
				pred = P:predict_enemy_pos(enemy, child_prediction) or V.vclone(enemy.pos)

				if not U.is_inside_ellipse(origin, pred, child_range * 1.05) then
					local ni = enemy.nav_path.ni + P:predict_enemy_node_advance(enemy, child_prediction)

					pred = P:node_pos(enemy.nav_path.pi, enemy.nav_path.spi, ni) or pred
				end

				table.insert(enemies_hitted, enemy.id)

				if table.count(enemies_hitted, function(_, id)
					return id == enemy.id
				end) > 1 then
					pred = V.vclone(pred)
					pred.x = pred.x + U.frandom(0, child_random_x) * U.random_sign()
					pred.y = pred.y + U.frandom(0, child_random_y) * U.random_sign()
					pred = nearest_path_pos(pred)
				end
			end

			if pred then
				table.insert(target_positions, pred)
			end
		end
	end

	while #target_positions < child_count do
		local angle = 2 * math.pi * (#target_positions + 1) / child_count
		local fallback_pos = U.point_on_ellipse(origin, math.min(60, child_range), angle)

		table.insert(target_positions, nearest_path_pos(fallback_pos))
	end

	for _, dest in ipairs(target_positions) do
		local child = E:create_entity(child_bullet)

		child.pos = V.vclone(origin)
		child.bullet.from = V.vclone(origin)
		child.bullet.to = V.vclone(dest)
		child.bullet.level = child_level
		child.bullet.source_id = child_source_id
		child.bullet.damage_factor = child_damage_factor

		queue_insert(store, child)
	end
end

scripts.tower_tricannon99 = {}

function scripts.tower_tricannon99.update(this, store, script)
	local tower_sid = 2
	local a = this.attacks
	local ab = this.attacks.list[1]
	local am = this.attacks.list[2]
	local ao = this.attacks.list[3]
	local pow_m = this.powers and this.powers.bombardment
	local pow_o = this.powers and this.powers.overheat
	local last_ts = store.tick_ts - ab.cooldown

	ab.ts = store.tick_ts - ab.cooldown + a.attack_delay_on_spawn

	local aa, pow
	local attacks = {
		ao,
		am,
		ab
	}
	local pows = {
		pow_o,
		pow_m
	}
	local overheateble_attacks = {
		am,
		ab
	}

	local function shoot_bullet(attack, enemy, dest, bullet_idx)
		local b = E:create_entity(attack.bullet)
		local bullet_start_offset = bullet_idx and attack.bullet_start_offset[bullet_idx] or attack.bullet_start_offset

		b.pos.x, b.pos.y = this.pos.x + bullet_start_offset.x, this.pos.y + bullet_start_offset.y
		b.bullet.damage_factor = this.tower.damage_factor
		b.bullet.from = V.vclone(b.pos)
		b.bullet.to = dest

		if attack.bullet == attack.bullet_overheated then
			pow = pow_o
		end

		b.bullet.level = pow and pow.level or 1
		b.bullet.target_id = enemy and enemy.id
		b.bullet.source_id = this.id

		queue_insert(store, b)

		return b
	end

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			if this.powers then
				for k, pow in pairs(this.powers) do
					if pow.changed then
						pow.changed = nil

						if pow == pow_m then
							am.cooldown = pow_m.cooldown[pow_m.level]

							if pow.level == 1 then
								am.ts = store.tick_ts - am.cooldown
							end
						elseif pow == pow_o then
							ao.cooldown = pow_o.cooldown[pow_o.level]
							ao.duration = pow_o.duration[pow_o.level]

							if pow.level == 1 then
								ao.ts = store.tick_ts - ao.cooldown
							end
						end
					end
				end
			end

			SU5.towers_swaped(store, this, this.attacks.list)

			if ao and ao.active and store.tick_ts - ao.ts > ao.duration and (not am or not am.active) then
				ao.active = nil

				for _, attack in ipairs(overheateble_attacks) do
					attack.bullet = attack._default_bullet
				end

				U.y_animation_play_group(this, ao.animation_end, nil, store.tick_ts, false, "layers")

				if am and am.cooldown and store.tick_ts - am.ts > am.cooldown then
					am.ts = store.tick_ts - (am.cooldown - a.min_cooldown)
				end
			end

			for i, aa in pairs(attacks) do
				pow = pows[i]

				if aa and (not pow or pow.level > 0) and aa.cooldown and store.tick_ts - aa.ts > aa.cooldown and (not a.min_cooldown or store.tick_ts - last_ts > a.min_cooldown) then
					local trigger, enemies, trigger_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, aa.range, aa.node_prediction, aa.vis_flags, aa.vis_bans)

					if not trigger then
						SU5.delay_attack(store, aa, fts(10))
					else
						local trigger_path = trigger.nav_path.pi

						if aa == ab then
							aa.ts = store.tick_ts
							last_ts = aa.ts

							local trigger_target_positions = {}

							for j = 1, aa.bomb_amount do
								local enemy_index = km.zmod(j + 1, #enemies)
								local enemy = enemies[enemy_index]
								local ni = enemy.nav_path.ni + P:predict_enemy_node_advance(enemy, aa.node_prediction)
								local dest = P:node_pos(enemy.nav_path.pi, enemy.nav_path.spi, ni)

								table.insert(trigger_target_positions, dest)
							end

							local shoot_animation = aa.animation

							if ao and ao.active then
								shoot_animation = ao.animation_shoot
							end

							U.animation_start_group(this, shoot_animation, nil, store.tick_ts, false, "layers")
							U.y_wait(store, aa.shoot_time)
							S:queue(aa.sound)

							local _, enemies, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, aa.range, aa.node_prediction, aa.vis_flags, aa.vis_bans)
							local target_positions = {}

							if enemies and #enemies > 0 then
								for j = 1, aa.bomb_amount do
									local enemy_index = km.zmod(j + 1, #enemies)
									local enemy = enemies[enemy_index]
									local ni = enemy.nav_path.ni + P:predict_enemy_node_advance(enemy, aa.node_prediction)
									local dest = P:node_pos(enemy.nav_path.pi, enemy.nav_path.spi, ni)

									table.insert(target_positions, {
										enemy = enemy,
										dest = dest
									})
								end
							else
								for j = 1, aa.bomb_amount do
									local trigger_target_positions_index = km.zmod(j + 1, #trigger_target_positions)
									local trigger_target_position = trigger_target_positions[trigger_target_positions_index]

									table.insert(target_positions, {
										dest = trigger_target_position
									})
								end
							end

							local enemies_hitted = {}

							for bullet_idx, target_position_data in ipairs(target_positions) do
								local enemy = target_position_data.enemy
								local pred = target_position_data.dest

								if enemy then
									local dest = P:predict_enemy_pos(enemy, aa.node_prediction)

									if U.is_inside_ellipse(tpos(this), dest, a.range * 1.05) then
										pred = dest

										table.insert(enemies_hitted, enemy.id)
									end
								end

								local enemy_hit_count = table.count(enemies_hitted, function(k, v)
									if v == enemy.id then
										return true
									end

									return false
								end)

								if not enemy or enemy and enemy_hit_count > 1 then
									pred.x = pred.x + U.frandom(0, ab.random_x_to_dest) * U.random_sign()
									pred.y = pred.y + U.frandom(0, ab.random_y_to_dest) * U.random_sign()

									local nearest_nodes = P:nearest_nodes(pred.x, pred.y)
									local pi, spi, ni = unpack(nearest_nodes[1])

									pred = P:node_pos(pi, spi, ni)
								end

								shoot_bullet(aa, nil, pred, bullet_idx)
								U.y_wait(store, aa.time_between_bombs)
							end

							U.y_animation_wait_group(this, "layers")

							aa.ts = last_ts
						elseif aa == am and this.tower.can_do_magic then
							aa.ts = store.tick_ts
							last_ts = aa.ts
							aa.active = true

							U.animation_start_group(this, aa.animation_start, nil, store.tick_ts, false, "layers")
							U.y_wait(store, aa.shoot_time)

							local enemy, __, pred_pos = U.find_foremost_enemy(store.entities, tpos(this), 0, aa.range, aa.node_prediction, aa.vis_flags, aa.vis_bans)
							local dest = enemy and pred_pos or trigger_pos
							local dest_path = enemy and enemy.nav_path.pi or trigger_path
							local nearest_nodes = P:nearest_nodes(dest.x, dest.y, {
								dest_path
							})
							local pi, spi, ni = unpack(nearest_nodes[1])
							local spread = aa.spread[pow.level]
							local node_skip = aa.node_skip[pow.level]
							local nindices = {}

							for ni_candidate = ni - spread, ni + spread, node_skip do
								if P:is_node_valid(pi, ni_candidate) then
									table.insert(nindices, ni_candidate)
								end
							end

							table.append(nindices, table.map(nindices, function(index, value)
								return value + 1
							end))
							S:queue(aa.sounds[pow.level])
							U.animation_start_group(this, aa.animation_loop, nil, store.tick_ts, true, "layers")

							for _, ni_candidate in ipairs(table.random_order(nindices)) do
								local spi = math.random(1, 3)
								local destination = P:node_pos(pi, spi, ni_candidate)
								local b = shoot_bullet(aa, nil, destination, 1)
								local min_time = aa.time_between_bombs_min
								local max_time = aa.time_between_bombs_max

								U.y_wait(store, fts(math.random(min_time, max_time)))
							end

							U.y_animation_wait_group(this, "layers")
							U.animation_start_group(this, aa.animation_end, nil, store.tick_ts, false, "layers")
							U.y_animation_wait_group(this, "layers")
							aa.active = nil

							if ao and ao.cooldown and store.tick_ts - ao.ts > ao.cooldown then
								ao.ts = store.tick_ts - (ao.cooldown - a.min_cooldown)
							end
						elseif aa == ao and this.tower.can_do_magic then
							aa.ts = store.tick_ts
							aa.active = true

							for _, attack in ipairs(overheateble_attacks) do
								attack._default_bullet = attack.bullet
								attack.bullet = attack.bullet_overheated
							end

							S:queue(aa.sound)
							U.y_animation_play_group(this, aa.animation_charge, nil, store.tick_ts, false, "layers")
						end
					end
				end
			end

			local idle_animation = "idle"

			if ao and ao.active then
				idle_animation = ao.animation_idle
			end

			U.y_animation_play_group(this, idle_animation, nil, store.tick_ts, false, "layers")
			coroutine.yield()
		end
	end
end

scripts.tower_dark_elf99 = {}
function scripts.tower_dark_elf99.update(this, store)
	local last_ts = store.tick_ts
	local a_name, a_flip, angle_idx, target, pred_pos
	local attack = this.attacks.list[1]
	local attack_soldiers = this.attacks.list[2]
	local b = this.barrack
	local pow_soldiers = this.powers and this.powers.skill_soldiers or nil
	local pow_buff = this.powers and this.powers.skill_buff or nil
	local MODE_FOREMOST = 0
	local MODE_MAXHP = 1

	local function find_maxhp_enemy(entities, origin, min_range, max_range, prediction_time, flags, bans, filter_func, min_override_flags)
		flags = flags or 0
		bans = bans or 0
		min_override_flags = min_override_flags or 0

		local enemies = {}

		for _, e in pairs(entities) do
			if e.pending_removal or not e.enemy or not e.nav_path or not e.vis or e.health and e.health.dead or band(e.vis.flags, bans) ~= 0 or band(e.vis.bans, flags) ~= 0 or filter_func and not filter_func(e, origin) then
				-- block empty
			else
				local e_pos, e_ni

				if prediction_time and e.motion and e.motion.speed then
					if e.motion.forced_waypoint then
						local dt = prediction_time == true and 1 or prediction_time

						e_pos = V.v(e.pos.x + dt * e.motion.speed.x, e.pos.y + dt * e.motion.speed.y)
						e_ni = e.nav_path.ni
					else
						local node_offset = P:predict_enemy_node_advance(e, prediction_time)

						e_ni = e.nav_path.ni + node_offset
						e_pos = P:node_pos(e.nav_path.pi, e.nav_path.spi, e_ni)
					end
				else
					e_pos = e.pos
					e_ni = e.nav_path.ni
				end

				if U.is_inside_ellipse(e_pos, origin, max_range) and P:is_node_valid(e.nav_path.pi, e_ni) and (min_range == 0 or band(e.vis.flags, min_override_flags) ~= 0 or not U.is_inside_ellipse(e_pos, origin, min_range)) then
					e.__ffe_pos = V.vclone(e_pos)

					table.insert(enemies, e)
				end
			end
		end

		if not enemies or #enemies == 0 then
			return nil, nil
		else
			table.sort(enemies, function(e1, e2)
				return e1.health.hp_max > e2.health.hp_max
			end)

			return enemies[1], enemies, enemies[1].__ffe_pos
		end
	end

	local function find_target(attack, node_prediction)
		if this.tower_upgrade_persistent_data.current_mode == MODE_FOREMOST then
			local target, _, pred_pos = U5.find_foremost_enemy(store.entities, tpos(this), 0, this.attacks.range, node_prediction, attack.vis_flags, attack.vis_bans)

			return target, pred_pos
		else
			local target, _, pred_pos = find_maxhp_enemy(store.entities, tpos(this), 0, this.attacks.range, node_prediction, attack.vis_flags, attack.vis_bans)

			return target, pred_pos
		end
	end

	local function animation_name_facing_angle_dark_elf(group, source_pos, dest_pos)
		local vx, vy = V.sub(dest_pos.x, dest_pos.y, source_pos.x, source_pos.y)
		local v_angle = V.angleTo(vx, vy)
		local angle = km.unroll(v_angle)
		local angle_deg = km.rad2deg(angle)
		local a = this.render.sprites[this.render.sid_archer]
		local o_name, o_flip, o_idx
		local a1, a2, a3, a4, a5, a6, a7, a8 = 0, 20, 90, 160, 180, 200, 270, 340
		local angles = a.angles[group]

		if a1 <= angle_deg and angle_deg < a2 then
			o_name, o_flip, o_idx = angles[1], false, 1
			quadrant = 1
		elseif a2 <= angle_deg and angle_deg < a3 then
			o_name, o_flip, o_idx = angles[2], false, 2
			quadrant = 2
		elseif a3 <= angle_deg and angle_deg < a4 then
			o_name, o_flip, o_idx = angles[2], true, 2
			quadrant = 3
		elseif a4 <= angle_deg and angle_deg < a5 then
			o_name, o_flip, o_idx = angles[1], true, 1
			quadrant = 4
		elseif a5 <= angle_deg and angle_deg < a6 then
			o_name, o_flip, o_idx = angles[4], true, 4
			quadrant = 5
		elseif a6 <= angle_deg and angle_deg < a7 then
			o_name, o_flip, o_idx = angles[3], true, 3
			quadrant = 6
		elseif a7 <= angle_deg and angle_deg < a8 then
			o_name, o_flip, o_idx = angles[3], false, 3
			quadrant = 7
		else
			o_name, o_flip, o_idx = angles[4], false, 4
			quadrant = 8
		end

		return o_name, o_flip, o_idx
	end

	local function check_change_mode()
		if this.change_mode then
			this.change_mode = false

			if this.tower_upgrade_persistent_data.current_mode == MODE_FOREMOST then
				this.tower_upgrade_persistent_data.current_mode = MODE_MAXHP
			else
				this.tower_upgrade_persistent_data.current_mode = MODE_FOREMOST
			end

			return true
		end

		return false
	end

	local function check_upgrades_purchase()
		if this.powers then
			for k, pow in pairs(this.powers) do
				if pow.changed then
					pow.changed = nil

					if pow == pow_soldiers then
						if not this.controller_soldiers then
							this.controller_soldiers = E:create_entity(this.controller_soldiers_template)
							this.controller_soldiers.tower_ref = this
							this.controller_soldiers.pos = this.pos

							queue_insert(store, this.controller_soldiers)
						end

						this.controller_soldiers.pow_level = pow.level
					end
				end
			end
		end
	end

	local function retarget(node_prediction)
		local retarget, new_pos = find_target(attack)

		if retarget then
			this.attacks._last_target_pos = pred_pos

			if this.mod_target then
				this.mod_target.modifier.target_id = retarget.id
			end

			return retarget, new_pos
		else
			target = nil

			if this.mod_target then
				queue_remove(store, this.mod_target)
			end

			return nil, nil
		end
	end

	if not this.attacks._last_target_pos then
		this.attacks._last_target_pos = {}
		this.attacks._last_target_pos = v(REF_W, 0)
	end

	local an, af = U5.animation_name_facing_point(this, "idle", this.attacks._last_target_pos, this.render.sid_archer)

	U5.animation_start(this, an, af, store.tick_ts, 1, this.render.sid_archer)

	if this.tower_upgrade_persistent_data.last_ts then
		last_ts = this.tower_upgrade_persistent_data.last_ts
		attack.ts = this.tower_upgrade_persistent_data.last_ts
	else
		attack.ts = store.tick_ts - attack.cooldown + attack.first_cooldown
	end

	::label_1159_0::

	while true do
		if this.tower.blocked then
			coroutine.yield()
		else
			check_upgrades_purchase()
			check_change_mode()
			SU5.towers_swaped(store, this, this.attacks.list)

			if store.tick_ts - attack.ts > attack.cooldown then
				target, pred_pos = find_target(attack, attack.node_prediction_prepare_from_begin + attack.node_prediction)

				if not target then
					SU5.delay_attack(store, attack, fts(10))

					goto label_1159_0
				end

				this.mod_target = E:create_entity(attack.mod_target)
				this.mod_target.modifier.target_id = target.id
				this.mod_target.modifier.source_id = this.id
				this.mod_target.render.sprites[1].hidden = this.tower_upgrade_persistent_data.current_mode == MODE_FOREMOST

				queue_insert(store, this.mod_target)

				local a_name, a_flip, angle_idx
				local start_ts = store.tick_ts

				this.attacks._last_target_pos = pred_pos

				local an, af = U5.animation_name_facing_point(this, "shot_prepare", this.attacks._last_target_pos, this.render.sid_archer)

				U5.animation_start(this, an .. "_begin", af, store.tick_ts, false, this.render.sid_archer)

				while not U5.animation_finished(this, this.render.sid_archer, 1) do
					check_upgrades_purchase()
					check_change_mode()

					if this.tower.blocked then
						local an, af = U5.animation_name_facing_point(this, "idle", this.attacks._last_target_pos, this.render.sid_archer)

						U5.animation_start(this, an, af, store.tick_ts, false, this.render.sid_archer)

						if this.mod_target then
							queue_remove(store, this.mod_target)
						end

						goto label_1159_0
					end

					coroutine.yield()
				end

				U5.animation_start(this, an .. "_loop", af, store.tick_ts, true, this.render.sid_archer)

				local old_target = target

				target, pred_pos = retarget(attack.node_prediction_prepare_from_loop + attack.node_prediction)

				while not target or not pred_pos do
					check_upgrades_purchase()
					check_change_mode()

					if this.tower.blocked then
						local an, af = U5.animation_name_facing_point(this, "idle", this.attacks._last_target_pos, this.render.sid_archer)

						U5.animation_start(this, an, af, store.tick_ts, false, this.render.sid_archer)

						if this.mod_target then
							queue_remove(store, this.mod_target)
						end

						goto label_1159_0
					end

					coroutine.yield()

					target, pred_pos = retarget(attack.node_prediction_prepare_from_loop + attack.node_prediction)
				end

				this.attacks._last_target_pos = pred_pos

				local anim_runs_until_now = this.render.sprites[this.render.sid_archer].runs

				while not U5.animation_finished(this, this.render.sid_archer, anim_runs_until_now + 1) do
					check_upgrades_purchase()
					check_change_mode()

					if this.tower.blocked then
						local an, af = U5.animation_name_facing_point(this, "idle", this.attacks._last_target_pos, this.render.sid_archer)

						U5.animation_start(this, an, af, store.tick_ts, false, this.render.sid_archer)

						if this.mod_target then
							queue_remove(store, this.mod_target)
						end

						goto label_1159_0
					end

					coroutine.yield()
				end

				old_target = target
				this.attacks._last_target_pos = pred_pos
				target, pred_pos = retarget(attack.node_prediction_prepare_from_loop + attack.node_prediction)

				if pred_pos then
					this.attacks._last_target_pos = pred_pos
				end

				an, af = U5.animation_name_facing_point(this, "shot_prepare", this.attacks._last_target_pos, this.render.sid_archer)

				U5.animation_start(this, an .. "_end", af, store.tick_ts, false, this.render.sid_archer)

				while not U5.animation_finished(this, this.render.sid_archer, 1) do
					check_upgrades_purchase()
					check_change_mode()

					if this.tower.blocked then
						local an, af = U5.animation_name_facing_point(this, "idle", this.attacks._last_target_pos, this.render.sid_archer)

						U5.animation_start(this, an, af, store.tick_ts, false, this.render.sid_archer)

						if this.mod_target then
							queue_remove(store, this.mod_target)
						end

						goto label_1159_0
					end

					coroutine.yield()
				end

				old_target = target
				target, pred_pos = retarget(attack.node_prediction)

				if not pred_pos then
					pred_pos = this.attacks._last_target_pos

					if old_target and not old_target.health.dead then
						local node_offset = P:predict_enemy_node_advance(old_target, attack.shoot_time)
						local e_ni = old_target.nav_path.ni + node_offset
						local e_pos = P:node_pos(old_target.nav_path.pi, old_target.nav_path.spi, e_ni)

						if V.dist(e_pos.x, e_pos.y, this.pos.x, this.pos.y) < this.attacks.range * this.attacks.range * 1.3 then
							target = old_target
						end
					end
				end

				an, af, angle_idx = animation_name_facing_angle_dark_elf("shot", this.pos, pred_pos)

				U5.animation_start(this, an, af, store.tick_ts, false, this.render.sid_archer)
				U5.y_wait(store, attack.shoot_time)

				local bullet = E:create_entity(attack.bullet)

				bullet.pos = V.vclone(this.pos)

				local offset_x = af and -attack.bullet_start_offset[angle_idx].x or attack.bullet_start_offset[angle_idx].x
				local offset_y = attack.bullet_start_offset[angle_idx].y

				bullet.pos = V.v(this.pos.x + offset_x, this.pos.y + offset_y)
				bullet.bullet.from = V.vclone(bullet.pos)
				bullet.bullet.to = V.vclone(pred_pos)

				if target then
					bullet.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
				end

				bullet.bullet.target_id = target and target.id or nil
				bullet.bullet.source_id = this.id
				bullet.bullet.damage_factor = this.tower.damage_factor

				if pow_buff and pow_buff.level > 0 then
					local soulsDamageMin = this.tower_upgrade_persistent_data.souls_extra_damage_min or 0
					local soulsDamageMax = this.tower_upgrade_persistent_data.souls_extra_damage_max or 0

					bullet.bullet.damage_min = bullet.bullet.damage_min + soulsDamageMin
					bullet.bullet.damage_max = bullet.bullet.damage_max + soulsDamageMax
					if target and target.health.hp_max and target.health.hp and target.health.hp / target.health.hp_max < 0.5 then
						bullet.bullet.damage_factor = bullet.bullet.damage_factor * bullet.bullet.extra_damage_factor
						bullet.bullet.reduce_armor = bullet.bullet.extra_reduce_armor
					end

				end

				queue_insert(store, bullet)

				while not U5.animation_finished(this, this.render.sid_archer, 1) do
					check_upgrades_purchase()
					check_change_mode()
					coroutine.yield()
				end

				local an, af = U5.animation_name_facing_point(this, "shot_end", pred_pos, this.render.sid_archer)

				U5.y_animation_play(this, an, af, store.tick_ts, false, this.render.sid_archer)

				attack.ts = start_ts
				last_ts = start_ts
				this.tower.long_idle_pos = V.vclone(pred_pos)
			end

			this.tower_upgrade_persistent_data.last_ts = last_ts

			if store.tick_ts - last_ts > this.tower.long_idle_cooldown then
				U5.animation_start(this, "idle", false, store.tick_ts, -1, this.render.sid_archer)

				this.attacks._last_target_pos = v(REF_W, 0)
			end

			coroutine.yield()
		end
	end
end

scripts.mod_crossbow_eagle_vulnerability_FL = {}

function scripts.mod_crossbow_eagle_vulnerability_FL.insert(this, store, script)
	local factors = this.received_damage_factors or {
		this.received_damage_factor or 1
	}
	local level = km.clamp(1, #factors, this.modifier.level or 1)

	this.received_damage_factor = factors[level]

	return scripts.mod_damage_factors.insert(this, store, script)
end

function scripts.mod_crossbow_eagle_vulnerability_FL.remove(this, store, script)
	return scripts.mod_damage_factors.remove(this, store, script)
end

scripts.aura_crossbow_eagle_vulnerability_FL = {}

function scripts.aura_crossbow_eagle_vulnerability_FL.update(this, store, script)
	this.aura.ts = store.tick_ts

	local last_hit_ts = store.tick_ts - (this.aura.cycle_time or 0.3)

	while true do
		local source = this.aura.source_id and store.entities[this.aura.source_id]

		if this.aura.track_source then
			if not source or source.health and source.health.dead or source.tower and source.tower.blocked then
				break
			end

			if source.pos then
				this.pos = V.vclone(source.pos)
			end

			if source.powers and source.powers.eagle then
				local level = source.powers.eagle.level or 0

				if level <= 0 then
					break
				end

				this.aura.level = level

				if source.attacks and source.attacks.list and source.attacks.list[3] then
					local eagle_attack = source.attacks.list[3]

					this.aura.radius = eagle_attack.range + eagle_attack.range_inc * level
				end
			end
		end

		if store.tick_ts - last_hit_ts >= (this.aura.cycle_time or 0.3) then
			last_hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.aura.radius, this.aura.vis_flags or F_MOD, this.aura.vis_bans or 0, function(e)
				return band(e.vis.flags or 0, F_FLYING) ~= 0
			end)

			if targets then
				for _, target in pairs(targets) do
					local mod = E:create_entity(this.aura.mod)

					mod.modifier.level = this.aura.level
					mod.modifier.target_id = target.id
					mod.modifier.source_id = this.aura.source_id or this.id

					queue_insert(store, mod)
				end
			end
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.mod_polymorph_sorcerer_enhanced = {}

local function sorcerer_polymorph_power_level(store, source_id, modifier_level)
	if modifier_level and modifier_level > 0 then
		return km.clamp(1, 3, modifier_level)
	end

	local source = source_id and store.entities[source_id]

	if source and source.bullet and source.bullet.source_id then
		source = store.entities[source.bullet.source_id] or source
	elseif source and source.combat_stats_source_id then
		source = store.entities[source.combat_stats_source_id] or source
	end

	if source and source.powers and source.powers.polymorph and source.powers.polymorph.level then
		return km.clamp(1, 3, source.powers.polymorph.level)
	end

	return 1
end

function scripts.mod_polymorph_sorcerer_enhanced.insert(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.vis or band(target.vis.bans or 0, F_POLYMORPH) ~= 0 then
		return false
	end

	local pm = this.polymorph
	local target_gold = 0

	if pm.transfer_gold_factor then
		if target.enemy then
			target_gold = target.enemy.gold
			target.enemy.gold = 0
		elseif target._original_enemy then
			target_gold = target._original_enemy.gold
			target._original_enemy.gold = 0
		end
	end

	local d = E:create_damage()

	d.damage_type = bor(DAMAGE_EAT, DAMAGE_NO_LIFESTEAL)
	d.source_id = this.id
	d.combat_stats_source_id = m.source_id
	d.target_id = target.id
	d.pop = pm.pop

	queue_damage(store, d)

	if not target or not target.vis or band(target.vis.bans or 0, F_POLYMORPH) ~= 0 then
		return false
	end

	target.vis.bans = F_ALL

	if pm.hit_fx_sizes then
		local fx_name = target.unit and pm.hit_fx_sizes[target.unit.size]

		if fx_name then
			local fx = E:create_entity(fx_name)

			fx.pos = V.vclone(target.pos)

			if m.use_mod_offset then
				fx.pos.x, fx.pos.y = fx.pos.x + target.unit.mod_offset.x, fx.pos.y + target.unit.mod_offset.y
			end

			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].draw_order = 2

			queue_insert(store, fx)
		end
	end

	local e_name = pm.custom_entity_names[target.template_name] or pm.custom_entity_names.default
	local e = E:create_entity(e_name)

	e.pos = V.vclone(target.pos)
	e.nav_path = table.deepclone(target.nav_path)

	if pm.transfer_lives_cost_factor and target and target.enemy and e and e.enemy then
		e.enemy.lives_cost = math.floor(target.enemy.lives_cost * pm.transfer_lives_cost_factor)
	end

	if pm.transfer_gold_factor and target and e and e.enemy then
		e.enemy.gold = math.floor(target_gold * pm.transfer_gold_factor)
	end

	if pm.transfer_health_factor and target and target.health and e and e.health then
		e.health.hp_max = math.floor(target.health.hp_max * pm.transfer_health_factor)
		e.health.hp = math.floor(target.health.hp * pm.transfer_health_factor)
	end

	if pm.transfer_speed_factor and target and target.motion and e and e.motion then
		e.motion.max_speed = target.motion.max_speed * pm.transfer_speed_factor

		local has, mods = U.has_modifier_types(store, target, MOD_TYPE_FAST, MOD_TYPE_SLOW)

		if has then
			for _, mod in pairs(mods) do
				if mod.fast then
					e.motion.max_speed = e.motion.max_speed / (mod.fast.factor or 1)
				elseif mod.slow then
					e.motion.max_speed = e.motion.max_speed / (mod.slow.factor or 1)
				end
			end
		end
	end

	if pm.fixed_speed and e.motion then
		e.motion.max_speed = pm.fixed_speed
	end

	if pm.splash_counts then
		local level = sorcerer_polymorph_power_level(store, m.source_id or this.combat_stats_source_id, m.level)

		e.sorcerer_polymorph_splash = {
			count = pm.splash_counts[level] or pm.splash_counts[#pm.splash_counts] or 0,
			mod = pm.splash_mod or "mod_polymorph_sorcerer_chain",
			radius = pm.splash_radius or 80,
			source_id = m.source_id
		}
	end

	queue_insert(store, e)
	signal.emit("mod-applied", this, target)
	queue_remove(store, this)

	return true
end

local function sorcerer_sheep_valid_splash_target(this, target)
	return target and target.id ~= this.id and target.health and not target.health.dead and target.vis and
		band(target.vis.bans or 0, F_POLYMORPH) == 0 and
		band(target.vis.flags or 0, bor(F_BOSS, F_MINIBOSS)) == 0
end

local function sorcerer_sheep_splash_polymorph(store, this)
	local cfg = this.sorcerer_polymorph_splash

	if not cfg or cfg.used or (cfg.count or 0) <= 0 then
		return
	end

	cfg.used = true

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, cfg.radius or 80, 0, 0, function(e)
		return sorcerer_sheep_valid_splash_target(this, e)
	end)

	if not targets then
		return
	end

	local count = 0

	for _, target in ipairs(targets) do
		if count >= cfg.count then
			break
		end

		if store.entities[target.id] and sorcerer_sheep_valid_splash_target(this, target) then
			local m = E:create_entity(cfg.mod or "mod_polymorph_sorcerer_chain")

			m.modifier.source_id = cfg.source_id or this.id
			m.modifier.target_id = target.id

			queue_insert(store, m)

			count = count + 1
		end
	end
end

scripts.enemy_sheep_sorcerer_enhanced = {}

function scripts.enemy_sheep_sorcerer_enhanced.update(this, store)
	local clicks = 0

	while true do
		if this.health.dead then
			sorcerer_sheep_splash_polymorph(store, this)
			SU.y_enemy_death(store, this)

			return
		end

		if this.ui.clicked then
			this.ui.clicked = nil
			clicks = clicks + 1
		end

		if clicks >= this.clicks_to_destroy then
			this.health.hp = 0

			coroutine.yield()
			AC:inc_check("SHEEP_KILLER")
		elseif this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, -1)
			coroutine.yield()
		else
			SU.y_enemy_walk_until_blocked(store, this, true, function(store, this)
				return this.ui.clicked
			end)
		end
	end
end

local function resume_base(co, this, store, script)
	local ok, err = coroutine.resume(co, this, store, script)
	if not ok then
		error(err)
	end
	return coroutine.status(co) == "dead"
end

local function archers_target_disabled(store, target)
	return target.enemy and target.enemy.blockers and #target.enemy.blockers > 0 or U6.has_modifier_types(store, target, MOD_TYPE_STUN)
end

scripts.arrow_archers_FL = {}

function scripts.arrow_archers_FL.update(this, store, script)
	local tower = store.entities[this.bullet.source_id]
	local level = tower and tower.powers and tower.powers.skill_a.level or 0
	if level > 0 then
		this.bullet.disabled_dmg_factor = (this.bullet.disabled_dmg_factor or 1) * (1 + 0.11 * level)
	end
	return scripts6.arrow_KR6.update(this, store, script)
end

scripts.arrow_ranger_poison_FL = {}

function scripts.arrow_ranger_poison_FL.update(this, store, script)
	local b = this.bullet
	local tower = store.entities[b.source_id]
	local bounce_level = tower and tower.powers and tower.powers.skill_c.level or 0
	local co = coroutine.create(scripts6.arrow_KR6.update)
	local bounced = false
	while true do
		local first = #store.damage_queue + 1
		local done = resume_base(co, this, store, script)
		if bounce_level > 0 and not bounced then
			for i = first, #store.damage_queue do
				local damage = store.damage_queue[i]
				if damage.source_id == this.id and damage.target_id == b.target_id then
					local bounce = E:create_entity("bullet_ranger_poison_bounce_FL_lvl" .. bounce_level)
					bounce.pos = V.vclone(b.to)
					bounce.target_id, bounce.source_id = b.target_id, this.id
					-- Poison rank and ricochet rank are independent. Keep the complete
					-- original poison while native ricochet rules scale direct damage.
					for _, key in ipairs({"damage_min", "damage_max", "damage_type", "damage_factor", "reduce_armor", "reduce_magic_armor", "level", "mod", "source_id"}) do
						bounce.bullet[key] = b[key]
					end
					queue_insert(store, bounce)
					bounced = true
					break
				end
			end
		end
		if done then return end
		coroutine.yield()
	end
end

scripts.bullet_ranger_poison_bounce_FL = {}

function scripts.bullet_ranger_poison_bounce_FL.update(this, store)
	local b = this.bullet
	local already_hit = {[this.target_id] = true}
	if b.particles_name then
		local ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id
		queue_insert(store, ps)
	end
	this.bounces = 0
	while this.bounces < this.max_bounces do
		while V.dist2(this.pos.x, this.pos.y, b.to.x, b.to.y) > (b.fixed_speed * store.tick_length)^2 do
			local target = store.entities[b.target_id]
			if target and target.health and not target.health.dead then
				b.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
			end
			b.speed.x, b.speed.y = V.mul(b.fixed_speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
			this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
			this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)
			coroutine.yield()
		end
		this.pos = V.vclone(b.to)
		local target = store.entities[b.target_id]
		already_hit[b.target_id] = true
		if target and target.health and not target.health.dead and not target.pending_removal then
			local damage = SU6.create_bullet_damage(b, target.id, this.id)
			queue_damage(store, damage)
			local mod = E:create_entity(b.mod)
			mod.modifier.source_id, mod.modifier.target_id = this.id, target.id
			mod.modifier.level, mod.modifier.source_damage = b.level, damage
			queue_insert(store, mod)
		end
		if b.hit_fx then
			local fx = E:create_entity(b.hit_fx)
			fx.pos, fx.render.sprites[1].ts = V.vclone(b.to), store.tick_ts
			queue_insert(store, fx)
		end
		if this.sound_events.hit then S:queue(this.sound_events.hit) end
		this.bounces = this.bounces + 1
		if this.bounces >= this.max_bounces then break end
		local targets = U6.find_enemies_in_range(store.entities, this.pos, 0, this.bounce_range, b.vis_flags, b.vis_bans, function(enemy)
			return not already_hit[enemy.id]
		end)
		if not targets or #targets == 0 then break end
		table.sort(targets, function(a, c)
			return V.dist2(this.pos.x, this.pos.y, a.pos.x, a.pos.y) < V.dist2(this.pos.x, this.pos.y, c.pos.x, c.pos.y)
		end)
		local next_target = targets[1]
		b.target_id = next_target.id
		b.to = V.v(next_target.pos.x + next_target.unit.hit_offset.x, next_target.pos.y + next_target.unit.hit_offset.y)
		b.damage_min = math.max(1, math.floor(b.damage_min * this.bounce_damage_mult))
		b.damage_max = math.max(1, math.floor(b.damage_max * this.bounce_damage_mult))
	end
	queue_remove(store, this)
end

scripts.ray_archers_skill_a_FL = {}

function scripts.ray_archers_skill_a_FL.update(this, store, script)
	local co = coroutine.create(scripts6.ray5_simple.update)
	while true do
		local first = #store.damage_queue + 1
		local done = resume_base(co, this, store, script)
		local target = store.entities[this.bullet.target_id]
		if target and archers_target_disabled(store, target) then
			local tower = store.entities[this.bullet.source_id]
			local level = tower and tower.powers and tower.powers.skill_a.level or 0
			for i = first, #store.damage_queue do
				local damage = store.damage_queue[i]
				if damage.target_id == target.id then
					damage.value = math.ceil(damage.value * (1 + 0.11 * level))
				end
			end
		end
		if done then
			return
		end
		coroutine.yield()
	end
end

scripts.ray_crossbows_skill_c_FL = {}

function scripts.ray_crossbows_skill_c_FL.update(this, store, script)
	local co = coroutine.create(scripts6.ray5_simple.update)
	local fear_applied = false
	while true do
		local first = #store.damage_queue + 1
		local done = resume_base(co, this, store, script)
		if not fear_applied and this.bullet.damage_type ~= DAMAGE_INSTAKILL then
			for i = first, #store.damage_queue do
				local damage = store.damage_queue[i]
				if damage.target_id == this.bullet.target_id then
					local target = store.entities[damage.target_id]
					if target and target.pos then
						local fear = E:create_entity(this.fl_fear_aura)
						fear.pos = V.vclone(target.pos)
						fear.aura.source_id = this.bullet.source_id
						queue_insert(store, fear)
					end
					fear_applied = true
					break
				end
			end
		end
		if done then
			return
		end
		coroutine.yield()
	end
end

scripts.tower_sniper_FL = {}

function scripts.tower_sniper_FL.update(this, store, script)
	local co = coroutine.create(scripts6.tower_sniper.update)
	local sentinel = {}
	while true do
		local kills = this.track_kills and this.track_kills.killed
		if kills and #kills == 0 and this.powers.skill_a.level > 0 then
			kills[1] = sentinel
		end
		local ok, err = coroutine.resume(co, this, store, script)
		if kills and kills[1] == sentinel then
			table.remove(kills, 1)
		end
		if not ok then
			error(err)
		end
		if coroutine.status(co) == "dead" then
			return
		end
		coroutine.yield()
	end
end

scripts.aura_knights_skill_c_FL = {}

function scripts.aura_knights_skill_c_FL.update(this, store)
	local last_cycle_ts = 0
	local seen = {}
	while true do
		local knight = store.entities[this.aura.source_id]
		if not knight or knight.health.dead then
			break
		end
		if store.tick_ts - last_cycle_ts >= this.aura.cycle_time then
			last_cycle_ts = store.tick_ts
			for _, other in pairs(store.entities) do
				if other.id ~= knight.id and other.template_name == knight.template_name and other.health and (other.health.dead or other.health.hp <= 0) and not other.health.death_finished_ts and not seen[other.id] and U6.is_inside_ellipse(other.pos, knight.pos, this.aura.radius) then
					seen[other.id] = true
					local level = knight.powers.skill_c.level
					knight.health.hp = math.min(knight.health.hp_max, knight.health.hp + knight.health.hp_max * this.fl_heal_factors[level])
					knight.melee.attacks[2].disabled = false
					knight.melee.attacks[1].disabled = true
					U6.y_wait(store, this.attack_duration)
					knight.melee.attacks[2].disabled = true
					knight.melee.attacks[1].disabled = false
					break
				end
			end
		end
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.decal_miners_cart_skill_a_FL = {}

function scripts.decal_miners_cart_skill_a_FL.update(this, store, script)
	local co = coroutine.create(scripts6.decal_miners_cart_skill_a.update)
	while true do
		local first = #store.damage_queue + 1
		local done = resume_base(co, this, store, script)
		local level = this.controller and this.controller.cart_level or 0
		local factor = ({0.10, 0.20, 0.30})[level] or 0
		for i = first, #store.damage_queue do
			local damage = store.damage_queue[i]
			if damage.source_id == this.id then
				local target = store.entities[damage.target_id]
				local gold = target and target.enemy and math.ceil((target.enemy.gold or 0) * factor) or 0
				if gold > 0 then
					signal.emit("got-gold", target.pos, gold, "tower_miners")
				end
			end
		end
		if done then
			return
		end
		coroutine.yield()
	end
end

scripts.aura_miners_skill_b_FL = {}

function scripts.aura_miners_skill_b_FL.update(this, store)
	local aura = this.aura
	for _, target in pairs(store.entities) do
		if target.unit and target.vis and target.health and not target.health.dead and band(target.vis.flags, aura.vis_bans) == 0 and band(target.vis.bans, aura.vis_flags) == 0 and U6.is_inside_ellipse(target.pos, this.pos, aura.radius) then
			local damage = E:create_entity("damage")
			damage.source_id = this.id
			damage.target_id = target.id
			damage.value = math.random(aura.damage_min, aura.damage_max)
			damage.damage_type = aura.damage_type
			queue_damage(store, damage)
			local mod = E:create_entity(aura.mod)
			mod.modifier.target_id = target.id
			mod.modifier.source_id = this.id
			mod.modifier.level = aura.level
			if type(mod.modifier.duration) == "table" then
				mod.modifier.duration = mod.modifier.duration[aura.level]
			end
			mod.fl_gold_reward = this.fl_gold_per_stun
			queue_insert(store, mod)
		end
	end
	coroutine.yield()
	queue_remove(store, this)
end

scripts.mod_miners_skill_b_stun_FL = {}

function scripts.mod_miners_skill_b_stun_FL.insert(this, store, script)
	local applied = scripts6.mod_stun.insert(this, store, script)
	if applied and this.fl_gold_reward then
		local target = store.entities[this.modifier.target_id]
		signal.emit("got-gold", target.pos, this.fl_gold_reward, "tower_miners")
	end
	return applied
end

scripts.bomb_catapult_roll_FL = {}

function scripts.bomb_catapult_roll_FL.update(this, store, script)
	scripts6.bomb_KR6.update(this, store, script)
	local roll = E:create_entity("aura_catapult_basic_roll_FL")
	local bullet = this.bullet
	local damage_min = bullet.damage_min * (bullet.damage_factor or 1)
	local damage_max = bullet.damage_max * (bullet.damage_factor or 1)
	if bullet.hit_payload == "aura_catapult_skill_b_bomb" then
		local explosion = E:get_template(bullet.hit_payload)
		local level = bullet.level or 1
		damage_min = damage_min + explosion.damage_min_conf[level]
		damage_max = damage_max + explosion.damage_max_conf[level]
	end
	roll.pos = V.vclone(this.bullet.to)
	roll.aura.source_id = this.bullet.source_id
	roll.damage_min = damage_min * 0.15
	roll.damage_max = damage_max * 0.15
	roll.damage_factor = 1
	queue_insert(store, roll)
end

scripts.aura_catapult_basic_roll_FL = {}

function scripts.aura_catapult_basic_roll_FL.update(this, store)
	local available = {}
	for pi in pairs(P.paths) do
		if not store.level.ignore_walk_backwards_paths or not table.contains(store.level.ignore_walk_backwards_paths, pi) then
			available[#available + 1] = pi
		end
	end
	if #available == 0 then
		queue_remove(store, this)
		return
	end
	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available, {1}, true)
	if not nearest or not nearest[1] then
		queue_remove(store, this)
		return
	end
	local pi, spi, ni = unpack(nearest[1])
	local start_ni = ni
	local last_hit_ts = store.tick_ts - this.aura.cycle_time
	while ni > 3 and start_ni - ni <= this.max_nodes do
		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			last_hit_ts = store.tick_ts
			local targets = U6.find_enemies_in_range(store.entities, this.pos, 0, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)
			if targets then
				for _, target in pairs(targets) do
					local d = E:create_entity("damage")
					d.source_id = this.id
					d.target_id = target.id
					d.damage_type = this.damage_type
					d.value = math.ceil(U6.frandom(this.damage_min, this.damage_max) * this.damage_factor)
					queue_damage(store, d)
				end
			end
		end
		local dest = P:node_pos(pi, spi, ni)
		if V.dist2(this.pos.x, this.pos.y, dest.x, dest.y) < 25 then
			ni = ni - 3
			dest = P:node_pos(pi, spi, ni)
		end
		U6.set_destination(this, dest)
		U6.walk(this, store.tick_length)
		local anim, flip = U6.animation_name_facing_point(this, "run", dest, 1, nil, true)
		U6.animation_start(this, anim, flip, store.tick_ts, true)
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.ray_sniper_FL = {}

function scripts.ray_sniper_FL.update(this, store, script)
	local co = coroutine.create(scripts6.ray5_simple.update)
	while true do
		local first = #store.damage_queue + 1
		local done = resume_base(co, this, store, script)
		local last = #store.damage_queue
		for i = first, last do
			local base = store.damage_queue[i]
			if base and base.target_id == this.bullet.target_id then
				local target = store.entities[base.target_id]
				if target and target.health then
					local mr = math.max(0, target.health.magic_armor or 0)
					local amount = target.health.hp_max * mr / this.fl_sniper_divisor * (this.bullet.damage_factor or 1)
					if band(target.vis.flags, F_BOSS) ~= 0 then
						amount = math.min(amount, this.fl_sniper_boss_cap)
					end
					if amount > 0 then
						local bonus = E:create_entity("damage")
						bonus.source_id = this.bullet.source_id
						bonus.target_id = target.id
						bonus.damage_type = DAMAGE_PHYSICAL
						bonus.value = math.ceil(amount)
						queue_damage(store, bonus)
					end
				end
			end
		end
		if done then
			return
		end
		coroutine.yield()
	end
end

scripts.aura_tree_attack_FL = {}

function scripts.aura_tree_attack_FL.update(this, store, script)
	local first = #store.damage_queue + 1
	scripts6.aura_utils.apply_area_damage(this, store, script)
	local last = #store.damage_queue
	if last < first then
		return
	end
	local base = store.damage_queue[math.random(first, last)]
	local bonus = E:create_entity("damage")
	bonus.source_id = this.id
	bonus.target_id = base.target_id
	bonus.damage_type = this.aura.damage_type
	bonus.value = math.ceil(2 * U6.frandom(this.aura.damage_min, this.aura.damage_max) * (this.aura.damage_factor or 1))
	queue_damage(store, bonus)
end

scripts.soldier_tree_FL = {}

function scripts.soldier_tree_FL.update(this, store, script)
	local co = coroutine.create(scripts6.soldier_tree.update)
	while true do
		local first = #store.damage_queue + 1
		local done = resume_base(co, this, store, script)
		local candidates = {}
		for i = first, #store.damage_queue do
			local d = store.damage_queue[i]
			if d.source_id == this.id and d.damage_type == this.melee.attacks[1].damage_type then
				candidates[#candidates + 1] = d
			end
		end
		if #candidates > 0 then
			local attack = this.melee.attacks[1]
			local bonus = E:create_entity("damage")
			bonus.source_id = this.id
			bonus.target_id = candidates[math.random(#candidates)].target_id
			bonus.damage_type = attack.damage_type
			bonus.value = 2 * math.random(attack.damage_min, attack.damage_max)
			queue_damage(store, bonus)
		end
		if done then
			return
		end
		coroutine.yield()
	end
end

scripts.mod_tree_skill_a_armor_FL = {}

function scripts.mod_tree_skill_a_armor_FL.insert(this, store)
	local target = store.entities[this.modifier.target_id]
	if not target or not target.health or target.health.dead then
		return false
	end
	local level = math.max(1, math.min(this.modifier.level or 1, #this.fl_armor_reductions))
	local factor = this.fl_armor_reductions[level]
	this.modifier.duration = this.fl_durations[level]
	this.fl_armor_lost = (target.health.armor or 0) * factor
	this.fl_magic_armor_lost = (target.health.magic_armor or 0) * factor
	if this.fl_armor_lost > 0 then
		SU6.armor_dec(target, this.fl_armor_lost)
	end
	if this.fl_magic_armor_lost > 0 then
		SU6.magic_armor_dec(target, this.fl_magic_armor_lost)
	end
	return true
end

function scripts.mod_tree_skill_a_armor_FL.remove(this, store)
	local target = store.entities[this.modifier.target_id]
	if target then
		if (this.fl_armor_lost or 0) > 0 then
			SU6.armor_inc(target, this.fl_armor_lost)
		end
		if (this.fl_magic_armor_lost or 0) > 0 then
			SU6.magic_armor_inc(target, this.fl_magic_armor_lost)
		end
	end
	return true
end

scripts.mod_forger_skill_c_stun_FL = {}

function scripts.mod_forger_skill_c_stun_FL.insert(this, store, script)
	if not scripts6.mod_stun.insert(this, store, script) then
		return false
	end

	local target = store.entities[this.modifier.target_id]
	if target and target.health then
		this.fl_applied_damage_factor = this.fl_received_damage_factor
		target.health.damage_factor = target.health.damage_factor * this.fl_applied_damage_factor
	end

	return true
end

function scripts.mod_forger_skill_c_stun_FL.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]
	if target and target.health and this.fl_applied_damage_factor then
		target.health.damage_factor = target.health.damage_factor / this.fl_applied_damage_factor
	end

	return scripts6.mod_stun.remove(this, store, script)
end

scripts.soldier_wildcat_FL = {}

function scripts.soldier_wildcat_FL.update(this, store, script)
	local co = coroutine.create(scripts6.soldier_wildcat.update)
	while true do
		local tower = store.entities[this.soldier.tower_id]
		local shared_ts = tower and tower.skill_c_ts
		if tower and this.fl_skill_c_ts then
			tower.skill_c_ts = this.fl_skill_c_ts
		end
		local ok, err = coroutine.resume(co, this, store, script)
		if tower then
			this.fl_skill_c_ts = tower.skill_c_ts
			tower.skill_c_ts = shared_ts
		end
		if not ok then
			error(err)
		end
		if coroutine.status(co) == "dead" then
			return
		end
		coroutine.yield()
	end
end

scripts.bomb_culverine_skill_a_FL = {}

function scripts.bomb_culverine_skill_a_FL.update(this, store, script)
	scripts6.bomb_KR6.update(this, store, script)
	local extra = E:create_entity("aura_bullet_culverine_lvl4")
	extra.pos = V.vclone(this.bullet.to)
	extra.aura.damage_factor = this.bullet.damage_factor or 1
	extra.aura.source_id = this.bullet.source_id
	queue_insert(store, extra)
end

scripts.aura_culverine_skill_b_FL = {}

function scripts.aura_culverine_skill_b_FL.update(this, store, script)
	local first = #store.damage_queue + 1
	scripts6.aura_utils.apply_area_damage(this, store, script)
	local last = #store.damage_queue
	for i = first, last do
		local base = store.damage_queue[i]
		local target = store.entities[base.target_id]
		if target and target.health then
			local armor = math.max(0, target.health.armor or 0)
			if armor > 0 then
				local bonus = E:create_entity("damage")
				bonus.source_id = this.id
				bonus.target_id = target.id
				bonus.damage_type = DAMAGE_TRUE
				bonus.value = math.ceil(100 * armor * this.fl_armor_multiplier * (this.aura.damage_factor or 1))
				queue_damage(store, bonus)
			end
		end
	end
end

scripts.tower_forger_FL = {}

function scripts.tower_forger_FL.update(this, store, script)
	local co = coroutine.create(scripts6.tower_forger.update)
	local original_foremost = U6.find_foremost_enemy
	local original_nearby = U6.find_enemies_in_range
	local ult = this.timed_attacks.list[4]
	local function has_magic_armor(enemy)
		return enemy.health and (enemy.health.magic_armor or 0) > 0
	end
	local preferred_foremost = function(entities, pos, min_range, max_range, prediction, flags, bans, ...)
			local target, targets, predicted = original_foremost(entities, pos, min_range, max_range, prediction, flags, bans, ...)
			if max_range == ult.detection_range and flags == ult.flags and targets then
				local resistant = table.filter(targets, function(_, enemy)
					return has_magic_armor(enemy)
				end)
				if #resistant > 0 then
					return resistant[1], resistant, predicted
				end
			end
			return target, targets, predicted
	end
	local preferred_nearby = function(entities, pos, min_range, max_range, flags, bans, ...)
			local nearby = original_nearby(entities, pos, min_range, max_range, flags, bans, ...)
			if nearby and max_range == ult.grouping_range and flags == ult.flags then
				table.sort(nearby, function(a, b)
					return has_magic_armor(a) and not has_magic_armor(b)
				end)
				local ordered = {}
				for i, enemy in ipairs(nearby) do
					local index = i % 2 == 1 and math.ceil(i / 2) or #nearby - i / 2 + 1
					ordered[index] = enemy
				end
				nearby = ordered
			end
			return nearby
	end
	while true do
		local active = this.powers.ultimate.active
		if active then
			U6.find_foremost_enemy = preferred_foremost
			U6.find_enemies_in_range = preferred_nearby
		end
		local ok, err = coroutine.resume(co, this, store, script)
		if active then
			U6.find_foremost_enemy = original_foremost
			U6.find_enemies_in_range = original_nearby
		end
		if not ok then
			error(err)
		end
		if coroutine.status(co) == "dead" then
			return
		end
		coroutine.yield()
	end
end

scripts.tower_light_priestess_FL = {}

function scripts.tower_light_priestess_FL.update(this, store, script)
	local original = coroutine.create(scripts6.tower_light_priestess.update)

	while true do
		local skill_a = this.powers.skill_a
		local skill_c = this.powers.skill_c

		-- The enhanced skill is a passive aura, so the original timed cast stays disabled.
		skill_c.changed = nil

		if not this.fl_priestess_aura and (skill_a.level > 0 or skill_c.level > 0) then
			local aura = E:create_entity("aura_light_priestess_FL")
			aura.aura.source_id = this.id
			aura.pos = V.vclone(this.pos)
			this.fl_priestess_aura = aura
			queue_insert(store, aura)
		end

		local ok, err = coroutine.resume(original, this, store, script)
		if not ok then
			error(err)
		end
		if coroutine.status(original) == "dead" then
			return
		end
		coroutine.yield()
	end
end

function scripts.tower_light_priestess_FL.remove(this, store, script)
	if this.fl_priestess_aura then
		queue_remove(store, this.fl_priestess_aura)
		this.fl_priestess_aura = nil
	end
	return scripts6.tower_light_priestess.remove(this, store, script)
end

scripts.aura_light_priestess_FL = {}

local function priestess_restore_hp(entry)
	local health = entry.unit.health
	if health then
		health.hp = health.hp / entry.factor
		health.hp_max = health.hp_max / entry.factor
	end
end

local function priestess_restore_tower(entry)
	local tower = entry.tower
	for attack, state in pairs(entry.cooldowns) do
		if attack.cooldown == state.reduced then
			attack.cooldown = state.base
		end
	end
	if tower.tower then
		tower.tower.damage_factor = tower.tower.damage_factor - 0.15
	end
	if tower.fl_priestess_skill_c_owner == entry.owner then
		tower.fl_priestess_skill_c_owner = nil
	end
end

local function priestess_sync_cooldowns(entry, store)
	-- Unlike Dove, these tower scripts read each attack's cooldown directly.
	local tower = entry.tower
	local seen = {}
	local function add_attacks(unit, attacks, timed)
		for index, attack in ipairs(attacks or {}) do
			if type(attack.cooldown) == "number" and attack.cooldown > 0 and not attack.basic_attack
				and (timed or index > 1 or attack.power_name or unit == tower and tower.tower.type == "wicked_sisters") then
				seen[attack] = true
				local state = entry.cooldowns[attack]
				if not state or attack.cooldown ~= state.reduced then
					local base = attack.cooldown
					state = {base = base, reduced = base * 0.75}
					entry.cooldowns[attack] = state
					attack.cooldown = state.reduced
				end
			end
		end
	end
	local function add_unit(unit)
		if not unit then
			return
		end
		add_attacks(unit, unit.timed_attacks and unit.timed_attacks.list, true)
		add_attacks(unit, unit.auras and unit.auras.list, true)
		add_attacks(unit, unit.attacks and unit.attacks.list, false)
		add_attacks(unit, unit.ranged and unit.ranged.attacks, false)
		add_attacks(unit, unit.melee and unit.melee.attacks, false)
	end

	add_unit(tower)
	if tower.barrack then
		for _, soldier in pairs(tower.barrack.soldiers) do
			if soldier.id and store.entities[soldier.id] then
				add_unit(soldier)
			end
		end
	end
	for attack, state in pairs(entry.cooldowns) do
		if not seen[attack] then
			if attack.cooldown == state.reduced then
				attack.cooldown = state.base
			end
			entry.cooldowns[attack] = nil
		end
	end
end

function scripts.aura_light_priestess_FL.update(this, store)
	local hp_targets = {}
	local tower_targets = {}
	this.fl_hp_targets = hp_targets
	this.fl_tower_targets = tower_targets
	local last_cycle = -math.huge

	while true do
		local source = store.entities[this.aura.source_id]
		if not source then
			queue_remove(store, this)
			return
		end
		if store.tick_ts - last_cycle >= this.aura.cycle_time then
			last_cycle = store.tick_ts
			local skill_a = source.powers.skill_a.level
			local skill_c = source.powers.skill_c.level
			local wanted_hp = {}
			if skill_a > 0 then
				local range = source.timed_attacks.list[1].aura_range
				local soldiers = U6.find_soldiers_in_range(store.entities, source.pos, 0, range, F_CUSTOM, F_ENEMY)
				for _, soldier in ipairs(soldiers or {}) do
					wanted_hp[soldier.id] = soldier
				end
			end
			for id, entry in pairs(hp_targets) do
				if wanted_hp[id] ~= entry.unit or entry.level ~= skill_a then
					priestess_restore_hp(entry)
					hp_targets[id] = nil
				end
			end
			if skill_a > 0 then
				local factor = ({1.1, 1.2, 1.3})[skill_a]
				for id, soldier in pairs(wanted_hp) do
					if not hp_targets[id] then
						soldier.health.hp = soldier.health.hp * factor
						soldier.health.hp_max = soldier.health.hp_max * factor
						hp_targets[id] = {unit = soldier, factor = factor, level = skill_a}
					end
				end
			end

			local wanted_towers = {}
			if skill_c > 0 then
				local range = source.timed_attacks.list[3].range
				local towers = U6.find_towers(store.entities, source.pos, 0, range, function(tower)
					return tower.id ~= source.id
				end)
				if towers then
					table.sort(towers, function(a, b)
						local ad = V.len2(a.pos.x - source.pos.x, a.pos.y - source.pos.y)
						local bd = V.len2(b.pos.x - source.pos.x, b.pos.y - source.pos.y)
						return ad == bd and a.id < b.id or ad < bd
					end)
					local selected = 0
					for _, tower in ipairs(towers) do
						if not tower.fl_priestess_skill_c_owner or tower.fl_priestess_skill_c_owner == this.id then
							wanted_towers[tower.id] = tower
							selected = selected + 1
							if selected >= skill_c then
								break
							end
						end
					end
				end
			end
			for id, entry in pairs(tower_targets) do
				if wanted_towers[id] ~= entry.tower then
					priestess_restore_tower(entry)
					tower_targets[id] = nil
				end
			end
			for id, tower in pairs(wanted_towers) do
				if not tower_targets[id] then
					tower.fl_priestess_skill_c_owner = this.id
					tower.tower.damage_factor = tower.tower.damage_factor + 0.15
					tower_targets[id] = {tower = tower, owner = this.id, cooldowns = {}}
				end
				priestess_sync_cooldowns(tower_targets[id], store)
			end
		end
		coroutine.yield()
	end
end

function scripts.aura_light_priestess_FL.remove(this, store)
	for _, entry in pairs(this.fl_hp_targets or {}) do
		priestess_restore_hp(entry)
	end
	for _, entry in pairs(this.fl_tower_targets or {}) do
		priestess_restore_tower(entry)
	end
	return true
end

return scripts
