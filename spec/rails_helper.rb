ENV["RAILS_ENV"] ||= 'test'

# PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
# $:.unshift PROJECT_ROOT

require 'spec_helper'
require File.expand_path("#{PROJECT_ROOT}/config/environment", __FILE__)
require 'rubygems'
require 'spork'
require 'rspec/rails'
require 'codeclimate-test-reporter'
require_relative 'test_helper_methods'

CodeClimate::TestReporter.start if ENV['RAILS_ENV'] == 'test'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
end

Spork.prefork do
  require 'rspec/mocks'
  require 'rspec/rails'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start if ENV['RAILS_ENV'] == 'test'
end

Spork.each_run do
  # This code will be run each time you run your specs.
end
