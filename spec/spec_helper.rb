ENV["RAILS_ENV"] ||= 'test'

require 'rubygems'
require 'spork'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require File.expand_path("#{PROJECT_ROOT}/config/environment", __FILE__)
$:.unshift PROJECT_ROOT

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start if ENV['RAILS_ENV'] == 'test'

require 'rspec/mocks'
require 'rspec/rails'

ActiveRecord::Migration.maintain_test_schema! if defined?(ActiveRecord::Migration)

# ----------
# VCR config
# ----------

# VCR.configure do |c|
#   c.cassette_library_dir = 'fixtures/vcr_cassettes'
#   c.hook_into :webmock
# end

require_relative 'test_helper_methods'

Spork.prefork do
  require 'rspec/mocks'
  require 'rspec/rails'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start if ENV['RAILS_ENV'] == 'test'
end

Spork.each_run do
  # This code will be run each time you run your specs.
end
