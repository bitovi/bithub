class AddOriginIdToEntities < ActiveRecord::Migration
  def change
    change_table :entities do |t|
      t.integer :origin_id
    end
  end
end
