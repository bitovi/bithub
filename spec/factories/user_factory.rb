FactoryGirl.define do
  factory :user do
    name "Nikica"
    email "neektza@gmail.com"

    after :build do |user|
      user.identities << FactoryGirl.create(:identity, user: user)
      user.identities << FactoryGirl.create(:identity_from_github, user: user)
      user.identities << FactoryGirl.create(:identity_from_twitter, user: user)
    end
  end
end
