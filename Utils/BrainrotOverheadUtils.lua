local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Brainrots = require(ReplicatedStorage.Shared.Modules.Core.Brainrots)
local Abbreviate = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Abbreviate"))

local BrainrotOverheadUtils = {}

local CPS_MULT_PER_LEVEL = 1.2
local SIZE_MULT_PER_LEVEL = 1.011

local function getBrainrotData(brainrotName: string)
	for _, data in Brainrots do
		if data.Name == brainrotName then
			return data
		end
	end
	return nil
end

local function getOverheadNameForRarity(rarity: string): string
	return rarity .. "Overhead"
end

local function getCPSWithLevel(baseCPS: number, level: number): number
	return baseCPS * (CPS_MULT_PER_LEVEL ^ (level - 1))
end

local function getModelTopY(model: Model): number
	local minY, maxY = math.huge, -math.huge
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and part.Name ~= "_Overhead" then
			local cf = part.CFrame
			local size = part.Size
			for x = -1, 1, 2 do
				for y = -1, 1, 2 do
					for z = -1, 1, 2 do
						local corner = cf * Vector3.new(size.X / 2 * x, size.Y / 2 * y, size.Z / 2 * z)
						if corner.Y < minY then minY = corner.Y end
						if corner.Y > maxY then maxY = corner.Y end
					end
				end
			end
		end
	end
	return maxY
end

local function captureOriginalValues(overheadPart: BasePart)
	if overheadPart:GetAttribute("OriginalValuesCaptured") then return end

	for _, attachment in overheadPart:GetChildren() do
		if attachment:IsA("Attachment") then
			attachment:SetAttribute("OriginalPosition", attachment.Position)

			for _, gui in attachment:GetChildren() do
				if gui:IsA("BillboardGui") then
					gui:SetAttribute("OriginalSize", gui.Size)
					gui:SetAttribute("OriginalStudsOffset", gui.StudsOffset)
					gui:SetAttribute("OriginalStudsOffsetWorldSpace", gui.StudsOffsetWorldSpace)
				end
			end
		end
	end

	overheadPart:SetAttribute("OriginalValuesCaptured", true)
end
local function scaleOverhead(overheadPart: BasePart, level: number)
	local scale = SIZE_MULT_PER_LEVEL ^ (level - 1)

	captureOriginalValues(overheadPart)

	for _, attachment in overheadPart:GetChildren() do
		if attachment:IsA("Attachment") then
			local origPos = attachment:GetAttribute("OriginalPosition")
			if origPos then
				attachment.Position = origPos * scale
			end

			for _, gui in attachment:GetChildren() do
				if gui:IsA("BillboardGui") then
					local origSize: UDim2 = gui:GetAttribute("OriginalSize")
					local origStudsOffset: Vector3 = gui:GetAttribute("OriginalStudsOffset")
					local origStudsOffsetWorldSpace: Vector3 = gui:GetAttribute("OriginalStudsOffsetWorldSpace")

					if origSize then
						gui.Size = UDim2.new(
							origSize.X.Scale * scale, origSize.X.Offset * scale,
							origSize.Y.Scale * scale, origSize.Y.Offset * scale
						)
					end
					if origStudsOffset then
						gui.StudsOffset = origStudsOffset * scale
					end
					if origStudsOffsetWorldSpace then
						gui.StudsOffsetWorldSpace = origStudsOffsetWorldSpace * scale
					end
				end
			end
		end
	end
end

function BrainrotOverheadUtils.attachOverhead(brainrotModel: Model, brainrotName: string, level: number)
	if not brainrotModel then return end

	local data = getBrainrotData(brainrotName)
	if not data then return end

	local rarity = data.Rarity or "Common"
	local overheadName = getOverheadNameForRarity(rarity)

	local overheadsFolder = ReplicatedStorage.Assets:FindFirstChild("Overheads")
	if not overheadsFolder then return end

	local overheadTemplate = overheadsFolder:FindFirstChild(overheadName)
	if not overheadTemplate then
		return
	end

	local existing = brainrotModel:FindFirstChild("_Overhead")
	if existing then
		existing:Destroy()
	end

	local overheadClone = overheadTemplate:Clone()
	overheadClone.Name = "_Overhead"

	local primary = brainrotModel.PrimaryPart or brainrotModel:FindFirstChildWhichIsA("BasePart")
	if not primary then return end
	local topY = getModelTopY(brainrotModel)
	local primaryY = primary.Position.Y
	local levelScale = SIZE_MULT_PER_LEVEL ^ (level - 1)
	local heightAbove = (topY - primaryY) + 2 * levelScale

	if overheadClone:IsA("BasePart") then
		overheadClone.Anchored = false
		overheadClone.CanCollide = false
		overheadClone.CanQuery = false
		overheadClone.CanTouch = false
		overheadClone.Massless = true
		overheadClone.Transparency = 1
		overheadClone.Size = Vector3.new(0.1, 0.1, 0.1)

		overheadClone.CFrame = primary.CFrame * CFrame.new(0, heightAbove, 0)
		overheadClone.Parent = brainrotModel

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = primary
		weld.Part1 = overheadClone
		weld.Parent = overheadClone

		for _, descendant in overheadClone:GetDescendants() do
			if descendant:IsA("BillboardGui") then
				descendant.AlwaysOnTop = true
				descendant.Enabled = true
				descendant.MaxDistance = 0
			end
		end

		captureOriginalValues(overheadClone)
		if level > 1 then
			scaleOverhead(overheadClone, level)
		end
	else
		overheadClone.Parent = brainrotModel
	end

	BrainrotOverheadUtils.updateOverhead(brainrotModel, brainrotName, level)
end

function BrainrotOverheadUtils.updateOverhead(brainrotModel: Model, brainrotName: string, level: number)
	if not brainrotModel then return end

	local overhead = brainrotModel:FindFirstChild("_Overhead")
	if not overhead then return end
	if overhead:IsA("BasePart") then
		scaleOverhead(overhead, level)
	end

	local attachment = overhead:FindFirstChildWhichIsA("Attachment")
	if not attachment then return end

	local billboard = attachment:FindFirstChildWhichIsA("BillboardGui")
	if not billboard then return end

	local data = getBrainrotData(brainrotName)
	if not data then return end

	local baseCPS = data.CPS or 0
	local actualCPS = getCPSWithLevel(baseCPS, level)
	local rarity = data.Rarity or "Common"

	local nameLabel = billboard:FindFirstChild("Name")
	if nameLabel and (nameLabel:IsA("TextLabel") or nameLabel:IsA("TextButton")) then
		nameLabel.Text = brainrotName
	end

	local cpsLabel = billboard:FindFirstChild("CPS")
	if cpsLabel and (cpsLabel:IsA("TextLabel") or cpsLabel:IsA("TextButton")) then
		cpsLabel.Text = "$" .. Abbreviate.abbreviate(math.floor(actualCPS)) .. "/s"
	end

	local levelLabel = billboard:FindFirstChild("Level")
	if levelLabel and (levelLabel:IsA("TextLabel") or levelLabel:IsA("TextButton")) then
		levelLabel.Text = "Lvl. " .. level
	end

	local rarityLabel = billboard:FindFirstChild("Rarity")
	if rarityLabel and (rarityLabel:IsA("TextLabel") or rarityLabel:IsA("TextButton")) then
		rarityLabel.Text = rarity
	end
end

return BrainrotOverheadUtils
