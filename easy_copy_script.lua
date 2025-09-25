--[[
    MEGA CITY SIMULATION - Way Better Than Flashpoint!
    Copy and paste this entire script into ServerScriptService
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Constants
local CITY_SIZE = 300
local BUILDING_COUNT = 50
local CAR_COUNT = 20
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
    CAR_COLORS = {
        Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(255, 165, 0), Color3.fromRGB(128, 0, 128)
    }
}

-- Main Simulation Class
local MegaCity = {}
MegaCity.__index = MegaCity

function MegaCity.new()
    local self = setmetatable({}, MegaCity)
    
    -- Core systems
    self.buildings = {}
    self.vehicles = {}
    self.parks = {}
    self.pedestrians = {}
    self.effects = {}
    
    -- Dynamic systems
    self.timeOfDay = 12.0
    self.weather = "sunny"
    self.trafficDensity = 0.7
    self.cityPopulation = 0
    self.economyLevel = 100
    
    -- Performance optimization
    self.updateCounter = 0
    self.lastUpdate = 0
    self.frameTime = 0
    
    -- Initialize everything
    self:setupEnvironment()
    self:createCities()
    self:setupLighting()
    self:createUI()
    self:startSimulation()
    
    return self
end

function MegaCity:setupEnvironment()
    -- Create water between cities
    local water = Instance.new("Part")
    water.Name = "Water"
    water.Size = Vector3.new(100, 20, CITY_SIZE * 2)
    water.Position = Vector3.new(0, -10, 0)
    water.Color = COLORS.WATER
    water.Material = Enum.Material.ForceField
    water.Anchored = true
    water.Parent = workspace
    
    -- Create bridge
    local bridge = Instance.new("Part")
    bridge.Name = "MegaBridge"
    bridge.Size = Vector3.new(100, 10, 30)
    bridge.Position = Vector3.new(0, 5, 0)
    bridge.Color = COLORS.BRIDGE
    bridge.Material = Enum.Material.Concrete
    bridge.Anchored = true
    bridge.Parent = workspace
    
    -- Bridge supports
    for i = -2, 2 do
        local support = Instance.new("Part")
        support.Name = "BridgeSupport"
        support.Size = Vector3.new(8, 30, 8)
        support.Position = Vector3.new(i * 25, -10, 0)
        support.Color = Color3.fromRGB(60, 60, 60)
        support.Material = Enum.Material.Concrete
        support.Anchored = true
        support.Parent = workspace
    end
end

function MegaCity:createCities()
    -- Central City (Left)
    self:createCity("Central", -CITY_SIZE/2, {
        tech = 0.4, business = 0.3, residential = 0.3
    })
    
    -- Starling City (Right)
    self:createCity("Starling", CITY_SIZE/2, {
        industrial = 0.4, harbor = 0.3, residential = 0.3
    })
    
    -- Create parks
    self:createParks()
    
    -- Spawn vehicles
    self:spawnVehicles()
end

function MegaCity:createCity(name, centerX, buildingTypes)
    local buildings = {}
    
    for i = 1, BUILDING_COUNT do
        local building = self:createBuilding({
            x = centerX + math.random(-CITY_SIZE/2, CITY_SIZE/2),
            z = math.random(-CITY_SIZE/2, CITY_SIZE/2),
            type = self:getRandomBuildingType(buildingTypes),
            height = math.random(30, 120)
        })
        table.insert(buildings, building)
    end
    
    self.buildings[name] = buildings
end

function MegaCity:createBuilding(data)
    local building = Instance.new("Part")
    building.Name = data.type .. "_Building"
    building.Size = Vector3.new(data.width or 20, data.height, data.width or 20)
    building.Position = Vector3.new(data.x, data.height/2, data.z)
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

function MegaCity:getBuildingColor(buildingType)
    local colors = {
        tech = COLORS.BUILDING_TECH,
        business = COLORS.BUILDING_BUSINESS,
        industrial = COLORS.BUILDING_INDUSTRIAL,
        residential = COLORS.BUILDING_RESIDENTIAL,
        harbor = Color3.fromRGB(90, 100, 110)
    }
    return colors[buildingType] or COLORS.BUILDING_BUSINESS
end

function MegaCity:getRandomBuildingType(types)
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

function MegaCity:addBuildingWindows(building, height)
    local windowCount = math.floor(height / 15)
    
    for i = 1, windowCount do
        local window = Instance.new("Part")
        window.Name = "Window"
        window.Size = Vector3.new(3, 3, 0.2)
        window.Position = building.Position + Vector3.new(
            math.random(-8, 8),
            -height/2 + i * 15,
            building.Size.Z/2 + 0.1
        )
        window.Color = math.random() < 0.6 and Color3.fromRGB(255, 255, 200) or Color3.fromRGB(20, 20, 20)
        window.Material = Enum.Material.Neon
        window.Anchored = true
        window.Parent = building
    end
end

function MegaCity:addRoofDetails(building, buildingType)
    if buildingType == "tech" then
        -- Add antenna
        local antenna = Instance.new("Part")
        antenna.Name = "Antenna"
        antenna.Size = Vector3.new(1, 20, 1)
        antenna.Position = building.Position + Vector3.new(0, building.Size.Y/2 + 10, 0)
        antenna.Color = Color3.fromRGB(200, 200, 200)
        antenna.Material = Enum.Material.Metal
        antenna.Anchored = true
        antenna.Parent = building
    end
end

function MegaCity:createParks()
    local parks = {
        {name = "Central Park", x = -100, z = 100, size = 80},
        {name = "Starling Park", x = 100, z = 100, size = 80},
        {name = "Bridge Park", x = 0, z = 0, size = 40}
    }
    
    for _, parkData in ipairs(parks) do
        self:createPark(parkData)
    end
end

function MegaCity:createPark(data)
    -- Grass area
    local grass = Instance.new("Part")
    grass.Name = data.name .. "_Grass"
    grass.Size = Vector3.new(data.size, 2, data.size)
    grass.Position = Vector3.new(data.x, 1, data.z)
    grass.Color = COLORS.GRASS
    grass.Material = Enum.Material.Grass
    grass.Anchored = true
    grass.Parent = workspace
    
    -- Add trees
    for i = 1, 8 do
        local tree = self:createTree(Vector3.new(
            data.x + math.random(-data.size/2 + 10, data.size/2 - 10),
            0,
            data.z + math.random(-data.size/2 + 10, data.size/2 - 10)
        ))
    end
    
    -- Add benches
    for i = 1, 3 do
        local bench = self:createBench(Vector3.new(
            data.x + math.random(-data.size/2 + 15, data.size/2 - 15),
            0,
            data.z + math.random(-data.size/2 + 15, data.size/2 - 15)
        ))
    end
end

function MegaCity:createTree(position)
    -- Trunk
    local trunk = Instance.new("Part")
    trunk.Name = "TreeTrunk"
    trunk.Size = Vector3.new(4, 20, 4)
    trunk.Position = position + Vector3.new(0, 10, 0)
    trunk.Color = Color3.fromRGB(101, 67, 33)
    trunk.Material = Enum.Material.Wood
    trunk.Anchored = true
    trunk.Parent = workspace
    
    -- Leaves
    local leaves = Instance.new("Part")
    leaves.Name = "TreeLeaves"
    leaves.Size = Vector3.new(15, 15, 15)
    leaves.Position = position + Vector3.new(0, 25, 0)
    leaves.Color = Color3.fromRGB(0, 100, 0)
    leaves.Material = Enum.Material.Grass
    leaves.Shape = Enum.PartType.Ball
    leaves.Anchored = true
    leaves.Parent = workspace
    
    return {trunk = trunk, leaves = leaves}
end

function MegaCity:createBench(position)
    local bench = Instance.new("Part")
    bench.Name = "Bench"
    bench.Size = Vector3.new(25, 4, 10)
    bench.Position = position + Vector3.new(0, 2, 0)
    bench.Color = Color3.fromRGB(101, 67, 33)
    bench.Material = Enum.Material.Wood
    bench.Anchored = true
    bench.Parent = workspace
    
    return bench
end

function MegaCity:spawnVehicles()
    for i = 1, CAR_COUNT do
        local vehicle = self:createVehicle()
        table.insert(self.vehicles, vehicle)
    end
end

function MegaCity:createVehicle()
    local car = Instance.new("Part")
    car.Name = "Vehicle"
    car.Size = Vector3.new(20, 10, 10)
    car.Color = COLORS.CAR_COLORS[math.random(1, #COLORS.CAR_COLORS)]
    car.Material = Enum.Material.Metal
    car.Anchored = true
    car.Parent = workspace
    
    -- Random starting position
    local startX = math.random(-CITY_SIZE, CITY_SIZE)
    local startZ = math.random(-CITY_SIZE, CITY_SIZE)
    car.Position = Vector3.new(startX, 5, startZ)
    
    -- Vehicle properties
    local vehicle = {
        part = car,
        speed = math.random(15, 35),
        direction = math.random() * 2 * math.pi,
        targetX = math.random(-CITY_SIZE, CITY_SIZE),
        targetZ = math.random(-CITY_SIZE, CITY_SIZE),
        lastUpdate = 0
    }
    
    return vehicle
end

function MegaCity:updateVehicles()
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
        
        if distance < 20 then
            vehicle.targetX = math.random(-CITY_SIZE, CITY_SIZE)
            vehicle.targetZ = math.random(-CITY_SIZE, CITY_SIZE)
        end
    end
end

function MegaCity:setupLighting()
    Lighting.Ambient = COLORS.SKY_DAY
    Lighting.Brightness = 2
    Lighting.TimeOfDay = "14:00:00"
end

function MegaCity:updateLighting()
    self.timeOfDay = self.timeOfDay + 0.005
    
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

function MegaCity:createUI()
    for _, player in ipairs(Players:GetPlayers()) do
        self:createPlayerGUI(player)
    end
    
    Players.PlayerAdded:Connect(function(player)
        self:createPlayerGUI(player)
    end)
end

function MegaCity:createPlayerGUI(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MegaCityGUI"
    screenGui.Parent = playerGui
    
    -- Main info panel
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "InfoFrame"
    infoFrame.Size = UDim2.new(0, 300, 0, 200)
    infoFrame.Position = UDim2.new(0, 10, 0, 10)
    infoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    infoFrame.BackgroundTransparency = 0.2
    infoFrame.Parent = screenGui
    
    -- Time display
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.Size = UDim2.new(1, 0, 0, 30)
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
    popLabel.Size = UDim2.new(1, 0, 0, 30)
    popLabel.Position = UDim2.new(0, 0, 0, 30)
    popLabel.BackgroundTransparency = 1
    popLabel.Text = "Population: 0"
    popLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    popLabel.TextScaled = true
    popLabel.Font = Enum.Font.SourceSans
    popLabel.Parent = infoFrame
    
    -- Economy display
    local econLabel = Instance.new("TextLabel")
    econLabel.Name = "EconLabel"
    econLabel.Size = UDim2.new(1, 0, 0, 30)
    econLabel.Position = UDim2.new(0, 0, 0, 60)
    econLabel.BackgroundTransparency = 1
    econLabel.Text = "Economy: 100%"
    econLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    econLabel.TextScaled = true
    econLabel.Font = Enum.Font.SourceSans
    econLabel.Parent = infoFrame
    
    -- Weather display
    local weatherLabel = Instance.new("TextLabel")
    weatherLabel.Name = "WeatherLabel"
    weatherLabel.Size = UDim2.new(1, 0, 0, 30)
    weatherLabel.Position = UDim2.new(0, 0, 0, 90)
    weatherLabel.BackgroundTransparency = 1
    weatherLabel.Text = "Weather: Sunny"
    weatherLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    weatherLabel.TextScaled = true
    weatherLabel.Font = Enum.Font.SourceSans
    weatherLabel.Parent = infoFrame
    
    -- City labels
    local centralLabel = Instance.new("TextLabel")
    centralLabel.Name = "CentralLabel"
    centralLabel.Size = UDim2.new(0, 150, 0, 40)
    centralLabel.Position = UDim2.new(0, 10, 0, 220)
    centralLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    centralLabel.BackgroundTransparency = 0.3
    centralLabel.Text = "CENTRAL CITY"
    centralLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    centralLabel.TextScaled = true
    centralLabel.Font = Enum.Font.SourceSansBold
    centralLabel.Parent = screenGui
    
    local starlingLabel = Instance.new("TextLabel")
    starlingLabel.Name = "StarlingLabel"
    starlingLabel.Size = UDim2.new(0, 150, 0, 40)
    starlingLabel.Position = UDim2.new(1, -160, 0, 220)
    starlingLabel.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    starlingLabel.BackgroundTransparency = 0.3
    starlingLabel.Text = "STARLING CITY"
    starlingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    starlingLabel.TextScaled = true
    starlingLabel.Font = Enum.Font.SourceSansBold
    starlingLabel.Parent = screenGui
    
    -- Store GUI references
    self.playerGUIs = self.playerGUIs or {}
    self.playerGUIs[player] = {
        timeLabel = timeLabel,
        popLabel = popLabel,
        econLabel = econLabel,
        weatherLabel = weatherLabel
    }
end

function MegaCity:updateUI()
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
    end
end

function MegaCity:updateSimulation()
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

function MegaCity:updateEconomy()
    self.economyLevel = math.max(50, math.min(150, self.economyLevel + math.random(-2, 3)))
end

function MegaCity:updatePopulation()
    self.cityPopulation = math.max(0, self.cityPopulation + math.random(-5, 10))
end

function MegaCity:updateWeather()
    local weathers = {"sunny", "cloudy", "rainy", "stormy"}
    self.weather = weathers[math.random(1, #weathers)]
end

function MegaCity:startSimulation()
    print("🚀 Starting MEGA CITY SIMULATION!")
    print("🏙️ Central City & Starling City")
    print("🌉 Advanced bridge system")
    print("🚗 Smart traffic AI")
    print("🌦️ Dynamic weather")
    print("💡 Realistic lighting")
    print("📊 Economy simulation")
    print("🎮 Multiplayer support")
    
    -- Main simulation loop
    local connection
    connection = RunService.Heartbeat:Connect(function()
        self:updateSimulation()
    end)
end

-- Initialize the mega city simulation
local megaCity = MegaCity.new()

-- Clean up on close
game:BindToClose(function()
    print("🏙️ Mega City Simulation shutting down...")
end)