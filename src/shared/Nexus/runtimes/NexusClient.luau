export type Controller = {
    Name: string,
    Client: (any) -> (any),
}
export type NexusClient = {
    Player: Player,
    Util: Folder,
    Controllers: { Controller }
}
local NexusClient: NexusClient = {}

NexusClient.__index = NexusClient

NexusClient.Player = game:GetService("Players").LocalPlayer
NexusClient.Util = game:GetService("ReplicatedStorage").Shared.Packages

NexusClient.Controllers = {}

local Promise = require(NexusClient.Util.Promise)
local Comm = require(NexusClient.Util.Comm)
local ClientComm = Comm.ClientComm

return NexusClient