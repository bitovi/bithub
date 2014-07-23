module FeedSupervisors
  class Twitter
    include Celluloid

    def initialize(brand_name)
      @brand_name = brand_name
      boot
    end

    def boot
      Celluloid.logger.info "Booting Twitter supervisor for #{@brand_name}"

      @endpoints = SupervisionGroup.new
      user_tokens.each do |tokens|
        @endpoints.supervise_as(twitter_search_actor_name, Poller, *[@brand_name, Fetchers::Twitter::TweetSearch.new(client(tokens), {terms: terms}), {interval: 30}])
        # @endpoints.supervise_as(actor_name, Poller, *[@brand_name, Fetchers::Twitter::Followers.new(client(tokens)), {interval: 21600}])
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
        config.consumer_key        = static_config.fetch(:api_key)
        config.consumer_secret     = static_config.fetch(:api_secret)
        config.access_token        = token
        config.access_token_secret = token_secret
      end
      client
    end

    def user_tokens
      wc = Celluloid::Actor[:configurator].feed_config(@brand_name, :twitter)
      wc.fetch(:identities).map do |id|
        [id.fetch(:access_token), id.fetch(:access_secret)]
      end
    end

    def terms
      Celluloid::Actor[:configurator].feed_config(@brand_name, :twitter).fetch(:terms)
    end

    def static_config
      Celluloid::Actor[:configurator].static_config.fetch(:twitter)
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
