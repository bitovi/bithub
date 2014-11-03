class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|

      t.integer :total
      t.string  :currency, limit: 3

      t.timestamp :period_start
      t.timestamp :period_end

      t.string :plan_id

      t.string :stripe_event_id
      t.string :stripe_invoice_id
      t.string :stripe_customer_id
      t.string :stripe_subscription_id

      t.hstore :props

      t.references :brand

      t.timestamps
    end
  end
end
