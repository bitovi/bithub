class CreateConstraints < ActiveRecord::Migration
  def change

    # Users
    add_foreign_key :users, :countries

    # Entities
    add_foreign_key :entities, :tags, :column => 'feed_id', :name => 'entities_feed_tags_fk'
    add_foreign_key :entities, :tags, :column => 'type_id', :name => 'entities_type_tags_fk'
    add_foreign_key :entities, :scoring_rules

    # Ownerships
    add_foreign_key :ownerships, :users, :column => 'owner_id', :dependent => :delete
    add_foreign_key :ownerships, :entities, :column => 'entity_id', :dependent => :delete

    # Activities
    add_foreign_key :upvotes,   :entities, :column => 'applies_to_id', :dependent => :delete
    add_foreign_key :upvotes,   :users,    :column => 'actor_id', :dependent => :delete
    add_foreign_key :awards,    :entities, :column => 'applies_to_id', :dependent => :delete
    add_foreign_key :awards,    :users,    :column => 'actor_id', :dependent => :delete
    add_foreign_key :internals, :users,    :column => 'actor_id', :dependent => :delete
    add_foreign_key :internals, :users,    :column => 'receiver_id', :dependent => :delete

    # Achievements
    add_foreign_key :achievements, :users,   :dependent => :delete
    add_foreign_key :achievements, :rewards, :dependent => :delete

    # Accounts
    add_foreign_key :accounts, :brands

    # Feed configs 
    add_foreign_key :feed_configs, :brands, :dependent => :delete

    # Brand identities
    add_foreign_key :brand_identities, :brands, :dependent => :delete

    # Funnels
    add_foreign_key :funnel_constraints_funnels, :funnels, :dependent => :delete
    add_foreign_key :funnel_constraints_funnels, :funnel_constraints

    # Brands
    add_foreign_key :brands_users, :users,  :dependent => :delete
    add_foreign_key :brands_users, :brands, :dependent => :delete

  end
end
