class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.references :category
      t.integer :points
      t.integer :award
      t.string_array :required_tags
      t.integer :priority

      t.timestamps
    end
  end
end
