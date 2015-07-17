namespace :data do
  desc "Deletes entities that belong to no service or embed"
  task :delete_orphaned_entities => :environment do
    puts "--- BEGIN delete_orphaned_entities"

    # create hash where key is [org_id, acc_id] and value is list of record ids
    # then delete duplicates
    Brand.all.each do |b|
      Apartment::Tenant.switch(b.tenant_name) do
        sql_command = <<-SQL
            delete from entities where entities.id not in (select embed_entities.entity_id);
            delete from entities where entities.id not in (select service_entities.entity_id);
        SQL
        ActiveRecord::Base.connection.execute(sql_command)
      end
    end

    puts "--- END delete_orphaned_entities"
  end
end
