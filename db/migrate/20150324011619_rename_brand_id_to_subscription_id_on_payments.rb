class RenameBrandIdToSubscriptionIdOnPayments < ActiveRecord::Migration
  def change
    rename_column :payments, :brand_id, :subscription_id \
      if column_exists? 'public.payments', 'brand_id'
  end
end
