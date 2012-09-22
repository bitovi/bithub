$: << File.dirname(__FILE__)

namespace :jobs do

  desc "Start the crawler"
  task :crawl do

    require 'lib/crawler'

    begin
      start_crawler
    rescue Exception => e
      puts e.inspect
      e.backtrace.each { |line| puts line }
    end
  end
end
