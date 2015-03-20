require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Account registration', type: :request do

  before do
    ENV['STRIPE_DISABLE'] = 'false'
    StripeMock.start
    @invite_code = FactoryGirl.create(:invite_code)
    @startup_plan = FactoryGirl.create(:plan)
  end

  after do
    StripeMock.stop
    ENV['STRIPE_DISABLE'] = 'true'
  end

  describe 'POST /register' do
    it 'creates an account, a new brand and subscription for that account' do
      expect do
        post '/register/startup', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
      end.to \
        change(Account, :count).by(1)
        change(Brand, :count).by(1).and \
        change(Subscription, :count).by(1)
        change(Organization, :count).by(1)

      expect(Account.first.confirmed?).to be_falsey
      expect(Subscription.first.plan).to eq @startup_plan
    end
  end
end
