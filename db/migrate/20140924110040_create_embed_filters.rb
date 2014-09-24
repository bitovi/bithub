class CreateEmbedFilters < ActiveRecord::Migration
  def change
    create_table :embed_filters do |t|
      t.references :embed
      t.references :filter
      t.string :classification
    end
  end
end
