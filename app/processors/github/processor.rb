require 'lib/hash'
require 'app/processors/commons'
require 'app/processors/github/event_types'

module EventProcessor
  class Github
    include Commons
    class NotValidEventException < Exception; end

    def process(event_hash)
      processed_event_hash = {
        origin_ts: parse_date(event_hash['created_at']).iso8601,
        origin_date: parse_date(event_hash['created_at']).strftime("%Y-%m-%d"),
        hash_key: event_hash['hash_key'],
        source_data: event_hash,
        meta: {
          type: event_hash['type'].snake_case,
          feed: feed,
          origin_id: event_hash['id'],
          origin_author_name: event_hash['actor']['login'],
          origin_author_id: event_hash['actor']['id'],
          origin_author_gravatar: event_hash['actor']['gravatar_id']
        }
      }

      t = event_hash['type'].snake_case.to_sym
      begin
        processed_event_hash.deep_merge(EVENT_TYPES[t].call(event_hash))
      rescue NoMethodError => e
        raise NotValidEventException, "unknown event type"
      end
    end
  end
end
