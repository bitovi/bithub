class CreateInteractions < ActiveRecord::Migration
  def change
    create_table :interactions, id: false  do |t|
      t.string :event_type
      t.string :event_subtype
      t.references :primary_source, polymorphic: true
      t.references :secondary_source, polymorphic: true
      t.datetime :created_at
    end
  end
end
