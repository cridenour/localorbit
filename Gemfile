source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '2.3.8'

gem 'rails', '~> 4.1.11'

gem 'pg', '~> 0.21.0'

# Assets
gem 'sass-rails',   '~> 4.0.0'
gem 'uglifier',     '~> 2.7.2'
gem 'coffee-rails', '~> 4.0.0'

# The jQuery update is doing something weird
# with data confirms and poltergeist
gem 'jquery-rails', '~> 3.1.3'
gem 'jquery-ui-rails'
gem 'accountingjs-rails'
gem 'compass-rails'
gem 'underscore-rails'
gem 'wysihtml5-rails'

gem 'active_model_serializers'
gem 'active_record_query_trace'
gem 'active_record_union'
gem 'acts_as_geocodable'
gem 'audited-activerecord'
gem 'awesome_nested_set'
gem 'bootsnap', require: false # TODO: Remove this when we upgrade to rails 5.2
gem 'stripe'
gem 'color'
gem 'countries'
gem 'csv_builder'
gem 'delayed_job_active_record'
gem 'devise', '~> 3.5.10'
gem 'devise_invitable'
gem 'devise_masquerade'
gem 'dragonfly-s3_data_store'
gem 'draper'
gem 'figaro'
gem 'font_assets'
gem 'graticule'
gem 'groupdate', :git => 'https://github.com/trestrantham/groupdate.git', :branch => 'custom-calculations' # Waiting on https://github.com/ankane/groupdate/pull/53
gem 'interactor-rails', '< 3.0'
gem 'interactor', '< 3.0' # We are not ready for 3 yet
gem 'intercom-rails', '~> 0.2.26'
gem 'intercom', '~> 2.3.0'
gem 'jbuilder'
gem 'jwt'
gem 'kaminari'                      # Paginator
gem 'pdfkit'
gem 'periscope-activerecord'
gem 'pg_search'
gem 'postgres_ext'
gem 'rack-canonical-host'
gem 'ransack'
gem 'simpleidn'
gem 'stripe_event'
gem 'font-awesome-rails'
gem 'wysiwyg-rails'
gem 'kiba'                      # ETL Tool

gem "browserify-rails"          # Support
gem "react-rails"

gem 'migration_data'

gem "pundit"

gem 'httparty'
gem 'omniauth-stripe-connect'

gem 's3_direct_upload', :git => 'https://github.com/waynehoover/s3_direct_upload.git'

gem 'constructor'
gem 'tabulator', :git => 'https://github.com/dcrosby42/tabulator.git'
gem 'rschema', :git => 'https://github.com/tomdalling/rschema.git'

gem 'turbolinks'

# wkhtmltopdf versions are a mess. 0.12.1 is stable
# See https://github.com/zakird/wkhtmltopdf_binary_gem/issues/13
#  we are waiting for 0.12.5 to land for https://github.com/wkhtmltopdf/wkhtmltopdf/issues/3241
# The github version is massive and makes the Heroku slug huge
install_if -> { RUBY_PLATFORM =~ /darwin/ } do
  gem 'wkhtmltopdf-binary', git: 'https://github.com/zakird/wkhtmltopdf_binary_gem.git'
end
install_if -> { ENV['ON_HEROKU'] == 'true' } do
  gem 'wkhtmltopdf-heroku'
end

# Product import/export
gem 'rubyXL', require: false # XLSX
gem 'spreadsheet', require: false # XLS
gem 'slop', '~> 3.0', require: false # option parsing
gem 'dedent', require: false
gem 'activerecord-import', require: false
gem 'grape' # API v2
gem 'grape-active_model_serializers' # API v2
gem 'rack-cors', :require => 'rack/cors' # API v2
gem 'grape-swagger' # API V2, documentation

gem 'rollbar'

gem 'quickbooks-ruby', github: 'ruckus/quickbooks-ruby', ref: 'ba54c446bf37'
gem "attr_encrypted", '~> 3.0.0'

group :doc do
  gem 'sdoc', require: false
end

group :development do
  gem 'bullet'
  gem 'ultrahook'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'rubocop', require: false
  gem 'quiet_assets'
  gem 'aws-sdk'
  gem 'railroady'
  gem 'rails_view_annotator'
  gem 'rubycritic', require: false
  gem 'mailcatcher'
  gem 'unicorn'

  # profiling, see https://github.com/MiniProfiler/rack-mini-profiler#installation
  gem 'rack-mini-profiler'
  gem 'memory_profiler'
  gem 'flamegraph'
  gem 'stackprof'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 3.0'
  gem 'rspec-collection_matchers'
  gem 'rspec_junit_formatter', :git => 'https://github.com/circleci/rspec_junit_formatter.git'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'byebug'
  gem 'pry-byebug'
  gem 'launchy'
  gem 'awesome_print'
  gem 'konacha'
  gem 'konacha-chai-matchers'
  gem 'webmock'
  gem 'capybara-slow_finder_errors'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
end

group :test do
  gem 'simplecov', require: false
  gem 'domino'
  gem 'email_spec'
  gem 'database_cleaner'
  gem 'guard-rspec', require: false
  gem 'guard-konacha-rails'
  gem 'timecop'
  gem 'vcr'
  gem 'fire_poll', '1.2.0'
  gem 'capybara-screenshot'
end

group :staging do
  gem 'skylight'
end

group :production, :staging do
  gem 'newrelic_rpm'
  gem 'newrelic-dragonfly'
  #gem 'passenger'
  gem 'rack-cache', require: 'rack/cache'
  gem 'rails_12factor'
  gem 'platform-api'
end

group :production, :staging, :development do
  gem 'puma'
end
