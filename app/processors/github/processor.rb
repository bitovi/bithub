require 'lib/hash'
require 'lib/string'
require 'app/processors/github/event_types'

module EventProcessor
  class Github
    class NotValidEventException < Exception; end
    attr_reader :feed

    def initialize(opts)
      @feed = opts[:feed]
    end

    def process(event_hash)
      # Github provides date in format: "2013-02-14T22:47:29Z"
      parsed_date = Time.parse(event_hash[:created_at]).utc

      processed_event_hash = {
        origin_ts: parsed_date.iso8601,
        origin_date: parsed_date.strftime("%Y-%m-%d"),
        hash_key: event_hash[:hash_key],
        source_data: event_hash,
        meta: {
          type: event_hash[:type].snake_case,
          feed: feed,
          origin_id: event_hash[:id],
          origin_author_name: event_hash[:actor][:login],
          origin_author_id: event_hash[:actor][:id],
          origin_author_gravatar: event_hash[:actor][:gravatar_id]
        }
      }

      t = event_hash[:type]
      processed_event_hash.deep_merge(EVENT_TYPES[t].call(event_hash))
    end
  end
end
