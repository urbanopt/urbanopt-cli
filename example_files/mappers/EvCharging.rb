# *********************************************************************************
# URBANopt (tm), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://github.com/urbanopt/urbanopt-example-geojson-project/blob/develop/LICENSE.md
# *********************************************************************************

require 'urbanopt/reporting'
require 'openstudio/common_measures'
require 'openstudio/model_articulation'

require_relative 'HighEfficiency'

require 'json'

module URBANopt
  module Scenario
    class EvChargingMapper < HighEfficiencyMapper
      def create_osw(scenario, features, feature_names)
        osw = super(scenario, features, feature_names)

        feature = features[0]

        def ev_charging_type(building_type)
          typical_home = ['Single-Family', 'Multifamily (2 to 4 units)', 'Multifamily (5 or more units)', 'Lodging']
          typical_public = ['Public assembly', 'Strip shopping mall', 'Enclosed mall', 'Retail other than mall', 'Food service', 'Nonrefrigerated warehouse', 'Food sales', 'Refrigerated warehouse', 'Religious worship', 'Service', 'Public order and safety', 'Uncovered Parking', 'Covered Parking']
          typical_work = ['Office', 'Laboratory', 'Education', 'Inpatient health care', 'Outpatient health care', 'Nursing']

          if typical_home.include? building_type
            return 'Typical Home'
          elsif typical_public.include? building_type
            return 'Typical Public'
          elsif typical_work.include? building_type
            return 'Typical Work'
          end
        end

        # add EV loads
        ev_charging = nil

        begin
          ev_charging = feature.ev_charging
        rescue StandardError
        end

        if ev_charging != true
          puts 'Please set ev_charging to true to add EV loads.'
        elsif ev_charging == true
          OpenStudio::Extension.set_measure_argument(osw, 'add_ev_load', '__SKIP__', false)
          begin
            ev_charging_station_type = feature.ev_charging_station_type
          rescue StandardError
          end
          if !ev_charging_station_type.nil? && !ev_charging_station_type.empty?
            OpenStudio::Extension.set_measure_argument(osw, 'add_ev_load', 'chg_station_type', ev_charging_station_type)
          else
            building_type = feature.building_type
            # For mixed use building ev_charging_station_type must be specified
            if building_type == 'Mixed use'
              puts 'Specify the ev_charging_station_type for the Feature, add_ev_load measure not applied.'
            else
              ev_charging_station_type = ev_charging_type(building_type)
              OpenStudio::Extension.set_measure_argument(osw, 'add_ev_load', 'chg_station_type', ev_charging_station_type)
            end
          end

          begin
            if ev_charging_station_type == 'Typical Work'
              delay_type = feature.delay_type
              OpenStudio::Extension.set_measure_argument(osw, 'add_ev_load', 'delay_type', delay_type)
            end
          rescue StandardError
          end

          begin
            ev_charging_behavior = feature.ev_charging_behavior
            if !ev_charging_behavior.nil? && !ev_charging_behavior.empty?
              OpenStudio::Extension.set_measure_argument(osw, 'add_ev_load', 'charge_behavior', ev_charging_behavior)
            end
          rescue StandardError
          end

          begin
            ev_percent = feature.ev_percent
            if !ev_percent.nil? && !ev_percent.empty?
              OpenStudio::Extension.set_measure_argument(osw, 'add_ev_load', 'ev_percent', ev_percent)
            end
          rescue StandardError
          end

          begin
            ev_use_model_occupancy = feature.ev_use_model_occupancy
            if !ev_use_model_occupancy.nil?
              OpenStudio::Extension.set_measure_argument(osw, 'add_ev_load', 'ev_use_model_occupancy', ev_use_model_occupancy)
            end
          rescue StandardError
          end

          # Add EMS Control to EV charging only if ev_charging is true
          begin
            ev_curtailment_frac = feature.ev_curtailment_frac
          rescue StandardError
          end

          if !ev_curtailment_frac.nil?
            OpenStudio::Extension.set_measure_argument(osw, 'add_ems_to_control_ev_charging', '__SKIP__', false)
            OpenStudio::Extension.set_measure_argument(osw, 'add_ems_to_control_ev_charging', 'curtailment_frac', ev_curtailment_frac)
          end

        end

        return osw
      end
    end
  end
end
