server 'staging.bithub.com', user: fetch(:user), roles: %w{app web db}
set :branch, 'frontend-3-0'
set :log_level, :info
