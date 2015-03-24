class AddAvailabilityToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :available, :boolean, default: false \
      unless column_exists? 'public.plans', 'available'
  end
end
