class CreateNaturalLanguageQueries < ActiveRecord::Migration
  def change
    create_table :natural_language_queries do |t|
      t.string :attr
      t.string :op
      t.string :val
      t.boolean :is_negated
    end
  end
end
