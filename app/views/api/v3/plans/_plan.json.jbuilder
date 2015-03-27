json.(plan, :id, :name, :trail_period_days, :amount, :currency, :interval, :available, :features, :limits)

json.plan_id plan.stripe_id
json.grace_period_days plan.grace_period