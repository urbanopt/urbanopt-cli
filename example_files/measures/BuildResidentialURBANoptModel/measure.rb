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

    arg = OpenStudio::Measure::OSArgument::makeStringArgument("unit_type", true)
    arg.setDisplayName("Geometry: Unit Type")
    arg.setDescription("The type of unit.")
    args << arg

    arg = OpenStudio::Measure::OSArgument::makeDoubleArgument("cfa", true)
    arg.setDisplayName("Geometry: Conditioned Floor Area")
    arg.setUnits("ft^2")
    arg.setDescription("The total floor area of the conditioned space (including any conditioned basement floor area).")
    args << arg

    arg = OpenStudio::Measure::OSArgument::makeDoubleArgument("wall_height", true)
    arg.setDisplayName("Geometry: Wall Height (Per Floor)")
    arg.setUnits("ft")
    arg.setDescription("The height of the living space (and garage) walls.")
    args << arg

    arg = OpenStudio::Measure::OSArgument::makeIntegerArgument("num_units", true)
    arg.setDisplayName("Geometry: Number of Units")
    arg.setUnits("#")
    arg.setDescription("The number of units in the building.")
    args << arg

    arg = OpenStudio::Measure::OSArgument::makeIntegerArgument("num_floors", true)
    arg.setDisplayName("Geometry: Number of Floors")
    arg.setUnits("#")
    arg.setDescription("The number of floors above grade (in the unit if single-family, and in the building if multifamily).")
    args << arg

    arg = OpenStudio::Measure::OSArgument::makeStringArgument("foundation_type", true)
    arg.setDisplayName("Geometry: Foundation Type")
    arg.setDescription("The foundation type of the building.")
    args << arg

    arg = OpenStudio::Measure::OSArgument::makeStringArgument("roof_type", true)
    arg.setDisplayName("Geometry: Roof Type")
    arg.setDescription("The roof type of the building.")
    args << arg

    arg = OpenStudio::Measure::OSArgument::makeStringArgument("heating_system_type", true)
    arg.setDisplayName("Heating System: Type")
    arg.setDescription("The type of the heating system.")
    args << arg

    arg = OpenStudio::Measure::OSArgument::makeStringArgument("heating_system_fuel", true)
    arg.setDisplayName("Heating System: Fuel Type")
    arg.setDescription("The fuel type of the heating system.")
    args << arg

    arg = OpenStudio::Measure::OSArgument::makeStringArgument("cooling_system_type", true)
    arg.setDisplayName("Cooling System: Type")
    arg.setDescription("The type of the cooling system.")
    arg.setDefaultValue("central air conditioner")
    args << arg

    arg = OpenStudio::Measure::OSArgument::makeStringArgument("heat_pump_type", true)
    arg.setDisplayName("Heat Pump: Type")
    arg.setDescription("The type of the heat pump.")
    arg.setDefaultValue("none")
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

    args = { :unit_type => runner.getStringArgumentValue("unit_type", user_arguments),
             :cfa => runner.getDoubleArgumentValue("cfa", user_arguments),
             :wall_height => runner.getDoubleArgumentValue("wall_height", user_arguments),
             :num_units => runner.getIntegerArgumentValue("num_units", user_arguments),
             :num_floors => runner.getIntegerArgumentValue("num_floors", user_arguments),             
             :foundation_type => runner.getStringArgumentValue("foundation_type", user_arguments),
             :roof_type => runner.getStringArgumentValue("roof_type", user_arguments),
             :heating_system_type => runner.getStringArgumentValue("heating_system_type", user_arguments),
             :heating_system_fuel => runner.getStringArgumentValue("heating_system_fuel", user_arguments),
             :cooling_system_type => runner.getStringArgumentValue("cooling_system_type", user_arguments),
             :heat_pump_type => runner.getStringArgumentValue("heat_pump_type", user_arguments) }

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
    if args[:unit_type] == "single-family detached"
      measure_subdir = "ResidentialGeometryCreateSingleFamilyDetached"
    elsif args[:unit_type] == "single-family attached"
      measure_subdir = "ResidentialGeometryCreateSingleFamilyAttached"
    elsif args[:unit_type] == "multifamily"
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
    if ["single-family detached"].include? args[:unit_type]
      measure_args["total_ffa"] = args[:cfa]
      measure_args["num_floors"] = args[:num_floors]
    elsif ["single-family attached", "multifamily"].include? args[:unit_type]
      measure_args["unit_ffa"] = args[:cfa]
      measure_args["num_floors"] = args[:num_floors]
      measure_args["num_units"] = args[:num_units]
    end
    measures[measure_subdir] << measure_args

    if not apply_measures(measures_dir, measures, runner, whole_building_model, nil, nil, true)
      return false
    end

    # Apply HPXML measures
    measures_dir = File.absolute_path(File.join(File.dirname(__FILE__), "../../resources/hpxml-measures"))

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
      measure_args["unit_type"] = args[:unit_type]
      measure_args["unit_multiplier"] = units_represented
      measure_args["cfa"] = args[:cfa]
      measure_args["wall_height"] = args[:wall_height]
      measure_args["num_units"] = args[:num_units]
      measure_args["num_floors"] = args[:num_floors]
      measure_args["foundation_type"] = args[:foundation_type]
      measure_args["roof_type"] = args[:roof_type]
      measure_args["heating_system_type"] = args[:heating_system_type]
      measure_args["heating_system_fuel"] = args[:heating_system_fuel]
      measure_args["cooling_system_type"] = args[:cooling_system_type]
      measure_args["heat_pump_type"] = args[:heat_pump_type]
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
