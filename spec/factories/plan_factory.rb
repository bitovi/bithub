FactoryGirl.define do
  factory :plan do
    stripe_id 'startup'
    name 'Startup'
    amount 9900
  end
end
