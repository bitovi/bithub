require 'guzzler/guzzler'

module Guzzler
  module Jobs
    class Client

      def self.schedule(service)
        Guzzler.redis do |conn|
          conn.multi do
            conn.set(service.key, service.data.to_json)
            conn.zadd('schedule', Time.now.to_f, service.member)
          end
        end
      end

      def self.unschedule(service)
        Guzzler.redis do |conn|
          conn.multi do
            conn.del(service.key, service.data)
            conn.zrem('schedule', service.member)
          end
        end
      end

    end
  end
end
