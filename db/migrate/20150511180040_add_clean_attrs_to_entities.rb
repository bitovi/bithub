class AddCleanAttrsToEntities < ActiveRecord::Migration
  def change
    add_column(:entities, :searchable_content, :text)
    add_column(:entities, :searchable_title, :text)
    add_column(:entities, :searchable_body, :text)
    add_column(:entities, :searchable_author, :text)
    remove_column(:entities, :author)
  end
end
