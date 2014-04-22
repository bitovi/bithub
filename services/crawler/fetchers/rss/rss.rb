require 'feedjira'

module Fetchers

  class Rss
    include Protocol

    def initialize(url, hints = [])
      @url = url
      @terms = []
    end

    def fetch
      x = Feedjira::Feed.fetch_and_parse(@url)
      to_hashes(x.entries)
    end

    def to_hashes(entries)
      entries.map do |e|
        Hash[e.map { |f, v| [f, v] }]
      end
    end
  end
end
