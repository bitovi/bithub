require 'guzzler/fetchers/all'

module Guzzler::Fetchers

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
                        mappings[camelized_feed.to_sym][camelized_type.to_sym]
                      end

      if fetcher_thing && fetcher_thing.respond_to?(:fetch)
        fetcher_thing
      elsif fetcher_thing
        fetcher_thing.new(@job)
      else
        nil
      end
    end

    def native_fetcher_exists?(feed_name, type_name)
      Guzzler::Fetchers.constants.include?(feed_name) && "Guzzler::Fetchers::#{feed_name}".constantize.constants.include?(type_name)
    end

    private
    def mappings
      {
        :Github => {
          :Repo => Guzzler::Fetchers::Github::RepoActivity,
          :Org => Guzzler::Fetchers::Github::OrgActivity
        },

        :Facebook => {
          :PublicPage => Guzzler::Fetchers::Facebook::GetFeed.new(
            ::Koala::Facebook::API.new("#{ENV['FACEBOOK_CLIENT_ID']}|#{ENV['FACEBOOK_CLIENT_SECRET']}"),
            { object_id: @job.config.fetch(:id) }
          )
        },

        :Meetup => {
          :Group => Guzzler::Fetchers::Meetup::Events
        },

        :Disqus => {
          :Forum => Guzzler::Fetchers::Disqus::Comments
        },

        :Stackexchange => {
          :Tags => Guzzler::Fetchers::Stackexchange::Search
        },

        :Tumblr => {
          :Tag => Guzzler::Fetchers::Tumblr::Tagged,
          :Blog => Guzzler::Fetchers::Tumblr::Posts
        },

        :Twitter => {
          :Term => Guzzler::Fetchers::Twitter::Search.new(@job) { |c| c.fetch(:term) },
          :Hashtag => Guzzler::Fetchers::Twitter::Search.new(@job) { |c| '#' + @job.config.fetch(:hashtag) }
        }
      }
    end

  end
end
