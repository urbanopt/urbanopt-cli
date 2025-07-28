require 'json'
require 'fileutils'
require_relative 'utils'


def calculate_capital_costs(scenario_filepath, feature_filepath)
  """Compare year one operating costs to user-provided capital costs"""
  root_dir, scenario_file_name = Pathname(File.expand_path(scenario_filepath)).split
  scenario_name = File.basename(scenario_file_name, File.extname(scenario_file_name))
  run_dir = root_dir / 'run' / scenario_name.downcase
  feature_file_hash = JSON.parse(File.read(File.expand_path(feature_filepath)), symbolize_names: true)

  cost_results = {}
  scenario_output_filepath = run_dir / 'reopt' / "scenario_report_#{scenario_name}_reopt_run.json"
  scenario_capital_costs = 0
  feature_file_hash[:features].each do |feature|
    next unless feature[:properties][:type] == 'Building'
    if feature[:properties].key?(:capital_costs_per_square_foot)
      if feature[:properties][:capital_costs_per_square_foot] == true
        building_capital_cost = feature[:properties][:capital_costs] * feature[:properties][:floor_area]
      elsif feature[:properties][:capital_costs_per_square_foot] == false
        building_capital_cost = feature[:properties][:capital_costs]
      else
        abort("\nERROR: If using 'capital_costs_per_square_foot' in the feature file, it must be either 'true' or 'false'")
      end
    else
      building_capital_cost = 0
    end
    scenario_capital_costs += building_capital_cost

    # If reopt was run for feature optimization
    unless File.exist?(scenario_output_filepath)
      feature_output_filepath = run_dir / feature[:properties][:id] / 'reopt' / "feature_report_#{feature[:properties][:id]}_reopt_run.json"
      unless File.exist?(feature_output_filepath)
        abort("\nERROR: REopt post-processing has not been run for feature #{feature[:properties][:id]}. Please run REopt post-processing first.")
      end
      reopt_output = JSON.parse(File.read(feature_output_filepath), symbolize_names: true)
      year_one_cost = reopt_output[:outputs][:ElectricTariff][:year_one_bill_before_tax]
      cost_results[feature[:properties][:id]] = {
        capital_costs: format_float(building_capital_cost),
        year_one_cost: format_float(year_one_cost),
        simple_payback: "#{(building_capital_cost / year_one_cost).round(1)} years"
      }
    end
  end
  # If reopt was run for scenario optimization
  if File.exist?(scenario_output_filepath)
    reopt_output = JSON.parse(File.read(scenario_output_filepath), symbolize_names: true)
    year_one_cost = reopt_output[:outputs][:ElectricTariff][:year_one_bill_before_tax]
    cost_results[scenario_name] = {
      capital_costs: format_float(scenario_capital_costs),
      year_one_cost: format_float(year_one_cost),
      simple_payback: "#{(scenario_capital_costs / year_one_cost).round(1)} years"
    }
  end

  # write capital costs file for this scenario
  capital_costs_filepath = run_dir / "capital_costs_#{scenario_name}.json"
  File.open(capital_costs_filepath, 'w') { |f| f.write JSON.pretty_generate(cost_results) }
end
