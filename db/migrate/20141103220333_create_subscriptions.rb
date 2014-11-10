class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|

      t.references :brand

      t.string :plan_id

      t.string :stripe_event_id
      t.string :stripe_customer_id
      t.string :stripe_subscription_id
      t.string :stripe_subscription_status

      t.string :card_token
      t.string :card_exp_month
      t.string :card_exp_year
      t.string :card_type
      t.string :card_last4, limit: 4

      t.timestamps
    end
  end
end
