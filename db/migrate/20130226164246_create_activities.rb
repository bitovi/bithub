class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :applies_to, :null => false
      t.references :actor, :null => false
      t.integer :identificator, :null => false
      t.integer :value
      t.boolean :fullfilled, :default => true
      t.string :description

      t.timestamps
    end
  end
end
