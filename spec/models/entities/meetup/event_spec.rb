require 'rails_helper'

describe Entities::Meetup::Event do
  describe 'data' do
    it 'prepares the data for building/updating' do
      event_event = Events::Meetup::EventEvent.new(
        raw_data(response_path: 'meetup/2_events.json')['results'][0])

      entity_wrapper = Entities::Meetup::Event.new(event_event)
      instance = entity_wrapper.procure.instance
      puts instance.props.keys.inspect
      expect(instance.attributes.keys).to include( 'title', 'body', 'url', 'origin_id', 'origin_ts')
      expect(instance.props.keys).to include( 'location', 'status', 'scheduled_at', 'event_host_ids', 'group_name')
    end
  end
end
