namespace :data do
  desc "Removes \"open an issues\" from Github issues"
  task :remove_prefix_from_issue_titles => :environment do
    total_events_cnt = Event.tagged_with('issues_event').count
    cnt = 0; step = 10 ** Math.log10(total_events_cnt / 10).round
    puts "Total # of events: #{total_events_cnt}"

    Event.tagged_with('issues_event').each do |e|
      e.update_attribute(:title, e.title.gsub("open an issue: ", ""));
      e.update_attribute(:title, e.title.gsub("closed an issue: ", ""));
      cnt += 1

      if (progress = (cnt % step)) == 0
        puts "#{(cnt/total_events_cnt.to_f*100).round}% events done"
      end
    end
  end
end
