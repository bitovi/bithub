class CreateBrandIdentities < ActiveRecord::Migration
  def up
    create_table :brand_identities do |t|
      t.string :provider
      t.string :uid
      t.json :source_data, default: '{}'

      t.references :brand
      t.timestamps
    end

    # add_index :brand_identities, [:provider, :uid], :unique => true
  end

  def down
    drop_table :brand_identities
  end
end
