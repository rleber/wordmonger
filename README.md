# wordmonger

This is a collection of tools to work with LEGO colors.

## Installation

### From Git

If installing for the system in general:

```bash
git clone \<git repository url\> wordmonger
cd wordmonger
gem build wordmonger.gemspec
gem install wordmonger-\<version\>.gem # e.g. gem install wordmonger-1.0.0.gem

```

If installing for a specific application, built with bundler, then replace the last command above with:

```bash
cd \<your application root\>
bundle add wordmonger
bundle build
```

### From RubyGems

This gem has not been released to RubyGems. Maybe I will do that when I feel it's mature enough.

<!-- 
TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem phrase right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
``` 
-->

## Usage

```wordmonger <command> <options>```

Type ```wordmonger help``` for a list of commands, or ```wordmonger help <command>``` for help with a specific command.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rleber/model. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/rleber/model/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Model project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rleber/model/blob/master/CODE_OF_CONDUCT.md).
