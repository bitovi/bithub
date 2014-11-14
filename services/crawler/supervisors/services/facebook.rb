require 'koala'

module Supervisors::Services
  class Facebook < Supervisors::Service
    def boot
      @endpoints = SupervisionGroup.new
      pages.each do |page|
        fetcher = Fetchers::Facebook::PageFeed.new(::Koala::Facebook::API.new(page.fetch(:access_token)))
        @endpoints.supervise_as(
          page_actor_name(page.fetch(:id)),
          Poller, *[
            @embed_name,
            @brand_name,
            fetcher,
            {interval: 60}
          ]
        )
      end
    end

    private
    def page_actor_name(page_id)
      (path('pages') << 'page_id').join('_').to_sym
    end

    def pages
      service_config.fetch(:pages)
    end
  end
end
