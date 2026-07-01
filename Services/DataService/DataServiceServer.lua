local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ProfileStore = require(ServerScriptService.Packages.ProfileStore)
local Networker = require(ReplicatedStorage.Packages.Networker)
local Trove = require(ReplicatedStorage.Packages.Trove)

local DataTemplate = require(ReplicatedStorage.Shared.Modules.Core.DataTemplate)
local Configs = require(ReplicatedStorage.Shared.Modules.Core.Configs)

local DataServiceUtils = require(script.Parent.DataServiceUtils)

local DataServiceServer = {}

local PlayerStore = ProfileStore.New(Configs.DATA_STORE_KEY, DataTemplate)

function DataServiceServer.init(self: DataServiceServer)
	self.profiles = {}
	self.troves = {}

	self.networker = Networker.server.new("DataService", self, {
		DataServiceServer.onDataFetching,
	})

	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:onPlayerAdded(player)
		end)
	end

	Players.PlayerAdded:Connect(function(player)
		self:onPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:onPlayerLeft(player)
	end)

	game:BindToClose(function()
		for _, player in Players:GetPlayers() do
			self:onPlayerLeft(player)
		end
	end)
end

function DataServiceServer.onPlayerAdded(self: DataServiceServer, player: Player)
	local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile.OnSessionEnd:Connect(function()
			self.profiles[player] = nil
			player:Kick("Profile session end - Please rejoin")
		end)

		if player.Parent == Players then
			local localTrove = Trove.new()
			self.troves[player] = localTrove
			localTrove:AttachToInstance(player)

			self.profiles[player] = profile

			DataServiceUtils.initLeaderboard(player, profile, localTrove)
			player:SetAttribute("DataLoaded", true)
		else
			profile:EndSession()
		end
	else
		player:Kick("Profile load fail - Please rejoin")
	end
end

function DataServiceServer.onPlayerLeft(self: DataServiceServer, player: Player)
	local profile = self.profiles[player]
	local trove = self.troves[player]

	if profile ~= nil then
		profile:EndSession()
	end

	if trove ~= nil then
		trove:Destroy()
	end
end

function DataServiceServer.getProfile(self: DataServiceServer, player: Player)
	return self.profiles[player]
end

function DataServiceServer.onDataFetching(self: DataServiceServer, player: Player, dataName: string)
	local profile = self.profiles[player]
	if profile then
		return profile.Data[dataName]
	end
end

function DataServiceServer.getNetworker(self: DataServiceServer)
	return self.networker
end

type DataServiceServer = typeof(DataServiceServer) & {
	profiles: {[Player]: any},
	networker: Networker.Server,
	troves: {[Player]: Trove.Trove},
}

return DataServiceServer :: DataServiceServer
