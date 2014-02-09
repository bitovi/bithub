module Events
  module Digestable

    def content_digest
      if respond_to?(:event_id)
        calc_digest(event_id.to_s)
      elsif respond_to?(:origin_id)
        calc_digest(origin_id.to_s)
      else
        fail InvalidDigestSeed.new("don't know how to calculate digest", nice_name)
      end
    end

    def calc_digest(seed)
      Digest::MD5.hexdigest(seed + self.class.name)
    end
  end
end
