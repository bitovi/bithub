namespace :data do
  desc "Imports/updates tags from YAML file"
  task :import_or_update_tags => :environment do

    puts "---"
    puts "Importing/updating tags"
    
    tags = YAML::load_file('config/tag_definitions.yml')
    updated = []
    imported = []
    failed = []

    tags.each do |tag_name, opts|
      attrs = {
        display_name: opts['display_name'],
        aliases: opts['aliases'],
        props: opts['props']
      }

      if existing = Tag.find_by_name(tag_name)
        existing.assign_attributes(attrs)
        existing.group_list = opts['group_list']
        existing.save ? updated.push(tag_name) : failed.push(tag_name)
      else
        t = Tag.new({:name => tag_name}.merge(attrs))
        t.group_list = opts['group_list']
        t.save ? imported.push(tag_name) : failed.push(tag_name)
      end
    end
    
    puts "Summary:"
    puts "  #{imported.length} tags imported"
    puts "  #{updated.length} tags updated"
    puts "  #{failed.length} tags failed: #{failed.to_s}"

  end
end
