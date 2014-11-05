# Run `rake stripe:prepare` to update plans on stripe.com

Stripe.plan :starter do |plan|
  plan.name = 'Starter'
  plan.amount = 1000 # in cents
  plan.currency = 'usd'
  plan.interval = 'month'
  plan.interval_count = 1
  plan.trial_period_days = 45
end

Stripe.plan :advanced do |plan|
  plan.name = 'Advanced'
  plan.amount = 4500
  plan.currency = 'usd'
  plan.interval = 'month'
  plan.interval_count = 1
  plan.trial_period_days = 45
end
