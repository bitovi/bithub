module Supervisors
  module Services
    class TumblrTagged < Supervisors::Service
      def boot
        @endpoints = SupervisionGroup.new

        tag_fetcher = Fetchers::Tumblr::Tagged.new(tag)
        @endpoints.supervise_as(
          @path.child_actor_name("endpoint_tagged_#{tag}"),
          Poller, *[
            @path,
            tag_fetcher,
            {interval: 600}
          ])
      end

      private

      def tag
        service_config.fetch(:tag)
      end
    end
  end
end
