FactoryGirl.define do

  factory :natlang_query do
    
    trait :contains_haskell do
      attr 'content'
      op 'contains'
      val 'haskell'
    end

    trait :tagged_with_canjs do
      attr ''
      op 'tagged_with'
      val 'canjs'
    end

    trait :is_from_twitter do
      attr 'feed_name'
      op 'is'
      val 'twitter'
    end

    trait :negated do
      is_negated true
    end
  end

end
