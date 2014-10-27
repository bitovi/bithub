require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Account registration', type: :request do

  describe 'GET /register' do
    it 'renders the register page on /register' do
      get '/register'
      assert_select '#new_account' do
        assert_select '#account_email'
        assert_select '#account_password'
        assert_select '#account_password_confirmation'
      end
    end
  end

  describe 'POST /register' do
    it 'creates an account, and a new brand for that account' do
      expect do
        post '/register', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
      end.to change(Account, :count).by (1)
      expect(Account.first.confirmed?).to be_falsey
    end

    it 'creates the brand along with the account if account is being registered' do
      expect do
        post '/register', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
      end.to change(Brand, :count).by (1)
    end

    it 'doesn\'t create the brand if the account is being invited'
  end
end
