local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logger = require(ReplicatedStorage.Modules.Shared.Logger)

local TestService = {}

function TestService:Init()
	Logger:Info("TestService", "Init")
end

function TestService:Start()
	Logger:Info("TestService", "Start")
end

return TestService