class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :email
      t.string :password
      t.string :name
      t.hstore :props

      t.references :brand

      t.timestamps
    end
  end
end
