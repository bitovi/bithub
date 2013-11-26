namespace :data do
  desc "Create/update tags"
  task :import_or_update_tags => :environment do
    tags = YAML::load_file('config/tag_definitions.yml')

    tags.each do |tag_name, opts|
      existing = Tag.find_by_name(tag_name)

      if existing
        puts "[UPDATED] Tag | name: #{tag_name}, display_name: #{opts['display_name']}, aliases: #{opts['aliases']}"
        existing.update_attributes({:display_name => opts['display_name'], :aliases => opts['aliases']})
      else
        puts "[CREATED] Tag | name: #{tag_name}: display_name: #{opts['display_name']}, aliases: #{opts['aliases']}"
        Tag.create({:name => tag_name, :display_name => opts['display_name'], :aliases => opts['aliases']})
      end

    end
  end
end
