require 'json'
require './app/string.rb'

module Response

  @root = './spec/responses/'

  def self.load(feed, type)    
    @path = File.join(@root, feed, type.snake_case + '.json')
    JSON.parse( IO.read(@path) )    
  end

  def self.load_raw(feed, type)    
    @path = File.join(@root, feed, type.snake_case + '.json')
    file = File.open(@path, "rb")
    file.read
  end
  
end
