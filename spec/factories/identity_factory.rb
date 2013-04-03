FactoryGirl.define do
  factory :identity do
    sequence(:uid)
    provider 'some_feed'

    trait :twitter do
      provider 'twitter'
    end

    trait :github do
      provider 'github'
    end

    factory :identity_from_github, traits: [:github]
    factory :identity_from_twitter, traits: [:twitter]
  end
end
