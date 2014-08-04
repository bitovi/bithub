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
      ) if not(terms.nil?) && not(terms.empty?)

      @endpoints.supervise_as(
        actor_name('events'),
        Poller,
        *[@brand_name,
          Fetchers::Meetup::Events.new(
            @client,
            group_ids: group_ids,
            event_set: event_set
        )]
      ) if not(group_ids.nil?) && not(group_ids.empty?)
      
      @endpoints.supervise_as(
        actor_name('rsvps'),
        Poller,
        *[@brand_name,
          Fetchers::Meetup::Rsvps.new(
            @client,
            event_set: event_set
        )]
      ) if not(event_set.nil?) && not(event_set.empty?)
      
      Celluloid::Actor[:commander].publish(register_msg, :registration)
    end

    def reload
      Celluloid::Actor[:commander].publish(unregister_msg.merge({:reloading => true}), :registration)
      Celluloid::Actor[:commander].publish(register_msg.merge({:reloading => true}), :registration)
    end

    private

    def brand_feed_config
      configurator.feed_config(@brand_name, :meetup)
    end

    def group_ids
      brand_feed_config.fetch(:groups)
    end

    def terms
      brand_feed_config.fetch(:terms)
    end

    def token
      brand_feed_config.fetch(:token)
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
