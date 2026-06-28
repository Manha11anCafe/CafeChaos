local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logger = require(ReplicatedStorage.Modules.Shared.Logger)

local TestService = {}

function TestService:Init()
	Logger:Info("TestService", "Initialized")
end

return TestService