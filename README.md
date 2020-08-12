# URBANopt Cli

This is the command line interface (CLI) for URBANopt.

## Installation (Using Installer)

If you use the installer option to install urbanopt cli, after you install the package you will need to open a terminal and navigate to installation path. Then, depending on your shell environment, run the setup-env script to generate the environmental variables to use the uo cli tool. You only need to run this once as it generates an env file that can then called anytime
you want to use the uo cli tool.

Below are the setup scripts for each respective shell environment.

### Bash (or GitBash for windows)
```
$ cd c:/urbanopt-cli-0.3.1
$ ./setup-env.sh
$ . ./env.sh
```

### Powershell
```
$ cd c:\urbanopt-cli-0.3.1
$ .\setup-env.ps1
$ . .\env.ps1
```
### Windows Command Prompt
```
$ cd c:\urbanopt-cli-0.3.1
$ .\setup-env.bat
$ env.bat
```

## Installation (Using Ruby) 

2 ) Using ruby add this line to your application's Gemfile:

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

- Valid `TYPE`s are: `default`, `opendss`, `reopt-scenario`, `reopt-feature`

Delete a scenario you have already run:

```terminal
uo delete --scenario <SCENARIOFILE>
```

Installed CLI version:

```terminal
uo --version
```

## Development

To install this gem onto your local machine, clone this repo and run `bundle exec rake install`. If you make changes to this repo, update the version number in `lib/version.rb` in your first commit. When ready to release, [follow the documentation](https://docs.urbanopt.net/developer_resources/release_instructions.html).
