local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local Promise = require(ReplicatedStorage.Packages.Promise)

local SETTINGS = require(script.Parent.Parent.DataStoreSettings)
local LAYOUT = require(script.Parent.STORE_LAYOUT)

local PlayerStoreService = Knit.CreateService({
	Name = script.Name,
	Client = {},
})

PlayerStoreService.PLAYER_KEY = "players.Player_"

local PROFILES = require(script.Parent.PROFILES)

function PlayerStoreService.Client:GetProfile(player: Player)
	return self.Server:GetProfile(player)
end
function PlayerStoreService:GetProfile(player: Player)
	local profile = PROFILES[player] or "[PlayerStoreService] Missing Profile"
	print(PROFILES)
	return profile.Data
end

function PlayerStoreService.Client:SaveProfile(player: Player, newData)
	return PlayerStoreService:SaveProfile(player, newData)
end

function PlayerStoreService:SaveProfile(player, newData)
	local profile = PROFILES[player]
	profile.Data = newData
	return profile.Data or {}
end

function PlayerStoreService:LoadProfile(player: Player)
	return Promise.new(function(resolve, reject, _reject)
		-- Start a profile session for this player's data:
		task.spawn(function()
			local profile = self.PlayerStore:StartSessionAsync(`{self.PLAYER_KEY}{player.UserId}`, {
				Cancel = function()
					return player.Parent ~= Players
				end,
			})

			-- Handling new profile session or failure to start it:

			if profile ~= nil then
				profile:AddUserId(player.UserId) -- GDPR compliance
				profile:Reconcile() -- Fill in missing variables from PROFILE_TEMPLATE (optional)

				profile.OnSessionEnd:Connect(function()
					PROFILES[player] = nil
					player:Kick(`Profile session end - Please rejoin`)
				end)

				if player.Parent == Players then
					PROFILES[player] = profile
					print(`Profile loaded for {player.Name}!`, profile)
					resolve(true)
				else
					-- The player has left before the profile session started
					profile:EndSession()
					_reject("AH")
				end
			else
				-- This condition should only happen when the Roblox server is shutting down
				player:Kick(`Profile load fail - Please rejoin`)
				_reject("AH")
			end
		end)
	end)
end

function PlayerStoreService:KnitInit()
	-- setup playeradded for loading player profiles from PS
	self.LAYOUT = LAYOUT
	self.PlayerStore = ProfileStore.New(SETTINGS.DATABASE_NAME, LAYOUT)

	if RunService:IsStudio() or RunService:IsRunMode() then
		self.PlayerStore = self.PlayerStore.Mock
	end

	Players.PlayerAdded:Connect(function(player)
		self:LoadProfile(player):await()
	end)

	Players.PlayerRemoving:Connect(function(player)
		local profile = PROFILES[player]
		if profile ~= nil then
			profile:EndSession()
		end
	end)
end

function PlayerStoreService:KnitStart() end

return PlayerStoreService
