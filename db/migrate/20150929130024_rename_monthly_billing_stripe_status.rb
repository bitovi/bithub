class RenameMonthlyBillingStripeStatus < ActiveRecord::Migration
  def change
    if Apartment::Tenant.current == 'public'
      rename_column :monthly_billings, :stripe_status, :stripe_charge_status
    end
  end
end
