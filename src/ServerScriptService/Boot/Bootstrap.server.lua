-- Bootstrap.server.lua
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Logger      = require(ReplicatedStorage.Modules.Core.Logger)
local GameConfig  = require(ReplicatedStorage.Config.GameConfig)
local ServiceLoader = require(ServerScriptService.Boot.ServiceLoader)

-- ============================
-- สร้าง Remotes ทั้งหมดก่อน
-- เพื่อกัน RemoteEvent หายตอน Rojo sync
-- ============================
local function setupRemotes()

	local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

	if not remotesFolder then
		remotesFolder = Instance.new("Folder")
		remotesFolder.Name = "Remotes"
		remotesFolder.Parent = ReplicatedStorage
	end

	local function createRemote(name)
		if not remotesFolder:FindFirstChild(name) then
			local remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = remotesFolder
			Logger:Info("Bootstrap", "Created Remote: " .. name)
		end
	end

	-- เพิ่ม Remote ใหม่ตรงนี้เสมอ
	createRemote("DebugCommand")

end

-- ============================
-- Boot Sequence
-- ============================
Logger:Info("Bootstrap", "Server is starting...")
Logger:Info("Bootstrap", string.format("%s v%s", GameConfig.Game.Name, GameConfig.Game.Version))

setupRemotes()

ServiceLoader:Load()

Logger:Info("Bootstrap", "Initialization complete.")