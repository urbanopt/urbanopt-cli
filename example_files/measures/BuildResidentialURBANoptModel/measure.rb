# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/measures/measure_writing_guide/

require 'openstudio'

# start the measure
class BuildResidentialURBANoptModel < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    return "Build Residential URBANopt Model"
  end

  # human readable description
  def description
    return "Builds the OpenStudio Model for an existing residential building."
  end

  # human readable description of modeling approach
  def modeler_description
    return "Builds the residential OpenStudio Model using the geojson feature file, which contains the specified parameters for each existing building."
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    arg = OpenStudio::Ruleset::OSArgument.makeStringArgument("building_type", true)
    arg.setDisplayName("Building Type")
    arg.setDescription("The type of the residential building.")
    args << arg

    arg = OpenStudio::Ruleset::OSArgument.makeDoubleArgument("footprint_area", true)
    arg.setDisplayName("Footpring Area")
    arg.setDescription("The footprint area of the residential building.")
    args << arg

    arg = OpenStudio::Ruleset::OSArgument.makeIntegerArgument("number_of_stories", true)
    arg.setDisplayName("Number of Stories")
    arg.setDescription("The number of stories in the residential building.")
    args << arg

    arg = OpenStudio::Ruleset::OSArgument.makeIntegerArgument("number_of_residential_units", true)
    arg.setDisplayName("Number of Residential Units")
    arg.setDescription("The number of residential units in the residential building.")
    args << arg

    arg = OpenStudio::Measure::OSArgument::makeBoolArgument("minimal_collapsed", true)
    arg.setDisplayName("Minimal Collapsed Building")
    arg.setDescription("Collapse the building down into only corner, end, and/or middle units.")
    arg.setDefaultValue(false)
    args << arg

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    args = { :building_type => runner.getStringArgumentValue("building_type", user_arguments),
             :footprint_area => runner.getDoubleArgumentValue("footprint_area", user_arguments),
             :number_of_stories => runner.getIntegerArgumentValue("number_of_stories", user_arguments),
             :number_of_residential_units => runner.getIntegerArgumentValue("number_of_residential_units", user_arguments),
             :minimal_collapsed => runner.getBoolArgumentValue("minimal_collapsed", user_arguments) }

    # Override some defaults with geojson feature file values
    args[:unit_ffa] = args[:footprint_area] * args[:number_of_stories] / args[:number_of_residential_units]

    # Get file/dir paths
    resources_dir = File.absolute_path(File.join(File.dirname(__FILE__), "resources"))
    meta_measure_file = File.join(resources_dir, "meta_measure.rb")
    require File.join(File.dirname(meta_measure_file), File.basename(meta_measure_file, File.extname(meta_measure_file)))
    workflow_json = File.join(resources_dir, "measure-info.json")

    # Apply whole building create geometry measures
    measures_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))

    # Check file/dir paths exist
    check_dir_exists(measures_dir, runner)

    # Choose which whole building create geometry measure to call
    if args[:building_type] == "single-family detached"
      measure_subdir = "ResidentialGeometryCreateSingleFamilyDetached"
    elsif args[:building_type] == "single-family attached"
      measure_subdir = "ResidentialGeometryCreateSingleFamilyAttached"
    elsif args[:building_type] == "multifamily"
      measure_subdir = "ResidentialGeometryCreateMultifamily"
    end

    full_measure_path = File.join(measures_dir, measure_subdir, "measure.rb")
    check_file_exists(full_measure_path, runner)
    measure = get_measure_instance(full_measure_path)

    # Fill the measure args hash with default values
    measure_args = {}
    whole_building_model = OpenStudio::Model::Model.new
    get_measure_args_default_values(whole_building_model, measure_args, measure)

    # Override some defaults with geojson feature file values
    measures = {}
    measures[measure_subdir] = []
    if args[:building_type] == "single-family detached"
      measure_args["total_ffa"] = args[:unit_ffa]
      measure_args["num_floors"] = args[:number_of_stories]
    elsif ["single-family attached", "multifamily"].include? args[:building_type]
      measure_args["unit_ffa"] = args[:unit_ffa]
      measure_args["num_floors"] = args[:number_of_stories]
      measure_args["num_units"] = args[:number_of_residential_units]
      measure_args["minimal_collapsed"] = args[:minimal_collapsed]
    end
    measures[measure_subdir] << measure_args

    if not apply_measures(measures_dir, measures, runner, whole_building_model, nil, nil, true)
      return false
    end

    # Apply HPXML measures
    measures_dir = File.absolute_path(File.join(File.dirname(__FILE__), "../../resources/residential-hpxml-measures"))

    # Check file/dir paths exist
    check_dir_exists(measures_dir, runner)

    unit_models = []
    whole_building_model.getBuildingUnits.each do |unit|
      unit_model = OpenStudio::Model::Model.new

      # Get unit multiplier
      units_represented = 1
      if unit.additionalProperties.getFeatureAsInteger("Units Represented").is_initialized
        units_represented = unit.additionalProperties.getFeatureAsInteger("Units Represented").get
      end

      # BuildResidentialHPXML
      measure_subdir = "BuildResidentialHPXML"
      full_measure_path = File.join(measures_dir, measure_subdir, "measure.rb")
      check_file_exists(full_measure_path, runner)
      measure = get_measure_instance(full_measure_path)

      # Fill the measure args hash with default values
      measure_args = {}
      get_measure_args_default_values(unit_model, measure_args, measure)

      measures = {}
      measures[measure_subdir] = []
      measure_args["weather_station_epw_filename"] = "USA_NY_Buffalo-Greater.Buffalo.Intl.AP.725280_TMY3.epw" # FIXME
      measure_args["hpxml_path"] = File.expand_path("../in.xml")
      measure_args["schedules_output_path"] = "../schedules.csv"
      measure_args["unit_type"] = args[:building_type]
      measure_args["cfa"] = args[:unit_ffa]
      measure_args["unit_multiplier"] = units_represented
      measures[measure_subdir] << measure_args

      # HPXMLtoOpenStudio
      measure_subdir = "HPXMLtoOpenStudio"
      full_measure_path = File.join(measures_dir, measure_subdir, "measure.rb")
      check_file_exists(full_measure_path, runner)
      measure = get_measure_instance(full_measure_path)

      # Fill the measure args hash with default values
      measure_args = {}
      get_measure_args_default_values(unit_model, measure_args, measure)

      measures[measure_subdir] = []
      measure_args["hpxml_path"] = File.expand_path("../in.xml")
      measure_args["weather_dir"] = File.expand_path("../../../../weather")
      measures[measure_subdir] << measure_args

      if not apply_measures(measures_dir, measures, runner, unit_model, workflow_json, "#{unit.name}.osw", true)
        return false
      end

      unit_models << unit_model
    end

    # TODO: merge all unit models into a single model
    model.getBuilding.remove
    model.getShadowCalculation.remove
    model.getSimulationControl.remove
    model.getSite.remove
    model.getTimestep.remove

    unit_models.each do |unit_model|
      model.addObjects(unit_model.objects, true)
    end

    return true
  end

  def get_measure_args_default_values(model, args, measure)
    measure.arguments(model).each do |arg|
      next unless arg.hasDefaultValue

      case arg.type.valueName.downcase
      when "boolean"
        args[arg.name] = arg.defaultValueAsBool
      when "double"
        args[arg.name] = arg.defaultValueAsDouble
      when "integer"
        args[arg.name] = arg.defaultValueAsInteger
      when "string"
        args[arg.name] = arg.defaultValueAsString
      when "choice"
        args[arg.name] = arg.defaultValueAsString
      end
    end
  end
end

# register the measure to be used by the application
BuildResidentialURBANoptModel.new.registerWithApplication
