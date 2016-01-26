require 'guzzler/guzzler'

module Guzzler
  class Client

    def self.guzzle(service)
      if service.listens?
        cache_listening(service)
      else
        cache_polling(service)
      end
    end

    def self.unguzzle(service)
      if service.listens?
        clear_listening_cache(service)
      else
        clear_polling_cache(service)
      end
    end

    def self.cache_listening(service)
      Guzzler.redis do |conn|
        conn.multi do
          conn.set(service.key, service.data.to_json)
          conn.sadd('services:listening', service.member)
        end
      end
    end

    def self.cache_polling(service)
      Guzzler.redis do |conn|
        conn.multi do
          conn.set(service.key, service.data.to_json)
          conn.zadd('services:polling', Time.now.to_f, service.member)
        end
      end
    end
    
    def self.clear_listening_cache(service)
      Guzzler.redis do |conn|
        conn.multi do
          conn.del(service.key, service.data.to_json)
          conn.srem('services:listening', service.member)
          conn.srem('services:listening:subscribed', service.member)
          delete_digests(conn, service)
        end
      end
    end

    def self.clear_polling_cache(service)
      Guzzler.redis do |conn|
        conn.multi do
          conn.del(service.key, service.data)
          conn.zrem('services:polling', service.member)
          delete_digests(conn, service)
        end
      end
    end

    def delete_digests(conn, service)
      conn.del("digests:batch:#{service.tenant_name}:#{service.id}")
      conn.del("digests:total:#{service.tenant_name}:#{service.id}")
    end
  end
end
