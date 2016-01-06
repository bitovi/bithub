require 'feedjira'

module Guzzler::Fetchers

  module Rss
    class Site
      include Protocol

      def initialize(job)
        @job = job
      end

      def fetch
        log_fetch

        feed = Feedjira::Feed.fetch_and_parse(@job.config.fetch('url'))
        raise_error(feed) if feed.is_a? Numeric
        to_hashes feed
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

      private

      def to_hashes(feed)
        meta = extract_meta(feed)

        extract_entries(feed.entries).map do |e|
          e['feed'] = meta; e
        end
      end

      def extract_meta(feed)
        %i(feed_url title url).reduce({}) do |acc, f|
          acc[f.to_s] = feed.send(f) if feed.respond_to?(f)
          acc
        end
      end

      def extract_entries(entries)
        entries.map do |e|
          Hash[e.map {|f, v| [f, v]}]
        end
      end

    end
  end
end
