namespace :data do
  desc "Builds a relation between a service and a brand ident"
  task :assoc_brand_ident_to_service => :environment do

    puts "---"
    puts "Linking existing Services to BrandIdentities"

    Brand.all.each do |b|
      Apartment::Tenant.switch(b.name) do
        service_total = Service.count
        service_done = 0
        Service.all.each do |s|
          s.brand_identity = BrandIdentity.where(brand_id: b.id, provider: s.feed_name).first
          service_done += 1 if s.save
        end

        puts "For brand #{b.name}: services: #{service_total}, services done: #{service_done}"
      end
    end
  end
end
