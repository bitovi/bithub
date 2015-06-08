require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Subscriptions', type: :request do

  before(:each) do
    StripeMock.start
    ENV['STRIPE_ENABLE'] = 'true'
    @stripe_helper = StripeMock.create_test_helper
    @stripe_helper.create_plan(id: 'a_plan', amount: 1234567, trial_period_days: 45)
    register_and_login

    ### Plans aren't currenly in use so we have to manually link it
    Subscription.first.update_attribute :plan_id, Plan.first.id
  end

  after(:each) do
    ENV['STRIPE_ENABLE'] = 'false'
    StripeMock.stop
  end

  describe 'GET /admin/subscriptions/edit/cc' do
    it 'renders the edit credit card info page on /admin/subscriptions/edit/cc' do
      get '/admin/subscriptions/edit/cc'
      assert_select '#edit_cc' do
        assert_select '#cc_number'
        assert_select '#cc_cvc'
        assert_select '#cc_exp_month'
        assert_select '#cc_exp_year'
        # stripe_token after submit? part of frontend
      end
    end
  end

  describe 'GET /admin/subscriptions/edit/plan' do
    # Plans are currently disabled
    # it 'renders the edit plan page on /admin/subscriptions/edit/plan' do
    #   get '/admin/subscriptions/edit/plan'
    #   assert_select '#edit_plan' do
    #     assert_select '#plan_id'
    #   end
    # end
  end

  describe 'POST /admin/subscriptions/update' do
    it 'updates subscription with new credit card info' do
      card_token = @stripe_helper.generate_card_token number: '4242424242424242', cvc: '123', exp_year: '2018', exp_month: '12'
      post '/admin/subscriptions/update', { stripe_token: card_token }
      expect(Subscription.current.card_last4).to eq('4242')
      expect(Subscription.current.card_exp_month).to eq('12')
      expect(Subscription.current.card_exp_year).to eq('2018')
    end

    # Plans are currently disabled
    # it 'updates subscription with a new plan' do
    #   post '/admin/subscriptions/update', { plan: 'a_plan' }
    #   expect(Subscription.current.plan.stripe_id).to eq('a_plan')
    # end
  end
end
