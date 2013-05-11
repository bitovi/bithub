FactoryGirl.define do

  factory :user do
    sequence(:name) {|n| "User ##{n}" }
    sequence(:email) {|n| "user#{n}@bitovi.com" }

    trait :with_ident do
      after :build do |user|
        FactoryGirl.create(:identity, user: user, provider: 'github', uid: 123456789)
        FactoryGirl.create(:identity, user: user, provider: 'twitter', uid: 987654321)
      end
    end
  end
end
