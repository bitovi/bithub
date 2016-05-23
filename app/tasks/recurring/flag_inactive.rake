namespace :recurring do

  desc 'Flags brands that haven\'t confirmed their users and haven\'t logged in a week as inactive'
  task :flag_inactive => :environment do
    Rails.logger.info "[WHENEVER] Flagging inactive users"

    Brand.flag_inactive

    Rails.logger.info "[WHENEVER] Flagged inactive users."
  end
end
