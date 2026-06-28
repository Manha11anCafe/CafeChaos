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
end

return ServiceLoader