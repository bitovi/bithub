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
        if locker.locked?(lock_name)
          Celluloid.logger.info "Twitter stream locked, trying again in a minute"
          try_again_later
        else
          @retry.cancel if @retry
          @client.filter(:track => @topics.join(',')) do |object|
            @block.call object
          end
        end
      rescue ::Twitter::Error::TooManyRequests => e
        locker.lock(lock_name, lock_duration)
        Celluloid.logger.info "Locked streaming for #{lock_duration/60} minutes"
        Celluloid.logger.error e
        raise e
      end

      def try_again_later
        if @retry
          @retry.reset
        else
          @retry = after(60) { connect }
        end
      end

      def lock_name
        Celluloid::Actor[:stream_supervisor].twitter_lock_name 
      end
      
      def lock_duration
        Celluloid::Actor[:stream_supervisor].twitter_lock_duration
      end

      def locker
        Celluloid::Actor[:lock_manager]
      end
    end
  end
end
