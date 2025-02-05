local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local DataService = Knit.CreateService({
	Name = script.Name,
	Client = {},
})

-- this is unlikely to be used on the client, and as such, functions will be made to work only on server (no Client exposed functions)
function DataService:KnitInit() end

function DataService:KnitStart() end

return DataService
