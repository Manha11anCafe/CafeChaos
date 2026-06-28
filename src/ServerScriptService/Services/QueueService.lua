local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")

local Logger = require(ReplicatedStorage.Modules.Core.Logger)

local QueueService = {
	Name = "QueueService"
}

QueueService.QueuePoints = {}
QueueService.Occupied = {}

function QueueService:Init()
	Logger:Info(self.Name, "Init")

	local queueFolder = Workspace:WaitForChild("QueuePoints")

	for _, point in ipairs(queueFolder:GetChildren()) do
		if point:IsA("BasePart") then
			table.insert(self.QueuePoints, point)
		end
	end

	table.sort(self.QueuePoints, function(a, b)
		return a.Name < b.Name
	end)
end

function QueueService:GetFreePosition()
	for index, point in ipairs(self.QueuePoints) do
		if not self.Occupied[index] then
			return index, point
		end
	end

	return nil, nil
end

function QueueService:Assign(customer)
	local index, point = self:GetFreePosition()

	if not point then
		Logger:Info(self.Name, "Queue is full!")
		return
	end

	self.Occupied[index] = customer.Id
	customer.QueueIndex = index
	customer.Target = point

	Logger:Info(
		self.Name,
		string.format("Assigned Customer #%d to Queue %d", customer.Id, index)
	)

	local npc = customer.Model
	if npc and npc.PrimaryPart then
		task.spawn(function()
	        self:MoveNPC(npc, point)
        end)
	end
end

function QueueService:Start()
	Logger:Info(self.Name, "Start")
end

function QueueService:MoveNPC(npc, targetPosition)

	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local root = npc:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then
		return
	end

	local path = PathfindingService:CreatePath()

	path:ComputeAsync(root.Position, targetPosition.Position)

	if path.Status ~= Enum.PathStatus.Success then
		warn("[QueueService] Path failed")
		return
	end

	local waypoints = path:GetWaypoints()

	for _, waypoint in ipairs(waypoints) do
		humanoid:MoveTo(waypoint.Position)
		humanoid.MoveToFinished:Wait()
	end
end

return QueueService