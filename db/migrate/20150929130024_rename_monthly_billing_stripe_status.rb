class RenameMonthlyBillingStripeStatus < ActiveRecord::Migration
  def change
    rename_column :monthly_billings, :stripe_status, :stripe_charge_status
  end
end
