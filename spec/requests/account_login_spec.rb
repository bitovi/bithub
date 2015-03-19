require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Account login', type: :request do

  before do
    StripeMock.start
    @invite_code = FactoryGirl.create(:invite_code)
    @startup_plan = FactoryGirl.create(:plan)
  end

  after do
    StripeMock.stop
  end

  describe 'POST /login' do
    it 'creates an account session (logs the account in)' do
      post '/register/startup', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
      post '/login', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
      expect(Account.first.last_sign_in_at).to be_truthy
    end
  end
end
