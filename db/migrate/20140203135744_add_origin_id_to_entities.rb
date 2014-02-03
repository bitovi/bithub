class AddOriginIdToEntities < ActiveRecord::Migration
  def change
    change_table :entities do |t|
      t.string :origin_id
    end
  end
end
