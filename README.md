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
`/usr/local/urbanopt-cli-0.13.0/`

To run the UrbanOpt CLI, first run the `setup-env.sh` script that generates environmental variables and stores these in `env_uo.sh` in your home directory.

```terminal
/usr/local/urbanopt-cli-0.13.0/setup-env.sh
. ~/.env_uo.sh
```

When launching new shell terminals run `. ~/.env_uo.sh` to setup the environment. 

### Mac OSX (>= 10.12)

Download the [.dmg package](https://docs.urbanopt.net/installation/mac.html#install-with-the-urbanopt-installer).

Use the GUI installer and choose a directory to install. Once installed, open a terminal and run the provided setup script.
The `setup-env.sh` generates env variables and stores them in a file `.env_uo.sh` in your home directory.

```terminal
/Applications/UrbanOptCLI_0.13.0/setup-env.sh
. ~/.env_uo.sh
```

When launching new shell terminals run `. ~/.env_uo.sh` to setup the environment. 

### Windows (64-bit Windows 7 – 10)

Download the [.exe installer](https://docs.urbanopt.net/installation/windows.html#install-with-the-urbanopt-installer).

Use the GUI installer and choose a directory to install. Once installed, open a terminal (Powershell, Windows CMD and GitBash are supported) and run the provided setup script for that shell (below are the setup scripts for each respective shell environment).


#### Bash (or GitBash for Windows)
```terminal
c:/urbanopt-cli-0.13.0/setup-env.sh
. ~/.env_uo.sh
```

#### Powershell or Command Prompt
```terminal
c:\urbanopt-cli-0.13.0\setup-env.ps1
. ~\.env_uo.ps1
```
#### Windows Command Prompt
After the `setup-env.ps1` script has been run:
```terminal
"%HOMEPATH%/.env_uo.bat"
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

| Python Package              | Version | Notes |
| --------------------------- | ------- | ----- |
| urbanopt-ditto-reader       | 0.6.4   |  |
| NREL-disco                  | 0.5.1   |Currently excluded due to dependency issue. Will be restored in next version |
| urbanopt-des | 0.2.0   | This includes the Geojson Modelica Translator |
| ThermalNetwork              | 0.5.0   | This includes GHEDesigner |
| Urban System Generator (usg) | 0.1.1 | |


## Development

To install this gem onto your local machine, clone this repo and run `bundle exec rake install`. If you make changes to this repo, update the version number in `lib/version.rb` in your first commit. When ready to release, [follow the documentation](https://docs.urbanopt.net/developer_resources/release_instructions.html).


## Python Dependency Refactor - uv 

Starting with version 1.3.0, there has been a major python dependency refactor.
The CLI now uses `example_files/python_deps/pyproject.toml` as the source of truth for Python tool dependencies and uv for python package management.

The CLI:
1. Reads `[dependency-groups]` from `pyproject.toml`.
2. Reads `requires-python` from `pyproject.toml` and derives a major.minor version for uv (for example `3.10` from `==3.10.*`).
3. Uses `uv tool install --python <version> <package>` during `uo install_python`.
4. Uses `uv tool run --python <version> --from <package> <command...>` at runtime.


### For troubleshooting only: How to Update a Python Dependency in an Installed URBANopt Installer

If you need to manually update a python dependency directly in the URBANopt CLI installer, follow the steps below.

#### Step 1: Locate Installed pyproject.toml

Find the installed gem location:

```bash
gem contents urbanopt-cli | grep example_files/python_deps/pyproject.toml
```

If your installer is at `/Applications/URBANoptCLI_1.2.0`, the file is typically under that install's embedded Ruby gem path, ending with:

```text
.../gems/urbanopt-cli-<version>/example_files/python_deps/pyproject.toml
```

#### Step 2: Edit the Dependency in pyproject.toml

Open `pyproject.toml` and edit the package spec in `[dependency-groups]`.

Example:

```toml
[dependency-groups]
thermalnetwork = [
  "thermalnetwork==0.5.0",
]
```

Update to:

```toml
thermalnetwork = [
  "thermalnetwork==0.6.0",
]
```

Notes:
1. Keep valid TOML syntax.
2. The CLI uses the first package entry in each group for uv tool install/run.
3. If you add multiple entries in one group, the CLI warns and uses only the first one for uv tool commands.

#### Step 3: Reinstall Python Tool Environments via CLI

From an environment where `uo` resolves to the installed CLI, run:

```bash
uo install_python
```

This command now:
1. Checks `uv` availability.
2. Loads dependency groups from installed `pyproject.toml`.
3. Determines Python version from `requires-python`.
4. Installs each active tool with `uv tool install`.

There is no separate `uv sync` step required for CLI behavior.

#### Step 4: Verify with an End-to-End CLI Command

Use a command that exercises the updated tool.

Examples:
1. `ditto-reader`: run `uo opendss ...`
2. `thermalnetwork`: run `uo ghe_size ...`
3. `urbanopt-des`: run `uo des_params ...` or other `des_*` command
4. `usg`: run `uo usg_preprocess ...`

Because runtime uses `uv tool run --from <package>`, this is the most reliable verification path.

#### For Manual uv Testing (Optional)

If you want to test outside `uo`, mirror CLI behavior directly:

```bash
uv tool install --python 3.10 "thermalnetwork==0.6.0"
uv tool run --python 3.10 --from "thermalnetwork==0.6.0" python -c "import thermalnetwork; print(thermalnetwork.__version__)"
```

Use the Python version derived from `requires-python` in installed `pyproject.toml`.

#### Troubleshooting

`ERROR: uv is not installed or not on your PATH`:
1. Install uv and retry `uo install_python`.

`Missing dependency group '<name>' in pyproject.toml`:
1. Ensure group names match expected active groups exactly.
2. Ensure `[dependency-groups]` section is valid TOML.

`requires-python not found` or parse warning:
1. Add/fix `requires-python` in `[project]` (for example `==3.10.*`).
2. If parsing fails, CLI falls back to Python `3.10`.

Command still appears to use old behavior:
1. Confirm you edited the installed gem's `pyproject.toml`, not a source checkout copy.
2. Re-run `uo install_python` after editing.

