require 'digest/md5'
require 'andand'

require 'lib/core_ext'
require 'app/domain/events/shared/type_mappings'

# Require all feed and type files
Dir[File.join('app', 'domain', 'events', 'feeds', '**', '*.rb')].each do |f|
  require f
end

module Events
  class Processor
    include Events::TypeMappings

    def initialize(feed)
      config = yield Hash.new if block_given?
      @feed = feed
      @subprocessor = Events.const_get(feed.capitalize)
                            .const_get('Processor')
                            .new{config}
    end

    def process(original_hash)
      processed = {}
      .deep_merge(hash_key_source_data_and_feed(original_hash))
      .deep_merge(origin_timestamps_hash(original_hash))

      @subprocessor.process(remap_meta_type(original_hash), processed)
    end

    def content_digest(event_hash)
      @subprocessor.content_digest(event_hash)
    end

    def events_from_response(response_hash)
      @subprocessor.events_from_response(response_hash)
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
      otss = @subprocessor.origin_timestamps(event_hash)
      return {
        origin_ts: otss.iso8601,
        origin_date: to_date_str(otss)
      }
    end

    def to_date_str(date)
      date.strftime("%Y-%m-%d")
    end

    def remap_meta_type(original_hash)
      original_hash.deep_merge({
        meta: { type: type_mappings(original_hash[:type]) }
      })
    end

  end
end
