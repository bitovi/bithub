class ModifyFilters < ActiveRecord::Migration
  def change
    remove_column :filters, :tags, :string, array: true, default: '{}'
    add_column :filters, :is_conjunctive, :boolean, :default => false
  end
end
