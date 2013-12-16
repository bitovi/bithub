require 'andand'
require 'core_ext'

# Require all Event types
# strips lib because the current path is not the same thing as load path
Dir[File.join('lib', 'processing', 'feeds', '**/*.rb')].each do |f|
  require f.gsub('lib/', '')
end


module Processing
  class Processor

    class NonExistentFeedException < Exception; end
    class InvalidEventException < Exception; end
    class MissingTimestamp < Exception; end

    def initialize(feed)
      @feed = feed
      config = {}
      yield config if block_given?
      @feed_processor = Object::const_get('Processing').const_get(feed.capitalize).new(config)
    end

    def process(event_hash, fsc = nil)
      pph = {}
      .deep_merge(hash_key_source_data_and_feed(event_hash))
      .deep_merge(origin_timestamps_hash(event_hash))

      if fsc
        @feed_processor.process(event_hash, pph, fsc)
      else
        @feed_processor.process(event_hash, pph)
      end
    end

    def unique_attribute(event_hash)
      @feed_processor.unique_attribute(event_hash)
    end

    def content_digest(event_hash)
      @feed_processor.content_digest(event_hash) if @feed_processor.respond_to? :content_digest
    end

    def events_from_response(response_hash)
      @feed_processor.events_from_response(response_hash)
    end

    private

    def hash_key_source_data_and_feed(event_hash)
      return {
        hash_key: event_hash.delete(:hash_key),
        source_data: event_hash,
        meta: { feed: @feed.to_s }
      }
    end

    def origin_timestamps_hash(event_hash)
      otss = @feed_processor.origin_timestamps(event_hash)
      return {
        origin_ts: otss.iso8601,
        origin_date: to_date_str(otss)
      }
    end

    def to_date_str(date)
      date.strftime("%Y-%m-%d")
    end

  end
end
