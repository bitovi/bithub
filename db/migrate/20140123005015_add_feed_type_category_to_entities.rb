class AddFeedTypeCategoryToEntities < ActiveRecord::Migration
  def change
    execute "ALTER TABLE entities DROP CONSTRAINT fk_entities_feed_tags;"
    execute "ALTER TABLE entities DROP CONSTRAINT fk_entities_category_tags;"

    change_table :entities do |t|
      t.column :feed_name, :string
      t.column :type_name, :string
      t.column :category_name, :string
      t.column :type_id, :integer
    end

    execute "ALTER TABLE entities ADD CONSTRAINT fk_entities_feed_tags FOREIGN KEY (feed_id) REFERENCES tags(id);"
    execute "ALTER TABLE entities ADD CONSTRAINT fk_entities_type_tags FOREIGN KEY (type_id) REFERENCES tags(id);"
    execute "ALTER TABLE entities ADD CONSTRAINT fk_entities_category_tags FOREIGN KEY (category_id) REFERENCES tags(id);"
  end
end
