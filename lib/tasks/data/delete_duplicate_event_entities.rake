namespace :data do
  desc "Deletes corrupted event_entities"
  task :delete_duplicate_event_entities => :environment do
    puts "--- BEGIN delete_duplicate_event_entities"

    Brand.all.pluck(:name) do |b_name|
      Apartment::Tenant.switch(b_name) do
        command = <<-SQL
          DELETE FROM embed_entities WHERE id IN 
           (SELECT id FROM
             (SELECT id, row_number() OVER (partition BY entity_id, embed_id ORDER BY id) AS rnum
               FROM embed_entities
             ) t
            WHERE t.rnum > 1);"
        SQL
        ActiveRecord::Base.execute(command)
      end
    end

    puts "--- END delete_duplicate_event_entities"
  end
end
