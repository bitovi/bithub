namespace :data do
  desc "Adds 'stealjs' tags to events that where 'props.repo_name' equals 'bitovi/steal' "

  task :fix_stealjs_tags => :environment do
    count = 0
    Event.where("events.props -> 'repo_name' = 'bitovi/steal'").each do |e|
      e.tag_list.add('stealjs') unless e.tag_list.include?('stealjs')
      e.save!
      count += 1
    end

    puts "#{count} events tagged with 'stealjs'"
  end
end
