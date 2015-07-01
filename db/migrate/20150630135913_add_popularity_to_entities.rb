class AddPopularityToEntities < ActiveRecord::Migration
  def up
    add_column :entities, :popularity, :integer, default: 0
  end

  def down
    remove_column :entities, :popularity
  end
end
