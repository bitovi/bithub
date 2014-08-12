server 'staging.bithub.com', user: fetch(:user), roles: %w{app db}
set :branch, 'staging'

set :log_level, :debug

set :rbenv_custom_path, '/opt/rbenv'
set :rbenv_type, :system
set :rbenv_ruby, '2.1.1'
