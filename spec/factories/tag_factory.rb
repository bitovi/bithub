FactoryGirl.define do

  factory :tag, :aliases => [:category, :feed] do
    sequence(:name) {|n| "tag#{n}" }
    sequence(:display_name) {|n| "Nice name #{n}" }
  end
end
