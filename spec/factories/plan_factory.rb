FactoryGirl.define do
  factory :plan do
    stripe_id 'a_plan'
    name 'Some plan'
    amount 1337

    trait :startup do
      stripe_id 'startup'
      name 'Startup'
      amount 9900
    end

    trait :brand do
      stripe_id 'brand'
      name 'Brand'
      amount 240000
    end
  end
end
