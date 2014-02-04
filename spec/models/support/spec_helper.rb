ENV["RAILS_ENV"] ||= 'test'

RAILS_ROOT = File.expand_path("../../../..", __FILE__)
require File.join(RAILS_ROOT, 'config', 'environment')

require 'digest/md5'
require 'rspec/rails'
require 'rspec/autorun'
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation, {:except => %w(tags taggings event_aggregated_tag_list user_total_score event_total_upvotes)}

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, :type => :controller
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"

  config.before(:suite) do
    DatabaseCleaner.clean
  end
end

OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
  'provider' => 'twitter',
  'uid' => '987654321',
  'info' => {
    'email' => 'neektza@gmail.com',
    'name' => 'Nikica Jokic',
    'nickname' => 'neektza'
  }
})

OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
  'provider' => 'github',
  'uid' => '123456789',
  'info' => {
    'email' => 'neektza@gmail.com',
    'nickname' => 'neektza'
  }
})

OmniAuth.config.test_mode = true

def oauth_data_hash(provider = 'github', uid = 123456789, email = 'neektza@gmail.com', name = 'Nikica Jokic')
  Hash["omniauth.auth", Hash["provider", provider, "uid", uid, 'info', Hash["email", email, "name", name]]]
end

def show_me(response)
  File.open("/tmp/debug.html", "w") do |f|
    f.puts response.body
  end
  system "open /tmp/debug.html"
end
