class CreateCategoryDeterminationRules < ActiveRecord::Migration
  def change
    create_table :category_determination_rules do |t|
      t.string :name
      t.hstore :required_tags
      t.hstore :props
      t.string :category_name

      t.timestamps
    end
  end
end
