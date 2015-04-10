namespace :data do
  desc "Imports or updates Stripe plans from YAML file"
  task :import_plans => :environment do

    Rails.logger.info "---"
    Rails.logger.info "Importing plan definitions"

    plans = YAML::load_file('config/stripe/plans.yml')

    plans.each do |attrs|

      unless plan = Plan.find_by_name(attrs['name'])
        if Plan.new(attrs).save
          Rails.logger.info "Saving plan '#{attrs['name']}' successful"
        else
          Rails.logger.info "Saving plan '#{attrs['name']}' failed"
        end
      else
        Rails.logger.info "[skipping] Plan '#{attrs['name']}' already exists!"
      end
    end

    Rails.logger.info "----> Don't forget to run `rake stripe:prepare` to update plans on Stripe API"

  end
end
