class CreateEmbedEntities < ActiveRecord::Migration
  def change
    create_table :embed_entities do |t|
      t.references :embed
      t.references :entity
      t.boolean :is_approved
    end
  end
end
