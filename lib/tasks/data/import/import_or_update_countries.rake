namespace :data do
  desc "Create/update countries"
  task :import_or_update_countries => :environment do
    Rails.logger.info "--- BEGIN data:import_or_update_countries"

    countries = YAML::load_file('config/countries.yml')
    updated = []; imported = []; failed = []
    
    countries.each do |code, data|
      if country = Country.where({:iso => code}).first
        country.update_attributes({:name => data['name']}) ? updated.push(data['name']) : failed.push(data['name'])
      else
        Country.new({:iso => code, :name => data['name']}).save ? imported.push(data['name']) : failed.push(data['name'])
      end      
    end

    Rails.logger.info "Summary:"
    Rails.logger.info "  #{imported.length} countries imported"
    Rails.logger.info "  #{updated.length} countries updated"
    Rails.logger.info "  #{failed.length} countries failed: #{failed.to_s}"

    Rails.logger.info "--- END data:import_or_update_countries"
  end
end
