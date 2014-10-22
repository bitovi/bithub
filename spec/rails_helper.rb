ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("#{PROJECT_ROOT}/config/environment", __FILE__)
require 'spec_helper'
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

OmniAuth.config.add_mock(:twitter, {:uid => '12345'})
OmniAuth.config.add_mock(:github, {:uid => '54321'})

RSpec.configure do |config|
  config.before(:suite) do
    Celluloid.boot
    Apartment::Database.drop('testy') rescue nil
    DatabaseCleaner.clean_with :truncation, except: %w(tags scoring_rules)
    Brand.create name: 'testy', tenant_name: 'testy'
  end

  config.after(:suite) do
    Apartment::Database.drop 'testy' rescue nil
    Celluloid.shutdown
  end

  config.before(:each) do
    Apartment::Database.switch 'testy'
  end

  config.include Capybara::DSL, type: :request
  config.include Requests::JsonHelpers, type: :request

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
end

# Assert that a hash has keys,
# used mainly for testing json responses
RSpec::Matchers.define :have_keys do |keys|
  match do |actual|
    keys.inject(true) do |accumul, k|
      accumul && actual.has_key?(k.to_s)
    end
  end
end
