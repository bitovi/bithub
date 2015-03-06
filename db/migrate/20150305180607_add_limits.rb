class AddLimits < ActiveRecord::Migration
  def change
    add_column :plans, :grace_period, :integer, null: false, default: 15
    add_column :plans, :limits,       :json,    null: false, default: '{}'
    add_column :plans, :features,     :json,    null: false, default: '{}'
  end
end
