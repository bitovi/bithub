def new_decision(ee)
  if ee.is_approved_manually == true
    'approved'
  elsif ee.is_approved_manually == false
    'deleted'
  elsif ee.is_pinned == true
    'starred'
  else
    'pending'
  end
end

namespace :data do
  desc "Convert old migration to new decision based system"
  task :migrate_to_new_moderation => :environment do
    puts "--- BEGIN run_moderation_on_all_embeds"

    Brand.pluck(:tenant_name).each do |tn|
      Apartment::Tenant.switch(tn) do
        EmbedEntity.where find_each do |ee|

          ee.update_attribute(:decision, new_decision(ee))
        end
      end
    end

    puts "--- END run_moderation_on_all_embeds"
  end
end
