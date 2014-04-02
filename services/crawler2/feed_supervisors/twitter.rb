module FeedSupervisors
  class Twitter
    include Celluloid

    def initialize(brand_name, cfg)
      @brand_name = brand_name
      @config = cfg

      @client = ::Twitter::REST::Client.new do |config|
        config.consumer_key        = $app_auth.fetch(:twitter).fetch(:api_key)
        config.consumer_secret     = $app_auth.fetch(:twitter).fetch(:api_secret)
        config.access_token        = @config.fetch(:token)
        config.access_token_secret = @config.fetch(:token_secret)
      end

      boot
    end

    def boot
      Celluloid.logger.info "Booting Twitter supervisor for #{@brand_name}"
      @endpoints = SupervisionGroup.new
      @endpoints.supervise_as(actor_name, Poller, *[@brand_name, Fetchers::Twitter::TweetSearch.new(@client, {terms: @config.fetch(:terms)}), {interval: 360}])

      Celluloid::Actor[:twitter_public_stream].register(Channel.new(@brand_name, @config.fetch(:terms)))
    end

    def actor_name
      "#{@brand_name}_twitter_search".to_sym
    end

  end
end

