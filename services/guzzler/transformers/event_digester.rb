require 'events/events'
require 'guzzler/transformers/api'

module Guzzler
  class EventDigester

    def call(items, service)
      items.map { |item| assign_digest(item.to_h, service) }
    end

    private
    def assign_digest(item, service)
      event = Events.event_instance({ source_data: item }, service.feed_name)

      proc_item = {
        data: item,
        meta: { content_digest: event.content_digest }
      }

      proc_item
    end
  end
end

# rescue Events::DeterminationError => e
#   error "[EVENT_PUBLISHER][#{owner_data.to_log_format}] #{e}"
#   nil
# rescue KeyError => e
#   error "[EVENT_PUBLISHER][#{owner_data.to_log_format}] #{e}"
#   nil # if we can't dispatch, return nil so it will end up filtered out
# rescue TypeError => 
#   error "[EVENT_PUBLISHER][#{owner_data.to_log_format}] #{e} | #{event.inspect}"
#   raise e
#   nil
