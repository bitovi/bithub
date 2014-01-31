class CreateOwnerships < ActiveRecord::Migration
  def change
    create_table :ownerships do |t|
      t.references :owner
      t.references :entity
      t.references :scoring_rule
      t.integer :value
      t.string :type

      t.timestamps
    end

    change_table :entities do |t|
      t.remove :author_id
    end
    
    change_table :scoring_rules do |t|
      t.rename :authorship_value, :ownership_value
    end
  end
end
