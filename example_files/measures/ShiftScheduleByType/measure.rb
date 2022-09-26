# *******************************************************************************
# OpenStudio(R), Copyright (c) 2008-2021, Alliance for Sustainable Energy, LLC.
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# (1) Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# (2) Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# (3) Neither the name of the copyright holder nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission from the respective party.
#
# (4) Other than as required in clauses (1) and (2), distributions in any form
# of modifications or other derivative works may not use the "OpenStudio"
# trademark, "OS", "os", or any other confusingly similar designation without
# specific prior written permission from Alliance for Sustainable Energy, LLC.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER(S) AND ANY CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER(S), ANY CONTRIBUTORS, THE
# UNITED STATES GOVERNMENT, OR THE UNITED STATES DEPARTMENT OF ENERGY, NOR ANY OF
# THEIR EMPLOYEES, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# *******************************************************************************

# see the URL below for information on how to write OpenStudio measures
# http://openstudio.nrel.gov/openstudio-measure-writing-guide

# see the URL below for access to C++ documentation on model objects (click on "model" in the main window to view model objects)
# http://openstudio.nrel.gov/sites/openstudio.nrel.gov/files/nv_data/cpp_documentation_it/model/html/namespaces.html

# This measure was created as an adaptation of the "ShiftScheduleProfileTime" common
# measure. This measure adds the ability to choose types (Cooling/Heating) of 
# schedules to shift instead of choosing all schedules or one schedule.

# Start the measure
class ShiftScheduleByType < OpenStudio::Measure::ModelMeasure
  # define the name that a user will see, this method may be deprecated as
  # the display name in PAT comes from the name field in measure.xml
  def name
    return 'ShiftScheduleByType'
  end

  # human readable description
  def description
    return 'This measure was developed for the URBANopt Class Project and shifts specific building schedules if they include cooling ("CLG"), heating ("HTG"), or air ("Air") strings. The measure will shift these chosen schedules by an amount specified by the user and will also output a .csv file of the schedules before and after the shift.'
  end

  # human readable description of modeling approach
  def modeler_description
    return "Depending on the model's thermostat deadband settings, shifting of exclusively cooling or heating schedules can result in EnergyPlus deadband errors. It is recommended to shift both cooling and heating schedules using the 'coolheat' option for schedchoice. If no schedules for the current model include the cooling, heating, or air strings, none will be shifted. Schedules including the string 'setback' are intentionally excluded from shifts in order to prevent EnergyPlus errors."
  end

  # Define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # Argument to specify the amount of time by which the chosen schedule(s) will be shifted
    shift_value = OpenStudio::Measure::OSArgument.makeDoubleArgument('shift_value', true)
    shift_value.setDisplayName('Shift Schedule Profiles Forward (24hr, use decimal for sub hour and negative values for backward shift).')
    shift_value.setDefaultValue(1)
    args << shift_value

    # Argument to choose which schedules will be shifted
    choices = OpenStudio::StringVector.new
    choices << 'Cooling' 
    choices << 'Heating'
    choices << 'CoolHeat'
    schedchoice = OpenStudio::Measure::OSArgument.makeChoiceArgument('schedchoice', choices)
    schedchoice.setDisplayName('Choose which schedule class(es) to shift by the specified shift value')
    schedchoice.setDefaultValue('CoolHeat')
    args << schedchoice

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end
    
    # Export CSV file with Schedule setpoints before schedule shifts
    #model1 = runner.lastOpenStudioModel
    #model = model1.get
    interval = 60
    header = []
    header << 'Time'
    schedules = []
    model.getScheduleDays.each do |schedule|
      header << schedule.name.get
      schedules << schedule
    end

    dt = OpenStudio::Time.new(0, 0, interval, 0)
    time = OpenStudio::Time.new(0, 0, 0, 0)
    stop = OpenStudio::Time.new(1, 0, 0, 0)
    values = []
    while time <= stop
      row = []
      row << time.to_s
      schedules.each do |schedule|
        row << schedule.getValue(time)
      end
      values << row

      time += dt
    end
    
    runner.registerInfo("Writing CSV report 'schedulereportbefore.csv'")
    File.open('schedulereportbefore.csv', 'w') do |file|
      file.puts header.join(',')
      values.each do |row|
        file.puts row.join(',')
      end
    end
    
    # populate choice argument for schedules that are applied to surfaces in the model
    schedule_handles = OpenStudio::StringVector.new
    schedule_display_names = OpenStudio::StringVector.new

    # putting space types and names into hash
    schedule_args = model.getScheduleRulesets
    schedule_args_hash = {}
    schedule_args.each do |schedule_arg|
      schedule_args_hash[schedule_arg.name.to_s] = schedule_arg
    end

    # looping through sorted hash of schedules
    schedule_args_hash.sort.map do |key, value|
      # only include if schedule use count > 0
      if value.directUseCount > 0
        schedule_handles << value.handle.to_s
        schedule_display_names << key
      end
    end

    # Assign the user inputs to variables
    shift_value = runner.getDoubleArgumentValue('shift_value', user_arguments)
    schedchoice = runner.getStringArgumentValue('schedchoice', user_arguments)

    apply_to_all_schedules = true

    # Check shift value for reasonableness
    if (shift_value / 24) == (shift_value / 24).to_i
      runner.registerAsNotApplicable('No schedule shift was requested, the model was not changed.')
    end

    # Get schedules for measure
    schedules = []
    if apply_to_all_schedules
      raw_schedules = model.getScheduleRulesets
      raw_schedules_hash = {}
      raw_schedules.each do |raw_schedule|
        raw_schedules_hash[raw_schedule.name.to_s] = raw_schedule
      end
  
      # Looping through sorted hash of schedules
      raw_schedules_hash.sort.map do |name, value|
        # Only include if the schedule is used in the model
        if value.directUseCount > 0
          schedule_handles << value.handle.to_s
          schedule_display_names << name
          runner.registerInfo("Searching Schedule: #{name}")
          if !name.downcase.include?("setback")
            if schedchoice == "Cool" # Cooling and Air Only
              if (name.to_s.include?("CLG") || name.to_s.include?("Air"))
                # ADD v to Cooling list
                schedules << value
                runner.registerInfo("Schedule #{name} does contain 'CLG' or 'Air'")
              else
                runner.registerInfo("Schedule #{name} does not contain 'CLG' or 'Air'")
              end
            elsif schedchoice == "Heat" # Heating and Air Only
              if (name.to_s.include?("HTG") || name.to_s.include?("Air"))
                # ADD v to Heating list
                schedules << value
                runner.registerInfo("Schedule #{name} does contain 'HTG' or 'Air'")
              else
                runner.registerInfo("Schedule #{name} does not contain 'HTG' or 'Air'")
              end
            elsif schedchoice == "CoolHeat" # Cooling, Heating, and Air
              if (name.to_s.include?("CLG") || name.to_s.include?("HTG") || name.to_s.include?("Air"))
                # ADD v to Cooling/Heating list
                schedules << value
                runner.registerInfo("Schedule #{name} does contain 'CLG' or 'HTG' or 'Air'")
              else
                runner.registerInfo("Schedule #{name} does not contain 'CLG' or 'HTG' or 'Air'")
              end
            else
              runner.registerError('Unexpected value of schedchoice: ' + schedchoice + '.')
              return false
            end
          end
        end
      end

    else
      runner.registerAsNotApplicable('No schedules included in shift')
    end

    # Loop through all chosen schedules
    schedules.each do |schedule|
      # Array of all profiles to change
      profiles = []

      # Push default profiles to array
      default_rule = schedule.defaultDaySchedule
      profiles << default_rule

      # Push profiles to array
      rules = schedule.scheduleRules
      rules.each do |rule|
        day_sch = rule.daySchedule
        profiles << day_sch
      end

      # Add design days to array
      summer_design = schedule.summerDesignDaySchedule
      winter_design = schedule.winterDesignDaySchedule
      profiles << summer_design
      profiles << winter_design

      # Reporting initial condition of model
      if apply_to_all_schedules
        runner.registerInitialCondition("#{schedules.size} schedules are shifted in this model.")
      else
        runner.registerInitialCondition("Schedule #{schedule.name} has #{profiles.size} profiles including design days.")
      end

      # Rename schedule
      schedule.setName("#{schedule.name} - (shifted #{shift_value} hours)")

      shift_hours = shift_value.to_i
      shift_minutes = ((shift_value - shift_value.to_i) * 60).to_i

      # Give info messages as I change specific profiles
      runner.registerInfo("Adjusting #{schedule.name}")

      # Edit profiles
      profiles.each do |day_sch|
        times = day_sch.times
        values = day_sch.values

        runner.registerInfo("Old day_sch: #{day_sch}")
        runner.registerInfo("Old Times: #{times}")
        runner.registerInfo("Old Values: #{values}")

        # Time objects to use in measure
        time_0 = OpenStudio::Time.new(0, 0, 0, 0)
        time_24 =  OpenStudio::Time.new(0, 24, 0, 0)
        shift_time = OpenStudio::Time.new(0, shift_hours, shift_minutes, 0)

        # Arrays for values to avoid overlap conflict of times
        new_times = []
        new_values = []

        if values.length < 2 # Avoid adjusting schedules with only one cooling/heating/air setpoint
          new_times = times
          new_values = values
        else # Adjust schedules with more than 3 setpoints
          # Create a pair of times and values for what will be 0 time after adjustment
          new_times << time_24
          if shift_time > time_0
            new_values << day_sch.getValue(time_24 - shift_time)
          else
            new_values << day_sch.getValue(time_0 - shift_time)
          end

          # Clear values
          day_sch.clearValues

          # Unfreeze arrays before editing
          times = times.clone(freeze: false) if times.frozen?
          values = values.clone(freeze: false) if values.frozen?

          if values.length == 2
            timeschg = values.length - 2
          else 
            timeschg = values.length - 3
          end

          # Count number of arrays
          for i in 0..timeschg 
            new_time = times[i] + shift_time
            # Adjust wrap around times for times that are t > 24 or t < 0
            if new_time < time_0
              new_time = new_time + time_24
              values.rotate(1) # Move first value to last value in array
              runner.registerWarning("Times adjusted for wrap around due to new time < 0.")
            elsif new_time > time_24
              new_time = new_time - time_24
              values.rotate(-1) # Move last value to first value in array
              runner.registerWarning("Times adjusted for wrap around due to new time > 24.")
            else # If 0 < new_time < 24
              new_time = new_time
            end
            # Make new values
            new_times = times.insert(i, new_time)
            new_times.delete_at(i+1)
          end

          new_values = values # Set new values equal to original schedule values
          new_times.freeze

        end

        if values.length <= 4
          timeschg = values.length - 1
        else
          timeschg = values.length - 2
        end

        for i in 0..(timeschg)
          day_sch.addValue(new_times[i], new_values[i])
        end
        runner.registerInfo("New day_sch: #{day_sch}")
        runner.registerInfo("New Times: #{new_times}")
        runner.registerInfo("New Values: #{new_values}")
      end
    end

    # Report final condition of model
    if apply_to_all_schedules
      runner.registerFinalCondition('Shifted time for all profiles for all schedules.')
    else
      runner.registerFinalCondition("Shifted time for all profiles used by this schedule.")
    end
    
    # Export CSV file with Schedule setpoints after schedule shifts
    #model = runner.lastOpenStudioModel
    #model = model.get
    interval = 60

    header = []
    header << 'Time'
    schedules = []

    model.getScheduleDays.each do |schedule|
      header << schedule.name.get
      schedules << schedule
    end

    dt = OpenStudio::Time.new(0, 0, interval, 0)
    time = OpenStudio::Time.new(0, 0, 0, 0)
    stop = OpenStudio::Time.new(1, 0, 0, 0)
    values = []
    while time <= stop
      row = []
      row << time.to_s
      schedules.each do |schedule|
        row << schedule.getValue(time)
      end
      values << row

      time += dt
    end

    runner.registerInfo("Writing CSV report 'schedulereportafter.csv'")
    File.open('schedulereportafter.csv', 'w') do |file|
      file.puts header.join(',')
      values.each do |row|
        file.puts row.join(',')
      end
    end
    
    return true
  end
end

# Allow the measure to be used by the application
ShiftScheduleByType.new.registerWithApplication
