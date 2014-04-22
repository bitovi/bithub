module FeedSupervisors
  class Meetup
    include Celluloid

    def initialize(brand_name, cfg)
      @brand_name = brand_name
      @client = RMeetup::Client.new access_token: token
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

    def token
      config.fetch(:access_token)
    end

    def group_ids
      config.fetch(:groups)
    end
    
    def actor_name(endpoint_type)
      "#{@brand_name}_meetup_#{endpoint_type}".to_sym
    end
  end
end
