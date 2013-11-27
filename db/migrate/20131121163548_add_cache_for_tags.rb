class AddCacheForTags < ActiveRecord::Migration
  def change
    add_column :events, :cached_tag_list, :string
  end
end
