local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logger = require(ReplicatedStorage.Modules.Core.Logger)

local NPCController = {
	Name = "NPCController"
}

-- =========================
-- MOVE LOCK (กันเดินซ้อน)
-- =========================
local Moving = {}

-- =========================
-- MAIN MOVE FUNCTION
-- =========================
function NPCController:MoveTo(npc, targetPart)

	if not npc or not targetPart then return end
	if Moving[npc] then return end

	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local root = npc:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then return end

	Moving[npc] = true

	task.spawn(function()

		local path = PathfindingService:CreatePath({
			AgentRadius = 2,
			AgentHeight = 5,
			AgentCanJump = false
		})

		local success, err = pcall(function()
			path:ComputeAsync(root.Position, targetPart.Position)
		end)

		if not success or path.Status ~= Enum.PathStatus.Success then
			-- fallback move
			humanoid:MoveTo(targetPart.Position)
			humanoid.MoveToFinished:Wait()
			Moving[npc] = nil
			return
		end

		local waypoints = path:GetWaypoints()

		for _, wp in ipairs(waypoints) do

			if not npc.Parent then
				Moving[npc] = nil
				return
			end

			humanoid:MoveTo(wp.Position)
			local reached = humanoid.MoveToFinished:Wait()

			-- ถ้าตาย/โดนแทรก/หาย ให้หยุด
			if not reached then
				break
			end
		end

		Moving[npc] = nil
	end)
end

return NPCController