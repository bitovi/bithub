class DropFunnelConstraintsFunnels < ActiveRecord::Migration
  def change
    execute "drop materialized view pagination;"
    drop_table :funnel_constraints_funnels
  end
end
