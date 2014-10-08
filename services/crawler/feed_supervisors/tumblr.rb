module FeedSupervisors
  class Tumblr
    include Celluloid

    def initialize(brand_name)
      @brand_name = brand_name
      boot
    end

    def boot
      Celluloid.logger.info "Booting Tumblr supervisor for #{@brand_name}"
      @endpoints = SupervisionGroup.new

      blogs.each do |hostname|
        @endpoints.supervise_as(
          actor_name("blog_#{hostname}"),
          Poller,
          *[@brand_name, Fetchers::Tumblr::Posts.new(hostname), {interval: 600}]
        )
      end

      tags.each do |tag|
        @endpoints.supervise_as(
          actor_name("tag_#{tag}"),
          Poller,
          *[@brand_name, Fetchers::Tumblr::Tagged.new(tag), {interval: 60}]
        )
      end
    end

    private

    def config
      Celluloid::Actor[:configurator].feed_config(@brand_name, :tumblr)
    end

    def tags
      config.fetch(:tags) { [] }
    end

    def blogs
      config.fetch(:blogs) { [] }
    end

    def actor_name(endpoint_type)
      "#{@brand_name}_tumblr_#{endpoint_type}".to_sym
    end

  end
end
