--[[
    ULTIMATE CITY SIMULATION - Fixed & Improved!
    Better spacing, no gaps, smooth performance
    Place in ServerScriptService
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Constants
local CITY_SIZE = 400
local BUILDING_COUNT = 30  -- Reduced from 50 to 30 for less crowding
local CAR_COUNT = 15       -- Reduced from 20 to 15
local FPS_TARGET = 60

-- Colors
local COLORS = {
    SKY_DAWN = Color3.fromRGB(255, 140, 0),
    SKY_DAY = Color3.fromRGB(135, 206, 235),
    SKY_NIGHT = Color3.fromRGB(20, 20, 40),
    BUILDING_TECH = Color3.fromRGB(100, 150, 200),
    BUILDING_BUSINESS = Color3.fromRGB(120, 120, 120),
    BUILDING_INDUSTRIAL = Color3.fromRGB(80, 80, 80),
    BUILDING_RESIDENTIAL = Color3.fromRGB(110, 110, 100),
    ROAD = Color3.fromRGB(45, 45, 45),
    GRASS = Color3.fromRGB(34, 139, 34),
    WATER = Color3.fromRGB(0, 100, 200),
    BRIDGE = Color3.fromRGB(105, 105, 105),
    GROUND = Color3.fromRGB(60, 60, 60),
    CAR_COLORS = {
        Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(255, 165, 0), Color3.fromRGB(128, 0, 128)
    }
}

-- Main Simulation Class
local UltimateCity = {}
UltimateCity.__index = UltimateCity

function UltimateCity.new()
    local self = setmetatable({}, UltimateCity)
    
    -- Core systems
    self.buildings = {}
    self.vehicles = {}
    self.parks = {}
    self.roads = {}
    self.groundParts = {}
    
    -- Dynamic systems
    self.timeOfDay = 12.0
    self.weather = "sunny"
    self.trafficDensity = 0.7
    self.cityPopulation = 0
    self.economyLevel = 100
    
    -- Performance optimization
    self.updateCounter = 0
    
    -- Initialize everything
    self:createGround()
    self:setupEnvironment()
    self:createCities()
    self:createRoads()
    self:createParks()
    self:spawnVehicles()
    self:setupLighting()
    self:createUI()
    self:startSimulation()
    
    return self
end

function UltimateCity:createGround()
    -- Create main ground platform
    local ground = Instance.new("Part")
    ground.Name = "MainGround"
    ground.Size = Vector3.new(1000, 10, 1000)
    ground.Position = Vector3.new(0, -5, 0)
    ground.Color = COLORS.GROUND
    ground.Material = Enum.Material.Concrete
    ground.Anchored = true
    ground.Parent = workspace
    
    -- Create city-specific ground areas
    local centralGround = Instance.new("Part")
    centralGround.Name = "CentralGround"
    centralGround.Size = Vector3.new(CITY_SIZE, 2, CITY_SIZE)
    centralGround.Position = Vector3.new(-CITY_SIZE/2, 1, 0)
    centralGround.Color = Color3.fromRGB(70, 70, 70)
    centralGround.Material = Enum.Material.Concrete
    centralGround.Anchored = true
    centralGround.Parent = workspace
    
    local starlingGround = Instance.new("Part")
    starlingGround.Name = "StarlingGround"
    starlingGround.Size = Vector3.new(CITY_SIZE, 2, CITY_SIZE)
    starlingGround.Position = Vector3.new(CITY_SIZE/2, 1, 0)
    starlingGround.Color = Color3.fromRGB(70, 70, 70)
    starlingGround.Material = Enum.Material.Concrete
    starlingGround.Anchored = true
    starlingGround.Parent = workspace
    
    table.insert(self.groundParts, ground)
    table.insert(self.groundParts, centralGround)
    table.insert(self.groundParts, starlingGround)
end

function UltimateCity:setupEnvironment()
    -- Create water between cities
    local water = Instance.new("Part")
    water.Name = "Water"
    water.Size = Vector3.new(120, 20, CITY_SIZE * 2)
    water.Position = Vector3.new(0, -10, 0)
    water.Color = COLORS.WATER
    water.Material = Enum.Material.ForceField
    water.Anchored = true
    water.Parent = workspace
    
    -- Create bridge
    local bridge = Instance.new("Part")
    bridge.Name = "MegaBridge"
    bridge.Size = Vector3.new(120, 10, 40)
    bridge.Position = Vector3.new(0, 5, 0)
    bridge.Color = COLORS.BRIDGE
    bridge.Material = Enum.Material.Concrete
    bridge.Anchored = true
    bridge.Parent = workspace
    
    -- Bridge supports
    for i = -2, 2 do
        local support = Instance.new("Part")
        support.Name = "BridgeSupport"
        support.Size = Vector3.new(10, 30, 10)
        support.Position = Vector3.new(i * 30, -10, 0)
        support.Color = Color3.fromRGB(60, 60, 60)
        support.Material = Enum.Material.Concrete
        support.Anchored = true
        support.Parent = workspace
    end
    
    -- Bridge railings
    local leftRailing = Instance.new("Part")
    leftRailing.Name = "LeftRailing"
    leftRailing.Size = Vector3.new(120, 8, 4)
    leftRailing.Position = Vector3.new(0, 9, -22)
    leftRailing.Color = Color3.fromRGB(80, 80, 80)
    leftRailing.Material = Enum.Material.Metal
    leftRailing.Anchored = true
    leftRailing.Parent = workspace
    
    local rightRailing = Instance.new("Part")
    rightRailing.Name = "RightRailing"
    rightRailing.Size = Vector3.new(120, 8, 4)
    rightRailing.Position = Vector3.new(0, 9, 22)
    rightRailing.Color = Color3.fromRGB(80, 80, 80)
    rightRailing.Material = Enum.Material.Metal
    rightRailing.Anchored = true
    rightRailing.Parent = workspace
end

function UltimateCity:createCities()
    -- Central City (Left) - More spaced out
    self:createCity("Central", -CITY_SIZE/2, {
        tech = 0.4, business = 0.3, residential = 0.3
    })
    
    -- Starling City (Right) - More spaced out
    self:createCity("Starling", CITY_SIZE/2, {
        industrial = 0.4, harbor = 0.3, residential = 0.3
    })
end

function UltimateCity:createCity(name, centerX, buildingTypes)
    local buildings = {}
    local usedPositions = {}
    
    for i = 1, BUILDING_COUNT do
        local attempts = 0
        local x, z
        
        -- Try to find a non-overlapping position
        repeat
            x = centerX + math.random(-CITY_SIZE/2 + 50, CITY_SIZE/2 - 50)
            z = math.random(-CITY_SIZE/2 + 50, CITY_SIZE/2 - 50)
            attempts = attempts + 1
        until not self:isPositionUsed(x, z, usedPositions) or attempts > 50
        
        if attempts <= 50 then
            table.insert(usedPositions, {x = x, z = z})
            
            local building = self:createBuilding({
                x = x,
                z = z,
                type = self:getRandomBuildingType(buildingTypes),
                height = math.random(40, 100)  -- Reduced height range
            })
            table.insert(buildings, building)
        end
    end
    
    self.buildings[name] = buildings
end

function UltimateCity:isPositionUsed(x, z, usedPositions)
    for _, pos in ipairs(usedPositions) do
        local distance = math.sqrt((x - pos.x)^2 + (z - pos.z)^2)
        if distance < 60 then  -- Minimum distance between buildings
            return true
        end
    end
    return false
end

function UltimateCity:createBuilding(data)
    local building = Instance.new("Part")
    building.Name = data.type .. "_Building"
    building.Size = Vector3.new(25, data.height, 25)  -- Fixed size for better spacing
    building.Position = Vector3.new(data.x, data.height/2 + 1, data.z)
    building.Color = self:getBuildingColor(data.type)
    building.Material = Enum.Material.Concrete
    building.Anchored = true
    building.Parent = workspace
    
    -- Add windows
    self:addBuildingWindows(building, data.height)
    
    -- Add roof details
    self:addRoofDetails(building, data.type)
    
    return building
end

function UltimateCity:getBuildingColor(buildingType)
    local colors = {
        tech = COLORS.BUILDING_TECH,
        business = COLORS.BUILDING_BUSINESS,
        industrial = COLORS.BUILDING_INDUSTRIAL,
        residential = COLORS.BUILDING_RESIDENTIAL,
        harbor = Color3.fromRGB(90, 100, 110)
    }
    return colors[buildingType] or COLORS.BUILDING_BUSINESS
end

function UltimateCity:getRandomBuildingType(types)
    local rand = math.random()
    local cumulative = 0
    
    for type, probability in pairs(types) do
        cumulative = cumulative + probability
        if rand <= cumulative then
            return type
        end
    end
    
    return "business"
end

function UltimateCity:addBuildingWindows(building, height)
    local windowCount = math.floor(height / 20)  -- Less windows for cleaner look
    
    for i = 1, windowCount do
        local window = Instance.new("Part")
        window.Name = "Window"
        window.Size = Vector3.new(4, 4, 0.2)
        window.Position = building.Position + Vector3.new(
            math.random(-10, 10),
            -height/2 + i * 20,
            building.Size.Z/2 + 0.1
        )
        window.Color = math.random() < 0.7 and Color3.fromRGB(255, 255, 200) or Color3.fromRGB(20, 20, 20)
        window.Material = Enum.Material.Neon
        window.Anchored = true
        window.Parent = building
    end
end

function UltimateCity:addRoofDetails(building, buildingType)
    if buildingType == "tech" then
        -- Add antenna
        local antenna = Instance.new("Part")
        antenna.Name = "Antenna"
        antenna.Size = Vector3.new(2, 25, 2)
        antenna.Position = building.Position + Vector3.new(0, building.Size.Y/2 + 12, 0)
        antenna.Color = Color3.fromRGB(200, 200, 200)
        antenna.Material = Enum.Material.Metal
        antenna.Anchored = true
        antenna.Parent = building
    elseif buildingType == "industrial" then
        -- Add smokestack
        local smokestack = Instance.new("Part")
        smokestack.Name = "Smokestack"
        smokestack.Size = Vector3.new(8, 30, 8)
        smokestack.Position = building.Position + Vector3.new(0, building.Size.Y/2 + 15, 0)
        smokestack.Color = Color3.fromRGB(100, 100, 100)
        smokestack.Material = Enum.Material.Concrete
        smokestack.Anchored = true
        smokestack.Parent = building
    end
end

function UltimateCity:createRoads()
    -- Main roads connecting cities
    local mainRoad1 = Instance.new("Part")
    mainRoad1.Name = "MainRoad1"
    mainRoad1.Size = Vector3.new(400, 2, 20)
    mainRoad1.Position = Vector3.new(0, 2, -100)
    mainRoad1.Color = COLORS.ROAD
    mainRoad1.Material = Enum.Material.Asphalt
    mainRoad1.Anchored = true
    mainRoad1.Parent = workspace
    
    local mainRoad2 = Instance.new("Part")
    mainRoad2.Name = "MainRoad2"
    mainRoad2.Size = Vector3.new(400, 2, 20)
    mainRoad2.Position = Vector3.new(0, 2, 100)
    mainRoad2.Color = COLORS.ROAD
    mainRoad2.Material = Enum.Material.Asphalt
    mainRoad2.Anchored = true
    mainRoad2.Parent = workspace
    
    -- Bridge road
    local bridgeRoad = Instance.new("Part")
    bridgeRoad.Name = "BridgeRoad"
    bridgeRoad.Size = Vector3.new(120, 2, 30)
    bridgeRoad.Position = Vector3.new(0, 6, 0)
    bridgeRoad.Color = COLORS.ROAD
    bridgeRoad.Material = Enum.Material.Asphalt
    bridgeRoad.Anchored = true
    bridgeRoad.Parent = workspace
    
    table.insert(self.roads, mainRoad1)
    table.insert(self.roads, mainRoad2)
    table.insert(self.roads, bridgeRoad)
end

function UltimateCity:createParks()
    local parks = {
        {name = "Central Park", x = -150, z = 150, size = 100},
        {name = "Starling Park", x = 150, z = 150, size = 100},
        {name = "Bridge Park", x = 0, z = 0, size = 60}
    }
    
    for _, parkData in ipairs(parks) do
        self:createPark(parkData)
    end
end

function UltimateCity:createPark(data)
    -- Grass area
    local grass = Instance.new("Part")
    grass.Name = data.name .. "_Grass"
    grass.Size = Vector3.new(data.size, 2, data.size)
    grass.Position = Vector3.new(data.x, 2, data.z)
    grass.Color = COLORS.GRASS
    grass.Material = Enum.Material.Grass
    grass.Anchored = true
    grass.Parent = workspace
    
    -- Add trees
    for i = 1, 12 do
        local tree = self:createTree(Vector3.new(
            data.x + math.random(-data.size/2 + 15, data.size/2 - 15),
            0,
            data.z + math.random(-data.size/2 + 15, data.size/2 - 15)
        ))
    end
    
    -- Add benches
    for i = 1, 4 do
        local bench = self:createBench(Vector3.new(
            data.x + math.random(-data.size/2 + 20, data.size/2 - 20),
            0,
            data.z + math.random(-data.size/2 + 20, data.size/2 - 20)
        ))
    end
    
    -- Add fountain for central parks
    if data.name ~= "Bridge Park" then
        local fountain = Instance.new("Part")
        fountain.Name = "Fountain"
        fountain.Size = Vector3.new(20, 15, 20)
        fountain.Position = Vector3.new(data.x, 9, data.z)
        fountain.Color = Color3.fromRGB(200, 200, 200)
        fountain.Material = Enum.Material.Concrete
        fountain.Shape = Enum.PartType.Cylinder
        fountain.Anchored = true
        fountain.Parent = workspace
    end
end

function UltimateCity:createTree(position)
    -- Trunk
    local trunk = Instance.new("Part")
    trunk.Name = "TreeTrunk"
    trunk.Size = Vector3.new(6, 25, 6)
    trunk.Position = position + Vector3.new(0, 12, 0)
    trunk.Color = Color3.fromRGB(101, 67, 33)
    trunk.Material = Enum.Material.Wood
    trunk.Anchored = true
    trunk.Parent = workspace
    
    -- Leaves
    local leaves = Instance.new("Part")
    leaves.Name = "TreeLeaves"
    leaves.Size = Vector3.new(20, 20, 20)
    leaves.Position = position + Vector3.new(0, 30, 0)
    leaves.Color = Color3.fromRGB(0, 120, 0)
    leaves.Material = Enum.Material.Grass
    leaves.Shape = Enum.PartType.Ball
    leaves.Anchored = true
    leaves.Parent = workspace
    
    return {trunk = trunk, leaves = leaves}
end

function UltimateCity:createBench(position)
    local bench = Instance.new("Part")
    bench.Name = "Bench"
    bench.Size = Vector3.new(30, 5, 12)
    bench.Position = position + Vector3.new(0, 2.5, 0)
    bench.Color = Color3.fromRGB(101, 67, 33)
    bench.Material = Enum.Material.Wood
    bench.Anchored = true
    bench.Parent = workspace
    
    return bench
end

function UltimateCity:spawnVehicles()
    for i = 1, CAR_COUNT do
        local vehicle = self:createVehicle()
        table.insert(self.vehicles, vehicle)
    end
end

function UltimateCity:createVehicle()
    local car = Instance.new("Part")
    car.Name = "Vehicle"
    car.Size = Vector3.new(25, 12, 12)
    car.Color = COLORS.CAR_COLORS[math.random(1, #COLORS.CAR_COLORS)]
    car.Material = Enum.Material.Metal
    car.Anchored = true
    car.Parent = workspace
    
    -- Random starting position on roads
    local roadPositions = {
        Vector3.new(0, 7, -100),
        Vector3.new(0, 7, 100),
        Vector3.new(0, 7, 0)
    }
    
    local startPos = roadPositions[math.random(1, #roadPositions)]
    car.Position = startPos
    
    -- Vehicle properties
    local vehicle = {
        part = car,
        speed = math.random(20, 40),
        direction = math.random() * 2 * math.pi,
        targetX = math.random(-CITY_SIZE, CITY_SIZE),
        targetZ = math.random(-CITY_SIZE, CITY_SIZE),
        lastUpdate = 0
    }
    
    return vehicle
end

function UltimateCity:updateVehicles()
    for _, vehicle in ipairs(self.vehicles) do
        -- Smooth movement towards target
        local direction = math.atan2(vehicle.targetZ - vehicle.part.Position.Z, vehicle.targetX - vehicle.part.Position.X)
        vehicle.part.Position = vehicle.part.Position + Vector3.new(
            math.cos(direction) * vehicle.speed * (1/60),
            0,
            math.sin(direction) * vehicle.speed * (1/60)
        )
        
        -- Update target when close
        local distance = math.sqrt(
            (vehicle.targetX - vehicle.part.Position.X)^2 + 
            (vehicle.targetZ - vehicle.part.Position.Z)^2
        )
        
        if distance < 30 then
            vehicle.targetX = math.random(-CITY_SIZE, CITY_SIZE)
            vehicle.targetZ = math.random(-CITY_SIZE, CITY_SIZE)
        end
        
        -- Keep vehicles on roads
        if vehicle.part.Position.Y < 5 then
            vehicle.part.Position = Vector3.new(vehicle.part.Position.X, 7, vehicle.part.Position.Z)
        end
    end
end

function UltimateCity:setupLighting()
    Lighting.Ambient = COLORS.SKY_DAY
    Lighting.Brightness = 2
    Lighting.TimeOfDay = "14:00:00"
end

function UltimateCity:updateLighting()
    self.timeOfDay = self.timeOfDay + 0.003  -- Slower time progression
    
    if self.timeOfDay >= 24 then
        self.timeOfDay = 0
    end
    
    -- Smooth sky color transitions
    local skyColor
    if self.timeOfDay < 6 or self.timeOfDay > 18 then
        skyColor = COLORS.SKY_NIGHT
    elseif self.timeOfDay < 8 or self.timeOfDay > 16 then
        skyColor = COLORS.SKY_DAWN
    else
        skyColor = COLORS.SKY_DAY
    end
    
    Lighting.Ambient = skyColor
    Lighting.Brightness = math.sin(self.timeOfDay * math.pi / 12) * 0.5 + 1.5
end

function UltimateCity:createUI()
    for _, player in ipairs(Players:GetPlayers()) do
        self:createPlayerGUI(player)
    end
    
    Players.PlayerAdded:Connect(function(player)
        self:createPlayerGUI(player)
    end)
end

function UltimateCity:createPlayerGUI(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UltimateCityGUI"
    screenGui.Parent = playerGui
    
    -- Main info panel
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "InfoFrame"
    infoFrame.Size = UDim2.new(0, 320, 0, 220)
    infoFrame.Position = UDim2.new(0, 10, 0, 10)
    infoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    infoFrame.BackgroundTransparency = 0.1
    infoFrame.Parent = screenGui
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = infoFrame
    
    -- Time display
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.Size = UDim2.new(1, 0, 0, 35)
    timeLabel.Position = UDim2.new(0, 0, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "Time: 14:00"
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.SourceSansBold
    timeLabel.Parent = infoFrame
    
    -- Population display
    local popLabel = Instance.new("TextLabel")
    popLabel.Name = "PopLabel"
    popLabel.Size = UDim2.new(1, 0, 0, 35)
    popLabel.Position = UDim2.new(0, 0, 0, 35)
    popLabel.BackgroundTransparency = 1
    popLabel.Text = "Population: 0"
    popLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    popLabel.TextScaled = true
    popLabel.Font = Enum.Font.SourceSans
    popLabel.Parent = infoFrame
    
    -- Economy display
    local econLabel = Instance.new("TextLabel")
    econLabel.Name = "EconLabel"
    econLabel.Size = UDim2.new(1, 0, 0, 35)
    econLabel.Position = UDim2.new(0, 0, 0, 70)
    econLabel.BackgroundTransparency = 1
    econLabel.Text = "Economy: 100%"
    econLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    econLabel.TextScaled = true
    econLabel.Font = Enum.Font.SourceSans
    econLabel.Parent = infoFrame
    
    -- Weather display
    local weatherLabel = Instance.new("TextLabel")
    weatherLabel.Name = "WeatherLabel"
    weatherLabel.Size = UDim2.new(1, 0, 0, 35)
    weatherLabel.Position = UDim2.new(0, 0, 0, 105)
    weatherLabel.BackgroundTransparency = 1
    weatherLabel.Text = "Weather: Sunny"
    weatherLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    weatherLabel.TextScaled = true
    weatherLabel.Font = Enum.Font.SourceSans
    weatherLabel.Parent = infoFrame
    
    -- Buildings count
    local buildingsLabel = Instance.new("TextLabel")
    buildingsLabel.Name = "BuildingsLabel"
    buildingsLabel.Size = UDim2.new(1, 0, 0, 35)
    buildingsLabel.Position = UDim2.new(0, 0, 0, 140)
    buildingsLabel.BackgroundTransparency = 1
    buildingsLabel.Text = "Buildings: 60"
    buildingsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    buildingsLabel.TextScaled = true
    buildingsLabel.Font = Enum.Font.SourceSans
    buildingsLabel.Parent = infoFrame
    
    -- City labels
    local centralLabel = Instance.new("TextLabel")
    centralLabel.Name = "CentralLabel"
    centralLabel.Size = UDim2.new(0, 180, 0, 50)
    centralLabel.Position = UDim2.new(0, 10, 0, 250)
    centralLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    centralLabel.BackgroundTransparency = 0.2
    centralLabel.Text = "CENTRAL CITY"
    centralLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    centralLabel.TextScaled = true
    centralLabel.Font = Enum.Font.SourceSansBold
    centralLabel.Parent = screenGui
    
    local centralCorner = Instance.new("UICorner")
    centralCorner.CornerRadius = UDim.new(0, 8)
    centralCorner.Parent = centralLabel
    
    local starlingLabel = Instance.new("TextLabel")
    starlingLabel.Name = "StarlingLabel"
    starlingLabel.Size = UDim2.new(0, 180, 0, 50)
    starlingLabel.Position = UDim2.new(1, -190, 0, 250)
    starlingLabel.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    starlingLabel.BackgroundTransparency = 0.2
    starlingLabel.Text = "STARLING CITY"
    starlingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    starlingLabel.TextScaled = true
    starlingLabel.Font = Enum.Font.SourceSansBold
    starlingLabel.Parent = screenGui
    
    local starlingCorner = Instance.new("UICorner")
    starlingCorner.CornerRadius = UDim.new(0, 8)
    starlingCorner.Parent = starlingLabel
    
    -- Store GUI references
    self.playerGUIs = self.playerGUIs or {}
    self.playerGUIs[player] = {
        timeLabel = timeLabel,
        popLabel = popLabel,
        econLabel = econLabel,
        weatherLabel = weatherLabel,
        buildingsLabel = buildingsLabel
    }
end

function UltimateCity:updateUI()
    for player, gui in pairs(self.playerGUIs or {}) do
        if gui.timeLabel then
            gui.timeLabel.Text = string.format("Time: %.1f:00", self.timeOfDay)
        end
        if gui.popLabel then
            gui.popLabel.Text = string.format("Population: %d", self.cityPopulation)
        end
        if gui.econLabel then
            gui.econLabel.Text = string.format("Economy: %d%%", self.economyLevel)
        end
        if gui.weatherLabel then
            gui.weatherLabel.Text = "Weather: " .. self.weather:gsub("^%l", string.upper)
        end
        if gui.buildingsLabel then
            local totalBuildings = 0
            for _, cityBuildings in pairs(self.buildings) do
                totalBuildings = totalBuildings + #cityBuildings
            end
            gui.buildingsLabel.Text = string.format("Buildings: %d", totalBuildings)
        end
    end
end

function UltimateCity:updateSimulation()
    self.updateCounter = self.updateCounter + 1
    
    -- Update systems at different rates for performance
    if self.updateCounter % 1 == 0 then -- Every frame
        self:updateVehicles()
        self:updateLighting()
    end
    
    if self.updateCounter % 60 == 0 then -- Every second
        self:updateUI()
        self:updateEconomy()
        self:updatePopulation()
    end
    
    if self.updateCounter % 300 == 0 then -- Every 5 seconds
        self:updateWeather()
    end
end

function UltimateCity:updateEconomy()
    self.economyLevel = math.max(50, math.min(150, self.economyLevel + math.random(-2, 3)))
end

function UltimateCity:updatePopulation()
    self.cityPopulation = math.max(0, self.cityPopulation + math.random(-5, 10))
end

function UltimateCity:updateWeather()
    local weathers = {"sunny", "cloudy", "rainy", "stormy"}
    self.weather = weathers[math.random(1, #weathers)]
end

function UltimateCity:startSimulation()
    print("🚀 Starting ULTIMATE CITY SIMULATION!")
    print("🏙️ Central City & Starling City")
    print("🌉 Advanced bridge system")
    print("🚗 Smart traffic AI")
    print("🌦️ Dynamic weather")
    print("💡 Realistic lighting")
    print("📊 Economy simulation")
    print("🎮 Multiplayer support")
    print("✅ No gaps - Safe ground coverage!")
    print("✅ Better spacing - Less crowded!")
    
    -- Main simulation loop
    local connection
    connection = RunService.Heartbeat:Connect(function()
        self:updateSimulation()
    end)
end

-- Initialize the ultimate city simulation
local ultimateCity = UltimateCity.new()

-- Clean up on close
game:BindToClose(function()
    print("🏙️ Ultimate City Simulation shutting down...")
end)