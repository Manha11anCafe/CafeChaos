local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logger = require(ReplicatedStorage.Modules.Core.Logger)

local NPCFactory = {}

function NPCFactory:CreateCustomer(customer)
	Logger:Info("NPCFactory", string.format(
		"Preparing NPC for Customer #%d",
		customer.Id
	))

	return nil
end

return NPCFactory