local Assets = game.ReplicatedStorage.Assets
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local RenderPlayer = require(Assets.RenderPlayer)

local Camera = workspace.CurrentCamera
local Player = game.Players.LocalPlayer
local Character = RenderPlayer[1](Player.Name, CFrame.new(0, 6.95, 0) * CFrame.new(90, 0, 0) * CFrame.Angles(0, -math.pi/2, 0))
local Mouse = Player:GetMouse()

Camera.CameraSubject = Character.Eyes
Camera.CameraType = Enum.CameraType.Scriptable

local HeadY = 0
local DeltaX = 0

local RS = game:GetService("RunService").RenderStepped
local RSWait = RS.wait
local V3Lerp = Vector3.new().lerp
local rad, min, max, sqrt, pow, sin, pi = math.rad, math.min, math.max, math.sqrt, math.pow, math.sin, math.pi
local CFNew, CFAng, V3New, V3N, V2New = CFrame.new, CFrame.Angles, Vector3.new, Vector3.new(), Vector2.new
local wrap = coroutine.wrap
local Eyes, EyesOffset = Character.Head, CFrame.new(0, 0, -0.7) * CFrame.Angles(0, math.pi, 0)
local BasePart = Character.BasePart
local Legs = Character.Legs
local MouseMovement = Enum.UserInputType.MouseMovement

Character.Head.Transparency = 1
Character.Neck.Transparency = 1
Character.Eyes.Transparency = 1
for _, v in pairs(Character.Head:GetChildren()) do
	if v:IsA("BasePart") then
		v.Transparency = 1
	end
end

UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
UserInputService.InputChanged:connect(function(Input, Processed)
	if not Processed and Input.UserInputType == MouseMovement then
		DeltaX = DeltaX - Input.Delta.X/100
		HeadY = min(max(HeadY + Input.Delta.Y * 0.4, -90), 90)
	end
end)

local ForwardMove, BackwardMove, LeftMove, RightMove = 0, 0, 0, 0

local Speed = 16
local TrueSpeed = 0
local Sprinting = false

local Stamina = 100
local LastMovement = V3N

local TweenTime = 0.2

local function inCirc(t)
	return -1 * (sqrt(1 - pow(t, 2)) - 1)
end

local FootstepSound = Assets.Sounds.Character.Footstep:Clone()
FootstepSound.Parent = BasePart

local BreathingSound = Assets.Sounds.Character.Breath:Clone()
BreathingSound.Parent = BasePart

local UID = 0
local function MovementUpdate()
	local MoveSpeed = ForwardMove + BackwardMove + (LeftMove + RightMove)/2
	Legs[1](MoveSpeed)
	
	local MovementDirection = V3New(LeftMove + RightMove, 0, ForwardMove + BackwardMove).Unit * Speed * (1/60) * (Sprinting and 1.5 or 1)
	if MovementDirection.X ~= MovementDirection.X then
		MovementDirection = V3N
	end
	
	UID = UID + 1
	local LUID = UID
	for i = 1, TweenTime * 60 do
		if UID ~= LUID then
			break
		end
		LastMovement = V3Lerp(LastMovement, MovementDirection, inCirc(i/(TweenTime * 60)))
		RSWait(RS)
	end
end

local function MoveForwardFunc(ActionName, InputState, InputObject)			
	if InputState == Enum.UserInputState.Begin then
		ForwardMove = 1
	elseif InputState == Enum.UserInputState.End then
		ForwardMove = 0
	end
	MovementUpdate()
end

local function MoveBackwardFunc(ActionName, InputState, InputObject)	
	if InputState == Enum.UserInputState.Begin then
		BackwardMove = -1
	elseif InputState == Enum.UserInputState.End then
		BackwardMove = 0
	end
	MovementUpdate()
end

local function MoveLeftFunc(ActionName, InputState, InputObject)	
	if InputState == Enum.UserInputState.Begin then
		LeftMove = 1
	elseif InputState == Enum.UserInputState.End then
		LeftMove = 0
	end
	MovementUpdate()
end

local function MoveRightFunc(ActionName, InputState, InputObject)	
	if InputState == Enum.UserInputState.Begin then
		RightMove = -1
	elseif InputState == Enum.UserInputState.End then
		RightMove = 0
	end
	MovementUpdate()
end

local function MoveSprintFunc(ActionName, InputState, InputObject)	
	if InputState == Enum.UserInputState.Begin and Stamina > 15 then
		Sprinting = true
		Character.Sprinting = true
		Legs[2](true)
	elseif InputState == Enum.UserInputState.End then
		Sprinting = false
		Character.Sprinting = false
		Legs[2](false)
	end
	MovementUpdate()
end

local IsJumping, InAir = false, false
local function MoveJumpFunc(ActionName, InputState, InputObject)	
	if InputState == Enum.UserInputState.Begin and not IsJumping then
		if Sprinting then
			Sprinting = false
			Character.Sprinting = false
			Legs[2](false)
			MovementUpdate()
		end
		IsJumping, InAir = true, true
		Character.Jump()
		InAir = false
		wait(1)
		IsJumping = false
	end
end

ContextActionService:BindActionToInputTypes("ForwardMovement", MoveForwardFunc, false, Enum.PlayerActions.CharacterForward)
ContextActionService:BindActionToInputTypes("BackwardMovement", MoveBackwardFunc, false, Enum.PlayerActions.CharacterBackward)
ContextActionService:BindActionToInputTypes("LeftMovement", MoveLeftFunc, false, Enum.PlayerActions.CharacterLeft)
ContextActionService:BindActionToInputTypes("RightMovement", MoveRightFunc, false, Enum.PlayerActions.CharacterRight)
ContextActionService:BindActionToInputTypes("SprintMovement", MoveSprintFunc, false, Enum.KeyCode.LeftShift)
ContextActionService:BindActionToInputTypes("JumpMovement", MoveJumpFunc, false, Enum.PlayerActions.CharacterJump)

local function CylinderCollision(CylPos, CylHeight, CylWidth, Pos)
	if Pos.Y > CylPos.Y + CylHeight/2 or Pos.Y < CylPos.Y - CylHeight/2 then
		return false
	end
	local TmpPos = V3New(Pos.X, CylPos.Y, Pos.Z)
	local Dist = (CylPos - TmpPos).magnitude
	if Dist > CylWidth/2 then
		return false
	end
	local Back = CFNew(CylPos, TmpPos)
	local Move = CylWidth/2 - Dist
	--Move character backwards by move amount
end

local function BallCollision(BallPos, BallWidth, Temp, Pos)
	local Dist = (BallPos - Pos).magnitude
	if Dist > BallWidth/2 then
		return false
	end
	local Back = CFNew(BallPos, Pos)
	local Move = BallWidth/2 - Dist
	--Move character backwards by move amount
end

local function InfCylinderCollision(CylPos, CF)
	local Distance = (CylPos - V3New(CF.X, 0, CF.Z)).magnitude
	if Distance < 4 then
		local TruePos = V3New(CF.X, 0, CF.Z)
		local Direction = CFNew(CylPos, TruePos)
		return -TruePos + CylPos + Direction.lookVector * 4
	end
end

local CharacterModels = {}
NewModels = RenderPlayer[3](function(Models)
	CharacterModels = {}
	for _, v in pairs(Models) do
		if v ~= BasePart then
			table.insert(CharacterModels, v.BasePart)
		end
	end
end)
for _, v in pairs(NewModels) do
	if v ~= BasePart then
		table.insert(CharacterModels, v.BasePart)
	end
end

local function CalculateCollisions(CF)
	local Distance = V2New(CF.X, CF.Z).magnitude
	if Distance > 93 then
		local TruePos = V3New(CF.X, 0, CF.Z)
		local Direction = CFNew(V3N, TruePos)
		CF = CF - TruePos + Direction.lookVector * 93
	end
	
	for _, v in pairs(CharacterModels) do
		local Offset = InfCylinderCollision(V3New(v.Position.X, 0, v.Position.Z), CF)
		if Offset then
			CF = CF + Offset
		end
	end
	
	return CF
end

spawn(function()
	while wait() do
		FootstepSound.Pitch = 0.8 + TrueSpeed * 3
		if (InAir or TrueSpeed < 0.1) and FootstepSound.IsPlaying then
			FootstepSound:Stop()
		elseif not InAir and TrueSpeed > 0.1 and not FootstepSound.IsPlaying then
			FootstepSound:Play()
		end
		if Sprinting and TrueSpeed > 0.3 then
			Stamina = max(Stamina - 2, 0)
			if Stamina < 60 and not BreathingSound.IsPlaying then
				BreathingSound:Play()
			end
			if Stamina == 0 then
				Sprinting = false
				Character.Sprinting = false
				Legs[2](false)
				MovementUpdate()
			end
		else
			Stamina = min(Stamina + 1, 100)
		end
	end
end)

UserInputService.InputBegan:connect(function(Input, Processed)
	if Processed == false then
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Character.MouseDown = true
			wrap(Character.Animate)("Swing")
		elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
			wrap(Character.Animate)("Block")
		end
	end
end)

UserInputService.InputEnded:connect(function(Input, Processed)
	if Processed == false then
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Character.MouseDown = false
		end
	end
end)

UserInputService.InputChanged:connect(function(Input, Processed)
	if Processed == false then
		if Input.UserInputType == Enum.UserInputType.MouseWheel then
			if Input.Position.Z > 0 then
				wrap(Character.Animate)("Lunge")
			else
				wrap(Character.Animate)("Down")
			end
		end
	end
end)

local LastCF = BasePart.Position
while true do
	local Rate = RSWait(RS)
	local Delta = 60 * Rate
	
	Character.RotateUpperTorso(rad(HeadY))
	
	Legs[4](Rate)
	
	BasePart.CFrame = CalculateCollisions(BasePart.CFrame * CFAng(0, DeltaX, 0) * CFNew(LastMovement.X * 0.8 * Delta, 0, LastMovement.Z * Delta))
	TrueSpeed = (BasePart.Position - LastCF).magnitude
	LastCF = BasePart.Position
	DeltaX = 0
	Camera.CFrame = Eyes.CFrame * EyesOffset
end