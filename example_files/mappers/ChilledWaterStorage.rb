# *********************************************************************************
# URBANopt (tm), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://github.com/urbanopt/urbanopt-reopt-gem/blob/develop/LICENSE.md
# *********************************************************************************

# Mapper created by LBNL using the measure from openstudio-geb gem
# (https://github.com/LBNL-ETA/Openstudio-GEB-gem)
# *********************************************************************************

require 'urbanopt/reporting'
require 'openstudio/geb'

require_relative 'Baseline'

require 'json'

module URBANopt
  module Scenario
    class ChilledWaterStorageMapper < BaselineMapper
      def create_osw(scenario, features, feature_names)
        osw = super(scenario, features, feature_names)

        feature = features[0]
        building_type = feature.building_type

        # Only apply to commercial buildings, not residential models
        if commercial_building_types.include? building_type
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', '__SKIP__', false)
          # Provide a tank volume in m3 or a sizing run will be run to decide the tank volume automatically
          # OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'tank_vol', 2)

          # Select to use the tank for "Full Storage" or "Partial Storage"
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'objective', 'Partial Storage')

          # Select a plant loop as the primary loop to add the water tank on. By default it will be "Chilled water loop" if exists
          # OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'selected_primary_loop_name', "Chilled water loop")

          # Primary Loop (charging) Setpoint Temperature in degree C
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'primary_loop_sp', 6.7)
          # Secondary Loop (discharging) Setpoint Temperature in degree C
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'secondary_loop_sp', 6.7)
          # Chilled Water Tank Setpoint Temperature in degree C
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'tank_charge_sp', 6.7)
          # Loop Design Temperature Difference in degree C. Use the existing setting or provide a numeric value
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'primary_delta_t', 'Use Existing Loop Value')
          # Secondary Loop Design Temperature Difference in degree C
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'secondary_delta_t', 4.5)

          # Start date of availability of Chilled Water Storage. Use MM-DD format, e.g., 04-01. Default is 01-01.
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'thermal_storage_startdate', '01-01')
          # End date of availability of Chilled Water Storage. Use MM-DD format, e.g., 10-31. Default is 12-31.
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'thermal_storage_enddate', '12-31')
          # Starting Time for Chilled Water Tank Discharge. Use 24 hour format (HH:MM)
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'discharge_start', '08:00')
          # End Time for Chilled Water Tank Discharge. Use 24 hour format (HH:MM)
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'discharge_end', '21:00')
          # Starting Time for Chilled Water Tank Charge. Use 24 hour format (HH:MM)
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'charge_start', '23:00')
          # End Time for Chilled Water Tank Charge. Use 24 hour format (HH:MM)
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'charge_end', '07:00')

          # Allow Chilled Water Tank Work on Weekends?
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'wknds', false)

          # Provide an output path for tank sizing run (if tank volume is not provided)
          OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'run_output_path', '.')

          # Provide a epw file path for tank sizing run (if tank volume is not provided). By default it uses the model's weather file
          # OpenStudio::Extension.set_measure_argument(osw, 'add_chilled_water_storage_tank', 'epw_path', feature.weather_filename)
        end

        return osw
      end
    end
  end
end
