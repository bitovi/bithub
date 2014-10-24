FactoryGirl.define do

  factory :natlang_query do
    trait :contains_canjs do
      attr 'content'
      op 'contains'
      val 'canjs'
    end

    trait :is_from_github do
      attr 'feed_name'
      op 'is'
      val 'github'
    end
  end

end
