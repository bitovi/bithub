namespace :data do
  desc "Pulls s3 images for articles, apps and plugins to uploads/"
  task :pull_s3_images => :environment do
    require 'net/http'

    Event.tagged_with(["article", "app", "plugin"], :any => true)
         .where("props ? 'image'")
         .all.each do |e|

      filename = File.basename(e.props['image'])
      url = "/bithub" + e.props['image'].gsub(/(?<ext>\.\w+)$/,'_800\k<ext>')
      download_to = File.join(Rails.root, "public", "uploads", "event", "image", e.id.to_s, filename)

      puts "Downloading resource #{url}"

      Net::HTTP.start("s3.amazonaws.com") do |http|
        resp = http.get(url)
        FileUtils.mkdir_p(File.dirname(download_to))
        File.open(download_to, "wb") do |file|
          file.write(resp.body)
        end
      end
      
      e.image = File.open(download_to)
      e.save!

      puts "Written to #{download_to}"
    end

  end
end
