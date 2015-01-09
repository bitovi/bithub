FactoryGirl.define do
  factory :brand do
    name "bitovi"
    tenant_name "bitovi"
  end

  factory :brands_user do
    total_score 0
  end
    
  after(:create) do |brand|
    brand.class.skip_callback(:create, :after, :notify_brand_start)
    brand.class.skip_callback(:update, :after, :notify_brand_restart)
    brand.class.skip_callback(:destroy, :after, :notify_brand_stop)
  end
end
