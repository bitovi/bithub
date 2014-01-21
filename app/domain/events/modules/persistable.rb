module Events
  module Persistable
    def build
      @instance = Event.new({
        feed: event.feed,
        type: event.type,
        content_digest: event.content_digest,
        source_data: event.source_data,
      })
    end

    def persist
      @instance.save
    end

    def persist!
      @instance.save!
    end
  end
end
