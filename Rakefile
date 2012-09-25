$: << File.dirname(__FILE__)

namespace :jobs do

  desc "Start the bot"
  task :listen do
    require 'lib/bot'

    begin
      start_bot
    rescue Exception => e
      puts e.inspect
      e.backtrace.each { |line| puts line }
    end

  end
end
