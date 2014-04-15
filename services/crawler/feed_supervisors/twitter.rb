module FeedSupervisors
  class Twitter
    include Celluloid

    def initialize(brand_name)
      @brand_name = brand_name
      boot
    end

    def boot
      Celluloid.logger.info "Booting Twitter supervisor for #{@brand_name}"
      @client = init_client

      @endpoints = SupervisionGroup.new
      @endpoints.supervise_as(actor_name, Poller, *[@brand_name, Fetchers::Twitter::TweetSearch.new(@client, {terms: terms}), {interval: 3600}])

      Celluloid::Actor[:twitter_public_stream].register(Channel.new(@brand_name, terms))
    end

    def reload
      Celluloid::Actor[:configurator].reload
      Celluloid::Actor[:twitter_public_stream].unregister(@brand_name, reloading: true)
      Celluloid::Actor[:twitter_public_stream].register(Channel.new(@brand_name, terms), reloading: true)
      @client = init_client
    end

    def actor_name
      "#{@brand_name}_twitter_search".to_sym
    end

    private

    def init_client
      token, token_secret = user_tokens
      ::Twitter::REST::Client.new do |config|
        config.consumer_key        = $app_auth.fetch(:twitter).fetch(:api_key)
        config.consumer_secret     = $app_auth.fetch(:twitter).fetch(:api_secret)
        config.access_token        = token
        config.access_token_secret = token_secret
      end
    end

    def user_tokens
      wc = Celluloid::Actor[:configurator].feed_config(@brand_name, :twitter)
      [wc.fetch(:token), wc.fetch(:token_secret)]
    end

    def terms
      Celluloid::Actor[:configurator].feed_config(@brand_name, :twitter).fetch(:terms)
    end

  end
end
