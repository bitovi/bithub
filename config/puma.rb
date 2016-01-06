#!/usr/bin/env puma

require 'puma'

workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

# preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to Postgres (ActiveRecord)')
  end

  if defined?(Bunny)
    ConnectionManager.instance
    Rails.logger.info('Connected to RabbitMQ')
  end

  if defined?(Redis)
    ConnectionManager.instance
    Rails.logger.info('Connected to Redis')
  end
end
