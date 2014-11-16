class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string  :stripe_id,         null: false
      t.string  :name,              null: false
      t.text    :description
      t.integer :amount,            null: false
      t.string  :currency,          null: false, default: 'usd'
      t.string  :interval,          null: false, default: 'month'
      t.integer :interval_count,    null: false, default: 1
      t.integer :trail_period_days, null: false, default: 30
    end
  end
end
