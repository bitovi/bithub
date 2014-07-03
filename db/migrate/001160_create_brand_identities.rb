class CreateBrandIdentities < ActiveRecord::Migration
  def up
    create_table :brand_identities do |t|
      t.string :provider
      t.string :uid
      t.json :source_data, default: ''

      t.references :brand
      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE brand_identities
        ADD CONSTRAINT brand_identities_unique_uid_provider_combination
        UNIQUE (provider, uid);
      SQL
  end

  def down
    drop_table :brand_identities
  end
end
