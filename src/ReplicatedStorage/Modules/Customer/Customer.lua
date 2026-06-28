local CustomerState = require(script.Parent.CustomerState)

local Customer = {}
Customer.__index = Customer

function Customer.new(id)
	local self = setmetatable({}, Customer)

	self.Id = id
	self.State = CustomerState.Idle
	self.Model = nil
    self.Humanoid = nil
    self.RootPart = nil

    self.Order = nil

    self.Patience = 100
    self.Mood = "Neutral"
    self.Reward = 0

    self.QueueIndex = nil
    self.Seat = nil
    self.Target = nil

	return self
end

return Customer