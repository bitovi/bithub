namespace :data do
  task :cleanup_issue_duplicates => :environment do

    deleted = []
    
    Event.tagged_with('issues_event').each do |e|
      content_digest = e.props['content_digest']
      if match = Event.where("id <> #{e.id} and props->'content_digest'='#{content_digest}'").first

        # delete events from issues stream, identified by title attr in source_data
        if match.source_data['title']
          duplicate = match
          keep = e
        else
          duplicate = e
          keep = match          
        end

        duplicate.children.each {|c| c.parent = keep; c.save!}
        deleted.push(duplicate.id)
        duplicate.destroy
      end
    end

    #for_deletion.each {|id| Event.destroy(id)}
    puts "Events with following ids were deleted: (count: #{deleted.count})"
    puts "#{deleted}"
    
  end
end
