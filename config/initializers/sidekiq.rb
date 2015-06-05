Sidekiq.configure_server do |config|
  Sidekiq::Logging.logger = LoggerFactory.new('worker_server', :environment => Rails.env).logger

  config.redis = { :url => ENV['REDIS_URL'], :namespace => 'sidekiq' }
end

Sidekiq.configure_client do |config|
  Sidekiq::Logging.logger = LoggerFactory.new('worker_client', :environment => Rails.env).logger

  config.redis = { :url => ENV['REDIS_URL'], :namespace => 'sidekiq' }
end

