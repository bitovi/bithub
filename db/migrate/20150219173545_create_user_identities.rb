class CreateUserIdentities < ActiveRecord::Migration
  def change
    create_table :user_identities do |t|
      t.references :user
      t.string :provider
      t.json :source_data, default: '{}'
    end

    add_column :user_identities, :uid, :bigint
    add_foreign_key :user_identities, :users, dependent: :delete
  end
end
