namespace :redis do
  desc "Flushes the Redis database specified in the ENV"
  task :flushdb => :environment do
    redis = Redis.new(:db => 15)
    redis.flushdb
  end
end
