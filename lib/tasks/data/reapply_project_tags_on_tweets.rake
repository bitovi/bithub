namespace :data do
  desc "Reapplies project tags on twitter events by searching text."
  task :reapply_project_tags_on_tweets => :environment do

    @delimiters = /[ ,.!?;\/]/
    @levenshtein_treshold = 1
    @counters = {}
    @events = Event.tagged_with('status_event')

    def tokenize(text)
      text.downcase.split(@delimiters).reject(&:empty?)
    end

    total_events_cnt = @events.count; cnt = 0; step = 100;

    @events.each do |e|
      search_text = e[:title]
      matched_tags = []
      
      # match project tags within tweet
      tokenize(search_text).reduce([]) do |result, word|
        Tag.projects.each do |tag|
          tag.aliases.each do |tag_alias|
            if Levenshtein.distance(word, tag_alias) <= @levenshtein_treshold
              (result << tag.name) if !result.include?(tag.name)
              break
            end
          end
        end
        matched_tags = result 
      end

      # newly matched project tags
      new_projects = matched_tags - e.tag_list
      new_projects.each {|tag| @counters[tag] ? @counters[tag] += 1 : @counters[tag] = 1}        
      
      e.tag_list.add(new_projects)
      e.save!

      # increment counter
      cnt += 1
      puts "#{(cnt/total_events_cnt.to_f*100).round}% events done" if (progress = (cnt % step)) == 0

    end

    # print out statistics
    @counters.each {|k,v| puts "Project '#{k}' newly tagged #{v} times!"}
  end
end
