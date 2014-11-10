require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Account login', type: :request do

  before do
    StripeMock.start
    StripeMock.create_test_helper.create_plan(id: 'starter', amount: 1000, trial_period_days: 45)
  end
  after do
    StripeMock.stop
  end

  describe 'GET /login' do
    it 'renders the login page on /login' do
      get '/login'
      assert_select '#new_account' do
        assert_select '#account_email'
        assert_select '#account_password'
      end
    end
  end

  describe 'POST /login' do
    it 'creates an account session (logs the account in)' do
      post '/register/starter', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
      post '/login', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
      expect(Account.first.last_sign_in_at).to be_truthy
    end
  end
end
