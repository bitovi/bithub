require 'services/intervals'
require 'rmeetup'
require 'persistent/id_set'

module Supervisors::Services::Meetup
  class Group < Supervisors::Service

    def boot
      event_set = IdSet.new(@brand_name, "meetup", "rsvp")

      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('events', group_id)).actor_name,
        Poller, *[
          @path,
          Fetchers::Meetup::Events.new(client, group_ids: [group_id], event_set: event_set),
          { interval: MEETUP_GROUP }
        ])

      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('rsvps', group_id)).actor_name,
        Poller, *[
          @path,
          Fetchers::Meetup::Rsvps.new(client, event_set: event_set),
          { interval: MEETUP_EVENT }
        ])
    end

    private

    def client
      @client ||= ::RMeetup::Client.new api_key: api_key
    end

    def group_id
      service_config.fetch(:id)
    end

    def token
      service_config.fetch(:token)
    end

    def api_key
      static_config.fetch(:meetup).fetch(:personal_key)
    end
  end
end
