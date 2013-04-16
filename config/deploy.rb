require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set(:use_sudo, false)
set(:ssh_options, { :forward_agent => true })
set(:bundle_flags, "--deployment --quiet --binstubs")
set(:normalize_asset_timestamps, false)

set(:user, "bithub")
set(:application, "web")
set(:repository, "git@github.com:bitovi/bithub.git")

set(:branch, "master")
set(:deploy_via, :remote_cache)
set(:deploy_to) { "/home/#{user}/#{application}/#{app_env}" }


set(:stages, ['staging', 'prod'])
set(:default_stage, 'staging')

server "69.164.216.88", :app, :web, :db, :primary => true

namespace :deploy do
  desc "Zero-downtime restart of Unicorn"
  task :restart, :except => { :no_release => true } do
    run "kill -s USR2 `cat #{shared_path}/tmp/pids/unicorn.pid`"
  end

  desc "Start unicorn"
  task :start, :except => { :no_release => true } do
    run "cd #{current_path} ; ./bin/unicorn_rails -c config/unicorn.rb"
  end

  desc "Stop unicorn"
  task :stop, :except => { :no_release => true } do
    run "kill -s QUIT `cat #{shared_path}/tmp/pids/unicorn.pid`"
  end

  # LISTENER
  # task(:start) { run "sudo /usr/bin/service bithub-#{application}-#{app_env} start" }
  # task(:stop) { run "sudo /usr/bin/service bithub-#{application}-#{app_env} stop" }
  # task(:restart) { run "sudo /usr/bin/service bithub-#{application}-#{app_env} restart" }
end
