require 'feedjira'

module Fetchers

  module Rss
    class Rss
      include Protocol

      def initialize(url, hints = [])
        @url = url
        @terms = []
      end

      def fetch
        x = Feedjira::Feed.fetch_and_parse(@url)
        raise_error(x) if x.is_a? Numeric
        to_hashes(x.entries)
      end

      def raise_error(x)
        if x == 0 || (200..299).include?(x) || (400..499).include?(x)
          fail ConfigError.new 'URL is not valid RSS feed'
        elsif (500..599).include?(x)
          fail RemoteError.new 'URL is unavailable'
        else
          raise UnknownError.new "Not handled, status code is #{x}"
        end
      end

      def to_hashes(entries)
        entries.map do |e|
          Hash[e.map { |f, v| [f, v] }]
        end
      end
    end
  end
end


