namespace :data do
  desc "Sets thread_updated at for all events (to latest in thread)"
  task :fill_thread_ts => :environment do
    total_events_cnt = Event.count; cnt = 0; step = 1000;
    puts "Total # of events: #{total_events_cnt}"

    Event.all.each do |e|
      max_tua_ts = ([e.origin_ts] + e.children.pluck(:origin_ts)).max
      e.update_attribute(:thread_updated_at, max_tua_ts);
      e.children.each do |c|
        c.update_attribute(:thread_updated_at, max_tua_ts)
        cnt += 1
      end
      cnt += 1;

      if (progress = (cnt % 1000)) == 0
        puts "#{(cnt/total_events_cnt.to_f*100).round}% events done"
      end
    end
  end
end
