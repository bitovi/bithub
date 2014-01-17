require 'digest/md5'
require 'andand'

require 'lib/core_ext'
require 'lib/loggable'
require 'lib/configurable'

require 'events/payload'
require 'events/mappings'
require 'events/modules/errors'

# Require all feed and type files
Dir[File.join('app', 'domain', 'events', 'feeds', '**', '*.rb')].each do |f|
  require f
end

module Events

  class Processor
    include Loggable
    include Configurable

    def initialize(response, &blk)
      initialize_logger("INFO")
      initialize_config(&blk)

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
        e = construct_event(event_hash)
        Hash.new({
          content_digest: e.content_digest,
          source_data: e.source_data,
          meta: {
            feed: e.feed,
            type: e.type,
          }
        })
      end
      self
    end

    def result
      @decorated || @extracted || @parsed
    end

    private

    def construct_event(event_hash)
      event_type = Events.feed(@feed.capitalize).type(event_hash)
      @logger.debug "==================> class: #{event_type}"
      event_type.new(event_hash)
    end
    
    def subprocessor
      @subprocessor ||= Events.feed(@feed.capitalize)::Processor.new(@response) do |config|
        config = @config
      end
    end
  end

end
