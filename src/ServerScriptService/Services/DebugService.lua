local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CustomerService = require(script.Parent.CustomerService)
local QueueService = require(script.Parent.QueueService)

local DebugService = {
	Name = "DebugService"
}

function DebugService:Init()

	local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DebugCommand")

	print("[DEBUG SERVICE] INIT OK")

	remote.OnServerEvent:Connect(function(player, command)

		print("[DEBUG SERVER]", command)

		if command == "spawn" then
			CustomerService:CreateCustomer(math.random(1000,9999))

		elseif command == "sendout" then
			if QueueService.QueueOrder then
				for _, c in ipairs(QueueService.QueueOrder) do
					if c then
						QueueService:SendCustomerOut(c)
					end
				end
			end
		end

	end)
end

return DebugService