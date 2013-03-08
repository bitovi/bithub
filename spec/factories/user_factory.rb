FactoryGirl.define do
  factory :author do
    name "Nikica"
    email "neektza@gmail.com"

    association :identity, factory: :identity
  end
end
