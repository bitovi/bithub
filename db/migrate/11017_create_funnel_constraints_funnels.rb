class CreateFunnelConstraintsFunnels < ActiveRecord::Migration
  def change
    create_table :funnel_constraints_funnels, :id => false do |t|
      t.references :funnel
      t.references :funnel_constraint
    end
  end
end
