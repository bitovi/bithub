class UpdateModeration < ActiveRecord::Migration
  def change
    remove_column :filters, :is_conj
    remove_column :filters, :classification

    add_column    :filters, :action, :string, null: false
  end
end
