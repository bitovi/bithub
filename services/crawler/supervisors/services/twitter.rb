module Supervisors::Services
  class Twitter < Supervisors::Service
    def boot
      @endpoints = SupervisionGroup.new
      user_tokens.each do |tokens|
        tweet_search_fetcher = Fetchers::Twitter::TweetSearch.new(
          client(tokens),
          {terms: terms}
        )

        @endpoints.supervise_as(
          twitter_search_actor_name, Poller, *[
            @brand_name,
            @embed_name,
            tweet_search_fetcher,
            {interval: 60}
          ]
        )

        followers_fetcher = Fetchers::Twitter::Followers.new(client(tokens))
        @endpoints.supervise_as(
          follow_actor_name, Poller, *[
            @brand_name,
            @embed_name,
            followers_fetcher,
            { interval: 600 }
          ]
        )
      end

      Celluloid::Actor[:commander].publish(register_msg, :registration)
    end

    def reload
      Celluloid::Actor[twitter_search_actor_name].fetcher.set_terms(terms)
      commander.publish(unregister_msg.merge({:reloading => true}), :registration)
      commander.publish(register_msg.merge({:reloading => true}), :registration)
    end

    def twitter_search_actor_name
      "#{@brand_name}_twitter_search".to_sym
    end

    def follow_actor_name
      "#{@brand_name}_follows".to_sym
    end

    def commander
      Celluloid::Actor[:commander]
    end

    private

    def client(tokens)
      token, token_secret = tokens
      client = ::Twitter::REST::Client.new do |config|
        config.consumer_key        = api_key
        config.consumer_secret     = api_secret
        config.access_token        = token
        config.access_token_secret = token_secret
      end
      client
    end

    def user_tokens
      service_config.fetch(:identities).map do |id|
        [id.fetch(:access_token), id.fetch(:access_secret)]
      end
    end

    def terms
      service_config.fetch(:terms)
    end

    def api_key
      static_config.fetch(:twitter).fetch(:api_key)
    end

    def api_secret
      static_config.fetch(:twitter).fetch(:api_secret)
    end

    def register_msg
      {
        :action => :register,
        :feed_name => :twitter,
        :brand_name => @brand_name,
        :terms => terms
      }
    end

    def unregister_msg
      {
        :action => :unregister,
        :feed_name => :twitter,
        :brand_name => @brand_name
      }
    end

  end
end
