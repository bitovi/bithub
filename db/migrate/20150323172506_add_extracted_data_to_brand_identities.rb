class AddExtractedDataToBrandIdentities < ActiveRecord::Migration
  def change
    change_table :brand_identities do |t|
      t.json :extracted_data
    end
  end
end
