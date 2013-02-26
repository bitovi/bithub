class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.text :body
      t.string :url
      t.string :hash_key
      t.string :feed
      t.string :type
      t.string :state
      t.string :label
      t.references :author
      t.references :rule

      t.timestamps
    end
  end
end
