print("[DEBUG] Controller Loaded")

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DebugCommand")

local debugMode = false

-- =========================
-- KEY TOGGLE (\)
-- =========================
UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

	if input.KeyCode == Enum.KeyCode.BackSlash then
		debugMode = not debugMode
		print("[DEBUG] MODE =", debugMode)
	end

end)

-- =========================
-- CHAT COMMAND (SAFE BACKUP)
-- =========================
game.Players.LocalPlayer.Chatted:Connect(function(msg)

	if not debugMode then return end

	msg = msg:lower()

	print("[DEBUG CMD]", msg)

	if msg == "spawn" then
		remote:FireServer("spawn")

	elseif msg == "sendout" then
		remote:FireServer("sendout")

	elseif msg == "clear" then
		remote:FireServer("clear")
	end

end)