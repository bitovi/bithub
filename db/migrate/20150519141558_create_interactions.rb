class CreateInteractions < ActiveRecord::Migration
  def change
    create_table :interactions, id: false  do |t|
      t.string :event_type
      t.integer :source_id
      t.string :source_type
      t.datetime :created_at
    end
  end
end
