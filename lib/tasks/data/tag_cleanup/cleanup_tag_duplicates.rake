namespace :data do
  desc "Cleans possible tag duplicates"
  task :cleanup_tag_duplicates => :environment do

    def alias_exists?(tags, name)

      tags.each do |tag|
        return tag if tag[:name] != name and tag[:aliases] and tag[:aliases].include?(name)
      end

      return nil
    end

    # here we will store tag duplicates
    duplicates = []

    # fetch tags
    tags = Tag.all()

    # find duplicates and rewire
    tags.each do |tag|
      original = alias_exists?(tags, tag[:name])

      if original
        # update category FK on events
        num_categories = Event.update_all({:category_id => original[:id]}, {:category_id => tag[:id]})

        # update feed FK on events
        num_feeds = Event.update_all({:feed_id => original[:id]}, {:feed_id => tag[:id]})

        # update all records on Tagging model in ActsAsTaggbleOn
        num_tags = ActsAsTaggableOn::Tagging.update_all({:tag_id => original[:id]}, {:tag_id => tag[:id]})

        puts "#{tag[:name]}(#{tag[:id]}) is duplicate of #{original[:name]}(#{original[:id]}); Number of updated categories: #{num_categories}, feeds: #{num_feeds}, tags: #{num_tags}"

        # finally remeber duplicated tag
        duplicates.push tag
      end
    end

    # delete duplicated tags from DB
    duplicates.each do |tag|
      if tag.destroy()
        puts "#{tag[:name]} deleted"
      else
        puts "#{tag[:name]} deletion failed"
      end
    end

  end
end
