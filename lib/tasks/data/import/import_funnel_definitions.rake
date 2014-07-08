namespace :data do
  desc "Imports funnel determinations from YAML file"
  task :import_funnel_definitions => :environment do

    puts "---"
    puts "Importing funnel definitions"

    if tenant = ENV['TENANT']
      Apartment::Database.switch tenant
      puts "Tenant switched to '#{Apartment::Database.current_tenant}'"
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
        puts "Importing funnel '#{d['name']}' successful"
      else
        puts "Importing funnel '#{d['name']}' failed"
      end
    end

  end
end
