class AddFeedTypeCategoryToEntities < ActiveRecord::Migration
  def change

    change_table :entities do |t|
      t.column :feed_name, :string
      t.column :type_name, :string
      t.column :category_name, :string
      t.column :type_id, :integer
    end

    execute "ALTER TABLE entities ADD CONSTRAINT fk_entities_type_tags FOREIGN KEY (type_id) REFERENCES tags(id);"
  end
end
