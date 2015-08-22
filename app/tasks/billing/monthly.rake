namespace :billing do
  namespace :monthly do

    desc "Create monthly billing records"
    task :create => :environment do
      puts "--- BEGIN billing:monthly:create"


      puts "\nList of params that can be passed via ENV vars:"
      puts "   YEAR         Year to be used, defaults to current"
      puts "   MONTH        Month to be used, defaults to previous"
      puts "   SAVE=true  Creates MonthlyBilling"

      _previous = Time.now - 1.month

      _year  = ENV['YEAR'] || _previous.year
      _month = ENV['MONTH'] || _previous.month
      _save  = ENV['SAVE'] == 'true'

      puts "\n=========== Create Monthly billing records for #{_year}-#{_month}, SAVE=#{_save}\n"

      Organization.all.each do |org|
        brand        = org.brands.first
        subscription = org.subscription

        unless subscription.stripe_customer_id
          puts "Org '#{org.name}' is missing stripe customer!"
          next
        else
          puts "Org '#{org.name}'"
        end

        Apartment::Tenant.switch(brand.tenant_name) do
          # collect embed publish/unpublish/destroy logs
          logs_export = EmbedEvent.export_for_monthly_billing_by_org_id org.id, year: _year, month: _month

          mbm = MonthlyBillings::Manager.new org.id, logs_export, year: _year, month: _month

          mbm.usage_per_days.each do |key, dates|
            brand_id, embed_id = key
            record             = mbm.find_record(brand_id, embed_id).last
            price              = mbm.price.to_i / 100.00

            puts "\t #{embed_id} / #{record.embed_name}: #{dates.count} days * #{price} USD = #{dates.count * price}"
          end

          if _save && (mb = mbm.save_to_monthly_billings!)
            puts "\t ----> MonthlyBilling '#{mb.description}' created!"
          else
            puts "\t ----> Creating MonthlyBilling skipped!"
          end
        end
      end

      puts "--- END billing:monthly:create"
    end

    desc "Charge monthly billing records"
    task :charge => :environment do
      puts "--- BEGIN billing:monthly:charge"

      puts "\nList of params that can be passed via ENV vars:"
      puts "   YEAR         Year to be used, defaults to current"
      puts "   MONTH        Month to be used, defaults to previous"

      _previous = Time.now - 1.month

      _year   = ENV['YEAR'] || _previous.year
      _month  = ENV['MONTH'] || _previous.month

      month = Time.new _year, _month

      puts "\n=========== Charging monthly billing records for #{_year}-#{_month}\n"

      MonthlyBilling\
	  .where(period_beginning: month.beginning_of_month, period_end: month.end_of_month)
      .each do |mb|
        puts "Charging #{mb.id} / #{mb.description}"

        if mb.stripe_charge_id
          puts "\t Already charged! ----> Skipping!"
        else
          if charged_mb = mb.stripe_charge!
            puts "\t Charge successful! Stripe charge id: #{charged_mb.stripe_charge_id}"
          else
            puts "\t Charge failed!"
          end
        end

      end

      puts "--- END billing:monthly:charge"
    end

  end
end
