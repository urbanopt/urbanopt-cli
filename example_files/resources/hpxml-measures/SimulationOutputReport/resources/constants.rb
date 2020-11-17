# frozen_string_literal: true

class FT
  # Fuel Types
  Elec = 'Electricity'.freeze
  Gas = 'Natural Gas'.freeze
  Oil = 'Fuel Oil'.freeze
  Propane = 'Propane'.freeze
  WoodCord = 'Wood Cord'.freeze
  WoodPellets = 'Wood Pellets'.freeze
  Coal = 'Coal'.freeze
end

class EUT
  # End Use Types
  Heating = 'Heating'.freeze
  HeatingFanPump = 'Heating Fans/Pumps'.freeze
  Cooling = 'Cooling'.freeze
  CoolingFanPump = 'Cooling Fans/Pumps'.freeze
  HotWater = 'Hot Water'.freeze
  HotWaterRecircPump = 'Hot Water Recirc Pump'.freeze
  HotWaterSolarThermalPump = 'Hot Water Solar Thermal Pump'.freeze
  LightsInterior = 'Lighting Interior'.freeze
  LightsGarage = 'Lighting Garage'.freeze
  LightsExterior = 'Lighting Exterior'.freeze
  MechVent = 'Mech Vent'.freeze
  MechVentPreheat = 'Mech Vent Preheating'.freeze
  MechVentPrecool = 'Mech Vent Precooling'.freeze
  WholeHouseFan = 'Whole House Fan'.freeze
  Refrigerator = 'Refrigerator'.freeze
  Freezer = 'Freezer'.freeze
  Dehumidifier = 'Dehumidifier'.freeze
  Dishwasher = 'Dishwasher'.freeze
  ClothesWasher = 'Clothes Washer'.freeze
  ClothesDryer = 'Clothes Dryer'.freeze
  RangeOven = 'Range/Oven'.freeze
  CeilingFan = 'Ceiling Fan'.freeze
  Television = 'Television'.freeze
  PlugLoads = 'Plug Loads'.freeze
  Vehicle = 'Electric Vehicle Charging'.freeze
  WellPump = 'Well Pump'.freeze
  PoolHeater = 'Pool Heater'.freeze
  PoolPump = 'Pool Pump'.freeze
  HotTubHeater = 'Hot Tub Heater'.freeze
  HotTubPump = 'Hot Tub Pump'.freeze
  Grill = 'Grill'.freeze
  Lighting = 'Lighting'.freeze
  Fireplace = 'Fireplace'.freeze
  PV = 'PV'.freeze
end

class HWT
  # Hot Water Types
  ClothesWasher = 'Clothes Washer'.freeze
  Dishwasher = 'Dishwasher'.freeze
  Fixtures = 'Fixtures'.freeze
  DistributionWaste = 'Distribution Waste'.freeze
end

class LT
  # Load Types
  Heating = 'Heating'.freeze
  Cooling = 'Cooling'.freeze
  HotWaterDelivered = 'Hot Water: Delivered'.freeze
  HotWaterTankLosses = 'Hot Water: Tank Losses'.freeze
  HotWaterDesuperheater = 'Hot Water: Desuperheater'.freeze
  HotWaterSolarThermal = 'Hot Water: Solar Thermal'.freeze
end

class CLT
  # Component Load Types
  Roofs = 'Roofs'.freeze
  Ceilings = 'Ceilings'.freeze
  Walls = 'Walls'.freeze
  RimJoists = 'Rim Joists'.freeze
  FoundationWalls = 'Foundation Walls'.freeze
  Doors = 'Doors'.freeze
  Windows = 'Windows'.freeze
  Skylights = 'Skylights'.freeze
  Floors = 'Floors'.freeze
  Slabs = 'Slabs'.freeze
  InternalMass = 'Internal Mass'.freeze
  Infiltration = 'Infiltration'.freeze
  NaturalVentilation = 'Natural Ventilation'.freeze
  MechanicalVentilation = 'Mechanical Ventilation'.freeze
  WholeHouseFan = 'Whole House Fan'.freeze
  ClothesDryerExhaust = 'Clothes Dryer Exhaust'.freeze
  Ducts = 'Ducts'.freeze
  InternalGains = 'Internal Gains'.freeze
end

class PFT
  # Peak Fuel Types
  Summer = 'Summer'.freeze
  Winter = 'Winter'.freeze
end

class AFT
  # Airflow Types
  Infiltration = 'Infiltration'.freeze
  MechanicalVentilation = 'Mechanical Ventilation'.freeze
  NaturalVentilation = 'Natural Ventilation'.freeze
  WholeHouseFan = 'Whole House Fan'.freeze
  ClothesDryerExhaust = 'Clothes Dryer Exhaust'.freeze
end

class WT
  # Weather Types
  DrybulbTemp = 'Drybulb Temperature'.freeze
  WetbulbTemp = 'Wetbulb Temperature'.freeze
  RelativeHumidity = 'Relative Humidity'.freeze
  WindSpeed = 'Wind Speed'.freeze
  DiffuseSolar = 'Diffuse Solar Radiation'.freeze
  DirectSolar = 'Direct Solar Radiation'.freeze
end
