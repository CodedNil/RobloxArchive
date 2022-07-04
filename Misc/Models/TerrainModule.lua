local MaxX, MaxZ, Resolution = 1536, 1536, 256
local SandHeight, WaterHeight = -32, -8

local Terrain = workspace.Terrain
local R3New, V3New = Region3.new, Vector3.new
local Air, Water, Sand, Asphalt, Grass, Ground, Mud, Leaf, Snow, Ice = Enum.Material.Air, Enum.Material.Water, Enum.Material.Sand, Enum.Material.Asphalt, Enum.Material.Grass, Enum.Material.Ground, Enum.Material.Mud, Enum.Material.LeafyGrass, Enum.Material.Snow, Enum.Material.Ice

local Self = {}

function Self.RemoveWater()
	for mx = -MaxX, MaxZ, Resolution do
		for mz = -MaxX, MaxZ, Resolution do
			local Region = R3New(V3New(mx, SandHeight + 8, mz), V3New(mx + Resolution, WaterHeight, mz + Resolution))
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
	for _, v in pairs(workspace.Props:GetChildren()) do
		if v.Name == "WaterPart" then
			Terrain:FillBlock(v.CFrame, v.Size, Air)
		end
	end
	game.ChangeHistoryService:SetWaypoint("TerrainChanged")
end

function Self.AddWater()
	for mx = -MaxX, MaxZ, Resolution do
		for mz = -MaxX, MaxZ, Resolution do
			local Region = R3New(V3New(mx, SandHeight + 8, mz), V3New(mx + Resolution, WaterHeight, mz + Resolution))
			local Material, Occupancy = Terrain:ReadVoxels(Region, 4)
			local Size = Material.Size
			for x = 1, Size.X do
				for y = 1, Size.Y do
					for z = 1, Size.Z do
						if Material[x][y][z] == Air then
							Material[x][y][z] = Water
							Occupancy[x][y][z] = 1
						end
					end
				end
			end
			Terrain:WriteVoxels(Region, 4, Material, Occupancy)
		end
	end
	for _, v in pairs(workspace.Props:GetChildren()) do
		if v.Name == "WaterPart" then
			Terrain:FillBlock(v.CFrame, v.Size, Water)
		end
	end
	game.ChangeHistoryService:SetWaypoint("TerrainChanged")
end

function Self.AddIce()
	for mx = -MaxX, MaxZ, Resolution do
		for mz = -MaxX, MaxZ, Resolution do
			local Region = R3New(V3New(mx, SandHeight + 8, mz), V3New(mx + Resolution, WaterHeight, mz + Resolution))
			local Material, Occupancy = Terrain:ReadVoxels(Region, 4)
			local Size = Material.Size
			for x = 1, Size.X do
				for y = 1, Size.Y do
					for z = 1, Size.Z do
						if Material[x][y][z] == Water then
							Material[x][y][z] = Ice
							Occupancy[x][y][z] = 1
						end
					end
				end
			end
			Terrain:WriteVoxels(Region, 4, Material, Occupancy)
		end
	end
	for _, v in pairs(workspace.Props:GetChildren()) do
		if v.Name == "WaterPart" then
			Terrain:FillBlock(v.CFrame, v.Size, Water)
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

function Self.AddFloors()
	for _, v in pairs(workspace.Floors:GetChildren()) do
		Terrain:FillBlock(v.CFrame + Vector3.new(0, v.Size.Y/2 + 16, 0), Vector3.new(v.Size.X, 32, v.Size.Z), Air)
		Terrain:FillBlock(v.CFrame, v.Size, Asphalt)
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

function Self.AddSnow()
	for mx = -MaxX, MaxZ, Resolution do
		for mz = -MaxX, MaxZ, Resolution do
			local Region = R3New(V3New(mx, WaterHeight - 4, mz), V3New(mx + Resolution, WaterHeight + 68, mz + Resolution))
			local Material, Occupancy = Terrain:ReadVoxels(Region, 4)
			local Size = Material.Size
			for x = 1, Size.X do
				for y = 1, Size.Y do
					for z = 1, Size.Z do
						if Material[x][y][z] == Grass or Material[x][y][z] == Ground or Material[x][y][z] == Leaf then
							Material[x][y][z] = Snow
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