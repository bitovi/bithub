namespace :data do
  desc "Cleans junk tags that ended up in the system"
  task :cleanup_junk_tags=> :environment do

    puts "---"
    puts "Cleaning up junk tags (undefined in tag_definitions.yml)"
    
    tags = YAML::load_file('config/tag_definitions.yml')
    matched = []
    unmatched = []
    deleted =  []

    uncategorized = Tag.find_by_name('uncategorized')

    if not uncategorized
      puts "Couldn't find tag 'uncategorized'! exiting ..."
      exit 1
    end
    
    Tag.all.each do |db_tag|
      msg = nil
      
      matched_tags = tags.select do |tag_name, opts|
        (db_tag.name == tag_name) || (opts && opts['aliases'] && opts['aliases'].include?(db_tag.name))
      end

      if matched_tags.empty?
        msg = "'#{db_tag.name}' NOT matched! --> "
        unmatched.push(db_tag.name)          

        # unlink references
        ActsAsTaggableOn::Tagging.delete_all(:tag_id => db_tag.id)
        Event.update_all({:category_id => uncategorized.id}, {:category_id => db_tag.id})

        # delete tag
        if !db_tag.destroy
          msg += " DELETING failed!"
        else
          msg " DELETED!"
          deleted.push(db_tag.name)
        end
        
      else
        matched.push(db_tag.name)
        
      end      
    end

    puts "Summary:"
    puts "  #{matched.length} tags matched"    
    puts "  #{unmatched.length} tags NOT matched"
    puts "  #{deleted.length} tags DELETED"
    
  end
end
