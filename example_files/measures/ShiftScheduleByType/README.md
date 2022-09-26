

###### (Automatically generated documentation)

# ShiftScheduleByType

## Description
This measure was developed for the URBANopt Class Project and shifts specific building schedules if they include cooling ("CLG"), heating ("HTG"), or air ("Air") strings. The measure will shift these chosen schedules by an amount specified by the user and will also output a .csv file of the schedules before and after the shift.

## Modeler Description
Depending on the model's thermostat deadband settings, shifting of exclusively cooling or heating schedules can result in EnergyPlus deadband errors. It is recommended to shift both cooling and heating schedules using the 'coolheat' option for schedchoice. If no schedules for the current model include the cooling, heating, or air strings, none will be shifted. Schedules including the string 'setback' are intentionally excluded from shifts in order to prevent EnergyPlus errors.

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Shift Schedule Profiles Forward (24hr, use decimal for sub hour and negative values for backward shift).

**Name:** shift_value,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Choose which schedule class(es) to shift by the specified shift value

**Name:** schedchoice,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false




