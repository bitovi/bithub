class CreateConstraints < ActiveRecord::Migration
  def change
    add_foreign_key :users, :countries
    add_foreign_key :entities, :scoring_rules
    add_foreign_key :ownerships, :users, column: 'owner_id', dependent: :delete
    add_foreign_key :ownerships, :entities, column: 'entity_id', dependent: :delete
    add_foreign_key :upvotes,   :entities, column: 'applies_to_id', dependent: :delete
    add_foreign_key :upvotes,   :users,    column: 'actor_id', dependent: :delete
    add_foreign_key :awards,    :entities, column: 'applies_to_id', dependent: :delete
    add_foreign_key :awards,    :users,    column: 'actor_id', dependent: :delete
    add_foreign_key :internals, :users,    column: 'actor_id', dependent: :delete
    add_foreign_key :internals, :users,    column: 'receiver_id', dependent: :delete
    add_foreign_key :achievements, :users,   dependent: :delete
    add_foreign_key :achievements, :rewards, dependent: :delete
    add_foreign_key :accounts, :brands
    add_foreign_key :embeds, :brands, dependent: :delete
    add_foreign_key :services, :embeds, dependent: :delete
    add_foreign_key :brand_identities, :brands, dependent: :delete
    add_foreign_key :brands_users, :users,  dependent: :delete
    add_foreign_key :brands_users, :brands, dependent: :delete
  end
end
