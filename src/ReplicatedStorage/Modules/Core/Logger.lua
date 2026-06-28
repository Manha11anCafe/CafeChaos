-- Logger.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- โหลด GameConfig แบบ lazy เพื่อกัน circular require
local _config = nil
local function getConfig()
	if not _config then
		local ok, cfg = pcall(function()
			return require(ReplicatedStorage.Config.GameConfig)
		end)
		_config = ok and cfg or { Debug = false }
	end
	return _config
end

local Logger = {}

function Logger:Info(system, message)
	if getConfig().Debug then
		print(string.format("[%s] %s", system, message))
	end
end

function Logger:Warn(system, message)
	warn(string.format("[%s] WARNING: %s", system, message))
end

function Logger:Error(system, message)
	error(string.format("[%s] ERROR: %s", system, message), 2)
end

return Logger