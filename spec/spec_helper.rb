PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$:.unshift PROJECT_ROOT

require 'rspec'
require 'rspec/mocks'

require 'celluloid'
require 'celluloid/io'

require 'lib/core_helpers'
require 'spec/test_helper_methods'

Celluloid.logger.level = Logger::ERROR

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation, {
      :except => %w(tags scoring_rules funnels funnel_constraints funnel_constraints_funnels)
    }

    DatabaseCleaner.strategy = :transaction

    Apartment::Database.drop('testy') rescue nil
    Brand.create :name => 'testy', :tenant_name =>'testy'
  end

  config.after(:suite) do
    Apartment::Database.drop 'testy' rescue nil
    Celluloid.shutdown
  end

  config.before(:each) do
    Apartment::Database.switch 'testy'
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

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
