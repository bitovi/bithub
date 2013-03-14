class CreateActivities < ActiveRecord::Migration
  def change
    create_table :upvotes do |t|
      t.references :applies_to, :null => false
      t.references :actor, :null => false
      t.integer :value

      t.timestamps
    end

    create_table :anteups do |t|
      t.references :applies_to, :null => false
      t.references :actor, :null => false
      t.integer :value
      t.boolean :fullfilled, :default => false

      t.timestamps
    end

    create_table :awards do |t|
      t.references :applies_to, :null => false
      t.references :actor, :null => false
      t.integer :value

      t.timestamps
    end

    create_table :internal do |t|
      t.references :actor, :null => false
      t.references :receiver, :null => false
      t.references :applies_to
      t.integer :value

      t.timestamps
    end

  end
end
