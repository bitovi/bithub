FactoryGirl.define do

  factory :rule do
    required_tags []
    authorship_value 0
    upvote_value 0
    award_value 0
    priority 0

    factory :rule_with_award do
      award_value 100
    end
    
  end

end
