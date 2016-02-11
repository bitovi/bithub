namespace :recurring do

  desc 'Clean services from Redis that have been deleted by the user'
  task :clean_orphaned_services => :environment do
    Rails.logger.info "[WHENEVER] Running recurring:clean_orphaned_services at #{Time.now}"

    if Service.num_of_services('polling') < Guzzler.zcard('services:polling')
      services_in_redis = Guzzler.zrange('services:polling')
      services_in_postgres = Service.all_services('polling').map do |s|
        Apartment::Tenant.switch(s.tenant_name) do
          GuzzlerServiceDecorator.new(s).member
        end
      end

      (services_in_redis - services_in_postgres).each do |s_key|
        Guzzler.zrem('services:polling', s_key)
      end
    end

    if Service.num_of_services('listening') < Guzzler.scard('services:listening')
      services_in_redis = Guzzler.smembers('services:listening')
      services_in_postgres = Service.all_services('listening').map do |s|
        Apartment::Tenant.switch(s.tenant_name) do
          GuzzlerServiceDecorator.new(s).member
        end
      end

      (services_in_redis - services_in_postgres).each do |s_key|
        Guzzler.srem('services:listening', s_key)
      end
    end

    Rails.logger.info "[WHENEVER] Done with recurring:clean_orphaned_services at #{Time.now}"
  end
end
