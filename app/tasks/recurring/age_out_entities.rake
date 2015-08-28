namespace :recurring do

  desc 'Deletes entities older than a month for non-paying, inactive accounts'
  task :age_out_entities => :environment do
    Rails.logger.info '[WHENEVER] Deleting old-ass entities'

    Brand.without_card.inactive.pluck(:tenant_name).each do |tenant_name|
      Apartment::Tenant.switch(tenant_name) do
        ActiveRecord::Base.connection.execute <<-SQL
          DELETE FROM entities USING service_entities
          WHERE entities.id = service_entities.entity_id
          AND entities.thread_updated_ts < now() :: TIMESTAMP - '1 month' :: INTERVAL;
        SQL
      end
    end

    Rails.logger.info '[WHENEVER] Deleted old-ass entities'
  end
end
