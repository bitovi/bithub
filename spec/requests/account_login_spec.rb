require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Account login', type: :request do

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
      post '/register', { account: account_registration_data }
      post '/login', { account: account_login_data }
      expect(Account.first.last_sign_in_at).to be_truthy
    end
  end
end
