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
      if existing = Tag.find_by_name(tag_name)

        if existing
          existing.display_name = opts['display_name']
          existing.aliases = opts['aliases']
          existing.group_list = opts['group_list']

          if existing.save
            updated.push(tag_name)
          else
            failed.push(tag_name)
          end
        end
        
      else
        t = Tag.new
        t.name = tag_name
        t.display_name = opts['display_name']
        t.aliases = opts['aliases']
        t.group_list = opts['group_list']

        if t.save
          imported.push(tag_name)
        else
          failed.push(tag_name)
        end
        
      end
    end
    
    puts "Summary:"
    puts "  #{imported.length} tags imported"
    puts "  #{updated.length} tags updated"
    puts "  #{failed.length} tags failed: #{failed.to_s}"

  end
end
