# *********************************************************************************
# URBANopt (tm), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://github.com/urbanopt/urbanopt-cli/blob/develop/LICENSE.md
# *********************************************************************************

require 'urbanopt/reporting'
require 'openstudio/common_measures'
require 'openstudio/model_articulation'
require 'openstudio/ee_measures'
require 'openstudio/calibration'

require_relative 'Baseline'

require 'json'

module URBANopt
  module Scenario
    class ClassProjectMapper < BaselineMapper
      def create_osw(scenario, features, feature_names)
        osw = super(scenario, features, feature_names)

        feature = features[0]
        building_type = feature.building_type

        # Energy Efficiency Measures

        OpenStudio::Extension.set_measure_argument(osw, 'AddOverhangsByProjectionFactor', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'AddOverhangsByProjectionFactor', 'projection_factor', 0.5)

        OpenStudio::Extension.set_measure_argument(osw, 'EnableDemandControlledVentilation', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'EnableDemandControlledVentilation', 'dcv_type', 'EnableDCV')

        OpenStudio::Extension.set_measure_argument(osw, 'EnableEconomizerControl', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'EnableEconomizerControl', 'economizer_type', 'FixedDryBulb')

        OpenStudio::Extension.set_measure_argument(osw, 'ImproveFanBeltEfficiency', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'ImproveFanBeltEfficiency', 'motor_eff', 3.0)

        OpenStudio::Extension.set_measure_argument(osw, 'ImproveMotorEfficiency', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'ImproveMotorEfficiency', 'motor_eff', 96.0)

        OpenStudio::Extension.set_measure_argument(osw, 'IncreaseInsulationRValueForExteriorWalls', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'IncreaseInsulationRValueForExteriorWalls', 'r_value', 13.0)

        OpenStudio::Extension.set_measure_argument(osw, 'IncreaseInsulationRValueForRoofs', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'IncreaseInsulationRValueForRoofs', 'r_value', 30.0)

        OpenStudio::Extension.set_measure_argument(osw, 'ReduceElectricEquipmentLoadsByPercentage', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'ReduceElectricEquipmentLoadsByPercentage', 'elecequip_power_reduction_percent', 30.0)

        OpenStudio::Extension.set_measure_argument(osw, 'ReduceLightingLoadsByPercentage', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'ReduceLightingLoadsByPercentage', 'lighting_power_reduction_percent', 30.0)

        OpenStudio::Extension.set_measure_argument(osw, 'ReduceSpaceInfiltrationByPercentage', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'ReduceSpaceInfiltrationByPercentage', 'space_infiltration_reduction_percent', 30.0)

        # Demand Flexibility Measures

        OpenStudio::Extension.set_measure_argument(osw, 'add_ev_load', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'add_ev_load', 'delay_type', 'Min Delay')

        OpenStudio::Extension.set_measure_argument(osw, 'add_ems_to_control_ev_charging', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'add_ems_to_control_ev_charging', 'curtailment_frac', 0.95)

        OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'vol', 2)
        OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'max_temp', 185)
        OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'min_temp', 125)
        OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'flex0', 'Charge - Heat Pump')
        OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'flex_hrs0', '02:00-08:00')
        OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'flex1', 'Float')
        OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'flex_hrs1', '08:01-20:00')

        OpenStudio::Extension.set_measure_argument(osw, 'add_packaged_ice_storage', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'add_packaged_ice_storage', 'ice_cap', 'AutoSize')

        OpenStudio::Extension.set_measure_argument(osw, 'ShiftScheduleByType', '__SKIP__', true)
        OpenStudio::Extension.set_measure_argument(osw, 'ShiftScheduleByType', 'shift_value', -2)
        OpenStudio::Extension.set_measure_argument(osw, 'ShiftScheduleByType', 'schedchoice', 'CoolHeat')

        return osw
      end
    end
  end
end
