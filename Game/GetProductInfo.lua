local MarketplaceService = game:GetService("MarketplaceService")

return function(ID: number, Type: Enum.InfoType)
	
	local productInfo
	local success, result

	repeat
		success, result = pcall(function()
			return MarketplaceService:GetProductInfoAsync(
				ID,
				Type
			)
		end)

		if not success then
			task.wait(1)
		end
	until success

	productInfo = result
	
	return productInfo
end
