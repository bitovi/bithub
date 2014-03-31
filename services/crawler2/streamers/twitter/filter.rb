require 'twitter'

module Streamers
  module Twitter

    class Filter
      DEFAULT_TRACK_TERMS = %w(pizdamaterina)
      include Celluloid::IO
      include Registrable

      def initialize(auth = {})

        @client = ::Twitter::Streaming::Client.new({
          tcp_socket_class: Celluloid::IO::TCPSocket,
          ssl_socket_class: Celluloid::IO::SSLSocket
        }) do |config|
          config.consumer_key        = auth.fetch(:api_key)
          config.consumer_secret     = auth.fetch(:api_secret)
          config.access_token        = auth.fetch(:access_token)
          config.access_token_secret = auth.fetch(:access_token_secret)
        end

        @filters = []
        async.connect
      end

      def connect
        @client.filter(:track => topics.join(',')) do |object|
          puts "TWEET"
        end

        Celluloid.logger.info "Streaming twitter:public_stream with topics: #{topics}"
        link(@client)
      end

      def reconnect
        Celluloid.logger.info "Reconnecting twitter:public_stream"
        @client.terminate
        connect
      end

      def topics
        (t = @filters.map{|f| f.topics}.uniq.flatten).empty? ? DEFAULT_TRACK_TERMS : t
      end
    end
  end
end
