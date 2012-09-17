namespace :jobs do

  desc "Start the listener (bot)"
  task :listen do

    require 'bundler/setup'
    require 'cinch'
    require 'httparty'
    require 'yajl'

    begin
      bot = Cinch::Bot.new do
        configure do |c|
          c.nick = "feeder-bot"
          c.server = "irc.freenode.org"
          c.channels = ["#canjs", "#bitovi"]
          # c.channels = ['#cinch-bots']
        end

        on :message, /^(.+)$/ do |m, txt|
          event_hash = {
            username: m.user,
            timestamp: m.time,
            raw_data: txt,
            title: txt,
            feed: 'irc'
          }

          # Needs to be in an array to be the in same form as crawler data
          events = []
          events << event_hash

          HTTParty.post('http://storer.herokuapp.com/events', {:body => {events: Yajl::Encoder.encode(events)}})
        end
      end

      bot.start 

    rescue Exception => e
      puts e.inspect
      e.backtrace.each { |line| puts line }
    end
  end
end
