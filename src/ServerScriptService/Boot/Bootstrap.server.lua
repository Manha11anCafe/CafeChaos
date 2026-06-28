local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Logger = require(ReplicatedStorage.Modules.Core.Logger)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)
local ServiceLoader = require(ServerScriptService.Boot.ServiceLoader)

Logger:Info("Bootstrap", "Server is starting...")
Logger:Info(
	"Bootstrap",
	string.format("%s v%s", GameConfig.Game.Name, GameConfig.Game.Version)
)

ServiceLoader:Load()

Logger:Info("Bootstrap", "Initialization complete.")