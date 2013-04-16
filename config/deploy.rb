require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set(:use_sudo, false)
set(:ssh_options, { :forward_agent => true })
set(:bundle_flags, "--deployment --quiet --binstubs")

set(:user, "bithub")
set(:application, "irc-bot")
set(:repository, "git@github.com:jupiterjs/irc-bot.git")

set(:branch, "master")
set(:deploy_via, :remote_cache)
set(:deploy_to) { "/home/#{user}/#{application}/#{app_env}" }

set(:normalize_asset_timestamps, false)
set(:default_environment, {
  'PATH' => "/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH"
})

set(:stages, ['staging', 'prod'])
set(:default_stage, 'staging')

server "69.164.216.88", :app, :web, :db, :primary => true

namespace :deploy do
  task(:start) { run "sudo /usr/bin/service bithub-#{application}-#{app_env} start" }
  task(:stop) { run "sudo /usr/bin/service bithub-#{application}-#{app_env} stop" }
  task(:restart) { run "sudo /usr/bin/service bithub-#{application}-#{app_env} restart" }
end
