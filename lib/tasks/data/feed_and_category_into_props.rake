namespace :data do
  task :feed_and_category_into_props => :environment do
    total_events_cnt = Event.count
    puts "Total number of events: #{total_events_cnt}"

    cnt = 0
    puts "Updating for CATEGORIES"
    puts "-----------------------"
    Tag.categories.each do |t|
      cnt += Event.tagged_with(t.name).count
      Event.tagged_with(t.name).update_all("props = props || ('category => #{t.name}')")
      puts "CATEGORIES: Updating for #{t.name}: #{(cnt/total_events_cnt.to_f*100).round}% events done"
    end
    
    cnt = 0
    puts "Updating for FEEDS"
    puts "------------------"
    Tag.feeds.each do |t|
      cnt += Event.tagged_with(t.name).count
      Event.tagged_with(t.name).update_all("props = props || ('feed => #{t.name}')")
      puts "FEEDS: Updating for #{t.name}: #{(cnt/total_events_cnt.to_f*100).round}% events done"
    end
  end
end
