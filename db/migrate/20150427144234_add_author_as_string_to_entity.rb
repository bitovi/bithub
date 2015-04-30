class AddAuthorAsStringToEntity < ActiveRecord::Migration
  def change
    add_column :entities, :author, :string
  end
end
