set(:db_backups_path, '/backups/dbsnapshots/')

namespace :db do

  desc "Determine a name for the backup file"
  task :backup_name, :roles => :db, :only => { :primary => true } do
    backup_time = Time.now.strftime("%Y%m%d-%H%M%S")
    set :backup_file, File.join(db_backups_path, backup_time + '.backup')
  end

  desc "Backup database"
  task :backup, :roles => :db, :only => {:primary => true} do
    backup_name

    run("cat #{current_path}/config/database.yml") { |channel, stream, data| @environment_info = YAML.load(data)[rails_env] }
    dbuser = @environment_info['username']
    dbpass = @environment_info['password']
    environment_database = @environment_info['database']
    dbhost = @environment_info['host']

    run "pg_dump -W -Fc -c -U #{dbuser} #{environment_database} > #{backup_file}" do |ch, stream, out |
      ch.send_data "#{dbpass}\n" if out=~ /^Password:/
    end
  end

  desc "List database backups"
  task :list_backups, :roles => :db, :only => {:primary => true} do
    run("ls -lh #{db_backups_path}*.backup") do |channel, stream, data|

      data.split(/\r?\n/).each do |row|
        attrs = row.split()
        next if attrs.length != 9 

        name = File.basename(attrs[8], ".backup")
        puts "Version: #{name} [#{attrs[4]}] [#{attrs[5]} #{attrs[6]} #{attrs[7]}]"
      end

    end
  end

  desc "Restore database to selected version"
  task :restore, :roles => :db, :only => {:primary => true} do
    if not exists? :version
      puts "Specify which version to restore. Hint: use \"cap db:restore -s version=__version__\""
    else
      dbname = (app_env == 'prod') ? 'bithub' : 'bithub_' + app_env
      backup_path = File.join(db_backups_path, version + '.backup')
      run("pg_restore -c -d #{dbname} #{backup_path}")
    end
  end

  desc "Download backup"
  task :download, :roles => :db, :only => {:primary => true} do
    if not exists? :version
      puts "Specify which version to restore. Hint: use \"cap db:download -s version=__version__\""
    else
      src = File.join(db_backups_path, version + ".backup")      
      dest = ((exists? :path) ? path : './') + version + ".backup"
      top.download(src, dest, :via => :scp, &block)
    end
  end

  desc "Upload backup"
  task :upload, :roles => :db, :only => {:primary => true} do
    if not exists? :backup_file
      puts "Please provide path to backup file. Hint: user \"cap db:upload -s backup_file=__path_to_backup_file__\""
    else
      src = backup_file
      dest = File.join(db_backups_path, File.basename(backup_file))
      top.upload(src, dest, :via => :scp, &block)
    end
  end

  desc "Sync database with production"
  task :sync_with_prod, :roles => :db, :only => {:primary => true} do
    dbname = 'bithub_staging' unless dbname
    run "pg_dump -Fc -w -h 69.164.216.88 bithub | pg_restore -c -d bithub_staging"
  end

end
