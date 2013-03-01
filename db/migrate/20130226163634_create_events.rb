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
      t.date :date, :null => false

      t.hstore :props
      t.text :raw_json, :null => false

      t.timestamps
    end

    add_index(:events, :hash_key)
  end
end
