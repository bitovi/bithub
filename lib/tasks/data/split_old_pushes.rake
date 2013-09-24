namespace :data do
  desc "Re-saves users (triggers pre/after hooks)"
  task :split_old_pushes => :environment do
    total_events_cnt = Event.count; cnt = 0; step = 100;

    Event.tagged_with('push_event').each do |e|
      e.split_push_event_to_commits

      cnt += 1
      if (progress = (cnt % step)) == 0
        puts "#{(cnt/total_events_cnt.to_f*100).round}% events done"
      end
    end
  end
end
