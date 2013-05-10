FactoryGirl.define do

  factory :user do
    sequence(:name) {|n| "User ##{n}" }
    sequence(:email) {|n| "user#{n}@bitovi.com" }

    trait :with_ident do
      after :build do |user|
        user.identities << FactoryGirl.create(:identity, user: user, provider: 'github')
        user.identities << FactoryGirl.create(:identity, user: user, provider: 'twitter')
      end
    end
  end
end
