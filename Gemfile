# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.7.2'

gem 'rails', '~> 6.0.0'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.2.3'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.1'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# https://github.com/swanandp/acts_as_list
gem 'acts_as_list', '~> 0.9.10'
# https://github.com/ai/autoprefixer-rails
# gem 'autoprefixer-rails', '~> 7.2.5'

gem 'redcarpet', '~> 3.4.0'

gem 'cancancan', '~> 3.1.0'
gem 'devise', '~> 4.7.3'

gem 'kaminari', '~> 1.2.1'

gem 'faker', '~> 2.14', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger
  # console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.32'
  gem 'dotenv-rails', '~> 2.7'
  gem 'fabrication', '~> 2.19.0'
  gem 'guard', '~> 2.0'
  gem 'guard-bundler', require: false
  gem 'guard-rails', '~> 0.8.1', require: false
  gem 'guard-rspec', '~> 4.7.3', require: false
  gem 'rspec', '~> 3.7.0'
  gem 'rspec-rails', '~> 3.7'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere
  # in the code.
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard-livereload', '~> 2.5', require: false
  gem 'letter_opener', '~> 1.7'
  gem 'listen', '~> 3.2'
  gem 'rubocop', '~> 1.4.2', require: false
  gem 'scss_lint', '~> 0.59', require: false
  gem 'scss_lint_reporter_junit', '~> 0.1', require: false
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.1'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  # for circleci support
  gem 'rspec_junit_formatter', '~> 0.4.1'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'timecop', '~> 0.9'
end
