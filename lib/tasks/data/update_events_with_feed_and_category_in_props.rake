namespace :data do
  task :feed_and_category_into_props => :environment do

    total_events_cnt = Event.count

    cnt = 0
    puts "---"
    puts "Inserting :category into props"
    Tag.categories.each do |t|
      cnt += Event.tagged_with(t.name).count
      Event.tagged_with(t.name).update_all("props = props || ('category => #{t.name}')")
      puts "Done for '#{t.name}' => #{(cnt/total_events_cnt.to_f*100).round}% events done"
    end
    
    cnt = 0
    puts "---"
    puts "Inserting :feed into props"
    Tag.feeds.each do |t|
      cnt += Event.tagged_with(t.name).count
      Event.tagged_with(t.name).update_all("props = props || ('feed => #{t.name}')")
      puts "Done for '#{t.name}' => #{(cnt/total_events_cnt.to_f*100).round}% events done"
    end
  end
end
