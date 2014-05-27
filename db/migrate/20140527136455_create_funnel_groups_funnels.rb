class CreateFunnelGroupsFunnels < ActiveRecord::Migration

  def change
    create_table :funnel_groups_funnels, :id => false do |t|
      t.references :funnel
      t.references :funnel_group
    end

    add_index :funnel_groups_funnels, [:funnel_group_id, :funnel_id]
    add_index :funnel_groups_funnels, :funnel_id
  end

end
