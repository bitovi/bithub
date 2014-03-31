module FeedSupervisors
  class Meetup
    include Celluloid

    def initialize(brand_name, cfg)
      @brand_name = brand_name
      @token = cfg.fetch(:token)
    end

    def boot
      @endpoints = SupervisionGroup.new

      endpoints.each do |repo_name|
        @endpoints.supervise_as(actor_name('open_events') , Poller , *[@token , repo_name , Fetchers::Meetup::OpenEvents])
        @endpoints.supervise_as(actor_name('events')      , Poller , *[@token , repo_name , Fetchers::Meetup::Events])
        @endpoints.supervise_as(actor_name('rsvps')       , Poller , *[@token , repo_name , Fetchers::Meetup::Rsvps])
      end
    end

    private
    def repos
      @config.fetch(:repos)
    end

    def orgs
      @config.fetch(:orgs)
    end
    
    def actor_name(endpoint_type, endpoint_id)
      "#{@brand_name}_meetup_#{endpoint_type}_#{endpoint_id}".to_sym
    end

    def user_stream?(endpoint_name)
      endpoint_name =~ /_user/
    end

  end
end


    def fetchers
      if endpoint_name == :open_events
        Fetchers::Meetup::OpenEvents
      elsif endpoint_name == :events
        Fetchers::Meetup::Events
      elsif endpoint_name == :rsvps
        Fetchers::Meetup::Rsvps
      end
    end

    def connectors
      if endpoint_name == :rsvps
        Connectors::Meetup::Rsvps
      elsif endpoint_name == :open_events
        Connectors::Meetup::OpenEvents
      end
    end

#         :polling:
#             :open_events:
#                 :params:
#                     :fields: "event_hosts"
#                     :status: "past,upcoming"
#             :events:
#                 :params:
#                     :fields: "event_hosts"
#                     :status: "past"
#             :rsvps:
#                 :params:

#         :streaming:
#             :open_events:
#                 :url: "http://stream.meetup.com/2/open_events"
#             :rsvps:
#                 :url: "http://stream.meetup.com/2/rsvps"
