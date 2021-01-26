# Bulldoze Renamer

Bulldoze Renamer is a tool to rename things in a code project.

Suppose you have an object that you called PoohBear but you want to now rename it to HoneyBear.

That means that everywhere in your project you want to replace `PoohBear -> HoneyBear`.
But also `pooh_bear -> honey_bear`. Any there may be some constant `POOH_BEAR_ACTIONS ->
HONEY_BEAR_ACTIONS` somewhere. And maybe the class is defined in `lib/bears/pooh_bear/pooh_bear.rb`
and so that file should be renamed `lib/bears/pooh_bear -> lib/bears/honey_bear` and
`lib/bears/pooh_bear/pooh_bear.rb -> lib/bears/honey_bear/honey_bear.rb`.

This tool aims to do all those replacements for you in the entire project in one go.

## Dependencies

libmagic is a dependency that should be available for your OS. E.g. using brew on OSX:

    $ brew install libmagic

## Installation

Install by installing the gem:

    $ gem install bulldoze_renamer

## Usage

It runs like so: `bulldoze_rename target_directory PoohBear HoneyBear`

It will only check files that are known to the git repo of the target_directory.

Invoked like this it will only show an overview of the changes that will take place.
The output looks like this:

    underscore : pooh_bear -> honey_bear
    camelize   : PoohBear  -> HoneyBear
    dasherize  : pooh-bear -> honey-bear
    upcase     : POOH_BEAR -> HONEY_BEAR
    js_camelize: poohBear  -> honeyBear

    camelize
      | upcase
      |   | filename
      |   |   |
      _   _   1 lib/bears/pooh_bear
      1   1   1 lib/bears/pooh_bear/pooh_bear.rb

The first section shows the possible mappings it looks for in the target_directory.
The section below that shows which of those actually occur in which files. Files
that will need to be renamed also have a value for `filename`.

To actually perform the substitutions, add the `-p` option to the earlier command.
Then it will print out the filenames as they are being updated. That looks like
this:

    Performing:
    R lib/bears/pooh_bear/pooh_bear.rb -> lib/bears/pooh_bear/honey_bear.rb
    d lib/bears/pooh_bear -> lib/bears/honey_bear

Where the first character denotes:
- f: substituted value in file
- r: only renamed the file
- R: renamed file and substituted values in it
- d: directory which was moved

### Warning

As suggested by the name `bulldozer`, this tool is rather crude. Undesirable things
can happen, especially if it is not clear from the original value or target value
what type of format it should be.

For example for `pooh_bear` it is clear that it is in underscore format, but if it
were just `pooh` it could also be in js_camelize format.

Therefore there should be no issue if both original and new values have multiple words.
When replacing a single word with another single word, there should also be no issue.

But when you replace single word with multiple words it will be ambiguous which format to
use.

When you replace multiple words with a single word, that will work fine, but afterwards
renaming it again may be problematic.

Always ensure by checking changes in git that they are all correct.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
