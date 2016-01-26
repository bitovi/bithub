require 'events/events'
require 'guzzler/transformers/api'

module Guzzler
  class EventDigester

    def call(items, service)
      items.map { |item| assign_digest(item.to_h, service) }.compact
    end

    private
    def assign_digest(item, service)
      if event = Events.event_instance({ source_data: item }, service.feed_name)
        { data: item, meta: { content_digest: event.content_digest } }
      end
    end
  end
end
