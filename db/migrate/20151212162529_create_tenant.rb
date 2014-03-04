class CreateTenant < ActiveRecord::Migration
  def change
    create_table :tenants do |t|
      t.string :login
      t.string :name
      t.string :email
      t.string :address
      t.string :city
      t.string :postal
      t.string :state
      t.references :country
      t.hstore :props

      t.timestamps
    end

    add_index(:tenants, :email)
  end
end
