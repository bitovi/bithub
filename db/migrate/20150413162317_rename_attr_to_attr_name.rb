class RenameAttrToAttrName < ActiveRecord::Migration
  def change
    rename_column :natlang_queries, :attr, :attr_name
  end
end
