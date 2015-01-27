require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Account registration', type: :request do

  before do
    ENV['STRIPE_DISABLE'] = 'false'
    StripeMock.start
    StripeMock.create_test_helper.create_plan(id: 'starter', amount: 1000, trial_period_days: 45)
  end
  after do
    StripeMock.stop
    ENV['STRIPE_DISABLE'] = 'true'
  end

  describe 'POST /register' do
    it 'creates an account, a new brand and subscription for that account' do
      expect do
        post '/register/starter', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
      end.to \
        change(Account, :count).by(1).and \
        change(Brand, :count).by(1).and \
        change(Subscription, :count).by(1)

      #expect(Account.first.confirmed?).to be_falsey
      expect(Subscription.first.plan_id).to be_truthy
      expect(Subscription.first.brand_id).to be_truthy
      expect(Subscription.first.stripe_customer_id).to be_truthy
      expect(Subscription.first.stripe_subscription_id).to be_truthy
      expect(Subscription.first.stripe_subscription_status).to be_truthy
    end

    it 'doesn\'t create the brand if the account is being invited'
  end
end
