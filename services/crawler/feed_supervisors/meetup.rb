require 'rmeetup'
require 'persistent/id_set'

module FeedSupervisors
  class Meetup
    include Celluloid

    def initialize(brand_name)
      @brand_name = brand_name
      @client = ::RMeetup::Client.new api_key: api_key
      boot
    end

    def boot
      Celluloid.logger.info "Booting Meetup supervisor for #{@brand_name}"
      @endpoints = SupervisionGroup.new

      event_set = IdSet.new(@brand_name, "meetup", "rsvp")

      @endpoints.supervise_as(
        actor_name('open_events'),
        Poller,
        *[@brand_name,
          Fetchers::Meetup::OpenEvents.new(
            @client,
            terms: terms
        )]
      )

      @endpoints.supervise_as(
        actor_name('events'),
        Poller,
        *[@brand_name,
          Fetchers::Meetup::Events.new(
            @client,
            group_ids: group_ids,
            event_set: event_set
        )]
      )
      
      @endpoints.supervise_as(
        actor_name('rsvps'),
        Poller,
        *[@brand_name,
          Fetchers::Meetup::Rsvps.new(
            @client,
            event_set: event_set
        )]
      )
    end

    private
    def config
      Celluloid::Actor[:configurator].feed_config(@brand_name, :meetup)
    end

    def group_ids
      config.fetch(:groups)
    end

    def terms
      config.fetch(:terms)
    end

    def token
      config.fetch(:access_token)
    end

    def api_key
      Celluloid::Actor[:configurator].static_config.fetch(:meetup).fetch(:api_key)
    end

    def actor_name(endpoint_type)
      "#{@brand_name}_meetup_#{endpoint_type}".to_sym
    end
  end
end
