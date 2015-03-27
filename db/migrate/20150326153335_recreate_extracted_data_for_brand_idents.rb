class RecreateExtractedDataForBrandIdents < ActiveRecord::Migration
  def change
    remove_column :brand_identities, :extracted_data
    add_column :brand_identities, :extracted_data, :json, default: '{}'
  end
end
