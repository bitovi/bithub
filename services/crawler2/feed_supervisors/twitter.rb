module FeedSupervisors
  class Twitter
    include Celluloid

    def initialize(brand_name, cfg)
    end

    def fetchers
      Fetchers::Twitter::TweetSearch
    end

    def connectors
      if endpoint_name == :public
        Connectors::Twitter::Public
      elsif user_stream? endpoint_name
        Connectors::Twitter::User
      end
    end


  end
end

