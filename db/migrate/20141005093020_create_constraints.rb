class CreateConstraints < ActiveRecord::Migration
  def change
    add_foreign_key :users, :countries

    # Ownerships
    add_foreign_key :ownerships, :users,    :column => 'owner_id', dependent: :delete
    add_foreign_key :ownerships, :entities, :column => 'entity_id', dependent: :delete

    # Accounts
    add_foreign_key :accounts_brands, :brands, dependent: :delete
    add_foreign_key :accounts_brands, :accounts, dependent: :delete

    # Brands -> Embeds, Embeds -> Services
    add_foreign_key :embeds,   :brands, dependent: :delete
    add_foreign_key :services, :embeds, dependent: :delete

    # Brand identities
    add_foreign_key :brand_identities, :brands, dependent: :delete

    # Brands
    add_foreign_key :brands_users, :users,  dependent: :delete
    add_foreign_key :brands_users, :brands, dependent: :delete
  end
end
