namespace :recurring do

  desc "Calculate analytics every tenant"
  task :mark_inactive => :environment do
    Rails.logger.info "[WHENEVER] Finding inactive accounts"

    Brand.without_card.map do |b|
      last_sign_in_at = b.organization.accounts.maximum(:last_sign_in_at) || 10.years.ago
      b.update_attribute(:is_active, last_sign_in_at >= 2.weeks.ago) 
    end



    Rails.logger.info "[WHENEVER] Found inactive accounts."
  end
end
