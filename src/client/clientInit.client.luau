--[[ local Loader = require(game.ReplicatedStorage.Packages.Loader)

local controllers = Loader.LoadDescendants(game.ReplicatedStorage.Shared.Services, Loader.MatchesName("Controller$"))

Loader.SpawnAll(controllers, "OnStart") ]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Shared.Packages.Knit)

Knit.AddControllers(ReplicatedStorage.Shared.Controllers)

Knit:Start({ ServicePromises = false })

local PlayerDataService = Knit.GetService("PlayerDataService")

local s, p = PlayerDataService:GetProfile(game.Players.LocalPlayer):await()
warn(s)
warn(p)
p.VERSION += 400

local _s, _p = PlayerDataService:SaveProfile(Knit.Player, {
	VERSION = p.VERSION,
	TITLES = p.TITLES,
}):await()

warn(_p)
