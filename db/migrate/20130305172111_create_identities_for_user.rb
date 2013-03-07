class CreateIdentitiesForUser < ActiveRecord::Migration
  def up
    create_table :identities do |t|
      t.string :uid
      t.string :provider
      t.text :source_data
      t.references :user
    end

    add_index :identities, :user_id
  end

  def down
    drop_table :identities
  end
end
