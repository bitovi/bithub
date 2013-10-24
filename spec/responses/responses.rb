require 'json'
require 'lib/string'
require 'lib/hash'

module Response
  ROOT = 'spec/responses'

  def self.load(feed, type)    
    @path = File.join(ROOT, feed, type.snake_case + '.json')
    JSON.parse(File.read(@path))
  end

  def self.load_raw(feed, type)    
    @path = File.join(ROOT, feed, type.snake_case + '.json')
    file = File.open(@path, "rb")
    file.read
  end
end
