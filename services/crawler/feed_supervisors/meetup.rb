require 'rmeetup'

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

      @endpoints.supervise_as(
        actor_name('open_events'),
        Poller,
        *[@brand_name, Fetchers::Meetup::OpenEvents.new(@client, terms: terms)]
      )

      @endpoints.supervise_as(
        actor_name('events'),
        Poller ,
        *[@brand_name, Fetchers::Meetup::Events.new(@client, group_ids: group_ids)]
      )
    end

    private
    def config
      Celluloid::Actor[:configurator].feed_config(@brand_name, :meetup)
    end
    
    def group_ids
      config.fetch(:groups)
    end

    def token
      config.fetch(:access_token)
    end

    def api_key
      Celluloid::Actor[:configurator].static_config.fetch(:public_streams).fetch(:meetup).fetch(:api_key)
    end
    
    def actor_name(endpoint_type)
      "#{@brand_name}_meetup_#{endpoint_type}".to_sym
    end
  end
end
