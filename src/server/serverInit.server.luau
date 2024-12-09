--[[ 

local services = Loader.LoadDescendants(game.ReplicatedStorage.Shared.Services, Loader.MatchesName("Service$"))

Loader.SpawnAll(services, "OnStart") ]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Shared.Packages.Knit)
local Loader = require(ReplicatedStorage.Shared.Packages.Loader)

--[[ local services = Loader.LoadDescendants(ReplicatedStorage.Shared.Services, Loader.MatchesName("Service$"))
for _, service in services do
	Knit.CreateService(service)
end *]]

Knit.AddServicesDeep(ReplicatedStorage.Shared.Services)

Knit.Start()
