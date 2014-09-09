class CreateIdentities < ActiveRecord::Migration
  def up
    create_table :identities do |t|
      t.string :provider
      t.json :source_data, default: '{}'
      t.references :user
    end

    add_column :identities, :uid, :bigint

    add_index :identities, :user_id
    add_index :identities, [:provider, :uid], :unique => true
  end

  def down
    drop_table :identities
  end
end
