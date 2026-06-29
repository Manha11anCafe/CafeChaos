-- QueueService.lua
local Workspace           = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local MOVE_TIMEOUT = 10

local QueueService = {
	Name         = "QueueService",
	QueuePoints  = {},
	QueueOrder   = {},
	Occupied     = {},
	WaitingList  = {},
}

function QueueService:Init()

	local folder = Workspace:WaitForChild("QueuePoints")

	self.QueuePoints = {}
	self.QueueOrder  = {}
	self.Occupied    = {}
	self.WaitingList = {}

	for _, p in ipairs(folder:GetChildren()) do
		if p:IsA("BasePart") and p.Name ~= "ExitPoint" then
			table.insert(self.QueuePoints, p)
		end
	end

	table.sort(self.QueuePoints, function(a, b)
		return a.Name < b.Name
	end)
end

function QueueService:GetFree()
	for i = 1, #self.QueuePoints do
		if not self.Occupied[i] then
			return i, self.QueuePoints[i]
		end
	end
	return nil, nil
end

function QueueService:Move(npc, point)
	local hum = npc and npc:FindFirstChildOfClass("Humanoid")
	if hum and point then
		hum:MoveTo(point.Position)
	end
end

-- เมื่อ NPC เดินถึง QueuePoint แล้ว → assign order + เริ่ม patience
local function onNPCReachedQueue(customer)
	local OrderService   = require(ServerScriptService.Services.OrderService)
	local PatienceSystem = require(ServerScriptService.Systems.PatienceSystem)

	OrderService:AssignOrder(customer)
	PatienceSystem:Start(customer)
end

local function assignToSlot(self, customer, index, point)
	self.Occupied[index]  = customer.Id
	customer.QueueIndex   = index
	customer.Target       = point

	table.insert(self.QueueOrder, customer)

	-- Move แล้วรอถึงจริงๆ ก่อน assign order
	task.spawn(function()
		local hum = customer.Model and customer.Model:FindFirstChildOfClass("Humanoid")
		if not hum then return end

		hum:MoveTo(point.Position)

		local done = false
		task.delay(MOVE_TIMEOUT, function()
			if not done then done = true end
		end)

		hum.MoveToFinished:Wait()
		done = true

		-- NPC ถึงที่แล้ว
		if customer.Model and customer.Model.Parent then
			onNPCReachedQueue(customer)
		end
	end)
end

function QueueService:_flushWaiting()
	while #self.WaitingList > 0 do
		local index, point = self:GetFree()
		if not index then break end

		local customer = table.remove(self.WaitingList, 1)
		if customer and customer.Model then
			assignToSlot(self, customer, index, point)
		end
	end
end

function QueueService:Assign(customer)
	if not customer or not customer.Model then return end

	local index, point = self:GetFree()

	if not index then
		table.insert(self.WaitingList, customer)
		return
	end

	assignToSlot(self, customer, index, point)
end

function QueueService:Reorder()
	local new = {}
	self.Occupied = {}

	for _, c in ipairs(self.QueueOrder) do
		if c and c.Model then
			local index = #new + 1
			local point = self.QueuePoints[index]

			if point then
				c.QueueIndex         = index
				self.Occupied[index] = c.Id
				self:Move(c.Model, point)
				table.insert(new, c)
			end
		end
	end

	self.QueueOrder = new
	self:_flushWaiting()
end

local function getExit()
	return Workspace:FindFirstChild("ExitPoint")
		or Workspace.QueuePoints:FindFirstChild("ExitPoint")
end

local function walkToExitAndDestroy(npc)
	local exit = getExit()
	if not exit then
		if npc and npc.Parent then npc:Destroy() end
		return
	end

	local hum = npc:FindFirstChildOfClass("Humanoid")
	if not hum then
		if npc and npc.Parent then npc:Destroy() end
		return
	end

	hum:MoveTo(exit.Position)

	local done = false
	task.delay(MOVE_TIMEOUT, function()
		if not done then
			done = true
			if npc and npc.Parent then npc:Destroy() end
		end
	end)

	hum.MoveToFinished:Wait()
	if not done then
		done = true
		if npc and npc.Parent then npc:Destroy() end
	end
end

function QueueService:SendOut(customer)
	if not customer then return end

	local npc = customer.Model

	for i, c in ipairs(self.QueueOrder) do
		if c.Id == customer.Id then
			table.remove(self.QueueOrder, i)
			break
		end
	end

	if customer.QueueIndex then
		self.Occupied[customer.QueueIndex] = nil
	end

	self:Reorder()

	if npc then
		task.spawn(walkToExitAndDestroy, npc)
	end
end

function QueueService:Clear()
	local waitSnap  = table.move(self.WaitingList, 1, #self.WaitingList, 1, {})
	local queueSnap = table.move(self.QueueOrder,  1, #self.QueueOrder,  1, {})

	self.QueueOrder  = {}
	self.Occupied    = {}
	self.WaitingList = {}

	for _, c in ipairs(queueSnap) do
		if c.Model then task.spawn(walkToExitAndDestroy, c.Model) end
	end

	for _, c in ipairs(waitSnap) do
		if c.Model and c.Model.Parent then c.Model:Destroy() end
	end
end

function QueueService:Start()
end

return QueueService