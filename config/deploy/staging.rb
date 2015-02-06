server 'staging.bithub.com', user: fetch(:user), roles: %w{app db}
set :branch, 'master'

set :log_level, :debug
