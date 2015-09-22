require 'guzzler/fetchers/all'

module Guzzler
  module Fetchers

    class Mapper

      def initialize(job)
        @job = job
      end

      def fetcher
        camelized_feed = @job.feed_name.camel_case
        camelized_type = @job.type_name.camel_case

        fetcher_thing = if native_fetcher_exists?(camelized_feed.to_sym, camelized_type.to_sym)
          "Guzzler::Fetchers::#{camelized_feed}::#{camelized_type}".constantize
        else
          mappings.fetch(camelized_feed.to_sym).fetch(camelized_type.to_sym)
        end

        if fetcher_thing.respond_to?(:fetch)
          fetcher_thing
        else
          fetcher_thing.new(@job)
        end

      rescue KeyError => e
        Guzzler.logger.error "Don't know how to process job #{camelized_feed}/#{camelized_type}"
        Guzzler.logger.error @job.inspect
        nil
      end

      def native_fetcher_exists?(feed_name, type_name)
        Guzzler::Fetchers.constants.include?(feed_name) && "Guzzler::Fetchers::#{feed_name}".constantize.constants.include?(type_name)
      end

      private
      def mappings
        {
          :Github => {
            :Repo => Fetchers::Github::RepoActivity,
            :Org => Fetchers::Github::OrgActivity
          },

          :Facebook => {
            :PublicPage => Fetchers::Facebook::GetFeed
          },

          :Meetup => {
            :Group => Fetchers::Meetup::Events
          },

          :Disqus => {
            :Forum => Fetchers::Disqus::Comments
          },

          :Stackexchange => {
            :Tags => Fetchers::Stackexchange::Search
          },

          :Tumblr => {
            :Tag => Fetchers::Tumblr::Tagged,
            :Blog => Fetchers::Tumblr::Posts
          },

          :Twitter => {
            :Term => Fetchers::Twitter::Search.new(@job) { |c| c.fetch('term') },
            :Hashtag => Fetchers::Twitter::Search.new(@job) { |c| '#' + @job.config.fetch('hashtag') }
          }
        }
      end

    end
  end
end
