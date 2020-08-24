# URBANopt Cli

This is the command line interface (CLI) for URBANopt.

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

## Installation Using Installer

The UrbanOpt installer is an alternate way to install the UrbanOpt CLI that also includes Ruby 2.5.x and OpenStudio SDK.  
Below are installation instructions for each platform. 

Link to provied installers: 

https://urbanopt-cli-resources.s3-us-west-2.amazonaws.com/installers/1/


### Linux

The provided linux .deb package is built for Ubuntu 18.04. You can install it using the apt package manager. 
First, download the .deb package (link above).  

To install: 

`sudo apt update`
`sudo apt install ./UrbanOptCLI-0.3.1.4dd7dd0288-Linux.deb`

This will install to `/usr/local/` directory. e.g. `/usr/local/urbanopt-cli-0.3.1/`  

To run the UrbanOpt CLI, first run the `setup-env.sh` script that generates environmental variables and stores these in `env_uo.sh` in your home directory. 

`$ /usr/local/urbanopt-cli-0.3.1/setup-env.sh`
`. ~/.env_uo.sh` 

Anytime you want use the UrbanOptCLI run `$ . .env_uo.sh` and you can start using the UrbanOpt CLI utlity by invoking it using `uo` e.g. `$ uo --help`

### Mac OSX 

The provided Mac .dmg package is built for OSX versions >= 10.12. 
First, download the .dmg package. 

Use the GUI installer and choose a directory to install. Once installed, open a terminal and run the provided setup script. 
The `setup-env.sh` generates env variables and stores them in a file `.env_uo.sh` in your home direcotry. 

e.g.
`$ /Applications/UrbanOptCLI_0.3.1/setup-env.sh`
`$. ~/.env_uo.sh` 

Anytime you want use the UrbanOptCLI run `$ . .env_uo.sh` and you can start using the UrbanOpt CLI utlity by invoking it using `uo` e.g. `$ uo --help`

### Windows

First, download the .exe installer. Use the GUI installer and choose a directory to install. Once installed, open a terminal (Powershell, cmd and GitBash are supported) and run the provided setup script for that shell (below are the setup scripts for each respective shell environment).


### Bash (or GitBash for Windows)
```
$ c:/urbanopt-cli-0.3.1/setup-env.sh
$. ~/.env_uo.sh
```

### Powershell
```
$c:\urbanopt-cli-0.3.1\setup-env.ps1
$ . $HOME\.env_uo.ps1
```
### Windows Command Prompt
```
$ cd c:\urbanopt-cli-0.3.1\setup-env.bat
$ %HOME%\.env_uo.bat
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
