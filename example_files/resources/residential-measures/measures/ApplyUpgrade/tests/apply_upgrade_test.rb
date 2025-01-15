# frozen_string_literal: true

require 'openstudio'
require_relative '../../../resources/hpxml-measures/HPXMLtoOpenStudio/resources/minitest_helper'
require_relative '../../../resources/hpxml-measures/HPXMLtoOpenStudio/resources/hpxml'
require_relative '../measure.rb'

class ApplyUpgradeTest < Minitest::Test
  def test_SFD_1story_FB_UA_GRG_MSHP_FuelTanklessWH
    osw_file = '../../UpgradeCosts/tests/SFD_1story_FB_UA_GRG_MSHP_FuelTanklessWH.osw'
    puts "\nTesting #{File.basename(osw_file)}..."

    _test_measure(osw_file)

    args_hash = {}
    expected_capacities = {
      'heating_system_heating_capacity' => nil,
      'heating_system_2_heating_capacity' => nil,
      'cooling_system_cooling_capacity' => nil,
      'heat_pump_heating_capacity' => 60000.0,
      'heat_pump_cooling_capacity' => 60000.0,
      'heat_pump_backup_heating_capacity' => 100000.0
    }

    _lighting_upgrade(args_hash)
    _test_retaining_capacities(args_hash, expected_capacities)

    _heating_system_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    _heating_system_2_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    _cooling_system_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    _heat_pump_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    puts 'Retaining existing heating system:'
    expected_values = {}

    expected_values['heat_pump_backup_type'] = nil
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpAirToAir, nil, expected_values)

    expected_values['heat_pump_backup_type'] = nil
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpMiniSplit, nil, expected_values)

    expected_values['heat_pump_backup_type'] = nil
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpMiniSplit, 'false', expected_values)

    expected_values['heat_pump_backup_type'] = nil
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpMiniSplit, 'true', expected_values)
  end

  def test_SFD_1story_UB_UA_GRG_ACV_FuelFurnace_PortableHeater_HPWH
    osw_file = '../../UpgradeCosts/tests/SFD_1story_UB_UA_GRG_ACV_FuelFurnace_PortableHeater_HPWH.osw'
    puts "\nTesting #{File.basename(osw_file)}..."

    _test_measure(osw_file)

    args_hash = {}
    expected_capacities = {
      'heating_system_heating_capacity' => 100000.0,
      'heating_system_2_heating_capacity' => 20000.0,
      'cooling_system_cooling_capacity' => 60000.0,
      'heat_pump_heating_capacity' => nil,
      'heat_pump_cooling_capacity' => nil,
      'heat_pump_backup_heating_capacity' => nil
    }

    puts 'Retaining capacities:'
    _lighting_upgrade(args_hash)
    _test_retaining_capacities(args_hash, expected_capacities)

    _heating_system_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    _heating_system_2_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    _cooling_system_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    _heat_pump_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    puts 'Retaining existing heating system:'
    expected_values = {
      'heating_system_type' => HPXML::HVACTypeFurnace,
      'heat_pump_backup_fuel' => HPXML::FuelTypeNaturalGas,
      'heat_pump_backup_heating_efficiency' => 0.92,
      'heat_pump_backup_heating_capacity' => 100000.0
    }

    expected_values['heat_pump_backup_type'] = HPXML::HeatPumpBackupTypeIntegrated
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpAirToAir, nil, expected_values)

    expected_values['heat_pump_backup_type'] = HPXML::HeatPumpBackupTypeSeparate
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpMiniSplit, nil, expected_values)

    expected_values['heat_pump_backup_type'] = HPXML::HeatPumpBackupTypeSeparate
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpMiniSplit, 'false', expected_values)

    expected_values['heat_pump_backup_type'] = HPXML::HeatPumpBackupTypeIntegrated
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpMiniSplit, 'true', expected_values)
  end

  def test_SFD_2story_CS_UA_AC2_FuelBoiler_FuelTankWH
    osw_file = '../../UpgradeCosts/tests/SFD_2story_CS_UA_AC2_FuelBoiler_FuelTankWH.osw'
    puts "\nTesting #{File.basename(osw_file)}..."

    _test_measure(osw_file)

    args_hash = {}
    expected_capacities = {
      'heating_system_heating_capacity' => 100000.0,
      'heating_system_2_heating_capacity' => nil,
      'cooling_system_cooling_capacity' => 60000.0,
      'heat_pump_heating_capacity' => nil,
      'heat_pump_cooling_capacity' => nil,
      'heat_pump_backup_heating_capacity' => nil
    }

    puts 'Retaining capacities:'
    _lighting_upgrade(args_hash)
    _test_retaining_capacities(args_hash, expected_capacities)

    _heating_system_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    _heating_system_2_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    _cooling_system_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    _heat_pump_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    puts 'Retaining existing heating system:'
    expected_values = {
      'heating_system_type' => HPXML::HVACTypeBoiler,
      'heat_pump_backup_fuel' => HPXML::FuelTypeNaturalGas,
      'heat_pump_backup_heating_efficiency' => 0.92,
      'heat_pump_backup_heating_capacity' => 100000.0
    }

    expected_values['heat_pump_backup_type'] = HPXML::HeatPumpBackupTypeSeparate
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpAirToAir, nil, expected_values)

    expected_values['heat_pump_backup_type'] = HPXML::HeatPumpBackupTypeSeparate
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpMiniSplit, nil, expected_values)

    expected_values['heat_pump_backup_type'] = HPXML::HeatPumpBackupTypeSeparate
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpMiniSplit, 'false', expected_values)

    expected_values['heat_pump_backup_type'] = HPXML::HeatPumpBackupTypeSeparate
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpMiniSplit, 'true', expected_values)
  end

  def test_SFD_2story_FB_UA_GRG_AC1_ElecBaseboard_FuelTankWH
    osw_file = '../../UpgradeCosts/tests/SFD_2story_FB_UA_GRG_AC1_ElecBaseboard_FuelTankWH.osw'
    puts "\nTesting #{File.basename(osw_file)}..."

    _test_measure(osw_file)

    args_hash = {}
    expected_capacities = {
      'heating_system_heating_capacity' => 100000.0,
      'heating_system_2_heating_capacity' => nil,
      'cooling_system_cooling_capacity' => 60000.0,
      'heat_pump_heating_capacity' => nil,
      'heat_pump_cooling_capacity' => nil,
      'heat_pump_backup_heating_capacity' => nil
    }

    puts 'Retaining capacities:'
    _lighting_upgrade(args_hash)
    _test_retaining_capacities(args_hash, expected_capacities)

    _heating_system_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    _heating_system_2_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    _cooling_system_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    _heat_pump_upgrade(args_hash, expected_capacities)
    _test_retaining_capacities(args_hash, expected_capacities)

    puts 'Retaining existing heating system:'
    expected_values = {
      'heating_system_type' => HPXML::HVACTypeElectricResistance,
      'heat_pump_backup_fuel' => HPXML::FuelTypeElectricity,
      'heat_pump_backup_heating_efficiency' => 1.0,
      'heat_pump_backup_heating_capacity' => 100000.0
    }

    expected_values['heat_pump_backup_type'] = HPXML::HeatPumpBackupTypeSeparate
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpAirToAir, nil, expected_values)

    expected_values['heat_pump_backup_type'] = HPXML::HeatPumpBackupTypeSeparate
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpMiniSplit, nil, expected_values)

    expected_values['heat_pump_backup_type'] = HPXML::HeatPumpBackupTypeSeparate
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpMiniSplit, 'false', expected_values)

    expected_values['heat_pump_backup_type'] = HPXML::HeatPumpBackupTypeSeparate
    _test_heat_pump_backup(HPXML::HVACTypeHeatPumpMiniSplit, 'true', expected_values)
  end

  private

  def _lighting_upgrade(args_hash)
    puts "\twindow upgrade..."
    args_hash['window_ufactor'] = 0.29
    args_hash['window_shgc'] = 0.26
  end

  def _heating_system_upgrade(args_hash, expected_capacities)
    puts "\theating system upgrade..."
    args_hash['heating_system_type'] = HPXML::HVACTypeFurnace
    args_hash['heat_pump_type'] = 'none'
    expected_capacities['heating_system_heating_capacity'] = nil
    expected_capacities['heat_pump_heating_capacity'] = nil
    expected_capacities['heat_pump_cooling_capacity'] = nil
    expected_capacities['heat_pump_backup_heating_capacity'] = nil
  end

  def _heating_system_2_upgrade(args_hash, expected_capacities)
    puts "\tsecondary heating system upgrade..."
    args_hash['heating_system_2_type'] = HPXML::HVACTypeFireplace
    expected_capacities['heating_system_2_heating_capacity'] = nil
  end

  def _cooling_system_upgrade(args_hash, expected_capacities)
    puts "\tcooling system upgrade..."
    args_hash['cooling_system_type'] = HPXML::HVACTypeCentralAirConditioner
    args_hash['heat_pump_type'] = 'none'
    expected_capacities['cooling_system_cooling_capacity'] = nil
    expected_capacities['heat_pump_heating_capacity'] = nil
    expected_capacities['heat_pump_cooling_capacity'] = nil
    expected_capacities['heat_pump_backup_heating_capacity'] = nil
  end

  def _heat_pump_upgrade(args_hash, expected_capacities)
    puts "\theat pump upgrade..."
    args_hash['heating_system_type'] = 'none'
    args_hash['cooling_system_type'] = 'none'
    args_hash['heat_pump_type'] = HPXML::HVACTypeHeatPumpAirToAir
    expected_capacities['heating_system_heating_capacity'] = nil
    expected_capacities['cooling_system_cooling_capacity'] = nil
    expected_capacities['heat_pump_heating_capacity'] = nil
    expected_capacities['heat_pump_cooling_capacity'] = nil
    expected_capacities['heat_pump_backup_heating_capacity'] = nil
  end

  def _test_measure(osw_file)
    require 'json'

    this_dir = File.dirname(__FILE__)
    osw = File.absolute_path("#{this_dir}/#{osw_file}")

    measures = {}

    osw_hash = JSON.parse(File.read(osw))
    measures_dir = File.join(File.dirname(__FILE__), osw_hash['measure_paths'][0])
    osw_hash['steps'].each do |step|
      measures[step['measure_dir_name']] = [step['arguments']]
    end

    model = OpenStudio::Model::Model.new
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)

    # Apply measure
    success = apply_measures(measures_dir, measures, runner, model)

    # Report warnings/errors
    runner.result.stepWarnings.each do |s|
      puts "Warning: #{s}"
    end
    runner.result.stepErrors.each do |s|
      puts "Error: #{s}"
    end

    assert(success)
  end

  def _test_retaining_capacities(args_hash, expected_capacities)
    this_dir = File.dirname(__FILE__)
    hpxml_path = File.join(this_dir, '../../UpgradeCosts/tests/in.xml')
    hpxml = HPXML.new(hpxml_path: hpxml_path)

    # Create instance of the measure
    measure = ApplyUpgrade.new

    hpxml.buildings.each do |hpxml_bldg|
      # Check for correct capacity values
      system_upgrades = measure.get_system_upgrades(hpxml_bldg, [], args_hash)
      actual_capacities = measure.get_system_capacities(hpxml_bldg, system_upgrades)

      expected_capacities.each do |str, val|
        if val.nil?
          assert_nil(actual_capacities[str])
        else
          assert_equal(val, actual_capacities[str])
        end
      end
    end
  end

  def _test_heat_pump_backup(heat_pump_type, heat_pump_is_ducted, expected_values)
    this_dir = File.dirname(__FILE__)
    hpxml_path = File.join(this_dir, '../../UpgradeCosts/tests/in.xml')
    hpxml = HPXML.new(hpxml_path: hpxml_path)

    # Create instance of the measure
    measure = ApplyUpgrade.new

    hpxml.buildings.each do |hpxml_bldg|
      heating_system = measure.get_heating_system(hpxml_bldg)
      if heating_system.nil?
        assert_nil(expected_values['heat_pump_backup_type'])
        puts "\thpxml.heating_systems.size=#{hpxml_bldg.heating_systems.size}..."
        return
      end

      puts "\theat_pump_type='#{heat_pump_type}', heat_pump_is_ducted='#{heat_pump_is_ducted}'..."

      heat_pump_backup_type = measure.get_heat_pump_backup_type(heating_system, heat_pump_type, heat_pump_is_ducted)
      actual_values = measure.get_heat_pump_backup_values(heating_system)
      actual_values['heat_pump_backup_type'] = heat_pump_backup_type

      expected_values.each do |str, val|
        if val.nil?
          assert_nil(actual_values[str])
        else
          assert_equal(val, actual_values[str])
        end
      end
    end
  end
end
