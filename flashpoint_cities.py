#!/usr/bin/env python3
"""
Flashpoint Cities - Central City & Starling City Simulation
A unique city simulation featuring two connected cities with roads, parks, and interactive elements.
"""

import pygame
import math
import random
import sys
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass
from enum import Enum

# Initialize Pygame
pygame.init()

# Constants
SCREEN_WIDTH = 1400
SCREEN_HEIGHT = 800
FPS = 60

# Colors
SKY_BLUE = (135, 206, 235)
CITY_GRAY = (64, 64, 64)
ROAD_GRAY = (45, 45, 45)
BRIDGE_COLOR = (105, 105, 105)
GRASS_GREEN = (34, 139, 34)
PARK_GREEN = (0, 128, 0)
WATER_BLUE = (0, 100, 200)
BUILDING_COLORS = [(70, 70, 70), (80, 80, 80), (90, 90, 90), (100, 100, 100)]
STREET_LIGHT = (255, 255, 200)
CAR_COLORS = [(255, 0, 0), (0, 0, 255), (255, 255, 0), (0, 255, 0), (255, 165, 0)]

class CityType(Enum):
    CENTRAL = "Central City"
    STARLING = "Starling City"

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
class Road:
    start: Tuple[int, int]
    end: Tuple[int, int]
    width: int
    lanes: int

@dataclass
class Park:
    x: int
    y: int
    width: int
    height: int
    trees: List[Tuple[int, int]]
    benches: List[Tuple[int, int]]

@dataclass
class Car:
    x: float
    y: float
    speed: float
    color: Tuple[int, int, int]
    direction: float
    road_index: int

class FlashpointCities:
    def __init__(self):
        self.screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
        pygame.display.set_caption("Flashpoint Cities - Central City & Starling City")
        self.clock = pygame.time.Clock()
        self.running = True
        
        # City boundaries
        self.central_city_rect = pygame.Rect(50, 50, 600, 700)
        self.starling_city_rect = pygame.Rect(750, 50, 600, 700)
        self.bridge_rect = pygame.Rect(650, 300, 100, 200)
        
        # Game objects
        self.buildings: List[Building] = []
        self.roads: List[Road] = []
        self.parks: List[Park] = []
        self.cars: List[Car] = []
        self.time_of_day = 0  # 0-24 hours
        
        # Initialize cities
        self._initialize_cities()
        self._create_roads()
        self._create_parks()
        self._spawn_cars()
        
        # Interactive elements
        self.selected_city = None
        self.zoom_level = 1.0
        self.camera_x = 0
        self.camera_y = 0
        
    def _initialize_cities(self):
        """Initialize buildings for both cities"""
        # Central City buildings (more tech-focused)
        central_buildings = [
            # Tech district
            (100, 100, 80, 120, "tech"),
            (200, 80, 90, 140, "tech"),
            (320, 100, 70, 100, "tech"),
            (420, 90, 85, 130, "tech"),
            
            # Business district
            (100, 300, 100, 80, "business"),
            (220, 280, 120, 100, "business"),
            (360, 300, 90, 90, "business"),
            (470, 290, 110, 110, "business"),
            
            # Residential
            (120, 500, 60, 80, "residential"),
            (200, 480, 70, 90, "residential"),
            (290, 500, 65, 85, "residential"),
            (380, 490, 75, 95, "residential"),
            (470, 500, 60, 80, "residential"),
        ]
        
        # Starling City buildings (more industrial)
        starling_buildings = [
            # Industrial district
            (800, 100, 100, 100, "industrial"),
            (920, 90, 110, 110, "industrial"),
            (1050, 100, 90, 90, "industrial"),
            (1160, 95, 100, 105, "industrial"),
            
            # Harbor district
            (800, 300, 80, 120, "harbor"),
            (900, 280, 90, 140, "harbor"),
            (1010, 300, 85, 130, "harbor"),
            (1115, 290, 90, 135, "harbor"),
            
            # Residential
            (820, 500, 70, 90, "residential"),
            (910, 480, 80, 100, "residential"),
            (1010, 500, 75, 85, "residential"),
            (1105, 490, 70, 95, "residential"),
        ]
        
        # Create buildings
        for x, y, w, h, building_type in central_buildings + starling_buildings:
            color = self._get_building_color(building_type)
            windows = self._generate_windows(x, y, w, h)
            lit_windows = [random.choice([True, False]) for _ in windows]
            
            self.buildings.append(Building(x, y, w, h, color, windows, lit_windows))
    
    def _get_building_color(self, building_type: str) -> Tuple[int, int, int]:
        """Get color based on building type"""
        colors = {
            "tech": (100, 150, 200),
            "business": (120, 120, 120),
            "industrial": (80, 80, 80),
            "harbor": (90, 100, 110),
            "residential": (110, 110, 100)
        }
        return colors.get(building_type, (100, 100, 100))
    
    def _generate_windows(self, x: int, y: int, w: int, h: int) -> List[Tuple[int, int, int, int]]:
        """Generate window positions for a building"""
        windows = []
        window_size = 8
        spacing = 15
        
        for row in range(2, h - 10, spacing):
            for col in range(10, w - 10, spacing):
                if random.random() < 0.7:  # 70% chance of window
                    windows.append((x + col, y + row, window_size, window_size))
        
        return windows
    
    def _create_roads(self):
        """Create road network connecting both cities"""
        # Main roads within cities
        self.roads = [
            # Central City roads
            Road((100, 200), (600, 200), 20, 2),  # Main street
            Road((100, 400), (600, 400), 20, 2),  # Secondary street
            Road((300, 100), (300, 600), 20, 2),  # Vertical street
            
            # Starling City roads
            Road((800, 200), (1300, 200), 20, 2),  # Main street
            Road((800, 400), (1300, 400), 20, 2),  # Secondary street
            Road((1100, 100), (1100, 600), 20, 2),  # Vertical street
            
            # Bridge connecting cities
            Road((600, 350), (750, 350), 30, 4),  # Bridge road
            Road((600, 400), (750, 400), 30, 4),  # Bridge road
        ]
    
    def _create_parks(self):
        """Create parks and green spaces"""
        # Central City parks
        central_park = Park(150, 550, 200, 100, [], [])
        central_park.trees = [(170, 570), (200, 580), (230, 570), (180, 600), (220, 600)]
        central_park.benches = [(190, 590), (210, 590)]
        
        # Starling City parks
        starling_park = Park(850, 550, 200, 100, [], [])
        starling_park.trees = [(870, 570), (900, 580), (930, 570), (880, 600), (920, 600)]
        starling_park.benches = [(890, 590), (910, 590)]
        
        # Bridge park (unique feature!)
        bridge_park = Park(650, 250, 100, 50, [], [])
        bridge_park.trees = [(670, 270), (690, 275), (710, 270)]
        bridge_park.benches = [(680, 290), (700, 290)]
        
        self.parks = [central_park, starling_park, bridge_park]
    
    def _spawn_cars(self):
        """Spawn cars on roads"""
        for i, road in enumerate(self.roads):
            # Spawn cars on each road
            num_cars = random.randint(2, 5)
            for j in range(num_cars):
                if road.start[0] == road.end[0]:  # Vertical road
                    x = road.start[0] + random.randint(-road.width//4, road.width//4)
                    y = road.start[1] + (road.end[1] - road.start[1]) * j / num_cars
                    direction = math.pi/2 if road.end[1] > road.start[1] else -math.pi/2
                else:  # Horizontal road
                    x = road.start[0] + (road.end[0] - road.start[0]) * j / num_cars
                    y = road.start[1] + random.randint(-road.width//4, road.width//4)
                    direction = 0 if road.end[0] > road.start[0] else math.pi
                
                speed = random.uniform(1, 3)
                color = random.choice(CAR_COLORS)
                
                self.cars.append(Car(x, y, speed, color, direction, i))
    
    def _update_cars(self):
        """Update car positions"""
        for car in self.cars:
            # Move car in its direction
            car.x += math.cos(car.direction) * car.speed
            car.y += math.sin(car.direction) * car.speed
            
            # Wrap around screen edges
            if car.x < 0:
                car.x = SCREEN_WIDTH
            elif car.x > SCREEN_WIDTH:
                car.x = 0
            
            if car.y < 0:
                car.y = SCREEN_HEIGHT
            elif car.y > SCREEN_HEIGHT:
                car.y = 0
    
    def _update_lighting(self):
        """Update city lighting based on time of day"""
        self.time_of_day += 0.01
        if self.time_of_day >= 24:
            self.time_of_day = 0
        
        # Update building window lights
        for building in self.buildings:
            for i, lit in enumerate(building.lit_windows):
                # Randomly toggle lights based on time
                if random.random() < 0.001:  # Small chance to toggle
                    building.lit_windows[i] = not lit
    
    def _draw_background(self):
        """Draw sky and water background"""
        # Sky gradient
        for y in range(SCREEN_HEIGHT):
            color_factor = y / SCREEN_HEIGHT
            sky_color = (
                int(135 + color_factor * 50),
                int(206 + color_factor * 30),
                int(235 + color_factor * 20)
            )
            pygame.draw.line(self.screen, sky_color, (0, y), (SCREEN_WIDTH, y))
        
        # Water between cities
        water_rect = pygame.Rect(650, 0, 100, SCREEN_HEIGHT)
        pygame.draw.rect(self.screen, WATER_BLUE, water_rect)
    
    def _draw_bridge(self):
        """Draw the bridge connecting cities"""
        # Bridge structure
        pygame.draw.rect(self.screen, BRIDGE_COLOR, self.bridge_rect)
        
        # Bridge supports
        for i in range(3):
            support_x = self.bridge_rect.x + i * 50
            pygame.draw.rect(self.screen, (60, 60, 60), 
                           (support_x, self.bridge_rect.bottom, 20, 100))
        
        # Bridge lights
        for i in range(5):
            light_x = self.bridge_rect.x + i * 25
            pygame.draw.circle(self.screen, STREET_LIGHT, 
                             (light_x, self.bridge_rect.y - 10), 5)
    
    def _draw_roads(self):
        """Draw all roads"""
        for road in self.roads:
            # Draw road
            pygame.draw.line(self.screen, ROAD_GRAY, road.start, road.end, road.width)
            
            # Draw lane markings
            if road.lanes > 1:
                mid_x = (road.start[0] + road.end[0]) // 2
                mid_y = (road.start[1] + road.end[1]) // 2
                pygame.draw.line(self.screen, (255, 255, 255), 
                               road.start, road.end, 2)
    
    def _draw_buildings(self):
        """Draw all buildings"""
        for building in self.buildings:
            # Draw building
            pygame.draw.rect(self.screen, building.color, 
                           (building.x, building.y, building.width, building.height))
            
            # Draw windows
            for i, window in enumerate(building.windows):
                if building.lit_windows[i]:
                    pygame.draw.rect(self.screen, STREET_LIGHT, window)
                else:
                    pygame.draw.rect(self.screen, (20, 20, 20), window)
    
    def _draw_parks(self):
        """Draw parks and green spaces"""
        for park in self.parks:
            # Draw grass
            pygame.draw.rect(self.screen, GRASS_GREEN, 
                           (park.x, park.y, park.width, park.height))
            
            # Draw trees
            for tree_x, tree_y in park.trees:
                # Tree trunk
                pygame.draw.rect(self.screen, (101, 67, 33), 
                               (tree_x - 3, tree_y, 6, 15))
                # Tree leaves
                pygame.draw.circle(self.screen, PARK_GREEN, 
                                 (tree_x, tree_y - 5), 12)
            
            # Draw benches
            for bench_x, bench_y in park.benches:
                pygame.draw.rect(self.screen, (101, 67, 33), 
                               (bench_x - 10, bench_y, 20, 3))
                pygame.draw.rect(self.screen, (101, 67, 33), 
                               (bench_x - 10, bench_y - 8, 3, 8))
                pygame.draw.rect(self.screen, (101, 67, 33), 
                               (bench_x + 7, bench_y - 8, 3, 8))
    
    def _draw_cars(self):
        """Draw all cars"""
        for car in self.cars:
            # Car body
            car_rect = pygame.Rect(car.x - 8, car.y - 4, 16, 8)
            pygame.draw.rect(self.screen, car.color, car_rect)
            
            # Car direction indicator
            front_x = car.x + math.cos(car.direction) * 8
            front_y = car.y + math.sin(car.direction) * 8
            pygame.draw.circle(self.screen, (255, 255, 255), (int(front_x), int(front_y)), 2)
    
    def _draw_ui(self):
        """Draw user interface"""
        # Time display
        font = pygame.font.Font(None, 36)
        time_text = f"Time: {self.time_of_day:.1f}:00"
        time_surface = font.render(time_text, True, (255, 255, 255))
        self.screen.blit(time_surface, (10, 10))
        
        # City labels
        central_label = font.render("Central City", True, (255, 255, 255))
        starling_label = font.render("Starling City", True, (255, 255, 255))
        
        self.screen.blit(central_label, (self.central_city_rect.x + 10, 
                                       self.central_city_rect.y + 10))
        self.screen.blit(starling_label, (self.starling_city_rect.x + 10, 
                                        self.starling_city_rect.y + 10))
        
        # Instructions
        small_font = pygame.font.Font(None, 24)
        instructions = [
            "Click on cities to interact",
            "ESC to quit",
            "Space to pause/resume time"
        ]
        
        for i, instruction in enumerate(instructions):
            text_surface = small_font.render(instruction, True, (200, 200, 200))
            self.screen.blit(text_surface, (10, SCREEN_HEIGHT - 80 + i * 25))
    
    def _handle_events(self):
        """Handle user input"""
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.running = False
            
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    self.running = False
                elif event.key == pygame.K_SPACE:
                    # Toggle time pause
                    pass
            
            elif event.type == pygame.MOUSEBUTTONDOWN:
                mouse_x, mouse_y = pygame.mouse.get_pos()
                
                # Check city selection
                if self.central_city_rect.collidepoint(mouse_x, mouse_y):
                    self.selected_city = CityType.CENTRAL
                    print("Selected Central City!")
                elif self.starling_city_rect.collidepoint(mouse_x, mouse_y):
                    self.selected_city = CityType.STARLING
                    print("Selected Starling City!")
                else:
                    self.selected_city = None
    
    def run(self):
        """Main game loop"""
        while self.running:
            self._handle_events()
            
            # Update game state
            self._update_cars()
            self._update_lighting()
            
            # Draw everything
            self._draw_background()
            self._draw_roads()
            self._draw_parks()
            self._draw_buildings()
            self._draw_bridge()
            self._draw_cars()
            self._draw_ui()
            
            # Highlight selected city
            if self.selected_city:
                if self.selected_city == CityType.CENTRAL:
                    pygame.draw.rect(self.screen, (255, 255, 0), 
                                   self.central_city_rect, 5)
                else:
                    pygame.draw.rect(self.screen, (255, 255, 0), 
                                   self.starling_city_rect, 5)
            
            pygame.display.flip()
            self.clock.tick(FPS)
        
        pygame.quit()
        sys.exit()

def main():
    """Main function"""
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
    
    game = FlashpointCities()
    game.run()

if __name__ == "__main__":
    main()