local ServiceRegistry = {}

local Services = {}

function ServiceRegistry:Register(name, service)
	Services[name] = service
end

function ServiceRegistry:Get(name)
	return Services[name]
end

return ServiceRegistry