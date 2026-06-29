-- OrderService.lua
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local MenuConfig = require(ReplicatedStorage.Config.MenuConfig)
local Logger     = require(ReplicatedStorage.Modules.Core.Logger)

local OrderService = {
	Name   = "OrderService",
	Orders = {},        -- [customerId] = order
	Queue  = {},        -- order ที่รับแล้ว เรียงตามเวลา
}

function OrderService:Init()
	self.Orders = {}
	self.Queue  = {}
end

-- สุ่มเมนูแล้ว assign ให้ลูกค้า (เรียกจาก QueueService)
function OrderService:AssignOrder(customer)

	if not customer then return end

	local items  = MenuConfig.Items
	local picked = items[math.random(1, #items)]

	local order = {
		CustomerId = customer.Id,
		ItemId     = picked.Id,
		ItemName   = picked.Name,
		Price      = picked.Price,
		TipMax     = picked.TipMax,
		PrepTime   = picked.PrepTime,
		Served     = false,
		Taken      = false,
	}

	self.Orders[customer.Id] = order
	customer.Order = order

	Logger:Info("OrderService", string.format(
		"Customer %s ordered %s ($%d)", customer.Id, order.ItemName, order.Price
	))

	-- แจ้ง client แสดง order เหนือหัว NPC
	local remotes = ReplicatedStorage.Remotes
	local showOrder = remotes:FindFirstChild("ShowOrder")
	if showOrder and customer.Model then
		showOrder:FireAllClients(customer.Model, order.ItemName)
	end

	return order
end

-- ผู้เล่นกด E รับ order จาก NPC
function OrderService:TakeOrder(customer)

	if not customer then return false end

	local order = self.Orders[customer.Id]
	if not order or order.Taken then return false end

	order.Taken = true
	table.insert(self.Queue, order)

	Logger:Info("OrderService", string.format(
		"Order taken: %s", order.ItemName
	))

	-- แจ้ง client อัพเดต HUD
	self:_broadcastQueue()

	return true
end

function OrderService:GetOrder(customerId)
	return self.Orders[customerId]
end

function OrderService:ClearOrder(customerId)

	-- เอาออกจาก Queue ด้วย
	for i, o in ipairs(self.Queue) do
		if o.CustomerId == customerId then
			table.remove(self.Queue, i)
			break
		end
	end

	self.Orders[customerId] = nil
	self:_broadcastQueue()
end

-- ส่ง queue ปัจจุบันไปให้ client ทุกคน
function OrderService:_broadcastQueue()
	local remote = ReplicatedStorage.Remotes:FindFirstChild("OrderListUpdated")
	if not remote then return end

	-- ส่งแค่ชื่อ เรียงตามลำดับ
	local list = {}
	for _, o in ipairs(self.Queue) do
		if not o.Served then
			table.insert(list, o.ItemName)
		end
	end

	remote:FireAllClients(list)
end

function OrderService:Start()

	-- รับ TakeOrder จาก client
	local remote = ReplicatedStorage.Remotes:WaitForChild("TakeOrder")

	remote.OnServerEvent:Connect(function(player, npcModel)

		if not npcModel then return end

		-- หา customer จาก model
		local CustomerService = require(ServerScriptService.Services.CustomerService)
		local customer = nil

		for _, c in pairs(CustomerService.Customers) do
			if c.Model == npcModel then
				customer = c
				break
			end
		end

		if customer then
			self:TakeOrder(customer)
		end
	end)
end

return OrderService