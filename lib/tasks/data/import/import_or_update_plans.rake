namespace :data do
  desc "Imports or updates Stripe plans from YAML file"
  task :import_or_update_plans => :environment do

    Rails.logger.info "---"
    Rails.logger.info "Importing plan definitions"

    plans = YAML::load_file('config/stripe/plans.yml')

    plans.each do |attrs|

      if plan = Plan.find_by_stripe_id(attrs['stripe_id'])
        if plan.update_attributes(attrs)
          Rails.logger.info "Updating plan '#{attrs['stripe_id']}' successful"
        else
          Rails.logger.info "Updating plan '#{attrs['stripe_id']}' failed"
        end
      else
        if Plan.new(attrs).save
          Rails.logger.info "Saving plan '#{attrs['stripe_id']}' successful"
        else
          Rails.logger.info "Saving plan '#{attrs['stripe_id']}' failed"
        end
      end
    end

    Rails.logger.info "----> Don't forget to run `rake stripe:prepare` to update plans on Stripe API"

  end
end
