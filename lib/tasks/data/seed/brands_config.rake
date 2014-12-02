namespace :seed do
  desc "Seed db with test brand"
  task :brands_config => :environment do

    puts "---"
    puts "Importing test account with brand/embeds/services"

    file = File.read(File.join(Rails.root, 'config/seed_brands_embeds_services.json'))
    brands = JSON.parse(file, { symbolize_names: true })[:brands]

    brands.each do |bc|

      # try to use existing brand
      if brand = Brand.find_by_name(bc[:name])
        puts "Using already existing brand '#{brand.name}'." if brand.save!
      else
        brand = Brand.new name: bc[:name], tenant_name: bc[:name]
        puts "Created new brand '#{brand.name}'." if brand.save!
      end

      Apartment::Database.switch brand.name

      bc[:embeds].each do |ec|
        next if brand.embeds.find_by_name ec[:name]

        embed = Embed.new brand: brand, name: ec[:name]
        puts "\t --> Created new embed '#{embed.name}'." if embed.save!

        ec[:services].each do |sc|
          service =  Service.new(embed: embed,
                                 feed_name: sc[:feed_name],
                                 type_name: sc[:type_name],
                                 json_config: sc[:json_config])

          puts "\t\t --> Created new service ('#{service.feed_name}' '#{service.type_name}')." if service.save!
        end
      end

      Apartment::Database.switch
    end

  end
end
