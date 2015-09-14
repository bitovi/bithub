require 'connection_pool'
require 'redis'
require 'redis/namespace'
require 'uri'

module Guzzler
  class RedisConnection
    class << self

      def create
        size = Guzzler.options[:concurrency] + 2

        ConnectionPool.new(:timeout => 1, :size => size) do
          client
        end
      end

      private

      def client
        Redis::Namespace.new('guzzler', :redis => Redis.new(url: 'redis://127.0.0.1:6379/15'))
      end

      def redis_url
        ENV.fetch('REDIS_URL')
      end
    end
  end
end
