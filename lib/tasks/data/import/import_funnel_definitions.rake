namespace :data do
  desc "Imports funnel determinations from YAML file"
  task :import_funnel_definitions => :environment do

    Rails.logger.info "---"
    Rails.logger.info "Importing funnel definitions"

    if tenant = ENV['TENANT']
      Apartment::Tenant.switch! tenant
      Rails.logger.info "Tenant switched to '#{Apartment::Tenant.current}'"
    end

    definitions = YAML::load_file('config/funnel_definitions.yml')

    Funnel.destroy_all
    FunnelConstraint.destroy_all

    definitions.each do |d|
      funnel = Funnel.new name: d['name'], display_name: d['display_name'], tags: d['tags']

      funnel.constraints = d['constraints'].map do |c|
        FunnelConstraint.new feed_name: c['feed_name'], type_name: c['type_name']
      end

      if funnel.save
        Rails.logger.info "Importing funnel '#{d['name']}' successful"
      else
        Rails.logger.info "Importing funnel '#{d['name']}' failed"
      end
    end

    Apartment::Tenant.switch!
  end
end
