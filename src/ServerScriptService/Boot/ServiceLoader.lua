local ServiceRegistry = require(script.Parent.ServiceRegistry)

local ServerScriptService = game:GetService("ServerScriptService")
local ServicesFolder = ServerScriptService:WaitForChild("Services")

local ServiceLoader = {}

function ServiceLoader:Load()

	local Services = {}

	-- load all services
	for _, moduleScript in ipairs(ServicesFolder:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then

			local success, service = pcall(require, moduleScript)

			if success and service then
				ServiceRegistry:Register(service.Name, service)
				table.insert(Services, service)
			else
				warn("[ServiceLoader] Failed to load:", moduleScript.Name)
			end
		end
	end

	-- sort
	table.sort(Services, function(a, b)
		return (a.Name or "") < (b.Name or "")
	end)

	-- INIT PHASE
	for _, service in ipairs(Services) do
		if service.Init then
			print("[ServiceLoader] Init:", service.Name)
			service:Init()
		end
	end

	-- START PHASE
	for _, service in ipairs(Services) do
		if service.Start then
			print("[ServiceLoader] Start:", service.Name)
			task.spawn(function()
				service:Start()
			end)
		end
	end

	print("[ServiceLoader] ALL SERVICES LOADED")

end

return ServiceLoader