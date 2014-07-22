class CleanupCategories < ActiveRecord::Migration
  def up
    drop_table :category_determination_rules
    remove_column :entities, :category_id
    remove_column :entities, :category_name
  end

  def down
    create_table :category_determination_rules do |t|
      t.string  :name
      t.hstore  :required_tags
      t.hstore  :props
      t.string  :category_name
      t.integer :position

      t.timestamps
    end
    add_column :entities, :category_id, :integer
    add_column :entities, :category_name, :string
  end
end
