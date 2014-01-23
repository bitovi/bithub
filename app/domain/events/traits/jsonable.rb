module Events
  module JSONable

    def to_json
      {
        meta: {
          feed: feed,
          type: type,
        },
        content_digest: content_digest,
        source_data: source_data,
      }
    end

  end
end
