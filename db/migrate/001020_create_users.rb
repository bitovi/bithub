class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :name
      t.string  :email
      t.string  :address
      t.string  :address2
      t.string  :city
      t.string  :postal
      t.string  :state
      t.hstore  :props
      t.integer :total_score, :default => 0

      t.references :country

      t.timestamps
    end

    add_index(:users, :email)

    create_table(:roles) do |t|
      t.string :name
      t.references :resource, :polymorphic => true

      t.timestamps
    end

    create_table(:users_roles, :id => false) do |t|
      t.references :user
      t.references :role
    end

    add_index(:roles, :name)
    add_index(:roles, [ :name, :resource_type, :resource_id ])
    add_index(:users_roles, [ :user_id, :role_id ])

  end

end
