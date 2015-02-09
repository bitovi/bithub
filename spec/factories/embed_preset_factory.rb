FactoryGirl.define do
  factory :embed_preset do
    name 'some_preset'
    embed_id nil
    config({ some_key: 'some_val' })
  end

end
