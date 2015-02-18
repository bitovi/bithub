namespace :redis do
  desc "Clear all digests from Redis (database from ENV)"
  task :clear_digests => :environment do
    redis = ConnectionManager.instance.redis
    if !(keys = redis.keys "digest*").empty?
      redis.del(keys)
    end
  end
end
