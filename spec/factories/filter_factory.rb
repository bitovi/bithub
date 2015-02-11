FactoryGirl.define do

  factory :filter do
    is_conj true
    classification 'approving'

    trait :disjunctive do
      is_conj false
    end
    
    trait :conjunctive do
      is_conj true
    end
  end

end
