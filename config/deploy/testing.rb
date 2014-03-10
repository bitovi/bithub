server 'testing.bithub.com', user: fetch(:user), roles: %w{app db} #, my_property: :my_value
set :branch, 'testing'

set :log_level, :debug

set :rbenv_custom_path, '/opt/rbenv'
set :rbenv_type, :system
set :rbenv_ruby, '2.1.1'
