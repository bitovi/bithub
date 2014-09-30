class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.references :embed
      t.boolean :is_conj
      t.string :classification
      t.integer :filterable_id
      t.string  :filterable_type
    end
  end
end
