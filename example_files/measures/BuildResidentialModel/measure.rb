# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/measures/measure_writing_guide/

require 'openstudio'
if File.exist? File.absolute_path(File.join(File.dirname(__FILE__), '../../lib/resources/hpxml-measures/HPXMLtoOpenStudio/resources')) # Hack to run ResStock on AWS
  resources_path = File.absolute_path(File.join(File.dirname(__FILE__), '../../lib/resources/hpxml-measures/HPXMLtoOpenStudio/resources'))
elsif File.exist? File.absolute_path(File.join(File.dirname(__FILE__), '../../resources/hpxml-measures/HPXMLtoOpenStudio/resources')) # Hack to run ResStock unit tests locally
  resources_path = File.absolute_path(File.join(File.dirname(__FILE__), '../../resources/hpxml-measures/HPXMLtoOpenStudio/resources'))
elsif File.exist? File.join(OpenStudio::BCLMeasure.userMeasuresDir.to_s, 'HPXMLtoOpenStudio/resources') # Hack to run measures in the OS App since applied measures are copied off into a temporary directory
  resources_path = File.join(OpenStudio::BCLMeasure.userMeasuresDir.to_s, 'HPXMLtoOpenStudio/resources')
else
  resources_path = File.absolute_path(File.join(File.dirname(__FILE__), '../HPXMLtoOpenStudio/resources'))
end
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
    arg.setDisplayName('Custom HPXML Files')
    arg.setDescription('The name of the folder containing HPXML files, relative to the xml_building folder.')
    args << arg

    measures_dir = File.absolute_path(File.join(File.dirname(__FILE__), '../../resources/hpxml-measures'))
    measure_subdir = 'BuildResidentialHPXML'
    full_measure_path = File.join(measures_dir, measure_subdir, 'measure.rb')
    measure = get_measure_instance(full_measure_path)

    measure.arguments(model).each do |arg|
      next if ['hpxml_path'].include? arg.name

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
      # TODO: how to check if arg is an optional or not?

      if args[arg].is_initialized
        args[arg] = args[arg].get
      else
        args.delete(arg)
      end
    rescue StandardError
    end

    # get file/dir paths
    resources_dir = File.absolute_path(File.join(File.dirname(__FILE__), '../../resources'))
    meta_measure_file = File.join(resources_dir, 'meta_measure.rb')
    require File.join(File.dirname(meta_measure_file), File.basename(meta_measure_file, File.extname(meta_measure_file)))
    workflow_json = File.join(resources_dir, 'measure-info.json')

    # apply HPXML measures
    measures_dir = File.join(resources_dir, 'hpxml-measures')
    check_dir_exists(measures_dir, runner)

    # these will get added back in by unit_model
    model.getBuilding.remove
    model.getShadowCalculation.remove
    model.getSimulationControl.remove
    model.getSite.remove
    model.getTimestep.remove

    # either create units or get pre-made units
    if args['hpxml_dir'].nil?
      units = get_unit_positions(runner, args)
      if units.empty?
        return false
      end
    else
      hpxml_dir = File.join(File.dirname(__FILE__), "../../xml_building/#{args['hpxml_dir']}")

      if !File.exist?(hpxml_dir)
        runner.registerError("HPXML directory #{File.expand_path(hpxml_dir)} was specified for feature ID = #{args['feature_id']}, but could not be found.")
        return false
      end

      units = []
      Dir["#{hpxml_dir}/*.xml"].each do |hpxml_path|
        name, ext = File.basename(hpxml_path).split('.')
        units << { 'name' => name, 'hpxml_path' => hpxml_path }
      end
    end

    standards_number_of_living_units = units.size
    if args['hpxml_dir'].nil? && args.key?('geometry_building_num_units') && (standards_number_of_living_units != Integer(args['geometry_building_num_units']))
      runner.registerError("The number of created units (#{units.size}) differs from the specified number of units (#{standards_number_of_living_units}).")
      return false
    end

    units.each_with_index do |unit, unit_num|
      unit_model = OpenStudio::Model::Model.new

      measures = {}
      hpxml_path = File.expand_path("../#{unit['name']}.xml")
      if !unit.key?('hpxml_path')

        # BuildResidentialHPXML
        measure_subdir = 'BuildResidentialHPXML'
        full_measure_path = File.join(measures_dir, measure_subdir, 'measure.rb')
        check_file_exists(full_measure_path, runner)
        measures[measure_subdir] = []

        measure_args = args.clone
        measure_args['hpxml_path'] = hpxml_path
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
        measure_args.delete('feature_id')
        measure_args.delete('schedules_type')
        measure_args.delete('schedules_random_seed')
        measure_args.delete('schedules_variation')
        measure_args.delete('geometry_num_floors_above_grade')

        measures[measure_subdir] << measure_args
      else
        FileUtils.cp(File.expand_path(unit['hpxml_path']), hpxml_path)
      end

      # BuildResidentialScheduleFile
      measure_subdir = 'BuildResidentialScheduleFile'
      full_measure_path = File.join(measures_dir, measure_subdir, 'measure.rb')
      check_file_exists(full_measure_path, runner)
      measures[measure_subdir] = []

      measure_args = {}
      measure_args['hpxml_path'] = hpxml_path
      measure_args['hpxml_output_path'] = hpxml_path
      measure_args['schedules_type'] = args['schedules_type']
      measure_args['schedules_random_seed'] = args['schedules_random_seed'] # variation by building; deterministic
      if args['schedules_variation'] == 'unit'
        measure_args['schedules_random_seed'] *= (unit_num + 1) # variation across units; deterministic
      end
      measure_args['output_csv_path'] = File.expand_path("../#{unit['name']}.csv")

      measures[measure_subdir] << measure_args

      # HPXMLtoOpenStudio
      measure_subdir = 'HPXMLtoOpenStudio'
      full_measure_path = File.join(measures_dir, measure_subdir, 'measure.rb')
      check_file_exists(full_measure_path, runner)
      measures[measure_subdir] = []

      measure_args = {}
      measure_args['hpxml_path'] = hpxml_path
      measure_args['output_dir'] = File.expand_path('..')
      measure_args['debug'] = true

      measures[measure_subdir] << measure_args

      if !apply_child_measures(measures_dir, measures, runner, unit_model, workflow_json, "#{unit['name']}.osw", true)
        return false
      end

      # store metadata for default feature reports measure
      standards_number_of_above_ground_stories = Integer(args['geometry_num_floors_above_grade'])
      standards_number_of_stories = Integer(args['geometry_num_floors_above_grade'])
      number_of_conditioned_stories = Integer(args['geometry_num_floors_above_grade'])
      if ['UnconditionedBasement', 'ConditionedBasement'].include?(args['geometry_foundation_type'])
        standards_number_of_stories += 1
        if ['ConditionedBasement'].include?(args['geometry_foundation_type'])
          number_of_conditioned_stories += 1
        end
      end

      case args['geometry_unit_type']
      when 'single-family detached'
        building_type = 'Single-Family Detached'
      when 'single-family attached'
        building_type = 'Single-Family Attached'
      when 'apartment unit'
        building_type = 'Multifamily'
      end

      unit_model.getSpaces.each do |unit_space|
        unit_space_type = OpenStudio::Model::SpaceType.new(unit_model)
        unit_space_type.setStandardsSpaceType(unit_space.name.to_s)
        unit_space.setSpaceType(unit_space_type)
      end

      unit_model.getSpaceTypes.each do |space_type|
        next unless space_type.standardsSpaceType.is_initialized
        next if !space_type.standardsSpaceType.get.include?('living space')

        space_type.setStandardsBuildingType(building_type)
      end

      unit_model.getBuilding.setStandardsBuildingType('Residential')
      unit_model.getBuilding.setStandardsNumberOfAboveGroundStories(standards_number_of_above_ground_stories)
      unit_model.getBuilding.setStandardsNumberOfStories(standards_number_of_stories)
      unit_model.getBuilding.setNominalFloortoFloorHeight(Float(args['geometry_average_ceiling_height']))
      unit_model.getBuilding.setStandardsNumberOfLivingUnits(standards_number_of_living_units)
      unit_model.getBuilding.additionalProperties.setFeature('NumberOfConditionedStories', number_of_conditioned_stories)

      if unit_num == 0 # for the first building unit, add everything

        model.addObjects(unit_model.objects, true)

      else # for single-family attached and multifamily, add "almost" everything

        y_shift = 100.0 * unit_num # meters

        # shift the unit so it's not right on top of the previous one
        unit_model.getSpaces.sort.each do |space|
          space.setYOrigin(y_shift)
        end

        # shift shading surfaces
        m = OpenStudio::Matrix.new(4, 4, 0)
        m[0, 0] = 1
        m[1, 1] = 1
        m[2, 2] = 1
        m[3, 3] = 1
        m[1, 3] = y_shift
        t = OpenStudio::Transformation.new(m)

        unit_model.getShadingSurfaceGroups.each do |shading_surface_group|
          next if shading_surface_group.space.is_initialized # already got shifted

          shading_surface_group.shadingSurfaces.each do |shading_surface|
            shading_surface.setVertices(t * shading_surface.vertices)
          end
        end

        # prefix all objects with name using unit number. May be cleaner if source models are setup with unique names
        prefix_all_unit_model_objects(unit_model, unit)

        # we already have the following unique objects from the first building unit
        unit_model.getConvergenceLimits.remove
        unit_model.getOutputDiagnostics.remove
        unit_model.getRunPeriodControlDaylightSavingTime.remove
        unit_model.getShadowCalculation.remove
        unit_model.getSimulationControl.remove
        unit_model.getSiteGroundTemperatureDeep.remove
        unit_model.getSiteGroundTemperatureShallow.remove
        unit_model.getSite.remove
        unit_model.getInsideSurfaceConvectionAlgorithm.remove
        unit_model.getOutsideSurfaceConvectionAlgorithm.remove
        unit_model.getTimestep.remove
        unit_model.getFoundationKivaSettings.remove
        unit_model.getOutputJSON.remove
        unit_model.getOutputControlFiles.remove
        unit_model.getPerformancePrecisionTradeoffs.remove

        unit_model_objects = []
        unit_model.objects.each do |obj|
          unit_model_objects << obj unless obj.to_Building.is_initialized # if we remove this, we lose all thermal zones
        end

        model.addObjects(unit_model_objects, true)

      end
    end

    # save the "re-composed" model with all building units to file
    building_path = File.expand_path(File.join('..', 'whole_building.osm'))
    model.save(building_path, true)

    return true
  end

  def get_unit_positions(runner, args)
    units = []
    case args['geometry_unit_type']
    when 'single-family detached'
      units << { 'name' => 'unit 1' }
    when 'single-family attached'
      (1..args['geometry_building_num_units']).to_a.each do |unit_num|
        case unit_num
        when 1
          units << { 'name' => "unit #{unit_num}",
                     'geometry_unit_left_wall_is_adiabatic' => true }
        when args['geometry_building_num_units']
          units << { 'name' => "unit #{unit_num}",
                     'geometry_unit_right_wall_is_adiabatic' => true }
        else
          units << { 'name' => "unit #{unit_num}",
                     'geometry_unit_left_wall_is_adiabatic' => true,
                     'geometry_unit_right_wall_is_adiabatic' => true }
        end
      end
    when 'apartment unit'
      num_units_per_floor = (Float(args['geometry_building_num_units']) / Float(args['geometry_num_floors_above_grade'])).ceil
      if num_units_per_floor == 1
        runner.registerError("num_units_per_floor='#{num_units_per_floor}' not supported.")
        return units
      end

      floor = 1
      position = 1
      (1..args['geometry_building_num_units']).to_a.each do |unit_num|
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

        geometry_foundation_type = args['geometry_foundation_type']
        geometry_attic_type = args['geometry_attic_type']

        if Float(args['geometry_num_floors_above_grade']) > 1
          case floor
          when 1
            geometry_attic_type = 'BelowApartment'
          when args['geometry_num_floors_above_grade']
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

        units << { 'name' => "unit #{unit_num}",
                   'geometry_unit_left_wall_is_adiabatic' => geometry_unit_left_wall_is_adiabatic,
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

  def get_measure_args_default_values(model, args, measure)
    measure.arguments(model).each do |arg|
      next unless arg.hasDefaultValue

      case arg.type.valueName.downcase
      when 'boolean'
        args[arg.name] = arg.defaultValueAsBool
      when 'double'
        args[arg.name] = arg.defaultValueAsDouble
      when 'integer'
        args[arg.name] = arg.defaultValueAsInteger
      when 'string'
        args[arg.name] = arg.defaultValueAsString
      when 'choice'
        args[arg.name] = arg.defaultValueAsString
      end
    end
  end

  def prefix_all_unit_model_objects(unit_model, unit)
    # EMS objects
    ems_map = {}

    unit_model.getEnergyManagementSystemSensors.each do |sensor|
      old_sensor_name = sensor.name.to_s
      new_sensor_name = make_variable_name("#{unit['name']}_#{sensor.name}")

      ems_map[old_sensor_name] = new_sensor_name

      old_sensor_key_name = sensor.keyName.to_s
      new_sensor_key_name = make_variable_name("#{unit['name']}_#{sensor.keyName}") unless sensor.keyName.empty?
      sensor.setKeyName(new_sensor_key_name) unless sensor.keyName.empty?
    end

    unit_model.getEnergyManagementSystemActuators.each do |actuator|
      old_actuator_name = actuator.name.to_s
      new_actuator_name = make_variable_name("#{unit['name']}_#{actuator.name}")

      ems_map[old_actuator_name] = new_actuator_name
    end

    unit_model.getEnergyManagementSystemOutputVariables.each do |output_variable|
      next if output_variable.emsVariableObject.is_initialized

      old_ems_variable_name = output_variable.emsVariableName.to_s
      new_ems_variable_name = make_variable_name("#{unit['name']}_#{output_variable.emsVariableName}")

      ems_map[old_ems_variable_name] = new_ems_variable_name
      output_variable.setEMSVariableName(new_ems_variable_name)
    end

    # variables in program lines don't get updated automatically
    characters = ['', ' ', ',', '(', ')', '+', '-', '*', '/', ';']
    unit_model.getEnergyManagementSystemPrograms.each do |program|
      old_program_name = program.name.to_s
      new_program_name = make_variable_name("#{unit['name']}_#{program.name}")

      new_lines = []
      program.lines.each_with_index do |line, i|
        ems_map.each do |old_name, new_name|
          # old_name between at least 1 character, with the exception of '' on left and ' ' on right
          characters.each do |lhs|
            characters.each do |rhs|
              next if lhs == '' && ['', ' '].include?(rhs)

              line = line.gsub("#{lhs}#{old_name}#{rhs}", "#{lhs}#{new_name}#{rhs}") if line.include?("#{lhs}#{old_name}#{rhs}")
            end
          end
        end
        new_lines << line
      end
      program.setLines(new_lines)
    end

    # All model objects
    unit_model.objects.each do |model_object|
      next if model_object.name.nil?

      new_model_object_name = make_variable_name("#{unit['name']}_#{model_object.name}")
      model_object.setName(new_model_object_name)
    end
  end

  def make_variable_name(str)
    return str.gsub(' ', '_').gsub('-', '_')
  end
end

# register the measure to be used by the application
BuildResidentialModel.new.registerWithApplication
