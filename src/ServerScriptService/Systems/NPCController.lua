local PathfindingService = game:GetService("PathfindingService")

local NPCController = {}

local ActiveMoves = {}

local function GetHumanoid(model)
	return model:FindFirstChildOfClass("Humanoid")
end

local function GetRoot(model)
	return model:FindFirstChild("HumanoidRootPart")
end

function NPCController:CancelMove(model)

	local move = ActiveMoves[model]

	if move then
		move.Cancelled = true
	end

end

function NPCController:MoveTo(model, destination)

	if not model then
		return
	end

	local humanoid = GetHumanoid(model)
	local root = GetRoot(model)

	if not humanoid or not root then
		return
	end

	self:CancelMove(model)

	local moveData = {
		Cancelled = false
	}

	ActiveMoves[model] = moveData

	local path = PathfindingService:CreatePath()

	path:ComputeAsync(
		root.Position,
		destination.Position
	)

	if path.Status ~= Enum.PathStatus.Success then
		return
	end

	local waypoints = path:GetWaypoints()
    	for _, waypoint in ipairs(waypoints) do

		if moveData.Cancelled then
			return false
		end

		if waypoint.Action == Enum.PathWaypointAction.Jump then
			humanoid.Jump = true
		end

		humanoid:MoveTo(waypoint.Position)

		local reached = humanoid.MoveToFinished:Wait()

		if moveData.Cancelled then
			return false
		end

		if not reached then
			return false
		end
	end

	ActiveMoves[model] = nil

	return true
end

function NPCController:IsMoving(model)
	return ActiveMoves[model] ~= nil
end

return NPCController