class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.integer :brand_id
      t.string  :feed_name
      t.column  :json_config, :json

      t.timestamps
    end
  end
end
