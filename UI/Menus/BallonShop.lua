local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local Balloons = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Core"):WaitForChild("Balloons"))
local Monetization = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Core"):WaitForChild("Monetization"))
local Abbreviate = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Abbreviate"))
local notifyUnlock = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Game"):WaitForChild("UnluckFrame"))
local UIManager = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Core"):WaitForChild("UIManager"))

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local BalloonShopEvent = RemotesFolder:WaitForChild("BalloonShopEvent") :: RemoteEvent

local BalloonShop = {}

local localPlayer: Player
local playerGui: PlayerGui
local feature: Frame
local mainFrame: Frame
local scrollingFrame: ScrollingFrame

local DEFAULT_BALLOON_NAME = "Red Balloon"

local ownedBalloons: {[string]: boolean} = {}
local equippedBalloon: string? = nil
local balloonClones: {[string]: Frame} = {}

local function getRobuxPrice(productId: number): number?
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfoAsync(productId, Enum.InfoType.Product)
	end)
	if success and info then
		return info.PriceInRobux
	end
	return nil
end

local function refreshBalloonUI(balloonName: string)
	local clone = balloonClones[balloonName]
	if not clone then return end

	local buttonList = clone:FindFirstChild("ButtonList", true)
	if not buttonList then return end

	local buyButton = buttonList:FindFirstChild("BuyButton")
	local robuxButton = buttonList:FindFirstChild("RobuxButton")

	local isOwned = ownedBalloons[balloonName] == true
	local isEquipped = equippedBalloon == balloonName
	local isDefault = balloonName == DEFAULT_BALLOON_NAME

	if robuxButton then
		if isDefault or isOwned then
			robuxButton.Visible = false
		else
			robuxButton.Visible = true
		end
	end

	if buyButton then
		local priceBtn = buyButton:FindFirstChild("Price")
		if priceBtn and (priceBtn:IsA("TextLabel") or priceBtn:IsA("TextButton")) then
			local balloonData
			for _, data in Balloons do
				if data.Name == balloonName then
					balloonData = data
					break
				end
			end

			if isOwned then
				if isEquipped then
					priceBtn.Text = "Equipped"
				else
					priceBtn.Text = "Equip"
				end
			else
				if balloonData then
					priceBtn.Text = "$" .. Abbreviate.abbreviate(balloonData.Price)
				end
			end
		end
	end
end

local function refreshAllBalloons()
	for balloonName, _ in balloonClones do
		refreshBalloonUI(balloonName)
	end
end

local function onBuyButtonClicked(balloonData)
	local balloonName = balloonData.Name
	local isOwned = ownedBalloons[balloonName] == true

	if isOwned then
		BalloonShopEvent:FireServer("equipBalloon", balloonName)
	else
		BalloonShopEvent:FireServer("purchaseBalloon", balloonName)
	end
end

local function populateBalloons()
	if not scrollingFrame then return end

	local templatesFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Templets")
	local balloonTemplate = templatesFolder:WaitForChild("BalloonShopTemplet")
	local raritiesFolder = templatesFolder:WaitForChild("Rarities")

	for _, child in scrollingFrame:GetChildren() do
		if child.Name == "Gap" then continue end
		if child:IsA("Frame") or child:IsA("ImageLabel") or child:IsA("ImageButton") or child:IsA("TextButton") then
			child:Destroy()
		end
	end
	balloonClones = {}

	for i, balloonData in Balloons do
		local clone = balloonTemplate:Clone()
		clone.Name = balloonData.Name
		balloonClones[balloonData.Name] = clone

		local nameBottom = clone:FindFirstChild("BallonNameButtom", true)
		if nameBottom and (nameBottom:IsA("TextLabel") or nameBottom:IsA("TextButton")) then
			nameBottom.Text = balloonData.Name
		end

		local nameTop = clone:FindFirstChild("BallonNameTop", true)
		if nameTop and (nameTop:IsA("TextLabel") or nameTop:IsA("TextButton")) then
			nameTop.Text = balloonData.Name
		end

		local icon = clone:FindFirstChild("Icon", true)
		if icon and (icon:IsA("ImageLabel") or icon:IsA("ImageButton")) then
			icon.Image = balloonData.Image
		end

		local buttonList = clone:FindFirstChild("ButtonList", true)
		if buttonList then
			local buyButton = buttonList:FindFirstChild("BuyButton")
			if buyButton then
				if buyButton:IsA("GuiButton") then
					buyButton.Activated:Connect(function()
						onBuyButtonClicked(balloonData)
					end)
				else
					buyButton.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							onBuyButtonClicked(balloonData)
						end
					end)
				end
			end

			local robuxButton = buttonList:FindFirstChild("RobuxButton")
			if robuxButton then
				local devProductData = Monetization.DevProducts[balloonData.Name]
				local productId = devProductData and devProductData.ID or nil

				local robuxPriceBtn = robuxButton:FindFirstChild("Price")
				if robuxPriceBtn and (robuxPriceBtn:IsA("TextLabel") or robuxPriceBtn:IsA("TextButton")) then
					if productId then
						robuxPriceBtn.Text = "..."
						task.spawn(function()
							local robuxPrice = getRobuxPrice(productId)
							if robuxPrice and robuxPriceBtn.Parent then
								robuxPriceBtn.Text = tostring(robuxPrice)
							elseif robuxPriceBtn.Parent then
								robuxPriceBtn.Text = "?"
							end
						end)
					else
						robuxPriceBtn.Text = ""
					end
				end

				if productId then
					if robuxButton:IsA("GuiButton") then
						robuxButton.Activated:Connect(function()
							MarketplaceService:PromptProductPurchase(localPlayer, productId)
						end)
					else
						robuxButton.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
								MarketplaceService:PromptProductPurchase(localPlayer, productId)
							end
						end)
					end
				end
			end
		end

		local durabilityLabel = clone:FindFirstChild("Durability", true)
		if durabilityLabel and (durabilityLabel:IsA("TextLabel") or durabilityLabel:IsA("TextButton")) then
			durabilityLabel.Text = tostring(balloonData.Durability)
		end

		local rarityLabel = clone:FindFirstChild("Rarity", true)
		if rarityLabel and (rarityLabel:IsA("TextLabel") or rarityLabel:IsA("TextButton")) then
			rarityLabel.Text = balloonData.Rarity

			local existingGradient = rarityLabel:FindFirstChildOfClass("UIGradient")
			if existingGradient then existingGradient:Destroy() end

			local rarityGradient = raritiesFolder:FindFirstChild(balloonData.Rarity)
			if rarityGradient and rarityGradient:IsA("UIGradient") then
				local gradientClone = rarityGradient:Clone()
				gradientClone.Parent = rarityLabel
			end
		end

		clone.Parent = scrollingFrame
	end

	refreshAllBalloons()
end

function BalloonShop:init()
	if not RunService:IsClient() then return end

	localPlayer = Players.LocalPlayer
	if not localPlayer then
		repeat task.wait() until Players.LocalPlayer
		localPlayer = Players.LocalPlayer
	end

	playerGui = localPlayer:WaitForChild("PlayerGui")
	feature = playerGui:WaitForChild("App"):WaitForChild("Container"):WaitForChild("Frames"):WaitForChild("BalloonShop")
	mainFrame = feature:WaitForChild("Main")
	scrollingFrame = mainFrame:WaitForChild("ScrollingFrame")

	feature.Close.Activated:Connect(function()
		self:closeWindow()
	end)

	BalloonShopEvent.OnClientEvent:Connect(function(action, state)
		if action == "updateBalloonState" and state then
			if state.owned then ownedBalloons = state.owned end
			if state.equipped ~= nil then equippedBalloon = state.equipped end
			refreshAllBalloons()

		elseif action == "balloonUnlocked" and state and state.balloonName then
			notifyUnlock("Balloon", state.balloonName)
		end
	end)

	MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, wasPurchased)
		if userId ~= localPlayer.UserId then return end
		if wasPurchased then
			BalloonShopEvent:FireServer("requestBalloonState")
		end
	end)

	populateBalloons()

	BalloonShopEvent:FireServer("requestBalloonState")

	self:closeWindow(true)
end

function BalloonShop:openWindow()
	if not feature then return end
	UIManager:RequestOpen(self, feature)
end

function BalloonShop:closeWindow(instant, switching)
	if not feature then return end
	UIManager:RequestClose(self, feature, instant, switching)
end

function BalloonShop:toggleVisiblity(open: boolean?)
	if open ~= nil then
		if not open then self:closeWindow() else self:openWindow() end
	else
		if not feature.Visible then self:openWindow() else self:closeWindow() end
	end
end

type BalloonShop = typeof(BalloonShop)
return BalloonShop :: BalloonShop
