class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :address
      t.string :city
      t.string :postal
      t.string :state
      t.references :country

      t.timestamps
    end

    add_index(:users, :email)
  end
end
