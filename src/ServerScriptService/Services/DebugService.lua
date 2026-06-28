-- DebugService.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DebugService = {
	Name = "DebugService"
}

function DebugService:Init()

	local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DebugCommand")

	remote.OnServerEvent:Connect(function(player, command)

		local CustomerService = require(ServerScriptService.Services.CustomerService)
		local QueueService = require(ServerScriptService.Services.QueueService)

		if command == "spawn" then
			CustomerService:CreateCustomer(math.random(1000, 9999))

		elseif command == "sendout" then
			-- ส่งออกแค่คนแรกในคิว
			local first = QueueService.QueueOrder[1]
			if first then
				QueueService:SendOut(first)
			end

		elseif command == "clear" then
			QueueService:Clear()
		end
	end)
end

function DebugService:Start() end

return DebugService