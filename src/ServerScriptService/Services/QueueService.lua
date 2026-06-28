local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPCController = require(script.Parent.Parent.Systems.NPCController)

local Logger = require(ReplicatedStorage.Modules.Core.Logger)

local QueueService = {
	Name = "QueueService"
}

QueueService.QueuePoints = {}
QueueService.QueueOrder = {}
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
	table.insert(self.QueueOrder, customer)

	customer.QueueIndex = index
	customer.Target = point

	Logger:Info(
		self.Name,
		string.format("Assigned Customer #%d to Queue %d", customer.Id, index)
	)

	local npc = customer.Model

	if npc then
		task.spawn(function()
	        NPCController:MoveTo(npc, point)
        end)
	end
end

function QueueService:CleanQueue()
	local newList = {}

	for _, customer in ipairs(self.QueueOrder) do
		if customer then
			table.insert(newList, customer)
		end
	end

	self.QueueOrder = newList
end

function QueueService:ReorderQueue()

	for index, customer in ipairs(self.QueueOrder) do

		if customer and customer.Model and self.QueuePoints[index] then

			customer.QueueIndex = index
			customer.Target = self.QueuePoints[index]

			local npc = customer.Model

			if npc then
				task.spawn(function()
	                NPCController:MoveTo(npc, self.QueuePoints[index])
                end)
			end
		end
	end
end

function QueueService:RemoveCustomer(customerId)

	for i, customer in ipairs(self.QueueOrder) do
		if customer and customer.Id == customerId then
			table.remove(self.QueueOrder, i)
			self.Occupied[i] = nil

			self:CleanQueue()
			self:ReorderQueue()
			return
		end
	end
end

function QueueService:SendCustomerOut(customer)

	if not customer then return end

	local npc = customer.Model
	local exit = Workspace:FindFirstChild("ExitPoint")

	if not npc or not exit then
		return
	end

	task.spawn(function()

	    NPCController:MoveTo(npc, exit)

	    if npc.Parent then
		    npc:Destroy()
	    end

    end)

	self:RemoveCustomer(customer.Id)
end

function QueueService:Start()
	Logger:Info(self.Name, "Start")
end

return QueueService