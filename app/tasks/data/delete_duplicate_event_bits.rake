namespace :data do
  desc "Deletes corrupted event_bits"
  task :delete_duplicate_event_bits => :environment do
    puts "--- BEGIN delete_duplicate_event_bits"

    Brand.all.pluck(:name) do |b_name|
      Apartment::Tenant.switch(b_name) do
        command = <<-SQL
          DELETE FROM moderations WHERE id IN 
           (SELECT id FROM
             (SELECT id, row_number() OVER (partition BY bit_id, hub_id ORDER BY id) AS rnum
               FROM moderations
             ) t
            WHERE t.rnum > 1);"
        SQL
        ActiveRecord::Base.execute(command)
      end
    end

    puts "--- END delete_duplicate_event_bits"
  end
end
