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
local SU = require("script_utils_pld")
local U = require("utils_pld")
local ULH = require("utils_lh")
local LU = require("level_utils")
local UP = require("upgrades")
local V = require("klua.vector")
local W = require("wave_db")
local F = require("klove.font_db")
local I = require("klove.image_db")
local MP = require("malik_presentation")
local G = love.graphics
local bit = require("bit")
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot

require("i18n")

local function branch_register_solid_image(name, r, g, b)
	if I:s(name, true) then
		return
	end

	local data = love.image.newImageData(1, 1)
	local major = love.getVersion and select(1, love.getVersion()) or 0

	if major >= 11 then
		data:setPixel(0, 0, r / 255, g / 255, b / 255, 1)
	else
		data:setPixel(0, 0, r, g, b, 255)
	end

	I:add_image(name, G.newImage(data), "runtime_kr4_branch", 1)
end

branch_register_solid_image("stage158_sea_fill", 13, 96, 112)

local scripts = require("scripts_5")

local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

local function combat_stats_parent_id(value)
	if type(value) == "table" then
		return value.id
	end

	return value
end

local function combat_stats_entity_source_id(entity)
	if not entity then
		return nil
	end

	if entity.soldier and entity.soldier.tower_id then
		return combat_stats_parent_id(entity.soldier.tower_id)
	end

	if entity.bullet and entity.bullet.source_id then
		return combat_stats_parent_id(entity.bullet.source_id)
	end

	if entity.modifier and entity.modifier.source_id then
		return combat_stats_parent_id(entity.modifier.source_id)
	end

	if entity.aura and entity.aura.source_id then
		return combat_stats_parent_id(entity.aura.source_id)
	end

	if entity.spell and entity.spell.source_id then
		return combat_stats_parent_id(entity.spell.source_id)
	end

	if entity.spawner and entity.spawner.owner_id then
		return combat_stats_parent_id(entity.spawner.owner_id)
	end

	if entity.relic and entity.relic.owner_id then
		return combat_stats_parent_id(entity.relic.owner_id)
	end

	if entity.tower_id then
		return combat_stats_parent_id(entity.tower_id)
	end

	if entity.tower_ref then
		return combat_stats_parent_id(entity.tower_ref)
	end

	if entity.xp_dest_id then
		return combat_stats_parent_id(entity.xp_dest_id)
	end

	if entity.source_id then
		return combat_stats_parent_id(entity.source_id)
	end

	if entity.owner_id then
		return combat_stats_parent_id(entity.owner_id)
	end

	if entity.source then
		return combat_stats_parent_id(entity.source)
	end

	if entity.owner then
		return combat_stats_parent_id(entity.owner)
	end

	return nil
end

local function combat_stats_tag_child(entity, source_id)
	source_id = combat_stats_parent_id(source_id)

	if not entity or not source_id then
		return
	end

	entity.combat_stats_source_id = entity.combat_stats_source_id or source_id
end

local function queue_damage(store, damage)
	local source

	if damage and (not damage.combat_stats_source_id or not damage.combat_stats_source_template) then
		source = damage.source_id and store.entities[damage.source_id]

		if not damage.combat_stats_source_id then
			damage.combat_stats_source_id = combat_stats_entity_source_id(source) or combat_stats_parent_id(damage.xp_dest_id)
		end

		if source and source.template_name and not damage.combat_stats_source_template then
			damage.combat_stats_source_template = source.template_name
		end
	end

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

local function y_show_taunt_set(store, taunts, set_name, index, wait)
	local set = taunts.sets[set_name]

	index = index or set.idxs and table.random(set.idxs) or math.random(set.start_idx, set.end_idx)

	local duration = taunts.duration
	local taunt_id = _(string.format(set.format, index))

	log.info("show taunt " .. taunt_id)
	signal.emit("show-balloon_tutorial", taunt_id, false)

	if wait then
		U.y_wait(store, duration)
	end
end

local function y_hero_melee_block_and_attacks(store, hero)
	local target = SU.soldier_pick_melee_target(store, hero)

	if not target then
		return false, A_NO_TARGET
	end

	if SU.soldier_move_to_slot_step(store, hero, target) then
		return true
	end

	local attack = SU.soldier_pick_melee_attack(store, hero, target)

	if not attack then
		return false, A_IN_COOLDOWN
	end

	local upg = UP:get_upgrade("heroes_lethal_focus")
	local triggered_lethal_focus = false
	local attack_pop = attack.pop
	local attack_pop_chance = attack.pop_chance

	if attack.basic_attack and upg then
		if not hero._lethal_focus_deck then
			hero._lethal_focus_deck = SU.deck_new(upg.trigger_cards, upg.total_cards)
		end

		triggered_lethal_focus = SU.deck_draw(hero._lethal_focus_deck)
	end

	if triggered_lethal_focus then
		hero.unit.damage_factor = hero.unit.damage_factor * upg.damage_factor
		attack.pop = {
			"pop_crit_heroes"
		}
		attack.pop_chance = 1
	end

	if attack.xp_from_skill then
		SU.hero_gain_xp_from_skill(hero, hero.hero.skills[attack.xp_from_skill])
	end

	local attack_done

	if attack.loops then
		attack_done = SU.y_soldier_do_loopable_melee_attack(store, hero, target, attack)
	elseif attack.type == "area" then
		attack_done = SU.y_soldier_do_single_area_attack(store, hero, target, attack)
	else
		attack_done = SU.y_soldier_do_single_melee_attack(store, hero, target, attack)
	end

	if triggered_lethal_focus then
		hero.unit.damage_factor = hero.unit.damage_factor / upg.damage_factor
		attack.pop = attack_pop
		attack.pop_chance = attack_pop_chance
	end

	if attack_done then
		return false, A_DONE
	else
		return true
	end
end

local function y_hero_ranged_attacks(store, hero)
	local target, attack, pred_pos = SU.soldier_pick_ranged_target_and_attack(store, hero)

	if not target then
		return false, A_NO_TARGET
	end

	if not attack then
		return false, A_IN_COOLDOWN
	end

	local upg = UP:get_upgrade("heroes_lethal_focus")
	local triggered_lethal_focus = false
	local bullet_t = E:get_template(attack.bullet)
	local bullet_use_unit_damage_factor = bullet_t.bullet.use_unit_damage_factor
	local bullet_pop = bullet_t.bullet.pop
	local bullet_pop_conds = bullet_t.bullet.pop_conds

	if attack.basic_attack and upg then
		if not hero._lethal_focus_deck then
			hero._lethal_focus_deck = SU.deck_new(upg.trigger_cards, upg.total_cards)
		end

		triggered_lethal_focus = SU.deck_draw(hero._lethal_focus_deck)
	end

	if triggered_lethal_focus then
		if bullet_t.bullet.damage_radius > 0 then
			hero.unit.damage_factor = hero.unit.damage_factor * upg.damage_factor_area
		else
			hero.unit.damage_factor = hero.unit.damage_factor * upg.damage_factor
		end

		bullet_t.bullet.use_unit_damage_factor = true
		bullet_t.bullet.pop = {
			"pop_crit"
		}
		bullet_t.bullet.pop_conds = DR_DAMAGE
	end

	local start_ts = store.tick_ts
	local attack_done

	U.set_destination(hero, hero.pos)

	if attack.loops then
		attack_done = SU.y_soldier_do_loopable_ranged_attack(store, hero, target, attack)
	else
		attack_done = SU.y_soldier_do_ranged_attack(store, hero, target, attack, pred_pos)
	end

	if attack_done then
		attack.ts = start_ts

		if attack.shared_cooldown then
			for _, aa in pairs(hero.ranged.attacks) do
				if aa ~= attack and aa.shared_cooldown then
					aa.ts = attack.ts
				end
			end
		end

		if hero.ranged.forced_cooldown then
			hero.ranged.forced_ts = start_ts
		end
	end

	if triggered_lethal_focus then
		if bullet_t.bullet.damage_radius > 0 then
			hero.unit.damage_factor = hero.unit.damage_factor / upg.damage_factor_area
		else
			hero.unit.damage_factor = hero.unit.damage_factor / upg.damage_factor
		end
		bullet_t.bullet.use_unit_damage_factor = bullet_use_unit_damage_factor
		bullet_t.bullet.pop = bullet_pop
		bullet_t.bullet.pop_conds = bullet_pop_conds
	end

	if attack_done then
		return false, A_DONE
	else
		return true
	end
end

scripts.kr4_soldier_barrack = {}
function scripts.kr4_soldier_barrack.update(this, store, script)
	local brk, sta
	local self_damage_ts = store.tick_ts

	local function check_tower_damage_factor()
		local tower = store.entities[this.soldier.tower_id]
		if tower then
			for _, a in ipairs(this.melee.attacks) do
				if not a._original_damage_min then
					a._original_damage_min = a.damage_min
				end

				if not a._original_damage_max then
					a._original_damage_max = a.damage_max
				end

				a.damage_min = a._original_damage_min * tower.tower.damage_factor
				a.damage_max = a._original_damage_max * tower.tower.damage_factor
			end
		end
	end

	local function hide_shadow(isHidden)
		for i, sprite in pairs(this.render.sprites) do
			if sprite.is_shadow then
				sprite.hidden = isHidden
			end
		end
	end

	if this.vis._bans then
		this.vis.bans = this.vis._bans
		this.vis._bans = nil
	end

	if this.render.sprites[1].name == "raise" then
		this.health_bar.hidden = true

		U.animation_start(this, "raise", nil, store.tick_ts, 1)

		while not U.animation_finished(this) and not this.health.dead do
			coroutine.yield()
		end

		if not this.health.dead then
			this.health_bar.hidden = nil
			hide_shadow(true)
		end
	end

	while true do
		if this.powers then
			for pn, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil

					SU.soldier_power_upgrade(this, pn)
				end
			end
		end

		if this.cloak then
			this.vis.flags = band(this.vis.flags, bnot(this.cloak.flags))
			this.vis.bans = band(this.vis.bans, bnot(this.cloak.bans))
			this.render.sprites[1].alpha = 255
		end

		if not this.health.dead or SU.y_soldier_revive(store, this) then
			-- block empty
		else
			hide_shadow(true)
			SU.y_soldier_death(store, this)
			return
		end

		if this.self_damage and not this.health.dead and store.tick_ts - self_damage_ts >= (this.self_damage.cooldown or 2) then
			self_damage_ts = store.tick_ts

			local d = E:create_damage()

			d.source_id = this.id
			d.target_id = this.id
			d.value = this.self_damage.damage or 0
			d.damage_type = this.self_damage.damage_type or DAMAGE_TRUE

			queue_damage(store, d)
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			SU.soldier_courage_upgrade(store, this)

			if this.dodge and this.dodge.active then
				this.dodge.active = false

				if this.dodge.counter_attack and this.powers[this.dodge.counter_attack.power_name].level > 0 then
					this.dodge.counter_attack_pending = true
				elseif this.dodge.animation then
					if this.dodge.hide_shadow then
						hide_shadow(true)
					end
					U.animation_start(this, this.dodge.animation, nil, store.tick_ts, 1)

					while not U.animation_finished(this) do
						coroutine.yield()
					end
					hide_shadow(false)
				end

				signal.emit("soldier-dodge", this)
			end

			while this.nav_rally.new do
				if SU.y_soldier_new_rally(store, this) then
					goto label_43_1
				end
			end

			check_tower_damage_factor()
			
			if this.timed_actions then
				brk, sta = SU.y_soldier_timed_actions(store, this)

				if brk then
					goto label_43_1
				end
			end

			if this.timed_attacks then
				brk, sta = SU.y_soldier_timed_attacks(store, this)

				if brk then
					goto label_43_1
				end
			end

			if this.ranged and this.ranged.range_while_blocking then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk then
					goto label_43_1
				end
			end

			if this.melee then
				if this.dodge and this.dodge.hide_shadow and this.dodge.counter_attack_pending then
					hide_shadow(true)
				end
				brk, sta = SU.y_soldier_melee_block_and_attacks(store, this)
				if this.dodge and this.dodge.hide_shadow then
					hide_shadow(false)
				end

				if brk or sta ~= A_NO_TARGET then
					goto label_43_1
				end
			end

			if this.ranged and not this.ranged.range_while_blocking then
				brk, sta = SU.y_soldier_ranged_attacks(store, this)

				if brk or sta == A_DONE then
					goto label_43_1
				elseif sta == A_IN_COOLDOWN and not this.ranged.go_back_during_cooldown then
					goto label_43_0
				end
			end

			if SU.soldier_go_back_step(store, this) then
				goto label_43_1
			end

			::label_43_0::

			SU.soldier_idle(store, this)

			if this.cloak then
				this.vis.flags = bor(this.vis.flags, this.cloak.flags)
				this.vis.bans = bor(this.vis.bans, this.cloak.bans)

				if this.cloak.alpha then
					this.render.sprites[1].alpha = this.cloak.alpha
				end
			end

			SU.soldier_regen(store, this)
		end

		::label_43_1::

		coroutine.yield()
	end
end

scripts.kr4_enemy_mixed = {}
function scripts.kr4_enemy_mixed.update(this, store, script)
	local function check_unit_attack(store, this, a)
		if SU.check_unit_attack_available(store, this, a) then
			return SU.entity_attacks(store, this, a)
		end
		return false
	end

	local walk_break_fn = function(store, this)
		if this.timed_attacks then
			for i, a in ipairs(this.timed_attacks.list) do
				if check_unit_attack(store, this, a) then
					return true
				end
			end
		end
		return false
	end

	local melee_break_fn = function(store, this)
		if this.timed_attacks then
			for i, a in ipairs(this.timed_attacks.list) do
				if a.melee_break and check_unit_attack(store, this, a) then
					return true
				end
			end
		end
		return false
	end

	local ranged_break_fn = function(store, this)
		if this.timed_attacks then
			for i, a in ipairs(this.timed_attacks.list) do
				if a.ranged_break and check_unit_attack(store, this, a) then
					return true
				end
			end
		end
		return false
	end

	if this.timed_attacks then
		for i, a in ipairs(this.timed_attacks.list) do
			a.ts = store.tick_ts
		end
	end

	if this.render.sprites[1].name == "raise" then
		if this.sound_events and this.sound_events.raise then
			S:queue(this.sound_events.raise, this.sound_events.raise_args)
		end
		this.health_bar.hidden = true
		local an, af = U.animation_name_facing_point(this, "raise", this.motion.dest)
		SU.hide_shadow(this, true)
		U.y_animation_play(this, an, af, store.tick_ts, 1)
		SU.hide_shadow(this, false)
		if not this.health.dead then
			this.health_bar.hidden = nil
		end
	end

	local ps
	if this.particle then
		ps = {}
		if type(this.particle) == "table" then
			for i, value in ipairs(this.particle) do
				local p = E:create_entity(value)
				p.particle_system.emit = true
				p.particle_system.track_id = this.id
				queue_insert(store, p)
				table.insert(ps, p)
			end
		else
			local p = E:create_entity(this.particle)
			p.particle_system.emit = true
			p.particle_system.track_id = this.id
			queue_insert(store, p)
			table.insert(ps, p)
		end
	end

	::label_29_0::

	while true do
		if this.health.dead then
			if ps then
				for i, p in ipairs(ps) do
					p.particle_system.emit = nil
				end
			end

			SU.hide_shadow(this, true)
			SU.y_enemy_death(store, this)

			if this.deadth_fn then
				this.deadth_fn(this, store, script)
			end

			return
		end

		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			SU.y_enemy_mixed_walk_melee_ranged(store, this, false, walk_break_fn, melee_break_fn, ranged_break_fn)
			
			if ps and this.render then
				for i, p in ipairs(ps) do
					p.particle_system.flip_x = this.render.sprites[1].flip_x
				end
			end

			coroutine.yield()
		end
	end
end

scripts.enemy_crystal_demolisher = {}
function scripts.enemy_crystal_demolisher.death_fn(this, store, script)
	local death = this.death
	local targets = U.find_soldiers_in_range(store.entities, this.pos, death.min_range, death.max_range, death.vis_flags or 0, death.vis_bans or death.vis_ban or 0, kr4_valid_enemy_soldier_target)

	if targets then
		for i, t in pairs(targets) do
			if death.count and i > death.count then
				break
			end

			local d = E:create_damage()

			d.source_id = this.id
			d.target_id = t.id
			d.damage_type = death.damage_type
			d.value = math.ceil(this.unit.damage_factor * death.damage)

			queue_damage(store, d)
		end
	end
end

scripts.enemy_bullywags_erudite = {}
function scripts.enemy_bullywags_erudite.remove(this, store, script)
	local ba = this.ranged.attacks[1]
	
	for i, b in pairs(ba._stored_bullets) do
		queue_remove(store, b)
	end
	return true
end

scripts.infuser_cast_shield_mod = {}

local function infuser_cast_shield_restore_target(this, target)
	if target and target._shield_mod == this then
		target._shield_mod = nil

		if target.health and target.health.on_damage == scripts.infuser_cast_shield_mod.on_damage then
			target.health.on_damage = this._old_on_damage
		end

		if target.unit then
			target.unit.blood_color = this._blood_color
		end
	end
end

function scripts.infuser_cast_shield_mod.insert(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or target.health.dead then
		return false
	end

	if target._shield_mod and target._shield_mod ~= this then
		infuser_cast_shield_restore_target(target._shield_mod, target)
		target._shield_mod.ready_removed = true
		queue_remove(store, target._shield_mod)
	end

	m.ts = store.tick_ts
	target._shield_mod = this
	this._old_on_damage = target.health.on_damage
	target.health.on_damage = scripts.infuser_cast_shield_mod.on_damage
	this._hit_sources = {}
	this._blood_color = target.unit and target.unit.blood_color
	if target.unit then
		target.unit.blood_color = BLOOD_NONE
	end
	this.health.hp = this.modifier.shield_hp
	this.health.hp_max = this.modifier.shield_hp

	return true
end

function scripts.infuser_cast_shield_mod.update(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]
	m.ts = store.tick_ts
	local shield_decay_ts = store.tick_ts
	local s = this.render.sprites[1]

	if not target or not target.pos then
		queue_remove(store, this)

		return
	end

	this.pos = target.pos

	SU.set_mod_offset(store, this, m.target_id)

	U.y_animation_play(this, this.animations[1], nil, store.tick_ts)

	while true do
		if not target or target.health.dead then
			U.y_animation_play(this, this.animations[3], nil, store.tick_ts)
			queue_remove(store, this)

			return
		end

		SU.set_mod_offset(store, this, m.target_id)

		U.y_animation_play(this, this.animations[2], nil, store.tick_ts)

		if this.ready_removed then
			U.y_animation_play(this, this.animations[3], nil, store.tick_ts)

			queue_remove(store, this)
		end

		coroutine.yield()
	end
end

function scripts.infuser_cast_shield_mod.remove(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	infuser_cast_shield_restore_target(this, target)

	return true
end

function scripts.infuser_cast_shield_mod.on_damage(this, store, damage)
	local mod = this._shield_mod

	if not mod then
		log.error("infuser_cast_shield_mod.on_damage for enemy %s has no mod pointer", this.id)

		return true
	end

	if U.flag_has(damage.damage_type, bor(DAMAGE_INSTAKILL, DAMAGE_DISINTEGRATE, DAMAGE_EAT, DAMAGE_IGNORE_SHIELD)) then
		infuser_cast_shield_restore_target(mod, this)
		queue_remove(store, mod)

		return true
	end

	local pd = U.predict_damage(this, damage)

	if pd >= mod.health.hp then
		mod.health.hp = 0
		mod.ready_removed = true

		return false
	end

	mod.health.hp = mod.health.hp - pd

	return false
end

scripts.infuser_cast_speed_mod = {}
function scripts.infuser_cast_speed_mod.insert(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if scripts.mod_slow.insert(this, store, script) then
		if not (target.render and target.render.sprites[1].angles) then
			return false
		end

		this.origin_walk_animations = target.render.sprites[1].angles.walk
		target.render.sprites[1].angles.walk = this.walk_animations

		return true
	end

	return false
end

function scripts.infuser_cast_speed_mod.remove(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if scripts.mod_slow.remove(this, store, script) then
		if not target or target.health.dead then
			return false
		end
		
		target.render.sprites[1].angles.walk = this.origin_walk_animations

		return true
	end

	return false
end

scripts.bullywag_bubble_crystal = {}
function scripts.bullywag_bubble_crystal.update(this, store, script)
	local a1 = this.attacks.list[1]
	local bullets = {}
	a1.ts = store.tick_ts
	this.ui.clicked = nil
	this.ui.can_click = nil
	U.animation_start_group(this, "cooldown", nil, store.tick_ts, true, this.animation_group1)
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = nil
			targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a1.range, a1.vis_flags, a1.vis_bans)
			if targets then
				S:queue(a1.sound, a1.sound_args)
				U.animation_start_group(this, a1.animation, nil, store.tick_ts, true, this.animation_group1)
				for i, target in ipairs(targets) do
					if i > a1.max_targets then
						break
					end
					local mod = E:create_entity(a1.mod)

					mod.modifier.target_id = target.id

					queue_insert(store, mod)

					local mod2 = E:create_entity(a1.mod2)

					mod2.modifier.target_id = target.id

					queue_insert(store, mod2)
					a1.ts = store.tick_ts
				end

				local pulse = E:create_entity("decal_bubble_crystal_pulse")

				pulse.pos.x, pulse.pos.y = this.pos.x, this.pos.y
				pulse.render.sprites[1].ts = store.tick_ts

				queue_insert(store, pulse)
				
				U.animation_start_group(this, "cooldown", nil, store.tick_ts, true, this.animation_group1)
			else
				this.tween.disabled = true
				this.ui.can_click = true
			end
		end
		
		if store.tick_ts - a1.ts >= a1.cooldown then
			U.animation_start_group(this, "ready", nil, store.tick_ts, true, this.animation_group1)
			this.ui.can_click = true
		end

		coroutine.yield()
	end	
end

scripts.multi_sprite_fx = {}

function scripts.multi_sprite_fx.update(this, store)
	local start_ts = store.tick_ts
	local this_sprites = this.render.sprites
	local finished_anims = {}
	local delayed_sprites = {}

	for i = 1, #this_sprites do
		local s = this_sprites[i]

		if s.animated then
			if s.delay_start then
				delayed_sprites[i] = s.delay_start + start_ts
			else
				U.animation_start(this, s.name, nil, store.tick_ts, false, i, true)
			end

			finished_anims[i] = false
		else
			finished_anims[i] = true
		end
	end

	if this.tween then
		this.tween.ts = store.tick_ts
	end

	local function handle_finished_anim(index)
		if delayed_sprites[index] then
			if store.tick_ts > delayed_sprites[index] then
				this_sprites[index].hidden = false

				U.animation_start(this, this_sprites[index].name, nil, store.tick_ts, false, index, true)

				delayed_sprites[index] = nil
			end

			return false
		end

		if finished_anims[index] then
			return false
		end

		if not U.animation_finished(this, index, 1) then
			return false
		end

		this_sprites[index].hidden = true
		finished_anims[index] = true

		for i = 1, #this_sprites do
			if not finished_anims[i] then
				return false
			end
		end

		return true
	end

	while true do
		for i = 1, #this_sprites do
			if handle_finished_anim(i) then
				if not this.tween or not this.tween.remove then
					queue_remove(store, this)
				end

				return
			end
		end

		coroutine.yield()
	end
end

scripts.bullywag_spawner = {}
function scripts.bullywag_spawner.update(this, store, script)
	local sp = this.spawner

	while true do
		SU.mixed_entity_play_animation(this, sp.animations[1], store.tick_ts,
		sp.facing_point, true)
		if sp.spawn_data then

			sp.spawn_data = nil

			SU.mixed_entity_play_animation(this, sp.animations[2], store.tick_ts,
				sp.facing_point)
			SU.mixed_entity_play_animation(this, sp.animations[3], store.tick_ts, sp.facing_point)
			SU.mixed_entity_play_animation(this, sp.animations[4], store.tick_ts, sp.facing_point)
		else
			SU.mixed_entity_animation_wait(this, sp.animations[1])
			SU.mixed_entity_animation_wait(this, sp.animations[4])
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.overcharge_crystal = {}
function scripts.overcharge_crystal.update(this, store, script)
	local a1 = this.attacks.list[1]
	this.charging = false
	this.charged = false
	this.decharge = false
	this.charging_stage = 0
	local bullets = {}
	a1.ts = store.tick_ts

	local charging_ts = store.tick_ts
	U.animation_start_group(this, "idle", nil, store.tick_ts, true, this.animation_group1)
	while true do
		--受到注能，进入充能状态
		if this.charging_stage == 0 and this.charging == true then
			this.charging = false
			this.charging_stage = 1
			U.animation_start_group(this, "charging", nil, store.tick_ts, true, this.animation_group1)
			charging_ts = store.tick_ts
			goto label_745_0
		end

		--充能被打断，进入休眠状态
		if this.charging_stage == 1 and this.decharge == true then
			this.decharge = false
			U.animation_start_group(this, "idle", nil, store.tick_ts, true, this.animation_group1)
			goto label_745_0
		end

		--充能充满，开始攻击
		if this.charging_stage == 1 and this.charged == true then
			this.charging_stage = 2
			this.chaged = false
			--S:queue("frog_infuser_crystal_charged")
			U.animation_start_group(this, "charged", nil, store.tick_ts, true, animation_group1)
			U.y_wait(store, fts(48))

			--找地图上是否有塔。如果有则攻击。

			local targets = table.filter(store.entities, function(k, v)
				return v.tower and v.tower.type ~= "holder" and v.ui.can_click and U.is_inside_ellipse(v.pos, this.pos, a1.max_range) or v.tower and not v.pending_removal and not v.tower.blocked and (not a1.excluded_templates or not table.contains(a1.excluded_templates, v.template_name)) and U.is_inside_ellipse(v.pos, this.pos, a1.max_range) and (a1.min_range == 0 or not U.is_inside_ellipse(v.pos, this.pos, a1.min_range)) and v.vis and band(v.vis.flags, a1.vis_bans) == 0 and band(v.vis.bans, a1.vis_flags) == 0 and not table.contains(a1.exclude_tower_kind, v.tower.kind) and not U.has_modifiers(store, v, a1.mod) and v.tower.can_be_mod
			end)
			if targets and #targets > 0 then
				target = table.random(targets)

				U.y_animation_play_group(this, "shoot", nil, store.tick_ts, 1, animation_group1)
				--S:queue("frog_infuser_crystal_bolt-loopstart")

				local fx = E:create_entity("fx_lightining_soldier_tower_pandas_blue")
				fx.pos = V.v(target.pos.x, target.pos.y)
				fx.render.sprites[1].ts = store.tick_ts
				queue_insert(store, fx)

				local mod = E:create_entity(a1.mod)
				mod.modifier.target_id = target.id
				mod.modifier.source_id = this.id
				mod.pos = target.pos
				queue_insert(store, mod)

				U.y_animation_wait(this)

				U.animation_start_group(this, "idle", nil, store.tick_ts, true, this.animation_group1)

			end
			U.animation_start_group(this, "idle", nil, store.tick_ts, true, this.animation_group1)
			this.charging = false
			this.charged = false
			this.decharge = false
			this.charging_stage = 0
			goto label_745_0
		end
	
		::label_745_0::
		coroutine.yield()
	end	
end

scripts.ray_simple_silent = {}

function scripts.ray_simple_silent.update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = store.entities[b.target_id]
	local dest = V.vclone(b.to)
	local source = store.entities[b.source_id]


	local interrupt = false

	local function update_sprite()
		if this.track_target and target and target.motion then
			local tpx, tpy = target.pos.x, target.pos.y

			if not b.ignore_hit_offset then
				tpx, tpy = tpx + target.unit.hit_offset.x, tpy + target.unit.hit_offset.y
			end

			local d = math.max(math.abs(tpx - b.to.x), math.abs(tpy - b.to.y))

			if d > b.max_track_distance then
				log.paranoid("(%s) ray_simple target (%s) out of max_track_distance", this.id, target.id)

				target = nil
			else
				dest.x, dest.y = target.pos.x, target.pos.y

				if target.unit and target.unit.hit_offset then
					dest.x, dest.y = dest.x + target.unit.hit_offset.x, dest.y + target.unit.hit_offset.y
				end
			end
		end

		local angle = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)

		s.r = angle
		s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
		s.scale.x = s.scale.x * 1.28
	end

	local function interrupt_judge()
		interrupt = (source.health.dead == true or source.unit.is_stunned == true)
	end

	if not b.ignore_hit_offset and this.track_target and target and target.motion then
		b.to.x, b.to.y = target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y
	end

	s.scale = s.scale or V.v(1, 1)
	s.ts = store.tick_ts

	update_sprite()

	if target.charging_stage == 0 then
		target.charging = true
	else
		goto label_1076_0
	end

	while store.tick_ts - s.ts < b.hit_time and interrupt == false do
		interrupt_judge()

		if target and U.flag_has(target.vis.bans, F_RANGED) then
			target = nil
		end

		if this.track_target then
			update_sprite()
		end
		coroutine.yield()
	end
	if interrupt == true then
		goto label_1076_1
	end

	--[[
	if target and b.damage_type ~= DAMAGE_NONE then
		local d = SU.create_bullet_damage(b, target.id, this.id)

		queue_damage(store, d)
	end

	if target and (b.mod or b.mods) then
		local mods = b.mods or {
			b.mod
		}

		for _, mod_name in pairs(mods) do
			local m = E:create_entity(mod_name)

			m.modifier.target_id = b.target_id
			m.modifier.level = b.level

			queue_insert(store, m)
		end
	end

	if b.hit_payload then
		local hp

		if type(b.hit_payload) == "string" then
			hp = E:create_entity(b.hit_payload)
		else
			hp = b.hit_payload
		end

		if hp.aura then
			hp.aura.level = this.bullet.level
			hp.aura.source_id = this.id

			if target then
				hp.pos.x, hp.pos.y = target.pos.x, target.pos.y
			else
				hp.pos.x, hp.pos.y = dest.x, dest.y
			end
		else
			hp.pos.x, hp.pos.y = dest.x, dest.y
		end

		queue_insert(store, hp)
	end

	if b.hit_fx then
		local is_air = target and band(target.vis.flags, F_FLYING) ~= 0
		local fx = E:create_entity(b.hit_fx)

		if b.hit_fx_ignore_hit_offset and target and not is_air then
			fx.pos.x, fx.pos.y = target.pos.x, target.pos.y
		else
			fx.pos.x, fx.pos.y = dest.x, dest.y
		end

		fx.render.sprites[1].ts = store.tick_ts

		queue_insert(store, fx)
	end

	if this.ray_duration then
		while store.tick_ts - s.ts < this.ray_duration and target and not target.health.dead do
			if this.track_target then
				update_sprite()
			end
			coroutine.yield()
		end
	else
		U.y_animation_wait(this)
	end
	]]--
	::label_1076_1::

	if interrupt == false then 
		target.charged = true
	else
		target.decharge = true
	end

	::label_1076_0::
	this.skip_charging = true
	S:stop(this.sound_events.insert)
	queue_remove(store, this)
end

scripts.mod_erudite_buff = {}

function scripts.mod_erudite_buff.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or target.health.dead or target.enemy and not target.enemy.can_accept_magic then
		return false
	end

	if band(this.modifier.vis_flags, target.vis.bans) ~= 0 or band(this.modifier.vis_bans, target.vis.flags) ~= 0 then
		log.paranoid("mod %s cannot be applied to entity %s:%s because of vis flags/bans", this.template_name, target.id, target.template_name)

		return false
	end

	local buff = this.armor_buff
	local inc = buff.max_factor

	if buff.magic then
		if buff.factor then
			inc = buff.factor * target.health.magic_armor
		end

		SU.magic_armor_inc(target, inc)
	else
		if buff.factor then
			inc = buff.factor * target.health.armor
		end

		SU.armor_inc(target, inc)
	end

	buff._total_factor = inc

	target.ranged.attacks[1].bullet = "enemy_bullywags_erudite_upgrade_bolt"

	signal.emit("mod-applied", this, target)

	return true
end

function scripts.mod_erudite_buff.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target then
		local buff = this.armor_buff

		if buff.magic then
			SU.magic_armor_dec(target, buff._total_factor)
		else
			SU.armor_dec(target, buff._total_factor)
		end
		target.ranged.attacks[1].bullet = "enemy_bullywags_erudite_bolt"
	end

	return true
end

function scripts.mod_erudite_buff.update(this, store, script)
	local buff = this.armor_buff
	local m = this.modifier
	local last_ts = store.tick_ts
	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)

		return
	end

	this.pos = target.pos

	while true do
		target = store.entities[m.target_id]

		if not target or target.health.dead or store.tick_ts - m.ts >= m.duration then
			queue_remove(store, this)

			return
		end

		if this.render and m.use_mod_offset and target.unit.mod_offset then
			this.render.sprites[1].offset.x, this.render.sprites[1].offset.y = target.unit.mod_offset.x, target.unit.mod_offset.y
		end

		if store.tick_ts - last_ts > buff.cycle_time then
			last_ts = store.tick_ts

			if buff.magic and target.health.magic_armor < buff.max_factor then
				SU.magic_armor_inc(target, buff.step_factor)

				buff._total_factor = buff._total_factor + buff.step_factor
			elseif not buff.magic and target.health.armor < buff.max_factor then
				SU.armor_inc(target, buff.step_factor)

				buff._total_factor = buff._total_factor + buff.step_factor
			end
		end

		coroutine.yield()
	end
end

---------------------------------------------------------
--------------------海盗王关卡与场景脚本--------------------
---------------------------------------------------------

function pirate_nodes_to_exit(this)
	if not this.nav_path then
		return 9999
	end

	local dir = this.nav_path.dir or 1

	return math.max(0, (P:get_end_node(this.nav_path.pi) - this.nav_path.ni) * dir)
end

function pirate_nodes_from_start(this)
	if not this.nav_path then
		return 9999
	end

	local dir = this.nav_path.dir or 1

	return math.max(0, (this.nav_path.ni - P:get_start_node(this.nav_path.pi)) * dir)
end

function branch_clamp_path_node(pi, ni)
	local start_node = P:get_start_node(pi)
	local end_node = P:get_end_node(pi)

	if start_node <= end_node then
		return km.clamp(start_node, end_node, ni)
	else
		return km.clamp(end_node, start_node, ni)
	end
end

function branch_path_dir(pi)
	return P:get_start_node(pi) <= P:get_end_node(pi) and 1 or -1
end

function branch_nodes_to_exit_at(pi, ni)
	local dir = branch_path_dir(pi)

	return math.max(0, (P:get_end_node(pi) - ni) * dir)
end

function branch_shift_path_node(nav_path, nodes)
	local dir = nav_path.dir or 1

	return branch_clamp_path_node(nav_path.pi, nav_path.ni + nodes * dir)
end

function branch_find_nearest_template(store, template_name, pos)
	local nearest, nearest_dist

	for _, e in pairs(store.entities) do
		if e.template_name == template_name and e.pos then
			local dist = V.dist(pos.x, pos.y, e.pos.x, e.pos.y)

			if not nearest_dist or dist < nearest_dist then
				nearest = e
				nearest_dist = dist
			end
		end
	end

	return nearest
end

function pirate_damage(store, source, target, value, damage_type)
	if not target or not target.health or target.health.dead then
		return
	end
	if source then
		target._kr4_last_damage_source_id = source.id
		target._kr4_last_damage_template = source.template_name
		target._kr4_last_damage_pirate_kind = source.pirate and source.pirate.kind
		target._kr4_last_damage_ts = store.tick_ts
	end
	local d = E:create_damage()
	d.source_id = source and source.id or nil
	d.target_id = target.id
	d.value = value
	d.damage_type = damage_type or DAMAGE_PHYSICAL
	queue_damage(store, d)
end

function kr4_is_air_support_soldier(e)
	local name = e and e.template_name or ""

	return string.find(name, "soldier_balloon", 1, true) ~= nil or string.find(name, "zeppelin_hero", 1, true) ~= nil
end

function kr4_valid_enemy_soldier_target(e)
	return not kr4_is_air_support_soldier(e)
end

local function branch_blocker_allows_kill_spawn(blocker)
	if not blocker or not blocker.soldier or not blocker.health then
		return false
	end
	if blocker.hero or blocker.reinforcement then
		return false
	end

	local damage_types = blocker.health.last_damage_types or 0

	return band(damage_types, bor(DAMAGE_EAT, DAMAGE_NO_SPAWNS, DAMAGE_DISINTEGRATE, DAMAGE_DISINTEGRATE_BOSS)) == 0
end

function pirate_damage_soldiers(store, source, pos, radius, damage_min, damage_max, damage_type, max_count)
	local targets = U.find_soldiers_in_range(store.entities, pos, 0, radius, 0, 0, kr4_valid_enemy_soldier_target)
	if not targets then
		return 0
	end
	local count = 0
	for _, target in ipairs(targets) do
		count = count + 1
		if max_count and count > max_count then
			break
		end
		pirate_damage(store, source, target, math.random(damage_min, damage_max), damage_type)
	end
	return count
end

function pirate_spawn_on_path(store, template_name, owner, node_offset, pi, spi)
	local e = E:create_entity(template_name)
	if not e.nav_path then
		return nil
	end
	pi = pi or owner and owner.nav_path and owner.nav_path.pi or 1
	spi = spi or owner and owner.nav_path and owner.nav_path.spi or 1
	e.nav_path.dir = owner and owner.nav_path and owner.nav_path.dir or branch_path_dir(pi)
	e.nav_path.pi = pi
	e.nav_path.spi = spi
	e.nav_path.ni = owner and owner.nav_path and owner.nav_path.ni or P:get_start_node(pi)
	e.nav_path.ni = branch_shift_path_node(e.nav_path, node_offset or 0)
	e.pos = V.vclone(P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni))
	queue_insert(store, e)
	return e
end

function pirate_start_animation(this, animation, flip, ts, loop, sprite_ids, force_ts)
	if not sprite_ids then
		if this.animation_group then
			U.animation_start_group(this, animation, flip, ts, loop, this.animation_group)
			return
		end
		U.animation_start(this, animation, flip, ts, loop, nil, force_ts)
		return
	end
	for _, sid in ipairs(sprite_ids) do
		local sprite = this.render.sprites[sid]
		if sprite then
			local ignore_start = sprite.ignore_start
			sprite.ignore_start = false
			U.animation_start(this, animation, flip, ts, loop, sid, force_ts)
			sprite.ignore_start = ignore_start
			if sprite.zeta_attached_offset then
				sprite.offset.x = (sprite.flip_x and -1 or 1) * sprite.zeta_attached_offset.x
				sprite.offset.y = sprite.zeta_attached_offset.y
			end
		end
	end
end

function pirate_cannon_warning(store, pos, duration)
	local warning = E:create_entity("fx_pirate_cannon_warning")
	warning.pos = V.vclone(pos)
	warning.duration = duration
	queue_insert(store, warning)
end

function kr4_insert_one_shot_fx(store, template_name, pos, duration)
	local fx = E:create_entity(template_name)

	fx.pos = V.vclone(pos)

	if duration and fx.timed then
		fx.timed.duration = duration
	end

	if fx.render and fx.render.sprites then
		for _, s in pairs(fx.render.sprites) do
			s.ts = store.tick_ts
			s.loop = false
		end
	end

	queue_insert(store, fx)

	return fx
end

function pirate_cannon_impact(store, pos)
	kr4_insert_one_shot_fx(store, "fx_kr4_explosion_fragment", pos, 1)
end

function pirate_play_cast(store, this, animation, cast_time, target, sprite_ids)
	local flip = target and target.pos and target.pos.x < this.pos.x or nil
	local animation_name = animation or "idle"
	if target and target.pos and not sprite_ids then
		animation_name, flip = U.animation_name_facing_point(this, animation_name, target.pos)
	end
	pirate_start_animation(this, animation_name, flip, store.tick_ts, false, sprite_ids)
	local ts = store.tick_ts
	while store.tick_ts - ts < (cast_time or 0) do
		if this.health.dead or this.unit.is_stunned then
			return false
		end
		coroutine.yield()
	end
	return true
end

function pirate_play_full_animation(store, this, animation, target, sprite_ids)
	local flip = target and target.pos and target.pos.x < this.pos.x or nil
	pirate_start_animation(this, animation or "idle", flip, store.tick_ts, false, sprite_ids)
	local wait_sid = sprite_ids and sprite_ids[1] or 1
	while not U.animation_finished(this, wait_sid) do
		if this.health.dead or this.unit.is_stunned then
			return false
		end
		coroutine.yield()
	end
	return true
end

function kr4_enemy_walk_path_step(store, this, animation_name)
	if not this.nav_path then
		coroutine.yield()
		return false
	end

	local next_pos

	if this.motion.forced_waypoint then
		next_pos = this.motion.forced_waypoint

		if V.dist(next_pos.x, next_pos.y, this.pos.x, this.pos.y) < 2 * this.motion.max_speed * store.tick_length then
			this.pos.x, this.pos.y = next_pos.x, next_pos.y
			this.motion.forced_waypoint = nil
			this.motion.speed.x, this.motion.speed.y = 0, 0
			coroutine.yield()
			return true
		end
	else
		next_pos = P:next_entity_node(this, store.tick_length)

		if not next_pos then
			coroutine.yield()
			return false
		end
	end

	if animation_name then
		local an, af = U.animation_name_facing_point(this, animation_name, next_pos)
		local s = this.render and this.render.sprites and this.render.sprites[1]

		if s and (s.name ~= an or s.flip_x ~= af) then
			if this.animation_group then
				U.animation_start_group(this, an, af, store.tick_ts, true, this.animation_group)
			else
				U.animation_start(this, an, af, store.tick_ts, true, nil, true)
			end
		end
	end

	U.set_destination(this, next_pos)
	U.walk(this, store.tick_length)
	coroutine.yield()
	this.motion.speed.x, this.motion.speed.y = 0, 0

	return true
end

-- 复用前代引擎的追踪弹更新，只替换其固定的 "flying" 起手动画名。
scripts.pirate_bolt = {}

function scripts.pirate_bolt.insert(this, store)
	local b = this.bullet
	b.speed.x, b.speed.y = V.normalize(b.to.x - b.from.x, b.to.y - b.from.y)
	U.animation_start(this, "travel", nil, store.tick_ts, true, nil, true)
	return true
end

scripts.blackthorne_cluster_controller = {}

function scripts.blackthorne_cluster_controller.update(this, store)
	for _ = 1, this.count do
		local fragment = E:create_entity(this.fragment)
		fragment.pos = V.vclone(this.pos)
		fragment.bullet.from = V.vclone(this.pos)
		fragment.bullet.to = V.v(this.pos.x + math.random(-70, 70), this.pos.y + math.random(-45, 45))
		fragment.bullet.source_id = this.source_id
		queue_insert(store, fragment)
	end
	queue_remove(store, this)
end

scripts.mod_pirate_stat_buff = {}

function scripts.mod_pirate_stat_buff.insert(this, store)
	local target = store.entities[this.modifier.target_id]
	if not target or not target.unit or not target.motion then
		return false
	end
	target.unit.damage_factor = target.unit.damage_factor * this.damage_factor
	target.motion.max_speed = target.motion.max_speed * this.speed_factor
	return true
end

function scripts.mod_pirate_stat_buff.remove(this, store)
	local target = store.entities[this.modifier.target_id]
	if target and target.unit and target.motion then
		target.unit.damage_factor = target.unit.damage_factor / this.damage_factor
		target.motion.max_speed = target.motion.max_speed / this.speed_factor
	end
	return true
end

scripts.mod_shark_lifesteal = {}

function scripts.mod_shark_lifesteal.insert(this, store)
	local source = store.entities[this.modifier.source_id]
	if source and source.health and not source.health.dead then
		source.health.hp = km.clamp(0, source.health.hp_max, source.health.hp + (this.heal or 0))
	end
	return false
end

scripts.mod_ghostly_barge_armor = {}

function scripts.mod_ghostly_barge_armor.insert(this, store)
	local target = store.entities[this.modifier.target_id]
	if not target or not target.health then
		return false
	end
	this._old_magic_armor = target.health.magic_armor
	target.health.magic_armor = km.clamp(0, 1, (target.health.magic_armor or 0) + this.magic_armor)
	return true
end

function scripts.mod_ghostly_barge_armor.remove(this, store)
	local target = store.entities[this.modifier.target_id]
	if target and target.health then
		target.health.magic_armor = this._old_magic_armor or 0
	end
	return true
end

scripts.mod_pirate_tower_block = {}

function scripts.mod_pirate_tower_block.remove(this, store)
	if not this._tower_blocked then return true end
	local target = store.entities[this.modifier.target_id]
	if target and target.tower then SU.tower_block_dec(target) end
	this._tower_blocked = false
	return true
end

function scripts.mod_pirate_tower_block.update(this, store)
	local target = store.entities[this.modifier.target_id]
	if not target or not target.tower then
		queue_remove(store, this)
		return
	end
	this.modifier.ts = store.tick_ts
	this.pos = target.pos
	if this.ui then
		this.ui.clicked = nil
		this.ui.can_click = true
	end
	SU.tower_block_inc(target)
	this._tower_blocked = true
	U.animation_start(this, this.in_animation or "in", nil, store.tick_ts, false)
	if U.y_wait(store, this.in_time or 0.2, function() return not store.entities[target.id] end) then
		queue_remove(store, this)
		return
	end
	U.animation_start(this, this.loop_animation or "loop", nil, store.tick_ts, true)
	local target_gone = false
	local interrupted = U.y_wait(store, math.max(0, this.modifier.duration - 0.4), function()
		if not store.entities[target.id] then
			target_gone = true
			return true
		end
		if this.ui and this.ui.clicked then
			this.ui.clicked = nil
			if this.tap_fx then
				branch_spawn_scene(store, this.tap_fx, this.pos.x, this.pos.y + (this.tap_fx_offset_y or 0))
			end
			return true
		end
	end)
	if interrupted and target_gone then
		queue_remove(store, this)
		return
	end
	U.animation_start(this, this.out_animation or "out", nil, store.tick_ts, false)
	U.y_wait(store, this.out_time or 0.2)
	if this._tower_blocked and store.entities[target.id] then SU.tower_block_dec(target) end
	this._tower_blocked = false
	queue_remove(store, this)
end

scripts.enemy_tailblade = {}

function scripts.enemy_tailblade.on_damage(this, store, damage)
	local source = damage.source_id and store.entities[damage.source_id]
	local melee_source = source and source.soldier and this.enemy and table.contains(this.enemy.blockers, source.id)
	if not this.dodge or this.unit.is_stunned or this.health.dead or this.dodge.active or
		(this.dodge.cooldown and store.tick_ts - this.dodge.ts < this.dodge.cooldown) or
		not melee_source or band(damage.damage_type, DAMAGE_NO_DODGE) ~= 0 or math.random() > this.dodge.chance then
		return true
	end
	local e = E:create_entity("pop_miss")
	e.pos = V.vclone(this.pos)
	e.render.sprites[1].ts = store.tick_ts
	queue_insert(store, e)
	this.dodge.ts = store.tick_ts
	this.dodge.active = true
	return false
end

scripts.enemy_ghost_ship = {}

function scripts.enemy_ghost_ship.on_damage(this, store, damage)
	return not this._pirate_fog_shield
end

scripts.pirate_corpse_marker = {}

function scripts.pirate_corpse_marker.update(this, store)
	this.ts = store.tick_ts
	this.expire_ts = this.ts + this.duration
	while not this.used and store.tick_ts < this.expire_ts do
		coroutine.yield()
	end
	this.expired = true
	queue_remove(store, this)
end

scripts.mod_zeta_juggernaut_half_health = {}

function scripts.mod_zeta_juggernaut_half_health.insert(this, store)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead or target._zeta_juggernaut_half_health then
		return false
	end

	target._zeta_juggernaut_half_health = true
	target.health.hp_max = math.max(1, math.floor(target.health.hp_max * (this.health_factor or 0.5)))
	target.health.hp = math.min(target.health.hp, target.health.hp_max)

	return true
end

function pirate_spawn_corpse(store, this)
	if not this.pirate.corpse or not this.nav_path then
		return
	end
	local marker = E:create_entity("pirate_corpse_marker")
	marker.pos = V.vclone(this.pos)
	marker.pi = this.nav_path.pi
	marker.spi = this.nav_path.spi
	marker.ni = this.nav_path.ni
	marker.raise_template = this.pirate.corpse == "hanged" and "enemy_hanged_captain" or "enemy_risen_cutthroat"
	queue_insert(store, marker)
end

function pirate_on_death(store, this)
	local p = this.pirate
	if p.kind == "boom_baboon" then S:queue("kr4_enemies_pirates_baboon_explotion") end
	if p.kind == "filibusters" or p.kind == "filibusters_mini" then S:queue("group_pirates_filibusters_fall_off") end
	if p.death_fx then
		kr4_insert_one_shot_fx(store, p.death_fx, this.pos, p.death_fx_duration or 1)
	end
	if p.death_damage then
		pirate_damage_soldiers(store, this, this.pos, p.death_damage.radius, p.death_damage.damage_min, p.death_damage.damage_max, p.death_damage.damage_type, p.death_damage.max_count)
	end
	if p.death_spawns and (not p.safe_nodes_to_exit or pirate_nodes_to_exit(this) > p.safe_nodes_to_exit) then
		for i, name in ipairs(p.death_spawns) do
			pirate_spawn_on_path(store, name, this, i - 1)
		end
	end
	if p.death_cage then
		local cage = E:create_entity(p.death_cage.template or "blackthorne_prisoner_box_small")
		local pos = p.death_cage.pos or V.v(this.pos.x + (p.death_cage.offset and p.death_cage.offset.x or 0), this.pos.y + (p.death_cage.offset and p.death_cage.offset.y or 0))
		cage.pos = V.vclone(pos)
		cage.delay = p.death_cage.delay or 0
		if p.death_cage.sound ~= nil then
			cage.sound = p.death_cage.sound
		end
		for _, s in ipairs(cage.render.sprites) do
			s.flip_x = p.death_cage.flip_x or false
		end
		queue_insert(store, cage)
	end
	pirate_spawn_corpse(store, this)
	if p.end_level_on_death then
		branch_kill_all_enemies_for_victory(store)
	end
end

function pirate_tick_passives(store, this)
	local p = this.pirate
	if p.rush then
		local defenders = U.find_soldiers_in_range(store.entities, this.pos, 0, p.rush.radius, 0, F_FLYING, kr4_valid_enemy_soldier_target)
		local wanted = defenders and pirate_nodes_to_exit(this) > (p.rush.safe_nodes_to_exit or 0) and p.rush.factor or 1
		if wanted ~= (p._rush_factor or 1) then
			this.motion.max_speed = this.motion.max_speed / (p._rush_factor or 1) * wanted
			p._rush_factor = wanted
			this.render.sprites[1].angles.walk = wanted == 1 and {"walk", "walkUp", "walkDown"} or {"rollWalk", "rollWalkUp", "rollWalkDown"}
		end
	end
	if p.rager then
		local allies = U.find_enemies_in_range(store.entities, this.pos, 0, p.rager.radius, 0, 0, function(e)
			return e.id ~= this.id and e.template_name == this.template_name
		end)
		if allies then
			p._rager_until = store.tick_ts + p.rager.linger
		end
		local wanted = p._rager_until and store.tick_ts < p._rager_until and p.rager.factor or 1
		this.unit.damage_factor = this.unit.damage_factor / (p._rager_factor or 1) * wanted
		p._rager_factor = wanted
	end
	if p.fog_speed then
		local active = this._in_pirate_fog and true or false
		if active ~= (p._fog_speed_active or false) then
			local factor = p.fog_speed / (p._base_speed or this.motion.max_speed)
			this.motion.max_speed = this.motion.max_speed * (active and factor or 1 / factor)
			p._fog_speed_active = active
		end
	end
	if p.phase_thresholds and this.nav_path then
		local next_phase = (p._phase or 0) + 1
		local threshold = p.phase_thresholds[next_phase]
		if threshold and this.health.hp <= this.health.hp_max * threshold then
			p._phase = next_phase
			local new_pi = p.phase_paths and p.phase_paths[next_phase] or (next_phase == 1 and 2 or 1)
			local nodes = P:nearest_nodes(this.pos.x, this.pos.y, {new_pi}, nil, true)
			if nodes and #nodes > 0 then
				this.nav_path.pi, this.nav_path.spi, this.nav_path.ni = nodes[1][1], nodes[1][2], nodes[1][3]
				this.pos = V.vclone(P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni))
			end
		end
	end
	if p.rolling_damage and (not p._rolling_ts or store.tick_ts - p._rolling_ts >= p.rolling_damage.cooldown) then
		p._rolling_ts = store.tick_ts
		pirate_damage_soldiers(store, this, this.pos, p.rolling_damage.radius, p.rolling_damage.damage, p.rolling_damage.damage, DAMAGE_PHYSICAL)
	end
	if p.stomp and (not p._stomp_ts or store.tick_ts - p._stomp_ts >= p.stomp.cooldown) then
		p._stomp_ts = store.tick_ts
		pirate_damage_soldiers(store, this, this.pos, p.stomp.radius, p.stomp.damage, p.stomp.damage, DAMAGE_PHYSICAL)
	end
	if p.armor_aura and (not p._armor_ts or store.tick_ts - p._armor_ts >= p.armor_aura.cooldown) then
		p._armor_ts = store.tick_ts
		local allies = U.find_enemies_in_range(store.entities, this.pos, 0, p.armor_aura.radius, 0, 0, function(e)
			return e.id ~= this.id
		end)
		for i, e in ipairs(allies or {}) do
			if i > p.armor_aura.max_count then break end
			if not U.has_modifiers(store, e, p.armor_aura.mod) then
				local m = E:create_entity(p.armor_aura.mod)
				m.modifier.source_id = this.id
				m.modifier.target_id = e.id
				queue_insert(store, m)
			end
		end
	end
	if p.proximity then
		local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, p.proximity, 0, 0, kr4_valid_enemy_soldier_target)
		if targets then
			this.health.hp = 0
			this.health.dead = true
			return true
		end
	end
	return false
end

function pirate_find_towers(store, pos, radius)
	return table.filter(store.entities, function(_, e)
		return e.tower and not e.tower_holder and not e.tower.destroy and U.is_inside_ellipse(e.pos, pos, radius)
	end)
end

function pirate_delay_skill(skill, now, delay)
	if not skill or not skill.cooldown or not delay then return end
	local ready_ts = (skill.ts or now) + skill.cooldown
	skill.ts = math.max(ready_ts, now) + delay - skill.cooldown
end

function pirate_try_skill(store, this)
	local p = this.pirate
	local now = store.tick_ts

	if p.heal and now - (p.heal.ts or 0) >= p.heal.cooldown and this.health.hp < this.health.hp_max * p.heal.health_trigger and #this.enemy.blockers == 0 then
		p.heal.ts = now
		if pirate_play_cast(store, this, p.heal.animation, p.heal.cast_time) then
			this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + p.heal.amount)
			S:queue("kr4_enemies_pirates_corsair_heal")
		end
		return true
	end

	if p.bomb and not p._bomb_used and now - (p.bomb.ts or 0) >= p.bomb.cooldown then
		local target = U.find_nearest_soldier(store.entities, this.pos, p.bomb.min_range, p.bomb.max_range, F_RANGED, 0, kr4_valid_enemy_soldier_target)
		if target then
			p.bomb.ts = now
			if pirate_play_cast(store, this, p.bomb.animation, p.bomb.shoot_time, target) then
				local b = E:create_entity(p.bomb.bullet)
				local animation_name, flip = U.animation_name_facing_point(this, p.bomb.animation, target.pos)
				local offset = p.bomb.shoot_offsets and p.bomb.shoot_offsets[animation_name] or v(0, 0)
				b.pos = V.v(this.pos.x + (flip and -offset.x or offset.x), this.pos.y + offset.y)
				b.bullet.from = V.vclone(b.pos)
				b.bullet.to = V.vclone(target.pos)
				b.bullet.target_id = target.id
				b.bullet.source_id = this.id
				queue_insert(store, b)
				if p.one_shot then
					p._bomb_used = true
					this.motion.max_speed = this.motion.max_speed * 1.5
					this.unit.death_animation = "twoDeath"
					this.render.sprites[1].angles.walk = {"twoWalk", "twoWalkUp", "twoWalkDown"}
				end
			end
			return true
		end
	end

	if p.buff and now - (p.buff.ts or 0) >= p.buff.cooldown and pirate_nodes_to_exit(this) > 30 then
		local allies = U.find_enemies_in_range(store.entities, this.pos, 0, p.buff.radius, 0, bor(F_BOSS, F_MINIBOSS), function(e)
			return e.id ~= this.id and not U.has_modifiers(store, e, p.buff.mod)
		end)
		if allies and #allies >= p.buff.min_count then
			p.buff.ts = now
			if not pirate_play_cast(store, this, p.buff.animation, p.buff.cast_time, allies[1]) then
				return true
			end
			for i, e in ipairs(allies) do
				if i > p.buff.max_count then break end
				local m = E:create_entity(p.buff.mod)
				m.modifier.source_id = this.id
				m.modifier.target_id = e.id
				m.modifier.duration = p.buff.duration
				queue_insert(store, m)
			end
			S:queue("kr4_enemies_pirates_apemate_buff")
			return true
		end
	end

	if p.buried and now - (p.buried.ts or 0) >= p.buried.cooldown and pirate_nodes_to_exit(this) > p.buried.safe_nodes_to_exit and #this.enemy.blockers == 0 then
		p.buried.ts = now
		S:queue("group_sharks_bullshark_dasher_dig_in")
		local old_bans = this.vis.bans
		this.vis.bans = bor(this.vis.bans, F_BLOCK, F_RANGED, F_AREA, F_MOD)
		this.motion.max_speed = this.motion.max_speed * p.buried.factor
		if p.buried.animation_in and not pirate_play_full_animation(store, this, p.buried.animation_in) then
			this.vis.bans = old_bans
			this.motion.max_speed = this.motion.max_speed / p.buried.factor
			return true
		end
		U.animation_start(this, p.buried.animation, nil, store.tick_ts, true, nil, true)
		local ts = store.tick_ts
		while not this.health.dead and store.tick_ts - ts < p.buried.duration do
			kr4_enemy_walk_path_step(store, this)
		end
		if not this.health.dead and p.buried.animation_out then
			pirate_play_full_animation(store, this, p.buried.animation_out)
		end
		this.vis.bans = old_bans
		this.motion.max_speed = this.motion.max_speed / p.buried.factor
		if not this.health.dead and this.render and this.render.sprites[1] then
			local walk = this.render.sprites[1].angles and this.render.sprites[1].angles.walk
			U.animation_start(this, walk and walk[1] or "walk", nil, store.tick_ts, true, nil, true)
		end
		S:queue("group_sharks_bullshark_dasher_dig_out")
		return true
	end

	if p.stun and now - (p.stun.ts or 0) >= p.stun.cooldown and #this.enemy.blockers > 0 then
		local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, p.stun.radius, F_BLOCK, F_FLYING, kr4_valid_enemy_soldier_target)
		if targets and #targets >= (p.stun.min_count or 1) then
			p.stun.ts = now
			S:queue("krv_sharks_hammerhead_unit_stun")
			if not pirate_play_cast(store, this, p.stun.animation, p.stun.cast_time, targets[1]) then
				return true
			end
			for i, e in ipairs(targets) do
				if i > (p.stun.max_count or #targets) then break end
				local m = E:create_entity("mod_stun")
				m.modifier.source_id = this.id
				m.modifier.target_id = e.id
				m.modifier.duration = p.stun.duration
				queue_insert(store, m)
			end
			return true
		end
	end

	local tower_block_cooldown = p.tower_block and (p.tower_block._first and p.tower_block.cooldown or p.tower_block.first_cooldown or p.tower_block.cooldown)
	if p.tower_block and now - (p.tower_block.ts or 0) >= tower_block_cooldown then
		local towers = pirate_find_towers(store, this.pos, p.tower_block.radius)
		if towers and #towers > 0 then
			p.tower_block.ts = now
			p.tower_block._first = true
			S:queue("krv_sfx_sharks_hammerhead_tower_stun")
			if not pirate_play_cast(store, this, p.tower_block.animation, p.tower_block.cast_time, towers[1], p.tower_block.sprite_ids) then
				return true
			end
			for i, tower in ipairs(towers) do
				if i > p.tower_block.max_count then break end
				local m = E:create_entity(p.tower_block.mod)
				m.modifier.source_id = this.id
				m.modifier.target_id = tower.id
				m.modifier.duration = p.tower_block.duration
				queue_insert(store, m)
			end
			return true
		end
	end

	if p.recruit and now - (p.recruit.ts or 0) >= p.recruit.cooldown and pirate_nodes_to_exit(this) > p.recruit.safe_nodes_to_exit and #this.enemy.blockers == 0 then
		local corpses = table.filter(store.entities, function(_, e)
			return e.template_name == "pirate_corpse_marker" and not e.used and not e.expired and (not e.expire_ts or now < e.expire_ts) and U.is_inside_ellipse(e.pos, this.pos, p.recruit.radius)
		end)
		if #corpses > 0 then
			local reserved = {}
			for _, corpse in ipairs(corpses) do
				if #reserved >= p.recruit.max_count then break end
				if not corpse.used and not corpse.expired then
					corpse.used = true
					corpse.used_by = this.id
					table.insert(reserved, corpse)
				end
			end
			if #reserved == 0 then
				return true
			end
			p.recruit.ts = now
			S:queue("krv_sfx_ghosts-corpse-recruiter-resurrect")
			if not pirate_play_cast(store, this, p.recruit.animation, p.recruit.cast_time, corpses[1]) then
				for _, corpse in ipairs(reserved) do
					if store.entities[corpse.id] and corpse.used_by == this.id then
						corpse.used = nil
						corpse.used_by = nil
					end
				end
				return true
			end
			for _, corpse in ipairs(reserved) do
				if store.entities[corpse.id] and not corpse.expired and (not corpse.expire_ts or store.tick_ts < corpse.expire_ts) then
					local raised = E:create_entity(corpse.raise_template)
					raised.nav_path.pi = corpse.pi
					raised.nav_path.spi = corpse.spi
					raised.nav_path.ni = corpse.ni
					raised.pos = V.vclone(corpse.pos)
					raised.pirate.spawn_animation = "spawn"
					if raised.enemy then
						raised.enemy.gold = 0
					end
					queue_insert(store, raised)
					queue_remove(store, corpse)
				end
			end
			return true
		end
	end

	if p.fog_spawn and now - (p.fog_spawn.ts or 0) >= p.fog_spawn.cooldown and pirate_nodes_to_exit(this) > p.fog_spawn.safe_nodes_to_exit and #this.enemy.blockers == 0 then
		p.fog_spawn.ts = now
		S:queue("krv_sfx_ghosts-hanged-captain-fog")
		if not pirate_play_cast(store, this, p.fog_spawn.animation, p.fog_spawn.cast_time) then
			return true
		end
		local qty = p.fog_spawn.qty or 1
		for i = 1, qty do
			local node_offset = (i - math.ceil(qty * 0.5)) * (p.fog_spawn.step_nodes or 0)
			local ni = branch_shift_path_node(this.nav_path, node_offset)
			local fog = E:create_entity("pirates_fog")
			fog.pos = V.vclone(P:node_pos(this.nav_path.pi, this.nav_path.spi, ni))
			fog.duration = p.fog_spawn.duration
			fog.radius = p.fog_spawn.radius
			fog.from_skill = true
			queue_insert(store, fog)
		end
		return true
	end

	if p.cannons and now - (p.cannons.ts or 0) >= p.cannons.cooldown and #this.enemy.blockers == 0 then
		local soldiers = U.find_soldiers_in_range(store.entities, this.pos, 0, 10000, 0, F_FLYING, function(e)
			return kr4_valid_enemy_soldier_target(e)
		end)
		if soldiers then
			p.cannons.ts = now
			if not pirate_play_cast(store, this, p.cannons.animation, p.cannons.cast_time) then
				return true
			end
			local zones = {}
			for i = 1, math.min(p.cannons.max_count, #soldiers) do
				zones[i] = V.vclone(soldiers[i].pos)
				pirate_cannon_warning(store, zones[i], p.cannons.warning_time)
			end
			S:queue("special_cannon_shot")
			local interrupted = U.y_wait(store, p.cannons.warning_time, function()
				return this.health.dead
			end)
			if interrupted then return true end
			for _, pos in ipairs(zones) do
				pirate_damage_soldiers(store, this, pos, p.cannons.radius, p.cannons.damage_min, p.cannons.damage_max, DAMAGE_TRUE)
				pirate_cannon_impact(store, pos)
			end
			S:queue("special_cannon_shot_explotion")
			return true
		end
	end

	if p.spawn_apemate and now - (p.spawn_apemate.ts or 0) >= (p.spawn_apemate._first and p.spawn_apemate.cooldown or p.spawn_apemate.first_cooldown) and pirate_nodes_to_exit(this) > p.spawn_apemate.safe_nodes_to_exit then
		p.spawn_apemate.ts = now
		p.spawn_apemate._first = true
		if not pirate_play_cast(store, this, p.spawn_apemate.animation, p.spawn_apemate.cast_time, nil, p.spawn_apemate.sprite_ids) then
			return true
		end
		pirate_spawn_on_path(store, "enemy_apemate", this, p.spawn_apemate.ahead_nodes)
		S:queue("krv_sfx_monkeys_boss_apemate_summon_op2")
		return true
	end

	if p.fruit and now - (p.fruit.ts or 0) >= p.fruit.cooldown then
		p.fruit.ts = now
		if not pirate_play_cast(store, this, p.fruit.animation, p.fruit.cast_time, nil, p.fruit.sprite_ids) then
			return true
		end
		local fx = E:create_entity("macaque_fruit_splash")
		fx.pos = v(512, 384)
		fx.duration = p.fruit.duration
		queue_insert(store, fx)
		S:queue("group_monkeys_boss_spit")
		return true
	end

	if p.spawn_sharks and now - (p.spawn_sharks.ts or 0) >= p.spawn_sharks.cooldown and pirate_nodes_to_exit(this) > (p.spawn_sharks.safe_nodes_to_exit or 0) and #this.enemy.blockers == 0 then
		p.spawn_sharks.ts = now
		S:queue("group_sharks_boss_callUnits")
		if not pirate_play_cast(store, this, p.spawn_sharks.animation, p.spawn_sharks.cast_time) then
			return true
		end
		local group = {}
		for i = 1, 2 do
			local roll = math.random()
			group[i] = roll <= 0.1 and "enemy_hammermage" or roll <= 0.7 and "enemy_tigershark_rager" or "enemy_bullshark_dasher"
		end
		for i, name in ipairs(group) do
			pirate_spawn_on_path(store, name, this, i * 10)
		end
		return true
	end

	if p.destroy_tower and now - (p.destroy_tower.ts or 0) >= p.destroy_tower.cooldown and #this.enemy.blockers == 0 then
		local towers = pirate_find_towers(store, this.pos, p.destroy_tower.radius or 10000)
		if #towers > 0 then
			p.destroy_tower.ts = now
			S:queue("krv_sfx_sharks_boss_tower_instakill")
			local target = towers[math.random(1, #towers)]
			local old_bans = this.vis.bans
			this.vis.bans = bor(this.vis.bans, F_BLOCK, F_RANGED, F_AREA, F_MOD)
			if not pirate_play_full_animation(store, this, p.destroy_tower.animation, target) then
				this.vis.bans = old_bans
				return true
			end
			U.sprites_hide(this, nil, nil, true)
			this.health_bar.hidden = true
			local interrupted = U.y_wait(store, p.destroy_tower.hidden_time, function()
				return this.health.dead
			end)
			if not interrupted and store.entities[target.id] then target.tower.destroy = true end
			U.sprites_show(this, nil, nil, true)
			this.health_bar.hidden = nil
			if not interrupted then
				pirate_play_full_animation(store, this, p.destroy_tower.return_animation)
			end
			this.vis.bans = old_bans
			return true
		end
	end

	if p.ghost_barrage and now - (p.ghost_barrage.ts or 0) >= p.ghost_barrage.cooldown then
		local targets = U.find_soldiers_in_range(store.entities, this.pos, p.ghost_barrage.min_range, p.ghost_barrage.max_range, 0, 0, kr4_valid_enemy_soldier_target)
		if targets then
			p.ghost_barrage.ts = now
			if not pirate_play_cast(store, this, p.ghost_barrage.animation, p.ghost_barrage.cast_time, targets[1]) then
				return true
			end
			U.animation_start(this, p.ghost_barrage.animation, nil, store.tick_ts, true, nil, true)
			local rounds = math.min(p.ghost_barrage.max_rounds, #targets)
			for r = 1, rounds do
				local pos = V.vclone(targets[km.zmod(r, #targets)].pos)
				for _ = 1, p.ghost_barrage.shots do
					if this.health.dead then return true end
					pirate_damage_soldiers(store, this, pos, p.ghost_barrage.radius, p.ghost_barrage.damage_min, p.ghost_barrage.damage_max, DAMAGE_MAGICAL)
					local fx = E:create_entity("fx_enemy_ghost_barrage")
					fx.pos = V.vclone(pos)
					queue_insert(store, fx)
					U.y_wait(store, 0.08)
				end
			end
			return true
		end
	end

	if p.disable_power and now - (p.disable_power.ts or 0) >= p.disable_power.cooldown then
		p.disable_power.ts = now
		S:queue("krv_sfx_ghost_captain_power_block")
		if not pirate_play_cast(store, this, p.disable_power.animation, p.disable_power.cast_time) then
			return true
		end
		signal.emit("block-random-power", math.random(p.disable_power.duration_min, p.disable_power.duration_max), "flying_ghost_ship", true)
		return true
	end

	if p.cluster_bomb and now - (p.cluster_bomb.ts or 0) >= p.cluster_bomb.cooldown and #this.enemy.blockers == 0 then
		local target = U.find_nearest_soldier(store.entities, this.pos, p.cluster_bomb.min_range, p.cluster_bomb.max_range, 0, F_FLYING, function(e)
			if not kr4_valid_enemy_soldier_target(e) then
				return false
			end

			local near = U.find_soldiers_in_range(store.entities, e.pos, 0, p.cluster_bomb.search_radius, 0, F_FLYING, kr4_valid_enemy_soldier_target)
			return near and #near >= p.cluster_bomb.min_count
		end)
		if target then
			p.cluster_bomb.ts = now
			if not pirate_play_cast(store, this, p.cluster_bomb.animation, p.cluster_bomb.cast_time, target) then
				return true
			end
			local payload = E:create_entity("enemy_blackthorne_cluster_controller")
			payload.source_id = this.id
			payload.fragment = p.cluster_bomb.fragment
			payload.count = p.cluster_bomb.count
			local bomb = E:create_entity(p.cluster_bomb.bullet)
			bomb.pos = V.v(this.pos.x, this.pos.y + 25)
			bomb.bullet.from = V.vclone(bomb.pos)
			bomb.bullet.to = V.vclone(target.pos)
			bomb.bullet.source_id = this.id
			bomb.bullet.hit_payload = payload
			queue_insert(store, bomb)
			return true
		end
	end

	if p.fly and now - (p.fly.ts or 0) >= p.fly.cooldown and #this.enemy.blockers == 0 and pirate_nodes_to_exit(this) > p.fly.safe_nodes_to_exit then
		p.fly.ts = now
		pirate_delay_skill(p.steal_gold, now, p.fly.delay_other_skills)
		S:queue("krv_sfx_blackthrone-teletransport-bosses_teleport-in")
		local old_bans = this.vis.bans
		this.vis.bans = bor(this.vis.bans, F_BLOCK, F_RANGED, F_AREA, F_MOD)
		this.motion.max_speed = this.motion.max_speed * p.fly.factor
		if p.fly.animation_in and not pirate_play_full_animation(store, this, p.fly.animation_in) then
			this.vis.bans = old_bans
			this.motion.max_speed = this.motion.max_speed / p.fly.factor
			return true
		end
		local invulnerable_left = (p.fly.invulnerable_time or 0) - (store.tick_ts - now)
		if invulnerable_left > 0 then
			U.y_wait(store, invulnerable_left)
		end
		this.vis.bans = bor(old_bans, F_BLOCK)
		U.animation_start(this, p.fly.animation, nil, store.tick_ts, true, nil, true)
		local ts = store.tick_ts
		while not this.health.dead and not this.unit.is_stunned and store.tick_ts - ts < p.fly.duration do
			kr4_enemy_walk_path_step(store, this, p.fly.animation)
		end
		if not this.health.dead and not this.unit.is_stunned and p.fly.animation_out then
			pirate_play_full_animation(store, this, p.fly.animation_out)
		end
		this.vis.bans = old_bans
		this.motion.max_speed = this.motion.max_speed / p.fly.factor
		S:queue("krv_sfx_blackthrone-teletransport-bosses_teleport-out")
		return true
	end

	if p.steal_gold and now - (p.steal_gold.ts or 0) >= p.steal_gold.cooldown and store.player_gold >= p.steal_gold.min_gold then
		p.steal_gold.ts = now
		pirate_delay_skill(p.fly, now, p.steal_gold.delay_other_skills)
		if not pirate_play_cast(store, this, p.steal_gold.animation, p.steal_gold.cast_time) then
			return true
		end
		if p.steal_gold.parrot_fx then
			local parrot = E:create_entity(p.steal_gold.parrot_fx)
			local offset = p.steal_gold.parrot_offset or v(70, 55)
			local amount = math.min(store.player_gold, p.steal_gold.fixed + math.floor(store.player_gold * p.steal_gold.factor))
			parrot.pos = V.v(this.pos.x + offset.x, this.pos.y + offset.y)
			parrot.loop_time = p.steal_gold.loop_time or parrot.loop_time
			parrot.steal_amount = amount
			parrot.steal_sound = "kr4_pirates_sfx_blackthorne_gold_steal"
			queue_insert(store, parrot)
		end
		if p.steal_gold.loop_animation and p.steal_gold.loop_time and p.steal_gold.loop_time > 0 then
			U.animation_start(this, p.steal_gold.loop_animation, nil, store.tick_ts, true, nil, true)
			local interrupted = U.y_wait(store, p.steal_gold.loop_time, function()
				return this.health.dead or this.unit.is_stunned
			end)
			if interrupted then return true end
		end
		if not p.steal_gold.parrot_fx then
			local amount = math.min(store.player_gold, p.steal_gold.fixed + math.floor(store.player_gold * p.steal_gold.factor))
			store.player_gold = math.max(0, store.player_gold - amount)
			S:queue("kr4_pirates_sfx_blackthorne_gold_steal")
		end
		if p.steal_gold.out_animation then
			pirate_play_full_animation(store, this, p.steal_gold.out_animation)
		end
		return true
	end

	if p.kraken and now - (p.kraken.ts or 0) >= p.kraken.cooldown then
		local towers = pirate_find_towers(store, this.pos, p.kraken.radius or 10000)
		if #towers > 0 then
			p.kraken.ts = now
			pirate_delay_skill(p.fly, now, p.kraken.delay_other_skills)
			pirate_delay_skill(p.steal_gold, now, p.kraken.delay_other_skills)
			S:queue("krv_sfx_blackthrone_kraken-towerkill-cast")
			if not pirate_play_cast(store, this, p.kraken.animation, p.kraken.cast_time) then
				return true
			end
			table.sort(towers, function(a, b) return (a.tower.price or 0) > (b.tower.price or 0) end)
			local picked = table.slice(towers, 1, math.min(p.kraken.max_towers, #towers))
			for _, tower in ipairs(picked) do SU.tower_block_inc(tower) end
			local interrupted = U.y_wait(store, p.kraken.delay, function()
				return this.health.dead
			end)
			if interrupted then
				for _, tower in ipairs(picked) do
					if store.entities[tower.id] then SU.tower_block_dec(tower) end
				end
				return true
			end
			if picked[1] and store.entities[picked[1].id] then
				picked[1].tower.destroy = true
				S:queue("krv_sfx_blackthrone_kraken-towerkill-towerDestroy")
			end
			for i = 2, #picked do if store.entities[picked[i].id] then SU.tower_block_dec(picked[i]) end end
			return true
		end
	end

	return false
end

scripts.enemy_pirate = {}

function scripts.enemy_pirate.blockers_only(this, store, attack, target)
	return this.enemy and table.contains(this.enemy.blockers, target.id)
end

function scripts.enemy_pirate.update(this, store, script)
	local p = this.pirate
	if not p._initialized then
		p._initialized = true
		p._base_speed = this.motion.max_speed
		for _, cfg in pairs(p) do
			if type(cfg) == "table" and (cfg.cooldown or cfg.first_cooldown) then
				cfg.ts = store.tick_ts - (cfg.start_ready and (cfg.cooldown or 0) or 0)
			end
		end
	end
	if p.spawn_animation then
		local spawn_animation = p.spawn_animation
		p.spawn_animation = nil
		if p.spawn_sound then S:queue(p.spawn_sound) end
		local old_bans = this.vis.bans
		this.vis.bans = bor(this.vis.bans, F_BLOCK, F_RANGED, F_AREA, F_MOD)
		pirate_play_full_animation(store, this, spawn_animation)
		this.vis.bans = old_bans
	end

	local break_fn = function(store, entity)
		if pirate_tick_passives(store, entity) then
			return true
		end
		return pirate_try_skill(store, entity)
	end

	while true do
		if this.health.dead then
			for _, sid in ipairs(p.hide_sprite_ids_on_death or {}) do
				if this.render.sprites[sid] then this.render.sprites[sid].hidden = true end
			end
			pirate_on_death(store, this)
			SU.hide_shadow(this, true)
			if p.boss_death then
				if this.health_bar then
					this.health_bar.hidden = true
				end
				if this.ui then
					this.ui.can_click = false
					this.ui.z = -1
				end
				if this.sound_events and this.sound_events.death then
					S:queue(this.sound_events.death, this.sound_events.death_args)
				end

				local animation = p.boss_death.animation or this.unit.death_animation or "death"

				pirate_start_animation(this, animation, nil, store.tick_ts, false)

				local death_ts = store.tick_ts
				local max_time = p.boss_death.max_time or 5

				while store.tick_ts - death_ts < max_time and not U.animation_finished(this, 1) do
					coroutine.yield()
				end

				if p.boss_death.loop_animation then
					pirate_start_animation(this, p.boss_death.loop_animation, nil, store.tick_ts, true)
				end

				U.y_wait(store, p.boss_death.delay or 0)
				this.health.death_finished_ts = store.tick_ts
				queue_remove(store, this)
				return
			end
			if p.remove_on_death then
				if this.health_bar then
					this.health_bar.hidden = true
				end
				if this.ui then
					this.ui.can_click = false
					this.ui.z = -1
				end
				U.sprites_hide(this, nil, nil, true)
				queue_remove(store, this)
				return
			end
			SU.y_enemy_death(store, this)
			return
		end
		if this.unit.is_stunned then
			if this.dodge then this.dodge.active = false end
			SU.y_enemy_stun(store, this)
		elseif this.dodge and this.dodge.active then
			this.dodge.active = false
			U.animation_start(this, this.dodge.animation, nil, store.tick_ts, false)
			U.y_animation_wait(this)
		else
			pirate_tick_passives(store, this)
			SU.y_enemy_mixed_walk_melee_ranged(store, this, false, break_fn, break_fn, break_fn)
			coroutine.yield()
		end
	end
end

scripts.macaque_fruit_splash = {}

function scripts.macaque_fruit_splash.update(this, store)
	this.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts
	while store.tick_ts - this.ts < this.duration do
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.blackthorne_coin_parrot = {}

function scripts.blackthorne_coin_parrot.update(this, store)
	U.animation_start(this, "in", nil, store.tick_ts, false)
	while not U.animation_finished(this) do
		coroutine.yield()
	end
	U.animation_start(this, "loop", nil, store.tick_ts, true)
	local loop_time = this.loop_time or 5
	local steal_amount = this.steal_amount or 0
	local stolen = 0
	local steal_ts = store.tick_ts
	local sound_played = false

	while store.tick_ts - steal_ts < loop_time do
		if steal_amount > 0 then
			local progress = km.clamp(0, 1, (store.tick_ts - steal_ts) / loop_time)
			local expected = math.floor(steal_amount * progress)
			local delta = math.min(store.player_gold or 0, expected - stolen)

			if delta > 0 then
				store.player_gold = math.max(0, (store.player_gold or 0) - delta)
				stolen = stolen + delta
				if this.steal_sound and not sound_played then
					S:queue(this.steal_sound)
					sound_played = true
				end
			end
		end
		coroutine.yield()
	end

	if steal_amount > stolen then
		local delta = math.min(store.player_gold or 0, steal_amount - stolen)
		if delta > 0 then
			store.player_gold = math.max(0, (store.player_gold or 0) - delta)
			if this.steal_sound and not sound_played then
				S:queue(this.steal_sound)
			end
		end
	end

	U.animation_start(this, "out", nil, store.tick_ts, false)
	while not U.animation_finished(this) do
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.blackthorne_prisoner_box = {}

function scripts.blackthorne_prisoner_box.update(this, store)
	if this.delay and this.delay > 0 then
		U.sprites_hide(this, nil, nil, true)
		U.y_wait(store, this.delay)
		U.sprites_show(this, nil, nil, true)
	end
	if this.sound then
		S:queue(this.sound)
	end
	for i, _ in ipairs(this.render.sprites) do
		U.animation_start(this, "run", nil, store.tick_ts, false, i, true)
	end
	while not U.animation_finished(this, 1) do
		coroutine.yield()
	end
	while true do
		coroutine.yield()
	end
end

scripts.stage39_deep_king_scene = {}

function scripts.stage39_deep_king_scene.update(this, store)
	local animation = this.animation or "idle"
	for i, _ in ipairs(this.render.sprites) do
		U.animation_start(this, animation, nil, store.tick_ts, not this.one_shot, i, true)
	end
	if this.one_shot then
		while not U.animation_finished(this, 1) do
			coroutine.yield()
		end
		queue_remove(store, this)
		return
	end
	while not this.remove do
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.stage41_blackthorne_scene = {}

function scripts.stage41_blackthorne_scene.update(this, store)
	local function play(animation, loop, duration)
		U.animation_start(this, animation, nil, store.tick_ts, loop)
		if loop then
			U.y_wait(store, duration or 0)
		else
			while not U.animation_finished(this) do
				coroutine.yield()
			end
		end
	end

	play("idle", true, 0)

	while not this.remove do
		local action = this.action
		this.action = nil
		if not action and this.actions and #this.actions > 0 then
			action = table.remove(this.actions, 1)
		end
		if action == "steal" then
			play("tiefIn", false)
			play("tiefLoop", true, this.loop_time or 5)
			play("tiefOut", false)
			play("idle", true, 0)
		elseif action == "ability" then
			play("ability", false)
			play("idle", true, 0)
		else
			coroutine.yield()
		end
	end
	queue_remove(store, this)
end

---------------------------------------------------------

function pirate_level_damage(store, source, target, value, damage_type)
	if not target or not target.health or target.health.dead then return end
	local d = E:create_damage()
	d.source_id = source and source.id or nil
	d.target_id = target.id
	d.value = value
	d.damage_type = damage_type
	queue_damage(store, d)
end

function pirate_level_damage_area(store, source, pos, radius, damage_min, damage_max, damage_type)
	local targets = U.find_soldiers_in_range(store.entities, pos, 0, radius, 0, 0, kr4_valid_enemy_soldier_target)
	for _, target in ipairs(targets or {}) do
		pirate_level_damage(store, source, target, math.random(damage_min, damage_max), damage_type)
	end
end

function pirate_level_spawn(store, template_name, pi, spi, ni)
	local e = E:create_entity(template_name)
	e.nav_path.pi = pi or 1
	e.nav_path.spi = spi or 1
	e.nav_path.dir = branch_path_dir(e.nav_path.pi)
	e.nav_path.ni = ni or P:get_start_node(e.nav_path.pi)
	e.nav_path.ni = branch_clamp_path_node(e.nav_path.pi, e.nav_path.ni)
	e.pos = V.vclone(P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni))
	queue_insert(store, e)
	return e
end

function pirate_level_spawn_from_pos(store, template_name, spawn_pos)
	local nodes = spawn_pos and P:nearest_nodes(spawn_pos.x, spawn_pos.y, nil, nil, true)

	if not nodes or not nodes[1] then
		return nil
	end

	return branch_spawn_from_pos_to_path(store, template_name, spawn_pos, nodes[1][1], nodes[1][2], nodes[1][3])
end

local stage37_house_spawners = {
	v(752, 320),
	v(535, 488)
}

function pirate_stage37_house_spawn(store, template_name, spawner_index)
	local pos = stage37_house_spawners[spawner_index or 1] or stage37_house_spawners[1]

	return pirate_level_spawn_from_pos(store, template_name, V.vclone(pos))
end

function pirate_entity_sprite_name(e)
	return e.render and e.render.sprites and e.render.sprites[1] and e.render.sprites[1].name
end

function pirate_remove_scene_sprites(store, names, predicate)
	for _, e in pairs(store.entities) do
		local name = pirate_entity_sprite_name(e)
		if name and names[name] and (not predicate or predicate(e)) then
			queue_remove(store, e)
		end
	end
end

local stage38_river_mask_names = {
	stage38_mask_1 = true,
	stage38_mask_2 = true,
	stage38_mask_3 = true
}

function pirate_stage38_river_masks(store)
	local masks = {}

	for _, e in pairs(store.entities) do
		local name = pirate_entity_sprite_name(e)

		if name and stage38_river_mask_names[name] and e.render and e.render.sprites and e.render.sprites[1] then
			table.insert(masks, e)
		end
	end

	return masks
end

function pirate_stage38_prepare_river(store)
	for _, e in ipairs(pirate_stage38_river_masks(store)) do
		e.render.sprites[1].alpha = 0
	end
end

function pirate_stage38_dry_river(store)
	local masks = pirate_stage38_river_masks(store)
	local duration = 1.4
	local start_ts = store.tick_ts

	pirate_remove_scene_sprites(store, {water_sparks_run = true}, function(e)
		return e.pos and e.pos.x > 250 and e.pos.x < 900 and e.pos.y > 250 and e.pos.y < 650
	end)

	while store.tick_ts - start_ts < duration do
		local alpha = km.clamp(0, 255, math.floor(255 * (store.tick_ts - start_ts) / duration))

		for _, e in ipairs(masks) do
			if store.entities[e.id] and e.render and e.render.sprites and e.render.sprites[1] then
				e.render.sprites[1].alpha = alpha
			end
		end

		coroutine.yield()
	end

	for _, e in ipairs(masks) do
		if store.entities[e.id] and e.render and e.render.sprites and e.render.sprites[1] then
			e.render.sprites[1].alpha = 255
		end
	end
end

function pirate_stage189_idle(store)
	local e = E:create_entity("stage39_deep_king_throne_scene")
	e.pos = v(512, 384)
	e.animation = "idle"
	queue_insert(store, e)
	return e
end

function pirate_stage189_deep_king_intro(store)
	local sequence = {{3, 1, "spawn"}, {5, 1, "taunt"}, {1, 1, "taunt"}}
	for _, cfg in ipairs(sequence) do
		local pi, spi, animation = cfg[1], cfg[2], cfg[3]
		local ni = P:get_start_node(pi)
		local pos = V.vclone(P:node_pos(pi, spi, ni))
		local splash = E:create_entity("stage39_deep_king_splash")
		splash.pos = V.vclone(pos)
		queue_insert(store, splash)
		local scene = E:create_entity("stage39_deep_king_throne_scene")
		scene.pos = pos
		scene.animation = animation
		scene.one_shot = true
		queue_insert(store, scene)
		U.y_wait(store, animation == "spawn" and 1.1 or 0.65)
	end
end

function pirate_stage41_blackthorne(store)
	for _, e in pairs(store.entities) do
		if e.template_name == "stage41_blackthorne_scene" then
			return e
		end
	end
end

function pirate_stage41_queue_action(scene, action)
	if scene then
		scene.actions = scene.actions or {}
		table.insert(scene.actions, action)
	end
end

function pirate_stage41_steal(store, scene, pos, amount)
	amount = math.min(store.player_gold, amount or 150)
	if amount <= 0 then
		return
	end
	pirate_stage41_queue_action(scene, "steal")
	local parrot = E:create_entity("blackthorne_coin_parrot")
	parrot.pos = pos and V.vclone(pos) or v(170, 30)
	parrot.loop_time = 5
	parrot.steal_amount = amount
	parrot.steal_sound = "kr4_pirates_sfx_blackthorne_gold_steal"
	queue_insert(store, parrot)
end

local stage41_blocked_holder_data = {
	["11"] = {pos = v(295, 568), rally = v(298, 524)},
	["12"] = {pos = v(289, 216), rally = v(213, 271)},
	["13"] = {pos = v(312, 449), rally = v(375, 486)}
}

local stage41_grid_open_ranges = {
	[1] = {
		{0, 20, 14},
		{0, 26, 15},
		{0, 26, 16},
		{0, 26, 17},
		{35, 42, 17},
		{0, 26, 18},
		{35, 43, 18},
		{15, 26, 19},
		{35, 44, 19},
		{15, 27, 20},
		{35, 44, 20},
		{15, 28, 21},
		{35, 45, 21},
		{16, 28, 22},
		{33, 45, 22},
		{17, 43, 23},
		{19, 45, 24},
		{50, 55, 24},
		{19, 56, 25},
		{20, 57, 26},
		{20, 57, 27},
		{19, 56, 28},
		{17, 55, 29},
		{0, 54, 30},
		{0, 54, 31},
		{0, 53, 32},
		{0, 31, 33},
		{40, 50, 33},
		{0, 12, 34},
		{41, 49, 34},
		{42, 49, 35},
		{43, 50, 36},
		{43, 44, 37}
	},
	[2] = {
		{0, 29, 14},
		{0, 32, 15},
		{0, 33, 16},
		{0, 42, 17},
		{0, 43, 18},
		{13, 44, 19},
		{14, 44, 20},
		{15, 45, 21},
		{16, 45, 22},
		{17, 43, 23},
		{19, 45, 24},
		{50, 55, 24},
		{19, 56, 25},
		{20, 57, 26},
		{20, 57, 27},
		{19, 56, 28},
		{17, 55, 29},
		{0, 54, 30},
		{0, 54, 31},
		{0, 53, 32},
		{0, 31, 33},
		{40, 50, 33},
		{0, 12, 34},
		{41, 49, 34},
		{42, 49, 35},
		{43, 50, 36},
		{43, 44, 37}
	}
}

function pirate_stage41_apply_grid_patch(step)
	for _, range in ipairs(stage41_grid_open_ranges[step] or {}) do
		local c1, c2, row = range[1], range[2], range[3]

		for col = c1, c2 do
			if GR.grid[col + 1] then
				GR:set_cell(col + 1, row + 1, TERRAIN_LAND)
			end
		end
	end

	if GR.waypoints_cache then
		GR.waypoints_cache.from_c = nil
		GR.waypoints_cache.to_c = nil
		GR.waypoints_cache.path_c = nil
		GR.waypoints_cache.path = nil
	end
end

function pirate_stage41_blocked_holder_id(e)
	if e.tower and e.tower.holder_id then
		return tostring(e.tower.holder_id)
	end
	if e.pos then
		for id, cfg in pairs(stage41_blocked_holder_data) do
			if math.abs(e.pos.x - cfg.pos.x) < 4 and math.abs(e.pos.y - cfg.pos.y) < 4 then
				return id
			end
		end
	end
end

function pirate_stage41_open_holders(store, holder_ids)
	local ids = {}
	for _, id in ipairs(holder_ids) do ids[tostring(id)] = true end
	for _, e in pairs(store.entities) do
		local holder_id = pirate_stage41_blocked_holder_id(e)
		if e.template_name == "pirates_blocked" and holder_id and ids[holder_id] then
			local cfg = stage41_blocked_holder_data[holder_id]
			local burst = E:create_entity("stage41_burst")
			burst.pos = V.vclone(e.pos)
			queue_insert(store, burst)
			local holder = E:create_entity("tower_holder")
			holder.pos = V.vclone(e.pos)
			if holder.tower then
				holder.tower.terrain_style = e.tower and e.tower.terrain_style or 7
				holder.tower.holder_id = e.tower and e.tower.holder_id or holder_id
				holder.tower.default_rally_pos = e.tower and e.tower.default_rally_pos and V.vclone(e.tower.default_rally_pos) or cfg and V.vclone(cfg.rally) or nil
			end
			if holder.ui then
				holder.ui.nav_mesh_id = e.ui and e.ui.nav_mesh_id or holder_id
			end
			queue_insert(store, holder)
			queue_remove(store, e)
		end
	end
end

function pirate_stage41_open_path(store, scene, step)
	pirate_stage41_queue_action(scene, "ability")
	pirate_stage41_apply_grid_patch(step)
	local positions = step == 1 and {v(90, 260), v(180, 270), v(228, 200), v(127, 210), v(70, 290), v(30, 210)} or {v(362, 535), v(300, 500), v(335, 461), v(400, 480), v(430, 445)}
	for _, pos in ipairs(positions) do
		local burst = E:create_entity("stage41_burst")
		burst.pos = V.vclone(pos)
		queue_insert(store, burst)
	end
	S:queue("kr4_level41_pirates_sfx_barrel_explotion")
	if step == 1 then
		pirate_stage41_open_holders(store, {12})
		pirate_remove_scene_sprites(store, {stage_41_mask03 = true})
	else
		pirate_stage41_open_holders(store, {11, 13})
		pirate_remove_scene_sprites(store, {stage_41_mask04 = true})
	end
end

scripts.pirates_fog = {}

function pirate_fog_enter(this, target)
	target._pirate_fogs = target._pirate_fogs or {}
	if target._pirate_fogs[this.id] then return end
	local first_fog = next(target._pirate_fogs) == nil
	target._pirate_fogs[this.id] = true
	if first_fog and target.soldier and target.unit then
		target.unit.damage_factor = target.unit.damage_factor * 0.7
	end
	if target.enemy then
		target._in_pirate_fog = true
		if target.pirate and target.pirate.fog_immortality then
			target._pirate_fog_shield = true
			if target.vis and not target._pirate_fog_bans then
				target._pirate_fog_bans = U.push_bans(target.vis, bor(F_RANGED, F_AREA))
			end
		end
	end
end

function pirate_fog_leave(this, target)
	if not target._pirate_fogs or not target._pirate_fogs[this.id] then return end
	target._pirate_fogs[this.id] = nil
	local any_fog = next(target._pirate_fogs) ~= nil
	if not any_fog and target.soldier and target.unit then
		target.unit.damage_factor = target.unit.damage_factor / 0.7
	end
	if target.enemy and not any_fog then
		target._in_pirate_fog = nil
		target._pirate_fog_shield = nil
		if target.vis and target._pirate_fog_bans then
			U.pop_bans(target.vis, target._pirate_fog_bans)
			target._pirate_fog_bans = nil
		end
	end
end

function pirate_fog_raise_dead(store, target)
	if target._pirate_fog_raised or not target.soldier or not target.health.dead then return end
	local raise_window = 2
	if target.health.death_ts and store.tick_ts - target.health.death_ts > raise_window then return end
	if not target._kr4_last_damage_ts or store.tick_ts - target._kr4_last_damage_ts > raise_window then return end
	if target._kr4_last_damage_template ~= "enemy_hanged_captain" and target._kr4_last_damage_pirate_kind ~= "hanged_captain" then return end
	target._pirate_fog_raised = true
	local nodes = P:nearest_nodes(target.pos.x, target.pos.y, nil, nil, true)
	if not nodes or #nodes < 1 then return end
	local pi, spi, ni = unpack(nodes[1])
	local raised = E:create_entity("enemy_risen_cutthroat")
	raised.nav_path.pi = pi
	raised.nav_path.spi = spi
	raised.nav_path.ni = ni
	raised.pos = V.vclone(target.pos)
	raised.render.sprites[1].name = "raise"
	if raised.enemy then
		raised.enemy.gold = 0
	end
	queue_insert(store, raised)
end

function scripts.pirates_fog.update(this, store)
	while true do
		while not this.active and not this.from_skill do
			this.render.sprites[1].hidden = true
			coroutine.yield()
		end
		this.render.sprites[1].hidden = false
		this.ts = store.tick_ts
		local touched = {}
		while store.tick_ts - this.ts < this.duration do
			for _, e in pairs(store.entities) do
				if e.vis and e.health and (e.soldier or e.enemy) and U.is_inside_ellipse(e.pos, this.pos, this.radius) then
					touched[e.id] = e
					pirate_fog_enter(this, e)
					pirate_fog_raise_dead(store, e)
				elseif touched[e.id] then
					pirate_fog_leave(this, e)
					touched[e.id] = nil
				end
			end
			coroutine.yield()
		end
		for _, e in pairs(touched) do pirate_fog_leave(this, e) end
		if this.controller_owned then
			this.active = false
			this.render.sprites[1].hidden = true
		else
			queue_remove(store, this)
			return
		end
	end
end

scripts.pirates_stage_controller = {}

scripts.stage37_pirate_ship = {}

function scripts.stage37_pirate_ship.update(this, store)
	local campaign = store.level_mode == GAME_MODE_CAMPAIGN
	this.idle_animation = campaign and "idle" or "idleShip"
	this.signal_animation = campaign and "signal" or "signalShip"
	U.animation_start(this, this.idle_animation, nil, store.tick_ts, true, 1, true)
	U.animation_start(this, this.idle_animation, nil, store.tick_ts, true, 2, true)

	while not this.remove do
		if this.signal then
			this.signal = false
			U.animation_start(this, this.signal_animation, nil, store.tick_ts, false, 1)
			U.animation_start(this, this.signal_animation, nil, store.tick_ts, false, 2)
			U.animation_start(this, "attack", nil, store.tick_ts, false, 7)
			U.animation_start(this, "attack", nil, store.tick_ts, false, 8)
			while not this.remove and not U.animation_finished(this, 1) do
				coroutine.yield()
			end
			if not this.remove then
				U.animation_start(this, this.idle_animation, nil, store.tick_ts, true, 1, true)
				U.animation_start(this, this.idle_animation, nil, store.tick_ts, true, 2, true)
				U.animation_start(this, "idle", nil, store.tick_ts, true, 7, true)
				U.animation_start(this, "idle", nil, store.tick_ts, true, 8, true)
			end
		end
		coroutine.yield()
	end
	queue_remove(store, this)
end

function pirate_stage37_ship(store)
	for _, e in pairs(store.entities) do
		if e.template_name == "stage37_pirate_ship" then
			return e
		end
	end
end

function pirate_controller_activate_fog(store, predicate, duration)
	for _, e in pairs(store.entities) do
		if e.template_name and string.find(e.template_name, "pirates_fog", 1, true) and predicate(e) then
			e.controller_owned = true
			e.duration = duration
			e.active = true
		end
	end
end

function pirate_controller_cannon(store, controller)
	local soldiers = U.find_soldiers_in_range(store.entities, v(512, 384), 0, 2000, 0, 0, kr4_valid_enemy_soldier_target)
	if not soldiers then return end
	local zones = {}
	for i = 1, math.min(8, #soldiers) do
		zones[i] = V.vclone(soldiers[i].pos)
		pirate_cannon_warning(store, zones[i], 6)
	end
	local ship = pirate_stage37_ship(store)
	if ship then ship.signal = true end
	S:queue("special_cannon_shot")
	U.y_wait(store, 6)
	for _, pos in ipairs(zones) do
		pirate_level_damage_area(store, controller, pos, 45, 200, 300, DAMAGE_TRUE)
		pirate_cannon_impact(store, pos)
	end
	S:queue("special_cannon_shot_explotion")
end

function pirate_controller_macaque_cannon(store, controller, max_towers)
	local towers = table.filter(store.entities, function(_, e)
		return e.tower and not e.tower_holder and not e.tower.destroy
	end)
	if #towers < 1 then return end
	S:queue("krv_sfx_monkeys_boss_bananade_shot")
	for i = #towers, 2, -1 do
		local j = math.random(1, i)
		towers[i], towers[j] = towers[j], towers[i]
	end
	for i, tower in ipairs(towers) do
		if i > max_towers then break end
		local m = E:create_entity("boss_macaque_block_tower")
		m.modifier.source_id = controller.id
		m.modifier.target_id = tower.id
		m.modifier.duration = 5
		queue_insert(store, m)
	end
	S:queue("krv_sfx_monkeys_boss_bananade_fall")
end

local macaque_cannon_campaign = {
	[4] = {first = 5, cooldown = 18, count = 5, max_towers = 1},
	[9] = {first = 5, cooldown = 18, count = 5, max_towers = 2},
	[12] = {first = 5, cooldown = 18, count = 5, max_towers = 2},
	[14] = {first = 5, cooldown = 18, count = 5, max_towers = 3}
}

local macaque_cannon_heroic = {
	[1] = {first = 30, cooldown = 20, count = 1, max_towers = 1},
	[2] = {first = 20, cooldown = 20, count = 2, max_towers = 1},
	[3] = {first = 15, cooldown = 20, count = 2, max_towers = 2},
	[4] = {first = 10, cooldown = 15, count = 3, max_towers = 2},
	[5] = {first = 5, cooldown = 15, count = 4, max_towers = 3},
	[6] = {first = 5, cooldown = 15, count = 5, max_towers = 3}
}

-- KR4 的自定义出怪路径从 0 开始；前代路径和子路均从 1 开始。
local macaque_ball_campaign = {
	[4] = {{first = 8, cooldown = 9, count = 2, pi = 3, spi = 2}},
	[6] = {{first = 3, cooldown = 29, count = 2, pi = 3, spi = 2}},
	[9] = {
		{first = 20, cooldown = 24, count = 2, pi = 1, spi = 3},
		{first = 10, cooldown = 24, count = 2, pi = 2, spi = 2}
	},
	[13] = {
		{first = 30, cooldown = 25, count = 2, pi = 3, spi = 2},
		{first = 22, cooldown = 25, count = 2, pi = 1, spi = 3},
		{first = 9, cooldown = 25, count = 2, pi = 2, spi = 2}
	},
	[14] = {
		{first = 43, cooldown = 1, count = 1, pi = 1, spi = 1},
		{first = 3, cooldown = 1, count = 1, pi = 2, spi = 1}
	}
}

local blackthorne_miniboss_schedule = {
	[5] = {
		{key = "black_corsair", delay = 5, template = "enemy_black_corsair_last_stage", pi = 1, spi = 1, ni = 38},
		{key = "macaque", delay = 57, template = "enemy_boss_macaque_last_stage", pi = 4, spi = 1, ni = 43}
	},
	[12] = {
		{key = "deep_king", delay = 3, template = "enemy_deep_king_throne_last_stage", pi = 6, spi = 1, ni = 11},
		{key = "ghost_ship", delay = 67, template = "enemy_flying_ghost_ship_last_stage", pi = 8, spi = 1, ni = 66}
	}
}

function scripts.pirates_stage_controller.update(this, store)
	local level = this.level
	local campaign = store.level_mode == GAME_MODE_CAMPAIGN
	local last_wave = 0
	local boss_spawned = false
	local cannon_ts = store.tick_ts
	local macaque_wave_ts = store.tick_ts
	local macaque_cannon_count = 0
	local macaque_ball_counts = {}
	local blackthorne_wave_ts = store.tick_ts
	local blackthorne_minibosses = {}
	local steal_ts = store.tick_ts - 40
	local stage38_dried = false
	local stage189_idle_entity = nil
	local stage41_blackthorne_entity = nil
	local stage41_opened_first = false
	local stage41_opened_second = false
	local stage41_heroes_positioned = false

	if level == 190 or level == 191 then
		for _, e in pairs(store.entities) do
			if e.template_name and string.find(e.template_name, "pirates_fog", 1, true) then
				e.controller_owned = true
				e.active = false
			end
		end
	end
	if level == 189 and campaign then
		stage189_idle_entity = pirate_stage189_idle(store)
	end
	if level == 188 and campaign then
		pirate_stage38_prepare_river(store)
	end
	if level == 191 and campaign then
		stage41_blackthorne_entity = E:create_entity("stage41_blackthorne_scene")
		stage41_blackthorne_entity.pos = v(671, 546)
		queue_insert(store, stage41_blackthorne_entity)
	end

	while true do
		local wave = store.wave_group_number or 0
		if level == 191 and not stage41_heroes_positioned then
			local heroes, seen = {}, {}

			local function add_hero(hero)
				local key = hero and (hero.id or hero)

				if key and not seen[key] then
					seen[key] = true
					table.insert(heroes, hero)
				end
			end

			for _, hero in ipairs(store.main_heroes or {}) do add_hero(hero) end
			add_hero(store.main1_hero)
			add_hero(store.main_hero)

			if #heroes > 0 then
				local positions = {v(477, 300), v(517, 300), v(477, 336), v(517, 336)}

				for i, hero in ipairs(heroes) do
					local pos = positions[i] or v(497 + (i - 4) * 12, 336)

					hero.pos = V.vclone(pos)
					if hero.nav_rally then
						hero.nav_rally.center = V.vclone(pos)
						hero.nav_rally.pos = V.vclone(pos)
					end
				end

				stage41_heroes_positioned = true
			end
		end
		if level == 188 and wave > last_wave then
			macaque_wave_ts = store.tick_ts
			macaque_cannon_count = 0
			macaque_ball_counts = {}
		end
		if level == 191 and wave > last_wave then
			blackthorne_wave_ts = store.tick_ts
		end
		if level == 187 then
			if wave > last_wave and last_wave == 0 then cannon_ts = store.tick_ts end
			if wave > 0 and not boss_spawned and store.level_mode ~= GAME_MODE_IRON and store.tick_ts - cannon_ts >= 20 then
				cannon_ts = store.tick_ts
				pirate_controller_cannon(store, this)
			end
			if store.level_mode ~= GAME_MODE_IRON and wave > last_wave and (wave == 3 or wave == 6 or wave == 9 or wave == 12) then
				pirate_stage37_house_spawn(store, wave % 2 == 0 and "enemy_corsair" or "enemy_bucaneer", 1)
				pirate_stage37_house_spawn(store, "enemy_freebooter", 2)
			end
			if campaign and wave >= 15 and not boss_spawned then
				boss_spawned = true
				local ship = pirate_stage37_ship(store)
				if ship then ship.remove = true end
				pirate_level_spawn(store, "enemy_black_corsair", 3, 1)
			end
		elseif level == 188 then
			local elapsed = store.tick_ts - macaque_wave_ts
			local cannon_schedule = campaign and macaque_cannon_campaign or (store.level_mode == GAME_MODE_HEROIC and macaque_cannon_heroic or nil)
			local cannon_cfg = cannon_schedule and cannon_schedule[wave]
			if cannon_cfg and macaque_cannon_count < cannon_cfg.count and elapsed >= cannon_cfg.first + macaque_cannon_count * cannon_cfg.cooldown then
				macaque_cannon_count = macaque_cannon_count + 1
				pirate_controller_macaque_cannon(store, this, cannon_cfg.max_towers)
			end
			local balls = campaign and macaque_ball_campaign[wave]
			for i, cfg in ipairs(balls or {}) do
				local count = macaque_ball_counts[i] or 0
				if count < cfg.count and elapsed >= cfg.first + count * cfg.cooldown then
					macaque_ball_counts[i] = count + 1
					pirate_level_spawn(store, "enemy_monkey_ball", cfg.pi, cfg.spi)
				end
			end
			if campaign and wave >= 15 and not boss_spawned then
				boss_spawned = true
				if not stage38_dried then
					stage38_dried = true
					pirate_stage38_dry_river(store)
				end
				pirate_level_spawn(store, "enemy_macaque", 4, 1)
			end
		elseif level == 189 then
			if campaign and wave >= 15 and not boss_spawned then
				boss_spawned = true
				if stage189_idle_entity then
					stage189_idle_entity.remove = true
					stage189_idle_entity = nil
				end
				pirate_stage189_deep_king_intro(store)
				pirate_level_spawn(store, "enemy_deep_king_throne", 1, 1)
			end
		elseif level == 190 then
			if wave > last_wave and wave == 4 then
				pirate_controller_activate_fog(store, function(e) return not string.find(e.template_name, "boss2", 1, true) end, 18)
			elseif wave > last_wave and wave == 7 then
				pirate_controller_activate_fog(store, function(e) return string.find(e.template_name, "boss2", 1, true) ~= nil end, 18)
			end
			if campaign and wave >= 15 and not boss_spawned then
				boss_spawned = true
				pirate_level_spawn(store, "enemy_flying_ghost_ship", 8, 1)
			end
		elseif level == 191 then
			if campaign then
				local elapsed = store.tick_ts - blackthorne_wave_ts
				for _, cfg in ipairs(blackthorne_miniboss_schedule[wave] or {}) do
					if not blackthorne_minibosses[cfg.key] and elapsed >= cfg.delay then
						blackthorne_minibosses[cfg.key] = true
						pirate_level_spawn(store, cfg.template, cfg.pi, cfg.spi, cfg.ni)
					end
				end
			end
			if wave > last_wave then
				if campaign and wave >= 4 and not stage41_opened_first then
					stage41_opened_first = true
					pirate_stage41_open_path(store, stage41_blackthorne_entity or pirate_stage41_blackthorne(store), 1)
				end
				if wave == 4 then pirate_controller_activate_fog(store, function(e) return not string.find(e.template_name, "boss2", 1, true) end, 30) end
				if campaign and wave >= 7 and not stage41_opened_second then
					stage41_opened_second = true
					pirate_stage41_open_path(store, stage41_blackthorne_entity or pirate_stage41_blackthorne(store), 2)
				end
				if wave == 7 then pirate_controller_activate_fog(store, function(e) return string.find(e.template_name, "boss2", 1, true) ~= nil end, 30) end
			end
			if campaign and wave >= 4 and not boss_spawned and store.tick_ts - steal_ts >= 40 and store.player_gold >= 350 then
				steal_ts = store.tick_ts
				pirate_stage41_steal(store, stage41_blackthorne_entity or pirate_stage41_blackthorne(store), v(170, 30), 150)
			end
			if campaign and wave >= 15 and not boss_spawned then
				boss_spawned = true
				if stage41_blackthorne_entity then
					stage41_blackthorne_entity.remove = true
					stage41_blackthorne_entity = nil
				end
				pirate_level_spawn(store, "enemy_blackthorne", 7, 1)
			end
		end
		last_wave = math.max(last_wave, wave)
		coroutine.yield()
	end
end

---------------------------------------------------------
-- KR4 branch campaigns (20-25 and 28-36)
---------------------------------------------------------

function branch_damage(store, source, target, value, damage_type)
	if not target or not target.health or target.health.dead then return end
	local d = E:create_damage()
	d.source_id = source and source.id
	d.target_id = target.id
	d.value = math.max(0, math.floor(value or 0))
	d.damage_type = damage_type or DAMAGE_PHYSICAL
	queue_damage(store, d)
end

function branch_damage_soldiers(store, source, pos, radius, damage_min, damage_max, damage_type, max_count)
	local targets = U.find_soldiers_in_range(store.entities, pos, 0, radius, 0, F_FLYING, kr4_valid_enemy_soldier_target)
	for i, target in ipairs(targets or {}) do
		if max_count and i > max_count then break end
		branch_damage(store, source, target, math.random(damage_min, damage_max), damage_type)
	end
	return targets or {}
end

function branch_spawn_on_path(store, template_name, owner, node_offset, pi, spi, ni)
	local e = E:create_entity(template_name)
	if not e.nav_path then return nil end
	pi = pi or owner and owner.nav_path and owner.nav_path.pi or 1
	spi = spi or owner and owner.nav_path and owner.nav_path.spi or 1
	ni = ni or owner and owner.nav_path and owner.nav_path.ni or P:get_start_node(pi)
	e.nav_path.pi = pi
	e.nav_path.spi = spi
	e.nav_path.dir = owner and owner.nav_path and owner.nav_path.dir or branch_path_dir(pi)
	e.nav_path.ni = branch_shift_path_node({pi = pi, ni = ni, dir = e.nav_path.dir}, node_offset or 0)
	e.pos = V.vclone(P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni))
	queue_insert(store, e)
	return e
end

function branch_normalize_path_index(pi)
	pi = tonumber(pi) or 1

	if pi < 1 then
		pi = pi + 1
	end

	return pi
end

function branch_kr4_path_rank(pi)
	return (tonumber(pi) or 0) + 1
end

function branch_spawn_from_pos_to_path(store, template_name, spawn_pos, pi, spi, ni)
	local e = E:create_entity(template_name)

	if not e.nav_path then return nil end

	pi = branch_normalize_path_index(pi)
	spi = tonumber(spi) or 1

	if not P.paths[pi] then
		local nodes = spawn_pos and P:nearest_nodes(spawn_pos.x, spawn_pos.y, nil, nil, true)
		if not nodes or not nodes[1] then return nil end
		pi, spi, ni = nodes[1][1], nodes[1][2], nodes[1][3]
	elseif not P.paths[pi][spi] then
		spi = 1
	end

	ni = ni or P:get_start_node(pi)
	e.nav_path.pi = pi
	e.nav_path.spi = spi
	e.nav_path.dir = branch_path_dir(pi)
	e.nav_path.ni = branch_clamp_path_node(pi, ni)
	e.pos = V.vclone(spawn_pos)
	e.motion.forced_waypoint = V.vclone(P:node_pos(e.nav_path.pi, e.nav_path.spi, e.nav_path.ni))
	queue_insert(store, e)

	return e
end

function branch_find_towers(store, pos, radius)
	return table.filter(store.entities, function(_, e)
		return e.tower and not e.tower_holder and not e.tower.destroy and U.is_inside_ellipse(e.pos, pos, radius)
	end)
end

function branch_ready(cfg, now)
	return cfg and now - (cfg.ts or -1e+99) >= (cfg.cooldown or 0)
end

function branch_shared_ready(branch, cfg, now)
	if not branch_ready(cfg, now) then
		return false
	end

	if cfg.shared_min_cooldown and now - (branch._shared_skill_ts or -1e+99) < cfg.shared_min_cooldown then
		return false
	end

	return true
end

function branch_shared_mark(branch, cfg, now)
	if cfg and cfg.shared_min_cooldown then
		branch._shared_skill_ts = now
	end
end

function branch_launch_lightseeker_wave(store, wave_name, pos)
	local controller = E:create_entity("stage165_lightseeker_wave_event")

	controller.wave_name = wave_name
	controller.pos = pos and V.vclone(pos) or V.v(0, 0)
	queue_insert(store, controller)

	return controller
end

function branch_spawn_fx_at(store, name, pos, flip_x)
	if not name or not pos then return nil end
	local fx = E:create_entity(name)
	fx.pos = V.vclone(pos)
	for _, s in pairs(fx.render and fx.render.sprites or {}) do
		s.ts = store.tick_ts
		if flip_x ~= nil then
			s.flip_x = flip_x
		end
	end
	queue_insert(store, fx)
	return fx
end

scripts.branch_enemy_projectile = {}

function scripts.branch_enemy_projectile.insert(this, store)
	local b = this.bullet
	local s = this.render and this.render.sprites and this.render.sprites[1]

	b.from = b.from or V.vclone(this.pos)
	b.to = b.to or V.vclone(this.pos)
	b.flight_time = b.flight_time or fts(18)
	b.ts = store.tick_ts
	b.last_pos = V.vclone(b.from)
	b.speed = SU.initial_parabola_speed(b.from, b.to, b.flight_time, b.g)

	this.pos = V.vclone(b.from)

	if s then
		s.ts = store.tick_ts
		s.flip_x = true
	end

	return true
end

function branch_enemy_projectile_apply_mod(store, projectile, target, damage)
	local b = projectile.bullet

	if not target or not b.mod then return end

	local mods = type(b.mod) == "table" and b.mod or {b.mod}

	for _, mod_name in ipairs(mods) do
		local mod = E:create_entity(mod_name)

		mod.modifier.source_id = projectile.source_id or projectile.id
		mod.modifier.target_id = target.id
		mod.modifier.level = b.level
		mod.modifier.source_damage = damage

		if b.mod_duration then
			mod.modifier.duration = b.mod_duration
		end

		queue_insert(store, mod)
	end
end

function scripts.branch_enemy_projectile.update(this, store)
	local b = this.bullet
	local s = this.render and this.render.sprites and this.render.sprites[1]

	while store.tick_ts - b.ts + store.tick_length <= b.flight_time do
		coroutine.yield()

		b.last_pos.x, b.last_pos.y = this.pos.x, this.pos.y
		this.pos.x, this.pos.y = SU.position_in_parabola(store.tick_ts - b.ts, b.from, b.speed, b.g)

		if s and not b.ignore_rotation then
			s.r = V.angleTo(this.pos.x - b.last_pos.x, this.pos.y - b.last_pos.y)
			s.flip_x = true
		end
	end

	this.pos = V.vclone(b.to)

	local hit_pos = V.vclone(b.to)
	local target = b.target_id and store.entities[b.target_id]
	local victims

	if target and target.unit and target.unit.hit_offset and not b.ignore_hit_offset then
		hit_pos = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
	end

	if b.damage_radius and b.damage_radius > 0 and not b.no_damage then
		victims = branch_damage_soldiers(store, store.entities[this.source_id], hit_pos, b.damage_radius, b.damage_min, b.damage_max, b.damage_type, b.max_count)
	else
		victims = target and {target} or {}
		if target and target.health and not target.health.dead and not b.no_damage then
			local d = E:create_damage()

			d.source_id = this.source_id
			d.target_id = target.id
			d.value = math.random(b.damage_min or 0, b.damage_max or b.damage_min or 0)
			d.damage_type = b.damage_type or DAMAGE_PHYSICAL

			queue_damage(store, d)
			branch_enemy_projectile_apply_mod(store, this, target, d)
		end
	end

	if b.damage_radius and b.mod then
		for _, victim in ipairs(victims or {}) do
			branch_enemy_projectile_apply_mod(store, this, victim)
		end
	end

	if b.hit_fx then
		branch_spawn_fx_at(store, b.hit_fx, hit_pos)
	end
	if b.hit_blood_fx and target and target.unit and target.unit.blood_color ~= BLOOD_NONE then
		local sfx = E:create_entity(b.hit_blood_fx)

		sfx.pos = V.vclone(hit_pos)
		sfx.render.sprites[1].ts = store.tick_ts

		if sfx.use_blood_color and target.unit.blood_color then
			sfx.render.sprites[1].name = target.unit.blood_color
			sfx.render.sprites[1].r = this.render.sprites[1].r
		end

		queue_insert(store, sfx)
	end
	if b.decal_fx then
		local decal_pos = target and target.pos and V.vclone(target.pos) or V.vclone(b.to)

		branch_spawn_fx_at(store, b.decal_fx, decal_pos, b.decal_flip_x)
	end
	if b.hit_sound then
		S:queue(b.hit_sound)
	end

	queue_remove(store, this)
end

scripts.branch_enemy_ray = {}

function scripts.branch_enemy_ray.update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = b.target_id and store.entities[b.target_id]
	local dest = V.vclone(b.to)
	local start_ts = store.tick_ts

	local function update_sprite()
		if this.track_target and target and target.health and not target.health.dead then
			dest = V.vclone(target.pos)
			if target.unit and target.unit.hit_offset and not b.ignore_hit_offset then
				dest.x = dest.x + target.unit.hit_offset.x
				dest.y = dest.y + target.unit.hit_offset.y
			end
		end

		s.r = V.angleTo(dest.x - this.pos.x, dest.y - this.pos.y)
		s.scale.x = V.dist(dest.x, dest.y, this.pos.x, this.pos.y) / this.image_width
	end

	s.scale = s.scale or V.v(1, 1)
	s.ts = start_ts
	update_sprite()

	while store.tick_ts - start_ts < (b.hit_time or 0) do
		coroutine.yield()
		if this.track_target then update_sprite() end
	end

	local victims = branch_damage_soldiers(store, store.entities[this.source_id], dest,
		b.damage_radius or 0, b.damage_min, b.damage_max, b.damage_type, b.max_count)

	for _, victim in ipairs(victims) do
		branch_enemy_projectile_apply_mod(store, this, victim)
	end
	if b.hit_fx then branch_spawn_fx_at(store, b.hit_fx, dest) end
	if b.hit_sound then S:queue(b.hit_sound) end

	while store.tick_ts - start_ts < (this.ray_duration or b.hit_time or 0) do
		coroutine.yield()
		if this.track_target then update_sprite() end
	end

	queue_remove(store, this)
end

function branch_enemy_fire_projectile(store, this, attack, target)
	local projectile = E:create_entity(attack.projectile)
	local target_pos = target and target.pos and V.vclone(target.pos) or V.vclone(this.pos)
	local offset = attack.shoot_offset or V.v(0, this.unit and this.unit.hit_offset and this.unit.hit_offset.y or 24)
	local flip = target and target.pos and target.pos.x < this.pos.x

	if target and target.unit and target.unit.hit_offset and not attack.ignore_hit_offset then
		target_pos.x = target_pos.x + target.unit.hit_offset.x
		target_pos.y = target_pos.y + target.unit.hit_offset.y
	end

	projectile.source_id = this.id
	projectile.pos = V.v(this.pos.x + (flip and -offset.x or offset.x), this.pos.y + offset.y)
	projectile.bullet.from = V.vclone(projectile.pos)
	projectile.bullet.to = target_pos
	projectile.bullet.target_id = target and target.id
	if attack.hp_damage_factor and target and target.health then
		local damage = math.ceil((target.health.hp_max or 0) * attack.hp_damage_factor)

		projectile.bullet.damage_min = damage
		projectile.bullet.damage_max = damage
		projectile.bullet.damage_type = bor(attack.damage_type or DAMAGE_MAGICAL, DAMAGE_NO_DODGE)
	elseif attack.instakill and target and target.health then
		local lethal_damage = (target.health.hp or 0) + (target.health.hp_max or 0) + 1

		projectile.bullet.damage_min = lethal_damage
		projectile.bullet.damage_max = lethal_damage
		projectile.bullet.damage_type = bor(DAMAGE_TRUE, DAMAGE_NO_DODGE)
	else
		projectile.bullet.damage_min = attack.damage_min
		projectile.bullet.damage_max = attack.damage_max
		projectile.bullet.damage_type = attack.damage_type
	end
	projectile.bullet.damage_radius = attack.radius or projectile.bullet.damage_radius
	projectile.bullet.max_count = attack.max_count
	projectile.bullet.decal_flip_x = flip
	projectile.bullet.no_damage = attack.no_damage
	if attack.decal_fx then projectile.bullet.decal_fx = attack.decal_fx end
	if attack.hit_sound then projectile.bullet.hit_sound = attack.hit_sound end
	if attack.hit_blood_fx then projectile.bullet.hit_blood_fx = attack.hit_blood_fx end

	if attack.flight_time then projectile.bullet.flight_time = attack.flight_time end
	if attack.g then projectile.bullet.g = attack.g end
	if attack.mod then projectile.bullet.mod = attack.mod end
	if attack.mod_duration then projectile.bullet.mod_duration = attack.mod_duration end
	if attack.freeze then
		projectile.bullet.mod = "mod_branch_freeze"
		projectile.bullet.mod_duration = attack.freeze
	end

	queue_insert(store, projectile)
	if attack.projectile_sound then
		S:queue(attack.projectile_sound)
	end

	return projectile
end

function branch_kill_all_enemies_for_victory(store, stop_wave_spawns)
	if stop_wave_spawns then
		store.wave_spawn_thread = nil
		store.wave_spawn_co = nil
		store.waves_active = {}
		store.manual_wave_cos = {}
		store.next_wave_group_ready = nil
		store.current_wave_group = nil
		store.send_next_wave = false
		store.force_next_wave = false
		LU.kill_all_enemies(store, true)
	end

	for _, e in pairs(store.entities) do
		if e.enemy and e.health and not e.health.dead then
			local d = E:create_damage()

			d.source_id = nil
			d.target_id = e.id
			d.value = (e.health.hp or 0) + (e.health.hp_max or 0) + 1000
			d.damage_type = bor(DAMAGE_TRUE, DAMAGE_NO_SPAWNS, DAMAGE_NO_DODGE)

			queue_damage(store, d)
		end
	end

	store.waves_finished = true

	if store.level then
		store.level.kr4_boss_done = true
		store.level.run_complete = true
	end
end

function branch_mark_ready_tables(branch, now)
	for _, cfg in pairs(branch) do
		if type(cfg) == "table" and cfg.cooldown then
			cfg.ts = cfg.ready_on_start and now - cfg.cooldown or now
		end
	end
end

local function branch_damage_will_kill(target, damage)
	if not target.health or target.health.dead then
		return false
	end

	if band(damage.damage_type or 0, bor(DAMAGE_INSTAKILL, DAMAGE_EAT)) ~= 0 then
		return true
	end

	return U.predict_damage(target, damage) >= target.health.hp
end

local function branch_repairable_dead_target(target, repair)
	return target and target.health and target.health.dead and target._branch_repairable and (not target.unit or not target.unit.hide_during_death and not target.unit.hide_after_death)
end

local function branch_repair_can_continue(store, caster, target, repair)
	if not store.entities[caster.id] or not store.entities[target.id] then
		return false
	end
	if caster.health.dead or caster.unit.is_stunned then
		return false
	end
	if repair.dead_only and not branch_repairable_dead_target(target, repair) then
		return false
	end
	if not repair.dead_only and (not target.health or target.health.dead and not branch_repairable_dead_target(target, repair)) then
		return false
	end
	if target.health.delete_after and target.health.delete_after <= store.tick_ts then
		return false
	end
	if repair.interrupt_on_block and #caster.enemy.blockers > 0 then
		return false
	end

	return true
end

local function branch_protect_repair_target(target, now, duration)
	if target.health and target.health.dead and target.health.delete_after then
		target.health.delete_after = math.max(target.health.delete_after, now + duration)
	end
end

local function branch_play_repair(store, this, repair, target)
	local cast_time = repair.cast_time or 0.4
	local finish_ts = store.tick_ts + cast_time
	local flip = target.pos and target.pos.x < this.pos.x or nil
	local wait_sid = repair.sprite_ids and repair.sprite_ids[1] or 1

	branch_protect_repair_target(target, store.tick_ts, cast_time + (repair.delete_after_grace or 1))

	if repair.animation then
		pirate_start_animation(this, repair.animation, flip, store.tick_ts, false, repair.sprite_ids, true)

		while store.tick_ts < finish_ts and not U.animation_finished(this, wait_sid) do
			if not branch_repair_can_continue(store, this, target, repair) then return false end

			coroutine.yield()
		end
	end

	if repair.loop_animation and store.tick_ts < finish_ts then
		pirate_start_animation(this, repair.loop_animation, flip, store.tick_ts, true, repair.sprite_ids, true)
	end

	local next_ray_ts = store.tick_ts

	while store.tick_ts < finish_ts do
		if not branch_repair_can_continue(store, this, target, repair) then return false end

		if repair.projectile and store.tick_ts >= next_ray_ts then
			branch_enemy_fire_projectile(store, this, repair, target)

			next_ray_ts = store.tick_ts + (repair.ray_interval or 0.45)
		end

		branch_protect_repair_target(target, store.tick_ts, repair.delete_after_grace or 1)
		coroutine.yield()
	end

	if repair.end_animation and branch_repair_can_continue(store, this, target, repair) then
		pirate_start_animation(this, repair.end_animation, flip, store.tick_ts, false, repair.sprite_ids, true)

		while not U.animation_finished(this, wait_sid) do
			if not store.entities[this.id] or this.health.dead or this.unit.is_stunned then return false end

			coroutine.yield()
		end
	end

	return branch_repair_can_continue(store, this, target, repair)
end

scripts.mod_branch_stat = {}

function scripts.mod_branch_stat.insert(this, store)
	local target = store.entities[this.modifier.target_id]
	if not target then return false end
	if this.speed_factor and target.motion then
		this._speed_factor = this.speed_factor
		target.motion.max_speed = target.motion.max_speed * this.speed_factor
	end
	if this.damage_factor and target.unit then
		this._damage_factor = this.damage_factor
		target.unit.damage_factor = target.unit.damage_factor * this.damage_factor
	end
	if this.hp_bonus and target.health then
		this._hp_bonus = this.hp_bonus
		target.health.hp_max = target.health.hp_max + this.hp_bonus
		target.health.hp = target.health.hp + this.hp_bonus
	end
	if this.magic_armor and target.health then
		this._old_magic_armor = target.health.magic_armor or 0
		target.health.magic_armor = math.max(target.health.magic_armor or 0, this.magic_armor)
	end
	return true
end

function scripts.mod_branch_stat.remove(this, store)
	local target = store.entities[this.modifier.target_id]
	if not target then return true end
	if this._speed_factor and target.motion then target.motion.max_speed = target.motion.max_speed / this._speed_factor end
	if this._damage_factor and target.unit then target.unit.damage_factor = target.unit.damage_factor / this._damage_factor end
	if this._hp_bonus and target.health then
		target.health.hp = km.clamp(0, math.max(1, target.health.hp_max - this._hp_bonus), target.health.hp - this._hp_bonus)
		target.health.hp_max = math.max(1, target.health.hp_max - this._hp_bonus)
	end
	if this._old_magic_armor and target.health then target.health.magic_armor = this._old_magic_armor end
	return true
end

function scripts.mod_branch_stat.update(this, store)
	this.modifier.ts = store.tick_ts
	while store.tick_ts - this.modifier.ts < this.modifier.duration do
		if not store.entities[this.modifier.target_id] then break end
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.mod_zeta_oloch_imprison = {}

function scripts.mod_zeta_oloch_imprison.update(this, store)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target then
		queue_remove(store, this)
		return
	end

	this.pos = target.pos
	U.y_animation_play(this, "in", nil, store.tick_ts, false)
	U.animation_start(this, "loop", nil, store.tick_ts, true)

	local start_ts = store.tick_ts
	local next_damage_ts = start_ts
	while store.tick_ts - start_ts < m.duration and target and not target.health.dead do
		this.pos = target.pos
		if store.tick_ts >= next_damage_ts then
			branch_damage(store, store.entities[m.source_id], target, this.damage or 24, DAMAGE_MAGICAL)
			next_damage_ts = next_damage_ts + (this.tick or 1)
		end
		coroutine.yield()
	end

	if target and target.health and target.health.dead and not this.fissure_spawned then
		this.fissure_spawned = true
		branch_spawn_scene(store, this.fissure_template or "enemy_zeta_demon_fissure", target.pos.x, target.pos.y)
	end
	queue_remove(store, this)
end

scripts.mod_branch_polymorph = {}

function scripts.mod_branch_polymorph.insert(this, store)
	local target = store.entities[this.modifier.target_id]
	if not target or not target.unit or not target.health or target.health.dead then return false end

	this._target_had_vis = target.vis ~= nil
	this._target_had_ui = target.ui ~= nil
	this._target_old_vis_bans = target.vis and target.vis.bans
	this._target_old_can_click = target.ui and target.ui.can_click
	this._target_old_can_select = target.ui and target.ui.can_select
	this._target_old_target_id = target.soldier and target.soldier.target_id
	this._target_hidden_sprites = {}

	if target.soldier and target.soldier.target_id then
		U.unblock_target(store, target)
	end
	if target.enemy and target.enemy.blockers and #target.enemy.blockers > 0 then
		U.unblock_all(store, target)
	end

	if target.render and target.render.sprites then
		for i, s in pairs(target.render.sprites) do
			this._target_hidden_sprites[i] = s.hidden
			s.hidden = true
		end
	end

	if target.vis then
		target.vis.bans = F_ALL
	end

	if target.ui then
		target.ui.can_click = false
		target.ui.can_select = false
	end

	SU.stun_inc(target)
	this._stunned = true

	local sprite = this.render and this.render.sprites and this.render.sprites[1]
	local shadow = this.render and this.render.sprites and this.render.sprites[2]
	local big = target.unit.size and target.unit.size >= UNIT_SIZE_MEDIUM
	local visual = big and this.visual_big or this.visual_small

	if visual then
		if sprite then
			sprite.prefix = visual.prefix
			sprite.name = visual.idle or "idle"
			sprite.anchor = visual.anchor or sprite.anchor
			sprite.ts = store.tick_ts
			sprite.hidden = false
			U.animation_start(this, sprite.name, nil, store.tick_ts, true, 1, true)
		end
		if shadow then
			shadow.name = visual.shadow
			shadow.anchor = visual.anchor or shadow.anchor
			shadow.hidden = false
		end
	end

	return true
end

function scripts.mod_branch_polymorph.remove(this, store)
	local target = store.entities[this.modifier.target_id]
	if target and target.unit then
		if this._target_hidden_sprites and target.render and target.render.sprites then
			for i, hidden in pairs(this._target_hidden_sprites) do
				if target.render.sprites[i] then
					target.render.sprites[i].hidden = hidden
				end
			end
		end
		if target.vis and this._target_had_vis then
			target.vis.bans = this._target_old_vis_bans
		end
		if target.ui and this._target_had_ui then
			target.ui.can_click = this._target_old_can_click
			target.ui.can_select = this._target_old_can_select
		end
		if this._stunned then SU.stun_dec(target) end
	end
	this._stunned = false
	return true
end

function scripts.mod_branch_polymorph.update(this, store)
	this.modifier.ts = store.tick_ts
	while store.tick_ts - this.modifier.ts < this.modifier.duration do
		local target = store.entities[this.modifier.target_id]
		if not target or not target.health or target.health.dead then break end
		if this.source_dead_min_duration and store.tick_ts - this.modifier.ts >= this.source_dead_min_duration then
			local source = this.modifier.source_id and store.entities[this.modifier.source_id]
			if not source or source.health and source.health.dead then
				break
			end
		end
		this.pos = V.vclone(target.pos)
		if this.render and target.render then
			local s = this.render.sprites[1]
			local sh = this.render.sprites[2]
			s.z = target.render.sprites[1].z + 1
			if sh then sh.z = Z_DECALS + 1 end
		end
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.mod_branch_heal = {}

function scripts.mod_branch_heal.update(this, store)
	this.modifier.ts = store.tick_ts
	local tick_ts = store.tick_ts - (this.tick or 0.2)

	while store.tick_ts - this.modifier.ts < this.modifier.duration do
		local target = store.entities[this.modifier.target_id]
		if not target or not target.health or target.health.dead then break end

		this.pos = V.vclone(target.pos)

		if this.render and target.unit then
			local s = this.render.sprites[1]
			if not this._render_init then
				s.ts = store.tick_ts
				this._render_init = true
			end
			s.offset = target.unit.mod_offset and V.vclone(target.unit.mod_offset) or V.v(0, 0)
			if target.render then
				s.z = target.render.sprites[1].z + 1
			end
		end

		if store.tick_ts - tick_ts >= (this.tick or 0.2) then
			tick_ts = store.tick_ts
			target.health.hp = km.clamp(0, target.health.hp_max, target.health.hp + (this.heal or 0))
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.mod_branch_dot = {}

function scripts.mod_branch_dot.update(this, store)
	this.modifier.ts = store.tick_ts
	local tick_ts = store.tick_ts - (this.tick or 0.5)
	while store.tick_ts - this.modifier.ts < this.modifier.duration do
		local target = store.entities[this.modifier.target_id]
		if not target or not target.health or target.health.dead then break end
		this.pos = target.pos

		if this.render then
			local s = this.render.sprites[1]

			if not this._render_init then
				s.ts = store.tick_ts
				this._render_init = true
			end
			if this.modifier.use_mod_offset and target.unit and target.unit.mod_offset then
				s.offset = V.vclone(target.unit.mod_offset)
			end
			if target.render then
				s.z = target.render.sprites[1].z + 1
			end
		end

		if store.tick_ts - tick_ts >= (this.tick or 0.5) then
			tick_ts = store.tick_ts
			branch_damage(store, store.entities[this.modifier.source_id], target, this.damage or 0, this.damage_type or DAMAGE_TRUE)
		end
		coroutine.yield()
	end
	queue_remove(store, this)
end

scripts.branch_enemy = {}

function scripts.branch_enemy.get_info(this)
	local out = scripts.enemy_basic.get_info(this)
	local branch = this.branch or {}
	local function fill_ranged(a)
		if not a or not a.damage_min or not a.damage_max then
			return
		end

		local factor = this.unit and this.unit.damage_factor or 1
		local min = math.ceil(a.damage_min * factor)
		local max = math.ceil(a.damage_max * factor)

		out.ranged_damage_min = min
		out.ranged_damage_max = max
		out.ranged_damage_type = a.damage_type
		out.no_ranged = false

		if not out.damage_min then
			out.damage_min = min
			out.damage_max = max
			out.damage_type = a.damage_type
			out.yes_melee = false
		end
	end

	fill_ranged(branch.ranged)
	if out.no_ranged then
		fill_ranged(branch.snipe)
	end

	return out
end

function scripts.branch_enemy.on_damage(this, store, damage)
	local b = this.branch
	if not b or not b.dodge or this.health.dead or this.unit.is_stunned or band(damage.damage_type, DAMAGE_NO_DODGE) ~= 0 then return true end
	local source = damage.source_id and store.entities[damage.source_id]
	if not source or not source.soldier or not table.contains(this.enemy.blockers, source.id) or math.random() >= b.dodge then return true end
	local pop = E:create_entity("pop_miss")
	pop.pos = V.vclone(this.pos)
	queue_insert(store, pop)
	U.animation_start(this, "dodge", nil, store.tick_ts, false)
	return false
end

function scripts.branch_enemy.on_repairable_damage(this, store, damage)
	if not this.repairable_death or this.health.dead then
		return true
	end

	if branch_damage_will_kill(this, damage) then
		local cfg = this.repairable_death
		local no_repair_types = cfg.no_repair_damage_types or bor(DAMAGE_EXPLOSION, DAMAGE_FX_EXPLODE, DAMAGE_DISINTEGRATE, DAMAGE_DISINTEGRATE_BOSS, DAMAGE_EAT, DAMAGE_NO_SPAWNS)

		this._branch_repairable = band(damage.damage_type or 0, no_repair_types) == 0

		if this._branch_repairable then
			if cfg.disabled_animation then this.unit.death_animation = cfg.disabled_animation end
			if cfg.dead_lifetime then this.health.dead_lifetime = cfg.dead_lifetime end
		else
			if cfg.destroyed_animation then this.unit.death_animation = cfg.destroyed_animation end
			if cfg.destroyed_lifetime then this.health.dead_lifetime = cfg.destroyed_lifetime end
		end
	end

	return true
end

function scripts.branch_enemy.on_repairable_dodge_damage(this, store, damage)
	if scripts.branch_enemy.on_damage(this, store, damage) == false then
		return false
	end

	return scripts.branch_enemy.on_repairable_damage(this, store, damage)
end

local function branch_begin_speed_skill(this, factor)
	if not this.motion then
		return nil
	end

	factor = factor or 1
	this.motion.max_speed = this.motion.max_speed * factor

	return factor
end

local function branch_end_speed_skill(this, factor)
	if not this.motion or not factor or factor == 0 then
		return
	end

	-- Slow modifiers also multiply/divide max_speed. Undo only this skill's
	-- factor so a slow starting or expiring mid-skill cannot inflate speed.
	this.motion.max_speed = this.motion.max_speed / factor
end

local function branch_swap_armor_cfg(value)
	if type(value) == "table" then
		return value
	end

	return {interval = value or 15, armor = 0.85, magic_armor = 0.85}
end

local function branch_apply_swap_armor_state(this, store, b, state, play_sound)
	local cfg = branch_swap_armor_cfg(b.swap_armor)
	local h = this.health
	local armor = state == "physical" and (cfg.armor or 0.85) or 0
	local magic_armor = state == "magic" and (cfg.magic_armor or cfg.armor or 0.85) or 0
	local current_raw_armor = h.raw_armor ~= nil and h.raw_armor or h.armor or 0
	local current_raw_magic_armor = h.raw_magic_armor ~= nil and h.raw_magic_armor or h.magic_armor or 0
	local armor_delta = current_raw_armor - (b._swap_base_armor ~= nil and b._swap_base_armor or h.armor or 0)
	local magic_armor_delta = current_raw_magic_armor - (b._swap_base_magic_armor ~= nil and b._swap_base_magic_armor or h.magic_armor or 0)

	h.raw_armor = armor + armor_delta
	h.raw_magic_armor = magic_armor + magic_armor_delta
	h.armor = km.clamp(0, 1, h.raw_armor)
	h.magic_armor = km.clamp(0, 1, h.raw_magic_armor)
	b._swap_base_armor = armor
	b._swap_base_magic_armor = magic_armor
	b._swap_armor_state = state

	local physical_sid = cfg.physical_sprite
	local magic_sid = cfg.magic_sprite

	if this.render and this.render.sprites then
		if physical_sid and this.render.sprites[physical_sid] then
			this.render.sprites[physical_sid].hidden = state ~= "physical"
			if state == "physical" then
				U.animation_start(this, "loop", nil, store.tick_ts, true, physical_sid, true)
			end
		end
		if magic_sid and this.render.sprites[magic_sid] then
			this.render.sprites[magic_sid].hidden = state ~= "magic"
			if state == "magic" then
				U.animation_start(this, "loop", nil, store.tick_ts, true, magic_sid, true)
			end
		end
	end

	if play_sound then
		S:queue(state == "physical" and (cfg.physical_sound or "ice_winter_lord_stone_shield") or (cfg.magic_sound or "ice_winter_lord_gems_shield"))
	end
end

local function branch_update_swap_armor(this, store, b, now)
	local cfg = branch_swap_armor_cfg(b.swap_armor)
	local interval = cfg.interval or 15

	if not b._swap_armor_state then
		branch_apply_swap_armor_state(this, store, b, cfg.initial_state or "physical", false)
		b._swap_armor_next_ts = now + interval
	elseif now >= (b._swap_armor_next_ts or now + interval) then
		local next_state = b._swap_armor_state == "physical" and "magic" or "physical"

		branch_apply_swap_armor_state(this, store, b, next_state, true)
		b._swap_armor_next_ts = now + interval
	end
end

local function branch_enemy_update_swarm_block(store, this, cfg)
	local blocker_id = cfg.blocker_id
	local blocker = blocker_id and store.entities[blocker_id]
	local valid = blocker and blocker.soldier and blocker.health and not blocker.health.dead and
		blocker.soldier.target_id and U.is_inside_ellipse(blocker.pos, this.pos, cfg.break_range or 65)

	if blocker_id and not valid then
		for i = #this.enemy.blockers, 1, -1 do
			if this.enemy.blockers[i] == blocker_id then table.remove(this.enemy.blockers, i) end
		end
		cfg.blocker_id = nil
	end

	if cfg.blocker_id or #this.enemy.blockers > 0 then return end

	local target = U.find_nearest_soldier(store.entities, this.pos, 0, cfg.range or 50, F_BLOCK, F_FLYING,
		function(soldier)
			return kr4_valid_enemy_soldier_target(soldier) and soldier.soldier.target_id ~= nil
		end)

	if target then
		table.insert(this.enemy.blockers, target.id)
		cfg.blocker_id = target.id
	end
end

local function branch_enemy_update_walking_ranged(store, this, attack, now)
	if attack.pending_target_id and now >= attack.pending_fire_ts then
		local target = store.entities[attack.pending_target_id]

		attack.pending_target_id = nil
		attack.pending_fire_ts = nil
		if target and target.health and not target.health.dead then
			branch_enemy_fire_projectile(store, this, attack, target)
		end
	end

	if attack.pending_target_id or not branch_ready(attack, now) or #this.enemy.blockers > 0 then return end

	local target = U.find_nearest_soldier(store.entities, this.pos, attack.min_range or 0, attack.max_range,
		attack.vis_flags or 0, attack.vis_bans or F_FLYING, kr4_valid_enemy_soldier_target)

	if target then
		attack.ts = now
		attack.pending_target_id = target.id
		attack.pending_fire_ts = now + (attack.hit_time or attack.cast_time or 0)
		if attack.sound then S:queue(attack.sound) end
		U.animation_start(this, attack.animation or "ranged", target.pos.x < this.pos.x, now, false, nil, true)
	end
end

function branch_enemy_passives(store, this)
	if this.render and this.render.sprites and this.render.sprites[1] then
		local body = this.render.sprites[1]

		for i = 2, #this.render.sprites do
			local sprite = this.render.sprites[i]

			if sprite.zeta_attached_unit then
				sprite.flip_x = body.flip_x
				if sprite.zeta_attached_offset then
					sprite.offset.x = (body.flip_x and -1 or 1) * sprite.zeta_attached_offset.x
					sprite.offset.y = sprite.zeta_attached_offset.y
				end
			end
		end
	end

	local b = this.branch
	local now = store.tick_ts
	if b.swarm_block then branch_enemy_update_swarm_block(store, this, b.swarm_block) end
	if b.ranged and b.ranged.walk_while_shooting then
		branch_enemy_update_walking_ranged(store, this, b.ranged, now)
	end
	local melee_attack = this.melee and this.melee.attacks and this.melee.attacks[1]
	if melee_attack and b._melee_ts_initialized and melee_attack.ts ~= b._last_melee_ts then
		b._last_melee_ts = melee_attack.ts
		if melee_attack.ts and b.damage_stack_on_attack then
			local mod = E:create_entity(b.damage_stack_on_attack.mod or "mod_zeta_demon_guard_damage")

			mod.modifier.source_id = this.id
			mod.modifier.target_id = this.id
			queue_insert(store, mod)
		end
		if melee_attack.ts and b.reset_ranged_on_melee and b.ranged then b.ranged.ts = now end
	end
	if b.self_decay and b.self_decay.ts == nil then
		b.self_decay.ts = now + (b.self_decay.initial_delay or 0)
	end
	if b.self_decay and now >= b.self_decay.ts then
		local cfg = b.self_decay
		local should_decay = cfg.always

		if not should_decay then
			should_decay = true

			for _, e in pairs(store.entities) do
				if e.id ~= this.id and e.enemy and e.health and not e.health.dead and
						e.template_name ~= "enemy_zeta_draugr_flag1" then
					should_decay = false
					break
				end
			end
		end

		if should_decay then
			branch_damage(store, this, this, cfg.damage or 5000, cfg.damage_type or DAMAGE_TRUE)
		end

		cfg.ts = now + (cfg.cooldown or 0.25)
	end
	if b.layer_offsets and this.render and this.render.sprites then
		local main_sprite = this.render.sprites[1]
		local animation_name = main_sprite and main_sprite.name or ""
		local direction = string.find(animation_name, "Up", 1, true) and "up" or string.find(animation_name, "Down", 1, true) and "down" or "leftright"

		for sid, offsets in pairs(b.layer_offsets) do
			local sprite = this.render.sprites[sid]
			local offset = sprite and (offsets[direction] or offsets.leftright)

			if offset then
				sprite.offset = V.vclone(offset)
			end
		end
	end
	if b.entry_walk and this.nav_path then
		local ew = b.entry_walk
		local dir = this.nav_path.dir or 1
		local reached = this.nav_path.pi == (ew.path or this.nav_path.pi) and (dir > 0 and this.nav_path.ni >= ew.node or dir < 0 and this.nav_path.ni <= ew.node)
		if reached then
			this.motion.max_speed = ew.restore_speed or this.motion.max_speed
			b.entry_walk = nil
		end
	end
	if b.lightseeker_waves and this.nav_path then
		for _, cfg in ipairs(b.lightseeker_waves) do
			local dir = this.nav_path.dir or 1
			local reached = dir > 0 and this.nav_path.ni >= cfg.node or dir < 0 and this.nav_path.ni <= cfg.node

			if not cfg.done and reached then
				cfg.done = true
				branch_launch_lightseeker_wave(store, cfg.wave, this.pos)
			end
		end
	end
	if b.regen and not this.health.dead then
		local elapsed = now - (b._regen_ts or now)
		if elapsed >= 1 then
			b._regen_ts = now
			this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + b.regen * elapsed)
		end
	end
	if b.swap_armor then
		branch_update_swap_armor(this, store, b, now)
	end
	if b.melee_armor then
		this.health.armor = #this.enemy.blockers > 0 and b.melee_armor or 0
	end
	if b.shield_drop_on_melee then
		b._base_armor = b._base_armor or this.health.armor
		this.health.armor = #this.enemy.blockers > 0 and math.max(0, b._base_armor - 0.9) or b._base_armor
	end
	if b.kill_spawn or b.devour_heal then
		b._known_blockers = b._known_blockers or {}
		b._valid_kill_blockers = b._valid_kill_blockers or {}
		local current_blockers = {}

		for _, id in ipairs(this.enemy.blockers) do
			current_blockers[id] = true
		end

		for id in pairs(b._known_blockers) do
			local blocker = store.entities[id]
			if not blocker then
				b._known_blockers[id] = nil
				b._valid_kill_blockers[id] = nil
			elseif blocker.health and blocker.health.dead then
				local valid_kill = b._valid_kill_blockers[id]

				b._known_blockers[id] = nil
				b._valid_kill_blockers[id] = nil

				if valid_kill then
					if b.kill_spawn and this.nav_path then branch_spawn_on_path(store, b.kill_spawn, this, -2) end
					if b.devour_heal then this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + b.devour_heal) end
				end
			elseif not current_blockers[id] then
				b._known_blockers[id] = nil
				b._valid_kill_blockers[id] = nil
			end
		end
		for _, id in ipairs(this.enemy.blockers) do
			b._known_blockers[id] = true
			if b._valid_kill_blockers[id] == nil then
				b._valid_kill_blockers[id] = branch_blocker_allows_kill_spawn(store.entities[id])
			end
		end
	end
	if b.trample and now - (b.trample.ts or -1e+99) >= b.trample.tick then
		b.trample.ts = now
		branch_damage_soldiers(store, this, this.pos, b.trample.radius, b.trample.damage, b.trample.damage, DAMAGE_PHYSICAL)
	end
	if b.contact_damage and now - (b.contact_damage.ts or -1e+99) >= b.contact_damage.cooldown then
		local target = U.find_nearest_soldier(store.entities, this.pos, 0, 25, 0, F_FLYING, kr4_valid_enemy_soldier_target)
		if target then
			b.contact_damage.ts = now
			branch_damage(store, this, target, math.random(b.contact_damage.damage_min, b.contact_damage.damage_max), DAMAGE_PHYSICAL)
		end
	end
	if b.spawn and b.spawn.passive and (not b.spawn.wave_start or (store.wave_group_number or 0) >= b.spawn.wave_start) and
			branch_ready(b.spawn, now) and (not this.nav_path or pirate_nodes_to_exit(this) > (b.spawn.safe_nodes_to_exit or 0)) then
		local s = b.spawn

		s.ts = now

		for i = 1, s.count do
			local template = s.template or s.templates and s.templates[math.random(1, #s.templates)]
			local spawned = template and branch_spawn_on_path(store, template, this, -(s.node_gap or 2) * i)

			if spawned and s.zero_gold then
				spawned.enemy.gold = 0
			end
		end
	end
	if b.swap_path_data and this.nav_path and #this.enemy.blockers == 0 then
		for _, cfg in ipairs(b.swap_path_data) do
			local dir = this.nav_path.dir or branch_path_dir(this.nav_path.pi)
			local reached = dir > 0 and this.nav_path.ni >= cfg.trigger_node or dir < 0 and this.nav_path.ni <= cfg.trigger_node

			if not cfg.done and (not cfg.path or this.nav_path.pi == cfg.path) and reached then
				cfg.done = true
				if not cfg.walk_to_path then
					branch_spawn_fx_at(store, cfg.fx, this.pos)
				end
				this.nav_path.pi = tonumber(cfg.new_path) or this.nav_path.pi
				this.nav_path.spi = tonumber(cfg.new_subpath) or this.nav_path.spi or 1
				this.nav_path.dir = branch_path_dir(this.nav_path.pi)
				local target_ni = branch_clamp_path_node(this.nav_path.pi, tonumber(cfg.new_node) or this.nav_path.ni)
				this.nav_path.ni = cfg.walk_to_path and branch_clamp_path_node(this.nav_path.pi, target_ni - (this.nav_path.dir or 1)) or target_ni
				if cfg.walk_to_path then
					local next_pos = P:next_entity_node(this, store.tick_length)
					if next_pos then
						U.set_destination(this, next_pos)
						U.set_heading(this, next_pos)
					end
				else
					this.pos = V.vclone(P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni))
					branch_spawn_fx_at(store, cfg.fx_back, this.pos)
				end
				break
			end
		end
	end
	if b.armor_aura and now - (b.armor_aura.ts or -1e+99) >= 0.25 then
		b.armor_aura.ts = now
		for _, ally in ipairs(U.find_enemies_in_range(store.entities, this.pos, 0, b.armor_aura.range, 0, 0, function(e) return e.id ~= this.id end) or {}) do
			if not U.has_modifiers(store, ally, "mod_branch_magic_armor") then
				local m = E:create_entity("mod_branch_magic_armor")
				m.modifier.source_id, m.modifier.target_id = this.id, ally.id
				m.magic_armor = b.armor_aura.magic
				queue_insert(store, m)
			end
		end
	end
	if b.damage_aura and now - (b.damage_aura.ts or -1e+99) >= 0.25 then
		b.damage_aura.ts = now
		for _, ally in ipairs(U.find_enemies_in_range(store.entities, this.pos, 0, b.damage_aura.range, 0, bor(F_BOSS, F_MINIBOSS), function(e) return e.id ~= this.id end) or {}) do
			if not U.has_modifiers(store, ally, "mod_branch_damage") then
				local m = E:create_entity("mod_branch_damage")
				m.modifier.source_id, m.modifier.target_id = this.id, ally.id
				m.damage_factor, m.modifier.duration = b.damage_aura.factor, 0.5
				queue_insert(store, m)
			end
		end
	end
	if b.water_regen or b.water_duplicate then
		local water_zone
		for _, zone in pairs(store.entities) do
			if zone.branch_water_zone then
				local in_zone

				if zone.path and zone.node_start and zone.node_end and this.nav_path then
					local node_min = math.min(zone.node_start, zone.node_end)
					local node_max = math.max(zone.node_start, zone.node_end)

					in_zone = this.nav_path.pi == zone.path and this.nav_path.ni >= node_min and this.nav_path.ni <= node_max
				else
					in_zone = U.is_inside_ellipse(this.pos, zone.pos, zone.radius or 30)
				end

				if in_zone then
					water_zone = zone
					break
				end
			end
		end
		if water_zone and b.water_regen and now - (b._water_ts or -1e+99) >= 0.1 then
			b._water_ts = now
			this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + b.water_regen * 0.1)
		end
		if water_zone and b.water_duplicate and b._water_zone_id ~= water_zone.id then
			b._water_zone_id = water_zone.id
			local spawned = branch_spawn_on_path(store, b.water_duplicate, this, -2)

			if spawned and spawned.branch then
				spawned.branch._water_zone_id = water_zone.id
			end
		elseif not water_zone then
			b._water_zone_id = nil
		end
	end
	if b.necromancy and now - (b.necromancy.ts or -1e+99) >= 0.2 then
		b.necromancy.ts = now
		b.necromancy.seen = b.necromancy.seen or {}
		for _, unit in pairs(store.entities) do
			if unit.soldier and unit.health and unit.health.dead and not b.necromancy.seen[unit.id] and U.is_inside_ellipse(unit.pos, this.pos, b.necromancy.range) then
				b.necromancy.seen[unit.id] = true
				if this.nav_path and pirate_nodes_to_exit(this) > (b.necromancy.safe_nodes_to_exit or 0) then branch_spawn_on_path(store, b.necromancy.template, this, -2) end
			end
		end
	end
end

function branch_enemy_try_transform_on_melee(store, this)
	local b = this.branch
	local a = b and b.transform_on_melee

	if not a then
		return false
	end

	local blocked = #this.enemy.blockers > 0
	local factor = a.factor or 1

	if blocked and not a.active then
		a.active = true
		this.health.hp_max = this.health.hp_max * factor
		this.health.hp = this.health.hp * factor
		if a.sound then S:queue(a.sound) end
		if a.animation_in then pirate_play_full_animation(store, this, a.animation_in) end
		if not this.health.dead and a.idle_animation and #this.enemy.blockers > 0 then
			U.animation_start(this, a.idle_animation, nil, store.tick_ts, true)
		end
		return true
	elseif not blocked and a.active then
		a.active = nil
		this.health.hp_max = this.health.hp_max / factor
		this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp / factor)
		if a.animation_out then pirate_play_full_animation(store, this, a.animation_out) end
		return true
	end

	return false
end

function branch_possessed_enemy_try_skill(store, this)
	local b, now = this.branch, store.tick_ts

	if not b then
		return false
	end

	local transform = b.transform_on_melee
	if transform then
		local target = this.soldier and this.soldier.target_id and store.entities[this.soldier.target_id]
		local blocked = target and target.health and not target.health.dead
		local factor = transform.factor or 1

		if blocked and not transform.active then
			transform.active = true
			this.health.hp_max = this.health.hp_max * factor
			this.health.hp = this.health.hp * factor
			if transform.sound then S:queue(transform.sound) end
			if transform.animation_in then pirate_play_full_animation(store, this, transform.animation_in) end
			if not this.health.dead and transform.idle_animation and this.soldier and this.soldier.target_id then
				U.animation_start(this, transform.idle_animation, nil, store.tick_ts, true)
			end
			return true
		elseif not blocked and transform.active then
			transform.active = nil
			this.health.hp_max = this.health.hp_max / factor
			this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp / factor)
			if transform.animation_out then pirate_play_full_animation(store, this, transform.animation_out) end
			return true
		end
	end

	if b.polymorph and branch_ready(b.polymorph, now) then
		local a = b.polymorph
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range or 150, 0, F_FLYING, function(e)
			return e.id ~= this.id and e.health and not e.health.dead and
				(not e.vis or band(e.vis.flags or 0, bor(F_BOSS, F_MINIBOSS)) == 0 and band(e.vis.bans or 0, F_POLYMORPH) == 0)
		end)

		if targets and #targets > 0 then
			local target = targets[math.random(1, #targets)]
			a.ts = now
			if pirate_play_cast(store, this, a.animation or "special", 0.5, target) then
				if store.entities[target.id] and target.health and not target.health.dead then
					local m = E:create_entity("mod_branch_polymorph")
					m.modifier.source_id, m.modifier.target_id, m.modifier.duration = this.id, target.id, a.duration or 10
					m.source_dead_min_duration = a.source_dead_min_duration
					queue_insert(store, m)
				end
			end
			return true
		end
	end

	return false
end

local function branch_enemy_valid_instakill_target(this, a, target)
	if not target or not target.health or target.health.dead then
		return false
	end

	if target.vis then
		if a.vis_bans and band(target.vis.flags or 0, a.vis_bans) ~= 0 then
			return false
		end

		if a.vis_flags and band(target.vis.bans or 0, a.vis_flags) ~= 0 then
			return false
		end
	end

	if a.hp_ratio and target.health.hp > target.health.hp_max * a.hp_ratio then
		return false
	end

	if a.safe_nodes_to_exit and pirate_nodes_to_exit(this) <= a.safe_nodes_to_exit then
		return false
	end

	return true
end

local function branch_enemy_cast_oloch_imprison(store, this, cfg)
	local excluded_templates = {
		seed_defense_flag0 = true,
		level_demon_fissure = true,
		level_demon_ray = true,
		enemy_zeta_demon_fissure = true,
		enemy_zeta_demon_ray = true,
	}
	local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, cfg.range or 200, 0,
		bor(F_FLYING, F_BOSS), function(target)
			return not excluded_templates[target.template_name] and kr4_valid_enemy_soldier_target(target) and
				not U.has_modifiers(store, target, cfg.mod or "mod_zeta_oloch_imprison")
		end)
	local target = targets and targets[1]

	if not target then return false end
	if not cfg.no_animation and not pirate_play_cast(store, this, cfg.animation or "shoot", cfg.cast_time or 0.5, target) then
		return false
	end

	local mod = E:create_entity(cfg.mod or "mod_zeta_oloch_imprison")

	mod.modifier.source_id = this.id
	mod.modifier.target_id = target.id
	mod.modifier.duration = cfg.duration or mod.modifier.duration
	mod.damage = cfg.damage or mod.damage
	mod.tick = cfg.tick or mod.tick
	queue_insert(store, mod)
	return true
end

function branch_enemy_try_skill(store, this)
	local b, now = this.branch, store.tick_ts
	if b.malik_presentation then
		b._malik_taunt_ts = b._malik_taunt_ts or now
		if now - b._malik_taunt_ts >= 25 and #this.enemy.blockers == 0 then
			b._malik_taunt_ts = now
			b._malik_taunt = (b._malik_taunt or 0) % 5 + 1
			MP.say(this, store, "BATTLE", b._malik_taunt, 4)
			pirate_play_full_animation(store, this, "taunt")
			return true
		end
	end
	if branch_enemy_try_transform_on_melee(store, this) then
		return true
	end
	if b.lay_egg and branch_ready(b.lay_egg, now) and
			(not this.nav_path or pirate_nodes_to_exit(this) > (b.lay_egg.safe_nodes_to_exit or 0)) then
		local a = b.lay_egg

		a.ts = now
		if a.cooldown_max then a.cooldown = math.random(a.cooldown_min or a.cooldown, a.cooldown_max) end
		if pirate_play_cast(store, this, a.animation or "special", a.cast_time or 0.4) then
			local egg = E:create_entity(a.egg_template or "zeta_spider_egg")

			egg.pos = V.vclone(this.pos)
			egg.path = this.nav_path and this.nav_path.pi or 1
			egg.subpath = this.nav_path and this.nav_path.spi or 1
			egg.node = this.nav_path and this.nav_path.ni or P:get_start_node(egg.path)
			egg.spawn_template = a.spawn_template or "enemy_zeta_spiderling"
			egg.spawn_count = a.spawn_count or 2
			queue_insert(store, egg)
		end
		return true
	end
	if b.lightseeker_heal and branch_ready(b.lightseeker_heal, now) then
		local h = b.lightseeker_heal

		for _, cfg in ipairs(h.thresholds or {}) do
			if not cfg.done and this.health.hp <= this.health.hp_max * cfg.ratio then
				cfg.done = true
				h.ts = now

				if pirate_play_cast(store, this, h.animation or "heal", h.cast_time or 1.17, this) then
					this.health.hp = km.clamp(0, this.health.hp_max, this.health.hp + cfg.amount)
				end

				return true
			end
		end
	end
	if b.lightseeker_courage and branch_ready(b.lightseeker_courage, now) then
		local c = b.lightseeker_courage
		local denied = c.excluded or {}
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, c.range or 150, 0, 0, function(e)
			return e.id ~= this.id and e.health and not e.health.dead and not denied[e.template_name] and not U.has_modifiers(store, e, c.mod or "mod_magnus_arcane_shield")
		end)

		if targets and #targets >= (c.min_targets or 2) then
			c.ts = now

			if c.sound then
				S:queue(c.sound)
			end

			if pirate_play_cast(store, this, c.animation or "buff", c.cast_time or 0.5) then
				local count = math.min(#targets, math.random(c.min_targets or 2, c.max_targets or 5))

				for i = 1, count do
					local m = E:create_entity(c.mod or "mod_magnus_arcane_shield")

					m.modifier.source_id = this.id
					m.modifier.target_id = targets[i].id
					m.modifier.duration = c.duration or 4
					queue_insert(store, m)
				end
			end

			return true
		end
	end
	if b.instakill and #this.enemy.blockers > 0 and now - (b.instakill.ts or -1e+99) >= (b.instakill.cooldown or 1) then
		local a = b.instakill
		local target

		for _, blocker_id in ipairs(this.enemy.blockers) do
			local candidate = store.entities[blocker_id]

			if branch_enemy_valid_instakill_target(this, a, candidate) then
				target = candidate
				break
			end
		end

		if target then
			b.instakill.ts = now
			if math.random() <= (a.chance or 1) then
				if a.sound then S:queue(a.sound) end
				if pirate_play_cast(store, this, a.animation, a.cast_time or 0.4, target) then
					if a.hp_damage_factor then
						branch_damage(store, this, target, math.ceil(target.health.hp_max * a.hp_damage_factor),
							bor(a.damage_type or DAMAGE_MAGICAL, DAMAGE_NO_DODGE))
					else
						branch_damage(store, this, target, target.health.hp + target.health.hp_max, DAMAGE_TRUE)
					end
					if a.egg_template and this.nav_path then
						local egg = E:create_entity(a.egg_template)
						local nest = a.egg_at_nest and branch_find_nearest_template(store, "velociraptor_nest", this.pos)

						egg.pos = nest and V.vclone(nest.pos) or V.vclone(target.pos)
						if nest then
							egg.pos.y = egg.pos.y + 8
						end
						egg.path = this.nav_path.pi
						egg.subpath = this.nav_path.spi
						egg.node = this.nav_path.ni
						queue_insert(store, egg)
						if nest then
							branch_spawn_scene(store, "fx_velociraptor_nest_hatch", nest.pos.x, nest.pos.y + 8)
						end
						if a.egg_sound then
							S:queue(a.egg_sound)
						end
					end
					if b.reset_ranged_on_melee and b.ranged then b.ranged.ts = now end
					if a.imprison then branch_enemy_cast_oloch_imprison(store, this, a.imprison) end
				if b.malik_presentation then MP.finish(this, store) end
				end
				return true
			end
		end
	end
	if this.melee and this.melee.attacks[1] and this.melee.attacks[1].area_attack then
		local a = this.melee.attacks[1].area_attack
		if #this.enemy.blockers > 0 and now - (a.ts or -1e+99) >= a.cooldown then
			a.ts = now
			if a.sound then S:queue(a.sound) end
			if pirate_play_cast(store, this, a.animation, a.hit_time, store.entities[this.enemy.blockers[1]]) then
				branch_damage_soldiers(store, this, this.pos, a.radius, a.damage_min, a.damage_max, a.damage_type or DAMAGE_PHYSICAL, a.max_count)
			end
			return true
		end
	end
	if b.ranged and not b.ranged.walk_while_shooting and b.ranged.stand_ground and (not b.ranged.no_melee or #this.enemy.blockers == 0) then
		local a = b.ranged
		local target = U.find_nearest_soldier(store.entities, this.pos, a.min_range or 0, a.max_range, a.vis_flags or 0, a.vis_bans or F_FLYING, kr4_valid_enemy_soldier_target)

		if target and not branch_ready(a, now) then
			U.animation_start(this, a.hold_animation or "idle", target.pos.x < this.pos.x, store.tick_ts, true, nil, true)
			coroutine.yield()
			return true
		end
	end
	if b.ranged and not b.ranged.walk_while_shooting and branch_ready(b.ranged, now) and (not b.ranged.no_melee or #this.enemy.blockers == 0) then
		local a = b.ranged
		local target = U.find_nearest_soldier(store.entities, this.pos, a.min_range or 0, a.max_range, a.vis_flags or 0, a.vis_bans or F_FLYING, kr4_valid_enemy_soldier_target)
		if target then
			a.ts = now
			if a.sound then S:queue(a.sound) end
			if pirate_play_cast(store, this, a.animation, a.hit_time or a.cast_time, a.no_facing and nil or target, a.sprite_ids) then
				if a.projectile then
					for i = 1, a.count or 1 do
						branch_enemy_fire_projectile(store, this, a, target)
						if i < (a.count or 1) and a.followup_animation then
							U.animation_start(this, a.followup_animation, target.pos.x < this.pos.x, store.tick_ts, false, a.sprite_ids and a.sprite_ids[1], true)
							U.y_wait(store, a.shot_interval or 0.167, function()
								return this.health.dead or this.unit.is_stunned
							end)
							if this.health.dead or this.unit.is_stunned then break end
						end
					end
					for _, chance in ipairs(a.extra_projectile_chances or {}) do
						if math.random() <= chance then
							branch_enemy_fire_projectile(store, this, a, target)
						end
					end
				else
					local targets = a.radius and U.find_soldiers_in_range(store.entities, target.pos, 0, a.radius, 0, F_FLYING, kr4_valid_enemy_soldier_target) or {target}
					for _, victim in ipairs(targets or {}) do
						for _ = 1, a.count or 1 do
							branch_damage(store, this, victim, math.random(a.damage_min, a.damage_max), a.damage_type)
						end
					end
					if a.freeze then
						local m = E:create_entity("mod_branch_freeze")
						m.modifier.source_id, m.modifier.target_id, m.modifier.duration = this.id, target.id, a.freeze
						queue_insert(store, m)
					end
				end
				if a.end_animation and not this.health.dead and not this.unit.is_stunned then
					pirate_play_full_animation(store, this, a.end_animation, nil, a.sprite_ids)
				end
				if a.imprison then branch_enemy_cast_oloch_imprison(store, this, a.imprison) end
			end
			return true
		end
	end
	if b.snipe and branch_ready(b.snipe, now) then
		local a = b.snipe
		local target = U.find_nearest_soldier(store.entities, this.pos, a.min_range or 0, a.max_range, a.vis_flags or 0, a.vis_bans or F_FLYING, kr4_valid_enemy_soldier_target)
		if target then
			a.ts = now
			if a.sound then S:queue(a.sound) end
			if pirate_play_cast(store, this, a.animation, a.hit_time or a.cast_time, a.no_facing and nil or target) then
				if a.projectile then
					branch_enemy_fire_projectile(store, this, a, target)
				else
					branch_damage(store, this, target, math.random(a.damage_min, a.damage_max), a.damage_type)
				end
			end
			return true
		end
	end
	if b.drum_buff and branch_ready(b.drum_buff, now) then
		local a = b.drum_buff
		local excluded = a.excludes or {}
		local allies = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, 0, 0, function(e)
			return e.id ~= this.id and e.health and not e.health.dead and not excluded[e.template_name]
		end)

		if allies and #allies >= (a.min_targets or 1) then
			a.ts = now

			if a.sound then S:queue(a.sound) end

			if (not a.animation or pirate_play_cast(store, this, a.animation, a.cast_time or 0.3, nil, a.sprite_ids)) then
				if a.decal_fx then
					branch_spawn_fx_at(store, a.decal_fx, this.pos)
				end

				for i, ally in ipairs(allies) do
					if i > (a.max_targets or 10) then break end

					if a.heal_mod and not U.has_modifiers(store, ally, a.heal_mod) then
						local m = E:create_entity(a.heal_mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = ally.id
						m.modifier.duration = a.heal_duration or m.modifier.duration
						m.tick = a.heal_tick or m.tick
						m.heal = a.heal_amount or m.heal
						queue_insert(store, m)
					end

					if a.speed_mod and not U.has_modifiers(store, ally, a.speed_mod) then
						local m = E:create_entity(a.speed_mod)

						m.modifier.source_id = this.id
						m.modifier.target_id = ally.id
						m.modifier.duration = a.speed_duration or m.modifier.duration
						m.speed_factor = a.speed_factor or m.speed_factor
						queue_insert(store, m)
					end
				end

				if a.loop_animation and a.loop_time and a.loop_time > 0 then
					pirate_start_animation(this, a.loop_animation, nil, store.tick_ts, true, a.sprite_ids, true)
					U.y_wait(store, a.loop_time, function() return this.health.dead or this.unit.is_stunned end)
				end

				if a.end_animation and not this.health.dead and not this.unit.is_stunned then
					pirate_play_full_animation(store, this, a.end_animation, nil, a.sprite_ids)
				end
			end

			return true
		end
	end
	if b.heal and branch_ready(b.heal, now) then
		local h = b.heal
		local excluded = h.excludes or {}
		local hp_threshold = h.hp_threshold or 1
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, h.range, 0, 0, function(e)
			local source = e.zeta_source_metadata

			return (h.include_self or e.id ~= this.id) and e.health and not e.health.dead and
				e.health.hp < e.health.hp_max * hp_threshold and
				not excluded[e.template_name] and (h.include_mecha or not (source and source.is_mecha))
		end)
		if targets and #targets > 0 then
			h.ts = now
			if h.sound then S:queue(h.sound) end
			if h.no_animation or pirate_play_cast(store, this, h.animation, h.cast_time or 0.4, targets[1]) then
				for i, target in ipairs(targets) do
					if i > (h.max_targets or 1) then break end
					if h.projectile then
						branch_enemy_fire_projectile(store, this, h, target)
					end
					if h.mod then
						local m = E:create_entity(h.mod)
						m.modifier.source_id = this.id
						m.modifier.target_id = target.id
						m.modifier.duration = h.duration or m.modifier.duration
						m.tick = h.tick or m.tick
						m.heal = h.tick_heal or h.heal or m.heal
						queue_insert(store, m)
					else
						target.health.hp = km.clamp(0, target.health.hp_max, target.health.hp + (h.amount or target.health.hp_max * h.factor))
					end
				end
			end
			return true
		end
	end
	if b.repair and branch_ready(b.repair, now) then
		local r = b.repair
		local targets = {}

		for _, e in pairs(store.entities) do
			if e.id ~= this.id and e.enemy and e.health and e.nav_path and U.is_inside_ellipse(e.pos, this.pos, r.range) and (not r.targets or r.targets[e.template_name]) then
				local repairable_dead = branch_repairable_dead_target(e, r)
				if (r.dead_only and repairable_dead or not r.dead_only and (repairable_dead or not e.health.dead and e.health.hp < e.health.hp_max)) and not e._branch_repairing then
					table.insert(targets, e)
				end
			end
		end

		if #targets > 0 then
			table.sort(targets, function(a, b)
				local ad = a.health.dead and 0 or a.health.hp / math.max(1, a.health.hp_max)
				local bd = b.health.dead and 0 or b.health.hp / math.max(1, b.health.hp_max)

				return ad < bd
			end)

			r.ts = now

			if r.sound then S:queue(r.sound) end

			local repair_target = targets[1]
			repair_target._branch_repairing = true
			local repaired = branch_play_repair(store, this, r, repair_target)

			if repaired and store.entities[repair_target.id] and not this.health.dead and not this.unit.is_stunned and (not r.interrupt_on_block or #this.enemy.blockers == 0) then
				for i, target in ipairs(targets) do
					if i > (r.max_targets or 1) then break end

					local factor = r.hp_factors and r.hp_factors[target.template_name] or r.factor or 0.2
					local hp = math.max(1, math.floor(target.health.hp_max * factor))

					if target.health.dead then
						target._branch_repairable = nil
						local replacement = branch_spawn_on_path(store, target.template_name, target, 0)

						if replacement then
							replacement.pos = V.vclone(target.pos)
							replacement.health.hp = hp
						end

						queue_remove(store, target)
					else
						target.health.hp = km.clamp(0, target.health.hp_max, target.health.hp + hp)
					end
				end
			elseif r.break_on_interrupt and store.entities[repair_target.id] and repair_target.health and repair_target.health.dead then
				repair_target._branch_repairable = nil
				queue_remove(store, repair_target)
			end

			if store.entities[repair_target.id] then
				repair_target._branch_repairing = nil
			end

			return true
		end
	end
	if b.spawn and not b.spawn.passive and branch_ready(b.spawn, now) and (not this.nav_path or pirate_nodes_to_exit(this) > (b.spawn.safe_nodes_to_exit or 0)) then
		local s = b.spawn
		s.ts = now
		if s.sound then S:queue(s.sound) end
		if (not s.animation or pirate_play_cast(store, this, s.animation, s.cast_time or 0.5)) then
			for i = 1, s.count do
				local template = s.template or s.templates and s.templates[math.random(1, #s.templates)]
				local spawned = template and branch_spawn_on_path(store, template, this, -(s.node_gap or 2) * i)

				if spawned and s.zero_gold then
					spawned.enemy.gold = 0
				end
			end
		end
		return true
	end
	if b.spawn_eagle and branch_ready(b.spawn_eagle, now) and not this._branch_spawn_eagle_done then
		local a = b.spawn_eagle
		local target = not a.range or U.find_nearest_soldier(store.entities, this.pos, 0, a.range, 0, F_FLYING, kr4_valid_enemy_soldier_target)
		local alive = 0

		for _, e in pairs(store.entities) do
			if e.owner_id == this.id and e.template_name == a.template and e.health and not e.health.dead then
				alive = alive + 1
			end
		end

		if target and alive < (a.max_alive or 999) then
			a.ts = now
			if a.once then
				this._branch_spawn_eagle_done = true
			end
			if a.sound then S:queue(a.sound) end
			if pirate_play_cast(store, this, a.animation, a.cast_time or 0.2, target) then
				local eagle

				if this.nav_path then
					local pi = this.nav_path.pi
					local spi = this.nav_path.spi
					local dir = branch_path_dir(pi)
					local ni = branch_shift_path_node({pi = pi, ni = this.nav_path.ni, dir = dir}, -3)

					eagle = branch_spawn_on_path(store, a.template, nil, 0, pi, spi, ni)

					if eagle then
						eagle.nav_path.dir = dir
					end
				else
					eagle = branch_spawn_on_path(store, a.template, this, -3)
				end

				if eagle then
					eagle.owner_id = this.id
				end

				if a.prefix_on_spawn then
					local sprite = this.render and this.render.sprites and this.render.sprites[1]

					if sprite then
						sprite.angles.walk = {a.prefix_on_spawn .. "Walk", a.prefix_on_spawn .. "WalkUp", a.prefix_on_spawn .. "WalkDown"}
						sprite.name = a.idle_name or (a.prefix_on_spawn .. "Idle")
						U.animation_start(this, sprite.name, nil, store.tick_ts, true, nil, true)
					end

					if this.unit then
						this.unit.death_animation = a.prefix_on_spawn .. "Death"
					end
				end
			end
			return true
		end
	end
	if b.transform_unit and branch_ready(b.transform_unit, now) then
		local a = b.transform_unit
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, 0, bor(F_BOSS, F_MINIBOSS), function(e)
			return e.template_name == a.from and e.nav_path and e.health and not e.health.dead
		end)
		if targets and #targets > 0 then
			a.ts = now
			if a.sound then S:queue(a.sound) end
			if pirate_play_cast(store, this, a.animation, a.cast_time or 0.3, targets[1]) then
				if a.result_sound then S:queue(a.result_sound) end
				for i, target in ipairs(targets) do
					if i > (a.max_targets or 1) then break end
					local replacement = branch_spawn_on_path(store, a.to, target, 0)
					if replacement then
						replacement.pos = V.vclone(target.pos)
						replacement.nav_path.pi = target.nav_path.pi
						replacement.nav_path.spi = target.nav_path.spi
						replacement.nav_path.ni = target.nav_path.ni
					end
					queue_remove(store, target)
				end
			end
			return true
		end
	end
	if b.area_spawn_dead and branch_ready(b.area_spawn_dead, now) then
		local a = b.area_spawn_dead
		local targets = {}
		for _, e in pairs(store.entities) do
			local death_types = e.health and e.health.last_damage_types or 0
			local invalid_death = bor(DAMAGE_EXPLOSION, DAMAGE_FX_EXPLODE, DAMAGE_DISINTEGRATE, DAMAGE_DISINTEGRATE_BOSS, DAMAGE_EAT, DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS)
			if e.health and e.health.dead and not e.health.death_finished_ts and not e._branch_corpse_consumed and
				e.nav_path and (not a.includes or a.includes[e.template_name]) and
				band(death_types, invalid_death) == 0 and not (e.unit and (e.unit.hide_after_death or e.unit.hide_during_death)) and
				U.is_inside_ellipse(e.pos, this.pos, a.range) then
				table.insert(targets, e)
			end
		end
		if #targets > 0 then
			a.ts = now
			if a.sound then S:queue(a.sound) end
			if pirate_play_cast(store, this, a.animation, a.cast_time or 0.4, targets[1]) then
				for i, target in ipairs(targets) do
					if i > (a.max_targets or 1) then break end
					target._branch_corpse_consumed = true
					local spawned = branch_spawn_on_path(store, a.template, target, 0)
					if spawned and a.zero_gold then spawned.enemy.gold = 0 end
					queue_remove(store, target)
				end
			end
			return true
		end
	end
	if b.tower_block and branch_ready(b.tower_block, now) then
		local a = b.tower_block
		local towers = branch_find_towers(store, this.pos, a.range)
		if #towers > 0 then
			a.ts = now
			if a.sound then S:queue(a.sound) end
			if pirate_play_cast(store, this, a.animation, a.cast_time or 0.5, towers[1]) then
				for i, tower in ipairs(towers) do
					if i > (a.max_targets or 1) then break end
					local m = E:create_entity(a.mod or "mod_branch_tower_block")
					m.modifier.source_id, m.modifier.target_id, m.modifier.duration = this.id, tower.id, a.duration
					queue_insert(store, m)
				end
			end
			return true
		end
	end
	if b.shield and branch_ready(b.shield, now) and not this._shield_mod then
		local a = b.shield
		local m = E:create_entity(a.mod or "infuser_cast_shield_mod")

		a.ts = now
		m.modifier.source_id = this.id
		m.modifier.target_id = this.id
		if a.shield_hp then
			m.modifier.shield_hp = a.shield_hp
		end
		queue_insert(store, m)

		return true
	end
	if b.polymorph and branch_ready(b.polymorph, now) and (not this.nav_path or pirate_nodes_to_exit(this) > (b.polymorph.safe_nodes_to_exit or 0)) then
		local a = b.polymorph
		local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.range, 0, bor(F_FLYING, F_HERO), kr4_valid_enemy_soldier_target)
		if targets and #targets > 0 then
			a.ts = now
			if pirate_play_cast(store, this, a.animation, 0.5, targets[1]) then
				for i, target in ipairs(targets) do
					if i > (a.max_targets or 1) then break end
					if store.entities[target.id] and target.health and not target.health.dead then
						if a.instakill then
							if a.sheep_template then
								local nodes = P:nearest_nodes(target.pos.x, target.pos.y, nil, nil, true)

								if nodes and nodes[1] then
									local sheep = branch_spawn_on_path(store, a.sheep_template, nil, 0, nodes[1][1], nodes[1][2], nodes[1][3])

									if sheep then
										sheep.pos = V.vclone(target.pos)
										sheep.enemy.gold = 0
									end
								end
							end
							branch_damage(store, this, target, target.health.hp + target.health.hp_max, bor(DAMAGE_TRUE, DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS, DAMAGE_NO_DODGE))
						else
							local m = E:create_entity("mod_branch_polymorph")
							m.modifier.source_id, m.modifier.target_id, m.modifier.duration = this.id, target.id, a.duration
							m.source_dead_min_duration = a.source_dead_min_duration
							queue_insert(store, m)
						end
					end
				end
			end
			return true
		end
	end
	if b.stun and branch_ready(b.stun, now) then
		local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, b.stun.range, 0, F_FLYING, kr4_valid_enemy_soldier_target)
		if targets and #targets > 0 then
			b.stun.ts = now
			if pirate_play_cast(store, this, b.stun.animation, 0.4, targets[1]) then
				for _, target in ipairs(targets) do
					local m = E:create_entity("mod_stun")
					m.modifier.source_id, m.modifier.target_id, m.modifier.duration = this.id, target.id, b.stun.duration
					queue_insert(store, m)
				end
			end
			return true
		end
	end
	if b.teleport_allies and branch_ready(b.teleport_allies, now) and (not this.nav_path or pirate_nodes_to_exit(this) > (b.teleport_allies.safe_nodes_to_exit or 0)) then
		local a = b.teleport_allies
		local denied = a.excludes or {}
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, a.range, 0, bor(F_BOSS, F_MINIBOSS), function(e)
			if e.id == this.id or not e.nav_path or denied[e.template_name] then return false end
			return not e._branch_arcane_teleport_ts or now - e._branch_arcane_teleport_ts >= (a.target_cooldown or a.cooldown or 8)
		end)
		if targets and #targets >= a.min_targets then
			a.ts = now
			if pirate_play_cast(store, this, a.animation, 0.5) then
				for i, target in ipairs(targets) do
					if i > (a.max_targets or 10) then break end
					target.nav_path.ni = branch_shift_path_node(target.nav_path, a.nodes)
					target.pos = V.vclone(P:node_pos(target.nav_path.pi, target.nav_path.spi, target.nav_path.ni))
					target._branch_arcane_teleport_ts = now
				end
			end
			return true
		end
	end
	if b.shadow_jump and branch_shared_ready(b, b.shadow_jump, now) and this.nav_path and pirate_nodes_to_exit(this) > (b.shadow_jump.safe_nodes_to_exit or 0) and pirate_nodes_from_start(this) >= (b.shadow_jump.safe_nodes_start or 0) then
		local jump_target = not b.shadow_jump.require_target or U.find_nearest_soldier(store.entities, this.pos, 0, b.shadow_jump.trigger_range or 125, 0, F_FLYING, kr4_valid_enemy_soldier_target)

		if b.shadow_jump.require_target and not jump_target then
			return false
		end

		b.shadow_jump.ts = now
		branch_shared_mark(b, b.shadow_jump, now)
		if b.shadow_jump.sound then S:queue(b.shadow_jump.sound) end
		if pirate_play_full_animation(store, this, b.shadow_jump.animation_out) then
			if b.shadow_jump.leave_copy then branch_spawn_on_path(store, b.shadow_jump.leave_copy, this, 0) end
			this.nav_path.ni = branch_shift_path_node(this.nav_path, b.shadow_jump.nodes)
			this.pos = V.vclone(P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni))
			pirate_play_full_animation(store, this, b.shadow_jump.animation_in)
			local walk_time = b.shadow_jump.walk_after or 0
			local walk_ts = store.tick_ts

			while walk_time > 0 and not this.health.dead and #this.enemy.blockers == 0 and store.tick_ts - walk_ts < walk_time do
				kr4_enemy_walk_path_step(store, this, b.shadow_jump.walk_animation)
			end
		end
		return true
	end
	if b.path_jump and branch_ready(b.path_jump, now) and this.nav_path and #this.enemy.blockers == 0 then
		local a = b.path_jump
		a.ts = now
		if a.sound then S:queue(a.sound) end
		if pirate_play_full_animation(store, this, a.animation_out) then
			this.nav_path.ni = branch_shift_path_node(this.nav_path, a.nodes)
			this.pos = V.vclone(P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni))
			pirate_play_full_animation(store, this, a.animation_in)
		end
		return true
	end
	if b.charge and branch_ready(b.charge, now) and this.nav_path and #this.enemy.blockers == 0 and pirate_nodes_to_exit(this) > (b.charge.safe_nodes_to_exit or 0) then
		local a = b.charge
		a.ts = now
		local sprite = this.render and this.render.sprites[1]
		local old_angles = sprite and sprite.angles and sprite.angles.walk
		local old_bans = this.vis.bans
		local speed_factor = branch_begin_speed_skill(this, a.factor)
		if a.sound then S:queue(a.sound) end
		if sprite and a.animation then sprite.angles.walk = {a.animation, a.animation_up or a.animation .. "Up", a.animation_down or a.animation .. "Down"} end
		if a.ignore_block then
			this.vis.bans = bor(this.vis.bans, F_BLOCK)
		end
		local ts = store.tick_ts
		local damage_ts = store.tick_ts - (a.tick_time or 0.1)
		while not this.health.dead and not this.unit.is_stunned and (a.ignore_block or #this.enemy.blockers == 0) and store.tick_ts - ts < (a.duration or 1) do
			if a.damage_min and store.tick_ts - damage_ts >= (a.tick_time or 0.1) then
				damage_ts = store.tick_ts
				branch_damage_soldiers(store, this, this.pos, a.radius or 25, a.damage_min, a.damage_max or a.damage_min, a.damage_type or DAMAGE_PHYSICAL, a.max_count)
			end
			kr4_enemy_walk_path_step(store, this, a.animation)
		end
		branch_end_speed_skill(this, speed_factor)
		this.vis.bans = old_bans
		if sprite and old_angles then
			sprite.angles.walk = old_angles
			U.animation_start(this, old_angles[1] or "walk", sprite.flip_x, store.tick_ts, true, nil, true)
		end
		return true
	end
	if b.buried and branch_ready(b.buried, now) and this.nav_path and #this.enemy.blockers == 0 then
		local a = b.buried
		a.ts = now
		if a.sound then S:queue(a.sound) end
		if a.animation_in then pirate_play_full_animation(store, this, a.animation_in) end
		local old_bans = this.vis.bans
		this.vis.bans = bor(this.vis.bans, F_BLOCK, F_RANGED, F_AREA, F_MOD)
		this.motion.max_speed = this.motion.max_speed * a.factor
		U.animation_start(this, a.animation, nil, store.tick_ts, true, nil, true)
		local ts = store.tick_ts
		while not this.health.dead and store.tick_ts - ts < a.duration do kr4_enemy_walk_path_step(store, this, a.animation) end
		this.motion.max_speed = this.motion.max_speed / a.factor
		this.vis.bans = old_bans
		if not this.health.dead and a.animation_out then pirate_play_full_animation(store, this, a.animation_out) end
		return true
	end
	if b.fly and branch_ready(b.fly, now) and this.nav_path and #this.enemy.blockers == 0 and pirate_nodes_to_exit(this) > (b.fly.safe_nodes_to_exit or 0) then
		local a = b.fly
		local sprite = this.render and this.render.sprites[1]
		local old_angles = sprite and sprite.angles and sprite.angles.walk
		local old_death_animation = this.unit.death_animation
		a.ts = now
		if a.animation_in then
			pirate_play_full_animation(store, this, a.animation_in)
		end
		local old_flags, old_bans = this.vis.flags, this.vis.bans
		local speed_factor = branch_begin_speed_skill(this, a.factor)
		this.vis.flags = bor(this.vis.flags, F_FLYING)
		this.vis.bans = bor(this.vis.bans, F_BLOCK)
		if sprite and a.animation then
			sprite.angles.walk = {a.animation, a.animation_up or a.animation .. "Up", a.animation_down or a.animation .. "Down"}
			U.animation_start(this, a.animation, sprite.flip_x, store.tick_ts, true, nil, true)
		end
		if a.death_animation then this.unit.death_animation = a.death_animation end
		local ts = store.tick_ts
		while not this.health.dead and not this.unit.is_stunned and store.tick_ts - ts < (a.duration or 1) do
			kr4_enemy_walk_path_step(store, this, a.animation)
		end
		branch_end_speed_skill(this, speed_factor)
		this.vis.flags, this.vis.bans = old_flags, old_bans
		if sprite and old_angles then sprite.angles.walk = old_angles end
		if not this.health.dead and a.animation_out then
			pirate_play_full_animation(store, this, a.animation_out)
		end
		if not this.health.dead then this.unit.death_animation = old_death_animation end
		return true
	end
	if b.warcry and branch_ready(b.warcry, now) then
		local allies = U.find_enemies_in_range(store.entities, this.pos, 0, b.warcry.range, 0, bor(F_BOSS, F_MINIBOSS), function(e)
			return e.id ~= this.id and (not b.warcry.targets or b.warcry.targets[e.template_name])
		end)
		if allies and #allies > 0 then
			b.warcry.ts = now
			if pirate_play_cast(store, this, b.warcry.animation, 0.5) then
				for _, ally in ipairs(allies) do
					local m = E:create_entity(b.warcry.mod or "mod_branch_damage")
					m.modifier.source_id, m.modifier.target_id, m.modifier.duration = this.id, ally.id, b.warcry.duration
					m.damage_factor = b.warcry.factor
					m.speed_factor = b.warcry.speed_factor
					m.hp_bonus = b.warcry.hp_bonus
					queue_insert(store, m)
				end
			end
			return true
		end
	end
	if b.clone and branch_shared_ready(b, b.clone, now) then
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, b.clone.range, 0, 0, function(e) return e.template_name == b.clone.template end)
		if targets and #targets >= b.clone.min_targets then
			b.clone.ts = now
			branch_shared_mark(b, b.clone, now)
			if b.clone.sound then S:queue(b.clone.sound) end
			if pirate_play_cast(store, this, b.clone.animation, b.clone.cast_time) then
				for i, target in ipairs(targets) do
					if i > b.clone.max_targets then break end
					branch_spawn_on_path(store, target.template_name, target, math.random(7, 14))
				end
			end
			return true
		end
	end
	if b.water_pool and branch_ready(b.water_pool, now) then
		local target = U.find_nearest_soldier(store.entities, this.pos, 0, 1000, 0, F_FLYING, kr4_valid_enemy_soldier_target)
		if target then
			b.water_pool.ts = now
			if pirate_play_cast(store, this, b.water_pool.animation, b.water_pool.cast_time, target) then
				local pool = E:create_entity("dragon_king_water_pool")
				pool.pos, pool.duration, pool.radius = V.vclone(target.pos), b.water_pool.duration, b.water_pool.radius
				pool.source_id = this.id
				queue_insert(store, pool)
			end
			return true
		end
	end
	if b.doomsday and branch_ready(b.doomsday, now) then
		local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, 9999, 0, F_FLYING, kr4_valid_enemy_soldier_target)
		if targets and #targets >= 2 then
			b.doomsday.ts = now
			if b.doomsday.sound then S:queue(b.doomsday.sound) end
			if pirate_play_cast(store, this, b.doomsday.animation, b.doomsday.cast_time) then
				for i = 1, b.doomsday.count do
					local target = targets[math.random(1, #targets)]
					local meteor = E:create_entity("great_t_meteor_controller")
					meteor.pos = V.v(target.pos.x + math.random(-50, 50), target.pos.y + math.random(-30, 30))
					meteor.source_id, meteor.damage_min, meteor.damage_max = this.id, b.doomsday.damage_min, b.doomsday.damage_max
					queue_insert(store, meteor)
				end
			end
			return true
		end
	end
	if b.tower_destroy and branch_ready(b.tower_destroy, now) then
		local towers = branch_find_towers(store, this.pos, b.tower_destroy.range)
		if #towers > 0 then
			b.tower_destroy.ts = now
			if b.tower_destroy.sound then S:queue(b.tower_destroy.sound) end
			if pirate_play_cast(store, this, b.tower_destroy.animation, b.tower_destroy.cast_time, towers[1]) then
				if store.entities[towers[1].id] then
					if b.malik_presentation then MP.tower_impact(store, towers[1].pos) end
					towers[1].tower.destroy = true
				end
				if b.malik_presentation then MP.finish(this, store) end
			end
			return true
		end
	end
	if b.rocket_jump and branch_ready(b.rocket_jump, now) and this.nav_path and #this.enemy.blockers == 0 then
		local a = b.rocket_jump
		local destination

		if a.destinations and #a.destinations > 0 then
			destination = a.destinations[a.destination_index or 1]
			if not destination then return false end

			if destination and destination.reach_node and (this.nav_path.ni or 0) < destination.reach_node then
				return false
			end
		end

		a.ts = now
		if a.sound then S:queue(a.sound) end
		if pirate_play_full_animation(store, this, a.animation_out) then
			local old_speed = this.motion.max_speed
			local old_bans = this.vis.bans
			local target_pi, target_spi, target_node

			if a.destinations and #a.destinations > 0 then
				destination = destination or a.destinations[a.destination_index or 1]

				target_pi = branch_kr4_path_rank(destination.path)
				target_spi = (destination.subpath or 0) + 1
				target_node = destination.node

				if not P.paths[target_pi] then
					target_pi = this.nav_path.pi
				end
				if P.paths[target_pi] and not P.paths[target_pi][target_spi] then
					target_spi = 1
				end
				target_node = branch_clamp_path_node(target_pi, target_node)
			else
				target_node = branch_shift_path_node(this.nav_path, a.nodes)
			end

			local start_pos = V.vclone(this.pos)
			local landing_pos = V.vclone(P:node_pos(target_pi or this.nav_path.pi, target_spi or this.nav_path.spi, target_node))
			local jump_ts = store.tick_ts
			local duration = a.cross_path_travel_time or 0.6
			local old_z = {}
			for sid, sprite in ipairs(this.render.sprites) do
				old_z[sid] = sprite.z
				if sprite.animated then sprite.z = Z_OBJECTS_COVERS + 1 end
			end
			this.vis.bans = bor(old_bans, F_BLOCK)
			pirate_start_animation(this, a.animation or "jumpTravel", nil, store.tick_ts, true, nil, true)
			local phase = 0
			while not this.health.dead and not this.unit.is_stunned and store.tick_ts - jump_ts < duration do
				phase = math.min(1, (store.tick_ts - jump_ts) / duration)
				this.pos.x = start_pos.x + (landing_pos.x - start_pos.x) * phase
				this.pos.y = start_pos.y + (landing_pos.y - start_pos.y) * phase + math.sin(math.pi * phase) * (a.jump_height or 80)
				coroutine.yield()
			end
			this.motion.max_speed = old_speed
			this.vis.bans = old_bans
			for sid, sprite in ipairs(this.render.sprites) do sprite.z = old_z[sid] end
			if this.health.dead or this.unit.is_stunned then
				-- Cancel at the departure node; do not leave a corpse or stunned boss airborne.
				this.pos = start_pos
				return true
			end
			this.nav_path.pi = target_pi or this.nav_path.pi
			this.nav_path.spi = target_spi or this.nav_path.spi
			this.nav_path.ni = target_node
			this.nav_path.dir = branch_path_dir(this.nav_path.pi)
			this.pos = landing_pos
			if a.destinations then a.destination_index = (a.destination_index or 1) + 1 end
			if pirate_play_cast(store, this, a.animation_in, a.land_hit_time or 0.3) then
				branch_spawn_fx_at(store, "fx_branch_malik_jump_decal", this.pos)
				if a.hit_sound then S:queue(a.hit_sound) end
				branch_damage_soldiers(store, this, this.pos, a.radius, a.damage_min, a.damage_max, DAMAGE_PHYSICAL, 8)
				MP.finish(this, store)
			end
		end
		return true
	end
	return false
end

local function branch_enemy_allows_death_spawn(this)
	local h = this and this.health
	local damage_types = h and h.last_damage_types or 0
	local bans = bor(DAMAGE_EAT, DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS, DAMAGE_DISINTEGRATE, DAMAGE_DISINTEGRATE_BOSS, DAMAGE_FX_EXPLODE)

	return band(damage_types, bans) == 0
end

function branch_enemy_death(store, this)
	local b = this.branch
	if b.death_damage then
		local d = b.death_damage

		branch_damage_soldiers(store, this, this.pos, d.range, d.damage_min, d.damage_max, d.damage_type or DAMAGE_PHYSICAL, d.max_count or 99)
	end
	if b.end_level_on_death and not b.malik_presentation then
		branch_kill_all_enemies_for_victory(store, b.stop_wave_spawns_on_death)
	end
	if b.end_level_on_last_of_template then
		local others_alive = false
		for _, e in pairs(store.entities) do
			if e.id ~= this.id and e.template_name == this.template_name and e.health and not e.health.dead then
				others_alive = true
				break
			end
		end
		if not others_alive then branch_kill_all_enemies_for_victory(store) end
	end
	if b.death_spawn and branch_enemy_allows_death_spawn(this) then
		local spawned = branch_spawn_on_path(store, b.death_spawn, this, 0)
		if spawned then
			spawned.pos = V.vclone(this.pos)
		end
	end
	if b.death_freeze and math.random() <= (b.death_freeze.chance or 1) then
		local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, b.death_freeze.range, 0, F_FLYING, kr4_valid_enemy_soldier_target)
		for i, target in ipairs(targets or {}) do
			if i > (b.death_freeze.max_targets or 99) then break end
			local m = E:create_entity("mod_branch_freeze")
			m.modifier.source_id, m.modifier.target_id = this.id, target.id
			m.modifier.duration = b.death_freeze.duration or 2
			queue_insert(store, m)
		end
	end

	if b.boss_death then
		local boss_death = b.boss_death
		if b.malik_presentation then MP.clear(this, store) end

		SU.hide_shadow(this, true)

		if this.health_bar then
			this.health_bar.hidden = true
		end
		if this.ui then
			this.ui.can_click = false
			this.ui.can_select = false
			this.ui.z = -1
		end

		if this.sound_events and this.sound_events.death then
			S:queue(this.sound_events.death, this.sound_events.death_args)
		end
		for _, sound in ipairs(boss_death.sounds or {}) do
			S:queue(sound.name, sound.delay and {delay = sound.delay} or nil)
		end

		local animation = boss_death.animation or this.unit.death_animation or "death"

		U.animation_start(this, animation, nil, store.tick_ts, false)

		local death_ts = store.tick_ts

		if boss_death.sequence then
			local animation_timeout = boss_death.animation_timeout or 5

			while store.tick_ts - death_ts < animation_timeout and not U.animation_finished(this) do
				coroutine.yield()
			end

			if boss_death.loop_animation and (boss_death.loop_duration or 0) > 0 then
				U.animation_start(this, boss_death.loop_animation, nil, store.tick_ts, true)
				if b.malik_presentation then
					for i = 1, 2 do
						MP.say(this, store, "END", i, 4)
						U.y_wait(store, 4)
					end
					MP.clear(this, store)
				else
					U.y_wait(store, boss_death.loop_duration)
				end
			end

			if boss_death.end_animation then
				U.animation_start(this, boss_death.end_animation, nil, store.tick_ts, false)

				local end_ts = store.tick_ts
				local end_timeout = boss_death.end_timeout or 5

				while store.tick_ts - end_ts < end_timeout and not U.animation_finished(this) do
					coroutine.yield()
				end
			end
		else
			local delay = boss_death.delay or 0

			while store.tick_ts - death_ts < delay do
				coroutine.yield()
			end
		end

		if b.malik_presentation and b.end_level_on_death then
			branch_kill_all_enemies_for_victory(store, b.stop_wave_spawns_on_death)
		end
		this.health.death_finished_ts = store.tick_ts
		queue_remove(store, this)

		return
	end

	SU.hide_shadow(this, true)
	SU.y_enemy_death(store, this)
end

function scripts.branch_enemy.update(this, store)
	local b = this.branch

	if not b._initialized then
		b._initialized = true
		b._base_speed = this.motion and this.motion.max_speed or 0
	end

	branch_mark_ready_tables(b, store.tick_ts)
	local melee_attack = this.melee and this.melee.attacks and this.melee.attacks[1]
	b._last_melee_ts = melee_attack and melee_attack.ts
	b._melee_ts_initialized = true
	b._regen_ts = store.tick_ts
	b._lifetime_ts = store.tick_ts
	if b.spawn_fx then
		local fx_name = b.spawn_fx
		local fx_pos = V.v(this.pos.x, this.pos.y + (b.spawn_fx_y or 0))

		b.spawn_fx = nil
		branch_spawn_fx_at(store, fx_name, fx_pos)

		if b.spawn_delay and b.spawn_delay > 0 then
			U.y_wait(store, b.spawn_delay, function()
				return this.health.dead
			end)

			if this.health.dead then
				branch_enemy_death(store, this)
				return
			end
		end
	end
	if b.spawn_animation then
		local animation = b.spawn_animation
		b.spawn_animation = nil
		if b.spawn_sound then S:queue(b.spawn_sound) end
		pirate_play_full_animation(store, this, animation)
	end
	if b.revive then
		b._revive_ts = store.tick_ts
	end
	local break_fn = function(store, entity)
		branch_enemy_passives(store, entity)
		return branch_enemy_try_skill(store, entity)
	end
	while true do
		if b.lifetime and store.tick_ts - b._lifetime_ts >= b.lifetime and not this.health.dead then
			this.health.last_damage_types = DAMAGE_NO_SPAWNS
			this.health.hp = 0
			this.health.dead = true
		end
		if this.health.dead then branch_enemy_death(store, this) return end
		if this.unit.is_stunned then
			SU.y_enemy_stun(store, this)
		else
			branch_enemy_passives(store, this)
			if b.revive and b._revive_ts and store.tick_ts - b._revive_ts >= b.revive_after and (not this.nav_path or pirate_nodes_to_exit(this) > (b.revive_safe_nodes or 0)) then
				if b.revive_sound then S:queue(b.revive_sound) end
				if b.revive_animation then
					if not pirate_play_full_animation(store, this, b.revive_animation) then
						if this.health.dead then
							branch_enemy_death(store, this)
						end
						return
					end
				end
				if b.revive_delay_after and b.revive_delay_after > 0 then
					U.y_wait(store, b.revive_delay_after, function() return this.health.dead end)
					if this.health.dead then
						branch_enemy_death(store, this)
						return
					end
				end
				branch_spawn_on_path(store, b.revive, this, 0)
				queue_remove(store, this)
				return
			end
			SU.y_enemy_mixed_walk_melee_ranged(store, this, false, break_fn, break_fn, break_fn)
			coroutine.yield()
		end
	end
end

scripts.velociraptor_egg = {}

function scripts.velociraptor_egg.update(this, store)
	local s = this.render and this.render.sprites and this.render.sprites[1]

	if s then
		s.ts = store.tick_ts
		if s.animated then U.animation_start(this, this.idle_animation or "idle", nil, store.tick_ts, true) end
	end

	U.y_wait(store, this.hatch_time or 4)
	if s and s.animated and this.hatch_animation then
		U.y_animation_play(this, this.hatch_animation, nil, store.tick_ts, false)
	end

	local pi = this.path or 1
	local spi = this.subpath or 1
	local ni = this.node or P:get_start_node(pi)
	for i = 1, this.spawn_count or 1 do
		local spawned = branch_spawn_on_path(store, this.spawn_template or "enemy_velociraptor", nil,
			-(i - 1) * (this.node_gap or 1), pi, spi, ni)

		if spawned then spawned.pos = V.vclone(this.pos) end
	end

	queue_remove(store, this)
end

scripts.dragon_king_water_pool = {}

function scripts.dragon_king_water_pool.update(this, store)
	this.branch_water_zone = true
	this.render.sprites[1].ts = store.tick_ts
	local ts = store.tick_ts
	while store.tick_ts - ts < this.duration do coroutine.yield() end
	queue_remove(store, this)
end

local dragon_king_water_waves = {
	[3] = true,
	[4] = true,
	[8] = true,
	[9] = true,
	[13] = true,
	[15] = true,
	[16] = true
}

function dragon_king_set_body_visible(this, visible)
	for _, sid in ipairs(this.branch.body_sprite_ids or {}) do
		local s = this.render.sprites[sid]
		if s then s.hidden = not visible end
	end
end

function dragon_king_start(this, animation, store, loop, sprite_ids)
	pirate_start_animation(this, animation, nil, store.tick_ts, loop, sprite_ids, true)
end

function dragon_king_wait(store, this, duration)
	local ts = store.tick_ts

	while store.tick_ts - ts < duration do
		if this.health.dead then return false end
		coroutine.yield()
	end

	return true
end

function dragon_king_wait_animation(store, this, sid)
	while not U.animation_finished(this, sid or 1) do
		if this.health.dead then return false end
		coroutine.yield()
	end

	return true
end

function dragon_king_spawn_pool(store, source_id, template, pos, duration, radius)
	local pool = E:create_entity(template or "dragon_king_water_pool")

	pool.pos = V.vclone(pos)
	pool.duration = duration or pool.duration
	pool.radius = radius or pool.radius
	pool.source_id = source_id

	queue_insert(store, pool)

	return pool
end

scripts.dragon_king_water_splash = {}

function scripts.dragon_king_water_splash.update(this, store)
	this.render.sprites[1].ts = store.tick_ts
	U.y_wait(store, this.duration or 0.6)
	queue_remove(store, this)
end

scripts.dragon_king_water_bolt = {}

function scripts.dragon_king_water_bolt.update(this, store)
	local s = this.render.sprites[1]
	local to = this.to and V.vclone(this.to) or V.vclone(this.pos)
	local speed = this.speed or 520

	s.ts = store.tick_ts

	while V.dist(this.pos.x, this.pos.y, to.x, to.y) > speed * store.tick_length do
		local dx, dy = to.x - this.pos.x, to.y - this.pos.y
		local vx, vy = V.mul(speed, V.normalize(dx, dy))

		this.pos.x = this.pos.x + vx * store.tick_length
		this.pos.y = this.pos.y + vy * store.tick_length
		s.r = V.angleTo(dx, dy)

		coroutine.yield()
	end

	this.pos = V.vclone(to)

	if this.hit_sound then
		S:queue(this.hit_sound)
	end

	if this.hit_fx then
		branch_spawn_fx_at(store, this.hit_fx, to)
	end

	dragon_king_spawn_pool(store, this.source_id, this.pool, to, this.duration, this.radius)

	local impact_ts = store.tick_ts
	local spawned = {}

	while true do
		local pending = false

		for i, cfg in ipairs(this.extra_pools or {}) do
			if not spawned[i] then
				if store.tick_ts - impact_ts >= (cfg.delay or 0) then
					spawned[i] = true

					local offset = cfg.offset or cfg.offsets and cfg.offsets[math.random(1, #cfg.offsets)] or V.v(0, 0)
					local pos = V.v(to.x + (offset.x or 0), to.y + (offset.y or 0))

					dragon_king_spawn_pool(store, this.source_id, this.pool, pos, this.duration, cfg.radius or this.radius)
				else
					pending = true
				end
			end
		end

		if not pending then break end
		coroutine.yield()
	end

	queue_remove(store, this)
end

function dragon_king_target_position(cfg)
	if not cfg or not P.paths[cfg.path] then
		return nil
	end

	local node = branch_clamp_path_node(cfg.path, cfg.node or P:get_start_node(cfg.path))

	return V.vclone(P:node_pos(cfg.path, 1, node))
end

function dragon_king_spit_water(store, this)
	local b = this.branch
	local water = b.water
	local targets = water.target_nodes or {}

	if #targets < 1 then
		return false
	end

	b.water_target_index = (b.water_target_index or 0) % #targets + 1

	local target_pos = dragon_king_target_position(targets[b.water_target_index])

	if not target_pos then
		return false
	end

	dragon_king_start(this, water.animation or "attack", store, false, b.main_sprite_ids)

	local ts = store.tick_ts
	local sound_done = false
	local sound_delay = water.sound_delay or 0.3

	while store.tick_ts - ts < (water.cast_time or 0.4) do
		if this.health.dead then return false end

		if not sound_done and water.sound and store.tick_ts - ts >= sound_delay then
			sound_done = true
			S:queue(water.sound)
		end

		coroutine.yield()
	end

	if not sound_done and water.sound then
		S:queue(water.sound)
	end

	local bolt = E:create_entity(water.projectile or "dragon_king_water_bolt")
	local shoot_offset = water.shoot_offset or V.v(0, 0)

	bolt.pos = V.v(this.pos.x + shoot_offset.x, this.pos.y + shoot_offset.y)
	bolt.from = V.vclone(bolt.pos)
	bolt.to = target_pos
	bolt.source_id = this.id
	bolt.duration = water.duration
	bolt.radius = water.radius

	queue_insert(store, bolt)

	dragon_king_wait_animation(store, this, b.main_sprite_ids and b.main_sprite_ids[1] or 1)

	if not this.health.dead then
		dragon_king_start(this, "idle", store, true, b.main_sprite_ids)
	end

	return true
end

function dragon_king_move_forward(store, this)
	local b = this.branch
	local move = b.move

	if not move or not this.nav_path then
		return false
	end

	local pi, spi = this.nav_path.pi, this.nav_path.spi or 1
	local dir = this.nav_path.dir or branch_path_dir(pi)
	local end_node = P:get_end_node(pi)
	local limit = move.node_limit or end_node
	local next_node = branch_clamp_path_node(pi, this.nav_path.ni + (move.nodes or 25) * dir)

	if dir > 0 then
		next_node = math.min(next_node, limit, end_node)
	else
		next_node = math.max(next_node, limit, end_node)
	end

	if dir > 0 and next_node <= this.nav_path.ni or dir < 0 and next_node >= this.nav_path.ni then
		return false
	end

	dragon_king_set_body_visible(this, true)

	if move.sound_out then S:queue(move.sound_out) end
	dragon_king_start(this, move.animation_out or "out", store, false, b.main_sprite_ids)
	dragon_king_start(this, move.body_out or "outTail", store, false, b.body_sprite_ids)

	if not dragon_king_wait(store, this, move.action_time or 1.5) then
		return false
	end

	this.nav_path.ni = next_node
	this.pos = V.vclone(P:node_pos(pi, spi, this.nav_path.ni))

	if move.sound_loop then S:queue(move.sound_loop) end
	dragon_king_start(this, move.body_slide or "inSlide", store, true, b.body_sprite_ids)

	if not dragon_king_wait(store, this, move.delay_to_end or 1.5) then
		return false
	end

	if move.sound_in then S:queue(move.sound_in) end
	dragon_king_start(this, move.animation_in or "in", store, false, b.main_sprite_ids)
	dragon_king_start(this, move.body_in or "inHead", store, false, b.body_sprite_ids)
	dragon_king_wait_animation(store, this, b.main_sprite_ids and b.main_sprite_ids[1] or 1)

	if not this.health.dead then
		dragon_king_set_body_visible(this, false)
		dragon_king_start(this, "idle", store, true, b.main_sprite_ids)
	end

	return true
end

function dragon_king_enter_home(store, this)
	local b = this.branch
	local move = b.move or {}

	this.health.ignore_damage = true
	this.health_bar.hidden = true
	if this.ui then
		this.ui.can_click = false
		this.ui.can_select = false
	end

	if this.nav_path and P.paths[this.nav_path.pi] then
		local pi = this.nav_path.pi
		local spi = this.nav_path.spi or 1

		this.nav_path.ni = P:get_end_node(pi)
		this.pos = V.vclone(P:node_pos(pi, spi, this.nav_path.ni))
	end

	dragon_king_set_body_visible(this, true)
	if move.sound_out then S:queue(move.sound_out) end
	dragon_king_start(this, move.animation_out or "out", store, false, b.main_sprite_ids)
	dragon_king_start(this, move.body_out or "outTail", store, false, b.body_sprite_ids)
	queue_remove(store, this)

	store.lives = 0

	return true
end

scripts.dragon_king_boss = {}

function scripts.dragon_king_boss.update(this, store)
	local b = this.branch
	local water_ts = -1e+99
	local move_ts = store.tick_ts
	local active = false
	local original_flags = this.vis.flags
	local original_bans = this.vis.bans
	local original_can_click = this.ui and this.ui.can_click
	local original_can_select = this.ui and this.ui.can_select
	local original_ignore_damage = this.health.ignore_damage
	local original_immune_to = this.health.immune_to

	this.motion.forced_waypoint = nil
	this.health_bar.hidden = true
	this.health.ignore_damage = true
	this.health.immune_to = DAMAGE_ALL_TYPES
	this.health.hp = this.health.hp_max
	this.health.dead = false
	this.vis.flags = band(this.vis.flags, bnot(bor(F_ENEMY, F_BOSS)))
	this.vis.bans = bor(this.vis.bans, F_BLOCK, F_RANGED, F_AREA, F_MOD)
	if this.ui then
		this.ui.can_click = false
		this.ui.can_select = false
	end
	dragon_king_set_body_visible(this, false)
	dragon_king_start(this, "idle", store, true, b.main_sprite_ids)

	while true do
		local now = store.tick_ts
		local wave = store.wave_group_number or 0

		if this.enemy and #this.enemy.blockers > 0 then
			U.unblock_all(store, this)
		end

		if not active and this.health.dead then
			this.health.dead = false
			this.health.hp = this.health.hp_max
		end

		if this.health.dead then
			this.health_bar.hidden = true
			dragon_king_set_body_visible(this, true)
			dragon_king_start(this, "death", store, false, b.main_sprite_ids)
			dragon_king_start(this, "death", store, false, b.body_sprite_ids)
			branch_kill_all_enemies_for_victory(store)
			U.y_wait(store, b.death_delay or 3.7)
			queue_remove(store, this)
			return
		end

		if not active and wave >= 16 then
			active = true
			this.health.dead = false
			this.health.hp = this.health.hp_max
			this.health.ignore_damage = original_ignore_damage
			this.health.immune_to = original_immune_to
			this.health_bar.hidden = nil
			this.vis.flags = original_flags
			this.vis.bans = original_bans
			if this.ui then
				this.ui.can_click = original_can_click
				this.ui.can_select = original_can_select
			end
			move_ts = now - ((b.move and b.move.cooldown) or 35)
			S:queue("MusicBossFight_175")
		end

		if active and b.move and now - move_ts >= (b.move.cooldown or 35) then
			move_ts = now
			local moved = dragon_king_move_forward(store, this)

			if not moved and not this.health.dead then
				dragon_king_enter_home(store, this)
				return
			end
		elseif (active or dragon_king_water_waves[wave]) and b.water and now - water_ts >= (b.water.cooldown or 6) then
			water_ts = now
			dragon_king_spit_water(store, this)
		else
			coroutine.yield()
		end
	end
end

function stage175_spawn_dragon_king_boss(store)
	local spawn_pos = V.v(102, 330)
	local water_path = 6
	local pi, spi, ni = water_path, 3, 1

	-- In this port, level 175's Dragon King uses the middle water lane, not KR4's land-path rank.
	if P.paths[water_path] then
		local nodes = P:nearest_nodes(spawn_pos.x, spawn_pos.y, {water_path}, nil, true)

		if nodes and nodes[1] then
			pi, spi, ni = nodes[1][1], nodes[1][2], nodes[1][3]
		end
	else
		local nodes = P:nearest_nodes(spawn_pos.x, spawn_pos.y, nil, nil, true)

		if nodes and nodes[1] then
			pi, spi, ni = nodes[1][1], nodes[1][2], nodes[1][3]
		end
	end

	return branch_spawn_from_pos_to_path(store, "enemy_dragon_king_boss", spawn_pos, pi, spi, ni)
end

scripts.great_t_meteor = {}

function scripts.great_t_meteor.update(this, store)
	this.render.sprites[1].ts = store.tick_ts
	U.y_wait(store, this.delay)
	branch_damage_soldiers(store, store.entities[this.source_id], this.pos, this.radius, this.damage_min, this.damage_max, DAMAGE_PHYSICAL)
	kr4_insert_one_shot_fx(store, "fx_kr4_explosion_fragment", this.pos, 1)
	queue_remove(store, this)
end

scripts.branch_water_zone = {}

function scripts.branch_water_zone.update(this, store)
	this.branch_water_zone = true
	while true do coroutine.yield() end
end

scripts.branch_static_decal = {}

function scripts.branch_static_decal.update(this, store)
	for _, s in pairs(this.render and this.render.sprites or {}) do
		s.ts = store.tick_ts
	end

	local sprite = this.render and this.render.sprites and this.render.sprites[1]

	for sid, s in pairs(this.render and this.render.sprites or {}) do
		if s.animated and s.name and not s.hidden then
			U.animation_start(this, s.name, s.flip_x, store.tick_ts, true, sid)
		end
	end

	while true do
		if this.ui and this.ui.clicked then
			this.ui.clicked = nil

			local animation = this.click_animation

			if type(animation) == "table" and #animation > 0 then
				animation = animation[math.random(1, #animation)]
			end

			if animation then
				if this.animation_group then
					U.y_animation_play_group(this, animation, nil, store.tick_ts, 1, this.animation_group)
				else
					U.y_animation_play(this, animation, nil, store.tick_ts, 1)
				end

				if store.entities[this.id] and sprite and sprite.animated and sprite.name then
					if this.animation_group then
						U.animation_start_group(this, this.loop_animation or sprite.name, nil, store.tick_ts, true, this.animation_group)
					else
						U.animation_start(this, this.loop_animation or sprite.name, nil, store.tick_ts, true, 1)
					end
				end
			end

			if this.remove_on_click then
				queue_remove(store, this)
				return
			end
		end

		coroutine.yield()
	end
end

scripts.alleria_end = {}

function scripts.alleria_end.update(this, store)
	for _, s in pairs(this.render and this.render.sprites or {}) do
		s.ts = store.tick_ts
	end

	if this.leaves_fx then
		local fx = E:create_entity(this.leaves_fx)

		fx.pos = V.vclone(this.pos)
		for _, s in pairs(fx.render and fx.render.sprites or {}) do
			s.ts = store.tick_ts
		end
		queue_insert(store, fx)
	end

	if this.start_animation then
		U.y_animation_play(this, this.start_animation, nil, store.tick_ts, 1)
	end

	queue_remove(store, this)
end

scripts.mod_magnus_arcane_shield = {}

function scripts.mod_magnus_arcane_shield.insert(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.health or target.health.dead or target._magnus_arcane_shield_mod then
		return false
	end

	m.ts = store.tick_ts
	this._old_on_damage = target.health.on_damage
	this._blood_color = target.unit and target.unit.blood_color
	local lethal_bans = bor(F_INSTAKILL, F_EAT, F_DISINTEGRATED, F_POLYMORPH)
	this._vis_bans_added = target.vis and band(lethal_bans, bnot(target.vis.bans or 0)) or 0
	target._magnus_arcane_shield_mod = this
	target.health.on_damage = scripts.mod_magnus_arcane_shield.on_damage
	if target.vis then target.vis.bans = bor(target.vis.bans or 0, lethal_bans) end

	if target.unit then
		target.unit.blood_color = BLOOD_NONE
	end

	return true
end

function scripts.mod_magnus_arcane_shield.update(this, store, script)
	local m = this.modifier
	local target = store.entities[m.target_id]

	if not target or not target.pos then
		queue_remove(store, this)

		return
	end

	m.ts = store.tick_ts
	this.pos = target.pos

	if this.render then
		SU.set_mod_offset(store, this, m.target_id)
	end

	U.y_animation_play(this, this.in_animation or "in", nil, store.tick_ts)
	U.animation_start(this, this.loop_animation or "loop", nil, store.tick_ts, true)

	while true do
		target = store.entities[m.target_id]

		if not target or target.health and target.health.dead or store.tick_ts - m.ts >= m.duration then
			break
		end

		this.pos = target.pos

		if this.render then
			SU.set_mod_offset(store, this, m.target_id)
		end

		coroutine.yield()
	end

	U.y_animation_play(this, this.out_animation or "out", nil, store.tick_ts)
	queue_remove(store, this)
end

function scripts.mod_magnus_arcane_shield.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target and target._magnus_arcane_shield_mod == this then
		target._magnus_arcane_shield_mod = nil

		if target.health and target.health.on_damage == scripts.mod_magnus_arcane_shield.on_damage then
			target.health.on_damage = this._old_on_damage
		end

		if target.unit then
			target.unit.blood_color = this._blood_color
		end

		if target.vis and this._vis_bans_added then
			target.vis.bans = band(target.vis.bans or 0, bnot(this._vis_bans_added))
		end
	end

	return true
end

function scripts.mod_magnus_arcane_shield.on_damage(this, store, damage)
	return false
end

scripts.aura_magnus_poison = {}

function scripts.aura_magnus_poison.update(this, store, script)
	local a = this.aura
	local cycle_time = a.cycle_time or 0.33
	local last_hit_ts = store.tick_ts - cycle_time

	a.ts = store.tick_ts

	for sid, s in pairs(this.render and this.render.sprites or {}) do
		s.ts = store.tick_ts
		U.animation_start(this, s.name, s.flip_x, store.tick_ts, true, sid)
	end

	if this.intro_animation then
		U.animation_start(this, this.intro_animation, nil, store.tick_ts, false, 1)
	end

	if this.steam_intro_animation and this.render and this.render.sprites[3] then
		U.animation_start(this, this.steam_intro_animation, nil, store.tick_ts, false, 3)
	end

	if this.intro_time and this.intro_time > 0 then
		U.y_wait(store, this.intro_time)
	end

	if this.run_animation then
		U.animation_start(this, this.run_animation, nil, store.tick_ts, true, 1)
	end

	if this.steam_run_animation and this.render and this.render.sprites[3] then
		U.animation_start(this, this.steam_run_animation, nil, store.tick_ts, true, 3)
	end

	while store.tick_ts - a.ts < a.duration do
		if store.tick_ts - last_hit_ts >= cycle_time then
			last_hit_ts = store.tick_ts

			local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, a.radius, a.vis_flags or 0, a.vis_bans or 0, kr4_valid_enemy_soldier_target)

			for _, target in ipairs(targets or {}) do
				local mods = U.get_modifiers(store, target, {
					a.mod
				})

				if mods and #mods > 0 then
					mods[1].modifier.ts = store.tick_ts
				else
					local mod = E:create_entity(a.mod)

					mod.modifier.source_id = a.source_id or this.id
					mod.modifier.target_id = target.id
					mod.modifier.duration = a.mod_duration or mod.modifier.duration

					queue_insert(store, mod)
				end
			end
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.magnus = {}

function magnus_template_matches(name, exact, prefixes)
	if exact and table.contains(exact, name) then
		return true
	end

	for _, prefix in ipairs(prefixes or {}) do
		if string.find(name, prefix, 1, true) == 1 then
			return true
		end
	end

	return false
end

function magnus_start_idle(this, store)
	local cfg = this.magnus or {}

	U.animation_start_group(this, cfg.idle_animation or "idle", nil, store.tick_ts, true, cfg.animation_group or this.animation_group)
end

function magnus_play_cast(this, store, cfg, apply_fn)
	local group = cfg.animation_group or this.animation_group or this.magnus and this.magnus.animation_group

	if cfg.animation then
		U.y_animation_play_group(this, cfg.animation, nil, store.tick_ts, 1, group)
	end

	local result = not apply_fn or apply_fn()

	if cfg.loop_animation then
		U.animation_start_group(this, cfg.loop_animation, nil, store.tick_ts, true, group)
		U.y_wait(store, cfg.loop_time or 0.25)
	end

	if cfg.end_animation then
		U.y_animation_play_group(this, cfg.end_animation, nil, store.tick_ts, 1, group)
	end

	magnus_start_idle(this, store)

	return result
end

function magnus_cast_shield(this, store)
	local cfg = this.magnus and this.magnus.shield

	if not cfg then
		return false
	end

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, cfg.range or 9999, 0, 0, function(e)
		return not magnus_template_matches(e.template_name, cfg.excluded_templates, cfg.excluded_prefixes) and not U.has_modifiers(store, e, cfg.mod)
	end)

	if not targets or #targets < (cfg.min_targets or 1) then
		return false
	end

	targets = table.random_order(targets)

	local count = math.min(#targets, math.random(cfg.min_targets or 1, cfg.max_targets or cfg.min_targets or 1))
	local picked = {}

	for i = 1, count do
		table.insert(picked, targets[i])
	end

	return magnus_play_cast(this, store, cfg, function()
		for _, target_ref in ipairs(picked) do
			local target = store.entities[target_ref.id]

			if target and target.health and not target.health.dead and not U.has_modifiers(store, target, cfg.mod) then
				local mod = E:create_entity(cfg.mod)

				mod.modifier.source_id = this.id
				mod.modifier.target_id = target.id
				mod.modifier.duration = cfg.duration or mod.modifier.duration

				queue_insert(store, mod)
			end
		end

		return true
	end)
end

function magnus_valid_tower_target(store, e, cfg, origin)
	if not (e and e.tower and e.ui and e.pos and not e.tower_holder) then
		return false
	end

	if e.tower.can_be_mod == false or e.tower.type == "build_animation" or e.tower.blocked then
		return false
	end

	if cfg.radius and not U.is_inside_ellipse(e.pos, origin, cfg.radius) then
		return false
	end

	if cfg.excluded_kinds and table.contains(cfg.excluded_kinds, e.tower.kind) then
		return false
	end

	if cfg.excluded_types and table.contains(cfg.excluded_types, e.tower.type) then
		return false
	end

	if magnus_template_matches(e.template_name, cfg.excluded_templates, cfg.excluded_prefixes) then
		return false
	end

	if U.has_modifiers(store, e, cfg.mod) then
		return false
	end

	return true
end

function magnus_cast_tower_block(this, store)
	local cfg = this.magnus and this.magnus.tower_block

	if not cfg then
		return false
	end

	local targets = table.filter(store.entities, function(_, e)
		return magnus_valid_tower_target(store, e, cfg, this.pos)
	end)

	if not targets or #targets == 0 then
		return false
	end

	targets = table.random_order(targets)

	local count = math.min(cfg.max_targets or 3, #targets)
	local picked = {}

	for i = 1, count do
		table.insert(picked, targets[i])
	end

	return magnus_play_cast(this, store, cfg, function()
		for _, target_ref in ipairs(picked) do
			local target = store.entities[target_ref.id]

			if magnus_valid_tower_target(store, target, cfg, this.pos) then
				local mod = E:create_entity(cfg.mod)

				mod.modifier.source_id = this.id
				mod.modifier.target_id = target.id
				mod.modifier.duration = cfg.duration or mod.modifier.duration

				queue_insert(store, mod)
			end
		end

		return true
	end)
end

function magnus_poison_candidate(e)
	return e and e.soldier and e.vis and e.health and not e.health.dead and band(e.vis.bans, F_POISON) == 0 and band(e.vis.flags, F_FLYING) == 0 and kr4_valid_enemy_soldier_target(e)
end

scripts.zeta_cerberus_holder = {}

function scripts.zeta_cerberus_holder.update(this, store)
	local sprite = this.render and this.render.sprites and this.render.sprites[1]

	if sprite then
		sprite.ts = store.tick_ts
		U.animation_start(this, "sleep", false, store.tick_ts, true)
	end

	while (store.wave_group_number or 0) < (this.wave_start or 15) do
		coroutine.yield()
	end

	local cerberus = branch_spawn_from_pos_to_path(
		store,
		this.spawn_template or "enemy_cerberus",
		V.vclone(this.pos),
		this.spawn_path or 4,
		this.spawn_subpath or 1,
		this.spawn_node or 36
	)

	if cerberus then
		cerberus.ignore_seen_tracker = true
		queue_remove(store, this)
	end
end

scripts.zeta_stage_event = {}

local function zeta_is_demon_enemy(e)
	if not e or not e.enemy or not e.health or e.health.dead then
		return false
	end

	local name = e.template_name or ""

	if name == "enemy_zeta_demon_fissure" or name == "enemy_zeta_demon_ray" then
		return false
	end

	local source = e.zeta_source_metadata

	if source and source.is_demon ~= nil then
		return source.is_demon
	end

	-- Non-Zeta templates do not carry a source row; keep their established
	-- compatibility fallback without using it for newly ported units.
	return string.find(name, "demon", 1, true) ~= nil
		or string.find(name, "cerberus", 1, true) ~= nil
		or string.find(name, "moloch", 1, true) ~= nil
		or string.find(name, "veznan", 1, true) ~= nil
		or string.find(name, "oloch", 1, true) ~= nil
end

local function zeta_is_demon_soldier(e)
	if not e or not e.soldier or not e.health or e.health.dead then
		return false
	end

	local name = e.template_name or ""

	return string.find(name, "demon", 1, true) ~= nil
		or string.find(name, "pit_lord", 1, true) ~= nil
		or string.find(name, "oloch", 1, true) ~= nil
		or string.find(name, "murglun", 1, true) ~= nil
end

local function zeta_is_fissure_burn_immune(e)
	local name = e and e.template_name or ""

	return zeta_is_demon_soldier(e)
		or string.find(name, "trident", 1, true) ~= nil
		or string.find(name, "goonie", 1, true) ~= nil
end

local function zeta_live_fissures(store, origin, radius)
	local result = {}

	for _, e in pairs(store.entities) do
		if e.template_name == "enemy_zeta_demon_fissure" and e.health and not e.health.dead and
				(not origin or V.dist(origin.x, origin.y, e.pos.x, e.pos.y) <= (radius or 9999)) then
			table.insert(result, e)
		end
	end

	return result
end


scripts.zeta_demon_fissure = {}

function scripts.zeta_demon_fissure.update(this, store)
	local cfg = this.zeta_fissure
	local regen_ts = store.tick_ts
	local support_ts = store.tick_ts
	local burn_ts = store.tick_ts
	local boss_heal_ts = store.tick_ts
	local trident_heal_ts = store.tick_ts

	while true do
		if this.health.dead then
			local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, cfg.death_radius, 0, F_FLYING,
				kr4_valid_enemy_soldier_target) or {}

			for _, target in ipairs(targets) do
				branch_damage(store, this, target, cfg.death_damage, DAMAGE_MAGICAL)
			end

			branch_enemy_death(store, this)
			return
		end

		if store.tick_ts - regen_ts >= cfg.regen_cooldown then
			regen_ts = store.tick_ts
			this.health.hp = math.min(this.health.hp_max, this.health.hp + cfg.regen)
		end

		if store.tick_ts - support_ts >= cfg.support_cooldown then
			support_ts = store.tick_ts
			local allies = U.find_enemies_in_range(store.entities, this.pos, 0, cfg.support_radius, 0, 0,
				function(e) return e.id ~= this.id and zeta_is_demon_enemy(e) end) or {}

			for _, ally in ipairs(allies) do
				local heal = cfg.flat_heal

				if band(ally.vis.flags or 0, F_BOSS) == 0 then
					heal = heal + math.floor(ally.health.hp_max * cfg.heal_factor + 0.5)
				end

				ally.health.hp = math.min(ally.health.hp_max, ally.health.hp + heal)
			end

			for _, ally in pairs(store.entities) do
				if zeta_is_demon_soldier(ally) and V.dist(this.pos.x, this.pos.y, ally.pos.x, ally.pos.y) <= cfg.support_radius then
					local heal = cfg.flat_heal + math.floor(ally.health.hp_max * cfg.heal_factor + 0.5)

					ally.health.hp = math.min(ally.health.hp_max, ally.health.hp + heal)
				end
			end
		end

		if store.tick_ts - boss_heal_ts >= (cfg.boss_heal_cooldown or 2) then
			boss_heal_ts = store.tick_ts

			for _, ally in ipairs(U.find_enemies_in_range(store.entities, this.pos, 0, cfg.support_radius, 0, 0,
					function(e) return e.id ~= this.id and zeta_is_demon_enemy(e) and band(e.vis.flags or 0, F_BOSS) ~= 0 end) or {}) do
				ally.health.hp = math.min(ally.health.hp_max,
					ally.health.hp + math.floor(ally.health.hp_max * (cfg.boss_heal_factor or 0.008334) + 0.5))
			end
		end

		if store.tick_ts - trident_heal_ts >= (cfg.trident_heal_cooldown or 0.5) then
			trident_heal_ts = store.tick_ts

			for _, ally in pairs(store.entities) do
				local name = ally.template_name or ""

				if ally.soldier and ally.health and not ally.health.dead and
						string.find(name, "trident", 1, true) and
						V.dist(this.pos.x, this.pos.y, ally.pos.x, ally.pos.y) <= cfg.support_radius then
					ally.health.hp = math.min(ally.health.hp_max, ally.health.hp + (cfg.trident_heal or 5))
				end
			end
		end

		if store.tick_ts - burn_ts >= cfg.burn_cooldown then
			burn_ts = store.tick_ts
			local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, cfg.support_radius, 0, F_FLYING,
				kr4_valid_enemy_soldier_target) or {}

			for _, target in ipairs(targets) do
				if not zeta_is_fissure_burn_immune(target) then
					branch_damage(store, this, target, cfg.burn_damage, DAMAGE_TRUE)
				end
			end
		end

		coroutine.yield()
	end
end


scripts.zeta_demon_ray = {}

scripts.zeta_demon_spawner = {}

function scripts.zeta_demon_spawner.update(this, store)
	U.animation_start(this, "idle", nil, store.tick_ts, true)
	U.y_wait(store, this.zeta_spawner.lifetime)

	this.health.hp = 0
	this.health.dead = true
	this.health.last_damage_types = 0
	branch_enemy_death(store, this)
end

function scripts.zeta_demon_ray.update(this, store)
	local cfg = this.zeta_ray
	local base_bans = this.vis.bans or 0
	local regen_ts = store.tick_ts
	local initial_damage_ts = store.tick_ts + cfg.initial_damage_delay
	local initial_damage_done = false
	local was_below_trigger = false
	local fire_ts

	while true do
		if this.health.dead then
			branch_enemy_death(store, this)
			return
		end

		local protected = #zeta_live_fissures(store, this.pos, cfg.protection_radius) > 0
		this.vis.bans = protected and bor(base_bans, F_ALL) or base_bans

		if not initial_damage_done and store.tick_ts >= initial_damage_ts then
			initial_damage_done = true
			this.health.hp = math.max(1, this.health.hp - cfg.initial_damage)
			regen_ts = store.tick_ts
		end

		local below_trigger = this.health.hp <= this.health.hp_max * cfg.trigger_hp_factor

		if below_trigger and not was_below_trigger and not fire_ts then
			fire_ts = store.tick_ts + (cfg.arm_delay or 0)
		end

		was_below_trigger = below_trigger

		if fire_ts and store.tick_ts >= fire_ts then
			fire_ts = nil
			local fissures = zeta_live_fissures(store, nil, nil)
			local available = {}

			for _, fissure in ipairs(fissures) do
				if not fissure._zeta_ray_claimed then
					table.insert(available, fissure)
				end
			end

			table.sort(available, function(a, b)
				return V.dist(this.pos.x, this.pos.y, a.pos.x, a.pos.y) < V.dist(this.pos.x, this.pos.y, b.pos.x, b.pos.y)
			end)

			for i = 1, math.min(cfg.max_targets, #available) do
				available[i]._zeta_ray_claimed = true
				branch_damage(store, this, available[i], cfg.fissure_damage, DAMAGE_TRUE)
			end
		end

		if initial_damage_done and store.tick_ts - regen_ts >= cfg.regen_cooldown then
			regen_ts = store.tick_ts
			this.health.hp = math.min(this.health.hp_max, this.health.hp + cfg.regen)
		end

		coroutine.yield()
	end
end


scripts.zeta_pit_lord_spawner = {}

function scripts.zeta_pit_lord_spawner.update(this, store)
	local soldier = E:create_entity("soldier_zeta_pit_lord_ally")

	soldier.pos = V.vclone(this.pos)
	soldier.nav_rally.center = V.vclone(this.pos)
	soldier.nav_rally.pos = V.v(this.pos.x - 45, this.pos.y)
	soldier.reinforcement.ts = store.tick_ts
	queue_insert(store, soldier)
	queue_remove(store, this)
end


scripts.zeta_oloch_altar = {}

function scripts.zeta_oloch_altar.update(this, store)
	U.animation_start(this, "idle", false, store.tick_ts, true)
	local fired = {}

	while not this.health.dead and (store.wave_group_number or 0) < (this.activate_wave or 16) do
		local wave = store.wave_group_number or 0

		for _, eruption_wave in ipairs(this.eruption_waves or {}) do
			if wave >= eruption_wave and not fired[eruption_wave] then
				fired[eruption_wave] = true
				U.y_animation_play(this, "magmaEruption", nil, store.tick_ts, 1)

				if not this.health.dead then
					U.animation_start(this, "idle", false, store.tick_ts, true)
				end
			end
		end

		coroutine.yield()
	end

	if not this.health.dead then
		branch_damage_soldiers(store, this, this.pos, this.death_radius or 60,
			this.death_damage or 140, this.death_damage or 140, DAMAGE_MAGICAL)
		this.health.hp = 0
		this.health.dead = true
	end

	branch_enemy_death(store, this)
end


scripts.zeta_eva2_magnet = {}

function scripts.zeta_eva2_magnet.update(this, store)
	U.animation_start(this, "idle", false, store.tick_ts, true)
	this.ui.clicked = nil

	while not this.ui.clicked do
		coroutine.yield()
	end

	this.ui.can_click = false
	local triggered = E:create_entity(this.triggered_template or "zeta_eva2_magnet_triggered")

	triggered.pos = V.vclone(this.pos)
	queue_insert(store, triggered)
	queue_remove(store, this)
end


scripts.zeta_eva2_magnet_triggered = {}

function scripts.zeta_eva2_magnet_triggered.update(this, store)
	U.animation_start(this, "shoot", false, store.tick_ts, true)
	local end_ts = store.tick_ts + (this.duration or 6)
	local next_ts = store.tick_ts

	while store.tick_ts < end_ts do
		if store.tick_ts >= next_ts then
			next_ts = next_ts + (this.attack_interval or 0.2)
			local targets = U.find_enemies_in_range(store.entities, this.pos, 20, this.attack_radius or 1500, 0, 0,
				function(e)
					return e.template_name ~= "enemy_toxic_blob" and
						e.template_name ~= "enemy_warhammer_guard" and
						e.template_name ~= "enemy_smokebeard_engineer"
				end) or {}

			if #targets > 0 then
				local target = targets[math.random(1, #targets)]

				branch_damage(store, this, target, this.damage or 25, DAMAGE_TRUE)
				signal.emit("got-gold", V.vclone(target.pos), this.gold_per_hit or 1)
			end
		end

		coroutine.yield()
	end

	signal.emit("got-gold", V.vclone(this.pos), this.death_gold or 5)
	queue_remove(store, this)
end


scripts.zeta_eva3_statue = {}

function scripts.zeta_eva3_statue.update(this, store)
	U.animation_start(this, "idle", false, store.tick_ts, true)

	if not this.next_template then
		while true do
			coroutine.yield()
		end
	end

	this.ui.clicked = nil

	while not this.ui.clicked do
		coroutine.yield()
	end

	this.ui.can_click = false
	U.y_animation_play(this, "death", nil, store.tick_ts, 1)

	if this.reward and this.reward > 0 then
		signal.emit("got-gold", V.vclone(this.pos), this.reward)
	end

	local next_statue = E:create_entity(this.next_template)

	next_statue.pos = V.vclone(this.pos)
	queue_insert(store, next_statue)
	queue_remove(store, this)
end


scripts.zeta_wilbur_altar = {}

function scripts.zeta_wilbur_altar.update(this, store)
	U.animation_start(this, "idle", false, store.tick_ts, true)

	while (store.wave_group_number or 0) < (this.altar_wave or 10) do
		coroutine.yield()
	end

	branch_damage_soldiers(store, this, this.pos, this.death_radius or 45,
		this.death_damage or 80, this.death_damage or 80, DAMAGE_MAGICAL)
	this.health.hp = 0
	this.health.dead = true
	branch_enemy_death(store, this)
end


scripts.zeta_gold_reward_spawner = {}

function scripts.zeta_gold_reward_spawner.update(this, store)
	while (store.wave_group_number or 0) < (this.wave or 1) do
		coroutine.yield()
	end

	local pile = E:create_entity("zeta_gold_coin_pile")

	pile.pos = V.vclone(this.pos)
	pile.reward = this.reward or pile.reward
	queue_insert(store, pile)
	queue_remove(store, this)
end


scripts.zeta_gold_coin_pile = {}

function scripts.zeta_gold_coin_pile.update(this, store)
	U.animation_start(this, "idle", nil, store.tick_ts, true)
	this.ui.clicked = nil

	while not this.ui.clicked do
		coroutine.yield()
	end

	this.ui.can_click = false
	S:queue("coins_sound")
	signal.emit("got-gold", V.vclone(this.pos), this.reward or 150)
	U.y_animation_play(this, "death", nil, store.tick_ts, 1)
	queue_remove(store, this)
end


scripts.zeta_demon_heroic_booster = {}

scripts.zeta_fury_modifier = {}

function scripts.zeta_fury_modifier.insert(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if not target or not target.health or target.health.dead or not target.unit then
		return false
	end

	if this.received_damage_factor then
		target.health.damage_factor = (target.health.damage_factor or 1) * this.received_damage_factor
	end

	if this.inflicted_damage_factor then
		target.unit.damage_factor = (target.unit.damage_factor or 1) * this.inflicted_damage_factor
	end

	if this.speed_factor and target.motion then
		target.motion.max_speed = target.motion.max_speed * this.speed_factor
	end

	return true
end

function scripts.zeta_fury_modifier.remove(this, store, script)
	local target = store.entities[this.modifier.target_id]

	if target and target.health and target.unit then
		if this.received_damage_factor then
			target.health.damage_factor = (target.health.damage_factor or 1) / this.received_damage_factor
		end

		if this.inflicted_damage_factor then
			target.unit.damage_factor = (target.unit.damage_factor or 1) / this.inflicted_damage_factor
		end

		if this.speed_factor and target.motion then
			target.motion.max_speed = target.motion.max_speed / this.speed_factor
		end
	end

	return true
end

function scripts.zeta_demon_heroic_booster.update(this, store)
	while true do
		local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.radius, 0, 0,
			function(e) return e.health and not e.health.dead and e.id ~= this.id end) or {}

		for _, target in ipairs(targets) do
			local mod = E:create_entity("mod_zeta_demon_heroic_enrage")
			mod.modifier.source_id = this.id
			mod.modifier.target_id = target.id
			queue_insert(store, mod)
		end

		U.y_wait(store, this.cycle_time)
	end
end


scripts.zeta_eva_support_controller = {}

function scripts.zeta_eva_support_controller.update(this, store)
	while true do
		for _, e in pairs(store.entities) do
			if (e.template_name == "enemy_mechadwarf_eva" or e.template_name == "enemy_mechadwarf_eva1") and
					e.health and not e.health.dead and e.health.hp < e.health.hp_max * 0.5 then
				e.health.hp = math.min(e.health.hp_max, e.health.hp + this.heal_per_tick)
			end
		end

		U.y_wait(store, 1)
	end
end


local zeta_eva1_iron_health_factors = {
	[0] = 0.1,
	[1] = 0.1,
	[2] = 0.25,
	[3] = 0.4,
	[4] = 0.56,
	[5] = 0.72,
	[6] = 0.9
}

local zeta_eva1_iron_bosses = {
	enemy_mechadwarf_boss = true,
	enemy_mechadwarf_eva_boss = true,
	enemy_smokebeard_engineer_boss = true
}

local zeta_eva1_iron_speed_factors = {
	enemy_bruiser_pillar = 0.48,
	enemy_chomp_bot_pillar = 0.48,
	enemy_clockwork_spider_pillar = 0.64,
	enemy_cyclopter_pilot_pillar = 0.48,
	enemy_stonebeard_geomancer_pillar = 0.48,
	enemy_tinbeard_gunman_pillar = 0.48,
	enemy_tinbeard_gunman_lightning_pillar = 0.48,
	enemy_warhammer_guard_pillar = 0.48,
	enemy_mechadwarf_boss = 0.3,
	enemy_mechadwarf_eva_boss = 0.3,
	enemy_smokebeard_engineer_boss = 0.3
}

local function zeta_set_health_factor(entity, base_key, factor_key, factor)
	if not entity.health or entity.health.dead then
		return
	end

	entity[base_key] = entity[base_key] or entity.health.hp_max

	if entity[factor_key] == factor then
		return
	end

	local old_max = math.max(1, entity.health.hp_max or entity[base_key])
	local hp_ratio = math.max(0, math.min(1, (entity.health.hp or old_max) / old_max))
	local new_max = math.max(1, math.floor(entity[base_key] * factor + 0.5))

	entity.health.hp_max = new_max
	entity.health.hp = math.max(1, math.min(new_max, math.floor(new_max * hp_ratio + 0.5)))
	entity[factor_key] = factor
end

local function zeta_is_eva1_iron_enemy(entity)
	return entity.enemy and zeta_eva1_iron_speed_factors[entity.template_name] ~= nil
end

local function zeta_eva1_iron_apply_tower_damage(entity)
	if not entity.tower or entity.tower_holder or entity._zeta_eva1_iron_damage or
			string.find(entity.template_name or "", "balloon", 1, true) then
		return
	end

	entity.tower.damage_factor = (entity.tower.damage_factor or 1) * 3
	entity._zeta_eva1_iron_damage = true
end

local function zeta_eva1_iron_apply_special_damage(entity)
	if not entity.unit or entity._zeta_eva1_iron_unit_damage then
		return
	end

	local name = entity.template_name or ""

	if string.find(name, "zapper", 1, true) or string.find(name, "shaolin", 1, true) then
		entity.unit.damage_factor = (entity.unit.damage_factor or 1) * 3
		entity._zeta_eva1_iron_unit_damage = true
	end
end

scripts.zeta_eva1_iron_controller = {}

function scripts.zeta_eva1_iron_controller.update(this, store)
	while true do
		local wave = math.max(0, math.min(6, store.wave_group_number or 0))
		local health_factor = zeta_eva1_iron_health_factors[wave] or 0.9

		for _, entity in pairs(store.entities) do
			if zeta_is_eva1_iron_enemy(entity) then
				if entity.motion and not entity._zeta_eva1_iron_speed then
					entity.motion.max_speed = entity.motion.max_speed * zeta_eva1_iron_speed_factors[entity.template_name]
					entity._zeta_eva1_iron_speed = true
				end

				if not zeta_eva1_iron_bosses[entity.template_name] then
					zeta_set_health_factor(entity, "_zeta_eva1_iron_base_hp", "_zeta_eva1_iron_hp_factor",
						health_factor)
				end
			end

			zeta_eva1_iron_apply_tower_damage(entity)
			zeta_eva1_iron_apply_special_damage(entity)
		end

		U.y_wait(store, this.scan_interval or 0.15)
	end
end


local zeta_eva1_heroic_special_targets = {
	enemy_tinbeard_gunman_lightning = true,
	enemy_stonebeard_geomancer = true,
	enemy_test_geomancer = true
}

local zeta_eva1_heroic_targets = {
	enemy_mechadwarf_boss = true,
	enemy_clockwork_spider = true,
	enemy_clockwork_spider_fast = true,
	enemy_bruiser_legion = true,
	enemy_bruiser_legion_fast = true,
	enemy_mechadwarf = true,
	enemy_mechadwarf_fast = true,
	enemy_mechadwarf_eva = true,
	enemy_mechadwarf_eva1 = true,
	enemy_chomp_bot = true,
	enemy_chomp_bot_fast = true,
	enemy_test_bot = true,
	enemy_test_bot_fast = true,
	enemy_cyclopter_pilot = true,
	enemy_cyclopter_pilot_fast = true,
	enemy_cyclopter_engineer = true,
	enemy_warhammer_guard = true,
	enemy_warhammer_guard_fast = true,
	enemy_stonebeard_geomancer_fast = true,
	enemy_test_geomancer_fast = true,
	enemy_sulfur_alchemist = true,
	enemy_sulfur_alchemist_fast = true,
	enemy_boron_alchemist = true,
	enemy_boron_alchemist_fast = true,
	enemy_smokebeard_engineer = true,
	enemy_smokebeard_engineer_fast = true,
	enemy_royal_engineer = true,
	enemy_royal_engineer_fast = true,
	enemy_quarry_worker = true,
	enemy_quarry_worker_fast = true,
	enemy_tinbeard_gunman = true
}

local function zeta_eva1_possess(store, controller, target, limited_lifetime)
	local mod = E:create_entity("mod_possession")

	mod.modifier.source_id = controller.id
	mod.modifier.target_id = target.id
	mod.modifier.level = 1
	mod.possession_duration = {[1] = controller.possession_duration or 1500}
	target._zeta_eva1_heroic_possessed = true

	if limited_lifetime then
		target._zeta_eva1_heroic_death_ts = store.tick_ts + (controller.special_lifetime or 5)
	end

	queue_insert(store, mod)
end

scripts.zeta_eva1_heroic_controller = {}

function scripts.zeta_eva1_heroic_controller.update(this, store)
	while true do
		for _, entity in pairs(store.entities) do
			if entity.health and not entity.health.dead then
				local name = entity.template_name or ""
				local special = zeta_eva1_heroic_special_targets[name]

				if entity.enemy and entity.nav_path and not entity._zeta_eva1_heroic_possessed and
						(special or zeta_eva1_heroic_targets[name]) then
					if not special or math.random() < (this.possession_chance or 0.375) then
						zeta_eva1_possess(store, this, entity, special)
					else
						-- The source aura rolls only once for these three special enemies.
						entity._zeta_eva1_heroic_possessed = true
					end
				elseif entity._zeta_eva1_heroic_death_ts and store.tick_ts >= entity._zeta_eva1_heroic_death_ts then
					entity._zeta_eva1_heroic_death_ts = nil
					branch_damage(store, this, entity, (entity.health.hp or 0) + (entity.health.hp_max or 0),
						bor(DAMAGE_TRUE, DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS, DAMAGE_NO_DODGE))
				end
			end
		end

		U.y_wait(store, this.scan_interval or 0.15)
	end
end


local zeta_eva2_enemy_buff_weights = {
	[1] = {0.2, 0.2, 0.18, 0.18, 0.12, 0.12},
	[2] = {0.15, 0.15, 0.15, 0.15, 0.2, 0.2},
	[3] = {0.18, 0.18, 0.18, 0.18, 0.28}
}

local zeta_eva2_magnet_positions = {
	{80, 460}, {190, 190}, {300, 570}, {390, 400}, {490, 290},
	{600, 540}, {710, 360}, {820, 190}, {925, 500}, {1040, 300}
}

local function zeta_weighted_roll(weights)
	local roll = math.random()
	local total = 0

	for i, weight in ipairs(weights or {}) do
		total = total + weight

		if roll <= total then
			return i
		end
	end

	return #(weights or {1})
end

local function zeta_eva2_scale_health(entity, marker, factor)
	if not entity.health or entity[marker] then
		return
	end

	entity.health.hp_max = math.max(1, math.floor(entity.health.hp_max * factor + 0.5))
	entity.health.hp = math.max(1, math.floor((entity.health.hp or entity.health.hp_max) * factor + 0.5))
	entity[marker] = true
end

local function zeta_eva2_scale_unit_damage(entity, marker, factor)
	if entity.unit and not entity[marker] then
		entity.unit.damage_factor = (entity.unit.damage_factor or 1) * factor
		entity[marker] = true
	end
end

local function zeta_eva2_scale_tower_range(entity, marker, factor)
	if entity.tower and not entity.tower_holder and entity.attacks and not entity[marker] then
		entity.attacks.range = (entity.attacks.range or 0) * factor
		entity[marker] = true
	end
end

local function zeta_eva2_scale_tower_damage(entity, marker, factor)
	if entity.tower and not entity.tower_holder and not entity[marker] then
		entity.tower.damage_factor = (entity.tower.damage_factor or 1) * factor
		entity[marker] = true
	end
end

local function zeta_eva2_apply_enemy_buff(entity, phase, choice)
	if not entity.enemy or not entity.health or entity.health.dead then
		return
	end

	local marker = string.format("_zeta_eva2_enemy_%d_%d", phase, choice)

	if entity[marker] then
		return
	end

	entity[marker] = true

	local health_factors = {{1.5}, {1.6}, {1.8}}
	local damage_factors = {{2}, {2.2}, {2.6}}
	local speed_factors = {{1.4}, {1.48}, {1.64}}
	local heal_values = {{10}, {12}, {16}}

	if choice == 1 then
		zeta_eva2_scale_health(entity, marker .. "_health", health_factors[phase][1])
	elseif choice == 2 then
		zeta_eva2_scale_unit_damage(entity, marker .. "_damage", damage_factors[phase][1])
	elseif choice == 3 and entity.motion then
		entity.motion.max_speed = entity.motion.max_speed * speed_factors[phase][1]
	elseif choice == 4 then
		entity._zeta_eva2_regen = (entity._zeta_eva2_regen or 0) + heal_values[phase][1]
	elseif phase == 1 and choice == 5 and entity.template_name == "enemy_warhammer_guard" then
		entity.health.armor = math.min(1, (entity.health.armor or 0) + 0.5)
		zeta_eva2_scale_unit_damage(entity, marker .. "_special", 1.5)
	elseif phase == 1 and choice == 6 and entity.template_name == "enemy_chomp_bot" then
		zeta_eva2_scale_health(entity, marker .. "_special_health", 1.5)
		zeta_eva2_scale_unit_damage(entity, marker .. "_special_damage", 1.5)
	elseif phase == 2 and choice == 5 and string.find(entity.template_name or "", "smokebeard_engineer", 1, true) then
		zeta_eva2_scale_health(entity, marker .. "_special_health", 1.5)
		zeta_eva2_scale_unit_damage(entity, marker .. "_special_damage", 1.4)
	elseif phase == 2 and choice == 6 and entity.template_name == "enemy_toxic_blob" then
		zeta_eva2_scale_health(entity, marker .. "_special_health", 2)
		zeta_eva2_scale_unit_damage(entity, marker .. "_special_damage", 1.5)
	elseif phase == 3 and choice == 5 and string.find(entity.template_name or "", "mechadwarf", 1, true) then
		zeta_eva2_scale_health(entity, marker .. "_special_health", 2.5)
		zeta_eva2_scale_unit_damage(entity, marker .. "_special_damage", 2)
	end
end

local function zeta_eva2_spawn_mecha(store)
	local mecha = E:create_entity("soldier_mecha")
	local pos = store.main_hero and store.main_hero.pos or V.v(512, 384)

	mecha.pos = V.vclone(pos)
	mecha.nav_rally.pos = V.vclone(pos)
	mecha.nav_rally.new = true
	mecha.powers.missile.level = 2
	mecha.powers.oil.level = 3
	queue_insert(store, mecha)
end

local function zeta_eva2_apply_player_choice(controller, store, choice)
	controller.player_choices = controller.player_choices or {}
	controller.player_choices[choice] = (controller.player_choices[choice] or 0) + 1

	if choice == 6 then
		zeta_eva2_spawn_mecha(store)
	elseif choice == 9 then
		for _, pos in ipairs(zeta_eva2_magnet_positions) do
			local magnet = E:create_entity("zeta_eva2_magnet")

			magnet.pos = V.v(pos[1], pos[2])
			queue_insert(store, magnet)
		end
	elseif choice == 10 then
		store.lives = (store.lives or 0) + 2
	end
end

local function zeta_eva2_update_player_choices(controller, store, entity)
	local choices = controller.player_choices or {}

	for rank = 1, choices[1] or 0 do
		if entity.unit and not entity.enemy and not entity._original_enemy then
			zeta_eva2_scale_health(entity, "_zeta_eva2_player_hp_" .. rank, 1.5)
			zeta_eva2_scale_unit_damage(entity, "_zeta_eva2_player_damage_" .. rank, 1.25)
		end
	end

	for rank = 1, choices[2] or 0 do
		zeta_eva2_scale_tower_range(entity, "_zeta_eva2_player_range_" .. rank, 1.8)
	end

	for rank = 1, choices[3] or 0 do
		if entity.unit and not entity.enemy and not entity._original_enemy then
			local armor_marker = "_zeta_eva2_player_armor_" .. rank

			if entity.health and not entity[armor_marker] then
				entity.health.armor = math.min(1, (entity.health.armor or 0) + 0.4)
				entity[armor_marker] = true
			end

			zeta_eva2_scale_unit_damage(entity, "_zeta_eva2_player_damage_armor_" .. rank, 1.6)
		end
	end

	for rank = 1, choices[4] or 0 do
		zeta_eva2_scale_tower_damage(entity, "_zeta_eva2_player_tower_damage_" .. rank, 1.111112)
	end

	if choices[5] and entity.soldier and string.find(entity.template_name or "", "soldier_kr4_reinforcement", 1, true) and
			not string.find(entity.template_name or "", "pit_lord", 1, true) and not entity._zeta_eva2_pit_lord_upgrade then
		entity._zeta_eva2_pit_lord_upgrade = true
		local pit_lord = E:create_entity("soldier_kr4_reinforcement_pit_lord")

		pit_lord.pos = V.vclone(entity.pos)
		pit_lord.nav_rally.pos = entity.nav_rally and V.vclone(entity.nav_rally.pos) or V.vclone(entity.pos)
		pit_lord.nav_rally.new = true
		queue_insert(store, pit_lord)
		queue_remove(store, entity)
	end
end

local function zeta_eva2_random_enemy(store, filter)
	local targets = {}

	for _, entity in pairs(store.entities) do
		if entity.enemy and entity.health and not entity.health.dead and (not filter or filter(entity)) then
			table.insert(targets, entity)
		end
	end

	return #targets > 0 and targets[math.random(1, #targets)] or nil
end

local function zeta_eva2_attack_random(controller, store, count, damage, radius)
	local picked = {}

	for _ = 1, count do
		local target = zeta_eva2_random_enemy(store, function(e) return not picked[e.id] end)

		if not target then
			break
		end

		picked[target.id] = true
		local targets = U.find_enemies_in_range(store.entities, target.pos, 0, radius, 0, 0) or {}

		for _, victim in ipairs(targets) do
			branch_damage(store, controller, victim, damage, DAMAGE_TRUE)
		end
	end
end

local function zeta_eva2_apply_polymorph(controller, store)
	local target = zeta_eva2_random_enemy(store, function(e)
		return not e.branch or not e.branch.boss
	end)

	if not target then
		return
	end

	target.health.hp = math.max(1, math.floor(target.health.hp_max * 0.05 + 0.5))
	local mod = E:create_entity("mod_possession")

	mod.modifier.source_id = controller.id
	mod.modifier.target_id = target.id
	mod.modifier.level = 1
	mod.possession_duration = {[1] = 6}
	queue_insert(store, mod)
end

local function zeta_eva2_apply_vulnerability(controller, store)
	controller.vulnerabilities = controller.vulnerabilities or {}

	for _ = 1, 4 do
		local target = zeta_eva2_random_enemy(store)

		if target then
			target.health.damage_factor = (target.health.damage_factor or 1) * 1.5
			table.insert(controller.vulnerabilities, {target_id = target.id, expires = store.tick_ts + 12})
		end
	end
end

local function zeta_eva2_update_vulnerabilities(controller, store)
	local active = controller.vulnerabilities or {}

	for i = #active, 1, -1 do
		local item = active[i]

		if store.tick_ts >= item.expires then
			local target = store.entities[item.target_id]

			if target and target.health then
				target.health.damage_factor = (target.health.damage_factor or 1) / 1.5
			end

			table.remove(active, i)
		end
	end
end

scripts.zeta_eva2_heroic_choice = {}

function scripts.zeta_eva2_heroic_choice.update(this, store)
	U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)
	U.animation_start(this, "idle", false, store.tick_ts, true)
	this.ui.clicked = nil
	local start_ts = store.tick_ts

	while store.tick_ts - start_ts < (this.choice_timeout or 30) do
		local controller = store.entities[this.controller_id]

		if not controller or controller.choice_round ~= this.choice_round or controller.choice_result then
			break
		end

		if this.ui.clicked then
			this.ui.clicked = nil
			this.ui.can_click = false
			controller.choice_result = this.side
			controller.choice_value = this.side == "left" and math.random(1, 6) or math.random(7, 12)
			U.y_animation_play(this, "shoot", nil, store.tick_ts, 1)
			break
		end

		coroutine.yield()
	end

	this.ui.can_click = false
	queue_remove(store, this)
end

scripts.zeta_eva2_heroic_controller = {}

function scripts.zeta_eva2_heroic_controller.update(this, store)
	this.player_choices = {}
	this.enemy_buffs = {}
	this.choice_round = 0
	this.next_choice_index = 1
	this.next_regen_ts = store.tick_ts + 1
	this.next_necromancy_ts = store.tick_ts + 8
	this.next_gold_ts = store.tick_ts + 1
	this.next_polymorph_ts = store.tick_ts + 7
	this.next_vulnerability_ts = store.tick_ts + 5

	while true do
		local wave = store.wave_group_number or 0
		local wanted_wave = this.choice_waves and this.choice_waves[this.next_choice_index]

		if wanted_wave and wave >= wanted_wave then
			local phase = this.next_choice_index

			this.next_choice_index = this.next_choice_index + 1
			this.choice_round = this.choice_round + 1
			this.choice_result = nil
			this.choice_value = nil
			this.enemy_buffs[phase] = zeta_weighted_roll(zeta_eva2_enemy_buff_weights[phase])

			for _, cfg in ipairs({{"zeta_eva2_heroic_choice_left", 390, 400}, {"zeta_eva2_heroic_choice_right", 630, 400}}) do
				local choice = E:create_entity(cfg[1])

				choice.pos = V.v(cfg[2], cfg[3])
				choice.controller_id = this.id
				choice.choice_round = this.choice_round
				queue_insert(store, choice)
			end
		end

		if this.choice_value then
			zeta_eva2_apply_player_choice(this, store, this.choice_value)
			this.choice_value = nil
		end

		for _, entity in pairs(store.entities) do
			for phase, choice in pairs(this.enemy_buffs) do
				zeta_eva2_apply_enemy_buff(entity, phase, choice)
			end

			zeta_eva2_update_player_choices(this, store, entity)
		end

		if store.tick_ts >= this.next_regen_ts then
			this.next_regen_ts = store.tick_ts + 1

			for _, entity in pairs(store.entities) do
				if entity.enemy and entity.health and not entity.health.dead and entity._zeta_eva2_regen then
					entity.health.hp = math.min(entity.health.hp_max, entity.health.hp + entity._zeta_eva2_regen)
				end
			end
		end

		if this.player_choices[7] and store.tick_ts >= this.next_necromancy_ts then
			this.next_necromancy_ts = store.tick_ts + 8
			zeta_eva2_attack_random(this, store, 4, 50, 62.5)
		end

		if this.player_choices[8] and store.tick_ts >= this.next_gold_ts then
			this.next_gold_ts = store.tick_ts + 1
			local target = zeta_eva2_random_enemy(store)

			if target then
				signal.emit("got-gold", V.vclone(target.pos), 1)
			end
		end

		if this.player_choices[11] and store.tick_ts >= this.next_polymorph_ts then
			this.next_polymorph_ts = store.tick_ts + 7
			zeta_eva2_apply_polymorph(this, store)
		end

		if this.player_choices[12] and store.tick_ts >= this.next_vulnerability_ts then
			this.next_vulnerability_ts = store.tick_ts + 5
			zeta_eva2_apply_vulnerability(this, store)
		end

		zeta_eva2_update_vulnerabilities(this, store)
		U.y_wait(store, this.scan_interval or 0.15)
	end
end


scripts.zeta_eva3_heroic_controller = {}

function scripts.zeta_eva3_heroic_controller.update(this, store)
	local target

	for _, entity in pairs(store.entities) do
		if entity.tower and tostring(entity.tower.holder_id) == tostring(this.target_holder_id or "14") and
				entity.template_name == "zeta_level19_iron_tower" then
			target = entity
			break
		end
	end

	if target then
		local cloud = E:create_entity(this.cloud_template or "enemy_zeta_level19_black_cloud")
		local nodes = P:nearest_nodes(target.pos.x, target.pos.y, nil, nil, true)

		cloud.pos = V.vclone(target.pos)
		cloud.target_tower_id = target.id

		if nodes and nodes[1] then
			cloud.nav_path.pi = nodes[1][1]
			cloud.nav_path.spi = nodes[1][2]
			cloud.nav_path.ni = nodes[1][3]
		end

		queue_insert(store, cloud)
	end

	queue_remove(store, this)
end

scripts.zeta_level19_black_cloud = {}

function scripts.zeta_level19_black_cloud.update(this, store)
	U.animation_start(this, "idle", false, store.tick_ts, true)

	while not this.health.dead do
		coroutine.yield()
	end

	local residue = E:create_entity("zeta_level19_black_cloud_residue")

	residue.pos = V.vclone(this.pos)
	residue.target_tower_id = this.target_tower_id
	queue_insert(store, residue)
	branch_enemy_death(store, this)
end

scripts.zeta_level19_black_cloud_residue = {}

function scripts.zeta_level19_black_cloud_residue.update(this, store)
	U.animation_start(this, "idle", false, store.tick_ts, true)
	U.y_wait(store, this.duration or 3)
	local tower = store.entities[this.target_tower_id]

	if tower and tower.tower and not tower.tower.destroy then
		tower.tower.destroy = true
	end

	queue_remove(store, this)
end


scripts.zeta_demon_iron_controller = {}

function scripts.zeta_demon_iron_controller.update(this, store)
	while true do
		for _, entity in pairs(store.entities) do
			local name = entity.template_name or ""

			if entity.enemy and entity.health and not entity.health.dead and zeta_is_demon_enemy(entity) and
					not string.find(name, "pit_lord", 1, true) and not entity._zeta_demon_iron_scaled then
				zeta_set_health_factor(entity, "_zeta_demon_iron_base_hp", "_zeta_demon_iron_hp_factor", 1.5)

				if entity.unit then
					entity.unit.damage_factor = (entity.unit.damage_factor or 1) * 1.5
				end

				entity._zeta_demon_iron_scaled = true
			end
		end

		U.y_wait(store, this.scan_interval or 0.15)
	end
end


scripts.zeta_eva2_factory = {}

function scripts.zeta_eva2_factory.get_info(this)
	return {
		type = STATS_TYPE_TEXT,
		desc = _("EVA_FACTORY_DESCRIPTION")
	}
end

scripts.soldier_zeta_chomp_bot_ally = {}

function scripts.soldier_zeta_chomp_bot_ally.remove(this, store)
	if this.health.dead and not this.death_refund_paid then
		this.death_refund_paid = true
		signal.emit("got-gold", V.vclone(this.pos), this.death_refund or 15)
	end

	return scripts.soldier_barrack.remove(this, store)
end

scripts.zeta_level19_iron_tower = {}

function scripts.zeta_level19_iron_tower.get_info(this)
	return scripts.tower_mage.get_info(this)
end

function scripts.zeta_level19_iron_tower.remove(this, store)
	local attack = this.attacks and this.attacks.list[1]

	for _, bullet in ipairs(attack and attack._stored_bullets or {}) do
		if store.entities[bullet.id] then
			queue_remove(store, bullet)
		end
	end

	return true
end

function scripts.zeta_level19_iron_tower.update(this, store)
	local attack = this.attacks.list[1]
	local stored = attack._stored_bullets

	attack.ts = store.tick_ts

	local function spawn_bolt(target, storage_offset)
		local bullet = E:create_entity(attack.bullet)
		local start_offset = attack.bullet_start_offset[1]

		bullet.bullet.from = V.v(this.pos.x + start_offset.x, this.pos.y + start_offset.y)
		bullet.bullet.source_id = this.id
		bullet.pos = V.vclone(bullet.bullet.from)

		if target then
			bullet.bullet.target_id = target.id
			bullet.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
		else
			bullet.bullet.store = true
			bullet.bullet.target_id = nil
			bullet.bullet.to = V.v(this.pos.x + storage_offset.x, this.pos.y + storage_offset.y)
			table.insert(stored, bullet)
		end

		queue_insert(store, bullet)
	end

	while true do
		if not this.tower.blocked and store.tick_ts - attack.ts >= attack.cooldown then
			local target = U.find_foremost_enemy(store.entities, this.pos, 0, this.attacks.range, false,
				attack.vis_flags, attack.vis_bans)

			if target then
				attack.ts = store.tick_ts
				U.animation_start(this, attack.animation, nil, store.tick_ts, false, 2)

				while store.tick_ts - attack.ts < attack.shoot_time do
					coroutine.yield()
				end

				if target.health and not target.health.dead and band(target.vis.bans, attack.vis_flags) == 0 and
						band(target.vis.flags, attack.vis_bans) == 0 then
					if #stored > 0 then
						for _, bullet in ipairs(stored) do
							bullet.bullet.target_id = target.id
							bullet.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x,
								target.pos.y + target.unit.hit_offset.y)
						end
						attack._stored_bullets = {}
						stored = attack._stored_bullets
					else
						spawn_bolt(target)
					end
				end
			elseif #stored < attack.max_stored_bullets then
				attack.ts = store.tick_ts
				spawn_bolt(nil, attack.storage_offsets[#stored + 1])
			end
		end

		coroutine.yield()
	end
end

function scripts.zeta_eva2_factory.update(this, store)
	local us = this.user_selection
	local active_ids = {}

	if us then
		us.allowed = true
	end

	while true do
		for i = #active_ids, 1, -1 do
			local soldier = store.entities[active_ids[i]]

			if not soldier or soldier.health.dead then
				table.remove(active_ids, i)
			end
		end

		if us then
			us.allowed = #active_ids < (this.max_units or 5)

			if us.new_pos then
				local dest = us.new_pos
				local attack = this.attacks and this.attacks.list[us.arg or 1]

				us.arg = nil
				us.new_pos = nil

				if us.allowed and attack and store.player_gold >= (attack.price or 0) then
					store.player_gold = store.player_gold - (attack.price or 0)

					local soldier = E:create_entity(this.soldier_template or "soldier_zeta_chomp_bot_ally")
					local spawn_offset = this.spawn_offset or V.v(-8, 6)

					soldier.pos = V.v(this.pos.x + spawn_offset.x, this.pos.y + spawn_offset.y)

					if soldier.nav_rally then
						soldier.nav_rally.center = V.vclone(dest)
						soldier.nav_rally.pos = V.vclone(dest)
						soldier.nav_rally.new = true
					end

					if soldier.soldier then
						soldier.soldier.tower_id = this.id
						soldier.soldier.tower_soldier_idx = #active_ids + 1
					end

					queue_insert(store, soldier)
					table.insert(active_ids, soldier.id)
					signal.emit("tower-spawn", this, soldier)
				end
			end
		end

		coroutine.yield()
	end
end

local zeta_triplet_templates = {
	"enemy_kr4_enemy_demon_veznan",
	"enemy_kr1_enemy_demon_moloch",
	"enemy_kr4_enemy_demon_oloch"
}

local function zeta_find_triplet_members(store, members)
	for _, e in pairs(store.entities) do
		for _, template_name in ipairs(zeta_triplet_templates) do
			if e.template_name == template_name and not members[template_name] then
				members[template_name] = e
				break
			end
		end
	end
end

scripts.zeta_triplet_controller = {}

function scripts.zeta_triplet_controller.update(this, store)
	if store.zeta_triplet_controller_id and store.zeta_triplet_controller_id ~= this.id and
			store.entities[store.zeta_triplet_controller_id] then
		queue_remove(store, this)
		return
	end

	store.zeta_triplet_controller_id = this.id
	local members = {}
	local death_seen = {}
	local iron_scaled = {}
	local slowed = {}

	while true do
		zeta_find_triplet_members(store, members)

		if not this.iron_triplet then
			for _, member in pairs(members) do
				if member.motion and not slowed[member.id] then
					member.motion.max_speed = member.motion.max_speed * 0.72
					slowed[member.id] = true
				end
			end
		end

		if this.iron_triplet then
			for _, e in pairs(store.entities) do
				local factor = e.template_name == "enemy_kr4_enemy_demon_oloch" and 0.4
					or (e.template_name == "enemy_kr4_enemy_demon_veznan" or
						e.template_name == "enemy_kr1_enemy_demon_moloch") and 0.5
					or e.template_name == "enemy_cerberus" and 0.6

				if factor and e.health and not iron_scaled[e.id] then
					e.health.hp_max = math.max(1, math.floor(e.health.hp_max * factor + 0.5))
					e.health.hp = math.min(e.health.hp, e.health.hp_max)
					iron_scaled[e.id] = true
				end
			end
		end

		local seen_count = 0
		local dead_count = 0

		for _, template_name in ipairs(zeta_triplet_templates) do
			local member = members[template_name]

			if member then
				seen_count = seen_count + 1

				if member.health.dead or not store.entities[member.id] then
					dead_count = dead_count + 1

					if not death_seen[template_name] then
						death_seen[template_name] = true

						for _, other_name in ipairs(zeta_triplet_templates) do
							local other = members[other_name]

							if other and other_name ~= template_name and other.health and not other.health.dead then
								branch_damage(store, this, other, this.death_damage or 3335, DAMAGE_MAGICAL)
							end
						end
					end
				end
			end
		end

		if seen_count == #zeta_triplet_templates and dead_count == #zeta_triplet_templates then
			store.zeta_triplet_controller_id = nil
			queue_remove(store, this)
			return
		end

		coroutine.yield()
	end
end

scripts.zeta_endgame_spawner = {}

function scripts.zeta_endgame_spawner.update(this, store)
	local members = {}

	while true do
		zeta_find_triplet_members(store, members)

		local seen_count = 0
		local dead_count = 0

		for _, template_name in ipairs(zeta_triplet_templates) do
			local member = members[template_name]

			if member then
				seen_count = seen_count + 1

				if member.health.dead or not store.entities[member.id] then
					dead_count = dead_count + 1
				end
			end
		end

		if seen_count == #zeta_triplet_templates and dead_count == #zeta_triplet_templates then
			local final_boss = branch_spawn_on_path(store, "enemy_demon_endgame", this, 0)

			if final_boss then
				final_boss.pos = V.vclone(this.pos)
			end

			queue_remove(store, this)
			return
		end

		coroutine.yield()
	end
end

local function zeta_shuffle_targets(targets)
	for i = #targets, 2, -1 do
		local j = math.random(i)

		targets[i], targets[j] = targets[j], targets[i]
	end

	return targets
end

local function zeta_event_activate_paths(paths)
	for _, pi in ipairs(paths or {}) do
		if P.paths[pi] then
			P:activate_path(pi)
		end
	end
end

local function zeta_event_pick_soldier(store, origin, max_health)
	local targets = U.find_soldiers_in_range(store.entities, origin, 0, 2000, 0, 0, kr4_valid_enemy_soldier_target)

	if not targets or #targets == 0 then
		return nil
	end

	if max_health then
		table.sort(targets, function(a, b)
			local ah = a.health and a.health.hp or 0
			local bh = b.health and b.health.hp or 0

			return ah > bh
		end)

		return targets[1]
	end

	return targets[math.random(1, #targets)]
end

local function zeta_event_block_nearest_tower(this, store, radius)
	local towers = {}

	for _, tower in pairs(store.entities) do
		if tower.tower and tower.ui and tower.pos and not tower.tower_holder and
				tower.tower.type ~= "build_animation" and tower.tower.can_be_mod ~= false and
				not tower.tower.blocked and V.dist(this.pos.x, this.pos.y, tower.pos.x, tower.pos.y) <= radius then
			table.insert(towers, tower)
		end
	end

	table.sort(towers, function(a, b)
		return V.dist(this.pos.x, this.pos.y, a.pos.x, a.pos.y) <
			V.dist(this.pos.x, this.pos.y, b.pos.x, b.pos.y)
	end)

	local tower = towers[1]

	if tower then
		local mod = E:create_entity("mod_branch_tower_block")

		mod.modifier.source_id = this.id
		mod.modifier.target_id = tower.id
		mod.modifier.duration = 100000
		queue_insert(store, mod)
	end
end

local function zeta_event_spawn_enemy(this, store, template_name, count)
	local pi = this.spawn_path or 1

	if not P.paths[pi] then
		log.error("zeta event tried to spawn %s on missing target path %s", template_name, pi)
		return
	end

	for i = 1, count or 1 do
		if store.level and store.level.run_complete then
			break
		end

		local spi = this.spawn_subpath

		if not spi or spi < 1 then
			spi = math.random(1, #P.paths[pi])
		elseif not P.paths[pi][spi] then
			spi = 1
		end

		local ni = this.spawn_node or P:get_start_node(pi)
		local spawn_pos = this.spawn_pos or P:node_pos(pi, spi, ni) or this.pos

		branch_spawn_from_pos_to_path(store, template_name, spawn_pos, pi, spi, ni)

		if i < (count or 1) and (this.spawn_interval or 0) > 0 then
			U.y_wait(store, this.spawn_interval)
		end
	end
end

function scripts.zeta_stage_event.update(this, store)
	local kind = this.kind

	if kind == "spawn" then
		zeta_event_spawn_enemy(this, store, this.spawn_template, this.spawn_count or 1)
	elseif kind == "storm" then
		local storm = branch_spawn_scene(store, "snow_storm", this.pos.x, this.pos.y, this.storm or {})

		storm.army = this.army
		storm.duration = this.duration or storm.duration
	elseif kind == "levitate" then
		local next_ts = store.tick_ts

		while true do
			if store.tick_ts >= next_ts then
				local targets = U.find_enemies_in_range(store.entities, V.v(512, 384), 0, 2000, 0, F_BOSS) or {}

				zeta_shuffle_targets(targets)

				for i = 1, math.min(this.units_amount or 15, #targets) do
					local target = targets[i]
					local mod = E:create_entity("mod_branch_freeze")

					mod.modifier.source_id = this.id
					mod.modifier.target_id = target.id
					mod.modifier.duration = this.unit_freeze_duration or 5
					queue_insert(store, mod)
				end

				next_ts = store.tick_ts + (this.modifier_interval or 20)
			end

			coroutine.yield()
		end
	elseif kind == "missile" then
		local end_ts = store.tick_ts + (this.duration or 28)
		local next_ts = store.tick_ts

		while store.tick_ts < end_ts do
			if store.tick_ts >= next_ts then
				local roll = math.random(1, 6)
				local creates_fissure = roll <= 2
				local max_health = roll == 1 or roll == 3 or roll == 4
				local target = zeta_event_pick_soldier(store, this.pos, max_health)

				if target then
					local hit_pos = V.vclone(target.pos)

					if target.vis and band(target.vis.flags or 0, F_FLYING) ~= 0 then
						hit_pos.y = hit_pos.y - 84
					end

					kr4_insert_one_shot_fx(store, "fx_murglun_fireball_explosion", hit_pos, 1)
					branch_damage_soldiers(store, this, hit_pos, this.damage_radius or 67.5,
						creates_fissure and (this.special_damage_min or 80) or (this.damage_min or 60),
						this.damage_max or 120, creates_fissure and DAMAGE_MAGICAL or DAMAGE_TRUE)

					if creates_fissure then
						branch_spawn_scene(store, "enemy_zeta_demon_fissure", hit_pos.x, hit_pos.y)
					end
				end

				next_ts = next_ts + (this.attack_interval or 5)
			end

			coroutine.yield()
		end
	elseif kind == "factory" or kind == "stone" then
		local scene = this.scene_id and store.entities[this.scene_id]

		if scene and scene.render and scene.render.sprites then
			U.animation_start(scene, "death", false, store.tick_ts, false)
		end

		kr4_insert_one_shot_fx(store, "fx_kr4_explosion_fragment", this.pos, 1)

		if kind == "stone" or kind == "factory" then
			branch_damage_soldiers(store, this, this.pos, this.damage_radius or 100,
				this.damage_min or 400, this.damage_max or 400, this.damage_type or DAMAGE_MAGICAL)
		end

		U.y_wait(store, this.activate_delay or 0)
		zeta_event_activate_paths(this.activate_paths)

		if this.spawn_template then
			zeta_event_spawn_enemy(this, store, this.spawn_template, this.spawn_count or 1)
		end

		if kind == "factory" then
			U.y_wait(store, 0.1)
			branch_damage_soldiers(store, this, this.pos, this.damage_radius or 100,
				this.damage_min or 400, this.damage_max or 400, this.damage_type or DAMAGE_MAGICAL)
			zeta_event_block_nearest_tower(this, store, this.tower_block_radius or 40)
		end

		if scene and store.entities[scene.id] then
			queue_remove(store, scene)
		end
	elseif kind == "altar" then
		branch_spawn_scene(store, "zeta_stage87_end", 515, 768)
	end

	queue_remove(store, this)
end

function magnus_cast_poison(this, store)
	local cfg = this.magnus and this.magnus.poison

	if not cfg then
		return false
	end

	local centers = {}
	local candidates = table.filter(store.entities, function(_, e)
		return magnus_poison_candidate(e)
	end)

	for _, soldier in ipairs(candidates or {}) do
		local nearby = U.find_soldiers_in_range(store.entities, soldier.pos, 0, cfg.search_radius or 120, 0, F_FLYING, kr4_valid_enemy_soldier_target)

		if nearby and #nearby >= (cfg.min_targets or 2) then
			table.insert(centers, soldier)
		end
	end

	if #centers == 0 then
		return false
	end

	local center = table.random(centers)
	local pos = V.vclone(center.pos)

	return magnus_play_cast(this, store, cfg, function()
		local aura = E:create_entity(cfg.aura)

		aura.pos = pos
		aura.aura.source_id = this.id
		aura.aura.duration = cfg.duration or aura.aura.duration
		aura.aura.radius = cfg.radius or aura.aura.radius

		queue_insert(store, aura)

		return true
	end)
end

function magnus_cast_skill(this, store, skill_name)
	if skill_name == "shield" then
		return magnus_cast_shield(this, store)
	elseif skill_name == "tower_block" then
		return magnus_cast_tower_block(this, store)
	elseif skill_name == "poison" then
		return magnus_cast_poison(this, store)
	end

	return false
end

function scripts.magnus.update(this, store)
	for _, s in pairs(this.render and this.render.sprites or {}) do
		s.ts = store.tick_ts
	end

	magnus_start_idle(this, store)

	local last_wave = store.wave_group_number or 0
	local initial_schedule = this.magnus and this.magnus.wave_skills and this.magnus.wave_skills[last_wave]
	local next_cast_ts = initial_schedule and store.tick_ts or 1e+99

	while not this.exit do
		local wave = store.wave_group_number or 0
		local schedule = this.magnus and this.magnus.wave_skills and this.magnus.wave_skills[wave]

		if wave ~= last_wave then
			last_wave = wave
			next_cast_ts = schedule and store.tick_ts or 1e+99
		end

		if schedule and not store.waves_finished and store.tick_ts >= next_cast_ts then
			local casted = magnus_cast_skill(this, store, schedule.skill)

			next_cast_ts = store.tick_ts + (casted and schedule.cooldown or 1)
		end

		coroutine.yield()
	end
	for _, p in ipairs({{532,412},{443,409},{498,435},{449,502},{509,501},{476,394},{424,411},{463,452}}) do
		branch_spawn_scene(store, "fx_magnus_end_explosion", p[1], p[2])
		U.y_wait(store, 0.33)
	end
	for _, sprite in ipairs(this.render.sprites) do sprite.hidden = true end
	this.exit_done = true

end

scripts.stage12_sheep = {}

function scripts.stage12_sheep.update(this, store)
	local sprite = this.render and this.render.sprites and this.render.sprites[1]

	if sprite and sprite.animated and sprite.name then
		U.animation_start(this, this.loop_animation or sprite.name, nil, store.tick_ts, true, 1)
	end

	this.ui.clicked = nil
	this.ui.can_click = true

	local clicks = 0
	local required = this.clicks_to_destroy or 5
	local reacting = false

	while clicks < required do
		if this.ui.clicked then
			this.ui.clicked = nil
			clicks = clicks + 1

			local animation = this.click_animation

			if type(animation) == "table" and #animation > 0 then
				animation = animation[math.random(1, #animation)]
			end

			if animation and clicks < required then
				U.animation_start(this, animation, nil, store.tick_ts, false, 1)
				reacting = true
			end
		end

		if reacting and U.animation_finished(this, 1) then
			U.animation_start(this, this.loop_animation or sprite.name, nil, store.tick_ts, true, 1)
			reacting = false
		end

		coroutine.yield()
	end

	this.ui.can_click = false

	if this.sound_events and this.sound_events.remove then
		S:queue(this.sound_events.remove)
	end

	if this.death_animation then
		U.y_animation_play(this, this.death_animation, nil, store.tick_ts, 1)
	end

	if this.counts_for_joe then
		store.stage12_joe_sheep_kills = (store.stage12_joe_sheep_kills or 0) + 1
	end

	queue_remove(store, this)
end

scripts.stage12_joe_dummy = {}

function scripts.stage12_joe_dummy.insert(this, store)
	store.stage12_joe_sheep_kills = 0

	return true
end

function scripts.stage12_joe_dummy.update(this, store)
	local sprite = this.render and this.render.sprites and this.render.sprites[1]

	if sprite and sprite.animated then
		U.animation_start(this, this.loop_animation or sprite.name, nil, store.tick_ts, true, 1)
	end

	this.ui.clicked = nil
	local next_idle_ts = store.tick_ts + math.random(this.idle_cooldown_min or 20, this.idle_cooldown_max or 40)

	while (store.stage12_joe_sheep_kills or 0) < (this.required_sheep or 5) do
		if this.ui.clicked then
			this.ui.clicked = nil
		end

		if store.tick_ts >= next_idle_ts then
			local animation = this.click_animation

			if type(animation) == "table" and #animation > 0 then
				animation = animation[math.random(1, #animation)]
			end

			if animation then
				U.y_animation_play(this, animation, nil, store.tick_ts, 1)

				if store.entities[this.id] and sprite and sprite.animated then
					U.animation_start(this, this.loop_animation or sprite.name, nil, store.tick_ts, true, 1)
				end
			end

			next_idle_ts = store.tick_ts + math.random(this.idle_cooldown_min or 20, this.idle_cooldown_max or 40)
		end

		coroutine.yield()
	end

	this.ui.can_click = false

	if this.angry_sound then
		S:queue(this.angry_sound)
	end

	if this.angry_animation then
		U.y_animation_play(this, this.angry_animation, nil, store.tick_ts, 1)
	end

	local joe = branch_spawn_from_pos_to_path(store, this.joe_template or "enemy_linirea_joe", V.vclone(this.pos), this.joe_path or 1, this.joe_subpath or 1, this.joe_node or 60)

	if joe then
		joe.pos = V.vclone(this.pos)

		-- The dummy already played Joe's transformation, so the enemy starts walking immediately.
		if joe.branch then
			joe.branch.spawn_animation = nil
			joe.branch.spawn_sound = nil
		end
	end

	queue_remove(store, this)
end

scripts.stage12_farm_spawner = {}

function scripts.stage12_farm_spawner.update(this, store)
	for _, template_name in ipairs(this.units or {}) do
		branch_spawn_from_pos_to_path(store, template_name, V.vclone(this.pos), this.path or 1, this.subpath or 1, this.node)
		U.y_wait(store, this.interval or 1)
	end

	queue_remove(store, this)
end

scripts.boss_shaman = {}

function scripts.boss_shaman.update(this, store)
	local s = this.render.sprites[1]

	s.ts = store.tick_ts
	U.animation_start(this, s.name or "idle", nil, store.tick_ts, true, 1)

	local next_taunt_ts = store.tick_ts + math.random(this.taunt_cooldown_min or 10, this.taunt_cooldown_max or 20)

	while true do
		if this.end_sequence then
			this.end_sequence = nil

			local end_ts = store.tick_ts
			local played = {}

			U.animation_start(this, "shake1", nil, store.tick_ts, false, 1, true)

			while store.tick_ts - end_ts < 2 do
				for i, cfg in ipairs(this.end_sounds or {}) do
					if not played[i] and store.tick_ts - end_ts >= (cfg.time or 0) then
						played[i] = true
						S:queue(cfg.sound)
					end
				end

				if store.tick_ts - end_ts > 1.55 then
					local alpha = km.clamp(0, 255, 255 * (1 - (store.tick_ts - end_ts - 1.55) / 0.45))
					this.render.sprites[1].alpha = alpha
				end

				coroutine.yield()
			end

			queue_remove(store, this)

			return
		end

		if store.tick_ts >= next_taunt_ts then
			U.y_animation_play(this, "speak1_start", nil, store.tick_ts, 1)
			U.animation_start(this, "speak1_loop", nil, store.tick_ts, true, 1, true)
			U.y_wait(store, this.taunt_loop_duration or 2.5)
			U.y_animation_play(this, "speak1_end", nil, store.tick_ts, 1)

			if store.entities[this.id] then
				U.animation_start(this, "idle", nil, store.tick_ts, true, 1, true)
			end

			next_taunt_ts = store.tick_ts + math.random(this.taunt_cooldown_min or 10, this.taunt_cooldown_max or 20)
		end

		coroutine.yield()
	end
end

scripts.mercenary_troll_hut = {}

function scripts.mercenary_troll_hut.update(this, store, script)
	local b = this.barrack
	local door_sids = this.render.door_sids or {this.render.door_sid or 2}

	local function play_door(animation)
		for _, sid in ipairs(door_sids) do
			U.animation_start(this, animation, nil, store.tick_ts, false, sid)
		end

		U.y_animation_wait(this, door_sids[1])
	end

	while true do
		local old_count = #b.soldiers

		b.soldiers = table.filter(b.soldiers, function(_, s)
			return store.entities[s.id] ~= nil
		end)

		if #b.soldiers > 0 and #b.soldiers ~= old_count then
			for i, s in ipairs(b.soldiers) do
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
			end
		end

		if b.unit_bought then
			if #b.soldiers < b.max_soldiers then
				local s = E:create_entity(b.unit_bought)

				if store.player_gold >= s.unit.price then
					if b.has_door and not b.door_open then
						play_door("open")

						b.door_open = true
						b.door_open_ts = store.tick_ts
					end

					store.player_gold = store.player_gold - s.unit.price

					table.insert(b.soldiers, s)

					local i = #b.soldiers

					s.soldier.tower_id = this.id
					s.soldier.tower_soldier_idx = i
					s.pos = V.v(V.add(this.pos.x, this.pos.y, b.respawn_offset.x, b.respawn_offset.y))
					s.nav_rally.new = true

					queue_insert(store, s)

					for j, ss in ipairs(b.soldiers) do
						ss.nav_rally.pos, ss.nav_rally.center = U.rally_formation_position(j, b, b.max_soldiers, b.rally_angle_offset)
					end

					signal.emit("tower-spawn", this, s)
				end
			end

			b.unit_bought = nil
		end

		if b.has_door and b.door_open and store.tick_ts - b.door_open_ts > b.door_hold_time then
			play_door("close")

			b.door_open = false
		end

		if b.rally_new then
			b.rally_new = false

			signal.emit("rally-point-changed", this)

			local sounds = {}
			local all_dead = true

			for i, s in ipairs(b.soldiers) do
				s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
				s.nav_rally.new = true

				if s.sound_events.change_rally_point then
					table.insert(sounds, s.sound_events.change_rally_point)
				end

				all_dead = all_dead and s.health.dead
			end

			if not all_dead then
				if #sounds > 0 then
					S:queue(sounds[math.random(1, #sounds)])
				else
					S:queue(this.sound_events.change_rally_point)
				end
			end
		end

		coroutine.yield()
	end
end

scripts.linirea_caravan = {}

function scripts.linirea_caravan.get_info(this)
	return {
		type = STATS_TYPE_TEXT,
		desc = _("TOWER_CARAVAN_DESCRIPTION")
	}
end

function scripts.linirea_caravan.can_select_point(this, x, y, store)
	return P:valid_node_nearby(x, y, nil, NF_RALLY) and GR:cell_is(x, y, TERRAIN_ALL_MASK)
end

function scripts.linirea_caravan.update(this, store, script)
	local us = this.user_selection
	local thief_sid = this.render.thief_sid
	local next_thief_anim_ts = store.tick_ts + math.random(20, 30)
	local thief_animating = false

	local function play_thief(animation, loop)
		if thief_sid and this.render.sprites[thief_sid] then
			U.animation_start(this, animation, nil, store.tick_ts, loop, thief_sid)
			thief_animating = not loop
		end
	end

	local function insert_spawn_fx(pos)
		if not this.spawn_fx then
			return
		end

		local fx = E:create_entity(this.spawn_fx)

		fx.pos = V.vclone(pos)
		fx.pos.y = fx.pos.y + (this.spawn_fx_y_offset or 0)

		if fx.render and fx.render.sprites then
			for _, s in pairs(fx.render.sprites) do
				s.ts = store.tick_ts
			end
		end

		queue_insert(store, fx)
	end

	local function spawn_soldier(template_name, center, offset, index)
		local soldier = E:create_entity(template_name)
		local pos = V.v(center.x + (offset and offset.x or 0), center.y + (offset and offset.y or 0))

		soldier.pos = V.vclone(pos)

		if soldier.nav_rally then
			soldier.nav_rally.center = V.vclone(center)
			soldier.nav_rally.pos = V.vclone(pos)
			soldier.nav_rally.new = false
		end

		if soldier.soldier then
			soldier.soldier.tower_id = this.id
			soldier.soldier.tower_soldier_idx = index
		end

		queue_insert(store, soldier)
		signal.emit("tower-spawn", this, soldier)
	end

	if us then
		us.allowed = true
	end

	play_thief("idle", true)

	while true do
		if thief_sid then
			if thief_animating and U.animation_finished(this, thief_sid) then
				play_thief("idle", true)
			elseif not thief_animating and store.tick_ts >= next_thief_anim_ts and not us.in_progress and not us.menu_shown then
				play_thief("throwCoin", false)
				next_thief_anim_ts = store.tick_ts + math.random(20, 30)
			end
		end

		if us and us.new_pos then
			local arg = us.arg or 1
			local dest = us.new_pos
			local attack = this.attacks and this.attacks.list[arg]

			us.arg = nil
			us.new_pos = nil

			if attack and attack.price and attack.price <= store.player_gold then
				local packs = attack.packs
				local pack = packs and packs[math.random(1, #packs)]

				if pack then
					store.player_gold = store.player_gold - attack.price

					play_thief("call", false)
					insert_spawn_fx(dest)

					local offsets = this.caravan_offsets[#pack] or this.caravan_offsets.default

					for i, template_name in ipairs(pack) do
						spawn_soldier(template_name, dest, offsets and offsets[i], i)
					end
				end
			end
		end

		coroutine.yield()
	end
end

function branch_apply_holder_visual(holder)
	if not holder or not holder.tower or not holder.tower.terrain_style or not holder.render or not holder.render.sprites then
		return
	end

	local s = holder.render.sprites[1]

	if s and type(s.name) == "string" and string.find(s.name, "%%") then
		s.name = string.format(s.name, holder.tower.terrain_style)
	end
end

function branch_copy_holder_data(source, target)
	if not source or not source.tower or not target or not target.tower then
		return
	end

	target.tower.holder_id = source.tower.holder_id
	target.tower.flip_x = source.tower.flip_x

	if source.tower.default_rally_pos then
		target.tower.default_rally_pos = V.vclone(source.tower.default_rally_pos)
	end

	if source.tower.terrain_style then
		target.tower.terrain_style = source.tower.terrain_style
	end

	if target.ui and source.ui and source.ui.nav_mesh_id then
		target.ui.nav_mesh_id = source.ui.nav_mesh_id
	end
end

function branch_restore_ice_block_holder(store, this)
	local restore_template = this.restore_template or "tower_holder"

	if restore_template == "dummy_holder" then
		restore_template = "tower_holder"
	end

	local holder = E:create_entity(restore_template)

	holder.pos = V.vclone(this.pos)

	if holder.tower then
		holder.tower.holder_id = this.tower and this.tower.holder_id or this.holder_id
		holder.tower.flip_x = this.tower and this.tower.flip_x

		if this.tower and this.tower.default_rally_pos then
			holder.tower.default_rally_pos = V.vclone(this.tower.default_rally_pos)
		end

		if this.tower and this.tower.terrain_style then
			holder.tower.terrain_style = this.tower.terrain_style
		end
	end

	if holder.ui then
		holder.ui.nav_mesh_id = this.ui and this.ui.nav_mesh_id or this.restore_nav_mesh_id
	end

	branch_apply_holder_visual(holder)
	queue_insert(store, holder)
	signal.emit("tower-upgraded", holder, this)

	return holder
end

scripts.ice_block = {}

function scripts.ice_block.update(this, store)
	this.render.sprites[1].ts = store.tick_ts
	this.ui.clicked = nil
	local due_ts
	while not this.remove do
		local wave = store.wave_group_number or 0
		if not due_ts and wave >= this.wave_start then due_ts = store.tick_ts + this.delay_to_spawn end

		this.ui.clicked = nil

		if this.tower and this.tower.upgrade_to then
			-- The player chose the 200-gold tower-menu clear action; the tower
			-- system will replace this blocked holder and charge the price.
			coroutine.yield()
		elseif due_ts and store.tick_ts >= due_ts then
			local e = branch_spawn_from_pos_to_path(store, "enemy_ice_golem", this.pos, this.path, this.subpath, this.node)

			if e then
				this.render.sprites[1].hidden = true
				this.ui.can_click = false
			end

			queue_remove(store, this)
			return
		end
		coroutine.yield()
	end
end

scripts.magical_stove = {}

function scripts.magical_stove.update(this, store)
	local function start(animation, loop)
		U.animation_start_group(this, animation, nil, store.tick_ts, loop, this.animation_group)
	end

	local function coin_ready(visible)
		local sid = this.coin_sprite_id
		local sprite = sid and this.render.sprites[sid]

		if not sprite then
			return
		end

		sprite.hidden = not visible

		if visible then
			U.animation_start(this, this.coin_animation or "run", nil, store.tick_ts, true, sid, true)
		end
	end

	this.ui.clicked = nil
	local ready_ts = store.tick_ts

	start(this.ready_animation or "ready", true)
	coin_ready(true)

	while true do
		if store.tick_ts >= ready_ts and this._cooling_down then
			this._cooling_down = nil
			start(this.ready_animation or "ready", true)
			coin_ready(true)
		end

		if this.ui.clicked then
			this.ui.clicked = nil
			if store.tick_ts >= ready_ts then
				ready_ts = store.tick_ts + this.cooldown
				this._cooling_down = true
				coin_ready(false)
				start(this.shoot_animation or "shoot", false)
				S:queue("level23_magicstove_absortion")
				local targets = U.find_enemies_in_range(store.entities, this.pos, 0, this.radius, 0, bor(F_BOSS, F_MINIBOSS))
				for i, enemy in ipairs(targets or {}) do
					if i > this.max_targets then break end
					if enemy.enemy then enemy.enemy.gold = math.floor((enemy.enemy.gold or 0) * this.gold_factor) end
					branch_damage(store, this, enemy, enemy.health.hp + enemy.health.hp_max, DAMAGE_TRUE)
				end

				while store.tick_ts < ready_ts and this._cooling_down do
					if U.animation_finished(this, 1) then
						start(this.cooldown_animation or "cooldown", true)
						break
					end
					coroutine.yield()
				end
			end
		end
		coroutine.yield()
	end
end

scripts.shaolin_master = {}

function scripts.shaolin_master.update(this, store)
	local sprite = this.render and this.render.sprites and this.render.sprites[1]
	local positions = this.array_positions or {}
	local touches = this.touches_to_win or #positions
	local delay = this.delay_to_appear or 3

	if not sprite or #positions < 1 or touches < 1 then
		return
	end

	this.ui.clicked = nil
	this.ui.can_click = false
	sprite.hidden = true

	for i = 1, touches do
		U.y_wait(store, delay)

		local pos = positions[(i - 1) % #positions + 1]

		this.pos.x, this.pos.y = pos.x, pos.y
		this.ui.clicked = nil
		this.ui.can_click = true
		sprite.hidden = false

		U.y_animation_play(this, "in", nil, store.tick_ts, 1)
		if not store.entities[this.id] then
			return
		end

		U.animation_start(this, "idle", nil, store.tick_ts, true, 1)

		while store.entities[this.id] and not this.ui.clicked do
			coroutine.yield()
		end

		if not store.entities[this.id] then
			return
		end

		this.ui.clicked = nil
		this.ui.can_click = false

		U.y_animation_play(this, "action", nil, store.tick_ts, 1)
		if not store.entities[this.id] then
			return
		end

		U.y_animation_play(this, "out", nil, store.tick_ts, 1)
		sprite.hidden = true
	end

	queue_remove(store, this)
end

scripts.blackburn_part = {}

function scripts.blackburn_part.update(this, store)
	this.ui.clicked = nil
	while true do
		if this.ui.clicked then
			this.ui.clicked = nil
			local controller = this.controller_id and store.entities[this.controller_id]
			if controller then controller.parts_found = (controller.parts_found or 0) + 1 end
			S:queue("level28_blackburn_armourpieces")
			queue_remove(store, this)
			return
		end
		coroutine.yield()
	end
end

scripts.blackburn_controller = {}

function scripts.blackburn_controller.update(this, store)
	this.render.sprites[1].hidden = true
	this.parts_found = 0
	local parts = {
		{79, 352, "stage_28_axe"}, {795, 157, "stage_28_belt"}, {913, 480, "stage_28_hand"},
		{405, 553, "stage_28_helmet"}, {270, 130, "stage_28_shoulder"}
	}
	for _, cfg in ipairs(parts) do
		local p = E:create_entity("blackburn_part")
		p.pos, p.controller_id = V.v(cfg[1], cfg[2]), this.id
		p.render.sprites[1].name = cfg[3]
		queue_insert(store, p)
	end
	while this.parts_found < #parts do coroutine.yield() end
	S:queue("level28_blackburn_achievement")
	local towers = {}
	for _, tower in pairs(store.entities) do
		if tower.tower and not tower.tower_holder and not tower.tower.destroy then
			tower.tower.damage_factor = tower.tower.damage_factor * 1.5
			table.insert(towers, tower)
		end
	end
	U.y_wait(store, 5)
	for _, tower in ipairs(towers) do if store.entities[tower.id] and tower.tower then tower.tower.damage_factor = tower.tower.damage_factor / 1.5 end end
	queue_remove(store, this)
end

scripts.branch_one_shot_fx = {}

function scripts.branch_one_shot_fx.update(this, store)
	local sprite = this.render and this.render.sprites and this.render.sprites[1]

	if this.frames and sprite then
		for _, frame in ipairs(this.frames) do
			if not store.entities[this.id] then
				return
			end

			sprite.name = frame
			U.y_wait(store, this.frame_time or 0.05)
		end

		queue_remove(store, this)

		return
	end

	if sprite and sprite.animated and sprite.name then
		if this.animation_group then
			U.animation_start_group(this, sprite.name, sprite.flip_x, store.tick_ts, false, this.animation_group)
		else
			U.animation_start(this, sprite.name, sprite.flip_x, store.tick_ts, false, 1)
		end
	end

	U.y_wait(store, this.duration or 0.4)
	queue_remove(store, this)
end

function kr4_refresh_or_insert_modifier(store, source, target, mod_name)
	if not target or not target.health or target.health.dead then
		return
	end

	for _, e in pairs(store.entities) do
		if e.template_name == mod_name and e.modifier and e.modifier.target_id == target.id then
			e.modifier.ts = store.tick_ts

			return
		end
	end

	local m = E:create_entity(mod_name)
	m.modifier.source_id = source and source.id
	m.modifier.target_id = target.id

	queue_insert(store, m)
end

scripts.kr4_plant_projectile = {}

function scripts.kr4_plant_projectile.update(this, store)
	local sprite = this.render and this.render.sprites and this.render.sprites[1]
	local from = this.from or this.pos
	local to = this.to or this.pos
	local duration = this.duration or 0.45
	local height = this.height or 45
	local ts = store.tick_ts

	if sprite and sprite.animated and sprite.name then
		U.animation_start(this, sprite.name, to.x < from.x, store.tick_ts, true, 1)
	end

	while store.tick_ts - ts < duration do
		local t = km.clamp(0, 1, (store.tick_ts - ts) / duration)

		this.pos.x = from.x + (to.x - from.x) * t
		this.pos.y = from.y + (to.y - from.y) * t + math.sin(math.pi * t) * height

		coroutine.yield()
	end

	this.pos = V.vclone(to)

	if this.sound_hit then
		S:queue(this.sound_hit)
	end

	if this.hit_fx then
		local fx = E:create_entity(this.hit_fx)
		fx.pos = V.vclone(to)
		queue_insert(store, fx)
	end

	if this.pool then
		local pool = E:create_entity(this.pool)
		pool.pos = V.vclone(to)
		pool.source_id = this.source_id
		queue_insert(store, pool)
	end

	queue_remove(store, this)
end

scripts.kr4_plant_venom_pool = {}

function scripts.kr4_plant_venom_pool.update(this, store)
	local sprite = this.render and this.render.sprites and this.render.sprites[1]
	local ts = store.tick_ts
	local tick_ts = store.tick_ts - (this.tick or 0.1)
	local source = this.source_id and store.entities[this.source_id] or this

	if sprite and sprite.animated then
		U.y_animation_play(this, "in", nil, store.tick_ts, 1)
		U.animation_start(this, "run", nil, store.tick_ts, true, 1)
	end

	while store.tick_ts - ts < (this.duration or 4.5) do
		if store.tick_ts - tick_ts >= (this.tick or 0.1) then
			tick_ts = store.tick_ts

			local targets = U.find_soldiers_in_range(store.entities, this.pos, 0, this.radius or 52.5, 0, F_FLYING, kr4_valid_enemy_soldier_target)

			for _, target in ipairs(targets or {}) do
				kr4_refresh_or_insert_modifier(store, source, target, this.mod or "mod_branch_plant_venom")

				if this.slow_mod then
					kr4_refresh_or_insert_modifier(store, source, target, this.slow_mod)
				end
			end
		end

		coroutine.yield()
	end

	if sprite and sprite.animated then
		U.y_animation_play(this, "out", nil, store.tick_ts, 1)
	end

	queue_remove(store, this)
end

scripts.kr4_carnivorous_plant = {}

function scripts.kr4_carnivorous_plant.update(this, store)
	local venom_ts = store.tick_ts - this.venom.cooldown
	local teleport_ts = store.tick_ts - (this.teleport and this.teleport.cooldown or 999999)
	local sprite = this.render.sprites[1]

	U.animation_start(this, sprite.name or "idle", sprite.flip_x, store.tick_ts, true, 1)

	while true do
		if store.tick_ts - venom_ts >= this.venom.cooldown then
			local target = U.find_nearest_soldier(store.entities, this.pos, 0, this.venom.range, 0, F_FLYING, kr4_valid_enemy_soldier_target)
			if target then
				venom_ts = store.tick_ts
				U.animation_start(this, "venom", target.pos.x < this.pos.x, store.tick_ts, false, 1)
				U.y_wait(store, 0.3)

				if store.entities[this.id] and store.entities[target.id] then
					S:queue("carnivorous_plant_venom_shoot")

					local projectile = E:create_entity(this.venom.projectile or "kr4_carnivorous_plant_venom_projectile")
					local shoot_x = target.pos.x < this.pos.x and -5 or 5
					projectile.pos = V.v(this.pos.x + shoot_x, this.pos.y + 5)
					projectile.from = V.vclone(projectile.pos)
					projectile.to = V.vclone(target.pos)
					projectile.source_id = this.id
					projectile.pool = this.venom.pool or projectile.pool
					queue_insert(store, projectile)
				end

				if store.entities[this.id] then
					U.animation_start(this, "idle", sprite.flip_x, store.tick_ts, true, 1)
				end
			end
		end
		if this.teleport and not this.teleport.disabled and store.tick_ts - teleport_ts >= this.teleport.cooldown then
			local target, center, teleport_index
			local side = sprite.flip_x and -1 or 1
			local centers = this.teleport.centers_px or this.teleport.centers or {}
			local use_path_teleport = this.teleport.positions ~= nil
			local repeat_cooldown = this.teleport.repeat_cooldown or 8
			local target_filter = function(e)
				if not e.health or e.health.dead or not e.nav_path then
					return false
				end

				if e.vis and band(e.vis.flags, bor(F_BOSS, F_MINIBOSS)) ~= 0 then
					return false
				end

				return not e._kr4_plant_teleport_ts or store.tick_ts - e._kr4_plant_teleport_ts >= repeat_cooldown
			end

			for i, c in ipairs(centers) do
				local cx = c.x or c[1] or 0
				local cy = c.y or c[2] or 0
				local range = c.range or c[3] or this.teleport.range

				if this.teleport.centers_px then
					center = V.v(this.pos.x + side * cx, this.pos.y + cy)
				else
					center = V.v(this.pos.x + side * cx * 10, this.pos.y + cy * 10)
				end

				if use_path_teleport then
					target = U.find_nearest_enemy(store.entities, center, 0, range, 0, bor(F_FLYING, F_BOSS, F_MINIBOSS), target_filter)
				elseif this.teleport.target_enemies then
					target = U.find_nearest_enemy(store.entities, center, 0, range, 0, bor(F_FLYING, F_BOSS, F_MINIBOSS), target_filter)
				else
					target = U.find_nearest_soldier(store.entities, center, 0, range, 0, bor(F_FLYING, F_HERO))
				end

				if target then
					teleport_index = i
					break
				end
			end

			if target then
				teleport_ts = store.tick_ts
				U.animation_start(this, "teleIn", target.pos.x < this.pos.x, store.tick_ts, false, 1)
				U.y_wait(store, 0.25)

				if store.entities[this.id] and store.entities[target.id] then
					S:queue("carnivorous_plant_eating")

					local old_pos = V.vclone(target.pos)
					local destination = this.teleport.positions and (this.teleport.positions[teleport_index] or this.teleport.positions[1])
					local new_pos
					local old_to_exit = target.nav_path and branch_nodes_to_exit_at(target.nav_path.pi, target.nav_path.ni)
					local only_forward = this.teleport.target_enemies and this.teleport.only_forward ~= false
					local allowed_backtrack = this.teleport.allowed_backtrack or 5
					local function can_land(pi, ni)
						if not only_forward or not old_to_exit then
							return true
						end

						return branch_nodes_to_exit_at(pi, ni) <= old_to_exit + allowed_backtrack
					end

					if destination and target.nav_path then
						local pi = branch_normalize_path_index(destination.path)
						local spi = target.nav_path.spi or 1
						local ni = destination.node or target.nav_path.ni

						if not P.paths[pi] then
							pi = target.nav_path.pi
						end

						if P.paths[pi] and not P.paths[pi][spi] then
							spi = 1
						end

						ni = branch_clamp_path_node(pi, ni)
						if can_land(pi, ni) then
							new_pos = V.vclone(P:node_pos(pi, spi, ni))
							U.unblock_all(store, target)
							target.nav_path.pi = pi
							target.nav_path.spi = spi
							target.nav_path.dir = branch_path_dir(pi)
							target.nav_path.ni = ni
						end
					else
						local dx = math.abs(old_pos.x - this.pos.x)
						local mirrored_pos = V.v(this.pos.x - side * dx, old_pos.y)

						if this.teleport.target_enemies and target.nav_path then
							local nodes = P:nearest_nodes(mirrored_pos.x, mirrored_pos.y, nil, nil, true)

							for _, node in ipairs(nodes or {}) do
								local pi, spi, ni = node[1], node[2], node[3]

								if P.paths[pi] and P.paths[pi][spi] then
									ni = branch_clamp_path_node(pi, ni)
									if can_land(pi, ni) then
										U.unblock_all(store, target)
										target.nav_path.pi = pi
										target.nav_path.spi = spi
										target.nav_path.dir = branch_path_dir(pi)
										target.nav_path.ni = ni
										new_pos = V.vclone(P:node_pos(pi, spi, target.nav_path.ni))
										break
									end
								end
							end
						else
							new_pos = mirrored_pos
						end
					end

					if new_pos then
						local spit = E:create_entity("kr4_carnivorous_plant_spit_projectile")

						spit.pos = V.v(this.pos.x - side * 10, this.pos.y + 45)
						spit.from = V.vclone(spit.pos)
						spit.to = V.vclone(new_pos)
						queue_insert(store, spit)

						target._kr4_plant_teleport_ts = store.tick_ts
						target.pos = new_pos
						SU.stun_inc(target)
						U.y_wait(store, this.teleport.sickness or 1.5)

						if store.entities[target.id] then
							SU.stun_dec(target)
						end
					end
				end

				if store.entities[this.id] then
					S:queue("carnivorous_plant_throw")
					U.y_animation_play(this, "teleOut", target.pos.x < this.pos.x, store.tick_ts, 1)
					U.animation_start(this, "idle", sprite.flip_x, store.tick_ts, true, 1)
				end
			end
		end
		coroutine.yield()
	end
end

scripts.stage36_crowd = {}

function scripts.stage36_crowd.update(this, store)
	local prefix
	if this.pos.y < 200 then
		prefix = this.pos.x < 512 and "croud_HM_down" or "croud_vez_down"
	elseif this.pos.x < 512 then
		prefix = this.pos.x < 270 and "croud_HM_left" or "croud_HM_right"
	else
		prefix = this.pos.x < 760 and "croud_vez_left" or "croud_vez_right"
	end
	this.render.sprites[1].prefix = prefix
	U.animation_start(this, "run", nil, store.tick_ts, true)
	while true do coroutine.yield() end
end

scripts.stage36_malik_throne = {}

function scripts.stage36_malik_throne.update(this, store)
	-- The chair is scenery, not a moving part of Malik's exit animation.
	local chair = E:create_entity("decal")
	chair.pos = V.vclone(this.pos)
	chair.render.sprites[1] = table.deepclone(this.render.sprites[1])
	queue_insert(store, chair)
	this.render.sprites[1].hidden = true

	local function play(animation, loop, force_ts)
		for i = 2, #this.render.sprites do
			U.animation_start(this, animation, nil, store.tick_ts, loop, i, force_ts)
		end
	end

	local function wait(seconds, interruptible)
		local until_ts = store.tick_ts + seconds
		while store.tick_ts < until_ts do
			if interruptible and this.exit then MP.clear(this, store); return false end
			coroutine.yield()
		end
		return true
	end
	local function talk(kind, index, interruptible)
		play("sitTauntIn", false, true)
		if not wait(fts(6), interruptible) then return false end
		play("sitTauntLoop", true, true)
		MP.say(this, store, kind, index, 4)
		if not wait(4, interruptible) then return false end
		MP.clear(this, store)
		play("sitTauntEnd", false, true)
		if not wait(fts(13), interruptible) then return false end
		play("sitIdle", true, true)
		return true
	end

	play("sitIdle", true, true)
	if wait(1, true) then
		for i = 1, 2 do if not talk("INTRO", i, true) then break end end
	end
	local next_taunt_ts = store.tick_ts + math.random(12, 18)
	local taunt = 1
	while not this.exit do
		if store.tick_ts >= next_taunt_ts then
			if not talk("BATTLE", taunt, true) then break end
			local laugh = taunt % 2 == 1
			S:queue(laugh and "malik_sitted_taunt_laught" or "malik_sitted_taunt_bolt")
			play(laugh and "sitLaugh" or "sitAngry", false, true)
			if not wait(fts(laugh and 69 or 56), true) then break end
			play("sitIdle", true, true)
			taunt = taunt % 5 + 1
			next_taunt_ts = store.tick_ts + math.random(12, 18)
		end
		coroutine.yield()
	end
	MP.clear(this, store)
	if this.exit_sound then S:queue(this.exit_sound) end
	for i = 1, 2 do talk("PRE_FIGHT", i, false) end
	MP.clear(this, store)

	play(this.exit_animation or "sitJump", false, true)

	local start_pos = V.vclone(this.pos)
	local destination = this.exit_destination or start_pos
	local jump_ts = store.tick_ts
	-- Vengeance sitJump has 57 frames (180..236). Movement starts after
	-- the 28-frame seated preparation and ends at the landing frames.
	while not U.animation_finished(this, 2) and store.tick_ts - jump_ts < fts(57) + 0.25 do
		local phase = math.max(0, math.min(1, (store.tick_ts - jump_ts - fts(28)) / fts(19)))
		this.pos.x = start_pos.x + (destination.x - start_pos.x) * phase
		this.pos.y = start_pos.y + (destination.y - start_pos.y) * phase + math.sin(math.pi * phase) * 60
		coroutine.yield()
	end
	this.pos = V.vclone(destination)

	this.exit_done = true
	queue_remove(store, this)
end

scripts.branch_looping_decal = {}

function scripts.branch_looping_decal.update(this, store)
	local sprite = this.render.sprites[1]

	if this.exo_prefix then
		sprite.prefix = this.exo_prefix
	end

	if this.scale then
		sprite.scale = V.v(this.scale, this.scale)
	end

	if this.flipped_x ~= nil then
		sprite.flip_x = this.flipped_x
	end

	if this.y_position_adjust then
		sprite.offset = sprite.offset or V.v(0, 0)
		sprite.offset.y = this.y_position_adjust
	end

	local idle = this.idle_animation or sprite.name or "idle"

	U.animation_start(this, idle, sprite.flip_x, store.tick_ts, true)

	while true do
		local variants = this.loop_variants

		if variants and #variants > 0 then
			local cfg = variants[math.random(1, #variants)]
			local min_cooldown = cfg.min_cooldown or 1
			local max_cooldown = cfg.max_cooldown or min_cooldown

			U.animation_start(this, cfg.animation_idle or idle, sprite.flip_x, store.tick_ts, true)
			U.y_wait(store, U.frandom(min_cooldown, max_cooldown))
			U.animation_start(this, cfg.animation_end or idle, sprite.flip_x, store.tick_ts, false)
			U.y_animation_wait(this)
			U.animation_start(this, idle, sprite.flip_x, store.tick_ts, true)
		end

		coroutine.yield()
	end
end

scripts.shatra = {}

local function stage184_shatra_set_hidden(this, hidden)
	if not this.render or not this.render.sprites then
		return
	end

	for _, s in ipairs(this.render.sprites) do
		s.hidden = hidden
	end
end

local function stage184_shatra_spawn_tower_hit_fx(store, pos)
	if not pos then
		return
	end

	local dust = E:create_entity("fx_tower_sell_dust")
	dust.pos.x, dust.pos.y = pos.x, pos.y + 35
	dust.render.sprites[1].ts = store.tick_ts
	queue_insert(store, dust)

	local explosion = E:create_entity("fx_explosion_small")
	explosion.pos.x, explosion.pos.y = pos.x, pos.y + 45
	explosion.render.sprites[1].ts = store.tick_ts
	queue_insert(store, explosion)
end

local function stage184_shatra_play_action(this, store, hit_delay, hit_fn)
	U.animation_start(this, "action", nil, store.tick_ts, true)

	local duration = this.action_loop_duration or 5

	if hit_fn and hit_delay and hit_delay > 0 and hit_delay < duration then
		U.y_wait(store, hit_delay)

		if store.entities[this.id] and not this.pending_removal then
			hit_fn()
		end

		U.y_wait(store, duration - hit_delay)
	else
		U.y_wait(store, duration)

		if hit_fn and store.entities[this.id] and not this.pending_removal then
			hit_fn()
		end
	end

	if store.entities[this.id] and not this.pending_removal then
		U.animation_start(this, "idleFight", nil, store.tick_ts, true)
	end
end

local function stage184_shatra_spawn_ship_fx(store, template_name, pos)
	if not template_name or not pos then
		return
	end

	return branch_spawn_scene(store, template_name, pos.x, pos.y + 100)
end

local function stage184_shatra_tower_allowed(this, tower)
	if not tower or not tower.tower or tower.tower.destroy or tower.pending_removal then
		return false
	end

	local excludes = this.omegaray and this.omegaray.excludes or {}

	return not excludes[tower.template_name]
end

local function stage184_shatra_find_tower_target(this, store)
	local cfg = this.omegaray or {}
	local radius = cfg.tower_radius or 72

	for _, region in ipairs(cfg.towers or {}) do
		local best, best_dist

		for _, pos in ipairs(region) do
			for _, tower in ipairs(branch_find_towers(store, pos, radius) or {}) do
				if stage184_shatra_tower_allowed(this, tower) then
					local dist = V.dist(pos.x, pos.y, tower.pos.x, tower.pos.y)

					if not best_dist or dist < best_dist then
						best = tower
						best_dist = dist
					end
				end
			end
		end

		if best then
			return best
		end
	end

	return nil
end

local function stage184_shatra_valid_abduction_target(soldier)
	return soldier and soldier.soldier and soldier.pos and soldier.health and not soldier.health.dead and not kr4_is_air_support_soldier(soldier)
end

local function stage184_shatra_find_abduction_targets(this, store)
	local cfg = this.abduction or {}
	local crowd_range = cfg.crowd_range or 140
	local kill_radius = cfg.kill_radius or 120
	local min_targets = cfg.min_targets or 2
	local candidates = {}
	local soldiers = U.find_soldiers_in_range(store.entities, this.pos, 0, 9999, 0, F_FLYING, stage184_shatra_valid_abduction_target)

	for _, soldier in ipairs(soldiers or {}) do
		local crowd = U.find_soldiers_in_range(store.entities, soldier.pos, 0, crowd_range, 0, F_FLYING, stage184_shatra_valid_abduction_target)

		if crowd and #crowd >= min_targets then
			table.insert(candidates, V.vclone(soldier.pos))
		end
	end

	if #candidates == 0 then
		return nil, nil
	end

	local pos = candidates[math.random(1, #candidates)]
	local targets = U.find_soldiers_in_range(store.entities, pos, 0, kill_radius, 0, F_FLYING, stage184_shatra_valid_abduction_target)

	if not targets or #targets == 0 then
		return nil, nil
	end

	return pos, targets
end

function scripts.shatra.update(this, store)
	stage184_shatra_set_hidden(this, true)

	while (store.wave_group_number or 0) < (this.wave_start or 15) do
		coroutine.yield()
	end

	stage184_shatra_set_hidden(this, false)
	if this.sound_events and this.sound_events.spawn then S:queue(this.sound_events.spawn) end
	U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)
	U.animation_start(this, "idleFight", nil, store.tick_ts, true)

	local ray = this.omegaray or {}
	local abduction = this.abduction or {}
	local tower_ts = store.tick_ts - ((ray.cooldown or 20) - (ray.cooldown_wait or 5))
	local soldier_ts = store.tick_ts

	while not store.waves_finished or LU.has_alive_enemies(store) do
		if store.tick_ts - tower_ts >= (ray.cooldown or 20) then
			tower_ts = store.tick_ts
			local tower = stage184_shatra_find_tower_target(this, store)

			if tower then
				if this.sound_events and this.sound_events.deathray then S:queue(this.sound_events.deathray) end
				stage184_shatra_spawn_ship_fx(store, ray.fx, tower.pos)
				stage184_shatra_play_action(this, store, ray.destroy_delay, function()
					if store.entities[tower.id] and tower.tower and not tower.tower.destroy then
						stage184_shatra_spawn_tower_hit_fx(store, tower.pos)
						tower.tower.destroy = true
					end
				end)
			end
		end

		if store.tick_ts - soldier_ts >= (abduction.cooldown or 15) then
			soldier_ts = store.tick_ts
			local pos, soldiers = stage184_shatra_find_abduction_targets(this, store)

			if pos and soldiers and #soldiers > 0 then
				if this.sound_events and this.sound_events.abduction then S:queue(this.sound_events.abduction) end
				stage184_shatra_spawn_ship_fx(store, abduction.fx, pos)
				stage184_shatra_play_action(this, store)
				for i = 1, math.min(abduction.max_targets or 3, #soldiers) do
					local soldier = soldiers[i]
					if store.entities[soldier.id] and soldier.health and not soldier.health.dead then
						branch_damage(store, this, soldier, (soldier.health.hp or 0) + (soldier.health.hp_max or 0), bor(DAMAGE_TRUE, DAMAGE_INSTAKILL, DAMAGE_NO_SPAWNS, DAMAGE_NO_DODGE))
					end
				end
			end
		end

		coroutine.yield()
	end

	if this.sound_events and this.sound_events.death then S:queue(this.sound_events.death) end
	stage184_shatra_spawn_ship_fx(store, abduction.fx, this.pos)
	U.y_animation_play(this, "actionDeath", nil, store.tick_ts, 1)
	queue_remove(store, this)
end

scripts.sarcophagus = {}

function scripts.sarcophagus.update(this, store)
	if this.ui then
		this.ui.clicked = nil
	end

	while true do
		local activated = false

		if this.ui and this.ui.clicked then
			this.ui.clicked = nil
			activated = this.direct_activate ~= false
		end

		if this.user_selection and (this.user_selection.in_progress or this.user_selection.arg) then
			this.user_selection.in_progress = nil
			this.user_selection.arg = nil
			activated = true
		end

		if activated then
			local cost = this.cost or (this.template_name == "sarcophagus_2" and 35 or 120)
			local ready_ts = this.next_ready_ts or -1e+99

			if store.tick_ts >= ready_ts and not this.spawning and store.player_gold >= cost then
				this.spawning = true
				this.next_ready_ts = store.tick_ts + (this.cooldown or 13.5)
				store.player_gold = store.player_gold - cost
				U.animation_start(this, "open", nil, store.tick_ts, false, 1)
				U.animation_start(this, "open", nil, store.tick_ts, false, 2)
				local nodes = P:nearest_nodes(this.pos.x, this.pos.y + (this.spawn_path_y_offset or 80), nil, nil, true) or P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)
				local pi, spi, ni = 1, 1, P:get_start_node(1)

				if nodes and nodes[1] then
					pi, spi, ni = nodes[1][1], nodes[1][2], nodes[1][3]
				end

				local spawn_count = this.spawn_count or 5

				for i = 1, spawn_count do
					U.y_wait(store, this.spawn_interval or 2.7)

					if not store.entities[this.id] then
						return
					end

					local spawn_ni = branch_clamp_path_node(pi, ni + ((i - 1) % 3))
					local spawn_pos = V.vclone(P:node_pos(pi, spi, spawn_ni))
					local mummy = E:create_entity(this.spawn_template or "stage34_sarcophagus_mummy")

					mummy.pos = V.vclone(spawn_pos)
					if mummy.nav_path then
						mummy.nav_path.pi = pi
						mummy.nav_path.spi = spi
						mummy.nav_path.ni = spawn_ni
						mummy.nav_path.dir = -1
					end
					if mummy.nav_rally then
						mummy.nav_rally.center = V.vclone(spawn_pos)
						mummy.nav_rally.pos = V.vclone(spawn_pos)
					end
					if mummy.ui then
						mummy.ui.can_click = true
						mummy.ui.can_select = true
					end
					queue_insert(store, mummy)
				end

				U.animation_start(this, "close", nil, store.tick_ts, false, 1)
				U.animation_start(this, "close", nil, store.tick_ts, false, 2)
				this.spawning = nil
			end
		end
		coroutine.yield()
	end
end

scripts.hammerhold_archer = {}

function scripts.hammerhold_archer.update(this, store)
	local ts = store.tick_ts - this.attack.cooldown
	local end_ts = this.lifetime and store.tick_ts + this.lifetime

	if this.roof_archer then
		S:queue("roof_archer_spawn")
		U.y_animation_play(this, "spawn", nil, store.tick_ts, 1)
		U.animation_start(this, "idleRight", nil, store.tick_ts, true, 1)
	end

	while true do
		if end_ts and store.tick_ts >= end_ts then
			if this.roof_archer then
				S:queue("roof_archer_out")
				U.y_animation_play(this, "out", nil, store.tick_ts, 1)
			end
			queue_remove(store, this)
			return
		end

		if store.tick_ts - ts >= this.attack.cooldown then
			local target = U.find_nearest_soldier(store.entities, this.pos, this.attack.min_range, this.attack.max_range, 0, F_FLYING, kr4_valid_enemy_soldier_target)
			if target then
				ts = store.tick_ts
				local anim, idle
				if this.roof_archer then
					local upper = target.pos.y < this.pos.y
					local left = target.pos.x < this.pos.x
					anim = (upper and "shootUp" or "shootDown") .. (left and "Left" or "Right")
					idle = upper and (left and "idleUpLeft" or "idleUp") or (left and "idleLeft" or "idleRight")
				else
					anim = target.pos.y > this.pos.y and "shootUp" or "shootDown"
					idle = target.pos.y > this.pos.y and "idleUp" or "idle"
				end
				local sid = this.roof_archer and 1 or 2
				U.animation_start(this, anim, target.pos.x < this.pos.x, store.tick_ts, false, sid)
				U.y_wait(store, this.attack.hit_time or 0.25)
				branch_damage(store, this, target, math.random(this.attack.damage_min, this.attack.damage_max), DAMAGE_PHYSICAL)
				if store.entities[this.id] then
					U.animation_start(this, idle, target.pos.x < this.pos.x, store.tick_ts, true, sid)
				end
			end
		end
		coroutine.yield()
	end
end

scripts.hammerhold_barrack = {}

function scripts.hammerhold_barrack.update(this, store)
	local ts = store.tick_ts - this.cooldown
	while true do
		if store.waves_finished then
			for _, e in pairs(store.entities) do
				if e.owner_id == this.id and e.health and not e.health.dead then
					e.health.last_damage_types = DAMAGE_NO_SPAWNS
					e.health.hp = 0
					e.health.dead = true
				end
			end

			queue_remove(store, this)
			return
		end

		while this.start_wave and (store.wave_group_number or 0) < this.start_wave do
			if store.waves_finished then
				queue_remove(store, this)
				return
			end
			coroutine.yield()
		end

		if store.tick_ts - ts >= this.cooldown then
			ts = store.tick_ts
			U.animation_start(this, "open", nil, store.tick_ts, false, 1)
			U.animation_start(this, "open", nil, store.tick_ts, false, 2)
			U.y_wait(store, 0.45)
			local nodes = P:nearest_nodes(this.pos.x, this.pos.y, nil, nil, true)
			if nodes and nodes[1] then
				local soldier = branch_spawn_on_path(store, "enemy_legionnaire", nil, -1, nodes[1][1], nodes[1][2], nodes[1][3])
				if soldier then
					soldier.owner_id = this.id
					soldier.pos = V.vclone(this.pos)
				end
			end
			if store.entities[this.id] then
				U.animation_start(this, "close", nil, store.tick_ts, false, 1)
				U.animation_start(this, "close", nil, store.tick_ts, false, 2)
			end
		end
		coroutine.yield()
	end
end

scripts.veznan_ship_cannon = {}

function scripts.veznan_ship_cannon.update(this, store)
	this.ui.can_click = true
	this.ui.clicked = nil
	this.shots = 0
	this.costs = this.costs or {200, 250, 300}
	while this.shots < #this.costs do
		if this.ui.clicked then
			this.ui.clicked = nil
			local cost = this.costs[this.shots + 1] or 200
			if store.player_gold >= cost then
				store.player_gold = store.player_gold - cost
				this.shots = this.shots + 1
				U.animation_start(this, "run", nil, store.tick_ts, false)
				local targets = table.filter(store.entities, function(_, e) return e.template_name == "hammerhold_archer" or string.find(e.template_name or "", "hammerhold_barrack", 1, true) end)
				if #targets > 0 then queue_remove(store, targets[1]) end
				U.y_wait(store, 1)
				if store.entities[this.id] then U.animation_start(this, "idle", nil, store.tick_ts, true) end
			end
		end
		coroutine.yield()
	end
	this.ui.can_click = false
	while true do coroutine.yield() end
end

scripts.stage10_tower_ice_block = {}

function stage10_tower_ice_release(this, store, target)
	if this._click_proxy and target then
		SU.ui_click_proxy_remove(target, this)
		this._click_proxy = nil
	end

	if this._tower_blocked and target and store.entities[target.id] then
		SU.tower_block_dec(target)
	end

	this._tower_blocked = nil
	this.ui.can_click = false
end

function scripts.stage10_tower_ice_block.update(this, store)
	local target = store.entities[this.target_id]

	if not target or not target.tower or target.tower_holder then
		queue_remove(store, this)

		return
	end

	this.pos.x = target.pos.x
	this.pos.y = target.pos.y + (this.y_offset or 20)
	this.ui.clicked = nil

	SU.tower_block_inc(target)
	this._tower_blocked = true
	SU.ui_click_proxy_add(target, this)
	this._click_proxy = true

	for sid = 1, 2 do
		U.animation_start(this, "start", nil, store.tick_ts, false, sid)
	end

	U.y_wait(store, this.unblock_delay or 0.33, function()
		return not store.entities[target.id]
	end)

	if not store.entities[target.id] then
		stage10_tower_ice_release(this, store, target)
		queue_remove(store, this)

		return
	end

	for sid = 1, 2 do
		U.animation_start(this, "idle", nil, store.tick_ts, true, sid)
	end

	local clicks = 0
	local ts = store.tick_ts
	local required_clicks = this.required_clicks or 3

	while store.entities[target.id] and clicks < required_clicks and store.tick_ts - ts < (this.duration or 4) do
		this.pos.x = target.pos.x
		this.pos.y = target.pos.y + (this.y_offset or 20)

		if this.ui.clicked then
			this.ui.clicked = nil
			clicks = clicks + 1

			if this.tap_fx then
				local fx = E:create_entity(this.tap_fx)
				fx.pos = V.v(this.pos.x, this.pos.y + 2)
				queue_insert(store, fx)
			end
		end

		coroutine.yield()
	end

	if this.sound_events and this.sound_events.remove then
		S:queue(this.sound_events.remove)
	end

	for sid = 1, 2 do
		U.animation_start(this, "end", nil, store.tick_ts, false, sid)
	end

	stage10_tower_ice_release(this, store, target)
	U.y_wait(store, 0.25)
	queue_remove(store, this)
end

function stage10_has_tower_ice(store, tower)
	for _, e in pairs(store.entities) do
		if e.template_name == "stage10_tower_ice_block" and e.target_id == tower.id then
			return true
		end
	end

	return false
end

function stage10_valid_tower_target(e)
	return e and e.tower and e.ui and not e.tower_holder and e.pos and e.tower.can_be_mod ~= false and e.tower.type ~= "build_animation" and not e.tower.blocked
end

function stage10_freeze_towers(store, amount, duration, template)
	local targets = {}

	for _, e in pairs(store.entities) do
		if stage10_valid_tower_target(e) and not stage10_has_tower_ice(store, e) then
			table.insert(targets, e)
		end
	end

	for i = #targets, 2, -1 do
		local j = math.random(i)
		targets[i], targets[j] = targets[j], targets[i]
	end

	for i = 1, math.min(amount or 3, #targets) do
		local target = targets[i]
		local ice = E:create_entity(template or "stage10_tower_ice_block")
		ice.target_id = target.id
		ice.duration = duration or ice.duration
		ice.pos = V.v(target.pos.x, target.pos.y + (ice.y_offset or 20))
		queue_insert(store, ice)
	end
end

scripts.snow_storm = {}

local function zeta_storm_freeze_soldiers(this, store)
	local targets = U.find_soldiers_in_range(store.entities, V.v(512, 384), 0, 2000, 0, F_FLYING,
		kr4_valid_enemy_soldier_target) or {}

	zeta_shuffle_targets(targets)

	for i = 1, math.min(this.units_amount or 0, #targets) do
		local target = targets[i]
		local mod = E:create_entity(this.unit_modifier or "mod_branch_freeze")

		mod.modifier.source_id = this.id
		mod.modifier.target_id = target.id
		mod.modifier.duration = this.unit_freeze_duration or 4
		queue_insert(store, mod)
	end
end

local function zeta_storm_speed_enemies(this, store)
	local targets = U.find_enemies_in_range(store.entities, V.v(512, 384), 0, 2000, 0, 0) or {}

	zeta_shuffle_targets(targets)

	for i = 1, math.min(this.units_amount or 0, #targets) do
		local target = targets[i]
		local mod = E:create_entity("mod_branch_damage")

		mod.modifier.source_id = this.id
		mod.modifier.target_id = target.id
		mod.modifier.duration = this.unit_speed_duration or 2.5
		mod.speed_factor = this.unit_speed_factor or 1.8
		mod.damage_factor = nil
		queue_insert(store, mod)
	end
end

function scripts.snow_storm.update(this, store)
	local duration = this.duration or 15
	local start_ts = store.tick_ts
	local next_modifier_ts = start_ts
	local modifier_interval = this.time_add_modifier or this.modifier_interval or 15
	local particles

	if this.sound_events and this.sound_events.insert then
		S:queue(this.sound_events.insert)
	end

	if this.particle_name then
		particles = E:create_entity(this.particle_name)
		particles.pos = V.v(this.pos.x, this.pos.y)

		if this.particle_emission_rate and particles.particle_system then
			particles.particle_system.emission_rate = this.particle_emission_rate
		end

		queue_insert(store, particles)
	end

	while store.tick_ts - start_ts < duration do
		if store.tick_ts >= next_modifier_ts then
			if this.army == 0 then
				zeta_storm_speed_enemies(this, store)
			else
				stage10_freeze_towers(store, this.towers_amount or 3, this.tower_block_duration or 4,
					this.tower_block_template)

				if this.army == 1 then
					zeta_storm_freeze_soldiers(this, store)
				end
			end

			next_modifier_ts = next_modifier_ts + modifier_interval
		end

		coroutine.yield()
	end

	if particles and store.entities[particles.id] then
		queue_remove(store, particles)
	end

	queue_remove(store, this)
end

local branch_stage10_blizzard_schedules = {
	[GAME_MODE_CAMPAIGN] = {
		{wave = 2, delay = 0, duration = 15},
		{wave = 6, delay = 0, duration = 15},
		{wave = 9, delay = 0, duration = 40},
		{wave = 12, delay = 0, duration = 15},
		{wave = 14, delay = 0, duration = 15},
		{wave = 15, delay = 0, duration = 30},
		{wave = 15, delay = 30, duration = 15}
	},
	[GAME_MODE_HEROIC] = {
		{wave = 3, delay = 0, duration = 40},
		{wave = 4, delay = 0, duration = 15},
		{wave = 4, delay = 15, duration = 15},
		{wave = 5, delay = 0, duration = 15},
		{wave = 5, delay = 15, duration = 15},
		{wave = 6, delay = 0, duration = 15},
		{wave = 6, delay = 15, duration = 15},
		{wave = 6, delay = 30, duration = 15},
		{wave = 6, delay = 45, duration = 40}
	},
	[GAME_MODE_IRON] = {
		{wave = 1, delay = 0, duration = 800, towers_amount = 50, tower_block_duration = 20, time_add_modifier = 400, emission_rate = 300}
	}
}

local branch_stage12_farm_schedules = {
	[GAME_MODE_CAMPAIGN] = {
		{wave = 4, delay = 16, path = 4, x = 140, y = 309, interval = 1.5, units = {"enemy_farmer_bucket", "enemy_farmer_bucket", "enemy_farmer_rake", "enemy_farmer_scythe"}},
		{wave = 6, delay = 14, path = 4, x = 140, y = 309, interval = 1.5, units = {"enemy_farmer_bucket", "enemy_farmer_rooster", "enemy_farmer_rake", "enemy_farmer_rooster", "enemy_farmer_rooster"}},
		{wave = 6, delay = 32, path = 4, x = 140, y = 309, interval = 1.5, units = {"enemy_farmer_bucket", "enemy_farmer_rake", "enemy_farmer_rake", "enemy_farmer_rake", "enemy_farmer_bucket", "enemy_farmer_rooster", "enemy_farmer_rooster"}},
		{wave = 8, delay = 24, path = 3, x = 464, y = 580, interval = 1, units = {"enemy_farmer_bucket", "enemy_farmer_rake"}},
		{wave = 8, delay = 26, path = 3, x = 572, y = 577, interval = 1, units = {"enemy_farmer_scythe", "enemy_farmer_mile"}},
		{wave = 11, delay = 14, path = 4, x = 140, y = 309, interval = 1.5, units = {"enemy_farmer_bucket", "enemy_farmer_rooster", "enemy_farmer_rake", "enemy_farmer_rooster", "enemy_farmer_mile"}},
		{wave = 11, delay = 34, path = 3, x = 464, y = 580, interval = 1, units = {"enemy_farmer_bucket", "enemy_farmer_rooster"}},
		{wave = 11, delay = 30, path = 3, x = 572, y = 577, interval = 1, units = {"enemy_farmer_scythe", "enemy_farmer_mile"}},
		{wave = 14, delay = 14, path = 4, x = 140, y = 309, interval = 1.5, units = {"enemy_farmer_bucket", "enemy_farmer_rooster", "enemy_farmer_rake", "enemy_farmer_rooster", "enemy_farmer_mile"}},
		{wave = 14, delay = 15, path = 3, x = 464, y = 580, interval = 1, units = {"enemy_farmer_bucket", "enemy_farmer_rooster"}},
		{wave = 14, delay = 2, path = 3, x = 572, y = 577, interval = 1, units = {"enemy_farmer_scythe", "enemy_farmer_mile"}}
	},
	[GAME_MODE_HEROIC] = {
		{wave = 2, delay = 10, path = 3, x = 464, y = 580, interval = 1.5, units = {"enemy_farmer_bucket", "enemy_farmer_bucket", "enemy_farmer_rake", "enemy_farmer_scythe"}},
		{wave = 3, delay = 10, path = 3, x = 464, y = 580, interval = 1.5, units = {"enemy_farmer_bucket", "enemy_farmer_rake", "enemy_farmer_rake", "enemy_farmer_rake", "enemy_farmer_mile"}},
		{wave = 4, delay = 10, path = 4, x = 140, y = 309, interval = 1.5, units = {"enemy_farmer_bucket", "enemy_farmer_rake", "enemy_farmer_bucket", "enemy_farmer_rake", "enemy_farmer_scythe"}}
	}
}

local branch_ice_schedules = {
	[170] = {
		[GAME_MODE_CAMPAIGN] = {{14,6,20,200,1,0,50,10},{15,15,10,200,1,0,50,10},{16,14,10,200,3,0,75,10},{17,14,20,200,2,0,100,10},{18,6,25,200,2,0,100,10},{19,10,22,200,1,0,112,10},{20,15,20,200,3,0,120,10},{21,15,15,200,3,0,50,10},{22,10,15,200,3,0,70,10},{23,3,5,200,3,0,25,10}},
		[GAME_MODE_HEROIC] = {{14,3,20,200,1,0,50,10},{15,5,5,200,1,0,50,10},{16,4,10,200,3,0,75,10},{17,5,10,200,2,0,100,10},{18,5,15,200,2,0,100,10},{19,4,22,200,1,0,112,10},{20,6,20,200,3,0,120,10},{21,6,15,200,3,0,50,10},{22,6,15,200,3,0,70,10},{23,3,5,200,3,0,25,10}}
	},
	[171] = {
		[GAME_MODE_CAMPAIGN] = {{18,3,27,200,3,0,25,10},{17,6,22,200,3,0,50,10},{27,6,37,200,1,0,65,10},{22,10,25,200,3,0,90,10},{24,10,10,200,2,0,50,10},{26,12,25,200,0,0,60,10},{20,12,30,200,3,0,105,10},{25,14,35,200,0,0,75,10},{21,14,25,200,3,0,110,10},{23,15,30,200,3,0,100,10},{16,15,20,200,3,0,50,10},{19,15,15,200,2,0,100,10}},
		[GAME_MODE_HEROIC] = {{18,1,20,200,3,0,25,10},{17,2,25,200,3,0,50,10},{27,3,27,200,2,0,65,10},{22,3,20,200,3,0,90,10},{24,4,7,200,2,0,50,10},{26,4,25,200,0,0,60,10},{20,5,30,200,3,0,105,10},{25,5,35,200,0,0,75,10},{21,5,25,200,3,0,110,10},{23,6,30,200,3,0,100,10},{16,6,20,200,3,0,50,10},{19,6,15,200,2,0,100,10}}
	},
	[172] = {
		[GAME_MODE_CAMPAIGN] = {{16,6,5,200,4,0,30,10},{17,3,65,200,4,0,20,10},{18,10,25,200,4,0,60,10},{19,15,17,200,4,0,80,10},{20,14,15,200,4,0,100,10},{21,6,15,200,2,0,90,10},{22,14,10,200,2,0,100,10},{23,15,20,200,2,0,110,10},{24,14,5,200,1,0,50,10},{25,15,10,200,4,0,60,10},{26,10,5,200,1,0,60,10}},
		[GAME_MODE_HEROIC] = {{16,2,5,200,4,0,30,10},{17,2,35,200,4,0,20,10},{18,3,25,200,4,0,60,10},{19,4,17,200,4,0,80,10},{20,5,15,200,4,0,100,10},{21,3,15,200,2,0,90,10},{22,5,10,200,2,0,100,10},{23,6,20,200,2,0,110,10},{24,4,5,200,1,0,50,10},{25,6,10,200,4,0,60,10},{26,6,5,200,1,0,60,10}}
	},
	[193] = {
		[GAME_MODE_CAMPAIGN] = {{16,6,20,200,4,0,66,10},{17,15,10,200,4,0,96,10},{18,14,10,200,1,0,190,10},{19,14,20,200,0,0,186,10},{20,6,25,200,1,0,178,10},{21,10,22,200,2,0,74,10},{22,11,20,200,5,0,212,10},{23,15,15,200,3,0,45,10},{24,10,15,200,0,0,50,10}},
		[GAME_MODE_HEROIC] = {{16,1,15,150,4,0,66,10},{17,2,15,150,4,0,96,10},{18,4,10,150,1,0,190,10},{19,5,10,150,0,0,186,10},{20,5,20,150,1,0,178,10},{21,4,22,150,2,0,74,10},{22,6,20,150,5,0,212,10},{23,6,15,150,3,0,45,10},{24,6,20,150,0,0,50,10}},
		[GAME_MODE_IRON] = {{15,3,25,100,1,0,75,5},{16,5,5,100,1,0,75,5},{17,4,15,100,3,0,100,5},{19,5,20,100,2,0,125,5},{20,4,27,100,1,0,137,5},{21,6,25,100,3,0,145,5},{22,6,20,100,3,0,75,5},{23,6,20,100,3,0,95,5},{24,3,5,100,3,0,50,5}}
	},
	[194] = {
		[GAME_MODE_CAMPAIGN] = {{18,6,1,200,0,0,70,10},{19,15,5,200,4,0,44,10},{20,11,10,200,1,1,114,10},{21,6,20,200,0,0,163,10},{22,14,30,200,2,0,128,10},{23,9,5,200,2,0,48,10},{24,14,15,200,2,0,96,10},{25,15,10,200,3,0,131,10},{26,11,30,200,1,1,286,10},{27,15,30,200,1,0,308,10}},
		[GAME_MODE_HEROIC] = {{18,4,40,100,0,0,70,10},{19,6,1,100,4,0,44,10},{20,2,30,100,1,1,114,10},{21,2,23,100,0,0,163,10},{22,4,30,100,2,0,128,10},{23,1,2,100,2,0,48,10},{24,6,30,100,2,0,96,10},{25,3,37,100,3,0,131,10},{26,2,1,100,1,1,285,10},{27,6,1,100,1,0,308,10}},
		[GAME_MODE_IRON] = {{18,3,32,200,3,0,50,5},{19,6,30,200,3,0,75,5},{20,6,32,200,2,0,90,5},{21,10,25,200,3,0,115,5},{22,10,12,200,2,0,75,5},{23,12,30,200,0,0,60,5},{24,12,35,200,3,0,130,5},{25,14,40,200,0,0,75,5},{26,14,30,200,3,0,135,5},{27,15,35,200,3,0,125,5}}
	},
	[195] = {
		[GAME_MODE_CAMPAIGN] = {{17,6,35,200,4,0,79,10},{18,3,44,200,0,0,37,10},{19,9,2,200,5,0,25,10},{20,9,20,200,2,0,65,10},{21,13,15,200,7,0,11,10},{22,6,5,200,0,0,71,10},{23,12,10,200,0,0,95,10},{24,15,20,200,5,0,158,10},{25,15,5,200,4,0,54,10},{26,16,1,4444,3,2,2,0.1},{27,16,1,4444,3,1,2,0.1}},
		[GAME_MODE_HEROIC] = {{17,8,35,100,4,0,79,10},{18,5,30,100,0,0,37,10},{19,7,25,100,5,0,25,10},{20,8,2,100,2,0,65,10},{21,7,5,100,7,0,11,10},{22,8,15,100,0,0,71,10},{23,9,10,100,0,0,95,10},{24,10,50,100,5,0,158,10},{25,10,5,100,4,0,54,10},{26,9,1,100,3,2,2,10},{27,6,5,100,3,1,2,10}},
		[GAME_MODE_IRON] = {{17,2,10,100,4,0,55,5},{18,2,40,100,4,0,45,5},{19,3,30,100,4,0,85,5},{20,4,22,100,4,0,105,5},{21,5,20,100,4,0,125,5},{22,3,20,100,2,0,90,5},{23,5,15,100,2,0,100,5},{24,6,25,100,2,0,110,5},{25,4,10,100,1,0,50,5},{26,6,15,100,4,0,85,5},{27,6,10,100,1,0,60,5}}
	}
}

function branch_ice_node_offset(level, cfg)
	local tag = cfg and cfg[1]

	if level == 170 then
		return 25
	elseif level == 171 then
		return (tag == 25 or tag == 26) and 0 or 25
	elseif level == 172 then
		return (tag == 16 or tag == 17 or tag == 18 or tag == 19 or tag == 20 or tag == 25) and 25 or 0
	end

	return 0
end

function branch_spawn_scene(store, name, x, y, fields)
	local e = E:create_entity(name)
	e.pos = V.v(x, y)
	for k, value in pairs(fields or {}) do e[k] = value end
	queue_insert(store, e)
	return e
end

local function branch_stage16_shift_entity_x(e, dx)
	if e.pos then
		e.pos.x = e.pos.x + dx
	end

	if e.tower and e.tower.default_rally_pos then
		e.tower.default_rally_pos.x = e.tower.default_rally_pos.x + dx
	end

	if e.barrack and e.barrack.rally_pos then
		e.barrack.rally_pos.x = e.barrack.rally_pos.x + dx
	end
end

local function branch_stage16_recalc_path_terrain(pi)
	local path = P.paths[pi]

	if not path or not path[1] then
		return
	end

	local terrain_types = TERRAIN_NONE

	for _, node in pairs(path[1]) do
		terrain_types = bor(terrain_types, GR:cell_type(node.x, node.y))
	end

	P.terrains[pi] = band(terrain_types, TERRAIN_TYPES_MASK)
	P.terrain_props[pi] = band(terrain_types, TERRAIN_PROPS_MASK)
end

local function branch_stage16_configure_path(pi, active, dx)
	local path = P.paths[pi]

	if not path then
		return
	end

	if dx and dx ~= 0 then
		for _, subpath in pairs(path) do
			for _, node in pairs(subpath) do
				node.x = node.x + dx
			end
		end
	end

	if active then
		P:activate_path(pi)
	else
		P:deactivate_path(pi)
	end

	local nodes = path[1]

	if nodes and #nodes > 0 then
		P:set_start_node(pi, 1)
		P:set_visible_start_node(pi, 1)
		P:set_end_node(pi, #nodes)
		P:set_visible_end_node(pi, #nodes)
	end

	branch_stage16_recalc_path_terrain(pi)
end

local function branch_stage16_split_setup(store, level, controller)
	if (level ~= 166 and level ~= 192) or controller.kr4_stage16_split_done then
		return
	end

	controller.kr4_stage16_split_done = true

	if level == 166 then
		for pi = 1, 4 do
			branch_stage16_configure_path(pi, true, 512 - 1655)
		end

		for pi = 5, 10 do
			branch_stage16_configure_path(pi, false, 0)
		end
	else
		for pi = 1, 6 do
			P.paths[pi] = P.paths[pi + 4]
		end

		for pi = 7, 10 do
			P.paths[pi] = nil
			P:deactivate_path(pi)
		end

		for pi = 1, 6 do
			branch_stage16_configure_path(pi, true, 512 - 592)
		end
	end

	local dx = level == 166 and 512 - 1655 or 512 - 592
	local left_fx = {
		Stage16_water_run = true,
		Stage16_door_over = true,
		Stage_16_castle_door_shadow = true,
		Stage_16_mask_1 = true
	}

	for _, e in pairs(store.entities) do
		local remove = false
		local holder_id = e.tower and tonumber(e.tower.holder_id)

		if holder_id then
			if level == 166 then
				if holder_id >= 15 then
					branch_stage16_shift_entity_x(e, dx)
				else
					remove = true
				end
			elseif holder_id < 15 then
				branch_stage16_shift_entity_x(e, dx)
			else
				remove = true
			end
		elseif e.template_name == "decal_defend_point5" or e.template_name == "decal_defense_flag5" then
			if level == 166 then
				if e.pos and e.pos.x > 1500 then
					branch_stage16_shift_entity_x(e, dx)
				else
					remove = true
				end
			elseif e.pos and e.pos.x <= 1500 then
				branch_stage16_shift_entity_x(e, dx)
			else
				remove = true
			end
		elseif e.template_name == "fx_repeat_forever" and e.render and e.render.sprites and e.render.sprites[1] then
			local name = e.render.sprites[1].name

			if level == 166 then
				if name == "Stage_16_mask_0" then
					branch_stage16_shift_entity_x(e, dx)
				elseif left_fx[name] then
					remove = true
				end
			elseif name == "Stage_16_mask_0" then
				remove = true
			elseif left_fx[name] then
				branch_stage16_shift_entity_x(e, dx)
			end
		end

		if remove then
			queue_remove(store, e)
		end
	end
end

function branch_path_or_default(pi)
	pi = tonumber(pi) or 1

	return P.paths[pi] and pi or 1
end

function branch_subpath_or_default(pi, spi)
	spi = tonumber(spi) or 1

	return P.paths[pi] and P.paths[pi][spi] and spi or 1
end

local stage164_golem_house_schedules = {
	-- KR4 campaign object coordinates are already in the same stage-space as
	-- level164_data.lua; the route target is chosen from this build's path DB.
	{wave = 6, x = 589, y = 642},
	{wave = 10, x = 303, y = 138},
	{wave = 13, x = 689, y = 138, flip_x = true}
}

local stage164_portal_schedules = {
	[GAME_MODE_CAMPAIGN] = {
		{
			wave = 3,
			x = 553,
			y = 105,
			spawns = {
				{template = "enemy_footman", delay = 3},
				{template = "enemy_footman", delay = 5},
				{template = "enemy_footman", delay = 7}
			}
		},
		{
			wave = 6,
			x = 553,
			y = 105,
			spawns = {
				{template = "enemy_elite_footman", delay = 3},
				{template = "enemy_elite_footman", delay = 5},
				{template = "enemy_elite_footman", delay = 7}
			}
		},
		{
			wave = 12,
			x = 553,
			y = 105,
			spawns = {
				{template = "enemy_elven_warrior", delay = 8},
				{template = "enemy_elven_warrior", delay = 10},
				{template = "enemy_elven_warrior", delay = 12},
				{template = "enemy_arcane_magus", delay = 22},
				{template = "enemy_arcane_magus", delay = 24}
			}
		}
	}
}

function stage164_apply_flip(e, flip_x)
	if not e or not flip_x then
		return
	end

	for _, s in pairs(e.render and e.render.sprites or {}) do
		s.flip_x = true
	end
end

function stage164_route_target(cfg, pos)
	local path, subpath, node

	if cfg and cfg.path then
		path = branch_path_or_default(cfg.path)
		subpath = branch_subpath_or_default(path, cfg.subpath)
		node = cfg.node or P:get_start_node(path)

		return path, subpath, node
	end

	pos = pos or cfg and cfg.x and cfg.y and V.v(cfg.x, cfg.y)

	local nodes = pos and P:nearest_nodes(pos.x, pos.y, nil, nil, true)

	if nodes and nodes[1] then
		return nodes[1][1], nodes[1][2], nodes[1][3]
	end

	path = 1
	subpath = branch_subpath_or_default(path, 1)
	node = P:get_start_node(path)

	return path, subpath, node
end

function stage164_wake_golem_house(store, cfg, decal)
	if decal and store.entities[decal.id] then
		queue_remove(store, decal)
	end

	local path, subpath, node = stage164_route_target(cfg, V.v(cfg.x, cfg.y))
	local e = branch_spawn_from_pos_to_path(store, "enemy_golem_house", V.v(cfg.x, cfg.y), path, subpath, node)

	stage164_apply_flip(e, cfg.flip_x)

	return e
end

function stage164_spawn_teleporter_flash(store, cfg)
	local fx = E:create_entity("stage164_teleporter_flash")
	local pos = cfg.fx_pos or V.v(cfg.x, (cfg.y or 0) + 20)

	fx.pos = V.vclone(pos)

	for _, s in pairs(fx.render and fx.render.sprites or {}) do
		s.ts = store.tick_ts
		s.loop = false
	end

	queue_insert(store, fx)

	return fx
end

function branch_stage30_plant_teleport(centers_px, positions, disabled)
	return {
		cooldown = 2.5,
		range = 80,
		sickness = 1.5,
		centers_px = centers_px,
		positions = positions,
		disabled = disabled
	}
end

function branch_stage30_spawn_plant(store, x, y, centers_px, positions, disabled)
	return branch_spawn_scene(store, "kr4_carnivorous_plant", x, y, {
		teleport = branch_stage30_plant_teleport(centers_px, positions, disabled)
	})
end

local stage165_lightseeker_wave_groups = {
	boss_riders_elites_1 = {
		{path = 1, delay = 0, spawns = {
			{template = "enemy_knight_rider", count = 2, interval = 1, fixed_sub_path = -1, node = 2},
			{template = "enemy_banner_bearer", count = 1, interval = 1, fixed_sub_path = -1, node = 2},
			{template = "enemy_elite_footman", count = 4, interval = 1, fixed_sub_path = -1, node = 2}
		}}
	},
	boss_elites_1 = {
		{path = 1, delay = 0, spawns = {
			{template = "enemy_elite_footman", count = 6, interval = 1, fixed_sub_path = -1, node = 2}
		}}
	},
	boss_paladins_1 = {
		{path = 1, delay = 0, spawns = {
			{template = "enemy_paladin", count = 2, interval = 1, fixed_sub_path = -1, node = 2}
		}}
	},
	boss_tower_1 = {
		{path = 1, delay = 0, spawns = {
			{template = "enemy_tower_shield_knight", count = 2, interval = 1, fixed_sub_path = -1, node = 2}
		}}
	},
	boss_sorcerer_4 = {
		{path = 4, delay = 3, spawns = {
			{template = "enemy_high_sorcerer", count = 1, interval = 1, fixed_sub_path = 0, node = 2}
		}}
	},
	boss_elite_4 = {
		{path = 4, delay = 3, spawns = {
			{template = "enemy_elite_footman", count = 6, interval = 1, fixed_sub_path = -1, node = 2}
		}}
	},
	boss_elves_4 = {
		{path = 4, delay = 0, spawns = {
			{template = "enemy_elven_warrior", count = 4, interval = 1, fixed_sub_path = -1, node = 2}
		}}
	}
}

local stage165_house_types = {
	blacksmith = {
		house_template = "linirea_house_swap_blacksmith",
		source = "enemy_footman",
		result = "enemy_paladin",
		paths = {5},
		subpath = 2,
		node = 120,
		enter_offset = V.v(-30, 0),
		enter_radius = 45,
		out_path = 1,
		out_node = 3,
		out_offset = V.v(10, 20),
		change_delay = 8
	},
	stable = {
		house_template = "linirea_house_swap_stable",
		source = "enemy_paladin",
		result = "enemy_knight_rider",
		paths = {2, 3},
		subpath = 2,
		node = 84,
		enter_offset = V.v(-50, 0),
		enter_radius = 40,
		out_path = 6,
		out_subpath = 3,
		out_node = 2,
		out_offset = V.v(35, 60),
		change_delay = 8
	}
}

local stage165_house_schedules = {
	[GAME_MODE_CAMPAIGN] = {
		{wave = 5, kind = "blacksmith", count = 2},
		{wave = 9, kind = "stable", count = 3},
		{wave = 11, kind = "blacksmith", count = 4},
		{wave = 13, kind = "blacksmith", count = 2},
		{wave = 14, kind = "stable", count = 3},
		{wave = 15, kind = "stable", count = 1}
	},
	[GAME_MODE_HEROIC] = {
		{wave = 4, kind = "stable", count = 4},
		{wave = 4, kind = "blacksmith", count = 4},
		{wave = 6, kind = "stable", count = 6}
	},
	[GAME_MODE_IRON] = {
		{wave = 1, kind = "stable", count = 3}
	}
}

local stage165_boss_house_schedule = {kind = "stable", count = 1}

local stage163_alleria_schedules = {
	{wave = 3, delay = 6, path = 1, node = 36},
	{wave = 5, delay = 6, path = 0, node = 20},
	{wave = 5, delay = 26, path = 1, node = 36},
	{wave = 7, delay = 4, path = 1, node = 60},
	{wave = 7, delay = 20, path = 0, node = 26},
	{wave = 10, delay = 4, path = 0, node = 26},
	{wave = 10, delay = 20, path = 1, node = 36},
	{wave = 10, delay = 36, path = 0, node = 70},
	{wave = 12, delay = 4, path = 1, node = 60},
	{wave = 12, delay = 20, path = 0, node = 26},
	{wave = 14, delay = 4, path = 0, node = 26},
	{wave = 14, delay = 20, path = 1, node = 36},
	{wave = 14, delay = 36, path = 0, node = 70},
	{wave = 15, delay = 4, path = 0, node = 26},
	{wave = 15, delay = 20, path = 1, node = 36},
	{wave = 15, delay = 36, path = 0, node = 70}
}

local branch_stage_water_segments = {
	[173] = {
		{path = 1, node_start = 41, node_end = 58},
		{path = 1, node_start = 104, node_end = 116},
		{path = 2, node_start = 88, node_end = 112},
		{path = 3, node_start = 90, node_end = 114}
	},
	[174] = {
		{path = 1, node_start = 36, node_end = 48},
		{path = 1, node_start = 82, node_end = 97},
		{path = 2, node_start = 52, node_end = 67},
		{path = 2, node_start = 99, node_end = 113},
		{path = 3, node_start = 52, node_end = 66},
		{path = 3, node_start = 106, node_end = 117},
		{path = 4, node_start = 62, node_end = 78},
		{path = 4, node_start = 108, node_end = 120}
	},
	[175] = {
		{path = 2, node_start = 65, node_end = 75},
		{path = 3, node_start = 58, node_end = 68},
		{path = 3, node_start = 150, node_end = 163},
		{path = 4, node_start = 56, node_end = 67},
		{path = 5, node_start = 66, node_end = 79}
	}
}

function stage163_spawn_alleria(store, cfg)
	local pi = branch_kr4_path_rank(cfg.path)

	if not P.paths[pi] then
		return nil
	end

	local unit = branch_spawn_on_path(store, "enemy_alleria", nil, 0, pi, 1, branch_clamp_path_node(pi, cfg.node))

	stage164_apply_flip(unit, true)

	return unit
end

function stage163_has_living_enemies(store)
	for _, e in pairs(store.entities) do
		if e.enemy and e.health and not e.health.dead and (not e.vis or band(e.vis.flags or 0, F_ENEMY) ~= 0) then
			return true
		end
	end

	return false
end

function stage165_copy_house_cfg(cfg)
	local base = stage165_house_types[cfg.kind]

	if not base then
		return nil
	end

	local out = {}

	for k, v in pairs(base) do
		out[k] = v
	end

	for k, v in pairs(cfg) do
		out[k] = v
	end

	return out
end

function stage165_spawn_house_event(store, cfg)
	local event_cfg = stage165_copy_house_cfg(cfg)

	if not event_cfg then
		return nil
	end

	return branch_spawn_scene(store, "stage165_house_swap_event", 0, 0, {cfg = event_cfg})
end

function stage165_find_house(store, template_name)
	for _, e in pairs(store.entities) do
		if e.template_name == template_name then
			return e
		end
	end

	return nil
end

function stage165_path_or_default(pi)
	pi = tonumber(pi) or 1

	return P.paths[pi] and pi or 1
end

function stage165_subpath_or_default(pi, spi)
	spi = tonumber(spi) or 1

	return P.paths[pi] and P.paths[pi][spi] and spi or 1
end

function stage165_house_set_animation(store, house, animation, loop)
	if not house or not house.render or not house.render.sprites then
		return
	end

	for sid in pairs(house.render.sprites) do
		U.animation_start(house, animation, nil, store.tick_ts, loop ~= false, sid)
	end
end

function stage165_spawn_house_input(store, cfg, index)
	local paths = cfg.paths or {1}
	local pi = stage165_path_or_default(paths[(index - 1) % #paths + 1])
	local spi = stage165_subpath_or_default(pi, cfg.subpath or 1)

	return branch_spawn_on_path(store, cfg.source, nil, 0, pi, spi, cfg.start_node or P:get_start_node(pi))
end

function stage165_house_unit_reached(store, unit, cfg, house)
	if not unit or not store.entities[unit.id] or unit.health and unit.health.dead then
		return false
	end

	local reached_node = false

	if unit.nav_path then
		local dir = unit.nav_path.dir or branch_path_dir(unit.nav_path.pi)
		local node = cfg.node or P:get_end_node(unit.nav_path.pi)

		if dir > 0 and unit.nav_path.ni >= node or dir < 0 and unit.nav_path.ni <= node then
			reached_node = true
		end
	end

	if not reached_node then
		return false
	end

	if house and cfg.enter_radius then
		local offset = cfg.enter_offset or V.v(0, 0)

		return V.dist(unit.pos.x, unit.pos.y, house.pos.x + offset.x, house.pos.y + offset.y) <= cfg.enter_radius
	end

	return reached_node
end

function stage165_spawn_house_result(store, cfg, house)
	local out_path = stage165_path_or_default(cfg.out_path or 1)
	local out_subpath = stage165_subpath_or_default(out_path, cfg.out_subpath or 1)
	local out_node = cfg.out_node or P:get_start_node(out_path)
	local source_pos = house and V.v(house.pos.x + (cfg.out_offset and cfg.out_offset.x or 0), house.pos.y + (cfg.out_offset and cfg.out_offset.y or 0)) or V.vclone(P:node_pos(out_path, out_subpath, out_node))

	return branch_spawn_from_pos_to_path(store, cfg.result, source_pos, out_path, out_subpath, out_node)
end

scripts.stage164_spawn_event = {}

function scripts.stage164_spawn_event.update(this, store)
	local cfg = this.cfg

	if not cfg then
		queue_remove(store, this)

		return
	end

	local base_pos = cfg.pos or this.pos
	local path, subpath, node = stage164_route_target(cfg, base_pos)
	local elapsed = 0

	for _, spawn in ipairs(cfg.spawns or {}) do
		local delay = spawn.delay or 0

		if delay > elapsed then
			U.y_wait(store, delay - elapsed)
			elapsed = delay
		end

		for i = 1, (spawn.count or 1) do
			local pos = spawn.pos or cfg.pos or this.pos
			local spawn_path, spawn_subpath, spawn_node = stage164_route_target(spawn.path and spawn or cfg, pos)

			stage164_spawn_teleporter_flash(store, cfg)

			local unit = branch_spawn_from_pos_to_path(store, spawn.template, V.vclone(pos), spawn_path or path, spawn_subpath or subpath, spawn_node or node)

			stage164_apply_flip(unit, spawn.flip_x)

			if i < (spawn.count or 1) and spawn.interval and spawn.interval > 0 then
				U.y_wait(store, spawn.interval)
				elapsed = elapsed + spawn.interval
			end
		end
	end

	queue_remove(store, this)
end

scripts.stage165_house_swap_event = {}

function scripts.stage165_house_swap_event.update(this, store)
	local cfg = this.cfg

	if not cfg then
		queue_remove(store, this)

		return
	end

	local house = stage165_find_house(store, cfg.house_template)
	local units = {}
	local jobs = {}

	for i = 1, (cfg.count or 1) do
		local unit = stage165_spawn_house_input(store, cfg, i)

		if unit then
			table.insert(units, unit)
		end

		U.y_wait(store, cfg.spawn_interval or 0.6)
	end

	while #units > 0 or #jobs > 0 do
		for i = #units, 1, -1 do
			local unit = units[i]

			if not unit or not store.entities[unit.id] or unit.health and unit.health.dead then
				table.remove(units, i)
			elseif stage165_house_unit_reached(store, unit, cfg, house) then
				queue_remove(store, unit)
				table.remove(units, i)
				table.insert(jobs, store.tick_ts + (cfg.change_delay or 8))
				stage165_house_set_animation(store, house, "run", true)
			end
		end

		for i = #jobs, 1, -1 do
			if store.tick_ts >= jobs[i] then
				stage165_spawn_house_result(store, cfg, house)
				table.remove(jobs, i)
			end
		end

		coroutine.yield()
	end

	stage165_house_set_animation(store, house, "idle", true)
	queue_remove(store, this)
end

scripts.stage165_lightseeker_wave_event = {}

function scripts.stage165_lightseeker_wave_event.update(this, store)
	local groups = stage165_lightseeker_wave_groups[this.wave_name]

	for _, group in ipairs(groups or {}) do
		if group.delay and group.delay > 0 then
			U.y_wait(store, group.delay)
		end

		local pi = stage165_path_or_default(branch_kr4_path_rank(group.path))
		local path_count = P.paths[pi] and #P.paths[pi] or 1

		for _, spawn in ipairs(group.spawns or {}) do
			for _ = 1, (spawn.count or 1) do
				local spi

				if spawn.fixed_sub_path and spawn.fixed_sub_path >= 0 then
					spi = spawn.fixed_sub_path + 1
				else
					spi = path_count > 1 and math.random(1, path_count) or 1
				end

				spi = stage165_subpath_or_default(pi, spi)
				branch_spawn_on_path(store, spawn.template, nil, 0, pi, spi, spawn.node or P:get_start_node(pi))

				if spawn.interval and spawn.interval > 0 then
					U.y_wait(store, spawn.interval)
				end
			end
		end
	end

	queue_remove(store, this)
end

scripts.lightseeker_roof = {}

function scripts.lightseeker_roof.update(this, store)
	U.animation_start(this, "lightseeker_chair_idle", nil, store.tick_ts, true, 1)

	while not this.exit do
		coroutine.yield()
	end

	U.animation_start(this, "lightseeker_chair_standUp", nil, store.tick_ts, false, 1)
	U.y_animation_wait(this, 1)
	this.exit_done = true
	queue_remove(store, this)
end

function scripts.spider_nest_enemy_in_range(store, tower)
	local sn = tower.spider_nest or {}

	return U.find_foremost_enemy(store.entities, tower.pos, 0, sn.range or 320, false, F_RANGED, F_FLYING)
end

function scripts.spider_nest_update_egg_sprites(tower, store)
	local b = tower.barrack
	local sn = tower.spider_nest or {}
	local max_soldiers = b.max_soldiers or 1

	for i, cfg in ipairs(sn.egg_configs or {}) do
		local sprite = tower.render and tower.render.sprites and tower.render.sprites[cfg.sid]

		if sprite then
			sprite.hidden = i > max_soldiers

			if not sprite.hidden and tower._spider_egg_open_until and tower._spider_egg_open_until[i] and store.tick_ts >= tower._spider_egg_open_until[i] then
				tower._spider_egg_open_until[i] = nil
				U.animation_start(tower, cfg.prefix .. "_idleClosed", nil, store.tick_ts, true, cfg.sid, true)
			end
		end
	end
end

function scripts.spider_nest_spawn_webs(tower, store)
	if tower._spider_webs_spawned then
		return
	end

	tower._spider_webs_spawned = true
	tower._spider_webs = {}

	for _, cfg in ipairs(tower.spider_nest.web_offsets or {}) do
		local web = branch_spawn_scene(store, "spider_nest_web_fx", tower.pos.x + cfg.x, tower.pos.y + cfg.y)
		local scale = cfg.scale or 1

		if web.render and web.render.sprites and web.render.sprites[1] then
			web.render.sprites[1].scale = V.v(scale, scale)
		end

		table.insert(tower._spider_webs, web)
	end
end

function scripts.spider_nest_apply_web_slow(tower, store)
	local sn = tower.spider_nest or {}
	local mod_name = sn.web_mod or "mod_spider_nest_web_slow"
	local enemies = U.find_enemies_in_range(store.entities, tower.pos, 0, sn.web_range or sn.range or 320, F_RANGED, F_FLYING)

	for _, enemy in ipairs(enemies or {}) do
		if not U.has_modifiers(store, enemy, mod_name) then
			local mod = E:create_entity(mod_name)

			mod.modifier.source_id = tower.id
			mod.modifier.target_id = enemy.id
			queue_insert(store, mod)
		end
	end
end

function scripts.spider_nest_reposition_soldiers(tower)
	local b = tower.barrack

	for i = 1, b.max_soldiers do
		local s = b.soldiers[i]

		if s and not s.health.dead then
			s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(i, b, b.max_soldiers, b.rally_angle_offset)
			s.nav_rally.new = true
		end
	end
end

function scripts.spider_nest_spawn_spider(tower, store, slot)
	local b = tower.barrack
	local sn = tower.spider_nest or {}
	local cfg = sn.egg_configs and sn.egg_configs[slot] or {}
	local s = E:create_entity(b.soldier_type)

	s.soldier.tower_id = tower.id
	s.soldier.tower_soldier_idx = slot
	s.pos = V.v(tower.pos.x + (cfg.spawn_x or 0), tower.pos.y + (cfg.spawn_y or 0))
	s.nav_rally.pos, s.nav_rally.center = U.rally_formation_position(slot, b, b.max_soldiers, b.rally_angle_offset)
	s.nav_rally.new = true

	queue_insert(store, s)

	b.soldiers[slot] = s
	tower._spider_slot_ts[slot] = store.tick_ts

	if cfg.sid then
		U.animation_start(tower, cfg.prefix .. "_spawn", nil, store.tick_ts, false, cfg.sid, true)
		tower._spider_egg_open_until[slot] = store.tick_ts + (cfg.respawn_delay or 0.6)
	end

	signal.emit("tower-spawn", tower, s)

	return s
end

scripts.spider_nest_tower = {}

function scripts.spider_nest_tower.update(this, store)
	local b = this.barrack
	local sn = this.spider_nest or {}
	local desired_max = 1 + (this.powers and this.powers.spiderlings and this.powers.spiderlings.level or 0)
	local web_tick_ts = store.tick_ts

	this._spider_slot_ts = this._spider_slot_ts or {}
	this._spider_egg_open_until = this._spider_egg_open_until or {}
	b.max_soldiers = desired_max
	b.soldiers = b.soldiers or {}

	for i = 1, sn.max_soldiers or 3 do
		this._spider_slot_ts[i] = this._spider_slot_ts[i] or store.tick_ts - (sn.egg_refresh_cooldown or 15)
	end

	U.animation_start(this, "special_spider_tower_idle", nil, store.tick_ts, true, 2, true)

	while true do
		if this.powers then
			for _, p in pairs(this.powers) do
				if p.changed then
					p.changed = nil
				end
			end
		end

		local new_max = 1 + (this.powers and this.powers.spiderlings and this.powers.spiderlings.level or 0)

		if new_max ~= desired_max then
			desired_max = new_max
			b.max_soldiers = desired_max
			scripts.spider_nest_reposition_soldiers(this)
		end

		if this.powers and this.powers.sticky_web and this.powers.sticky_web.level > 0 then
			scripts.spider_nest_spawn_webs(this, store)

			if store.tick_ts - web_tick_ts >= (sn.web_tick_time or 0.2) then
				web_tick_ts = store.tick_ts
				scripts.spider_nest_apply_web_slow(this, store)
			end
		end

		scripts.spider_nest_update_egg_sprites(this, store)

		if not this.tower.blocked and scripts.spider_nest_enemy_in_range(store, this) then
			for i = 1, b.max_soldiers do
				local s = b.soldiers[i]

				if (not s or s.health.dead and not store.entities[s.id]) and store.tick_ts - (this._spider_slot_ts[i] or 0) >= (sn.egg_refresh_cooldown or 15) then
					scripts.spider_nest_spawn_spider(this, store, i)
				end
			end
		end

		if b.rally_new then
			b.rally_new = false
			signal.emit("rally-point-changed", this)
			scripts.spider_nest_reposition_soldiers(this)

			if this.sound_events and this.sound_events.change_rally_point then
				S:queue(this.sound_events.change_rally_point)
			end
		end

		coroutine.yield()
	end
end

function branch_stage10_spawn_blizzard(store, cfg)
	local storm = branch_spawn_scene(store, "snow_storm", 337, 706, {
		duration = cfg.duration,
		towers_amount = cfg.towers_amount or 3,
		tower_block_duration = cfg.tower_block_duration or 4,
		time_add_modifier = cfg.time_add_modifier or 15
	})

	if cfg.emission_rate then
		storm.particle_emission_rate = cfg.emission_rate
	end

	return storm
end

function branch_stage12_spawn_farmers(store, cfg)
	return branch_spawn_scene(store, "stage12_farm_spawner", cfg.x, cfg.y, {
		units = cfg.units,
		path = branch_kr4_path_rank(cfg.path),
		subpath = cfg.subpath or 1,
		node = cfg.node,
		interval = cfg.interval or 1
	})
end

local branch_viking_weapon_animations = {
	"viking_boss_axe_decal_run",
	"viking_boss_arrow_decal_run",
	"viking_boss_spear_decal_run"
}

function branch_is_valid_soldier_target(e)
	return e and e.soldier and e.health and not e.health.dead and e.pos and not U.flag_has(e.vis and e.vis.flags or 0, F_FLYING) and kr4_valid_enemy_soldier_target(e)
end

function branch_find_soldier_cluster_pos(store, radius, min_count)
	local best_count = 0
	local best = {}

	for _, e in pairs(store.entities) do
		if branch_is_valid_soldier_target(e) then
			local count = 0
			local sx, sy = 0, 0
			local targets = U.find_soldiers_in_range(store.entities, e.pos, 0, radius, 0, F_FLYING)

			for _, target in ipairs(targets or {}) do
				if branch_is_valid_soldier_target(target) then
					count = count + 1
					sx = sx + target.pos.x
					sy = sy + target.pos.y
				end
			end

			if count >= (min_count or 1) then
				local pos = count > 0 and V.v(sx / count, sy / count) or V.vclone(e.pos)

				if count > best_count then
					best_count = count
					best = {pos}
				elseif count == best_count then
					table.insert(best, pos)
				end
			end
		end
	end

	if #best > 0 then
		return best[math.random(1, #best)]
	end

	return nil
end

function branch_damage_soldier_area(store, source, pos, radius, damage, damage_type, max_count, freeze_chance, freeze_duration)
	local targets = U.find_soldiers_in_range(store.entities, pos, 0, radius, 0, F_FLYING, kr4_valid_enemy_soldier_target)

	for i, target in ipairs(targets or {}) do
		if max_count and i > max_count then
			break
		end

		branch_damage(store, source, target, damage, damage_type)

		if freeze_chance and math.random() <= freeze_chance then
			local m = E:create_entity("mod_branch_freeze")
			m.modifier.source_id = source and source.id
			m.modifier.target_id = target.id
			m.modifier.duration = freeze_duration or 3
			queue_insert(store, m)
		end
	end

	return targets or {}
end

function branch_viking_spawn_weapon_impact(store, pos, animation)
	local fx = branch_spawn_scene(store, "viking_boss_weapon_impact", pos.x, pos.y)
	fx.render.sprites[1].name = animation or branch_viking_weapon_animations[math.random(1, #branch_viking_weapon_animations)]
	fx.render.sprites[1].ts = store.tick_ts
	return fx
end

function branch_viking_spawn_weapon_warning(store, pos)
	local fx = branch_spawn_scene(store, "viking_boss_weapon_warning", pos.x, pos.y)
	fx.render.sprites[1].ts = store.tick_ts
	return fx
end

function branch_viking_stage9_attack(store, boss)
	local center = branch_find_soldier_cluster_pos(store, 120, 1)

	if not center then
		return false
	end

	if boss and store.entities[boss.id] then
		U.animation_start(boss, "viking_boss_attack", nil, store.tick_ts, false, 1, true)
	end

	local count = math.random(4, 7)
	local strikes = {}

	for i = 1, count do
		local pos = V.v(center.x + math.random(-70, 70), center.y + math.random(-45, 45))
		local animation = branch_viking_weapon_animations[math.random(1, #branch_viking_weapon_animations)]

		branch_viking_spawn_weapon_warning(store, pos)
		table.insert(strikes, {pos = pos, animation = animation})
	end

	U.y_wait(store, 0.85)

	for _, strike in ipairs(strikes) do
		branch_viking_spawn_weapon_impact(store, strike.pos, strike.animation)
		branch_damage_soldier_area(store, boss, strike.pos, 80, 80, bor(DAMAGE_TRUE, DAMAGE_EXPLOSION, DAMAGE_FX_EXPLODE), nil)
		U.y_wait(store, 0.12)
	end

	if boss and store.entities[boss.id] then
		U.animation_start(boss, "viking_boss_idle", nil, store.tick_ts, true, 1, true)
	end

	return true
end

function branch_viking_dragon_start(dragon, body_animation, rider_animation, ts, loop)
	if not dragon or not dragon.render then
		return
	end

	if dragon.animation_group then
		U.animation_start_group(dragon, body_animation, nil, ts, loop, dragon.animation_group)
	else
		U.animation_start(dragon, body_animation, nil, ts, loop, 1, true)
	end

	U.animation_start(dragon, rider_animation, nil, ts, loop, dragon.rider_sprite_idx or 2, true)
end

function branch_viking_dragon_move(store, dragon, from, to, duration)
	if not dragon or not store.entities[dragon.id] then
		return false
	end

	branch_viking_dragon_start(dragon, "viking_boss_dragon_walk", "viking_boss_dragon_rider_walk", store.tick_ts, true)

	local start_ts = store.tick_ts

	while store.tick_ts - start_ts < duration do
		if not store.entities[dragon.id] then
			return false
		end

		local p = km.clamp(0, 1, (store.tick_ts - start_ts) / duration)
		dragon.pos.x = from.x + (to.x - from.x) * p
		dragon.pos.y = from.y + (to.y - from.y) * p
		coroutine.yield()
	end

	dragon.pos.x = to.x
	dragon.pos.y = to.y

	return true
end

function branch_viking_dragon_breath(store, dragon, pos)
	if not dragon or not store.entities[dragon.id] then
		return false
	end

	branch_viking_dragon_start(dragon, "viking_boss_dragon_breathIn", "viking_boss_dragon_rider_breathIn", store.tick_ts, false)
	U.y_wait(store, 0.45)
	branch_viking_dragon_start(dragon, "viking_boss_dragon_breathLoop", "viking_boss_dragon_rider_breathLoop", store.tick_ts, true)

	for i = 1, 3 do
		local hit_pos = V.v(pos.x + (i - 2) * 42 + math.random(-18, 18), pos.y + math.random(-20, 20))

		branch_spawn_scene(store, "viking_boss_dragon_breath_floor", hit_pos.x, hit_pos.y)
		branch_spawn_scene(store, "viking_boss_dragon_breath_hits", hit_pos.x, hit_pos.y + 10)
		branch_damage_soldier_area(store, dragon, hit_pos, 80, 90, DAMAGE_PHYSICAL, nil, 0.5, 3)
		U.y_wait(store, 0.45)
	end

	branch_viking_dragon_start(dragon, "viking_boss_dragon_breathOut", "viking_boss_dragon_rider_breathOut", store.tick_ts, false)
	U.y_wait(store, 0.4)

	return true
end

function branch_viking_stage11_attack(store, dragon)
	local target = branch_find_soldier_cluster_pos(store, 120, 2)

	if not target or not dragon or not store.entities[dragon.id] then
		return false
	end

	branch_stage161_set_entity_visible(dragon, true)

	local attack_pos = V.v(target.x - 135, km.clamp(90, 620, target.y - 145))
	local home = dragon and dragon.stage161_home_pos
	local from = home and V.vclone(dragon.pos) or V.v(-160, attack_pos.y - 70)
	local out = V.v(1260, attack_pos.y - 45)

	if not branch_viking_dragon_move(store, dragon, from, attack_pos, 1.25) then
		return false
	end

	branch_viking_dragon_breath(store, dragon, target)

	if home then
		if branch_viking_dragon_move(store, dragon, attack_pos, home, 1.25) then
			branch_viking_dragon_start(dragon, "viking_boss_dragon_idle", "viking_boss_dragon_rider_idle", store.tick_ts, true)
		end
	else
		branch_viking_dragon_start(dragon, "viking_boss_dragon_outFly", "viking_boss_dragon_rider_outFly", store.tick_ts, true)
		branch_viking_dragon_move(store, dragon, attack_pos, out, 1.4)
	end

	return true
end

local stage161_horn_cooldowns = {16, 12, 12}
local stage161_horn_counts = {2, 2, 3}
local stage161_final_wave = 15
local stage161_ice_platform_pos = V.v(481, 460)

function branch_stage161_state(store)
	store.branch_stage161_dragon = store.branch_stage161_dragon or {
		hits = 0,
		boss_active = false,
		final_sequence = false,
		finished = false,
		ice_platform_collapsed = false
	}

	return store.branch_stage161_dragon
end

function branch_stage161_boss_entity(store, state)
	state = state or branch_stage161_state(store)

	if not state.boss then
		return nil
	end

	local boss = store.entities[state.boss.id]

	if boss and boss.health and not boss.health.dead then
		return boss
	end

	return nil
end

function branch_stage161_alive_boss(store, state)
	state = state or branch_stage161_state(store)

	if not state.boss_active then
		return nil
	end

	return branch_stage161_boss_entity(store, state)
end

function branch_stage161_set_entity_visible(entity, visible)
	if not entity or not entity.render or not entity.render.sprites then
		return
	end

	for _, sprite in pairs(entity.render.sprites) do
		sprite.hidden = not visible
	end

	if entity.health_bar then
		entity.health_bar.hidden = not visible
	end
end

function branch_stage161_set_boss_visible(boss, visible)
	branch_stage161_set_entity_visible(boss, visible)
end

function branch_stage161_collapse_ice_platform(store, state)
	state = state or branch_stage161_state(store)

	if state.ice_platform_collapsed then
		return
	end

	state.ice_platform_collapsed = true
	S:queue("barbarians_jokull_icebreak")
	branch_spawn_scene(store, "stage161_ice_platform_cracks_fx", stage161_ice_platform_pos.x, stage161_ice_platform_pos.y)
	branch_spawn_scene(store, "stage161_ice_platform_shards_fx", stage161_ice_platform_pos.x, stage161_ice_platform_pos.y)

	for _, e in pairs(store.entities) do
		local sprite = e.render and e.render.sprites and e.render.sprites[1]

		if sprite and sprite.name == "dragon_camouflage" then
			branch_stage161_set_entity_visible(e, false)
			queue_remove(store, e)
		end
	end

	branch_spawn_scene(store, "mega_boss_dragon_horn_impact", stage161_ice_platform_pos.x, stage161_ice_platform_pos.y)
	U.y_wait(store, 0.35)
end

function branch_stage161_remove_rider_dragon(store, state)
	state = state or branch_stage161_state(store)

	local dragon = state.rider_dragon

	if dragon and store.entities[dragon.id] then
		branch_viking_dragon_start(dragon, "viking_boss_dragon_outFly", "viking_boss_dragon_rider_outFly", store.tick_ts, true)
		U.y_wait(store, 0.2)
		queue_remove(store, dragon)
	end

	state.rider_dragon = nil
end

function branch_stage161_spawn_boss(store, dormant)
	local state = branch_stage161_state(store)
	local boss_pos = V.v(344, 539)
	local boss = branch_spawn_from_pos_to_path(store, "enemy_mega_boss_dragon", boss_pos, 2, 2, 111)

	if boss then
		boss.pos = V.vclone(boss_pos)
		boss.stage161_dormant = dormant
		if boss.motion then
			boss.stage161_saved_speed = boss.motion.max_speed
			boss.motion.max_speed = dormant and 0 or boss.motion.max_speed
			boss.motion.speed = dormant and 0 or boss.motion.speed
		end
		state.boss = boss
		if dormant then
			branch_stage161_set_entity_visible(boss, true)
			if boss.health_bar then
				boss.health_bar.hidden = true
			end
		else
			branch_stage161_set_boss_visible(boss, true)
		end
	end

	return boss
end

function branch_stage161_drop_cannons(store, cannons)
	local active = {}

	for _, cannon in ipairs(cannons or {}) do
		if cannon and store.entities[cannon.id] and not cannon.stage161_dropped then
			cannon.stage161_dropped = true
			table.insert(active, {
				entity = cannon,
				from_y = cannon.pos.y,
				to_y = cannon.stage161_final_y or cannon.pos.y - 800
			})
		end
	end

	if #active == 0 then
		return
	end

	S:queue("level11_goblincannon_drop")

	local start_ts = store.tick_ts
	local duration = 0.8

	while store.tick_ts - start_ts < duration do
		local phase = km.clamp(0, 1, (store.tick_ts - start_ts) / duration)

		for _, item in ipairs(active) do
			if store.entities[item.entity.id] then
				item.entity.pos.y = U.ease_value(item.from_y, item.to_y, phase)
			end
		end

		coroutine.yield()
	end

	for _, item in ipairs(active) do
		if store.entities[item.entity.id] then
			item.entity.pos.y = item.to_y
		end
	end
end

function branch_stage161_activate_boss(store)
	local state = branch_stage161_state(store)
	local boss = branch_stage161_boss_entity(store, state)

	if state.boss_active or state.boss_activating then
		return boss
	end

	state.boss_activating = true

	branch_stage161_remove_rider_dragon(store, state)
	branch_stage161_collapse_ice_platform(store, state)
	boss = branch_stage161_boss_entity(store, state)

	if not boss then
		boss = branch_stage161_spawn_boss(store, false)
	end

	if boss then
		boss.stage161_dormant = false
		if boss.motion and boss.stage161_saved_speed then
			boss.motion.max_speed = boss.stage161_saved_speed
		end
		state.boss = boss
		branch_stage161_set_entity_visible(state.traffic_guy, true)
		branch_stage161_set_entity_visible(state.left_cannon, true)
		branch_stage161_set_entity_visible(state.right_cannon, true)
		branch_stage161_set_boss_visible(boss, true)
		S:queue("MusicBossFight_161")
		branch_stage161_drop_cannons(store, {state.left_cannon, state.right_cannon})
		state.boss_active = true
	end

	state.boss_activating = nil

	return boss
end

function branch_stage161_update_boss_hp(state, boss)
	if boss and boss.health then
		boss.health.hp = math.max(0, (boss.stage161_max_hits or 5) - (state.hits or 0))
		boss.stage161_hit = true
	end
end

function branch_stage161_spawn_hit_fx(store, pos)
	branch_spawn_scene(store, "mega_boss_dragon_horn_impact", pos.x, pos.y)
	branch_spawn_scene(store, "mega_boss_dragon_projectile_smoke", pos.x, pos.y + 18)
end

function branch_stage161_cannon_animation_start(cannon, name, store, loop)
	local flip = cannon.render.sprites[1].flip_x

	if cannon.animation_group then
		U.animation_start_group(cannon, name, flip, store.tick_ts, loop, cannon.animation_group)
	else
		U.animation_start(cannon, name, flip, store.tick_ts, loop, 1, true)
	end
end

function branch_stage161_cannon_animation_play(cannon, name, store, times)
	local flip = cannon.render.sprites[1].flip_x

	if cannon.animation_group then
		U.y_animation_play_group(cannon, name, flip, store.tick_ts, times, cannon.animation_group)
	else
		U.y_animation_play(cannon, name, flip, store.tick_ts, times, 1)
	end
end

function branch_stage161_break_cannon(store, cannon)
	if not cannon or not store.entities[cannon.id] or cannon.broken then
		return
	end

	cannon.broken = true
	cannon.ui.can_click = false
	cannon.ui.clicked = nil
	S:queue("level11_goblincannon_explodes")
	branch_spawn_scene(store, "stage11_cannon_explosion_fx", cannon.pos.x, cannon.pos.y + 42)
	branch_stage161_cannon_animation_play(cannon, "Stage_11_cannon_dead", store, 1)

	if store.entities[cannon.id] then
		branch_stage161_cannon_animation_start(cannon, "Stage_11_cannon_loopdead", store, true)
	end
end

function branch_stage161_cannon_shot_pos(cannon)
	local dx = cannon.tip_offset_x or (cannon.side == "right" and -30 or 30)
	local dy = cannon.tip_offset_y or 110

	return V.v(cannon.pos.x + dx, cannon.pos.y + dy)
end

function branch_stage161_register_hit(store, cannon, boss)
	local state = branch_stage161_state(store)

	if state.finished then
		return
	end

	state.hits = math.min((boss and boss.stage161_max_hits) or 5, (state.hits or 0) + 1)
	branch_stage161_update_boss_hp(state, boss)
	branch_stage161_spawn_hit_fx(store, boss.pos)

	if state.hits == 4 and not state.final_sequence then
		state.final_sequence = true

		if state.left_cannon and store.entities[state.left_cannon.id] then
			state.left_cannon.break_requested = true
		end

		if state.right_cannon and store.entities[state.right_cannon.id] then
			state.right_cannon.force_shoot_ts = store.tick_ts + 1.2
		end
	elseif state.hits >= ((boss and boss.stage161_max_hits) or 5) then
		state.finished = true

		if boss and boss.health then
			boss.health.hp = 0
			boss.health.dead = true
		end

		S:queue("barbarians_jokull_death")
		branch_spawn_scene(store, "stage11_cannon_explosion_fx", boss.pos.x, boss.pos.y + 40)
	end
end

function branch_stage161_fire_cannon(store, cannon, forced)
	if not cannon or cannon.broken then
		return false
	end

	local state = branch_stage161_state(store)
	local boss = branch_stage161_alive_boss(store, state)

	if not boss or state.finished then
		return false
	end

	if not forced and (state.final_sequence or store.tick_ts < (cannon.next_ready_ts or 0)) then
		return false
	end

	cannon.ui.can_click = false
	cannon.ui.clicked = nil
	S:queue("level11_goblincannon_drop")
	branch_stage161_cannon_animation_start(cannon, "Stage_11_cannon_startcharge", store, false)
	U.y_wait(store, cannon.action_time or 0.4)

	if not store.entities[cannon.id] or not branch_stage161_alive_boss(store, state) then
		return false
	end

	S:queue("level11_goblincannon_fire")
	branch_stage161_cannon_animation_start(cannon, "Stage_11_cannon_shoot", store, false)
	local shot_pos = branch_stage161_cannon_shot_pos(cannon)
	local projectile = branch_spawn_scene(store, "stage11_cannon_projectile_fx", shot_pos.x, shot_pos.y)

	if projectile and projectile.render and projectile.render.sprites and projectile.render.sprites[1] then
		projectile.render.sprites[1].r = V.angleTo(boss.pos.x - shot_pos.x, boss.pos.y - shot_pos.y)
	end

	U.y_wait(store, cannon.hit_time or 0.35)

	if branch_stage161_alive_boss(store, state) then
		branch_stage161_register_hit(store, cannon, boss)
	end

	cannon.next_ready_ts = store.tick_ts + (cannon.cooldown or 30)

	if store.entities[cannon.id] and not cannon.broken then
		branch_stage161_cannon_animation_start(cannon, "Stage_11_cannon_loopready", store, true)
		cannon.ui.can_click = not state.final_sequence
	end

	return true
end

function branch_stage161_horn_phase(state)
	local hits = state and state.hits or 0

	if hits >= 4 then
		return 3
	elseif hits >= 2 then
		return 2
	end

	return 1
end

function branch_stage161_horn_attack(store, boss)
	if not boss or not store.entities[boss.id] then
		return false
	end

	local state = branch_stage161_state(store)
	local phase = branch_stage161_horn_phase(state)
	local count = stage161_horn_counts[phase] or 2
	local center = branch_find_soldier_cluster_pos(store, 140, 2) or branch_find_soldier_cluster_pos(store, 140, 1)

	if not center then
		return false
	end

	S:queue("level11_vikings_horn")

	for i = 1, count do
		local pos = V.v(center.x + math.random(-80, 80), center.y + math.random(-55, 55))

		S:queue("barbarians_jokull_peakshot")
		U.y_wait(store, 0.8)
		branch_stage161_spawn_hit_fx(store, pos)
		S:queue("barbarians_jokull_peakimpact")
		branch_damage_soldier_area(store, boss, pos, 120, math.random(120, 250), bor(DAMAGE_EXPLOSION, DAMAGE_FX_EXPLODE), nil)
		U.y_wait(store, 0.15)
	end

	return true
end

local stage161_launch_units = {
	{"enemy_blue_wyvern", 1, 1},
	{"enemy_northern_wildling", 1, 1},
	{"enemy_northern_huntress", 2, 1},
	{"enemy_blue_wyvern", 2, 1}
}

function branch_stage161_launch_minions(store, boss)
	if not boss or not store.entities[boss.id] then
		return false
	end

	if not branch_stage161_state(store).boss_active then
		return false
	end

	S:queue("level11_vikings_horn")

	for i, cfg in ipairs(stage161_launch_units) do
		local pi, spi = cfg[2], cfg[3]
		local pos = P:node_pos(pi, spi, P:get_start_node(pi))

		branch_spawn_scene(store, "wyvern_spawner", pos.x, pos.y)
		branch_spawn_on_path(store, cfg[1], nil, 0, pi, spi, P:get_start_node(pi))
		U.y_wait(store, 0.25)
	end

	return true
end

scripts.stage11_goblin_cannon = {}

function scripts.stage11_goblin_cannon.update(this, store)
	this.ui.can_click = false
	this.ui.clicked = nil
	this.next_ready_ts = store.tick_ts
	branch_stage161_cannon_animation_start(this, "Stage_11_cannon_loopready", store, true)

	while true do
		local state = branch_stage161_state(store)
		local boss = branch_stage161_alive_boss(store, state)

		if state.finished then
			this.ui.can_click = false
		elseif not boss then
			this.ui.clicked = nil
			this.ui.can_click = false
		elseif this.break_requested then
			this.break_requested = nil
			branch_stage161_break_cannon(store, this)
		elseif this.force_shoot_ts and store.tick_ts >= this.force_shoot_ts then
			this.force_shoot_ts = nil
			branch_stage161_fire_cannon(store, this, true)
		elseif this.ui.clicked then
			this.ui.clicked = nil
			branch_stage161_fire_cannon(store, this, false)
		elseif not this.broken then
			this.ui.can_click = store.tick_ts >= (this.next_ready_ts or 0) and not state.final_sequence
		end

		coroutine.yield()
	end
end

scripts.mega_boss_dragon = {}

function scripts.mega_boss_dragon.update(this, store)
	local state = branch_stage161_state(store)
	state.boss = this
	this.stage161_max_hits = 5
	this.health.hp_max = 5
	this.health.hp = 5 - state.hits
	this.health.immune_to = DAMAGE_ALL_TYPES
	this.enemy.lives_cost = 0
	this.ui.can_click = false
	this.ui.can_select = false
	local function animation(name, loop)
		local phase = branch_stage161_horn_phase(state)
		local suffix = phase == 3 and "Damage2" or phase == 2 and "Damage1" or ""
		U.animation_start(this, name .. suffix, nil, store.tick_ts, loop, 1, true)
	end
	animation("idle", true)
	local horn_ts, freeze_ts, launch_ts = store.tick_ts + 4, store.tick_ts + 9, store.tick_ts + 5
	while store.entities[this.id] and not state.finished and not this.health.dead do
		local phase = branch_stage161_horn_phase(state)
		if this.stage161_hit then
			this.stage161_hit = nil
			animation("toStunned", false)
			U.y_animation_wait(this, 1)
			animation("stunned", true)
			U.y_wait(store, 1)
			animation("toIdle", false)
			U.y_animation_wait(this, 1)
			animation("idle", true)
		elseif store.tick_ts >= horn_ts then
			animation("shoot", false)
			branch_stage161_horn_attack(store, this)
			U.y_animation_wait(this, 1)
			horn_ts = store.tick_ts + (stage161_horn_cooldowns[phase] or 12)
			animation("idle", true)
		elseif store.tick_ts >= freeze_ts then
			local center = branch_find_soldier_cluster_pos(store, 150, 1)
			if not center then
				for _, tower in pairs(store.entities) do
					if tower.tower and tower.tower.type ~= "holder" and not tower.tower_holder then center = tower.pos break end
				end
			end
			if center then
				animation("fire", false)
				S:queue("barbarians_jokull_breath")
				U.y_wait(store, 0.4)
				branch_spawn_scene(store, "fx_jokull_breath", center.x, center.y)
				for _, target in pairs(store.entities) do
					if target.pos and V.dist(target.pos.x, target.pos.y, center.x, center.y) <= 150 then
						local mod_name
						if target.tower and not target.tower_holder then mod_name = "mod_branch_tower_block_frost"
						elseif target.soldier and target.health and not target.health.dead and math.random() < 0.8 then mod_name = "mod_jokull_freeze" end
						if mod_name then
							local mod = E:create_entity(mod_name)
							mod.modifier.source_id, mod.modifier.target_id = this.id, target.id
							mod.modifier.duration = target.tower and 3 or 1
							queue_insert(store, mod)
						end
					end
				end
				U.y_animation_wait(this, 1)
				animation("idle", true)
			end
			freeze_ts = store.tick_ts + (phase == 1 and 16 or 12)
		elseif store.tick_ts >= launch_ts then
			branch_stage161_launch_minions(store, this)
			launch_ts = store.tick_ts + math.random(15, 25)
		else
			coroutine.yield()
		end
	end
	if store.entities[this.id] then
		U.y_animation_play(this, "death", nil, store.tick_ts, 1, 1)
		queue_remove(store, this)
	end
	state.death_finished = true
end


local branch_troll_hut_schedules = {
	[157] = {
		[GAME_MODE_CAMPAIGN] = {"10"},
		[GAME_MODE_HEROIC] = {"10"},
		[GAME_MODE_IRON] = {"10", "1", "11"}
	},
	[158] = {
		[GAME_MODE_IRON] = {"9", "7", "5"}
	},
	[159] = {
		[GAME_MODE_HEROIC] = {"13", "4"},
		[GAME_MODE_IRON] = {"13", "4", "11"}
	},
	[160] = {
		[GAME_MODE_HEROIC] = {"13", "3"},
		[GAME_MODE_IRON] = {"13", "3", "6", "7"}
	},
	[161] = {
		[GAME_MODE_HEROIC] = {"8", "12"},
		[GAME_MODE_IRON] = {"3", "4", "8", "12"}
	},
	[170] = {
		[GAME_MODE_HEROIC] = {"7", "10"},
		[GAME_MODE_IRON] = {"8", "10", "6", "14", "7"},
		discount = true
	},
	[171] = {
		[GAME_MODE_HEROIC] = {"4", "9", "7"},
		[GAME_MODE_IRON] = {"4", "9", "7"},
		discount = true
	},
	[172] = {
		[GAME_MODE_HEROIC] = {"12", "9", "4"},
		[GAME_MODE_IRON] = {"12", "9", "4"},
		discount = true
	},
	[193] = {
		[GAME_MODE_HEROIC] = {"2", "14"},
		[GAME_MODE_IRON] = {"8", "2", "6", "5", "14", "10"},
		discount = true
	},
	[194] = {
		[GAME_MODE_HEROIC] = {"16", "7"},
		discount = true
	},
	[195] = {
		[GAME_MODE_IRON] = {"3"},
		discount = true
	}
}

function branch_apply_troll_hut_prices(discount)
	local spear = E:get_template("mercenary_troll_hunter_spear")
	local axe = E:get_template("mercenary_troll_hunter_axe")

	if spear then spear.unit.price = discount and 20 or 40 end
	if axe then axe.unit.price = discount and 40 or 80 end
end

function branch_replace_holder_with_troll_hut(store, holder_id)
	local holder

	for _, e in pairs(store.entities) do
		if e.tower and tostring(e.tower.holder_id) == tostring(holder_id) then
			holder = e
			break
		end
	end

	if not holder then
		return
	end

	if holder.template_name == "mercenary_troll_hut" then
		return
	end

	local hut = branch_spawn_scene(store, "mercenary_troll_hut", holder.pos.x, holder.pos.y)

	branch_copy_holder_data(holder, hut)

	if hut.barrack and holder.tower.default_rally_pos then
		hut.barrack.rally_pos = V.vclone(holder.tower.default_rally_pos)
	end

	queue_remove(store, holder)
	signal.emit("tower-removed", holder, hut)
end

local zeta_mode_prebuilt_towers = {
	[193] = {
		[GAME_MODE_HEROIC] = {
			{25, {"tower_orc_warriors_den_lvl1"}},
			{26, {"tower_orc_warriors_den_lvl1"}}
		},
		[GAME_MODE_IRON] = {
			{25, {"tower_orc_warriors_den_lvl1"}},
			{26, {"tower_orc_warriors_den_lvl1"}}
		}
	},
	[194] = {
		[GAME_MODE_HEROIC] = {
			{31, {"tower_orc_warriors_den_lvl1"}},
			{32, {"tower_orc_warriors_den_lvl1"}},
			{33, {"tower_orc_warriors_den_lvl1"}},
			{34, {"tower_orc_warriors_den_lvl1"}},
			{35, {"tower_orc_warriors_den_lvl1"}},
			{36, {"tower_orc_warriors_den_lvl1"}},
			{37, {"tower_orc_warriors_den_lvl1"}}
		},
		[GAME_MODE_IRON] = {
			{31, {"tower_orc_warriors_den_lvl1", "tower_swamp_monster_lvl1"}},
			{32, {"tower_orc_warriors_den_lvl1"}}
		}
	},
	[195] = {
		[GAME_MODE_CAMPAIGN] = {{29, {"tower_orc_warriors_den_lvl1"}}},
		[GAME_MODE_HEROIC] = {{28, {"tower_orc_warriors_den_lvl1"}}},
		[GAME_MODE_IRON] = {{3, {"tower_barrack_1"}, keep_source = true}}
	},
	[196] = {
		[GAME_MODE_HEROIC] = {
			{17, {"linirea_caravan"}},
			{18, {"tower_orc_warriors_den_lvl1"}},
			{21, {"linirea_caravan"}},
			{24, {"linirea_caravan_2"}}
		},
		[GAME_MODE_IRON] = {
			{18, {"tower_shaolin_lvl1", "tower_orc_warriors_den_lvl1"}}
		}
	},
	[197] = {
		[GAME_MODE_CAMPAIGN] = {{16, {"zeta_eva2_factory"}}},
		[GAME_MODE_HEROIC] = {
			{1, {"tower_orc_warriors_den_lvl1"}},
			{9, {"tower_wicked_sisters_lvl1", "tower_melting_furnace_lvl1"}}
		},
		[GAME_MODE_IRON] = {
			{9, {"tower_wicked_sisters_lvl1", "tower_orc_warriors_den_lvl1"}},
			{17, {"tower_orc_warriors_den_lvl1"}},
			{11, {"zeta_eva2_factory"}},
			{14, {"zeta_eva2_factory"}}
		}
	},
	[199] = {
		[GAME_MODE_HEROIC] = {
			{11, {"tower_wicked_sisters_lvl1"}},
			{19, {"tower_orc_warriors_den_lvl1"}}
		}
	},
	[200] = {
		[GAME_MODE_HEROIC] = {
			{3, {"tower_infernal_mage_lvl2"}},
			{5, {"tower_infernal_mage_lvl2"}},
			{7, {"tower_infernal_mage_lvl2"}},
			{9, {"tower_infernal_mage_lvl2"}},
			{10, {"tower_infernal_mage_lvl2"}},
			{13, {"tower_infernal_mage_lvl2"}}
		},
		[GAME_MODE_IRON] = {
			{4, {"tower_barrack_3"}},
			{7, {"tower_barrack_3"}},
			{11, {"tower_barrack_3"}},
			{14, {"tower_barrack_3"}}
		}
	},
	[201] = {
		[GAME_MODE_HEROIC] = {
			{14, {"zeta_level19_iron_tower"}},
			{8, {"tower_swamp_monster_lvl1"}},
			{10, {"tower_swamp_monster_lvl1"}}
		},
		[GAME_MODE_IRON] = {
			{3, {"tower_grim_cemetery_lvl1"}},
			{4, {"tower_grim_cemetery_lvl1"}},
			{5, {"tower_grim_cemetery_lvl1"}},
			{6, {"tower_grim_cemetery_lvl1"}},
			{7, {"tower_grim_cemetery_lvl1"}},
			{8, {"tower_grim_cemetery_lvl1"}},
			{9, {"tower_grim_cemetery_lvl1"}},
			{10, {"tower_grim_cemetery_lvl1"}},
			{11, {"tower_grim_cemetery_lvl1"}},
			{13, {"tower_grim_cemetery_lvl1"}},
			{14, {"tower_grim_cemetery_lvl1"}},
			{15, {"tower_grim_cemetery_lvl1"}}
		}
	}
}

local zeta_mode_removed_holders = {
	[199] = {
		[GAME_MODE_HEROIC] = {18},
		[GAME_MODE_IRON] = {18}
	},
	[200] = {
		[GAME_MODE_IRON] = {18}
	}
}

local zeta_mode_extra_lives = {
	[194] = {[GAME_MODE_IRON] = 2},
	[197] = {[GAME_MODE_HEROIC] = 2},
	[199] = {[GAME_MODE_HEROIC] = 2, [GAME_MODE_IRON] = 4},
	[201] = {[GAME_MODE_HEROIC] = 2}
}

local zeta_gold_reward_profiles = {
	gold0 = {wave = 0, min_difficulty = DIFFICULTY_IMPOSSIBLE},
	gold0_med = {wave = 0, min_difficulty = DIFFICULTY_HARD},
	gold0_easy = {wave = 0, min_difficulty = DIFFICULTY_NORMAL},
	gold3 = {wave = 3, min_difficulty = DIFFICULTY_NORMAL},
	gold3_med = {wave = 3, min_difficulty = DIFFICULTY_HARD},
	gold6 = {wave = 6, min_difficulty = DIFFICULTY_HARD},
	gold6_hard = {wave = 6, min_difficulty = DIFFICULTY_IMPOSSIBLE},
	gold6_easy = {wave = 6, min_difficulty = DIFFICULTY_NORMAL},
	gold9 = {wave = 9, min_difficulty = DIFFICULTY_IMPOSSIBLE},
	gold9_easy = {wave = 9, min_difficulty = DIFFICULTY_NORMAL},
	gold12 = {wave = 12, min_difficulty = DIFFICULTY_HARD}
}

local zeta_gold_rewards = {
	[193] = {
		{"gold0", 324, 19},
		{"gold3", 994, 727}, {"gold3", -22, 90}, {"gold3", 30, 707},
		{"gold6", 806, 359}, {"gold6", 515, 647},
		{"gold9", 866, 90},
		{"gold12", 682, 280}
	},
	[194] = {
		{"gold0", 984, 712},
		{"gold3", 606, 254}, {"gold3", -56, 391},
		{"gold6", 470, 287},
		{"gold9", 208, 750},
		{"gold12", 1094, 30}, {"gold12", 353, 148}
	},
	[195] = {
		{"gold0", -76, 468},
		{"gold3", 1142, 338}, {"gold3", 218, 27},
		{"gold6", 940, 655}, {"gold6", 593, 616},
		{"gold9", 983, 410},
		{"gold12", 846, 10}
	},
	[196] = {
		{"gold0", 263, 127},
		{"gold3", 75, 718},
		{"gold6", 1022, 20}, {"gold6", 749, 607},
		{"gold9", 111, 75},
		{"gold12", -80, 95}, {"gold12", 925, 459}
	},
	[197] = {
		{"gold3", 976, 33}, {"gold6_hard", 627, 220}, {"gold9_easy", 460, 48},
		{"gold3_med", 462, 278}, {"gold6", 22, 148}, {"gold9", 43, 469},
		{"gold0_med", 150, 568}, {"gold12", 766, 650}, {"gold0", 835, 502}
	},
	[198] = {
		{"gold0", 645, 592},
		{"gold3", 992, 118}, {"gold3", 505, 727},
		{"gold6", -4, 621},
		{"gold12", 411, 480}, {"gold12", 928, 721}
	},
	[199] = {
		{"gold0", 960, 430}, {"gold0_med", 680, 460},
		{"gold3", 34, 670}, {"gold3", 990, 316},
		{"gold6", 400, 500}, {"gold6", 0, 120},
		{"gold9", 930, 720}, {"gold9", 680, 460},
		{"gold12", 380, 60}, {"gold12", 990, 316}
	},
	[200] = {
		{"gold3", 490, 205}, {"gold6", 480, 430},
		{"gold9", 528, 625}, {"gold9", 928, 648},
		{"gold0_med", 944, 490}, {"gold0_easy", 131, 230},
		{"gold6_easy", 980, 366}, {"gold12", 70, 433}, {"gold0", 813, 80}
	},
	[201] = {
		{"gold0", 769, 88},
		{"gold9", 477, 704}, {"gold9", 894, 495},
		{"gold0_med", 5, 173}, {"gold6", 493, 639}, {"gold12", 519, 50},
		{"gold3", 106, 577}, {"gold3", 511, 444}
	}
}

local function zeta_spawn_gold_rewards(store, level)
	if store.level_mode ~= GAME_MODE_CAMPAIGN then
		return
	end

	for _, cfg in ipairs(zeta_gold_rewards[level] or {}) do
		local profile = zeta_gold_reward_profiles[cfg[1]]

		if profile and (store.level_difficulty or DIFFICULTY_NORMAL) >= profile.min_difficulty then
			local spawner = branch_spawn_scene(store, "zeta_gold_reward_spawner", cfg[2], cfg[3])

			spawner.wave = profile.wave
		end
	end
end

local function zeta_find_holder_entity(store, holder_id)
	for _, e in pairs(store.entities) do
		if e.tower and tostring(e.tower.holder_id) == tostring(holder_id) then
			return e
		end
	end
end

local function zeta_spawn_prebuilt_towers(store, cfg)
	local source = zeta_find_holder_entity(store, cfg[1])

	if not source then
		return
	end

	for _, template_name in ipairs(cfg[2] or {}) do
		local tower = branch_spawn_scene(store, template_name, source.pos.x, source.pos.y)

		branch_copy_holder_data(source, tower)
		branch_apply_holder_visual(tower)

		if tower.barrack and source.tower.default_rally_pos then
			tower.barrack.rally_pos = V.vclone(source.tower.default_rally_pos)
		end

		if tower.render and tower.render.sprites then
			for _, sprite in pairs(tower.render.sprites) do
				sprite.ts = store.tick_ts
			end
		end

		signal.emit("tower-spawn", source, tower)
	end

	if not cfg.keep_source then
		queue_remove(store, source)
		signal.emit("tower-removed", source)
	end
end

local function zeta_apply_mode_towers(store, level)
	local removed = zeta_mode_removed_holders[level]

	for _, holder_id in ipairs(removed and removed[store.level_mode] or {}) do
		local holder = zeta_find_holder_entity(store, holder_id)

		if holder then
			queue_remove(store, holder)
			signal.emit("tower-removed", holder)
		end
	end

	local by_level = zeta_mode_prebuilt_towers[level]

	for _, cfg in ipairs(by_level and by_level[store.level_mode] or {}) do
		zeta_spawn_prebuilt_towers(store, cfg)
	end

	local lives = zeta_mode_extra_lives[level]

	if lives and lives[store.level_mode] then
		store.lives = store.lives + lives[store.level_mode]
	end
end

local function stage185_units(rug, snake, merchant)
	local units = {}

	for i = 1, rug or 0 do table.insert(units, "enemy_hammerhold_citizen_rugmerchant") end
	for i = 1, snake or 0 do table.insert(units, "enemy_hammerhold_citizen_snakecharmer") end
	for i = 1, merchant or 0 do table.insert(units, "enemy_hammerhold_citizen") end

	return units
end

local stage183_iron_ambushes = {
	{delay = 6, path = 0, subpath = 1, node = 74, count = 2, interval = 4, x = 935, y = 230, flip_x = true},
	{delay = 4, path = 1, subpath = 2, node = 72, count = 2, interval = 4, x = 935, y = 230, flip_x = true},
	{delay = 14, path = 1, subpath = 1, node = 52, count = 2, interval = 2, x = 667, y = 481, flip_x = true},
	{delay = 15, path = 0, subpath = 2, node = 59, count = 2, interval = 2, x = 568, y = 459},
	{delay = 28, path = 0, subpath = 1, node = 59, count = 2, interval = 2, x = 568, y = 459},
	{delay = 30, path = 1, subpath = 2, node = 72, count = 2, interval = 2, x = 935, y = 230, flip_x = true},
	{delay = 45, path = 0, subpath = 2, node = 90, count = 2, interval = 4, x = 519, y = 434, flip_x = true},
	{delay = 46, path = 0, subpath = 2, node = 92, count = 2, interval = 4, x = 406, y = 417},
	{delay = 47, path = 1, subpath = 1, node = 100, count = 4, interval = 2, x = 627, y = 134, flip_x = true},
	{delay = 70, path = 0, node = 160, count = 7, interval = 2, x = 402, y = 152, flip_x = true},
	{delay = 70, path = 1, node = 160, count = 4, interval = 4, x = 430, y = 463, flip_x = true},
	{delay = 72, path = 1, node = 160, count = 3, interval = 4, x = 465, y = 480, flip_x = true},
	{delay = 120, path = 0, node = 160, count = 4, interval = 2, x = 402, y = 152, flip_x = true},
	{delay = 120, path = 1, node = 160, count = 2, interval = 4, x = 430, y = 463, flip_x = true},
	{delay = 122, path = 1, node = 160, count = 2, interval = 4, x = 465, y = 480, flip_x = true},
	{delay = 96, path = 0, subpath = 1, node = 90, count = 6, interval = 1, x = 610, y = 358},
	{delay = 95, path = 1, subpath = 2, node = 90, count = 3, interval = 2, x = 879, y = 178, flip_x = true},
	{delay = 95, path = 1, subpath = 2, node = 90, count = 3, interval = 2, x = 749, y = 140},
	{delay = 114, path = 0, subpath = 1, node = 74, count = 1, interval = 4, x = 935, y = 230, flip_x = true},
	{delay = 114, path = 1, subpath = 2, node = 72, count = 1, interval = 4, x = 935, y = 230, flip_x = true},
	{delay = 114, path = 1, subpath = 1, node = 52, count = 2, interval = 2, x = 667, y = 481, flip_x = true},
	{delay = 118, path = 0, subpath = 2, node = 59, count = 2, interval = 2, x = 568, y = 459},
	{delay = 118, path = 0, subpath = 1, node = 59, count = 2, interval = 2, x = 568, y = 459},
	{delay = 122, path = 1, subpath = 2, node = 72, count = 2, interval = 2, x = 935, y = 230, flip_x = true},
	{delay = 122, path = 0, subpath = 2, node = 90, count = 1, interval = 4, x = 519, y = 434, flip_x = true}
}

local function stage183_queue_nomad_ambush(store, active_spawns, cfg)
	table.insert(active_spawns, {
		cfg = cfg,
		remaining = cfg.count,
		next_ts = store.tick_ts
	})
end

local function stage183_update_nomad_ambushes(store, active_spawns)
	for i = #active_spawns, 1, -1 do
		local spawner = active_spawns[i]
		local cfg = spawner.cfg

		if spawner.remaining <= 0 then
			table.remove(active_spawns, i)
		elseif store.tick_ts >= spawner.next_ts then
			local spawn_pos = V.v(cfg.x + math.random(-4, 4), cfg.y + math.random(-4, 4))
			local unit = branch_spawn_from_pos_to_path(store, "enemy_legion_nomad", spawn_pos,
				branch_kr4_path_rank(cfg.path), (cfg.subpath or 0) + 1, cfg.node)

			if unit then
				if unit.branch then
					unit.branch.spawn_animation = "spawn"
				end

				for _, sprite in ipairs(unit.render and unit.render.sprites or {}) do
					sprite.flip_x = cfg.flip_x or false
				end
			end

			spawner.remaining = spawner.remaining - 1
			spawner.next_ts = store.tick_ts + cfg.interval
		end
	end
end

local function stage185_roofs(wave, delay, positions)
	local out = {}

	for _, p in ipairs(positions) do
		table.insert(out, {wave = wave, delay = delay, kind = "roof", x = p[1], y = p[2]})
	end

	return out
end

local stage185_roof_positions = {{128, 673}, {318, 261}, {879, 666}, {660, 242}}
local stage185_special_schedules = {
	{wave = 1, delay = 27, path = 7, node = 120, x = 613, y = 643, interval = 0.8, units = stage185_units(2, 3)},
	{wave = 2, delay = 2, path = 7, node = 50, x = 129, y = 619, interval = 0.7, units = stage185_units(4, 5)},
	{wave = 2, delay = 25, path = 7, node = 50, x = 129, y = 619, interval = 0.8, units = stage185_units(2, 1)},
	{wave = 2, delay = 39, path = 0, node = 74, x = 410, y = 362, interval = 0.8, units = stage185_units(3, 1)},
	{wave = 3, delay = 17, path = 0, node = 74, x = 410, y = 362, interval = 0.8, units = stage185_units(3, 4)},
	{wave = 5, delay = 12, path = 7, node = 120, x = 613, y = 643, interval = 0.8, units = stage185_units(2, 3)},
	{wave = 5, delay = 17, path = 7, node = 120, x = 613, y = 643, interval = 0.8, units = stage185_units(0, 0, 3)},
	{wave = 7, delay = 33, path = 7, node = 50, x = 129, y = 619, interval = 0.8, units = stage185_units(4, 4)},
	{wave = 9, delay = 0, path = 7, node = 50, x = 129, y = 619, interval = 0.7, units = stage185_units(4, 4)},
	{wave = 9, delay = 0, path = 0, node = 74, x = 410, y = 362, interval = 0.7, units = stage185_units(2, 2)},
	{wave = 9, delay = 0, path = 7, node = 110, x = 613, y = 650, interval = 0.7, units = stage185_units(3, 3)},
	{wave = 9, delay = 50, path = 7, node = 50, x = 129, y = 619, interval = 0.7, units = stage185_units(4, 4)},
	{wave = 9, delay = 50, path = 0, node = 74, x = 410, y = 362, interval = 0.7, units = stage185_units(2, 2)},
	{wave = 9, delay = 50, path = 7, node = 110, x = 613, y = 650, interval = 0.7, units = stage185_units(3, 3)},
	{wave = 11, delay = 45, path = 7, node = 50, x = 129, y = 619, interval = 0.7, units = stage185_units(5, 4)},
	{wave = 11, delay = 45, path = 0, node = 74, x = 410, y = 362, interval = 0.7, units = stage185_units(3, 4)},
	{wave = 13, delay = 0, path = 7, node = 50, x = 129, y = 619, interval = 0.7, units = stage185_units(4, 4)},
	{wave = 13, delay = 0, path = 0, node = 74, x = 410, y = 362, interval = 0.7, units = stage185_units(2, 2)},
	{wave = 13, delay = 0, path = 7, node = 110, x = 613, y = 650, interval = 0.7, units = stage185_units(3, 3)},
	{wave = 13, delay = 25, path = 7, node = 120, x = 613, y = 643, interval = 0.8, units = stage185_units(2, 1)},
	{wave = 13, delay = 30, path = 7, node = 120, x = 613, y = 643, interval = 0.8, units = stage185_units(0, 0, 3)},
	{wave = 13, delay = 70, path = 7, node = 50, x = 129, y = 619, interval = 0.7, units = stage185_units(4, 4)},
	{wave = 13, delay = 70, path = 0, node = 74, x = 410, y = 362, interval = 0.7, units = stage185_units(2, 2)},
	{wave = 15, delay = 8, path = 7, node = 110, x = 613, y = 650, interval = 0.9, units = stage185_units(0, 15)},
	{wave = 15, delay = 13, path = 0, node = 74, x = 410, y = 362, interval = 0.9, units = stage185_units(0, 15)},
	{wave = 15, delay = 15, path = 7, node = 110, x = 613, y = 650, interval = 0.9, units = stage185_units(15, 0)},
	{wave = 15, delay = 18, path = 7, node = 50, x = 129, y = 619, interval = 0.9, units = stage185_units(15, 0)},
	{wave = 15, delay = 20, path = 0, node = 74, x = 410, y = 362, interval = 0.9, units = stage185_units(15, 0)},
	{wave = 15, delay = 25, path = 7, node = 50, x = 129, y = 619, interval = 0.9, units = stage185_units(0, 15)}
}

local function zeta_storm_event(wave, delay, duration, army, units, towers, interval, tower_duration,
		speed_factor, emission_rate)
	return {
		wave = wave,
		delay = delay,
		kind = "storm",
		pos = V.v(337, 706),
		duration = duration,
		army = army,
		storm = {
			units_amount = units,
			towers_amount = towers,
			modifier_interval = interval,
			tower_block_duration = tower_duration,
			unit_freeze_duration = 4,
			unit_speed_duration = 2.5,
			unit_speed_factor = speed_factor,
			particle_emission_rate = emission_rate or 50
		}
	}
end

local function zeta_spawn_event(wave, delay, template, count, interval, path, subpath, node, pos)
	return {
		wave = wave,
		delay = delay,
		kind = "spawn",
		spawn_template = template,
		spawn_count = count or 1,
		spawn_interval = interval or 0,
		spawn_path = path,
		spawn_subpath = subpath,
		spawn_node = node,
		spawn_pos = pos,
		pos = pos
	}
end

local function zeta_missile_event(wave, delay, pos, path, subpath, node)
	return {
		wave = wave,
		delay = delay,
		kind = "missile",
		pos = pos,
		spawn_path = path,
		spawn_subpath = subpath,
		spawn_node = node,
		duration = 28,
		attack_interval = 5,
		damage_radius = 67.5,
		damage_min = 60,
		damage_max = 120
	}
end

local zeta_stage_schedules = {
	[193] = {
		[GAME_MODE_CAMPAIGN] = {
			zeta_storm_event(1, 8, 30, 1, 3, 3, 15, 120),
			zeta_storm_event(1, 8, 30, 0, 100, 0, 30, nil, 1.8),
			zeta_storm_event(3, 8, 30, 1, 3, 3, 15, 120),
			zeta_storm_event(3, 8, 30, 0, 100, 0, 30, nil, 1.8),
			zeta_storm_event(10, 8, 30, 1, 3, 3, 15, 120),
			zeta_storm_event(10, 8, 30, 0, 100, 0, 30, nil, 1.8),
			zeta_storm_event(15, 8, 18, 1, 3, 3, 15, 4, nil, 150),
			zeta_storm_event(15, 8, 18, 0, 100, 0, 15, nil, 1.8, 150),
			zeta_storm_event(15, 58, 18, 1, 3, 3, 15, 4, nil, 150),
			zeta_storm_event(15, 58, 18, 0, 100, 0, 15, nil, 1.8, 150)
		},
		[GAME_MODE_HEROIC] = {
			zeta_spawn_event(1, 0, "enemy_zeta_draugr_flag1", 1, 0, 7, 1, 10),
			zeta_spawn_event(1, 0, "enemy_zeta_draugr_flag0", 1, 0, 7, 1, 10),
			zeta_spawn_event(2, 0, "enemy_zeta_draugr_flag1", 1, 0, 7, 1, 10),
			zeta_spawn_event(3, 0, "enemy_zeta_draugr_flag1", 1, 0, 7, 1, 10),
			zeta_spawn_event(4, 0, "enemy_zeta_draugr_flag1", 1, 0, 7, 1, 10),
			zeta_spawn_event(5, 0, "enemy_zeta_draugr_flag1", 1, 0, 7, 1, 10)
		},
		[GAME_MODE_IRON] = {
			zeta_storm_event(1, 0, 450, 1, 75, 50, 450, 10)
		}
	},
	[194] = {
		[GAME_MODE_CAMPAIGN] = {
			zeta_spawn_event(1, 5, "enemy_draugr_gold", 5, 3, 2, 1, 286, V.v(904, 44)),
			zeta_spawn_event(1, 30, "enemy_draugr_gold", 5, 3, 2, 1, 286, V.v(904, 44)),
			zeta_spawn_event(3, 5, "enemy_draugr_gold", 10, 3, 2, 1, 286, V.v(904, 44)),
			zeta_spawn_event(3, 35, "enemy_draugr_gold", 5, 3, 2, 1, 286, V.v(904, 44)),
			zeta_storm_event(4, 8, 12, 1, 1, 1, 15, 120),
			zeta_storm_event(4, 8, 12, 0, 100, 0, 30, nil, 1.8),
			zeta_spawn_event(6, 5, "enemy_draugr_gold", 10, 3, 2, 1, 286, V.v(904, 44)),
			zeta_spawn_event(9, 55, "enemy_draugr_gold", 10, 3, 2, 1, 286, V.v(904, 44)),
			zeta_spawn_event(10, 5, "enemy_draugr_gold", 30, 3, 2, 1, 286, V.v(904, 44)),
			zeta_spawn_event(13, 10, "enemy_draugr_gold", 60, 3, 2, 1, 286, V.v(904, 44)),
			zeta_storm_event(13, 80, 25, 1, 4, 3, 15, 120),
			zeta_storm_event(13, 80, 25, 0, 100, 0, 30, nil, 1.8),
			zeta_spawn_event(14, 5, "enemy_draugr_gold", 15, 3, 2, 1, 286, V.v(904, 44)),
			zeta_spawn_event(14, 5, "enemy_draugr_gold", 15, 3, 2, 1, 286, V.v(904, 44)),
			zeta_storm_event(14, 45, 30, 1, 5, 2, 15, 120),
			zeta_spawn_event(14, 56, "enemy_draugr_gold", 10, 3, 2, 1, 286, V.v(904, 44)),
			zeta_storm_event(14, 75, 50, 0, 100, 0, 30, nil, 1.8),
			zeta_spawn_event(15, 10, "enemy_draugr_gold", 25, 3, 2, 1, 286, V.v(904, 44))
		},
		[GAME_MODE_HEROIC] = {
			zeta_spawn_event(1, 18, "enemy_draugr_gold", 12, 3, 2, 1, 286, V.v(904, 44)),
			zeta_spawn_event(3, 1, "enemy_draugr_gold", 8, 3, 2, 1, 286, V.v(904, 44)),
			zeta_spawn_event(6, 36, "enemy_draugr_gold", 20, 3, 2, 1, 286, V.v(904, 44))
		},
		[GAME_MODE_IRON] = {
			{wave = 1, delay = 10, kind = "levitate", pos = V.v(904, 44), modifier_interval = 20,
				units_amount = 15, unit_freeze_duration = 5}
		}
	},
	[195] = {
		[GAME_MODE_CAMPAIGN] = {
			zeta_spawn_event(4, 15, "enemy_draugr_armor", 1, 3, 7, 1, 1),
			zeta_spawn_event(4, 16, "enemy_draugr_gold", 4, 3, 7, 1, 1),
			zeta_storm_event(5, 36, 18, 1, 2, 2, 15, 120),
			zeta_storm_event(5, 36, 18, 0, 60, 0, 30, nil, 1.8),
			zeta_spawn_event(8, 1, "enemy_apex_stalker", 2, 3, 8, 1, 1),
			zeta_spawn_event(8, 20, "enemy_apex_stalker", 3, 3, 8, 1, 1),
			zeta_spawn_event(8, 29, "enemy_apex_stalker", 3, 3, 8, 1, 1),
			zeta_storm_event(10, 30, 18, 1, 5, 4, 15, 120),
			zeta_storm_event(10, 30, 18, 0, 80, 0, 30, nil, 1.8),
			zeta_spawn_event(11, 16, "enemy_blue_wyvern", 5, 1, 7, 1, 1),
			zeta_spawn_event(11, 16, "enemy_blue_wyvern", 5, 1, 8, 1, 1),
			zeta_spawn_event(11, 38, "enemy_frost_giant", 1, 3, 7, 1, 1),
			zeta_spawn_event(11, 38, "enemy_frost_giant", 1, 3, 8, 1, 1),
			zeta_spawn_event(12, 69, "enemy_valkyrie", 1, 1, 7, 1, 1),
			zeta_spawn_event(12, 71, "enemy_valkyrie", 1, 1, 8, 1, 1),
			zeta_spawn_event(12, 78, "enemy_valkyrie", 1, 1, 7, 1, 1),
			zeta_spawn_event(12, 80, "enemy_valkyrie", 1, 1, 8, 1, 1),
			zeta_spawn_event(14, 14, "enemy_draugr_armor", 25, 2.4, 8, 1, 1),
			zeta_spawn_event(14, 31, "enemy_winter_lord_mage", 1, 4, 7, 1, 1),
			zeta_storm_event(14, 33, 29, 1, 12, 10, 15, 120),
			zeta_storm_event(14, 33, 29, 0, 80, 0, 30, nil, 1.8),
			zeta_spawn_event(14, 43, "enemy_winter_lord_mage", 1, 4, 7, 1, 1),
			zeta_spawn_event(15, 35, "enemy_apex_stalker", 2, 3, 8, 1, 1),
			zeta_spawn_event(15, 35, "enemy_winter_lord_mage", 5, 2, 7, 1, 1),
			zeta_spawn_event(15, 43, "enemy_ice_golem", 1, 5, 8, 1, 1),
			zeta_spawn_event(15, 70, "enemy_apex_stalker", 3, 1.5, 8, 1, 1),
			zeta_spawn_event(15, 76, "enemy_apex_stalker", 3, 2, 7, 1, 1),
			zeta_storm_event(16, 30, 600, 0, 30, 0, 30, nil, 1.8)
		}
	},
	[197] = {
		[GAME_MODE_CAMPAIGN] = {
			{wave = 7, delay = 2.4, kind = "factory", pos = V.v(662, 197), activate_delay = 2.8,
				activate_paths = {2, 4, 7}, spawn_pos = V.v(662, 218), spawn_template = "enemy_toxic_blob",
				spawn_count = 3, spawn_interval = 0.5, spawn_path = 2, spawn_subpath = 0, spawn_node = 139}
		}
	},
	[198] = {
		[GAME_MODE_CAMPAIGN] = {
			zeta_missile_event(2, 5, V.v(637, 504), 5, 3, 6),
			zeta_missile_event(5, 12, V.v(637, 504), 5, 3, 6),
			zeta_missile_event(6, 1, V.v(637, 504), 5, 3, 6), zeta_missile_event(6, 25, V.v(637, 504), 5, 3, 6),
			zeta_missile_event(8, 1, V.v(637, 504), 5, 3, 6), zeta_missile_event(8, 30, V.v(637, 504), 5, 3, 6),
			zeta_missile_event(11, 1, V.v(637, 504), 5, 3, 6), zeta_missile_event(11, 30, V.v(637, 504), 5, 3, 6),
			zeta_missile_event(11, 55, V.v(637, 504), 5, 3, 6),
			zeta_missile_event(13, 1, V.v(637, 504), 5, 3, 6), zeta_missile_event(13, 55, V.v(637, 504), 5, 3, 6),
			zeta_missile_event(14, 10, V.v(637, 504), 5, 3, 6),
			zeta_missile_event(15, 1, V.v(637, 504), 5, 3, 6), zeta_missile_event(15, 35, V.v(637, 504), 5, 3, 6)
		},
		[GAME_MODE_HEROIC] = {
			zeta_missile_event(1, 5, V.v(637, 504), 5, 3, 6), zeta_missile_event(2, 5, V.v(637, 504), 5, 3, 6),
			zeta_missile_event(4, 5, V.v(637, 504), 5, 3, 6), zeta_missile_event(6, 1, V.v(637, 504), 5, 3, 6),
			zeta_missile_event(6, 30, V.v(637, 504), 5, 3, 6)
		},
		[GAME_MODE_IRON] = {
			zeta_missile_event(1, 1, V.v(637, 504), 5, 3, 6), zeta_missile_event(3, 1, V.v(637, 504), 5, 3, 6)
		}
	},
	[199] = {
		[GAME_MODE_CAMPAIGN] = {
			zeta_missile_event(3, 5, V.v(960, 388), 3, 1, 160),
			zeta_missile_event(5, 5, V.v(960, 388), 3, 1, 160), zeta_missile_event(5, 20, V.v(960, 388), 3, 1, 160),
			zeta_missile_event(6, 5, V.v(960, 388), 3, 1, 160), zeta_missile_event(8, 5, V.v(960, 388), 3, 1, 160),
			zeta_missile_event(10, 11, V.v(960, 388), 3, 1, 160), zeta_missile_event(10, 30, V.v(960, 388), 3, 1, 160),
			zeta_missile_event(10, 45, V.v(960, 388), 3, 1, 160), zeta_missile_event(13, 5, V.v(960, 388), 3, 1, 160),
			zeta_missile_event(13, 18, V.v(960, 388), 3, 1, 160), zeta_missile_event(14, 24, V.v(960, 388), 3, 1, 160)
		},
		[GAME_MODE_HEROIC] = {
			zeta_missile_event(1, 5, V.v(960, 388), 3, 1, 160), zeta_missile_event(3, 1, V.v(960, 388), 3, 1, 160),
			zeta_missile_event(3, 25, V.v(960, 388), 3, 1, 160), zeta_missile_event(5, 1, V.v(960, 388), 3, 1, 160),
			zeta_missile_event(5, 25, V.v(960, 388), 3, 1, 160)
		}
	},
	[200] = {
		[GAME_MODE_CAMPAIGN] = {
			zeta_missile_event(3, 5, V.v(100, 380), 3, 1, 16),
			{wave = 4, delay = 2.4, kind = "stone", stone = 1, pos = V.v(470, 195), activate_delay = 2.8, activate_paths = {7, 10}},
			zeta_missile_event(5, 5, V.v(100, 380), 3, 1, 16), zeta_missile_event(5, 20, V.v(100, 380), 3, 1, 16),
			zeta_missile_event(6, 15, V.v(100, 380), 3, 1, 16),
			{wave = 7, delay = 2.4, kind = "stone", stone = 2, pos = V.v(470, 370), activate_delay = 2.8, activate_paths = {3, 5}},
			zeta_missile_event(9, 15, V.v(100, 380), 3, 1, 16), zeta_missile_event(9, 40, V.v(100, 380), 3, 1, 16),
			{wave = 10, delay = 2.4, kind = "stone", stone = 3, pos = V.v(518, 565), activate_delay = 2.8, activate_paths = {1}},
			zeta_missile_event(10, 30, V.v(100, 380), 3, 1, 16), zeta_missile_event(12, 10, V.v(100, 380), 3, 1, 16),
			zeta_missile_event(13, 2, V.v(100, 380), 3, 1, 16), zeta_missile_event(13, 14, V.v(100, 380), 3, 1, 16),
			zeta_missile_event(15, 5, V.v(100, 380), 3, 1, 16), zeta_missile_event(15, 21, V.v(100, 380), 3, 1, 16),
			zeta_missile_event(15, 39, V.v(100, 380), 3, 1, 16),
			zeta_spawn_event(16, 6, "enemy_kr4_boss_red_triplet", 1, 0, 3, 1, 16, V.v(100, 380)),
			zeta_spawn_event(16, 6, "enemy_demon_endgame_spawner", 1, 0, 8, 1, 1, V.v(500, 305)),
			zeta_spawn_event(16, 6, "enemy_kr4_enemy_demon_oloch", 1, 0, 8, 1, 1, V.v(185, 395))
		},
		[GAME_MODE_HEROIC] = {
			zeta_missile_event(2, 5, V.v(960, 388), 3, 1, 16), zeta_missile_event(2, 18, V.v(960, 388), 3, 1, 16),
			zeta_missile_event(4, 1, V.v(960, 388), 3, 1, 16), zeta_missile_event(4, 4, V.v(960, 388), 3, 1, 16),
			zeta_missile_event(4, 87, V.v(960, 388), 3, 1, 16), zeta_missile_event(6, 1, V.v(960, 388), 3, 1, 16),
			zeta_missile_event(6, 25, V.v(960, 388), 3, 1, 16)
		}
	},
	[201] = {
		[GAME_MODE_CAMPAIGN] = {
			{wave = 16, delay = 1, kind = "altar"}
		}
	}
}

local zeta_level20_iron_enemy_storms = {
	{8, 7, 8, 12}, {26, 10, 10, 12}, {41, 7, 8, 12}, {58, 6, 8, 12},
	{72, 9, 10, 12}, {85, 12, 14, 12}, {104, 6, 8, 12}, {115, 14, 15, 12},
	{136, 6, 10, 12}, {151, 11, 15, 12}, {171, 9, 10, 12}, {193, 6, 8, 6},
	{208, 11, 13, 6}, {233, 5, 8, 6}, {250, 5, 6, 6}, {258, 3, 4, 6},
	{265, 10, 13, 6}, {289, 6, 8, 6}, {304, 8, 8, 6}, {314, 4, 4, 6},
	{330, 6, 8, 6}, {344, 6, 6, 6}, {354, 9, 9, 6}, {370, 5, 8, 6},
	{381, 7, 8, 6}, {397, 13, 15, 6}, {416, 8, 8, 6}, {426, 4, 4, 6},
	{434, 4, 4, 6}, {442, 4, 4, 6}
}

for _, cfg in ipairs(zeta_level20_iron_enemy_storms) do
	table.insert(zeta_stage_schedules[193][GAME_MODE_IRON],
		zeta_storm_event(1, cfg[1], cfg[2], 0, cfg[4], 0, cfg[3], nil, 1.4))
end

for _, e in ipairs(stage185_roofs(3, 0, {{128, 673}, {660, 242}})) do table.insert(stage185_special_schedules, e) end
for _, e in ipairs(stage185_roofs(3, 25, {{128, 673}, {660, 242}})) do table.insert(stage185_special_schedules, e) end
for _, e in ipairs(stage185_roofs(4, 0, {{879, 666}, {318, 261}})) do table.insert(stage185_special_schedules, e) end
for _, e in ipairs(stage185_roofs(4, 20, {{879, 666}, {318, 261}})) do table.insert(stage185_special_schedules, e) end
for _, e in ipairs(stage185_roofs(4, 40, {{879, 666}, {318, 261}})) do table.insert(stage185_special_schedules, e) end
for _, e in ipairs(stage185_roofs(8, 0, stage185_roof_positions)) do table.insert(stage185_special_schedules, e) end
for _, e in ipairs(stage185_roofs(8, 30, stage185_roof_positions)) do table.insert(stage185_special_schedules, e) end
for _, e in ipairs(stage185_roofs(8, 50, stage185_roof_positions)) do table.insert(stage185_special_schedules, e) end
for _, e in ipairs(stage185_roofs(11, 0, {{879, 666}, {660, 242}})) do table.insert(stage185_special_schedules, e) end
for _, e in ipairs(stage185_roofs(11, 20, {{879, 666}, {660, 242}})) do table.insert(stage185_special_schedules, e) end
for _, e in ipairs(stage185_roofs(12, 0, stage185_roof_positions)) do table.insert(stage185_special_schedules, e) end
for _, e in ipairs(stage185_roofs(12, 30, stage185_roof_positions)) do table.insert(stage185_special_schedules, e) end
for _, e in ipairs(stage185_roofs(15, 15, stage185_roof_positions)) do table.insert(stage185_special_schedules, e) end
for _, e in ipairs(stage185_roofs(15, 45, stage185_roof_positions)) do table.insert(stage185_special_schedules, e) end
for _, e in ipairs(stage185_roofs(15, 75, stage185_roof_positions)) do table.insert(stage185_special_schedules, e) end

function stage185_queue_special_event(store, active_spawns, cfg)
	if cfg.kind == "roof" then
		branch_spawn_scene(store, "hammerhold_roof_archer", cfg.x, cfg.y)
		return
	end

	table.insert(active_spawns, {
		units = cfg.units or {},
		index = 1,
		next_ts = store.tick_ts,
		interval = cfg.interval or 0.8,
		path = branch_kr4_path_rank(cfg.path),
		subpath = (cfg.subpath or 0) + 1,
		node = cfg.node,
		x = cfg.x,
		y = cfg.y
	})
end

function stage185_update_special_spawns(store, active_spawns)
	for i = #active_spawns, 1, -1 do
		local spawner = active_spawns[i]

		if spawner.index > #spawner.units then
			table.remove(active_spawns, i)
		elseif store.tick_ts >= spawner.next_ts then
			local template = spawner.units[spawner.index]
			local spawn_pos = V.v((spawner.x or 0) + math.random(-4, 4), (spawner.y or 0) + math.random(-4, 4))

			branch_spawn_from_pos_to_path(store, template, spawn_pos, spawner.path, spawner.subpath, spawner.node)
			spawner.index = spawner.index + 1
			spawner.next_ts = store.tick_ts + spawner.interval
		end
	end
end

local stage155_factory_schedules = {
	[GAME_MODE_CAMPAIGN] = {
		{wave = 6, delay = 5, action = "open_line"},
		{wave = 6, delay = 5, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 3}, source = "line"},
		{wave = 6, delay = 20, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 8, delay = 5, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 8, delay = 65, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 10, delay = 5, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 10, delay = 20, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 10, delay = 35, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 10, delay = 50, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 12, delay = 3, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 12, delay = 30, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 12, delay = 45, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 15, delay = 3, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 15, delay = 35, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 15, delay = 50, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 15, delay = 55, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {2}, source = "machine"}
	},
	[GAME_MODE_HEROIC] = {
		{wave = 1, delay = 0, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 2}, source = "line"},
		{wave = 1, delay = 16, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 2}, source = "line"},
		{wave = 1, delay = 32, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 2}, source = "line"},
		{wave = 1, delay = 48, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 2}, source = "line"},
		{wave = 1, delay = 64, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 3}, source = "line"},
		{wave = 1, delay = 80, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 3}, source = "line"},
		{wave = 1, delay = 96, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 3}, source = "line"},
		{wave = 2, delay = 0, action = "open_line"},
		{wave = 3, delay = 0, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 3, delay = 16, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 3, delay = 32, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 3, delay = 48, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 3, delay = 64, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 3, delay = 80, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 4, delay = 0, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 4, delay = 15, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 4, delay = 25, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 4, delay = 30, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 4, delay = 45, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 4, delay = 60, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 4, delay = 73, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 4, delay = 86, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 4, delay = 99, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 5, delay = 20, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 5, delay = 50, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 5, delay = 80, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 6, delay = 0, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 2}, source = "line"},
		{wave = 6, delay = 12, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 2}, source = "line"},
		{wave = 6, delay = 24, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 2}, source = "line"},
		{wave = 6, delay = 30, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 6, delay = 36, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 2}, source = "line"},
		{wave = 6, delay = 48, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 2}, source = "line"},
		{wave = 6, delay = 55, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 6, delay = 60, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 6, delay = 72, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 6, delay = 80, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 6, delay = 84, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 6, delay = 96, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 6, delay = 100, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 6, delay = 108, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"}
	},
	[GAME_MODE_IRON] = {
		{wave = 1, delay = 65, action = "open_line"},
		{wave = 1, delay = 150, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 1, delay = 185, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 2}, source = "line"},
		{wave = 1, delay = 210, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 2}, source = "line"},
		{wave = 1, delay = 220, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 1, delay = 235, enemy = "enemy_chomp_bot", path = 4, count = 2, subpaths = {1, 2}, source = "line"},
		{wave = 1, delay = 260, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 1, delay = 285, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 1, delay = 310, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 1, delay = 400, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 1, delay = 420, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 1, delay = 420, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 1, delay = 440, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 1, delay = 450, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 1, delay = 460, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 1, delay = 475, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 1, delay = 480, enemy = "enemy_mechadwarf", path = 5, count = 1, subpaths = {1}, source = "machine"},
		{wave = 1, delay = 490, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 1, delay = 505, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 1, delay = 520, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"},
		{wave = 1, delay = 535, enemy = "enemy_chomp_bot", path = 4, count = 3, subpaths = {1, 2, 3}, source = "line"}
	}
}

function stage155_set_hidden(entity, hidden)
	if not entity or not entity.render or not entity.render.sprites then
		return
	end

	for _, sprite in pairs(entity.render.sprites) do
		sprite.hidden = hidden
	end
end

function stage155_set_ramp_open(ramp)
	local sprite = ramp and ramp.render and ramp.render.sprites and ramp.render.sprites[1]

	if sprite then
		sprite.hidden = false
		sprite.name = "Stage5_ramp_pc_0025"
		sprite.animated = false
	end
end

function stage155_factory_spawn_pos(cfg)
	if cfg and cfg.spawn_pos then
		return V.v(cfg.spawn_pos.x, cfg.spawn_pos.y)
	elseif cfg and cfg.source == "machine" then
		return V.v(871, 592)
	else
		return V.v(200, 607)
	end
end

function stage155_factory_path(cfg)
	return branch_kr4_path_rank(cfg and cfg.path)
end

function stage155_line_start_animation(line, animation, ts, loop)
	if not line or not line.render or not line.render.sprites then
		return
	end

	for sid, s in pairs(line.render.sprites) do
		if s.animated and not s.hidden then
			U.animation_start(line, animation, nil, ts, loop, sid, true)
		end
	end
end

function stage155_line_play_animation(store, line, animation)
	if not line or not store.entities[line.id] then
		return
	end

	stage155_line_start_animation(line, animation, store.tick_ts, false)

	while store.entities[line.id] and not U.animation_finished(line, 1) do
		coroutine.yield()
	end
end

function stage155_show_factory_line(store, ramp, line, instant)
	stage155_set_hidden(ramp, false)
	stage155_set_hidden(line, false)

	if ramp and store.entities[ramp.id] then
		if instant then
			stage155_set_ramp_open(ramp)
		else
			U.animation_start(ramp, "ramp_run", nil, store.tick_ts, false, 1)
			S:queue("level5_rightbridge")
		end
	end

	if line and store.entities[line.id] then
		if not instant then
			stage155_line_play_animation(store, line, "open")
		end

		stage155_line_start_animation(line, "move", store.tick_ts, true)
	end
end

function stage155_play_factory_source(store, cfg, machine, ramp, line, line_open)
	if cfg.source == "machine" then
		if machine and store.entities[machine.id] then
			U.animation_start(machine, "run", nil, store.tick_ts, false)
			S:queue("level5_mechafactory_elevator")
			S:queue("level5_mechafactory_construction")
		end
		U.y_wait(store, cfg.spawn_delay or 3)
	elseif cfg.source == "line" then
		if line_open then
			if line and store.entities[line.id] then
				stage155_line_start_animation(line, "move", store.tick_ts, true)
			end
		else
			stage155_show_factory_line(store, ramp, line, false)
		end

		if line and store.entities[line.id] then
			stage155_line_play_animation(store, line, math.random() < 0.5 and "hammer" or "light")
			stage155_line_start_animation(line, "move", store.tick_ts, true)
		end

		S:queue("level5_conveyorbelt")
		S:queue("level5_pneumaticpress")
	end
end

function stage155_run_factory_event(store, cfg, machine, ramp, line, line_open)
	if cfg.action == "open_line" then
		if not line_open then
			stage155_show_factory_line(store, ramp, line, false)
		end

		return true
	end

	if not cfg.enemy then
		return line_open
	end

	stage155_play_factory_source(store, cfg, machine, ramp, line, line_open)

	local pi = stage155_factory_path(cfg)
	if not P.paths[pi] then
		pi = 1
	end

	local subpaths = cfg.subpaths or {1}
	local count = cfg.count or #subpaths

	for i = 1, count do
		local spi = subpaths[((i - 1) % #subpaths) + 1] or 1
		if P.paths[pi] and not P.paths[pi][spi] then
			spi = 1
		end
		branch_spawn_from_pos_to_path(store, cfg.enemy, stage155_factory_spawn_pos(cfg), pi, spi, P:get_start_node(pi))
	end

	return line_open or cfg.source == "line"
end

function stage158_unit(name, subpath)
	return {
		enemy = "enemy_" .. name,
		path = branch_kr4_path_rank(1),
		subpath = (tonumber(subpath) or 0) + 1,
		node = 75
	}
end

function stage158_units(name, subpaths)
	local out = {}

	for _, subpath in ipairs(subpaths or {}) do
		table.insert(out, stage158_unit(name, subpath))
	end

	return out
end

function stage158_repeat_units(name, count, subpath)
	local out = {}

	for i = 1, count do
		table.insert(out, stage158_unit(name, subpath))
	end

	return out
end

function stage158_concat_units(...)
	local out = {}

	for i = 1, select("#", ...) do
		for _, unit in ipairs(select(i, ...) or {}) do
			table.insert(out, unit)
		end
	end

	return out
end

local stage158_ship_schedules = {
	[GAME_MODE_CAMPAIGN] = {
		{wave = 2, delay = 1, units = stage158_repeat_units("northern_berserker", 1, 0)},
		{wave = 2, delay = 33, units = stage158_repeat_units("northern_berserker", 1, 0)},
		{wave = 5, delay = 5, units = stage158_concat_units(stage158_units("northern_wildling", {0, 1, 2}), stage158_units("northern_huntress", {1, 0}))},
		{wave = 6, delay = 1, time_between_spawns = 3.5, units = stage158_units("northern_wildling", {1, 2, 0, 2, 1, 1, 2, 0, 0, 2, 1, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2})}
	},
	[GAME_MODE_HEROIC] = {
		{wave = 2, delay = 40, units = stage158_repeat_units("northern_wildling", 3, 0)},
		{wave = 2, delay = 80, units = stage158_repeat_units("northern_wildling", 3, 0)},
		{wave = 3, delay = 10, units = stage158_repeat_units("northern_wildling", 4, 0)},
		{wave = 3, delay = 35, units = stage158_repeat_units("northern_wildling", 4, 0)},
		{wave = 3, delay = 60, units = stage158_repeat_units("northern_wildling", 4, 0)},
		{wave = 4, delay = 30, units = stage158_concat_units(stage158_repeat_units("northern_wildling", 3, 0), stage158_repeat_units("northern_berserker", 1, 0))},
		{wave = 4, delay = 60, units = stage158_concat_units(stage158_repeat_units("northern_wildling", 3, 0), stage158_repeat_units("northern_berserker", 1, 0))},
		{wave = 5, delay = 10, units = stage158_concat_units(stage158_repeat_units("northern_berserker", 1, 0), stage158_repeat_units("northern_wildling", 1, 0))},
		{wave = 5, delay = 35, units = stage158_concat_units(stage158_repeat_units("northern_berserker", 1, 0), stage158_repeat_units("northern_wildling", 1, 0))},
		{wave = 5, delay = 70, units = stage158_concat_units(stage158_repeat_units("northern_berserker", 1, 0), stage158_repeat_units("northern_wildling", 1, 0), stage158_repeat_units("northern_berserker", 1, 0))},
		{wave = 5, delay = 100, units = stage158_repeat_units("northern_wildling", 5, 0)},
		{wave = 6, delay = 30, units = stage158_concat_units(stage158_repeat_units("northern_wildling", 3, 0), stage158_repeat_units("northern_berserker", 1, 0))},
		{wave = 6, delay = 70, units = stage158_concat_units(stage158_repeat_units("northern_wildling", 3, 0), stage158_repeat_units("northern_berserker", 1, 0))},
		{wave = 6, delay = 110, units = stage158_concat_units(stage158_repeat_units("northern_wildling", 3, 0), stage158_repeat_units("northern_berserker", 1, 0))}
	},
	[GAME_MODE_IRON] = {
		{wave = 1, delay = 20, units = stage158_repeat_units("northern_wildling", 2, 0)},
		{wave = 1, delay = 45, units = stage158_repeat_units("northern_wildling", 4, 0)},
		{wave = 1, delay = 70, units = stage158_repeat_units("northern_wildling", 4, 0)},
		{wave = 1, delay = 120, units = stage158_repeat_units("northern_wildling", 4, 0)},
		{wave = 1, delay = 150, units = stage158_repeat_units("northern_wildling", 5, 0)},
		{wave = 1, delay = 180, units = stage158_repeat_units("northern_wildling", 6, 0)},
		{wave = 1, delay = 220, units = stage158_repeat_units("northern_wildling", 5, 0)},
		{wave = 1, delay = 240, units = stage158_repeat_units("northern_wildling", 5, 0)},
		{wave = 1, delay = 260, units = stage158_repeat_units("northern_berserker", 2, 0)},
		{wave = 1, delay = 280, units = stage158_repeat_units("northern_berserker", 2, 0)}
	}
}

function stage158_move_entity(this, store, target, duration)
	local start_x, start_y = this.pos.x, this.pos.y
	local ts = store.tick_ts

	duration = duration or 1

	while store.tick_ts - ts < duration do
		if not store.entities[this.id] then
			return false
		end

		local p = km.clamp(0, 1, (store.tick_ts - ts) / duration)

		this.pos.x = start_x + (target.x - start_x) * p
		this.pos.y = start_y + (target.y - start_y) * p

		coroutine.yield()
	end

	this.pos.x = target.x
	this.pos.y = target.y

	return true
end

scripts.stage158_ship = {}

function scripts.stage158_ship.update(this, store)
	U.animation_start(this, "ship_loop", nil, store.tick_ts, true, 1)
	U.animation_start(this, "ship_rowings", nil, store.tick_ts, true, 2)
	U.animation_start(this, "ship_water", nil, store.tick_ts, true, 3)

	local start = V.vclone(this.pos)
	local destiny = this.destiny_position or V.v(242, 466)
	local spawn_position = this.spawn_position or V.v(255, 485)
	local navigation_time = this.navigation_time or 5

	S:queue("level8_vikingship_oar")

	if not stage158_move_entity(this, store, destiny, navigation_time) then
		return
	end

	S:queue("level8_vikingship_strand")
	U.y_wait(store, this.wait_open_door or 1)

	if this.render.sprites[4] then
		this.render.sprites[4].hidden = false
		S:queue("level8_vikingship_dooropens")
		U.y_animation_play(this, "ship_openDoor", nil, store.tick_ts, 1, 4)
	end

	for _, unit in ipairs(this.units or {}) do
		branch_spawn_from_pos_to_path(store, unit.enemy, spawn_position, unit.path or 1, unit.subpath or 1, unit.node or 90)
		U.y_wait(store, this.time_between_spawns or 1)
	end

	U.y_wait(store, this.wait_close_door or 2)

	if this.render.sprites[4] then
		U.y_animation_play(this, "ship_closeDoor", nil, store.tick_ts, 1, 4)
		this.render.sprites[4].hidden = true
	end

	S:queue("level8_vikingship_retreat")
	stage158_move_entity(this, store, start, navigation_time)
	queue_remove(store, this)
end

function stage158_spawn_ship(store, cfg)
	return branch_spawn_scene(store, "stage158_ship", -265, 577, {
		destiny_position = V.v(242, 466),
		spawn_position = V.v(255, 485),
		navigation_time = 5,
		wait_open_door = 1,
		wait_close_door = 2,
		time_between_spawns = cfg.time_between_spawns or 1,
		units = cfg.units
	})
end

function stage158_set_ice_path(active)
	if not P.paths[3] then
		return
	end

	if active then
		P:activate_path(3)
	else
		P:deactivate_path(3)
	end
end

function stage158_spawn_iceberg(store, instant)
	local start = V.v(760, -542)
	local finish = V.v(760, 27)
	local iceberg = branch_spawn_scene(store, "stage158_iceberg", instant and finish.x or start.x, instant and finish.y or start.y)

	if instant then
		stage158_set_ice_path(true)
		return iceberg
	end

	if not stage158_move_entity(iceberg, store, finish, 5) then
		return iceberg
	end

	branch_spawn_scene(store, "fx_stage158_iceberg_splash", finish.x, finish.y)
	branch_spawn_scene(store, "fx_stage158_iceberg_crack", finish.x, finish.y)
	stage158_set_ice_path(true)

	return iceberg
end

function branch_spawn_boss(store, name, pi, spi, ni)
	return branch_spawn_on_path(store, name, nil, 0, pi or 1, spi or 1, ni or P:get_start_node(pi or 1))
end

function stage178_preview_place(this, store)
	local center = this.center or this.pos
	local radius = this.circle_radius or 55
	local y_scale = this.circle_y_scale or 0.45
	local angle = this.angle or 0

	this.pos.x = center.x + math.cos(angle) * radius
	this.pos.y = center.y + math.sin(angle) * radius * y_scale
	this.angle = angle + (this.circle_speed or 0.65) * store.tick_length

	local s = this.render and this.render.sprites and this.render.sprites[1]

	if s then
		s.flip_x = math.sin(angle) < 0
	end
end

scripts.stage178_lord_preview = {}

function scripts.stage178_lord_preview.update(this, store)
	local s = this.render.sprites[1]
	local fade_in = this.fade_in or 0.33
	local fade_out = this.fade_out or 0.33

	if not this.center then
		this.center = V.vclone(this.pos)
	end

	U.animation_start(this, "idle", nil, store.tick_ts, true)

	local ts = store.tick_ts

	while store.tick_ts - ts < fade_in do
		stage178_preview_place(this, store)
		s.alpha = km.clamp(0, 255, 255 * (store.tick_ts - ts) / fade_in)
		coroutine.yield()
	end

	s.alpha = 255

	while not this.fade_out_requested do
		stage178_preview_place(this, store)
		coroutine.yield()
	end

	ts = store.tick_ts

	while store.tick_ts - ts < fade_out do
		stage178_preview_place(this, store)
		s.alpha = km.clamp(0, 255, 255 * (1 - (store.tick_ts - ts) / fade_out))
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.stage178_lord_spawn_fx = {}

function scripts.stage178_lord_spawn_fx.update(this, store)
	local s = this.render.sprites[1]
	local duration = this.duration or 5
	local fade_in = this.fade_in or 0.33
	local fade_out = this.fade_out or 0.33
	local ts = store.tick_ts

	U.animation_start(this, "run", nil, store.tick_ts, true)

	while store.tick_ts - ts < duration + fade_out do
		local elapsed = store.tick_ts - ts

		if elapsed < fade_in then
			s.alpha = km.clamp(0, 255, 255 * elapsed / fade_in)
		elseif elapsed > duration then
			s.alpha = km.clamp(0, 255, 255 * (1 - (elapsed - duration) / fade_out))
		else
			s.alpha = 255
		end

		coroutine.yield()
	end

	queue_remove(store, this)
end

function stage178_kill_all_enemies_for_victory(store)
	for _, e in pairs(store.entities) do
		if e.enemy and e.health and not e.health.dead then
			local d = E:create_damage()

			d.source_id = nil
			d.target_id = e.id
			d.value = (e.health.hp or 0) + (e.health.hp_max or 0) + 1000
			d.damage_type = bor(DAMAGE_TRUE, DAMAGE_NO_SPAWNS, DAMAGE_NO_DODGE)

			queue_damage(store, d)
		end
	end

	store.waves_finished = true

	if store.level then
		store.level.run_complete = true
	end
end

function stage178_spawn_afterlife_bosses(store, previews)
	for _, p in ipairs(previews or {}) do
		if p and store.entities[p.id] then
			p.fade_out_requested = true
		end
	end

	local positions = {
		{pi = 1, spi = 1, ni = 30},
		{pi = 3, spi = 1, ni = 40}
	}
	local names = {"enemy_lord_of_afterlife", "enemy_lord_of_afterlife_2"}

	if math.random() < 0.5 then
		names[1], names[2] = names[2], names[1]
	end

	S:queue("level28_ghostsummon_part1")

	for i, cfg in ipairs(positions) do
		local pos = P:node_pos(cfg.pi, cfg.spi, cfg.ni)
		local fx = names[i] == "enemy_lord_of_afterlife" and "fx_lord_of_afterlife_spawn" or "fx_lord_of_afterlife_spawn_2"

		branch_spawn_scene(store, fx, pos.x, pos.y)
	end

	U.y_wait(store, 1.6)
	S:queue("level28_ghostsummon_part2")
	U.y_wait(store, 2.4)

	local bosses = {}

	for i, cfg in ipairs(positions) do
		local boss = branch_spawn_on_path(store, names[i], nil, 0, cfg.pi, cfg.spi, cfg.ni)

		if boss then
			table.insert(bosses, boss)
		end
	end

	return bosses
end

scripts.anurian_boss_water = {}

function scripts.anurian_boss_water.update(this, store)
	for _, s in pairs(this.render and this.render.sprites or {}) do
		s.ts = store.tick_ts
	end

	U.animation_start(this, "walk", nil, store.tick_ts, true)

	local next_idle_ts = store.tick_ts + math.random(40, 60)

	while true do
		if store.tick_ts >= next_idle_ts then
			local animation = math.random() < 0.5 and "talk" or "inflate"
			U.y_animation_play(this, animation, nil, store.tick_ts, 1)
			U.animation_start(this, "walk", nil, store.tick_ts, true)
			next_idle_ts = store.tick_ts + math.random(40, 60)
		end

		coroutine.yield()
	end
end

scripts.boss_dwarf_scene = {}

function scripts.boss_dwarf_scene.update(this, store)
	local sprite = this.render.sprites[1]
	local steal = this.steal_gold
	local next_steal_ts = steal and store.tick_ts + math.random(steal.cooldown_min or 45, steal.cooldown_max or 50)

	U.animation_start(this, "boss_dwarf_idle", nil, store.tick_ts, true, 1)
	if this.render.sprites[2] then
		U.animation_start(this, "run", nil, store.tick_ts, true, 2)
	end

	while not this.exit do
		if steal and store.tick_ts >= next_steal_ts and (store.wave_group_number or 0) >= (steal.wave_start or 1) then
			if (store.player_gold or 0) >= (steal.min_gold or 1000) then
				next_steal_ts = store.tick_ts + math.random(steal.cooldown_min or 45, steal.cooldown_max or 50)
				U.animation_start(this, steal.animation or "boss_dwarf_steal", nil, store.tick_ts, false, 1)

				if steal.fx then
					local fx = E:create_entity(steal.fx)
					fx.pos = V.vclone(steal.fx_pos or V.v(129, 10))
					queue_insert(store, fx)
				end

				if steal.sound then
					S:queue(steal.sound)
				end

				local loops = steal.loops or 10
				local gold_steal = steal.gold_steal or 1

				for _ = 1, loops do
					if this.exit then
						break
					end

					store.player_gold = math.max(0, (store.player_gold or 0) - gold_steal)
					U.y_wait(store, steal.loop_delay or 0.05)
				end

				while not this.exit and not U.animation_finished(this, 1) do
					coroutine.yield()
				end

				if not this.exit then
					U.animation_start(this, "boss_dwarf_idle", nil, store.tick_ts, true, 1)
				end
			end
		end

		coroutine.yield()
	end

	S:queue("dwarves_boss_dwarf_throne")

	for _, animation in ipairs(this.exit_animations or {"boss_dwarf_up", "boss_dwarf_jump", "boss_dwarf_downOut"}) do
		if not store.entities[this.id] then
			return
		end

		U.animation_start(this, animation, sprite.flip_x, store.tick_ts, false, 1)
		U.y_animation_wait(this)
	end

	this.exit_done = true
	queue_remove(store, this)
end

(function()
local branch_stage3_trolley_schedules = {
	[GAME_MODE_CAMPAIGN] = {
		{2, 8, "Bruiser2", 4, {{"enemy_bruiser", 1, 1, 120}, {"enemy_bruiser", 1, 2, 120}}},
		{3, 8, "Kremling", 1, {{"enemy_bruiser", 1, 1, 120}, {"enemy_bruiser", 1, 2, 120}}},
		{3, 7, "DK", 4, {{"enemy_warhammer_guard", 1, 1, 120}, {"enemy_warhammer_guard", 1, 2, 120}}},
		{4, 8, "IJ", 4, {{"enemy_bruiser", 1, 1, 120}, {"enemy_warhammer_guard", 1, 2, 120}}, false},
		{5, 3, "Bruiser2Warhammer1", 4, {{"enemy_bruiser", 1, 1, 120}, {"enemy_bruiser", 1, 2, 120}, {"enemy_warhammer_guard", 1, 3, 120}}},
		{8, 6, "Bruiser2Warhammer1", 4, {{"enemy_bruiser", 2, 1, 120}, {"enemy_bruiser", 2, 2, 120}, {"enemy_warhammer_guard", 2, 3, 120}}},
		{8, 9, "Warhammer3", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 3, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{8, 24, "Warhammer3", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}, {"enemy_warhammer_guard", 2, 3, 120}}},
		{9, 6, "Warhammer3", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 3, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{9, 15, "Warhammer3", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}, {"enemy_warhammer_guard", 2, 3, 120}}},
		{9, 24, "Warhammer3", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{9, 27, "Warhammer3", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}, {"enemy_warhammer_guard", 2, 3, 120}}},
		{11, 3, "Bruiser2Warhammer1", 4, {{"enemy_bruiser", 1, 1, 120}, {"enemy_bruiser", 1, 2, 120}, {"enemy_warhammer_guard", 1, 3, 120}}},
		{11, 8, "Bruiser2Warhammer1", 4, {{"enemy_bruiser", 1, 1, 120}, {"enemy_bruiser", 1, 2, 120}, {"enemy_warhammer_guard", 1, 3, 120}}},
		{11, 18, "Warhammer2", 4, {{"enemy_warhammer_guard", 1, 1, 120}, {"enemy_warhammer_guard", 1, 2, 120}}},
		{11, 23, "Warhammer2", 4, {{"enemy_warhammer_guard", 1, 1, 120}, {"enemy_warhammer_guard", 1, 2, 120}}},
		{12, 10, "Warhammer3", 4, {{"enemy_warhammer_guard", 1, 1, 120}, {"enemy_warhammer_guard", 1, 2, 120}, {"enemy_warhammer_guard", 1, 3, 120}}},
		{12, 15, "Warhammer3", 4, {{"enemy_warhammer_guard", 1, 1, 120}, {"enemy_warhammer_guard", 1, 2, 120}, {"enemy_warhammer_guard", 1, 3, 120}}},
		{12, 45, "Warhammer3", 4, {{"enemy_warhammer_guard", 1, 1, 120}, {"enemy_warhammer_guard", 1, 2, 120}, {"enemy_warhammer_guard", 1, 3, 120}}},
		{12, 50, "Warhammer3", 4, {{"enemy_warhammer_guard", 1, 1, 120}, {"enemy_warhammer_guard", 1, 2, 120}, {"enemy_warhammer_guard", 1, 3, 120}}},
		{12, 55, "Warhammer3", 4, {{"enemy_warhammer_guard", 1, 1, 120}, {"enemy_warhammer_guard", 1, 2, 120}, {"enemy_warhammer_guard", 1, 3, 120}}}
	},
	[GAME_MODE_HEROIC] = {
		{2, 15, "Bruiser2", 4, {{"enemy_bruiser", 2, 1, 120}, {"enemy_bruiser", 2, 2, 120}}},
		{3, 2, "Bruiser2", 4, {{"enemy_bruiser", 2, 1, 120}, {"enemy_bruiser", 2, 2, 120}}},
		{3, 3, "Bruiser2", 4, {{"enemy_bruiser", 2, 1, 120}, {"enemy_bruiser", 2, 2, 120}}},
		{4, 2, "Bruiser2", 4, {{"enemy_bruiser", 2, 1, 120}, {"enemy_bruiser", 2, 2, 120}}},
		{4, 3, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{4, 25, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{4, 26, "Bruiser2", 4, {{"enemy_bruiser", 2, 1, 120}, {"enemy_bruiser", 2, 2, 120}}},
		{4, 50, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{4, 51, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{4, 85, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{4, 86, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{5, 10, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{5, 12, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{5, 14, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{5, 25, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{5, 27, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{5, 29, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{5, 40, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{5, 42, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{5, 44, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{5, 46, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{6, 10, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{6, 11, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{6, 12, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{6, 25, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{6, 26, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{6, 27, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{6, 40, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{6, 41, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{6, 42, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{6, 55, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{6, 56, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{6, 57, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{6, 58, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}}
	},
	[GAME_MODE_IRON] = {
		{1, 80, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 93, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 106, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 119, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 132, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 145, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 158, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 171, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 184, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 197, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 210, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 223, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 236, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 249, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 262, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 275, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 288, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 301, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}},
		{1, 314, "Warhammer2", 4, {{"enemy_warhammer_guard", 2, 1, 120}, {"enemy_warhammer_guard", 2, 2, 120}}}
	}
}

scripts.branch_stage3_trolley_schedules = branch_stage3_trolley_schedules

function branch_stage3_cart_animation(cart, direction, layer)
	if layer then
		return "cart_layer" .. layer .. "_" .. (direction or "side") .. (cart or "Warhammer3")
	end

	return "cart_layer_" .. (direction or "side") .. (cart or "Warhammer3")
end

function branch_stage3_cart_has_fall_animation(cart)
	return cart == "Bruiser2" or cart == "Bruiser2Warhammer1" or cart == "Warhammer2" or cart == "Warhammer3"
end

function branch_stage3_cart_animation_start(this, cart, direction, ts, loop, flip)
	for sid = 1, 2 do
		if this.render.sprites[sid] then
			U.animation_start(this, branch_stage3_cart_animation(cart, direction, sid), flip, ts, loop, sid)
		end
	end
end

function branch_stage3_trolley_set_hidden(this, hidden)
	for _, sprite in pairs(this.render and this.render.sprites or {}) do
		sprite.hidden = hidden
	end
end

function branch_stage3_trolley_target(units)
	local unit = units and units[1]

	if unit and P.paths[unit[2]] and P.paths[unit[2]][unit[3]] then
		local ni = branch_clamp_path_node(unit[2], unit[4])

		return P:node_pos(unit[2], unit[3], ni)
	end

	if P.paths[1] and P.paths[1][1] then
		local ni = branch_clamp_path_node(1, 120)

		return P:node_pos(1, 1, ni)
	end

	return V.v(820, 520)
end

function branch_stage3_trolley_direction(from, to)
	local dx = to.x - from.x
	local dy = to.y - from.y

	if math.abs(dy) > math.abs(dx) * 0.55 then
		return dy > 0 and "up" or "down"
	end

	return "side"
end

function branch_stage3_trolley_route(units)
	local target = branch_stage3_trolley_target(units)
	local fall_pos = target.x > 500 and V.v(610, 248) or V.v(565, 252)
	local tunnel_entry = V.v(699.7, 658.4)

	-- Cart/rail points traced against stage_153 at the actual
	-- scale_required_textures ref_scale: (768 * 768 / 1080) / 1080.
	-- The cart and its carried enemies come from the same scaled atlas, so the
	-- route is stored in game-world coordinates converted from the rail's
	-- fullhd image-space curve.
	tunnel_entry.teleport_to = V.v(1109.7, 45.6)
	fall_pos.trolley_throw = true

	local route = {
		V.v(343.5, 650.9),
		V.v(408.5, 632.2),
		V.v(457.4, 617.7),
		V.v(505.6, 613.6),
		V.v(554.5, 610.8),
		V.v(602.7, 612.4),
		V.v(651.6, 626.5),
		tunnel_entry,
		V.v(1063.2, 55.7),
		V.v(1015.9, 48.8),
		V.v(969.3, 43.6),
		V.v(922.8, 56.5),
		V.v(875.5, 77.4),
		V.v(828.9, 102.8),
		V.v(781.6, 151.1),
		V.v(735, 184.2),
		V.v(688.5, 192.2),
		V.v(641.2, 191.4),
		V.v(581.8, 205.5),
		fall_pos
	}

	return route
end

function branch_stage3_trolley_segment_time(from, to)
	local dx = to.x - from.x
	local dy = to.y - from.y
	local distance = math.sqrt(dx * dx + dy * dy)

	return km.clamp(0.35, 1.35, distance / 210)
end

function branch_stage3_trolley_throw_to(this, store, target)
	local from = V.vclone(this.pos)
	local to = V.vclone(target)
	local flight_time = this.throw_time or 0.46
	local peak = this.throw_peak or 45
	local apex_y = math.min(from.y, to.y) - peak
	local midpoint_y = (from.y + to.y) * 0.5
	local g = this.throw_g or math.max(900, (midpoint_y - apex_y) / (0.125 * flight_time * flight_time))
	local speed = SU.initial_parabola_speed(from, to, flight_time, g)
	local ts = store.tick_ts

	while store.tick_ts - ts < flight_time do
		local t = store.tick_ts - ts

		this.pos.x, this.pos.y = SU.position_in_parabola(t, from, speed, g)

		coroutine.yield()
	end

	this.pos.x = to.x
	this.pos.y = to.y
end

function branch_stage3_trolley_handle_click(this, store, clicks)
	if this.exploitable == false or not this.ui or not this.ui.can_click or not this.ui.clicked then
		return false, clicks
	end

	this.ui.clicked = nil
	clicks = clicks + 1
	branch_spawn_scene(store, "fx_stage3_trolley_hit", this.pos.x, this.pos.y + (this.touch_offset or 18))
	S:queue(math.random() < 0.5 and "level3_minerywork_var1" or "level3_minerywork_var2")

	if clicks >= (this.touches or 4) then
		this.ui.can_click = false
		S:queue("level3_trolley_crash")
		branch_spawn_scene(store, "fx_stage3_trolley_explosion", this.pos.x, this.pos.y)
		branch_spawn_scene(store, "decal_stage3_trolley_explosion", this.pos.x, this.pos.y)

		if branch_stage3_cart_has_fall_animation(this.cart) then
			branch_stage3_cart_animation_start(this, this.cart, "fall", store.tick_ts, false)
			U.y_wait(store, 0.45)
		end

		queue_remove(store, this)

		return true, clicks
	end

	return false, clicks
end

function branch_stage3_spawn_trolley(store, cfg)
	local e = branch_spawn_scene(store, "stage3_trolley", 343.5, 650.9, {
		cart = cfg[3],
		touches = cfg[4] or 4,
		spawns = cfg[5] or {},
		exploitable = cfg[6] ~= false
	})

	return e
end

scripts.branch_stage3_spawn_trolley = branch_stage3_spawn_trolley

scripts.stage3_trolley = {}

function scripts.stage3_trolley.update(this, store)
	local route = branch_stage3_trolley_route(this.spawns)
	local clicks = 0

	this.ui.clicked = nil
	this.ui.can_click = this.exploitable ~= false

	for _, sprite in pairs(this.render and this.render.sprites or {}) do
		sprite.ts = store.tick_ts
	end

	S:queue("level3_trolley_loop")

	local start = route[1]
	local did_throw = false

	this.pos.x = start.x
	this.pos.y = start.y

	for i = 2, #route do
		local target = route[i]

		if target.trolley_throw then
			this.ui.can_click = false
			this.ui.clicked = nil

			if branch_stage3_cart_has_fall_animation(this.cart) then
				branch_stage3_cart_animation_start(this, this.cart, "fall", store.tick_ts, false)
			end

			branch_stage3_trolley_throw_to(this, store, target)

			start = target
			did_throw = true

			break
		end

		local direction = branch_stage3_trolley_direction(start, target)
		local flip = direction == "side" and target.x < start.x or nil
		local duration = branch_stage3_trolley_segment_time(start, target)
		local ts = store.tick_ts

		this.pos.x = start.x
		this.pos.y = start.y
		branch_stage3_cart_animation_start(this, this.cart, direction, store.tick_ts, true, flip)

		while store.tick_ts - ts < duration do
			local p = km.clamp(0, 1, (store.tick_ts - ts) / duration)

			this.pos.x = start.x + (target.x - start.x) * p
			this.pos.y = start.y + (target.y - start.y) * p

			local destroyed

			destroyed, clicks = branch_stage3_trolley_handle_click(this, store, clicks)

			if destroyed then
				return
			end

			coroutine.yield()
		end

		this.pos.x = target.x
		this.pos.y = target.y

		if target.teleport_to then
			local can_click = this.ui.can_click

			this.ui.can_click = false
			this.ui.clicked = nil
			branch_stage3_trolley_set_hidden(this, true)
			U.y_wait(store, this.teleport_wait or 0.12)

			start = target.teleport_to
			this.pos.x = start.x
			this.pos.y = start.y
			branch_stage3_trolley_set_hidden(this, false)
			this.ui.clicked = nil
			this.ui.can_click = can_click
		else
			start = target
		end
	end

	this.ui.can_click = false
	S:queue("level3_trolley_loopend")

	if not did_throw and branch_stage3_cart_has_fall_animation(this.cart) then
		branch_stage3_cart_animation_start(this, this.cart, "fall", store.tick_ts, false)
		U.y_wait(store, this.throw_delay or 0.12)
	end

	for _, unit in ipairs(this.spawns or {}) do
		branch_spawn_from_pos_to_path(store, unit[1], this.pos, unit[2], unit[3], unit[4])
	end

	if branch_stage3_cart_has_fall_animation(this.cart) then
		U.y_wait(store, this.remove_wait or 0.35)
	end

	queue_remove(store, this)
end

end)()

scripts.branch_stage_controller = {}

function scripts.branch_stage_controller.update(this, store)
	local level = this.level
	local frozen_logic_level = level
	local anurian_water, anurian_water_fx, anurian_mask_2
	local winter_queen_statue
	local great_t_shaman
	local malik_throne
	local boss_dwarf_scene
	local lightseeker_roof
	local magnus_scene, denas_scene
	local raptor_nests = {}
	local ice_holder_data = {}
	local afterlife_previews, afterlife_bosses, afterlife_boss_seen
	local afterlife_victory = false
	local afterlife_cleanup_ts = -1e+99
	local boss_spawned = false
	local stage3_trolley_fired = {}
	local stage10_blizzard_fired = {}
	local stage12_farm_fired = {}
	local stage163_alleria_fired = {}
	local stage163_alleria_end_fired = false
	local stage164_golem_fired = {}
	local stage164_portal_fired = {}
	local stage164_golem_dormants = {}
	local stage165_house_fired = {}
	local stage155_machine_spawner, stage155_ramp_spawner, stage155_assembly_line
	local stage155_line_open = false
	local viking_boss_scene
	local viking_stage9_next_attack = 0
	local stage16_heroes_positioned = false
	local zeta_scene_magnet, zeta_scene_altar
	local zeta_stones = {}
	local zeta_stage_fired = {}
	local stage183_ambush_fired = {}
	local stage183_active_ambushes = {}

	-- Generic data-only levels must wait for the scripted boss or ending scene.
	if store.level_mode == GAME_MODE_CAMPAIGN and (level == 161 or level == 164 or level == 165 or level == 166 or level == 192) and not store.level.update then
		store.level.run_complete = nil
		store.level.update = function(level_state)
			while not level_state.kr4_boss_done do coroutine.yield() end
		end
	end
	branch_stage16_split_setup(store, level, this)

	if level == 155 then
		branch_spawn_scene(store, "stage155_machine_spawner_shadow", 862, 550)
		stage155_machine_spawner = branch_spawn_scene(store, "stage155_machine_spawner", 862, 521)
		stage155_ramp_spawner = branch_spawn_scene(store, "stage155_ramp_spawner", 1076, 415)
		stage155_assembly_line = branch_spawn_scene(store, "stage155_assembly_line", 142, 620)

		if store.level_mode == GAME_MODE_CAMPAIGN then
			stage155_set_hidden(stage155_ramp_spawner, true)
			stage155_set_hidden(stage155_assembly_line, true)
		else
			stage155_show_factory_line(store, stage155_ramp_spawner, stage155_assembly_line, true)
			stage155_line_open = true
		end
	end
	if level == 158 then
		stage158_spawn_iceberg(store, true)
	end
	if level == 156 and store.level_mode == GAME_MODE_CAMPAIGN then
		boss_dwarf_scene = branch_spawn_scene(store, "boss_dwarf", 260, 628)
	elseif level == 159 and store.level_mode == GAME_MODE_CAMPAIGN then
		viking_boss_scene = branch_spawn_scene(store, "viking_boss", 518, 619)
		viking_boss_scene.loop_variants = nil
	elseif level == 161 and store.level_mode == GAME_MODE_CAMPAIGN then
		local state = branch_stage161_state(store)
		state.rider_dragon = branch_spawn_scene(store, "viking_boss_dragon", 480, 520)
		state.rider_dragon.stage161_home_pos = V.v(480, 520)
		state.next_attack_ts = store.tick_ts + 12
		state.left_cannon = branch_spawn_scene(store, "stage11_goblin_cannon_left", 330, 1015, {stage161_final_y = 215})
		state.right_cannon = branch_spawn_scene(store, "stage11_goblin_cannon_right", 645, 1015, {stage161_final_y = 215})
		branch_stage161_set_entity_visible(state.left_cannon, false)
		branch_stage161_set_entity_visible(state.right_cannon, false)
	elseif level == 164 and store.level_mode == GAME_MODE_CAMPAIGN then
		branch_spawn_scene(store, "ladle", 120, 331)
		magnus_scene = branch_spawn_scene(store, "magnus", 487, 372)
		branch_spawn_scene(store, "house_toad", 794, 602)

		for i, cfg in ipairs(stage164_golem_house_schedules) do
			local dormant = branch_spawn_scene(store, "stage164_golem_house_dormant", cfg.x, cfg.y)

			stage164_apply_flip(dormant, cfg.flip_x)
			stage164_golem_dormants[i] = dormant
		end
	elseif level == 165 and store.level_mode == GAME_MODE_CAMPAIGN then
		lightseeker_roof = branch_spawn_scene(store, "lightseeker_roof", 113, 350)
	end

	if (level == 166 or level == 192) and store.level_mode == GAME_MODE_CAMPAIGN then
		-- The port splits the original wide stage into two maps; keep the king inside each view.
		denas_scene = branch_spawn_scene(store, "denas", level == 166 and 65 or 95, level == 166 and 440 or 445)
		if level == 192 and store.kr4_denas_continuation then
			store.lives = store.kr4_denas_continuation.lives
			store.player_gold = 2500
		end
	end

	if level == 169 and store.level_mode == GAME_MODE_CAMPAIGN then
		anurian_water = branch_spawn_scene(store, "anurian_boss_water", 102, 381)
		anurian_mask_2 = branch_spawn_scene(store, "stage169_mask_2", 93, 324)
		anurian_water_fx = branch_spawn_scene(store, "stage169_anurian_water_fx", 100, 384)
	end

	if level == 172 and store.level_mode == GAME_MODE_CAMPAIGN then
		branch_spawn_scene(store, "stage22_back_throne", 525, 651)
		winter_queen_statue = branch_spawn_scene(store, "winter_queen_statue", 530, 664)
	elseif level == 195 and store.level_mode == GAME_MODE_CAMPAIGN then
		branch_spawn_scene(store, "stage22_back_throne", 925, 651)
		winter_queen_statue = branch_spawn_scene(store, "winter_queen_statue", 930, 664)
	end

	if branch_troll_hut_schedules[frozen_logic_level] then
		local cfg = branch_troll_hut_schedules[frozen_logic_level]
		local holder_ids = cfg[store.level_mode]

		branch_apply_troll_hut_prices(cfg.discount and store.level_mode ~= GAME_MODE_CAMPAIGN)

		for _, holder_id in ipairs(holder_ids or {}) do
			branch_replace_holder_with_troll_hut(store, holder_id)
		end
	else
		branch_apply_troll_hut_prices(false)
	end

	zeta_apply_mode_towers(store, level)
	zeta_spawn_gold_rewards(store, level)

	if level == 196 and store.level_mode == GAME_MODE_HEROIC then
		branch_spawn_scene(store, "zeta_eva1_heroic_controller", 0, 0)
	elseif level == 196 and store.level_mode == GAME_MODE_IRON then
		branch_spawn_scene(store, "zeta_eva1_iron_controller", 0, 0)
	elseif level == 197 and store.level_mode == GAME_MODE_HEROIC then
		branch_spawn_scene(store, "zeta_eva2_heroic_controller", 0, 0)
	elseif level == 198 and store.level_mode == GAME_MODE_IRON then
		branch_spawn_scene(store, "zeta_demon_iron_controller", 0, 0)
	elseif level == 201 and store.level_mode == GAME_MODE_HEROIC then
		branch_spawn_scene(store, "zeta_eva3_heroic_controller", 470, 200)
	end

	if level == 178 and store.level_mode == GAME_MODE_CAMPAIGN then
		local center = V.v(530, 664)

		afterlife_previews = {
			branch_spawn_scene(store, "stage178_lord_of_afterlife_preview", center.x + 55, center.y, {center = center, angle = 0}),
			branch_spawn_scene(store, "stage178_lord_of_afterlife_preview_2", center.x - 55, center.y, {center = center, angle = math.pi})
		}
	end

	if level == 186 and store.level_mode == GAME_MODE_CAMPAIGN then
		malik_throne = branch_spawn_scene(store, "stage36_malik_throne", 117, 489)
	end

	if branch_ice_schedules[frozen_logic_level] then
		local mode_schedule = branch_ice_schedules[frozen_logic_level][store.level_mode] or branch_ice_schedules[frozen_logic_level][GAME_MODE_HEROIC]
		for _, cfg in ipairs(mode_schedule or {}) do
			local holder
			for _, e in pairs(store.entities) do if e.tower and tostring(e.tower.holder_id) == tostring(cfg[1]) then holder = e break end end
			local path = branch_kr4_path_rank(cfg[5])
			local subpath = (tonumber(cfg[6]) or 0) + 1
			local node = (cfg[7] or 1) + branch_ice_node_offset(frozen_logic_level, cfg)
			if not P.paths[path] then path = 1 end
			if P.paths[path] and not P.paths[path][subpath] then subpath = 1 end
			local pos = holder and holder.pos or P:node_pos(path, subpath, node)
			local ice_block = branch_spawn_scene(store, "ice_block", pos.x, pos.y, {holder_id=tostring(cfg[1]), wave_start=cfg[2], cooldown=cfg[3], cost=cfg[4], path=path, subpath=subpath, node=node, delay_to_spawn=cfg[8], restore_template="tower_holder", restore_nav_mesh_id=holder and holder.ui and holder.ui.nav_mesh_id})

			ice_block.tower.holder_id = tostring(cfg[1])
			ice_block.tower_holder.unblock_price = cfg[4] or ice_block.cost

			if holder then
				branch_copy_holder_data(holder, ice_block)
				ice_block.restore_nav_mesh_id = holder.ui and holder.ui.nav_mesh_id or ice_block.restore_nav_mesh_id
				ice_holder_data[tostring(cfg[1])] = {
					nav_mesh_id = holder.ui and holder.ui.nav_mesh_id
				}
				queue_remove(store, holder)
				signal.emit("tower-removed", holder, ice_block)
			end
		end
	end
	if level == 197 or level == 201 or level == 196 and store.level_mode ~= GAME_MODE_IRON then
		local support = branch_spawn_scene(store, "zeta_eva_support_controller", 0, 0)
		support.heal_per_tick = (store.level_difficulty == DIFFICULTY_HARD or
			store.level_difficulty == DIFFICULTY_IMPOSSIBLE) and 40 or 20
	end

	if level == 197 and store.level_mode == GAME_MODE_CAMPAIGN then
		zeta_scene_magnet = branch_spawn_scene(store, "zeta_eva2_magnet", 80, 460)
		for _, pi in ipairs({2, 4, 7}) do
			if P.paths[pi] then P:deactivate_path(pi) end
		end
	elseif level == 197 and store.level_mode == GAME_MODE_IRON then
		branch_spawn_scene(store, "zeta_eva2_magnet", 80, 460)
		branch_spawn_scene(store, "zeta_eva2_magnet", 490, 290)
	elseif level == 200 and store.level_mode == GAME_MODE_CAMPAIGN then
		zeta_stones[1] = branch_spawn_scene(store, "zeta_demon_stone_1", 470, 200)
		zeta_stones[2] = branch_spawn_scene(store, "zeta_demon_stone_2", 470, 375)
		zeta_stones[3] = branch_spawn_scene(store, "zeta_demon_stone_3", 518, 570)
		for _, pi in ipairs({1, 3, 5, 7, 10}) do
			if P.paths[pi] then P:deactivate_path(pi) end
		end
	elseif level == 200 and store.level_mode == GAME_MODE_IRON then
		branch_spawn_scene(store, "enemy_kr4_boss_red_triplet_iron", 185, 395)
	elseif level == 201 and store.level_mode == GAME_MODE_CAMPAIGN then
		zeta_scene_altar = branch_spawn_scene(store, "zeta_wilbur_altar", 500, 560)
		branch_spawn_scene(store, "zeta_eva3_statue225", 805, 102)
	end

	if level == 198 then
		for _, p in ipairs({{983, 383}, {1036, 377}, {1089, 389}, {1138, 382}, {601, 460}}) do
			branch_spawn_scene(store, "enemy_zeta_demon_fissure", p[1], p[2])
		end
		for _, p in ipairs({{40, 327}, {832, 188}}) do
			branch_spawn_scene(store, "enemy_zeta_demon_spawner", p[1], p[2])
		end
	elseif level == 199 then
		branch_spawn_scene(store, "enemy_zeta_demon_fissure", 601, 460)
		for _, p in ipairs({{140, 227}, {840, 188}, {512, 474}}) do
			branch_spawn_scene(store, "enemy_zeta_demon_spawner", p[1], p[2])
		end
	elseif level == 200 then
		for _, p in ipairs({{1050, 260}, {1115, 280}, {1180, 270}}) do
			branch_spawn_scene(store, "enemy_zeta_demon_fissure", p[1], p[2])
		end
		for _, p in ipairs({{140, 227}, {817, 528}, {646, 230}}) do
			branch_spawn_scene(store, "enemy_zeta_demon_spawner", p[1], p[2])
		end

		if store.level_mode == GAME_MODE_CAMPAIGN then
			branch_spawn_scene(store, "enemy_zeta_oloch_altar", 54, 438)
			branch_spawn_scene(store, "zeta_pit_lord_spawner", 970, 230)
		elseif store.level_mode == GAME_MODE_HEROIC then
			branch_spawn_scene(store, "zeta_demon_heroic_booster", 470, 200)
		elseif store.level_mode == GAME_MODE_IRON then
			for _, p in ipairs({{970, 228}, {971, 230}, {972, 228}}) do
				branch_spawn_scene(store, "zeta_pit_lord_spawner", p[1], p[2])
			end
		end
	end
	if branch_stage_water_segments[level] then
		for _, segment in ipairs(branch_stage_water_segments[level]) do
			branch_spawn_scene(store, "branch_water_zone", 0, 0, segment)
		end
	end
	if level == 175 and store.level_mode == GAME_MODE_CAMPAIGN then
		local boss = stage175_spawn_dragon_king_boss(store)

		if boss then
			boss_spawned = true
		end
	end
	if level == 179 then
		table.insert(raptor_nests, branch_spawn_scene(store, "velociraptor_nest", 580, 356))
		table.insert(raptor_nests, branch_spawn_scene(store, "velociraptor_nest", 814, 234))
		if store.level_mode == GAME_MODE_IRON then table.insert(raptor_nests, branch_spawn_scene(store, "velociraptor_nest", 248, 490)) end
	elseif level == 180 and store.level_mode ~= GAME_MODE_IRON then
		table.insert(raptor_nests, branch_spawn_scene(store, "velociraptor_nest", 517, 605))
	end
	if level == 180 then
		local plants = store.level_mode == GAME_MODE_IRON and {{310,339},{535,372},{763,375},{436,551}} or {{475,345},{763,375}}
		for _, p in ipairs(plants) do
			branch_spawn_scene(store, "kr4_carnivorous_plant", p[1], p[2], {
				teleport = {disabled = false, target_enemies = true, cooldown = 2.5, range = 50, sickness = 1.5, centers = {{17, 19}, {19, 17}, {17, -19}, {19, -17}}}
			})
		end
	elseif level == 181 and store.level_mode ~= GAME_MODE_IRON then
		local plant_teleport = {disabled = false, target_enemies = true, cooldown = 2.5, range = 50, sickness = 1.5, centers = {{17, 19}, {19, 17}, {17, -19}, {19, -17}}}
		branch_spawn_scene(store, "kr4_carnivorous_plant", 590, 390, {teleport = plant_teleport})
		branch_spawn_scene(store, "kr4_carnivorous_plant", 345, 390, {teleport = plant_teleport})
		if store.level_mode == GAME_MODE_CAMPAIGN then great_t_shaman = branch_spawn_scene(store, "boss_shaman", 831, 432) end
	elseif level == 182 then
		if store.level_mode == GAME_MODE_CAMPAIGN then
			branch_spawn_scene(store, "hammerhold_archer", 564, 523)
			branch_spawn_scene(store, "hammerhold_archer", 398, 494)
			branch_spawn_scene(store, "hammerhold_barrack", 684, 563)
			branch_spawn_scene(store, "veznan_ship_cannon", 165, 525)
		elseif store.level_mode == GAME_MODE_IRON then
			local archers={{689,426},{769,218},{564,523}}
			local barracks={{530,211},{519,403},{645,305},{818,336},{843,501},{398,494},{684,563}}
			for _, p in ipairs(archers) do branch_spawn_scene(store,"hammerhold_archer",p[1],p[2]) end
			for i, p in ipairs(barracks) do branch_spawn_scene(store,"hammerhold_barrack"..i,p[1],p[2]) end
			branch_spawn_scene(store, "veznan_ship_cannon_iron", 165, 525)
		end
	elseif level == 184 then
		if store.level_mode == GAME_MODE_IRON then
			local replaced_holders = {
				{"1", 350, 327},
				{"3", 621, 203},
				{"10", 826, 540},
				{"11", 281, 526}
			}

			for _, cfg in ipairs(replaced_holders) do
				for _, e in pairs(store.entities) do
					if e.tower and tostring(e.tower.holder_id) == cfg[1] then
						queue_remove(store, e)
						break
					end
				end

				local sarcophagus = branch_spawn_scene(store, "stage34_sarcophagus_build_2", cfg[2], cfg[3])
				sarcophagus.ui.nav_mesh_id = cfg[1]
				sarcophagus.tower.holder_id = cfg[1]
				sarcophagus.tower.default_rally_pos = V.v(cfg[2], cfg[3] + 60)
				sarcophagus.cost = 35
				sarcophagus.attacks.list[1].price = sarcophagus.cost
			end

			local holder = branch_spawn_scene(store, "tower_holder_g4_8", 596, 363)
			holder.tower.terrain_style = 44
			holder.tower.default_rally_pos = V.v(598, 350)
			holder.tower.holder_id = "14"
			holder.ui.nav_mesh_id = "14"
		else
			local sarcophagus = branch_spawn_scene(store,"stage34_sarcophagus_build_2",588,350)
			sarcophagus.ui.nav_mesh_id = "14"
			sarcophagus.tower.holder_id = "14"
			sarcophagus.tower.default_rally_pos = V.v(596, 363)
			sarcophagus.attacks.list[1].price = sarcophagus.cost or 120
		end
		if store.level_mode == GAME_MODE_CAMPAIGN then branch_spawn_scene(store,"shatra",511,620) end
	end

	local last_wave, wave_ts = store.wave_group_number or 0, store.tick_ts
	local nest_counts = {}
	local stage185_fired = {}
	local stage185_active_spawns = {}
	while true do
		local wave = store.wave_group_number or 0

		if (level == 166 or level == 192) and not stage16_heroes_positioned then
			local heroes, seen = {}, {}

			local function add_hero(hero)
				local key = hero and (hero.id or hero)

				if key and not seen[key] then
					seen[key] = true
					table.insert(heroes, hero)
				end
			end

			for _, hero in ipairs(store.main_heroes or {}) do add_hero(hero) end
			add_hero(store.main1_hero)
			add_hero(store.main_hero)

			if #heroes > 0 then
				local center = level == 166 and V.v(700, 550) or V.v(963, 537)
				local offsets = {V.v(-20, -18), V.v(20, -18), V.v(-20, 18), V.v(20, 18)}

				for i, hero in ipairs(heroes) do
					local offset = offsets[i] or V.v((i - 1) * 10, 0)
					local spawn_pos = V.v(center.x + offset.x, center.y + offset.y)

					hero.pos = V.vclone(spawn_pos)

					if hero.nav_rally then
						hero.nav_rally.center = V.vclone(spawn_pos)
						hero.nav_rally.pos = V.vclone(spawn_pos)
					end
				end

				stage16_heroes_positioned = true
			end
		end

		for holder_id, data in pairs(ice_holder_data) do
			if data.nav_mesh_id then
				for _, e in pairs(store.entities) do
					if e.tower and tostring(e.tower.holder_id) == holder_id and e.template_name ~= "ice_block" then
						if e.ui then
							e.ui.nav_mesh_id = data.nav_mesh_id
						end

						break
					end
				end
			end
		end

		if wave ~= last_wave then last_wave, wave_ts, nest_counts = wave, store.tick_ts, {} end
		local elapsed = store.tick_ts - wave_ts
		local zeta_mode_schedule = zeta_stage_schedules[level] and zeta_stage_schedules[level][store.level_mode]

		if level == 183 and store.level_mode == GAME_MODE_IRON then
			for i, cfg in ipairs(stage183_iron_ambushes) do
				if wave == 1 and not stage183_ambush_fired[i] and elapsed >= cfg.delay then
					stage183_ambush_fired[i] = true
					stage183_queue_nomad_ambush(store, stage183_active_ambushes, cfg)
				end
			end

			stage183_update_nomad_ambushes(store, stage183_active_ambushes)
		end

		if zeta_mode_schedule and not (store.level and store.level.run_complete) then
			for i, cfg in ipairs(zeta_mode_schedule) do
				if cfg.wave == wave and not zeta_stage_fired[i] and elapsed >= (cfg.delay or 0) then
					zeta_stage_fired[i] = true
					local pos = cfg.pos

					if not pos then
						pos = level == 198 and V.v(466.5, 456)
							or level == 199 and V.v(789.5, 340)
							or level == 200 and V.v(-70.5, 332)
							or V.v(512, 384)
					end

					local event = branch_spawn_scene(store, "zeta_stage_event", pos.x, pos.y, cfg)

					if cfg.kind == "stone" and zeta_stones[cfg.stone] then
						event.scene_id = zeta_stones[cfg.stone].id
					elseif cfg.kind == "altar" and zeta_scene_altar then
						event.scene_id = zeta_scene_altar.id
					end
				end
			end
		end
		if level == 185 and store.level_mode == GAME_MODE_CAMPAIGN then
			for i, cfg in ipairs(stage185_special_schedules) do
				if cfg.wave == wave and not stage185_fired[i] and elapsed >= (cfg.delay or 0) then
					stage185_fired[i] = true
					stage185_queue_special_event(store, stage185_active_spawns, cfg)
				end
			end

			stage185_update_special_spawns(store, stage185_active_spawns)
		end

		if level == 153 then
			for i, cfg in ipairs(scripts.branch_stage3_trolley_schedules[store.level_mode] or {}) do
				if cfg[1] == wave and not stage3_trolley_fired[i] and elapsed >= cfg[2] then
					stage3_trolley_fired[i] = true
					scripts.branch_stage3_spawn_trolley(store, cfg)
				end
			end
		end
		if level == 160 then
			for i, cfg in ipairs(branch_stage10_blizzard_schedules[store.level_mode] or {}) do
				if cfg.wave == wave and not stage10_blizzard_fired[i] and elapsed >= (cfg.delay or 0) then
					stage10_blizzard_fired[i] = true
					branch_stage10_spawn_blizzard(store, cfg)
				end
			end
		end
		if level == 162 then
			for i, cfg in ipairs(branch_stage12_farm_schedules[store.level_mode] or {}) do
				if cfg.wave == wave and not stage12_farm_fired[i] and elapsed >= (cfg.delay or 0) then
					stage12_farm_fired[i] = true
					branch_stage12_spawn_farmers(store, cfg)
				end
			end
		end
		if level == 163 and store.level_mode == GAME_MODE_CAMPAIGN then
			for i, cfg in ipairs(stage163_alleria_schedules) do
				if cfg.wave == wave and not stage163_alleria_fired[i] and elapsed >= cfg.delay then
					stage163_alleria_fired[i] = true
					stage163_spawn_alleria(store, cfg)
				end
			end

			if store.waves_finished and not stage163_alleria_end_fired and not stage163_has_living_enemies(store) then
				stage163_alleria_end_fired = true
				branch_spawn_scene(store, "alleria_end", 487, 387)
			end
		end
		if level == 164 and store.level_mode == GAME_MODE_CAMPAIGN then
			for i, cfg in ipairs(stage164_golem_house_schedules) do
				if cfg.wave == wave and not stage164_golem_fired[i] and elapsed >= (cfg.delay or 0) then
					stage164_golem_fired[i] = true
					stage164_wake_golem_house(store, cfg, stage164_golem_dormants[i])
				end
			end

			for i, cfg in ipairs(stage164_portal_schedules[store.level_mode] or {}) do
				if cfg.wave == wave and not stage164_portal_fired[i] and elapsed >= (cfg.delay or 0) then
					stage164_portal_fired[i] = true
					branch_spawn_scene(store, "stage164_spawn_event", cfg.x, cfg.y, {cfg = cfg, pos = V.v(cfg.x, cfg.y)})
				end
			end
		end
		if level == 155 then
			for i, cfg in ipairs(stage155_factory_schedules[store.level_mode] or {}) do
				if cfg.wave == wave and not nest_counts[i] and elapsed >= cfg.delay then
					nest_counts[i] = true
					stage155_line_open = stage155_run_factory_event(store, cfg, stage155_machine_spawner, stage155_ramp_spawner, stage155_assembly_line, stage155_line_open)
				end
			end
		end
		if level == 158 then
			for i, cfg in ipairs(stage158_ship_schedules[store.level_mode] or {}) do
				if cfg.wave == wave and not nest_counts[i] and elapsed >= cfg.delay then
					nest_counts[i] = true
					stage158_spawn_ship(store, cfg)
				end
			end

		end
		if level == 165 then
			for i, cfg in ipairs(stage165_house_schedules[store.level_mode] or {}) do
				if cfg.wave == wave and not stage165_house_fired[i] and elapsed >= (cfg.delay or 0) then
					stage165_house_fired[i] = true
					stage165_spawn_house_event(store, cfg)
				end
			end
		end
		if store.level_mode == GAME_MODE_CAMPAIGN and level == 159 and not store.waves_finished and wave >= 2 and store.tick_ts >= viking_stage9_next_attack then
			if branch_viking_stage9_attack(store, viking_boss_scene) then
				viking_stage9_next_attack = store.tick_ts + math.random(20, 25)
			else
				viking_stage9_next_attack = store.tick_ts + 2
			end
		end
		if level == 179 then
			local schedules = {[7]={{2,15},{2,28},{2,45}},[9]={{1,12},{1,22},{1,30}},[13]={{1,8},{2,18}},[15]={{1,40},{2,40},{1,60},{2,60}}}
			for i, cfg in ipairs(schedules[wave] or {}) do
				if not nest_counts[i] and elapsed >= cfg[2] then
					nest_counts[i] = true
					local nest = raptor_nests[((cfg[1] or 1) - 1) % math.max(1, #raptor_nests) + 1]
					if nest and store.entities[nest.id] then branch_spawn_scene(store, "fx_velociraptor_nest_hatch", nest.pos.x, nest.pos.y + 8) end
					branch_spawn_on_path(store, "enemy_velociraptor", nil, 0, cfg[1], 1, P:get_start_node(cfg[1]))
				end
			end
		elseif level == 180 then
			local times
			if store.level_mode == GAME_MODE_CAMPAIGN and wave == 11 then
				times = {2, 7, 12, 17, 22}
			elseif store.level_mode == GAME_MODE_HEROIC and wave == 1 then
				times = {2, 5, 8, 11, 14, 17, 20, 23, 26}
			end

			for i, delay in ipairs(times or {}) do
				if not nest_counts[i] and elapsed >= delay then
					nest_counts[i] = true
					local nest = raptor_nests[1]
					if nest and store.entities[nest.id] then branch_spawn_scene(store, "fx_velociraptor_nest_hatch", nest.pos.x, nest.pos.y + 8) end
					branch_spawn_on_path(store, "enemy_velociraptor", nil, 0, 1, 1, P:get_start_node(1))
				end
			end
		end
		if store.level_mode == GAME_MODE_CAMPAIGN and level == 161 then
			local state = branch_stage161_state(store)
			if not boss_spawned and store.waves_finished and not LU.has_alive_enemies(store) then
				boss_spawned = branch_stage161_activate_boss(store) ~= nil
			elseif not boss_spawned and wave > 0 and wave < 15 and store.tick_ts >= state.next_attack_ts then
				branch_viking_stage11_attack(store, state.rider_dragon)
				state.next_attack_ts = store.tick_ts + 18
			end
			if state.finished and state.death_finished and not this.stage161_victory then
				this.stage161_victory = true
				branch_kill_all_enemies_for_victory(store, true)
			end
		end
		if store.level_mode == GAME_MODE_CAMPAIGN and (level == 164 or level == 166) and not boss_spawned and store.waves_finished and not LU.has_alive_enemies(store) then
			boss_spawned = true
			if magnus_scene and store.entities[magnus_scene.id] then
				magnus_scene.exit = true
				while not magnus_scene.exit_done do coroutine.yield() end
			elseif denas_scene and store.entities[denas_scene.id] then
				U.y_animation_play(denas_scene, "denas_taunt", nil, store.tick_ts, 2, 1)
				store.custom_game_outcome = {
					next_item_name = "game", level_idx = 192, level_mode = store.level_mode,
					level_difficulty = store.level_difficulty, campaign_variant = store.campaign_variant,
					kr4_denas_continuation = {lives = store.lives}
				}
			end
			branch_kill_all_enemies_for_victory(store, true)
		end
		if store.level_mode == GAME_MODE_CAMPAIGN and level == 156 and not boss_spawned and wave >= 15 then
			boss_spawned = true

			if boss_dwarf_scene and store.entities[boss_dwarf_scene.id] then
				boss_dwarf_scene.exit = true

				while store.entities[boss_dwarf_scene.id] and not boss_dwarf_scene.exit_done do
					coroutine.yield()
				end
			end

			local boss = branch_spawn_from_pos_to_path(store, "enemy_boss_dwarf_mecha", V.v(260, 628), 2, 1, P:get_start_node(2))

			if boss then
				S:queue("MusicBossFight_156")
			end
		end
		if store.level_mode == GAME_MODE_CAMPAIGN and (level == 172 or level == 195) and not boss_spawned and wave >= 16 then
			if winter_queen_statue and store.entities[winter_queen_statue.id] then
				queue_remove(store, winter_queen_statue)
				winter_queen_statue = nil
			end

			local winter_queen_pos = level == 195 and V.v(930, 664) or V.v(530, 664)
			local boss = branch_spawn_from_pos_to_path(store, "enemy_winter_queen", winter_queen_pos, 3, 1, 45)

			if not boss then
				boss = branch_spawn_boss(store, "enemy_winter_queen", 3, 1, 45)
			end

			if boss then
				if level == 195 then
					boss.branch.stop_wave_spawns_on_death = true
				end

				S:queue("level22_winterqueen_awake")
				S:queue(level == 195 and "MusicBossFight_195" or "MusicBossFight_172")
			end

			boss_spawned = true
		end
		if store.level_mode == GAME_MODE_CAMPAIGN and level == 169 and not boss_spawned and wave >= 16 then
			if anurian_water then queue_remove(store, anurian_water) anurian_water = nil end
			if anurian_water_fx then queue_remove(store, anurian_water_fx) anurian_water_fx = nil end
			local boss = branch_spawn_on_path(store, "enemy_boss_anurian", nil, -1, 2, 1, 47)
			if boss then
				boss.pos = V.v(100, 384)
				local restore_speed = boss.motion.max_speed
				boss.motion.max_speed = 50
				boss.branch.entry_walk = {path = 2, node = 47, restore_speed = restore_speed}
			end
			S:queue("MusicBossFight_169")
			boss_spawned = true
		end
		if store.level_mode == GAME_MODE_CAMPAIGN and level == 178 then
			if not boss_spawned and wave >= 16 then
				boss_spawned = true
				afterlife_bosses = stage178_spawn_afterlife_bosses(store, afterlife_previews)
				afterlife_boss_seen = {}
				S:queue("MusicBossFight_178")
			end

			if boss_spawned and afterlife_bosses and not afterlife_victory then
				local dead_count, seen_count = 0, 0

				for _, boss in ipairs(afterlife_bosses) do
					if boss then
						local stored = store.entities[boss.id]

						if stored then
							afterlife_boss_seen[boss.id] = true
						end

						if afterlife_boss_seen[boss.id] then
							seen_count = seen_count + 1
						end

						if boss.health and boss.health.dead then
							dead_count = dead_count + 1
						end
					end
				end

				if seen_count >= 2 and dead_count >= 2 then
					afterlife_victory = true
					afterlife_cleanup_ts = -1e+99
					stage178_kill_all_enemies_for_victory(store)
				end
			end

			if afterlife_victory and not store.game_outcome and store.tick_ts - afterlife_cleanup_ts >= 0.2 then
				afterlife_cleanup_ts = store.tick_ts
				stage178_kill_all_enemies_for_victory(store)
			end
		end
		if store.level_mode == GAME_MODE_CAMPAIGN and level == 181 and not boss_spawned and wave >= 15 then
			boss_spawned = true
			if great_t_shaman and store.entities[great_t_shaman.id] then
				great_t_shaman.end_sequence = true
			end
			for _, e in pairs(store.entities) do
				if e.template_name == "kr4_carnivorous_plant" then
					S:queue("kr4_enemies_boss_great_t_crunch")
					queue_remove(store, e)
				end
			end
			U.y_wait(store, 2)
			branch_spawn_boss(store, "enemy_boss_great_t", 3, 1, P:get_start_node(3))
			S:queue("MusicBossFight_181")
		end
		if store.level_mode == GAME_MODE_CAMPAIGN and level == 183 and not boss_spawned and wave >= 15 then
			boss_spawned = true
			branch_spawn_boss(store, "enemy_mirage_path", 1, 1, P:get_start_node(1))
		end
		if store.level_mode == GAME_MODE_CAMPAIGN and level == 185 and not boss_spawned and wave >= 15 then
			boss_spawned = true
			local alric_path = branch_kr4_path_rank(1)
			branch_spawn_boss(store, "enemy_alric", alric_path, 1, P:get_start_node(alric_path))
		end
		if store.level_mode == GAME_MODE_CAMPAIGN and level == 186 and not boss_spawned and wave >= 15 then
			boss_spawned = true
			local malik_path = branch_kr4_path_rank(3)
			local malik_node = branch_clamp_path_node(malik_path, 45)
			if malik_throne and store.entities[malik_throne.id] then
				malik_throne.exit_destination = V.vclone(P:node_pos(malik_path, 1, malik_node))
				malik_throne.exit = true
				while store.entities[malik_throne.id] and not malik_throne.exit_done do
					coroutine.yield()
				end
			end
			local malik = branch_spawn_boss(store, "enemy_malik", malik_path, 1, malik_node)
			-- The throne jump already consumed the first scripted destination.
			if malik and malik.branch.rocket_jump then
				malik.branch.rocket_jump.destination_index = 2
			end
		end
		if store.level_mode == GAME_MODE_CAMPAIGN and not boss_spawned and store.waves_finished then
			if level == 156 then
				boss_spawned = true
			elseif level == 165 then
				stage165_spawn_house_event(store, stage165_boss_house_schedule)

				if lightseeker_roof and store.entities[lightseeker_roof.id] then
					lightseeker_roof.exit = true

					while store.entities[lightseeker_roof.id] and not lightseeker_roof.exit_done do
						coroutine.yield()
					end
				end

				local boss = branch_spawn_from_pos_to_path(store, "enemy_lightseeker", V.v(140, 310), 4, 1, 99)

				if not boss then
					boss = branch_spawn_boss(store, "enemy_lightseeker", 4, 1, 99)
				end

				if boss then
					S:queue("MusicBossFight_165")
				end

				boss_spawned = true
			elseif level == 175 then
				stage175_spawn_dragon_king_boss(store)
				boss_spawned = true
			elseif level == 181 then
				boss_spawned=true
			elseif level == 183 then boss_spawned=true
			elseif level == 185 then boss_spawned=true
			elseif level == 186 then
				boss_spawned=true
			end
		end
		coroutine.yield()
	end
end

---------------------------------------------------------
-- KR4 powers and reinforcements (levels 150-199)
---------------------------------------------------------

(function()

function kr4_queue_damage(store, source, target, value, damage_type, track_kills)
	if not target or not target.health or target.health.dead then
		return nil
	end

	local d = E:create_damage()

	d.source_id = source and source.id
	d.target_id = target.id
	d.value = math.max(0, math.floor(value or 0))
	d.damage_type = damage_type or DAMAGE_PHYSICAL
	d.track_kills = track_kills

	queue_damage(store, d)

	return d
end

function kr4_insert_fx(store, name, pos)
	if not name then
		return nil
	end

	local fx = E:create_entity(name)

	fx.pos = V.vclone(pos)

	if fx.render and fx.render.sprites then
		for _, s in pairs(fx.render.sprites) do
			s.ts = store.tick_ts
		end
	end

	queue_insert(store, fx)

	return fx
end

function kr4_death_ray_target_pos(target)
	if not target then
		return nil
	end

	local pos = V.vclone(target.pos)

	if target.unit and target.unit.hit_offset then
		pos.x = pos.x + target.unit.hit_offset.x
		pos.y = pos.y + target.unit.hit_offset.y
	end

	return pos
end

function kr4_death_ray_update_sprite(this, target)
	local to = this.to and V.vclone(this.to) or kr4_death_ray_target_pos(target)

	if not to then
		return false
	end

	if target and target.health and not target.health.dead then
		to = kr4_death_ray_target_pos(target)
	end

	local s = this.render.sprites[1]
	local dx = to.x - this.pos.x
	local dy = to.y - this.pos.y
	local dist = V.dist(to.x, to.y, this.pos.x, this.pos.y)

	s.r = V.angleTo(dx, dy)
	s.scale = s.scale or V.v(1, 1)
	s.scale.x = dist / (this.image_width or 212)
	s.scale.y = 1

	return true
end

scripts.ray_kr4_power_death_ray_coils = {}

function scripts.ray_kr4_power_death_ray_coils.update(this, store, script)
	local target = store.entities[this.target_id]
	local hit_pos = kr4_death_ray_target_pos(target) or this.to

	if not hit_pos then
		queue_remove(store, this)

		return
	end

	this.to = V.vclone(hit_pos)

	U.animation_start(this, "travel", false, store.tick_ts, false, 1)
	kr4_death_ray_update_sprite(this, target)
	kr4_insert_fx(store, this.hit_fx, hit_pos)

	if target and target.health and not target.health.dead then
		kr4_queue_damage(store, store.entities[this.source_id], target, math.random(this.damage_min, this.damage_max), this.damage_type or DAMAGE_TRUE)
	end

	local start_ts = store.tick_ts

	while store.tick_ts - start_ts < (this.duration or 0.43) do
		kr4_death_ray_update_sprite(this, target)
		coroutine.yield()
	end

	queue_remove(store, this)
end

scripts.decal_kr4_power_death_ray_coils = {}

function scripts.decal_kr4_power_death_ray_coils.update(this, store, script)
	local function find_enemy()
		local target = U.find_foremost_enemy(store.entities, this.pos, 0, (this.trigger_dist or 80) + (this.extra_trigger_dist or 0), false, this.vis_flags or 0, this.vis_bans or 0, function(e)
			return not this.target_only_paths or e.nav_path and table.contains(this.target_only_paths, e.nav_path.pi)
		end)

		return target
	end

	U.animation_start(this, "run", false, store.tick_ts, true, this.base_sid)
	U.animation_start(this, "run", false, store.tick_ts, true, this.top_sid)

	local next_attack_ts = store.tick_ts

	while true do
		if store.tick_ts >= next_attack_ts then
			local target = find_enemy()

			if target then
				U.animation_start(this, "charge", false, store.tick_ts, false, this.base_sid)
				U.animation_start(this, "charge", false, store.tick_ts, false, this.top_sid)
				U.y_wait(store, this.action_time or 0.1)

				if not target or target.health and target.health.dead then
					target = find_enemy()
				end

				U.animation_start(this, "shoot", false, store.tick_ts, false, this.base_sid)
				U.animation_start(this, "shoot", false, store.tick_ts, false, this.top_sid)

				if target then
					local ray = E:create_entity(this.ray)

					ray.pos = V.v(this.pos.x + this.shoot_offset.x, this.pos.y + this.shoot_offset.y)
					ray.to = kr4_death_ray_target_pos(target)
					ray.target_id = target.id
					ray.source_id = this.id

					queue_insert(store, ray)
				end

				while not U.animation_finished(this, this.base_sid) do
					coroutine.yield()
				end

				U.animation_start(this, "run", false, store.tick_ts, true, this.base_sid)
				U.animation_start(this, "run", false, store.tick_ts, true, this.top_sid)

				next_attack_ts = store.tick_ts + (this.cooldown or 180)
			end
		end

		U.y_wait(store, this.tick_time or 0.05)
	end
end

function kr4_reinforcement_death_burst(store, this)
	local cfg = this.kr4_reinforcement

	if not cfg or cfg.death_done or not cfg.death_damage or cfg.death_damage <= 0 then
		return
	end

	cfg.death_done = true

	if cfg.death_animation then
		this.unit.death_animation = cfg.death_animation
	end

	kr4_insert_fx(store, cfg.death_decal, this.pos)

	local targets = U.find_enemies_in_range(store.entities, this.pos, 0, cfg.death_radius or 45, 0, F_FLYING)

	for i, target in ipairs(targets or {}) do
		if cfg.death_max_count and i > cfg.death_max_count then
			break
		end

		kr4_queue_damage(store, this, target, cfg.death_damage, cfg.death_type or DAMAGE_PHYSICAL)
	end
end

function kr4_prepare_reinforcement(e, level, center, pos)
	e.pos = V.vclone(pos)
	e.nav_rally.center = V.vclone(center)
	e.nav_rally.pos = V.vclone(pos)

	local cfg = e.kr4_reinforcement

	if cfg then
		if level >= 1 then
			cfg.death_damage = cfg.base_death_damage
			cfg.death_radius = cfg.base_death_radius
			cfg.death_max_count = cfg.base_death_max_count
			cfg.death_type = cfg.base_death_type
		else
			cfg.death_damage = 0
		end
	end
end

scripts.kr4_reinforcement = {}

function scripts.kr4_reinforcement.insert(this, store, script)
	if this.melee then
		this.melee.order = U.attack_order(this.melee.attacks)
	end

	if this.ranged then
		this.ranged.order = U.attack_order(this.ranged.attacks)
	end

	return true
end

function scripts.kr4_reinforcement.update(this, store, script)
	local brk, stam, star

	this.reinforcement.ts = store.tick_ts
	this.render.sprites[1].ts = store.tick_ts

	if this.spawn_animation then
		this.health_bar.hidden = true
		U.y_animation_play(this, this.spawn_animation, nil, store.tick_ts, 1)

		if not this.health.dead then
			this.health_bar.hidden = nil
			U.animation_start(this, "idle", nil, store.tick_ts, true)
		end
	elseif this.kr4_reinforcement and this.kr4_reinforcement.summon_fx then
		kr4_insert_fx(store, this.kr4_reinforcement.summon_fx, this.pos)
	end

	while true do
		if this.health.dead or this.reinforcement.duration and store.tick_ts - this.reinforcement.ts > this.reinforcement.duration then
			if this.health.hp > 0 then
				this.reinforcement.hp_before_timeout = this.health.hp
			end

			this.health.hp = 0

			if IS_KR5 then
				SU.remove_modifiers(store, this)
			end

			kr4_reinforcement_death_burst(store, this)
			SU.y_soldier_death(store, this)

			return
		end

		if this.unit.is_stunned then
			SU.soldier_idle(store, this)
		else
			SU.soldier_courage_upgrade(store, this)

			if this.melee then
				brk, stam = SU.y_soldier_melee_block_and_attacks(store, this)

				if stam == A_IN_COOLDOWN and this.kr4_reinforcement and this.kr4_reinforcement.block_idle then
					local s = this.render and this.render.sprites and this.render.sprites[1]

					if s and s.name ~= this.kr4_reinforcement.block_idle then
						U.animation_start(this, this.kr4_reinforcement.block_idle, s.flip_x, store.tick_ts, true, nil, true)
					end

					goto kr4_reinforcement_yield
				end

				if brk or stam == A_DONE or stam == A_IN_COOLDOWN and not this.melee.continue_in_cooldown then
					goto kr4_reinforcement_yield
				end
			end

			if this.ranged then
				brk, star = SU.y_soldier_ranged_attacks(store, this)

				if brk or star == A_DONE then
					goto kr4_reinforcement_yield
				elseif star == A_IN_COOLDOWN then
					goto kr4_reinforcement_idle
				end
			end

			if this.melee and this.melee.continue_in_cooldown and stam == A_IN_COOLDOWN then
				goto kr4_reinforcement_yield
			end

			if SU.soldier_go_back_step(store, this) then
				goto kr4_reinforcement_yield
			end

			::kr4_reinforcement_idle::

			SU.soldier_idle(store, this)
			SU.soldier_regen(store, this)
		end

		::kr4_reinforcement_yield::

		coroutine.yield()
	end
end

scripts.power_kr4_reinforcements_control = {}

function scripts.power_kr4_reinforcements_control.can_select_point(this, x, y)
	return P:valid_node_nearby(x, y, nil, NF_RALLY) and GR:cell_is_only(x, y, bor(TERRAIN_LAND, TERRAIN_ICE))
end

function kr4_reinforcement_template_for(level, branch)
	if level <= 1 then
		return "soldier_kr4_reinforcement_goonie", "group_demon_goonies_taunt"
	elseif level == 2 then
		return "soldier_kr4_reinforcement_trained_goonie", "group_demon_goonies_taunt"
	elseif branch == "royal" then
		return level >= 4 and "soldier_kr4_reinforcement_demon_guard_nova" or "soldier_kr4_reinforcement_demon_guard", "group_demon_guards_taunt"
	else
		return level >= 4 and "soldier_kr4_reinforcement_flaming_trident" or "soldier_kr4_reinforcement_hellion_trident", "group_demon_tridents_taunt"
	end
end

function scripts.power_kr4_reinforcements_control.insert(this, store, script)
	local center = V.vclone(this.pos)
	local level = km.clamp(0, 5, this.reinforcement_level or UP.levels.reinforcements or 0)
	local template_name, taunt = kr4_reinforcement_template_for(level, this.branch)
	local offsets = this.extra_count and {{0, -20}, {-20, 10}, {20, 10}} or {{10, -10}, {-10, 10}}

	for _, offset in ipairs(offsets) do
		local e = E:create_entity(template_name)

		kr4_prepare_reinforcement(e, level, center, V.v(center.x + offset[1], center.y + offset[2]))
		queue_insert(store, e)
	end

	if level >= 5 and math.random() < (this.pit_lord_chance or 0.3) then
		local e = E:create_entity("soldier_kr4_reinforcement_pit_lord")

		kr4_prepare_reinforcement(e, level, center, V.v(center.x, center.y))
		queue_insert(store, e)
	end

	if taunt then
		S:queue(taunt)
	end

	return true
end

scripts.power_soul_impact_control = {}

function scripts.power_soul_impact_control.can_select_point(this, x, y, store)
	return not GR:cell_is(x, y, TERRAIN_CLIFF) and (P:valid_node_nearby(x, y, 1.4285714285714286, NF_POWER_1) or store.level.fn_can_power and store.level:fn_can_power(store, GUI_MODE_POWER_1, V.v(x, y)) or GR:cell_is(x, y, TERRAIN_WATER))
end

function kr4_soul_random_pos(this)
	local cfg = this.soul_impact
	local p

	for _ = 1, 5 do
		p = V.v(this.pos.x + math.random(-cfg.max_spread, cfg.max_spread), this.pos.y + math.random(-cfg.max_spread, cfg.max_spread))

		if not GR:cell_is(p.x, p.y, TERRAIN_CLIFF) then
			return p
		end
	end

	return V.vclone(this.pos)
end

function kr4_soul_enemy_pos(store)
	local enemies = U.find_enemies_in_range(store.entities, V.v(REF_W * 0.5, REF_H * 0.5), 0, 2000, 0, 0)

	if not enemies or #enemies == 0 then
		return nil
	end

	table.sort(enemies, function(a, b)
		local ai = a.nav_path and a.nav_path.ni or 0
		local bi = b.nav_path and b.nav_path.ni or 0

		return ai > bi
	end)

	return V.vclone(enemies[1].pos)
end

function kr4_soul_apply_mod(store, mod_name, target_id, duration)
	local mod = E:create_entity(mod_name)

	mod.modifier.target_id = target_id

	if duration then
		mod.modifier.duration = duration
	end

	queue_insert(store, mod)
end

function kr4_soul_release_spectres(store, this, pos)
	local cfg = this.soul_impact

	if not cfg.spectre_count or cfg.spectre_count <= 0 then
		return
	end

	local targets = U.find_enemies_in_range(store.entities, pos, 0, cfg.spectre_range or 175, 0, 0)

	if not targets or #targets == 0 then
		return
	end

	S:queue(this.sound_events.spectres)

	for i, target in ipairs(targets) do
		if i > cfg.spectre_count then
			break
		end

		local b = E:create_entity("power_soul_impact_bolt")

		b.pos = V.vclone(pos)
		b.bullet.from = V.vclone(pos)
		b.bullet.to = V.v(target.pos.x + target.unit.hit_offset.x, target.pos.y + target.unit.hit_offset.y)
		b.bullet.target_id = target.id
		b.bullet.damage_min = cfg.spectre_damage_min
		b.bullet.damage_max = cfg.spectre_damage_max
		b.bullet.source_id = this.id

		queue_insert(store, b)
	end
end

function kr4_soul_reduce_cooldown_for_kills(store, this)
	local cfg = this.soul_impact

	if not cfg.kill_cooldown_max or cfg.kill_cooldown_max <= 0 then
		this.track_kills.killed = {}

		return
	end

	for _, killed_id in pairs(this.track_kills.killed) do
		signal.emit("reduce-user-power-cooldown", 1, math.random(cfg.kill_cooldown_min, cfg.kill_cooldown_max))
	end

	this.track_kills.killed = {}
end

function kr4_soul_impact_once(store, this, pos, allow_echo)
	local cfg = this.soul_impact

	kr4_insert_fx(store, "fx_power_soul_impact", pos)
	U.y_wait(store, cfg.damage_delay or 0.2)
	kr4_insert_fx(store, "fx_power_soul_impact_explosion", pos)
	kr4_insert_fx(store, "decal_power_soul_impact_explosion", pos)
	S:queue(this.sound_events.impact)

	local targets = U.find_enemies_in_range(store.entities, pos, 0, cfg.damage_radius, 0, 0)

	for _, target in ipairs(targets or {}) do
		kr4_queue_damage(store, this, target, math.random(cfg.damage_min, cfg.damage_max), cfg.damage_type, true)

		if cfg.stun_duration and cfg.stun_duration > 0 then
			kr4_soul_apply_mod(store, "mod_power_soul_impact_stun", target.id, cfg.stun_duration)
		end

		if cfg.slow_duration and cfg.slow_duration > 0 then
			kr4_soul_apply_mod(store, "mod_power_soul_impact_slow", target.id, cfg.slow_duration)
		end
	end

	coroutine.yield()
	kr4_soul_reduce_cooldown_for_kills(store, this)
	kr4_soul_release_spectres(store, this, pos)

	if allow_echo and cfg.echo_chance and cfg.echo_chance > 0 and math.random() < cfg.echo_chance then
		U.y_wait(store, cfg.echo_delay or 1)
		kr4_soul_impact_once(store, this, pos, false)
	end
end

function scripts.power_soul_impact_control.update(this, store, script)
	local cfg = this.soul_impact
	local count = cfg.impact_count or 3
	local storm_extra = cfg.storm_extra or 0

	this.track_kills.killed = {}
	S:queue(this.sound_events.release)

	for i = 1, count do
		local use_enemy = storm_extra > 0 and i > count - storm_extra
		local pos = use_enemy and kr4_soul_enemy_pos(store) or nil

		pos = pos or kr4_soul_random_pos(this)

		kr4_soul_impact_once(store, this, pos, true)

		if i < count then
			U.y_wait(store, cfg.impact_delay or 0.8)
		end
	end

	queue_remove(store, this)
end

end)()

return scripts

