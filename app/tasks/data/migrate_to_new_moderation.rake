namespace :data do
  desc "Convert old migration to new decision based system"
  task :migrate_to_new_moderation => :environment do
    puts "--- BEGIN run_moderation_on_all_embeds"

    Brand.pluck(:tenant_name).each do |tn|
      puts "Migrating tenant #{tn}"
      Apartment::Tenant.switch(tn) do
        EmbedEntity.where('is_approved_manually = TRUE OR (is_approved_automatically = TRUE AND is_approved_manually IS NULL)').update_all(:decision => 'approved')
        EmbedEntity.where('is_approved_manually = FALSE OR (is_approved_automatically = FALSE AND is_approved_manually IS NULL)').update_all(:decision => 'deleted')
        EmbedEntity.where('is_pinned = TRUE').update_all(:decision => 'starred')
      end
    end
  end

  puts "--- END run_moderation_on_all_embeds"
end


Brand.pluck(:tenant_name).map { |tn| Apartment::Tenant.switch(tn) { ServiceError.count }}

