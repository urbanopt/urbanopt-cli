# frozen_string_literal: true

class EPlus
  # Constants
  FuelTypeElectricity = 'electricity'
  FuelTypeNaturalGas = 'NaturalGas'
  FuelTypeOil = 'FuelOilNo2'
  FuelTypePropane = 'Propane'
  FuelTypeWoodCord = 'OtherFuel1'
  FuelTypeWoodPellets = 'OtherFuel2'
  FuelTypeCoal = 'Coal'

  def self.input_fuel_map(hpxml_fuel)
    # Name of fuel used as inputs to E+ objects
    if [HPXML::FuelTypeElectricity].include? hpxml_fuel
      FuelTypeElectricity
    elsif [HPXML::FuelTypeNaturalGas].include? hpxml_fuel
      FuelTypeNaturalGas
    elsif [HPXML::FuelTypeOil,
           HPXML::FuelTypeOil1,
           HPXML::FuelTypeOil2,
           HPXML::FuelTypeOil4,
           HPXML::FuelTypeOil5or6,
           HPXML::FuelTypeDiesel,
           HPXML::FuelTypeKerosene].include? hpxml_fuel
      FuelTypeOil
    elsif [HPXML::FuelTypePropane].include? hpxml_fuel
      FuelTypePropane
    elsif [HPXML::FuelTypeWoodCord].include? hpxml_fuel
      FuelTypeWoodCord
    elsif [HPXML::FuelTypeWoodPellets].include? hpxml_fuel
      FuelTypeWoodPellets
    elsif [HPXML::FuelTypeCoal,
           HPXML::FuelTypeCoalAnthracite,
           HPXML::FuelTypeCoalBituminous,
           HPXML::FuelTypeCoke].include? hpxml_fuel
      FuelTypeCoal
    else
      raise "Unexpected HPXML fuel '#{hpxml_fuel}'."
    end
  end

  def self.output_fuel_map(ep_fuel)
    # Name of fuel used in E+ outputs
    if ep_fuel == FuelTypeElectricity
      'Electric'
    elsif ep_fuel == FuelTypeNaturalGas
      'Gas'
    elsif ep_fuel == FuelTypeOil
      'FuelOil#2'
    else
      ep_fuel
    end
  end
end
