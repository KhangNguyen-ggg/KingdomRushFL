local bit = require("bit")
local GR = require("grid_db")
local P = require("path_db")

local band = bit.band
local bor = bit.bor
local M = {}

local function blockable_node(pi, spi, ni)
	if not P:is_node_valid(pi, ni, NF_ALL) then
		return false
	end

	local pos = P:node_pos(pi, spi, ni)
	local terrain = GR:cell_type(pos.x, pos.y)

	return band(terrain, bor(TERRAIN_WATER, TERRAIN_CLIFF, TERRAIN_NOWALK)) == 0
end

function M.place_enemy(target, previous_path, force_blockable)
	local nav = target.nav_path

	if not nav then
		return
	end

	if force_blockable or target.enemy and not target.water and not target.cliff and band(target.vis.flags, F_FLYING) == 0 then
		local pi, spi, ni = nav.pi, nav.spi, nav.ni
		local last = #P:path(pi, spi)
		local found = blockable_node(pi, spi, ni) and ni or nil

		for distance = 1, math.min(24, last) do
			if found then
				break
			end

			if ni - distance >= 1 and blockable_node(pi, spi, ni - distance) then
				found = ni - distance
			elseif ni + distance <= last and blockable_node(pi, spi, ni + distance) then
				found = ni + distance
			end
		end

		if found then
			nav.ni = found
		elseif previous_path then
			target.nav_path = previous_path
			nav = previous_path
		end
	end

	local pos = P:node_pos(nav)
	target.pos.x, target.pos.y = pos.x, pos.y
end

function M.sync_enemy_terrain(store, target, SU)
	if target.enemy and target.water then
		SU.enemy_water_change(store, target)
	end

	if target.enemy and target.cliff then
		SU.enemy_cliff_change(store, target)
	end
end

return M
