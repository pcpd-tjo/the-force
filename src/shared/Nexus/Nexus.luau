-- Draft of how we will load the game manager from one script but for client vs server

-- Nexus is our module loader, state manager, and boundary between client and server in-game.
-- Essentially, it holds all the important stuff for backend services and frontend controllers e.g. DataService, ThemeController
local RS = game:GetService("RunService")
if RS:IsClient() then
    return require(script.Parent.runtimes.ClientNexus)
else
    return require(script.Parent.runtimes.ServerNexus)
end
