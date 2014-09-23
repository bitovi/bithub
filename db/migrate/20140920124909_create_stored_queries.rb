class CreateStoredQueries < ActiveRecord::Migration
  def change
    create_table :stored_queries do |t|
      t.string :att
      t.string :op
      t.string :val
      t.boolean :is_negated
    end
  end
end
