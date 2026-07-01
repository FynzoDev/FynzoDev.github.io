local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Abbreviate = require(ReplicatedStorage.Packages.Abbreviate)

local secondToMS = require(ReplicatedStorage.Shared.Modules.Game.SecondToHMS)

local player: Player = Players.LocalPlayer
local feature = player.PlayerGui:WaitForChild("App"):WaitForChild("Container"):WaitForChild("Screen"):WaitForChild("BottomLeftInfo")

local Stats = {}

local function playCashSound()
	local template = SoundService:FindFirstChild("SFX")
	if not template then return end
	template = template:FindFirstChild("Cash")
	if not template or not template:IsA("Sound") then return end

	local clone = template:Clone()
	clone.Name = "Cash_" .. tostring(math.random(1, 1e9))
	clone.Parent = SoundService
	clone:Play()

	clone.Ended:Once(function()
		clone:Destroy()
	end)

	-- הגנה אם Ended לא נורה
	task.delay((template.TimeLength > 0 and template.TimeLength or 5) + 1, function()
		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
end

function Stats:init()
	self:setupCashStats()
	self:setupFriendBoostStats()
end

function Stats:setupCashStats()
	local leaderstats = player:WaitForChild("leaderstats")
	local cash: NumberValue = leaderstats:WaitForChild("Cash")

	feature.MoneyDisplay.Money.MoneyCount.Text = "$ " .. Abbreviate.abbreviate(cash.Value)

	local previousCash: number = cash.Value

	cash.Changed:Connect(function(newValue: number)

		if newValue > previousCash then
			playCashSound()

			local delta = newValue - previousCash

			local plusCash: TextLabel = script.PlusCash:Clone()
			plusCash.Text = "+$ " .. Abbreviate.abbreviate(delta)
			plusCash.Parent = feature.CashEffect

			task.delay(1, function()
				local textTransparency = TweenService:Create(plusCash, TweenInfo.new(0.5), {TextTransparency = 1})
				textTransparency:Play()
				textTransparency.Completed:Once(function()
					plusCash:Destroy()
				end)
			end)

		elseif newValue < previousCash then
			playCashSound()

			local delta = previousCash - newValue

			local minusCash: TextLabel = script.MinusCash:Clone()
			minusCash.Text = "-$ " .. Abbreviate.abbreviate(delta)
			minusCash.Parent = feature.CashEffect

			task.delay(1, function()
				local textTransparency = TweenService:Create(minusCash, TweenInfo.new(0.5), {TextTransparency = 1})
				textTransparency:Play()
				textTransparency.Completed:Once(function()
					minusCash:Destroy()
				end)
			end)
		end

		previousCash = newValue
		feature.MoneyDisplay.Money.MoneyCount.Text = "$ " .. Abbreviate.abbreviate(newValue)
	end)
end

function Stats:setupFriendBoostStats()
	local friendBoost: IntValue = player:WaitForChild("FriendBoost")

	friendBoost.Changed:Connect(function(value: number)
		feature.FriendBoost.Percentage.Text = (friendBoost.Value * 100) .. "%" 
	end)
end

return Stats
