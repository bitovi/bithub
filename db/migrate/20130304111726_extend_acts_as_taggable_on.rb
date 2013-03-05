class ExtendActsAsTaggableOn < ActiveRecord::Migration
  def change
    add_column :tags, :display_name, :string
    add_column :tags, :aliases, :string_array
    add_column :tags, :is_category, :boolean, :default => false
    add_column :tags, :is_feed, :boolean, :default => false
    add_column :tags, :priority, :integer
  end
end
