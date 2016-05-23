namespace :data do
  desc "Deletes bits that belong to no service or hub"
  task :delete_orphaned_bits => :environment do
    puts "--- BEGIN delete_orphaned_bits"

    # create hash where key is [org_id, acc_id] and value is list of record ids
    # then delete duplicates
    Brand.all.each do |b|
      Apartment::Tenant.switch(b.tenant_name) do
        sql_command = <<-SQL
            delete from bits where bits.id not in (select moderations.bit_id);
            delete from bits where bits.id not in (select service_bits.bit_id);
        SQL
        ActiveRecord::Base.connection.execute(sql_command)
      end
    end

    puts "--- END delete_orphaned_bits"
  end
end
