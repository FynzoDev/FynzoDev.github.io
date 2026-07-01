local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local SocialService = game:GetService("SocialService")

local player: Player = Players.LocalPlayer
local screen = player.PlayerGui:WaitForChild("App"):WaitForChild("Container"):WaitForChild("Screen")
local feature = screen:WaitForChild("Right")

local bottomRightInfo = screen:WaitForChild("BottomRightInfo")

local rightButtons = {}

local function formatPercent(boost: number): string
	return "+" .. math.floor((boost or 0) * 100 + 0.5) .. "%"
end

function rightButtons:updateRobloxPlus()
	local premiumBoost = player:GetAttribute("PremiumBoost") or 0
	self.RobloxPlusPercent.Text = formatPercent(premiumBoost)
end

function rightButtons:updateFriends()
	local friendBoost = player:GetAttribute("FriendBoost") or 0
	self.FriendsPercent.Text = formatPercent(friendBoost)
end

local function promptPremium()
	local ok, err = pcall(function()
		MarketplaceService:PromptPremiumPurchase(player)
	end)
	if not ok then
		warn("[rightButtons] PromptPremiumPurchase נכשל:", err)
	end
end

local function promptInviteFriends()
	local canInvite = false
	local ok = pcall(function()
		canInvite = SocialService:CanSendGameInviteAsync(player)
	end)
end

function rightButtons:init()
	local robloxPlusButton = bottomRightInfo:WaitForChild("RobloxPlus")
	local friendsButton = bottomRightInfo:WaitForChild("Friends")

	self.RobloxPlusPercent = robloxPlusButton:WaitForChild("%")
	self.FriendsPercent = friendsButton:WaitForChild("%")

	self:updateRobloxPlus()
	self:updateFriends()

	player:GetAttributeChangedSignal("PremiumBoost"):Connect(function()
		self:updateRobloxPlus()
	end)
	player:GetAttributeChangedSignal("FriendBoost"):Connect(function()
		self:updateFriends()
	end)


	robloxPlusButton.Activated:Connect(promptPremium)
	friendsButton.Activated:Connect(promptInviteFriends)
end

return rightButtons
