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
  MAPPINGS = { }

  def self.feed(feed_name)
    if MAPPINGS.include?(feed_name)
      self.const_get(MAPPINGS[feed_name])
    else
      self.const_get(feed_name)
    end
  end

  class Processor
    include Loggable

    def initialize(feed, response)
      initialize_logger
      @config = yield Hash.new if block_given?
      @response = response
      @feed = feed
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
      @extracted.map do |event_hash|
        e = construct_event

        decorated = {
          content_digest: e.content_digest,
          source_data: e.source_data,
          meta: {
            feed: e.feed,
            type: e.type,
          }
        }

        if subprocessor.respond_to? :extract_tags
          decorated[:meta][:tags] = processor.extract_tags(original_hash)
        end

        decorated
      end
    end

    private

    def construct_event
      feed_name = @feed.capitalize
      type_name = subprocessor.determine_event_type(@response)
      Events.feed(feed_name).type(type_name).new(@response)
    end
    
    def subprocessor
      @subprocessor ||= Events.feed(@feed.capitalize)::Processor.new(@response){@config}
    end
  end

end
