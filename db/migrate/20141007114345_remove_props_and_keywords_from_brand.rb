class RemovePropsAndKeywordsFromBrand < ActiveRecord::Migration
  def change
    remove_column :brands, :props, :hstore, :default => ''
    remove_column :brands, :keywords, :string, :array => true, :default => []
  end
end
