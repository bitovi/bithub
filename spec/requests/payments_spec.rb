require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Stripe Webhook handlers', type: :request do

  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:request_headers) do
    {
      "Accept" => "application/json",
      "Content-Type" => "application/json"
    }
  end

  before do
    ENV['STRIPE_DISABLE'] = 'false'
    StripeMock.start
    stripe_helper.create_plan(id: 'startup', amount: 1000, trial_period_days: 45)
    post '/register/startup', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
  end

  after do
    StripeMock.stop
    ENV['STRIPE_DISABLE'] = 'true'
  end

  describe 'handling Stripe webhook event invoice.payment_succeeded ' do
    it 'creates new payment' do
      cus_id = Brand.current.subscription.stripe_customer_id
      event = StripeMock.mock_webhook_event('invoice.payment_succeeded', customer: cus_id)
      invoice = event.data.object

      post '/stripe/events', event.to_json, request_headers

      payment = Payment.first.reload

      expect(payment.total).to eq(invoice.total)
      expect(payment.currency).to eq(invoice.currency)
      expect(payment.period_start).to be_truthy
      expect(payment.period_end).to be_truthy
      expect(payment.stripe_invoice_id).to eq(invoice.id)
      expect(payment.stripe_customer_id).to eq(invoice.customer)
      expect(payment.stripe_subscription_id).to eq(invoice.subscription)
    end
  end

  describe 'handling Stripe webhook event customer.subscription.updated ' do
    it 'updated subscription' do
      cus_id = Brand.current.subscription.stripe_customer_id
      event = StripeMock.mock_webhook_event('customer.subscription.updated', customer: cus_id)
      stripe_sub = event.data.object

      post '/stripe/events', event.to_json, request_headers

      sub = Subscription.first.reload

      expect(sub.plan_id).to eq(stripe_sub.plan.id)
      expect(sub.stripe_event_id).to eq(event.id)
      expect(sub.stripe_subscription_status).to eq(stripe_sub.status)
    end
  end
end
