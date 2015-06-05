namespace :billing do
  desc "Runs monthly billing"
  task :monthly => :environment do
    puts "--- BEGIN billing:monthly"

    if ENV['charge'] != 'true'
      puts "\n========= Run task with 'charge=true' to create billings and charge =========\n"
    end

    Organization.all.each do |org|
      brand        = org.brands.first
      subscription = org.subscription

      unless subscription.stripe_customer_id
        puts "#{org.name} is missing stripe customer!"
        next
      end

      Apartment::Tenant.switch(brand.tenant_name) do
        # collect embed publish/unpublish/destroy logs
        logs_export = EmbedEvent.export_for_monthly_billing_by_org_id org.id

        mb = MonthlyBillings::Manager.new org.id, logs_export

        mb.usage_per_days.each do |key, dates|
          brand_id, embed_id = key
          last_date          = dates.map {|d| d}.last
          record             = mb.find_by_record brand_id, embed_id,last_date

          puts "\t #{record.embed_name}: #{dates.count} days * #{mb.price} USD = #{dates.count * mb.price}"
        end

        mb.save_to_monthly_billings! if ENV['charge'] == 'true'
      end
    end

    puts "--- END billing:monthly"
  end
end
