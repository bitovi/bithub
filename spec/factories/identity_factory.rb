FactoryGirl.define do
  factory :identity do
    sequence(:uid)
    sequence(:provider) {|n| "provider#{1}"}
  end
end
