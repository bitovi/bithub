module Guzzler::Poller

  class RangeyRen

    def initialize(schedule_keyname)
      @schedule_keyname = schedule_keyname
    end
    
    def redis_key
      @schedule_keyname
    end

    def retrieve
      item = nil
      now = Time.now.to_f

      Guzzler.redis do |conn|
        conn.watch(@schedule_keyname) do
          service_key, score = conn.zrangebyscore(@schedule_keyname, '-inf', now, { :limit => [0, 1], :with_scores => true }).first
          if service_key && score
            if service_data = conn.redis.get(service_key)
              item = Guzzler::Service.new(service_key, service_data)
              conn.zincrby(@schedule_keyname, (now - score + item.interval), service_key)
            end
          end
        end
      end

      item
    end
  end

end
