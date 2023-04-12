# Add classes or functions here than can be used across a variety of our python classes and modules.
require_relative 'constants'
require_relative 'unit_conversions'

class HelperMethods
  def self.eplus_fuel_map(fuel)
    if fuel == Constants.FuelTypeElectric
      return 'Electricity'
    elsif fuel == Constants.FuelTypeGas
      return 'NaturalGas'
    elsif fuel == Constants.FuelTypeOil
      return 'FuelOil#1'
    elsif fuel == Constants.FuelTypePropane
      return 'PropaneGas'
    elsif fuel == Constants.FuelTypeWood
      return 'OtherFuel1'
    end
  end

  def self.reverse_eplus_fuel_map(fuel)
    case fuel
    when 'Electricity'
      return Constants.FuelTypeElectric
    when 'NaturalGas'
      return Constants.FuelTypeGas
    when 'FuelOil#1'
      return Constants.FuelTypeOil
    when 'PropaneGas'
      return Constants.FuelTypePropane
    when 'OtherFuel1'
      return Constants.FuelTypeWood
    end
  end

  def self.reverse_openstudio_fuel_map(fuel)
    case fuel
    when 'Electricity'
      return Constants.FuelTypeElectric
    when 'Gas'
      return Constants.FuelTypeGas
    when 'FuelOil#1'
      return Constants.FuelTypeOil
    when 'Propane'
      return Constants.FuelTypePropane
    end
  end

  def self.remove_unused_constructions_and_materials(model, runner)
    # Code from https://bcl.nrel.gov/node/82267 (remove_orphan_objects_and_unused_resources measure)
    model.getConstructions.sort.each do |resource|
      if resource.directUseCount == 0
        runner.registerInfo("Removed construction '#{resource.name}' because it was orphaned.")
        resource.remove
      end
    end

    model.getMaterials.sort.each do |resource|
      if resource.directUseCount == 0
        runner.registerInfo("Removed material '#{resource.name}' because it was orphaned.")
        resource.remove
      end
    end
  end

  def self.state_code_map
    return { 'Alabama' => 'AL', 'Alaska' => 'AK', 'Arizona' => 'AZ', 'Arkansas' => 'AR', 'California' => 'CA', 'Colorado' => 'CO', 'Connecticut' => 'CT', 'Delaware' => 'DE', 'District of Columbia' => 'DC',
             'Florida' => 'FL', 'Georgia' => 'GA', 'Hawaii' => 'HI', 'Idaho' => 'ID', 'Illinois' => 'IL', 'Indiana' => 'IN', 'Iowa' => 'IA', 'Kansas' => 'KS', 'Kentucky' => 'KY', 'Louisiana' => 'LA',
             'Maine' => 'ME', 'Maryland' => 'MD', 'Massachusetts' => 'MA', 'Michigan' => 'MI', 'Minnesota' => 'MN', 'Mississippi' => 'MS', 'Missouri' => 'MO', 'Montana' => 'MT', 'Nebraska' => 'NE', 'Nevada' => 'NV',
             'New Hampshire' => 'NH', 'New Jersey' => 'NJ', 'New Mexico' => 'NM', 'New York' => 'NY', 'North Carolina' => 'NC', 'North Dakota' => 'ND', 'Ohio' => 'OH', 'Oklahoma' => 'OK',
             'Oregon' => 'OR', 'Pennsylvania' => 'PA', 'Puerto Rico' => 'PR', 'Rhode Island' => 'RI', 'South Carolina' => 'SC', 'South Dakota' => 'SD', 'Tennessee' => 'TN', 'Texas' => 'TX',
             'Utah' => 'UT', 'Vermont' => 'VT', 'Virginia' => 'VA', 'Washington' => 'WA', 'West Virginia' => 'WV', 'Wisconsin' => 'WI', 'Wyoming' => 'WY' }
  end
end

class MathTools
  def self.valid_float?(str)
    !Float(str).nil?
  rescue StandardError
    false
  end

  def self.interp2(x, x0, x1, f0, f1)
    '
    Returns the linear interpolation between two results.
    '

    return f0 + ((x - x0) / (x1 - x0)) * (f1 - f0)
  end

  def self.interp4(x, y, x1, x2, y1, y2, fx1y1, fx1y2, fx2y1, fx2y2)
    '
    Returns the bilinear interpolation between four results.
    '

    return (fx1y1 / ((x2 - x1) * (y2 - y1))) * (x2 - x) * (y2 - y) \
          + (fx2y1 / ((x2 - x1) * (y2 - y1))) * (x - x1) * (y2 - y) \
          + (fx1y2 / ((x2 - x1) * (y2 - y1))) * (x2 - x) * (y - y1) \
          + (fx2y2 / ((x2 - x1) * (y2 - y1))) * (x - x1) * (y - y1)
  end

  def self.biquadratic(x, y, c)
    '
    Description:
    ------------
        Calculate the result of a biquadratic polynomial with independent variables
        x and y, and a list of coefficients, c:
        z = c[1] + c[2]*x + c[3]*x**2 + c[4]*y + c[5]*y**2 + c[6]*x*y
    Inputs:
    -------
        x       float      independent variable 1
        y       float      independent variable 2
        c       tuple      list of 6 coeffients [floats]
    Outputs:
    --------
        z       float      result of biquadratic polynomial
    '
    if c.length != 6
      puts 'Error: There must be 6 coefficients in a biquadratic polynomial'
    end
    z = c[0] + c[1] * x + c[2] * x**2 + c[3] * y + c[4] * y**2 + c[5] * y * x
    return z
  end

  def self.quadratic(x, c)
    '
    Description:
    ------------
        Calculate the result of a quadratic polynomial with independent variable
        x and a list of coefficients, c:

        y = c[1] + c[2]*x + c[3]*x**2

    Inputs:
    -------
        x       float      independent variable
        c       tuple      list of 6 coeffients [floats]

    Outputs:
    --------
        y       float      result of biquadratic polynomial
    '
    if c.size != 3
      puts 'Error: There must be 3 coefficients in a quadratic polynomial'
    end
    y = c[0] + c[1] * x + c[2] * x**2

    return y
  end

  def self.bicubic(x, y, c)
    '
    Description:
    ------------
        Calculate the result of a bicubic polynomial with independent variables
        x and y, and a list of coefficients, c:

        z = c[1] + c[2]*x + c[3]*y + c[4]*x**2 + c[5]*x*y + c[6]*y**2 + \
            c[7]*x**3 + c[8]*y*x**2 + c[9]*x*y**2 + c[10]*y**3

    Inputs:
    -------
        x       float      independent variable 1
        y       float      independent variable 2
        c       tuple      list of 10 coeffients [floats]

    Outputs:
    --------
        z       float      result of bicubic polynomial
    '
    if c.size != 10
      puts 'Error: There must be 10 coefficients in a bicubic polynomial'
    end
    z = c[0] + c[1] * x + c[2] * y + c[3] * x**2 + c[4] * x * y + c[5] * y**2 + \
        c[6] * x**3 + c[7] * y * x**2 + c[8] * x * y**2 + c[9] * y**3

    return z
  end

  def self.Iterate(x0, f0, x1, f1, x2, f2, icount, cvg)
    '
    Description:
    ------------
        Determine if a guess is within tolerance for convergence
        if not, output a new guess using the Newton-Raphson method
    Source:
    -------
        Based on XITERATE f77 code in ResAC (Brandemuehl)
    Inputs:
    -------
        x0      float    current guess value
        f0      float    value of function f(x) at current guess value
        x1,x2   floats   previous two guess values, used to create quadratic
                         (or linear fit)
        f1,f2   floats   previous two values of f(x)
        icount  int      iteration count
        cvg     bool     Has the iteration reached convergence?
    Outputs:
    --------
        x_new   float    new guess value
        cvg     bool     Has the iteration reached convergence?
        x1,x2   floats   updated previous two guess values, used to create quadratic
                         (or linear fit)
        f1,f2   floats   updated previous two values of f(x)
    Example:
    --------
        # Find a value of x that makes f(x) equal to some specific value f:
        # initial guess (all values of x)
        x = 1.0
        x1 = x
        x2 = x
        # initial error
        error = f - f(x)
        error1 = error
        error2 = error
        itmax = 50  # maximum iterations
        cvg = False # initialize convergence to "False"
        for i in range(1,itmax+1):
            error = f - f(x)
            x,cvg,x1,error1,x2,error2 = \
                                     Iterate(x,error,x1,error1,x2,error2,i,cvg)
            if cvg:
                break
        if cvg:
            print "x converged after", i, :iterations"
        else:
            print "x did NOT converge after", i, "iterations"
        print "x, when f(x) is", f,"is", x
    '

    tolRel = 1e-5
    dx = 0.1

    # Test for convergence
    if (((x0 - x1).abs < tolRel * [x0.abs, Constants.small].max) && (icount != 1)) || (f0 == 0)
      x_new = x0
      cvg = true
    else
      cvg = false

      case icount
      when 1 # Perturbation
        mode = 1
      when 2 # Linear fit
        mode = 2
      else # Quadratic fit
        mode = 3
      end

      if mode == 3
        # Quadratic fit
        if x0 == x1 # If two xi are equal, use a linear fit
          x1 = x2
          f1 = f2
          mode = 2
        elsif x0 == x2 # If two xi are equal, use a linear fit
          mode = 2
        else
          # Set up quadratic coefficients
          c = ((f2 - f0) / (x2 - x0) - (f1 - f0) / (x1 - x0)) / (x2 - x1)
          b = (f1 - f0) / (x1 - x0) - (x1 + x0) * c
          a = f0 - (b + c * x0) * x0

          if c.abs < Constants.small # If points are co-linear, use linear fit
            mode = 2
          elsif ((a + (b + c * x1) * x1 - f1) / f1).abs > Constants.small
            # If coefficients do not accurately predict data points due to
            # round-off, use linear fit
            mode = 2
          else
            d = b**2 - 4.0 * a * c # calculate discriminant to check for real roots
            if d < 0.0 # if no real roots, use linear fit
              mode = 2
            else
              if d > 0.0 # if real unequal roots, use nearest root to recent guess
                x_new = (-b + Math.sqrt(d)) / (2 * c)
                x_other = -x_new - b / c
                if (x_new - x0).abs > (x_other - x0).abs
                  x_new = x_other
                end
              else # If real equal roots, use that root
                x_new = -b / (2 * c)
              end

              if (f1 * f0 > 0) && (f2 * f0 > 0) # If the previous two f(x) were the same sign as the new
                if f2.abs > f1.abs
                  x2 = x1
                  f2 = f1
                end
              else
                if f2 * f0 > 0
                  x2 = x1
                  f2 = f1
                end
              end
              x1 = x0
              f1 = f0
            end
          end
        end
      end

      if mode == 2
        # Linear Fit
        m = (f1 - f0) / (x1 - x0)
        if m == 0 # If slope is zero, use perturbation
          mode = 1
        else
          x_new = x0 - f0 / m
          x2 = x1
          f2 = f1
          x1 = x0
          f1 = f0
        end
      end

      if mode == 1
        # Perturbation
        if x0.abs > Constants.small
          x_new = x0 * (1 + dx)
        else
          x_new = dx
        end
        x2 = x1
        f2 = f1
        x1 = x0
        f1 = f0
      end
    end
    return x_new, cvg, x1, f1, x2, f2
  end
end

class OutputVariables
  def self.zone_indoor_air_wetbulb_temperature(tdb, w, pr)
    tdb = tdb.collect { |n| UnitConversions.convert(n, 'C', 'F') } # degF
    pr = pr.collect { |n| UnitConversions.convert(n, 'pa', 'psi') } # psi
    twb = [tdb, w, pr].transpose.collect { |x, y, z| Psychrometrics.Twb_fT_w_P(x, y, z) } # degF
    twb = twb.collect { |n| UnitConversions.convert(n, 'F', 'C') } # degC
    return twb # degC
  end

  def self.wetbulb_globe_temperature(twb, mrt)
    twbg = [twb.collect { |n| n * 0.7 }, mrt.collect { |n| n * 0.3 }].transpose.map { |x| x.reduce(:+) } # degC
    return twbg # degC
  end
end

class OutputMeters
  def initialize(model, runner, reporting_frequency, include_enduse_subcategories = false)
    require 'matrix'

    @model = model
    @runner = runner
    @reporting_frequency_os = reporting_frequency
    @include_enduse_subcategories = include_enduse_subcategories

    @steps_per_hour = 6
    if @model.getSimulationControl.timestep.is_initialized
      @steps_per_hour = @model.getSimulationControl.timestep.get.numberOfTimestepsPerHour
    end

    reporting_frequency_map = {
      'Timestep' => 'Zone Timestep',
      'Hourly' => 'Hourly',
      'Daily' => 'Daily',
      'Monthly' => 'Monthly',
      'RunPeriod' => 'Run Period'
    }
    @reporting_frequency_eplus = reporting_frequency_map[@reporting_frequency_os]
  end

  def steps_per_hour
    return @steps_per_hour
  end

  def electricity(sql_file, ann_env_pd)
    env_period_ix_query = "SELECT EnvironmentPeriodIndex FROM EnvironmentPeriods WHERE EnvironmentName='#{ann_env_pd}'"
    env_period_ix = sql_file.execAndReturnFirstInt(env_period_ix_query).get
    num_ts = get_num_ts(sql_file)

    # Get meters that aren't tied to units (i.e., are metered at the building level)
    modeledCentralElectricityHeating = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:ELECTRICITYHEATING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    modeledCentralElectricityCooling = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:ELECTRICITYCOOLING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    modeledCentralElectricityExteriorLighting = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:ELECTRICITYEXTERIORLIGHTING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    modeledCentralElectricityExteriorHolidayLighting = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:ELECTRICITYEXTERIORHOLIDAYLIGHTING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    modeledCentralElectricityGarageLighting = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:ELECTRICITYGARAGELIGHTING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    modeledCentralElectricityPumpsHeating = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:ELECTRICITYPUMPSHEATING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    modeledCentralElectricityPumpsCooling = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:ELECTRICITYPUMPSCOOLING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    modeledCentralElectricityInteriorEquipment = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:ELECTRICITYINTERIOREQUIPMENT') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    modeledCentralElectricityPhotovoltaics = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:ELECTRICITYPHOTOVOLTAICS') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    modeledCentralElectricityExtraRefrigerator = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:ELECTRICITYEXTRAREFRIGERATOR') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    modeledCentralElectricityFreezer = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:ELECTRICITYFREEZER') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")

    # Separate these from non central systems
    centralElectricityHeating = Vector.elements(Array.new(num_ts, 0.0))
    centralElectricityCooling = Vector.elements(Array.new(num_ts, 0.0))
    centralElectricityPumpsHeating = Vector.elements(Array.new(num_ts, 0.0))
    centralElectricityPumpsCooling = Vector.elements(Array.new(num_ts, 0.0))

    # Get meters that are tied to units, and apportion building level meters to these
    electricityHeating = Vector.elements(Array.new(num_ts, 0.0))
    electricityCooling = Vector.elements(Array.new(num_ts, 0.0))
    electricityInteriorLighting = Vector.elements(Array.new(num_ts, 0.0))
    electricityExteriorLighting = Vector.elements(Array.new(num_ts, 0.0))
    electricityExteriorHolidayLighting = Vector.elements(Array.new(num_ts, 0.0))
    electricityGarageLighting = Vector.elements(Array.new(num_ts, 0.0))
    electricityInteriorEquipment = Vector.elements(Array.new(num_ts, 0.0))
    electricityFansHeating = Vector.elements(Array.new(num_ts, 0.0))
    electricityFansCooling = Vector.elements(Array.new(num_ts, 0.0))
    electricityPumpsHeating = Vector.elements(Array.new(num_ts, 0.0))
    electricityPumpsCooling = Vector.elements(Array.new(num_ts, 0.0))
    electricityWaterSystems = Vector.elements(Array.new(num_ts, 0.0))
    electricityPhotovoltaics = Vector.elements(Array.new(num_ts, 0.0))
    electricityRefrigerator = Vector.elements(Array.new(num_ts, 0.0))
    electricityClothesWasher = Vector.elements(Array.new(num_ts, 0.0))
    electricityClothesDryer = Vector.elements(Array.new(num_ts, 0.0))
    electricityCookingRange = Vector.elements(Array.new(num_ts, 0.0))
    electricityDishwasher = Vector.elements(Array.new(num_ts, 0.0))
    electricityPlugLoads = Vector.elements(Array.new(num_ts, 0.0))
    electricityHouseFan = Vector.elements(Array.new(num_ts, 0.0))
    electricityRangeFan = Vector.elements(Array.new(num_ts, 0.0))
    electricityBathFan = Vector.elements(Array.new(num_ts, 0.0))
    electricityCeilingFan = Vector.elements(Array.new(num_ts, 0.0))
    electricityExtraRefrigerator = Vector.elements(Array.new(num_ts, 0.0))
    electricityFreezer = Vector.elements(Array.new(num_ts, 0.0))
    electricityPoolHeater = Vector.elements(Array.new(num_ts, 0.0))
    electricityPoolPump = Vector.elements(Array.new(num_ts, 0.0))
    electricityHotTubHeater = Vector.elements(Array.new(num_ts, 0.0))
    electricityHotTubPump = Vector.elements(Array.new(num_ts, 0.0))
    electricityWellPump = Vector.elements(Array.new(num_ts, 0.0))
    electricityRecircPump = Vector.elements(Array.new(num_ts, 0.0))
    electricityVehicle = Vector.elements(Array.new(num_ts, 0.0))

    # Get building units
    units = Geometry.get_building_units(@model, @runner)
    if units.nil?
      return false
    end

    units.each do |unit|
      unit_name = unit.name.to_s.upcase
      units_represented = get_units_represented(unit)

      electricityHeating = add_unit(sql_file, electricityHeating, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYHEATING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      centralElectricityHeating = apportion_central(centralElectricityHeating, modeledCentralElectricityHeating, units_represented, units.length)
      electricityCooling = add_unit(sql_file, electricityCooling, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYCOOLING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      centralElectricityCooling = apportion_central(centralElectricityCooling, modeledCentralElectricityCooling, units_represented, units.length)
      electricityInteriorLighting = add_unit(sql_file, electricityInteriorLighting, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYINTERIORLIGHTING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      electricityExteriorLighting = apportion_central(electricityExteriorLighting, modeledCentralElectricityExteriorLighting, units_represented, units.length)
      electricityExteriorHolidayLighting = apportion_central(electricityExteriorHolidayLighting, modeledCentralElectricityExteriorHolidayLighting, units_represented, units.length)
      electricityGarageLighting = apportion_central(electricityGarageLighting, modeledCentralElectricityGarageLighting, units_represented, units.length)
      electricityInteriorEquipment = add_unit(sql_file, electricityInteriorEquipment, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYINTERIOREQUIPMENT') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      electricityInteriorEquipment = apportion_central(electricityInteriorEquipment, modeledCentralElectricityInteriorEquipment, units_represented, units.length)
      electricityFansHeating = add_unit(sql_file, electricityFansHeating, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYFANSHEATING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      electricityFansCooling = add_unit(sql_file, electricityFansCooling, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYFANSCOOLING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      electricityPumpsHeating = add_unit(sql_file, electricityPumpsHeating, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYPUMPSHEATING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      centralElectricityPumpsHeating = apportion_central(centralElectricityPumpsHeating, modeledCentralElectricityPumpsHeating, units_represented, units.length)
      electricityPumpsCooling = add_unit(sql_file, electricityPumpsCooling, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYPUMPSCOOLING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      centralElectricityPumpsCooling = apportion_central(centralElectricityPumpsCooling, modeledCentralElectricityPumpsCooling, units_represented, units.length)
      electricityWaterSystems = add_unit(sql_file, electricityWaterSystems, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYWATERSYSTEMS') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")

      if @include_enduse_subcategories
        electricityRefrigerator = add_unit(sql_file, electricityRefrigerator, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYREFRIGERATOR') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityClothesWasher = add_unit(sql_file, electricityClothesWasher, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYCLOTHESWASHER') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityClothesDryer = add_unit(sql_file, electricityClothesDryer, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYCLOTHESDRYER') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityCookingRange = add_unit(sql_file, electricityCookingRange, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYCOOKINGRANGE') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityDishwasher = add_unit(sql_file, electricityDishwasher, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYDISHWASHER') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityPlugLoads = add_unit(sql_file, electricityPlugLoads, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYPLUGLOADS') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityHouseFan = add_unit(sql_file, electricityHouseFan, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYHOUSEFAN') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityRangeFan = add_unit(sql_file, electricityRangeFan, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYRANGEFAN') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityBathFan = add_unit(sql_file, electricityBathFan, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYBATHFAN') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityCeilingFan = add_unit(sql_file, electricityCeilingFan, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYCEILINGFAN') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityExtraRefrigerator = add_unit(sql_file, electricityExtraRefrigerator, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYEXTRAREFRIGERATOR') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityExtraRefrigerator = apportion_central(electricityExtraRefrigerator, modeledCentralElectricityExtraRefrigerator, units_represented, units.length)
        electricityFreezer = add_unit(sql_file, electricityFreezer, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYFREEZER') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityFreezer = apportion_central(electricityFreezer, modeledCentralElectricityFreezer, units_represented, units.length)
        electricityPoolHeater = add_unit(sql_file, electricityPoolHeater, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYPOOLHEATER') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityPoolPump = add_unit(sql_file, electricityPoolPump, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYPOOLPUMP') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityHotTubHeater = add_unit(sql_file, electricityHotTubHeater, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYHOTTUBHEATER') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityHotTubPump = add_unit(sql_file, electricityHotTubPump, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYHOTTUBPUMP') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityWellPump = add_unit(sql_file, electricityWellPump, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYWELLPUMP') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityRecircPump = add_unit(sql_file, electricityRecircPump, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYRECIRCPUMP') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        electricityVehicle = add_unit(sql_file, electricityVehicle, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:ELECTRICITYVEHICLE') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      end
    end

    @electricity = Electricity.new
    @electricity.heating = electricityHeating
    @electricity.central_heating = centralElectricityHeating
    @electricity.cooling = electricityCooling
    @electricity.central_cooling = centralElectricityCooling
    @electricity.interior_lighting = electricityInteriorLighting
    @electricity.exterior_lighting = electricityExteriorLighting
    @electricity.exterior_holiday_lighting = electricityExteriorHolidayLighting
    @electricity.garage_lighting = electricityGarageLighting
    @electricity.interior_equipment = electricityInteriorEquipment
    @electricity.fans_heating = electricityFansHeating
    @electricity.fans_cooling = electricityFansCooling
    @electricity.pumps_heating = electricityPumpsHeating
    @electricity.central_pumps_heating = centralElectricityPumpsHeating
    @electricity.pumps_cooling = electricityPumpsCooling
    @electricity.central_pumps_cooling = centralElectricityPumpsCooling
    @electricity.water_systems = electricityWaterSystems
    @electricity.photovoltaics = -1.0 * modeledCentralElectricityPhotovoltaics

    if @include_enduse_subcategories
      @electricity.refrigerator = electricityRefrigerator
      @electricity.clothes_washer = electricityClothesWasher
      @electricity.clothes_dryer = electricityClothesDryer
      @electricity.cooking_range = electricityCookingRange
      @electricity.dishwasher = electricityDishwasher
      @electricity.plug_loads = electricityPlugLoads
      @electricity.house_fan = electricityHouseFan
      @electricity.range_fan = electricityRangeFan
      @electricity.bath_fan = electricityBathFan
      @electricity.ceiling_fan = electricityCeilingFan
      @electricity.extra_refrigerator = electricityExtraRefrigerator
      @electricity.freezer = electricityFreezer
      @electricity.pool_heater = electricityPoolHeater
      @electricity.pool_pump = electricityPoolPump
      @electricity.hot_tub_heater = electricityHotTubHeater
      @electricity.hot_tub_pump = electricityHotTubPump
      @electricity.well_pump = electricityWellPump
      @electricity.recirc_pump = electricityRecircPump
      @electricity.vehicle = electricityVehicle
    end

    @electricity.total_end_uses = @electricity.heating +
                                  @electricity.central_heating +
                                  @electricity.cooling +
                                  @electricity.central_cooling +
                                  @electricity.interior_lighting +
                                  @electricity.exterior_lighting +
                                  @electricity.exterior_holiday_lighting +
                                  @electricity.garage_lighting +
                                  @electricity.interior_equipment +
                                  @electricity.fans_heating +
                                  @electricity.fans_cooling +
                                  @electricity.pumps_heating +
                                  @electricity.central_pumps_heating +
                                  @electricity.pumps_cooling +
                                  @electricity.central_pumps_cooling +
                                  @electricity.water_systems

    return @electricity
  end

  def natural_gas(sql_file, ann_env_pd)
    env_period_ix_query = "SELECT EnvironmentPeriodIndex FROM EnvironmentPeriods WHERE EnvironmentName='#{ann_env_pd}'"
    env_period_ix = sql_file.execAndReturnFirstInt(env_period_ix_query).get
    num_ts = get_num_ts(sql_file)

    # Get meters that aren't tied to units (i.e., are metered at the building level)
    modeledCentralNaturalGasHeating = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:NATURALGASHEATING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    modeledCentralNaturalGasInteriorEquipment = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:NATURALGASINTERIOREQUIPMENT') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    modeledCentralNaturalGasGrill = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:NATURALGASGRILL') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    modeledCentralNaturalGasLighting = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:NATURALGASLIGHTING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    modeledCentralNaturalGasFireplace = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:NATURALGASFIREPLACE') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")

    # Separate these from non central systems
    centralNaturalGasHeating = Vector.elements(Array.new(num_ts, 0.0))

    # Get meters that are tied to units, and apportion building level meters to these
    naturalGasHeating = Vector.elements(Array.new(num_ts, 0.0))
    naturalGasInteriorEquipment = Vector.elements(Array.new(num_ts, 0.0))
    naturalGasWaterSystems = Vector.elements(Array.new(num_ts, 0.0))
    naturalGasClothesDryer = Vector.elements(Array.new(num_ts, 0.0))
    naturalGasCookingRange = Vector.elements(Array.new(num_ts, 0.0))
    naturalGasPoolHeater = Vector.elements(Array.new(num_ts, 0.0))
    naturalGasHotTubHeater = Vector.elements(Array.new(num_ts, 0.0))
    naturalGasGrill = Vector.elements(Array.new(num_ts, 0.0))
    naturalGasLighting = Vector.elements(Array.new(num_ts, 0.0))
    naturalGasFireplace = Vector.elements(Array.new(num_ts, 0.0))

    # Get building units
    units = Geometry.get_building_units(@model, @runner)
    if units.nil?
      return false
    end

    units.each do |unit|
      unit_name = unit.name.to_s.upcase
      units_represented = get_units_represented(unit)

      naturalGasHeating = add_unit(sql_file, naturalGasHeating, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:NATURALGASHEATING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      centralNaturalGasHeating = apportion_central(centralNaturalGasHeating, modeledCentralNaturalGasHeating, units_represented, units.length)
      naturalGasInteriorEquipment = add_unit(sql_file, naturalGasInteriorEquipment, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:NATURALGASINTERIOREQUIPMENT') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      naturalGasInteriorEquipment = apportion_central(naturalGasInteriorEquipment, modeledCentralNaturalGasInteriorEquipment, units_represented, units.length)
      naturalGasWaterSystems = add_unit(sql_file, naturalGasWaterSystems, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:NATURALGASWATERSYSTEMS') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")

      if @include_enduse_subcategories
        naturalGasClothesDryer = add_unit(sql_file, naturalGasClothesDryer, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:NATURALGASCLOTHESDRYER') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        naturalGasCookingRange = add_unit(sql_file, naturalGasCookingRange, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:NATURALGASCOOKINGRANGE') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        naturalGasPoolHeater = add_unit(sql_file, naturalGasPoolHeater, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:NATURALGASPOOLHEATER') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        naturalGasHotTubHeater = add_unit(sql_file, naturalGasHotTubHeater, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:NATURALGASHOTTUBHEATER') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        naturalGasGrill = add_unit(sql_file, naturalGasGrill, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:NATURALGASGRILL') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        naturalGasGrill = apportion_central(naturalGasGrill, modeledCentralNaturalGasGrill, units_represented, units.length)
        naturalGasLighting = add_unit(sql_file, naturalGasLighting, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:NATURALGASLIGHTING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        naturalGasLighting = apportion_central(naturalGasLighting, modeledCentralNaturalGasLighting, units_represented, units.length)
        naturalGasFireplace = add_unit(sql_file, naturalGasFireplace, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:NATURALGASFIREPLACE') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        naturalGasFireplace = apportion_central(naturalGasFireplace, modeledCentralNaturalGasFireplace, units_represented, units.length)
      end
    end

    @natural_gas = NaturalGas.new
    @natural_gas.heating = naturalGasHeating
    @natural_gas.central_heating = centralNaturalGasHeating
    @natural_gas.interior_equipment = naturalGasInteriorEquipment
    @natural_gas.water_systems = naturalGasWaterSystems

    if @include_enduse_subcategories
      @natural_gas.clothes_dryer = naturalGasClothesDryer
      @natural_gas.cooking_range = naturalGasCookingRange
      @natural_gas.pool_heater = naturalGasPoolHeater
      @natural_gas.hot_tub_heater = naturalGasHotTubHeater
      @natural_gas.grill = naturalGasGrill
      @natural_gas.lighting = naturalGasLighting
      @natural_gas.fireplace = naturalGasFireplace
    end

    @natural_gas.total_end_uses = @natural_gas.heating +
                                  @natural_gas.central_heating +
                                  @natural_gas.interior_equipment +
                                  @natural_gas.water_systems

    return @natural_gas
  end

  def fuel_oil(sql_file, ann_env_pd)
    env_period_ix_query = "SELECT EnvironmentPeriodIndex FROM EnvironmentPeriods WHERE EnvironmentName='#{ann_env_pd}'"
    env_period_ix = sql_file.execAndReturnFirstInt(env_period_ix_query).get
    num_ts = get_num_ts(sql_file)

    # Get meters that aren't tied to units (i.e., are metered at the building level)
    modeledCentralFuelOilHeating = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:FUELOILHEATING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")

    # Separate these from non central systems
    centralFuelOilHeating = Vector.elements(Array.new(num_ts, 0.0))

    # Get meters that are tied to units, and apportion building level meters to these
    fuelOilHeating = Vector.elements(Array.new(num_ts, 0.0))
    fuelOilWaterSystems = Vector.elements(Array.new(num_ts, 0.0))

    # Get building units
    units = Geometry.get_building_units(@model, @runner)
    if units.nil?
      return false
    end

    units.each do |unit|
      unit_name = unit.name.to_s.upcase
      units_represented = get_units_represented(unit)

      fuelOilHeating = add_unit(sql_file, fuelOilHeating, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:FUELOILHEATING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      centralFuelOilHeating = apportion_central(centralFuelOilHeating, modeledCentralFuelOilHeating, units_represented, units.length)
      fuelOilWaterSystems = add_unit(sql_file, fuelOilWaterSystems, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:FUELOILWATERSYSTEMS') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    end

    @fuel_oil = FuelOil.new
    @fuel_oil.heating = fuelOilHeating
    @fuel_oil.central_heating = centralFuelOilHeating
    @fuel_oil.water_systems = fuelOilWaterSystems

    @fuel_oil.total_end_uses = @fuel_oil.heating +
                               @fuel_oil.central_heating +
                               @fuel_oil.water_systems
    return @fuel_oil
  end

  def propane(sql_file, ann_env_pd)
    env_period_ix_query = "SELECT EnvironmentPeriodIndex FROM EnvironmentPeriods WHERE EnvironmentName='#{ann_env_pd}'"
    env_period_ix = sql_file.execAndReturnFirstInt(env_period_ix_query).get
    num_ts = get_num_ts(sql_file)

    # Get meters that aren't tied to units (i.e., are metered at the building level)
    modeledCentralPropaneHeating = add_unit(sql_file, Vector.elements(Array.new(num_ts, 0.0)), 1, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('CENTRAL:PROPANEHEATING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")

    # Separate these from non central systems
    centralPropaneHeating = Vector.elements(Array.new(num_ts, 0.0))

    # Get meters that are tied to units, and apportion building level meters to these
    propaneHeating = Vector.elements(Array.new(num_ts, 0.0))
    propaneInteriorEquipment = Vector.elements(Array.new(num_ts, 0.0))
    propaneWaterSystems = Vector.elements(Array.new(num_ts, 0.0))
    propaneClothesDryer = Vector.elements(Array.new(num_ts, 0.0))
    propaneCookingRange = Vector.elements(Array.new(num_ts, 0.0))

    # Get building units
    units = Geometry.get_building_units(@model, @runner)
    if units.nil?
      return false
    end

    units.each do |unit|
      unit_name = unit.name.to_s.upcase
      units_represented = get_units_represented(unit)

      propaneHeating = add_unit(sql_file, propaneHeating, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:PROPANEHEATING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      centralPropaneHeating = apportion_central(centralPropaneHeating, modeledCentralPropaneHeating, units_represented, units.length)
      propaneInteriorEquipment = add_unit(sql_file, propaneInteriorEquipment, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:PROPANEINTERIOREQUIPMENT') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      propaneWaterSystems = add_unit(sql_file, propaneWaterSystems, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:PROPANEWATERSYSTEMS') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")

      if @include_enduse_subcategories
        propaneClothesDryer = add_unit(sql_file, propaneClothesDryer, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:PROPANECLOTHESDRYER') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
        propaneCookingRange = add_unit(sql_file, propaneCookingRange, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:PROPANECOOKINGRANGE') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
      end
    end

    @propane = Propane.new

    @propane.heating = propaneHeating
    @propane.central_heating = centralPropaneHeating
    @propane.interior_equipment = propaneInteriorEquipment
    @propane.water_systems = propaneWaterSystems

    if @include_enduse_subcategories
      @propane.clothes_dryer = propaneClothesDryer
      @propane.cooking_range = propaneCookingRange
    end

    @propane.total_end_uses = @propane.heating +
                              @propane.central_heating +
                              @propane.interior_equipment +
                              @propane.water_systems

    return @propane
  end

  def wood(sql_file, ann_env_pd)
    env_period_ix_query = "SELECT EnvironmentPeriodIndex FROM EnvironmentPeriods WHERE EnvironmentName='#{ann_env_pd}'"
    env_period_ix = sql_file.execAndReturnFirstInt(env_period_ix_query).get
    num_ts = get_num_ts(sql_file)

    # Get meters that are tied to units, and apportion building level meters to these
    woodHeating = Vector.elements(Array.new(num_ts, 0.0))

    # Get building units
    units = Geometry.get_building_units(@model, @runner)
    if units.nil?
      return false
    end

    units.each do |unit|
      unit_name = unit.name.to_s.upcase
      units_represented = get_units_represented(unit)

      woodHeating = add_unit(sql_file, woodHeating, units_represented, "SELECT VariableValue/1000000000 FROM ReportMeterData WHERE ReportMeterDataDictionaryIndex IN (SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableType='Sum' AND VariableName IN ('#{unit_name}:WOODHEATING') AND ReportingFrequency='#{@reporting_frequency_eplus}' AND VariableUnits='J') AND TimeIndex IN (SELECT TimeIndex FROM Time WHERE EnvironmentPeriodIndex='#{env_period_ix}')")
    end

    @wood = Wood.new

    @wood.heating = woodHeating

    @wood.total_end_uses = @wood.heating

    return @wood
  end

  def hours_setpoint_not_met(sql_file)
    # Get meters that are tied to units, and apportion building level meters to these
    hoursHeatingSetpointNotMet = 0.0
    hoursCoolingSetpointNotMet = 0.0

    # Get building units
    units = Geometry.get_building_units(@model, @runner)
    if units.nil?
      return false
    end

    units.each do |unit|
      thermal_zones = []
      unit.spaces.each do |space|
        thermal_zone = space.thermalZone.get
        unless thermal_zones.include? thermal_zone
          thermal_zones << thermal_zone
        end
      end

      units_represented = get_units_represented(unit)

      thermal_zones.each do |thermal_zone|
        thermal_zone_name = thermal_zone.name.to_s.upcase

        hours_heating_setpoint_not_met_query = "SELECT Value FROM TabularDataWithStrings WHERE (ReportName='SystemSummary') AND (ReportForString='Entire Facility') AND (TableName='Time Setpoint Not Met') AND (RowName = '#{thermal_zone_name}') AND (ColumnName='During Heating') AND (Units = 'hr')"
        unless sql_file.execAndReturnFirstDouble(hours_heating_setpoint_not_met_query).empty?
          hoursHeatingSetpointNotMet += units_represented * sql_file.execAndReturnFirstDouble(hours_heating_setpoint_not_met_query).get
        end

        hours_cooling_setpoint_not_met_query = "SELECT Value FROM TabularDataWithStrings WHERE (ReportName='SystemSummary') AND (ReportForString='Entire Facility') AND (TableName='Time Setpoint Not Met') AND (RowName = '#{thermal_zone_name}') AND (ColumnName='During Cooling') AND (Units = 'hr')"
        unless sql_file.execAndReturnFirstDouble(hours_cooling_setpoint_not_met_query).empty?
          hoursCoolingSetpointNotMet += units_represented * sql_file.execAndReturnFirstDouble(hours_cooling_setpoint_not_met_query).get
        end
      end
    end

    @hours_setpoint_not_met = HoursSetpointNotMet.new
    @hours_setpoint_not_met.heating = hoursHeatingSetpointNotMet
    @hours_setpoint_not_met.cooling = hoursCoolingSetpointNotMet

    return @hours_setpoint_not_met
  end

  def get_units_represented(unit)
    units_represented = 1
    if unit.additionalProperties.getFeatureAsInteger('Units Represented').is_initialized
      units_represented = unit.additionalProperties.getFeatureAsInteger('Units Represented').get
    end
    return units_represented
  end

  def get_num_ts(sql_file)
    hrs_sim = 0
    if sql_file.hoursSimulated.is_initialized
      hrs_sim = sql_file.hoursSimulated.get
    end
    num_ts = hrs_sim * @steps_per_hour
    case @reporting_frequency_os
    when 'Hourly'
      num_ts = hrs_sim
    when 'Daily'
      num_ts = (hrs_sim / 24.0).to_i
    when 'Monthly'
      run_period = @model.getRunPeriod
      begin_month = run_period.getBeginMonth
      end_month = run_period.getEndMonth
      num_ts = (end_month - begin_month) + 1
    when 'RunPeriod'
      num_ts = 1
    end
    return num_ts
  end

  def add_unit(sql_file, values, units_represented = 1, query_str = '')
    unless sql_file.execAndReturnVectorOfDouble(query_str).get.empty?
      values += units_represented * Vector.elements(sql_file.execAndReturnVectorOfDouble(query_str).get)
    end
    return values
  end

  def apportion_central(values, modeled_central, units_represented = 1, units_length = 1)
    values += units_represented * (modeled_central / units_length)
    return values
  end

  def create_custom_building_unit_meters
    # Initialize custom meter hash containing meter names and key/var groups
    custom_meter_infos = {}

    # Get building units
    units = Geometry.get_building_units(@model, @runner)

    units.each do |unit|
      # Get all zones in unit
      thermal_zones = []
      unit.spaces.each do |space|
        thermal_zone = space.thermalZone.get
        unless thermal_zones.include? thermal_zone
          thermal_zones << thermal_zone
        end
      end

      electricity_heating(custom_meter_infos, unit, thermal_zones)
      electricity_cooling(custom_meter_infos, unit, thermal_zones)
      electricity_interior_lighting(custom_meter_infos, unit, thermal_zones)
      electricity_exterior_lighting(custom_meter_infos, unit, thermal_zones)
      electricity_exterior_holiday_lighting(custom_meter_infos, unit, thermal_zones)
      electricity_garage_lighting(custom_meter_infos, unit, thermal_zones)
      electricity_interior_equipment(custom_meter_infos, unit, thermal_zones)
      electricity_fans_heating(custom_meter_infos, unit, thermal_zones)
      electricity_fans_cooling(custom_meter_infos, unit, thermal_zones)
      electricity_pumps_heating(custom_meter_infos, unit, thermal_zones)
      electricity_pumps_cooling(custom_meter_infos, unit, thermal_zones)
      electricity_water_systems(custom_meter_infos, unit, thermal_zones)
      electricity_photovoltaics(custom_meter_infos, unit, thermal_zones)
      natural_gas_heating(custom_meter_infos, unit, thermal_zones)
      natural_gas_interior_equipment(custom_meter_infos, unit, thermal_zones)
      natural_gas_water_systems(custom_meter_infos, unit, thermal_zones)
      fuel_oil_heating(custom_meter_infos, unit, thermal_zones)
      fuel_oil_water_systems(custom_meter_infos, unit, thermal_zones)
      propane_heating(custom_meter_infos, unit, thermal_zones)
      propane_interior_equipment(custom_meter_infos, unit, thermal_zones)
      propane_water_systems(custom_meter_infos, unit, thermal_zones)
      wood_heating(custom_meter_infos, unit, thermal_zones)

      if @include_enduse_subcategories
        electricity_refrigerator(custom_meter_infos, unit, thermal_zones)
        electricity_clothes_washer(custom_meter_infos, unit, thermal_zones)
        electricity_clothes_dryer(custom_meter_infos, unit, thermal_zones)
        natural_gas_clothes_dryer(custom_meter_infos, unit, thermal_zones)
        propane_clothes_dryer(custom_meter_infos, unit, thermal_zones)
        electricity_cooking_range(custom_meter_infos, unit, thermal_zones)
        natural_gas_cooking_range(custom_meter_infos, unit, thermal_zones)
        propane_cooking_range(custom_meter_infos, unit, thermal_zones)
        electricity_dishwasher(custom_meter_infos, unit, thermal_zones)
        electricity_plug_loads(custom_meter_infos, unit, thermal_zones)
        electricity_house_fan(custom_meter_infos, unit, thermal_zones)
        electricity_range_fan(custom_meter_infos, unit, thermal_zones)
        electricity_bath_fan(custom_meter_infos, unit, thermal_zones)
        electricity_ceiling_fan(custom_meter_infos, unit, thermal_zones)
        electricity_extra_refrigerator(custom_meter_infos, unit, thermal_zones)
        electricity_freezer(custom_meter_infos, unit, thermal_zones)
        electricity_pool_heater(custom_meter_infos, unit, thermal_zones)
        natural_gas_pool_heater(custom_meter_infos, unit, thermal_zones)
        electricity_pool_pump(custom_meter_infos, unit, thermal_zones)
        electricity_hot_tub_heater(custom_meter_infos, unit, thermal_zones)
        natural_gas_hot_tub_heater(custom_meter_infos, unit, thermal_zones)
        electricity_hot_tub_pump(custom_meter_infos, unit, thermal_zones)
        natural_gas_grill(custom_meter_infos, unit, thermal_zones)
        natural_gas_lighting(custom_meter_infos, unit, thermal_zones)
        natural_gas_fireplace(custom_meter_infos, unit, thermal_zones)
        electricity_well_pump(custom_meter_infos, unit, thermal_zones)
        electricity_recirc_pump(custom_meter_infos, unit, thermal_zones)
        electricity_vehicle(custom_meter_infos, unit, thermal_zones)
      end
    end

    results = OpenStudio::IdfObjectVector.new
    custom_meter_infos.each do |meter_name, custom_meter_info|
      next if custom_meter_info['key_var_groups'].empty?

      custom_meter = create_custom_meter(meter_name, custom_meter_info['fuel_type'], custom_meter_info['key_var_groups'])
      results << OpenStudio::IdfObject.load(custom_meter).get
      results << OpenStudio::IdfObject.load("Output:Meter,#{meter_name},#{@reporting_frequency_os};").get
    end

    return results
  end

  def create_custom_meter(meter_name, fuel_type, key_var_groups)
    custom_meter = "Meter:Custom,#{meter_name},#{fuel_type}"
    key_var_groups.each do |key_var_group|
      key, var = key_var_group
      custom_meter += ",#{key},#{var}"
    end
    custom_meter += ';'
    return custom_meter
  end

  def electricity_heating(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityHeating"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    custom_meter_infos['Central:ElectricityHeating'] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? 'pan heater'

        custom_meter_infos["#{unit.name}:ElectricityHeating"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
    thermal_zones.each do |thermal_zone|
      heating_equipment = HVAC.existing_heating_equipment(@model, @runner, thermal_zone)
      heating_equipment.each do |htg_equip|
        clg_coil, htg_coil, supp_htg_coil = HVAC.get_coils_from_hvac_equip(htg_equip)

        case htg_equip
        when OpenStudio::Model::AirLoopHVACUnitarySystem
          custom_meter_infos["#{unit.name}:ElectricityHeating"]['key_var_groups'] << [htg_coil.name.to_s, 'Heating Coil Electric Energy']
          custom_meter_infos["#{unit.name}:ElectricityHeating"]['key_var_groups'] << [htg_equip.name.to_s, 'Unitary System Heating Ancillary Electric Energy']
          unless htg_coil.is_a? OpenStudio::Model::CoilCoolingWaterToAirHeatPumpEquationFit
            custom_meter_infos["#{unit.name}:ElectricityHeating"]['key_var_groups'] << [htg_coil.name.to_s, 'Heating Coil Defrost Electric Energy']
            custom_meter_infos["#{unit.name}:ElectricityHeating"]['key_var_groups'] << [htg_coil.name.to_s, 'Heating Coil Crankcase Heater Electric Energy']
          end
          unless supp_htg_coil.nil?
            custom_meter_infos["#{unit.name}:ElectricityHeating"]['key_var_groups'] << [supp_htg_coil.name.to_s, 'Heating Coil Electric Energy']
          end
        when OpenStudio::Model::ZoneHVACBaseboardConvectiveWater

          @model.getPlantLoops.each do |plant_loop|
            is_specified_zone = false
            units_served = []
            plant_loop.demandComponents.each do |demand_component|
              next unless demand_component.to_CoilHeatingWaterBaseboard.is_initialized

              demand_coil = demand_component.to_CoilHeatingWaterBaseboard.get
              thermal_zone_served = demand_coil.containingZoneHVACComponent.get.thermalZone.get
              thermal_zone_served.spaces.each do |space_served|
                unit_served = space_served.buildingUnit.get
                next if units_served.include? unit_served

                units_served << unit_served
              end
              next if thermal_zone_served != thermal_zone

              is_specified_zone = true
            end
            next unless is_specified_zone

            plant_loop.supplyComponents.each do |supply_component|
              next unless supply_component.to_BoilerHotWater.is_initialized

              if units_served.length == 1
                if supply_component.to_BoilerHotWater.get.fuelType == 'Electricity'
                  custom_meter_infos["#{unit.name}:ElectricityHeating"]['key_var_groups'] << [supply_component.name.to_s, 'Boiler Electric Energy']
                end
                custom_meter_infos["#{unit.name}:ElectricityHeating"]['key_var_groups'] << [supply_component.name.to_s, 'Boiler Ancillary Electric Energy']
              else # this is a central system
                if supply_component.to_BoilerHotWater.get.fuelType == 'Electricity'
                  custom_meter_infos['Central:ElectricityHeating']['key_var_groups'] << [supply_component.name.to_s, 'Boiler Electric Energy']
                end
                custom_meter_infos['Central:ElectricityHeating']['key_var_groups'] << [supply_component.name.to_s, 'Boiler Ancillary Electric Energy']
              end
            end
          end

        when OpenStudio::Model::ZoneHVACBaseboardConvectiveElectric
          custom_meter_infos["#{unit.name}:ElectricityHeating"]['key_var_groups'] << [htg_equip.name.to_s, 'Baseboard Electric Energy']

        when OpenStudio::Model::ZoneHVACFourPipeFanCoil, OpenStudio::Model::ZoneHVACPackagedTerminalAirConditioner

          @model.getPlantLoops.each do |plant_loop|
            is_specified_zone = false
            units_served = []
            plant_loop.demandComponents.each do |demand_component|
              next unless demand_component.to_CoilHeatingWater.is_initialized

              demand_coil = demand_component.to_CoilHeatingWater.get
              thermal_zone_served = demand_coil.containingZoneHVACComponent.get.thermalZone.get
              thermal_zone_served.spaces.each do |space_served|
                unit_served = space_served.buildingUnit.get
                next if units_served.include? unit_served

                units_served << unit_served
              end
              next if thermal_zone_served != thermal_zone

              is_specified_zone = true
            end
            next unless is_specified_zone

            plant_loop.supplyComponents.each do |supply_component|
              next unless supply_component.to_BoilerHotWater.is_initialized

              if units_served.length == 1
                if supply_component.to_BoilerHotWater.get.fuelType == 'Electricity'
                  custom_meter_infos["#{unit.name}:ElectricityHeating"]['key_var_groups'] << [supply_component.name.to_s, 'Boiler Electric Energy']
                end
                custom_meter_infos["#{unit.name}:ElectricityHeating"]['key_var_groups'] << [supply_component.name.to_s, 'Boiler Ancillary Electric Energy']
              else # this is a central system
                if supply_component.to_BoilerHotWater.get.fuelType == 'Electricity'
                  custom_meter_infos['Central:ElectricityHeating']['key_var_groups'] << [supply_component.name.to_s, 'Boiler Electric Energy']
                end
                custom_meter_infos['Central:ElectricityHeating']['key_var_groups'] << [supply_component.name.to_s, 'Boiler Ancillary Electric Energy']
              end
            end
          end

        end
      end
    end
  end

  def electricity_cooling(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityCooling"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    custom_meter_infos['Central:ElectricityCooling'] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    thermal_zones.each do |thermal_zone|
      cooling_equipment = HVAC.existing_cooling_equipment(@model, @runner, thermal_zone)
      cooling_equipment.each do |clg_equip|
        clg_coil, htg_coil, supp_htg_coil = HVAC.get_coils_from_hvac_equip(clg_equip)

        case clg_equip
        when OpenStudio::Model::AirLoopHVACUnitarySystem
          custom_meter_infos["#{unit.name}:ElectricityCooling"]['key_var_groups'] << [clg_coil.name.to_s, 'Cooling Coil Electric Energy']
          custom_meter_infos["#{unit.name}:ElectricityCooling"]['key_var_groups'] << [clg_equip.name.to_s, 'Unitary System Cooling Ancillary Electric Energy']
          unless clg_coil.is_a? OpenStudio::Model::CoilCoolingWaterToAirHeatPumpEquationFit
            custom_meter_infos["#{unit.name}:ElectricityCooling"]['key_var_groups'] << [clg_coil.name.to_s, 'Cooling Coil Crankcase Heater Electric Energy']
          end
        when OpenStudio::Model::ZoneHVACPackagedTerminalAirConditioner
          custom_meter_infos["#{unit.name}:ElectricityCooling"]['key_var_groups'] << [clg_coil.name.to_s, 'Cooling Coil Electric Energy']
        when OpenStudio::Model::ZoneHVACFourPipeFanCoil
          @model.getPlantLoops.each do |plant_loop|
            is_specified_zone = false
            units_served = []
            plant_loop.demandComponents.each do |demand_component|
              next unless demand_component.to_CoilCoolingWater.is_initialized

              demand_coil = demand_component.to_CoilCoolingWater.get
              thermal_zone_served = demand_coil.containingZoneHVACComponent.get.thermalZone.get
              thermal_zone_served.spaces.each do |space_served|
                unit_served = space_served.buildingUnit.get
                next if units_served.include? unit_served

                units_served << unit_served
              end
              next if thermal_zone_served != thermal_zone

              is_specified_zone = true
            end
            next unless is_specified_zone

            plant_loop.supplyComponents.each do |supply_component|
              next unless supply_component.to_ChillerElectricEIR.is_initialized

              if units_served.length == 1
                custom_meter_infos["#{unit.name}:ElectricityCooling"]['key_var_groups'] << [supply_component.name.to_s, 'Chiller Electric Energy']
              else # this is a central system
                custom_meter_infos['Central:ElectricityCooling']['key_var_groups'] << [supply_component.name.to_s, 'Chiller Electric Energy']
              end
            end
          end

        end
      end
      dehumidifiers = HVAC.get_dehumidifiers(@model, @runner, thermal_zone)
      dehumidifiers.each do |dehumidifier|
        custom_meter_infos["#{unit.name}:ElectricityCooling"]['key_var_groups'] << [dehumidifier.name.to_s, 'Zone Dehumidifier Electric Energy']
      end
    end
  end

  def electricity_interior_lighting(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityInteriorLighting"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    thermal_zones.each do |thermal_zone|
      custom_meter_infos["#{unit.name}:ElectricityInteriorLighting"]['key_var_groups'] << ['', "InteriorLights:Electricity:Zone:#{thermal_zone.name}"]
    end
  end

  def electricity_exterior_lighting(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos['Central:ElectricityExteriorLighting'] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    @model.getExteriorLightss.each do |exterior_lights|
      if !exterior_lights.endUseSubcategory.include? Constants.ObjectNameLightingExteriorHoliday
        custom_meter_infos['Central:ElectricityExteriorLighting']['key_var_groups'] << [exterior_lights.name.to_s, 'Exterior Lights Electric Energy']
      end
    end
  end

  def electricity_exterior_holiday_lighting(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos['Central:ElectricityExteriorHolidayLighting'] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    @model.getExteriorLightss.each do |exterior_lights|
      if exterior_lights.endUseSubcategory.include? Constants.ObjectNameLightingExteriorHoliday
        custom_meter_infos['Central:ElectricityExteriorHolidayLighting']['key_var_groups'] << [exterior_lights.name.to_s, 'Exterior Lights Electric Energy']
      end
    end
  end

  def electricity_garage_lighting(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos['Central:ElectricityGarageLighting'] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    @model.getLightss.each do |lights|
      next unless lights.endUseSubcategory.include? Constants.ObjectNameLightingGarage

      custom_meter_infos['Central:ElectricityGarageLighting']['key_var_groups'] << [lights.name.to_s, 'Lights Electric Energy']
    end
  end

  def electricity_interior_equipment(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityInteriorEquipment"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next if equip.endUseSubcategory.include? 'pan heater'

        custom_meter_infos["#{unit.name}:ElectricityInteriorEquipment"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
    custom_meter_infos['Central:ElectricityInteriorEquipment'] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    @model.getSpaces.each do |space|
      next if space.buildingUnit.is_initialized

      space.electricEquipment.each do |equip|
        custom_meter_infos['Central:ElectricityInteriorEquipment']['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def electricity_fans_heating(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityFansHeating"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    thermal_zones.each do |thermal_zone|
      heating_equipment = HVAC.existing_heating_equipment(@model, @runner, thermal_zone)
      heating_equipment.each do |htg_equip|
        clg_coil, htg_coil, supp_htg_coil = HVAC.get_coils_from_hvac_equip(htg_equip)
        if htg_equip.is_a? OpenStudio::Model::AirLoopHVACUnitarySystem
          custom_meter_infos["#{unit.name}:ElectricityFansHeating"]['key_var_groups'] << [htg_equip.supplyFan.get.name.to_s, 'Fan Electric Energy']
        end
      end
    end
    @model.getPlantLoops.each do |plant_loop|
      if plant_loop.name.to_s == Constants.PlantLoopDomesticWater(unit.name.to_s)
        water_heater = Waterheater.get_water_heater(@model, plant_loop, @runner)
        if water_heater.is_a? OpenStudio::Model::WaterHeaterHeatPumpWrappedCondenser
          custom_meter_infos["#{unit.name}:ElectricityFansHeating"]['key_var_groups'] << [water_heater.fan.name.to_s, 'Fan Electric Energy']
        end
      end
    end
  end

  def electricity_fans_cooling(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityFansCooling"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    thermal_zones.each do |thermal_zone|
      cooling_equipment = HVAC.existing_cooling_equipment(@model, @runner, thermal_zone)
      cooling_equipment.each do |clg_equip|
        clg_coil, htg_coil, supp_htg_coil = HVAC.get_coils_from_hvac_equip(clg_equip)
        case clg_equip
        when OpenStudio::Model::AirLoopHVACUnitarySystem
          custom_meter_infos["#{unit.name}:ElectricityFansCooling"]['key_var_groups'] << [clg_equip.supplyFan.get.name.to_s, 'Fan Electric Energy']
        when OpenStudio::Model::ZoneHVACPackagedTerminalAirConditioner, OpenStudio::Model::ZoneHVACFourPipeFanCoil
          custom_meter_infos["#{unit.name}:ElectricityFansCooling"]['key_var_groups'] << [clg_equip.supplyAirFan.name.to_s, 'Fan Electric Energy'] # FIXME: all fan coil fan energy is assigned to fan cooling
        end
      end
    end
  end

  def electricity_pumps_heating(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityPumpsHeating"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    custom_meter_infos['Central:ElectricityPumpsHeating'] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    @model.getEnergyManagementSystemOutputVariables.each do |ems_output_var|
      if ems_output_var.name.to_s.include? 'Central htg pump:Pumps:Electricity'
        custom_meter_infos['Central:ElectricityPumpsHeating']['key_var_groups'] << ['', ems_output_var.name.to_s]
      elsif ems_output_var.name.to_s.include?('htg pump:Pumps:Electricity') && (ems_output_var.emsVariableName.to_s == "#{unit.name}_pumps_h".gsub(' ', '_'))
        custom_meter_infos["#{unit.name}:ElectricityPumpsHeating"]['key_var_groups'] << ['', ems_output_var.name.to_s]
      end
    end
    @model.getPumpConstantSpeeds.each do |pump| # shw pump
      next unless pump.name.to_s.include? Constants.ObjectNameSolarHotWater

      if ((unit.name.to_s == 'unit 1') && (!pump.name.to_s.include? 'unit')) || pump.name.to_s.end_with?("#{unit.name} pump")
        custom_meter_infos["#{unit.name}:ElectricityPumpsHeating"]['key_var_groups'] << [pump.name.to_s, 'Pump Electric Energy']
      end
    end
  end

  def electricity_pumps_cooling(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityPumpsCooling"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    custom_meter_infos['Central:ElectricityPumpsCooling'] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    @model.getEnergyManagementSystemOutputVariables.each do |ems_output_var|
      if ems_output_var.name.to_s.include? 'Central clg pump:Pumps:Electricity'
        custom_meter_infos['Central:ElectricityPumpsCooling']['key_var_groups'] << ['', ems_output_var.name.to_s]
      elsif ems_output_var.name.to_s.include?('clg pump:Pumps:Electricity') && (ems_output_var.emsVariableName.to_s == "#{unit.name}_pumps_c".gsub(' ', '_'))
        custom_meter_infos["#{unit.name}:ElectricityPumpsCooling"]['key_var_groups'] << ['', ems_output_var.name.to_s]
      end
    end
  end

  def electricity_water_systems(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityWaterSystems"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    @model.getPlantLoops.each do |plant_loop|
      if plant_loop.name.to_s == Constants.PlantLoopDomesticWater(unit.name.to_s)
        water_heater = Waterheater.get_water_heater(@model, plant_loop, @runner)

        case water_heater
        when OpenStudio::Model::WaterHeaterMixed
          custom_meter_infos["#{unit.name}:ElectricityWaterSystems"]['key_var_groups'] << [water_heater.name.to_s, 'Water Heater Off Cycle Parasitic Electric Energy']
          custom_meter_infos["#{unit.name}:ElectricityWaterSystems"]['key_var_groups'] << [water_heater.name.to_s, 'Water Heater On Cycle Parasitic Electric Energy']
          next if water_heater.heaterFuelType != 'Electricity'

          custom_meter_infos["#{unit.name}:ElectricityWaterSystems"]['key_var_groups'] << [water_heater.name.to_s, 'Water Heater Electric Energy']
        when OpenStudio::Model::WaterHeaterHeatPumpWrappedCondenser
          custom_meter_infos["#{unit.name}:ElectricityWaterSystems"]['key_var_groups'] << [water_heater.name.to_s, 'Water Heater Off Cycle Ancillary Electric Energy']
          custom_meter_infos["#{unit.name}:ElectricityWaterSystems"]['key_var_groups'] << [water_heater.name.to_s, 'Water Heater On Cycle Ancillary Electric Energy']

          tank = water_heater.tank.to_WaterHeaterStratified.get
          custom_meter_infos["#{unit.name}:ElectricityWaterSystems"]['key_var_groups'] << [tank.name.to_s, 'Water Heater Electric Energy']
          custom_meter_infos["#{unit.name}:ElectricityWaterSystems"]['key_var_groups'] << [tank.name.to_s, 'Water Heater Off Cycle Parasitic Electric Energy']
          custom_meter_infos["#{unit.name}:ElectricityWaterSystems"]['key_var_groups'] << [tank.name.to_s, 'Water Heater On Cycle Parasitic Electric Energy']

          coil = water_heater.dXCoil.to_CoilWaterHeatingAirToWaterHeatPumpWrapped.get
          custom_meter_infos["#{unit.name}:ElectricityWaterSystems"]['key_var_groups'] << [coil.name.to_s, 'Cooling Coil Crankcase Heater Electric Energy']
          custom_meter_infos["#{unit.name}:ElectricityWaterSystems"]['key_var_groups'] << [coil.name.to_s, 'Cooling Coil Water Heating Electric Energy']
        end
      end
    end
    shw_tank = Waterheater.get_shw_storage_tank(@model, unit)
    unless shw_tank.nil?
      custom_meter_infos["#{unit.name}:ElectricityWaterSystems"]['key_var_groups'] << [shw_tank.name.to_s, 'Water Heater Electric Energy']
      custom_meter_infos["#{unit.name}:ElectricityWaterSystems"]['key_var_groups'] << [shw_tank.name.to_s, 'Water Heater Off Cycle Parasitic Electric Energy']
      custom_meter_infos["#{unit.name}:ElectricityWaterSystems"]['key_var_groups'] << [shw_tank.name.to_s, 'Water Heater On Cycle Parasitic Electric Energy']
    end
  end

  def electricity_photovoltaics(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos['Central:ElectricityPhotovoltaics'] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    @model.getGeneratorPVWattss.each do |generator_pvwatts|
      custom_meter_infos['Central:ElectricityPhotovoltaics']['key_var_groups'] << [generator_pvwatts.name.to_s, 'Generator Produced DC Electric Energy']
    end
    @model.getElectricLoadCenterInverterPVWattss.each do |electric_load_center_inverter_pvwatts|
      custom_meter_infos['Central:ElectricityPhotovoltaics']['key_var_groups'] << [electric_load_center_inverter_pvwatts.name.to_s, 'Inverter Conversion Loss Decrement Energy']
    end
  end

  def natural_gas_heating(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:NaturalGasHeating"] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    custom_meter_infos['Central:NaturalGasHeating'] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    thermal_zones.each do |thermal_zone|
      heating_equipment = HVAC.existing_heating_equipment(@model, @runner, thermal_zone)
      heating_equipment.each do |htg_equip|
        clg_coil, htg_coil, supp_htg_coil = HVAC.get_coils_from_hvac_equip(htg_equip)

        case htg_equip
        when OpenStudio::Model::AirLoopHVACUnitarySystem
          next if htg_coil.is_a?(OpenStudio::Model::CoilHeatingElectric) || htg_coil.is_a?(OpenStudio::Model::CoilHeatingDXSingleSpeed) || htg_coil.is_a?(OpenStudio::Model::CoilHeatingDXMultiSpeed)

          if htg_coil.is_a?(OpenStudio::Model::CoilHeatingGas) && (htg_coil.fuelType != 'NaturalGas')
            next
          end

          custom_meter_infos["#{unit.name}:NaturalGasHeating"]['key_var_groups'] << [htg_coil.name.to_s, 'Heating Coil Gas Energy']
          custom_meter_infos["#{unit.name}:NaturalGasHeating"]['key_var_groups'] << [htg_coil.name.to_s, 'Heating Coil Ancillary Gas Energy']

        when OpenStudio::Model::ZoneHVACBaseboardConvectiveWater
          @model.getPlantLoops.each do |plant_loop|
            is_specified_zone = false
            units_served = []
            plant_loop.demandComponents.each do |demand_component|
              next unless demand_component.to_CoilHeatingWaterBaseboard.is_initialized

              demand_coil = demand_component.to_CoilHeatingWaterBaseboard.get
              thermal_zone_served = demand_coil.containingZoneHVACComponent.get.thermalZone.get
              thermal_zone_served.spaces.each do |space_served|
                unit_served = space_served.buildingUnit.get
                next if units_served.include? unit_served

                units_served << unit_served
              end
              next if thermal_zone_served != thermal_zone

              is_specified_zone = true
            end
            next unless is_specified_zone

            plant_loop.supplyComponents.each do |supply_component|
              next unless supply_component.to_BoilerHotWater.is_initialized
              next if supply_component.to_BoilerHotWater.get.fuelType != 'NaturalGas'

              if units_served.length == 1
                custom_meter_infos["#{unit.name}:NaturalGasHeating"]['key_var_groups'] << [supply_component.name.to_s, 'Boiler Gas Energy']
              else # this is a central system
                custom_meter_infos['Central:NaturalGasHeating']['key_var_groups'] << [supply_component.name.to_s, 'Boiler Gas Energy']
              end
            end
          end

        when OpenStudio::Model::ZoneHVACFourPipeFanCoil, OpenStudio::Model::ZoneHVACPackagedTerminalAirConditioner
          @model.getPlantLoops.each do |plant_loop|
            is_specified_zone = false
            units_served = []
            plant_loop.demandComponents.each do |demand_component|
              next unless demand_component.to_CoilHeatingWater.is_initialized

              demand_coil = demand_component.to_CoilHeatingWater.get
              thermal_zone_served = demand_coil.containingZoneHVACComponent.get.thermalZone.get
              thermal_zone_served.spaces.each do |space_served|
                unit_served = space_served.buildingUnit.get
                next if units_served.include? unit_served

                units_served << unit_served
              end
              next if thermal_zone_served != thermal_zone

              is_specified_zone = true
            end
            next unless is_specified_zone

            plant_loop.supplyComponents.each do |supply_component|
              next unless supply_component.to_BoilerHotWater.is_initialized
              next if supply_component.to_BoilerHotWater.get.fuelType != 'NaturalGas'

              if units_served.length == 1
                custom_meter_infos["#{unit.name}:NaturalGasHeating"]['key_var_groups'] << [supply_component.name.to_s, 'Boiler Gas Energy']
              else # this is a central system
                custom_meter_infos['Central:NaturalGasHeating']['key_var_groups'] << [supply_component.name.to_s, 'Boiler Gas Energy']
              end
            end
          end
        end
      end
    end
  end

  def natural_gas_interior_equipment(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:NaturalGasInteriorEquipment"] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.gasEquipment.each do |equip|
        custom_meter_infos["#{unit.name}:NaturalGasInteriorEquipment"]['key_var_groups'] << [equip.name.to_s, 'Gas Equipment Gas Energy']
      end
      space.otherEquipment.each do |equip|
        next if equip.fuelType != 'NaturalGas'

        custom_meter_infos["#{unit.name}:NaturalGasInteriorEquipment"]['key_var_groups'] << [equip.name.to_s, 'Other Equipment Gas Energy']
      end
    end
    custom_meter_infos['Central:NaturalGasInteriorEquipment'] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    @model.getSpaces.each do |space|
      next if space.buildingUnit.is_initialized

      space.gasEquipment.each do |equip|
        custom_meter_infos['Central:NaturalGasInteriorEquipment']['key_var_groups'] << [equip.name.to_s, 'Gas Equipment Gas Energy']
      end
      space.otherEquipment.each do |equip|
        next if equip.fuelType != 'NaturalGas'

        custom_meter_infos['Central:NaturalGasInteriorEquipment']['key_var_groups'] << [equip.name.to_s, 'Other Equipment Gas Energy']
      end
    end
  end

  def natural_gas_water_systems(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:NaturalGasWaterSystems"] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    @model.getPlantLoops.each do |plant_loop|
      if plant_loop.name.to_s == Constants.PlantLoopDomesticWater(unit.name.to_s)
        water_heater = Waterheater.get_water_heater(@model, plant_loop, @runner)
        next unless water_heater.is_a? OpenStudio::Model::WaterHeaterMixed
        next if water_heater.heaterFuelType != 'NaturalGas'

        custom_meter_infos["#{unit.name}:NaturalGasWaterSystems"]['key_var_groups'] << [water_heater.name.to_s, 'Water Heater Gas Energy']
      end
    end
  end

  def fuel_oil_heating(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:FuelOilHeating"] = { 'fuel_type' => 'FuelOil#1', 'key_var_groups' => [] }
    custom_meter_infos['Central:FuelOilHeating'] = { 'fuel_type' => 'FuelOil#1', 'key_var_groups' => [] }
    thermal_zones.each do |thermal_zone|
      heating_equipment = HVAC.existing_heating_equipment(@model, @runner, thermal_zone)
      heating_equipment.each do |htg_equip|
        clg_coil, htg_coil, supp_htg_coil = HVAC.get_coils_from_hvac_equip(htg_equip)

        case htg_equip
        when OpenStudio::Model::AirLoopHVACUnitarySystem
          next if htg_coil.is_a?(OpenStudio::Model::CoilHeatingElectric) || htg_coil.is_a?(OpenStudio::Model::CoilHeatingDXSingleSpeed) || htg_coil.is_a?(OpenStudio::Model::CoilHeatingDXMultiSpeed)

          if htg_coil.is_a?(OpenStudio::Model::CoilHeatingGas) && (htg_coil.fuelType != 'FuelOil#1')
            next
          end

          custom_meter_infos["#{unit.name}:FuelOilHeating"]['key_var_groups'] << [htg_coil.name.to_s, 'Heating Coil FuelOil#1 Energy']
          custom_meter_infos["#{unit.name}:FuelOilHeating"]['key_var_groups'] << [htg_coil.name.to_s, 'Heating Coil Ancillary FuelOil#1 Energy']

        when OpenStudio::Model::ZoneHVACBaseboardConvectiveWater
          @model.getPlantLoops.each do |plant_loop|
            is_specified_zone = false
            units_served = []
            plant_loop.demandComponents.each do |demand_component|
              next unless demand_component.to_CoilHeatingWaterBaseboard.is_initialized

              demand_coil = demand_component.to_CoilHeatingWaterBaseboard.get
              thermal_zone_served = demand_coil.containingZoneHVACComponent.get.thermalZone.get
              thermal_zone_served.spaces.each do |space_served|
                unit_served = space_served.buildingUnit.get
                next if units_served.include? unit_served

                units_served << unit_served
              end
              next if thermal_zone_served != thermal_zone

              is_specified_zone = true
            end
            next unless is_specified_zone

            plant_loop.supplyComponents.each do |supply_component|
              next unless supply_component.to_BoilerHotWater.is_initialized
              next if supply_component.to_BoilerHotWater.get.fuelType != 'FuelOil#1'

              if units_served.length == 1
                custom_meter_infos["#{unit.name}:FuelOilHeating"]['key_var_groups'] << [supply_component.name.to_s, 'Boiler FuelOil#1 Energy']
              else # this is a central system
                custom_meter_infos['Central:FuelOilHeating']['key_var_groups'] << [supply_component.name.to_s, 'Boiler FuelOil#1 Energy']
              end
            end
          end

        when OpenStudio::Model::ZoneHVACFourPipeFanCoil, OpenStudio::Model::ZoneHVACPackagedTerminalAirConditioner
          @model.getPlantLoops.each do |plant_loop|
            is_specified_zone = false
            units_served = []
            plant_loop.demandComponents.each do |demand_component|
              next unless demand_component.to_CoilHeatingWater.is_initialized

              demand_coil = demand_component.to_CoilHeatingWater.get
              thermal_zone_served = demand_coil.containingZoneHVACComponent.get.thermalZone.get
              thermal_zone_served.spaces.each do |space_served|
                unit_served = space_served.buildingUnit.get
                next if units_served.include? unit_served

                units_served << unit_served
              end
              next if thermal_zone_served != thermal_zone

              is_specified_zone = true
            end
            next unless is_specified_zone

            plant_loop.supplyComponents.each do |supply_component|
              next unless supply_component.to_BoilerHotWater.is_initialized
              next if supply_component.to_BoilerHotWater.get.fuelType != 'FuelOil#1'

              if units_served.length == 1
                custom_meter_infos["#{unit.name}:FuelOilHeating"]['key_var_groups'] << [supply_component.name.to_s, 'Boiler FuelOil#1 Energy']
              else # this is a central system
                custom_meter_infos['Central:FuelOilHeating']['key_var_groups'] << [supply_component.name.to_s, 'Boiler FuelOil#1 Energy']
              end
            end
          end

        end
      end
    end
  end

  def fuel_oil_water_systems(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:FuelOilWaterSystems"] = { 'fuel_type' => 'FuelOil#1', 'key_var_groups' => [] }
    @model.getPlantLoops.each do |plant_loop|
      if plant_loop.name.to_s == Constants.PlantLoopDomesticWater(unit.name.to_s)
        water_heater = Waterheater.get_water_heater(@model, plant_loop, @runner)
        next unless water_heater.is_a? OpenStudio::Model::WaterHeaterMixed
        next if water_heater.heaterFuelType != 'FuelOil#1'

        custom_meter_infos["#{unit.name}:FuelOilWaterSystems"]['key_var_groups'] << [water_heater.name.to_s, 'Water Heater FuelOil#1 Energy']
      end
    end
  end

  def propane_heating(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:PropaneHeating"] = { 'fuel_type' => 'PropaneGas', 'key_var_groups' => [] }
    custom_meter_infos['Central:PropaneHeating'] = { 'fuel_type' => 'PropaneGas', 'key_var_groups' => [] }
    thermal_zones.each do |thermal_zone|
      heating_equipment = HVAC.existing_heating_equipment(@model, @runner, thermal_zone)
      heating_equipment.each do |htg_equip|
        clg_coil, htg_coil, supp_htg_coil = HVAC.get_coils_from_hvac_equip(htg_equip)

        case htg_equip
        when OpenStudio::Model::AirLoopHVACUnitarySystem
          next if htg_coil.is_a?(OpenStudio::Model::CoilHeatingElectric) || htg_coil.is_a?(OpenStudio::Model::CoilHeatingDXSingleSpeed) || htg_coil.is_a?(OpenStudio::Model::CoilHeatingDXMultiSpeed)

          if htg_coil.is_a?(OpenStudio::Model::CoilHeatingGas) && (htg_coil.fuelType != 'PropaneGas')
            next
          end

          custom_meter_infos["#{unit.name}:PropaneHeating"]['key_var_groups'] << [htg_coil.name.to_s, 'Heating Coil Propane Energy']
          custom_meter_infos["#{unit.name}:PropaneHeating"]['key_var_groups'] << [htg_coil.name.to_s, 'Heating Coil Ancillary Propane Energy']

        when OpenStudio::Model::ZoneHVACBaseboardConvectiveWater
          @model.getPlantLoops.each do |plant_loop|
            is_specified_zone = false
            units_served = []
            plant_loop.demandComponents.each do |demand_component|
              next unless demand_component.to_CoilHeatingWaterBaseboard.is_initialized

              demand_coil = demand_component.to_CoilHeatingWaterBaseboard.get
              thermal_zone_served = demand_coil.containingZoneHVACComponent.get.thermalZone.get
              thermal_zone_served.spaces.each do |space_served|
                unit_served = space_served.buildingUnit.get
                next if units_served.include? unit_served

                units_served << unit_served
              end
              next if thermal_zone_served != thermal_zone

              is_specified_zone = true
            end
            next unless is_specified_zone

            plant_loop.supplyComponents.each do |supply_component|
              next unless supply_component.to_BoilerHotWater.is_initialized
              next if supply_component.to_BoilerHotWater.get.fuelType != 'PropaneGas'

              if units_served.length == 1
                custom_meter_infos["#{unit.name}:PropaneHeating"]['key_var_groups'] << [supply_component.name.to_s, 'Boiler Propane Energy']
              else # this is a central system
                custom_meter_infos['Central:PropaneHeating']['key_var_groups'] << [supply_component.name.to_s, 'Boiler Propane Energy']
              end
            end
          end

        when OpenStudio::Model::ZoneHVACFourPipeFanCoil, OpenStudio::Model::ZoneHVACPackagedTerminalAirConditioner
          @model.getPlantLoops.each do |plant_loop|
            is_specified_zone = false
            units_served = []
            plant_loop.demandComponents.each do |demand_component|
              next unless demand_component.to_CoilHeatingWater.is_initialized

              demand_coil = demand_component.to_CoilHeatingWater.get
              thermal_zone_served = demand_coil.containingZoneHVACComponent.get.thermalZone.get
              thermal_zone_served.spaces.each do |space_served|
                unit_served = space_served.buildingUnit.get
                next if units_served.include? unit_served

                units_served << unit_served
              end
              next if thermal_zone_served != thermal_zone

              is_specified_zone = true
            end
            next unless is_specified_zone

            plant_loop.supplyComponents.each do |supply_component|
              next unless supply_component.to_BoilerHotWater.is_initialized
              next if supply_component.to_BoilerHotWater.get.fuelType != 'PropaneGas'

              if units_served.length == 1
                custom_meter_infos["#{unit.name}:PropaneHeating"]['key_var_groups'] << [supply_component.name.to_s, 'Boiler Propane Energy']
              else # this is a central system
                custom_meter_infos['Central:PropaneHeating']['key_var_groups'] << [supply_component.name.to_s, 'Boiler Propane Energy']
              end
            end
          end
        end
      end
    end
  end

  def propane_interior_equipment(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:PropaneInteriorEquipment"] = { 'fuel_type' => 'PropaneGas', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.otherEquipment.each do |equip|
        next if equip.fuelType != 'PropaneGas'

        custom_meter_infos["#{unit.name}:PropaneInteriorEquipment"]['key_var_groups'] << [equip.name.to_s, 'Other Equipment Propane Energy']
      end
    end
    custom_meter_infos['Central:PropaneInteriorEquipment'] = { 'fuel_type' => 'PropaneGas', 'key_var_groups' => [] }
    @model.getSpaces.each do |space|
      next if space.buildingUnit.is_initialized

      space.otherEquipment.each do |equip|
        next if equip.fuelType != 'PropaneGas'

        custom_meter_infos['Central:PropaneInteriorEquipment']['key_var_groups'] << [equip.name.to_s, 'Other Equipment Propane Energy']
      end
    end
  end

  def propane_water_systems(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:PropaneWaterSystems"] = { 'fuel_type' => 'PropaneGas', 'key_var_groups' => [] }
    @model.getPlantLoops.each do |plant_loop|
      if plant_loop.name.to_s == Constants.PlantLoopDomesticWater(unit.name.to_s)
        water_heater = Waterheater.get_water_heater(@model, plant_loop, @runner)
        next unless water_heater.is_a? OpenStudio::Model::WaterHeaterMixed
        next if water_heater.heaterFuelType != 'PropaneGas'

        custom_meter_infos["#{unit.name}:PropaneWaterSystems"]['key_var_groups'] << [water_heater.name.to_s, 'Water Heater Propane Energy']
      end
    end
  end

  def wood_heating(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:WoodHeating"] = { 'fuel_type' => 'OtherFuel1', 'key_var_groups' => [] }
    thermal_zones.each do |thermal_zone|
      heating_equipment = HVAC.existing_heating_equipment(@model, @runner, thermal_zone)
      heating_equipment.each do |htg_equip|
        clg_coil, htg_coil, supp_htg_coil = HVAC.get_coils_from_hvac_equip(htg_equip)

        if htg_equip.is_a? OpenStudio::Model::AirLoopHVACUnitarySystem
          if htg_coil.is_a?(OpenStudio::Model::CoilHeatingGas) && (htg_coil.fuelType != 'OtherFuel1')
            next
          end

          custom_meter_infos["#{unit.name}:WoodHeating"]['key_var_groups'] << [htg_coil.name.to_s, 'Heating Coil OtherFuel1 Energy']
        end
      end
    end
  end

  def electricity_refrigerator(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityRefrigerator"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameRefrigerator

        custom_meter_infos["#{unit.name}:ElectricityRefrigerator"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def electricity_clothes_washer(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityClothesWasher"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameClothesWasher

        custom_meter_infos["#{unit.name}:ElectricityClothesWasher"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def electricity_clothes_dryer(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityClothesDryer"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameClothesDryer(nil)

        custom_meter_infos["#{unit.name}:ElectricityClothesDryer"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def natural_gas_clothes_dryer(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:NaturalGasClothesDryer"] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.otherEquipment.each do |equip|
        next unless equip.fuelType == 'NaturalGas'
        next unless equip.endUseSubcategory.include? Constants.ObjectNameClothesDryer(nil)

        custom_meter_infos["#{unit.name}:NaturalGasClothesDryer"]['key_var_groups'] << [equip.name.to_s, 'Other Equipment Gas Energy']
      end
    end
  end

  def propane_clothes_dryer(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:PropaneClothesDryer"] = { 'fuel_type' => 'PropaneGas', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.otherEquipment.each do |equip|
        next unless equip.fuelType == 'PropaneGas'
        next unless equip.endUseSubcategory.include? Constants.ObjectNameClothesDryer(nil)

        custom_meter_infos["#{unit.name}:PropaneClothesDryer"]['key_var_groups'] << [equip.name.to_s, 'Other Equipment Propane Energy']
      end
    end
  end

  def electricity_cooking_range(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityCookingRange"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameCookingRange(nil)

        custom_meter_infos["#{unit.name}:ElectricityCookingRange"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def natural_gas_cooking_range(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:NaturalGasCookingRange"] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.otherEquipment.each do |equip|
        next unless equip.fuelType == 'NaturalGas'
        next unless equip.endUseSubcategory.include? Constants.ObjectNameCookingRange(nil)

        custom_meter_infos["#{unit.name}:NaturalGasCookingRange"]['key_var_groups'] << [equip.name.to_s, 'Other Equipment Gas Energy']
      end
    end
  end

  def propane_cooking_range(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:PropaneCookingRange"] = { 'fuel_type' => 'PropaneGas', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.otherEquipment.each do |equip|
        next unless equip.fuelType == 'PropaneGas'
        next unless equip.endUseSubcategory.include? Constants.ObjectNameCookingRange(nil)

        custom_meter_infos["#{unit.name}:PropaneCookingRange"]['key_var_groups'] << [equip.name.to_s, 'Other Equipment Propane Energy']
      end
    end
  end

  def electricity_dishwasher(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityDishwasher"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameDishwasher

        custom_meter_infos["#{unit.name}:ElectricityDishwasher"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def electricity_plug_loads(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityPlugLoads"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameMiscPlugLoads

        custom_meter_infos["#{unit.name}:ElectricityPlugLoads"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def electricity_house_fan(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityHouseFan"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? 'house fan'

        custom_meter_infos["#{unit.name}:ElectricityHouseFan"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def electricity_range_fan(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityRangeFan"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? 'range fan'

        custom_meter_infos["#{unit.name}:ElectricityRangeFan"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def electricity_bath_fan(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityBathFan"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? 'bath fan'

        custom_meter_infos["#{unit.name}:ElectricityBathFan"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def electricity_ceiling_fan(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityCeilingFan"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameCeilingFan

        custom_meter_infos["#{unit.name}:ElectricityCeilingFan"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def electricity_extra_refrigerator(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityExtraRefrigerator"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameExtraRefrigerator

        custom_meter_infos["#{unit.name}:ElectricityExtraRefrigerator"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end

    custom_meter_infos['Central:ElectricityExtraRefrigerator'] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    @model.getSpaces.each do |space|
      next if space.buildingUnit.is_initialized

      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameExtraRefrigerator

        custom_meter_infos['Central:ElectricityExtraRefrigerator']['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def electricity_freezer(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityFreezer"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameFreezer

        custom_meter_infos["#{unit.name}:ElectricityFreezer"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end

    custom_meter_infos['Central:ElectricityFreezer'] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    @model.getSpaces.each do |space|
      next if space.buildingUnit.is_initialized

      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameFreezer

        custom_meter_infos['Central:ElectricityFreezer']['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def electricity_pool_heater(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityPoolHeater"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNamePoolHeater(Constants.FuelTypeElectric)

        custom_meter_infos["#{unit.name}:ElectricityPoolHeater"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def natural_gas_pool_heater(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:NaturalGasPoolHeater"] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.gasEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNamePoolHeater(Constants.FuelTypeGas)

        custom_meter_infos["#{unit.name}:NaturalGasPoolHeater"]['key_var_groups'] << [equip.name.to_s, 'Gas Equipment Gas Energy']
      end
    end
  end

  def electricity_pool_pump(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityPoolPump"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNamePoolPump

        custom_meter_infos["#{unit.name}:ElectricityPoolPump"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def electricity_hot_tub_heater(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityHotTubHeater"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameHotTubHeater(Constants.FuelTypeElectric)

        custom_meter_infos["#{unit.name}:ElectricityHotTubHeater"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def natural_gas_hot_tub_heater(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:NaturalGasHotTubHeater"] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.gasEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameHotTubHeater(Constants.FuelTypeGas)

        custom_meter_infos["#{unit.name}:NaturalGasHotTubHeater"]['key_var_groups'] << [equip.name.to_s, 'Gas Equipment Gas Energy']
      end
    end
  end

  def electricity_hot_tub_pump(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityHotTubPump"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameHotTubPump

        custom_meter_infos["#{unit.name}:ElectricityHotTubPump"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def natural_gas_grill(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:NaturalGasGrill"] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.gasEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameGasGrill

        custom_meter_infos["#{unit.name}:NaturalGasGrill"]['key_var_groups'] << [equip.name.to_s, 'Gas Equipment Gas Energy']
      end
    end

    custom_meter_infos['Central:NaturalGasGrill'] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    @model.getSpaces.each do |space|
      next if space.buildingUnit.is_initialized

      space.gasEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameGasGrill

        custom_meter_infos['Central:NaturalGasGrill']['key_var_groups'] << [equip.name.to_s, 'Gas Equipment Gas Energy']
      end
    end
  end

  def natural_gas_lighting(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:NaturalGasLighting"] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.gasEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameGasLighting

        custom_meter_infos["#{unit.name}:NaturalGasLighting"]['key_var_groups'] << [equip.name.to_s, 'Gas Equipment Gas Energy']
      end
    end

    custom_meter_infos['Central:NaturalGasLighting'] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    @model.getSpaces.each do |space|
      next if space.buildingUnit.is_initialized

      space.gasEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameGasLighting

        custom_meter_infos['Central:NaturalGasLighting']['key_var_groups'] << [equip.name.to_s, 'Gas Equipment Gas Energy']
      end
    end
  end

  def natural_gas_fireplace(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:NaturalGasFireplace"] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.gasEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameGasFireplace

        custom_meter_infos["#{unit.name}:NaturalGasFireplace"]['key_var_groups'] << [equip.name.to_s, 'Gas Equipment Gas Energy']
      end
    end

    custom_meter_infos['Central:NaturalGasFireplace'] = { 'fuel_type' => 'NaturalGas', 'key_var_groups' => [] }
    @model.getSpaces.each do |space|
      next if space.buildingUnit.is_initialized

      space.gasEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameGasFireplace

        custom_meter_infos['Central:NaturalGasFireplace']['key_var_groups'] << [equip.name.to_s, 'Gas Equipment Gas Energy']
      end
    end
  end

  def electricity_well_pump(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityWellPump"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameWellPump

        custom_meter_infos["#{unit.name}:ElectricityWellPump"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def electricity_recirc_pump(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityRecircPump"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameHotWaterRecircPump

        custom_meter_infos["#{unit.name}:ElectricityRecircPump"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end

  def electricity_vehicle(custom_meter_infos, unit, thermal_zones)
    custom_meter_infos["#{unit.name}:ElectricityVehicle"] = { 'fuel_type' => 'Electricity', 'key_var_groups' => [] }
    unit.spaces.each do |space|
      space.electricEquipment.each do |equip|
        next unless equip.endUseSubcategory.include? Constants.ObjectNameElectricVehicle

        custom_meter_infos["#{unit.name}:ElectricityVehicle"]['key_var_groups'] << [equip.name.to_s, 'Electric Equipment Electric Energy']
      end
    end
  end
end

class Electricity
  def initialize; end
  attr_accessor :heating, :central_heating, :cooling, :central_cooling, :interior_lighting, :exterior_lighting, :exterior_holiday_lighting,
                :garage_lighting, :interior_equipment, :fans_heating, :fans_cooling, :pumps_heating, :central_pumps_heating, :pumps_cooling,
                :central_pumps_cooling, :water_systems, :photovoltaics, :refrigerator, :clothes_washer, :clothes_dryer, :cooking_range,
                :dishwasher, :plug_loads, :house_fan, :range_fan, :bath_fan, :ceiling_fan, :extra_refrigerator, :freezer, :pool_heater,
                :pool_pump, :hot_tub_heater, :hot_tub_pump, :well_pump, :recirc_pump, :vehicle, :total_end_uses
end

class NaturalGas
  def initialize; end
  attr_accessor :heating, :central_heating, :interior_equipment, :water_systems, :clothes_dryer, :cooking_range, :pool_heater,
                :hot_tub_heater, :grill, :lighting, :fireplace, :total_end_uses
end

class FuelOil
  def initialize; end
  attr_accessor :heating, :central_heating, :interior_equipment, :water_systems, :total_end_uses
end

class Propane
  def initialize; end
  attr_accessor :heating, :central_heating, :interior_equipment, :water_systems, :clothes_dryer, :cooking_range, :total_end_uses
end

class Wood
  def initialize; end
  attr_accessor :heating, :total_end_uses
end

class HoursSetpointNotMet
  def initialize; end
  attr_accessor :heating, :cooling
end
