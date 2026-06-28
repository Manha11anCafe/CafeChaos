local ServerScriptService = game:GetService("ServerScriptService")

local ServiceLoader = {}

local Services = {
	require(ServerScriptService.Services.TestService)
}

function ServiceLoader:Load()

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