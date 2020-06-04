# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 6.0' #, '~> 5.1.4'
# Use postgresql as the database for Active Record
gem 'pg' #, '~> 0.18'
# Use Puma as the app server
gem 'puma' #, '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails' #, '~> 5.0'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
# gem 'webpacker', '~> 4.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails' #, '~> 4.2'
# Turbolinks makes navigating your web application faster.
# Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

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

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger
  # console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara' #, '~> 2.13'
  gem 'fabrication', '~> 2.19.0'
  # gem 'guard', '~> 2.14.2'
  # gem 'guard-bundler', require: false
  # gem 'guard-rails', '~> 0.8.1', require: false
  # gem 'guard-rspec', '~> 4.7.3', require: false
  gem 'rspec', '~> 3.7.0'
  gem 'rspec-rails', '~> 3.7'
  gem 'selenium-webdriver'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  # gem 'faker', '~> 1.8.7', require: false
  # gem 'guard-livereload', '~> 2.5', require: false
  # Access an IRB console on exception pages or by using <%= console %> anywhere
  # in the code.
  gem 'listen' #, '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  # gem 'rubocop', '~> 0.52.1'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

gem 'shoulda-matchers', '~> 3.1', group: :test

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
