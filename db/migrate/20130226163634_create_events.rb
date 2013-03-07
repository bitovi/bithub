class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :hash_key, :null => false
      t.string :title
      t.string :url
      t.text :body
      t.references :author
      t.references :rule, :null => false
      t.references :parent
      t.references :feed, :null => false
      t.references :category, :null => false
      t.datetime :origin_ts, :null => false
      t.date :origin_date, :null => false

      t.hstore :props
      t.text :source_data, :null => false

      t.timestamps
    end

    add_index(:events, :hash_key)
    add_index(:events, :origin_date)
  end
end
