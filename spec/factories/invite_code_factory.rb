FactoryGirl.define do
  factory :invite_code do
    code 'mamatijetest'
    remaining_uses 10000
    valid_until 1.year.from_now
  end
end
