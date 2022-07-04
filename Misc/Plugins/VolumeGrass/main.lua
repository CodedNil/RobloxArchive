local Plugin = PluginManager():CreatePlugin()
local Toolbar = Plugin:CreateToolbar("Detailing")
local VolumeGrass = Toolbar:CreateButton("VolumeGrass", "", "http://www.roblox.com/asset/?id=249780864")

local Active = false

local Mouse = Plugin:GetMouse()

local GrassModel = workspace:FindFirstChild("GrassModel")

local CoreGui = game:GetService('CoreGui')
local UserInput = game:GetService('UserInputService')

local Gui = Instance.new("ScreenGui", CoreGui)

local SelPart = Instance.new("Part", Gui)
SelPart.FormFactor = Enum.FormFactor.Custom

local SelSphere = Instance.new("SelectionSphere", SelPart)
SelSphere.Color = BrickColor.new("Br. yellowish green")
SelSphere.Transparency = 1
SelSphere.SurfaceTransparency = 1
SelSphere.SurfaceColor = BrickColor.new("Br. yellowish green")
SelSphere.Adornee = SelPart

local ChunkSize = 32
local SelectionSize, SelectionDensity = 12, 5
local LastCursorDistance = 300
local KeysDown, MouseDown = {}, false

local max, min = math.max, math.min

VolumeGrass.Click:connect(function()
	Active = not Active
	SelPart.Size = Vector3.new(1, 1, 1) * SelectionSize + Vector3.new(0.1, 0.1, 0.1)
	SelSphere.Transparency = Active and min(SelectionDensity/10, 0.8) or 1
	SelSphere.SurfaceTransparency = Active and min(SelectionDensity/10 + 0.4, 0.8) or 1
	if Active then
		Plugin:Activate(true)
		Mouse.TargetFilter = GrassModel
		if not GrassModel then
			GrassModel = Instance.new("Model", workspace)
			GrassModel.Name = "GrassModel"
		end
	end
end)

function Scrollwheel(Delta)
	if Active then
		if KeysDown[Enum.KeyCode.LeftShift] or KeysDown[Enum.KeyCode.RightShift] then
			SelectionSize = max(4, min(200, SelectionSize + Delta * 4))
			SelPart.Size = Vector3.new(1, 1, 1) * SelectionSize + Vector3.new(0.1, 0.1, 0.1)
		elseif KeysDown[Enum.KeyCode.LeftControl] or KeysDown[Enum.KeyCode.RightControl] then
			SelectionDensity = max(1, min(10, SelectionDensity - Delta))
			SelSphere.Transparency = min(SelectionDensity/10, 0.8)
			SelSphere.SurfaceTransparency = min(SelectionDensity/10 + 0.4, 0.8)
		end
	end
end

UserInput.InputBegan:connect(function(Event, Soaked)
	KeysDown[Event.KeyCode] = true
	if Event.UserInputType == Enum.UserInputType.MouseButton1 and not Soaked and Active then
		MouseDown = true
	end
end)

UserInput.InputEnded:connect(function(Event, Soaked)
	KeysDown[Event.KeyCode] = nil
	if Event.UserInputType == Enum.UserInputType.MouseButton1 and MouseDown then
		MouseDown = false
		
		if Active then
			if KeysDown[Enum.KeyCode.LeftShift] or KeysDown[Enum.KeyCode.RightShift] then
				for _, v in ipairs(GrassModel:GetChildren()) do
					if (v.Position - Mouse.Hit.p).magnitude < SelectionSize then
						v:Destroy()
					end
				end
			else
				local Part = Instance.new("Part", GrassModel)
				Part.Anchored = true
				Part.CanCollide = false
				Part.FormFactor = Enum.FormFactor.Custom
				Part.Size = Vector3.new(SelectionSize, 0.2, SelectionSize)
				Part.Reflectance = 1 - SelectionDensity/20
				Part.Transparency = 0.8
				Part.CFrame = CFrame.new(Mouse.Hit.p)
				Part.BrickColor = BrickColor.new("Br. yellowish green")
				Instance.new("CylinderMesh", Part)
			end
		end
	end
end)

Mouse.WheelForward:connect(function()
	Scrollwheel(1)
end)
Mouse.WheelBackward:connect(function()
	Scrollwheel(-1)
end)

local RenderStepped = game:GetService("RunService").RenderStepped
while true do
	if Active then
		local MainPoint = Mouse.Hit.p - Mouse.UnitRay.Direction * 0.05
		if not Mouse.Target then
			MainPoint = workspace.CurrentCamera.CoordinateFrame.p + Mouse.UnitRay.Direction * LastCursorDistance
		end
		
		SelPart.CFrame = CFrame.new(MainPoint)
		
		LastCursorDistance = max(20 + SelectionSize * 1.5, (MainPoint - workspace.CurrentCamera.CoordinateFrame.p).magnitude)
	end
	RenderStepped:wait()
end