FactoryGirl.define do
  factory :invite_code do
    code 'mamatijetest'
    remaining_uses 10000
    valid_until 1.year.from_now

    trait :surely_doesnt_exist do
      code 'whatisthecode'
      valid_until 2.years.from_now
    end
  end
end
