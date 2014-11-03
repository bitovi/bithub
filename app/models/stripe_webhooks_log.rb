class StripeWebhooksLog < ActiveRecord::Base
  include Stripe::Callbacks

  self.table_name = 'stripe_webhooks_log'

  after_stripe_event do |target, event|
    log = self.new(event_id: event.id, target: target.to_hash, event: event.to_hash)

    unless log.save
      Rails.logger.warn "[Stripe Webhook] Logging failed! \n#{target} \n#{event}"
    end
  end
end
