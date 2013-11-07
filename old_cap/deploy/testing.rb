set :stage, :testing
set :app_env, :testing
set :branch, :testing

server 'testing.bithub.com', user: 'bithub', roles: %w{web app db broker}
