server 'staging.bithub.com', user: fetch(:user), roles: %w{app db}
set :branch, 'server_migration'

set :log_level, :debug
