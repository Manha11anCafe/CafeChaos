-- NPCFactory.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService    = game:GetService("PhysicsService")

local NPC_GROUP = "NPC"

local groupExists = false
for _, group in ipairs(PhysicsService:GetRegisteredCollisionGroups()) do
	if group.name == NPC_GROUP then
		groupExists = true
		break
	end
end

if not groupExists then
	PhysicsService:RegisterCollisionGroup(NPC_GROUP)
	PhysicsService:CollisionGroupSetCollidable(NPC_GROUP, NPC_GROUP, false)
end

-- ใช้ BasePart.CollisionGroup แทน SetPartCollisionGroup (deprecated)
local function applyCollisionGroup(model, groupName)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = groupName
		end
	end
end

local NPCFactory = {}

function NPCFactory:SpawnCustomer(id)

	local template = ReplicatedStorage
		:WaitForChild("Assets")
		:WaitForChild("NPC")
		:WaitForChild("CustomerTemplate")

	local npc = template:Clone()
	npc.Name = "Customer_" .. id

	local spawnFolder = workspace:FindFirstChild("NPCSpawn")
	local spawnPart   = spawnFolder and spawnFolder:FindFirstChildOfClass("BasePart")

	if spawnPart then
		local root = npc:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
		end
	end

	local folder = workspace:FindFirstChild("Customers")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Customers"
		folder.Parent = workspace
	end

	npc.Parent = folder

	applyCollisionGroup(npc, NPC_GROUP)

	return npc
end

return NPCFactory