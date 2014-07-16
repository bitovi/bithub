require_relative 'client'

module Streamers
  module Twitter

    class Filter
      include Celluloid::IO
      include Registrable

      def initialize(auth = {})
        @auth = auth
        async.timed_connect(false)
      end

      def reconnect
        @client.terminate if @client
        connect
      end

      def connect
        listen if channels.length > 0
      end

      private

      def listen
        Celluloid.logger.info "Connecting to Twitter streaming API with topics: #{topics}"
        @client = Client.supervise(auth: auth, topics: topics) do |object|
          route object, :twitter, %i(text)
        end
      end

      def topics
        (t = channels.map{|c| c.topics}.uniq.flatten).empty? ? DEFAULT_TRACK_TERMS : t
      end

      def auth
        Celluloid::Actor[:configurator].static_config.fetch(:twitter)
      end

      DEFAULT_TRACK_TERMS = %w(bithub)
    end
  end
end
