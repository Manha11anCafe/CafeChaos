local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NPCFactory = require(script.Parent.Parent.Systems.NPCFactory)
local Logger = require(ReplicatedStorage.Modules.Core.Logger)
local Customer = require(ReplicatedStorage.Modules.Customer.Customer)

local CustomerService = {
	Name = "CustomerService"
}

CustomerService.Customers = {}
CustomerService.NextCustomerId = 1

function CustomerService:Init()
	Logger:Info(self.Name, "Init")
end

function CustomerService:Start()
	Logger:Info(self.Name, "Start")

	local customer = Customer.new(self.NextCustomerId)

	self.Customers[customer.Id] = customer
	self.NextCustomerId += 1

	NPCFactory:CreateCustomer(customer)

	Logger:Info(
		self.Name,
		string.format("Created Customer #%d", customer.Id)
	)
end

return CustomerService