require 'stripe_mock'

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
    name: 'neektza',
    email: 'neektza@gmail.com',
    password: 'foobar123',
    password_confirmation: 'foobar123'
  }

  ACCOUNT_LOGIN_DATA = {
    name: 'neektza',
    password: 'foobar123',
    remember_me: '0'
  }

  BRAND_DATA = {
    name: 'brand new Brand',
    tenant_name: 'brandnewbrand'
  }
end
