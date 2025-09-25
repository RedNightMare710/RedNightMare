#!/usr/bin/env python3
"""
Flashpoint Cities - Central City & Starling City Simulation
A unique city simulation featuring two interconnected cities with dynamic environments,
realistic physics, and Flashpoint-inspired elements.
"""

import pygame
import random
import math
import time
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass
from enum import Enum

# Initialize Pygame
pygame.init()

# Constants
SCREEN_WIDTH = 1600
SCREEN_HEIGHT = 900
FPS = 60
BRIDGE_WIDTH = 200
CITY_HEIGHT = 400

# Colors
SKY_BLUE = (135, 206, 235)
BRIDGE_GRAY = (105, 105, 105)
ROAD_ASPHALT = (64, 64, 64)
GRASS_GREEN = (34, 139, 34)
PARK_GREEN = (0, 128, 0)
BUILDING_COLORS = [(70, 70, 70), (80, 80, 80), (90, 90, 90), (100, 100, 100)]
WATER_BLUE = (0, 100, 200)
STREET_LIGHT = (255, 255, 0)
TRAFFIC_LIGHT_RED = (255, 0, 0)
TRAFFIC_LIGHT_GREEN = (0, 255, 0)
TRAFFIC_LIGHT_YELLOW = (255, 255, 0)

class WeatherType(Enum):
    SUNNY = "sunny"
    RAINY = "rainy"
    STORMY = "stormy"
    FOGGY = "foggy"

@dataclass
class Building:
    x: int
    y: int
    width: int
    height: int
    color: Tuple[int, int, int]
    windows: List[Tuple[int, int, int, int]]
    lit_windows: List[bool]

@dataclass
class Vehicle:
    x: float
    y: float
    speed: float
    direction: float
    color: Tuple[int, int, int]
    size: Tuple[int, int]
    city: str  # "central" or "starling"

@dataclass
class Park:
    x: int
    y: int
    width: int
    height: int
    trees: List[Tuple[int, int]]
    benches: List[Tuple[int, int]]
    fountain: Optional[Tuple[int, int]]

class FlashpointCities:
    def __init__(self):
        self.screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
        pygame.display.set_caption("Flashpoint Cities - Central City & Starling City")
        self.clock = pygame.time.Clock()
        self.running = True
        
        # City data
        self.central_city_buildings: List[Building] = []
        self.starling_city_buildings: List[Building] = []
        self.vehicles: List[Vehicle] = []
        self.parks: List[Park] = []
        self.bridge_segments: List[Tuple[int, int, int, int]] = []
        
        # Dynamic elements
        self.weather = WeatherType.SUNNY
        self.time_of_day = 0.0  # 0.0 = midnight, 0.5 = noon, 1.0 = midnight
        self.traffic_lights = {"central": True, "starling": True}  # True = green, False = red
        self.light_timer = 0
        
        # Flashpoint effects
        self.speed_force_active = False
        self.speed_force_timer = 0
        self.lightning_strikes: List[Tuple[int, int, int]] = []  # x, y, intensity
        
        self.initialize_cities()
        self.generate_bridge()
        self.create_parks()
        
    def initialize_cities(self):
        """Generate buildings for both cities"""
        # Central City (left side)
        for i in range(25):
            x = random.randint(50, 400)
            y = random.randint(SCREEN_HEIGHT - CITY_HEIGHT, SCREEN_HEIGHT - 50)
            width = random.randint(30, 80)
            height = random.randint(60, 200)
            color = random.choice(BUILDING_COLORS)
            
            # Generate windows
            windows = []
            lit_windows = []
            for wx in range(x + 5, x + width - 5, 15):
                for wy in range(y + 5, y + height - 5, 20):
                    windows.append((wx, wy, 8, 12))
                    lit_windows.append(random.choice([True, False]))
            
            building = Building(x, y, width, height, color, windows, lit_windows)
            self.central_city_buildings.append(building)
        
        # Starling City (right side)
        for i in range(25):
            x = random.randint(SCREEN_WIDTH - 400, SCREEN_WIDTH - 50)
            y = random.randint(SCREEN_HEIGHT - CITY_HEIGHT, SCREEN_HEIGHT - 50)
            width = random.randint(30, 80)
            height = random.randint(60, 200)
            color = random.choice(BUILDING_COLORS)
            
            # Generate windows
            windows = []
            lit_windows = []
            for wx in range(x + 5, x + width - 5, 15):
                for wy in range(y + 5, y + height - 5, 20):
                    windows.append((wx, wy, 8, 12))
                    lit_windows.append(random.choice([True, False]))
            
            building = Building(x, y, width, height, color, windows, lit_windows)
            self.starling_city_buildings.append(building)
    
    def generate_bridge(self):
        """Create the bridge connecting the two cities"""
        bridge_start_x = 400
        bridge_end_x = SCREEN_WIDTH - 400
        bridge_y = SCREEN_HEIGHT - 150
        
        # Main bridge deck
        self.bridge_segments = [
            (bridge_start_x, bridge_y, bridge_end_x - bridge_start_x, 20),
            (bridge_start_x, bridge_y - 20, bridge_end_x - bridge_start_x, 20),
            (bridge_start_x, bridge_y - 40, bridge_end_x - bridge_start_x, 20)
        ]
        
        # Bridge supports
        support_spacing = 100
        for x in range(bridge_start_x, bridge_end_x, support_spacing):
            self.bridge_segments.append((x, bridge_y + 20, 10, 100))
    
    def create_parks(self):
        """Create parks and green spaces"""
        # Central City Park
        central_park = Park(
            x=100, y=SCREEN_HEIGHT - 300,
            width=200, height=150,
            trees=[], benches=[], fountain=(200, SCREEN_HEIGHT - 225)
        )
        
        # Add trees to central park
        for _ in range(8):
            tree_x = random.randint(central_park.x + 20, central_park.x + central_park.width - 20)
            tree_y = random.randint(central_park.y + 20, central_park.y + central_park.height - 20)
            central_park.trees.append((tree_x, tree_y))
        
        # Add benches
        for _ in range(3):
            bench_x = random.randint(central_park.x + 30, central_park.x + central_park.width - 30)
            bench_y = random.randint(central_park.y + 30, central_park.y + central_park.height - 30)
            central_park.benches.append((bench_x, bench_y))
        
        # Starling City Park
        starling_park = Park(
            x=SCREEN_WIDTH - 300, y=SCREEN_HEIGHT - 300,
            width=200, height=150,
            trees=[], benches=[], fountain=(SCREEN_WIDTH - 200, SCREEN_HEIGHT - 225)
        )
        
        # Add trees to starling park
        for _ in range(8):
            tree_x = random.randint(starling_park.x + 20, starling_park.x + starling_park.width - 20)
            tree_y = random.randint(starling_park.y + 20, starling_park.y + starling_park.height - 20)
            starling_park.trees.append((tree_x, tree_y))
        
        # Add benches
        for _ in range(3):
            bench_x = random.randint(starling_park.x + 30, starling_park.x + starling_park.width - 30)
            bench_y = random.randint(starling_park.y + 30, starling_park.y + starling_park.height - 30)
            starling_park.benches.append((bench_x, bench_y))
        
        self.parks.extend([central_park, starling_park])
    
    def spawn_vehicles(self):
        """Spawn vehicles on roads and bridge"""
        if random.random() < 0.02:  # 2% chance per frame
            # Spawn from Central City
            if random.choice([True, False]):
                vehicle = Vehicle(
                    x=50, y=SCREEN_HEIGHT - 100,
                    speed=random.uniform(1, 3),
                    direction=0,  # Moving right
                    color=random.choice([(255, 0, 0), (0, 0, 255), (255, 255, 0), (0, 255, 0)]),
                    size=(20, 10),
                    city="central"
                )
                self.vehicles.append(vehicle)
        
        if random.random() < 0.02:  # 2% chance per frame
            # Spawn from Starling City
            if random.choice([True, False]):
                vehicle = Vehicle(
                    x=SCREEN_WIDTH - 50, y=SCREEN_HEIGHT - 100,
                    speed=random.uniform(1, 3),
                    direction=180,  # Moving left
                    color=random.choice([(255, 0, 0), (0, 0, 255), (255, 255, 0), (0, 255, 0)]),
                    size=(20, 10),
                    city="starling"
                )
                self.vehicles.append(vehicle)
    
    def update_vehicles(self):
        """Update vehicle positions and remove off-screen vehicles"""
        for vehicle in self.vehicles[:]:
            # Update position based on direction
            if vehicle.direction == 0:  # Moving right
                vehicle.x += vehicle.speed
            else:  # Moving left
                vehicle.x -= vehicle.speed
            
            # Remove vehicles that are off-screen
            if vehicle.x < -50 or vehicle.x > SCREEN_WIDTH + 50:
                self.vehicles.remove(vehicle)
    
    def update_traffic_lights(self):
        """Update traffic light timing"""
        self.light_timer += 1
        if self.light_timer > 180:  # 3 seconds at 60 FPS
            self.traffic_lights["central"] = not self.traffic_lights["central"]
            self.traffic_lights["starling"] = not self.traffic_lights["starling"]
            self.light_timer = 0
    
    def update_weather(self):
        """Update weather effects"""
        if random.random() < 0.001:  # 0.1% chance to change weather
            self.weather = random.choice(list(WeatherType))
    
    def update_time(self):
        """Update time of day"""
        self.time_of_day += 0.0001  # Slow time progression
        if self.time_of_day > 1.0:
            self.time_of_day = 0.0
    
    def update_lightning(self):
        """Update lightning effects"""
        if self.weather == WeatherType.STORMY:
            if random.random() < 0.1:  # 10% chance per frame
                x = random.randint(0, SCREEN_WIDTH)
                y = random.randint(0, SCREEN_HEIGHT // 2)
                intensity = random.randint(50, 255)
                self.lightning_strikes.append((x, y, intensity))
        
        # Remove old lightning strikes
        self.lightning_strikes = [(x, y, i-10) for x, y, i in self.lightning_strikes if i > 10]
    
    def activate_speed_force(self):
        """Activate Flashpoint speed force effect"""
        self.speed_force_active = True
        self.speed_force_timer = 300  # 5 seconds at 60 FPS
    
    def update_speed_force(self):
        """Update speed force effects"""
        if self.speed_force_active:
            self.speed_force_timer -= 1
            if self.speed_force_timer <= 0:
                self.speed_force_active = False
    
    def draw_background(self):
        """Draw sky and water background"""
        # Sky gradient based on time of day
        if self.time_of_day < 0.25 or self.time_of_day > 0.75:  # Night
            sky_color = (20, 20, 40)
        elif self.time_of_day < 0.5:  # Dawn to noon
            sky_color = (135, 206, 235)
        else:  # Afternoon to dusk
            sky_color = (255, 140, 0)
        
        self.screen.fill(sky_color)
        
        # Water
        water_rect = pygame.Rect(0, SCREEN_HEIGHT - 50, SCREEN_WIDTH, 50)
        pygame.draw.rect(self.screen, WATER_BLUE, water_rect)
    
    def draw_bridge(self):
        """Draw the bridge connecting the cities"""
        for segment in self.bridge_segments:
            pygame.draw.rect(self.screen, BRIDGE_GRAY, segment)
        
        # Bridge road markings
        bridge_y = SCREEN_HEIGHT - 150
        pygame.draw.line(self.screen, (255, 255, 255), (400, bridge_y - 10), (SCREEN_WIDTH - 400, bridge_y - 10), 2)
        pygame.draw.line(self.screen, (255, 255, 255), (400, bridge_y + 10), (SCREEN_WIDTH - 400, bridge_y + 10), 2)
    
    def draw_roads(self):
        """Draw road networks"""
        # Main roads
        pygame.draw.rect(self.screen, ROAD_ASPHALT, (0, SCREEN_HEIGHT - 100, SCREEN_WIDTH, 50))
        
        # Road markings
        for x in range(0, SCREEN_WIDTH, 50):
            pygame.draw.line(self.screen, (255, 255, 255), (x, SCREEN_HEIGHT - 75), (x + 25, SCREEN_HEIGHT - 75), 2)
        
        # Side streets
        pygame.draw.rect(self.screen, ROAD_ASPHALT, (200, SCREEN_HEIGHT - 200, 100, 20))
        pygame.draw.rect(self.screen, ROAD_ASPHALT, (SCREEN_WIDTH - 300, SCREEN_HEIGHT - 200, 100, 20))
    
    def draw_buildings(self):
        """Draw all buildings with windows"""
        all_buildings = self.central_city_buildings + self.starling_city_buildings
        
        for building in all_buildings:
            # Draw building
            pygame.draw.rect(self.screen, building.color, (building.x, building.y, building.width, building.height))
            
            # Draw windows
            for i, window in enumerate(building.windows):
                if building.lit_windows[i]:
                    pygame.draw.rect(self.screen, (255, 255, 150), window)
                else:
                    pygame.draw.rect(self.screen, (50, 50, 50), window)
    
    def draw_parks(self):
        """Draw parks and green spaces"""
        for park in self.parks:
            # Draw grass
            pygame.draw.rect(self.screen, PARK_GREEN, (park.x, park.y, park.width, park.height))
            
            # Draw trees
            for tree_x, tree_y in park.trees:
                # Tree trunk
                pygame.draw.rect(self.screen, (139, 69, 19), (tree_x - 3, tree_y, 6, 15))
                # Tree leaves
                pygame.draw.circle(self.screen, (0, 100, 0), (tree_x, tree_y - 5), 12)
            
            # Draw benches
            for bench_x, bench_y in park.benches:
                pygame.draw.rect(self.screen, (139, 69, 19), (bench_x - 10, bench_y, 20, 3))
                pygame.draw.rect(self.screen, (139, 69, 19), (bench_x - 10, bench_y - 8, 3, 8))
                pygame.draw.rect(self.screen, (139, 69, 19), (bench_x + 7, bench_y - 8, 3, 8))
            
            # Draw fountain
            if park.fountain:
                fx, fy = park.fountain
                pygame.draw.circle(self.screen, (200, 200, 200), (fx, fy), 15)
                pygame.draw.circle(self.screen, (100, 150, 255), (fx, fy), 10)
    
    def draw_vehicles(self):
        """Draw all vehicles"""
        for vehicle in self.vehicles:
            # Apply speed force effect
            if self.speed_force_active:
                # Create motion blur effect
                for i in range(3):
                    alpha = 100 - i * 30
                    blur_color = (*vehicle.color, alpha)
                    blur_x = vehicle.x - i * vehicle.speed * 2
                    pygame.draw.rect(self.screen, vehicle.color, (blur_x, vehicle.y, vehicle.size[0], vehicle.size[1]))
            else:
                pygame.draw.rect(self.screen, vehicle.color, (vehicle.x, vehicle.y, vehicle.size[0], vehicle.size[1]))
    
    def draw_traffic_lights(self):
        """Draw traffic lights"""
        # Central City traffic light
        light_x = 350
        light_y = SCREEN_HEIGHT - 120
        
        pygame.draw.rect(self.screen, (0, 0, 0), (light_x, light_y, 20, 50))
        if self.traffic_lights["central"]:
            pygame.draw.circle(self.screen, TRAFFIC_LIGHT_GREEN, (light_x + 10, light_y + 15), 8)
        else:
            pygame.draw.circle(self.screen, TRAFFIC_LIGHT_RED, (light_x + 10, light_y + 35), 8)
        
        # Starling City traffic light
        light_x = SCREEN_WIDTH - 370
        light_y = SCREEN_HEIGHT - 120
        
        pygame.draw.rect(self.screen, (0, 0, 0), (light_x, light_y, 20, 50))
        if self.traffic_lights["starling"]:
            pygame.draw.circle(self.screen, TRAFFIC_LIGHT_GREEN, (light_x + 10, light_y + 15), 8)
        else:
            pygame.draw.circle(self.screen, TRAFFIC_LIGHT_RED, (light_x + 10, light_y + 35), 8)
    
    def draw_lightning(self):
        """Draw lightning effects"""
        for x, y, intensity in self.lightning_strikes:
            color = (intensity, intensity, intensity)
            pygame.draw.line(self.screen, color, (x, y), (x + random.randint(-20, 20), y + random.randint(10, 30)), 3)
    
    def draw_weather_effects(self):
        """Draw weather effects"""
        if self.weather == WeatherType.RAINY:
            for _ in range(100):
                x = random.randint(0, SCREEN_WIDTH)
                y = random.randint(0, SCREEN_HEIGHT)
                pygame.draw.line(self.screen, (100, 150, 255), (x, y), (x + 2, y + 10), 1)
        
        elif self.weather == WeatherType.FOGGY:
            fog_surface = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT))
            fog_surface.set_alpha(50)
            fog_surface.fill((200, 200, 200))
            self.screen.blit(fog_surface, (0, 0))
    
    def draw_speed_force_effects(self):
        """Draw speed force visual effects"""
        if self.speed_force_active:
            # Create speed lines
            for _ in range(20):
                x = random.randint(0, SCREEN_WIDTH)
                y = random.randint(0, SCREEN_HEIGHT)
                pygame.draw.line(self.screen, (255, 255, 255), (x, y), (x - 50, y), 2)
    
    def draw_ui(self):
        """Draw user interface elements"""
        font = pygame.font.Font(None, 36)
        
        # City labels
        central_text = font.render("CENTRAL CITY", True, (255, 255, 255))
        starling_text = font.render("STARLING CITY", True, (255, 255, 255))
        
        self.screen.blit(central_text, (50, 50))
        self.screen.blit(starling_text, (SCREEN_WIDTH - 200, 50))
        
        # Weather display
        weather_text = font.render(f"Weather: {self.weather.value.upper()}", True, (255, 255, 255))
        self.screen.blit(weather_text, (SCREEN_WIDTH // 2 - 100, 50))
        
        # Speed force indicator
        if self.speed_force_active:
            speed_text = font.render("SPEED FORCE ACTIVE!", True, (255, 255, 0))
            self.screen.blit(speed_text, (SCREEN_WIDTH // 2 - 100, 100))
        
        # Instructions
        instruction_font = pygame.font.Font(None, 24)
        instructions = [
            "Press SPACE to activate Speed Force",
            "Press R to change weather",
            "Press ESC to exit"
        ]
        
        for i, instruction in enumerate(instructions):
            text = instruction_font.render(instruction, True, (200, 200, 200))
            self.screen.blit(text, (10, SCREEN_HEIGHT - 80 + i * 25))
    
    def handle_events(self):
        """Handle user input events"""
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.running = False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    self.running = False
                elif event.key == pygame.K_SPACE:
                    self.activate_speed_force()
                elif event.key == pygame.K_r:
                    self.weather = random.choice(list(WeatherType))
    
    def update(self):
        """Update all game elements"""
        self.spawn_vehicles()
        self.update_vehicles()
        self.update_traffic_lights()
        self.update_weather()
        self.update_time()
        self.update_lightning()
        self.update_speed_force()
    
    def draw(self):
        """Draw all game elements"""
        self.draw_background()
        self.draw_roads()
        self.draw_bridge()
        self.draw_parks()
        self.draw_buildings()
        self.draw_vehicles()
        self.draw_traffic_lights()
        self.draw_lightning()
        self.draw_weather_effects()
        self.draw_speed_force_effects()
        self.draw_ui()
    
    def run(self):
        """Main game loop"""
        print("🚀 Starting Flashpoint Cities Simulation...")
        print("🏙️  Central City and Starling City are now connected!")
        print("⚡ Press SPACE to activate Speed Force!")
        print("🌦️  Press R to change weather!")
        print("🚗 Watch the traffic flow between cities!")
        
        while self.running:
            self.handle_events()
            self.update()
            self.draw()
            
            pygame.display.flip()
            self.clock.tick(FPS)
        
        pygame.quit()
        print("👋 Thanks for exploring Flashpoint Cities!")

def main():
    """Main entry point"""
    try:
        game = FlashpointCities()
        game.run()
    except Exception as e:
        print(f"❌ Error running simulation: {e}")
        print("💡 Make sure you have pygame installed: pip install pygame")

if __name__ == "__main__":
    main()