if defined?(Puma)
  workers Integer(ENV["WEB_CONCURRENCY"] || 2)
  threads_count = Integer(ENV["MAX_THREADS"] || 5)
  threads 1, threads_count

  rails_env = ENV["RACK_ENV"] || "development"
  environment rails_env

  bind "unix:///tmp/bithub.sock"

  stdout_redirect "/tmp/puma.stdout.log", "/tmp/puma.stderr.log", true

  pidfile "/tmp/puma.pid"
  state_path "/tmp/puma.state"

  preload_app!
  rackup DefaultRackup

  on_worker_boot do
    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.establish_connection
      Rails.logger.info('Connected to Postgres (ActiveRecord)')
    end
  end
end
