namespace :data do
  desc "Create tag aliases"
  task :create_tag_aliases => :environment do
    tags = YAML::load_file('config/tag_aliases.yml')

    tags.each do |tag, aliases|
      existing = Tag.where(:name => tag).first
      if existing
        existing.update_attribute(:aliases, aliases)
        puts "EXISTENT TAG #{tag}: Setting aliases #{aliases}"
      else
        puts "NON-EXISTENT TAG #{tag}: Creating a new one and setting aliases: #{aliases}"
        Tag.create({:name => tag, :aliases => aliases})
      end
   end
  end
end
