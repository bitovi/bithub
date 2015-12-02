namespace :data do
  desc "Runs moderate method on every embed"
  task :run_moderation_on_all_embeds => :environment do
    puts "--- BEGIN run_moderation_on_all_embeds"
    Brand.pluck(:tenant_name).each do |tn|
      Apartment::Tenant.switch(tn) do
        Embed.all.each do |embed|
          puts "Running moderation on brand: #{brand_name}, embed ID:#{embed.id}"
          embed.moderate
        end
      end
    end
    puts "--- END run_moderation_on_all_embeds"
  end
end
