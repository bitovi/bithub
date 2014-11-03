class Subscription < ActiveRecord::Base
  include Stripe::Callbacks

  belongs_to :brand

  after_customer_subscription_updated! do |subscription, event|
    # do something
  end
end
