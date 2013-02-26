class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.text :body
      t.string :url
      t.string :hash_key

      t.timestamps
    end
  end
end
