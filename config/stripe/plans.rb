# Run `rake stripe:prepare` to update plans on stripe.com

if defined?(Plan) && Plan.table_exists?
  Plan.where.not(stripe_id: nil).each do |p|
    Stripe.plan(p.stripe_id.to_sym) do |plan|
      plan.name = p.name
      plan.amount = p.amount
      plan.currency = p.currency
      plan.interval = p.interval
      plan.interval_count = p.interval_count
      plan.trial_period_days = p.trail_period_days
    end
  end
end
