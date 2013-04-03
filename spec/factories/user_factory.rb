FactoryGirl.define do

  factory :user do
    sequence(:name) {|n| "User ##{n}" }
    sequence(:email) {|n| "user#{n}@bitovi.com" }

    after :build do |user|
      user.identities << FactoryGirl.create(:identity_from_github, user: user)
      user.identities << FactoryGirl.create(:identity_from_twitter, user: user)
    end
  end

end
