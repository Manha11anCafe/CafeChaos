local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logger = require(ReplicatedStorage.Modules.Shared.Logger)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)

Logger:Info("Bootstrap", "Server is starting...")
Logger:Info(
	"Bootstrap",
	string.format("%s v%s", GameConfig.Game.Name, GameConfig.Game.Version)
)
Logger:Info("Bootstrap", "Initialization complete.")