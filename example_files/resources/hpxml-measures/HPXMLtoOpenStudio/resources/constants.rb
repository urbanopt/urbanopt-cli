# frozen_string_literal: true

class Constants
  # Numbers --------------------

  def self.AssumedInsideTemp
    73.5 # deg-F
  end

  def self.g
    32.174 # gravity (ft/s2)
  end

  def self.MonthNumDays
    [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  end

  def self.small
    1e-9
  end

  # Strings --------------------

  def self.AirFilm
    'AirFilm'
  end

  def self.CalcTypeERIRatedHome
    'ERI Rated Home'
  end

  def self.CalcTypeERIReferenceHome
    'ERI Reference Home'
  end

  def self.CalcTypeERIIndexAdjustmentDesign
    'ERI Index Adjustment Design'
  end

  def self.CalcTypeERIIndexAdjustmentReferenceHome
    'ERI Index Adjustment Reference Home'
  end

  def self.BoreConfigSingle
    'single'
  end

  def self.BoreConfigLine
    'line'
  end

  def self.BoreConfigOpenRectangle
    'open-rectangle'
  end

  def self.BoreConfigRectangle
    'rectangle'
  end

  def self.BoreConfigLconfig
    'l-config'
  end

  def self.BoreConfigL2config
    'l2-config'
  end

  def self.BoreConfigUconfig
    'u-config'
  end

  def self.BuildingAmericaClimateZone
    'Building America'
  end

  def self.ERIVersions
    %w[2014 2014A 2014AD 2014ADE 2014ADEG 2014ADEGL 2019 2019A 2019AB]
  end

  def self.FluidWater
    'water'
  end

  def self.FluidPropyleneGlycol
    'propylene-glycol'
  end

  def self.FluidEthyleneGlycol
    'ethylene-glycol'
  end

  def self.IsDuctLoadForReport
    __method__.to_s
  end

  def self.ObjectNameAirflow
    'airflow'
  end

  def self.ObjectNameAirSourceHeatPump
    'air source heat pump'
  end

  def self.ObjectNameBackupHeatingCoil
    'backup htg coil'
  end

  def self.ObjectNameBoiler
    'boiler'
  end

  def self.ObjectNameCeilingFan
    'ceiling fan'
  end

  def self.ObjectNameCentralAirConditioner
    'central ac'
  end

  def self.ObjectNameCentralAirConditionerAndFurnace
    'central ac and furnace'
  end

  def self.ObjectNameClothesWasher
    'clothes washer'
  end

  def self.ObjectNameClothesDryer
    'clothes dryer'
  end

  def self.ObjectNameCombiWaterHeatingEnergy(water_heater_name)
    "#{water_heater_name} dhw energy"
  end

  def self.ObjectNameComponentLoadsProgram
    'component loads program'
  end

  def self.ObjectNameCookingRange
    'cooking range'
  end

  def self.ObjectNameCoolingSeason
    'cooling season'
  end

  def self.ObjectNameCoolingSetpoint
    'cooling setpoint'
  end

  def self.ObjectNameDehumidifier
    'dehumidifier'
  end

  def self.ObjectNameDesuperheater(water_heater_name)
    "#{water_heater_name} Desuperheater"
  end

  def self.ObjectNameDishwasher
    'dishwasher'
  end

  def self.ObjectNameDistributionWaste
    'dhw distribution waste'
  end

  def self.ObjectNameDucts
    'ducts'
  end

  def self.ObjectNameElectricBaseboard
    'baseboard'
  end

  def self.ObjectNameERVHRV
    'erv or hrv'
  end

  def self.ObjectNameEvaporativeCooler
    'evap cooler'
  end

  def self.ObjectNameExteriorLighting
    'exterior lighting'
  end

  def self.ObjectNameFanPumpDisaggregateCool(fan_or_pump_name = '')
    "#{fan_or_pump_name} clg disaggregate"
  end

  def self.ObjectNameFanPumpDisaggregatePrimaryHeat(fan_or_pump_name = '')
    "#{fan_or_pump_name} htg primary disaggregate"
  end

  def self.ObjectNameFanPumpDisaggregateBackupHeat(fan_or_pump_name = '')
    "#{fan_or_pump_name} htg backup disaggregate"
  end

  def self.ObjectNameFixtures
    'dhw fixtures'
  end

  def self.ObjectNameFreezer
    'freezer'
  end

  def self.ObjectNameFurnace
    'furnace'
  end

  def self.ObjectNameFurniture
    'furniture'
  end

  def self.ObjectNameGarageLighting
    'garage lighting'
  end

  def self.ObjectNameGroundSourceHeatPump
    'ground source heat pump'
  end

  def self.ObjectNameHeatingSeason
    'heating season'
  end

  def self.ObjectNameHeatingSetpoint
    'heating setpoint'
  end

  def self.ObjectNameHotWaterRecircPump
    'dhw recirc pump'
  end

  def self.ObjectNameIdealAirSystem
    'ideal'
  end

  def self.ObjectNameIdealAirSystemResidual
    'ideal residual'
  end

  def self.ObjectNameInfiltration
    'infil'
  end

  def self.ObjectNameInteriorLighting
    'interior lighting'
  end

  def self.ObjectNameLightingExteriorHoliday
    'exterior holiday lighting'
  end

  def self.ObjectNameMechanicalVentilation
    'mech vent'
  end

  def self.ObjectNameMechanicalVentilationPreconditioning
    'mech vent preconditioning'
  end

  def self.ObjectNameMechanicalVentilationHouseFan
    'mech vent house fan'
  end

  def self.ObjectNameMechanicalVentilationHouseFanCFIS
    'mech vent house fan cfis'
  end

  def self.ObjectNameMechanicalVentilationBathFan
    'mech vent bath fan'
  end

  def self.ObjectNameMechanicalVentilationRangeFan
    'mech vent range fan'
  end

  def self.ObjectNameMechanicalVentilationAirflow
    'Qfan'
  end

  def self.ObjectNameMiniSplitHeatPump
    'mini split heat pump'
  end

  def self.ObjectNameMiscGrill
    'misc grill'
  end

  def self.ObjectNameMiscLighting
    'misc lighting'
  end

  def self.ObjectNameMiscFireplace
    'misc fireplace'
  end

  def self.ObjectNameMiscPoolHeater
    'misc pool heater'
  end

  def self.ObjectNameMiscPoolPump
    'misc pool pump'
  end

  def self.ObjectNameMiscHotTubHeater
    'misc hot tub heater'
  end

  def self.ObjectNameMiscHotTubPump
    'misc hot tub pump'
  end

  def self.ObjectNameMiscPlugLoads
    'misc plug loads'
  end

  def self.ObjectNameMiscTelevision
    'misc tv'
  end

  def self.ObjectNameMiscElectricVehicleCharging
    'misc electric vehicle charging'
  end

  def self.ObjectNameMiscWellPump
    'misc well pump'
  end

  def self.ObjectNameNaturalVentilation
    'natural vent'
  end

  def self.ObjectNameNeighbors
    'neighbors'
  end

  def self.ObjectNameOccupants
    'occupants'
  end

  def self.ObjectNameOverhangs
    'overhangs'
  end

  def self.ObjectNamePlantLoopDHW
    'dhw loop'
  end

  def self.ObjectNamePlantLoopSHW
    'solar hot water loop'
  end

  def self.ObjectNameRefrigerator
    'fridge'
  end

  def self.ObjectNameRelativeHumiditySetpoint
    'rh setpoint'
  end

  def self.ObjectNameRoomAirConditioner
    'room ac'
  end

  def self.ObjectNameSharedPump(hvac_name)
    "#{hvac_name} shared pump"
  end

  def self.ObjectNameSolarHotWater
    'solar hot water'
  end

  def self.ObjectNameTankHX
    'dhw source hx'
  end

  def self.ObjectNameUnitHeater
    'unit heater'
  end

  def self.ObjectNameWaterHeater
    'water heater'
  end

  def self.ObjectNameWaterLatent
    'water latent'
  end

  def self.ObjectNameWaterSensible
    'water sensible'
  end

  def self.ObjectNameWaterHeaterAdjustment(water_heater_name)
    "#{water_heater_name} EC adjustment"
  end

  def self.ObjectNameWaterLoopHeatPump
    'water loop heat pump'
  end

  def self.ObjectNameWholeHouseFan
    'whole house fan'
  end

  def self.ScheduleTypeLimitsFraction
    'Fractional'
  end

  def self.ScheduleTypeLimitsOnOff
    'OnOff'
  end

  def self.ScheduleTypeLimitsTemperature
    'Temperature'
  end

  def self.SizingInfoDuctExist
    __method__.to_s
  end

  def self.SizingInfoDuctSides
    __method__.to_s
  end

  def self.SizingInfoDuctLocations
    __method__.to_s
  end

  def self.SizingInfoDuctLeakageFracs
    __method__.to_s
  end

  def self.SizingInfoDuctLeakageCFM25s
    __method__.to_s
  end

  def self.SizingInfoDuctAreas
    __method__.to_s
  end

  def self.SizingInfoDuctRvalues
    __method__.to_s
  end

  def self.SizingInfoHVACFracHeatLoadServed
    __method__.to_s
  end

  def self.SizingInfoHVACFracCoolLoadServed
    __method__.to_s
  end

  def self.SizingInfoHVACCoolType
    __method__.to_s
  end

  def self.SizingInfoHVACHeatType
    __method__.to_s
  end

  def self.SizingInfoHVACPumpPower
    __method__.to_s
  end

  def self.SizingInfoHVACSystemIsDucted # Only needed for optionally ducted systems
    __method__.to_s
  end

  def self.SizingInfoGSHPBoreConfig
    __method__.to_s
  end

  def self.SizingInfoGSHPBoreDepth
    __method__.to_s
  end

  def self.SizingInfoGSHPBoreHoles
    __method__.to_s
  end

  def self.SizingInfoGSHPBoreSpacing
    __method__.to_s
  end

  def self.SizingInfoGSHPCoil_BF_FT_SPEC
    __method__.to_s
  end

  def self.SizingInfoGSHPCoilBF
    __method__.to_s
  end

  def self.SizingInfoGSHPUTubeSpacingType
    __method__.to_s
  end

  def self.SizingInfoHVACCapacityRatioCooling
    __method__.to_s
  end

  def self.SizingInfoHVACCapacityRatioHeating
    __method__.to_s
  end

  def self.SizingInfoHVACCoolingCFMs
    __method__.to_s
  end

  def self.SizingInfoHVACHeatingCapacityOffset
    __method__.to_s
  end

  def self.SizingInfoHVACHeatingCFMs
    __method__.to_s
  end

  def self.SizingInfoHVACRatedCFMperTonHeating
    __method__.to_s
  end

  def self.SizingInfoHVACRatedCFMperTonCooling
    __method__.to_s
  end

  def self.SizingInfoHVACSHR
    __method__.to_s
  end

  def self.SizingInfoMechVentExist
    __method__.to_s
  end

  def self.SizingInfoMechVentApparentSensibleEffectiveness
    __method__.to_s
  end

  def self.SizingInfoMechVentLatentEffectiveness
    __method__.to_s
  end

  def self.SizingInfoMechVentWholeHouseRateBalanced
    __method__.to_s
  end

  def self.SizingInfoMechVentWholeHouseRateUnbalanced
    __method__.to_s
  end

  def self.SizingInfoMechVentWholeHouseRatePreHeated
    __method__.to_s
  end

  def self.SizingInfoMechVentWholeHouseRatePreCooled
    __method__.to_s
  end

  def self.SizingInfoMechVentWholeHouseRateRecirculated
    __method__.to_s
  end

  def self.SizingInfoSIPWallInsThickness
    __method__.to_s
  end

  def self.SizingInfoZoneInfiltrationACH
    __method__.to_s
  end

  def self.SizingInfoZoneInfiltrationCFM
    __method__.to_s
  end
end
