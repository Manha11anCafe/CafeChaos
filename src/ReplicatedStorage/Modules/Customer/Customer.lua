local CustomerState = require(script.Parent.CustomerState)

local Customer = {}
Customer.__index = Customer

function Customer.new(id)
	local self = setmetatable({}, Customer)

	self.Id = id
	self.State = CustomerState.Idle
	self.Order = nil
	self.Patience = 100
	self.Mood = "Neutral"
	self.Reward = 0

	return self
end

return Customer