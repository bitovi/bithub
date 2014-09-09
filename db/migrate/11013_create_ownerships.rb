class CreateOwnerships < ActiveRecord::Migration
  def change
    create_table :ownerships do |t|
      t.references :owner
      t.references :entity
      t.integer :value
      t.string :ownership_type

      t.timestamps
    end
  end
end
