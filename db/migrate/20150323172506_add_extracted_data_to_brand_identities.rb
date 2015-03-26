class AddExtractedDataToBrandIdentities < ActiveRecord::Migration
  def change
    change_table :brand_identities do |t|
      t.json :extracted_data \
      unless column_exists? 'public.brand_identities', 'extracted_data'
    end
  end
end
