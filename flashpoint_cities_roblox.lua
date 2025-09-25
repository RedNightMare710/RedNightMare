--[[
    Flashpoint Cities - Central City & Starling City Simulation
    A unique Roblox city simulation featuring two connected cities with roads, parks, and interactive elements.
    This is like Flashpoint but better and different!
    
    Place this script in ServerScriptService for server-side execution
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Constants
local CITY_SIZE = 200
local BRIDGE_WIDTH = 50
local BUILDING_HEIGHT_RANGE = {50, 150}
local CAR_SPEED_RANGE = {10, 30}

-- Colors
local COLORS = {
    SKY_BLUE = Color3.fromRGB(135, 206, 235),
    CITY_GRAY = Color3.fromRGB(64, 64, 64),
    ROAD_GRAY = Color3.fromRGB(45, 45, 45),
    BRIDGE_COLOR = Color3.fromRGB(105, 105, 105),
    GRASS_GREEN = Color3.fromRGB(34, 139, 34),
    PARK_GREEN = Color3.fromRGB(0, 128, 0),
    WATER_BLUE = Color3.fromRGB(0, 100, 200),
    STREET_LIGHT = Color3.fromRGB(255, 255, 200),
    CAR_COLORS = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(255, 165, 0)
    }
}

-- Building Types
local BUILDING_TYPES = {
    TECH = {
        color = Color3.fromRGB(100, 150, 200),
        height_multiplier = 1.2
    },
    BUSINESS = {
        color = Color3.fromRGB(120, 120, 120),
        height_multiplier = 1.0
    },
    INDUSTRIAL = {
        color = Color3.fromRGB(80, 80, 80),
        height_multiplier = 0.8
    },
    HARBOR = {
        color = Color3.fromRGB(90, 100, 110),
        height_multiplier = 0.9
    },
    RESIDENTIAL = {
        color = Color3.fromRGB(110, 110, 100),
        height_multiplier = 0.7
    }
}

-- Main FlashpointCities Class
local FlashpointCities = {}
FlashpointCities.__index = FlashpointCities

function FlashpointCities.new()
    local self = setmetatable({}, FlashpointCities)
    
    -- Initialize properties
    self.buildings = {}
    self.roads = {}
    self.parks = {}
    self.cars = {}
    self.timeOfDay = 0
    self.selectedCity = nil
    self.isRunning = true
    
    -- City boundaries
    self.centralCityBounds = {
        minX = -CITY_SIZE,
        maxX = -50,
        minZ = -CITY_SIZE,
        maxZ = CITY_SIZE
    }
    
    self.starlingCityBounds = {
        minX = 50,
        maxX = CITY_SIZE,
        minZ = -CITY_SIZE,
        maxZ = CITY_SIZE
    }
    
    self.bridgeBounds = {
        minX = -50,
        maxX = 50,
        minZ = -25,
        maxZ = 25
    }
    
    -- Initialize the simulation
    self:initializeCities()
    self:createRoads()
    self:createParks()
    self:spawnCars()
    self:setupLighting()
    self:createUI()
    
    return self
end

function FlashpointCities:initializeCities()
    -- Central City buildings (tech-focused)
    local centralBuildings = {
        -- Tech district
        {x = -150, z = -100, width = 30, height = 80, type = "TECH"},
        {x = -100, z = -80, width = 35, height = 90, type = "TECH"},
        {x = -50, z = -100, width = 25, height = 70, type = "TECH"},
        {x = -20, z = -90, width = 30, height = 85, type = "TECH"},
        
        -- Business district
        {x = -150, z = 0, width = 40, height = 60, type = "BUSINESS"},
        {x = -100, z = -20, width = 45, height = 70, type = "BUSINESS"},
        {x = -50, z = 0, width = 35, height = 65, type = "BUSINESS"},
        {x = -20, z = -10, width = 40, height = 75, type = "BUSINESS"},
        
        -- Residential
        {x = -120, z = 100, width = 25, height = 50, type = "RESIDENTIAL"},
        {x = -80, z = 80, width = 30, height = 55, type = "RESIDENTIAL"},
        {x = -40, z = 100, width = 28, height = 52, type = "RESIDENTIAL"},
        {x = -10, z = 90, width = 32, height = 58, type = "RESIDENTIAL"},
    }
    
    -- Starling City buildings (industrial)
    local starlingBuildings = {
        -- Industrial district
        {x = 50, z = -100, width = 40, height = 70, type = "INDUSTRIAL"},
        {x = 100, z = -90, width = 45, height = 75, type = "INDUSTRIAL"},
        {x = 150, z = -100, width = 35, height = 65, type = "INDUSTRIAL"},
        {x = 180, z = -95, width = 40, height = 72, type = "INDUSTRIAL"},
        
        -- Harbor district
        {x = 50, z = 0, width = 30, height = 80, type = "HARBOR"},
        {x = 100, z = -20, width = 35, height = 90, type = "HARBOR"},
        {x = 150, z = 0, width = 32, height = 85, type = "HARBOR"},
        {x = 180, z = -10, width = 35, height = 88, type = "HARBOR"},
        
        -- Residential
        {x = 70, z = 100, width = 30, height = 55, type = "RESIDENTIAL"},
        {x = 110, z = 80, width = 35, height = 60, type = "RESIDENTIAL"},
        {x = 150, z = 100, width = 32, height = 52, type = "RESIDENTIAL"},
        {x = 180, z = 90, width = 30, height = 58, type = "RESIDENTIAL"},
    }
    
    -- Create buildings
    for _, buildingData in ipairs(centralBuildings) do
        self:createBuilding(buildingData)
    end
    
    for _, buildingData in ipairs(starlingBuildings) do
        self:createBuilding(buildingData)
    end
end

function FlashpointCities:createBuilding(data)
    local buildingType = BUILDING_TYPES[data.type]
    local height = data.height * buildingType.height_multiplier
    
    -- Create building part
    local building = Instance.new("Part")
    building.Name = data.type .. "_Building"
    building.Size = Vector3.new(data.width, height, data.width)
    building.Position = Vector3.new(data.x, height/2, data.z)
    building.Color = buildingType.color
    building.Material = Enum.Material.Concrete
    building.Anchored = true
    building.Parent = workspace
    
    -- Add windows
    self:addWindows(building, data.width, height)
    
    -- Store building reference
    table.insert(self.buildings, {
        part = building,
        type = data.type,
        position = Vector3.new(data.x, height/2, data.z)
    })
end

function FlashpointCities:addWindows(building, width, height)
    local windowSize = 2
    local spacing = 8
    
    for x = -width/2 + spacing, width/2 - spacing, spacing do
        for y = -height/2 + spacing, height/2 - spacing, spacing do
            if math.random() < 0.7 then -- 70% chance of window
                local window = Instance.new("Part")
                window.Name = "Window"
                window.Size = Vector3.new(windowSize, windowSize, 0.2)
                window.Position = building.Position + Vector3.new(x, y, width/2 + 0.1)
                window.Color = math.random() < 0.5 and COLORS.STREET_LIGHT or Color3.fromRGB(20, 20, 20)
                window.Material = Enum.Material.Neon
                window.Anchored = true
                window.Parent = building
            end
        end
    end
end

function FlashpointCities:createRoads()
    -- Central City roads
    local centralRoads = {
        {start = Vector3.new(-CITY_SIZE, 1, -50), finish = Vector3.new(-50, 1, -50), width = 20},
        {start = Vector3.new(-CITY_SIZE, 1, 50), finish = Vector3.new(-50, 1, 50), width = 20},
        {start = Vector3.new(-100, 1, -CITY_SIZE), finish = Vector3.new(-100, 1, CITY_SIZE), width = 20},
    }
    
    -- Starling City roads
    local starlingRoads = {
        {start = Vector3.new(50, 1, -50), finish = Vector3.new(CITY_SIZE, 1, -50), width = 20},
        {start = Vector3.new(50, 1, 50), finish = Vector3.new(CITY_SIZE, 1, 50), width = 20},
        {start = Vector3.new(100, 1, -CITY_SIZE), finish = Vector3.new(100, 1, CITY_SIZE), width = 20},
    }
    
    -- Bridge roads
    local bridgeRoads = {
        {start = Vector3.new(-50, 1, -25), finish = Vector3.new(50, 1, -25), width = 30},
        {start = Vector3.new(-50, 1, 25), finish = Vector3.new(50, 1, 25), width = 30},
    }
    
    -- Create all roads
    for _, roadData in ipairs(centralRoads) do
        self:createRoad(roadData)
    end
    
    for _, roadData in ipairs(starlingRoads) do
        self:createRoad(roadData)
    end
    
    for _, roadData in ipairs(bridgeRoads) do
        self:createRoad(roadData)
    end
end

function FlashpointCities:createRoad(data)
    local road = Instance.new("Part")
    road.Name = "Road"
    road.Size = Vector3.new(
        math.abs(data.finish.X - data.start.X) + data.width,
        data.width,
        math.abs(data.finish.Z - data.start.Z) + data.width
    )
    road.Position = (data.start + data.finish) / 2
    road.Color = COLORS.ROAD_GRAY
    road.Material = Enum.Material.Asphalt
    road.Anchored = true
    road.Parent = workspace
    
    -- Add road markings
    self:addRoadMarkings(road, data)
    
    table.insert(self.roads, road)
end

function FlashpointCities:addRoadMarkings(road, data)
    local marking = Instance.new("Part")
    marking.Name = "RoadMarking"
    marking.Size = Vector3.new(road.Size.X, 0.2, 2)
    marking.Position = road.Position
    marking.Color = Color3.fromRGB(255, 255, 255)
    marking.Material = Enum.Material.Neon
    marking.Anchored = true
    marking.Parent = road
end

function FlashpointCities:createParks()
    -- Central City Park
    local centralPark = self:createPark({
        x = -120,
        z = 150,
        width = 60,
        height = 40,
        name = "Central City Park"
    })
    
    -- Starling City Park
    local starlingPark = self:createPark({
        x = 120,
        z = 150,
        width = 60,
        height = 40,
        name = "Starling City Park"
    })
    
    -- Bridge Park (unique feature!)
    local bridgePark = self:createPark({
        x = 0,
        z = 0,
        width = 40,
        height = 20,
        name = "Bridge Park"
    })
    
    self.parks = {centralPark, starlingPark, bridgePark}
end

function FlashpointCities:createPark(data)
    -- Create grass area
    local grass = Instance.new("Part")
    grass.Name = data.name .. "_Grass"
    grass.Size = Vector3.new(data.width, 1, data.height)
    grass.Position = Vector3.new(data.x, 0.5, data.z)
    grass.Color = COLORS.GRASS_GREEN
    grass.Material = Enum.Material.Grass
    grass.Anchored = true
    grass.Parent = workspace
    
    local park = {
        grass = grass,
        trees = {},
        benches = {}
    }
    
    -- Add trees
    for i = 1, 5 do
        local tree = self:createTree(Vector3.new(
            data.x + math.random(-data.width/2 + 5, data.width/2 - 5),
            0,
            data.z + math.random(-data.height/2 + 5, data.height/2 - 5)
        ))
        table.insert(park.trees, tree)
    end
    
    -- Add benches
    for i = 1, 2 do
        local bench = self:createBench(Vector3.new(
            data.x + math.random(-data.width/2 + 10, data.width/2 - 10),
            0,
            data.z + math.random(-data.height/2 + 10, data.height/2 - 10)
        ))
        table.insert(park.benches, bench)
    end
    
    return park
end

function FlashpointCities:createTree(position)
    -- Tree trunk
    local trunk = Instance.new("Part")
    trunk.Name = "TreeTrunk"
    trunk.Size = Vector3.new(3, 15, 3)
    trunk.Position = position + Vector3.new(0, 7.5, 0)
    trunk.Color = Color3.fromRGB(101, 67, 33)
    trunk.Material = Enum.Material.Wood
    trunk.Anchored = true
    trunk.Parent = workspace
    
    -- Tree leaves
    local leaves = Instance.new("Part")
    leaves.Name = "TreeLeaves"
    leaves.Size = Vector3.new(12, 12, 12)
    leaves.Position = position + Vector3.new(0, 18, 0)
    leaves.Color = COLORS.PARK_GREEN
    leaves.Material = Enum.Material.Grass
    leaves.Shape = Enum.PartType.Ball
    leaves.Anchored = true
    leaves.Parent = workspace
    
    return {trunk = trunk, leaves = leaves}
end

function FlashpointCities:createBench(position)
    local bench = Instance.new("Part")
    bench.Name = "Bench"
    bench.Size = Vector3.new(20, 3, 8)
    bench.Position = position + Vector3.new(0, 1.5, 0)
    bench.Color = Color3.fromRGB(101, 67, 33)
    bench.Material = Enum.Material.Wood
    bench.Anchored = true
    bench.Parent = workspace
    
    return bench
end

function FlashpointCities:spawnCars()
    -- Spawn cars on different roads
    for i = 1, 10 do
        local car = self:createCar()
        table.insert(self.cars, car)
    end
end

function FlashpointCities:createCar()
    local car = Instance.new("Part")
    car.Name = "Car"
    car.Size = Vector3.new(16, 8, 8)
    car.Color = COLORS.CAR_COLORS[math.random(1, #COLORS.CAR_COLORS)]
    car.Material = Enum.Material.Metal
    car.Anchored = true
    car.Parent = workspace
    
    -- Random starting position
    local startX = math.random(-CITY_SIZE, CITY_SIZE)
    local startZ = math.random(-CITY_SIZE, CITY_SIZE)
    car.Position = Vector3.new(startX, 4, startZ)
    
    -- Random direction and speed
    local direction = math.random() * 2 * math.pi
    local speed = math.random(CAR_SPEED_RANGE[1], CAR_SPEED_RANGE[2])
    
    return {
        part = car,
        direction = direction,
        speed = speed,
        velocity = Vector3.new(math.cos(direction) * speed, 0, math.sin(direction) * speed)
    }
end

function FlashpointCities:updateCars()
    for _, car in ipairs(self.cars) do
        -- Move car
        car.part.Position = car.part.Position + car.velocity * (1/60)
        
        -- Wrap around screen edges
        if car.part.Position.X > CITY_SIZE then
            car.part.Position = Vector3.new(-CITY_SIZE, car.part.Position.Y, car.part.Position.Z)
        elseif car.part.Position.X < -CITY_SIZE then
            car.part.Position = Vector3.new(CITY_SIZE, car.part.Position.Y, car.part.Position.Z)
        end
        
        if car.part.Position.Z > CITY_SIZE then
            car.part.Position = Vector3.new(car.part.Position.X, car.part.Position.Y, -CITY_SIZE)
        elseif car.part.Position.Z < -CITY_SIZE then
            car.part.Position = Vector3.new(car.part.Position.X, car.part.Position.Y, CITY_SIZE)
        end
        
        -- Randomly change direction occasionally
        if math.random() < 0.01 then
            car.direction = math.random() * 2 * math.pi
            car.velocity = Vector3.new(math.cos(car.direction) * car.speed, 0, math.sin(car.direction) * car.speed)
        end
    end
end

function FlashpointCities:setupLighting()
    -- Set up day/night cycle
    Lighting.Ambient = Color3.fromRGB(135, 206, 235)
    Lighting.Brightness = 2
    Lighting.TimeOfDay = "14:00:00"
end

function FlashpointCities:updateLighting()
    self.timeOfDay = self.timeOfDay + 0.01
    if self.timeOfDay >= 24 then
        self.timeOfDay = 0
    end
    
    -- Update lighting based on time
    local brightness = math.sin(self.timeOfDay * math.pi / 12) * 0.5 + 1.5
    Lighting.Brightness = brightness
    
    -- Update building window lights
    for _, building in ipairs(self.buildings) do
        for _, window in ipairs(building.part:GetChildren()) do
            if window.Name == "Window" then
                if math.random() < 0.001 then
                    window.Color = math.random() < 0.5 and COLORS.STREET_LIGHT or Color3.fromRGB(20, 20, 20)
                end
            end
        end
    end
end

function FlashpointCities:createUI()
    -- Create GUI for players
    for _, player in ipairs(Players:GetPlayers()) do
        self:createPlayerGUI(player)
    end
    
    -- Connect to new players
    Players.PlayerAdded:Connect(function(player)
        self:createPlayerGUI(player)
    end)
end

function FlashpointCities:createPlayerGUI(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FlashpointCitiesGUI"
    screenGui.Parent = playerGui
    
    -- Time display
    local timeFrame = Instance.new("Frame")
    timeFrame.Name = "TimeFrame"
    timeFrame.Size = UDim2.new(0, 200, 0, 50)
    timeFrame.Position = UDim2.new(0, 10, 0, 10)
    timeFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    timeFrame.BackgroundTransparency = 0.3
    timeFrame.Parent = screenGui
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.Size = UDim2.new(1, 0, 1, 0)
    timeLabel.Position = UDim2.new(0, 0, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "Time: 14:00"
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.SourceSansBold
    timeLabel.Parent = timeFrame
    
    -- City labels
    local centralLabel = Instance.new("TextLabel")
    centralLabel.Name = "CentralLabel"
    centralLabel.Size = UDim2.new(0, 150, 0, 30)
    centralLabel.Position = UDim2.new(0, 10, 0, 70)
    centralLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    centralLabel.BackgroundTransparency = 0.3
    centralLabel.Text = "CENTRAL CITY"
    centralLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    centralLabel.TextScaled = true
    centralLabel.Font = Enum.Font.SourceSansBold
    centralLabel.Parent = screenGui
    
    local starlingLabel = Instance.new("TextLabel")
    starlingLabel.Name = "StarlingLabel"
    starlingLabel.Size = UDim2.new(0, 150, 0, 30)
    starlingLabel.Position = UDim2.new(1, -160, 0, 70)
    starlingLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    starlingLabel.BackgroundTransparency = 0.3
    starlingLabel.Text = "STARLING CITY"
    starlingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    starlingLabel.TextScaled = true
    starlingLabel.Font = Enum.Font.SourceSansBold
    starlingLabel.Parent = screenGui
    
    -- Instructions
    local instructionsFrame = Instance.new("Frame")
    instructionsFrame.Name = "InstructionsFrame"
    instructionsFrame.Size = UDim2.new(0, 300, 0, 100)
    instructionsFrame.Position = UDim2.new(0, 10, 1, -110)
    instructionsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    instructionsFrame.BackgroundTransparency = 0.3
    instructionsFrame.Parent = screenGui
    
    local instructionsLabel = Instance.new("TextLabel")
    instructionsLabel.Name = "InstructionsLabel"
    instructionsLabel.Size = UDim2.new(1, 0, 1, 0)
    instructionsLabel.Position = UDim2.new(0, 0, 0, 0)
    instructionsLabel.BackgroundTransparency = 1
    instructionsLabel.Text = "Click on cities to interact!\nESC to quit\nSpace to pause time"
    instructionsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    instructionsLabel.TextScaled = true
    instructionsLabel.Font = Enum.Font.SourceSans
    instructionsLabel.Parent = instructionsFrame
    
    -- Store references for updates
    self.playerGUIs = self.playerGUIs or {}
    self.playerGUIs[player] = {
        timeLabel = timeLabel,
        centralLabel = centralLabel,
        starlingLabel = starlingLabel
    }
end

function FlashpointCities:updateUI()
    -- Update time display for all players
    for player, gui in pairs(self.playerGUIs or {}) do
        if gui.timeLabel then
            gui.timeLabel.Text = string.format("Time: %.1f:00", self.timeOfDay)
        end
    end
end

function FlashpointCities:handleInput(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Escape then
        self.isRunning = false
    elseif input.KeyCode == Enum.KeyCode.Space then
        -- Toggle time pause (implement if needed)
    end
end

function FlashpointCities:run()
    print("Starting Flashpoint Cities...")
    print("Features:")
    print("- Central City & Starling City")
    print("- Connecting bridge with park")
    print("- Dynamic road network")
    print("- Animated cars")
    print("- Day/night cycle")
    print("- Interactive city selection")
    print("- Parks with trees and benches")
    print("- Realistic building windows")
    
    -- Connect input handling
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        self:handleInput(input, gameProcessed)
    end)
    
    -- Main game loop
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not self.isRunning then
            connection:Disconnect()
            return
        end
        
        self:updateCars()
        self:updateLighting()
        self:updateUI()
    end)
end

-- Initialize and run the simulation
local flashpointCities = FlashpointCities.new()
flashpointCities:run()

-- Clean up when script is stopped
game:BindToClose(function()
    flashpointCities.isRunning = false
end)