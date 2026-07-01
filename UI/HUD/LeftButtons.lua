local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networker = require(ReplicatedStorage.Packages.Networker)

local player: Player = Players.LocalPlayer
local screen = player.PlayerGui:WaitForChild("App"):WaitForChild("Container"):WaitForChild("Screen")
local feature = screen:WaitForChild("Left")
local feature2 = screen:WaitForChild("Right")

local Shop = require(ReplicatedStorage.UI.Menus.Shop)
local Settings = require(ReplicatedStorage.UI.Menus.Settings)
local Index = require(ReplicatedStorage.UI.Menus.Index) 
local Rebirth = require(ReplicatedStorage.UI.Menus.Rebirth)


local leftButtons = {}
leftButtons.Buttons = {
	Shop = Shop,
	Settings = Settings,
	Index = Index,
	Rebirth = Rebirth,
}

function leftButtons:toggleAllVisilbityOff(buttonName: string)
	for name, module in pairs(leftButtons.Buttons) do
		if name == buttonName then continue end
		if module.closeWindow then module:closeWindow() end
	end
end

function leftButtons:init()
	feature.Settings.Active = true
	feature.Shop.Active = true
	feature.Index.Active = true
	feature.Rebirth.Active = true

	feature.Settings.Activated:Connect(function()
		self:openWindow("Settings")
	end)
	feature.Rebirth.Activated:Connect(function()
		self:openWindow("Rebirth")
	end)
	feature.Shop.Activated:Connect(function()
		self:openWindow("Shop")
	end)
	feature.Index.Activated:Connect(function()
		self:openWindow("Index")
	end)

	self:setupPromptWindows()
end

function leftButtons:openWindow(windowName: string)
	if not windowName or windowName == "" then return end

	if self.Buttons[windowName] then
		self:toggleAllVisilbityOff(windowName)
		self.Buttons[windowName]:toggleVisiblity()
	else
		warn("Warning: Window '" .. tostring(windowName) .. "' not found in leftButtons")
	end
end

function leftButtons:setupPromptWindows()
	local networker = Networker.client.new("BoothShopService", leftButtons, {
		leftButtons.openWindow
	})
end

return leftButtons
