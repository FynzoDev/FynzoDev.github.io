local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networker = require(ReplicatedStorage.Packages.Networker)

local DataServiceClient = {}

function DataServiceClient.init(self: DataServiceClient)
	self.networker = Networker.client.new("DataService", self)
end

function DataServiceClient.fetchData(self: DataServiceClient, dataName: string)
	local data = self.networker:fetch("onDataFetching", dataName)
	return data
end

type DataServiceClient = typeof(DataServiceClient) & {
	networker: Networker.Client
}

return DataServiceClient :: DataServiceClient
