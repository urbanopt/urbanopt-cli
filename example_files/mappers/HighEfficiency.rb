# *********************************************************************************
# URBANopt (tm), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://github.com/urbanopt/urbanopt-example-geojson-project/blob/develop/LICENSE.md
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
    class HighEfficiencyMapper < BaselineMapper
      def create_osw(scenario, features, feature_names)
        osw = super(scenario, features, feature_names)

        feature = features[0]
        building_type = feature.building_type

        if residential_building_types.include? building_type
          args = {}
          osw[:steps].each do |step|
            next if step[:measure_dir_name] != 'BuildResidentialModel'

            step[:arguments].each do |arg_name, arg_val|
              args[arg_name] = arg_val
            end
          end

          args[:wall_assembly_r] = Float(args[:wall_assembly_r]) * 1.2 # 20% increase
          # the following are no longer required in HPXML v1.5.0
          # if this isn't set, set to 90% (0.9), else reduce to 90% of set value
          args[:misc_plug_loads_television_usage_multiplier] = args[:misc_plug_loads_television_usage_multiplier].nil? ? 0.9 : Float(args[:misc_plug_loads_television_usage_multiplier]) * 0.9 # 10% reduction
          args[:misc_plug_loads_other_usage_multiplier] = args[:misc_plug_loads_other_usage_multiplier].nil? ? 0.9 : Float(args[:misc_plug_loads_other_usage_multiplier]) * 0.9 # 10% reduction
          args[:lighting_interior_usage_multiplier] = args[:lighting_interior_usage_multiplier].nil? ? 0.9 : Float(args[:lighting_interior_usage_multiplier]) * 0.9 # 10% reduction
          args[:lighting_exterior_usage_multiplier] = args[:lighting_exterior_usage_multiplier].nil? ? 0.9 : Float(args[:lighting_exterior_usage_multiplier]) * 0.9 # 10% reduction
          args[:lighting_garage_usage_multiplier] = args[:lighting_garage_usage_multiplier].nil? ? 0.9 : Float(args[:lighting_garage_usage_multiplier]) * 0.9 # 10% reduction
          args[:clothes_washer_usage_multiplier] = args[:clothes_washer_usage_multiplier].nil? ? 0.9 : Float(args[:clothes_washer_usage_multiplier]) * 0.9 # 10% reduction
          args[:clothes_dryer_usage_multiplier] = args[:clothes_dryer_usage_multiplier].nil? ? 0.9 : Float(args[:clothes_dryer_usage_multiplier]) * 0.9 # 10% reduction
          args[:dishwasher_usage_multiplier] = args[:dishwasher_usage_multiplier].nil? ? 0.9 : Float(args[:dishwasher_usage_multiplier]) * 0.9 # 10% reduction
          args[:refrigerator_usage_multiplier] = args[:refrigerator_usage_multiplier].nil? ? 0.9 : Float(args[:refrigerator_usage_multiplier]) * 0.9 # 10% reduction
          args[:cooking_range_oven_usage_multiplier] = args[:cooking_range_oven_usage_multiplier].nil? ? 0.9 : Float(args[:cooking_range_oven_usage_multiplier]) * 0.9 # 10% reduction
          args[:water_fixtures_usage_multiplier] = args[:water_fixtures_usage_multiplier].nil? ? 0.9 : Float(args[:water_fixtures_usage_multiplier]) * 0.9 # 10% reduction

          args.each do |arg_name, arg_val|
            OpenStudio::Extension.set_measure_argument(osw, 'BuildResidentialModel', arg_name, arg_val)
          end
        elsif commercial_building_types.include? building_type
          OpenStudio::Extension.set_measure_argument(osw, 'IncreaseInsulationRValueForExteriorWalls', '__SKIP__', false)
          OpenStudio::Extension.set_measure_argument(osw, 'IncreaseInsulationRValueForExteriorWalls', 'r_value', 20)

          OpenStudio::Extension.set_measure_argument(osw, 'ReduceElectricEquipmentLoadsByPercentage', '__SKIP__', false)
          OpenStudio::Extension.set_measure_argument(osw, 'ReduceElectricEquipmentLoadsByPercentage', 'elecequip_power_reduction_percent', 20)

          OpenStudio::Extension.set_measure_argument(osw, 'ReduceLightingLoadsByPercentage', '__SKIP__', false)
          OpenStudio::Extension.set_measure_argument(osw, 'ReduceLightingLoadsByPercentage', 'lighting_power_reduction_percent', 10)
        end

        return osw
      end
    end
  end
end
