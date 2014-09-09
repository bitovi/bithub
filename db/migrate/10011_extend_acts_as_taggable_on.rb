class ExtendActsAsTaggableOn < ActiveRecord::Migration
  def change
    add_column :tags, :display_name, :string
    add_column :tags, :aliases, :string, array: true, default: []
    add_column :tags, :props, :hstore, default: ''
  end
end
