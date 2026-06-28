-- QueueService.lua
local Workspace = game:GetService("Workspace")

local MOVE_TIMEOUT = 10 -- วินาที ถ้าเกินนี้ให้ Destroy เลย

local QueueService = {
	Name = "QueueService"
}

QueueService.QueuePoints = {}
QueueService.QueueOrder  = {}
QueueService.Occupied    = {}

function QueueService:Init()

	local folder = Workspace:WaitForChild("QueuePoints")

	self.QueuePoints = {}
	self.QueueOrder  = {}
	self.Occupied    = {}

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

function QueueService:Assign(customer)

	if not customer or not customer.Model then return end

	local index, point = self:GetFree()
	if not index then return end

	self.Occupied[index]  = customer.Id
	customer.QueueIndex   = index
	customer.Target       = point

	table.insert(self.QueueOrder, customer)
	self:Move(customer.Model, point)
end

function QueueService:Move(npc, point)

	local hum = npc and npc:FindFirstChildOfClass("Humanoid")
	if hum and point then
		hum:MoveTo(point.Position)
	end
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
end

-- หา ExitPoint ทั้งใน Workspace และใน QueuePoints folder
local function getExit()
	return Workspace:FindFirstChild("ExitPoint")
		or Workspace.QueuePoints:FindFirstChild("ExitPoint")
end

-- เดินไปจุดออก รอถึงจริงๆ หรือ timeout แล้ว Destroy
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

	local snapshot = table.move(self.QueueOrder, 1, #self.QueueOrder, 1, {})

	self.QueueOrder = {}
	self.Occupied   = {}

	for _, c in ipairs(snapshot) do
		if c.Model then
			task.spawn(walkToExitAndDestroy, c.Model)
		end
	end
end

function QueueService:Start()
end

return QueueService