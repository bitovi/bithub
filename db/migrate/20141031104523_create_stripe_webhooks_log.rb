class CreateStripeWebhooksLog < ActiveRecord::Migration
  def change
    create_table :stripe_webhooks_log do |t|
      t.string :event_id
      t.json   :target
      t.json   :event

      t.timestamps
    end
  end
end
