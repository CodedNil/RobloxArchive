local Player = game.Players.LocalPlayer

local Feet = {
	Left = "Stone",
	Right = "Stone"
}
local Sounds = {}

repeat wait(0.1) until Player.Character
local Character = Player.Character
local Humanoid = Character.Humanoid

if Character:FindFirstChild("Sound") then
	Character.Sound:Destroy()
end
for _, v in pairs(Character.Head:GetChildren()) do
	if v:IsA("Sound") then
		v:Stop()
		v:Destroy()
	end
end
for _, v in pairs(game.ServerStorage.Footsteps:GetChildren()) do
	local n = v:Clone()
	n.Parent = Character.Head
	Sounds[v.Name] = n
end

function newSound(id)
	local sound = Instance.new("Sound", Character.Head)
	sound.SoundId = id
	return sound
end

Sounds.Died = newSound("rbxasset://sounds/uuhhh.wav")
Sounds.FallingDown = newSound("rbxasset://sounds/splat.wav")
Sounds.FreeFalling = newSound("rbxasset://sounds/swoosh.wav")
Sounds.GettingUp = newSound("rbxasset://sounds/hit.wav")
Sounds.Jumping = newSound("rbxasset://sounds/button.wav")

local Foot = "Left"
local FindPartOnRay = game.Workspace.FindPartOnRay

function Loop()
	while true do
		if Running then
			local LeftLeg = Character:FindFirstChild("Left Leg")
			local RightLeg = Character:FindFirstChild("Right Leg")
			if LeftLeg then
				local ray = Ray.new(LeftLeg.Position, Vector3.new(0, -10, 0))
				local part, endPoint = FindPartOnRay(game.Workspace, ray, Character)
				if part then
					Feet.Left = tostring(part.Material):sub(15)
				end
			end
			if RightLeg then
				local ray = Ray.new(RightLeg.Position, Vector3.new(0, -10, 0))
				local part, endPoint = FindPartOnRay(game.Workspace, ray, Character)
				if part then
					Feet.Right = tostring(part.Material):sub(15)
				end
			end
			if Sounds[Feet[Foot]] then
				Sounds[Feet[Foot]]:Play()
			else
				Sounds.Stone:Play()
			end
			if Foot == "Left" then
				Foot = "Right"
			else
				Foot = "Left"
			end
			wait(0.3)
		elseif Climbing then
			local Torso = Character:FindFirstChild("Torso")
			if Torso then
				local ray = Ray.new(Torso.Position, Torso.CFrame.lookVector * 10)
				local part, endPoint = FindPartOnRay(game.Workspace, ray, Character)
				if part then
					local mat = tostring(part.Material):sub(15)
					if Sounds[mat] then
						Sounds[mat]:Play()
					else
						Sounds.Stone:Play()
					end
				end
			end
			wait(0.3)
		elseif Swimming then
			Sounds.Water:Play()
			wait(0.6)
		else
			wait()
		end
	end
end

function onDied()
	Sounds.Died:Play()
end

function onState(state, sound)
	if state then
		sound:Play()
	else
		sound:Pause()
	end
end

function onRunning(speed)
	if math.abs(speed) > 1 then
		Running = true
	else
		Running = false
	end
end

function onSwimming(speed)
	if math.abs(speed) > 1 then
		Swimming = true
	else
		Swimming = false
	end
end

function onClimbing(speed)
	if math.abs(speed) > 1 then
		Climbing = true
	else
		Climbing = false
	end
end

Humanoid.Died:connect(onDied)
Humanoid.Running:connect(onRunning)
Humanoid.Swimming:connect(onSwimming)
Humanoid.Climbing:connect(onClimbing)
Humanoid.Jumping:connect(function(state) onState(state, Sounds.Jumping) end)
Humanoid.GettingUp:connect(function(state) onState(state, Sounds.GettingUp) end)
Humanoid.FreeFalling:connect(function(state) onState(state, Sounds.FreeFalling) end)
Humanoid.FallingDown:connect(function(state) onState(state, Sounds.FallingDown) end)
Loop()