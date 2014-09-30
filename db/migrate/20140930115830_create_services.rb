class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name
      t.json :source_data, default: '{}'
    end
  end
end
