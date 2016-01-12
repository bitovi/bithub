module Guzzler
  # Type can be either 'listening' or 'polling'
  
  def self.service_config(service_key)
    service_key.gsub!('guzzler:', '')
    redis do |conn|
      Guzzler.logger.debug "--------------> S_KEY: #{service_key}"
      str = conn.get(service_key)
      Guzzler.logger.debug "--------------> S_CFG: #{str}"
      str
    end
  end

  def self.services(type)
    type = type.to_s

    if type == 'listening'
      redis do |conn|
        conn.smembers "services:#{type}"
      end
    else
      redis do |conn|
        conn.zrange "services:#{type}", 0, -1
      end
    end
  end

  def self.enq(q_name, item)
    redis do |conn|
      conn.lpush(q_name, item.to_json)
    end
  end

  def self.deq(q_name)
    redis do |conn|
      conn.rpop(q_name)
    end
  end
  
end
