module Events
  module Digestable

    def content_digest
      if respond_to?(:event_id)
        digest = calc_digest(event_id.to_s)
        digest
      elsif respond_to?(:origin_id)
        calc_digest(origin_id.to_s)
      else
        fail InvalidDigestSeed.new("missing a seed", source_data)
      end
    end

    def calc_digest(seed)
      Digest::MD5.hexdigest(seed + self.class.name)
    end
  end
end
