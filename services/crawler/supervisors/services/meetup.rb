require 'rmeetup'
require 'persistent/id_set'

module Supervisors::Services
  class Meetup < Supervisors::Service
    def boot
      @client = ::RMeetup::Client.new api_key: api_key
      @endpoints = SupervisionGroup.new

      event_set = IdSet.new(@brand_name, "meetup", "rsvp")

      oe_fetcher = Fetchers::Meetup::OpenEvents.new(
        @client,
        terms: terms
      )

      @endpoints.supervise_as(
        actor_name('open_events'),
        Poller, *[
          @brand_name,
          @embed_name,
          oe_fetcher
        ]
      ) if not(terms.nil?) && not(terms.empty?)

      e_fetcher = Fetchers::Meetup::Events.new(
        @client,
        group_ids: group_ids,
        event_set: event_set
      )

      @endpoints.supervise_as(
        actor_name('events'),
        Poller, *[
          @brand_name,
          @embed_name,
          e_fetcher
        ]
      ) if not(group_ids.nil?) && not(group_ids.empty?)
      
      rsvp_fetcher = Fetchers::Meetup::Rsvps.new(
        @client,
        event_set: event_set
      )

      @endpoints.supervise_as(
        actor_name('rsvps'),
        Poller, *[
          @brand_name,
          @embed_name,
          rsvp_fetcher
        ]
      ) if not(event_set.nil?) && not(event_set.empty?)
      
      Celluloid::Actor[:commander].publish(register_msg, :registration)
    end

    def reload
      Celluloid::Actor[:commander].publish(unregister_msg.merge({:reloading => true}), :registration)
      Celluloid::Actor[:commander].publish(register_msg.merge({:reloading => true}), :registration)
    end

    private

    def group_ids
      service_config.fetch(:groups)
    end

    def terms
      service_config.fetch(:terms)
    end

    def token
      service_config.fetch(:token)
    end

    def api_key
      configurator.static_config.fetch(:meetup).fetch(:personal_key)
    end

    def actor_name(endpoint_type)
      "#{@brand_name}_meetup_#{endpoint_type}".to_sym
    end

    def configurator
      Celluloid::Actor[:configurator]
    end

    def register_msg
      {
        :action => :register,
        :feed_name => :meetup,
        :brand_name => @brand_name,
        :terms => terms
      }
    end

    def unregister_msg
      {
        :action => :unregister,
        :feed_name => :meetup,
        :brand_name => @brand_name
      }
    end
  end
end
