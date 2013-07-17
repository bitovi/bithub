namespace :data do
  desc "Sets thread_updated at for all events (to latest in thread)"
  task :calculate_latest_thread_activity => :environment do
    total_events_cnt = Event.count; cnt = 0; step = 1000;
    puts "Total # of events: #{total_events_cnt}"

    Event.all.each do |e|
      e.bump_thread
      cnt += 1

      if (progress = (cnt % 1000)) == 0
        puts "#{(cnt/total_events_cnt.to_f*100).round}% events done"
      end
    end
  end
end
