# *********************************************************************************
# URBANopt™, Copyright (c) 2019-2021, Alliance for Sustainable Energy, LLC, and other
# contributors. All rights reserved.

# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:

# Redistributions of source code must retain the above copyright notice, this list
# of conditions and the following disclaimer.

# Redistributions in binary form must reproduce the above copyright notice, this
# list of conditions and the following disclaimer in the documentation and/or other
# materials provided with the distribution.

# Neither the name of the copyright holder nor the names of its contributors may be
# used to endorse or promote products derived from this software without specific
# prior written permission.

# Redistribution of this software, without modification, must refer to the software
# by the same designation. Redistribution of a modified version of this software
# (i) may not refer to the modified version by the same designation, or by any
# confusingly similar designation, and (ii) must refer to the underlying software
# originally provided by Alliance as “URBANopt”. Except to comply with the foregoing,
# the term “URBANopt”, or any confusingly similar designation may not be used to
# refer to any modified version of this software or any modified version of the
# underlying software originally provided by Alliance without the prior written
# consent of Alliance.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
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
          args[:plug_loads_television_usage_multiplier] = Float(args[:plug_loads_television_usage_multiplier]) * 0.9 # 10% reduction
          args[:plug_loads_other_usage_multiplier] = Float(args[:plug_loads_other_usage_multiplier]) * 0.9 # 10% reduction
          args[:lighting_usage_multiplier_interior] = Float(args[:lighting_usage_multiplier_interior]) * 0.9 # 10% reduction
          args[:lighting_usage_multiplier_exterior] = Float(args[:lighting_usage_multiplier_exterior]) * 0.9 # 10% reduction
          args[:clothes_washer_usage_multiplier] = Float(args[:clothes_washer_usage_multiplier]) * 0.9 # 10% reduction
          args[:clothes_dryer_usage_multiplier] = Float(args[:clothes_dryer_usage_multiplier]) * 0.9 # 10% reduction
          args[:dishwasher_usage_multiplier] = Float(args[:dishwasher_usage_multiplier]) * 0.9 # 10% reduction
          args[:refrigerator_usage_multiplier] = Float(args[:refrigerator_usage_multiplier]) * 0.9 # 10% reduction
          args[:cooking_range_oven_usage_multiplier] = Float(args[:cooking_range_oven_usage_multiplier]) * 0.9 # 10% reduction
          args[:water_fixtures_usage_multiplier] = Float(args[:water_fixtures_usage_multiplier]) * 0.9 # 10% reduction

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
