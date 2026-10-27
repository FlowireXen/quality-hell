--# Stored settings
local QH_unlocked = settings.startup["SEMBY_unlocked"].value

local QH_handcraft = settings.startup["SEMBY_handcraft"].value / 100

local QH_asteroid = script.active_mods["space-age"] and settings.startup["SEMBY_asteroid"].value / 100 or 0
local QH_asteroid_shuffle = settings.startup["SEMBY_asteroid_shuffle"].value

local QH_struct = settings.startup["SEMBY_structure"].value / 100
local QH_struct_dist = settings.startup["SEMBY_structure_distance"].value / 100
local QH_struct_evo = settings.startup["SEMBY_structure_evolution"].value / 100

local QH_entity = settings.startup["SEMBY_entity"].value / 100
local QH_entity_dist = settings.startup["SEMBY_entity_distance"].value / 100
local QH_entity_evo = settings.startup["SEMBY_entity_evolution"].value / 100

local QH_segentity = settings.startup["SEMBY_segentity"].value / 100
local QH_segentity_dist = settings.startup["SEMBY_segentity_distance"].value / 100
local QH_segentity_evo = settings.startup["SEMBY_segentity_evolution"].value / 100

local QH_grace_dist = settings.startup["SEMBY_grace_distance"].value

--# Quality:tm: functions
local function QH_GetQuality(quality, chance, limited)
	return quality and quality.roll_quality(chance, math.random(), limited and "player" or nil)
end

local QH_quality_count = #prototypes.quality -2
local function QH_rngQuality(quality, chance)
	if quality and math.random() <= chance then
		local count = math.random(QH_quality_count)
		for i = 1, count do
			if quality.next ~= nil then
				quality = quality.next
			else break end
		end
	end
	return quality
end

local function QH_GetDistChance(dist_mult, position)
	if position then
		return math.max(0, math.max(math.abs(position.x), math.abs(position.y)) / 32 - QH_grace_dist) * dist_mult
	else return 0 end
end
local function QH_GetEvoChance(evo_mult, force, surface)
	return game.forces[force and force.name or "enemy"].get_evolution_factor(surface) * evo_mult
end

local function QH_QualifyEntity(entity, chance, dist_mult, evo_mult)
	if entity and entity.valid and entity.quality and entity.quality.next then
		-- position
		local position = entity.position
		local surface = entity.surface.name
		-- chance
		if dist_mult ~= 0 then
			chance = chance + QH_GetDistChance(dist_mult, position)
		end
		if evo_mult ~= 0 then
			chance = chance + QH_GetEvoChance(evo_mult, entity.force, surface)
		end
		-- qualify
		local quality = QH_GetQuality(entity.quality, chance, false)
		if quality and quality ~= entity.quality then
			--game.print("Entity: "..position.x..", "..position.y)
			local new_entity = {
				name = entity.name,
				quality = quality,
				force = entity.force,
				position = position,
				direction = entity.direction
			}
			entity.destroy({raise_destroy = false})
			game.surfaces[surface].create_entity(new_entity)
		end
	end
end

--# Unlock qualities
local function QH_UnlockQualities()
	if QH_unlocked then
		for _, quality in pairs(prototypes.quality) do
			game.forces["player"].unlock_quality(quality.name)
		end
	else
		game.forces["player"].unlock_quality("uncommon");
		game.forces["player"].unlock_quality("rare");
	end
end
script.on_init(function()
	QH_UnlockQualities()
end)
script.on_configuration_changed(function()
	QH_UnlockQualities()
end)

--# Handcraft quality (Thanks: PennyJim)
if QH_handcraft ~= 0 then
	script.on_event(defines.events.on_player_crafted_item, function(event)
		local baseStack = event.item_stack
		if baseStack and baseStack.valid and baseStack.quality and baseStack.quality.next then
			local quality = QH_GetQuality(baseStack.quality, QH_handcraft, true)
			if quality and quality ~= baseStack.quality then
				--game.print("Handcraft: "..quality.name)
				-- PennyJim copy;
				local copyStack = {
					name = baseStack.name,
					count = baseStack.count,
					health = baseStack.health,
					quality = quality,
					spoil_percent = baseStack.spoil_percent,
				}
				if baseStack.is_tool then
					copyStack.durability = baseStack.durability
				end
				if baseStack.is_ammo then
					copyStack.ammo = baseStack.ammo
				end
				if baseStack.is_item_with_tags then
					copyStack.tags = baseStack.tags
					copyStack.custom_description = baseStack.custom_description
				end
				-- Apply copy;
				baseStack.set_stack(copyStack)
			end
		end
	end)
end

--# Asteroid quality
if QH_asteroid ~= 0 then
	script.on_event(defines.events.on_script_trigger_effect, function(event)
		if event.effect_id == "quality-hell-asteroid-created" then
			local entity = event.source_entity
			if entity and entity.valid and entity.type == "asteroid" then
				local position = entity.position
				-- "event.tick" would block chances for multiple asteroids.
				-- i can't filter this event or add any tags to the entity.
				-- i don't know how and i don't want to use dummy-entities.
				-- but i noticed that "natural" positions are even for one;
				if position.x % 1 == 0 or position.y % 1 == 0 then
					local quality = QH_asteroid_shuffle and QH_rngQuality(entity.quality, QH_asteroid)
									or QH_GetQuality(entity.quality, QH_asteroid, false)
					if quality and quality ~= entity.quality then
						--game.print("Asteroid: "..position.x..", "..position.y..", tick: "..event.tick..", Q: "..quality.name)
						local surface = entity.surface.name
						-- stupid scuffed bs
						position.x = position.x + (position.x >= 0 and 0.01 or -0.01)
						position.y = position.y + (position.y >= 0 and 0.01 or -0.01)
						local new_entity = {
							name = entity.name,
							quality = quality,
							force = entity.force,
							position = position,
							direction = entity.direction,
							velocity = entity.get_movement()
						}
						entity.destroy({raise_destroy = false})
						local asteroid = game.surfaces[surface].create_entity(new_entity)
					end
				end
			end
		end
	end)
end

--# Structure quality
if QH_struct ~= 0 or QH_struct_dist ~= 0 or QH_struct_evo ~= 0 then
	--## Scan new chunks
	script.on_event(defines.events.on_chunk_generated, function(event)
		local surface, area = event.surface, event.area
		for _, entity in pairs(surface.find_entities_filtered({area = area, force = "enemy"})) do
			if entity.type == "unit-spawner" or entity.type == "turret" then
				QH_QualifyEntity(entity, QH_struct, QH_struct_dist, QH_struct_evo)
			end
		end
	end)
	--## New structure
	script.on_event(defines.events.on_biter_base_built, function(event)
		QH_QualifyEntity(event.entity, QH_struct, QH_struct_dist, QH_struct_evo)
	end)
end

--# Entity quality
if QH_entity ~= 0 or QH_entity_dist ~= 0 or QH_entity_evo ~= 0 then
	--## New entity
	script.on_event(defines.events.on_entity_spawned, function(event)
		QH_QualifyEntity(event.entity, QH_entity, QH_entity_dist, QH_entity_evo)
	end)
end

--# Segmented entity quality
if QH_segentity ~= 0 or QH_segentity_dist ~= 0 or QH_segentity_evo ~= 0 then
	--## New segmented entity
	script.on_event(defines.events.on_segmented_unit_created, function(event)
		local entity = event.segmented_unit
		if entity and entity.valid and entity.segments then
			-- position
			local position = entity.segments[1].position
			local surface = entity.surface.name
			-- chance
			local chance = QH_segentity
			if QH_segentity_dist ~= 0 then
				chance = chance + QH_GetDistChance(QH_segentity_dist, position)
			end
			if QH_segentity_evo ~= 0 then
				chance = chance + QH_GetEvoChance(QH_segentity_evo, entity.force, surface)
			end
			-- qualify
			local quality = QH_GetQuality(prototypes.quality["normal"], chance, false)
			if quality and quality.name ~= "normal" then
				--game.print("SegEntity: "..position.x..", "..position.y)
				local new_entity = {
					name = entity.prototype.name,
					quality = quality,
					force = entity.force,
					territory = entity.territory,
					position = position,
					body_nodes = entity.get_body_nodes()
				}
				entity.destroy({raise_destroy = false})
				game.surfaces[surface].create_segmented_unit(new_entity)
			end
		end
	end, {{filter = "cause", cause = defines.segmented_unit_created_cause.map_generated}})
end
