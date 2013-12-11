require 'capistrano/ext/multistage'
require 'capistrano/node-deploy'
require 'bundler/capistrano'

set(:use_sudo, false)
set(:ssh_options, { :forward_agent => true })
set(:bundle_flags, "--deployment --quiet --binstubs")

set(:user, "bithub")
set(:application, "liveservice")
set(:repository, "git@github.com:jupiterjs/feeder-web.git")
set(:branch, "live-service")
set(:deploy_via, :remote_cache)
set(:deploy_to) { "/home/#{user}/#{application}" }

set(:default_environment, {
  'PATH' => "/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH"
})

set(:stages, ['staging', 'prod'])
set(:default_stage, 'prod')

set :node_binary, "/usr/local/bin/node"
set :node_user, "bithub"

namespace :deploy do
  desc "Restart the live service"
  task :restart, :except => { :no_release => true } do
    run "sudo /usr/bin/service bithub-#{application} restart"
  end

  desc "Start the live service"
  task :start, :except => { :no_release => true } do
    run "sudo /usr/bin/service bithub-#{application} start"
  end

  desc "Stop the live service"
  task :stop, :except => { :no_release => true } do
    run "sudo /usr/bin/service bithub-#{application} stop"
  end

  task(:recreate_upstart_conf) do
    run "#{current_path}/bin/foreman export --app bithub-#{application} --user #{user} --env #{current_path}/.env_#{app_env} --procfile #{current_path}/Procfile upstart /etc/init"
  end
end

after('deploy:update', 'deploy:restart')
before('deploy:restart', 'deploy:recreate_upstart_conf')
