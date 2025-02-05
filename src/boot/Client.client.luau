local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = game:GetService("ReplicatedStorage").Packages
local Knit = require(Packages.Knit)
local Promise = require(Packages.Promise)

local Llama = require(ReplicatedStorage.Packages.Llama)

local Shared = ReplicatedStorage.Shared

local ClientFolder = ReplicatedStorage.Client

local Components = ClientFolder.Components
local Controllers = ClientFolder.Controllers
local Modules = ClientFolder.Modules

Knit.IsStudio = RunService:IsStudio() or RunService:IsRunMode()
Knit.Shared = Shared
Knit.Modules = Modules
Knit.Components = Components

Knit.AddControllersDeep(Controllers)

Knit.ComponentsLoaded = false

---

function Knit.OnComponentsLoaded()
	return Promise.new(function(resolve, _reject, onCancel)
		if Knit.ComponentsLoaded then
			resolve()
		end

		local heartbeat
		heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
			debug.profilebegin("A")
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

---

local chatSettings = {
	-- The amount of time, in seconds, to wait before a bubble fades out.
	BubbleDuration = 15,

	-- The amount of messages to be displayed, before old ones disappear
	-- immediately when a new message comes in.
	MaxBubbles = 8,

	-- Styling for the bubbles. These settings will change various visual aspects.
	BackgroundColor3 = Color3.fromRGB(35, 35, 35),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.Ubuntu,
	Transparency = 0,
	CornerRadius = UDim.new(0, 10),
	TailVisible = true,
	Padding = 5, -- in pixels
	MaxWidth = 400, --in pixels

	-- Extra space between the head and the billboard (useful if you want to
	-- leave some space for other character billboard UIs)
	VerticalStudsOffset = 0,

	-- Space in pixels between two bubbles
	BubblesSpacing = 8,

	-- The distance (from the camera) that bubbles turn into a single bubble
	-- with ellipses (...) to indicate chatter.
	MinimizeDistance = 120,
	-- The max distance (from the camera) that bubbles are shown at
	MaxDistance = 150,
}
game:GetService("Chat"):SetBubbleChatSettings(chatSettings)

Knit.Start()
	:andThen(function()
		for _, component in pairs(Components:GetDescendants()) do
			if component:IsA("ModuleScript") then
				require(component)
			end
		end
		Knit.ComponentsLoaded = true

		game:GetService("Chat"):SetBubbleChatSettings(chatSettings)
	end)
	:andThen(function()
		--[[ local cmdrClientModuleFile = ReplicatedStorage:WaitForChild("CmdrClient", 15)
		if not cmdrClientModuleFile then
			warn("CmdrClient did not load after 15 seconds. Cmdr commands unavailable.")
		end

		local Cmdr = require(cmdrClientModuleFile)

		Cmdr:SetActivationKeys({ Enum.KeyCode.Tilde, Enum.KeyCode.F2 }) ]]
	end)
	:catch(warn)

task.wait(2)
local PlayerStoreService = Knit.GetService("PlayerStoreService")

local s,p = PlayerStoreService:GetProfile(game.Players.LocalPlayer):await()
warn(s,p)
p.VERSION += 40
warn(s,p)
