FactoryGirl.define do
  factory :account do
    email "kikica@gmail.com"
    password "coobar123"
    password_confirmation "coobar123"
    association :invite_code, factory: [:invite_code, :surely_doesnt_exist]
  end
end

