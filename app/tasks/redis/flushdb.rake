namespace :redis do
  desc "Flushes the Redis database specified in the ENV"
  task :flushdb => :environment do
    redis = ConnectionManager.instance.redis
    redis.flushdb
  end
end
