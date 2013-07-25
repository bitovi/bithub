namespace :data do
  desc "Imports countries data from YAML file"
  task :import_countries_data => :environment do
    countries = YAML::load_file('config/countries.yml')
    successes = 0
    failures = 0

    previous = Country.delete_all
    puts "#{previous} records deleted from countries table!"

    countries.each do |code, data|
      if Country.new({:iso => code, :name => data['name']}).save()
        successes += 1
      else
        failures += 1
      end
    end

    puts "#{successes} countries imported, #{failures} failures!"
  end
end
