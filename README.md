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

Make ScenarioFiles from a FeatureFile using MapperFiles:

```terminal
uo -m -f <FEATUREFILE>
```

Run URBANopt energy simulations for each feature in your scenario:

```terminal
uo -r -s <SCENARIOFILE> -f <FEATUREFILE>
```

Aggregate simulations for a full scenario:

```terminal
uo -a -s <SCENARIOFILE> -f <FEATUREFILE>
```

Delete a scenario that you have already run:

```terminal
uo -d -s <SCENARIOFILE>
```

Installed CLI version:

```terminal
uo -v
```

## Development

To install this gem onto your local machine, clone this repo and run `rake install`. If you make changes to this repo, update the version number in `lib/version.rb` in your first commit. When ready to release, run the changelog script at `lib/change_log.rb` and copy the appropriate portion of the output into `CHANGELOG.md`. Run `bundle exec rake release` which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
