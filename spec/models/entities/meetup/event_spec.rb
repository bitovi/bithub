require 'rails_helper'

describe Entities::Meetup::Event do
  describe 'data' do
    it 'prepares the data for building/updating' do
      event_event = Events::Meetup::EventEvent.new(
        raw_data(response_path: 'meetup/2_events.json')['results'][0])

      entity_wrapper = Entities::Meetup::Event.new(event_event)

      expect(entity_wrapper.data.keys).to include(
        :title, :body, :url, :origin_id, :origin_ts)

      expect(entity_wrapper.data[:props].keys).to include(
        :location, :status, :venue, :scheduled_at, :latitude,
        :longitude, :event_hosts, :event_host_ids)
    end
  end
end
