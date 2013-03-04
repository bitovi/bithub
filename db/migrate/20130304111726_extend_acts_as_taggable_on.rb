class ExtendActsAsTaggableOn < ActiveRecord::Migration
  def change
    add_column :tags, :display_name, :string
    add_column :tags, :aliases, :string_array
  end
end
