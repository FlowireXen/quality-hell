--# [SEMBY]; Shoutout to my Balatro-Mod "Shimmerberry" :3
data:extend({
	--# Qualities
	{
		name = "SEMBY_unlocked",
		order = "01",
		setting_type = "startup",
		type = "bool-setting",
		default_value = true
	},
	{
		name = "SEMBY_science_discount",
		order = "02",
		setting_type = "startup",
		type = "double-setting",
		default_value = 80.0,
		minimum_value = 0.0,
		maximum_value = 100.0
	},
	--# Gameplay
	{
		name = "SEMBY_handcraft",
		order = "03",
		setting_type = "startup",
		type = "double-setting",
		default_value = 20.0,
		minimum_value = 0.0,
		maximum_value = 100.0
	},
	{
		name = "SEMBY_quality_machine",
		order = "04",
		setting_type = "startup",
		type = "double-setting",
		default_value = 20.0,
		minimum_value = -100.0,
		maximum_value = 100.0
	},
	{
		name = "SEMBY_quality_miner",
		order = "05",
		setting_type = "startup",
		type = "double-setting",
		default_value = 20.0,
		minimum_value = -100.0,
		maximum_value = 100.0
	},
	{
		name = "SEMBY_allow_quality",
		order = "06",
		setting_type = "startup",
		type = "bool-setting",
		default_value = true
	},
	--# Structure
	{
		name = "SEMBY_structure",
		order = "09",
		setting_type = "startup",
		type = "double-setting",
		default_value = 20.0,
		minimum_value = 0.0,
		maximum_value = 100.0
	},
	{
		name = "SEMBY_structure_distance",
		order = "10",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.1,
		minimum_value = -100.0,
		maximum_value = 100.0
	},
	{
		name = "SEMBY_structure_evolution",
		order = "11",
		setting_type = "startup",
		type = "double-setting",
		default_value = 10.0,
		minimum_value = -100.0,
		maximum_value = 100.0
	},
	--# Entity
	{
		name = "SEMBY_entity",
		order = "12",
		setting_type = "startup",
		type = "double-setting",
		default_value = 20.0,
		minimum_value = 0.0,
		maximum_value = 100.0
	},
	{
		name = "SEMBY_entity_distance",
		order = "13",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.1,
		minimum_value = -100.0,
		maximum_value = 100.0
	},
	{
		name = "SEMBY_entity_evolution",
		order = "14",
		setting_type = "startup",
		type = "double-setting",
		default_value = 10.0,
		minimum_value = -100.0,
		maximum_value = 100.0
	},
	--# Segmented Entity
	{
		name = "SEMBY_segentity",
		order = "15",
		setting_type = "startup",
		type = "double-setting",
		default_value = 20.0,
		minimum_value = 0.0,
		maximum_value = 100.0
	},
	{
		name = "SEMBY_segentity_distance",
		order = "16",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.25,
		minimum_value = -100.0,
		maximum_value = 100.0
	},
	{
		name = "SEMBY_segentity_evolution",
		order = "17",
		setting_type = "startup",
		type = "double-setting",
		default_value = 0.0,
		minimum_value = -100.0,
		maximum_value = 100.0
	},
	--# Distance Calc.
	{
		name = "SEMBY_grace_distance",
		order = "18",
		setting_type = "startup",
		type = "double-setting",
		default_value = 32.0,
		minimum_value = 0.0,
		maximum_value = 256.0
	}
})

if mods["space-age"] then
	data:extend({
		--# Asteroid
		{
			name = "SEMBY_asteroid",
			order = "07",
			setting_type = "startup",
			type = "double-setting",
			default_value = 20.0,
			minimum_value = 0.0,
			maximum_value = 100.0
		},
		{
			name = "SEMBY_asteroid_shuffle",
			order = "08",
			setting_type = "startup",
			type = "bool-setting",
			default_value = true
		}
	})
end
