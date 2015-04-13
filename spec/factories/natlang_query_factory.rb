FactoryGirl.define do

  factory :natlang_query do
    
    trait :contains_haskell do
      attr_name 'content'
      op 'contains_all'
      val 'haskell'
    end

    trait :is_from_twitter do
      attr_name 'feed_name'
      op 'is'
      val 'twitter'
    end

    trait :negated do
      is_negated true
    end
  end

end
