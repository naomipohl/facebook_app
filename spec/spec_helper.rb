ENV['RAILS_ENV'] ||= 'test'
require 'bundler'
Bundler.require(:default, ENV['RAILS_ENV'])
require File.expand_path('../../config/environment', __FILE__)
require 'rack_session_access/capybara'
require 'capybara/dsl'
require 'capybara/rspec'
require 'database_cleaner'

Capybara.app = Rack::Builder.parse_file(File.expand_path('../../config.ru', __FILE__)).first

ActiveRecord::Migrator.migrate(File.join(Rails.root, 'db/migrate'))

RSpec.configure do |config|
  config.include Capybara::DSL
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

