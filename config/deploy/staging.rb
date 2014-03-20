server 'staging.bithub.com', user: fetch(:user), roles: %w{app db}
ask :branch, 'staging'
