class DropJunkJsonAttrs < ActiveRecord::Migration
  def up
    remove_column :events, :source_json
  end

  def down
    add_column :events, :source_json, :json
  end
end
