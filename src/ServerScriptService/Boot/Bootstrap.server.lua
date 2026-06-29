-- Bootstrap.server.lua
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Logger        = require(ReplicatedStorage.Modules.Core.Logger)
local GameConfig    = require(ReplicatedStorage.Config.GameConfig)
local ServiceLoader = require(ServerScriptService.Boot.ServiceLoader)

local function setupRemotes()

	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end

	local function makeRemote(name)
		if not folder:FindFirstChild(name) then
			local r = Instance.new("RemoteEvent")
			r.Name = name
			r.Parent = folder
			Logger:Info("Bootstrap", "Created Remote: " .. name)
		end
	end

	local function makeFunction(name)
		if not folder:FindFirstChild(name) then
			local f = Instance.new("RemoteFunction")
			f.Name = name
			f.Parent = folder
			Logger:Info("Bootstrap", "Created RemoteFunction: " .. name)
		end
	end

	-- Debug
	makeRemote("DebugCommand")

	-- Order System
	makeRemote("ShowOrder")        -- Server -> Client: แสดง order เหนือหัว NPC
	makeRemote("UpdatePatience")   -- Server -> Client: อัพเดต patience bar
	makeRemote("TakeOrder")        -- Client -> Server: ผู้เล่นกด E รับ order
	makeRemote("OrderListUpdated") -- Server -> Client: อัพเดต order list ใน HUD

end

Logger:Info("Bootstrap", "Server is starting...")
Logger:Info("Bootstrap", string.format("%s v%s", GameConfig.Game.Name, GameConfig.Game.Version))

setupRemotes()
ServiceLoader:Load()

Logger:Info("Bootstrap", "Initialization complete.")