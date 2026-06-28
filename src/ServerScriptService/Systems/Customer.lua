-- Customer.lua
-- Object แทนลูกค้า 1 คน ใช้ Customer.new(id) เพื่อสร้าง
local CustomerState = require(game:GetService("ServerScriptService").Systems.CustomerState)

local Customer = {}
Customer.__index = Customer

function Customer.new(id)
	local self = setmetatable({}, Customer)

	self.Id         = id
	self.State      = CustomerState.Spawning  -- state เริ่มต้น
	self.Model      = nil
	self.Humanoid   = nil
	self.RootPart   = nil

	self.Order      = nil

	self.Patience   = 100
	self.Mood       = "Neutral"
	self.Reward     = 0

	self.QueueIndex = nil
	self.Seat       = nil
	self.Target     = nil

	return self
end

function Customer:SetState(newState)
	self.State = newState
end

return Customer