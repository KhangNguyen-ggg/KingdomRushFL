local log = require("klua.log"):new("game_scripts")

require("klua.table")

local km = require("klua.macros")
local signal = require("hump.signal")
local earnings_stats = require("earnings_stats")
local AC = require("achievements")
local E = require("entity_db")
local GR = require("grid_db")
local GS = require("game_settings")
local P = require("path_db")
local S = require("sound_db")
local SU = require("script_utils_123")
local U = require("utils_123")
local ULH = require("utils_lh")
local LU = require("level_utils")
local UP = require("upgrades")
local V = require("klua.vector")
local W = require("wave_db")
local F = require("klove.font_db")
local I = require("klove.image_db")
local G = love.graphics
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot

require("i18n")

local scripts = require("scripts_123")
local K45 = require("game_scripts-45")

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

local function r(x, y, w, h)
	return {
		pos = v(x, y),
		size = v(w, h)
	}
end

local function tpos(e)
	return e.tower and e.tower.range_offset and V.v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or e.pos
end

--少林
scripts.tower_shaolin = {}

function scripts.tower_shaolin.get_info(this)
	local a = this.attacks.list[1]
	local b = E:get_template(a.bullet)
	local min, max = b.bullet.damage_min, b.bullet.damage_max

	min, max = math.ceil(min * this.tower.damage_factor), math.ceil(max * this.tower.damage_factor)

	local cooldown = this.attacks.enemy_cooldown

	return {
		type = STATS_TYPE_TOWER,
		damage_min = min,
		damage_max = max,
		range = this.attacks.range,
		cooldown = cooldown
	}
end

function scripts.tower_shaolin.insert(this, store)
	this.aura1 = nil
	if this.auras then
		for _, a in pairs(this.auras.list) do
			local e = E:create_entity(a.name)
			e.pos = V.vclone(this.pos)
			e.aura.level = 1
			e.aura.source_id = this.id
			e.aura.ts = store.tick_ts
			if this.powers and this.powers.lion.level >= 1 then
				this.aura1 = e
				queue_insert(store, e)
			end
		end
	end
	if this.tower.level == 4 then
		if not this.barrack.rally_pos and this.tower.default_rally_pos then
			this.barrack.rally_pos = V.vclone(this.tower.default_rally_pos)
		end
	end

	return true
end

function scripts.tower_shaolin.remove(this, store)
	
	if this.pixies then
		for _, e in pairs(this.pixies) do
			if e.is_stun == true then
				SU.stun_dec(e.target_stun)
			end
			e.owner = nil

			queue_remove(store, e)
		end
	end
	
	if this.aura1 then
		queue_remove(store, this.aura1)
	end

	if this.tower.level == 4 then
		for _, s in pairs(this.barrack.soldiers) do
			if s.health then
				s.health.dead = true
			end

			queue_remove(store, s)
		end
	end

	return true
end

function scripts.tower_shaolin.update(this, store)
	local a = this.attacks
	this.pixies = {}
	a.ts = store.tick_ts
	this.idle_offsets = {v(-18, -1),v(21, -3),v(5, -9),
		v(-18, -1),v(21, -3),v(5, -9)}
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

	this.anim_play_out = false
	this.anim_play_in = false
	while true do
		if this.tower.blocked then
			-- block empty
		else
			if pow_t and pow_t.changed and #this.pixies < 6 then
				pow_t.changed = nil

				spawn_pixie()
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

scripts.decal_shaolin = {}

function scripts.decal_shaolin.update(this, store)
	local iflip = this.idle_flip
	local o, slot_pos, slot_flip, enemy_flip
	local punchInName = {"punchIn", "kickIn"}
	local punchOutName = {"punchOut", "kickOut"}
	--U.y_animation_play(this, "punchIn", slot_flip, store.tick_ts)
	this.is_stun = false
	this.target_stun = nil

	while true do
		if this.target_id ~= nil then
			local target = store.entities[this.target_id]

			if not target or target.health.dead then
				-- block empty
			else

				if band(target.vis.bans, F_STUN) == 0 and band(target.vis.flags, F_BOSS) == 0 and (not target.enemy.blockers or #target.enemy.blockers == 0) then
					SU.stun_inc(target)
					this.is_stun = true
					this.target_stun = target
				end

				this.render.sprites[1].hidden = false
				local is_air = band(target.vis.flags, F_FLYING) ~= 0
				local random_action = 1
				if is_air then
					this.pos.x, this.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y
					this.tween.disabled = false
					this.tween.props[1].disabled = false
					this.tween.props[1].ts = store.tick_ts
					this.tween.props[1].keys[2][2].y = math.max(target.unit.hit_offset.y - 20, 5)
					U.animation_start(this, "dragonPunchUp", nil, store.tick_ts)
				else
					slot_pos, slot_flip, enemy_flip = U.melee_slot_position(this, target, 1)
					this.pos.x, this.pos.y = slot_pos.x, slot_pos.y
					random_action = math.random(1, 2)
					U.animation_start(this, punchInName[random_action], slot_flip, store.tick_ts)
				end
				U.y_wait(store, fts(6))

				if target and not target.health.dead then
					local bullet = E:get_template(this.attack.bullet).bullet
					local fx = E:create_entity(bullet.hit_fx)
					if is_air then
						fx.pos.x = target.pos.x + target.unit.hit_offset.x
						fx.pos.y = target.pos.y + target.unit.hit_offset.y
					else
						fx.render.sprites[1].hidden = true
					end
					fx.render.sprites[1].ts = store.tick_ts
					queue_insert(store, fx)
					local d = SU.create_bullet_damage(bullet, target.id, this.id)
					queue_damage(store, d)
				end

				if is_air then
					U.animation_start(this, "dragonPunchDown", nil, store.tick_ts)
					U.y_wait(store, fts(5))
					this.tween.disabled = true
					this.tween.props[1].disabled = true
					U.y_animation_play(this, "dragonPunchOut", nil, store.tick_ts)
				else
					U.y_animation_wait(this)
					U.y_animation_play(this, punchOutName[random_action], slot_flip, store.tick_ts)
				end

				if this.is_stun then
					SU.stun_dec(target)
					this.is_stun = false
					this.target_stun = nil
				end

				if this.attack_level == 1 then
					this.owner.anim_play_in = true
				end
				
				this.render.sprites[1].hidden = true

				o = this.idle_pos
				this.pos.x, this.pos.y = this.owner.pos.x + o.x, this.owner.pos.y + o.y

				--U.y_animation_play(this, "punchIn", slot_flip, store.tick_ts)
			end

			this.target_id = nil
		elseif store.tick_ts - iflip.ts > iflip.cooldown then
			U.animation_start(this, table.random(iflip.animations), math.random() < 0.5, store.tick_ts, iflip.loop)

			iflip.ts = store.tick_ts
		end

		coroutine.yield()
	end
end

scripts.mod_gold = {}

function scripts.mod_gold.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.motion or target.motion.invulnerable or not target.enemy then
		return false
	end

	if this.modifier.excluded_templates and table.contains(this.modifier.excluded_templates, target.template_name) then
		log.paranoid("mod_slow.insert not inserted to %s because of excluded_templates", target.id)

		return false
	end

	log.paranoid("mod_slow.insert (%s)-%s for (%s)-%s", this.id, this.template_name, target.id, target.template_name)

	--target.motion.max_speed = target.motion.max_speed * this.slow.factor
	if not target._gold_factor then
		target._gold_factor = 1
		if target.enemy.gold then
			target._gold_origin = target.enemy.gold
		else
			target._gold_origin = 20
		end
	end
	target._gold_factor = target._gold_factor * this.slow.factor
	local old_gold = target.enemy.gold or 0
	target.enemy.gold = math.floor(target._gold_origin * target._gold_factor)
	earnings_stats.adjust_enemy_bonus(target, "tower_shaolin", target.enemy.gold - old_gold)
	this.modifier.ts = store.tick_ts

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_gold.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target and target.health and target.motion and target.enemy then
		--target.motion.max_speed = target.motion.max_speed / this.slow.factor
		target._gold_factor = target._gold_factor / this.slow.factor
		local old_gold = target.enemy.gold or 0
		target.enemy.gold = math.floor(target._gold_origin * target._gold_factor)
		earnings_stats.adjust_enemy_bonus(target, "tower_shaolin", target.enemy.gold - old_gold)

		log.paranoid("mod_slow.remove (%s)-%s for (%s)-%s", this.id, this.template_name, target.id, target.template_name)
	else
		log.debug("mod_slow.remove target is nil for id %s", this.modifier.target_id)
	end

	return true
end

scripts.aura_tower_shaolin_gold = {}

function scripts.aura_tower_shaolin_gold.insert(this, store, script)
	this.aura.ts = store.tick_ts
	if this.render then
		for _, s in pairs(this.render.sprites) do
			s.ts = store.tick_ts
		end
	end

	if this.aura.source_id then
		local target = store.entities[this.aura.source_id]

		if target and this.render and this.aura.use_mod_offset and target.unit and target.unit.mod_offset then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end
	end

	this.actual_duration = this.aura.duration

	if this.aura.duration_inc then
		this.actual_duration = this.actual_duration + this.aura.level * this.aura.duration_inc
	end

	return true
end

function scripts.aura_tower_shaolin_gold.update(this, store, script)
	local first_hit_ts
	local last_hit_ts = 0
	local cycles_count = 0
	local victims_count = 0

	for _, ps_n in pairs(this.ps_names) do
		local ps = E:create_entity(ps_n)

		ps.particle_system.emit_area_spread = V.vv(this.aura.radius)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	if this.aura.track_source and this.aura.source_id then
		local te = store.entities[this.aura.source_id]

		if te and te.pos then
			this.pos = te.pos
		end
	end

	last_hit_ts = store.tick_ts - this.aura.cycle_time

	if this.aura.apply_delay then
		last_hit_ts = last_hit_ts + this.aura.apply_delay
	end

	while true do
		if this.interrupt then
			last_hit_ts = 1e+99
		end

		if this.aura.cycles and cycles_count >= this.aura.cycles or this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration then
			break
		end

		if this.aura.stop_on_max_count and this.aura.max_count and victims_count >= this.aura.max_count then
			break
		end

		if this.aura.track_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if not te or te.health and te.health.dead and not this.aura.track_dead then
				break
			end
		end

		if this.aura.requires_magic then
			local te = store.entities[this.aura.source_id]

			if not te or not te.enemy then
				goto label_1060_0
			end

			if this.render then
				this.render.sprites[1].hidden = not te.enemy.can_do_magic
			end

			if not te.enemy.can_do_magic then
				goto label_1060_0
			end
		end

		if this.aura.source_vis_flags and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if te and te.vis and band(te.vis.bans, this.aura.source_vis_flags) ~= 0 then
				goto label_1060_0
			end
		end

		if this.aura.requires_alive_source and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if te and te.health and te.health.dead then
				goto label_1060_0
			end
		end

		if not (store.tick_ts - last_hit_ts >= this.aura.cycle_time) or this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
			-- block empty
		else
			if this.render and this.aura.cast_resets_sprite_id then
				this.render.sprites[this.aura.cast_resets_sprite_id].ts = store.tick_ts
			end

			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts
			cycles_count = cycles_count + 1

			local targets = table.filter(store.entities, function(k, v)
				return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
			end)

			for i, target in ipairs(targets) do
				if this.aura.targets_per_cycle and i > this.aura.targets_per_cycle then
					break
				end

				if this.aura.max_count and victims_count >= this.aura.max_count then
					break
				end

				local mods = this.aura.mods or {
					this.aura.mod
				}

				for _, mod_name in pairs(mods) do
					local new_mod = E:create_entity(mod_name)

					new_mod.modifier.level = this.aura.level
					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id

					if this.aura.hide_source_fx and target.id == this.aura.source_id then
						new_mod.render = nil
					end

					queue_insert(store, new_mod)

					victims_count = victims_count + 1
				end
			end
		end

		::label_1060_0::

		coroutine.yield()
	end

	signal.emit("aura-apply-mod-victims", this, victims_count)
	queue_remove(store, this)
end


--冰龙
scripts.hero_eiskalt = {}
--[[
function scripts.hero_eiskalt.get_info(this)
	local m = E:get_template("fireball_eiskalt")
	local min, max = m.bullet.damage_min, m.bullet.damage_max

	return {
		type = STATS_TYPE_SOLDIER,
		hp = this.health.hp,
		hp_max = this.health.hp_max,
		damage_min = min,
		damage_max = max,
		damage_type = DAMAGE_MAGICAL,
		armor = this.health.armor,
		respawn = this.health.dead_lifetime
	}
end
]]--
function scripts.hero_eiskalt.get_info(this)
	local t = scripts.hero_basic.get_info_ranged(this)
	local m = E:get_template(this.ranged.attacks[1].bullet)
    	t.ranged_damage_max = m.bullet.damage_max * this.unit.damage_factor
		t.ranged_damage_min = m.bullet.damage_min * this.unit.damage_factor
		t.ranged_damage_type = m.bullet.damage_type
	return t
end

function scripts.hero_eiskalt.level_up(this, store, initial)
	local hl = this.hero.level
	local ls = this.hero.level_stats

	this.health.hp_max = ls.hp_max[hl]
	this.regen.health = ls.regen_health[hl]
	this.health.armor = ls.armor[hl]

	local b = E:get_template("fireball_eiskalt")

	b.bullet.damage_max = ls.ranged_damage_max[hl]
	b.bullet.damage_min = ls.ranged_damage_min[hl]

	--确定科技等级和数值
	--local m = E:get_template("mod_dracolich_disease")

	--m.dps.damage_min = ls.disease_damage[hl]
	--m.dps.damage_max = ls.disease_damage[hl]

	local s

	--普攻爆炸
	s = this.hero.skills.explosion
	if initial and s.level >= 0 then
		b = E:get_template("fireball_eiskalt")
		b.bullet.damage_radius = s.damage_radius[s.level]
	end


	--冻土
	s = this.hero.skills.coldfury
	if initial and s.level > 0 then
		this.timed_attacks.list[3].disabled = nil
		this.timed_attacks.list[3].cooldown = s.cooldown_time[s.level]
	end

	--雪球
	s = this.hero.skills.frosty
	if initial and s.level > 0 then
		local a = this.timed_attacks.list[1]
		a.disabled = nil
		a.damage_min = s.damage_min[s.level]
		a.damage_max = s.damage_max[s.level]
	end

	--冰刺
	s = this.hero.skills.icepeak
	if initial and s.level > 0 then
		local a = this.timed_attacks.list[2]
		a.disabled = nil
		b = E:get_template("eiskalt_icepeaks")
		b.damage_min = s.damage_min[s.level]
		b.damage_max = s.damage_max[s.level]
	end

	--冰龙大招
	s = this.hero.skills.ultimate
	if initial and s.level >= 0 then
		local u = E:get_template("hero_eiskalt_ultimate")
		u.duration = s.duration[s.level]
	end



	this.health.hp = this.health.hp_max
end

function scripts.hero_eiskalt.insert(this, store)
	this.hero.fn_level_up(this, store, true)

	this.ranged.order = U.attack_order(this.ranged.attacks)

	return true
end

function scripts.hero_eiskalt.update(this, store)
	local h = this.health
	local he = this.hero
	local a, skill, force_idle_ts


	U.y_animation_play(this, "respawn", nil, store.tick_ts, 1)

	this.health_bar.hidden = false
	force_idle_ts = true

	while true do
		if h.dead then
			SU.y_hero_death_and_respawn(store, this)

			force_idle_ts = true
		end

		while this.nav_rally.new do
			SU.y_hero_new_rally(store, this)
		end

		if SU.hero_level_up(store, this) then
			U.y_animation_play(this, "levelup", nil, store.tick_ts, 1)
		end


		--4技能：冰刺（原脊骨雨），召唤物从骨头换成冰刺且固定8根
		a = this.timed_attacks.list[2]
		skill = this.hero.skills.icepeak
		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if not target then
				SU.delay_attack(store, a, 0.4)
			else
				local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
				local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {
					pi
				}, nil, nil, NF_RALLY)

				if #nodes < 1 then
					SU.delay_attack(store, a, 0.4)
				else
					local s_pi, s_spi, s_ni = unpack(nodes[1])
					local flip = target.pos.x < this.pos.x

					U.animation_start(this, "icePeaks", flip, store.tick_ts)
					--skeleton_glow_fx()
					U.y_wait(store, a.spawn_time)

					local delay = 0
					--local n_step = ni < s_ni and -2 or 2
					local n_step = ni < s_ni and -4 or 4

					ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + 6 or ni)

					for i = 1, skill.count[skill.level] do
						local e = E:create_entity(a.entity)

						e.pos = P:node_pos(pi, spi, ni)
						e.render.sprites[1].prefix = e.render.sprites[1].prefix
						e.render.sprites[1].flip_x = math.random() > 0.5
						e.delay = delay
						e.bullet.source_id = this.id
						e.bullet.level = this.hero.skills.icepeak.level

						queue_insert(store, e)

						delay = delay + fts(U.frandom(2, 3))
						ni = ni + n_step
						spi = km.zmod(spi + math.random(1, 2), 3)
					end

					U.y_animation_wait(this)

					force_idle_ts = true
					a.ts = store.tick_ts

					SU.hero_gain_xp_from_skill(this, skill)

					goto label_386_1
				end
			end
		end

		--2技能：永恒冻土（原撞击地面）
		--抄了1代冰女的代码
		a = this.timed_attacks.list[3]
		skill = this.hero.skills.coldfury
		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans)

			if not target then
				SU.delay_attack(store, a, 0.13333333333333333)
			else
				local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
				local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {	pi}, nil, nil, NF_RALLY)

				if #nodes < 1 then
					SU.delay_attack(store, a, 0.4)
				else
					local s_pi, s_spi, s_ni = unpack(nodes[1])
					local flip = target.pos.x < this.pos.x
					local start_ts = store.tick_ts

					U.animation_start(this, "coldFury", flip, store.tick_ts)
					S:queue(a.sound)

					if SU.y_hero_wait(store, this, a.cast_time) then
						goto label_61_0
					end

					a.ts = start_ts

					SU.hero_gain_xp_from_skill(this, skill)

					local delay = 0
					local n_step = ni < s_ni and -a.step or a.step

					ni = km.clamp(1, #P:path(s_pi), ni < s_ni and ni + a.nodes_offset or ni)

					for i = 1, 8 do
						local b = E:create_entity(a.bullet)

						b.pos = P:node_pos(pi, spi, ni)
						b.render.sprites[1].prefix = b.render.sprites[1].prefix
						b.render.sprites[1].flip_x = not flip
						b.delay = delay

						queue_insert(store, b)

                        local fx = E:create_entity(b.aura.hit_decal)
                        fx.pos = V.vclone(b.pos)
                        fx.delay = delay
                        queue_insert(store, fx)

						delay = delay + 0.05
						ni = ni + n_step
						spi = km.zmod(spi + 1, 3)
					end

					SU.y_hero_animation_wait(this)

					goto label_61_0
				end
			end
		end

		::label_61_0::

		--3技能：大雪球（原瘟疫载体）
		a = this.timed_attacks.list[1]
		skill = this.hero.skills.frosty
		if not a.disabled and store.tick_ts - a.ts > a.cooldown then
			local targets_info = U.find_enemies_in_paths(store.entities, this.pos, a.range_nodes_min, a.range_nodes_max, nil, a.vis_flags, a.vis_bans)

			if not targets_info then
				SU.delay_attack(store, a, 0.4)
			else
				local target

				for _, ti in pairs(targets_info) do
					if GR:cell_is(ti.enemy.pos.x, ti.enemy.pos.y, TERRAIN_LAND) then
						target = ti.enemy

						break
					end
				end

				if not target then
					SU.delay_attack(store, a, 0.4)
				else
					local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
					local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {
						pi
					}, nil, nil, NF_RALLY)

					if #nodes < 1 then
						SU.delay_attack(store, a, 0.4)
					else
						local s_pi, s_spi, s_ni = unpack(nodes[1])
						local dir = ni < s_ni and -1 or 1
						local offset = math.random(a.range_nodes_min, a.range_nodes_min + 5)

						s_ni = km.clamp(1, #P:path(s_pi), s_ni + (dir > 0 and offset or -offset))

                        local target_node = P:node_pos(s_pi, s_spi, s_ni, true)
						local flip = target_node.x < this.pos.x

						S:queue(a.sound)
						U.animation_start(this, "frosty", flip, store.tick_ts)
						U.y_wait(store, a.spawn_time)

                        local e = E:create_entity(a.entity)

                        e.bullet.from = v(this.pos.x + (flip and -1 or 1) * a.spawn_offset.x, this.pos.y + a.spawn_offset.y)
                        e.bullet.to = v(target_node.x, target_node.y)
                        e.bullet.level = this.hero.skills.frosty.level
                        --e.pos.x, e.pos.y = this.pos.x + (flip and -1 or 1) * a.spawn_offset.x, this.pos.y + a.spawn_offset.y
                        --e.nav_path.pi = s_pi
                        --e.nav_path.spi = math.random(1, 3)
                        --e.nav_path.ni = s_ni
                        --e.nav_path.dir = dir
                        --e.aura.source_id = this.id
                        --e.aura.level = this.hero.skills.frosty.level

                        queue_insert(store, e)

						U.y_animation_wait(this)

						force_idle_ts = true
						a.ts = store.tick_ts

						SU.hero_gain_xp_from_skill(this, skill)

						goto label_386_1
					end
				end
			end
		end

		--普攻，可直接沿用骨龙的
		for _, i in pairs(this.ranged.order) do
			local a = this.ranged.attacks[i]

			if a.disabled then
				-- block empty
			elseif a.sync_animation and not this.render.sprites[1].sync_flag then
				-- block empty
			elseif store.tick_ts - a.ts < a.cooldown then
				-- block empty
			elseif math.random() > a.chance then
				-- block empty
			else
				local origin = V.v(this.pos.x, this.pos.y + a.bullet_start_offset[1].y)
				local bullet_t = E:get_template(a.bullet)
				local bullet_speed = bullet_t.bullet.min_speed
				local flight_time = bullet_t.bullet.flight_time
				local target = U.find_random_enemy(store.entities, this.pos, a.min_range, a.max_range, a.vis_flags, a.vis_bans, function(v)
					local v_pos = v.pos

					if not v.nav_path then
						return false
					end

					local n_pos = P:node_pos(v.nav_path)

					if V.dist(n_pos.x, n_pos.y, v_pos.x, v_pos.y) > 5 then
						return false
					end

					if a.nodes_limit and (P:get_start_node(v.nav_path.pi) + a.nodes_limit > v.nav_path.ni or P:get_end_node(v.nav_path.pi) - a.nodes_limit < v.nav_path.ni) then
						return false
					end

					if v.motion and v.motion.speed then
						local node_offset

						if flight_time then
							node_offset = P:predict_enemy_node_advance(v, flight_time + a.shoot_time)
						else
							local dist = V.dist(origin.x, origin.y, v.pos.x, v.pos.y)

							node_offset = P:predict_enemy_node_advance(v, dist / bullet_speed)
						end

						v_pos = P:node_pos(v.nav_path.pi, v.nav_path.spi, v.nav_path.ni + node_offset)
					end

					local dist_x = math.abs(v_pos.x - this.pos.x)
					local dist_y = math.abs(v_pos.y - this.pos.y)

					return dist_x > 45
				end)

				if target then
					local start_ts = store.tick_ts
					local b, emit_fx, emit_ps, emit_ts
					local dist = V.dist(origin.x, origin.y, target.pos.x, target.pos.y)
					local node_offset = P:predict_enemy_node_advance(target, dist / bullet_speed)
					local t_pos = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)
					local an, af, ai = U.animation_name_facing_point(this, a.animation, t_pos)

					U.animation_start(this, an, af, store.tick_ts)

					while store.tick_ts - start_ts < a.shoot_time do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_386_0
						end

						coroutine.yield()
					end

					S:queue(a.sound)

					b = E:create_entity(a.bullet)
					b.bullet.target_id = target.id
					b.bullet.source_id = this.id
					b.pos = V.vclone(this.pos)
					b.pos.x = b.pos.x + (af and -1 or 1) * a.bullet_start_offset[ai].x
					b.pos.y = b.pos.y + a.bullet_start_offset[ai].y
					b.bullet.from = V.vclone(b.pos)
					b.bullet.to = V.v(t_pos.x, t_pos.y)
					--print("damage radius"..b.bullet.damage_radius)
					--b.bullet.damage_radius = 20 + 20 * this.hero.skills.explosion.level

					queue_insert(store, b)

					a.ts = start_ts

					while not U.animation_finished(this) do
						if this.unit.is_stunned or this.health.dead or this.nav_rally and this.nav_rally.new then
							goto label_386_0
						end

						coroutine.yield()
					end

					force_idle_ts = true

					::label_386_0::

					goto label_386_1
				end
			end
		end

		SU.soldier_idle(store, this, force_idle_ts)
		SU.soldier_regen(store, this)

		force_idle_ts = nil

		::label_386_1::

		coroutine.yield()
	end
end

--冰冻烟雾
scripts.eiskalt_cold_fury_smoke = {}
function scripts.eiskalt_cold_fury_smoke.update(this, store)
    U.sprites_hide(this)
    if this.delay then
        U.y_wait(store, this.delay)
    end
    for _, s in pairs(this.render.sprites) do
        s.ts = store.tick_ts
    end
    U.sprites_show(this)
    this.tween.disabled = false
    this.tween.ts = store.tick_ts
end

--冰刺
scripts.eiskalt_icepeaks = {}

function scripts.eiskalt_icepeaks.update(this, store)
	local b = this.bullet

	U.sprites_hide(this)

	if this.delay then
		U.y_wait(store, this.delay)
	end

	U.sprites_show(this)

	local start_ts = store.tick_ts

	this.pos.x = this.pos.x + math.random(-4, 4)
	this.pos.y = this.pos.y + math.random(-5, 5)

	S:queue(this.sound_events.delayed_insert)
	U.animation_start(this, "in", nil, store.tick_ts, false)

	this.tween.ts = store.tick_ts

	U.y_wait(store, b.hit_time)

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, b.damage_radius, b.damage_flags, b.damage_bans)

	if targets then
		for _, target in pairs(targets) do
			local d = E:create_damage()

			d.damage_type = b.damage_type
			d.source_id = this.id
			d.target_id = target.id
			d.value = 0 
			if band(target.vis.flags, F_BOSS) == 0 then
				d.value = target.health.hp_max * 0.1 * b.level--百分比伤害
			end
			queue_damage(store, d)

			if b.mod then
				local m = E:create_entity(b.mod)

				m.modifier.source_id = this.id
				m.modifier.target_id = target.id
				m.modifier.xp_dest_id = b.source_id

				queue_insert(store, m)
			end
		end
	end

	U.y_wait(store, b.duration - (store.tick_ts - start_ts))
	U.y_animation_play(this, "out", nil, store.tick_ts, false)
	queue_remove(store, this)
end

--冰球
scripts.hero_eiskalt_frosty = {}

function scripts.hero_eiskalt_frosty.insert(this, store)
	next_pos = P:node_pos(this.nav_path)

	if not next_pos then
		return false
	end

	return true
end

function scripts.hero_eiskalt_frosty.update(this, store)
	local y_off = 20
	local a = this.aura
	local m = this.motion
	local nav = this.nav_path
	local dt = store.tick_length
	local start_ni = nav.ni
	local start_ts = store.tick_ts
	local hit_ts = 0

	a.duration = a.duration + U.frandom(-a.duration_var, 0)
	m.max_speed = m.max_speed + math.random(0, m.max_speed_var)

	local step = m.max_speed * dt
	local next_pos = P:node_pos(nav)

	next_pos.y = next_pos.y + y_off

	U.set_destination(this, next_pos)

	local v_heading = V.v(0, 0)

	v_heading.x, v_heading.y = V.normalize(next_pos.x - this.pos.x, next_pos.y - this.pos.y)

	local th_dist = 25
	local turn_speed = math.pi * 1.5
	local enemies_hit = {}

	if this.delay then
		this.render.sprites[1].hidden = true

		U.y_wait(store, this.delay)

		this.render.sprites[1].hidden = nil
	end

	--local ps = E:create_entity("ps_dracolich_plague")

	--ps.particle_system.track_id = this.id

	--queue_insert(store, ps)

	while true do
		if this.tween.disabled and store.tick_ts - start_ts > a.duration then
			this.tween.disabled = nil
			this.tween.ts = store.tick_ts
			--ps.particle_system.emit = false
		end

		if th_dist > V.len(m.dest.x - this.pos.x, m.dest.y - this.pos.y) then
			nav.ni = nav.ni + math.random(6, 11) * nav.dir

			local p_len = #P:path(nav.pi)

			if nav.ni <= 1 or p_len <= nav.ni then
				a.duration = 0
			end

			nav.ni = km.clamp(1, p_len, nav.ni)
			nav.spi = km.zmod(nav.spi + math.random(1, 2), 3)
			next_pos = P:node_pos(nav)
			next_pos.y = next_pos.y + y_off

			U.set_destination(this, next_pos)
		end

		local dx, dy = V.sub(m.dest.x, m.dest.y, this.pos.x, this.pos.y)
		local sa = km.short_angle(V.angleTo(dx, dy), V.angleTo(v_heading.x, v_heading.y))
		local angle_step = math.min(turn_speed * dt, math.abs(sa)) * km.sign(sa) * -1

		v_heading.x, v_heading.y = V.rotate(angle_step, v_heading.x, v_heading.y)

		local sx, sy = V.mul(step, v_heading.x, v_heading.y)

		this.pos.x, this.pos.y = V.add(this.pos.x, this.pos.y, sx, sy)
		m.speed.x, m.speed.y = sx / dt, sy / dt
		this.render.sprites[1].r = V.angleTo(v_heading.x, v_heading.y)

		if store.tick_ts - hit_ts > a.damage_cycle then
			hit_ts = store.tick_ts

			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.damage_radius, a.damage_flags, a.damage_bans, function(v)
				return not table.contains(enemies_hit, v)
			end)

			if not targets then
				-- block empty
			else
				for _, e in pairs(targets) do
					local d = E:create_damage()

					d.source_id = this.id
					d.target_id = e.id
					d.value = math.random(a.damage_min, a.damage_max)
					d.damage_type = a.damage_type

					queue_damage(store, d)

					if a.mod then
						local m = E:create_entity(a.mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = e.id
						m.modifier.xp_dest_id = a.source_id

						queue_insert(store, m)
					end

					table.insert(enemies_hit, e)
				end
			end
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

--冰球 5代死灵版

scripts.aura_eiskalt_skill_rider = {}

function scripts.aura_eiskalt_skill_rider.update(this, store, script)
	local first_hit_ts
	local last_hit_ts = 0
	local sid_rider = 1
	local sid_fx = 2
	local target_pos = this.pos
	local fading = false
	local spawned_fx = false
	local path_ni = 1
	local path_spi = 1
	local path_pi = 1
	local available_paths = {}

	for k, v in pairs(P.paths) do
		table.insert(available_paths, k)
	end

	if store.level.ignore_walk_backwards_paths then
		available_paths = table.filter(available_paths, function(k, v)
			return not table.contains(store.level.ignore_walk_backwards_paths, v)
		end)
	end

	local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths)

	if #nearest > 0 then
		path_pi, path_spi, path_ni = unpack(nearest[1])

		for _, n in pairs(nearest) do
			local _path_pi, _path_spi, _path_ni = unpack(n)

			if _path_pi == this.path_id then
				path_pi, path_spi, path_ni = _path_pi, _path_spi, _path_ni

				break
			end
		end
	end

	path_spi = 1
	path_ni = path_ni - 3

	local distance = 0

	last_hit_ts = store.tick_ts - this.aura.cycle_time

	if this.aura.apply_delay then
		last_hit_ts = last_hit_ts + this.aura.apply_delay
	end

	local function hit_enemies()
		local targets = table.filter(store.entities, function(k, v)
			return v.unit and v.vis and v.health and not v.health.dead and band(v.vis.flags, this.aura.vis_bans) == 0 and band(v.vis.bans, this.aura.vis_flags) == 0 and U.is_inside_ellipse(v.pos, this.pos, this.aura.radius) and (not this.aura.allowed_templates or table.contains(this.aura.allowed_templates, v.template_name)) and (not this.aura.excluded_templates or not table.contains(this.aura.excluded_templates, v.template_name)) and (not this.aura.filter_source or this.aura.source_id ~= v.id)
		end)

		for i, target in ipairs(targets) do
			local already_hit_target = false
			local has_mod, mods = U.has_modifiers(store, target, this.aura.mod)

			if has_mod then
				for _, mod in pairs(mods) do
					if mod.modifier.source_id == this.id then
						already_hit_target = true

						break
					end
				end
			end

			if already_hit_target then
				-- block empty
			else
				this.damage_max = this.damage_max_config[this.aura.level]
				this.damage_min = this.damage_min_config[this.aura.level]

				if target and not target.health.dead and target.enemy then
					queue_damage(store, SU.create_attack_damage(this, target.id, this.id))

					local hit_fx = E:create_entity(this.hit_fx)

					hit_fx.pos = V.vclone(target.pos)
					hit_fx.pos.x, hit_fx.pos.y = hit_fx.pos.x + target.unit.hit_offset.x, hit_fx.pos.y + target.unit.hit_offset.y
					hit_fx.render.sprites[1].ts = store.tick_ts

					queue_insert(store, hit_fx)

					local new_mod = E:create_entity(this.aura.mod)

					new_mod.modifier.target_id = target.id
					new_mod.modifier.source_id = this.id

					if this.aura.hide_source_fx and target.id == this.aura.source_id then
						new_mod.render = nil
					end

					queue_insert(store, new_mod)
				end
			end
		end
	end

	path_ni = path_ni - 3
	target_pos = P:node_pos(path_pi, path_spi, path_ni)

	local flip_x = target_pos.x < this.pos.x

	U.animation_start(this, "spawn", flip_x, store.tick_ts, 1, sid_rider)
	--U.y_wait(store, fts(21))
	hit_enemies()
	--U.y_wait(store, fts(10))

	this.tween.props[1].disabled = true
	this.tween.props[1].ts = store.tick_ts

	local psA = E:create_entity(this.particles_name_A)

	psA.particle_system.track_id = this.id
	psA.particle_system.emit = true

	queue_insert(store, psA)

	local psB = E:create_entity(this.particles_name_B)

	psB.particle_system.track_id = this.id
	psB.particle_system.emit = true

	queue_insert(store, psB)

	local function rider_go_back_step()
		if V.veq(this.pos, target_pos) then
			this.motion.arrived = true

			return false
		else
			U.set_destination(this, target_pos)

			if U.walk(this, store.tick_length) then
				return false
			else
				local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)

				U.animation_start(this, an, af, store.tick_ts, -1, sid_rider)

				return true
			end
		end
	end

	local function run_backwards()
		local last_pos = this.pos

		distance = V.dist2(target_pos.x, target_pos.y, this.pos.x, this.pos.y)

		if distance < 25 then
			path_ni = path_ni - 3
			target_pos = P:node_pos(path_pi, path_spi, path_ni)
		end

		rider_go_back_step()

		--[[
		if not spawned_fx then
			local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)
			local hit_fx

			if an == "walk_side" then
				hit_fx = E:create_entity(this.spawn_side_fx)
			elseif an == "walk_front" then
				hit_fx = E:create_entity(this.spawn_front_fx)
			else
				hit_fx = E:create_entity(this.spawn_back_fx)
			end

			hit_fx.pos = V.vclone(this.pos)
			hit_fx.render.sprites[1].ts = store.tick_ts
			hit_fx.render.sprites[1].flip_x = af

			queue_insert(store, hit_fx)

			spawned_fx = true
		end
		]]--

		local r = V.angleTo(target_pos.x - last_pos.x, target_pos.y - last_pos.y)

		psA.particle_system.emit_offset.x, psA.particle_system.emit_offset.y = V.rotate(r, psA.emit_offset_relative.x, psA.emit_offset_relative.y)
		psB.particle_system.emit_offset.x, psB.particle_system.emit_offset.y = V.rotate(r, psB.emit_offset_relative.x, psB.emit_offset_relative.y)
	end

	local function check_start_fade()
		if fading then
			return false
		end

		local fade_duration = this.tween.props[1].keys[2][1]

		if this.aura.duration >= 0 and store.tick_ts - this.aura.ts + fade_duration > this.actual_duration then
			return true
		end

		local nearest = P:nearest_nodes(this.pos.x, this.pos.y, available_paths)

		if #nearest > 0 then
			path_pi, path_spi, path_ni = unpack(nearest[1])

			return path_ni < 10
		end

		return false
	end

	while true do
		if this.interrupt then
			last_hit_ts = 1e+99
		end

		this.render.sprites[1].offset.y = 0
		if this.aura.duration >= 0 and store.tick_ts - this.aura.ts > this.actual_duration or fading and this.render.sprites[1].alpha <= 0 then
			break
		end

		if check_start_fade() then
			fading = true
			this.tween.props[1].disabled = false
			this.tween.reverse = true
			this.tween.props[1].ts = store.tick_ts
		end

		if this.aura.source_vis_flags and this.aura.source_id then
			local te = store.entities[this.aura.source_id]

			if te and te.vis and band(te.vis.bans, this.aura.source_vis_flags) ~= 0 then
				goto label_651_0
			end
		end

		if store.tick_ts - last_hit_ts >= this.aura.cycle_time then
			if this.aura.apply_duration and first_hit_ts and store.tick_ts - first_hit_ts > this.aura.apply_duration then
				goto label_651_0
			end

			first_hit_ts = first_hit_ts or store.tick_ts
			last_hit_ts = store.tick_ts

			hit_enemies()
		end

		run_backwards()

		::label_651_0::

		coroutine.yield()
	end

	queue_remove(store, this)
end

--普攻
scripts.fireball_eiskalt = {}

function scripts.fireball_eiskalt.update(this, store)
	local b = this.bullet
	local mspeed = b.min_speed
	local tl = store.tick_length
	local ps
	local targeted_hit_offset = false

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	local target = store.entities[b.target_id]

	if target then
		local dist = V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y)
		local node_offset = P:predict_enemy_node_advance(target, dist / mspeed)

		b.to = P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni + node_offset)

		if band(target.vis.flags, F_FLYING) ~= 0 and target.unit and target.unit.hit_offset then
			targeted_hit_offset = true
			b.to.x, b.to.y = b.to.x + target.unit.hit_offset.x, b.to.y + target.unit.hit_offset.y
		end
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * tl do
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * tl, this.pos.y + b.speed.y * tl
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		coroutine.yield()
	end

	local hit_center = V.vclone(b.to)

	if target and target.unit and target.unit.hit_offset and targeted_hit_offset then
		hit_center.y = hit_center.y - target.unit.hit_offset.y
	end

	local targets = U.find_enemies_in_range(store.entities, hit_center, 0, b.damage_radius, b.vis_flags, b.vis_bans)

	if targets then
		for _, e in pairs(targets) do
			local d = SU.create_bullet_damage(b, e.id, this.id)

			d.xp_dest_id = b.source_id

			queue_damage(store, d)

			if b.mod then
				local mod = E:create_entity(b.mod)

				mod.modifier.target_id = e.id
				mod.modifier.source_id = b.source_id
				mod.xp_dest_id = b.source_id

				queue_insert(store, mod)
			end
		end
	end

	S:queue(this.sound_events.hit)

	local fx, air_hit

	if b.hit_fx_air and target and target.vis and band(target.vis.flags, F_FLYING) ~= 0 then
		fx = E:create_entity(b.hit_fx_air)
		air_hit = true
	elseif b.hit_fx then
		fx = E:create_entity(b.hit_fx)
	end

	if fx then
		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	if b.hit_decal and not air_hit then
		fx = E:create_entity(b.hit_decal)
		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = 0

		queue_insert(store, fx)
	end

	queue_remove(store, this)
end

--冰龙大招
scripts.hero_eiskalt_ultimate = {}
function scripts.hero_eiskalt_ultimate.can_fire_fn(this, x, y, store)
	return not GR:cell_is(x, y, TERRAIN_FAERIE) and P:valid_node_nearby(x, y, 1.4285714285714286, NF_POWER_3)
end

function scripts.hero_eiskalt_ultimate.insert(this, store, script)
	for _, e in pairs(store.entities) do
		if e.template_name == this.template_name then
			log.debug("atomic_freeze already exists, force silent removal")
			queue_remove(store, e)

			this.skip_ice_slabs = true
		end
	end

	return true
end

function scripts.hero_eiskalt_ultimate.update(this, store, script)
	--signal.emit("atomic-freeze-starts")

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, 9999, this.vis_flags, this.vis_bans, function(e)
		return not table.contains(this.excluded_templates, e.template_name)
	end)

	local mod 
	if targets then
		for _, target in pairs(targets) do

			if band(target.vis.flags, F_BOSS) == 0 and band(target.vis.bans, F_FREEZE) == 0 then
				mod = E:create_entity(this.mod)
				mod.modifier.target_id = target.id
				mod.modifier.duration = this.duration

				queue_insert(store, mod)
			end

			
		end
	end

	if this.skip_ice_slabs then
		for _, e in pairs(store.entities) do
			if e.template_name == "decal_user_item_atomic_freeze_slab" then
				e.render.sprites[1].ts = store.tick_ts
			end
		end
	else
		for i = 1, 10 do
			local rpos = P:get_random_position(20, bor(TERRAIN_LAND, TERRAIN_WATER))

			if not rpos then
				log.debug("user_item_atomic_freeze: could not find random position for slab decal. i:%s", i)
			else
				local e = E:create_entity("decal_user_item_atomic_freeze_slab")

				e.duration = this.duration
				e.pos = rpos
				e.render.sprites[1].ts = store.tick_ts
				e.render.sprites[1].name = string.format(e.render.sprites[1].name, math.random(1, e.decals_count))
				e.render.sprites[1].scale = V.v(U.random_sign(), 1)

				queue_insert(store, e)
			end
		end
	end

	--[[
    if mod then
        local overlay_tween_time = 0.5
        local overlay = E:create_entity("overlay_eiskalt_freeze")
        overlay.pos.x, overlay.pos.y = REF_W / 2, REF_H / 2
        overlay.tween.props[1].keys = {
            { 0, 0 },
            { overlay_tween_time, this.freeze_alpha_min }
        }
        overlay.tween.props[1].ts = store.tick_ts
        queue_insert(store, overlay)

        local begin_ts = store.tick_ts
        while begin_ts + mod.modifier.duration > store.tick_ts do
            if not overlay.tween.props[1].loop and store.tick_ts - begin_ts > overlay_tween_time then
                overlay.tween.props[1].loop = true
                overlay.tween.props[1].keys = {
                    { 0, this.freeze_alpha_min },
                    { 0.8, this.freeze_alpha_max },
                    { 1.6, this.freeze_alpha_min }
                }
                overlay.tween.props[1].ts = store.tick_ts
            end

            this.rain.ts = store.tick_ts
            local rain = this.rain
            rain.ts = store.tick_ts

            local angle = U.frandom(rain.angle_min, rain.angle_max)

            for i = 1, rain.count do
                angle = angle + U.frandom(-rain.angle_between, rain.angle_between)

                local dist = math.random(rain.distance_min, rain.distance_max)
                local ox, oy = V.rotate(angle, dist, 0)
                local delay = U.frandom(0.001, rain.delay_max)
                local pos = V.v(math.random(-REF_OX, REF_W + REF_OX), math.random(0, REF_H))
                local e = E:create_entity("fx_power_eiskalt_drop")

                e.pos.x, e.pos.y = pos.x, pos.y
                e.render.sprites[1].offset = V.v(-ox, -oy)
                e.render.sprites[1].r = angle
                e.render.sprites[1].alpha = math.random(rain.alpha_min, rain.alpha_max)
                e.tween.props[1].keys = {
                    { 0, 0 },
                    { 0.001, 255 }
                }
                e.tween.props[2] = E:clone_c("tween_prop")
                e.tween.props[2].keys = {
                    { 0, V.v(-ox, -oy) },
                    { 0.001, V.v(-ox, -oy) },
                    { rain.duration, V.v(0, 0) }
                }
                e.tween.props[2].name = "offset"
                e.tween.ts = store.tick_ts + delay

                queue_insert(store, e)
            end
            coroutine.yield()
        end

        overlay.tween.props[1].keys = {
            { 0, overlay.render.sprites[1].alpha },
            { overlay_tween_time, 0 }
        }
        overlay.tween.props[1].ts = store.tick_ts
        overlay.tween.props[1].loop = false
        overlay.tween.remove = false
	end
	]]
	U.y_wait(store, this.duration)

	--signal.emit("atomic-freeze-ends")
	queue_remove(store, this)
end

--沼巨
scripts.tower_swamp_monster = {}
--[[
function scripts.tower_swamp_monster.get_info(this)
	if not this.tower_upgrade_persistent_data.current_mode or this.tower_upgrade_persistent_data.current_mode == 0 then
		local s = E:create_entity(this.barrack.soldier_type)

		if this.powers then
			for pn, p in pairs(this.powers) do
				for i = 1, p.level do
					SU.soldier_power_upgrade(s, pn)
				end
			end
		end

		local s_info = s.info.fn(s)
		local attacks

		if s.melee and s.melee.attacks then
			attacks = s.melee.attacks
		elseif s.ranged and s.ranged.attacks then
			attacks = s.ranged.attacks
		end

		local min, max

		for _, a in pairs(attacks) do
			if a.damage_min then
				min, max = a.damage_min, a.damage_max

				break
			end
		end

		if min and max then
			min, max = math.ceil(min), math.ceil(max)
		end

		return {
			type = STATS_TYPE_TOWER_BARRACK,
			hp_max = s.health.hp_max,
			damage_min = min,
			damage_max = max,
			armor = s.health.armor,
			respawn = s.health.dead_lifetime
		}
	else
		local b = E:create_entity(this.attacks.list[1].bullet)
		return {
			damage_min = math.ceil(b.bullet.damage_min * this.tower.damage_factor),
			damage_max = math.ceil(b.bullet.damage_max * this.tower.damage_factor),
			range = this.attacks.range,
			type = STATS_TYPE_TOWER,
			cooldown = this.attacks.list[1].cooldown
		}
	end
end
]]--
function scripts.tower_swamp_monster.get_info(this)
	if not this.tower_upgrade_persistent_data.current_mode or this.tower_upgrade_persistent_data.current_mode == 0 then
	   local s = E:create_entity(this.barrack.soldier_type)

	   if this.powers then
	   	for pn, p in pairs(this.powers) do
	   		for i = 1, p.level do
	   			SU.soldier_power_upgrade(s, pn)
	   		end
	   	end
	   end

	   if s.unit and this.tower then
			s.unit.damage_factor = (s.unit.damage_factor or 1) * (this.tower.damage_factor or 1)
	   end
   
	   local s_info = s.info.fn(s)
       local attacks, damage_type
       local min, max
	   local yes_melee = true
       local no_ranged = true
	   local dodge_chance
	   local dodge = nil
   
       if s.melee and s.melee.attacks then
           attacks = s.melee.attacks
           for _, a in pairs(attacks) do
               if a.damage_min then
                   min, max = a.damage_min, a.damage_max
                   damage_type = a.damage_type
                   break
               end
           end
           if s.unit and min then
               min, max = min * s.unit.damage_factor, max * s.unit.damage_factor
           end
   
           if min and max then
               min, max = math.ceil(min), math.ceil(max)
           end
       end
   
       local ranged_min, ranged_max
       local ranged_damage_type
	   local ranged_damage_type
       if s.ranged and s.ranged.attacks then
	   	ranged_attacks = s.ranged.attacks
           for _, a in pairs(ranged_attacks) do
               if not a.disabled and a.bullet then
                   local b = E:get_template(a.bullet)
                   local level = a.level
                   if b and b.bullet.damage_min and b.bullet.damage_max then
                       if level and b.bullet.damage_inc then
                           ranged_min, ranged_max = b.bullet.damage_min + (b.bullet.damage_inc * level),
                               b.bullet.damage_max + (b.bullet.damage_inc * level)
                       else
                           ranged_min, ranged_max = b.bullet.damage_min,b.bullet.damage_max
                       end
                       ranged_damage_type = b.bullet.damage_type
                       break
                   end
               end
           end
   
           if s.unit and ranged_min then
               ranged_min, ranged_max = ranged_min * s.unit.damage_factor, ranged_max * s.unit.damage_factor
           end
   
           if ranged_min and ranged_max then
               ranged_min, ranged_max = math.ceil(ranged_min), math.ceil(ranged_max)
           end
       end
   
       if ranged_damage_type then
           no_ranged = false
       end
   
       local melee_count = 0
       if s.melee and s.melee.attacks then
           melee_count = #s.melee.attacks
       end
   
       if no_ranged and melee_count > 1 then
           while melee_count > 1 do
               local a = s.melee.attacks[melee_count]
               if a.damage_min and not a.disabled then
                   ranged_min, ranged_max = a.damage_min, a.damage_max
                   ranged_damage_type = a.damage_type
                   if s.unit then
                       ranged_min, ranged_max = ranged_min * s.unit.damage_factor, ranged_max * s.unit.damage_factor
                   end
                   ranged_min, ranged_max = math.ceil(ranged_min), math.ceil(ranged_max)
                   break
               end
               melee_count = melee_count - 1
           end
       end
   
	   if s.dodge then
	   	dodge = true
	   	dodge_chance = s.dodge.chance
	   end
   
	   local armor = band(s.health.immune_to, DAMAGE_PHYSICAL) ~= 0 and 1 or s.health.armor
	   local magic_armor = band(s.health.immune_to, DAMAGE_MAGICAL) ~= 0 and 1 or s.health.magic_armor
   
       return {
           type = STATS_TYPE_TOWER_BARRACK,
           hp_max = s.health.hp_max,
   
           damage_min = min,
           damage_max = max,
           damage_type = damage_type,
	   	   damage_icon = s.info.damage_icon,
   
           ranged_damage_min = ranged_min,
           ranged_damage_max = ranged_max,
           ranged_damage_type = ranged_damage_type,
	   	   ranged_damage_icon = s.info.ranged_damage_icon,
   
           armor = armor,
           magic_armor = magic_armor,
	   	   dodge = dodge,
	   	   dodge_chance = dodge_chance,			
           respawn = s.health.dead_lifetime,
           no_ranged = no_ranged,
	   	yes_melee = yes_melee
       }
	else
		local b = E:create_entity(this.attacks.list[1].bullet)
		local dt = b.bullet.damage_type
		return {
			damage_min = math.ceil(b.bullet.damage_min * this.tower.damage_factor),
			damage_max = math.ceil(b.bullet.damage_max * this.tower.damage_factor),
			damage_type = dt,
			range = this.attacks.range,
			type = STATS_TYPE_TOWER,
			cooldown = this.attacks.list[1].cooldown
		}
	end
end

function scripts.tower_swamp_monster.insert(this, store, script)
	if not this.barrack.rally_pos and this.tower.default_rally_pos then
		this.barrack.rally_pos = V.vclone(this.tower.default_rally_pos)
	end

	return true
end

function scripts.tower_swamp_monster.remove(this, store, script)
	for _, s in pairs(this.barrack.soldiers) do
		if s.health then
			s.health.dead = true
		end

		queue_remove(store, s)
	end

	return true
end

function scripts.tower_swamp_monster.update(this, store, script)
	local shooter_sid = this.tower.level == 4 and 4 or 2
	local ab = this.attacks and this.attacks.list[1]

	if this.tower_upgrade_persistent_data.current_mode == nil then
		this.tower_upgrade_persistent_data.current_mode = 0
	end

	b_type = this.barrack.soldier_type
	this.tower_upgrade_persistent_data.collect_hp = this.tower_upgrade_persistent_data.current_mode == 1 and E:get_template(b_type).health.hp_max or 0
	if this.tower.level < 4 then
		if this.tower_upgrade_persistent_data.current_mode == 0 then 
			this.render.sprites[2].hidden = true
			this.barrack.max_soldiers = 1
		else
			this.render.sprites[2].hidden = false
			this.barrack.max_soldiers = 0
		end
	else
		if this.tower_upgrade_persistent_data.current_mode == 0 then 
			this.render.sprites[2].hidden = false
			this.render.sprites[3].hidden = false
			this.render.sprites[4].hidden = true
			this.render.sprites[5].hidden = true
			this.render.sprites[6].hidden = true
			this.barrack.max_soldiers = 1
		else
			this.render.sprites[2].hidden = true
			this.render.sprites[3].hidden = true
			this.render.sprites[4].hidden = false
			this.render.sprites[5].hidden = false
			this.render.sprites[6].hidden = false
			this.barrack.max_soldiers = 0
		end
	end


	local attacks = {}
	if ab then
		table.insert(attacks, ab)--射击
		--table.insert(pows, nil)
	end
	local check_hp_store = false

	local function check_change_mode()
		if this.change_mode then
			this.change_mode = false
			--死亡状态下不能切换
			if this.tower_upgrade_persistent_data.current_mode == 0 and this.barrack.soldiers[1].health.dead then
				return false
			end

			if this.tower_upgrade_persistent_data.current_mode == 0 then
				this.tower_upgrade_persistent_data.collect_hp = math.max(this.barrack.soldiers[1].health.hp, 1)
				this.barrack.max_soldiers = 0
				if this.barrack.soldiers[1] and this.barrack.soldiers[1].health then
					this.barrack.soldiers[1].health.dead = true
				end

				queue_remove(store, this.barrack.soldiers[1])
				this.tower_upgrade_persistent_data.current_mode = 1
			else
				this.barrack.max_soldiers = 1
				this.tower_upgrade_persistent_data.current_mode = 0
				check_hp_store = true
			end

			if this.tower.level < 4 then
				if this.tower_upgrade_persistent_data.current_mode == 0 then 
					this.render.sprites[2].hidden = true
				else
					this.render.sprites[2].hidden = false
				end
			else
				if this.tower_upgrade_persistent_data.current_mode == 0 then 
					this.render.sprites[2].hidden = false
					this.render.sprites[3].hidden = false
					this.render.sprites[4].hidden = true
					this.render.sprites[5].hidden = true
					this.render.sprites[6].hidden = true
				else
					this.render.sprites[2].hidden = true
					this.render.sprites[3].hidden = true
					this.render.sprites[4].hidden = false
					this.render.sprites[5].hidden = false
					this.render.sprites[6].hidden = false
				end
			end
			S:queue("SwampMonsterTaunt")
			return true
		end

		return false
	end

	local function sync_soldier_tower_damage_factor(s)
		if not s or not s.unit then
			return
		end

		local factor = this.tower and this.tower.damage_factor or 1
		local applied = s._tower_damage_factor or 1

		if applied ~= factor then
			s.unit.damage_factor = (s.unit.damage_factor or 1) / applied * factor
			s._tower_damage_factor = factor
		end
	end

	while true do
		
		local b = this.barrack

		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil

					for _, s in pairs(b.soldiers) do
						s.powers[pn].level = p.level
						s.powers[pn].changed = true
					end
				end
			end
		end

		check_change_mode()

		if not this.tower.blocked then
			for i = 1, b.max_soldiers do
				local s = b.soldiers[i]

				if not s or s.health.dead and not store.entities[s.id] then
					s = E:create_entity(b.soldier_type)
					s.soldier.tower_id = this.id
					s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
					s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers)
					s.nav_rally.new = true

					if this.powers then
						for pn, p in pairs(this.powers) do
							s.powers[pn].level = p.level
						end
					end

					sync_soldier_tower_damage_factor(s)

					queue_insert(store, s)

					b.soldiers[i] = s

					signal.emit("tower-spawn", this, s)

				end
			end
		end

		if b.rally_new then
			b.rally_new = false

			signal.emit("rally-point-changed", this)

			local all_dead = true

			for i, s in ipairs(b.soldiers) do
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
				s.nav_rally.new = true
				all_dead = all_dead and s.health.dead
			end

			if not all_dead then
				S:queue(this.sound_events.change_rally_point)
			end
		end

		if check_hp_store == true and b.soldiers[1] then 
			check_hp_store = false
			b.soldiers[1].health.hp = math.min(b.soldiers[1].health.hp_max, this.tower_upgrade_persistent_data.collect_hp)
			this.tower_upgrade_persistent_data.collect_hp = 0
		end

		if this.tower.blocked or this.tower_upgrade_persistent_data.current_mode == 0 then
			coroutine.yield()
		else
			for i, aa in pairs(attacks) do
				if aa and not aa.disabled and store.tick_ts - aa.ts > aa.cooldown then 
					if aa == ab then
						local target
						target = U.find_foremost_enemy(store.entities, tpos(this), 0, this.attacks.range, false, aa.vis_flags, aa.vis_bans)
						if not target then
							--SU.delay_attack(store, aa, fts(5))
						else
							local enemy_id = target.id
							local shoot_pos = pred_pos

							aa.ts = store.tick_ts

							local soffset = this.render.sprites[shooter_sid].offset
							local an, af, ai = U.animation_name_facing_point(this, aa.animation, target.pos, shooter_sid, soffset)
							local start_offset = aa.bullet_start_offset

							if this.tower.level == 4 then
								U.animation_start_group(this, an, af, store.tick_ts, false, "layers")
							else
								U.animation_start(this, an, af, store.tick_ts, false, shooter_sid)
							end
							U.y_wait(store, ab.shoot_time)
							if target then
								local b = E:create_entity(aa.bullet)
								b.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
								b.pos = V.vclone(b.bullet.from)
								b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
								b.bullet.target_id = target.id
								b.bullet.source_id = this.id
								b.bullet.damage_min = math.ceil(b.bullet.damage_min * this.tower.damage_factor)
								b.bullet.damage_max = math.ceil(b.bullet.damage_max * this.tower.damage_factor)

								--投手的额外mod
								if this.powers and this.powers.stun.level > 0 and math.random() < this.powers.stun.mod_chance[this.powers.stun.level] then
									b.bullet.mod = "mod_swamp_stun"
								end
								if this.powers and this.powers.instakill.level > 0
									and math.random() < this.powers.instakill.mod_chance[this.powers.instakill.level]
									and band(target.vis.flags, bor(F_BOSS, F_MINIBOSS)) == 0
									and band(target.vis.bans, F_INSTAKILL) == 0 then
									b.render.sprites[1].name = "Swamp_monster_tower_proyectile_instakill_lvl4"
									b.bullet.damage_type = bor(DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS)
								end
								if this.powers and this.powers.eat.level > 0 then
									local d = SU.create_bullet_damage(b.bullet, target.id, this.id)
									--queue_damage(store, d)
									local will_kill = U.predict_damage(target, d) >= target.health.hp
									if will_kill then
										this.tower_upgrade_persistent_data.collect_hp = this.tower_upgrade_persistent_data.collect_hp + this.powers.eat.hp
									end
								end
								queue_insert(store, b)
							end
							while not U.animation_finished(this, shooter_sid) do
								coroutine.yield()
							end
							local an2 = an == "shootUp" and "idleUp" or "idle" 
							if this.tower.level == 4 then
								U.animation_start_group(this, an2, af, store.tick_ts, true, "layers")
							else
								U.animation_start(this, an2, af, store.tick_ts, true, shooter_sid)
							end
						end		
					end
				end
			end

		end
		coroutine.yield()
	end
end

--沼巨战士
scripts.soldier_swamp_monster = {}

function scripts.soldier_swamp_monster.insert(this, store)
	if scripts.soldier_barrack.insert(this, store) then
		if this.powers then
			for pn, p in pairs(this.powers) do

				if pn == "instakill" then
						--this.health.dark_spiked_armor = p.dark_spiked_armor[p.level]
						--this.render.sprites[1].prefix = "soldier_dark_knight_spikes"
						this.melee.attacks[1].chance = 1 - this.powers.stun.level * this.melee.attacks[2].chance_inc - this.powers.instakill.level * this.melee.attacks[3].chance_inc
						this.melee.attacks[3].chance = this.powers.instakill.level * this.melee.attacks[3].chance_inc
						this.melee.attacks[2].chance = this.powers.stun.level * this.melee.attacks[2].chance_inc
				end
					if pn == "stun" then
						this.melee.attacks[1].chance = 1 - this.powers.stun.level * this.melee.attacks[2].chance_inc - this.powers.instakill.level * this.melee.attacks[3].chance_inc
						this.melee.attacks[2].chance = this.powers.stun.level * this.melee.attacks[2].chance_inc
						this.melee.attacks[3].chance = this.powers.instakill.level * this.melee.attacks[3].chance_inc
						
					end
			end
		end

		return true
	end

	return false
end

function scripts.soldier_swamp_monster.update(this, store)
	local brk, sta
	local tower = store.entities[this.soldier.tower_id]

	local function sync_tower_damage_factor()
		tower = store.entities[this.soldier.tower_id]

		local factor = tower and tower.tower and tower.tower.damage_factor or 1
		local applied = this._tower_damage_factor or 1

		if this.unit and applied ~= factor then
			this.unit.damage_factor = (this.unit.damage_factor or 1) / applied * factor
			this._tower_damage_factor = factor
		end
	end

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	while true do
		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil

					SU.soldier_power_upgrade(this, pn)

					if pn == "instakill" then
						--this.health.dark_spiked_armor = p.dark_spiked_armor[p.level]
						--this.render.sprites[1].prefix = "soldier_dark_knight_spikes"
						this.melee.attacks[1].chance = 1 - this.powers.stun.level * this.melee.attacks[2].chance_inc - this.powers.instakill.level * this.melee.attacks[3].chance_inc
						this.melee.attacks[3].chance = this.powers.instakill.level * this.melee.attacks[3].chance_inc
						this.melee.attacks[2].chance = this.powers.stun.level * this.melee.attacks[2].chance_inc
					end
					if pn == "stun" then
						this.melee.attacks[1].chance = 1 - this.powers.stun.level * this.melee.attacks[2].chance_inc - this.powers.instakill.level * this.melee.attacks[3].chance_inc
						this.melee.attacks[2].chance = this.powers.stun.level * this.melee.attacks[2].chance_inc
						this.melee.attacks[3].chance = this.powers.instakill.level * this.melee.attacks[3].chance_inc
						
					end
					--print(this.melee.attacks[1].chance.." "..this.melee.attacks[2].chance.." "..this.melee.attacks[3].chance)
				end
			end
		end

		if not this.health.dead or SU.y_soldier_revive(store, this) then
			-- block empty
		else
			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			sync_tower_damage_factor()
			--[[
			if this.dodge and this.dodge.active then
				local ca = this.dodge.shield

				this.dodge.active = false

				if this.powers[this.dodge.power_name].level > 0 and store.tick_ts - ca.ts > ca.cooldown then
					local start_ts = store.tick_ts

					ca.ts = 0
					this.health.ignore_damage = true
					this.vis.bans = bor(this.vis.bans, F_NET)

					S:queue(ca.sound)
					U.y_animation_play(this, ca.animation_start, nil, store.tick_ts, 1)
					U.y_wait(store, ca.hit_time)

					while store.tick_ts - start_ts < ca.duration do
						if store.tick_ts - ca.ts > ca.damage_every then
							ca.ts = store.tick_ts
						end
						
						if this.nav_rally.new then
							this.vis.bans = band(this.vis.bans, bnot(F_NET))
							this.health.ignore_damage = false
							goto label_612_1
						end

						coroutine.yield()
					end

					this.vis.bans = band(this.vis.bans, bnot(F_NET))
					
					U.y_animation_play(this, ca.animation_end, nil, store.tick_ts, 1)
					
					this.health.ignore_damage = false

					SU.soldier_idle(store, this)
					signal.emit("soldier-dodge", this)
				end
			end
			]]--
			::label_612_1::
			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto label_61_1
				end
			end

			--brk, sta = SU.y_soldier_melee_block_and_attacks(store, this) --y_swamp_melee_block_and_attacks
			brk, sta = SU.y_swamp_melee_block_and_attacks(store, this)

			if brk or sta ~= A_NO_TARGET then
				-- block empty
			else

				if brk or sta == A_DONE then
					goto label_61_1
				elseif sta == A_IN_COOLDOWN then
					goto label_61_0
				end

				if SU.soldier_go_back_step(store, this) then
					goto label_61_1
				end

				::label_61_0::

				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end

		::label_61_1::

		coroutine.yield()
	end
end



-- SC Reset 3.6 branch towers -------------------------------------------------

local function sc_source_tower(store, source_id)
	local source = store.entities[source_id]

	if source and source.tower and not source.tower.destroy then
		return source
	end
end

local function sc_source_damage_factor(store, source_id)
	local source = sc_source_tower(store, source_id)

	return source and source.tower.damage_factor or 1
end

local function sc_apply_mod(store, name, source_id, target_id, level, duration)
	local mod = E:create_entity(name)

	mod.modifier.source_id = source_id
	mod.modifier.target_id = target_id
	mod.modifier.level = level or 0
	if duration then
		mod.modifier.duration = duration
	end

	queue_insert(store, mod)
	return mod
end

local function sc_refresh_or_apply_mod(store, name, source_id, target_id, level, duration, refresh_source)
	for _, entity in pairs(store.entities) do
		if entity.template_name == name and entity.modifier and entity.modifier.target_id == target_id then
			entity.modifier.ts = store.tick_ts
			entity.modifier.level = level or entity.modifier.level
			entity.modifier.duration = duration or entity.modifier.duration
			if refresh_source then
				entity.modifier.source_id = source_id
			end
			return entity
		end
	end

	return sc_apply_mod(store, name, source_id, target_id, level, duration)
end

local function sc_queue_damage(store, source_id, target, value, damage_type)
	local damage = E:create_damage()

	damage.source_id = source_id
	damage.target_id = target.id
	damage.value = value
	damage.damage_type = damage_type
	queue_damage(store, damage)
end

local function sc_radius(source_diameter)
	return source_diameter / 2
end

local function sc_spawn_reinforcement(store, name, pos, rally_pos)
	local soldier = E:create_entity(name)

	soldier.pos = V.vclone(pos)
	if soldier.nav_rally then
		soldier.nav_rally.pos = V.vclone(rally_pos or pos)
		soldier.nav_rally.center = V.vclone(rally_pos or pos)
		soldier.nav_rally.new = true
	end
	queue_insert(store, soldier)
	return soldier
end

local function sc_spawn_path_soldier(store, name, pos)
	local nodes = P:nearest_nodes(pos.x, pos.y, nil, nil, true)

	if not nodes or #nodes == 0 then
		log.error("SC branch tower could not find an active path at %s,%s", pos.x, pos.y)
		return nil
	end

	local pi = nodes[1][1]
	local spi = math.random(1, #P.paths[pi])
	local subpath_nodes = P:nearest_nodes(pos.x, pos.y, {pi}, {spi}, true)
	local node = subpath_nodes[1] or nodes[1]
	local soldier = E:create_entity(name)

	soldier.nav_path.pi = node[1]
	soldier.nav_path.spi = node[2]
	soldier.nav_path.ni = node[3]
	soldier.pos = V.vclone(pos)
	queue_insert(store, soldier)
	return soldier
end

local function sc_path_positions(target, count, spacing)
	local positions = {}

	if not target or not target.nav_path then
		return positions
	end

	local pi, spi, ni = target.nav_path.pi, target.nav_path.spi, target.nav_path.ni
	local first_offset = -math.floor((count - 1) / 2) * spacing
	local path = P.paths[pi] and P.paths[pi][spi]

	if not path then
		return positions
	end

	for i = 1, count do
		local path_ni = km.clamp(1, #path, ni + first_offset + (i - 1) * spacing)
		local pos = P:node_pos(pi, spi, path_ni)

		if pos then
			positions[#positions + 1] = V.vclone(pos)
		end
	end

	return positions
end

local function sc_find_crowded_enemy(store, origin, range, crowd_range, vis_flags, vis_bans)
	local candidates = U.find_enemies_in_range(store.entities, origin, 0, range, vis_flags, vis_bans) or {}
	local best, best_count

	for _, candidate in pairs(candidates) do
		local crowd = U.find_enemies_in_range(store.entities, candidate.pos, 0, crowd_range, vis_flags, vis_bans) or {}

		if not best_count or #crowd > best_count then
			best = candidate
			best_count = #crowd
		end
	end

	return best
end

local function sc_fire_bullet(store, name, source, target, offset)
	local bullet = E:create_entity(name)
	local start = offset or V.v(0, 0)
	local hit_offset = target.unit and target.unit.hit_offset or V.v(0, 0)

	bullet.pos = V.v(source.pos.x + start.x, source.pos.y + start.y)
	bullet.bullet.from = V.vclone(bullet.pos)
	bullet.bullet.to = V.v(target.pos.x + hit_offset.x, target.pos.y + hit_offset.y)
	bullet.bullet.target_id = target.id
	bullet.bullet.source_id = source.id
	if source.tower then
		bullet.bullet.damage_factor = source.tower.damage_factor
	end
	queue_insert(store, bullet)
	return bullet
end

scripts.sc_branch_barrack = {}

function scripts.sc_branch_barrack.insert(this, store, script)
	local ok = scripts.tower_barrack.insert(this, store, script)

	if ok and this.sc_controller then
		local controller = E:create_entity(this.sc_controller)
		controller.source_id = this.id
		controller.pos = V.vclone(this.pos)
		queue_insert(store, controller)
		this.sc_controller_id = controller.id
	end

	return ok
end

function scripts.sc_branch_barrack.remove(this, store, script)
	if this.sc_controller_id and store.entities[this.sc_controller_id] then
		queue_remove(store, store.entities[this.sc_controller_id])
	end

	return scripts.tower_barrack.remove(this, store, script)
end

function scripts.sc_branch_barrack.update(this, store, script)
	local function sync_soldier_powers(soldier)
		if not this.powers or not soldier.powers then
			return
		end

		for power_name, tower_power in pairs(this.powers) do
			local soldier_power = soldier.powers[power_name]

			if soldier_power then
				soldier_power.level = tower_power.level
				for _, attacks in pairs({soldier.melee and soldier.melee.attacks, soldier.ranged and soldier.ranged.attacks}) do
					if attacks then
						for _, attack in pairs(attacks) do
							if attack.power_name == power_name then
								attack.level = tower_power.level
								attack.disabled = tower_power.level == 0 and true or nil
								if attack.damage_inc then
									attack._sc_damage_min = attack._sc_damage_min or attack.damage_min
									attack._sc_damage_max = attack._sc_damage_max or attack.damage_max
									attack.damage_min = attack._sc_damage_min + attack.damage_inc * tower_power.level
									attack.damage_max = attack._sc_damage_max + attack.damage_inc * tower_power.level
								end
							end
						end
					end
				end
				if soldier.timed_actions then
					for _, action in pairs(soldier.timed_actions.list) do
						if action.power_name == power_name then
							action.level = tower_power.level
							action.disabled = tower_power.level == 0 and true or nil
						end
					end
				end
			end
		end
	end

	while true do
		local barrack = this.barrack

		if this.powers then
			for _, power in pairs(this.powers) do
				if power.changed then
					power.changed = nil
				end
			end
		end

		for _, soldier in pairs(barrack.soldiers) do
			if soldier then
				sync_soldier_powers(soldier)
			end
		end

		if not this.tower.blocked then
			for i = 1, barrack.max_soldiers do
				local soldier = barrack.soldiers[i]

				if not soldier or soldier.health.dead and not store.entities[soldier.id] then
					soldier = E:create_entity(barrack.soldier_type)
					soldier.soldier.tower_id = this.id
					soldier.soldier.tower_soldier_idx = i
					soldier.pos = V.v(this.pos.x + barrack.respawn_offset.x, this.pos.y + barrack.respawn_offset.y)
					soldier.nav_rally.pos, soldier.nav_rally.center = U.rally_formation_position(i, barrack, barrack.max_soldiers)
					soldier.nav_rally.new = true

					sync_soldier_powers(soldier)

					queue_insert(store, soldier)
					barrack.soldiers[i] = soldier
					signal.emit("tower-spawn", this, soldier)
				end
			end
		end

		if barrack.rally_new then
			barrack.rally_new = false
			signal.emit("rally-point-changed", this)

			for i, soldier in ipairs(barrack.soldiers) do
				if soldier and soldier.nav_rally then
					soldier.nav_rally.pos, soldier.nav_rally.center = U.rally_formation_position(i, barrack, barrack.max_soldiers, barrack.rally_angle_offset)
					soldier.nav_rally.new = true
				end
			end

			S:queue(this.sound_events.change_rally_point)
		end

		coroutine.yield()
	end
end

scripts.sc_rat_controller = {}

scripts.sc_harpooner = {}

function scripts.sc_harpooner.insert(this, store, script)
	if this.soldier.tower_soldier_idx == 2 then
		this.render.sprites[1].prefix = "harpooner_girl"
		this.ranged.attacks[1].bullet = "bullet_sc_harpooner_girl"
	end

	return scripts.soldier_barrack.insert(this, store, script)
end

scripts.sc_harpooner_stun_roll = {}

function scripts.sc_harpooner_stun_roll.insert(this, store)
	if math.random() < 0.25 then
		sc_apply_mod(store, "mod_sc_harpooner_stun", this.modifier.source_id, this.modifier.target_id)
	end
	return false
end

scripts.sc_path_soldier = {}

function scripts.sc_path_soldier.get_info(this)
	local info = scripts.soldier_barrack.get_info(this)

	info.respawn = nil
	return info
end

function scripts.sc_path_soldier.insert(this, store, script)
	this.melee.order = U.attack_order(this.melee.attacks)
	this.nav_path.ni = this.nav_path.ni + math.random(3, 6)
	this.pos = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)

	return this.pos ~= nil
end

function scripts.sc_path_soldier.update(this, store, script)
	local attack = this.melee.attacks[1]
	local next_pos = V.vclone(this.pos)

	while true do
		if this.health.dead then
			this.health.hp = 0
			SU.y_soldier_death(store, this)
			queue_remove(store, this)
			return
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, true)
		else
			local brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if not brk and sta == A_NO_TARGET then
				local nearest = P:nearest_nodes(this.pos.x, this.pos.y, {this.nav_path.pi}, {this.nav_path.spi})

				if nearest and nearest[1] and nearest[1][3] < this.nav_path.ni then
					this.nav_path.ni = nearest[1][3]
				end

				local target
				while next_pos and not target and not this.health.dead and not this.unit.is_stunned do
					U.set_destination(this, next_pos)
					local an, af = U.animation_name_facing_point(this, "walk", this.motion.dest)
					U.animation_start(this, an, af, store.tick_ts, true)
					U.walk(this, store.tick_length)
					coroutine.yield()
					target = U.find_foremost_enemy(store.entities, this.pos, 0, this.melee.range, false, attack.vis_flags, attack.vis_bans)
					next_pos = P:next_entity_node(this, store.tick_length)
				end

				if this.health.dead or not next_pos then
					this.health.hp = 0
					U.y_animation_play(this, "death", nil, store.tick_ts, 1)
					queue_remove(store, this)
					return
				end
			end
		end

		coroutine.yield()
	end
end

scripts.sc_poisonous_rat = {}

function scripts.sc_poisonous_rat.update(this, store, script)
	local sprite = this.render.sprites[1]

	if this.spawn_delay and this.spawn_delay > 0 then
		sprite.hidden = true
		U.y_wait(store, this.spawn_delay)
		sprite.hidden = nil
	end

	local aura_ts = store.tick_ts - this.aura.cooldown
	local next_pos = P:next_entity_node(this, store.tick_length)

	while next_pos do
		if store.tick_ts - aura_ts >= this.aura.cooldown then
			aura_ts = store.tick_ts
			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.aura.range, F_MOD, bor(F_FLYING, F_NIGHTMARE)) or {}

			for _, target in ipairs(targets) do
				sc_refresh_or_apply_mod(store, "mod_sc_rat_swarm_dot", this.source_id, target.id, this.level, ({5, 6, 7})[this.level])
				sc_refresh_or_apply_mod(store, "mod_sc_rat_swarm_slow", this.source_id, target.id, this.level, ({5, 6, 7})[this.level])
			end
		end

		U.set_destination(this, next_pos)
		local animation, flip = U.animation_name_facing_point(this, "walk", this.motion.dest)

		U.animation_start(this, animation, flip, store.tick_ts, true)
		U.walk(this, store.tick_length)
		coroutine.yield()
		next_pos = P:next_entity_node(this, store.tick_length)
	end

	queue_remove(store, this)
end

function scripts.sc_rat_controller.update(this, store)
	local shooter_data = {
		{sprite = 4, offset = V.v(-14, 45)},
		{sprite = 5, offset = V.v(4, 34)}
	}
	local next_shot_ts = {store.tick_ts, store.tick_ts}
	local idle_ts = {}
	local small_ts = store.tick_ts - 7
	local swarm_ts = store.tick_ts
	local big_ts = store.tick_ts
	local big_rat_id
	local swarm_animation_end_ts

	while true do
		local tower = sc_source_tower(store, this.source_id)

		if not tower then
			break
		end

		this.pos = tower.pos
		if swarm_animation_end_ts and store.tick_ts >= swarm_animation_end_ts then
			U.animation_start(tower, "IdleBase", nil, store.tick_ts, true, 2)
			U.animation_start(tower, "idle", nil, store.tick_ts, true, 3)
			swarm_animation_end_ts = nil
		end

		for index, data in ipairs(shooter_data) do
			if idle_ts[index] and store.tick_ts >= idle_ts[index] then
				U.animation_start(tower, "idle", nil, store.tick_ts, true, data.sprite)
				idle_ts[index] = nil
			end

			if not tower.tower.blocked and store.tick_ts >= next_shot_ts[index] then
				local shooter_pos = V.v(tower.pos.x + data.offset.x, tower.pos.y + data.offset.y)
				local target = U.find_random_enemy(store.entities, shooter_pos, 0, sc_radius(300), F_RANGED, F_NIGHTMARE)

				if target then
					local flip = target.pos.x < shooter_pos.x
					local shot_offset = V.v(data.offset.x + (flip and -10 or 10), data.offset.y + 12)

					U.animation_start(tower, "range", flip, store.tick_ts, false, data.sprite)
					sc_fire_bullet(store, "sc_rat_small_bolt", tower, target, shot_offset)
					next_shot_ts[index] = store.tick_ts + U.frandom(0.8, 1)
					idle_ts[index] = store.tick_ts + 0.3
				end
			end
		end

		if not tower.tower.blocked and store.tick_ts - small_ts >= 7 then
			small_ts = store.tick_ts
			S:queue("UndergroundWarriorsSkill")
			local level = tower.powers.training.level
			local soldier = sc_spawn_path_soldier(store, "soldier_sc_underground", tower.pos)

			if soldier then
				soldier.health.hp_max = ({100, 120, 145, 175})[level + 1]
				soldier.health.hp = soldier.health.hp_max
				soldier.health.armor = ({0, 0.1, 0.2, 0.3})[level + 1]
				soldier.melee.attacks[1].damage_min = 17
				soldier.melee.attacks[1].damage_max = 25
				soldier.melee.attacks[2].damage_min = 17
				soldier.melee.attacks[2].damage_max = 25
				soldier.melee.attacks[2].chance = ({0, 0.2, 0.3, 0.4})[level + 1]
				soldier.melee.attacks[2].mod = ({nil, "mod_sc_underground_stun_1", "mod_sc_underground_stun_2", "mod_sc_underground_stun_3"})[level + 1]
			end
		end

		local big_level = tower.powers.big_rat.level
		local big_rat = big_rat_id and store.entities[big_rat_id]
		if big_level > 0 and not big_rat and store.tick_ts - big_ts >= ({34, 29, 24})[big_level] then
			big_ts = store.tick_ts
			big_rat = sc_spawn_path_soldier(store, "soldier_sc_big_rat", tower.pos)
			if big_rat then
				big_rat.health.hp_max = ({480, 540, 620})[big_level]
				big_rat.health.hp = big_rat.health.hp_max
				big_rat_id = big_rat.id
			end
		end

		local swarm_level = tower.powers.rat_swarm.level
		if swarm_level > 0 and not tower.tower.blocked and store.tick_ts - swarm_ts >= 18 then
			local target = U.find_random_enemy(store.entities, tower.pos, 0, sc_radius(280), F_MOD, bor(F_FLYING, F_NIGHTMARE), function(enemy)
				return enemy.nav_path ~= nil
			end)

			if target then
				swarm_ts = store.tick_ts
				S:queue("UndergroundWarriorsRatSwarm")
				U.animation_start(tower, "IdleBaseSkillAction", nil, store.tick_ts, false, 2)
				U.animation_start(tower, "IdleBaseSkillAction", nil, store.tick_ts, false, 3)
				swarm_animation_end_ts = store.tick_ts + 0.7

				for i = 1, 6 do
					local rat = E:create_entity("unit_sc_poisonous_rat")
					local pi = target.nav_path.pi
					local spi = math.random(1, #P.paths[pi])
					local nodes = P:nearest_nodes(target.pos.x, target.pos.y, {pi}, {spi}, true)
					local node = nodes and nodes[1]

					rat.nav_path.pi = pi
					rat.nav_path.spi = node and node[2] or target.nav_path.spi
					rat.nav_path.ni = node and node[3] or target.nav_path.ni
					rat.nav_path.dir = -1
					rat.pos = V.vclone(target.pos)
					rat.source_id = tower.id
					rat.level = swarm_level
					rat.spawn_delay = (i - 1) * 0.1
					queue_insert(store, rat)
				end
			end
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.sc_rat_shield = {}

function scripts.sc_rat_shield.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end

	this.modifier.duration = ({3, 4, 5})[this.modifier.level]
	this.previous_ignore_damage = target.health.ignore_damage
	target.health.ignore_damage = true
	this.modifier.ts = store.tick_ts
	return true
end

function scripts.sc_rat_shield.remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target and target.health then
		target.health.ignore_damage = this.previous_ignore_damage or false
	end
	return true
end

scripts.sc_avenger_controller = {}

function scripts.sc_avenger_controller.update(this, store)
	local curse_ts = {}

	while true do
		local tower = sc_source_tower(store, this.source_id)

		if not tower then
			break
		end
		this.pos = tower.pos

		for _, soldier in pairs(tower.barrack.soldiers) do
			if soldier and soldier.health and not soldier.health.dead then
				-- Adjust only the stance's base resistance; direct assignment each tick
				-- would erase temporary bonuses such as the KR6 priestess aura.
				local base_armor = soldier.soldier.target_id and 0.5 or 0.9
				local previous_armor = soldier.sc_avenger_base_armor or 0.9

				if base_armor ~= previous_armor then
					SU.armor_inc(soldier, base_armor - previous_armor)
					soldier.sc_avenger_base_armor = base_armor
				end

				local base_magic_armor = 0.45 * math.min(tower.powers.magic_armor.level, 2)
				local previous_magic_armor = soldier.sc_avenger_base_magic_armor or 0

				if base_magic_armor ~= previous_magic_armor then
					SU.magic_armor_inc(soldier, base_magic_armor - previous_magic_armor)
					soldier.sc_avenger_base_magic_armor = base_magic_armor
				end
				local level = soldier.powers.death_curse.level
				if curse_ts[soldier.id] == nil then
					curse_ts[soldier.id] = store.tick_ts
				end
				local last_ts = curse_ts[soldier.id]

				if level > 0 and store.tick_ts - last_ts >= 7.5 then
					local targets = U.find_enemies_in_range(store.entities, soldier.pos, 0, sc_radius(150), F_MOD, F_NIGHTMARE) or {}
					if #targets >= 2 then
						curse_ts[soldier.id] = store.tick_ts
					for _, target in pairs(targets) do
						if not U.has_modifiers(store, target, "mod_sc_avenger_curse") then
							sc_apply_mod(store, "mod_sc_avenger_curse", soldier.id, target.id, level, 9999)
						end
					end
					end
				end
			end
		end
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.sc_avenger_bonus = {}

function scripts.sc_avenger_bonus.insert(this, store)
	local source = store.entities[this.modifier.source_id]
	local target = store.entities[this.modifier.target_id]
	local level = source and source.powers and source.powers.twilight_blade.level or 0

	if target and target.health and not target.health.dead and level > 0 then
		sc_queue_damage(store, source.id, target, ({5, 10})[level], DAMAGE_TRUE)
	end
	return false
end

scripts.sc_avenger_curse = {}

function scripts.sc_avenger_curse.update(this, store)
	local target = store.entities[this.modifier.target_id]

	while target and not target.health.dead and store.tick_ts - this.modifier.ts < this.modifier.duration do
		this.pos = target.pos
		coroutine.yield()
		target = store.entities[this.modifier.target_id]
	end

	if target and target.health.dead then
		local burst = E:create_entity("aura_sc_avenger_curse_burst")
		burst.pos = V.vclone(target.pos)
		burst.aura.source_id = this.modifier.source_id
		burst.aura.level = this.modifier.level
		queue_insert(store, burst)
	end
	queue_remove(store, this)
end

scripts.sc_avenger_curse_burst = {}

function scripts.sc_avenger_curse_burst.update(this, store)
	local damage = ({30, 55, 80})[this.aura.level]
	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, sc_radius(120), F_AREA, F_NIGHTMARE) or {}

	for _, target in pairs(targets) do
		sc_queue_damage(store, this.aura.source_id, target, damage, DAMAGE_MAGICAL)
	end
	queue_remove(store, this)
end

scripts.sc_forest_heal = {}

function scripts.sc_forest_heal.update(this, store)
	local level = this.aura.level
	local source = store.entities[this.aura.source_id]
	local start_ts = store.tick_ts
	local tick_ts = store.tick_ts - 0.5

	if source then
		this.pos = source.pos
	end

	while source and not source.health.dead and store.tick_ts - start_ts < 5 do
		this.pos = source.pos
		if store.tick_ts - tick_ts >= 0.5 then
			tick_ts = store.tick_ts
			local allies = U.find_soldiers_in_range(store.entities, this.pos, 0, sc_radius(300), F_FRIEND, 0) or {}

			for _, ally in pairs(allies) do
				if ally.health and not ally.health.dead then
					local amount = ({12, 24, 36})[level]
					ally.health.hp = km.clamp(0, ally.health.hp_max, ally.health.hp + amount)
					signal.emit("health-regen", ally, amount)
				end
			end
		end
		coroutine.yield()
		source = store.entities[this.aura.source_id]
	end

	queue_remove(store, this)
end

scripts.sc_forest_roots = {}

function scripts.sc_forest_roots.update(this, store)
	local source = store.entities[this.aura.source_id]

	if source then
		this.pos = source.pos
	end
	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, sc_radius(330), F_MOD, bor(F_FLYING, F_BOSS, F_NIGHTMARE)) or {}
	local count = math.min(#targets, ({7, 8})[this.aura.level])

	for i = 1, count do
		sc_apply_mod(store, "mod_sc_forest_roots", this.aura.source_id, targets[i].id, this.aura.level, ({4, 7})[this.aura.level])
	end
	queue_remove(store, this)
end

scripts.sc_slow_dps = {}

function scripts.sc_slow_dps.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead or not target.motion then
		return false
	end
	target.motion.max_speed = target.motion.max_speed * this.slow.factor
	this.modifier.ts = store.tick_ts
	this.dps.ts = store.tick_ts - this.dps.damage_every
	if this.render then
		this.render.sprites[1].ts = store.tick_ts
		this.render.sprites[1].z = target.render and target.render.sprites[1].z or Z_EFFECTS
	end
	return true
end

function scripts.sc_slow_dps.update(this, store)
	local target = store.entities[this.modifier.target_id]

	while target and not target.health.dead and store.tick_ts - this.modifier.ts < this.modifier.duration do
		this.pos = target.pos
		if store.tick_ts - this.dps.ts >= this.dps.damage_every then
			this.dps.ts = store.tick_ts
			sc_queue_damage(store, this.modifier.source_id, target, math.random(this.dps.damage_min, this.dps.damage_max), this.dps.damage_type)
		end
		coroutine.yield()
		target = store.entities[this.modifier.target_id]
	end
	queue_remove(store, this)
end

function scripts.sc_slow_dps.remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target and target.motion then
		target.motion.max_speed = target.motion.max_speed / this.slow.factor
	end
	return true
end

scripts.sc_nuclear_tower = {}

function scripts.sc_nuclear_tower.get_info(this)
		return {
			type = STATS_TYPE_TOWER,
			damage_min = 77,
			damage_max = 77,
			damage_type = DAMAGE_MAGICAL,
			range = this.attacks.range,
			cooldown = 4.3
		}
end

function scripts.sc_nuclear_tower.update(this, store)
	local attack_ts = store.tick_ts - 4.3
	local zone_power = this.powers.toxic_zone
	local zone_cooldown = 28
	local zone_ts = zone_power.level > 0 and store.tick_ts - zone_cooldown or store.tick_ts

	while true do
		for _, power in pairs(this.powers) do
			if power.changed then
				if power == zone_power and power.level > 0 then
					-- The original skill starts ready when it is bought.  Do not tie
					-- its first cast to the age of the tower.
					zone_ts = store.tick_ts - zone_cooldown
				end
				power.changed = nil
			end
		end

		if zone_power.level > 0 and not this.tower.blocked and store.tick_ts - zone_ts >= zone_cooldown then
			zone_ts = store.tick_ts
			S:queue("WasteDisposerSkill")
			U.animation_start(this, "discharge", nil, store.tick_ts, false, 2)
			U.y_wait(store, 0.6)

			local zone = E:create_entity("aura_sc_nuclear_zone")
			zone.aura.source_id = this.id
			zone.pos = V.vclone(this.pos)
			queue_insert(store, zone)

			-- This sequence is enqueued by the four dummy animation skills in
			-- the source data.  It is intentionally not cancelled by blocking.
			for _ = 1, 3 do
				U.y_animation_play(this, "loop", nil, store.tick_ts, 1, 2)
			end
			U.y_animation_play(this, "charge", nil, store.tick_ts, 1, 2)
			U.animation_start(this, "idle", nil, store.tick_ts, true, 2)
		elseif not this.tower.blocked and store.tick_ts - attack_ts >= 4.3 then
			local target = U.find_foremost_enemy(store.entities, this.pos, 0, this.attacks.range, 0, F_RANGED, bor(F_FLYING, F_NIGHTMARE))

			if target then
				attack_ts = store.tick_ts
				S:queue("WasteDisposerThrow")
				U.animation_start(this, "discharge", nil, store.tick_ts, false, 2)
				U.y_wait(store, 0.35)
				local bullet = sc_fire_bullet(store, "bullet_sc_nuclear", this, target, V.v(0, 48))
				-- Nuclear projectiles target the floor, not the unit's elevated
				-- hit point.  The impact, area damage and blob all share this point.
				bullet.bullet.to = V.vclone(target.pos)
				bullet.power_levels = {
					efficiency = this.powers.efficiency.level,
					super_blob = this.powers.super_blob.level
				}
				U.y_animation_wait(this, 2)
				U.animation_start(this, "idle", nil, store.tick_ts, true, 2)
			end
		end

		coroutine.yield()
	end
end

scripts.sc_nuclear_bomb = {}

function scripts.sc_nuclear_bomb.update(this, store)
	local b = this.bullet
	local start_ts = store.tick_ts
	local from = V.vclone(b.from)

	while store.tick_ts - start_ts < b.flight_time do
		local p = km.clamp(0, 1, (store.tick_ts - start_ts) / b.flight_time)
		this.pos.x = from.x + (b.to.x - from.x) * p
		this.pos.y = from.y + (b.to.y - from.y) * p + math.sin(p * math.pi) * 42
		coroutine.yield()
	end

	local impact = E:create_entity("fx_sc_nuclear_impact")
	impact.pos = V.vclone(b.to)
	queue_insert(store, impact)
	S:queue("WasteDisposerFall")

	local targets = U.find_enemies_in_range(store.entities, b.to, 0, b.damage_radius, F_RANGED, bor(F_FLYING, F_NIGHTMARE)) or {}
	for _, target in pairs(targets) do
		sc_queue_damage(store, b.source_id, target, 77 * (b.damage_factor or 1), DAMAGE_MAGICAL)
		target.health.armor = math.max(0, (target.health.armor or 0) - 0.02)
	end

	local levels = this.power_levels or {efficiency = 0, super_blob = 0}
	local blob_name = levels.super_blob > 0 and "soldier_sc_nuclear_blob_big" or "soldier_sc_nuclear_blob"
	local blob = sc_spawn_reinforcement(store, blob_name, b.to, b.to)
	blob.soldier.tower_id = b.source_id
	blob.sc_efficiency_level = levels.efficiency
	blob.unit.death_animation = levels.efficiency > 0 and "skillDeath" or "death"
	if levels.super_blob > 0 then
		blob.sc_blob_level = levels.super_blob
		blob.health.hp_max = ({120, 156, 204})[levels.super_blob]
		blob.health.hp = blob.health.hp_max
		blob.melee.attacks[1].damage_min = ({8, 9, 10})[levels.super_blob]
		blob.melee.attacks[1].damage_max = ({15, 17, 18})[levels.super_blob]
	end

	local decay = E:create_entity("controller_sc_nuclear_decay")
	decay.source_id = b.source_id
	decay.target_id = blob.id
	decay.efficiency_level = levels.efficiency
	decay.pos = blob.pos
	queue_insert(store, decay)
	queue_remove(store, this)
end

scripts.sc_nuclear_decay = {}
scripts.sc_nuclear_blob = {}

function scripts.sc_nuclear_blob.update(this, store, script)
	this.health_bar.hidden = true
	U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)
	this.health_bar.hidden = nil
	return K45.kr4_soldier_barrack.update(this, store, script)
end

function scripts.sc_nuclear_decay.update(this, store)
	local tick_ts = store.tick_ts
	local target = store.entities[this.target_id]

	while target and not target.health.dead do
		this.pos = target.pos
		if store.tick_ts - tick_ts >= 1 then
			tick_ts = store.tick_ts
			sc_queue_damage(store, this.source_id, target, target.health.hp_max * 0.06, DAMAGE_TRUE)
		end
		coroutine.yield()
		target = store.entities[this.target_id]
	end

	if target and this.efficiency_level > 0 then
		local burst_pos = V.vclone(target.pos)

		-- The upgraded blob's source death modifier triggers one second into
		-- skillDeath rather than at the first frame of the death animation.
		U.y_wait(store, 1)
		local burst = E:create_entity("aura_sc_nuclear_death")
		burst.pos = burst_pos
		burst.aura.source_id = this.source_id
		burst.aura.level = this.efficiency_level
		queue_insert(store, burst)
	end
	queue_remove(store, this)
end

scripts.sc_nuclear_burst = {}

function scripts.sc_nuclear_burst.update(this, store)
	local level = this.aura.level

	U.animation_start(this, "spawn", nil, store.tick_ts, false, 1, true)

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, sc_radius(75), F_AREA, bor(F_FLYING, F_NIGHTMARE)) or {}

	for _, target in pairs(targets) do
		sc_queue_damage(store, this.aura.source_id, target, ({28, 42, 56})[level], DAMAGE_PHYSICAL)
	end

	local residue = E:create_entity("aura_sc_nuclear_residue")
	residue.pos = V.vclone(this.pos)
	residue.aura.source_id = this.aura.source_id
	residue.aura.level = level
	queue_insert(store, residue)
	U.y_animation_wait(this, 1)
	queue_remove(store, this)
end

scripts.sc_nuclear_residue = {}

function scripts.sc_nuclear_residue.update(this, store)
	local start_ts = store.tick_ts
	local tick_ts = store.tick_ts - 0.1

	U.animation_start(this, "run", nil, store.tick_ts, false, 1, true)

	while store.tick_ts - start_ts < 2 do
		if store.tick_ts - tick_ts >= 0.1 then
			tick_ts = store.tick_ts
			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, sc_radius(130), F_MOD, bor(F_FLYING, F_NIGHTMARE)) or {}

			for _, target in pairs(targets) do
				sc_refresh_or_apply_mod(store, "mod_sc_nuclear_residue", this.aura.source_id, target.id, this.aura.level, 4, true)
			end
		end
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.sc_nuclear_residue_mod = {}

function scripts.sc_nuclear_residue_mod.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end
	this.modifier.ts = store.tick_ts
	this.tick_ts = store.tick_ts - 0.1
	this.pos = target.pos
	this.render.sprites[1].ts = store.tick_ts
	return true
end

function scripts.sc_nuclear_residue_mod.update(this, store)
	local target = store.entities[this.modifier.target_id]

	while target and not target.health.dead and store.tick_ts - this.modifier.ts < this.modifier.duration do
		this.pos = target.pos
		if store.tick_ts - this.tick_ts >= 0.1 then
			this.tick_ts = this.tick_ts + 0.1
			local damage_per_tick = ({1.4, 2, 2.7})[this.modifier.level]
			sc_queue_damage(store, this.modifier.source_id, target, damage_per_tick * sc_source_damage_factor(store, this.modifier.source_id), DAMAGE_MAGICAL)
		end
		coroutine.yield()
		target = store.entities[this.modifier.target_id]
	end
	queue_remove(store, this)
end

scripts.sc_nuclear_zone = {}

function scripts.sc_nuclear_zone.update(this, store)
	local start_ts = store.tick_ts
	local tick_ts = store.tick_ts - 1.5

	for _, sprite in ipairs(this.render.sprites) do
		local offset = sprite.offset or V.v(0, 0)
		local x = this.pos.x + offset.x
		local y = this.pos.y + offset.y

		sprite.ts = store.tick_ts
		sprite.sc_nuclear_visible = P:valid_node_nearby(x, y, 0.5)
		sprite.hidden = not sprite.sc_nuclear_visible
		sprite.alpha = 0
	end

	while store.tick_ts - start_ts < 10 do
		local elapsed = store.tick_ts - start_ts
		local decal_alpha

		if elapsed < 0.2 then
			decal_alpha = 255 * elapsed / 0.2
		elseif elapsed < 6.7 then
			decal_alpha = 255
		elseif elapsed < 7 then
			decal_alpha = 255 * (7 - elapsed) / 0.3
		else
			decal_alpha = 0
		end

		for _, sprite in ipairs(this.render.sprites) do
			sprite.alpha = decal_alpha
			sprite.hidden = not sprite.sc_nuclear_visible or elapsed >= 7
		end

		if store.tick_ts - tick_ts >= 1.5 then
			tick_ts = store.tick_ts
			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, sc_radius(300), F_RANGED, bor(F_FLYING, F_NIGHTMARE)) or {}
			for _, target in pairs(targets) do
				sc_queue_damage(store, this.aura.source_id, target, 9 * sc_source_damage_factor(store, this.aura.source_id), DAMAGE_MAGICAL)
				target.health.armor = math.max(0, (target.health.armor or 0) - 0.01)
			end
		end
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.sc_drone_tower = {}

function scripts.sc_drone_tower.remove(this, store, script)
	for _, entity in pairs(store.entities) do
		if entity.modifier and entity.modifier.source_id == this.id and
			(entity.template_name == "mod_sc_drone_support" or
				entity.template_name == "mod_sc_drone_soldier_damage") then
			queue_remove(store, entity)
		end
	end

	return scripts.sc_branch_barrack.remove(this, store, script)
end

scripts.sc_drone_controller = {}

scripts.sc_drone = {}

function scripts.sc_drone.update(this, store)
	local attack = this.ranged.attacks[1]
	local sprite = this.render.sprites[1]
	local index = this.soldier.tower_soldier_idx or 1
	local target_offsets = {
		V.v(-18, 10),
		V.v(18, 10),
		V.v(0, -14)
	}
	local target_offset = target_offsets[index] or V.v(0, 0)
	local phase = (index - 1) * 2 * math.pi / 3
	local attack_ts = store.tick_ts - attack.cooldown
	local dest = V.vclone(this.pos)

	local function move_towards(point)
		dest.x, dest.y = point.x, point.y
		sprite.flip_x = dest.x < this.pos.x
		U.force_motion_step(this, store.tick_length, dest)
	end

	local function patrol(center)
		local angle = phase + store.tick_ts * 1.35
		move_towards(V.v(center.x + math.cos(angle) * 32, center.y + math.sin(angle) * 18))
	end

	U.animation_start(this, "walk", nil, store.tick_ts, true, 1)

	while true do
		local tower = this.soldier.tower_id and store.entities[this.soldier.tower_id]

		if this.health.dead or not tower then
			queue_remove(store, this)
			return
		end

		if this.nav_rally.new then
			this.nav_rally.new = false
		end

		if this.unit.is_stunned then
			U.animation_start(this, "idle", nil, store.tick_ts, true, 1)
			coroutine.yield()
		else
			local center = tower.pos
			local search_range = tower.barrack and tower.barrack.rally_range or attack.max_range
			local target = U.find_nearest_enemy(store.entities, center, 0, search_range, attack.vis_flags, attack.vis_bans)
			local target_pos = target and V.v(target.pos.x + target_offset.x, target.pos.y + target_offset.y)

			-- 调集范围决定无人机能发现多远的目标；攻击范围只决定无人机
			-- 巡航到离目标多近时才开始射击。
			if target and V.dist(this.pos.x, this.pos.y, target.pos.x, target.pos.y) > attack.max_range then
				move_towards(target_pos)
				coroutine.yield()

			elseif target and store.tick_ts - attack_ts >= attack.cooldown then
				local animation, flip = U.animation_name_facing_point(this, attack.animation, target.pos)
				local start_ts = store.tick_ts

				attack_ts = store.tick_ts
				S:queue(attack.sound)
				U.animation_start(this, animation, flip, store.tick_ts, false, 1)

				for _, shoot_time in ipairs(attack.shoot_times) do
					while store.tick_ts - start_ts < shoot_time do
						if not store.entities[target.id] or target.health.dead then
							break
						end
						move_towards(V.v(target.pos.x + target_offset.x, target.pos.y + target_offset.y))
						coroutine.yield()
					end

					if not store.entities[target.id] or target.health.dead then
						break
					end

					sc_fire_bullet(store, attack.bullet, this, target, V.v(0, 10))
				end

				while not U.animation_finished(this, 1) do
					if store.entities[target.id] and not target.health.dead then
						move_towards(V.v(target.pos.x + target_offset.x, target.pos.y + target_offset.y))
					else
						patrol(center)
					end
					coroutine.yield()
				end

				U.animation_start(this, "walk", nil, store.tick_ts, true, 1)
			elseif target then
				move_towards(target_pos)
				coroutine.yield()
			else
				patrol(center)
				coroutine.yield()
			end
		end
	end
end

function scripts.sc_drone_controller.update(this, store)
	local bomb_ts = store.tick_ts
	local big_ts = store.tick_ts
	this.big_id = nil
	this.big_spawn_pending = false
	local aura_level = 0
	local aura_mods = {}
	local soldier_aura_level = 0
	local soldier_aura_mods = {}

	local function clear_mods(mods)
		for _, mod in pairs(mods) do
			if store.entities[mod.id] then
				queue_remove(store, mod)
			end
		end
	end

	while true do
		local tower = sc_source_tower(store, this.source_id)
		if not tower then
			break
		end
		this.pos = tower.pos
		--tower.powers.support.price_inc = tower.powers.support.level >= 2 and 280 or 270

		local drone_level = tower.powers.drone_upgrade.level
		for index, soldier in pairs(tower.barrack.soldiers) do
			if soldier and soldier.ranged and soldier.render then
				local upgraded = index <= drone_level
				local attack = soldier.ranged.attacks[1]

				if soldier.sc_drone_upgraded ~= upgraded then
					soldier.sc_drone_upgraded = upgraded
					attack.bullet = upgraded and "bullet_sc_drone_upgraded" or "bullet_sc_drone"
					attack.cooldown = upgraded and 0.8 or 1
					soldier.render.sprites[1].prefix = upgraded and "dronehivedrone_skilla" or "dronehivedrone"
					if soldier.render.sprites[2] then
						soldier.render.sprites[2].name = upgraded and "asst_dronehive_drone_shadow_skillA" or "asst_dronehive_drone_shadow"
					end
					U.animation_start(soldier, "idle", nil, store.tick_ts, true)
				end
			end
		end

		if drone_level ~= soldier_aura_level then
			clear_mods(soldier_aura_mods)
			soldier_aura_mods = {}
			soldier_aura_level = drone_level
		end
		if drone_level > 0 then
			local in_range = {}
			local soldiers = U.find_soldiers_in_range(store.entities, tower.pos, 0, sc_radius(500), F_FRIEND, 0) or {}

			for _, soldier in pairs(soldiers) do
				if soldier.unit and soldier.id ~= tower.id and not soldier.health.dead then
					in_range[soldier.id] = true
					if not soldier_aura_mods[soldier.id] then
						local mod = E:create_entity("mod_sc_drone_soldier_damage")
						mod.modifier.source_id = tower.id
						mod.modifier.target_id = soldier.id
						mod.inflicted_damage_factor = ({1.2, 1.35, 1.5})[drone_level]
						queue_insert(store, mod)
						soldier_aura_mods[soldier.id] = mod
					end
				end
			end

			for id, mod in pairs(soldier_aura_mods) do
				if not in_range[id] then
					if store.entities[mod.id] then
						queue_remove(store, mod)
					end
					soldier_aura_mods[id] = nil
				end
			end
		end

		if not tower.tower.blocked and store.tick_ts - bomb_ts >= 12 then
			local target = U.find_foremost_enemy(store.entities, tower.pos, 0, sc_radius(3000), false, F_RANGED, bor(F_FLYING, F_NIGHTMARE))
			if target then
				bomb_ts = store.tick_ts
				S:queue("DroneHiveSkill")
				U.animation_start(tower, "specialDroneOpen", nil, store.tick_ts, false, 2)
				U.y_wait(store, 0.9)
				if target.health.dead then
					target = U.find_foremost_enemy(store.entities, tower.pos, 0, sc_radius(3000), false, F_RANGED, bor(F_FLYING, F_NIGHTMARE))
				end

				if target then
				local bullet = E:create_entity("bullet_sc_drone_orbital")
				bullet.pos = V.v(tower.pos.x + 29, tower.pos.y + 26)
				bullet.bullet.from = V.vclone(bullet.pos)
				bullet.bullet.to = V.vclone(target.pos)
				bullet.bullet.target_id = target.id
				bullet.bullet.source_id = tower.id
				queue_insert(store, bullet)
				end
				U.animation_start(tower, "specialDroneClose", nil, store.tick_ts, false, 2)
			end
		end

		local level = tower.powers.support.level
		if level ~= aura_level then
			clear_mods(aura_mods)
			aura_mods = {}
			aura_level = level
		end
		if level > 0 then
			local in_range = {}
			for _, other in pairs(store.entities) do
				if other.tower and not other.tower_holder and other.id ~= tower.id and not other.tower.destroy and V.dist(other.pos.x, other.pos.y, tower.pos.x, tower.pos.y) <= sc_radius(500) then
					in_range[other.id] = true
					if not aura_mods[other.id] then
						local mod = E:create_entity("mod_sc_drone_support")
						mod.modifier.source_id = tower.id
						mod.modifier.target_id = other.id
						mod.modifier.level = level
						mod.range_factor = ({1.05, 1.1, 1.15})[level]
						mod.damage_factor = ({1.16, 1.32, 1.48})[level]
						queue_insert(store, mod)
						aura_mods[other.id] = mod
					end
				end
			end
			for id, mod in pairs(aura_mods) do
				if not in_range[id] then
					if store.entities[mod.id] then
						queue_remove(store, mod)
					end
					aura_mods[id] = nil
				end
			end
		end

		local big_level = tower.powers.big_drone.level
		local big = this.big_id and store.entities[this.big_id]
		local rally_pos = tower.barrack and tower.barrack.rally_pos or tower.pos

		if big and big.nav_rally and rally_pos then
			local synced_pos = big.sc_drone_rally_pos

			if not synced_pos or synced_pos.x ~= rally_pos.x or synced_pos.y ~= rally_pos.y then
				big.nav_rally.pos = V.vclone(rally_pos)
				big.nav_rally.center = V.vclone(rally_pos)
				big.nav_rally.new = true
				big.sc_drone_rally_pos = V.vclone(rally_pos)
			end
		end

		if big_level > 0 and not big and not this.big_spawn_pending and store.tick_ts - big_ts >= ({16, 13})[big_level] then
			local target = U.find_foremost_enemy(store.entities, tower.pos, 0, sc_radius(280), false, F_RANGED, bor(F_FLYING, F_NIGHTMARE))

			if target then
				big_ts = store.tick_ts
				this.big_spawn_pending = true
				S:queue("DroneHiveBigEject")
				U.animation_start(tower, "skillBinSpawn", nil, store.tick_ts, false, 2)
				U.y_wait(store, 0.233)
				local bullet = E:create_entity("bullet_sc_big_drone_spawn")
				bullet.pos = V.v(tower.pos.x - 25, tower.pos.y + 13)
				bullet.bullet.from = V.vclone(bullet.pos)
				bullet.bullet.to = V.vclone(target.pos)
				bullet.bullet.source_id = tower.id
				bullet.level = big_level
				bullet.controller_id = this.id
				queue_insert(store, bullet)
			end
		end
		coroutine.yield()
	end

	clear_mods(aura_mods)
	clear_mods(soldier_aura_mods)
	queue_remove(store, this)
end

scripts.sc_drone_orbital = {}
scripts.sc_drone_orbital_projectile = {}
scripts.sc_big_drone_spawn = {}
scripts.sc_big_drone = {}
scripts.sc_one_shot_fx = {}

function scripts.sc_big_drone_spawn.update(this, store)
	local start_ts = store.tick_ts
	local flight_time = 0.6
	local from = V.vclone(this.bullet.from)
	local to = V.vclone(this.bullet.to)

	while store.tick_ts - start_ts < flight_time do
		local p = km.clamp(0, 1, (store.tick_ts - start_ts) / flight_time)
		this.pos.x = from.x + (to.x - from.x) * p
		this.pos.y = from.y + (to.y - from.y) * p + math.sin(p * math.pi) * 55
		coroutine.yield()
	end

	local tower = store.entities[this.bullet.source_id]
	local rally_pos = tower and tower.barrack and tower.barrack.rally_pos or to
	local big = sc_spawn_reinforcement(store, "soldier_sc_big_drone", to, rally_pos)
	S:queue("DroneHiveBigLand")
	big.soldier.tower_id = this.bullet.source_id
	big.sc_drone_rally_pos = V.vclone(rally_pos)
	big.health.hp_max = ({245, 340})[this.level]
	big.health.hp = big.health.hp_max
	local controller = store.entities[this.controller_id]
	if controller then
		controller.big_id = big.id
		controller.big_spawn_pending = false
	end
	queue_remove(store, this)
end

function scripts.sc_big_drone.update(this, store, script)
	this.health_bar.hidden = true
	U.y_animation_play(this, "shootDron", nil, store.tick_ts, 1)
	this.health_bar.hidden = nil
	this.idle_flip.last_animation = "walk"
	return K45.kr4_soldier_barrack.update(this, store, script)
end

function scripts.sc_one_shot_fx.update(this, store)
	for _, sprite in ipairs(this.render.sprites or {}) do
		if sprite.animated then
			sprite.ts = store.tick_ts
		end
	end

	U.y_wait(store, this.duration or 0.6)
	queue_remove(store, this)
end

function scripts.sc_drone_orbital_projectile.update(this, store)
	local bullet = this.bullet
	local start_ts = store.tick_ts
	local from = V.vclone(this.pos)
	local flight_time = math.max(0.35, V.dist(from.x, from.y, bullet.to.x, bullet.to.y) / 600)

	while store.tick_ts - start_ts < flight_time do
		local target = store.entities[bullet.target_id]

		if target and not target.health.dead then
			bullet.to = V.vclone(target.pos)
		end
		local progress = km.clamp(0, 1, (store.tick_ts - start_ts) / flight_time)
		this.pos.x = from.x + (bullet.to.x - from.x) * progress
		this.pos.y = from.y + (bullet.to.y - from.y) * progress
		coroutine.yield()
	end

	local burst = E:create_entity("aura_sc_drone_orbital")
	burst.pos = V.vclone(bullet.to)
	burst.aura.source_id = bullet.source_id
	burst.target_id = bullet.target_id
	queue_insert(store, burst)
	queue_remove(store, this)
end

function scripts.sc_drone_orbital.update(this, store)
	S:queue("DroneHiveExplosion")
	local source = sc_source_tower(store, this.aura.source_id)
	local damage = 96 * (source and source.tower.damage_factor or 1)
	local target = store.entities[this.target_id]

	if target and target.health and not target.health.dead then
		sc_queue_damage(store, this.aura.source_id, target, damage, DAMAGE_PHYSICAL)
	end
	queue_remove(store, this)
end

scripts.sc_thermal_tower = {}

function scripts.sc_thermal_tower.get_info(this)
	return {
		type = STATS_TYPE_TOWER,
		damage_min = 57,
		damage_max = 57,
		damage_type = DAMAGE_PHYSICAL,
		range = this.attacks.range,
		cooldown = 4
	}
end

function scripts.sc_thermal_tower.update(this, store)
	local attack_ts = store.tick_ts - 4
	local sumo_ts = store.tick_ts
	local mist_ts = store.tick_ts

	while true do
		for _, power in pairs(this.powers) do
			power.changed = nil
		end
		if not this.tower.blocked and store.tick_ts - attack_ts >= 4 then
			local target = U.find_foremost_enemy(store.entities, this.pos, 0, this.attacks.range, false, F_RANGED, F_NIGHTMARE)
			if target then
				attack_ts = store.tick_ts
				S:queue("ThermalblastSpaSkill")
				U.animation_start(this, "baseAttack", nil, store.tick_ts, false, 2)
				U.y_wait(store, 0.35)
				local positions = sc_path_positions(target, 3, 3)

				for _, pos in ipairs(positions) do
					local geyser = E:create_entity("aura_sc_thermal_geyser")
					geyser.pos = pos
					geyser.aura.source_id = this.id
					geyser.aura.level = this.powers.geysers.level
					queue_insert(store, geyser)
					U.y_wait(store, 0.2)
				end
			end
		end

		local sumo_level = this.powers.sumo.level
		if sumo_level > 0 and not this.tower.blocked and store.tick_ts - sumo_ts >= ({15, 13, 11})[sumo_level] then
			local target = U.find_foremost_enemy(store.entities, this.pos, 0, this.attacks.range, false, F_RANGED, bor(F_FLYING, F_NIGHTMARE))

			if target then
				sumo_ts = store.tick_ts
				S:queue("ThermalblastSpaGong")
				local sumo = sc_spawn_reinforcement(store, "soldier_sc_sumo", target.pos, target.pos)
				sumo.health.hp_max = ({160, 240, 320})[sumo_level]
				sumo.health.hp = sumo.health.hp_max
				sumo.melee.attacks[1].damage_min = ({69, 84, 102})[sumo_level]
				sumo.melee.attacks[1].damage_max = ({102, 126, 149})[sumo_level]
				sumo.reinforcement.duration = ({9, 11, 13})[sumo_level]
				local landing = E:create_entity("aura_sc_sumo_landing")
				landing.pos = V.vclone(target.pos)
				landing.aura.source_id = this.id
				queue_insert(store, landing)
			end
		end

		local mist_level = this.powers.mist.level
		if mist_level > 0 and not this.tower.blocked and store.tick_ts - mist_ts >= ({24, 21, 17})[mist_level] then
			local target = sc_find_crowded_enemy(store, this.pos, this.attacks.range, sc_radius(120), F_RANGED, bor(F_FLYING, F_NIGHTMARE))

			if target then
				mist_ts = store.tick_ts
				S:queue("ThermalblastSpaMist")
				for _, pos in ipairs(sc_path_positions(target, 8, 3)) do
					local mist = E:create_entity("aura_sc_thermal_mist")
					mist.pos = pos
					mist.aura.source_id = this.id
					mist.aura.level = mist_level
					queue_insert(store, mist)
				end
			end
		end
		coroutine.yield()
	end
end

scripts.sc_thermal_geyser = {}

function scripts.sc_thermal_geyser.update(this, store)
	-- This effect is created during combat.  Exoskeleton sprites inherit ts=0,
	-- so without an explicit restart a non-looping animation is already on its
	-- final frame (which contains only the falling droplets) when it is drawn.
	U.animation_start(this, "run", nil, store.tick_ts, false, nil, true)

	local level = this.aura.level
	local damage_factor = sc_source_damage_factor(store, this.aura.source_id)
	local enemies = U.find_enemies_in_range(store.entities, this.pos, 0, sc_radius(72), F_AREA, F_NIGHTMARE) or {}
	for _, enemy in pairs(enemies) do
		sc_queue_damage(store, this.aura.source_id, enemy, 57 * damage_factor, DAMAGE_PHYSICAL)
		if level > 0 then
			sc_apply_mod(store, "mod_sc_geyser_dot", this.aura.source_id, enemy.id, level, ({1.5, 3, 4.5})[level])
		end
	end
	local allies = U.find_soldiers_in_range(store.entities, this.pos, 0, sc_radius(72), F_FRIEND, 0) or {}
	for _, ally in pairs(allies) do
		if ally.health and not ally.health.dead then
			ally.health.hp = km.clamp(0, ally.health.hp_max, ally.health.hp + 30)
			signal.emit("health-regen", ally, 30)
		end
	end
	-- Exoskeleton/layer animations do not reliably update the normal sprite
	-- completion counter.  Keep the effect alive for the 52-frame decal instead.
	U.y_wait(store, fts(52))
	queue_remove(store, this)
end

scripts.sc_geyser_dot = {}

function scripts.sc_geyser_dot.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead then
		return false
	end
	this.modifier.ts = store.tick_ts
	this.tick_ts = store.tick_ts - 0.16
	this.damage = 3 * sc_source_damage_factor(store, this.modifier.source_id)
	this.pos = target.pos
	if this.render then
		this.render.sprites[1].ts = store.tick_ts
	end
	return true
end

function scripts.sc_geyser_dot.update(this, store)
	local target = store.entities[this.modifier.target_id]

	while target and not target.health.dead and store.tick_ts - this.modifier.ts < this.modifier.duration do
		this.pos = target.pos
		if store.tick_ts - this.tick_ts >= 0.16 then
			this.tick_ts = this.tick_ts + 0.16
			sc_queue_damage(store, this.modifier.source_id, target, this.damage, DAMAGE_PHYSICAL)
		end
		coroutine.yield()
		target = store.entities[this.modifier.target_id]
	end
	queue_remove(store, this)
end

scripts.sc_sumo_landing = {}
scripts.sc_sumo = {}

function scripts.sc_sumo.update(this, store, script)
	this.health_bar.hidden = true
	U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)
	this.health_bar.hidden = nil
	this.nav_rally.new = false
	return scripts.soldier_reinforcement.update(this, store, script)
end

function scripts.sc_sumo_landing.update(this, store)
	U.y_wait(store, 0.3)
	S:queue("ThermalblastSpaSumo")
	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, sc_radius(60), F_AREA, bor(F_FLYING, F_BOSS, F_NIGHTMARE)) or {}
	for _, target in pairs(targets) do
		sc_queue_damage(store, this.aura.source_id, target, 80, DAMAGE_PHYSICAL)
		sc_apply_mod(store, "mod_sc_sumo_stun", this.aura.source_id, target.id)
	end
	queue_remove(store, this)
end

scripts.sc_thermal_mist = {}

function scripts.sc_thermal_mist.update(this, store)
	local duration = ({5, 6, 8})[this.aura.level]
	local start_ts = store.tick_ts
	local tick_ts = store.tick_ts - 0.1

	while store.tick_ts - start_ts < duration do
		if store.tick_ts - tick_ts >= 0.1 then
			tick_ts = store.tick_ts
			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, sc_radius(95), F_MOD, bor(F_FLYING, F_BOSS, F_NIGHTMARE)) or {}

			for _, target in pairs(targets) do
				if target.sc_thermal_mist_apply_ts ~= store.tick_ts then
					target.sc_thermal_mist_apply_ts = store.tick_ts
					sc_refresh_or_apply_mod(store, "mod_sc_thermal_slow", this.aura.source_id, target.id, this.aura.level, 0.16)
					sc_refresh_or_apply_mod(store, "mod_sc_thermal_silence", this.aura.source_id, target.id, this.aura.level, 0.16)
				end
			end
		end
		coroutine.yield()
	end
	U.y_animation_play(this, "fadeout", nil, store.tick_ts, 1)
	queue_remove(store, this)
end

scripts.sc_silence = {}

function scripts.sc_silence.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.enemy or target.health.dead then
		return false
	end
	this.previous_can_do_magic = target.enemy.can_do_magic
	this.previous_can_accept_magic = target.enemy.can_accept_magic
	target.enemy.can_do_magic = false
	target.enemy.can_accept_magic = false
	this.modifier.ts = store.tick_ts
	if this.render then
		this.render.sprites[1].ts = store.tick_ts
	end
	return true
end

function scripts.sc_silence.remove(this, store)
	local target = store.entities[this.modifier.target_id]

	if target and target.enemy then
		target.enemy.can_do_magic = this.previous_can_do_magic
		target.enemy.can_accept_magic = this.previous_can_accept_magic
	end
	return true
end

-- Fuhai Temple -------------------------------------------------------------

scripts.sc_fuhai_silence = {}

function scripts.sc_fuhai_silence.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.vis or not U.flags_pass(target.vis, this.modifier) then
		return false
	end
	return scripts.sc_silence.insert(this, store)
end

scripts.sc_fuhai_temple = {}

function scripts.sc_fuhai_temple.get_info(this)
	return {
		type = STATS_TYPE_TOWER,
		damage_min = math.ceil(this.attacks.damage_min * this.tower.damage_factor),
		damage_max = math.ceil(this.attacks.damage_max * this.tower.damage_factor),
		damage_type = DAMAGE_TRUE,
		range = this.attacks.range,
		cooldown = this.attacks.cooldown
	}
end

function scripts.sc_fuhai_temple.insert(this, store, script)
	this.fuhai_monks = {}
	return scripts.tower_barrack.insert(this, store, script)
end

function scripts.sc_fuhai_temple.remove(this, store, script)
	for _, monk in pairs(this.fuhai_monks or {}) do
		if monk.is_stun and monk.target_stun then
			SU.stun_dec(monk.target_stun)
			monk.is_stun = false
			monk.target_stun = nil
		end
		monk.force_remove = true
		if store.entities[monk.id] then
			queue_remove(store, monk)
		end
	end
	this.fuhai_monks = nil
	return scripts.tower_barrack.remove(this, store, script)
end

function scripts.sc_fuhai_temple.update(this, store)
	local aura_ts = store.tick_ts
	local enemy_cooldowns = {}
	local idle_offsets = {
		v(-25, 32),
		v(25, 32),
		v(-36, 20),
		v(36, 20),
		v(0, 45)
	}

	local function spawn_monk(index)
		local monk = E:create_entity("decal_sc_fuhai_monk")
		local offset = idle_offsets[index]

		monk.owner = this
		monk.owner_sprite_id = 2 + index
		monk.idle_pos = V.vclone(offset)
		monk.pos = V.v(this.pos.x + offset.x, this.pos.y + offset.y)
		monk.attack = this.attacks
		monk.attack_ts = store.tick_ts - this.attacks.cooldown
		monk.render.sprites[1].hidden = true
		queue_insert(store, monk)
		table.insert(this.fuhai_monks, monk)
	end

	spawn_monk(1)
	spawn_monk(2)

	while true do
		local monk_count = 2 + this.powers.monks.level
		local arhat_count = this.powers.arhat.level
		while #this.fuhai_monks < monk_count do
			spawn_monk(#this.fuhai_monks + 1)
		end

		for i = 1, 5 do
			this.render.sprites[2 + i].hidden = i > monk_count
		end

		for name, power in pairs(this.powers) do
			if power.changed then
				power.changed = nil
				if name == "arhat" then
					power.price_inc = power.level >= 2 and 260 or 240
				end
			end
		end

		this.barrack.max_soldiers = arhat_count
		if not this.tower.blocked then
			for i = 1, arhat_count do
				local soldier = this.barrack.soldiers[i]
				if not soldier or soldier.health.dead and not store.entities[soldier.id] then
					soldier = E:create_entity(this.barrack.soldier_type)
					soldier.soldier.tower_id = this.id
					soldier.soldier.tower_soldier_idx = i
					soldier.pos = V.v(this.pos.x + this.barrack.respawn_offset.x, this.pos.y + this.barrack.respawn_offset.y)
					soldier.nav_rally.pos, soldier.nav_rally.center = U.rally_formation_position(i, this.barrack, arhat_count)
					soldier.nav_rally.new = true
					queue_insert(store, soldier)
					this.barrack.soldiers[i] = soldier
					signal.emit("tower-spawn", this, soldier)
				end
			end
		end

		if this.barrack.rally_new then
			this.barrack.rally_new = false
			signal.emit("rally-point-changed", this)
			for i, soldier in ipairs(this.barrack.soldiers) do
				if soldier and soldier.nav_rally then
					soldier.nav_rally.pos, soldier.nav_rally.center = U.rally_formation_position(i, this.barrack, math.max(1, arhat_count), this.barrack.rally_angle_offset)
					soldier.nav_rally.new = true
				end
			end
			S:queue(this.sound_events.change_rally_point)
		end

		local aura_level = this.powers.aura.level
		if aura_level > 0 and store.tick_ts - aura_ts >= 0.1 then
			aura_ts = store.tick_ts
			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, sc_radius(350), F_MOD, bor(F_FLYING, F_NIGHTMARE)) or {}
			for _, target in pairs(targets) do
				sc_refresh_or_apply_mod(store, "mod_sc_fuhai_aura_slow_" .. aura_level, this.id, target.id, aura_level, 0.3)
				sc_refresh_or_apply_mod(store, "mod_sc_fuhai_aura_damage_" .. aura_level, this.id, target.id, aura_level, 0.3)
			end
		end

		if not this.tower.blocked then
			local active_count = 0
			local selected_targets = {}

			for enemy_id, cooldown_ts in pairs(enemy_cooldowns) do
				if cooldown_ts <= store.tick_ts then
					enemy_cooldowns[enemy_id] = nil
				end
			end

			for _, monk in ipairs(this.fuhai_monks) do
				if monk.target_id then
					active_count = active_count + 1
					selected_targets[monk.target_id] = true
				end
			end

			for _, monk in ipairs(this.fuhai_monks) do
				if active_count >= this.attacks.max_targets then
					break
				end
				if not monk.target_id and store.tick_ts - monk.attack_ts >= this.attacks.cooldown then
					local target = U.find_foremost_enemy(store.entities, this.pos, 0, this.attacks.range, false,
						F_RANGED, bor(F_FLYING, F_NIGHTMARE), function(enemy)
							return not selected_targets[enemy.id] and not enemy_cooldowns[enemy.id]
						end)
					if target then
						monk.target_id = target.id
						monk.attack_ts = store.tick_ts
						enemy_cooldowns[target.id] = store.tick_ts + (this.attacks.enemy_cooldown or this.attacks.cooldown)
						selected_targets[target.id] = true
						active_count = active_count + 1
						U.animation_start(this, "out", nil, store.tick_ts, false, monk.owner_sprite_id)
					end
				end
			end
		end
		coroutine.yield()
	end
end

scripts.sc_fuhai_monk = {}

function scripts.sc_fuhai_monk.update(this, store)
	local punch_in = {"punchIn", "kickIn"}
	local punch_out = {"punchOut", "kickOut"}
	this.is_stun = false
	this.target_stun = nil

	local function release_stun()
		if this.is_stun and this.target_stun then
			SU.stun_dec(this.target_stun)
		end
		this.is_stun = false
		this.target_stun = nil
	end

	local function return_to_tower()
		local owner = this.owner
		if owner and store.entities[owner.id] and owner.render and this.owner_sprite_id then
			U.animation_start(owner, "in", nil, store.tick_ts, false, this.owner_sprite_id)
		end
		this.render.sprites[1].hidden = true
		if owner and this.idle_pos then
			this.pos.x = owner.pos.x + this.idle_pos.x
			this.pos.y = owner.pos.y + this.idle_pos.y
		end
		this.target_id = nil
	end

	while not this.force_remove do
		if this.target_id then
			local target = store.entities[this.target_id]
			local owner = this.owner

			if not target or not target.health or target.health.dead or not owner or not store.entities[owner.id] then
				release_stun()
				return_to_tower()
			else
				if target.vis and target.enemy and band(target.vis.bans, F_STUN) == 0 and
					band(target.vis.flags, bor(F_BOSS, F_MINIBOSS)) == 0 and
					(not target.enemy.blockers or #target.enemy.blockers == 0) then
					SU.stun_inc(target)
					this.is_stun = true
					this.target_stun = target
				end

				this.render.sprites[1].hidden = false
				local is_air = target.vis and band(target.vis.flags, F_FLYING) ~= 0
				local action = math.random(1, 2)
				local slot_flip

				if is_air then
					local hit_offset = target.unit and target.unit.hit_offset or V.v(0, 0)
					this.pos.x, this.pos.y = target.pos.x + hit_offset.x, target.pos.y
					this.tween.disabled = false
					this.tween.props[1].disabled = false
					this.tween.props[1].ts = store.tick_ts
					this.tween.props[1].keys[2][2].y = math.max(hit_offset.y - 20, 5)
					U.animation_start(this, "dragonPunchUp", nil, store.tick_ts)
				else
					local slot_pos
					slot_pos, slot_flip = U.melee_slot_position(this, target, 1)
					this.pos.x, this.pos.y = slot_pos.x, slot_pos.y
					U.animation_start(this, punch_in[action], slot_flip, store.tick_ts)
				end

				U.y_wait(store, this.attack_time)
				if store.entities[target.id] and not target.health.dead and store.entities[owner.id] then
					local extra = target.health.hp_max * 0.04
					if target.vis and band(target.vis.flags, bor(F_BOSS, F_MINIBOSS)) ~= 0 then
						extra = math.min(extra, 60)
					end
					sc_queue_damage(store, owner.id, target,
						(math.random(this.attack.damage_min, this.attack.damage_max) + extra) * owner.tower.damage_factor,
						DAMAGE_TRUE)
					sc_refresh_or_apply_mod(store, "mod_sc_fuhai_stun", owner.id, target.id, 0, fts(8))
					sc_refresh_or_apply_mod(store, "mod_sc_fuhai_silence", owner.id, target.id, 0, 2)
					local fx = E:create_entity("fx_sc_fuhai_hit")
					local hit_offset = target.unit and target.unit.hit_offset or V.v(0, 0)
					fx.pos = V.v(target.pos.x + hit_offset.x, target.pos.y + hit_offset.y)
					fx.render.sprites[1].ts = store.tick_ts
					queue_insert(store, fx)
					S:queue("FuhaiAttack")
				end

				if is_air then
					U.animation_start(this, "dragonPunchDown", nil, store.tick_ts)
					U.y_wait(store, fts(5))
					this.tween.disabled = true
					this.tween.props[1].disabled = true
					U.y_animation_play(this, "dragonPunchOut", nil, store.tick_ts)
				else
					U.y_animation_wait(this)
					U.y_animation_play(this, punch_out[action], slot_flip, store.tick_ts)
				end

				release_stun()
				return_to_tower()
			end
		end
		coroutine.yield()
	end

	release_stun()
	if store.entities[this.id] then
		queue_remove(store, this)
	end
end

scripts.sc_fuhai_arhat = {}

function scripts.sc_fuhai_arhat.update(this, store, script)
	this.health_bar.hidden = true
	U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)
	this.health_bar.hidden = nil
	return scripts.soldier_barrack.update(this, store, script)
end

-- Winter Witch -------------------------------------------------------------

scripts.sc_winter_tower = {}

function scripts.sc_winter_tower.get_info(this)
	local attack = this.attacks.list[1]
	return {
		type = STATS_TYPE_TOWER_MAGE,
		damage_min = math.ceil(attack.damage_min * this.tower.damage_factor),
		damage_max = math.ceil(attack.damage_max * this.tower.damage_factor),
		damage_type = DAMAGE_MAGICAL,
		range = this.attacks.range,
		cooldown = attack.cooldown
	}
end

local function sc_winter_start_cast(this, store, tower_animation)
	if this.tower.level == 4 then
		U.animation_start_group(this, tower_animation, nil, store.tick_ts, false, "winter_tower")
	end
	U.animation_start_group(this, "summon", nil, store.tick_ts, false, "winter_shooter")
end

local function sc_winter_end_cast(this, store)
	if this.tower.level == 4 then
		U.animation_start_group(this, "idle", nil, store.tick_ts, true, "winter_tower")
	end
	U.animation_start_group(this, "idle", nil, store.tick_ts, true, "winter_shooter")
end

local function sc_winter_face_target(this, target)
	local flip_x = target.pos.x < this.pos.x + this.shooter_offset.x
	for _, sprite in pairs(this.render.sprites) do
		if sprite.group == "winter_shooter" then
			sprite.flip_x = flip_x
		end
	end
	return flip_x
end

local function sc_winter_bullet_start(this, attack, flip_x)
	return V.v(
		this.shooter_offset.x + (flip_x and -attack.shoot_offset.x or attack.shoot_offset.x),
		this.shooter_offset.y + attack.shoot_offset.y)
end

function scripts.sc_winter_tower.update(this, store)
	local attack = this.attacks.list[1]
	local attack_ts = store.tick_ts - attack.cooldown
	local attack_count = 0
	local ground_ts = store.tick_ts
	local shield_ts = store.tick_ts
	local tornado_ts = store.tick_ts

	while true do
		if this.powers then
			for name, power in pairs(this.powers) do
				if power.changed then
					power.changed = nil
					if name == "ground" then
						ground_ts = store.tick_ts
						power.price_inc = 210
					elseif name == "shield" then
						shield_ts = store.tick_ts
					elseif name == "tornado" then
						tornado_ts = store.tick_ts
						power.price_inc = 250
					end
				end
			end
		end

		local cast = false
		if this.powers and not this.tower.blocked then
			local ground_level = this.powers.ground.level
			if ground_level > 0 and store.tick_ts - ground_ts >= 9.9 then
				local target = sc_find_crowded_enemy(store, this.pos, sc_radius(333), sc_radius(100), F_RANGED, bor(F_FLYING, F_NIGHTMARE))
				if target then
					ground_ts = store.tick_ts
					cast = true
					sc_winter_start_cast(this, store, "affliction")
					S:queue("WinterGround")
					U.y_wait(store, 0.4)
					for _, pos in ipairs(sc_path_positions(target, 2 + ground_level, 3)) do
						local ground = E:create_entity("aura_sc_winter_ground")
						ground.pos = pos
						ground.aura.source_id = this.id
						ground.aura.level = ground_level
						queue_insert(store, ground)
					end
					sc_winter_end_cast(this, store)
				end
			end

			local shield_level = this.powers.shield.level
			if not cast and shield_level > 0 and store.tick_ts - shield_ts >= 14 then
				local allies = U.find_soldiers_in_range(store.entities, this.pos, 0, sc_radius(333), F_FRIEND, 0) or {}
				local candidates = {}
				for _, ally in pairs(allies) do
					if ally.health and not ally.health.dead and not ally.sc_winter_shield then
						candidates[#candidates + 1] = ally
					end
				end
				table.sort(candidates, function(a, b)
					return a.health.hp / a.health.hp_max < b.health.hp / b.health.hp_max
				end)
				if #candidates > 0 then
					shield_ts = store.tick_ts
					cast = true
					sc_winter_start_cast(this, store, "teleport")
					S:queue("WinterShield")
					U.y_wait(store, 0.4)
					for i = 1, math.min(3, #candidates) do
						sc_apply_mod(store, "mod_sc_winter_shield", this.id, candidates[i].id, shield_level, 7)
					end
					sc_winter_end_cast(this, store)
				end
			end

			local tornado_level = this.powers.tornado.level
			if not cast and tornado_level > 0 and store.tick_ts - tornado_ts >= 22.5 then
				local target = U.find_foremost_enemy(store.entities, this.pos, 0, sc_radius(333), false,
					bor(F_RANGED, F_TWISTER), bor(F_FLYING, F_CLIFF, F_BOSS, F_NIGHTMARE))
				if target and target.nav_path then
					tornado_ts = store.tick_ts
					cast = true
					sc_winter_face_target(this, target)
					sc_winter_start_cast(this, store, "teleport")
					S:queue("WinterTornado")
					U.y_wait(store, 0.7)
					local tornado = E:create_entity("aura_sc_winter_tornado")
					tornado.aura.source_id = this.id
					tornado.aura.level = tornado_level
					tornado.nav_path.pi = target.nav_path.pi
					tornado.nav_path.spi = target.nav_path.spi
					tornado.nav_path.ni = target.nav_path.ni + P:predict_enemy_node_advance(target, true)
					tornado.pos = P:node_pos(tornado.nav_path.pi, tornado.nav_path.spi, tornado.nav_path.ni)
					queue_insert(store, tornado)
					sc_winter_end_cast(this, store)
				end
			end
		end

		if not cast and not this.tower.blocked and store.tick_ts - attack_ts >= attack.cooldown then
			local area = (attack_count + 1) % 3 == 0
			local target
			if area then
				target = sc_find_crowded_enemy(store, tpos(this), this.attacks.range, sc_radius(110), attack.vis_flags, attack.vis_bans)
			else
				target = U.find_nearest_enemy(store.entities, tpos(this), 0, this.attacks.range, attack.vis_flags, attack.vis_bans)
			end
			if target then
				attack_ts = store.tick_ts
				attack_count = attack_count + 1
				local flip_x = sc_winter_face_target(this, target)
				U.animation_start_group(this, "shoot", nil, store.tick_ts, false, "winter_shooter")
				U.y_wait(store, attack.shoot_time)
				if store.entities[target.id] and not target.health.dead then
					local bullet = sc_fire_bullet(store, area and attack.area_bullet or attack.bullet, this, target,
						sc_winter_bullet_start(this, attack, flip_x))
					if area then
						bullet.bullet.to = V.vclone(target.pos)
					end
					bullet.damage_min = attack.damage_min
					bullet.damage_max = attack.damage_max
					bullet.level_index = this.winter_index
					bullet.area = area
					bullet.damage_factor = this.tower.damage_factor
				end
				U.animation_start_group(this, "idle", nil, store.tick_ts, true, "winter_shooter")
			end
		end
		coroutine.yield()
	end
end

scripts.sc_winter_bullet = {}

function scripts.sc_winter_bullet.update(this, store)
	local target = store.entities[this.bullet.target_id]
	local dest = V.vclone(this.bullet.to)
	local start_ts = store.tick_ts
	local arrived = false

	U.animation_start(this, "travel", nil, store.tick_ts, true)
	while not arrived and store.tick_ts - start_ts < 3 do
		if not this.area and (not target or not target.health or target.health.dead) and this.retarget_range > 0 then
			target = U.find_nearest_enemy(store.entities, this.pos, 0, this.retarget_range, F_RANGED, F_NIGHTMARE)
			if target then
				this.bullet.target_id = target.id
			end
		end
		if not this.area and target and target.health and not target.health.dead and target.pos then
			local hit_offset = target.unit and target.unit.hit_offset or V.v(0, 0)
			dest.x, dest.y = target.pos.x + hit_offset.x, target.pos.y + hit_offset.y
		end
		local dx, dy = dest.x - this.pos.x, dest.y - this.pos.y
		local distance = math.sqrt(dx * dx + dy * dy)
		local step = this.speed * store.tick_length
		if distance <= step or distance == 0 then
			this.pos.x, this.pos.y = dest.x, dest.y
			arrived = true
		else
			this.pos.x = this.pos.x + dx / distance * step
			this.pos.y = this.pos.y + dy / distance * step
			this.render.sprites[1].r = V.angleTo(dx, dy)
			coroutine.yield()
			target = store.entities[this.bullet.target_id]
		end
	end

	local targets = {}
	if this.area then
		targets = U.find_enemies_in_range(store.entities, this.pos, 0, sc_radius(100), F_AREA, F_NIGHTMARE) or {}
	else
		target = store.entities[this.bullet.target_id]
		if target and target.health and not target.health.dead then
			targets[1] = target
		end
	end

	for _, enemy in pairs(targets) do
		sc_queue_damage(store, this.bullet.source_id, enemy, math.random(this.damage_min, this.damage_max) * (this.damage_factor or 1), DAMAGE_MAGICAL)
		local is_boss = enemy.vis and band(enemy.vis.flags, bor(F_BOSS, F_MINIBOSS)) ~= 0
		local slow_name = "mod_sc_winter_slow_" .. this.level_index
		if is_boss then
			slow_name = "mod_sc_winter_slow_boss_" .. this.level_index
		end
		sc_refresh_or_apply_mod(store, slow_name, this.bullet.source_id, enemy.id, this.level_index, 3)
		if math.random() <= ({0.12, 0.2, 0.28})[this.level_index] then
			sc_refresh_or_apply_mod(store, "mod_sc_winter_freeze", this.bullet.source_id, enemy.id, this.level_index, 2)
		end
	end

	this.render.sprites[1].r = 0
	U.animation_start(this, "hit", nil, store.tick_ts, false)
	if this.area then
		local fx = E:create_entity("fx_sc_winter_area_hit")
		fx.pos = V.v(this.pos.x, this.pos.y + 3)
		queue_insert(store, fx)
	end
	while not U.animation_finished(this) do
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.sc_winter_ground = {}

function scripts.sc_winter_ground.update(this, store)
	local duration = ({2, 3, 4})[this.aura.level]
	local start_ts = store.tick_ts
	local cycle_ts = store.tick_ts - 0.25

	while store.tick_ts - start_ts < duration do
		if store.tick_ts - cycle_ts >= 0.2 then
			cycle_ts = store.tick_ts
			local targets = U.find_enemies_in_range(store.entities, this.pos, 0, sc_radius(89), F_MOD, bor(F_FLYING, F_NIGHTMARE)) or {}
			for _, target in pairs(targets) do
				sc_refresh_or_apply_mod(store, "mod_sc_winter_ground_slow", this.aura.source_id, target.id, this.aura.level, 0.3)
			end
		end
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.sc_winter_shield = {}

function scripts.sc_winter_shield.on_damage(this, store, damage)
	local mod = this.__sc_winter_shield_mod
	local previous_on_damage = this.__sc_winter_shield_on_damage

	if mod and mod.shield_hp and mod.shield_hp > 0 then
		local absorbed = math.min(damage.value or 0, mod.shield_hp)
		mod.shield_hp = mod.shield_hp - absorbed
		damage.value = math.max(0, (damage.value or 0) - absorbed)
		if mod.shield_hp <= 0 then
			mod.broken = true
		end
	end

	if previous_on_damage then
		return previous_on_damage(this, store, damage)
	end
	return true
end

function scripts.sc_winter_shield.insert(this, store)
	local target = store.entities[this.modifier.target_id]
	if not target or not target.health or target.health.dead or target.sc_winter_shield then
		return false
	end

	local previous_on_damage = target.health.on_damage
	if previous_on_damage == scripts.sc_winter_shield.on_damage then
		previous_on_damage = target.__sc_winter_shield_on_damage
	end

	this.shield_hp = 210
	this.modifier.ts = store.tick_ts
	target.sc_winter_shield = this
	target.__sc_winter_shield_mod = this
	target.__sc_winter_shield_on_damage = previous_on_damage
	target.health.on_damage = scripts.sc_winter_shield.on_damage
	local hp_before = target.health.hp
	target.health.hp = math.min(target.health.hp_max, target.health.hp + target.health.hp_max * 0.1)
	this.pos = target.pos
	for _, sprite in pairs(this.render.sprites) do
		sprite.ts = store.tick_ts
	end
	signal.emit("health-regen", target, target.health.hp - hp_before)
	return true
end

function scripts.sc_winter_shield.update(this, store)
	local target = store.entities[this.modifier.target_id]
	U.animation_start_group(this, "in", nil, store.tick_ts, false, "winter_shield")
	U.y_wait(store, fts(24))
	U.animation_start_group(this, "loop", nil, store.tick_ts, true, "winter_shield")

	while target and target.health and not target.health.dead and not this.broken and store.tick_ts - this.modifier.ts < this.modifier.duration do
		this.pos = target.pos
		coroutine.yield()
		target = store.entities[this.modifier.target_id]
	end
	U.animation_start_group(this, "out", nil, store.tick_ts, false, "winter_shield")
	U.y_wait(store, fts(18))
	queue_remove(store, this)
end

function scripts.sc_winter_shield.remove(this, store)
	if this.shield_removed then
		return true
	end
	this.shield_removed = true
	local target = store.entities[this.modifier.target_id]
	if target and target.health and target.__sc_winter_shield_mod == this then
		target.health.on_damage = target.__sc_winter_shield_on_damage
		target.__sc_winter_shield_mod = nil
		target.__sc_winter_shield_on_damage = nil
		if target.sc_winter_shield == this then
			target.sc_winter_shield = nil
		end
	end
	return true
end

scripts.sc_winter_tornado = {}

function scripts.sc_winter_tornado.update(this, store)
	local level = this.aura.level
	local duration = ({5, 6.25, 7.5})[level]
	local damage_per_tick = ({2, 4, 6})[level]
	local enemies_max = this.enemies_max + level * this.enemies_inc
	local np = this.nav_path
	local picked_enemies = {}

	this.picked_enemies = picked_enemies

	U.animation_start(this, "start", nil, store.tick_ts, false)
	while not U.animation_finished(this) do
		coroutine.yield()
	end

	S:queue("ArchmageTwisterTravel")
	U.animation_start(this, "travel", nil, store.tick_ts, true)
	np.ni = km.clamp(P:get_start_node(np.pi), P:get_end_node(np.pi), np.ni)
	local start_ts = store.tick_ts
	local damage_ts = start_ts
	local last_node = P:get_start_node(np.pi) + this.nodes_limit
	local terrains = band(P:path_terrain_types(np.pi), bnot(TERRAIN_CLIFF))

	local function pick_up_enemies()
		if #picked_enemies >= enemies_max then
			return
		end

		local _, enemies = U.find_foremost_enemy(store.entities, this.pos, 0, this.pickup_range, false,
			this.aura.vis_flags, this.aura.vis_bans, function(enemy)
			return enemy.enemy and enemy.enemy.counts and enemy.enemy.valid_terrains and enemy.nav_path and
				(not enemy.enemy.counts.twister or enemy.enemy.counts.twister < this.max_times_applied) and
				band(bnot(enemy.enemy.valid_terrains), terrains) == 0
		end)

		if not enemies then
			return
		end

		for _, enemy in ipairs(enemies) do
			if #picked_enemies >= enemies_max then
				break
			end

			table.insert(picked_enemies, {enemy = enemy, damage_ticks = 0})
			SU.remove_modifiers(store, enemy)
			SU.remove_auras(store, enemy)
			queue_remove(store, enemy)
			enemy.health.dead = true
			enemy.health.last_damage_types = DAMAGE_EAT
			enemy.main_script.co = nil
			enemy.main_script.runs = 0
			U.unblock_all(store, enemy)
			if enemy.ui then
				enemy.ui.can_click = false
			end
			if enemy.count_group then
				enemy.count_group.in_limbo = true
			end
		end
	end

	local function add_winter_damage()
		local elapsed = store.tick_ts - damage_ts
		if elapsed < 0.25 then
			return
		end

		local ticks = math.floor(elapsed / 0.25)
		damage_ts = damage_ts + ticks * 0.25
		for _, picked in ipairs(picked_enemies) do
			picked.damage_ticks = picked.damage_ticks + ticks
		end
	end

	while store.tick_ts - start_ts < duration and last_node < np.ni and
		band(GR:cell_type(this.pos.x, this.pos.y), TERRAIN_CLIFF) == 0 do
		local next_ni = np.ni - 5
		local next_pos = P:node_pos(np.pi, np.spi, next_ni)
		if next_pos and P:is_node_valid(np.pi, next_ni, NF_TWISTER) and
			band(GR:cell_type(next_pos.x, next_pos.y), TERRAIN_CLIFF) == 0 then
			np.ni = next_ni
		end
		np.spi = np.spi == 2 and 3 or 2
		U.set_destination(this, P:node_pos(np.pi, np.spi, np.ni))

		while not this.motion.arrived and store.tick_ts - start_ts < duration do
			U.walk(this, store.tick_length)
			pick_up_enemies()
			add_winter_damage()
			coroutine.yield()
		end
	end

	add_winter_damage()
	for _, picked in ipairs(picked_enemies) do
		local enemy = picked.enemy
		enemy.enemy.counts.twister = (enemy.enemy.counts.twister or 0) + 1
		enemy.nav_path.pi = np.pi
		enemy.nav_path.ni = km.clamp(1, #P:path(np.pi) - 1, math.random(-3, 3) + np.ni)
		enemy.pos = P:node_pos(enemy.nav_path.pi, enemy.nav_path.spi, enemy.nav_path.ni)
		enemy.main_script.runs = 1
		enemy.health.dead = false
		enemy.motion.forced_waypoint = nil
		if enemy.ui then
			enemy.ui.can_click = true
		end
		queue_insert(store, enemy)
	end

	coroutine.yield()
	local damage_value = damage_per_tick * sc_source_damage_factor(store, this.aura.source_id)
	for _, picked in ipairs(picked_enemies) do
		local enemy = picked.enemy
		if store.entities[enemy.id] and not enemy.health.dead then
			for _ = 1, picked.damage_ticks do
				sc_queue_damage(store, this.aura.source_id, enemy, damage_value, DAMAGE_MAGICAL)
			end
		end
	end
	this.picked_enemies = {}

	S:stop("ArchmageTwisterTravel")
	U.animation_start(this, "end", nil, store.tick_ts, false)
	while not U.animation_finished(this) do
		coroutine.yield()
	end
	queue_remove(store, this)
end

-- BEGIN DOVE43 BUILTIN TOWERS
scripts.dove43_config = {["sniper_tower"]={["kill_chance_inc"]=0.01,["kill_chance_max"]=1,["kill_boss_factor"]=8,["kill_hp_max_factor"]=0.5,["practice_cooldown"]={18,16.5,14},["practice_targets"]={2,3,3},["practice_rounds"]={2,2,3},["practice_damage_mul"]={1.8,2.1,2.4},["weak_duration"]={4,4,4},["weak_slow"]={0.9,0.8,0.7},["weak_poison_damage"]={24,32,40},["weak_max_stacks"]=4,["attack_cooldown"]=1.3,["attack_range"]=360,["attack_follow_time"]=1.8,["attack_damage_min"]=42,["attack_damage_max"]=78,["kill_chance"]=0.05},["plague_hospital"]={["attack_range"]=180,["miasma_damage"]=9.1,["miasma_tick"]=1,["miasma_duration"]=1.2,["corpse_delay"]=1,["zombie_cap"]={4,6,8},["zombie_hp"]={90,90,115},["zombie_damage_min"]={4,4,6},["zombie_damage_max"]={8,8,12},["zombie_speed"]=40,["zombie_melee_range"]=60,["zombie_hit_time"]=0.53,["zombie_revive_time"]=12,["mike_cooldown"]={30,25},["mike_hp"]={300,400},["mike_damage_min"]={18,22},["mike_damage_max"]={28,34},["mike_speed"]=65,["mike_melee_range"]=90,["mike_hit_time"]=0.5,["mike_armor"]=0.2,["bio_cooldown"]={18,15},["bio_duration"]={10,10},["bio_damage_mult"]={1.2,1.4},["bio_hp_mult"]={1.3,1.6},["bio_scale_mult"]=1.15},["command_center"]={["flashbang_damage_max"]=84,["flashbang_damage_radius"]=65,["flashbang_cooldown"]=4,["flashbang_stun_duration"]=2,["aura_damage_factor"]=1.2,["radar_cooldown"]=20,["intranet_cooldown"]={40,36},["airstrike_cooldown"]={24,22,20},["airstrike_missiles"]={6,7,8},["airstrike_damage_min"]={26,36,46},["airstrike_damage_max"]={57,78,99},["airstrike_damage_radius"]=50,["attack_range"]=250,["flashbang_damage_min"]=49},["ice_cooler"]={["range"]=160,["cooldown"]=6.6,["damage_min"]=56,["damage_max"]=80,["breath_width"]=35,["freeze_duration"]=1.3,["party_cooldown"]=25,["party_damage_min"]=8,["party_damage_max"]=12,["party_count"]=20,["party_radius"]=45,["flavors_chance"]={0.24,0.32,0.4},["flavors_hp"]={0.9,0.8,0.7},["flavors_duration"]=2.3,["fans_cooldown"]={18,14},["fans_hp"]={180,180},["fans_duration"]={10,10},["fans_count"]=3,["fans_damage_min"]=15,["fans_damage_max"]=22},["machine_gunner"]={["arrow_cooldown"]={10,9,8},["arrow_count"]={1,2,3},["arrow_damage_max"]={69,72,74},["arrow_damage_min"]={37,39,40},["arrow_direct_damage_max"]=26,["arrow_direct_damage_min"]=13,["arrow_radius"]=55,["arrow_range"]=195,["medal_attack_cooldown"]=0.2,["medal_attack_damage_max"]=22,["medal_attack_damage_min"]=10,["medal_storm_bullets"]=1,["medal_storm_damage_factor"]=2,["medal_storm_interval"]=0.1,["storm_bullets"]=2,["storm_cooldown"]=18,["storm_damage_factor"]=1.5,["storm_duration"]=3,["storm_interval"]=0.3,["attack_bullets"]=2,["attack_burst_interval"]=0.133,["attack_burst_weight"]={0.7,0.5,0.3},["attack_cooldown"]=0.8,["attack_damage_max"]=17,["attack_damage_min"]=8,["attack_range"]=175}}

-- Local adapters for Dove's spatial-index API. The native simulation remains unchanged.
local dove43_U = setmetatable({}, {__index = U})
local dove43_SU = setmetatable({}, {__index = SU})
local function dove43_entities() return simulation.store.entities end
function dove43_U.tower_ready_to_use_power(power, attack, store, tower)
	return power and power.level > 0 and not attack.disabled and
		(tower.can_do_magic or attack.requires_magic == false) and
		store.tick_ts - (attack.ts or 0) > (attack.cooldown or math.huge) * (tower.cooldown_factor or 1)
end
dove43_U.y_wait_unconditional = U.y_wait
dove43_U.y_wait_conditional = U.y_wait
dove43_U.animation_start_default = U.animation_start
function dove43_U.calculate_enemy_ffe_pos(enemy, prediction)
	if prediction and enemy.motion and enemy.motion.speed then
		if enemy.motion.forced_waypoint then
			local dt = prediction == true and 1 or prediction
			return v(enemy.pos.x + enemy.motion.speed.x * dt, enemy.pos.y + enemy.motion.speed.y * dt)
		end
		return P:node_pos(enemy.nav_path.pi, enemy.nav_path.spi,
			enemy.nav_path.ni + P:predict_enemy_node_advance(enemy, prediction))
	end
	return V.vclone(enemy.pos)
end
function dove43_U.find_foremost_enemy_in_range_filter_off(pos, range, prediction, flags, bans, filter)
	return U.find_foremost_enemy(dove43_entities(), pos, 0, range, prediction, flags, bans, filter)
end
dove43_U.find_foremost_enemy_in_range_filter_on = dove43_U.find_foremost_enemy_in_range_filter_off
function dove43_U.find_enemies_in_range_filter_off(pos, range, flags, bans)
	return U.find_enemies_in_range(dove43_entities(), pos, 0, range, flags or 0, bans or 0)
end
function dove43_U.find_enemies_in_range_filter_override(pos, range, filter)
	local result = {}
	for _, enemy in pairs(dove43_entities()) do
		if enemy.enemy and enemy.pos and enemy.health and U.is_inside_ellipse(enemy.pos, pos, range) and filter(enemy) then
			result[#result + 1] = enemy
		end
	end
	return #result > 0 and result or nil
end
function dove43_U.detect_foremost_enemy_with_flying_preference_in_range_filter_off(pos, range, flags, bans)
	local enemy = U.find_foremost_enemy(dove43_entities(), pos, 0, range, false, flags, bans,
		function(e) return band(e.vis.flags, F_FLYING) ~= 0 end)
	return enemy or U.find_foremost_enemy(dove43_entities(), pos, 0, range, false, flags, bans)
end
function dove43_U.find_enemies_around_line(x1, y1, x2, y2, width, flags, bans)
	local dx, dy = x2 - x1, y2 - y1
	local length = math.sqrt(dx * dx + dy * dy)
	local result = {}
	if length == 0 then return result end
	local ux, uy = dx / length, dy / length
	for _, e in pairs(dove43_entities()) do
		if e.enemy and e.health and not e.health.dead and not e.pending_removal and e.vis and
			band(e.vis.flags, bans or 0) == 0 and band(e.vis.bans, flags or 0) == 0 then
			local offset = e.unit.hit_offset or v(0, 0)
			local ex, ey = e.pos.x + offset.x - x1, e.pos.y + offset.y - y1
			local along, across = ex * ux + ey * uy, ex * uy - ey * ux
			if along >= -width and along <= length + width and math.abs(across) <= width then
				result[#result + 1] = e
			end
		end
	end
	return result
end
function dove43_U.bans_add(vis, flags) vis.bans = bor(vis.bans or 0, flags) end
function dove43_U.bans_remove(vis, flags) vis.bans = band(vis.bans or 0, bnot(flags)) end
function dove43_U.heal(entity, amount)
	entity.health.hp = math.min(entity.health.hp_max, entity.health.hp + amount)
end
function dove43_U.get_nearest_valid_rally_pos(pos)
	local nodes = P:nearest_nodes(pos.x, pos.y, nil, {1, 2, 3}, NF_RALLY)
	if nodes and nodes[1] then return P:node_pos(unpack(nodes[1], 1, 3)) end
end
function dove43_U.get_path_fx_points(tower, spacing)
	local points = {}
	for pi, path in pairs(P.paths or {}) do
		for ni, pos in ipairs(path[1] or {}) do
			if ni % 4 == 0 and P:is_node_valid(pi, ni) and U.is_inside_ellipse(pos, tower.pos, tower.attacks.range - 30) then
				local clear = true
				for _, other in ipairs(points) do
					if V.dist2(pos.x, pos.y, other.pos.x, other.pos.y) < spacing * spacing then clear = false; break end
				end
				if clear then points[#points + 1] = {pos = V.vclone(pos)} end
			end
		end
	end
	return points
end
function dove43_SU.soldier_inherit_tower_buff_factor(soldier, tower)
	soldier.unit.damage_factor = soldier.unit.damage_factor * tower.tower.damage_factor
end
local function scale_tower_range_dove43(target, factor)
	if not target or not target.attacks then return end
	target.attacks.range = target.attacks.range * factor
	for _, attack in pairs(target.attacks.list or {}) do
		if type(attack.range) == "number" then attack.range = attack.range * factor end
		if type(attack.max_range) == "number" then attack.max_range = attack.max_range * factor end
	end
end
function dove43_SU.insert_tower_range_buff(target, factor) scale_tower_range_dove43(target, factor) end
function dove43_SU.remove_tower_range_buff(target, factor) scale_tower_range_dove43(target, 1 / factor) end
function dove43_SU.remove_tower_damage_factor_buff(target, increment)
	target.tower.damage_factor = target.tower.damage_factor / (1 + increment)
end
scripts.dove43_utils = dove43_U
-- Adapt only the new status effects to the native modifier lifecycle.
scripts.mod_dps_dove43 = {}
function scripts.mod_dps_dove43.insert(this, store)
	local m, dps = this.modifier, this.dps
	if m.max_duplicates then
		local count = 0
		for _, other in pairs(store.entities) do
			if other.id ~= this.id and not other.pending_removal and other.template_name == this.template_name and
				other.modifier.target_id == m.target_id and other.modifier.level == m.level then count = count + 1 end
		end
		if count >= m.max_duplicates then return false end
	end
	local factor = m.damage_factor or 1
	for _, key in ipairs({"damage_min", "damage_max", "damage_inc", "damage_first", "damage_last"}) do
		if type(dps[key]) == "number" then dps[key] = dps[key] * factor end
	end
	return scripts.mod_dps.insert(this, store)
end
scripts.mod_slow_dove43 = {}
function scripts.mod_slow_dove43.insert(this, store)
	this.slow.factor = this.slow.factor + this.modifier.level * (this.slow.factor_inc or 0)
	return scripts.mod_slow.insert(this, store)
end

scripts.shotgun_dove43 = {insert = scripts.shotgun.insert}
function scripts.shotgun_dove43.update(this, store)
	local b = this.bullet
	local target = store.entities[b.target_id]
	local speed = b.min_speed
	local target_invalid = false
	local ps

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		simulation:queue_insert_entity(ps)
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) >= 2 * (speed * store.tick_length) do
		coroutine.yield()

		if not target_invalid then
			target = store.entities[b.target_id]
		end

		if target then
			local tpx, tpy = target.pos.x, target.pos.y

			if not b.ignore_hit_offset then
				tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y
			end
			local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))

			if d > b.max_track_distance or band(target.vis.bans, F_RANGED) ~= 0 then
				target_invalid = true
				target = nil
			end
		end

		b.speed.x, b.speed.y = V.mul(speed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.to.x - this.pos.x, b.to.y - this.pos.y)

		if b.hide_radius then
			this.render.sprites[1].hidden = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
		end
	end

	if target and target.health and not target.health.dead then
		local u = UP:get_upgrade("archer_precision")

		if u and math.random() < u.chance then
			b.damage_min = b.damage_min * u.damage_factor
			b.damage_max = b.damage_max * u.damage_factor
			b.pop = {"pop_crit"}
			b.pop_conds = DR_DAMAGE
		end

		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)
		if b.damage_radius and b.damage_radius > 0 then
			local nearby = U.find_enemies_in_range(store.entities, target.pos, 0, b.damage_radius, b.damage_flags, b.damage_bans)
			for _, enemy in ipairs(nearby or {}) do
				if enemy.id ~= target.id and not enemy.pending_removal then
					queue_damage(store, SU.create_bullet_damage(b, enemy.id, this.id))
				end
			end
		end

		local mods

		if b.mod then
			mods = {b.mod}
		elseif b.mods then
			mods = b.mods
		end

		if mods then
			for _, mod_name in ipairs(mods) do
				local mod = E:create_entity(mod_name)

				mod.modifier.source_id = b.source_id
				mod.modifier.target_id = target.id
				mod.modifier.level = b.level
				mod.modifier.source_damage = d
				mod.modifier.damage_factor = b.damage_factor

				simulation:queue_insert_entity(mod)
			end
		end

		if b.hit_blood_fx and target.unit.blood_color ~= BLOOD_NONE then
			local sfx = E:create_entity(b.hit_blood_fx)

			sfx.pos.x, sfx.pos.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
			sfx.render.sprites[1].ts = store.tick_ts

			if sfx.use_blood_color and target.unit.blood_color then
				sfx.render.sprites[1].r = this.render.sprites[1].r
				sfx.render.sprites[1].name = target.unit.blood_color
			end

			simulation:queue_insert_entity(sfx)
		end
	elseif b.miss_fx_water and GR:cell_is(b.to.x, b.to.y, TERRAIN_WATER) then
		local fx = E:create_entity(b.miss_fx_water)

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)
	elseif b.miss_fx then
		local fx = E:create_entity(b.miss_fx)

		fx.pos.x, fx.pos.y = b.to.x, b.to.y
		fx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(fx)
	end

	simulation:queue_remove_entity(this)
end


-- Native bomb trajectory with Dove on-hit modifier lists.
scripts.bomb_dove43 = {insert = scripts.bomb.insert}
function scripts.bomb_dove43.update(this, store, script)
	local b = this.bullet
	local dmin, dmax = b.damage_min, b.damage_max
	local dradius = b.damage_radius

	if b.level and b.level > 0 then
		if b.damage_radius_inc then
			dradius = dradius + b.level * b.damage_radius_inc
		end

		if b.damage_min_inc then
			dmin = dmin + b.level * b.damage_min_inc
		end

		if b.damage_max_inc then
			dmax = dmax + b.level * b.damage_max_inc
		end
	end

	local ps

	if b.particles_name then
		ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id

		queue_insert(store, ps)
	end

	while store.tick_ts - b.ts + store.tick_length < b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

		if b.align_with_trajectory then
			this.render.sprites[1].r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
		elseif b.rotation_speed then
			this.render.sprites[1].r = this.render.sprites[1].r + b.rotation_speed * store.tick_length
		end

		if b.hide_radius then
			this.render.sprites[1].hidden = V.dist(this.pos.x, this.pos.y, b.from.x, b.from.y) < b.hide_radius or V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) < b.hide_radius
		end
	end

	local enemies = table.filter(store.entities, function(k, v)
		return v.enemy and v.vis and v.health and not v.health.dead and band(v.vis.flags, b.damage_bans) == 0 and band(v.vis.bans, b.damage_flags) == 0 and U.is_inside_ellipse(v.pos, b.to, dradius)
	end)

	for _, enemy in pairs(enemies) do
		local d = E:create_damage()

		d.damage_type = b.damage_type
		d.reduce_armor = b.reduce_armor
		d.reduce_magic_armor = b.reduce_magic_armor

		--if this.up_alchemical_powder_chance and math.random() < this.up_alchemical_powder_chance or UP:get_upgrade("engineer_efficiency") then
		--	d.value = dmax
		--else
			local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, dradius)

			d.value = math.floor(dmax - (dmax - dmin) * dist_factor)
		--end

		d.value = math.ceil(b.damage_factor * d.value)
		d.source_id = this.id
		d.target_id = enemy.id

		queue_damage(store, d)
		log.paranoid("bomb id:%s, radius:%s, enemy id:%s, dist:%s, damage:%s damage_type:%x", this.id, dradius, enemy.id, V.dist(enemy.pos.x, enemy.pos.y, b.to.x, b.to.y), d.value, d.damage_type)

		if this.up_shock_and_awe_chance and band(enemy.vis.bans, F_STUN) == 0 and band(enemy.vis.flags, bor(F_BOSS, F_CLIFF, F_FLYING)) == 0 and math.random() < this.up_shock_and_awe_chance then
			local mod = E:create_entity("mod_shock_and_awe")

			mod.modifier.target_id = enemy.id

			queue_insert(store, mod)
		end

		for _, mod_name in ipairs(b.mod and {b.mod} or b.mods or {}) do
			local mod = E:create_entity(mod_name)
			mod.modifier.target_id = enemy.id
			mod.modifier.source_id = b.source_id or this.id
			mod.modifier.damage_factor = b.damage_factor
			queue_insert(store, mod)
		end
	end

	local p = SU.create_bullet_pop(store, this)

	queue_insert(store, p)

	local cell_type = GR:cell_type(b.to.x, b.to.y)

	if b.hit_fx_water and band(cell_type, TERRAIN_WATER) ~= 0 then
		S:queue(this.sound_events.hit_water)

		local water_fx = E:create_entity(b.hit_fx_water)

		water_fx.pos.x, water_fx.pos.y = b.to.x, b.to.y
		water_fx.render.sprites[1].ts = store.tick_ts
		water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

		queue_insert(store, water_fx)
	elseif b.hit_fx then
		S:queue(this.sound_events.hit)

		local sfx = E:create_entity(b.hit_fx)

		sfx.pos = V.vclone(b.to)
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset

		queue_insert(store, sfx)
	end

	if b.hit_decal and band(cell_type, TERRAIN_WATER) == 0 then
		local decal = E:create_entity(b.hit_decal)

		decal.pos = V.vclone(b.to)
		decal.render.sprites[1].ts = store.tick_ts

		queue_insert(store, decal)
	end

	if b.hit_payload then
		local hp

		if type(b.hit_payload) == "string" then
			hp = E:create_entity(b.hit_payload)
		else
			hp = b.hit_payload
		end

		hp.pos.x, hp.pos.y = b.to.x, b.to.y

		if hp.aura then
			hp.aura.level = this.bullet.level
		end

		queue_insert(store, hp)
	end

	queue_remove(store, this)
end


do -- sniper_tower
local U, SU = dove43_U, dove43_SU
local game_scripts = scripts
local cfg = scripts.dove43_config["sniper_tower"]


local v = V.v
local vclone = V.vclone

local band = bit.band
local bor = bit.bor

local SHOOT_TIME = 0.166
local KILL_AIM_TIME = 1
local SCALE_K = 1.265625 / 1.2
local SPOTTER_OFFSET = {-24 * SCALE_K, -4 * SCALE_K}
local SHOOTER_OFFSET_Y = 45 * SCALE_K
local SHOOTER_SID = 3
local function queue_insert(e)
	simulation:queue_insert_entity(e)
end
local function queue_remove(e)
	simulation:queue_remove_entity(e)
end

local function fts(frames)
	return frames / FPS
end
local function angle_between(from, to)
	return math.deg(math.atan2(to.y - from.y, to.x - from.x)) % 360
end
local function shoot_animation(angle, suffix)
	local a = angle % 360
	local flip = a > 90 and a < 270
	if a >= 337.5 or a < 22.5 or (a >= 157.5 and a < 202.5) then
		return "shootSide" .. suffix, flip, "lateral"
	elseif a >= 67.5 and a < 112.5 then
		return "shootUp" .. suffix, false, "up"
	elseif a >= 247.5 and a < 292.5 then
		return "shootDown" .. suffix, false, "down"
	elseif (a >= 22.5 and a < 67.5) or (a >= 112.5 and a < 157.5) then
		return "shootUpDiagonal" .. suffix, flip, "diagonalUp"
	else
		return "shootDownDiagonal" .. suffix, flip, "diagonalDown"
	end
end
local function shooter_animation(this, name, flip_x, ts, loop)
	U.animation_start(this, name, flip_x, ts, loop, SHOOTER_SID)
end
local IDLE_BY_ZONE = {
	lateral = "idle_side",
	up = "idle_up",
	down = "idle_down",
	diagonalUp = "idle_updiag",
	diagonalDown = "idle_downdiag",
}
local SHOOT_OFFSETS = {
	normal = {
		up = {12, 12}, down = {4, 5}, lateral = {4, 5},
		diagonalUp = {4, 5}, diagonalDown = {4, 5},
		flipped = {
			up = {-12, 12}, down = {4, 5}, lateral = {4, 5},
			diagonalUp = {4, 5}, diagonalDown = {4, 5},
		},
	},
	advanced = {
		up = {0, 25}, down = {0, -8}, lateral = {29, 7},
		diagonalUp = {15, 25}, diagonalDown = {18, -5},
		flipped = {
			up = {0, 25}, down = {0, -8}, lateral = {-29, 5},
			diagonalUp = {-15, 25}, diagonalDown = {-15, -5},
		},
	},
}
local function target_hit_pos(target)
	local p = v(target.pos.x, target.pos.y)
	if target.unit and target.unit.hit_offset then
		p.x = p.x + target.unit.hit_offset.x
		p.y = p.y + target.unit.hit_offset.y
	end
	return p
end
local function template_damage(bullet_name)
	local bt = E:get_template(bullet_name)
	local b = bt and bt.bullet
	if b and b.damage_min and b.damage_max then
		return b.damage_min, b.damage_max
	end
	return cfg.attack_damage_min, cfg.attack_damage_max
end
local function fire_bullet(this, store, enemy, zone, kind, bullet_name, dmg_min, dmg_max, mods, ray_len, dmg_type, lvl)
	local offs = SHOOT_OFFSETS[kind] or SHOOT_OFFSETS.normal
	local o = offs
	if this.render.sprites[SHOOTER_SID].flip_x then
		o = offs.flipped
	end
	o = o[zone] or {4, 5}
	local ox = o[1] * SCALE_K
	local bullet = E:create_entity(bullet_name)
	local b = bullet.bullet
	b.from, b.to = v(0, 0), v(0, 0)
	b.damage_min = dmg_min
	b.damage_max = dmg_max
	b.damage_factor = this.tower.damage_factor
	if lvl then
		b.level = lvl
	end
	if mods then
		b.mods = mods
	end
	if dmg_type then
		b.damage_type = dmg_type
		b.pop = {"pop_headshot"}
	end
	bullet.pos.x = this.pos.x + ox
	bullet.pos.y = this.pos.y + SHOOTER_OFFSET_Y + o[2] * SCALE_K
	b.from.x, b.from.y = bullet.pos.x, bullet.pos.y
	local tp = target_hit_pos(enemy)
	b.to.x, b.to.y = tp.x, tp.y
	if ray_len then
		local dx, dy = tp.x - bullet.pos.x, tp.y - bullet.pos.y
		local d = math.sqrt(dx * dx + dy * dy)

		if d > ray_len then
			local k = (d - ray_len) / d
			b.to.x = bullet.pos.x + dx * k
			b.to.y = bullet.pos.y + dy * k
		end
	end
	b.target_id = enemy.id
	b.source_id = this.id
	queue_insert(bullet)
	return bullet.pos.x, bullet.pos.y, tp.x, tp.y
end
local function spawn_mira(store, tower, target, tpl_name, duration, mira_name)
	local fx = E:create_entity(tpl_name)
	fx.mira = {
		target_id = target.id,
		tower_id = tower.id,
		ts = store.tick_ts,
		duration = duration,
	}
	fx.pos = vclone(target.pos)
	if mira_name then
		fx.render.sprites[1].name = mira_name
	end
	fx.render.sprites[1].ts = store.tick_ts
	queue_insert(fx)
	return fx
end
local function spawn_mira_set(store, tower, target, duration, mira_name)
	local m1 = spawn_mira(store, tower, target, "fx_sniper_mira", duration, mira_name)
	local m2 = spawn_mira(store, tower, target, "fx_sniper_mira_decal", duration)
	return {m1, m2}
end
local function spawn_ray(store, fx0, fy0, tx, ty)
	local fx = E:create_entity("fx_sniper_ray")
	fx.pos.x, fx.pos.y = fx0, fy0
	fx.render.sprites[1].ts = store.tick_ts
	fx.render.sprites[1].r = V.angleTo(tx - fx0, ty - fy0)
	fx.render.sprites[1].scale = v(V.dist(fx0, fy0, tx, ty) / 114.3, 1)
	queue_insert(fx)
end
scripts.tower_sniper = {}
local function sync_base_parts(sprites, pl, wl)
	sprites[4].hidden = pl == 0
	sprites[5].hidden = wl == 0
end
function scripts.tower_sniper.get_info(this)
	local aa = this.attacks.list[1]
	local dmin, dmax = template_damage(aa.bullet or "arrow_sniper_shot")
	return {
		type = STATS_TYPE_TOWER,
		damage_min = dmin * this.tower.damage_factor,
		damage_max = dmax * this.tower.damage_factor,
		damage_type = DAMAGE_PHYSICAL,
		range = this.attacks.range,
		cooldown = aa.cooldown * this.tower.cooldown_factor,
	}
end
function scripts.tower_sniper.update(this, store)
	store.d43_sniper_claims = store.d43_sniper_claims or {}
	local kill_claims = store.d43_sniper_claims
	local at = this.attacks
	local aa = this.attacks.list[1]
	local tw = this.tower
	local sprites = this.render.sprites
	local pow_p = this.powers.practice
	local kill_pity = 0
	pow_p.ts = store.tick_ts
	local weak_seen, practice_seen = -1, -1
	local follow_target_id, follow_ts = nil, store.tick_ts
	local mira_fxs = nil
	local spotter_id = nil
	aa.ts = store.tick_ts
	while true do
		if tw.blocked then
			coroutine.yield()
		else
			local wl = this.powers.weak.level
			local pl = this.powers.practice.level
			if wl ~= weak_seen then
				weak_seen = wl
				aa.bullet = wl > 0 and "arrow_sniper_shot_weak" or "arrow_sniper_shot"
				sync_base_parts(sprites, pl, wl)
			end
			if pl ~= practice_seen then
				practice_seen = pl
				pow_p.ts = store.tick_ts
				pow_p.cooldown = cfg.practice_cooldown[pl] or cfg.practice_cooldown[1]
				sync_base_parts(sprites, pl, wl)
				if pl > 0 and not (spotter_id and store.entities[spotter_id]) then
					local spotter = E:create_entity("sniper_spotter")
					spotter.pos = v(this.pos.x + SPOTTER_OFFSET[1], this.pos.y + SPOTTER_OFFSET[2])
					spotter.spotter = {tower_id = this.id}
					spotter.render.sprites[1].ts = store.tick_ts
					queue_insert(spotter)
					spotter_id = spotter.id
				end
			end
			local kl = this.powers.kill.level
			if U.tower_ready_to_use_power(pow_p, pow_p, store, tw) then
				local picked = {}
				local filters = {
					function(e)
						return band(e.vis.flags, F_FLYING) ~= 0
					end,
					function(e)
						return band(e.vis.flags, F_FLYING) == 0 and (e.ranged or e.timed_attacks or e.auras or e.death_spawns)
					end,
					function(e)
						return band(e.vis.flags, F_FLYING) == 0 and not (e.ranged or e.timed_attacks or e.auras or e.death_spawns)
					end,
				}

				for pass = 1, 3 do
					local _, sorted = U.find_foremost_enemy(store.entities, this.pos, at.blind_range, at.range, false, F_RANGED, 0, filters[pass])

					if sorted then
						for i = 1, #sorted do
							picked[#picked + 1] = sorted[i]
						end
					end
				end

				if #picked > 0 then
					pow_p.ts = store.tick_ts
					if mira_fxs then
						for i = 1, #mira_fxs do
							queue_remove(mira_fxs[i])
						end
						mira_fxs = nil
					end
					local spotter = spotter_id and store.entities[spotter_id]
					if spotter then
						U.animation_start(spotter, "special", false, store.tick_ts, false, 1)
						U.y_wait_unconditional(store, 1.5)
					end
					local max_targets = cfg.practice_targets[pl] or cfg.practice_targets[1]

					if #picked > max_targets then
						for i = #picked, max_targets + 1, -1 do
							picked[i] = nil
						end
					end

					local enemies = picked
					local shot = 0
					local last_flip, last_zone = nil, nil
					local mul = cfg.practice_damage_mul[pl] or 1
					local miras = {}

					for ti = 1, #enemies do
						local target = enemies[ti]

						if store.entities[target.id] and not target.health.dead then
							miras[#miras + 1] = spawn_mira(store, this, target, "fx_sniper_skill_mira", 5)
						end
					end

					for round_i = 1, cfg.practice_rounds[pl] or cfg.practice_rounds[1] do
						local aim_target = nil

						for ti = 1, #enemies do
							local target = enemies[ti]

							if store.entities[target.id] and not target.health.dead then
								aim_target = aim_target or target
							end
						end

						if not aim_target then
							break
						end

						local an, flip, zone = shoot_animation(angle_between(this.pos, aim_target.pos), "Advanced")
						last_flip, last_zone = flip, zone

						shooter_animation(this, an, flip, store.tick_ts, true)

						U.y_wait_unconditional(store, SHOOT_TIME)

						local fired = false

						for ti = 1, #enemies do
							local target = enemies[ti]

							if store.entities[target.id] and not target.health.dead then
								local _, _, tzone = shoot_animation(angle_between(this.pos, target.pos), "Advanced")
								local pmods = weak_seen > 0 and {"mod_sniper_poison_dot", "mod_sniper_poison_slow"} or nil
								local pdmin, pdmax = template_damage("arrow_sniper_ray")
								local fx0, fy0, tx, ty = fire_bullet(this, store, target, tzone, "advanced", "arrow_sniper_ray",
									pdmin * mul, pdmax * mul, pmods, nil, nil, weak_seen)
								local ray = E:create_entity("fx_sniper_ray_skill")
								local rdx, rdy = tx - fx0, ty - fy0
								local rdist = math.sqrt(rdx * rdx + rdy * rdy)
								ray.pos.x, ray.pos.y = fx0 + rdx * 0.056, fy0 + rdy * 0.056
								ray.ray_ts = store.tick_ts
								ray.render.sprites[1].ts = store.tick_ts
								ray.render.sprites[1].r = V.angleTo(rdx, rdy)
								ray.render.sprites[1].scale = v(rdist / 228, 1.8)
								queue_insert(ray)
								shot = shot + 1
								fired = true

								if kl > 0 then
									kill_pity = math.min(kill_pity + cfg.kill_chance_inc, cfg.kill_chance_max - cfg.kill_chance)
								end
							end
						end

					if not fired then
						break
					end

						U.y_wait_unconditional(store, 0.4)
					end
					for i = 1, #miras do
						if store.entities[miras[i].id] then
							queue_remove(miras[i])
						end
					end
					if spotter then
						U.animation_start(spotter, "idle", nil, store.tick_ts, true, 1)
					end
					if last_flip ~= nil then
						shooter_animation(this, IDLE_BY_ZONE[last_zone], last_flip, store.tick_ts, true)
					end
					aa.ts = store.tick_ts
				end
			end
			if store.tick_ts - aa.ts >= aa.cooldown * tw.cooldown_factor then
				local enemy = nil
				if follow_target_id then
					local t = store.entities[follow_target_id]
					if t and not t.health.dead and store.tick_ts - follow_ts < cfg.attack_follow_time
						and V.dist(this.pos.x, this.pos.y, t.pos.x, t.pos.y) <= at.range then
						enemy = t
					else
						follow_target_id = nil
					end
				end
				if not enemy then
					enemy = U.find_foremost_enemy(store.entities, this.pos, at.blind_range, at.range, false, aa.vis_flags, aa.vis_bans, function(e)
						return band(e.vis.flags, F_FLYING) ~= 0
					end)

					if not enemy then
					enemy = U.find_foremost_enemy(store.entities, this.pos, at.blind_range, at.range, false, aa.vis_flags, aa.vis_bans, function(e)
						return band(e.vis.flags, F_FLYING) == 0 and (e.ranged or e.timed_attacks or e.auras or e.death_spawns)
					end)
				end

				if not enemy then
					enemy = U.find_foremost_enemy(store.entities, this.pos, at.blind_range, at.range, false, aa.vis_flags, aa.vis_bans, function(e)
						return band(e.vis.flags, F_FLYING) == 0 and not (e.ranged or e.timed_attacks or e.auras or e.death_spawns)
					end)
				end

				if enemy then
					follow_target_id = enemy.id
					follow_ts = store.tick_ts
				else
					aa.ts = aa.ts + fts(5)
				end
			end
				if enemy then
				aa.ts = store.tick_ts
				aa.count = aa.count + 1
				local heart = kl > 0 and math.random() < cfg.kill_chance + kill_pity

				if heart then
					local claim = kill_claims[enemy.id]

					if claim and claim.id ~= this.id and store.tick_ts - claim.ts < 2 then
						heart = false
					end
				end

				if mira_fxs then
					for i = 1, #mira_fxs do
						queue_remove(mira_fxs[i])
					end
					mira_fxs = nil
				end
				local an, flip, zone = shoot_animation(angle_between(this.pos, enemy.pos), heart and "Special" or "")
				local kill_mira = nil

				if heart then
					kill_claims[enemy.id] = {id = this.id, ts = store.tick_ts}
					S:queue("d43_sniper_laser_sight")
					kill_mira = spawn_mira(store, this, enemy, "fx_sniper_mira_special", KILL_AIM_TIME + 0.3)
				else
					mira_fxs = spawn_mira_set(store, this, enemy, cfg.attack_follow_time,
						weak_seen > 0 and "run2" or "run")
				end
				shooter_animation(this, IDLE_BY_ZONE[zone], flip, store.tick_ts, true)

				if heart then
					U.y_wait_conditional(store, KILL_AIM_TIME, function()
						return not store.entities[enemy.id] or enemy.health.dead
					end)
				else
					U.y_wait_unconditional(store, SHOOT_TIME)
				end

				if store.entities[enemy.id] and not enemy.health.dead then
					shooter_animation(this, an, flip, store.tick_ts, false)
					U.y_wait_unconditional(store, heart and SHOOT_TIME or 0.1)
					local mods = weak_seen > 0 and {"mod_sniper_poison_dot", "mod_sniper_poison_slow"} or nil
					if heart then
						local is_boss = band(enemy.vis.flags, F_BOSS) ~= 0
						local no_instakill = band(enemy.vis.bans, F_INSTAKILL) ~= 0
						local kdmin, kdmax

						if is_boss then
							local bdmin, bdmax = template_damage("arrow_sniper_kill")
							kdmin, kdmax = bdmin * cfg.kill_boss_factor, bdmax * cfg.kill_boss_factor
						elseif no_instakill then
							kdmin, kdmax = enemy.health.hp_max * cfg.kill_hp_max_factor, enemy.health.hp_max * cfg.kill_hp_max_factor
						else
							kdmin, kdmax = enemy.health.hp, enemy.health.hp
						end

						local dmg_type = nil

						if not is_boss and not no_instakill then
							dmg_type = bor(DAMAGE_INSTAKILL, DAMAGE_NO_DODGE)
						end

						local fx0, fy0, tx, ty = fire_bullet(this, store, enemy, zone, "advanced", "arrow_sniper_kill",
							kdmin, kdmax, mods, nil, dmg_type, weak_seen)
						spawn_ray(store, fx0, fy0, tx, ty)
						kill_pity = 0
					else
						local dmin, dmax = template_damage(aa.bullet)
						local u = UP:get_upgrade("archer_precision")

						if u and math.random() < u.chance then
							dmin, dmax = dmin * u.damage_factor, dmax * u.damage_factor
						end

						fire_bullet(this, store, enemy, zone, "normal", aa.bullet, dmin, dmax, mods, nil, nil, weak_seen)
						kill_pity = math.min(kill_pity + cfg.kill_chance_inc, cfg.kill_chance_max - cfg.kill_chance)
					end

					U.y_animation_wait(this, SHOOTER_SID)
				else
					if kill_mira and store.entities[kill_mira.id] then
						queue_remove(kill_mira)
					end
				end
				if heart then
					kill_claims[enemy.id] = nil
				end
				shooter_animation(this, IDLE_BY_ZONE[zone], flip, store.tick_ts, true)
			end
			elseif follow_target_id then
					local t = store.entities[follow_target_id]
					if t and not t.health.dead then
						local _, flip, zone = shoot_animation(angle_between(this.pos, t.pos), "")
						local idle_name = IDLE_BY_ZONE[zone]
						local s = this.render.sprites[SHOOTER_SID]

						if s.name ~= idle_name or s.flip_x ~= flip then
							shooter_animation(this, idle_name, flip, store.tick_ts, true)
						end
					else
						follow_target_id = nil
					end
				end
		end
		coroutine.yield()
	end
end
scripts.fx_sniper_mira = {}
function scripts.fx_sniper_mira.update(this, store)
	local m = this.mira
	local is_decal = this.template_name == "fx_sniper_mira_decal"
	while true do
		local target = store.entities[m.target_id]
		if not target or not target.pos or target.health.dead
			or not store.entities[m.tower_id]
			or store.tick_ts - m.ts > m.duration then
			queue_remove(this)
			return
		end
		this.pos.x = target.pos.x
		this.pos.y = target.pos.y
		if not is_decal and target.unit and target.unit.hit_offset then
			this.pos.x = this.pos.x + target.unit.hit_offset.x
			this.pos.y = this.pos.y + target.unit.hit_offset.y
		end
		coroutine.yield()
	end
end
scripts.fx_sniper_mira_special = {}
function scripts.fx_sniper_mira_special.update(this, store)
	local m = this.mira
	while true do
		if store.tick_ts - m.ts > m.duration or not store.entities[m.tower_id] then
			queue_remove(this)
			return
		end
		local target = store.entities[m.target_id]
		if target and target.pos and not target.health.dead then
			this.pos.x = target.pos.x
			this.pos.y = target.pos.y
			if target.unit and target.unit.hit_offset then
				this.pos.x = this.pos.x + target.unit.hit_offset.x
				this.pos.y = this.pos.y + target.unit.hit_offset.y
			end
		end
		coroutine.yield()
	end
end
scripts.fx_sniper_ray_skill = {}
function scripts.fx_sniper_ray_skill.update(this, store)
	local t0 = this.ray_ts
	while store.tick_ts - t0 < 0.1 do
		coroutine.yield()
	end
	queue_remove(this)
end
scripts.sniper_spotter = {}
function scripts.sniper_spotter.update(this, store)
	local sp = this.spotter
	while true do
		local tower = store.entities[sp.tower_id]
		if not tower or not tower.tower then
			queue_remove(this)
			return
		end
		coroutine.yield()
	end
end

end

do -- plague_hospital
local U, SU = dove43_U, dove43_SU
local game_scripts = scripts
local cfg = scripts.dove43_config["plague_hospital"]


local v = V.v
local vclone = V.vclone

local band = bit.band
local bor = bit.bor

local TOWER_SID = 2
local DOCTOR_SID = 3
local MIKE_SPAWN_WAIT = 0.5
local MIKE_SPAWN_OFFSET = {52, -15}
local MIKE_CAP = 3
local MIASMA_STUN_CHANCE = 0.05
local CORPSE_COOLDOWN = 1
local CORPSE_RANGE_INSET = 30
local AURA_FX_DECAL_COUNT = 16
local AURA_FX_SMOKE_COUNT = 12
local AURA_FX_SPARK_COUNT = 12
local AURA_FX_INTERVAL = 0.3
local AURA_FX_LIFETIME_MIN = 3
local AURA_FX_LIFETIME_MAX = 7

local function queue_insert(e)
	simulation:queue_insert_entity(e)
end
local function queue_remove(e)
	simulation:queue_remove_entity(e)
end
local function living_zombies(aura, store)
	local living = {}
	if aura and aura.ph_zombies then
		for i = #aura.ph_zombies, 1, -1 do
			local z = aura.ph_zombies[i]
			if not store.entities[z.id] or (z.health and z.health.dead) then
				if z.health and z.health.dead and aura.ph_revive_queue then
					local tower = store.entities[aura.aura.source_id]
					if tower and tower.powers and tower.powers.house.level > 0 then
						aura.ph_revive_queue[#aura.ph_revive_queue + 1] = store.tick_ts
					end
				end
				table.remove(aura.ph_zombies, i)
			else
				living[#living + 1] = z
			end
		end
	end
	return living
end
local function apply_zombie_stats(z, source, scfg)
	local level = source.powers.house.level
	local hp_max = type(scfg.zombie_hp) == "table" and scfg.zombie_hp[level + 1] or scfg.zombie_hp
	if z.health.hp_max ~= hp_max then
		local delta = hp_max - z.health.hp_max
		z.health.hp_max = hp_max
		if delta > 0 and not z.health.dead then
			if z.health.hp then
				z.health.hp = math.min(z.health.hp + delta, hp_max)
			else
				z.health.hp = hp_max
			end
		end
	end
	if type(scfg.zombie_damage_min) == "table" then
		z.melee.attacks[1].damage_min = scfg.zombie_damage_min[level + 1]
		z.melee.attacks[1].damage_max = scfg.zombie_damage_max[level + 1]
	end
	if level >= 2 then
		z.melee.attacks[1].damage_type = DAMAGE_TRUE
	end
end
local function spawn_aura_fx(this, store, full)
	local points = U.get_path_fx_points(this, 55)
	if not points or #points == 0 then
		return
	end
	local lists = {
		{this.ph_fx_decal, "decal_plague_hospital_decal", AURA_FX_DECAL_COUNT},
		{this.ph_fx_smoke, "decal_plague_hospital_smoke", AURA_FX_SMOKE_COUNT},
		{this.ph_fx_spark, "decal_plague_hospital_spark", AURA_FX_SPARK_COUNT},
	}
	for i = 1, #lists do
		local list = lists[i][1]
		for j = #list, 1, -1 do
			if not store.entities[list[j].id] then
				table.remove(list, j)
			end
		end
		local n = full and lists[i][3] - #list or (#list < lists[i][3] and 1 or 0)
		for j = 1, n do
			local d = E:create_entity(lists[i][2])
			d.pos = vclone(points[math.random(#points)].pos)
			list[#list + 1] = d
			queue_insert(d)
		end
	end
end
local function rearrange_mikes(this, store, count, force)
	local living = {}
	for _, m in ipairs(this.barrack.soldiers) do
		if store.entities[m.id] and not m.health.dead then
			living[#living + 1] = m
		end
	end
	this.barrack.soldiers = living
	count = count or #living
	if force or count ~= this.ph_mike_count then
		this.ph_mike_count = count
		for i = 1, #living do
			local m = living[i]
			m.nav_rally.pos, m.nav_rally.center = U.rally_formation_position(i, this.barrack, count)
			if force or not m.soldier.target_id then
				m.nav_rally.new = true
			end
		end
	end
	return #living
end

scripts.tower_plague_hospital = {}

function scripts.tower_plague_hospital.rally_fn(this, store, force_silent)
	if rearrange_mikes(this, store, nil, true) > 0 and not force_silent then
		S:queue(this.sound_events.change_rally_point)
	end
end

function scripts.tower_plague_hospital.get_info(this)
	local mod = E:get_template("mod_plague_hospital_miasma")
	local aura = E:get_template("aura_plague_hospital_miasma")
	return {
		type = STATS_TYPE_TOWER,
		damage_min = math.floor(mod.dps.damage_min * this.tower.damage_factor),
		damage_max = math.floor(mod.dps.damage_max * this.tower.damage_factor),
		damage_type = DAMAGE_POISON,
		range = this.attacks.range,
		cooldown = aura.aura.cycle_time * this.tower.cooldown_factor
	}
end

function scripts.tower_plague_hospital.insert(this, store, script)
	local rally = this.barrack.rally_pos
	if not rally or V.dist(this.pos.x, this.pos.y, rally.x, rally.y) > this.barrack.rally_range then
		local desired = v(this.pos.x + 52, this.pos.y - 15)
		this.barrack.rally_pos = U.get_nearest_valid_rally_pos(desired) or desired
	end
	local miasma = E:create_entity("aura_plague_hospital_miasma")
	miasma.pos = vclone(this.pos)
	miasma.aura.source_id = this.id
	miasma.aura.ts = store.tick_ts
	miasma.aura.radius = this.attacks.range
	miasma.owner = this
	this.ph_miasma_aura = miasma
	queue_insert(miasma)

	local corpse = E:create_entity("aura_plague_hospital_corpse")
	corpse.pos = vclone(this.pos)
	corpse.aura.source_id = this.id
	corpse.aura.ts = store.tick_ts
	this.ph_corpse_aura = corpse
	queue_insert(corpse)

	this.ph_mike_count = 0
	if not this.barrack.rally_pos and this.tower.default_rally_pos then
		this.barrack.rally_pos = vclone(this.tower.default_rally_pos)
	end
	this.ph_fx_decal = {}
	this.ph_fx_smoke = {}
	this.ph_fx_spark = {}
	spawn_aura_fx(this, store, true)
	for i = 4, 7 do
		local s = this.render.sprites[i]
		if s and s.exo then
			s.ts = store.tick_ts
		end
	end
	this.attacks.list[1].ts = store.tick_ts
	return true
end

function scripts.tower_plague_hospital.remove(this, store)
	if this.ph_miasma_aura then
		queue_remove(this.ph_miasma_aura)
		this.ph_miasma_aura = nil
	end
	if this.ph_corpse_aura then
		for _, s in ipairs(this.ph_corpse_aura.ph_zombies) do
			if s.health then
				s.health.dead = true
			end
			queue_remove(s)
		end
		queue_remove(this.ph_corpse_aura)
		this.ph_corpse_aura = nil
	end
	if this.barrack.soldiers then
		for _, m in ipairs(this.barrack.soldiers) do
			queue_remove(m)
		end
		this.barrack.soldiers = {}
	end
	for _, list in ipairs({this.ph_fx_decal, this.ph_fx_smoke, this.ph_fx_spark}) do
		if list then
			for i = 1, #list do
				queue_remove(list[i])
			end
		end
	end
	this.ph_fx_decal = nil
	this.ph_fx_smoke = nil
	this.ph_fx_spark = nil
	return true
end

function scripts.tower_plague_hospital.update(this, store, script)
	local a = this.attacks
	local a_mike = this.attacks.list[1]
	local pow_m = this.powers.mike
	local pow_h = this.powers.house
	local pow_b = this.powers.biohazard
	local tw = this.tower
	local sprites = this.render.sprites
	local mike_seen, house_seen, bio_seen = -1, -1, -1
	pow_b.ts = store.tick_ts
	local aura_fx_ts = store.tick_ts
	local doctor_flavor_ts = store.tick_ts + math.random(4, 8)
	local last_range = a.range
	local last_tower_df = tw.damage_factor

	while true do
		if tw.blocked then
			coroutine.yield()
		else
			local ml = pow_m.level
			local hl = pow_h.level
			local bl = pow_b.level

			if hl ~= house_seen or bl ~= bio_seen then
				house_seen = hl
				bio_seen = bl
				if bl > 0 then
					pow_b.cooldown = cfg.bio_cooldown[bl] or cfg.bio_cooldown[1]
				end
				local tower_prefixes = {
					"d43_plaguetower",
					"d43_plaguetower_skilla",
					"d43_plaguetower_skillb",
					"d43_plaguetower_skillab",
				}
				sprites[TOWER_SID].prefix = tower_prefixes[(hl > 0 and 2 or 1) + (bl > 0 and 2 or 0)]
				U.animation_start(this, "idle", nil, store.tick_ts, true, TOWER_SID)
				sprites[DOCTOR_SID].prefix = hl > 0 and "d43_plaguetower_doctor_skilla" or "d43_plaguetower_doctor"
				U.animation_start(this, "idle", nil, store.tick_ts, true, DOCTOR_SID)
			end

			if ml ~= mike_seen then
				local was_zero = mike_seen <= 0
				mike_seen = ml
				a_mike.disabled = ml == 0
				if ml > 0 then
					a_mike.cooldown = pow_m.cooldown[ml]
					if was_zero then
						a_mike.ts = store.tick_ts - a_mike.cooldown * tw.cooldown_factor - 1
					end
				end
			end

			if last_range ~= a.range then
				last_range = a.range
				if this.ph_miasma_aura then
					this.ph_miasma_aura.aura.radius = a.range
				end
			end

			if tw.damage_factor ~= last_tower_df then
				local df_delta = tw.damage_factor - last_tower_df
				last_tower_df = tw.damage_factor
				if this.ph_corpse_aura and this.ph_corpse_aura.ph_zombies then
					for _, z in ipairs(this.ph_corpse_aura.ph_zombies) do
						if z.unit then
							z.unit.damage_factor = z.unit.damage_factor + df_delta
						end
					end
				end
			end

			if store.tick_ts - aura_fx_ts >= AURA_FX_INTERVAL then
				aura_fx_ts = store.tick_ts
				spawn_aura_fx(this, store, false)
			end

			local mike_count = rearrange_mikes(this, store)

			if ml > 0 and mike_count < MIKE_CAP and U.tower_ready_to_use_power(pow_m, a_mike, store, tw) then
				local enemy = U.find_foremost_enemy_in_range_filter_off(vclone(this.pos), a.range, false, a_mike.vis_flags, a_mike.vis_bans)
				local flip
				if enemy then
					flip = enemy.pos.x < this.pos.x
				else
					flip = this.render.sprites[TOWER_SID].flip_x
				end
				a_mike.ts = store.tick_ts
				U.animation_start(this, "spawngiant", flip, store.tick_ts, false, TOWER_SID)
				U.animation_start(this, "activateskill", flip, store.tick_ts, false, DOCTOR_SID)
				S:queue("d43_plague_summon")
				U.y_wait_unconditional(store, MIKE_SPAWN_WAIT)
				rearrange_mikes(this, store, mike_count + 1)
				local mike = E:create_entity(a_mike.entity)
				mike.pos = v(this.pos.x + MIKE_SPAWN_OFFSET[1] * (flip and -1 or 1), this.pos.y + MIKE_SPAWN_OFFSET[2])
				mike.source_id = this.id
				mike.soldier.tower_id = this.id
				mike.nav_rally.pos, mike.nav_rally.center = U.rally_formation_position(mike_count + 1, this.barrack, mike_count + 1)
				SU.soldier_inherit_tower_buff_factor(mike, this, store.tick_ts)
				queue_insert(mike)
				this.barrack.soldiers[#this.barrack.soldiers + 1] = mike
				U.y_animation_wait(this, TOWER_SID)
				U.y_animation_wait(this, DOCTOR_SID)
				U.animation_start(this, "idle", nil, store.tick_ts, true, TOWER_SID)
				U.animation_start(this, "idle", nil, store.tick_ts, true, DOCTOR_SID)
			end

			if bl > 0 and U.tower_ready_to_use_power(pow_b, pow_b, store, tw) then
				local living = living_zombies(this.ph_corpse_aura, store)
				for _, m in ipairs(this.barrack.soldiers) do
					if store.entities[m.id] and not m.health.dead then
						living[#living + 1] = m
					end
				end
				if #living > 0 then
					pow_b.ts = store.tick_ts
					U.animation_start(this, "skillb", nil, store.tick_ts, false, TOWER_SID)
					U.animation_start(this, "skillb", nil, store.tick_ts, false, DOCTOR_SID)
					U.y_wait_unconditional(store, 0.3)
					for i = 1, #living do
						local z = living[i]
						if not z.health.dead then
							local m = E:create_entity("mod_plague_hospital_buff")
							m.modifier.level = bl
							m.modifier.duration = cfg.bio_duration[bl] or cfg.bio_duration[1]
							m.modifier.target_id = z.id
							m.modifier.source_id = this.id
							m.ph_damage_mult = cfg.bio_damage_mult[bl] or cfg.bio_damage_mult[1]
							m.ph_hp_mult = cfg.bio_hp_mult[bl] or cfg.bio_hp_mult[1]
							m.ph_scale_mult = cfg.bio_scale_mult
							queue_insert(m)
						end
					end
					U.y_animation_wait(this, TOWER_SID)
					U.y_animation_wait(this, DOCTOR_SID)
					U.animation_start(this, "idle", nil, store.tick_ts, true, TOWER_SID)
					U.animation_start(this, "idle", nil, store.tick_ts, true, DOCTOR_SID)
				else
					pow_b.ts = store.tick_ts - (cfg.bio_cooldown[bl] or cfg.bio_cooldown[1]) + 1
				end
			end

			if store.tick_ts >= doctor_flavor_ts then
				U.animation_start(this, math.random(2) == 1 and "idleanim" or "idleanim2", nil, store.tick_ts, false, DOCTOR_SID)
				U.y_animation_wait(this, DOCTOR_SID)
				U.animation_start(this, "idle", nil, store.tick_ts, true, DOCTOR_SID)
				doctor_flavor_ts = store.tick_ts + math.random(6, 12)
			end
		end
		coroutine.yield()
	end
end

scripts.decal_plague_hospital = {}

function scripts.decal_plague_hospital.update(this, store)
	U.animation_start(this, "run", nil, store.tick_ts, true)
	local end_ts = store.tick_ts + AURA_FX_LIFETIME_MIN + math.random() * (AURA_FX_LIFETIME_MAX - AURA_FX_LIFETIME_MIN)
	while store.tick_ts < end_ts do
		coroutine.yield()
	end
	if this.ph_fx_fadeout then
		U.animation_start(this, "fadeout", nil, store.tick_ts, false)
		U.y_animation_wait(this, 1)
	end
	queue_remove(this)
end

scripts.aura_plague_hospital_miasma = {}

function scripts.aura_plague_hospital_miasma.update(this, store)
	local last_hit_ts = store.tick_ts - this.aura.cycle_time
	local mod_names = this.aura.mods
	while true do
		if not store.entities[this.owner.id] then
			queue_remove(this)
			return
		end
		if store.tick_ts - last_hit_ts <= this.aura.cycle_time * this.owner.tower.cooldown_factor then
		else
			last_hit_ts = store.tick_ts
			local targets = U.find_enemies_in_range_filter_off(this.pos, this.aura.radius, this.aura.vis_flags, this.aura.vis_bans)
			if targets then
				for i = 1, #targets do
					for j = 1, #mod_names do
						local new_mod = E:create_entity(mod_names[j])
						new_mod.modifier.target_id = targets[i].id
						new_mod.modifier.source_id = this.id
						if j == 1 then
							new_mod.modifier.damage_factor = this.owner.tower.damage_factor
						end
						queue_insert(new_mod)
					end
				end
			end
		end
		coroutine.yield()
	end
end

scripts.mod_plague_hospital_miasma_stun = {}

function scripts.mod_plague_hospital_miasma_stun.insert(this, store)
	local u = UP:get_upgrade("custom_engineer_6")

	if not u then
		return false
	end
	if math.random() > MIASMA_STUN_CHANCE then
		return false
	end
	return scripts.mod_stun.insert(this, store)
end

scripts.aura_plague_hospital_corpse = {}

function scripts.aura_plague_hospital_corpse.update(this, store)
	local convert_ts = store.tick_ts
	local last_clean_ts = store.tick_ts
	while true do
		local source = store.entities[this.aura.source_id]
		if not source or not source.tower then
			queue_remove(this)
			return
		end
		local scfg = source.tower_cfg
		local cap = scfg.zombie_cap[source.powers.house.level + 1]
		if store.tick_ts - last_clean_ts >= this.aura.cycle_time then
			last_clean_ts = store.tick_ts
			living_zombies(this, store)
			local house_level = source.powers.house.level
			if this.ph_house_level ~= house_level then
				this.ph_house_level = house_level
				for i = 1, #this.ph_zombies do
					apply_zombie_stats(this.ph_zombies[i], source, scfg)
				end
			end
			if #this.ph_revive_queue > 0 and source.powers.house.level > 0 and store.tick_ts - this.ph_revive_queue[1] >= (scfg.zombie_revive_time or 12) * source.tower.cooldown_factor and #this.ph_zombies < cap then
				local revive_range = source.attacks.range
				local enemy, _, spawn_pos = U.find_foremost_enemy_in_range_filter_on(this.pos, revive_range - CORPSE_RANGE_INSET, 1, F_BLOCK, F_FLYING, function(e)
					if e._ph_revive and e._ph_revive[this.id] and e._ph_revive[this.id] >= 1 then
						return false
					end
					local pp = U.calculate_enemy_ffe_pos(e, 1)
					local dx = pp.x - this.pos.x
					local dy = (pp.y - this.pos.y) / (ASPECT or 0.7)
					return dx * dx + dy * dy <= revive_range * revive_range
				end)
				if enemy then
					table.remove(this.ph_revive_queue, 1)
					if not enemy._ph_revive then
						enemy._ph_revive = {}
					end
					enemy._ph_revive[this.id] = (enemy._ph_revive[this.id] or 0) + 1
					local z = E:create_entity("soldier_plague_zombie")
					z.pos = vclone(spawn_pos)
					z.nav_rally.pos = vclone(z.pos)
					z.nav_rally.center = vclone(z.pos)
					z.source_id = source.id
					z.soldier.tower_id = source.id
					apply_zombie_stats(z, source, scfg)
					SU.soldier_inherit_tower_buff_factor(z, source, store.tick_ts)
					queue_insert(z)
					this.ph_zombies[#this.ph_zombies + 1] = z
				end
			end
		end
		if #this.ph_zombies < cap and store.tick_ts - convert_ts >= CORPSE_COOLDOWN * source.tower.cooldown_factor then
			local delay = scfg.corpse_delay
			local dead_enemies = U.find_enemies_in_range_filter_override(this.pos, source.attacks.range - CORPSE_RANGE_INSET, function(e)
				return e.health.dead
					and band(e.vis.bans, F_SKELETON) == 0
					and band((e.health.last_damage_types or 0), DAMAGE_EAT) == 0
					and band(e.vis.flags, F_FLYING) == 0
					and store.tick_ts - e.health.death_ts >= delay
			end)
			if dead_enemies and #dead_enemies > 0 then
				convert_ts = store.tick_ts
				local dead = dead_enemies[1]
				U.bans_add(dead.vis, F_SKELETON)
				dead.health.delete_after = 0
				local z = E:create_entity("soldier_plague_zombie")
				z.pos = vclone(dead.pos)
				if dead.enemy.necromancer_offset then
					z.pos.x = z.pos.x + dead.enemy.necromancer_offset.x * (dead.render.sprites[1].flip_x and -1 or 1)
					z.pos.y = z.pos.y + dead.enemy.necromancer_offset.y
				end
				z.nav_rally.pos = vclone(z.pos)
				z.nav_rally.center = vclone(z.pos)
				z.source_id = source.id
				z.soldier.tower_id = source.id
				apply_zombie_stats(z, source, scfg)
				SU.soldier_inherit_tower_buff_factor(z, source, store.tick_ts)
				queue_insert(z)
				this.ph_zombies[#this.ph_zombies + 1] = z
			end
		end
		coroutine.yield()
	end
end

scripts.soldier_plague_zombie = {}

function scripts.soldier_plague_zombie.get_info(this)
	local info = scripts.soldier_barrack.get_info(this)
	local tower = simulation.store and simulation.store.entities[this.soldier.tower_id]
	if tower and tower.powers and tower.powers.house.level > 0 then
		info.respawn = tower.tower_cfg.zombie_revive_time * tower.tower.cooldown_factor
	else
		info.respawn = nil
	end
	return info
end

function scripts.soldier_plague_zombie.update(this, store)
	local brk, sta
	this.render.sprites[1].ts = store.tick_ts
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end
	do
		local target = SU.soldier_pick_melee_target(store, this)

		if target then
			U.block_enemy(store, this, target)

			local slot_pos, _, _ = U.melee_slot_position(this, target)

			if slot_pos then
				U.set_destination(this, slot_pos)
			end
		end
	end
	this.health_bar.hidden = true
	U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)
	if not this.health.dead then
		this.health_bar.hidden = nil
	end
	local starting_pos = vclone(this.pos)
	this.nav_rally.pos = starting_pos
	this.nav_rally.center = vclone(starting_pos)
	while true do
		if this.health.dead then
			U.unblock_target(store, this)
			if band(this.health.last_damage_types, DAMAGE_EAT) ~= 0 then
				this.unit.hide_during_death = true
			end
			U.y_animation_play(this, "death", nil, store.tick_ts, 1)
			queue_remove(this)
			return
		end
		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
			if brk or sta == A_DONE or sta == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
			elseif SU.soldier_go_back_step(store, this) then
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end
		coroutine.yield()
	end
end

scripts.soldier_plague_mutant = {}

function scripts.soldier_plague_mutant.get_info(this)
	local info = scripts.soldier_barrack.get_info(this)
	local tower = simulation.store and simulation.store.entities[this.soldier.tower_id]
	if tower and tower.powers and tower.powers.mike.level > 0 then
		info.respawn = tower.tower_cfg.mike_cooldown[tower.powers.mike.level] * tower.tower.cooldown_factor
	else
		info.respawn = nil
	end
	return info
end

function scripts.soldier_plague_mutant.insert(this, store)
	local tower = store.entities[this.source_id]
	if tower and tower.tower_cfg and tower.powers then
		local mcfg = tower.tower_cfg
		local lvl = math.max(1, math.min(#mcfg.mike_hp, tower.powers.mike.level))
		this.health.hp_max = mcfg.mike_hp[lvl]
		this.health.hp = this.health.hp_max
		this.regen.health = math.ceil(this.health.hp_max * 0.2)
		this.melee.attacks[1].damage_min = mcfg.mike_damage_min[lvl]
		this.melee.attacks[1].damage_max = mcfg.mike_damage_max[lvl]
	end
	if store.root_entity_map and tower then
		store.root_entity_map[this.id] = tower
	end
	return true
end

function scripts.soldier_plague_mutant.update(this, store)
	local brk, sta
	this.render.sprites[1].ts = store.tick_ts
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end
	this.health_bar.hidden = true
	U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)
	if not this.health.dead then
		this.health_bar.hidden = nil
	end
	while true do
		if this.health.dead then
			U.unblock_target(store, this)
			if band(this.health.last_damage_types, DAMAGE_EAT) ~= 0 then
				this.unit.hide_during_death = true
			end
			U.y_animation_play(this, "death", nil, store.tick_ts, 1)
			queue_remove(this)
			return
		end
		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto label_mike_continue
				end
			end
			brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
			if brk or sta == A_DONE or sta == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
				goto label_mike_continue
			elseif SU.soldier_go_back_step(store, this) then
				goto label_mike_continue
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)
			end
		end
		::label_mike_continue::
		coroutine.yield()
	end
end

scripts.mod_plague_hospital_buff = {}

function scripts.mod_plague_hospital_buff.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if not target or target.health.dead or not target.unit then
		return false
	end
	this.ph_damage_mult = this.ph_damage_mult or 1
	this.ph_hp_mult = this.ph_hp_mult or 1
	this.ph_scale_mult = this.ph_scale_mult or 1
	target.unit.damage_factor = target.unit.damage_factor * this.ph_damage_mult
	local h = target.health
	this.ph_overflow_hp = math.max(0, h.hp - h.hp_max)
	local boost = math.ceil(h.hp_max * (this.ph_hp_mult - 1))
	this.ph_hp_boost = boost
	h.hp_max = h.hp_max + boost
	U.heal(target, h.hp_max - h.hp)
	local s = target.render and target.render.sprites[1]
	if s then
		this.ph_prev_scale = s.scale
		s.scale = v((s.scale and s.scale.x or 1) * this.ph_scale_mult, (s.scale and s.scale.y or 1) * this.ph_scale_mult)
	end
	if this.render then
		for _, rs in pairs(this.render.sprites) do
			rs.ts = store.tick_ts
		end
	end
	signal.emit("mod-applied", this, target)
	return true
end

function scripts.mod_plague_hospital_buff.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if not target or not target.pos then
		queue_remove(this)
		return
	end
	this.pos = target.pos
	while true do
		target = store.entities[m.target_id]
		if not target or not target.pos or target.health.dead or store.tick_ts - m.ts >= m.duration then
			queue_remove(this)
			return
		end
		this.pos = target.pos
		coroutine.yield()
	end
end

function scripts.mod_plague_hospital_buff.remove(this, store)
	local target = store.entities[this.modifier.target_id]
	if target and target.health and target.unit then
		target.unit.damage_factor = target.unit.damage_factor / this.ph_damage_mult
		if this.ph_hp_boost then
			local h = target.health
			h.hp_max = math.max(1, h.hp_max - this.ph_hp_boost)
			local cap = h.hp_max
			if this.ph_overflow_hp and this.ph_overflow_hp <= this.ph_hp_boost then
				cap = cap + this.ph_overflow_hp
			end
			h.hp = math.min(h.hp, cap)
		end
		if this.ph_prev_scale ~= nil and target.render and target.render.sprites[1] then
			target.render.sprites[1].scale = this.ph_prev_scale
		end
	end
	return true
end

end

do -- command_center
local U, SU = dove43_U, dove43_SU
local game_scripts = scripts
local cfg = scripts.dove43_config["command_center"]


local v = V.v
local vclone = V.vclone

local band = bit.band

local TOWER_SID = 2
local TOWER_PREFIXES = {
	"d43_commandcenter_tower",
	"d43_commandcenter_tower_a",
	"d43_commandcenter_tower_b",
	"d43_commandcenter_tower_ab",
}
local PLANE_SPEED = 230
local PLANE_HEIGHT = 300
local PLANE_MARGIN = 520
local WAVE_FLY_TIME = 0.45
local TARGET_MARK_TIME = 8
local ROUTINE_MIN = 5
local ROUTINE_MAX = 9

local function queue_insert(e)
	simulation:queue_insert_entity(e)
end
local function queue_remove(e)
	simulation:queue_remove_entity(e)
end
local function tpos(e)
	return e.tower and e.tower.range_offset and v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or e.pos
end
local function shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end

scripts.tower_command_center = {}

function scripts.tower_command_center.get_info(this)
	local b = E:get_template("cc_flashbang_bullet")
	return {
		type = STATS_TYPE_TOWER,
		damage_min = b.bullet.damage_min * this.tower.damage_factor,
		damage_max = b.bullet.damage_max * this.tower.damage_factor,
		damage_type = DAMAGE_EXPLOSION,
		range = this.attacks.range,
		cooldown = this.attacks.list[1].cooldown * this.tower.cooldown_factor
	}
end

function scripts.tower_command_center.insert(this, store)
	this.attacks.list[1].ts = store.tick_ts
	this.attacks.list[2].ts = store.tick_ts
	this.render.sprites[2].ts = store.tick_ts
	return true
end

function scripts.tower_command_center.remove(this, store)
	local ae = this.attacks.list[2]
	local towers = U.find_towers_in_range(store.entities, this.pos, {max_range = this.attacks.range, min_range = 0}, function(t)
		return U.has_modifiers(store, t, ae.mod)
	end)
	if towers then
		for _, tower in pairs(towers) do
			SU.remove_modifiers(store, tower, ae.mod)
			SU.remove_modifiers(store, tower, ae.mod_fx)
		end
	end
	for _, mod in pairs(store.entities) do
		if mod.template_name == "mod_cc_intranet_range" and mod.modifier.source_id == this.id then
			queue_remove(mod)
		end
	end
	return true
end

function scripts.tower_command_center.update(this, store)
	local a = this.attacks
	local ba = a.list[1]
	local ae = a.list[2]
	local pow_r = this.powers.radar
	local pow_i = this.powers.intranet
	local pow_s = this.powers.reaper
	local pow_m = this.powers.airstrike
	local tw = this.tower
	local sprites = this.render.sprites
	local tcfg = this.tower_cfg
	local strike_seen, intranet_seen = -1, -1
	local tink = UP:get_upgrade("engineer_gnomish_tinkering")
	local tink_factor = tink and tink.cooldown_factor or 1
	local missile_tpl = E:get_template("cc_power_missile")
	local missile_dmul_min = missile_tpl.bullet.damage_min / tcfg.airstrike_damage_min[1]
	local missile_dmul_max = missile_tpl.bullet.damage_max / tcfg.airstrike_damage_max[1]
	local missile_flat = missile_tpl.bullet.damage_min == missile_tpl.bullet.damage_max
	ba.ts = store.tick_ts
	ae.ts = store.tick_ts
	pow_r.ts = store.tick_ts
	pow_r.cooldown = tcfg.radar_cooldown * tink_factor
	pow_i.ts = store.tick_ts
	pow_s.ts = store.tick_ts
	pow_m.ts = store.tick_ts
	pow_m.cooldown = pow_m.cooldown_base * tink_factor
	local range_aura_ts = -math.huge
	local routine_ts = store.tick_ts + math.random(4, 8)
	local aura_factor = tcfg.aura_damage_factor

	while true do
		if tw.blocked then
			coroutine.yield()
		else
			local rl = pow_r.level
			local il = pow_i.level
			local sl = pow_s.level

			if sl ~= strike_seen or il ~= intranet_seen then
				strike_seen = sl
				intranet_seen = il
				sprites[TOWER_SID].prefix = TOWER_PREFIXES[(sl > 0 and 2 or 1) + (il > 0 and 2 or 0)]
				U.animation_start(this, "idle", nil, store.tick_ts, true, TOWER_SID)
				if il > 0 then
					pow_i.ts = store.tick_ts
					pow_i.cooldown = tcfg.intranet_cooldown[il] * tink_factor
				end
				if sl > 0 then
					pow_s.ts = store.tick_ts
					pow_s.cooldown = tcfg.airstrike_cooldown[sl] * tink_factor
				end
			end

			if store.tick_ts - ae.ts > ae.cooldown * tw.cooldown_factor then
				local towers = U.find_towers_in_range(store.entities, tpos(this), {max_range = a.range, min_range = 0}, function(t)
					local has_mod, mods = U.has_modifiers(store, t, ae.mod)
					local max_factor = 1
					if has_mod and mods and #mods >= 1 then
						for k, mm in ipairs(mods) do
							if max_factor < mm.damage_factor then
								max_factor = mm.damage_factor
							end
						end
					end
					return t.tower.can_be_mod and max_factor < aura_factor and band(t.vis.flags, ae.vis_bans) == 0 and band(t.vis.bans, ae.vis_flags) == 0
				end)
				if not towers or #towers <= 0 then
					ae.ts = ae.ts + ae.cooldown
				else
					for _, tower in ipairs(towers) do
						local m = E:create_entity(ae.mod)
						m.modifier.source_id = this.id
						m.modifier.target_id = tower.id
						m.damage_factor = aura_factor
						m.modifier.damage_factor = aura_factor
						queue_insert(m)
						m = E:create_entity(ae.mod_fx)
						m.modifier.source_id = this.id
						m.modifier.target_id = tower.id
						m.pos.x, m.pos.y = tower.pos.x, tower.pos.y
						queue_insert(m)
					end
					ae.ts = store.tick_ts
				end
			end

			if il > 0 and store.tick_ts - range_aura_ts >= 0.5 then
				range_aura_ts = store.tick_ts
				local targets = U.find_towers_in_range(store.entities, tpos(this), {max_range = a.range, min_range = 0}, function(t)
					return t.id ~= this.id and t.tower.can_be_mod and not t.pending_removal
				end)
				for _, tower in ipairs(targets or {}) do
					local _, mods = U.has_modifiers(store, tower, "mod_cc_intranet_range")
					local owned = false
					for _, mod in pairs(mods or {}) do
						if mod.modifier.source_id == this.id and not mod.pending_removal then owned = true; break end
					end
					if not owned then
						local mod = E:create_entity("mod_cc_intranet_range")
						mod.modifier.source_id, mod.modifier.target_id = this.id, tower.id
						mod.range_factor = 1 + pow_i.range_bonus[il]
						queue_insert(mod)
					end
				end
			end

			if rl > 0 and U.tower_ready_to_use_power(pow_r, pow_r, store, tw) then
				pow_r.ts = store.tick_ts
				U.animation_start(this, "Activate", nil, store.tick_ts, false, TOWER_SID)
				S:queue("d43_cc_radar")
				local enemies = U.find_enemies_in_range_filter_off(tpos(this), a.range, F_RANGED, 0)
				for _, enemy in ipairs(enemies or {}) do
					if not enemy.pending_removal then
						local bonus = band(enemy.vis.flags, F_FLYING) ~= 0 or (enemy.health.armor or 0) >= pow_r.armor_threshold
						local damage = E:assign_damage(DAMAGE_ELECTRICAL, pow_r.damage[rl] * tw.damage_factor * (bonus and 2 or 1), this.id, enemy.id)
						queue_damage(store, damage)
					end
				end
				U.y_animation_wait(this, TOWER_SID)
				U.animation_start(this, "idle", nil, store.tick_ts, true, TOWER_SID)
			end

			if il > 0 and U.tower_ready_to_use_power(pow_i, pow_i, store, tw) then
				local targets = U.find_towers_in_range(store.entities, tpos(this), {max_range = a.range, min_range = 0}, function(t)
					return t.tower.can_be_mod and t.id ~= this.id
				end)
				if targets and #targets > 0 then
					pow_i.ts = store.tick_ts
					U.animation_start(this, "skill_B", nil, store.tick_ts, false, TOWER_SID)
					S:queue("d43_cc_intranet")
					U.y_wait_unconditional(store, 0.4)
					for _, tower in ipairs(targets) do
						local w = E:create_entity("cc_intranet_wave")
						w.pos = v(this.pos.x + 10, this.pos.y + 80)
						w.from = vclone(w.pos)
						w.to = vclone(tower.pos)
						w.source_id = this.id
						w.target_id = tower.id
						queue_insert(w)
					end
					U.y_animation_wait(this, TOWER_SID)
					U.animation_start(this, "idle", nil, store.tick_ts, true, TOWER_SID)
				else
					pow_i.ts = store.tick_ts - pow_i.cooldown * tw.cooldown_factor + 1
				end
			end

			if sl > 0 and U.tower_ready_to_use_power(pow_s, pow_s, store, tw) then
				local enemies = U.find_enemies_in_range_filter_off(tpos(this), a.range, ba.vis_flags, ba.vis_bans)
				if enemies and #enemies > 0 then
					pow_s.ts = store.tick_ts
					U.animation_start(this, "skill_A", nil, store.tick_ts, false, TOWER_SID)
					S:queue("d43_cc_airstrike")
					S:queue("d43_cc_plane")
					local plane = E:create_entity("cc_power_plane")
					local dir = math.random(2) == 1 and 1 or -1
					plane.pos = v(this.pos.x - dir * PLANE_MARGIN, this.pos.y + PLANE_HEIGHT)
					plane.cc_dir = dir
					plane.cc_end_x = this.pos.x + dir * PLANE_MARGIN
					queue_insert(plane)
					U.y_wait_unconditional(store, 0.5)
					shuffle(enemies)
					local n = tcfg.airstrike_missiles[sl]
					for i = 1, n do
						local tgt = enemies[(i - 1) % #enemies + 1]
						local b = E:create_entity("cc_power_missile")
						if missile_flat then
						b.bullet.damage_min = tcfg.airstrike_damage_max[sl] * missile_dmul_max
						b.bullet.damage_max = tcfg.airstrike_damage_max[sl] * missile_dmul_max
					else
						b.bullet.damage_min = tcfg.airstrike_damage_min[sl] * missile_dmul_min
						b.bullet.damage_max = tcfg.airstrike_damage_max[sl] * missile_dmul_max
					end
						b.bullet.damage_factor = tw.damage_factor
						b.bullet.execute_ratio = pow_s.execute_ratio[sl]
						b.bullet.target_id = tgt.id
						b.pos = v(plane.pos.x + (math.random() - 0.5) * 20, plane.pos.y)
						b.bullet.to = vclone(tgt.pos)
						b.bullet.source_id = this.id
						queue_insert(b)
						local mark = E:create_entity("fx_cc_power_target")
						mark.pos = vclone(tgt.pos)
						mark.cc_target_id = tgt.id
						mark.cc_missile_id = b.id
						queue_insert(mark)
						if i < n then
							U.y_wait_unconditional(store, 0.3)
						end
					end
					U.y_animation_wait(this, TOWER_SID)
					U.animation_start(this, "idle", nil, store.tick_ts, true, TOWER_SID)
				else
					pow_s.ts = store.tick_ts - pow_s.cooldown * tw.cooldown_factor + 1
				end
			end

			if pow_m.level > 0 and U.tower_ready_to_use_power(pow_m, pow_m, store, tw) then
				local enemies = U.find_enemies_in_range_filter_off(tpos(this), a.range, F_RANGED, 0)
				if enemies and #enemies > 0 then
					pow_m.ts = store.tick_ts
					U.animation_start(this, "skill_A", nil, store.tick_ts, false, TOWER_SID)
					for i = 1, pow_m.missiles[pow_m.level] do
						local target = enemies[(i - 1) % #enemies + 1]
						local missile = E:create_entity("cc_reaper_missile")
						missile.pos = v(this.pos.x + (i % 2 == 0 and -16 or 16), this.pos.y + 65)
						missile.bullet.from = vclone(missile.pos)
						missile.bullet.to = v(missile.pos.x + (i % 2 == 0 and -20 or 20), missile.pos.y + 55)
						missile.bullet.target_id, missile.bullet.source_id = target.id, this.id
						missile.bullet.damage_factor = tw.damage_factor
						queue_insert(missile)
						if i < pow_m.missiles[pow_m.level] then U.y_wait_unconditional(store, 0.15) end
					end
					U.y_animation_wait(this, TOWER_SID)
					U.animation_start(this, "idle", nil, store.tick_ts, true, TOWER_SID)
				end
			end

			if store.tick_ts - ba.ts >= ba.cooldown * tw.cooldown_factor then
				local enemy, _, pred_pos = U.find_foremost_enemy_in_range_filter_off(tpos(this), a.range, ba.node_prediction, ba.vis_flags, ba.vis_bans)
				if enemy then
					ba.ts = store.tick_ts
					local flip = enemy.pos.x < this.pos.x
					U.animation_start(this, flip and "FlashbangIzq" or "FlashbangDer", nil, store.tick_ts, false, TOWER_SID)
					while store.tick_ts - ba.ts < ba.shoot_time do
						coroutine.yield()
					end
					local trigger_pos = pred_pos
					enemy, _, pred_pos = U.find_foremost_enemy_in_range_filter_off(tpos(this), a.range, ba.node_prediction, ba.vis_flags, ba.vis_bans)
					local b = E:create_entity(ba.bullet)
					b.bullet.damage_factor = tw.damage_factor
					local ox = flip and 2 or -17
					b.pos.x, b.pos.y = this.pos.x + ox, this.pos.y + 55
					b.bullet.from = vclone(b.pos)
					b.bullet.to = enemy and pred_pos or trigger_pos
					b.bullet.source_id = this.id
					queue_insert(b)
				else
					ba.ts = ba.ts + 0.1
				end
				U.animation_start(this, "idle", nil, store.tick_ts, true, TOWER_SID)
			end

			if store.tick_ts >= routine_ts then
				U.animation_start(this, "unitsroutine", nil, store.tick_ts, false, TOWER_SID)
				U.y_animation_wait(this, TOWER_SID)
				U.animation_start(this, "idle", nil, store.tick_ts, true, TOWER_SID)
				routine_ts = store.tick_ts + math.random(ROUTINE_MIN, ROUTINE_MAX)
			end
		end
		coroutine.yield()
	end
end

scripts.mod_cc_command_aura = {}

function scripts.mod_cc_command_aura.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if target then
		this.pos = target.pos
	end
	m.ts = store.tick_ts
	while store.tick_ts - m.ts < m.duration do
		target = store.entities[m.target_id]
		local source = store.entities[m.source_id]
		if not target or not target.pos or not source or source.pending_removal then
			break
		end
		if source.attacks then
			local dx = target.pos.x - source.pos.x
			local dy = target.pos.y - source.pos.y
			if dx * dx + dy * dy > source.attacks.range * source.attacks.range then
				break
			end
		end
		this.pos = target.pos
		coroutine.yield()
	end
	queue_remove(this)
end

function scripts.mod_cc_command_aura.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if target and target.tower and this.damage_factor then
		SU.remove_tower_damage_factor_buff(target, this.damage_factor - 1)
		SU.remove_modifiers(store, target, "mod_cc_command_aura_fx")
	end
	local source = store.entities[m.source_id]
	if source then
		source.attacks.list[2].ts = store.tick_ts
	end
	return true
end

scripts.mod_cc_command_aura_fx = {}

function scripts.mod_cc_command_aura_fx.insert(this, store)
	if this.render then
		for _, rs in pairs(this.render.sprites) do
			rs.ts = store.tick_ts
		end
	end
	return true
end

function scripts.mod_cc_command_aura_fx.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if target then
		this.pos = target.pos
	end
	while true do
		target = store.entities[m.target_id]
		if not target or not target.pos or not store.entities[m.source_id] or store.entities[m.source_id].pending_removal then
			queue_remove(this)
			return
		end
		this.pos = target.pos
		coroutine.yield()
	end
end

scripts.mod_cc_intranet_range = {}

local function cc_other_range_factor(this, store)
	local factor = 1
	for _, mod in pairs(store.entities) do
		if mod.id ~= this.id and mod.template_name == this.template_name and mod.cc_range_registered and
			mod.modifier.target_id == this.modifier.target_id then
			factor = math.max(factor, mod.range_factor)
		end
	end
	return factor
end

function scripts.mod_cc_intranet_range.insert(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if not target or not target.tower then
		return false
	end
	local other = cc_other_range_factor(this, store)
	SU.insert_tower_range_buff(target, math.max(other, this.range_factor) / other)
	this.cc_range_registered = true
	this.pos = target.pos
	if this.render then
		for _, rs in pairs(this.render.sprites) do
			rs.ts = store.tick_ts
		end
	end
	signal.emit("mod-applied", this, target)
	return true
end

function scripts.mod_cc_intranet_range.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if target then
		this.pos = target.pos
	end
	while true do
		target = store.entities[m.target_id]
		local source = store.entities[m.source_id]
		local power = source and source.powers and source.powers.intranet
		if not target or target.pending_removal or not source or source.pending_removal or
			source.tower.blocked or not power or power.level == 0 or
			not U.is_inside_ellipse(target.pos, tpos(source), source.attacks.range) then
			break
		end
		local factor = 1 + power.range_bonus[power.level]
		if factor ~= this.range_factor then
			scripts.mod_cc_intranet_range.remove(this, store)
			this.range_factor = factor
			scripts.mod_cc_intranet_range.insert(this, store)
		end
		this.pos = target.pos
		coroutine.yield()
	end
	queue_remove(this)
end

function scripts.mod_cc_intranet_range.remove(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]
	if this.cc_range_registered and target and target.tower then
		local other = cc_other_range_factor(this, store)
		SU.insert_tower_range_buff(target, other / math.max(other, this.range_factor))
	end
	this.cc_range_registered = nil
	return true
end

scripts.cc_intranet_wave = {}

function scripts.cc_intranet_wave.update(this, store)
	local from, to = this.from, this.to
	this.pos.x, this.pos.y = from.x, from.y
	this.render.sprites[1].ts = store.tick_ts
	U.animation_start(this, "start", nil, store.tick_ts, false)
	U.y_animation_wait(this, 1)
	U.animation_start(this, "idle", nil, store.tick_ts, true)
	local start_ts = store.tick_ts
	while store.tick_ts - start_ts < WAVE_FLY_TIME do
		local k = (store.tick_ts - start_ts) / WAVE_FLY_TIME
		this.pos.x = from.x + (to.x - from.x) * k
		this.pos.y = from.y + (to.y - from.y) * k
		coroutine.yield()
	end
	local target = store.entities[this.target_id]
	if target then
		if target.attacks then
			local cf = target.tower and target.tower.cooldown_factor or 1
			for _, atk in ipairs(target.attacks.list) do
				if atk.cooldown and atk.cooldown > 0 and not atk.disabled then
					atk.ts = store.tick_ts - atk.cooldown * cf
				end
			end
		end
		for _, attack in pairs(target.timed_attacks and target.timed_attacks.list or {}) do
			if type(attack.cooldown) == "number" then attack.ts = store.tick_ts - attack.cooldown - 1 end
		end
		if target.powers then
			for pn, p in pairs(target.powers) do
				if p.ts and p.cooldown and pn ~= "intranet" then
					p.ts = store.tick_ts - (type(p.cooldown) == "number" and p.cooldown or 0) - 1
				end
			end
		end
	end
	local fx = E:create_entity("fx_cc_intranet_hit")
	fx.pos.x, fx.pos.y = to.x, to.y
	fx.render.sprites[1].ts = store.tick_ts
	queue_insert(fx)
	U.animation_start(this, "fade", nil, store.tick_ts, false)
	U.y_animation_wait(this, 1)
	queue_remove(this)
end

scripts.cc_power_plane = {}

function scripts.cc_power_plane.update(this, store)
	local dir = this.cc_dir or 1
	this.render.sprites[1].flip_x = dir < 0
	this.render.sprites[1].ts = store.tick_ts
	while true do
		this.pos.x = this.pos.x + PLANE_SPEED * dir * store.tick_length
		if (dir > 0 and this.pos.x >= this.cc_end_x) or (dir < 0 and this.pos.x <= this.cc_end_x) then
			break
		end
		coroutine.yield()
	end
	queue_remove(this)
end

scripts.fx_cc_power_target = {}

function scripts.fx_cc_power_target.update(this, store)
	U.animation_start(this, "run", nil, store.tick_ts, true)
	local end_ts = store.tick_ts + TARGET_MARK_TIME
	while store.tick_ts < end_ts do
		local tgt = store.entities[this.cc_target_id]
		if not tgt then
			break
		end
		this.pos.x, this.pos.y = tgt.pos.x, tgt.pos.y
		if this.cc_missile_id and not store.entities[this.cc_missile_id] then
			break
		end
		coroutine.yield()
	end
	queue_remove(this)
end

end

-- T200 homing flight with a post-damage execution check.
scripts.missile_cc_reaper = {}
function scripts.missile_cc_reaper.update(this, store, script)
	local b = this.bullet
	local target = store.entities[b.target_id]
	local mspeed = b.min_speed
	local rot_dir = 1
	local follow = false
	local max_seek_angle = b.max_seek_angle or 0.2

	if this.render.sprites[1].animated then
		U.animation_start(this, "flying", nil, store.tick_ts, -1)
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.speed.x, b.speed.y)

		if b.rot_dir_from_long_angle and target then
			rot_dir = target.pos.x < this.pos.x and -1 or 1
		elseif b.speed.x < 0 then
			rot_dir = -1
		end

		coroutine.yield()
	end

	if not target or target.health and target.health.dead then
		local ref_pos = target and target.pos or this.pos

		target = U.find_foremost_enemy(store.entities, ref_pos, 0, b.retarget_range, false, b.vis_flags)
	end

	if target then
		b.to.x, b.to.y = target.pos.x, target.pos.y

		if target.unit.hit_offset then
			b.to.x, b.to.y = b.to.x + target.unit.hit_offset.x, b.to.y + target.unit.hit_offset.y
		end
	end

	while V.dist(this.pos.x, this.pos.y, b.to.x, b.to.y) > mspeed * store.tick_length do
		if not target or target.health and target.health.dead or band(target.vis.bans, b.vis_flags) ~= 0 then
			local ref_pos = target and target.pos or this.pos

			target = U.find_foremost_enemy(store.entities, ref_pos, 0, b.retarget_range, false, b.vis_flags)

			if b.rot_dir_from_long_angle and target then
				rot_dir = target.pos.x < this.pos.x and -1 or 1
			end
		end

		if target then
			b.to.x, b.to.y = target.pos.x, target.pos.y

			if target.unit.hit_offset then
				b.to.x, b.to.y = b.to.x + target.unit.hit_offset.x, b.to.y + target.unit.hit_offset.y
			end
		end

		local d_angle = V.angleTo(b.speed.x, b.speed.y, b.to.x - this.pos.x, b.to.y - this.pos.y)

		if max_seek_angle < math.abs(d_angle) then
			local rot = b.turn_speed * store.tick_length * rot_dir
			local dir = V.angleTo(b.speed.x, b.speed.y)

			if dir > math.pi / 3 and dir < 2 * math.pi / 3 then
				rot = rot * (b.turn_helicoidal_factor or 1.5)
			end

			b.speed.x, b.speed.y = V.rotate(rot, b.speed.x, b.speed.y)
		else
			mspeed = mspeed + 30 * math.ceil(mspeed * 0.03333333333333333 * b.acceleration_factor)
			mspeed = km.clamp(b.min_speed, b.max_speed, mspeed)
			b.speed.x, b.speed.y = V.mul(mspeed, V.normalize(b.to.x - this.pos.x, b.to.y - this.pos.y))
		end

		this.pos.x, this.pos.y = this.pos.x + b.speed.x * store.tick_length, this.pos.y + b.speed.y * store.tick_length
		this.render.sprites[1].r = V.angleTo(b.speed.x, b.speed.y)

		coroutine.yield()
	end


	local hits = {}
	for _, enemy in pairs(store.entities) do
		if enemy.enemy and enemy.health and not enemy.health.dead and not enemy.pending_removal and enemy.vis and enemy.unit and
			band(enemy.vis.flags, b.damage_bans) == 0 and band(enemy.vis.bans, b.damage_flags) == 0 then
			local hit_pos = V.v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
			if U.is_inside_ellipse(hit_pos, b.to, b.damage_radius) then
				local falloff = U.dist_factor_inside_ellipse(hit_pos, b.to, b.damage_radius)
				local damage = E:assign_damage(b.damage_type, math.ceil(b.damage_factor * math.floor(b.damage_max - (b.damage_max - b.damage_min) * falloff)), b.source_id or this.id, enemy.id)
				hits[#hits + 1] = damage
				queue_damage(store, damage)
			end
		end
	end
	local fx = E:create_entity(b.hit_fx)
	fx.pos = V.vclone(b.to)
	fx.render.sprites[1].ts = store.tick_ts
	queue_insert(store, fx)
	S:queue(this.sound_events.hit)
	this.render.sprites[1].hidden = true
	if b.execute_ratio and b.execute_ratio > 0 then
		-- Wait for actual armor, shield and immunity results before execution.
		for _, damage in ipairs(hits) do
			while damage.damage_applied == nil do coroutine.yield() end
		end
		for _, damage in ipairs(hits) do
			local enemy = store.entities[damage.target_id]
			if damage.damage_applied > 0 and enemy and not enemy.pending_removal and not enemy.health.dead and
				enemy.health.hp > 0 and enemy.health.hp < enemy.health.hp_max * b.execute_ratio and
				band(enemy.vis.bans, F_INSTAKILL) == 0 then
				queue_damage(store, E:assign_damage(DAMAGE_INSTAKILL, 0, b.source_id or this.id, enemy.id))
			end
		end
	end
	queue_remove(store, this)
end

do -- ice_cooler
local U, SU = dove43_U, dove43_SU
local game_scripts = scripts
local cfg = scripts.dove43_config["ice_cooler"]


local v = V.v

local band = bit.band

local ICECREAM_FRAMES = {"d43_ice_cooler_asst_icecream_cian", "d43_ice_cooler_asst_icecream_pink", "d43_ice_cooler_asst_icecream_green"}
local ICECREAM_FX = {"fx_ice_cooler_explosion_cian", "fx_ice_cooler_explosion_pink", "fx_ice_cooler_explosion_green"}
local FAN_TPLS = {"soldier_ice_cooler_fan_cyan", "soldier_ice_cooler_fan_pink", "soldier_ice_cooler_fan_green"}

local SHOOT_OFFSETS = {
	attack = v(19.6, 79.1),
	attackUp = v(9.5, 81.8),
	attackDiagonalUp = v(17.7, 88.2),
	attackDown = v(10.2, 76.8)
}

local OUT_ANIMS = {
	attack = "attackOut",
	attackUp = "attackUpout",
	attackDiagonalUp = "attackDiagonalUpOut",
	attackDown = "attackDownOut"
}

local function fts(t)
	return t / 30
end

local function queue_damage(store, damage)
	store.damage_queue[#store.damage_queue + 1] = damage
end

local function tpos(e)
	return e.tower and e.tower.range_offset and V.v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or e.pos
end

local function direction_for_angle(angle)
	local deg = km.unroll(angle) * 180 / math.pi

	if deg >= 75 and deg < 105 then
		return "attackUp", false
	elseif deg >= 225 and deg < 315 then
		return "attackDown", false
	elseif (deg >= 15 and deg < 75) or (deg >= 105 and deg < 165) then
		return "attackDiagonalUp", deg > 90
	else
		return "attack", deg > 90 and deg < 270
	end
end

local function idle_name_for_direction(dir)
	if dir == "attackUp" or dir == "attackDiagonalUp" then
		return "idleUp"
	end
	return "idle"
end

scripts.enemy_ice_cooler_snowman = {}

function scripts.enemy_ice_cooler_snowman.update(this, store)
	U.y_animation_play(this, "in", nil, store.tick_ts, 1)

	local s = this.render.sprites[1]
	s.name = "idle"
	s.frame_idx = 1

	game_scripts.enemy_passive.update(this, store)
end

scripts.mod_ice_cooler_polymorph = {}

function scripts.mod_ice_cooler_polymorph.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or not target.enemy then
		return false
	end

	if U.flag_has(target.vis.bans or 0, F_POLYMORPH) or U.flag_has(target.vis.flags, this.modifier.vis_bans) then
		return false
	end

	if this.party_chance then
		local seq = store._ic_party_seq
		local judged_map = store._ic_party_judged

		if not seq or not this.modifier._party_seq or this.modifier._party_seq ~= seq then
			this.modifier._party_seq = seq
			judged_map = judged_map or {}
			store._ic_party_judged = judged_map
		end

		local tid = target.id

		if judged_map[tid] then
			return false
		end

		judged_map[tid] = true

		if math.random() >= this.party_chance then
			return false
		end
	end

	target.vis.bans = U.flag_set(target.vis.bans or 0, F_POLYMORPH)

	this.target_ref = target

	for _, s in ipairs(target.render.sprites) do
		s.hidden = true
	end

	SU.remove_modifiers(store, target, nil, "mod_ice_cooler_polymorph")
	SU.remove_auras(store, target)
	simulation:queue_remove_entity(target)
	U.unblock_all(store, target)

	target.health.dead = true

	if target.ui then
		target.ui.can_click = false
	end

	if target.main_script then
		target.main_script.co = nil
		target.main_script.runs = 0
	end

	if target.count_group then
		target.count_group.in_limbo = true
	end

	target.trigger_deselect = true

	local snowman = E:create_entity("enemy_ice_cooler_snowman")

	snowman.pos = V.vclone(target.pos)
	snowman.nav_path = target.nav_path
	this.snapshot_hp = target.health.hp
	snowman.health.hp_max = target.health.hp * (type(this.entity_hp) == "table" and this.entity_hp[this.modifier.level] or this.entity_hp)
	snowman.health.hp = snowman.health.hp_max
	snowman.health.armor = 0
	snowman.health.magic_armor = 0
	snowman.health.patched = target.health.patched
	snowman.enemy.gold = target.enemy.gold

	simulation:queue_insert_entity(snowman)

	this.snowman_ref = snowman

	S:queue(this.sound_transform)

	local sfx = E:create_entity(this.transform_fx)

	sfx.pos = v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
	sfx.render.sprites[1].ts = store.tick_ts

	simulation:queue_insert_entity(sfx)

	return true
end

function scripts.mod_ice_cooler_polymorph.update(this, store)
	local m = this.modifier
	local target = this.target_ref

	if not target then
		simulation:queue_remove_entity(this)

		return
	end

	m.ts = store.tick_ts
	this.pos = target.pos

	while true do
		if m.duration >= 0 and store.tick_ts - m.ts > m.duration then
			simulation:queue_remove_entity(this)

			return
		end

		coroutine.yield()
	end
end

function scripts.mod_ice_cooler_polymorph.remove(this, store)
	local target = this.target_ref
	local snowman = this.snowman_ref

	if target and snowman and store.entities[snowman.id] and not snowman.health.dead then
		for _, s in ipairs(target.render.sprites) do
			s.hidden = false
			s.hidden_count = 0
		end

		target.main_script.runs = 1

		if target.ui then
			target.ui.can_click = true
		end

		target.pos = V.vclone(snowman.pos)
		target.health.dead = false
		target.health.patched = snowman.health.patched
		target.health.hp = this.snapshot_hp * snowman.health.hp / snowman.health.hp_max

		target.unit.stun_count = 0
		target.unit.is_stunned = nil
		target.enemy.can_do_magic = true
		target.enemy.can_accept_magic = true

		if target.silence_cast_count then
			target.silence_cast_count = 0
		end

		if target.health_bar then
			target.health_bar.hidden = nil
		end

		if target.count_group then
			target.count_group.in_limbo = nil
		end

		target.vis.bans = U.flag_clear(target.vis.bans, F_POLYMORPH)

		target.nav_path = snowman.nav_path

		simulation:queue_insert_entity(target)

		snowman.trigger_deselect = true

		S:queue(this.sound_transform)

		local sfx = E:create_entity(this.transform_fx)

		sfx.pos = v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
		sfx.render.sprites[1].ts = store.tick_ts

		simulation:queue_insert_entity(sfx)
		simulation:queue_remove_entity(snowman)
	end

	return true
end

scripts.soldier_ice_cooler_fan = {}

function scripts.soldier_ice_cooler_fan.update(this, store)
	
	if this.vis._bans_added then
		U.bans_remove(this.vis, F_ALL)
		this.vis._bans_added = nil
	end

	this.reinforcement.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts
	this.nav_rally.pos = V.vclone(this.fan_rally_pos or this.pos)
	this.nav_rally.center = this.fan_rally_center or this.nav_rally.pos

	do
		local target = SU.soldier_pick_melee_target(store, this)
		if target then
			U.block_enemy(store, this, target)
			local slot_pos, _, _ = U.melee_slot_position(this, target)
			if slot_pos then
				U.set_destination(this, slot_pos)
			end
		end
	end

	U.y_animation_play(this, "indash", nil, store.tick_ts, 1)

	local starting_pos = V.vclone(this.nav_rally.pos)
	local patrol_pos = V.vclone(this.pos)

	patrol_pos.x, patrol_pos.y = patrol_pos.x + this.patrol_pos_offset.x, patrol_pos.y + this.patrol_pos_offset.y

	local nearest_node = P:nearest_nodes(patrol_pos.x, patrol_pos.y, nil, nil, false)[1]
	local pi, spi, ni = unpack(nearest_node)
	local npos = P:node_pos(pi, spi, ni)
	local patrol_pos_2 = V.vclone(this.pos)

	patrol_pos_2.x, patrol_pos_2.y = patrol_pos_2.x - this.patrol_pos_offset.x, patrol_pos_2.y - this.patrol_pos_offset.y

	nearest_node = P:nearest_nodes(patrol_pos_2.x, patrol_pos_2.y, nil, nil, false)[1]
	pi, spi, ni = unpack(nearest_node)
	local npos_2 = P:node_pos(pi, spi, ni)

	if V.dist2(patrol_pos.x, patrol_pos.y, npos.x, npos.y) > V.dist2(patrol_pos_2.x, patrol_pos_2.y, npos_2.x, npos_2.y) then
		patrol_pos = V.vclone(patrol_pos_2)
	end

	this.nav_rally.pos = starting_pos

	local idle_ts = store.tick_ts
	local patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)

	while true do
		if this.health.dead or (this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration) then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end

			this.health.hp = 0

			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)

			idle_ts = store.tick_ts
			patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)
		else
			local brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)

			if brk or sta == A_DONE or sta == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
				idle_ts = store.tick_ts
				patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)
			elseif SU.soldier_go_back_step(store, this) then
			else
				SU.soldier_idle(store, this)
				SU.soldier_regen(store, this)

				if patrol_cd < store.tick_ts - idle_ts then
					if this.nav_rally.pos == starting_pos then
						this.nav_rally.pos = patrol_pos
					else
						this.nav_rally.pos = starting_pos
					end

					idle_ts = store.tick_ts
					patrol_cd = math.random(this.patrol_min_cd, this.patrol_max_cd)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.tower_ice_cooler = {}

function scripts.tower_ice_cooler.get_info(this)
	local o = game_scripts.tower_common.get_info(this)

	local b = E:get_template("ice_cooler_breath_bullet").bullet
	o.damage_min = math.ceil(b.damage_min * this.tower.damage_factor)
	o.damage_max = math.ceil(b.damage_max * this.tower.damage_factor)
	o.damage_type = DAMAGE_MAGICAL

	return o
end

function scripts.tower_ice_cooler.update(this, store)
	local tower_sid = this.render.sid_tower
	local shooter_sid = this.render.sid_shooter
	local tw = this.tower
	local a = this.attacks
	local aa = a.list[1]
	local pa = a.list[2]
	local fa = a.list[3]
	local pow_p = this.powers.party
	local pow_fl = this.powers.flavors
	local pow_f = this.powers.fans

	aa.ts = store.tick_ts
	pa.ts = store.tick_ts
	fa.ts = store.tick_ts

	U.animation_start(this, "idle", false, store.tick_ts, true, shooter_sid)

	while true do
		if tw.blocked then
		else
			if pow_p.changed then
				pow_p.changed = nil
			end

			if pow_fl.changed then
				pow_fl.changed = nil
			end

			if pow_f.changed then
				pow_f.changed = nil

				fa.cooldown = cfg.fans_cooldown[pow_f.level]
			end

			local body_prefix

			if pow_fl.level > 0 and pow_f.level > 0 then
				body_prefix = "d43_icecooler_tower_skillab"
			elseif pow_fl.level > 0 then
				body_prefix = "d43_icecooler_tower_skilla"
			elseif pow_f.level > 0 then
				body_prefix = "d43_icecooler_tower_skillb"
			else
				body_prefix = "d43_icecooler_tower"
			end

			if this.render.sprites[tower_sid].prefix ~= body_prefix then
				this.render.sprites[tower_sid].prefix = body_prefix

				U.animation_start(this, "idle", false, store.tick_ts, true, tower_sid)
			end

			if U.tower_ready_to_use_power(pow_f, fa, store, tw) then
				local any_enemy = U.find_foremost_enemy_in_range_filter_off(tpos(this), a.range, false, fa.vis_flags, fa.vis_bans)

				if any_enemy then
					fa.ts = store.tick_ts

					U.animation_start(this, "runSkillB", false, store.tick_ts, false, tower_sid)

					local pred_pos = P:node_pos(any_enemy.nav_path.pi, any_enemy.nav_path.spi, any_enemy.nav_path.ni)

					for i = 1, cfg.fans_count do
						local fan = E:create_entity(FAN_TPLS[math.random(1, 3)])

						local rally_pos, rally_center = U.rally_formation_position(i, {rally_pos = V.vclone(pred_pos), rally_radius = 30}, cfg.fans_count)
						local spawn_pos = U.get_nearest_valid_rally_pos(rally_pos) or pred_pos

						fan.pos = v(spawn_pos.x + math.random(-5, 5), spawn_pos.y + math.random(-5, 5))
						fan.fan_rally_pos = V.vclone(fan.pos)
						fan.fan_rally_center = rally_center
						fan.health.hp_max = type(pow_f.hp) == "table" and pow_f.hp[pow_f.level] or pow_f.hp
						fan.health.hp = fan.health.hp_max
						fan.reinforcement.duration = type(cfg.fans_duration) == "table" and cfg.fans_duration[pow_f.level] or cfg.fans_duration

						SU.soldier_inherit_tower_buff_factor(fan, this, store.tick_ts)
						fan.source_id = this.id

						simulation:queue_insert_entity(fan)

						U.y_wait_unconditional(store, 0.2)
					end

					while not U.animation_finished(this, tower_sid) do
						coroutine.yield()
					end

					U.animation_start(this, "idle", false, store.tick_ts, true, tower_sid)
				else
					fa.ts = fa.ts + fts(5)
				end
			end

			if U.tower_ready_to_use_power(pow_p, pa, store, tw) then
				local enemy = U.find_random_enemy(store.entities, tpos(this), 0, a.range, pa.vis_flags, pa.vis_bans)

				if enemy then
					pa.ts = store.tick_ts

					S:queue("d43_ice_cooler_party_throw")

					local last_an = "shootDown"

					for i = 1, cfg.party_count do
						enemy = U.find_random_enemy(store.entities, tpos(this), 0, a.range, pa.vis_flags, pa.vis_bans)

						if not enemy then
							break
						end

						local an = enemy.pos.y > this.pos.y and "shootUp" or "shootDown"
						local p_flip = enemy.pos.x < this.pos.x

						last_an = an
						this.ice_cooler_shooter_flip = p_flip

						U.animation_start(this, an, p_flip, store.tick_ts, false, shooter_sid)

						local bullet = E:create_entity("ice_cooler_icecream")
						local b = bullet.bullet
	b.from, b.to = v(0, 0), v(0, 0)
						local start_off = an == "shootUp" and v(10, 71) or v(10, 67)
						local ffe = U.calculate_enemy_ffe_pos(enemy, 0.6)

						b.from.x = this.pos.x + start_off.x
						b.from.y = this.pos.y + start_off.y
						b.to.x = ffe.x + enemy.unit.hit_offset.x + (math.random() - 0.5) * 30
						b.to.y = ffe.y + enemy.unit.hit_offset.y + (math.random() - 0.5) * 20
						b.source_id = this.id
						b.damage_factor = tw.damage_factor

						if pow_fl.level > 0 then
						if not this._ic_last_party_ts or store.tick_ts - this._ic_last_party_ts > 1 then
							this._ic_last_party_ts = store.tick_ts
							store._ic_party_seq = (store._ic_party_seq or 0) + 1
							store._ic_party_judged = {}
						end
						b.mods = {"mod_ice_cooler_freeze", "mod_ice_cooler_party_polymorph_" .. pow_fl.level}
					end

						bullet.pos.x, bullet.pos.y = b.from.x, b.from.y

						local ci = math.random(1, 3)

						bullet.render.sprites[1].name = ICECREAM_FRAMES[ci]
						b.hit_fx = ICECREAM_FX[ci]

						simulation:queue_insert_entity(bullet)

						U.y_wait_unconditional(store, 0.1)
					end

					U.animation_start(this, last_an == "shootUp" and "idleUp" or "idle", this.ice_cooler_shooter_flip, store.tick_ts, true, shooter_sid)
				else
					pa.ts = pa.ts + fts(5)
				end
			end

			if store.tick_ts - aa.ts <= aa.cooldown * tw.cooldown_factor then
			else
				local enemy = U.find_foremost_enemy_in_range_filter_off(tpos(this), a.range, false, aa.vis_flags, aa.vis_bans)

				if enemy then
					aa.ts = store.tick_ts

					local shooter_offset_y = this.render.sprites[shooter_sid].offset.y
					local pred_pos = v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)

					local function current_direction()
						local tx, ty = V.sub(pred_pos.x, pred_pos.y, this.pos.x, this.pos.y + shooter_offset_y)

						return direction_for_angle(km.unroll(V.angleTo(tx, ty)))
					end

					local dir, flip = current_direction()

					this.ice_cooler_shooter_flip = flip

					U.animation_start(this, dir .. "In", flip, store.tick_ts, false, shooter_sid)

					S:queue("d43_ice_cooler_shoot_" .. math.random(1, 3))

					U.y_animation_wait(this, shooter_sid)

					U.animation_start(this, dir .. "Loop", flip, store.tick_ts, true, shooter_sid)

					this.ice_cooler_breath_fx = E:create_entity("fx_ice_cooler_breath")

					local fx = this.ice_cooler_breath_fx

					fx.pos = v(this.pos.x, this.pos.y)
					fx.render.sprites[1].ts = store.tick_ts
					fx.render.sprites[1].hidden = true

					simulation:queue_insert_entity(fx)
					U.y_animation_play(fx, "in", false, store.tick_ts)
					U.animation_start_default(fx, "travel", false, store.tick_ts, true)

					local fire_ts = store.tick_ts
					local fire_cycle_ts = store.tick_ts - 0.3
					local judged = {}
					local breath_bullet = E:get_template("ice_cooler_breath_bullet").bullet
					local breath_mods = {}
					if breath_bullet.mod then breath_mods[#breath_mods + 1] = breath_bullet.mod end
					if breath_bullet.mods then
						for _, m in ipairs(breath_bullet.mods) do
							breath_mods[#breath_mods + 1] = m
						end
					end

					while store.tick_ts - fire_ts < 1.2 do
						if not enemy or not enemy.health or enemy.health.dead then
							enemy = U.find_foremost_enemy_in_range_filter_off(tpos(this), a.range, false, aa.vis_flags, aa.vis_bans)

							if enemy then
								pred_pos.x = enemy.pos.x + enemy.unit.hit_offset.x
								pred_pos.y = enemy.pos.y + enemy.unit.hit_offset.y
							end
						else
							pred_pos.x = enemy.pos.x + enemy.unit.hit_offset.x
							pred_pos.y = enemy.pos.y + enemy.unit.hit_offset.y
						end

						local n_dir, n_flip = current_direction()

						if n_dir ~= dir or n_flip ~= flip then
							dir, flip = n_dir, n_flip
							this.ice_cooler_shooter_flip = flip

							U.animation_start(this, dir .. "Loop", flip, store.tick_ts, true, shooter_sid)
						end

						local shoot_off = flip and v(-SHOOT_OFFSETS[dir].x, SHOOT_OFFSETS[dir].y) or SHOOT_OFFSETS[dir]
						local dist = V.dist(this.pos.x + shoot_off.x, this.pos.y + shoot_off.y, pred_pos.x, pred_pos.y)

						fx.pos.x = this.pos.x + shoot_off.x
						fx.pos.y = this.pos.y + shoot_off.y
						fx.render.sprites[1].r = V.angleTo(pred_pos.x - fx.pos.x, pred_pos.y - fx.pos.y)

						local ray_r = fx.render.sprites[1].r
						local org = tpos(this)
						local ray_len = a.range + (org.x - fx.pos.x) * math.cos(ray_r) + (org.y - fx.pos.y) * math.sin(ray_r)
						local visual_len = math.min(dist, ray_len)
						fx.render.sprites[1].scale = v(1.265625 * math.max(0.3, visual_len / 137), 1.265625)
						fx.render.sprites[1].hidden = false

						if store.tick_ts - fire_cycle_ts >= 0.3 then
							fire_cycle_ts = fire_cycle_ts + 0.3

							local tick_targets = U.find_enemies_around_line(fx.pos.x, fx.pos.y, fx.pos.x + math.cos(ray_r) * ray_len, fx.pos.y + math.sin(ray_r) * ray_len, cfg.breath_width, aa.vis_flags, aa.vis_bans)

							if tick_targets then
								for i = 1, #tick_targets do
									local t = tick_targets[i]

									if not t.health.dead then
										local d = E:assign_damage(DAMAGE_MAGICAL, math.random(breath_bullet.damage_min, breath_bullet.damage_max) / 4 * tw.damage_factor, this.id, t.id)

										d.hooks = breath_bullet.damage_hooks

										queue_damage(store, d)

										for _, mod_name in ipairs(breath_mods) do
											local mod = E:create_entity(mod_name)

											mod.modifier.target_id = t.id
											mod.modifier.source_id = this.id

											simulation:queue_insert_entity(mod)
										end

										if not judged[t.id] then
											judged[t.id] = true

											if pow_fl.level > 0 and math.random() < cfg.flavors_chance[pow_fl.level] then
												local mod = E:create_entity("mod_ice_cooler_polymorph")

												mod.modifier.level = pow_fl.level
												mod.modifier.target_id = t.id
												mod.modifier.source_id = this.id

												simulation:queue_insert_entity(mod)
											else
												local mod = E:create_entity("mod_ice_cooler_freeze")

												mod.modifier.target_id = t.id
												mod.modifier.source_id = this.id

												simulation:queue_insert_entity(mod)
											end
										else
											local mod = E:create_entity("mod_ice_cooler_freeze")

											mod.modifier.target_id = t.id
											mod.modifier.source_id = this.id

											simulation:queue_insert_entity(mod)
										end
									end
								end
							end
						end

						coroutine.yield()
					end

					S:queue("d43_ice_cooler_freeze")

					local decal_radius = cfg.breath_width * 1.4
					local decal_count = 4 + math.floor(decal_radius / 25)

					for i = 0, decal_count - 1 do
						local decal = E:create_entity("fx_ice_cooler_freeze_mark")
						local ang = i * math.pi * 2 / (decal_count - 1)
						local rr = i == 0 and 0 or decal_radius * 0.55 + (math.random() - 0.5) * 20

						decal.pos.x = pred_pos.x + math.cos(ang) * rr
						decal.pos.y = pred_pos.y + math.sin(ang) * rr
						decal.render.sprites[1].ts = store.tick_ts + math.random() * 0.15
						decal.render.sprites[1].flip_x = math.random() < 0.5

						simulation:queue_insert_entity(decal)
					end

					U.y_animation_play(fx, "out", false, store.tick_ts)
					simulation:queue_remove_entity(fx)
					this.ice_cooler_breath_fx = nil

					U.animation_start(this, OUT_ANIMS[dir], flip, store.tick_ts, false, shooter_sid)

					U.y_animation_wait(this, shooter_sid)

					U.animation_start(this, idle_name_for_direction(dir), this.ice_cooler_shooter_flip, store.tick_ts, true, shooter_sid)
				else
					aa.ts = aa.ts + 0.1
				end
			end
		end

		coroutine.yield()
	end
end

function scripts.tower_ice_cooler.remove(this, store)
	if this.ice_cooler_breath_fx then
		this.ice_cooler_breath_fx.render.sprites[1].hidden = true

		simulation:queue_remove_entity(this.ice_cooler_breath_fx)

		this.ice_cooler_breath_fx = nil
	end

	return true
end


end

do -- machine_gunner
local U, SU = dove43_U, dove43_SU
local game_scripts = scripts
local cfg = scripts.dove43_config["machine_gunner"]


local v = V.v
local vclone = V.vclone

local bor = bit.bor

local function fts(frames)
	return frames / FPS
end

local function tpos(e)
	if e.tower and e.tower.range_offset then
		return v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y)
	end
	return e.pos
end

local function target_hit_pos(target)
	local p = v(target.pos.x, target.pos.y)
	if target.unit and target.unit.hit_offset then
		p.x = p.x + target.unit.hit_offset.x
		p.y = p.y + target.unit.hit_offset.y
	end
	return p
end

local function angle_between(from, to)
	return math.deg(math.atan2(to.y - from.y, to.x - from.x)) % 360
end

local function facing_flip(a)
	return a > 90 and a < 270
end

local function zone_suffix(a)
	if a >= 75 and a < 105 then
		return "Up"
	elseif (a >= 45 and a < 75) or (a >= 105 and a < 135) then
		return "DiagUpA"
	elseif (a >= 16 and a < 45) or (a >= 135 and a < 165) then
		return "DiagUpB"
	elseif (a >= 165 and a < 196) or a >= 345 or a < 16 then
		return "Lateral"
	elseif (a >= 225 and a < 255) or (a >= 285 and a < 316) then
		return "DiagDownA"
	elseif (a >= 196 and a < 225) or (a >= 316 and a < 345) then
		return "DiagDownB"
	end

	return "Down"
end

local function shoot_name(a)
	return a < 180 and "shootUp" or "shootDown"
end

local function idle_name(a)
	return a < 180 and "idleUp" or "idleDown"
end

local function skill_name(a)
	return a < 180 and "skilladvancedUp" or "skilladvanced"
end

local function storm_name(a)
	return "bulletstorm" .. zone_suffix(a)
end

local MUZZLE = {
	{
		shoot = {
			{ { 20, 40 }, { 6, 35 } },
			{ { 31, 7 }, { 17, 2 } },
		},
		storm = {
			Up = { { 8, 42 }, { -6, 37 } },
			DiagUpA = { { 9, 38 }, { -5, 33 } },
			DiagUpB = { { 18, 34 }, { 4, 29 } },
			Lateral = { { 33, 19 }, { 19, 14 } },
			DiagDownB = { { 31, 11 }, { 17, 6 } },
			DiagDownA = { { 26, 2 }, { 12, -3 } },
			Down = { { 8, -6 }, { -6, -11 } },
		},
	},
	{
		shoot = {
			{ { 34, 40 } },
			{ { 51, 2 } },
		},
		storm = {
			Up = { { 1, 40 } },
			DiagUpA = { { 22, 46 } },
			DiagUpB = { { 28, 42 } },
			Lateral = { { 50, 16 } },
			DiagDownB = { { 49, 5 } },
			DiagDownA = { { 48, -1 } },
			Down = { { 13, -11 } },
		},
	},
}

local BOW_LAUNCH = { 31.25, 37.05 }

local RIPPLE_OFFSET = v(4, 6)

local function muzzle_x(m, flip, sp)
	local s = sp.scale.x

	return sp.offset.x + (flip and -1 or 1) * m[1] * s
end

local function muzzle_y(m, sp)
	return sp.offset.y + m[2] * sp.scale.y
end

local function bullet_template_scales(bb)
	local smin, smax = 1, 1

	if bb and bb._cfg_damage_min and bb._cfg_damage_min > 0 and bb.damage_min then
		smin = bb.damage_min / bb._cfg_damage_min
	end
	if bb and bb._cfg_damage_max and bb._cfg_damage_max > 0 and bb.damage_max then
		smax = bb.damage_max / bb._cfg_damage_max
	end

	return smin, smax
end

scripts.tower_machine_gunner = {}

function scripts.tower_machine_gunner.get_info(this)
	local aa = this.attacks.list[1]
	local bt = aa.bullet and E:get_template(aa.bullet)
	local dmin, dmax = 0, 0

	if bt and bt.bullet then
		dmin, dmax = bt.bullet.damage_min or 0, bt.bullet.damage_max or 0
	end

	local c = this.tower.tower_cfg or {}
	local medal = this.powers and this.powers.medal
	local mul, cooldown

	if medal and medal.level > 0 then
		mul = 1
		cooldown = c.medal_attack_cooldown or aa.cooldown
		local smin, smax = bullet_template_scales(bt and bt.bullet)

		if c.medal_attack_damage_min then
			dmin = c.medal_attack_damage_min * smin
		end
		if c.medal_attack_damage_max then
			dmax = c.medal_attack_damage_max * smax
		end
	else
		local volley = bt.bullet.volley_damage
		local _, max_scale = bullet_template_scales(bt.bullet)
		dmin, dmax = volley.damage_min, math.floor(volley.base_max * max_scale + 1e-8)
		mul = 1
		cooldown = aa.cooldown
	end

	local df = this.tower.damage_factor or 1

	return {
		type = STATS_TYPE_TOWER,
		damage_min = dmin * mul * df,
		damage_max = dmax * mul * df,
		damage_type = DAMAGE_PHYSICAL,
		range = this.attacks.range,
		cooldown = cooldown * (this.tower.cooldown_factor or 1),
	}
end

function scripts.tower_machine_gunner.update(this, store)
	local a = this.attacks
	local aa = this.attacks.list[1]
	local as = this.attacks.list[2]
	local ar = this.attacks.list[3]
	local tw = this.tower
	local sprites = this.render.sprites
	local sid = this.render.sid_shooter
	local sid_medal = this.render.sid_deco_medal
	local sid_arrow = this.render.sid_deco_arrow
	local tp = tpos(this)
	local pow_storm = this.powers.storm
	local pow_medal = this.powers.medal
	local pow_arrow = this.powers.arrow
	local seen_medal, seen_arrow = -1, -1

	local function cfg()
		return tw.tower_cfg
	end

	local function ready_attack(attack)
		local cd = attack.cooldown

		if attack == aa and pow_medal.level > 0 then
			cd = cfg().medal_attack_cooldown or cd
		end

		return store.tick_ts - attack.ts > cd * (tw.cooldown_factor or 1)
	end

	local function face_shot(name_of_angle, a)
		U.animation_start(this, name_of_angle(a), facing_flip(a), store.tick_ts, false, sid)
	end

	local last_angle

	local function idle_face(enemy)
		if enemy then
			local a = angle_between(tp, enemy.pos)

			last_angle = a
			U.animation_start(this, idle_name(a), facing_flip(a), store.tick_ts, true, sid)
		elseif last_angle then
			U.animation_start(this, idle_name(last_angle), facing_flip(last_angle), store.tick_ts, true, sid)
		else
			U.animation_start(this, "idle", false, store.tick_ts, true, sid)
		end
	end

	local function fire_bullet(bullet_name, enemy, dmin, dmax, mx, my, already_scaled)
		local b = E:create_entity(bullet_name)
		local bl = b.bullet
		bl.from, bl.to = v(0, 0), v(0, 0)
		local bt = E:get_template(bullet_name)
		local smin, smax = bullet_template_scales(bt and bt.bullet)

		bl.damage_min = already_scaled and dmin or dmin * smin
		bl.damage_max = already_scaled and dmax or dmax * smax
		bl.damage_factor = tw.damage_factor
		bl.target_id = enemy.id
		bl.source_id = this.id
		b.pos.x = this.pos.x + mx
		b.pos.y = this.pos.y + my
		bl.from.x, bl.from.y = b.pos.x, b.pos.y

		local hpos = target_hit_pos(enemy)

		bl.to.x, bl.to.y = hpos.x, hpos.y
		simulation:queue_insert_entity(b)
	end

	local function fire_volley(bullet_name, enemy, dmin, dmax, count, muzzles, flip)
		local sp = sprites[sid]

		for i = 1, count do
			local m = muzzles[((i - 1) % #muzzles) + 1]

			fire_bullet(bullet_name, enemy, dmin, dmax, muzzle_x(m, flip, sp), muzzle_y(m, sp))
		end
	end

	local last_ripple_ts = -math.huge

	local function fire_ripple()
		if store.tick_ts - last_ripple_ts < 0.4 then
			return
		end

		last_ripple_ts = store.tick_ts
		local fx = E:create_entity("fx_machine_gunner_ripple")

		fx.pos.x = this.pos.x + RIPPLE_OFFSET.x
		fx.pos.y = this.pos.y + RIPPLE_OFFSET.y
		fx.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(fx)
	end

	local function find_storm_target()
		return U.find_foremost_enemy(store.entities, tp, 0, a.range, false, as.vis_flags, as.vis_bans)
	end

	local function run_storm()
		local enemy = find_storm_target()

		if not enemy then
			return false
		end

		pow_storm.ts = store.tick_ts
		S:queue("d43_machine_gunner_skill")

		local c = cfg()
		local medal = pow_medal.level > 0
		local end_ts = store.tick_ts + c.storm_duration
		local shots = medal and (c.medal_storm_bullets or 1) or (c.storm_bullets or 2)
		local interval = (medal and (c.medal_storm_interval or c.storm_interval) or c.storm_interval) * (tw.cooldown_factor or 1)
		local factor = medal and (c.medal_storm_damage_factor or 2) or (c.storm_damage_factor or 1)
		local bmin = medal and (c.medal_attack_damage_min or c.attack_damage_min) or c.attack_damage_min
		local bmax = medal and (c.medal_attack_damage_max or c.attack_damage_max) or c.attack_damage_max
		local dmin, dmax = bmin * factor, bmax * factor

		while store.tick_ts < end_ts and not tw.blocked do
			enemy = U.detect_foremost_enemy_with_flying_preference_in_range_filter_off(tp, a.range, as.vis_flags, as.vis_bans)

			if not enemy then
				break
			end

			local ang = angle_between(tp, enemy.pos)
			local flip = facing_flip(ang)
			local mi = medal and 2 or 1
			local muzzles = MUZZLE[mi].storm[zone_suffix(ang)]

			last_angle = ang
			U.animation_start(this, storm_name(ang), flip, store.tick_ts, true, sid)
			fire_volley(as.bullet, enemy, dmin, dmax, shots, muzzles, flip)
			fire_ripple()
			U.y_wait_unconditional(store, interval)
		end

		idle_face(find_storm_target())

		return true
	end

	local function arrow_range()
		local base = cfg().attack_range

		if not base or base <= 0 then
			return ar.range
		end

		return ar.range * (a.range / base)
	end

	local function fire_arrows(m, flip)
		local c = cfg()
		local lvl = pow_arrow.level
		local count = ar.per_level_count[lvl] or 1
		local arng = arrow_range()
		local targets = U.find_enemies_in_range_filter_off(tp, arng, ar.vis_flags, ar.vis_bans)
		local sp = sprites[sid]
		local mx = muzzle_x(m, flip, sp)
		local my = muzzle_y(m, sp)

		if not targets or #targets == 0 then
			return false
		end

		for i = 1, count do
			local t = targets[(i - 1) % #targets + 1]
			local b = E:create_entity(ar.bullet)
			local bl = b.bullet
		bl.from, bl.to = v(0, 0), v(0, 0)
			local hpos = target_hit_pos(t)

			bl.level = lvl
			bl.damage_factor = tw.damage_factor
			bl.target_id = t.id
			bl.source_id = this.id

			local u = UP:get_upgrade("archer_precision")

			if u and math.random() < u.chance then
				bl.damage_min = bl.damage_min * u.damage_factor
				bl.damage_max = bl.damage_max * u.damage_factor
				bl.pop = { "pop_crit" }
				bl.pop_conds = DR_DAMAGE
			end
			b.pos.x = this.pos.x + mx + (i - (count + 1) * 0.5) * 6
			b.pos.y = this.pos.y + my
			bl.from.x, bl.from.y = b.pos.x, b.pos.y
			bl.to.x, bl.to.y = hpos.x, hpos.y

			local dist = V.dist(bl.from.x, bl.from.y, bl.to.x, bl.to.y)

			bl.flight_time = bl.flight_time_min + dist / arng * bl.flight_time_factor
			simulation:queue_insert_entity(b)
		end

		return true
	end

	local function find_arrow_target()
		return U.find_foremost_enemy(store.entities, tp, 0, arrow_range(), false, ar.vis_flags, ar.vis_bans)
	end

	aa.ts = store.tick_ts
	ar.ts = store.tick_ts

	if not pow_storm.ts then
		pow_storm.ts = store.tick_ts
	end

	while true do
		if tw.blocked then
			idle_face(nil)
			coroutine.yield()
		else
			local ml = pow_medal.level

			if ml ~= seen_medal then
				seen_medal = ml
				sprites[sid_medal].hidden = ml == 0

				local new_prefix = ml > 0 and "d43_shooter_machinegunner_basic" or "d43_shooter_machinegunner"

				if sprites[sid].prefix ~= new_prefix then
					sprites[sid].prefix = new_prefix
					U.animation_start(this, "idle", false, store.tick_ts, true, sid)
				end
			end

			local al = pow_arrow.level

			if al ~= seen_arrow then
				seen_arrow = al
				sprites[sid_arrow].hidden = al == 0
				ar.disabled = al == 0

				if al > 0 then
					ar.cooldown = ar.per_level_cooldown[al] or ar.cooldown
					ar.ts = store.tick_ts
				end
			end

			if pow_storm.level > 0 and U.tower_ready_to_use_power(pow_storm, pow_storm, store, tw) then
				run_storm()
			end

			if not ar.disabled and ready_attack(ar) then
				local enemy = find_arrow_target()

				if not enemy then
					ar.ts = ar.ts + fts(5)
				else
					local a = angle_between(tp, enemy.pos)
					local flip = facing_flip(a)

					face_shot(skill_name, a)
					U.y_wait_unconditional(store, ar.shoot_time * (tw.cooldown_factor or 1))

					if fire_arrows(BOW_LAUNCH, flip) then
						ar.ts = store.tick_ts
					end

					U.y_animation_wait(this, sid)

					idle_face(find_arrow_target())
				end
			end

			if ready_attack(aa) then
				local enemy = U.find_foremost_enemy(store.entities, tp, 0, a.range, false, aa.vis_flags, aa.vis_bans)

				if not enemy then
					aa.ts = aa.ts + fts(5)
					idle_face(nil)
				elseif pow_medal.level > 0 then
					aa.ts = store.tick_ts

					local c = cfg()
					local ang = angle_between(tp, enemy.pos)
					local flip = facing_flip(ang)

					last_angle = ang
					U.animation_start(this, shoot_name(ang), flip, store.tick_ts, true, sid)

					enemy = U.detect_foremost_enemy_with_flying_preference_in_range_filter_off(tp, a.range, aa.vis_flags, aa.vis_bans)

					if enemy then
						fire_volley(aa.bullet, enemy, c.medal_attack_damage_min or c.attack_damage_min, c.medal_attack_damage_max or c.attack_damage_max, 1, MUZZLE[2].shoot[ang < 180 and 1 or 2], flip)
					else
						idle_face(nil)
					end
				else
					aa.ts = store.tick_ts

					local c = cfg()
					local burst = #(c.attack_burst_weight or { 1 })
					local bullets = c.attack_bullets or 1
					local volley = E:get_template(aa.bullet).bullet.volley_damage
					local _, max_scale = bullet_template_scales(E:get_template(aa.bullet).bullet)
					local volley_max = math.floor(volley.base_max * max_scale + 1e-8)
					local total_weight, used_weight = 0, 0
					for _, weight in ipairs(c.attack_burst_weight or {1}) do total_weight = total_weight + weight * bullets end

					for i = 1, burst do
						local ang = angle_between(tp, enemy.pos)
						local w = c.attack_burst_weight[i] or 1

						last_angle = ang
						face_shot(shoot_name, ang)
						U.y_wait_unconditional(store, aa.shoot_time * (tw.cooldown_factor or 1))

						enemy = U.detect_foremost_enemy_with_flying_preference_in_range_filter_off(tp, a.range, aa.vis_flags, aa.vis_bans)

						if enemy then
							local muzzles = MUZZLE[1].shoot[ang < 180 and 1 or 2]
							local flip = facing_flip(ang)
							local sp = sprites[sid]
							for shot = 1, bullets do
								local previous = used_weight
								used_weight = used_weight + w
								local dmin = math.floor(volley.damage_min * used_weight / total_weight + 1e-8) - math.floor(volley.damage_min * previous / total_weight + 1e-8)
								local dmax = math.floor(volley_max * used_weight / total_weight + 1e-8) - math.floor(volley_max * previous / total_weight + 1e-8)
								local muzzle = muzzles[(shot - 1) % #muzzles + 1]
								fire_bullet(aa.bullet, enemy, dmin, dmax, muzzle_x(muzzle, flip, sp), muzzle_y(muzzle, sp), true)
							end
						end

						if i < burst then
							U.y_wait_unconditional(store, c.attack_burst_interval * (tw.cooldown_factor or 1))

							if not enemy then
								enemy = U.find_foremost_enemy(store.entities, tp, 0, a.range, false, aa.vis_flags, aa.vis_bans)
							end

							if not enemy then
								break
							end
						end
					end

					idle_face(enemy)
				end
			end

			coroutine.yield()
		end
	end
end

scripts.aura_machine_gunner_burst = {}

function scripts.aura_machine_gunner_burst.update(this, store)
	local a = this.aura
	local source = store.entities[this.source_id]

	if source and source.bullet then
		a.level = source.bullet.level
	end

	local target = this.target_id and store.entities[this.target_id]
	local hit_pos = vclone(this.pos)

	if target then
		hit_pos.x, hit_pos.y = target.pos.x, target.pos.y
	end

	local lvl = a.level or 1
	local dmin = a.per_level_damage_min[lvl] or a.per_level_damage_min[1]
	local dmax = a.per_level_damage_max[lvl] or a.per_level_damage_max[1]
	local df = (source and source.bullet and source.bullet.damage_factor) or 1
	local targets = U.find_enemies_in_range_filter_off(hit_pos, a.radius, a.vis_flags, a.vis_bans)

	if targets then
		for _, enemy in ipairs(targets) do
			local d = E:assign_damage(a.damage_type, math.random(dmin, dmax) * df, this.id, enemy.id)

			store.damage_queue[#store.damage_queue + 1] = d
		end
	end

	U.y_animation_play(this, nil, nil, store.tick_ts, 1)
	simulation:queue_remove_entity(this)
end


end
-- END DOVE43 BUILTIN TOWERS
-- BEGIN DOVE43 EXTRA TOWERS
do
local E = require("entity_db")
local S = require("sound_db")
local UP = require("upgrades")
local GR = require("grid_db")
local V = require("klua.vector")
local v, vclone = V.v, V.vclone
local bit = require("bit")
local bor, band = bit.bor, bit.band
local native_SU = require("script_utils_123")
local native_U = require("utils_123")
local U = setmetatable({}, {__index = scripts.dove43_utils})
local extra_SU = setmetatable({}, {__index = native_SU})
local SU = extra_SU

function U.find_biggest_enemy_in_range_filter_off(pos, range, flags, bans, filter)
    local enemies = U.find_enemies_in_range_filter_off(pos, range, flags, bans)
    local best
    for _, enemy in ipairs(enemies or {}) do
        if (not filter or filter(enemy)) and (not best or enemy.health.hp_max > best.health.hp_max) then
            best = enemy
        end
    end
    return best
end
U.find_biggest_enemy_in_range_filter_on = U.find_biggest_enemy_in_range_filter_off
U.find_foremost_enemy_in_range_filter_on = U.find_foremost_enemy_in_range_filter_off
function U.find_enemies_in_range_filter_off_consider_hit_offset(pos, radius, flags, bans)
    return U.find_enemies_in_range_filter_off(pos, radius, flags, bans)
end
function extra_SU.create_bullet_damage_without_pops(bullet, target_id, source_id)
    local damage = native_SU.create_bullet_damage(bullet, target_id, source_id)
    damage.pop, damage.pop_chance, damage.pop_conds = nil, nil, nil
    return damage
end
extra_SU.create_bullet_damage_without_pops_and_value = extra_SU.create_bullet_damage_without_pops
local function valid_possession_target(target, store)
    return target and target.enemy and target.nav_path and target.melee and target.health
        and not target.health.dead and not target._possession_skill_active
        and not native_U.has_modifiers(store, target, "mod_possession_skill")
end

do
local cfg = {["attack_radius"]=75,["attack_cooldown"]=3.3,["attack_damage_min"]=68,["attack_damage_max"]=112,["precision_cooldown"]={20,18,15},["precision_damage_min"]={110,160,210},["precision_damage_max"]={183,258,333},["precision_radius"]=50,["drone_range"]=130,["drone_cooldown"]=1.5,["drone_damage_min"]=38,["drone_damage_max"]=72,["drone_detect_range"]=200,["drone_leash_range"]=80,["drone_move_speed"]=150,["slow_radius"]=75,["slow_factor"]={0.85,0.7}}
local function queue_damage(store, d)
	store.damage_queue[#store.damage_queue + 1] = d
end
local DRONE_HOVER = {0, 95}
local SLOW_FX_REF_RADIUS = 60
local FX_BASE_SCALE = 1.265625
local BOMB_FX_REF_RADIUS = 65
local BOMB_FX_SCALE = 0.9
local MUZZLE_OFFSET = {-5, 36}
local LAUNCH_OFFSET = {9, 140}
local SKY_HEIGHT = 700
local SHOOT_FRAMES = 53
local ACTION_FRAME = 34
local RISE_TIME = 0.6
local WEAPON_IN_FRAMES = 54
local WEAPON_SHOOT_FRAMES = 24
local function queue_insert(e)
	simulation:queue_insert_entity(e)
end
local function queue_remove(e)
	simulation:queue_remove_entity(e)
end
local function anim_start(this, name, loop, sid, ts)
	U.animation_start(this, name, nil, ts, loop, sid, true)
end
local function hit_pos(target)
	local p = v(target.pos.x, target.pos.y)
	if target.unit and target.unit.hit_offset then
		p.x = p.x + target.unit.hit_offset.x
		p.y = p.y + target.unit.hit_offset.y
	end
	return p
end
local function skill_state(a, b)
	return (a and 1 or 0) + (b and 2 or 0) + 1
end
local function scale_explosion_fx(name, factor)
	local tpl = E:get_template(name)
	if tpl and tpl.render and tpl.render.sprites and tpl.render.sprites[1] then
		tpl.render.sprites[1].scale = v(factor, factor)
	end
end
scripts.tower_blastin_bullriders = {}
local function set_skill_sprites(this, store, state)
	for i = 1, 4 do
		this.render.sprites[this.bullriders_body_ids[i]].hidden = i ~= state
		this.render.sprites[this.bullriders_weapon_ids[i]].hidden = i ~= state
	end
	this._body_sid = this.bullriders_body_ids[state]
	this._weapon_sid = this.bullriders_weapon_ids[state]
	anim_start(this, "idle", true, this._body_sid, store.tick_ts)
	local wname, wloop = "idle", true
	if this._weapon_state == "ready" then
		wname = "idle_with_missile"
	elseif this._weapon_state == "reload" then
		wname, wloop = "in", false
	elseif this._weapon_state == "shoot" then
		wname, wloop = "shoot", false
	end
	anim_start(this, wname, wloop, this._weapon_sid, store.tick_ts)
end
local function set_flag_state(this, store, electrified)
	this.render.sprites[this.bullriders_flag_id].hidden = electrified
	this.render.sprites[this.bullriders_flag_decal_id].hidden = electrified
	this.render.sprites[this.bullriders_flag_b_id].hidden = not electrified
	this.render.sprites[this.bullriders_flag_decal_b_id].hidden = not electrified
	this.render.sprites[this.bullriders_slow_fx_id].hidden = not electrified
	this.render.sprites[this.bullriders_slow_ring_id].hidden = not electrified
	if electrified then
		anim_start(this, "in", false, this.bullriders_flag_b_id, store.tick_ts)
		anim_start(this, "in", false, this.bullriders_flag_decal_b_id, store.tick_ts)
		anim_start(this, "in", false, this.bullriders_slow_ring_id, store.tick_ts)
		this._flag_loop = "idle"
	else
		anim_start(this, "in", false, this.bullriders_flag_id, store.tick_ts)
		anim_start(this, "in", false, this.bullriders_flag_decal_id, store.tick_ts)
		this._flag_loop = "Idle"
	end
	this._flag_in = true
end
local function spawn_drones(this)
	local drone = E:create_entity("drone_bullriders")
	drone.pos.x = this.pos.x + DRONE_HOVER[1]
	drone.pos.y = this.pos.y + DRONE_HOVER[2]
	drone.owner = this
	queue_insert(drone)
	this.bullriders_drones = {drone}
end
local function remove_drones(this)
	if not this.bullriders_drones then
		return
	end
	for _, d in ipairs(this.bullriders_drones) do
		queue_remove(d)
	end
	this.bullriders_drones = nil
end
local function apply_slow_fx_scale(this, radius)
	local k = FX_BASE_SCALE * radius / SLOW_FX_REF_RADIUS
	this.render.sprites[this.bullriders_slow_fx_id].scale = v(k, k)
	this.render.sprites[this.bullriders_slow_ring_id].scale = v(k, k)
end
local function sync_slow_radius(this)
	local radius = cfg.slow_radius * (this.attacks.range / cfg.attack_radius)
	if this._slow_radius == radius then
		return
	end
	this._slow_radius = radius
	if this.bullriders_slow_aura then
		this.bullriders_slow_aura.aura.radius = radius
	end
	apply_slow_fx_scale(this, radius)
end
scripts.tower_blastin_bullriders.sync_slow_radius = sync_slow_radius
local function ensure_slow_aura(this, store)
	if this.bullriders_slow_aura then
		return
	end
	local aura = E:create_entity("aura_bullriders_slow")
	aura.pos.x, aura.pos.y = this.barrack.rally_pos.x, this.barrack.rally_pos.y
	aura.aura.source_id = this.id
	aura.aura.ts = store.tick_ts
	aura.aura.mod = this.powers.buying_time.level >= 2 and "mod_bullriders_slow_2" or "mod_bullriders_slow_1"
	this.bullriders_slow_aura = aura
	queue_insert(aura)
end
local function remove_slow_aura(this)
	if this.bullriders_slow_aura then
		queue_remove(this.bullriders_slow_aura)
		this.bullriders_slow_aura = nil
	end
end
function scripts.tower_blastin_bullriders.insert(this, store)
	local b = this.barrack
	if not b.rally_pos or (b.rally_pos.x == 0 and b.rally_pos.y == 0) then
		local p = U.get_nearest_valid_rally_pos(v(this.pos.x, this.pos.y + 40))
		p = p or v(this.pos.x, this.pos.y + 40)
		b.rally_pos = vclone(p)
		this.tower.default_rally_pos = vclone(p)
	end
	for _, s in ipairs(this.render.sprites) do
		if s.exo then
			s.ts = store.tick_ts
		end
	end
	this.attacks.list[1].ts = store.tick_ts
	this.powers.precision.ts = store.tick_ts
	this.powers.double_trouble.ts = store.tick_ts
	this.powers.buying_time.ts = store.tick_ts
	this._state = -1
	this._precision_level = -1
	this._drone_level = -1
	this._time_level = -1
	this._weapon_state = "empty"
	this._shots = {}
	this._last_rally_x, this._last_rally_y = b.rally_pos.x, b.rally_pos.y
	local marker = E:create_entity("flag_bullriders_marker")
	marker.soldier.tower_id = this.id
	marker.pos.x, marker.pos.y = b.rally_pos.x, b.rally_pos.y
	queue_insert(marker)
	this.bullriders_marker = marker
	return true
end
function scripts.tower_blastin_bullriders.remove(this, store)
	remove_drones(this)
	remove_slow_aura(this)
	if this.bullriders_marker then
		queue_remove(this.bullriders_marker)
		this.bullriders_marker = nil
	end
	return true
end
function scripts.tower_blastin_bullriders.update(this, store)
	local a = this.attacks.list[1]
	local tw = this.tower
	local sprites = this.render.sprites
	local b = this.barrack
	local pow_p = this.powers.precision
	local pow_d = this.powers.double_trouble
	local pow_b = this.powers.buying_time
	local flag_id = this.bullriders_flag_id
	local flag_b_id = this.bullriders_flag_b_id
	local flag_decal_id = this.bullriders_flag_decal_id
	local flag_decal_b_id = this.bullriders_flag_decal_b_id
	local slow_fx_id = this.bullriders_slow_fx_id
	local slow_ring_id = this.bullriders_slow_ring_id
	while true do
		if tw.blocked then
			coroutine.yield()
		else
			local dl = pow_d.level
			local bl = pow_b.level
			local pl = pow_p.level
			if pl ~= this._precision_level then
				this._precision_level = pl
				if pl > 0 then
					local cd_mul = E:get_template("tower_blastin_bullriders").powers.precision.cooldown_tech_factor or 1
					pow_p.cooldown = cfg.precision_cooldown[pl] * cd_mul
				end
			end
			if dl ~= this._drone_level then
				this._drone_level = dl
				if dl > 0 and not this.bullriders_drones then
					spawn_drones(this)
				elseif dl == 0 then
					remove_drones(this)
				end
			end
			if bl ~= this._time_level then
				this._time_level = bl
				this._slow_radius = nil
				if bl > 0 then
					ensure_slow_aura(this, store)
					set_flag_state(this, store, true)
				else
					remove_slow_aura(this)
					set_flag_state(this, store, false)
				end
			end
			if bl > 0 then
				sync_slow_radius(this)
			end
			local state = skill_state(dl > 0, bl > 0)
			if state ~= this._state then
				this._state = state
				set_skill_sprites(this, store, state)
			end
			local rally = b.rally_pos
			local dx = rally.x - this.pos.x
			local dy = rally.y - this.pos.y
			if this._last_rally_x and (math.abs(rally.x - this._last_rally_x) > 2 or math.abs(rally.y - this._last_rally_y) > 2) then
				local sid = bl > 0 and flag_b_id or flag_id
				anim_start(this, "in", false, sid, store.tick_ts)
				anim_start(this, "in", false, bl > 0 and flag_decal_b_id or flag_decal_id, store.tick_ts)
				if bl > 0 then
					anim_start(this, "in", false, slow_ring_id, store.tick_ts)
				end
				this._flag_in = true
				this._flag_loop = bl > 0 and "idle" or "Idle"
			end
			this._last_rally_x, this._last_rally_y = rally.x, rally.y
			local fo = v(dx, dy)
			sprites[flag_id].offset = fo
			sprites[flag_b_id].offset = fo
			sprites[flag_decal_id].offset = fo
			sprites[flag_decal_b_id].offset = fo
			sprites[slow_fx_id].offset = fo
			sprites[slow_ring_id].offset = fo
			if this.bullriders_slow_aura then
				this.bullriders_slow_aura.pos.x = rally.x
				this.bullriders_slow_aura.pos.y = rally.y
			end
			if this._flag_in then
				local sid = bl > 0 and flag_b_id or flag_id
				if U.animation_finished(this, sid) then
					this._flag_in = false
					anim_start(this, this._flag_loop, true, sid, store.tick_ts)
					if bl > 0 then
						anim_start(this, this._flag_loop, true, flag_decal_b_id, store.tick_ts)
						anim_start(this, this._flag_loop, true, slow_ring_id, store.tick_ts)
					else
						anim_start(this, this._flag_loop, true, flag_decal_id, store.tick_ts)
					end
				end
			end
			if this._shoot_end_ts and store.tick_ts >= this._shoot_end_ts then
				this._shoot_end_ts = nil
				anim_start(this, "idle", true, this._body_sid, store.tick_ts)
			end
			if not this._shots then
				this._shots = {}
			end
			for i = #this._shots, 1, -1 do
				local s = this._shots[i]
				if s.launch_ts and store.tick_ts >= s.launch_ts then
					s.launch_ts = nil
					S:queue("d43_blastin_mortar_shot")
					local fxo = E:create_entity("fx_bullriders_launch_rocket")
					fxo.pos.x, fxo.pos.y = this.pos.x + LAUNCH_OFFSET[1], this.pos.y + LAUNCH_OFFSET[2]
					queue_insert(fxo)
				end
				if store.tick_ts >= s.bomb_ts then
					local bomb = E:create_entity("bomb_bullriders_basic")
					local bb = bomb.bullet
					bb.damage_factor = tw.damage_factor
					bb.flight_time = 0.3
					bb.damage_radius = bb.damage_radius + (this.attacks.range - cfg.attack_radius)
					local radius_scale = bb.damage_radius / BOMB_FX_REF_RADIUS * BOMB_FX_SCALE
					scale_explosion_fx("fx_bullriders_explosion", radius_scale)
					scale_explosion_fx("decal_bullriders_crater", radius_scale)
					bb.from = v(s.x, s.y + SKY_HEIGHT)
					bb.to = v(s.x, s.y)
					bomb.pos.x, bomb.pos.y = bb.from.x, bb.from.y
					queue_insert(bomb)
					table.remove(this._shots, i)
				end
			end
			if store.tick_ts - a.ts > a.cooldown * tw.cooldown_factor then
				local enemies = U.find_enemies_in_range_filter_off(rally, this.attacks.range, a.vis_flags, a.vis_bans)
				if enemies then
					a.ts = store.tick_ts
					local fps = sprites[this._body_sid].fps or FPS
					local action_time = ACTION_FRAME / fps
					anim_start(this, "Shoot", false, this._body_sid, store.tick_ts)
					this._shoot_end_ts = store.tick_ts + SHOOT_FRAMES / fps
					this._shots[#this._shots + 1] = {
						launch_ts = store.tick_ts + action_time,
						bomb_ts = store.tick_ts + action_time + RISE_TIME,
						x = rally.x,
						y = rally.y
					}
				end
			end
			if pl > 0 then
				if this._weapon_state == "shoot" and store.tick_ts >= this._weapon_end_ts then
					this._weapon_state = "empty"
					anim_start(this, "idle", true, this._weapon_sid, store.tick_ts)
				end
				if this._weapon_state == "reload" and store.tick_ts >= this._weapon_end_ts then
					this._weapon_state = "ready"
					anim_start(this, "idle_with_missile", true, this._weapon_sid, store.tick_ts)
				end
				if this._weapon_state == "empty" and U.tower_ready_to_use_power(pow_p, pow_p, store, tw) then
					this._weapon_state = "reload"
					this._weapon_end_ts = store.tick_ts + WEAPON_IN_FRAMES / (sprites[this._weapon_sid].fps or FPS)
					anim_start(this, "in", false, this._weapon_sid, store.tick_ts)
				end
				if this._weapon_state == "ready" and U.tower_ready_to_use_power(pow_p, pow_p, store, tw) then
					local target = U.find_biggest_enemy_in_range_filter_off(this.pos, math.huge, bor(F_RANGED), 0)
					if target then
						pow_p.ts = store.tick_ts
						local tp = hit_pos(target)
						local bolt = E:create_entity("bolt_bullriders_precision")
						local bb = bolt.bullet
						local dmg_mul = E:get_template("tower_blastin_bullriders").powers.precision.damage_tech_factor or 1
						bb.damage_min = cfg.precision_damage_min[pl] * dmg_mul
						bb.damage_max = cfg.precision_damage_max[pl] * dmg_mul
						bb.damage_factor = tw.damage_factor
						scale_explosion_fx("fx_bullriders_precision_explosion", bb.damage_radius / cfg.precision_radius)
						bb.to = vclone(tp)
						bb.target_id = target.id
						bolt.pos.x, bolt.pos.y = this.pos.x + MUZZLE_OFFSET[1], this.pos.y + MUZZLE_OFFSET[2]
						queue_insert(bolt)
						this._weapon_state = "shoot"
						this._weapon_end_ts = store.tick_ts + WEAPON_SHOOT_FRAMES / (sprites[this._weapon_sid].fps or FPS)
						anim_start(this, "shoot", false, this._weapon_sid, store.tick_ts)
					end
				end
			end
		end
		coroutine.yield()
	end
end
scripts.flag_bullriders_marker = {}
function scripts.flag_bullriders_marker.get_info(this)
	local store = simulation and simulation.store
	local t = store and store.entities and store.entities[this.soldier.tower_id]
	if not (t and t.tower) then
		t = E:get_template("tower_blastin_bullriders")
	end
	if t then
		return scripts.tower_common.get_info(t)
	end
	return {
		type = STATS_TYPE_TEXT,
		desc = ""
	}
end
function scripts.flag_bullriders_marker.insert(this, store)
	this.render.sprites[1].hidden = true
	return true
end
function scripts.flag_bullriders_marker.update(this, store)
	while true do
		local t = this.soldier.tower_id and store.entities[this.soldier.tower_id]
		if t and t.barrack then
			this.pos.x, this.pos.y = t.barrack.rally_pos.x, t.barrack.rally_pos.y
		end
		coroutine.yield()
	end
end
scripts.fx_bullriders_launch_rocket = {}
function scripts.fx_bullriders_launch_rocket.insert(this, store)
	local s = this.render.sprites[1]
	s.hidden = false
	s.ts = store.tick_ts
	s.r = math.pi / 2
	this.ts = store.tick_ts
	return true
end
function scripts.fx_bullriders_launch_rocket.update(this, store)
	local vy = 900
	while store.tick_ts - this.ts < RISE_TIME do
		coroutine.yield()
		this.pos.y = this.pos.y + vy * store.tick_length
	end
	simulation:queue_remove_entity(this)
end
scripts.bomb_bullriders_basic = {}
function scripts.bomb_bullriders_basic.update(this, store)
	local b = this.bullet
	local dmin, dmax = b.damage_min, b.damage_max
	local dradius = b.damage_radius
	if b.level and b.level > 0 then
		if b.damage_radius_inc then
			dradius = dradius + b.level * b.damage_radius_inc
		end
		if b.damage_min_inc then
			dmin = dmin + b.level * b.damage_min_inc
		end
		if b.damage_max_inc then
			dmax = dmax + b.level * b.damage_max_inc
		end
	end
	if b.particles_name then
		local ps = E:create_entity(b.particles_name)
		ps.particle_system.track_id = this.id
		simulation:queue_insert_entity(ps)
	end
	local expected_stop_time = b.ts + b.flight_time - store.tick_length
	local this_pos = this.pos
	this_pos.x, this_pos.y = b.from.x, b.from.y
	local v_x = b.speed.x
	local v_y = b.speed.y
	local last_ts = store.tick_ts
	local sprites = this.render.sprites
	while store.tick_ts < expected_stop_time do
		coroutine.yield()
		local dt = store.tick_ts - last_ts
		this_pos.x = this_pos.x + v_x * dt
		this_pos.y = this_pos.y + v_y * dt
		if b.align_with_trajectory then
			sprites[1].r = math.atan2(v_y, v_x)
		elseif b.rotation_speed then
			sprites[1].r = sprites[1].r + b.rotation_speed * store.tick_length
		end
		if b.hide_radius then
			sprites[1].hidden = V.dist2(this_pos.x, this_pos.y, b.from.x, b.from.y) < b.hide_radius * b.hide_radius or V.dist2(this_pos.x, this_pos.y, b.to.x, b.to.y) < b.hide_radius * b.hide_radius
		end
		v_y = v_y + b.g * dt
		last_ts = last_ts + dt
	end
	this_pos.x, this_pos.y = b.to.x, b.to.y
	local enemies = U.find_enemies_in_range_filter_off(this_pos, dradius, b.damage_flags, b.damage_bans)
	local mods
	if b.mod then
		mods = {b.mod}
	elseif b.mods then
		mods = b.mods
	end
	if enemies then
		for i = 1, #enemies do
			local enemy = enemies[i]
			local d = extra_SU.create_bullet_damage_without_pops_and_value(b, enemy.id, this.id)
			if UP:get_upgrade("engineer_efficiency") then
				d.value = dmax
			else
				local dist_factor = U.dist_factor_inside_ellipse(enemy.pos, b.to, dradius)
				d.value = dmax - (dmax - dmin) * dist_factor
			end
			d.value = b.damage_factor * d.value
			queue_damage(store, d)
			if mods then
				for _, mod_name in ipairs(mods) do
					if U.flags_pass(enemy.vis, E:get_template(mod_name).modifier) then
						local mod = E:create_entity(mod_name)
						mod.modifier.damage_factor = b.damage_factor
						mod.modifier.target_id = enemy.id
						mod.modifier.source_id = this.id
						simulation:queue_insert_entity(mod)
					end
				end
			end
		end
	end
	local p = SU.create_bullet_pop(store, this)
	if p then
		simulation:queue_insert_entity(p)
	end
	local cell_type = GR:cell_type(this_pos.x, this_pos.y)
	if b.hit_fx_water and band(cell_type, TERRAIN_WATER) ~= 0 then
		S:queue(this.sound_events.hit_water)
		local water_fx = E:create_entity(b.hit_fx_water)
		water_fx.pos.x, water_fx.pos.y = this_pos.x, this_pos.y
		water_fx.render.sprites[1].ts = store.tick_ts
		water_fx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
		simulation:queue_insert_entity(water_fx)
	elseif b.hit_fx then
		S:queue(this.sound_events.hit)
		local sfx = E:create_entity(b.hit_fx)
		sfx.pos = vclone(this_pos)
		sfx.render.sprites[1].ts = store.tick_ts
		sfx.render.sprites[1].sort_y_offset = b.hit_fx_sort_y_offset
		simulation:queue_insert_entity(sfx)
	end
	if b.hit_decal and band(cell_type, TERRAIN_WATER) == 0 then
		local decal = E:create_entity(b.hit_decal)
		decal.pos = vclone(this_pos)
		decal.render.sprites[1].ts = store.tick_ts
		simulation:queue_insert_entity(decal)
	end
	if b.hit_payload then
		local hp
		if type(b.hit_payload) == "string" then
			hp = E:create_entity(b.hit_payload)
		else
			hp = b.hit_payload
		end
		hp.pos.x, hp.pos.y = this_pos.x, this_pos.y
		hp.source_id = b.source_id
		if hp.unit then
			hp.unit.damage_factor = this.bullet.damage_factor * hp.unit.damage_factor
		end
		if hp.aura then
			hp.aura.level = this.bullet.level
			hp.aura.source_id = this.id
			hp.aura.damage_factor = this.bullet.damage_factor * hp.aura.damage_factor
		end
		if not hp.unit and not hp.aura then
			hp.damage_factor = this.bullet.damage_factor
		end
		simulation:queue_insert_entity(hp)
	end
	simulation:queue_remove_entity(this)
end
scripts.bolt_bullriders_precision = {}
function scripts.bolt_bullriders_precision.update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	if s.animated then
		U.animation_start_default(this, "run", nil, store.tick_ts, true)
	end
	local ang = b.to.x >= this.pos.x and math.pi / 8 or math.pi * 7 / 8
	local dx, dy = math.cos(ang), math.sin(ang)
	s.r = ang
	local remain = 150
	while remain > 0 do
		local step = math.min(400 * store.tick_length, remain)
		this.pos.x = this.pos.x + dx * step
		this.pos.y = this.pos.y + dy * step
		remain = remain - step
		coroutine.yield()
	end
	return scripts.missile.update(this, store)
end
scripts.drone_bullriders = {}
function scripts.drone_bullriders.insert(this, store)
	this.render.sprites[1].ts = store.tick_ts
	this.render.sprites[2].ts = store.tick_ts
	for i = 1, #this.render.sprites do
		this.render.sprites[i].sort_y_offset = -DRONE_HOVER[2] - 5
	end
	this.shoot_ts = store.tick_ts
	this.anim = "idle"
	this.anchor_x, this.anchor_y = this.pos.x, this.pos.y
	return true
end
function scripts.drone_bullriders.update(this, store)
	local range = cfg.drone_range
	local cooldown = cfg.drone_cooldown
	local detect = cfg.drone_detect_range
	local leash = cfg.drone_leash_range
	local speed = cfg.drone_move_speed
	local ax = this.anchor_x or this.pos.x
	local ay = this.anchor_y or this.pos.y
	this.anchor_x, this.anchor_y = ax, ay
	local anchor = v(ax, ay)
	local function move_to(gx, gy)
		local dx, dy = gx - this.pos.x, gy - this.pos.y
		local d2 = dx * dx + dy * dy
		local step = speed * store.tick_length
		if d2 > step * step then
			local d = math.sqrt(d2)
			this.pos.x = this.pos.x + dx / d * step
			this.pos.y = this.pos.y + dy / d * step
		else
			this.pos.x, this.pos.y = gx, gy
		end
	end
	while true do
		if this.anim == "attack" and U.animation_finished(this, 1) then
			this.anim = "idle"
			anim_start(this, "idle", true, 1, store.tick_ts)
		end
		local target = this.target_id and store.entities[this.target_id]
		if target then
			local dx, dy = target.pos.x - ax, target.pos.y - ay
			if (target.health and target.health.dead) or dx * dx + dy * dy > detect * detect then
				target = nil
			end
		end
		if not target then
			target = U.find_foremost_enemy_in_range_filter_off(anchor, detect, 0, bor(F_RANGED), 0)
			this.target_id = target and target.id or nil
		end
		if target then
			local flip = target.pos.x < this.pos.x
			if this.render.sprites[1].flip_x ~= flip then
				this.render.sprites[1].flip_x = flip
			end
			local dx, dy = target.pos.x - ax, target.pos.y - ay
			local d = math.sqrt(dx * dx + dy * dy)
			if d > 0 then
				local travel = math.min(leash, math.max(0, d - range + 20))
				move_to(ax + dx / d * travel, ay + dy / d * travel)
			else
				move_to(ax, ay)
			end
			local cdf = this.owner and this.owner.tower and this.owner.tower.cooldown_factor or 1
			if store.tick_ts - this.shoot_ts >= cooldown * cdf then
				local sx, sy = target.pos.x - this.pos.x, target.pos.y - this.pos.y
				if sx * sx + sy * sy <= range * range then
					this.shoot_ts = store.tick_ts
					this.anim = "attack"
					anim_start(this, "attack", false, 1, store.tick_ts)
					S:queue("d43_blastin_drone_shot")
					local tp = hit_pos(target)
					local bullet = E:create_entity("bullet_bullriders_drone")
					local bb = bullet.bullet
					local df = this.owner and this.owner.tower and this.owner.tower.damage_factor or 1
					bb.damage_min = cfg.drone_damage_min
					bb.damage_max = cfg.drone_damage_max
					bb.damage_factor = df
					bb.from = vclone(this.pos)
					bb.to = vclone(tp)
					bb.target_id = target.id
					bullet.pos.x, bullet.pos.y = this.pos.x, this.pos.y
					queue_insert(bullet)
				end
			end
		else
			move_to(ax, ay)
		end
		coroutine.yield()
	end
end
end

do
local cfg = {["attack_range"]=150,["mind_control_cooldown"]=5,["mind_control_duration"]=10,["mind_control_max_units"]=2,["mind_control_drain_pct"]=0.02,["tantrum_cooldown"]={20,18,16},["tantrum_stun"]={4,5,6},["tantrum_max_targets"]=5,["tantrum_min_count"]=2,["bigbrain_range"]=155,["bigbrain_cooldown"]={4,3,2.5},["bigbrain_damage_min"]=54,["bigbrain_damage_min_inc"]=23,["bigbrain_damage_max"]=66,["bigbrain_damage_max_inc"]=28,["projection_cooldown"]={12,10,8},["projection_radius"]=55,["projection_damage_min"]=40,["projection_damage_min_inc"]=20,["projection_damage_max"]=60,["projection_damage_max_inc"]=30}
local function tpos(e)
	return e.tower and e.tower.range_offset and V.v(e.pos.x + e.tower.range_offset.x, e.pos.y + e.tower.range_offset.y) or e.pos
end

local function betray_filter(target, store)
	return valid_possession_target(target, store)
end

local function count_controlled(this, store)
	local list = this._wifi_mind

	if not list then
		return 0
	end

	local n = 0

	for i = #list, 1, -1 do
		local t = store.entities[list[i]]

		if not t or t.health.dead or not t._possession_skill_active then
			table.remove(list, i)
		else
			n = n + 1
		end
	end

	return n
end

scripts.tower_wifi_babies = {}

function scripts.tower_wifi_babies.get_info(this)
	local o = scripts.tower_common.get_info(this)
	local mb = E:get_template(this.mind_control.bullet).bullet

	o.damage_min = mb.damage_min
	o.damage_max = mb.damage_max
	o.damage_type = DAMAGE_MAGICAL
	o.cooldown = this.mind_control.cooldown * this.tower.cooldown_factor

	return o
end

function scripts.tower_wifi_babies.update(this, store)
	local tw = this.tower
	local a = this.attacks
	local a_ray = a.list[1]
	local pow_mind = this.mind_control
	local pow_t = this.powers.tantrum
	local pow_b = this.powers.big_brain
	local pow_p = this.powers.projection
	local sid = this.render.sid_tower
	local ray_range_ratio = cfg.bigbrain_range / cfg.attack_range

	a_ray.ts = store.tick_ts
	pow_mind.ts = 0
	pow_t.ts = store.tick_ts
	pow_p.ts = store.tick_ts
	pow_mind.cooldown = cfg.mind_control_cooldown
	pow_t.cooldown = cfg.tantrum_cooldown[1]
	pow_p.cooldown = cfg.projection_cooldown[1]
	a_ray.cooldown = 6

	this._wifi_mind = {}

	local mind_retry_ts = 0

	local function projection_free(e)
		return not (e._wifi_projection_ts and store.tick_ts - e._wifi_projection_ts < 0.5)
	end

	U.animation_start(this, "idle", nil, store.tick_ts, true, sid)

	while true do
		if tw.blocked then
			coroutine.yield()
		else
			if pow_t.changed then
				pow_t.changed = nil
				pow_t.cooldown = cfg.tantrum_cooldown[(pow_t.level or 0) + 1]
			end

			if pow_b.changed then
				pow_b.changed = nil

				if pow_b.level > 0 then
					a_ray.cooldown = cfg.bigbrain_cooldown[pow_b.level]
				end
			end

			if pow_p.changed then
				pow_p.changed = nil

				if pow_p.level > 0 then
					pow_p.cooldown = cfg.projection_cooldown[pow_p.level]
				end
			end

			local body_prefix

			if pow_b.level > 0 and pow_p.level > 0 then
				body_prefix = "d43_wifi_babies_skillab"
			elseif pow_b.level > 0 then
				body_prefix = "d43_wifi_babies_skilla"
			elseif pow_p.level > 0 then
				body_prefix = "d43_wifi_babies_skillb"
			else
				body_prefix = "d43_wifi_babies"
			end

			if this.render.sprites[sid].prefix ~= body_prefix then
				this.render.sprites[sid].prefix = body_prefix

				U.animation_start(this, "idle", nil, store.tick_ts, true, sid)
			end

			if this.render.sprites[sid].name ~= "idle" and U.animation_finished(this, sid) then
				U.animation_start(this, "idle", nil, store.tick_ts, true, sid, true)
			end

			if store.tick_ts - pow_mind.ts > pow_mind.cooldown * tw.cooldown_factor and store.tick_ts >= mind_retry_ts then
				local target

				if count_controlled(this, store) < cfg.mind_control_max_units then
					target = U.find_biggest_enemy_in_range_filter_on(tpos(this), a.range, pow_mind.vis_flags, pow_mind.vis_bans, function(enemy) return betray_filter(enemy, store) end)
				end

				if target then
					pow_mind.ts = store.tick_ts

					local b = E:create_entity(pow_mind.bullet)
					local from = v(this.pos.x + pow_mind.bullet_start_offset.x, this.pos.y + pow_mind.bullet_start_offset.y)

					b.pos.x, b.pos.y = from.x, from.y
					b.bullet.from = V.vclone(b.pos)
					b.bullet.to = v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
					b.bullet.target_id = target.id
					b.bullet.source_id = this.id
					b.bullet.damage_factor = tw.damage_factor

					simulation:queue_insert_entity(b)

					this._wifi_mind[#this._wifi_mind + 1] = target.id
				else
					mind_retry_ts = store.tick_ts + 0.1
				end
			end

			if store.tick_ts - pow_t.ts > pow_t.cooldown * tw.cooldown_factor then
				local lv = pow_t.level or 0
				local enemies = U.find_enemies_in_range_filter_off(tpos(this), a.range, pow_t.vis_flags, pow_t.vis_bans)

				if enemies and #enemies >= cfg.tantrum_min_count then
					pow_t.ts = store.tick_ts

					U.animation_start(this, "tantrum", nil, store.tick_ts, false, sid)
					S:queue("d43_wifi_babies_cry_" .. math.random(1, 3))

					local fx = E:create_entity("fx_wifi_babies_pulse")

					fx.pos.x, fx.pos.y = this.pos.x, this.pos.y
					simulation:queue_insert_entity(fx)

					local n = 0

					for _, t in ipairs(enemies) do
						if n >= cfg.tantrum_max_targets then
							break
						end

						n = n + 1

						local m = E:create_entity("mod_wifi_babies_stun")

						m.modifier.target_id = t.id
						m.modifier.duration = cfg.tantrum_stun[lv + 1]
						m.modifier.source_id = this.id
						simulation:queue_insert_entity(m)

						local ex = E:create_entity("fx_wifi_babies_stun_hit")

						ex.pos.x, ex.pos.y = t.pos.x, t.pos.y
						simulation:queue_insert_entity(ex)
					end
				else
					pow_t.ts = pow_t.ts + 0.1
				end
			end

			if U.tower_ready_to_use_power(pow_b, a_ray, store, tw) then
				local enemy = U.find_foremost_enemy_in_range_filter_off(tpos(this), a.range * ray_range_ratio, 0, a_ray.vis_flags, a_ray.vis_bans)

				if enemy then
					a_ray.ts = store.tick_ts

					U.animation_start(this, "skillbasic", nil, store.tick_ts, false, sid)

					local b = E:create_entity(a_ray.bullet)
					local from = v(this.pos.x + a_ray.bullet_start_offset.x, this.pos.y + a_ray.bullet_start_offset.y)

					b.pos.x, b.pos.y = from.x, from.y
					b.bullet.from = V.vclone(b.pos)
					b.bullet.to = v(enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y)
					b.bullet.target_id = enemy.id
					b.bullet.source_id = this.id
					b.bullet.level = pow_b.level - 1
					b.bullet.damage_factor = tw.damage_factor

					simulation:queue_insert_entity(b)
				else
					a_ray.ts = a_ray.ts + 0.1
				end
			end

			if U.tower_ready_to_use_power(pow_p, pow_p, store, tw) then
				local enemy = U.find_foremost_enemy_in_range_filter_on(tpos(this), math.huge, 0, pow_p.vis_flags, pow_p.vis_bans, projection_free)

				if enemy then
					enemy._wifi_projection_ts = store.tick_ts
					pow_p.ts = store.tick_ts

					U.animation_start(this, "skilladvanced", nil, store.tick_ts, false, sid)
					S:queue("d43_wifi_babies_projection")

					local pos_x, pos_y = enemy.pos.x + enemy.unit.hit_offset.x, enemy.pos.y + enemy.unit.hit_offset.y
					local ex = E:create_entity("bolt_wifi_babies_projection")

					ex.pos.x, ex.pos.y = pos_x, pos_y
					ex.bullet.level = pow_p.level - 1
					ex.bullet.damage_factor = tw.damage_factor
					ex.bullet.source_id = this.id
					simulation:queue_insert_entity(ex)

					local dc = E:create_entity("fx_wifi_babies_projection_decal")

					dc.pos.x, dc.pos.y = pos_x, pos_y
					simulation:queue_insert_entity(dc)
				else
					pow_p.ts = pow_p.ts + 0.1
				end
			end

			coroutine.yield()
		end
	end
end

scripts.bolt_wifi_babies_projection = {}

function scripts.bolt_wifi_babies_projection.update(this, store)
	local b = this.bullet

	U.animation_start_default(this, "hit", nil, store.tick_ts, false)

	local enemies = U.find_enemies_in_range_filter_off_consider_hit_offset(this.pos, b.damage_radius, b.damage_flags, b.damage_bans)

	if enemies then
		for _, enemy in ipairs(enemies) do
			store.damage_queue[#store.damage_queue + 1] = extra_SU.create_bullet_damage_without_pops(b, enemy.id, this.id)
		end
	end

	while not U.animation_finished(this, 1) do
		coroutine.yield()
	end

	simulation:queue_remove_entity(this)
end
end
end
-- END DOVE43 EXTRA TOWERS

return scripts
