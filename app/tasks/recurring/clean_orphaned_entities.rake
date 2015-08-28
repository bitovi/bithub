namespace :recurring do

  desc 'Deletes entities that belong to no service or embed'
  task :clean_orphaned_entities => :environment do
    Rails.logger.info "[WHENEVER] Running recurring:clean_orphaned_entities at #{Time.now}"

    Brand.pluck(:tenant_name).each do |tenant_name|
      Support::OrphanedEntitiesCleaner.new(tenant_name).clean
    end

    Rails.logger.info "[WHENEVER] Done with recurring:clean_orphaned_entities at #{Time.now}"
  end
end
