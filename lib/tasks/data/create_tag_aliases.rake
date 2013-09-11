namespace :data do
  desc "Create tag aliases"
  task :create_tag_aliases => :environment do
    tags = YAML::load_file('config/tag_aliases.yml')

    tags.each do |tag, settings|
      existing = Tag.where(:name => tag).first
      if existing
        existing.update_attribute(:aliases, settings['aliases'])
        puts "EXISTING TAG #{tag}: Setting aliases #{settings['aliases']}"
      else
        puts "NON-EXISTING TAG #{tag}: Creating a new one and setting aliases: #{settings['aliases']}"
        Tag.create({:name => tag, :aliases => settings['aliases']})
      end
   end
  end
end
