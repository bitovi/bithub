FactoryGirl.define do

  factory :user do
    sequence(:name) {|n| "User ##{n}" }
    sequence(:email) {|n| "user#{n}@bitovi.com" }

    trait :with_both_idents do
      after :build do |user|
        user.identities << FactoryGirl.build(:identity, user: user, provider: 'github', uid: 123456789)
        user.identities << FactoryGirl.build(:identity, user: user, provider: 'twitter', uid: 987654321)
      end
    end
    
    trait :with_twitter_ident do
      after :build do |user|
        user.identities << FactoryGirl.build(:identity, user: user, provider: 'twitter', uid: 987654321)
      end
    end
    
    trait :with_github_ident do
      after :build do |user|
        user.identities << FactoryGirl.build(:identity, user: user, provider: 'github', uid: 123456789)
      end
    end

    factory :user_with_all_idents, traits: [:with_both_idents]
    factory :user_with_github_ident, traits: [:with_github_ident]
    factory :user_with_twitter_ident, traits: [:with_twitter_ident]
  end
end
