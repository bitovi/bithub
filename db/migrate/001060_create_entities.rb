class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.text   :title
      t.text   :url
      t.text   :body
      t.string :origin_id
      t.string :feed_name
      t.string :type_name
      t.string :category_name

      t.references :scoring_rule, :null => false
      t.references :feed, :null => false
      t.references :type, :null => false
      t.references :category, :null => false
      t.references :parent

      t.datetime :origin_ts, :null => false
      t.datetime :thread_updated_ts, :null => false

      t.string :image
      t.string :cached_tag_list
      t.integer :total_upvotes

      t.hstore :props, default: ''
      t.timestamps
    end

    create_table :entity_refs do |t|
      t.references :from, :null => false
      t.references :to, :null => false
    end

  end
end
