namespace :data do
  desc "Seed db with brand/feed config for development"
  task :dev_crawler_config => :environment do

    puts "---"
    puts "Importing brand/feed config for crawler"

    brands = YAML::load_file(File.join(Rails.root, 'config/services/crawler/development.yml')).fetch(:brands)
    cnt = 0

    FeedConfig.delete_all
    brands.each do |brand_name, feeds|
      feeds.each do |feed_name, cfg|
        cnt += 1
        FeedConfig.create(brand_name: brand_name, feed_name: feed_name, config: cfg)
      end
    end

    puts "#{cnt} exist, #{FeedConfig.count} imported"
  end
end
