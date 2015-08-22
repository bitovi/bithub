namespace :redis do
  desc "Flushes crawler locks from the database specified in the ENV"
  task :clear_locks => :environment do
    redis = ConnectionManager.instance.redis
    if !(keys = redis.keys "lock*").empty?
      redis.del(keys)
    end
  end
end
