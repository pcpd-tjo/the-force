local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local ProfileService = require(ServerScriptService.ServerPackages.ProfileService)
local Llama = require(ReplicatedStorage.Packages.Llama)

local SETTINGS = require(script.Parent.Parent.DataStoreSettings)
local LAYOUT = require(script.Parent.LAYOUT)

local PlayerDataService = Knit.CreateService({
	Name = script.Name,
	Client = {
		MyProperty = Knit.CreateProperty("Hello"),
	},
})

PlayerDataService.PLAYER_KEY = "Player_"

local DATABASE_SCOPE = "players"
PlayerDataService.DATABASE_SCOPE = DATABASE_SCOPE

local _Profiles = {}

PlayerDataService.PROFILES = {} 
local ProfileStore = ProfileService.GetProfileStore({
	Name = SETTINGS.DATABASE_NAME,
	--Scope = DATABASE_SCOPE,
}, LAYOUT)

function PlayerDataService.Client:GetProfile(player: Player)
	return self.Server:GetProfile(player)
	--[[ return Promise.new(function(resolve, reject)
		warn("Wagwan fam what you saying g")
		local profile = self.Server:GetProfile(player)
		if profile then
			resolve(Llama.Dictionary.copyDeep(profile))
		else
			reject("Profile not found")
		end
	end)	 *]]
end
function PlayerDataService:GetProfile(player: Player)
	--local p = _Profiles[player] --self.Profiles[player.UserId]
	return if self.PROFILES[player] ~= nil then self.PROFILES[player].Data else "MISSING PROFILE - CONSULT A DEV" -- Return 0 if no points found for player
end

function PlayerDataService.Client:SaveProfile(player: Player, newData)
	return PlayerDataService:SaveProfile(player, newData)
end

function PlayerDataService:SaveProfile(player: Player, newData)
	local profile = self.PROFILES[player]
	profile.Data = newData
	return profile
end

function PlayerDataService:LoadProfile(player: Player)
	local profile = ProfileStore:LoadProfileAsync(self.PLAYER_KEY .. player.UserId)
	if profile ~= nil then
		warn("[PlayerDataService] Found Player Profile " .. player.UserId)
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		warn(profile.Data)
		profile:ListenToRelease(function()
			self.PROFILES[player] = nil
			--player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			self.PROFILES[player] = profile
			profile.Data.TITLES = Llama.List.append(profile.Data.TITLES, "new-title-test")
			profile:Save()
		end
	else
		player:Kick("Your data is corrupt, or failed to load, please contact a developer with your user id ready.")
	end
end

function PlayerDataService:KnitInit()
	-- setup playeradded for loading player profiles from PS
	self.LAYOUT = LAYOUT
	Players.PlayerAdded:Connect(function(player)
		self:LoadProfile(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		local profile = self.PROFILES[player] -- self.Profiles[player]
		if profile ~= nil then
			profile:Release()
		end
	end)
end

function PlayerDataService:KnitStart() end

return PlayerDataService
