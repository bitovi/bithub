namespace :recurring do

  desc 'Flags brands that haven\'t confirmed their accounts and haven\'t logged in a week as inactive'
  task :flag_inactive => :environment do
    Rails.logger.info "[WHENEVER] Flagging inactive accounts"

    Brand.flag_inactive

    Rails.logger.info "[WHENEVER] Flagged inactive accounts."
  end
end
