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

  factory :award do
    association :applies_to, factory: :event, title: "Some award"
    association :actor, factory: :user
    value 50    
  end

end
