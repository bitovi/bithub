ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("#{PROJECT_ROOT}/config/environment", __FILE__)
require 'spec_helper'
require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

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

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
end
