local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local MarketplaceService = game:GetService("MarketplaceService")
local StarterGui: StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Confetti = require(ReplicatedStorage.Packages.ConfettiHandler)

local localPlayer: Player = Players.LocalPlayer

local Core = {}

function Core:init()
	self.confetti = Confetti.new()
	self:initPurchaseSounds()
	self:disableResetButton()
end

function Core:disableResetButton()
	local disabled = false

	while not disabled do
		disabled = pcall(function()
			StarterGui:SetCore("ResetButtonCallback", false)
		end)

		if not disabled then
			task.wait()
		end
	end
end

function Core:initPurchaseSounds()
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player: Player, gamePassId: number, wasPurchased: boolean)
		if player ~= localPlayer then return end

		if wasPurchased then
			self.confetti:Emit(100, UDim2.fromScale(.5, 1))
			SoundService:PlayLocalSound(SoundService.SFX.Money)
		end
	end)
	
	MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId: number, productId: number, isPurchased: boolean) 
		if userId ~= localPlayer.UserId then return end

		if isPurchased then
			self.confetti:Emit(100, UDim2.fromScale(.5, 1))
			SoundService:PlayLocalSound(SoundService.SFX.Money)
		end
	end)
end

return Core
