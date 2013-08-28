namespace :data do
  desc "Recreates uploaded versions from originals"
  task :recreate_image_versions => :environment do

    Event.all.each do |e|
      e.image.recreate_versions! if e.image.present?
    end
  end
end
