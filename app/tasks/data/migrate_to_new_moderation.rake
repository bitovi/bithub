namespace :data do
  desc "Convert old migration to new decision based system"
  task :migrate_to_new_moderation => :environment do
    puts "--- BEGIN run_moderation_on_all_hubs"

    Brand.pluck(:tenant_name).each do |tn|
      puts "Migrating tenant #{tn}"
      Apartment::Tenant.switch(tn) do
        Moderation.where('is_approved_manually = TRUE OR (is_approved_automatically = TRUE AND is_approved_manually IS NULL)').update_all(:decision => 'approved')
        Moderation.where('is_approved_manually = FALSE OR (is_approved_automatically = FALSE AND is_approved_manually IS NULL)').update_all(:decision => 'deleted')
        Moderation.where('is_pinned = TRUE').update_all(:decision => 'starred')
      end
    end

    puts "--- END run_moderation_on_all_hubs"
  end

end
