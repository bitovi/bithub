class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.text :title
      t.text :url
      t.text :body

      t.references :author
      t.references :rule, :null => false
      t.references :feed, :null => false
      t.references :category, :null => false

      t.datetime :origin_ts, :null => false
      t.datetime :thread_updated_ts, :null => false

      t.string :image
      t.string :cached_tag_list
      t.integer :total_upvotes

      t.hstore :props
      t.timestamps
    end
  end
end
