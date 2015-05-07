class AddTimestampsEmbedEntities < ActiveRecord::Migration
  def change
    add_column(:embed_entities, :created_at, :datetime)
    add_column(:embed_entities, :updated_at, :datetime)
  end
end
