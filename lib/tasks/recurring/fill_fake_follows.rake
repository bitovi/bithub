namespace :recurring do

  desc "Fill pending columns for FakeFollow entities"
  task :fill_fake_follows => :environment do
    Rails.logger.info "[WHENEVER] Running recurring:fill_fake_follows at #{Time.now}"

    Brand.pluck(:name).each do |name|
      Apartment::Tenant.switch name do
        Sidekiq.redis do |conn|
          fff = Support::FakeFollowFiller.new(conn)
          fff.fill_missing
        end
      end
    end

    Rails.logger.info "[WHENEVER] Done with recurring:fill_fake_follows at #{Time.now}"
  end
end
