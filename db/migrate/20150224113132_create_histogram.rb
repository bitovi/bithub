class CreateHistogram < ActiveRecord::Migration
  def change
    create_table :histogram, id: false do |t|
      t.string :source_type
      t.integer :source_id
      t.integer :volume
      t.integer :delta
      t.datetime :measured_at
    end
  end
end
