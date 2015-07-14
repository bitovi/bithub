class DeleteForeignKeys < ActiveRecord::Migration
  def change

    schema = Apartment::Tenant.current

    if table_exists?("#{schema}.accounts_brands")
      drop_table :accounts_brands
    end

    if table_exists?("#{schema}.brand_identities")
      remove_foreign_key :brand_identities, column: :brand_id
    end

    if table_exists?("#{schema}.brands_users")
      remove_foreign_key :brands_users, column: :user_id
      remove_foreign_key :brands_users, column: :brand_id
    end


    if table_exists?("#{schema}.embeds")
      remove_foreign_key :embeds, column: :brand_id
    end

    if table_exists?("#{schema}.ownerships")
      remove_foreign_key :ownerships, column: :entity_id
      remove_foreign_key :ownerships, column: :owner_id
    end

    if table_exists?("#{schema}.services")
      remove_foreign_key :services, column: :embed_id
    end

    if table_exists?("#{schema}.users")
      remove_foreign_key :users, column: :country_id
    end

  end
end
