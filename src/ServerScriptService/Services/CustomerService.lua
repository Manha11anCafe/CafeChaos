local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logger = require(ReplicatedStorage.Modules.Core.Logger)

local QueueService = require(script.Parent.QueueService)
local NPCFactory = require(script.Parent.Parent.Systems.NPCFactory)
local CustomerState = require(script.Parent.Parent.Systems.CustomerState)

local CustomerService = {
	Name = "CustomerService"
}

-- Dictionary สำหรับค้นหาด้วย ID
CustomerService.Customers = {}

function CustomerService:Init()

	Logger:Info(self.Name, "Init")

	self.Customers = {}

end

function CustomerService:GetCustomer(id)
	return self.Customers[id]
end

function CustomerService:CreateCustomer(id)

	local customer = {

		Id = id,

		State = CustomerState.Spawning,

		Mood = 100,
		Patience = 100,

		QueueIndex = nil,

		Model = nil,
		Target = nil,

		SpawnTime = os.clock(),

		MoveToken = 0,
	}

	local npc = NPCFactory:SpawnCustomer(id)

	customer.Model = npc

	self.Customers[id] = customer

	customer.State = CustomerState.WalkingToQueue

	QueueService:Assign(customer)

	Logger:Info(self.Name, "Created Customer #" .. id)

	return customer

end

function CustomerService:RemoveCustomer(id)

	self.Customers[id] = nil

end

function CustomerService:Start()

	Logger:Info(self.Name, "Start")

	-- Spawn อัตโนมัติปิดไว้ ใช้ Debug เท่านั้น

end

return CustomerService