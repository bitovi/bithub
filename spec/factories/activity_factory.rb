FactoryGirl.define do

  factory :upvote do
    association :applies_to, factory: :event, title: "Some event"
    association :actor, factory: :user
    value 1
  end

  factory :anteup do
    association :applies_to, factory: :event, title: "Some event"
    association :actor, factory: :user
    value 25
  end

end
