# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'web'

set :scm, :git
set :repo_url, 'git@github.com:bitovi/bithub.git'
ask :branch, 'master'
set :deploy_to, '/home/bithub/web'
set(:ssh_options, { forward_agent: true })

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
set :pty, true

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
