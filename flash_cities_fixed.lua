-- Flash City & Starling City — XXL Grid, Wider Specials, Multi-Room Interiors, Safe Teleports, Streets Life
-- Specials guaranteed (incl. S.T.A.R. Labs), enterable; no ground gaps; bigger grid; more life.
-- Place this Script in ServerScriptService.

-- Services
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

print("=== FLASH CITIES (XXL GRID + SPECIALS FIXED + STREET LIFE) STARTING ===")

-- Config
local CITY_SIZE = 2400
local BLOCK_SIZE = 120
local CITY_SEPARATION = 8000
local CITY_HEIGHT = 10
local CITY_HALF = CITY_SIZE / 2

-- City centers
local CENTRAL_CENTER = Vector3.new(0, CITY_HEIGHT, 0)
local STARLING_CENTER = Vector3.new(CITY_SEPARATION, CITY_HEIGHT, 0)

-- World folders
local worldFolder = Instance.new("Folder")
worldFolder.Name = "FlashWorld"
worldFolder.Parent = Workspace

local citiesFolder = Instance.new("Folder")
citiesFolder.Name = "Cities"
citiesFolder.Parent = worldFolder

local roadsFolder = Instance.new("Folder")
roadsFolder.Name = "Roads"
roadsFolder.Parent = worldFolder

local bridgeFolder = Instance.new("Folder")
bridgeFolder.Name = "Bridge"
bridgeFolder.Parent = worldFolder

local propsFolder = Instance.new("Folder")
propsFolder.Name = "Props"
propsFolder.Parent = worldFolder

local specialsFolder = Instance.new("Folder")
specialsFolder.Name = "SpecialBuildings"
specialsFolder.Parent = worldFolder

local interiorsFolder = Instance.new("Folder")
interiorsFolder.Name = "Interiors"
interiorsFolder.Parent = worldFolder

local streetsFolder = Instance.new("Folder")
streetsFolder.Name = "Streets"
streetsFolder.Parent = worldFolder

local lifeFolder = Instance.new("Folder")
lifeFolder.Name = "Civilians"
lifeFolder.Parent = worldFolder

-- Specials lists
local CENTRAL_SPECIALS = {
	"S.T.A.R. Labs",
	"CCPD",
	"Jitters Coffee",
	"Flash Museum",
	"Barry's House",
	"Mercury Labs",
	"Iron Heights",
	"City Hall"
}

local STARLING_SPECIALS = {
	"Queen Consolidated",
	"Verdant Club",
	"Palmer Tech",
	"Arrow Cave",
	"SCPD",
	"Queen Mansion",
	"Starling City Hall",
	"Starling Hospital"
}

-- Utils
local function createPart(name, size, cframe, parent, color, material, anchored, collidable)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Anchored = anchored ~= false
	p.CanCollide = collidable ~= false
	if color then 
		p.Color = color 
	end
	if material then 
		p.Material = material 
	end
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function billboard(adornee, text, maxDist, color)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 420, 0, 84)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 10, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = maxDist or 4500
	gui.Adornee = adornee
	gui.Parent = adornee
	
	local tl = Instance.new("TextLabel")
	tl.BackgroundTransparency = 1
	tl.Size = UDim2.new(1, 0, 1, 0)
	tl.TextScaled = true
	tl.Font = Enum.Font.GothamBold
	tl.Text = text
	tl.TextColor3 = color or Color3.fromRGB(90, 90, 90)
	tl.TextStrokeTransparency = 0.35
	tl.TextStrokeColor3 = Color3.new(0, 0, 0)
	tl.Parent = gui
end

local function safeTeleport(player, targetCFrame)
	if not player or not player.Character then 
		return 
	end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	local hum = player.Character:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then 
		return 
	end
	hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	hum.Sit = false
	hum:ChangeState(Enum.HumanoidStateType.Jumping)
	hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
end

-- Lighting
local function setupLighting()
	Lighting.Brightness = 3
	Lighting.ClockTime = 13.5
	Lighting.FogStart = 1200
	Lighting.FogEnd = 80000
	Lighting.FogColor = Color3.fromRGB(200, 220, 255)
	Lighting.EnvironmentDiffuseScale = 0.7
	Lighting.EnvironmentSpecularScale = 0.6
	
	if not Lighting:FindFirstChild("Atmosphere") then
		local atmo = Instance.new("Atmosphere")
		atmo.Density = 0.06
		atmo.Offset = 0.2
		atmo.Color = Color3.fromRGB(199, 199, 199)
		atmo.Decay = Color3.fromRGB(106, 112, 125)
		atmo.Glare = 0.35
		atmo.Haze = 0.6
		atmo.Parent = Lighting
	end
	
	pcall(function()
		Workspace.StreamingEnabled = false
	end)
end

-- City ground (plus seam overlay)
local function createCityGround(name, center, color)
	local base = createPart(
		name .. "_Ground",
		Vector3.new(CITY_SIZE + 700, 28, CITY_SIZE + 700),
		CFrame.new(center.X, CITY_HEIGHT - 14, center.Z),
		citiesFolder,
		color or Color3.fromRGB(60, 170, 60),
		Enum.Material.Grass
	)
	
	createPart(
		name .. "_SeamOverlay",
		Vector3.new(CITY_SIZE + 740, 0.35, CITY_SIZE + 740),
		CFrame.new(center.X, CITY_HEIGHT + 0.01, center.Z),
		citiesFolder,
		Color3.fromRGB(64, 175, 64),
		Enum.Material.Grass
	)
	
	return base
end

-- Sidewalk helper
local function createSidewalk(name, size, cframe)
	return createPart(name, size, cframe, streetsFolder, Color3.fromRGB(200, 200, 200), Enum.Material.Concrete)
end

-- Cars
local function createCar(name, cframe, color)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = streetsFolder
	
	local body = createPart("CarBody", Vector3.new(11, 3, 6), cframe * CFrame.new(0, 1.6, 0), model, color or Color3.fromRGB(180, 40, 40), Enum.Material.Metal)
	local top = createPart("CarTop", Vector3.new(6, 2, 5), body.CFrame * CFrame.new(0, 2.5, 0), model, Color3.fromRGB(200, 200, 220), Enum.Material.Glass)
	top.Transparency = 0.2
	
	return model
end

-- Civilians (lightweight, tweened)
local function spawnCivilians(center, count)
	for i = 1, count do
		local npc = createPart("Civilian_" .. i, Vector3.new(2, 3.5, 2), CFrame.new(center + Vector3.new(math.random(-CITY_HALF/2, CITY_HALF/2), CITY_HEIGHT + 1.75, math.random(-CITY_HALF/2, CITY_HALF/2))), lifeFolder, Color3.fromRGB(math.random(80, 255), math.random(80, 255), math.random(80, 255)), Enum.Material.SmoothPlastic)
		npc.Anchored = true
		
		task.spawn(function()
			while npc.Parent do
				local target = center + Vector3.new(math.random(-CITY_HALF/2, CITY_HALF/2), CITY_HEIGHT + 1.75, math.random(-CITY_HALF/2, CITY_HALF/2))
				local tw = TweenService:Create(npc, TweenInfo.new(math.random(6, 12), Enum.EasingStyle.Linear), {CFrame = CFrame.new(target)})
				tw:Play()
				tw.Completed:Wait()
				task.wait(math.random(1, 3))
			end
		end)
	end
end

-- Roads + sidewalks + streetlights + cars
local function createRoadGrid(center, size, blockSize)
	local half = size / 2
	local roadWidth = 18
	local y = CITY_HEIGHT + 0.05

	for z = -half, half, blockSize do
		local h = createPart("Road_H", Vector3.new(size + roadWidth, 1, roadWidth), CFrame.new(center.X, y, center.Z + z), roadsFolder, Color3.fromRGB(40, 40, 40), Enum.Material.Asphalt)
		createSidewalk("Sidewalk_H_L", Vector3.new(size + roadWidth, 1, 7), h.CFrame * CFrame.new(0, 1, -roadWidth/2 - 3.5))
		createSidewalk("Sidewalk_H_R", Vector3.new(size + roadWidth, 1, 7), h.CFrame * CFrame.new(0, 1, roadWidth/2 + 3.5))
	end
	
	for x = -half, half, blockSize do
		local v = createPart("Road_V", Vector3.new(roadWidth, 1, size + roadWidth), CFrame.new(center.X + x, y, center.Z), roadsFolder, Color3.fromRGB(40, 40, 40), Enum.Material.Asphalt)
		createSidewalk("Sidewalk_V_L", Vector3.new(7, 1, size + roadWidth), v.CFrame * CFrame.new(-roadWidth/2 - 3.5, 1, 0))
		createSidewalk("Sidewalk_V_R", Vector3.new(7, 1, size + roadWidth), v.CFrame * CFrame.new(roadWidth/2 + 3.5, 1, 0))
	end

	local plaza = createPart("Plaza", Vector3.new(140, 1, 140), CFrame.new(center.X, y + 0.05, center.Z), roadsFolder, Color3.fromRGB(70, 70, 80), Enum.Material.Slate)
	local cw = Color3.fromRGB(240, 240, 240)
	createPart("Crosswalk_N", Vector3.new(140, 0.2, 2), plaza.CFrame * CFrame.new(0, 0.7, -71), streetsFolder, cw, Enum.Material.SmoothPlastic)
	createPart("Crosswalk_S", Vector3.new(140, 0.2, 2), plaza.CFrame * CFrame.new(0, 0.7, 71), streetsFolder, cw, Enum.Material.SmoothPlastic)
	createPart("Crosswalk_W", Vector3.new(2, 0.2, 140), plaza.CFrame * CFrame.new(-71, 0.7, 0), streetsFolder, cw, Enum.Material.SmoothPlastic)
	createPart("Crosswalk_E", Vector3.new(2, 0.2, 140), plaza.CFrame * CFrame.new(71, 0.7, 0), streetsFolder, cw, Enum.Material.SmoothPlastic)

	for z = -half, half, blockSize * 2 do
		for x = -half, half, blockSize * 2 do
			local base = CFrame.new(center.X + x, CITY_HEIGHT + 0.5, center.Z + z)
			local pole = createPart("StreetLightPole", Vector3.new(0.8, 14, 0.8), base * CFrame.new(6, 7, 6), streetsFolder, Color3.fromRGB(120, 120, 130), Enum.Material.Metal)
			local head = createPart("StreetLightHead", Vector3.new(3, 0.6, 1.2), pole.CFrame * CFrame.new(0, 7.5, -2), streetsFolder, Color3.fromRGB(250, 250, 200), Enum.Material.Neon)
			head.Transparency = 0.15
		end
	end

	-- Parked cars
	for i = -3, 3 do
		createCar("CarH_" .. i, CFrame.new(center.X + i*18, CITY_HEIGHT + 1, center.Z - 90) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(math.random(60, 255), math.random(60, 255), math.random(60, 255)))
	end
	for i = -3, 3 do
		createCar("CarV_" .. i, CFrame.new(center.X - 90, CITY_HEIGHT + 1, center.Z + i*18) * CFrame.Angles(0, 0, 0), Color3.fromRGB(math.random(60, 255), math.random(60, 255), math.random(60, 255)))
	end
end

-- Skyline
local function createCityBlocks(center)
	local grid = 8
	local spacing = (CITY_SIZE * 0.78) / grid
	local startX = center.X - (spacing * (grid - 1)) / 2
	local startZ = center.Z - (spacing * (grid - 1)) / 2
	
	for gx = 0, grid - 1 do
		for gz = 0, grid - 1 do
			local offset = Vector2.new(gx - (grid - 1)/2, gz - (grid - 1)/2)
			if offset.Magnitude > 1.7 then
				local basePos = Vector3.new(startX + gx * spacing, CITY_HEIGHT + 10, startZ + gz * spacing)
				local sx = math.random(50, 80)
				local sz = math.random(50, 80)
				local sy = math.random(150, 360)
				local color = Color3.fromRGB(140 + math.random(-25, 25), 140 + math.random(-25, 25), 140 + math.random(-25, 25))
				createPart("Block", Vector3.new(sx, sy, sz), CFrame.new(basePos.X, CITY_HEIGHT + sy/2, basePos.Z), propsFolder, color, Enum.Material.Concrete)
				createPart("Roof", Vector3.new(sx + 2, 2, sz + 2), CFrame.new(basePos.X, CITY_HEIGHT + sy + 1, basePos.Z), propsFolder, Color3.fromRGB(90, 90, 100), Enum.Material.Metal)
			end
		end
	end
end

-- Styles for specials (single definition)
local function getSpecialStyle(name)
	if name == "S.T.A.R. Labs" then
		return Vector3.new(300, 170, 300), Color3.fromRGB(175, 205, 245), Enum.Material.Glass
	elseif name == "CCPD" or name == "SCPD" then
		return Vector3.new(200, 120, 180), Color3.fromRGB(100, 120, 180), Enum.Material.Concrete
	elseif name == "Jitters Coffee" or name == "Verdant Club" then
		return Vector3.new(170, 100, 170), Color3.fromRGB(150, 100, 80), Enum.Material.Wood
	elseif name == "Flash Museum" then
		return Vector3.new(240, 150, 240), Color3.fromRGB(230, 210, 140), Enum.Material.Sand
	elseif name == "Barry's House" or name == "Queen Mansion" then
		return Vector3.new(200, 110, 200), Color3.fromRGB(210, 200, 190), Enum.Material.SmoothPlastic
	elseif name == "Mercury Labs" or name == "Palmer Tech" then
		return Vector3.new(240, 150, 240), Color3.fromRGB(170, 220, 220), Enum.Material.Glass
	elseif name == "Iron Heights" then
		return Vector3.new(280, 140, 250), Color3.fromRGB(120, 120, 120), Enum.Material.Concrete
	elseif name == "City Hall" or name == "Starling City Hall" then
		return Vector3.new(240, 140, 240), Color3.fromRGB(200, 200, 210), Enum.Material.Slate
	elseif name == "Queen Consolidated" then
		return Vector3.new(300, 200, 300), Color3.fromRGB(120, 170, 120), Enum.Material.Metal
	elseif name == "Arrow Cave" then
		return Vector3.new(200, 110, 200), Color3.fromRGB(70, 70, 70), Enum.Material.Slate
	elseif name == "Starling Hospital" then
		return Vector3.new(240, 150, 240), Color3.fromRGB(220, 240, 240), Enum.Material.SmoothPlastic
	end
	return Vector3.new(210, 120, 210), Color3.fromRGB(160, 160, 160), Enum.Material.Concrete
end

-- Interior room builder (solid floors, door gaps in walls)
local function createBoxRoom(model, name, centerCFrame, size, color, material, openings)
	local t = 2
	local sx, sy, sz = size.X, size.Y, size.Z
	local floor = createPart(name .. "_Floor", Vector3.new(sx, t, sz), centerCFrame * CFrame.new(0, -sy/2, 0), model, Color3.fromRGB(140, 140, 140), Enum.Material.Metal)
	local ceil = createPart(name .. "_Ceil", Vector3.new(sx, t, sz), centerCFrame * CFrame.new(0, sy/2, 0), model, color or Color3.fromRGB(220, 220, 230), material or Enum.Material.SmoothPlastic)
	ceil.Transparency = 0.05

	local doorW, wallH = 16, (sy - t)
	local function wallPart(wname, wsize, wcf)
		return createPart(wname, wsize, wcf, model, color or Color3.fromRGB(220, 220, 230), material or Enum.Material.SmoothPlastic)
	end

	do
		local z = sz/2 - t/2
		if openings and openings.front then
			local seg = (sx - doorW)/2
			if seg > 0 then
				wallPart(name .. "_FrontL", Vector3.new(seg, wallH, t), centerCFrame * CFrame.new(-sx/2 + seg/2, 0, z))
				wallPart(name .. "_FrontR", Vector3.new(seg, wallH, t), centerCFrame * CFrame.new(sx/2 - seg/2, 0, z))
			end
		else
			wallPart(name .. "_Front", Vector3.new(sx, wallH, t), centerCFrame * CFrame.new(0, 0, z))
		end
	end
	
	do
		local z = -sz/2 + t/2
		if openings and openings.back then
			local seg = (sx - doorW)/2
			if seg > 0 then
				wallPart(name .. "_BackL", Vector3.new(seg, wallH, t), centerCFrame * CFrame.new(-sx/2 + seg/2, 0, z))
				wallPart(name .. "_BackR", Vector3.new(seg, wallH, t), centerCFrame * CFrame.new(sx/2 - seg/2, 0, z))
			end
		else
			wallPart(name .. "_Back", Vector3.new(sx, wallH, t), centerCFrame * CFrame.new(0, 0, z))
		end
	end
	
	do
		local x = -sx/2 + t/2
		if openings and openings.left then
			local seg = (sz - doorW)/2
			if seg > 0 then
				wallPart(name .. "_LeftB", Vector3.new(t, wallH, seg), centerCFrame * CFrame.new(x, 0, -sz/2 + seg/2))
				wallPart(name .. "_LeftF", Vector3.new(t, wallH, seg), centerCFrame * CFrame.new(x, 0, sz/2 - seg/2))
			end
		else
			wallPart(name .. "_Left", Vector3.new(t, wallH, sz), centerCFrame * CFrame.new(x, 0, 0))
		end
	end
	
	do
		local x = sx/2 - t/2
		if openings and openings.right then
			local seg = (sz - doorW)/2
			if seg > 0 then
				wallPart(name .. "_RightB", Vector3.new(t, wallH, seg), centerCFrame * CFrame.new(x, 0, -sz/2 + seg/2))
				wallPart(name .. "_RightF", Vector3.new(t, wallH, seg), centerCFrame * CFrame.new(x, 0, sz/2 - seg/2))
			end
		else
			wallPart(name .. "_Right", Vector3.new(t, wallH, sz), centerCFrame * CFrame.new(x, 0, 0))
		end
	end

	return { floorTopY = (floor.Position.Y + floor.Size.Y/2), center = centerCFrame.Position }
end

local function addExit(interiorModel, spawnCFrame, exitTargetCFrame)
	createPart("SpawnPad", Vector3.new(14, 1, 14), spawnCFrame * CFrame.new(0, -3.6, 0), interiorModel, Color3.fromRGB(200, 220, 255), Enum.Material.SmoothPlastic)
	local exitPad = createPart("ExitPad", Vector3.new(12, 0.6, 12), spawnCFrame * CFrame.new(0, -3.2, 16), interiorModel, Color3.fromRGB(255, 120, 120), Enum.Material.Neon)
	billboard(exitPad, "Exit", 1500, Color3.fromRGB(255, 200, 200))
	
	local exitPrompt = Instance.new("ProximityPrompt")
	exitPrompt.ActionText = "Exit"
	exitPrompt.ObjectText = "Return"
	exitPrompt.HoldDuration = 0.2
	exitPrompt.MaxActivationDistance = 14
	exitPrompt.Parent = exitPad
	
	exitPrompt.Triggered:Connect(function(player)
		safeTeleport(player, exitTargetCFrame)
	end)
end

local function addLightToggle(interiorModel, anchorCFrame)
	local node = createPart("LightSwitch", Vector3.new(4, 1, 4), anchorCFrame * CFrame.new(12, -2, 0), interiorModel, Color3.fromRGB(255, 255, 120), Enum.Material.Neon)
	node.Transparency = 0.2
	billboard(node, "Toggle Lights", 1000, Color3.fromRGB(255, 255, 200))
	
	local point = Instance.new("PointLight")
	point.Brightness = 3
	point.Range = 80
	point.Color = Color3.fromRGB(255, 245, 220)
	point.Parent = interiorModel
	
	local on = true
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Toggle"
	prompt.ObjectText = "Lights"
	prompt.HoldDuration = 0.15
	prompt.MaxActivationDistance = 14
	prompt.Parent = node
	
	prompt.Triggered:Connect(function()
		on = not on
		point.Enabled = on
		node.Color = on and Color3.fromRGB(255, 255, 120) or Color3.fromRGB(120, 120, 120)
	end)
end

-- Generic multi-room interior
local function createGenericInterior(buildingName)
	local model = Instance.new("Model")
	model.Name = buildingName .. "_Interior"
	model.Parent = interiorsFolder
	
	local yBase = -110
	local lobbyInfo = createBoxRoom(model, "Lobby", CFrame.new(0, yBase, 0), Vector3.new(120, 24, 120), Color3.fromRGB(225, 230, 235), Enum.Material.SmoothPlastic, {front=true, right=true, back=true, left=true})
	createBoxRoom(model, "Office", CFrame.new(100, yBase, 0), Vector3.new(80, 20, 70), Color3.fromRGB(230, 235, 240), Enum.Material.SmoothPlastic, {left=true})
	createBoxRoom(model, "Storage", CFrame.new(0, yBase, 100), Vector3.new(80, 20, 70), Color3.fromRGB(210, 210, 210), Enum.Material.SmoothPlastic, {back=true})
	createBoxRoom(model, "Conference", CFrame.new(0, yBase, -100), Vector3.new(80, 20, 70), Color3.fromRGB(235, 235, 235), Enum.Material.SmoothPlastic, {front=true})
	createBoxRoom(model, "BreakRoom", CFrame.new(-100, yBase, 0), Vector3.new(80, 20, 60), Color3.fromRGB(205, 215, 220), Enum.Material.SmoothPlastic, {right=true})
	
	addLightToggle(model, CFrame.new(0, yBase, 0))
	local spawnCFrame = CFrame.new(0, lobbyInfo.floorTopY + 0.1, -32)
	return model, spawnCFrame
end

-- Arrow Cave (large)
local function createArrowCaveInterior()
	local model = Instance.new("Model")
	model.Name = "Arrow Cave_Interior"
	model.Parent = interiorsFolder
	
	local yBase = -130
	local caveInfo = createBoxRoom(model, "Cave", CFrame.new(0, yBase, 0), Vector3.new(140, 24, 140), Color3.fromRGB(60, 60, 65), Enum.Material.Slate, {right=true, front=true})
	createBoxRoom(model, "Range", CFrame.new(110, yBase, 0), Vector3.new(90, 22, 70), Color3.fromRGB(70, 70, 75), Enum.Material.Slate, {left=true})
	createBoxRoom(model, "Workshop", CFrame.new(0, yBase, 110), Vector3.new(90, 22, 70), Color3.fromRGB(75, 75, 80), Enum.Material.Slate, {back=true})
	
	addLightToggle(model, CFrame.new(0, yBase, 0))
	local spawnCFrame = CFrame.new(0, caveInfo.floorTopY + 0.1, -32)
	return model, spawnCFrame
end

-- S.T.A.R. Labs (XL multi-room + ring corridors)
local function createLabsInterior()
	local model = Instance.new("Model")
	model.Name = "S.T.A.R. Labs_Interior"
	model.Parent = interiorsFolder
	
	local yBase = -150

	local lobby = createBoxRoom(model, "Lobby", CFrame.new(0, yBase, 0), Vector3.new(200, 30, 160), Color3.fromRGB(235, 240, 250), Enum.Material.SmoothPlastic, {front=true, back=true, left=true, right=true})
	local cortex = createBoxRoom(model, "Cortex", CFrame.new(120, yBase, 0), Vector3.new(120, 22, 90), Color3.fromRGB(225, 235, 245), Enum.Material.SmoothPlastic, {left=true, right=true})
	local med = createBoxRoom(model, "MedBay", CFrame.new(0, yBase, 120), Vector3.new(100, 22, 80), Color3.fromRGB(220, 250, 250), Enum.Material.SmoothPlastic, {back=true})
	local speed = createBoxRoom(model, "SpeedLab", CFrame.new(-120, yBase, 0), Vector3.new(120, 22, 90), Color3.fromRGB(240, 230, 210), Enum.Material.SmoothPlastic, {right=true, left=true})
	local vault = createBoxRoom(model, "TimeVault", CFrame.new(0, yBase, -120), Vector3.new(100, 22, 80), Color3.fromRGB(60, 60, 60), Enum.Material.Metal, {front=true})
	local pipeline = createBoxRoom(model, "PipelineWing", CFrame.new(-220, yBase, 0), Vector3.new(110, 22, 90), Color3.fromRGB(90, 90, 100), Enum.Material.Metal, {right=true})
	local observation = createBoxRoom(model, "Observation", CFrame.new(220, yBase, 0), Vector3.new(110, 22, 90), Color3.fromRGB(215, 230, 245), Enum.Material.Glass, {left=true})

	createBoxRoom(model, "Hall_N", CFrame.new(0, yBase, -70), Vector3.new(180, 16, 24), Color3.fromRGB(220, 230, 240), Enum.Material.SmoothPlastic, {front=true, back=true})
	createBoxRoom(model, "Hall_S", CFrame.new(0, yBase, 70), Vector3.new(180, 16, 24), Color3.fromRGB(220, 230, 240), Enum.Material.SmoothPlastic, {front=true, back=true})
	createBoxRoom(model, "Hall_E", CFrame.new(70, yBase, 0), Vector3.new(24, 16, 140), Color3.fromRGB(220, 230, 240), Enum.Material.SmoothPlastic, {left=true, right=true})
	createBoxRoom(model, "Hall_W", CFrame.new(-70, yBase, 0), Vector3.new(24, 16, 140), Color3.fromRGB(220, 230, 240), Enum.Material.SmoothPlastic, {left=true, right=true})

	local console = createPart("CortexConsole", Vector3.new(16, 4, 6), CFrame.new(120, cortex.floorTopY + 2, -18), model, Color3.fromRGB(110, 150, 190), Enum.Material.Metal)
	billboard(console, "Run Diagnostics", 1400, Color3.fromRGB(200, 230, 255))
	local cPrompt = Instance.new("ProximityPrompt")
	cPrompt.ActionText = "Run"
	cPrompt.ObjectText = "Diagnostics"
	cPrompt.HoldDuration = 0.25
	cPrompt.MaxActivationDistance = 14
	cPrompt.Parent = console

	local medStation = createPart("MedStation", Vector3.new(12, 3, 8), CFrame.new(12, med.floorTopY + 1.5, 120), model, Color3.fromRGB(220, 255, 255), Enum.Material.SmoothPlastic)
	billboard(medStation, "Med Station (Heal)", 1400, Color3.fromRGB(220, 255, 255))
	local mPrompt = Instance.new("ProximityPrompt")
	mPrompt.ActionText = "Heal"
	mPrompt.ObjectText = "Med Station"
	mPrompt.HoldDuration = 0.2
	mPrompt.MaxActivationDistance = 14
	mPrompt.Parent = medStation
	
	mPrompt.Triggered:Connect(function(player)
		if player and player.Character then
			local hum = player.Character:FindFirstChildOfClass("Humanoid")
			if hum then 
				hum.Health = hum.MaxHealth 
			end
		end
	end)

	local speedRing = createPart("SpeedRing", Vector3.new(24, 2, 24), CFrame.new(-120, speed.floorTopY + 1, 0), model, Color3.fromRGB(255, 220, 120), Enum.Material.Neon)
	speedRing.Transparency = 0.25
	billboard(speedRing, "Speed Lab Platform", 1400, Color3.fromRGB(255, 235, 200))

	local spawnCFrame = CFrame.new(0, lobby.floorTopY + 0.1, -36)
	createPart("LobbySpawnPlate", Vector3.new(16, 1, 16), spawnCFrame * CFrame.new(0, -3.8, 0), model, Color3.fromRGB(210, 220, 235), Enum.Material.SmoothPlastic)

	addLightToggle(model, CFrame.new(0, yBase, 0))
	return model, spawnCFrame
end

-- Teleports
local function addTeleportDoor(doorPart, interiorModel, spawnCFrame, buildingName)
	billboard(doorPart, "Enter " .. buildingName, 3000, Color3.fromRGB(200, 255, 200))
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Enter"
	prompt.ObjectText = buildingName
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 14
	prompt.Parent = doorPart

	local exitTargetCFrame = doorPart.CFrame * CFrame.new(0, 2, -12)
	prompt.Triggered:Connect(function(player)
		safeTeleport(player, spawnCFrame)
	end)
	addExit(interiorModel, spawnCFrame, exitTargetCFrame)
end

-- Streetscape ring around specials
local function addBuildingStreetscape(name, body)
	local sz = body.Size
	local pos = body.Position
	local pad = 14
	createSidewalk(name .. "_Sidewalk", Vector3.new(sz.X + pad*2, 1, sz.Z + pad*2), CFrame.new(pos.X, CITY_HEIGHT + 0.8, pos.Z))
	
	local cornerOffsets = {
		Vector3.new(sz.X/2 + pad - 5, 0, sz.Z/2 + pad - 5),
		Vector3.new(-sz.X/2 - pad + 5, 0, sz.Z/2 + pad - 5),
		Vector3.new(sz.X/2 + pad - 5, 0, -sz.Z/2 - pad + 5),
		Vector3.new(-sz.X/2 - pad + 5, 0, -sz.Z/2 - pad + 5),
	}
	
	for i, off in ipairs(cornerOffsets) do
		local base = CFrame.new(pos + off + Vector3.new(0, 0.5, 0))
		local pole = createPart(name .. "_LampPole_" .. i, Vector3.new(0.8, 14, 0.8), base * CFrame.new(0, 7, 0), streetsFolder, Color3.fromRGB(120, 120, 130), Enum.Material.Metal)
		local head = createPart(name .. "_LampHead_" .. i, Vector3.new(3, 0.6, 1.2), pole.CFrame * CFrame.new(0, 7.5, 0), streetsFolder, Color3.fromRGB(250, 250, 200), Enum.Material.Neon)
		head.Transparency = 0.15
	end
end

-- Special building (XL shells, enterable) + STAR Labs facade
local function createSpecialBuilding(name, position)
	local size, color, material = getSpecialStyle(name)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = specialsFolder

	local body = createPart("Body", size, CFrame.new(position.X, CITY_HEIGHT + size.Y/2, position.Z), model, color, material)
	
	if name == "S.T.A.R. Labs" then
		createPart("WingA", Vector3.new(size.X * 0.5, size.Y * 0.7, size.Z * 0.45), body.CFrame * CFrame.new(size.X * 0.49, -size.Y * 0.15, 0), model, Color3.fromRGB(190, 210, 240), Enum.Material.Glass)
		createPart("WingB", Vector3.new(size.X * 0.5, size.Y * 0.7, size.Z * 0.45), body.CFrame * CFrame.new(-size.X * 0.49, -size.Y * 0.15, 0), model, Color3.fromRGB(190, 210, 240), Enum.Material.Glass)
		createPart("Atrium", Vector3.new(size.X * 0.78, size.Y * 0.58, 12), body.CFrame * CFrame.new(0, -size.Y * 0.08, -size.Z/2 - 6), model, Color3.fromRGB(210, 230, 255), Enum.Material.Glass)
	end

	local roof = createPart("Roof", Vector3.new(size.X + 10, 2, size.Z + 10), body.CFrame * CFrame.new(0, size.Y/2 + 1, 0), model, Color3.fromRGB(90, 90, 100), Enum.Material.Metal)
	local door = createPart("Door", Vector3.new(12, 18, 1), body.CFrame * CFrame.new(0, -size.Y/2 + 9, -size.Z/2 - 0.8), model, Color3.fromRGB(70, 120, 180), Enum.Material.Metal)
	door.CanCollide = true

	addBuildingStreetscape(name, body)

	local interiorModel, spawnCFrame
	if name == "Arrow Cave" then
		interiorModel, spawnCFrame = createArrowCaveInterior()
	elseif name == "S.T.A.R. Labs" then
		interiorModel, spawnCFrame = createLabsInterior()
	else
		interiorModel, spawnCFrame = createGenericInterior(name)
	end
	addTeleportDoor(door, interiorModel, spawnCFrame, name)

	local label = createPart("LabelBase", Vector3.new(14, 2, 14), roof.CFrame * CFrame.new(0, 7, 0), model, Color3.fromRGB(255, 255, 200), Enum.Material.Neon)
	billboard(label, name, 6000, Color3.fromRGB(255, 255, 230))

	return model
end

-- Place specials: guarantee key landmarks at fixed, visible spots + ring others
local function placeKeySpecial(center, name, offset)
	local pos = center + offset
	createSpecialBuilding(name, pos)
end

local function placeSpecials(center, names)
	local placed = {}
	-- Guarantee STAR Labs near Central; Queen Consolidated near Starling
	if center == CENTRAL_CENTER then
		placeKeySpecial(center, "S.T.A.R. Labs", Vector3.new(0, 0, -CITY_SIZE * 0.28))
		placed["S.T.A.R. Labs"] = true
	else
		placeKeySpecial(center, "Queen Consolidated", Vector3.new(0, 0, -CITY_SIZE * 0.28))
		placed["Queen Consolidated"] = true
	end
	
	local radius = CITY_SIZE * 0.36
	for i, name in ipairs(names) do
		if not placed[name] then
			local t = (i - 1) / #names
			local angle = t * math.pi * 2
			local pos = Vector3.new(center.X + math.cos(angle) * radius, CITY_HEIGHT, center.Z + math.sin(angle) * radius)
			createSpecialBuilding(name, pos)
		end
	end
end

-- City sign
local function createCitySign(cityName, center)
	local sign = createPart(cityName .. "_Sign", Vector3.new(64, 10, 2), CFrame.new(center.X, CITY_HEIGHT + 28, center.Z - CITY_HALF - 28), worldFolder, Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
	billboard(sign, cityName:upper(), 7000)
end

-- Build a city
local function buildCity(center, label, groundColor, specials)
	createCityGround(label, center, groundColor)
	createRoadGrid(center, CITY_SIZE, BLOCK_SIZE)
	createCityBlocks(center)
	if specials and #specials > 0 then 
		placeSpecials(center, specials) 
	end
	createCitySign(label, center)
	-- Add life
	spawnCivilians(center, 30)
end

-- Bridge (ground connector)
local function buildBridgeRoad()
	local centralEdgeX = CENTRAL_CENTER.X + CITY_HALF + 12
	local starlingEdgeX = STARLING_CENTER.X - CITY_HALF - 12
	local length = math.max(100, starlingEdgeX - centralEdgeX)
	local midX = centralEdgeX + length / 2
	local width = 84
	
	local deck = createPart("BridgeRoad", Vector3.new(length, 2, width), CFrame.new(midX, CITY_HEIGHT + 0.05, 0), bridgeFolder, Color3.fromRGB(45, 45, 45), Enum.Material.Asphalt)
	local railColor = Color3.fromRGB(200, 200, 210)
	createPart("Rail_L", Vector3.new(length, 3, 1), deck.CFrame * CFrame.new(0, 2, -width/2 + 0.5), bridgeFolder, railColor, Enum.Material.Metal)
	createPart("Rail_R", Vector3.new(length, 3, 1), deck.CFrame * CFrame.new(0, 2, width/2 - 0.5), bridgeFolder, railColor, Enum.Material.Metal)
	
	for i = 0, 20 do
		local x = centralEdgeX + (length * (i/20))
		local pole = createPart("Beacon_" .. i, Vector3.new(2, 26, 2), CFrame.new(x, CITY_HEIGHT + 13, -width/2 + 4), bridgeFolder, Color3.fromRGB(255, 255, 190), Enum.Material.Neon)
		pole.Transparency = 0.2
	end
end

-- Spawns
local function createSpawns()
	local spawn1 = Instance.new("SpawnLocation")
	spawn1.Name = "CitySpawn"
	spawn1.Size = Vector3.new(6, 1, 6)
	spawn1.CFrame = CFrame.new(CENTRAL_CENTER + Vector3.new(0, 2, 0))
	spawn1.BrickColor = BrickColor.new("Bright yellow")
	spawn1.Material = Enum.Material.Neon
	spawn1.Anchored = true
	spawn1.Parent = worldFolder

	local spawn2 = Instance.new("SpawnLocation")
	spawn2.Name = "StarlingSpawn"
	spawn2.Size = Vector3.new(6, 1, 6)
	spawn2.CFrame = CFrame.new(STARLING_CENTER + Vector3.new(0, 2, 0))
	spawn2.BrickColor = BrickColor.new("Bright blue")
	spawn2.Material = Enum.Material.Neon
	spawn2.Anchored = true
	spawn2.Parent = worldFolder

	return spawn1, spawn2
end

-- Init
math.randomseed(os.time())
setupLighting()
buildCity(CENTRAL_CENTER, "Central City", Color3.fromRGB(60, 170, 60), CENTRAL_SPECIALS)
buildCity(STARLING_CENTER, "Starling City", Color3.fromRGB(80, 120, 180), STARLING_SPECIALS)
buildBridgeRoad()
local spawnA, spawnB = createSpawns()

for _, obj in ipairs(Workspace:GetChildren()) do
	if obj:IsA("SpawnLocation") and (obj ~= spawnA and obj ~= spawnB) then
		obj:Destroy()
	end
end

print("=== FLASH CITIES (XXL GRID + SPECIALS FIXED + STREET LIFE) READY ===")