require 'bundler/setup'
require 'cinch'
require 'httparty'
require 'yajl'

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
    
    HTTParty.post('http://localhost:4567/events', {:body => {events: Yajl::Encoder.encode(events)}})
  end
end

bot.start 
