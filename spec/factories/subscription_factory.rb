FactoryGirl.define do
  factory :subscription do
  end

  after(:create) do |sub|
    sub.class.skip_callback(:create, :before, :create_stripe_customer)
    sub.class.skip_callback(:destroy, :before, :delete_stripe_customer)
  end
end
