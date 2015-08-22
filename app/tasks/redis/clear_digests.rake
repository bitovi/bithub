namespace :redis do
  desc "Flushes crawler digests from the database specified in the ENV"
  task :clear_digests => :environment do
    redis = ConnectionManager.instance.redis
    if !(keys = redis.keys "digest*").empty?
      redis.del(keys)
    end
  end
end
