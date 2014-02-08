module Events
  module JSONable

    def to_json
      {
        meta: {
          feed_name: feed_name,
          type_name: type_name,
        },
        content_digest: content_digest,
        source_data: source_data,
      }
    end

  end
end
