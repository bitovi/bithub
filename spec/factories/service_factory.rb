FactoryGirl.define do

  factory :service do
    factory :twitter_service do
      feed_name 'twitter'
      config Hash['terms', %w(canjs javascriptmvc)]
    end

    factory :facebook_service do
      feed_name 'facebook'
      config Hash['pages', [
        { 'id' => '487939194652299',
          'name' => 'Koryu Bujutsu Zagreb',
          'access_token' => 'SomeToken123'
      }]]
    end

    factory :meetup_service do
      feed_name 'meetup'
      config Hash['groups', [
        { 'id' => '10878382', 'name' => 'ZgElixir' },
        { 'id' => '13140052', 'name' => 'rubyzg' }
      ], 'terms', ['neektza']]
    end

    factory :disqus_service do
      feed_name 'disqus'
      config Hash['forums', [
        { 'id' => 'pltconfusion', 'name' => 'PLT Confusion' }
      ]]
    end

    factory :stackexchange_service do
      feed_name 'stackexchange'
      config Hash['tags', ['neektza']]
    end

    factory :github_service do
      feed_name 'github'
      config Hash[
        'repos',
        %w(neektza/twitter neektza/rmeetup),
        'orgs',
        ['KSET']
      ]
    end

  end
end
