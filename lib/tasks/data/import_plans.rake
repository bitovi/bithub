namespace :data do
  desc "Imports or updates Stripe plans from YAML file"
  task :import_plans => :environment do

    Rails.logger.info "---"
    Rails.logger.info "Importing plan definitions"

    plans = YAML::load_file('config/stripe/plans.yml')

    plans.each do |attrs|

      unless plan = Plan.find_by_stripe_id(attrs['stripe_id'])
        if Plan.new(attrs).save
          Rails.logger.info "Saving plan '#{attrs['stripe_id']}' successful"
        else
          Rails.logger.info "Saving plan '#{attrs['stripe_id']}' failed"
        end
      else
        Rails.logger.info "[skipping] Plan '#{attrs['stripe_id']}' already exists!"
      end
    end

    Rails.logger.info "----> Don't forget to run `rake stripe:prepare` to update plans on Stripe API"

  end
end
