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
require 'openstudio/common_measures'
require 'openstudio/model_articulation'

require 'json'

module URBANopt
  module Scenario
    class BaselineMapper < SimulationMapperBase
    
      # class level variables
      @@instance_lock = Mutex.new
      @@osw = nil
      @@geometry = nil
    
      def initialize()
      
        # do initialization of class variables in thread safe way
        @@instance_lock.synchronize do
          if @@osw.nil? 
            
            # load the OSW for this class
            osw_path = File.join(File.dirname(__FILE__), 'base_workflow.osw')
            File.open(osw_path, 'r') do |file|
              @@osw = JSON.parse(file.read, symbolize_names: true)
            end
        
            # add any paths local to the project
            @@osw[:file_paths] << File.join(File.dirname(__FILE__), '../weather/')
            
            # configures OSW with extension gem paths for measures and files, all extension gems must be 
            # required before this
            @@osw = OpenStudio::Extension.configure_osw(@@osw)
          end
        end
      end
      
      def create_osw(scenario, features, feature_names)
        
        if features.size != 1
          raise "TestMapper1 currently cannot simulate more than one feature"
        end
        feature = features[0]
        feature_id = feature.id
        feature_type = feature.type 
        feature_name = feature.name
        if feature_names.size == 1
          feature_name = feature_names[0]
        end
        
        if feature_type == 'Building'
          
          building_type_1 = feature.building_type

          case building_type_1
          when 'Multifamily (5 or more units)'
            building_type_1 = 'MidriseApartment'
          when 'Multifamily (2 to 4 units)'
            building_type_1 = 'MidriseApartment'
          when 'Single-Family'
            building_type_1 = 'MidriseApartment'
          when 'Office'
            building_type_1 = 'MediumOffice'
          when 'Outpatient health care'
            building_type_1 = 'Outpatient'
          when 'Inpatient health care'
            building_type_1 = 'Hospital'
          when 'Lodging'
            building_type_1 = 'LargeHotel'
          when 'Food service'
            building_type_1 = 'FullServiceRestaurant'
          when 'Strip shopping mall'
            building_type_1 = 'RetailStripmall'
          when 'Retail other than mall'
            building_type_1 = 'RetailStandalone' 
          when 'Education'
            building_type_1 = 'SecondarySchool'
          when 'Nursing'
            building_type_1 = 'MidriseApartment'  
          when 'Mixed use'
            mixed_type_1 = feature.mixed_type_1
            
            mixed_type_2 = feature.mixed_type_2
            mixed_type_2_percentage = feature.mixed_type_2_percentage
            mixed_type_2_fract_bldg_area = mixed_type_2_percentage*0.01
                       
            mixed_type_3 = feature.mixed_type_3
            mixed_type_3_percentage = feature.mixed_type_3_percentage
            mixed_type_3_fract_bldg_area = mixed_type_3_percentage*0.01

            mixed_type_4 = feature.mixed_type_4
            mixed_type_4_percentage = feature.mixed_type_4_percentage
            mixed_type_4_fract_bldg_area = mixed_type_4_percentage*0.01

            mixed_use_types = []
            mixed_use_types << mixed_type_1
            mixed_use_types << mixed_type_2
            mixed_use_types << mixed_type_3
            mixed_use_types << mixed_type_4

            openstudio_mixed_use_types = []

            mixed_use_types.each do |mixed_use_type|

              case mixed_use_type
              when 'Multifamily (5 or more units)'
                mixed_use_type = 'MidriseApartment'
              when 'Multifamily (2 to 4 units)'
                mixed_use_type = 'MidriseApartment'
              when 'Single-Family'
                mixed_use_type = 'MidriseApartment'
              when 'Office'
                mixed_use_type = 'MediumOffice'
              when 'Outpatient health care'
                mixed_use_type = 'Outpatient'
              when 'Inpatient health care'
                mixed_use_type = 'Hospital'
              when 'Lodging'
                mixed_use_type = 'LargeHotel'
              when 'Food service'
                mixed_use_type = 'FullServiceRestaurant'
              when 'Strip shopping mall'
                mixed_use_type = 'RetailStripmall'
              when 'Retail other than mall'
                mixed_use_type = 'RetailStandalone' 
              when 'Education'
                mixed_use_type = 'SecondarySchool'
              when 'Nursing'
                mixed_use_type = 'MidriseApartment' 
              end

              openstudio_mixed_use_types << mixed_use_type
            end

            openstudio_mixed_type_1 = openstudio_mixed_use_types[0]  
            openstudio_mixed_type_2 = openstudio_mixed_use_types[1]
            openstudio_mixed_type_3 = openstudio_mixed_use_types[2]
            openstudio_mixed_type_4 = openstudio_mixed_use_types[3]

          end

          footprint_area = feature.footprint_area
          floor_height = 10
          number_of_stories = feature.number_of_stories 
          
          # default values
          number_of_stories_above_ground = number_of_stories
          number_of_stories_below_ground = 0
          begin
            number_of_stories_above_ground = feature.number_of_stories_above_ground
            number_of_stories_below_ground = number_of_stories - number_of_stories_above_ground 
          rescue
          end
         #template = feature.template
        end

        # default value for system_type
        system_type = "Inferred"
        begin
          system_type = feature.system_type
        rescue
        end

        # deep clone of @@osw before we configure it
        osw = Marshal.load(Marshal.dump(@@osw))
        
        # now we have the feature, we can look up its properties and set arguments in the OSW
        osw[:name] = feature_name
        osw[:description] = feature_name
        
        # create a bar building, will have spaces tagged with individual space types given the input building types
        OpenStudio::Extension.set_measure_argument(osw, 'create_bar_from_building_type_ratios', 'single_floor_area', footprint_area)
        OpenStudio::Extension.set_measure_argument(osw, 'create_bar_from_building_type_ratios', 'floor_height', floor_height)
        OpenStudio::Extension.set_measure_argument(osw, 'create_bar_from_building_type_ratios', 'num_stories_above_grade', number_of_stories_above_ground)
        OpenStudio::Extension.set_measure_argument(osw, 'create_bar_from_building_type_ratios', 'num_stories_below_grade', number_of_stories_below_ground)

        OpenStudio::Extension.set_measure_argument(osw, 'create_bar_from_building_type_ratios', 'bldg_type_a', building_type_1)
        
        if building_type_1 == 'Mixed use'

          OpenStudio::Extension.set_measure_argument(osw, 'create_bar_from_building_type_ratios', 'bldg_type_a', openstudio_mixed_type_1)
          
          OpenStudio::Extension.set_measure_argument(osw, 'create_bar_from_building_type_ratios', 'bldg_type_b', openstudio_mixed_type_2)
          
          OpenStudio::Extension.set_measure_argument(osw, 'create_bar_from_building_type_ratios', 'bldg_type_b_fract_bldg_area', mixed_type_2_fract_bldg_area)
                    
          OpenStudio::Extension.set_measure_argument(osw, 'create_bar_from_building_type_ratios', 'bldg_type_c', openstudio_mixed_type_3)
          
          OpenStudio::Extension.set_measure_argument(osw, 'create_bar_from_building_type_ratios', 'bldg_type_c_fract_bldg_area', mixed_type_3_fract_bldg_area)
          
          OpenStudio::Extension.set_measure_argument(osw, 'create_bar_from_building_type_ratios', 'bldg_type_d', openstudio_mixed_type_4)
          
          OpenStudio::Extension.set_measure_argument(osw, 'create_bar_from_building_type_ratios', 'bldg_type_d_fract_bldg_area', mixed_type_4_fract_bldg_area)      
        
        end
        
        # calling create typical building the first time will create space types
        OpenStudio::Extension.set_measure_argument(osw, 'create_typical_building_from_model', 'add_hvac', false, 'create_typical_building_from_model 1')
        
        # create a blended space type for each story
        OpenStudio::Extension.set_measure_argument(osw, 
        'blended_space_type_from_model', 'blend_method', 'Building Story')
        
        # create geometry for the desired feature, this will reuse blended space types in the model for each story and remove the bar geometry
        OpenStudio::Extension.set_measure_argument(osw, 'urban_geometry_creation', 'geojson_file', scenario.feature_file.path)
        OpenStudio::Extension.set_measure_argument(osw, 'urban_geometry_creation', 'feature_id', feature_id)
        OpenStudio::Extension.set_measure_argument(osw, 'urban_geometry_creation', 'surrounding_buildings', 'ShadingOnly')
        
        if building_type_1 == 'MidriseApartment'
          OpenStudio::Extension.set_measure_argument(osw, 'IncreaseInsulationRValueForExteriorWalls', '__SKIP__', true)
          OpenStudio::Extension.set_measure_argument(osw, 'IncreaseInsulationRValueForExteriorWalls', 'r_value', 10)
        end
        
        # call create typical building a second time, do not touch space types, only add hvac
        OpenStudio::Extension.set_measure_argument(osw, 'create_typical_building_from_model', 'system_type', system_type, 'create_typical_building_from_model 2')
        
        # call the default feature reporting measure
        OpenStudio::Extension.set_measure_argument(osw, 'default_feature_reports', 'feature_id', feature_id)
        OpenStudio::Extension.set_measure_argument(osw, 'default_feature_reports', 'feature_name', feature_name)
        OpenStudio::Extension.set_measure_argument(osw, 'default_feature_reports', 'feature_type', feature_type)

        return osw
      end
      
    end
  end
end