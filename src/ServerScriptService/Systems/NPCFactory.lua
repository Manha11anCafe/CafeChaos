local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NPCFactory = {}

function NPCFactory:SpawnCustomer(id)

    local template = ReplicatedStorage
        :WaitForChild("Assets")
        :WaitForChild("NPC")
        :WaitForChild("CustomerTemplate")

    local npc = template:Clone()
    npc.Name = "Customer_" .. id

    -- หา spawn point
    local spawnFolder = workspace:FindFirstChild("NPCSpawn")
    local spawnPart = spawnFolder and spawnFolder:FindFirstChildOfClass("BasePart")

    -- วาง NPC ที่ spawn point ก่อน parent
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

    return npc
end

return NPCFactory