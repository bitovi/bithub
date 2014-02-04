namespace :data do
  task :clean_forum_duplicates => :environment do

    deleted = []
    Event.where(feed_id: 19).each do |e|
      content_digest = e.props['content_digest']

      if match = Event.where("id <> ? and coalesce(parent_id, 0) = ? and title = ?", e.id, 0, e.title).first
      
        # delete events from issues stream, identified by title attr in source_data
        if match.children.length == 0
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
