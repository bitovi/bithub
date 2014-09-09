class CreateFeedConfig < ActiveRecord::Migration
  def change
    create_table :feed_configs do |t|
      t.integer :brand_id
      t.string  :feed_name
      t.column  :config, :json

      t.timestamps
    end
  end
end
