# *********************************************************************************
# URBANopt (tm), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://github.com/urbanopt/urbanopt-example-geojson-project/blob/develop/LICENSE.md
# *********************************************************************************

require 'urbanopt/reporting'
require 'openstudio/common_measures'
require 'openstudio/model_articulation'
require 'openstudio/load_flexibility_measures'

require_relative 'HighEfficiency'

require 'json'

module URBANopt
  module Scenario
    class ThermalStorageMapper < HighEfficiencyMapper
      def create_osw(scenario, features, feature_names)
        osw = super(scenario, features, feature_names)

        # Add ice to applicable TES object building and set applicable charge and discharge times

        if feature_names[0].to_s == 'Mixed_use 1'
          OpenStudio::Extension.set_measure_argument(osw,
                                                     'add_central_ice_storage', '__SKIP__', false)
          OpenStudio::Extension.set_measure_argument(osw, 'add_central_ice_storage', 'storage_capacity', 6000)
        end

        if feature_names[0].to_s == 'Restaurant 1'
          OpenStudio::Extension.set_measure_argument(osw,
                                                     'add_packaged_ice_storage', '__SKIP__', false)
        end

        if feature_names[0].to_s == 'Restaurant 10'
          OpenStudio::Extension.set_measure_argument(osw,
                                                     'add_packaged_ice_storage', '__SKIP__', false)
        end

        if feature_names[0].to_s == 'Restaurant 12'
          OpenStudio::Extension.set_measure_argument(osw,
                                                     'add_packaged_ice_storage', '__SKIP__', false)
        end

        if feature_names[0].to_s == 'Restaurant 14'
          OpenStudio::Extension.set_measure_argument(osw,
                                                     'add_packaged_ice_storage', '__SKIP__', false)
        end

        if feature_names[0].to_s == 'Restaurant 15'
          OpenStudio::Extension.set_measure_argument(osw,
                                                     'add_packaged_ice_storage', '__SKIP__', false)
        end

        if feature_names[0].to_s == 'Office 1'
          OpenStudio::Extension.set_measure_argument(osw,
                                                     'add_central_ice_storage', '__SKIP__', false)
          OpenStudio::Extension.set_measure_argument(osw, 'add_central_ice_storage', 'storage_capacity', 1200)
        end

        if feature_names[0].to_s == 'Hospital 1'
          OpenStudio::Extension.set_measure_argument(osw,
                                                     'add_central_ice_storage', '__SKIP__', false)
          OpenStudio::Extension.set_measure_argument(osw, 'add_central_ice_storage', 'storage_capacity', 3000)
        end

        if feature_names[0].to_s == 'Hospital 2'
          OpenStudio::Extension.set_measure_argument(osw,
                                                     'add_central_ice_storage', '__SKIP__', false)
          OpenStudio::Extension.set_measure_argument(osw, 'add_central_ice_storage', 'storage_capacity', 900)
        end

        if feature_names[0].to_s == 'Mixed use 2'
          OpenStudio::Extension.set_measure_argument(osw,
                                                     'add_central_ice_storage', '__SKIP__', false)
          OpenStudio::Extension.set_measure_argument(osw, 'add_central_ice_storage', 'storage_capacity', 7000)
        end

        if feature_names[0].to_s == 'Restaurant 13'
          OpenStudio::Extension.set_measure_argument(osw,
                                                     'add_packaged_ice_storage', '__SKIP__', false)
        end

        if feature_names[0].to_s == 'Mall 1'
          OpenStudio::Extension.set_measure_argument(osw,
                                                     'add_central_ice_storage', '__SKIP__', false)
          OpenStudio::Extension.set_measure_argument(osw, 'add_central_ice_storage', 'storage_capacity', 1500)
        end

        if feature_names[0].to_s == 'Hotel 1'
          # PTAC coils must be explicitly excluded
          ptac_coils = ['BUILDING STORY 10 THERMALZONE PTAC 1SPD DX AC CLG COIL 458KBTU/HR 9.5EER',
                        'BUILDING STORY 4 THERMALZONE PTAC 1SPD DX AC CLG COIL 369KBTU/HR 9.5EER',
                        'BUILDING STORY 5 THERMALZONE PTAC 1SPD DX AC CLG COIL 370KBTU/HR 9.5EER',
                        'BUILDING STORY 6 THERMALZONE PTAC 1SPD DX AC CLG COIL 370KBTU/HR 9.5EER',
                        'BUILDING STORY 7 THERMALZONE PTAC 1SPD DX AC CLG COIL 370KBTU/HR 9.5EER',
                        'BUILDING STORY 8 THERMALZONE PTAC 1SPD DX AC CLG COIL 370KBTU/HR 9.5EER',
                        'BUILDING STORY 9 THERMALZONE PTAC 1SPD DX AC CLG COIL 371KBTU/HR 9.5EER']

          ptac_coils.each do |ptac|
            OpenStudio::Extension.set_measure_argument(osw, 'add_packaged_ice_storage', ptac, false)
          end
        end

        return osw
      end
    end
  end
end
