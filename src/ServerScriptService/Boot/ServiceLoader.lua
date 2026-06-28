-- ServiceLoader.lua
local ServiceRegistry = require(script.Parent.ServiceRegistry)

local ServerScriptService = game:GetService("ServerScriptService")
local ServicesFolder = ServerScriptService:WaitForChild("Services")

local ServiceLoader = {}

function ServiceLoader:Load()

	local services = {}

	-- 1. require ทุก service
	for _, moduleScript in ipairs(ServicesFolder:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then

			local ok, service = pcall(require, moduleScript)

			if ok and type(service) == "table" then

				if not service.Name then
					service.Name = moduleScript.Name
				end

				ServiceRegistry:Register(service.Name, service)
				table.insert(services, service)

			else
				warn(string.format("[ServiceLoader] require failed: %s — %s", moduleScript.Name, tostring(service)))
			end
		end
	end

	-- 2. Init ทีละตัว — ถ้าพังให้ warn แต่ไม่หยุด service อื่น
	for _, s in ipairs(services) do
		if s.Init then
			local ok, err = pcall(function() s:Init() end)
			if not ok then
				warn(string.format("[ServiceLoader] Init failed: %s — %s", s.Name, tostring(err)))
			end
		end
	end

	-- 3. Start ทีละตัว — spawn แยก thread กันบล็อกกัน
	for _, s in ipairs(services) do
		if s.Start then
			task.spawn(function()
				local ok, err = pcall(function() s:Start() end)
				if not ok then
					warn(string.format("[ServiceLoader] Start failed: %s — %s", s.Name, tostring(err)))
				end
			end)
		end
	end

	print("[ServiceLoader] All services loaded.")
end

return ServiceLoader