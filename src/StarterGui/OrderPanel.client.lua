-- OrderPanel.client.lua
-- กด E ที่ NPC เพื่อเปิด / กด E หรือ Escape เพื่อปิด

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera    = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

local INTERACT_DIST = 10  -- studs

-- ============================
-- GUI
-- ============================
local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "OrderPanel"
screenGui.ResetOnSpawn  = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent        = playerGui

-- พื้นหลัง dim
local overlay = Instance.new("Frame")
overlay.Size                  = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3      = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.6
overlay.BorderSizePixel       = 0
overlay.Visible               = false
overlay.Parent                = screenGui

-- panel กลางจอ
local panel = Instance.new("Frame")
panel.Size             = UDim2.new(0, 320, 0, 400)
panel.Position         = UDim2.new(0.5, -160, 0.5, -200)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel  = 0
panel.Visible          = false
panel.Parent           = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

-- header
local header = Instance.new("Frame")
header.Size            = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
header.BackgroundTransparency = 0
header.BorderSizePixel = 0
header.Parent          = panel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size             = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text             = "ORDER"
titleLabel.TextColor3       = Color3.fromRGB(220, 220, 220)
titleLabel.TextSize         = 16
titleLabel.Font             = Enum.Font.GothamBold
titleLabel.TextXAlignment   = Enum.TextXAlignment.Center
titleLabel.Parent           = header

-- hint
local hint = Instance.new("TextLabel")
hint.Size             = UDim2.new(1, 0, 0, 20)
hint.Position         = UDim2.new(0, 0, 1, -28)
hint.BackgroundTransparency = 1
hint.Text             = "E / Escape to close"
hint.TextColor3       = Color3.fromRGB(100, 100, 100)
hint.TextSize         = 12
hint.Font             = Enum.Font.Code
hint.TextXAlignment   = Enum.TextXAlignment.Center
hint.Parent           = panel

-- item display
local itemName = Instance.new("TextLabel")
itemName.Size             = UDim2.new(1, -32, 0, 60)
itemName.Position         = UDim2.new(0, 16, 0, 64)
itemName.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
itemName.BackgroundTransparency = 0
itemName.BorderSizePixel  = 0
itemName.Text             = ""
itemName.TextColor3       = Color3.fromRGB(240, 240, 240)
itemName.TextSize         = 26
itemName.Font             = Enum.Font.GothamBold
itemName.TextXAlignment   = Enum.TextXAlignment.Center
itemName.Parent           = panel

local itemCorner = Instance.new("UICorner")
itemCorner.CornerRadius = UDim.new(0, 6)
itemCorner.Parent = itemName

-- patience bar bg
local barBg = Instance.new("Frame")
barBg.Size             = UDim2.new(1, -32, 0, 8)
barBg.Position         = UDim2.new(0, 16, 0, 140)
barBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
barBg.BorderSizePixel  = 0
barBg.Parent           = panel

local barBgCorner = Instance.new("UICorner")
barBgCorner.CornerRadius = UDim.new(1, 0)
barBgCorner.Parent = barBg

local barFill = Instance.new("Frame")
barFill.Size             = UDim2.new(1, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
barFill.BorderSizePixel  = 0
barFill.Parent           = barBg

local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(1, 0)
barFillCorner.Parent = barFill

-- take button
local takeBtn = Instance.new("TextButton")
takeBtn.Size             = UDim2.new(1, -32, 0, 48)
takeBtn.Position         = UDim2.new(0, 16, 0, 168)
takeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
takeBtn.BorderSizePixel  = 0
takeBtn.Text             = "Take Order  [E]"
takeBtn.TextColor3       = Color3.fromRGB(220, 220, 220)
takeBtn.TextSize         = 14
takeBtn.Font             = Enum.Font.GothamBold
takeBtn.Parent           = panel

local takeBtnCorner = Instance.new("UICorner")
takeBtnCorner.CornerRadius = UDim.new(0, 6)
takeBtnCorner.Parent = takeBtn

-- ============================
-- State
-- ============================
local isOpen      = false
local targetNPC   = nil
local currentPat  = 100
local maxPat      = 100

-- ============================
-- Helpers
-- ============================
local function getNearestNPC()
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local folder = workspace:FindFirstChild("Customers")
	if not folder then return nil end

	local nearest, dist = nil, INTERACT_DIST

	for _, npc in ipairs(folder:GetChildren()) do
		local npcRoot = npc:FindFirstChild("HumanoidRootPart")
		if npcRoot then
			local d = (root.Position - npcRoot.Position).Magnitude
			if d < dist then
				nearest = npc
				dist    = d
			end
		end
	end

	return nearest
end

local function updateBar(patience, maxPatience)
	local pct = math.clamp(patience / maxPatience, 0, 1)
	barFill.Size = UDim2.new(pct, 0, 1, 0)

	if pct > 0.5 then
		barFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
	elseif pct > 0.25 then
		barFill.BackgroundColor3 = Color3.fromRGB(220, 180, 50)
	else
		barFill.BackgroundColor3 = Color3.fromRGB(210, 70, 70)
	end
end

local function openPanel(npc, orderName, patience, maxPatience)
	targetNPC  = npc
	currentPat = patience or 100
	maxPat     = maxPatience or 100

	itemName.Text = orderName or "?"
	updateBar(currentPat, maxPat)

	overlay.Visible = true
	panel.Visible   = true
	isOpen          = true
end

local function closePanel()
	overlay.Visible = false
	panel.Visible   = false
	isOpen          = false
	targetNPC       = nil
end

local function sendTakeOrder()
	if not targetNPC then return end
	local remote = ReplicatedStorage.Remotes:FindFirstChild("TakeOrder")
	if remote then
		remote:FireServer(targetNPC)
	end
	closePanel()
end

-- ============================
-- Input
-- ============================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.E then
		if isOpen then
			sendTakeOrder()
		else
			local npc = getNearestNPC()
			if npc then
				-- หา order name จาก BillboardGui ที่ติดอยู่กับ NPC
				local billboard = npc:FindFirstChild("OrderBillboard")
				local label     = billboard and billboard:FindFirstChild("OrderLabel")
				local orderName = label and label.Text or "?"
				openPanel(npc, orderName, 100, 100)
			end
		end
	end

	if isOpen and input.KeyCode == Enum.KeyCode.Escape then
		closePanel()
	end
end)

takeBtn.MouseButton1Click:Connect(sendTakeOrder)

-- ============================
-- Remotes
-- ============================
local remotes = ReplicatedStorage:WaitForChild("Remotes")

-- อัพเดต patience bar ขณะ panel เปิดอยู่
remotes:WaitForChild("UpdatePatience").OnClientEvent:Connect(function(npcModel, patience, maxPatience)
	if isOpen and targetNPC == npcModel then
		currentPat = patience
		maxPat     = maxPatience
		updateBar(patience, maxPatience)
	end
end)