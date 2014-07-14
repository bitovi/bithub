class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.hstore :props, default: ''

      t.references :brand

      t.timestamps
    end
  end
end
