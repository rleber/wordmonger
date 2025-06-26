# frozen_string_literal: true

source "https://rubygems.org"

repo_name = 'rleber/wordmonger.git'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }


group :development, :test do
  # Basic Pry Setup
  gem 'rspec'
  gem 'awesome_print' # pretty print ruby objects
  gem 'pry' # Console with powerful introspection capabilitie
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'reline' # Required by pry-byebug; will no longer be part of the default gems
  gem 'irb' # Required by byebug; will no longer be part of the default gems
  # gem 'pry-nav'
  # gem 'debug'
  # gem 'pry-debugger' # Integrates pry with standard Ruby debugger
  gem 'pry-doc' # Provide MRI Core documentation
  # gem 'pry-rails' # Causes rails console to open pry. `DISABLE_PRY_RAILS=1 rails c` can still open with IRB
  gem 'ostruct' # Required by Pry; will no longer be part of the default gems

  # Alternative debugger
  #   byebug has useful features, but doesn't play nice with Rails Zeitwerk
  #   This config uses pry-debugger instead
  # gem 'pry-byebug' # Integrates pry with byebug
  
  # Auxiliary Gems
  # gem 'pry-rescue' # Start a pry session whenever something goes wrong
  # gem 'pry-theme' # An easy way to customize Pry colors via theme files
  # gem 'binding_of_caller' # To evaluate code from a higher up call stack context
end
