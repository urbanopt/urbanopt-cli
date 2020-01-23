# UoCli

This is the command line interface (CLI) for URBANopt.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'uo_cli'
```

And then execute:

```terminal
bundle
```

Or install it yourself with:

```terminal
gem install uo_cli
```

## Usage

For help text in your terminal, type:

```terminal
uo -h
```

Create a project folder:

```terminal
uo -p <FOLDERNAME>
```

Make ScenarioFiles from a FeatureFile:

```terminal
uo -m <FEATUREFILE>
```

Run simulations with URBANopt:

```terminal
uo -r -s <SCENARIOFILE> -f <FEATUREFILE>
```

Aggregate simulations for a full scenario:

```terminal
uo -a -s <SCENARIOFILE> -f <FEATUREFILE>
```

The `run` and `aggregate` commands require addtional flags and the appropriate file paths. For example, to `run` using `baseline_scenario.csv` and `example_project.json` you would enter:

```terminal
uo -r -s baseline_scenario.csv -f example_project.json
```

Delete a scenario that you have already Run:

```terminal
uo -d <SCENARIOFILE>
```

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `lib/version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
