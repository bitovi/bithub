FactoryGirl.define do

  factory :activity do
    association :applies_to, factory: :event, title: "Some event"
    association :actor, factory: :user
    fullfilled true

    factory :activity_upvote do
      identificator "upvote"
      value 1
    end

    factory :activity_stake do
      identificator "stake"
      value 25
    end

  end
end
