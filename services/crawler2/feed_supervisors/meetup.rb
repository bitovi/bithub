module FeedSupervisors
  class Meetup
    include Celluloid

    def initialize(brand_name, cfg)
      @brand_name = brand_name
      @config = cfg

      ::RMeetup::Client.api_key = $app_auth.fetch(:meetup).fetch(:api_key)
      @client = RMeetup::Client
      boot
    end

    def boot
      Celluloid.logger.info "Booting Meetup supervisor for #{@brand_name}"
      @endpoints = SupervisionGroup.new

      @endpoints.supervise_as(actor_name('open_events') , Poller , *[@brand_name, Fetchers::Meetup::OpenEvents.new(@client, {terms: @config.fetch(:terms)})])
      @endpoints.supervise_as(actor_name('events')      , Poller , *[@brand_name, Fetchers::Meetup::Events.new(@client)])
      @endpoints.supervise_as(actor_name('rsvps')       , Poller , *[@brand_name, Fetchers::Meetup::Rsvps.new(@client)])
    end

    private
    def repos
      @config.fetch(:repos)
    end

    def orgs
      @config.fetch(:orgs)
    end
    
    def actor_name(endpoint_type)
      "#{@brand_name}_meetup_#{endpoint_type}".to_sym
    end

    def user_stream?(endpoint_name)
      endpoint_name =~ /_user/
    end

  end
end
