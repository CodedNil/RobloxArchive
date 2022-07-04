local MaxX, MaxZ, Resolution = 2048, 2048, 64
local SandHeight, WaterHeight = -80, 0

local Terrain = workspace.Terrain
local R3New, V3New = Region3.new, Vector3.new
local Air, Water, Sand, Grass, Ground, Mud, Leaf, Basalt = Enum.Material.Air, Enum.Material.Water, Enum.Material.Sand, Enum.Material.Asphalt, Enum.Material.Grass, Enum.Material.Ground, Enum.Material.Mud, Enum.Material.LeafyGrass, Enum.Material.Basalt

local Self = {}

function Self.RemoveBasalt()
	local Part = workspace.BasaltRemoval
	local Region = R3New(
		V3New(Part.Position.X - Part.Size.X / 2, Part.Position.Y - Part.Size.Y / 2, Part.Position.Z - Part.Size.Z / 2),
		V3New(Part.Position.X + Part.Size.X / 2, Part.Position.Y + Part.Size.Y / 2, Part.Position.Z + Part.Size.Z / 2),
		4
	):ExpandToGrid(4)
	
	local Material, Occupancy = Terrain:ReadVoxels(Region, 4)
	local Size = Material.Size
	for x = 1, Size.X do
		for y = 1, Size.Y do
			for z = 1, Size.Z do
				if Material[x][y][z] == Enum.Material.Basalt then
					Material[x][y][z] = Air
				end
			end
		end
	end
	Terrain:WriteVoxels(Region, 4, Material, Occupancy)
	
	game.ChangeHistoryService:SetWaypoint("TerrainChanged")
end

function Self.RemoveWaterBox()
	local Part = workspace.WaterRemoval
	local Region = R3New(
		V3New(Part.Position.X - Part.Size.X / 2, Part.Position.Y - Part.Size.Y / 2, Part.Position.Z - Part.Size.Z / 2),
		V3New(Part.Position.X + Part.Size.X / 2, Part.Position.Y + Part.Size.Y / 2, Part.Position.Z + Part.Size.Z / 2),
		4
	):ExpandToGrid(4)
	
	local Material, Occupancy = Terrain:ReadVoxels(Region, 4)
	local Size = Material.Size
	for x = 1, Size.X do
		for y = 1, Size.Y do
			for z = 1, Size.Z do
				if Material[x][y][z] == Enum.Material.Water then
					Material[x][y][z] = Air
				end
			end
		end
	end
	Terrain:WriteVoxels(Region, 4, Material, Occupancy)
	
	game.ChangeHistoryService:SetWaypoint("TerrainChanged")
end

function Self.RemoveWater()
	for mx = -MaxX, MaxZ, Resolution do
		for mz = -MaxX, MaxZ, Resolution do
			local Region = R3New(V3New(mx, SandHeight, mz), V3New(mx + Resolution, WaterHeight, mz + Resolution))
			local Material, Occupancy = Terrain:ReadVoxels(Region, 4)
			local Size = Material.Size
			for x = 1, Size.X do
				for y = 1, Size.Y do
					for z = 1, Size.Z do
						if Material[x][y][z] == Water then
							Material[x][y][z] = Air
						end
					end
				end
			end
			Terrain:WriteVoxels(Region, 4, Material, Occupancy)
		end
	end
	game.ChangeHistoryService:SetWaypoint("TerrainChanged")
end

local Rays = {}

local RNew, V3New = Ray.new, Vector3.new
local floor = math.floor
local RayDirection = Vector3.new(0, -1150, 0)

local function GetHeight(X, Z)
	if Rays[X] and Rays[X][Z] then
		return Rays[X][Z]
	end
	local Hit, Pos = workspace:FindPartOnRayWithWhitelist(RNew(V3New(X, 1000, Z), RayDirection), {workspace.Terrain, workspace.Cliffs}, true)
	Rays[X] = Rays[X] or {}
	Rays[X][Z] = Pos.Y
	return Rays[X][Z]
end

function Self.AddWater()
	for mx = -MaxX, MaxZ, Resolution do
		for mz = -MaxX, MaxZ, Resolution do
			if Vector2.new(mx, mz).Magnitude < MaxX then
				local Region = R3New(V3New(mx, SandHeight + 8, mz), V3New(mx + Resolution, WaterHeight, mz + Resolution))
				local Material, Occupancy = Terrain:ReadVoxels(Region, 4)
				local Size = Material.Size
				for x = 1, Size.X do
					local X = floor(x * 4 + mx + 0.5)
					for z = 1, Size.Z do
						local Z = floor(z * 4 + mz + 0.5)
						
						local Height = GetHeight(X, Z)
						if Height < 0 then
							for y = 1, Size.Y do
								local Y = floor(y * 4 + SandHeight + 8 + 0.5)
								if Material[x][y][z] == Air and Y > Height - 4 then
									Material[x][y][z] = Water
									Occupancy[x][y][z] = 1
								end
							end
						end
					end
				end
				Terrain:WriteVoxels(Region, 4, Material, Occupancy)
			end
		end
	end
	game.ChangeHistoryService:SetWaypoint("TerrainChanged")
end

function Self.AddSand()
	for mx = -MaxX, MaxZ, Resolution do
		for mz = -MaxX, MaxZ, Resolution do
			local Region = R3New(V3New(mx, SandHeight, mz), V3New(mx + Resolution, SandHeight + 8, mz + Resolution))
			local Material, Occupancy = Terrain:ReadVoxels(Region, 4)
			local Size = Material.Size
			for x = 1, Size.X do
				for y = 1, Size.Y do
					for z = 1, Size.Z do
						Material[x][y][z] = Sand
						Occupancy[x][y][z] = 1
					end
				end
			end
			Terrain:WriteVoxels(Region, 4, Material, Occupancy)
		end
	end
	game.ChangeHistoryService:SetWaypoint("TerrainChanged")
end

function Self.RemoveSand()
	for mx = -MaxX, MaxZ, Resolution do
		for mz = -MaxX, MaxZ, Resolution do
			local Region = R3New(V3New(mx, SandHeight, mz), V3New(mx + Resolution, SandHeight + 8, mz + Resolution))
			local Material, Occupancy = Terrain:ReadVoxels(Region, 4)
			local Size = Material.Size
			for x = 1, Size.X do
				for y = 1, Size.Y do
					for z = 1, Size.Z do
						if Material[x][y][z] == Sand then
							Material[x][y][z] = Air
						end
					end
				end
			end
			Terrain:WriteVoxels(Region, 4, Material, Occupancy)
		end
	end
	game.ChangeHistoryService:SetWaypoint("TerrainChanged")
end

function Self.RemoveOutside()
	for mx = -MaxX - 512, MaxZ + 512, Resolution do
		for mz = -MaxX - 512, MaxZ + 512, Resolution do
			if Vector2.new(mx, mz).Magnitude > MaxX then
				local Region = R3New(V3New(mx, SandHeight - 4, mz), V3New(mx + Resolution, WaterHeight + 4, mz + Resolution))
				local Material, Occupancy = Terrain:ReadVoxels(Region, 4)
				local Size = Material.Size
				for x = 1, Size.X do
					for y = 1, Size.Y do
						for z = 1, Size.Z do
							Material[x][y][z] = Air
						end
					end
				end
				Terrain:WriteVoxels(Region, 4, Material, Occupancy)
			end
		end
	end
	game.ChangeHistoryService:SetWaypoint("TerrainChanged")
end

function Self.RemoveLower()
	for mx = -MaxX, MaxZ, Resolution do
		for mz = -MaxX, MaxZ, Resolution do
			local Region = R3New(V3New(mx, SandHeight - 60, mz), V3New(mx + Resolution, SandHeight, mz + Resolution))
			local Material, Occupancy = Terrain:ReadVoxels(Region, 4)
			local Size = Material.Size
			for x = 1, Size.X do
				for y = 1, Size.Y do
					for z = 1, Size.Z do
						Material[x][y][z] = Air
					end
				end
			end
			Terrain:WriteVoxels(Region, 4, Material, Occupancy)
		end
	end
	game.ChangeHistoryService:SetWaypoint("TerrainChanged")
end

local function LoopFillHoles(Material, Occupancy)
	local Size = Material.Size
	for x = 1, Size.X do
		for y = 1, Size.Y do
			for z = 1, Size.Z do
				if Material[x][y + 1] and Material[x][y + 1][z] then
					local AboveM, AboveO = Material[x][y + 1][z], Occupancy[x][y + 1][z]
					if AboveO > 0 and Occupancy[x][y][z] < 1 then
						Material[x][y][z] = AboveM
						Occupancy[x][y][z] = 1
					end
				end
			end
		end
	end
	return Material, Occupancy
end

function Self.FillHoles()
	for mx = -MaxX, MaxZ, Resolution do
		for mz = -MaxX, MaxZ, Resolution do
			local Region = R3New(V3New(mx, SandHeight, mz), V3New(mx + Resolution, WaterHeight + 4, mz + Resolution))
			local Material, Occupancy = Terrain:ReadVoxels(Region, 4)
			for i = 1, 8 do
				Material, Occupancy = LoopFillHoles(Material, Occupancy)
			end
			Terrain:WriteVoxels(Region, 4, Material, Occupancy)
		end
	end
	game.ChangeHistoryService:SetWaypoint("TerrainChanged")
end

function Self.AddMud()
	for mx = -MaxX, MaxZ, Resolution do
		for mz = -MaxX, MaxZ, Resolution do
			local Region = R3New(V3New(mx, SandHeight, mz), V3New(mx + Resolution, WaterHeight, mz + Resolution))
			local Material, Occupancy = Terrain:ReadVoxels(Region, 4)
			local Size = Material.Size
			for x = 1, Size.X do
				for y = 1, Size.Y do
					for z = 1, Size.Z do
						if Material[x][y][z] == Grass or Material[x][y][z] == Ground then
							Material[x][y][z] = Mud
						end
					end
				end
			end
			Terrain:WriteVoxels(Region, 4, Material, Occupancy)
		end
	end
	game.ChangeHistoryService:SetWaypoint("TerrainChanged")
end

return Self