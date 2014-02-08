require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'travis/pro'


set(:use_sudo, false)
set(:ssh_options, { :forward_agent => true })
set(:bundle_flags, "--deployment --quiet --binstubs")

set(:user, "bithub")
set(:application, "web")
set(:repository, "git@github.com:bitovi/bithub.git")

set(:branch, "master")
set(:deploy_via, :remote_cache)
set(:deploy_to) { "/home/#{user}/#{application}" }

set(:normalize_asset_timestamps, false)
set(:default_environment, {
  'PATH' => "/opt/rbenv/shims/:/opt/rbenv/bin:/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH"
})

set(:stages, ['testing', 'staging', 'prod'])
set(:default_stage, 'testing')

set(:shared_children, shared_children + %w{public/uploads})

set :ci_access_token, "DTaq7IXrUgbhNeaBVtTdcA"
set :ci_repository, "bitovi/bithub"

namespace :deploy do

  desc "Recreate Upstart configuration"
  task(:recreate_upstart_conf) do
    run "#{current_path}/bin/foreman export --app bithub --log /var/log/bithub/web --user #{user} --env #{current_path}/.env_#{app_env} --procfile #{current_path}/Procfile.#{app_env} upstart /etc/init"
  end

  desc "Symling uploads from shared to public folder"
  task :symlink_uploads do
    run "ln -nfs #{shared_path}/uploads  #{current_path}/public/uploads"
  end

  namespace :listener do
    desc "Start listener"
    task :start, :except => { :no_release => true } do
      run "sudo /usr/bin/service bithub-listener start"
    end

    desc "Stop listener"
    task :stop, :except => { :no_release => true } do
      run "sudo /usr/bin/service bithub-listener stop"
    end
  end

  namespace :crawler do
    desc "Start crawler"
    task :start, :except => { :no_release => true } do
      run "sudo /usr/bin/service bithub-crawler start"
    end

    desc "Stop crawler"
    task :stop, :except => { :no_release => true } do
      run "sudo /usr/bin/service bithub-crawler stop"
    end
  end

  namespace :web do
    desc "Start unicorn"
    task :start, :except => { :no_release => true } do
      run "sudo /usr/bin/service bithub-web start"
    end

    desc "Stop unicorn"
    task :stop, :except => { :no_release => true } do
      run "sudo /usr/bin/service bithub-web stop"
    end
  end

  namespace :ircbot do
    desc "Start IRC bot"
    task :start, :except => { :no_release => true } do
      run "sudo /usr/bin/service bithub-irc_bot stop"
    end

    desc "Stop IRC bot"
    task :stop, :except => { :no_release => true } do
      run "sudo /usr/bin/service bithub-irc_bot stop"
    end
  end

  namespace :liveservice do
    desc "Start live service"
    task :start, :except => { :no_release => true } do
      run "sudo /usr/bin/service bithub-liveservice stop"
    end

    desc "Stop live service"
    task :stop, :except => { :no_release => true } do
      run "sudo /usr/bin/service bithub-liveservice stop"
    end
  end
end

#before('deploy', 'travis:verify')
before('deploy:restart', 'deploy:recreate_upstart_conf')
before('deploy:restart', 'deploy:symlink_uploads')

#after('deploy', 'db:backup')
