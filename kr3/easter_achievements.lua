local signal = require("hump.signal")
local events = require("data.easter_achievement_events")
local M = {}

local function current_generation()
	local current = rawget(_G, "game") or package.loaded.game
	local level = current and current.store and current.store.level_idx
	if type(level) ~= "number" then return end
	if level >= 150 and level <= 201 then return 4 end
	if level >= 101 and level <= 141 then return 5 end
	if level >= 251 and level <= 269 then return 6 end
end

function M:register_handlers(A)
	for event, listener in pairs(self.listeners or {}) do signal.remove(event, listener) end
	self.listeners = {}
	local killed = function(entity)
		if current_generation() == 4 and entity and entity.template_name == "enemy_linirea_joe" then A:got("KR4_ACHIEVEMENT_FARMER_JOE") end
	end
	signal.register("entity-killed", killed)
	self.listeners["entity-killed"] = killed
	for generation, definitions in pairs(events) do
		local expected_generation = tonumber(generation)
		for event, definition in pairs(definitions) do
			local spec = definition
			local listener = function(value)
				if current_generation() ~= expected_generation then return end
				if spec.method == "runes" then
					local rune = type(value) == "string" and tonumber(value:match("^RUNEQUEST_([1-6])$"))
					if rune then A:flag_check(spec.id, 2 ^ (rune - 1)) end
				elseif spec.method == "index_flag" then
					local index = tonumber(value)
					-- Two DLC scripts still send FL level numbers with the original offset.
					if index and index >= 100 then index = index - 100 end
					if index and index % 1 == 0 and index >= 0 and index <= spec.max_index then
						A:flag_check(spec.id, 2 ^ index)
					end
				else
					A[spec.method](A, spec.id)
				end
			end
			signal.register(event, listener)
			self.listeners[event] = listener
		end
	end
end

return M
