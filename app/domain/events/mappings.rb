module Events
  module Github; end
  module Twitter; end
  module Forum; end
  module Blog; end
  module Disqus; end
  module Bithub; end
  module Meetup; end

  MAPPINGS = {}

  def self.feed(feed_name)
    if MAPPINGS.include?(feed_name)
      self.const_get(MAPPINGS[feed_name])
    else
      self.const_get(feed_name)
    end
  end
end
