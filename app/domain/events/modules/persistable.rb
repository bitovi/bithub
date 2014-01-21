module Events
  module Persistable
    def build
      @instance = Event.new({
        feed: feed,
        type: type,
        content_digest: content_digest,
        source_data: source_data,
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
