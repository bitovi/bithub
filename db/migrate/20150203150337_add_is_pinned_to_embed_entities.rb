class AddIsPinnedToEmbedEntities < ActiveRecord::Migration
  def change
    add_column :embed_entities, :is_pinned, :boolean, default: false
  end
end
