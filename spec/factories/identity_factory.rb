FactoryGirl.define do
  factory :identity do

    trait :from_twitter do
      uid 55592490
      provider 'twitter'
    end
    
    trait :from_github do
      uid 816489
      provider 'github'
    end
  end
end
