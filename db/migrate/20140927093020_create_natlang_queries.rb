class CreateNatlangQueries < ActiveRecord::Migration
  def change
    create_table :natlang_queries do |t|
      t.string :attr
      t.string :op
      t.string :val
      t.boolean :is_negated, :default => false
      t.references :filter
    end
  end
end
