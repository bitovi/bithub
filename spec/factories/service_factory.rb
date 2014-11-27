FactoryGirl.define do

  factory :service do
    embed

    factory :rss_service do
      feed_name 'rss'
      type_name 'site'
      json_config Hash[
        'sites', %w(pltconfusion.com)
      ]
    end

    factory :twitter_service do
      feed_name 'twitter'
      type_name 'timeline'
      json_config Hash['terms', %w(canjs javascriptmvc)]
    end

    factory :facebook_service do
      feed_name 'facebook'
      type_name 'page'
      json_config Hash['pages', [
        { 'id' => '487939194652299',
          'name' => 'Koryu Bujutsu Zagreb',
          'access_token' => 'SomeToken123'
      }]]
    end

    factory :meetup_service do
      feed_name 'meetup'
      type_name 'group'
      json_config Hash['groups', [
        { 'id' => '10878382', 'name' => 'ZgElixir' },
        { 'id' => '13140052', 'name' => 'rubyzg' }
      ], 'terms', ['neektza']]
    end

    factory :disqus_service do
      feed_name 'disqus'
      type_name 'forum'
      json_config Hash['forums', [
        { 'id' => 'pltconfusion', 'name' => 'PLT Confusion' }
      ]]
    end

    factory :stackexchange_service do
      feed_name 'stackexchange'
      type_name 'tags'
      json_config Hash['tags', ['neektza']]
    end

    factory :github_service do
      feed_name 'github'
      type_name 'repo'
      json_config Hash[
        'repos',
        %w(neektza/twitter neektza/rmeetup),
        'orgs',
        ['KSET']
      ]
    end
  end
end
