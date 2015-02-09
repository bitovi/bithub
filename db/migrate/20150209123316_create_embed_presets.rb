class CreateEmbedPresets < ActiveRecord::Migration
  def change
    create_table :embed_presets do |t|
      t.references :embed
      t.string :name
      t.json :config
      t.timestamps
    end
  end
end
