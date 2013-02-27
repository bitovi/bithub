class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :applies_to
      t.references :actor
      t.string :type
      t.integer :awarded_value
      t.integer :staked_value
      t.boolean :stake_fullfilled

      t.timestamps
    end
  end
end
