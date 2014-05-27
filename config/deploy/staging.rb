server 'staging.bithub.com', user: fetch(:user), roles: %w{app db}
ask :branch, 'staging'

set :log_level, :debug

set :rbenv_custom_path, '~/.rbenv'
set :rbenv_type, :system
set :rbenv_ruby, '1.9.3-p392'
