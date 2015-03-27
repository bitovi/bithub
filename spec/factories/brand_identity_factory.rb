FactoryGirl.define do
  factory :brand_identity do
    provider 'facebook'
    source_data Hash.new
    extracted_data Hash.new
  end
end
