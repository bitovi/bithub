class AddFkToServiceErrors < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute <<-SQL
      DELETE FROM service_errors WHERE NOT EXISTS (SELECT 1 FROM services WHERE services.id = service_errors.service_id);
      ALTER TABLE service_errors DROP CONSTRAINT IF EXISTS fk_service_errors_to_services;
      ALTER TABLE service_errors ADD CONSTRAINT fk_service_errors_to_services FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE CASCADE;
    SQL
  end

  def drop
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TABLE service_errors DROP CONSTRAINT IF EXISTS fk_service_errors_to_services;
    SQL
  end
end
