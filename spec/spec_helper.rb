PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift PROJECT_ROOT
$LOAD_PATH.unshift File.join(PROJECT_ROOT, 'app')
$LOAD_PATH.unshift File.join(PROJECT_ROOT, 'app', 'models')
$LOAD_PATH.unshift File.join(PROJECT_ROOT, 'app', 'domain')

if ENV['RAILS_ENV'] == 'testing'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'rspec'
require 'rspec/mocks'

require 'celluloid'
require 'celluloid/io'

require 'lib/core_helpers'
require 'spec/test_helper_methods'

Celluloid.logger.level = Logger::ERROR

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end
end
