require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set(:use_sudo, false)
set(:ssh_options, { :forward_agent => true })
set(:bundle_flags, "--deployment --quiet --binstubs")

set(:user, "bithub")
set(:application, "crawler")
set(:repository, "git@github.com:bitovi/bithub-crawler.git")

set(:deploy_via, :remote_cache)
set(:deploy_to) { "/home/#{user}/#{application}" }

set(:normalize_asset_timestamps, false)
set(:default_environment, {
  'PATH' => "/opt/rbenv/bin:/opt/rbenv/shims:/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH"
})

set(:stages, ['staging', 'prod'])
set(:default_stage, 'prod')

namespace :deploy do
  task(:start) { run "sudo /usr/bin/service bithub-#{application} start" }
  task(:stop) { run "sudo /usr/bin/service bithub-#{application} stop" }
  task(:restart) { run "sudo /usr/bin/service bithub-#{application} restart" }

  task(:recreate_upstart_conf) do
    run "#{current_path}/bin/foreman export --log /var/log/bithub/#{application} --app bithub-#{application} --user #{user} --env #{current_path}/.env_#{app_env} --procfile #{current_path}/Procfile upstart /etc/init"
  end
end

before('deploy:restart', 'deploy:recreate_upstart_conf')
