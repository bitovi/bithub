require 'json'
require 'redis'
require 'redis-namespace'

conn = Redis::Namespace.new('guzzler', :redis => (redis = Redis.new(:db => 15)))

def pop_job(conn)
  now = Time.now.to_f; job = nil;
  conn.watch(schedule_key) do
    if (sk = conn.zrangebyscore(schedule_key, '-inf', now, :limit => [0, 1]).first)
      if sd = conn.redis.get(sk) # get without namespace
        job = JSON.parse(sd)
        conn.multi do |multi|
          multi.zrem(schedule_key, sk)
          multi.zadd(schedule_key, now + job['interval'].to_f, sk)
        end
      end
    end
  end
  job
end

def generate_random_jobs(conn)
  1000.times do
    service_data = {
      'brand_id' => rand(100),
      'service_id' => rand(1000),
      'interval' => rand(1..5)
    }

    conn.set(service_key(service_data), JSON.generate(service_data))
    conn.zadd(schedule_key, Time.now.to_f - rand(100), service_key(service_data))
  end
end

def service_key(service_data)
  brand_id = service_data['brand_id']
  service_id = service_data['service_id']
  "#{services_registry_prefix}:#{brand_id}:#{service_id}"
end

def schedule_key
  'schedule'
end

def services_registry_prefix
  'services'
end

