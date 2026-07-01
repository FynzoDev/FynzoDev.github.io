return function()
	for _, moduleScript: ModuleScript in script:GetDescendants() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local feature = require(moduleScript)
		if type(feature) == "table" and feature.init then
			feature:init()
		end
	end
end
