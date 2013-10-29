require 'json'
require 'lib/core_ext'

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
