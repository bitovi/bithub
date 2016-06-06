class RefactorTableColumnNames < ActiveRecord::Migration
  	def up
  		rename_table :entities, :bits
		
		rename_column :embed_entities, :embed_id, :hub_id
  	  	rename_column :embed_entities, :entity_id, :bit_id
  	  	rename_table :embed_entities, :moderations
		
		rename_column :service_entities, :entity_id, :bit_id 
  	  	rename_table :service_entities, :service_bits
		
		rename_table :embeds, :hubs
		
		rename_column :embed_presets, :embed_id, :hub_id
  	  	rename_table :embed_presets, :hub_presets
		
		rename_column :embed_events, :embed_id, :hub_id
  	  	rename_column :embed_events, :embed_name, :hub_name
  	  	rename_table :embed_events, :hub_events
		
		rename_column :account_organizations, :account_id, :user_id
		rename_column :accounts_account_roles, :account_id, :user_id
		rename_column :accounts_account_roles, :account_role_id, :user_role_id
		rename_table :accounts, :users
		rename_table :account_organizations, :user_organizations
		rename_table :account_roles, :user_roles
		rename_table :accounts_account_roles, :users_user_roles
		
		rename_column :events, :embed_id, :hub_id
		rename_column :events, :entity_id, :bit_id
		
		rename_column :services, :embed_id, :hub_id
		
		rename_column :filters, :embed_id, :hub_id
		
		rename_table :hub_presets, :hub_embeds
		
		rename_column :services, :brand_identity_id, :credential_id
		rename_table :brand_identities, :credentials
	end
  	
	def down
		rename_column :services, :credential_id, :brand_identity_id
		rename_table :credentials, :brand_identities
		
		rename_table :hub_embeds, :hub_presets
		
		rename_column :filters, :hub_id, :embed_id
		
		rename_column :services, :hub_id, :embed_id
		
		rename_column :events, :bit_id, :entity_id
		rename_column :events, :hub_id, :embed_id
		
		rename_column :user_organizations, :user_id, :account_id
		rename_column :users_user_roles, :user_id, :account_id
		rename_column :users_user_roles, :user_role_id, :account_role_id
		rename_table :users, :accounts
		rename_table :user_organizations, :account_organizations
		rename_table :user_roles, :account_roles
		rename_table :users_user_roles, :accounts_account_roles 
		
		rename_column :hub_events, :hub_id, :embed_id
		rename_column :hub_events, :hub_name, :embed_name
		rename_table :hub_events, :embed_events
		
		rename_column :hub_presets, :hub_id, :embed_id
		rename_table :hub_presets, :embed_presets
		
		rename_table :hubs, :embeds
		
		rename_column :service_bits, :bit_id, :entity_id
		rename_table :service_bits, :service_entities
		
		rename_column :moderations, :hub_id, :embed_id
		rename_column :moderations, :bit_id, :entity_id
		rename_table :moderations, :embed_entities
		
		rename_table :bits, :entities
	end
end
