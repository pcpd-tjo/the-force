local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Llama = require(ReplicatedStorage.Packages.Llama)

local Shared = ReplicatedStorage.Shared
local Dict = Llama.Dictionary

local Components = script.Components
local Services = script.Services
local Modules = script.Modules


Knit.IsStudio = RunService:IsStudio() or RunService:IsRunMode()
Knit.Shared = Shared
Knit.Modules = Modules
Knit.Components = Components

Knit.AddServicesDeep(Services)

Knit.ComponentsLoaded = false

---

function Knit.OnComponentsLoaded()
	return Promise.new(function(resolve, _reject, onCancel)
		if Knit.ComponentsLoaded then
			resolve()
		end

		local heartbeat
		heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
			debug.profilebegin("B")
			if Knit.ComponentsLoaded then
				heartbeat:Disconnect()
				resolve()
			end
			debug.profileend()
		end)

		onCancel(function()
			if heartbeat then
				heartbeat:Disconnect()
			end
		end)
	end)
end

Knit.Start()
	:andThen(function()
		for _, component in pairs(Components:GetDescendants()) do
			require(component)
		end
		Knit.ComponentsLoaded = true
	end)
	:andThen(function()
		local Cmdr = require(ServerScriptService.ServerPackages.Cmdr)

		--Cmdr:RegisterHooksIn(ServerScriptService.Server.Modules.CmdrHooks)
		--Cmdr:RegisterTypesIn(ServerScriptService.Server.Modules.CmdrTypes)
		--Cmdr:RegisterCommandsIn(ServerScriptService.Server.Modules.CmdrCommands)
		Cmdr:RegisterDefaultCommands()
	end)
	:catch(warn)
