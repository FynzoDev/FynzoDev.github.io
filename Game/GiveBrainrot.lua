return function(brainrotName: string, level: number?, inventoryId: string?)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local CollectionService = game:GetService("CollectionService")

	local BrainrotOverheadUtils = require(ReplicatedStorage.Shared.Modules.Utils.BrainrotOverheadUtils)

	local SIZE_MULT_PER_LEVEL = 1.011

	local brainrotModel: Model = ReplicatedStorage.Assets.Brainrots:FindFirstChild(brainrotName)
	if not brainrotModel then return end

	brainrotModel = brainrotModel:Clone()

	local tool: Tool = Instance.new("Tool")
	tool.Name = brainrotName
	tool.CanBeDropped = false
	tool.RequiresHandle = true

	local primaryPart: BasePart = brainrotModel.PrimaryPart
	if not primaryPart then return end

	local actualLevel = level or 1
	if actualLevel > 1 then
		local targetScale = SIZE_MULT_PER_LEVEL ^ (actualLevel - 1)
		if brainrotModel.ScaleTo then
			brainrotModel:ScaleTo(targetScale)
		end
	end
	BrainrotOverheadUtils.attachOverhead(brainrotModel, brainrotName, actualLevel)

	primaryPart.Name = "Handle"
	primaryPart.Anchored = false

	local overheadPart = brainrotModel:FindFirstChild("_Overhead")

	primaryPart.Parent = tool

	for _, part: BasePart in brainrotModel:GetDescendants() do
		if part:IsA("BasePart") then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = primaryPart
			weld.Part1 = part
			weld.Parent = part
			part.Anchored = false
		end
	end

	if overheadPart and overheadPart:IsA("BasePart") then
		for _, child in overheadPart:GetChildren() do
			if child:IsA("WeldConstraint") then
				child:Destroy()
			end
		end
		overheadPart.Anchored = false
		overheadPart.CanCollide = false
		overheadPart.Massless = true
		overheadPart.Transparency = 1

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = primaryPart
		weld.Part1 = overheadPart
		weld.Parent = overheadPart
	end

	tool:SetAttribute("ToolType", "Brainrot")
	tool:SetAttribute("BrainrotName", brainrotName)
	tool:SetAttribute("Level", actualLevel)
	if inventoryId then
		tool:SetAttribute("InventoryId", inventoryId)
	end

	brainrotModel.Parent = tool

	CollectionService:AddTag(tool, "BrainrotPlacer")

	return tool
end
