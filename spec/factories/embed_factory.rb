FactoryGirl.define do
  factory :embed do
    name "an embed that embeds Internet"

    trait :permissive do
      approved_by_default true
    end
    
    trait :restrictive do
      approved_by_default false
    end

    before(:create) do |embed|
      embed.class.skip_callback(:create, :after, :notify_embed_start)
      embed.class.skip_callback(:update, :after, :notify_embed_restart)
      embed.class.skip_callback(:destroy, :after, :notify_embed_stop)
    end
  end
end
