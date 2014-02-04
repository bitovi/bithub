module Events
  module Digestable
    def content_digest
      if respond_to? :origin_id
        @digest ||= calc_digest(origin_id.to_s)
      else
        fail InvalidDigestSeed
      end
    end

    def calc_digest(seed)
      Digest::MD5.hexdigest(seed + self.class.name)
    end
  end
end
