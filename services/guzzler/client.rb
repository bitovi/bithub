require 'guzzler/guzzler'

module Guzzler
  class Client

    def self.guzzle(service)
      if service.listens?
        start_listening(service)
      else
        start_polling(service)
      end
    end

    def self.unguzzle(service)
      if true
        stop_listening(service)
      else
        stop_polling(service)
      end
    end

    def self.start_listening(service)
      Guzzler.redis do |conn|
        conn.multi do
          conn.set(service.key, service.data.to_json)
          conn.sadd('services:listening', service.member)
        end
      end
    end

    def self.stop_listening(service)
      Guzzler.redis do |conn|
        conn.multi do
          conn.del(service.key, service.data.to_json)
          conn.srem('services:listening', service.member)
        end
      end
    end

    def self.start_polling(service)
      Guzzler.redis do |conn|
        conn.multi do
          conn.set(service.key, service.data.to_json)
          conn.zadd('services:polling', Time.now.to_f, service.member)
        end
      end
    end

    def self.stop_polling(service)
      Guzzler.redis do |conn|
        conn.multi do
          conn.del(service.key, service.data)
          conn.zrem('services:polling', service.member)
        end
      end
    end

  end
end
