class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :type_name, :null => true
      t.string :feed_name, :null => true
      t.string :content_digest, :unique => true
      t.hstore :props, default: ''
      t.json   :source_data

      ### one event can produce many 'parent' entities?!
      t.references :entity

      t.timestamps
    end

    add_index(:events, :content_digest)
  end
end
