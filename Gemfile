# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.8"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.8", ">= 7.0.8.4"

# Use postgresql as the database for Active Record
gem "pg"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"

gem 'aasm', '4.12.3'
gem 'grape', '~> 1.6.2'
gem 'grape-active_model_serializers', git: 'https://github.com/Thinkei/grape-active_model_serializers', branch: :master
gem 'grape_has_scope'
gem 'grape_logging'
gem 'grape-route-helpers'
gem 'hashie', '~> 5.0.0'
gem 'hashie-forbidden_attributes'
gem 'hiredis'
gem 'redis'
gem 'redis-mutex', '4.0.1'
gem "ruby-openai", "~> 7.0.1"
gem 'sidekiq'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails', '~> 6.1.0'
  gem 'rubocop', '~> 1.57.1', require: false
  gem 'rubocop-performance', '~> 1.19.1', require: false
  gem 'rubocop-rails', '~> 2.21.2', require: false
  gem 'rubocop-rspec', '~> 2.24.1', require: false
end

group :test do
  gem 'fakeredis', git: 'https://github.com/guilleiguaran/fakeredis.git',
                   ref: '95619078dbebe9be93b87d35513fd55411489e20',
                   require: 'fakeredis/rspec'
  gem 'shoulda-matchers', '~> 5.3.0'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem 'grape_on_rails_routes'
end

source 'https://gem.fury.io/eh-devops/' do
  gem 'google_json_response', '~> 0.4.0'
end
