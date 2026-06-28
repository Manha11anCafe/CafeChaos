-- CustomerService.lua
local ReplicatedStorage    = game:GetService("ReplicatedStorage")
local ServerScriptService  = game:GetService("ServerScriptService")

local Customer    = require(ServerScriptService.Systems.Customer)
local QueueService = require(ServerScriptService.Services.QueueService)
local NPCFactory  = require(ServerScriptService.Systems.NPCFactory)

local CustomerService = {
	Name = "CustomerService"
}

CustomerService.Customers = {}

function CustomerService:Init()
	self.Customers = {}
end

function CustomerService:CreateCustomer(id)

	-- ใช้ Customer.new() แทน table ธรรมดา
	local customer = Customer.new(id)

	local npc = NPCFactory:SpawnCustomer(id)
	customer.Model     = npc
	customer.Humanoid  = npc:FindFirstChildOfClass("Humanoid")
	customer.RootPart  = npc:FindFirstChild("HumanoidRootPart")

	self.Customers[id] = customer

	QueueService:Assign(customer)

	return customer
end

function CustomerService:GetCustomer(id)
	return self.Customers[id]
end

function CustomerService:RemoveCustomer(id)
	self.Customers[id] = nil
end

function CustomerService:Start()
end

return CustomerService