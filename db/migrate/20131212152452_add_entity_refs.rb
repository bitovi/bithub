class AddEntityRefs < ActiveRecord::Migration
  def change
    create_table :entity_refs do |t|
      t.references :from, :null => false
      t.references :id, :null => false
    end
  end
end
