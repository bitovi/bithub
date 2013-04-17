require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set(:use_sudo, false)
set(:ssh_options, { :forward_agent => true })
set(:bundle_flags, "--deployment --quiet --binstubs")

set(:user, "bithub")
set(:application, "web")
set(:repository, "git@github.com:bitovi/bithub.git")

set(:branch, "master")
set(:deploy_via, :remote_cache)
set(:deploy_to) { "/home/#{user}/#{application}/#{app_env}" }

set(:normalize_asset_timestamps, false)
set(:default_environment, {
  'PATH' => "/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH"
})

set(:stages, ['staging', 'prod'])
set(:default_stage, 'prod')

server "69.164.216.88", :app, :web, :db, :primary => true

namespace :deploy do
  desc "Zero-downtime restart of Unicorn"
  task :restart, :except => { :no_release => true } do
    run "kill -s USR2 `cat #{shared_path}/pids/unicorn.pid`"
    run "sudo /usr/bin/service bithub-listener-#{app_env} restart"
  end

  desc "Start unicorn"
  task :start, :except => { :no_release => true } do
    run "cd #{current_path} ; ./bin/unicorn_rails -c config/unicorn.rb -D -E production"
    run "sudo /usr/bin/service bithub-listener-#{app_env} start"
  end

  desc "Stop unicorn"
  task :stop, :except => { :no_release => true } do
    run "kill -s QUIT `cat #{shared_path}/pids/unicorn.pid`"
    run "sudo /usr/bin/service bithub-listener-#{app_env} stop"
  end

  task(:recreate_upstart_conf) do
    run "#{current_path}/bin/foreman export --app bithub-listener-#{app_env} --user #{user} --env #{current_path}/.env_#{app_env} --procfile #{current_path}/Procfile upstart /etc/init"
  end
end

after('deploy:update_code', 'deploy:recreate_upstart_conf')
