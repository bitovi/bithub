require 'connection_pool'
require 'redis'
require 'redis/namespace'
require 'uri'

module Guzzler
  class RedisConnection
    class << self

      def create(options = {})
        options[:url] ||= redis_url

        ConnectionPool.new(:timeout => 1, :size => 5) do
          create_client(options)
        end
      end

      private

      def create_client(options = {})
        namespace = options[:namespace] || 'guzzler'
        Redis::Namespace.new(namespace, :redis => Redis.new(:url => options.fetch(:url)))
      end

      def redis_url
        ENV['REDIS_URL'] || 'redis://127.0.0.1:6379/15'
      end
    end
  end
end
