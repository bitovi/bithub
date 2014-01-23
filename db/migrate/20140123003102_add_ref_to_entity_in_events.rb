class AddRefToEntityInEvents < ActiveRecord::Migration
  def up
    add_column :events, :entity_id, :integer
  end

  def down
    remove_column :events, :entity_id
  end
end
