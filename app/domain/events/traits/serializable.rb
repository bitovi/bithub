module Events
  module Serializable
    def to_hash
      {
        meta: {
          feed_name: feed_name,
          type_name: type_name,
        },
        content_digest: content_digest,
        source_data: source_data,
      }
    end

    def to_json
      ActiveSupport::JSON.encode(to_hash)
    end
  end
end
