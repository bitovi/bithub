
def read_db_config(stage=fetch(:stage))
  db_config_raw = capture :cat, File.join(fetch(:deploy_to), 'current/config/database.yml')
  YAML.load(db_config_raw)[stage.to_s]
end

def gen_backup_version
  Time.now.strftime("%Y%m%d-%H%M%S")
end

def exit_upon_active_db_sessions
  num = active_db_sessions_num
  (error "There #{num > 1 ? 'are' : 'is'} #{num} active sessions on database! " and exit) if num > 0

end

def active_db_sessions_num
  dbname = read_db_config['database']
  capture(:psql, 'postgres', '-At', "-c \"SELECT sum(numbackends) FROM pg_stat_database where datname='#{dbname}';\"").to_i
end
