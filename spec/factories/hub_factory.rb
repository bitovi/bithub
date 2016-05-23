FactoryGirl.define do
  factory :hub do
    name "an hub that hubs Internet"

    trait :permissive do
      approved_by_default true
    end
    
    trait :restrictive do
      approved_by_default false
    end

    before(:create) do |hub|
      hub.class.skip_callback(:create, :after, :notify_hub_start)
      hub.class.skip_callback(:update, :after, :notify_hub_restart)
      hub.class.skip_callback(:destroy, :after, :notify_hub_stop)
    end
  end
end
