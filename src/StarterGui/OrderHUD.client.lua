-- OrderHUD.client.lua
-- แสดง order แรกสุดที่ยังค้างอยู่ที่ขอบจอด้านขวา

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================
-- GUI
-- ============================
local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "OrderHUD"
screenGui.ResetOnSpawn  = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent        = playerGui

-- container ขวาบน
local container = Instance.new("Frame")
container.Size             = UDim2.new(0, 180, 0, 80)
container.Position         = UDim2.new(1, -196, 0, 16)
container.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
container.BackgroundTransparency = 0.3
container.BorderSizePixel  = 0
container.Visible          = false
container.Parent           = screenGui

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 6)
containerCorner.Parent = container

-- label "NEXT"
local nextLabel = Instance.new("TextLabel")
nextLabel.Size             = UDim2.new(1, 0, 0, 24)
nextLabel.Position         = UDim2.new(0, 0, 0, 8)
nextLabel.BackgroundTransparency = 1
nextLabel.Text             = "NEXT ORDER"
nextLabel.TextColor3       = Color3.fromRGB(140, 140, 140)
nextLabel.TextSize         = 11
nextLabel.Font             = Enum.Font.GothamBold
nextLabel.TextXAlignment   = Enum.TextXAlignment.Center
nextLabel.Parent           = container

-- ชื่อ order
local orderLabel = Instance.new("TextLabel")
orderLabel.Size             = UDim2.new(1, -16, 0, 36)
orderLabel.Position         = UDim2.new(0, 8, 0, 32)
orderLabel.BackgroundTransparency = 1
orderLabel.Text             = ""
orderLabel.TextColor3       = Color3.fromRGB(230, 230, 230)
orderLabel.TextSize         = 22
orderLabel.Font             = Enum.Font.GothamBold
orderLabel.TextXAlignment   = Enum.TextXAlignment.Center
orderLabel.Parent           = container

-- ============================
-- Update
-- ============================
local function updateHUD(list)
	if not list or #list == 0 then
		container.Visible = false
		return
	end

	container.Visible = true
	orderLabel.Text   = list[1]  -- แสดงแค่ order แรก
end

-- ============================
-- Remote
-- ============================
local remotes = ReplicatedStorage:WaitForChild("Remotes")

remotes:WaitForChild("OrderListUpdated").OnClientEvent:Connect(function(list)
	updateHUD(list)
end)