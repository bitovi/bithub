FactoryGirl.define do
  factory :user do
    name "Nikica"
    email "neektza@gmail.com"


    after :build do |user|
      FactoryGirl.create_list(:identity, 2, user: user)
    end
  end
end
