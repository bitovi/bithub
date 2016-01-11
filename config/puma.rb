if defined?(Puma)
  workers Integer(ENV['WEB_CONCURRENCY'] || 2)
  threads_count = Integer(ENV['MAX_THREADS'] || 5)
  threads threads_count, threads_count
  
  environment ENV['RACK_ENV'] || 'development'

  if ENV['ENV'] == 'production'
    preload_app!
    port ENV['PORT']
  elsif ENV['ENV'] == 'development'
    bind "unix:///tmp/bithub.sock"
  end

  rackup DefaultRackup

  on_worker_boot do
    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.establish_connection
      Rails.logger.info('Connected to Postgres (ActiveRecord)')
    end
  end
end
