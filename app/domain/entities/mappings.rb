module Entities
  MAPPINGS = {}

  def self.feed(feed_name)
    feed_name = feed_name.camel_case
    if MAPPINGS.include?(feed_name)
      self.const_get(MAPPINGS[feed_name])
    else
      self.const_get(feed_name)
    end
  end

  module Github; end
  module Twitter; end
  module Forum; end
  module Blog; end
  module Disqus; end
  module Meetup; end
end
