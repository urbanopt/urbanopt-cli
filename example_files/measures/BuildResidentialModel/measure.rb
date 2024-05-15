# *********************************************************************************
# URBANopt (tm), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://github.com/urbanopt/urbanopt-cli/blob/develop/LICENSE.md
# *********************************************************************************

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/measures/measure_writing_guide/

require 'openstudio'
resources_path = File.absolute_path(File.join(File.dirname(__FILE__), '../../resources/hpxml-measures/HPXMLtoOpenStudio/resources'))
require File.join(resources_path, 'meta_measure')

# start the measure
class BuildResidentialModel < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    return 'Build Residential Model'
  end

  # human readable description
  def description
    return 'Builds the OpenStudio Model for an existing residential building.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Builds the residential OpenStudio Model using the geojson feature file, which contains the specified parameters for each existing building.'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    arg = OpenStudio::Ruleset::OSArgument.makeIntegerArgument('feature_id', true)
    arg.setDisplayName('Feature ID')
    arg.setDescription('The feature ID passed from Baseline.rb.')
    args << arg

    schedules_type_choices = OpenStudio::StringVector.new
    schedules_type_choices << 'smooth'
    schedules_type_choices << 'stochastic'

    arg = OpenStudio::Measure::OSArgument.makeChoiceArgument('schedules_type', schedules_type_choices, true)
    arg.setDisplayName('Schedules: Type')
    arg.setDescription('The type of occupant-related schedules to use.')
    arg.setDefaultValue('smooth')
    args << arg

    arg = OpenStudio::Measure::OSArgument.makeIntegerArgument('schedules_random_seed', true)
    arg.setDisplayName('Schedules: Random Seed')
    arg.setUnits('#')
    arg.setDescription("This numeric field is the seed for the random number generator. Only applies if the schedules type is 'stochastic'.")
    args << arg

    schedules_variation_choices = OpenStudio::StringVector.new
    schedules_variation_choices << 'unit'
    schedules_variation_choices << 'building'

    arg = OpenStudio::Ruleset::OSArgument.makeChoiceArgument('schedules_variation', schedules_variation_choices, true)
    arg.setDisplayName('Schedules: Variation')
    arg.setDescription('How the schedules vary.')
    args << arg

    arg = OpenStudio::Measure::OSArgument.makeIntegerArgument('geometry_num_floors_above_grade', true)
    arg.setDisplayName('Geometry: Number of Floors Above Grade')
    arg.setUnits('#')
    arg.setDescription('The number of floors above grade.')
    args << arg

    arg = OpenStudio::Measure::OSArgument.makeStringArgument('hpxml_dir', false)
    arg.setDisplayName('Folder Containing Custom HPXML File')
    arg.setDescription('The name of the folder containing a custom HPXML file, relative to the xml_building folder.')
    args << arg

    arg = OpenStudio::Measure::OSArgument.makeStringArgument('output_dir', true)
    arg.setDisplayName('Directory for Output Files')
    arg.setDescription('Absolute/relative path for the output files directory.')
    args << arg

    measures_dir = File.absolute_path(File.join(File.dirname(__FILE__), '../../resources/hpxml-measures'))
    measure_subdir = 'BuildResidentialHPXML'
    full_measure_path = File.join(measures_dir, measure_subdir, 'measure.rb')
    measure = get_measure_instance(full_measure_path)

    measure.arguments(model).each do |arg|
      args << arg
    end

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign the user inputs to variables
    args = get_argument_values(runner, arguments(model), user_arguments)

    # optionals: get or remove
    args.each_key do |arg|
      if args[arg].is_initialized
        args[arg] = args[arg].get
      else
        args.delete(arg)
      end
    rescue StandardError # this is needed for when args[arg] is actually a value
    end

    # get hpxml-measures directory
    resources_dir = File.absolute_path(File.join(File.dirname(__FILE__), '../../resources'))
    measures_dir = File.join(resources_dir, 'hpxml-measures')
    check_dir_exists(measures_dir, runner)

    # either create units or get pre-made units
    if args[:hpxml_dir].nil?
      units = get_unit_positions(runner, args)
      if units.empty?
        return false
      end

      standards_number_of_living_units = units.size
    else
      xml_building_folder = 'xml_building'
      hpxml_dir = File.join(File.dirname(__FILE__), "../../#{xml_building_folder}/#{args[:hpxml_dir]}")

      if !File.exist?(hpxml_dir)
        runner.registerError("HPXML directory '#{File.join(xml_building_folder, File.basename(hpxml_dir))}' was specified for feature ID = #{args[:feature_id]}, but could not be found.")
        return false
      end

      units = []
      hpxml_paths = Dir["#{hpxml_dir}/*.xml"]
      if hpxml_paths.size != 1
        runner.registerError("HPXML directory '#{File.join(xml_building_folder, File.basename(hpxml_dir))}' must contain exactly 1 HPXML file; the single file can describe multiple dwelling units of a feature.")
        return false
      end
      hpxml_path = hpxml_paths[0]
      units << { 'hpxml_path' => hpxml_path }

      hpxml = HPXML.new(hpxml_path: hpxml_path, building_id: 'ALL')
      standards_number_of_living_units = 0
      hpxml.buildings.each do |hpxml_bldg|
        number_of_units = 1
        number_of_units = hpxml_bldg.building_construction.number_of_units if !hpxml_bldg.building_construction.number_of_units.nil?
        standards_number_of_living_units += number_of_units
      end
    end

    if args.key?(:geometry_building_num_units) && (standards_number_of_living_units != Integer(args[:geometry_building_num_units]))
      runner.registerError("The number of actual dwelling units (#{standards_number_of_living_units}) differs from the specified number of units (#{Integer(args[:geometry_building_num_units])}).")
      return false
    end

    hpxml_path = File.expand_path(args[:hpxml_path])
    units.each_with_index do |unit, unit_num|
      measures = {}
      if !unit.key?('hpxml_path') # create a single new HPXML file describing all dwelling units of the feature

        # BuildResidentialHPXML
        measure_subdir = 'BuildResidentialHPXML'
        full_measure_path = File.join(measures_dir, measure_subdir, 'measure.rb')
        check_file_exists(full_measure_path, runner)

        measure_args = args.clone.transform_keys(&:to_s)
        measure_args['hpxml_path'] = hpxml_path
        if unit_num > 0
          measure_args['existing_hpxml_path'] = hpxml_path
          measure_args['battery_present'] = 'false' # limitation of OS-HPXML
        end
        begin
          measure_args['software_info_program_used'] = File.basename(File.absolute_path(File.join(File.dirname(__FILE__), '../../..')))
        rescue StandardError
        end
        begin
          version_rb File.absolute_path(File.join(File.dirname(__FILE__), '../../../lib/uo_cli/version.rb'))
          require version_rb
          measure_args['software_info_program_version'] = URBANopt::CLI::VERSION
        rescue StandardError
        end
        measure_args['geometry_unit_left_wall_is_adiabatic'] = unit['geometry_unit_left_wall_is_adiabatic'] if unit.key?('geometry_unit_left_wall_is_adiabatic')
        measure_args['geometry_unit_right_wall_is_adiabatic'] = unit['geometry_unit_right_wall_is_adiabatic'] if unit.key?('geometry_unit_right_wall_is_adiabatic')
        measure_args['geometry_unit_front_wall_is_adiabatic'] = unit['geometry_unit_front_wall_is_adiabatic'] if unit.key?('geometry_unit_front_wall_is_adiabatic')
        measure_args['geometry_unit_back_wall_is_adiabatic'] = unit['geometry_unit_back_wall_is_adiabatic'] if unit.key?('geometry_unit_back_wall_is_adiabatic')
        measure_args['geometry_foundation_type'] = unit['geometry_foundation_type'] if unit.key?('geometry_foundation_type')
        measure_args['geometry_attic_type'] = unit['geometry_attic_type'] if unit.key?('geometry_attic_type')
        measure_args['geometry_unit_orientation'] = unit['geometry_unit_orientation'] if unit.key?('geometry_unit_orientation')

        # don't assign these to BuildResidentialHPXML
        measure = get_measure_instance(full_measure_path)
        arg_names = measure.arguments(model).collect { |arg| arg.name.to_sym }
        args_to_delete = args.keys - arg_names
        args_to_delete.each do |arg_to_delete|
          measure_args.delete(arg_to_delete.to_s)
        end

        measures[measure_subdir] = [measure_args]

        if !apply_measures(measures_dir, measures, runner, model, true, 'OpenStudio::Measure::ModelMeasure', 'feature.osw')
          return false
        end
      else # we're using an HPXML file from the xml_building folder
        FileUtils.cp(File.expand_path(unit['hpxml_path']), hpxml_path)

      end
    end

    # call BuildResidentialScheduleFile / HPXMLtoOpenStudio after HPXML file is created
    measures = {}

    # BuildResidentialScheduleFile
    if args[:schedules_type] == 'stochastic' # if smooth, don't run the measure; schedules type stochastic currently hardcoded in Baseline.rb
      measure_subdir = 'BuildResidentialScheduleFile'
      full_measure_path = File.join(measures_dir, measure_subdir, 'measure.rb')
      check_file_exists(full_measure_path, runner)

      measure_args = {}
      measure_args['hpxml_path'] = hpxml_path
      measure_args['hpxml_output_path'] = hpxml_path
      measure_args['schedules_random_seed'] = args[:schedules_random_seed]
      measure_args['building_id'] = 'ALL' # FIXME: schedules variation by building currently not supported; by unit currently hardcoded in Baseline.rb
      measure_args['output_csv_path'] = 'schedules.csv'

      measures[measure_subdir] = [measure_args]
    end

    # HPXMLtoOpenStudio
    measure_subdir = 'HPXMLtoOpenStudio'
    full_measure_path = File.join(measures_dir, measure_subdir, 'measure.rb')
    check_file_exists(full_measure_path, runner)

    measure_args = {}
    measure_args['hpxml_path'] = hpxml_path
    measure_args['output_dir'] = File.expand_path(args[:output_dir])
    measure_args['debug'] = true
    measure_args['building_id'] = 'ALL'

    measures[measure_subdir] = [measure_args]

    if !apply_measures(measures_dir, measures, runner, model, true, 'OpenStudio::Measure::ModelMeasure', 'feature.osw')
      return false
    end

    # store metadata for default_feature_reports measure
    standards_number_of_above_ground_stories = Integer(args[:geometry_num_floors_above_grade])
    standards_number_of_stories = Integer(args[:geometry_num_floors_above_grade])
    number_of_conditioned_stories = Integer(args[:geometry_num_floors_above_grade])
    if ['UnconditionedBasement', 'ConditionedBasement'].include?(args[:geometry_foundation_type])
      standards_number_of_stories += 1
      if ['ConditionedBasement'].include?(args[:geometry_foundation_type])
        number_of_conditioned_stories += 1
      end
    end

    case args[:geometry_unit_type]
    when 'single-family detached'
      building_type = 'Single-Family Detached'
    when 'single-family attached'
      building_type = 'Single-Family Attached'
    when 'apartment unit'
      building_type = 'Multifamily'
    end

    model.getSpaces.each do |space|
      space_type = OpenStudio::Model::SpaceType.new(model)
      space_type.setStandardsSpaceType(space.name.to_s)
      space.setSpaceType(space_type)
    end

    model.getSpaceTypes.each do |space_type|
      next unless space_type.standardsSpaceType.is_initialized

      # set building_type on SpaceType for conditioned spaces to populate space_type_areas hash in default_feature_reports
      if space_type.standardsSpaceType.get.include?('conditioned space') || space_type.standardsSpaceType.get.include?('conditioned_space')
        space_type.setStandardsBuildingType(building_type)
      end
    end

    model.getBuilding.setStandardsBuildingType('Residential')
    model.getBuilding.setStandardsNumberOfAboveGroundStories(standards_number_of_above_ground_stories)
    model.getBuilding.setStandardsNumberOfStories(standards_number_of_stories)
    model.getBuilding.setNominalFloortoFloorHeight(Float(args[:geometry_average_ceiling_height]))
    model.getBuilding.setStandardsNumberOfLivingUnits(standards_number_of_living_units)
    model.getBuilding.additionalProperties.setFeature('NumberOfConditionedStories', number_of_conditioned_stories)

    return true
  end

  def get_unit_positions(runner, args)
    units = []
    case args[:geometry_unit_type]
    when 'single-family detached'
      units << {}
    when 'single-family attached'
      (1..args[:geometry_building_num_units]).to_a.each do |unit_num|
        case unit_num
        when 1
          units << { 'geometry_unit_left_wall_is_adiabatic' => true }
        when args[:geometry_building_num_units]
          units << { 'geometry_unit_right_wall_is_adiabatic' => true }
        else
          units << { 'geometry_unit_left_wall_is_adiabatic' => true,
                     'geometry_unit_right_wall_is_adiabatic' => true }
        end
      end
    when 'apartment unit'
      num_units_per_floor = (Float(args[:geometry_building_num_units]) / Float(args[:geometry_num_floors_above_grade])).ceil
      if num_units_per_floor == 1
        runner.registerError("Unit type '#{args[:geometry_unit_type]}' with num_units_per_floor=#{num_units_per_floor} is not supported.")
        return units
      end

      floor = 1
      position = 1
      (1..args[:geometry_building_num_units]).to_a.each do |unit_num|
        geometry_unit_orientation = 180.0
        if position.even?
          geometry_unit_orientation = 0.0
        end

        geometry_unit_left_wall_is_adiabatic = true
        geometry_unit_right_wall_is_adiabatic = true
        geometry_unit_front_wall_is_adiabatic = true
        geometry_unit_back_wall_is_adiabatic = false

        if position == 1
          geometry_unit_right_wall_is_adiabatic = false
        elsif position == 2
          geometry_unit_left_wall_is_adiabatic = false
        elsif (position == num_units_per_floor) && num_units_per_floor.even?
          geometry_unit_right_wall_is_adiabatic = false
        elsif (position == num_units_per_floor) && num_units_per_floor.odd?
          geometry_unit_left_wall_is_adiabatic = false
        elsif (position + 1 == num_units_per_floor) && num_units_per_floor.even?
          geometry_unit_left_wall_is_adiabatic = false
        elsif (position + 1 == num_units_per_floor) && num_units_per_floor.odd?
          geometry_unit_right_wall_is_adiabatic = false
        end

        geometry_foundation_type = args[:geometry_foundation_type]
        geometry_attic_type = args[:geometry_attic_type]

        if Float(args[:geometry_num_floors_above_grade]) > 1
          case floor
          when 1
            geometry_attic_type = 'BelowApartment'
          when args[:geometry_num_floors_above_grade]
            geometry_foundation_type = 'AboveApartment'
          else
            geometry_foundation_type = 'AboveApartment'
            geometry_attic_type = 'BelowApartment'
          end
        end

        if unit_num % num_units_per_floor == 0
          floor += 1
          position = 0
        end
        position += 1

        units << { 'geometry_unit_left_wall_is_adiabatic' => geometry_unit_left_wall_is_adiabatic,
                   'geometry_unit_right_wall_is_adiabatic' => geometry_unit_right_wall_is_adiabatic,
                   'geometry_unit_front_wall_is_adiabatic' => geometry_unit_front_wall_is_adiabatic,
                   'geometry_unit_back_wall_is_adiabatic' => geometry_unit_back_wall_is_adiabatic,
                   'geometry_foundation_type' => geometry_foundation_type,
                   'geometry_attic_type' => geometry_attic_type,
                   'geometry_unit_orientation' => geometry_unit_orientation }
      end
    end
    return units
  end
end

# register the measure to be used by the application
BuildResidentialModel.new.registerWithApplication
