# require 'rails_helper'
# require_relative 'request_helpers'

# RSpec.describe 'Subscriptions', type: :request do

#   before do
#     StripeMock.star
#     ENV['STRIPE_DISABLE'] = 'false'
#     stripe_helper = StripeMock.create_test_helper 
#     stripe_helper.create_plan(id: 'brand', amount: 1234567, trial_period_days: 45)
#     stripe_helper.create_plan(id: 'agency', amount: 9876543, trial_period_days: 7)
#     post '/register/agency', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
#     post '/login', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
#   end

#   after do
#     ENV['STRIPE_DISABLE'] = 'true'
#     StripeMock.stop
#   end

#   describe 'GET /admin/subscriptions/edit/cc' do
#     it 'renders the edit credit card info page on /admin/subscriptions/edit/cc' do
#       get '/admin/subscriptions/edit/cc'
#       assert_select '#edit_cc' do
#         assert_select '#cc_number'
#         assert_select '#cc_cvc'
#         assert_select '#cc_exp_month'
#         assert_select '#cc_exp_year'
#         # stripe_token after submit? part of frontend
#       end
#     end
#   end

#   describe 'GET /admin/subscriptions/edit/plan' do
#     it 'renders the edit plan page on /admin/subscriptions/edit/plan' do
#       get '/admin/subscriptions/edit/plan'
#       assert_select '#edit_plan' do
#         assert_select '#plan_id'
#       end
#     end
#   end

#   describe 'POST /admin/subscriptions/update' do
#     it 'updates subscription with new credit card info' do
#       card_token = stripe_helper.generate_card_token number: '4242424242424242', cvc: '123', exp_year: '2018', exp_month: '12'
#       post '/admin/subscriptions/update', { stripe_token: card_token }
#       expect(Brand.current.subscription.card_last4).to eq('4242')
#       expect(Brand.current.subscription.card_exp_month).to eq('12')
#       expect(Brand.current.subscription.card_exp_year).to eq('2018')
#     end

#     it 'updates subscription with a new plan' do
#       post '/admin/subscriptions/update', { plan: 'advanced' }
#       expect(Brand.current.subscription.plan_id).to eq('advanced')
#     end
#   end
# end
