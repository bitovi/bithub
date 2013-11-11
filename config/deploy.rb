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
set(:deploy_to) { "/home/#{user}/#{application}" }

set(:normalize_asset_timestamps, false)
set(:default_environment, {
  'PATH' => "/opt/rbenv/shims/:/opt/rbenv/bin:/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH"
})

set(:stages, ['testing', 'staging', 'prod'])
set(:default_stage, 'prod')

set(:shared_children, shared_children + %w{public/uploads})

namespace :deploy do

  desc "Zero-downtime restart of Unicorn"
  task :restart, :except => { :no_release => true } do
    run "kill -s USR2 `cat #{shared_path}/pids/unicorn.pid`"
    run "sudo /usr/bin/service bithub-listener restart"

    timeout = 10
    puts "Waiting for #{timeout} seconds before killing old unicorn master processes"
    sleep timeout

    run "ps aux |grep \"[m]aster (old)\"" do |channel, stream, data|
      data.split(/\r?\n/).each do |row|
        attrs = row.split()
        puts "Killing old unicorn_rails master with PID #{attrs[1]}"
        run "kill #{attrs[1]}"
      end
    end
  end

  desc "Start unicorn"
  task :start, :except => { :no_release => true } do
    envs = capture "cat #{current_path}/.env_#{app_env} | egrep '^[A-Z]'"
    env_hash = Hash[envs.lines.map {|l| l.strip.split('=')}]
    run "cd #{current_path}; ./bin/unicorn_rails -D -c config/unicorn.rb", { env: env_hash }
    run "sudo /usr/bin/service bithub-listener start"
  end

  desc "Stop unicorn"
  task :stop, :except => { :no_release => true } do
    run "kill -s QUIT `cat #{shared_path}/pids/unicorn.pid`"
    run "sudo /usr/bin/service bithub-listener stop"
  end

  desc "Recreate Upstart configuration"
  task(:recreate_upstart_conf) do
    run "#{current_path}/bin/foreman export --app bithub-listener --log /var/log/bithub/listener --user #{user} --env #{current_path}/.env_#{app_env} --procfile #{current_path}/Procfile.#{app_env} upstart /etc/init"
  end

  desc "Symling uploads from shared to public folder"
  task :symlink_uploads do
    run "ln -nfs #{shared_path}/uploads  #{current_path}/public/uploads"
  end

end

before('deploy:restart', 'deploy:recreate_upstart_conf')
before('deploy:restart', 'deploy:symlink_uploads')
after('deploy', 'db:backup')
