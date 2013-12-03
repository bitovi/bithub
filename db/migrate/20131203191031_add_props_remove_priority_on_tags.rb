class AddPropsRemovePriorityOnTags < ActiveRecord::Migration
  def change
    add_column :tags, :props, :hstore
    remove_column :tags, :priority
  end
end
