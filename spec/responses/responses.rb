require 'json'
require './app/string.rb'

module Response

  @root = './spec/responses/'

  def self.load(feed, type)
    
    @path = File.join(@root, feed, type.snake_case + '.json')
    JSON.parse( IO.read(@path) )
    
  end
  
end
