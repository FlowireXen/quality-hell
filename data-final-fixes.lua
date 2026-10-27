--# Stored settings
local QH_all_quality = settings.startup["SEMBY_allow_quality"].value

local QH_machine = settings.startup["SEMBY_quality_machine"].value / 100
local QH_miner = settings.startup["SEMBY_quality_miner"].value / 100

local QH_asteroid = mods["space-age"] and settings.startup["SEMBY_asteroid"].value / 100 or 0

--# Allow "Quality" in all recipes
if QH_all_quality then
	for _, recipe in pairs(data.raw["recipe"]) do
		if recipe then recipe.allow_quality = true end
	end
end

--# Set base quality
local function QH_QualifyReceiver(receiver, chance)
	-- allow quality
	if receiver.allowed_effects then
		if type(receiver.allowed_effects) ~= "table" then
			receiver.allowed_effects = { receiver.allowed_effects }
		end
		table.insert(receiver.allowed_effects, "quality")
	end
	-- effect table
	if not receiver.effect_receiver then
		receiver.effect_receiver = { }
	end
	-- base quality
	if not receiver.effect_receiver.base_effect then
		receiver.effect_receiver.base_effect = { }
	end
	receiver.effect_receiver.base_effect.quality = chance
	-- min/max quality
	--if not receiver.effect_receiver.quality_limits then
	--	receiver.effect_receiver.quality_limits = { }
	--end
	--receiver.effect_receiver.quality_limits.low = settings.startup["SEMBY_quality_min"].value / 100
	--receiver.effect_receiver.quality_limits.high = settings.startup["SEMBY_quality_max"].value / 100
end

if QH_machine ~= 0 then
	for _, machine in pairs(data.raw["assembling-machine"]) do
		QH_QualifyReceiver(machine, QH_machine)
	end
	for _, furnace in pairs(data.raw["furnace"]) do
		QH_QualifyReceiver(furnace, QH_machine)
	end
end
if QH_miner ~= 0 then
	for _, mining in pairs(data.raw["mining-drill"]) do
		QH_QualifyReceiver(mining, QH_miner)
	end
end

--# Asteroid quality
if QH_asteroid ~= 0 then
	for _, asteroid in pairs(data.raw["asteroid"]) do
		-- Add new call/create-event
		local create_effect = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					type = "script",
					effect_id = "quality-hell-asteroid-created"
				}
			}
		}
		if not asteroid.created_effect then
			asteroid.created_effect = { create_effect }
		else
			if type(asteroid.created_effect) ~= "table" then
				asteroid.created_effect = { asteroid.created_effect }
			end
			table.insert(asteroid.created_effect, create_effect)
		end
	end
end
