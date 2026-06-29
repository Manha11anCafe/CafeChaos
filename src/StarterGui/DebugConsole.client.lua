-- DebugConsole.client.lua
-- \ to toggle

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================
-- Commands
-- ============================
local COMMANDS = {
	sp   = { desc = "Spawn NPC",           action = "spawn"   },
	so   = { desc = "Send out first NPC",  action = "sendout" },
	cl   = { desc = "Clear all NPCs",      action = "clear"   },
	help = { desc = "Show all commands",   action = "help"    },
}

-- ============================
-- Screen GUI
-- ============================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DebugConsole"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Input bar — top of screen
local inputBar = Instance.new("Frame")
inputBar.Name = "InputBar"
inputBar.Size = UDim2.new(1, 0, 0, 32)
inputBar.Position = UDim2.new(0, 0, 0, 0)
inputBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
inputBar.BackgroundTransparency = 0.45
inputBar.BorderSizePixel = 0
inputBar.Visible = false
inputBar.Parent = screenGui

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -16, 1, -8)
inputBox.Position = UDim2.new(0, 8, 0, 4)
inputBox.BackgroundTransparency = 1
inputBox.Text = ""
inputBox.PlaceholderText = "> type command  (help for list)"
inputBox.TextColor3 = Color3.fromRGB(230, 230, 230)
inputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
inputBox.TextSize = 14
inputBox.Font = Enum.Font.Code
inputBox.TextXAlignment = Enum.TextXAlignment.Left
inputBox.ClearTextOnFocus = true
inputBox.Parent = inputBar

-- Log panel — below input bar
local logFrame = Instance.new("Frame")
logFrame.Name = "LogFrame"
logFrame.Size = UDim2.new(1, 0, 0, 160)
logFrame.Position = UDim2.new(0, 0, 0, 32)
logFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
logFrame.BackgroundTransparency = 0.65
logFrame.BorderSizePixel = 0
logFrame.Visible = false
logFrame.Parent = screenGui

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -8, 1, -8)
scroll.Position = UDim2.new(0, 4, 0, 4)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = logFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 1)
layout.Parent = scroll

-- ============================
-- Log helpers
-- ============================
local function log(text, color)
	color = color or Color3.fromRGB(200, 200, 200)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 17)
	label.BackgroundTransparency = 1
	label.Text = "  " .. text
	label.TextColor3 = color
	label.TextSize = 13
	label.Font = Enum.Font.Code
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = scroll

	task.spawn(function()
		task.wait()
		scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
	end)
end

local function logInput(text)
	log("> " .. text, Color3.fromRGB(255, 255, 255))
end

local function logOk(text)
	log(text, Color3.fromRGB(120, 210, 120))
end

local function logErr(text)
	log(text, Color3.fromRGB(220, 100, 100))
end

local function logInfo(text)
	log(text, Color3.fromRGB(160, 160, 160))
end

-- ============================
-- Help
-- ============================
local function showHelp()
	logInfo("----------------------------")
	for cmd, data in pairs(COMMANDS) do
		logInfo(string.format("  %-6s  %s", cmd, data.desc))
	end
	logInfo("----------------------------")
end

-- ============================
-- Execute
-- ============================
local function execute(input)

	input = input:lower():match("^%s*(.-)%s*$")
	if input == "" then return end

	logInput(input)

	local cmd = COMMANDS[input]

	if not cmd then
		logErr("unknown command '" .. input .. "'")
		return
	end

	if cmd.action == "help" then
		showHelp()
		return
	end

	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local remote  = remotes and remotes:FindFirstChild("DebugCommand")

	if not remote then
		logErr("DebugCommand remote not found")
		return
	end

	remote:FireServer(cmd.action)
	logOk(cmd.desc)
end

-- ============================
-- Toggle
-- ============================
local isOpen = false

local function open()
	isOpen = true
	inputBar.Visible = true
	logFrame.Visible = true
	inputBox:CaptureFocus()
end

local function close()
	isOpen = false
	inputBar.Visible = false
	logFrame.Visible = false
	inputBox:ReleaseFocus()
end

-- ============================
-- Input events
-- ============================
UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if input.KeyCode == Enum.KeyCode.BackSlash then
		if isOpen then close() else open() end
		return
	end

	if isOpen and input.KeyCode == Enum.KeyCode.Escape then
		close()
	end
end)

inputBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local text = inputBox.Text
		inputBox.Text = ""
		execute(text)
		inputBox:CaptureFocus()
	end
end)