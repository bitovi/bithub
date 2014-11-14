module Supervisors::Services
  class Tumblr < Supervisors::Service
    def boot
      Celluloid.logger.info "Booting Tumblr supervisor for #{@brand_name}"
      @endpoints = SupervisionGroup.new

      blogs.each do |hostname|
        blog_fetcher = Fetchers::Tumblr::Posts.new(hostname) 
        @endpoints.supervise_as(
          actor_name("blog_#{hostname}"), Poller, *[
            @brand_name,
            @embed_name,
            blog_fetcher,
            { interval: 600 }
          ]
        )
      end

      tags.each do |tag|
        tag_fetcher = Fetchers::Tumblr::Tagged.new(tag)
        @endpoints.supervise_as(
          actor_name("tag_#{tag}"), Poller, *[
            @brand_name,
            @embed_name,
            tag_fetcher,
            {interval: 60}
          ]
        )
      end
    end

    private

    def tags
      service_config.fetch(:tags) { [] }
    end

    def blogs
      service_config.fetch(:blogs) { [] }
    end

    def actor_name(endpoint_type)
      "#{@brand_name}_tumblr_#{endpoint_type}".to_sym
    end

  end
end
