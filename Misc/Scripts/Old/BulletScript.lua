local BulletSpeed = 100 -- Speed of the bullet
local BulletSpread = 5 -- Spread of the bullet
local Damage = 50 -- Damage of the bullet

-- The bullet
local BPart = Instance.new("Part")
BPart.Name = "BulletPart"
BPart.Anchored = true
BPart.CanCollide = false
BPart.FormFactor = Enum.FormFactor.Custom
BPart.BackSurface = Enum.SurfaceType.SmoothNoOutlines
BPart.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
BPart.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
BPart.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
BPart.RightSurface = Enum.SurfaceType.SmoothNoOutlines
BPart.TopSurface = Enum.SurfaceType.SmoothNoOutlines
BPart.Size = Vector3.new(1, 1, 0.2)
local BMesh = Instance.new("BlockMesh", BPart)

function Weld(x,y)
	local W = Instance.new("Weld")
	W.Part0 = x
	W.Part1 = y
	local CJ = CFrame.new(x.Position)
	local C0 = x.CFrame:inverse()*CJ
	local C1 = y.CFrame:inverse()*CJ
	W.C0 = C0
	W.C1 = C1
	W.Parent = x
end

function FireBullet(Start, Direction)
	
	local InitialSpeed = Direction * BulletSpeed -- Speed of the bullet, AKA, velocity
	local Speed = InitialSpeed
	local HitObj, HitPos = nil, nil -- Make it local :)
	local Bullet = nil -- Make it local :)
	local IgnoreList = {}
	
	while wait() do
		-- Apply gravity / drag
		Speed = Speed - (InitialSpeed / (BulletSpeed * 2)) - Vector3.new(0, 1, 0)
		
		-- Apply gravity to X + Z
		if Speed.Y < 0 then
			Speed = Speed + Vector3.new(InitialSpeed.X / (BulletSpeed * 2), -0.5, InitialSpeed.Z / (BulletSpeed * 2))
		end
		
		-- Make sure it doesn't go backwards
		if (InitialSpeed.X < 0 and Speed.X > 0) or (InitialSpeed.X > 0 and Speed.X < 0) then
			Speed = Vector3.new(0, Speed.Y, Speed.Z)
		end
		
		if (InitialSpeed.Z < 0 and Speed.Z > 0) or (InitialSpeed.Z > 0 and Speed.Z < 0) then
			Speed = Vector3.new(Speed.X, Speed.Y, 0)
		end
		
		print(Speed.Y)
		-- Do the raycast
		HitObj, HitPos = workspace:FindPartOnRayWithIgnoreList(Ray.new(Start, Speed / 10), IgnoreList)
		
		-- Make sure the bullet isn't bellow 0 Y
		if Start.Y < 0 then
			break
		end
		
		-- The distance between the original and hit positions for bullet length and offset
		local HitDist = (Start - HitPos).magnitude
		
		-- The bullet
		Bullet = BPart:Clone()
		Bullet.Mesh.Scale = Vector3.new(1, 1, HitDist * 5)
		Bullet.Mesh.Offset = Vector3.new(0, 0, -HitDist/2)
		Bullet.CFrame = CFrame.new(Start, HitPos)
		Bullet.Parent = workspace
		--game.Debris:AddItem(Bullet, 1/30)
		
		-- If it has hit something, break
		if HitObj then
			if HitObj.CanCollide and HitObj.Name ~= "BulletPart" then
				break
			else
				local Humanoid = HitObj.Parent:FindFirstChild("Humanoid") or HitObj.Parent.Parent:FindFirstChild("Humanoid")
				if Humanoid then
					break
				end
			end
			table.insert(IgnoreList, HitObj)
			Speed = Speed + (InitialSpeed / (BulletSpeed * 2)) + Vector3.new(0, 0.1, 0)
		else
			-- Set the start pos to the hitpos for the next iteration
			Start = HitPos
		end
	end
	
	Bullet = BPart:Clone()
	Bullet.Mesh.Scale = Vector3.new(1, 1, 1)
	Bullet.CFrame = CFrame.new(HitPos, Start)
	Bullet.Anchored = false
	
	if HitObj then
		Weld(Bullet, HitObj)
		if not HitObj.Anchored then
			HitObj.Velocity = Speed * 3
		end
	else
		Bullet.CanCollide = true
		Bullet.Velocity = Speed * 3
	end
	
	Bullet.Parent = workspace
	game.Debris:AddItem(Bullet, 2)
	
	return HitObj, Speed.magnitude / InitialSpeed.magnitude
end

function DamageModifier(HitObj)
	if HitObj.Name == "Head" then
		return 1.5
	elseif HitObj.Name == "Torso" or HitObj.Name == "HumanoidBasePart" then
		return 1
	elseif HitObj.Parent:IsA("Model") then
		return 0.8
	elseif HitObj.Parent:IsA("Hat") then
		return 0.9
	else
		return 0
	end
end

function HandleFire()
	local HitObj, Speed = FireBullet(workspace.A.Position, workspace.A.CFrame.lookVector + Vector3.new(math.random(-BulletSpread, BulletSpread) / 100, math.random(-BulletSpread, BulletSpread) / 100, math.random(-BulletSpread, BulletSpread) / 100))
	if HitObj then
		local Humanoid = HitObj.Parent:FindFirstChild("Humanoid") or HitObj.Parent.Parent:FindFirstChild("Humanoid")
		if Humanoid then
			local Damage = Damage * Speed
			Damage = Damage * DamageModifier(HitObj)
			Humanoid:TakeDamage(Damage * Speed)
		end
	end
end

HandleFire()