# config valid only for Capistrano 3.1
#lock '3.1.0'

set :application, 'bithub'
set :user, 'bithub'

set :scm, :git
set :repo_url, 'git@github.com:bitovi/bithub.git'
ask :branch, 'master'
set :deploy_to, '/home/bithub/bithub'
set :ssh_options, { forward_agent: true }

set :format, :pretty
set :log_level, :info
set :pty, true

set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml',
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp/pids',
  'tmp/cache',
  'tmp/sockets',
  'vendor/bundle',
  'public/system'
)

set :default_env, { env: fetch(:stage), rails_env: fetch(:stage) }

set :keep_releases, 10

# Custom variables
set :backup_path, "/pg_dumps/"
set :backup_ext, ".dump"
set :current_path, File.join([fetch(:deploy_to), 'current'])
set :shared_path, File.join([fetch(:deploy_to), 'shared'])
set :log_path, File.join([fetch(:shared_path), 'log'])

# 'foreman' command should be prefixed with 'rbenv exec' and 'bundle exec'
set :rbenv_map_bins, fetch(:rbenv_map_bins, []).push('foreman')
set :bundle_bins, fetch(:bundle_bins, []).push('foreman')

after 'deploy:updated', 'newrelic:notice_deployment'
