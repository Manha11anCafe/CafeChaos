local ServiceRegistry = require(script.Parent.ServiceRegistry)

local ServerScriptService = game:GetService("ServerScriptService")

local ServicesFolder = ServerScriptService:WaitForChild("Services")

local ServiceLoader = {}

local Services = {}

function ServiceLoader:Load()

	table.clear(Services)

	for _, moduleScript in ipairs(ServicesFolder:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then

			local service = require(moduleScript)
            
            ServiceRegistry:Register(service.Name, service)

			table.insert(Services, service)

		end
	end

	table.sort(Services, function(a, b)
		return (a.Name or "") < (b.Name or "")
	end)

	for _, service in ipairs(Services) do
		if service.Init then
			service:Init()
		end
	end

	for _, service in ipairs(Services) do
		if service.Start then
			service:Start()
		end
	end

end

return ServiceLoader