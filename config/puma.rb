if defined?(Puma)
  workers Integer(ENV["WEB_CONCURRENCY"] || 2)
  threads_count = Integer(ENV["MAX_THREADS"] || 5)
  threads 1, threads_count

  app_dir = File.expand_path("../../..", File.dirname(__FILE__))
  shared_dir = "#{app_dir}/shared"

  rails_env = ENV["RACK_ENV"] || "production"
  environment rails_env

  bind "unix://#{shared_dir}/sockets/puma.sock"

  stdout_redirect "#{shared_dir}/logs/puma.stdout.log", "#{shared_dir}/logs/puma.stderr.log", true

  pidfile "#{shared_dir}/pids/puma.pid"
  state_path "#{shared_dir}/pids/puma.state"

  preload_app!
  rackup DefaultRackup

  on_worker_boot do
    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.establish_connection
      Rails.logger.info('Connected to Postgres (ActiveRecord)')
    end
  end
end
