class CreateEventsRaw < ActiveRecord::Migration
  def change
    create_table :events_raw do |t|
      t.references :event
      t.hstore :data
    end
  end
end
