namespace :data do
  desc "Fills searchable_* fields with cleaned-up content"
  task :fill_searchable_fields => :environment do
    puts "--- BEGIN fill_searchable_fields"

    sql_command = File.read('lib/tasks/data/clean_title_and_body.sql')

    puts "Executing command:"
    puts "------------------"
    puts sql_command
    puts "------------------"

    Brand.all.map do |b|
      puts "Executing for tenant: #{b.name}"
      Apartment::Tenant.switch(b.name) do
        ActiveRecord::Base.connection.execute(sql_command)
      end
    end

    puts "--- END fill_searchable_fields"
  end
end
