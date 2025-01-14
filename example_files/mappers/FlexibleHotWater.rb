# *********************************************************************************
# URBANopt (tm), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://github.com/urbanopt/urbanopt-example-geojson-project/blob/develop/LICENSE.md
# *********************************************************************************

require 'urbanopt/reporting'

require_relative 'Baseline'

require 'json'

module URBANopt
  module Scenario
    class FlexibleHotWaterMapper < BaselineMapper
      def create_osw(scenario, features, feature_names)
        osw = super(scenario, features, feature_names)

        feature = features[0]
        building_type = feature.building_type

        # Only apply to commercial buildings, not residential models
        if commercial_building_types.include? building_type
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', '__SKIP__', false)
          # Add a sizing multiplier to the tank capacity to cover flex periods
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'vol', 2)
          # Update maximum tank and minimum temperature setpoints
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'max_temp', 185)
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'min_temp', 125)

          # Manage water heat charge float periods by building
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'flex0', 'Charge - Heat Pump')
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'flex_hrs0', '16:00-17:00')
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'flex1', 'Float')
          OpenStudio::Extension.set_measure_argument(osw, 'add_hpwh', 'flex_hrs1', '17:01-19:00')
        end

        return osw
      end
    end
  end
end
