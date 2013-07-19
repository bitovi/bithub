namespace :data do
  desc "Re-does sanitization to bodies of forum events"
  task :reapply_sanitizer_to_forum_bodies => :environment do
    CUSTOM_RULESET = Sanitize::Config::RELAXED
    CUSTOM_RULESET[:elements] << "div"

    total_events_cnt = Event.tagged_with('forums').count
    cnt = 0; step = 10 ** Math.log10(total_events_cnt / 10).round
    puts "Total # of events: #{total_events_cnt}"

    Event.tagged_with('forums').each do |e|
      raw_body = e.source_data["description"] 
      e.update_attribute(:body, Sanitize.clean(raw_body, CUSTOM_RULESET))
    end

    if (progress = (cnt % step)) == 0
      puts "#{(cnt/total_events_cnt.to_f*100).round}% events done"
    end
  end
end
