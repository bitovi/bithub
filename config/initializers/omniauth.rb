module OmniAuth::Strategies

  class TwitterBrand < Twitter
    def name
      :twitter_brand
    end
  end

  class GitHubBrand < GitHub
    def name
      :github_brand
    end
  end

  class MeetupBrand < Meetup
    def name
      :meetup_brand
    end
  end

  class StackExchangeBrand < StackExchange
    def name
      :stackexchange_brand
    end
  end

  class FacebookBrand < Facebook
    def name
      :facebook_brand
    end
  end

  class DisqusBrand < Disqus
    def name
      :disqus_brand
    end
  end

  class FoursquareBrand < Foursquare
    def name
      :foursquare_brand
    end
  end

end

OmniAuth.config.add_camelization 'github_brand', 'GitHubBrand'
OmniAuth.config.add_camelization 'stackexchange_brand', 'StackExchangeBrand'
