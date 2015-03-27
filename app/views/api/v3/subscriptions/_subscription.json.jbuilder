json.(sub, :id)

json.status sub.stripe_subscription_status

json.card do
  json.exp_month sub.card_exp_month
  json.exp_year  sub.card_exp_year
  json.type      sub.card_type
  json.last4     sub.card_last4
end

json.plan do
  json.partial! 'api/v3/plans/plan', plan: sub.plan
end
