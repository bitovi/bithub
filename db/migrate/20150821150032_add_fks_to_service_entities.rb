class AddFksToServiceEntities < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute <<-SQL
      DELETE FROM service_entities
      WHERE NOT EXISTS (SELECT 1 FROM entities WHERE entities.id = service_entities.entity_id);

      DELETE FROM service_entities
      WHERE NOT EXISTS (SELECT 1 FROM services WHERE services.id = service_entities.service_id);

      ALTER TABLE service_entities DROP CONSTRAINT IF EXISTS fk_service_entities_to_entities;
      ALTER TABLE service_entities DROP CONSTRAINT IF EXISTS fk_service_entities_to_services;

      ALTER TABLE service_entities
      ADD CONSTRAINT fk_service_entities_to_entities
      FOREIGN KEY (entity_id) REFERENCES entities (id)
      ON DELETE CASCADE;

      ALTER TABLE service_entities
      ADD CONSTRAINT fk_service_entities_to_services
      FOREIGN KEY (service_id) REFERENCES services (id)
      ON DELETE CASCADE;
    SQL
  end

  def down
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TABLE service_entities DROP CONSTRAINT IF EXISTS fk_service_entities_to_entities;
      ALTER TABLE service_entities DROP CONSTRAINT IF EXISTS fk_service_entities_to_services;
    SQL
  end
end
