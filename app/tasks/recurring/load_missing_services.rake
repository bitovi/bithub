namespace :recurring do
  desc 'Populate, from the database, redis with the polling and listening services'
  task :load_missing_services => :environment do |variable|
    Rails.logger.info "[WHENEVER] Running recurring:load_missing_services at #{Time.now}"

    polling = Service.all_services("polling").map do |s|
      Guzzler::Client.guzzle(GuzzlerServiceDecorator.new(s))
    end

    Service.all_services("listening").map do |s|
      Guzzler::Client.guzzle(GuzzlerServiceDecorator.new(s))
    end

    Rails.logger.info "[WHENEVER] Done with recurring:load_missing_services at #{Time.now}"
  end
end
