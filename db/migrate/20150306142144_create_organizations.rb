class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.timestamps
    end

    # remapping
    create_join_table :accounts, :organizations
    drop_table :accounts_brands
    rename_column :subscriptions, :brand_id, :organization_id
    remove_column :subscriptions, :plan_id
    add_column :subscriptions, :plan_id, :integer
    add_column :brands, :organization_id, :integer
  end
end
