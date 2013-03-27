class CreateIdentitiesForUser < ActiveRecord::Migration
  def up
    create_table :identities do |t|
      t.string :provider
      t.text :source_data
      t.references :user
    end

    add_column :identities, :uid, :bigint
    add_index :identities, :user_id
    
    execute <<-SQL
      CONSTRAINT unique_uid_provider_combination
        UNIQUE (provider, uid);
    SQL
  end

  def down
    drop_table :identities
  end
end
