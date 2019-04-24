source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2.1'
# Use sqlite3 as the database for Active Record

gem 'google-api-client', require: 'google/apis/calendar_v3'

gem 'mysql2'
#linebot用
gem 'line-bot-api'
#環境変数を簡単に利用できるgem
gem 'dotenv-rails'
#cssフレームワーク
gem 'bulma-rails'
#jquery
gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'whenever'
gem 'slim-rails'
gem 'bcrypt'

gem 'rails-erd', group: [:development, :test]

gem 'search_cop'

gem 'webpacker'
gem 'kaminari'
gem 'slack-notifier'

# 画像アップロード用
gem 'carrierwave'
gem 'fog-aws'
gem 'rmagick'

# ActiveRecord用
gem 'activerecord-import'

#gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# 本体
gem 'capistrano', '~> 3.11.0', require: false
gem 'capistrano-bundler', '~> 1.4.0', require: false
gem 'capistrano-rails', '~> 1.4.0', require: false
gem 'capistrano-rbenv', '~> 2.1.4', require: false
gem 'sshkit-sudo', '~> 0.1.0', require: false
gem 'capistrano3-puma', '~> 3.1.1', require: false
gem 'capistrano-npm', require: false
gem 'capistrano-yarn', require: false

#本番環境用
gem 'unicorn'
gem "capistrano3-unicorn", require: false

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data'#, platforms: [:mingw, :mswin, :x64_mingw, :jruby]
