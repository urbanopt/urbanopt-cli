#*********************************************************************************
# URBANopt, Copyright (c) 2019, Alliance for Sustainable Energy, LLC, and other 
# contributors. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice, this list 
# of conditions and the following disclaimer.
# 
# Redistributions in binary form must reproduce the above copyright notice, this 
# list of conditions and the following disclaimer in the documentation and/or other 
# materials provided with the distribution.
# 
# Neither the name of the copyright holder nor the names of its contributors may be 
# used to endorse or promote products derived from this software without specific 
# prior written permission.
# 
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
#*********************************************************************************

require 'urbanopt/scenario'

require 'json'

module URBANopt
  module Scenario
    class ResidentialBaselineMapper < SimulationMapperBase
    
      # class level variables
      @@instance_lock = Mutex.new
      @@osw = nil
      @@geometry = nil
    
      def initialize()
      
        # do initialization of class variables in thread safe way
        @@instance_lock.synchronize do
          if @@osw.nil? 
            
            # load the OSW for this class
            osw_path = File.join(File.dirname(__FILE__), 'residential_base_workflow.osw')
            File.open(osw_path, 'r') do |file|
              @@osw = JSON.parse(file.read, symbolize_names: true)
            end
        
            # add any paths local to the project
            @@osw[:measure_paths] << File.join(File.dirname(__FILE__), '../measures/')
            @@osw[:measure_paths] << File.join(File.dirname(__FILE__), '../resources/hpxml-measures')

            # configures OSW with extension gem paths for measures and files, all extension gems must be 
            # required before this
            @@osw = OpenStudio::Extension.configure_osw(@@osw)
          end
        end
      end
      
      def create_osw(scenario, features, feature_names)
        
        if features.size != 1
          raise "ResidentialBaseline currently cannot simulate more than one feature."
        end
        feature = features[0]
        feature_id = feature.id
        feature_type = feature.type 
        feature_name = feature.name
        if feature_names.size == 1
          feature_name = feature_names[0]
        end
        
        if feature_type == 'Building'
          
          building_type = feature.building_type
          num_units = 1

          case building_type
          when 'Single-Family Attached'
            num_units = 3
            begin
              num_units = feature.number_of_residential_units
            rescue
            end
          when 'Multifamily'
            num_units = 9
            begin
              num_units = feature.number_of_residential_units
            rescue
            end
          end

          unit_type = building_type

          num_floors = feature.number_of_stories
          number_of_stories_below_ground = 0
          begin
            num_floors = feature.number_of_stories_above_ground
            number_of_stories_below_ground = feature.number_of_stories - num_floors 
          rescue
          end

          if number_of_stories_below_ground > 1
            raise "ResidentialBaseline currently cannot handle multiple stories below ground."
          end

          begin
            cfa = feature.floor_area / num_units
          rescue
            cfa = feature.footprint_area * num_floors / num_units
          end

          wall_height = 8.0
          begin
            wall_height = feature.maximum_roof_height / num_floors
          rescue
          end

          foundation_type = "slab"
          if number_of_stories_below_ground > 0
            begin
              foundation_type = feature.foundation_type
            rescue
            end
          end

          roof_type = "gable"
          begin
            roof_type = feature.roof_type
          rescue
          end

          system_type = "Residential - furnace and central air conditioner"
          begin
            system_type = feature.system_type
          rescue
          end

          case system_type
          when 'Residential - no heating or cooling'
            heating_system_type = "none"
            cooling_system_type = "none"
            heat_pump_type = "none"
          when 'Residential - furnace and no cooling'
            heating_system_type = "Furnace"
            cooling_system_type = "none"
            heat_pump_type = "none"
          when 'Residential - furnace and central air conditioner'
            heating_system_type = "Furnace"
            cooling_system_type = "central air conditioner"
            heat_pump_type = "none"
          when 'Residential - furnace and room air conditioner'
            heating_system_type = "Furnace"
            cooling_system_type = "room air conditioner"
            heat_pump_type = "none"
          when 'Residential - furnace and evaporative cooler'
            heating_system_type = "Furnace"
            cooling_system_type = "evaporative cooler"
            heat_pump_type = "none"
          when 'Residential - boiler and no cooling'
            heating_system_type = "Boiler"
            cooling_system_type = "none"
            heat_pump_type = "none"
          when 'Residential - boiler and central air conditioner'
            heating_system_type = "Boiler"
            cooling_system_type = "central air conditioner"
            heat_pump_type = "none"
          when 'Residential - boiler and room air conditioner'
            heating_system_type = "Boiler"
            cooling_system_type = "room air conditioner"
            heat_pump_type = "none"
          when 'Residential - boiler and evaporative cooler'
            heating_system_type = "Boiler"
            cooling_system_type = "evaporative cooler"
            heat_pump_type = "none"
          when 'Residential - no heating and central air conditioner'
            heating_system_type = "none"
            cooling_system_type = "central air conditioner"
            heat_pump_type = "none"
          when 'Residential - no heating and room air conditioner'
            heating_system_type = "none"
            cooling_system_type = "room air conditioner"
            heat_pump_type = "none"
          when 'Residential - no heating and evaporative cooler'
            heating_system_type = "none"
            cooling_system_type = "evaporative cooler"
            heat_pump_type = "none"
          when 'Residential - air-to-air heat pump'
            heating_system_type = "none"
            cooling_system_type = "none"
            heat_pump_type = "air-to-air"
          when 'Residential - mini-split heat pump'
            heating_system_type = "none"
            cooling_system_type = "none"
            heat_pump_type = "mini-split"
          when 'Residential - ground-to-air heat pump'
            heating_system_type = "none"
            cooling_system_type = "none"
            heat_pump_type = "ground-to-air"
          end

          heating_system_fuel = "natural gas"
          begin
            heating_system_fuel = feature.heating_system_fuel_type
          rescue
          end
        end

        # deep clone of @@osw before we configure it
        osw = Marshal.load(Marshal.dump(@@osw))
        
        # now we have the feature, we can look up its properties and set arguments in the OSW
        osw[:name] = feature_name
        osw[:description] = feature_name

        # BuildResidentialURBANoptModel
        OpenStudio::Extension.set_measure_argument(osw, 'BuildResidentialURBANoptModel', 'unit_type', unit_type)
        OpenStudio::Extension.set_measure_argument(osw, 'BuildResidentialURBANoptModel', 'cfa', cfa)
        OpenStudio::Extension.set_measure_argument(osw, 'BuildResidentialURBANoptModel', 'wall_height', wall_height)
        OpenStudio::Extension.set_measure_argument(osw, 'BuildResidentialURBANoptModel', 'num_units', num_units)
        OpenStudio::Extension.set_measure_argument(osw, 'BuildResidentialURBANoptModel', 'num_floors', num_floors)
        OpenStudio::Extension.set_measure_argument(osw, 'BuildResidentialURBANoptModel', 'foundation_type', foundation_type)
        OpenStudio::Extension.set_measure_argument(osw, 'BuildResidentialURBANoptModel', 'roof_type', roof_type)
        OpenStudio::Extension.set_measure_argument(osw, 'BuildResidentialURBANoptModel', 'heating_system_type', heating_system_type)
        OpenStudio::Extension.set_measure_argument(osw, 'BuildResidentialURBANoptModel', 'heating_system_fuel', heating_system_fuel)
        OpenStudio::Extension.set_measure_argument(osw, 'BuildResidentialURBANoptModel', 'cooling_system_type', cooling_system_type)
        OpenStudio::Extension.set_measure_argument(osw, 'BuildResidentialURBANoptModel', 'heat_pump_type', heat_pump_type)

        # SimulationOutputReport
        OpenStudio::Extension.set_measure_argument(osw, 'SimulationOutputReport', 'timeseries_frequency', "hourly")
        OpenStudio::Extension.set_measure_argument(osw, 'SimulationOutputReport', 'include_timeseries_zone_temperatures', false)
        OpenStudio::Extension.set_measure_argument(osw, 'SimulationOutputReport', 'include_timeseries_fuel_consumptions', false)
        OpenStudio::Extension.set_measure_argument(osw, 'SimulationOutputReport', 'include_timeseries_end_use_consumptions', false)
        OpenStudio::Extension.set_measure_argument(osw, 'SimulationOutputReport', 'include_timeseries_total_loads', false)
        OpenStudio::Extension.set_measure_argument(osw, 'SimulationOutputReport', 'include_timeseries_component_loads', false)

        # default_feature_reports
        OpenStudio::Extension.set_measure_argument(osw, 'default_feature_reports', 'feature_id', feature_id)
        OpenStudio::Extension.set_measure_argument(osw, 'default_feature_reports', 'feature_name', feature_name)
        OpenStudio::Extension.set_measure_argument(osw, 'default_feature_reports', 'feature_type', feature_type)

        return osw
      end
      
    end
  end
end