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

    def process(original_hash)
      processed = {
        content_digest: content_digest(original_hash),
        source_data: original_hash,
        meta: { feed: @feed },
      }
      
      @subprocessor.process(original_hash, processed)
    end

    def content_digest(original_hash)
      event.new(original_hash).content_digest
    end

    def events_from_response(response_hash)
      @subprocessor.events_from_response(response_hash)
    end

    def event
      feed = @feed.capitalize
      type = @subprocessor.determine_event_type(original_hash)
      Events.const_get(feed).const_get(type)
    end
    
    def subprocessor
      @subprocessor ||= Events.const_get(@feed.capitalize)::Processor.new{config}
    end
  end

end
