namespace :data do
  desc "Fills props with origin_author_username where applicable"
  task :fill_props_origin_author_username => :environment do
    puts "--- BEGIN fill_props_origin_author_username"
    statuses = Bit.all.map do |bit|
      !!bit.wrapped.procure.normalize.instance.save
    end
    puts "--- END fill_props_origin_author_username, all_done? #{statuses.all?}"
  end
end
