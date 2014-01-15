require 'digest/md5'
require 'andand'

require 'lib/core_ext'
require 'lib/loggable'
require 'events/payload'
require 'events/modules/errors'

# Require all feed and type files
Dir[File.join('app', 'domain', 'events', 'feeds', '**', '*.rb')].each do |f|
  require f
end

module Events
  class Processor
    include Loggable

    def initialize(feed)
      initialize_logger
      config = yield Hash.new if block_given?
      @feed = feed
    end
    
    def extract(response_hash)
      subprocessor.events_from_response(response_hash)
    end

    def decorate(original_hash)
      e = construct_event(original_hash)

      decorated = {
        content_digest: e.content_digest,
        source_data: e.source_data,
        meta: {
          feed: e.feed,
          type: e.type,
        }
      }
      
      if processor.respond_to? :extract_tags
        decorated[:meta][:tags] = processor.extract_tags(original_hash)
      end

      decorated
    end

    private

    def construct_event(original_hash)
      feed = @feed.capitalize
      type = subprocessor.determine_event_type(original_hash)
      Events.const_get(feed).const_get(type).new(original_hash)
    end
    
    def subprocessor
      @subprocessor ||= Events.const_get(@feed.capitalize)::Processor.new{config}
    end
  end

end
