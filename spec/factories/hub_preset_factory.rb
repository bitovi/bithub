FactoryGirl.define do
  factory :hub_preset do
    name 'some_preset'
    hub_id nil
    config({ some_key: 'some_val' })
  end

end
