namespace :data do
  desc "Create tags"
  task :create_tags => :environment do
    tags = YAML::load_file('config/tags_definition.yml')

    tags.each do |tag, settings|
      existing = Tag.where(:name => tag).first
      if existing
        existing.update_attributes({:display_name => settings['display_name'], :aliases => settings['aliases']})
        puts "EXISTING TAG #{tag}: Setting aliases #{settings['aliases']}"
      else
        puts "NON-EXISTING TAG #{tag}: Creating a new one and setting aliases: #{settings['aliases']}"
        Tag.create({:name => tag, :display_name => settings['display_name'], :aliases => settings['aliases']})
      end
   end
  end
end
