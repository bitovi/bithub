class AddLimits < ActiveRecord::Migration
  def change
    add_column :plans, :grace_period, :integer, null: false, default: 15 \
      unless column_exists? 'public.plans', 'grace_period'
    add_column :plans, :limits,       :json,    null: false, default: '{}' \
      unless column_exists? 'public.plans', 'limits'
    add_column :plans, :features,     :json,    null: false, default: '{}' \
      unless column_exists? 'public.plans', 'features'
  end
end
