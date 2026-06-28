local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logger = require(
	ReplicatedStorage.Modules.Shared.Logger
)

Logger:Info("Bootstrap", "Server is starting...")
Logger:Info("Bootstrap", "Initialization complete.")