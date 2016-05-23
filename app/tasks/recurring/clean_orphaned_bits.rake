namespace :recurring do

  desc 'Deletes bits that belong to no service or hub'
  task :clean_orphaned_bits => :environment do
    Rails.logger.info "[WHENEVER] Running recurring:clean_orphaned_bits at #{Time.now}"

    Brand.pluck(:tenant_name).each do |tenant_name|
      Support::OrphanedEntitiesCleaner.new(tenant_name).clean
    end

    Rails.logger.info "[WHENEVER] Done with recurring:clean_orphaned_bits at #{Time.now}"
  end
end
