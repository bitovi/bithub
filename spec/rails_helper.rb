ENV['RAILS_ENV'] = 'test'

require File.expand_path("#{PROJECT_ROOT}/config/environment", __FILE__)
require 'spec_helper'
require 'rspec/rails'
require 'webmock/rspec'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

# otherwise all net connects will fail
WebMock.allow_net_connect!

RSpec.configure do |config|
  config.before(:suite) do
    Celluloid.boot
    DatabaseCleaner.clean_with :truncation
  end

  config.after(:suite) do
    Celluloid.shutdown
  end

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
