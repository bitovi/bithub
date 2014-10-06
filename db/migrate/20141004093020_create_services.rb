class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.references :embed
      t.string  :feed_name
      t.column  :json_config, :json
      t.timestamps
    end
  end
end
