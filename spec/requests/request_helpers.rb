require 'stripe_mock'
require 'rails_helper'

RSpec.configure do |config|
  config.before(:suite) do
    Plan.delete_all
    FactoryGirl.create(:plan)
  end

  config.after(:suite) do
    Plan.delete_all
  end
end

StripeMock.webhook_fixture_path = './spec/support/fixtures/stripe_webhooks'

OmniAuth.config.test_mode = true

OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
  'provider' => 'twitter',
  'uid' => '123545',
  'user_info' => {
    'name' => 'mockuser',
    'image' => 'mock_user_thumbnail_url'
  },
  'credentials' => {
    'token' => 'mock_token',
    'secret' => 'mock_secret'
  }
})

OmniAuth.config.mock_auth[:instagram] = OmniAuth::AuthHash.new({
  'provider' => 'instagram',
  'uid' => '545123',
  'user_info' => {
    'name' => 'mockuser',
    'image' => 'mock_user_thumbnail_url'
  },
  'credentials' => {
    'token' => 'mock_token',
    'secret' => 'mock_secret'
  }
})

module AuthTestData
  POST_HEADERS = {
    'CONTENT_TYPE' => 'application/json'
  }

  ACCOUNT_REGISTRATION_DATA = {
    email: 'neektza@gmail.com',
    code: 'mamatijetest',
    name: 'neektza',
    password: 'foobar123',
    password_confirmation: 'foobar123'
  }

  ACCOUNT_LOGIN_DATA = {
    email: 'neektza@gmail.com',
    password: 'foobar123',
    remember_me: '0'
  }

  BRAND_DATA = {
    name: 'brand new Brand',
    tenant_name: 'brandnewbrand'
  }
end

def register_and_login
  post '/accounts', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
  post '/accounts/sign_in', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
end
