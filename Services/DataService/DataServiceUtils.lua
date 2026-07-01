local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)

local DataServiceUtils = {}

function DataServiceUtils.initLeaderboard(player: Player, profile: {any}, localTrove: Trove.Trove)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local cash = Instance.new("NumberValue")
	cash.Name = "Cash"
	cash.Value = profile.Data.Cash
	cash.Parent = leaderstats

	local heliumPower = Instance.new("NumberValue")
	heliumPower.Name = "HeliumPower"
	heliumPower.Value = profile.Data.heliumPower
	heliumPower.Parent = player

	local currentBalloon = Instance.new("StringValue")
	currentBalloon.Name = "CurrentBalloon"
	currentBalloon.Value = profile.Data.currentBalloon
	currentBalloon.Parent = player

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = profile.Data.Rebirths
	rebirths.Parent = leaderstats

	local playtime = Instance.new("NumberValue")
	playtime.Name = "Playtime"
	playtime.Value = profile.Data.Playtime
	playtime.Parent = player

	local Multipliers = Instance.new("Folder")
	Multipliers.Name = "Multipliers"
	Multipliers.Parent = player

	local LuckMultiplier = Instance.new("NumberValue")
	LuckMultiplier.Name = "LuckMultiplier"
	LuckMultiplier.Value = profile.Data.Multipliers.LuckMultiplier
	LuckMultiplier.Parent = Multipliers

	local CashMultiplier = Instance.new("NumberValue")
	CashMultiplier.Name = "CashMultiplier"
	CashMultiplier.Value = profile.Data.Multipliers.CashMultiplier
	CashMultiplier:SetAttribute("BaseValue", profile.Data.Multipliers.CashMultiplier)
	CashMultiplier.Parent = Multipliers

	local streak = Instance.new("IntValue")
	streak.Name = "Streak"
	streak.Value = profile.Data.Streak
	streak.Parent = player

	localTrove:Add(cash.Changed:Connect(function(value)
		profile.Data.Cash = value
	end))

	localTrove:Add(rebirths.Changed:Connect(function(value)
		profile.Data.Rebirths = value
	end))

	localTrove:Add(playtime.Changed:Connect(function(value)
		profile.Data.Playtime = value
	end))

	localTrove:Add(LuckMultiplier.Changed:Connect(function(value)
		profile.Data.Multipliers.LuckMultiplier = value
	end))

	localTrove:Add(CashMultiplier:GetAttributeChangedSignal("BaseValue"):Connect(function()
		profile.Data.Multipliers.CashMultiplier = CashMultiplier:GetAttribute("BaseValue")
	end))

	localTrove:Add(streak.Changed:Connect(function(value)
		profile.Data.Streak = value
	end))

	if not profile.Data.PlacedBrainrots then
		profile.Data.PlacedBrainrots = {}
	end
	if not profile.Data.InventoryBrainrots then
		profile.Data.InventoryBrainrots = {}
	end
end

function DataServiceUtils.setBaseCashMultiplier(player: Player, value: number)
	local multipliers = player:FindFirstChild("Multipliers")
	if not multipliers then return end
	local cashMultiplier = multipliers:FindFirstChild("CashMultiplier")
	if not cashMultiplier then return end
	cashMultiplier:SetAttribute("BaseValue", value)
end

function DataServiceUtils.addToBaseCashMultiplier(player: Player, delta: number)
	local multipliers = player:FindFirstChild("Multipliers")
	if not multipliers then return end
	local cashMultiplier = multipliers:FindFirstChild("CashMultiplier")
	if not cashMultiplier then return end
	local current = cashMultiplier:GetAttribute("BaseValue") or cashMultiplier.Value
	cashMultiplier:SetAttribute("BaseValue", current + delta)
end


function DataServiceUtils.savePlacedBrainrot(profile: {any}, slotName: string, brainrotName: string?, accumulated: number)
	if not profile.Data.PlacedBrainrots then
		profile.Data.PlacedBrainrots = {}
	end
	if brainrotName then
		local existing = profile.Data.PlacedBrainrots[slotName] or {}
		profile.Data.PlacedBrainrots[slotName] = {
			BrainrotName = brainrotName,
			Accumulated = accumulated or 0,
			Level = existing.Level or 1,
		}
	else
		profile.Data.PlacedBrainrots[slotName] = nil
	end
end

function DataServiceUtils.saveSlotLevel(profile: {any}, slotName: string, level: number)
	if not profile.Data.PlacedBrainrots then
		profile.Data.PlacedBrainrots = {}
	end
	if profile.Data.PlacedBrainrots[slotName] then
		profile.Data.PlacedBrainrots[slotName].Level = level
	end
end

function DataServiceUtils.getPlacedBrainrots(profile: {any}): {[string]: {BrainrotName: string, Accumulated: number, Level: number}}
	return profile.Data.PlacedBrainrots or {}
end

local function generateInventoryId(): string
	return tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
end

function DataServiceUtils.addInventoryBrainrot(profile: {any}, brainrotName: string, level: number?): string
	if not profile.Data.InventoryBrainrots then
		profile.Data.InventoryBrainrots = {}
	end
	local id = generateInventoryId()
	table.insert(profile.Data.InventoryBrainrots, {
		Id = id,
		BrainrotName = brainrotName,
		Level = level or 1,
	})
	return id
end

function DataServiceUtils.removeInventoryBrainrot(profile: {any}, id: string)
	if not profile.Data.InventoryBrainrots then return end
	for i, entry in profile.Data.InventoryBrainrots do
		if entry.Id == id then
			table.remove(profile.Data.InventoryBrainrots, i)
			return
		end
	end
end

function DataServiceUtils.updateInventoryBrainrotLevel(profile: {any}, id: string, level: number)
	if not profile.Data.InventoryBrainrots then return end
	for _, entry in profile.Data.InventoryBrainrots do
		if entry.Id == id then
			entry.Level = level
			return
		end
	end
end

function DataServiceUtils.getInventoryBrainrots(profile: {any}): {{Id: string, BrainrotName: string, Level: number}}
	return profile.Data.InventoryBrainrots or {}
end

function DataServiceUtils.clearInventoryBrainrots(profile: {any})
	profile.Data.InventoryBrainrots = {}
end

return DataServiceUtils
