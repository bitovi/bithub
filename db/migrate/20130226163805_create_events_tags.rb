class CreateEventsTags < ActiveRecord::Migration
  def change
    create_table :events_tags do |t|
      t.references :event
      t.references :tag
    end
  end
end
