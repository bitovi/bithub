require 'yajl'
require 'nokogiri'
require 'nori'
require 'lib/core_ext'

module Response
  ROOT = 'spec/responses'

  def self.load(feed, type)    
    if %w(blog forums).include? feed
      Nori.new(:parser => :nokogiri).parse(File.read(File.join(ROOT, feed, type.snake_case + '.rss')))
    else
      Yajl::Parser.parse(File.read(File.join(ROOT, feed, type.snake_case + '.json')))
    end
  end

  def self.load_raw(feed, type)    
    @path = File.join(ROOT, feed, type.snake_case + '.json')
    file = File.open(@path, "rb")
    file.read
  end
end
