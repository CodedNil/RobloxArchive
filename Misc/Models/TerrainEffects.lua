local Terrain = workspace.Terrain
local MaterialMap = {}
local Timers = {}

local Duration = 60

local CFNew, V3New, V3N, R3New, INew = CFrame.new, Vector3.new, Vector3.new(), Region3.new, Instance.new
local floor, pow, random, insert, wrap = math.floor, math.pow, math.random, table.insert, coroutine.wrap
local Mud, Ground, Grass = Enum.Material.Mud, Enum.Material.Ground, Enum.Material.Grass

local function Round(Position)
	return V3New(floor(Position.X/4 + 0.5) * 4, floor(Position.Y/4 + 0.5) * 4, floor(Position.Z/4 + 0.5) * 4)
end

local function PosToString(Position)
	return Position.X.."."..Position.Y.."."..Position.Z
end

local function outCubic(t)
	return pow(t - 1, 3) + 1
end

function GetPositions(Position, Size)
	Position = Round(Position)
	local Positions = {}
	for x = Position.X - Size, Position.X + Size, 4 do
		for y = Position.Y - Size, Position.Y + Size, 4 do
			for z = Position.Z - Size, Position.Z + Size, 4 do
				local Dist = (Position - V3New(x, y, z)).magnitude
				if Dist <= Size then
					insert(Positions, {X = x, Y = y, Z = z, O = outCubic(1 - (Dist/Size))})
				end
			end
		end
	end
	return Positions
end

function SetMaterial(Position, NewMaterial)
	Position = Round(Position)
	local Str = PosToString(Position)
	
	local Region = R3New(V3New(Position.X, Position.Y, Position.Z), V3New(Position.X + 4, Position.Y + 4, Position.Z + 4))
	local Mat, Occ = Terrain:ReadVoxels(Region, 4)
	
	if NewMaterial then
		if Timers[Str] then
			Timers[Str] = {Position, Timers[Str][2], Duration}
			if NewMaterial == Mud then
				Mat[1][1][1] = NewMaterial
				Terrain:WriteVoxels(Region, 4, Mat, Occ)
			end
		elseif Mat[1][1][1] == Grass then
			Timers[Str] = {Position, Mat[1][1][1], Duration}
			Mat[1][1][1] = NewMaterial
			Terrain:WriteVoxels(Region, 4, Mat, Occ)
		end
	elseif Timers[Str] then
		Mat[1][1][1] = Timers[Str][2]
		Terrain:WriteVoxels(Region, 4, Mat, Occ)
		Timers[Str] = nil
	end
end

spawn(function()
	while wait(1) do
		for i, v in pairs(Timers) do
			if v[3] > 0 then
				v[3] = v[3] - 1
			else
				SetMaterial(v[1])
			end
		end
	end
end)

local function PlaySound(Child)
	local Part = INew("Part", workspace)
	Part.Anchored = true
	Part.Size = V3N
	Part.CanCollide = false
	Part.Transparency = 1
	Part.CFrame = CFNew(Child.Position)
	local Sound = INew("Sound", Part)
	Sound.SoundId = "rbxassetid://138210320"
	Sound.Pitch = 1
	Sound.Volume = 1
	Sound.MaxDistance = Child.BlastRadius * 30
	Sound:Play()
	Sound.Ended:wait()
	Part:Destroy()
end

workspace.ChildAdded:connect(function(Child)
	if Child:IsA("Explosion") then
		wrap(PlaySound)(Child)
		local Positions = GetPositions(Child.Position, Child.BlastRadius * 4)
		for _, v in pairs(Positions) do
			if random() < v.O then
				SetMaterial(v, v.O > 0.9 and Mud or Ground)
				if random() < 0.1 then
					wait()
				end
			end
		end
	end
end)