# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'web'

set :scm, :git
set :repo_url, 'git@github.com:bitovi/bithub.git'
ask :branch, 'master'
set :deploy_to, '/home/bithub/web'
set(:ssh_options, {
      forward_agent: true
    })

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
#set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
set :default_env, {
  path: "/home/bithub/.rbenv/shims:/opt/rbenv/shims:$PATH",
  env: fetch(:stage),
  rails_env: fetch(:stage)
}

# Default value for keep_releases is 5
set :keep_releases, 10

# Custom variables
set :backup_path, "/backups/dbsnapshots/"
set :backup_ext, ".backup"
set :log_path, "/var/log/bithub/web/"
set :unicorn_log_path, "/home/bithub/web/shared/log"
set :user, "bithub"

# Bundler config
# set :bundle_roles, :all
# set :bundle_servers, -> { release_roles(fetch(:bundle_roles)) }
# set :bundle_binstubs, -> { shared_path.join('bin') }
# #set :bundle_gemfile, -> { release_path.join('MyGemfile') }
# set :bundle_path, -> { shared_path.join('bundle') }
# set :bundle_without, %w{development test}.join(' ')
# set :bundle_flags, '--deployment --quiet'
# set :bundle_env_variables, {}


namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
