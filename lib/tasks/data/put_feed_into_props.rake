namespace :data do
  task :put_feed_into_props => :environment do
    total_events_cnt = Event.count; cnt = 0; step = 1000;
    puts "Total # of events: #{total_events_cnt}"

    Event.all.each do |e|
      e.props['feed'] = e.feed.name
      e.save

      cnt += 1
      if (progress = (cnt % 1000)) == 0
        puts "#{(cnt/total_events_cnt.to_f*100).round}% events done"
      end
    end
  end
end
