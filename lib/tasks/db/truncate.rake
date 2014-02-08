namespace :db do
  desc "Truncate all existing data"
  task :truncate => "db:load_config" do
    views = %w(entity_aggregated_tag_list entity_total_upvotes user_total_score)
    critical_tables = %w(tags scoring_rules category_determination_rules)
    begin
      config = ActiveRecord::Base.configurations[::Rails.env]
      ActiveRecord::Base.establish_connection
      case config["adapter"]
      when "mysql", "postgresql"
        (ActiveRecord::Base.connection.tables - views).each do |table|
          ActiveRecord::Base.connection.execute("TRUNCATE #{table} CASCADE")
        end
      when "sqlite", "sqlite3"
        ActiveRecord::Base.connection.tables.each do |table|
          ActiveRecord::Base.connection.execute("DELETE FROM #{table}")
          ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence where name='#{table}'")
        end                                                                                                                               
        ActiveRecord::Base.connection.execute("VACUUM")
      end
    end
    Rake::Task["data:import"].execute
  end
end
