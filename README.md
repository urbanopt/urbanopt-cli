[![CLI build status](https://github.com/urbanopt/urbanopt-cli/actions/workflows/nightly_ci_build.yml/badge.svg)](https://github.com/urbanopt/urbanopt-cli/actions/workflows/nightly_ci_build.yml)<br/>
[![Core-gem](https://github.com/urbanopt/urbanopt-core-gem/actions/workflows/nightly_build.yml/badge.svg)](https://github.com/urbanopt/urbanopt-core-gem/actions/workflows/nightly_build.yml)
[![Coverage Status](https://coveralls.io/repos/github/urbanopt/urbanopt-core-gem/badge.svg?branch=develop)](https://coveralls.io/github/urbanopt/urbanopt-core-gem?branch=develop)<br/>
[![Geojson-gem](https://github.com/urbanopt/urbanopt-geojson-gem/actions/workflows/nightly_build.yml/badge.svg)](https://github.com/urbanopt/urbanopt-geojson-gem/actions/workflows/nightly_build.yml)
[![Coverage Status](https://coveralls.io/repos/github/urbanopt/urbanopt-geojson-gem/badge.svg?branch=develop)](https://coveralls.io/github/urbanopt/urbanopt-geojson-gem?branch=develop)<br/>
[![Reopt-gem](https://github.com/urbanopt/urbanopt-reopt-gem/actions/workflows/nightly_ci_build.yml/badge.svg)](https://github.com/urbanopt/urbanopt-reopt-gem/actions/workflows/nightly_ci_build.yml)
[![Coverage Status](https://coveralls.io/repos/github/urbanopt/urbanopt-reopt-gem/badge.svg?branch=develop)](https://coveralls.io/github/urbanopt/urbanopt-reopt-gem?branch=develop)<br/>
[![Reporting-gem](https://github.com/urbanopt/urbanopt-reporting-gem/actions/workflows/nightly_ci_build.yml/badge.svg)](https://github.com/urbanopt/urbanopt-reporting-gem/actions/workflows/nightly_ci_build.yml)
[![Coverage Status](https://coveralls.io/repos/github/urbanopt/urbanopt-reporting-gem/badge.svg?branch=develop)](https://coveralls.io/github/urbanopt/urbanopt-reporting-gem?branch=develop)<br/>
[![RNM-gem](https://github.com/urbanopt/urbanopt-rnm-us-gem/actions/workflows/nightly_ci_build.yml/badge.svg)](https://github.com/urbanopt/urbanopt-rnm-us-gem/actions/workflows/nightly_ci_build.yml)
[![Coverage Status](https://coveralls.io/repos/github/urbanopt/urbanopt-rnm-us-gem/badge.svg?branch=develop)](https://coveralls.io/github/urbanopt/urbanopt-rnm-us-gem?branch=develop)<br/>
[![Scenario-gem](https://github.com/urbanopt/urbanopt-scenario-gem/actions/workflows/nightly_ci_build.yml/badge.svg)](https://github.com/urbanopt/urbanopt-scenario-gem/actions/workflows/nightly_ci_build.yml)
[![Coverage Status](https://coveralls.io/repos/github/urbanopt/urbanopt-scenario-gem/badge.svg?branch=develop)](https://coveralls.io/github/urbanopt/urbanopt-scenario-gem?branch=develop)<br/>
[![Example-project CI](https://github.com/urbanopt/urbanopt-example-geojson-project/actions/workflows/weekly_build.yml/badge.svg)](https://github.com/urbanopt/urbanopt-example-geojson-project/actions/workflows/weekly_build.yml)
[![Coverage Status](https://coveralls.io/repos/github/urbanopt/urbanopt-example-geojson-project/badge.svg?branch=develop)](https://coveralls.io/github/urbanopt/urbanopt-example-geojson-project?branch=develop)

# URBANopt CLI

This is the command line interface (CLI) for the URBANopt™ SDK.

## Installation (Using Ruby)

Add this line to your application's Gemfile:

```ruby
gem 'urbanopt-cli'
```


And then execute:

```terminal
bundle
```

Or install it yourself with:

```terminal
gem install urbanopt-cli
```

## Installation (Using Installer)

The UrbanOpt installer is an alternate way to install the UrbanOpt CLI that also includes Ruby 2.7.2 and the OpenStudio SDK.
Below are installation instructions for each platform.

### Linux (Ubuntu 18.04)

Download the [.deb package](https://docs.urbanopt.net/installation/linux.html#install-with-the-urbanopt-installer).

```terminal
sudo apt update
sudo apt install ./UrbanOptCLI-0.3.1.b6f118d506-Linux.deb
```

This will install to `/usr/local/` directory.
e.g.
`/usr/local/urbanopt-cli-0.3.1/`

To run the UrbanOpt CLI, first run the `setup-env.sh` script that generates environmental variables and stores these in `env_uo.sh` in your home directory.

```terminal
/usr/local/urbanopt-cli-0.3.1/setup-env.sh
. ~/.env_uo.sh
```

When launching new shell terminals run `. ~/.env_uo.sh` to setup the environment. 

### Mac OSX (>= 10.12)

Download the [.dmg package](https://docs.urbanopt.net/installation/mac.html#install-with-the-urbanopt-installer).

Use the GUI installer and choose a directory to install. Once installed, open a terminal and run the provided setup script.
The `setup-env.sh` generates env variables and stores them in a file `.env_uo.sh` in your home directory.

```terminal
/Applications/UrbanOptCLI_0.3.1/setup-env.sh
. ~/.env_uo.sh
```

When launching new shell terminals run `. ~/.env_uo.sh` to setup the environment. 

### Windows (64-bit Windows 7 – 10)

Download the [.exe installer](https://docs.urbanopt.net/installation/windows.html#install-with-the-urbanopt-installer).

Use the GUI installer and choose a directory to install. Once installed, open a terminal (Powershell, Windows CMD and GitBash are supported) and run the provided setup script for that shell (below are the setup scripts for each respective shell environment).


#### Bash (or GitBash for Windows)
```terminal
c:/urbanopt-cli-0.3.1/setup-env.sh
. ~/.env_uo.sh
```

#### Powershell
```terminal
c:\urbanopt-cli-0.3.1\setup-env.ps1
. ~\.env_uo.ps1
```
#### Windows Command Prompt
```terminal
c:\urbanopt-cli-0.3.1\setup-env.bat
%HOMEPATH%\.env_uo.bat
```

When launching new shell terminals run the correct environment config to setup the environment. 

## Usage

For help text in your terminal, type:

```terminal
uo --help
```

Create a project folder:

```terminal
uo create --project-folder <FOLDERNAME>
```

Overwrite an existing project folder:

```terminal
uo create --overwrite --project-folder <FOLDERNAME>
```

Create an empty project folder without the example files:

```terminal
uo create --empty --project-folder <FOLDERNAME>
```

Create ScenarioFiles from a FeatureFile using MapperFiles:

```terminal
uo create --scenario-file <FEATUREFILE>
```

Create a ScenarioFile using only a specific FEATURE_ID from a FEATUREFILE:

```terminal
uo create --scenario-file <FEATUREFILE> --single-feature <FEATURE_ID>
```

Create a REopt ScenarioFile from an existing ScenarioFile:

```terminal
uo create --reopt-scenario-file baseline_scenario.csv
```

Run URBANopt energy simulations for each feature in your scenario:

```terminal
uo run --scenario <SCENARIOFILE> --feature <FEATUREFILE>
```

Run URBANopt energy simulations for each feature in your scenario, with REopt functionality included:

```terminal
uo run --reopt --scenario <SCENARIOFILE> --feature <FEATUREFILE>
```

Post-process simulations for a full scenario:

```terminal
uo process --<TYPE> --scenario <SCENARIOFILE> --feature <FEATUREFILE>
```

- Valid `TYPE`s are: `default`, `opendss`, `reopt-scenario`, `reopt-feature`, `reopt-resilience`, `disco`

Delete a scenario you have already run:

```terminal
uo delete --scenario <SCENARIOFILE>
```

Installed CLI version:

```terminal
uo --version
```

## Current Python Dependencies

Python dependencies are currently versioned as follows:

| Python Package              | Version |
| --------------------------- | ------- |
| urbanopt-ditto-reader       | 0.5.1   |
| NREL-disco                  | 0.4.2   |
| geojson-modelica-translator | 0.6.0rc2   |
| ThermalNetwork | 0.2.2   |

## Development

To install this gem onto your local machine, clone this repo and run `bundle exec rake install`. If you make changes to this repo, update the version number in `lib/version.rb` in your first commit. When ready to release, [follow the documentation](https://docs.urbanopt.net/developer_resources/release_instructions.html).
