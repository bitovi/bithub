ENV['ENV'] = 'test'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

$LOAD_PATH.unshift File.join(PROJECT_ROOT, 'app', 'models')
$LOAD_PATH.unshift File.join(PROJECT_ROOT, 'app', 'domain')
$LOAD_PATH.unshift File.join(PROJECT_ROOT, 'app')
$LOAD_PATH.unshift File.join(PROJECT_ROOT, 'services', 'guzzler')
$LOAD_PATH.unshift File.join(PROJECT_ROOT, 'services', 'listener')
$LOAD_PATH.unshift File.join(PROJECT_ROOT, 'services')
$LOAD_PATH.unshift PROJECT_ROOT

require 'rspec'
require 'rspec/mocks'

require 'celluloid/test'

require 'lib/core_helpers'
require 'spec/test_helper_methods'

require 'database_cleaner'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'dotenv'
Dotenv.load

Celluloid.logger.level = Logger::ERROR
DatabaseCleaner.logger = Celluloid.logger

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
