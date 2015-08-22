module Support
  class OrphanedEntitiesCleaner
    def initialize(tenant_name)
      @tenant_name = tenant_name
    end

    def clean
      Apartment::Tenant.switch(@tenant_name) do
        ActiveRecord::Base.connection.execute <<-SQL
          DELETE FROM entities
          WHERE NOT EXISTS (
              SELECT 1 FROM service_entities
              WHERE entities.id = service_entities.entity_id)
          AND NOT EXISTS (
              SELECT 1 FROM embed_entities
              WHERE entities.id = embed_entities.entity_id);
        SQL
      end
    end
  end
end
