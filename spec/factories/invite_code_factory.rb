FactoryGirl.define do
  factory :invite_code do
    code 'mamatijetest'
    remaining_uses 1
    valid_until 1.year.from_now
  end
end
