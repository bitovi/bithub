namespace :data do
  desc "Reapplies categories for issue/bug/feature events"
  task :reapply_categories_for_issues => :environment do
    categories = {
      'bug' => {
        'count' => 0,
        'labels' => ['bug'],
      },
      'feature' => {
        'count' => 0,
        'labels' => ['feature','enhancement']
      },
      'issue' => {
        'count' => 0,
        'labels' => []
      }
    }

    # iter github issues events
    Event.tagged_with('issues_event').each do |e|
      labels = e['source_data']['payload']['issue']['labels'].collect {|l| l['name'].downcase}
      bestMatch = {
        'score' => 0,
        'category' => 'issue'
      }

      # match best category
      categories.each do |k, v|
        match = v['labels'] & labels
        if (match.length >= bestMatch['score'])
          bestMatch = {
            'score' => match.length,
            'category' => k
          }
        end
      end

      # set category
      #e.category = bestMatch['category']

      # update count
      categories[bestMatch['category']]['count'] += 1
      e.category = Tag.find_by_name(bestMatch['category'])
      e.tag_list.add(bestMatch['category']) unless e.tag_list.include? bestMatch['category']
      e.save!
    end

    categories.each {|k,v| puts "category #{k} matched #{v['count']} times"}

  end
end
