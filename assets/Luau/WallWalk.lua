return [[
script = Instance.new("LocalScript")

function _ClickToMoveDisplay()
	local ClickToMoveDisplay = {}

	local FAILURE_ANIMATION_ID = "rbxassetid://2874840706"

	local TrailDotIcon = "rbxasset://textures/ui/traildot.png"
	local EndWaypointIcon = "rbxasset://textures/ui/waypoint.png"

	local WaypointsAlwaysOnTop = false

	local WAYPOINT_INCLUDE_FACTOR = 2
	local LAST_DOT_DISTANCE = 3

	local WAYPOINT_BILLBOARD_SIZE = UDim2.new(0, 1.68 * 25, 0, 2 * 25)

	local ENDWAYPOINT_SIZE_OFFSET_MIN = Vector2.new(0, 0.5)
	local ENDWAYPOINT_SIZE_OFFSET_MAX = Vector2.new(0, 1)

	local FAIL_WAYPOINT_SIZE_OFFSET_CENTER = Vector2.new(0, 0.5)
	local FAIL_WAYPOINT_SIZE_OFFSET_LEFT = Vector2.new(0.1, 0.5)
	local FAIL_WAYPOINT_SIZE_OFFSET_RIGHT = Vector2.new(-0.1, 0.5)

	local FAILURE_TWEEN_LENGTH = 0.125
	local FAILURE_TWEEN_COUNT = 4

	local TWEEN_WAYPOINT_THRESHOLD = 5

	local TRAIL_DOT_PARENT_NAME = "ClickToMoveDisplay"

	local TrailDotSize = Vector2.new(1.5, 1.5)

	local TRAIL_DOT_MIN_SCALE = 1
	local TRAIL_DOT_MIN_DISTANCE = 10
	local TRAIL_DOT_MAX_SCALE = 2.5
	local TRAIL_DOT_MAX_DISTANCE = 100

	local PlayersService = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local Workspace = game:GetService("Workspace")

	local LocalPlayer = PlayersService.LocalPlayer

	local function CreateWaypointTemplates()
		local TrailDotTemplate = Instance.new("Part")
		TrailDotTemplate.Size = Vector3.new(1, 1, 1)
		TrailDotTemplate.Anchored = true
		TrailDotTemplate.CanCollide = false
		TrailDotTemplate.Name = "TrailDot"
		TrailDotTemplate.Transparency = 1
		local TrailDotImage = Instance.new("ImageHandleAdornment")
		TrailDotImage.Name = "TrailDotImage"
		TrailDotImage.Size = TrailDotSize
		TrailDotImage.SizeRelativeOffset = Vector3.new(0, 0, -0.1)
		TrailDotImage.AlwaysOnTop = WaypointsAlwaysOnTop
		TrailDotImage.Image = TrailDotIcon
		TrailDotImage.Adornee = TrailDotTemplate
		TrailDotImage.Parent = TrailDotTemplate

		local EndWaypointTemplate = Instance.new("Part")
		EndWaypointTemplate.Size = Vector3.new(2, 2, 2)
		EndWaypointTemplate.Anchored = true
		EndWaypointTemplate.CanCollide = false
		EndWaypointTemplate.Name = "EndWaypoint"
		EndWaypointTemplate.Transparency = 1
		local EndWaypointImage = Instance.new("ImageHandleAdornment")
		EndWaypointImage.Name = "TrailDotImage"
		EndWaypointImage.Size = TrailDotSize
		EndWaypointImage.SizeRelativeOffset = Vector3.new(0, 0, -0.1)
		EndWaypointImage.AlwaysOnTop = WaypointsAlwaysOnTop
		EndWaypointImage.Image = TrailDotIcon
		EndWaypointImage.Adornee = EndWaypointTemplate
		EndWaypointImage.Parent = EndWaypointTemplate
		local EndWaypointBillboard = Instance.new("BillboardGui")
		EndWaypointBillboard.Name = "EndWaypointBillboard"
		EndWaypointBillboard.Size = WAYPOINT_BILLBOARD_SIZE
		EndWaypointBillboard.LightInfluence = 0
		EndWaypointBillboard.SizeOffset = ENDWAYPOINT_SIZE_OFFSET_MIN
		EndWaypointBillboard.AlwaysOnTop = true
		EndWaypointBillboard.Adornee = EndWaypointTemplate
		EndWaypointBillboard.Parent = EndWaypointTemplate
		local EndWaypointImageLabel = Instance.new("ImageLabel")
		EndWaypointImageLabel.Image = EndWaypointIcon
		EndWaypointImageLabel.BackgroundTransparency = 1
		EndWaypointImageLabel.Size = UDim2.new(1, 0, 1, 0)
		EndWaypointImageLabel.Parent = EndWaypointBillboard


		local FailureWaypointTemplate = Instance.new("Part")
		FailureWaypointTemplate.Size = Vector3.new(2, 2, 2)
		FailureWaypointTemplate.Anchored = true
		FailureWaypointTemplate.CanCollide = false
		FailureWaypointTemplate.Name = "FailureWaypoint"
		FailureWaypointTemplate.Transparency = 1
		local FailureWaypointImage = Instance.new("ImageHandleAdornment")
		FailureWaypointImage.Name = "TrailDotImage"
		FailureWaypointImage.Size = TrailDotSize
		FailureWaypointImage.SizeRelativeOffset = Vector3.new(0, 0, -0.1)
		FailureWaypointImage.AlwaysOnTop = WaypointsAlwaysOnTop
		FailureWaypointImage.Image = TrailDotIcon
		FailureWaypointImage.Adornee = FailureWaypointTemplate
		FailureWaypointImage.Parent = FailureWaypointTemplate
		local FailureWaypointBillboard = Instance.new("BillboardGui")
		FailureWaypointBillboard.Name = "FailureWaypointBillboard"
		FailureWaypointBillboard.Size = WAYPOINT_BILLBOARD_SIZE
		FailureWaypointBillboard.LightInfluence = 0
		FailureWaypointBillboard.SizeOffset = FAIL_WAYPOINT_SIZE_OFFSET_CENTER
		FailureWaypointBillboard.AlwaysOnTop = true
		FailureWaypointBillboard.Adornee = FailureWaypointTemplate
		FailureWaypointBillboard.Parent = FailureWaypointTemplate
		local FailureWaypointFrame = Instance.new("Frame")
		FailureWaypointFrame.BackgroundTransparency = 1
		FailureWaypointFrame.Size = UDim2.new(0, 0, 0, 0)
		FailureWaypointFrame.Position = UDim2.new(0.5, 0, 1, 0)
		FailureWaypointFrame.Parent = FailureWaypointBillboard
		local FailureWaypointImageLabel = Instance.new("ImageLabel")
		FailureWaypointImageLabel.Image = EndWaypointIcon
		FailureWaypointImageLabel.BackgroundTransparency = 1
		FailureWaypointImageLabel.Position = UDim2.new(
			0, -WAYPOINT_BILLBOARD_SIZE.X.Offset/2, 0, -WAYPOINT_BILLBOARD_SIZE.Y.Offset
		)
		FailureWaypointImageLabel.Size = WAYPOINT_BILLBOARD_SIZE
		FailureWaypointImageLabel.Parent = FailureWaypointFrame

		return TrailDotTemplate, EndWaypointTemplate, FailureWaypointTemplate
	end

	local TrailDotTemplate, EndWaypointTemplate, FailureWaypointTemplate = CreateWaypointTemplates()

	local function getTrailDotParent()
		local camera = Workspace.CurrentCamera
		local trailParent = camera:FindFirstChild(TRAIL_DOT_PARENT_NAME)
		if not trailParent then
			trailParent = Instance.new("Model")
			trailParent.Name = TRAIL_DOT_PARENT_NAME
			trailParent.Parent = camera
		end
		return trailParent
	end

	local function placePathWaypoint(waypointModel, position)
		local ray = Ray.new(position + Vector3.new(0, 2.5, 0), Vector3.new(0, -10, 0))
		local hitPart, hitPoint, hitNormal = Workspace:FindPartOnRayWithIgnoreList(
			ray,
			{ Workspace.CurrentCamera, LocalPlayer.Character }
		)
		if hitPart then
			waypointModel.CFrame = CFrame.new(hitPoint, hitPoint + hitNormal)
			waypointModel.Parent = getTrailDotParent()
		end
	end

	local TrailDot = {}
	TrailDot.__index = TrailDot

	function TrailDot:Destroy()
		self.DisplayModel:Destroy()
	end

	function TrailDot:NewDisplayModel(position)
		local newDisplayModel = TrailDotTemplate:Clone()
		placePathWaypoint(newDisplayModel, position)
		return newDisplayModel
	end

	function TrailDot.new(position, closestWaypoint)
		local self = setmetatable({}, TrailDot)

		self.DisplayModel = self:NewDisplayModel(position)
		self.ClosestWayPoint = closestWaypoint

		return self
	end

	local EndWaypoint = {}
	EndWaypoint.__index = EndWaypoint

	function EndWaypoint:Destroy()
		self.Destroyed = true
		self.Tween:Cancel()
		self.DisplayModel:Destroy()
	end

	function EndWaypoint:NewDisplayModel(position)
		local newDisplayModel = EndWaypointTemplate:Clone()
		placePathWaypoint(newDisplayModel, position)
		return newDisplayModel
	end

	function EndWaypoint:CreateTween()
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true)
		local tween = TweenService:Create(
			self.DisplayModel.EndWaypointBillboard,
			tweenInfo,
			{ SizeOffset = ENDWAYPOINT_SIZE_OFFSET_MAX }
		)
		tween:Play()
		return tween
	end

	function EndWaypoint:TweenInFrom(originalPosition)
		local currentPositon = self.DisplayModel.Position
		local studsOffset = originalPosition - currentPositon
		self.DisplayModel.EndWaypointBillboard.StudsOffset = Vector3.new(0, studsOffset.Y, 0)
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local tween = TweenService:Create(
			self.DisplayModel.EndWaypointBillboard,
			tweenInfo,
			{ StudsOffset = Vector3.new(0, 0, 0) }
		)
		tween:Play()
		return tween
	end

	function EndWaypoint.new(position, closestWaypoint, originalPosition)
		local self = setmetatable({}, EndWaypoint)

		self.DisplayModel = self:NewDisplayModel(position)
		self.Destroyed = false
		if originalPosition and (originalPosition - position).magnitude > TWEEN_WAYPOINT_THRESHOLD then
			self.Tween = self:TweenInFrom(originalPosition)
			coroutine.wrap(function()
				self.Tween.Completed:Wait()
				if not self.Destroyed then
					self.Tween = self:CreateTween()
				end
			end)()
		else
			self.Tween = self:CreateTween()
		end
		self.ClosestWayPoint = closestWaypoint

		return self
	end

	local FailureWaypoint = {}
	FailureWaypoint.__index = FailureWaypoint

	function FailureWaypoint:Hide()
		self.DisplayModel.Parent = nil
	end

	function FailureWaypoint:Destroy()
		self.DisplayModel:Destroy()
	end

	function FailureWaypoint:NewDisplayModel(position)
		local newDisplayModel = FailureWaypointTemplate:Clone()
		placePathWaypoint(newDisplayModel, position)
		local ray = Ray.new(position + Vector3.new(0, 2.5, 0), Vector3.new(0, -10, 0))
		local hitPart, hitPoint, hitNormal = Workspace:FindPartOnRayWithIgnoreList(
			ray, { Workspace.CurrentCamera, LocalPlayer.Character }
		)
		if hitPart then
			newDisplayModel.CFrame = CFrame.new(hitPoint, hitPoint + hitNormal)
			newDisplayModel.Parent = getTrailDotParent()
		end
		return newDisplayModel
	end

	function FailureWaypoint:RunFailureTween()
		wait(FAILURE_TWEEN_LENGTH)
		local tweenInfo = TweenInfo.new(FAILURE_TWEEN_LENGTH/2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local tweenLeft = TweenService:Create(self.DisplayModel.FailureWaypointBillboard, tweenInfo,
			{ SizeOffset = FAIL_WAYPOINT_SIZE_OFFSET_LEFT })
		tweenLeft:Play()

		local tweenLeftRoation = TweenService:Create(self.DisplayModel.FailureWaypointBillboard.Frame, tweenInfo,
			{ Rotation = 10 })
		tweenLeftRoation:Play()

		tweenLeft.Completed:wait()

		tweenInfo = TweenInfo.new(FAILURE_TWEEN_LENGTH, Enum.EasingStyle.Sine, Enum.EasingDirection.Out,
			FAILURE_TWEEN_COUNT - 1, true)
		local tweenSideToSide = TweenService:Create(self.DisplayModel.FailureWaypointBillboard, tweenInfo,
			{ SizeOffset = FAIL_WAYPOINT_SIZE_OFFSET_RIGHT})
		tweenSideToSide:Play()

		tweenInfo = TweenInfo.new(FAILURE_TWEEN_LENGTH, Enum.EasingStyle.Sine, Enum.EasingDirection.Out,
			FAILURE_TWEEN_COUNT - 1, true)
		local tweenFlash = TweenService:Create(self.DisplayModel.FailureWaypointBillboard.Frame.ImageLabel, tweenInfo,
			{ ImageColor3 = Color3.new(0.75, 0.75, 0.75)})
		tweenFlash:Play()

		local tweenRotate = TweenService:Create(self.DisplayModel.FailureWaypointBillboard.Frame, tweenInfo,
			{ Rotation = -10 })
		tweenRotate:Play()

		tweenSideToSide.Completed:wait()

		tweenInfo = TweenInfo.new(FAILURE_TWEEN_LENGTH/2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local tweenCenter = TweenService:Create(self.DisplayModel.FailureWaypointBillboard, tweenInfo,
			{ SizeOffset = FAIL_WAYPOINT_SIZE_OFFSET_CENTER })
		tweenCenter:Play()

		local tweenRoation = TweenService:Create(self.DisplayModel.FailureWaypointBillboard.Frame, tweenInfo,
			{ Rotation = 0 })
		tweenRoation:Play()

		tweenCenter.Completed:wait()

		wait(FAILURE_TWEEN_LENGTH)
	end

	function FailureWaypoint.new(position)
		local self = setmetatable({}, FailureWaypoint)

		self.DisplayModel = self:NewDisplayModel(position)

		return self
	end

	local failureAnimation = Instance.new("Animation")
	failureAnimation.AnimationId = FAILURE_ANIMATION_ID

	local lastHumanoid = nil
	local lastFailureAnimationTrack = nil

	local function getFailureAnimationTrack(myHumanoid)
		if myHumanoid == lastHumanoid then
			return lastFailureAnimationTrack
		end
		lastFailureAnimationTrack = myHumanoid:LoadAnimation(failureAnimation)
		lastFailureAnimationTrack.Priority = Enum.AnimationPriority.Action
		lastFailureAnimationTrack.Looped = false
		return lastFailureAnimationTrack
	end

	local function findPlayerHumanoid()
		local character = LocalPlayer.Character
		if character then
			return character:FindFirstChildOfClass("Humanoid")
		end
	end

	local function createTrailDots(wayPoints, originalEndWaypoint)
		local newTrailDots = {}
		local count = 1
		for i = 1, #wayPoints - 1 do
			local closeToEnd = (wayPoints[i].Position - wayPoints[#wayPoints].Position).magnitude < LAST_DOT_DISTANCE
			local includeWaypoint = i % WAYPOINT_INCLUDE_FACTOR == 0 and not closeToEnd
			if includeWaypoint then
				local trailDot = TrailDot.new(wayPoints[i].Position, i)
				newTrailDots[count] = trailDot
				count = count + 1
			end
		end

		local newEndWaypoint = EndWaypoint.new(wayPoints[#wayPoints].Position, #wayPoints, originalEndWaypoint)
		table.insert(newTrailDots, newEndWaypoint)

		local reversedTrailDots = {}
		count = 1
		for i = #newTrailDots, 1, -1 do
			reversedTrailDots[count] = newTrailDots[i]
			count = count + 1
		end
		return reversedTrailDots
	end

	local function getTrailDotScale(distanceToCamera, defaultSize)
		local rangeLength = TRAIL_DOT_MAX_DISTANCE - TRAIL_DOT_MIN_DISTANCE
		local inRangePoint = math.clamp(distanceToCamera - TRAIL_DOT_MIN_DISTANCE, 0, rangeLength)/rangeLength
		local scale = TRAIL_DOT_MIN_SCALE + (TRAIL_DOT_MAX_SCALE - TRAIL_DOT_MIN_SCALE)*inRangePoint
		return defaultSize * scale
	end

	local createPathCount = 0
	function ClickToMoveDisplay.CreatePathDisplay(wayPoints, originalEndWaypoint)
		createPathCount = createPathCount + 1
		local trailDots = createTrailDots(wayPoints, originalEndWaypoint)

		local function removePathBeforePoint(wayPointNumber)
			for i = #trailDots, 1, -1 do
				local trailDot = trailDots[i]
				if trailDot.ClosestWayPoint <= wayPointNumber then
					trailDot:Destroy()
					trailDots[i] = nil
				else
					break
				end
			end
		end

		local reiszeTrailDotsUpdateName = "ClickToMoveResizeTrail" ..createPathCount
		local function resizeTrailDots()
			if #trailDots == 0 then
				RunService:UnbindFromRenderStep(reiszeTrailDotsUpdateName)
				return
			end
			local cameraPos = Workspace.CurrentCamera.CFrame.p
			for i = 1, #trailDots do
				local trailDotImage = trailDots[i].DisplayModel:FindFirstChild("TrailDotImage")
				if trailDotImage then
					local distanceToCamera = (trailDots[i].DisplayModel.Position - cameraPos).magnitude
					trailDotImage.Size = getTrailDotScale(distanceToCamera, TrailDotSize)
				end
			end
		end
		RunService:BindToRenderStep(reiszeTrailDotsUpdateName, Enum.RenderPriority.Camera.Value - 1, resizeTrailDots)

		local function removePath()
			removePathBeforePoint(#wayPoints)
		end

		return removePath, removePathBeforePoint
	end

	local lastFailureWaypoint = nil
	function ClickToMoveDisplay.DisplayFailureWaypoint(position)
		if lastFailureWaypoint then
			lastFailureWaypoint:Hide()
		end
		local failureWaypoint = FailureWaypoint.new(position)
		lastFailureWaypoint = failureWaypoint
		coroutine.wrap(function()
			failureWaypoint:RunFailureTween()
			failureWaypoint:Destroy()
			failureWaypoint = nil
		end)()
	end

	function ClickToMoveDisplay.CreateEndWaypoint(position)
		return EndWaypoint.new(position)
	end

	function ClickToMoveDisplay.PlayFailureAnimation()
		local myHumanoid = findPlayerHumanoid()
		if myHumanoid then
			local animationTrack = getFailureAnimationTrack(myHumanoid)
			animationTrack:Play()
		end
	end

	function ClickToMoveDisplay.CancelFailureAnimation()
		if lastFailureAnimationTrack ~= nil and lastFailureAnimationTrack.IsPlaying then
			lastFailureAnimationTrack:Stop()
		end
	end

	function ClickToMoveDisplay.SetWaypointTexture(texture)
		TrailDotIcon = texture
		TrailDotTemplate, EndWaypointTemplate, FailureWaypointTemplate = CreateWaypointTemplates()
	end

	function ClickToMoveDisplay.GetWaypointTexture()
		return TrailDotIcon
	end

	function ClickToMoveDisplay.SetWaypointRadius(radius)
		TrailDotSize = Vector2.new(radius, radius)
		TrailDotTemplate, EndWaypointTemplate, FailureWaypointTemplate = CreateWaypointTemplates()
	end

	function ClickToMoveDisplay.GetWaypointRadius()
		return TrailDotSize.X
	end

	function ClickToMoveDisplay.SetEndWaypointTexture(texture)
		EndWaypointIcon = texture
		TrailDotTemplate, EndWaypointTemplate, FailureWaypointTemplate = CreateWaypointTemplates()
	end

	function ClickToMoveDisplay.GetEndWaypointTexture()
		return EndWaypointIcon
	end

	function ClickToMoveDisplay.SetWaypointsAlwaysOnTop(alwaysOnTop)
		WaypointsAlwaysOnTop = alwaysOnTop
		TrailDotTemplate, EndWaypointTemplate, FailureWaypointTemplate = CreateWaypointTemplates()
	end

	function ClickToMoveDisplay.GetWaypointsAlwaysOnTop()
		return WaypointsAlwaysOnTop
	end

	return ClickToMoveDisplay
end

function _BaseCharacterController()

	local ZERO_VECTOR3 = Vector3.new(0,0,0)

	local BaseCharacterController = {}
	BaseCharacterController.__index = BaseCharacterController

	function BaseCharacterController.new()
		local self = setmetatable({}, BaseCharacterController)
		self.enabled = false
		self.moveVector = ZERO_VECTOR3
		self.moveVectorIsCameraRelative = true
		self.isJumping = false
		return self
	end

	function BaseCharacterController:OnRenderStepped(dt)
	end

	function BaseCharacterController:GetMoveVector()
		return self.moveVector
	end

	function BaseCharacterController:IsMoveVectorCameraRelative()
		return self.moveVectorIsCameraRelative
	end

	function BaseCharacterController:GetIsJumping()
		return self.isJumping
	end

	function BaseCharacterController:Enable(enable)
		error("BaseCharacterController:Enable must be overridden in derived classes and should not be called.")
		return false
	end

	return BaseCharacterController
end

function _VehicleController()
	local ContextActionService = game:GetService("ContextActionService")

	local useTriggersForThrottle = true
	local onlyTriggersForThrottle = false
	local ZERO_VECTOR3 = Vector3.new(0,0,0)

	local AUTO_PILOT_DEFAULT_MAX_STEERING_ANGLE = 35


	local VehicleController = {}
	VehicleController.__index = VehicleController

	function VehicleController.new(CONTROL_ACTION_PRIORITY)
		local self = setmetatable({}, VehicleController)

		self.CONTROL_ACTION_PRIORITY = CONTROL_ACTION_PRIORITY

		self.enabled = false
		self.vehicleSeat = nil
		self.throttle = 0
		self.steer = 0

		self.acceleration = 0
		self.decceleration = 0
		self.turningRight = 0
		self.turningLeft = 0

		self.vehicleMoveVector = ZERO_VECTOR3

		self.autoPilot = {}
		self.autoPilot.MaxSpeed = 0
		self.autoPilot.MaxSteeringAngle = 0

		return self
	end

	function VehicleController:BindContextActions()
		if useTriggersForThrottle then
			ContextActionService:BindActionAtPriority("throttleAccel", (function(actionName, inputState, inputObject)
				self:OnThrottleAccel(actionName, inputState, inputObject)
				return Enum.ContextActionResult.Pass
			end), false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.ButtonR2)
			ContextActionService:BindActionAtPriority("throttleDeccel", (function(actionName, inputState, inputObject)
				self:OnThrottleDeccel(actionName, inputState, inputObject)
				return Enum.ContextActionResult.Pass
			end), false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.ButtonL2)
		end
		ContextActionService:BindActionAtPriority("arrowSteerRight", (function(actionName, inputState, inputObject)
			self:OnSteerRight(actionName, inputState, inputObject)
			return Enum.ContextActionResult.Pass
		end), false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.Right)
		ContextActionService:BindActionAtPriority("arrowSteerLeft", (function(actionName, inputState, inputObject)
			self:OnSteerLeft(actionName, inputState, inputObject)
			return Enum.ContextActionResult.Pass
		end), false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.Left)
	end

	function VehicleController:Enable(enable, vehicleSeat)
		if enable == self.enabled and vehicleSeat == self.vehicleSeat then
			return
		end

		self.enabled = enable
		self.vehicleMoveVector = ZERO_VECTOR3

		if enable then
			if vehicleSeat then
				self.vehicleSeat = vehicleSeat

				self:SetupAutoPilot()
				self:BindContextActions()
			end
		else
			if useTriggersForThrottle then
				ContextActionService:UnbindAction("throttleAccel")
				ContextActionService:UnbindAction("throttleDeccel")
			end
			ContextActionService:UnbindAction("arrowSteerRight")
			ContextActionService:UnbindAction("arrowSteerLeft")
			self.vehicleSeat = nil
		end
	end

	function VehicleController:OnThrottleAccel(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
			self.acceleration = 0
		else
			self.acceleration = -1
		end
		self.throttle = self.acceleration + self.decceleration
	end

	function VehicleController:OnThrottleDeccel(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
			self.decceleration = 0
		else
			self.decceleration = 1
		end
		self.throttle = self.acceleration + self.decceleration
	end

	function VehicleController:OnSteerRight(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
			self.turningRight = 0
		else
			self.turningRight = 1
		end
		self.steer = self.turningRight + self.turningLeft
	end

	function VehicleController:OnSteerLeft(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
			self.turningLeft = 0
		else
			self.turningLeft = -1
		end
		self.steer = self.turningRight + self.turningLeft
	end

	function VehicleController:Update(moveVector, cameraRelative, usingGamepad)
		if self.vehicleSeat then
			if cameraRelative then
				moveVector = moveVector + Vector3.new(self.steer, 0, self.throttle)
				if usingGamepad and onlyTriggersForThrottle and useTriggersForThrottle then
					self.vehicleSeat.ThrottleFloat = -self.throttle
				else
					self.vehicleSeat.ThrottleFloat = -moveVector.Z
				end
				self.vehicleSeat.SteerFloat = moveVector.X

				return moveVector, true
			else
				local localMoveVector = self.vehicleSeat.Occupant.RootPart.CFrame:VectorToObjectSpace(moveVector)

				self.vehicleSeat.ThrottleFloat = self:ComputeThrottle(localMoveVector)
				self.vehicleSeat.SteerFloat = self:ComputeSteer(localMoveVector)

				return ZERO_VECTOR3, true
			end
		end
		return moveVector, false
	end

	function VehicleController:ComputeThrottle(localMoveVector)
		if localMoveVector ~= ZERO_VECTOR3 then
			local throttle = -localMoveVector.Z
			return throttle
		else
			return 0.0
		end
	end

	function VehicleController:ComputeSteer(localMoveVector)
		if localMoveVector ~= ZERO_VECTOR3 then
			local steerAngle = -math.atan2(-localMoveVector.x, -localMoveVector.z) * (180 / math.pi)
			return steerAngle / self.autoPilot.MaxSteeringAngle
		else
			return 0.0
		end
	end

	function VehicleController:SetupAutoPilot()
		self.autoPilot.MaxSpeed = self.vehicleSeat.MaxSpeed
		self.autoPilot.MaxSteeringAngle = AUTO_PILOT_DEFAULT_MAX_STEERING_ANGLE

	end

	return VehicleController
end

function _TouchJump()

	local Players = game:GetService("Players")
	local GuiService = game:GetService("GuiService")

	local TOUCH_CONTROL_SHEET = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"

	local BaseCharacterController = _BaseCharacterController()
	local TouchJump = setmetatable({}, BaseCharacterController)
	TouchJump.__index = TouchJump

	function TouchJump.new()
		local self = setmetatable(BaseCharacterController.new(), TouchJump)

		self.parentUIFrame = nil
		self.jumpButton = nil
		self.characterAddedConn = nil
		self.humanoidStateEnabledChangedConn = nil
		self.humanoidJumpPowerConn = nil
		self.humanoidParentConn = nil
		self.externallyEnabled = false
		self.jumpPower = 0
		self.jumpStateEnabled = true
		self.isJumping = false
		self.humanoid = nil

		return self
	end

	function TouchJump:EnableButton(enable)
		if enable then
			if not self.jumpButton then
				self:Create()
			end
			local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and self.externallyEnabled then
				if self.externallyEnabled then
					if humanoid.JumpPower > 0 then
						self.jumpButton.Visible = true
					end
				end
			end
		else
			self.jumpButton.Visible = false
			self.isJumping = false
			self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
		end
	end

	function TouchJump:UpdateEnabled()
		if self.jumpPower > 0 and self.jumpStateEnabled then
			self:EnableButton(true)
		else
			self:EnableButton(false)
		end
	end

	function TouchJump:HumanoidChanged(prop)
		local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if prop == "JumpPower" then
				self.jumpPower =  humanoid.JumpPower
				self:UpdateEnabled()
			elseif prop == "Parent" then
				if not humanoid.Parent then
					self.humanoidChangeConn:Disconnect()
				end
			end
		end
	end

	function TouchJump:HumanoidStateEnabledChanged(state, isEnabled)
		if state == Enum.HumanoidStateType.Jumping then
			self.jumpStateEnabled = isEnabled
			self:UpdateEnabled()
		end
	end

	function TouchJump:CharacterAdded(char)
		if self.humanoidChangeConn then
			self.humanoidChangeConn:Disconnect()
			self.humanoidChangeConn = nil
		end

		self.humanoid = char:FindFirstChildOfClass("Humanoid")
		while not self.humanoid do
			char.ChildAdded:wait()
			self.humanoid = char:FindFirstChildOfClass("Humanoid")
		end

		self.humanoidJumpPowerConn = self.humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
			self.jumpPower =  self.humanoid.JumpPower
			self:UpdateEnabled()
		end)

		self.humanoidParentConn = self.humanoid:GetPropertyChangedSignal("Parent"):Connect(function()
			if not self.humanoid.Parent then
				self.humanoidJumpPowerConn:Disconnect()
				self.humanoidJumpPowerConn = nil
				self.humanoidParentConn:Disconnect()
				self.humanoidParentConn = nil
			end
		end)

		self.humanoidStateEnabledChangedConn = self.humanoid.StateEnabledChanged:Connect(function(state, enabled)
			self:HumanoidStateEnabledChanged(state, enabled)
		end)

		self.jumpPower = self.humanoid.JumpPower
		self.jumpStateEnabled = self.humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
		self:UpdateEnabled()
	end

	function TouchJump:SetupCharacterAddedFunction()
		self.characterAddedConn = Players.LocalPlayer.CharacterAdded:Connect(function(char)
			self:CharacterAdded(char)
		end)
		if Players.LocalPlayer.Character then
			self:CharacterAdded(Players.LocalPlayer.Character)
		end
	end

	function TouchJump:Enable(enable, parentFrame)
		if parentFrame then
			self.parentUIFrame = parentFrame
		end
		self.externallyEnabled = enable
		self:EnableButton(enable)
	end

	function TouchJump:Create()
		if not self.parentUIFrame then
			return
		end

		if self.jumpButton then
			self.jumpButton:Destroy()
			self.jumpButton = nil
		end

		local minAxis = math.min(self.parentUIFrame.AbsoluteSize.x, self.parentUIFrame.AbsoluteSize.y)
		local isSmallScreen = minAxis <= 500
		local jumpButtonSize = isSmallScreen and 70 or 120

		self.jumpButton = Instance.new("ImageButton")
		self.jumpButton.Name = "JumpButton"
		self.jumpButton.Visible = false
		self.jumpButton.BackgroundTransparency = 1
		self.jumpButton.Image = TOUCH_CONTROL_SHEET
		self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
		self.jumpButton.ImageRectSize = Vector2.new(144, 144)
		self.jumpButton.Size = UDim2.new(0, jumpButtonSize, 0, jumpButtonSize)

		self.jumpButton.Position = isSmallScreen and UDim2.new(1, -(jumpButtonSize*1.5-10), 1, -jumpButtonSize - 20) or
			UDim2.new(1, -(jumpButtonSize*1.5-10), 1, -jumpButtonSize * 1.75)

		local touchObject = nil
		self.jumpButton.InputBegan:connect(function(inputObject)
			if touchObject or inputObject.UserInputType ~= Enum.UserInputType.Touch
				or inputObject.UserInputState ~= Enum.UserInputState.Begin then
				return
			end

			touchObject = inputObject
			self.jumpButton.ImageRectOffset = Vector2.new(146, 146)
			self.isJumping = true
		end)

		local OnInputEnded = function()
			touchObject = nil
			self.isJumping = false
			self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
		end

		self.jumpButton.InputEnded:connect(function(inputObject)
			if inputObject == touchObject then
				OnInputEnded()
			end
		end)

		GuiService.MenuOpened:connect(function()
			if touchObject then
				OnInputEnded()
			end
		end)

		if not self.characterAddedConn then
			self:SetupCharacterAddedFunction()
		end

		self.jumpButton.Parent = self.parentUIFrame
	end

	return TouchJump
end

function _ClickToMoveController()
	local UserInputService = game:GetService("UserInputService")
	local PathfindingService = game:GetService("PathfindingService")
	local Players = game:GetService("Players")
	local DebrisService = game:GetService('Debris')
	local StarterGui = game:GetService("StarterGui")
	local Workspace = game:GetService("Workspace")
	local CollectionService = game:GetService("CollectionService")
	local GuiService = game:GetService("GuiService")


	local ShowPath = true
	local PlayFailureAnimation = true
	local UseDirectPath = false
	local UseDirectPathForVehicle = true
	local AgentSizeIncreaseFactor = 1.0
	local UnreachableWaypointTimeout = 8

	local movementKeys = {
		[Enum.KeyCode.W] = true;
		[Enum.KeyCode.A] = true;
		[Enum.KeyCode.S] = true;
		[Enum.KeyCode.D] = true;
		[Enum.KeyCode.Up] = true;
		[Enum.KeyCode.Down] = true;
	}

	local FFlagUserNavigationClickToMoveSkipPassedWaypointsSuccess, FFlagUserNavigationClickToMoveSkipPassedWaypointsResult = pcall(function() return UserSettings():IsUserFeatureEnabled("UserNavigationClickToMoveSkipPassedWaypoints") end)
	local FFlagUserNavigationClickToMoveSkipPassedWaypoints = FFlagUserNavigationClickToMoveSkipPassedWaypointsSuccess and FFlagUserNavigationClickToMoveSkipPassedWaypointsResult

	local Player = Players.LocalPlayer

	local ClickToMoveDisplay = _ClickToMoveDisplay()

	local ZERO_VECTOR3 = Vector3.new(0,0,0)
	local ALMOST_ZERO = 0.000001


	local Utility = {}
	do
		local function FindCharacterAncestor(part)
			if part then
				local humanoid = part:FindFirstChildOfClass("Humanoid")
				if humanoid then
					return part, humanoid
				else
					return FindCharacterAncestor(part.Parent)
				end
			end
		end
		Utility.FindCharacterAncestor = FindCharacterAncestor

		local function Raycast(ray, ignoreNonCollidable, ignoreList)
			ignoreList = ignoreList or {}
			local hitPart, hitPos, hitNorm, hitMat = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
			if hitPart then
				if ignoreNonCollidable and hitPart.CanCollide == false then
					local _, humanoid = FindCharacterAncestor(hitPart)
					if humanoid == nil then
						table.insert(ignoreList, hitPart)
						return Raycast(ray, ignoreNonCollidable, ignoreList)
					end
				end
				return hitPart, hitPos, hitNorm, hitMat
			end
			return nil, nil
		end
		Utility.Raycast = Raycast
	end

	local humanoidCache = {}
	local function findPlayerHumanoid(player)
		local character = player and player.Character
		if character then
			local resultHumanoid = humanoidCache[player]
			if resultHumanoid and resultHumanoid.Parent == character then
				return resultHumanoid
			else
				humanoidCache[player] = nil
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoidCache[player] = humanoid
				end
				return humanoid
			end
		end
	end

	local CurrentIgnoreList
	local CurrentIgnoreTag = nil

	local TaggedInstanceAddedConnection = nil
	local TaggedInstanceRemovedConnection = nil

	local function GetCharacter()
		return Player and Player.Character
	end

	local function UpdateIgnoreTag(newIgnoreTag)
		if newIgnoreTag == CurrentIgnoreTag then
			return
		end
		if TaggedInstanceAddedConnection then
			TaggedInstanceAddedConnection:Disconnect()
			TaggedInstanceAddedConnection = nil
		end
		if TaggedInstanceRemovedConnection then
			TaggedInstanceRemovedConnection:Disconnect()
			TaggedInstanceRemovedConnection = nil
		end
		CurrentIgnoreTag = newIgnoreTag
		CurrentIgnoreList = {GetCharacter()}
		if CurrentIgnoreTag ~= nil then
			local ignoreParts = CollectionService:GetTagged(CurrentIgnoreTag)
			for _, ignorePart in ipairs(ignoreParts) do
				table.insert(CurrentIgnoreList, ignorePart)
			end
			TaggedInstanceAddedConnection = CollectionService:GetInstanceAddedSignal(
				CurrentIgnoreTag):Connect(function(ignorePart)
				table.insert(CurrentIgnoreList, ignorePart)
			end)
			TaggedInstanceRemovedConnection = CollectionService:GetInstanceRemovedSignal(
				CurrentIgnoreTag):Connect(function(ignorePart)
				for i = 1, #CurrentIgnoreList do
					if CurrentIgnoreList[i] == ignorePart then
						CurrentIgnoreList[i] = CurrentIgnoreList[#CurrentIgnoreList]
						table.remove(CurrentIgnoreList)
						break
					end
				end
			end)
		end
	end

	local function getIgnoreList()
		if CurrentIgnoreList then
			return CurrentIgnoreList
		end
		CurrentIgnoreList = {}
		table.insert(CurrentIgnoreList, GetCharacter())
		return CurrentIgnoreList
	end


	local function Pather(endPoint, surfaceNormal, overrideUseDirectPath)
		local this = {}

		local directPathForHumanoid
		local directPathForVehicle
		if overrideUseDirectPath ~= nil then
			directPathForHumanoid = overrideUseDirectPath
			directPathForVehicle = overrideUseDirectPath
		else
			directPathForHumanoid = UseDirectPath
			directPathForVehicle = UseDirectPathForVehicle
		end

		this.Cancelled = false
		this.Started = false

		this.Finished = Instance.new("BindableEvent")
		this.PathFailed = Instance.new("BindableEvent")

		this.PathComputing = false
		this.PathComputed = false

		this.OriginalTargetPoint = endPoint
		this.TargetPoint = endPoint
		this.TargetSurfaceNormal = surfaceNormal

		this.DiedConn = nil
		this.SeatedConn = nil
		this.BlockedConn = nil
		this.TeleportedConn = nil

		this.CurrentPoint = 0

		this.HumanoidOffsetFromPath = ZERO_VECTOR3

		this.CurrentWaypointPosition = nil
		this.CurrentWaypointPlaneNormal = ZERO_VECTOR3
		this.CurrentWaypointPlaneDistance = 0
		this.CurrentWaypointNeedsJump = false;

		this.CurrentHumanoidPosition = ZERO_VECTOR3
		this.CurrentHumanoidVelocity = 0

		this.NextActionMoveDirection = ZERO_VECTOR3
		this.NextActionJump = false

		this.Timeout = 0

		this.Humanoid = findPlayerHumanoid(Player)
		this.OriginPoint = nil
		this.AgentCanFollowPath = false
		this.DirectPath = false
		this.DirectPathRiseFirst = false

		local rootPart = this.Humanoid and this.Humanoid.RootPart
		if rootPart then
			this.OriginPoint = rootPart.CFrame.p

			local agentRadius = 2
			local agentHeight = 5
			local agentCanJump = true

			local seat = this.Humanoid.SeatPart
			if seat and seat:IsA("VehicleSeat") then
				local vehicle = seat:FindFirstAncestorOfClass("Model")
				if vehicle then
					local tempPrimaryPart = vehicle.PrimaryPart
					vehicle.PrimaryPart = seat

					if directPathForVehicle then
						local extents = vehicle:GetExtentsSize()
						agentRadius = AgentSizeIncreaseFactor * 0.5 * math.sqrt(extents.X * extents.X + extents.Z * extents.Z)
						agentHeight = AgentSizeIncreaseFactor * extents.Y
						agentCanJump = false
						this.AgentCanFollowPath = true
						this.DirectPath = directPathForVehicle
					end

					vehicle.PrimaryPart = tempPrimaryPart
				end
			else
				local extents = GetCharacter():GetExtentsSize()
				agentRadius = AgentSizeIncreaseFactor * 0.5 * math.sqrt(extents.X * extents.X + extents.Z * extents.Z)
				agentHeight = AgentSizeIncreaseFactor * extents.Y
				agentCanJump = (this.Humanoid.JumpPower > 0)
				this.AgentCanFollowPath = true
				this.DirectPath = directPathForHumanoid
				this.DirectPathRiseFirst = this.Humanoid.Sit
			end

			this.pathResult = PathfindingService:CreatePath({AgentRadius = agentRadius, AgentHeight = agentHeight, AgentCanJump = agentCanJump})
		end

		function this:Cleanup()
			if this.stopTraverseFunc then
				this.stopTraverseFunc()
				this.stopTraverseFunc = nil
			end

			if this.MoveToConn then
				this.MoveToConn:Disconnect()
				this.MoveToConn = nil
			end

			if this.BlockedConn then
				this.BlockedConn:Disconnect()
				this.BlockedConn = nil
			end

			if this.DiedConn then
				this.DiedConn:Disconnect()
				this.DiedConn = nil
			end

			if this.SeatedConn then
				this.SeatedConn:Disconnect()
				this.SeatedConn = nil
			end

			if this.TeleportedConn then
				this.TeleportedConn:Disconnect()
				this.TeleportedConn = nil
			end

			this.Started = false
		end

		function this:Cancel()
			this.Cancelled = true
			this:Cleanup()
		end

		function this:IsActive()
			return this.AgentCanFollowPath and this.Started and not this.Cancelled
		end

		function this:OnPathInterrupted()
			this.Cancelled = true
			this:OnPointReached(false)
		end

		function this:ComputePath()
			if this.OriginPoint then
				if this.PathComputed or this.PathComputing then return end
				this.PathComputing = true
				if this.AgentCanFollowPath then
					if this.DirectPath then
						this.pointList = {
							PathWaypoint.new(this.OriginPoint, Enum.PathWaypointAction.Walk),
							PathWaypoint.new(this.TargetPoint, this.DirectPathRiseFirst and Enum.PathWaypointAction.Jump or Enum.PathWaypointAction.Walk)
						}
						this.PathComputed = true
					else
						this.pathResult:ComputeAsync(this.OriginPoint, this.TargetPoint)
						this.pointList = this.pathResult:GetWaypoints()
						this.BlockedConn = this.pathResult.Blocked:Connect(function(blockedIdx) this:OnPathBlocked(blockedIdx) end)
						this.PathComputed = this.pathResult.Status == Enum.PathStatus.Success
					end
				end
				this.PathComputing = false
			end
		end

		function this:IsValidPath()
			this:ComputePath()
			return this.PathComputed and this.AgentCanFollowPath
		end

		this.Recomputing = false
		function this:OnPathBlocked(blockedWaypointIdx)
			local pathBlocked = blockedWaypointIdx >= this.CurrentPoint
			if not pathBlocked or this.Recomputing then
				return
			end

			this.Recomputing = true

			if this.stopTraverseFunc then
				this.stopTraverseFunc()
				this.stopTraverseFunc = nil
			end

			this.OriginPoint = this.Humanoid.RootPart.CFrame.p

			this.pathResult:ComputeAsync(this.OriginPoint, this.TargetPoint)
			this.pointList = this.pathResult:GetWaypoints()
			if #this.pointList > 0 then
				this.HumanoidOffsetFromPath = this.pointList[1].Position - this.OriginPoint
			end
			this.PathComputed = this.pathResult.Status == Enum.PathStatus.Success

			if ShowPath then
				this.stopTraverseFunc, this.setPointFunc = ClickToMoveDisplay.CreatePathDisplay(this.pointList)
			end
			if this.PathComputed then
				this.CurrentPoint = 1
				this:OnPointReached(true)
			else
				this.PathFailed:Fire()
				this:Cleanup()
			end

			this.Recomputing = false
		end

		function this:OnRenderStepped(dt)
			if this.Started and not this.Cancelled then
				this.Timeout = this.Timeout + dt
				if this.Timeout > UnreachableWaypointTimeout then
					this:OnPointReached(false)
					return
				end

				this.CurrentHumanoidPosition = this.Humanoid.RootPart.Position + this.HumanoidOffsetFromPath
				this.CurrentHumanoidVelocity = this.Humanoid.RootPart.Velocity

				while this.Started and this:IsCurrentWaypointReached() do
					this:OnPointReached(true)
				end

				if this.Started then
					this.NextActionMoveDirection = this.CurrentWaypointPosition - this.CurrentHumanoidPosition
					if this.NextActionMoveDirection.Magnitude > ALMOST_ZERO then
						this.NextActionMoveDirection = this.NextActionMoveDirection.Unit
					else
						this.NextActionMoveDirection = ZERO_VECTOR3
					end
					if this.CurrentWaypointNeedsJump then
						this.NextActionJump = true
						this.CurrentWaypointNeedsJump = false
					else
						this.NextActionJump = false
					end
				end
			end
		end

		function this:IsCurrentWaypointReached()
			local reached = false

			if this.CurrentWaypointPlaneNormal ~= ZERO_VECTOR3 then
				local dist = this.CurrentWaypointPlaneNormal:Dot(this.CurrentHumanoidPosition) - this.CurrentWaypointPlaneDistance
				local velocity = -this.CurrentWaypointPlaneNormal:Dot(this.CurrentHumanoidVelocity)
				local threshold = math.max(1.0, 0.0625 * velocity)
				reached = dist < threshold
			else
				reached = true
			end

			if reached then
				this.CurrentWaypointPosition = nil
				this.CurrentWaypointPlaneNormal	= ZERO_VECTOR3
				this.CurrentWaypointPlaneDistance = 0
			end

			return reached
		end

		function this:OnPointReached(reached)

			if reached and not this.Cancelled then
				if this.setPointFunc then
					this.setPointFunc(this.CurrentPoint)
				end

				local nextWaypointIdx = this.CurrentPoint + 1

				if nextWaypointIdx > #this.pointList then
					if this.stopTraverseFunc then
						this.stopTraverseFunc()
					end
					this.Finished:Fire()
					this:Cleanup()
				else
					local currentWaypoint = this.pointList[this.CurrentPoint]
					local nextWaypoint = this.pointList[nextWaypointIdx]

					local currentState = this.Humanoid:GetState()
					local isInAir = currentState == Enum.HumanoidStateType.FallingDown
						or currentState == Enum.HumanoidStateType.Freefall
						or currentState == Enum.HumanoidStateType.Jumping

					if isInAir then
						local shouldWaitForGround = nextWaypoint.Action == Enum.PathWaypointAction.Jump
						if not shouldWaitForGround and this.CurrentPoint > 1 then
							local prevWaypoint = this.pointList[this.CurrentPoint - 1]

							local prevDir = currentWaypoint.Position - prevWaypoint.Position
							local currDir = nextWaypoint.Position - currentWaypoint.Position

							local prevDirXZ = Vector2.new(prevDir.x, prevDir.z).Unit
							local currDirXZ = Vector2.new(currDir.x, currDir.z).Unit

							local THRESHOLD_COS = 0.996
							shouldWaitForGround = prevDirXZ:Dot(currDirXZ) < THRESHOLD_COS
						end

						if shouldWaitForGround then
							this.Humanoid.FreeFalling:Wait()

							wait(0.1)
						end
					end

					if FFlagUserNavigationClickToMoveSkipPassedWaypoints then
						this:MoveToNextWayPoint(currentWaypoint, nextWaypoint, nextWaypointIdx)
					else
						if this.setPointFunc then
							this.setPointFunc(nextWaypointIdx)
						end
						if nextWaypoint.Action == Enum.PathWaypointAction.Jump then
							this.Humanoid.Jump = true
						end
						this.Humanoid:MoveTo(nextWaypoint.Position)

						this.CurrentPoint = nextWaypointIdx
					end
				end
			else
				this.PathFailed:Fire()
				this:Cleanup()
			end
		end

		function this:MoveToNextWayPoint(currentWaypoint, nextWaypoint, nextWaypointIdx)
			this.CurrentWaypointPlaneNormal = currentWaypoint.Position - nextWaypoint.Position
			this.CurrentWaypointPlaneNormal = Vector3.new(this.CurrentWaypointPlaneNormal.X, 0, this.CurrentWaypointPlaneNormal.Z)
			if this.CurrentWaypointPlaneNormal.Magnitude > ALMOST_ZERO then
				this.CurrentWaypointPlaneNormal	= this.CurrentWaypointPlaneNormal.Unit
				this.CurrentWaypointPlaneDistance = this.CurrentWaypointPlaneNormal:Dot(nextWaypoint.Position)
			else
				this.CurrentWaypointPlaneNormal	= ZERO_VECTOR3
				this.CurrentWaypointPlaneDistance = 0
			end

			this.CurrentWaypointNeedsJump = nextWaypoint.Action == Enum.PathWaypointAction.Jump;

			this.CurrentWaypointPosition = nextWaypoint.Position

			this.CurrentPoint = nextWaypointIdx

			this.Timeout = 0
		end

		function this:Start(overrideShowPath)
			if not this.AgentCanFollowPath then
				this.PathFailed:Fire()
				return
			end

			if this.Started then return end
			this.Started = true

			ClickToMoveDisplay.CancelFailureAnimation()

			if ShowPath then
				if overrideShowPath == nil or overrideShowPath then
					this.stopTraverseFunc, this.setPointFunc = ClickToMoveDisplay.CreatePathDisplay(this.pointList, this.OriginalTargetPoint)
				end
			end

			if #this.pointList > 0 then
				this.HumanoidOffsetFromPath = Vector3.new(0, this.pointList[1].Position.Y - this.OriginPoint.Y, 0)

				this.CurrentHumanoidPosition = this.Humanoid.RootPart.Position + this.HumanoidOffsetFromPath
				this.CurrentHumanoidVelocity = this.Humanoid.RootPart.Velocity

				this.SeatedConn = this.Humanoid.Seated:Connect(function(isSeated, seat) this:OnPathInterrupted() end)
				this.DiedConn = this.Humanoid.Died:Connect(function() this:OnPathInterrupted() end)
				this.TeleportedConn = this.Humanoid.RootPart:GetPropertyChangedSignal("CFrame"):Connect(function() this:OnPathInterrupted() end)

				this.CurrentPoint = 1
				this:OnPointReached(true)
			else
				this.PathFailed:Fire()
				if this.stopTraverseFunc then
					this.stopTraverseFunc()
				end
			end
		end

		local offsetPoint = this.TargetPoint + this.TargetSurfaceNormal*1.5
		local ray = Ray.new(offsetPoint, Vector3.new(0,-1,0)*50)
		local newHitPart, newHitPos = Workspace:FindPartOnRayWithIgnoreList(ray, getIgnoreList())
		if newHitPart then
			this.TargetPoint = newHitPos
		end
		this:ComputePath()

		return this
	end


	local function CheckAlive()
		local humanoid = findPlayerHumanoid(Player)
		return humanoid ~= nil and humanoid.Health > 0
	end

	local function GetEquippedTool(character)
		if character ~= nil then
			for _, child in pairs(character:GetChildren()) do
				if child:IsA('Tool') then
					return child
				end
			end
		end
	end

	local ExistingPather = nil
	local ExistingIndicator = nil
	local PathCompleteListener = nil
	local PathFailedListener = nil

	local function CleanupPath()
		if ExistingPather then
			ExistingPather:Cancel()
			ExistingPather = nil
		end
		if PathCompleteListener then
			PathCompleteListener:Disconnect()
			PathCompleteListener = nil
		end
		if PathFailedListener then
			PathFailedListener:Disconnect()
			PathFailedListener = nil
		end
		if ExistingIndicator then
			ExistingIndicator:Destroy()
		end
	end

	local function HandleMoveTo(thisPather, hitPt, hitChar, character, overrideShowPath)
		if ExistingPather then
			CleanupPath()
		end
		ExistingPather = thisPather
		thisPather:Start(overrideShowPath)

		PathCompleteListener = thisPather.Finished.Event:Connect(function()
			CleanupPath()
			if hitChar then
				local currentWeapon = GetEquippedTool(character)
				if currentWeapon then
					currentWeapon:Activate()
				end
			end
		end)
		PathFailedListener = thisPather.PathFailed.Event:Connect(function()
			CleanupPath()
			if overrideShowPath == nil or overrideShowPath then
				local shouldPlayFailureAnim = PlayFailureAnimation and not (ExistingPather and ExistingPather:IsActive())
				if shouldPlayFailureAnim then
					ClickToMoveDisplay.PlayFailureAnimation()
				end
				ClickToMoveDisplay.DisplayFailureWaypoint(hitPt)
			end
		end)
	end

	local function ShowPathFailedFeedback(hitPt)
		if ExistingPather and ExistingPather:IsActive() then
			ExistingPather:Cancel()
		end
		if PlayFailureAnimation then
			ClickToMoveDisplay.PlayFailureAnimation()
		end
		ClickToMoveDisplay.DisplayFailureWaypoint(hitPt)
	end

	function OnTap(tapPositions, goToPoint, wasTouchTap)
		local camera = Workspace.CurrentCamera
		local character = Player.Character

		if not CheckAlive() then return end

		if #tapPositions == 1 or goToPoint then
			if camera then
				local unitRay = camera:ScreenPointToRay(tapPositions[1].x, tapPositions[1].y)
				local ray = Ray.new(unitRay.Origin, unitRay.Direction*1000)

				local myHumanoid = findPlayerHumanoid(Player)
				local hitPart, hitPt, hitNormal = Utility.Raycast(ray, true, getIgnoreList())

				local hitChar, hitHumanoid = Utility.FindCharacterAncestor(hitPart)
				if wasTouchTap and hitHumanoid and StarterGui:GetCore("AvatarContextMenuEnabled") then
					local clickedPlayer = Players:GetPlayerFromCharacter(hitHumanoid.Parent)
					if clickedPlayer then
						CleanupPath()
						return
					end
				end
				if goToPoint then
					hitPt = goToPoint
					hitChar = nil
				end
				if hitPt and character then
					CleanupPath()
					local thisPather = Pather(hitPt, hitNormal)
					if thisPather:IsValidPath() then
						HandleMoveTo(thisPather, hitPt, hitChar, character)
					else
						thisPather:Cleanup()
						ShowPathFailedFeedback(hitPt)
					end
				end
			end
		elseif #tapPositions >= 2 then
			if camera then
				local currentWeapon = GetEquippedTool(character)
				if currentWeapon then
					currentWeapon:Activate()
				end
			end
		end
	end

	local function DisconnectEvent(event)
		if event then
			event:Disconnect()
		end
	end

	local KeyboardController = _Keyboard()
	local ClickToMove = setmetatable({}, KeyboardController)
	ClickToMove.__index = ClickToMove

	function ClickToMove.new(CONTROL_ACTION_PRIORITY)
		local self = setmetatable(KeyboardController.new(CONTROL_ACTION_PRIORITY), ClickToMove)

		self.fingerTouches = {}
		self.numUnsunkTouches = 0
		self.mouse1Down = tick()
		self.mouse1DownPos = Vector2.new()
		self.mouse2DownTime = tick()
		self.mouse2DownPos = Vector2.new()
		self.mouse2UpTime = tick()

		self.keyboardMoveVector = ZERO_VECTOR3

		self.tapConn = nil
		self.inputBeganConn = nil
		self.inputChangedConn = nil
		self.inputEndedConn = nil
		self.humanoidDiedConn = nil
		self.characterChildAddedConn = nil
		self.onCharacterAddedConn = nil
		self.characterChildRemovedConn = nil
		self.renderSteppedConn = nil
		self.menuOpenedConnection = nil

		self.running = false

		self.wasdEnabled = false

		return self
	end

	function ClickToMove:DisconnectEvents()
		DisconnectEvent(self.tapConn)
		DisconnectEvent(self.inputBeganConn)
		DisconnectEvent(self.inputChangedConn)
		DisconnectEvent(self.inputEndedConn)
		DisconnectEvent(self.humanoidDiedConn)
		DisconnectEvent(self.characterChildAddedConn)
		DisconnectEvent(self.onCharacterAddedConn)
		DisconnectEvent(self.renderSteppedConn)
		DisconnectEvent(self.characterChildRemovedConn)
		DisconnectEvent(self.menuOpenedConnection)
	end

	function ClickToMove:OnTouchBegan(input, processed)
		if self.fingerTouches[input] == nil and not processed then
			self.numUnsunkTouches = self.numUnsunkTouches + 1
		end
		self.fingerTouches[input] = processed
	end

	function ClickToMove:OnTouchChanged(input, processed)
		if self.fingerTouches[input] == nil then
			self.fingerTouches[input] = processed
			if not processed then
				self.numUnsunkTouches = self.numUnsunkTouches + 1
			end
		end
	end

	function ClickToMove:OnTouchEnded(input, processed)
		if self.fingerTouches[input] ~= nil and self.fingerTouches[input] == false then
			self.numUnsunkTouches = self.numUnsunkTouches - 1
		end
		self.fingerTouches[input] = nil
	end


	function ClickToMove:OnCharacterAdded(character)
		self:DisconnectEvents()

		self.inputBeganConn = UserInputService.InputBegan:Connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.Touch then
				self:OnTouchBegan(input, processed)
			end

			if self.wasdEnabled and processed == false and input.UserInputType == Enum.UserInputType.Keyboard
				and movementKeys[input.KeyCode] then
				CleanupPath()
				ClickToMoveDisplay.CancelFailureAnimation()
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self.mouse1DownTime = tick()
				self.mouse1DownPos = input.Position
			end
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				self.mouse2DownTime = tick()
				self.mouse2DownPos = input.Position
			end
		end)

		self.inputChangedConn = UserInputService.InputChanged:Connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.Touch then
				self:OnTouchChanged(input, processed)
			end
		end)

		self.inputEndedConn = UserInputService.InputEnded:Connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.Touch then
				self:OnTouchEnded(input, processed)
			end

			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				self.mouse2UpTime = tick()
				local currPos = input.Position
				local allowed = ExistingPather or self.keyboardMoveVector.Magnitude <= 0
				if self.mouse2UpTime - self.mouse2DownTime < 0.25 and (currPos - self.mouse2DownPos).magnitude < 5 and allowed then
					local positions = {currPos}
					OnTap(positions)
				end
			end
		end)

		self.tapConn = UserInputService.TouchTap:Connect(function(touchPositions, processed)
			if not processed then
				OnTap(touchPositions, nil, true)
			end
		end)

		self.menuOpenedConnection = GuiService.MenuOpened:Connect(function()
			CleanupPath()
		end)

		local function OnCharacterChildAdded(child)
			if UserInputService.TouchEnabled then
				if child:IsA('Tool') then
					child.ManualActivationOnly = true
				end
			end
			if child:IsA('Humanoid') then
				DisconnectEvent(self.humanoidDiedConn)
				self.humanoidDiedConn = child.Died:Connect(function()
					if ExistingIndicator then
						DebrisService:AddItem(ExistingIndicator.Model, 1)
					end
				end)
			end
		end

		self.characterChildAddedConn = character.ChildAdded:Connect(function(child)
			OnCharacterChildAdded(child)
		end)
		self.characterChildRemovedConn = character.ChildRemoved:Connect(function(child)
			if UserInputService.TouchEnabled then
				if child:IsA('Tool') then
					child.ManualActivationOnly = false
				end
			end
		end)
		for _, child in pairs(character:GetChildren()) do
			OnCharacterChildAdded(child)
		end
	end

	function ClickToMove:Start()
		self:Enable(true)
	end

	function ClickToMove:Stop()
		self:Enable(false)
	end

	function ClickToMove:CleanupPath()
		CleanupPath()
	end

	function ClickToMove:Enable(enable, enableWASD, touchJumpController)
		if enable then
			if not self.running then
				if Player.Character then
					self:OnCharacterAdded(Player.Character)
				end
				self.onCharacterAddedConn = Player.CharacterAdded:Connect(function(char)
					self:OnCharacterAdded(char)
				end)
				self.running = true
			end
			self.touchJumpController = touchJumpController
			if self.touchJumpController then
				self.touchJumpController:Enable(self.jumpEnabled)
			end
		else
			if self.running then
				self:DisconnectEvents()
				CleanupPath()
				if UserInputService.TouchEnabled then
					local character = Player.Character
					if character then
						for _, child in pairs(character:GetChildren()) do
							if child:IsA('Tool') then
								child.ManualActivationOnly = false
							end
						end
					end
				end
				self.running = false
			end
			if self.touchJumpController and not self.jumpEnabled then
				self.touchJumpController:Enable(true)
			end
			self.touchJumpController = nil
		end

		if UserInputService.KeyboardEnabled and enable ~= self.enabled then

			self.forwardValue  = 0
			self.backwardValue = 0
			self.leftValue = 0
			self.rightValue = 0

			self.moveVector = ZERO_VECTOR3

			if enable then
				self:BindContextActions()
				self:ConnectFocusEventListeners()
			else
				self:UnbindContextActions()
				self:DisconnectFocusEventListeners()
			end
		end

		self.wasdEnabled = enable and enableWASD or false
		self.enabled = enable
	end

	function ClickToMove:OnRenderStepped(dt)
		self.isJumping = false

		if ExistingPather then
			ExistingPather:OnRenderStepped(dt)

			if ExistingPather then
				self.moveVector = ExistingPather.NextActionMoveDirection
				self.moveVectorIsCameraRelative = false

				if ExistingPather.NextActionJump then
					self.isJumping = true
				end
			else
				self.moveVector = self.keyboardMoveVector
				self.moveVectorIsCameraRelative = true
			end
		else
			self.moveVector = self.keyboardMoveVector
			self.moveVectorIsCameraRelative = true
		end

		if self.jumpRequested then
			self.isJumping = true
		end
	end

	function ClickToMove:UpdateMovement(inputState)
		if inputState == Enum.UserInputState.Cancel then
			self.keyboardMoveVector = ZERO_VECTOR3
		elseif self.wasdEnabled then
			self.keyboardMoveVector = Vector3.new(self.leftValue + self.rightValue, 0, self.forwardValue + self.backwardValue)
		end
	end

	function ClickToMove:UpdateJump()
	end

	function ClickToMove:SetShowPath(value)
		ShowPath = value
	end

	function ClickToMove:GetShowPath()
		return ShowPath
	end

	function ClickToMove:SetWaypointTexture(texture)
		ClickToMoveDisplay.SetWaypointTexture(texture)
	end

	function ClickToMove:GetWaypointTexture()
		return ClickToMoveDisplay.GetWaypointTexture()
	end

	function ClickToMove:SetWaypointRadius(radius)
		ClickToMoveDisplay.SetWaypointRadius(radius)
	end

	function ClickToMove:GetWaypointRadius()
		return ClickToMoveDisplay.GetWaypointRadius()
	end

	function ClickToMove:SetEndWaypointTexture(texture)
		ClickToMoveDisplay.SetEndWaypointTexture(texture)
	end

	function ClickToMove:GetEndWaypointTexture()
		return ClickToMoveDisplay.GetEndWaypointTexture()
	end

	function ClickToMove:SetWaypointsAlwaysOnTop(alwaysOnTop)
		ClickToMoveDisplay.SetWaypointsAlwaysOnTop(alwaysOnTop)
	end

	function ClickToMove:GetWaypointsAlwaysOnTop()
		return ClickToMoveDisplay.GetWaypointsAlwaysOnTop()
	end

	function ClickToMove:SetFailureAnimationEnabled(enabled)
		PlayFailureAnimation = enabled
	end

	function ClickToMove:GetFailureAnimationEnabled()
		return PlayFailureAnimation
	end

	function ClickToMove:SetIgnoredPartsTag(tag)
		UpdateIgnoreTag(tag)
	end

	function ClickToMove:GetIgnoredPartsTag()
		return CurrentIgnoreTag
	end

	function ClickToMove:SetUseDirectPath(directPath)
		UseDirectPath = directPath
	end

	function ClickToMove:GetUseDirectPath()
		return UseDirectPath
	end

	function ClickToMove:SetAgentSizeIncreaseFactor(increaseFactorPercent)
		AgentSizeIncreaseFactor = 1.0 + (increaseFactorPercent / 100.0)
	end

	function ClickToMove:GetAgentSizeIncreaseFactor()
		return (AgentSizeIncreaseFactor - 1.0) * 100.0
	end

	function ClickToMove:SetUnreachableWaypointTimeout(timeoutInSec)
		UnreachableWaypointTimeout = timeoutInSec
	end

	function ClickToMove:GetUnreachableWaypointTimeout()
		return UnreachableWaypointTimeout
	end

	function ClickToMove:SetUserJumpEnabled(jumpEnabled)
		self.jumpEnabled = jumpEnabled
		if self.touchJumpController then
			self.touchJumpController:Enable(jumpEnabled)
		end
	end

	function ClickToMove:GetUserJumpEnabled()
		return self.jumpEnabled
	end

	function ClickToMove:MoveTo(position, showPath, useDirectPath)
		local character = Player.Character
		if character == nil then
			return false
		end
		local thisPather = Pather(position, Vector3.new(0, 1, 0), useDirectPath)
		if thisPather and thisPather:IsValidPath() then
			HandleMoveTo(thisPather, position, nil, character, showPath)
			return true
		end
		return false
	end

	return ClickToMove
end

function _TouchThumbstick()
	local Players = game:GetService("Players")
	local GuiService = game:GetService("GuiService")
	local UserInputService = game:GetService("UserInputService")
	local ZERO_VECTOR3 = Vector3.new(0,0,0)
	local TOUCH_CONTROL_SHEET = "rbxasset://textures/ui/TouchControlsSheet.png"
	local BaseCharacterController = _BaseCharacterController()
	local TouchThumbstick = setmetatable({}, BaseCharacterController)
	TouchThumbstick.__index = TouchThumbstick
	function TouchThumbstick.new()
		local self = setmetatable(BaseCharacterController.new(), TouchThumbstick)

		self.isFollowStick = false

		self.thumbstickFrame = nil
		self.moveTouchObject = nil
		self.onTouchMovedConn = nil
		self.onTouchEndedConn = nil
		self.screenPos = nil
		self.stickImage = nil
		self.thumbstickSize = nil

		return self
	end
	function TouchThumbstick:Enable(enable, uiParentFrame)
		if enable == nil then return false end
		enable = enable and true or false
		if self.enabled == enable then return true end

		self.moveVector = ZERO_VECTOR3
		self.isJumping = false

		if enable then
			if not self.thumbstickFrame then
				self:Create(uiParentFrame)
			end
			self.thumbstickFrame.Visible = true
		else
			self.thumbstickFrame.Visible = false
			self:OnInputEnded()
		end
		self.enabled = enable
	end
	function TouchThumbstick:OnInputEnded()
		self.thumbstickFrame.Position = self.screenPos
		self.stickImage.Position = UDim2.new(0, self.thumbstickFrame.Size.X.Offset/2 - self.thumbstickSize/4, 0, self.thumbstickFrame.Size.Y.Offset/2 - self.thumbstickSize/4)

		self.moveVector = ZERO_VECTOR3
		self.isJumping = false
		self.thumbstickFrame.Position = self.screenPos
		self.moveTouchObject = nil
	end
	function TouchThumbstick:Create(parentFrame)

		if self.thumbstickFrame then
			self.thumbstickFrame:Destroy()
			self.thumbstickFrame = nil
			if self.onTouchMovedConn then
				self.onTouchMovedConn:Disconnect()
				self.onTouchMovedConn = nil
			end
			if self.onTouchEndedConn then
				self.onTouchEndedConn:Disconnect()
				self.onTouchEndedConn = nil
			end
		end

		local minAxis = math.min(parentFrame.AbsoluteSize.x, parentFrame.AbsoluteSize.y)
		local isSmallScreen = minAxis <= 500
		self.thumbstickSize = isSmallScreen and 70 or 120
		self.screenPos = isSmallScreen and UDim2.new(0, (self.thumbstickSize/2) - 10, 1, -self.thumbstickSize - 20) or
			UDim2.new(0, self.thumbstickSize/2, 1, -self.thumbstickSize * 1.75)

		self.thumbstickFrame = Instance.new("Frame")
		self.thumbstickFrame.Name = "ThumbstickFrame"
		self.thumbstickFrame.Active = true
		self.thumbstickFrame.Visible = false
		self.thumbstickFrame.Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize)
		self.thumbstickFrame.Position = self.screenPos
		self.thumbstickFrame.BackgroundTransparency = 1

		local outerImage = Instance.new("ImageLabel")
		outerImage.Name = "OuterImage"
		outerImage.Image = TOUCH_CONTROL_SHEET
		outerImage.ImageRectOffset = Vector2.new()
		outerImage.ImageRectSize = Vector2.new(220, 220)
		outerImage.BackgroundTransparency = 1
		outerImage.Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize)
		outerImage.Position = UDim2.new(0, 0, 0, 0)
		outerImage.Parent = self.thumbstickFrame

		self.stickImage = Instance.new("ImageLabel")
		self.stickImage.Name = "StickImage"
		self.stickImage.Image = TOUCH_CONTROL_SHEET
		self.stickImage.ImageRectOffset = Vector2.new(220, 0)
		self.stickImage.ImageRectSize = Vector2.new(111, 111)
		self.stickImage.BackgroundTransparency = 1
		self.stickImage.Size = UDim2.new(0, self.thumbstickSize/2, 0, self.thumbstickSize/2)
		self.stickImage.Position = UDim2.new(0, self.thumbstickSize/2 - self.thumbstickSize/4, 0, self.thumbstickSize/2 - self.thumbstickSize/4)
		self.stickImage.ZIndex = 2
		self.stickImage.Parent = self.thumbstickFrame

		local centerPosition = nil
		local deadZone = 0.05

		local function DoMove(direction)

			local currentMoveVector = direction / (self.thumbstickSize/2)

			local inputAxisMagnitude = currentMoveVector.magnitude
			if inputAxisMagnitude < deadZone then
				currentMoveVector = Vector3.new()
			else
				currentMoveVector = currentMoveVector.unit * ((inputAxisMagnitude - deadZone) / (1 - deadZone))
				currentMoveVector = Vector3.new(currentMoveVector.x, 0, currentMoveVector.y)
			end

			self.moveVector = currentMoveVector
		end

		local function MoveStick(pos)
			local relativePosition = Vector2.new(pos.x - centerPosition.x, pos.y - centerPosition.y)
			local length = relativePosition.magnitude
			local maxLength = self.thumbstickFrame.AbsoluteSize.x/2
			if self.isFollowStick and length > maxLength then
				local offset = relativePosition.unit * maxLength
				self.thumbstickFrame.Position = UDim2.new(
					0, pos.x - self.thumbstickFrame.AbsoluteSize.x/2 - offset.x,
					0, pos.y - self.thumbstickFrame.AbsoluteSize.y/2 - offset.y)
			else
				length = math.min(length, maxLength)
				relativePosition = relativePosition.unit * length
			end
			self.stickImage.Position = UDim2.new(0, relativePosition.x + self.stickImage.AbsoluteSize.x/2, 0, relativePosition.y + self.stickImage.AbsoluteSize.y/2)
		end

		self.thumbstickFrame.InputBegan:Connect(function(inputObject)
			if self.moveTouchObject or inputObject.UserInputType ~= Enum.UserInputType.Touch
				or inputObject.UserInputState ~= Enum.UserInputState.Begin then
				return
			end

			self.moveTouchObject = inputObject
			self.thumbstickFrame.Position = UDim2.new(0, inputObject.Position.x - self.thumbstickFrame.Size.X.Offset/2, 0, inputObject.Position.y - self.thumbstickFrame.Size.Y.Offset/2)
			centerPosition = Vector2.new(self.thumbstickFrame.AbsolutePosition.x + self.thumbstickFrame.AbsoluteSize.x/2,
				self.thumbstickFrame.AbsolutePosition.y + self.thumbstickFrame.AbsoluteSize.y/2)
			local direction = Vector2.new(inputObject.Position.x - centerPosition.x, inputObject.Position.y - centerPosition.y)
		end)

		self.onTouchMovedConn = UserInputService.TouchMoved:Connect(function(inputObject, isProcessed)
			if inputObject == self.moveTouchObject then
				centerPosition = Vector2.new(self.thumbstickFrame.AbsolutePosition.x + self.thumbstickFrame.AbsoluteSize.x/2,
					self.thumbstickFrame.AbsolutePosition.y + self.thumbstickFrame.AbsoluteSize.y/2)
				local direction = Vector2.new(inputObject.Position.x - centerPosition.x, inputObject.Position.y - centerPosition.y)
				DoMove(direction)
				MoveStick(inputObject.Position)
			end
		end)

		self.onTouchEndedConn = UserInputService.TouchEnded:Connect(function(inputObject, isProcessed)
			if inputObject == self.moveTouchObject then
				self:OnInputEnded()
			end
		end)

		GuiService.MenuOpened:Connect(function()
			if self.moveTouchObject then
				self:OnInputEnded()
			end
		end)

		self.thumbstickFrame.Parent = parentFrame
	end
	return TouchThumbstick
end

function _DynamicThumbstick()
	local ZERO_VECTOR3 = Vector3.new(0,0,0)
	local TOUCH_CONTROLS_SHEET = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"

	local DYNAMIC_THUMBSTICK_ACTION_NAME = "DynamicThumbstickAction"
	local DYNAMIC_THUMBSTICK_ACTION_PRIORITY = Enum.ContextActionPriority.High.Value

	local MIDDLE_TRANSPARENCIES = {
		1 - 0.89,
		1 - 0.70,
		1 - 0.60,
		1 - 0.50,
		1 - 0.40,
		1 - 0.30,
		1 - 0.25
	}
	local NUM_MIDDLE_IMAGES = #MIDDLE_TRANSPARENCIES

	local FADE_IN_OUT_BACKGROUND = true
	local FADE_IN_OUT_MAX_ALPHA = 0.35

	local FADE_IN_OUT_HALF_DURATION_DEFAULT = 0.3
	local FADE_IN_OUT_BALANCE_DEFAULT = 0.5
	local ThumbstickFadeTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	local Players = game:GetService("Players")
	local GuiService = game:GetService("GuiService")
	local UserInputService = game:GetService("UserInputService")
	local ContextActionService = game:GetService("ContextActionService")
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")

	local LocalPlayer = Players.LocalPlayer
	if not LocalPlayer then
		Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
		LocalPlayer = Players.LocalPlayer
	end

	local BaseCharacterController = _BaseCharacterController()
	local DynamicThumbstick = setmetatable({}, BaseCharacterController)
	DynamicThumbstick.__index = DynamicThumbstick

	function DynamicThumbstick.new()
		local self = setmetatable(BaseCharacterController.new(), DynamicThumbstick)

		self.moveTouchObject = nil
		self.moveTouchLockedIn = false
		self.moveTouchFirstChanged = false
		self.moveTouchStartPosition = nil

		self.startImage = nil
		self.endImage = nil
		self.middleImages = {}

		self.startImageFadeTween = nil
		self.endImageFadeTween = nil
		self.middleImageFadeTweens = {}

		self.isFirstTouch = true

		self.thumbstickFrame = nil

		self.onRenderSteppedConn = nil

		self.fadeInAndOutBalance = FADE_IN_OUT_BALANCE_DEFAULT
		self.fadeInAndOutHalfDuration = FADE_IN_OUT_HALF_DURATION_DEFAULT
		self.hasFadedBackgroundInPortrait = false
		self.hasFadedBackgroundInLandscape = false

		self.tweenInAlphaStart = nil
		self.tweenOutAlphaStart = nil

		return self
	end

	function DynamicThumbstick:GetIsJumping()
		local wasJumping = self.isJumping
		self.isJumping = false
		return wasJumping
	end

	function DynamicThumbstick:Enable(enable, uiParentFrame)
		if enable == nil then return false end
		enable = enable and true or false
		if self.enabled == enable then return true end

		if enable then
			if not self.thumbstickFrame then
				self:Create(uiParentFrame)
			end

			self:BindContextActions()
		else
			ContextActionService:UnbindAction(DYNAMIC_THUMBSTICK_ACTION_NAME)
			self:OnInputEnded()
		end

		self.enabled = enable
		self.thumbstickFrame.Visible = enable
	end

	function DynamicThumbstick:OnInputEnded()
		self.moveTouchObject = nil
		self.moveVector = ZERO_VECTOR3
		self:FadeThumbstick(false)
	end

	function DynamicThumbstick:FadeThumbstick(visible)
		if not visible and self.moveTouchObject then
			return
		end
		if self.isFirstTouch then return end

		if self.startImageFadeTween then
			self.startImageFadeTween:Cancel()
		end
		if self.endImageFadeTween then
			self.endImageFadeTween:Cancel()
		end
		for i = 1, #self.middleImages do
			if self.middleImageFadeTweens[i] then
				self.middleImageFadeTweens[i]:Cancel()
			end
		end

		if visible then
			self.startImageFadeTween = TweenService:Create(self.startImage, ThumbstickFadeTweenInfo, { ImageTransparency = 0 })
			self.startImageFadeTween:Play()

			self.endImageFadeTween = TweenService:Create(self.endImage, ThumbstickFadeTweenInfo, { ImageTransparency = 0.2 })
			self.endImageFadeTween:Play()

			for i = 1, #self.middleImages do
				self.middleImageFadeTweens[i] = TweenService:Create(self.middleImages[i], ThumbstickFadeTweenInfo, { ImageTransparency = MIDDLE_TRANSPARENCIES[i] })
				self.middleImageFadeTweens[i]:Play()
			end
		else
			self.startImageFadeTween = TweenService:Create(self.startImage, ThumbstickFadeTweenInfo, { ImageTransparency = 1 })
			self.startImageFadeTween:Play()

			self.endImageFadeTween = TweenService:Create(self.endImage, ThumbstickFadeTweenInfo, { ImageTransparency = 1 })
			self.endImageFadeTween:Play()

			for i = 1, #self.middleImages do
				self.middleImageFadeTweens[i] = TweenService:Create(self.middleImages[i], ThumbstickFadeTweenInfo, { ImageTransparency = 1 })
				self.middleImageFadeTweens[i]:Play()
			end
		end
	end

	function DynamicThumbstick:FadeThumbstickFrame(fadeDuration, fadeRatio)
		self.fadeInAndOutHalfDuration = fadeDuration * 0.5
		self.fadeInAndOutBalance = fadeRatio
		self.tweenInAlphaStart = tick()
	end

	function DynamicThumbstick:InputInFrame(inputObject)
		local frameCornerTopLeft = self.thumbstickFrame.AbsolutePosition
		local frameCornerBottomRight = frameCornerTopLeft + self.thumbstickFrame.AbsoluteSize
		local inputPosition = inputObject.Position
		if inputPosition.X >= frameCornerTopLeft.X and inputPosition.Y >= frameCornerTopLeft.Y then
			if inputPosition.X <= frameCornerBottomRight.X and inputPosition.Y <= frameCornerBottomRight.Y then
				return true
			end
		end
		return false
	end

	function DynamicThumbstick:DoFadeInBackground()
		local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		local hasFadedBackgroundInOrientation = false

		if playerGui then
			if playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeLeft or
				playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeRight then
				hasFadedBackgroundInOrientation = self.hasFadedBackgroundInLandscape
				self.hasFadedBackgroundInLandscape = true
			elseif playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait then
				hasFadedBackgroundInOrientation = self.hasFadedBackgroundInPortrait
				self.hasFadedBackgroundInPortrait = true
			end
		end

		if not hasFadedBackgroundInOrientation then
			self.fadeInAndOutHalfDuration = FADE_IN_OUT_HALF_DURATION_DEFAULT
			self.fadeInAndOutBalance = FADE_IN_OUT_BALANCE_DEFAULT
			self.tweenInAlphaStart = tick()
		end
	end

	function DynamicThumbstick:DoMove(direction)
		local currentMoveVector = direction

		local inputAxisMagnitude = currentMoveVector.magnitude
		if inputAxisMagnitude < self.radiusOfDeadZone then
			currentMoveVector = ZERO_VECTOR3
		else
			currentMoveVector = currentMoveVector.unit*(
				1 - math.max(0, (self.radiusOfMaxSpeed - currentMoveVector.magnitude)/self.radiusOfMaxSpeed)
			)
			currentMoveVector = Vector3.new(currentMoveVector.x, 0, currentMoveVector.y)
		end

		self.moveVector = currentMoveVector
	end


	function DynamicThumbstick:LayoutMiddleImages(startPos, endPos)
		local startDist = (self.thumbstickSize / 2) + self.middleSize
		local vector = endPos - startPos
		local distAvailable = vector.magnitude - (self.thumbstickRingSize / 2) - self.middleSize
		local direction = vector.unit

		local distNeeded = self.middleSpacing * NUM_MIDDLE_IMAGES
		local spacing = self.middleSpacing

		if distNeeded < distAvailable then
			spacing = distAvailable / NUM_MIDDLE_IMAGES
		end

		for i = 1, NUM_MIDDLE_IMAGES do
			local image = self.middleImages[i]
			local distWithout = startDist + (spacing * (i - 2))
			local currentDist = startDist + (spacing * (i - 1))

			if distWithout < distAvailable then
				local pos = endPos - direction * currentDist
				local exposedFraction = math.clamp(1 - ((currentDist - distAvailable) / spacing), 0, 1)

				image.Visible = true
				image.Position = UDim2.new(0, pos.X, 0, pos.Y)
				image.Size = UDim2.new(0, self.middleSize * exposedFraction, 0, self.middleSize * exposedFraction)
			else
				image.Visible = false
			end
		end
	end

	function DynamicThumbstick:MoveStick(pos)
		local vector2StartPosition = Vector2.new(self.moveTouchStartPosition.X, self.moveTouchStartPosition.Y)
		local startPos = vector2StartPosition - self.thumbstickFrame.AbsolutePosition
		local endPos = Vector2.new(pos.X, pos.Y) - self.thumbstickFrame.AbsolutePosition
		self.endImage.Position = UDim2.new(0, endPos.X, 0, endPos.Y)
		self:LayoutMiddleImages(startPos, endPos)
	end

	function DynamicThumbstick:BindContextActions()
		local function inputBegan(inputObject)
			if self.moveTouchObject then
				return Enum.ContextActionResult.Pass
			end

			if not self:InputInFrame(inputObject) then
				return Enum.ContextActionResult.Pass
			end

			if self.isFirstTouch then
				self.isFirstTouch = false
				local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out,0,false,0)
				TweenService:Create(self.startImage, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
				TweenService:Create(
					self.endImage,
					tweenInfo,
					{Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize), ImageColor3 = Color3.new(0,0,0)}
				):Play()
			end

			self.moveTouchLockedIn = false
			self.moveTouchObject = inputObject
			self.moveTouchStartPosition = inputObject.Position
			self.moveTouchFirstChanged = true

			if FADE_IN_OUT_BACKGROUND then
				self:DoFadeInBackground()
			end

			return Enum.ContextActionResult.Pass
		end

		local function inputChanged(inputObject)
			if inputObject == self.moveTouchObject then
				if self.moveTouchFirstChanged then
					self.moveTouchFirstChanged = false

					local startPosVec2 = Vector2.new(
						inputObject.Position.X - self.thumbstickFrame.AbsolutePosition.X,
						inputObject.Position.Y - self.thumbstickFrame.AbsolutePosition.Y
					)
					self.startImage.Visible = true
					self.startImage.Position = UDim2.new(0, startPosVec2.X, 0, startPosVec2.Y)
					self.endImage.Visible = true
					self.endImage.Position = self.startImage.Position

					self:FadeThumbstick(true)
					self:MoveStick(inputObject.Position)
				end

				self.moveTouchLockedIn = true

				local direction = Vector2.new(
					inputObject.Position.x - self.moveTouchStartPosition.x,
					inputObject.Position.y - self.moveTouchStartPosition.y
				)
				if math.abs(direction.x) > 0 or math.abs(direction.y) > 0 then
					self:DoMove(direction)
					self:MoveStick(inputObject.Position)
				end
				return Enum.ContextActionResult.Sink
			end
			return Enum.ContextActionResult.Pass
		end

		local function inputEnded(inputObject)
			if inputObject == self.moveTouchObject then
				self:OnInputEnded()
				if self.moveTouchLockedIn then
					return Enum.ContextActionResult.Sink
				end
			end
			return Enum.ContextActionResult.Pass
		end

		local function handleInput(actionName, inputState, inputObject)
			if inputState == Enum.UserInputState.Begin then
				return inputBegan(inputObject)
			elseif inputState == Enum.UserInputState.Change then
				return inputChanged(inputObject)
			elseif inputState == Enum.UserInputState.End then
				return inputEnded(inputObject)
			elseif inputState == Enum.UserInputState.Cancel then
				self:OnInputEnded()
			end
		end

		ContextActionService:BindActionAtPriority(
			DYNAMIC_THUMBSTICK_ACTION_NAME,
			handleInput,
			false,
			DYNAMIC_THUMBSTICK_ACTION_PRIORITY,
			Enum.UserInputType.Touch)
	end

	function DynamicThumbstick:Create(parentFrame)
		if self.thumbstickFrame then
			self.thumbstickFrame:Destroy()
			self.thumbstickFrame = nil
			if self.onRenderSteppedConn then
				self.onRenderSteppedConn:Disconnect()
				self.onRenderSteppedConn = nil
			end
		end

		self.thumbstickSize = 45
		self.thumbstickRingSize = 20
		self.middleSize = 10
		self.middleSpacing = self.middleSize + 4
		self.radiusOfDeadZone = 2
		self.radiusOfMaxSpeed = 20

		local screenSize = parentFrame.AbsoluteSize
		local isBigScreen = math.min(screenSize.x, screenSize.y) > 500
		if isBigScreen then
			self.thumbstickSize = self.thumbstickSize * 2
			self.thumbstickRingSize = self.thumbstickRingSize * 2
			self.middleSize = self.middleSize * 2
			self.middleSpacing = self.middleSpacing * 2
			self.radiusOfDeadZone = self.radiusOfDeadZone * 2
			self.radiusOfMaxSpeed = self.radiusOfMaxSpeed * 2
		end

		local function layoutThumbstickFrame(portraitMode)
			if portraitMode then
				self.thumbstickFrame.Size = UDim2.new(1, 0, 0.4, 0)
				self.thumbstickFrame.Position = UDim2.new(0, 0, 0.6, 0)
			else
				self.thumbstickFrame.Size = UDim2.new(0.4, 0, 2/3, 0)
				self.thumbstickFrame.Position = UDim2.new(0, 0, 1/3, 0)
			end
		end

		self.thumbstickFrame = Instance.new("Frame")
		self.thumbstickFrame.BorderSizePixel = 0
		self.thumbstickFrame.Name = "DynamicThumbstickFrame"
		self.thumbstickFrame.Visible = false
		self.thumbstickFrame.BackgroundTransparency = 1.0
		self.thumbstickFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		self.thumbstickFrame.Active = false
		layoutThumbstickFrame(false)

		self.startImage = Instance.new("ImageLabel")
		self.startImage.Name = "ThumbstickStart"
		self.startImage.Visible = true
		self.startImage.BackgroundTransparency = 1
		self.startImage.Image = TOUCH_CONTROLS_SHEET
		self.startImage.ImageRectOffset = Vector2.new(1,1)
		self.startImage.ImageRectSize = Vector2.new(144, 144)
		self.startImage.ImageColor3 = Color3.new(0, 0, 0)
		self.startImage.AnchorPoint = Vector2.new(0.5, 0.5)
		self.startImage.Position = UDim2.new(0, self.thumbstickRingSize * 3.3, 1, -self.thumbstickRingSize  * 2.8)
		self.startImage.Size = UDim2.new(0, self.thumbstickRingSize  * 3.7, 0, self.thumbstickRingSize  * 3.7)
		self.startImage.ZIndex = 10
		self.startImage.Parent = self.thumbstickFrame

		self.endImage = Instance.new("ImageLabel")
		self.endImage.Name = "ThumbstickEnd"
		self.endImage.Visible = true
		self.endImage.BackgroundTransparency = 1
		self.endImage.Image = TOUCH_CONTROLS_SHEET
		self.endImage.ImageRectOffset = Vector2.new(1,1)
		self.endImage.ImageRectSize =  Vector2.new(144, 144)
		self.endImage.AnchorPoint = Vector2.new(0.5, 0.5)
		self.endImage.Position = self.startImage.Position
		self.endImage.Size = UDim2.new(0, self.thumbstickSize * 0.8, 0, self.thumbstickSize * 0.8)
		self.endImage.ZIndex = 10
		self.endImage.Parent = self.thumbstickFrame

		for i = 1, NUM_MIDDLE_IMAGES do
			self.middleImages[i] = Instance.new("ImageLabel")
			self.middleImages[i].Name = "ThumbstickMiddle"
			self.middleImages[i].Visible = false
			self.middleImages[i].BackgroundTransparency = 1
			self.middleImages[i].Image = TOUCH_CONTROLS_SHEET
			self.middleImages[i].ImageRectOffset = Vector2.new(1,1)
			self.middleImages[i].ImageRectSize = Vector2.new(144, 144)
			self.middleImages[i].ImageTransparency = MIDDLE_TRANSPARENCIES[i]
			self.middleImages[i].AnchorPoint = Vector2.new(0.5, 0.5)
			self.middleImages[i].ZIndex = 9
			self.middleImages[i].Parent = self.thumbstickFrame
		end

		local CameraChangedConn = nil
		local function onCurrentCameraChanged()
			if CameraChangedConn then
				CameraChangedConn:Disconnect()
				CameraChangedConn = nil
			end
			local newCamera = workspace.CurrentCamera
			if newCamera then
				local function onViewportSizeChanged()
					local size = newCamera.ViewportSize
					local portraitMode = size.X < size.Y
					layoutThumbstickFrame(portraitMode)
				end
				CameraChangedConn = newCamera:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportSizeChanged)
				onViewportSizeChanged()
			end
		end
		workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCurrentCameraChanged)
		if workspace.CurrentCamera then
			onCurrentCameraChanged()
		end

		self.moveTouchStartPosition = nil

		self.startImageFadeTween = nil
		self.endImageFadeTween = nil
		self.middleImageFadeTweens = {}

		self.onRenderSteppedConn = RunService.RenderStepped:Connect(function()
			if self.tweenInAlphaStart ~= nil then
				local delta = tick() - self.tweenInAlphaStart
				local fadeInTime = (self.fadeInAndOutHalfDuration * 2 * self.fadeInAndOutBalance)
				self.thumbstickFrame.BackgroundTransparency = 1 - FADE_IN_OUT_MAX_ALPHA*math.min(delta/fadeInTime, 1)
				if delta > fadeInTime then
					self.tweenOutAlphaStart = tick()
					self.tweenInAlphaStart = nil
				end
			elseif self.tweenOutAlphaStart ~= nil then
				local delta = tick() - self.tweenOutAlphaStart
				local fadeOutTime = (self.fadeInAndOutHalfDuration * 2) - (self.fadeInAndOutHalfDuration * 2 * self.fadeInAndOutBalance)
				self.thumbstickFrame.BackgroundTransparency = 1 - FADE_IN_OUT_MAX_ALPHA + FADE_IN_OUT_MAX_ALPHA*math.min(delta/fadeOutTime, 1)
				if delta > fadeOutTime  then
					self.tweenOutAlphaStart = nil
				end
			end
		end)

		self.onTouchEndedConn = UserInputService.TouchEnded:connect(function(inputObject)
			if inputObject == self.moveTouchObject then
				self:OnInputEnded()
			end
		end)

		GuiService.MenuOpened:connect(function()
			if self.moveTouchObject then
				self:OnInputEnded()
			end
		end)

		local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		while not playerGui do
			LocalPlayer.ChildAdded:wait()
			playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		end

		local playerGuiChangedConn = nil
		local originalScreenOrientationWasLandscape =	playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeLeft or
			playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.LandscapeRight

		local function longShowBackground()
			self.fadeInAndOutHalfDuration = 2.5
			self.fadeInAndOutBalance = 0.05
			self.tweenInAlphaStart = tick()
		end

		playerGuiChangedConn = playerGui:GetPropertyChangedSignal("CurrentScreenOrientation"):Connect(function()
			if (originalScreenOrientationWasLandscape and playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait) or
				(not originalScreenOrientationWasLandscape and playerGui.CurrentScreenOrientation ~= Enum.ScreenOrientation.Portrait) then

				playerGuiChangedConn:disconnect()
				longShowBackground()

				if originalScreenOrientationWasLandscape then
					self.hasFadedBackgroundInPortrait = true
				else
					self.hasFadedBackgroundInLandscape = true
				end
			end
		end)

		self.thumbstickFrame.Parent = parentFrame

		if game:IsLoaded() then
			longShowBackground()
		else
			coroutine.wrap(function()
				game.Loaded:Wait()
				longShowBackground()
			end)()
		end
	end

	return DynamicThumbstick
end

function _Gamepad()
	local UserInputService = game:GetService("UserInputService")
	local ContextActionService = game:GetService("ContextActionService")

	local ZERO_VECTOR3 = Vector3.new(0,0,0)
	local NONE = Enum.UserInputType.None
	local thumbstickDeadzone = 0.2

	local BaseCharacterController = _BaseCharacterController()
	local Gamepad = setmetatable({}, BaseCharacterController)
	Gamepad.__index = Gamepad

	function Gamepad.new(CONTROL_ACTION_PRIORITY)
		local self = setmetatable(BaseCharacterController.new(), Gamepad)

		self.CONTROL_ACTION_PRIORITY = CONTROL_ACTION_PRIORITY

		self.forwardValue  = 0
		self.backwardValue = 0
		self.leftValue = 0
		self.rightValue = 0

		self.activeGamepad = NONE
		self.gamepadConnectedConn = nil
		self.gamepadDisconnectedConn = nil
		return self
	end

	function Gamepad:Enable(enable)
		if not UserInputService.GamepadEnabled then
			return false
		end

		if enable == self.enabled then
			return true
		end

		self.forwardValue  = 0
		self.backwardValue = 0
		self.leftValue = 0
		self.rightValue = 0
		self.moveVector = ZERO_VECTOR3
		self.isJumping = false

		if enable then
			self.activeGamepad = self:GetHighestPriorityGamepad()
			if self.activeGamepad ~= NONE then
				self:BindContextActions()
				self:ConnectGamepadConnectionListeners()
			else
				return false
			end
		else
			self:UnbindContextActions()
			self:DisconnectGamepadConnectionListeners()
			self.activeGamepad = NONE
		end

		self.enabled = enable
		return true
	end

	function Gamepad:GetHighestPriorityGamepad()
		local connectedGamepads = UserInputService:GetConnectedGamepads()
		local bestGamepad = NONE
		for _, gamepad in pairs(connectedGamepads) do
			if gamepad.Value < bestGamepad.Value then
				bestGamepad = gamepad
			end
		end
		return bestGamepad
	end

	function Gamepad:BindContextActions()

		if self.activeGamepad == NONE then
			return false
		end

		local handleJumpAction = function(actionName, inputState, inputObject)
			self.isJumping = (inputState == Enum.UserInputState.Begin)
			return Enum.ContextActionResult.Sink
		end

		local handleThumbstickInput = function(actionName, inputState, inputObject)

			if inputState == Enum.UserInputState.Cancel then
				self.moveVector = ZERO_VECTOR3
				return Enum.ContextActionResult.Sink
			end

			if self.activeGamepad ~= inputObject.UserInputType then
				return Enum.ContextActionResult.Pass
			end
			if inputObject.KeyCode ~= Enum.KeyCode.Thumbstick1 then return end

			if inputObject.Position.magnitude > thumbstickDeadzone then
				self.moveVector  =  Vector3.new(inputObject.Position.X, 0, -inputObject.Position.Y)
			else
				self.moveVector = ZERO_VECTOR3
			end
			return Enum.ContextActionResult.Sink
		end

		ContextActionService:BindActivate(self.activeGamepad, Enum.KeyCode.ButtonR2)
		ContextActionService:BindActionAtPriority("jumpAction", handleJumpAction, false,
			self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.ButtonA)
		ContextActionService:BindActionAtPriority("moveThumbstick", handleThumbstickInput, false,
			self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.Thumbstick1)

		return true
	end

	function Gamepad:UnbindContextActions()
		if self.activeGamepad ~= NONE then
			ContextActionService:UnbindActivate(self.activeGamepad, Enum.KeyCode.ButtonR2)
		end
		ContextActionService:UnbindAction("moveThumbstick")
		ContextActionService:UnbindAction("jumpAction")
	end

	function Gamepad:OnNewGamepadConnected()
		local bestGamepad = self:GetHighestPriorityGamepad()

		if bestGamepad == self.activeGamepad then
			return
		end

		if bestGamepad == NONE then
			warn("Gamepad:OnNewGamepadConnected found no connected gamepads")
			self:UnbindContextActions()
			return
		end

		if self.activeGamepad ~= NONE then
			self:UnbindContextActions()
		end

		self.activeGamepad = bestGamepad
		self:BindContextActions()
	end

	function Gamepad:OnCurrentGamepadDisconnected()
		if self.activeGamepad ~= NONE then
			ContextActionService:UnbindActivate(self.activeGamepad, Enum.KeyCode.ButtonR2)
		end

		local bestGamepad = self:GetHighestPriorityGamepad()

		if self.activeGamepad ~= NONE and bestGamepad == self.activeGamepad then
			warn("Gamepad:OnCurrentGamepadDisconnected found the supposedly disconnected gamepad in connectedGamepads.")
			self:UnbindContextActions()
			self.activeGamepad = NONE
			return
		end

		if bestGamepad == NONE then
			self:UnbindContextActions()
			self.activeGamepad = NONE
		else
			self.activeGamepad = bestGamepad
			ContextActionService:BindActivate(self.activeGamepad, Enum.KeyCode.ButtonR2)
		end
	end

	function Gamepad:ConnectGamepadConnectionListeners()
		self.gamepadConnectedConn = UserInputService.GamepadConnected:Connect(function(gamepadEnum)
			self:OnNewGamepadConnected()
		end)

		self.gamepadDisconnectedConn = UserInputService.GamepadDisconnected:Connect(function(gamepadEnum)
			if self.activeGamepad == gamepadEnum then
				self:OnCurrentGamepadDisconnected()
			end
		end)

	end

	function Gamepad:DisconnectGamepadConnectionListeners()
		if self.gamepadConnectedConn then
			self.gamepadConnectedConn:Disconnect()
			self.gamepadConnectedConn = nil
		end

		if self.gamepadDisconnectedConn then
			self.gamepadDisconnectedConn:Disconnect()
			self.gamepadDisconnectedConn = nil
		end
	end

	return Gamepad
end

function _Keyboard()

	local UserInputService = game:GetService("UserInputService")
	local ContextActionService = game:GetService("ContextActionService")

	local ZERO_VECTOR3 = Vector3.new(0,0,0)

	local BaseCharacterController = _BaseCharacterController()
	local Keyboard = setmetatable({}, BaseCharacterController)
	Keyboard.__index = Keyboard

	function Keyboard.new(CONTROL_ACTION_PRIORITY)
		local self = setmetatable(BaseCharacterController.new(), Keyboard)

		self.CONTROL_ACTION_PRIORITY = CONTROL_ACTION_PRIORITY

		self.textFocusReleasedConn = nil
		self.textFocusGainedConn = nil
		self.windowFocusReleasedConn = nil

		self.forwardValue  = 0
		self.backwardValue = 0
		self.leftValue = 0
		self.rightValue = 0

		self.jumpEnabled = true

		return self
	end

	function Keyboard:Enable(enable)
		if not UserInputService.KeyboardEnabled then
			return false
		end

		if enable == self.enabled then
			return true
		end

		self.forwardValue  = 0
		self.backwardValue = 0
		self.leftValue = 0
		self.rightValue = 0
		self.moveVector = ZERO_VECTOR3
		self.jumpRequested = false
		self:UpdateJump()

		if enable then
			self:BindContextActions()
			self:ConnectFocusEventListeners()
		else
			self:UnbindContextActions()
			self:DisconnectFocusEventListeners()
		end

		self.enabled = enable
		return true
	end

	function Keyboard:UpdateMovement(inputState)
		if inputState == Enum.UserInputState.Cancel then
			self.moveVector = ZERO_VECTOR3
		else
			self.moveVector = Vector3.new(self.leftValue + self.rightValue, 0, self.forwardValue + self.backwardValue)
		end
	end

	function Keyboard:UpdateJump()
		self.isJumping = self.jumpRequested
	end

	function Keyboard:BindContextActions()

		local handleMoveForward = function(actionName, inputState, inputObject)
			self.forwardValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
			self:UpdateMovement(inputState)
			return Enum.ContextActionResult.Pass
		end

		local handleMoveBackward = function(actionName, inputState, inputObject)
			self.backwardValue = (inputState == Enum.UserInputState.Begin) and 1 or 0
			self:UpdateMovement(inputState)
			return Enum.ContextActionResult.Pass
		end

		local handleMoveLeft = function(actionName, inputState, inputObject)
			self.leftValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
			self:UpdateMovement(inputState)
			return Enum.ContextActionResult.Pass
		end

		local handleMoveRight = function(actionName, inputState, inputObject)
			self.rightValue = (inputState == Enum.UserInputState.Begin) and 1 or 0
			self:UpdateMovement(inputState)
			return Enum.ContextActionResult.Pass
		end

		local handleJumpAction = function(actionName, inputState, inputObject)
			self.jumpRequested = self.jumpEnabled and (inputState == Enum.UserInputState.Begin)
			self:UpdateJump()
			return Enum.ContextActionResult.Pass
		end

		ContextActionService:BindActionAtPriority("moveForwardAction", handleMoveForward, false,
			self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterForward)
		ContextActionService:BindActionAtPriority("moveBackwardAction", handleMoveBackward, false,
			self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterBackward)
		ContextActionService:BindActionAtPriority("moveLeftAction", handleMoveLeft, false,
			self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterLeft)
		ContextActionService:BindActionAtPriority("moveRightAction", handleMoveRight, false,
			self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterRight)
		ContextActionService:BindActionAtPriority("jumpAction", handleJumpAction, false,
			self.CONTROL_ACTION_PRIORITY, Enum.PlayerActions.CharacterJump)
	end

	function Keyboard:UnbindContextActions()
		ContextActionService:UnbindAction("moveForwardAction")
		ContextActionService:UnbindAction("moveBackwardAction")
		ContextActionService:UnbindAction("moveLeftAction")
		ContextActionService:UnbindAction("moveRightAction")
		ContextActionService:UnbindAction("jumpAction")
	end

	function Keyboard:ConnectFocusEventListeners()
		local function onFocusReleased()
			self.moveVector = ZERO_VECTOR3
			self.forwardValue  = 0
			self.backwardValue = 0
			self.leftValue = 0
			self.rightValue = 0
			self.jumpRequested = false
			self:UpdateJump()
		end

		local function onTextFocusGained(textboxFocused)
			self.jumpRequested = false
			self:UpdateJump()
		end

		self.textFocusReleasedConn = UserInputService.TextBoxFocusReleased:Connect(onFocusReleased)
		self.textFocusGainedConn = UserInputService.TextBoxFocused:Connect(onTextFocusGained)
		self.windowFocusReleasedConn = UserInputService.WindowFocused:Connect(onFocusReleased)
	end

	function Keyboard:DisconnectFocusEventListeners()
		if self.textFocusReleasedCon then
			self.textFocusReleasedCon:Disconnect()
			self.textFocusReleasedCon = nil
		end
		if self.textFocusGainedConn then
			self.textFocusGainedConn:Disconnect()
			self.textFocusGainedConn = nil
		end
		if self.windowFocusReleasedConn then
			self.windowFocusReleasedConn:Disconnect()
			self.windowFocusReleasedConn = nil
		end
	end

	return Keyboard
end

function _ControlModule()
	local ControlModule = {}
	ControlModule.__index = ControlModule

	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local Workspace = game:GetService("Workspace")
	local UserGameSettings = UserSettings():GetService("UserGameSettings")

	local Keyboard = _Keyboard()
	local Gamepad = _Gamepad()
	local DynamicThumbstick = _DynamicThumbstick()

	local FFlagUserMakeThumbstickDynamic do
		local success, value = pcall(function()
			return UserSettings():IsUserFeatureEnabled("UserMakeThumbstickDynamic")
		end)
		FFlagUserMakeThumbstickDynamic = success and value
	end

	local TouchThumbstick = FFlagUserMakeThumbstickDynamic and DynamicThumbstick or _TouchThumbstick()

	local ClickToMove = _ClickToMoveController()
	local TouchJump = _TouchJump()

	local VehicleController = _VehicleController()

	local CONTROL_ACTION_PRIORITY = Enum.ContextActionPriority.Default.Value

	local movementEnumToModuleMap = {
		[Enum.TouchMovementMode.DPad] = DynamicThumbstick,
		[Enum.DevTouchMovementMode.DPad] = DynamicThumbstick,
		[Enum.TouchMovementMode.Thumbpad] = DynamicThumbstick,
		[Enum.DevTouchMovementMode.Thumbpad] = DynamicThumbstick,
		[Enum.TouchMovementMode.Thumbstick] = TouchThumbstick,
		[Enum.DevTouchMovementMode.Thumbstick] = TouchThumbstick,
		[Enum.TouchMovementMode.DynamicThumbstick] = DynamicThumbstick,
		[Enum.DevTouchMovementMode.DynamicThumbstick] = DynamicThumbstick,
		[Enum.TouchMovementMode.ClickToMove] = ClickToMove,
		[Enum.DevTouchMovementMode.ClickToMove] = ClickToMove,

		[Enum.TouchMovementMode.Default] = DynamicThumbstick,

		[Enum.ComputerMovementMode.Default] = Keyboard,
		[Enum.ComputerMovementMode.KeyboardMouse] = Keyboard,
		[Enum.DevComputerMovementMode.KeyboardMouse] = Keyboard,
		[Enum.DevComputerMovementMode.Scriptable] = nil,
		[Enum.ComputerMovementMode.ClickToMove] = ClickToMove,
		[Enum.DevComputerMovementMode.ClickToMove] = ClickToMove,
	}

	local computerInputTypeToModuleMap = {
		[Enum.UserInputType.Keyboard] = Keyboard,
		[Enum.UserInputType.MouseButton1] = Keyboard,
		[Enum.UserInputType.MouseButton2] = Keyboard,
		[Enum.UserInputType.MouseButton3] = Keyboard,
		[Enum.UserInputType.MouseWheel] = Keyboard,
		[Enum.UserInputType.MouseMovement] = Keyboard,
		[Enum.UserInputType.Gamepad1] = Gamepad,
		[Enum.UserInputType.Gamepad2] = Gamepad,
		[Enum.UserInputType.Gamepad3] = Gamepad,
		[Enum.UserInputType.Gamepad4] = Gamepad,
	}

	local lastInputType

	function ControlModule.new()
		local self = setmetatable({},ControlModule)

		self.controllers = {}

		self.activeControlModule = nil
		self.activeController = nil
		self.touchJumpController = nil
		self.moveFunction = Players.LocalPlayer.Move
		self.humanoid = nil
		self.lastInputType = Enum.UserInputType.None

		self.humanoidSeatedConn = nil
		self.vehicleController = nil

		self.touchControlFrame = nil

		self.vehicleController = VehicleController.new(CONTROL_ACTION_PRIORITY)

		Players.LocalPlayer.CharacterAdded:Connect(function(char) self:OnCharacterAdded(char) end)
		Players.LocalPlayer.CharacterRemoving:Connect(function(char) self:OnCharacterRemoving(char) end)
		if Players.LocalPlayer.Character then
			self:OnCharacterAdded(Players.LocalPlayer.Character)
		end

		RunService:BindToRenderStep("ControlScriptRenderstep", Enum.RenderPriority.Input.Value, function(dt)
			self:OnRenderStepped(dt)
		end)

		UserInputService.LastInputTypeChanged:Connect(function(newLastInputType)
			self:OnLastInputTypeChanged(newLastInputType)
		end)


		UserGameSettings:GetPropertyChangedSignal("TouchMovementMode"):Connect(function()
			self:OnTouchMovementModeChange()
		end)
		Players.LocalPlayer:GetPropertyChangedSignal("DevTouchMovementMode"):Connect(function()
			self:OnTouchMovementModeChange()
		end)

		UserGameSettings:GetPropertyChangedSignal("ComputerMovementMode"):Connect(function()
			self:OnComputerMovementModeChange()
		end)
		Players.LocalPlayer:GetPropertyChangedSignal("DevComputerMovementMode"):Connect(function()
			self:OnComputerMovementModeChange()
		end)

		self.playerGui = nil
		self.touchGui = nil
		self.playerGuiAddedConn = nil

		if UserInputService.TouchEnabled then
			self.playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
			if self.playerGui then
				self:CreateTouchGuiContainer()
				self:OnLastInputTypeChanged(UserInputService:GetLastInputType())
			else
				self.playerGuiAddedConn = Players.LocalPlayer.ChildAdded:Connect(function(child)
					if child:IsA("PlayerGui") then
						self.playerGui = child
						self:CreateTouchGuiContainer()
						self.playerGuiAddedConn:Disconnect()
						self.playerGuiAddedConn = nil
						self:OnLastInputTypeChanged(UserInputService:GetLastInputType())
					end
				end)
			end
		else
			self:OnLastInputTypeChanged(UserInputService:GetLastInputType())
		end

		return self
	end

	function ControlModule:GetMoveVector()
		if self.activeController then
			return self.activeController:GetMoveVector()
		end
		return Vector3.new(0,0,0)
	end

	function ControlModule:GetActiveController()
		return self.activeController
	end

	function ControlModule:EnableActiveControlModule()
		if self.activeControlModule == ClickToMove then
			self.activeController:Enable(
				true,
				Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.UserChoice,
				self.touchJumpController
			)
		elseif self.touchControlFrame then
			self.activeController:Enable(true, self.touchControlFrame)
		else
			self.activeController:Enable(true)
		end
	end

	function ControlModule:Enable(enable)
		if not self.activeController then
			return
		end

		if enable == nil then
			enable = true
		end
		if enable then
			self:EnableActiveControlModule()
		else
			self:Disable()
		end
	end

	function ControlModule:Disable()
		if self.activeController then
			self.activeController:Enable(false)

			if self.moveFunction then
				self.moveFunction(Players.LocalPlayer, Vector3.new(0,0,0), true)
			end
		end
	end


	function ControlModule:SelectComputerMovementModule()
		if not (UserInputService.KeyboardEnabled or UserInputService.GamepadEnabled) then
			return nil, false
		end

		local computerModule
		local DevMovementMode = Players.LocalPlayer.DevComputerMovementMode

		if DevMovementMode == Enum.DevComputerMovementMode.UserChoice then
			computerModule = computerInputTypeToModuleMap[lastInputType]
			if UserGameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove and computerModule == Keyboard then
				computerModule = ClickToMove
			end
		else
			computerModule = movementEnumToModuleMap[DevMovementMode]

			if (not computerModule) and DevMovementMode ~= Enum.DevComputerMovementMode.Scriptable then
				warn("No character control module is associated with DevComputerMovementMode ", DevMovementMode)
			end
		end

		if computerModule then
			return computerModule, true
		elseif DevMovementMode == Enum.DevComputerMovementMode.Scriptable then
			return nil, true
		else
			return nil, false
		end
	end

	function ControlModule:SelectTouchModule()
		if not UserInputService.TouchEnabled then
			return nil, false
		end
		local touchModule
		local DevMovementMode = Players.LocalPlayer.DevTouchMovementMode
		if DevMovementMode == Enum.DevTouchMovementMode.UserChoice then
			touchModule = movementEnumToModuleMap[UserGameSettings.TouchMovementMode]
		elseif DevMovementMode == Enum.DevTouchMovementMode.Scriptable then
			return nil, true
		else
			touchModule = movementEnumToModuleMap[DevMovementMode]
		end
		return touchModule, true
	end

	local function calculateRawMoveVector(humanoid, cameraRelativeMoveVector)
		local camera = Workspace.CurrentCamera
		if not camera then
			return cameraRelativeMoveVector
		end

		if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
			return camera.CFrame:VectorToWorldSpace(cameraRelativeMoveVector)
		end

		local c, s
		local _, _, _, R00, R01, R02, _, _, R12, _, _, R22 = camera.CFrame:GetComponents()
		if R12 < 1 and R12 > -1 then
			c = R22
			s = R02
		else
			c = R00
			s = -R01*math.sign(R12)
		end
		local norm = math.sqrt(c*c + s*s)
		return Vector3.new(
			(c*cameraRelativeMoveVector.x + s*cameraRelativeMoveVector.z)/norm,
			0,
			(c*cameraRelativeMoveVector.z - s*cameraRelativeMoveVector.x)/norm
		)
	end

	function ControlModule:OnRenderStepped(dt)
		if self.activeController and self.activeController.enabled and self.humanoid then
			self.activeController:OnRenderStepped(dt)

			local moveVector = self.activeController:GetMoveVector()
			local cameraRelative = self.activeController:IsMoveVectorCameraRelative()

			local clickToMoveController = self:GetClickToMoveController()
			if self.activeController ~= clickToMoveController then
				if moveVector.magnitude > 0 then
					clickToMoveController:CleanupPath()
				else
					clickToMoveController:OnRenderStepped(dt)
					moveVector = clickToMoveController:GetMoveVector()
					cameraRelative = clickToMoveController:IsMoveVectorCameraRelative()
				end
			end

			local vehicleConsumedInput = false
			if self.vehicleController then
				moveVector, vehicleConsumedInput = self.vehicleController:Update(moveVector, cameraRelative, self.activeControlModule==Gamepad)
			end

			if cameraRelative then
				moveVector = calculateRawMoveVector(self.humanoid, moveVector)
			end
			self.moveFunction(Players.LocalPlayer, moveVector, false)

			self.humanoid.Jump = self.activeController:GetIsJumping() or (self.touchJumpController and self.touchJumpController:GetIsJumping())
		end
	end

	function ControlModule:OnHumanoidSeated(active, currentSeatPart)
		if active then
			if currentSeatPart and currentSeatPart:IsA("VehicleSeat") then
				if not self.vehicleController then
					self.vehicleController = self.vehicleController.new(CONTROL_ACTION_PRIORITY)
				end
				self.vehicleController:Enable(true, currentSeatPart)
			end
		else
			if self.vehicleController then
				self.vehicleController:Enable(false, currentSeatPart)
			end
		end
	end

	function ControlModule:OnCharacterAdded(char)
		self.humanoid = char:FindFirstChildOfClass("Humanoid")
		while not self.humanoid do
			char.ChildAdded:wait()
			self.humanoid = char:FindFirstChildOfClass("Humanoid")
		end

		if self.touchGui then
			self.touchGui.Enabled = true
		end

		if self.humanoidSeatedConn then
			self.humanoidSeatedConn:Disconnect()
			self.humanoidSeatedConn = nil
		end
		self.humanoidSeatedConn = self.humanoid.Seated:Connect(function(active, currentSeatPart)
			self:OnHumanoidSeated(active, currentSeatPart)
		end)
	end

	function ControlModule:OnCharacterRemoving(char)
		self.humanoid = nil

		if self.touchGui then
			self.touchGui.Enabled = false
		end
	end

	function ControlModule:SwitchToController(controlModule)
		if not controlModule then
			if self.activeController then
				self.activeController:Enable(false)
			end
			self.activeController = nil
			self.activeControlModule = nil
		else
			if not self.controllers[controlModule] then
				self.controllers[controlModule] = controlModule.new(CONTROL_ACTION_PRIORITY)
			end

			if self.activeController ~= self.controllers[controlModule] then
				if self.activeController then
					self.activeController:Enable(false)
				end
				self.activeController = self.controllers[controlModule]
				self.activeControlModule = controlModule

				if self.touchControlFrame and (self.activeControlModule == ClickToMove
					or self.activeControlModule == TouchThumbstick
					or self.activeControlModule == DynamicThumbstick) then
					if not self.controllers[TouchJump] then
						self.controllers[TouchJump] = TouchJump.new()
					end
					self.touchJumpController = self.controllers[TouchJump]
					self.touchJumpController:Enable(true, self.touchControlFrame)
				else
					if self.touchJumpController then
						self.touchJumpController:Enable(false)
					end
				end

				self:EnableActiveControlModule()
			end
		end
	end

	function ControlModule:OnLastInputTypeChanged(newLastInputType)
		if lastInputType == newLastInputType then
			warn("LastInputType Change listener called with current type.")
		end
		lastInputType = newLastInputType

		if lastInputType == Enum.UserInputType.Touch then
			local touchModule, success = self:SelectTouchModule()
			if success then
				while not self.touchControlFrame do
					wait()
				end
				self:SwitchToController(touchModule)
			end
		elseif computerInputTypeToModuleMap[lastInputType] ~= nil then
			local computerModule = self:SelectComputerMovementModule()
			if computerModule then
				self:SwitchToController(computerModule)
			end
		end
	end

	function ControlModule:OnComputerMovementModeChange()
		local controlModule, success =  self:SelectComputerMovementModule()
		if success then
			self:SwitchToController(controlModule)
		end
	end

	function ControlModule:OnTouchMovementModeChange()
		local touchModule, success = self:SelectTouchModule()
		if success then
			while not self.touchControlFrame do
				wait()
			end
			self:SwitchToController(touchModule)
		end
	end

	function ControlModule:CreateTouchGuiContainer()
		if self.touchGui then self.touchGui:Destroy() end
		
		local TouchGui = self.playerGui:FindFirstChild("TouchGui")
		if TouchGui then
			TouchGui:Destroy()
		end
		
		self.touchGui = Instance.new("ScreenGui")
		self.touchGui.Name = "TouchGui"
		self.touchGui.ResetOnSpawn = false
		self.touchGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		self.touchGui.Enabled = self.humanoid ~= nil

		self.touchControlFrame = Instance.new("Frame")
		self.touchControlFrame.Name = "TouchControlFrame"
		self.touchControlFrame.Size = UDim2.new(1, 0, 1, 0)
		self.touchControlFrame.BackgroundTransparency = 1
		self.touchControlFrame.Parent = self.touchGui

		self.touchGui.Parent = self.playerGui
		
	end

	function ControlModule:GetClickToMoveController()
		if not self.controllers[ClickToMove] then
			self.controllers[ClickToMove] = ClickToMove.new(CONTROL_ACTION_PRIORITY)
		end
		return self.controllers[ClickToMove]
	end

	function ControlModule:IsJumping()
		if self.activeController then
			return self.activeController:GetIsJumping() or (self.touchJumpController and self.touchJumpController:GetIsJumping())
		end
		return false
	end

	return ControlModule.new()
end

function _PlayerModule()
	local PlayerModule = {}
	PlayerModule.__index = PlayerModule
	function PlayerModule.new()
		local self = setmetatable({},PlayerModule)
		self.controls = _ControlModule()
		return self
	end
	function PlayerModule:GetControls()
		return self.controls
	end
	function PlayerModule:GetClickToMoveController()
		return self.controls:GetClickToMoveController()
	end
	return PlayerModule.new()
end

function _sounds()

	local SetState = Instance.new("BindableEvent",script)

	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")

	local SOUND_DATA = {
		Climbing = {
			SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3",
			Looped = true,
		},
		Died = {
			SoundId = "rbxasset://sounds/uuhhh.mp3",
		},
		FreeFalling = {
			SoundId = "rbxasset://sounds/action_falling.mp3",
			Looped = true,
		},
		GettingUp = {
			SoundId = "rbxasset://sounds/action_get_up.mp3",
		},
		Jumping = {
			SoundId = "rbxasset://sounds/action_jump.mp3",
		},
		Landing = {
			SoundId = "rbxasset://sounds/action_jump_land.mp3",
		},
		Running = {
			SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3",
			Looped = true,
			Pitch = 1.85,
		},
		Splash = {
			SoundId = "rbxasset://sounds/impact_water.mp3",
		},
		Swimming = {
			SoundId = "rbxasset://sounds/action_swim.mp3",
			Looped = true,
			Pitch = 1.6,
		},
	}

	local function waitForFirst(...)
		local shunt = Instance.new("BindableEvent")
		local slots = {...}

		local function fire(...)
			for i = 1, #slots do
				slots[i]:Disconnect()
			end

			return shunt:Fire(...)
		end

		for i = 1, #slots do
			slots[i] = slots[i]:Connect(fire)
		end

		return shunt.Event:Wait()
	end

	local function map(x, inMin, inMax, outMin, outMax)
		return (x - inMin)*(outMax - outMin)/(inMax - inMin) + outMin
	end

	local function playSound(sound)
		sound.TimePosition = 0
		sound.Playing = true
	end

	local function stopSound(sound)
		sound.Playing = false
		sound.TimePosition = 0
	end

	local function shallowCopy(t)
		local out = {}
		for k, v in pairs(t) do
			out[k] = v
		end
		return out
	end

	local function initializeSoundSystem(player, humanoid, rootPart)
		local sounds = {}

		for name, props in pairs(SOUND_DATA) do
			local sound = Instance.new("Sound")
			sound.Name = name

			sound.Archivable = false
			sound.EmitterSize = 5
			sound.MaxDistance = 150
			sound.Volume = 0.65

			for propName, propValue in pairs(props) do
				sound[propName] = propValue
			end

			sound.Parent = rootPart
			sounds[name] = sound
		end

		local playingLoopedSounds = {}

		local function stopPlayingLoopedSounds(except)
			for sound in pairs(shallowCopy(playingLoopedSounds)) do
				if sound ~= except then
					sound.Playing = false
					playingLoopedSounds[sound] = nil
				end
			end
		end

		local stateTransitions = {
			[Enum.HumanoidStateType.FallingDown] = function()
				stopPlayingLoopedSounds()
			end,

			[Enum.HumanoidStateType.GettingUp] = function()
				stopPlayingLoopedSounds()
				playSound(sounds.GettingUp)
			end,

			[Enum.HumanoidStateType.Jumping] = function()
				stopPlayingLoopedSounds()
				playSound(sounds.Jumping)
			end,

			[Enum.HumanoidStateType.Swimming] = function()
				local verticalSpeed = math.abs(rootPart.Velocity.Y)
				if verticalSpeed > 0.1 then
					sounds.Splash.Volume = math.clamp(map(verticalSpeed, 100, 350, 0.28, 1), 0, 1)
					playSound(sounds.Splash)
				end
				stopPlayingLoopedSounds(sounds.Swimming)
				sounds.Swimming.Playing = true
				playingLoopedSounds[sounds.Swimming] = true
			end,

			[Enum.HumanoidStateType.Freefall] = function()
				sounds.FreeFalling.Volume = 0
				stopPlayingLoopedSounds(sounds.FreeFalling)
				playingLoopedSounds[sounds.FreeFalling] = true
			end,

			[Enum.HumanoidStateType.Landed] = function()
				stopPlayingLoopedSounds()
				local verticalSpeed = math.abs(rootPart.Velocity.Y)
				if verticalSpeed > 75 then
					sounds.Landing.Volume = math.clamp(map(verticalSpeed, 50, 100, 0, 1), 0, 1)
					playSound(sounds.Landing)
				end
			end,

			[Enum.HumanoidStateType.Running] = function()
				stopPlayingLoopedSounds(sounds.Running)
				sounds.Running.Playing = true
				playingLoopedSounds[sounds.Running] = true
			end,

			[Enum.HumanoidStateType.Climbing] = function()
				local sound = sounds.Climbing
				if math.abs(rootPart.Velocity.Y) > 0.1 then
					sound.Playing = true
					stopPlayingLoopedSounds(sound)
				else
					stopPlayingLoopedSounds()
				end
				playingLoopedSounds[sound] = true
			end,

			[Enum.HumanoidStateType.Seated] = function()
				stopPlayingLoopedSounds()
			end,

			[Enum.HumanoidStateType.Dead] = function()
				stopPlayingLoopedSounds()
				playSound(sounds.Died)
			end,
		}

		local loopedSoundUpdaters = {
			[sounds.Climbing] = function(dt, sound, vel)
				sound.Playing = vel.Magnitude > 0.1
			end,

			[sounds.FreeFalling] = function(dt, sound, vel)
				if vel.Magnitude > 75 then
					sound.Volume = math.clamp(sound.Volume + 0.9*dt, 0, 1)
				else
					sound.Volume = 0
				end
			end,

			[sounds.Running] = function(dt, sound, vel)
				sound.Playing = vel.Magnitude > 0.5 and humanoid.MoveDirection.Magnitude > 0.5
			end,
		}

		local stateRemap = {
			[Enum.HumanoidStateType.RunningNoPhysics] = Enum.HumanoidStateType.Running,
		}

		local activeState = stateRemap[humanoid:GetState()] or humanoid:GetState()
		local activeConnections = {}

		local stateChangedConn = humanoid.StateChanged:Connect(function(_, state)
			state = stateRemap[state] or state

			if state ~= activeState then
				local transitionFunc = stateTransitions[state]

				if transitionFunc then
					transitionFunc()
				end

				activeState = state
			end
		end)

		local customStateChangedConn = SetState.Event:Connect(function(state)
			state = stateRemap[state] or state

			if state ~= activeState then
				local transitionFunc = stateTransitions[state]

				if transitionFunc then
					transitionFunc()
				end

				activeState = state
			end
		end)

		local steppedConn = RunService.Stepped:Connect(function(_, worldDt)
			for sound in pairs(playingLoopedSounds) do
				local updater = loopedSoundUpdaters[sound]

				if updater then
					updater(worldDt, sound, rootPart.Velocity)
				end
			end
		end)

		local humanoidAncestryChangedConn
		local rootPartAncestryChangedConn
		local characterAddedConn

		local function terminate()
			stateChangedConn:Disconnect()
			customStateChangedConn:Disconnect()
			steppedConn:Disconnect()
			humanoidAncestryChangedConn:Disconnect()
			rootPartAncestryChangedConn:Disconnect()
			characterAddedConn:Disconnect()
		end

		humanoidAncestryChangedConn = humanoid.AncestryChanged:Connect(function(_, parent)
			if not parent then
				terminate()
			end
		end)

		rootPartAncestryChangedConn = rootPart.AncestryChanged:Connect(function(_, parent)
			if not parent then
				terminate()
			end
		end)

		characterAddedConn = player.CharacterAdded:Connect(terminate)
	end

	local function playerAdded(player)
		local function characterAdded(character)

			if not character.Parent then
				waitForFirst(character.AncestryChanged, player.CharacterAdded)
			end

			if player.Character ~= character or not character.Parent then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			while character:IsDescendantOf(game) and not humanoid do
				waitForFirst(character.ChildAdded, character.AncestryChanged, player.CharacterAdded)
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			if player.Character ~= character or not character:IsDescendantOf(game) then
				return
			end

			local rootPart = character:FindFirstChild("HumanoidRootPart")
			while character:IsDescendantOf(game) and not rootPart do
				waitForFirst(character.ChildAdded, character.AncestryChanged, humanoid.AncestryChanged, player.CharacterAdded)
				rootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if rootPart and humanoid:IsDescendantOf(game) and character:IsDescendantOf(game) and player.Character == character then
				initializeSoundSystem(player, humanoid, rootPart)
			end
		end

		if player.Character then
			characterAdded(player.Character)
		end
		player.CharacterAdded:Connect(characterAdded)
	end

	Players.PlayerAdded:Connect(playerAdded)
	for _, player in ipairs(Players:GetPlayers()) do
		playerAdded(player)
	end
	return SetState
end

function _StateTracker()
	local EPSILON = 0.1

	local SPEED = {
		["onRunning"] = true,
		["onClimbing"] = true
	}

	local INAIR = {
		["onFreeFall"] = true,
		["onJumping"] = true
	}

	local STATEMAP = {
		["onRunning"] = Enum.HumanoidStateType.Running,
		["onJumping"] = Enum.HumanoidStateType.Jumping,
		["onFreeFall"] = Enum.HumanoidStateType.Freefall
	}

	local StateTracker = {}
	StateTracker.__index = StateTracker

	function StateTracker.new(humanoid, soundState)
		local self = setmetatable({}, StateTracker)

		self.Humanoid = humanoid
		self.HRP = humanoid.RootPart

		self.Speed = 0
		self.State = "onRunning"
		self.Jumped = false
		self.JumpTick = tick()

		self.SoundState = soundState

		self._ChangedEvent = Instance.new("BindableEvent")
		self.Changed = self._ChangedEvent.Event

		return self
	end

	function StateTracker:Destroy()
		self._ChangedEvent:Destroy()
	end

	function StateTracker:RequestedJump()
		self.Jumped = true
		self.JumpTick = tick()
	end

	function StateTracker:OnStep(gravityUp, grounded, isMoving)
		local cVelocity = self.HRP.Velocity
		local gVelocity = cVelocity:Dot(gravityUp)

		local oldState, oldSpeed = self.State, self.Speed

		local newState
		local newSpeed = cVelocity.Magnitude

		if (not grounded) then
			if (gVelocity > 0) then
				if (self.Jumped) then
					newState = "onJumping"
				else
					newState = "onFreeFall"
				end
			else
				if (self.Jumped) then
					self.Jumped = false
				end
				newState = "onFreeFall"
			end
		else
			if (self.Jumped and tick() - self.JumpTick > 0.1) then
				self.Jumped = false
			end
			newSpeed = (cVelocity - gVelocity*gravityUp).Magnitude
			newState = "onRunning"
		end

		newSpeed = isMoving and newSpeed or 0

		if (oldState ~= newState or (SPEED[newState] and math.abs(oldSpeed - newSpeed) > EPSILON)) then
			self.State = newState
			self.Speed = newSpeed
			self.SoundState:Fire(STATEMAP[newState])
			self._ChangedEvent:Fire(self.State, self.Speed)
		end
	end

	return StateTracker
end
function _InitObjects()
	local model = game:GetObjects("rbxassetid://17267177523")[1]
	local SPHERE = model:WaitForChild("Sphere")
	local FLOOR = model:WaitForChild("Floor")
	local VFORCE = model:WaitForChild("VectorForce")
	local BGYRO = model:WaitForChild("BodyGyro")
	local function initObjects(self)
		local hrp = self.HRP
		local humanoid = self.Humanoid
		local sphere = SPHERE:Clone()
		sphere.Parent = self.Character
		local floor = FLOOR:Clone()
		floor.Parent = self.Character
		local isR15 = (humanoid.RigType == Enum.HumanoidRigType.R15)
		local height = isR15 and (humanoid.HipHeight + 0.05) or 2
		local weld = Instance.new("Weld")
		weld.C0 = CFrame.new(0, -height, 0.1)
		weld.Part0 = hrp
		weld.Part1 = sphere
		weld.Parent = sphere
		local weld2 = Instance.new("Weld")
		weld2.C0 = CFrame.new(0, -(height + 1.5), 0)
		weld2.Part0 = hrp
		weld2.Part1 = floor
		weld2.Parent = floor
		local gyro = BGYRO:Clone()
		gyro.CFrame = hrp.CFrame
		gyro.Parent = hrp
		local vForce = VFORCE:Clone()
		vForce.Attachment0 = isR15 and hrp:WaitForChild("RootRigAttachment") or hrp:WaitForChild("RootAttachment")
		vForce.Parent = hrp
		return sphere, gyro, vForce, floor
	end
	return initObjects
end
local plr = game.Players.LocalPlayer
local ms = plr:GetMouse()
local char
plr.CharacterAdded:Connect(function(c)
	char = c
end)

function _R6()
	function r6()
		local Figure = char
		local Torso = Figure:WaitForChild("Torso")
		local RightShoulder = Torso:WaitForChild("Right Shoulder")
		local LeftShoulder = Torso:WaitForChild("Left Shoulder")
		local RightHip = Torso:WaitForChild("Right Hip")
		local LeftHip = Torso:WaitForChild("Left Hip")
		local Neck = Torso:WaitForChild("Neck")
		local Humanoid = Figure:WaitForChild("Humanoid")
		local pose = "Standing"
		local currentAnim = ""
		local currentAnimInstance = nil
		local currentAnimTrack = nil
		local currentAnimKeyframeHandler = nil
		local currentAnimSpeed = 1.0
		local animTable = {}
		local animNames = {
			idle = 	{
				{ id = "http://www.roblox.com/asset/?id=180435571", weight = 9 },
				{ id = "http://www.roblox.com/asset/?id=180435792", weight = 1 }
			},
			walk = 	{
				{ id = "http://www.roblox.com/asset/?id=180426354", weight = 10 }
			},
			run = 	{
				{ id = "run.xml", weight = 10 }
			},
			jump = 	{
				{ id = "http://www.roblox.com/asset/?id=125750702", weight = 10 }
			},
			fall = 	{
				{ id = "http://www.roblox.com/asset/?id=180436148", weight = 10 }
			},
			climb = {
				{ id = "http://www.roblox.com/asset/?id=180436334", weight = 10 }
			},
			sit = 	{
				{ id = "http://www.roblox.com/asset/?id=178130996", weight = 10 }
			},
			toolnone = {
				{ id = "http://www.roblox.com/asset/?id=182393478", weight = 10 }
			},
			toolslash = {
				{ id = "http://www.roblox.com/asset/?id=129967390", weight = 10 }
			},
			toollunge = {
				{ id = "http://www.roblox.com/asset/?id=129967478", weight = 10 }
			},
			wave = {
				{ id = "http://www.roblox.com/asset/?id=128777973", weight = 10 }
			},
			point = {
				{ id = "http://www.roblox.com/asset/?id=128853357", weight = 10 }
			},
			dance1 = {
				{ id = "http://www.roblox.com/asset/?id=182435998", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=182491037", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=182491065", weight = 10 }
			},
			dance2 = {
				{ id = "http://www.roblox.com/asset/?id=182436842", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=182491248", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=182491277", weight = 10 }
			},
			dance3 = {
				{ id = "http://www.roblox.com/asset/?id=182436935", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=182491368", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=182491423", weight = 10 }
			},
			laugh = {
				{ id = "http://www.roblox.com/asset/?id=129423131", weight = 10 }
			},
			cheer = {
				{ id = "http://www.roblox.com/asset/?id=129423030", weight = 10 }
			},
		}
		local dances = {"dance1", "dance2", "dance3"}
		local emoteNames = { wave = false, point = false, dance1 = true, dance2 = true, dance3 = true, laugh = false, cheer = false}
		function configureAnimationSet(name, fileList)
			if (animTable[name] ~= nil) then
				for _, connection in pairs(animTable[name].connections) do
					connection:disconnect()
				end
			end
			animTable[name] = {}
			animTable[name].count = 0
			animTable[name].totalWeight = 0
			animTable[name].connections = {}
			local config = script:FindFirstChild(name)
			if (config ~= nil) then
				table.insert(animTable[name].connections, config.ChildAdded:connect(function(child) configureAnimationSet(name, fileList) end))
				table.insert(animTable[name].connections, config.ChildRemoved:connect(function(child) configureAnimationSet(name, fileList) end))
				local idx = 1
				for _, childPart in pairs(config:GetChildren()) do
					if (childPart:IsA("Animation")) then
						table.insert(animTable[name].connections, childPart.Changed:connect(function(property) configureAnimationSet(name, fileList) end))
						animTable[name][idx] = {}
						animTable[name][idx].anim = childPart
						local weightObject = childPart:FindFirstChild("Weight")
						if (weightObject == nil) then
							animTable[name][idx].weight = 1
						else
							animTable[name][idx].weight = weightObject.Value
						end
						animTable[name].count = animTable[name].count + 1
						animTable[name].totalWeight = animTable[name].totalWeight + animTable[name][idx].weight
						idx = idx + 1
					end
				end
			end
			if (animTable[name].count <= 0) then
				for idx, anim in pairs(fileList) do
					animTable[name][idx] = {}
					animTable[name][idx].anim = Instance.new("Animation")
					animTable[name][idx].anim.Name = name
					animTable[name][idx].anim.AnimationId = anim.id
					animTable[name][idx].weight = anim.weight
					animTable[name].count = animTable[name].count + 1
					animTable[name].totalWeight = animTable[name].totalWeight + anim.weight
				end
			end
		end
		function scriptChildModified(child)
			local fileList = animNames[child.Name]
			if (fileList ~= nil) then
				configureAnimationSet(child.Name, fileList)
			end
		end

		script.ChildAdded:connect(scriptChildModified)
		script.ChildRemoved:connect(scriptChildModified)


		for name, fileList in pairs(animNames) do
			configureAnimationSet(name, fileList)
		end


		local toolAnim = "None"
		local toolAnimTime = 0

		local jumpAnimTime = 0
		local jumpAnimDuration = 0.3

		local toolTransitionTime = 0.1
		local fallTransitionTime = 0.3
		local jumpMaxLimbVelocity = 0.75


		function stopAllAnimations()
			local oldAnim = currentAnim

			if (emoteNames[oldAnim] ~= nil and emoteNames[oldAnim] == false) then
				oldAnim = "idle"
			end

			currentAnim = ""
			currentAnimInstance = nil
			if (currentAnimKeyframeHandler ~= nil) then
				currentAnimKeyframeHandler:disconnect()
			end

			if (currentAnimTrack ~= nil) then
				currentAnimTrack:Stop()
				currentAnimTrack:Destroy()
				currentAnimTrack = nil
			end
			return oldAnim
		end

		function setAnimationSpeed(speed)
			if speed ~= currentAnimSpeed then
				currentAnimSpeed = speed
				currentAnimTrack:AdjustSpeed(currentAnimSpeed)
			end
		end

		function keyFrameReachedFunc(frameName)
			if (frameName == "End") then

				local repeatAnim = currentAnim
				if (emoteNames[repeatAnim] ~= nil and emoteNames[repeatAnim] == false) then
					repeatAnim = "idle"
				end

				local animSpeed = currentAnimSpeed
				playAnimation(repeatAnim, 0.0, Humanoid)
				setAnimationSpeed(animSpeed)
			end
		end

		function playAnimation(animName, transitionTime, humanoid)

			local roll = math.random(1, animTable[animName].totalWeight)
			local origRoll = roll
			local idx = 1
			while (roll > animTable[animName][idx].weight) do
				roll = roll - animTable[animName][idx].weight
				idx = idx + 1
			end
			local anim = animTable[animName][idx].anim

			if (anim ~= currentAnimInstance) then

				if (currentAnimTrack ~= nil) then
					currentAnimTrack:Stop(transitionTime)
					currentAnimTrack:Destroy()
				end

				currentAnimSpeed = 1.0

				currentAnimTrack = humanoid:LoadAnimation(anim)
				currentAnimTrack.Priority = Enum.AnimationPriority.Core

				currentAnimTrack:Play(transitionTime)
				currentAnim = animName
				currentAnimInstance = anim

				if (currentAnimKeyframeHandler ~= nil) then
					currentAnimKeyframeHandler:disconnect()
				end
				currentAnimKeyframeHandler = currentAnimTrack.KeyframeReached:connect(keyFrameReachedFunc)

			end

		end


		local toolAnimName = ""
		local toolAnimTrack = nil
		local toolAnimInstance = nil
		local currentToolAnimKeyframeHandler = nil

		function toolKeyFrameReachedFunc(frameName)
			if (frameName == "End") then
				playToolAnimation(toolAnimName, 0.0, Humanoid)
			end
		end


		function playToolAnimation(animName, transitionTime, humanoid, priority)

			local roll = math.random(1, animTable[animName].totalWeight)
			local origRoll = roll
			local idx = 1
			while (roll > animTable[animName][idx].weight) do
				roll = roll - animTable[animName][idx].weight
				idx = idx + 1
			end
			local anim = animTable[animName][idx].anim

			if (toolAnimInstance ~= anim) then

				if (toolAnimTrack ~= nil) then
					toolAnimTrack:Stop()
					toolAnimTrack:Destroy()
					transitionTime = 0
				end

				toolAnimTrack = humanoid:LoadAnimation(anim)
				if priority then
					toolAnimTrack.Priority = priority
				end

				toolAnimTrack:Play(transitionTime)
				toolAnimName = animName
				toolAnimInstance = anim

				currentToolAnimKeyframeHandler = toolAnimTrack.KeyframeReached:connect(toolKeyFrameReachedFunc)
			end
		end

		function stopToolAnimations()
			local oldAnim = toolAnimName

			if (currentToolAnimKeyframeHandler ~= nil) then
				currentToolAnimKeyframeHandler:disconnect()
			end

			toolAnimName = ""
			toolAnimInstance = nil
			if (toolAnimTrack ~= nil) then
				toolAnimTrack:Stop()
				toolAnimTrack:Destroy()
				toolAnimTrack = nil
			end


			return oldAnim
		end



		function onRunning(speed)
			if speed > 0.01 then
				playAnimation("walk", 0.1, Humanoid)
				if currentAnimInstance and currentAnimInstance.AnimationId == "http://www.roblox.com/asset/?id=180426354" then
					setAnimationSpeed(speed / 14.5)
				end
				pose = "Running"
			else
				if emoteNames[currentAnim] == nil then
					playAnimation("idle", 0.1, Humanoid)
					pose = "Standing"
				end
			end
		end

		function onDied()
			pose = "Dead"
		end

		function onJumping()
			playAnimation("jump", 0.1, Humanoid)
			jumpAnimTime = jumpAnimDuration
			pose = "Jumping"
		end

		function onClimbing(speed)
			playAnimation("climb", 0.1, Humanoid)
			setAnimationSpeed(speed / 12.0)
			pose = "Climbing"
		end

		function onGettingUp()
			pose = "GettingUp"
		end

		function onFreeFall()
			if (jumpAnimTime <= 0) then
				playAnimation("fall", fallTransitionTime, Humanoid)
			end
			pose = "FreeFall"
		end

		function onFallingDown()
			pose = "FallingDown"
		end

		function onSeated()
			pose = "Seated"
		end

		function onPlatformStanding()
			pose = "PlatformStanding"
		end

		function onSwimming(speed)
			if speed > 0 then
				pose = "Running"
			else
				pose = "Standing"
			end
		end

		function getTool()
			for _, kid in ipairs(Figure:GetChildren()) do
				if kid.className == "Tool" then return kid end
			end
			return nil
		end

		function getToolAnim(tool)
			for _, c in ipairs(tool:GetChildren()) do
				if c.Name == "toolanim" and c.className == "StringValue" then
					return c
				end
			end
			return nil
		end

		function animateTool()

			if (toolAnim == "None") then
				playToolAnimation("toolnone", toolTransitionTime, Humanoid, Enum.AnimationPriority.Idle)
				return
			end

			if (toolAnim == "Slash") then
				playToolAnimation("toolslash", 0, Humanoid, Enum.AnimationPriority.Action)
				return
			end

			if (toolAnim == "Lunge") then
				playToolAnimation("toollunge", 0, Humanoid, Enum.AnimationPriority.Action)
				return
			end
		end

		function moveSit()
			RightShoulder.MaxVelocity = 0.15
			LeftShoulder.MaxVelocity = 0.15
			RightShoulder:SetDesiredAngle(3.14 /2)
			LeftShoulder:SetDesiredAngle(-3.14 /2)
			RightHip:SetDesiredAngle(3.14 /2)
			LeftHip:SetDesiredAngle(-3.14 /2)
		end

		local lastTick = 0

		function move(time)
			local amplitude = 1
			local frequency = 1
			local deltaTime = time - lastTick
			lastTick = time

			local climbFudge = 0
			local setAngles = false

			if (jumpAnimTime > 0) then
				jumpAnimTime = jumpAnimTime - deltaTime
			end

			if (pose == "FreeFall" and jumpAnimTime <= 0) then
				playAnimation("fall", fallTransitionTime, Humanoid)
			elseif (pose == "Seated") then
				playAnimation("sit", 0.5, Humanoid)
				return
			elseif (pose == "Running") then
				playAnimation("walk", 0.1, Humanoid)
			elseif (pose == "Dead" or pose == "GettingUp" or pose == "FallingDown" or pose == "Seated" or pose == "PlatformStanding") then
				stopAllAnimations()
				amplitude = 0.1
				frequency = 1
				setAngles = true
			end

			if (setAngles) then
				local desiredAngle = amplitude * math.sin(time * frequency)

				RightShoulder:SetDesiredAngle(desiredAngle + climbFudge)
				LeftShoulder:SetDesiredAngle(desiredAngle - climbFudge)
				RightHip:SetDesiredAngle(-desiredAngle)
				LeftHip:SetDesiredAngle(-desiredAngle)
			end

			local tool = getTool()
			if tool and tool:FindFirstChild("Handle") then

				local animStringValueObject = getToolAnim(tool)

				if animStringValueObject then
					toolAnim = animStringValueObject.Value
					animStringValueObject.Parent = nil
					toolAnimTime = time + .3
				end

				if time > toolAnimTime then
					toolAnimTime = 0
					toolAnim = "None"
				end

				animateTool()
			else
				stopToolAnimations()
				toolAnim = "None"
				toolAnimInstance = nil
				toolAnimTime = 0
			end
		end


		local events = {}
		local eventHum = Humanoid

		local function onUnhook()
			for i = 1, #events do
				events[i]:Disconnect()
			end
			events = {}
		end

		local function onHook()
			onUnhook()

			pose = eventHum.Sit and "Seated" or "Standing"

			events = {
				eventHum.Died:connect(onDied),
				eventHum.Running:connect(onRunning),
				eventHum.Jumping:connect(onJumping),
				eventHum.Climbing:connect(onClimbing),
				eventHum.GettingUp:connect(onGettingUp),
				eventHum.FreeFalling:connect(onFreeFall),
				eventHum.FallingDown:connect(onFallingDown),
				eventHum.Seated:connect(onSeated),
				eventHum.PlatformStanding:connect(onPlatformStanding),
				eventHum.Swimming:connect(onSwimming)
			}
		end


		onHook()

		game:GetService("Players").LocalPlayer.Chatted:connect(function(msg)
			local emote = ""
			if msg == "/e dance" then
				emote = dances[math.random(1, #dances)]
			elseif (string.sub(msg, 1, 3) == "/e ") then
				emote = string.sub(msg, 4)
			elseif (string.sub(msg, 1, 7) == "/emote ") then
				emote = string.sub(msg, 8)
			end

			if (pose == "Standing" and emoteNames[emote] ~= nil) then
				playAnimation(emote, 0.1, Humanoid)
			end

		end)



		playAnimation("idle", 0.1, Humanoid)
		pose = "Standing"

		spawn(function()
			while Figure.Parent ~= nil do
				local _, time = wait(0.1)
				move(time)
			end
		end)

		return {
			onRunning = onRunning,
			onDied = onDied,
			onJumping = onJumping,
			onClimbing = onClimbing,
			onGettingUp = onGettingUp,
			onFreeFall = onFreeFall,
			onFallingDown = onFallingDown,
			onSeated = onSeated,
			onPlatformStanding = onPlatformStanding,
			onHook = onHook,
			onUnhook = onUnhook
		}

	end
	return r6()
end

function _R15()
	local function r15()

		local Character = char
		local Humanoid = Character:WaitForChild("Humanoid")
		local pose = "Standing"

		local userNoUpdateOnLoopSuccess, userNoUpdateOnLoopValue = pcall(function() return UserSettings():IsUserFeatureEnabled("UserNoUpdateOnLoop") end)
		local userNoUpdateOnLoop = userNoUpdateOnLoopSuccess and userNoUpdateOnLoopValue
		local userAnimationSpeedDampeningSuccess, userAnimationSpeedDampeningValue = pcall(function() return UserSettings():IsUserFeatureEnabled("UserAnimationSpeedDampening") end)
		local userAnimationSpeedDampening = userAnimationSpeedDampeningSuccess and userAnimationSpeedDampeningValue

		local animateScriptEmoteHookFlagExists, animateScriptEmoteHookFlagEnabled = pcall(function()
			return UserSettings():IsUserFeatureEnabled("UserAnimateScriptEmoteHook")
		end)
		local FFlagAnimateScriptEmoteHook = animateScriptEmoteHookFlagExists and animateScriptEmoteHookFlagEnabled

		local AnimationSpeedDampeningObject = script:FindFirstChild("ScaleDampeningPercent")
		local HumanoidHipHeight = 2

		local EMOTE_TRANSITION_TIME = 0.1

		local currentAnim = ""
		local currentAnimInstance = nil
		local currentAnimTrack = nil
		local currentAnimKeyframeHandler = nil
		local currentAnimSpeed = 1.0

		local runAnimTrack = nil
		local runAnimKeyframeHandler = nil

		local animTable = {}
		local animNames = {
			idle = 	{
				{ id = Character.Animate.idle.Animation1.AnimationId, weight = 1 },
				{ id = Character.Animate.idle.Animation1.AnimationId, weight = 1 },
				{ id = Character.Animate.idle.Animation2.AnimationId, weight = 9 }
			},
			walk = 	{
				{ id = Character.Animate.walk.WalkAnim.AnimationId, weight = 10 }
			},
			run = 	{
				{ id = Character.Animate.run.RunAnim.AnimationId, weight = 10 }
			},
			swim = 	{
				{ id = Character.Animate.swim.Swim.AnimationId, weight = 10 }
			},
			swimidle = 	{
				{ id = Character.Animate.swimidle.SwimIdle.AnimationId, weight = 10 }
			},
			jump = 	{
				{ id = Character.Animate.jump.JumpAnim.AnimationId, weight = 10 }
			},
			fall = 	{
				{ id = Character.Animate.fall.FallAnim.AnimationId, weight = 10 }
			},
			climb = {
				{ id = Character.Animate.climb.ClimbAnim.AnimationId, weight = 10 }
			},
			sit = 	{
				{ id = "http://www.roblox.com/asset/?id=2506281703", weight = 10 }
			},
			toolnone = {
				{ id = "http://www.roblox.com/asset/?id=507768375", weight = 10 }
			},
			toolslash = {
				{ id = "http://www.roblox.com/asset/?id=522635514", weight = 10 }
			},
			toollunge = {
				{ id = "http://www.roblox.com/asset/?id=522638767", weight = 10 }
			},
			wave = {
				{ id = "http://www.roblox.com/asset/?id=507770239", weight = 10 }
			},
			point = {
				{ id = "http://www.roblox.com/asset/?id=507770453", weight = 10 }
			},
			dance = {
				{ id = "http://www.roblox.com/asset/?id=507771019", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=507771955", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=507772104", weight = 10 }
			},
			dance2 = {
				{ id = "http://www.roblox.com/asset/?id=507776043", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=507776720", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=507776879", weight = 10 }
			},
			dance3 = {
				{ id = "http://www.roblox.com/asset/?id=507777268", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=507777451", weight = 10 },
				{ id = "http://www.roblox.com/asset/?id=507777623", weight = 10 }
			},
			laugh = {
				{ id = "http://www.roblox.com/asset/?id=507770818", weight = 10 }
			},
			cheer = {
				{ id = "http://www.roblox.com/asset/?id=507770677", weight = 10 }
			},
		}

		local emoteNames = { wave = false, point = false, dance = true, dance2 = true, dance3 = true, laugh = false, cheer = false}

		local PreloadAnimsUserFlag = false
		local PreloadedAnims = {}
		local successPreloadAnim, msgPreloadAnim = pcall(function()
			PreloadAnimsUserFlag = UserSettings():IsUserFeatureEnabled("UserPreloadAnimations")
		end)
		if not successPreloadAnim then
			PreloadAnimsUserFlag = false
		end

		math.randomseed(tick())

		function findExistingAnimationInSet(set, anim)
			if set == nil or anim == nil then
				return 0
			end

			for idx = 1, set.count, 1 do
				if set[idx].anim.AnimationId == anim.AnimationId then
					return idx
				end
			end

			return 0
		end

		function configureAnimationSet(name, fileList)
			if (animTable[name] ~= nil) then
				for _, connection in pairs(animTable[name].connections) do
					connection:disconnect()
				end
			end
			animTable[name] = {}
			animTable[name].count = 0
			animTable[name].totalWeight = 0
			animTable[name].connections = {}

			local allowCustomAnimations = true

			local success, msg = pcall(function() allowCustomAnimations = game:GetService("StarterPlayer").AllowCustomAnimations end)
			if not success then
				allowCustomAnimations = true
			end

			local config = script:FindFirstChild(name)
			if (allowCustomAnimations and config ~= nil) then
				table.insert(animTable[name].connections, config.ChildAdded:connect(function(child) configureAnimationSet(name, fileList) end))
				table.insert(animTable[name].connections, config.ChildRemoved:connect(function(child) configureAnimationSet(name, fileList) end))

				local idx = 0
				for _, childPart in pairs(config:GetChildren()) do
					if (childPart:IsA("Animation")) then
						local newWeight = 1
						local weightObject = childPart:FindFirstChild("Weight")
						if (weightObject ~= nil) then
							newWeight = weightObject.Value
						end
						animTable[name].count = animTable[name].count + 1
						idx = animTable[name].count
						animTable[name][idx] = {}
						animTable[name][idx].anim = childPart
						animTable[name][idx].weight = newWeight
						animTable[name].totalWeight = animTable[name].totalWeight + animTable[name][idx].weight
						table.insert(animTable[name].connections, childPart.Changed:connect(function(property) configureAnimationSet(name, fileList) end))
						table.insert(animTable[name].connections, childPart.ChildAdded:connect(function(property) configureAnimationSet(name, fileList) end))
						table.insert(animTable[name].connections, childPart.ChildRemoved:connect(function(property) configureAnimationSet(name, fileList) end))
					end
				end
			end

			if (animTable[name].count <= 0) then
				for idx, anim in pairs(fileList) do
					animTable[name][idx] = {}
					animTable[name][idx].anim = Instance.new("Animation")
					animTable[name][idx].anim.Name = name
					animTable[name][idx].anim.AnimationId = anim.id
					animTable[name][idx].weight = anim.weight
					animTable[name].count = animTable[name].count + 1
					animTable[name].totalWeight = animTable[name].totalWeight + anim.weight
				end
			end

			if PreloadAnimsUserFlag then
				for i, animType in pairs(animTable) do
					for idx = 1, animType.count, 1 do
						if PreloadedAnims[animType[idx].anim.AnimationId] == nil then
							Humanoid:LoadAnimation(animType[idx].anim)
							PreloadedAnims[animType[idx].anim.AnimationId] = true
						end
					end
				end
			end
		end


		function configureAnimationSetOld(name, fileList)
			if (animTable[name] ~= nil) then
				for _, connection in pairs(animTable[name].connections) do
					connection:disconnect()
				end
			end
			animTable[name] = {}
			animTable[name].count = 0
			animTable[name].totalWeight = 0
			animTable[name].connections = {}

			local allowCustomAnimations = true

			local success, msg = pcall(function() allowCustomAnimations = game:GetService("StarterPlayer").AllowCustomAnimations end)
			if not success then
				allowCustomAnimations = true
			end

			local config = script:FindFirstChild(name)
			if (allowCustomAnimations and config ~= nil) then
				table.insert(animTable[name].connections, config.ChildAdded:connect(function(child) configureAnimationSet(name, fileList) end))
				table.insert(animTable[name].connections, config.ChildRemoved:connect(function(child) configureAnimationSet(name, fileList) end))
				local idx = 1
				for _, childPart in pairs(config:GetChildren()) do
					if (childPart:IsA("Animation")) then
						table.insert(animTable[name].connections, childPart.Changed:connect(function(property) configureAnimationSet(name, fileList) end))
						animTable[name][idx] = {}
						animTable[name][idx].anim = childPart
						local weightObject = childPart:FindFirstChild("Weight")
						if (weightObject == nil) then
							animTable[name][idx].weight = 1
						else
							animTable[name][idx].weight = weightObject.Value
						end
						animTable[name].count = animTable[name].count + 1
						animTable[name].totalWeight = animTable[name].totalWeight + animTable[name][idx].weight
						idx = idx + 1
					end
				end
			end

			if (animTable[name].count <= 0) then
				for idx, anim in pairs(fileList) do
					animTable[name][idx] = {}
					animTable[name][idx].anim = Instance.new("Animation")
					animTable[name][idx].anim.Name = name
					animTable[name][idx].anim.AnimationId = anim.id
					animTable[name][idx].weight = anim.weight
					animTable[name].count = animTable[name].count + 1
					animTable[name].totalWeight = animTable[name].totalWeight + anim.weight
				end
			end

			if PreloadAnimsUserFlag then
				for i, animType in pairs(animTable) do
					for idx = 1, animType.count, 1 do
						Humanoid:LoadAnimation(animType[idx].anim)
					end
				end
			end
		end

		function scriptChildModified(child)
			local fileList = animNames[child.Name]
			if (fileList ~= nil) then
				configureAnimationSet(child.Name, fileList)
			end
		end

		script.ChildAdded:connect(scriptChildModified)
		script.ChildRemoved:connect(scriptChildModified)


		for name, fileList in pairs(animNames) do
			configureAnimationSet(name, fileList)
		end


		local toolAnim = "None"
		local toolAnimTime = 0

		local jumpAnimTime = 0
		local jumpAnimDuration = 0.31

		local toolTransitionTime = 0.1
		local fallTransitionTime = 0.2

		local currentlyPlayingEmote = false


		function stopAllAnimations()
			local oldAnim = currentAnim

			if (emoteNames[oldAnim] ~= nil and emoteNames[oldAnim] == false) then
				oldAnim = "idle"
			end

			if FFlagAnimateScriptEmoteHook and currentlyPlayingEmote then
				oldAnim = "idle"
				currentlyPlayingEmote = false
			end

			currentAnim = ""
			currentAnimInstance = nil
			if (currentAnimKeyframeHandler ~= nil) then
				currentAnimKeyframeHandler:disconnect()
			end

			if (currentAnimTrack ~= nil) then
				currentAnimTrack:Stop()
				currentAnimTrack:Destroy()
				currentAnimTrack = nil
			end

			if (runAnimKeyframeHandler ~= nil) then
				runAnimKeyframeHandler:disconnect()
			end

			if (runAnimTrack ~= nil) then
				runAnimTrack:Stop()
				runAnimTrack:Destroy()
				runAnimTrack = nil
			end

			return oldAnim
		end

		function getHeightScale()
			if Humanoid then
				if not Humanoid.AutomaticScalingEnabled then
					return 1
				end

				local scale = Humanoid.HipHeight / HumanoidHipHeight
				if userAnimationSpeedDampening then
					if AnimationSpeedDampeningObject == nil then
						AnimationSpeedDampeningObject = script:FindFirstChild("ScaleDampeningPercent")
					end
					if AnimationSpeedDampeningObject ~= nil then
						scale = 1 + (Humanoid.HipHeight - HumanoidHipHeight) * AnimationSpeedDampeningObject.Value / HumanoidHipHeight
					end
				end
				return scale
			end
			return 1
		end

		local smallButNotZero = 0.0001
		function setRunSpeed(speed)
			local speedScaled = speed * 1.25
			local heightScale = getHeightScale()
			local runSpeed = speedScaled / heightScale

			if runSpeed ~= currentAnimSpeed then
				if runSpeed < 0.33 then
					currentAnimTrack:AdjustWeight(1.0)
					runAnimTrack:AdjustWeight(smallButNotZero)
				elseif runSpeed < 0.66 then
					local weight = ((runSpeed - 0.33) / 0.33)
					currentAnimTrack:AdjustWeight(1.0 - weight + smallButNotZero)
					runAnimTrack:AdjustWeight(weight + smallButNotZero)
				else
					currentAnimTrack:AdjustWeight(smallButNotZero)
					runAnimTrack:AdjustWeight(1.0)
				end
				currentAnimSpeed = runSpeed
				runAnimTrack:AdjustSpeed(runSpeed)
				currentAnimTrack:AdjustSpeed(runSpeed)
			end
		end

		function setAnimationSpeed(speed)
			if currentAnim == "walk" then
				setRunSpeed(speed)
			else
				if speed ~= currentAnimSpeed then
					currentAnimSpeed = speed
					currentAnimTrack:AdjustSpeed(currentAnimSpeed)
				end
			end
		end

		function keyFrameReachedFunc(frameName)
			if (frameName == "End") then
				if currentAnim == "walk" then
					if userNoUpdateOnLoop == true then
						if runAnimTrack.Looped ~= true then
							runAnimTrack.TimePosition = 0.0
						end
						if currentAnimTrack.Looped ~= true then
							currentAnimTrack.TimePosition = 0.0
						end
					else
						runAnimTrack.TimePosition = 0.0
						currentAnimTrack.TimePosition = 0.0
					end
				else
					local repeatAnim = currentAnim
					if (emoteNames[repeatAnim] ~= nil and emoteNames[repeatAnim] == false) then
						repeatAnim = "idle"
					end

					if FFlagAnimateScriptEmoteHook and currentlyPlayingEmote then
						if currentAnimTrack.Looped then
							return
						end

						repeatAnim = "idle"
						currentlyPlayingEmote = false
					end

					local animSpeed = currentAnimSpeed
					playAnimation(repeatAnim, 0.15, Humanoid)
					setAnimationSpeed(animSpeed)
				end
			end
		end

		function rollAnimation(animName)
			local roll = math.random(1, animTable[animName].totalWeight)
			local origRoll = roll
			local idx = 1
			while (roll > animTable[animName][idx].weight) do
				roll = roll - animTable[animName][idx].weight
				idx = idx + 1
			end
			return idx
		end

		local function switchToAnim(anim, animName, transitionTime, humanoid)
			if (anim ~= currentAnimInstance) then

				if (currentAnimTrack ~= nil) then
					currentAnimTrack:Stop(transitionTime)
					currentAnimTrack:Destroy()
				end

				if (runAnimTrack ~= nil) then
					runAnimTrack:Stop(transitionTime)
					runAnimTrack:Destroy()
					if userNoUpdateOnLoop == true then
						runAnimTrack = nil
					end
				end

				currentAnimSpeed = 1.0

				currentAnimTrack = humanoid:LoadAnimation(anim)
				currentAnimTrack.Priority = Enum.AnimationPriority.Core

				currentAnimTrack:Play(transitionTime)
				currentAnim = animName
				currentAnimInstance = anim

				if (currentAnimKeyframeHandler ~= nil) then
					currentAnimKeyframeHandler:disconnect()
				end
				currentAnimKeyframeHandler = currentAnimTrack.KeyframeReached:connect(keyFrameReachedFunc)

				if animName == "walk" then
					local runAnimName = "run"
					local runIdx = rollAnimation(runAnimName)

					runAnimTrack = humanoid:LoadAnimation(animTable[runAnimName][runIdx].anim)
					runAnimTrack.Priority = Enum.AnimationPriority.Core
					runAnimTrack:Play(transitionTime)

					if (runAnimKeyframeHandler ~= nil) then
						runAnimKeyframeHandler:disconnect()
					end
					runAnimKeyframeHandler = runAnimTrack.KeyframeReached:connect(keyFrameReachedFunc)
				end
			end
		end

		function playAnimation(animName, transitionTime, humanoid)
			local idx = rollAnimation(animName)
			local anim = animTable[animName][idx].anim

			switchToAnim(anim, animName, transitionTime, humanoid)
			currentlyPlayingEmote = false
		end

		function playEmote(emoteAnim, transitionTime, humanoid)
			switchToAnim(emoteAnim, emoteAnim.Name, transitionTime, humanoid)
			currentlyPlayingEmote = true
		end


		local toolAnimName = ""
		local toolAnimTrack = nil
		local toolAnimInstance = nil
		local currentToolAnimKeyframeHandler = nil

		function toolKeyFrameReachedFunc(frameName)
			if (frameName == "End") then
				playToolAnimation(toolAnimName, 0.0, Humanoid)
			end
		end


		function playToolAnimation(animName, transitionTime, humanoid, priority)
			local idx = rollAnimation(animName)
			local anim = animTable[animName][idx].anim

			if (toolAnimInstance ~= anim) then

				if (toolAnimTrack ~= nil) then
					toolAnimTrack:Stop()
					toolAnimTrack:Destroy()
					transitionTime = 0
				end

				toolAnimTrack = humanoid:LoadAnimation(anim)
				if priority then
					toolAnimTrack.Priority = priority
				end

				toolAnimTrack:Play(transitionTime)
				toolAnimName = animName
				toolAnimInstance = anim

				currentToolAnimKeyframeHandler = toolAnimTrack.KeyframeReached:connect(toolKeyFrameReachedFunc)
			end
		end

		function stopToolAnimations()
			local oldAnim = toolAnimName

			if (currentToolAnimKeyframeHandler ~= nil) then
				currentToolAnimKeyframeHandler:disconnect()
			end

			toolAnimName = ""
			toolAnimInstance = nil
			if (toolAnimTrack ~= nil) then
				toolAnimTrack:Stop()
				toolAnimTrack:Destroy()
				toolAnimTrack = nil
			end

			return oldAnim
		end


		function onRunning(speed)
			if speed > 0.75 then
				local scale = 16.0
				playAnimation("walk", 0.2, Humanoid)
				setAnimationSpeed(speed / scale)
				pose = "Running"
			else
				if emoteNames[currentAnim] == nil and not currentlyPlayingEmote then
					playAnimation("idle", 0.2, Humanoid)
					pose = "Standing"
				end
			end
		end

		function onDied()
			pose = "Dead"
		end

		function onJumping()
			playAnimation("jump", 0.1, Humanoid)
			jumpAnimTime = jumpAnimDuration
			pose = "Jumping"
		end

		function onClimbing(speed)
			local scale = 5.0
			playAnimation("climb", 0.1, Humanoid)
			setAnimationSpeed(speed / scale)
			pose = "Climbing"
		end

		function onGettingUp()
			pose = "GettingUp"
		end

		function onFreeFall()
			if (jumpAnimTime <= 0) then
				playAnimation("fall", fallTransitionTime, Humanoid)
			end
			pose = "FreeFall"
		end

		function onFallingDown()
			pose = "FallingDown"
		end

		function onSeated()
			pose = "Seated"
		end

		function onPlatformStanding()
			pose = "PlatformStanding"
		end


		function onSwimming(speed)
			if speed > 1.00 then
				local scale = 10.0
				playAnimation("swim", 0.4, Humanoid)
				setAnimationSpeed(speed / scale)
				pose = "Swimming"
			else
				playAnimation("swimidle", 0.4, Humanoid)
				pose = "Standing"
			end
		end

		function animateTool()
			if (toolAnim == "None") then
				playToolAnimation("toolnone", toolTransitionTime, Humanoid, Enum.AnimationPriority.Idle)
				return
			end

			if (toolAnim == "Slash") then
				playToolAnimation("toolslash", 0, Humanoid, Enum.AnimationPriority.Action)
				return
			end

			if (toolAnim == "Lunge") then
				playToolAnimation("toollunge", 0, Humanoid, Enum.AnimationPriority.Action)
				return
			end
		end

		function getToolAnim(tool)
			for _, c in ipairs(tool:GetChildren()) do
				if c.Name == "toolanim" and c.className == "StringValue" then
					return c
				end
			end
			return nil
		end

		local lastTick = 0

		function stepAnimate(currentTime)
			local amplitude = 1
			local frequency = 1
			local deltaTime = currentTime - lastTick
			lastTick = currentTime

			local climbFudge = 0
			local setAngles = false

			if (jumpAnimTime > 0) then
				jumpAnimTime = jumpAnimTime - deltaTime
			end

			if (pose == "FreeFall" and jumpAnimTime <= 0) then
				playAnimation("fall", fallTransitionTime, Humanoid)
			elseif (pose == "Seated") then
				playAnimation("sit", 0.5, Humanoid)
				return
			elseif (pose == "Running") then
				playAnimation("walk", 0.2, Humanoid)
			elseif (pose == "Dead" or pose == "GettingUp" or pose == "FallingDown" or pose == "Seated" or pose == "PlatformStanding") then
				stopAllAnimations()
				amplitude = 0.1
				frequency = 1
				setAngles = true
			end

			local tool = Character:FindFirstChildOfClass("Tool")
			if tool and tool:FindFirstChild("Handle") then
				local animStringValueObject = getToolAnim(tool)

				if animStringValueObject then
					toolAnim = animStringValueObject.Value
					animStringValueObject.Parent = nil
					toolAnimTime = currentTime + .3
				end

				if currentTime > toolAnimTime then
					toolAnimTime = 0
					toolAnim = "None"
				end

				animateTool()
			else
				stopToolAnimations()
				toolAnim = "None"
				toolAnimInstance = nil
				toolAnimTime = 0
			end
		end


		local events = {}
		local eventHum = Humanoid

		local function onUnhook()
			for i = 1, #events do
				events[i]:Disconnect()
			end
			events = {}
		end

		local function onHook()
			onUnhook()

			pose = eventHum.Sit and "Seated" or "Standing"

			events = {
				eventHum.Died:connect(onDied),
				eventHum.Running:connect(onRunning),
				eventHum.Jumping:connect(onJumping),
				eventHum.Climbing:connect(onClimbing),
				eventHum.GettingUp:connect(onGettingUp),
				eventHum.FreeFalling:connect(onFreeFall),
				eventHum.FallingDown:connect(onFallingDown),
				eventHum.Seated:connect(onSeated),
				eventHum.PlatformStanding:connect(onPlatformStanding),
				eventHum.Swimming:connect(onSwimming)
			}
		end


		onHook()

		game:GetService("Players").LocalPlayer.Chatted:connect(function(msg)
			local emote = ""
			if (string.sub(msg, 1, 3) == "/e ") then
				emote = string.sub(msg, 4)
			elseif (string.sub(msg, 1, 7) == "/emote ") then
				emote = string.sub(msg, 8)
			end

			if (pose == "Standing" and emoteNames[emote] ~= nil) then
				playAnimation(emote, EMOTE_TRANSITION_TIME, Humanoid)
			end
		end)


		playAnimation("idle", 0.1, Humanoid)
		pose = "Standing"
		spawn(function()
			while Character.Parent ~= nil do
				local _, currentGameTime = wait(0.1)
				stepAnimate(currentGameTime)
			end
		end)
		return {
			onRunning = onRunning,
			onDied = onDied,
			onJumping = onJumping,
			onClimbing = onClimbing,
			onGettingUp = onGettingUp,
			onFreeFall = onFreeFall,
			onFallingDown = onFallingDown,
			onSeated = onSeated,
			onPlatformStanding = onPlatformStanding,
			onHook = onHook,
			onUnhook = onUnhook
		}
	end
	return r15()
end
while true do
	wait(.1)
	if plr.Character ~= nil then
		char = plr.Character
		break
	end
end
function _Controller()
	local humanoid = char:WaitForChild("Humanoid")
	local animFuncs = {}
	if (humanoid.RigType == Enum.HumanoidRigType.R6) then
		animFuncs = _R6()
	else
		animFuncs = _R15()
	end
	return animFuncs
end
function _AnimationHandler()
	local AnimationHandler = {}
	AnimationHandler.__index = AnimationHandler

	function AnimationHandler.new(humanoid, animate)
		local self = setmetatable({}, AnimationHandler)

		self._AnimFuncs = _Controller()
		self.Humanoid = humanoid

		return self
	end

	function AnimationHandler:EnableDefault(bool)
		if (bool) then
			self._AnimFuncs.onHook()
		else
			self._AnimFuncs.onUnhook()
		end
	end

	function AnimationHandler:Run(name, ...)
		self._AnimFuncs[name](...)
	end

	return AnimationHandler
end

function _GravityController()

	local ZERO = Vector3.new(0, 0, 0)
	local UNIT_X = Vector3.new(1, 0, 0)
	local UNIT_Y = Vector3.new(0, 1, 0)
	local UNIT_Z = Vector3.new(0, 0, 1)
	local VEC_XY = Vector3.new(1, 0, 1)

	local IDENTITYCF = CFrame.new()

	local JUMPMODIFIER = 1.2
	local TRANSITION = 0.15
	local WALKF = 200 / 3

	local UIS = game:GetService("UserInputService")
	local RUNSERVICE = game:GetService("RunService")

	local InitObjects = _InitObjects()
	local AnimationHandler = _AnimationHandler()
	local StateTracker = _StateTracker()


	local GravityController = {}
	GravityController.__index = GravityController


	local function getRotationBetween(u, v, axis)
		local dot, uxv = u:Dot(v), u:Cross(v)
		if (dot < -0.99999) then return CFrame.fromAxisAngle(axis, math.pi) end
		return CFrame.new(0, 0, 0, uxv.x, uxv.y, uxv.z, 1 + dot)
	end

	local function lookAt(pos, forward, up)
		local r = forward:Cross(up)
		local u = r:Cross(forward)
		return CFrame.fromMatrix(pos, r.Unit, u.Unit)
	end

	local function getMass(array)
		local mass = 0
		for _, part in next, array do
			if (part:IsA("BasePart")) then
				mass = mass + part:GetMass()
			end
		end
		return mass
	end

	local ExecutedPlayerModule = _PlayerModule()
	local ExecutedSounds = _sounds()
	function GravityController.new(player)
		local self = setmetatable({}, GravityController)


		local playerModule = ExecutedPlayerModule
		self.Controls = playerModule:GetControls()

		self.Player = player
		self.Character = player.Character
		self.Humanoid = player.Character:WaitForChild("Humanoid")
		self.HRP = player.Character:WaitForChild("HumanoidRootPart")

		self.AnimationHandler = AnimationHandler.new(self.Humanoid, self.Character:WaitForChild("Animate"))
		self.AnimationHandler:EnableDefault(false)
		local ssss = game:GetService("Players").LocalPlayer.PlayerScripts:FindFirstChild("SetState") or Instance.new("BindableEvent",game:GetService("Players").LocalPlayer.PlayerScripts)
		local soundState = ExecutedSounds
		ssss.Name = "SetState"

		self.StateTracker = StateTracker.new(self.Humanoid, soundState)
		self.StateTracker.Changed:Connect(function(name, speed)
			self.AnimationHandler:Run(name, speed)
		end)

		local collider, gyro, vForce, floor = InitObjects(self)

		floor.Touched:Connect(function() end)
		collider.Touched:Connect(function() end)

		self.Collider = collider
		self.VForce = vForce
		self.Gyro = gyro
		self.Floor = floor

		self.LastPart = workspace.Terrain
		self.LastPartCFrame = IDENTITYCF

		self.GravityUp = UNIT_Y
		self.Ignores = {self.Character}

		self.Humanoid.PlatformStand = true

		self.CharacterMass = getMass(self.Character:GetDescendants())
		self.Character.AncestryChanged:Connect(function() self.CharacterMass = getMass(self.Character:GetDescendants()) end)

		self.JumpCon = RUNSERVICE.RenderStepped:Connect(function(dt)
			if (self.Controls:IsJumping()) then
				self:OnJumpRequest()
			end
		end)

		self.DeathCon = self.Humanoid.Died:Connect(function() self:Destroy() end)
		self.SeatCon = self.Humanoid.Seated:Connect(function(active) if (active) then self:Destroy() end end)
		self.HeartCon = RUNSERVICE.Heartbeat:Connect(function(dt) self:OnHeartbeatStep(dt) end)
		RUNSERVICE:BindToRenderStep("GravityStep", Enum.RenderPriority.Input.Value + 1, function(dt) self:OnGravityStep(dt) end)


		return self
	end


	function GravityController:Destroy()
		self.JumpCon:Disconnect()
		self.DeathCon:Disconnect()
		self.SeatCon:Disconnect()
		self.HeartCon:Disconnect()

		RUNSERVICE:UnbindFromRenderStep("GravityStep")

		self.Collider:Destroy()
		self.VForce:Destroy()
		self.Gyro:Destroy()
		self.StateTracker:Destroy()

		self.Humanoid.PlatformStand = false
		self.AnimationHandler:EnableDefault(true)

		self.GravityUp = UNIT_Y
	end

	function GravityController:GetGravityUp(oldGravity)
		return oldGravity
	end

	function GravityController:IsGrounded(isJumpCheck)
		if (not isJumpCheck) then
			local parts = self.Floor:GetTouchingParts()
			for _, part in next, parts do
				if (not part:IsDescendantOf(self.Character)) then
					return true
				end
			end
		else
			if (self.StateTracker.Jumped) then
				return false
			end

			local valid = {}
			local parts = self.Collider:GetTouchingParts()
			for _, part in next, parts do
				if (not part:IsDescendantOf(self.Character)) then
					table.insert(valid, part)
				end
			end

			if (#valid > 0) then
				local max = math.cos(self.Humanoid.MaxSlopeAngle)
				local ray = Ray.new(self.Collider.Position, -10 * self.GravityUp)
				local hit, pos, normal = workspace:FindPartOnRayWithWhitelist(ray, valid, true)

				if (hit and max <= self.GravityUp:Dot(normal)) then
					return true
				end
			end
		end
		return false
	end

	function GravityController:OnJumpRequest()
		if (not self.StateTracker.Jumped and self:IsGrounded(true)) then
			local hrpVel = self.HRP.Velocity
			self.HRP.Velocity = hrpVel + self.GravityUp*self.Humanoid.JumpPower*JUMPMODIFIER
			self.StateTracker:RequestedJump()
		end
	end

	function GravityController:GetMoveVector()
		return self.Controls:GetMoveVector()
	end

	function GravityController:OnHeartbeatStep(dt)
		local ray = Ray.new(self.Collider.Position, -1.1*self.GravityUp)
		local hit, pos, normal = workspace:FindPartOnRayWithIgnoreList(ray, self.Ignores)
		local lastPart = self.LastPart

		if (hit and lastPart and lastPart == hit) then
			local offset = self.LastPartCFrame:ToObjectSpace(self.HRP.CFrame)
			self.HRP.CFrame = hit.CFrame:ToWorldSpace(offset)
		end

		self.LastPart = hit
		self.LastPartCFrame = hit and hit.CFrame
	end

	function GravityController:OnGravityStep(dt)
		local oldGravity = self.GravityUp
		local newGravity = self:GetGravityUp(oldGravity)

		local rotation = getRotationBetween(oldGravity, newGravity, workspace.CurrentCamera.CFrame.RightVector)
		rotation = IDENTITYCF:Lerp(rotation, TRANSITION)

		self.GravityUp = rotation * oldGravity

		local camCF = workspace.CurrentCamera.CFrame
		local fDot = camCF.LookVector:Dot(newGravity)
		local cForward = math.abs(fDot) > 0.5 and -math.sign(fDot)*camCF.UpVector or camCF.LookVector

		local left = cForward:Cross(-newGravity).Unit
		local forward = -left:Cross(newGravity).Unit

		local move = self:GetMoveVector()
		local worldMove = forward*move.z - left*move.x
		worldMove = worldMove:Dot(worldMove) > 1 and worldMove.Unit or worldMove

		local isInputMoving = worldMove:Dot(worldMove) > 0

		local hrpCFLook = self.HRP.CFrame.LookVector
		local charF = hrpCFLook:Dot(forward)*forward + hrpCFLook:Dot(left)*left
		local charR = charF:Cross(newGravity).Unit
		local newCharCF = CFrame.fromMatrix(ZERO, charR, newGravity, -charF)

		local newCharRotation = IDENTITYCF
		if (isInputMoving) then
			newCharRotation = IDENTITYCF:Lerp(getRotationBetween(charF, worldMove, newGravity), 0.7)
		end

		local g = workspace.Gravity
		local gForce = g * self.CharacterMass * (UNIT_Y - newGravity)

		local cVelocity = self.HRP.Velocity
		local tVelocity = self.Humanoid.WalkSpeed * worldMove
		local gVelocity = cVelocity:Dot(newGravity)*newGravity
		local hVelocity = cVelocity - gVelocity

		if (hVelocity:Dot(hVelocity) < 1) then
			hVelocity = ZERO
		end

		local dVelocity = tVelocity - hVelocity
		local walkForceM = math.min(10000, WALKF * self.CharacterMass * dVelocity.Magnitude / (dt*60))
		local walkForce = walkForceM > 0 and dVelocity.Unit*walkForceM or ZERO

		local charRotation = newCharRotation * newCharCF

		self.StateTracker:OnStep(self.GravityUp, self:IsGrounded(), isInputMoving)

		self.VForce.Force = walkForce + gForce
		self.Gyro.CFrame = charRotation
	end
	return GravityController
end
function _Draw3D()
	local module = {}


	module.StyleGuide = {
		Point = {
			Thickness = 0.5;
			Color = Color3.new(0, 1, 0);
		},

		Line = {
			Thickness = 0.1;
			Color = Color3.new(1, 1, 0);
		},

		Ray = {
			Thickness = 0.1;
			Color = Color3.new(1, 0, 1);
		},

		Triangle = {
			Thickness = 0.05;
		};

		CFrame = {
			Thickness = 0.1;
			RightColor3 = Color3.new(1, 0, 0);
			UpColor3 = Color3.new(0, 1, 0);
			BackColor3 = Color3.new(0, 0, 1);
			PartProperties = {
				Material = Enum.Material.SmoothPlastic;
			};
		}
	}


	local WEDGE = Instance.new("WedgePart")
	WEDGE.Material = Enum.Material.SmoothPlastic
	WEDGE.Anchored = true
	WEDGE.CanCollide = false

	local PART = Instance.new("Part")
	PART.Size = Vector3.new(0.1, 0.1, 0.1)
	PART.Anchored = true
	PART.CanCollide = false
	PART.TopSurface = Enum.SurfaceType.Smooth
	PART.BottomSurface = Enum.SurfaceType.Smooth
	PART.Material = Enum.Material.SmoothPlastic


	local function draw(properties, style)
		local part = PART:Clone()
		for k, v in next, properties do
			part[k] = v
		end
		if (style) then
			for k, v in next, style do
				if (k ~= "Thickness") then
					part[k] = v
				end
			end
		end
		return part
	end

	function module.Draw(parent, properties)
		properties.Parent = parent
		return draw(properties, nil)
	end

	function module.Point(parent, cf_v3)
		local thickness = module.StyleGuide.Point.Thickness
		return draw({
			Size = Vector3.new(thickness, thickness, thickness);
			CFrame = (typeof(cf_v3) == "CFrame" and cf_v3 or CFrame.new(cf_v3));
			Parent = parent;
		}, module.StyleGuide.Point)
	end

	function module.Line(parent, a, b)
		local thickness = module.StyleGuide.Line.Thickness
		return draw({
			CFrame = CFrame.new((a + b)/2, b);
			Size = Vector3.new(thickness, thickness, (b - a).Magnitude);
			Parent = parent;
		}, module.StyleGuide.Line)
	end

	function module.Ray(parent, origin, direction)
		local thickness = module.StyleGuide.Ray.Thickness
		return draw({
			CFrame = CFrame.new(origin + direction/2, origin + direction);
			Size = Vector3.new(thickness, thickness, direction.Magnitude);
			Parent = parent;
		}, module.StyleGuide.Ray)
	end

	function module.Triangle(parent, a, b, c)
		local ab, ac, bc = b - a, c - a, c - b
		local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)

		if (abd > acd and abd > bcd) then
			c, a = a, c
		elseif (acd > bcd and acd > abd) then
			a, b = b, a
		end

		ab, ac, bc = b - a, c - a, c - b

		local right = ac:Cross(ab).Unit
		local up = bc:Cross(right).Unit
		local back = bc.Unit

		local height = math.abs(ab:Dot(up))
		local width1 = math.abs(ab:Dot(back))
		local width2 = math.abs(ac:Dot(back))

		local thickness = module.StyleGuide.Triangle.Thickness

		local w1 = WEDGE:Clone()
		w1.Size = Vector3.new(thickness, height, width1)
		w1.CFrame = CFrame.fromMatrix((a + b)/2, right, up, back)
		w1.Parent = parent

		local w2 = WEDGE:Clone()
		w2.Size = Vector3.new(thickness, height, width2)
		w2.CFrame = CFrame.fromMatrix((a + c)/2, -right, up, -back)
		w2.Parent = parent

		for k, v in next, module.StyleGuide.Triangle do
			if (k ~= "Thickness") then
				w1[k] = v
				w2[k] = v
			end
		end

		return w1, w2
	end

	function module.CFrame(parent, cf)
		local origin = cf.Position
		local r = cf.RightVector
		local u = cf.UpVector
		local b = -cf.LookVector

		local thickness = module.StyleGuide.CFrame.Thickness

		local right = draw({
			CFrame = CFrame.new(origin + r/2, origin + r);
			Size = Vector3.new(thickness, thickness, r.Magnitude);
			Color = module.StyleGuide.CFrame.RightColor3;
			Parent = parent;
		}, module.StyleGuide.CFrame.PartProperties)

		local up = draw({
			CFrame = CFrame.new(origin + u/2, origin + u);
			Size = Vector3.new(thickness, thickness, r.Magnitude);
			Color = module.StyleGuide.CFrame.UpColor3;
			Parent = parent;
		}, module.StyleGuide.CFrame.PartProperties)

		local back = draw({
			CFrame = CFrame.new(origin + b/2, origin + b);
			Size = Vector3.new(thickness, thickness, u.Magnitude);
			Color = module.StyleGuide.CFrame.BackColor3;
			Parent = parent;
		}, module.StyleGuide.CFrame.PartProperties)

		return right, up, back
	end


	return module
end
function _Draw2D()
	local module = {}


	module.StyleGuide = {
		Point = {
			BorderSizePixel = 0;
			Size = UDim2.new(0, 4, 0, 4);
			BorderColor3 = Color3.new(0, 0, 0);
			BackgroundColor3 = Color3.new(0, 1, 0);
		},

		Line = {
			Thickness = 1;
			BorderSizePixel = 0;
			BorderColor3 = Color3.new(0, 0, 0);
			BackgroundColor3 = Color3.new(0, 1, 0);
		},

		Ray = {
			Thickness = 1;
			BorderSizePixel = 0;
			BorderColor3 = Color3.new(0, 0, 0);
			BackgroundColor3 = Color3.new(0, 1, 0);
		},

		Triangle = {
			ImageTransparency = 0;
			ImageColor3 = Color3.new(0, 1, 0);
		}
	}


	local HALF = Vector2.new(0.5, 0.5)

	local RIGHT = "rbxassetid://2798177521"
	local LEFT = "rbxassetid://2798177955"

	local IMG = Instance.new("ImageLabel")
	IMG.BackgroundTransparency = 1
	IMG.AnchorPoint = HALF
	IMG.BorderSizePixel = 0

	local FRAME = Instance.new("Frame")
	FRAME.BorderSizePixel = 0
	FRAME.Size = UDim2.new(0, 0, 0, 0)
	FRAME.BackgroundColor3 = Color3.new(1, 1, 1)


	function draw(properties, style)
		local frame = FRAME:Clone()
		for k, v in next, properties do
			frame[k] = v
		end
		if (style) then
			for k, v in next, style do
				if (k ~= "Thickness") then
					frame[k] = v
				end
			end
		end
		return frame
	end

	function module.Draw(parent, properties)
		properties.Parent = parent
		return draw(properties, nil)
	end

	function module.Point(parent, v2)
		return draw({
			AnchorPoint = HALF;
			Position = UDim2.new(0, v2.x, 0, v2.y);
			Parent = parent;
		}, module.StyleGuide.Point)
	end

	function module.Line(parent, a, b)
		local v = (b - a)
		local m = (a + b)/2

		return draw({
			AnchorPoint = HALF;
			Position = UDim2.new(0, m.x, 0, m.y);
			Size = UDim2.new(0, module.StyleGuide.Line.Thickness, 0, v.magnitude);
			Rotation = math.deg(math.atan2(v.y, v.x)) - 90;
			BackgroundColor3 = Color3.new(1, 1, 0);
			Parent = parent;
		}, module.StyleGuide.Line)
	end

	function module.Ray(parent, origin, direction)
		local a, b = origin, origin + direction
		local v = (b - a)
		local m = (a + b)/2

		return draw({
			AnchorPoint = HALF;
			Position = UDim2.new(0, m.x, 0, m.y);
			Size = UDim2.new(0, module.StyleGuide.Ray.Thickness, 0, v.magnitude);
			Rotation = math.deg(math.atan2(v.y, v.x)) - 90;
			Parent = parent;
		}, module.StyleGuide.Ray)
	end

	function module.Triangle(parent, a, b, c)
		local ab, ac, bc = b - a, c - a, c - b
		local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)

		if (abd > acd and abd > bcd) then
			c, a = a, c
		elseif (acd > bcd and acd > abd) then
			a, b = b, a
		end

		ab, ac, bc = b - a, c - a, c - b

		local unit = bc.unit
		local height = unit:Cross(ab)
		local flip = (height >= 0)
		local theta = math.deg(math.atan2(unit.y, unit.x)) + (flip and 0 or 180)

		local m1 = (a + b)/2
		local m2 = (a + c)/2

		local w1 = IMG:Clone()
		w1.Image = flip and RIGHT or LEFT
		w1.AnchorPoint = HALF
		w1.Size = UDim2.new(0, math.abs(unit:Dot(ab)), 0, height)
		w1.Position = UDim2.new(0, m1.x, 0, m1.y)
		w1.Rotation = theta
		w1.Parent = parent

		local w2 = IMG:Clone()
		w2.Image = flip and LEFT or RIGHT
		w2.AnchorPoint = HALF
		w2.Size = UDim2.new(0, math.abs(unit:Dot(ac)), 0, height)
		w2.Position = UDim2.new(0, m2.x, 0, m2.y)
		w2.Rotation = theta
		w2.Parent = parent

		for k, v in next, module.StyleGuide.Triangle do
			w1[k] = v
			w2[k] = v
		end

		return w1, w2
	end


	return module
end
function _DrawClass()
	local Draw2DModule = _Draw2D()
	local Draw3DModule = _Draw3D()


	local DrawClass = {}
	local DrawClassStorage = setmetatable({}, {__mode = "k"})
	DrawClass.__index = DrawClass

	function DrawClass.new(parent)
		local self = setmetatable({}, DrawClass)

		self.Parent = parent
		DrawClassStorage[self] = {}

		self.Draw3D = {}
		for key, func in next, Draw3DModule do
			self.Draw3D[key] = function(...)
				local returns = {func(self.Parent, ...)}
				for i = 1, #returns do
					table.insert(DrawClassStorage[self], returns[i])
				end
				return unpack(returns)
			end
		end

		self.Draw2D = {}
		for key, func in next, Draw2DModule do
			self.Draw2D[key] = function(...)
				local returns = {func(self.Parent, ...)}
				for i = 1, #returns do
					table.insert(DrawClassStorage[self], returns[i])
				end
				return unpack(returns)
			end
		end

		return self
	end


	function DrawClass:Clear()
		local t = DrawClassStorage[self]
		while (#t > 0) do
			local part = table.remove(t)
			if (part) then
				part:Destroy()
			end
		end
		DrawClassStorage[self] = {}
	end


	return DrawClass
end

local PLAYERS = game:GetService("Players")

local GravityController = _GravityController()
local Controller = GravityController.new(PLAYERS.LocalPlayer)

local DrawClass = _DrawClass()

local PI2 = math.pi*2
local ZERO = Vector3.new(0, 0, 0)

local LOWER_RADIUS_OFFSET = 3
local NUM_DOWN_RAYS = 24
local ODD_DOWN_RAY_START_RADIUS = 3
local EVEN_DOWN_RAY_START_RADIUS = 2
local ODD_DOWN_RAY_END_RADIUS = 1.66666
local EVEN_DOWN_RAY_END_RADIUS = 1

local NUM_FEELER_RAYS = 9
local FEELER_LENGTH = 2
local FEELER_START_OFFSET = 2
local FEELER_RADIUS = 3.5
local FEELER_APEX_OFFSET = 1
local FEELER_WEIGHTING = 8

function GetGravityUp(self, oldGravityUp)
	local ignoreList = {}
	for i, player in next, PLAYERS:GetPlayers() do
		ignoreList[i] = player.Character
	end


	local hrpCF = self.HRP.CFrame
	local isR15 = (self.Humanoid.RigType == Enum.HumanoidRigType.R15)

	local origin = isR15 and hrpCF.p or hrpCF.p + 0.35*oldGravityUp
	local radialVector = math.abs(hrpCF.LookVector:Dot(oldGravityUp)) < 0.999 and hrpCF.LookVector:Cross(oldGravityUp) or hrpCF.RightVector:Cross(oldGravityUp)

	local centerRayLength = 25
	local centerRay = Ray.new(origin, -centerRayLength * oldGravityUp)
	local centerHit, centerHitPoint, centerHitNormal = workspace:FindPartOnRayWithIgnoreList(centerRay, ignoreList)


	local downHitCount = 0
	local totalHitCount = 0
	local centerRayHitCount = 0
	local evenRayHitCount = 0
	local oddRayHitCount = 0

	local mainDownNormal = ZERO
	if (centerHit) then
		mainDownNormal = centerHitNormal
		centerRayHitCount = 0
	end

	local downRaySum = ZERO
	for i = 1, NUM_DOWN_RAYS do
		local dtheta = PI2 * ((i-1)/NUM_DOWN_RAYS)

		local angleWeight = 0.25 + 0.75 * math.abs(math.cos(dtheta))
		local isEvenRay = (i%2 == 0)
		local startRadius = isEvenRay and EVEN_DOWN_RAY_START_RADIUS or ODD_DOWN_RAY_START_RADIUS
		local endRadius = isEvenRay and EVEN_DOWN_RAY_END_RADIUS or ODD_DOWN_RAY_END_RADIUS
		local downRayLength = centerRayLength

		local offset = CFrame.fromAxisAngle(oldGravityUp, dtheta) * radialVector
		local dir = (LOWER_RADIUS_OFFSET * -oldGravityUp + (endRadius - startRadius) * offset)
		local ray = Ray.new(origin + startRadius * offset, downRayLength * dir.unit)
		local hit, hitPoint, hitNormal = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)

		if (hit) then
			downRaySum = downRaySum + angleWeight * hitNormal
			downHitCount = downHitCount + 1
			if isEvenRay then
				evenRayHitCount = evenRayHitCount + 1
			else
				oddRayHitCount = oddRayHitCount + 1
			end
		end
	end

	local feelerHitCount = 0
	local feelerNormalSum = ZERO

	for i = 1, NUM_FEELER_RAYS do
		local dtheta = 2 * math.pi * ((i-1)/NUM_FEELER_RAYS)
		local angleWeight =  0.25 + 0.75 * math.abs(math.cos(dtheta))
		local offset = CFrame.fromAxisAngle(oldGravityUp, dtheta) * radialVector
		local dir = (FEELER_RADIUS * offset + LOWER_RADIUS_OFFSET * -oldGravityUp).unit
		local feelerOrigin = origin - FEELER_APEX_OFFSET * -oldGravityUp + FEELER_START_OFFSET * dir
		local ray = Ray.new(feelerOrigin, FEELER_LENGTH * dir)
		local hit, hitPoint, hitNormal = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)

		if (hit) then
			feelerNormalSum = feelerNormalSum + FEELER_WEIGHTING * angleWeight * hitNormal
			feelerHitCount = feelerHitCount + 1
		end
	end

	if (centerRayHitCount + downHitCount + feelerHitCount > 0) then
		local normalSum = mainDownNormal + downRaySum + feelerNormalSum
		if (normalSum ~= ZERO) then
			return normalSum.unit
		end
	end

	return oldGravityUp
end

Controller.GetGravityUp = GetGravityUp
]]
