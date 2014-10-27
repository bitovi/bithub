FactoryGirl.define do

  factory :filter do
    is_conj true
    classification 'moderating'

    trait :disjunctive do
      is_conj false
    end
    
    trait :conjunctive do
      is_conj true
    end
  end

end
