-- PatienceSystem.lua
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Logger = require(ReplicatedStorage.Modules.Core.Logger)
local GameConfig = require(ReplicatedStorage.Config.GameConfig)

local PatienceSystem = {
	Name = "PatienceSystem"
}

-- เก็บ thread ของแต่ละ customer กัน leak
PatienceSystem._threads = {}

function PatienceSystem:Init()
	self._threads = {}
end

function PatienceSystem:Start(customer)

	if not customer then return end
	if self._threads[customer.Id] then return end -- กัน start ซ้ำ

	local maxPatience = GameConfig.Customer.MaxPatience
	local interval    = 1 -- ลดทุก 1 วินาที

	local thread = task.spawn(function()

		while customer.Patience > 0 do
			task.wait(interval)

			if not customer.Model or not customer.Model.Parent then
				break -- NPC ถูก destroy แล้ว
			end

			customer.Patience = math.max(0, customer.Patience - interval)

			-- แจ้ง client อัพเดต patience bar
			local remote = ReplicatedStorage.Remotes:FindFirstChild("UpdatePatience")
			if remote and customer.Model then
				remote:FireAllClients(customer.Model, customer.Patience, maxPatience)
			end

			if customer.Patience <= 0 then
				Logger:Info("PatienceSystem", string.format(
					"Customer %s ran out of patience", customer.Id
				))

				-- require ตอนใช้งาน กัน circular
				local QueueService = require(ServerScriptService.Services.QueueService)
				local CustomerService = require(ServerScriptService.Services.CustomerService)
				local OrderService = require(ServerScriptService.Services.OrderService)

				OrderService:ClearOrder(customer.Id)
				CustomerService:RemoveCustomer(customer.Id)
				QueueService:SendOut(customer)

				break
			end
		end

		self._threads[customer.Id] = nil
	end)

	self._threads[customer.Id] = thread
end

function PatienceSystem:Stop(customerId)
	local thread = self._threads[customerId]
	if thread then
		task.cancel(thread)
		self._threads[customerId] = nil
	end
end

return PatienceSystem