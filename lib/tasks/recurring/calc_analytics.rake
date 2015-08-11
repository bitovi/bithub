namespace :recurring do

  desc "Calculate analytics every tenant"
  task :calc_analytics => :environment do
    Rails.logger.info "[WHENEVER] Running recurring:calc_analytics at #{Time.now}"

    Brand.pluck(:name).each do |name|
      Apartment::Tenant.switch name do
        Histogram.fill_stats
      end
    end

    Rails.logger.info "[WHENEVER] Done with recurring:calc_analytics at #{Time.now}"
  end
end
