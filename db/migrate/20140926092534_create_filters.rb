class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.references :embed
      t.boolean :is_conj
      t.string :classification
    end
  end
end
