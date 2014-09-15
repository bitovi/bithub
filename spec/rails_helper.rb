ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("#{PROJECT_ROOT}/config/environment", __FILE__)
require 'spec_helper'
require 'rspec/rails'

if ENV['RAILS_ENV'] == 'testing'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
end
