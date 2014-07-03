require 'twitter'

module Streamers
  module Twitter

    class Client
      include Celluloid::IO

      def initialize(opts, &block)
        @block = block


        @auth = opts.fetch(:auth)
        @topics = opts.fetch(:topics)

        @client = ::Twitter::Streaming::Client.new({
          tcp_socket_class: Celluloid::IO::TCPSocket,
          ssl_socket_class: Celluloid::IO::SSLSocket
        }) do |config|
          config.consumer_key        = @auth.fetch(:api_key)
          config.consumer_secret     = @auth.fetch(:api_secret)
          config.access_token        = '55592490-2wJvxrMg7YS1Ndf2N0bGe8DRMr2ba3wmukx0vMUHw'
          config.access_token_secret = 'XREakQgM9iXvploScr7jT8JbwFlWapNO3PVrBSbTE'
        end

        async.connect
      end

      def connect
        @client.filter(:track => @topics.join(',')) do |object|
          @block.call object
        end
      end
    end

    class Filter
      include Celluloid
      include Registrable

      def initialize(auth = {})
        @auth = auth
      end

      def reconnect
        Celluloid.logger.info "Reconnecting twitter:public_stream with topics: #{topics}"
        @client.terminate if @client
        listen
      end

      def connect
        Celluloid.logger.info "Connecting twitter:public_stream with topics: #{topics}"
        listen if @channels.length > 0
      end

      private

      def listen
        @client = Client.supervise(auth: auth, topics: topics) do |object|
          route object, :twitter, %i(text)
        end
      end

      def topics
        (t = @channels.map{|c| c.topics}.uniq.flatten).empty? ? DEFAULT_TRACK_TERMS : t
      end

      def auth
        Celluloid::Actor[:configurator].static_config.fetch(:twitter)
      end

      DEFAULT_TRACK_TERMS = %w(bithub)
    end
  end
end
