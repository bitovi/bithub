FactoryGirl.define do

  factory :service do
    embed

    factory :rss_service do
      feed_name 'rss'
      type_name 'site'
      config Hash[
        'url', 'pltconfusion.com',
        'tag_with', 'wat'
      ]
    end

    factory :twitter_service do
      feed_name 'twitter'
      type_name 'user_timeline'
      config Hash[
        'handle', 'bitovi',
        'display_name', 'Bitovi'
      ]
    end

    factory :facebook_service do
      feed_name 'facebook'
      type_name 'page'
      config Hash[
        'id', '487939194652299',
        'display_name', 'Koryu Bujutsu Zagreb'
      ]
    end

    factory :meetup_service do
      feed_name 'meetup'
      type_name 'group'
      config Hash[
        'id', '10878382',
        'display_name', 'ZgElixir'
      ]
    end

    factory :disqus_service do
      feed_name 'disqus'
      type_name 'forum'
      config Hash[
        'url', 'pltconfusion.com',
        'display_name', 'PLT Confusion'
      ]
    end

    factory :stackexchange_service do
      feed_name 'stackexchange'
      type_name 'tags'
      config Hash[
        'tags', ['neektza']
      ]
    end

    factory :github_service do
      feed_name 'github'
      type_name 'repo'
      config Hash[
        'name', 'bitovi/bithub',
        'tracking', Hash['issues', true, 'pull_requests', true]
      ]
    end

    after(:create) do |service|
      service.class.skip_callback(:create, :after, :notify_service_start)
      service.class.skip_callback(:update, :after, :notify_service_restart)
      service.class.skip_callback(:destroy, :after, :notify_service_stop)
    end
  end
end
