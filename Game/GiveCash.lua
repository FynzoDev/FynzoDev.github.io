return function(player: Player, amount: number)
	if amount <= 0 then return end
	local multiplier = 1
	local multipliers = player:FindFirstChild("Multipliers")
	if multipliers then
		local cashMultiplier = multipliers:FindFirstChild("CashMultiplier")
		if cashMultiplier then
			multiplier = cashMultiplier.Value
		end
	end

	amount *= multiplier

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local cash = leaderstats:FindFirstChild("Cash")
	if not cash then return end

	cash.Value += math.floor(amount)
end
