namespace :recurring do

  desc "Process events that were never processed"
  task :process_unprocessed_events => :environment do
    Rails.logger.info "[WHENEVER] Finding inactive accounts"
    # TODO
    Rails.logger.info "[WHENEVER] Found inactive accounts."
  end
end
