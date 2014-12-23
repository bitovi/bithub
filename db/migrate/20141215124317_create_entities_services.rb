class CreateEntitiesServices < ActiveRecord::Migration

  def up
    create_table :entities_services, id: false do |t|
      t.references :service
      t.references :entity
    end

    execute <<-SQL
    CREATE INDEX index_entities_services_on_entity_id_and_service_id
    ON entities_services
    USING btree
    (entity_id, service_id);
SQL

    execute <<-SQL
    CREATE INDEX index_entities_services_on_service_id
    ON entities_services
    USING btree
    (service_id);
SQL

  end

  def down
    drop_table :entities_services
  end

end
