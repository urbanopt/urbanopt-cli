# Changelog

## Version 0.9.3
Date Range: 04/11/23 - 06/14/23:

- Fixed [#421] ( https://github.com/urbanopt/urbanopt-cli/issues/421 ), Pin parser dependency to avoid native extensions issue

## Version 0.9.2
Date Range: 01/06/23 - 04/11/23:

- Fixed [#417]( https://github.com/urbanopt/urbanopt-cli/pull/417 ), pin addressable dependency to resolve unicode_normalize error
- Fixed [#397]( https://github.com/urbanopt/urbanopt-cli/pull/397 ), New tests for GEB mappers

## Version 0.9.1
Date Range: 12/14/22 - 01/05/23:

- Updates to support HPXML to 1.5.1 and OpenStudio 3.5.1
- Updated copyrights for 2023

## Version 0.9.0
Date Range: 07/07/22 - 12/13/22:

- Fixed [#305]( https://github.com/urbanopt/urbanopt-cli/issues/305 ), Expand RNM to OpenDSS connection
- Fixed [#330]( https://github.com/urbanopt/urbanopt-cli/issues/330 ), Create a UO CLI command to install DISCO 
- Fixed [#331]( https://github.com/urbanopt/urbanopt-cli/issues/331 ), Install Miniconda Python, pip, and Python dependencies within urbanopt installation
- Fixed [#361]( https://github.com/urbanopt/urbanopt-cli/issues/361 ), CLI command to update an existing project to latest URBANopt version
- Fixed [#380]( https://github.com/urbanopt/urbanopt-cli/issues/380 ), Better error handling of uo create command
- New Feature - Initial DISCO integration
- CLI command for Class Project creation 
- Added RNM flag to OpenDSS command for processing RNM-US DSS files
- New Feature - 3 GEB scenarios: add chilled water storage, EPD reduction during Peak Hours, Adjust Thermostat during Peak Hours
- Updated dependencies for OpenStudio 3.5.0 and HPXML 1.5.0

## Version 0.8.3
Date Range: 07/07/22 - 09/30/22:

- Updated RNM-US gem dependency to 0.4.0 (API v2)
- Fixed [#368]( https://github.com/urbanopt/urbanopt-cli/issues/368 ), Num-parallel flag leads to crash
- Fixed [#375]( https://github.com/urbanopt/urbanopt-cli/issues/375 ), Windows Installer setup script doesn't work for usernames with spaces

## Version 0.8.2
Date Range: 06/28/22 - 07/06/22:

- Fixed [#362]( https://github.com/urbanopt/urbanopt-cli/issues/362 ), BuildResidentialModel measure can't handle non-integer feature IDs

## Version 0.8.1
Date Range: 05/14/22 - 06/28/22:

- Fixed [#343]( https://github.com/urbanopt/urbanopt-cli/issues/343 ), Carbon Emission Reporting
- Fixed [#329]( https://github.com/urbanopt/urbanopt-cli/issues/329 ), Better error messages for missing modelica files
- Fixed [#349]( https://github.com/urbanopt/urbanopt-cli/issues/349 ), num_parallel bug

## Version 0.8.0

Date Range: 12/22/21 - 05/13/22:

- Fixed [#230]( https://github.com/urbanopt/urbanopt-cli/issues/230 ), Add --num_parallel as input param to cli
- Fixed [#237]( https://github.com/urbanopt/urbanopt-cli/issues/237 ), Verify the "datapoint is out of date" process
- Fixed [#256]( https://github.com/urbanopt/urbanopt-cli/issues/256 ), Update num_parallel in runner.config to n-1 and/or udpate installation documentation
- Fixed [#286]( https://github.com/urbanopt/urbanopt-cli/issues/286 ), fix issues when running opendss simulations
- Fixed [#291]( https://github.com/urbanopt/urbanopt-cli/issues/291 ), Access opendss `upgrade` flag
- Fixed [#292]( https://github.com/urbanopt/urbanopt-cli/issues/292 ), Ensure reopt can only be run with reopt files & data
- Fixed [#293]( https://github.com/urbanopt/urbanopt-cli/issues/293 ), Allow min/max renewable energy targets to be set
- Fixed [#303]( https://github.com/urbanopt/urbanopt-cli/issues/303 ), Add variability to EVs based on # occupants
- Fixed [#304]( https://github.com/urbanopt/urbanopt-cli/issues/304 ), REopt --off-grid flag
- Fixed [#318]( https://github.com/urbanopt/urbanopt-cli/issues/318 ), update copyrights for 2022
- Fixed [#323]( https://github.com/urbanopt/urbanopt-cli/issues/323 ), Recent change removes respect for user changes to assumptions file
- Fixed [#327]( https://github.com/urbanopt/urbanopt-cli/issues/327 ), Update electrical project feature-file

## Version 0.7.1

Date Range 11/23/21 - 12/22/21

- Bugfix: update project gemfile dependencies

## Version 0.7.0

Date Range 11/4/21 - 11/22/21

- Fixed [#278]( https://github.com/urbanopt/urbanopt-cli/issues/278 ), Visualizations are broken for scenarios without REopt results
- Fixed [#275]( https://github.com/urbanopt/urbanopt-cli/issues/275 ), Skip detailed model creation workflow if create bar workflow selected and detailed osm present
- Fixed [#272]( https://github.com/urbanopt/urbanopt-cli/issues/272 ), looking for simulations run for opendss fails when there are other folders in the run folder
- Updated dependencies for OpenStudio 3.3

## Version 0.6.4

Date Range 10/29/21 - 11/3/21

- Fixed [#267]( https://github.com/urbanopt/urbanopt-cli/issues/267 ), Default the GCR (ground coverage ratio) for PV to 0.99 in all example assumptions files

## Version 0.6.3

Date Range 7/23/21 - 10/28/21

- Fixed [#248]( https://github.com/urbanopt/urbanopt-cli/issues/248 ), Update example project to make use of commercial hours of operation customization
- Fixed [#255]( https://github.com/urbanopt/urbanopt-cli/issues/255 ), Look into warning message
- Fixed [#258]( https://github.com/urbanopt/urbanopt-cli/issues/258 ), added missing feature location arguments to CreateBar & Floorspace workflows
- Fixed [#260]( https://github.com/urbanopt/urbanopt-cli/issues/260 ), Add support for community PV, and ground-mount PV associated with Features
- Fixed [#265]( https://github.com/urbanopt/urbanopt-cli/issues/265 ), RNM workflow does not work when specifying the electrical catalog
- Fixed [#268]( https://github.com/urbanopt/urbanopt-cli/issues/268 ), Sync files from the urbanopt / urbanopt-example-geojson-project repository

## Version 0.6.2

Date Range 7/2/21 - 7/22/21

- Fixed [#246]( https://github.com/urbanopt/urbanopt-cli/issues/246 ), Fix Visualizations for other fuels
- Fixed [#250]( https://github.com/urbanopt/urbanopt-cli/issues/250 ), Integrate RNM functionality
- Fixed [#252]( https://github.com/urbanopt/urbanopt-cli/issues/252 ), Utilize ASHRAE 90.1 Laboratory prototype model

## Version 0.6.1

Date Range 5/1/21 - 7/1/21

- Fixed [#222]( https://github.com/urbanopt/urbanopt-cli/issues/222 ), Add a resilience flag to reopt processing
- Fixed [#224]( https://github.com/urbanopt/urbanopt-cli/issues/224 ), Createbar and Floorspace mappers are out of date
- Fixed [#227]( https://github.com/urbanopt/urbanopt-cli/issues/227 ), Runtime error when running urbanopt cli example project
- Fixed [#233]( https://github.com/urbanopt/urbanopt-cli/issues/233 ), update rubocop configs to v4
- Fixed [#235]( https://github.com/urbanopt/urbanopt-cli/issues/235 ), Re-add old residential types to the commercial hash
- Fixed [#238]( https://github.com/urbanopt/urbanopt-cli/issues/238 ), Fix BuildingResidentialModel feature_id argument - JSON parse bug
- Fixed [#240]( https://github.com/urbanopt/urbanopt-cli/issues/240 ), Update example mappers from urbanopt-example-geojson-project
- Fixed [#242]( https://github.com/urbanopt/urbanopt-cli/issues/242 ), Add load_flexibility require to baseline mapper

## Version 0.6.0

Date Range 3/31/21 - 4/30/21

- Fixed [#179]( https://github.com/urbanopt/urbanopt-cli/issues/179 ), Visualization : Annual End Use graphs, updating end-use tags
- Fixed [#185]( https://github.com/urbanopt/urbanopt-cli/issues/185 ), Add additional fuels used by the residential workflow to the first chart (when they exist)
- Updated dependencies for OpenStudio 3.2.0 / Ruby 2.7

## Version 0.5.2

Date Range 3/9/21 - 3/31/21

- Fixed [#190]( https://github.com/urbanopt/urbanopt-cli/issues/190 ), Graceful rescue from "uo" command
- Fixed [#191]( https://github.com/urbanopt/urbanopt-cli/issues/191 ), add error catching
- Fixed [#197]( https://github.com/urbanopt/urbanopt-cli/issues/197 ), Update copyrights for 2021
- Fixed [#200]( https://github.com/urbanopt/urbanopt-cli/issues/200 ), Scenario Level Assumptions File cannot be Defined by User
- Fixed [#202]( https://github.com/urbanopt/urbanopt-cli/issues/202 ), Use the new Ditto-Reader CLI in the UO CLI - Remove Pycall Dependency
- Fixed [#214]( https://github.com/urbanopt/urbanopt-cli/issues/214 ), reopt-scenario processing should allow selecting assumptions file
- Fixed [#215]( https://github.com/urbanopt/urbanopt-cli/issues/215 ), Support running GMT (DES) directly from the main CLI
- Fixed [#219]( https://github.com/urbanopt/urbanopt-cli/issues/219 ), Avoid saving feature reports twice.

## Version 0.5.1

Date Range 12/17/20 - 3/8/21

- Fixed [#157]( https://github.com/urbanopt/urbanopt-cli/issues/157 ), Edit maximum value for y axis in visualization graphs
- Fixed [#158]( https://github.com/urbanopt/urbanopt-cli/issues/158 ), Check units for Gas:Facility in visualization graphs
- Fixed [#172]( https://github.com/urbanopt/urbanopt-cli/issues/172 ), Add district heating/cooling systems
- Fixed [#174]( https://github.com/urbanopt/urbanopt-cli/issues/174 ), Ditto reader doesn't work in a virtualenv
- Fixed [#175]( https://github.com/urbanopt/urbanopt-cli/issues/175 ), developer_nrel_key warning at each user command
- Fixed [#176]( https://github.com/urbanopt/urbanopt-cli/issues/176 ), validate eui results
- Fixed [#183]( https://github.com/urbanopt/urbanopt-cli/issues/183 ), Add EV charging measure to example project
- Fixed [#184]( https://github.com/urbanopt/urbanopt-cli/issues/184 ), Change fuel units to kBtus on the monthly and net charts
- Fixed [#187]( https://github.com/urbanopt/urbanopt-cli/issues/187 ), Tests shouldn't take so long
- Fixed [#192]( https://github.com/urbanopt/urbanopt-cli/issues/192 ), Add electrical components to feature-file to work with opendss
- Fixed [#199]( https://github.com/urbanopt/urbanopt-cli/issues/199 ), re-added the multifamily options to the commercial_building_types list.
- Fixed [#200]( https://github.com/urbanopt/urbanopt-cli/issues/200 ), Scenario Level Assumptions File cannot be Defined by User
- Fixed [#201]( https://github.com/urbanopt/urbanopt-cli/issues/201 ), OpenDSS should work with URBANopt
- Fixed [#202]( https://github.com/urbanopt/urbanopt-cli/issues/202 ), Use the new Ditto-Reader CLI in the UO CLI - Remove Pycall Dependency
- Fixed [#203]( https://github.com/urbanopt/urbanopt-cli/issues/203 ), Update CI to install Python and urbanopt-ditto-reader package

## Version 0.5.0

Date Range 11/17/20 - 12/16/20

- Updated dependencies to support OpenStudio 3.1.0

## Version 0.4.1

Date Range: 10/01/20 - 11/16/20

- Fixed [#146]( https://github.com/urbanopt/urbanopt-cli/issues/146 ), Better error handling on Visualize command
- Fixed [#147]( https://github.com/urbanopt/urbanopt-cli/issues/147 ), Copy Visualize files from directory
- Fixed [#151]( https://github.com/urbanopt/urbanopt-cli/issues/151 ), Saving to db file doesn't work right on windows machines
- Fixed [#153]( https://github.com/urbanopt/urbanopt-cli/issues/153 ), Dependencies need to be managed tighter
- Fixed [#156]( https://github.com/urbanopt/urbanopt-cli/issues/156 ), BUGFIX: Add methods to save feature results
- Fixed [#163]( https://github.com/urbanopt/urbanopt-cli/issues/163 ), Bugfixes for residential workflow
- Fixed [#164]( https://github.com/urbanopt/urbanopt-cli/issues/164 ), Enhancements for residential workflow

## Version 0.4.0

Date Range: 06/11/20 - 09/30/20

- Fixed [#49]( https://github.com/urbanopt/urbanopt-cli/issues/49 ), Gathering results (post-processing) should provide scenario-level results in a database file
- Fixed [#95]( https://github.com/urbanopt/urbanopt-cli/issues/95 ), store bundle directory outside of project directory
- Fixed [#115]( https://github.com/urbanopt/urbanopt-cli/issues/115 ), Add command for visualising scenario results after post processing
- Fixed [#117]( https://github.com/urbanopt/urbanopt-cli/issues/117 ), run results
- Fixed [#119]( https://github.com/urbanopt/urbanopt-cli/issues/119 ), Integrate OpenDSS/diTTo reader
- Fixed [#121]( https://github.com/urbanopt/urbanopt-cli/issues/121 ), Add command for visualising feature results after post processing
- Fixed [#123]( https://github.com/urbanopt/urbanopt-cli/issues/123 ), Check that regular run completed before attempting opendss run
- Fixed [#124]( https://github.com/urbanopt/urbanopt-cli/issues/124 ), Add alternate geometry creation methods to cli
- Fixed [#129]( https://github.com/urbanopt/urbanopt-cli/issues/129 ), Need better way of getting data files into project folders
- Fixed [#131]( https://github.com/urbanopt/urbanopt-cli/issues/131 ), Implement HPXML-based workflow for residential buildings
- Fixed [#134]( https://github.com/urbanopt/urbanopt-cli/issues/134 ), Update runner.conf with new options
- Fixed [#136]( https://github.com/urbanopt/urbanopt-cli/issues/136 ), Chore: Add TM to first mention URBANopt on LICENSE file and LICENSE section
- Fixed [#138]( https://github.com/urbanopt/urbanopt-cli/issues/138 ), Update reopt assumption file in example projects and CLI repos.
- Fixed [#140]( https://github.com/urbanopt/urbanopt-cli/issues/140 ), db file is only created for default post-processor
- Fixed [#143]( https://github.com/urbanopt/urbanopt-cli/issues/143 ), Restrict scenario CSV names to be all lowercase

## Version 0.3.1

Date Range: 06/05/20 - 06/10/20:

- Fixed [#113]( https://github.com/urbanopt/urbanopt-cli/issues/113 ), CLI crashes if reopt folder missing from project directory

## Version 0.3.0

Date Range: 04/23/20 - 06/05/20

- Fixed [#96]( https://github.com/urbanopt/urbanopt-cli/issues/96 ), Better error checking
- Fixed [#99]( https://github.com/urbanopt/urbanopt-cli/issues/99 ), CLI complexity is hindering usage
- Fixed [#100]( https://github.com/urbanopt/urbanopt-cli/issues/100 ), REopt gem is used even for non-reopt simulations and post-processing
- Fixed [#102]( https://github.com/urbanopt/urbanopt-cli/issues/102 ), Update change_log functionality
- Fixed [#103]( https://github.com/urbanopt/urbanopt-cli/issues/103 ), Update CLI to work with OS 3.0

Update to OpenStudio 3.x and Ruby 2.5.x

## Version 0.2.3

Date Range: 04/01/20 - 04/23/20:

- Fixed [#65]( https://github.com/urbanopt/urbanopt-cli/issues/65 ), Add more tests
- Fixed [#81]( https://github.com/urbanopt/urbanopt-cli/issues/81 ), Mappers weren't updated for version 0.2
- Fixed [#83]( https://github.com/urbanopt/urbanopt-cli/issues/83 ), Recommend using absolute paths
- Fixed [#85]( https://github.com/urbanopt/urbanopt-cli/issues/85 ), reopt dependency not installed
- Fixed [#88]( https://github.com/urbanopt/urbanopt-cli/issues/88 ), Reopt tests are failing
- Fixed [#90]( https://github.com/urbanopt/urbanopt-cli/issues/90 ), Update baseline mapper
- Fixed [#92]( https://github.com/urbanopt/urbanopt-cli/issues/92 ), baseline mapper bug reading json file

## Version 0.2.2

Date Range: 3/31/20 - 3/31/20

- Fixing simplecov / json native extension dependency

## Version 0.2.1

Date Range: 03/31/20 - 03/31/20

- Fixed [#77]( https://github.com/urbanopt/urbanopt-cli/issues/77 ), Undefined local variable

## Version 0.2.0

Date Range: 02/14/20 - 03/31/20

- Fixed [#2]( https://github.com/urbanopt/urbanopt-cli/issues/2 ), Feature Request: Have this gem get pre-installed
- Fixed [#4]( https://github.com/urbanopt/urbanopt-cli/issues/4 ), Remove example-geojson-project repo
- Fixed [#9]( https://github.com/urbanopt/urbanopt-cli/issues/9 ), Update copyrights
- Fixed [#10]( https://github.com/urbanopt/urbanopt-cli/issues/10 ), Add --version flag
- Fixed [#12]( https://github.com/urbanopt/urbanopt-cli/issues/12 ), Support ReOpt workflow
- Fixed [#16]( https://github.com/urbanopt/urbanopt-cli/issues/16 ), Remove travis file
- Fixed [#19]( https://github.com/urbanopt/urbanopt-cli/issues/19 ), Rack version must be <2.2
- Fixed [#20]( https://github.com/urbanopt/urbanopt-cli/issues/20 ), Simplecov is an unnecessary dependency
- Fixed [#22]( https://github.com/urbanopt/urbanopt-cli/issues/22 ), Run a single datapoint
- Fixed [#25]( https://github.com/urbanopt/urbanopt-cli/issues/25 ), Add ability for CLI to generate config file
- Fixed [#26]( https://github.com/urbanopt/urbanopt-cli/issues/26 ), Using weekday start time in example mapper
- Fixed [#39]( https://github.com/urbanopt/urbanopt-cli/issues/39 ), PR template shouldn't ask for Changelog updates
- Fixed [#40]( https://github.com/urbanopt/urbanopt-cli/issues/40 ), Windows users are requiring Rack during Run command
- Fixed [#42]( https://github.com/urbanopt/urbanopt-cli/issues/42 ), We still need to require the NREL fork of Simplecov
- Fixed [#43]( https://github.com/urbanopt/urbanopt-cli/issues/43 ), rake install is hanging
- Fixed [#44]( https://github.com/urbanopt/urbanopt-cli/issues/44 ), Add detailed OSM workflow to example project
- Fixed [#45]( https://github.com/urbanopt/urbanopt-cli/issues/45 ), Remove single-family and multi-family buildings from example project
- Fixed [#46]( https://github.com/urbanopt/urbanopt-cli/issues/46 ), Remove os-standard dependency from example project gemfile
- Fixed [#55]( https://github.com/urbanopt/urbanopt-cli/issues/55 ), SegFault running CLI on windows
- Fixed [#56]( https://github.com/urbanopt/urbanopt-cli/issues/56 ), Ruby version is not specified
- Fixed [#59]( https://github.com/urbanopt/urbanopt-cli/issues/59 ), Add save individual report functionality to CLI
- Fixed [#63]( https://github.com/urbanopt/urbanopt-cli/issues/63 ), Add a way to create an "empty" project
- Fixed [#67]( https://github.com/urbanopt/urbanopt-cli/issues/67 ), Add an option to the -p command to overwrite an existing directory
- Fixed [#68]( https://github.com/urbanopt/urbanopt-cli/issues/68 ), Add OpenDSS postprocess command

## Version 0.1.0

Initial commit
