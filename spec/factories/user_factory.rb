FactoryGirl.define do

  factory :country do
    iso "9001"
    name  "croatia"
    display_name "Croatia"
  end

  factory :user do
    name "Nikica"
    email "neektza@gmail.com"

    trait :with_completed_profile do
      address "Vukovarska"
      city "Zagreb"
      postal "10013"
      state "Grad Zagreb"
      association :country, factory: :country
    end

    props Hash.new

    trait :with_both_idents do
      after :build do |user|
        user.identities << FactoryGirl.build(:identity, user: user, provider: 'github', uid: 123456789)
        user.identities << FactoryGirl.build(:identity, user: user, provider: 'twitter', uid: 987654321)
      end

      after :create do |user|
        user.identities << FactoryGirl.create(:identity, user: user, provider: 'github', uid: 123456789)
        user.identities << FactoryGirl.create(:identity, user: user, provider: 'twitter', uid: 987654321)
      end
    end

    trait :with_twitter_ident do
      after :build do |user|
        user.identities << FactoryGirl.build(:identity, user: user, provider: 'twitter', uid: 987654321)
      end

      after :create do |user|
        user.identities << FactoryGirl.create(:identity, user: user, provider: 'twitter', uid: 987654321)
      end
    end

    trait :with_github_ident do
      after :build do |user|
        user.identities << FactoryGirl.build(:identity, user: user, provider: 'github', uid: 123456789)
      end

      after :create do |user|
        user.identities << FactoryGirl.create(:identity, user: user, provider: 'github', uid: 123456789)
      end
    end

  end
end
