namespace :data do
  desc "Runs moderate method on every hub"
  task :run_moderation_on_all_hubs => :environment do
    puts "--- BEGIN run_moderation_on_all_hubs"
    Brand.pluck(:tenant_name).each do |tn|
      Apartment::Tenant.switch(tn) do
        Hub.all.each do |hub|
          puts "Running moderation on brand: #{brand_name}, hub ID:#{hub.id}"
          hub.moderate
        end
      end
    end
    puts "--- END run_moderation_on_all_hubs"
  end
end
