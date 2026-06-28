local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logger = require(ReplicatedStorage.Modules.Core.Logger)

local NPCFactory = {
	Name = "NPCFactory"
}

-- 📌 ดึง Template จาก ReplicatedStorage
local function getTemplate()
	local assets = ReplicatedStorage:WaitForChild("Assets")
	local npcFolder = assets:WaitForChild("NPC")
	local template = npcFolder:WaitForChild("CustomerTemplate")

	return template
end

function NPCFactory:SpawnCustomer(id)

	local template = getTemplate()

	if not template then
		warn("[NPCFactory] CustomerTemplate not found")
		return nil
	end

	local clone = template:Clone()
	clone.Name = "Customer_" .. id

	-- 📌 วางใน workspace สำหรับ NPC ที่ active อยู่
	local customersFolder = workspace:FindFirstChild("Customers")

	if not customersFolder then
		customersFolder = Instance.new("Folder")
		customersFolder.Name = "Customers"
		customersFolder.Parent = workspace
	end

	clone.Parent = customersFolder

	Logger:Info(self.Name, "Spawned NPC for Customer #" .. id)

	return clone
end

return NPCFactory