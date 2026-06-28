local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Logger = require(ReplicatedStorage.Modules.Core.Logger)

local NPCFactory = {}

function NPCFactory:CreateCustomer(customer)

	local templateFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("NPC")
	local template = templateFolder:WaitForChild("CustomerTemplate")

	local npc = template:Clone()
	npc.Name = "Customer_" .. customer.Id

	npc.Parent = Workspace

	-- เก็บ reference กลับไปที่ data
	customer.Model = npc
	customer.RootPart = npc:FindFirstChild("HumanoidRootPart")

	if customer.RootPart then
		customer.RootPart.CFrame = CFrame.new(0, 5, 0)
	end

	Logger:Info("NPCFactory", "Spawned NPC for Customer #" .. customer.Id)

	return npc
end

return NPCFactory