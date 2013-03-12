FactoryGirl.define do
  factory :identity do
    uid '123'
    provider 'some_feed'

    trait :twitter do
      uid '123456'
      provider 'twitter'
    end

    trait :github do
      uid '456789'
      provider 'github'
    end

    factory :identity_from_github, traits: [:github]
    factory :identity_from_twitter, traits: [:twitter]
  end
end
