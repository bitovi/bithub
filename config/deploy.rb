require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set(:use_sudo, false)
set(:ssh_options, { :forward_agent => true })
set(:bundle_flags, "--deployment --quiet --binstubs")

set(:user, "bithub")
set(:application, "crawler")
set(:repository, "git@github.com:bitovi/bithub-crawler.git")

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
  task(:start) { run "sudo /usr/bin/service bithub-#{application}-#{app_env} start" }
  task(:stop) { run "sudo /usr/bin/service bithub-#{application}-#{app_env} stop" }
  task(:restart) { run "sudo /usr/bin/service bithub-#{application}-#{app_env} restart" }

  task(:recreate_upstart_conf) do
    run "#{current_path}/bin/foreman export --app bithub-#{application}-#{app_env} --user #{user} --env #{current_path}/.env_#{app_env} --procfile #{current_path}/Procfile upstart /etc/init"
  end
end

after('deploy:update_code', 'deploy:recreate_upstart_conf')
