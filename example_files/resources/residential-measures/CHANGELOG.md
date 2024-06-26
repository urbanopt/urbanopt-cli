## ResStock v3.2.0
###### December 19, 2023 - [Diff](https://github.com/NREL/resstock/compare/v3.1.1...v3.2.0)

Features
- Add ability to calculate simple utility bills based on a user-specified TSV file of utility rates ([#1012](https://github.com/NREL/resstock/pull/1012))
- Add 2022 Cambium emissions data ([#1038](https://github.com/NREL/resstock/pull/1038))
- Update characteristics to use EIA 2020 RECS ([#1031](https://github.com/NREL/resstock/pull/1031))
- Add Energystar Climate Zone for window upgrade specification ([#1080](https://github.com/NREL/resstock/pull/1080))
- Include HVAC secondary heating capabilities for project_testing ([#1090](https://github.com/NREL/resstock/pull/1090))
- For heat pump upgrades, adds the ability to set the existing primary (non-shared) heating system as the backup system using only a single option from the lookup ([#1074](https://github.com/NREL/resstock/pull/1074))
- options_saturations.csv is added to project_*/resources/ folder ([#1132](https://github.com/NREL/resstock/pull/1132))
- Update `run_analysis.rb` to map datapoints to run folder names when the `-k` argument is supplied ([#1138](https://github.com/NREL/resstock/pull/1138))
- Add Water Heater Location and Geometry Space Combination, update Geometry Garage and Geometry Floor Area Bin to RECS2020, update RECS2020 microdata from v2 to v4, auto-generate buildstocks for yml_precomputed tests ([#1125](https://github.com/NREL/resstock/pull/1125))
- Add ability to request timeseries resilience output from the yml file ([#1113](https://github.com/NREL/resstock/pull/1113))
- Add ability to calculate detailed utility bills based on a user-specified TSV file of paths to JSON utility rate tariff files ([#1109](https://github.com/NREL/resstock/pull/1109))
- Update to OpenStudio v3.7.0 ([#1144](https://github.com/NREL/resstock/pull/1144))
- Update to RECS 2020 V5 data files ([#1164](https://github.com/NREL/resstock/pull/1164))
- Automate creation of new "Arguments" documentation sections for summarizing arguments (and their default values) in options_lookup.tsv ([#1146](https://github.com/NREL/resstock/pull/1146))
- Add variability in ground thermal conductivity ([#1165](https://github.com/NREL/resstock/pull/1165))

Fixes
- Set standard format for options_lookup ([#962](https://github.com/NREL/resstock/pull/962))
- Model a wood storage water heater when "Other Fuel" is sampled from Water Heater Efficiency.tsv (allowing downstream modeling of clothes washer/dryer). Similarly, model a wood wall/floor furnace when "Other" is sampled from HVAC Heating Efficiency.tsv ([#947](https://github.com/NREL/resstock/pull/947))
- Update ResStockArguments to support nonzero fraction of heat load served by the secondary heating system ([#1090](https://github.com/NREL/resstock/pull/1090))
- Fix square footage for a MF dwelling unit in the "3000-3999" CFA bin (from 33171 to 3171) ([#1115](https://github.com/NREL/resstock/pull/1115))
- Fix/clarify duct location assignment by defining Duct Location.tsv, making Duct Leakage and Insulation (formerly Duct) depend on Duct Location, and making HVAC Has Ducts depend on HVAC Has Shared Systems. Includes fixes on standalone and shared heating system assignment for Other Fuel. ([#1104](https://github.com/NREL/resstock/pull/1104), [#1112](https://github.com/NREL/resstock/pull/1112))
- Correct refrigerator rated annual kWh based on EF and an assumed volume of 20.9cft. ([#1118](https://github.com/NREL/resstock/pull/1118))
- Minor changes to heating and cooling setpoint TSV due to refactoring of prune_rules handling in resstock-estimation ([#1132](https://github.com/NREL/resstock/pull/1132))
- Minor changes to heating and cooling setpoint TSV after a bug fix ([#1136](https://github.com/NREL/resstock/pull/1136))
- Update `run_analysis.rb` to handle illegal path characters in upgrade names ([#1138](https://github.com/NREL/resstock/pull/1138))
- Update TMY3 weather URL from the NREL Data Catalog ([#1182](https://github.com/NREL/resstock/pull/1182))

## ResStock v3.1.1
###### November 28, 2023 - [Diff](https://github.com/NREL/resstock/compare/v3.1.0...v3.1.1)

Fixes
- Use `Gem::Version` on buildstockbatch version string comparisons so that, e.g., '2023.10.0' < '2023.5.0' does not evaluate to true ([#1170](https://github.com/NREL/resstock/pull/1170))

## ResStock v3.1.0
###### May 25, 2023 - [Diff](https://github.com/NREL/resstock/compare/v3.0.0...v3.1.0)

Features
- Include battery modeling capabilities for project_testing ([#1009](https://github.com/NREL/resstock/pull/1009))
- Ability to check buildstock csv against an options lookup as a command line utility ([#1042](https://github.com/NREL/resstock/pull/1042))
- Demonstrate new power outage modeling feature using upgrades specified in example project yml files ([#1054](https://github.com/NREL/resstock/pull/1054))
- Ability to specify a "sample_weight" column in the precomputed buildstock.csv ([#1056](https://github.com/NREL/resstock/pull/1056))
- Add descriptions to the housing characteristics ([#1069](https://github.com/NREL/resstock/pull/1069))
- Connect ASHP to optional capacity retention temperature and fraction arguments (that already exist for MSHP) ([#1071](https://github.com/NREL/resstock/pull/1071))
- Add data dictionary files for describing various outputs. Use these files to (1) check against integration test results, and (2) generate documentation tables ([#1058](https://github.com/NREL/resstock/pull/1058))
- OS-HPXML now supports use of optional heat pump capacity retention temperature and fraction arguments (applicable to both ASHP and MSHP) ([#1072](https://github.com/NREL/resstock/pull/1072))
- Update to OpenStudio v3.6.1 ([#1076](https://github.com/NREL/resstock/pull/1076))

Fixes
- Pulls in upstream OS-HPXML fix related to [avoiding possible OpenStudio temporary directory collision](https://github.com/NREL/OpenStudio-HPXML/pull/1316) causing random errors ([#1054](https://github.com/NREL/resstock/pull/1054))
- Pulls in upstream OS-HPXML fix related to [falling back to a WWR calculation when window placement fails](https://github.com/NREL/OpenStudio-HPXML/pull/1385) causing errors fitting windows ([#1076](https://github.com/NREL/resstock/pull/1076))

## ResStock v3.0.0
###### February 3, 2023 - [Diff](https://github.com/NREL/resstock/compare/v2.5.0...v3.0.0)

Features
- Transition to using the HPXML-based workflow ([#443](https://github.com/NREL/resstock/pull/443))
- Add a new "Floor Area, Foundation (ft^2)" cost multiplier ([#870](https://github.com/NREL/resstock/pull/870))
- Add a new "Floor Area, Attic * Insulation Increase (ft^2 * Delta R-value)" cost multiplier for handling incremental costs of adding attic insulation ([#842](https://github.com/NREL/resstock/pull/842))
- Allow air leakage % reduction upgrades (e.g., 25%), and add a new "Floor Area, Conditioned * Infiltration Reduction (ft^2 * Delta ACH50)" cost multiplier for handling incremental costs of such upgrades ([#840](https://github.com/NREL/resstock/pull/840))
- For the testing project, sample equal distributions of (1) smooth and stochastic schedules (each 50%) and (2) faulted and non-faulted HVAC systems (each 50%) ([#828](https://github.com/NREL/resstock/pull/828))
- Allow upgrade options to be defined in the lookup using measures other than ResStockArguments ([#839](https://github.com/NREL/resstock/pull/839))
- Enable rim joists for homes with basements/crawlspaces; assumes a height of 9.25 inches and calculates rim joist assembly R-value from new insulation arguments ([#831](https://github.com/NREL/resstock/pull/831))
- Enable the HEScore workflow to be run with BuildExistingModel ([#782](https://github.com/NREL/resstock/pull/782))
- Cities with more than 15,000 dwelling units are added as a geographic characteristic ([#874](https://github.com/NREL/resstock/pull/874))
- Update tsvs with new sampling_probability calculation ([#905](https://github.com/NREL/resstock/pull/905))
- Improve distributions of heat pumps in the southeast U.S. by spliting IECC zone 2A into two zones: 2A (FL, GA, AL, MS) and 2A (TX, LA) ([#913](https://github.com/NREL/resstock/pull/913))
- Add Income and Tenure tsv, update PUMS tsvs from 2017 5-yrs to 2019 5-yrs, update dependencies and fix encoding error in Occupants.tsv ([#900](https://github.com/NREL/resstock/pull/900))
- Add Income and Tenure into Geometry Floor Area ([#949](https://github.com/NREL/resstock/pull/949))
- Add distributions for partial space cooling ([#964](https://github.com/NREL/resstock/pull/964))
- Add ability to calculate emissions for various scenarios ([#791](https://github.com/NREL/resstock/pull/791))
- Add ability to calculate simple utility bills for various scenarios ([#984](https://github.com/NREL/resstock/pull/984))
- Modeled floor area based on AHS 2021 and AHS 2019 ([#978](https://github.com/NREL/resstock/pull/978))
- Add area median income ([#1004](https://github.com/NREL/resstock/pull/1004))
- Update to OpenStudio v3.5.1 ([#1006](https://github.com/NREL/resstock/pull/1015))

Fixes
- Clean up option names for natural ventilation and hot water distribution ([#828](https://github.com/NREL/resstock/pull/828))
- Remove the zero degree switchover temperature for heat pump backup heating ([#833](https://github.com/NREL/resstock/pull/833))
- For homes with a finished attic or cathedral ceilings, models a conditioned attic instead of a vented attic ([#830](https://github.com/NREL/resstock/pull/830))
- Reduce housing characteristic file size by relaxing the six digit float format in the housing characteristics ([#877](https://github.com/NREL/resstock/pull/877))
- Fix minor bug in sampling probability calculation ([#934](https://github.com/NREL/resstock/pull/934)) 
- Rename sources subfolders so all tsv_makers can be imported as packages ([#959](https://github.com/NREL/resstock/pull/959))
- Fix heating and cooling auto-season inputs ([#975](https://github.com/NREL/resstock/pull/975))
- Remove Void from dependency columns in TSVs and update tests.([#981](https://github.com/NREL/resstock/pull/981))
- Update low-sample downscaling logic to use raw source_weight, which leads to minor changes to Geometry Floor Area and HVAC Partial Space Conditioning ([#982](https://github.com/NREL/resstock/pull/982))

## ResStock v2.5.0
###### February 9, 2022 - [Diff](https://github.com/NREL/OpenStudio-BuildStock/compare/v2.4.0...v2.5.0)

Features
- Update to OpenStudio v3.3.0 ([#604](https://github.com/NREL/resstock/pull/604))
- Model multifamily and single-family attached buildings as individual dwelling units instead of multiple units representing a building ([#439](https://github.com/NREL/resstock/pull/439))
- Reduce vacant unit heating setpoints to 55ºF ([#541](https://github.com/NREL/resstock/pull/541))
- Introduce a CEC Building Climate Zone tag for samples in California ([#548](https://github.com/NREL/resstock/pull/548))
- Increase LED saturation to approximately 2019 levels ([#545](https://github.com/NREL/resstock/pull/545))
- Introduce GEB capabilities for water heaters, including the ability to schedule setpoint and HPWH operating mode ([#483](https://github.com/NREL/resstock/pull/483))
- Introduce different cooling setpoint distributions for window ACs ([#551](https://github.com/NREL/resstock/pull/551))
- Include electric zonal heating equipment as a dependency in heating setpoint-related tsvs ([#549](https://github.com/NREL/resstock/pull/549))
- Geo-temporal shifting of the stochastic load model schedules using the American Time Use Survey ([#550](https://github.com/NREL/resstock/pull/550))
- Switch data source for `Geometry Wall Type.tsv` from RECS 2009 to Homeland Infrastructure Foundation-Level Data (HIFLD) Parcel data ([#561](https://github.com/NREL/resstock/pull/561))
- Use Schedule:File with well pump / vehicle plug loads, as well as gas grill / fireplace / lighting fuel loads. This enables the optional vacancy period to apply to these end uses ([#566](https://github.com/NREL/resstock/pull/556))
- Update example project yaml files to use buildstockbatch input schema version 0.3 ([#583](https://github.com/NREL/resstock/pull/583))
- Update default daylight saving start and end dates to March 12 and November 5, respectively ([#585](https://github.com/NREL/resstock/pull/585))
- Switches room air conditioner model to use Cutler performance curves ([#586](https://github.com/NREL/resstock/pull/586))
- Remove 3 story limit for multi-family buildings, and instead use RECS data to allow for buildings up to 21 stories ([#558](https://github.com/NREL/resstock/pull/558))
- Add a sampling probability column in the housing characteristics to define the probability a given column will be sampled ([#584](https://github.com/NREL/resstock/pull/584))
- Add ReEDS balancing areas as a spatial field ([#591](https://github.com/NREL/resstock/pull/591))
- Changes heat pump defrost control from OnDemand to Timed ([#605](https://github.com/NREL/resstock/pull/605))
- Update number of bathrooms assumption to match the Building America House Simulation Protocols ([#601](https://github.com/NREL/resstock/pull/601))
- Speed up sampling algorithm by multiple orders of magnitude for large numbers of samples ([#606](https://github.com/NREL/resstock/pull/606))
- Use ANSI/RESNET/ICC 301 equations to calculate annual interior, exterior, and garage lighting energy ([#619](https://github.com/NREL/resstock/pull/619))
- Update tsv files for both the national and testing projects. Supports transition to ResStock-HPXML ([#559](https://github.com/NREL/resstock/pull/559))
- Changes "Duct Surface Area (ft^2)" cost multiplier to "Duct Unconditioned Surface Area (ft^2)" ([#634](https://github.com/NREL/resstock/pull/634))
- Update window type distributions using RECS 2015. Includes additional of frame material types (RECS 2015) and presence of storm windows (D&R International) ([#615](https://github.com/NREL/resstock/pull/615))
- Reduces window interior shading during Winter to match ANSI/RESNET/ICC 301 assumption ([#649](https://github.com/NREL/resstock/pull/649))
- Updates ceiling fan model based on ANSI/RESNET ICC 301 assumptions ([#652](https://github.com/NREL/resstock/pull/652))
- Updates infiltration model pressure coefficient ([#670](https://github.com/NREL/resstock/pull/670))
- Updates mechanical ventilation options/model to ASHRAE 62.2-2019 and adds a "Flow Rate, Mechanical Ventilation (cfm)" output ([#675](https://github.com/NREL/resstock/pull/675))
- Add PV ownership and PV system size distributions using 2019 Tracking the Sun and GTM report on solar installation. ([#673](https://github.com/NREL/resstock/pull/673))
- Add optional argument to ResidentialLocation measure for setting the IECC climate zone ([#755](https://github.com/NREL/resstock/pull/764))
- Add Geometry Story Bin tsv and Geometry Story Bin dependency to Geometry Wall Type. ([#759](https://github.com/NREL/resstock/pull/759))
- Add arguments to the ServerDirectoryCleanup measure for controlling deletion of files in the run folder. ([#661](https://github.com/NREL/resstock/pull/661), [#818](https://github.com/NREL/resstock/pull/818))

Fixes
- Fixes significant runtime bottleneck in TSV fetching in BuildExistingModel & ApplyUpgrade measures ([#543](https://github.com/NREL/resstock/pull/543))
- Dwelling units that are 0-499 ft2 are limited to a maximum of 2 bedrooms ([#553](https://github.com/NREL/resstock/pull/553))
- Reverses the material layers of the unfinished attic floor construction so that they are correctly ordered outside-to-inside ([#556](https://github.com/NREL/resstock/pull/556))
- Fixes invalid garage and living space dimension errors ([#560](https://github.com/NREL/resstock/pull/560))
- Set all mini-split heat pump supplemental capacity to autosize ([#564](https://github.com/NREL/resstock/pull/564))
- Reduce stochastic schedule generation runtime by over 50% ([#571](https://github.com/NREL/resstock/pull/571), [#577](https://github.com/NREL/resstock/pull/577))
- Fixes the problem that `Heating Type=Void` is showing up in buildstock samples ([#568](https://github.com/NREL/resstock/pull/568))
- Set AZ counties to NA daylight saving times instead of some AR counties ([#585](https://github.com/NREL/resstock/pull/585)) 
- Housing characteristics fixes based on more samples in testing ([#592](https://github.com/NREL/resstock/pull/592))
- Fixes window-to-wall ratio calculation for facades with doors ([#597](https://github.com/NREL/resstock/pull/597))
- Fixes number of bathrooms for single-family attached and multi-family buildings ([#601](https://github.com/NREL/resstock/pull/601))
- Sync the sample probabilities after a bug fix in tsv_dist ([#609](https://github.com/NREL/resstock/pull/609))
- Fix name of ReEDS balancing areas ([#613](https://github.com/NREL/resstock/pull/613))
- Fixes hot water distribution internal gains not being zeroed out during vacancies ([#653](https://github.com/NREL/resstock/pull/653))
- Exclude adiabatic doors when outputting the door area cost multiplier ([#674](https://github.com/NREL/resstock/pull/674))
- Disaggregate the shared fan coil's fan energy use into heating and cooling ([#694](https://github.com/NREL/resstock/pull/694))
- Fixes hours setpoint not met output to exclude A) no heating and/or cooling equipment and B) finished basements ([#700](https://github.com/NREL/resstock/pull/700))
- Revert wall type constraint that assumes all brick facades built >1960 are wood-framed with 4" face brick. Also add constraint to force all buildings > 8 stories to have steel-framed wall type ([#759](https://github.com/NREL/resstock/pull/759))
- Fixes for wall constructions: remove wood sheathing on CMU and brick walls; better data for exterior finish absorptances and wall densities ([#789](https://github.com/NREL/resstock/pull/789))
- Fixes unit conversion bugs in solar hot water model ([#809](https://github.com/NREL/resstock/pull/809))
- Update the number of units represented in the national project YAML files to the American Community Survey 2019 5-year estimate ([#821](https://github.com/NREL/resstock/pull/821))
- Properly apply roof insulation when the attic type is Finished Attic or Cathedral Ceilings ([#817](https://github.com/NREL/resstock/pull/817))

## ResStock v2.4.0
###### January 27, 2021 - [Diff](https://github.com/NREL/OpenStudio-BuildStock/compare/v2.3.0...v2.4.0)

Features
- Report the annual peak use and timing using the quantities of interest measure ([#458](https://github.com/NREL/resstock/pull/458))
- Major change to most occupant-related schedules. Occupant activities are now generated on-the-fly and saved to .csv files used by Schedule:File objects. Schedules are generated using time-inhomogenous Markov chains derived from American Time Use Survey data, supplemented with sampling duration and power level from NEEA RBSA data, as well as DHW draw duration and flow rate data from Aquacraft/AWWA data [(see pre-print for details)](https://arxiv.org/abs/2111.01881) ([#348](https://github.com/NREL/resstock/pull/348))
- Update the dependencies for heating and cooling setpoint tsvs (Setpoint, Has Offset, Offset Magnitude, and Offset Period) to IECC climate zone ([#468](https://github.com/NREL/resstock/pull/468))
- Distinguish between vacant and occupied dwelling units using PUMS data ([#473](https://github.com/NREL/resstock/pull/473))
- Update heating fuel distributions to be by Public Use Microdata Area (PUMA) rather than State ([#474](https://github.com/NREL/resstock/pull/474))
- Restructure HVAC housing characteristics to 1) simplify the structure, 2) allow for integrating more local data sources, 3) update reference years for HVAC and refrigerator ages and efficiencies from 2009 to 2018, 4) add assumption comments to all HVAC-related housing characteristics, 5) improve Room AC efficiency distributions using ENERGY STAR saturation data, and 6) fix some incorrect assignment of Option=None heating systems ([#478](https://github.com/NREL/resstock/pull/478))
- Increase roofing material options; update roofing material tsv files to include these new options ([#485](https://github.com/NREL/resstock/pull/485))
- Update foundation type from the [Building Foundation Design Handbook](https://www.osti.gov/biblio/6980439-building-foundation-design-handbook) published in 1988 to RECS 2009 ([#492](https://github.com/NREL/resstock/pull/492))
- Synchronize weather between ResStock and ComStock which increases the number of weather stations from 215 to 941 ([#507](https://github.com/NREL/resstock/pull/507))
- Update Occupants per unit from RECS 2015 to PUMS 5-yr 2017 ([#509](https://github.com/NREL/resstock/pull/509]))
- Based on RECS 2015, separate the plug load equations for single-family detached, single-family attached, and multifamily buildings ([#471](https://github.com/NREL/resstock/pull/471))
- Allow for plug load energy consumption to vary by Census Division and include additional "diversity" multiplier in plug load equations ([#511](https://github.com/NREL/resstock/pull/511))
- Lighting saturations based on RECS 2015 with new building type and spatial dependencies ([#510](https://github.com/NREL/resstock/pull/510]))
- Introduce premium water heaters and heat pump water heaters into building stock, differentiate between central and in-unit water heating, and split water heater fuel and efficiency into different housing characteristics ([#513](https://github.com/NREL/resstock/pull/513))
- Separate heat pump electric supplemental heating from total electric heating in output reporting ([#512](https://github.com/NREL/OpenStudio-BuildStock/pull/512))
- Update the duct leakage "total" to "to outside" conversion to be based on ASHRAE Standard 152 ([#532](https://github.com/NREL/resstock/pull/532))
- Allow for flexible weather regions based on weather data available and introduce TMY3 weather files for the new weather format ([#525](https://github.com/NREL/resstock/pull/525))

Fixes
- Fix for pseudo-random number generator that was generating non-deterministic occupancy schedules ([#477](https://github.com/NREL/resstock/pull/477))
- Iterate all spaces in a thermal zone when checking for zone type; fixes missing infiltration for protruding garages in 1-story homes ([#480](https://github.com/NREL/resstock/pull/480))
- Update spatial distribution of units based on total dwelling unit counts rather than occupied unit counts ([#486](https://github.com/NREL/resstock/pull/486))
- Exclude existing shared walls when calculating the partition wall area of MF and SFA buildings ([#496](https://github.com/NREL/resstock/pull/496))
- For the purpose of calculating cooling and dehumidification loads for HVAC sizing, use simple internal gains equation from ANSI/RESNET/ICC 301 (consistent with HPXML workflow); this fixes a bug introduced in [#348](https://github.com/NREL/resstock/pull/348) that caused cooling capacities to be ~3x larger than they should be ([#501](https://github.com/NREL/resstock/pull/501))
- Reintroduce IECC climate zone dependency to HVAC Cooling Type and some heat pump fixes ([#497](https://github.com/NREL/resstock/pull/497))
- Reintroduce monthly multipliers with stochastic load model for dishwasher, clothes washer and clothes dryer and cooking ([#504](https://github.com/NREL/resstock/pull/504))
- Account for collapsed units when determining geometry variables (building floor/wall area and volume) in infiltration calculations; add airflow unit tests ([#518](https://github.com/NREL/resstock/pull/518))
- Fix for calculating door and below-grade wall area of multifamily and single-family attached buildings with collapsed geometries ([#523](https://github.com/NREL/resstock/pull/523))
- In the Corridor.tsv, assign single-family attached, single-family detached, and mobile homes with a "Not Applicable" option ([#502](https://github.com/NREL/resstock/pull/522))
- Remove ceiling fan energy for vacant units ([#527](https://github.com/NREL/resstock/pull/527))
- Fix bug related to incorrect timestamps when using AMY weather file ([#528](https://github.com/NREL/resstock/pull/528))
- Fix DST start hour error and end date error ([#530](https://github.com/NREL/resstock/pull/530)) 
- Calculate slab surface effective R values used in HVAC sizing with unit-level variables  ([#537](https://github.com/NREL/resstock/pull/537)) 

## ResStock v2.3.0
###### June 24, 2020 - [Diff](https://github.com/NREL/resstock/compare/v2.2.4...v2.3.0)

Features
- Remove the single-family detached project, and remove PAT from the testing and multifamily projects ([#402](https://github.com/NREL/resstock/pull/402))
- Relocate the data folder, along with tsv makers, to a separate private repository ([#401](https://github.com/NREL/resstock/pull/401))
- Update the single-family detached and multifamily projects with more up-to-date lighting stock distributions ([#392](https://github.com/NREL/resstock/pull/392))
- Update Insulation Finished Attic tsv with more options for insulation levels ([#395](https://github.com/NREL/resstock/pull/395))
- Add ability to ignore comment lines with the "#" symbol ([#408](https://github.com/NREL/resstock/pull/408))
- Update occupant and plug loads equations based on RECS 2015 data; replace floor area with occupants as independent variable in plug loads equation; allow modeling of zero-bedroom units (e.g., studios) ([#324](https://github.com/NREL/resstock/pull/324))
- New geospatial characteristics have been added or updated. New geospatial characteristics are as follows: ASHRAE IECC Climate Zone 2004, State, County, PUMA, Census Division, Census Region, Building America Climate Zone, and ISO/RTO Region. The top level housing characteristic is now ASHRAE IECC Climate Zone 2004. Now using data from the American Community Survey Public Use Microdata Sample (ACS PUMS) for Building Type, Vintage, and Heating Fuel ([#416](https://github.com/NREL/resstock/pull/416))
- Update HVAC System Cooling tsv with air-conditioning saturations ("None", "Room AC", or "Central AC") from American Housing Survey for Custom Region 04. Efficiency probabilities remain based on RECS 2009 ([#418](https://github.com/NREL/resstock/pull/418))
- Diversify the timing heating and cooling setpoint setbacks ([#414](https://github.com/NREL/resstock/pull/414))
- Reduce the number of appliances in multifamily units. Adding RECS building type as a dependencies to clothes washers, clothes dryers, dishwashers, refrigerators, extra refrigerators, and stand-alone freezers. Update refrigeration levels based on RECS 2009 age and shipment-weighted efficiency by year. Now using the American Housing Survey (AHS) for clothes washer and clothes dryer saturations. New geographic field, AHS Region, which uses the top 15 largest Core Based Statistical Areas (CBSAs) and Non-CBSA Census Divisions. ([420](https://github.com/NREL/resstock/pull/420))
- Exterior lighting schedule changed from using interior lighting sunrise/sunset algorithm to T24 2016 Residential ACM Appendix C Table 8 Exterior Lighting Hourly Multiplier for weekdays and weekends ([#419](https://github.com/NREL/resstock/pull/419))
- Increase the diversity of the floor areas that are simulated. Geometry House Size has been replaced by Geometry Floor Area Bin and Geometry Floor Area. Now using AHS for specifying the floor area. Floor areas differ by non-Core Based Statistical Areas (CBSAs) Census Divisions and the top 15 largest CBSAs ([#425](https://github.com/NREL/resstock/pull/425))
- Increase the diversity of the infiltration simulated. Now using the Residential Diagnostics Database for the Infiltration housing characteristic ([#427](https://github.com/NREL/resstock/pull/427))
- Allow a key value to be specified when outputting timeseries variables ([#438](https://github.com/NREL/resstock/pull/438))

Fixes
- Rename "project_multifamily_beta" to "project_national" ([#459](https://github.com/NREL/resstock/pull/459))
- Add mini-split heat pump pan heater to custom meter for heating electricity ([#454](https://github.com/NREL/resstock/pull/454))
- Assign daylight saving start/end dates based on county and not epw region ([#453](https://github.com/NREL/resstock/pull/453))
- Update ceiling fan tsv to remove the "National Average" option, and instead sample 28% "None" and 72% "Standard Efficiency" ([#445](https://github.com/NREL/resstock/pull/445))
- Remove Location Weather Filename and Location Weather Year tsvs, and update options lookup to reflect updated weather file changes; weather filenames are now required to match what is in the options lookup ([#432](https://github.com/NREL/resstock/pull/432))
- Fix bug in QOI reporting measure where absence of any heating/cooling/overlap seasons would cause errors ([#433](https://github.com/NREL/resstock/pull/433))
- Restructure unfinished attic and finished roof -related tsv files (i.e., insulation, roof material, and radiant barrier) and options ([#426](https://github.com/NREL/resstock/pull/426))
- Exclude net site energy consumption from annual and timeseries simulation output ("total" now reflects net of pv); change `include_enduse_subcategories` argument default to "true"; report either total interior equipment OR each of its components ([#405](https://github.com/NREL/resstock/pull/405))
- Refactor the tsv maker classes to accommodate more data sources ([#392](https://github.com/NREL/resstock/pull/392))
- Allow a building to be simulated with no water heater; map the "Other Fuel" option from the Water Heater tsv to no water heater ([#375](https://github.com/NREL/resstock/pull/375))
- Revert plug load schedule to RBSA for the National Average option ([#355](https://github.com/NREL/resstock/pull/355))
- Removed the "Geometry Unit Stories SF" and "Geometry Unit Stories MF" housing characteristics. Unit stories are instead represented by the "Geometry Stories" housing characteristic ([#416](https://github.com/NREL/resstock/pull/416))
- Diversify window to wall ratio variation using the Residential Building Stock Assessment (RBSA) II data ([#412](https://github.com/NREL/resstock/pull/412))
- Fix bug in assigning small window areas to surfaces ([#452](https://github.com/NREL/resstock/pull/452))

## ResStock v2.2.5
###### September 24, 2020 - [Diff](https://github.com/NREL/resstock/compare/v2.2.4...v2.2.5)

Fixes
- Update the weather zip file url in each PAT project to point to a different location at data.nrel.gov ([#489](https://github.com/NREL/resstock/pull/489))

## ResStock v2.2.4
###### April 28, 2020 - [Diff](https://github.com/NREL/resstock/compare/v2.2.3...v2.2.4)

Fixes
- Fix bug in options lookup where buildings without heating systems were not being assigned the required "has_hvac_flue" airflow measure argument ([#442](https://github.com/NREL/resstock/pull/442))

## ResStock v2.2.3
###### March 9, 2020 - [Diff](https://github.com/NREL/resstock/compare/v2.2.2...v2.2.3)

Fixes
- Update the weather zip file url in each PAT project to point to data.nrel.gov ([#422](https://github.com/NREL/resstock/pull/422))

## ResStock v2.2.2
###### February 19, 2020 - [Diff](https://github.com/NREL/resstock/compare/v2.2.1...v2.2.2)

Fixes
- Update the datapoint initialization script to download weather files to a common zip filename ([#406](https://github.com/NREL/resstock/pull/406))

## ResStock v2.2.1
###### February 7, 2020 - [Diff](https://github.com/NREL/resstock/compare/v2.2.0...v2.2.1)

Features
- Update the multifamily project with a Geometry Wall Type tsv file for sampling between wood stud and masonry walls ([#382](https://github.com/NREL/resstock/pull/382))

Fixes
- Add generation of the Geometry Wall Type tsv file for the single-family detached project to the 2009 RECS tsv maker; this corrects the tsv file ([#387](https://github.com/NREL/resstock/pull/387))
- Add generation of the Misc Pool tsv file (with Geometry Building Type and Location Region dependencies) to the 2009 RECS tsv maker; this also corrects having pool pumps for all homes ([#387](https://github.com/NREL/resstock/pull/387))
- Refactor the RECS tsv makers for years 2009 and 2015 ([#382](https://github.com/NREL/resstock/pull/382))

## ResStock v2.2.0
###### January 30, 2020 - [Diff](https://github.com/NREL/resstock/compare/v2.1.0...v2.2.0)

Features
- The results csv now optionally reports annual totals for all end use subcategories, including appliances, plug loads, etc. ([#371](https://github.com/NREL/resstock/pull/371))
- Split out national average options so not all homes have all miscellaneous equipment, and add none options to appliances ([#362](https://github.com/NREL/resstock/pull/362))
- Update the single-family detached project with a Geometry Wall Type tsv file for sampling between wood stud and masonry walls ([#357](https://github.com/NREL/resstock/pull/357))
- Made housing characteristics a consistent format. Added integrity check to ensure housing characteristics follow the guildelines specified in read-the-docs ([#353](https://github.com/NREL/resstock/pull/353))
- Include additional "daylight saving time" and "utc time" columns to timeseries csv file to account for one hour forward and backward time shifts ([#346](https://github.com/NREL/resstock/pull/346))
- Update bedrooms and occupants tsv files with options and probability distributions based on RECS 2015 data ([#340](https://github.com/NREL/resstock/pull/340))
- Add new QOIReport measure for reporting seasonal quantities of interest for uncertainty quantification ([#334](https://github.com/NREL/resstock/pull/334))
- Separate tsv files for bedrooms, cooking range schedule, corridor, holiday lighting, interior/other lighting use, pool schedule, plug loads schedule, and refrigeration schedule ([#338](https://github.com/NREL/resstock/pull/338))

Fixes
- Allow Wood Stove option as an upgrade, and account for wood heating energy in simulation output ([#372](https://github.com/NREL/resstock/pull/372))
- Custom meters for ceiling fan, hot water recirc pump, and vehicle end use subcategories were not properly implemented ([#371](https://github.com/NREL/resstock/pull/371))
- Some re-labeling of tsv files, such as "Geometry Building Type" to "Geometry Building Type RECS" and "Geometry Building Type FPL" to "Geometry Building Type ACS" ([#356](https://github.com/NREL/resstock/pull/356))
- Removes option "Auto" from parameter "Occupants" in the options lookup file ([#360](https://github.com/NREL/resstock/pull/360))
- Update the multifamily project's neighbors and orientation tsv files to have geometry building type dependency; remove the now obsolete "Geometry Is Multifamily Low Rise.tsv" file ([#350](https://github.com/NREL/resstock/pull/350))
- Update each PAT project's AMI selection to "2.9.0" ([#346](https://github.com/NREL/resstock/pull/346))
- Fixes for custom output meters: total site electricity double-counting exterior holiday lighting, and garage lighting all zeroes ([#349](https://github.com/NREL/resstock/pull/349))
- Remove shared facades tsv files from the multifamily_beta and testing projects ([#301](https://github.com/NREL/resstock/pull/301))
- Move redundant output meter code from individual reporting measures out into shared resource file ([#334](https://github.com/NREL/resstock/pull/334))
- Fix for the power outages measure where the last hour of the day was not getting the new schedule applied ([#238](https://github.com/NREL/resstock/pull/238))

## ResStock v2.1.0
###### November 5, 2019 - [Diff](https://github.com/NREL/resstock/compare/v2.0.0...v2.1.0)

Features
- Update to OpenStudio v2.9.0 ([#322](https://github.com/NREL/resstock/pull/322))
- Unit tests and performance improvements for integrity checks ([#228](https://github.com/NREL/resstock/pull/228), [#237](https://github.com/NREL/resstock/pull/237), [#239](https://github.com/NREL/resstock/pull/239))
- Register climate zones (BA and IECC) based on the simulation EPW file ([#245](https://github.com/NREL/resstock/pull/245))
- Split ResidentialLighting into separate ResidentialLightingInterior and ResidentialLightingOther (with optional exterior holiday lighting) measures ([#244](https://github.com/NREL/resstock/pull/244), [#252](https://github.com/NREL/resstock/pull/252))
- Additional example workflow osw files using TMY/AMY2012/AMY2014 weather for use in regression testing ([#259](https://github.com/NREL/resstock/pull/259), [#261](https://github.com/NREL/resstock/pull/261))
- Update all projects with new heating/cooling setpoint, offset, and magnitude distributions ([#272](https://github.com/NREL/resstock/pull/272))
- Add new ResidentialDemandResponse measure that allows for 8760 DR schedules to be applied to heating/cooling schedules ([#276](https://github.com/NREL/resstock/pull/276))
- Additional options for HVAC, dehumidifier, clothes washer, misc loads, infiltration, etc. ([#264](https://github.com/NREL/resstock/pull/264), [#278](https://github.com/NREL/resstock/pull/278), [#292](https://github.com/NREL/resstock/pull/292))
- Add EV options and update ResidentialMiscLargeUncommonLoads measure with new electric vehicle argument ([#282](https://github.com/NREL/resstock/pull/282))
- Update ResidentialSimulationControls measure to include a calendar year argument for controlling the simulation start day of week ([#287](https://github.com/NREL/resstock/pull/287))
- Increase number of possible upgrade options from 10 to 25 ([#273](https://github.com/NREL/resstock/pull/273), [#293](https://github.com/NREL/resstock/pull/293))
- Additional "max-tech" options for slab, wall, refrigerator, dishwasher, clothes washer, and lighting ([#296](https://github.com/NREL/resstock/pull/296))
- Add references to ResStock trademark in both the license and readme files ([#302](https://github.com/NREL/resstock/pull/302))
- Report all cost multipliers in the SimulationOutputReport measure ([#304](https://github.com/NREL/resstock/pull/304))
- Add options for low flow fixtures ([#305](https://github.com/NREL/resstock/pull/305))
- Add argument to BuildExistingModel measure that allows the user to ignore measures ([#310](https://github.com/NREL/resstock/pull/310))
- Create example project yaml files for use with buildstockbatch ([#291](https://github.com/NREL/resstock/pull/291), [#314](https://github.com/NREL/resstock/pull/314))
- Create a pull request template to facilitate development ([#317](https://github.com/NREL/resstock/pull/317))
- Update documentation to clarify downselect logic parameters ([#321](https://github.com/NREL/resstock/pull/321))
- Additional options for EnergyStar clothes washer, clothes dryer, dishwasher ([#329](https://github.com/NREL/resstock/pull/329), [#333](https://github.com/NREL/resstock/pull/333))

Fixes
- Bugfix for assuming that all simulations are exactly 365 days ([#255](https://github.com/NREL/resstock/pull/255))
- Bugfix for heating coil defrost strategy ([#258](https://github.com/NREL/resstock/pull/258))
- Various HVAC-related fixes for buildings with central systems ([#263](https://github.com/NREL/resstock/pull/263))
- Update testing project to sweep through more options ([#280](https://github.com/NREL/resstock/pull/280))
- Updates, edits, and clarification to the documentation ([#270](https://github.com/NREL/resstock/pull/270), [#274](https://github.com/NREL/resstock/pull/274), [#285](https://github.com/NREL/resstock/pull/285))
- Skip any reporting measure output requests for datapoints that have been registered as invalid ([#286](https://github.com/NREL/resstock/pull/286))
- Bugfix for when bedrooms are specified for each unit but bathrooms are not ([#295](https://github.com/NREL/resstock/pull/295))
- Ensure that autosizing does not draw the whole tank volume in one minute for solar hot water storage tank ([#307](https://github.com/NREL/resstock/pull/307))
- Remove invalid characters from option names for consistency with buildstockbatch ([#308](https://github.com/NREL/resstock/pull/308))
- Bugfix for ducts occasionally getting placed in the garage attic instead of only unfinished attic ([#309](https://github.com/NREL/resstock/pull/309))
- Able to get past runner values of any type, and not just as string ([#312](https://github.com/NREL/resstock/pull/312))
- Log the error message along with the backtrace when an applied measure fails ([#315](https://github.com/NREL/resstock/pull/315))
- Add tests to ensure that the Run Measure argument is correctly defined in all Apply Upgrade measures for all projects ([#320](https://github.com/NREL/resstock/pull/320))
- Bugfix when specifying numbers of bedrooms to building units ([#330](https://github.com/NREL/resstock/pull/330))
- Enforce rubocop as CI test so code with offenses cannot be merged ([#331](https://github.com/NREL/resstock/pull/331))
- Bugfix for some clothes washer, dishwasher options causing increased energy consumption ([#329](https://github.com/NREL/resstock/pull/329), [#333](https://github.com/NREL/resstock/pull/333))


## ResStock v2.0.0
###### April 17, 2019 - [Diff](https://github.com/NREL/resstock/compare/v1.0.0...v2.0.0)

Features
- Update to OpenStudio v2.8.0 ([#151](https://github.com/NREL/resstock/pull/151))
- Add a multifamily project which includes housing characteristic distributions for single-family detached, single-family attached, and multifamily buildings ([#151](https://github.com/NREL/resstock/pull/151))
- Ability to add central systems (boiler with baseboards, fan coil, PTAC) to multifamily buildings using the openstudio-standards gem ([#151](https://github.com/NREL/resstock/pull/151))
- Ability to simulate large multifamily buildings using "collapsed" buildings with multipliers on building units ([#206](https://github.com/NREL/resstock/pull/206))
- Automatically generate dependency graphs and a dependency wheel for each project ([#211](https://github.com/NREL/resstock/pull/211))
- Add measures for calculating construction properties, modeling power outages and calculating resilience metrics, and calculating utility bills ([#151](https://github.com/NREL/resstock/pull/151))
- Add measure for modeling shared multiifamily facades using adiabatic constructions ([#151](https://github.com/NREL/resstock/pull/151))
- Relocate all measure unit tests, test osw files, and test osm files from archived OpenStudio-BEopt and into this repository ([#151](https://github.com/NREL/resstock/pull/151))
- Create example workflow osw files for single-family detached, single-family attached, and multifamily buildings using TMY weather ([#151](https://github.com/NREL/resstock/pull/151))

Fixes
- Reporting measures read from ReportMeterData table to get disaggregated fan and pump energy ([#151](https://github.com/NREL/resstock/pull/151))
- Break out central system heating, cooling, and pump energy in reporting measures ([#151](https://github.com/NREL/resstock/pull/151))
- Use custom unit conversions script instead of that provided by OpenStudio SDK ([#216](https://github.com/NREL/resstock/pull/216))


## ResStock v1.0.0
###### April 17, 2019
