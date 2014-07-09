FactoryGirl.define do

  factory :funnel_constraint do
    feed_name :github
    type_name :issue
    funnel
  end

  factory :funnel do
    name "example"
    display_name "A nice example"
    tags %w(bug canjs)

    transient do
      constraint_count 5
    end

    after(:build) do |funnel, evaluator|
      build_list(:post, evaluator.constraint_count, funnel: funnel)
    end

  end

end
