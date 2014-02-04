require 'digest/md5'
require 'andand'

require 'lib/core_ext'
require 'lib/core_helpers'
require 'lib/loggable'

require 'events/dispatcher'

# Require all feed and type files
Dir[File.join('app', 'domain', 'events', 'feeds', '**', '*.rb')].each do |f|
  require f
end

module Events
  class Processor
    include Loggable
    class Configuration
      attr_accessor :term, :feed
    end

    def initialize(response, &blk)
      initialize_logger("INFO")

      @config = Configuration.new
      blk.(@config) if blk

      @feed = @config.feed
      @response = response
    end
    
    def parse
      @parsed ||= subprocessor.parse
      self
    end

    def extract
      @extracted ||= subprocessor.extract
      self
    end

    def decorate
      @decorated ||= result.map do |event_hash|
        e = Events::Dispatcher.dispatch(event_hash, @feed)
        e.to_json.deep_merge(subprocessor.decorate)
      end
      self
    end

    def result
      @decorated || @extracted || @parsed
    end

    private
    
    def subprocessor
      @subprocessor ||= Events.feed(@feed)::Processor.new(@response) do |config|
        config.term = @config.term
      end
    end
  end

end
