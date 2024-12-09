local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Shared.Packages.Knit)
local TitleService = Knit.CreateService({
	Name = "TitleService",
	Client = {},
})

function TitleService:KnitInit() 
	self.Titles = {}
end

function TitleService:KnitStart() 
	-- fetch titles, load into service
end

return TitleService
