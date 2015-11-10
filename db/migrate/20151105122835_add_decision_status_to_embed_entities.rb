class AddDecisionStatusToEmbedEntities < ActiveRecord::Migration
  def change
    add_column :embed_entities, :decision, :string, :default => 'pending'
  end
end
