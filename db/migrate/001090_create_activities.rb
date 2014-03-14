class CreateActivities < ActiveRecord::Migration
  def change
    create_table :upvotes do |t|
      t.references :applies_to, :null => false
      t.references :actor, :null => false
      t.integer :value

      t.timestamps

    end

    add_index(:upvotes, :applies_to_id)

    create_table :awards do |t|
      t.references :applies_to, :null => false
      t.references :actor, :null => false
      t.integer :value

      t.timestamps
    end

    create_table :internals do |t|
      t.references :actor, :null => true
      t.references :receiver, :null => false
      t.references :applies_to
      t.string :variant
      t.string :comment
      t.integer :value
      t.timestamps
    end

  end
end
