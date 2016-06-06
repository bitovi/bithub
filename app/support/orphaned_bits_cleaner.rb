module Support
  class OrphanedBitsCleaner
    def initialize(tenant_name)
      @tenant_name = tenant_name
    end

    def clean
      Apartment::Tenant.switch(@tenant_name) do
        ActiveRecord::Base.connection.execute <<-SQL
          DELETE FROM bits
          WHERE NOT EXISTS (
              SELECT 1 FROM service_bits
              WHERE bits.id = service_bits.bit_id)
          AND NOT EXISTS (
              SELECT 1 FROM moderations
              WHERE bits.id = moderations.bit_id);
        SQL
      end
    end
  end
end
