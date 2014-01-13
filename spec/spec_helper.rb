# Spec helper for Rails-less tests

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..'))
ENV["RAILS_ENV"] ||= 'test'

require 'rspec/mocks'

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start if ENV['RAILS_ENV'] == 'testing'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  # WAT?
end
