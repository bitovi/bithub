class CreateCategoryDeterminationRules < ActiveRecord::Migration
  def change
    create_table :category_determination_rules do |t|
      t.string :name, :null => false, :unique => true
      t.hstore :scorings
    end
  end
end
