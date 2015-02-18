namespace :redis do
  desc "Flushes Redis (database from ENV)"
  task :flushdb => :environment do
    redis = ConnectionManager.instance.redis
    redis.flushdb
  end
end
