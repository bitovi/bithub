namespace :data do
  desc "Create/update countries"
  task :import_or_update_countries => :environment do

    puts "---"
    puts "Importing/updating countries"

    countries = YAML::load_file('config/countries.yml')
    updated = []
    imported = []
    failed = []
    
    countries.each do |code, data|
      if country = Country.where({:iso => code}).first
        country.update_attributes({:name => data['name']}) ? updated.push(data['name']) : failed.push(data['name'])
      else
        Country.new({:iso => code, :name => data['name']}).save ? imported.push(data['name']) : failed.push(data['name'])
      end      
    end

    puts "Summary:"
    puts "  #{imported.length} countries imported"
    puts "  #{updated.length} countries updated"
    puts "  #{failed.length} countries failed: #{failed.to_s}"

  end
end
