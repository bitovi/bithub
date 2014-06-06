module Events
  module Persistable

    def build
      @instance = Event.new({
        feed_name: feed_name,
        type_name: type_name,
        content_digest: content_digest,
        source_data: source_data,
        props: meta || {}
      })
      self
    end

    def persist
      @instance.save
    end

    def persist!
      @instance.save!
    end
  end
end
