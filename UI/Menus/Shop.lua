local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local UIManager = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Core"):WaitForChild("UIManager"))
local SoundService = game:GetService("SoundService")
local sound = SoundService:WaitForChild("UI"):WaitForChild("RobuxShopBell")

local player: Player = Players.LocalPlayer
local feature = player.PlayerGui
	:WaitForChild("App")
	:WaitForChild("Container")
	:WaitForChild("Frames")
	:WaitForChild("Shop")

local content = feature:WaitForChild("Content")
local scroll = content:WaitForChild("Scroll")

local Shop = {}

local STAGGER_DELAY = 0.15   
local ITEM_TIME = 0.35       
local animToken = 0        

local function getItems()
	local items = {}
	for _, child in scroll:GetChildren() do
		if child:IsA("GuiObject") then
			table.insert(items, child)
		end
	end
	table.sort(items, function(a, b)
		if a.LayoutOrder ~= b.LayoutOrder then
			return a.LayoutOrder < b.LayoutOrder
		end
		return a.Name < b.Name
	end)
	return items
end

local function playRevealAnimation()
	animToken += 1
	local myToken = animToken

	local items = getItems()
	for _, item in items do
		local scale = item:FindFirstChildWhichIsA("UIScale")
		if not scale then
			scale = Instance.new("UIScale")
			scale.Parent = item
		end
		scale.Scale = 0
	end

	for i, item in items do
		task.spawn(function()
			task.wait((i - 1) * STAGGER_DELAY)
			if myToken ~= animToken then return end

			local scale = item:FindFirstChildWhichIsA("UIScale")
			if not scale then return end

			TweenService:Create(
				scale,
				TweenInfo.new(ITEM_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ Scale = 1 }
			):Play()
		end)
	end
end


feature.Close.Active = true
feature.Close.Activated:Connect(function()
	Shop:closeWindow()
end)

function Shop:openWindow()
	if not feature then return end
	UIManager:RequestOpen(self, feature)
	playRevealAnimation()
	sound:Play()
end

function Shop:closeWindow(instant, switching)
	if not feature then return end
	animToken += 1
	UIManager:RequestClose(self, feature, instant, switching)
end

function Shop:toggleVisiblity(open: boolean?)
	if open ~= nil then
		if not open then self:closeWindow() else self:openWindow() end
	else
		if not feature.Visible then self:openWindow() else self:closeWindow() end
	end
end

Shop:closeWindow(true)

type Shop = typeof(Shop)
return Shop :: Shop
