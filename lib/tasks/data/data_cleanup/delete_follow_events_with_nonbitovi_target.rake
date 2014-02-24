namespace :data do
  task :delete_follow_events_with_nonbitovi_target => :environment do

    ValidTargets = ['canjs', 'javascriptmvc', 'bitovi', 'jquerypp', 'funcunit']
    
    puts "---"
    puts "Deleting follow events with non-bitovi target"

    entity = Entity.feed('twitter').type('follow')
    counter = []
    
    entity.find_each do |e|
      screen_name = e.props.andand['target']

      if screen_name && not(ValidTargets.include?(screen_name))
        e.destroy
        counter.push screen_name
      end
    end

    puts "#{counter.length} events deleted with targets #{counter.to_s}"

  end
end
