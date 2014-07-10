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
        @endpoints.supervise_as(actor_name, Poller, *[@brand_name, Fetchers::Twitter::TweetSearch.new(client(tokens), {terms: terms}), {interval: 300}])
        # @endpoints.supervise_as(actor_name, Poller, *[@brand_name, Fetchers::Twitter::Followers.new(client(tokens)), {interval: 21600}])
      end

      if Celluloid::Actor[:twitter_public_stream]
        Celluloid::Actor[:twitter_public_stream].register(Channel.new(@brand_name, terms))
      end
    end

    def reload
      if Celluloid::Actor[:twitter_public_stream]
        Celluloid::Actor[:twitter_public_stream].unregister(@brand_name, reloading: true)
        Celluloid::Actor[:twitter_public_stream].register(Channel.new(@brand_name, terms), reloading: true)
      end
    end

    def actor_name
      "#{@brand_name}_twitter_search".to_sym
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

  end
end
