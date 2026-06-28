local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logger = require(ReplicatedStorage.Modules.Core.Logger)

local TestService = {
	Name = "TestService"
}

function TestService:Init()
	Logger:Info(self.Name, "Init")
end

function TestService:Start()
	Logger:Info(self.Name, "Start")
end

return TestService