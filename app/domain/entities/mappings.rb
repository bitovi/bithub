module Entities
  module Github; end
  module Twitter; end
  module Forum; end
  module Blog; end
  module Disqus; end
  module Meetup; end
  module Bithub; end
  module Irc; end

  def self.feed(feed_name)
    feed_name = feed_name.andand.camel_case.andand.to_sym
    if self.constants.include?(feed_name)
      self.const_get(feed_name)
    else
      fail MappingError.new("Couldn't find valid feed", feed_name)
    end
  end
end
