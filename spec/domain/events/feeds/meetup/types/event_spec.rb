require 'domain/events/spec_helper'

describe Events::Meetup::Event do

  let(:raw_event) do
    raw_data(response_path: 'meetup/2_events.json')['results'].first
  end
  
  subject(:event) do
    Events::Meetup::Event.new(raw_event)
  end

  describe "#digest_seed" do
    it "should construct the seed using (event_id, url, name, description, status, composite_location, latitude, longitude, event_host_ids_csv)" do
      seed =  raw_event['id']
      seed += raw_event['event_url']
      seed += raw_event['name']
      seed += raw_event['description']
      seed += raw_event['status']
      # seed += raw_event['venue']
      seed += raw_event['venue']['lat'].to_s
      seed += raw_event['venue']['lon'].to_s
      seed += "Event::Meetup::Event"

      expect(event.digest_seed).to eq seed
    end
  end
  
  describe "#origin_id" do
    it "should delegate to event#url" do
      expect(event.origin_id).to eq raw_event['url']
    end
  end

  describe "#scheduled_at" do
    it "return the scheduled at 'time' in ISO8601 format"
  end

  describe "#origin_timestamp" do
    it "should be in UTC" do
      expect(event.origin_timestamp.zone).to eq "UTC"
    end
  end

  describe "#event_host_ids_csv" do
    pending "add some tests"
  end

end
