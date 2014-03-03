require 'spec_helper'

# Domain logic is in app/domain
$:.unshift(File.expand_path(File.join('app', 'domain')))

DatabaseCleaner.strategy = :truncation, { except: %w(user_total_score entity_total_upvotes entity_aggregated_tag_list) }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.before(:suite) { DatabaseCleaner.clean }
  config.use_transactional_fixtures = true
  config.order = "random"
end

require 'yaml'
require 'core_ext'
require 'core_helpers'
