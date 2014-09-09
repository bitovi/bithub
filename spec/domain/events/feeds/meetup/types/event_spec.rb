require 'domain/events/spec_helper'

describe Events::Meetup::Event do

  let(:raw_event) do
    raw_data(response_path: 'meetup/2_events.json')['results'].first
  end

  subject(:event_event) do
    Events::Meetup::Event.new(raw_event)
  end

  describe "#digest_seed" do
    it "should construct the seed using (event_id, url, name, description, status, composite_location, latitude, longitude, event_host_ids_csv)" do
      venue_warpper = Wrappers::Meetup::Venue.new(raw_event['venue'])

      seed =  raw_event['id']
      seed += raw_event['event_url']
      seed += raw_event['name']
      seed += raw_event['description']
      seed += raw_event['status']
      # seed += venue_warpper.composite_location # composite_location breaking
      seed += raw_event['event_hosts'].map{|h| h['member_id']}.join(',')
      seed += "Events::Meetup::Event"

      expect(event_event.digest_seed).to eq seed
    end
  end

  describe "#scheduled_at" do
    it "should format the scheduled_at date in iso8601" do
      event_wrapper = Wrappers::Meetup::Event.new(raw_event)
      expect(event_event.scheduled_at).to eq event_wrapper.scheduled_at.iso8601
    end
  end
end
