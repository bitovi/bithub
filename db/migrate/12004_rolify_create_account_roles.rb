class RolifyCreateAccountRoles < ActiveRecord::Migration
  def change
    create_table(:account_roles) do |t|
      t.string :name
      t.references :resource, :polymorphic => true

      t.timestamps
    end

    create_table(:accounts_account_roles, :id => false) do |t|
      t.references :account
      t.references :account_role
    end

    add_index(:account_roles, :name)
    add_index(:account_roles, [ :name, :resource_type, :resource_id ])
    add_index(:accounts_account_roles, [ :account_id, :account_role_id ])
  end
end
