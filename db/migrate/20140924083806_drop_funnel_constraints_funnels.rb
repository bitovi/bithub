class DropFunnelConstraintsFunnels < ActiveRecord::Migration
  def change
    drop_table :funnel_constraints_funnels
  end
end
