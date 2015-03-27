class RemoveNotNullConstraintFromPlansStripeId < ActiveRecord::Migration
  def change
    change_column :plans, :stripe_id, :string, :null => true
  end
end
