require 'domain/spec_helper'
require 'rake'

require File.expand_path("../../../../config/environment", __FILE__)
require 'rspec/rails'

DatabaseCleaner.strategy = :truncation, {:except => %w(tags taggings scoring_rules category_determination_rules entity_aggregated_tag_list user_total_score entity_total_upvotes)}

# Seed

load File.expand_path("../../../../lib/tasks/data/import/import_or_update_tags.rake", __FILE__)
load File.expand_path("../../../../lib/tasks/data/import/import_category_determination_rules.rake", __FILE__)
load File.expand_path("../../../../lib/tasks/data/import/import_scoring_rules.rake", __FILE__)

Rake::Task.define_task(:environment)
silence_stream(STDOUT) do
  Rake::Task["data:import_or_update_tags"].invoke
  Rake::Task["data:import_category_determination_rules"].invoke
  Rake::Task["data:import_scoring_rules"].invoke
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.use_transactional_fixtures = true
  config.order = "random"

  config.before(:suite) do
    DatabaseCleaner.clean
  end
end
