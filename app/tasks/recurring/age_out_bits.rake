namespace :recurring do

  desc 'Deletes bits older than a month for non-paying, inactive users'
  task :age_out_bits => :environment do
    Rails.logger.info '[WHENEVER] Deleting old-ass bits'

    Brand.without_card.inactive.pluck(:tenant_name).each do |tenant_name|
      Apartment::Tenant.switch(tenant_name) do
        ActiveRecord::Base.connection.execute <<-SQL
          DELETE FROM bits USING service_bits
          WHERE bits.id = service_bits.bit_id
          AND bits.thread_updated_ts < now() :: TIMESTAMP - '1 month' :: INTERVAL;
        SQL
      end
    end

    Rails.logger.info '[WHENEVER] Deleted old-ass bits'
  end
end
