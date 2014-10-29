# Run `rake stripe:prepare` to update plans on stripe.com

Stripe.plan :primo do |plan|
  plan.name = 'Starter'
  plan.amount = 1000 # in cents
  plan.currency = 'usd'
  plan.interval = 'month'
  plan.interval_count = 1
  plan.trial_period_days = 30
end

# charge.succeded

# customer.created
# customer.card.created/updated/deleted
# customer.subscription.created/updated
# invoice.created/updated/payment_succeeded/payment_failed
