class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.string :url
      t.string :hash_key
      t.text :body
      t.references :author
      t.references :rule
      t.references :category

      t.timestamps
    end
  end
end
