# *********************************************************************************
# URBANopt (tm), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://github.com/urbanopt/urbanopt-cli/blob/develop/LICENSE.md
# *********************************************************************************

# frozen_string_literal: true

require_relative '../../../resources/hpxml-measures/HPXMLtoOpenStudio/resources/minitest_helper'
require_relative '../../../mappers/residential/util'
require_relative '../../../mappers/residential/template//util'
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require_relative '../measure'
require 'csv'

class BuildResidentialModelTest < Minitest::Test
  def setup
    @tests_path = File.dirname(__FILE__)
    @run_path = File.join(@tests_path, 'run')
    @hpxml_path = File.join(@run_path, 'feature.xml')
    FileUtils.mkdir_p(@run_path)

    @args = {}
    _initialize_arguments
  end

  def teardown
    FileUtils.rm_rf(@run_path)
  end

  def _initialize_arguments
    # BuildResidentialModel arguments
    @args[:hpxml_path] = @hpxml_path
    @args[:output_dir] = @run_path
    @args[:feature_id] = 1
    @args[:schedules_type] = 'stochastic'
    @args[:schedules_random_seed] = 1
    @args[:schedules_variation] = 'unit'
    @args[:geometry_num_floors_above_grade] = 1

    # Optionals / Feature
    @args[:geometry_building_num_units] = 1
    @timestep = 60
    @run_period = 'Jan 1 - Dec 31'
    @calendar_year = 2007
    @weather_filename = 'USA_NY_Buffalo-Greater.Buffalo.Intl.AP.725280_TMY3.epw'
    @building_type = 'Single-Family Detached'
    @floor_area = 3055
    @number_of_bedrooms = 3
    @geometry_unit_orientation = nil
    @geometry_aspect_ratio = nil
    @occupancy_calculation_type = nil
    @number_of_occupants = nil
    @maximum_roof_height = 8.0
    @foundation_type = 'crawlspace - unvented'
    @attic_type = 'attic - vented'
    @roof_type = 'Gable'
    @onsite_parking_fraction = false
    @system_type = 'Residential - furnace and central air conditioner'
    @heating_system_fuel_type = 'natural gas'
    @template = nil
    @climate_zone = '5A'
  end

  def test_hpxml_dir
    # in https://github.com/urbanopt/urbanopt-geojson-gem/blob/develop/lib/urbanopt/geojson/schema/building_properties.json, see:
    # - "hpxml_directory"

    @args[:hpxml_dir] = '18'
    _test_measure(expected_errors: ["HPXML directory 'xml_building/18' was specified for feature ID = 1, but could not be found."])

    @args[:hpxml_dir] = '../measures/BuildResidentialModel/tests/xml_building/17'
    _test_measure(expected_errors: ["HPXML directory 'xml_building/17' must contain exactly 1 HPXML file; the single file can describe multiple dwelling units of a feature."])

    @args[:hpxml_dir] = '17'
    _test_measure(expected_errors: ['The number of actual dwelling units (4) differs from the specified number of units (1).'])

    @args[:geometry_building_num_units] = 4

    _test_measure
  end

  def test_schedules_type
    # Baseline.rb mapper currently hardcodes schedules_type to "stochastic"

    schedules_types = ['stochastic', 'smooth']

    schedules_types.each do |schedules_type|
      @args[:schedules_type] = schedules_type

      _apply_residential
      _test_measure
    end
  end

  def test_feature_building_types_num_units_and_stories
    # in https://github.com/urbanopt/urbanopt-geojson-gem/blob/develop/lib/urbanopt/geojson/schema/building_properties.json, see:
    # - "buildingType"
    # - "number_of_residential_units"
    # - "number_of_stories_above_ground"

    feature_building_types = ['Single-Family Detached', 'Single-Family Attached', 'Multifamily']
    feature_number_of_residential_unitss = (1..3).to_a
    feature_number_of_stories_above_grounds = (1..2).to_a

    feature_building_types.each do |feature_building_type|
      feature_number_of_residential_unitss.each do |feature_number_of_residential_units|
        feature_number_of_stories_above_grounds.each do |feature_number_of_stories_above_ground|
          @building_type = feature_building_type
          @args[:geometry_num_floors_above_grade] = feature_number_of_stories_above_ground
          @args[:geometry_building_num_units] = feature_number_of_residential_units

          expected_errors = []
          if feature_building_type == 'Multifamily'
            num_units_per_floor = (Float(@args[:geometry_building_num_units]) / Float(@args[:geometry_num_floors_above_grade])).ceil
            if num_units_per_floor == 1
              expected_errors = ["Unit type 'apartment unit' with num_units_per_floor=#{num_units_per_floor} is not supported."]
            end
          end

          _apply_residential
          _test_measure(expected_errors: expected_errors)
        end
      end
    end
  end

  def test_feature_building_foundation_and_attic_types_and_num_stories
    # in https://github.com/urbanopt/urbanopt-geojson-gem/blob/develop/lib/urbanopt/geojson/schema/building_properties.json, see:
    # - "buildingType"
    # - "foundationType"
    # - "atticType"
    # - "number_of_stories_above_ground"

    feature_building_types = ['Single-Family Detached', 'Single-Family Attached', 'Multifamily']
    feature_foundation_types = ['slab', 'crawlspace - vented', 'crawlspace - conditioned', 'basement - unconditioned',	'basement - conditioned', 'ambient']
    feature_attic_types = ['attic - vented', 'attic - conditioned', 'flat roof']
    feature_number_of_stories_above_grounds = (1..2).to_a

    feature_building_types.each do |feature_building_type|
      feature_foundation_types.each do |feature_foundation_type|
        feature_attic_types.each do |feature_attic_type|
          feature_number_of_stories_above_grounds.each do |feature_number_of_stories_above_ground|
            @building_type = feature_building_type
            @foundation_type = feature_foundation_type
            @attic_type = feature_attic_type
            @args[:geometry_num_floors_above_grade] = feature_number_of_stories_above_ground

            expected_errors = []
            if feature_attic_type == 'attic - conditioned' && feature_number_of_stories_above_ground == 1
              expected_errors = ['Units with a conditioned attic must have at least two above-grade floors.']
            end
            if feature_building_type == 'Multifamily'
              num_units_per_floor = (Float(@args[:geometry_building_num_units]) / Float(@args[:geometry_num_floors_above_grade])).ceil
              if num_units_per_floor == 1
                expected_errors = ["Unit type 'apartment unit' with num_units_per_floor=#{num_units_per_floor} is not supported."]
              end
            end

            _apply_residential
            _test_measure(expected_errors: expected_errors)
          end
        end
      end
    end
  end

  def test_feature_building_types_num_units_and_bedrooms
    # in https://github.com/urbanopt/urbanopt-geojson-gem/blob/develop/lib/urbanopt/geojson/schema/building_properties.json, see:
    # - "buildingType"
    # - "number_of_residential_units"
    # - "number_of_bedrooms"

    feature_building_types = ['Single-Family Detached', 'Multifamily']
    feature_number_of_residential_unitss = (2..4).to_a
    feature_number_of_bedroomss = (11..13).to_a

    feature_building_types.each do |feature_building_type|
      feature_number_of_residential_unitss.each do |feature_number_of_residential_units|
        feature_number_of_bedroomss.each do |feature_number_of_bedrooms|
          @building_type = feature_building_type
          @args[:geometry_building_num_units] = feature_number_of_residential_units
          @number_of_bedrooms = feature_number_of_bedrooms

          _apply_residential
          _test_measure
        end
      end
    end
  end

  def test_feature_building_occ_calc_types_num_occupants_and_units
    # in https://github.com/urbanopt/urbanopt-geojson-gem/blob/develop/lib/urbanopt/geojson/schema/building_properties.json, see:
    # - "buildingType"
    # - "occupancy_calculation_type"
    # - "number_of_residential_units"
    # - "number_of_occupants"

    feature_building_types = ['Single-Family Detached', 'Multifamily']
    feature_occupancy_calculation_types = ['asset', 'operational']
    feature_number_of_residential_unitss = (2..3).to_a
    feature_number_of_occupantss = [nil, 3]

    feature_building_types.each do |feature_building_type|
      feature_occupancy_calculation_types.each do |feature_occupancy_calculation_type|
        feature_number_of_residential_unitss.each do |feature_number_of_residential_units|
          feature_number_of_occupantss.each do |feature_number_of_occupants|
            @building_type = feature_building_type
            @occupancy_calculation_type = feature_occupancy_calculation_type
            @args[:geometry_building_num_units] = feature_number_of_residential_units
            @number_of_occupants = feature_number_of_occupants

            _apply_residential
            _test_measure
          end
        end
      end
    end
  end

  def test_feature_building_foundation_types_and_garages
    # in https://github.com/urbanopt/urbanopt-geojson-gem/blob/develop/lib/urbanopt/geojson/schema/building_properties.json, see:
    # - "buildingType"
    # - "foundationType"
    # - "onsite_parking_fraction"

    feature_building_types = ['Single-Family Detached', 'Single-Family Attached', 'Multifamily']
    feature_foundation_types = ['slab', 'crawlspace - vented', 'crawlspace - conditioned', 'basement - unconditioned',	'basement - conditioned', 'ambient']
    feature_onsite_parking_fractions = [false, true]

    feature_building_types.each do |feature_building_type|
      feature_foundation_types.each do |feature_foundation_type|
        feature_onsite_parking_fractions.each do |feature_onsite_parking_fraction|
          @building_type = feature_building_type
          @foundation_type = feature_foundation_type
          @onsite_parking_fraction = feature_onsite_parking_fraction
          @args[:geometry_building_num_units] = 2

          expected_errors = []
          if feature_foundation_type == 'ambient' && feature_onsite_parking_fraction
            expected_errors = ['Cannot handle garages with an ambient foundation type.']
          end
          if feature_building_type == 'Multifamily' && feature_foundation_type.include?('- conditioned')
            expected_errors = ['Conditioned basement/crawlspace foundation type for apartment units is not currently supported.']
          end

          _apply_residential
          _test_measure(expected_errors: expected_errors)
        end
      end
    end
  end

  def test_hvac_system_and_fuel_types
    # in https://github.com/urbanopt/urbanopt-geojson-gem/blob/develop/lib/urbanopt/geojson/schema/building_properties.json, see:
    # - "systemType" (those prefixed with "Residential")
    # - "heatingSystemFuelType"

    feature_system_types = ['Residential - electric resistance and no cooling', 'Residential - electric resistance and central air conditioner',	'Residential - electric resistance and room air conditioner', 'Residential - electric resistance and evaporative cooler', 'Residential - furnace and no cooling', 'Residential - furnace and central air conditioner', 'Residential - furnace and room air conditioner', 'Residential - furnace and evaporative cooler', 'Residential - boiler and no cooling', 'Residential - boiler and central air conditioner', 'Residential - boiler and room air conditioner', 'Residential - boiler and evaporative cooler', 'Residential - air-to-air heat pump', 'Residential - mini-split heat pump', 'Residential - ground-to-air heat pump']
    feature_heating_system_fuel_types = ['electricity', 'natural gas', 'fuel oil', 'propane', 'wood']

    feature_system_types.each do |feature_system_type|
      feature_heating_system_fuel_types.each do |feature_heating_system_fuel_type|
        @system_type = feature_system_type
        @heating_system_fuel_type = feature_heating_system_fuel_type

        _apply_residential
        _test_measure
      end
    end
  end

  def test_residential_template_types
    # in https://github.com/urbanopt/urbanopt-geojson-gem/blob/develop/lib/urbanopt/geojson/schema/building_properties.json, see:
    # - "templateType"

    feature_templates = ['Residential IECC 2006 - Customizable Template Sep 2020', 'Residential IECC 2009 - Customizable Template Sep 2020', 'Residential IECC 2012 - Customizable Template Sep 2020', 'Residential IECC 2015 - Customizable Template Sep 2020', 'Residential IECC 2018 - Customizable Template Sep 2020', 'Residential IECC 2006 - Customizable Template Apr 2022', 'Residential IECC 2009 - Customizable Template Apr 2022', 'Residential IECC 2012 - Customizable Template Apr 2022', 'Residential IECC 2015 - Customizable Template Apr 2022', 'Residential IECC 2018 - Customizable Template Apr 2022']

    feature_templates.each do |feature_template|
      @args = {}
      _initialize_arguments

      @template = feature_template

      _apply_residential
      _apply_residential_template
      _test_measure
    end
  end

  def _apply_residential
    residential_simulation(@args, @timestep, @run_period, @calendar_year, @weather_filename)
    residential_geometry_unit(@args, @building_type, @floor_area, @number_of_bedrooms, @geometry_unit_orientation, @geometry_unit_aspect_ratio, @occupancy_calculation_type, @number_of_occupants, @maximum_roof_height)
    residential_geometry_foundation(@args, @foundation_type)
    residential_geometry_attic(@args, @attic_type, @roof_type)
    residential_geometry_garage(@args, @onsite_parking_fraction)
    residential_geometry_neighbor(@args)
    residential_hvac(@args, @system_type, @heating_system_fuel_type)
    residential_appliances(@args)
  end

  def _apply_residential_template
    residential_template(@args, @template, @climate_zone)
  end

  def _test_measure(expected_errors: [])
    # create an instance of the measure
    measure = BuildResidentialModel.new

    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)
    model = OpenStudio::Model::Model.new

    # get arguments
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if @args.key?(arg.name.to_sym)
        assert(temp_arg_var.setValue(@args[arg.name.to_sym]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # run the measure
    measure.run(model, runner, argument_map)
    result = runner.result

    # assert that it ran correctly
    if !expected_errors.empty?
      # show_output(result) unless result.value.valueName == 'Fail'
      assert_equal('Fail', result.value.valueName)

      error_msgs = result.errors.map(&:logMessage)
      expected_errors.each do |expected_error|
        assert_includes(error_msgs, expected_error)
      end
    else
      show_output(result) unless result.value.valueName == 'Success'
      assert_equal('Success', result.value.valueName)
    end
  end
end
