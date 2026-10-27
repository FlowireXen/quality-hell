--# Stored settings
local QH_discount = settings.startup["SEMBY_science_discount"].value / 100

--# Reduce cost of technologies
if QH_discount ~= 0 then
	for _, technology in pairs(data.raw["technology"]) do
		if technology and technology.unit and technology.unit.count then
			local effects = technology.effects
			if effects and #effects > 0 then
				local quality_only
				for i = 1, #effects do
					if effects[i] and effects[i].type and effects[i].type == "unlock-quality" then
						quality_only = true
					else
						quality_only = false
						break
					end
				end
				if quality_only then
					technology.unit.count = math.max(1, math.floor(technology.unit.count * (1.0 - QH_discount)))
				end
			end
		end
	end
end
