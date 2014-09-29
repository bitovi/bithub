class DropFunnelConstraints < ActiveRecord::Migration
  def change
    drop_table :funnel_constraints
  end
end
