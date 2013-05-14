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
  'PATH' => "/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH"
})

set(:stages, ['staging', 'prod'])
set(:default_stage, 'prod')

set(:shared_children, shared_children + %w{public/uploads})

namespace :deploy do
  desc "Zero-downtime restart of Unicorn"
  task :restart, :except => { :no_release => true } do
    run "kill -s USR2 `cat #{shared_path}/pids/unicorn.pid`"
    run "sudo /usr/bin/service bithub-listener restart"
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

  task(:recreate_upstart_conf) do
    run "#{current_path}/bin/foreman export --app bithub-listener --user #{user} --env #{current_path}/.env_#{app_env} --procfile #{current_path}/Procfile.#{app_env} upstart /etc/init"
  end

  task :symlink_uploads do
    run "ln -nfs #{shared_path}/uploads  #{current_path}/public/uploads"
  end
end

namespace :db do

  desc "Determine a name for the dump file"
  task :backup_name, :roles => :db, :only => { :primary => true } do
    backup_time = Time.now.strftime("%Y%m%d-%H%M%S")
    set :backup_file, "/backups/#{app_env}-dbsnapshots/#{backup_time}.sql"
  end

  desc "Backup PostgreSQL database to /backups/prod-snapshots/"
  task :dump, :roles => :db, :only => {:primary => true} do
    backup_name

    run("cat #{current_path}/config/database.yml") { |channel, stream, data| @environment_info = YAML.load(data)[rails_env] }
    dbuser = @environment_info['username']
    dbpass = @environment_info['password']
    environment_database = @environment_info['database']
    dbhost = @environment_info['host']

    run("cat #{current_path}/config/database.yml") { |channel, stream, data| @environment_info = YAML.load(data)[rails_env] }
    run "pg_dump -W -c -U #{dbuser} #{environment_database} | bzip2 -c > #{backup_file}.bz2" do |ch, stream, out |
      ch.send_data "#{dbpass}\n" if out=~ /^Password:/
    end
  end


  desc "Sync your production database to your local workstation"
  task :download_dump, :roles => :db, :only => {:primary => true} do
    backup_name
    dump
    get "#{backup_file}.bz2", "/tmp/#{application}.sql.bz2"
    development_info = YAML.load_file("config/database.yml")['development']
    run_str = "PGPASSWORD=#{development_info['password']} bzcat /tmp/#{application}.sql.bz2 | psql -U #{development_info['username']} -h #{development_info['host']} #{development_info['database']}"
    %x!#{run_str}!
  end

  task :upload_dump, :roles => :db, :only => {:primary => true} do
  end

end

before('deploy:restart', 'deploy:recreate_upstart_conf')
before('deploy:restart', 'deploy:symlink_uploads')
after('deploy', 'db:dump')
