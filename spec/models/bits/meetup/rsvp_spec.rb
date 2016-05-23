require 'rails_helper'

describe Bits::Meetup::Rsvp do
  describe 'data' do
    it 'prepares the data for building/updating' do
      rsvp_event = Events::Meetup::RsvpEvent.new(
        raw_data(response_path: 'meetup/2_rsvps.json')['results'][0])

      bit_wrapper = Bits::Meetup::Rsvp.new(rsvp_event)
      instance = bit_wrapper.procure.instance

      expect(instance.attributes.keys).to include('title', 'body', 'origin_id', 'origin_ts')
      expect(instance.props.keys).to include('origin_author_id', 'origin_author_name', 'origin_author_avatar_url', 'event_id', 'response')
    end
  end
end
