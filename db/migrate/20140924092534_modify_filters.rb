class ModifyFilters < ActiveRecord::Migration
  def change
    remove_column :filters , :props        , :hstore  , default: ''
    remove_column :filters , :tags         , :string  , array: true , default: '{}'
    remove_column :filters , :name         , :string  , default: ''
    remove_column :filters , :display_name , :string  , default: ''
    remove_column :filters , :position     , :integer , default: 0
    add_column :filters, :is_conj, :boolean, :default => true
  end
end
