FactoryGirl.define do

  factory :feed_config do
    brand_name 'neektza'
    brand

    factory :feed_config_twitter do
      feed_name 'twitter'
      config Hash["terms", ["canjs", "javascriptmvc"]]
    end

    factory :feed_config_facebook do
      feed_name 'facebook'
      config Hash["pages", [{ "id"=>"487939194652299", "name"=>"Koryu Bujutsu Zagreb", "access_token"=>"SomeToken123"}]]
    end

    factory :feed_config_meetup do
      feed_name "meetup"
      config Hash["groups", [{"id"=>"10878382", "name"=>"ZgElixir"}, {"id"=>"13140052", "name"=>"rubyzg"}], "terms", ["neektza"]]
    end
    
    factory :feed_config_disqus do
      feed_name 'disqus'
      config Hash["forums", [{"id"=>"pltconfusion", "name"=>"PLT Confusion"}]]
    end

    factory :feed_name_stackexchange do
      feed_name "stackexchange"
      config Hash["tags", ["neektza"]]
    end
    
    factory :feed_config_github do
      feed_name 'github'
      config Hash["repos", ["neektza/twitter", "neektza/rmeetup"], "orgs", ["KSET"]]
    end

  end
end
