class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :applies_to_event
      t.references :actor
      t.string :type
      t.integer :points

      t.timestamps
    end
  end
end
